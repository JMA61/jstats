# ==============================================================================
#  jstats_dev_tools.R -- receive / assemble tools for the split package source
# ==============================================================================
#
#  PURPOSE
#  The package source lives in R/ as multiple .R files (the Session 108 split).
#  Claude edits against a single assembled master file (jstats_source.R) that
#  carries machine-readable sentinel lines marking each file boundary:
#
#      #<<<FILE: descriptives.R>>>
#
#  These sentinels are inert R comments. They remain as line 1 of every
#  split file in R/, and they remain in the assembled master through every
#  edit. Do not remove or alter them.
#
#  USAGE -- source this file from the package project root (the folder that
#  contains DESCRIPTION and R/), then call one of:
#
#    receive_package("jstats_source.R")
#        Takes an assembled master file received from Claude and installs it
#        into R/. Steps: parse-check and anchor-check the inbound file ->
#        structural gates (wrap call sites; overview links, S311) ->
#        timestamped backup of R/, written BESIDE the package folder since
#        S337 (<package folder>_R_backups/, the last five kept; see
#        .jdev_backup_R()) -> split on sentinels and write the R/
#        files -> reassemble-and-diff self-check (restores the backup and
#        aborts on any mismatch) -> devtools::load_all() -> document() ->
#        check(), reporting the error/warning/note tally (the known benign
#        quarto/TMPDIR quirk on Windows is filtered out of the tally).
#
#    receive_all("jstats_source.R", version = "0.9.217")
#        The whole routine after a build, in one call (S342): sets the
#        version in DESCRIPTION, runs receive_package(), then every
#        assertion battery (regression/run_all.R), then the pending
#        walk sections (regression/walk_tools.R, rewalk()). It stops
#        after the check if R CMD check found an error, a warning or a
#        note, and after the batteries if any is not green, each time
#        printing a block to paste back to Claude; a clean run ends on
#        that block too. On Windows the block is also put on the
#        clipboard. After a stop that has been looked at,
#        receive_all(from = "batteries") or receive_all(from = "walks")
#        carries on without receiving again. receive_package() is
#        unchanged and can still be called on its own.
#
#    assemble_package()
#        Concatenates the R/ files in canonical order (sentinels included)
#        into an assembled master for upload to Claude's knowledge base.
#        Prints the base-integrity anchor block (line count, sentinel count,
#        marker count) for the next session's handover.
#
#  The canonical file order is stored in tools/file_manifest.txt, which
#  receive_package() rewrites from the inbound file's sentinel order on
#  every successful receive. Adding or reordering files in a future session
#  therefore needs no edit to this script -- the inbound master is the
#  source of truth for the layout.
#
#  Files in R/ that do NOT begin with a sentinel line (currently zzz.R and
#  data.R) are never touched by either mode.
#
# ==============================================================================

# ---- internal constants ------------------------------------------------------

.jdev_sentinel_regex <- "#<<<FILE: [^>]+>>>\n"
.jdev_manifest_path  <- file.path("tools", "file_manifest.txt")
.jdev_marker         <- ".jst_jstats_class"
.jdev_backups_kept   <- 5L
# receive_all() (S342): where the batteries and the walks are. An option
# overrides it, for a run somewhere other than the workstation.
.jdev_regression_dir <- function() {
  getOption("jdev.regression.dir",
            "E:/00 R Projects/00_jstats_test_data/regression")
}
# What the last receive_all() learned, kept so that a call resumed with
# from = "batteries" or "walks" can still report the earlier stages. Its
# parent is the empty environment, and it is read with inherits = FALSE
# (S347): a lookup that missed here went on into the global environment,
# where a red battery leaves its check() helper, and the report then got a
# function in place of the R CMD check line ("argument 1 (type 'list')
# cannot be handled by 'cat'").
.jdev_last <- new.env(parent = emptyenv())

# ---- internal helpers --------------------------------------------------------

.jdev_assert_package_root <- function() {
  if (!file.exists("DESCRIPTION") || !dir.exists("R")) {
    stop("Working directory does not look like the package root ",
         "(need DESCRIPTION and R/). Current: ", getwd(), call. = FALSE)
  }
}

.jdev_read_raw <- function(path) {
  readBin(path, what = "raw", n = file.size(path))
}

.jdev_count_lines <- function(raw_bytes) {
  n <- sum(raw_bytes == as.raw(10L))
  if (length(raw_bytes) > 0 && raw_bytes[length(raw_bytes)] != as.raw(10L)) {
    n <- n + 1L
  }
  n
}

