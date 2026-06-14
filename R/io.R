#<<<FILE: io.R>>>

# -- jload --------------------------------------------------------------------

#' Load a data file into R
#'
#' @description
#' \code{jload()} reads a data file and assigns it as a data frame in your
#' environment. Supports SPSS (\code{.sav}), Stata (\code{.dta}), SAS
#' (\code{.sas7bdat}, \code{.xpt}), Excel (\code{.xlsx}, \code{.xls}),
#' CSV (\code{.csv}), and R's native \code{.rds} format.
#'
#' The file format is determined entirely by the file extension ---
#' \code{jload()} reads the extension (e.g. \code{.sav}, \code{.dta},
#' \code{.xlsx}) and uses the appropriate reader automatically.
#'
#' By default, \code{jload()} looks for the file in the working
#' directory. If a data folder is configured with
#' \code{joptions(data.dir = ...)}, that folder is searched first. If a
#' full file path is provided, it is used directly.
#'
#' The data frame is automatically named after the file (without the
#' extension). Use the \code{name} argument to specify a different name.
#'
#' @param file Character string. The filename (e.g. \code{"mydata.sav"}) or
#'   a full file path (e.g. \code{"C:/Projects/mydata.sav"}). Use forward
#'   slashes in file paths. If the extension is omitted, \code{jload()}
#'   searches for common data file types automatically.
#' @param name Character string (optional). The name to assign the data frame
#'   in your environment. If omitted, the name is derived from the filename.
#' @param use Logical. If \code{TRUE}, automatically calls \code{juse()} on
#'   the loaded data frame to set it as the default for jstats
#'   functions. Default is \code{FALSE}.
#' @param overwrite Logical. If \code{TRUE}, overwrites an existing object
#'   with the same name without prompting. If \code{FALSE} (default),
#'   prompts for confirmation in interactive sessions. In non-interactive
#'   sessions, overwrites with a warning message.
#' @param check.missing Logical. If \code{TRUE} (default), scans numeric
#'   variables for values that look like coded missing values (e.g. -99, 999)
#'   and reports them. Set to \code{FALSE} to skip this check.
#' @param sheet For Excel files only. The sheet to read --- either a sheet
#'   name (character) or sheet number (integer). Defaults to the first sheet.
#'   If the file has multiple sheets and \code{sheet} is not specified,
#'   a message lists the available sheets.
#' @param preserve.udm Logical. If \code{TRUE} (default), user-defined
#'   missing values arriving with the file are preserved: SPSS-style
#'   codes such as -99 keep their original numeric values in the data
#'   frame, with metadata attached so the package's analysis functions
#'   still treat them as missing, and Stata-style tagged values
#'   (\code{.a}, \code{.b}, ...) are kept as read. If \code{FALSE},
#'   both forms are converted to plain \code{NA} on import and the
#'   metadata is stripped. Applies to any loaded file whose columns
#'   carry missing-value declarations --- typically \code{.sav},
#'   \code{.dta}, and \code{.sas7bdat} files, and \code{.rds} files
#'   saved from such data. For \code{.sav} files, \code{TRUE}
#'   corresponds to haven's \code{user_na = TRUE}.
#' @param udm.notice Per-call override for the UDM notification frequency.
#'   \code{NULL} (default) defers to the global setting from \code{joutput()}.
#'   \code{TRUE} prints the notification on every load; \code{FALSE}
#'   suppresses it; \code{NULL} at the global level shows once per session.
#'   See \code{?joutput} for the full toggle behavior.
#'
#' @return Invisibly returns the loaded data frame. The primary effect is
#'   assigning the data frame in the calling environment.
#'
#' @details
#' \strong{File paths:}
#' Use forward slashes (\code{/}) in file paths. If you copy a path from
#' Windows File Explorer, replace the backslashes with forward slashes.
#' R does not accept single backslashes in file paths.
#'
#' \strong{File search order:}
#' \enumerate{
#'   \item If the path contains a directory separator (\code{/}), the path
#'     is used directly.
#'   \item If the path is a bare filename, \code{jload()} checks:
#'     (a) the folder named by \code{joptions("data.dir")} if it is set
#'     and exists; (b) the working directory.
#' }
#'
#' \strong{Auto-naming:}
#' The data frame name is derived from the filename by stripping the
#' extension. If the resulting name starts with a digit (which R does not
#' allow as a variable name), you must supply the \code{name} argument.
#'
#' \strong{Excel files:}
#' Excel files (\code{.xlsx}, \code{.xls}) do not contain variable or
#' value labels. The data will be loaded as plain numeric, character, or
#' logical columns. Use \code{jrelabel()} to add labels after loading
#' if needed.
#'
#' \strong{Coded missing values:}
#' When \code{check.missing = TRUE}, the function scans numeric variables
#' for values that appear to be coded missing values. Only whole-number
#' values are considered (coded missing values are always integers like
#' -99, 999, etc.). Two detection methods are used:
#' \itemize{
#'   \item For SPSS files, user-defined missing values stored in the file
#'     metadata are reported with high confidence.
#'   \item A heuristic scan detects negative values among otherwise positive
#'     data and extreme outlier values (5x the range of other values).
#' }
#' Detected values are reported but not changed. Use \code{\link{jrecode}}
#' to convert them to \code{NA} if needed.
#'
#' @examples
#' \dontrun{
#' # SPSS
#' jload("community.sav")
#' jload("community.sav", use = TRUE)
#' jload("community.sav", name = "MySurvey")
#'
#' # Stata
#' jload("community.dta")
#'
#' # SAS
#' jload("community.sas7bdat")
#' jload("community.xpt")
#'
#' # Excel
#' jload("community.xlsx")
#' jload("community.xlsx", sheet = "Wave2")
#' jload("community.xlsx", sheet = 2)
#'
#' # CSV and R native
#' jload("community.csv")
#' jload("community.rds")
#'
#' # Extension omitted -- jload searches for a matching file automatically
#' jload("community")
#'
#' # Full file path
#' jload("C:/Projects/Data/community.dta")
#'
#' # Quiet load (e.g. in a .Rprofile or startup script): suppresses the
#' # informational messages while still loading. Errors and warnings still show.
#' jload("community.rds", name = "MyData", quiet = TRUE)
#' }
#'
#' @seealso \code{\link{jstats}} for the package overview,
#'   workflow conventions, and complete function listing.
#'
#' @export
#' @param quiet Logical; default FALSE. When TRUE, suppresses jload()'s
#'   informational messages (the directory-resolution note, file found,
#'   load summary, default-data note, and the UDM narrative, overriding
#'   udm.notice). Errors, warnings, the multi-sheet advisory, and the
#'   overwrite prompt are still shown.
jload <- function(file, name = NULL, use = FALSE, overwrite = FALSE,
                  check.missing = TRUE, sheet = NULL,
                  preserve.udm = TRUE, udm.notice = NULL, quiet = FALSE) {

  # quiet = TRUE mutes informational messages (the directory-resolution
  # note, file found, load summary, default-data note, and the UDM
  # narrative). Errors, warnings, the multi-sheet advisory, and the
  # overwrite prompt are never muted.
  say <- function(...) if (!quiet) message(...)

  # Rule F: consecutive load-time notes are separated by a blank line so
  # they do not run together. The "Loaded ..." summary is a status line,
  # not a note, and is not spaced this way. say_note() wraps say() with
  # the tracking; the UDM narrative (emitted directly via message())
  # participates through the same .jst_note_fired flag.
  .jst_note_fired <- FALSE
  say_note <- function(...) {
    if (.jst_note_fired) say("")
    say(...)
    .jst_note_fired <<- TRUE
  }

  # --- Validate file argument ------------------------------------------------
  if (missing(file) || !is.character(file) || length(file) != 1 ||
      nchar(trimws(file)) == 0) {
    .jst_stop("Provide a filename, e.g. jload(\"mydata.sav\")")
  }

  # --- Determine if file has a directory component ---------------------------
  has_dir <- grepl("[/\\\\]", file)  # forward slash or Windows-native backslash

  # --- Determine file extension ----------------------------------------------
  ext <- tolower(tools::file_ext(file))

  # --- Supported extensions --------------------------------------------------
  supported_ext <- c("sav", "dta", "csv", "rds", "sas7bdat", "xpt",
                     "xlsx", "xls", "rdata", "rda")

  # --- Handle .RData/.rda redirect -------------------------------------------
  if (ext %in% c("rdata", "rda")) {
    .jst_stop(
      ".RData files contain multiple named objects. ",
      "Use load(\"", file, "\") to load these directly."
    )
  }

  # --- No extension: search for matching files -------------------------------
  # from_package flags a fall-through to a package-shipped dataset (set in
  # the search block below when nothing matches on disk).
  from_package <- FALSE
  if (ext == "") {
    found <- .jst_search_no_extension(file, has_dir)
    if (length(found) == 0) {
      # Disk files win: only when nothing matches on disk do we fall back to
      # a package-shipped dataset of this name (e.g. jload("community")).
      pkg_df <- .jst_get_package_dataset(file)
      if (!is.null(pkg_df)) {
        from_package <- TRUE
        df <- pkg_df
      } else {
        search_dirs <- if (has_dir) character(0) else .jst_get_search_dirs()
        .jst_stop(
          "No file found matching '", file, "' with any supported extension ",
          "(.sav, .dta, .csv, .rds, .sas7bdat, .xpt, .xlsx, .xls).\n",
          if (length(search_dirs) > 0)
            paste0("Searched in: ",
                   paste(ifelse(search_dirs == ".", "working directory",
                                paste0(search_dirs, " folder")),
                         collapse = " and "),
                   .jst_missing_data_dir_note())
          else
            paste0("Searched in: ", .jst_norm_path(dirname(file)))
        )
      }
    } else if (length(found) == 1) {
      say("Found ", basename(found), " in ", .jst_norm_path(dirname(found)))
      file    <- found
      ext     <- tolower(tools::file_ext(file))
      has_dir <- TRUE
    } else {
      msg <- paste0(
        "Multiple files found matching '", file, "':\n",
        paste0("  ", found, collapse = "\n"), "\n",
        "Include the file extension to specify which one."
      )
      .jst_stop(msg)
    }
  }

  # --- Validate extension ----------------------------------------------------
  if (!from_package && !ext %in% supported_ext) {
    .jst_stop(
      "Unsupported file extension '.", ext, "'. Supported formats:\n",
      "  .sav       SPSS\n",
      "  .dta       Stata\n",
      "  .sas7bdat  SAS\n",
      "  .xpt       SAS interchange\n",
      "  .xlsx      Excel\n",
      "  .xls       Excel (legacy)\n",
      "  .csv       Comma-separated values\n",
      "  .rds       R native"
    )
  }

  # --- Resolve file path -----------------------------------------------------
  if (from_package) {
    # Package dataset: df is already materialised; there is no file path to
    # resolve (resolved_path is not used on this path).
  } else if (has_dir) {
    # Full or relative path provided — use directly
    resolved_path <- file
    if (!file.exists(resolved_path)) {
      .jst_stop("File not found: ", .jst_norm_path(resolved_path))
    }
  } else {
    # Bare filename — search the data.dir folder (if set), then the working directory
    resolved_path <- .jst_find_file(file, quiet = quiet)
  }

  # --- Determine object name -------------------------------------------------
  if (!is.null(name)) {
    obj_name <- name
  } else {
    obj_name <- tools::file_path_sans_ext(basename(file))
  }

  # Check for leading digit
  if (grepl("^[0-9]", obj_name)) {
    .jst_stop(
      "The filename '", basename(file), "' starts with a number. ",
      "R does not allow variable names to start with a digit.\n",
      "Provide a name, e.g.:\n",
      "  jload(\"", file, "\", name = \"",
      gsub("^[0-9]+", "", obj_name), "\")"
    )
  }

  # Make syntactically valid (replace spaces, hyphens, etc.)
  obj_name <- make.names(obj_name)

  # --- Overwrite check -------------------------------------------------------
  target_env <- parent.frame()
  if (exists(obj_name, envir = target_env, inherits = FALSE) && !overwrite) {
    if (interactive()) {
      response <- readline(
        paste0("'", obj_name, "' already exists in your environment. ",
               "Overwrite? (y/n): ")
      )
      if (!tolower(trimws(response)) %in% c("y", "yes")) {
        message("Load cancelled.")
        return(invisible(NULL))
      }
    } else {
      message(
        "'", obj_name, "' already existed and has been replaced."
      )
    }
  }

  # --- Validate sheet argument for non-Excel files ----------------------------
  if (!is.null(sheet) && !ext %in% c("xlsx", "xls")) {
    warning(
      "`sheet` is only used for Excel format (.xlsx, .xls). ",
      "Ignoring it for this .", ext, " file.",
      call. = FALSE
    )
  }

  # --- Read the file ---------------------------------------------------------
  # For .sav: always pass user_na = TRUE so UDM metadata is available for
  # the .jst_handle_udms step below, regardless of preserve.udm. The package
  # then decides whether to preserve or convert based on preserve.udm.
  df <- if (from_package) df else switch(ext,
               sav      = haven::read_sav(resolved_path, user_na = TRUE),
               dta      = haven::read_dta(resolved_path),
               sas7bdat = haven::read_sas(resolved_path),
               xpt      = haven::read_xpt(resolved_path),
               csv      = utils::read.csv(resolved_path, stringsAsFactors = FALSE),
               rds      = readRDS(resolved_path),
               xlsx     = ,
               xls      = {
                 # List available sheets
                 all_sheets <- readxl::excel_sheets(resolved_path)

                 # Multi-sheet message (only when sheet not specified)
                 if (is.null(sheet) && length(all_sheets) > 1) {
                   message(
                     "This file has ", length(all_sheets), " sheets: ",
                     paste(all_sheets, collapse = ", "), "\n",
                     "Reading the first sheet (\"", all_sheets[1], "\"). ",
                     "To read a different sheet, use:\n",
                     "  jload(\"", basename(file), "\", sheet = \"",
                     all_sheets[2], "\")"
                   )
                 }

                 read_args <- list(path = resolved_path)
                 if (!is.null(sheet)) read_args$sheet <- sheet
                 do.call(readxl::read_excel, read_args)
               }
  )

  # Ensure result is a data frame
  if (!is.data.frame(df)) {
    if (ext == "rds") {
      .jst_stop(
        "The .rds file does not contain a data frame. ",
        "jload() only loads data frames."
      )
    }
    df <- as.data.frame(df)
  }

  # --- Capture baked classification registrations ----------------------------
  # An .rds saved by jsave may carry the active registrations as a frame-level
  # ".jst_registrations" attribute. Capture it now and strip it from the frame
  # so the object assigned to the environment is clean (the notebook, not an
  # on-object attribute, is the runtime source of truth). Non-.rds files and
  # pre-feature .rds files carry nothing, so baked_regs is NULL there. The
  # notebook is refreshed from this below, once obj_name is settled.
  baked_regs <- attr(df, ".jst_registrations")
  attr(df, ".jst_registrations") <- NULL

  # --- Handle UDMs (all formats with potential UDM metadata) -----------------
  # The read above passes user_na = TRUE for .sav so SPSS UDM metadata is
  # available. For .dta and .sas7bdat, haven natively reads tagged NAs.
  # .jst_handle_udms iterates columns and uses .jst_missing_info() to detect
  # formal declarations in either representation. For UDM-free data the
  # call is cheap and returns an empty udm_info; no narrative is emitted.
  # Either preserve the metadata (preserve.udm = TRUE, the default) or
  # convert UDM cells to plain NA and strip the metadata (preserve.udm
  # = FALSE). Either way we capture per-variable info for the narrative.
  udm_result <- .jst_handle_udms(df, preserve.udm)
  df         <- udm_result$df
  udm_info   <- udm_result$udm_info

  # --- Assign to environment -------------------------------------------------
  assign(obj_name, df, envir = target_env)

  # --- Summary message -------------------------------------------------------
  if (from_package) {
    say("Loaded the jstats example dataset '", file, "'.")
  } else {
    say(
      "Loaded ", obj_name,
      " (", .jst_format_label(ext), "; ",
      format(nrow(df), big.mark = ","), " cases, ",
      ncol(df), " variables)"
    )
  }

  # --- Refresh classification registrations ----------------------------------
  # Make the session notebook for this frame name match the file (the file is
  # the source of truth at load time). Keyed by obj_name -- the name the frame
  # is loaded as, which is what later analysis calls reference -- not the name
  # it was saved under. Restores baked registrations (replacing any differing
  # in-session ones), or clears stale ones when the loaded data carries none.
  reg_note <- .jst_refresh_registrations(obj_name, baked_regs)
  if (!is.null(reg_note)) say_note(reg_note)

  # --- Set as default with juse() if requested -------------------------------
  if (use) {
    options(.jst_default_data = obj_name)
    say_note("Default data frame set to: ", obj_name)
  }

  # --- UDM narrative notification --------------------------------------------
  # Toggle resolution: per-call udm.notice arg > joutput global toggle >
  # joutput level default. NULL at the resolved level means "auto" = show
  # once per session (tracked via .jst_udm_notice_shown option).
  if (length(udm_info) > 0) {
    notice_setting <- .jst_resolve_toggle("udm.notice", udm.notice)
    show_notice <- if (isTRUE(notice_setting)) {
      TRUE
    } else if (identical(notice_setting, FALSE)) {
      FALSE
    } else {
      # NULL / auto mode — show only if not yet shown this session
      !isTRUE(getOption(".jst_udm_notice_shown", FALSE))
    }
    if (show_notice && !quiet) {
      if (.jst_note_fired) message("")
      message(.jst_format_udm_narrative(udm_info, preserve.udm, data_name = obj_name))
      .jst_note_fired <- TRUE
      options(.jst_udm_notice_shown = TRUE)
    }
  }

  # --- Coded missing value scan ----------------------------------------------
  # When UDMs were found and announced by the narrative above, suppress the
  # diagnostic's formal branch to avoid duplicate per-variable tabular
  # output (scan_udm = FALSE). The heuristic branch always runs and can
  # surface suspicious values that aren't formally declared anywhere.
  # When no UDMs were found, scan_udm = TRUE so the formal branch picks
  # up haven_labelled_spss columns that may have arrived via .rds round-
  # trip or R-side construction (currently na_values-only; tagged_na
  # reading via the abstraction is a future refactor step).
  if (check.missing) {
    .jst_scan_coded_missing(df, obj_name, scan_udm = (length(udm_info) == 0))
  }

  invisible(df)
}


