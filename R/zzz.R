
# -- Package lifecycle hooks ---------------------------------------------------
#
# All package-level hooks for jstats live in this file:
#
#   .onAttach()  — runs automatically on library(jstats). When the
#                  jstats.check_updates option is TRUE (the default), it
#                  performs up to two network reads: (1) a redirect-and-
#                  announce gist (successor-package migration or one-off
#                  broadcast), and (2) an r-universe version check.
#                  Both fail silently on network errors, and the gist read
#                  doubles as a connectivity probe: if it cannot reach the
#                  network, the version check is skipped rather than left to
#                  time out as well. Setting options(jstats.check_updates =
#                  FALSE) skips both reads entirely (for networked-but-no-
#                  internet machines) and just confirms the load.
#
#   .onUnload()  — runs automatically when the package is unloaded or
#                  the R session ends. Clears all session-state options
#                  the package sets.
#
# Small internal helpers used only by .onAttach() are defined here as
# well to keep the lifecycle code localized.
#
# ------------------------------------------------------------------------------


# -- Internal: redirect-gist URL -----------------------------------------------
#
# The gist is a small JSON file that lets us redirect users to a successor
# package (when the package is eventually renamed) or broadcast a one-off
# message (e.g., "course dataset updated"), without having to release a
# new package version. The URL below omits the per-commit hash segment,
# so it always serves the latest content of the gist file.
#
# Schema:
#   {
#     "schema_version": 1,
#     "current_package": "jstats",
#     "successor": null | { "package": "<name>", "install_hint": "<cmd>" },
#     "message":   null | "<string>",
#     "last_updated": "YYYY-MM-DD"
#   }

.jst_gist_url <- "https://gist.githubusercontent.com/JMA61/90aa6edf8cc898fb9bef37890892bddd/raw/jstats_redirect.json"


# -- Internal: minimal JSON field parsers --------------------------------------
#
# These parsers are tailored to the gist schema above. They are deliberately
# minimal (no jsonlite dependency). Each returns NULL when the field is
# absent, null, or empty, so the caller can test with is.null().

.jst_parse_string_field <- function(json, field) {
  pat <- paste0('"', field, '"\\s*:\\s*"([^"]*)"')
  m   <- regmatches(json, regexpr(pat, json, perl = TRUE))
  if (length(m) == 0) return(NULL)
  val <- sub(pat, "\\1", m, perl = TRUE)
  if (!nzchar(val)) return(NULL)
  val
}

.jst_parse_successor <- function(json) {
  # Matches either an object ({...}) or null.
  pat <- '"successor"\\s*:\\s*(\\{[^}]*\\}|null)'
  m   <- regmatches(json, regexpr(pat, json, perl = TRUE))
  if (length(m) == 0)  return(NULL)
  val <- sub(pat, "\\1", m, perl = TRUE)
  if (val == "null")   return(NULL)

  pkg  <- .jst_parse_string_field(val, "package")
  hint <- .jst_parse_string_field(val, "install_hint")
  if (is.null(pkg))    return(NULL)   # Malformed object — treat as no successor

  list(package = pkg, install_hint = hint)
}


# -- Internal: fetch and parse the gist ----------------------------------------
#
# Fetches the gist with a short timeout and returns a list with three
# fields: network_ok (logical), successor (list or NULL), and message
# (string or NULL).
#
# The network read here doubles as a connectivity probe for .onAttach(): the
# readLines() call is the ONLY part that touches the network, so its success
# or failure is a reliable signal for whether a second network read (the
# r-universe version check) is worth attempting. A connection failure throws and
# is caught -> network_ok = FALSE, and the caller skips the second read. A
# PARSE failure is different: it can only occur AFTER readLines() has already
# succeeded, so the network was fine and network_ok stays TRUE -- a transient
# parse glitch must not suppress a version check that would have worked.

.jst_read_gist <- function() {
  old_opts <- options(timeout = 3)
  on.exit(options(old_opts), add = TRUE)

  lines <- tryCatch(
    readLines(.jst_gist_url, warn = FALSE),
    error = function(e) NULL
  )
  if (is.null(lines)) {
    return(list(network_ok = FALSE, successor = NULL, message = NULL))
  }

  json <- paste(lines, collapse = " ")
  tryCatch(
    list(
      network_ok = TRUE,
      successor  = .jst_parse_successor(json),
      message    = .jst_parse_string_field(json, "message")
    ),
    error = function(e) list(network_ok = TRUE, successor = NULL, message = NULL)
  )
}


# -- Internal: fetch the latest jstats version from r-universe -----------------
#
# Reads the published Version from the jstats r-universe package index and
# returns it as a character string, or NA_character_ if the read fails (no
# network, the repository unreachable, or jstats not listed). Reads the source
# index (type = "source") so the version comes back regardless of the running R
# version or platform. Factored out so the version read lives in exactly one
# place: both the load-time check (.jst_show_version_status) and jupdate() call
# it.