# Split an assembled master (raw bytes) on sentinel lines.
# Returns a named list of raw vectors, one per file, each INCLUDING its
# sentinel line. Stops if the file does not begin with a sentinel or if a
# sentinel appears anywhere other than the start of a line.
.jdev_split_sentinels <- function(raw_bytes) {
  txt <- rawToChar(raw_bytes)
  g <- gregexpr(.jdev_sentinel_regex, txt, useBytes = TRUE)
  m <- g[[1]]
  if (m[1] == -1) {
    stop("No sentinel lines (#<<<FILE: name.R>>>) found in the inbound file. ",
         "This does not look like an assembled master.", call. = FALSE)
  }
  starts <- as.integer(m)
  lens   <- attr(m, "match.length")
  if (starts[1] != 1L) {
    stop("The inbound file does not begin with a sentinel line. ",
         "Content before the first sentinel cannot be assigned to a file.",
         call. = FALSE)
  }
  # every sentinel after the first must sit at the start of a line
  for (s in starts[-1]) {
    if (raw_bytes[s - 1L] != as.raw(10L)) {
      stop("A sentinel was found mid-line at byte offset ", s,
           ". Sentinels must each be on their own line.", call. = FALSE)
    }
  }
  hdrs  <- regmatches(txt, g)[[1]]
  names <- sub("^#<<<FILE: ", "", sub(">>>\n$", "", hdrs))
  if (anyDuplicated(names)) {
    stop("Duplicate sentinel filename(s) in the inbound file: ",
         paste(unique(names[duplicated(names)]), collapse = ", "),
         call. = FALSE)
  }
  ends   <- c(starts[-1] - 1L, length(raw_bytes))
  chunks <- vector("list", length(starts))
  for (i in seq_along(starts)) {
    chunks[[i]] <- raw_bytes[starts[i]:ends[i]]
  }
  names(chunks) <- names
  chunks
}

.jdev_wrap_violations <- function(exprs) {
  # Structural gate -- a CALL-SITE WHITELIST (Session 292; replaces the
  # Session 255 lexical test outright). The wrapping primitives,
  # .jst_wrap_prose() and strwrap(), may be called only from the wrapper
  # layer: .jst_wrap_message() and .jst_wrap_indent(). Every emitter
  # (.jst_stop, .jst_stop_arg, .jst_warn, .jst_msg, .jst_advisory_note,
  # .jst_msg_out) wraps the assembled message at the REAL prefix reserve
  # and treats existing breaks as hard, so a builder that wraps its own
  # prose at a guessed reserve produces two sets of break points -- the
  # S287 jencode double wrap, where the word list landed as 15 and 24
  # columns when one line held it.
  # Why a whitelist and not the old "wrap lexically inside an emitter's
  # argument list" test: that test could not see a wrap assigned to a
  # variable and emitted a statement later (the jencode site), nor tell a
  # harmless reserve-0 wrap from a harmful one -- reserve 0 double-wraps
  # just as badly once the text reaches .jst_stop() (reserve 19) or
  # .jst_warn() (9). Where a builder wraps, it is wrong wherever the text
  # is going; so the rule is about the CALLER, not the route.
  # .jst_wrap_indent() stays available to builders: there the call
  # supplies the indent, not merely the wrap, and its output is
  # classified "indent" and left alone by the emitter's own wrap.
  # Walks the parse tree rather than the text, so a call split across
  # lines is caught and a mention inside a string or comment is not.
  wrappers <- c(".jst_wrap_prose", "strwrap")
  allowed  <- c(".jst_wrap_message", ".jst_wrap_indent", ".jst_wrap_prose")
  empty    <- list(quote(expr = ))
  found    <- character(0)

  walk <- function(e, fn) {
    if (is.call(e)) {
      head_nm <- if (is.name(e[[1L]])) as.character(e[[1L]]) else ""
      if (head_nm %in% wrappers && !(fn %in% allowed)) {
        found <<- c(found, paste0(fn, ": ", head_nm, "()"))
      }
      parts <- as.list(e)
      for (i in seq_along(parts)) {
        # An omitted argument (as in x[i, ]) parses to the empty symbol. Test
        # it in place: binding it to a variable makes every later use of that
        # variable raise "argument is missing, with no default".
        if (identical(parts[i], empty)) next
        walk(parts[[i]], fn)
      }
    } else if (is.pairlist(e) || is.list(e)) {
      parts <- as.list(e)
      for (i in seq_along(parts)) {
        if (identical(parts[i], empty)) next
        walk(parts[[i]], fn)
      }
    }
    invisible(NULL)
  }

  for (ex in exprs) {
    fn <- "<top level>"
    if (is.call(ex) && length(ex) >= 3L &&
        as.character(ex[[1L]])[1L] %in% c("<-", "=") && is.name(ex[[2L]])) {
      fn <- as.character(ex[[2L]])
    }
    walk(ex, fn)
  }
  # One entry per SITE, not unique(): the count reported by the gate is the
  # number of calls to fix, and two wraps in one builder are two fixes.
  found
}