# -- jload internal helpers ---------------------------------------------------

#' Internal: materialise a package-shipped dataset by name
#'
#' @description
#' Backs jload's package-data fallback. When a bare name passed to
#' \code{jload()} matches no file on disk, jload calls this to look for a
#' dataset of that name shipped in the package's \code{data/} directory
#' (e.g. \code{jload("community")}). Returns the dataset as an
#' already-evaluated data frame -- forcing the lazy-load promise so the
#' caller can \code{assign()} a materialised object into the workspace (the
#' Data pane), not a promise that the IDE parks under Values until forced.
#'
#' @details
#' Resolves the package by its own namespace, so it follows a later package
#' rename automatically. Returns \code{NULL} -- so jload falls through to its
#' usual not-found error -- when the package is not installed as a namespace
#' (e.g. when the source is merely \code{source()}d during development), when
#' no shipped dataset of that name exists, or when the named object is not a
#' data frame.
#'
#' @param name Character(1). The bare dataset name requested.
#'
#' @return A data frame, or \code{NULL}.
#'
#' @keywords internal
.jst_get_package_dataset <- function(name) {
  pkg <- utils::packageName(environment())
  if (is.null(pkg)) return(NULL)

  avail <- tryCatch(
    utils::data(package = pkg)$results[, "Item"],
    error = function(e) character(0)
  )
  # data() item names can carry a parenthetical alias (e.g. "x (y)"); match
  # on the leading token only.
  items <- sub("\\s.*$", "", avail)
  if (!name %in% items) return(NULL)

  tmp <- new.env()
  tryCatch(
    utils::data(list = name, package = pkg, envir = tmp),
    error = function(e) NULL
  )
  if (!exists(name, envir = tmp, inherits = FALSE)) return(NULL)

  obj <- get(name, envir = tmp, inherits = FALSE)  # forces the promise
  if (!is.data.frame(obj)) return(NULL)
  obj
}

#' Internal: normalize a path for display in user-facing messages
#'
#' \code{winslash = "/"} forces forward slashes (avoiding the Windows
#' backslash/forward-slash mix that arises when paths from
#' \code{tempdir()} etc. are joined with \code{file.path()} output).
#' \code{mustWork = FALSE} allows the call to succeed for paths that
#' do not yet exist (relevant for jsave's pre-write context). Falls
#' back to the input unchanged on any error.
#'
#' @keywords internal
.jst_norm_path <- function(p) {
  tryCatch(
    normalizePath(p, winslash = "/", mustWork = FALSE),
    error = function(e) p
  )
}

#' Internal: map a file extension to its user-facing format label
#'
#' Returns the format-name parenthetical used in jload and jsave
#' success messages -- e.g. \code{"Stata format"} for \code{.dta},
#' \code{"R native format"} for \code{.rds}. Centralises the mapping
#' so both functions stay in sync, and so the labels can be edited
#' in one place if the wording is later refined.
#'
#' Unknown extensions fall back to \code{<ext> format} (e.g.
#' \code{"foo format"}), which keeps the message structurally sound
#' even if a new extension is added without updating this helper.
#'
#' @keywords internal
.jst_format_label <- function(ext) {
  switch(tolower(ext),
         sav      = "SPSS format",
         dta      = "Stata format",
         sas7bdat = "SAS format",
         xpt      = "SAS interchange format",
         xlsx     = "Excel format",
         xls      = "Excel (legacy) format",
         csv      = "CSV format",
         rds      = "R native format",
         paste0(ext, " format"))
}

#' Internal: read missing-value declarations from a column
#'
#' Central reading abstraction for the missing-value handling layer.
#' Takes a column and returns a uniform structure describing the formal
#' missing-value information attached to it, regardless of whether the
#' column carries SPSS UDM representation (\code{na_values} and/or
#' \code{na_range} attributes on \code{haven_labelled_spss}) or Stata
#' UDM representation (\code{tagged_na} markers on \code{haven_labelled}
#' or plain numeric). Downstream helpers consume this structure rather
#' than reading raw attributes themselves; this keeps representation-
#' specific knowledge in one place.
#'
#' Label-only detection (values with labels like "Refused" but no
#' formal declaration) is NOT in scope here -- that pattern is handled
#' by \code{.jst_scan_coded_missing}'s heuristic branch.
#'
#' @param col A column from a data frame, possibly with UDM attributes
#'   or Stata-style missing-value markers.
#'
#' @return \code{NULL} if the column has no formal UDM declarations.
#'   Otherwise a list with:
#'   \describe{
#'     \item{representation}{\code{"spss"} or \code{"stata"}}
#'     \item{na_range}{Length-2 numeric vector for SPSS range-based
#'       missingness, or \code{NULL}}
#'     \item{codes}{A data frame with one row per declared code/tag,
#'       or \code{NULL} if only \code{na_range} is present. Columns:
#'       \code{code} (character display form, e.g. \code{"-99"} or
#'       \code{".a"}), \code{label} (character or \code{NA}),
#'       \code{source} (\code{"na_values"} or \code{"tagged_na"}),
#'       \code{numeric} (underlying numeric value; \code{NA} for
#'       tagged NAs), \code{tag} (tag letter for Stata; \code{NA} for
#'       SPSS UDMs).}
#'   }
#'
#' @keywords internal
.jst_missing_info <- function(col) {
  na_vals  <- attr(col, "na_values")
  na_range <- attr(col, "na_range")

  has_spss_udms <- (!is.null(na_vals)  && length(na_vals)  > 0) ||
                   (!is.null(na_range) && length(na_range) == 2)

  # Tagged NAs only exist on doubles; haven::na_tag returns NA for
  # non-tagged elements on any double vector.
  has_tagged <- FALSE
  if (is.double(col)) {
    has_tagged <- any(!is.na(haven::na_tag(col)))
  }

  if (!has_spss_udms && !has_tagged) return(NULL)

  # Pathological: both representations on one column. haven's read paths
  # produce one or the other, never both. Defensive branch prefers the
  # formal SPSS declaration if somehow both are present.
  if (has_spss_udms && has_tagged) has_tagged <- FALSE

  val_labs <- if (haven::is.labelled(col)) labelled::val_labels(col) else NULL

  if (has_spss_udms) {
    # SPSS representation: na_values + optional na_range
    codes_df <- NULL

    if (!is.null(na_vals) && length(na_vals) > 0) {
      n_vals     <- as.numeric(na_vals)
      labels_vec <- rep(NA_character_, length(n_vals))

      if (!is.null(val_labs) && length(val_labs) > 0) {
        # Match labels by numeric equality; suppressWarnings handles any
        # tagged-NA entries in val_labs (they coerce to NA and don't match).
        numeric_labels <- suppressWarnings(as.numeric(val_labs))
        for (i in seq_along(n_vals)) {
          idx <- which(!is.na(numeric_labels) & numeric_labels == n_vals[i])
          if (length(idx) > 0) labels_vec[i] <- names(val_labs)[idx[1]]
        }
      }

      codes_df <- data.frame(
        code    = format(n_vals),
        label   = labels_vec,
        source  = rep("na_values", length(n_vals)),
        numeric = n_vals,
        tag     = rep(NA_character_, length(n_vals)),
        stringsAsFactors = FALSE
      )
    }

    list(
      representation = "spss",
      na_range       = if (!is.null(na_range) && length(na_range) == 2) na_range else NULL,
      codes          = codes_df
    )

  } else {
    # Stata representation: tagged_na markers
    tags_present <- unique(haven::na_tag(col))
    tags_present <- tags_present[!is.na(tags_present)]

    if (length(tags_present) == 0) return(NULL)  # defensive

    labels_vec <- rep(NA_character_, length(tags_present))

    if (!is.null(val_labs) && length(val_labs) > 0) {
      val_tags <- haven::na_tag(val_labs)
      for (i in seq_along(tags_present)) {
        idx <- which(!is.na(val_tags) & val_tags == tags_present[i])
        if (length(idx) > 0) labels_vec[i] <- names(val_labs)[idx[1]]
      }
    }

    codes_df <- data.frame(
      code    = paste0(".", tags_present),
      label   = labels_vec,
      source  = rep("tagged_na", length(tags_present)),
      numeric = rep(NA_real_, length(tags_present)),
      tag     = tags_present,
      stringsAsFactors = FALSE
    )

    list(
      representation = "stata",
      na_range       = NULL,
      codes          = codes_df
    )
  }
}