.jst_latest_universe_version <- function() {
  old_opts <- options(timeout = 3)
  on.exit(options(old_opts), add = TRUE)

  tryCatch({
    ap <- suppressWarnings(available.packages(
      repos = "https://jma61.r-universe.dev",
      type  = "source"
    ))
    if ("jstats" %in% rownames(ap)) {
      as.character(ap["jstats", "Version"])
    } else {
      NA_character_
    }
  }, error = function(e) NA_character_)
}


# -- Internal: show the standard version-check message -------------------------
#
# Compares the latest r-universe version (via .jst_latest_universe_version()) to
# the installed version and prints either an "up to date" line or a short
# upgrade notice that points at jupdate(). Falls back to a "loaded" line if the
# version read fails (typically no internet).

.jst_show_version_status <- function(installed_ver) {
  universe_ver <- .jst_latest_universe_version()

  if (is.na(universe_ver)) {
    packageStartupMessage(
      "jstats v", installed_ver, " loaded.",
      " (Could not check for updates - no internet connection?)"
    )
    return(invisible())
  }

  if (package_version(universe_ver) > package_version(installed_ver)) {
    packageStartupMessage(
      "=======================================================\n",
      " A new version of jstats is available (", universe_ver, ").\n",
      " You have version ", installed_ver, ".\n",
      " To update, run:\n",
      "   jupdate()\n",
      "======================================================="
    )
  } else {
    packageStartupMessage("jstats v", installed_ver, " is up to date.")
  }
}


# -- Internal: show the migration message --------------------------------------
#
# Called when the gist's successor field is non-null. Replaces (not
# supplements) the standard version-check messages — at this point the
# version of the retiring package is no longer the user's concern.

.jst_show_migration <- function(successor, installed_ver) {
  pkg  <- successor$package
  hint <- successor$install_hint
  # Name the retiring package from its own metadata rather than a literal,
  # so this message carries no hardcoded source/target pair: the source is
  # whatever package this hook ships in, the target comes from the gist.
  this_pkg <- utils::packageName()
  if (is.null(this_pkg) || !nzchar(this_pkg)) this_pkg <- "This package"

  body <- paste0(
    "=======================================================\n",
    " ", this_pkg, " has been renamed to `", pkg, "`.\n",
    " This package (v", installed_ver, ") is no longer maintained."
  )

  if (!is.null(hint) && nzchar(hint)) {
    body <- paste0(body,
                   "\n To switch, run:\n",
                   "   ", hint)
  } else {
    body <- paste0(body,
                   "\n To switch, install the `", pkg, "` package.")
  }

  body <- paste0(body, "\n=======================================================")
  packageStartupMessage(body)
}


# -- Internal: vendored s3_register --------------------------------------------
#
# Standalone copy of the canonical s3_register() (the version tidyverse
# packages vendor). Registers the optional broom/generics methods at load
# WITHOUT a hard dependency on broom or generics, and WITHOUT relying on rlang
# exporting s3_register() -- it does not, even at 1.1.3. The methods activate
# only if/when `generics` (re-exported by broom) is present. (Session 71)

.jst_s3_register <- function(generic, class, method = NULL) {
  stopifnot(is.character(generic), length(generic) == 1)
  stopifnot(is.character(class), length(class) == 1)

  pieces  <- strsplit(generic, "::")[[1]]
  stopifnot(length(pieces) == 2)
  package <- pieces[[1]]
  generic <- pieces[[2]]

  caller <- parent.frame()

  get_method_env <- function() {
    top <- topenv(caller)
    if (isNamespace(top)) asNamespace(environmentName(top)) else caller
  }
  get_method <- function(method) {
    if (is.null(method)) get(paste0(generic, ".", class), envir = get_method_env())
    else method
  }

  register <- function(...) {
    envir     <- asNamespace(package)
    method_fn <- get_method(method)
    stopifnot(is.function(method_fn))
    if (exists(generic, envir)) {
      registerS3method(generic, class, method_fn, envir = envir)
    }
  }

  setHook(packageEvent(package, "onLoad"), function(...) register())
  if (isNamespaceLoaded(package)) register()
  invisible()
}


# -- .onLoad -------------------------------------------------------------------
#
# Runs automatically when the package namespace is loaded. Registers (1) the
# internal APA-export accessor methods on their own internal generics, and
# (2) the optional broom/generics adapter methods. Both are S3-method
# registrations; neither exports anything to the user-facing namespace.