# Overview gate helper (Session 311). Returns the exported functions that
# the package overview page (?jstats -- the roxygen block ending in the
# "_PACKAGE" line) does not \link. The page lists every user-facing
# function by purpose, and jai() sends AI assistants to it for the full
# function list, but it is hand-curated: jencode shipped at S238 and
# reached the page only at S277, and nothing failed in between (R CMD
# check does not know what the page is FOR). This makes the omission loud
# at the moment it is introduced.
# An export is an S3 METHOD, and exempt, when a leading part of its name up
# to a dot is itself exported (jplot.default, jplot.jst_lm): the page links
# the generic. Reads the TEXT, not the parse tree -- roxygen lives in
# comments, which parse() discards. Both @export forms are read: a bare tag
# (the function defined after the block) and "@export name".
.jdev_overview_missing <- function(txt) {
  lines  <- strsplit(txt, "\n", fixed = TRUE)[[1L]]
  pkg_at <- grep('^"_PACKAGE"[[:space:]]*$', lines)
  if (length(pkg_at) != 1L) {
    stop("Overview gate: expected exactly one \"_PACKAGE\" line in the ",
         "inbound file, found ", length(pkg_at), ". The package overview ",
         "block has moved, been renamed, or been duplicated -- aborting.",
         call. = FALSE)
  }
  top <- pkg_at
  while (top > 1L && grepl("^#'", lines[top - 1L])) top <- top - 1L
  block  <- paste(lines[top:pkg_at], collapse = "\n")
  hits   <- regmatches(block, gregexpr("\\\\link(\\[[^]]*\\])?\\{[^}]+\\}",
                                       block))[[1L]]
  linked <- sub("^\\\\link(\\[[^]]*\\])?\\{([^}]+)\\}$", "\\2", hits)

  exports <- character(0)
  for (i in grep("^#'[[:space:]]*@export\\b", lines, perl = TRUE)) {
    named <- trimws(sub("^#'[[:space:]]*@export", "", lines[i]))
    if (nzchar(named)) {
      exports <- c(exports, strsplit(named, "[[:space:]]+")[[1L]])
      next
    }
    j <- i + 1L
    while (j <= length(lines) && grepl("^#'", lines[j])) j <- j + 1L
    if (j > length(lines)) next
    m <- regmatches(lines[j], regexec(
      "^([A-Za-z.][A-Za-z0-9._]*)[[:space:]]*(<-|=)[[:space:]]*function\\b",
      lines[j], perl = TRUE))[[1L]]
    if (length(m)) exports <- c(exports, m[2L])
  }
  exports <- unique(exports)

  is_method <- vapply(exports, function(e) {
    parts <- strsplit(e, ".", fixed = TRUE)[[1L]]
    if (length(parts) < 2L) return(FALSE)
    lead <- vapply(seq_len(length(parts) - 1L), function(k)
      paste(parts[seq_len(k)], collapse = "."), character(1))
    any(lead %in% setdiff(exports, e))
  }, logical(1))

  list(exports = exports[!is_method], linked = unique(linked),
       missing = setdiff(exports[!is_method], linked))
}

# List the sentinel-managed .R files currently in R/ (first line is a sentinel).
.jdev_managed_files <- function() {
  fs <- list.files("R", pattern = "\\.R$", full.names = FALSE)
  keep <- vapply(fs, function(f) {
    con <- file(file.path("R", f), open = "rb")
    on.exit(close(con))
    first <- readLines(con, n = 1L, warn = FALSE)
    length(first) == 1L && grepl("^#<<<FILE: ", first)
  }, logical(1))
  fs[keep]
}

# Where the backups go (S337; the S289 item): a folder BESIDE the package
# folder, named for it -- E:/00 R Projects/jstats_R_backups for a package in
# E:/00 R Projects/jstats. R CMD build copies the whole package folder before
# it applies .Rbuildignore, so a backup inside it is part of every build's
# input (the S289 build failure), however well it is ignored afterwards.
.jdev_backup_home <- function() {
  root <- normalizePath(getwd(), winslash = "/", mustWork = TRUE)
  file.path(dirname(root), paste0(basename(root), "_R_backups"))
}

# Copies R/ to a timestamped folder under .jdev_backup_home() and keeps the
# newest .jdev_backups_kept of them. Only folders this function names
# (R_backup_<8 digits>_<6 digits>) are ever removed, and only there.
.jdev_backup_R <- function() {
  home <- .jdev_backup_home()
  if (!dir.exists(home) && !dir.create(home)) {
    stop("Backup of R/ failed: could not create ", home,
         ". Aborting before any changes.", call. = FALSE)
  }
  stamp <- format(Sys.time(), "%Y%m%d_%H%M%S")
  bdir  <- file.path(home, paste0("R_backup_", stamp))
  if (!dir.create(bdir)) {
    stop("Backup of R/ failed: could not create ", bdir,
         ". Aborting before any changes.", call. = FALSE)
  }
  ok <- file.copy(list.files("R", full.names = TRUE), bdir)
  if (!all(ok)) stop("Backup of R/ failed. Aborting before any changes.",
                     call. = FALSE)
  old <- sort(list.files(home, pattern = "^R_backup_[0-9]{8}_[0-9]{6}$"),
              decreasing = TRUE)
  old <- old[seq_along(old) > .jdev_backups_kept]
  for (d in old) unlink(file.path(home, d), recursive = TRUE)
  attr(bdir, "pruned") <- length(old)
  bdir
}