# -----------------------------------------------------------------------------
# .jst_predominant_convention()
#
# Scans the columns of a data frame and returns its predominant UDM
# convention. Per Sign-off 6b (Session 32), extracted from the body of
# .jst_options_nudge so both that helper and jdeclare_udm's post-
# declaration mismatch notice consume the same logic.
#
# Classification rules (per locked design, Cross-cutting 3 Notes):
#   - Only columns with declared UDMs count toward the predominant
#     convention. Plain numeric columns are ignored.
#   - Ties (equal SPSS- and Stata-form counts) return NA.
#   - DFs with zero UDM-bearing columns return NA.
# -----------------------------------------------------------------------------

#' Internal helper: classify a data frame's predominant UDM convention
#'
#' Walks a data frame's columns via \code{.jst_missing_info()}, counts
#' SPSS-form vs Stata-form UDM-bearing columns, and returns the
#' convention with the larger count. Returns \code{NA_character_} when
#' counts tie or when no columns carry UDM declarations.
#'
#' @param df A data frame.
#'
#' @return Character scalar: \code{"spss"}, \code{"stata"}, or
#'   \code{NA_character_}.
#'
#' @keywords internal
.jst_predominant_convention <- function(df) {
  if (!is.data.frame(df)) return(NA_character_)

  spss_count  <- 0L
  stata_count <- 0L
  for (col in df) {
    info <- .jst_missing_info(col)
    if (is.null(info)) next
    if (identical(info$representation, "spss"))  spss_count  <- spss_count  + 1L
    if (identical(info$representation, "stata")) stata_count <- stata_count + 1L
  }

  if (spss_count == 0L && stata_count == 0L) return(NA_character_)
  if (spss_count == stata_count)              return(NA_character_)
  if (spss_count > stata_count)               return("spss")
  return("stata")
}

#' Internal: inspect a data frame for UDM-bearing columns and optionally
#' convert UDM cells to NA
#'
#' Walks the columns of \code{df}, calling \code{.jst_missing_info()} on
#' each to discover formal user-defined missing-value declarations.
#' Captures per-variable information into a list entry used downstream
#' by the narrative formatter. Covers both SPSS UDM representation
#' (\code{na_values} and/or \code{na_range} on
#' \code{haven_labelled_spss}) and Stata UDM representation
#' (\code{tagged_na} markers on \code{haven_labelled}).
#'
#' When \code{preserve.udm = FALSE}, additionally converts UDM cells to
#' \code{NA} and strips the corresponding metadata. For SPSS columns
#' this strips \code{na_values} and \code{na_range}; for Stata columns
#' \code{haven::zap_missing()} converts Stata-style missing-value cells to plain NA.
#' In both cases the column's other attributes (value labels for
#' non-missing codes, variable label, class) are preserved.
#'
#' @return A list with elements \code{df} (possibly modified) and
#'   \code{udm_info} (list of per-variable info; empty list if no UDM-
#'   bearing columns were found). Each \code{udm_info} entry is a list
#'   with \code{var} (variable name) and \code{info}
#'   (the \code{.jst_missing_info()} return value for that column).
#'
#' @keywords internal
.jst_handle_udms <- function(df, preserve.udm) {
  udm_info <- list()

  for (vname in names(df)) {
    col  <- df[[vname]]
    info <- .jst_missing_info(col)
    if (is.null(info)) next

    # Capture per-variable info for the narrative
    udm_info[[length(udm_info) + 1]] <- list(
      var  = vname,
      info = info
    )

    if (!preserve.udm) {
      if (info$representation == "spss") {
        # unclass() bypasses vctrs's "Can't convert <haven_labelled> to <double>"
        # cast refusal in cold-session vec_cast dispatch ordering. See the matching
        # note in .jst_detect_suspicious_values() for full context.
        x_num <- suppressWarnings(as.numeric(unclass(col)))
        mask  <- rep(FALSE, length(x_num))

        if (!is.null(info$codes)) {
          mask <- mask | (!is.na(x_num) & x_num %in% info$codes$numeric)
        }
        if (!is.null(info$na_range)) {
          mask <- mask | (!is.na(x_num) & x_num >= info$na_range[1] & x_num <= info$na_range[2])
        }

        df[[vname]][mask] <- NA
        attr(df[[vname]], "na_values") <- NULL
        attr(df[[vname]], "na_range")  <- NULL

      } else if (info$representation == "stata") {
        # Tagged NAs already satisfy is.na() in analysis paths; conversion
        # here is for users who want plain-NA columns (no tagged-NA metadata
        # to round-trip back to Stata). haven::zap_missing converts tagged
        # NAs to plain NAs while preserving labels on non-missing values.
        df[[vname]] <- haven::zap_missing(col)
      }
    }
  }

  list(df = df, udm_info = udm_info)
}

#' Internal: format the UDM narrative notification text
#'
#' Builds the message string emitted when UDM-bearing variables are
#' detected during a load. Wording differs depending on whether the
#' UDMs were preserved (\code{preserve.udm = TRUE}) or converted
#' (\code{preserve.udm = FALSE}). Variable list is truncated at
#' \code{max_show} entries with an "...and N more" tail.
#'
#' Renders SPSS UDM codes (e.g. \code{-99}) and Stata tagged NAs
#' (e.g. \code{.a}) using parallel notation: \code{code ["label"]} or
#' \code{code (no label)}. The code form comes pre-rendered in the
#' \code{code} column of \code{.jst_missing_info()}'s return.
#'
#' @keywords internal
.jst_format_udm_narrative <- function(udm_info, preserve.udm, max_show = 10L,
                                      data_name = "data") {
  # Suggested jconvert() calls below use the loaded object's name (threaded
  # from jload) so the advice is copy-paste runnable; fall back to the
  # generic placeholder only when no name is available.
  call_name <- if (!is.null(data_name) && nzchar(data_name)) data_name else "data"
  n_vars <- length(udm_info)
  if (n_vars == 0) return(NULL)

  show_n <- min(n_vars, max_show)
  var_strings <- character(show_n)

  for (i in seq_len(show_n)) {
    entry <- udm_info[[i]]
    info  <- entry$info
    parts <- character(0)

    # Per-code rendering. info$codes is a data.frame with pre-rendered
    # display forms in the `code` column ("-99" for SPSS, ".a" for Stata),
    # and labels in the `label` column.
    if (!is.null(info$codes) && nrow(info$codes) > 0) {
      val_strs <- character(nrow(info$codes))
      for (j in seq_len(nrow(info$codes))) {
        code  <- info$codes$code[j]
        label <- info$codes$label[j]
        val_strs[j] <- if (!is.na(label) && nzchar(label)) {
          sprintf('%s ["%s"]', code, label)
        } else {
          sprintf('%s (no label)', code)
        }
      }
      parts <- c(parts, paste(val_strs, collapse = ", "))
    }

    # Range rendering (SPSS only — Stata has no equivalent)
    if (!is.null(info$na_range)) {
      parts <- c(parts, sprintf("range %s to %s",
                                format(info$na_range[1]),
                                format(info$na_range[2])))
    }

    body <- paste(parts, collapse = "; ")
    if (!preserve.udm) body <- paste0("was ", body)

    var_strings[i] <- sprintf("%s: %s", entry$var, body)
  }

  list_lines <- paste0("  ", var_strings)
  if (n_vars > max_show) {
    list_lines <- c(list_lines, paste0("  ...and ", n_vars - max_show, " more"))
  }
  list_str <- paste(list_lines, collapse = "\n")

  if (preserve.udm) {
    paste0(
      sprintf("%d %s user-defined missing values:\n", n_vars,
              if (n_vars == 1) "variable has" else "variables have"),
      list_str,
      "\nThese codes are excluded as missing in jstats analyses. ",
      "For better base R compatibility, convert them:\n",
      sprintf("  jconvert(%s, to = \"stata\")  - retains missing-value codes, ", call_name),
      "base R compatible (recommended)\n",
      sprintf("  jconvert(%s, to = \"baseR\")  - converts to plain NA and ", call_name),
      "removes missing-value codes"
    )
  } else {
    paste0(
      sprintf("%d %s user-defined missing values, ", n_vars,
              if (n_vars == 1) "variable had" else "variables had"),
      "converted to plain NA per preserve.udm = FALSE:\n",
      list_str,
      "\nTo keep the declarations instead, reload with preserve.udm = TRUE."
    )
  }
}

#' Internal: format a character vector as a comma-separated list with truncation
#'
#' Renders a vector of variable names (or any character vector) as a
#' single comma-separated string, truncating after \code{max_show}
#' entries with a \code{"... and N more"} suffix. Used by jsave's
#' pre-flight error messages so the .sav, .dta, and .xpt code paths
#' share one truncation convention.
#'
#' @param vars Character vector of names to render.
#' @param max_show Integer. Maximum number of names to show before
#'   truncating. Default \code{10L}.
#'
#' @return Character scalar. Empty string if \code{vars} is empty.
#'
#' @keywords internal
.jst_format_var_list <- function(vars, max_show = 10L) {
  n <- length(vars)
  if (n == 0) return("")
  show_n <- min(n, max_show)
  out <- paste(vars[seq_len(show_n)], collapse = ", ")
  if (n > show_n) {
    out <- paste0(out, ", ... and ", n - show_n, " more")
  }
  out
}

#' Internal: detect tagged-NA-bearing columns in a data frame
#'
#' @description
#' Returns the names of variables whose UDM representation is
#' Stata-form (Stata-style tagged missing values, e.g.
#' \code{haven::tagged_na("a")}). Used by jsave's pre-flight checks
#' before writing to \code{.sav} and \code{.xpt} (neither format
#' carries tagged NAs).
#'
#' @details
#' Walks the columns of \code{data} via \code{.jst_missing_info()}
#' for a single source of truth on UDM representation detection.
#' Returns names where \code{representation == "stata"}.
#'
#' @keywords internal
.jst_has_tagged_na <- function(data) {
  affected <- character(0)
  for (vname in names(data)) {
    info <- .jst_missing_info(data[[vname]])
    if (!is.null(info) && identical(info$representation, "stata")) {
      affected <- c(affected, vname)
    }
  }
  affected
}

#' Internal: detect SPSS-form UDM-bearing columns in a data frame
#'
#' @description
#' Returns the names of variables whose UDM representation is
#' SPSS-form, i.e. the column carries \code{na_values} and/or
#' \code{na_range} attributes (as produced by
#' \code{haven::labelled_spss()}). Used by jsave's pre-flight check
#' before writing to \code{.dta} (which has no SPSS-UDM
#' representation; Stata uses tagged NAs instead).
#'
#' @details
#' Walks the columns of \code{data} via \code{.jst_missing_info()}
#' for a single source of truth on UDM representation detection.
#' Returns names where \code{representation == "spss"}.
#'
#' @keywords internal
.jst_has_spss_udm <- function(data) {
  affected <- character(0)
  for (vname in names(data)) {
    info <- .jst_missing_info(data[[vname]])
    if (!is.null(info) && identical(info$representation, "spss")) {
      affected <- c(affected, vname)
    }
  }
  affected
}

#' Internal: search for a file without extension across supported formats
#' @keywords internal
.jst_search_no_extension <- function(basename_no_ext, has_dir) {

  search_ext <- c("sav", "dta", "csv", "rds", "sas7bdat", "xpt", "xlsx", "xls")
  found <- character(0)

  if (has_dir) {
    # Has directory component — search only in that directory
    for (e in search_ext) {
      candidate <- paste0(basename_no_ext, ".", e)
      if (file.exists(candidate)) found <- c(found, candidate)
    }
  } else {
    # Bare filename — search the data.dir folder (if set), then the working directory
    search_dirs <- .jst_get_search_dirs()
    for (d in search_dirs) {
      for (e in search_ext) {
        candidate <- file.path(d, paste0(basename_no_ext, ".", e))
        if (file.exists(candidate)) found <- c(found, candidate)
      }
    }
  }

  return(found)
}

#' Internal: get the ordered list of directories to search for data files
#'
#' Resolution rules:
#' - If \code{joptions("data.dir")} is set and that folder exists, it is
#'   searched first.
#' - The working directory itself is always included as the final
#'   search location.
#'
#' Internal: note for a configured-but-missing data.dir
#'
#' Returns a one-line note (with a leading newline) when
#' \code{joptions(data.dir = ...)} points at a folder that does not currently
#' exist; otherwise returns \code{""}. Appended to jload's not-found errors so
#' a typo'd or stale \code{data.dir} is diagnosed where it bites rather than
#' surfacing as a bare "searched in working directory". Uses the same
#' \code{dir.exists()} test as \code{.jst_get_search_dirs()}, so it fires
#' exactly when the configured folder was skipped from the search path.
#'
#' @keywords internal
.jst_missing_data_dir_note <- function() {
  data_dir <- getOption(".jst_options_data_dir", .jst_options_defaults$data.dir)
  if (!is.null(data_dir) && !dir.exists(data_dir)) {
    paste0("\nNote: the configured data folder '", data_dir,
           "' does not exist (set via joptions(data.dir = ...)).")
  } else {
    ""
  }
}

#' @keywords internal
.jst_get_search_dirs <- function() {
  data_dir <- getOption(".jst_options_data_dir",
                        .jst_options_defaults$data.dir)
  dirs <- character(0)

  if (!is.null(data_dir)) {
    # Explicit data.dir set — search there if it exists. No case-insensitive
    # fallback: an explicit "MyFolder" will not silently match "myfolder".
    if (dir.exists(data_dir)) dirs <- c(dirs, data_dir)
  }

  # Working directory is always searched last, matching base-R conventions.
  dirs <- c(dirs, ".")
  dirs
}

