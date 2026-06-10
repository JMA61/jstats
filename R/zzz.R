
# -- Package lifecycle hooks ---------------------------------------------------
#
# All package-level hooks for jstats live in this file:
#
#   .onAttach()  — runs automatically on library(jstats). Performs
#                  two independent checks: (1) compares the installed
#                  version to the current version on GitHub, and (2) reads
#                  a redirect-and-announce gist to pick up any
#                  successor-package migration or one-off broadcast
#                  message. Both checks fail silently on network errors.
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
# Fetches the gist with a short timeout and returns a list with two
# fields: successor (list or NULL) and message (string or NULL). Returns
# NULL overall if the fetch or parse fails for any reason.

.jst_read_gist <- function() {
  tryCatch({
    old_opts <- options(timeout = 5)
    on.exit(options(old_opts), add = TRUE)

    lines <- readLines(.jst_gist_url, warn = FALSE)
    json  <- paste(lines, collapse = " ")

    list(
      successor = .jst_parse_successor(json),
      message   = .jst_parse_string_field(json, "message")
    )
  }, error = function(e) NULL)
}


# -- Internal: show the standard version-check message -------------------------
#
# Reads the DESCRIPTION file from the main branch on GitHub and compares
# the Version field to the installed version. Prints either an "up to
# date" line or a multi-line upgrade notice. Falls back to a "loaded"
# line if the GitHub check fails.

.jst_show_version_status <- function(installed_ver) {
  tryCatch({
    old_opts <- options(timeout = 5)
    on.exit(options(old_opts), add = TRUE)

    github_desc <- readLines(
      "https://raw.githubusercontent.com/JMA61/jstats/main/DESCRIPTION",
      warn = FALSE
    )
    ver_line   <- github_desc[grepl("^Version:", github_desc)]
    github_ver <- trimws(sub("^Version:", "", ver_line))

    if (package_version(github_ver) > package_version(installed_ver)) {
      packageStartupMessage(
        "=======================================================\n",
        " A new version of jstats is available (", github_ver, ").\n",
        " You have version ", installed_ver, ".\n",
        " To update, run:\n",
        "   detach('package:jstats', unload = TRUE)\n",
        "   remotes::install_github('JMA61/jstats', upgrade = 'never')\n",
        "   library(jstats)\n",
        "======================================================="
      )
    } else {
      packageStartupMessage("jstats v", installed_ver, " is up to date.")
    }
  }, error = function(e) {
    packageStartupMessage(
      "jstats v", installed_ver, " loaded.",
      " (Could not check for updates - no internet connection?)"
    )
  })
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
# (e.g., R CMD check, knitr builds) are silent.

.onAttach <- function(libname, pkgname) {
  if (!interactive()) return()

  installed_ver <- as.character(utils::packageVersion("jstats"))
  gist_info     <- .jst_read_gist()

  # If the gist says a successor exists, show migration message only.
  # Otherwise, run the standard GitHub version check.
  if (!is.null(gist_info) && !is.null(gist_info$successor) &&
      !identical(gist_info$successor$package, "jstats")) {
    .jst_show_migration(gist_info$successor, installed_ver)
  } else {
    .jst_show_version_status(installed_ver)
  }

  # Append any one-off broadcast message. Fires whether or not a
  # successor is set, so it works for announcements before, during, or
  # after a migration.
  if (!is.null(gist_info) && !is.null(gist_info$message)) {
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