.jdev_restore_backup <- function(bdir, managed_then, managed_now) {
  # remove whatever the failed receive wrote, then restore the backup copies
  for (f in union(managed_then, managed_now)) {
    p <- file.path("R", f)
    if (file.exists(p)) file.remove(p)
  }
  file.copy(list.files(bdir, full.names = TRUE), "R", overwrite = TRUE)
}

# ---- receive mode ------------------------------------------------------------

receive_package <- function(file = "jstats_source.R") {
  .jdev_assert_package_root()
  if (!file.exists(file)) stop("Inbound file not found: ", file, call. = FALSE)

  raw_in <- .jdev_read_raw(file)
  txt_in <- rawToChar(raw_in)

  ## -- 1. parse check (before anything touches disk) --------------------------
  tmp <- tempfile(fileext = ".R")
  writeBin(raw_in, tmp)
  parsed <- tryCatch(parse(file = tmp),
                     error = function(e) stop("Inbound file does not parse: ",
                                              conditionMessage(e), call. = FALSE))
  cat("Parse check:        OK (", length(parsed), "top-level expressions )\n")

  ## -- 2. anchor checks --------------------------------------------------------
  n_lines <- .jdev_count_lines(raw_in)
  n_marker <- length(gregexpr(.jdev_marker, txt_in, fixed = TRUE)[[1]])
  if (!grepl(.jdev_marker, txt_in, fixed = TRUE)) {
    stop("Base-integrity marker '", .jdev_marker, "' is absent from the ",
         "inbound file. Stale or wrong base -- aborting.", call. = FALSE)
  }
  chunks <- .jdev_split_sentinels(raw_in)
  cat("Anchor checks:      OK ( lines:", n_lines,
      "| sentinels:", length(chunks),
      "| marker occurrences:", n_marker, ")\n")

  ## -- 2b. structural gate: wrapping only from the wrapper layer (S292) -----
  wrap_bad <- .jdev_wrap_violations(parsed)
  if (length(wrap_bad)) {
    stop("Structural gate failed -- ", length(wrap_bad),
         " wrap call(s) outside the wrapper layer (.jst_wrap_message / ",
         ".jst_wrap_indent):\n  ",
         paste(wrap_bad, collapse = "\n  "),
         "\nRoute the text through an emitter (.jst_stop, .jst_warn, ",
         ".jst_msg, .jst_msg_out) and let it wrap; a builder never calls ",
         ".jst_wrap_prose() or strwrap() itself. Stripping the wrap alone ",
         "is wrong on a cat() route -- convert the cat() to .jst_msg_out().",
         call. = FALSE)
  }
  cat("Structural gate:    OK ( no wrap call outside the wrapper layer )\n")

  ## -- 2c. overview gate: every export linked from ?jstats (S311) ----------
  ov <- .jdev_overview_missing(txt_in)
  if (length(ov$missing)) {
    stop("Overview gate failed -- ", length(ov$missing), " exported ",
         "function(s) not linked from the package overview (?jstats):\n  ",
         paste(ov$missing, collapse = "\n  "),
         "\nAdd each to its purpose group in the roxygen block that ends ",
         "with \"_PACKAGE\" (utils.R), as \\code{\\link{name}} -- text. ",
         "Then check _pkgdown.yml (pkgdown::check_pkgdown()) and the ",
         "guides' reference.qmd, the two other hand-curated lists.",
         call. = FALSE)
  }
  cat("Overview gate:      OK ( all", length(ov$exports),
      "exported functions linked from ?jstats )\n")

  ## -- 3. one-time migration guard ---------------------------------------------
  # if a sentinel-less copy of the monolith is still in R/, every function
  # would be defined twice (silently). Stop and have it removed first.
  old_monolith <- file.path("R", file)
  if (file.exists(old_monolith)) {
    first <- readLines(old_monolith, n = 1L, warn = FALSE)
    if (!length(first) || !grepl("^#<<<FILE: ", first)) {
      stop("A sentinel-less ", old_monolith, " is still present -- this is ",
           "the pre-split monolith, now superseded by the file you are ",
           "receiving. Delete ", old_monolith, " (it is preserved in git ",
           "and in the knowledge base), then rerun receive_package().",
           call. = FALSE)
    }
  }

  ## -- 4. timestamped backup of R/ --------------------------------------------
  managed_before <- .jdev_managed_files()
  bdir <- .jdev_backup_R()
  cat("Backup:             R/ copied to", bdir, "\n")
  cat("                    ( beside the package folder; the newest",
      .jdev_backups_kept, "are kept",
      if (attr(bdir, "pruned") > 0L)
        paste0("-- ", attr(bdir, "pruned"), " older removed"),
      ")\n")
  in_root <- list.files(".", pattern = "^R_backup_")
  if (length(in_root)) {
    cat("                    ", length(in_root), "older backup folder(s) are",
        "still INSIDE the package folder\n",
        "                    ( written before S337; nothing reads them, and",
        "they can be deleted )\n")
  }

  ## -- 5. split and write ------------------------------------------------------
  # delete sentinel-managed files not present in the inbound layout
  # (sentinel-less files such as zzz.R and data.R are never touched)
  stale <- setdiff(managed_before, names(chunks))
  for (f in stale) file.remove(file.path("R", f))
  if (length(stale)) {
    cat("Removed stale file(s) no longer in the layout:",
        paste(stale, collapse = ", "), "\n")
  }
  for (nm in names(chunks)) {
    writeBin(chunks[[nm]], file.path("R", nm))
  }
  cat("Split:              wrote", length(chunks), "file(s) to R/\n")

  ## -- 6. reassemble-and-diff self-check ---------------------------------------
  re <- do.call(c, lapply(names(chunks),
                          function(nm) .jdev_read_raw(file.path("R", nm))))
  if (!identical(re, raw_in)) {
    .jdev_restore_backup(bdir, managed_before, names(chunks))
    stop("SELF-CHECK FAILED: reassembled R/ files are not byte-identical to ",
         "the inbound file. R/ has been restored from ", bdir, ". ",
         "No package state was changed.", call. = FALSE)
  }
  cat("Self-check:         OK ( reassembly is byte-identical to inbound )\n")

  ## -- 7. write the canonical-order manifest -----------------------------------
  if (!dir.exists("tools")) dir.create("tools")
  writeLines(names(chunks), .jdev_manifest_path)
  cat("Manifest:           ", .jdev_manifest_path, "updated (",
      length(chunks), "entries )\n")

  ## -- 8. ensure .Rbuildignore covers dev-tool artifacts ------------------------
  # otherwise check() raises a "non-standard files at top level" NOTE for the
  # inbound master and the manifest on every run. "^R_backup_" stays for any
  # backup folder left in the package folder from before S337. AGENTS.md
  # (S337; the S207 item) is what jai("project") writes: non-standard at
  # the top level, so it is ignored here whether or not one exists yet.
  want <- c("^R_backup_",
            paste0("^", gsub(".", "\\.", file, fixed = TRUE), "$"),
            "^tools/file_manifest\\.txt$",
            "^jstats_dev_tools\\.R$",
            "^AGENTS\\.md$")
  have <- if (file.exists(".Rbuildignore")) {
    readLines(".Rbuildignore", warn = FALSE)
  } else character(0)
  add <- setdiff(want, have)
  if (length(add)) {
    writeLines(c(have, add), ".Rbuildignore")
    cat("Rbuildignore:        added pattern(s):", paste(add, collapse = "  "),
        "\n")
  }

  ## -- 9. load, document, check ------------------------------------------------
  cat("\n--- devtools::load_all() ---\n")
  devtools::load_all()
  cat("\n--- devtools::document() ---\n")
  devtools::document()
  cat("\n--- devtools::check() ---\n")
  res <- devtools::check(error_on = "never")

  ## -- 10. tally, filtering the known benign quarto/TMPDIR Windows quirk --------
  is_quarto_quirk <- function(x) grepl("TMPDIR", x) | grepl("quarto", x,
                                                            ignore.case = TRUE)
  errs  <- res$errors[!is_quarto_quirk(res$errors)]
  warns <- res$warnings[!is_quarto_quirk(res$warnings)]
  notes <- res$notes[!is_quarto_quirk(res$notes)]
  n_filtered <- (length(res$errors) - length(errs)) +
                (length(res$warnings) - length(warns)) +
                (length(res$notes) - length(notes))
  cat("\n==============================================\n")
  cat("CHECK TALLY:  errors:", length(errs),
      " warnings:", length(warns),
      " notes:", length(notes), "\n")
  if (n_filtered > 0) {
    cat("( filtered", n_filtered,
        "known benign quarto/TMPDIR finding(s) )\n")
  }
  cat("==============================================\n")
  invisible(res)
}

