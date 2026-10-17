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
#'   sessions, overwrites and says so in a note. In a script, state it
#'   explicitly: \code{jload("mydata.rds", overwrite = TRUE)}. Otherwise,
#'   if the name already exists in your environment, and the script was
#'   run by pasting or with RStudio's Run button, the call stops with an
#'   error.
#' @param package Logical. If \code{TRUE}, loads a jstats example dataset
#'   shipped in the package (e.g. \code{community}, \code{clinic}) by bare
#'   name, or a shipped example file by its file name
#'   (\code{"community_spss.sav"}), bypassing the disk search. Use this when
#'   a same-named file in the working directory or data folder would
#'   otherwise shadow the shipped copy. If \code{FALSE} (default), a
#'   matching disk file takes precedence and the shipped copy is used only
#'   when no file matches. \code{file} must be a name with no path when
#'   \code{package = TRUE}, and a dataset's name has no extension.
#' @param check.missing Logical. If \code{TRUE} (default), scans numeric
#'   variables for values that look like coded missing values (e.g. -99, 999)
#'   and reports them. Set to \code{FALSE} to skip this check.
#' @param sheet For Excel files only. The sheet to read --- either a sheet
#'   name (character) or sheet number (integer). Defaults to the first sheet.
#'   If the file has multiple sheets and \code{sheet} is not specified,
#'   a message lists the available sheets.
#' @param skip For Excel and CSV files. The number of rows of the sheet, or
#'   lines of the file, above the variable names: a title, a blank row, a
#'   note. Default 0. When the first row of a sheet looks like a title, a
#'   note shows the call with the \code{skip} it needs; a CSV file in that
#'   shape stops with the same call.
#' @param header For Excel and CSV files. \code{TRUE} (default) reads the
#'   first row of the sheet, or line of the file, as the variable names.
#'   \code{FALSE} reads it as the first case, for a file with no names row,
#'   and names the variables \code{V1}, \code{V2}, and so on, as base R's
#'   \code{read.csv(header = FALSE)} does. Every other format carries its
#'   own variable names, so \code{header = FALSE} stops there. When every
#'   name read is a number, a note shows the call with
#'   \code{header = FALSE}; writing \code{header = TRUE} in the call says the
#'   numbers are the names (years, say), and the note is not shown.
#' @param preserve.declarations Logical. If \code{TRUE} (default), declared
#'   missing values arriving with the file are preserved: SPSS-style
#'   codes such as -99, and declared ranges, keep their original numeric
#'   values in the data frame, with the declaration attached so the
#'   package's analysis functions still treat them as missing, and
#'   Stata-style tagged values (\code{.a}, \code{.b}, ...) are kept as
#'   read. If \code{FALSE}, both forms are converted to plain \code{NA}
#'   on import and the declarations are removed; value labels are kept.
#'   Applies to any loaded file whose columns
#'   carry missing-value declarations --- typically \code{.sav},
#'   \code{.dta}, and \code{.sas7bdat} files, and \code{.rds} files
#'   saved from such data. For \code{.sav} files, \code{TRUE}
#'   corresponds to haven's \code{user_na = TRUE}. The haven package and
#'   its documentation call these user-defined missing values.
#' @param missing.notice Per-call override for the missing-value notification.
#'   \code{NULL} (default) defers to the setting from \code{joutput()}.
#'   \code{TRUE} prints the notification, in its full form, on any load
#'   with declared missing values; \code{FALSE} suppresses it. Under the
#'   default (standard) and full output levels the first such load in a
#'   session prints the full notification and later loads print a compact
#'   form (the variable inventory, plus the convention note when one
#'   applies, without the guidance lines); minimal suppresses the
#'   notification. See \code{?joutput} for the full toggle behavior.
#'
#' @return Invisibly returns \code{NULL}; jload() is called for its side
#'   effects. The loaded data frame is placed in the calling environment
#'   under the file's name (or \code{name}), and any classification
#'   registrations saved with an .rds file are restored for that name.
#'   Loading a file that carries none clears any registrations set this
#'   session under that name, with a note saying so. Do not assign the
#'   result: \code{x <- jload("mydata.rds")} binds only \code{NULL},
#'   while the data frame still arrives under its own name.
#'
#' @details
#' \strong{File paths:}
#' Use forward slashes (\code{/}) in file paths. If you copy a path from
#' Windows File Explorer, replace the backslashes with forward slashes.
#' R does not accept single backslashes in file paths: inside quoted text
#' it reads a backslash and the letter after it as one special character
#' (a backslash before t is a tab), so the path that arrives is not the
#' one typed. \code{jload()} stops on such a path and shows it written
#' with forward slashes.
#'
#' \strong{CSV files:}
#' A CSV file with one column keeps its empty lines: each is a case whose
#' one cell is empty, which is how a missing value is written there. In a
#' file with two or more columns an empty line is not a case. An empty
#' cell in a text variable is read as blank text, never as missing (see
#' \code{\link{jsave}}).
#'
#' Before a CSV file is read, every line's values are counted. A first line
#' with fewer values than the lines below it (a title above the names, or a
#' name missing), and a later line with more values than the first, stop
#' the load with the line and what to do: read as they are, R would turn
#' the first values of every line into row names, or split the long line
#' into two cases, and say nothing. A file whose values are separated by
#' semicolons, as Excel saves them in many European settings, stops with
#' the base R line that reads it. A file that is not in UTF-8 (one saved by
#' Excel on Windows as "CSV (Comma delimited)" is in Windows-1252) is read
#' in Windows-1252, and a note says so. Read with \code{header = FALSE}, a
#' file has no names line, so each line is measured against the number of
#' values most lines hold: a line holding more stops the load, and one
#' holding fewer is read with its last cells empty.
#'
#' \strong{A file with no names row:}
#' A CSV file or a sheet whose first row is data loses that case to the
#' variable names, which are then numbers (\code{1} becomes \code{X1}).
#' When every name read is a number, or empty, a note says the row they
#' came from may be the first case and shows the call that reads it as one:
#' \code{jload("scores.csv", header = FALSE)}, the variables named
#' \code{V1}, \code{V2}, and so on.
#'
#' \strong{Rows and columns that may not be data:}
#' A sheet can hold rows with nothing in them, a column with no name and
#' nothing in it, and lines of text below the data, such as a source or a
#' footnote; a CSV file can hold a line of commas alone, an empty column
#' from a comma at the end of each line, and the row numbers R's
#' \code{write.csv()} writes in a first column with no name. Each is read
#' as data, as a case or a variable, and a note names them by their place
#' in the file, with the case numbers or the variable names; when footnotes
#' turned a variable of numbers into text, it says so. Nothing is removed.
#' An empty line in a CSV file of one column is a case with a missing value,
#' and is not named.
#'
#' \strong{Variable names from other software:}
#' A file from outside R can hold names R cannot use as they are:
#' \code{2024 score}, \code{Age (years)}, an empty header, two columns
#' with the same name, a word R reserves (\code{if}, \code{TRUE}), an SPSS
#' name such as \code{Q1@A}, a Stata name such as \code{_merge}. For every
#' format but \code{.rds}, each such name is changed: spaces and symbols at
#' either end are dropped, any other run of characters that are not
#' letters, digits or underscores becomes one underscore, a name that
#' starts with a digit or an underscore or is a reserved word gets an
#' \code{X} in front, an empty name becomes \code{V} and its column's
#' position, a repeated name gets \code{_2}, and a changed name is kept to
#' 32 characters. So \code{2024 score} becomes \code{X2024_score} and
#' \code{Age (years)} becomes \code{Age_years}. A name R can use as it is
#' is never changed. The original name becomes the variable's label, unless
#' the variable has a label of its own, and a note lists every change. An
#' \code{.rds} file is returned as it was saved.
#'
#' \strong{File search order:}
#' \enumerate{
#'   \item If the path contains a directory separator (\code{/}, or a
#'     backslash), the path is used directly.
#'   \item If the path is a bare filename, \code{jload()} checks:
#'     (a) the folder named by the \code{data.dir} setting in
#'     \code{\link{joptions}} if it is set and exists; (b) the working
#'     directory.
#' }
#' When the extension is omitted, both locations are searched for every
#' supported extension, and more than one match (two extensions, or the
#' same file in both locations) is an error that asks for the extension.
#' If nothing matches on disk, a bare name falls back to a shipped example
#' dataset of that name (see below).
#'
#' \strong{Auto-naming:}
#' The data frame name is derived from the filename by stripping the
#' extension. If the resulting name starts with a digit (which R does not
#' allow as a variable name), you must supply the \code{name} argument.
#' Other characters R does not allow in a name, such as spaces and
#' hyphens, are changed as variable names are (see above):
#' \code{"my data-1.sav"} loads as \code{my_data_1}.
#'
#' \strong{Excel files:}
#' Excel files (\code{.xlsx}, \code{.xls}) do not contain variable or
#' value labels. The data will be loaded as plain numeric, character, or
#' logical columns; a variable whose name was changed has its original
#' name as its label. Use \code{jrelabel()} to add labels after loading
#' if needed. Row 1 of the sheet is read as the variable names; when the
#' names are lower down, \code{skip} gives the number of rows above them,
#' and when there are none, \code{header = FALSE} reads row 1 as data.
#' Each variable's type is read from every row of the sheet.
#'
#' \strong{Missing-value declarations:}
#' Missing-value declarations are stored in the file itself, but they
#' only survive the trip back if the reader requests them.
#' \code{jload()} always does, so declarations written by
#' \code{jsave()} are present after every jstats load (unless
#' \code{preserve.declarations = FALSE}). Other ways of
#' reading the same file may convert the declared cells to plain
#' \code{NA} and discard the declarations, so the same file can show
#' different numbers of valid cases depending on how it was read.
#'
#' \strong{Coded missing values:}
#' When \code{check.missing = TRUE}, the function scans numeric variables
#' for values that look like coded missing values but are not declared as
#' missing. (Declared missing values are reported in the load's own
#' notification, never by the scan.) Only whole-number values are
#' considered. A value is flagged when it is
#' \itemize{
#'   \item a negative number at least three times the size of the
#'     variable's largest non-negative value (-99 on a 1-to-5 scale), or
#'   \item at least five times the size of every other value in the
#'     variable (999 on a 1-to-7 scale).
#' }
#' A value in the \code{missing.convention.codes} setting of
#' \code{\link{joptions}} (-99, -98 and -97 by default) is flagged as
#' well, whatever its size. A flagged value whose value label suggests
#' missingness (such as "Refused" or "Don't know") is reported as
#' label-only; one of the setting's codes, as convention-matched; the rest
#' as suspected. Flagged values are reported but not changed. If
#' they are missing values, declare them with
#' \code{\link{jdeclare_missing}}, which keeps the codes and their labels;
#' the report shows the call.
#'
#' \strong{Package example datasets and .rda / .RData files:}
#' \code{jload()} opens the example datasets shipped with jstats --
#' currently \code{community} and \code{clinic} -- by bare name:
#' \code{jload("community")}. These ship inside the package as .rda
#' files, but the bare-name load is a lookup of the shipped dataset,
#' not a file read, and it works only for package datasets. It does
#' not extend to .rda or .RData files generally: naming the extension
#' (\code{jload("community.rda")}) or pointing at any other .rda or
#' .RData file is refused with a pointer to base R's \code{load()},
#' because such files can hold several objects under names of their
#' own choosing, outside jload's one-data-frame contract. Note also
#' that the shipped dataset is a fallback: a file with a matching name
#' in the working directory or data.dir folder is opened instead of
#' the shipped copy. Use \code{package = TRUE} to force the shipped
#' dataset.
#'
#' \strong{Example files:}
#' jstats also ships the \code{community} data as files, the kind a
#' collaborator might send: \code{community_spss.sav},
#' \code{community_stata.dta} and \code{community_excel.xlsx}. When no
#' file of that name is in the data.dir folder or the working directory,
#' \code{jload("community_spss.sav")} reads the shipped one, and says so;
#' the name without its extension works too
#' (\code{jload("community_spss")}). A file of the same name on disk is
#' read instead, with a note giving the call that reads the shipped file:
#' \code{jload("community_spss.sav", package = TRUE)}.
#'
#' \strong{Variables named T or F:}
#' At \code{joutput("full")} a note names a variable called \code{T} or
#' \code{F}. jstats reads it as the variable, but in base R \code{T} and
#' \code{F} also stand for \code{TRUE} and \code{FALSE}, and code run
#' inside the data frame -- \code{with()}, \code{subset()} -- reads the
#' variable in their place.
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
#' jload("survey.xlsx", skip = 2)   # a title and a blank row above the names
#' jload("scores.csv", header = FALSE)   # no names row: V1, V2, ...
#'
#' # CSV and R format
#' jload("community.csv")
#' jload("community.rds")
#'
#' # Extension omitted -- jload searches for a matching file automatically
#' jload("community")
#'
#' # The example files shipped with jstats, read by name
#' jload("community_spss.sav")
#' jload("community_excel.xlsx", package = TRUE)   # even beside a local copy
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
#'   load summary, default-data note, registration notes, and the
#'   narrative about declared missing values, overriding missing.notice).
#'   Errors, warnings, the multi-sheet advisory, the overwrite prompt, the
#'   note that a local file shadowed a shipped dataset, the note that an
#'   existing object was replaced, and the notes on what the read changed
#'   or found (variable names changed, a title row, names that are all
#'   numbers, rows and columns that may not be data, a CSV file's encoding)
#'   are still shown, as is the coded-missing scan report; turn that off
#'   with \code{check.missing = FALSE}.
jload <- function(file, name = NULL, use = FALSE, overwrite = FALSE,
                  package = FALSE, check.missing = TRUE, sheet = NULL,
                  skip = 0, header = TRUE, preserve.declarations = TRUE,
                  missing.notice = NULL, quiet = FALSE) {
  # Validate TRUE/FALSE flags up front (display toggles also accept
  # NULL, meaning defer to joutput()).
  .jst_check_flag(use, "use")
  .jst_check_flag(overwrite, "overwrite")
  .jst_check_flag(package, "package")
  .jst_check_flag(check.missing, "check.missing")
  # header = (ruling R21, Jeff, S364; built Session 365): FALSE reads the
  # first row of a sheet, or line of a CSV file, as data, the variables
  # named V1, V2, ...; every other format carries its own names. Written
  # out as TRUE it says the names are names, which silences the note on a
  # first row of numbers (the S362 audit's item 14).
  .jst_check_flag(header, "header")
  header_given <- !missing(header)
  .jst_check_flag(preserve.declarations, "preserve.declarations")
  .jst_check_flag(quiet, "quiet")
  .jst_check_flag(missing.notice, "missing.notice", null.ok = TRUE)
  # skip = (ruling R9 part (2), Session 362): the rows of an Excel sheet,
  # or the lines of a CSV file, above the variable names.
  if (!is.numeric(skip) || length(skip) != 1L || is.na(skip) || skip < 0 ||
      skip != round(skip)) {
    .jst_stop("`skip` must be a whole number, 0 or more: the number of rows ",
              "above the variable names.")
  }
  skip <- as.integer(skip)

  # quiet = TRUE mutes informational messages (the directory-resolution
  # note, file found, load summary, default-data note, and the UDM
  # narrative). Errors, warnings, the multi-sheet advisory, the
  # shadowed-dataset note, and the overwrite prompt are never muted.
  say <- function(...) if (!quiet) .jst_msg(...)

  # Rule F: consecutive load-time notes are separated by a blank line so
  # they do not run together. The "Loaded ..." summary is a status line,
  # and since ruling R6 (S345; built Session 351) a blank line sets it off
  # from a note on either side. say_note() wraps say() with the tracking;
  # the Loaded line and the UDM narrative (emitted directly via message())
  # take part through the same .jst_note_fired flag.
  .jst_note_fired <- FALSE
  say_note <- function(...) {
    if (.jst_note_fired) say("")
    say(...)
    .jst_note_fired <<- TRUE
  }

  # --- Validate file argument ------------------------------------------------
  # What was given is read before the generic stop (Session 351, Fix Slate
  # 6). A name typed without its quotes, jload(mydata.sav), stopped on R's
  # own "object 'mydata.sav' not found" when the test below forced it; a
  # data frame, jload(community), and an expression that came out empty,
  # jload(system.file(...)) finding no file, both got "Provide a filename".
  # The argument is forced once, here, so an expression is not evaluated
  # twice.
  if (!missing(file)) {
    file_sub <- substitute(file)
    if (is.symbol(file_sub) &&
        !exists(as.character(file_sub), envir = parent.frame())) {
      .jst_stop(as.character(file_sub), " is not in quotes.\n",
                "A file name goes in quotes:\n",
                "  jload(\"", as.character(file_sub), "\")")
    }
    .jst_jload_file_value(file_sub, file)
  }
  # The name a loaded data frame is given, and a sheet name, typed bare
  # (ruling R18, Session 356): jload("f.rds", name = mydata) met R's
  # "object 'mydata' not found". Read before either is forced.
  .jst_free_text_arg(substitute(name), parent.frame(), sys.call(),
                     match.call(), "name", "a name", "jload")
  .jst_free_text_arg(substitute(sheet), parent.frame(), sys.call(),
                     match.call(), "sheet", "a sheet name", "jload")
  if (missing(file) || !is.character(file) || length(file) != 1 ||
      nchar(trimws(file)) == 0) {
    .jst_stop("Provide a filename, e.g. jload(\"mydata.sav\")")
  }
  # A path typed with single backslashes (S343, Jeff's decision; built
  # S351): R made "\t" and "\n" a tab and a new line before jload() saw it.
  .jst_check_path_chars(file)
  # The file as typed, for the lines a message offers (Session 362): the
  # resolution below replaces file with the path it found.
  file_typed <- gsub("\\", "/", file, fixed = TRUE)

  # The call a fix line offers (Session 362; widened Session 365): the file
  # as typed, the name, and every reading argument the call gave --
  # package = TRUE, sheet =, skip =, header = FALSE -- in the order of the
  # signature, the one the fix changes given by name (skip = 2, sheet =
  # "B", header = TRUE to leave it out). A line offered after the file WAS
  # loaded (the title note, the no-header note, the multi-sheet note)
  # carries overwrite = TRUE whatever the call gave: the name now holds what
  # was just read, and without it the line stops in a script (the
  # overwrite question, which source() answers with an empty line) -- a
  # printed call runs as printed. Until Session 365 the multi-sheet note
  # built its own line from basename(file), which dropped a typed folder,
  # and the sheet stop's and the leading-digit stop's lines dropped skip =.
  line_for <- function(..., loaded = FALSE, shown_file = file_typed) {
    set  <- list(...)
    pick <- function(key, own) if (key %in% names(set)) set[[key]] else own
    nm <- pick("name", name)
    sh <- pick("sheet", sheet)
    sk <- pick("skip", skip)
    hd <- pick("header", header)
    a <- paste0("\"", .jst_dq_escape(shown_file), "\"")
    if (!is.null(nm)) a <- c(a, paste0("name = \"", .jst_dq_escape(nm), "\""))
    if (isTRUE(overwrite) || loaded) a <- c(a, "overwrite = TRUE")
    if (isTRUE(package)) a <- c(a, "package = TRUE")
    if (!is.null(sh)) a <- c(a, paste0("sheet = ", paste(deparse(sh), collapse = "")))
    if (!is.null(sk) && sk > 0L) a <- c(a, paste0("skip = ", sk))
    if (isFALSE(hd)) a <- c(a, "header = FALSE")
    paste0("  jload(", paste(a, collapse = ", "), ")")
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
    # One voice with the bare-name redirect below (the S219 item's finding
    # 6; Session 357): the fact, then the base R line on its own. The file
    # is named as typed, slashes swapped so the line pastes back into R.
    shown <- gsub("\\", "/", file, fixed = TRUE)
    .jst_stop(
      shown, " is an .RData file, which jstats does not load.\n",
      "Load it with base R:\n",
      "  load(\"", shown, "\")"
    )
  }

  # --- Forced package dataset (package = TRUE) -------------------------------
  # from_package flags a package-shipped dataset rather than a disk file. It is
  # set here when package = TRUE forces the shipped copy, or in the no-extension
  # search below when nothing matches on disk.
  from_package <- FALSE
  # An example file shipped in inst/extdata (Session 361, the Session 74
  # item's second half): read as a file is, from its place in the
  # installed package, and said so before the Loaded line.
  from_extdata <- FALSE
  if (isTRUE(package)) {
    # Since Session 361 package = TRUE also forces an example file, named
    # with its extension (jload("community_spss.sav", package = TRUE)) or
    # by its name alone when no dataset has that name; a path is still
    # refused, and a dataset's name with an extension gets the name alone.
    if (has_dir) {
      b <- basename(file)
      .jst_stop(
        "package = TRUE loads a jstats example dataset or file by its ",
        "name alone.\n",
        "Drop the path:\n",
        "  jload(\"",
        if (b %in% .jst_extdata_files()) b else tools::file_path_sans_ext(b),
        "\", package = TRUE)"
      )
    }
    if (ext != "") {
      ex <- .jst_extdata_path(file)
      if (length(ex) == 0L) {
        stem <- tools::file_path_sans_ext(file)
        if (.jst_is_package_dataset(stem)) {
          .jst_stop(
            "package = TRUE loads a jstats example dataset by its name ",
            "alone.\n",
            "Drop the extension:\n",
            "  jload(\"", stem, "\", package = TRUE)"
          )
        }
        .jst_package_not_found(file)
      }
      file <- ex; has_dir <- TRUE; from_extdata <- TRUE
    } else {
      pkg_df <- .jst_get_package_dataset(file)
      if (!is.null(pkg_df)) {
        from_package <- TRUE
        df           <- pkg_df
      } else {
        ex <- .jst_extdata_path(file, stem = TRUE)
        if (length(ex) != 1L) .jst_package_not_found(file)
        file <- ex; ext <- tolower(tools::file_ext(ex))
        has_dir <- TRUE; from_extdata <- TRUE
      }
    }
  }

  # --- No extension: search for matching files -------------------------------
  if (!from_package && ext == "") {
    requested_name <- file
    found <- .jst_search_no_extension(file, has_dir)
    if (length(found) == 0) {
      # Disk files win: only when nothing matches on disk do we fall back to
      # a package-shipped dataset of this name (e.g. jload("community")).
      pkg_df <- .jst_get_package_dataset(file)
      ex_hit <- if (is.null(pkg_df) && !has_dir) {
        .jst_extdata_path(file, stem = TRUE)
      } else character(0)
      if (!is.null(pkg_df)) {
        from_package <- TRUE
        df <- pkg_df
      } else if (length(ex_hit) == 1L) {
        # Then a shipped example file of this name (Session 361):
        # jload("community_spss") reads community_spss.sav.
        file <- ex_hit; ext <- tolower(tools::file_ext(ex_hit))
        has_dir <- TRUE; from_extdata <- TRUE
      } else if (length(ex_hit) > 1L) {
        .jst_stop(
          "Multiple jstats example files match '", file, "':\n",
          paste0("  ", basename(ex_hit), collapse = "\n"), "\n",
          "Include the file extension to specify which one."
        )
      } else {
        # Nothing loadable, and no shipped dataset of this name. Before
        # reporting a bare not-found, check whether an .RData-family file is
        # sitting there under this stem: the file the user meant plainly
        # exists, and "no file found" would send them looking for a typo.
        # Same redirect as the typed-extension path above.
        # The extension in each case R writes and users type: on a
        # case-sensitive file system (Linux) "rdata" alone missed x.RData,
        # the form save() is usually given (Session 357).
        rdata_hit <- .jst_search_no_extension(file, has_dir,
                                              exts = c("RData", "rdata",
                                                       "Rdata", "rda", "RDA"))
        if (length(rdata_hit) > 0) {
          shown <- sub("^\\./", "", rdata_hit[1])
          .jst_stop(
            "No file found matching '", file, "' with any supported ",
            "extension.\n",
            shown, " is an .RData file, which jstats does not load.\n",
            "Load it with base R:\n",
            "  load(\"", shown, "\")"
          )
        }
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
      # A disk file matched. If a shipped jstats dataset shares this bare
      # name, the file shadowed it (disk wins) -- say so, and how to force the
      # dataset. Consequential and never muted, like the multi-sheet advisory.
      if (.jst_is_package_dataset(requested_name)) {
        .jst_msg(
          "A local file and a jstats example dataset are both named '",
          requested_name, "'.\n",
          "The local file was loaded.\n",
          "To load the example dataset instead, use:\n",
          "  jload(\"", requested_name, "\", package = TRUE)"
        )
      } else if (!has_dir &&
                 length(.jst_extdata_path(requested_name, stem = TRUE)) == 1L) {
        # The same for a shipped example file (Session 361).
        .jst_msg(
          "A local file and a jstats example file are both named '",
          requested_name, "'.\n",
          "The local file was loaded.\n",
          "To load the example file instead, use:\n",
          "  jload(\"", requested_name, "\", package = TRUE)"
        )
      }
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
      "  .rds       R"
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
    # Bare filename — search the data.dir folder (if set), then the working
    # directory, then (Session 361) the example files shipped with jstats:
    # jload("community_spss.sav") with no such file on disk reads the
    # shipped one. A file on disk wins, and is said to.
    ex <- .jst_extdata_path(file)
    resolved_path <- .jst_find_file(file, quiet = quiet,
                                    fallback = if (length(ex)) ex else NULL)
    if (length(ex) == 1L) {
      if (identical(resolved_path, ex)) {
        from_extdata <- TRUE
      } else {
        .jst_msg(
          "A local file and a jstats example file are both named '",
          file, "'.\n",
          "The local file was loaded.\n",
          "To load the example file instead, use:\n",
          "  jload(\"", file, "\", package = TRUE)"
        )
      }
    }
  }
  # header = FALSE on a format that carries its own variable names (ruling
  # R21): a stop, before the overwrite question and the read, with the call
  # to run without it. header = TRUE written out passes, as skip = 0 does.
  if (!header && (from_package || !ext %in% c("csv", "xlsx", "xls"))) {
    .jst_stop(
      "header = FALSE is only for Excel format (.xlsx, .xls) and CSV format ",
      "(.csv).\n",
      if (from_package) {
        paste0(file, " is a jstats example dataset, which carries its own ",
               "variable names.\n")
      } else {
        paste0(basename(file), " is in ", .jst_format_label(ext), " (.", ext,
               "), which carries its own variable names.\n")
      },
      "To load it, drop header = FALSE:\n",
      line_for(header = TRUE, sheet = NULL, skip = 0L)
    )
  }

  # Where an example file was read from, in the form a data.dir read takes
  # ("Reading from <folder>"), before the Loaded line.
  if (from_extdata) say("Reading from the jstats example files")

  # --- Determine object name -------------------------------------------------
  if (!is.null(name)) {
    obj_name <- name
  } else {
    obj_name <- tools::file_path_sans_ext(basename(file))
  }

  # Check for leading digit. The rule is about the DATA FRAME's name
  # (Session 351, the Session 154 item's part 3): "variable names" read as
  # columns to the users this message meets. A name given with name = is
  # the name that starts with the digit, not the file's.
  if (grepl("^[0-9]", obj_name)) {
    .jst_stop(
      if (is.null(name)) {
        paste0("The filename '", basename(file), "' starts with a number.\n")
      } else {
        paste0("The name '", name, "' starts with a number.\n")
      },
      "R does not allow a data frame's name to start with a digit.\n",
      "Provide a name, e.g.:\n",
      # Slash-swap, not normalizePath: a bare data.dir-resolved name
      # must stay bare so the rerun resolves the same way; only the
      # backslashes are unpasteable (S241 walk finding, D6 sibling).
      # Since Session 365 the line keeps the call's reading arguments
      # (sheet =, skip =, header = FALSE), through line_for().
      line_for(name = gsub("^[0-9]+", "", obj_name),
               shown_file = gsub("\\", "/", file, fixed = TRUE))
    )
  }

  # A name R cannot use as it is gets the cleaner the variables get (the
  # import audit's lean 10, Session 362): "My Survey (final)" becomes
  # My_Survey_final, where make.names() gave My.Survey..final.
  obj_name <- .jst_clean_object_name(obj_name)

  # --- Overwrite check -------------------------------------------------------
  # The question is asked before the read, so a "no" costs no read. The
  # note of a session that cannot ask waits for the assignment (Session
  # 365): printed here, it said "has been replaced" over a call that then
  # stopped on a CSV file's shape or a sheet = naming no sheet.
  target_env <- parent.frame()
  replaced <- FALSE
  if (exists(obj_name, envir = target_env, inherits = FALSE) && !overwrite) {
    if (interactive()) {
      ok <- .jst_confirm(
        paste0("'", obj_name, "' already exists in your environment. ",
               "Overwrite? (y/n): "),
        "Add overwrite = TRUE to the call, then run it again."
      )
      if (!ok) {
        .jst_msg("Load cancelled.")
        return(invisible(NULL))
      }
    } else {
      replaced <- TRUE
    }
  }

  # --- Validate sheet argument for non-Excel files ----------------------------
  if (!is.null(sheet) && !ext %in% c("xlsx", "xls")) {
    .jst_warn(
      "`sheet` is only used for Excel format (.xlsx, .xls). ",
      "Ignoring it for this .", ext, " file."
    )
  }
  if (skip > 0L && !ext %in% c("xlsx", "xls", "csv")) {
    .jst_warn(
      "`skip` is only used for Excel format (.xlsx, .xls) and CSV format ",
      "(.csv). Ignoring it for this .", ext, " file."
    )
  }

  # --- Start-of-load status line ---------------------------------------------
  # Printed before the (possibly slow) file read so the console shows activity
  # for the whole read plus the post-load scan, and the "Loaded" summary below
  # can wait until the object is actually in place. Package example datasets
  # skip it: they are already in memory here and load instantly.
  #
  # The 15 MB threshold is a deliberately conservative catch, NOT a calibrated
  # figure. Its S204 rationale ("roughly ten seconds and up") was measured
  # against the quadratic Rule 2 loop in .jst_detect_suspicious_values, which
  # dominated load time until it was fixed in S205; that calibration died with
  # the defect. Post-fix timings on a fast local SSD (S205):
  #
  #   events.rds   1.1 MB    143,983 x 7    0.06 s
  #   events.sav   9.2 MB    143,983 x 7    0.17 s
  #   Visits.csv   109 MiB   1,945,849 x 4  1.49 s
  #
  # So on modern local disks nothing realistic is slow enough to need the
  # line, and 15 MB fires early. It is kept anyway for the cases those
  # timings cannot reach -- network shares, USB and other slow media, older
  # machines -- where firing early is the safe direction for a reassurance
  # message. Retuning upward would be fitting a constant to one SSD. A
  # companion post-read gate on cell count was added and retired in the same
  # session: with the scan fixed there was no wait left for it to announce.
  if (!from_package) {
    fsize <- suppressWarnings(file.size(resolved_path))
    big   <- !is.na(fsize) && fsize >= 15 * 1024^2
    # Bare-line floor (S230): since the D1 reorder put "Loaded ..." first,
    # the bare Loading line is redundant on a fast load, so it fires only
    # from 1 MB up -- below that even slow media finish in about a second.
    # The floor inherits the S205 err-low principle (a 1 MB/s share takes
    # ~1 s at the floor and grows from there); an unknown size also shows
    # the line, erring toward reassurance. The 15 MB suffix gate above is
    # unchanged -- see the S205 comment for why it must not be retuned.
    show_line <- is.na(fsize) || fsize >= 1 * 1024^2
    if (show_line) {
      say("Loading ", obj_name, " ...",
          if (big) " (large file; this may take a moment)" else "")
    }
  }

  # --- Read the file ---------------------------------------------------------
  # A reader's own error is relayed in the house form (Rule AH; the import
  # audit, Session 362): until then R's "no lines available in input" or
  # readxl's "Sheet 'Nope' not found" reached the user with no jload() in
  # front of it and nothing said of the file.
  shown <- basename(file)
  read_or_stop <- function(expr) {
    tryCatch(expr, error = function(e) {
      .jst_stop(shown, " could not be read.\nR reported:\n  ",
                gsub("\\s*\n\\s*", " ",
                     gsub("\033\\[[0-9;]*m", "", conditionMessage(e))),
                fn = "jload")
    })
  }
  # A CSV file is checked before it is read (the import audit, Session
  # 362): empty; its encoding (Windows-1252 from Excel on Windows read as
  # such); a first line shorter than the lines below it, or a line longer
  # than the first, which read.csv() turns into row names or a second case
  # without a word (.jst_csv_check_shape()). Read with header = FALSE
  # (Session 365) a file has no names line, so each line is measured
  # against the count most lines hold, which the read then takes as the
  # number of variables (csv_cols).
  csv_enc  <- NULL
  csv_cols <- NULL
  if (!from_package && ext == "csv") {
    if (isTRUE(file.size(resolved_path) == 0)) {
      .jst_stop(shown, " is empty: it holds no lines.")
    }
    csv_enc  <- .jst_csv_encoding(resolved_path)
    csv_cols <- .jst_csv_check_shape(resolved_path, skip, csv_enc, shown,
                                     line_for, obj_name, header = header)
  }

  # An Excel file's sheets, and a sheet = that names none of them (Session
  # 362: readxl's "Sheet 'Nope' not found" had come through raw).
  if (!from_package && ext %in% c("xlsx", "xls")) {
    all_sheets <- read_or_stop(readxl::excel_sheets(resolved_path))
    if (!is.null(sheet)) {
      missing_sheet <- if (is.character(sheet)) {
        !sheet %in% all_sheets
      } else {
        !is.numeric(sheet) || length(sheet) != 1L || is.na(sheet) ||
          sheet != round(sheet) || sheet < 1 || sheet > length(all_sheets)
      }
      if (missing_sheet) {
        n_sh <- length(all_sheets)
        q_sh <- paste0("\"", all_sheets, "\"")
        .jst_stop(
          if (is.character(sheet)) {
            paste0(shown, " has no sheet named \"", sheet, "\".\n")
          } else {
            paste0(shown, " has ", n_sh, " ", .jst_plural(n_sh, "sheet", "sheets"),
                   ", so there is no sheet ", paste(deparse(sheet), collapse = ""),
                   ".\n")
          },
          if (n_sh == 1L) paste0("Its only sheet is ", q_sh, ":\n")
          else paste0("Its sheets are ", .jst_and_list(q_sh), ".\n",
                      "To read one, name it:\n"),
          line_for(sheet = all_sheets[1L]))
      }
    }
    # Multi-sheet message (only when sheet not specified). Its line is the
    # call's own since Session 365 (the folder as typed, name =, skip =,
    # header = FALSE), with overwrite = TRUE: the first sheet is read under
    # the name before anyone runs it. It was built from basename(file),
    # which read another file, or none, when a folder was typed.
    if (is.null(sheet) && length(all_sheets) > 1) {
      .jst_msg(
        "This file has ", length(all_sheets), " sheets: ",
        paste(all_sheets, collapse = ", "), "\n",
        "Reading the first sheet (\"", all_sheets[1], "\"). ",
        "To read a different sheet, use:\n",
        line_for(sheet = all_sheets[2L], loaded = TRUE)
      )
    }
  }

  # For .sav: always pass user_na = TRUE so UDM metadata is available for
  # the .jst_handle_udms step below, regardless of preserve.declarations. The package
  # then decides whether to preserve or convert based on preserve.declarations.
  df <- if (from_package) df else switch(ext,
               sav      = read_or_stop(haven::read_sav(resolved_path, user_na = TRUE)),
               dta      = read_or_stop(haven::read_dta(resolved_path)),
               sas7bdat = read_or_stop(haven::read_sas(resolved_path)),
               xpt      = read_or_stop(haven::read_xpt(resolved_path)),
               # A one-column file keeps its empty lines (Session 351, the
               # S345 item): each is a case whose one cell is empty -- how
               # jsave(), write.csv(na = "") and Excel all write a missing
               # cell there -- and read.csv() skipped them, so 8 cases saved
               # came back as 6. A file of two or more columns is read as
               # before: an empty line in it is not a case.
               # Since Session 362: the names as the file has them
               # (check.names = FALSE; the cleaner below renames), never a
               # column taken as row names (row.names = NULL), skip = lines
               # above the names, and the file's encoding.
               # Since Session 365 (ruling R21): header = FALSE reads the
               # first line as a case, the variables V1, V2, ... for the
               # count most lines hold (col.names), so a long line past the
               # first five -- the lines read.csv() counts -- is never
               # split, and a one-column file is known by that count.
               csv      = {
                 csv_args <- list(
                   resolved_path, header = header, stringsAsFactors = FALSE,
                   check.names = FALSE, row.names = NULL, skip = skip,
                   fileEncoding = if (is.null(csv_enc)) "" else csv_enc,
                   blank.lines.skip = if (header) {
                     !.jst_csv_one_column(resolved_path, skip, csv_enc)
                   } else !identical(csv_cols, 1L))
                 if (!header && !is.null(csv_cols)) {
                   csv_args$col.names <- paste0("V", seq_len(csv_cols))
                 }
                 read_or_stop(do.call(utils::read.csv, csv_args))
               },
               rds      = read_or_stop(readRDS(resolved_path)),
               xlsx     = ,
               xls      = {
                 # Since Session 362: the names as the sheet has them
                 # (.name_repair = "minimal": readxl's "New names:" message
                 # is gone, the cleaner below renames and says so), skip =,
                 # and a column's type guessed from every row, not the first
                 # 1,000 -- readxl turned 100 text cells after row 1,100 into
                 # missing values with 100 warnings, and 100 numbers below
                 # 1,100 empty cells into TRUE with none (1,048,576 is
                 # Excel's row limit).
                 # Since Session 365 (ruling R21): header = FALSE reads row
                 # 1 as data (col_names = FALSE, which gives every column
                 # an empty name under "minimal"), the variables named V1,
                 # V2, ... as read.csv(header = FALSE) names them.
                 read_args <- list(path = resolved_path, skip = skip,
                                   col_names = header,
                                   guess_max = 1048576L,
                                   .name_repair = "minimal")
                 if (!is.null(sheet)) read_args$sheet <- sheet
                 xl <- read_or_stop(do.call(readxl::read_excel, read_args))
                 if (!header) names(xl) <- paste0("V", seq_len(ncol(xl)))
                 xl
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

  # --- Variable names from outside R (ruling R9 part (1), ruling R20) --------
  # Session 362. A file from outside R -- every format but .rds -- can hold
  # names R cannot read bare. Each such name is cleaned, one rule for every
  # format, the old name kept as the variable's label where it has none,
  # and a note lists every change; a name R takes as it is is never
  # touched (.jst_clean_import_names()). A package dataset and an .rds file
  # come back as they were made. An Excel sheet whose first row may be a
  # title is found here too, before the names change (.jst_excel_title_row()).
  rename_note <- NULL
  title_rows  <- NULL
  title_named <- 0L
  nohead_note <- NULL
  stray_note  <- NULL
  if (!from_package && ext != "rds") {
    sheet_file <- ext %in% c("xlsx", "xls")
    raw_nm <- names(df)
    # The title note reads the names row; with header = FALSE there is none.
    if (sheet_file && header) {
      title_rows  <- .jst_excel_title_row(resolved_path, sheet, skip, raw_nm)
      title_named <- sum(nzchar(trimws(raw_nm)))
    }
    # Session 365: names that are all numbers (the no-header note), and
    # rows and columns that may not be data (the stray-parts note), found
    # on the names as the file has them. Neither beside a title note, whose
    # skip = call reads the sheet again: one thing at a time.
    no_head <- FALSE
    parts   <- NULL
    if ((sheet_file || ext == "csv") && is.null(title_rows)) {
      no_head <- header && !header_given && .jst_names_all_numbers(raw_nm)
      parts   <- .jst_import_stray_parts(df, raw_nm, header)
    }
    cl <- .jst_clean_import_names(raw_nm)
    if (any(cl$changed)) {
      ap <- .jst_apply_new_names(df, cl$names, cl$changed)
      df <- ap$df
      rename_note <- .jst_import_names_note(raw_nm[cl$changed],
                                            cl$names[cl$changed], ap$had)
    }
    if (no_head) {
      nohead_note <- .jst_no_header_note(shown, raw_nm, sheet_file,
                                         line_for(header = FALSE, loaded = TRUE))
    }
    if (!is.null(parts) && length(parts$rows) + length(parts$notes) +
        length(parts$cols) + parts$rownum > 0L) {
      # Where each case and variable is in the file, counted only when
      # there is something to say (a second, light read).
      case_pos <- NULL
      col_pos  <- NULL
      if (sheet_file) {
        og <- .jst_excel_origin(resolved_path, sheet, skip)
        if (!is.null(og)) {
          case_pos <- og$row - 1L + (if (header) 1L else 0L) + seq_len(nrow(df))
          col_pos  <- .jst_excel_col_letters(og$col - 1L + seq_len(ncol(df)))
          # A column holding numbers and the footnotes' text is read as
          # text; numbers stored as text in Excel are too, and only the
          # cells say which.
          if (isTRUE(parts$text_col)) {
            parts$text_col <- .jst_excel_cells_numeric(
              resolved_path, sheet, case_pos[parts$rest], og$col)
          }
        } else parts$text_col <- FALSE
      } else {
        ln <- .jst_csv_case_lines(resolved_path, skip, csv_enc, header)
        if (length(ln) == nrow(df)) case_pos <- ln
        col_pos <- as.character(seq_len(ncol(df)))
      }
      stray_note <- .jst_stray_parts_note(parts, names(df), shown, sheet_file,
                                          case_pos, col_pos, header, obj_name)
    }
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
  # Either preserve the metadata (preserve.declarations = TRUE, the default) or
  # convert UDM cells to plain NA and strip the metadata (preserve.declarations
  # = FALSE). Either way we capture per-variable info for the narrative.
  udm_result <- .jst_handle_udms(df, preserve.declarations)
  df         <- udm_result$df
  udm_info   <- udm_result$udm_info

  # --- Assign to environment -------------------------------------------------
  # The non-interactive overwrite note, at the replacement itself (see the
  # overwrite check); a note, so a blank line sets the Loaded line off from
  # it (ruling R6).
  if (replaced) {
    .jst_msg("'", obj_name, "' already existed and has been replaced.")
    .jst_note_fired <- TRUE
  }
  assign(obj_name, df, envir = target_env)

  # --- Refresh classification registrations ----------------------------------
  # Make the session notebook for this frame name match the file (the file is
  # the source of truth at load time). Keyed by obj_name -- the name the frame
  # is loaded as, which is what later analysis calls reference -- not the name
  # it was saved under. Restores baked registrations (replacing any differing
  # in-session ones), or clears stale ones when the loaded data carries none.
  # Entries for variables absent from the loaded frame are dropped before
  # filing (load-side intersect, S208), with a note.
  reg_note <- .jst_refresh_registrations(obj_name, baked_regs, names(df))
  for (nt in reg_note) say_note(nt)

  # --- Set as default with juse() if requested -------------------------------
  if (use) {
    options(.jst_default_data = obj_name)
    say_note("Default data frame set to: ", obj_name)
  }

  # --- Summary message --------------------------------------------------------
  # Printed BEFORE the UDM narrative (S227, E17 reorder): the load
  # confirmation leads, and the narrative reads as detail under it. The
  # object is already in place -- the environment assign happened above.
  # A status line, set off by a blank line from a note on either side
  # (ruling R6, Jeff, S345; built Session 351): the narrative sat directly
  # on it. Under quiet = TRUE nothing the flag spaces prints, so it is set
  # whatever quiet is (a guard on it was dead code: the S351 mutant round).
  if (.jst_note_fired) say("")
  if (from_package) {
    # No closing period, as on the file branch below and jsave()'s Saved
    # line: a status line (the S206 item, candidate 2; Session 357).
    say("Loaded the jstats example dataset '", file, "'")
  } else {
    say(
      "Loaded ", obj_name,
      " (", .jst_format_label(ext), "; ",
      format(nrow(df), big.mark = ","),
      if (nrow(df) == 1L) " case, " else " cases, ",
      ncol(df),
      if (ncol(df) == 1L) " variable)" else " variables)"
    )
  }
  .jst_note_fired <- TRUE

  # --- What the read found, and the names it changed (Session 362) ------------
  # Consequential notes, shown under quiet = TRUE as well: the file's
  # encoding when it was not UTF-8, an Excel title row and the skip = call
  # that reads past it (ruling R9 part (2)), and the names changed (part
  # (1)). Each is set off by a blank line (Rule F).
  emit_note <- function(...) {
    if (.jst_note_fired) .jst_msg("")
    .jst_msg(...)
    .jst_note_fired <<- TRUE
  }
  if (!is.null(csv_enc)) {
    emit_note("Note: ", shown, " is not in UTF-8, the encoding R reads, so ",
              "it was read as ",
              if (identical(csv_enc, "CP1252")) {
                "Windows-1252, the encoding Excel on Windows saves a CSV file in."
              } else "Latin-1.",
              "\nCheck its accented letters and symbols.")
  }
  if (!is.null(title_rows)) {
    k_cols <- ncol(df)
    above  <- title_rows$names - 1L
    emit_note("Note: row ", title_rows$title, " of ", shown, " has a name in ",
              "only ", title_named, " of its ", k_cols, " ",
              .jst_plural(k_cols, "column", "columns"), ", so it may be a ",
              "title rather than the variable names.\n",
              "The names seem to be in row ", title_rows$names, ".\n",
              "To read from there, skip the ", above, " ",
              .jst_plural(above, "row", "rows"), " above them:\n",
              line_for(skip = above, loaded = TRUE))
  }
  # Session 365: the no-header note and the stray-parts note, after the
  # title note and before the names changed, which list what was read.
  if (!is.null(nohead_note)) emit_note(nohead_note)
  if (!is.null(stray_note)) emit_note(stray_note)
  if (!is.null(rename_note)) emit_note(rename_note)

  # --- UDM narrative notification --------------------------------------------
  # Toggle resolution: per-call missing.notice arg > joutput global toggle >
  # joutput level default. Standard and full both default to TRUE (show on
  # every UDM-bearing load); minimal is FALSE. The NULL/"auto" branch below
  # (show once per session, tracked via .jst_missing_notice_shown) is retained
  # but no preset level now selects it.
  # Form (S227, E17): the first showing in a session uses the full form;
  # later showings use the compact form (inventory plus any convention
  # note, guidance lines dropped). An explicitly passed missing.notice = TRUE
  # forces the full form, giving a way to recall the guidance later in a
  # session. A blank line sets it off from the Loaded line above it (ruling
  # R6, Session 351; from S227 to S350 it followed with none).
  if (length(udm_info) > 0) {
    notice_setting <- .jst_resolve_toggle("missing.notice", missing.notice)
    show_notice <- if (isTRUE(notice_setting)) {
      TRUE
    } else if (identical(notice_setting, FALSE)) {
      FALSE
    } else {
      # NULL / auto mode — show only if not yet shown this session
      !isTRUE(getOption(".jst_missing_notice_shown", FALSE))
    }
    if (show_notice && !quiet) {
      compact <- isTRUE(getOption(".jst_missing_notice_shown", FALSE)) &&
        !isTRUE(missing.notice)
      if (.jst_note_fired) say("")
      .jst_msg(.jst_format_udm_narrative(udm_info, preserve.declarations,
                                        data_name = obj_name,
                                        compact = compact))
      .jst_note_fired <- TRUE
      options(.jst_missing_notice_shown = TRUE)
    }
  }

  # --- Variables named T or F (Session 361, the S289 item) --------------------
  # T and F are base R's overwritable stand-ins for TRUE and FALSE. jstats
  # reads a variable of either name as the variable (ruling R18: the data
  # frame's variable wins), but base R code run inside the data -- with(),
  # subset(), transform() -- reads the variable where T or F meant TRUE or
  # FALSE. An advisory note (joutput("full") only), as the item has it; a
  # blank line sets it off from a note above it (Rule F).
  tf_vars <- intersect(c("T", "F"), names(df))
  if (length(tf_vars) > 0L && !quiet &&
      identical(getOption(".jst_output_level", "standard"), "full")) {
    n_tf <- length(tf_vars)
    if (.jst_note_fired) say("")
    .jst_advisory_note(
      "Note: ", .jst_and_list(tf_vars), " ", .jst_plural(n_tf, "is a variable",
                                                         "are variables"),
      " in ", obj_name, ".\n",
      "jstats reads ", .jst_plural(n_tf, "it", "them"), " as the ",
      .jst_plural(n_tf, "variable", "variables"), ", but in base R ",
      .jst_and_list(tf_vars), " also ", .jst_plural(n_tf, "stands", "stand"),
      " for ", .jst_and_list(c(T = "TRUE", F = "FALSE")[tf_vars]),
      ", and code run inside ", obj_name, " (with(), subset()) reads the ",
      .jst_plural(n_tf, "variable", "variables"), " in ",
      .jst_plural(n_tf, "its", "their"), " place.\n",
      "To rename ", .jst_plural(n_tf, "it", "them"), ", replacing ",
      .jst_plural(n_tf, "newname", "the new names"), ":\n",
      paste0("  names(", obj_name, ")[names(", obj_name, ") == \"", tf_vars,
             "\"] <- \"",
             if (n_tf == 1L) "newname" else paste0("newname", seq_len(n_tf)),
             "\"", collapse = "\n"))
    .jst_note_fired <- TRUE
  }

  # --- Coded missing value scan ----------------------------------------------
  # Formally declared UDMs are the narrative's job (.jst_handle_udms,
  # above); the scan reports only what the narrative cannot -- values
  # whose labels look like missing-value codes without a declaration
  # (label-only), values in the missing.convention.codes setting with no
  # declaration (convention-matched, Session 361), and suspicious sentinel
  # values with no metadata at all (suspected). Declared codes are
  # excluded from every classification.
  # (The scan's formal-UDM branch, unreachable from this call by
  # construction, was removed at S233 -- see the changelog.)
  if (check.missing) {
    .jst_scan_coded_missing(df, obj_name)
  }

  # DECISION B (settled S205, implemented S208): return nothing. jload() is
  # a statement -- it places the frame under obj_name above -- and returning
  # the frame invited the capture reflex (x <- jload(...)), which minted a
  # silent second copy the registration notebook never knew about. Post-B
  # the capture binds NULL, visible in the Environment pane, and first use
  # fails loudly via the resolver NULL guard.
  invisible(NULL)
}


# -- jload internal helpers ---------------------------------------------------

#' Internal: names of datasets shipped in the package
#'
#' @description
#' Returns the bare names of every dataset shipped in the package's
#' \code{data/} directory (e.g. \code{community}, \code{clinic}), resolved
#' through the package's own namespace so a later package rename is followed
#' automatically. Returns \code{character(0)} when the package is not installed
#' as a namespace (e.g. when the source is merely \code{source()}d during
#' development).
#'
#' @return A character vector of dataset names, possibly empty.
#'
#' @keywords internal
.jst_package_datasets <- function() {
  pkg <- utils::packageName(environment())
  if (is.null(pkg)) return(character(0))

  avail <- tryCatch(
    utils::data(package = pkg)$results[, "Item"],
    error = function(e) character(0)
  )
  # data() item names can carry a parenthetical alias (e.g. "x (y)"); keep the
  # leading token only.
  sub("\\s.*$", "", avail)
}

#' Internal: the example files shipped in the package's inst/extdata
#'
#' @description
#' Session 361 (the Session 74 item's extdata half, decided S77 and S107):
#' the files jload() finds by name when no file of that name is on disk --
#' \code{community_spss.sav}, \code{community_stata.dta} and
#' \code{community_excel.xlsx}. Resolved through the package's own
#' namespace, as \code{.jst_package_datasets()} is, and empty when the
#' package is not installed as a namespace.
#'
#' @return A sorted character vector of file names, possibly empty.
#'
#' @keywords internal
.jst_extdata_files <- function() {
  pkg <- utils::packageName(environment())
  if (is.null(pkg)) return(character(0))
  dir <- system.file("extdata", package = pkg)
  if (!nzchar(dir)) return(character(0))
  sort(list.files(dir))
}

#' Internal: the full path of a shipped example file
#'
#' @param name A file name, with its extension; or, with \code{stem =
#'   TRUE}, a name without one.
#' @param stem Logical: match \code{name} against the files' names without
#'   their extensions (the loadable extensions only).
#' @return Character vector of full paths -- one, none, or (by stem)
#'   several.
#' @keywords internal
.jst_extdata_path <- function(name, stem = FALSE) {
  files <- .jst_extdata_files()
  hits <- if (isTRUE(stem)) {
    files[tools::file_path_sans_ext(files) == name &
            tolower(tools::file_ext(files)) %in%
              c("sav", "dta", "csv", "rds", "sas7bdat", "xpt", "xlsx", "xls")]
  } else files[files == name]
  if (length(hits) == 0L) return(character(0))
  pkg <- utils::packageName(environment())
  vapply(hits, function(f) system.file("extdata", f, package = pkg),
         character(1), USE.NAMES = FALSE)
}

#' Internal: the not-found stop of jload(package = TRUE)
#' @param file What was asked for.
#' @keywords internal
.jst_package_not_found <- function(file) {
  ex <- .jst_extdata_files()
  .jst_stop(
    "No jstats example dataset or file named '", file, "'.\n",
    "Shipped datasets: ",
    paste(.jst_package_datasets(), collapse = ", "), ".",
    if (length(ex) > 0L) paste0("\nExample files: ",
                                paste(ex, collapse = ", "), ".")
  )
}

#' Internal: is a bare name a package-shipped dataset?
#'
#' @description
#' TRUE when \code{name} matches a dataset shipped in the package (see
#' \code{.jst_package_datasets}). Backs jload's shadowed-dataset note (a disk
#' file sharing a name with a shipped dataset) and the package = TRUE guard,
#' both of which need a name-only test without materialising the data.
#'
#' @param name Character(1). The bare name to test.
#'
#' @return A length-one logical.
#'
#' @keywords internal
.jst_is_package_dataset <- function(name) {
  name %in% .jst_package_datasets()
}

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

  if (!.jst_is_package_dataset(name)) return(NULL)

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

#' Internal: does a CSV file have exactly one column?
#'
#' Reads the header line alone -- the separator and quoting read.csv()
#' uses, so a quoted name holding a comma is one field -- and counts its
#' fields. jload() reads a one-column file without skipping empty lines
#' (Session 351), since there an empty line is a case with an empty cell.
#' A file that cannot be read this way answers FALSE, leaving read.csv()'s
#' default and its own error. Since Session 362 the header line is the one
#' after skip = lines, read in the file's encoding.
#' @param path Path to the file.
#' @param skip Lines above the names.
#' @param enc NULL, or the encoding the file is read in.
#' @return TRUE or FALSE.
#' @keywords internal
.jst_csv_one_column <- function(path, skip = 0L, enc = NULL) {
  con <- if (is.null(enc)) path else file(path, encoding = enc)
  hdr <- tryCatch(scan(con, what = "", sep = ",", quote = "\"", skip = skip,
                       nlines = 1L, quiet = TRUE, na.strings = character(0)),
                  error = function(e) character(0))
  length(hdr) == 1L
}

# -- Names from outside R (ruling R9, ruling R20; Session 362) -----------------
#
# A file made outside R can hold variable names R cannot read bare: "2024
# score", "Age (years)", "Agree?", an empty header, a duplicate, a word R
# reserves, an SPSS name such as Q1@A, a Stata name such as _merge. Until
# Session 362 Excel kept them as typed (backticks in every call) and
# read.csv() rewrote them its own way (X2024.score, Age..years.), and
# jload() said nothing of either. Ruling R9 (Jeff, S345): one rule for every
# outside format, letters, digits and underscores, the header kept as the
# variable label, a note listing each change, and never for .rds or .RData.
# Ruling R20 (Jeff, S362, on the import audit's recommendation): a name R
# accepts is never touched; only a name R cannot read bare is rewritten,
# and a rewritten name is kept to 32 characters (64 bytes), since it is new
# anyway. What each SAVE format refuses beyond that -- a Stata reserved
# word, a name longer than SPSS's 64 bytes, two names that differ only in
# case -- is jsave()'s check, .jst_save_name_problems(), with its own
# message and clean.names = TRUE.

#' Internal: the words R reserves
#'
#' A name equal to one of these cannot be used bare in R code (?Reserved),
#' although it passes the letters-digits-underscores test. make.names()
#' also catches them; the list is kept for the cleaner, which must not
#' produce one.
#' @keywords internal
.jst_r_reserved <- c("if", "else", "repeat", "while", "function", "for",
                     "in", "next", "break", "TRUE", "FALSE", "NULL", "Inf",
                     "NaN", "NA", "NA_integer_", "NA_real_", "NA_character_",
                     "NA_complex_")

#' Internal: can R read each name bare?
#'
#' TRUE for a name R code can use as it is: syntactic (make.names() leaves
#' it unchanged), not a reserved word, not "..." or "..1". Empty and NA are
#' FALSE. Duplicates are the caller's test.
#' @param x Character vector of names.
#' @return Logical vector of the same length.
#' @keywords internal
.jst_name_valid_r <- function(x) {
  ok <- !is.na(x) & nzchar(x)
  ok[ok] <- make.names(x[ok]) == x[ok] & !x[ok] %in% .jst_r_reserved &
    !grepl("^\\.\\.(\\.|[0-9]+)$", x[ok])
  ok
}

#' Internal: shorten a name to a character and a byte budget
#'
#' Cuts at a character, never inside one, then drops the underscores the
#' cut leaves at the end.
#' @param s Character(1).
#' @param max_chars,max_bytes The budgets.
#' @return Character(1).
#' @keywords internal
.jst_trunc_name <- function(s, max_chars = 32L, max_bytes = 64L) {
  if (nchar(s) > max_chars) s <- substr(s, 1L, max_chars)
  while (nchar(s, type = "bytes") > max_bytes) {
    s <- substr(s, 1L, nchar(s) - 1L)
  }
  sub("_+$", "", s)
}

#' Internal: one cleaned name
#'
#' The R9 rule: spaces and symbols at either end are dropped; any other run
#' of characters that are not letters, digits or underscores becomes one
#' underscore; nothing left gives V and the column's position (read.table's
#' form for an unnamed column); a name starting with a digit or an
#' underscore, or equal to a reserved word, gets an X; the result is kept
#' to the length budget. Letters are letters of any script (R, SPSS and
#' Stata take them); \code{ascii = TRUE} keeps A to Z alone, for SAS.
#'
#' @param x Character(1): the name as the file has it.
#' @param pos Its column position, for an empty result.
#' @param reserved A function of one name: TRUE when the target reserves it.
#' @param ascii Logical: letters A to Z only.
#' @param max_chars,max_bytes Length budget.
#' @return Character(1).
#' @keywords internal
.jst_clean_name <- function(x, pos, reserved = function(s) s %in% .jst_r_reserved,
                            ascii = FALSE, max_chars = 32L, max_bytes = 64L) {
  keep <- if (ascii) "A-Za-z0-9_" else "\\p{L}\\p{Nd}_"
  s <- if (is.na(x)) "" else x
  s <- gsub(paste0("^[^", keep, "]+|[^", keep, "]+$"), "", s, perl = TRUE)
  s <- gsub(paste0("[^", keep, "]+"), "_", s, perl = TRUE)
  s <- gsub("_{2,}", "_", s)
  if (!nzchar(s)) s <- paste0("V", pos)
  if (grepl("^[\\p{Nd}_]", s, perl = TRUE)) s <- paste0("X", s)
  if (reserved(s) || s %in% .jst_r_reserved) s <- paste0("X", s)
  s <- .jst_trunc_name(s, max_chars, max_bytes)
  # A letter R itself does not take in a name (rare scripts, or a locale
  # that is not UTF-8): fall back to A to Z, which every target takes.
  if (!.jst_name_valid_r(s) && !ascii) {
    return(.jst_clean_name(x, pos, reserved, ascii = TRUE, max_chars, max_bytes))
  }
  s
}

#' Internal: make a new name unique among names already taken
#'
#' Compared ignoring case, since SPSS and SAS fold case and a new name
#' costs nothing to keep clear of both: a taken name gets _2, _3 and so on,
#' the base shortened to leave room for the suffix.
#' @param s Character(1).
#' @param taken Character vector.
#' @param max_chars,max_bytes Length budget.
#' @return Character(1).
#' @keywords internal
.jst_unique_name <- function(s, taken, max_chars = 32L, max_bytes = 64L) {
  low <- tolower(taken)
  if (!tolower(s) %in% low) return(s)
  k <- 2L
  repeat {
    suf  <- paste0("_", k)
    cand <- paste0(.jst_trunc_name(s, max_chars - nchar(suf),
                                   max_bytes - nchar(suf)), suf)
    if (!tolower(cand) %in% low) return(cand)
    k <- k + 1L
  }
}

#' Internal: the names jload() gives the variables of a file from outside R
#'
#' Ruling R20: a name R can read bare, and not a repeat of an earlier one,
#' is never touched; every other name is cleaned (.jst_clean_name()) and
#' made unique among all the names. Used for every outside format, never
#' for .rds.
#' @param nm Character vector: the names as the file has them.
#' @return list(names, changed): the new names and which of them changed.
#' @keywords internal
.jst_clean_import_names <- function(nm) {
  nm[is.na(nm)] <- ""
  touched <- !.jst_name_valid_r(nm) | duplicated(nm)
  new   <- nm
  taken <- nm[!touched]
  for (i in which(touched)) {
    s <- .jst_unique_name(.jst_clean_name(nm[i], i), taken)
    new[i] <- s
    taken  <- c(taken, s)
  }
  list(names = new, changed = new != nm | touched)
}

#' Internal: the arrow lines of a rename note
#'
#' One line per changed name: the old name in double quotes (so an outer
#' space shows), padded to a column, then the new name, and an optional
#' third column. Two spaces always sit before the arrow, so the wrapper
#' reads each line as a layout line and passes it whole
#' (.jst_seg_category()).
#' @param old,new Character vectors.
#' @param why Optional character vector, a third column.
#' @return Character vector.
#' @keywords internal
.jst_rename_lines <- function(old, new, why = NULL) {
  q  <- paste0("\"", .jst_dq_escape(old), "\"")
  # The column fits the longest old name of up to 30 characters; a longer
  # one runs past it.
  w  <- max(c(0L, nchar(q)[nchar(q) <= 30L]))
  pad <- function(x, w) paste0(x, strrep(" ", pmax(0L, w - nchar(x))))
  out <- paste0("  ", pad(q, w), "  -> ", new)
  if (!is.null(why)) {
    w2  <- max(nchar(new))
    out <- paste0("  ", pad(q, w), "  -> ", pad(new, w2), "  (", why, ")")
  }
  out
}

#' Internal: the label sentence under a rename note
#' @param had Character vector, one per renamed variable: "own" (it had a
#'   label and keeps it), "given" (its old name is now its label) or "none"
#'   (its old name was empty, so it has no label).
#' @param where "" for jload(), " in the file" for jsave().
#' @return Character(1), possibly empty: no sentence when no renamed
#'   variable has a label.
#' @keywords internal
.jst_rename_label_line <- function(had, where = "") {
  had <- had[had != "none"]
  n   <- length(had)
  if (n == 0L) return("")
  if (!any(had == "own")) {
    if (n == 1L) paste0("The original name is the variable's label", where, ".")
    else paste0("The original names are the variables' labels", where, ".")
  } else if (all(had == "own")) {
    if (n == 1L) "The variable keeps the label it had."
    else "The variables keep the labels they had."
  } else {
    paste0("A variable with no label of its own has its original name as ",
           "its label", where, ".")
  }
}

#' Internal: rename a frame's variables, keeping each old name as a label
#'
#' A renamed variable with no label of its own is given its old name as its
#' variable label (the header kept, ruling R9); one with a label keeps it,
#' and the old name is in the note only. An empty old name gives no label.
#' @param df A data frame.
#' @param new The new names, one per variable.
#' @param changed Logical: which changed.
#' @return list(df, had): the renamed frame, and for each changed variable
#'   "own" (it had a label of its own), "given" (its old name is its label)
#'   or "none" (its old name was empty).
#' @keywords internal
.jst_apply_new_names <- function(df, new, changed) {
  old <- names(df)
  had <- character(0)
  for (i in which(changed)) {
    x   <- df[[i]]
    lab <- attr(x, "label", exact = TRUE)
    has <- is.character(lab) && length(lab) == 1L && !is.na(lab) &&
      nzchar(lab)
    kind <- "own"
    if (!has) {
      o <- trimws(old[i], whitespace = "[\\h\\v]")
      kind <- if (nzchar(o)) "given" else "none"
      if (nzchar(o)) {
        attr(x, "label") <- o
        df[[i]] <- x
      }
    }
    had <- c(had, kind)
  }
  names(df) <- new
  list(df = df, had = had)
}

#' Internal: jload()'s note on the names it changed
#' @param old,new The changed names, before and after.
#' @param had From .jst_apply_new_names().
#' @return Character(1).
#' @keywords internal
.jst_import_names_note <- function(old, new, had) {
  n <- length(old)
  lab <- .jst_rename_label_line(had)
  paste0("Note: ", n, " variable ", .jst_plural(n, "name was", "names were"),
         " changed to ", .jst_plural(n, "a valid R name", "valid R names"), ":\n",
         paste(.jst_rename_lines(old, new), collapse = "\n"),
         if (nzchar(lab)) paste0("\n", lab))
}

#' Internal: the names a save format refuses
#'
#' jsave()'s check before writing .sav, .dta or .xpt (the import audit's
#' third finding; Session 362). haven checks some rules and ReadStat others,
#' one name at a time, in haven's own words: a Stata save named only a long
#' name, then, fixed, "2024 score", then "Age (years)". This one check holds
#' each format's rules and reports every name at once, with the name it
#' would be given and why:
#' \describe{
#'   \item{sav}{haven's own test: a letter or @ first; letters, digits and
#'     . _ $ # @ after, not ending in a period; at most 64 bytes; not ALL AND
#'     BY EQ GE GT LE LT NE NOT OR TO WITH in any case; unique ignoring
#'     case.}
#'   \item{dta}{a letter or underscore first, letters, digits and
#'     underscores after; at most 32 characters; not a word Stata reserves
#'     (ReadStat's list, probed S362, and str followed by digits).}
#'   \item{xpt}{A to Z, digits and underscores, not a digit first; at most
#'     32 characters; not _N_, _ERROR_, _ALL_, _NUMERIC_ or _CHARACTER_;
#'     unique ignoring case (SAS folds case; haven writes both names).}
#' }
#' @param nm Character vector of names.
#' @param ext "sav", "dta" or "xpt".
#' @return data.frame(pos, old, new, why), one row per refused name; zero
#'   rows when every name can be written.
#' @keywords internal
.jst_save_name_problems <- function(nm, ext) {
  spss_res <- c("ALL", "AND", "BY", "EQ", "GE", "GT", "LE", "LT", "NE",
                "NOT", "OR", "TO", "WITH")
  stata_res <- c("_all", "_b", "byte", "_coef", "_cons", "double", "float",
                 "if", "in", "int", "long", "_n", "_N", "_pi", "_pred", "_rc",
                 "_skip", "strL", "using", "with")
  sas_res <- c("_N_", "_ERROR_", "_ALL_", "_NUMERIC_", "_CHARACTER_")
  fmt <- switch(ext, sav = "SPSS", dta = "Stata", xpt = "SAS")
  why <- rep(NA_character_, length(nm))
  for (i in seq_along(nm)) {
    s <- nm[i]
    why[i] <- switch(ext,
      sav = if (nchar(s, type = "bytes") > 64L) "longer than 64 bytes"
        else if (toupper(s) %in% spss_res) "a word SPSS reserves"
        else if (!grepl("^[\\p{L}@]", s, perl = TRUE)) "does not start with a letter"
        else if (grepl("\\.$", s)) "ends in a period"
        else if (!grepl("^[\\p{L}@][\\p{L}\\p{N}\\p{Sc}._$#@]*$", s, perl = TRUE))
          "holds a character SPSS does not take"
        else NA_character_,
      dta = if (nchar(s) > 32L) "longer than 32 characters"
        else if (s %in% stata_res || grepl("^str[0-9]+$", s)) "a word Stata reserves"
        else if (!grepl("^[\\p{L}_]", s, perl = TRUE))
          "does not start with a letter or underscore"
        else if (!grepl("^[\\p{L}_][\\p{L}\\p{N}_]*$", s, perl = TRUE))
          "holds a character Stata does not take"
        else NA_character_,
      xpt = if (nchar(s) > 32L) "longer than 32 characters"
        else if (toupper(s) %in% sas_res) "a name SAS reserves"
        else if (!grepl("^[A-Za-z_]", s)) "does not start with a letter or underscore"
        else if (!grepl("^[A-Za-z_][A-Za-z0-9_]*$", s))
          "holds a character SAS does not take"
        else NA_character_)
  }
  # SPSS and SAS fold case: of two names that differ only in case, the
  # later is refused.
  if (ext %in% c("sav", "xpt")) {
    low <- tolower(nm)
    dup <- duplicated(low) & is.na(why)
    for (i in which(dup)) {
      why[i] <- paste0(fmt, " reads it as ", nm[match(low[i], low)])
    }
  }
  bad <- which(!is.na(why))
  if (length(bad) == 0L) {
    return(data.frame(pos = integer(0), old = character(0), new = character(0),
                      why = character(0), stringsAsFactors = FALSE))
  }
  is_res <- switch(ext,
    sav = function(s) toupper(s) %in% spss_res,
    dta = function(s) s %in% stata_res || grepl("^str[0-9]+$", s),
    xpt = function(s) toupper(s) %in% sas_res)
  taken <- nm[-bad]
  new   <- character(length(bad))
  for (k in seq_along(bad)) {
    s <- .jst_clean_name(nm[bad[k]], bad[k], reserved = is_res,
                         ascii = identical(ext, "xpt"))
    s <- .jst_unique_name(s, taken)
    new[k] <- s
    taken  <- c(taken, s)
  }
  data.frame(pos = bad, old = nm[bad], new = new, why = why[bad],
             stringsAsFactors = FALSE)
}

#' Internal: jsave()'s pre-flight section for refused names
#' @param probs From .jst_save_name_problems().
#' @param ext The target.
#' @param data_name The data frame's name, for the prose.
#' @param line The jsave() call that saves with clean.names = TRUE.
#' @return Character(1).
#' @keywords internal
.jst_save_names_error_msg <- function(probs, ext, data_name, line) {
  fmt <- switch(ext, sav = "SPSS format (.sav)", dta = "Stata format (.dta)",
                xpt = "SAS interchange format (.xpt)")
  n <- nrow(probs)
  lines <- .jst_rename_lines(probs$old, probs$new, probs$why)
  if (length(lines) > 10L) {
    lines <- c(lines[1:10], paste0("  ...and ", length(lines) - 10L, " more"))
  }
  paste0(n, " variable ", .jst_plural(n, "name", "names"), " in the ",
         data_name, " data frame cannot be used in ", fmt, ":\n",
         paste(lines, collapse = "\n"), "\n",
         "To save the file with ", .jst_plural(n, "this name", "these names"),
         " (the ", data_name, " data frame keeps its own):\n",
         line)
}

#' Internal: jsave()'s note after clean.names = TRUE renamed in the file
#' @keywords internal
.jst_save_names_note <- function(old, new, had, ext, data_name) {
  fmt <- switch(ext, sav = "SPSS format (.sav)", dta = "Stata format (.dta)",
                xpt = "SAS interchange format (.xpt)")
  n <- length(old)
  lab <- .jst_rename_label_line(had, " in the file")
  paste0("Note: ", n, " variable ", .jst_plural(n, "name was", "names were"),
         " changed in the file to ", .jst_plural(n, "a name", "names"), " ",
         fmt, " takes; the ", data_name, " data frame keeps its own:\n",
         paste(.jst_rename_lines(old, new), collapse = "\n"),
         if (nzchar(lab)) paste0("\n", lab))
}

#' Internal: the SAS name of the dataset inside an .xpt file
#'
#' haven::write_xpt() names the dataset after the file it writes, and
#' jsave() writes a temporary file first, so every .xpt jsave() made until
#' Session 362 named its dataset jsave_<stem>_<hex>, and a file name over
#' about 13 characters stopped the save ("`name` must be 32 characters or
#' fewer"). The dataset is named after the file the user asked for, cleaned
#' to a SAS name: A to Z, digits and underscores, a letter or underscore
#' first, at most 32 characters.
#' @param stem The file name without its extension.
#' @return Character(1).
#' @keywords internal
.jst_sas_member_name <- function(stem) {
  if (grepl("^[A-Za-z_][A-Za-z0-9_]*$", stem) && nchar(stem) <= 32L) return(stem)
  .jst_clean_name(stem, 1L, reserved = function(s) FALSE, ascii = TRUE)
}

#' Internal: labels a save format would shorten
#'
#' Measured S362 through haven 2.5.4: .sav keeps 256 bytes of a variable
#' label and 120 of a value label, cutting between characters; .dta writes
#' 321 bytes of a variable label and can cut INSIDE a character, leaving
#' text that is not valid UTF-8, while Stata's documented limit is 80
#' characters; .xpt keeps them whole. A data frame's own label is refused
#' by haven past 80 characters (.dta) and 40 (.xpt). So jsave() shortens
#' itself, between characters, what .dta and the frame labels need, lets
#' .sav cut, and says what was shortened in either case.
#' @param data The data frame as it will be written.
#' @param ext The target.
#' @return list(data, vars, values, frame): the data with what jsave()
#'   shortens itself shortened; the variables whose variable label is cut;
#'   the variables with a value label cut; whether the frame's label is.
#' @keywords internal
.jst_save_label_limits <- function(data, ext) {
  cut_chars <- function(s, n) if (nchar(s) > n) substr(s, 1L, n) else s
  vars <- character(0); values <- character(0); frame <- FALSE
  if (!ext %in% c("sav", "dta", "xpt")) {
    return(list(data = data, vars = vars, values = values, frame = frame))
  }
  for (v in names(data)) {
    x   <- data[[v]]
    lab <- attr(x, "label", exact = TRUE)
    if (is.character(lab) && length(lab) == 1L && !is.na(lab)) {
      if (ext == "sav" && nchar(lab, type = "bytes") > 256L) vars <- c(vars, v)
      if (ext == "dta" && nchar(lab) > 80L) {
        vars <- c(vars, v)
        attr(x, "label") <- cut_chars(lab, 80L)
        data[[v]] <- x
      }
    }
    if (ext == "sav") {
      vl <- names(attr(x, "labels", exact = TRUE))
      if (length(vl) && any(nchar(vl, type = "bytes") > 120L)) {
        values <- c(values, v)
      }
    }
  }
  flab <- attr(data, "label", exact = TRUE)
  lim  <- switch(ext, dta = 80L, xpt = 40L, NA_integer_)
  if (!is.na(lim) && is.character(flab) && length(flab) == 1L &&
      !is.na(flab) && nchar(flab) > lim) {
    attr(data, "label") <- cut_chars(flab, lim)
    frame <- TRUE
  }
  list(data = data, vars = vars, values = values, frame = frame)
}

#' Internal: jsave()'s note on labels shortened in the file
#' @keywords internal
.jst_save_labels_note <- function(lim, ext, data_name) {
  fmt <- switch(ext, sav = "SPSS format (.sav)", dta = "Stata format (.dta)",
                xpt = "SAS interchange format (.xpt)")
  rule <- switch(ext,
    sav = "keeps 256 bytes of a variable label and 120 of a value label (fewer letters when they are accented)",
    dta = "keeps 80 characters of a variable label and of the data frame's label",
    xpt = "keeps 40 characters of the data frame's label")
  parts <- character(0)
  if (length(lim$vars)) {
    parts <- c(parts, paste0("the variable ",
                             .jst_plural(length(lim$vars), "label", "labels"),
                             " of ", .jst_format_var_list(lim$vars, and = TRUE)))
  }
  if (length(lim$values)) {
    parts <- c(parts, paste0("value labels of ",
                             .jst_format_var_list(lim$values, and = TRUE)))
  }
  if (isTRUE(lim$frame)) parts <- c(parts, "the data frame's own label")
  n_lab <- length(lim$vars) + length(lim$values) + isTRUE(lim$frame)
  paste0("Note: ", fmt, " ", rule, ".\n",
         "Shortened in the file: ", .jst_and_list(parts), ".\n",
         "The ", data_name, " data frame keeps ",
         .jst_plural(n_lab, "it", "them"), " whole.")
}

#' Internal: the shape of a CSV file, checked before it is read
#'
#' read.csv() decides how many variables a file has from its first line and
#' its first five lines, and two shapes go wrong without a word (the import
#' audit, Session 362): a first line with FEWER fields than the lines below
#' it -- a title above the names, a missing name, a semicolon file from
#' European Excel -- makes the first values of every line row names, which
#' jload() then drops, or stops on R's "more columns than column names"; and
#' a line further down with MORE fields than the first is split into two
#' cases. Every line's fields are counted first (count.fields(), quoting as
#' read.csv() quotes), and those shapes stop here, saying what the file
#' holds and what to do. A line with fewer fields than the first is read as
#' it always was, its last cells empty.
#'
#' Read with header = FALSE (ruling R21, Session 365) a file has no names
#' line to measure the others against: every line is a case, measured
#' against the count most lines hold. A line holding more stops, as a line
#' longer than the names line does; a shorter one is read with its last
#' cells empty; the title search, which looks for a names line, is not
#' made. The count is returned, and jload() reads that many variables
#' (col.names), so a long line past the first five -- the lines read.csv()
#' counts -- could not be split even if one got through.
#'
#' @param path The file.
#' @param skip Lines skipped above the names.
#' @param enc NULL, or the encoding the file is read in.
#' @param shown The file's name for the prose.
#' @param line_for jload()'s line builder: \code{line_for(skip = 2)} gives
#'   the jload() call that reads the file with skip = 2.
#' @param obj_name The data frame's name, for the read.csv2() line.
#' @param header As jload() reads the file.
#' @return Invisibly: with header = FALSE the number of values most lines
#'   hold (NULL when the lines could not be counted); otherwise NULL. Or
#'   stops.
#' @keywords internal
.jst_csv_check_shape <- function(path, skip, enc, shown, line_for, obj_name,
                                 header = TRUE) {
  open_con <- function() if (is.null(enc)) file(path) else file(path, encoding = enc)
  # count.fields() gives NULL when skip = passes the last line; a file it
  # cannot read at all is left to read.csv() and its own message.
  cf <- tryCatch(utils::count.fields(open_con(), sep = ",", quote = "\"",
                                     skip = skip, blank.lines.skip = FALSE,
                                     comment.char = ""),
                 error = function(e) FALSE)
  if (identical(cf, FALSE)) return(invisible(NULL))
  if (length(cf) == 0L || all(cf %in% 0L)) {
    .jst_stop("skip = ", skip, " skips every line of ", shown, ".")
  }
  first <- which(!is.na(cf) & cf > 0L)[1L]
  hdr   <- cf[first]
  body  <- cf[seq_along(cf) > first]
  known <- body[!is.na(body) & body > 0L]
  lines <- tryCatch(readLines(open_con(), n = skip + first + 20L, warn = FALSE),
                    error = function(e) character(0))
  hdr_text <- if (length(lines) >= skip + first) lines[skip + first] else ""
  # A semicolon file (European Excel): its names line counts more fields
  # split at semicolons than at commas, quoted names read as read.csv2()
  # reads them, so a semicolon inside a quoted name is not a separator.
  n_semi <- length(tryCatch(scan(text = hdr_text, what = "", sep = ";",
                                 quote = "\"", quiet = TRUE,
                                 na.strings = character(0)),
                            error = function(e) character(0)))
  if (n_semi >= 2L && n_semi > hdr) {
    path_shown <- sub("^\\./", "", gsub("\\", "/", path, fixed = TRUE))
    .jst_stop(shown, " separates its values with semicolons, as Excel does ",
              "in many European settings.\n",
              "jload() reads files whose values are separated by commas.\n",
              "Save it from Excel as an .xlsx file and load that, or read it ",
              "with base R:\n",
              "  ", obj_name, " <- read.csv2(\"", .jst_dq_escape(path_shown), "\"",
              # Since Session 365 the call's skip = and header = FALSE.
              if (skip > 0L) paste0(", skip = ", skip),
              if (!header) ", header = FALSE", ")")
  }
  if (!header) {
    every <- cf[!is.na(cf) & cf > 0L]
    tab   <- table(every)
    modal <- as.integer(names(tab)[which.max(tab)])
    long  <- which(!is.na(cf) & cf > modal)
    if (length(long) == 1L) {
      .jst_stop("line ", skip + long, " of ", shown, " holds ", cf[long],
                " values, but most lines hold ", modal, ", so R would split ",
                "it into two cases.\n",
                "Correct that line of the file, then run jload() again.")
    }
    if (length(long) > 1L) {
      .jst_stop("lines ", .jst_short_list(skip + long), " of ", shown,
                " hold more values than most lines (", modal, "), so R would ",
                "split each into two cases.\n",
                "Correct those lines of the file, then run jload() again.")
    }
    return(invisible(modal))
  }
  if (length(known) == 0L || !any(known > hdr)) return(invisible(NULL))
  tab   <- table(known)
  modal <- as.integer(names(tab)[which.max(tab)])
  line_no <- function(i) skip + first + i
  if (hdr < modal) {
    # A title above the names: a later line, among the first twenty, with
    # the common count and words in every field.
    cand <- NA_integer_
    for (i in seq_len(min(20L, length(body)))) {
      if (is.na(body[i]) || body[i] != modal) next
      txt <- lines[line_no(i)]
      if (is.na(txt)) next
      f <- tryCatch(scan(text = txt, what = "", sep = ",", quote = "\"",
                         quiet = TRUE, na.strings = character(0)),
                    error = function(e) character(0))
      f <- trimws(f)
      if (length(f) == modal && all(nzchar(f)) &&
          all(is.na(suppressWarnings(as.numeric(f))))) {
        cand <- i
        break
      }
    }
    if (!is.na(cand)) {
      at <- line_no(cand)
      .jst_stop("the first line of ", shown, " holds ", hdr, " ",
                .jst_plural(hdr, "value", "values"), ", but most lines below ",
                "it hold ", modal, ".\n",
                "The variable names seem to be on line ", at, ".\n",
                "To read from there, skip the ", at - 1L, " ",
                .jst_plural(at - 1L, "line", "lines"), " above them:\n",
                line_for(skip = at - 1L))
    }
    .jst_stop("the first line of ", shown, " has ", hdr, " ",
              .jst_plural(hdr, "name", "names"), ", but most lines below it ",
              "hold ", modal, " values.\n",
              "Add the missing ", .jst_plural(modal - hdr, "name", "names"),
              " to the first line of the file, then run jload() again.")
  }
  long <- which(!is.na(body) & body > hdr)
  at   <- line_no(long)
  n    <- length(at)
  shown_at <- if (n > 5L) {
    paste0(paste(at[1:5], collapse = ", "), " and ", n - 5L, " more")
  } else .jst_and_list(as.character(at))
  if (n == 1L) {
    .jst_stop("line ", at, " of ", shown, " holds ", body[long], " values, but ",
              "the first line has ", hdr, " ", .jst_plural(hdr, "name", "names"),
              ", so R would split it into two cases.\n",
              "Correct that line of the file, then run jload() again.")
  }
  .jst_stop("lines ", shown_at, " of ", shown, " hold more values than the ",
            "first line has names (", hdr, "), so R would split each into ",
            "two cases.\n",
            "Correct those lines of the file, then run jload() again.")
}

#' Internal: the encoding a CSV file is read in
#'
#' R reads a CSV file as UTF-8. One saved by Excel on Windows as "CSV (Comma
#' delimited)" is in Windows-1252, and a single accented letter or curly
#' apostrophe in it stopped jload() on R's "invalid multibyte string" (the
#' import audit, Session 362). A file whose bytes are valid UTF-8 (a mark at
#' the start included) is read as R reads it; any other is read as
#' Windows-1252, or, when even that cannot read it, as Latin-1, which
#' reads every byte.
#' @param path The file.
#' @return NULL for UTF-8, else "CP1252" or "latin1".
#' @keywords internal
.jst_csv_encoding <- function(path) {
  b <- tryCatch(readBin(path, "raw", file.size(path)), error = function(e) raw(0))
  if (length(b) == 0L) return(NULL)
  if (!is.na(iconv(list(b), "UTF-8", "UTF-8"))) return(NULL)
  if (!is.na(iconv(list(b), "CP1252", "UTF-8"))) "CP1252" else "latin1"
}

#' Internal: write a CSV file that Excel opens as written
#'
#' jsave()'s CSV writer (Session 362). R writes a CSV file in UTF-8, and
#' Excel on Windows opens one that does not start with the UTF-8 byte-order
#' mark in Windows-1252, so every accented letter, curly apostrophe or dash
#' came up as two or three other characters (Jeff's check of the import
#' audit's item 21). When the file holds a byte beyond ASCII and every line
#' of it is valid UTF-8, the three bytes of the mark (EF BB BF) go first,
#' as Excel's own "CSV UTF-8" writes them. A file of ASCII alone is written
#' as before, byte for byte, and so is one holding text that is not UTF-8
#' (a string read in another encoding and never converted), which the mark
#' would misdescribe. The file is written as write.csv() writes it, with no
#' re-encoding: asking R for UTF-8 output in a session that is not UTF-8
#' cut each accented word short. jload() reads the mark as the start of a
#' UTF-8 file (.jst_csv_encoding(); read.csv() discards it).
#' @param data The data frame, as jsave() writes it.
#' @param path The file to write (jsave()'s temporary file).
#' @return The path, invisibly.
#' @keywords internal
.jst_write_csv <- function(data, path) {
  utils::write.csv(data, path, row.names = FALSE, na = "")
  if (identical(.jst_file_text_kind(path), "utf8")) {
    marked <- paste0(path, ".bom")
    on.exit(unlink(marked))
    writeBin(as.raw(c(0xef, 0xbb, 0xbf)), marked)
    if (!isTRUE(file.append(marked, path)) || !file.remove(path) ||
        !file.rename(marked, path)) {
      stop("Could not finish writing the file.", call. = FALSE)
    }
  }
  invisible(path)
}

#' Internal: what kind of text a file holds
#'
#' Read 50,000 lines at a time, so a large CSV file is never held whole, and
#' by lines, so no character is split between two pieces (Session 362;
#' .jst_write_csv()).
#' @param path The file.
#' @return "ascii" (no byte above 0x7F), "utf8" (some, and every line valid
#'   UTF-8) or "other".
#' @keywords internal
.jst_file_text_kind <- function(path) {
  con <- file(path, "rb")
  on.exit(close(con))
  beyond <- FALSE
  repeat {
    ln <- readLines(con, n = 50000L, warn = FALSE)
    if (!length(ln)) break
    if (!all(validUTF8(ln))) return("other")
    if (!beyond) beyond <- any(grepl("[\\x80-\\xff]", ln, perl = TRUE,
                                     useBytes = TRUE))
  }
  if (beyond) "utf8" else "ascii"
}

#' Internal: a title row above an Excel sheet's names
#'
#' Ruling R9 part (2): a sheet whose first row is a title loads the title as
#' a variable name, the real names as a case and every column as text, and
#' readxl said only "New names:". When at most half the columns of the
#' first row read have a name, the first twenty rows are read again as
#' they stand (range =, which keeps empty rows, so the row numbers are the
#' sheet's) and, when a later row holds words in at least half the columns
#' and in every cell it fills, it is offered as the names: the row, and the
#' skip = call that reads from it. A note, not a stop: one unnamed column
#' is common and legitimate, and nothing is offered then.
#' @param path,sheet,skip As jload() reads the sheet.
#' @param nm The names read.
#' @return NULL, or list(title, names): the sheet rows of the title and of
#'   the names.
#' @keywords internal
.jst_excel_title_row <- function(path, sheet, skip, nm) {
  k <- length(nm)
  if (k < 2L || sum(nzchar(trimws(nm))) * 2L > k) return(NULL)
  rows <- tryCatch(suppressMessages(suppressWarnings(readxl::read_excel(
    path, sheet = if (is.null(sheet)) 1L else sheet, col_names = FALSE,
    col_types = "list", range = readxl::cell_rows(c(skip + 1L, skip + 21L)),
    .name_repair = "minimal"))), error = function(e) NULL)
  if (is.null(rows) || nrow(rows) < 2L) return(NULL)
  filled <- function(r) {
    vals <- lapply(rows, function(col) col[[r]])
    ok   <- !vapply(vals, function(v) is.null(v) || length(v) == 0L ||
                      (length(v) == 1L && is.na(v)), logical(1))
    list(n = sum(ok), text = all(vapply(vals[ok], function(v)
      is.character(v) && nzchar(trimws(v)) &&
        is.na(suppressWarnings(as.numeric(v))), logical(1))))
  }
  firsts <- which(vapply(seq_len(nrow(rows)), function(r) filled(r)$n > 0L,
                         logical(1)))
  if (length(firsts) < 2L) return(NULL)
  for (r in firsts[-1L]) {
    f <- filled(r)
    if (f$n * 2L >= ncol(rows) && f$n >= 2L && f$text) {
      return(list(title = skip + firsts[1L], names = skip + r))
    }
  }
  NULL
}

# -- What a file holds that may not be data (Session 365) ----------------------
#
# Fix Slate 12, the import audit's items 14 and 17 (S362), with ruling R21.
# A CSV file or a sheet with no names row lost its first case to the names,
# which were then numbers ("1" -> X1), and a sheet's blank rows, blank
# columns and footnote lines -- and a CSV file's line of commas, trailing
# comma and write.csv() row numbers -- loaded as cases and variables; jload()
# said nothing of either. Each now gets a consequential note; nothing is
# dropped (Jeff's S362 lean: "a note naming them; nothing dropped").

#' Internal: does each string read as a number?
#'
#' TRUE for text that is a number as written: digits with an optional sign,
#' decimal point and exponent ("7", "-2.5", "1e3", ".5"), spaces around it
#' allowed. "Inf", "NA", "1,000" and "50\%" are not. Used by the no-header
#' note and the stray-parts note (Session 365).
#' @param x Character vector.
#' @return Logical vector; NA and "" are FALSE.
#' @keywords internal
.jst_is_number_text <- function(x) {
  x <- trimws(as.character(x))
  !is.na(x) & grepl("^[-+]?([0-9]+\\.?[0-9]*|\\.[0-9]+)([eE][-+]?[0-9]+)?$", x)
}

#' Internal: are the names read from a file all numbers?
#'
#' The S362 import audit's item 14: a CSV file or a sheet with no names row
#' loses its first case to the names, which are then numbers. TRUE when
#' every name that is not empty reads as a number and at least one does. An
#' empty name does not count against it: a first case with a missing value
#' has one (1,,3).
#' @param nm Character vector: the names as read.
#' @return TRUE or FALSE.
#' @keywords internal
.jst_names_all_numbers <- function(nm) {
  nm <- trimws(ifelse(is.na(nm), "", nm), whitespace = "[\\h\\v]")
  full <- nzchar(nm)
  any(full) && all(.jst_is_number_text(nm[full]))
}

#' Internal: a list of at most five, then a count
#'
#' "4", "4 and 7", "4, 7, and 9" up to \code{max_show}; past it, "4, 7, 9,
#' 12, 15 and 3 more" -- the CSV shape check's form for the lines it names.
#' @param x A vector.
#' @param max_show How many to name.
#' @return Character(1).
#' @keywords internal
.jst_short_list <- function(x, max_show = 5L) {
  x <- as.character(x)
  n <- length(x)
  if (n <= max_show) return(.jst_and_list(x))
  paste0(paste(x[seq_len(max_show)], collapse = ", "), " and ", n - max_show,
         " more")
}

#' Internal: jload()'s note on names that are all numbers
#'
#' Session 365 (the S362 audit's item 14; ruling R21): the names read from
#' the file are all numbers, so the line or row they came from may be the
#' first case. The names as read, then the jload() call with header =
#' FALSE, which reads that line as a case.
#' @param shown The file's name.
#' @param nm The names as read.
#' @param sheet_file TRUE for an Excel file ("row"), FALSE for CSV ("line").
#' @param line The jload() call with header = FALSE.
#' @return Character(1).
#' @keywords internal
.jst_no_header_note <- function(shown, nm, sheet_file, line) {
  nm  <- trimws(ifelse(is.na(nm), "", nm), whitespace = "[\\h\\v]")
  k   <- length(nm)
  shw <- ifelse(nzchar(nm), nm, "\"\"")
  shw <- if (k <= 6L) paste(shw, collapse = ", ") else {
    paste0(paste(shw[1:6], collapse = ", "), " and ", k - 6L, " more")
  }
  v   <- paste0("V", seq_len(k))
  unit <- if (sheet_file) "row" else "line"
  paste0("Note: ", if (k == 1L) "the variable name" else "every variable name",
         " read from ", shown, " is a number",
         if (any(!nzchar(nm))) " or empty", " (", shw,
         "), so the ", unit, " ", if (k == 1L) "it" else "they",
         " came from may be the first case rather than ",
         if (k == 1L) "a name" else "the names", ".\n",
         "To read that ", unit, " as a case, with the ",
         if (k == 1L) "variable" else "variables", " named ",
         if (k <= 3L) .jst_and_list(v) else paste0("V1 to V", k), ":\n",
         line)
}

#' Internal: an Excel column's letters
#' @param j Column numbers.
#' @return Character vector: "A", "Z", "AA", ...
#' @keywords internal
.jst_excel_col_letters <- function(j) {
  vapply(j, function(x) {
    s <- ""
    while (x > 0) {
      r <- (x - 1) %% 26
      s <- paste0(LETTERS[r + 1], s)
      x <- (x - 1) %/% 26
    }
    s
  }, character(1), USE.NAMES = FALSE)
}

#' Internal: where an Excel sheet's data begin
#'
#' readxl starts at the first row after skip = that holds anything and at
#' the leftmost column that does, so a case's row and a variable's column
#' in the sheet are counted from there (Session 365, for the stray-parts
#' note). The first 200 rows after skip = are read as cells (col_types =
#' "list", as .jst_excel_title_row() reads them); the columns left of the
#' one they start in are then read down the whole sheet, since one cell
#' there moves readxl's start.
#' @param path,sheet,skip As jload() read the sheet.
#' @return list(row, col): the sheet row and column of the first cell
#'   readxl read; NULL when it cannot be found.
#' @keywords internal
.jst_excel_origin <- function(path, sheet, skip) {
  sh <- if (is.null(sheet)) 1L else sheet
  rd <- function(range) {
    tryCatch(suppressMessages(suppressWarnings(readxl::read_excel(
      path, sheet = sh, col_names = FALSE, col_types = "list", range = range,
      .name_repair = "minimal"))), error = function(e) NULL)
  }
  full <- function(v) !(is.null(v) || length(v) == 0L ||
                          (length(v) == 1L && is.na(v)))
  cells <- function(tb) {
    matrix(vapply(tb, function(col) vapply(col, full, logical(1)),
                  logical(nrow(tb))), nrow = nrow(tb))
  }
  win <- rd(readxl::cell_limits(c(skip + 1L, 1L), c(skip + 200L, NA)))
  if (is.null(win) || nrow(win) == 0L || ncol(win) == 0L) return(NULL)
  m  <- cells(win)
  r0 <- which(rowSums(m) > 0L)[1L]
  if (is.na(r0)) return(NULL)
  c0 <- which(colSums(m) > 0L)[1L]
  if (c0 > 1L) {
    left <- rd(readxl::cell_limits(c(skip + 1L, 1L), c(NA, c0 - 1L)))
    if (!is.null(left) && nrow(left) > 0L && ncol(left) > 0L) {
      cl <- which(colSums(cells(left)) > 0L)
      if (length(cl)) c0 <- cl[1L]
    }
  }
  list(row = skip + r0, col = c0)
}

#' Internal: are some cells of an Excel column numbers?
#'
#' A column holding numbers and one text cell is read as text, and readxl
#' gives its numbers back as their digits; so are numbers stored as text in
#' Excel. Only the cells say which (Session 365: the stray-parts note says
#' the footnotes made a variable text only when its other cells are
#' numbers).
#' @param path,sheet As jload() read the sheet.
#' @param rows,col The sheet rows and the column.
#' @return TRUE when every one is a number cell.
#' @keywords internal
.jst_excel_cells_numeric <- function(path, sheet, rows, col) {
  if (!length(rows)) return(FALSE)
  tb <- tryCatch(suppressMessages(suppressWarnings(readxl::read_excel(
    path, sheet = if (is.null(sheet)) 1L else sheet, col_names = FALSE,
    col_types = "list",
    range = readxl::cell_limits(c(min(rows), col), c(max(rows), col)),
    .name_repair = "minimal"))), error = function(e) NULL)
  if (is.null(tb) || ncol(tb) != 1L) return(FALSE)
  v <- tb[[1L]][rows - min(rows) + 1L]
  all(vapply(v, function(x) is.numeric(x) && length(x) == 1L && !is.na(x),
             logical(1)))
}

#' Internal: the line of a CSV file each case starts on
#'
#' count.fields() gives each line's number of values: NA for a line whose
#' quoted value carries on to the next, the count on the line a case ends
#' on, and 0 for an empty line, which read.csv() skips between cases. A
#' case starts on the first line after the last case ended that is not
#' empty (Session 365, for the stray-parts note).
#' @param path,skip,enc As jload() read the file.
#' @param header TRUE when the first case is the names line.
#' @return Integer vector: the line of the file each case starts on; NULL
#'   when the lines cannot be counted.
#' @keywords internal
.jst_csv_case_lines <- function(path, skip, enc, header) {
  con <- if (is.null(enc)) file(path) else file(path, encoding = enc)
  cf <- tryCatch(utils::count.fields(con, sep = ",", quote = "\"", skip = skip,
                                     blank.lines.skip = FALSE,
                                     comment.char = ""),
                 error = function(e) NULL)
  if (is.null(cf) || !length(cf)) return(NULL)
  ends <- which(!is.na(cf) & cf > 0L)
  if (!length(ends)) return(NULL)
  used <- which(is.na(cf) | cf > 0L)
  prev <- c(0L, ends[-length(ends)])
  starts <- used[findInterval(prev, used) + 1L]
  if (header) starts <- starts[-1L]
  skip + starts
}

#' Internal: rows and columns of a file that may not be data
#'
#' Session 365 (the S362 audit's item 17): an Excel sheet's blank rows,
#' blank columns and footnote lines, and their CSV kin -- a line of commas,
#' a trailing comma's column, the row numbers write.csv() writes -- loaded
#' as cases and variables, and nothing said so. Found here on the data as
#' read and the names as the file has them; nothing is dropped. A cell is
#' empty when it is NA, or text of nothing but spaces.
#' \describe{
#'   \item{rows}{cases with nothing in them, in data of two or more
#'     variables (in a one-column file an empty line is a case with a
#'     missing value, Session 351); with row numbers, the other variables}
#'   \item{notes}{the last cases, below the data, with text that is not a
#'     number in the first variable and nothing in the others}
#'   \item{cols}{variables with no name and nothing in them (with header =
#'     FALSE, nothing in them)}
#'   \item{rownum}{1 when the first variable has no name and holds 1 to n
#'     in order, n of 2 or more, as write.csv()'s row names do}
#'   \item{rest}{the other cases with something in the first variable}
#'   \item{text_col}{TRUE when every one of those reads as a number, so the
#'     notes are why the first variable is text}
#' }
#' @param df The data frame as read.
#' @param nm The names as the file has them.
#' @param header As jload() read the file.
#' @return list(rows, notes, cols, rownum, rest, text_col, n), n the number
#'   of cases.
#' @keywords internal
.jst_import_stray_parts <- function(df, nm, header = TRUE) {
  n <- nrow(df); k <- ncol(df)
  out <- list(rows = integer(0), notes = integer(0), cols = integer(0),
              rownum = 0L, rest = integer(0), text_col = FALSE, n = n)
  if (n == 0L || k == 0L) return(out)
  ws <- "[\\h\\v]"
  # Which cells are empty. Text is tested for spaces only where it starts
  # with one, since this runs on every CSV and Excel load (a 1.9-million-
  # row file: a second when every cell went through trimws()).
  empty <- function(x) {
    if (is.list(x)) return(rep(FALSE, length(x)))
    e <- is.na(x)
    if (is.character(x)) {
      e <- e | !nzchar(x)
      s <- which(!e)
      if (length(s)) {
        sp <- s[grepl("^[\\h\\v]", x[s], perl = TRUE)]
        if (length(sp)) e[sp] <- !nzchar(trimws(x[sp], whitespace = ws))
      }
    }
    as.vector(e)
  }
  all_empty <- function(x) {
    head_n <- min(length(x), 50L)
    all(empty(x[seq_len(head_n)])) && all(empty(x))
  }
  nm <- trimws(ifelse(is.na(nm), "", nm), whitespace = ws)
  no_name <- if (header) which(!nzchar(nm)) else seq_len(k)
  out$cols <- no_name[vapply(no_name, function(j) all_empty(df[[j]]),
                             logical(1))]
  x1 <- df[[1L]]
  if (header && 1L %in% no_name && n >= 2L && k >= 2L) {
    in_order <- if (is.numeric(x1)) {
      !anyNA(x1) && x1[n] == n && all(x1 == seq_len(n))
    } else if (is.character(x1)) {
      identical(trimws(x1[n]), as.character(n)) &&
        identical(trimws(x1), as.character(seq_len(n)))
    } else FALSE
    if (isTRUE(in_order)) out$rownum <- 1L
  }
  if (k < 2L) return(out)
  # Empty rows: the candidates narrowed one variable at a time, those that
  # are not text first, so the first variable with data rules out nearly
  # every row.
  use  <- if (out$rownum == 1L) seq_len(k)[-1L] else seq_len(k)
  use  <- use[order(vapply(df[use], is.character, logical(1)))]
  cand <- seq_len(n)
  for (j in use) {
    cand <- cand[empty(df[[j]][cand])]
    if (!length(cand)) break
  }
  out$rows <- cand
  if (out$rownum == 1L || !is.character(x1)) return(out)
  # Footnotes: from the last case up, past empty cases, while the first
  # variable holds text that is not a number and the others hold nothing.
  is_blank <- logical(n)
  is_blank[cand] <- TRUE
  others <- df[-1L]
  note_like <- function(i) {
    !empty(x1[i]) && !.jst_is_number_text(x1[i]) &&
      all(vapply(others, function(x) empty(x[i]), logical(1)))
  }
  notes <- integer(0)
  i <- n
  while (i >= 1L) {
    if (is_blank[i]) { i <- i - 1L; next }
    if (note_like(i)) { notes <- c(i, notes); i <- i - 1L; next }
    break
  }
  if (i >= 1L && length(notes)) {
    out$notes <- notes
    out$rest  <- setdiff(which(!empty(x1)), notes)
    out$text_col <- length(out$rest) > 0L &&
      all(.jst_is_number_text(x1[out$rest]))
  }
  out
}

#' Internal: jload()'s note on rows and columns that may not be data
#'
#' Session 365 (the S362 audit's item 17). One sentence for each kind found
#' (Rule E): the empty rows, the footnotes (and the variable they made
#' text), the empty columns, the row numbers; each by its place in the file
#' (an Excel row or column letter, a CSV line or column number) with the
#' case numbers or the variable names in parentheses, or, when the place
#' cannot be counted, by the cases and variables alone. Then that they were
#' read as data and nothing was removed, and the way to leave them out.
#' @param parts From .jst_import_stray_parts(), text_col settled.
#' @param vars The variables' names, as loaded.
#' @param shown The file's name.
#' @param sheet_file TRUE for an Excel file, FALSE for CSV.
#' @param case_pos NULL, or each case's row or line in the file.
#' @param col_pos NULL, or each variable's column in the file.
#' @param header As jload() read the file.
#' @param data_name The data frame's name, for the fallback.
#' @return Character(1), or NULL when nothing was found.
#' @keywords internal
.jst_stray_parts_note <- function(parts, vars, shown, sheet_file, case_pos,
                                  col_pos, header, data_name) {
  n_items <- length(parts$rows) + length(parts$notes) + length(parts$cols) +
    parts$rownum
  if (n_items == 0L) return(NULL)
  unit  <- if (sheet_file) "row" else "line"
  first <- TRUE
  cap1  <- function(s) paste0(toupper(substr(s, 1L, 1L)), substring(s, 2L))
  where <- function(idx, kind) {
    m <- length(idx)
    at <- if (identical(kind, "case")) case_pos else col_pos
    own <- if (identical(kind, "case")) {
      paste0(.jst_plural(m, "case", "cases"), " ", .jst_short_list(idx))
    } else .jst_short_list(vars[idx])
    s <- if (!is.null(at)) {
      paste0(.jst_plural(m, if (identical(kind, "case")) unit else "column",
                         if (identical(kind, "case")) paste0(unit, "s") else "columns"),
             " ", .jst_short_list(at[idx]),
             if (first) paste0(" of ", shown), " (", own, ")")
    } else {
      paste0(own, if (first) paste0(" of the ", data_name, " data frame"))
    }
    s <- if (first) s else cap1(s)
    first <<- FALSE
    s
  }
  out <- character(0)
  if (length(parts$rows)) {
    m <- length(parts$rows)
    out <- c(out, paste0(where(parts$rows, "case"), " ",
                         if (m == 1L) "is" else "are", " empty."))
  }
  if (length(parts$notes)) {
    m <- length(parts$notes)
    out <- c(out, paste0(where(parts$notes, "case"), " ",
                         if (m == 1L) "has" else "have",
                         " text in the first column only, below the data, so ",
                         if (m == 1L) "it may be a footnote." else "they may be footnotes."))
    if (isTRUE(parts$text_col)) {
      out <- c(out, paste0("Because of ", if (m == 1L) "it" else "them", ", ",
                           vars[1L], " was read as text."))
    }
  }
  if (length(parts$cols)) {
    m <- length(parts$cols)
    out <- c(out, paste0(where(parts$cols, "col"), " ",
                         if (!header) {
                           if (m == 1L) "is empty." else "are empty."
                         } else if (m == 1L) {
                           "has no name and is empty."
                         } else "have no names and are empty."))
  }
  if (parts$rownum == 1L) {
    out <- c(out, paste0(where(1L, "col"),
                         " has no name and holds the numbers 1 to ", parts$n,
                         " in order, so it may be row numbers, as R's ",
                         "write.csv() writes them."))
  }
  one <- n_items == 1L
  out <- c(out,
           paste0(if (one) "It was" else "They were", " read as data, and ",
                  "nothing was removed."),
           paste0("To leave ", if (one) "it" else "them", " out, delete ",
                  if (one) "it" else "them",
                  " from the file and load the file again."))
  paste0("Note: ", paste(out, collapse = "\n"))
}

#' Internal: a data frame's name made from a file's name
#'
#' The same cleaner as a variable's name (lean 10 of the import audit,
#' Session 362), with no length budget: "My Survey (final).xlsx" loads as
#' My_Survey_final, where make.names() gave My.Survey..final. A name R
#' takes as it is stays as it is.
#' @param x Character(1).
#' @return Character(1).
#' @keywords internal
.jst_clean_object_name <- function(x) {
  if (.jst_name_valid_r(x)) return(x)
  .jst_clean_name(x, 1L, max_chars = 10000L, max_bytes = 40000L)
}

#' Internal: stop on a path holding characters R made from single backslashes
#'
#' A Windows path typed or pasted into R with single backslashes reaches the
#' function changed: inside quoted text R reads a backslash and the letter
#' after it as one special character, so a backslash before t becomes a tab
#' and one before n a new line, and the file is then reported not found
#' under a name the user never typed (Session 343, Jeff's decision; built
#' Session 351). An ILLEGAL escape, such as a backslash before the digit 5,
#' stops R while it reads the line, before any function runs; that case is
#' the guides' Troubleshooting entry, not this check's.
#'
#' A path holding a control character (below a space, or DEL) stops here,
#' before the file is looked for. The message quotes the path as R holds
#' it -- deparse() writes the characters back as the escapes that made
#' them -- and, when every such character is one of the seven a backslash
#' and a letter make (bell, backspace, tab, new line, vertical tab, form
#' feed, carriage return), gives the same path with forward slashes;
#' otherwise the instruction alone, since an octal or hex escape cannot be
#' told from the character it made. A path with none passes untouched:
#' spaces, a UNC path and doubled backslashes hold no control character.
#' Callers: jload() and jsave() on their file argument, joptions() on
#' data.dir.
#'
#' @param path The path argument as received.
#' @param what The noun for it in the fix line, "path" or "folder".
#' @return Invisibly NULL when the path holds no control character;
#'   otherwise stops through .jst_stop().
#' @keywords internal
.jst_check_path_chars <- function(path, what = "path") {
  if (!is.character(path) || length(path) != 1L || is.na(path) ||
      !grepl("[\\x01-\\x1F\\x7F]", path, perl = TRUE)) {
    return(invisible(NULL))
  }
  letter <- c("\a" = "a", "\b" = "b", "\t" = "t", "\n" = "n",
              "\v" = "v", "\f" = "f", "\r" = "r")
  word   <- c(a = "a bell", b = "a backspace", t = "a tab",
              n = "a new line", v = "a vertical tab", f = "a form feed",
              r = "a carriage return")
  chars <- strsplit(path, "", fixed = TRUE)[[1L]]
  ctrl  <- chars[grepl("[\\x01-\\x1F\\x7F]", chars, perl = TRUE)]
  typed <- deparse(path)
  n     <- length(ctrl)
  if (all(ctrl %in% names(letter))) {
    seen  <- unique(unname(letter[ctrl]))
    kinds <- paste0("\\", seen, " as ", word[seen])
    fixed <- chars
    hit   <- fixed %in% names(letter)
    fixed[hit] <- paste0("/", letter[fixed[hit]])
    fixed <- gsub("\\", "/", paste(fixed, collapse = ""), fixed = TRUE)
    .jst_stop("R read the ", .jst_plural(n, "single backslash", "single backslashes"),
              " in ", typed, " as ",
              .jst_plural(n, "a special character", "special characters"),
              " (", paste(kinds, collapse = ", "), ").\n",
              "Write the ", what, " with forward slashes:\n",
              "  ", deparse(fixed))
  }
  .jst_stop("R read ", .jst_plural(n, "a single backslash", "single backslashes"),
            " in ", typed, " as ",
            .jst_plural(n, "a special character", "special characters"), ".\n",
            "Type the ", what, " again with forward slashes in place of ",
            "the backslashes.")
}

#' Internal: jload()'s file argument when it is not a file name
#'
#' Called by jload() with the argument as typed and its value, before the
#' generic "Provide a filename" stop (Session 351, Fix Slate 6). Two inputs
#' get a stop of their own:
#' \itemize{
#'   \item a data frame -- for a shipped dataset's name (jload(community),
#'     the quotes left off the documented jload("community")) the quoted
#'     call; for any other frame named by itself, that it is already
#'     loaded and the jsave() call that writes it to a file (the Session 40
#'     item);
#'   \item an empty string that an EXPRESSION gave -- a variable, or a call
#'     such as system.file() finding no file (the S197 item, a failure mode
#'     an AI assistant was seen to produce). The expression is the subject
#'     of the sentence; for system.file() a second line says it gives an
#'     empty string when the file is not in the package. An empty string
#'     typed as such keeps the generic stop.
#' }
#' Anything else returns and meets jload()'s own checks.
#'
#' @param file_sub The file argument as typed, from substitute().
#' @param value Its value, already forced by jload().
#' @return Invisibly NULL, or stops through .jst_stop().
#' @keywords internal
.jst_jload_file_value <- function(file_sub, value) {
  if (is.data.frame(value)) {
    if (is.symbol(file_sub)) {
      nm <- as.character(file_sub)
      if (.jst_is_package_dataset(nm)) {
        .jst_stop("the name of the ", nm, " dataset goes in quotes:\n",
                  "  jload(\"", nm, "\")")
      }
      .jst_stop("the ", nm, " data frame is already loaded.\n",
                "To save it to a file:\n",
                "  jsave(", deparse(file_sub), ", \"", nm, ".rds\")")
    }
    .jst_stop(paste(deparse(file_sub), collapse = " "),
              " is a data frame, not a file name.\n",
              "Provide a filename, e.g. jload(\"mydata.sav\")")
  }
  if (is.character(value) && length(value) == 1L && !is.na(value) &&
      identical(value, "") && !is.character(file_sub)) {
    expr <- paste(deparse(file_sub), collapse = " ")
    if (is.call(file_sub) && identical(file_sub[[1L]], as.name("system.file"))) {
      .jst_stop(expr, " is \"\", an empty file name.\n",
                "system.file() gives \"\" when the file is not in the package.")
    }
    .jst_stop(expr, " is \"\", an empty file name.")
  }
  invisible(NULL)
}

#' Internal: map a file extension to its user-facing format label
#'
#' Returns the format-name parenthetical used in jload and jsave
#' success messages -- e.g. \code{"Stata format"} for \code{.dta},
#' \code{"R format"} for \code{.rds}. Centralises the mapping
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
         rds      = "R format",
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
#' @param observed Logical. When \code{TRUE}, additionally enumerate the
#'   distinct values actually PRESENT in the column that fall inside a
#'   declared \code{na_range}, returned as \code{range_values}. Defaults
#'   to \code{FALSE} because that enumeration reads the column's data
#'   (cost proportional to its length), while every other component of
#'   the return is an attribute read. Callers that need only the
#'   declaration -- jsave's pre-flight, jload's narrative, jconvert, the
#'   CPS renderers -- leave it \code{FALSE} and pay nothing.
#'
#' @return \code{NULL} if the column has no formal UDM declarations.
#'   Otherwise a list with:
#'   \describe{
#'     \item{representation}{\code{"spss"} or \code{"stata"} -- the
#'       PHYSICAL structure (na_values metadata vs tagged_na markers).
#'       Deliberately binary: SAS-form is structurally Stata-form
#'       (Decision 13), so structural consumers (conversion loops,
#'       UDM-to-NA application) key on this and never see "sas".}
#'     \item{convention}{\code{"spss"}, \code{"stata"}, \code{"sas"},
#'       or \code{NA_character_} -- the user-facing CONVENTION, refined
#'       from tag letter case: all-lowercase tags read as Stata-form,
#'       all-uppercase as SAS-form, mixed case as \code{NA} (ambiguous;
#'       Decision 13's rule -- such a column is skipped by convention
#'       counting and does not engage the resolver's column level).
#'       Always \code{"spss"} for SPSS-representation columns.}
#'     \item{na_range}{Length-2 numeric vector for SPSS range-based
#'       missingness, or \code{NULL}}
#'     \item{codes}{A data frame with one row per declared code/tag,
#'       or \code{NULL} if only \code{na_range} is present. Columns:
#'       \code{code} (character display form, e.g. \code{"-99"} or
#'       \code{".a"}), \code{label} (character or \code{NA}),
#'       \code{source} (\code{"na_values"} or \code{"tagged_na"}),
#'       \code{numeric} (underlying numeric value; \code{NA} for
#'       tagged NAs), \code{tag} (tag letter for Stata; \code{NA} for
#'       SPSS UDMs). On a string variable (\code{text} below) \code{code}
#'       is the declared string exactly as stored and \code{numeric} is
#'       \code{NA}; consumers compare cells against \code{code}.}
#'     \item{text}{SPSS representation only: \code{TRUE} when the column
#'       is character-backed, so its declared missing values are strings
#'       (Session 340); \code{FALSE} otherwise.}
#'     \item{range_values}{Only when \code{observed = TRUE} and an
#'       \code{na_range} is declared: a data frame of the DISTINCT
#'       observed in-band values, same columns as \code{codes} (with
#'       \code{source = "na_range"}), ascending by value, carrying no
#'       counts -- consumers keep their own counting logic, exactly as
#'       they do for \code{codes}. Values that are also declared
#'       discretely in \code{na_values} are excluded, so the two
#'       components never describe the same cell twice. A zero-row data
#'       frame means the band is declared but no in-band value occurs;
#'       \code{NULL} means the enumeration was not requested, or no
#'       band is declared.}
#'   }
#'
#' @section Why codes is not extended:
#' \code{codes} carries DECLARATION-SLOT semantics -- consumers such as
#' jsave's .sav pre-flight, jconvert's letter cap and its SPSS-to-Stata
#' ordering, and jdeclare_missing's drop notice read \code{nrow(codes)} as
#' "how many discrete codes has the user declared". Folding observed
#' in-band values into \code{codes} would take a range-bearing column
#' from zero declared codes to however many happen to be present, and
#' those consumers would then refuse a file that saves correctly today.
#' Observed values are therefore a separate component, never a longer
#' \code{codes}.
#'
#' @keywords internal
.jst_missing_info <- function(col, observed = FALSE) {
  na_vals  <- attr(col, "na_values")
  na_range <- attr(col, "na_range")

  has_spss_udms <- (!is.null(na_vals)  && length(na_vals)  > 0) ||
                   (!is.null(na_range) && length(na_range) == 2)

  # Tagged NAs only exist on doubles; haven::na_tag returns NA for
  # non-tagged elements on any double vector. A column is Stata-form on
  # EITHER kind of evidence: tagged cells in the data, or markers
  # declared through tagged value labels with no tagged cells yet -- the
  # forward-declaration pattern (a marker labeled before any cases carry
  # it; the same evidence rule jdeclare_missing applies since S218). Without
  # the label arm, a forward-declared column returned NULL here and its
  # declarations were invisible to every consumer of this abstraction,
  # including jload's narrative.
  # The cells are read only where they can hold a tag (Session 349, the S217
  # item's fix 1): a tagged NA is always an NA, so a column with no NA has
  # none, and among a column's cells only the NA ones need reading. The
  # answer is the same by construction; the test, paid on every double
  # column of every analysis call, ran some 35 times faster on a column of
  # 1.9 million rows with no NA, and 6 times on one with NA cells.
  has_tagged <- FALSE
  if (is.double(col)) {
    has_tagged <- anyNA(col) &&
      any(!is.na(haven::na_tag(col[is.na(col)])))
    if (!has_tagged && haven::is.labelled(col)) {
      vl_probe <- labelled::val_labels(col)
      if (!is.null(vl_probe) && length(vl_probe) > 0L &&
          any(!is.na(haven::na_tag(vl_probe)))) {
        has_tagged <- TRUE
      }
    }
  }

  if (!has_spss_udms && !has_tagged) return(NULL)

  # Pathological: both representations on one column. haven's read paths
  # produce one or the other, never both. Defensive branch prefers the
  # formal SPSS declaration if somehow both are present.
  if (has_spss_udms && has_tagged) has_tagged <- FALSE

  val_labs <- if (haven::is.labelled(col)) labelled::val_labels(col) else NULL

  # A character-backed column: its declared missing values are strings. A
  # range cannot be declared on a string variable (SPSS allows none), so a
  # stray na_range on one is ignored rather than compared as numbers.
  is_text <- is.character(col)
  if (is_text) na_range <- NULL

  if (has_spss_udms) {
    # SPSS representation: na_values + optional na_range
    codes_df <- NULL

    if (is_text && !is.null(na_vals) && length(na_vals) > 0) {
      # A string variable's declared missing values (S340). SPSS declares
      # them directly -- MISSING VALUES MARITAL ('UNKNOWN'). -- and haven
      # carries them as a character na_values on a character-backed
      # haven_labelled_spss column. The declared STRINGS are the codes:
      # `code` holds each one exactly as stored (it is what consumers
      # compare cells against, never a display form), `numeric` is NA,
      # and the list's `text` element tells a consumer which comparison
      # to make. Until S340 this arm did not exist: as.numeric() turned
      # every declared string into NA with a coercion warning, so nothing
      # downstream could count or mask a cell.
      s_vals     <- as.character(na_vals)
      labels_vec <- rep(NA_character_, length(s_vals))
      if (!is.null(val_labs) && length(val_labs) > 0) {
        lab_vals <- as.character(unname(val_labs))
        for (i in seq_along(s_vals)) {
          idx <- which(!is.na(lab_vals) & lab_vals == s_vals[i])
          if (length(idx) > 0) labels_vec[i] <- names(val_labs)[idx[1]]
        }
      }
      codes_df <- data.frame(
        code    = s_vals,
        label   = labels_vec,
        source  = rep("na_values", length(s_vals)),
        numeric = rep(NA_real_, length(s_vals)),
        tag     = rep(NA_character_, length(s_vals)),
        stringsAsFactors = FALSE
      )
      # Deterministic order, as the numeric arm's: by value, and "radix"
      # pins C-locale collation so two machines cannot disagree.
      codes_df <- codes_df[order(codes_df$code, method = "radix"), ,
                           drop = FALSE]
      rownames(codes_df) <- NULL

    } else if (!is.null(na_vals) && length(na_vals) > 0) {
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
        # trim = TRUE for the same reason range_values below carries it:
        # format() pads a multi-value vector to a common width, which puts
        # stray leading spaces in front of the narrower codes when these
        # strings are rendered as row labels (" -5" beside "-99"). The
        # padding was fixed on the range side at S214 and missed here;
        # with the S220 ordering alignment interleaving code rows and
        # in-band rows, the mismatch became visible in one block.
        code    = format(n_vals, trim = TRUE),
        label   = labels_vec,
        source  = rep("na_values", length(n_vals)),
        numeric = n_vals,
        tag     = rep(NA_character_, length(n_vals)),
        stringsAsFactors = FALSE
      )

      # Deterministic order: ascending by value (S233). haven returns
      # na_values in DECLARATION order, which is stable within a column
      # but arbitrary across columns, so two columns declaring the same
      # two codes could render them in opposite orders. Sorting here
      # rather than at each render point means the load narrative, the
      # CPS detail table and the UDM entries builder -- all three iterate
      # this frame row-by-row -- cannot disagree with each other. Same
      # principle the jfreq Missing block already applies across its
      # three tiers (S220: declaration order is a leftover, not a
      # principle; ascending by value is the commercial-software parity).
      codes_df <- codes_df[order(codes_df$numeric), , drop = FALSE]
      rownames(codes_df) <- NULL
    }

    # Observed in-band values (opt-in; see @param observed). This is the
    # only part of the return that reads the column's data rather than
    # its attributes, so it is computed only when asked for and only
    # when a band is actually declared.
    range_values_df <- NULL
    if (isTRUE(observed) && !is.null(na_range) && length(na_range) == 2) {
      lo    <- min(na_range)
      hi    <- max(na_range)
      x_num <- suppressWarnings(as.numeric(unclass(col)))
      vals  <- sort(unique(x_num[!is.na(x_num) & x_num >= lo & x_num <= hi]))

      # A value that is ALSO declared discretely belongs to codes, not
      # here: reporting it in both would double-count the same cells.
      if (!is.null(na_vals) && length(na_vals) > 0) {
        vals <- vals[!(vals %in% suppressWarnings(as.numeric(na_vals)))]
      }

      rv_labels <- rep(NA_character_, length(vals))
      if (!is.null(val_labs) && length(val_labs) > 0 && length(vals) > 0) {
        numeric_labels <- suppressWarnings(as.numeric(val_labs))
        for (i in seq_along(vals)) {
          idx <- which(!is.na(numeric_labels) & numeric_labels == vals[i])
          if (length(idx) > 0) rv_labels[i] <- names(val_labs)[idx[1]]
        }
      }

      # trim = TRUE: format() pads a multi-value vector to a common
      # width, which would put stray leading spaces in front of the
      # shorter codes when these strings are rendered as row labels.
      range_values_df <- data.frame(
        code    = format(vals, trim = TRUE),
        label   = rv_labels,
        source  = rep("na_range", length(vals)),
        numeric = as.numeric(vals),
        tag     = rep(NA_character_, length(vals)),
        stringsAsFactors = FALSE
      )
    }

    # A text column whose only declaration was the ignored range declares
    # nothing this package can read.
    if (is_text && is.null(codes_df)) return(NULL)

    list(
      representation = "spss",
      convention     = "spss",
      na_range       = if (!is.null(na_range) && length(na_range) == 2) na_range else NULL,
      codes          = codes_df,
      range_values   = range_values_df,
      text           = is_text
    )

  } else {
    # Stata representation: tagged_na markers. Union of both evidence
    # kinds -- tags present in cells, and tags declared through value
    # labels (forward-declared markers; see the has_tagged comment
    # above). Cell order first, then label-only tags, deduplicated.
    tags_present <- unique(haven::na_tag(col))
    tags_present <- tags_present[!is.na(tags_present)]
    if (!is.null(val_labs) && length(val_labs) > 0) {
      lab_tags <- haven::na_tag(val_labs)
      lab_tags <- lab_tags[!is.na(lab_tags)]
      tags_present <- unique(c(tags_present, lab_tags))
    }

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

    # Deterministic order: by tag letter (S233), the tagged-NA analogue of
    # the SPSS branch's ascending-by-value rule. tags_present is built
    # from cell order of first appearance, so before this the same two
    # codes could render ".a, .b" on one column and ".b, .a" on the next,
    # and would shuffle again if the rows were re-sorted. method =
    # "radix" pins C-locale collation: R's default character ordering
    # follows the session locale, so a plain sort would still differ
    # between machines -- the same class of defect being fixed. Primary
    # key is the lowercased letter so a mixed-case (ambiguous-convention)
    # column interleaves as .a, .A, .b, .B rather than splitting by case.
    # The tiebreak between a letter's two cases runs DESCENDING because
    # C-locale byte order puts uppercase first (65 before 97); descending
    # puts the lowercase Stata-form member ahead of its SAS-form twin,
    # which is the commoner form in this package's data.
    codes_df <- codes_df[order(tolower(codes_df$tag), codes_df$tag,
                               method = "radix",
                               decreasing = c(FALSE, TRUE)), , drop = FALSE]
    rownames(codes_df) <- NULL

    # Convention refinement from tag letter case (Decision 13): all
    # lowercase = Stata-form, all uppercase = SAS-form, mixed = NA
    # (ambiguous). Judged over the union of cell tags and label-declared
    # tags -- the same evidence set the codes table is built from.
    tag_convention <- if (all(tags_present %in% letters)) {
      "stata"
    } else if (all(tags_present %in% LETTERS)) {
      "sas"
    } else {
      NA_character_
    }

    list(
      representation = "stata",
      convention     = tag_convention,
      na_range       = NULL,
      codes          = codes_df,
      range_values   = NULL   # Stata form has no range declaration
    )
  }
}

# -----------------------------------------------------------------------------
# .jst_convention_census() / .jst_predominant_convention()
#
# Scans the columns of a data frame and classifies its UDM convention
# make-up. Per Sign-off 6b (Session 32), extracted from the body of
# .jst_options_nudge so both that helper and jdeclare_missing's post-
# declaration mismatch notice consume the same logic; generalized to
# the three-way census at S226 (Decision 13).
#
# Classification rules (per locked design, Cross-cutting 3 Notes,
# extended by Decision 13):
#   - Only columns with a classifiable convention count. Plain numeric
#     columns are ignored; mixed-case tagged columns (convention = NA,
#     the ambiguous rule) are likewise ignored -- they count toward
#     neither the verdict nor unanimity.
#   - The predominant convention is the STRICT PLURALITY winner; a tie
#     for the top count, or zero countable columns, yields NA.
# -----------------------------------------------------------------------------

#' Internal helper: census a data frame's UDM conventions
#'
#' Walks a data frame's columns via \code{.jst_missing_info()} and
#' tallies countable columns by convention (\code{"spss"},
#' \code{"stata"}, \code{"sas"}; ambiguous mixed-case columns are
#' skipped).
#'
#' @param df A data frame.
#'
#' @return A list with \code{counts} (named integer vector: spss,
#'   stata, sas), \code{predominant} (the strict-plurality winner, or
#'   \code{NA_character_} on a top-count tie or zero countable
#'   columns), and \code{unanimous} (\code{TRUE} when exactly one
#'   convention has a nonzero count; \code{FALSE} otherwise, including
#'   the zero-column case).
#'
#' @keywords internal
.jst_convention_census <- function(df) {
  counts <- c(spss = 0L, stata = 0L, sas = 0L)
  if (is.data.frame(df)) {
    for (col in df) {
      info <- .jst_missing_info(col)
      if (is.null(info)) next
      conv <- info$convention
      if (is.null(conv) || is.na(conv)) next
      if (conv %in% names(counts)) counts[[conv]] <- counts[[conv]] + 1L
    }
  }

  total   <- sum(counts)
  top     <- max(counts)
  winners <- names(counts)[counts == top]

  predominant <- if (total == 0L || length(winners) > 1L) NA_character_
                 else winners
  unanimous   <- total > 0L && sum(counts > 0L) == 1L

  list(counts = counts, predominant = predominant, unanimous = unanimous)
}

#' Internal helper: classify a data frame's predominant UDM convention
#'
#' Thin wrapper over \code{.jst_convention_census()} returning only the
#' verdict, for callers that need no counts or unanimity.
#'
#' @param df A data frame.
#'
#' @return Character scalar: \code{"spss"}, \code{"stata"},
#'   \code{"sas"}, or \code{NA_character_}.
#'
#' @keywords internal
.jst_predominant_convention <- function(df) {
  .jst_convention_census(df)$predominant
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
#' When \code{preserve.declarations = FALSE}, additionally converts UDM cells to
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
.jst_handle_udms <- function(df, preserve.declarations) {
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

    if (!preserve.declarations) {
      if (info$representation == "spss") {
        # unclass() bypasses vctrs's "Can't convert <haven_labelled> to <double>"
        # cast refusal in cold-session vec_cast dispatch ordering. See the matching
        # note in .jst_detect_suspicious_values() for full context.
        x_num <- suppressWarnings(as.numeric(unclass(col)))
        mask  <- rep(FALSE, length(x_num))

        if (isTRUE(info$text)) {
          # A string variable's declared values are strings (S340): until
          # then the numeric comparison matched nothing, so the declaration
          # was stripped below while its cells stayed in the data as text.
          x_chr <- as.character(unclass(col))
          mask  <- !is.na(x_chr) & x_chr %in% info$codes$code
        } else if (!is.null(info$codes)) {
          mask <- mask | (!is.na(x_num) & x_num %in% info$codes$numeric)
        }
        if (!is.null(info$na_range)) {
          mask <- mask | (!is.na(x_num) & x_num >= info$na_range[1] & x_num <= info$na_range[2])
        }

        df[[vname]][mask] <- NA
        attr(df[[vname]], "na_values") <- NULL
        attr(df[[vname]], "na_range")  <- NULL

      } else if (info$representation == "stata") {
        # User-requested plain-NA conversion (preserve.declarations = FALSE):
        # strip the tagged-NA metadata so nothing round-trips back to Stata.
        # haven::zap_missing converts tagged NAs to plain NAs while
        # preserving labels on non-missing values. (The analysis pipeline's
        # Step 0 applies the same zap on its own copy -- AUDIT-039 -- for a
        # different reason: keeping as_factor() from reviving labelled
        # tags as factor levels.)
        df[[vname]] <- haven::zap_missing(col)
      }
    }
  }

  list(df = df, udm_info = udm_info)
}

#' Internal: format the UDM narrative notification text
#'
#' Builds the message string emitted when UDM-bearing variables are
#' detected during a load. The S227 (E17) redesign conditions the text
#' on three things: the convention(s) actually read (per-variable
#' \code{convention} from \code{.jst_missing_info()}), the
#' \code{missing.convention} setting in \code{\link{joptions}}, and whether the
#' full form has already been shown this session (\code{compact}).
#'
#' Shapes produced under \code{preserve.declarations = TRUE}:
#' \itemize{
#'   \item Uniform frame: style-named header ("5 variables have
#'     SPSS-style missing values:"). SPSS-style frames with no
#'     conflicting setting add the base-R gap fact and the one
#'     jconvert remedy; Stata- and SAS-style frames add nothing, since
#'     tagged markers are already NA to base R.
#'   \item Uniform frame under an explicitly set, different
#'     \code{missing.convention}: a setting-mismatch note with two
#'     equal-standing remedies (change the setting, or convert the
#'     data), neither recommended -- the Rule D equal-standing-remedies
#'     carve-out (S227).
#'   \item Mixed frame: grouped-count header ("6 variables have missing
#'     values (5 SPSS-style, 1 Stata-style):") plus a mixes note with
#'     one align line per real style present. Under an explicitly set
#'     convention the note instead names the off-setting columns, the
#'     setting's own style leads the align lines, and align targets
#'     other than the setting carry a joptions rider so the setting is
#'     not left stale. Ambiguous mixed-case tagged columns (convention
#'     NA, Decision 13) form their own "mixed-case" display group and
#'     get no align line of their own -- any align target collapses
#'     them.
#'   \item Compact form (second and later showings in a session, unless
#'     the call passed \code{missing.notice = TRUE}): header + inventory,
#'     with the convention note retained -- it is frame-specific, and
#'     compaction must not silence a new frame's mismatch -- and the
#'     Case 1 guidance lines dropped.
#' }
#' The setting-MISMATCH notice is gated on an explicitly set
#' \code{missing.convention}: a user who stated no preference must
#' never be nagged about a mismatch with it (S226). Mixed-frame ALIGN lines
#' are not so gated -- each carries a
#' \code{joptions(missing.convention = ...)} rider whenever running it
#' would leave the setting not matching the result, which under
#' \code{"none"} means both of them (S227; the joptions rider rule in
#' the missing-values reference). The rider is not a suggestion to adopt
#' a convention -- it is the second half of a remedy the user has
#' already chosen to run.
#'
#' The \code{preserve.declarations = FALSE} branch (declarations converted to
#' plain NA on request) keeps its original shape with a style-named
#' header and is never compacted -- it reports a destructive action the
#' user explicitly requested.
#'
#' Renders SPSS UDM codes (e.g. \code{-99}) and tagged markers
#' (e.g. \code{.a}) using parallel notation: \code{code ["label"]} or
#' \code{code (no label)}. The code form comes pre-rendered in the
#' \code{code} column of \code{.jst_missing_info()}'s return.
#'
#' @param compact Logical. \code{TRUE} selects the repeat-showing
#'   compact form described above.
#'
#' @keywords internal
.jst_format_udm_narrative <- function(udm_info, preserve.declarations,
                                      max_show = 10L, data_name = "data",
                                      compact = FALSE) {
  # Suggested jconvert()/joptions() calls below use the loaded object's
  # name (threaded from jload) so the advice is copy-paste runnable; fall
  # back to the generic placeholder only when no name is available.
  call_name <- if (!is.null(data_name) && nzchar(data_name)) data_name else "data"
  n_vars <- length(udm_info)
  if (n_vars == 0) return(NULL)

  # --- Convention census over the loaded frame's declared columns -----------
  # info$convention: "spss" | "stata" | "sas" | NA (ambiguous mixed-case
  # tags, Decision 13). NA columns form their own display group.
  convs <- vapply(udm_info, function(e) {
    cv <- e$info$convention
    if (is.null(cv) || is.na(cv)) "ambiguous" else cv
  }, character(1))
  grp_order  <- c("spss", "stata", "sas", "ambiguous")
  grp_counts <- vapply(grp_order, function(g) sum(convs == g), integer(1))
  names(grp_counts) <- grp_order
  present        <- grp_order[grp_counts > 0L]
  styles_present <- setdiff(present, "ambiguous")
  uniform  <- length(present) == 1L && !identical(present, "ambiguous")
  all_amb  <- identical(present, "ambiguous")
  disp_label <- function(g) {
    if (identical(g, "ambiguous")) "mixed-case" else .jst_convention_label(g)
  }

  # --- The joptions setting (the explicit-setting gate, S226) ---------------
  opt <- getOption(".jst_options_missing_convention",
                   .jst_options_defaults$missing.convention)
  explicit_set <- is.character(opt) && length(opt) == 1L && !is.na(opt) &&
    opt %in% c("spss", "stata", "sas")

  # --- Per-variable inventory lines -----------------------------------------
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
        val_strs[j] <- .jst_udm_row_label(code, label)
      }
      parts <- c(parts, paste(val_strs, collapse = ", "))
    }

    # Range rendering (SPSS only -- Stata form has no equivalent)
    if (!is.null(info$na_range)) {
      parts <- c(parts, sprintf("range %s to %s",
                                format(info$na_range[1]),
                                format(info$na_range[2])))
    }

    body <- paste(parts, collapse = "; ")
    if (!preserve.declarations) body <- paste0("was ", body)

    var_strings[i] <- sprintf("%s: %s", entry$var, body)
  }

  list_lines <- paste0("  ", var_strings)
  if (n_vars > max_show) {
    list_lines <- c(list_lines, paste0("  ...and ", n_vars - max_show, " more"))
  }
  list_str <- paste(list_lines, collapse = "\n")

  # --- Header ----------------------------------------------------------------
  # Uniform frames name the style (the locked S226 header form); mixed
  # frames carry grouped counts in canonical order, ambiguous last.
  verb_have <- if (n_vars == 1) "has" else "have"
  verb_noun <- if (n_vars == 1) "variable" else "variables"
  count_parens <- paste(vapply(present, function(g)
    sprintf("%d %s", grp_counts[[g]], disp_label(g)), character(1)),
    collapse = ", ")

  # --- preserve.declarations = FALSE: conversion report, never compacted ----
  if (!preserve.declarations) {
    head_str <- if (uniform) {
      sprintf(
        "%d %s had %s missing values, converted to plain NA per preserve.declarations = FALSE:",
        n_vars, verb_noun, disp_label(present))
    } else {
      sprintf(
        "%d %s had missing values (%s), converted to plain NA per preserve.declarations = FALSE:",
        n_vars, verb_noun, count_parens)
    }
    return(paste0(
      head_str, "\n", list_str,
      "\nTo keep the declarations instead, reload with preserve.declarations = TRUE."
    ))
  }

  # --- preserve.declarations = TRUE ------------------------------------------
  head_str <- if (uniform) {
    sprintf("%d %s %s %s missing values:",
            n_vars, verb_noun, verb_have, disp_label(present))
  } else {
    sprintf("%d %s %s missing values (%s):",
            n_vars, verb_noun, verb_have, count_parens)
  }

  tail_lines <- character(0)  # Case 1 guidance; dropped in compact form
  note_lines <- character(0)  # convention note; retained in compact form

  # A conversion remedy, as a block: the lead with its "run" verb, the
  # calls, and for a frame holding a text variable with declared missing
  # values a sentence after them (Session 351, the S340 item). jconvert()
  # refuses such a variable under to = "stata" or "sas", so the offered
  # whole-frame call stopped; the route that runs makes its declared
  # values plain NA first (.jst_text_route()), and the second call is
  # left out when nothing else would convert. rider adds the joptions()
  # line that keeps the setting matching the result. Without a text
  # variable every block is the same as before, line for line.
  text_vars <- unname(vapply(Filter(function(e) isTRUE(e$info$text), udm_info),
                             function(e) e$var, character(1)))
  conv_block <- function(lead, g, rider = FALSE) {
    route <- NULL
    if (length(text_vars) > 0L && g %in% c("stata", "sas")) {
      rest <- any(vapply(udm_info, function(e) {
        !isTRUE(e$info$text) && !identical(e$info$convention, g)
      }, logical(1)))
      route <- .jst_text_route(call_name, g, text_vars, convert_rest = rest,
                               more_lines = rider)
    }
    calls <- if (is.null(route)) {
      sprintf("  jconvert(%s, to = \"%s\", modify = TRUE)", call_name, g)
    } else route$calls
    if (rider) {
      calls <- c(calls, sprintf("  joptions(missing.convention = \"%s\")", g))
    }
    run <- switch(as.character(length(calls)),
                  "1" = "run:", "2" = "run both:", "run all three:")
    c(paste(lead, run), calls, if (!is.null(route)) route$note)
  }

  if (uniform) {
    st <- present
    if (explicit_set && !identical(opt, st)) {
      # Case 4: uniform frame, explicitly set different convention. Two
      # equal-standing remedies (Rule D carve-out, S227), the data's own
      # style first per the non-destructive-first suggestion convention;
      # neither recommended -- which is right depends on whether the user
      # regards the data or the setting as the truth.
      note_lines <- c(
        # The subject agrees with the count (S347 item, Session 357):
        # the header above has just said "1 variable has ...".
        sprintf(
          "Note: %s %s, but your missing.convention setting is \"%s\".",
          .jst_plural(n_vars, "this variable is", "these variables are"),
          disp_label(st), opt),
        sprintf("To use %s missing values, run:", disp_label(st)),
        sprintf("  joptions(missing.convention = \"%s\")", st),
        conv_block(sprintf("To use %s missing values,", disp_label(opt)), opt)
      )
    } else if (identical(st, "spss")) {
      # Case 1: uniform SPSS-style, no conflicting setting. The one
      # fidelity fact a user cannot see (base R reads the codes as real
      # values) plus the one conditional remedy. The to = "baseR" path
      # and the range-enumeration cost live in ?jconvert and in
      # jconvert's own run-time messages (settled S227: costs surface
      # where they bite -- jsave's pre-flight refusals cover the .sav
      # dead end).
      # A declared STRING has no Stata form -- jconvert(to = "stata")
      # refuses a text variable (S340) -- so a frame holding one is offered
      # the conversion that does run for it, to plain NA.
      any_text <- any(vapply(udm_info, function(e) isTRUE(e$info$text),
                             logical(1)))
      tail_lines <- c(
        "jstats analyses treat these codes as missing. Base R functions do not.",
        "To make them missing in base R as well, convert:",
        sprintf("  jconvert(%s, to = \"%s\", modify = TRUE)", call_name,
                if (any_text) "baseR" else "stata")
      )
    }
    # Uniform Stata-/SAS-style with no conflicting setting (Case 5):
    # tagged markers are already NA to base R -- header and inventory
    # say everything; the .sav route lives in jsave's pre-flight.
  } else if (!all_amb) {
    if (explicit_set) {
      # Case 7: mixed frame under an explicitly set convention. The note
      # names the off-setting columns (grouped by style, canonical
      # order); one align line per real style present, the setting's
      # style first; align targets other than the setting carry the
      # joptions rider so the chosen style and the setting end up
      # matching either way.
      off_groups <- setdiff(present, opt)
      # Names while a group is short, a count past three (Session 351, the
      # S294 item): a wide frame put ten names and "... and 2 more" ahead
      # of the verb. The inventory above lists them, as Case 4's "these
      # variables" relies on. Three is the durability reminder's limit
      # (S339).
      seg <- vapply(off_groups, function(g) {
        vars_g <- vapply(udm_info[convs == g], function(e) e$var,
                         character(1))
        sprintf("%s %s %s",
                if (length(vars_g) <= 3L) {
                  .jst_format_var_list(vars_g, and = TRUE)
                } else {
                  paste(length(vars_g), "variables")
                },
                if (length(vars_g) == 1L) "is" else "are",
                disp_label(g))
      }, character(1))
      note_first <- sprintf(
        "Note: %s, but your missing.convention setting is \"%s\".",
        paste(seg, collapse = " and "), opt)
      remedy_styles <- c(intersect(opt, styles_present),
                         setdiff(styles_present, opt))
      # Rule L form (S230): the intro clause ends in a colon and each
      # runnable call gets its own two-space-indented line, no trailing
      # period. An off-setting target carries the joptions rider as a
      # second indented call under "run both:".
      note_rest <- unlist(lapply(remedy_styles, function(g) {
        conv_block(sprintf("To use %s missing values throughout,",
                           disp_label(g)),
                   g, rider = !identical(g, opt))
      }), use.names = FALSE)
      note_lines <- c(note_first, note_rest)
    } else {
      # Case 6: mixed frame, no convention set.
      mix_labels <- vapply(present, disp_label, character(1))
      mix_str <- if (length(mix_labels) == 2L) {
        paste(mix_labels, collapse = " and ")
      } else {
        paste0(paste(mix_labels[-length(mix_labels)], collapse = ", "),
               ", and ", mix_labels[length(mix_labels)])
      }
      # S227: BOTH align lines carry the joptions rider here. Running
      # either one leaves missing.convention at "none", so the next
      # fresh evidence-free declaration hits the Decision 11
      # choose-first gate (S244; pre-S244, it silently re-mixed the
      # frame) -- the same class of bite the Case 7 rider prevents.
      # Governing rule:
      # an align line carries a rider whenever running it would leave the
      # setting not matching the result. Scoped to mixed-frame align
      # lines; Case 1's jconvert line answers a different question
      # ("make them missing in base R") and is deliberately left alone.
      note_lines <- c(
        # Rule T (S230 item, Session 357): a message never opens on a
        # bare frame name.
        sprintf("Note: the %s data frame mixes %s missing values.",
                call_name, mix_str),
        unlist(lapply(styles_present, function(g) {
          conv_block(sprintf("To use %s throughout,", disp_label(g)),
                     g, rider = TRUE)
        }), use.names = FALSE)
      )
    }
  }
  # All-ambiguous frames (every declared column mixed-case): header and
  # inventory only. No style can be named and no remedy reasoned about
  # from muddled evidence -- the Decision 13 ambiguous rule's display
  # counterpart.

  out <- paste0(head_str, "\n", list_str)
  if (!compact && length(tail_lines) > 0L) {
    out <- paste0(out, "\n", paste(tail_lines, collapse = "\n"))
  }
  if (length(note_lines) > 0L) {
    out <- paste0(out, "\n", paste(note_lines, collapse = "\n"))
  }
  out
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
#' @param and Logical. When \code{TRUE} and the list is not truncated,
#'   the final name is joined with \code{"and"} ("A and B"; "A, B, and
#'   C" at three or more, Oxford comma per Rule A). Default
#'   \code{FALSE}, the comma-only form every pre-S227 caller expects.
#'   A truncated list is unaffected either way -- its "... and N more"
#'   tail already supplies the conjunction.
#'
#' @return Character scalar. Empty string if \code{vars} is empty.
#'
#' @keywords internal
.jst_format_var_list <- function(vars, max_show = 10L, and = FALSE) {
  n <- length(vars)
  if (n == 0) return("")
  show_n <- min(n, max_show)
  shown  <- vars[seq_len(show_n)]
  if (n > show_n) {
    return(paste0(paste(shown, collapse = ", "),
                  ", ... and ", n - show_n, " more"))
  }
  if (!isTRUE(and) || show_n == 1L) return(paste(shown, collapse = ", "))
  if (show_n == 2L) return(paste(shown, collapse = " and "))
  paste0(paste(shown[-show_n], collapse = ", "), ", and ", shown[show_n])
}

#' Internal: cap an own-line variable list at max_show, with "...and N more"
#'
#' Takes already-built per-variable display lines (e.g. "    Income: 4 codes")
#' and returns them unchanged when there are at most \code{max_show}, otherwise
#' the first \code{max_show} followed by a "    ...and N more" tail. The
#' four-space indent matches the per-variable lines jconvert and jsave build.
#' @param var_lines Character vector of pre-built, indented per-variable lines.
#' @param max_show Integer. Maximum lines to show before truncating (default 10).
#' @return Character vector, possibly truncated with a tail line.
#' @keywords internal
.jst_cap_var_lines <- function(var_lines, max_show = 10L) {
  n <- length(var_lines)
  if (n <= max_show) return(var_lines)
  c(var_lines[seq_len(max_show)],
    paste0("    ...and ", n - max_show, " more"))
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
#'
#' @param basename_no_ext The stem to search for (no extension).
#' @param has_dir Logical. Does the stem carry a directory component?
#' @param exts Character vector of extensions to try, without the dot.
#'   Defaults to the eight loadable formats. jload also calls this with
#'   \code{c("rdata", "rda")} to detect an .RData file sitting where a
#'   loadable one was expected, so the two searches share one set of
#'   directory rules.
#' @keywords internal
.jst_search_no_extension <- function(basename_no_ext, has_dir,
                                     exts = c("sav", "dta", "csv", "rds",
                                              "sas7bdat", "xpt", "xlsx",
                                              "xls")) {

  search_ext <- exts
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
#' - If the \code{data.dir} setting in \code{\link{joptions}} is set and that
#'   folder exists, it is searched first.
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
    # The path goes on its own line rather than inline: a folder name with
    # spaces in it -- C:/Users/Jane Smith/My Project -- is word-filled apart
    # by any wrap, and a broken path cannot be copied. On its own line it is
    # classified "pass" and travels whole. Same shape jai() uses. (S254)
    .jst_wrap_message(paste0(
      "\nNote: the configured data folder does not exist:\n  ", data_dir,
      "\nThe folder is set with joptions(data.dir = ...)."))
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
#' @param fallback A path returned, in place of the not-found stop, when no
#'   file of that name is on disk: the shipped example file of that name
#'   (Session 361), or NULL.
#' @keywords internal
.jst_find_file <- function(filename, quiet = FALSE, fallback = NULL) {
  search_dirs <- .jst_get_search_dirs()
  for (d in search_dirs) {
    candidate <- file.path(d, filename)
    if (file.exists(candidate)) {
      if (d != "." && !quiet) {
        .jst_msg("Reading from ", .jst_norm_path(d))
      }
      return(candidate)
    }
  }
  # A shipped example file of this name (Session 361): returned when no
  # file on disk matched; the caller says where it was read from.
  if (!is.null(fallback)) return(fallback)
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
#' Classifies findings three ways, most specific first: label-only (a value
#' label suggesting missingness, per the package wordlist, with no formal
#' declaration); convention-matched (Session 361; the Session 23 item,
#' Decision 5A: a value in the \code{missing.convention.codes} setting,
#' found whether or not the heuristic flags it); and suspected (a
#' suspicious sentinel value with no metadata at all). Values formally
#' declared in \code{na_values} or \code{na_range} are excluded from every
#' classification -- declared UDMs are reported by jload's narrative
#' (\code{.jst_handle_udms}), not here.
#'
#' @keywords internal
.jst_scan_coded_missing <- function(df, obj_name) {

  max_report <- 10L  # Maximum number of rows to display (harmonized with
                     # the narrative cap in .jst_format_udm_narrative)

  # The codes the package recommends (the missing.convention.codes
  # setting), for the convention-matched category (Session 361).
  conv_codes <- as.numeric(getOption(
    ".jst_options_missing_convention_codes",
    .jst_options_defaults$missing.convention.codes))
  conv_show  <- paste(vapply(conv_codes, .jst_fmt_code, character(1)),
                      collapse = ", ")

  # Collect findings: list of lists with var, value, count, source
  findings <- list()

  for (vname in names(df)) {
    col <- df[[vname]]
    if (!is.numeric(col) && !inherits(col, "haven_labelled")) next
    # A character-backed haven_labelled column (a string variable carrying
    # value labels, as a .sav stores Sex "M" / "F") has no numeric codes to
    # scan, and as.numeric() on one is a vctrs error, not an NA: until S340
    # jload() stopped here with "Can't convert `vec_data(x)` <character> to
    # <double>" after it had assigned the frame.
    if (is.character(col)) next
    # Only scan numeric-like variables (.jst_as_numeric(): the AUDIT-014
    # pattern, found at this site by the Session 342 scan)
    num_vals <- suppressWarnings(.jst_as_numeric(col))
    if (all(is.na(num_vals))) next

    # Pull formal UDM declarations once per variable. The heuristic
    # filter reads them so values formally declared as UDMs are never
    # flagged as "suspected" (declared codes are the load narrative's
    # job, not the scan's).
    spss_na_vals  <- attr(col, "na_values")
    spss_na_range <- attr(col, "na_range")

    # Value labels are used by the heuristic branch's label-only check —
    # values that have a label attached but no formal na_values
    # declaration are reported as "label-only" rather than "suspected".
    # This pattern arises commonly after .dta or .xpt round-trip, which
    # preserve value labels but not the formal UDM declaration.
    val_labs <- attr(col, "labels")

    # --- Heuristic scan using existing detection function ---
    # Only scan whole-number values — coded missings are always integers
    whole_vals <- num_vals[!is.na(num_vals) & num_vals == round(num_vals)]
    # Convention-matched values (Session 361; the Session 23 item, as
    # Decision 5A locked it): a value in the missing.convention.codes
    # setting is a candidate whatever the heuristic thinks of it -- a -99
    # beside ages of 18 to 80 is one the heuristic leaves alone by design.
    # Most specific wins below: a missing-suggestive label makes it
    # label-only, else it is convention-matched, else suspected.
    conv_hits <- sort(unique(whole_vals[whole_vals %in% conv_codes]))
    if (length(whole_vals) >= 2 || length(conv_hits) > 0) {
      suspicious <- if (length(whole_vals) >= 2) {
        .jst_detect_suspicious_values(whole_vals, vname)
      } else numeric(0)
      suspicious <- sort(unique(c(suspicious, conv_hits)))
      for (sv in suspicious) {
        # Skip if formally declared as UDM on this variable: declared
        # codes are covered by the load narrative, and without this
        # filter the heuristic would mislabel those same values as
        # suspected ("not formally defined").
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
            source = if (sv %in% conv_codes) "convention_matched"
                     else "suspected"
          )
        }
      }
    }
  }

  # --- Report findings -------------------------------------------------------
  if (length(findings) > 0) {

    # Internal source keys ("label_only", "suspected") are kept
    # separate from the user-facing tag text below, so display wording
    # can change without touching comparison logic. (The former em-dash
    # tag strings doubled as comparison keys; this split removes that
    # hazard, and the tag text itself is now ASCII-only per the
    # runtime-string punctuation convention.)
    src_display <- c(
      label_only         = "label-only -- not formally declared",
      convention_matched = "convention-matched -- not formally declared",
      suspected          = "suspected -- not formally defined"
    )

    sources_present <- unique(vapply(findings, function(f) f$source, character(1)))
    has_label_only <- "label_only" %in% sources_present
    has_conv       <- "convention_matched" %in% sources_present
    has_heur       <- "suspected"  %in% sources_present

    # Single-source rendering: when exactly ONE source type is present,
    # the per-row [source] tags would repeat one fact on every row, so
    # the rows drop the brackets and the legend reads as plain prose.
    # When two or more sources mix, the tags disambiguate the rows (the
    # tag-system carve-out) and the bracketed per-source legends stay.
    single_source <- length(sources_present) == 1L

    # Heading: telegraph "Suspected" only when ALL findings are pure
    # heuristic (no label-only). Label-only findings represent real
    # metadata that earns the neutral wording even when heuristic
    # findings are mixed in; a convention-matched value (Session 361) is
    # the code the package itself recommends, and earns it too.
    heading <- if (has_heur && !has_label_only && !has_conv) {
      "Suspected missing-value codes detected:"
    } else {
      "Missing-value codes detected:"
    }
    cat("\n", heading, "\n", sep = "")

    # Group findings by (variable, source). One row per group lists every
    # value flagged for that combination. This collapses the common case
    # of one variable carrying two codes (e.g. -99 and -98, both
    # label-only) from two lines to one. Mixed sources on the same
    # variable (rare -- e.g. a labelled code alongside an unlabelled
    # sentinel caught only by the heuristic) produce two rows for that
    # variable, one per source. Group order preserves the scan order of
    # first appearance.
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
        # S355 (the S319 item): the value with its label in the one form
        # every declared value takes (voice Rule AF, .jst_udm_row_label()),
        # where these rows read -99 "Refused" (3) and jconvert()'s list
        # of the same finding read 9 = "Not asked".
        vc_strs <- paste0(
          vapply(seq_along(g$values), function(k) {
            .jst_udm_row_label(sprintf("%g", g$values[k]), g$labels[k],
                               unlabelled = "bare")
          }, character(1)),
          " (", g$counts, ")")
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
      hidden_label_only <- sum(hidden_sources == "label_only")
      hidden_conv       <- sum(hidden_sources == "convention_matched")
      hidden_heur       <- sum(hidden_sources == "suspected")

      mixed <- (hidden_label_only > 0) + (hidden_conv > 0) +
        (hidden_heur > 0) > 1
      if (mixed) {
        cat(sprintf("  ... and %d more:\n", n_groups - max_report))
        if (hidden_label_only > 0) {
          cat(sprintf("    %d with [%s]\n", hidden_label_only,
                      src_display[["label_only"]]))
        }
        if (hidden_conv > 0) {
          cat(sprintf("    %d with [%s]\n", hidden_conv,
                      src_display[["convention_matched"]]))
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
    # Assembled as one string per branch and handed to the emitter, rather
    # than one cat() per line. These lines were hand-broken at a fixed width
    # when they were written, which is the one shape no message.width setting
    # can reach: there was no wrapper in the path to reach. (Session 255)
    if (single_source) {
      # One source type present: the legend reads as plain prose with no
      # bracket tag, since there is nothing to disambiguate.
      if (has_label_only) {
        .jst_msg_out(
          "These codes are not formally declared, so they are not treated ",
          "as missing, but the value labels suggest they mark missing ",
          "values. Declare them as missing if they are; leave ",
          "as-is if real.")
      } else if (has_conv) {
        .jst_msg_out(
          "These codes match the missing.convention.codes setting (",
          conv_show, ") but are not formally declared, so they are not ",
          "treated as missing. Declare them as missing if they are; leave ",
          "as-is if real.")
      } else {
        .jst_msg_out(
          "These codes are not formally defined, so they are not treated ",
          "as missing. Declare them as missing if they are; leave as-is ",
          "if real.")
      }
    } else {
      # The bracket tag takes a line of its own and the whole explanation
      # hangs under it at indent two, so every line of the block aligns.
      # The tag CANNOT share the first line with re-flowable prose: the
      # emitter classifies line by line, so the hang has to live in leading
      # spaces on lines the wrapper will keep indented. Merging the tag line
      # and the sentence below it is what cost this block its hang at S255,
      # caught in the modify_form_walk read the same session.
      if (has_label_only) {
        .jst_msg_out(
          "[", src_display[["label_only"]], "]:\n",
          "  not automatically treated as NA, but the value labels ",
          "suggest they mark missing values.\n",
          "  Declare them as missing if they are; leave as-is if real.")
      }
      if (has_conv) {
        .jst_msg_out(
          "[", src_display[["convention_matched"]], "]:\n",
          "  not automatically treated as NA, but they match the ",
          "missing.convention.codes setting (", conv_show, ").\n",
          "  Declare them as missing if they are; leave as-is if real.")
      }
      if (has_heur) {
        .jst_msg_out(
          "[", src_display[["suspected"]], "]:\n",
          "  not automatically treated as NA.\n",
          "  Declare them as missing if they are; leave as-is if real.")
      }
    }

    # Suggestion example: lead with the non-destructive declaration
    # (jdeclare_missing) rather than a destructive recode-to-NA, per the
    # message-suggestion convention (Session-113 addendum in the missing-
    # values reference). Target preference: label-only first (it
    # typically has several labelled codes, the most informative
    # example), then convention-matched (Session 361), then suspected.
    # A convention-matched target carries no missing-value label, so it
    # is offered as a suspected one is, the placeholder labels included.
    ex_var <- NULL
    ex_src <- NULL
    for (src in c("label_only", "convention_matched", "suspected")) {
      idx <- which(vapply(findings, function(f) f$source == src, logical(1)))
      if (length(idx) > 0) {
        ex_var <- findings[[idx[1]]]$var
        ex_src <- src
        break
      }
    }
    if (!is.null(ex_var)) {
      ex_codes <- sort(unique(vapply(findings, function(f) {
        if (f$var == ex_var) f$value else NA_real_
      }, numeric(1))))
      ex_codes <- ex_codes[!is.na(ex_codes)]
      codes_str <- if (length(ex_codes) == 1L) {
        format(ex_codes)
      } else {
        paste0("c(", paste(format(ex_codes, trim = TRUE), collapse = ", "), ")")
      }
      ex_col <- df[[ex_var]]
      # S352 (ruling R8's offered declarations): on a variable of Stata or
      # SAS form -- a .dta file's -99 beside the variable's own .a -- the
      # declaration would give the codes letters the variable carries, and
      # jdeclare_missing() refuses that (v0.9.218). What runs is the codes
      # sent to markers it does not use, in a new variable; a label each
      # code carries moves with it.
      ex_clash <- .jst_marker_clash(ex_col, length(ex_codes))
      ex_route <- if (!is.null(ex_clash)) {
        .jst_marker_recode_line(obj_name, ex_var, ex_codes, ex_clash$conv,
                                ex_clash$tags)
      } else NULL
      if (!is.null(ex_route)) {
        .jst_msg_out("\nTo recode one variable's codes to markers it does ",
                     "not use:")
        # S353: the offered lines go through the stdout emitter, as the
        # prose around them does, so a line wider than the message gets
        # ruling R5's layout; a bare cat() printed it whole.
        .jst_msg_out(ex_route)
        if (ex_src %in% c("suspected", "convention_matched")) {
          .jst_msg_out("To recode and label them in one call, replacing ",
                       "the placeholder names:")
          .jst_msg_out(.jst_marker_recode_line(
            obj_name, ex_var, ex_codes, ex_clash$conv, ex_clash$tags,
            labels = paste0("label", seq_along(ex_codes))))
        }
      } else {
        # S352 (ruling R15; Jeff, S347: "that's what I want"): with no
        # convention selected the line below stops at the choose-first
        # gate, so the menu comes first, as at the other six sites. A
        # variable with declared missing values of its own is declared in
        # its own form and meets no gate.
        ex_gate <- .jst_declare_gate_lead(
          "jload", n = length(ex_codes),
          plain = is.null(.jst_missing_info(ex_col)),
          what = if (length(ex_codes) == 1L) "this code" else "these codes")
        # S267: intros are plain prose through the stdout emitter -- the
        # old "#" prefixes made the block read as a script fragment and
        # left the second call commented out (not directly runnable).
        if (!is.null(ex_gate)) {
          .jst_msg_out("\n", ex_gate)
          .jst_msg_out("Then, to declare one variable's codes as missing:")
        } else {
          .jst_msg_out("\nTo declare one variable's codes as missing:")
        }
        .jst_msg_out(sprintf("  jdeclare_missing(%s, %s, codes = %s, modify = TRUE)",
                             obj_name, ex_var, codes_str))
        # For a suspected (unlabelled) target, offer a commented example
        # that also attaches labels in the same call. Placeholder label
        # strings, not guessed meanings -- the scan does not know what the
        # codes signify (Session 115). Omitted for a label-only target,
        # where the codes already carry labels and bare codes preserve them.
        if (ex_src %in% c("suspected", "convention_matched")) {
          lbl_parts <- paste0("\"label", seq_along(ex_codes), "\" = ",
                              format(ex_codes, trim = TRUE))
          lbl_str   <- paste0("c(", paste(lbl_parts, collapse = ", "), ")")
          .jst_msg_out("To declare and label them in one call, replacing ",
                       "the placeholder names:")
          .jst_msg_out(sprintf(
            "  jdeclare_missing(%s, %s, codes = %s, modify = TRUE)",
            obj_name, ex_var, lbl_str))
        }
      }
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
#' \code{jconvert(to = "stata")} -- since S218 the one remedy covers
#' both forms, as jconvert enumerates \code{na_range} declarations
#' too. Verbosity is controlled by the active \code{joutput()} level.
#'
#' @param spss_vars Character vector of variable names carrying
#'   SPSS-form UDM declarations (\code{na_values} and/or
#'   \code{na_range}).
#' @param data_name Character. Name of the data frame argument in
#'   the user's call to \code{jsave()}, used to construct the
#'   suggested \code{jconvert()} call.
#' @param text_vars The variables of \code{spss_vars} that are text
#'   (Session 351). When there are any, the remedy is the route
#'   \code{.jst_text_route()} builds -- their declared values made plain
#'   NA, then the rest converted -- with its sentence, and at the standard
#'   and full levels a closing line pointing to \code{jencode()}.
#' @param pd_line The offered jsave() call with
#'   \code{preserve.declarations = FALSE}, indented, or NULL (Session 361,
#'   the S218 item): the save that makes every declared missing value
#'   plain NA in the file, offered beside the conversion.
#'
#' @return Character scalar suitable for passing to \code{stop()}.
#'
#' @keywords internal
.jst_jsave_dta_error_msg <- function(spss_vars, data_name,
                                     text_vars = character(0),
                                     pd_line = NULL) {

  output_level <- getOption(".jst_output_level", "standard")
  n_total      <- length(spss_vars)
  is_sg        <- (n_total == 1)
  noun         <- if (is_sg) "variable" else "variables"
  verb_carry   <- if (is_sg) "carries" else "carry"

  # A text variable with declared missing values (Session 351, the S340
  # item): jconvert(to = "stata") refuses one since v0.9.214, so the line
  # this message offered stopped. Offered instead: its declared values made
  # plain NA, then the rest converted -- which is what a .dta file can
  # hold -- or jencode() first, which keeps them.
  route <- if (length(text_vars) > 0L) {
    .jst_text_route(data_name, "stata", text_vars,
                    convert_rest = length(setdiff(spss_vars, text_vars)) > 0L)
  } else NULL
  calls <- if (is.null(route)) {
    paste0("  jconvert(", data_name, ", to = \"stata\", modify = TRUE)")
  } else route$calls

  # --- Minimal tier -------------------------------------------------------
  if (identical(output_level, "minimal")) {
    return(paste(c(
      paste0(n_total, " ", noun, " ", verb_carry,
             " SPSS-style missing values, incompatible with the .dta format."),
      "Convert first, then save again:",
      calls,
      if (!is.null(route)) route$note,
      if (!is.null(pd_line)) c("Or save every declared missing value as plain NA instead:", pd_line)), collapse = "\n"))
  }

  # --- Standard / full tier ----------------------------------------------
  # S267: aligned to the trio's .sav/.xpt shape -- colon head, list glued
  # to it, blank after the list.
  paste(c(
    paste0(n_total, " ", noun, " ", verb_carry,
           " SPSS-style missing values, incompatible with the .dta format:"),
    paste0("  ", .jst_format_var_list(spss_vars)),
    "",
    if (is.null(route)) {
      "Before saving to Stata format, convert with:"
    } else {
      paste0("Before saving to Stata format, run",
             if (length(calls) == 2L) " both:" else ":")
    },
    calls,
    if (!is.null(route)) c(route$note,
      paste0("Or turn ", .jst_plural(length(text_vars), "it", "each"),
             " into a numeric variable first with jencode().")),
    # Session 361 (the S218 item): the save that blanks them instead.
    if (!is.null(pd_line)) c("Or save every declared missing value as plain NA instead:", pd_line)),
    collapse = "\n")
}

#' Internal: a variable list as the vars = argument of a printed call
#'
#' One name as a quoted string, several as c() of quoted strings --
#' \code{vars = "S"}, \code{vars = c("S", "T")} -- through deparse(), so a
#' name holding a quotation mark or a backslash is written as R reads it.
#' @param v Character vector of variable names.
#' @return Character scalar.
#' @keywords internal
.jst_names_arg <- function(v) {
  paste(deparse(unname(as.character(v)), width.cutoff = 500L), collapse = "")
}

#' Internal: the route to Stata-style or SAS-style missing values for a frame
#' holding text variables with declared missing values
#'
#' A marker is a kind of NA in a NUMERIC variable, so jconvert() refuses a
#' text variable with declared missing values under to = "stata" or "sas"
#' (Session 340), and every message that offered the whole-frame
#' conversion printed a call that stopped (the S340 item, built Session
#' 351). What runs: the text variables' declared values made plain NA,
#' then the frame converted -- the order matters, since the conversion
#' refuses while a declared string remains -- with one sentence naming
#' what the first line does. The load narrative's Case 1 line takes
#' to = "baseR" for the same reason (v0.9.214).
#'
#' @param data_name The data frame's name, for the printed calls.
#' @param to "stata" or "sas".
#' @param text_vars The text variables with declared missing values.
#' @param convert_rest Logical: does a variable remain for the second call
#'   to convert? FALSE leaves the first call alone, its sentence saying
#'   "this" for "the first line".
#' @param more_lines Logical: will the caller print a line after these
#'   calls (the joptions() rider)? Then the sentence says "the first line"
#'   even when there is one call.
#' @return A list: \code{calls}, the indented call lines; \code{note}, the
#'   sentence.
#' @keywords internal
.jst_text_route <- function(data_name, to, text_vars, convert_rest = TRUE,
                            more_lines = FALSE) {
  n <- length(text_vars)
  base_line <- paste0("  jconvert(", data_name, ", vars = ",
                      .jst_names_arg(text_vars), ", to = \"baseR\", modify = TRUE)")
  conv_line <- paste0("  jconvert(", data_name, ", to = \"", to, "\"",
                      ", modify = TRUE)")
  list(
    calls = if (isTRUE(convert_rest)) c(base_line, conv_line) else base_line,
    note  = paste0(.jst_format_var_list(text_vars, and = TRUE), " ",
                   .jst_plural(n, "is", "are"), " text, so ",
                   if (isTRUE(convert_rest) || isTRUE(more_lines)) {
                     "the first line"
                   } else "this",
                   " makes ", .jst_plural(n, "its", "their"),
                   " declared values plain NA."))
}

#' Internal: the text variables among those with SPSS-style declarations
#'
#' The variables of \code{vars} whose declared missing values sit on a text
#' (string) variable, read through \code{.jst_missing_info()}'s \code{text}
#' flag. jconvert() cannot give these Stata-style or SAS-style missing
#' values (Session 340), so a message offering that conversion asks first
#' (Session 351).
#' @param data A data frame.
#' @param vars Names of its variables to consider; default every one.
#' @return Character vector, possibly empty.
#' @keywords internal
.jst_declared_text_vars <- function(data, vars = names(data)) {
  vars[vapply(vars, function(v) {
    info <- .jst_missing_info(data[[v]])
    !is.null(info) && identical(info$representation, "spss") &&
      isTRUE(info$text)
  }, logical(1))]
}

#' Internal: the text route for a whole frame, when it needs one
#'
#' Five more messages offered the whole-frame jconvert(to = "stata" or
#' "sas") that stops on a text variable with declared missing values
#' (Session 352; the S351 item): joptions()'s workspace check, the
#' convert-first remedy of the marker error a column of SPSS-style missing
#' values gets, jrecode()'s ambiguous-missing stop and its marker refusal,
#' and jdeclare_missing()'s note on a setting the variables do not use. Each
#' asks this helper first: NULL when the plain call runs -- a target that
#' is not "stata" or "sas", or no declared string in the frame -- else
#' \code{.jst_text_route()}'s calls and sentence, the second call kept only
#' when a variable of another form remains to convert.
#'
#' @param data The data frame.
#' @param data_name Its name, for the printed calls.
#' @param to The conversion target.
#' @param more_lines Passed to \code{.jst_text_route()}.
#' @return NULL, or the list \code{.jst_text_route()} returns.
#' @keywords internal
.jst_frame_text_route <- function(data, data_name, to, more_lines = FALSE) {
  if (!is.data.frame(data) || length(to) != 1L ||
      !isTRUE(to %in% c("stata", "sas"))) return(NULL)
  tv <- .jst_declared_text_vars(data)
  if (length(tv) == 0L) return(NULL)
  rest <- any(vapply(setdiff(names(data), tv), function(v) {
    info <- .jst_missing_info(data[[v]])
    !is.null(info) && !identical(info$convention, to)
  }, logical(1)))
  .jst_text_route(data_name, to, tv, convert_rest = rest,
                  more_lines = more_lines)
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
#' @param pd_line The offered jsave() call with
#'   \code{preserve.declarations = FALSE}, indented, or NULL (Session 361,
#'   the S218 item): the save that makes every declared missing value
#'   plain NA in the file, which replaces the jconvert(to = "baseR") line as
#'   the drop route (it leaves the data frame as it is).
#'
#' @return Character scalar suitable for passing to \code{stop()}.
#'
#' @keywords internal
.jst_jsave_xpt_error_msg <- function(vars, data_name,
                                     spss_vars = character(0),
                                     pd_line = NULL) {

  output_level <- getOption(".jst_output_level", "standard")
  all_vars     <- unique(c(vars, spss_vars))
  n            <- length(all_vars)
  is_sg        <- (n == 1)
  noun         <- if (is_sg) "variable" else "variables"
  # S355 (the S282 item): "carry", the verb of the .dta refusal and of every
  # declared-value sentence; the three refusals said "carry", "contain" and
  # "contain".
  verb_contain <- if (is_sg) "carries" else "carry"

  has_tagged <- length(vars) > 0
  has_spss   <- length(spss_vars) > 0

  # The drop route (Session 361, the S218 item): the save that makes every
  # declared missing value plain NA in the file and leaves the data frame
  # as it is (voice Rule G), where the message offered jconvert(to =
  # "baseR", modify = TRUE), which made them NA in the data frame too.
  drop_line <- if (!is.null(pd_line)) pd_line else
    paste0("  jconvert(", data_name, ", to = \"baseR\", modify = TRUE)")

  # The preserve-path advice depends on which missing-value form is
  # present: tagged NAs round-trip via .dta, SPSS-form declarations via
  # .sav, and a frame carrying both forms has no single ReadStat target
  # until the forms are unified with jconvert(). The generic
  # "missing-value codes" wording is the locked Session-36 carve-out for
  # .xpt messages.
  if (identical(output_level, "minimal")) {
    preserve <- if (has_tagged && has_spss) {
      paste0("To preserve them, convert them to one form with jconvert() ",
             "and save as SPSS format (.sav) or Stata format (.dta).")
    } else if (has_spss) {
      "To preserve them, save as SPSS format (.sav)."
    } else {
      "To preserve them, save as Stata format (.dta)."
    }
    return(paste0(
      n, " ", noun, " ", verb_contain,
      " missing-value codes, incompatible with the .xpt format.\n",
      preserve, " To drop them:\n", drop_line))
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
    if (!is.null(pd_line)) {
      "To save as .xpt with every declared missing value as plain NA, run:\n"
    } else "To save as .xpt, drop these by running:\n",
    drop_line, "\n\n",
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
#' @param pd_line The offered jsave() call with
#'   \code{preserve.declarations = FALSE}, indented, or NULL (Session 361,
#'   the S218 item): the save that makes every declared missing value
#'   plain NA in the file, offered beside the conversion.
#'
#' @return Character scalar suitable for passing to \code{stop()}.
#'
#' @keywords internal
.jst_jsave_sav_error_msg <- function(vars, data, data_name, pd_line = NULL) {

  output_level <- getOption(".jst_output_level", "standard")
  n            <- length(vars)
  is_sg        <- (n == 1)
  noun         <- if (is_sg) "variable" else "variables"
  verb_contain <- if (is_sg) "carries" else "carry"   # S355, as the .dta's

  # Inspect tag case across the flagged columns to pick the right
  # style phrase. Stata convention uses lowercase letters (.a, .b, ...);
  # SAS convention uses uppercase (.A, .B, ...); both can in principle
  # coexist either across columns or within a single column. The probe
  # reads the labels as well as the cells (S314): a column is flagged when
  # a value label alone declares its marker, and such a column has a case
  # too -- before, a label-only .A column read as "Stata-style".
  has_lower <- FALSE
  has_upper <- FALSE
  for (v in vars) {
    tags <- .jst_marker_tags(data[[v]])$all
    if (any(grepl("[a-z]", tags))) has_lower <- TRUE
    if (any(grepl("[A-Z]", tags))) has_upper <- TRUE
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
      style_phrase, ", incompatible with the .sav format.\n",
      "Convert first, then save again:\n",
      "  jconvert(", data_name, ", to = \"spss\", modify = TRUE)",
      if (!is.null(pd_line)) paste0("\n", "Or save every declared missing value as plain NA instead:", "\n", pd_line)))
  }

  # --- Standard / full tier ----------------------------------------------
  paste0(
    n, " ", noun, " ", verb_contain, " ",
    style_phrase, ", incompatible with the .sav format:\n",
    "  ", .jst_format_var_list(vars), "\n\n",
    "Before saving to SPSS format, convert to SPSS-style missing values ",
    "with:\n",
    "  jconvert(", data_name, ", to = \"spss\", modify = TRUE)",
    # Session 361 (the S218 item): the save that blanks them instead.
    if (!is.null(pd_line)) paste0("\n", "Or save every declared missing value as plain NA instead:", "\n", pd_line)
  )
}


#' Internal: build jsave's error message for SPSS-form UDM columns that exceed
#' the .sav missing-value limit
#'
#' SPSS .sav files allow at most three discrete user-defined-missing codes per
#' variable, or a range plus one discrete code. haven::write_sav() enforces
#' SPSS's own rule and errors mid-write (leaving a partial file) on a column
#' carrying more, so jsave()'s .sav pre-flight catches these first. Because the
#' Stata-side cap is 26 (Decision 4, Session 121), converting to Stata and
#' saving as .dta is a keep-all route alongside .rds, so both non-lossy options
#' are offered before the lossy jrecode() reduction.
#'
#' @param overcap_info List of per-variable entries, each a list with
#'   \code{var} (name), \code{n} (count of discrete na_values codes), and
#'   \code{range} (logical: does the column also carry an na_range?).
#' @param data_name The data frame's name, used in the suggested fix code.
#' @param text_vars The frame's text variables with declared missing values
#'   (Session 351). When there are any, the Stata route is not offered: a
#'   .dta file cannot keep a text variable's declared missing values, so
#'   its "also keeping all the codes" would be false, and its jconvert()
#'   line stops on them (the S340 item; Jeff's lean, S351).
#' @param prose_name The data frame as the sentence names it; by default
#'   \code{data_name}. jsave() gives the typed expression here when the
#'   lines name mydata (Session 352).
#' @param stem The name the offered files take; by default
#'   \code{data_name}. Until Session 352 the data argument as typed,
#'   which for an expression gave a file name that does not parse.
#' @param pd_line The offered jsave() call with
#'   \code{preserve.declarations = FALSE}, indented, or NULL (Session 361,
#'   the S218 item): the save that makes every declared missing value
#'   plain NA in the file, offered beside the conversion.
#'
#' @return Character scalar suitable as a \code{.jst_jsave_combined_error_msg}
#'   section (no \code{jsave():} prefix; that is added on emission).
#' @keywords internal
.jst_jsave_sav_overcap_error_msg <- function(overcap_info, data_name,
                                             text_vars = character(0),
                                             prose_name = data_name,
                                             stem = data_name,
                                             pd_line = NULL) {

  output_level <- getOption(".jst_output_level", "standard")
  n     <- length(overcap_info)
  is_sg <- (n == 1)
  noun  <- if (is_sg) "variable" else "variables"
  verb  <- if (is_sg) "has"      else "have"
  stata_route <- length(text_vars) == 0L

  # --- Minimal tier -------------------------------------------------------
  if (identical(output_level, "minimal")) {
    return(paste0(
      n, " ", noun, " ", verb, " more declared missing values than SPSS format (.sav) ",
      "allows (at most 3, or a range plus one).\n",
      if (stata_route) {
        paste0("Save as R format (.rds) or ",
               "convert to Stata format (.dta) to keep all the codes, or reduce ",
               "them first.")
      } else {
        "Save as R format (.rds) to keep all the codes, or reduce them first."
      },
      if (!is.null(pd_line)) paste0("\n", "Or save every declared missing value as plain NA instead:", "\n", pd_line)
    ))
  }

  # --- Standard / full tier ----------------------------------------------
  var_lines <- .jst_cap_var_lines(vapply(overcap_info, function(e) {
    if (isTRUE(e$range)) sprintf("  %s: range + %d codes", e$var, e$n)
    else                 sprintf("  %s: %d codes", e$var, e$n)
  }, character(1)))

  lead <- sprintf("%s %s in %s %s more:",
                  if (is_sg) "This" else "These", noun, prose_name, verb)

  # S267 redraft: family treatment (locked generic term, Rule L
  # two-space remedies, Rule X, unnumbered alternatives).
  paste(c(
    "SPSS format (.sav) allows at most 3 declared missing values per variable, or a range plus one code.",
    "",
    lead,
    var_lines,
    "",
    "To save in R format (.rds) instead, keeping all the codes:",
    sprintf("  jsave(%s, \"%s.rds\")", data_name, stem),
    if (stata_route) c(
      "To convert to Stata and save as Stata format (.dta), also keeping all the codes:",
      sprintf("  jconvert(%s, to = \"stata\", modify = TRUE)", data_name),
      sprintf("  jsave(%s, \"%s.dta\")", data_name, stem)),
    # Session 361 (the S218 item): SPSS format, every declared missing
    # value saved as plain NA.
    if (!is.null(pd_line)) c(
      "To save as SPSS format (.sav) with every declared missing value as plain NA:",
      pd_line),
    "Or reduce each variable's declared missing values to fit."
  ), collapse = "\n")
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

  # Minimal tier: join the compact section messages, no frame. Newline
  # join (S230): sections are Rule E split internally, so a space join
  # would glue the next section onto the previous one mid-line.
  if (identical(output_level, "minimal")) {
    return(paste(unlist(sections), collapse = "\n"))
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
      # A label rewrite above went through labelled::val_labels<-, which
      # rebuilds without the haven display format -- and this column is
      # on its way to write_dta(), which reads format.stata. Restore the
      # passengers from the untouched original (S299).
      data[[vname]] <- .jst_carry_col_attrs(data[[vname]], col)
      n_changed   <- n_changed + 1L
    }
  }

  list(data = data, n_changed = n_changed)
}


#' Internal helper: jsave's undeclared-stray release note
#'
#' The RELEASE-side note of the S239 mint/observe/release framework:
#' \code{jsave()} is the boundary past which the package can no longer
#' reach the data, so an undeclared suspicious code written to a
#' declaration-carrying format is reported ONCE, when the frame's own
#' metadata supplies the evidence. Fires only when all three hold:
#' the target format carries declarations (gated at the call site);
#' another column declares missing values in the same style (SPSS-form
#' numeric declarations -- tag-form columns are self-declaring, so no
#' undeclared-tag state exists and tags do not testify about numeric
#' strays); and an undeclared suspicious code sits on a column. Silent
#' when the frame declares nothing anywhere (the pure-guess case).
#' Groups by column when codes differ; the remedy is a runnable
#' declare-then-resave pair.
#'
#' @param data The data frame as written (post any preserve.declarations
#'   collapse, so a stripped frame has no evidence and stays silent).
#' @param data_name Character. The frame's display name.
#' @param file_arg Character. The normalized (forward-slash) target
#'   path, echoed into the resave line. Never the raw file argument: a
#'   Windows backslash path inside the quoted recipe is a parse error
#'   on paste.
#'
#' @return Character scalar note, or \code{NULL} when nothing fires.
#'
#' @keywords internal
.jst_jsave_release_notes <- function(data, data_name, file_arg) {
  # Evidence columns (Reading 2, S239): numeric-code (SPSS-form)
  # declarations. Tag-form columns are self-declaring and do not testify
  # about numeric strays, so they are neither evidence nor exempt.
  infos <- lapply(data, .jst_missing_info)
  evidence_cols <- names(data)[vapply(infos, function(i) {
    !is.null(i) && identical(i$representation, "spss")
  }, logical(1))]
  if (length(evidence_cols) == 0L) return(NULL)

  strays <- list()
  for (vn in names(data)) {
    col <- data[[vn]]
    if (is.character(col) || is.factor(col) || is.logical(col) ||
        inherits(col, c("Date", "POSIXct", "POSIXlt", "difftime"))) {
      next
    }
    susp <- .jst_detect_suspicious_values(col, vn)
    if (length(susp) == 0L) next
    info <- infos[[vn]]
    if (!is.null(info)) {
      if (!is.null(info$codes)) susp <- setdiff(susp, info$codes$numeric)
      if (!is.null(info$na_range)) {
        susp <- susp[susp < info$na_range[1] | susp > info$na_range[2]]
      }
    }
    if (length(susp) == 0L) next
    # "Other columns": the evidence must sit somewhere besides the stray
    # column itself, or the note's own sentence would be false.
    if (length(setdiff(evidence_cols, vn)) == 0L) next
    strays[[vn]] <- sort(susp)
  }
  if (length(strays) == 0L) return(NULL)

  vars     <- names(strays)
  n_codes  <- length(unlist(strays))
  plural   <- n_codes > 1L
  pair_txt <- vapply(vars, function(vn) {
    paste0(.jst_and_list(vapply(strays[[vn]], .jst_fmt_code,
                                character(1))),
           " in ", vn)
  }, character(1))
  oth <- setdiff(evidence_cols, vars)
  if (length(oth) == 0L) oth <- evidence_cols
  oth_one <- length(oth) == 1L

  head1 <- paste0(
    "Note: ", .jst_and_list(pair_txt),
    if (plural) " are" else " is",
    " not declared as missing, though ",
    if (oth_one) "another column in " else "other columns in ",
    data_name,
    if (oth_one) " declares " else " declare ",
    "SPSS-style missing values.")
  head2 <- if (plural) {
    paste0("They were written to the file as ordinary values, so other ",
           "software will read them as valid data.")
  } else {
    paste0("It was written to the file as an ordinary value, so other ",
           "software will read it as valid data.")
  }
  decl_lines <- vapply(vars, function(vn) {
    cs <- strays[[vn]]
    ct <- if (length(cs) == 1L) {
      .jst_fmt_code(cs)
    } else {
      paste0("c(", paste(vapply(cs, .jst_fmt_code, character(1)),
                         collapse = ", "), ")")
    }
    paste0("  jdeclare_missing(", data_name, ", ", vn, ", codes = ", ct,
           ", modify = TRUE)")
  }, character(1))
  jsave_line <- paste0("  jsave(", data_name, ", \"", file_arg,
                       "\", overwrite = TRUE)")
  n_lines <- length(decl_lines) + 1L
  intro <- paste0("To declare ", if (plural) "them" else "it",
                  " and save again, run",
                  if (n_lines == 2L) " both:" else ":")

  paste0(head1, "\n", head2, "\n",
         intro, "\n", paste(decl_lines, collapse = "\n"), "\n",
         jsave_line)
}



#' Internal: jsave()'s note on declared missing values saved as plain NA
#'
#' Session 361 (the S218 item). \code{preserve.declarations = FALSE} makes
#' every declared missing value plain NA before the write, and since this
#' session it does so ahead of the .sav, .dta and .xpt pre-flight. After a
#' write to any format but Excel and CSV (whose loss note gives the same
#' count), this note says what happened: the cells that held a declared
#' value -- an SPSS-style code, or a Stata-style or SAS-style marker -- or,
#' when none did, that the declarations were dropped.
#' @param n Integer, the cells blanked.
#' @return Character scalar.
#' @keywords internal
.jst_jsave_blanked_note <- function(n) {
  if (n > 0L) {
    paste0("Note: ", n, " ",
           .jst_plural(n, "cell holding a declared missing value was",
                       "cells holding declared missing values were"),
           " blanked (preserve.declarations = FALSE).")
  } else {
    paste0("Note: no cell held a declared missing value; the declarations ",
           "were dropped (preserve.declarations = FALSE).")
  }
}


#' Internal: build the label / missing-value loss note for Excel and CSV saves
#'
#' @description
#' Excel and CSV cannot store variable labels, value labels, or
#' missing-value declarations. jsave emits a note after a successful write
#' to these formats describing what was (or, under
#' \code{preserve.declarations = FALSE}, would have been) lost. The wording
#' depends on which missing-value form the frame carried and on whether
#' \code{preserve.declarations = FALSE} blanked the codes.
#'
#' @details
#' Since Session 359 (the S357 item, Jeff's walk of
#' missing_convention_walk.R Section 30) the note says only what the frame
#' had to lose and names what the package knows:
#' \itemize{
#'   \item The first line names labels only when a variable carries a
#'     variable label or value labels (the registration note's rule: it
#'     fires only on registrations), and missing-value metadata only when a
#'     variable declares missing values. A frame with neither gets no note.
#'   \item SPSS-style codes write as literal numbers. The variables and the
#'     declared codes their cells hold are named -- "Income's declared
#'     missing value -99 is written as an ordinary number and will read
#'     back as valid data." -- where the note said "Any SPSS-style missing
#'     values (e.g. -99)". A declared code no cell holds writes nothing,
#'     and is not named.
#'   \item The way to write them as empty cells is the jsave() call to
#'     run, with the data's name and the path just written, where the note
#'     gave "jsave(..., preserve.declarations = FALSE)", which does not run
#'     as printed (the S343 rule).
#'   \item Stata-style missing values write as blank cells; the
#'     distinction between them is not preserved.
#'   \item \code{preserve.declarations = FALSE} that blanked SPSS-style
#'     codes: a confirmation giving the count of blanked cells.
#' }
#' The note is a loss-of-fidelity warning per the locked jsave design; it is
#' not gated to the joutput verbosity tiers.
#'
#' @param ext Lowercase target extension, \code{"xlsx"} or \code{"csv"}.
#' @param spss_vars Character vector of SPSS-form UDM variable names, as
#'   detected before any collapse.
#' @param stata_vars Character vector of Stata-form tagged-NA variable
#'   names, as detected before any collapse.
#' @param preserve.declarations Logical, the value passed to jsave.
#' @param n_blanked Integer count of SPSS-style code cells blanked when
#'   \code{preserve.declarations = FALSE}; zero otherwise.
#' @param text_udm Logical: is one of \code{spss_vars} a text variable?
#'   Its declared codes are words, so "ordinary numbers" becomes "ordinary
#'   values" (Session 351, the S340 item's rider).
#' @param data The data frame as given, before any collapse: its labels
#'   and declarations.
#' @param code_name Character; the data as the printed line names it
#'   (\code{mydata} for an expression, whose line the caller opens with
#'   "mydata <- ...").
#' @param path Character; the path written, normalized.
#'
#' @return A single message string, or \code{NULL} if no note applies.
#'
#' @keywords internal
.jst_jsave_label_loss_note <- function(ext, spss_vars, stata_vars,
                                       preserve.declarations, n_blanked,
                                       text_udm = FALSE, data = NULL,
                                       code_name = NULL, path = NULL) {
  fmt <- if (identical(ext, "xlsx")) {
    "Excel format (.xlsx)"
  } else {
    "CSV format (.csv)"
  }
  has_spss  <- length(spss_vars)  > 0
  has_stata <- length(stata_vars) > 0
  has_labels <- if (is.null(data)) TRUE else {
    any(vapply(data, function(x) {
      vl <- attr(x, "label", exact = TRUE)
      length(attr(x, "labels", exact = TRUE)) > 0L ||
        (!is.null(vl) && any(nzchar(vl)))
    }, logical(1)))
  }
  labels_line <- function(meta) {
    if (has_labels && meta) {
      paste0(fmt, " does not store variable labels, value labels, or ",
             "missing-value metadata.")
    } else if (has_labels) {
      paste0(fmt, " does not store variable labels or value labels.")
    } else if (meta) {
      paste0(fmt, " does not store missing-value metadata.")
    } else {
      NULL
    }
  }

  # preserve.declarations = FALSE that blanked SPSS-style codes -> confirm.
  if (!preserve.declarations && has_spss && n_blanked > 0) {
    blanked <- paste0(
      n_blanked, " ",
      .jst_plural(n_blanked, "cell holding a declared missing value was",
                  "cells holding declared missing values were"),
      " blanked (preserve.declarations = FALSE).")
    ll <- labels_line(FALSE)
    return(.jst_wrap_message(paste0(
      # Rule E and the count's number (the Session 123 sweep; Session 357).
      "Note: ", if (!is.null(ll)) paste0(ll, "\n"), blanked)))
  }

  ll <- labels_line(has_spss || has_stata)
  if (is.null(ll)) return(NULL)
  body    <- character(0)
  pointer <- NULL

  # SPSS-style: the variables and the declared codes their cells hold.
  if (has_spss) {
    held <- list()
    for (v in spss_vars) {
      x  <- data[[v]]
      if (is.null(x)) next
      vals <- unclass(x)
      attributes(vals) <- NULL
      nv <- attr(x, "na_values", exact = TRUE)
      nr <- attr(x, "na_range", exact = TRUE)
      hit <- !is.na(vals) & vals %in% nv
      if (length(nr) == 2L && is.numeric(vals)) {
        hit <- hit | (!is.na(vals) & vals >= nr[1L] & vals <= nr[2L])
      }
      codes <- sort(unique(vals[hit]))
      if (length(codes) > 0L) held[[v]] <- codes
    }
    if (length(held) > 0L) {
      show_code <- function(z) {
        if (is.character(z)) paste0("\"", z, "\"")
        else if (z == floor(z)) format(z, scientific = FALSE, trim = TRUE)
        else format(z, trim = TRUE)
      }
      code_list <- function(cs) {
        sh <- vapply(cs, show_code, character(1))
        if (length(sh) > 4L) {
          sh <- c(sh[1:3], paste0(length(sh) - 3L, " more"))
        }
        .jst_and_list(sh)
      }
      n_codes <- sum(lengths(held))
      plural  <- n_codes > 1L
      kind    <- if (isTRUE(text_udm)) "value" else "number"
      subject <- if (length(held) == 1L) {
        paste0(names(held), "'s declared missing ",
               if (plural) "values " else "value ", code_list(held[[1L]]))
      } else if (length(held) <= 3L) {
        paste0("The declared missing values of ",
               .jst_and_list(vapply(names(held), function(v) {
                 paste0(v, " (", code_list(held[[v]]), ")")
               }, character(1))))
      } else {
        paste0("The declared missing values of ", length(held),
               " variables (", .jst_format_var_list(names(held),
                                                     max_show = 3L), ")")
      }
      body <- c(body, paste0(
        subject, if (plural) " are" else " is", " written as ",
        if (plural) paste0("ordinary ", kind, "s") else
          paste0("an ordinary ", kind),
        " and will read back as valid data."))
      if (!is.null(code_name) && !is.null(path)) {
        pointer <- paste0(
          "To write ", if (plural) "them as empty cells" else
            "it as an empty cell", " instead, save with:\n",
          "  jsave(", code_name, ", \"", path, "\", overwrite = TRUE, ",
          "preserve.declarations = FALSE)")
      }
    }
  }

  # The way out directly under the fact it answers: "it" is the SPSS-style
  # code, so the Stata-style sentence follows it.
  body <- c(body, pointer)

  # Stata-style: brief flatten note.
  if (has_stata) {
    body <- c(body, paste0(
      "Stata-style missing values (.a, .b, ...) are ",
      "written as blank cells; the distinction between them is not ",
      "preserved."))
  }

  .jst_wrap_message(paste0("Note: ", paste(c(ll, body), collapse = "\n")))
}


#' Internal: the note for a text variable's missing cells that a format
#' writes as blank text
#'
#' @description
#' Ruling R13 (Jeff, S345; built Session 351). SPSS format (.sav), Stata
#' format (.dta), SAS interchange format (.xpt) and CSV format (.csv) have
#' no missing value for text: haven and write.csv() write a text
#' variable's NA as an empty string, and jload() reads that back as the
#' \code{<blank>} category, counted as valid (the S340 decision: a blank is
#' reported, never assumed missing, and a file cannot say which blanks were
#' once missing). So jsave() says so when it happens: the variables, the
#' cells, and the two formats that keep them (.rds, .xlsx). The .xpt format
#' and a factor in a CSV file (written as its labels) lose the same way,
#' probed at S351 and added on Jeff's lean. A missing NUMBER survives every
#' format. A loss note, as the label and declaration losses are: not gated
#' to the joutput() levels.
#'
#' @param data The data frame as written.
#' @param ext Lowercase target extension.
#' @return The note, or NULL when the format keeps text NA or the frame has
#'   none.
#' @keywords internal
.jst_jsave_text_na_note <- function(data, ext) {
  if (!ext %in% c("sav", "dta", "xpt", "csv")) return(NULL)
  is_text <- function(col) {
    is.character(col) || (identical(ext, "csv") && is.factor(col))
  }
  # unclass(): is.na() on a declared string counts its declared values too.
  counts <- vapply(data, function(col) {
    if (!is_text(col)) return(0L)
    sum(is.na(unclass(col)))
  }, integer(1))
  vars <- names(data)[counts > 0L]
  if (length(vars) == 0L) return(NULL)
  n     <- counts[vars]
  total <- sum(n)
  kind  <- if (any(vapply(data[vars], is.factor, logical(1)))) {
    "a text or categorical variable"
  } else {
    "a text variable"
  }
  where <- if (length(vars) == 1L) {
    vars
  } else {
    .jst_format_var_list(paste0(vars, " (", n, ")"), and = TRUE)
  }
  paste0(
    "Note: ", .jst_format_label(ext), " (.", ext, ") cannot store a missing ",
    "value in ", kind, ".\n",
    total, " missing ", .jst_plural(total, "cell", "cells"), " in ", where,
    " ", .jst_plural(total, "was", "were"), " saved as blank text.\n",
    "R format (.rds) and Excel format (.xlsx) keep ",
    .jst_plural(total, "it", "them"), " missing.")
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
#' directory separator (\code{/}, or a backslash) bypass this setting and
#' are taken literally.
#'
#' If the \code{data} argument is omitted, the default data frame set by
#' \code{juse()} is used.
#'
#' @param data A data frame (unquoted). If omitted, uses the default set by
#'   \code{juse()}.
#' @param file Character string. The filename with extension (e.g.
#'   \code{"mydata.sav"}) or a full file path. Use forward slashes in
#'   file paths. If the extension is omitted, \code{.rds} is used and
#'   added to the filename.
#' @param overwrite Logical. If \code{TRUE}, overwrites an existing file
#'   without prompting. If \code{FALSE} (default), prompts for confirmation
#'   in interactive sessions. In non-interactive sessions, stops with an
#'   error. In a script, state it explicitly:
#'   \code{jsave(mydata, "mydata.rds", overwrite = TRUE)}. Otherwise, if
#'   the file already exists and the script was run by pasting or with
#'   RStudio's Run button, the call stops with an error.
#' @param preserve.declarations Logical. If \code{TRUE} (the default),
#'   missing-value declarations are written as they stand; formats that
#'   cannot store them (notably Excel and CSV) drop the metadata, and
#'   SPSS-style codes such as -99 then read back as ordinary numbers, while
#'   a missing-value form that .sav, .dta, or .xpt cannot represent stops
#'   the save before anything is written. If \code{FALSE}, every declared
#'   missing value -- an SPSS-style code, or a Stata-style or SAS-style
#'   marker -- is made plain NA before writing, in the file only (the data
#'   frame is not changed), and a note gives the number of cells. This
#'   happens before the .sav, .dta, and .xpt checks, so a form those
#'   formats cannot represent no longer stops the save. Mirrors the
#'   \code{preserve.declarations} argument of \code{\link{jload}}. The
#'   haven package and its documentation call these user-defined missing
#'   values.
#' @param clean.names Logical. For \code{.sav}, \code{.dta} and \code{.xpt}.
#'   If \code{FALSE} (the default), a variable name the format cannot hold
#'   stops the save, listing every such name, why, and the name it would be
#'   given. If \code{TRUE}, those names are changed in the file only, the
#'   way \code{\link{jload}} changes names R cannot use; the data frame
#'   keeps its own names, each old name becomes the variable's label in the
#'   file where it has none, and a note lists the changes.
#'
#' @return Invisibly returns \code{NULL}. Called for its side effect of
#'   writing a file to disk.
#'
#' @details
#' \strong{File paths:}
#' Use forward slashes (\code{/}) in file paths. If you copy a path from
#' Windows File Explorer, replace the backslashes with forward slashes.
#' R does not accept single backslashes in file paths: inside quoted text
#' it reads a backslash and the letter after it as one special character.
#' \code{jsave()} stops on such a path, before anything is written, and
#' shows it written with forward slashes.
#'
#' \strong{File location:}
#' \itemize{
#'   \item If the path contains a directory separator, the file is saved
#'     to that exact location; the folder must already exist.
#'   \item If the path is a bare filename and the \code{data.dir} setting in
#'     \code{\link{joptions}} is set, the file is saved to that folder
#'     (\code{joptions()} creates it when the setting is made; it is
#'     created again here if it has been removed since).
#'   \item If the path is a bare filename and the \code{data.dir} setting in
#'     \code{\link{joptions}} is unset (the default), the file is saved to the
#'     working directory.
#' }
#'
#' \strong{Format notes:}
#' \itemize{
#'   \item SPSS (\code{.sav}) and Stata (\code{.dta}) preserve variable
#'     labels and value labels.
#'   \item Excel (\code{.xlsx}) and CSV (\code{.csv}) do not preserve
#'     variable or value labels.
#'   \item R format (\code{.rds}) preserves the data frame exactly as it
#'     exists in R, including all attributes.
#'   \item R format (\code{.rds}) also carries the active classification
#'     registrations (see \code{\link{jdummy}}, \code{\link{jnumeric}},
#'     \code{\link{jcount}}, and \code{\link{jlikert}}), which
#'     \code{\link{jload}} restores. Other formats cannot store them, and
#'     a note says so when any are lost.
#'   \item Before writing \code{.sav}, \code{.dta}, or \code{.xpt},
#'     \code{jsave()} checks for anything the format cannot store and
#'     stops, naming every problem at once: complex, raw, list, or
#'     POSIXlt columns; missing values of a form the format cannot hold
#'     (Stata-style in \code{.sav}, SPSS-style in \code{.dta}, either in
#'     \code{.xpt}); and, for \code{.sav}, more than three declared codes,
#'     or a range plus more than one code, on one column. No file is
#'     written until the problems are fixed. A missing-value form the
#'     format cannot hold can also be saved as plain NA with
#'     \code{preserve.declarations = FALSE}, which the message offers
#'     beside the conversion.
#'   \item SPSS (\code{.sav}), Stata (\code{.dta}), SAS interchange
#'     (\code{.xpt}) and CSV (\code{.csv}) have no missing value for text:
#'     a text variable's missing cells are saved as blank text, and read
#'     back as blank, not missing. A note says so when it happens. R format
#'     (\code{.rds}) and Excel (\code{.xlsx}) keep them missing. In a CSV
#'     file the same holds for a factor, which is written as its labels.
#'   \item Variable names each format can hold: SPSS (\code{.sav}), a
#'     letter or @ first, then letters, digits and . _ $ # @, not ending in
#'     a period, at most 64 bytes, not a word SPSS reserves (ALL, AND, BY,
#'     EQ, GE, GT, LE, LT, NE, NOT, OR, TO, WITH), and no two that differ
#'     only in case; Stata (\code{.dta}), a letter or underscore first, then
#'     letters, digits and underscores, at most 32 characters, not a word
#'     Stata reserves (such as \code{long}, \code{in}, \code{byte}); SAS
#'     (\code{.xpt}), the letters A to Z, digits and underscores, not a digit
#'     first, at most 32 characters, and no two that differ only in case.
#'     A name outside these rules stops the save, naming every one at once,
#'     unless \code{clean.names = TRUE}.
#'   \item Labels each format shortens: SPSS keeps 256 bytes of a variable
#'     label and 120 of a value label; Stata keeps 80 characters of a
#'     variable label and of the data frame's label; SAS interchange keeps
#'     40 characters of the data frame's label. A note says what was
#'     shortened in the file; the data frame keeps its labels whole.
#'   \item An Excel sheet holds 1,048,575 cases below the names row and
#'     16,384 variables; a larger data frame stops with lines that save it
#'     in another format.
#'   \item Inside an \code{.xpt} file the SAS dataset is named after the
#'     file, changed to a SAS name when the file's name is not one (a note
#'     says so).
#'   \item A CSV file is written in UTF-8. When it holds a character
#'     beyond plain ASCII (an accented letter, a curly apostrophe, a
#'     dash), it starts with the UTF-8 byte-order mark, as Excel's own
#'     "CSV UTF-8" does, so that Excel opens it with those characters
#'     intact: without the mark, Excel on Windows reads a CSV file in
#'     Windows-1252. A file of plain ASCII has no mark. \code{jload()}
#'     reads the mark as the start of a UTF-8 file.
#'   \item Stata files are written as version 14 format.
#'   \item Legacy Excel format (\code{.xls}) is not supported for saving.
#'     Use \code{.xlsx} instead.
#' }
#'
#' @examples
#' # A runnable save into R's session temporary folder
#' jsave(community, file.path(tempdir(), "community.sav"), overwrite = TRUE)
#' jsave(data = community, file.path(tempdir(), "community.sav"),
#'       overwrite = TRUE)                   # the data frame given by name
#'
#' \dontrun{
#' # The file extension determines the format ---
#' # the same data frame can be saved in any supported format
#' jsave(community, "community.sav")         # SPSS
#' jsave(community, "community.xlsx")        # Excel
#' jsave(community, "community.csv")         # CSV
#' jsave(community, "community.rds")         # R format
#'
#' # Using juse() default
#' juse(community)
#' jsave("community.sav")
#'
#' # Full file path
#' jsave(community, "C:/Output/community.sav")
#'
#' # Stata and SAS formats cannot carry community's SPSS-style missing-value
#' # declarations -- convert first (jsave() pre-flights this and says so)
#' jconvert(community, to = "stata", modify = TRUE)
#' jsave(community, "community.dta")                  # Stata
#' jconvert(community, to = "baseR", modify = TRUE)
#' jsave(community, "community.xpt")                  # SAS interchange
#' }
#'
#' @seealso \code{\link{jstats}} for the package overview,
#'   workflow conventions, and complete function listing.
#'
#' @export
jsave <- function(data, file, overwrite = FALSE, preserve.declarations = TRUE,
                  clean.names = FALSE) {
  # Validate TRUE/FALSE flags up front.
  .jst_check_flag(overwrite, "overwrite")
  .jst_check_flag(preserve.declarations, "preserve.declarations")
  .jst_check_flag(clean.names, "clean.names")

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
  #   3. Expression that evaluates to NULL (e.g. jsave(MyData$BadCol,
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
  pre_eval <- NULL
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

    # Handed to the resolver below so the expression is not evaluated a
    # second time (AUDIT-052): an argument that prints a message, such as
    # jsave(jconvert(...), ...), printed it twice.
    pre_eval <- eval_result
    val <- eval_result$value
    if (is.null(val)) {
      data_str <- paste(deparse(data_sub), collapse = "")
      .jst_stop("'", data_str, "' is NULL. ",
           "Provide a data frame, e.g. jsave(MyData, \"mydata.sav\")")
    }
    # The resolver's sentence for the same input (S334 item, Session 351):
    # "'z' is a integer" pasted an article before the class.
    if (!is.data.frame(val) && !is.character(val)) {
      data_str   <- paste(deparse(data_sub), collapse = "")
      .jst_stop("'", data_str, "' is not a data frame.\n",
           "Provide a data frame, e.g. jsave(MyData, \"mydata.sav\")")
    }
    # A file name alone with no default set (the Session 40 item, Session
    # 351): the resolver asked "Did you mean to use it as a variable
    # name?" of a quoted file name. A string here is the file; what is
    # missing is the data frame.
    if (is.character(val) && length(val) == 1L && missing(file) &&
        is.null(getOption(".jst_default_data", default = NULL))) {
      .jst_stop(deparse(val), " is a file name, and no data frame was ",
                "given to save.\n",
                "Name the data frame first:\n",
                "  jsave(MyData, ", deparse(val), ")")
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
    accept_vector = FALSE,
    pre_eval      = pre_eval
  )

  data      <- arg1$data
  data_name <- arg1$name

  # The data as the printed lines name it (Session 352; the S351 item). An
  # expression given as the data -- jsave(oc86["X"], "oc86.sav") -- is
  # never pasted into a line to run: the pre-flight refusals pasted it
  # whole, into jsave(oc86["X"], "oc86["X"].rds"), which does not parse,
  # and into jconvert(oc86["X"], ..., modify = TRUE), which stops. Their
  # lines name mydata, and each block of them opens on "mydata <- ...",
  # the S339 form (.jst_expr_assign_lines()). A place (lst$d) keeps its
  # lines, which .jst_place_lines() makes run; its file is named by its
  # last part (.jst_data_file_stem()).
  data_kind <- if (identical(arg1$mode, "explicit")) {
    .jst_data_arg_kind(data_sub)
  } else "name"
  code_name <- if (identical(data_kind, "expression")) "mydata" else data_name
  code_stem <- .jst_data_file_stem(
    if (identical(arg1$mode, "explicit")) data_sub else NULL, data_name)
  expr_lines <- function(msg) {
    if (!identical(data_kind, "expression")) return(msg)
    .jst_expr_assign_lines(msg, .jst_term_text(data_sub))
  }

  # If data was omitted (e.g. jsave("file.rds")), route the captured first
  # argument into the file slot.
  if (arg1$mode == "symbol_with_default") {
    if (!missing(file)) {
      .jst_stop("when the data argument is omitted, all subsequent arguments must be named. ",
                "Use jsave(file = \"yourfile.ext\")",
                fn = "jsave")
    }
    file <- if (!is.null(pre_eval)) pre_eval$value else
              eval(arg1$first_arg_sub, envir = parent.frame())
  }

  # --- Validate data is a data frame -----------------------------------------
  if (!is.data.frame(data)) {
    .jst_stop(
      "Only data frames can be saved. '", data_name, "' is not a data frame."
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
      "  .rds       R"
    )
  }
  # A path typed with single backslashes (S343; Session 351): checked
  # before the folder is looked for and before a file is written. Not
  # caught, such a path saved on Linux under a name holding a tab.
  .jst_check_path_chars(file)

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
        "  jsave(", code_name, ", \"",
        tools::file_path_sans_ext(file), ".xlsx\")")
    }
    .jst_stop(expr_lines(paste0(
      "Unsupported file extension '.", ext, "'. Supported formats for saving:\n",
      "  .sav       SPSS\n",
      "  .dta       Stata\n",
      "  .xpt       SAS interchange\n",
      "  .xlsx      Excel\n",
      "  .csv       Comma-separated values\n",
      "  .rds       R",
      xls_msg
    )))
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
      # Explicit data.dir — write to that folder. joptions() created it
      # when the setting was made (S332); it is created again here if it
      # has been removed since, or if the setting came through options().
      if (.jst_create_data_dir(data_dir, fn = "jsave")) {
        .jst_msg(.jst_data_dir_created_note(data_dir))
      }
      out_path <- file.path(data_dir, file)
    }
  }

  # --- Overwrite check -------------------------------------------------------
  if (file.exists(out_path) && !overwrite) {
    if (interactive()) {
      ok <- .jst_confirm(
        paste0("File '", .jst_norm_path(out_path),
               "' already exists. Overwrite? (y/n): "),
        "Add overwrite = TRUE to the call, then run it again."
      )
      if (!ok) {
        .jst_msg("Save cancelled.")
        return(invisible(NULL))
      }
    } else {
      .jst_stop(
        "File '", .jst_norm_path(out_path), "' already exists. ",
        "Use overwrite = TRUE to replace it."
      )
    }
  }

  # --- Detect UDM forms and apply preserve.declarations (collapse) --------------------
  # Detection is captured here, on the frame as given, so the post-write
  # notes can describe what was present. The collapse runs BEFORE the
  # ReadStat pre-flight below (Session 361; decided in principle S218, where
  # until then "Option Y" ran it after): preserve.declarations = FALSE is an
  # explicit instruction to save every declared missing value as plain NA,
  # which satisfies the no-silent-loss rule, so a .sav, .dta or .xpt write
  # that the pre-flight refuses for a missing-value form the format cannot
  # hold now proceeds with the values blanked -- and says so, with the count,
  # after the write. The default, TRUE, is unchanged: nothing collapses, and
  # the pre-flight blocks what the format cannot represent. The
  # .jst_handle_udms() call is shared with jload's preserve.declarations
  # path, so collapse semantics stay identical both ways.
  spss_udm_vars  <- character(0)
  stata_udm_vars <- character(0)
  text_udm       <- FALSE
  n_udm_blanked  <- 0L
  n_tag_blanked  <- 0L   # cells holding a lettered marker (Session 361)
  # The frame as given, for the Excel/CSV note's labels and declared codes
  # (Session 359): preserve.declarations = FALSE replaces data below.
  data_given     <- data
  if (ext %in% c("xlsx", "csv") || !preserve.declarations) {
    spss_udm_vars  <- .jst_has_spss_udm(data)
    stata_udm_vars <- .jst_has_tagged_na(data)
    # A text variable's declared codes are words, not -99 (the S340
    # item's rider, Session 351): the loss note says "values" then.
    text_udm <- length(.jst_declared_text_vars(data, spss_udm_vars)) > 0L
    if (!preserve.declarations &&
        (length(spss_udm_vars) > 0 || length(stata_udm_vars) > 0)) {
      collapsed <- .jst_handle_udms(data, preserve.declarations = FALSE)
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
      # A marker's cell was NA already; what the collapse drops is which
      # marker it was. Counted for the note the other formats get.
      if (length(stata_udm_vars) > 0) {
        n_tag_blanked <- sum(vapply(stata_udm_vars, function(v) {
          x <- data[[v]]
          if (!is.double(x)) return(0L)
          sum(!is.na(haven::na_tag(x)))
        }, integer(1)))
      }
      data <- collapsed$df
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

    # (0) Variable names the format refuses (the import audit's third
    # finding, Session 362). haven and ReadStat checked them in their own
    # words and one at a time; .jst_save_name_problems() holds each
    # format's rules and names every refused name at once, with the name
    # clean.names = TRUE would give it in the file.
    name_probs <- .jst_save_name_problems(names(data), ext)
    if (nrow(name_probs) > 0L && !clean.names) {
      cn_line <- paste0("  jsave(", code_name, ", \"",
                        .jst_dq_escape(gsub("\\", "/", file, fixed = TRUE)),
                        "\"", if (isTRUE(overwrite)) ", overwrite = TRUE",
                        if (!preserve.declarations) ", preserve.declarations = FALSE",
                        ", clean.names = TRUE)")
      sections[[length(sections) + 1L]] <-
        .jst_save_names_error_msg(name_probs, ext, data_name, cn_line)
    }
    # A factor whose category is longer than 120 characters (.sav): haven
    # writes a factor's categories as value labels, which SPSS holds to 120
    # characters, and refused it in its own words (Session 362).
    if (ext == "sav") {
      long_lv <- names(data)[vapply(data, function(col) {
        is.factor(col) && any(nchar(levels(col)) > 120L, na.rm = TRUE)
      }, logical(1))]
      if (length(long_lv) > 0L) {
        n_lv <- length(long_lv)
        sections[[length(sections) + 1L]] <- paste0(
          .jst_and_list(long_lv), " ", .jst_plural(n_lv, "has", "have"),
          " a category longer than 120 characters, which SPSS format ",
          "(.sav) cannot store as a value label.\n",
          "Save ", .jst_plural(n_lv, "it", "them"), " as text, which SPSS ",
          "keeps whole:\n",
          paste0("  ", code_name, "$", long_lv, " <- as.character(",
                 code_name, "$", long_lv, ")", collapse = "\n"))
      }
    }

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
        names(data)[unsup_vars], unname(type_of[unsup_vars]), ext, code_name)
    }

    # (2) Missing-value incompatibilities -- format-specific. Each refusal
    # offers the save that blanks them (Session 361, the S218 item), the
    # call as given with preserve.declarations = FALSE: the conversion keeps
    # the declared values in the target's form, this saves them as plain NA
    # -- two remedies in opposite directions, named side by side (Rule D's
    # equal-standing carve-out). overwrite = TRUE rides when it was given.
    # The file as typed, slashes swapped (jload()'s leading-digit line does
    # the same, S241): a bare name resolved through data.dir stays bare, so
    # the line saves where this call would have.
    pd_line <- paste0("  jsave(", code_name, ", \"",
                      .jst_dq_escape(gsub("\\", "/", file, fixed = TRUE)),
                      "\"", if (isTRUE(overwrite)) ", overwrite = TRUE",
                      ", preserve.declarations = FALSE)")
    if (ext == "sav") {
      tagged_vars <- .jst_has_tagged_na(data)
      if (length(tagged_vars) > 0) {
        sections[[length(sections) + 1L]] <-
          .jst_jsave_sav_error_msg(tagged_vars, data, code_name,
                                   pd_line = pd_line)
      }
      # SPSS-form columns exceeding the .sav missing-value limit (at most 3
      # discrete codes, or a range plus 1). haven::write_sav() enforces SPSS's
      # own rule and errors mid-write (leaving a partial file) on a column
      # carrying more, so the pre-flight catches these with a fixable message.
      overcap_info <- list()
      for (vname in .jst_has_spss_udm(data)) {
        info    <- .jst_missing_info(data[[vname]])
        n_disc  <- if (!is.null(info$codes)) nrow(info$codes) else 0L
        has_rng <- !is.null(info$na_range)
        if ((!has_rng && n_disc > 3L) || (has_rng && n_disc > 1L)) {
          overcap_info[[length(overcap_info) + 1L]] <-
            list(var = vname, n = n_disc, range = has_rng)
        }
      }
      if (length(overcap_info) > 0) {
        sections[[length(sections) + 1L]] <-
          .jst_jsave_sav_overcap_error_msg(overcap_info, code_name,
                                           .jst_declared_text_vars(data),
                                           prose_name = data_name,
                                           stem       = code_stem,
                                           pd_line    = pd_line)
      }
    } else if (ext == "dta") {
      # Any SPSS-form column blocks the write; since S218 the remedy is
      # uniform (jconvert enumerates na_range declarations too), so no
      # bucketing by form -- one list, one remedy. Residual accepted by
      # design: a range enumerating past 26 values will be refused by
      # jconvert itself, with its own explanation, rather than
      # pre-checked here (the 26-cap logic lives in one place).
      spss_vars <- .jst_has_spss_udm(data)
      if (length(spss_vars) > 0) {
        sections[[length(sections) + 1L]] <-
          .jst_jsave_dta_error_msg(spss_vars, code_name,
                                   .jst_declared_text_vars(data, spss_vars),
                                   pd_line = pd_line)
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
          .jst_jsave_xpt_error_msg(tagged_vars, code_name, spss_vars,
                                   pd_line = pd_line)
      }
    }

    # Report all blocking issues at once (single message when only one fired).
    if (length(sections) > 0) {
      .jst_stop(expr_lines(
        .jst_jsave_combined_error_msg(sections, data_name, ext)))
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
        if (!is.null(note)) .jst_msg(note)
      }
    }
  }

  # --- Excel's sheet size (Session 362) ---------------------------------------
  # A sheet holds 1,048,576 rows and 16,384 columns. writexl stopped one row
  # past the limit in its own words ("the xlsx format does not support
  # tables with 1M+ rows") and AT it in libxlsxwriter's ("Worksheet row or
  # column index out of range."), since the names take a row.
  if (ext == "xlsx" && (nrow(data) > 1048575L || ncol(data) > 16384L)) {
    stem_typed <- sub("\\.xlsx$", "", gsub("\\", "/", file, fixed = TRUE),
                      ignore.case = TRUE)
    over <- c(
      if (nrow(data) > 1048575L) paste0(
        format(nrow(data), big.mark = ","), " cases, and Excel format ",
        "(.xlsx) holds at most 1,048,575.\n",
        "A sheet has 1,048,576 rows, one of them for the variable names."),
      if (ncol(data) > 16384L) paste0(
        format(ncol(data), big.mark = ","), " variables, and Excel format ",
        "(.xlsx) holds at most 16,384."))
    .jst_stop(expr_lines(paste0(
      "the ", data_name, " data frame has ", paste(over, collapse = "\nIt has "),
      "\nSave it in another format, for example:\n",
      "  jsave(", code_name, ", \"", .jst_dq_escape(stem_typed), ".rds\")\n",
      "  jsave(", code_name, ", \"", .jst_dq_escape(stem_typed), ".csv\")")))
  }

  # --- What the file gets in place of what the format cannot hold -------------
  # Session 362. clean.names = TRUE: the names .jst_save_name_problems()
  # refused are changed in the file only, each old name the variable's
  # label there where it had none. Labels: .dta's variable labels and the
  # frame labels of .dta and .xpt shortened here, between characters
  # (ReadStat cut a .dta label inside a character), and .sav's long labels
  # noted, which ReadStat shortens cleanly (.jst_save_label_limits()).
  names_changed <- NULL
  if (ext %in% c("sav", "dta", "xpt") && isTRUE(clean.names)) {
    probs <- .jst_save_name_problems(names(data), ext)
    if (nrow(probs) > 0L) {
      new_nm <- names(data)
      new_nm[probs$pos] <- probs$new
      ap <- .jst_apply_new_names(data, new_nm,
                                 seq_along(new_nm) %in% probs$pos)
      data <- ap$df
      names_changed <- list(old = probs$old, new = probs$new, had = ap$had)
    }
  }
  lab_lim <- .jst_save_label_limits(data, ext)
  data    <- lab_lim$data

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

  # A folder R cannot write to (Session 340): a read-only or protected
  # folder, or one an AI assistant's sandbox mode keeps writes out of. Probed
  # before the write, by the attempt itself (.jst_lib_writable(), R core's
  # own test), because each writer fails in its own words and two of them
  # are R's: saveRDS() warned "cannot open compressed file
  # './jsave_d_22e05de3092d.rds', probable reason 'Permission denied'" --
  # the temporary name below, which the user never typed -- and stopped on
  # "cannot open the connection"; write_xlsx() printed a C-level "[ERROR]
  # workbook_close()" that R cannot catch. A write that is REDIRECTED rather
  # than refused cannot be detected from here: the file is written, and
  # where it went is the sandbox's to say.
  if (!.jst_lib_writable(dirname(out_path))) {
    .jst_stop("R cannot write to this folder:\n",
              "  ", .jst_norm_path(dirname(out_path)), "\n",
              "Nothing was saved.\n",
              "Choose a folder you can write to and run jsave() again.")
  }

  xpt_member <- .jst_sas_member_name(basename_no_ext)
  temp_path <- tempfile(
    pattern = paste0("jsave_", basename_no_ext, "_"),
    tmpdir  = dirname(out_path),
    fileext = paste0(".", ext)
  )

  # Registration-aware save: only the .rds format carries arbitrary R
  # attributes, so bake the active classification registrations (jnumeric/
  # jcount via .jst_registry, jdummy via .jst_dummy) onto the frame just for
  # that path. Other formats get a loss note after the write instead. No-op
  # when the frame has no registrations. The bake prunes entries for
  # variables not present in the frame (courier prune, S208): the file's
  # card describes the file's contents, the session notebook is untouched,
  # and the pruned names surface as a note with the loss notes below.
  reg_dropped <- character(0)
  if (ext == "rds") {
    bake_result <- .jst_bake_registrations(data, data_name)
    data        <- bake_result$data
    reg_dropped <- bake_result$dropped
  }

  tryCatch({
    switch(ext,
           sav  = haven::write_sav(data, temp_path),
           dta  = haven::write_dta(data, temp_path, version = 14),
           # The dataset inside is named after the file asked for, not the
           # temporary one (Session 362; .jst_sas_member_name()).
           xpt  = haven::write_xpt(data, temp_path, name = xpt_member),
           xlsx = writexl::write_xlsx(data, temp_path),
           # In UTF-8, with the byte-order mark when the file holds a
           # character beyond ASCII (Session 362; .jst_write_csv()).
           csv  = .jst_write_csv(data, temp_path),
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

  # What the file holds in place of what the format could not (Session
  # 362): the names clean.names = TRUE changed, the labels shortened, and
  # an .xpt dataset's SAS name when the file's name is not one.
  if (!is.null(names_changed)) {
    loss_notes <- c(loss_notes, .jst_save_names_note(
      names_changed$old, names_changed$new, names_changed$had, ext, data_name))
  }
  if (length(lab_lim$vars) || length(lab_lim$values) || isTRUE(lab_lim$frame)) {
    loss_notes <- c(loss_notes, .jst_save_labels_note(lab_lim, ext, data_name))
  }
  if (ext == "xpt" && !identical(xpt_member, basename_no_ext)) {
    loss_notes <- c(loss_notes, paste0(
      "Note: inside ", basename(out_path), " the dataset is named ",
      xpt_member, ".\n",
      "A SAS dataset name holds only the letters A to Z, digits and ",
      "underscores, up to 32 characters."))
  }

  # Excel and CSV cannot store labels or missing-value metadata; the note
  # describes the loss (and, when preserve.declarations = FALSE blanked SPSS-style
  # codes, confirms it).
  if (ext %in% c("xlsx", "csv")) {
    label_note <- .jst_jsave_label_loss_note(
      ext, spss_udm_vars, stata_udm_vars, preserve.declarations, n_udm_blanked,
      text_udm = text_udm, data = data_given, code_name = code_name,
      path = .jst_norm_path(out_path))
    if (!is.null(label_note)) loss_notes <- c(loss_notes, expr_lines(label_note))
  }

  # preserve.declarations = FALSE on the other formats (Session 361, the
  # S218 item): what the collapse did, said after the write, as the
  # Excel/CSV note above says it -- the count of cells, or that no cell
  # held one and the declarations were dropped. Until then only Excel and
  # CSV said it, and a .rds or .sav save blanked them without a word.
  if (!preserve.declarations && !ext %in% c("xlsx", "csv") &&
      (length(spss_udm_vars) > 0 || length(stata_udm_vars) > 0)) {
    loss_notes <- c(loss_notes,
                    .jst_jsave_blanked_note(n_udm_blanked + n_tag_blanked))
  }

  # A text variable's missing cells (ruling R13, Jeff, S345; built Session
  # 351): .sav, .dta, .xpt and .csv have no missing value for text, and
  # write one as an empty string, which jload() reads back as the <blank>
  # category, counted valid. Read on the frame as written.
  text_na_note <- .jst_jsave_text_na_note(data, ext)
  if (!is.null(text_na_note)) loss_notes <- c(loss_notes, text_na_note)

  # Classification registrations ride along only in .rds (baked above). Any
  # other format silently drops them, so note the loss -- but only when the
  # frame actually has registrations to lose.
  if (ext != "rds") {
    reg_loss_note <- .jst_jsave_registration_loss_note(ext, data_name)
    if (!is.null(reg_loss_note)) loss_notes <- c(loss_notes, reg_loss_note)
  }

  # Courier-prune note (S208): registrations for variables absent from the
  # saved frame were left out of the file's card. Consequential -- the file's
  # card differs from the session notebook -- and recoverable in-session,
  # since the notebook itself was not touched.
  if (length(reg_dropped) > 0) {
    quoted <- paste0("'", reg_dropped, "'", collapse = ", ")
    prune_note <- if (length(reg_dropped) == 1L) {
      paste0("Note: ", quoted, " is not in ", data_name,
             ", so its registration was not carried into the file.")
    } else {
      paste0("Note: these variables are not in ", data_name, ", so their ",
             "registrations were not carried into the file: ", quoted, ".")
    }
    loss_notes <- c(loss_notes, prune_note)
  }

  # Release note (D6, S239): an undeclared suspicious code written to a
  # declaration-carrying format, with same-style evidence elsewhere in
  # the frame. Silent on formats with no declaration slot (.csv/.xlsx
  # keep their own label-loss note above) and when the frame declares
  # nothing anywhere. Runs on the frame AS WRITTEN, so preserve.declarations =
  # FALSE (declarations stripped above) leaves no evidence and stays
  # silent by the same rule. Consequential level: loss_notes is plain
  # message(), never joutput-gated.
  if (ext %in% c("sav", "dta", "xpt")) {
    # The resave recipe echoes the NORMALIZED path (the same
    # .jst_norm_path form the Saved line prints), never the raw file
    # argument: a Windows backslash path inside the quoted recipe is a
    # parse error on paste (S241 walk finding).
    release_note <- .jst_jsave_release_notes(data, data_name,
                                             .jst_norm_path(out_path))
    if (!is.null(release_note)) loss_notes <- c(loss_notes, release_note)
  }

  if (length(loss_notes) > 0) .jst_msg(paste(loss_notes, collapse = "\n\n"))

  # --- Confirmation message --------------------------------------------------
  # Two lines (S230): the parenthetical (format, cases, variables) is the
  # verification payload and gets its own flush-left line regardless of
  # path length, so it is never hostage to a long path's console wrap.
  # A call given as the data names nothing a user could find again
  # (Session 347): the line read "Saved mk() to ...". An index into a data
  # frame -- wv[, c("Education", "Age")] -- does, and is kept as typed.
  saved_what <- if (identical(arg1$mode, "explicit") &&
                    identical(.jst_data_arg_kind(data_sub), "expression") &&
                    !(is.call(data_sub) &&
                      identical(data_sub[[1L]], as.name("[")))) {
    "the data"
  } else {
    data_name
  }
  .jst_msg(
    "Saved ", saved_what, " to ", .jst_norm_path(out_path),
    "\n(", .jst_format_label(ext), "; ",
    format(nrow(data), big.mark = ","),
    if (nrow(data) == 1L) " case, " else " cases, ",
    ncol(data),
    if (ncol(data) == 1L) " variable)" else " variables)"
  )

  invisible(NULL)
}


#' Copy a data frame, carrying its classification registrations
#'
#' Copies a data frame to a new name AND clones any classification
#' registrations (jnumeric / jcount / jlikert / jdummy) attached to it, so
#' the copy behaves the same as the original under later analysis calls. A plain
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
#'   overwriting. In a script, state it explicitly:
#'   \code{jcopy(mydata, mydata2, overwrite = TRUE)}. Otherwise, if the
#'   name already exists in your environment, and the script was run by
#'   pasting or with RStudio's Run button, the call stops with an error.
#' @param quiet Logical; if TRUE, suppress the confirmation message.
#' @return Invisibly NULL. Called for its side effect: the copy is assigned into
#'   the calling environment under \code{name}, and its registrations are cloned
#'   onto that name.
#' @examples
#' \dontrun{
#'   jdummy(community, Region)        # register a classification on community
#'   jcopy(community, survey)         # survey carries Region's registration
#'   jcopy(data = community, survey)  # the data frame given by name
#'
#'   juse(community)
#'   jcopy(survey2)                   # copy the default (community) to survey2
#' }
#' @seealso \code{\link{jload}}, \code{\link{jsave}}, \code{\link{juse}}
#' @export
jcopy <- function(data, name, overwrite = FALSE, quiet = FALSE) {
  # Validate TRUE/FALSE flags up front.
  .jst_check_flag(overwrite, "overwrite")
  .jst_check_flag(quiet, "quiet")
  say <- function(...) if (!quiet) .jst_msg(...)

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
    .jst_stop("The name '", dest_name, "' starts with a number.\n",
         "R does not allow a data frame's name to start with a digit.")
  }
  dest_name <- make.names(dest_name)

  # Overwrite check in the calling environment.
  target_env <- parent.frame()
  if (exists(dest_name, envir = target_env, inherits = FALSE) && !overwrite) {
    if (interactive()) {
      ok <- .jst_confirm(
        paste0("'", dest_name, "' already exists in your environment. ",
               "Overwrite? (y/n): "),
        "Add overwrite = TRUE to the call, then run it again."
      )
      if (!ok) {
        .jst_msg("Copy cancelled.")
        return(invisible(NULL))
      }
    } else {
      .jst_msg("'", dest_name, "' already existed and has been replaced.")
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
      format(nrow(src_data), big.mark = ","),
      if (nrow(src_data) == 1L) " case, " else " cases, ",
      ncol(src_data),
      if (ncol(src_data) == 1L) " variable)" else " variables)")
  if (carried) {
    say("Carried over the classification registrations from ", src_name, ".")
  }

  invisible(NULL)
}