#' Internal: find a bare filename in the data.dir folder or the working directory
#' @param quiet Logical; default FALSE. When TRUE, suppresses the
#'   "Reading from <dir>" note (propagated from jload()'s quiet argument).
#'   The not-found error is unaffected.
#' @keywords internal
.jst_find_file <- function(filename, quiet = FALSE) {
  search_dirs <- .jst_get_search_dirs()
  for (d in search_dirs) {
    candidate <- file.path(d, filename)
    if (file.exists(candidate)) {
      if (d != "." && !quiet) {
        message("Reading from ", .jst_norm_path(d))
      }
      return(candidate)
    }
  }
  .jst_stop(
    "File '", filename, "' not found.\n",
    "Searched in: ",
    paste(ifelse(search_dirs == ".", "working directory",
                 paste0(search_dirs, " folder")),
          collapse = " and "),
    .jst_missing_data_dir_note(), "\n",
    "Check that the filename and extension are correct."
  )
}

#' Internal: scan for coded missing values and report findings
#'
#' @param scan_udm Logical. When \code{FALSE}, the haven \code{na_values}
#'   and \code{na_range} branches are skipped (only the suspicious-values
#'   heuristic runs). Set to \code{FALSE} when called after
#'   \code{.jst_handle_udms()} has already produced its narrative for
#'   \code{.sav} loads, to avoid duplicate output. The heuristic branch
#'   always excludes values that are formally declared in
#'   \code{na_values} or \code{na_range} on the variable, so passing
#'   \code{scan_udm = FALSE} produces no UDM-related output -- neither
#'   tabular nor flagged-as-suspected.
#'
#' @keywords internal
.jst_scan_coded_missing <- function(df, obj_name, scan_udm = TRUE) {

  max_report <- 10L  # Maximum number of rows to display (harmonized with
                     # the narrative cap in .jst_format_udm_narrative)

  # Collect findings: list of lists with var, value, count, source
  findings <- list()

  for (vname in names(df)) {
    col <- df[[vname]]
    if (!is.numeric(col) && !inherits(col, "haven_labelled")) next
    # Only scan numeric-like variables
    num_vals <- suppressWarnings(as.numeric(col))
    if (all(is.na(num_vals))) next

    # Pull formal UDM declarations once per variable. Both branches use
    # them: the formal branch (when scan_udm = TRUE) tabulates them, and
    # the heuristic branch (always) filters them OUT so values formally
    # declared as UDMs are never flagged as "suspected".
    spss_na_vals  <- attr(col, "na_values")
    spss_na_range <- attr(col, "na_range")

    # Value labels are used by the heuristic branch's label-only check —
    # values that have a label attached but no formal na_values
    # declaration are reported as "label-only" rather than "suspected".
    # This pattern arises commonly after .dta or .xpt round-trip, which
    # preserve value labels but not the formal UDM declaration.
    val_labs <- attr(col, "labels")

    # --- Check SPSS user-defined missing values (haven attribute) ---
    # SPSS-defined missings are checked on ALL values (including decimals)
    # because SPSS allows any value to be defined as missing.
    # Skipped (scan_udm = FALSE) when called from jload after the
    # narrative notification has already covered UDMs for .sav loads.
    if (scan_udm) {
      if (!is.null(spss_na_vals)) {
        for (sv in spss_na_vals) {
          n_cases <- sum(num_vals == sv, na.rm = TRUE)
          if (n_cases > 0) {
            findings[[length(findings) + 1]] <- list(
              var = vname, value = sv, count = n_cases,
              source = "udm"
            )
          }
        }
      }

      if (!is.null(spss_na_range)) {
        range_lo <- spss_na_range[1]
        range_hi <- spss_na_range[2]
        range_match <- !is.na(num_vals) & num_vals >= range_lo & num_vals <= range_hi
        if (any(range_match)) {
          range_vals <- sort(unique(num_vals[range_match]))
          for (rv in range_vals) {
            # Skip if already found via na_values
            already <- any(vapply(findings, function(f) {
              f$var == vname && f$value == rv
            }, logical(1)))
            if (!already) {
              n_cases <- sum(num_vals == rv, na.rm = TRUE)
              findings[[length(findings) + 1]] <- list(
                var = vname, value = rv, count = n_cases,
                source = "udm"
              )
            }
          }
        }
      }
    }

    # --- Heuristic scan using existing detection function ---
    # Only scan whole-number values — coded missings are always integers
    whole_vals <- num_vals[!is.na(num_vals) & num_vals == round(num_vals)]
    if (length(whole_vals) >= 2) {
      suspicious <- .jst_detect_suspicious_values(whole_vals, vname)
      for (sv in suspicious) {
        # Skip if formally declared as UDM on this variable. This filter
        # runs whether or not scan_udm = TRUE: when scan_udm = FALSE the
        # formal branch was gated off (because the .sav narrative covered
        # the UDMs), and without this filter the heuristic would mislabel
        # those same values as suspected ("not formally defined").
        is_formal_udm <-
          (!is.null(spss_na_vals) && sv %in% spss_na_vals) ||
          (!is.null(spss_na_range) && length(spss_na_range) == 2 &&
           sv >= spss_na_range[1] && sv <= spss_na_range[2])
        if (is_formal_udm) next

        # Skip if already reported from SPSS metadata
        already <- any(vapply(findings, function(f) {
          f$var == vname && f$value == sv
        }, logical(1)))
        if (already) next

        # Look up a value label for this code (if any). When the variable
        # has a label that suggests missingness (per the package-wide
        # wordlist defined at .jst_missing_label_wordlist), the finding is
        # "label-only" — the metadata signals UDM intent but the formal
        # na_values declaration is missing. Generic labels on suspicious
        # values (e.g. "Bad data" on a -99) fall through to the
        # "suspected" classification because they do not match the
        # missing-suggestive wordlist. (Wordlist narrowing per Q1 of the
        # Session 28 jconvert design lock; symmetric with jconvert's
        # Pattern A detection.)
        val_label_text <- NULL
        if (!is.null(val_labs)) {
          match_idx <- which(val_labs == sv)
          if (length(match_idx) > 0) {
            candidate <- names(val_labs)[match_idx[1]]
            if (nzchar(candidate) &&
                .jst_label_suggests_missing(candidate)) {
              val_label_text <- candidate
            }
          }
        }

        n_cases <- sum(num_vals == sv, na.rm = TRUE)
        if (!is.null(val_label_text)) {
          findings[[length(findings) + 1]] <- list(
            var = vname, value = sv, count = n_cases,
            label = val_label_text,
            source = "label_only"
          )
        } else {
          findings[[length(findings) + 1]] <- list(
            var = vname, value = sv, count = n_cases,
            source = "suspected"
          )
        }
      }
    }
  }

  # --- Report findings -------------------------------------------------------
  if (length(findings) > 0) {

    # Internal source keys ("udm", "label_only", "suspected") are kept
    # separate from the user-facing tag text below, so display wording
    # can change without touching comparison logic. (The former em-dash
    # tag strings doubled as comparison keys; this split removes that
    # hazard, and the tag text itself is now ASCII-only per the
    # runtime-string punctuation convention.)
    src_display <- c(
      udm        = "user-defined missing value",
      label_only = "label-only - not formally declared",
      suspected  = "suspected - not formally defined"
    )

    sources_present <- unique(vapply(findings, function(f) f$source, character(1)))
    has_udm        <- "udm"        %in% sources_present
    has_label_only <- "label_only" %in% sources_present
    has_heur       <- "suspected"  %in% sources_present

    # Single-source rendering: when exactly ONE source type is present,
    # the per-row [source] tags would repeat one fact on every row, so
    # the rows drop the brackets and the legend reads as plain prose.
    # When two or more sources mix, the tags disambiguate the rows (the
    # tag-system carve-out) and the bracketed per-source legends stay.
    single_source <- length(sources_present) == 1L

    # Heading: telegraph "Suspected" only when ALL findings are pure
    # heuristic (no formal UDMs and no label-only). Both formal UDMs and
    # label-only findings represent real metadata that earns the neutral
    # wording even when heuristic findings are mixed in.
    heading <- if (has_heur && !has_udm && !has_label_only) {
      "Suspected missing-value codes detected:"
    } else {
      "Missing-value codes detected:"
    }
    cat("\n", heading, "\n", sep = "")

    # Group findings by (variable, source). One row per group lists every
    # value flagged for that combination. This collapses the typical UDM
    # case (Cont_udm with codes -99 and -98) from two lines to one. Mixed
    # sources on the same variable (rare -- e.g. a UDM-bearing variable
    # with an additional sentinel value caught only by the heuristic)
    # produce two rows for that variable, one per source. Group order
    # preserves the scan order of first appearance.
    group_keys <- character(0)
    groups     <- list()
    for (f in findings) {
      key <- paste0(f$var, "|", f$source)
      if (is.null(groups[[key]])) {
        group_keys <- c(group_keys, key)
        groups[[key]] <- list(var = f$var, source = f$source,
                              values = numeric(0), counts = integer(0),
                              labels = character(0))
      }
      groups[[key]]$values <- c(groups[[key]]$values, f$value)
      groups[[key]]$counts <- c(groups[[key]]$counts, f$count)
      groups[[key]]$labels <- c(groups[[key]]$labels,
                                if (!is.null(f$label)) f$label else "")
    }

    n_groups <- length(group_keys)
    n_show   <- min(n_groups, max_report)

    # Dynamic width for the variable-name column so all rows align
    # cleanly regardless of name length. +1 for the trailing colon.
    visible_vars <- vapply(groups[group_keys[seq_len(n_show)]],
                           function(g) g$var, character(1))
    max_name_len <- max(nchar(visible_vars)) + 1L

    # Two-pass print: first build all the value-count strings so we can
    # compute the max width, then print with both name and vc columns
    # padded so the [source] brackets align vertically across rows (the
    # vc padding is skipped in single-source mode, where no bracket
    # column follows). Label-only findings inline the label after the
    # value, like
    #   -99 "Refused" (3), -98 "Don't know" (3)
    # Other source types use the compact form without labels.
    vc_parts <- character(n_show)
    for (i in seq_len(n_show)) {
      g <- groups[[group_keys[i]]]
      if (g$source == "label_only") {
        vc_strs <- sprintf('%g "%s" (%d)', g$values, g$labels, g$counts)
      } else {
        vc_strs <- sprintf("%g (%d)", g$values, g$counts)
      }
      vc_parts[i] <- paste(vc_strs, collapse = ", ")
    }
    max_vc_len <- max(nchar(vc_parts))

    for (i in seq_len(n_show)) {
      g <- groups[[group_keys[i]]]
      if (single_source) {
        cat(sprintf("  %-*s  %s\n",
                    max_name_len, paste0(g$var, ":"),
                    vc_parts[i]))
      } else {
        cat(sprintf("  %-*s  %-*s  [%s]\n",
                    max_name_len, paste0(g$var, ":"),
                    max_vc_len, vc_parts[i],
                    src_display[[g$source]]))
      }
    }
    if (n_groups > max_report) {
      # When the hidden rows span multiple source types, break down the
      # counts so the reader can tell what kinds of findings are not
      # visible. When all hidden rows share one source type, the legend
      # already covers the interpretation and the simple count suffices.
      hidden_sources <- vapply(groups[group_keys[(max_report + 1):n_groups]],
                               function(g) g$source, character(1))
      hidden_udm        <- sum(hidden_sources == "udm")
      hidden_label_only <- sum(hidden_sources == "label_only")
      hidden_heur       <- sum(hidden_sources == "suspected")

      mixed <- (hidden_udm > 0) + (hidden_label_only > 0) + (hidden_heur > 0) > 1
      if (mixed) {
        cat(sprintf("  ... and %d more:\n", n_groups - max_report))
        if (hidden_udm > 0) {
          cat(sprintf("    %d with [%s]\n", hidden_udm, src_display[["udm"]]))
        }
        if (hidden_label_only > 0) {
          cat(sprintf("    %d with [%s]\n", hidden_label_only,
                      src_display[["label_only"]]))
        }
        if (hidden_heur > 0) {
          cat(sprintf("    %d with [%s]\n", hidden_heur,
                      src_display[["suspected"]]))
        }
      } else {
        cat(sprintf("  ... and %d more.\n", n_groups - max_report))
      }
    }

    cat("\n")
    if (single_source) {
      # One source type present: the legend reads as plain prose with no
      # bracket tag, since there is nothing to disambiguate.
      if (has_udm) {
        cat("These codes are declared as user-defined missing values and are already\n")
        cat("treated as NA by jstats analysis functions.\n")
        cat("Conversion to plain NA is optional --- useful if you'll use this dataset\n")
        cat("with base R or non-package functions where the numeric values may be\n")
        cat("misinterpreted as real.\n")
      } else if (has_label_only) {
        cat("These codes are not formally declared, so they are not treated as missing,\n")
        cat("but their value labels look UDM-like.\n")
        cat("Declare them as missing if they are; leave as-is if real.\n")
      } else {
        cat("These codes are not formally defined, so they are not treated as missing.\n")
        cat("Declare them as missing if they are; leave as-is if real.\n")
      }
    } else {
      if (has_udm) {
        cat("[", src_display[["udm"]], "]: already treated as NA by jstats\n", sep = "")
        cat("  analysis functions. Conversion to plain NA is optional --- useful\n")
        cat("  if you'll use this dataset with base R or non-package functions where\n")
        cat("  the numeric values may be misinterpreted as real.\n")
      }
      if (has_label_only) {
        cat("[", src_display[["label_only"]], "]: not automatically treated as NA, but\n", sep = "")
        cat("  value labels look UDM-like.\n")
        cat("  Declare them as missing if they are; leave as-is if real.\n")
      }
      if (has_heur) {
        cat("[", src_display[["suspected"]], "]: not automatically treated as NA.\n", sep = "")
        cat("  Declare them as missing if they are; leave as-is if real.\n")
      }
    }

    # Suggestion example: lead with the non-destructive declaration
    # (jdeclare_udm) rather than a destructive recode-to-NA, per the
    # message-suggestion convention (Session-113 addendum in the missing-
    # values reference). Omitted entirely on pure-UDM reports -- the load
    # narrative and the legend above already carry the jconvert guidance
    # there. Target preference: label-only first (it typically has
    # several labelled codes, the most informative example), then
    # suspected; UDM rows are never the target, and a mixed-source
    # variable's UDM codes are excluded from the example's codes= set
    # because they are already declared.
    ex_var <- NULL
    for (src in c("label_only", "suspected")) {
      idx <- which(vapply(findings, function(f) f$source == src, logical(1)))
      if (length(idx) > 0) {
        ex_var <- findings[[idx[1]]]$var
        break
      }
    }
    if (!is.null(ex_var)) {
      ex_codes <- sort(unique(vapply(findings, function(f) {
        if (f$var == ex_var && f$source != "udm") f$value else NA_real_
      }, numeric(1))))
      ex_codes <- ex_codes[!is.na(ex_codes)]
      codes_str <- if (length(ex_codes) == 1L) {
        format(ex_codes)
      } else {
        paste0("c(", paste(format(ex_codes, trim = TRUE), collapse = ", "), ")")
      }
      cat("\n# To declare one variable's codes as missing:\n")
      cat(sprintf("  %s <- jdeclare_udm(%s, %s, codes = %s)\n",
                  obj_name, obj_name, ex_var, codes_str))
    }
  }
}