.onLoad <- function(libname, pkgname) {
  ns <- asNamespace(pkgname)

  # Register the internal APA-export accessor methods on their own (internal)
  # generics. Methods on a package's OWN generic must be registered for
  # UseMethod() to find them under namespace semantics -- a bare definition in
  # the namespace is not enough. Registering here keeps both the generics and
  # the methods internal (no NAMESPACE export). (return-shape audit, Session 71)
  for (cls in c("jst_lm", "jst_logistic", "jst_freq", "jst_desc", "jst_corr",
                "default")) {
    registerS3method(".jst_apa_terms", cls,
                     get(paste0(".jst_apa_terms.", cls), envir = ns), envir = ns)
    registerS3method(".jst_apa_model", cls,
                     get(paste0(".jst_apa_model.", cls), envir = ns), envir = ns)
  }

  # Conditionally register the optional broom/generics adapter methods (defined
  # in the main source file). No-op for users without broom/generics; japa()
  # never uses these. tidy() is provided for every analysis class with a broom
  # door; glance() only for classes with a genuine model-level summary
  # (regression and ANOVA) -- the htest-backed t-test and chi-square carry
  # everything in tidy(), so they get no glance().
  for (cls in c("jst_lm", "jst_logistic", "jst_ttest", "jst_anova",
                "jst_crosstab")) {
    .jst_s3_register("generics::tidy", cls)
  }
  for (cls in c("jst_lm", "jst_logistic", "jst_anova")) {
    .jst_s3_register("generics::glance", cls)
  }
}


# -- .onAttach -----------------------------------------------------------------
#
# Runs automatically on library(jstats). Non-interactive sessions
# (e.g., R CMD check, knitr builds) are silent -- EXCEPT when the caller
# deliberately opts in via options(jstats.attach.noninteractive = TRUE).
#
# The opt-in exists for the online guides. Their Quick Start page renders a
# facsimile of the RStudio Console showing what a reader sees when they run
# library(jstats) for the first time, and that facsimile is generated by
# actually running the line during a (non-interactive) Quarto render. Without
# the opt-in, .onAttach returns early, nothing is printed, and the page would
# have to hard-code the startup message -- which would go stale on every
# version bump. With it, the render prints the real, current message.
#
# The option is deliberately NOT documented for end users and defaults to
# FALSE: an ordinary non-interactive session (R CMD check, Rscript, knitr)
# stays silent exactly as before.

.onAttach <- function(libname, pkgname) {
  if (!interactive() &&
      !isTRUE(getOption("jstats.attach.noninteractive", FALSE))) {
    return()
  }

  installed_ver <- as.character(utils::packageVersion("jstats"))

  # Opt-out for networked-but-no-internet machines (e.g., locked-down lab or
  # server installs where a route exists but the internet does not). Setting
  # options(jstats.check_updates = FALSE) skips BOTH network reads and just
  # confirms the load -- no startup freeze waiting out timeouts. Default TRUE
  # preserves the update check for everyone else.
  if (!isTRUE(getOption("jstats.check_updates", TRUE))) {
    packageStartupMessage("jstats v", installed_ver, " loaded.")
    return(invisible())
  }

  gist_info <- .jst_read_gist()

  # If the gist says a successor exists, show migration message only.
  # Otherwise run the standard r-universe version check -- but bail (skip it)
  # when the gist read could not reach the network, since the version read
  # would only time out as well. The direct fallback line below matches the one
  # .jst_show_version_status() prints on its own failure, so the user sees the
  # same notice without waiting out a second timeout.
  if (!is.null(gist_info$successor) &&
      !identical(gist_info$successor$package, "jstats")) {
    .jst_show_migration(gist_info$successor, installed_ver)
  } else if (isTRUE(gist_info$network_ok)) {
    .jst_show_version_status(installed_ver)
  } else {
    packageStartupMessage(
      "jstats v", installed_ver, " loaded.",
      " (Could not check for updates - no internet connection?)"
    )
  }

  # Append any one-off broadcast message. Fires whether or not a
  # successor is set, so it works for announcements before, during, or
  # after a migration. Skipped implicitly when the network is unreachable
  # (message is NULL in that case).
  if (!is.null(gist_info$message)) {
    packageStartupMessage(gist_info$message)
  }
}


# -- .onUnload -----------------------------------------------------------------
#
# Runs automatically when the package is unloaded (detach(..., unload =
# TRUE)) or the R session ends. Clears all session-state options the
# package sets. Moved here from the main source file in Session 10 for
# consistency with .onAttach().

.onUnload <- function(libpath) {
  options(.jst_default_data    = NULL)
  options(.jst_filter          = NULL)
  options(.jst_complete        = NULL)
  options(.jst_dummy           = NULL)
  options(.jst_output_level    = NULL)
  options(.jst_output_toggles  = NULL)
}