# ---- receive_all: receive, batteries, walks, and the report --------------------

# The check findings that count: receive_package()'s own filter (the benign
# quarto/TMPDIR quirk on Windows), applied to a devtools::check() result.
.jdev_check_findings <- function(res) {
  quirk <- function(x) grepl("TMPDIR", x) | grepl("quarto", x, ignore.case = TRUE)
  keep  <- function(x) { x <- as.character(x); x[!quirk(x)] }
  list(errors = keep(res$errors), warnings = keep(res$warnings),
       notes = keep(res$notes))
}

# Set "Version:" in DESCRIPTION, byte for byte otherwise. Returns the bytes
# the file held before (for a restore) with attributes old and new.
.jdev_set_version <- function(version) {
  if (!is.character(version) || length(version) != 1L ||
      !grepl("^[0-9]+\\.[0-9]+\\.[0-9]+$", version)) {
    stop("version must be one string such as \"0.9.217\".", call. = FALSE)
  }
  before <- .jdev_read_raw("DESCRIPTION")
  txt    <- rawToChar(before)
  m      <- regexpr("(?m)^Version:[ \t]*[^\r\n]*", txt, perl = TRUE)
  if (m < 0L) stop("DESCRIPTION has no Version: line.", call. = FALSE)
  old <- trimws(sub("^Version:", "", regmatches(txt, m)))
  if (package_version(version) < package_version(old)) {
    stop("version ", version, " is lower than DESCRIPTION's ", old, ".",
         call. = FALSE)
  }
  if (!identical(old, version)) {
    regmatches(txt, m) <- paste0("Version: ", version)
    writeBin(charToRaw(txt), "DESCRIPTION")
  }
  structure(before, old = old, new = version)
}