# -- jsave --------------------------------------------------------------------

# -- jsave internal helpers --------------------------------------------------

#' Internal: build jsave's .dta pre-flight error message
#'
#' Produces the error message used by \code{jsave()} when SPSS-form
#' UDM declarations (\code{na_values} and/or \code{na_range}) are
#' encountered on a \code{.dta} write. The .dta format has no
#' representation for SPSS-style missing-value codes; haven would
#' otherwise drop them silently. The user is directed to convert via
#' \code{jconvert(to = "stata")} for enumerated codes, or to drop
#' via \code{jconvert(to = "baseR")} for range-based missingness
#' (which cannot be converted to Stata form). Verbosity is
#' controlled by the active \code{joutput()} level.
#'
#' @param enum_vars Character vector of variable names with
#'   enumerated missing-value codes (\code{na_values}).
#' @param range_vars Character vector of variable names with
#'   range-based missingness (\code{na_range}). A column that
#'   carries both \code{na_values} and \code{na_range} is placed
#'   in this bucket by the caller, since the range portion is the
#'   more restrictive constraint.
#' @param data_name Character. Name of the data frame argument in
#'   the user's call to \code{jsave()}, used to construct the
#'   suggested \code{jconvert()} call.
#'
#' @return Character scalar suitable for passing to \code{stop()}.
#'
#' @keywords internal
.jst_jsave_dta_error_msg <- function(enum_vars, range_vars, data_name) {

  output_level <- getOption(".jst_output_level", "standard")
  n_total      <- length(enum_vars) + length(range_vars)
  is_sg        <- (n_total == 1)
  noun         <- if (is_sg) "variable" else "variables"
  verb_carry   <- if (is_sg) "carries" else "carry"

  # --- Minimal tier -------------------------------------------------------
  if (identical(output_level, "minimal")) {
    return(paste0(
      n_total, " ", noun, " ", verb_carry,
      " SPSS-style missing values, incompatible with the .dta format. ",
      "Run ", data_name, " <- jconvert(", data_name, ", to = \"stata\") ",
      "for enumerated codes; range-based UDMs need recoding or ",
      data_name, " <- jconvert(", data_name, ", to = \"baseR\") ",
      "to drop the metadata."
    ))
  }

  # --- Standard / full tier ----------------------------------------------
  msg <- paste0(
    n_total, " ", noun, " ", verb_carry,
    " SPSS-style missing values, incompatible with the .dta format."
  )

  if (length(enum_vars) > 0) {
    msg <- paste0(
      msg, "\n\n",
      "  ", .jst_format_var_list(enum_vars), "\n",
      "Before saving to Stata format, convert with:\n",
      "  ", data_name, " <- jconvert(", data_name, ", to = \"stata\")"
    )
  }

  if (length(range_vars) > 0) {
    msg <- paste0(
      msg, "\n\n",
      "  ", .jst_format_var_list(range_vars), "\n",
      "Range-based missingness cannot be converted to Stata-style. ",
      "Either re-code the range to enumerated codes (then run jconvert), ",
      "or drop the metadata with:\n",
      "  ", data_name, " <- jconvert(", data_name, ", to = \"baseR\")"
    )
  }

  msg
}

#' Internal: build jsave's .xpt pre-flight error message
#'
#' Produces the error message used by \code{jsave()} when missing-value
#' forms the .xpt format cannot represent are encountered on a
#' \code{.xpt} write: tagged-NA values (haven would otherwise emit a
#' low-level error, \dQuote{Failed to insert value...}, and leave a
#' partial file on disk) and/or SPSS-form UDM declarations (haven would
#' otherwise strip the metadata silently, mirroring the
#' .dta-with-SPSS-UDMs failure mode). The user is directed to drop via
#' \code{jconvert(to = "baseR")}, or to preserve the codes by saving as
#' \code{.dta} (tagged NAs; SAS PROC IMPORT can read it) or \code{.sav}
#' (SPSS-form declarations). Verbosity is
#' controlled by the active \code{joutput()} level.
#'
#' @param vars Character vector of variable names containing
#'   tagged NAs. May be empty when only SPSS-form columns fired.
#' @param data_name Character. Name of the data frame argument in
#'   the user's call to \code{jsave()}, used to construct the
#'   suggested \code{jconvert()} call.
#' @param spss_vars Character vector of variable names carrying
#'   SPSS-form UDM declarations (\code{na_values} and/or
#'   \code{na_range}). The .xpt interchange format cannot represent
#'   these either; \code{haven::write_xpt} would strip them
#'   silently. Default \code{character(0)} keeps the pre-extension
#'   call signature working unchanged.
#'
#' @return Character scalar suitable for passing to \code{stop()}.
#'
#' @keywords internal
.jst_jsave_xpt_error_msg <- function(vars, data_name,
                                     spss_vars = character(0)) {

  output_level <- getOption(".jst_output_level", "standard")
  all_vars     <- unique(c(vars, spss_vars))
  n            <- length(all_vars)
  is_sg        <- (n == 1)
  noun         <- if (is_sg) "variable" else "variables"
  verb_contain <- if (is_sg) "contains" else "contain"

  has_tagged <- length(vars) > 0
  has_spss   <- length(spss_vars) > 0

  # The preserve-path advice depends on which missing-value form is
  # present: tagged NAs round-trip via .dta, SPSS-form declarations via
  # .sav, and a frame carrying both forms has no single ReadStat target
  # until the forms are unified with jconvert(). The generic
  # "missing-value codes" wording is the locked Session-36 carve-out for
  # .xpt messages.
  if (identical(output_level, "minimal")) {
    tail <- if (has_tagged && has_spss) {
      paste0("to drop them, or convert them to one form with jconvert() ",
             "and save as SPSS format (.sav) or Stata format (.dta) ",
             "to preserve them.")
    } else if (has_spss) {
      "to drop them, or save as SPSS format (.sav) to preserve them."
    } else {
      "to drop them, or save as Stata format (.dta) to preserve them."
    }
    return(paste0(
      n, " ", noun, " ", verb_contain,
      " missing-value codes, incompatible with the .xpt format. ",
      "Run ", data_name, " <- jconvert(", data_name, ", to = \"baseR\") ",
      tail
    ))
  }

  # --- Standard / full tier ----------------------------------------------
  preserve_advice <- if (has_tagged && has_spss) {
    paste0("To preserve these codes, convert them to one form with ",
           "jconvert() first, then save as SPSS format (.sav) or ",
           "Stata format (.dta) instead.")
  } else if (has_spss) {
    "To preserve these codes, save as SPSS format (.sav) instead."
  } else {
    paste0("To preserve these codes, save as Stata format (.dta) instead, ",
           "which SAS PROC IMPORT can read.")
  }

  paste0(
    n, " ", noun, " ", verb_contain,
    " missing-value codes, incompatible with the .xpt format:\n",
    "  ", .jst_format_var_list(all_vars), "\n\n",
    "To save as .xpt, drop these by running:\n",
    "  ", data_name, " <- jconvert(", data_name, ", to = \"baseR\")\n\n",
    preserve_advice
  )
}

#' Internal: build jsave's .sav pre-flight error message
#'
#' Produces the error message used by \code{jsave()} when tagged-NA
#' missing values are encountered on a \code{.sav} write. The .sav
#' format has no representation for tagged-NA markers; haven would
#' otherwise silently drop the marker distinctions (every \code{.a},
#' \code{.b}, \code{.c}, ... cell becomes plain \code{NA} indistinguishable
#' from any other). The user is directed to convert in advance via
#' \code{jconvert(to = "spss")}, which preserves the distinctions as
#' numeric codes that \code{.sav} can carry natively.
#'
#' The opening phrase is picked by inspecting the tag case of the
#' flagged columns: \dQuote{Stata-style missing values} when all tags
#' are lowercase (\code{.a}, \code{.b}, ...), \dQuote{SAS-style missing
#' values} when all tags are uppercase (\code{.A}, \code{.B}, ...), or
#' \dQuote{Stata-style or SAS-style missing values} when both cases
#' appear. Verbosity is controlled by the active \code{joutput()} level.
#'
#' @param vars Character vector of variable names containing tagged-NA
#'   missing values (Stata-style and/or SAS-style).
#' @param data The data frame being saved; used to inspect tag case
#'   on each flagged variable so the message names the right style.
#' @param data_name Character. Name of the data frame argument in
#'   the user's call to \code{jsave()}, used to construct the
#'   suggested \code{jconvert()} call.
#'
#' @return Character scalar suitable for passing to \code{stop()}.
#'
#' @keywords internal
.jst_jsave_sav_error_msg <- function(vars, data, data_name) {

  output_level <- getOption(".jst_output_level", "standard")
  n            <- length(vars)
  is_sg        <- (n == 1)
  noun         <- if (is_sg) "variable" else "variables"
  verb_contain <- if (is_sg) "contains" else "contain"

  # Inspect tag case across the flagged columns to pick the right
  # style phrase. Stata convention uses lowercase letters (.a, .b, ...);
  # SAS convention uses uppercase (.A, .B, ...); both can in principle
  # coexist either across columns or within a single column.
  has_lower <- FALSE
  has_upper <- FALSE
  for (v in vars) {
    col <- data[[v]]
    if (is.double(col)) {
      tags <- unique(haven::na_tag(col))
      tags <- tags[!is.na(tags)]
      if (any(grepl("[a-z]", tags))) has_lower <- TRUE
      if (any(grepl("[A-Z]", tags))) has_upper <- TRUE
    }
  }
  style_phrase <- if (has_lower && has_upper) {
    "Stata-style or SAS-style missing values"
  } else if (has_upper) {
    "SAS-style missing values"
  } else {
    "Stata-style missing values"
  }

  # --- Minimal tier -------------------------------------------------------
  if (identical(output_level, "minimal")) {
    return(paste0(
      n, " ", noun, " ", verb_contain, " ",
      style_phrase, ", incompatible with the .sav format. ",
      "Before saving, convert with ",
      data_name, " <- jconvert(", data_name, ", to = \"spss\")."
    ))
  }

  # --- Standard / full tier ----------------------------------------------
  paste0(
    n, " ", noun, " ", verb_contain, " ",
    style_phrase, ", incompatible with the .sav format:\n",
    "  ", .jst_format_var_list(vars), "\n\n",
    "Before saving to SPSS format, convert to SPSS-style missing values ",
    "with:\n",
    "  ", data_name, " <- jconvert(", data_name, ", to = \"spss\")"
  )
}


