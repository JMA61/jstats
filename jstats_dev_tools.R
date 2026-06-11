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
#        timestamped backup of R/ -> split on sentinels and write the R/
#        files -> reassemble-and-diff self-check (restores the backup and
#        aborts on any mismatch) -> devtools::load_all() -> document() ->
#        check(), reporting the error/warning/note tally (the known benign
#        quarto/TMPDIR quirk on Windows is filtered out of the tally).
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

.jdev_backup_R <- function() {
  stamp <- format(Sys.time(), "%Y%m%d_%H%M%S")
  bdir  <- paste0("R_backup_", stamp)
  dir.create(bdir)
  ok <- file.copy(list.files("R", full.names = TRUE), bdir)
  if (!all(ok)) stop("Backup of R/ failed. Aborting before any changes.",
                     call. = FALSE)
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
  # backups, the inbound master, and the manifest on every run
  want <- c("^R_backup_",
            paste0("^", gsub(".", "\\.", file, fixed = TRUE), "$"),
            "^tools/file_manifest\\.txt$",
            "^jstats_dev_tools\\.R$")
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