# TRUE when R/ holds exactly the inbound file: the receive got as far as
# writing it, and the self-check did not put the backup back.
.jdev_build_is_in_R <- function(file) {
  tryCatch({
    raw_in <- .jdev_read_raw(file)
    nm     <- names(.jdev_split_sentinels(raw_in))
    all(file.exists(file.path("R", nm))) &&
      identical(do.call(c, lapply(nm, function(f)
        .jdev_read_raw(file.path("R", f)))), raw_in)
  }, error = function(e) FALSE)
}

# The batteries and the walks call the package's internals bare, so they
# need the development load, not an installed copy.
.jdev_ensure_loaded <- function() {
  dev <- tryCatch(pkgload::is_dev_package("jstats"), error = function(e) FALSE)
  if (!isTRUE(dev)) devtools::load_all()
  invisible(TRUE)
}

.jdev_current_version <- function() {
  txt <- rawToChar(.jdev_read_raw("DESCRIPTION"))
  m   <- regexpr("(?m)^Version:[ \t]*[^\r\n]*", txt, perl = TRUE)
  if (m < 0L) "?" else trimws(sub("^Version:", "", regmatches(txt, m)))
}

# Print the block to paste back to Claude, between two rules, and put it on
# the clipboard where there is one (Windows). The rules are not part of it.
.jdev_report <- function(lines) {
  rule <- strrep("-", 62)
  cat("\n", rule, "\n", "PASTE THIS BACK TO CLAUDE", sep = "")
  on_clip <- FALSE
  if (identical(.Platform$OS.type, "windows")) {
    on_clip <- isTRUE(tryCatch({ utils::writeClipboard(lines); TRUE },
                               error = function(e) FALSE))
  }
  cat(if (on_clip) " (it is on the clipboard: Ctrl+V)" else "", "\n",
      rule, "\n", sep = "")
  cat(lines, sep = "\n")
  cat(rule, "\n", sep = "")
  invisible(lines)
}

# The pending sections of every walk in a folder, read through rewalk()'s
# own parser: list(<file> = "19, 22, 25, 26", ...), empty when none.
.jdev_pending_walks <- function(dir) {
  E <- environment(get("rewalk", envir = globalenv()))
  out <- list()
  for (f in E$find_walks(dir)) {
    w <- tryCatch(E$parse_walk(f), error = function(e) NULL)
    if (is.null(w) || length(w$pending$ids) == 0L) next
    out[[basename(f)]] <- paste(w$pending$ids, collapse = ", ")
  }
  out
}