#' Internal: build jsave's error message for unsupported column types
#'
#' The statistical interchange formats (.sav, .dta, .xpt) cannot store
#' complex, list, raw, or POSIXlt columns; the underlying writers abort
#' mid-write with a low-level message that does not name the offending
#' column (e.g. "Columns of type complex not supported yet", or "...type
#' list..." for a POSIXlt column, which is list-backed). This helper
#' produces one clean package-level error that names the column(s) and
#' their type(s) and gives the right remedy for each: complex/list/raw have
#' no sensible conversion and are dropped, while POSIXlt converts faithfully
#' to POSIXct (the same instant, which the formats can store).
#'
#' @param vars Character vector of offending column names.
#' @param types Character vector of the columns' types, parallel to
#'   \code{vars} ("complex", "list", "raw", or "POSIXlt").
#' @param ext The target extension ("sav", "dta", or "xpt").
#' @param data_name The data frame's name, used in the suggested fix code.
#'
#' @return Character scalar suitable for \code{stop(call. = FALSE)}.
#' @keywords internal
.jst_jsave_unsupported_type_error_msg <- function(vars, types, ext, data_name) {

  output_level <- getOption(".jst_output_level", "standard")
  n     <- length(vars)
  is_sg <- (n == 1)
  noun  <- if (is_sg) "column" else "columns"
  verb  <- if (is_sg) "is"     else "are"

  fmt <- switch(ext,
                sav = "SPSS format (.sav)",
                dta = "Stata format (.dta)",
                xpt = "SAS interchange format (.xpt)",
                paste0(".", ext, " format"))

  # Two remedy classes. drop: complex/list/raw have no representation and
  # no sensible conversion. convert: POSIXlt is list-backed (so the writers
  # reject it) but converts faithfully to POSIXct, which the formats store.
  drop_vars    <- vars[types %in% c("complex", "list", "raw")]
  convert_vars <- vars[types == "POSIXlt"]

  drop_code <- if (length(drop_vars) > 0) {
    paste0(data_name, "[c(",
           paste0("\"", drop_vars, "\"", collapse = ", "),
           ")] <- NULL")
  } else NULL
  convert_lines <- if (length(convert_vars) > 0) {
    paste0("  ", data_name, "$", convert_vars, " <- as.POSIXct(",
           data_name, "$", convert_vars, ")", collapse = "\n")
  } else NULL

  # --- Minimal tier -------------------------------------------------------
  if (identical(output_level, "minimal")) {
    parts <- character(0)
    if (!is.null(drop_code))     parts <- c(parts, paste0("drop ", drop_code))
    if (!is.null(convert_lines)) parts <- c(parts, "convert POSIXlt with as.POSIXct()")
    return(paste0(
      n, " ", noun, " ", verb, " of a type that ", fmt,
      " cannot store. ", paste(parts, collapse = "; "), "."
    ))
  }

  # --- Standard / full tier ----------------------------------------------
  var_lines <- paste0("  ", vars, " (", types, ")", collapse = "\n")
  out <- paste0(
    n, " ", noun, " ", verb, " of a type that ", fmt, " cannot store:\n",
    var_lines, "\n"
  )
  if (!is.null(drop_code)) {
    out <- paste0(
      out,
      "\ncomplex/list/raw columns have no ", fmt, " representation and no ",
      "sensible automatic conversion. Drop ",
      if (length(drop_vars) == 1) "it" else "them", " before saving with:\n",
      "  ", drop_code, "\n"
    )
  }
  if (!is.null(convert_lines)) {
    out <- paste0(
      out,
      "\nPOSIXlt columns are list-backed; convert to POSIXct (the same ",
      "instant, which ", fmt, " can store) before saving with:\n",
      convert_lines, "\n"
    )
  }
  sub("\n$", "", out)
}

#' Internal: assemble jsave's combined pre-flight error
#'
#' jsave runs two independent pre-flight checks for the ReadStat formats
#' (.sav/.dta/.xpt): one for column types the format cannot store, one for
#' missing-value codes it cannot represent. When more than one fires on a
#' single save, this helper frames the individual messages (each already
#' built and tier-formatted by its own \code{.jst_jsave_*_error_msg()} helper)
#' into one numbered error, so the user fixes everything and re-runs once
#' rather than discovering the second problem only after fixing the first. A
#' single firing is returned unchanged, so single-issue saves are byte-for-
#' byte identical to the pre-accumulation behavior.
#'
#' @param sections List of pre-built section messages, one per fired check.
#' @param data_name Character. The data frame's name, for the header.
#' @param ext Lowercase target extension ("sav", "dta", "xpt").
#' @return Character scalar suitable for \code{stop(call. = FALSE)}.
#' @keywords internal
.jst_jsave_combined_error_msg <- function(sections, data_name, ext) {
  if (length(sections) == 1L) return(sections[[1L]])

  output_level <- getOption(".jst_output_level", "standard")

  # Minimal tier: join the compact one-line section messages, no frame.
  if (identical(output_level, "minimal")) {
    return(paste(unlist(sections), collapse = " "))
  }

  # Standard / full tier: numbered sections under a unified header.
  fmt <- switch(ext,
                sav = "SPSS format (.sav)",
                dta = "Stata format (.dta)",
                xpt = "SAS interchange format (.xpt)",
                paste0(".", ext, " format"))
  numbered <- vapply(seq_along(sections),
                     function(i) paste0("[", i, "] ", sections[[i]]),
                     character(1))
  paste0(
    data_name, " cannot be saved to ", fmt, " yet -- ",
    length(sections), " things to fix:\n\n",
    paste(numbered, collapse = "\n\n"), "\n\n",
    "Fix the above, then run jsave() again."
  )
}
#' Internal: build jsave's case-correction note for .dta export
#'
#' Produces the informational note emitted by \code{jsave()} when
#' SAS-style missing values in the data frame have been converted
#' to Stata-style for the .dta format. haven's \code{write_dta()}
#' errors on SAS-style markers, so the conversion is necessary for
#' the write to succeed; the note simply tells the user it
#' happened. Suppressed at \code{joutput("minimal")} and
#' \code{joutput("standard")}; shown at \code{joutput("full")} only.
#'
#' @param n_changed Integer. Number of columns whose SAS-style
#'   missing values were converted.
#'
#' @return Character scalar, or \code{NULL} when the active
#'   \code{joutput()} level suppresses the note or when no
#'   conversion happened.
#'
#' @keywords internal
.jst_jsave_dta_case_correction_note <- function(n_changed) {
  if (!identical(getOption(".jst_output_level", "standard"), "full")) {
    return(NULL)
  }
  if (n_changed <= 0) return(NULL)

  is_sg <- (n_changed == 1)
  noun  <- if (is_sg) "variable" else "variables"

  paste0(
    "Note: ", n_changed, " ", noun, " had SAS-style missing values ",
    "(.A, .B, ...) converted to Stata-style missing values ",
    "(.a, .b, ...) for .dta files."
  )
}

#' Internal: convert SAS-style missing values to Stata-style in a data frame
#'
#' Walks the columns of \code{data}, converting any SAS-style missing
#' values (\code{.A}, \code{.B}, ..., stored as
#' \code{haven::tagged_na("A")} etc.) to their Stata-style equivalents
#' (\code{.a}, \code{.b}, ...) in both cell values and the
#' \code{val_labels} attribute. haven's \code{write_dta()} errors on
#' SAS-style markers in either location (Stata's format is
#' lowercase-only), so this conversion runs unconditionally in
#' \code{jsave()}'s .dta branch before \code{write_dta} is called.
#'
#' A column is counted in \code{n_changed} when any SAS-style marker
#' was converted -- in cells, in \code{val_labels}, or both. Columns
#' already in Stata-style form pass through unchanged and are not
#' counted. Non-double columns are skipped (Stata-style missing
#' values exist only on doubles).
#'
#' @param data A data frame.
#'
#' @return List with two elements: \code{data} (the data frame with
#'   SAS-style markers converted to Stata-style) and \code{n_changed}
#'   (integer count of columns touched).
#'
#' @keywords internal
.jst_lowercase_tagged_na_df <- function(data) {

  n_changed <- 0L

  for (vname in names(data)) {
    col <- data[[vname]]
    if (!is.double(col)) next

    changed <- FALSE

    # Cell values: locate uppercase tags, replace with lowercase.
    tags <- haven::na_tag(col)
    upper_cells <- which(!is.na(tags) & tags %in% LETTERS)
    if (length(upper_cells) > 0) {
      for (i in upper_cells) col[i] <- haven::tagged_na(tolower(tags[i]))
      changed <- TRUE
    }

    # val_labels attribute: haven::write_dta() validates tagged NAs
    # in labels too, so labels containing uppercase tags also need
    # conversion. Label names ("Refused", "Skipped", ...) are
    # preserved; only the value (the tagged NA) is rewritten.
    if (haven::is.labelled(col)) {
      vl <- labelled::val_labels(col)
      if (!is.null(vl) && length(vl) > 0) {
        lab_tags <- haven::na_tag(vl)
        upper_labs <- which(!is.na(lab_tags) & lab_tags %in% LETTERS)
        if (length(upper_labs) > 0) {
          for (i in upper_labs) vl[i] <- haven::tagged_na(tolower(lab_tags[i]))
          labelled::val_labels(col) <- vl
          changed <- TRUE
        }
      }
    }

    if (changed) {
      data[[vname]] <- col
      n_changed   <- n_changed + 1L
    }
  }

  list(data = data, n_changed = n_changed)
}

#' Internal: build the label / missing-value loss note for Excel and CSV saves
#'
#' @description
#' Excel and CSV cannot store variable labels, value labels, or
#' missing-value declarations. jsave emits a note after a successful write
#' to these formats describing what was (or, under
#' \code{preserve.udm = FALSE}, would have been) lost. The wording depends
#' on which missing-value form the frame carried and on whether
#' \code{preserve.udm = FALSE} blanked the codes.
#'
#' @details
#' Branching (SPSS-style codes write as literal numbers, while Stata-style
#' tagged NAs write as blank cells):
#' \itemize{
#'   \item \code{preserve.udm = FALSE} and SPSS-style codes were blanked:
#'     a confirmation giving the count of blanked cells.
#'   \item both forms present (\code{preserve.udm = TRUE}): a generic note
#'     that names neither platform, plus the \code{preserve.udm = FALSE}
#'     suggestion.
#'   \item SPSS-style only: the literal-numbers warning plus the suggestion.
#'   \item Stata-style only: a brief note that the tags write as blank cells
#'     and the distinction between them is not preserved.
#'   \item neither: a plain labels-only note.
#' }
#' The note is a loss-of-fidelity warning per the locked jsave design; it is
#' not gated to the joutput verbosity tiers.
#'
#' @param ext Lowercase target extension, \code{"xlsx"} or \code{"csv"}.
#' @param spss_vars Character vector of SPSS-form UDM variable names, as
#'   detected before any collapse.
#' @param stata_vars Character vector of Stata-form tagged-NA variable
#'   names, as detected before any collapse.
#' @param preserve.udm Logical, the value passed to jsave.
#' @param n_blanked Integer count of SPSS-style code cells blanked when
#'   \code{preserve.udm = FALSE}; zero otherwise.
#'
#' @return A single message string, or \code{NULL} if no note applies.
#'
#' @keywords internal
.jst_jsave_label_loss_note <- function(ext, spss_vars, stata_vars,
                                       preserve.udm, n_blanked) {
  fmt <- if (identical(ext, "xlsx")) {
    "Excel format (.xlsx)"
  } else {
    "CSV format (.csv)"
  }
  has_spss  <- length(spss_vars)  > 0
  has_stata <- length(stata_vars) > 0

  # preserve.udm = FALSE that actually blanked SPSS-style codes -> confirm.
  if (!preserve.udm && has_spss && n_blanked > 0) {
    return(paste0(
      "Note: ", fmt, " does not store variable labels or value labels. ",
      n_blanked, " missing-value codes were blanked to empty cells ",
      "(preserve.udm = FALSE)."))
  }

  # Both forms present: one generic note, no platform names.
  if (has_spss && has_stata) {
    return(paste0(
      "Note: ", fmt, " does not store variable labels, value labels, or ",
      "missing-value metadata.\n",
      "Declared missing-value codes lose their missing status, which may ",
      "result in them being written as ordinary numbers.\n",
      "Alternatively, use jsave(..., preserve.udm = FALSE) to blank them to ",
      "empty cells instead."))
  }

  # SPSS-style only: literal-numbers warning + suggestion.
  if (has_spss) {
    return(paste0(
      "Note: ", fmt, " does not store variable labels, value labels, or ",
      "missing-value metadata.\n",
      "Any SPSS-style missing-value codes (e.g. -99) are written as literal ",
      "numbers and will read back as ordinary values.\n",
      "Alternatively, use jsave(..., preserve.udm = FALSE) to blank them to ",
      "empty cells instead."))
  }

  # Stata-style only: brief flatten note.
  if (has_stata) {
    return(paste0(
      "Note: ", fmt, " does not store variable labels, value labels, or ",
      "missing-value metadata. Stata-style missing values (.a, .b, ...) are ",
      "written as blank cells; the distinction between them is not preserved."))
  }

  # Neither: labels-only.
  paste0("Note: ", fmt, " does not store variable labels or value labels.")
}