receive_all <- function(file = "jstats_source.R", version = NULL,
                        from = c("receive", "batteries", "walks")) {
  from <- match.arg(from)
  .jdev_assert_package_root()
  reg <- .jdev_regression_dir()
  if (!dir.exists(reg)) {
    stop("regression folder not found: ", reg, call. = FALSE)
  }
  head_line <- function() paste0("v", .jdev_current_version(), " received.")
  resume    <- function(stage) {
    cat("\nWhen that has been looked at, carry on without receiving again:\n",
        "  receive_all(from = \"", stage, "\")\n", sep = "")
  }

  ## -- 1. receive: the version, then receive_package() -------------------------
  if (from == "receive") {
    rm(list = ls(.jdev_last, all.names = TRUE), envir = .jdev_last)
    before <- NULL
    if (!is.null(version)) {
      before <- .jdev_set_version(version)
      cat("Version:            DESCRIPTION ",
          if (identical(attr(before, "old"), version)) "already reads " else
            paste0(attr(before, "old"), " -> "),
          version, "\n", sep = "")
    }
    # A receive that stops at a gate or at the self-check has changed
    # nothing in R/, and DESCRIPTION is put back to match. One that stops
    # later (load_all, document, check) has written the build, and the
    # new version stays with it.
    res <- tryCatch(receive_package(file), error = function(e) {
      back <- !is.null(before) && !.jdev_build_is_in_R(file) &&
              !identical(attr(before, "old"), attr(before, "new"))
      if (back) writeBin(as.raw(before), "DESCRIPTION")
      stop(conditionMessage(e),
           if (back) paste0("\n(Nothing was received; DESCRIPTION is back at ",
                            attr(before, "old"), ".)"),
           call. = FALSE)
    })
    fnd   <- .jdev_check_findings(res)
    count <- function(n, word) paste0(n, " ", word, if (n != 1L) "s")
    tally <- paste0("R CMD check: ", count(length(fnd$errors), "error"), ", ",
                    count(length(fnd$warnings), "warning"), ", ",
                    count(length(fnd$notes), "note"), ".")
    assign("check", tally, envir = .jdev_last)
    if (length(unlist(fnd)) > 0L) {
      body <- c(head_line(), tally)
      for (k in c("errors", "warnings", "notes")) {
        for (x in fnd[[k]]) {
          body <- c(body, "", paste0("[", sub("s$", "", k), "]"),
                    strsplit(x, "\n", fixed = TRUE)[[1L]])
        }
      }
      .jdev_report(c(body, "", "The batteries were not run."))
      resume("batteries")
      return(invisible(list(stage = "check", ok = FALSE)))
    }
  }
  check_line <- get0("check", envir = .jdev_last, inherits = FALSE,
                     ifnotfound = "R CMD check: not run in this call.")

  ## -- 2. the batteries --------------------------------------------------------
  if (from %in% c("receive", "batteries")) {
    .jdev_ensure_loaded()
    run_all <- file.path(reg, "run_all.R")
    if (!file.exists(run_all)) stop("not found: ", run_all, call. = FALSE)
    cat("\n--- ", run_all, " ---\n", sep = "")
    G <- globalenv()
    if (exists(".ra_board", envir = G, inherits = FALSE)) rm(".ra_board", envir = G)
    err <- tryCatch({ source(run_all, local = FALSE); NULL },
                    error = function(e) conditionMessage(e))
    board <- get0(".ra_board", envir = G, inherits = FALSE)
    lines <- character(0); n <- 0L; green <- !is.null(board) && is.null(err)
    for (nm in names(board)) {
      b <- board[[nm]]
      n <- n + if (is.na(b$n)) 0L else b$n
      if (!identical(b$status, "PASS")) green <- FALSE
      lines <- c(lines, paste0("  ", formatC(nm, width = -28),
                               formatC(b$status, width = -6), "  ",
                               if (is.na(b$n)) "?" else paste0(b$n_ok, "/", b$n)))
      for (d in b$bad) {
        lines <- c(lines, paste0("      failed: ", gsub("\\s*\n\\s*", " ", d)))
      }
      if (!is.null(b$err) && !identical(b$err, "assertion battery failed")) {
        lines <- c(lines, paste0("      halted: ",
                                 gsub("\\s*\n\\s*", " ", b$err)))
      }
    }
    if (green) {
      bat_line <- paste0("run_all.R: ALL BATTERIES GREEN (", length(board),
                         " run, ", n, " checks).")
      assign("batteries", bat_line, envir = .jdev_last)
    } else {
      red <- names(board)[vapply(board, function(b)
        !identical(b$status, "PASS"), logical(1))]
      assign("batteries",
             if (is.null(board)) "run_all.R: stopped before any battery ran."
             else paste0("run_all.R: NOT GREEN (", length(red), " of ",
                         length(board), "): ", paste(red, collapse = ", "),
                         "."),
             envir = .jdev_last)
      .jdev_report(c(head_line(), check_line, "run_all.R: NOT GREEN.", lines,
                     if (!is.null(err)) paste0("run_all.R stopped: ", err),
                     "", "The walks were not run."))
      resume("walks")
      return(invisible(list(stage = "batteries", ok = FALSE)))
    }
  }
  bat_line <- get0("batteries", envir = .jdev_last, inherits = FALSE,
                   ifnotfound = "run_all.R: not run in this call.")

  ## -- 3. the walks ------------------------------------------------------------
  .jdev_ensure_loaded()
  tools <- file.path(reg, "walk_tools.R")
  if (!file.exists(tools)) stop("not found: ", tools, call. = FALSE)
  source(tools, local = FALSE)
  rw <- get("rewalk", envir = globalenv())
  cat("\n")
  rw(dir = reg)
  pend  <- .jdev_pending_walks(reg)
  named <- paste(vapply(names(pend), function(f) paste(f, pend[[f]]), ""),
                 collapse = "; ")
  calls <- paste0("rewalk(\"", sub("_walk\\.R$", "", names(pend)), "\")")
  if (length(pend) == 0L) {
    walk_line <- "Walks: none pending."
  } else {
    cat("\n")
    ans <- readline("Enter to walk the pending sections now, n to skip: ")
    if (tolower(trimws(ans)) %in% c("n", "no", "q", "skip")) {
      cat("\nTo walk them later, one line at a time:\n",
          paste0("  ", calls, "\n"), sep = "")
      walk_line <- paste0("Walks: ", named, " -- NOT walked yet.")
    } else {
      done <- 0L
      for (k in seq_along(pend)) {
        rw(sub("_walk\\.R$", "", names(pend)[k]), dir = reg)
        done <- k
        if (k < length(pend)) {
          cat("\n")
          ans <- readline(paste0("Enter for ", names(pend)[k + 1L],
                                 ", q to stop: "))
          if (tolower(trimws(ans)) %in% c("q", "quit", "stop")) break
        }
      }
      part <- function(i) paste(vapply(names(pend)[i], function(f)
        paste(f, pend[[f]]), ""), collapse = "; ")
      walk_line <- c(paste0("Walks: ", part(seq_len(done)),
                            " -- walked, all okay"),
                     "(assuming that the walks are okay).")
      if (done < length(pend)) {
        rest <- seq_along(pend)[-seq_len(done)]
        cat("\nStill to walk, one line at a time:\n",
            paste0("  ", calls[rest], "\n"), sep = "")
        walk_line <- c(walk_line, paste0("Not walked yet: ", part(rest), "."))
      }
    }
  }

  ## -- 4. the report -----------------------------------------------------------
  .jdev_report(c(head_line(), check_line, bat_line, walk_line))
  ready <- grepl("0 errors, 0 warnings, 0 notes", check_line, fixed = TRUE) &&
           grepl("ALL BATTERIES GREEN", bat_line, fixed = TRUE) &&
           !any(grepl("NOT walked yet|Not walked yet", walk_line))
  cat(if (ready) "\nNext: commit with Claude's message, then push.\n"
      else "\nPaste the block to Claude before committing.\n")
  invisible(list(stage = "done", ok = ready))
}

# ---- assemble mode -------------------------------------------------------------

assemble_package <- function(out = "jstats_source.R") {
  .jdev_assert_package_root()
  if (!file.exists(.jdev_manifest_path)) {
    stop("Manifest not found at ", .jdev_manifest_path,
         ". Run receive_package() once to create it, or create the file ",
         "manually (one R/ filename per line, in canonical order).",
         call. = FALSE)
  }
  manifest <- readLines(.jdev_manifest_path, warn = FALSE)
  manifest <- manifest[nzchar(manifest)]
  missing <- manifest[!file.exists(file.path("R", manifest))]
  if (length(missing)) {
    stop("Manifest names file(s) absent from R/: ",
         paste(missing, collapse = ", "), call. = FALSE)
  }
  unmanaged <- setdiff(.jdev_managed_files(), manifest)
  if (length(unmanaged)) {
    stop("Sentinel-bearing file(s) in R/ are not in the manifest: ",
         paste(unmanaged, collapse = ", "),
         ". Add them to ", .jdev_manifest_path, " in the right position ",
         "before assembling, or the assembled master will be incomplete.",
         call. = FALSE)
  }
  out_raw <- do.call(c, lapply(manifest,
                               function(nm) .jdev_read_raw(file.path("R", nm))))
  # verify each piece still starts with its own correct sentinel
  txt <- rawToChar(out_raw)
  chunks <- .jdev_split_sentinels(out_raw)
  if (!identical(names(chunks), manifest)) {
    stop("Sentinel headers inside the R/ files do not match the manifest ",
         "order/names. A sentinel line was probably edited or removed.",
         call. = FALSE)
  }
  writeBin(out_raw, out)
  n_lines  <- .jdev_count_lines(out_raw)
  n_marker <- length(gregexpr(.jdev_marker, txt, fixed = TRUE)[[1]])
  cat("Assembled master written to:", out, "\n")
  cat("\n--- base-integrity anchor for the next handover ---\n")
  cat("  lines:              ", n_lines, "\n")
  cat("  sentinel files:     ", length(chunks), "\n")
  cat("  marker occurrences: ", n_marker, " (", .jdev_marker, ")\n")
  cat("---------------------------------------------------\n")
  invisible(out)
}