#' Save a data frame to a file
#'
#' @description
#' \code{jsave()} writes a data frame to a file. Supports SPSS (\code{.sav}),
#' Stata (\code{.dta}), SAS interchange (\code{.xpt}), Excel (\code{.xlsx}),
#' CSV (\code{.csv}), and R's native \code{.rds} format.
#'
#' The file format is determined entirely by the file extension you
#' provide --- for example, \code{"mydata.sav"} saves as SPSS,
#' \code{"mydata.dta"} saves as Stata, and \code{"mydata.xlsx"} saves
#' as Excel. Changing the extension changes the format.
#'
#' By default, \code{jsave()} writes bare-filename saves to the working
#' directory, matching base R's \code{saveRDS()} and \code{write.csv()}.
#' To save into a subfolder, set \code{\link{joptions}(data.dir = "...")}
#' once per session (or in \code{.Rprofile}). Filenames containing a
#' directory separator (\code{/}) bypass this setting and are taken
#' literally.
#'
#' If the \code{data} argument is omitted, the default data frame set by
#' \code{juse()} is used.
#'
#' @param data A data frame (unquoted). If omitted, uses the default set by
#'   \code{juse()}.
#' @param file Character string. The filename with extension (e.g.
#'   \code{"mydata.sav"}) or a full file path. Use forward slashes in
#'   file paths.
#' @param overwrite Logical. If \code{TRUE}, overwrites an existing file
#'   without prompting. If \code{FALSE} (default), prompts for confirmation
#'   in interactive sessions. In non-interactive sessions, stops with an
#'   error.
#' @param preserve.udm Logical. If \code{TRUE} (the default), missing-value
#'   declarations are written as they stand; formats that cannot store them
#'   (notably Excel and CSV) drop the metadata, and SPSS-style codes such as
#'   -99 then read back as ordinary numbers. If \code{FALSE}, those codes are
#'   blanked to plain NA before writing, so they become empty cells. Mirrors
#'   the \code{preserve.udm} argument of \code{\link{jload}}. The pre-flight
#'   checks for the .sav, .dta, and .xpt formats run before this step, so a
#'   missing-value form a target format cannot represent is still reported
#'   and blocked rather than silently dropped.
#'
#' @return Invisibly returns \code{NULL}. Called for its side effect of
#'   writing a file to disk.
#'
#' @details
#' \strong{File paths:}
#' Use forward slashes (\code{/}) in file paths. If you copy a path from
#' Windows File Explorer, replace the backslashes with forward slashes.
#' R does not accept single backslashes in file paths.
#'
#' \strong{File location:}
#' \itemize{
#'   \item If the path contains a directory separator, the file is saved
#'     to that exact location.
#'   \item If the path is a bare filename and \code{joptions("data.dir")}
#'     is set, the file is saved to that folder (auto-created if it
#'     doesn't yet exist).
#'   \item If the path is a bare filename and \code{joptions("data.dir")}
#'     is unset (the default), the file is saved to the working
#'     directory.
#' }
#'
#' \strong{Format notes:}
#' \itemize{
#'   \item SPSS (\code{.sav}) and Stata (\code{.dta}) preserve variable
#'     labels and value labels.
#'   \item Excel (\code{.xlsx}) and CSV (\code{.csv}) do not preserve
#'     variable or value labels.
#'   \item R native (\code{.rds}) preserves the data frame exactly as it
#'     exists in R, including all attributes.
#'   \item Stata files are written as version 14 format.
#'   \item Legacy Excel format (\code{.xls}) is not supported for saving.
#'     Use \code{.xlsx} instead.
#' }
#'
#' @examples
#' # A runnable save into R's session temporary folder
#' jsave(community, file.path(tempdir(), "community.sav"), overwrite = TRUE)
#'
#' \dontrun{
#' # The file extension determines the format ---
#' # the same data frame can be saved in any supported format
#' jsave(community, "community.sav")         # SPSS
#' jsave(community, "community.xlsx")        # Excel
#' jsave(community, "community.csv")         # CSV
#' jsave(community, "community.rds")         # R native
#'
#' # Stata and SAS formats cannot carry community's SPSS-form missing-value
#' # declarations -- convert first (jsave() pre-flights this and says so)
#' jsave(jconvert(community, to = "stata"), "community.dta")   # Stata
#' jsave(jconvert(community, to = "baseR"), "community.xpt")   # SAS interchange
#'
#' # Using juse() default
#' jsave(, "community.sav")
#'
#' # Full file path
#' jsave(community, "C:/Output/community.sav")
#' }
#'
#' @seealso \code{\link{jstats}} for the package overview,
#'   workflow conventions, and complete function listing.
#'
#' @export
jsave <- function(data, file, overwrite = FALSE, preserve.udm = TRUE) {

  # --- Pre-check: first argument must be a data frame -----------------------
  # The shared resolver (.jst_resolve_first_arg) frames a non-evaluating
  # bare symbol or a non-data-frame value as a possible variable-name
  # attempt -- appropriate for data-first analytic functions like
  # jdesc/jfreq/jcorr where bare symbols ARE variable names under the
  # juse default. jsave has no variable-name semantics (its first
  # argument must be a data frame), so we intercept the problematic
  # cases here and produce jsave-tailored errors before the shared
  # resolver runs.
  #
  # Cases intercepted:
  #   1. Bare symbol that doesn't exist (e.g. jsave(BadName, "x.rds"))
  #   2. Expression that fails to evaluate
  #   3. Expression that evaluates to NULL (e.g. jsave(SampleData$BadCol,
  #      "x.rds") -- $-access on a missing column returns NULL rather
  #      than erroring)
  #   4. Value that is neither a data frame nor a string (e.g.
  #      jsave(42, "x.rds"), jsave(some_list, "x.rds"))
  #
  # Strings are deliberately allowed through: when juse() is set, a
  # string in the first slot is the valid "data omitted, route string
  # to file slot" idiom handled by the resolver's symbol_with_default
  # mode (e.g. jsave("test.rds") after juse(MyData)). A literal NULL in
  # the first slot is also passed through, since the resolver has a
  # dedicated message for that case.
  data_sub <- substitute(data)
  if (!missing(data) && !is.null(data_sub)) {

    # Case 1: bare symbol that doesn't exist
    if (is.symbol(data_sub) &&
        !exists(as.character(data_sub), envir = parent.frame())) {
      .jst_stop("'", as.character(data_sub), "' not found. ",
           "Provide a data frame, e.g. jsave(MyData, \"mydata.sav\")")
    }

    # Cases 2-4: evaluate the first argument and inspect the value
    eval_result <- tryCatch(
      list(value = eval(data_sub, envir = parent.frame()), failed = FALSE),
      error = function(e) list(value = NULL, failed = TRUE)
    )

    if (eval_result$failed) {
      data_str <- paste(deparse(data_sub), collapse = "")
      .jst_stop("'", data_str, "' could not be evaluated. ",
           "Provide a data frame, e.g. jsave(MyData, \"mydata.sav\")")
    }

    val <- eval_result$value
    if (is.null(val)) {
      data_str <- paste(deparse(data_sub), collapse = "")
      .jst_stop("'", data_str, "' is NULL. ",
           "Provide a data frame, e.g. jsave(MyData, \"mydata.sav\")")
    }
    if (!is.data.frame(val) && !is.character(val)) {
      data_str   <- paste(deparse(data_sub), collapse = "")
      class_desc <- paste(class(val), collapse = "/")
      .jst_stop("'", data_str, "' is a ", class_desc, ", not a data frame. ",
           "Provide a data frame, e.g. jsave(MyData, \"mydata.sav\")")
    }
  }

  # --- Pre-check: unquoted filename -----------------------------------------
  # A bare filename like jsave(community, community.rds) parses
  # community.rds as a symbol, so forcing the file argument later yields
  # the cryptic base-R message "object 'community.rds' not found". Detect
  # the forgot-the-quotes case up front and give a jsave-tailored message,
  # mirroring the
  # data-argument interception above. Only fires when the bare symbol does
  # not resolve to any existing object (so a real variable passed by name is
  # left for the downstream "provide a filename" check) and deparses to a
  # name ending in a supported extension (so unrelated undefined symbols are
  # not misreported as missing quotes).
  if (!missing(file)) {
    file_sub <- substitute(file)
    if (is.symbol(file_sub)) {
      file_str <- as.character(file_sub)
      if (!exists(file_str, envir = parent.frame()) &&
          tolower(tools::file_ext(file_str)) %in%
            c("sav", "dta", "csv", "rds", "xpt", "xlsx", "xls")) {
        ex_data <- if (!missing(data) && is.symbol(data_sub)) {
          as.character(data_sub)
        } else {
          "MyData"
        }
        .jst_stop("'", file_str, "' is not quoted. Filenames must be in quotes, ",
             "e.g. jsave(", ex_data, ", \"", file_str, "\")")
      }
    }
  }

  # --- Resolve first argument -----------------------------------------------
  arg1 <- .jst_resolve_first_arg(
    data_sub      = data_sub,
    data_missing  = missing(data),
    fn_name       = "jsave",
    envir         = parent.frame(),
    accept_vector = FALSE
  )

  data      <- arg1$data
  data_name <- arg1$name

  # If data was omitted (e.g. jsave("file.rds")), route the captured first
  # argument into the file slot.
  if (arg1$mode == "symbol_with_default") {
    if (!missing(file)) {
      stop("jsave(): when the data argument is omitted, all subsequent arguments must be named. ",
           "Use jsave(file = \"yourfile.ext\")",
           call. = FALSE)
    }
    file <- eval(arg1$first_arg_sub, envir = parent.frame())
  }

  # --- Validate data is a data frame -----------------------------------------
  if (!is.data.frame(data)) {
    .jst_stop(
      "Only data frames can be saved. '", data_name, "' is ",
      paste0("a ", paste(class(data), collapse = "/"), ", not a data frame.")
    )
  }

  # --- Validate file argument ------------------------------------------------
  if (missing(file) || !is.character(file) || length(file) != 1 ||
      nchar(trimws(file)) == 0) {
    .jst_stop(
      "Provide a filename with extension, e.g. jsave(MyData, \"mydata.sav\")\n",
      "Supported formats:\n",
      "  .sav       SPSS\n",
      "  .dta       Stata\n",
      "  .xpt       SAS interchange\n",
      "  .xlsx      Excel\n",
      "  .csv       Comma-separated values\n",
      "  .rds       R native"
    )
  }

  # --- Check extension -------------------------------------------------------
  ext <- tolower(tools::file_ext(file))

  if (ext == "") {
    # Default to .rds when no extension supplied. Matches base R's
    # saveRDS() convention; the format is appended to the filename so
    # the on-disk artefact carries the extension that jload() expects.
    file <- paste0(file, ".rds")
    ext  <- "rds"
  }

  supported_ext <- c("sav", "dta", "csv", "rds", "xpt", "xlsx")
  if (!ext %in% supported_ext) {
    xls_msg <- ""
    if (ext == "xls") {
      xls_msg <- paste0(
        "\n\nThe legacy .xls format is not supported for saving. ",
        "Use .xlsx instead:\n",
        "  jsave(", data_name, ", \"",
        tools::file_path_sans_ext(file), ".xlsx\")")
    }
    .jst_stop(
      "Unsupported file extension '.", ext, "'. Supported formats for saving:\n",
      "  .sav       SPSS\n",
      "  .dta       Stata\n",
      "  .xpt       SAS interchange\n",
      "  .xlsx      Excel\n",
      "  .csv       Comma-separated values\n",
      "  .rds       R native",
      xls_msg
    )
  }

  # --- Resolve output path ---------------------------------------------------
  has_dir <- grepl("[/\\\\]", file)  # forward slash or Windows-native backslash

  if (has_dir) {
    out_path <- file
    # Ensure directory exists
    out_dir <- dirname(out_path)
    if (!dir.exists(out_dir)) {
      .jst_stop("Directory does not exist: ", .jst_norm_path(out_dir))
    }
  } else {
    # Bare filename — resolve via data.dir.
    data_dir <- getOption(".jst_options_data_dir",
                          .jst_options_defaults$data.dir)

    if (is.null(data_dir)) {
      # data.dir unset; write to the working directory.
      out_path <- file
    } else {
      # Explicit data.dir — write to that folder, creating it if needed.
      if (!dir.exists(data_dir)) {
        dir.create(data_dir, recursive = TRUE)
        message("Created '", data_dir, "' folder in working directory.")
      }
      out_path <- file.path(data_dir, file)
    }
  }

  # --- Overwrite check -------------------------------------------------------
  if (file.exists(out_path) && !overwrite) {
    if (interactive()) {
      response <- readline(
        paste0("File '", .jst_norm_path(out_path), "' already exists. Overwrite? (y/n): ")
      )
      if (!tolower(trimws(response)) %in% c("y", "yes")) {
        message("Save cancelled.")
        return(invisible(NULL))
      }
    } else {
      .jst_stop(
        "File '", .jst_norm_path(out_path), "' already exists. ",
        "Use overwrite = TRUE to replace it."
      )
    }
  }

  # --- Pre-flight for the ReadStat formats (.sav / .dta / .xpt) --------------
  # Two independent classes of problem can block a write to these formats:
  #   (1) column types the format cannot store -- complex, list, and raw have
  #       no representation; POSIXlt is list-backed and the writers reject it
  #       (its remedy is conversion to POSIXct, not a drop). Otherwise haven's
  #       writers abort mid-write with a low-level message that does not name
  #       the offending column.
  #   (2) missing-value codes the format cannot represent -- tagged NAs for
  #       .sav/.xpt, SPSS-style UDMs for .dta/.xpt. haven would silently drop
  #       these (or, for tagged NAs on .xpt, error mid-write and leave a
  #       partial file).
  # Both are detected up front and reported together, so the user fixes
  # everything in one pass and re-runs once instead of discovering the second
  # class only after fixing the first. Each class's message is built (and
  # tier-formatted) by its own helper; .jst_jsave_combined_error_msg() frames
  # them when more than one fires and returns a lone firing unchanged.
  # .csv stringifies and .xlsx/.rds carry every type, so none of those is gated.
  if (ext %in% c("sav", "dta", "xpt")) {
    sections <- list()

    # (1) Unsupported column types -- shared across the three formats.
    type_of <- vapply(data, function(col) {
      if (is.complex(col)) {
        "complex"
      } else if (is.raw(col)) {
        "raw"
      } else if (inherits(col, "POSIXlt")) {
        "POSIXlt"
      } else if (is.list(col) && !inherits(col, "POSIXt") &&
                 !is.data.frame(col)) {
        "list"
      } else {
        NA_character_
      }
    }, character(1))
    unsup_vars <- !is.na(type_of)
    if (any(unsup_vars)) {
      sections[[length(sections) + 1L]] <- .jst_jsave_unsupported_type_error_msg(
        names(data)[unsup_vars], unname(type_of[unsup_vars]), ext, data_name)
    }

    # (2) Missing-value incompatibilities -- format-specific.
    if (ext == "sav") {
      tagged_vars <- .jst_has_tagged_na(data)
      if (length(tagged_vars) > 0) {
        sections[[length(sections) + 1L]] <-
          .jst_jsave_sav_error_msg(tagged_vars, data, data_name)
      }
    } else if (ext == "dta") {
      spss_vars <- .jst_has_spss_udm(data)
      if (length(spss_vars) > 0) {
        # Bucket by missing-value form. A column carrying both na_values and
        # na_range goes in the range bucket -- the range portion blocks
        # conversion to Stata form, so the stricter remediation applies.
        enum_vars  <- character(0)
        range_vars <- character(0)
        for (vname in spss_vars) {
          info <- .jst_missing_info(data[[vname]])
          if (!is.null(info$na_range)) {
            range_vars <- c(range_vars, vname)
          } else {
            enum_vars  <- c(enum_vars, vname)
          }
        }
        sections[[length(sections) + 1L]] <-
          .jst_jsave_dta_error_msg(enum_vars, range_vars, data_name)
      }
    } else if (ext == "xpt") {
      # Both missing-value forms are unrepresentable in .xpt: tagged NAs
      # (haven errors mid-write and leaves a partial file) and SPSS-style
      # declarations (haven::write_xpt strips them silently). One message
      # covers whichever forms are present.
      tagged_vars <- .jst_has_tagged_na(data)
      spss_vars   <- .jst_has_spss_udm(data)
      if (length(tagged_vars) > 0 || length(spss_vars) > 0) {
        sections[[length(sections) + 1L]] <-
          .jst_jsave_xpt_error_msg(tagged_vars, data_name, spss_vars)
      }
    }

    # Report all blocking issues at once (single message when only one fired).
    if (length(sections) > 0) {
      .jst_stop(.jst_jsave_combined_error_msg(sections, data_name, ext))
    }

    # .dta only, once we know there are no blocking issues: lowercase any
    # SAS-style tagged NAs (.A, .B, ...) to Stata convention (.a, .b, ...),
    # which haven::write_dta() requires. Transparent fix with a note (full
    # tier only), per Decision 6B.
    if (ext == "dta") {
      conv <- .jst_lowercase_tagged_na_df(data)
      data <- conv$data
      if (conv$n_changed > 0) {
        note <- .jst_jsave_dta_case_correction_note(conv$n_changed)
        if (!is.null(note)) message(note)
      }
    }
  }

  # --- Detect UDM forms and apply preserve.udm (collapse) --------------------
  # Detection is captured here, on the frame as it stands after the ReadStat
  # pre-flight, so the post-write note (Excel/CSV) can describe what was
  # present. Option Y: the collapse runs AFTER the pre-flight, so a
  # missing-value form a target format cannot represent is blocked above
  # rather than silently dropped here. preserve.udm = FALSE then bites on the
  # ungated formats (Excel, CSV, rds) and on same-platform codes that passed
  # the pre-flight; on Excel/CSV it converts the post-write note from a
  # warning to a confirmation. The .jst_handle_udms() call is shared with
  # jload's preserve.udm path, so collapse semantics stay identical both ways.
  spss_udm_vars  <- character(0)
  stata_udm_vars <- character(0)
  n_udm_blanked  <- 0L
  if (ext %in% c("xlsx", "csv") || !preserve.udm) {
    spss_udm_vars  <- .jst_has_spss_udm(data)
    stata_udm_vars <- .jst_has_tagged_na(data)
    if (!preserve.udm &&
        (length(spss_udm_vars) > 0 || length(stata_udm_vars) > 0)) {
      collapsed <- .jst_handle_udms(data, preserve.udm = FALSE)
      if (length(spss_udm_vars) > 0) {
        n_udm_blanked <- sum(vapply(spss_udm_vars, function(v) {
          # Count on the underlying values: is.na() on a labelled_spss column
          # treats the declared codes as missing, so a raw is.na() diff would
          # see no change. unclass() exposes the stored numerics, letting us
          # tell a blanked code cell from a pre-existing system-missing.
          before <- unclass(data[[v]])
          after  <- unclass(collapsed$df[[v]])
          sum(is.na(after) & !is.na(before))
        }, integer(1)))
      }
      data <- collapsed$df
    }
  }

  # --- Write the file (atomic: write to temp, then rename) -------------------
  # Issue 6: writes go to a temporary path adjacent to the target. On
  # success we rename the temp to the target; on any error we delete the
  # temp and re-raise. This protects against partial-file scenarios where
  # an underlying write_*() errors mid-write — without atomicity, jload()
  # could later read a truncated file and report a misleading success.
  #
  # Naming notes: tempfile() produces a unique non-existing path. The
  # target's extension is preserved (fileext = paste0(".", ext)) because
  # haven::write_xpt() validates the file name and rejects paths whose
  # name does not look like a SAS-acceptable filename — leading dots and
  # foreign extensions both trigger "A provided name contains an illegal
  # character." Adjacent placement (tmpdir = dirname(out_path)) keeps
  # file.rename() within one filesystem so the rename is atomic.
  basename_no_ext <- tools::file_path_sans_ext(basename(out_path))
  temp_path <- tempfile(
    pattern = paste0("jsave_", basename_no_ext, "_"),
    tmpdir  = dirname(out_path),
    fileext = paste0(".", ext)
  )

  # Registration-aware save: only the .rds format carries arbitrary R
  # attributes, so bake the active classification registrations (jnumeric/
  # jcount via .jst_registry, jdummy via .jst_dummy) onto the frame just for
  # that path. Other formats get a loss note after the write instead. No-op
  # when the frame has no registrations.
  if (ext == "rds") {
    data <- .jst_bake_registrations(data, data_name)
  }

  tryCatch({
    switch(ext,
           sav  = haven::write_sav(data, temp_path),
           dta  = haven::write_dta(data, temp_path, version = 14),
           xpt  = haven::write_xpt(data, temp_path),
           xlsx = writexl::write_xlsx(data, temp_path),
           csv  = utils::write.csv(data, temp_path, row.names = FALSE,
                                    na = ""),
           rds  = saveRDS(data, temp_path)
    )
  }, error = function(e) {
    unlink(temp_path)
    .jst_stop(conditionMessage(e))
  })

  # Move the completed temp into place. On Windows file.rename() fails if
  # the destination exists, so explicitly remove first when overwriting.
  if (file.exists(out_path)) {
    if (!file.remove(out_path)) {
      unlink(temp_path)
      .jst_stop("Could not remove existing target file: ",
           .jst_norm_path(out_path))
    }
  }
  if (!file.rename(temp_path, out_path)) {
    unlink(temp_path)
    .jst_stop("Could not finalize save: rename of temporary file to ",
         .jst_norm_path(out_path), " failed.")
  }

  # Format-specific loss-of-fidelity notes (emitted after a confirmed write).
  # Collect them, then emit separated by a blank line so that when more than
  # one fires they do not run together; a single note prints with no extra
  # blank line. Not joutput-gated -- these are loss-of-fidelity warnings
  # (Decision 6B), not verbosity-tier detail.
  loss_notes <- character(0)

  # Excel and CSV cannot store labels or missing-value metadata; the note
  # describes the loss (and, when preserve.udm = FALSE blanked SPSS-style
  # codes, confirms it).
  if (ext %in% c("xlsx", "csv")) {
    label_note <- .jst_jsave_label_loss_note(
      ext, spss_udm_vars, stata_udm_vars, preserve.udm, n_udm_blanked)
    if (!is.null(label_note)) loss_notes <- c(loss_notes, label_note)
  }

  # Classification registrations ride along only in .rds (baked above). Any
  # other format silently drops them, so note the loss -- but only when the
  # frame actually has registrations to lose.
  if (ext != "rds") {
    reg_loss_note <- .jst_jsave_registration_loss_note(ext, data_name)
    if (!is.null(reg_loss_note)) loss_notes <- c(loss_notes, reg_loss_note)
  }

  if (length(loss_notes) > 0) message(paste(loss_notes, collapse = "\n\n"))

  # --- Confirmation message --------------------------------------------------
  message(
    "Saved ", data_name, " to ", .jst_norm_path(out_path),
    " (", .jst_format_label(ext), "; ",
    format(nrow(data), big.mark = ","), " cases, ",
    ncol(data), " variables)"
  )

  invisible(NULL)
}


#' Copy a data frame, carrying its classification registrations
#'
#' Copies a data frame to a new name AND clones any classification
#' registrations (jnumeric / jcount / jdummy) attached to it, so the copy
#' behaves the same as the original under later analysis calls. A plain
#' assignment (newdata <- mydata) copies the data but not the registrations,
#' because registrations live in a name-keyed session notebook rather than on
#' the data object; jcopy() is the verb that keeps the two together across a
#' rename or copy.
#'
#' Like jload(), jcopy() cannot see the name on the left of an assignment, so
#' the new name is supplied as an argument. The destination name is unquoted,
#' and a single name is always taken as the destination, with the source coming
#' from the juse() default:
#'
#' \itemize{
#'   \item \code{jcopy(mydata, newdata)} -- copy \code{mydata} to
#'     \code{newdata}.
#'   \item \code{jcopy(newdata)} -- copy the juse() default frame to
#'     \code{newdata}.
#' }
#'
#' Registrations travel only when the source frame carries them; copying an
#' unregistered frame just copies the data. The copy is independent of the
#' original.
#'
#' @param data The source data frame (unquoted). May be omitted when a juse()
#'   default is set, in which case the default frame is the source.
#' @param name The destination name (unquoted) the copy is assigned to. When a
#'   single name is given it is read as the destination, not the source.
#' @param overwrite Logical; if FALSE (the default) and the destination name
#'   already exists in your environment, an interactive session asks before
#'   overwriting.
#' @param quiet Logical; if TRUE, suppress the confirmation message.
#' @return Invisibly NULL. Called for its side effect: the copy is assigned into
#'   the calling environment under \code{name}, and its registrations are cloned
#'   onto that name.
#' @examples
#' \dontrun{
#'   jdummy(community, Region)        # register a classification on community
#'   jcopy(community, survey)         # survey carries Region's registration
#'
#'   juse(community)
#'   jcopy(survey2)                   # copy the default (community) to survey2
#' }
#' @seealso \code{\link{jload}}, \code{\link{jsave}}, \code{\link{juse}}
#' @export
jcopy <- function(data, name, overwrite = FALSE, quiet = FALSE) {
  say <- function(...) if (!quiet) message(...)

  # Resolve source and destination. The destination name is unquoted and is
  # never evaluated -- it may not exist yet. A single supplied name is the
  # destination (source from the juse() default); two names are source then
  # destination. Keying off missing(name) -- not on what a symbol resolves to
  # -- keeps the one-argument form unambiguous.
  if (missing(name)) {
    # jcopy(newdata): the single positional argument is the destination; the
    # source is the juse() default. `data` is the destination promise and must
    # not be forced.
    if (missing(data)) {
      .jst_stop("Provide a destination name, e.g. jcopy(mydata, newdata).")
    }
    dest_sub <- substitute(data)
    src <- tryCatch(
      .jst_resolve_data(envir = parent.frame()),
      error = function(e)
        .jst_stop("No source given and no juse() default set. Either name the ",
             "source -- jcopy(mydata, ", paste(deparse(dest_sub),
             collapse = ""), ") -- or set a default with juse(mydata).")
    )
    src_data <- src$data
    src_name <- src$name
  } else {
    dest_sub <- substitute(name)
    if (missing(data)) {
      # jcopy(name = newdata): source from the juse() default.
      src      <- .jst_resolve_data(envir = parent.frame())
      src_data <- src$data
      src_name <- src$name
    } else {
      # jcopy(mydata, newdata): explicit source then destination.
      src_sub  <- substitute(data)
      src_data <- data
      if (!is.data.frame(src_data)) {
        .jst_stop("The source must be a data frame. ",
             "Provide one, e.g. jcopy(mydata, newdata).")
      }
      src_name <- paste(deparse(src_sub), collapse = "")
    }
  }

  # Validate and normalise the destination name (mirrors jload()).
  dest_name <- paste(deparse(dest_sub), collapse = "")
  if (grepl("^[0-9]", dest_name)) {
    .jst_stop("The name '", dest_name, "' starts with a number. ",
         "R does not allow variable names to start with a digit.")
  }
  dest_name <- make.names(dest_name)

  # Overwrite check in the calling environment.
  target_env <- parent.frame()
  if (exists(dest_name, envir = target_env, inherits = FALSE) && !overwrite) {
    if (interactive()) {
      response <- readline(
        paste0("'", dest_name, "' already exists in your environment. ",
               "Overwrite? (y/n): "))
      if (!tolower(trimws(response)) %in% c("y", "yes")) {
        message("Copy cancelled.")
        return(invisible(NULL))
      }
    } else {
      message("'", dest_name, "' already existed and has been replaced.")
    }
  }

  # Assign the data copy.
  assign(dest_name, src_data, envir = target_env)

  # Clone the name-keyed classification registrations onto the new name. Both
  # registries are frame-keyed; passing NULL through clears any stale entry
  # already sitting under the destination name (set-NULL removes the entry), so
  # the destination ends up matching the source either way.
  reg   <- .jst_get_registry(src_name)
  dummy <- .jst_get_dummy(src_name)
  .jst_set_registry(dest_name, reg)
  .jst_set_dummy(dest_name, dummy)
  carried <- !is.null(reg) || !is.null(dummy)

  # Confirmation.
  say("Copied ", src_name, " to ", dest_name, " (",
      format(nrow(src_data), big.mark = ","), " cases, ",
      ncol(src_data), " variables)")
  if (carried) {
    say("Carried over the classification registrations from ", src_name, ".")
  }

  invisible(NULL)
}
