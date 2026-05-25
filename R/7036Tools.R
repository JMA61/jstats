#' JeffsStatTools: Simplified Statistical Analysis Tools for Social Science
#'
#' @description
#' JeffsStatTools simplifies R for users who need to do social science
#' analyses without being required to become experienced computer
#' programmers first. The package provides consistent syntax, sensible
#' defaults, and protection from confusing base R behaviors, while
#' staying close enough to base R conventions that users learn
#' transferable skills rather than a private dialect. Output is styled
#' after the best conventions from alternative applications such as
#' SPSS, Stata, and SAS, and code syntax is designed to ease the
#' transition from these alternative packages into R. While this
#' package was originally built as teaching infrastructure for a
#' university-level statistics course, it has now been expanded for
#' the broader social science research community.
#'
#' @section Audience:
#' The long-term primary audience is the broader social science
#' quantitative research community — criminologists, sociologists,
#' political scientists, psychologists, public health researchers,
#' and others who routinely work with Likert scales, categorical
#' variables, dichotomies, Cronbach's alpha, dummy-coded regression,
#' and \code{haven}-imported data from SPSS, Stata, or SAS.
#'
#' During the current development phase the package is being tested
#' actively by students and colleagues at Griffith University, plus
#' a growing community of former students and collaborating
#' instructors. Feedback from this group shapes ongoing refinements.
#'
#' @section Functions by purpose:
#' \strong{Descriptive analysis}
#' \itemize{
#'   \item \code{\link{jdesc}} — univariate descriptives (mean, median, SD, range, etc.) with optional grouping
#'   \item \code{\link{jfreq}} — frequency tables for one or more variables
#'   \item \code{\link{jcorr}} — Pearson or Spearman correlations with significance tests
#'   \item \code{\link{jalpha}} — Cronbach's alpha and item-total statistics for scale reliability
#'   \item \code{\link{jscreen}} — data screening for outliers, ranges, and skew
#' }
#'
#' \strong{Group comparisons and modeling}
#' \itemize{
#'   \item \code{\link{jt}} — independent or paired t-test
#'   \item \code{\link{jaov}} — one-way analysis of variance with optional post-hoc tests
#'   \item \code{\link{jcrosstab}} — cross-tabulation with chi-square and effect-size options
#'   \item \code{\link{jlm}} — linear regression
#'   \item \code{\link{jlogistic}} — logistic regression
#' }
#'
#' \strong{Variable construction}
#' \itemize{
#'   \item \code{\link{jrecode}} — recode values, with optional new value labels
#'   \item \code{\link{jrelabel}} — apply or replace value labels and variable label
#'   \item \code{\link{jsum}} — row-wise sum across variables, with min-valid handling
#'   \item \code{\link{javg}} — row-wise mean across variables, with min-valid handling
#' }
#'
#' \strong{Pipeline state management}
#' \itemize{
#'   \item \code{\link{juse}} — set the default data frame used implicitly by analysis functions
#'   \item \code{\link{jsubset}} — activate a row-level case-selection expression applied to subsequent calls
#'   \item \code{\link{jcomplete}} — activate listwise filtering on selected variables
#'   \item \code{\link{jdummy}} — register categorical variables for dummy coding in regression
#'   \item \code{\link{joutput}} — set session-level output verbosity (minimal / standard / full)
#' }
#'
#' \strong{Data import and export}
#' \itemize{
#'   \item \code{\link{jload}} — load data from \code{.rds}, \code{.sav}, \code{.dta}, \code{.sas7bdat}, \code{.xlsx}, or \code{.csv}
#'   \item \code{\link{jsave}} — save a data frame, with format inferred from the file extension
#' }
#'
#' \strong{Visualisation}
#' \itemize{
#'   \item \code{\link{jplot}} — base histograms and bar plots for data, plus method dispatch on result objects from \code{jt()}, \code{jlm()}, etc.
#' }
#'
#' For the full alphabetical listing of every exported function, run
#' \code{library(help = "JeffsStatTools")} or browse the package index.
#'
#' @section Workflow conventions:
#' \strong{The j-prefix.} Every user-facing function starts with
#' \code{j}, so the package's whole API can be discovered in RStudio
#' by typing \code{j} and pressing Tab. Internal helpers begin with a
#' dot or \code{.jst_} and are not intended for direct use.
#'
#' \strong{Formula vs data-first.} Group-comparison and modeling
#' functions follow the base R formula interface:
#' \code{jt(MathScore ~ Gender, data = SampleData)}. Descriptive and
#' data-management functions take the data frame first, followed by
#' unquoted variable names: \code{jfreq(SampleData, Gender, Program)}.
#' This matches the conventions of base R functions like
#' \code{aggregate()} and \code{cor()}.
#'
#' \strong{The juse-first habit.} A single \code{juse(MyData)} call
#' at the start of a session sets a default data frame. Subsequent
#' analysis calls can then omit the data argument:
#' \code{jfreq(Gender)} works the same as
#' \code{jfreq(MyData, Gender)}. The default also scopes the
#' pipeline-state functions, so \code{jsubset(Age < 30)} sets a
#' filter on the current default without further specification.
#'
#' \strong{Pipeline stages.} \code{jsubset()}, \code{jcomplete()}, and
#' \code{jdummy()} modify session state that subsequent analysis calls
#' read automatically. State is explicit — calls can be inspected,
#' inactivated, and cleared, and active state is reported in analysis
#' output, so a script's behavior stays visible and reproducible
#' rather than depending on hidden context.
#'
#' \strong{Output verbosity.} \code{joutput()} sets one of three
#' preset levels — \code{minimal}, \code{standard} (default), or
#' \code{full} — that modulate how much detail analysis functions
#' print. Useful for stripping output in production scripts or
#' expanding it during exploration. Per-call arguments always
#' override session-level settings. The Case Processing Summary
#' table follows an auto-suppress rule at the standard tier: it
#' prints when something happened (pipeline state, listwise drops,
#' or a per-variable discrepancy notification) and stays silent
#' otherwise. See \code{?joutput} for the full toggle behavior.
#'
#' @section Where to go next:
#' \itemize{
#'   \item For the full alphabetical listing of functions:
#'     \code{library(help = "JeffsStatTools")}.
#'   \item For source, issue reports, and contribution guidelines:
#'     the package's GitHub repository.
#'   \item For statistics and R fundamentals (in preparation): Book 1
#'     of the companion book series.
#'   \item For migration patterns from SPSS, Stata, or SAS, and a
#'     deeper guide to the package's design and use in real research
#'     (in preparation): Book 2, the adopter's guide.
#' }
#'
#' @keywords internal
"_PACKAGE"


# =============================================================================
#  INTERNAL HELPERS
# =============================================================================

# -- Output formatting helpers ------------------------------------------------

#' Internal helper: format a class vector for readable display
#'
#' Drops the uninformative "vctrs_vctr" class and appends "(Categorical)"
#' to "haven_labelled" to make the type line more meaningful to the user.
#'
#' @keywords internal
.format_var_type <- function(classes) {
  is_haven  <- "haven_labelled" %in% classes
  classes   <- classes[classes != "vctrs_vctr"]
  type_str  <- paste(classes, collapse = ", ")
  if (is_haven) type_str <- paste0(type_str, " (Categorical)")
  type_str
}

#' Internal helper: print a string in red using ANSI escape codes
#'
#' Works in RStudio, most terminals, and R Markdown HTML output.
#' Falls back to plain text in environments that strip ANSI codes.
#'
#' @keywords internal
.cat_red <- function(x) {
  cat(paste0("\033[31m", x, "\033[0m"))
}

#' Internal helper: print text in yellow ANSI color
#'
#' Used for informational/status notes where the text should be visually
#' distinct from regular output but not alarming (matches the "warning/note"
#' color convention).
#'
#' @keywords internal
.cat_yellow <- function(x) {
  cat(paste0("\033[33m", x, "\033[0m"))
}

#' Internal helper: print the "Using default data frame: X" note in yellow
#'
#' Used by every analysis function immediately after its red title line.
#' Groups the default-data-frame note with other session-state notes (jsubset,
#' jcomplete) under a consistent yellow coloring.
#'
#' @param data_name Character string name of the default data frame.
#' @param extra_newline Logical. If TRUE (default), adds a trailing blank
#'   line after the note so it's visually separated from whatever prints
#'   next. Set FALSE only when the caller wants the next line to abut
#'   the note directly.
#' @keywords internal
.jst_default_note <- function(data_name, extra_newline = TRUE) {
  .cat_yellow(paste0("Using default data frame: ", data_name, "\n"))
  if (extra_newline) cat("\n")
}

#' Internal helper: retrieve a variable label as a string
#'
#' Returns the label if present, otherwise the string "None".
#'
#' @keywords internal
.get_var_label_str <- function(x) {
  vl <- labelled::var_label(x)
  if (!is.null(vl) && length(vl) > 0 && !is.na(vl[1]) && nzchar(vl[1])) {
    as.character(vl[1])
  } else {
    "None"
  }
}

#' Internal helper: print variable label legend
#'
#' Used by jt, jaov, jcorr, jcrosstab, jscreen, and jalpha.
#'
#' @keywords internal
.print_var_labels <- function(data, var_names) {
  label_lines <- c()
  for (v in var_names) {
    if (v %in% names(data)) {
      vl <- labelled::var_label(data[[v]])
      if (!is.null(vl) && !is.na(vl) && nzchar(vl)) {
        label_lines <- c(label_lines, paste0("  ", v, " = ", vl))
      }
    }
  }
  if (length(label_lines) > 0) {
    cat("Variable Labels:\n")
    cat(paste(label_lines, collapse = "\n"))
    cat("\n\n")
  }
}

#' Internal helper: print a formatted table with precise column alignment
#'
#' Purpose-built table printer that replaces knitr::kable() for console output.
#' Provides right-justified numbers, left-justified text, clean separator lines,
#' and consistent indentation. No external dependencies --- pure base R.
#'
#' @param df A data frame to print.
#' @param col.names Optional character vector of column headers. If NULL,
#'   uses \code{names(df)}.
#' @param row.names Logical. If TRUE, includes row names as the first column.
#' @param align Optional character vector of alignment codes ("l", "r", "c"),
#'   one per displayed column. If NULL, auto-detects: numeric = right,
#'   character/other = left.
#' @param caption Optional title string printed above the table.
#' @param indent Number of leading spaces for each line. Default 2.
#' @param header.indent Number of leading spaces for the caption,
#'   header row, and separator row. Defaults to 0 (caption and header
#'   flush-left at column 1, with data rows indented). Set to a
#'   positive number to indent these alongside the data --- rare; the
#'   default produces the package's standard "block header at column
#'   1, data indented" layout.
#'
#' @keywords internal
.jst_print_table <- function(df, col.names = NULL, row.names = TRUE,
                             align = NULL, caption = NULL, indent = 2,
                             header.indent = 0) {

  headers <- if (!is.null(col.names)) col.names else names(df)

  # Build display matrix
  display_cols <- lapply(seq_len(ncol(df)), function(j) {
    col <- df[[j]]
    if (is.numeric(col)) {
      # scientific = FALSE keeps round/large values in plain decimal form
      # (e.g. 200000, not "2e+05"; 70, not "7e+01"). format() still gives a
      # column uniform decimal places, so right-justified numeric columns
      # align on the decimal point. (Session 50)
      ifelse(is.na(col), "", format(col, trim = TRUE, scientific = FALSE))
    } else {
      as.character(ifelse(is.na(col), "", col))
    }
  })
  display <- do.call(cbind, display_cols)

  if (row.names && !is.null(rownames(df)) &&
      !identical(rownames(df), as.character(seq_len(nrow(df))))) {
    display <- cbind(rownames(df), display)
    headers <- c("", headers)
    # If the caller passed an explicit align vector sized for the data
    # columns only, prepend "l" so the row-names column gets left-
    # justification and the rest shift into the right slots. Without
    # this, align[1] would silently absorb the row-names column (causing
    # variable names to be centered when the caller intended "c" for the
    # first data column) and align[n_displayed_cols] would be NA
    # (causing the last column to fall through to the default left
    # alignment). Skip the prepend if the caller already supplied a
    # vector matching the displayed-column count, on the assumption they
    # did so deliberately.
    if (!is.null(align) && length(align) == ncol(df)) {
      align <- c("l", align)
    }
  }

  n_cols <- ncol(display)
  n_rows <- nrow(display)

  # Auto-detect alignment
  if (is.null(align)) {
    align <- character(n_cols)
    for (j in seq_len(n_cols)) {
      if (row.names && j == 1 && !identical(rownames(df), as.character(seq_len(nrow(df))))) {
        align[j] <- "l"
      } else {
        orig_col <- if (row.names && !identical(rownames(df), as.character(seq_len(nrow(df))))) j - 1 else j
        if (orig_col >= 1 && orig_col <= ncol(df) && is.numeric(df[[orig_col]])) {
          align[j] <- "r"
        } else {
          align[j] <- "l"
        }
      }
    }
  }

  # Column widths
  col_widths <- integer(n_cols)
  for (j in seq_len(n_cols)) {
    data_widths <- nchar(trimws(display[, j]))
    col_widths[j] <- max(nchar(headers[j]), max(data_widths, 0L, na.rm = TRUE))
  }

  gap    <- "  "
  prefix <- paste(rep(" ", indent), collapse = "")
  header_prefix <- paste(rep(" ", header.indent), collapse = "")

  fmt_cell <- function(text, width, alignment) {
    text <- trimws(text)
    switch(alignment,
           "r" = formatC(text, width = width, flag = " "),
           "c" = {
             pad   <- max(0L, width - nchar(text))
             left  <- pad %/% 2
             right <- pad - left
             paste0(strrep(" ", left), text, strrep(" ", right))
           },
           formatC(text, width = -width, flag = "-")
    )
  }

  if (!is.null(caption)) {
    cat(header_prefix, caption, "\n", sep = "")
  }

  # Header
  header_cells <- vapply(seq_len(n_cols), function(j) {
    fmt_cell(headers[j], col_widths[j], align[j])
  }, character(1))
  cat(header_prefix, paste(header_cells, collapse = gap), "\n", sep = "")

  # Separator
  sep_cells <- vapply(col_widths, function(w) {
    paste(rep("-", w), collapse = "")
  }, character(1))
  cat(header_prefix, paste(sep_cells, collapse = gap), "\n", sep = "")

  # Data rows
  for (i in seq_len(n_rows)) {
    row_cells <- vapply(seq_len(n_cols), function(j) {
      fmt_cell(display[i, j], col_widths[j], align[j])
    }, character(1))
    cat(prefix, paste(row_cells, collapse = gap), "\n", sep = "")
  }
}


# -----------------------------------------------------------------------------
# Data pipeline helpers: jcomplete / jsubset storage and application
# These helpers manage per-dataset filter and complete-case settings,
# apply them in the correct order, and generate info-line messages.
# -----------------------------------------------------------------------------

#' Internal helper: get filter settings for a named data frame
#'
#' Looks up the \code{jsubset()} settings stored under the
#' \code{.jst_filter} option for a specific data frame name. Returns
#' \code{NULL} if no filter is set for that data frame.
#'
#' @param data_name Character string giving the data frame name to look
#'   up. If \code{NULL}, returns \code{NULL}.
#'
#' @return The stored filter settings list, or \code{NULL} if none.
#'
#' @keywords internal
.jst_get_filter <- function(data_name) {
  if (is.null(data_name)) return(NULL)
  all_filters <- getOption(".jst_filter", default = list())
  all_filters[[data_name]]
}

#' Internal helper: get complete-case settings for a named data frame
#'
#' Looks up the \code{jcomplete()} settings stored under the
#' \code{.jst_complete} option for a specific data frame name. Returns
#' \code{NULL} if no complete-case settings are stored for that data
#' frame.
#'
#' @param data_name Character string giving the data frame name to look
#'   up. If \code{NULL}, returns \code{NULL}.
#'
#' @return The stored complete-case settings list, or \code{NULL} if
#'   none.
#'
#' @keywords internal
.jst_get_complete <- function(data_name) {
  if (is.null(data_name)) return(NULL)
  all_complete <- getOption(".jst_complete", default = list())
  all_complete[[data_name]]
}

#' Internal helper: set filter settings for a named data frame
#'
#' Stores filter settings under the \code{.jst_filter} option, keyed by
#' data frame name. Used internally by \code{jsubset()}.
#'
#' @param data_name Character string giving the data frame name. If
#'   \code{NULL}, the call is a silent no-op.
#' @param settings A list of filter settings to store.
#'
#' @return \code{invisible(NULL)}. Called for its side effect on the
#'   \code{.jst_filter} option.
#'
#' @keywords internal
.jst_set_filter <- function(data_name, settings) {
  if (is.null(data_name)) return(invisible(NULL))
  all_filters <- getOption(".jst_filter", default = list())
  all_filters[[data_name]] <- settings
  options(.jst_filter = all_filters)
}

#' Internal helper: set complete-case settings for a named data frame
#'
#' Stores complete-case settings under the \code{.jst_complete} option,
#' keyed by data frame name. Used internally by \code{jcomplete()}.
#'
#' @param data_name Character string giving the data frame name. If
#'   \code{NULL}, the call is a silent no-op.
#' @param settings A list of complete-case settings to store.
#'
#' @return \code{invisible(NULL)}. Called for its side effect on the
#'   \code{.jst_complete} option.
#'
#' @keywords internal
.jst_set_complete <- function(data_name, settings) {
  if (is.null(data_name)) return(invisible(NULL))
  all_complete <- getOption(".jst_complete", default = list())
  all_complete[[data_name]] <- settings
  options(.jst_complete = all_complete)
}

#' Internal helper: report whether any data frame has an active filter
#'
#' Scans the \code{.jst_filter} option to see whether any data frame
#' has filter settings currently turned on. Used to drive informational
#' notes about filtering being active for some other dataset than the
#' one currently in use.
#'
#' @return Logical. \code{TRUE} if at least one data frame has an active
#'   filter setting; \code{FALSE} otherwise.
#'
#' @keywords internal
.jst_any_filter_active <- function() {
  all_filters <- getOption(".jst_filter", default = list())
  if (length(all_filters) == 0) return(FALSE)
  for (nm in names(all_filters)) {
    fs <- all_filters[[nm]]
    if (!is.null(fs) && isTRUE(fs$active)) return(TRUE)
  }
  FALSE
}

#' Internal helper: report whether any data frame has active complete-case settings
#'
#' Scans the \code{.jst_complete} option to see whether any data frame
#' has complete-case settings currently turned on. Used to drive
#' informational notes about complete-case handling being active for
#' some other dataset than the one currently in use.
#'
#' @return Logical. \code{TRUE} if at least one data frame has active
#'   complete-case settings; \code{FALSE} otherwise.
#'
#' @keywords internal
.jst_any_complete_active <- function() {
  all_complete <- getOption(".jst_complete", default = list())
  if (length(all_complete) == 0) return(FALSE)
  for (nm in names(all_complete)) {
    cs <- all_complete[[nm]]
    if (!is.null(cs) && isTRUE(cs$active)) return(TRUE)
  }
  FALSE
}

#' Internal helper: get registered dummy variables for a named data frame
#'
#' Looks up the \code{jdummy()} registrations stored under the
#' \code{.jst_dummy} option for a specific data frame name. Returns
#' \code{NULL} if no dummies are registered for that data frame.
#'
#' @param data_name Character string giving the data frame name to look
#'   up.
#'
#' @return The stored dummy-registration settings list, or \code{NULL}
#'   if none.
#'
#' @keywords internal
.jst_get_dummy <- function(data_name) {
  all_dummy <- getOption(".jst_dummy", default = list())
  all_dummy[[data_name]]
}

#' Internal helper: set registered dummy variables for a named data frame
#'
#' Stores dummy registrations under the \code{.jst_dummy} option, keyed
#' by data frame name. Used internally by \code{jdummy()}.
#'
#' @param data_name Character string giving the data frame name.
#' @param settings A list of dummy registrations to store.
#'
#' @return \code{invisible(NULL)}. Called for its side effect on the
#'   \code{.jst_dummy} option.
#'
#' @keywords internal
.jst_set_dummy <- function(data_name, settings) {
  all_dummy <- getOption(".jst_dummy", default = list())
  all_dummy[[data_name]] <- settings
  options(.jst_dummy = all_dummy)
}

#' Internal helper: render a pipeline-state clear message
#'
#' Shared formatter for the \code{(NULL)} clear messages of
#' \code{jsubset()}, \code{jcomplete()}, and \code{jdummy()}. Owns the
#' collapse layout so the three setters stay byte-identical: one data
#' frame renders on a single line; two or more render a header line plus
#' one indented \code{"  - "} line per data frame.
#'
#' @param fn_label Character function label used in the message prefix
#'   (e.g. \code{"jsubset"}).
#' @param dnames Character vector of data frame names being cleared.
#' @param payloads Character vector, parallel to \code{dnames}, giving the
#'   parenthesised "what was lost" text for each frame (e.g.
#'   \code{"had: Age < 40"} or \code{"had 2 registered: Religion, Region"}).
#'
#' @return \code{invisible(NULL)}. Called for its message side effect.
#'
#' @keywords internal
.jst_render_clear <- function(fn_label, dnames, payloads) {
  n <- length(dnames)
  if (n == 1L) {
    message(fn_label, " cleared for ", dnames[1L], " (", payloads[1L], ").")
  } else {
    lines <- paste0("  - ", dnames, " (", payloads, ")")
    message(fn_label, " cleared (", n, " data frames):\n",
            paste(lines, collapse = "\n"))
  }
  invisible(NULL)
}

#' Internal helper: render a pipeline-state session-wide status overview
#'
#' Shared formatter for the two-or-more-frame status overview of
#' \code{jsubset()} and \code{jcomplete()} (the toggleable setters). Renders
#' a header line plus one indented \code{"  - "} line per data frame, each
#' tagged \code{[active]} / \code{[inactive]} and marked \code{, default}
#' for the current \code{juse()} default. The zero- and one-frame cases stay
#' with the callers, since their single-line wording differs (and
#' \code{jcomplete} appends a live complete-case count there). \code{jdummy}
#' does not use this helper: it has no active/inactive toggle and its
#' overview header reads "registrations" rather than "settings".
#'
#' @param fn_label Character function label (e.g. \code{"jsubset"}).
#' @param dnames Character vector of data frame names.
#' @param payloads Character vector, parallel to \code{dnames}, giving the
#'   per-frame payload shown after the colon (the expression for
#'   \code{jsubset}; the comma-joined variable list for \code{jcomplete}).
#' @param active Logical vector, parallel to \code{dnames}, TRUE when the
#'   setting is active.
#' @param default_name Character name of the current \code{juse()} default,
#'   or \code{NULL}. The matching frame is tagged \code{, default}.
#'
#' @return \code{invisible(NULL)}. Called for its message side effect.
#'
#' @keywords internal
.jst_render_status_overview <- function(fn_label, dnames, payloads, active,
                                        default_name = NULL) {
  tags   <- ifelse(active, "active", "inactive")
  is_def <- if (is.null(default_name)) rep(FALSE, length(dnames)) else
              dnames == default_name
  tags   <- ifelse(is_def, paste0(tags, ", default"), tags)
  lines  <- paste0("  - ", dnames, ": ", payloads, "  [", tags, "]")
  message(fn_label, " settings (", length(dnames), " data frames):\n",
          paste(lines, collapse = "\n"))
  invisible(NULL)
}

#' Internal helper: build canonical dummy variable naming for a categorical variable
#'
#' Single source of truth for how categorical variables are turned into named
#' dummy columns across the package. Called by \code{jdummy()} during
#' registration and by \code{jlm()} / \code{jlogistic()} when handling
#' \code{categorical =} arguments and auto-detected categorical IVs.
#'
#' Supports six input shapes:
#' \enumerate{
#'   \item haven_labelled with descriptive labels not containing the
#'         variable name (e.g. Gender labelled "Male", "Female").
#'   \item haven_labelled with descriptive labels already containing the
#'         variable name (e.g. Program labelled "Program 1", "Program 2"...).
#'   \item haven_labelled with labels that equal the codes as strings
#'         (i.e. uninformative — labels carry no extra information).
#'   \item Plain numeric with no labels.
#'   \item Factor with character levels.
#'   \item Character vector.
#' }
#'
#' Naming algorithm:
#' \enumerate{
#'   \item Output form is always \code{VarName_Suffix}.
#'   \item Suffix source per category: descriptive label if available,
#'         numeric code otherwise. Mixed within a single variable is allowed
#'         (descriptive wins per-category).
#'   \item Canonicalise the chosen suffix: replace runs of non-alphanumeric
#'         characters with single underscore; trim leading and trailing
#'         underscores; if a suffix canonicalises to empty (label was entirely
#'         non-alphanumeric), fall back to that category's code.
#'   \item Anti-stutter: if the canonicalised suffix already begins with
#'         \code{paste0(var_name, "_")}, do not prepend the variable name
#'         again.
#'   \item Detect duplicates: if two categories produce the same final name,
#'         stop with an error pointing to \code{jrelabel()}.
#' }
#'
#' Permissive reference matching: when \code{ref} is a character string,
#' three matching attempts are made — direct match against canonical labels,
#' canonicalised user input matched against canonical labels (so
#' \code{"Program 3"} or \code{"3"} both find \code{"Program_3"}), and
#' string match against codes (so \code{"3"} also matches code 3).
#'
#' @param x A vector — haven_labelled, factor, character, or numeric.
#' @param var_name Character. The variable's name (used as the dummy
#'   column prefix).
#' @param ref Reference category specifier. May be \code{first} (default),
#'   \code{last}, a numeric code, or a character string matching a
#'   canonical label.
#' @param name.length.warn Integer. Warn if any final dummy name exceeds
#'   this many characters. Default 30.
#'
#' @return A list with components: \code{codes}, \code{labels}
#'   (canonical, used for display), \code{dummy_names} (canonical, for
#'   non-reference categories only), \code{var_type}, \code{ref_idx},
#'   \code{ref_code}, \code{ref_label}, \code{non_ref_idx}, \code{notes}
#'   (character vector of informational messages), \code{warnings_msg}
#'   (character vector of warnings).
#'
#' @keywords internal
.jst_make_dummy_names <- function(x, var_name, ref = "first",
                                  name.length.warn = 30L) {

  notes        <- character(0)
  warnings_msg <- character(0)

  # -- Step 1: classify input and extract codes + raw labels ----------------
  is_haven <- haven::is.labelled(x)

  if (is_haven) {
    var_type   <- "haven_labelled"
    val_labels <- labelled::val_labels(x)
    codes      <- .jst_as_numeric(sort(unique(x[!is.na(x)])))
    raw_labels <- character(length(codes))
    for (i in seq_along(codes)) {
      match_idx <- which(val_labels == codes[i])
      if (length(match_idx) > 0) {
        raw_labels[i] <- names(val_labels)[match_idx[1]]
      } else {
        raw_labels[i] <- as.character(codes[i])
      }
    }
  } else if (is.factor(x)) {
    var_type   <- "factor"
    lvls       <- levels(droplevels(x))
    codes      <- seq_along(lvls)
    raw_labels <- lvls
  } else if (is.character(x)) {
    var_type   <- "character"
    uniq       <- sort(unique(x[!is.na(x) & nzchar(x)]))
    codes      <- seq_along(uniq)
    raw_labels <- uniq
  } else if (is.numeric(x)) {
    var_type   <- "numeric"
    codes      <- sort(unique(x[!is.na(x)]))
    raw_labels <- as.character(codes)
  } else {
    stop("'", var_name, "' has an unsupported type for dummy coding ",
         "(class: ", paste(class(x), collapse = "/"), ").",
         call. = FALSE)
  }

  n_cats <- length(codes)
  if (n_cats < 2) {
    stop("'", var_name, "' has fewer than 2 categories. ",
         "Cannot create dummy variables.", call. = FALSE)
  }

  # -- Step 2: choose suffix source per category ----------------------------
  # Per-category rule: use the raw label if it is descriptive (non-empty
  # and not equal to the code-as-string); otherwise use the code.
  #
  # "Descriptive" detection is per-category, so a variable with mixed
  # descriptive and uninformative labels gets the most informative suffix
  # available for each category.

  code_as_str    <- as.character(codes)
  is_descriptive <- nzchar(raw_labels) & raw_labels != code_as_str

  # For non-haven types (factor, character, numeric), is_descriptive is
  # also true when the label genuinely differs from the synthetic code.
  # For numeric (no labels) all are "non-descriptive" → use codes. For
  # factor and character all should be descriptive (raw_labels are the
  # real values, and the codes are synthetic seq_along indices).

  used_code_fallback <- !is_descriptive
  suffix_source      <- ifelse(is_descriptive, raw_labels, code_as_str)

  # -- Step 3: canonicalise each suffix -------------------------------------
  canon <- gsub("[^A-Za-z0-9]+", "_", suffix_source)
  canon <- gsub("^_+|_+$", "", canon)

  # If canonicalisation produced an empty string (label was entirely
  # non-alphanumeric), fall back to the code for that category.
  empty_canon <- !nzchar(canon)
  if (any(empty_canon)) {
    canon[empty_canon]              <- code_as_str[empty_canon]
    used_code_fallback[empty_canon] <- TRUE
  }

  # -- Step 4: anti-stutter and prepend var_name ----------------------------
  prefix          <- paste0(var_name, "_")
  already_prefixed <- startsWith(canon, prefix)
  final_labels    <- ifelse(already_prefixed, canon, paste0(prefix, canon))

  # -- Step 5: duplicate detection ------------------------------------------
  if (anyDuplicated(final_labels) > 0) {
    dup_idx   <- which(duplicated(final_labels) | duplicated(final_labels,
                                                             fromLast = TRUE))
    dup_pairs <- vapply(unique(final_labels[dup_idx]), function(d) {
      offenders <- raw_labels[final_labels == d]
      paste0("'", paste(offenders, collapse = "' and '"),
             "' both produce '", d, "'")
    }, character(1))
    stop(
      "Cannot create unique dummy names for '", var_name, "': ",
      paste(dup_pairs, collapse = "; "), ". ",
      "Use jrelabel() to give these categories distinct labels, or ",
      "jrecode() to merge or rename them.",
      call. = FALSE
    )
  }

  # -- Step 6: resolve reference category -----------------------------------
  if (is.character(ref) && tolower(ref) == "first") {
    ref_idx <- 1L
  } else if (is.character(ref) && tolower(ref) == "last") {
    ref_idx <- n_cats
  } else if (is.numeric(ref)) {
    ref_idx <- which(codes == ref)
    if (length(ref_idx) == 0) {
      stop("Reference code ", ref, " not found in '", var_name,
           "'. Available codes: ", paste(codes, collapse = ", "),
           call. = FALSE)
    }
  } else if (is.character(ref)) {
    # Try direct match against canonical labels first.
    ref_idx <- which(final_labels == ref)
    if (length(ref_idx) == 0) {
      # Try canonicalising the user's input the same way labels were
      # canonicalised, then match.
      cleaned_ref <- gsub("[^A-Za-z0-9]+", "_", ref)
      cleaned_ref <- gsub("^_+|_+$", "", cleaned_ref)
      if (nzchar(cleaned_ref) && !startsWith(cleaned_ref, prefix)) {
        cleaned_ref <- paste0(prefix, cleaned_ref)
      }
      ref_idx <- which(final_labels == cleaned_ref)
    }
    if (length(ref_idx) == 0) {
      # Last try: match against codes-as-strings (so ref = "3" works for
      # code 3 even when canonical label is "Program_3").
      ref_idx <- which(code_as_str == ref)
    }
    if (length(ref_idx) == 0) {
      stop("Reference '", ref, "' not found in '", var_name,
           "'. Available labels: ", paste(final_labels, collapse = ", "),
           call. = FALSE)
    }
  } else {
    ref_idx <- 1L
  }

  ref_idx     <- as.integer(ref_idx[1])
  ref_code    <- codes[ref_idx]
  ref_label   <- final_labels[ref_idx]
  non_ref_idx <- setdiff(seq_len(n_cats), ref_idx)
  dummy_names <- final_labels[non_ref_idx]

  # -- Step 7: build informational notes and warnings -----------------------
  if (any(used_code_fallback)) {
    notes <- c(notes, paste0(
      "(Note: One or more dummy names for '", var_name, "' were built ",
      "from numeric codes because descriptive value labels were not ",
      "available. If these names aren't ideal, use jrelabel() to set ",
      "value labels, or jrecode() to change the underlying values, ",
      "then re-register with jdummy().)"
    ))
  }

  long_names <- final_labels[nchar(final_labels) > name.length.warn]
  if (length(long_names) > 0) {
    warnings_msg <- c(warnings_msg, paste0(
      "Some dummy names for '", var_name, "' exceed ", name.length.warn,
      " characters: ", paste(shQuote(long_names), collapse = ", "),
      ". The model will fit, but coefficient tables may look awkward. ",
      "Use jrelabel() to shorten the labels before jdummy()."
    ))
  }

  list(
    codes        = codes,
    labels       = final_labels,
    dummy_names  = dummy_names,
    var_type     = var_type,
    ref_idx      = ref_idx,
    ref_code     = ref_code,
    ref_label    = ref_label,
    non_ref_idx  = non_ref_idx,
    notes        = notes,
    warnings_msg = warnings_msg
  )
}


#' Internal helper: expand a single registration into dummy columns
#'
#' Given a registration-shaped object (from jdummy storage or built
#' in-flight via \code{.jst_make_dummy_names()}), add the dummy columns
#' to \code{data} and replace \code{var_name} with the dummy names in
#' \code{formula_str}. Used by \code{.jst_expand_dummies()} and by the
#' auto-categorical pathways in jlm and jlogistic.
#'
#' @param data The data frame.
#' @param formula_str The formula as a deparsed string.
#' @param reg A registration object (must have \code{var_name},
#'   \code{codes}, \code{non_ref_idx}, \code{dummy_names}).
#' @return A list with components \code{data}, \code{formula_str},
#'   \code{dummy_coef_names}.
#' @keywords internal
.jst_expand_one_dummy <- function(data, formula_str, reg) {

  orig_col         <- .jst_as_numeric(data[[reg$var_name]])
  dummy_coef_names <- character(0)

  for (j in seq_along(reg$non_ref_idx)) {
    idx   <- reg$non_ref_idx[j]
    dname <- reg$dummy_names[j]
    data[[dname]] <- ifelse(is.na(orig_col), NA_integer_,
                            as.integer(orig_col == reg$codes[idx]))
    dummy_coef_names <- c(dummy_coef_names, dname)
  }

  # Replace variable in formula with dummy names. Wrapping in parentheses
  # ensures correct behavior when the variable appears inside an
  # interaction term (e.g. y ~ x * Religion).
  dummy_plus  <- paste0("(", paste(reg$dummy_names, collapse = " + "), ")")
  formula_str <- gsub(paste0("\\b", reg$var_name, "\\b"),
                      dummy_plus, formula_str)

  list(data = data, formula_str = formula_str,
       dummy_coef_names = dummy_coef_names)
}


#' Internal helper: expand registered dummy variables in a formula and data frame
#'
#' Checks for jdummy registrations matching variables in the formula,
#' creates temporary dummy columns in the data frame, rewrites the formula,
#' and returns updated data, formula, reference category labels, and dummy
#' coefficient names. Used by jlm and future regression functions.
#'
#' @param data The data frame.
#' @param formula The model formula.
#' @param data_name Character string name of the data frame (for looking up registrations).
#'
#' @return A list with components:
#'   \describe{
#'     \item{data}{The data frame with dummy columns added.}
#'     \item{formula}{The updated formula with dummy names.}
#'     \item{ref_cats}{Character vector of "VarName = RefLabel" strings.}
#'     \item{dummy_coef_names}{Character vector of dummy column names (for blanking β).}
#'   }
#'
#' @keywords internal
.jst_expand_dummies <- function(data, formula, data_name) {

  model_vars       <- all.vars(formula)
  dummy_regs       <- .jst_get_dummy(data_name)
  ref_cats         <- character(0)
  dummy_coef_names <- character(0)

  if (!is.null(dummy_regs) && length(dummy_regs) > 0) {
    formula_str <- deparse(formula, width.cutoff = 500)
    dv_name     <- model_vars[1]

    for (reg in dummy_regs) {
      if (reg$var_name %in% model_vars && reg$var_name != dv_name) {
        expanded <- .jst_expand_one_dummy(data, formula_str, reg)
        data             <- expanded$data
        formula_str      <- expanded$formula_str
        dummy_coef_names <- c(dummy_coef_names, expanded$dummy_coef_names)

        ref_cats <- c(ref_cats, paste0(reg$var_name, " = ", reg$ref_label))
      }
    }

    formula <- stats::as.formula(formula_str)
  }

  list(data = data, formula = formula, ref_cats = ref_cats,
       dummy_coef_names = dummy_coef_names)
}

#' Internal helper: apply a logical mask expression to a data frame
#'
#' Shared mechanic for Step 2 (persistent jsubset) and Step 3 (per-call
#' \code{subset =} argument) of \code{.jst_apply_pipeline()}. Evaluates
#' \code{expr} in the data + caller environment, coerces \code{NA}s in
#' the resulting mask to \code{FALSE}, and returns the filtered data
#' frame. The two callers differ in upstream source (joptions state vs.
#' argument) and downstream bookkeeping (which \code{sample_info} slot
#' is populated); the masking step itself is identical.
#'
#' @param data Data frame to mask.
#' @param expr Unevaluated logical expression (a language object).
#' @param envir Environment to evaluate \code{expr} in. Data columns
#'   take precedence; \code{envir} provides fallback bindings.
#' @param on_error One of \code{"warn"} or \code{"stop"}. \code{"warn"}
#'   emits a warning and returns the data unchanged — used for the
#'   persistent jsubset state, where the expression was validated when
#'   set and a runtime failure is unexpected. \code{"stop"} raises an
#'   error — used for the per-call \code{subset =} argument, where a
#'   broken expression is a user error at call time.
#' @param stage_label Character. Prefix used in the error/warning
#'   message (e.g. \code{"jsubset"} or \code{"Subset"}) so failures
#'   are attributable to the right pipeline stage.
#'
#' @return The data frame filtered to rows where \code{expr} evaluates
#'   to \code{TRUE} (\code{NA} treated as \code{FALSE}).
#'
#' @keywords internal
.jst_apply_mask <- function(data, expr, envir, on_error, stage_label) {
  on_error <- match.arg(on_error, c("warn", "stop"))
  mask <- tryCatch(
    eval(expr, data, envir),
    error = function(e) {
      msg <- paste0(stage_label, " expression could not be evaluated: ",
                    conditionMessage(e))
      if (on_error == "warn") {
        warning(msg, call. = FALSE)
        rep(TRUE, nrow(data))
      } else {
        stop(msg, call. = FALSE)
      }
    }
  )
  mask[is.na(mask)] <- FALSE
  # Variable-label loss from `[.data.frame` row subsetting (plain atomic and
  # factor columns lose their label; haven_labelled keep theirs) is restored
  # once at the end of .jst_apply_pipeline, from the pre-pipeline snapshot, which
  # covers this path plus jcomplete's direct subset uniformly.
  data[mask, , drop = FALSE]
}

#' Internal helper: apply the full data pipeline and return filtered data + messages
#'
#' Order of operations:
#' \enumerate{
#'   \item jcomplete (listwise deletion for registered variables)
#'   \item jsubset (persistent case-selection expression)
#'   \item subset (one-off per-call case-selection expression)
#' }
#'
#' jcomplete and jsubset are keyed per-dataset. They apply whenever the
#' matching dataset is used, regardless of whether that dataset was supplied
#' via the juse() default or specified explicitly in the function call.
#' This matches the SPSS FILTER model: persistent state remains in effect
#' until explicitly turned off via jsubset(off) / jcomplete(off).
#'
#' When the current dataset has no jsubset / jcomplete set but at least one
#' other dataset does have an active setting, a yellow-colored note is
#' included in the pipeline messages to remind the user that case selection
#' is not active for this particular dataset.
#'
#' @param data The data frame.
#' @param data_name Character string name of the data frame.
#' @param is_default Logical. TRUE if the data frame came from juse().
#' @param subset_expr An unevaluated expression for one-off subsetting, or NULL.
#' @param envir The environment in which to evaluate expressions.
#'
#' @return A list with components:
#'   \describe{
#'     \item{data}{The filtered data frame.}
#'     \item{msgs}{Character vector of info-line messages to print.}
#'     \item{pipeline_counts}{A list of pipeline counts: \code{n_original},
#'       \code{n_after_complete}, \code{n_after_filter}, \code{n_after_subset}
#'       (each NULL if that step was not active), \code{complete_active},
#'       \code{filter_active}, \code{filter_expr}.}
#'   }
#'
#' @keywords internal
.jst_apply_pipeline <- function(data, data_name, is_default,
                                subset_expr = NULL, envir = parent.frame()) {

  msgs <- character(0)
  n_original <- nrow(data)

  # Snapshot the pre-masking data so the CPS bottom can compute source/pool
  # per-code counts from intact UDM codes (the masking pass below converts
  # SPSS-form UDM cells to NA destructively). Survival is tracked via a
  # temporary integer id column (rownames are unreliable on tibbles, which
  # the course datasets are); the column rides through the row-subsetting
  # filters and is read off — then removed — at the end. Operates on the
  # local analysis copy only; the user's frame is untouched.
  pre_pipeline_data <- data

  # Pipeline count tracking
  n_after_complete <- NULL
  n_after_filter   <- NULL
  n_after_subset   <- NULL
  complete_active  <- FALSE
  filter_active    <- FALSE
  filter_expr_str  <- NULL
  complete_vars    <- NULL

  # -- Step 0: declared UDM masking on the analysis copy --------------------
  # Mask values declared as user-defined missing values (UDMs) to NA on a
  # copy of the data frame used for this analysis. The user's data frame in
  # the workspace is unchanged — na_values / na_range metadata stays
  # attached so round-trip fidelity through jsave is preserved. Stata-form
  # tagged_na values are not touched here; they satisfy is.na() natively at
  # the C level. Replaces the former auto-NA-by-label mechanism
  # (.jst_preprocess_na, retired in v0.9.5) per Cross-cutting Decision 5 of
  # JStats_Missing_Values_Reference.txt Part 4.
  #
  # The whole-DF YELLOW notice that previously announced UDM masking was
  # dropped in v0.9.6 — the information is now surfaced per-variable via
  # jfreq's Missing section and via the Case Processing Summary, scoped to
  # the variables the analysis actually touches.
  udm_result <- .jst_apply_declared_udms_as_na(data)
  data       <- udm_result$data

  # Temporary survival-tracking id (removed before this function returns).
  # Added after masking (which preserves row order) and before filtering, so
  # the surviving values are the original 1..n_original row positions.
  data$.jst_row_id <- seq_len(n_original)

  # -- Step 1: jcomplete -----------------------------------------------------
  # Applied whenever a jcomplete is set on the current dataset (by name),
  # regardless of whether that dataset was supplied via juse() default or
  # explicitly in the call. This matches the SPSS FILTER convention: state
  # persists until explicitly turned off, not bypassed by dataset mention.
  cs <- .jst_get_complete(data_name)
  if (!is.null(cs)) {
    if (cs$active) {
      complete_active <- TRUE
      valid_vars <- cs$vars[cs$vars %in% names(data)]
      complete_vars <- valid_vars
      if (length(valid_vars) > 0) {
        complete_mask    <- stats::complete.cases(data[, valid_vars, drop = FALSE])
        data             <- data[complete_mask, , drop = FALSE]
        n_after_complete <- nrow(data)
      } else {
        n_after_complete <- nrow(data)
      }
    } else {
      msgs <- c(msgs, "[YELLOW](jcomplete set but inactive)")
    }
  } else {
    # No jcomplete set for this dataset — but one is set elsewhere?
    if (.jst_any_complete_active()) {
      msgs <- c(msgs, "[YELLOW](jcomplete not active for this dataset)")
    }
  }

  # -- Step 2: jsubset -------------------------------------------------------
  fs <- .jst_get_filter(data_name)
  if (!is.null(fs)) {
    if (fs$active) {
      filter_active   <- TRUE
      filter_expr_str <- fs$expr_str
      data            <- .jst_apply_mask(data, fs$expr, envir,
                                         on_error    = "warn",
                                         stage_label = "jsubset")
      n_after_filter  <- nrow(data)
    } else {
      msgs <- c(msgs, "[YELLOW](jsubset set but inactive)")
    }
  } else {
    # No jsubset set for this dataset — but one is set elsewhere?
    if (.jst_any_filter_active()) {
      msgs <- c(msgs, "[YELLOW](jsubset not active for this dataset)")
    }
  }

  # -- Step 3: subset (always applies) -------------------------------------
  # Per-call subset arg. Counts and expression are reported in the Case
  # Processing Summary table; no pipeline message is produced.
  subset_expr_str <- NULL
  if (!is.null(subset_expr)) {
    subset_expr_str <- paste(deparse(subset_expr), collapse = " ")
    data           <- .jst_apply_mask(data, subset_expr, envir,
                                      on_error    = "stop",
                                      stage_label = "Subset")
    n_after_subset <- nrow(data)
  }

  # Recover surviving original row positions, then strip the temp id column
  # so the returned analysis data is clean.
  surviving_ids    <- data$.jst_row_id
  data$.jst_row_id <- NULL

  # Restore variable labels from the pre-pipeline snapshot. Row subsetting via
  # `[.data.frame` (jcomplete's direct subset at Step 1, the jsubset / subset
  # masks, and the temp id-column add/strip) drops the `label` attribute from
  # plain atomic and factor columns; haven_labelled columns keep theirs via their
  # own `[` method. Restoring once here, from the untouched pre_pipeline_data,
  # covers all paths at a single point (a pass that never dropped the label is a
  # no-op). Read by the functions that take the label off the filtered frame
  # (jfreq, jt, jaov, jcrosstab, jcorr); jdesc captures labels before filtering.
  for (nm in names(data)) {
    lab <- attr(pre_pipeline_data[[nm]], "label", exact = TRUE)
    if (!is.null(lab) && is.null(attr(data[[nm]], "label", exact = TRUE))) {
      attr(data[[nm]], "label") <- lab
    }
  }

  pipeline_counts <- list(
    n_original       = n_original,
    n_after_complete = n_after_complete,
    n_after_filter   = n_after_filter,
    n_after_subset   = n_after_subset,
    complete_active  = complete_active,
    filter_active    = filter_active,
    filter_expr      = filter_expr_str,
    subset_expr      = subset_expr_str,
    # UDM masking activity from Step 0. udm_active = TRUE when at least
    # one variable had declared UDMs masked to NA on the analysis copy.
    # udm_masked_vars carries the per-variable detail (entries + n_cells)
    # for downstream display (Case Processing Summary, etc.).
    udm_active       = length(udm_result$converted) > 0L,
    udm_masked_vars  = udm_result$converted,
    # CPS rendering inputs (Steps 3-6). pre_pipeline_data holds the original
    # rows with UDM codes intact; surviving_ids are the original row numbers
    # that survived the pipeline (the analysis pool). The renderer derives
    # pool_data = pre_pipeline_data[surviving_ids, ] for source/pool counts.
    complete_vars     = complete_vars,
    pre_pipeline_data = pre_pipeline_data,
    surviving_ids     = surviving_ids
  )

  list(data = data, msgs = msgs, pipeline_counts = pipeline_counts)
}

#' Internal helper: print info-line messages generated by the pipeline
#'
#' @keywords internal
.jst_print_msgs <- function(msgs) {
  for (m in msgs) {
    if (startsWith(m, "[YELLOW]")) {
      .cat_yellow(sub("^\\[YELLOW\\]", "", m))
      cat("\n")
    } else {
      cat(m, "\n")
    }
  }
}

#' Internal helper: build standardized sample_info block
#'
#' Combines pipeline counts from .jst_apply_pipeline() with analysis-level
#' missing data information to produce the sample_info element included in
#' every analysis function's return value.
#'
#' @param pipeline_counts List returned by .jst_apply_pipeline()$pipeline_counts.
#' @param data Data frame after pipeline filtering (before analysis-level NA
#'   exclusion).
#' @param analysis_vars Character vector of variable names used in the analysis.
#' @param n_analysis Integer. Final N used in the analysis after listwise
#'   deletion on analysis variables.
#'
#' @return A list with elements: n_original, n_after_complete, n_after_filter,
#'   n_after_subset, n_analysis, n_excluded_missing, missing_by_var,
#'   complete_active, filter_active, filter_expr.
#'
#' @keywords internal
.jst_build_sample_info <- function(pipeline_counts, data, analysis_vars,
                                   n_analysis) {

  # Count missing values per analysis variable in the post-pipeline data
  missing_by_var <- vapply(analysis_vars, function(v) {
    if (v %in% names(data)) sum(is.na(data[[v]])) else 0L
  }, integer(1))

  n_after_pipeline   <- nrow(data)
  n_excluded_missing <- n_after_pipeline - n_analysis

  list(
    n_original         = pipeline_counts$n_original,
    n_after_complete   = pipeline_counts$n_after_complete,
    n_after_filter     = pipeline_counts$n_after_filter,
    n_after_subset     = pipeline_counts$n_after_subset,
    n_after_pipeline   = n_after_pipeline,
    n_analysis         = n_analysis,
    n_excluded_missing = n_excluded_missing,
    missing_by_var     = missing_by_var,
    analysis_vars      = analysis_vars,
    complete_active    = pipeline_counts$complete_active,
    complete_vars      = pipeline_counts$complete_vars,
    filter_active      = pipeline_counts$filter_active,
    filter_expr        = pipeline_counts$filter_expr,
    subset_expr        = pipeline_counts$subset_expr,
    udm_active         = pipeline_counts$udm_active,
    udm_masked_vars    = pipeline_counts$udm_masked_vars,
    pre_pipeline_data  = pipeline_counts$pre_pipeline_data,
    surviving_ids      = pipeline_counts$surviving_ids
  )
}

# Output level preset defaults (used by .jst_resolve_toggle and joutput)
#
# case.processing supports three states:
#   FALSE - never print CPS
#   TRUE  - always print CPS (even when nothing was excluded)
#   NULL  - "auto": print CPS only when something happened (any pipeline
#           state active, or for listwise=TRUE callers, listwise excluded
#           at least one case)
#
# udm.notice supports three states:
#   FALSE - never print the UDM narrative on jload
#   TRUE  - always print the narrative (every .sav load with UDMs)
#   NULL  - "auto": print once per session, then suppress (tracked via
#           the .jst_udm_notice_shown option)
.jst_output_defaults <- list(
  minimal  = list(effect.size = FALSE, ci = FALSE, levene = FALSE,
                  posthoc = FALSE, diagnostics = FALSE,
                  case.processing = FALSE, case.processing.detail = "none",
                  var.labels = FALSE, ref.categories = FALSE,
                  udm.notice = FALSE),
  standard = list(effect.size = TRUE,  ci = TRUE,  levene = FALSE,
                  posthoc = FALSE, diagnostics = FALSE,
                  case.processing = NULL,  case.processing.detail = "totals",
                  var.labels = TRUE,  ref.categories = TRUE,
                  udm.notice = NULL),
  full     = list(effect.size = TRUE,  ci = TRUE,  levene = TRUE,
                  posthoc = TRUE,  diagnostics = TRUE,
                  case.processing = TRUE,  case.processing.detail = "per_code",
                  var.labels = TRUE,  ref.categories = TRUE,
                  udm.notice = TRUE)
)

# -- joptions defaults --------------------------------------------------------
#
# Single source of truth for joptions slot defaults. Consulted both by
# joptions itself for reset semantics and by downstream readers (jload,
# jconvert, jdeclare_udm, jrecode, .jst_scan_coded_missing) via
# getOption() fallback when no explicit setting is present.
#
# Slots:
#   missing.convention   - one of "none", "spss", "stata". "none" =
#                          preserve-as-loaded (no auto-conversion at
#                          load time). "spss" / "stata" opts into
#                          load-time auto-conversion and supplies the
#                          target convention for fresh UDM declarations.
#   udm.convention.codes - numeric vector, length 1-4, whole numbers,
#                          no duplicates. Recommended UDM code set used
#                          by jconvert for Stata-tag -> SPSS-code mapping
#                          and by .jst_scan_coded_missing for
#                          convention-matched detection.
#   data.dir             - single character string, or NULL. NULL =
#                          jsave writes bare-filename saves to the
#                          working directory; jload bare-filename
#                          searches the working directory. Setting a
#                          value names a folder (relative to working
#                          directory) used for both save target and
#                          load search. See .jst_get_search_dirs() and
#                          jsave for transition-period backwards-compat
#                          handling of legacy Data/ or data/ folders.
.jst_options_defaults <- list(
  missing.convention   = "none",
  udm.convention.codes = c(-99, -98, -97, -96),
  data.dir             = NULL
)

#' Internal helper: resolve a display toggle value
#'
#' Implements three-tier precedence: (1) explicit per-call argument wins,
#' (2) individual joutput() toggle override, (3) joutput() level default.
#' Per-call arguments use NULL to mean "I didn't specify -- defer to joutput()".
#'
#' @param name Character. Toggle name (e.g. "effect.size", "ci", "levene").
#' @param per_call_value The value passed by the user in the function call,
#'   or NULL if not specified.
#'
#' @return Logical. TRUE or FALSE.
#'
#' @keywords internal
.jst_resolve_toggle <- function(name, per_call_value) {
  # 1. Explicit per-call argument wins
  if (!is.null(per_call_value)) return(per_call_value)
  # 2. Check individual toggle override from joutput()
  toggles <- getOption(".jst_output_toggles", list())
  if (name %in% names(toggles)) return(toggles[[name]])
  # 3. Fall back to level default
  level    <- getOption(".jst_output_level", "standard")
  defaults <- .jst_output_defaults
  defaults[[level]][[name]]
}

#' Internal helper: resolve the active missing-value convention
#'
#' Implements Decision 11's four-step precedence rule for determining
#' which UDM convention (SPSS-form or Stata-form) applies to a fresh
#' UDM declaration or convention-conditional recode. Returns either
#' \code{"spss"} or \code{"stata"} -- never \code{NULL}.
#'
#' The four levels of the precedence rule, in order:
#' \enumerate{
#'   \item If the column already carries a UDM convention (na_values
#'     metadata for SPSS-form, tagged_na markers for Stata-form),
#'     match it. Handled at the call site by passing a non-NULL value
#'     to \code{column_convention}; \code{jrecode()} does not engage
#'     this level because it produces fresh columns.
#'   \item If \code{per_call} is \code{"spss"} or \code{"stata"}, use
#'     that.
#'   \item If \code{joptions("missing.convention")} is \code{"spss"}
#'     or \code{"stata"}, use that.
#'   \item Else default to SPSS-form.
#' }
#'
#' @param per_call The value of the calling function's
#'   \code{convention} argument (typically NULL, "spss", or "stata").
#'   Validated; values other than NULL, "spss", or "stata" raise an
#'   error.
#' @param column_convention Optional. \code{"spss"}, \code{"stata"},
#'   or \code{NULL}. When non-NULL, level 1 of the precedence rule
#'   applies and the function returns this value immediately. Step 5b
#'   (\code{jdeclare_udm()}) will populate this argument from
#'   \code{.jst_missing_info()} on the operand column.
#'
#' @return Single character: \code{"spss"} or \code{"stata"}.
#'
#' @keywords internal
.jst_resolve_convention <- function(per_call = NULL, column_convention = NULL) {

  # Validate per_call up front so the error fires whether or not the
  # convention is actually consulted by the caller.
  if (!is.null(per_call)) {
    if (!is.character(per_call) || length(per_call) != 1L ||
        !per_call %in% c("spss", "stata")) {
      stop("The convention argument must be \"spss\" or \"stata\".",
           call. = FALSE)
    }
  }

  # Level 1: column already carries a convention.
  if (!is.null(column_convention) &&
      column_convention %in% c("spss", "stata")) {
    return(column_convention)
  }

  # Level 2: per-call argument.
  if (!is.null(per_call)) return(per_call)

  # Level 3: joptions setting.
  opt <- getOption(".jst_options_missing_convention",
                   .jst_options_defaults$missing.convention)
  if (opt %in% c("spss", "stata")) return(opt)

  # Level 4: SPSS-form default.
  return("spss")
}

#' CPS rendering rule tables (data, not logic)
#'
#' Canonical source = JStats_CPS_Rendering_Reference.txt Tables 1-3. Per the
#' locked lockstep commitment, any change to a rule here updates BOTH that
#' reference file and this data frame in the same session. "any" is a
#' wildcard; matching is first-match top-to-bottom, so reference rows whose
#' value is "-" (not evaluated) are encoded as "any" with ordering preserved.
#'
#' @keywords internal
.jst_cps_visibility_rules <- data.frame(
  level    = c("minimal", "standard", "standard", "standard", "full"),
  pipeline = c("any",     "no",       "yes",      "any",      "any"),
  missing  = c("any",     "no",       "any",      "yes",      "any"),
  rendered = c(FALSE,     FALSE,      TRUE,       TRUE,       TRUE),
  stringsAsFactors = FALSE
)

#' @keywords internal
.jst_cps_layout_rules <- data.frame(
  layout         = c("listwise", "pairwise", "per_var_desc", "per_var_freq"),
  top_default    = c("on",       "on",       "on",           "on"),
  bottom_default = c("on",       "on",       "on",           "off"),
  endpoint_label = c("Analysis N", "Remaining N", "Remaining N", "Remaining N"),
  auto_listwise  = c("shown",    "hidden",   "hidden",       "hidden"),
  stringsAsFactors = FALSE
)

#' @keywords internal
.jst_cps_bottom_rules <- data.frame(
  layout    = c(rep("listwise", 7), rep("pairwise", 7),
                rep("per_var_desc", 5), "per_var_freq"),
  has_udms  = c("no","no","no","no","yes","yes","yes",
                "no","no","no","no","yes","yes","yes",
                "no","no","yes","yes","yes",
                "any"),
  has_sysna = c("no","yes","yes","yes","any","any","any",
                "no","yes","yes","yes","any","any","any",
                "no","yes","any","any","any",
                "any"),
  tier      = c("any","none","totals","per_code","none","totals","per_code",
                "any","none","totals","per_code","none","totals","per_code",
                "any","any","none","totals","per_code",
                "any"),
  bottom        = c(FALSE,FALSE,TRUE,TRUE,FALSE,TRUE,TRUE,
                    FALSE,FALSE,TRUE,TRUE,FALSE,TRUE,TRUE,
                    FALSE,FALSE,FALSE,FALSE,TRUE,
                    FALSE),
  resolved_tier = c(NA,NA,"totals","totals",NA,"totals","per_code",
                    NA,NA,"totals","totals",NA,"totals","per_code",
                    NA,NA,NA,NA,"per_code",
                    NA),
  stringsAsFactors = FALSE
)

#' Internal helper: first-match lookup against a CPS rule frame
#'
#' @param rules A .jst_cps_*_rules data frame.
#' @param conds Named list of column -> observed value. A rule cell of
#'   \code{"any"} matches anything; otherwise an exact match is required.
#' @return The first matching row index, or \code{NA_integer_}.
#' @keywords internal
.jst_cps_match <- function(rules, conds) {
  for (i in seq_len(nrow(rules))) {
    ok <- TRUE
    for (col in names(conds)) {
      rv <- rules[[col]][i]
      if (!identical(rv, "any") && !identical(rv, conds[[col]])) {
        ok <- FALSE; break
      }
    }
    if (ok) return(i)
  }
  NA_integer_
}

#' Internal helper: resolve the CPS render spec from the rule tables
#'
#' Reads the three .jst_cps_*_rules frames and applies layer precedence
#' (Visibility first; if not rendered, returns early). Contains no rules of
#' its own. Errors loudly on a coordinate that matches no row.
#'
#' @param layout One of \code{"listwise"}, \code{"pairwise"},
#'   \code{"per_var_desc"}, \code{"per_var_freq"}.
#' @param pipeline_active Logical. Any of jcomplete/jsubset/subset fired.
#' @param has_udms Logical. At least one analysis variable has a declared UDM.
#' @param has_sysna Logical. At least one analysis variable has plain-NA
#'   missingness (in source or pool).
#' @param output_level One of \code{"minimal"}, \code{"standard"},
#'   \code{"full"}.
#' @param detail_tier One of \code{"none"}, \code{"totals"}, \code{"per_code"}.
#' @param cps_toggle Resolved case.processing toggle: \code{TRUE} (always),
#'   \code{FALSE} (never), or \code{NULL} (auto -> use output_level).
#' @return A list: render, render_top, render_bottom, endpoint_label,
#'   show_auto_listwise, resolved_tier, hide_second_col_pair.
#' @keywords internal
.jst_resolve_cps_render <- function(layout, pipeline_active,
                                    has_udms, has_sysna,
                                    output_level, detail_tier,
                                    cps_toggle = NULL) {

  eff_level <- if (isTRUE(cps_toggle)) "full"
               else if (identical(cps_toggle, FALSE)) "minimal"
               else output_level
  any_missing <- has_udms || has_sysna

  vi <- .jst_cps_match(
    .jst_cps_visibility_rules,
    list(level    = eff_level,
         pipeline = if (pipeline_active) "yes" else "no",
         missing  = if (any_missing) "yes" else "no"))
  if (is.na(vi)) {
    stop(".jst_resolve_cps_render(): no visibility rule for level='", eff_level,
         "', pipeline=", pipeline_active, ", missing=", any_missing,
         call. = FALSE)
  }
  if (!.jst_cps_visibility_rules$rendered[vi]) return(list(render = FALSE))

  li <- match(layout, .jst_cps_layout_rules$layout)
  if (is.na(li)) {
    stop(".jst_resolve_cps_render(): unknown layout '", layout, "'",
         call. = FALSE)
  }
  base <- .jst_cps_layout_rules[li, ]

  bi <- .jst_cps_match(
    .jst_cps_bottom_rules,
    list(layout    = layout,
         has_udms  = if (has_udms) "yes" else "no",
         has_sysna = if (has_sysna) "yes" else "no",
         tier      = detail_tier))
  if (is.na(bi)) {
    stop(".jst_resolve_cps_render(): no bottom rule for layout='", layout,
         "', has_udms=", has_udms, ", has_sysna=", has_sysna,
         ", tier='", detail_tier, "'", call. = FALSE)
  }
  ref <- .jst_cps_bottom_rules[bi, ]

  # Base footnote (e): the refinement layer can suppress an "on" base default
  # but cannot promote an "off" one (so per_var_freq never grows a bottom).
  render_bottom <- (base$bottom_default == "on") && isTRUE(ref$bottom)

  list(
    render               = TRUE,
    render_top           = (base$top_default == "on"),
    render_bottom        = render_bottom,
    endpoint_label       = base$endpoint_label,
    show_auto_listwise   = (base$auto_listwise == "shown"),
    resolved_tier        = if (render_bottom) ref$resolved_tier else NA_character_,
    hide_second_col_pair = !pipeline_active
  )
}

#' Internal helper: per-variable source/pool missing rows for the CPS bottom
#'
#' Computes, for one analysis variable, the per-code (and System/NA) counts
#' in the source (full original) and pool (surviving rows) columns. Counts
#' come from the pre-masking columns so SPSS-form UDM codes are still live
#' values; pool counts are post-filter-correct (this is also why the Session
#' 29 pre/post UDM count quirk does not affect the CPS bottom).
#'
#' @param pre_col  Pre-masking original column (full N).
#' @param pool_col Pre-masking column restricted to surviving rows.
#' @param mi       \code{.jst_missing_info()} for the column, or NULL.
#' @return data.frame(code_label, src, pool); empty if no missingness.
#' @keywords internal
.jst_cps_var_rows <- function(pre_col, pool_col, mi) {
  rows <- data.frame(code_label = character(0), src = integer(0),
                     pool = integer(0), stringsAsFactors = FALSE)

  if (!is.null(mi)) {
    if (identical(mi$representation, "stata")) {
      tag_pre  <- haven::na_tag(pre_col)
      tag_pool <- haven::na_tag(pool_col)
      for (i in seq_len(nrow(mi$codes))) {
        r   <- mi$codes[i, ]
        s   <- sum(!is.na(tag_pre)  & tag_pre  == r$tag)
        p   <- sum(!is.na(tag_pool) & tag_pool == r$tag)
        lab <- if (!is.na(r$label) && nzchar(r$label))
                 sprintf('%s ["%s"]', r$code, r$label)
               else sprintf('%s (no label)', r$code)
        rows <- rbind(rows, data.frame(code_label = lab, src = s, pool = p,
                                       stringsAsFactors = FALSE))
      }
    } else {
      # SPSS-form: per declared code, then na_range. UDM codes are live
      # values in the pre-masking columns, so numeric comparison works.
      x_pre  <- suppressWarnings(as.numeric(unclass(pre_col)))
      x_pool <- suppressWarnings(as.numeric(unclass(pool_col)))
      if (!is.null(mi$codes) && nrow(mi$codes) > 0L) {
        for (i in seq_len(nrow(mi$codes))) {
          r   <- mi$codes[i, ]
          s   <- sum(!is.na(x_pre)  & x_pre  == r$numeric)
          p   <- sum(!is.na(x_pool) & x_pool == r$numeric)
          lab <- if (!is.na(r$label) && nzchar(r$label))
                   sprintf('%s ["%s"]', r$code, r$label)
                 else sprintf('%s (no label)', r$code)
          rows <- rbind(rows, data.frame(code_label = lab, src = s, pool = p,
                                         stringsAsFactors = FALSE))
        }
      }
      if (!is.null(mi$na_range) && length(mi$na_range) == 2L) {
        lo <- mi$na_range[1]; hi <- mi$na_range[2]
        s  <- sum(!is.na(x_pre)  & x_pre  >= lo & x_pre  <= hi)
        p  <- sum(!is.na(x_pool) & x_pool >= lo & x_pool <= hi)
        rows <- rbind(rows, data.frame(
          code_label = sprintf("range %s to %s", lo, hi),
          src = s, pool = p, stringsAsFactors = FALSE))
      }
    }
  }

  # System/NA = plain NA cells. For Stata-form, exclude tagged NAs (those are
  # the per-tag rows above); for SPSS/no-mi, is.na captures only genuine
  # system-missing since UDM codes are live values in the pre-masking column.
  if (!is.null(mi) && identical(mi$representation, "stata")) {
    sys_src  <- sum(is.na(pre_col)  & is.na(haven::na_tag(pre_col)))
    sys_pool <- sum(is.na(pool_col) & is.na(haven::na_tag(pool_col)))
  } else {
    sys_src  <- sum(is.na(pre_col))
    sys_pool <- sum(is.na(pool_col))
  }
  if (sys_src > 0L || sys_pool > 0L) {
    rows <- rbind(rows, data.frame(code_label = .jst_label_system_missing,
                                   src = sys_src, pool = sys_pool,
                                   stringsAsFactors = FALSE))
  }
  rows
}

#' Internal helper: print the Case Processing Summary (CPS)
#'
#' Resolves a render spec from the .jst_cps_*_rules tables (via
#' \code{.jst_resolve_cps_render}) and draws the top table (pipeline chain)
#' and, where the spec calls for it, the bottom table (per-variable
#' missing-data breakdown, totals or per_code tier). Contains no render-rule
#' logic of its own; all show/hide decisions arrive pre-resolved.
#'
#' Display design = JStats_CPS_Rendering_Reference.txt (four layouts, Form B
#' bottom). Missing-value semantics = JStats_Missing_Values_Reference.txt.
#'
#' @param sample_info List from \code{.jst_build_sample_info} (carries the
#'   pipeline counts plus pre_pipeline_data / surviving_ids / analysis_vars).
#' @param analysis_type Layout key: \code{"listwise"}, \code{"pairwise"},
#'   \code{"per_var_desc"}, or \code{"per_var_freq"}.
#' @param detail Per-call case.processing.detail override (NULL, "none",
#'   "totals", "per_code"). NULL defers to the joutput tier default.
#' @param notification_template,data,analysis_vars Listwise-discrepancy
#'   notification inputs (per-variable layouts only); see the closure below.
#' @return \code{invisible(NULL)}.
#' @keywords internal
.jst_print_case_processing <- function(sample_info,
                                       analysis_type        = "listwise",
                                       detail                = NULL,
                                       notification_template = NULL,
                                       data                  = NULL,
                                       analysis_vars         = NULL) {

  valid_layouts <- c("listwise", "pairwise", "per_var_desc", "per_var_freq")
  if (!analysis_type %in% valid_layouts) {
    stop(".jst_print_case_processing(): analysis_type must be one of ",
         paste(sprintf("'%s'", valid_layouts), collapse = ", "), ".",
         call. = FALSE)
  }

  n_original <- sample_info$n_original
  n_analysis <- sample_info$n_analysis
  if (is.null(n_original) || n_original == 0) return(invisible(NULL))

  is_per_var <- analysis_type %in% c("per_var_desc", "per_var_freq")

  # ---- Listwise-discrepancy notification (per-variable layouts only) -------
  # Fires when 2+ analysis variables AND listwise across them would drop
  # cases beyond the smallest per-variable N. Independent of the CPS table.
  notification_eligible <- function() {
    if (!is_per_var || is.null(notification_template) ||
        is.null(data) || is.null(analysis_vars) ||
        length(analysis_vars) < 2 ||
        getOption(".jst_output_level", "standard") == "minimal" ||
        isTRUE(sample_info$complete_active)) {
      return(FALSE)
    }
    listwise_n <- sum(stats::complete.cases(data[, analysis_vars, drop = FALSE]))
    per_var_ns <- vapply(analysis_vars,
                         function(v) sum(!is.na(data[[v]])), integer(1))
    listwise_n < min(per_var_ns)
  }
  fire_notification <- function() {
    listwise_n <- sum(stats::complete.cases(data[, analysis_vars, drop = FALSE]))
    msg <- if (grepl("%d", notification_template, fixed = TRUE)) {
      sprintf(notification_template, listwise_n)
    } else notification_template
    cat(msg, "\n\n", sep = "")
  }

  # ---- Resolve the render spec from the rule tables ------------------------
  pre <- sample_info$pre_pipeline_data
  if (!is.null(pre) && !is.null(sample_info$surviving_ids)) {
    pool <- pre[sample_info$surviving_ids, , drop = FALSE]
  } else {
    pool <- NULL
  }
  cps_vars <- intersect(sample_info$analysis_vars,
                        if (is.null(pre)) character(0) else names(pre))

  mi_list  <- if (length(cps_vars))
                lapply(cps_vars, function(v) .jst_missing_info(pre[[v]]))
              else list()
  names(mi_list) <- cps_vars
  has_udms  <- any(vapply(mi_list, function(mi)
                 !is.null(mi) && !is.null(mi$codes) && nrow(mi$codes) > 0L,
                 logical(1)))
  has_sysna <- any(vapply(cps_vars, function(v) sum(is.na(pre[[v]])) > 0L,
                          logical(1)))

  pipeline_active <- isTRUE(sample_info$complete_active) ||
                     isTRUE(sample_info$filter_active) ||
                     !is.null(sample_info$n_after_subset)

  cps_toggle  <- .jst_resolve_toggle("case.processing", NULL)
  detail_tier <- .jst_resolve_toggle("case.processing.detail", detail)
  out_level   <- getOption(".jst_output_level", "standard")

  spec <- .jst_resolve_cps_render(
    layout          = analysis_type,
    pipeline_active = pipeline_active,
    has_udms        = isTRUE(has_udms),
    has_sysna       = isTRUE(has_sysna),
    output_level    = out_level,
    detail_tier     = detail_tier,
    cps_toggle      = cps_toggle)

  fmt1 <- function(x) sprintf("%.1f", x)
  dash <- "\u2014"
  # Pad on DISPLAY width, not sprintf's byte-based field width: the em-dash
  # is one column but three UTF-8 bytes, so sprintf("%Ns", ...) would under-
  # pad dash cells and shift the row. padl/padr right/left-justify by glyph
  # width so numeric and dash rows align.
  padl <- function(x, w) { x <- as.character(x)
    paste0(strrep(" ", max(0L, w - nchar(x, type = "width"))), x) }
  padr <- function(x, w) { x <- as.character(x)
    paste0(x, strrep(" ", max(0L, w - nchar(x, type = "width")))) }
  dw   <- function(x) nchar(as.character(x), type = "width")

  if (isTRUE(spec$render)) {

    # ---- TOP TABLE: pipeline chain ----
    if (isTRUE(spec$render_top)) {
      labels <- "Original"; surv_v <- n_original; exc_v <- NA_integer_
      prior  <- n_original

      if (isTRUE(sample_info$complete_active) &&
          !is.null(sample_info$n_after_complete)) {
        lab <- if (!is.null(sample_info$complete_vars) &&
                   length(sample_info$complete_vars))
                 sprintf("jcomplete (%s)",
                         paste(sample_info$complete_vars, collapse = ", "))
               else "jcomplete"
        labels <- c(labels, lab)
        exc_v  <- c(exc_v, prior - sample_info$n_after_complete)
        surv_v <- c(surv_v, sample_info$n_after_complete)
        prior  <- sample_info$n_after_complete
      }
      if (isTRUE(sample_info$filter_active) &&
          !is.null(sample_info$n_after_filter)) {
        lab <- if (!is.null(sample_info$filter_expr) &&
                   nzchar(sample_info$filter_expr))
                 sprintf("jsubset (%s)", sample_info$filter_expr)
               else "jsubset"
        labels <- c(labels, lab)
        exc_v  <- c(exc_v, prior - sample_info$n_after_filter)
        surv_v <- c(surv_v, sample_info$n_after_filter)
        prior  <- sample_info$n_after_filter
      }
      if (!is.null(sample_info$n_after_subset)) {
        lab <- if (!is.null(sample_info$subset_expr) &&
                   nzchar(sample_info$subset_expr))
                 sprintf("subset = %s", sample_info$subset_expr)
               else "subset"
        labels <- c(labels, lab)
        exc_v  <- c(exc_v, prior - sample_info$n_after_subset)
        surv_v <- c(surv_v, sample_info$n_after_subset)
        prior  <- sample_info$n_after_subset
      }
      if (isTRUE(spec$show_auto_listwise)) {
        labels <- c(labels, "Auto-listwise")
        exc_v  <- c(exc_v, sample_info$n_excluded_missing)
        surv_v <- c(surv_v, n_analysis)
        prior  <- n_analysis
      }
      labels <- c(labels, spec$endpoint_label)
      exc_v  <- c(exc_v, NA_integer_)
      surv_v <- c(surv_v, prior)

      # Column widths sized to content (display width) so long labels and
      # the multibyte em-dash both align. Header is indented 2, data rows 4;
      # both pad their label field to the same absolute end column.
      exc_strs  <- vapply(seq_along(labels), function(i)
                     if (is.na(exc_v[i])) dash else as.character(exc_v[i]),
                     character(1))
      surv_strs <- as.character(surv_v)
      pct_strs  <- fmt1(surv_v / n_original * 100)
      h_ind <- 2L; r_ind <- 4L
      lab_end <- max(h_ind + dw("Case Processing"), r_ind + max(dw(labels)))
      exc_w  <- max(dw("Excluded"),    max(dw(exc_strs)))
      surv_w <- max(dw("Surviving"),   max(dw(surv_strs)))
      pct_w  <- max(dw("% Surviving"), max(dw(pct_strs)))
      g <- "  "

      cat("\n")
      cat(strrep(" ", h_ind), padr("Case Processing", lab_end - h_ind), g,
          padl("Excluded", exc_w), g, padl("Surviving", surv_w), g,
          padl("% Surviving", pct_w), "\n", sep = "")
      for (i in seq_along(labels)) {
        cat(strrep(" ", r_ind), padr(labels[i], lab_end - r_ind), g,
            padl(exc_strs[i], exc_w), g, padl(surv_strs[i], surv_w), g,
            padl(pct_strs[i], pct_w), "\n", sep = "")
      }
    }

    # ---- BOTTOM TABLE: missing-data breakdown (Form B) ----
    if (isTRUE(spec$render_bottom) && !is.null(pool)) {
      per_code <- identical(spec$resolved_tier, "per_code")
      two_cols <- !isTRUE(spec$hide_second_col_pair)
      n_pool   <- nrow(pool)

      # First pass: gather the rows to display per variable (skip variables
      # with no missingness in either column), so widths can be sized to
      # actual content.
      disp <- list()
      for (v in cps_vars) {
        vr <- .jst_cps_var_rows(pre[[v]], pool[[v]], mi_list[[v]])
        if (nrow(vr) == 0L || (sum(vr$src) == 0L && sum(vr$pool) == 0L)) next
        rows <- if (per_code) vr
                else data.frame(code_label = "Missing", src = sum(vr$src),
                                pool = sum(vr$pool), stringsAsFactors = FALSE)
        disp[[length(disp) + 1L]] <- list(var = v, rows = rows)
      }

      if (length(disp) > 0L) {
        src_hdr  <- paste0("From ", n_original)
        pool_hdr <- paste0("From ", n_pool)
        all_lab  <- unlist(lapply(disp, function(d) d$rows$code_label))
        all_src  <- unlist(lapply(disp, function(d) d$rows$src))
        all_pool <- unlist(lapply(disp, function(d) d$rows$pool))
        all_srcp <- fmt1(all_src  / n_original * 100)
        all_plp  <- fmt1(all_pool / n_pool     * 100)

        h_ind <- 2L; c_ind <- 6L
        lab_end <- max(h_ind + dw("Missing-data breakdown"),
                       c_ind + max(dw(all_lab)))
        srcn_w  <- max(dw(src_hdr),  max(dw(all_src)))
        pct_w   <- max(dw("%"), max(dw(all_srcp), dw(all_plp)))
        pooln_w <- max(dw(pool_hdr), max(dw(all_pool)))
        g <- "  "

        emit <- function(indent, lab, lab_w, c1, p1, c2, p2) {
          if (two_cols)
            cat(strrep(" ", indent), padr(lab, lab_w), g, padl(c1, srcn_w), g,
                padl(p1, pct_w), g, padl(c2, pooln_w), g, padl(p2, pct_w),
                "\n", sep = "")
          else
            cat(strrep(" ", indent), padr(lab, lab_w), g, padl(c1, srcn_w), g,
                padl(p1, pct_w), "\n", sep = "")
        }

        cat("\n")
        emit(h_ind, "Missing-data breakdown", lab_end - h_ind,
             src_hdr, "%", pool_hdr, "%")
        for (d in disp) {
          cat(strrep(" ", 4L), d$var, "\n", sep = "")
          for (j in seq_len(nrow(d$rows))) {
            sc <- d$rows$src[j]; pl <- d$rows$pool[j]
            emit(c_ind, d$rows$code_label[j], lab_end - c_ind,
                 as.character(sc), fmt1(sc / n_original * 100),
                 as.character(pl), fmt1(pl / n_pool * 100))
          }
        }
      }
    }
    cat("\n")
  }

  # Notification fires on its own conditions, table or no table.
  if (notification_eligible()) fire_notification()

  invisible(NULL)
}

#' Internal helper: check that variable names exist in a data frame
#'
#' Produces clear error messages for several common user mistakes:
#'   - data passed as a character string (quoted dataset name)
#'   - data NULL
#'   - data is a matrix (needs as.data.frame())
#'   - data is some other non-data-frame object
#'   - data is a valid data frame, but the variable names don't appear in it
#'
#' Without these tailored messages, a string or other non-data-frame value
#' for `data` would fall through to the variable-name check and produce a
#' misleading "Variable(s) not found" error pointing at the variables
#' rather than at the real problem (the data argument itself).
#'
#' @keywords internal
.jst_check_vars <- function(data, var_names, data_name = NULL) {

  # -- First: confirm `data` is actually a data frame ----------------------
  if (!is.data.frame(data)) {
    if (is.character(data) && length(data) == 1) {
      stop(paste0(
        "'", data, "' (passed as a character string) is not a data frame. ",
        "Remove the quotes - e.g., ", data, " instead of \"", data, "\"."
      ), call. = FALSE)
    }
    if (is.null(data)) {
      stop(paste0(
        "data = NULL: no data frame supplied. Pass a data frame as the ",
        "data argument, or set a default with juse() first."
      ), call. = FALSE)
    }
    if (is.matrix(data)) {
      label <- if (!is.null(data_name)) data_name else "data"
      stop(paste0(
        "'", label, "' is a matrix, not a data frame. ",
        "Convert it first with: as.data.frame(", label, ")"
      ), call. = FALSE)
    }
    # Catch-all: non-data-frame R object of some other type.
    label <- if (!is.null(data_name)) data_name else "data"
    stop(paste0(
      "'", label, "' is a ", class(data)[1], " object, not a data frame. ",
      "The data argument requires a data frame."
    ), call. = FALSE)
  }

  # -- Then: confirm the requested variables exist in the data frame -------
  missing_vars <- var_names[!var_names %in% names(data)]
  if (length(missing_vars) > 0) {
    df_label <- if (!is.null(data_name)) {
      data_name
    } else {
      "the data frame"
    }
    stop(paste0(
      "Variable(s) not found in ", df_label, ": ",
      paste(missing_vars, collapse = ", "), ".\n",
      "Check spelling and make sure the variable exists."
    ), call. = FALSE)
  }
}

#' Internal helper: validate named arguments captured via ...
#'
#' Catches mis-named argument aliases that users sometimes type instead of
#' the correct name and errors with a "Did you mean" suggestion. Also
#' catches any other named argument in \code{...} that isn't on the
#' aliases list and errors with a plain unused-argument message. Used by
#' functions that accept \code{...} as a safety net (not for substantive
#' variable-passing).
#'
#' @param dots A list of arguments captured via \code{list(...)}.
#' @param aliases Named character vector. Names are the incorrect argument
#'   names that users might type; values are the correct argument names
#'   to suggest in the error message.
#' @param fn_name Character. The calling function's name, used in the
#'   error message.
#'
#' @return \code{invisible(NULL)}. Called for its side effect of
#'   throwing an error when an invalid argument name is found.
#'
#' @keywords internal
.jst_check_args <- function(dots, aliases, fn_name) {
  if (length(dots) == 0) return(invisible(NULL))
  dot_names <- names(dots)
  if (is.null(dot_names)) dot_names <- rep("", length(dots))

  for (nm in dot_names) {
    if (nzchar(nm) && nm %in% names(aliases)) {
      stop(sprintf("Argument '%s' is not valid in %s(). Did you mean `%s`?",
                   nm, fn_name, aliases[[nm]]), call. = FALSE)
    }
  }
  bad <- dot_names[nzchar(dot_names)]
  if (length(bad) > 0) {
    stop(sprintf("Unused argument(s) in %s(): %s",
                 fn_name, paste(bad, collapse = ", ")), call. = FALSE)
  }
  invisible(NULL)
}

#' Internal helper: resolve which data frame to use when none is explicitly given
#'
#' Looks up the data frame name set by \code{juse()} via the
#' \code{.jst_default_data} option, fetches the object from the specified
#' environment, and returns both the data frame itself and its name. The
#' name is needed by callers for output messages such as "(Using default
#' data frame: X)".
#'
#' Errors with a clear message if no default has been set, if the named
#' object cannot be found in the supplied environment, or if it is not a
#' data frame.
#'
#' @param envir Environment in which to look up the default data frame.
#'   Defaults to the parent frame so the caller's environment is searched.
#'
#' @return A list with two components:
#'   \describe{
#'     \item{data}{The resolved data frame.}
#'     \item{name}{Character string giving the name of the data frame.}
#'   }
#'
#' @keywords internal
.jst_resolve_data <- function(envir = parent.frame()) {
  data_name <- getOption(".jst_default_data", default = NULL)
  if (is.null(data_name)) {
    stop("No data frame specified and no default set. Use juse() to set a default.",
         call. = FALSE)
  }
  if (!exists(data_name, envir = envir)) {
    stop(paste0("Default data frame ", data_name,
                " not found. It may have been removed or renamed."),
         call. = FALSE)
  }
  data <- get(data_name, envir = envir)
  if (!is.data.frame(data)) {
    stop(paste0(data_name, " is not a data frame."), call. = FALSE)
  }
  list(data = data, name = data_name)
}

#' Internal helper: resolve the first positional argument of a data-first function
#'
#' Inspects the unevaluated first argument of a data-first function and
#' decides whether the user passed a real data frame, omitted the data
#' argument (so the \code{juse()} default should be used), or passed a
#' bare variable name without a leading comma (so the default should be
#' used and the captured symbol treated as the user's first content
#' argument).
#'
#' Distinguishes five outcomes via the \code{mode} field:
#' \describe{
#'   \item{\code{default}}{Data argument was missing; juse default used.}
#'   \item{\code{null}}{User passed literal \code{NULL}; only returned
#'     when \code{allow_null = TRUE}. Caller handles (e.g., for global
#'     clear semantics in jdummy/jsubset/jcomplete).}
#'   \item{\code{explicit}}{User passed an expression that evaluated
#'     to a data frame. That data frame is used.}
#'   \item{\code{vector_input}}{Only returned when
#'     \code{accept_vector = TRUE}. User passed an expression that
#'     evaluated to a non-data-frame value (typically an atomic vector
#'     or a column reference like \code{SampleData$Gender}). The caller
#'     handles this --- usually by wrapping the value in a temporary
#'     data frame.}
#'   \item{\code{symbol_with_default}}{User passed a bare symbol that
#'     did not evaluate (or evaluated to a non-data-frame value when
#'     \code{accept_vector = FALSE}). Treated as a variable-name attempt
#'     missing the leading comma. The juse default is used as the data
#'     frame, and the caller is expected to inject \code{first_arg_sub}
#'     as an additional content argument.}
#' }
#'
#' Errors with a tailored message when the user passed something that
#' cannot be resolved (e.g., bare symbol with no juse default set, or
#' literal \code{NULL} when \code{allow_null = FALSE}).
#'
#' @param data_sub The substituted first argument, captured by the
#'   caller via \code{substitute(data)}.
#' @param data_missing Logical. The result of \code{missing(data)} in
#'   the calling function. Must be captured by the caller because
#'   \code{missing()} cannot be used reliably across function call
#'   boundaries.
#' @param fn_name Character. The calling function's name, used in
#'   tailored error messages.
#' @param envir Environment. The calling function's parent frame; used
#'   for evaluating the first argument and looking up the juse default
#'   data frame.
#' @param allow_null Logical. If \code{TRUE}, literal \code{NULL} is
#'   returned with mode \code{null} for the caller to handle.
#'   Defaults to \code{FALSE}, in which case literal \code{NULL} errors.
#' @param accept_vector Logical. If \code{TRUE}, an expression that
#'   evaluates to a non-data-frame value is returned with mode
#'   \code{vector_input} for the caller to handle. Defaults to
#'   \code{FALSE}, in which case such inputs are treated as bare-symbol
#'   variable-name attempts (mode \code{symbol_with_default}).
#'
#' @return A list with components:
#'   \describe{
#'     \item{\code{mode}}{Character. One of \code{default},
#'       \code{null}, \code{explicit}, \code{vector_input},
#'       \code{symbol_with_default}.}
#'     \item{\code{data}}{The resolved data frame (or \code{NULL} for
#'       modes \code{null} and \code{vector_input}).}
#'     \item{\code{name}}{Character name string for messages (or
#'       \code{NULL} for modes \code{null} and \code{vector_input}).}
#'     \item{\code{first_arg_sub}}{The user's substituted first argument
#'       (or \code{NULL} when not applicable). Set for modes
#'       \code{vector_input} and \code{symbol_with_default}.}
#'     \item{\code{first_arg_value}}{The evaluated value of the first
#'       argument, set only for mode \code{vector_input}; \code{NULL}
#'       otherwise.}
#'   }
#'
#' @keywords internal
.jst_resolve_first_arg <- function(data_sub, data_missing, fn_name,
                                   envir         = parent.frame(),
                                   allow_null    = FALSE,
                                   accept_vector = FALSE) {

  # -- Case 1: data argument truly missing ----------------------------------
  if (data_missing) {
    resolved <- .jst_resolve_data(envir = envir)
    return(list(mode = "default",
                data = resolved$data, name = resolved$name,
                first_arg_sub = NULL, first_arg_value = NULL))
  }

  # -- Case 2: literal NULL passed in ---------------------------------------
  if (is.null(data_sub)) {
    if (allow_null) {
      return(list(mode = "null",
                  data = NULL, name = NULL,
                  first_arg_sub = NULL, first_arg_value = NULL))
    }
    stop(paste0(fn_name, "(): NULL is not a valid data argument. ",
                "Provide a data frame, or set a default first with juse()."),
         call. = FALSE)
  }

  # -- Try to evaluate the substituted first argument -----------------------
  eval_result <- tryCatch(
    list(value = eval(data_sub, envir = envir), failed = FALSE),
    error = function(e) list(value = NULL, failed = TRUE)
  )

  # -- Case 3: evaluated to a data frame ------------------------------------
  if (!eval_result$failed && is.data.frame(eval_result$value)) {
    return(list(mode = "explicit",
                data = eval_result$value,
                name = paste(deparse(data_sub), collapse = ""),
                first_arg_sub = NULL, first_arg_value = NULL))
  }

  # -- Cases 4 and 5 both need the juse default to fall back on -------------
  default_name <- getOption(".jst_default_data", default = NULL)

  # -- Case 4: evaluated to a non-data-frame value (vector input) -----------
  if (accept_vector && !eval_result$failed) {
    return(list(mode = "vector_input",
                data = NULL, name = NULL,
                first_arg_sub  = data_sub,
                first_arg_value = eval_result$value))
  }

  # -- Case 5: bare symbol that didn't evaluate (or non-data-frame value
  #            when accept_vector = FALSE). Treat as a variable name. -------
  if (is.null(default_name)) {
    data_str <- paste(deparse(data_sub), collapse = "")
    stop(paste0(
      "'", data_str, "' not found. Did you mean to use it as a variable name?\n",
      "If so, provide the data frame: ", fn_name, "(MyData, ", data_str, ")\n",
      "Or set a default first with juse(MyData), then: ", fn_name, "(", data_str, ")"
    ), call. = FALSE)
  }
  resolved <- .jst_resolve_data(envir = envir)
  list(mode = "symbol_with_default",
       data = resolved$data, name = resolved$name,
       first_arg_sub = data_sub, first_arg_value = NULL)
}

#' Internal helper: detect values that look like coded missing markers
#'
#' Scans a numeric vector for values likely to be coded missing markers
#' (e.g. \code{99}, \code{999}, \code{-99}) rather than legitimate
#' data. Two heuristics are applied:
#' \enumerate{
#'   \item Any negative value when all other values are positive —
#'     catches conventions like \code{-99} or \code{-9} for missing in
#'     otherwise non-negative categorical data.
#'   \item Any value whose absolute magnitude is at least 5 times the
#'     maximum of the other values — catches \code{99} in a 1-5 scale,
#'     \code{999} in a 1-10 scale, and so on.
#' }
#' Does not print messages; the calling function decides how to surface
#' the findings.
#'
#' @param x A variable (numeric or numeric-coercible).
#' @param var_name Character. The variable's name; not used by this
#'   helper but accepted for symmetry with callers that supply it.
#'
#' @return A sorted, unique numeric vector of suspicious values, or an
#'   empty numeric if none are found.
#'
#' @keywords internal
.jst_detect_suspicious_values <- function(x, var_name) {

  # unclass() strips haven_labelled / vctrs_vctr wrappers and returns the
  # underlying double values unchanged, sidestepping a vctrs dispatch
  # ordering issue where as.numeric() on a haven_labelled subset can fail
  # in sessions where readxl was loaded before haven's vec_cast method
  # registered into vctrs's dispatch table. Class-neutral for non-haven
  # input — unclass() of a plain numeric is a no-op, and unclass() of a
  # factor returns the integer codes that as.numeric(factor) already used.
  vals <- unique(as.numeric(unclass(x)[!is.na(x)]))
  if (length(vals) < 2) return(numeric(0))

  suspicious <- numeric(0)

  # Rule 1: negative values when all others are positive AND
  # the absolute magnitude is at least 3x the max positive value.
  # NOTE: deliberately conservative — misses missing-value codes like
  # -99 in variables with naturally high positives (e.g., Age 18-80
  # would not flag -99 because 99 < 3 * 80 = 240). Trade-off: better
  # to miss a sentinel that the user can spot from jload's output than
  # to flag a real extreme value as suspicious. The SPSS-defined UDM
  # detector (.jst_scan_coded_missing's na_values branch) catches
  # these cases when haven metadata is preserved; the heuristic is
  # the safety net for plain numerics where metadata has been stripped
  # (e.g., post-csv/xlsx/dta load).
  neg_vals <- vals[vals < 0]
  pos_vals <- vals[vals >= 0]

  if (length(neg_vals) > 0 && length(pos_vals) >= 2) {
    pos_max <- max(pos_vals)
    if (pos_max > 0) {
      suspicious <- c(suspicious, neg_vals[abs(neg_vals) >= 3 * pos_max])
    } else {
      suspicious <- c(suspicious, neg_vals)
    }
  }


  # Rule 2: absolute magnitude >= 5x the max of remaining values
  for (v in vals) {
    if (v %in% suspicious) next
    others <- vals[vals != v]
    if (length(others) == 0) next
    other_max <- max(abs(others))
    if (other_max > 0 && abs(v) >= 5 * other_max) {
      suspicious <- c(suspicious, v)
    }
  }

  return(sort(unique(suspicious)))
}


# -----------------------------------------------------------------------------
# Missing-label wordlist and predicate
#
# Canonical list of value-label strings that suggest a value is intended as
# missing rather than as ordinary data. Used to classify Pattern A (label-
# only, no formal declaration) variables in jconvert, and to narrow
# .jst_scan_coded_missing's label-only branch so generic labels on
# suspicious values fall through to the "suspected" classification while
# missing-suggestive labels surface for jdeclare_udm action.
#
# All entries are lower-case and whitespace-trimmed; .jst_label_suggests_
# missing() applies tolower(trimws(...)) before matching. Apostrophe
# variants of "don't know" are enumerated explicitly rather than via regex
# normalisation — the explicit list is easier to audit and extend.
#
# Replaces the literal "missing" match formerly performed by
# .jst_detect_missing_labels (retired in v0.9.5 per Cross-cutting Decision 1
# of JStats_Missing_Values_Reference.txt Part 4).
# -----------------------------------------------------------------------------

#' @keywords internal
.jst_missing_label_wordlist <- c(
  "missing", "refused", "don't know", "dont know",
  "no answer", "not asked", "not applicable", "n/a", "na",
  "skipped", "declined", "prefer not to say"
)


# -----------------------------------------------------------------------------
# .jst_label_system_missing
# Display label used in output tables for the system-missing row (R's
# plain NA, distinct from declared UDMs). "System/NA" reads in two
# audiences at once: SPSS/Stata users recognize "System" as the platform
# term for system-missing, and R users recognize "NA" as the in-language
# token for the same thing. Referenced wherever a per-row missing label
# is rendered (jfreq's Missing section in v0.9.6; CP table missing rows
# when the UDM-content work lands; future jscreen tweaks if its format
# aligns). Centralising as a constant ensures consistency if the term
# ever changes.
# -----------------------------------------------------------------------------

#' @keywords internal
.jst_label_system_missing <- "System/NA"


#' Internal helper: does a value label suggest missingness?
#'
#' Returns \code{TRUE} when the supplied label string, after case-folding
#' and whitespace trimming, matches an entry in
#' \code{.jst_missing_label_wordlist}. Returns \code{FALSE} for \code{NULL},
#' \code{NA}, non-character input, and labels that do not match the
#' wordlist.
#'
#' @keywords internal
.jst_label_suggests_missing <- function(label) {
  if (is.null(label)) return(FALSE)
  if (!is.character(label)) return(FALSE)
  if (length(label) != 1L) return(FALSE)
  if (is.na(label)) return(FALSE)
  tolower(trimws(label)) %in% .jst_missing_label_wordlist
}


# -----------------------------------------------------------------------------
# .jst_apply_declared_udms_as_na()
#
# Pipeline-step helper invoked at .jst_apply_pipeline's Step 0. For each
# column whose formal UDM information (as surfaced by .jst_missing_info)
# uses SPSS representation, masks declared na_values codes and na_range
# cells to NA on the analysis copy. The underlying data frame in the user's
# workspace is unchanged — na_values / na_range metadata stays attached to
# the column so round-trip fidelity through jsave is preserved. Stata-form
# tagged_na columns are not touched; tagged NAs satisfy is.na() natively at
# the C level and downstream code catches them without intervention.
#
# Replaces .jst_preprocess_na (retired in v0.9.5) per Cross-cutting Decision
# 5 of JStats_Missing_Values_Reference.txt Part 4.
#
# Returns a list with:
#   data      - the modified analysis copy
#   converted - a named list of per-variable entries. Each element is
#               list(entries, n_cells) where entries is a data.frame with
#               columns code_display, label, count (one row per declared
#               na_values code, count possibly 0; plus one row for the
#               na_range when declared), and n_cells is the aggregate
#               OR-mask count. Consumed by jfreq's Missing section for
#               per-code counts and by the (forthcoming) CPS per_code
#               bottom; n_cells drives udm_active.
# -----------------------------------------------------------------------------

#' Internal helper: mask declared SPSS-form UDM cells to NA on analysis copy
#'
#' @keywords internal
.jst_apply_declared_udms_as_na <- function(data) {
  converted <- list()

  for (vname in names(data)) {
    col  <- data[[vname]]
    info <- .jst_missing_info(col)
    if (is.null(info)) next
    if (info$representation != "spss") next

    # unclass() bypasses vctrs cast issues — see the matching note in
    # .jst_detect_suspicious_values() and .jst_handle_udms() for context.
    x_num <- suppressWarnings(as.numeric(unclass(col)))
    mask  <- rep(FALSE, length(x_num))

    # Per-code entries: one row per declared na_values code (count may be
    # 0 when a declared code is absent from the data), plus one row for
    # the na_range when declared. code_display / label mirror
    # .jst_missing_info()'s codes data frame so jfreq's Missing section
    # and the future CPS per_code bottom share one per-code count source.
    # The aggregate n_cells keeps its prior OR-mask semantics (used for
    # masking-activity detection / udm_active).
    entries <- data.frame(code_display = character(0), label = character(0),
                          count = integer(0), stringsAsFactors = FALSE)

    if (!is.null(info$codes) && nrow(info$codes) > 0L) {
      for (i in seq_len(nrow(info$codes))) {
        cnum <- info$codes$numeric[i]
        if (is.na(cnum)) next
        code_mask <- (!is.na(x_num) & x_num == cnum)
        mask      <- mask | code_mask
        entries   <- rbind(entries, data.frame(
          code_display = info$codes$code[i],
          label        = info$codes$label[i],
          count        = as.integer(sum(code_mask)),
          stringsAsFactors = FALSE))
      }
    }
    if (!is.null(info$na_range) && length(info$na_range) == 2L) {
      range_mask <- (!is.na(x_num) &
                       x_num >= info$na_range[1] &
                       x_num <= info$na_range[2])
      mask    <- mask | range_mask
      entries <- rbind(entries, data.frame(
        code_display = sprintf("range %s to %s",
                               as.character(info$na_range[1]),
                               as.character(info$na_range[2])),
        label        = NA_character_,
        count        = as.integer(sum(range_mask)),
        stringsAsFactors = FALSE))
    }

    n_cells <- sum(mask)
    if (n_cells > 0L) {
      # Positional indexing preserves class, na_values, na_range, and
      # value labels — only the underlying values change.
      data[[vname]][mask] <- NA
      converted[[vname]] <- list(
        entries = entries,
        n_cells = n_cells
      )
    }
  }

  list(data = data, converted = converted)
}


# -----------------------------------------------------------------------------
# .jst_tag_letters_to_codes()
#
# Translates Stata-style tagged-NA letter tags (.a, .b, ...) into the
# equivalent numeric UDM codes drawn from joptions("udm.convention.codes")
# (default c(-99, -98, -97, -96)). Mapping is positional: .a -> codes[1],
# .b -> codes[2], etc. Per Decision 4 of
# JStats_Missing_Values_Reference.txt Part 4 (Session 25 walk-through
# lock), this is the convention-based direction shared between
# jconvert's Stata-to-SPSS conversion path and jrecode's cross-
# convention error echo-back. jdeclare_udm in Step 5b will consume
# the same helper.
#
# When the input letter count exceeds the convention code count, the
# return covers only the mappable subset (in order) and
# attr(result, "unmapped") holds the letters that could not be mapped.
# Callers decide whether to error, truncate, or annotate based on the
# unmapped attribute.
# -----------------------------------------------------------------------------

#' Internal helper: map Stata-style tagged-NA letters to UDM codes
#'
#' Translates a vector of lowercase letter tags (e.g.
#' \code{c("a", "b")}) into the equivalent numeric UDM codes drawn
#' from \code{joptions("udm.convention.codes")}. Mapping is positional:
#' \code{.a} maps to the first code, \code{.b} to the second, etc.
#'
#' When \code{length(letters_in) > length(convention_codes)}, the
#' return covers only the mappable subset (in order) and
#' \code{attr(result, "unmapped")} holds the letters that could not be
#' mapped. Callers decide whether to error, truncate, or annotate
#' based on the unmapped attribute.
#'
#' @param letters_in Character vector of lowercase letter tags. Must
#'   be single lowercase letters (\code{"a"} through \code{"z"}); no
#'   leading period. Caller is responsible for stripping any leading
#'   period before calling.
#' @param convention_codes Optional numeric vector of UDM codes. When
#'   \code{NULL} (the default), the helper sources the value of
#'   \code{joptions("udm.convention.codes")} via the standard
#'   \code{getOption()} fallback.
#'
#' @return Named numeric vector. Names are the input letters; values
#'   are the corresponding convention codes. Carries an
#'   \code{unmapped} attribute (character vector) when the input
#'   letter count exceeded the convention code count.
#'
#' @keywords internal
.jst_tag_letters_to_codes <- function(letters_in, convention_codes = NULL) {

  if (is.null(convention_codes)) {
    convention_codes <- getOption(".jst_options_udm_convention_codes",
                                  .jst_options_defaults$udm.convention.codes)
  }

  if (length(letters_in) == 0L) {
    return(stats::setNames(numeric(0), character(0)))
  }

  n_mappable <- min(length(letters_in), length(convention_codes))

  result <- stats::setNames(
    as.numeric(convention_codes)[seq_len(n_mappable)],
    letters_in[seq_len(n_mappable)]
  )

  if (length(letters_in) > length(convention_codes)) {
    attr(result, "unmapped") <-
      letters_in[(length(convention_codes) + 1L):length(letters_in)]
  }

  result
}


# -- Variable classifier helpers ----------------------------------------------
#
# Four helpers that answer "what kind of variable is this?" Each does one
# thing well — they are deliberately not merged because callers have
# different needs:
#
#   .jst_is_categorical()      — intent helper. TRUE only when the user has
#                                declared categorical (jdummy registration,
#                                or class factor/logical/character). Drives
#                                behavioral decisions in jlm and jlogistic.
#   .jst_is_discrete_integer() — structural helper. TRUE for variables that
#                                *look* categorical (haven-labelled with
#                                labels in data and <= 6 distinct values, or
#                                whole-number 0-6 numeric). Drives warnings.
#   .jst_is_dichotomy()        — single source of truth for "is this a two-
#                                value variable, and what coding does it
#                                use?" Used by jlm and jlogistic DV/IV
#                                checks; future jcorr point-biserial.
#   .jst_is_count()            — TRUE for plain non-negative whole-number
#                                numeric, max <= 6, not haven-labelled.
#                                Warning trigger for jlm DV.
# -----------------------------------------------------------------------------

#' Internal helper: intent-based categorical classifier
#'
#' Returns TRUE only when the user has explicitly signalled that a variable
#' should be treated as categorical. This helper answers the question
#' "should this variable be behaviorally treated as categorical?" — for
#' decisions like factoring in regression, expanding to dummies, or
#' excluding from a correlation matrix.
#'
#' Paired with \code{.jst_is_discrete_integer()} (the structural helper).
#' Callers needing behavioral decisions use this helper; callers needing
#' a warning trigger typically check this helper first, and fall back to
#' the structural helper only if this one returns FALSE.
#'
#' Rules (first match wins):
#'
#' \enumerate{
#'   \item jdummy() registration for \code{var_name} on \code{data_name}
#'         -> categorical.
#'   \item Class factor, logical, or character -> categorical.
#'   \item Otherwise -> FALSE.
#' }
#'
#' NA preprocessing is expected to have run already via
#' \code{.jst_apply_pipeline()} before this helper is called on analysis
#' data, though neither rule depends on NA state.
#'
#' @param x A variable (vector).
#' @param var_name Optional character string. The variable's column name.
#'   Required for the jdummy() registration check.
#' @param data_name Optional character string. The data frame's name.
#'   Required for the jdummy() registration check.
#' @return TRUE if the user has declared the variable categorical,
#'   FALSE otherwise.
#' @keywords internal
.jst_is_categorical <- function(x, var_name = NULL, data_name = NULL) {

  # -- Rule A: jdummy() registration ---------------------------------------
  if (!is.null(var_name) && !is.null(data_name)) {
    dummy_regs <- .jst_get_dummy(data_name)
    if (!is.null(dummy_regs) && length(dummy_regs) > 0) {
      is_registered <- any(vapply(dummy_regs,
                                  function(r) identical(r$var_name, var_name),
                                  logical(1)))
      if (is_registered) return(TRUE)
    }
  }

  # -- Rule B: factor, logical, character ----------------------------------
  if (is.factor(x) || is.logical(x) || is.character(x)) return(TRUE)

  FALSE
}


#' Internal helper: structural categorical-looking classifier
#'
#' Returns TRUE when a variable's shape suggests it *could* be categorical
#' but has not been explicitly declared as such via jdummy() or a per-call
#' override. This helper answers a different question from
#' \code{.jst_is_categorical()}: it describes the structure of the values,
#' not the user's intent.
#'
#' Used primarily as a *warning trigger*: callers that want to alert users
#' to "this looks like it should probably have been jdummy-registered or
#' passed via categorical=" check this helper. It does NOT license
#' behavioral changes — analysis functions should only factor variables
#' based on the intent helper, not this one.
#'
#' Two structural rules, checked in order. First match wins.
#'
#' \enumerate{
#'   \item haven_labelled (including haven_labelled_spss) with value labels
#'         attached to at least one non-missing value present in the data,
#'         AND <= 6 unique non-NA values overall -> TRUE. Character-type
#'         labelled vectors return TRUE immediately. Numeric labelled
#'         vectors require BOTH that at least one labelled code actually
#'         appears in the (post-NA-preprocessing) data AND that there are
#'         no more than 6 distinct values present (variables with 7+
#'         distinct values have enough categories that linear-model
#'         assumptions hold reasonably well).
#'   \item Plain numeric (or haven_labelled numeric that fell through 1)
#'         with all whole-number values, min >= 0, max <= 6, and at least
#'         2 unique non-NA values -> TRUE.
#' }
#'
#' Bounds on both rules (0 to 6 inclusive) support the common view that
#' an interval-like variable with 6+ categories is adequately continuous
#' for linear-model use. 7-category Likert coded as 0-6 or 1-6 still
#' triggers the warning; coded as 1-7 does not. A 10-category labelled
#' Income variable falls through both rules and is treated as continuous.
#'
#' NA preprocessing (auto-conversion of values labelled "Missing" to NA)
#' is expected to have run already via \code{.jst_apply_pipeline()} before
#' this helper is called on analysis data. Rule 1's "labelled codes
#' present in data" check depends on this ordering.
#'
#' @param x A variable (vector).
#' @param var_name Optional character string. The variable's column name.
#'   Accepted for call-site symmetry with \code{.jst_is_categorical()};
#'   not currently used in this helper's logic.
#' @param data_name Optional character string. The data frame's name.
#'   Accepted for call-site symmetry with \code{.jst_is_categorical()};
#'   not currently used in this helper's logic.
#' @return TRUE if the variable has categorical-like structure,
#'   FALSE otherwise.
#' @keywords internal
.jst_is_discrete_integer <- function(x, var_name = NULL, data_name = NULL) {

  # -- Rule 1: haven_labelled with non-missing value labels ----------------
  # Require at most 6 unique non-NA values present in the data. Variables
  # with 7+ distinct values have enough categories that linear-regression
  # assumptions hold reasonably well (the 6-7 minimum convention for
  # interval-like DVs), so we do not flag them as categorical-like even
  # if they came in with value labels attached.
  if (haven::is.labelled(x)) {
    val_labs <- labelled::val_labels(x)
    if (!is.null(val_labs) && length(val_labs) > 0) {
      if (typeof(x) == "character") {
        # Character-labelled: any labels present make it categorical.
        return(TRUE)
      }
      # Numeric-labelled: require at least one labelled code to be present
      # in the (post-NA-preprocessing) data, AND require <= 6 unique
      # non-NA values overall. The first check prevents a continuous
      # variable with only a "Missing" label from misclassifying as
      # categorical once the missing values have been NA'd out. The
      # second check prevents large-N labelled variables (e.g., Income
      # with 10 broad categories) from being flagged.
      x_num       <- suppressWarnings(as.numeric(x))
      non_na_vals <- x_num[!is.na(x_num)]
      if (length(non_na_vals) > 0 &&
          any(val_labs %in% non_na_vals) &&
          length(unique(non_na_vals)) <= 6) {
        return(TRUE)
      }
      # Fall through to Rule 2 if no labelled codes remain in the data,
      # or if the variable has too many unique values to be flagged.
    }
  }

  # -- Rule 2: whole-number 0-6 range --------------------------------------
  if (is.numeric(x) || haven::is.labelled(x)) {
    x_num   <- suppressWarnings(as.numeric(x))
    x_clean <- x_num[!is.na(x_num)]
    if (length(x_clean) >= 2) {
      unique_vals <- unique(x_clean)
      if (length(unique_vals) >= 2 &&
          all(x_clean == floor(x_clean)) &&
          min(x_clean) >= 0 &&
          max(x_clean) <= 6) {
        return(TRUE)
      }
    }
  }

  FALSE
}


#' Internal helper: classify a variable for descriptive summarization
#'
#' Single source of truth for \code{jdesc()}'s decision about whether a
#' variable can be summarized with descriptive statistics (Min/Max/Mean/SD)
#' and, if so, how it is coerced to numeric. Used by both the ungrouped and
#' the by-group paths so the two cannot drift apart.
#'
#' Summarized: plain numeric, haven-labelled (numeric underlying), logical
#' (as 0/1), factors whose levels are numeric, and character columns whose
#' values are numbers stored as text (a note is attached in that case).
#' Refused: factors with text categories, character columns that are true
#' text, date/time variables (\code{Date}, \code{POSIXct}, \code{POSIXlt},
#' \code{difftime}), and any other type (list, complex, raw).
#'
#' @param x A single variable (vector / data-frame column).
#' @param var_name The variable's name, used to build messages.
#'
#' @return A list with elements \code{summarisable} (logical), \code{num}
#'   (numeric vector ready to summarize, or NULL), \code{note} (an
#'   informational message to emit even though the variable is summarized,
#'   or NULL), and \code{refusal} (the message explaining why the variable
#'   cannot be summarized, or NULL).
#'
#' @keywords internal
.jst_classify_desc_var <- function(x, var_name) {
  no  <- function(msg) list(summarisable = FALSE, num = NULL, note = NULL, refusal = msg)
  yes <- function(num, note = NULL) list(summarisable = TRUE, num = num, note = note, refusal = NULL)

  # Type rules live in the shared detector so jdesc and the analysis type
  # gate cannot drift; this wrapper only maps the kind to jdesc's answer and
  # owns jdesc's refusal wording / numbers-as-text note.
  k <- .jst_var_kind(x)

  switch(k$kind,
    # Numeric-ish kinds: summarize on the coerced numeric.
    numeric        = ,
    labelled       = ,
    logical        = ,
    numeric_factor = yes(k$num),

    # Numbers stored as text: summarize, but flag it.
    numeric_text   = yes(k$num, note = paste0("'", var_name, "' is stored as text but ",
                                  "contains numeric values; summarizing it ",
                                  "numerically.")),

    # Date/time types: not supported here (a dedicated function handles these).
    datetime       = no(paste0("'", var_name, "' is a date/time variable; jdesc() does ",
                               "not summarize dates or times.")),

    # Text factor / text character: refuse and redirect to jfreq().
    text_factor    = no(paste0("'", var_name, "' is a factor with text categories and ",
                               "cannot be summarized with descriptive statistics. Use ",
                               "jfreq() instead for categorical variables.")),
    text_character = no(paste0("'", var_name, "' is a character (text) variable and ",
                               "cannot be summarized with descriptive statistics. Use ",
                               "jfreq() instead for categorical variables.")),

    # complex / raw / list / other: refuse with a generic message. Keyed off
    # typeof(x) (not k$kind) so e.g. a closure column still reports "closure".
    no(paste0("'", var_name, "' is of type ", typeof(x), " and cannot be ",
              "summarized with descriptive statistics."))
  )
}

#' Internal helper: class-safe numeric coercion for haven-input columns
#'
#' Equivalent to \code{as.numeric(x)} for every input type (numeric, factor,
#' Date/POSIXct/difftime, character, and haven_labelled all give the same
#' result, since \code{unclass()} strips only the class attribute), but
#' bypasses vctrs method dispatch. A bare \code{as.numeric()} on a
#' \code{haven_labelled} vector can abort with "Can't convert
#' <haven_labelled> to <double>" in a fresh session where \code{readxl} was
#' attached before haven registered its \code{vec_cast} method (and always
#' aborts on a character-backed haven_labelled). Stripping the class first
#' sidesteps the dispatch entirely. Standardised package-wide at the
#' haven-input coercion sites in jdesc, jfreq, jscreen, jt, jaov, jcrosstab,
#' jcorr, jlm, jlogistic, jalpha, jdummy, and jrecode. (Session 50)
#'
#' @param x A variable / data-frame column.
#' @return A numeric vector.
#' @keywords internal
.jst_as_numeric <- function(x) as.numeric(unclass(x))

#' Internal helper: classify a variable's analysis-relevant type "kind"
#'
#' Single source of truth for the variable-type distinctions the analysis
#' functions and the type gate care about. Returns the kind plus, for the
#' numeric-ish kinds, the coerced numeric vector. Kinds: "numeric",
#' "labelled", "logical", "numeric_factor", "numeric_text" (numbers stored
#' as text), "text_factor", "text_character", "datetime"
#' (Date/POSIXct/POSIXlt/difftime), "complex", "raw", "list", "other".
#' (\code{.jst_classify_desc_var()} delegates to this detector for jdesc, so
#' the variable-type rules live here only and the two cannot drift.)
#'
#' @param x A variable / data-frame column.
#' @return A list with \code{kind} (character) and \code{num} (numeric
#'   vector for numeric-ish kinds, otherwise NULL).
#' @keywords internal
.jst_var_kind <- function(x) {
  if (inherits(x, c("Date", "POSIXct", "POSIXlt", "difftime")))
    return(list(kind = "datetime", num = NULL))
  if (is.complex(x)) return(list(kind = "complex", num = NULL))
  if (is.raw(x))     return(list(kind = "raw",     num = NULL))
  if (haven::is.labelled(x)) {
    # Character-backed haven_labelled (e.g. country codes "US"/"UK" carrying
    # value labels) has no numeric codes to summarize. Route it to the text-
    # categorical branch so jdesc refuses cleanly ("use jfreq()") instead of
    # coercing the character backing to all-NA and emitting "NAs introduced
    # by coercion". Numeric-backed labelled falls through to the numeric-ish
    # "labelled" kind unchanged. (Session 51)
    if (typeof(x) == "character") return(list(kind = "text_character", num = NULL))
    return(list(kind = "labelled", num = .jst_as_numeric(x)))
  }
  if (is.logical(x)) return(list(kind = "logical", num = as.numeric(x)))
  if (is.factor(x)) {
    num <- suppressWarnings(as.numeric(as.character(x)))
    if (all(is.na(num[!is.na(x)]))) return(list(kind = "text_factor", num = NULL))
    return(list(kind = "numeric_factor", num = num))
  }
  if (is.character(x)) {
    num <- suppressWarnings(as.numeric(x))
    if (all(is.na(num[!is.na(x)]))) return(list(kind = "text_character", num = NULL))
    return(list(kind = "numeric_text", num = num))
  }
  if (is.list(x))    return(list(kind = "list",    num = NULL))  # POSIXlt handled above
  if (is.numeric(x)) return(list(kind = "numeric", num = as.numeric(x)))
  list(kind = "other", num = NULL)
}

#' Internal helper: build the analysis type-gate error message
#'
#' @param var_name The offending variable's name.
#' @param kind The kind returned by \code{.jst_var_kind()}.
#' @param fn_label A short noun phrase for the function (e.g. "a t-test").
#' @return Character scalar suitable for \code{stop(call. = FALSE)}.
#' @keywords internal
.jst_analysis_type_error_msg <- function(var_name, kind, fn_label) {
  if (kind == "datetime") {
    return(paste0("'", var_name, "' is a date/time variable and cannot be used in ",
      fn_label, ". Convert it to an elapsed duration first, e.g. ",
      "as.numeric(difftime(end, start, units = \"days\"))."))
  }
  if (kind %in% c("complex", "raw", "list", "other")) {
    return(paste0("'", var_name, "' is of type ", kind,
      " and cannot be used in ", fn_label, "."))
  }
  if (kind == "numeric_text") {
    return(paste0("'", var_name, "' is numbers stored as text. Convert it with ",
      "as.numeric() before using it in ", fn_label, "."))
  }
  paste0("'", var_name, "' is a categorical (text) variable and cannot be used in ",
    fn_label, ", which needs a numeric variable.")
}

#' Internal helper: gate a variable for use in an analysis function
#'
#' Stops with a clean, variable-naming error when the variable's type cannot
#' be used in the calling analysis. Date/time, complex, list, and raw are
#' refused for every role; text (factor or character) and numbers-stored-as-
#' text are additionally refused when a numeric variable is required.
#' Accepted variables pass through; the returned kind carries the coerced
#' numeric for callers that want it.
#'
#' @param x The variable / column.
#' @param var_name The variable's name (for the message).
#' @param requires_numeric TRUE for roles that need a numeric variable
#'   (continuous DV, correlation variable, scale item); FALSE for roles where
#'   a categorical variable is valid (grouping variable, regression predictor,
#'   logistic DV).
#' @param fn_label A short noun phrase for the function (e.g. "a t-test").
#' @return Invisibly, the \code{.jst_var_kind()} result.
#' @keywords internal
.jst_check_analysis_var <- function(x, var_name, requires_numeric = TRUE,
                                    fn_label = "this analysis") {
  k <- .jst_var_kind(x)
  always_refuse <- c("datetime", "complex", "raw", "list", "other")
  num_refuse    <- c("text_factor", "text_character", "numeric_text")
  if (k$kind %in% always_refuse ||
      (requires_numeric && k$kind %in% num_refuse)) {
    stop(.jst_analysis_type_error_msg(var_name, k$kind, fn_label), call. = FALSE)
  }
  invisible(k)
}


#' Internal helper: dichotomy classifier
#'
#' Returns information about whether a variable is a two-value (dichotomous)
#' variable, and if so, what coding it uses. Designed to be the single
#' source of truth across the package for "is this a dichotomy?" questions
#' — used by jlm DV checks, by jlogistic DV validation, and (in the
#' future) by jcorr inclusion decisions for point-biserial correlations.
#'
#' Detects dichotomies in any of these forms:
#' \itemize{
#'   \item Numeric (or haven_labelled numeric) with exactly two unique
#'         non-NA values: classified by coding pattern as "0/1", "1/2",
#'         or "other" (e.g. 5/10, -1/1).
#'   \item Factor with exactly two levels: classified as "factor".
#'   \item Character with exactly two unique non-NA values: classified
#'         as "character".
#'   \item Logical with both TRUE and FALSE present: classified as
#'         "logical".
#' }
#'
#' Returns a list with two named elements so callers can both detect
#' dichotomies and react to specific codings without redoing the work:
#' \itemize{
#'   \item \code{is_dichotomy}: TRUE if the variable has exactly two
#'         non-NA distinct values, FALSE otherwise.
#'   \item \code{coding}: One of "0/1", "1/2", "other", "factor",
#'         "character", "logical" when \code{is_dichotomy} is TRUE;
#'         \code{NA_character_} otherwise.
#' }
#'
#' Why a list rather than two helpers: most callers want both pieces of
#' information at the same time (e.g. jlogistic asks both "is this a
#' dichotomy?" and "what coding?" to decide on its error message). One
#' helper that returns both avoids duplicating detection work and
#' eliminates the risk of two helpers giving inconsistent answers if
#' they're modified independently later.
#'
#' This helper makes no judgement about whether dichotomous treatment
#' is appropriate — that's up to the caller. jlogistic uses it to
#' validate the DV (and stops if not coded 0/1); the new jlm DV check
#' uses it to warn that a different model might have been intended;
#' future jcorr could use it to decide which correlation method to use.
#'
#' @param x A variable (vector).
#' @return A list with elements \code{is_dichotomy} (logical) and
#'   \code{coding} (character or NA).
#' @keywords internal
.jst_is_dichotomy <- function(x) {

  na_result <- list(is_dichotomy = FALSE, coding = NA_character_)

  # -- Logical: TRUE/FALSE -------------------------------------------------
  if (is.logical(x)) {
    vals <- unique(x[!is.na(x)])
    if (length(vals) == 2) return(list(is_dichotomy = TRUE, coding = "logical"))
    return(na_result)
  }

  # -- Factor: two levels --------------------------------------------------
  if (is.factor(x)) {
    if (nlevels(x) == 2) return(list(is_dichotomy = TRUE, coding = "factor"))
    return(na_result)
  }

  # -- Character: two unique non-NA values ---------------------------------
  if (is.character(x)) {
    vals <- unique(x[!is.na(x)])
    if (length(vals) == 2) return(list(is_dichotomy = TRUE, coding = "character"))
    return(na_result)
  }

  # -- Numeric or haven_labelled numeric: classify by coding pattern -------
  if (is.numeric(x) || haven::is.labelled(x)) {
    vals <- suppressWarnings(as.numeric(x))
    vals <- vals[!is.na(vals)]
    unique_vals <- sort(unique(vals))
    if (length(unique_vals) != 2) return(na_result)
    coding <- if (identical(unique_vals, c(0, 1))) {
                "0/1"
              } else if (identical(unique_vals, c(1, 2))) {
                "1/2"
              } else {
                "other"
              }
    return(list(is_dichotomy = TRUE, coding = coding))
  }

  na_result
}


#' Internal helper: count-variable classifier
#'
#' Returns TRUE when a variable's values fit the structural pattern of a
#' small-range count: non-negative whole numbers in the 0-6 range, with
#' no value labels attached, and not a dichotomy (which has its own
#' helper).
#'
#' Used as a *warning trigger* for analyses that assume a continuous DV
#' with at least 6-7 distinct values for reliable inference. The jlm DV
#' check uses it to warn that linear regression's assumptions (normally
#' distributed residuals, constant variance) are usually violated by
#' small-range counts. A future jpoisson()/jnegbin() workflow would be
#' the appropriate response when count regression is implemented; for
#' now the warning explains the limitation.
#'
#' This helper deliberately uses the same range rules as
#' .jst_is_discrete_integer() (min >= 0, max <= 6, all whole numbers).
#' The only structural difference is the "not haven-labelled" rule:
#' counts in this package are typically plain integers, while labelled
#' small-range integers are usually Likert items or category codes
#' rather than counts. Both helpers can return TRUE for the same
#' variable (e.g., an unlabelled small-range count fires both); the
#' calling function decides how to handle that overlap. For example,
#' the jlm DV check examines counts before discrete-integers so that
#' an unlabelled count gets the count-specific warning rather than the
#' more general categorical-like one.
#'
#' Detection criteria, all required:
#' \itemize{
#'   \item is.numeric and not haven_labelled
#'   \item not a dichotomy (.jst_is_dichotomy() handles the binary case)
#'   \item all values are whole numbers (integer-valued)
#'   \item minimum value >= 0
#'   \item maximum value <= 6
#'   \item at least 2 non-NA values
#' }
#'
#' @param x A variable (vector).
#' @return TRUE if the variable looks like a small-range count, FALSE
#'   otherwise.
#' @keywords internal
.jst_is_count <- function(x) {

  if (haven::is.labelled(x))   return(FALSE)
  if (!is.numeric(x))          return(FALSE)
  if (.jst_is_dichotomy(x)$is_dichotomy) return(FALSE)

  vals <- x[!is.na(x)]
  if (length(vals) < 2)        return(FALSE)
  if (!all(vals == floor(vals))) return(FALSE)
  if (min(vals) < 0)           return(FALSE)
  if (max(vals) > 6)           return(FALSE)

  TRUE
}


#' Internal helper: jstats analysis-role class for display
#'
#' Single display-layer resolver that reports how jstats treats a variable,
#' for the jscreen() "Variable Types" table. It does NOT define any new
#' classification rules: it composes the existing single-source helpers
#' (\code{.jst_var_kind()}, \code{.jst_is_dichotomy()},
#' \code{.jst_is_discrete_integer()}) so the screening report cannot drift
#' from how analyses and the outlier-skip actually treat a variable. The
#' same resolver decides jscreen's outlier-screening (screened iff
#' \code{class == "Numeric"}), so the Class column and the Outliers column
#' can never disagree.
#'
#' Class (the analysis role): one of "Numeric", "Categorical",
#' "Numbers-as-text", "Date-time", "Unsupported". Storage facts (labelled
#' vs plain, character backing) live in jscreen's separate "Base R Type"
#' column, never here — a base-R numeric can resolve to Numeric, or to
#' Categorical (dichotomy), or to Categorical (N-category), depending only
#' on the analysis-relevant structure.
#'
#' Sub-class (for Categorical only; "" otherwise): "dichotomy" for a two-
#' value variable, else "N-category" (e.g. "4-category") from the count of
#' distinct non-missing values. The boundary between Numeric and Categorical
#' is exactly the package's existing rule: a dichotomy (any coding), a
#' factor / logical / character, a haven-labelled variable with <= 6
#' categories, or a whole-number 0-6 numeric is Categorical; everything else
#' numeric-ish (continuous numeric, or labelled with 7+ categories) is
#' Numeric. (A future jcount()/jdummy()-style registry would be read here.)
#'
#' @param x A variable / data-frame column.
#' @return A list with \code{class} (character) and \code{subclass}
#'   (character, "" when none).
#' @keywords internal
.jst_jstats_class <- function(x) {
  k <- .jst_var_kind(x)

  # Non-analyzable / distinctly-handled kinds first.
  if (k$kind == "datetime")     return(list(class = "Date-time",       subclass = ""))
  if (k$kind == "numeric_text") return(list(class = "Numbers-as-text", subclass = ""))
  if (k$kind %in% c("complex", "raw", "list", "other"))
    return(list(class = "Unsupported", subclass = ""))

  # Numeric-ish (numeric / labelled / logical / numeric_factor) or text
  # categorical (text_factor / text_character). Decide Numeric vs Categorical
  # with the same helpers the analysis gate and the outlier-skip use.
  dich   <- .jst_is_dichotomy(x)
  is_cat <- k$kind %in% c("text_factor", "text_character") ||
            is.factor(x) || is.logical(x) ||
            dich$is_dichotomy ||
            .jst_is_discrete_integer(x)

  if (!is_cat) return(list(class = "Numeric", subclass = ""))

  if (dich$is_dichotomy) return(list(class = "Categorical", subclass = "dichotomy"))
  n_unique <- length(unique(x[!is.na(x)]))
  list(class = "Categorical", subclass = paste0(n_unique, "-category"))
}



#' Internal helper: parse a recoding-map string into a structured rule list
#'
#' Parses a map string of the form \code{"1=1; 2,3=2; 4,5=3; else=copy"}
#' (used by \code{jrecode()}) into a list of mapping rules plus an
#' else-action. Each rule's left-hand side may be a single value or a
#' comma-separated list of values; an explicit \code{else=...} clause
#' sets the fallback action.
#'
#' The right-hand side of each rule may be a numeric value, one of the
#' system-NA aliases (\code{System}, \code{NA}, or \code{SYSMIS}, case-
#' insensitive), or a Stata-style missing-value token (\code{.a} through
#' \code{.z}). Tagged-NA tokens are recorded in the parsed structure
#' but not validated against the active convention here; the caller
#' (\code{jrecode()}) performs the convention check after parsing.
#'
#' Errors with a clear message if the string is malformed.
#'
#' @param map_str Character string giving the recoding map, e.g.
#'   \code{"1=1; 2=0; else=NA"} or \code{"1=1; 2=0; else=.a"}.
#'
#' @return Invisibly, a list with components:
#'   \describe{
#'     \item{mappings}{List of lists; each inner list has \code{old_vals}
#'       (numeric vector), \code{new_val} (single numeric; \code{NA_real_}
#'       for system-NA and tagged-NA rules), and \code{tagged} (NULL for
#'       numeric or system-NA rules; a single lowercase letter character
#'       for tagged-NA rules).}
#'     \item{else_action}{Character: \code{"na"}, \code{"copy"}, or
#'       \code{"tagged"}.}
#'     \item{else_tag}{NULL when \code{else_action} is \code{"na"} or
#'       \code{"copy"}; a single lowercase letter character when
#'       \code{else_action} is \code{"tagged"}.}
#'     \item{else_explicit}{Logical: \code{TRUE} if the user wrote an
#'       explicit \code{else=...} clause, \code{FALSE} if defaulted.}
#'   }
#'
#' @keywords internal
.jst_parse_map <- function(map_str) {

  rules <- trimws(strsplit(map_str, ";")[[1]])
  rules <- rules[nchar(rules) > 0]

  if (length(rules) == 0) {
    stop("The map argument is empty. Provide at least one rule, e.g. map = \"1=1; 2=0\".", call. = FALSE)
  }

  result <- list(mappings = list(), else_action = "na",
                 else_tag = NULL, else_explicit = FALSE)

  # Helper: parse an RHS token. Returns list(new_val = numeric,
  # tagged = NULL | letter) or NULL if the token is not recognized
  # (caller then falls through to the existing numeric-error path).
  parse_rhs_token <- function(rhs_str, rule_str) {
    rhs_lower <- tolower(trimws(rhs_str))

    # System-NA aliases.
    if (rhs_lower %in% c("na", "sysmis", "system")) {
      return(list(new_val = NA_real_, tagged = NULL))
    }

    # Stata-style missing-value token: .a through .z.
    if (grepl("^\\.[a-z]$", rhs_lower)) {
      return(list(new_val = NA_real_,
                  tagged = substr(rhs_lower, 2L, 2L)))
    }

    # Malformed tagged-NA shapes: helpful error.
    if (grepl("^\\.", rhs_lower) || grepl("^na\\(", rhs_lower)) {
      stop(paste0(
        "Invalid new value '", rhs_str, "' in map rule '", rule_str, "'. ",
        "Stata-style missing-value tokens must be '.a' through '.z' ",
        "(a single lowercase letter after the period). The NA(a) ",
        "longhand is not supported in the map argument."
      ), call. = FALSE)
    }

    NULL
  }

  for (rule in rules) {

    if (!grepl("=", rule)) {
      stop(paste0(
        "Invalid rule '", rule, "' in map argument: each rule must contain '=', ",
        "e.g. '1=0' or '2,3=1'."
      ), call. = FALSE)
    }

    eq_pos <- regexpr("=", rule)[1]
    lhs    <- trimws(substr(rule, 1, eq_pos - 1))
    rhs    <- trimws(substr(rule, eq_pos + 1, nchar(rule)))

    # else rule
    if (tolower(lhs) == "else") {
      rhs_lower <- tolower(rhs)
      if (rhs_lower %in% c("na", "sysmis", "system")) {
        result$else_action   <- "na"
        result$else_tag      <- NULL
        result$else_explicit <- TRUE
      } else if (rhs_lower == "copy") {
        result$else_action   <- "copy"
        result$else_tag      <- NULL
        result$else_explicit <- TRUE
      } else if (grepl("^\\.[a-z]$", rhs_lower)) {
        result$else_action   <- "tagged"
        result$else_tag      <- substr(rhs_lower, 2L, 2L)
        result$else_explicit <- TRUE
      } else if (grepl("^\\.", rhs_lower) || grepl("^na\\(", rhs_lower)) {
        stop(paste0(
          "Invalid else action '", rhs, "' in map argument. ",
          "Stata-style missing-value tokens must be '.a' through '.z' ",
          "(a single lowercase letter after the period). The NA(a) ",
          "longhand is not supported in the map argument."
        ), call. = FALSE)
      } else {
        stop(paste0(
          "Invalid else action '", rhs, "' in map argument. Use ",
          "'else=NA', 'else=copy', or a Stata-style missing-value token ",
          "such as 'else=.a' (Stata convention only)."
        ), call. = FALSE)
      }
      next
    }

    # old values (may be comma-separated)
    old_strs <- trimws(strsplit(lhs, ",")[[1]])
    old_vals <- suppressWarnings(as.numeric(old_strs))

    if (any(is.na(old_vals))) {
      stop(paste0(
        "Invalid old value(s) '", lhs, "' in map rule '", rule, "'. ",
        "Old values must be numeric."
      ), call. = FALSE)
    }

    # new value
    rhs_parsed <- parse_rhs_token(rhs, rule)

    if (!is.null(rhs_parsed)) {
      new_val <- rhs_parsed$new_val
      tagged  <- rhs_parsed$tagged
    } else {
      tagged  <- NULL
      new_val <- suppressWarnings(as.numeric(rhs))
      if (is.na(new_val)) {
        # Detect commas used instead of semicolons between rules
        if (grepl(",", rhs) && grepl("=", rhs)) {
          stop(paste0(
            "It looks like commas were used to separate rules in the map string. ",
            "Use semicolons instead, e.g. map = \"1=5; 2=4; 3=3\"."
          ), call. = FALSE)
        }
        stop(paste0(
          "Invalid new value '", rhs, "' in map rule '", rule, "'. ",
          "New values must be numeric, a system-NA alias (NA, System, ",
          "or SYSMIS), or a Stata-style missing-value token (.a through .z)."
        ), call. = FALSE)
      }
    }

    result$mappings[[length(result$mappings) + 1]] <- list(
      old_vals = old_vals,
      new_val  = new_val,
      tagged   = tagged
    )
  }

  if (length(result$mappings) == 0) {
    stop("The map argument contains no valid recode rules (only an else clause was found).", call. = FALSE)
  }

  return(invisible(result))
}


#' Internal helper: parse a label-spec string into a named numeric vector
#'
#' Parses a labels string of the form
#' \code{"1=Young; 2=Middle Aged; 3=Older"} into a named numeric
#' vector formatted for use with \code{haven_labelled} variables (names
#' = label text, values = numeric codes). Splits on the first equals
#' sign in each rule, so label text may itself contain equals signs.
#'
#' The left-hand side of each rule may be a numeric value or a Stata-
#' style Stata-style missing-value token (\code{.a} through \code{.z}). Tagged-NA
#' entries are stored as \code{haven::tagged_na(<letter>)} values in
#' the returned vector; callers can detect them via
#' \code{haven::na_tag()}.
#'
#' @param labels_str Character string of the form
#'   \code{"value1=label1; value2=label2; ..."}.
#'
#' @return Invisibly, a named numeric vector. Names are label strings;
#'   values are numeric codes, or Stata-style missing values for tagged entries.
#'
#' @keywords internal
.jst_parse_labels <- function(labels_str) {

  rules <- trimws(strsplit(labels_str, ";")[[1]])
  rules <- rules[nchar(rules) > 0]

  if (length(rules) == 0) {
    stop("The labels argument is empty. Provide at least one label, e.g. labels = \"1=Male; 0=Female\".", call. = FALSE)
  }

  result <- c()

  for (rule in rules) {

    if (!grepl("=", rule)) {
      stop(paste0(
        "Invalid label rule '", rule, "': each rule must contain '=', ",
        "e.g. '1=Male'."
      ), call. = FALSE)
    }

    eq_pos    <- regexpr("=", rule)[1]
    val_str   <- trimws(substr(rule, 1, eq_pos - 1))
    label_str <- trimws(substr(rule, eq_pos + 1, nchar(rule)))

    val_lower <- tolower(val_str)

    if (grepl("^\\.[a-z]$", val_lower)) {
      # Stata-style missing-value token: .a through .z.
      val <- haven::tagged_na(substr(val_lower, 2L, 2L))
    } else if (grepl("^\\.", val_lower) || grepl("^na\\(", val_lower)) {
      stop(paste0(
        "Invalid value '", val_str, "' in label rule '", rule, "'. ",
        "Stata-style missing-value tokens must be '.a' through '.z' ",
        "(a single lowercase letter after the period). The NA(a) ",
        "longhand is not supported in the labels argument."
      ), call. = FALSE)
    } else {
      val <- suppressWarnings(as.numeric(val_str))
      if (is.na(val)) {
        stop(paste0(
          "Invalid value '", val_str, "' in label rule '", rule, "'. ",
          "The left side of each label rule must be numeric or a ",
          "Stata-style missing-value token (.a through .z)."
        ), call. = FALSE)
      }
    }

    if (nchar(label_str) == 0) {
      stop(paste0(
        "Empty label text in rule '", rule, "'. ",
        "Provide a label name after the equals sign."
      ), call. = FALSE)
    }

    entry        <- val
    names(entry) <- label_str
    result <- c(result, entry)
  }

  return(invisible(result))
}


# =============================================================================
#  USER-FACING SETUP
# =============================================================================

# -- juse ---------------------------------------------------------------------

#' Set or display the default data frame for JeffsStatTools functions
#'
#' @description
#' \code{juse()} sets a default data frame that will be used automatically
#' by all JeffsStatTools functions when the \code{data} argument is omitted.
#' This reduces typing and makes interactive use more convenient.
#'
#' The function stores the \emph{name} of the data frame, not a copy of
#' the data. This means any changes you make to the data frame (adding
#' columns, recoding variables, etc.) are automatically reflected in
#' subsequent function calls.
#'
#' @param data A data frame (unquoted). If omitted, prints the current
#'   default. Use \code{juse(NULL)} to clear the default.
#'
#' @return Invisibly returns \code{NULL}. Called for its side effect of
#'   setting, displaying, or clearing the default data frame.
#'
#' @note \code{juse()} stores the \emph{name} of the data frame, not a copy
#'   of the data. This means any changes you make to the data frame (adding
#'   columns, recoding variables, etc.) are automatically reflected in
#'   subsequent function calls. This differs from base R's \code{attach()},
#'   which creates a snapshot that can become stale after modifications.
#'   \code{juse()} is the recommended approach for this package.
#'
#' @examples
#' \donttest{
#' juse(mtcars)           # Set mtcars as the default
#' juse()                 # Display current default
#' jdesc(mpg, hp)         # Uses mtcars automatically
#' juse(NULL)             # Clear the default
#' }
#'
#' @seealso \code{\link{JeffsStatTools}} for the package overview,
#'   workflow conventions, and complete function listing.
#'
#' @export
juse <- function(data) {

  if (missing(data)) {
    # juse() with no arguments — print current default
    current <- getOption(".jst_default_data", default = NULL)
    if (is.null(current)) {
      message("No default data frame set. Use juse(DataFrameName) to set one.")
    } else {
      message("Current default data frame: ", current)
    }
    return(invisible(NULL))
  }

  # juse(NULL) — clear the default
  if (is.null(data)) {
    options(.jst_default_data = NULL)
    message("Default data frame cleared.")
    return(invisible(NULL))
  }

  data_name <- deparse(substitute(data))

  # Check it exists and is a data frame
  calling_env <- parent.frame()
  if (!exists(data_name, envir = calling_env)) {
    stop(paste0(data_name, " not found."), call. = FALSE)
  }
  if (!is.data.frame(get(data_name, envir = calling_env))) {
    stop(paste0(data_name, " is not a data frame."), call. = FALSE)
  }

  options(.jst_default_data = data_name)
  message("Default data frame set to: ", data_name)
  invisible(NULL)
}


# -- jsubset ------------------------------------------------------------------

#' Set, activate, deactivate, or clear a per-dataset case-selection expression
#'
#' @description
#' \code{jsubset()} sets a persistent case-selection expression that is
#' applied automatically by JeffsStatTools analysis functions when the
#' default data frame (set by \code{juse()}) is in use. This is analogous
#' to the SPSS FILTER command.
#'
#' The expression is stored per dataset, so switching \code{juse()} between
#' datasets preserves each dataset's setting independently.
#'
#' The expression applies whenever the matching dataset is used, regardless
#' of whether it was supplied via \code{juse()} or specified explicitly in
#' a function call. To bypass it temporarily without losing it, use
#' \code{jsubset(off)} before the analysis and \code{jsubset(on)} afterward.
#' This matches the SPSS FILTER / USE ALL convention.
#'
#' Expressions use standard R logical operators: \code{==}, \code{!=},
#' \code{<}, \code{<=}, \code{>}, \code{>=}, \code{&} (AND), \code{|} (OR),
#' \code{!} (NOT), \code{xor()} (XOR), and \code{\%in\%}. Using \code{=} for
#' equality or the SPSS-style keywords \code{AND}/\code{OR}/\code{NOT} will
#' produce a helpful error suggesting the correct R syntax.
#'
#' @param data Optional data frame. If supplied, the expression is stored
#'   on that dataset specifically. If omitted, the dataset set by
#'   \code{juse()} is used.
#' @param expr A logical expression (e.g. \code{Age < 40 & Gender == 1}),
#'   or one of the following special values:
#'   \describe{
#'     \item{\code{off}}{Deactivate the setting but remember the expression.}
#'     \item{\code{on}}{Reactivate a previously deactivated setting.}
#'     \item{\code{NULL}}{Clear the setting entirely (forget the expression).}
#'   }
#'   If \code{expr} and \code{data} are both omitted, prints the current
#'   jsubset status.
#'
#' @return Invisibly returns \code{NULL}. Called for its side effect.
#'
#' @examples
#' \donttest{
#' juse(mtcars)
#' jsubset(cyl == 4)             # Set using juse default
#' jsubset(mtcars, cyl == 4)     # Explicit dataset
#' jsubset(cyl == 4 & mpg > 20)  # Compound condition
#' jsubset(off)                  # Deactivate
#' jsubset(on)                   # Reactivate
#' jsubset()                     # Check status
#' jsubset(NULL)                 # Clear entirely
#' }
#'
#' @seealso \code{\link{JeffsStatTools}} for the package overview,
#'   workflow conventions, and complete function listing.
#'
#' @export
jsubset <- function(data, expr) {

  # -- No arguments: print session-wide status ------------------------------
  # Session-wide to match jsubset(NULL)'s scope. Collapse rule: 0 or 1 frame
  # renders on a single line; 2+ frames render a header line plus one
  # indented line per frame, with the juse() default marked.
  if (missing(data) && missing(expr)) {
    reg <- getOption(".jst_filter", default = list())
    reg <- reg[!vapply(reg, is.null, logical(1))]
    if (length(reg) == 0L) {
      message("No jsubset settings in this session.")
      return(invisible(NULL))
    }
    default_name <- getOption(".jst_default_data", default = NULL)
    dnames <- names(reg)
    if (length(reg) == 1L) {
      fs <- reg[[1L]]
      if (isTRUE(fs$active)) {
        message("jsubset active for ", dnames[1L], ": ", fs$expr_str)
      } else {
        message("jsubset set but inactive for ", dnames[1L], ": ", fs$expr_str)
      }
      return(invisible(NULL))
    }
    payloads <- vapply(reg, function(fs) fs$expr_str, character(1))
    active   <- vapply(reg, function(fs) isTRUE(fs$active), logical(1))
    .jst_render_status_overview("jsubset", dnames, payloads, active,
                                default_name)
    return(invisible(NULL))
  }

  # -- Capture both argument expressions BEFORE any evaluation --------------
  raw_data <- if (!missing(data)) substitute(data) else NULL
  raw_expr <- if (!missing(expr)) substitute(expr) else NULL

  # -- jsubset(NULL) — true global clear across all data frames -------------
  # Mirrors jdummy(NULL) semantics. Ignores the juse default; always
  # clears every per-data-frame jsubset setting. The condition
  # "data was supplied AND substituted expression is NULL" detects the
  # literal jsubset(NULL) call (cf. missing(data), which is FALSE here).
  if (!missing(data) && is.null(raw_data)) {
    all_filters <- getOption(".jst_filter", default = list())
    if (length(all_filters) == 0) {
      message("No jsubset settings to clear.")
      return(invisible(NULL))
    }
    dnames <- names(all_filters)
    hads <- vapply(seq_along(all_filters), function(i) {
      fs <- all_filters[[i]]
      if (is.null(fs)) "no jsubset set" else paste0("had: ", fs$expr_str)
    }, character(1))
    options(.jst_filter = NULL)
    .jst_render_clear("jsubset", dnames, hads)
    return(invisible(NULL))
  }

  # -- jsubset(off) / jsubset(on) — default-scoped --------------------------
  # Symbol checks happen on raw_data BEFORE the helper, since `off` and
  # `on` aren't real R objects and would fail evaluation.
  if (!is.null(raw_data) && is.symbol(raw_data) && missing(expr)) {
    sym_name <- tolower(as.character(raw_data))
    default_name <- getOption(".jst_default_data", default = NULL)
    if (sym_name == "off") {
      if (is.null(default_name)) {
        message("No default data frame set.")
        return(invisible(NULL))
      }
      fs <- .jst_get_filter(default_name)
      if (is.null(fs)) {
        message("No jsubset set for ", default_name, ". Nothing to deactivate.")
      } else {
        fs$active <- FALSE
        .jst_set_filter(default_name, fs)
        message("jsubset deactivated for ", default_name, ".")
      }
      return(invisible(NULL))
    }
    if (sym_name == "on") {
      if (is.null(default_name)) {
        message("No default data frame set.")
        return(invisible(NULL))
      }
      fs <- .jst_get_filter(default_name)
      if (is.null(fs)) {
        message("No jsubset set for ", default_name,
                ". Use jsubset(expression) to set one.")
      } else {
        fs$active <- TRUE
        .jst_set_filter(default_name, fs)
        message("jsubset reactivated for ", default_name, ": ", fs$expr_str)
      }
      return(invisible(NULL))
    }
  }

  # -- Resolve which arg is the data and which is the expression ------------
  # Uses the standard helper. For jsubset, the helper distinguishes:
  #   explicit            : raw_data is a data frame  -> raw_expr is the expr
  #   default             : missing(data)             -> raw_expr is the expr
  #   symbol_with_default : raw_data is the expr      -> juse default + raw_data
  arg1 <- .jst_resolve_first_arg(
    data_sub      = raw_data,
    data_missing  = missing(data),
    fn_name       = "jsubset",
    envir         = parent.frame(),
    accept_vector = FALSE
  )

  target_name <- arg1$name

  if (arg1$mode == "explicit") {
    # jsubset(SampleData, <expr>) — explicit data frame + expression slot
    if (missing(expr)) {
      stop("jsubset(", target_name, ", ...) requires a logical expression. ",
           "Example: jsubset(", target_name, ", Age < 40)", call. = FALSE)
    }
    filter_raw <- raw_expr
  } else if (arg1$mode == "default") {
    # jsubset(, <expr>) — leading comma + juse default
    if (is.null(raw_expr)) {
      stop("jsubset(): no logical expression supplied. ",
           "Example: jsubset(Age < 40)", call. = FALSE)
    }
    filter_raw <- raw_expr
  } else {
    # symbol_with_default — jsubset(<expr>) bare-expression form
    filter_raw <- arg1$first_arg_sub
  }

  # -- Detect common syntax mistakes before trying to evaluate --------------
  expr_str_for_check <- deparse(filter_raw, width.cutoff = 500)
  .jst_check_filter_syntax(filter_raw, expr_str_for_check)

  # -- Set and activate the expression --------------------------------------
  expr_str <- deparse(filter_raw, width.cutoff = 500)
  prior <- .jst_get_filter(target_name)
  .jst_set_filter(target_name, list(
    expr     = filter_raw,
    expr_str = expr_str,
    active   = TRUE
  ))
  if (!is.null(prior) && !identical(prior$expr_str, expr_str)) {
    message("jsubset replaced for ", target_name, ": ", expr_str,
            " (was: ", prior$expr_str, ")")
  } else {
    message("jsubset activated for ", target_name, ": ", expr_str)
  }
  invisible(NULL)
}


# -- jfilter (deprecation alias) ----------------------------------------------

#' Deprecated alias for \code{jsubset()}
#'
#' @description
#' \code{jfilter()} was renamed to \code{\link{jsubset}()} to align with
#' base R's \code{subset =} argument and the per-call \code{subset =}
#' argument used by JeffsStatTools analysis functions. \code{jfilter()}
#' continues to work as a thin alias that forwards every call directly
#' to \code{jsubset()}; the alias issues an \code{\link{.Deprecated}}
#' message on each call and will be removed in a future release.
#'
#' @param data See \code{\link{jsubset}()}.
#' @param expr See \code{\link{jsubset}()}.
#'
#' @return Invisibly returns \code{NULL}. Called for its side effect.
#'
#' @seealso \code{\link{jsubset}}
#'
#' @keywords internal
#' @export
jfilter <- function(data, expr) {
  .Deprecated("jsubset",
              msg = "jfilter() has been renamed to jsubset(). Please use jsubset() in new code.")
  # Forward the captured call to jsubset() so substitute()-based argument
  # handling sees the original unevaluated arguments (off / on / NULL /
  # bare-symbol / explicit-data forms all need to reach jsubset intact).
  cl    <- sys.call()
  cl[[1L]] <- as.name("jsubset")
  eval.parent(cl)
}


# -- .jst_check_filter_syntax -------------------------------------------------

#' Internal helper: detect common SPSS-style syntax mistakes in jsubset
#' expressions and provide guidance toward standard R operators.
#'
#' Catches:
#' - \code{=} used where \code{==} was meant (for equality comparison)
#' - \code{AND} / \code{OR} / \code{NOT} / \code{XOR} used as identifiers
#'   where \code{&} / \code{|} / \code{!} / \code{xor()} were meant
#'
#' @param raw_expr The unevaluated expression (a language object).
#' @param expr_str The deparsed expression string (for display in errors).
#' @keywords internal
.jst_check_filter_syntax <- function(raw_expr, expr_str) {

  # Catch a bare symbol used as the entire subset expression, e.g.
  # jsubset(Gender). The user almost certainly meant a comparison
  # like Gender == 1. Without this check, the symbol gets stored as
  # the expression and later attempts to apply it produce cryptic
  # errors from haven_labelled internals when subset_data is
  # non-logical.
  if (is.symbol(raw_expr)) {
    sym <- as.character(raw_expr)
    if (!sym %in% c("TRUE", "FALSE", "T", "F")) {
      stop(
        "Subset expression `", sym, "` is just a variable name and ",
        "cannot be used as a subset expression on its own. A subset ",
        "expression must compare a variable to a value (or evaluate to ",
        "TRUE/FALSE for each row).\n",
        "  Examples:\n",
        "    jsubset(", sym, " == 1)         # keep rows where ", sym, " is 1\n",
        "    jsubset(!is.na(", sym, "))       # keep rows where ", sym, " is not missing\n",
        "  You wrote: jsubset(", sym, ")",
        call. = FALSE
      )
    }
  }

  # Collect all symbols referenced in the expression
  all_names <- all.names(raw_expr, unique = FALSE)

  # Check for SPSS-style logical keywords used as identifiers
  spss_kw <- c("AND", "OR", "NOT", "XOR")
  hit <- intersect(toupper(all_names), spss_kw)
  if (length(hit) > 0) {
    kw <- hit[1]
    replacement <- switch(kw,
                          AND = "`&` (single ampersand)",
                          OR  = "`|` (pipe symbol)",
                          NOT = "`!` (exclamation mark)",
                          XOR = "`xor()` (a function call)")
    stop(
      "It looks like you used `", kw, "` in your subset expression, ",
      "which R treats as a variable name, not a logical operator.\n",
      "  In R, use ", replacement, " instead.\n",
      "  Examples:\n",
      "    jsubset(Age < 40 & Gender == 1)     # AND\n",
      "    jsubset(Age < 40 | Age > 60)        # OR\n",
      "    jsubset(!is.na(Age))                # NOT\n",
      "  You wrote: ", expr_str,
      call. = FALSE
    )
  }

  # Check for assignment (`=`) used where equality (`==`) was meant.
  # R parses `Gender = 1` inside a function call as a named argument, but
  # when deparsed it produces a `Gender = 1` string. Use the unevaluated
  # expression's deparsed form for a text check — look for ` = ` that is
  # not ` == ` and not a call argument like `method =`.
  # Most robust: check if the deparsed expression contains a lone `=` sign
  # that isn't part of `==`, `<=`, `>=`, or `!=`.
  if (grepl("(?<![=<>!])=(?!=)", expr_str, perl = TRUE)) {
    stop(
      "It looks like you used `=` in your subset expression. In R, `=` is ",
      "assignment; equality comparison uses `==` (double equals).\n",
      "  Example: jsubset(Gender == 1)\n",
      "  You wrote: ", expr_str,
      call. = FALSE
    )
  }

  invisible(NULL)
}


# -- jcomplete ----------------------------------------------------------------

#' Set a listwise complete-case filter for matching N across analyses
#'
#' @description
#' \code{jcomplete()} registers a set of variables and activates a listwise
#' deletion filter that excludes any case with a missing value on any of
#' the registered variables. This ensures that all subsequent analyses use
#' the same set of complete cases, which is essential when preliminary
#' analyses need to match the N of a final regression model.
#'
#' The setting is stored per dataset, so switching \code{juse()} between
#' datasets preserves each dataset's setting independently.
#'
#' The jcomplete filter applies whenever the matching dataset is used,
#' regardless of whether it was supplied via \code{juse()} or specified
#' explicitly in a function call. To bypass temporarily without losing
#' the setting, use \code{jcomplete(off)} before the analysis and
#' \code{jcomplete(on)} afterward. This matches the SPSS USE ALL /
#' FILTER convention.
#'
#' @param data A data frame. If omitted, uses the default set by
#'   \code{juse()}. Pass \code{NULL} to clear the filter entirely.
#'   Pass the bare word \code{off} to deactivate, or \code{on} to
#'   reactivate. Call with no arguments to check the current status.
#' @param ... Unquoted variable names to include in the listwise check.
#'
#' @return Invisibly returns \code{NULL}. Called for its side effect.
#'
#' @examples
#' \donttest{
#' juse(mtcars)
#' jcomplete(mpg, hp, wt, am)
#' jdesc(mpg)                     # Uses only complete cases on those 4 vars
#' jcomplete(off)                 # Deactivate
#' jcomplete(on)                  # Reactivate
#' jcomplete()                    # Check status
#' jcomplete(NULL)                # Clear entirely
#' }
#'
#' @seealso \code{\link{JeffsStatTools}} for the package overview,
#'   workflow conventions, and complete function listing.
#'
#' @export
jcomplete <- function(data, ...) {

  default_name <- getOption(".jst_default_data", default = NULL)

  # -- No arguments: print session-wide status ------------------------------
  # Session-wide to match jcomplete(NULL). Collapse rule: 0 or 1 frame on a
  # single line (the single active frame appends a live complete-case count
  # when the data frame is reachable from the caller); 2+ frames render a
  # header plus one indented line per frame, with the juse() default marked.
  if (missing(data) && ...length() == 0) {
    reg <- getOption(".jst_complete", default = list())
    reg <- reg[!vapply(reg, is.null, logical(1))]
    if (length(reg) == 0L) {
      message("No jcomplete settings in this session.")
      return(invisible(NULL))
    }
    dnames <- names(reg)
    if (length(reg) == 1L) {
      cs        <- reg[[1L]]
      vars_str  <- paste(cs$vars, collapse = ", ")
      count_str <- ""
      calling_env <- parent.frame()
      if (exists(dnames[1L], envir = calling_env)) {
        df         <- get(dnames[1L], envir = calling_env)
        valid_vars <- cs$vars[cs$vars %in% names(df)]
        if (length(valid_vars) > 0L) {
          n_total    <- nrow(df)
          # Mask SPSS-form UDMs first so the live count matches the analysis
          # pipeline (Cross-cutting 5); see the setup-summary note below.
          masked     <- .jst_apply_declared_udms_as_na(
            df[, valid_vars, drop = FALSE])$data
          n_complete <- sum(stats::complete.cases(masked[, valid_vars, drop = FALSE]))
          count_str  <- paste0(" (", n_complete, " of ", n_total,
                               " complete cases)")
        }
      }
      if (isTRUE(cs$active)) {
        message("jcomplete active for ", dnames[1L], ": ", vars_str, count_str)
      } else {
        message("jcomplete set but inactive for ", dnames[1L], ": ", vars_str)
      }
      return(invisible(NULL))
    }
    payloads <- vapply(reg, function(cs) paste(cs$vars, collapse = ", "),
                       character(1))
    active   <- vapply(reg, function(cs) isTRUE(cs$active), logical(1))
    .jst_render_status_overview("jcomplete", dnames, payloads, active,
                                default_name)
    return(invisible(NULL))
  }

  # -- Capture substitute BEFORE any evaluation ------------------------------
  # Must happen before is.null(data) or any other use of data, otherwise
  # bare symbols like off/on cause "object not found" errors.
  raw_data <- if (!missing(data)) substitute(data) else NULL

  # -- jcomplete(NULL) — true global clear across all data frames -----------
  # Mirrors jdummy(NULL) and jsubset(NULL) semantics. Ignores juse default;
  # always clears every per-data-frame jcomplete setting. The condition
  # "data was supplied AND substituted expression is NULL" detects the
  # literal jcomplete(NULL) call.
  if (!missing(data) && is.null(raw_data)) {
    all_complete <- getOption(".jst_complete", default = list())
    if (length(all_complete) == 0) {
      message("No jcomplete settings to clear.")
      return(invisible(NULL))
    }
    dnames <- names(all_complete)
    hads <- vapply(seq_along(all_complete), function(i) {
      cs <- all_complete[[i]]
      if (is.null(cs)) "no settings"
      else paste0("had: ", paste(cs$vars, collapse = ", "))
    }, character(1))
    options(.jst_complete = NULL)
    .jst_render_clear("jcomplete", dnames, hads)
    return(invisible(NULL))
  }

  # -- jcomplete(off) / jcomplete(on) — default-scoped ----------------------
  # Symbol checks happen on raw_data BEFORE the helper, since `off` and
  # `on` aren't real R objects and would fail evaluation. The
  # ...length() == 0 guard avoids interpreting a variable named "off"
  # accompanied by other variables as the off command.
  if (!is.null(raw_data) && is.symbol(raw_data) && ...length() == 0) {
    sym_name <- tolower(as.character(raw_data))
    if (sym_name == "off") {
      if (is.null(default_name)) {
        message("No default data frame set.")
        return(invisible(NULL))
      }
      cs <- .jst_get_complete(default_name)
      if (is.null(cs)) {
        message("No jcomplete filter set for ", default_name, ".")
      } else {
        cs$active <- FALSE
        .jst_set_complete(default_name, cs)
        message("jcomplete deactivated for ", default_name, ".")
      }
      return(invisible(NULL))
    }
    if (sym_name == "on") {
      if (is.null(default_name)) {
        message("No default data frame set.")
        return(invisible(NULL))
      }
      cs <- .jst_get_complete(default_name)
      if (is.null(cs)) {
        message("No jcomplete filter set for ", default_name,
                ". Use jcomplete(var1, var2, ...) to set one.")
      } else {
        cs$active <- TRUE
        .jst_set_complete(default_name, cs)
        message("jcomplete reactivated for ", default_name, ": ",
                paste(cs$vars, collapse = ", "))
      }
      return(invisible(NULL))
    }
  }

  # -- Resolve the first argument via the standard helper -------------------
  # Three modes possible at this point:
  #   explicit            : jcomplete(SampleData, v1, v2)  - data is a frame
  #   default             : jcomplete(, v1, v2)            - leading-comma form
  #   symbol_with_default : jcomplete(v1, v2, v3)          - bare-symbol form
  arg1 <- .jst_resolve_first_arg(
    data_sub      = raw_data,
    data_missing  = missing(data),
    fn_name       = "jcomplete",
    envir         = parent.frame(),
    accept_vector = FALSE
  )

  data              <- arg1$data
  .jst_data_name    <- arg1$name
  .jst_default_used <- arg1$mode %in% c("default", "symbol_with_default")

  variables <- rlang::enquos(...)

  # Bare-symbol form: prepend the captured first symbol to the variables list
  if (arg1$mode == "symbol_with_default") {
    extra_quo <- rlang::new_quosure(arg1$first_arg_sub,
                                    env = parent.frame())
    variables <- c(list(extra_quo), variables)
    class(variables) <- "quosures"
  }

  variable_names <- vapply(variables, rlang::quo_name, character(1))

  if (length(variable_names) == 0) {
    stop("Provide at least one variable name, e.g. jcomplete(DV, IV1, IV2).",
         call. = FALSE)
  }

  .jst_check_vars(data, variable_names, .jst_data_name)

  # Compute summary. Mask declared SPSS-form UDMs (na_values / na_range) to NA on
  # an analysis-only copy first, so this listwise diagnostic matches what the
  # analysis pipeline will actually exclude (Cross-cutting 5). complete.cases()
  # does not honour haven_labelled_spss na_values; is.na() does -- deriving both
  # the Missing column and the complete-case count from the masked copy keeps them
  # consistent. Stata/SAS tagged-NA values satisfy is.na() natively and are not
  # touched by the helper, so they already flow through complete.cases() correctly.
  n_total <- nrow(data)
  masked  <- .jst_apply_declared_udms_as_na(
    data[, variable_names, drop = FALSE])$data
  missing_info <- data.frame(
    Variable  = variable_names,
    N         = rep(n_total, length(variable_names)),
    Missing   = vapply(variable_names, function(v) sum(is.na(masked[[v]])), integer(1)),
    stringsAsFactors = FALSE
  )
  missing_info$Pct <- sprintf("%.1f%%", missing_info$Missing / n_total * 100)

  n_complete <- sum(stats::complete.cases(masked[, variable_names, drop = FALSE]))
  n_excluded <- n_total - n_complete

  # Store settings (capture any prior setting first, to flag replacement)
  prior_complete <- .jst_get_complete(.jst_data_name)
  .jst_set_complete(.jst_data_name, list(
    vars   = variable_names,
    active = TRUE
  ))

  # Print summary
  .cat_red("Listwise Case Filter\n")
  if (.jst_default_used) .jst_default_note(.jst_data_name, extra_newline = TRUE)

  .jst_print_table(missing_info,
                   col.names = c("Variable", "N", "Missing", "% Missing"),
                   row.names = FALSE)

  cat("\n  Complete cases: ", n_complete, " of ", n_total,
      " (", sprintf("%.1f", n_complete / n_total * 100), "%)\n", sep = "")
  if (n_excluded > 0) {
    cat("  Listwise filter activated \u2014 ", n_excluded,
        " cases will be excluded from subsequent analyses.\n", sep = "")
  } else {
    cat("  Listwise filter activated \u2014 no cases will be excluded (no missing values).\n")
  }
  if (!is.null(prior_complete) &&
      !identical(prior_complete$vars, variable_names)) {
    cat("  Replaced the previous jcomplete on ", .jst_data_name, " (was: ",
        paste(prior_complete$vars, collapse = ", "), ").\n", sep = "")
  }

  invisible(NULL)
}


# -- jdummy -------------------------------------------------------------------

#' Register categorical variables for dummy coding in regression
#'
#' @description
#' \code{jdummy()} registers a categorical variable so that \code{jlm()}
#' automatically expands it into dummy (indicator) variables when it appears
#' in a regression formula. The original data frame is never modified.
#'
#' Registrations are stored per dataset, so switching \code{juse()} between
#' datasets preserves each dataset's registrations independently.
#'
#' @param data A data frame, or omit to use the \code{juse()} default.
#'   Pass \code{NULL} to clear all registrations.
#' @param var Unquoted variable name to register. Omit (along with data)
#'   to display all current registrations.
#' @param ref The reference category (excluded from the regression model).
#'   Can be a numeric code, a quoted label name, or \code{first}
#'   (default) or \code{last}.
#' @param show Logical. If \code{TRUE}, prints the dummy coding scheme
#'   table showing the pattern of 0s and 1s. Default is \code{FALSE}.
#' @param remove Logical. If \code{TRUE}, removes the registration for
#'   the specified variable. Default is \code{FALSE}.
#'
#' @return Invisibly returns \code{NULL}. Called for its side effect.
#'
#' @examples
#' \donttest{
#' juse(mtcars)
#' jdummy(cyl)                          # Register, first category as reference
#' jdummy(cyl, ref = "last")            # Last category as reference
#' jdummy(cyl, ref = 6)                 # Reference by numeric code
#' # For haven-labelled variables, use the label name:
#' # jdummy(Employment, ref = "Part-Time")
#' jdummy(cyl, show = TRUE)             # Show coding scheme
#' jdummy(cyl, show = "all")            # Full scheme (for many categories)
#' jdummy()                             # Show all registrations
#' jdummy(cyl, remove = TRUE)           # Remove one registration
#' jdummy(mtcars, NULL)                 # Clear all registrations for mtcars
#' jdummy(NULL)                         # Clear registrations for ALL data frames
#' }
#'
#' @seealso \code{\link{JeffsStatTools}} for the package overview,
#'   workflow conventions, and complete function listing.
#'
#' @export
jdummy <- function(data, var, ref = "first", show = FALSE,
                   remove = FALSE) {

  default_name <- getOption(".jst_default_data", default = NULL)

  # -- jdummy() — no arguments: session-wide registration status ------------
  # Session-wide to match jdummy(NULL). Collapse rule: 1 frame renders the
  # full per-registration block (with optional coding scheme via show=);
  # 2+ frames render a header plus one concise line per frame (registered
  # variable names), with the juse() default marked. jdummy holds a list of
  # registrations per frame and has no active/inactive toggle, so there is
  # no off/on state to show here (unlike jsubset / jcomplete).
  if (missing(data) && missing(var)) {
    reg <- getOption(".jst_dummy", default = list())
    reg <- reg[vapply(reg, function(x) !is.null(x) && length(x) > 0L,
                      logical(1))]
    if (length(reg) == 0L) {
      message("No dummy registrations in this session.")
      return(invisible(NULL))
    }
    dnames <- names(reg)
    if (length(reg) > 1L) {
      lines <- vapply(seq_along(reg), function(i) {
        vn  <- vapply(reg[[i]], function(r) r$var_name, character(1))
        tag <- if (identical(dnames[i], default_name)) "  [default]" else ""
        paste0("  - ", dnames[i], ": ", paste(vn, collapse = ", "), tag)
      }, character(1))
      message("jdummy registrations (", length(reg), " data frames):\n",
              paste(lines, collapse = "\n"))
      return(invisible(NULL))
    }
    # Single frame: full per-registration rendering.
    frame_name <- dnames[1L]
    ds <- reg[[1L]]
    .cat_red("Dummy Variable Registrations\n")
    if (identical(frame_name, default_name)) {
      .jst_default_note(frame_name, extra_newline = TRUE)
    } else {
      .cat_yellow(paste0("Data frame: ", frame_name, "\n"))
      cat("\n")
    }
    for (regn in ds) {
      cat("  Variable: ", regn$var_name,
          " (", regn$var_type, ")\n", sep = "")
      cat("  Reference category: ", regn$ref_code, ": ", regn$ref_label, "\n", sep = "")
      cat("  Dummy variables: ", paste(regn$dummy_names, collapse = ", "), "\n", sep = "")
      cat("  Cases: ", regn$n_total,
          " (", regn$n_missing, " missing)\n", sep = "")

      # Show coding scheme if requested
      if (!identical(show, FALSE)) {
        n_cats <- length(regn$codes)
        show_all <- is.character(show) && tolower(show) == "all"
        n_show <- if (show_all) n_cats else min(n_cats, 5)

        all_col_names <- character(n_show)
        for (i in seq_len(n_show)) {
          if (i == regn$ref_idx) {
            all_col_names[i] <- paste0(regn$labels[i], "*")
          } else {
            all_col_names[i] <- regn$labels[i]
          }
        }

        row_labels <- character(n_show)
        for (i in 1:n_show) {
          if (i == regn$ref_idx) {
            row_labels[i] <- paste0(regn$codes[i], ": ", regn$labels[i], "*")
          } else {
            row_labels[i] <- paste0(regn$codes[i], ": ", regn$labels[i])
          }
        }

        scheme <- matrix(0L, nrow = n_show, ncol = n_show)
        for (i in 1:n_show) scheme[i, i] <- 1L

        scheme_df <- as.data.frame(scheme, stringsAsFactors = FALSE)
        names(scheme_df) <- all_col_names
        rownames(scheme_df) <- row_labels

        cat("\n  Dummy Coding Scheme:\n\n")
        .jst_print_table(scheme_df,
                         col.names = all_col_names,
                         row.names = TRUE,
                         indent = 4)
        cat("\n    * Reference category\n")

        if (n_cats > 5 && !show_all) {
          cat("    (Showing first 5 of ", n_cats,
              " categories \u2014 use show = \"all\" for complete table)\n", sep = "")
        }
      }
      cat("\n")
    }
    return(invisible(NULL))
  }

  # -- Capture substitute BEFORE any evaluation ------------------------------
  # Needed for the literal-NULL detection idiom and for the helper call.
  raw_data <- if (!missing(data)) substitute(data) else NULL

  # -- jdummy(NULL) — clear ALL registrations across every data frame --------
  # The condition "data was supplied AND substituted expression is NULL"
  # detects the literal jdummy(NULL) call. Mirrors jsubset(NULL) and
  # jcomplete(NULL).
  if (!missing(data) && is.null(raw_data)) {
    all_dummy <- getOption(".jst_dummy", default = list())
    if (length(all_dummy) == 0) {
      message("No dummy registrations to clear.")
      return(invisible(NULL))
    }

    # Build a per-data-frame summary BEFORE clearing, so the message can
    # tell the user what was lost.
    dnames <- names(all_dummy)
    hads <- vapply(seq_along(all_dummy), function(i) {
      regs <- all_dummy[[i]]
      if (is.null(regs) || length(regs) == 0) {
        "no registrations"
      } else {
        var_names <- vapply(regs, function(r) r$var_name, character(1))
        paste0("had ", length(var_names), " registered: ",
               paste(var_names, collapse = ", "))
      }
    }, character(1))

    options(.jst_dummy = NULL)

    .jst_render_clear("jdummy", dnames, hads)
    return(invisible(NULL))
  }

  # -- Resolve the first argument via the standard helper -------------------
  # Three modes possible at this point:
  #   explicit            : jdummy(SampleData, ...)        - data is a frame
  #   default             : jdummy(, var)                  - leading-comma form
  #   symbol_with_default : jdummy(var, ...)               - bare-symbol form
  arg1 <- .jst_resolve_first_arg(
    data_sub      = raw_data,
    data_missing  = missing(data),
    fn_name       = "jdummy",
    envir         = parent.frame(),
    accept_vector = FALSE
  )

  data              <- arg1$data
  .jst_data_name    <- arg1$name
  .jst_default_used <- arg1$mode %in% c("default", "symbol_with_default")

  # -- A' check: when data was omitted, the var slot must not be filled
  # positionally. Named args (ref, show, remove) are always fine.
  if (arg1$mode == "symbol_with_default" && !missing(var)) {
    displaced <- deparse(substitute(var))
    stop("jdummy(): when the data argument is omitted, all subsequent arguments must be named. ",
         "Use jdummy(", deparse(arg1$first_arg_sub),
         ", ref = ", displaced, ")",
         call. = FALSE)
  }

  # -- Determine var_name based on mode -------------------------------------
  if (arg1$mode == "symbol_with_default") {
    var_name <- deparse(arg1$first_arg_sub)
  } else if (!missing(var)) {
    var_name <- deparse(substitute(var))
  } else {
    var_name <- NULL  # only reachable in the clear-only path below
  }

  # Treat jdummy(SampleData, NULL) as a per-dataset clear, matching the
  # convention used by jsubset(SampleData, NULL) and jcomplete(SampleData,
  # NULL). The clear-all form jdummy(NULL) is handled earlier and never
  # reaches this point.
  if (identical(var_name, "NULL")) {
    existing <- .jst_get_dummy(.jst_data_name)
    if (is.null(existing) || length(existing) == 0) {
      message("No dummy registrations to clear for ", .jst_data_name, ".")
    } else {
      var_names <- vapply(existing, function(r) r$var_name, character(1))
      .jst_set_dummy(.jst_data_name, NULL)
      cat("Cleared ", length(var_names),
          " dummy registration", if (length(var_names) == 1L) "" else "s",
          " from ", .jst_data_name, ": ",
          paste(var_names, collapse = ", "), ".\n", sep = "")
    }
    return(invisible(NULL))
  }

  # If we got here without a var, the user passed neither data alone (above
  # would have hit the clear path or returned), nor a usable variable name.
  if (is.null(var_name)) {
    stop("jdummy(): no variable supplied. ",
         "Use jdummy(VarName) to register, jdummy(VarName, remove = TRUE) ",
         "to remove, or jdummy(NULL) to clear all registrations.",
         call. = FALSE)
  }

  .jst_check_vars(data, var_name, .jst_data_name)

  # -- jdummy(var, show = ...) on already-registered var: display only ------
  # If the user calls jdummy() naming an already-registered variable and
  # passes show = ... but does NOT pass ref = ..., treat the call as a
  # display-only request. This prevents accidentally clobbering a non-
  # default reference when the user just wants to inspect the existing
  # registration with the structural-table view.
  if (!identical(show, FALSE) && missing(ref) && !remove) {
    ds <- .jst_get_dummy(.jst_data_name)
    if (!is.null(ds)) {
      existing_idx <- which(vapply(ds, function(r) r$var_name == var_name,
                                   logical(1)))
      if (length(existing_idx) > 0) {
        reg <- ds[[existing_idx[1]]]

        # Print the existing registration summary
        .cat_red("Dummy Variable Registration\n")
        if (.jst_default_used) .jst_default_note(.jst_data_name, extra_newline = TRUE)
        cat("  Variable: ", reg$var_name, " (", reg$var_type, ")\n", sep = "")

        # ref_label is stored in canonical form from the original registration
        cat("  Reference category: ", reg$ref_label, "\n", sep = "")
        cat("  Dummy variables: ", paste(reg$dummy_names, collapse = ", "),
            "\n", sep = "")
        cat("  Cases: ", reg$n_total, " (", reg$n_missing, " missing)\n",
            sep = "")

        # Show coding scheme using stored codes/labels/ref_idx
        cat("\n  Dummy Coding Scheme:\n\n")
        n_cats   <- length(reg$codes)
        show_all <- is.character(show) && tolower(show) == "all"
        n_show   <- if (show_all) n_cats else min(n_cats, 5)

        all_col_names <- character(n_show)
        for (i in seq_len(n_show)) {
          if (i == reg$ref_idx) {
            all_col_names[i] <- paste0(reg$labels[i], "*")
          } else {
            all_col_names[i] <- reg$labels[i]
          }
        }

        row_labels <- character(n_show)
        for (i in 1:n_show) {
          if (i == reg$ref_idx) {
            row_labels[i] <- paste0(reg$codes[i], ": ", reg$labels[i], "*")
          } else {
            row_labels[i] <- paste0(reg$codes[i], ": ", reg$labels[i])
          }
        }

        scheme <- matrix(0L, nrow = n_show, ncol = n_show)
        for (i in 1:n_show) scheme[i, i] <- 1L
        scheme_df <- as.data.frame(scheme, stringsAsFactors = FALSE)
        names(scheme_df)    <- all_col_names
        rownames(scheme_df) <- row_labels

        .jst_print_table(scheme_df,
                         col.names = all_col_names,
                         row.names = TRUE,
                         indent = 4)

        cat("\n    * Reference category\n")
        if (n_cats > 5 && !show_all) {
          cat("    (Showing first 5 of ", n_cats,
              " categories \u2014 use show = \"all\" for complete table)\n",
              sep = "")
        }
        cat("\n")
        return(invisible(NULL))
      }
    }
    # If no existing registration, fall through to register-and-display.
  }

  # -- jdummy(var, remove = TRUE) — remove one registration -----------------
  if (remove) {
    ds <- .jst_get_dummy(.jst_data_name)
    if (!is.null(ds)) {
      ds <- ds[!vapply(ds, function(r) r$var_name == var_name, logical(1))]
      if (length(ds) == 0) ds <- NULL
      .jst_set_dummy(.jst_data_name, ds)
    }
    message("Dummy registration removed for '", var_name, "' in ", .jst_data_name, ".")
    return(invisible(NULL))
  }

  # -- Build registration via central helper --------------------------------
  # All naming logic lives in .jst_make_dummy_names() so that jdummy and
  # the auto-categorical pathways in jlm/jlogistic produce identical
  # column names for the same input.
  col <- data[[var_name]]
  built <- .jst_make_dummy_names(col, var_name, ref = ref)

  n_total   <- length(col)
  n_missing <- sum(is.na(col))

  # Print any informational notes from the helper (e.g. "codes used as
  # fallback because labels were not descriptive"). Warnings are deferred
  # until after the registration summary so the user sees the full result
  # first.
  for (n in built$notes) cat(n, "\n", sep = "")

  # Store registration
  reg <- list(
    var_name    = var_name,
    var_type    = built$var_type,
    codes       = built$codes,
    labels      = built$labels,
    ref_idx     = built$ref_idx,
    ref_code    = built$ref_code,
    ref_label   = built$ref_label,
    dummy_names = built$dummy_names,
    non_ref_idx = built$non_ref_idx,
    n_total     = n_total,
    n_missing   = n_missing
  )

  ds <- .jst_get_dummy(.jst_data_name)
  if (is.null(ds)) ds <- list()

  # Replace existing registration for this variable, or append
  existing_idx <- which(vapply(ds, function(r) r$var_name == var_name, logical(1)))
  if (length(existing_idx) > 0) {
    ds[[existing_idx[1]]] <- reg
  } else {
    ds[[length(ds) + 1]] <- reg
  }
  .jst_set_dummy(.jst_data_name, ds)

  # Print registration summary. ref_label and dummy_names are already in
  # canonical form from .jst_make_dummy_names() — no further processing
  # needed here.
  .cat_red("Dummy Variable Registration\n")
  if (.jst_default_used) .jst_default_note(.jst_data_name, extra_newline = TRUE)
  cat("  Variable: ", var_name, " (", built$var_type, ")\n", sep = "")
  cat("  Reference category: ", built$ref_label, "\n", sep = "")
  cat("  Dummy variables: ", paste(built$dummy_names, collapse = ", "),
      "\n", sep = "")
  cat("  Cases: ", n_total, " (", n_missing, " missing)\n", sep = "")

  # Pull short locals out of `built` to keep the show=TRUE block readable.
  codes      <- built$codes
  labels_vec <- built$labels
  ref_idx    <- built$ref_idx
  n_cats     <- length(codes)

  # Show coding scheme if requested
  if (!identical(show, FALSE)) {
    cat("\n  Dummy Coding Scheme:\n\n")

    show_all <- is.character(show) && tolower(show) == "all"
    n_show   <- if (show_all) n_cats else min(n_cats, 5)

    # Build column names — truncated to n_show
    all_col_names <- character(n_show)
    for (i in seq_len(n_show)) {
      if (i == ref_idx) {
        all_col_names[i] <- paste0(labels_vec[i], "*")
      } else {
        all_col_names[i] <- labels_vec[i]
      }
    }

    # Build row labels — add asterisk to reference category
    row_labels <- character(n_show)
    for (i in 1:n_show) {
      if (i == ref_idx) {
        row_labels[i] <- paste0(codes[i], ": ", labels_vec[i], "*")
      } else {
        row_labels[i] <- paste0(codes[i], ": ", labels_vec[i])
      }
    }

    # Build matrix of 0s and 1s
    scheme <- matrix(0L, nrow = n_show, ncol = n_show)
    for (i in 1:n_show) {
      scheme[i, i] <- 1L
    }

    scheme_df <- as.data.frame(scheme, stringsAsFactors = FALSE)
    names(scheme_df) <- all_col_names
    rownames(scheme_df) <- row_labels

    .jst_print_table(scheme_df,
                     col.names = all_col_names,
                     row.names = TRUE,
                     indent = 4)

    cat("\n    * Reference category\n")

    if (n_cats > 5 && !show_all) {
      cat("    (Showing first 5 of ", n_cats,
          " categories \u2014 use show = \"all\" for complete table)\n", sep = "")
    }
  }

  cat("\n")

  # Emit any deferred warnings (e.g. long names) after the user has seen
  # the full registration so the warning has context.
  for (w in built$warnings_msg) warning(w, call. = FALSE)

  invisible(NULL)
}


# -- joutput -------------------------------------------------------------------

#' Set session-level output verbosity
#'
#' Controls what analysis functions display by default. Three preset levels
#' are available, and individual toggles can override specific settings
#' within any level. Per-call arguments on analysis functions always take
#' precedence over joutput() settings.
#'
#' @param level Character. One of \code{minimal}, \code{standard}
#'   (default), or \code{full}. If omitted, prints the current settings.
#'   If \code{NULL}, resets to defaults (standard with no toggle overrides).
#'   \describe{
#'     \item{minimal}{Stripped-down output for power users. Core results
#'       only — no Case Processing Summary, no variable labels, no
#'       reference categories, no effect sizes, no CIs.}
#'     \item{standard}{Default. Suitable for teaching and routine use.
#'       Includes Case Processing Summary, variable labels, reference
#'       categories, effect sizes, and confidence intervals.}
#'     \item{full}{Everything in standard plus assumption checks
#'       (Levene's test), post-hoc tests, regression diagnostics, and the
#'       most detailed Case Processing Summary (per-code missing breakdown).}
#'   }
#' @param effect.size Logical or NULL. Override the level's default for
#'   effect size display.
#' @param ci Logical or NULL. Override the level's default for confidence
#'   interval display.
#' @param levene Logical or NULL. Override the level's default for
#'   Levene's test display.
#' @param posthoc Logical or NULL. Override the level's default for
#'   post-hoc test display (jaov only).
#' @param diagnostics Logical or NULL. Override the level's default for
#'   regression diagnostic output (jlm only).
#' @param case.processing Three-state toggle. \code{TRUE} forces the
#'   Case Processing Summary to print on every call. \code{FALSE}
#'   suppresses it on every call. \code{NULL} (the auto-suppress default
#'   at the standard tier) prints only when the call had something to
#'   report — pipeline state was active (\code{jsubset},
#'   \code{jcomplete}, or per-call \code{subset}), listwise deletion
#'   excluded at least one case (in listwise functions like \code{jlm},
#'   \code{jt}), or a per-variable discrepancy notification fires (in
#'   \code{jdesc}/\code{jfreq}). The minimal tier sets this to
#'   \code{FALSE}; the full tier sets it to \code{TRUE}; the standard
#'   tier sets it to \code{NULL}.
#' @param case.processing.detail Detail tier for the Case Processing
#'   Summary's missing-data breakdown: \code{"none"} (no bottom
#'   table), \code{"totals"} (one summed missing row per variable),
#'   or \code{"per_code"} (per UDM code plus system-missing). The
#'   minimal tier defaults to \code{"none"}, standard to
#'   \code{"totals"}, full to \code{"per_code"}.
#' @param var.labels Logical or NULL. Override the level's default for
#'   the variable labels block.
#' @param ref.categories Logical or NULL. Override the level's default
#'   for the reference categories block (registered dummies).
#' @param udm.notice Three-state toggle controlling the user-defined
#'   missing-value (UDM) notification emitted by \code{jload()} for
#'   \code{.sav} files. \code{TRUE} prints the notification on every
#'   load that involves UDM-bearing variables; \code{FALSE} suppresses
#'   it entirely; \code{NULL} ("auto") prints it only the first time
#'   in a session, then suppresses it. Standard level uses \code{NULL}
#'   (auto), minimal uses \code{FALSE}, full uses \code{TRUE}.
#'
#' @return Invisibly returns NULL. Called for its side effect of setting
#'   session options.
#'
#' @examples
#' joutput("standard")                     # effect sizes + CIs on all analyses
#' joutput("minimal", ci = TRUE)           # minimal + CIs only
#' joutput("full")                         # everything
#' joutput()                               # show current settings
#' joutput(NULL)                           # reset to defaults
#'
#' @seealso \code{\link{JeffsStatTools}} for the package overview,
#'   workflow conventions, and complete function listing.
#'
#' @export
#' @param echo Logical; default TRUE. When FALSE, joutput() applies the
#'   level/toggle change silently (the status panel is not printed). A bare
#'   joutput() status query always prints regardless of echo.
joutput <- function(level, effect.size = NULL, ci = NULL, levene = NULL,
                    posthoc = NULL, diagnostics = NULL,
                    case.processing = NULL, case.processing.detail = NULL,
                    var.labels = NULL,
                    ref.categories = NULL, udm.notice = NULL, echo = TRUE) {

  valid_levels <- c("minimal", "standard", "full")

  # joutput(NULL) -- reset to defaults
  if (!missing(level) && is.null(level)) {
    options(.jst_output_level = NULL)
    options(.jst_output_toggles = NULL)
    if (echo) {
      .cat_red("Output Settings\n")
      cat("Reset to defaults (standard, no toggle overrides).\n\n")
    }
    return(invisible(NULL))
  }

  # Collect any explicit toggle overrides
  toggle_args <- list()
  if (!is.null(effect.size))     toggle_args$effect.size     <- effect.size
  if (!is.null(ci))              toggle_args$ci              <- ci
  if (!is.null(levene))          toggle_args$levene          <- levene
  if (!is.null(posthoc))         toggle_args$posthoc         <- posthoc
  if (!is.null(diagnostics))     toggle_args$diagnostics     <- diagnostics
  if (!is.null(case.processing)) toggle_args$case.processing <- case.processing
  if (!is.null(case.processing.detail)) {
    if (!is.character(case.processing.detail) ||
        length(case.processing.detail) != 1 ||
        !(case.processing.detail %in% c("none", "totals", "per_code"))) {
      stop("case.processing.detail must be one of: \"none\", \"totals\", ",
           "\"per_code\".", call. = FALSE)
    }
    toggle_args$case.processing.detail <- case.processing.detail
  }
  if (!is.null(var.labels))      toggle_args$var.labels      <- var.labels
  if (!is.null(ref.categories))  toggle_args$ref.categories  <- ref.categories
  if (!is.null(udm.notice))      toggle_args$udm.notice      <- udm.notice

  # joutput() with no level argument -- show status or apply toggles only
  if (missing(level)) {
    if (length(toggle_args) > 0) {
      # Apply toggle overrides to current settings
      current_toggles <- getOption(".jst_output_toggles", list())
      for (nm in names(toggle_args)) current_toggles[[nm]] <- toggle_args[[nm]]
      options(.jst_output_toggles = current_toggles)
      # A toggle change respects echo.
      if (echo) .jst_output_status()
    } else {
      # A bare joutput() query always prints, regardless of echo.
      .jst_output_status()
    }
    return(invisible(NULL))
  }

  # Validate level
  if (!is.character(level) || length(level) != 1 || !(level %in% valid_levels)) {
    stop("level must be one of: \"minimal\", \"standard\", \"full\".",
         call. = FALSE)
  }

  # Set level and toggles
  options(.jst_output_level = level)
  if (length(toggle_args) > 0) {
    options(.jst_output_toggles = toggle_args)
  } else {
    options(.jst_output_toggles = NULL)
  }

  if (echo) .jst_output_status()
  invisible(NULL)
}

#' Internal helper: print current joutput() status
#'
#' @keywords internal
.jst_output_status <- function() {
  level   <- getOption(".jst_output_level", "standard")
  toggles <- getOption(".jst_output_toggles", list())

  .cat_red("Output Settings\n")
  cat("Level: ", level, "\n", sep = "")

  # Show effective value for each toggle
  toggle_names <- c("effect.size", "ci", "levene", "posthoc", "diagnostics",
                    "case.processing", "case.processing.detail",
                    "var.labels", "ref.categories", "udm.notice")
  defaults     <- .jst_output_defaults[[level]]

  for (nm in toggle_names) {
    default_val  <- defaults[[nm]]
    effective    <- if (nm %in% names(toggles)) toggles[[nm]] else default_val
    override_str <- if (nm %in% names(toggles)) " (override)" else ""

    # case.processing.detail carries a string tier (none/totals/per_code);
    # case.processing and udm.notice support three states (TRUE/FALSE/NULL=AUTO);
    # other toggles are binary.
    label <- if (identical(nm, "case.processing.detail")) {
      toupper(effective)
    } else if (is.null(effective)) {
      "AUTO"
    } else if (isTRUE(effective)) {
      "ON"
    } else {
      "OFF"
    }

    cat("  ", nm, ": ", label, override_str, "\n", sep = "")
  }
  cat("\n")
}


# =============================================================================
#  joptions -- non-display session options
# =============================================================================

# -- Internal: print current joptions() status --------------------------------
#
# Reads slot values from options() with fallback to .jst_options_defaults
# and prints the Options Settings panel. Called at the end of every
# joptions() call (including reset).

#' @keywords internal
.jst_options_status <- function() {
  mc <- getOption(".jst_options_missing_convention",
                  .jst_options_defaults$missing.convention)
  cc <- getOption(".jst_options_udm_convention_codes",
                  .jst_options_defaults$udm.convention.codes)
  dd <- getOption(".jst_options_data_dir",
                  .jst_options_defaults$data.dir)

  # Map the slot value to a user-facing label. "none" reads as "None
  # selected" so users understand they're in the no-auto-conversion
  # default; "spss" / "stata" surface in their familiar capitalizations.
  mc_label <- switch(mc,
                     none  = "None selected",
                     spss  = "SPSS",
                     stata = "Stata",
                     mc)

  # data.dir: NULL displays as "Working directory" for parallelism with
  # the "None selected" reading of missing.convention. A set value
  # displays as-is.
  dd_label <- if (is.null(dd)) "Working directory" else dd

  .cat_red("Options Settings\n")
  cat("User-defined missing values (UDMs) convention: ", mc_label,
      "\n", sep = "")
  cat("UDM convention codes: ", paste(cc, collapse = ", "), "\n", sep = "")
  cat("Data folder: ", dd_label, "\n", sep = "")
  cat("\n")
}


# -- Internal: globalenv() scan and one-line mismatch nudge -------------------
#
# Called by joptions() when missing.convention is set to "spss" or
# "stata". Scans globalenv() for data frames; for each, classifies each
# column's UDM convention via .jst_missing_info(); computes the DF's
# predominant convention; emits a one-line notice listing DFs whose
# predominant convention differs from target_convention. Silent when
# no mismatches.
#
# Classification rules (per locked design, Cross-cutting 3 Notes):
#   - Only columns with declared UDMs (SPSS-form na_values or Stata-form
#     tagged_na) count toward the predominant convention. Plain numeric
#     columns are ignored.
#   - Ties (equal SPSS- and Stata-form counts) cause the DF to be skipped.
#   - DFs with zero UDM-bearing columns are skipped (no predominant
#     convention to mismatch against).
#
# All mismatched DFs share the same predominant convention (the one
# opposite the newly-set target), so the message can group them.

#' @keywords internal
.jst_options_nudge <- function(target_convention) {
  env       <- globalenv()
  obj_names <- ls(envir = env)
  mismatched <- character(0)

  for (nm in obj_names) {
    obj <- tryCatch(get(nm, envir = env, inherits = FALSE),
                    error = function(e) NULL)
    if (!is.data.frame(obj)) next

    predominant <- .jst_predominant_convention(obj)
    if (is.na(predominant)) next

    if (predominant != target_convention) {
      mismatched <- c(mismatched, nm)
    }
  }

  if (length(mismatched) > 0L) {
    other_conv <- if (target_convention == "spss") "Stata" else "SPSS"
    verb       <- if (length(mismatched) == 1L) "uses" else "use"
    cat(sprintf("Note: %s predominantly %s %s-form UDMs. Use jconvert() to align.\n",
                paste(mismatched, collapse = ", "),
                verb,
                other_conv))
  }

  invisible(NULL)
}


#' Set or display session-level package options
#'
#' Controls session-wide settings that affect how the package handles
#' missing-value information and related conventions. \code{joptions} is
#' the non-display counterpart to \code{\link{joutput}}, which handles
#' output verbosity. Settings are read fresh on each function call:
#' changing a setting after data has been loaded does not retroactively
#' transform data already in memory. \code{\link{jconvert}} is the
#' explicit transform path for data already in the workspace.
#'
#' @section Slots:
#' \describe{
#'   \item{missing.convention}{Character, length 1. One of \code{"none"},
#'     \code{"spss"}, or \code{"stata"}. Default: \code{"none"}.
#'     \code{"none"} preserves loaded data as-is (no automatic conversion
#'     between UDM representations at load time). \code{"spss"} or
#'     \code{"stata"} opts into load-time auto-conversion via
#'     \code{\link{jload}}, and also supplies the target convention for
#'     fresh UDM declarations on columns with no existing convention.}
#'   \item{udm.convention.codes}{Numeric vector, length 1 to 4, whole
#'     numbers, no duplicates. Sign unconstrained. Default:
#'     \code{c(-99, -98, -97, -96)}. The recommended UDM code set used
#'     by \code{\link{jconvert}} when translating Stata-style missing values
#'     (\code{.a}, \code{.b}, \code{.c}, \code{.d}) into SPSS-form
#'     numeric codes, and by the load-time diagnostic for
#'     convention-matched detection.}
#'   \item{data.dir}{Character string (length 1), or \code{NULL}. Default:
#'     \code{NULL}. When \code{NULL}, \code{\link{jsave}} writes
#'     bare-filename saves to the working directory and \code{\link{jload}}
#'     searches the working directory. When set, names a folder (relative
#'     to the working directory) used as both the save target for
#'     bare-filename saves and as the first directory searched on
#'     bare-filename loads. The folder is auto-created on first save if
#'     it doesn't already exist. Filenames containing a directory
#'     separator (\code{/}) bypass this setting and are taken literally.}
#' }
#'
#' @section Call patterns:
#' \describe{
#'   \item{\code{joptions()}}{Print the current settings panel.}
#'   \item{\code{joptions(NULL)}}{Reset all slots to defaults, then print
#'     the panel.}
#'   \item{\code{joptions(slot = value, ...)}}{Set one or more slots,
#'     then print the panel. Passing \code{slot = NULL} as a named
#'     argument leaves that slot at its current value -- useful for
#'     setting one slot without touching another. To reset a single
#'     slot to its default, pass the default value explicitly (e.g.
#'     \code{joptions(missing.convention = "none")}).}
#' }
#'
#' @section Environment-scan notice:
#' Setting \code{missing.convention} to \code{"spss"} or \code{"stata"}
#' triggers a one-time scan of \code{globalenv()} for data frames whose
#' predominant UDM convention differs from the newly-set value. When
#' mismatches exist, a one-line notice lists the affected data frames
#' and suggests \code{\link{jconvert}} for alignment. The notice is
#' informational; nothing is changed. Plain data frames with no
#' UDM-bearing columns -- including the course datasets in their
#' standard form -- do not trigger the notice.
#'
#' @param missing.convention One of \code{"none"}, \code{"spss"}, or
#'   \code{"stata"}. See Slots.
#' @param udm.convention.codes Numeric vector, length 1 to 4. See Slots.
#' @param data.dir Character string (length 1), or \code{NULL}. See Slots.
#'
#' @return Invisibly returns \code{NULL}. Called for the side effect of
#'   updating session options and printing the status panel.
#'
#' @examples
#' joptions()                                        # show current settings
#' joptions(missing.convention = "spss")             # set, panel, nudge
#' joptions(udm.convention.codes = c(-99, -98))      # set, panel, no nudge
#' joptions(data.dir = "Data")                       # set save/load folder
#' joptions(missing.convention = "stata",
#'          udm.convention.codes = c(-99, -98, -97)) # set both
#' joptions(missing.convention = "spss",
#'          udm.convention.codes = NULL)             # set mc, leave codes
#' joptions(NULL)                                    # reset all to defaults
#'
#' @seealso \code{\link{joutput}} for output-verbosity settings;
#'   \code{\link{JeffsStatTools}} for the package overview.
#'
#' @export
#' @param echo Logical; default TRUE. When FALSE, joptions() applies the
#'   change silently, suppressing both the status panel and the convention
#'   nudge. A bare joptions() status query always prints regardless of echo.
joptions <- function(missing.convention = NULL, udm.convention.codes = NULL,
                     data.dir = NULL, echo = TRUE) {

  mc_supplied <- !missing(missing.convention)
  cc_supplied <- !missing(udm.convention.codes)
  dd_supplied <- !missing(data.dir)

  # joptions() -- no args, status only
  if (!mc_supplied && !cc_supplied && !dd_supplied) {
    .jst_options_status()
    return(invisible(NULL))
  }

  # Distinguish joptions(NULL) (reset all) from joptions(slot = NULL)
  # (leave that slot alone). The reset call has a single positional NULL
  # argument; match.call() would have rewritten that to
  # joptions(missing.convention = NULL) and erased the distinction, so
  # we inspect sys.call() directly. Detected shape: exactly one supplied
  # argument, unnamed in the source call, and NULL in value.
  call_args <- as.list(sys.call())[-1L]
  # Ignore a named echo = ... when detecting the reset shape, so
  # joptions(NULL, echo = FALSE) is still recognized as a (quiet) reset
  # rather than read as two arguments.
  arg_names <- names(call_args)
  if (!is.null(arg_names)) call_args <- call_args[arg_names != "echo"]
  positional_null_reset <- length(call_args) == 1L &&
                           (is.null(names(call_args)) ||
                            names(call_args) == "") &&
                           is.null(call_args[[1L]])

  # joptions(NULL) -- reset all
  if (positional_null_reset) {
    options(.jst_options_missing_convention   = NULL)
    options(.jst_options_udm_convention_codes = NULL)
    options(.jst_options_data_dir             = NULL)
    if (echo) .jst_options_status()
    return(invisible(NULL))
  }

  # Validate (atomic) -- all checks pass before any options() write
  if (mc_supplied && !is.null(missing.convention)) {
    if (!is.character(missing.convention) ||
        length(missing.convention) != 1L ||
        !(missing.convention %in% c("none", "spss", "stata"))) {
      stop("missing.convention must be one of: \"none\", \"spss\", \"stata\".",
           call. = FALSE)
    }
  }
  if (cc_supplied && !is.null(udm.convention.codes)) {
    x <- udm.convention.codes
    if (!is.numeric(x))
      stop("udm.convention.codes must be numeric.", call. = FALSE)
    if (length(x) < 1L || length(x) > 4L)
      stop("udm.convention.codes must have length 1 to 4.", call. = FALSE)
    if (anyNA(x) || !all(x == round(x)))
      stop("udm.convention.codes must contain only whole numbers.", call. = FALSE)
    if (anyDuplicated(x) > 0L)
      stop("udm.convention.codes must contain no duplicates.", call. = FALSE)
  }
  if (dd_supplied && !is.null(data.dir)) {
    if (!is.character(data.dir) ||
        length(data.dir) != 1L ||
        is.na(data.dir) ||
        nchar(trimws(data.dir)) == 0L) {
      stop("data.dir must be a single non-empty character string, or NULL.",
           call. = FALSE)
    }
  }

  # Write -- only supplied non-NULL args; NULL means "leave alone"
  trigger_nudge <- FALSE
  if (mc_supplied && !is.null(missing.convention)) {
    options(.jst_options_missing_convention = missing.convention)
    if (missing.convention %in% c("spss", "stata")) trigger_nudge <- TRUE
  }
  if (cc_supplied && !is.null(udm.convention.codes)) {
    options(.jst_options_udm_convention_codes = udm.convention.codes)
  }
  if (dd_supplied && !is.null(data.dir)) {
    options(.jst_options_data_dir = data.dir)
  }

  # Status panel, then nudge (per Session 28 Item 1 decision). echo = FALSE
  # silences both -- a quiet call is fully quiet.
  if (echo) {
    .jst_options_status()
    if (trigger_nudge) .jst_options_nudge(missing.convention)
  }

  invisible(NULL)
}

#' Return the configured data folder
#'
#' Read-side companion to \code{\link{joptions}(data.dir = ...)}: returns the
#' currently configured data folder as a string, for use in scripts that need
#' the path itself (building a file path, checking existence, cleaning up test
#' files) without reaching into package-internal option names.
#'
#' \code{joptions()} prints the folder but returns \code{invisible(NULL)};
#' \code{jdata_dir()} returns it as a value. When no folder is configured, the
#' \code{default} is returned (\code{"."}, the working directory, by default),
#' so the result drops straight into \code{\link{file.path}}. Pass
#' \code{default = NULL} to detect the unconfigured state explicitly.
#'
#' @param default Value returned when no data folder is configured. Defaults
#'   to \code{"."} (the working directory).
#' @return A length-one character string (the configured folder, or
#'   \code{default}); or \code{default} unchanged when it is \code{NULL}.
#' @seealso \code{\link{joptions}} to set the folder; \code{\link{jload}} and
#'   \code{\link{jsave}}, which resolve files against it.
#' @examples
#' \dontrun{
#' joptions(data.dir = "Data")
#' jdata_dir()                                  # "Data"
#' f <- file.path(jdata_dir(), "community.rds") # build a path in that folder
#' if (file.exists(f)) file.remove(f)
#'
#' jdata_dir(default = NULL)                    # NULL if nothing configured
#' }
#' @export
jdata_dir <- function(default = ".") {
  dir <- getOption(".jst_options_data_dir", .jst_options_defaults$data.dir)
  if (is.null(dir)) default else dir
}


# =============================================================================
#  DESCRIPTIVES
# =============================================================================

# -- jdesc --------------------------------------------------------------------

#' Descriptive statistics for one or more variables
#'
#' Computes basic descriptive statistics (N, non-missing, min, max, mean, SD)
#' for one or more variables in a data frame. Prints a formatted table and
#' invisibly returns the underlying results as a data frame.
#'
#' Output is structured consistently with \code{jfreq()}: a red title is
#' printed first, followed by a block showing the type and variable label
#' (or "None" if no label is present) for each variable, then a single blank
#' line before the table. For multiple variables, one type/label entry is
#' printed per variable before the shared table.
#'
#' Summarizes numeric, haven-labelled, logical, numeric-coded factor, and
#' numeric-looking character variables. Variables that cannot be summarized
#' --- text factors, text character variables, and date/time variables ---
#' are skipped with a warning directing the user to \code{jfreq()} (date/time
#' variables are not supported here). When every requested variable is
#' unsummarizable, jdesc() stops with an error. Also accepts a simple numeric
#' vector. Supports grouped descriptives via the \code{by} parameter.
#'
#' Haven-labelled variables are reported as \code{haven_labelled (Categorical)}
#' in the type line; the uninformative \code{vctrs_vctr} class is suppressed.
#'
#' @param data A data frame, or a numeric vector.
#' @param ... Unquoted variable names within \code{data} (ignored if data is a vector).
#' @param by An optional unquoted grouping variable name. When provided,
#'   descriptives are computed separately for each group, with a separate
#'   titled table per dependent variable.
#' @param subset An optional unquoted logical expression (e.g.
#'   \code{Group == 1}) to subset cases for this call only. Applied after
#'   jcomplete and jsubset. Does not affect other function calls.
#' @param labels Logical. If \code{TRUE} (default), prints the variable type
#'   and label (or "None") for each variable before the table.
#'
#' @return Invisibly returns a list of class \code{jst_desc} containing:
#'   \code{descriptives} (data frame of statistics, or NULL for grouped output),
#'   and \code{sample_info} (pipeline and missing data counts). Also
#'   prints a formatted table to the console.
#'
#' @examples
#' # With explicit data frame
#' jdesc(mtcars, mpg)
#' jdesc(mtcars, mpg, hp, wt)
#' jdesc(mtcars, mpg, by = am)
#'
#' # Using juse() default
#' juse(mtcars)
#' jdesc(mpg)
#' jdesc(mpg, hp, wt)
#' jdesc(mpg, by = am)
#'
#' # With a vector directly
#' jdesc(mtcars$mpg)
#'
#' @seealso \code{\link{JeffsStatTools}} for the package overview,
#'   workflow conventions, and complete function listing.
#'
#' @export
#' @param case.processing.detail Per-call override of the Case
#'   Processing Summary detail tier: one of \code{"none"},
#'   \code{"totals"}, or \code{"per_code"}. \code{NULL} (default)
#'   uses the active \code{joutput()} level default.
jdesc <- function(data, ..., by = NULL, subset = NULL, labels = NULL,
                  case.processing.detail = NULL) {

  # Resolve the first argument: explicit data frame, juse default,
  # vector input, or bare-symbol-as-variable-name (leading comma omitted).
  arg1 <- .jst_resolve_first_arg(
    data_sub      = substitute(data),
    data_missing  = missing(data),
    fn_name       = "jdesc",
    envir         = parent.frame(),
    accept_vector = TRUE
  )

  # Vector-input path (e.g. jdesc(SampleData$Gender)) — wrap and recurse
  if (arg1$mode == "vector_input") {
    var_name <- paste(deparse(arg1$first_arg_sub), collapse = "")
    if (grepl("\\$", var_name)) {
      var_name <- sub("^.*\\$", "", var_name)
    }
    temp_df  <- data.frame(x = arg1$first_arg_value)
    names(temp_df) <- var_name
    return(jdesc(temp_df, !!rlang::sym(var_name), labels = labels))
  }

  data              <- arg1$data
  .jst_data_name    <- arg1$name
  .jst_default_used <- arg1$mode %in% c("default", "symbol_with_default")

  variables <- rlang::enquos(...)

  # Leading-comma-omitted: prepend the captured symbol to variables list
  if (arg1$mode == "symbol_with_default") {
    extra_quo <- rlang::new_quosure(arg1$first_arg_sub,
                                    env = parent.frame())
    variables <- c(list(extra_quo), variables)
    class(variables) <- "quosures"
  }

  variable_names <- vapply(variables, rlang::quo_name, character(1))
  by_quo         <- rlang::enquo(by)

  # Check all variables exist before any processing
  check_names <- variable_names
  if (!rlang::quo_is_null(by_quo)) {
    check_names <- c(check_names, rlang::quo_name(by_quo))
  }
  .jst_check_vars(data, check_names, .jst_data_name)

  # Classify each analysis variable for summarizability. Shared by both the
  # grouped and ungrouped paths so the two cannot diverge. Numeric, labelled,
  # logical, numeric-coded factors, and numeric-looking text are summarized;
  # text factors, text character, date/time, and other types are refused.
  desc_class <- stats::setNames(
    lapply(variable_names, function(v) .jst_classify_desc_var(data[[v]], v)),
    variable_names
  )
  is_good   <- vapply(desc_class, function(z) isTRUE(z$summarisable), logical(1))
  good_vars <- variable_names[is_good]
  bad_vars  <- variable_names[!is_good]

  # If every requested variable is unsummarizable, stop before printing
  # anything. Mixed cases proceed: good variables are summarized and each
  # bad variable raises a warning.
  if (length(good_vars) == 0) {
    reasons <- vapply(variable_names, function(v) desc_class[[v]]$refusal,
                      character(1))
    if (length(variable_names) == 1L) {
      stop(reasons[[1L]], call. = FALSE)
    }
    stop(paste0("None of the requested variables can be summarized with ",
                "descriptive statistics:\n",
                paste0("  - ", reasons, collapse = "\n")), call. = FALSE)
  }

  # Per-variable notes for a summarized variable: the categorical-like
  # caution (small-range labelled / whole-number 0-6) and the numbers-as-text
  # note. Defined once so both paths warn identically. `dat` is passed
  # explicitly because the data frame is reassigned by the pipeline below.
  .emit_good_notes <- function(v, dat) {
    if (.jst_is_discrete_integer(dat[[v]], v, .jst_data_name)) {
      warning(paste0("'", v, "' has categorical-like structure ",
                     "(small-range integer or labelled values). ",
                     "Descriptive statistics may not be meaningful. ",
                     "Use jfreq() for frequency tables."),
              call. = FALSE)
    }
    if (!is.null(desc_class[[v]]$note)) {
      warning(desc_class[[v]]$note, call. = FALSE)
    }
  }
  # Mixed case: one warning per variable that could not be summarized.
  .emit_bad_refusals <- function() {
    for (v in bad_vars) warning(desc_class[[v]]$refusal, call. = FALSE)
  }

  # -- Grouped descriptives ---------------------------------------------------
  if (!rlang::quo_is_null(by_quo)) {
    by_name <- rlang::quo_name(by_quo)
    by_var  <- data[[by_name]]

    # Capture original class and label BEFORE any conversion
    original_by_class <- class(by_var)
    original_by_label <- .get_var_label_str(by_var)
    original_dv_info  <- stats::setNames(
      lapply(variable_names, function(v) {
        list(class = class(data[[v]]),
             label = .get_var_label_str(data[[v]]))
      }),
      variable_names
    )

    is_labelled_by <- haven::is.labelled(by_var)
    if (is_labelled_by) {
      original_codes  <- sort(unique(.jst_as_numeric(by_var[!is.na(by_var)])))
      data[[by_name]] <- haven::as_factor(by_var)
    } else if (!is.factor(data[[by_name]])) {
      data[[by_name]] <- factor(data[[by_name]])
    }

    group_levels <- levels(data[[by_name]])

    # Apply data pipeline (jcomplete, jsubset, subset) — once before per-variable loop
    subset_expr <- substitute(subset)
    pipeline <- .jst_apply_pipeline(data, .jst_data_name, .jst_default_used,
                                    subset_expr = subset_expr, envir = parent.frame())
    data     <- pipeline$data

    # Build sample_info once for the entire by-group output. Only the
    # summarizable (good) analysis variables contribute. Per-variable Ns are
    # reported in each mini-table.
    sample_info <- .jst_build_sample_info(
      pipeline_counts = pipeline$pipeline_counts,
      data            = pipeline$data,
      analysis_vars   = c(good_vars, by_name),
      n_analysis      = nrow(data)
    )
    # Shared header for the whole by-group output: printed once (parallels
    # the no-by path), not repeated per variable. The grouping variable's
    # type/label block belongs here; each analysis variable's own block
    # stays inside the per-variable loop below. The Case Processing Summary
    # likewise renders once for the whole by-group output (per-variable
    # layouts render CPS once; locked CPS rendering design).
    .cat_red(paste0("Descriptive Statistics by ", by_name,
                    " (", length(group_levels), " levels)\n"))
    if (.jst_default_used) .jst_default_note(.jst_data_name)
    .jst_print_msgs(pipeline$msgs)
    if (.jst_resolve_toggle("var.labels", labels)) {
      cat(by_name, "\n", sep = "")
      cat("  Type: ", .format_var_type(original_by_class), "\n", sep = "")
      cat("  Variable label: ", original_by_label, "\n", sep = "")
    }
    cat("\n")

    .jst_print_case_processing(sample_info, analysis_type = "per_var_desc",
                               detail = case.processing.detail)

    for (v in good_vars) {
      if (.jst_resolve_toggle("var.labels", labels)) {
        cat(v, "\n", sep = "")
        cat("  Type: ", .format_var_type(original_dv_info[[v]]$class), "\n", sep = "")
        cat("  Variable label: ", original_dv_info[[v]]$label, "\n", sep = "")
      }

      .emit_good_notes(v, data)
      cat("\n")

      # Coerce to numeric via the shared classifier. Text factors, text
      # character, and date/time variables never reach here (they are in
      # bad_vars), so this also avoids the stray coercion warning the old
      # bare as.numeric() produced for character columns.
      dv_data <- .jst_classify_desc_var(data[[v]], v)$num

      group_var_chr <- as.character(data[[by_name]])

      group_rows <- lapply(seq_along(group_levels), function(i) {
        lvl         <- group_levels[i]
        subset_data <- dv_data[group_var_chr == lvl]
        subset_data <- subset_data[!is.na(subset_data)]
        n <- length(subset_data)
        m <- if (n > 0) mean(subset_data) else NA
        s <- if (n > 0) sd(subset_data)   else NA

        group_label <- if (is_labelled_by) {
          paste0(original_codes[i], ": ", lvl)
        } else {
          lvl
        }

        df <- data.frame(
          GROUP_PLACEHOLDER = group_label,
          N     = n,
          Min   = if (n > 0) round(min(subset_data), 3) else NA,
          Max   = if (n > 0) round(max(subset_data), 3) else NA,
          Mean  = if (n > 0) round(m, 3) else NA,
          SD    = if (n > 0) round(s, 3) else NA,
          stringsAsFactors = FALSE
        )
        names(df)[1] <- by_name
        df
      })
      group_table <- do.call(rbind, group_rows)

      .jst_print_table(group_table, row.names = FALSE)
      cat("\n")
    }

    # Mixed case: warn for any variables that could not be summarized.
    .emit_bad_refusals()

    cat("\n")

    # Build sample_info for grouped descriptives
    sample_info <- .jst_build_sample_info(
      pipeline_counts = pipeline$pipeline_counts,
      data            = pipeline$data,
      analysis_vars   = c(good_vars, by_name),
      n_analysis      = nrow(data)
    )

    ret <- list(
      descriptives = NULL,
      by           = by_name,
      sample_info  = sample_info
    )
    class(ret) <- "jst_desc"
    return(invisible(ret))
  }

  # -- Standard (ungrouped) descriptives --------------------------------------

  # Capture original class and label info BEFORE any conversion
  original_var_info <- stats::setNames(
    lapply(variable_names, function(v) {
      list(class = class(data[[v]]),
           label = .get_var_label_str(data[[v]]))
    }),
    variable_names
  )

  # -- Print title and apply pipeline before computation -----------------------
  .cat_red("Descriptive Statistics\n")
  if (.jst_default_used) .jst_default_note(.jst_data_name)

  # Apply data pipeline (jcomplete, jsubset, subset)
  subset_expr <- substitute(subset)
  pipeline <- .jst_apply_pipeline(data, .jst_data_name, .jst_default_used,
                                  subset_expr = subset_expr, envir = parent.frame())
  data     <- pipeline$data
  .jst_print_msgs(pipeline$msgs)

  # Build sample_info (used by CPS and the return value). Only the
  # summarizable (good) variables contribute. For jdesc the analysis sample
  # is the post-pipeline data; per-variable Ns are reported in the
  # descriptives table itself, not in CPS.
  sample_info <- .jst_build_sample_info(
    pipeline_counts = pipeline$pipeline_counts,
    data            = pipeline$data,
    analysis_vars   = good_vars,
    n_analysis      = nrow(data)
  )

  .jst_print_case_processing(
    sample_info,
    analysis_type         = "per_var_desc",
    detail                = case.processing.detail,
    notification_template = paste0(
      "Note: Listwise deletion using jcomplete() first will reduce the Remaining N to %d."
    ),
    data          = data,
    analysis_vars = good_vars
  )

  if (.jst_resolve_toggle("var.labels", labels)) {
    for (v in good_vars) {
      cat(v, "\n", sep = "")
      cat("  Type: ", .format_var_type(original_var_info[[v]]$class), "\n", sep = "")
      cat("  Variable label: ", original_var_info[[v]]$label, "\n", sep = "")
    }
  }

  # Categorical-like and numbers-as-text notes for each summarized variable.
  for (v in good_vars) .emit_good_notes(v, data)

  # -- Compute descriptives on filtered data ---------------------------------
  descriptives_list <- lapply(good_vars, function(v) {
    var_data <- .jst_classify_desc_var(data[[v]], v)$num
    n        <- sum(!is.na(var_data))
    # Guard against a variable with zero non-missing values: min()/max()
    # would return Inf/-Inf (and emit base R "no non-missing arguments"
    # warnings), while mean()/sd() return NaN/NA. Report all four as NA
    # (rendered blank) instead, matching the grouped path's per-group
    # guard above. (Session 50)
    data.frame(
      Variable    = v,
      Total       = length(var_data),
      Non_missing = n,
      Min         = if (n > 0) round(min(var_data, na.rm = TRUE), 3) else NA,
      Max         = if (n > 0) round(max(var_data, na.rm = TRUE), 3) else NA,
      Mean        = if (n > 0) round(mean(var_data, na.rm = TRUE), 3) else NA,
      SD          = if (n > 0) round(stats::sd(var_data, na.rm = TRUE), 3) else NA,
      stringsAsFactors = FALSE
    )
  })

  descriptives <- do.call(rbind, descriptives_list)

  # Defensive: with good_vars guaranteed non-empty this should always hold,
  # but guard against an empty table reaching the renderer.
  if (!is.null(descriptives) && nrow(descriptives) > 0) {
    cat("\n")
    .jst_print_table(descriptives)
    cat("\n")
  }

  # Mixed case: warn for any variables that could not be summarized.
  .emit_bad_refusals()

  ret <- list(
    descriptives = descriptives,
    sample_info  = sample_info
  )
  class(ret) <- "jst_desc"
  invisible(ret)
}


#' Internal helper: coerce a POSIXlt vector to atomic POSIXct
#'
#' POSIXlt is list-backed (nine parallel components), which makes
#' \code{table()}, \code{unique()}, and \code{stats::complete.cases()} either
#' abort or misbehave. Returns the equivalent atomic POSIXct (same instants);
#' non-POSIXlt input is returned unchanged. Mirrors the POSIXlt -> POSIXct
#' remedy jsave recommends for unstorable column types.
#'
#' @param x A variable / data-frame column.
#' @return \code{x} as POSIXct if it was POSIXlt, otherwise \code{x} unchanged.
#' @keywords internal
.jst_posixlt_to_posixct <- function(x) {
  if (inherits(x, "POSIXlt")) as.POSIXct(x) else x
}


# -- jfreq --------------------------------------------------------------------

#' SPSS-like frequency tables for categorical variables
#'
#' Prints an SPSS-style frequency table (Freq, Total \%, Valid \%, Cum. \%) for
#' each variable supplied. Designed for use with unquoted variable names, and
#' also accepts a plain vector.
#'
#' Output is structured consistently with \code{jdesc()}: a single red
#' "Frequencies" title is printed first, followed by the default-data note
#' (if a juse() default was used), any pipeline messages, and the Case
#' Processing Summary (when at least one pipeline stage was active for
#' this call). Each variable then gets its own block consisting of the
#' variable name on its own line, indented Type and Variable label lines
#' (suppressed when \code{joutput()}'s \code{var.labels} toggle is off),
#' a blank line, and the frequency table. The frequency table ends with
#' a Total row showing the post-pipeline N.
#'
#' For haven-labelled variables, value labels and numeric codes are combined
#' in the frequency table rows (e.g. \code{1: Strongly Oppose}). The type
#' line reports \code{haven_labelled (Categorical)} and suppresses the
#' uninformative \code{vctrs_vctr} class. Variable labels are shown for all
#' variable types, not only haven-labelled ones.
#'
#' @param data A data frame, or a vector.
#' @param ... Unquoted variable name(s) within \code{data} (ignored if
#'   \code{data} is a vector).
#' @param subset An optional unquoted logical expression (e.g.
#'   \code{Group == 1}) to subset cases for this call only. Applied after
#'   jcomplete and jsubset. Does not affect other function calls.
#' @param labels Logical or NULL. If TRUE, prints the variable type and
#'   label (or "None") beneath the title. If FALSE, suppresses them. If
#'   NULL (default), defers to \code{joutput()}'s \code{var.labels}
#'   setting.
#'
#' @return Invisibly returns a list of class \code{jst_freq} containing:
#'   \code{frequencies} (named list of data frames, one per variable) and
#'   \code{sample_info} (pipeline and missing data counts).
#'
#' @examples
#' # With explicit data frame
#' jfreq(mtcars, cyl)
#' jfreq(mtcars, cyl, gear)
#'
#' # Using juse() default
#' juse(mtcars)
#' jfreq(cyl)
#' jfreq(cyl, gear)
#'
#' # With a vector directly
#' jfreq(mtcars$gear)
#'
#' @seealso \code{\link{JeffsStatTools}} for the package overview,
#'   workflow conventions, and complete function listing.
#'
#' @export
#' @param case.processing.detail Accepted for API symmetry. jfreq's
#'   Case Processing Summary is top-table only (no missing-data
#'   breakdown), so this argument has no effect; per-variable code
#'   detail already appears in each variable's frequency table.
jfreq <- function(data, ..., subset = NULL, labels = NULL,
                  case.processing.detail = NULL) {

  # Resolve the first argument: explicit data frame, juse default,
  # vector input, or bare-symbol-as-variable-name (leading comma omitted).
  arg1 <- .jst_resolve_first_arg(
    data_sub      = substitute(data),
    data_missing  = missing(data),
    fn_name       = "jfreq",
    envir         = parent.frame(),
    accept_vector = TRUE
  )

  # Vector-input path (e.g. jfreq(SampleData$Gender)) — wrap and recurse
  if (arg1$mode == "vector_input") {
    var_name <- paste(deparse(arg1$first_arg_sub), collapse = "")
    if (grepl("\\$", var_name)) {
      var_name <- sub("^.*\\$", "", var_name)
    }
    temp_df  <- data.frame(x = arg1$first_arg_value)
    names(temp_df) <- var_name
    return(jfreq(temp_df, !!rlang::sym(var_name), labels = labels))
  }

  data              <- arg1$data
  .jst_data_name    <- arg1$name
  .jst_default_used <- arg1$mode %in% c("default", "symbol_with_default")

  variables <- rlang::enquos(...)

  # Leading-comma-omitted: prepend the captured symbol to variables list
  if (arg1$mode == "symbol_with_default") {
    extra_quo <- rlang::new_quosure(arg1$first_arg_sub,
                                    env = parent.frame())
    variables <- c(list(extra_quo), variables)
    class(variables) <- "quosures"
  }

  results <- list()

  # Check all variables exist before any processing
  var_names_check <- vapply(variables, rlang::quo_name, character(1))
  .jst_check_vars(data, var_names_check, .jst_data_name)

  # Apply data pipeline (jcomplete, jsubset, subset) — once before per-variable loop
  subset_expr <- substitute(subset)
  pipeline <- .jst_apply_pipeline(data, .jst_data_name, .jst_default_used,
                                  subset_expr = subset_expr, envir = parent.frame())
  data     <- pipeline$data

  # Resolve display toggles
  show_var_labels      <- .jst_resolve_toggle("var.labels",      labels)
  # Build sample_info (used by CPS and the return value)
  sample_info <- .jst_build_sample_info(
    pipeline_counts = pipeline$pipeline_counts,
    data            = pipeline$data,
    analysis_vars   = var_names_check,
    n_analysis      = nrow(data)
  )

  # -- Preamble (printed once, before any per-variable block) ----------------
  .cat_red("Frequencies\n")
  if (.jst_default_used) .jst_default_note(.jst_data_name)
  .jst_print_msgs(pipeline$msgs)

  # Case Processing Summary (jfreq is the per-variable Frequencies layout:
  # top table only, never a bottom; per-variable code detail already lives in
  # each variable's own frequency table). case.processing.detail is accepted
  # for API uniformity but is a no-op here.
  .jst_print_case_processing(
    sample_info,
    analysis_type         = "per_var_freq",
    detail                = case.processing.detail,
    notification_template = paste0(
      "Note: Listwise deletion using jcomplete() first will reduce the Remaining N to %d."
    ),
    data          = data,
    analysis_vars = var_names_check
  )

  # Distinct-value count above which a frequency table is flagged as possibly
  # uninformative. Type-agnostic (catches timestamps, continuous measures, and
  # free-text IDs alike); jfreq still tabulates — the note is advisory only.
  # (Session 47)
  card_warn_threshold <- 50L

  # -- Per-variable blocks ---------------------------------------------------
  for (variable in variables) {
    variable_name <- rlang::quo_name(variable)

    # Capture class and label BEFORE any conversion
    temp_var      <- data[[variable_name]]
    var_class     <- class(temp_var)
    var_label_val <- .get_var_label_str(data[[variable_name]])

    # POSIXlt is list-backed; table()/is.na() try to cross-classify its nine
    # components and abort ("attempt to make a table with >= 2^31 elements").
    # Coerce to atomic POSIXct for tabulation (same instants); var_class above
    # keeps the displayed Type honest. (Session 47)
    temp_var <- .jst_posixlt_to_posixct(temp_var)

    # Cardinality guard: count distinct non-missing values for the advisory
    # note printed with this variable's block below. (Session 47)
    n_distinct_vals <- length(unique(temp_var[!is.na(temp_var)]))

    # Sort key for Valid rows: build a (display_string, sort_key) mapping
    # so the table sorts numerically when the underlying values are
    # numeric, regardless of the categorical-display treatment. Without
    # this, factor() defaults to alphabetic ordering, putting "10" between
    # "1" and "2".
    sort_codes <- NULL
    sort_levels <- NULL

    # Character-backed haven_labelled (e.g. "US"/"UK" carrying value labels):
    # the stored "codes" are strings, so the numeric-labelled path below would
    # coerce them to all-NA and yield an empty table plus an "NAs introduced
    # by coercion" warning. Display each stored value with its label as
    # "code: label" (bare code when unlabelled), sorted by the stored value,
    # mirroring the numeric-labelled layout with no numeric coercion. The
    # .jst_var_kind detector routes this kind to text_character for jdesc;
    # jfreq tabulates it here instead of refusing. (Session 51)
    if (haven::is.labelled(temp_var) && typeof(temp_var) == "character") {
      codes_chr  <- as.character(unclass(temp_var))
      val_labs   <- labelled::val_labels(temp_var)
      lab_lookup <- if (!is.null(val_labs) && length(val_labs) > 0L) {
        stats::setNames(names(val_labs), as.character(unname(val_labs)))
      } else {
        character(0)
      }
      lab_for     <- unname(lab_lookup[codes_chr])
      display_str <- ifelse(is.na(codes_chr), NA_character_,
                            ifelse(!is.na(lab_for) & nzchar(lab_for),
                                   paste(codes_chr, lab_for, sep = ": "),
                                   codes_chr))
      uniq        <- !is.na(codes_chr) & !duplicated(display_str)
      sort_codes  <- codes_chr[uniq]
      sort_levels <- display_str[uniq][order(sort_codes)]
      temp_var    <- factor(display_str, levels = sort_levels)

    # Haven-labelled (numeric-backed): combine numeric codes with value labels.
    } else if (haven::is.labelled(temp_var)) {
      label_text <- as.character(haven::as_factor(temp_var))
      codes      <- .jst_as_numeric(temp_var)
      val_labs   <- labelled::val_labels(temp_var)
      # When a code has no entry in val_labels, haven::as_factor falls
      # back to the stringified value, producing display strings like
      # "3: 3". Render those as bare code instead (Decision 7 Notes,
      # fix (b) in the valid-row context).
      has_label  <- if (!is.null(val_labs) && length(val_labs) > 0L) {
        !is.na(codes) & (codes %in% unname(val_labs))
      } else {
        rep(FALSE, length(codes))
      }
      display_str <- ifelse(is.na(codes), NA_character_,
                            ifelse(has_label,
                                   paste(codes, label_text, sep = ": "),
                                   as.character(codes)))
      # Map each unique display string to its underlying code for sorting
      uniq        <- !is.na(codes) & !duplicated(display_str)
      sort_codes  <- codes[uniq]
      sort_levels <- display_str[uniq][order(sort_codes)]
      temp_var    <- factor(display_str, levels = sort_levels)

    } else if (is.numeric(temp_var)) {
      # Plain numeric: numeric-ordered factor levels.
      uniq_vals   <- sort(unique(temp_var[!is.na(temp_var)]))
      sort_levels <- as.character(uniq_vals)
      temp_var    <- factor(as.character(temp_var), levels = sort_levels)
    }

    # Frequency table (base R) for the post-masking analysis copy.
    tbl         <- table(temp_var, useNA = "no")
    total_count <- length(temp_var)
    valid_count <- sum(!is.na(temp_var))

    # Valid rows: in the level order determined above.
    valid_df <- data.frame(
      Value = names(tbl),
      Freq  = as.integer(tbl),
      stringsAsFactors = FALSE
    )

    # Missing breakdown: UDM rows (if any) + system NA row (if any).
    # Row structure and labels are driven by .jst_missing_info() so the
    # format stays in sync with the load-time narrative produced by
    # .jst_format_udm_narrative (shared-rendering-conventions principle,
    # Decision 7). Per-code COUNTS for SPSS-form variables come from the
    # pipeline's declared-UDM masking pass (.jst_apply_declared_udms_as_na,
    # via pipeline$pipeline_counts$udm_masked_vars) rather than being
    # re-counted here, so jfreq and the forthcoming CPS per_code bottom
    # share one count source. Stata-form tagged_na variables are not
    # masked (is.na() catches them natively), so that branch still counts
    # via haven::na_tag() on the raw column.
    raw_col   <- arg1$data[[variable_name]]
    mi        <- .jst_missing_info(raw_col)
    udm_rows  <- data.frame(Value = character(0), Freq = integer(0),
                            stringsAsFactors = FALSE)
    udm_total <- 0L

    if (!is.null(mi)) {
      if (identical(mi$representation, "stata")) {
        # Stata/SAS-form: per-tag rows. haven::na_tag() distinguishes
        # lowercase (.a, .b) from uppercase (.A, .B) markers, so SAS-
        # style declarations land in their own rows correctly.
        tag_vec <- haven::na_tag(raw_col)
        for (i in seq_len(nrow(mi$codes))) {
          r <- mi$codes[i, ]
          row_count <- as.integer(sum(!is.na(tag_vec) & tag_vec == r$tag))
          row_label <- if (!is.na(r$label) && nzchar(r$label)) {
            sprintf('%s ["%s"]', r$code, r$label)
          } else {
            sprintf('%s (no label)', r$code)
          }
          udm_total <- udm_total + row_count
          udm_rows  <- rbind(udm_rows,
                             data.frame(Value = row_label, Freq = row_count,
                                        stringsAsFactors = FALSE))
        }
      } else {
        # SPSS-form: per-code rows plus optional range row. Counts come
        # from the masking pass (udm_masked_vars$entries); a variable
        # whose codes matched zero cells is absent from the bundle and its
        # rows must still print (count 0) — mi drives that, lookup -> 0.
        ent <- pipeline$pipeline_counts$udm_masked_vars[[variable_name]]$entries
        code_count <- function(code_disp) {
          if (is.null(ent)) return(0L)
          hit <- ent$count[ent$code_display == code_disp]
          if (length(hit) == 0L) 0L else as.integer(hit[1])
        }
        if (!is.null(mi$codes) && nrow(mi$codes) > 0L) {
          for (i in seq_len(nrow(mi$codes))) {
            r <- mi$codes[i, ]
            row_count <- code_count(r$code)
            row_label <- if (!is.na(r$label) && nzchar(r$label)) {
              sprintf('%s ["%s"]', r$code, r$label)
            } else {
              sprintf('%s (no label)', r$code)
            }
            udm_total <- udm_total + row_count
            udm_rows  <- rbind(udm_rows,
                               data.frame(Value = row_label, Freq = row_count,
                                          stringsAsFactors = FALSE))
          }
        }
        if (!is.null(mi$na_range) && length(mi$na_range) == 2L) {
          rg          <- mi$na_range
          # Range count is the entries row whose code_display is not one
          # of the discrete declared codes (at most one such row).
          range_count <- if (is.null(ent)) 0L else {
            rr <- ent$count[!ent$code_display %in% mi$codes$code]
            if (length(rr) == 0L) 0L else as.integer(sum(rr))
          }
          row_label   <- sprintf("range %s to %s", rg[1], rg[2])
          udm_total   <- udm_total + range_count
          udm_rows    <- rbind(udm_rows,
                               data.frame(Value = row_label, Freq = range_count,
                                          stringsAsFactors = FALSE))
        }
      }
    }

    total_na <- as.integer(sum(is.na(temp_var)))
    sys_na   <- max(0L, total_na - udm_total)

    # System NA row
    na_row <- if (sys_na > 0L) {
      data.frame(Value = .jst_label_system_missing, Freq = sys_na,
                 stringsAsFactors = FALSE)
    } else NULL

    has_missing <- (nrow(udm_rows) > 0L) || sys_na > 0L

    # Compute Total % across all rows (Valid + Missing + Total = 100)
    valid_df$TotalPct <- (valid_df$Freq / total_count) * 100
    if (nrow(udm_rows) > 0L) {
      udm_rows$TotalPct <- ifelse(is.na(udm_rows$Freq), NA_real_,
                                  (udm_rows$Freq / total_count) * 100)
    }
    if (!is.null(na_row)) {
      na_row$TotalPct <- (na_row$Freq / total_count) * 100
    }

    # Valid % and Cum. % apply only to Valid rows
    valid_df$ValidPct <- (valid_df$Freq / valid_count) * 100
    valid_df$CumPct   <- cumsum(valid_df$ValidPct)

    results[[variable_name]] <- list(valid = valid_df,
                                     udm   = udm_rows,
                                     na    = na_row,
                                     total = total_count)

    # -- Print: variable-name anchor -> (optional Type/Label) -> blank -> table
    cat(variable_name, "\n", sep = "")
    if (show_var_labels) {
      cat("  Type: ", .format_var_type(var_class), "\n", sep = "")
      cat("  Variable label: ", var_label_val, "\n", sep = "")
    }
    if (n_distinct_vals > card_warn_threshold) {
      cat("  Note: '", variable_name, "' has ", n_distinct_vals,
          " distinct values; a frequency table may not be informative.\n",
          sep = "")
    }
    cat("\n")

    # Build display rows. When missings exist, prepend "Valid" / "Missing"
    # marker rows. When no missings exist, print flat (current behavior).
    fmt_pct <- function(x) ifelse(is.na(x), "", sprintf("%.2f", x))
    fmt_int <- function(x) ifelse(is.na(x), "", as.character(x))

    display_df <- data.frame(Value = character(0), Freq = character(0),
                             TotalPct = character(0), ValidPct = character(0),
                             CumPct = character(0), stringsAsFactors = FALSE)

    if (has_missing) {
      # Valid section header
      display_df <- rbind(display_df, data.frame(
        Value = "Valid", Freq = "", TotalPct = "",
        ValidPct = "", CumPct = "", stringsAsFactors = FALSE))
    }

    # Valid data rows
    if (nrow(valid_df) > 0L) {
      display_df <- rbind(display_df, data.frame(
        Value    = valid_df$Value,
        Freq     = fmt_int(valid_df$Freq),
        TotalPct = fmt_pct(valid_df$TotalPct),
        ValidPct = fmt_pct(valid_df$ValidPct),
        CumPct   = fmt_pct(valid_df$CumPct),
        stringsAsFactors = FALSE))
    }

    if (has_missing) {
      # Missing section header (blank line + header row for separation)
      display_df <- rbind(display_df, data.frame(
        Value = "", Freq = "", TotalPct = "",
        ValidPct = "", CumPct = "", stringsAsFactors = FALSE))
      display_df <- rbind(display_df, data.frame(
        Value = "Missing", Freq = "", TotalPct = "",
        ValidPct = "", CumPct = "", stringsAsFactors = FALSE))

      # UDM rows (Valid % and Cum. % shown as "--" for missing rows)
      if (nrow(udm_rows) > 0L) {
        display_df <- rbind(display_df, data.frame(
          Value    = udm_rows$Value,
          Freq     = fmt_int(udm_rows$Freq),
          TotalPct = fmt_pct(udm_rows$TotalPct),
          ValidPct = "--",
          CumPct   = "--",
          stringsAsFactors = FALSE))
      }

      # System NA row
      if (!is.null(na_row)) {
        display_df <- rbind(display_df, data.frame(
          Value    = .jst_label_system_missing,
          Freq     = fmt_int(na_row$Freq),
          TotalPct = fmt_pct(na_row$TotalPct),
          ValidPct = "--",
          CumPct   = "--",
          stringsAsFactors = FALSE))
      }
    }

    # Total row (always; no Valid % or Cum. %)
    display_df <- rbind(display_df, data.frame(
      Value = "", Freq = "", TotalPct = "",
      ValidPct = "", CumPct = "", stringsAsFactors = FALSE))
    display_df <- rbind(display_df, data.frame(
      Value    = "Total",
      Freq     = as.character(total_count),
      TotalPct = "100.00",
      ValidPct = "",
      CumPct   = "",
      stringsAsFactors = FALSE))

    .jst_print_table(display_df,
                     col.names = c("", "Freq", "Total %", "Valid %", "Cum. %"),
                     row.names = FALSE,
                     align     = c("l", "r", "r", "r", "r"))
    cat("\n")
  }

  cat("\n")

  ret <- list(
    frequencies = results,
    sample_info = sample_info
  )
  class(ret) <- "jst_freq"
  invisible(ret)
}


#' Data screening overview
#'
#' Provides a quick overview of a data frame for screening. A red "Data
#' Screening" title is printed first, then a short header block (case and
#' variable counts, cases with missing data, variables with outliers),
#' followed by up to three tables: a Variable Types table (Base R storage
#' type, the jstats analysis-role class, an optional sub-class, and distinct-
#' value counts), a Missing Data & Outliers table, and — when variable labels
#' are shown — a Variable Labels table last. Handles haven-labelled and
#' date/time variables gracefully.
#'
#' The jstats Class column reports how the package treats each variable in
#' analyses (Numeric, Categorical, Numbers-as-text, Date-time, Unsupported),
#' in contrast to the Base R Type column's storage view; the same
#' classification gates outlier screening, so only Numeric-class variables
#' are SD-screened and the Outliers cell is left blank for the rest. Zero
#' counts are shown blank so only affected variables carry numbers; a column
#' (or the whole Missing/Outliers table) is omitted entirely when nothing is
#' flagged, and the header count lines explain the omission.
#'
#' When variable names are supplied, only those variables are screened. When
#' omitted, all variables in the data frame are screened. If a \code{subset}
#' expression references variables not already in the screening list, they
#' are included automatically.
#'
#' @param data A data frame.
#' @param ... Optional unquoted variable names to screen. If omitted,
#'   all variables in the data frame are screened.
#' @param outlier.sd Numeric. Number of standard deviations from the mean
#'   to flag as potential outliers (Numeric-class variables only). Default
#'   is 3.
#' @param subset An optional unquoted logical expression (e.g.
#'   \code{Group == 1}) to subset cases for this call only. Applied after
#'   jcomplete and jsubset. Does not affect other function calls.
#' @param labels Logical or NULL. If TRUE, prints the Variable Labels table
#'   (last) when labels are available. If FALSE, suppresses it. If NULL
#'   (default), defers to \code{joutput()}'s \code{var.labels} setting.
#' @param types Logical. If TRUE (default), prints the Variable Types table.
#'   Set FALSE to suppress it.
#' @param issues Logical. If TRUE (default), prints the Missing Data &
#'   Outliers table, which lists only the variables that actually have
#'   missing data or flagged outliers (clean variables are omitted). Set
#'   FALSE to suppress the table entirely. Suppressing \code{types},
#'   \code{issues}, and \code{labels} together leaves only the header block.
#' @param r.type Logical. If TRUE, adds a "Base R Type" column (numeric /
#'   haven_labelled / factor / character / date-time) to the Variable Types
#'   table, showing each variable's storage type alongside its jstats class.
#'   Default is FALSE: the storage type is expert detail (its main signal is
#'   "this variable carries value labels / came from SPSS or Stata"), so it
#'   is opt-in rather than shown by default. The returned data frame always
#'   includes it regardless of this setting.
#'
#' @return Invisibly returns a data frame of the screening results, with one
#'   row per variable and columns including the Base R type, the jstats
#'   \code{Class} and \code{SubClass}, distinct-value count, missing count
#'   and percentage, and the outlier count (NA for non-Numeric variables).
#'   The returned values are the raw counts; only the printed tables blank
#'   zeros and omit clean rows.
#'
#' @examples
#' # With explicit data frame
#' jscreen(mtcars)
#' jscreen(mtcars, outlier.sd = 2.5)
#'
#' # Show the Base R storage type column
#' jscreen(mtcars, r.type = TRUE)
#'
#' # Suppress tables (header block only)
#' jscreen(mtcars, types = FALSE, issues = FALSE)
#'
#' # Using juse() default
#' juse(mtcars)
#' jscreen()
#' jscreen(mpg, hp, wt)
#' jscreen(mpg, hp, wt, subset = am == 1)
#'
#' @seealso \code{\link{JeffsStatTools}} for the package overview,
#'   workflow conventions, and complete function listing.
#'
#' @export
jscreen <- function(data, ..., outlier.sd = 3, subset = NULL, labels = NULL,
                    types = TRUE, issues = TRUE, r.type = FALSE) {

  # Resolve the first argument: explicit data frame, juse default,
  # or bare-symbol-as-variable-name (leading comma omitted).
  arg1 <- .jst_resolve_first_arg(
    data_sub      = substitute(data),
    data_missing  = missing(data),
    fn_name       = "jscreen",
    envir         = parent.frame(),
    accept_vector = FALSE
  )

  data              <- arg1$data
  .jst_data_name    <- arg1$name
  .jst_default_used <- arg1$mode %in% c("default", "symbol_with_default")

  # Capture subset expression before evaluation
  subset_expr <- substitute(subset)

  # Determine which variables to screen
  variables <- rlang::enquos(...)

  # Leading-comma-omitted: prepend the captured symbol to variables list
  if (arg1$mode == "symbol_with_default") {
    extra_quo <- rlang::new_quosure(arg1$first_arg_sub,
                                    env = parent.frame())
    variables <- c(list(extra_quo), variables)
    class(variables) <- "quosures"
  }

  if (length(variables) > 0) {
    var_names <- vapply(variables, rlang::quo_name, character(1))
    .jst_check_vars(data, var_names, .jst_data_name)

    # Auto-include variables from subset expression
    if (!is.null(subset_expr)) {
      subset_vars <- all.vars(subset_expr)
      extra_vars  <- setdiff(subset_vars, var_names)
      extra_vars  <- extra_vars[extra_vars %in% names(data)]
      if (length(extra_vars) > 0) {
        var_names <- c(var_names, extra_vars)
      }
    }

    data <- data[, var_names, drop = FALSE]
  }

  # Red title
  .cat_red("Data Screening\n")
  if (.jst_default_used) .jst_default_note(.jst_data_name)

  # Apply data pipeline (jcomplete, jsubset, subset)
  pipeline <- .jst_apply_pipeline(data, .jst_data_name, .jst_default_used,
                                  subset_expr = subset_expr, envir = parent.frame())
  data     <- pipeline$data
  .jst_print_msgs(pipeline$msgs)

  # POSIXlt columns are list-backed; stats::complete.cases() and unique()
  # below either abort or misbehave on them. Capture each column's original
  # class BEFORE coercing, then coerce any POSIXlt column to atomic POSIXct
  # (same instants) so screening degrades gracefully instead of erroring.
  # as.POSIXct() drops both the POSIXlt class and the `label` attribute, so
  # the captured class keeps the displayed Type honest ("POSIXlt, POSIXt",
  # not the coerced "POSIXct, POSIXt") and the label is re-attached so the
  # column still appears in the Variable Labels list --- mirrors the
  # pre-coercion capture jfreq already does. (Session 47; honesty fix
  # Session 50)
  orig_classes <- lapply(data, class)
  lt_cols      <- vapply(data, function(col) inherits(col, "POSIXlt"), logical(1))
  if (any(lt_cols)) {
    for (nm in names(data)[lt_cols]) {
      lab        <- labelled::var_label(data[[nm]])
      data[[nm]] <- .jst_posixlt_to_posixct(data[[nm]])
      if (!is.null(lab)) labelled::var_label(data[[nm]]) <- lab
    }
  }

  # Resolve display toggle for the Variable Labels table.
  labels <- .jst_resolve_toggle("var.labels", labels)

  n_cases   <- nrow(data)
  n_vars    <- ncol(data)
  var_names <- names(data)

  # -- Per-variable screening rows -------------------------------------------
  screen_rows <- lapply(var_names, function(v) {
    col <- data[[v]]

    # Base R Type: the storage view (numeric / haven_labelled / factor /
    # character / date-time / ...). Distinct from the jstats Class below.
    var_type <- if (haven::is.labelled(col)) {
      "haven_labelled"
    } else if (is.factor(col)) {
      "factor"
    } else if (is.numeric(col)) {
      "numeric"
    } else if (is.character(col)) {
      "character"
    } else {
      # Pre-coercion class so a POSIXlt column coerced to POSIXct above still
      # reports its original Type. (Session 50)
      paste(orig_classes[[v]], collapse = ", ")
    }

    # jstats analysis-role classification via the single resolver. The same
    # resolver gates outlier screening (Numeric only), so the Class column
    # and the Outliers column cannot disagree. (Session 51)
    jc          <- .jst_jstats_class(col)
    n_missing   <- sum(is.na(col))
    pct_missing <- round(n_missing / n_cases * 100, 1)
    n_unique    <- length(unique(col[!is.na(col)]))

    # SD-outlier screening applies only to Numeric-class variables. For every
    # other class (Categorical including dichotomies, Numbers-as-text,
    # Date-time, Unsupported) the >SD rule is meaningless, so the Outliers
    # cell stays blank (NA) and the Class column explains why. (Session 51)
    n_outliers <- NA_integer_
    if (jc$class == "Numeric") {
      num_col <- .jst_as_numeric(col)
      m <- mean(num_col, na.rm = TRUE)
      s <- stats::sd(num_col, na.rm = TRUE)
      n_outliers <- if (!is.na(s) && s > 0) {
        as.integer(sum(abs(num_col - m) > outlier.sd * s, na.rm = TRUE))
      } else {
        0L
      }
    }

    data.frame(
      Variable    = v,
      Type        = var_type,
      Class       = jc$class,
      SubClass    = jc$subclass,
      Unique      = n_unique,
      Missing     = n_missing,
      Pct_Missing = pct_missing,
      Outliers    = n_outliers,
      stringsAsFactors = FALSE
    )
  })

  screen_table <- do.call(rbind, screen_rows)

  # -- Header block ----------------------------------------------------------
  # "Cases with missing data" = rows with >= 1 missing value (the listwise-
  # deletion magnitude). "Variables with outliers" = columns with >= 1 flagged
  # outlier (outliers are inherently per-variable, so the unit is variables).
  # Both lines always print: a 0 on either line is what explains a dropped
  # column (or the dropped Missing/Outliers table) below. (Session 51)
  n_cases_missing <- sum(!stats::complete.cases(data))
  n_vars_outliers <- sum(!is.na(screen_table$Outliers) & screen_table$Outliers > 0)

  cat("  Cases:", n_cases, "\n")
  cat("  Variables:", n_vars, "\n")
  cat("  Cases with missing data:", n_cases_missing, "\n")
  cat("  Variables with outliers:", n_vars_outliers, "\n")

  any_missing  <- any(screen_table$Missing > 0)
  any_outliers <- n_vars_outliers > 0
  any_subclass <- any(nzchar(screen_table$SubClass))

  # -- Table 1: Variable Types -----------------------------------------------
  # Base R Type column is opt-in (r.type = TRUE); Sub-class column appears
  # only when at least one variable has a sub-class.
  if (isTRUE(types)) {
    cols  <- "Variable"
    heads <- "Variable"
    if (isTRUE(r.type)) {
      cols  <- c(cols, "Type")
      heads <- c(heads, "Base R Type")
    }
    cols  <- c(cols, "Class")
    heads <- c(heads, "jstats Class")
    if (any_subclass) {
      cols  <- c(cols, "SubClass")
      heads <- c(heads, "Sub-class")
    }
    cols  <- c(cols, "Unique")
    heads <- c(heads, "Unique Values")
    cat("\n")
    .jst_print_table(screen_table[, cols, drop = FALSE],
                     caption   = "Variable Types",
                     col.names = heads,
                     row.names = FALSE)
  }

  # -- Table 2: Missing Data & Outliers --------------------------------------
  # Lists only the variables that actually have missing data or a flagged
  # outlier (clean variables are omitted, so the table is a short "needs
  # attention" view). Within the shown rows, zeros are blanked (set to NA,
  # which .jst_print_table renders empty). The Missing/% Missing pair is
  # dropped when nothing is missing anywhere, the Outliers column when nothing
  # is flagged, and the whole table when both are clean (the header count
  # lines already say so).
  if (isTRUE(issues) && (any_missing || any_outliers)) {
    flagged <- screen_table$Missing > 0 |
               (!is.na(screen_table$Outliers) & screen_table$Outliers > 0)
    st    <- screen_table[flagged, , drop = FALSE]
    t2    <- data.frame(Variable = st$Variable, stringsAsFactors = FALSE)
    heads <- "Variable"
    if (any_missing) {
      miss <- st$Missing
      pct  <- st$Pct_Missing
      pct[miss == 0]  <- NA_real_
      miss[miss == 0] <- NA_integer_
      t2$Missing     <- miss
      t2$Pct_Missing <- pct
      heads <- c(heads, "Missing", "% Missing")
    }
    if (any_outliers) {
      out <- st$Outliers
      out[!is.na(out) & out == 0] <- NA_integer_
      t2$Outliers <- out
      heads <- c(heads, "Outliers")
    }
    cat("\n")
    .jst_print_table(t2,
                     caption   = paste0("Missing Data & Outliers (outliers > ",
                                        outlier.sd, " SD from mean)"),
                     col.names = heads,
                     row.names = FALSE)
  }

  # -- Table 3: Variable Labels (last; only when toggled on) -----------------
  if (isTRUE(labels)) {
    cat("\n")
    .print_var_labels(data, var_names)
  }

  cat("\n")
  invisible(screen_table)
}


# =============================================================================
#  INFERENCE / GROUP COMPARISON
# =============================================================================

# -- jt -----------------------------------------------------------------------

#' Independent samples or paired samples t-test
#'
#' Runs a t-test and prints formatted group descriptives and test results.
#' By default, runs the traditional Student's independent samples t-test
#' assuming equal variances. Optional parameters provide Welch's correction,
#' paired samples, effect size (Cohen's d), Levene's test, and confidence
#' interval for the mean difference. Handles haven-labelled, numeric, and
#' factor grouping variables. For haven-labelled variables, numeric codes
#' are displayed alongside labels in the group descriptives table.
#'
#' A red title identifying the test type is printed first, followed by
#' variable labels (if present), then the results tables.
#'
#' @param formula A formula of the form \code{DV ~ Group}.
#' @param data A data frame containing variables referenced in \code{formula}.
#' @param paired Logical. If TRUE, runs a paired samples t-test. The two
#'   groups must have equal sample sizes. Default is FALSE.
#' @param welch Logical. If FALSE (default), runs Student's t-test
#'   (equal variances assumed). If TRUE, runs Welch's t-test. Ignored
#'   when paired = TRUE.
#' @param effect.size Logical or NULL. If TRUE, prints Cohen's d. If NULL
#'   (default), defers to \code{joutput()} session setting.
#' @param levene Logical or NULL. If TRUE, prints Levene's test for homogeneity
#'   of variance. Ignored when paired = TRUE. If NULL (default), defers to
#'   \code{joutput()}.
#' @param ci Logical or NULL. If TRUE, adds 95\% confidence interval for the
#'   mean difference. If NULL (default), defers to \code{joutput()}.
#' @param subset An optional unquoted logical expression (e.g.
#'   \code{Group == 1}) to subset cases for this call only. Applied after
#'   jcomplete and jsubset. Does not affect other function calls.
#' @param labels Logical. If TRUE (default), prints variable labels
#'   when available.
#' @param full Logical. If TRUE, turns on effect.size, levene, and ci
#'   all at once. Does not override explicit FALSE values.
#'
#' @return Invisibly returns a list of class \code{jst_ttest} containing:
#'   \code{model} (the \code{t.test} result), \code{model_frame} (the analysis
#'   data frame used for plotting), \code{test_type}, \code{formula},
#'   \code{descriptives}, \code{t}, \code{df}, \code{p}, \code{mean_difference},
#'   \code{ci} (95\% CI), \code{cohens_d}, \code{d_label}, \code{n}, and
#'   \code{sample_info} (pipeline and missing data counts).
#'
#' @examples
#' # With explicit data frame
#' jt(mpg ~ am, data = mtcars)
#' jt(mpg ~ am, data = mtcars, welch = TRUE)
#' jt(mpg ~ am, data = mtcars, full = TRUE)
#'
#' # Using juse() default
#' juse(mtcars)
#' jt(mpg ~ am)
#' jt(mpg ~ am, full = TRUE)
#'
#' @seealso \code{\link{JeffsStatTools}} for the package overview,
#'   workflow conventions, and complete function listing.
#'
#' @export
#' @importFrom stats t.test sd qt
#' @param case.processing.detail Per-call override of the Case
#'   Processing Summary detail tier: one of \code{"none"},
#'   \code{"totals"}, or \code{"per_code"}. \code{NULL} (default)
#'   uses the active \code{joutput()} level default.
jt <- function(formula, data, paired = FALSE, welch = FALSE,
               effect.size = NULL, levene = NULL, ci = NULL,
               subset = NULL, labels = NULL,
               case.processing.detail = NULL, full = FALSE) {

  # Resolve default data frame if not specified
  .jst_default_used <- FALSE
  .jst_data_name    <- NULL
  if (missing(data)) {
    resolved <- .jst_resolve_data(envir = parent.frame())
    data <- resolved$data
    .jst_default_used <- TRUE
    .jst_data_name    <- resolved$name
  } else {
    .jst_data_name <- deparse(substitute(data))
  }

  if (full) {
    if (is.null(effect.size)) effect.size <- TRUE
    if (is.null(levene))      levene      <- TRUE
    if (is.null(ci))          ci          <- TRUE
  }

  # Resolve display toggles: per-call > joutput() toggle > joutput() level
  effect.size <- .jst_resolve_toggle("effect.size", effect.size)
  ci          <- .jst_resolve_toggle("ci",          ci)
  levene      <- .jst_resolve_toggle("levene",      levene)
  # Red title - determined before any output
  if (paired) {
    .cat_red("Paired Samples T-Test\n")
  } else if (welch) {
    .cat_red("Welch's Independent Samples T-Test\n")
  } else {
    .cat_red("Independent Samples T-Test\n")
  }
  if (.jst_default_used) .jst_default_note(.jst_data_name)

  # Apply data pipeline (jcomplete, jsubset, subset)
  subset_expr <- substitute(subset)
  pipeline <- .jst_apply_pipeline(data, .jst_data_name, .jst_default_used,
                                  subset_expr = subset_expr, envir = parent.frame())
  data     <- pipeline$data
  .jst_print_msgs(pipeline$msgs)

  terms      <- all.vars(formula)
  dv_name    <- terms[1]
  group_name <- terms[2]

  .jst_check_vars(data, terms, .jst_data_name)
  # Type gate (Session 46): refuse a date DV (would coerce silently to a day
  # count) or a text/complex DV (would crash); grouping variable may be
  # categorical. See .jst_check_analysis_var.
  .jst_check_analysis_var(data[[terms[1L]]], terms[1L], TRUE, "a t-test")
  for (.gv in terms[-1L]) .jst_check_analysis_var(data[[.gv]], .gv, FALSE, "a t-test")

  # Build analysis-level data frame (listwise on all formula vars) and
  # sample_info early so the Case Processing Summary can use them.
  mf <- data[stats::complete.cases(data[, terms, drop = FALSE]),
             terms, drop = FALSE]

  sample_info <- .jst_build_sample_info(
    pipeline_counts = pipeline$pipeline_counts,
    data            = pipeline$data,
    analysis_vars   = terms,
    n_analysis      = nrow(mf)
  )

  # Case Processing Summary
  .jst_print_case_processing(sample_info, analysis_type = "listwise", detail = case.processing.detail)


  group_var   <- data[[group_name]]
  is_labelled <- haven::is.labelled(group_var)
  if (is_labelled) {
    original_codes <- sort(unique(.jst_as_numeric(group_var[!is.na(group_var)])))
  }

  if (is_labelled) {
    data[[group_name]] <- haven::as_factor(group_var)
  } else if (!is.factor(group_var)) {
    data[[group_name]] <- factor(group_var)
  }

  # Drop empty factor levels (pipeline filtering may leave empty levels)
  data[[group_name]] <- droplevels(data[[group_name]])

  n_levels <- nlevels(data[[group_name]])
  if (n_levels != 2) {
    # Build context-aware error message
    active_steps <- character(0)
    if (.jst_default_used) {
      cs <- .jst_get_complete(.jst_data_name)
      if (!is.null(cs) && cs$active) active_steps <- c(active_steps, "jcomplete")
      fs <- .jst_get_filter(.jst_data_name)
      if (!is.null(fs) && fs$active) active_steps <- c(active_steps,
                                                       paste0("jsubset (", fs$expr_str, ")"))
    }
    if (length(active_steps) > 0) {
      stop(paste0("'", group_name, "' has ", n_levels,
                  " category(ies) after applying ", paste(active_steps, collapse = " and "),
                  ". A t-test requires exactly 2. ",
                  "Check whether your jsubset or jcomplete settings ",
                  "are excluding one of the groups."), call. = FALSE)
    } else {
      stop(paste0("'", group_name, "' has ", n_levels,
                  " categories. A t-test requires exactly 2. ",
                  "Use jaov() for more than 2 categories."), call. = FALSE)
    }
  }

  if (haven::is.labelled(data[[dv_name]])) {
    data[[dv_name]] <- .jst_as_numeric(data[[dv_name]])
  }

  levels      <- levels(data[[group_name]])
  group1_data <- data[[dv_name]][data[[group_name]] == levels[1]]
  group2_data <- data[[dv_name]][data[[group_name]] == levels[2]]
  group1_data <- group1_data[!is.na(group1_data)]
  group2_data <- group2_data[!is.na(group2_data)]

  if (paired && length(group1_data) != length(group2_data)) {
    stop("Paired t-test requires equal sample sizes in both groups.", call. = FALSE)
  }

  if (.jst_resolve_toggle("var.labels", labels)) {
    .print_var_labels(data, c(dv_name, group_name))
  }

  # Levene's test
  if (levene && !paired) {
    group_factor  <- data[[group_name]]
    dv_vals       <- data[[dv_name]]
    group_means   <- tapply(dv_vals, group_factor, mean, na.rm = TRUE)
    abs_devs      <- abs(dv_vals - group_means[group_factor])
    levene_model  <- stats::aov(abs_devs ~ group_factor)
    levene_result <- summary(levene_model)[[1]]
    levene_f      <- round(levene_result$`F value`[1], 3)
    levene_p      <- levene_result$`Pr(>F)`[1]
    levene_p_fmt  <- if (!is.na(levene_p) && levene_p < 0.001) "<.001" else sprintf("%.3f", levene_p)

    levene_table <- data.frame(
      F_value = levene_f,
      df1     = levene_result$Df[1],
      df2     = levene_result$Df[2],
      p_value = levene_p_fmt,
      stringsAsFactors = FALSE,
      row.names = NULL
    )

    .jst_print_table(levene_table,
                     caption = "Levene's Test for Homogeneity of Variance",
                     col.names = c("F", "df1", "df2", "p"),
                     row.names = FALSE)

    # Interpretive note (only when significant and not already using Welch)
    if (!is.na(levene_p) && levene_p < 0.05 && !welch) {
      group_ns       <- tapply(dv_vals, group_factor, function(x) sum(!is.na(x)))
      size_ratio     <- max(group_ns) / min(group_ns)
      balanced       <- size_ratio <= 1.5
      levene_p_note  <- if (levene_p < 0.001) "<.001" else sprintf("%.3f", levene_p)
      if (balanced) {
        cat("Note: Levene's test is significant (p = ", levene_p_note,
            "), but group sizes are approximately equal\n",
            "so the standard test remains appropriate.\n", sep = "")
      } else {
        cat("Note: Levene's test is significant (p = ", levene_p_note,
            "), suggesting unequal variances.\n",
            "With unequal group sizes this may affect results \u2014 consider welch = TRUE.\n",
            sep = "")
      }
    }
    cat("\n")
  } else if (levene && paired) {
    cat("Note: Levene's test is not applicable for paired samples.\n\n")
  }

  # Group descriptives
  if (is_labelled) {
    group_labels <- paste0(original_codes, ": ", levels)
  } else {
    group_labels <- levels
  }

  desc_table <- data.frame(
    Group = group_labels,
    N     = c(length(group1_data), length(group2_data)),
    Mean  = round(c(mean(group1_data), mean(group2_data)), 3),
    SD    = round(c(sd(group1_data),   sd(group2_data)),   3),
    stringsAsFactors = FALSE
  )

  .jst_print_table(desc_table,
                   caption = paste("Group Descriptives:", dv_name, "by", group_name),
                   row.names = FALSE)
  cat("\n")

  # Run t-test
  if (paired) {
    result <- t.test(group1_data, group2_data, paired = TRUE)
  } else {
    result <- t.test(formula, data = data, var.equal = !welch)
  }

  p_val <- result$p.value
  p_fmt <- if (!is.na(p_val) && p_val < 0.001) "<.001" else sprintf("%.3f", p_val)

  test_table <- data.frame(
    t               = round(result$statistic, 3),
    df              = round(result$parameter, 1),
    p               = p_fmt,
    Mean_Difference = round(mean(group1_data) - mean(group2_data), 3),
    stringsAsFactors = FALSE,
    row.names = NULL
  )

  if (ci) {
    test_table$CI_Lower <- round(result$conf.int[1], 3)
    test_table$CI_Upper <- round(result$conf.int[2], 3)
  }

  if (paired) {
    test_label <- "Paired Samples T-Test Results"
  } else if (welch) {
    test_label <- "Welch's T-Test Results (equal variances not assumed)"
  } else {
    test_label <- "Independent Samples T-Test Results (equal variances assumed)"
  }

  if (ci) {
    .jst_print_table(test_table,
                     caption = test_label,
                     col.names = c("t", "df", "p", "Mean Difference",
                                   "95% CI Lower", "95% CI Upper"),
                     row.names = FALSE)
  } else {
    .jst_print_table(test_table,
                     caption = test_label,
                     col.names = c("t", "df", "p", "Mean Difference"),
                     row.names = FALSE)
  }

  # Effect size (Cohen's d) -- always computed, displayed only when requested
  n1 <- length(group1_data)
  n2 <- length(group2_data)
  m1 <- mean(group1_data)
  m2 <- mean(group2_data)
  s1 <- sd(group1_data)
  s2 <- sd(group2_data)

  if (paired) {
    diffs    <- group1_data - group2_data
    cohens_d <- mean(diffs) / sd(diffs)
    d_label  <- "Cohen's dz (paired)"
  } else {
    sp       <- sqrt(((n1 - 1) * s1^2 + (n2 - 1) * s2^2) / (n1 + n2 - 2))
    cohens_d <- (m1 - m2) / sp
    d_label  <- "Cohen's d"
  }

  if (effect.size) {
    cat(paste0("\n", d_label, ": ", round(cohens_d, 3), "\n"))
  }

  n_analysis <- nrow(mf)

  cat("\n")
  ret <- list(
    model           = result,
    model_frame     = mf,
    test_type       = if (paired) "paired" else if (welch) "welch" else "student",
    formula         = formula,
    descriptives    = desc_table,
    t               = unname(result$statistic),
    df              = unname(result$parameter),
    p               = result$p.value,
    mean_difference = m1 - m2,
    ci              = c(lower = result$conf.int[1], upper = result$conf.int[2]),
    cohens_d        = cohens_d,
    d_label         = d_label,
    n               = n_analysis,
    sample_info     = sample_info
  )
  class(ret) <- "jst_ttest"
  invisible(ret)
}


# -- jaov ---------------------------------------------------------------------

#' One-way ANOVA (traditional or Welch method)
#'
#' Runs a one-way ANOVA and prints a formatted group descriptives table
#' followed by an ANOVA table. By default, runs the traditional ANOVA
#' assuming equal variances. Optional parameters provide post-hoc tests,
#' effect size, Levene's test, and confidence intervals. Set welch = TRUE
#' for the Welch correction when equal variances cannot be assumed.
#' Handles haven-labelled, numeric, and factor grouping variables.
#' For haven-labelled variables, numeric codes are displayed alongside
#' labels in the group descriptives table.
#'
#' A red title identifying the test type is printed first, followed by
#' variable labels (if present), then the results tables.
#'
#' @param formula A formula of the form \code{DV ~ Group}.
#' @param data A data frame containing variables referenced in \code{formula}.
#' @param welch Logical. If FALSE (default), runs traditional ANOVA.
#'   If TRUE, runs Welch's ANOVA (does not assume equal variances).
#' @param posthoc Logical or NULL. If TRUE, prints Tukey HSD pairwise comparisons.
#'   Not available when welch = TRUE. If NULL (default), defers to
#'   \code{joutput()}.
#' @param effect.size Logical or NULL. If TRUE, prints eta-squared. If NULL
#'   (default), defers to \code{joutput()}.
#' @param levene Logical or NULL. If TRUE, prints Levene's test for homogeneity
#'   of variance. If NULL (default), defers to \code{joutput()}.
#' @param ci Logical or NULL. If TRUE, adds 95\% confidence intervals to the
#'   group descriptives table. If NULL (default), defers to \code{joutput()}.
#' @param subset An optional unquoted logical expression (e.g.
#'   \code{Group == 1}) to subset cases for this call only. Applied after
#'   jcomplete and jsubset. Does not affect other function calls.
#' @param labels Logical. If TRUE (default), prints variable labels
#'   when available.
#' @param full Logical. If TRUE, turns on posthoc, effect.size, levene,
#'   and ci all at once. Does not override explicit FALSE values.
#'
#' @return Invisibly returns a list of class \code{jst_anova} containing:
#'   \code{model} (the \code{aov} or \code{oneway.test} object),
#'   \code{model_frame} (the analysis data frame used for plotting),
#'   \code{test_type}, \code{formula}, \code{descriptives}, \code{f},
#'   \code{df1}, \code{df2}, \code{p}, \code{eta_squared}, \code{n}, and
#'   \code{sample_info} (pipeline and missing data counts).
#'
#' @examples
#' # With explicit data frame
#' jaov(mpg ~ cyl, data = mtcars)
#' jaov(mpg ~ cyl, data = mtcars, welch = TRUE)
#' jaov(mpg ~ cyl, data = mtcars, full = TRUE)
#'
#' # Using juse() default
#' juse(mtcars)
#' jaov(mpg ~ cyl)
#' jaov(mpg ~ cyl, full = TRUE)
#'
#' @seealso \code{\link{JeffsStatTools}} for the package overview,
#'   workflow conventions, and complete function listing.
#'
#' @export
#' @importFrom stats aov oneway.test TukeyHSD qt
#' @param case.processing.detail Per-call override of the Case
#'   Processing Summary detail tier: one of \code{"none"},
#'   \code{"totals"}, or \code{"per_code"}. \code{NULL} (default)
#'   uses the active \code{joutput()} level default.
jaov <- function(formula, data, welch = FALSE, posthoc = NULL,
                 effect.size = NULL, levene = NULL, ci = NULL,
                 subset = NULL, labels = NULL,
                 case.processing.detail = NULL, full = FALSE) {

  # Resolve default data frame if not specified
  .jst_default_used <- FALSE
  .jst_data_name    <- NULL
  if (missing(data)) {
    resolved <- .jst_resolve_data(envir = parent.frame())
    data <- resolved$data
    .jst_default_used <- TRUE
    .jst_data_name    <- resolved$name
  } else {
    .jst_data_name <- deparse(substitute(data))
  }

  if (full) {
    if (is.null(posthoc))     posthoc     <- TRUE
    if (is.null(effect.size)) effect.size <- TRUE
    if (is.null(levene))      levene      <- TRUE
    if (is.null(ci))          ci          <- TRUE
  }

  # Resolve display toggles: per-call > joutput() toggle > joutput() level
  effect.size  <- .jst_resolve_toggle("effect.size", effect.size)
  ci           <- .jst_resolve_toggle("ci",          ci)
  levene       <- .jst_resolve_toggle("levene",      levene)
  posthoc      <- .jst_resolve_toggle("posthoc",     posthoc)
  # Red title
  if (welch) {
    .cat_red("Welch's One-Way ANOVA\n")
  } else {
    .cat_red("One-Way ANOVA\n")
  }
  if (.jst_default_used) .jst_default_note(.jst_data_name)

  # Apply data pipeline (jcomplete, jsubset, subset)
  subset_expr <- substitute(subset)
  pipeline <- .jst_apply_pipeline(data, .jst_data_name, .jst_default_used,
                                  subset_expr = subset_expr, envir = parent.frame())
  data     <- pipeline$data
  .jst_print_msgs(pipeline$msgs)

  terms      <- all.vars(formula)
  dv_name    <- terms[1]
  group_name <- terms[2]

  .jst_check_vars(data, terms, .jst_data_name)
  # Type gate (Session 46): response must be numeric; grouping variable may be
  # categorical. Date/time and complex/list/raw refused. See .jst_check_analysis_var.
  .jst_check_analysis_var(data[[terms[1L]]], terms[1L], TRUE, "an ANOVA")
  for (.gv in terms[-1L]) .jst_check_analysis_var(data[[.gv]], .gv, FALSE, "an ANOVA")

  # Build analysis-level data frame (listwise on all formula vars) and
  # sample_info early so the Case Processing Summary can use them.
  mf <- data[stats::complete.cases(data[, terms, drop = FALSE]),
             terms, drop = FALSE]

  sample_info <- .jst_build_sample_info(
    pipeline_counts = pipeline$pipeline_counts,
    data            = pipeline$data,
    analysis_vars   = terms,
    n_analysis      = nrow(mf)
  )

  # Case Processing Summary
  .jst_print_case_processing(sample_info, analysis_type = "listwise", detail = case.processing.detail)

  group_var   <- data[[group_name]]
  is_labelled <- haven::is.labelled(group_var)
  if (is_labelled) {
    original_codes <- sort(unique(.jst_as_numeric(group_var[!is.na(group_var)])))
  }

  if (is_labelled) {
    data[[group_name]] <- haven::as_factor(group_var)
  } else if (!is.factor(group_var)) {
    data[[group_name]] <- factor(group_var)
  }

  # Drop empty factor levels (pipeline filtering may leave empty levels)
  data[[group_name]] <- droplevels(data[[group_name]])

  # Check minimum group levels
  n_levels <- nlevels(data[[group_name]])
  if (n_levels < 2) {
    active_steps <- character(0)
    if (.jst_default_used) {
      cs <- .jst_get_complete(.jst_data_name)
      if (!is.null(cs) && cs$active) active_steps <- c(active_steps, "jcomplete")
      fs <- .jst_get_filter(.jst_data_name)
      if (!is.null(fs) && fs$active) active_steps <- c(active_steps,
                                                       paste0("jsubset (", fs$expr_str, ")"))
    }
    if (length(active_steps) > 0) {
      stop(paste0("'", group_name, "' has ", n_levels,
                  " category(ies) after applying ", paste(active_steps, collapse = " and "),
                  ". An ANOVA requires at least 2. ",
                  "Check whether your jsubset or jcomplete settings ",
                  "are excluding one or more groups."), call. = FALSE)
    } else {
      stop(paste0("'", group_name, "' has ", n_levels,
                  " category(ies). An ANOVA requires at least 2 groups."),
           call. = FALSE)
    }
  }

  if (haven::is.labelled(data[[dv_name]])) {
    data[[dv_name]] <- .jst_as_numeric(data[[dv_name]])
  }

  if (.jst_resolve_toggle("var.labels", labels)) {
    .print_var_labels(data, c(dv_name, group_name))
  }

  # Levene's test
  if (levene) {
    group_factor  <- data[[group_name]]
    dv_vals       <- data[[dv_name]]
    group_means   <- tapply(dv_vals, group_factor, mean, na.rm = TRUE)
    abs_devs      <- abs(dv_vals - group_means[group_factor])
    levene_model  <- stats::aov(abs_devs ~ group_factor)
    levene_result <- summary(levene_model)[[1]]
    levene_f      <- round(levene_result$`F value`[1], 3)
    levene_p      <- levene_result$`Pr(>F)`[1]
    levene_p_fmt  <- if (!is.na(levene_p) && levene_p < 0.001) "<.001" else sprintf("%.3f", levene_p)

    levene_table <- data.frame(
      F_value = levene_f,
      df1     = levene_result$Df[1],
      df2     = levene_result$Df[2],
      p_value = levene_p_fmt,
      stringsAsFactors = FALSE,
      row.names = NULL
    )

    .jst_print_table(levene_table,
                     caption = "Levene's Test for Homogeneity of Variance",
                     col.names = c("F", "df1", "df2", "p"),
                     row.names = FALSE)

    # Interpretive note (only when significant and not already using Welch)
    if (!is.na(levene_p) && levene_p < 0.05 && !welch) {
      group_ns       <- tapply(dv_vals, group_factor, function(x) sum(!is.na(x)))
      size_ratio     <- max(group_ns) / min(group_ns)
      balanced       <- size_ratio <= 1.5
      levene_p_note  <- if (levene_p < 0.001) "<.001" else sprintf("%.3f", levene_p)
      if (balanced) {
        cat("Note: Levene's test is significant (p = ", levene_p_note,
            "), but group sizes are approximately equal\n",
            "so the standard test remains appropriate.\n", sep = "")
      } else {
        cat("Note: Levene's test is significant (p = ", levene_p_note,
            "), suggesting unequal variances.\n",
            "With unequal group sizes this may affect results \u2014 consider welch = TRUE.\n",
            sep = "")
      }
    }
    cat("\n")
  }

  # Group descriptives
  levels    <- levels(data[[group_name]])
  desc_rows <- lapply(seq_along(levels), function(i) {
    lvl        <- levels[i]
    group_data <- data[[dv_name]][data[[group_name]] == lvl]
    group_data <- group_data[!is.na(group_data)]
    n <- length(group_data)
    m <- mean(group_data)
    s <- sd(group_data)

    group_label <- if (is_labelled) {
      paste0(original_codes[i], ": ", lvl)
    } else {
      lvl
    }

    row <- data.frame(
      Group = group_label,
      N     = n,
      Mean  = round(m, 3),
      SD    = round(s, 3),
      stringsAsFactors = FALSE
    )

    if (ci) {
      se     <- s / sqrt(n)
      t_crit <- stats::qt(0.975, df = n - 1)
      row$CI_Lower <- round(m - t_crit * se, 3)
      row$CI_Upper <- round(m + t_crit * se, 3)
    }

    row
  })
  desc_table <- do.call(rbind, desc_rows)

  if (ci) {
    .jst_print_table(desc_table,
                     caption = paste("Group Descriptives:", dv_name, "by", group_name),
                     col.names = c("Group", "N", "Mean", "SD",
                                   "95% CI Lower", "95% CI Upper"),
                     row.names = FALSE)
  } else {
    .jst_print_table(desc_table,
                     caption = paste("Group Descriptives:", dv_name, "by", group_name),
                     row.names = FALSE)
  }
  cat("\n")

  if (welch) {
    model <- oneway.test(formula, data = data, var.equal = FALSE)

    p_val <- model$p.value
    p_fmt <- if (!is.na(p_val) && p_val < 0.001) "<.001" else sprintf("%.3f", p_val)

    welch_table <- data.frame(
      F_value = round(model$statistic, 3),
      df1     = round(model$parameter[1], 1),
      df2     = round(model$parameter[2], 1),
      p_value = p_fmt,
      stringsAsFactors = FALSE,
      row.names = NULL
    )

    .jst_print_table(welch_table,
                     caption = paste("Welch's ANOVA:", dv_name, "by", group_name),
                     col.names = c("F", "df1", "df2", "p"),
                     row.names = FALSE)

    cat("\nNote: Sum of Squares and Mean Squares are not available for Welch's ANOVA.\n",
        "To obtain these, run jaov() without welch = TRUE.\n", sep = "")

    if (posthoc) {
      cat("\nNote: Tukey HSD post-hoc tests are not available with Welch's ANOVA.\n",
          "Run without welch = TRUE for post-hoc comparisons.\n", sep = "")
    }

    # Always compute eta-squared (from traditional SS decomposition)
    temp_model  <- stats::aov(formula, data = data)
    temp_result <- summary(temp_model)[[1]]
    eta_sq      <- temp_result$`Sum Sq`[1] / sum(temp_result$`Sum Sq`)

    if (effect.size) {
      cat("\nEta-squared:", round(eta_sq, 3), "\n")
      cat("(Note: Eta-squared is calculated from the traditional SS decomposition.)\n")
    }

    # Store F, df, p for the return object
    f_value <- unname(model$statistic)
    df1     <- unname(model$parameter[1])
    df2     <- unname(model$parameter[2])
    p_value <- model$p.value

  } else {
    model  <- aov(formula, data = data)
    result <- summary(model)[[1]]

    total_df <- sum(result$Df)
    total_ss <- sum(result$`Sum Sq`)

    p_val <- result$`Pr(>F)`[1]
    p_fmt <- if (!is.na(p_val) && p_val < 0.001) "<.001" else sprintf("%.3f", p_val)

    anova_table <- data.frame(
      Source         = c(group_name, "Residual", "Total"),
      df             = c(result$Df, total_df),
      Sum_of_Squares = round(c(result$`Sum Sq`, total_ss), 3),
      Mean_Square    = c(round(result$`Mean Sq`, 3), NA),
      F_value        = c(round(result$`F value`[1], 3), NA, NA),
      p_value        = c(p_fmt, NA, NA),
      stringsAsFactors = FALSE
    )

    .jst_print_table(anova_table,
                     caption = paste("ANOVA:", dv_name, "by", group_name),
                     col.names = c("Source", "df", "Sum of Squares",
                                   "Mean Square", "F", "p"),
                     row.names = FALSE)

    # Always compute eta-squared
    eta_sq <- result$`Sum Sq`[1] / sum(result$`Sum Sq`)

    if (effect.size) {
      cat("\nEta-squared:", round(eta_sq, 3), "\n")
    }

    if (posthoc) {
      tukey        <- stats::TukeyHSD(model)
      tukey_result <- as.data.frame(tukey[[1]])

      tukey_p     <- tukey_result$`p adj`
      tukey_p_fmt <- ifelse(!is.na(tukey_p) & tukey_p < 0.001, "<.001",
                            sprintf("%.3f", tukey_p))

      tukey_table <- data.frame(
        Comparison = rownames(tukey_result),
        Difference = round(tukey_result$diff, 3),
        CI_Lower   = round(tukey_result$lwr,  3),
        CI_Upper   = round(tukey_result$upr,  3),
        p_adj      = tukey_p_fmt,
        stringsAsFactors = FALSE,
        row.names  = NULL
      )

      cat("\n")
      .jst_print_table(tukey_table,
                       caption = "Tukey HSD Post-Hoc Comparisons",
                       col.names = c("Comparison", "Mean Difference",
                                     "95% CI Lower", "95% CI Upper",
                                     "p (adjusted)"),
                       row.names = FALSE)
    }

    # Store F, df, p for the return object
    f_value <- result$`F value`[1]
    df1     <- result$Df[1]
    df2     <- result$Df[2]
    p_value <- result$`Pr(>F)`[1]
  }

  n_analysis <- nrow(mf)

  cat("\n")
  ret <- list(
    model        = model,
    model_frame  = mf,
    test_type    = if (welch) "welch" else "traditional",
    formula      = formula,
    descriptives = desc_table,
    f            = f_value,
    df1          = df1,
    df2          = df2,
    p            = p_value,
    eta_squared  = eta_sq,
    n            = n_analysis,
    sample_info  = sample_info
  )
  class(ret) <- "jst_anova"
  invisible(ret)
}


#' Cross-tabulation with optional chi-square test of independence
#'
#' Produces a cross-tabulation of two categorical variables, showing
#' observed frequencies and row percentages by default. Column
#' percentages, expected frequencies, and a chi-square test of
#' independence are available via arguments. Handles haven-labelled,
#' numeric, factor, and character variables. For haven-labelled
#' variables, numeric codes are displayed alongside labels.
#'
#' A red "Cross-Tabulation" title is printed first, followed by
#' variable labels (if present), then the table and optional test results.
#'
#' @param formula A formula of the form \code{Row ~ Column}.
#' @param data A data frame containing variables referenced in \code{formula}.
#' @param chisq Logical. If TRUE, prints the chi-square test of independence
#'   below the cross-tabulation. Default is FALSE.
#' @param expected Logical. If TRUE, prints expected frequencies alongside
#'   observed. Default is FALSE.
#' @param row.pct Logical. If TRUE (default), shows row percentages.
#' @param col.pct Logical. If TRUE, shows column percentages. Default is FALSE.
#' @param subset An optional unquoted logical expression (e.g.
#'   \code{Group == 1}) to subset cases for this call only. Applied after
#'   jcomplete and jsubset. Does not affect other function calls.
#' @param labels Logical. If TRUE (default), prints variable labels
#'   when available.
#'
#' @return Invisibly returns a list of class \code{jst_crosstab} containing:
#'   \code{observed} (observed frequency table), \code{expected} (expected
#'   frequency table), \code{n} (total N), \code{model_frame} (the analysis
#'   data frame used for plotting), \code{sample_info} (pipeline and
#'   missing data counts), and if \code{chisq = TRUE}: \code{chi_square},
#'   \code{df}, and \code{p}.
#'
#' @examples
#' # Cross-tabulation only
#' jcrosstab(cyl ~ am, data = mtcars)
#'
#' # With chi-square test
#' jcrosstab(cyl ~ am, data = mtcars, chisq = TRUE)
#'
#' # With expected frequencies and column percentages
#' jcrosstab(cyl ~ am, data = mtcars, expected = TRUE, col.pct = TRUE)
#'
#' # Using juse() default
#' juse(mtcars)
#' jcrosstab(cyl ~ am)
#' jcrosstab(cyl ~ am, chisq = TRUE)
#'
#' @seealso \code{\link{JeffsStatTools}} for the package overview,
#'   workflow conventions, and complete function listing.
#'
#' @importFrom stats chisq.test
#' @export
#' @param case.processing.detail Per-call override of the Case
#'   Processing Summary detail tier: one of \code{"none"},
#'   \code{"totals"}, or \code{"per_code"}. \code{NULL} (default)
#'   uses the active \code{joutput()} level default.
jcrosstab <- function(formula, data, chisq = FALSE, expected = FALSE,
                      row.pct = TRUE, col.pct = FALSE, subset = NULL,
                      labels = NULL, case.processing.detail = NULL) {

  # Resolve default data frame if not specified
  .jst_default_used <- FALSE
  .jst_data_name    <- NULL
  if (missing(data)) {
    resolved <- .jst_resolve_data(envir = parent.frame())
    data <- resolved$data
    .jst_default_used <- TRUE
    .jst_data_name    <- resolved$name
  } else {
    .jst_data_name <- deparse(substitute(data))
  }

  terms    <- all.vars(formula)
  row_name <- terms[1]
  col_name <- terms[2]

  .jst_check_vars(data, terms, .jst_data_name)
  # Type gate (Session 46): both variables are categorical; refuse date/time
  # and complex/list/raw. See .jst_check_analysis_var.
  for (.gv in terms) .jst_check_analysis_var(data[[.gv]], .gv, FALSE, "a cross-tabulation")

  # Red title
  .cat_red("Cross-Tabulation\n")
  if (.jst_default_used) .jst_default_note(.jst_data_name)

  # Apply data pipeline (jcomplete, jsubset, subset)
  subset_expr <- substitute(subset)
  pipeline <- .jst_apply_pipeline(data, .jst_data_name, .jst_default_used,
                                  subset_expr = subset_expr, envir = parent.frame())
  data     <- pipeline$data
  .jst_print_msgs(pipeline$msgs)

  # Resolve display toggles
  # Build analysis-level data frame (listwise on Row + Column) and
  # sample_info early so the Case Processing Summary can use them.
  mf <- data[stats::complete.cases(data[, c(row_name, col_name), drop = FALSE]),
             c(row_name, col_name), drop = FALSE]

  sample_info <- .jst_build_sample_info(
    pipeline_counts = pipeline$pipeline_counts,
    data            = pipeline$data,
    analysis_vars   = c(row_name, col_name),
    n_analysis      = nrow(mf)
  )

  # Case Processing Summary
  .jst_print_case_processing(sample_info, analysis_type = "listwise", detail = case.processing.detail)

  row_var <- data[[row_name]]
  col_var <- data[[col_name]]

  row_labelled <- haven::is.labelled(row_var)
  col_labelled <- haven::is.labelled(col_var)

  if (row_labelled) {
    row_codes <- sort(unique(.jst_as_numeric(row_var[!is.na(row_var)])))
    row_var   <- haven::as_factor(row_var)
  } else if (!is.factor(row_var)) {
    row_var <- factor(row_var)
  }

  if (col_labelled) {
    col_codes <- sort(unique(.jst_as_numeric(col_var[!is.na(col_var)])))
    col_var   <- haven::as_factor(col_var)
  } else if (!is.factor(col_var)) {
    col_var <- factor(col_var)
  }

  if (.jst_resolve_toggle("var.labels", labels)) {
    .print_var_labels(data, c(row_name, col_name))
  }

  # Drop empty factor levels (pipeline filtering may leave empty levels)
  row_var <- droplevels(row_var)
  col_var <- droplevels(col_var)

  row_levels <- levels(row_var)
  col_levels <- levels(col_var)

  # Check minimum levels
  for (check_info in list(list(name = row_name, lvls = row_levels),
                          list(name = col_name, lvls = col_levels))) {
    if (length(check_info$lvls) < 2) {
      active_steps <- character(0)
      if (.jst_default_used) {
        cs <- .jst_get_complete(.jst_data_name)
        if (!is.null(cs) && cs$active) active_steps <- c(active_steps, "jcomplete")
        fs <- .jst_get_filter(.jst_data_name)
        if (!is.null(fs) && fs$active) active_steps <- c(active_steps,
                                                         paste0("jsubset (", fs$expr_str, ")"))
      }
      context <- if (length(active_steps) > 0) {
        paste0(" after applying ", paste(active_steps, collapse = " and "))
      } else ""
      stop(paste0("'", check_info$name, "' has ", length(check_info$lvls),
                  " category(ies)", context,
                  ". A cross-tabulation requires at least 2 categories ",
                  "for each variable."), call. = FALSE)
    }
  }

  row_labels <- if (row_labelled) paste0(row_codes, ": ", row_levels) else row_levels
  col_labels <- if (col_labelled) paste0(col_codes, ": ", col_levels) else col_levels

  obs_table  <- table(row_var, col_var)
  chi_result <- suppressWarnings(stats::chisq.test(obs_table))
  exp_table  <- chi_result$expected

  p_val <- chi_result$p.value
  p_fmt <- if (!is.na(p_val) && p_val < 0.001) "<.001" else sprintf("%.3f", p_val)

  n_rows <- length(row_levels)
  n_cols <- length(col_levels)
  header <- c(row_name, col_labels, "Total")

  display_rows <- list()

  for (i in seq_len(n_rows)) {
    obs_vals  <- as.numeric(obs_table[i, ])
    row_total <- sum(obs_vals)
    display_rows <- c(display_rows,
                      list(c(row_labels[i], as.character(obs_vals),
                             as.character(row_total))))

    if (expected) {
      exp_vals     <- round(exp_table[i, ], 1)
      display_rows <- c(display_rows,
                        list(c("  (Expected)", sprintf("%.1f", exp_vals),
                               sprintf("%.1f", sum(exp_vals)))))
    }

    if (row.pct) {
      row_pcts     <- round(obs_vals / row_total * 100, 1)
      display_rows <- c(display_rows,
                        list(c("  (Row %)", sprintf("%.1f%%", row_pcts), "100.0%")))
    }

    if (col.pct) {
      col_totals    <- colSums(obs_table)
      col_pcts      <- round(obs_vals / col_totals * 100, 1)
      grand_total   <- sum(obs_table)
      col_pct_total <- round(row_total / grand_total * 100, 1)
      display_rows  <- c(display_rows,
                         list(c("  (Col %)", sprintf("%.1f%%", col_pcts),
                                sprintf("%.1f%%", col_pct_total))))
    }
  }

  col_totals  <- colSums(obs_table)
  grand_total <- sum(obs_table)
  display_rows <- c(display_rows,
                    list(c("Total", as.character(col_totals),
                           as.character(grand_total))))

  if (col.pct) {
    display_rows <- c(display_rows,
                      list(c("  (Col %)", rep("100.0%", n_cols), "100.0%")))
  }

  display_df           <- as.data.frame(do.call(rbind, display_rows),
                                        stringsAsFactors = FALSE)
  colnames(display_df) <- header

  .jst_print_table(display_df,
                   caption   = paste("Crosstab:", row_name, "by", col_name),
                   row.names = FALSE)
  cat("\n")

  # Chi-square test (only if requested)
  if (chisq) {
    chi_table <- data.frame(
      Chi_Square = round(chi_result$statistic, 3),
      df         = chi_result$parameter,
      p          = p_fmt,
      N          = grand_total,
      stringsAsFactors = FALSE,
      row.names  = NULL
    )

    .jst_print_table(chi_table,
                     caption   = "Chi-Square Test of Independence",
                     col.names = c("Chi-Square", "df", "p", "N"),
                     align     = c("c", "c", "c", "c"),
                     row.names = FALSE)

    min_expected <- min(exp_table)
    n_below_5    <- sum(exp_table < 5)
    if (n_below_5 > 0) {
      cat(paste0("\nNote: ", n_below_5, " cell(s) have expected frequencies less than 5 ",
                 "(minimum expected = ", round(min_expected, 1), "). ",
                 "Chi-square results may not be reliable.\n"))
    }
  }

  cat("\n")

  ret <- list(
    observed    = obs_table,
    expected    = exp_table,
    n           = grand_total,
    model_frame = mf,
    sample_info = sample_info
  )
  if (chisq) {
    ret$chi_square <- chi_result$statistic
    ret$df         <- chi_result$parameter
    ret$p          <- chi_result$p.value
  }
  class(ret) <- "jst_crosstab"
  invisible(ret)
}


# -- jcorr --------------------------------------------------------------------


# =============================================================================
#  CORRELATION AND REGRESSION
# =============================================================================


#' Bivariate correlation matrix with p values and pairwise N
#'
#' Computes pairwise correlations and prints a formatted lower-triangle
#' correlation matrix showing r, p values, and pairwise N for each pair.
#' Supports Pearson (default), Spearman, and Kendall methods.
#' Handles haven-labelled and factor variables with numeric levels.
#' Warns when variables may be categorical rather than continuous.
#'
#' A red title identifying the correlation method is printed first,
#' followed by variable labels (if present), then the matrix.
#'
#' @param data A data frame.
#' @param ... Unquoted variable names within \code{data}.
#' @param method Character. Correlation method: "pearson" (default),
#'   "spearman", or "kendall".
#' @param subset An optional unquoted logical expression (e.g.
#'   \code{Group == 1}) to subset cases for this call only. Applied after
#'   jcomplete and jsubset. Does not affect other function calls.
#' @param labels Logical. If TRUE (default), prints variable labels
#'   when available.
#'
#' @return Invisibly returns a list of class \code{jst_corr} containing:
#'   \code{r} (correlation matrix), \code{p} (p-value matrix),
#'   \code{n} (pairwise N matrix), \code{method}, \code{model_frame} (the
#'   analysis data frame used for plotting), and \code{sample_info}
#'   (pipeline and missing data counts).
#'
#' @examples
#' # With explicit data frame
#' jcorr(mtcars, mpg, hp, wt)
#' jcorr(mtcars, mpg, hp, wt, method = "spearman")
#'
#' # Using juse() default
#' juse(mtcars)
#' jcorr(mpg, hp, wt)
#'
#' @seealso \code{\link{JeffsStatTools}} for the package overview,
#'   workflow conventions, and complete function listing.
#'
#' @importFrom stats cor.test complete.cases
#' @export
#' @param case.processing.detail Per-call override of the Case
#'   Processing Summary detail tier: one of \code{"none"},
#'   \code{"totals"}, or \code{"per_code"}. \code{NULL} (default)
#'   uses the active \code{joutput()} level default.
jcorr <- function(data, ..., method = "pearson", subset = NULL, labels = NULL,
                  case.processing.detail = NULL) {

  # Resolve the first argument: explicit data frame, juse default,
  # or bare-symbol-as-variable-name (leading comma omitted).
  arg1 <- .jst_resolve_first_arg(
    data_sub      = substitute(data),
    data_missing  = missing(data),
    fn_name       = "jcorr",
    envir         = parent.frame(),
    accept_vector = FALSE
  )

  data              <- arg1$data
  .jst_data_name    <- arg1$name
  .jst_default_used <- arg1$mode %in% c("default", "symbol_with_default")

  variables <- rlang::enquos(...)

  # Leading-comma-omitted: prepend the captured symbol to variables list
  if (arg1$mode == "symbol_with_default") {
    extra_quo <- rlang::new_quosure(arg1$first_arg_sub,
                                    env = parent.frame())
    variables <- c(list(extra_quo), variables)
    class(variables) <- "quosures"
  }

  variable_names <- vapply(variables, rlang::quo_name, character(1))

  .jst_check_vars(data, variable_names, .jst_data_name)
  # Type gate (Session 46): correlation needs numeric variables; refuse text,
  # dates, and complex/list/raw up front (the loop below coerces the accepted
  # labelled / numeric-factor variables). See .jst_check_analysis_var.
  for (.gv in variable_names) .jst_check_analysis_var(data[[.gv]], .gv, TRUE, "a correlation")

  if (length(variable_names) < 2) {
    stop("jcorr() requires at least 2 variables. Only 1 was provided.", call. = FALSE)
  }

  method <- tolower(method)
  if (!method %in% c("pearson", "spearman", "kendall")) {
    stop("method must be 'pearson', 'spearman', or 'kendall'.", call. = FALSE)
  }

  method_label <- switch(method,
                         pearson  = "Pearson",
                         spearman = "Spearman",
                         kendall  = "Kendall")

  # Red title
  .cat_red(paste0(method_label, " Bivariate Correlations\n"))
  if (.jst_default_used) .jst_default_note(.jst_data_name)

  # Apply data pipeline (jcomplete, jsubset, subset)
  subset_expr <- substitute(subset)
  pipeline <- .jst_apply_pipeline(data, .jst_data_name, .jst_default_used,
                                  subset_expr = subset_expr, envir = parent.frame())
  data     <- pipeline$data
  .jst_print_msgs(pipeline$msgs)

  # Build sample_info early so the Case Processing Summary can use it.
  # jcorr uses pairwise deletion, not listwise.
  sample_info <- .jst_build_sample_info(
    pipeline_counts = pipeline$pipeline_counts,
    data            = pipeline$data,
    analysis_vars   = variable_names,
    n_analysis      = nrow(data)
  )

  # Case Processing Summary (jcorr is pairwise; the helper suppresses
  # the table when no pipeline stage was active).
  .jst_print_case_processing(sample_info, analysis_type = "pairwise", detail = case.processing.detail)

  cor_data <- data[, variable_names, drop = FALSE]

  for (v in variable_names) {
    # Hard errors — variable types that cannot be coerced to numeric for
    # correlation regardless of structure.
    if (is.character(cor_data[[v]])) {
      stop(paste0("'", v, "' is a character variable and cannot be used ",
                  "in a correlation. Use a numeric variable instead."), call. = FALSE)
    }
    if (is.factor(cor_data[[v]])) {
      numeric_check <- suppressWarnings(as.numeric(as.character(cor_data[[v]])))
      if (all(is.na(numeric_check[!is.na(cor_data[[v]])]))) {
        stop(paste0("'", v,
                    "' is a factor with text categories and cannot be used ",
                    "in a correlation. Use a numeric variable instead."), call. = FALSE)
      }
      cor_data[[v]] <- numeric_check
    }

    # Coerce labelled to numeric for correlation computation. The warning
    # decision is delegated to the unified classifier below.
    if (haven::is.labelled(cor_data[[v]])) {
      cor_data[[v]] <- .jst_as_numeric(cor_data[[v]])
    }

    # Categorical-like warning — uses the same classifier as jlm so that
    # haven-labelled variables with many distinct values (e.g. Income with
    # 10 broad categories) are NOT flagged, while small-range labelled or
    # whole-number 0-6 variables ARE flagged.
    if (.jst_is_discrete_integer(data[[v]], v, .jst_data_name)) {
      warning(paste0("'", v, "' has categorical-like structure ",
                     "(small-range integer or labelled values). Pearson ",
                     "correlations assume continuous/interval data. Verify ",
                     "this variable is appropriate for correlation."),
              call. = FALSE)
    }
  }

  n_vars   <- length(variable_names)
  r_matrix <- matrix(NA, n_vars, n_vars, dimnames = list(variable_names, variable_names))
  p_matrix <- matrix(NA, n_vars, n_vars, dimnames = list(variable_names, variable_names))
  n_matrix <- matrix(NA, n_vars, n_vars, dimnames = list(variable_names, variable_names))
  has_ties <- FALSE

  for (i in seq_len(n_vars)) {
    for (j in seq_len(n_vars)) {
      complete       <- stats::complete.cases(cor_data[[i]], cor_data[[j]])
      n_matrix[i, j] <- sum(complete)
      if (i == j) {
        r_matrix[i, j] <- 1
      } else if (n_matrix[i, j] > 2) {
        test            <- suppressWarnings(
          stats::cor.test(cor_data[[i]], cor_data[[j]], method = method)
        )
        r_matrix[i, j] <- test$estimate
        p_matrix[i, j] <- test$p.value
        if (method == "spearman") has_ties <- TRUE
      }
    }
  }

  display <- matrix("", n_vars, n_vars, dimnames = list(variable_names, variable_names))

  for (i in seq_len(n_vars)) {
    for (j in seq_len(n_vars)) {
      if (i == j) {
        display[i, j] <- "1"
      } else if (j < i) {
        r_fmt <- sprintf("%.3f", r_matrix[i, j])
        p_fmt <- if (!is.na(p_matrix[i, j]) && p_matrix[i, j] < 0.001) {
          "<.001"
        } else {
          sprintf("%.3f", p_matrix[i, j])
        }
        display[i, j] <- paste0(r_fmt, " (p=", p_fmt, ") N=", n_matrix[i, j])
      }
    }
  }

  display_df <- as.data.frame(display, stringsAsFactors = FALSE)

  if (.jst_resolve_toggle("var.labels", labels)) {
    .print_var_labels(data, variable_names)
  }

  .jst_print_table(display_df,
                   caption = paste0("Bivariate Correlations (", method_label, ")"))

  if (has_ties) {
    cat("\nNote: Spearman p-values are approximate due to tied values in the data.\n")
  }

  cat("\n")

  # Build analysis-level data frame for jplot() (2-variable scatter option)
  mf <- data[, variable_names, drop = FALSE]

  ret <- list(
    r           = r_matrix,
    p           = p_matrix,
    n           = n_matrix,
    method      = method,
    model_frame = mf,
    sample_info = sample_info
  )
  class(ret) <- "jst_corr"
  invisible(ret)
}


# -- Regression model helpers (jlm and jlogistic) -----------------------------

#' Internal helper: clean up factor coefficient names for output
#'
#' By default, R concatenates factor variable names with level names when
#' producing regression coefficient labels (e.g. "GenderRFemale"). This
#' helper inserts a separator between the variable name and level name for
#' readability (e.g. "GenderR-Female"). Only applies to factor IVs; numeric
#' dummy columns created by jdummy() are left unchanged since they are
#' already named clearly.
#'
#' @param coef_names Character vector of coefficient names from a fitted model.
#' @param data Data frame used to fit the model (post-conversion).
#' @param iv_names Character vector of IV names from the model formula.
#' @param sep Character. Separator to insert. Default is "-".
#'
#' @return Character vector of the same length as coef_names, with factor
#'   coefficient names separated.
#'
#' @keywords internal
.jst_clean_coef_names <- function(coef_names, data, iv_names, sep = "-") {
  cleaned <- coef_names
  for (v in iv_names) {
    if (!v %in% names(data)) next
    if (!is.factor(data[[v]])) next
    lvls <- levels(data[[v]])
    if (length(lvls) < 2) next
    for (lvl in lvls[-1]) {
      old_name <- paste0(v, lvl)
      new_name <- paste0(v, sep, lvl)
      cleaned[cleaned == old_name] <- new_name
    }
  }
  cleaned
}

#' Internal helper: compute VIF for a fitted linear model
#'
#' Computes Variance Inflation Factors from the model matrix correlation
#' structure. Returns a named numeric vector of VIF values for each
#' predictor (excluding the intercept). Returns NULL for bivariate models
#' (only one predictor) since VIF is not meaningful.
#'
#' @param model A fitted \code{lm} object.
#'
#' @return Named numeric vector of VIF values, or NULL for bivariate models.
#'
#' @keywords internal
.jst_compute_vif <- function(model) {
  X <- stats::model.matrix(model)[, -1, drop = FALSE]
  if (ncol(X) < 2) return(NULL)

  tryCatch({
    R <- stats::cor(X)
    vif_values <- diag(solve(R))
    names(vif_values) <- colnames(X)
    vif_values
  }, error = function(e) {
    warning("VIF could not be computed (possible perfect collinearity).",
            call. = FALSE)
    NULL
  })
}

#' Internal helper: produce diagnostic plots for a fitted linear model
#'
#' Generates five diagnostic plots using ggplot2. Each plot is printed
#' sequentially and appears in the RStudio Plots pane.
#'
#' @param model A fitted \code{lm} object.
#' @param which Character vector of plot types to produce. Options:
#'   "residuals" (residuals vs fitted), "qq" (normal Q-Q),
#'   "scale" (scale-location), "cooks" (Cook's distance),
#'   "leverage" (residuals vs leverage).
#' @param n_label Integer. Number of extreme points to label on each plot.
#'
#' @importFrom rlang .data
#' @keywords internal
.jst_plot_lm_diagnostics <- function(model, which, n_label = 3) {

  if (!requireNamespace("ggplot2", quietly = TRUE)) {
    cat("Note: Install ggplot2 for diagnostic plots: install.packages(\"ggplot2\")\n")
    return(invisible(NULL))
  }

  plots <- list()

  fitted_vals   <- stats::fitted(model)
  residuals_raw <- stats::residuals(model)
  std_resid     <- stats::rstandard(model)
  leverage      <- stats::hatvalues(model)
  cooks_d       <- stats::cooks.distance(model)
  obs_labels    <- names(fitted_vals)
  if (is.null(obs_labels)) obs_labels <- as.character(seq_along(fitted_vals))

  df <- data.frame(
    obs      = obs_labels,
    fitted   = fitted_vals,
    resid    = residuals_raw,
    std_resid = std_resid,
    leverage = leverage,
    cooks    = cooks_d,
    sqrt_std_resid = sqrt(abs(std_resid)),
    stringsAsFactors = FALSE
  )

  # Helper to get indices of top n extreme values
  top_n <- function(x, n) {
    if (length(x) <= n) return(seq_along(x))
    order(abs(x), decreasing = TRUE)[seq_len(n)]
  }

  # -- 1. Residuals vs Fitted -----------------------------------------------
  if ("residuals" %in% which) {
    idx <- top_n(df$resid, n_label)
    p <- ggplot2::ggplot(df, ggplot2::aes(x = .data$fitted, y = .data$resid)) +
      ggplot2::geom_point(alpha = 0.5) +
      ggplot2::geom_hline(yintercept = 0, linetype = "dashed", color = "red") +
      ggplot2::geom_smooth(method = "loess", se = FALSE, color = "steelblue",
                           formula = y ~ x) +
      ggplot2::geom_text(data = df[idx, ],
                         ggplot2::aes(label = .data$obs),
                         hjust = -0.2, size = 3, color = "red") +
      ggplot2::labs(title = "Residuals vs Fitted",
                    x = "Fitted Values", y = "Residuals") +
      ggplot2::theme_minimal()
    print(p)
    plots$residuals <- p
  }

  # -- 2. Normal Q-Q --------------------------------------------------------
  if ("qq" %in% which) {
    qq_data <- stats::qqnorm(df$std_resid, plot.it = FALSE)
    df_qq <- data.frame(
      theoretical = qq_data$x,
      sample      = qq_data$y,
      obs         = df$obs,
      stringsAsFactors = FALSE
    )
    idx <- top_n(df_qq$sample, n_label)
    p <- ggplot2::ggplot(df_qq, ggplot2::aes(x = .data$theoretical,
                                              y = .data$sample)) +
      ggplot2::geom_point(alpha = 0.5) +
      ggplot2::geom_abline(slope = 1, intercept = 0, linetype = "dashed",
                           color = "red") +
      ggplot2::geom_text(data = df_qq[idx, ],
                         ggplot2::aes(label = .data$obs),
                         hjust = -0.2, size = 3, color = "red") +
      ggplot2::labs(title = "Normal Q-Q",
                    x = "Theoretical Quantiles",
                    y = "Standardized Residuals") +
      ggplot2::theme_minimal()
    print(p)
    plots$qq <- p
  }

  # -- 3. Scale-Location ----------------------------------------------------
  if ("scale" %in% which) {
    idx <- top_n(df$sqrt_std_resid, n_label)
    p <- ggplot2::ggplot(df, ggplot2::aes(x = .data$fitted,
                                           y = .data$sqrt_std_resid)) +
      ggplot2::geom_point(alpha = 0.5) +
      ggplot2::geom_smooth(method = "loess", se = FALSE, color = "steelblue",
                           formula = y ~ x) +
      ggplot2::geom_text(data = df[idx, ],
                         ggplot2::aes(label = .data$obs),
                         hjust = -0.2, size = 3, color = "red") +
      ggplot2::labs(title = "Scale-Location",
                    x = "Fitted Values",
                    y = expression(sqrt("|Standardized Residuals|"))) +
      ggplot2::theme_minimal()
    print(p)
    plots$scale <- p
  }

  # -- 4. Cook's Distance ---------------------------------------------------
  if ("cooks" %in% which) {
    idx <- top_n(df$cooks, n_label)
    p <- ggplot2::ggplot(df, ggplot2::aes(x = seq_along(.data$cooks),
                                           y = .data$cooks)) +
      ggplot2::geom_col(alpha = 0.5, fill = "steelblue") +
      ggplot2::geom_hline(yintercept = 4 / nrow(df), linetype = "dashed",
                          color = "red") +
      ggplot2::geom_text(data = df[idx, ],
                         ggplot2::aes(x = idx, label = .data$obs),
                         vjust = -0.5, size = 3, color = "red") +
      ggplot2::labs(title = "Cook's Distance",
                    x = "Observation", y = "Cook's Distance") +
      ggplot2::theme_minimal()
    print(p)
    plots$cooks <- p
  }

  # -- 5. Residuals vs Leverage ---------------------------------------------
  if ("leverage" %in% which) {
    idx <- top_n(df$cooks, n_label)
    p_val <- length(stats::coef(model))
    n_obs <- nrow(df)
    cooks_levels <- c(0.5, 1)

    p <- ggplot2::ggplot(df, ggplot2::aes(x = .data$leverage,
                                           y = .data$std_resid)) +
      ggplot2::geom_point(alpha = 0.5) +
      ggplot2::geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
      ggplot2::geom_smooth(method = "loess", se = FALSE, color = "steelblue",
                           formula = y ~ x) +
      ggplot2::geom_text(data = df[idx, ],
                         ggplot2::aes(label = .data$obs),
                         hjust = -0.2, size = 3, color = "red") +
      ggplot2::labs(title = "Residuals vs Leverage",
                    x = "Leverage", y = "Standardized Residuals") +
      ggplot2::theme_minimal()
    print(p)
    plots$leverage <- p
  }

  invisible(plots)
}


#' Produce diagnostic plots for a binary logistic regression
#'
#' Internal helper called by \code{jplot.jst_logistic()} to generate
#' diagnostic plots appropriate for binary outcomes. Unlike standard
#' linear-regression residual plots, these are designed for the structure
#' of a logistic model.
#'
#' Produces any subset of five plots: binned residuals, ROC curve,
#' calibration plot, Cook's distance, and residuals vs leverage.
#'
#' Each plot is printed to the current device. Returns the plots invisibly
#' as a named list so callers can capture or modify them.
#'
#' @param model A fitted \code{glm} object with \code{family = binomial}.
#' @param which Character vector of diagnostic names. Any subset of
#'   \code{binned}, \code{roc}, \code{calibration}, \code{cooks},
#'   \code{leverage}.
#' @param n_label Integer. Number of extreme observations to label on
#'   relevant plots. Default 3.
#'
#' @return Invisibly, a named list of \code{ggplot} objects corresponding to
#'   the requested plots. Returns \code{NULL} invisibly if ggplot2 is not
#'   available.
#'
#' @keywords internal
#' @importFrom rlang .data
.jst_plot_logistic_diagnostics <- function(model, which, n_label = 3) {

  if (!requireNamespace("ggplot2", quietly = TRUE)) {
    cat("Note: Install ggplot2 for diagnostic plots: install.packages(\"ggplot2\")\n")
    return(invisible(NULL))
  }

  observed  <- stats::model.frame(model)[, 1]
  if (is.factor(observed)) observed <- as.numeric(observed) - 1
  predicted <- stats::fitted(model)
  resid_raw <- observed - predicted
  leverage  <- stats::hatvalues(model)
  cooks_d   <- stats::cooks.distance(model)
  obs_lab   <- names(predicted)
  if (is.null(obs_lab)) obs_lab <- as.character(seq_along(predicted))

  top_n <- function(x, n) {
    if (length(x) <= n) return(seq_along(x))
    order(abs(x), decreasing = TRUE)[seq_len(n)]
  }

  plots <- list()

  # -- 1. Binned residuals --------------------------------------------------
  if ("binned" %in% which) {
    n_bins <- max(10, floor(sqrt(length(predicted))))
    ord    <- order(predicted)
    bins   <- cut(seq_along(ord), breaks = n_bins, labels = FALSE)
    bin_df <- data.frame(
      bin_mean_pred  = tapply(predicted[ord], bins, mean),
      bin_mean_resid = tapply(resid_raw[ord], bins, mean),
      bin_n          = as.numeric(table(bins)),
      stringsAsFactors = FALSE
    )
    bin_df$upper <- 2 * sqrt(bin_df$bin_mean_pred *
                             (1 - bin_df$bin_mean_pred) / bin_df$bin_n)
    bin_df$lower <- -bin_df$upper

    p <- ggplot2::ggplot(bin_df,
                         ggplot2::aes(x = .data$bin_mean_pred,
                                      y = .data$bin_mean_resid)) +
      ggplot2::geom_hline(yintercept = 0, linetype = "dashed",
                          color = "red") +
      ggplot2::geom_line(ggplot2::aes(y = .data$upper),
                         color = "grey60", linetype = "dotted") +
      ggplot2::geom_line(ggplot2::aes(y = .data$lower),
                         color = "grey60", linetype = "dotted") +
      ggplot2::geom_point(alpha = 0.7, color = "steelblue") +
      ggplot2::labs(title = "Binned Residuals",
                    x = "Mean Predicted Probability (bin)",
                    y = "Mean Residual (bin)",
                    subtitle = "Dotted lines: approximate 95% bounds under a well-fit model") +
      ggplot2::theme_minimal()
    print(p)
    plots$binned <- p
  }

  # -- 2. ROC curve ---------------------------------------------------------
  if ("roc" %in% which) {
    thresholds <- sort(unique(c(0, predicted, 1)), decreasing = TRUE)
    roc_df <- data.frame(
      tpr = vapply(thresholds, function(t) {
        sum(predicted >= t & observed == 1) / max(1, sum(observed == 1))
      }, numeric(1)),
      fpr = vapply(thresholds, function(t) {
        sum(predicted >= t & observed == 0) / max(1, sum(observed == 0))
      }, numeric(1))
    )
    ord_fpr <- order(roc_df$fpr)
    roc_df  <- roc_df[ord_fpr, ]
    auc <- sum(diff(roc_df$fpr) *
               (roc_df$tpr[-1] + roc_df$tpr[-nrow(roc_df)]) / 2)

    auc_text <- paste0("AUC = ", sprintf("%.3f", auc))

    p <- ggplot2::ggplot(roc_df, ggplot2::aes(x = .data$fpr, y = .data$tpr)) +
      ggplot2::geom_abline(slope = 1, intercept = 0, linetype = "dashed",
                           color = "grey60") +
      ggplot2::geom_line(color = "steelblue", linewidth = 0.8) +
      ggplot2::annotate("text", x = 0.7, y = 0.1, label = auc_text,
                        hjust = 0, size = 4.2, color = "#333333") +
      ggplot2::coord_equal() +
      ggplot2::labs(title = "ROC Curve",
                    x = "False Positive Rate (1 \u2013 Specificity)",
                    y = "True Positive Rate (Sensitivity)") +
      ggplot2::theme_minimal()
    print(p)
    plots$roc <- p
  }

  # -- 3. Calibration plot --------------------------------------------------
  if ("calibration" %in% which) {
    n_bins <- 10
    ord    <- order(predicted)
    bins   <- cut(seq_along(ord), breaks = n_bins, labels = FALSE)
    cal_df <- data.frame(
      pred_mean = tapply(predicted[ord], bins, mean),
      obs_rate  = tapply(observed[ord], bins, mean),
      bin_n     = as.numeric(table(bins)),
      stringsAsFactors = FALSE
    )

    p <- ggplot2::ggplot(cal_df,
                         ggplot2::aes(x = .data$pred_mean,
                                      y = .data$obs_rate)) +
      ggplot2::geom_abline(slope = 1, intercept = 0, linetype = "dashed",
                           color = "grey60") +
      ggplot2::geom_point(ggplot2::aes(size = .data$bin_n),
                          color = "steelblue", alpha = 0.8) +
      ggplot2::geom_line(color = "steelblue", alpha = 0.5) +
      ggplot2::scale_size_continuous(range = c(2, 6), guide = "none") +
      ggplot2::coord_equal(xlim = c(0, 1), ylim = c(0, 1)) +
      ggplot2::labs(title = "Calibration Plot",
                    x = "Mean Predicted Probability",
                    y = "Observed Proportion",
                    subtitle = "Points on the diagonal = well-calibrated") +
      ggplot2::theme_minimal()
    print(p)
    plots$calibration <- p
  }

  # -- 4. Cook's Distance ---------------------------------------------------
  if ("cooks" %in% which) {
    df_cooks <- data.frame(
      idx   = seq_along(cooks_d),
      cooks = cooks_d,
      obs   = obs_lab,
      stringsAsFactors = FALSE
    )
    idx <- top_n(df_cooks$cooks, n_label)
    p <- ggplot2::ggplot(df_cooks, ggplot2::aes(x = .data$idx,
                                                 y = .data$cooks)) +
      ggplot2::geom_col(alpha = 0.5, fill = "steelblue") +
      ggplot2::geom_hline(yintercept = 4 / nrow(df_cooks), linetype = "dashed",
                          color = "red") +
      ggplot2::geom_text(data = df_cooks[idx, ],
                         ggplot2::aes(label = .data$obs),
                         vjust = -0.5, size = 3, color = "red") +
      ggplot2::labs(title = "Cook's Distance",
                    x = "Observation Index",
                    y = "Cook's Distance") +
      ggplot2::theme_minimal()
    print(p)
    plots$cooks <- p
  }

  # -- 5. Residuals vs Leverage ---------------------------------------------
  if ("leverage" %in% which) {
    pearson_res <- stats::residuals(model, type = "pearson")
    df_lev <- data.frame(
      leverage    = leverage,
      pearson_res = pearson_res,
      obs         = obs_lab,
      stringsAsFactors = FALSE
    )
    idx <- top_n(df_lev$pearson_res, n_label)
    p <- ggplot2::ggplot(df_lev, ggplot2::aes(x = .data$leverage,
                                               y = .data$pearson_res)) +
      ggplot2::geom_point(alpha = 0.5) +
      ggplot2::geom_hline(yintercept = 0, linetype = "dashed",
                          color = "red") +
      ggplot2::geom_text(data = df_lev[idx, ],
                         ggplot2::aes(label = .data$obs),
                         hjust = -0.2, size = 3, color = "red") +
      ggplot2::labs(title = "Residuals vs Leverage",
                    x = "Leverage",
                    y = "Pearson Residuals") +
      ggplot2::theme_minimal()
    print(p)
    plots$leverage <- p
  }

  # Console summary (match the lm helper pattern)
  plot_names_pretty <- c(
    binned      = "Binned Residuals",
    roc         = "ROC Curve",
    calibration = "Calibration Plot",
    cooks       = "Cook's Distance",
    leverage    = "Residuals vs Leverage"
  )
  produced <- plot_names_pretty[which]
  produced <- produced[!is.na(produced)]
  if (length(produced) == 1) {
    cat("(Diagnostic plot produced: ", produced, ")\n", sep = "")
  } else if (length(produced) > 1) {
    cat("\n", length(produced), " diagnostic plots produced ",
        "(use the arrow buttons in RStudio's Plots pane to navigate):\n",
        sep = "")
    for (i in seq_along(produced)) {
      cat("  ", i, ". ", produced[i], "\n", sep = "")
    }
  }

  invisible(plots)
}


# -- jlm ----------------------------------------------------------------------

#' SPSS-like linear regression output with standardized coefficients
#'
#' Fits a linear model using \code{stats::lm()} and prints SPSS-style output,
#' including unstandardized coefficients, standard errors, t values, p values,
#' and standardized coefficients (β). Standardized coefficients are left
#' blank for the intercept and for dummy-coded categorical terms.
#'
#' Also prints key model summary information (R-squared, adjusted R-squared,
#' residual standard error, F-test, sums of squares, and N). If any
#' coefficients are dropped due to perfect collinearity, a warning message
#' is printed.
#'
#' A red "Linear Regression" title is printed first, followed by variable
#' labels (if present), then the coefficient table and model fit statistics.
#'
#' \strong{Handling of variables:}
#' \itemize{
#'   \item Variables registered with \code{jdummy()} are expanded into dummy
#'     variables using the registered reference category.
#'   \item Unregistered haven-labelled variables with value labels are
#'     automatically treated as categorical (converted to factors). The
#'     first category is used as the reference, and an informational
#'     message suggests using \code{jdummy()} for control over the
#'     reference category.
#'   \item Haven-labelled variables without value labels are treated as
#'     continuous (converted to numeric).
#'   \item The \code{numeric} argument overrides auto-detection for variables
#'     that have value labels but should be treated as continuous (e.g. Age
#'     with labels like "18 years", "19 years").
#'   \item The \code{categorical} argument forces variables without value
#'     labels (or plain numeric variables) to be treated as categorical
#'     (e.g. a numeric Program variable coded 1--4 from a CSV file).
#'   \item The dependent variable is always treated as numeric.
#' }
#'
#' @param formula A model formula, e.g. \code{y ~ x1 + x2}.
#' @param data A data frame containing variables referenced in \code{formula}.
#' @param subset An optional unquoted logical expression (e.g.
#'   \code{Group == 1}) to subset cases for this call only. Applied after
#'   jcomplete and jsubset. Does not affect other function calls.
#' @param labels Logical. If TRUE (default), prints variable labels
#'   when available.
#' @param numeric Optional character vector of variable names that should be
#'   treated as continuous (numeric) even if they have value labels. For
#'   example, \code{numeric = "Age"} or \code{numeric = c("Age", "Education")}.
#' @param categorical Optional character vector of variable names that should
#'   be treated as categorical even if they lack value labels. For example,
#'   \code{categorical = "Program"} or \code{categorical = c("Program", "Region")}.
#'   The first sorted unique value becomes the reference category. Use
#'   \code{jdummy()} for control over the reference category.
#' @param diagnostics Logical, character vector, or NULL. If TRUE, prints VIF
#'   table and diagnostic plots. If a character vector, specifies which
#'   diagnostics to show: \code{vif}, \code{residuals}, \code{qq},
#'   \code{scale}, \code{cooks}, \code{leverage}. If NULL (default),
#'   defers to \code{joutput()} session setting.
#' @param full Logical. If TRUE, turns on diagnostics. Does not override
#'   explicit FALSE values.
#' @param ... Reserved for argument-name checking. Passing \code{which},
#'   \code{plots}, or \code{show} will produce a helpful error suggesting
#'   \code{diagnostics} instead.
#'
#' @return Invisibly returns a list of class \code{jst_lm} containing:
#'   \describe{
#'     \item{model}{The fitted \code{lm} object.}
#'     \item{model_type}{Character string \code{linear}.}
#'     \item{model_frame}{The model frame used to fit the model.}
#'     \item{formula_used}{The formula after dummy expansion.}
#'     \item{coefficients}{Formatted coefficient table (data frame).}
#'     \item{r_squared}{R-squared value.}
#'     \item{adj_r_squared}{Adjusted R-squared value.}
#'     \item{residual_se}{Residual standard error.}
#'     \item{f_statistic}{Named numeric vector with F value, df1, df2, and p.}
#'     \item{sums_of_squares}{Named numeric vector (regression, residual, total).}
#'     \item{n}{Number of observations used in the model.}
#'     \item{dummy_coef_names}{Names of dummy variable columns created by
#'       \code{jdummy()} registrations.}
#'     \item{ref_cats}{Reference category descriptions for all categorical
#'       variables in the model.}
#'     \item{vif}{Named numeric vector of VIF values, or NULL for bivariate.}
#'     \item{sample_info}{Pipeline and missing data counts.}
#'   }
#'
#' @examples
#' # With explicit data frame (named argument)
#' jlm(mpg ~ hp + wt, data = mtcars)
#'
#' # With explicit data frame (positional argument)
#' jlm(mpg ~ hp + wt, mtcars)
#'
#' # Using juse() default
#' juse(mtcars)
#' jlm(mpg ~ hp + wt)
#'
#' \dontrun{
#' # CATEGORICAL PREDICTORS
#' #
#' # The recommended approach: register the variable with jdummy()
#' # before running jlm(). This sets the categorical treatment
#' # persistently, so subsequent jlm() calls (and other analyses)
#' # use the same coding without re-specifying.
#' jdummy(SampleData, Program)
#' jlm(Outcome ~ Program + ReadingScore)
#'
#' # To choose a non-default reference category:
#' jdummy(SampleData, Program, ref = "Standard")
#' jlm(Outcome ~ Program + ReadingScore)
#'
#' # Per-call alternative: categorical = ... applies for one call only
#' # and does not persist. Useful when you want categorical treatment
#' # without registering, or when overriding a registration just once.
#' jlm(Outcome ~ Program + ReadingScore, categorical = "Program")
#'
#' # FORCING NUMERIC TREATMENT
#' #
#' # Use numeric = ... when a variable has value labels (haven_labelled)
#' # but you want it treated as a continuous score (e.g., a Likert
#' # scale you want the slope-per-unit interpretation for).
#' jlm(Outcome ~ Age + Employment, numeric = "Age")
#'
#' # Multiple overrides at once
#' jlm(Outcome ~ Age + Education + Program,
#'     numeric = c("Age", "Education"), categorical = "Program")
#' }
#'
#' @seealso \code{\link{JeffsStatTools}} for the package overview,
#'   workflow conventions, and complete function listing.
#'
#' @export
#' @param case.processing.detail Per-call override of the Case
#'   Processing Summary detail tier: one of \code{"none"},
#'   \code{"totals"}, or \code{"per_code"}. \code{NULL} (default)
#'   uses the active \code{joutput()} level default.
jlm <- function(formula, data, subset = NULL, labels = NULL,
                numeric = NULL, categorical = NULL,
                diagnostics = NULL, full = FALSE,
                case.processing.detail = NULL, ...) {

  .jst_check_args(
    list(...),
    aliases = c(which = "diagnostics", plots = "diagnostics",
                show = "diagnostics"),
    fn_name = "jlm"
  )

  # Resolve default data frame if not specified
  .jst_default_used <- FALSE
  .jst_data_name    <- NULL
  if (missing(data)) {
    resolved <- .jst_resolve_data(envir = parent.frame())
    data <- resolved$data
    .jst_default_used <- TRUE
    .jst_data_name    <- resolved$name
  } else {
    .jst_data_name <- deparse(substitute(data))
  }

  # Red title
  .cat_red("Linear Regression\n")
  if (.jst_default_used) .jst_default_note(.jst_data_name)

  # Apply data pipeline (jcomplete, jsubset, subset)
  subset_expr <- substitute(subset)
  pipeline <- .jst_apply_pipeline(data, .jst_data_name, .jst_default_used,
                                  subset_expr = subset_expr, envir = parent.frame())
  data     <- pipeline$data
  .jst_print_msgs(pipeline$msgs)

  # Resolve display toggles
  show_var_labels      <- .jst_resolve_toggle("var.labels",      labels)
  show_ref_categories  <- .jst_resolve_toggle("ref.categories",  NULL)
  # Resolve diagnostics toggle
  if (full) {
    if (is.null(diagnostics)) diagnostics <- TRUE
  }
  if (is.character(diagnostics)) {
    show_diag  <- TRUE
    diag_which <- diagnostics
  } else {
    show_diag  <- .jst_resolve_toggle("diagnostics", diagnostics)
    diag_which <- if (show_diag) {
      c("vif", "residuals", "qq", "scale", "cooks", "leverage")
    } else {
      character(0)
    }
  }

  model_vars            <- all.vars(formula)
  # Preserve the original (pre-expansion) variable names for use in
  # missing-by-variable reporting. After dummy expansion, model_vars
  # holds the dummy column names (e.g. ProgramApprenticeship); the
  # user wrote "Program" in the formula and the diagnostic should
  # speak the user's language.
  original_formula_vars <- model_vars

  .jst_check_vars(data, model_vars, .jst_data_name)
  # Type gate (Session 46): the response must be numeric; predictors may be
  # numeric or categorical. Date/time and complex/list/raw refused in both
  # roles. See .jst_check_analysis_var.
  .jst_check_analysis_var(data[[model_vars[1L]]], model_vars[1L], TRUE, "a linear model")
  for (.gv in model_vars[-1L]) .jst_check_analysis_var(data[[.gv]], .gv, FALSE, "a linear model")

  # -- Expand registered dummy variables ------------------------------------
  expanded         <- .jst_expand_dummies(data, formula, .jst_data_name)
  data             <- expanded$data
  formula          <- expanded$formula
  ref_cats         <- expanded$ref_cats
  dummy_coef_names <- expanded$dummy_coef_names
  model_vars       <- all.vars(formula)

  # -- Variable type conversion -------------------------------------------------
  # Priority order:
  #   1. jdummy() registrations (already expanded above)
  #   2. numeric/categorical overrides from this call
  #   3. Auto-detection: haven-labelled with value labels → categorical,
  #      everything else → numeric
  # DV is always numeric regardless of overrides.
  auto_ref_cats <- character(0)
  auto_cat_regs <- list()  # in-flight registrations for auto-cat / categorical = vars
  dv_name <- all.vars(formula)[1]

  # --- DV sanity check: warn if the DV looks categorical or dichotomous ----
  #
  # jlm runs linear regression, which treats the DV as continuous. If the
  # DV looks like a dichotomy or has small-integer categorical-like
  # structure, the user may have meant a different model. Warn but don't
  # stop — the user might genuinely want continuous treatment of a
  # 0/1-coded variable, for example, which is mathematically valid.
  dv_dich <- .jst_is_dichotomy(data[[dv_name]])
  if (dv_dich$is_dichotomy) {
    # Dichotomy-specific warning: jlogistic is the most likely intended
    # alternative. Coding-specific recode hint when not 0/1.
    base_msg <- paste0(
      "'", dv_name, "' is a dichotomy (coded ", dv_dich$coding,
      ") but is being used as the dependent variable in linear regression. ",
      "Linear regression treats the DV as continuous, which may not be ",
      "what you intended. Consider whether you meant: (a) reverse the ",
      "variables in the formula, e.g. jlm(", all.vars(formula)[2], " ~ ",
      dv_name
    )
    # Build full reversed-formula suggestion if more than one IV
    other_ivs <- all.vars(formula)[-1]
    if (length(other_ivs) > 1) {
      base_msg <- paste0(base_msg, " + ", paste(other_ivs[-1], collapse = " + "))
    }
    base_msg <- paste0(base_msg, ", ", .jst_data_name, "); or ")
    if (dv_dich$coding == "0/1") {
      tail_msg <- paste0(
        "(b) use jlogistic(", deparse(formula), ", ", .jst_data_name,
        ") for binary outcomes."
      )
    } else if (dv_dich$coding == "1/2") {
      tail_msg <- paste0(
        "(b) recode 1/2 to 0/1 with jrecode() and use jlogistic() for ",
        "binary outcomes."
      )
    } else {
      tail_msg <- paste0(
        "(b) recode to 0/1 with jrecode() and use jlogistic() for binary ",
        "outcomes."
      )
    }
    warning(base_msg, tail_msg, call. = FALSE)
  } else if (.jst_is_count(data[[dv_name]])) {
    # Count DV: small-range non-negative integer starting at 0. Linear
    # regression assumptions (normal residuals, constant variance) are
    # usually violated by small counts. The package does not yet have
    # count-model functions; for now, warn and let the model run.
    n_unique <- length(unique(data[[dv_name]][!is.na(data[[dv_name]])]))
    warning(
      "'", dv_name, "' looks like a count variable (non-negative integer ",
      "in the 0-6 range, ", n_unique, " unique values). Linear regression ",
      "assumes a continuous DV with at least 6-7 distinct values for ",
      "reliable inference. With small-range counts, the linear-regression ",
      "assumptions of normally distributed residuals and constant variance ",
      "are usually violated. Consider whether to (a) collapse '", dv_name,
      "' into broader categories and treat it as ordinal, or (b) wait ",
      "for count-model functions in a future package version (Poisson or ",
      "negative binomial regression). The model will run, but interpret ",
      "with caution.",
      call. = FALSE
    )
  } else if (.jst_is_discrete_integer(data[[dv_name]], dv_name,
                                      .jst_data_name)) {
    # Non-dichotomous but categorical-like (e.g. a Likert item used as DV).
    # Three plausible alternatives: reverse formula, jlogistic (multinomial
    # would apply but that's beyond current package scope), or jaov/jt.
    other_ivs <- all.vars(formula)[-1]
    reverse_formula <- paste0(other_ivs[1], " ~ ", dv_name)
    if (length(other_ivs) > 1) {
      reverse_formula <- paste0(reverse_formula, " + ",
                                paste(other_ivs[-1], collapse = " + "))
    }
    warning(
      "'", dv_name, "' is the dependent variable but has categorical-like ",
      "structure (small-range integer or labelled values). Linear ",
      "regression treats this as continuous, which may not be what you ",
      "intended. Consider whether you meant to: (a) reverse the variables ",
      "in the formula, e.g. jlm(", reverse_formula, ", ", .jst_data_name,
      "); (b) use jlogistic() if the DV is a binary outcome; or ",
      "(c) use jaov() or jt() to compare the IV across DV groups.",
      call. = FALSE
    )
  }

  # Validate override arguments against model variables
  iv_names <- setdiff(model_vars, c(dv_name, dummy_coef_names))
  # Also exclude original variable names that were expanded by jdummy()
  expanded_originals <- character(0)
  dummy_regs <- .jst_get_dummy(.jst_data_name)
  if (!is.null(dummy_regs)) {
    expanded_originals <- vapply(dummy_regs, function(r) r$var_name, character(1))
  }
  iv_names <- setdiff(iv_names, expanded_originals)

  if (!is.null(numeric)) {
    # Check if any numeric overrides refer to the DV
    dv_in_numeric <- intersect(numeric, dv_name)
    if (length(dv_in_numeric) > 0) {
      message(
        "Note: '", dv_in_numeric, "' is the dependent variable and is always ",
        "treated as numeric.\n",
        "The numeric argument is only needed for independent variables."
      )
      numeric <- setdiff(numeric, dv_name)
      if (length(numeric) == 0) numeric <- NULL
    }
  }

  if (!is.null(categorical)) {
    # Check if any categorical overrides refer to the DV
    dv_in_cat <- intersect(categorical, dv_name)
    if (length(dv_in_cat) > 0) {
      message(
        "Note: '", dv_in_cat, "' is the dependent variable and is always ",
        "treated as numeric.\n",
        "The categorical argument is only needed for independent variables."
      )
      categorical <- setdiff(categorical, dv_name)
      if (length(categorical) == 0) categorical <- NULL
    }
  }

  # Handle both cases for numeric / categorical arguments:
  #
  #   - Dummy-registered variable (name listed in expanded_originals):
  #       `categorical = "X"` → redundant with jdummy, warning, continue.
  #       `numeric = "X"`     → jdummy wins regardless, argument is ignored;
  #                             tailored warning explaining how to undo the
  #                             registration. Model still runs with the
  #                             dummy-expanded variable.
  #   - Unknown variable (not in expanded_originals, not in iv_names):
  #       Genuine typo or name that isn't in the formula. Stop with an
  #       error rather than silently running a model that ignores the
  #       user's stated intent.

  if (!is.null(numeric)) {
    bad <- setdiff(numeric, iv_names)
    if (length(bad) > 0) {
      bad_registered <- intersect(bad, expanded_originals)
      bad_unknown    <- setdiff(bad, expanded_originals)
      if (length(bad_registered) > 0) {
        warning(
          "numeric argument ",
          paste0("'", bad_registered, "'", collapse = ", "),
          " is ignored: already registered as a dummy variable via ",
          "jdummy(), which takes precedence. To model as continuous, ",
          "first clear the registration with: jdummy(NULL)",
          call. = FALSE
        )
      }
      if (length(bad_unknown) > 0) {
        stop(
          "numeric argument: ",
          paste0("'", bad_unknown, "'", collapse = ", "),
          " not found among independent variables in ", .jst_data_name,
          ". Check for typos.",
          call. = FALSE
        )
      }
      numeric <- intersect(numeric, iv_names)
    }
  }

  if (!is.null(categorical)) {
    bad <- setdiff(categorical, iv_names)
    if (length(bad) > 0) {
      bad_registered <- intersect(bad, expanded_originals)
      bad_unknown    <- setdiff(bad, expanded_originals)
      if (length(bad_registered) > 0) {
        warning(
          "categorical argument ",
          paste0("'", bad_registered, "'", collapse = ", "),
          " is redundant: already registered as a dummy variable via ",
          "jdummy(), so categorical treatment is automatic. Ignoring.",
          call. = FALSE
        )
      }
      if (length(bad_unknown) > 0) {
        stop(
          "categorical argument: ",
          paste0("'", bad_unknown, "'", collapse = ", "),
          " not found among independent variables in ", .jst_data_name,
          ". Check for typos.",
          call. = FALSE
        )
      }
      categorical <- intersect(categorical, iv_names)
    }
  }

  # Check for conflicts between numeric and categorical
  if (!is.null(numeric) && !is.null(categorical)) {
    conflict <- intersect(numeric, categorical)
    if (length(conflict) > 0) {
      stop(
        paste0("'", conflict, "'", collapse = ", "),
        " listed in both numeric and categorical arguments.",
        call. = FALSE
      )
    }
  }

  for (v in model_vars) {
    if (v %in% dummy_coef_names) next   # Dummy columns created by jdummy()
    if (v %in% expanded_originals) next # Original vars replaced by jdummy()

    if (v == dv_name) {
      # DV — always numeric
      if (haven::is.labelled(data[[v]])) data[[v]] <- .jst_as_numeric(data[[v]])
      next
    }

    # --- Override: numeric = "Var" forces numeric ---
    if (v %in% numeric) {
      if (haven::is.labelled(data[[v]])) {
        data[[v]] <- .jst_as_numeric(data[[v]])
      }
      # Plain numeric stays as-is
      next
    }

    # --- Override: categorical = "Var" forces categorical ---
    if (v %in% categorical) {
      reg <- .jst_make_dummy_names(data[[v]], v, ref = "first")
      auto_cat_regs[[v]] <- reg
      for (n in reg$notes) cat(n, "\n", sep = "")
      for (w in reg$warnings_msg) warning(w, call. = FALSE)
      auto_ref_cats <- c(auto_ref_cats, paste0(v, " = ", reg$ref_label))
      next
    }

    # --- Auto-detection (two-helper classifier) ---
    #
    # Intent helper first: only treat the IV as categorical when the user
    # has explicitly signalled categorical (jdummy-registered, or
    # factor/logical/character class). jdummy-registered IVs are handled
    # upstream by .jst_expand_dummies() and won't reach this block; the
    # Rule A check inside .jst_is_categorical() is defensive.
    #
    # If the intent helper returns FALSE, the IV enters the model as
    # numeric. The structural helper (.jst_is_discrete_integer()) is then
    # consulted purely to decide whether to warn the user: if the variable
    # has categorical-looking structure (haven-labelled with labels in
    # data, or small-range whole-number numeric), the user may have meant
    # to register with jdummy() or pass categorical = instead.
    if (.jst_is_categorical(data[[v]], v, .jst_data_name)) {
      reg <- .jst_make_dummy_names(data[[v]], v, ref = "first")
      auto_cat_regs[[v]] <- reg
      for (n in reg$notes) cat(n, "\n", sep = "")
      for (w in reg$warnings_msg) warning(w, call. = FALSE)
      auto_ref_cats <- c(auto_ref_cats, paste0(v, " = ", reg$ref_label))
    } else {
      # Not intent-categorical. Strip haven class if present, leave as
      # numeric in the model.
      if (haven::is.labelled(data[[v]])) {
        data[[v]] <- .jst_as_numeric(data[[v]])
      }
      # Check for dichotomy first: dichotomies are valid as numeric IVs
      # in linear regression (the slope is the mean difference). They do
      # not need dummy-coding. The discrete-integer warning would be
      # misleading for them. Soft coding-specific warnings only:
      #   - 0/1, factor, character, logical: no warning, clean run.
      #   - 1/2: model runs correctly, but recoding to 0/1 makes the
      #     intercept easier to interpret.
      #   - other (e.g., 5/10): non-standard coding; slope represents
      #     per-unit change, recoding to 0/1 advised.
      iv_dich <- .jst_is_dichotomy(data[[v]])
      if (iv_dich$is_dichotomy) {
        if (iv_dich$coding == "1/2") {
          warning(
            v, " is a 1/2 dichotomy. The model runs correctly, but ",
            "recoding to 0/1 makes the intercept easier to interpret. ",
            "To recode:\n\n",
            "  ", .jst_data_name, "$", v, "R <- jrecode(",
              .jst_data_name, ", ", v, ", map = \"1=0; 2=1\")\n",
            "  jlm(", deparse(formula[[2]]), " ~ ", v, "R)\n\n",
            "For other approaches (jdummy, categorical = ...) see ?jlm.",
            call. = FALSE
          )
        } else if (iv_dich$coding == "other") {
          warning(
            v, " is a dichotomy with non-standard coding. The slope ",
            "represents per-unit change rather than the contrast between ",
            "categories. Consider recoding to 0/1 for clearer interpretation. ",
            "Adapt the values below to match this variable's actual codes:\n\n",
            "  ", .jst_data_name, "$", v, "R <- jrecode(",
              .jst_data_name, ", ", v, ", map = \"<oldval1>=0; <oldval2>=1\")\n",
            "  jlm(", deparse(formula[[2]]), " ~ ", v, "R)\n\n",
            "For other approaches (jdummy, categorical = ...) see ?jlm.",
            call. = FALSE
          )
        }
        # 0/1, factor, character, logical: no warning.
      } else if (.jst_is_discrete_integer(data[[v]], v, .jst_data_name)) {
        # Non-dichotomous but categorical-like structure: emit the
        # informational warning so the user can confirm continuous
        # treatment or switch to categorical.
        warning(
          v, " has categorical-like structure (small-range integer ",
          "or labelled values) but is entering the model as continuous. ",
          "If continuous treatment is intended (e.g. a Likert scale), no ",
          "action is needed. To treat as categorical, register with jdummy:",
          "\n\n",
          "  jdummy(", .jst_data_name, ", ", v, ")\n",
          "  jlm(", deparse(formula), ")\n\n",
          "For other approaches (categorical = ...) see ?jlm.",
          call. = FALSE
        )
      }
    }
  }

  # -- Apply auto-categorical expansions ------------------------------------
  # For variables that were determined to be categorical (via categorical =
  # argument or auto-detection), an in-flight registration was built but
  # the formula/data weren't yet updated. Apply those expansions now using
  # the same .jst_expand_one_dummy() helper that .jst_expand_dummies()
  # uses for jdummy registrations, so naming is uniform across pathways.
  if (length(auto_cat_regs) > 0) {
    formula_str <- deparse(formula, width.cutoff = 500)
    for (vname in names(auto_cat_regs)) {
      reg <- auto_cat_regs[[vname]]
      reg$var_name <- vname
      expanded2 <- .jst_expand_one_dummy(data, formula_str, reg)
      data             <- expanded2$data
      formula_str      <- expanded2$formula_str
      dummy_coef_names <- c(dummy_coef_names, expanded2$dummy_coef_names)
    }
    formula    <- stats::as.formula(formula_str)
    model_vars <- all.vars(formula)
  }

  # Build model frame and sample_info early so case processing block can
  # use them. Listwise deletion is applied here via na.action = na.omit.
  mf          <- stats::model.frame(formula, data = data, na.action = stats::na.omit)
  sample_info <- .jst_build_sample_info(
    pipeline_counts = pipeline$pipeline_counts,
    data            = pipeline$data,
    analysis_vars   = original_formula_vars,
    n_analysis      = nrow(mf)
  )

  # Case Processing Summary
  .jst_print_case_processing(sample_info, analysis_type = "listwise", detail = case.processing.detail)

  # Variable labels
  if (show_var_labels) {
    .print_var_labels(data, all.vars(formula))
  }

  # Reference categories block + categorical-handling notes
  if (show_ref_categories) {
    # Print reference categories — registered dummies first, then auto/override
    all_ref_cats <- c(ref_cats, auto_ref_cats)
    if (length(all_ref_cats) > 0) {
      cat("  Reference categories: ", paste(all_ref_cats, collapse = ", "), "\n", sep = "")
    }

    # Informational messages for auto-detected categoricals
    auto_detected <- setdiff(sub(" = .*", "", auto_ref_cats),
                             if (!is.null(categorical)) categorical else character(0))
    if (length(auto_detected) > 0) {
      cat("  (", paste(auto_detected, collapse = ", "),
          " auto-detected as categorical. To choose a different\n",
          "   reference category, use jdummy() before running jlm().\n",
          "   If a variable should be numeric, use: numeric = \"",
          auto_detected[1], "\")\n", sep = "")
    }

    # Informational message for categorical overrides
    if (!is.null(categorical) && length(categorical) > 0) {
      cat_in_model <- intersect(categorical, sub(" = .*", "", auto_ref_cats))
      if (length(cat_in_model) > 0) {
        cat("  (", paste(cat_in_model, collapse = ", "),
            " treated as categorical via categorical argument.\n",
            "   To choose a different reference, use jdummy() before running jlm().)\n",
            sep = "")
      }
    }
    if (length(all_ref_cats) > 0) cat("\n")
  } else {
    # Build all_ref_cats anyway because downstream code (return object) uses it
    all_ref_cats <- c(ref_cats, auto_ref_cats)
  }

  # Pre-fit checks: catch conditions that would otherwise produce the
  # confusing lm.fit error "0 (non-NA) cases" — distinguishing the two
  # different underlying conditions for a clearer message.

  if (nrow(mf) == 0L) {
    stop("All cases were excluded by the pipeline and/or listwise ",
         "deletion; no model can be fit. See the Case Processing ",
         "Summary above to identify which stage(s) excluded the cases.",
         call. = FALSE)
  }

  # Zero-variance predictor check: any IV with only one unique value in
  # the analytic sample. Skip the response (column 1 of mf) and intercept.
  iv_cols <- mf[, -1L, drop = FALSE]
  if (ncol(iv_cols) > 0L) {
    n_unique <- vapply(iv_cols, function(x) length(unique(x)), integer(1))
    constant_ivs <- names(n_unique)[n_unique < 2L]
    if (length(constant_ivs) > 0L) {
      stop("The following predictor(s) have no variation in the ",
           "analysis sample (only one unique value); cannot fit slope: ",
           paste(constant_ivs, collapse = ", "), ". This often happens ",
           "when jsubset() restricts the sample to a single category of ",
           "a variable that is then used as a predictor.",
           call. = FALSE)
    }
  }

  model         <- stats::lm(formula, data = mf)
  model_summary <- summary(model)

  coefs <- as.data.frame(model_summary$coefficients, stringsAsFactors = FALSE)
  colnames(coefs)[1:4] <- c("b", "StdErr", "t", "P")

  mf_std   <- mf
  num_cols <- vapply(mf_std, is.numeric, logical(1))
  mf_std[, num_cols] <- lapply(mf_std[, num_cols, drop = FALSE], scale)

  std_model        <- stats::lm(formula, data = mf_std)
  std_coefs        <- stats::coef(std_model)
  std_b            <- rep(NA_real_, nrow(coefs))
  names(std_b)     <- rownames(coefs)
  common           <- intersect(names(std_coefs), names(std_b))
  std_b[common]    <- std_coefs[common]

  if ("(Intercept)" %in% names(std_b)) std_b["(Intercept)"] <- NA_real_

  factor_terms <- names(mf)[vapply(mf, is.factor, logical(1))]
  if (length(factor_terms) > 0) {
    for (term in factor_terms) {
      dummy_rows        <- grep(paste0("^", term), rownames(coefs), value = TRUE)
      std_b[dummy_rows] <- NA_real_
    }
  }

  # Blank β for registered dummy variables
  if (length(dummy_coef_names) > 0) {
    for (dname in dummy_coef_names) {
      if (dname %in% names(std_b)) std_b[dname] <- NA_real_
    }
  }

  p_num <- suppressWarnings(as.numeric(coefs$P))
  p_fmt <- ifelse(!is.na(p_num) & p_num < 0.001, "<.001",
                  ifelse(is.na(p_num), "<.001", sprintf("%.3f", p_num)))

  fmt3 <- function(x) sprintf("%.3f", as.numeric(x))

  # Clean up factor coefficient names for readability
  rownames(coefs) <- .jst_clean_coef_names(rownames(coefs), data,
                                            all.vars(formula)[-1])

  out_coefs <- data.frame(
    b       = fmt3(coefs$b),
    StdErr  = fmt3(coefs$StdErr),
    t       = fmt3(coefs$t),
    Beta    = ifelse(is.na(std_b), "", sprintf("%.3f", as.numeric(std_b))),
    P       = p_fmt,
    stringsAsFactors = FALSE,
    row.names = rownames(coefs)
  )

  r_squared     <- round(model_summary$r.squared, 3)
  adj_r_squared <- round(model_summary$adj.r.squared, 3)
  residual_se   <- round(model_summary$sigma, 3)

  f_stat  <- model_summary$fstatistic
  f_value <- round(unname(f_stat[1]), 3)
  df1     <- unname(f_stat[2])
  df2     <- unname(f_stat[3])
  f_p     <- stats::pf(f_value, df1, df2, lower.tail = FALSE)
  f_p_fmt <- ifelse(is.na(f_p) | f_p < 0.001, "<.001", sprintf("%.3f", f_p))

  n_obs         <- stats::nobs(model)
  y             <- stats::model.response(mf)
  ss_total      <- round(sum((y - mean(y))^2), 3)
  ss_regression <- round(sum((stats::fitted(model) - mean(y))^2), 3)
  ss_residual   <- round(sum(stats::residuals(model)^2), 3)

  if (any(is.na(stats::coef(model)))) {
    cat("\nWARNING: One or more variables have been removed from the model due to collinearity.\n")
  }

  # Perfect-fit guard: when R-squared is 1 and the residual standard error is
  # 0, the t and F statistics blow up to scientific-notation scale and the
  # printed precision is meaningless. This almost always means a variable was
  # regressed on itself or on an exact transformation of itself. Flag it so
  # the absurd-looking statistics below are read as a model-specification
  # error rather than a result; numeric output is retained. (Session 50)
  if (isTRUE(model_summary$r.squared >= 1 - 1e-9) &&
      isTRUE(model_summary$sigma <= 1e-9)) {
    cat("\nWARNING: Perfect linear fit detected (R-squared = 1, residual SE = 0).\n",
        "         This usually means a variable was regressed on itself or on an\n",
        "         exact transformation of itself. The t and F statistics below are\n",
        "         not meaningful -- check your model specification.\n", sep = "")
  }

  cat("\n")
  .jst_print_table(out_coefs,
                   caption   = "Coefficients",
                   col.names = c("b", "SE", "t", "\u03b2", "p"),
                   align     = c("c", "c", "c", "c", "c"),
                   row.names = TRUE)

  cat("\nR-squared: ", sprintf("%.3f", r_squared),
      "    Adjusted R-squared: ", sprintf("%.3f", adj_r_squared), "\n", sep = "")
  cat("Residual Standard Error: ", sprintf("%.3f", residual_se), "\n", sep = "")
  cat("\nF-statistic: ", sprintf("%.3f", f_value),
      " on ", df1, " and ", df2,
      " DF, p-value: ", f_p_fmt, "\n", sep = "")
  cat("Sum of Squares:\n")
  cat("  Regression: ", sprintf("%.3f", ss_regression), "\n", sep = "")
  cat("  Residual:   ", sprintf("%.3f", ss_residual),   "\n", sep = "")
  cat("  Total:      ", sprintf("%.3f", ss_total),      "\n", sep = "")

  # -- Diagnostics (VIF + plots) --------------------------------------------
  vif_values <- NULL
  if (show_diag) {

    # VIF — only for multivariate models (2+ predictors)
    if ("vif" %in% diag_which) {
      vif_values <- .jst_compute_vif(model)
      if (!is.null(vif_values)) {
        cat("\n")
        vif_df <- data.frame(
          Variable = names(vif_values),
          VIF      = round(vif_values, 3),
          stringsAsFactors = FALSE,
          row.names = NULL
        )
        .jst_print_table(vif_df,
                         caption = "VIF (Variance Inflation Factors)",
                         row.names = FALSE)

        # Targeted notes for VIF > 10
        high_vif <- vif_values[vif_values > 10]
        if (length(high_vif) > 0) {
          cat("\n")
          for (nm in names(high_vif)) {
            inflation <- round(sqrt(high_vif[nm]), 1)
            cat(nm, " (VIF = ", round(high_vif[nm], 1),
                "): standard error inflated by a factor of ", inflation, ".\n",
                "  If you need to interpret this coefficient specifically, consider\n",
                "  whether the collinearity is a concern for your research question.\n",
                sep = "")
          }
        }
      }
    } else {
      # Compute VIF silently for return object even if not displayed
      vif_values <- .jst_compute_vif(model)
    }

    # Diagnostic plots
    plot_which <- intersect(diag_which,
                            c("residuals", "qq", "scale", "cooks", "leverage"))
    if (length(plot_which) > 0) {
      plot_labels <- c(residuals = "Residuals vs Fitted", qq = "Normal Q-Q",
                       scale = "Scale-Location", cooks = "Cook's Distance",
                       leverage = "Residuals vs Leverage")
      if (length(plot_which) == 1) {
        cat("\n(Diagnostic plot produced: ",
            plot_labels[plot_which[1]], ")\n", sep = "")
      } else {
        cat("\n(", length(plot_which), " diagnostic plots produced",
            " \u2014 use the back arrow in the Plots pane to view all)\n",
            sep = "")
        for (i in seq_along(plot_which)) {
          cat("  ", i, ": ", plot_labels[plot_which[i]], "\n", sep = "")
        }
      }
      .jst_plot_lm_diagnostics(model, which = plot_which)
    }
  }

  ret <- list(
    model           = model,
    model_type      = "linear",
    model_frame     = mf,
    formula_used    = formula,
    coefficients    = out_coefs,
    r_squared       = r_squared,
    adj_r_squared   = adj_r_squared,
    residual_se     = residual_se,
    f_statistic     = c(value = f_value, df1 = df1, df2 = df2, p = f_p),
    sums_of_squares = c(regression = ss_regression,
                        residual   = ss_residual,
                        total      = ss_total),
    n               = n_obs,
    dummy_coef_names = dummy_coef_names,
    ref_cats        = c(ref_cats, auto_ref_cats),
    vif             = vif_values,
    sample_info     = sample_info
  )
  class(ret) <- "jst_lm"
  cat("\n")
  invisible(ret)
}


# -- jlogistic -----------------------------------------------------------------

#' Logistic regression with SPSS-style output
#'
#' Fits a binary logistic regression using \code{stats::glm()} with
#' \code{family = binomial} and prints formatted output including an omnibus
#' model test, model summary statistics, and a coefficients table with
#' odds ratios (Exp(B)).
#'
#' The dependent variable must be coded 0/1. If it is not, the function
#' stops with a clear error message and suggests the appropriate
#' \code{jrecode()} command.
#'
#' Handles haven-labelled variables, registered dummy variables via
#' \code{jdummy()}, and the \code{numeric}/\code{categorical} overrides
#' in the same way as \code{jlm()}.
#'
#' @param formula A model formula, e.g. \code{DV ~ IV1 + IV2}. The DV
#'   must be a binary variable coded 0/1.
#' @param data A data frame containing variables referenced in \code{formula}.
#' @param subset An optional unquoted logical expression (e.g.
#'   \code{Group == 1}) to subset cases for this call only.
#' @param labels Logical. If TRUE (default), prints variable labels
#'   when available.
#' @param numeric Optional character vector of variable names to treat
#'   as continuous even if they have value labels.
#' @param categorical Optional character vector of variable names to treat
#'   as categorical even if they lack value labels.
#' @param ci Logical or NULL. If TRUE, adds 95\% confidence intervals for
#'   Exp(B). If NULL (default), defers to \code{joutput()}.
#' @param classification Logical. If TRUE, prints a classification table
#'   showing predicted vs observed outcomes. Default is FALSE.
#' @param diagnostics Logical, character vector, or NULL. If TRUE, prints
#'   VIF table. If a character vector, \code{vif} is currently the only
#'   supported option. If NULL (default), defers to \code{joutput()}.
#' @param full Logical. If TRUE, turns on ci, classification, and
#'   diagnostics. Does not override explicit FALSE values.
#' @param ... Reserved for argument-name checking. Passing \code{which},
#'   \code{plots}, or \code{show} will produce a helpful error suggesting
#'   \code{diagnostics} instead.
#'
#' @return Invisibly returns a list of class \code{jst_logistic} containing:
#'   \describe{
#'     \item{model}{The fitted \code{glm} object.}
#'     \item{model_type}{Character string \code{logistic}.}
#'     \item{model_frame}{The model frame used to fit the model.}
#'     \item{formula_used}{The formula after dummy expansion.}
#'     \item{coefficients}{Formatted coefficient table (data frame).}
#'     \item{nagelkerke_r2}{Nagelkerke pseudo R-squared.}
#'     \item{cox_snell_r2}{Cox & Snell pseudo R-squared.}
#'     \item{neg2ll}{-2 Log Likelihood.}
#'     \item{aic}{Akaike Information Criterion.}
#'     \item{omnibus}{Named vector: chi_square, df, p.}
#'     \item{n}{Number of observations.}
#'     \item{predicts}{Character string describing what the model predicts.}
#'     \item{dummy_coef_names}{Names of dummy variable columns.}
#'     \item{ref_cats}{Reference category descriptions.}
#'     \item{vif}{Named numeric vector of VIF values, or NULL.}
#'     \item{sample_info}{Pipeline and missing data counts.}
#'   }
#'
#' @examples
#' # With explicit data frame
#' df <- mtcars
#' df$vs01 <- df$vs  # vs is already 0/1
#' jlogistic(vs01 ~ hp + wt, data = df)
#'
#' # Using juse() default
#' juse(df)
#' jlogistic(vs01 ~ hp + wt)
#'
#' \dontrun{
#' # CATEGORICAL PREDICTORS
#' #
#' # The recommended approach: register the variable with jdummy()
#' # before running jlogistic(). This sets categorical treatment
#' # persistently across subsequent analyses.
#' jdummy(SampleData, Program)
#' jlogistic(Outcome ~ Program + ReadingScore)
#'
#' # To choose a non-default reference category:
#' jdummy(SampleData, Program, ref = "Standard")
#' jlogistic(Outcome ~ Program + ReadingScore)
#'
#' # Per-call alternative: categorical = ... applies for one call only.
#' jlogistic(Outcome ~ Program + ReadingScore, categorical = "Program")
#'
#' # FORCING NUMERIC TREATMENT
#' #
#' # Use numeric = ... when a labelled variable should enter as a score.
#' jlogistic(Outcome ~ Age + Employment, numeric = "Age")
#' }
#'
#' @seealso \code{\link{JeffsStatTools}} for the package overview,
#'   workflow conventions, and complete function listing.
#'
#' @export
#' @importFrom stats glm binomial pchisq logLik as.formula
#' @param case.processing.detail Per-call override of the Case
#'   Processing Summary detail tier: one of \code{"none"},
#'   \code{"totals"}, or \code{"per_code"}. \code{NULL} (default)
#'   uses the active \code{joutput()} level default.
jlogistic <- function(formula, data, subset = NULL, labels = NULL,
                      numeric = NULL, categorical = NULL,
                      ci = NULL, classification = FALSE,
                      diagnostics = NULL, full = FALSE,
                      case.processing.detail = NULL, ...) {

  .jst_check_args(
    list(...),
    aliases = c(which = "diagnostics", plots = "diagnostics",
                show = "diagnostics"),
    fn_name = "jlogistic"
  )

  # Resolve default data frame if not specified
  .jst_default_used <- FALSE
  .jst_data_name    <- NULL
  if (missing(data)) {
    resolved <- .jst_resolve_data(envir = parent.frame())
    data <- resolved$data
    .jst_default_used <- TRUE
    .jst_data_name    <- resolved$name
  } else {
    .jst_data_name <- deparse(substitute(data))
  }

  if (full) {
    if (is.null(ci))          ci          <- TRUE
    if (is.null(diagnostics)) diagnostics <- TRUE
    classification <- TRUE
  }

  # Resolve display toggles
  ci           <- .jst_resolve_toggle("ci", ci)
  # Resolve diagnostics toggle
  if (is.character(diagnostics)) {
    show_diag  <- TRUE
    diag_which <- diagnostics
  } else {
    show_diag  <- .jst_resolve_toggle("diagnostics", diagnostics)
    diag_which <- if (show_diag) c("vif") else character(0)
  }

  # Red title
  .cat_red("Logistic Regression\n")
  if (.jst_default_used) .jst_default_note(.jst_data_name)

  # Apply data pipeline (jcomplete, jsubset, subset)
  subset_expr <- substitute(subset)
  pipeline <- .jst_apply_pipeline(data, .jst_data_name, .jst_default_used,
                                  subset_expr = subset_expr, envir = parent.frame())
  data     <- pipeline$data
  .jst_print_msgs(pipeline$msgs)

  model_vars            <- all.vars(formula)
  dv_name               <- model_vars[1]

  # Preserve the original (pre-expansion) variable names for use in
  # missing-by-variable reporting. After dummy expansion, model_vars
  # holds the dummy column names; the user wrote the originals in
  # the formula and the diagnostic should speak the user's language.
  original_formula_vars <- model_vars

  .jst_check_vars(data, model_vars, .jst_data_name)
  # Type gate (Session 46): the response is binary and may be a text factor
  # ("Yes"/"No"), so it passes as categorical here -- the dichotomy check below
  # enforces two levels. Predictors may be numeric or categorical; date/time
  # and complex/list/raw refused throughout. See .jst_check_analysis_var.
  for (.gv in model_vars) .jst_check_analysis_var(data[[.gv]], .gv, FALSE, "a logistic regression")

  # -- Expand registered dummy variables ------------------------------------
  expanded         <- .jst_expand_dummies(data, formula, .jst_data_name)
  data             <- expanded$data
  formula          <- expanded$formula
  ref_cats         <- expanded$ref_cats
  dummy_coef_names <- expanded$dummy_coef_names
  model_vars       <- all.vars(formula)

  # -- Variable type conversion (unified classifier) ------------------------
  # Priority order:
  #   1. jdummy() registrations (already expanded above)
  #   2. numeric/categorical overrides from this call
  #   3. Auto-detection via .jst_is_categorical()
  # DV is always numeric; handled after this loop.
  dv_name  <- all.vars(formula)[1]
  iv_names <- setdiff(model_vars, c(dv_name, dummy_coef_names))

  auto_detected  <- character(0)
  auto_ref_cats  <- character(0)
  auto_cat_regs  <- list()  # in-flight registrations for auto-cat / categorical = vars
  all_ref_cats   <- ref_cats

  # Exclude original variable names that were expanded by jdummy()
  expanded_originals <- character(0)
  dummy_regs <- .jst_get_dummy(.jst_data_name)
  if (!is.null(dummy_regs)) {
    expanded_originals <- vapply(dummy_regs, function(r) r$var_name,
                                 character(1))
  }

  for (v in iv_names) {
    if (v %in% dummy_coef_names)   next
    if (v %in% expanded_originals) next
    if (!(v %in% names(data)))     next

    # --- Override: numeric = "Var" forces continuous ---
    if (!is.null(numeric) && v %in% numeric) {
      if (haven::is.labelled(data[[v]])) {
        data[[v]] <- .jst_as_numeric(data[[v]])
      }
      next
    }

    # --- Override: categorical = "Var" forces categorical ---
    if (!is.null(categorical) && v %in% categorical) {
      reg <- .jst_make_dummy_names(data[[v]], v, ref = "first")
      auto_cat_regs[[v]] <- reg
      for (n in reg$notes) cat(n, "\n", sep = "")
      for (w in reg$warnings_msg) warning(w, call. = FALSE)
      auto_ref_cats <- c(auto_ref_cats,
                         paste0(v, " = ", reg$ref_label, " (first category)"))
      next
    }

    # --- Auto-detection via unified classifier ---
    if (.jst_is_categorical(data[[v]], v, .jst_data_name)) {
      reg <- .jst_make_dummy_names(data[[v]], v, ref = "first")
      auto_cat_regs[[v]] <- reg
      for (n in reg$notes) cat(n, "\n", sep = "")
      for (w in reg$warnings_msg) warning(w, call. = FALSE)
      auto_detected <- c(auto_detected, v)
      auto_ref_cats <- c(auto_ref_cats,
                         paste0(v, " = ", reg$ref_label, " (first category)"))
    } else {
      # Not intent-categorical. Strip haven class if present, leave as
      # numeric in the model.
      if (haven::is.labelled(data[[v]])) {
        data[[v]] <- .jst_as_numeric(data[[v]])
      }
      # Check for dichotomy first: dichotomies are valid as numeric IVs
      # in logistic regression (the slope on the log-odds is the
      # contrast). They do not need dummy-coding. The discrete-integer
      # warning would be misleading for them. Soft coding-specific
      # warnings only:
      #   - 0/1, factor, character, logical: no warning, clean run.
      #   - 1/2: model runs correctly, but recoding to 0/1 makes the
      #     intercept easier to interpret.
      #   - other (e.g., 5/10): non-standard coding; slope represents
      #     per-unit change, recoding to 0/1 advised.
      iv_dich <- .jst_is_dichotomy(data[[v]])
      if (iv_dich$is_dichotomy) {
        if (iv_dich$coding == "1/2") {
          warning(
            v, " is a 1/2 dichotomy. The model runs correctly, but ",
            "recoding to 0/1 makes the intercept easier to interpret. ",
            "To recode:\n\n",
            "  ", .jst_data_name, "$", v, "R <- jrecode(",
              .jst_data_name, ", ", v, ", map = \"1=0; 2=1\")\n",
            "  jlogistic(", deparse(formula[[2]]), " ~ ", v, "R)\n\n",
            "For other approaches (jdummy, categorical = ...) see ?jlogistic.",
            call. = FALSE
          )
        } else if (iv_dich$coding == "other") {
          warning(
            v, " is a dichotomy with non-standard coding. The slope ",
            "represents per-unit change rather than the contrast between ",
            "categories. Consider recoding to 0/1 for clearer interpretation. ",
            "Adapt the values below to match this variable's actual codes:\n\n",
            "  ", .jst_data_name, "$", v, "R <- jrecode(",
              .jst_data_name, ", ", v, ", map = \"<oldval1>=0; <oldval2>=1\")\n",
            "  jlogistic(", deparse(formula[[2]]), " ~ ", v, "R)\n\n",
            "For other approaches (jdummy, categorical = ...) see ?jlogistic.",
            call. = FALSE
          )
        }
        # 0/1, factor, character, logical: no warning.
      } else if (.jst_is_discrete_integer(data[[v]], v, .jst_data_name)) {
        # Non-dichotomous but categorical-like structure: emit the
        # informational warning so the user can confirm continuous
        # treatment or switch to categorical.
        warning(
          v, " has categorical-like structure (small-range integer ",
          "or labelled values) but is entering the model as a continuous ",
          "predictor. If continuous treatment is intended (e.g. a Likert ",
          "scale), no action is needed. To treat as categorical, register ",
          "with jdummy:\n\n",
          "  jdummy(", .jst_data_name, ", ", v, ")\n",
          "  jlogistic(", deparse(formula), ")\n\n",
          "For other approaches (categorical = ...) see ?jlogistic.",
          call. = FALSE
        )
      }
    }
  }

  all_ref_cats <- c(ref_cats, auto_ref_cats)

  # -- Apply auto-categorical expansions ------------------------------------
  # Same pattern as jlm: in-flight registrations built above are now
  # applied via .jst_expand_one_dummy() so dummy column names are uniform
  # across pathways.
  if (length(auto_cat_regs) > 0) {
    formula_str <- deparse(formula, width.cutoff = 500)
    for (vname in names(auto_cat_regs)) {
      reg <- auto_cat_regs[[vname]]
      reg$var_name <- vname
      expanded2 <- .jst_expand_one_dummy(data, formula_str, reg)
      data             <- expanded2$data
      formula_str      <- expanded2$formula_str
      dummy_coef_names <- c(dummy_coef_names, expanded2$dummy_coef_names)
    }
    formula    <- stats::as.formula(formula_str)
    model_vars <- all.vars(formula)
  }

  if (haven::is.labelled(data[[dv_name]])) {
    data[[dv_name]] <- .jst_as_numeric(data[[dv_name]])
  }

  # -- Validate DV is coded 0/1 ---------------------------------------------
  dv_vals     <- data[[dv_name]][!is.na(data[[dv_name]])]
  unique_vals <- sort(unique(dv_vals))

  if (!identical(unique_vals, c(0, 1))) {
    # Determine what kind of problem it is
    n_unique <- length(unique_vals)

    # Check for suspected coded missings among unique values
    if (n_unique >= 2) {
      non_binary <- setdiff(unique_vals, c(0, 1))
      suspicious <- .jst_detect_suspicious_values(dv_vals, dv_name)
      coded_miss <- intersect(non_binary, suspicious)
    } else {
      non_binary <- unique_vals
      coded_miss <- numeric(0)
    }

    # Get value labels for display if available
    orig_dv   <- pipeline$data[[dv_name]]
    dv_labels <- NULL
    if (haven::is.labelled(orig_dv)) {
      dv_labels <- labelled::val_labels(orig_dv)
    }

    if (n_unique == 2 && all(unique_vals %in% c(1, 2))) {
      # Common 1/2 coding — suggest recode to 0/1
      if (!is.null(dv_labels) && length(dv_labels) >= 2) {
        label_1 <- names(dv_labels[dv_labels == 1])
        label_2 <- names(dv_labels[dv_labels == 2])
        if (length(label_1) == 0) label_1 <- "1"
        if (length(label_2) == 0) label_2 <- "2"
        recode_labels <- paste0(", labels = \"0=", label_1, "; 1=", label_2, "\"")
      } else {
        label_1 <- "1"
        label_2 <- "2"
        recode_labels <- ""
      }
      stop(paste0(
        "'", dv_name, "' is coded 1/2. Logistic regression requires 0/1 coding.\n",
        "Recode before running jlogistic():\n",
        "  ", .jst_data_name, "$", dv_name, "R <- jrecode(, ", dv_name,
        ", map = \"1=0; 2=1\"", recode_labels, ")\n",
        "Then use ", dv_name, "R as your dependent variable."
      ), call. = FALSE)

    } else if (length(coded_miss) > 0) {
      # Has suspected coded missings
      miss_str <- paste(coded_miss, collapse = ", ")
      stop(paste0(
        "'", dv_name, "' has ", n_unique, " unique values (",
        paste(unique_vals, collapse = ", "),
        "). The dependent variable must have exactly 2 categories coded 0/1.\n",
        "The value(s) ", miss_str, " may be coded missing value(s).\n",
        "Convert to NA before running jlogistic():\n",
        "  ", .jst_data_name, "$", dv_name, "R <- jrecode(, ", dv_name,
        ", map = \"", paste0(coded_miss, "=NA", collapse = "; "),
        "; else=copy\")"
      ), call. = FALSE)

    } else {
      # Generic — wrong number of categories or wrong codes
      stop(paste0(
        "'", dv_name, "' has values: ",
        paste(unique_vals, collapse = ", "),
        ". Logistic regression requires a binary variable coded 0/1.\n",
        "Use jrecode() to create a 0/1 coded version before running jlogistic()."
      ), call. = FALSE)
    }
  }

  # -- Reference category and variable label reporting -----------------------
  if (length(all_ref_cats) > 0) {
    cat("\n  Reference categories:\n")
    for (rc in all_ref_cats) cat("    ", rc, "\n", sep = "")
  }

  if (length(auto_detected) > 0) {
    cat("  (", paste(auto_detected, collapse = ", "),
        " auto-detected as categorical. To choose a different\n",
        "   reference category, use jdummy() before running jlogistic().\n",
        "   If a variable should be numeric, use: numeric = \"",
        auto_detected[1], "\")\n", sep = "")
  }

  if (!is.null(categorical) && length(categorical) > 0) {
    cat_in_model <- intersect(categorical, sub(" = .*", "", auto_ref_cats))
    if (length(cat_in_model) > 0) {
      cat("  (", paste(cat_in_model, collapse = ", "),
          " treated as categorical via categorical argument.\n",
          "   To choose a different reference, use jdummy() before running jlogistic().)\n",
          sep = "")
    }
  }
  if (length(all_ref_cats) > 0) cat("\n")

  # -- Build analysis-level data frame and sample_info early so the Case
  # -- Processing Summary can use them.
  mf <- stats::model.frame(formula, data = data,
                           na.action = stats::na.omit)

  sample_info <- .jst_build_sample_info(
    pipeline_counts = pipeline$pipeline_counts,
    data            = pipeline$data,
    analysis_vars   = original_formula_vars,
    n_analysis      = nrow(mf)
  )

  # Case Processing Summary
  .jst_print_case_processing(sample_info, analysis_type = "listwise", detail = case.processing.detail)

  if (.jst_resolve_toggle("var.labels", labels)) {
    .print_var_labels(data, all.vars(formula))
  }

  # Capture DV label for "1" category (before model fitting, more reliable)
  dv_label_1 <- NULL
  orig_dv    <- pipeline$data[[dv_name]]
  if (haven::is.labelled(orig_dv)) {
    all_labels <- labelled::val_labels(orig_dv)
    if (!is.null(all_labels) && length(all_labels) > 0) {
      match_idx <- which(as.numeric(all_labels) == 1)
      if (length(match_idx) >= 1) {
        candidate <- names(all_labels)[match_idx[1]]
        if (!is.null(candidate) && nchar(candidate) > 0) {
          dv_label_1 <- candidate
        }
      }
    }
  }

  model <- stats::glm(formula, data = data, family = stats::binomial,
                       na.action = stats::na.omit)
  model_summary <- summary(model)
  n_obs         <- stats::nobs(model)

  # -- What does the model predict? ------------------------------------------
  predicts_str <- if (!is.null(dv_label_1)) dv_label_1 else "1"
  cat("Model predicts: ", predicts_str, "\n\n", sep = "")

  # -- Omnibus test (model vs null) ------------------------------------------
  null_model  <- stats::glm(as.formula(paste(dv_name, "~ 1")),
                             data = data, family = stats::binomial,
                             na.action = stats::na.omit)
  ll_null     <- as.numeric(stats::logLik(null_model))
  ll_model    <- as.numeric(stats::logLik(model))
  chi_sq      <- -2 * (ll_null - ll_model)
  omnibus_df  <- model$df.null - model$df.residual
  omnibus_p   <- stats::pchisq(chi_sq, df = omnibus_df, lower.tail = FALSE)
  omnibus_fmt <- if (!is.na(omnibus_p) && omnibus_p < 0.001) {
    "<.001"
  } else {
    sprintf("%.3f", omnibus_p)
  }

  omnibus_table <- data.frame(
    Chi_Square = round(chi_sq, 3),
    df         = omnibus_df,
    p          = omnibus_fmt,
    stringsAsFactors = FALSE,
    row.names = NULL
  )

  .jst_print_table(omnibus_table,
                   caption = "Omnibus Test of Model Coefficients",
                   col.names = c("Chi-Square", "df", "p"),
                   row.names = FALSE)
  cat("\n")

  # -- Model summary --------------------------------------------------------
  neg2ll       <- -2 * ll_model
  aic          <- stats::AIC(model)
  cox_snell_r2 <- 1 - exp((2 / n_obs) * (ll_null - ll_model))
  max_r2       <- 1 - exp((2 / n_obs) * ll_null)
  nagelkerke_r2 <- cox_snell_r2 / max_r2

  summary_table <- data.frame(
    neg2LL     = round(neg2ll, 3),
    CoxSnellR2 = round(cox_snell_r2, 3),
    NagelkerkeR2 = round(nagelkerke_r2, 3),
    AIC        = round(aic, 3),
    stringsAsFactors = FALSE,
    row.names = NULL
  )

  .jst_print_table(summary_table,
                   caption = "Model Summary",
                   col.names = c("-2 Log Likelihood", "Cox & Snell R\u00b2",
                                 "Nagelkerke R\u00b2", "AIC"),
                   row.names = FALSE)
  cat("\n")

  # -- Coefficients table ----------------------------------------------------
  coefs    <- as.data.frame(model_summary$coefficients, stringsAsFactors = FALSE)
  colnames(coefs) <- c("b", "SE", "z", "P")

  # Wald chi-square = z^2
  wald <- coefs$z^2

  p_num <- suppressWarnings(as.numeric(coefs$P))
  p_fmt <- ifelse(!is.na(p_num) & p_num < 0.001, "<.001",
                  ifelse(is.na(p_num), "<.001", sprintf("%.3f", p_num)))

  exp_b <- exp(coefs$b)

  fmt3 <- function(x) sprintf("%.3f", as.numeric(x))

  # Clean up factor coefficient names for readability
  rownames(coefs) <- .jst_clean_coef_names(rownames(coefs), data,
                                            all.vars(formula)[-1])

  out_coefs <- data.frame(
    b      = fmt3(coefs$b),
    SE     = fmt3(coefs$SE),
    Wald   = fmt3(wald),
    df     = rep("1", nrow(coefs)),
    p      = p_fmt,
    Exp_B  = fmt3(exp_b),
    stringsAsFactors = FALSE,
    row.names = rownames(coefs)
  )

  col_names <- c("b", "SE", "Wald", "df", "p", "Exp(B)")

  if (ci) {
    ci_vals <- suppressMessages(stats::confint(model))
    exp_ci_lower <- exp(ci_vals[, 1])
    exp_ci_upper <- exp(ci_vals[, 2])
    out_coefs$CI_Lower <- fmt3(exp_ci_lower)
    out_coefs$CI_Upper <- fmt3(exp_ci_upper)
    col_names <- c(col_names, "95% CI Lower", "95% CI Upper")
  }

  cat("\n")
  .jst_print_table(out_coefs,
                   caption   = "Coefficients",
                   col.names = col_names,
                   align     = rep("c", length(col_names)),
                   row.names = TRUE)

  cat("\nNumber of observations: ", n_obs, "\n", sep = "")

  # -- Classification table (optional) ---------------------------------------
  if (classification) {
    predicted_probs  <- stats::fitted(model)
    predicted_class  <- ifelse(predicted_probs >= 0.5, 1, 0)
    observed         <- stats::model.response(mf)

    tp <- sum(predicted_class == 1 & observed == 1)
    tn <- sum(predicted_class == 0 & observed == 0)
    fp <- sum(predicted_class == 1 & observed == 0)
    fn <- sum(predicted_class == 0 & observed == 1)

    class_table <- data.frame(
      Observed   = c("0", "1", "Overall"),
      Pred_0     = c(tn, fn, NA),
      Pred_1     = c(fp, tp, NA),
      Pct_Correct = c(
        round(tn / (tn + fp) * 100, 1),
        round(tp / (tp + fn) * 100, 1),
        round((tp + tn) / n_obs * 100, 1)
      ),
      stringsAsFactors = FALSE,
      row.names = NULL
    )

    cat("\n")
    .jst_print_table(class_table,
                     caption = "Classification Table (cutoff = 0.50)",
                     col.names = c("Observed", "Predicted 0", "Predicted 1",
                                   "% Correct"),
                     row.names = FALSE)
  }

  # -- Diagnostics (VIF) -----------------------------------------------------
  vif_values <- NULL
  if (show_diag && "vif" %in% diag_which) {
    # Compute VIF from the linear predictor model matrix
    X <- stats::model.matrix(model)[, -1, drop = FALSE]
    if (ncol(X) >= 2) {
      vif_values <- tryCatch({
        R <- stats::cor(X)
        vif_vals <- diag(solve(R))
        names(vif_vals) <- colnames(X)
        vif_vals
      }, error = function(e) {
        warning("VIF could not be computed (possible perfect collinearity).",
                call. = FALSE)
        NULL
      })

      if (!is.null(vif_values)) {
        cat("\n")
        vif_df <- data.frame(
          Variable = names(vif_values),
          VIF      = round(vif_values, 3),
          stringsAsFactors = FALSE,
          row.names = NULL
        )
        .jst_print_table(vif_df,
                         caption = "VIF (Variance Inflation Factors)",
                         row.names = FALSE)

        # Targeted notes for VIF > 10
        high_vif <- vif_values[vif_values > 10]
        if (length(high_vif) > 0) {
          cat("\n")
          for (nm in names(high_vif)) {
            inflation <- round(sqrt(high_vif[nm]), 1)
            cat(nm, " (VIF = ", round(high_vif[nm], 1),
                "): standard error inflated by a factor of ", inflation, ".\n",
                "  If you need to interpret this coefficient specifically, consider\n",
                "  whether the collinearity is a concern for your research question.\n",
                sep = "")
          }
        }
      }
    }
  } else if (show_diag) {
    # Compute VIF silently for return object
    X <- stats::model.matrix(model)[, -1, drop = FALSE]
    if (ncol(X) >= 2) {
      vif_values <- tryCatch({
        R <- stats::cor(X)
        vif_vals <- diag(solve(R))
        names(vif_vals) <- colnames(X)
        vif_vals
      }, error = function(e) NULL)
    }
  }

  cat("\n")
  ret <- list(
    model           = model,
    model_type      = "logistic",
    model_frame     = mf,
    formula_used    = formula,
    coefficients    = out_coefs,
    nagelkerke_r2   = nagelkerke_r2,
    cox_snell_r2    = cox_snell_r2,
    neg2ll          = neg2ll,
    aic             = aic,
    omnibus         = c(chi_square = chi_sq, df = omnibus_df, p = omnibus_p),
    n               = n_obs,
    predicts        = predicts_str,
    dummy_coef_names = dummy_coef_names,
    ref_cats        = all_ref_cats,
    vif             = vif_values,
    sample_info     = sample_info
  )
  class(ret) <- "jst_logistic"
  invisible(ret)
}


# -- jcrosstab -----------------------------------------------------------------


# -- jscreen ------------------------------------------------------------------


# -- jalpha -------------------------------------------------------------------


# =============================================================================
#  SCALE CONSTRUCTION
# =============================================================================


#' Cronbach's Alpha Reliability Analysis
#'
#' Computes Cronbach's alpha and prints SPSS-style reliability output
#' including a case processing summary, overall alpha, item statistics,
#' and item-total statistics with alpha-if-item-deleted. Built from
#' scratch with no external package dependencies beyond base R.
#' Handles haven-labelled variables automatically. Detects potentially
#' reverse-coded or misfit items.
#'
#' A red "Reliability Analysis" title is printed first, followed by the
#' case processing summary, overall alpha, item statistics, and
#' item-total statistics.
#'
#' @param data A data frame.
#' @param ... Unquoted variable names (scale items) within \code{data}.
#' @param subset An optional unquoted logical expression (e.g.
#'   \code{Group == 1}) to subset cases for this call only. Applied after
#'   jcomplete and jsubset. Does not affect other function calls.
#' @param labels Logical. If TRUE (default), prints variable labels
#'   when available.
#'
#' @return Invisibly returns a list of class \code{jst_alpha} containing:
#'   \code{alpha} (Cronbach's alpha), \code{n_items}, \code{n_used},
#'   \code{n_excluded}, \code{item_statistics}, \code{item_total_statistics},
#'   and \code{sample_info} (pipeline and missing data counts).
#'   item statistics data frame, and item-total statistics data frame.
#'
#' @examples
#' # With explicit data frame
#' jalpha(attitude, rating, complaints, privileges, learning, raises)
#'
#' # Using juse() default
#' juse(attitude)
#' jalpha(rating, complaints, privileges, learning, raises)
#'
#' @seealso \code{\link{JeffsStatTools}} for the package overview,
#'   workflow conventions, and complete function listing.
#'
#' @export
#' @param case.processing.detail Per-call override of the Case
#'   Processing Summary detail tier: one of \code{"none"},
#'   \code{"totals"}, or \code{"per_code"}. \code{NULL} (default)
#'   uses the active \code{joutput()} level default.
jalpha <- function(data, ..., subset = NULL, labels = NULL,
                   case.processing.detail = NULL) {

  # Resolve the first argument: explicit data frame, juse default,
  # or bare-symbol-as-variable-name (leading comma omitted).
  arg1 <- .jst_resolve_first_arg(
    data_sub      = substitute(data),
    data_missing  = missing(data),
    fn_name       = "jalpha",
    envir         = parent.frame(),
    accept_vector = FALSE
  )

  data              <- arg1$data
  .jst_data_name    <- arg1$name
  .jst_default_used <- arg1$mode %in% c("default", "symbol_with_default")

  variables <- rlang::enquos(...)

  # Leading-comma-omitted: prepend the captured symbol to variables list
  if (arg1$mode == "symbol_with_default") {
    extra_quo <- rlang::new_quosure(arg1$first_arg_sub,
                                    env = parent.frame())
    variables <- c(list(extra_quo), variables)
    class(variables) <- "quosures"
  }

  variable_names <- vapply(variables, rlang::quo_name, character(1))

  .jst_check_vars(data, variable_names, .jst_data_name)
  # Type gate (Session 46): scale items must be numeric; refuse text, dates,
  # and complex/list/raw. See .jst_check_analysis_var.
  for (.gv in variable_names) .jst_check_analysis_var(data[[.gv]], .gv, TRUE, "Cronbach's alpha")

  if (length(variable_names) < 2) {
    stop("jalpha() requires at least 2 items. Only 1 was provided.", call. = FALSE)
  }

  # Red title
  .cat_red("Reliability Analysis\n")
  if (.jst_default_used) .jst_default_note(.jst_data_name)

  # Apply data pipeline (jcomplete, jsubset, subset)
  subset_expr <- substitute(subset)
  pipeline <- .jst_apply_pipeline(data, .jst_data_name, .jst_default_used,
                                  subset_expr = subset_expr, envir = parent.frame())
  data     <- pipeline$data
  .jst_print_msgs(pipeline$msgs)

  items <- data[, variable_names, drop = FALSE]

  for (v in variable_names) {
    if (haven::is.labelled(items[[v]])) {
      items[[v]] <- .jst_as_numeric(items[[v]])
    }
  }

  complete_mask  <- stats::complete.cases(items)
  n_total        <- nrow(items)
  n_used         <- sum(complete_mask)
  n_excluded     <- n_total - n_used
  items_complete <- items[complete_mask, ]

  # Build sample_info early so the Case Processing Summary can use it.
  sample_info <- .jst_build_sample_info(
    pipeline_counts = pipeline$pipeline_counts,
    data            = pipeline$data,
    analysis_vars   = variable_names,
    n_analysis      = n_used
  )

  # Case Processing Summary (standard CPS chain; jalpha uses listwise
  # deletion across all scale items)
  .jst_print_case_processing(sample_info, analysis_type = "listwise", detail = case.processing.detail)

  # Overall Cronbach's Alpha
  k             <- ncol(items_complete)
  item_vars     <- sapply(items_complete, stats::var)
  total_var     <- stats::var(rowSums(items_complete))
  alpha_overall <- round((k / (k - 1)) * (1 - sum(item_vars) / total_var), 3)

  alpha_table <- data.frame(
    Alpha   = alpha_overall,
    N_Items = k,
    stringsAsFactors = FALSE
  )

  .jst_print_table(alpha_table,
                   caption = "Reliability Statistics",
                   col.names = c("Cronbach's Alpha", "N of Items"),
                   row.names = FALSE)
  cat("\n")

  # Variable Labels
  if (.jst_resolve_toggle("var.labels", labels)) {
    .print_var_labels(data, variable_names)
  }

  # Item Statistics
  item_stats <- data.frame(
    Item = variable_names,
    Mean = round(colMeans(items_complete), 3),
    SD   = round(sapply(items_complete, stats::sd), 3),
    N    = n_used,
    stringsAsFactors = FALSE,
    row.names = NULL
  )

  .jst_print_table(item_stats,
                   caption = "Item Statistics",
                   row.names = FALSE)
  cat("\n")

  # Item-Total Statistics
  total_scores    <- rowSums(items_complete)

  item_total_rows <- lapply(seq_along(variable_names), function(i) {
    item_name   <- variable_names[i]
    item_col    <- items_complete[[i]]
    rest_total  <- total_scores - item_col
    r_corrected <- round(stats::cor(item_col, rest_total), 3)

    remaining <- items_complete[, -i, drop = FALSE]
    k_r <- ncol(remaining)
    alpha_deleted <- if (k_r < 2) {
      NA
    } else {
      item_vars_r <- sapply(remaining, stats::var)
      total_var_r <- stats::var(rowSums(remaining))
      round((k_r / (k_r - 1)) * (1 - sum(item_vars_r) / total_var_r), 3)
    }

    data.frame(
      Item                   = item_name,
      Corrected_Item_Total_r = r_corrected,
      Alpha_If_Deleted       = alpha_deleted,
      stringsAsFactors       = FALSE
    )
  })

  item_total_table <- do.call(rbind, item_total_rows)

  # Diagnostic Warning
  neg_items <- item_total_table$Item[item_total_table$Corrected_Item_Total_r < 0]
  pos_items <- item_total_table$Item[item_total_table$Corrected_Item_Total_r >= 0]

  if (length(neg_items) > 0) {
    n_neg <- length(neg_items)
    n_pos <- length(pos_items)

    if (n_neg <= n_pos) {
      warning(paste0(
        "The following item(s) are negatively correlated with the rest ",
        "of the scale: ", paste(neg_items, collapse = ", "),
        ". This may indicate that these items need to be reverse-coded, ",
        "or that they do not belong in the scale. Examine the item-total ",
        "statistics table and the item content to determine the appropriate action."),
        call. = FALSE)
    } else {
      warning(paste0(
        "The majority of items are negatively correlated with the scale total. ",
        "This usually means that one or more items are coded in the opposite ",
        "direction or do not belong in the scale. Check the following item(s) ",
        "which are positively correlated while most others are not: ",
        paste(pos_items, collapse = ", ")),
        call. = FALSE)
    }
    cat("\n")
  }

  .jst_print_table(item_total_table,
                   caption = "Item-Total Statistics",
                   col.names = c("Item", "Corrected Item-Total r",
                                 "Alpha if Item Deleted"),
                   row.names = FALSE)

  cat("\n")

  ret <- list(
    alpha                 = alpha_overall,
    n_items               = k,
    n_used                = n_used,
    n_excluded            = n_excluded,
    item_statistics       = item_stats,
    item_total_statistics = item_total_table,
    sample_info           = sample_info
  )
  class(ret) <- "jst_alpha"
  invisible(ret)
}


# -- jsum / javg internal helper -----------------------------------------------

#' Internal helper: resolve variable names from enquos, expanding colon ranges
#'
#' Handles both explicit variable names (var1, var2, var3) and colon notation
#' (var1:var3) which expands to all columns between the two endpoints in
#' column order. Named arguments (e.g. min.valid, var.label) are excluded.
#'
#' @param quos_list A list of quosures from rlang::enquos(...).
#' @param data The data frame to resolve column names against.
#' @param fn_name Character. The calling function name for error messages.
#'
#' @return A list with two components:
#'   \describe{
#'     \item{var_names}{Character vector of all resolved variable names.}
#'     \item{label_parts}{Character vector of label-friendly descriptions,
#'       using "X to Y" for colon ranges and plain names for explicit
#'       variables.}
#'   }
#'
#' @keywords internal
.jst_resolve_varrange <- function(quos_list, data, fn_name, data_name = NULL) {

  all_cols    <- names(data)
  var_names   <- character(0)
  label_parts <- character(0)

  # Name the data frame in not-found / ordering messages when the caller
  # knows it, matching the package-wide convention (.jst_check_vars names the
  # frame); fall back to the generic phrasing only when no name is available.
  frame_ref <- if (!is.null(data_name) && nzchar(data_name)) {
    data_name
  } else {
    "the data frame"
  }

  for (q in quos_list) {
    expr <- rlang::quo_get_expr(q)

    if (is.call(expr) && identical(expr[[1]], as.name(":"))) {
      # Colon notation: var1:var6
      start_name <- as.character(expr[[2]])
      end_name   <- as.character(expr[[3]])

      start_idx <- match(start_name, all_cols)
      end_idx   <- match(end_name, all_cols)

      if (is.na(start_idx)) {
        stop(
          "Variable '", start_name, "' not found in ", frame_ref, ".\n",
          "Check spelling and capitalization.",
          call. = FALSE
        )
      }
      if (is.na(end_idx)) {
        stop(
          "Variable '", end_name, "' not found in ", frame_ref, ".\n",
          "Check spelling and capitalization.",
          call. = FALSE
        )
      }

      if (start_idx > end_idx) {
        stop(
          "In ", start_name, ":", end_name, ", '", start_name,
          "' comes after '", end_name, "' in the column order of ", frame_ref, ".\n",
          "Reverse the order: ", end_name, ":", start_name,
          call. = FALSE
        )
      }

      expanded <- all_cols[start_idx:end_idx]
      var_names   <- c(var_names, expanded)
      label_parts <- c(label_parts, paste0(start_name, " to ", end_name))

    } else {
      # Simple variable name
      vname <- rlang::quo_name(q)
      var_names   <- c(var_names, vname)
      label_parts <- c(label_parts, vname)
    }
  }

  list(var_names = var_names, label_parts = label_parts)
}


# -- jsum ----------------------------------------------------------------------

#' Compute a row-wise sum across multiple variables
#'
#' @description
#' \code{jsum()} computes the sum of values across multiple variables for each
#' case (row) in the data frame. This is typically used to create composite
#' scores from a set of related items (e.g. summing 6 survey items into a
#' total scale score).
#'
#' By default, cases with any missing values receive \code{NA}. Use the
#' \code{min.valid} argument to allow partial sums --- for example,
#' \code{min.valid = 1} returns the sum of available values as long as at
#' least one item is non-missing.
#'
#' Variables can be listed individually or using colon notation to select a
#' range of consecutive columns (e.g. \code{Attitude1:Attitude6}).
#'
#' @param data A data frame, or omit to use the \code{juse()} default.
#' @param ... Unquoted variable names. Use colon notation (e.g.
#'   \code{Attitude1:Attitude6}) to select a range of consecutive columns.
#' @param min.valid Integer (optional). The minimum number of non-missing
#'   values required to compute a sum. If a case has fewer non-missing
#'   values, the result is \code{NA}. If omitted, all values must be
#'   non-missing (equivalent to setting min.valid to the number of variables).
#' @param var.label Character string (optional). A variable label to attach
#'   to the result. If omitted, an auto-generated label is used.
#'
#' @return A numeric vector the same length as \code{nrow(data)}, suitable for
#'   assigning to a new column:
#'   \code{MyData$Total <- jsum(Var1, Var2, Var3)}.
#'
#' @examples
#' \dontrun{
#' # Set the default data frame (so you can omit it in function calls)
#' juse(MyData)
#'
#' # Sum three variables (all must be non-missing)
#' MyData$Total <- jsum(Score1, Score2, Score3)
#'
#' # Sum with partial data allowed (at least 1 non-missing)
#' MyData$Total <- jsum(Score1, Score2, Score3, min.valid = 1)
#'
#' # Sum using colon range for consecutive columns
#' MyData$ScaleTotal <- jsum(Attitude1:Attitude6)
#'
#' # Mix colon ranges and explicit names (e.g. after reverse-coding an item)
#' MyData$ScaleTotal <- jsum(Attitude1:Attitude3, Attitude4R, Attitude5:Attitude6)
#'
#' # With a custom variable label
#' MyData$Total <- jsum(Score1, Score2, Score3,
#'                      var.label = "Total Score")
#'
#' # With an explicit data frame (instead of using juse default)
#' MyData$Total <- jsum(MyData, Score1, Score2, Score3)
#' }
#'
#' @seealso \code{\link{javg}} for computing row-wise means.
#' @seealso \code{\link{JeffsStatTools}} for the package overview,
#'   workflow conventions, and complete function listing.
#'
#' @export
jsum <- function(data, ..., min.valid = NULL, var.label = NULL) {

  # Resolve the first argument: explicit data frame, juse default,
  # or bare-symbol-as-variable-name (leading comma omitted).
  arg1 <- .jst_resolve_first_arg(
    data_sub      = substitute(data),
    data_missing  = missing(data),
    fn_name       = "jsum",
    envir         = parent.frame(),
    accept_vector = FALSE
  )

  data           <- arg1$data
  .jst_data_name <- arg1$name

  # Resolve variable names (handles colon ranges)
  quos_list <- rlang::enquos(...)

  # Leading-comma-omitted: prepend the captured symbol to quos list
  if (arg1$mode == "symbol_with_default") {
    extra_quo <- rlang::new_quosure(arg1$first_arg_sub,
                                    env = parent.frame())
    quos_list <- c(list(extra_quo), quos_list)
    class(quos_list) <- "quosures"
  }

  resolved    <- .jst_resolve_varrange(quos_list, data, "jsum", .jst_data_name)
  var_names   <- resolved$var_names
  label_parts <- resolved$label_parts

  if (length(var_names) < 2) {
    stop("jsum() requires at least 2 variables.", call. = FALSE)
  }

  .jst_check_vars(data, var_names, .jst_data_name)

  # Extract columns and convert any haven-labelled to numeric
  items <- data[, var_names, drop = FALSE]
  for (v in var_names) {
    items[[v]] <- .jst_as_numeric(items[[v]])
  }

  n_vars  <- length(var_names)
  n_cases <- nrow(items)

  # Determine minimum valid threshold
  if (is.null(min.valid)) {
    threshold <- n_vars   # Default: all must be non-missing
  } else {
    threshold <- as.integer(min.valid)
    if (is.na(threshold) || threshold < 1) {
      stop("min.valid must be a positive integer.", call. = FALSE)
    }
    if (threshold > n_vars) {
      stop(
        "min.valid (", threshold, ") cannot exceed the number of variables (",
        n_vars, ").",
        call. = FALSE
      )
    }
  }

  # Compute row-wise sums
  mat        <- as.matrix(items)
  non_na     <- rowSums(!is.na(mat))
  row_sums   <- rowSums(mat, na.rm = TRUE)
  result     <- ifelse(non_na >= threshold, row_sums, NA_real_)

  # Count cases set to NA due to missingness
  n_na_result <- sum(is.na(result) & non_na > 0)
  n_all_na    <- sum(non_na == 0)
  n_valid     <- sum(!is.na(result))
  n_partial   <- if (!is.null(min.valid)) sum(!is.na(result) & non_na < n_vars) else 0L

  # Summary message
  msg_parts <- paste0(
    "Sum of ", n_vars, " variables computed for ", n_cases, " cases"
  )

  detail_parts <- character(0)
  if (!is.null(min.valid)) {
    if (n_partial > 0) {
      detail_parts <- c(detail_parts,
        paste0(n_partial, " case", if (n_partial != 1) "s" else "",
               " used partial data"))
    }
  }
  if (n_na_result > 0) {
    detail_parts <- c(detail_parts,
      paste0(n_na_result, " set to NA due to missing values"))
  }
  if (n_all_na > 0) {
    detail_parts <- c(detail_parts,
      paste0(n_all_na, " set to NA (all values missing)"))
  }

  if (length(detail_parts) > 0) {
    if (!is.null(min.valid)) {
      msg_parts <- paste0(msg_parts, " (min.valid = ", threshold, ": ",
                          paste(detail_parts, collapse = ", "), ").")
    } else {
      msg_parts <- paste0(msg_parts, " (", paste(detail_parts, collapse = ", "), ").")
    }
  } else {
    msg_parts <- paste0(msg_parts, ".")
  }
  message(msg_parts)

  # Attach variable label
  if (!is.null(var.label)) {
    labelled::var_label(result) <- var.label
  } else {
    auto_label <- paste0("Sum of ", paste(label_parts, collapse = ", "))
    labelled::var_label(result) <- auto_label
  }

  return(invisible(result))
}


# -- javg ----------------------------------------------------------------------

#' Compute a row-wise mean across multiple variables
#'
#' @description
#' \code{javg()} computes the mean of values across multiple variables for each
#' case (row) in the data frame. This is typically used to create scale means
#' from a set of related items.
#'
#' By default, cases with any missing values receive \code{NA}. Use the
#' \code{min.valid} argument to allow partial means --- for example,
#' \code{min.valid = 1} computes the mean of available values as long as
#' at least one item is non-missing.
#'
#' By default, the denominator is the number of non-missing values for each
#' case. Use \code{fixed = TRUE} to always divide by the total number of
#' variables regardless of missing values.
#'
#' Variables can be listed individually or using colon notation to select a
#' range of consecutive columns (e.g. \code{Attitude1:Attitude6}).
#'
#' @param data A data frame, or omit to use the \code{juse()} default.
#' @param ... Unquoted variable names. Use colon notation (e.g.
#'   \code{Attitude1:Attitude6}) to select a range of consecutive columns.
#' @param min.valid Integer (optional). The minimum number of non-missing
#'   values required to compute a mean. If a case has fewer non-missing
#'   values, the result is \code{NA}. If omitted, all values must be
#'   non-missing (equivalent to setting min.valid to the number of variables).
#' @param fixed Logical. If \code{FALSE} (default), the denominator for each
#'   case is the number of non-missing values (i.e. the mean adjusts for
#'   missing data). If \code{TRUE}, the denominator is always the total
#'   number of variables (i.e. missing values effectively count as zero).
#' @param var.label Character string (optional). A variable label to attach
#'   to the result. If omitted, an auto-generated label is used.
#'
#' @return A numeric vector the same length as \code{nrow(data)}, suitable for
#'   assigning to a new column:
#'   \code{MyData$ScaleMean <- javg(Var1, Var2, Var3)}.
#'
#' @examples
#' \dontrun{
#' # Set the default data frame (so you can omit it in function calls)
#' juse(MyData)
#'
#' # Mean of three variables (all must be non-missing)
#' MyData$Avg <- javg(Score1, Score2, Score3)
#'
#' # Mean with partial data allowed (at least 1 non-missing)
#' MyData$Avg <- javg(Score1, Score2, Score3, min.valid = 1)
#'
#' # Mean using colon range for consecutive columns
#' MyData$ScaleMean <- javg(Attitude1:Attitude6)
#'
#' # Mix colon ranges and explicit names (e.g. after reverse-coding an item)
#' MyData$ScaleMean <- javg(Attitude1:Attitude3, Attitude4R, Attitude5:Attitude6)
#'
#' # Fixed denominator (always divide by total number of variables)
#' MyData$Avg <- javg(Score1, Score2, Score3, min.valid = 1, fixed = TRUE)
#'
#' # With a custom variable label
#' MyData$ScaleMean <- javg(Attitude1:Attitude6,
#'                          var.label = "Scale Mean Score")
#'
#' # With an explicit data frame (instead of using juse default)
#' MyData$Avg <- javg(MyData, Score1, Score2, Score3)
#' }
#'
#' @seealso \code{\link{jsum}} for computing row-wise sums.
#' @seealso \code{\link{JeffsStatTools}} for the package overview,
#'   workflow conventions, and complete function listing.
#'
#' @export
javg <- function(data, ..., min.valid = NULL, fixed = FALSE, var.label = NULL) {

  # Resolve the first argument: explicit data frame, juse default,
  # or bare-symbol-as-variable-name (leading comma omitted).
  arg1 <- .jst_resolve_first_arg(
    data_sub      = substitute(data),
    data_missing  = missing(data),
    fn_name       = "javg",
    envir         = parent.frame(),
    accept_vector = FALSE
  )

  data           <- arg1$data
  .jst_data_name <- arg1$name

  # Resolve variable names (handles colon ranges)
  quos_list <- rlang::enquos(...)

  # Leading-comma-omitted: prepend the captured symbol to quos list
  if (arg1$mode == "symbol_with_default") {
    extra_quo <- rlang::new_quosure(arg1$first_arg_sub,
                                    env = parent.frame())
    quos_list <- c(list(extra_quo), quos_list)
    class(quos_list) <- "quosures"
  }

  resolved    <- .jst_resolve_varrange(quos_list, data, "javg", .jst_data_name)
  var_names   <- resolved$var_names
  label_parts <- resolved$label_parts

  if (length(var_names) < 2) {
    stop("javg() requires at least 2 variables.", call. = FALSE)
  }

  .jst_check_vars(data, var_names, .jst_data_name)

  # Extract columns and convert any haven-labelled to numeric
  items <- data[, var_names, drop = FALSE]
  for (v in var_names) {
    items[[v]] <- .jst_as_numeric(items[[v]])
  }

  n_vars  <- length(var_names)
  n_cases <- nrow(items)

  # Determine minimum valid threshold
  if (is.null(min.valid)) {
    threshold <- n_vars   # Default: all must be non-missing
  } else {
    threshold <- as.integer(min.valid)
    if (is.na(threshold) || threshold < 1) {
      stop("min.valid must be a positive integer.", call. = FALSE)
    }
    if (threshold > n_vars) {
      stop(
        "min.valid (", threshold, ") cannot exceed the number of variables (",
        n_vars, ").",
        call. = FALSE
      )
    }
  }

  # Compute row-wise means
  mat      <- as.matrix(items)
  non_na   <- rowSums(!is.na(mat))
  row_sums <- rowSums(mat, na.rm = TRUE)

  if (fixed) {
    row_means <- row_sums / n_vars
  } else {
    row_means <- ifelse(non_na > 0, row_sums / non_na, NA_real_)
  }

  result <- ifelse(non_na >= threshold, row_means, NA_real_)

  # Count cases set to NA due to missingness
  n_na_result <- sum(is.na(result) & non_na > 0)
  n_all_na    <- sum(non_na == 0)
  n_valid     <- sum(!is.na(result))
  n_partial   <- if (!is.null(min.valid)) sum(!is.na(result) & non_na < n_vars) else 0L

  # Summary message
  denom_note <- if (fixed) " (fixed denominator)" else ""
  msg_parts <- paste0(
    "Mean of ", n_vars, " variables computed for ", n_cases, " cases", denom_note
  )

  detail_parts <- character(0)
  if (!is.null(min.valid)) {
    if (n_partial > 0) {
      detail_parts <- c(detail_parts,
        paste0(n_partial, " case", if (n_partial != 1) "s" else "",
               " used partial data"))
    }
  }
  if (n_na_result > 0) {
    detail_parts <- c(detail_parts,
      paste0(n_na_result, " set to NA due to missing values"))
  }
  if (n_all_na > 0) {
    detail_parts <- c(detail_parts,
      paste0(n_all_na, " set to NA (all values missing)"))
  }

  if (length(detail_parts) > 0) {
    if (!is.null(min.valid)) {
      msg_parts <- paste0(msg_parts, " (min.valid = ", threshold, ": ",
                          paste(detail_parts, collapse = ", "), ").")
    } else {
      msg_parts <- paste0(msg_parts, " (", paste(detail_parts, collapse = ", "), ").")
    }
  } else {
    msg_parts <- paste0(msg_parts, ".")
  }
  message(msg_parts)

  # Attach variable label
  if (!is.null(var.label)) {
    labelled::var_label(result) <- var.label
  } else {
    auto_label <- paste0("Mean of ", paste(label_parts, collapse = ", "))
    labelled::var_label(result) <- auto_label
  }

  return(invisible(result))
}


# =============================================================================
#  DATA MANAGEMENT — RECODING & LABELING
# =============================================================================

# -- jrelabel ----------------------------------------------------------------

#' Apply variable and value labels to a variable
#'
#' @description
#' \code{jrelabel()} attaches a variable label and/or value labels to any
#' variable in a data frame. It is designed as a simple label applicator ---
#' it does not recode values or compare variables. Use it to add labels after
#' a recode, to fix missing labels, or to label any variable that needs them.
#'
#' The function accepts haven-labelled, plain numeric, factor, and character
#' variables. The output is always a \code{haven_labelled} vector, which is
#' compatible with all JeffsStatTools functions.
#'
#' Both the \code{labels} and \code{var.label} arguments are optional. If
#' neither is supplied, the function returns the variable unchanged as a
#' \code{haven_labelled} vector.
#'
#' If the variable already has labels, they are silently overwritten when
#' new labels are provided.
#'
#' @param data A data frame containing the variable.
#' @param var The variable to label (unquoted, e.g. \code{StatusR}).
#' @param labels Optional. A quoted string specifying value labels using the
#'   format \code{"code=Label Text"} with rules separated by semicolons.
#'
#'   Examples:
#'   \itemize{
#'     \item \code{"1=Yes; 0=No"}
#'     \item \code{"1=Employed; 2=Unemployed; 3=Student; 4=Retired"}
#'   }
#'
#' @param var.label Optional. A quoted string to use as the variable label
#'   (the description shown by \code{jdesc()}, \code{jfreq()}, etc.).
#'   If omitted, any existing variable label is preserved. If the variable
#'   has no existing label, no variable label is set.
#'
#' @return A \code{haven_labelled} vector with the requested labels applied.
#'   Assign this back to a column in your data frame:
#'   \code{MyData$VarName <- jrelabel(MyData, VarName, ...)}
#'
#' @examples
#' # Add value labels after a recode
#' df <- data.frame(Status = c(1, 2, 1, 2, 1, 2))
#' df$StatusR <- ifelse(df$Status == 1, 1, 0)
#' df$StatusR <- jrelabel(df, StatusR, labels = "1=Yes; 0=No",
#'                        var.label = "Status (recoded)")
#'
#' # Add just a variable label
#' df$StatusR <- jrelabel(df, StatusR, var.label = "Employment Status")
#'
#' # Add just value labels
#' df$StatusR <- jrelabel(df, StatusR, labels = "1=Yes; 0=No")
#'
#' # Using juse() default
#' juse(df)
#' df$StatusR <- jrelabel(StatusR, labels = "1=Active; 0=Inactive")
#'
#' @seealso \code{\link{jrecode}} for recoding values with optional labels
#'   in a single step.
#' @seealso \code{\link{JeffsStatTools}} for the package overview,
#'   workflow conventions, and complete function listing.
#'
#' @export
jrelabel <- function(data, var, labels = NULL, var.label = NULL) {

  # --- Resolve first argument -----------------------------------------------
  arg1 <- .jst_resolve_first_arg(
    data_sub      = substitute(data),
    data_missing  = missing(data),
    fn_name       = "jrelabel",
    envir         = parent.frame(),
    accept_vector = FALSE
  )

  data <- arg1$data

  # Determine variable name. If the user typed jrelabel(VarName, labels = ...)
  # — data omitted, named labels — the helper captured VarName as first_arg_sub.
  # Otherwise var is supplied positionally.
  if (arg1$mode == "symbol_with_default") {
    if (!missing(var)) {
      displaced <- deparse(substitute(var))
      stop("jrelabel(): when the data argument is omitted, all subsequent arguments must be named. ",
           "Use jrelabel(", deparse(arg1$first_arg_sub), ", labels = ", displaced, ")",
           call. = FALSE)
    }
    var_name <- deparse(arg1$first_arg_sub)
  } else {
    var_name <- deparse(substitute(var))
  }

  # --- Input checks ---
  if (!is.data.frame(data)) {
    stop("The first argument must be a data frame.", call. = FALSE)
  }
  if (!var_name %in% names(data)) {
    frame_ref <- if (!is.null(arg1$name) && nzchar(arg1$name)) arg1$name else "the data frame"
    stop(paste0("Variable '", var_name, "' not found in ", frame_ref, "."), call. = FALSE)
  }

  x <- data[[var_name]]

  # --- Preserve any existing variable label before conversion ---
  existing_var_label <- NULL
  if (haven::is.labelled(x)) {
    existing_var_label <- labelled::var_label(x)
  }

  # --- Convert to numeric vector for haven_labelled construction ---
  if (haven::is.labelled(x)) {
    num_vals <- .jst_as_numeric(x)
  } else if (is.factor(x)) {
    num_vals <- suppressWarnings(as.numeric(as.character(x)))
    if (all(is.na(num_vals[!is.na(x)]))) {
      stop(paste0(
        "'", var_name, "' is a factor with non-numeric levels. ",
        "Convert it to numeric values before using jrelabel()."
      ), call. = FALSE)
    }
  } else if (is.character(x)) {
    num_vals <- suppressWarnings(as.numeric(x))
    if (all(is.na(num_vals[!is.na(x)]))) {
      stop(paste0(
        "'", var_name, "' contains non-numeric text values. ",
        "Convert it to numeric values before using jrelabel()."
      ), call. = FALSE)
    }
  } else {
    num_vals <- as.numeric(x)
  }

  # --- Build haven_labelled vector ---
  result <- labelled::labelled(num_vals)

  # --- Apply variable label ---
  if (!is.null(var.label)) {
    if (!is.character(var.label) || length(var.label) != 1) {
      stop("The var.label argument must be a single quoted string.", call. = FALSE)
    }
    labelled::var_label(result) <- var.label
  } else if (!is.null(existing_var_label) &&
             nchar(trimws(existing_var_label)) > 0) {
    labelled::var_label(result) <- existing_var_label
  }

  # --- Apply value labels ---
  if (!is.null(labels)) {
    if (!is.character(labels) || length(labels) != 1) {
      stop("The labels argument must be a single quoted string, e.g. \"1=Yes; 0=No\".", call. = FALSE)
    }
    parsed_labels <- tryCatch(
      .jst_parse_labels(labels),
      error = function(e) stop(paste0("Error in labels argument: ",
                                      conditionMessage(e)), call. = FALSE)
    )
    labelled::val_labels(result) <- parsed_labels
  }

  return(invisible(result))
}


# -----------------------------------------------------------------------------
# .jst_jrecode_convention_error()
#
# Builds the error message emitted by jrecode() when the user's map or
# labels argument contains Stata-style missing-value tokens but the
# resolved convention is SPSS. Constructs a dynamic echo-back of the
# user's actual map and labels with tagged-NA tokens replaced by
# equivalent numeric UDM codes drawn from
# joptions("udm.convention.codes"), plus the canonical two-call
# SPSS-style pattern (jrecode then jdeclare_udm) per Decision 10's
# worked example.
#
# joutput-level gating:
#   minimal  - three lines: what went wrong, see ?jrecode, the
#              joptions switch hint. No dynamic echo-back.
#   standard - full block with the rewritten jrecode and jdeclare_udm
#   full       lines, plus the joptions switch line at the end.
#
# Cap behavior: when tagged-NA token count exceeds the convention
# code count, the helper substitutes the mappable subset and leaves
# unmapped tokens in their original .x form. A plain-language cap
# note explaining the situation is appended between the example
# block and the switch-convention line.
# -----------------------------------------------------------------------------

#' Internal helper: build jrecode's cross-convention error message
#'
#' Produces the error message used by \code{jrecode()} when Stata-style
#' Stata-style missing-value tokens appear in the map or labels argument but the
#' resolved convention is SPSS. Verbosity is controlled by the active
#' \code{joutput()} level.
#'
#' @param parsed_map List returned by \code{.jst_parse_map()}.
#' @param parsed_labels Named numeric vector returned by
#'   \code{.jst_parse_labels()}, or \code{NULL} if no labels argument
#'   was supplied.
#' @param data_name Character. Name of the data frame in the user's
#'   call (used to reconstruct the example).
#' @param orig_name Character. Name of the variable being recoded.
#'
#' @return Character scalar suitable for passing to \code{stop()}.
#'
#' @keywords internal
.jst_jrecode_convention_error <- function(parsed_map, parsed_labels,
                                          data_name, orig_name) {

  # --- Gather every tagged-NA letter that appeared --------------------------
  map_tags <- unlist(lapply(parsed_map$mappings, function(r) r$tagged))
  if (isTRUE(parsed_map$else_action == "tagged")) {
    map_tags <- c(map_tags, parsed_map$else_tag)
  }

  label_tags_lookup <- character(0)  # letter -> label, for jdeclare_udm
  if (!is.null(parsed_labels)) {
    tags_in_labels <- haven::na_tag(parsed_labels)
    for (i in seq_along(parsed_labels)) {
      if (!is.na(tags_in_labels[i])) {
        letter <- tags_in_labels[i]
        label_tags_lookup[letter] <- names(parsed_labels)[i]
      }
    }
  }
  label_tags <- names(label_tags_lookup)

  all_tags <- sort(unique(c(map_tags, label_tags)))
  first_tag <- all_tags[1]

  # --- Verbosity gate -------------------------------------------------------
  output_level <- getOption(".jst_output_level", "standard")

  if (identical(output_level, "minimal")) {
    return(paste0(
      "the map uses '.", first_tag, "', a Stata-style missing-value ",
      "marker. The package is currently set to SPSS convention.\n",
      "See ?jrecode for examples, or run\n",
      "joptions(missing.convention = \"stata\") to switch."
    ))
  }

  # --- Standard / full block ------------------------------------------------

  letter_to_code <- .jst_tag_letters_to_codes(all_tags)
  unmapped       <- attr(letter_to_code, "unmapped")
  if (is.null(unmapped)) unmapped <- character(0)

  # Reconstruct the user's map with tagged-NA tokens replaced by their
  # equivalent SPSS-form numeric codes. Tokens that couldn't be mapped
  # (cap exceeded) are left in their original .x form.
  format_num <- function(x) {
    if (is.na(x)) return("NA")
    # Render integers without a trailing ".0".
    if (x == floor(x)) format(as.integer(x)) else format(x)
  }

  rebuilt_map_parts <- character(0)
  for (rule in parsed_map$mappings) {
    lhs <- paste(vapply(rule$old_vals, format_num, character(1)),
                 collapse = ",")
    if (!is.null(rule$tagged)) {
      code <- letter_to_code[rule$tagged]
      rhs  <- if (is.na(code)) paste0(".", rule$tagged) else format_num(code)
    } else if (is.na(rule$new_val)) {
      rhs <- "NA"
    } else {
      rhs <- format_num(rule$new_val)
    }
    rebuilt_map_parts <- c(rebuilt_map_parts, paste0(lhs, "=", rhs))
  }
  if (isTRUE(parsed_map$else_explicit)) {
    if (identical(parsed_map$else_action, "tagged")) {
      code <- letter_to_code[parsed_map$else_tag]
      else_rhs <- if (is.na(code)) {
        paste0(".", parsed_map$else_tag)
      } else format_num(code)
    } else if (identical(parsed_map$else_action, "copy")) {
      else_rhs <- "copy"
    } else {
      else_rhs <- "NA"
    }
    rebuilt_map_parts <- c(rebuilt_map_parts, paste0("else=", else_rhs))
  }
  rebuilt_map <- paste(rebuilt_map_parts, collapse = "; ")

  # Rebuild the labels argument without tagged-NA entries; those move
  # to the jdeclare_udm call per Decision 10's worked example.
  rebuilt_labels <- NULL
  if (!is.null(parsed_labels)) {
    tags_in_labels <- haven::na_tag(parsed_labels)
    non_tag_idx <- which(is.na(tags_in_labels))
    if (length(non_tag_idx) > 0L) {
      label_parts <- character(0)
      for (i in non_tag_idx) {
        label_parts <- c(label_parts,
          paste0(format_num(parsed_labels[i]), "=", names(parsed_labels)[i]))
      }
      rebuilt_labels <- paste(label_parts, collapse = "; ")
    }
  }

  # Compose the rewritten jrecode call.
  jrecode_line <- paste0("    jrecode(", data_name, ", ", orig_name,
                         ", map = \"", rebuilt_map, "\"")
  if (!is.null(rebuilt_labels)) {
    indent <- paste(rep(" ", nchar("    jrecode(")), collapse = "")
    jrecode_line <- paste0(jrecode_line, ",\n", indent,
                           "labels = \"", rebuilt_labels, "\"")
  }
  jrecode_line <- paste0(jrecode_line, ")")

  # Compose the jdeclare_udm follow-up call, covering only the mapped
  # (non-unmapped) tags so the example is syntactically valid.
  mapped_tags <- setdiff(all_tags, unmapped)
  jdeclare_line <- NULL
  if (length(mapped_tags) > 0L) {
    codes_parts <- character(0)
    for (letter in mapped_tags) {
      code  <- letter_to_code[letter]
      label <- if (letter %in% names(label_tags_lookup)) {
        label_tags_lookup[[letter]]
      } else "Missing"
      codes_parts <- c(codes_parts,
                       paste0(label, " = ", format_num(code)))
    }
    jdeclare_line <- paste0("    jdeclare_udm(", data_name, ", ",
                            orig_name, ", codes = c(",
                            paste(codes_parts, collapse = ", "), "))")
  }

  # Assemble the message.
  msg_parts <- c(
    paste0("the map uses '.", first_tag, "', a Stata-style missing-",
           "value marker. The package is currently set to SPSS"),
    "convention, which uses numeric codes. Here is the equivalent",
    "recode in SPSS style:",
    "",
    jrecode_line
  )
  if (!is.null(jdeclare_line)) {
    msg_parts <- c(msg_parts, jdeclare_line)
  }
  msg_parts <- c(msg_parts, "",
    paste0("The numeric code",
           if (length(mapped_tags) > 1L) "s" else "",
           " above came from joptions(\"udm.convention.codes\")."))

  # Cap note: appended when one or more tags exceeded the convention
  # code count. Plain-language explanation; no jargon.
  if (length(unmapped) > 0L) {
    n_tags  <- length(all_tags)
    n_codes <- length(letter_to_code)
    unmapped_render <- paste0("'.", unmapped, "'", collapse = ", ")
    were_was <- if (length(unmapped) == 1L) "was" else "were"
    msg_parts <- c(msg_parts, "",
      paste0("Note: your map uses ", n_tags, " Stata-style markers (",
             paste0(".", all_tags, collapse = ", "), ") but"),
      paste0("joptions(\"udm.convention.codes\") currently holds only ",
             n_codes, " values; ", unmapped_render, " ", were_was),
      "not substituted in the example above. To add another code, run",
      "something like joptions(udm.convention.codes = c(-99, -98, -97))."
    )
  }

  msg_parts <- c(msg_parts, "",
    "To switch to Stata convention instead, run:",
    "joptions(missing.convention = \"stata\").")

  paste(msg_parts, collapse = "\n")
}


# -----------------------------------------------------------------------------
# .jst_jdeclare_udm_convention_error()
#
# Builds the cross-convention error message for jdeclare_udm. Fires
# when the user passes Stata-style missing-value tokens in the codes vector
# but the resolved convention is SPSS. Mirrors the structure of
# .jst_jrecode_convention_error() (Session 31) with two simplifications:
# the rewrite is a single jdeclare_udm call (not two calls), and there
# is no separate labels argument to rebuild (labels live as names on
# the codes vector when present).
#
# joutput-level gating:
#   minimal  - three lines: what went wrong, see ?jdeclare_udm, the
#              joptions switch hint.
#   standard - full block with the rewritten jdeclare_udm call and
#   full       the joptions switch line.
#
# Cap behavior: when tagged-NA token count exceeds the convention
# code count, the helper substitutes the mappable subset and leaves
# unmapped tokens out of the example call. A plain-language cap note
# is appended.
# -----------------------------------------------------------------------------

#' Internal helper: build jdeclare_udm's cross-convention error message
#'
#' Produces the error message used by \code{jdeclare_udm()} when
#' Stata-style missing-value tokens appear in the \code{codes} argument but
#' the resolved convention is SPSS. Verbosity is controlled by the
#' active \code{joutput()} level.
#'
#' @param parsed_codes Named numeric vector. Names are labels (\code{""}
#'   where no label was given). Values are the user's codes including
#'   any tagged-NA elements.
#' @param data_name Character. Name of the data frame in the user's
#'   call (used to reconstruct the example).
#' @param var_name Character. Name of the variable being declared.
#'
#' @return Character scalar suitable for passing to \code{stop()}.
#'
#' @keywords internal
.jst_jdeclare_udm_convention_error <- function(parsed_codes,
                                               data_name, var_name) {

  # --- Identify tagged-NA elements ------------------------------------------
  tags_in_codes <- haven::na_tag(parsed_codes)
  tag_idx       <- which(!is.na(tags_in_codes))
  all_tags      <- sort(unique(tags_in_codes[tag_idx]))
  first_tag     <- all_tags[1]

  # --- Verbosity gate -------------------------------------------------------
  output_level <- getOption(".jst_output_level", "standard")

  if (identical(output_level, "minimal")) {
    return(paste0(
      "codes for ", var_name, " contains '.", first_tag,
      "', a Stata-style missing-value marker. ",
      "The package is currently set to SPSS convention.\n",
      "See ?jdeclare_udm for examples, or run\n",
      "joptions(missing.convention = \"stata\") to switch."
    ))
  }

  # --- Standard / full block ------------------------------------------------

  letter_to_code <- .jst_tag_letters_to_codes(all_tags)
  unmapped       <- attr(letter_to_code, "unmapped")
  if (is.null(unmapped)) unmapped <- character(0)
  mapped_tags    <- setdiff(all_tags, unmapped)

  # Rebuild the codes vector with tagged-NA elements substituted by
  # their SPSS-form numeric equivalents. Unmapped tags drop out of the
  # rebuilt call (no numeric equivalent available); the cap note below
  # explains.
  format_num <- function(x) {
    if (is.na(x)) return("NA")
    if (x == floor(x)) format(as.integer(x)) else format(x)
  }

  rebuilt_parts <- character(0)
  for (i in seq_along(parsed_codes)) {
    val <- parsed_codes[i]
    lbl <- names(parsed_codes)[i]
    if (i %in% tag_idx) {
      this_tag <- tags_in_codes[i]
      if (this_tag %in% unmapped) next   # drop unmapped tagged elements
      code <- letter_to_code[this_tag]
      val_render <- format_num(code)
    } else {
      val_render <- format_num(as.numeric(val))
    }
    if (is.null(lbl) || !nzchar(lbl)) {
      rebuilt_parts <- c(rebuilt_parts, val_render)
    } else {
      # Quote labels that need it; backtick labels containing spaces or
      # other syntax-sensitive characters to keep the rebuilt call
      # syntactically valid R.
      lbl_render <- if (grepl("^[A-Za-z.][A-Za-z0-9._]*$", lbl)) {
        lbl
      } else {
        paste0("`", lbl, "`")
      }
      rebuilt_parts <- c(rebuilt_parts,
                         paste0(lbl_render, " = ", val_render))
    }
  }

  # Compose the rewritten jdeclare_udm call.
  if (length(rebuilt_parts) > 1L) {
    codes_arg <- paste0("c(", paste(rebuilt_parts, collapse = ", "), ")")
  } else if (length(rebuilt_parts) == 1L) {
    # If the single remaining element has a name, keep the c() wrapper
    # so the name survives. Otherwise a bare scalar is fine.
    if (grepl(" = ", rebuilt_parts)) {
      codes_arg <- paste0("c(", rebuilt_parts, ")")
    } else {
      codes_arg <- rebuilt_parts
    }
  } else {
    codes_arg <- "c()"
  }

  jdeclare_line <- paste0("    jdeclare_udm(", data_name, ", ", var_name,
                          ", codes = ", codes_arg, ")")

  # Assemble the message.
  msg_parts <- c(
    paste0("codes for ", var_name, " contains '.", first_tag,
           "', a Stata-style missing-value marker. ",
           "The package is currently set to SPSS"),
    "convention, which uses numeric codes. Here is the equivalent",
    "declaration in SPSS style:",
    "",
    jdeclare_line,
    "",
    paste0("The numeric code",
           if (length(mapped_tags) > 1L) "s" else "",
           " above came from joptions(\"udm.convention.codes\").")
  )

  # Cap note: appended when one or more tags exceeded the convention
  # code count.
  if (length(unmapped) > 0L) {
    n_tags  <- length(all_tags)
    n_codes <- length(letter_to_code)
    unmapped_render <- paste0("'.", unmapped, "'", collapse = ", ")
    were_was <- if (length(unmapped) == 1L) "was" else "were"
    msg_parts <- c(msg_parts, "",
      paste0("Note: codes uses ", n_tags, " Stata-style markers (",
             paste0(".", all_tags, collapse = ", "), ") but"),
      paste0("joptions(\"udm.convention.codes\") currently holds only ",
             n_codes, " values; ", unmapped_render, " ", were_was),
      "not substituted in the example above. To add another code, run",
      "something like joptions(udm.convention.codes = c(-99, -98, -97))."
    )
  }

  msg_parts <- c(msg_parts, "",
    "To switch to Stata convention instead, run:",
    "joptions(missing.convention = \"stata\").")

  paste(msg_parts, collapse = "\n")
}


# -----------------------------------------------------------------------------
# .jst_jdeclare_udm_mixed_error()
#
# Builds the Sign-off 4 error for when the user mixes tagged-NA elements
# and plain numeric codes in a single codes vector under Stata
# convention. Standard / full tier includes a worked split-call example.
# -----------------------------------------------------------------------------

#' @keywords internal
.jst_jdeclare_udm_mixed_error <- function(parsed_codes, data_name, var_name) {

  tags_in_codes <- haven::na_tag(parsed_codes)
  tag_idx       <- which(!is.na(tags_in_codes))
  num_idx       <- setdiff(seq_along(parsed_codes), tag_idx)

  output_level <- getOption(".jst_output_level", "standard")

  if (identical(output_level, "minimal")) {
    return(paste0(
      "codes for ", var_name, " mixes Stata-style missing values and ",
      "SPSS-style numeric codes. Issue these as separate jdeclare_udm() calls."
    ))
  }

  # Build the two split-call examples.
  format_num <- function(x) {
    if (is.na(x)) return("NA")
    if (x == floor(x)) format(as.integer(x)) else format(x)
  }

  fmt_label <- function(lbl) {
    if (is.null(lbl) || !nzchar(lbl)) return(NA_character_)
    if (grepl("^[A-Za-z.][A-Za-z0-9._]*$", lbl)) lbl
    else paste0("`", lbl, "`")
  }

  # Tagged-only call
  tag_parts <- character(0)
  for (i in tag_idx) {
    lbl <- fmt_label(names(parsed_codes)[i])
    rhs <- paste0("tagged_na(\"", tags_in_codes[i], "\")")
    if (is.na(lbl)) tag_parts <- c(tag_parts, rhs)
    else            tag_parts <- c(tag_parts, paste0(lbl, " = ", rhs))
  }
  tag_arg <- if (length(tag_parts) > 1L || grepl(" = ", tag_parts[1])) {
    paste0("c(", paste(tag_parts, collapse = ", "), ")")
  } else tag_parts[1]
  tag_line <- paste0("    ", data_name, " <- jdeclare_udm(",
                     data_name, ", ", var_name, ", codes = ", tag_arg, ")")

  # Numeric-only call
  num_parts <- character(0)
  for (i in num_idx) {
    lbl <- fmt_label(names(parsed_codes)[i])
    rhs <- format_num(as.numeric(parsed_codes[i]))
    if (is.na(lbl)) num_parts <- c(num_parts, rhs)
    else            num_parts <- c(num_parts, paste0(lbl, " = ", rhs))
  }
  num_arg <- if (length(num_parts) > 1L || grepl(" = ", num_parts[1])) {
    paste0("c(", paste(num_parts, collapse = ", "), ")")
  } else num_parts[1]
  num_line <- paste0("    ", data_name, " <- jdeclare_udm(",
                     data_name, ", ", var_name, ", codes = ", num_arg, ")")

  msg_parts <- c(
    paste0("codes for ", var_name, " mixes Stata-style missing values ",
           "and SPSS-style numeric codes."),
    "The two operations are different -- labeling existing Stata-style",
    "missing-value cells (tagged input) and converting numeric cells to",
    "Stata-style missing values (numeric input) -- and must be issued as",
    "separate calls.",
    "For your input, that would be:",
    "",
    tag_line,
    num_line
  )

  paste(msg_parts, collapse = "\n")
}


# -----------------------------------------------------------------------------
# .jst_jdeclare_udm_drop_notice()
#
# Builds the Sign-off 5 drop-notice message emitted after a successful
# declaration when the prior UDM set contained codes not in the new set.
# Minimal tier: variable name and dropped codes only. Standard/full
# tier: labels for the dropped codes and the ?jdeclare_udm pointer.
# -----------------------------------------------------------------------------

#' @keywords internal
.jst_jdeclare_udm_drop_notice <- function(dropped_df, var_name,
                                          representation) {
  # dropped_df: subset of an .jst_missing_info()$codes data.frame containing
  # only the dropped rows. Has columns code, label, source, numeric, tag.

  output_level <- getOption(".jst_output_level", "standard")

  if (identical(output_level, "minimal")) {
    dropped_render <- paste(dropped_df$code, collapse = ", ")
    return(paste0("Note: jdeclare_udm replaced existing UDMs on ",
                  var_name, ". Dropped: ", dropped_render, "."))
  }

  # Standard / full tier: include labels where available.
  parts <- character(0)
  for (i in seq_len(nrow(dropped_df))) {
    code <- dropped_df$code[i]
    lbl  <- dropped_df$label[i]
    if (!is.na(lbl) && nzchar(lbl)) {
      parts <- c(parts, sprintf("%s [\"%s\"]", code, lbl))
    } else {
      parts <- c(parts, code)
    }
  }
  paste0("Note: jdeclare_udm replaced the existing UDM set for ", var_name,
         ". Previously declared codes dropped: ", paste(parts, collapse = ", "),
         ". Use `?jdeclare_udm` to review the replace-semantics behavior.")
}


# -- jrecode -----------------------------------------------------------------

#' Recode a variable with explicit value mapping and optional labels
#'
#' @description
#' \code{jrecode()} recodes a variable using a simple map string that specifies
#' how old values should be converted to new values. It is designed for
#' situations where you need to collapse categories, change numeric codes,
#' or recode dichotomies. Variable and value labels are handled automatically.
#'
#' Map and labels rules can also produce missing values: plain system NA
#' via the \code{NA} / \code{System} / \code{SYSMIS} aliases, or
#' Stata-style tagged missing values (\code{.a} through \code{.z}) when
#' the active convention is Stata. See \emph{Missing values in the map}
#' below for the canonical patterns under each convention.
#'
#' @param data     A data frame containing the original variable.
#' @param orig.var The variable to recode (unquoted, e.g. \code{AgeGroup}).
#' @param map      A quoted string specifying the recode rules, using the
#'   format \code{"old=new"} with rules separated by semicolons. Multiple old
#'   values mapping to the same new value are separated by commas on the left
#'   side.
#'
#'   An optional \code{else} clause controls what happens to values not
#'   covered by the map:
#'   \itemize{
#'     \item No else clause: the function stops with a message if any
#'       values are left unmapped, so you can fix the map before proceeding.
#'     \item \code{else=NA} (also \code{else=System} or \code{else=SYSMIS}):
#'       unmapped values are deliberately set to system NA.
#'     \item \code{else=copy}: unmapped values are carried across unchanged.
#'     \item \code{else=.a} (or any Stata-style missing-value token, Stata
#'       convention only): unmapped values are set to that Stata-style missing value.
#'   }
#'
#'   Individual values can also be mapped to system NA using the same
#'   aliases: \code{"-5=NA"}, \code{"-5=System"}, or \code{"-5=SYSMIS"}.
#'
#'   Under Stata convention, values can be mapped to Stata-style missing-value tokens:
#'   \code{"-99=.a; -98=.b"}.
#'
#'   Examples:
#'   \itemize{
#'     \item \code{"1=1; 2=0"}
#'     \item \code{"1=1; 2,3=2; 4,5=3; else=NA"}
#'     \item \code{"1=1; 2=0; else=copy"}
#'     \item \code{"-5=System; else=copy"}
#'     \item \code{"3=1; 4=2; else=.a"} (Stata convention only)
#'   }
#'
#' @param labels   Optional. A quoted string specifying value labels for the
#'   new variable, using the format \code{"code=Label Text"} with rules
#'   separated by semicolons. If supplied, these labels are used as-is.
#'
#'   The left side of each rule may be a numeric code or, under Stata
#'   convention, a Stata-style missing-value token (\code{.a} through
#'   \code{.z}). Tagged-NA labels are stored on the tag itself, not on
#'   a numeric code.
#'
#'   If omitted, the function attempts to transfer value labels automatically
#'   from the original variable. This works when the original variable has
#'   value labels and the mapping is one-to-one (no categories are collapsed).
#'   When categories are collapsed, labels cannot be transferred automatically
#'   and a note is printed.
#'
#'   Example: \code{"1=Male; 0=Female"} or \code{".a=Refused; .b=Don't know"}.
#'
#' @param convention Optional. One of \code{"spss"}, \code{"stata"}, or
#'   \code{NULL} (default). Controls whether Stata-style missing-value tokens
#'   (\code{.a} through \code{.z}) are accepted in the map and labels
#'   arguments. Inert when no Stata-style missing-value tokens appear in either argument.
#'
#'   When \code{NULL}, the convention is resolved from
#'   \code{joptions("missing.convention")}; if that is also unset, the
#'   default is SPSS. Most users set the convention once at the top of a
#'   session via \code{joptions()} (or in their \code{.Rprofile}) rather
#'   than supplying this argument on every call. See \code{?joptions} for
#'   details.
#'
#' @return A \code{haven_labelled} vector with the recoded values, variable
#'   label, and (if supplied or auto-transferred) value labels applied. Assign
#'   this to a new column in your data frame:
#'   \code{MyData$AgeGroupR <- jrecode(MyData, AgeGroup, map = "...")}
#'
#' @details
#' The function accepts haven-labelled, plain numeric, and factor variables.
#'
#' The variable label from the original variable is carried across automatically
#' with "(recoded)" appended. If the original variable has no variable label,
#' the variable name is used instead.
#'
#' Value labels are handled in three ways, in order of priority:
#' \enumerate{
#'   \item If \code{labels} is supplied, those labels are used as-is.
#'   \item If \code{labels} is omitted and the original variable has value
#'     labels, they are automatically transferred to the new codes --- provided
#'     the mapping is one-to-one (no collapsing). For example, recoding 1/2 to
#'     1/0 will carry "Yes" and "No" across to the new codes automatically.
#'   \item If categories are collapsed (multiple old values map to one new
#'     value), automatic transfer is not possible and a note is printed
#'     directing you to supply labels manually.
#' }
#'
#' NA values in the original variable are always set to NA in the new variable,
#' regardless of the \code{else} setting.
#'
#' Values that appear to be coded missing values (e.g. -99, -9, 999) from SPSS
#' or another package are automatically detected and set to NA, even when
#' \code{else=copy} is used. A note is printed when this occurs.
#'
#' If the map does not include an \code{else} clause and there are unmapped
#' values in the variable, the function stops with a message listing the
#' unmapped values so you can fix the map before proceeding.
#'
#' If the map specifies values that do not exist in the original variable, a
#' warning is issued (but the function continues). This helps catch typos in
#' the map string.
#'
#' \strong{Missing values in the map.} The package supports two conventions
#' for representing user-defined missing values (UDMs), and the syntax for
#' producing UDMs from \code{jrecode()} depends on which one is active:
#'
#' Under \strong{SPSS convention} (the default), UDMs are real numeric
#' codes carrying metadata that flags them as missing. The two-step
#' canonical pattern is:
#'
#' \preformatted{
#' df$gearR <- jrecode(df, gear,
#'                     map    = "3=1; 4=2; else=-99",
#'                     labels = "1=Three gears; 2=Four gears")
#' df <- jdeclare_udm(df, gearR, codes = c(Refused = -99))
#' }
#'
#' The \code{jrecode()} call assigns the numeric sentinel \code{-99}; the
#' subsequent \code{jdeclare_udm()} call attaches the label and flags
#' \code{-99} as missing. Labeling \code{-99} inside the \code{labels}
#' argument is unnecessary --- \code{jdeclare_udm()} owns that label.
#'
#' Under \strong{Stata convention}, UDMs are typed missing cells marked
#' with Stata-style tags (\code{.a} through \code{.z}). The single-call
#' canonical pattern is:
#'
#' \preformatted{
#' df$gearR <- jrecode(df, gear,
#'                     map    = "3=1; 4=2; else=.a",
#'                     labels = "1=Three gears; 2=Four gears; .a=Refused")
#' }
#'
#' Under Stata convention, \code{jdeclare_udm()} is not needed for this
#' pattern --- \code{jrecode()} handles both the value recoding and the
#' Stata-style missing-value labeling in one call.
#'
#' Writing Stata-style missing-value tokens while the active convention is SPSS raises an
#' informative error that echoes the user's call rewritten in SPSS-style
#' syntax. Switching the convention session-wide is one line:
#' \code{joptions(missing.convention = "stata")}.
#'
#' @examples
#' # Recode with explicit labels
#' df <- data.frame(gear = mtcars$gear)
#' df$gearR <- jrecode(df, gear,
#'                     map    = "3=1; 4=2; 5=3",
#'                     labels = "1=Three; 2=Four; 3=Five")
#'
#' # Collapse categories (must supply labels)
#' df$gearR2 <- jrecode(df, gear,
#'                      map    = "3=1; 4,5=2",
#'                      labels = "1=Three gears; 2=Four or five gears")
#'
#' # Use else=copy to carry unspecified values across unchanged
#' df$gearR3 <- jrecode(df, gear,
#'                      map    = "3=1; else=copy",
#'                      labels = "1=Three gears")
#'
#' # Use else=NA to deliberately drop unspecified values to system NA
#' df$gearR4 <- jrecode(df, gear,
#'                      map    = "3=1; 4=2; else=NA",
#'                      labels = "1=Three gears; 2=Four gears")
#'
#' # Convert a specific coded missing value to system NA
#' df$gearR5 <- jrecode(df, gear, map = "99=System; else=copy")
#'
#' # Stata convention: Stata-style missing-value tokens in map and labels (single call)
#' \dontrun{
#' joptions(missing.convention = "stata")
#' df$gearR6 <- jrecode(df, gear,
#'                      map    = "3=1; 4=2; else=.a",
#'                      labels = "1=Three gears; 2=Four gears; .a=Refused")
#' }
#'
#' # Using juse() default
#' juse(df)
#' df$gearR7 <- jrecode(gear, map = "3=1; 4=2; 5=3",
#'                       labels = "1=Three; 2=Four; 3=Five")
#'
#' @seealso \code{\link{jdeclare_udm}} for declaring user-defined missing
#'   values on a column after a recode (the SPSS-style canonical pattern).
#' @seealso \code{\link{jrelabel}} for applying labels to an existing variable
#'   after a recode.
#' @seealso \code{\link{joptions}} for the session-level
#'   \code{missing.convention} setting.
#' @seealso \code{\link{JeffsStatTools}} for the package overview,
#'   workflow conventions, and complete function listing.
#'
#' @export
jrecode <- function(data, orig.var, map, labels = NULL, convention = NULL) {

  # --- Resolve first argument -----------------------------------------------
  arg1 <- .jst_resolve_first_arg(
    data_sub      = substitute(data),
    data_missing  = missing(data),
    fn_name       = "jrecode",
    envir         = parent.frame(),
    accept_vector = FALSE
  )

  data           <- arg1$data
  .jst_data_name <- arg1$name

  # Determine variable name. If the user typed jrecode(VarName, map = "...")
  # — data omitted, named map — the helper captured VarName as first_arg_sub.
  # Otherwise orig.var is supplied positionally.
  if (arg1$mode == "symbol_with_default") {
    if (!missing(orig.var)) {
      displaced <- deparse(substitute(orig.var))
      stop("jrecode(): when the data argument is omitted, all subsequent arguments must be named. ",
           "Use jrecode(", deparse(arg1$first_arg_sub), ", map = ", displaced, ")",
           call. = FALSE)
    }
    orig_name <- deparse(arg1$first_arg_sub)
  } else {
    orig_name <- deparse(substitute(orig.var))
  }

  # --- Input checks ---
  if (!is.data.frame(data)) {
    stop("The first argument must be a data frame.", call. = FALSE)
  }
  if (!orig_name %in% names(data)) {
    stop(paste0("Variable '", orig_name, "' not found in '", .jst_data_name, "'."), call. = FALSE)
  }
  if (missing(map) || !is.character(map) || length(map) != 1) {
    stop("The map argument must be a single quoted string, e.g. map = \"1=1; 2=0\".", call. = FALSE)
  }

  # Validate convention argument up front so an invalid value errors
  # whether or not the recode actually uses tagged-NA tokens. The
  # resolved convention is consulted only when tokens are present.
  if (!is.null(convention)) {
    if (!is.character(convention) || length(convention) != 1L ||
        !convention %in% c("spss", "stata")) {
      stop("The convention argument must be \"spss\" or \"stata\".",
           call. = FALSE)
    }
  }

  orig <- data[[orig_name]]

  # --- Detect suspicious coded missing values ---
  suspicious_vals <- .jst_detect_suspicious_values(orig, orig_name)

  # --- Parse map string ---
  parsed_map <- tryCatch(
    .jst_parse_map(map),
    error = function(e) stop(paste0("Error in map argument: ", conditionMessage(e)), call. = FALSE)
  )

  # --- Parse labels string (if supplied) ---
  # Parsed up front so the convention check below can scan both map
  # and labels for tagged-NA tokens in a single pass. The parsed
  # structure is consumed later in the value-label application step.
  parsed_labels <- NULL
  if (!is.null(labels)) {
    if (!is.character(labels) || length(labels) != 1) {
      stop("The labels argument must be a single quoted string, e.g. labels = \"1=Male; 0=Female\".", call. = FALSE)
    }
    parsed_labels <- tryCatch(
      .jst_parse_labels(labels),
      error = function(e) stop(paste0("Error in labels argument: ",
                                      conditionMessage(e)), call. = FALSE)
    )
  }

  # --- Cross-convention validation ---
  # Gather tagged-NA tokens from map and labels. If any are present,
  # resolve the active convention; under SPSS convention, raise the
  # cross-convention error with a dynamic echo-back of the user's
  # call rewritten in SPSS-style syntax. Under Stata convention the
  # tokens are accepted and flow through to the recode loop.
  map_has_tag <- any(!vapply(parsed_map$mappings,
                             function(r) is.null(r$tagged), logical(1))) ||
                 identical(parsed_map$else_action, "tagged")
  labels_has_tag <- if (!is.null(parsed_labels)) {
    any(!is.na(haven::na_tag(parsed_labels)))
  } else FALSE

  if (map_has_tag || labels_has_tag) {
    resolved_convention <- .jst_resolve_convention(convention)
    if (identical(resolved_convention, "spss")) {
      err_msg <- .jst_jrecode_convention_error(
        parsed_map    = parsed_map,
        parsed_labels = parsed_labels,
        data_name     = .jst_data_name,
        orig_name     = orig_name
      )
      stop(paste0("Error in jrecode(): ", err_msg), call. = FALSE)
    }
    # else: Stata convention — proceed; tagged-NA tokens are valid.
  }

  # --- Apply recode ---
  # unclass() bypasses vctrs's "Can't convert <haven_labelled> to <double>"
  # cast refusal; underlying double values are preserved unchanged. See the
  # matching note in .jst_detect_suspicious_values() for full context.
  orig_num  <- as.numeric(unclass(orig))
  new_num   <- rep(NA_real_, length(orig_num))

  all_specified_old <- c()

  for (rule in parsed_map$mappings) {
    old_vals <- rule$old_vals
    all_specified_old <- c(all_specified_old, old_vals)

    # Warn if a specified old value is not present in the data
    actual_vals       <- unique(orig_num[!is.na(orig_num)])
    missing_from_data <- setdiff(old_vals, actual_vals)
    if (length(missing_from_data) > 0) {
      warning(paste0(
        "Value(s) ", paste(missing_from_data, collapse = ", "),
        " specified in the map argument were not found in '", orig_name, "'. ",
        "Check for typos in your map string."
      ))
    }

    rule_mask <- !is.na(orig_num) & orig_num %in% old_vals
    if (!is.null(rule$tagged)) {
      # Stata-style tagged-NA: assign haven::tagged_na(<letter>) so the
      # tag attribute is preserved on the underlying double storage.
      new_num[rule_mask] <- haven::tagged_na(rule$tagged)
    } else {
      new_num[rule_mask] <- rule$new_val
    }
  }

  # --- Handle unspecified non-NA values ---
  # Exclude values that were explicitly mapped (including mapped to NA)
  unspecified_mask <- !is.na(orig_num) & is.na(new_num) &
                      !(orig_num %in% all_specified_old)
  unspecified_vals <- sort(unique(orig_num[unspecified_mask]))

  # Separate suspicious from legitimate unspecified values
  suspicious_unspecified <- unspecified_vals[unspecified_vals %in% suspicious_vals]
  legitimate_unspecified <- unspecified_vals[!unspecified_vals %in% suspicious_vals]

  # Force suspicious values to NA regardless of else setting
  if (length(suspicious_unspecified) > 0) {
    suspicious_mask <- !is.na(orig_num) & orig_num %in% suspicious_unspecified
    new_num[suspicious_mask] <- NA_real_
  }

  # Handle legitimate unspecified values based on else setting
  if (length(legitimate_unspecified) > 0) {
    if (parsed_map$else_explicit && parsed_map$else_action == "copy") {
      # else=copy: carry legitimate values through
      legit_mask <- !is.na(orig_num) & orig_num %in% legitimate_unspecified
      new_num[legit_mask] <- orig_num[legit_mask]
    } else if (parsed_map$else_explicit && parsed_map$else_action == "na") {
      # Explicit else=NA: set to NA silently (student is being deliberate)
      # Values are already NA, nothing to do
    } else if (parsed_map$else_explicit && parsed_map$else_action == "tagged") {
      # Stata-style tagged-NA else: assign haven::tagged_na(<letter>)
      # to all legitimate unspecified cells.
      legit_mask <- !is.na(orig_num) & orig_num %in% legitimate_unspecified
      new_num[legit_mask] <- haven::tagged_na(parsed_map$else_tag)
    } else {
      # No else clause: stop so student can fix the map
      stop(paste0(
        "Value(s) ", paste(legitimate_unspecified, collapse = ", "),
        " in '", orig_name, "' were not in the map. ",
        "Map these values and re-run."
      ), call. = FALSE)
    }
  }

  # Print note about suspicious values that were forced to NA.
  # Partition by source so the wording matches what we actually know:
  #   - Values present in the variable's na_values metadata are UDM-
  #     confirmed and get definitive "is a user-defined missing value"
  #     wording.
  #   - Values flagged only by the heuristic get tentative "looks like
  #     a coded missing value" wording.
  # This avoids underspeaking when the user has already seen the UDM
  # noted at jload time. See Session 22 changelog ("Problem A") for the
  # design discussion.
  if (length(suspicious_unspecified) > 0) {
    udm_codes <- attr(orig, "na_values", exact = TRUE)
    if (is.null(udm_codes)) udm_codes <- numeric(0)

    udm_unspecified  <- suspicious_unspecified[suspicious_unspecified %in% udm_codes]
    heur_unspecified <- suspicious_unspecified[!suspicious_unspecified %in% udm_codes]

    .verb_phrase <- function(n, singular, plural) if (n == 1L) singular else plural

    if (length(udm_unspecified) > 0) {
      vp <- .verb_phrase(
        length(udm_unspecified),
        "is a user-defined missing value and was set to NA",
        "are user-defined missing values and were set to NA"
      )
      message(paste0(
        "Note: ", paste(udm_unspecified, collapse = ", "),
        " in '", orig_name, "' ", vp, "."
      ))
    }
    if (length(heur_unspecified) > 0) {
      vp <- .verb_phrase(
        length(heur_unspecified),
        "looks like a coded missing value and was set to NA",
        "look like coded missing values and were set to NA"
      )
      message(paste0(
        "Note: ", paste(heur_unspecified, collapse = ", "),
        " in '", orig_name, "' ", vp, "."
      ))
    }
  }

  # NAs in original are always NA in output
  new_num[is.na(orig_num)] <- NA_real_

  # --- Variable label ---
  is_haven       <- inherits(orig, "haven_labelled")
  orig_var_label <- if (is_haven) labelled::var_label(orig) else NULL

  new_var_label <- if (!is.null(orig_var_label) &&
                       nchar(trimws(orig_var_label)) > 0) {
    paste0(orig_var_label, " (recoded)")
  } else {
    paste0(orig_name, " (recoded)")
  }

  # --- Build output as haven_labelled vector ---
  result <- labelled::labelled(new_num)
  labelled::var_label(result) <- new_var_label

  # --- Value labels ---
  if (!is.null(parsed_labels)) {
    # User-supplied labels always take precedence. The labels argument
    # was validated and parsed at the top of jrecode() so the parsed
    # vector is consumed directly here.
    labelled::val_labels(result) <- parsed_labels
  } else {
    # No labels supplied — try to auto-transfer from original variable
    orig_val_labels <- if (is_haven) labelled::val_labels(orig) else NULL

    if (!is.null(orig_val_labels) && length(orig_val_labels) > 0) {
      # Detect collapsing: multiple old values mapping to the same new
      # NON-NA value. NA-targeted rules are missing-value conversion, not
      # category collapse — combining several codes into NA is what the
      # user explicitly asked for, not a side effect to flag. Without
      # this filter, the duplicate-detection branch fires on common
      # missing-conversion maps like "-99=NA; -98=NA; else=copy".
      non_na_rules <- Filter(function(r) !is.na(r$new_val),
                              parsed_map$mappings)

      is_collapsing <- any(vapply(non_na_rules,
                                  function(r) length(r$old_vals) > 1,
                                  logical(1)))
      if (!is_collapsing) {
        non_na_new_vals <- vapply(non_na_rules,
                                   function(r) r$new_val, numeric(1))
        is_collapsing <- anyDuplicated(non_na_new_vals) > 0
      }

      if (is_collapsing) {
        message("Note: Categories were collapsed. Use labels argument or jrelabel() ",
                "to assign new value labels.")
      } else {
        # One-to-one mapping — transfer labels to new codes
        old_to_new <- list()
        for (rule in parsed_map$mappings) {
          old_to_new[[as.character(rule$old_vals)]] <- rule$new_val
        }

        new_val_labels <- c()
        for (i in seq_along(orig_val_labels)) {
          old_code   <- unname(orig_val_labels[i])
          label_name <- names(orig_val_labels)[i]

          if (as.character(old_code) %in% names(old_to_new)) {
            # Explicitly mapped — use the new code, but drop the label
            # if the target is NA (no value to anchor the label to).
            entry <- old_to_new[[as.character(old_code)]]
            if (is.na(entry)) next
            names(entry)   <- label_name
            new_val_labels <- c(new_val_labels, entry)
          } else if (parsed_map$else_action == "copy") {
            # Unmapped but carried across unchanged
            entry        <- old_code
            names(entry) <- label_name
            new_val_labels <- c(new_val_labels, entry)
          }
          # else: value became NA via else_action, label is dropped
        }

        if (length(new_val_labels) > 0) {
          labelled::val_labels(result) <- new_val_labels
        }
      }
    } else {
      message("Note: No value labels assigned. To add labels, use jrelabel().")
    }
  }

  return(invisible(result))
}


# -- jdeclare_udm ------------------------------------------------------------

#' Declare user-defined missing values on a variable
#'
#' @description
#' \code{jdeclare_udm()} declares one or more user-defined missing
#' values (UDMs) on a variable. UDMs are specific data values --
#' typically negative codes such as \code{-99} or Stata-style tagged
#' markers such as \code{.a} -- that indicate \emph{why} a value is
#' missing (refused, don't know, not applicable, etc.) rather than
#' simply that it is missing. Once declared, UDM cells are
#' automatically excluded from analyses but remain visible in the data
#' for diagnostic purposes (see \code{jfreq()}).
#'
#' The function operates in declarative mode: each call states the
#' column's complete UDM set. A second call to \code{jdeclare_udm()} on
#' the same column replaces, not augments, the prior declaration. This
#' matches SPSS's \code{MISSING VALUES} and Stata's \code{mvdecode}
#' semantics. When prior UDMs are dropped, a note lists them so the
#' destructive aspect of the replacement is not silent.
#'
#' @param data A data frame containing the variable.
#' @param var  The variable to declare UDMs on (unquoted, e.g.
#'   \code{Income}).
#' @param codes Numeric vector of code values to declare as UDMs.
#'   Accepts two forms:
#'   \describe{
#'     \item{Option A (separate codes and labels)}{Unnamed numeric
#'       vector; labels supplied via the \code{labels} argument. E.g.
#'       \code{codes = c(-99, -98), labels = "-99=Refused; -98=Don't know"}.}
#'     \item{Option C (haven-style named vector)}{Named numeric vector;
#'       names are the labels. E.g.
#'       \code{codes = c(Refused = -99, `Don't know` = -98)}.}
#'   }
#'   Under Stata convention, code values may be Stata-style missing-value markers
#'   created with \code{haven::tagged_na()}, e.g.
#'   \code{codes = c(Refused = tagged_na("a"))}.
#' @param labels Optional. A quoted string in the form
#'   \code{"value=label; value=label"} pairing labels with codes
#'   (Option A only). Must be \code{NULL} when \code{codes} is named
#'   (Option C).
#' @param convention Optional. One of \code{"spss"} or \code{"stata"};
#'   overrides the convention resolution for this call. When
#'   \code{NULL} (the default), the convention is resolved from the
#'   column's existing UDM declaration (if any), then from
#'   \code{joptions("missing.convention")}, then from the SPSS-form
#'   default.
#' @param udm.notice Logical. When \code{TRUE} (the default), the
#'   function prints a notification summarizing what was declared.
#'   Set \code{FALSE} to suppress.
#'
#' @return The data frame, with the specified variable updated to
#'   carry the declared UDMs.
#'
#' @section Missing-Values Convention:
#' Under SPSS convention, codes are declared as numeric values via the
#' column's \code{na_values} attribute (haven's representation of
#' SPSS-form UDMs). The data cells themselves are unchanged; only the
#' metadata that flags certain values as missing is added.
#'
#' Under Stata convention with Stata-style missing-value input, the function attaches
#' value labels to existing Stata-style missing-value cells on the column.
#'
#' Under Stata convention with numeric input, the function converts
#' matching cells to Stata-style missing-value markers (Session 30 design lock). The
#' mapping is ordering-based: codes sorted by absolute value
#' descending, more-negative-first as tie-breaker, then assigned
#' \code{.a}, \code{.b}, \code{.c}, \code{.d} in that order. The
#' assignment proceeds independently of \code{joptions("udm.convention.codes")}
#' (which only governs the reverse Stata-to-SPSS direction). A
#' conversion note in the standard/full \code{joutput} tier shows the
#' Stata-style equivalent for future calls.
#'
#' @section Mixed conventions and file export:
#' A single data frame may carry both SPSS-form and Stata-form UDM
#' columns. In-memory analysis and display tolerate the mix without
#' issue (each column renders in its native form). The constraint
#' shows up at file-export time: \code{.sav} and \code{.xpt} cannot
#' represent Stata-style missing values; \code{.dta} cannot represent SPSS-form
#' \code{na_values} declarations. \code{jsave()} pre-flights the DF
#' against the destination format and errors with a pointer to
#' \code{jconvert()} when the mix is incompatible. The
#' post-declaration mismatch notice emitted at the bottom of this
#' function's output exists to alert you early if a single-column
#' declaration ends up out of step with the rest of its DF.
#'
#' @seealso \code{\link{jrecode}}, \code{\link{jconvert}},
#'   \code{\link{joptions}}, \code{\link{JeffsStatTools}}
#'
#' @examples
#' \dontrun{
#' # SPSS form: declare -99 and -98 as UDMs with labels
#' SampleData <- jdeclare_udm(SampleData, Income,
#'                            codes  = c(-99, -98),
#'                            labels = "-99=Refused; -98=DontKnow")
#'
#' # Equivalent using Option C (named codes)
#' SampleData <- jdeclare_udm(SampleData, Income,
#'                            codes = c(Refused = -99, DontKnow = -98))
#'
#' # Stata-style: label existing Stata-style missing-value cells
#' SampleData <- jdeclare_udm(SampleData, Income,
#'                            codes = c(Refused = tagged_na("a")))
#' }
#'
#' @export
jdeclare_udm <- function(data, var, codes, labels = NULL,
                         convention = NULL, udm.notice = TRUE) {

  # --- Resolve first argument -----------------------------------------------
  arg1 <- .jst_resolve_first_arg(
    data_sub      = substitute(data),
    data_missing  = missing(data),
    fn_name       = "jdeclare_udm",
    envir         = parent.frame(),
    accept_vector = FALSE
  )

  data      <- arg1$data
  data_name <- arg1$name

  # Determine variable name (parallel to jrecode's pattern).
  if (arg1$mode == "symbol_with_default") {
    if (!missing(var)) {
      displaced <- deparse(substitute(var))
      stop("jdeclare_udm(): when the data argument is omitted, all subsequent arguments must be named. ",
           "Use jdeclare_udm(", deparse(arg1$first_arg_sub), ", var = ", displaced, ", ...)",
           call. = FALSE)
    }
    var_name <- deparse(arg1$first_arg_sub)
  } else {
    var_name <- deparse(substitute(var))
  }

  # --- Input checks ---------------------------------------------------------
  if (!is.data.frame(data)) {
    stop("The first argument must be a data frame.", call. = FALSE)
  }
  if (!var_name %in% names(data)) {
    stop(paste0("Variable '", var_name, "' not found in '",
                data_name, "'."), call. = FALSE)
  }

  if (missing(codes) || is.null(codes)) {
    stop("jdeclare_udm() argument `codes` is required.", call. = FALSE)
  }
  if (!is.numeric(codes) || length(codes) == 0L) {
    stop("jdeclare_udm() argument `codes` must be a non-empty numeric ",
         "vector (Stata-style missing values are accepted under Stata convention).",
         call. = FALSE)
  }
  if (!is.logical(udm.notice) || length(udm.notice) != 1L ||
      is.na(udm.notice)) {
    stop("jdeclare_udm() argument `udm.notice` must be TRUE or FALSE.",
         call. = FALSE)
  }

  # Validate convention argument up front.
  if (!is.null(convention)) {
    if (!is.character(convention) || length(convention) != 1L ||
        !convention %in% c("spss", "stata")) {
      stop("The convention argument must be \"spss\" or \"stata\".",
           call. = FALSE)
    }
  }

  # --- Argument disambiguation (Option A vs Option C) ----------------------
  codes_names <- names(codes)
  has_all_names <- !is.null(codes_names) && all(nzchar(codes_names))
  has_any_names <- !is.null(codes_names) && any(nzchar(codes_names))
  partial_names <- has_any_names && !has_all_names

  if (partial_names) {
    stop("jdeclare_udm(): `codes` is partially named. Either name every ",
         "element (Option C) or none (Option A with separate labels=).",
         call. = FALSE)
  }

  if (has_all_names && !is.null(labels)) {
    stop("jdeclare_udm(): pick one labeling form. Either name every ",
         "element of `codes` (Option C) OR supply `labels = ...` ",
         "separately (Option A), not both.",
         call. = FALSE)
  }

  # --- Parse labels (Option A path) -----------------------------------------
  parsed_labels <- NULL
  if (!is.null(labels)) {
    if (!is.character(labels) || length(labels) != 1L) {
      stop("The labels argument must be a single quoted string, e.g. ",
           "labels = \"-99=Refused; -98=Don't know\".",
           call. = FALSE)
    }
    parsed_labels <- tryCatch(
      .jst_parse_labels(labels),
      error = function(e) stop(paste0("Error in labels argument: ",
                                       conditionMessage(e)),
                               call. = FALSE)
    )
  }

  # --- Build the canonical parsed_codes (named numeric, names = labels) ----
  #
  # parsed_codes is the internal canonical form: a named numeric vector
  # where names are the labels (empty string where none) and values are
  # the code values (numeric or tagged-NA). All branches below consume
  # this form.
  if (has_all_names) {
    # Option C: names are labels directly.
    parsed_codes <- codes
  } else {
    # Option A: codes is unnamed numeric; pair with labels by code value.
    if (is.null(parsed_labels)) {
      parsed_codes        <- codes
      names(parsed_codes) <- rep("", length(codes))
    } else {
      # Match each entry in parsed_labels by code value to codes.
      # parsed_labels is a named numeric vector (names = labels,
      # values = numeric or tagged_na). For each code in `codes`, look
      # up the matching parsed_labels entry.
      assigned <- rep(NA_character_, length(codes))
      pl_tags  <- haven::na_tag(parsed_labels)
      c_tags   <- haven::na_tag(codes)
      for (i in seq_along(codes)) {
        if (!is.na(c_tags[i])) {
          # tagged-NA code: match by tag letter
          idx <- which(!is.na(pl_tags) & pl_tags == c_tags[i])
        } else {
          # numeric code: match by numeric value (ignore tagged entries)
          idx <- which(is.na(pl_tags) & !is.na(parsed_labels) &
                       parsed_labels == codes[i])
        }
        if (length(idx) > 0L) {
          assigned[i] <- names(parsed_labels)[idx[1]]
        }
      }
      # Warn about any labels that didn't match any code.
      pl_unused_idx <- setdiff(seq_along(parsed_labels),
                               unique(unlist(lapply(seq_along(codes),
                                 function(i) {
                                   if (!is.na(c_tags[i])) {
                                     which(!is.na(pl_tags) & pl_tags == c_tags[i])
                                   } else {
                                     which(is.na(pl_tags) & !is.na(parsed_labels) &
                                           parsed_labels == codes[i])
                                   }
                                 }))))
      if (length(pl_unused_idx) > 0L) {
        unused_render <- paste(
          vapply(pl_unused_idx,
                 function(i) {
                   v <- parsed_labels[i]
                   if (!is.na(pl_tags[i])) sprintf(".%s=%s",
                                                  pl_tags[i],
                                                  names(parsed_labels)[i])
                   else sprintf("%s=%s",
                                format(as.numeric(v)),
                                names(parsed_labels)[i])
                 }, character(1)),
          collapse = "; ")
        stop("jdeclare_udm(): labels argument contains entries that ",
             "do not match any value in `codes`: ", unused_render, ".",
             call. = FALSE)
      }

      parsed_codes <- codes
      assigned[is.na(assigned)] <- ""
      names(parsed_codes) <- assigned
    }
  }

  # --- Detect tagged-NA elements -------------------------------------------
  c_tags         <- haven::na_tag(parsed_codes)
  tag_idx        <- which(!is.na(c_tags))
  num_idx        <- setdiff(seq_along(parsed_codes), tag_idx)
  has_tagged     <- length(tag_idx) > 0L
  has_numeric    <- length(num_idx) > 0L

  # --- Sign-off 4: reject mixed tagged + numeric ---------------------------
  if (has_tagged && has_numeric) {
    stop(.jst_jdeclare_udm_mixed_error(parsed_codes, data_name, var_name),
         call. = FALSE)
  }

  # --- Read existing UDM info on the column --------------------------------
  col          <- data[[var_name]]
  existing_info <- .jst_missing_info(col)
  existing_conv <- if (!is.null(existing_info)) existing_info$representation
                   else NULL

  # --- Sign-off 2: per-call convention vs existing column UDM conflict -----
  if (!is.null(convention) && !is.null(existing_conv) &&
      existing_conv != convention) {
    other_form <- if (existing_conv == "spss") "SPSS-style" else "Stata-style"
    stop("Column '", var_name, "' already carries ", other_form,
         " UDMs; cannot use convention = \"", convention,
         "\" here. Use jconvert() to convert the column first, or ",
         "omit the convention argument.", call. = FALSE)
  }

  # --- Resolve convention ---------------------------------------------------
  resolved_convention <- .jst_resolve_convention(
    per_call          = convention,
    column_convention = existing_conv
  )

  # --- Sign-off 3 / Branch D2: SPSS convention + tagged-NA input -----------
  if (resolved_convention == "spss" && has_tagged) {
    err_msg <- .jst_jdeclare_udm_convention_error(
      parsed_codes = parsed_codes,
      data_name    = data_name,
      var_name     = var_name
    )
    stop(err_msg, call. = FALSE)
  }

  # ==========================================================================
  #  Branch dispatch
  # ==========================================================================

  if (resolved_convention == "spss") {
    # ---------- Branch D1: SPSS canonical (numeric codes) ------------------
    new_col <- .jst_jdeclare_udm_spss(col, parsed_codes)
    branch  <- "spss_canonical"

  } else if (has_tagged) {
    # ---------- Branch D3: Stata canonical (tagged-NA labeling) -----------
    new_col <- .jst_jdeclare_udm_stata_label(col, parsed_codes)
    branch  <- "stata_canonical"

  } else {
    # ---------- Branch D4: Stata conversion (numeric -> tagged-NA) ---------
    conv_result <- .jst_jdeclare_udm_stata_convert(col, parsed_codes,
                                                   var_name)
    new_col <- conv_result$new_col
    branch  <- "stata_conversion"
    # Conversion-specific info for the notification.
    conversion_info <- conv_result
  }

  data[[var_name]] <- new_col

  # --- Sign-off 5: drop notice ---------------------------------------------
  drop_notice_msg <- NULL
  if (!is.null(existing_info)) {
    # Determine which existing codes are not in the new set. For SPSS-form
    # this is numeric values; for Stata-form this is tag letters.
    if (existing_info$representation == "spss") {
      old_codes <- as.numeric(existing_info$codes$numeric)
      new_codes <- if (branch == "spss_canonical") {
        as.numeric(parsed_codes)
      } else {
        # branch ended up Stata; everything SPSS-side is dropped
        old_codes
      }
      dropped_mask <- !old_codes %in% new_codes
    } else {
      # existing is Stata-form
      old_tags <- existing_info$codes$tag
      new_tags <- if (branch == "stata_canonical") {
        as.character(haven::na_tag(parsed_codes))
      } else if (branch == "stata_conversion") {
        conversion_info$tag_letters
      } else {
        # branch ended up SPSS; everything Stata-side is dropped
        old_tags
      }
      dropped_mask <- !old_tags %in% new_tags
    }
    if (any(dropped_mask)) {
      drop_notice_msg <- .jst_jdeclare_udm_drop_notice(
        dropped_df     = existing_info$codes[dropped_mask, , drop = FALSE],
        var_name       = var_name,
        representation = existing_info$representation
      )
    }
  }

  # --- Build and emit notification -----------------------------------------
  if (isTRUE(udm.notice)) {
    notif <- .jst_jdeclare_udm_notification(
      data_name           = data_name,
      var_name            = var_name,
      parsed_codes        = parsed_codes,
      branch              = branch,
      conversion_info     = if (branch == "stata_conversion") conversion_info
                            else NULL
    )
    cat(notif, sep = "")
  }

  # Drop notice fires after the main notification (consistent with the
  # established pattern of placing follow-on notes after the primary
  # output block).
  if (!is.null(drop_notice_msg) && isTRUE(udm.notice)) {
    cat(drop_notice_msg, "\n", sep = "")
  }

  # --- Post-declaration mismatch notice (Decision 11 closing rule) ---------
  if (isTRUE(udm.notice)) {
    df_predominant <- .jst_predominant_convention(data)
    if (!is.na(df_predominant) && df_predominant != resolved_convention) {
      this_form  <- if (resolved_convention == "spss") "SPSS-style" else "Stata-style"
      other_form <- if (df_predominant       == "spss") "SPSS-style" else "Stata-style"
      cat(sprintf(
        "Note: variable %s is %s, but other columns in %s are predominantly %s. Use jconvert() to align if desired.\n",
        var_name, this_form, data_name, other_form))
    }
  }

  invisible(data)
}


# -----------------------------------------------------------------------------
# Branch D1: SPSS canonical
# -----------------------------------------------------------------------------

#' @keywords internal
.jst_jdeclare_udm_spss <- function(col, parsed_codes) {
  # parsed_codes: named numeric vector (names = labels or "", values =
  # numeric codes). Tagged-NA elements have been ruled out upstream.

  code_vals <- as.numeric(unname(parsed_codes))

  # Validate codes: finite, whole, no duplicates.
  if (any(!is.finite(code_vals))) {
    stop("jdeclare_udm(): codes must be finite numeric values.",
         call. = FALSE)
  }
  if (any(code_vals != floor(code_vals))) {
    stop("jdeclare_udm(): codes must be whole numbers.",
         call. = FALSE)
  }
  if (anyDuplicated(code_vals) > 0L) {
    stop("jdeclare_udm(): codes contains duplicate values.",
         call. = FALSE)
  }

  # Build the new value-labels set. Merge any existing labels with the
  # newly supplied ones (new labels win for the codes being declared).
  existing_labs <- if (haven::is.labelled(col)) labelled::val_labels(col)
                   else NULL

  # Strip any existing labels that point at codes being newly declared
  # (we'll re-add them with possibly different labels below). Existing
  # labels pointing at non-UDM codes (real-data labels) are preserved.
  if (!is.null(existing_labs) && length(existing_labs) > 0L) {
    keep_mask <- !(unname(existing_labs) %in% code_vals)
    existing_labs <- existing_labs[keep_mask]
  }

  # Build new labels for codes that have a label.
  label_names <- names(parsed_codes)
  new_labs <- numeric(0)
  for (i in seq_along(parsed_codes)) {
    if (nzchar(label_names[i])) {
      entry <- as.numeric(parsed_codes[i])
      names(entry) <- label_names[i]
      new_labs <- c(new_labs, entry)
    }
  }

  combined_labs <- c(existing_labs, new_labs)
  if (length(combined_labs) == 0L) combined_labs <- NULL

  # Use labelled_spss to attach na_values together with labels and
  # variable label.
  haven::labelled_spss(
    x         = as.numeric(unclass(col)),
    labels    = combined_labs,
    na_values = code_vals,
    label     = attr(col, "label", exact = TRUE)
  )
}


# -----------------------------------------------------------------------------
# Branch D3: Stata canonical (label existing tagged-NA cells)
# -----------------------------------------------------------------------------

#' @keywords internal
.jst_jdeclare_udm_stata_label <- function(col, parsed_codes) {
  # parsed_codes: named numeric vector where every value is a tagged-NA
  # (NA_real_ with a tag attribute).

  tags <- haven::na_tag(parsed_codes)
  if (anyDuplicated(tags) > 0L) {
    stop("jdeclare_udm(): codes contains duplicate Stata-style missing-value letters.",
         call. = FALSE)
  }

  existing_labs <- if (haven::is.labelled(col)) labelled::val_labels(col)
                   else NULL

  # Strip any existing tagged-NA labels for the tags being newly
  # declared. Plain-numeric labels are preserved.
  if (!is.null(existing_labs) && length(existing_labs) > 0L) {
    existing_tags <- haven::na_tag(existing_labs)
    keep_mask <- is.na(existing_tags) | !(existing_tags %in% tags)
    existing_labs <- existing_labs[keep_mask]
  }

  # Build new tagged-NA labels.
  label_names <- names(parsed_codes)
  new_labs <- numeric(0)
  for (i in seq_along(parsed_codes)) {
    if (nzchar(label_names[i])) {
      entry <- haven::tagged_na(tags[i])
      names(entry) <- label_names[i]
      new_labs <- c(new_labs, entry)
    }
  }

  combined_labs <- c(existing_labs, new_labs)
  if (length(combined_labs) == 0L) combined_labs <- NULL

  # Plain labelled (not labelled_spss); strip na_values if it leaked in.
  out <- haven::labelled(
    x      = as.numeric(unclass(col)),
    labels = combined_labs,
    label  = attr(col, "label", exact = TRUE)
  )
  out
}


# -----------------------------------------------------------------------------
# Branch D4: Stata conversion (numeric codes -> tagged-NA cells)
# -----------------------------------------------------------------------------

#' @keywords internal
.jst_jdeclare_udm_stata_convert <- function(col, parsed_codes, var_name) {
  # parsed_codes: named numeric vector (names = labels or "", values =
  # plain numeric codes). Tagged-NA elements ruled out upstream.

  code_vals <- as.numeric(unname(parsed_codes))

  # Validate codes.
  if (any(!is.finite(code_vals))) {
    stop("jdeclare_udm(): codes must be finite numeric values.",
         call. = FALSE)
  }
  if (any(code_vals != floor(code_vals))) {
    stop("jdeclare_udm(): codes must be whole numbers.",
         call. = FALSE)
  }
  if (anyDuplicated(code_vals) > 0L) {
    stop("jdeclare_udm(): codes contains duplicate values.",
         call. = FALSE)
  }
  if (length(code_vals) > 4L) {
    stop("jdeclare_udm(): under Stata convention with numeric codes, at ",
         "most 4 codes can be converted (mapped to .a, .b, .c, .d). Use ",
         "jrecode() with explicit .a-.z mappings for more.",
         call. = FALSE)
  }

  # Ordering-based mapping per Session 30 Branch D4 (Q6): codes sorted by
  # |code| descending, more-negative-first as tie-breaker. Then .a, .b,
  # .c, .d in that order.
  ordering           <- order(-abs(code_vals), code_vals)
  sorted_codes       <- code_vals[ordering]
  sorted_labels      <- names(parsed_codes)[ordering]
  tag_letters        <- letters[seq_along(sorted_codes)]

  x_num <- suppressWarnings(as.numeric(unclass(col)))
  new_col <- as.numeric(x_num)
  for (i in seq_along(sorted_codes)) {
    pos <- which(!is.na(x_num) & x_num == sorted_codes[i])
    new_col[pos] <- haven::tagged_na(tag_letters[i])
  }

  # Build val_labels with tagged_na as the value, label as the name.
  existing_labs <- if (haven::is.labelled(col)) labelled::val_labels(col)
                   else NULL

  # Strip any existing labels pointing at the codes being converted
  # (they're now tagged-NA values, not the numeric codes any more).
  if (!is.null(existing_labs) && length(existing_labs) > 0L) {
    keep_mask <- !(unname(existing_labs) %in% sorted_codes)
    existing_labs <- existing_labs[keep_mask]
  }

  new_labs <- numeric(0)
  for (i in seq_along(sorted_codes)) {
    if (nzchar(sorted_labels[i])) {
      entry <- haven::tagged_na(tag_letters[i])
      names(entry) <- sorted_labels[i]
      new_labs <- c(new_labs, entry)
    }
  }

  combined_labs <- c(existing_labs, new_labs)
  if (length(combined_labs) == 0L) combined_labs <- NULL

  out <- haven::labelled(
    x      = new_col,
    labels = combined_labs,
    label  = attr(col, "label", exact = TRUE)
  )

  list(
    new_col       = out,
    sorted_codes  = sorted_codes,
    sorted_labels = sorted_labels,
    tag_letters   = tag_letters
  )
}


# -----------------------------------------------------------------------------
# Notification builder
# -----------------------------------------------------------------------------

#' @keywords internal
.jst_jdeclare_udm_notification <- function(data_name, var_name,
                                           parsed_codes, branch,
                                           conversion_info = NULL) {

  output_level <- getOption(".jst_output_level", "standard")

  header <- switch(
    branch,
    spss_canonical    = paste0("Declared SPSS-style missing values in:"),
    stata_canonical   = paste0("Labelled Stata-style missing values in:"),
    stata_conversion  = paste0("Declared and converted to Stata-style missing values in:")
  )

  # Build body lines: code [label] format per jfreq's v0.9.5 Missing-section
  # display.
  body_lines <- character(0)
  if (branch == "stata_conversion") {
    # Lines reflect post-conversion state (tag letters, not source codes).
    for (i in seq_along(conversion_info$sorted_codes)) {
      tag <- conversion_info$tag_letters[i]
      lbl <- conversion_info$sorted_labels[i]
      if (nzchar(lbl)) {
        body_lines <- c(body_lines,
                        sprintf("  .%s [\"%s\"]  (from %s)",
                                tag, lbl,
                                format(conversion_info$sorted_codes[i])))
      } else {
        body_lines <- c(body_lines,
                        sprintf("  .%s  (from %s)",
                                tag,
                                format(conversion_info$sorted_codes[i])))
      }
    }
  } else if (branch == "stata_canonical") {
    c_tags <- haven::na_tag(parsed_codes)
    for (i in seq_along(parsed_codes)) {
      lbl <- names(parsed_codes)[i]
      if (nzchar(lbl)) {
        body_lines <- c(body_lines,
                        sprintf("  .%s [\"%s\"]", c_tags[i], lbl))
      } else {
        body_lines <- c(body_lines, sprintf("  .%s", c_tags[i]))
      }
    }
  } else {
    # SPSS canonical
    for (i in seq_along(parsed_codes)) {
      v   <- format(as.numeric(parsed_codes[i]))
      lbl <- names(parsed_codes)[i]
      if (nzchar(lbl)) {
        body_lines <- c(body_lines,
                        sprintf("  %s [\"%s\"]", v, lbl))
      } else {
        body_lines <- c(body_lines, sprintf("  %s", v))
      }
    }
  }

  msg <- paste0(
    header, "\n",
    "  ", data_name, "$", var_name, "\n",
    paste(body_lines, collapse = "\n"), "\n"
  )

  # Standard / full tier: assignment-syntax reminder.
  if (!identical(output_level, "minimal")) {
    reminder <- paste0(
      "Note: jdeclare_udm() returns the modified data frame; remember the assignment: ",
      data_name, " <- jdeclare_udm(", data_name, ", ", var_name, ", ...).\n"
    )
    msg <- paste0(msg, reminder)
  }

  # Full tier: conversion equivalent for Stata-conversion branch.
  if (identical(output_level, "full") && branch == "stata_conversion") {
    tag_parts <- character(0)
    for (i in seq_along(conversion_info$sorted_codes)) {
      tag <- conversion_info$tag_letters[i]
      lbl <- conversion_info$sorted_labels[i]
      rhs <- paste0("tagged_na(\"", tag, "\")")
      if (nzchar(lbl)) {
        lbl_render <- if (grepl("^[A-Za-z.][A-Za-z0-9._]*$", lbl)) lbl
                      else paste0("`", lbl, "`")
        tag_parts <- c(tag_parts, paste0(lbl_render, " = ", rhs))
      } else {
        tag_parts <- c(tag_parts, rhs)
      }
    }
    eq_call <- paste0(
      "Equivalent Stata-style call for future use:\n",
      "    ", data_name, " <- jdeclare_udm(", data_name, ", ", var_name,
      ", codes = c(", paste(tag_parts, collapse = ", "), "))\n"
    )
    msg <- paste0(msg, eq_call)
  }

  msg
}

# =============================================================================
#  DATA I/O
# =============================================================================

# -- jconvert -----------------------------------------------------------------

#' Convert user-defined missing value (UDM) declarations between formats
#'
#' \code{jconvert()} provides a single entry point for changing how user-
#' defined missing values (UDMs) are represented on the columns of a data
#' frame already in memory. Three target formats are supported: SPSS-style
#' (\code{na_values} on \code{haven_labelled_spss}), Stata-style
#' (\code{tagged_na} on \code{haven_labelled}), and base R (declarations
#' stripped, declared cells converted to plain \code{NA}). Replaces
#' \code{jstrip_udm()} (retired in v0.9.5); the base R target is the strip
#' behavior.
#'
#' @param data A data frame, or omitted to use the \code{juse()} default.
#' @param to One of \code{"baseR"}, \code{"spss"}, or \code{"stata"}
#'   (case-sensitive). When \code{NULL} (the default), \code{jconvert()}
#'   reads \code{joptions("missing.convention")}: if the slot is set to
#'   \code{"spss"} or \code{"stata"}, \code{to} resolves to that value; if
#'   the slot is at its \code{"none"} default, \code{jconvert()} errors
#'   with guidance naming the three concrete options. The destructive
#'   \code{"baseR"} target is never auto-resolved — it must always be
#'   passed explicitly.
#' @param ... Optional unquoted variable names. When supplied, only the
#'   listed variables are scanned. Mutually exclusive with \code{vars}.
#' @param vars Alternative scope-by-vector path: a character vector of
#'   variable names. Mutually exclusive with \code{...}. When both
#'   \code{...} and \code{vars} are empty, \code{jconvert()} operates on
#'   the whole data frame.
#' @param udm.notice Logical; \code{TRUE} (default) prints a notification
#'   summarizing what was converted (and what was skipped) along with an
#'   assignment-syntax reminder. \code{FALSE} suppresses the message.
#'   Always-on by default; does not consult \code{joutput()} because the
#'   function reports an action it just performed rather than explaining
#'   system behavior.
#'
#' @return The data frame with the requested conversions applied, returned
#'   invisibly. As with \code{jrelabel()} and \code{jrecode()}, the user
#'   must assign the return value back to retain the changes.
#'
#' @details
#' The three target formats:
#' \describe{
#'   \item{\code{to = "baseR"}}{Strip all UDM declarations and convert
#'     declared cells to plain \code{NA}. For SPSS-form columns
#'     (\code{na_values} / \code{na_range} on
#'     \code{haven_labelled_spss}), masks declared codes to \code{NA} and
#'     removes the attributes; value labels are preserved so the column
#'     can still round-trip through \code{jsave()} with original
#'     labeling. For columns carrying Stata-style missing values
#'     (\code{tagged_na} markers), uses \code{haven::zap_missing()} to
#'     convert them to plain \code{NA}s.}
#'   \item{\code{to = "spss"}}{Convert Stata-style or SAS-style missing
#'     values to SPSS-form numeric codes. Letter tags map to numeric
#'     codes via \code{joptions("udm.convention.codes")} (default
#'     \code{-99}, \code{-98}, \code{-97}, \code{-96}):
#'     \code{.a -> codes[1]}, \code{.b -> codes[2]}, and so on. SAS-style
#'     (uppercase) tags are case-corrected to Stata-style (lowercase)
#'     before the numeric mapping — for round-trip purposes the package
#'     treats \code{.A} and \code{.a} as the same conceptual marker, and
#'     mixed-case columns collapse to a single lowercase marker (SPSS has
#'     no parallel uppercase convention). The notification's per-column
#'     display shows the original (pre-correction) tag for SAS-corrected
#'     columns — e.g. \code{.A "Refused" -> -99} — so the user-visible
#'     mapping reflects what was actually in the data on input. Letter
#'     tags beyond \code{.d} (after case correction) are refused with
#'     guidance to use \code{jrecode()} for manual mapping.}
#'   \item{\code{to = "stata"}}{Convert SPSS-form numeric codes to
#'     Stata-style missing values. Letter tags are assigned by ordering
#'     rather than by convention: each column's own declared
#'     \code{na_values} codes are sorted by absolute value descending
#'     (ties broken with more-negative-first), then mapped
#'     \code{.a, .b, .c, .d} in that order. Convention codes are NOT
#'     consulted for this direction;
#'     they only govern the reverse (Stata to SPSS) mapping. Round-trip
#'     conversions are not guaranteed to preserve the original numeric
#'     codes (e.g. SPSS \code{c(-1, 9)} -> Stata \code{.a, .b} -> SPSS
#'     \code{c(-99, -98)} loses the original numbers), but the value
#'     labels survive intact and the missingness semantics are preserved.
#'     Range-based SPSS missings (\code{na_range}) are out of cross-format
#'     scope; columns with \code{na_range} are refused with guidance to
#'     enumerate the range in SPSS first. Columns with more than 4
#'     distinct \code{na_values} codes are also refused (matches the
#'     4-code cap on Stata letter-tag mapping).}
#' }
#'
#' Pre-flight checks for \code{to = "spss"} include a collision check:
#' if a column's target numeric code (e.g. \code{-99} for \code{.a}) is
#' present as genuine data in the column, the call errors before any
#' data is touched. The error message lists every colliding column and
#' presents three resolution paths: change the convention codes via
#' \code{joptions(udm.convention.codes = ...)}, scope the call via
#' \code{vars = c(...)} to exclude affected columns, or recode the real-
#' data values via \code{jrecode()} first. Atomicity applies to every
#' error mode — the entire \code{jconvert()} call either succeeds or
#' errors before mutating the data frame.
#'
#' \strong{Pattern A — value labels suggest missingness but no formal
#' declaration.} When a column has no formal UDM declaration but carries
#' value labels matching the package's missing-label wordlist (e.g.
#' \code{"Refused"}, \code{"Don't know"}, \code{"Not applicable"}),
#' \code{jconvert()} skips the column and surfaces it in the
#' notification with the affected value/label pairs. To formalise these
#' as UDMs use \code{jdeclare_udm()}; to leave them as ordinary data, no
#' action is needed.
#'
#' @examples
#' \dontrun{
#' # Strip UDMs from every applicable variable:
#' MyData <- jconvert(MyData, to = "baseR")
#'
#' # Convert SPSS-form UDMs to Stata-style missing values:
#' MyData <- jconvert(MyData, to = "stata")
#'
#' # Convert with target inferred from joptions:
#' joptions(missing.convention = "spss")
#' MyData <- jconvert(MyData)   # converts any Stata-form columns to SPSS
#'
#' # Scope by unquoted names:
#' MyData <- jconvert(MyData, to = "baseR", Income, Age)
#'
#' # Scope by character vector (alternative form):
#' MyData <- jconvert(MyData, to = "baseR", vars = c("Income", "Age"))
#'
#' # Suppress the notification (e.g. inside a script):
#' MyData <- jconvert(MyData, to = "baseR", udm.notice = FALSE)
#' }
#'
#' @seealso \code{\link{jload}} for the load-time strip alternative
#'   (\code{preserve.udm = FALSE}); \code{\link{joptions}} for setting
#'   the default convention and convention codes session-wide.
#'
#' @export
jconvert <- function(data, to = NULL, ..., vars = NULL, udm.notice = TRUE) {

  # --- Resolve first argument -------------------------------------------------
  arg1 <- .jst_resolve_first_arg(
    data_sub      = substitute(data),
    data_missing  = missing(data),
    fn_name       = "jconvert",
    envir         = parent.frame(),
    accept_vector = FALSE
  )

  data      <- arg1$data
  data_name <- arg1$name

  # --- Resolve `to` -----------------------------------------------------------
  # Auto-resolve from joptions when to= is NULL. spss/stata flow through;
  # "none" errors with guidance (Q5 of the Session 28 jconvert design lock).
  # baseR never auto-resolves — destructive transformations require
  # explicit intent.
  if (is.null(to)) {
    convention <- getOption(".jst_options_missing_convention",
                            .jst_options_defaults$missing.convention)
    if (convention %in% c("spss", "stata")) {
      to <- convention
    } else {
      stop(
        "jconvert() needs a target format. Pass to = \"baseR\", \"spss\", ",
        "or \"stata\" explicitly, or set joptions(missing.convention = ",
        "\"spss\") (or \"stata\") to enable auto-resolution.",
        call. = FALSE
      )
    }
  }
  if (!is.character(to) || length(to) != 1L ||
      !to %in% c("baseR", "spss", "stata")) {
    stop("jconvert() argument `to` must be one of \"baseR\", \"spss\", ",
         "or \"stata\" (case-sensitive).", call. = FALSE)
  }

  # --- Resolve variable list (... vs vars; mutually exclusive) ---------------
  variables <- rlang::enquos(...)

  # Leading-comma-omitted form: if first arg was captured as a bare symbol
  # alongside an active juse() default, prepend it to the variables list.
  if (arg1$mode == "symbol_with_default") {
    extra_quo <- rlang::new_quosure(arg1$first_arg_sub, env = parent.frame())
    variables <- c(list(extra_quo), variables)
    class(variables) <- "quosures"
  }

  dot_names <- if (length(variables) > 0) {
    vapply(variables, rlang::quo_name, character(1))
  } else {
    character(0)
  }

  if (length(dot_names) > 0 && !is.null(vars)) {
    stop("jconvert() accepts either unquoted variable names (...) or a ",
         "character vector via vars = c(...), but not both.",
         call. = FALSE)
  }
  if (!is.null(vars) && (!is.character(vars) || length(vars) == 0L)) {
    stop("jconvert() argument `vars` must be a non-empty character vector ",
         "of variable names.", call. = FALSE)
  }

  if (length(dot_names) > 0) {
    .jst_check_vars(data, dot_names, data_name)
    target_vars    <- dot_names
    user_specified <- TRUE
    var_scope      <- "dots"
  } else if (!is.null(vars)) {
    .jst_check_vars(data, vars, data_name)
    target_vars    <- vars
    user_specified <- TRUE
    var_scope      <- "vars"
  } else {
    target_vars    <- names(data)
    user_specified <- FALSE
    var_scope      <- "all"
  }

  # --- Classify each target column -------------------------------------------
  info_list       <- list()
  pattern_a       <- list()
  skipped_no_udms <- character(0)

  for (vname in target_vars) {
    col  <- data[[vname]]
    info <- .jst_missing_info(col)

    if (!is.null(info)) {
      info_list[[vname]] <- info
      next
    }

    # Pattern A scan: no formal declaration. Look for value labels matching
    # the missing-label wordlist (.jst_label_suggests_missing).
    pa_entries <- list()
    if (haven::is.labelled(col)) {
      val_labs <- labelled::val_labels(col)
      if (!is.null(val_labs) && length(val_labs) > 0L) {
        for (i in seq_along(val_labs)) {
          lbl <- names(val_labs)[i]
          if (.jst_label_suggests_missing(lbl)) {
            pa_entries[[length(pa_entries) + 1L]] <- list(
              value = unname(val_labs[i]),
              label = lbl
            )
          }
        }
      }
    }
    if (length(pa_entries) > 0L) {
      pattern_a[[vname]] <- pa_entries
    } else if (user_specified) {
      skipped_no_udms <- c(skipped_no_udms, vname)
    }
  }

  # --- Pre-flight checks: Q3 strict atomicity --------------------------------
  convention_codes <- getOption(".jst_options_udm_convention_codes",
                                .jst_options_defaults$udm.convention.codes)
  letter_codes <- letters[seq_along(convention_codes)]
  code_for_tag <- .jst_tag_letters_to_codes(letter_codes, convention_codes)
  tag_for_code <- stats::setNames(letter_codes, as.character(convention_codes))

  # Tracking for SAS-style (uppercase) tagged-NA case correction performed
  # inside the to = "spss" branch. Declared at function scope so the
  # notification builder (below) can read it regardless of which branch
  # the call took.
  sas_corrected_vars <- character(0)

  if (to == "spss") {
    # Case-correct SAS-style tags before validating. The convention codes
    # map lowercase letters positionally (.a -> codes[1], .b -> codes[2],
    # ...); uppercase tags have no native SPSS-form representation. Like
    # jsave's .dta path, jconvert treats .A and .a as the same conceptual
    # marker for round-trip purposes, converting the former to the latter
    # before the numeric mapping. Mixed-case columns (a column containing
    # both .a and .A) collapse to a single .a marker — the case
    # distinction is not preserved through SPSS-form, since SPSS has no
    # parallel uppercase convention.
    for (vname in names(info_list)) {
      info <- info_list[[vname]]
      if (info$representation != "stata") next
      col <- data[[vname]]
      if (!is.double(col)) next

      cell_changed  <- FALSE
      label_changed <- FALSE

      tags        <- haven::na_tag(col)
      upper_cells <- which(!is.na(tags) & tags %in% LETTERS)
      if (length(upper_cells) > 0L) {
        for (i in upper_cells) col[i] <- haven::tagged_na(tolower(tags[i]))
        cell_changed <- TRUE
      }

      if (haven::is.labelled(col)) {
        vl <- labelled::val_labels(col)
        if (!is.null(vl) && length(vl) > 0L) {
          lab_tags   <- haven::na_tag(vl)
          upper_labs <- which(!is.na(lab_tags) & lab_tags %in% LETTERS)
          if (length(upper_labs) > 0L) {
            for (i in upper_labs) vl[i] <- haven::tagged_na(tolower(lab_tags[i]))
            labelled::val_labels(col) <- vl
            label_changed <- TRUE
          }
        }
      }

      if (cell_changed || label_changed) {
        data[[vname]]      <- col
        sas_corrected_vars <- c(sas_corrected_vars, vname)
        # Refresh info_list so the downstream validation and conversion
        # loops see post-correction tags rather than the original .A/.B.
        info_list[[vname]] <- .jst_missing_info(col)
      }
    }

    # Stata-to-SPSS: check for letter-tag-beyond-.d and collisions.
    beyond_d_vars  <- list()
    collision_vars <- list()

    for (vname in names(info_list)) {
      info <- info_list[[vname]]
      if (info$representation != "stata") next

      col  <- data[[vname]]
      tags <- haven::na_tag(col)
      unique_tags <- unique(tags[!is.na(tags)])

      bad_tags <- unique_tags[!unique_tags %in% letter_codes]
      if (length(bad_tags) > 0L) {
        beyond_d_vars[[length(beyond_d_vars) + 1L]] <- list(
          var = vname, tags = paste0(".", bad_tags))
      }
      good_tags <- intersect(unique_tags, letter_codes)
      if (length(good_tags) > 0L) {
        x_num         <- suppressWarnings(as.numeric(unclass(col)))
        target_codes  <- unname(code_for_tag[good_tags])
        real_values   <- x_num[!is.na(x_num)]
        hits <- target_codes[
          vapply(target_codes,
                 function(tc) any(real_values == tc),
                 logical(1))
        ]
        if (length(hits) > 0L) {
          collision_vars[[length(collision_vars) + 1L]] <- list(
            var = vname, codes = hits)
        }
      }
    }

    if (length(beyond_d_vars) > 0L || length(collision_vars) > 0L) {
      msg_lines <- "jconvert() cannot proceed with to = \"spss\":"
      if (length(beyond_d_vars) > 0L) {
        msg_lines <- c(msg_lines, "",
                       "  Letter tags beyond .d (jconvert supports .a-.d):")
        for (e in beyond_d_vars) {
          msg_lines <- c(msg_lines,
                         sprintf("    %s: %s", e$var,
                                 paste(e$tags, collapse = ", ")))
        }
      }
      if (length(collision_vars) > 0L) {
        msg_lines <- c(msg_lines, "",
                       "  Target numeric codes collide with real data values:")
        for (e in collision_vars) {
          msg_lines <- c(msg_lines,
                         sprintf("    %s: %s", e$var,
                                 paste(e$codes, collapse = ", ")))
        }
      }
      msg_lines <- c(msg_lines, "",
                     "Resolution options:",
                     "  1. Change the convention codes:",
                     "       joptions(udm.convention.codes = c(...))",
                     "  2. Scope the call to exclude affected columns:",
                     sprintf("       jconvert(%s, to = \"spss\", vars = c(...))",
                             data_name),
                     "  3. Recode the real-data values first via jrecode().")
      stop(paste(msg_lines, collapse = "\n"), call. = FALSE)
    }
  }

  if (to == "stata") {
    # SPSS-to-Stata: check for na_range (out of scope) and >4 codes. The
    # codes themselves are mapped to letter tags by descending |code|
    # within each column (per Q6 of the Session 29 design lock); the
    # convention codes are NOT consulted for this direction.
    range_vars     <- character(0)
    over_cap_vars  <- list()

    for (vname in names(info_list)) {
      info <- info_list[[vname]]
      if (info$representation != "spss") next

      if (!is.null(info$na_range) && length(info$na_range) == 2L) {
        range_vars <- c(range_vars, vname)
      }
      if (!is.null(info$codes) && nrow(info$codes) > 4L) {
        over_cap_vars[[length(over_cap_vars) + 1L]] <- list(
          var = vname, n_codes = nrow(info$codes))
      }
    }

    if (length(range_vars) > 0L || length(over_cap_vars) > 0L) {
      msg_lines <- "jconvert() cannot proceed with to = \"stata\":"
      if (length(range_vars) > 0L) {
        msg_lines <- c(msg_lines, "",
                       "  Range-based SPSS missings (na_range) are out of",
                       "  cross-format scope:")
        for (v in range_vars) {
          msg_lines <- c(msg_lines, sprintf("    %s", v))
        }
        msg_lines <- c(msg_lines,
                       "  Enumerate the range as individual na_values codes",
                       "  in SPSS before converting, or scope the call to",
                       "  exclude these columns.")
      }
      if (length(over_cap_vars) > 0L) {
        msg_lines <- c(msg_lines, "",
                       "  More than 4 distinct na_values codes (jconvert",
                       "  supports up to 4 distinct tags .a-.d):")
        for (e in over_cap_vars) {
          msg_lines <- c(msg_lines,
                         sprintf("    %s: %d codes", e$var, e$n_codes))
        }
      }
      msg_lines <- c(msg_lines, "",
                     "Resolution options:",
                     "  1. Scope the call to exclude affected columns:",
                     sprintf("       jconvert(%s, to = \"stata\", vars = c(...))",
                             data_name),
                     "  2. Recode the codes manually via jrecode().")
      stop(paste(msg_lines, collapse = "\n"), call. = FALSE)
    }
  }

  # --- Perform conversions ---------------------------------------------------
  converted_vars   <- character(0)
  converted_info   <- list()
  skipped_already  <- character(0)   # in target format already (user_specified only)

  for (vname in names(info_list)) {
    info <- info_list[[vname]]
    col  <- data[[vname]]

    if (to == "baseR") {

      if (info$representation == "spss") {
        x_num <- suppressWarnings(as.numeric(unclass(col)))
        mask  <- rep(FALSE, length(x_num))
        if (!is.null(info$codes) && nrow(info$codes) > 0L) {
          declared_codes <- info$codes$numeric
          declared_codes <- declared_codes[!is.na(declared_codes)]
          if (length(declared_codes) > 0L) {
            mask <- mask | (!is.na(x_num) & x_num %in% declared_codes)
          }
        }
        if (!is.null(info$na_range) && length(info$na_range) == 2L) {
          mask <- mask | (!is.na(x_num) &
                            x_num >= info$na_range[1] &
                            x_num <= info$na_range[2])
        }
        data[[vname]][mask]              <- NA
        attr(data[[vname]], "na_values") <- NULL
        attr(data[[vname]], "na_range")  <- NULL
      } else {
        # Stata-form: haven::zap_missing handles tagged NAs uniformly.
        data[[vname]] <- haven::zap_missing(col)
      }

      # Build the display entries from the original info (pre-strip codes).
      display_entries <- character(0)
      if (!is.null(info$codes) && nrow(info$codes) > 0L) {
        for (i in seq_len(nrow(info$codes))) {
          code <- info$codes$code[i]
          lbl  <- info$codes$label[i]
          display_entries <- c(display_entries,
                               if (!is.na(lbl)) {
                                 sprintf('%s "%s"', code, lbl)
                               } else code)
        }
      }
      if (!is.null(info$na_range) && length(info$na_range) == 2L) {
        display_entries <- c(display_entries,
                             sprintf("range [%s, %s]",
                                     as.character(info$na_range[1]),
                                     as.character(info$na_range[2])))
      }
      converted_vars         <- c(converted_vars, vname)
      converted_info[[vname]] <- list(display = display_entries)

    } else if (to == "spss") {

      if (info$representation == "spss") {
        # Already in target — silent for whole-DF, reported as skipped for
        # explicit-named. Tracked unconditionally so the notification
        # builder can detect the "everything already in target" whole-DF
        # case and report it distinctly from the genuinely-empty case.
        skipped_already <- c(skipped_already, vname)
        next
      }

      tags  <- haven::na_tag(col)
      x_num <- suppressWarnings(as.numeric(unclass(col)))
      unique_tags <- unique(tags[!is.na(tags)])
      for (tg in unique_tags) {
        pos <- which(!is.na(tags) & tags == tg)
        x_num[pos] <- code_for_tag[[tg]]
      }

      val_labs     <- labelled::val_labels(col)
      new_val_labs <- val_labs
      if (!is.null(new_val_labs) && length(new_val_labs) > 0L) {
        vl_tags <- haven::na_tag(new_val_labs)
        for (i in seq_along(new_val_labs)) {
          if (!is.na(vl_tags[i]) && vl_tags[i] %in% letter_codes) {
            new_val_labs[i] <- code_for_tag[[vl_tags[i]]]
          }
        }
      }

      used_codes <- unname(code_for_tag[unique_tags])
      data[[vname]] <- haven::labelled_spss(
        x         = x_num,
        labels    = new_val_labs,
        na_values = used_codes,
        label     = attr(col, "label", exact = TRUE)
      )

      # Build display entries — source tag -> destination code, with the
      # label on the source side. Sort by tag (a, b, c, d) for stable
      # display order regardless of order-of-appearance in the data.
      # SAS-corrected columns display the original uppercase tag, since
      # post-correction `.a`/`.b` would obscure what the user actually
      # had in their data on input.
      was_sas <- vname %in% sas_corrected_vars
      display_entries <- character(0)
      for (tg in sort(unique_tags)) {
        code <- code_for_tag[[tg]]
        display_tag <- if (was_sas) toupper(tg) else tg
        source_disp <- paste0(".", display_tag)
        lbl  <- NA_character_
        if (!is.null(val_labs) && length(val_labs) > 0L) {
          vl_tags <- haven::na_tag(val_labs)
          mm <- which(!is.na(vl_tags) & vl_tags == tg)
          if (length(mm) > 0L) lbl <- names(val_labs)[mm[1]]
        }
        source_disp_with_lbl <- if (!is.na(lbl) && nzchar(lbl)) {
          sprintf('%s "%s"', source_disp, lbl)
        } else source_disp
        display_entries <- c(display_entries,
                             sprintf("%s -> %s",
                                     source_disp_with_lbl,
                                     as.character(code)))
      }
      converted_vars         <- c(converted_vars, vname)
      converted_info[[vname]] <- list(display = display_entries)

    } else if (to == "stata") {

      if (info$representation == "stata") {
        skipped_already <- c(skipped_already, vname)
        next
      }

      x_num <- suppressWarnings(as.numeric(unclass(col)))
      declared_codes <- info$codes$numeric
      declared_codes <- declared_codes[!is.na(declared_codes)]

      # Q6 (Session 29 design lock): SPSS->Stata mapping is ordering-based,
      # not convention-based. Sort the column's own declared codes by
      # absolute value descending, with more-negative-first as the tie-
      # breaker. Then map sorted_codes[1] -> .a, sorted_codes[2] -> .b,
      # etc. The convention codes are NOT consulted for this direction;
      # they only govern the reverse (Stata->SPSS) direction.
      ordering           <- order(-abs(declared_codes), declared_codes)
      sorted_codes       <- declared_codes[ordering]
      column_tag_letters <- letters[seq_along(sorted_codes)]
      column_tag_for_code <- stats::setNames(column_tag_letters,
                                             as.character(sorted_codes))

      new_col   <- as.numeric(x_num)
      used_tags <- character(0)
      for (code in sorted_codes) {
        tag_letter <- column_tag_for_code[[as.character(code)]]
        pos        <- which(!is.na(x_num) & x_num == code)
        new_col[pos] <- haven::tagged_na(tag_letter)
        used_tags <- c(used_tags, tag_letter)
      }

      val_labs     <- labelled::val_labels(col)
      new_val_labs <- val_labs
      if (!is.null(new_val_labs) && length(new_val_labs) > 0L) {
        for (i in seq_along(new_val_labs)) {
          v <- unname(new_val_labs[i])
          # Gate on declared_codes — val_labs entries pointing at codes
          # that aren't formally declared are real-data labels and must
          # stay as numeric entries. Otherwise a val_lab like "Don't know"
          # = -98 on a column with na_values = c(-99) would be incorrectly
          # converted to a tagged-NA marker, breaking the labeling for
          # real -98 cells in the data.
          if (!is.na(v) && v %in% declared_codes) {
            new_val_labs[i] <- haven::tagged_na(
              column_tag_for_code[[as.character(v)]])
          }
        }
      }

      data[[vname]] <- haven::labelled(
        x      = new_col,
        labels = new_val_labs,
        label  = attr(col, "label", exact = TRUE)
      )

      # Build display entries — source code -> destination tag, with the
      # label shown on the source side (the label survives unchanged on
      # the destination, so showing it once on the source is enough). The
      # entries are emitted in sorted_codes order (largest |code| first
      # per Q6), so the user reads ".a came from the largest |code|" left
      # to right.
      display_entries <- character(0)
      for (i in seq_along(sorted_codes)) {
        code <- sorted_codes[i]
        tg   <- column_tag_letters[i]
        lbl  <- NA_character_
        if (!is.null(val_labs) && length(val_labs) > 0L) {
          mm <- which(unname(val_labs) == code & !is.na(unname(val_labs)))
          if (length(mm) > 0L) lbl <- names(val_labs)[mm[1]]
        }
        source_disp <- if (!is.na(lbl) && nzchar(lbl)) {
          sprintf('%s "%s"', as.character(code), lbl)
        } else as.character(code)
        display_entries <- c(display_entries,
                             sprintf("%s -> .%s", source_disp, tg))
      }
      converted_vars         <- c(converted_vars, vname)
      converted_info[[vname]] <- list(display = display_entries)
    }
  }

  # --- Build notification (Q4 five-section format) --------------------------
  if (isTRUE(udm.notice)) {

    n_converted     <- length(converted_vars)
    n_already       <- length(skipped_already)
    n_pattern_a     <- length(pattern_a)
    n_skipped_nodes <- length(skipped_no_udms)

    # Empty-case detection. Two sub-cases need distinct messages:
    #   genuinely_empty       — no UDMs anywhere, no Pattern A. The truly
    #                           "nothing to look at" case.
    #   all_already_in_target — UDM-bearing columns exist but all already
    #                           match the requested target format. Whole-
    #                           DF flavour gets a single-line summary
    #                           since enumerating every already-in-target
    #                           column would be noisy.
    genuinely_empty       <- (length(info_list) == 0L && n_pattern_a == 0L)
    all_already_in_target <- (n_converted == 0L && n_pattern_a == 0L &&
                               n_skipped_nodes == 0L && n_already > 0L)

    if (genuinely_empty) {
      if (user_specified) {
        message("No user-defined missing values found in: ",
                paste(target_vars, collapse = ", "), ".")
      } else {
        message("No user-defined missing values found in '", data_name, "'.")
      }
      return(invisible(data))
    }

    if (all_already_in_target && !user_specified) {
      message(sprintf(
        "All UDM-bearing variables in '%s' are already in %s-form representation.",
        data_name, to))
      return(invisible(data))
    }

    msg_lines <- character(0)

    # Header + Converted: section
    if (n_converted > 0L) {
      header_verb <- switch(
        to,
        baseR = "Stripped declarations of user-defined missing values (UDMs) from",
        spss  = "Converted to SPSS-style missing values in",
        stata = "Converted to Stata-style missing values in"
      )
      msg_lines <- c(msg_lines, paste0(
        header_verb, " ", n_converted, " variable",
        if (n_converted == 1L) "" else "s", ":"))

      max_name_len <- max(nchar(converted_vars))
      for (vname in converted_vars) {
        ci <- converted_info[[vname]]
        msg_lines <- c(msg_lines, paste0(
          "  ", format(vname, width = max_name_len),
          "  (", paste(ci$display, collapse = ", "), ")"))
      }
    }

    # Skipped — already in target format (user_specified only — for whole-DF
    # the all_already_in_target short-circuit above already covered the case
    # where everything was already in target; for whole-DF with some
    # converted and some already in target, the already-in-target columns
    # are intentionally not enumerated to avoid noise).
    if (n_already > 0L && user_specified) {
      if (length(msg_lines) > 0L) msg_lines <- c(msg_lines, "")
      msg_lines <- c(msg_lines,
                     sprintf("Skipped (already in %s-form representation):", to),
                     paste0("  ", paste(skipped_already, collapse = ", ")))
    }

    # Skipped — no UDMs found (user_specified only by construction —
    # skipped_no_udms is only populated when user_specified is TRUE)
    if (n_skipped_nodes > 0L) {
      if (length(msg_lines) > 0L) msg_lines <- c(msg_lines, "")
      msg_lines <- c(msg_lines,
                     "Skipped (no UDMs found):",
                     paste0("  ", paste(skipped_no_udms, collapse = ", ")))
    }

    # Skipped — value labels suggest missingness (Pattern A)
    if (n_pattern_a > 0L) {
      if (length(msg_lines) > 0L) msg_lines <- c(msg_lines, "")
      msg_lines <- c(msg_lines,
                     "Skipped (value labels suggest missingness but not formally declared):")
      for (vname in names(pattern_a)) {
        entries <- pattern_a[[vname]]
        for (e in entries) {
          msg_lines <- c(msg_lines, sprintf(
            "  %s: %s = \"%s\"",
            vname, as.character(e$value), e$label))
        }
      }
      msg_lines <- c(msg_lines,
                     "",
                     "  To formalise these as UDMs, see jdeclare_udm().",
                     "  To leave them as ordinary data, no action is needed.")
    }

    # Assignment-syntax reminder (only when a conversion actually
    # happened AND the output level isn't "minimal" — the reminder is an
    # instructional aid for SPSS migrants new to R's assignment
    # semantics, displayed on the "standard" and "full" levels but
    # suppressed on "minimal" where users have already opted into
    # less-verbose output).
    if (n_converted > 0L) {
      out_level <- getOption(".jst_output_level", "standard")
      if (out_level != "minimal") {
        if (length(msg_lines) > 0L) msg_lines <- c(msg_lines, "")
        example_call <- .jst_build_jconvert_example(
          data_name = data_name, to = to,
          var_scope = var_scope,
          dot_names = dot_names, vars = vars)
        msg_lines <- c(msg_lines,
                       "Reminder: Changes are retained only when assigning the result back to your data frame,",
                       paste0("e.g., ", example_call))
      }
    }

    message(paste(msg_lines, collapse = "\n"))
  }

  invisible(data)
}


#' Internal: build the assignment-syntax example for jconvert notifications
#'
#' When the rendered call fits within the current terminal width (allowing
#' for the \code{prefix_width}-character "e.g., " prefix the caller will
#' prepend), the function returns a single-line string. When it doesn't,
#' the call is broken across multiple lines, packing args greedily into
#' each line, with continuation lines indented to align with the opening
#' paren of the \code{jconvert(} call.
#'
#' @keywords internal
.jst_build_jconvert_example <- function(data_name, to,
                                        var_scope, dot_names, vars,
                                        prefix_width = 6L) {
  to_arg <- paste0("to = \"", to, "\"")

  if (var_scope == "dots") {
    args <- c(data_name, to_arg, dot_names)
  } else if (var_scope == "vars") {
    vars_str <- paste0("vars = c(\"",
                       paste(vars, collapse = "\", \""),
                       "\")")
    args <- c(data_name, to_arg, vars_str)
  } else {
    args <- c(data_name, to_arg)
  }

  header <- paste0(data_name, " <- jconvert(")
  width  <- getOption("width", 80L)

  # Single-line case: the call (with the caller's "e.g., " prefix
  # accounted for) fits within terminal width.
  single <- paste0(header, paste(args, collapse = ", "), ")")
  if (prefix_width + nchar(single) <= width) {
    return(single)
  }

  # Multi-line wrap. Continuation lines align with the opening paren of
  # the jconvert() call on the first line.
  cont_indent <- strrep(" ", prefix_width + nchar(header))

  # Each token = one arg with its trailing punctuation ("arg," or "arg)").
  tokens <- vapply(seq_along(args), function(i) {
    paste0(args[i], if (i < length(args)) "," else ")")
  }, character(1))

  out_lines <- character(0)
  current   <- header
  on_first  <- TRUE   # first line gets the "e.g., " prefix width
  fresh     <- TRUE   # current line has no args yet (just header/indent)

  for (tok in tokens) {
    sep  <- if (fresh) "" else " "
    test <- paste0(current, sep, tok)
    eff  <- if (on_first) prefix_width + nchar(test) else nchar(test)

    if (eff <= width || fresh) {
      # Fits, or the line has no args yet — accept either way (a token too
      # wide for an otherwise-empty line still has to go somewhere).
      current <- test
      fresh   <- FALSE
    } else {
      # Doesn't fit; flush current line and start a new continuation line.
      out_lines <- c(out_lines, current)
      current   <- paste0(cont_indent, tok)
      on_first  <- FALSE
      fresh     <- FALSE
    }
  }

  out_lines <- c(out_lines, current)
  paste(out_lines, collapse = "\n")
}

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
#' By default, \code{jload()} looks for the file in a \code{Data/} (or
#' \code{data/}) subfolder of the working directory first, then the
#' working directory itself. If a full file path is provided, it is used
#' directly.
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
#'   the loaded data frame to set it as the default for JeffsStatTools
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
#' @param preserve.udm Logical. For SPSS \code{.sav} files only. If
#'   \code{TRUE} (default), user-defined missing-value (UDM) codes such as
#'   -99 are preserved as their original numeric values in the data frame,
#'   with metadata attached so the package's analysis functions still treat
#'   them as missing. If \code{FALSE}, UDM codes are converted to plain
#'   \code{NA} on import and the metadata is stripped (matching haven's
#'   default \code{user_na = FALSE} behavior). Has no effect on non-SPSS
#'   formats. Corresponds to haven's \code{user_na} argument with the same
#'   semantics when set to \code{TRUE}.
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
#'     and exists; (b) during the transition window following the May
#'     2026 redesign, any legacy \code{Data/} or \code{data/} folder in
#'     the working directory (compatibility with earlier versions);
#'     (c) the working directory.
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
#' jload("mydata.sav")
#' jload("mydata.sav", use = TRUE)
#' jload("mydata.sav", name = "MySurvey")
#'
#' # Stata
#' jload("mydata.dta")
#'
#' # SAS
#' jload("mydata.sas7bdat")
#' jload("mydata.xpt")
#'
#' # Excel
#' jload("mydata.xlsx")
#' jload("mydata.xlsx", sheet = "Wave2")
#' jload("mydata.xlsx", sheet = 2)
#'
#' # CSV and R native
#' jload("mydata.csv")
#' jload("mydata.rds")
#'
#' # Extension omitted — jload searches for a matching file automatically
#' jload("mydata")
#'
#' # Full file path
#' jload("C:/Projects/Data/mydata.dta")
#'
#' # Quiet load (e.g. in a .Rprofile or startup script): suppresses the
#' # informational messages while still loading. Errors and warnings still show.
#' jload("mydata.rds", name = "MyData", quiet = TRUE)
#' }
#'
#' @seealso \code{\link{JeffsStatTools}} for the package overview,
#'   workflow conventions, and complete function listing.
#'
#' @export
#' @param quiet Logical; default FALSE. When TRUE, suppresses jload()'s
#'   informational messages (file found, load summary, default-data note,
#'   and the UDM narrative, overriding udm.notice). Errors, warnings, the
#'   multi-sheet advisory, and the overwrite prompt are still shown.
jload <- function(file, name = NULL, use = FALSE, overwrite = FALSE,
                  check.missing = TRUE, sheet = NULL,
                  preserve.udm = TRUE, udm.notice = NULL, quiet = FALSE) {

  # quiet = TRUE mutes informational messages (file found, load summary,
  # default-data note, and the UDM narrative). Errors, warnings, the
  # multi-sheet advisory, and the overwrite prompt are never muted.
  say <- function(...) if (!quiet) message(...)

  # --- Validate file argument ------------------------------------------------
  if (missing(file) || !is.character(file) || length(file) != 1 ||
      nchar(trimws(file)) == 0) {
    stop("Provide a filename, e.g. jload(\"mydata.sav\")", call. = FALSE)
  }

  # --- Determine if file has a directory component ---------------------------
  has_dir <- grepl("/", file)

  # --- Determine file extension ----------------------------------------------
  ext <- tolower(tools::file_ext(file))

  # --- Supported extensions --------------------------------------------------
  supported_ext <- c("sav", "dta", "csv", "rds", "sas7bdat", "xpt",
                     "xlsx", "xls", "rdata", "rda")

  # --- Handle .RData/.rda redirect -------------------------------------------
  if (ext %in% c("rdata", "rda")) {
    stop(
      ".RData files contain multiple named objects. ",
      "Use load(\"", file, "\") to load these directly.",
      call. = FALSE
    )
  }

  # --- No extension: search for matching files -------------------------------
  if (ext == "") {
    found <- .jst_search_no_extension(file, has_dir)
    if (length(found) == 0) {
      search_dirs <- if (has_dir) character(0) else .jst_get_search_dirs()
      stop(
        "No file found matching '", file, "' with any supported extension ",
        "(.sav, .dta, .csv, .rds, .sas7bdat, .xpt, .xlsx, .xls).\n",
        if (length(search_dirs) > 0)
          paste0("Searched in: ",
                 paste(ifelse(search_dirs == ".", "working directory",
                              paste0(search_dirs, " folder")),
                       collapse = " and "),
                 .jst_missing_data_dir_note())
        else
          paste0("Searched in: ", .jst_norm_path(dirname(file))),
        call. = FALSE
      )
    }
    if (length(found) == 1) {
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
      stop(msg, call. = FALSE)
    }
  }

  # --- Validate extension ----------------------------------------------------
  if (!ext %in% supported_ext) {
    stop(
      "Unsupported file extension '.", ext, "'. Supported formats:\n",
      "  .sav       SPSS\n",
      "  .dta       Stata\n",
      "  .sas7bdat  SAS\n",
      "  .xpt       SAS transport\n",
      "  .xlsx      Excel\n",
      "  .xls       Excel (legacy)\n",
      "  .csv       Comma-separated values\n",
      "  .rds       R native",
      call. = FALSE
    )
  }

  # --- Resolve file path -----------------------------------------------------
  if (has_dir) {
    # Full or relative path provided — use directly
    resolved_path <- file
    if (!file.exists(resolved_path)) {
      stop("File not found: ", .jst_norm_path(resolved_path), call. = FALSE)
    }
  } else {
    # Bare filename — search Data/, data/, then working directory
    resolved_path <- .jst_find_file(file)
  }

  # --- Determine object name -------------------------------------------------
  if (!is.null(name)) {
    obj_name <- name
  } else {
    obj_name <- tools::file_path_sans_ext(basename(file))
  }

  # Check for leading digit
  if (grepl("^[0-9]", obj_name)) {
    stop(
      "The filename '", basename(file), "' starts with a number. ",
      "R does not allow variable names to start with a digit.\n",
      "Provide a name, e.g.:\n",
      "  jload(\"", file, "\", name = \"",
      gsub("^[0-9]+", "", obj_name), "\")",
      call. = FALSE
    )
  }

  # Make syntactically valid (replace spaces, hyphens, etc.)
  obj_name <- make.names(obj_name)

  # --- Overwrite check -------------------------------------------------------
  target_env <- parent.frame()
  if (exists(obj_name, envir = target_env) && !overwrite) {
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
      warning(
        "'", obj_name, "' already existed and has been replaced.",
        call. = FALSE
      )
    }
  }

  # --- Validate sheet argument for non-Excel files ----------------------------
  if (!is.null(sheet) && !ext %in% c("xlsx", "xls")) {
    warning(
      "The sheet argument is only used for Excel files (.xlsx, .xls). ",
      "Ignoring for .", ext, " file.",
      call. = FALSE
    )
  }

  # --- Read the file ---------------------------------------------------------
  # For .sav: always pass user_na = TRUE so UDM metadata is available for
  # the .jst_handle_udms step below, regardless of preserve.udm. The package
  # then decides whether to preserve or convert based on preserve.udm.
  df <- switch(ext,
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
      stop(
        "The .rds file does not contain a data frame. ",
        "jload() only loads data frames.",
        call. = FALSE
      )
    }
    df <- as.data.frame(df)
  }

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
  say(
    "Loaded ", obj_name,
    " (", .jst_format_label(ext), "; ",
    format(nrow(df), big.mark = ","), " cases, ",
    ncol(df), " variables)"
  )

  # --- Set as default with juse() if requested -------------------------------
  if (use) {
    options(.jst_default_data = obj_name)
    say("Default data frame set to: ", obj_name)
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
      message(.jst_format_udm_narrative(udm_info, preserve.udm, data_name = obj_name))
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
    .jst_scan_coded_missing(df, obj_name, ext, scan_udm = (length(udm_info) == 0))
  }

  invisible(df)
}


# -- jload internal helpers ---------------------------------------------------

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
         xpt      = "SAS transport format",
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
#' formal declaration) is NOT in scope here — that pattern is handled
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
      sprintf("%d variables have user-defined missing values:\n", n_vars),
      list_str,
      "\nThese codes are excluded as missing in jstats analyses. ",
      "For better base R compatibility, convert them:\n",
      sprintf("  jconvert(%s, to = \"stata\")  \u2014 retains missing-value codes, ", call_name),
      "base R compatible (recommended)\n",
      sprintf("  jconvert(%s, to = \"baseR\")  \u2014 converts to plain NA and ", call_name),
      "removes missing-value codes"
    )
  } else {
    paste0(
      sprintf("%d variables had user-defined missing values, ", n_vars),
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
    # Bare filename — search Data/, data/, working directory
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
#' - Otherwise, during the transition window (until 2026-06 cleanup),
#'   any legacy \code{Data/} or \code{data/} folder in the working
#'   directory is searched. This is backwards-compat for users with
#'   folders created by earlier versions where jsave auto-created them.
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
  } else {
    # >>> TRANSITION BLOCK — remove after 2026-06 course-end cleanup <<<
    # Backwards-compat for users with Data/ or data/ folders created by
    # earlier versions where jsave auto-created them. Once removed, the
    # NULL-default case adds nothing to dirs and the working directory
    # alone is searched.
    has_Data <- dir.exists("Data")
    has_data <- dir.exists("data")
    same_folder <- has_Data && has_data &&
                   identical(normalizePath("Data", mustWork = FALSE),
                             normalizePath("data", mustWork = FALSE))
    if (has_Data) dirs <- c(dirs, "Data")
    if (has_data && !same_folder) dirs <- c(dirs, "data")
    # >>> END TRANSITION BLOCK <<<
  }

  # Working directory is always searched last, matching base-R conventions.
  dirs <- c(dirs, ".")
  dirs
}

#' Internal: find a bare filename in Data/, data/, or working directory
#' @keywords internal
.jst_find_file <- function(filename) {
  search_dirs <- .jst_get_search_dirs()
  for (d in search_dirs) {
    candidate <- file.path(d, filename)
    if (file.exists(candidate)) {
      if (d != ".") {
        message("Reading from ", .jst_norm_path(d))
      }
      return(candidate)
    }
  }
  stop(
    "File '", filename, "' not found.\n",
    "Searched in: ",
    paste(ifelse(search_dirs == ".", "working directory",
                 paste0(search_dirs, " folder")),
          collapse = " and "),
    .jst_missing_data_dir_note(), "\n",
    "Check that the filename and extension are correct.",
    call. = FALSE
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
#'   \code{scan_udm = FALSE} produces no UDM-related output — neither
#'   tabular nor flagged-as-suspected.
#'
#' @keywords internal
.jst_scan_coded_missing <- function(df, obj_name, ext, scan_udm = TRUE) {

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
              source = "user-defined missing value"
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
                source = "user-defined missing value"
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
        # those same values as "suspected — not formally defined".
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
            source = "label-only \u2014 not formally declared"
          )
        } else {
          findings[[length(findings) + 1]] <- list(
            var = vname, value = sv, count = n_cases,
            source = "suspected \u2014 not formally defined"
          )
        }
      }
    }
  }

  # --- Report findings -------------------------------------------------------
  if (length(findings) > 0) {

    # Determine which sources are present so we can pick the heading,
    # render only the relevant legend lines, and fix the per-variable
    # jrecode example.
    sources_present <- unique(vapply(findings, function(f) f$source, character(1)))
    has_udm        <- "user-defined missing value"            %in% sources_present
    has_label_only <- "label-only \u2014 not formally declared" %in% sources_present
    has_heur       <- "suspected \u2014 not formally defined"   %in% sources_present

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
    # sources on the same variable (rare — e.g. a UDM-bearing variable
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
    # padded so the [source] brackets align vertically across rows.
    # Label-only findings inline the label after the value, like
    #   -99 "Refused" (3), -98 "Don't know" (3)
    # Other source types use the compact form without labels.
    vc_parts <- character(n_show)
    for (i in seq_len(n_show)) {
      g <- groups[[group_keys[i]]]
      if (g$source == "label-only \u2014 not formally declared") {
        vc_strs <- sprintf('%g "%s" (%d)', g$values, g$labels, g$counts)
      } else {
        vc_strs <- sprintf("%g (%d)", g$values, g$counts)
      }
      vc_parts[i] <- paste(vc_strs, collapse = ", ")
    }
    max_vc_len <- max(nchar(vc_parts))

    for (i in seq_len(n_show)) {
      g <- groups[[group_keys[i]]]
      cat(sprintf("  %-*s  %-*s  [%s]\n",
                  max_name_len, paste0(g$var, ":"),
                  max_vc_len, vc_parts[i],
                  g$source))
    }
    if (n_groups > max_report) {
      # When the hidden rows span multiple source types, break down the
      # counts so the reader can tell what kinds of findings are not
      # visible. When all hidden rows share one source type, the legend
      # already covers the interpretation and the simple count suffices.
      hidden_sources <- vapply(groups[group_keys[(max_report + 1):n_groups]],
                               function(g) g$source, character(1))
      hidden_udm        <- sum(hidden_sources == "user-defined missing value")
      hidden_label_only <- sum(hidden_sources == "label-only \u2014 not formally declared")
      hidden_heur       <- sum(hidden_sources == "suspected \u2014 not formally defined")

      mixed <- (hidden_udm > 0) + (hidden_label_only > 0) + (hidden_heur > 0) > 1
      if (mixed) {
        cat(sprintf("  ... and %d more:\n", n_groups - max_report))
        if (hidden_udm > 0) {
          cat(sprintf("    %d with [user-defined missing value]\n", hidden_udm))
        }
        if (hidden_label_only > 0) {
          cat(sprintf("    %d with [label-only \u2014 not formally declared]\n",
                      hidden_label_only))
        }
        if (hidden_heur > 0) {
          cat(sprintf("    %d with [suspected \u2014 not formally defined]\n",
                      hidden_heur))
        }
      } else {
        cat(sprintf("  ... and %d more.\n", n_groups - max_report))
      }
    }

    cat("\n")
    if (has_udm) {
      cat("[user-defined missing value]: already treated as NA by JeffsStatTools\n")
      cat("  analysis functions. Conversion to plain NA is optional --- useful\n")
      cat("  if you'll use this dataset with base R or non-package functions where\n")
      cat("  the numeric values may be misinterpreted as real.\n")
    }
    if (has_label_only) {
      cat("[label-only \u2014 not formally declared]: not automatically treated as NA, but\n")
      cat("  value labels look UDM-like (often after .dta or .xpt round-trip, which\n")
      cat("  preserve labels but not the formal declaration). Convert if these are\n")
      cat("  missing-value codes; leave as-is if real.\n")
    }
    if (has_heur) {
      cat("[suspected \u2014 not formally defined]: not automatically treated as NA.\n")
      cat("  Convert if these are missing-value codes; leave as-is if real.\n")
    }

    # Build a per-variable jrecode example. Preference order:
    # UDM > label-only > suspected. Both UDM and label-only typically
    # have multiple coded values (-99, -98, ...) which makes for a
    # more informative map; pure heuristic findings often have just
    # one code, so they fall through to the first finding.
    if (has_udm) {
      ex_var <- findings[[which(vapply(findings,
                                       function(f) f$source == "user-defined missing value",
                                       logical(1)))[1]]]$var
    } else if (has_label_only) {
      ex_var <- findings[[which(vapply(findings,
                                       function(f) f$source == "label-only \u2014 not formally declared",
                                       logical(1)))[1]]]$var
    } else {
      ex_var <- findings[[1]]$var
    }
    ex_codes <- sort(unique(vapply(findings,
                                   function(f) if (f$var == ex_var) f$value else NA_real_,
                                   numeric(1))))
    ex_codes <- ex_codes[!is.na(ex_codes)]
    map_str  <- paste0(paste0(format(ex_codes), "=NA"), collapse = "; ")
    map_str  <- paste0(map_str, "; else=copy")

    cat("\nTo convert one variable:\n")
    cat(sprintf("  %s$%s <- jrecode(%s, %s,\n    map = \"%s\")\n",
                obj_name, ex_var, obj_name, ex_var, map_str))

    # The bulk-strip option only applies to .sav loads, where preserve.udm
    # at jload time can convert all UDMs in one step. Skipped for .rds and
    # other formats where the data is already in R without that pathway.
    if (has_udm && ext == "sav") {
      cat("\nFor .sav files with many UDMs, jload(file, preserve.udm = FALSE)\n")
      cat("strips them all at load time.\n")
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
#' Produces the error message used by \code{jsave()} when tagged-NA
#' values are encountered on a \code{.xpt} write. The .xpt format
#' has no representation for tagged NAs; haven would otherwise emit
#' a low-level error (\dQuote{Failed to insert value...}) and leave
#' a partial file on disk. The user is directed to drop via
#' \code{jconvert(to = "baseR")} or to save as \code{.dta} (which
#' SAS PROC IMPORT can read) to preserve the codes. Verbosity is
#' controlled by the active \code{joutput()} level.
#'
#' @param vars Character vector of variable names containing
#'   tagged NAs.
#' @param data_name Character. Name of the data frame argument in
#'   the user's call to \code{jsave()}, used to construct the
#'   suggested \code{jconvert()} call.
#'
#' @return Character scalar suitable for passing to \code{stop()}.
#'
#' @keywords internal
.jst_jsave_xpt_error_msg <- function(vars, data_name) {

  output_level <- getOption(".jst_output_level", "standard")
  n            <- length(vars)
  is_sg        <- (n == 1)
  noun         <- if (is_sg) "variable" else "variables"
  verb_contain <- if (is_sg) "contains" else "contain"

  # --- Minimal tier -------------------------------------------------------
  if (identical(output_level, "minimal")) {
    return(paste0(
      n, " ", noun, " ", verb_contain,
      " missing-value codes, incompatible with the .xpt format. ",
      "Run ", data_name, " <- jconvert(", data_name, ", to = \"baseR\") ",
      "to drop them, or save as Stata format (.dta) to preserve them."
    ))
  }

  # --- Standard / full tier ----------------------------------------------
  paste0(
    n, " ", noun, " ", verb_contain,
    " missing-value codes, incompatible with the .xpt format:\n",
    "  ", .jst_format_var_list(vars), "\n\n",
    "To save as .xpt, drop these by running:\n",
    "  ", data_name, " <- jconvert(", data_name, ", to = \"baseR\")\n\n",
    "To preserve these codes, save as Stata format (.dta) instead, ",
    "which SAS PROC IMPORT can read."
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
#' was converted — in cells, in \code{val_labels}, or both. Columns
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

#' Save a data frame to a file
#'
#' @description
#' \code{jsave()} writes a data frame to a file. Supports SPSS (\code{.sav}),
#' Stata (\code{.dta}), SAS transport (\code{.xpt}), Excel (\code{.xlsx}),
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
#'     directory. During the transition window following the May 2026
#'     redesign, an existing \code{Data/} or \code{data/} folder in the
#'     working directory will still be used if present, preserving
#'     compatibility with earlier versions of the package.
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
#' \dontrun{
#' # The file extension determines the format ---
#' # the same data frame can be saved in any supported format
#' jsave(MyData, "mydata.sav")         # SPSS
#' jsave(MyData, "mydata.dta")         # Stata
#' jsave(MyData, "mydata.xpt")         # SAS transport
#' jsave(MyData, "mydata.xlsx")        # Excel
#' jsave(MyData, "mydata.csv")         # CSV
#' jsave(MyData, "mydata.rds")         # R native
#'
#' # Using juse() default
#' jsave(, "mydata.sav")
#'
#' # Full file path
#' jsave(MyData, "C:/Output/mydata.sav")
#' }
#'
#' @seealso \code{\link{JeffsStatTools}} for the package overview,
#'   workflow conventions, and complete function listing.
#'
#' @export
jsave <- function(data, file, overwrite = FALSE) {

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
      stop("'", as.character(data_sub), "' not found. ",
           "Provide a data frame, e.g. jsave(MyData, \"mydata.sav\")",
           call. = FALSE)
    }

    # Cases 2-4: evaluate the first argument and inspect the value
    eval_result <- tryCatch(
      list(value = eval(data_sub, envir = parent.frame()), failed = FALSE),
      error = function(e) list(value = NULL, failed = TRUE)
    )

    if (eval_result$failed) {
      data_str <- paste(deparse(data_sub), collapse = "")
      stop("'", data_str, "' could not be evaluated. ",
           "Provide a data frame, e.g. jsave(MyData, \"mydata.sav\")",
           call. = FALSE)
    }

    val <- eval_result$value
    if (is.null(val)) {
      data_str <- paste(deparse(data_sub), collapse = "")
      stop("'", data_str, "' is NULL. ",
           "Provide a data frame, e.g. jsave(MyData, \"mydata.sav\")",
           call. = FALSE)
    }
    if (!is.data.frame(val) && !is.character(val)) {
      data_str   <- paste(deparse(data_sub), collapse = "")
      class_desc <- paste(class(val), collapse = "/")
      stop("'", data_str, "' is a ", class_desc, ", not a data frame. ",
           "Provide a data frame, e.g. jsave(MyData, \"mydata.sav\")",
           call. = FALSE)
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
    stop(
      "jsave() saves data frames. '", data_name, "' is ",
      paste0("a ", paste(class(data), collapse = "/"), ", not a data frame."),
      call. = FALSE
    )
  }

  # --- Validate file argument ------------------------------------------------
  if (missing(file) || !is.character(file) || length(file) != 1 ||
      nchar(trimws(file)) == 0) {
    stop(
      "Provide a filename with extension, e.g. jsave(MyData, \"mydata.sav\")\n",
      "Supported formats:\n",
      "  .sav       SPSS\n",
      "  .dta       Stata\n",
      "  .xpt       SAS transport\n",
      "  .xlsx      Excel\n",
      "  .csv       Comma-separated values\n",
      "  .rds       R native",
      call. = FALSE
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
    stop(
      "Unsupported file extension '.", ext, "'. Supported formats for saving:\n",
      "  .sav       SPSS\n",
      "  .dta       Stata\n",
      "  .xpt       SAS transport\n",
      "  .xlsx      Excel\n",
      "  .csv       Comma-separated values\n",
      "  .rds       R native",
      xls_msg,
      call. = FALSE
    )
  }

  # --- Resolve output path ---------------------------------------------------
  has_dir <- grepl("/", file)

  if (has_dir) {
    out_path <- file
    # Ensure directory exists
    out_dir <- dirname(out_path)
    if (!dir.exists(out_dir)) {
      stop("Directory does not exist: ", .jst_norm_path(out_dir), call. = FALSE)
    }
  } else {
    # Bare filename — resolve via data.dir.
    data_dir <- getOption(".jst_options_data_dir",
                          .jst_options_defaults$data.dir)

    if (is.null(data_dir)) {
      # data.dir unset.
      #
      # >>> TRANSITION BLOCK — remove after 2026-06 course-end cleanup <<<
      # Backwards-compat: write to an existing Data/ or data/ folder if
      # present (preserves prior behavior for users with folders
      # auto-created by earlier versions). No auto-create — the
      # post-cleanup behavior is "write to working directory" and we
      # apply that whenever the legacy folders don't exist.
      if (dir.exists("Data")) {
        out_path <- file.path("Data", file)
      } else if (dir.exists("data")) {
        out_path <- file.path("data", file)
      } else {
        out_path <- file
      }
      # >>> END TRANSITION BLOCK (post-cleanup: out_path <- file) <<<
    } else {
      # Explicit data.dir — write to that folder, creating it if needed.
      if (!dir.exists(data_dir)) {
        dir.create(data_dir)
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
      stop(
        "File '", .jst_norm_path(out_path), "' already exists. ",
        "Use overwrite = TRUE to replace it.",
        call. = FALSE
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
  #       .sav/.xpt, SPSS-style UDMs for .dta. haven would silently drop these
  #       (or, for .xpt, error mid-write and leave a partial file).
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
      tagged_vars <- .jst_has_tagged_na(data)
      if (length(tagged_vars) > 0) {
        sections[[length(sections) + 1L]] <-
          .jst_jsave_xpt_error_msg(tagged_vars, data_name)
      }
    }

    # Report all blocking issues at once (single message when only one fired).
    if (length(sections) > 0) {
      stop(.jst_jsave_combined_error_msg(sections, data_name, ext),
           call. = FALSE)
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

  tryCatch({
    switch(ext,
           sav  = haven::write_sav(data, temp_path),
           dta  = haven::write_dta(data, temp_path, version = 14),
           xpt  = haven::write_xpt(data, temp_path),
           xlsx = writexl::write_xlsx(data, temp_path),
           csv  = utils::write.csv(data, temp_path, row.names = FALSE),
           rds  = saveRDS(data, temp_path)
    )
  }, error = function(e) {
    unlink(temp_path)
    stop(conditionMessage(e), call. = FALSE)
  })

  # Move the completed temp into place. On Windows file.rename() fails if
  # the destination exists, so explicitly remove first when overwriting.
  if (file.exists(out_path)) {
    if (!file.remove(out_path)) {
      unlink(temp_path)
      stop("Could not remove existing target file: ",
           .jst_norm_path(out_path),
           call. = FALSE)
    }
  }
  if (!file.rename(temp_path, out_path)) {
    unlink(temp_path)
    stop("Could not finalize save: rename of temporary file to ",
         .jst_norm_path(out_path), " failed.",
         call. = FALSE)
  }

  # Format-specific notes (emitted after a confirmed successful write)
  if (ext == "xlsx") {
    message("Note: Excel format does not preserve variable or value labels.")
  } else if (ext == "csv") {
    message("Note: CSV format does not preserve variable or value labels.")
  }

  # --- Confirmation message --------------------------------------------------
  message(
    "Saved ", data_name, " to ", .jst_norm_path(out_path),
    " (", .jst_format_label(ext), "; ",
    format(nrow(data), big.mark = ","), " cases, ",
    ncol(data), " variables)"
  )

  invisible(NULL)
}


# =============================================================================
#  PLOTTING
# =============================================================================

# -- jplot ---------------------------------------------------------------------

#' Visualise jst_* result objects or plot variables directly from a data frame
#'
#' Unified plotting function. Can be called in three ways:
#'
#' \strong{Result-object form:} Pass a result object returned by one of the
#' package's analysis functions. Produces appropriate plots for each class of
#' result (see valid plot names below).
#'
#' \strong{Formula form} (for plots that distinguish DV from IV): Pass a
#' formula as the first argument, followed optionally by a data frame. Used
#' for scatterplots and boxplots, consistent with the formula syntax of
#' \code{jlm()}, \code{jaov()}, and \code{jt()}. The DV on the left of
#' \code{~} goes on the y-axis; the IV on the right goes on the x-axis. Only
#' single-IV formulas are supported here; for multi-IV models, fit with
#' \code{jlm()} and pass the result to \code{jplot()}.
#'
#' \strong{Variable-list form} (for distributions and counts): Pass a data
#' frame followed by one or two unquoted variable names. Used for histograms
#' (1 numeric), bar charts (1 categorical), and grouped bar charts (2
#' categorical). Calls that would otherwise auto-detect to a scatter or
#' boxplot produce a helpful error directing you to the formula form.
#'
#' Supports pipeline integration (\code{jsubset}, \code{jcomplete}, per-call
#' \code{subset}), grouping via \code{by = }, and regression lines with
#' equation/R-squared/band annotations.
#'
#' Valid plot names by class (for the result-object form):
#' \itemize{
#'   \item \code{jst_lm}: \code{fit}, \code{predicted}, \code{effects},
#'     \code{coef}, \code{vif}, \code{residuals}, \code{qq},
#'     \code{scale}, \code{cooks}, \code{leverage}
#'   \item \code{jst_logistic}: \code{probability}, \code{roc},
#'     \code{calibration}, \code{binned}, \code{cooks}, \code{leverage},
#'     \code{coef}, \code{vif}
#'   \item \code{jst_ttest}, \code{jst_anova}: \code{box}
#'   \item \code{jst_corr}: \code{heatmap}, \code{scatter} (scatter requires
#'     exactly 2 variables in the correlation)
#'   \item \code{jst_crosstab}: \code{bar}
#' }
#'
#' The shortcut keyword \code{core} (default) produces a curated default
#' set for the class; \code{all} produces every plot the class supports.
#'
#' Valid plot types for the data-first form: \code{histogram}, \code{bar},
#' \code{scatter}, \code{box}, \code{grouped_bar}.
#'
#' Valid \code{line} values: \code{FALSE} (default), \code{TRUE} (alias for
#' \code{lm}), \code{lm}, \code{loess}, \code{connect}.
#'
#' Valid \code{band} values: \code{ci} (default confidence band around the
#' regression line, flares at the ends), \code{pi} (prediction interval for
#' individual observations, wider), \code{see} (constant-width +/- t*SEE
#' band illustrating the homoskedasticity assumption), \code{none} (no band).
#'
#' @param x A result object from one of the package's analysis functions
#'   (result-object form), or a data frame (data-first form).
#' @param which Character vector. \code{core} (default), \code{all}, or
#'   one or more specific plot names valid for the object's class.
#'   (Result-object form only.)
#' @param ... Additional arguments: for the result-object form these are
#'   passed to class-specific methods; for the data-first form these are
#'   unquoted variable names (1 or 2).
#' @param focal Unquoted name of the independent variable to place on the
#'   x-axis for \code{jst_lm} / \code{jst_logistic} \code{fit} and
#'   \code{probability} plots. Defaults to the first IV in the model.
#' @param at Character string or named list specifying where non-focal
#'   independent variables are held when drawing the fitted line in
#'   \code{jst_lm} / \code{jst_logistic} methods. One of \code{zero}
#'   (default), \code{mean}, \code{mixed} (categorical at 0, interval
#'   at mean), or a named list \code{list(Var1 = value, ...)}.
#' @param equation Logical. If TRUE (default), displays the equation in the
#'   subtitle for \code{line = "lm"} scatter plots (data-first form) or
#'   \code{jst_lm} \code{fit} plots (result-object form).
#' @param r2 Logical. If TRUE (default), displays R-squared in the subtitle
#'   alongside the equation.
#' @param by Unquoted variable name for group-coloring (data-first form).
#' @param type Character. Plot type override for the data-first form. One
#'   of \code{histogram}, \code{bar}, \code{scatter}, \code{box},
#'   \code{grouped_bar}. If NULL (default), auto-detected from variable
#'   types.
#' @param line Controls a line overlay on data-first scatter plots. One of
#'   \code{FALSE} (default; no line), \code{TRUE} (alias for \code{lm}),
#'   \code{lm}, \code{loess}, \code{connect}.
#' @param band Character. Uncertainty band type for \code{line = "lm"}
#'   scatter plots. One of \code{ci} (default; 95\% confidence band for
#'   the mean, flares at the ends), \code{pi} (95\% prediction interval
#'   for individual observations), \code{see} (constant-width band at
#'   +/- t*SEE; useful for teaching homoskedasticity), \code{none}.
#' @param subset Optional unquoted logical expression to filter cases for
#'   this call only (data-first form).
#' @param labels Logical. If TRUE (default), prints variable labels when
#'   available (data-first form).
#'
#' @return Invisibly, a single \code{ggplot} object if one plot is produced,
#'   or a named list of \code{ggplot} objects if multiple are produced
#'   (result-object form). Invisibly returns the \code{ggplot} object for
#'   the data-first form.
#'
#' @examples
#' \dontrun{
#'   # Result-object form
#'   m <- jlm(TotalCrime ~ Age + Tattoos, SampleData)
#'   jplot(m)                            # core diagnostics + fit plot
#'   jplot(m, which = "coef")            # coefficient forest plot
#'   jplot(m, which = "fit", focal = Age, at = "mean")
#'
#'   # Formula form (scatter and box)
#'   jplot(Tattoos ~ Age, SampleData)                       # scatter
#'   jplot(Tattoos ~ Age, SampleData, line = "lm")          # scatter + regression
#'   jplot(Tattoos ~ Age, SampleData, line = "lm", band = "see")
#'   jplot(Tattoos ~ Age, SampleData, by = Gender, line = "lm")
#'   jplot(Age ~ Gender, SampleData)                        # boxplot
#'
#'   # Variable-list form (distributions and counts)
#'   jplot(SampleData, Age)                     # histogram
#'   jplot(SampleData, Gender)                  # bar chart
#'   jplot(SampleData, Program, Employment)     # grouped bar chart
#' }
#'
#' @seealso \code{\link{JeffsStatTools}} for the package overview,
#'   workflow conventions, and complete function listing.
#'
#' @export
#' @importFrom stats setNames
#' @importFrom utils tail
jplot <- function(x, which = "core", ...) {
  UseMethod("jplot")
}

#' @rdname jplot
#' @export
#' @importFrom rlang .data
jplot.default <- function(x, ..., by = NULL, type = NULL,
                          line = FALSE, equation = TRUE, r2 = TRUE,
                          band = "ci", subset = NULL, labels = NULL) {

  # Capture the call for later argument-inspection (used by the ignored-arg
  # note that fires when, e.g., the user passes line = "lm" to a histogram).
  jplot_call <- match.call()

  # ---------------------------------------------------------------------------
  # Formula-first path: jplot(DV ~ IV, data) for scatter/box where a DV/IV
  # distinction is meaningful.  Detected BEFORE the data-frame branch because
  # `x` in this case is a formula, not a data frame.
  # ---------------------------------------------------------------------------
  if (!missing(x) && inherits(x, "formula")) {
    by_sub <- substitute(by)
    return(.jst_jplot_formula(x, jplot_call, ...,
                              by_expr = by_sub, type = type, line = line,
                              equation = equation, r2 = r2, band = band,
                              subset_expr = substitute(subset),
                              labels = labels,
                              parent_env = parent.frame()))
  }

  # Resolve the first argument: explicit data frame, juse default,
  # or bare-symbol-as-variable-name (leading comma omitted).
  arg1 <- .jst_resolve_first_arg(
    data_sub      = substitute(x),
    data_missing  = missing(x),
    fn_name       = "jplot",
    envir         = parent.frame(),
    accept_vector = FALSE
  )

  # Alias to `data` internally for clarity; the generic uses `x` for S3 consistency
  data              <- arg1$data
  .jst_data_name    <- arg1$name
  .jst_default_used <- arg1$mode %in% c("default", "symbol_with_default")

  if (!is.data.frame(data)) {
    stop("jplot(): the first argument must be a data frame. ",
         "To plot a result object (e.g. from jlm()), pass it as the first ",
         "argument: jplot(my_result).",
         call. = FALSE)
  }

  if (!requireNamespace("ggplot2", quietly = TRUE)) {
    stop("Package 'ggplot2' is required for jplot(). ",
         "Install with: install.packages(\"ggplot2\")", call. = FALSE)
  }

  # Capture variable names
  variables <- rlang::enquos(...)

  # Leading-comma-omitted: prepend the captured symbol to variables list
  if (arg1$mode == "symbol_with_default") {
    extra_quo <- rlang::new_quosure(arg1$first_arg_sub,
                                    env = parent.frame())
    variables <- c(list(extra_quo), variables)
    class(variables) <- "quosures"
  }

  variable_names <- vapply(variables, rlang::quo_name, character(1))
  by_quo         <- rlang::enquo(by)
  has_by         <- !rlang::quo_is_null(by_quo)
  by_name        <- if (has_by) rlang::quo_name(by_quo) else NULL

  n_vars <- length(variable_names)
  if (n_vars == 0) {
    stop("jplot(): no variables specified. Provide one or more variable ",
         "names, e.g. jplot(SampleData, Age, Tattoos).", call. = FALSE)
  }
  if (n_vars > 2) {
    stop("jplot(): only 1 or 2 variables can be plotted at once. ",
         "For more variables, use `by =` to add a grouping variable ",
         "(e.g. jplot(data, x, y, by = Gender)) or call jplot() ",
         "multiple times.", call. = FALSE)
  }

  # Check all variables exist
  check_names <- variable_names
  if (has_by) check_names <- c(check_names, by_name)
  .jst_check_vars(data, check_names, .jst_data_name)

  # Validate band argument
  valid_bands <- c("ci", "pi", "see", "none")
  if (!is.character(band) || length(band) != 1 || !band %in% valid_bands) {
    stop("`band` must be one of: ", paste(sprintf("\"%s\"", valid_bands),
                                          collapse = ", "), ".",
         call. = FALSE)
  }

  # Validate line argument
  if (isTRUE(line)) line <- "lm"
  valid_lines <- c(FALSE, "lm", "loess", "connect")
  if (!identical(line, FALSE) && !(is.character(line) && length(line) == 1 &&
                                   line %in% c("lm", "loess", "connect"))) {
    stop("`line` must be FALSE, TRUE, or one of: ",
         "\"lm\", \"loess\", \"connect\".", call. = FALSE)
  }

  # Apply data pipeline (jcomplete, jsubset, subset)
  subset_expr <- substitute(subset)
  pipeline <- .jst_apply_pipeline(data, .jst_data_name, .jst_default_used,
                                  subset_expr = subset_expr,
                                  envir = parent.frame())
  data <- pipeline$data
  # Pipeline messages are printed below, after the red title

  # Classify variables
  var_types <- vapply(variable_names,
                      function(v) if (.jst_is_categorical(data[[v]], v,
                                                           .jst_data_name))
                                    "categorical" else "numeric",
                      character(1))

  # Auto-detect plot type if not specified
  resolved_type <- type
  if (is.null(resolved_type)) {
    resolved_type <- .jst_auto_plot_type(var_types, n_vars)
  }

  valid_types <- c("histogram", "bar", "scatter", "box", "grouped_bar")
  if (!resolved_type %in% valid_types) {
    stop("Invalid `type` value: \"", resolved_type, "\".\n",
         "Valid types: ", paste(sprintf("\"%s\"", valid_types),
                                 collapse = ", "), ".",
         call. = FALSE)
  }

  # -- Require formula syntax for scatter and box (relationship plots) ------
  # These plots distinguish DV from IV. Requiring formula syntax prevents
  # confusion about which variable goes on which axis and mirrors jlm/jaov.
  if (resolved_type == "scatter") {
    stop("For two-numeric scatterplots, use formula syntax to make the DV ",
         "and IV explicit (consistent with jlm):\n",
         "  jplot(", variable_names[2], " ~ ", variable_names[1],
         ", ", if (!is.null(.jst_data_name)) .jst_data_name else "SampleData",
         if (!identical(line, FALSE)) paste0(", line = \"",
                                             if (isTRUE(line)) "lm" else line,
                                             "\"") else "",
         ")\n",
         "(The DV on the left of ~ goes on the y-axis; the IV on the right ",
         "goes on the x-axis.)",
         call. = FALSE)
  }
  if (resolved_type == "box") {
    # Numeric goes on y, categorical on x — i.e. numeric ~ categorical
    num_var <- variable_names[var_types == "numeric"][1]
    cat_var <- variable_names[var_types == "categorical"][1]
    stop("For boxplots, use formula syntax to make the outcome and grouping ",
         "variable explicit (consistent with jaov):\n",
         "  jplot(", num_var, " ~ ", cat_var, ", ",
         if (!is.null(.jst_data_name)) .jst_data_name else "SampleData", ")\n",
         "(The numeric outcome on the left of ~ goes on the y-axis; the ",
         "categorical grouping variable on the right goes on the x-axis.)",
         call. = FALSE)
  }

  # -- Note about arguments ignored for this plot type ----------------------
  # line/band/equation/r2 apply only to scatter plots with line = "lm".
  # If the user explicitly passed any of these but the resolved plot type
  # doesn't use them, emit a single consolidated yellow note.
  called_args   <- names(jplot_call)
  explicit_args <- called_args[nzchar(called_args)]

  is_scatter_lm <- resolved_type == "scatter" &&
                   (identical(line, "lm") || identical(line, TRUE))

  ignored <- character(0)
  if ("line" %in% explicit_args && resolved_type != "scatter") {
    ignored <- c(ignored, "line")
  }
  if ("band" %in% explicit_args && !is_scatter_lm) {
    ignored <- c(ignored, "band")
  }
  if ("equation" %in% explicit_args && !is_scatter_lm) {
    ignored <- c(ignored, "equation")
  }
  if ("r2" %in% explicit_args && !is_scatter_lm) {
    ignored <- c(ignored, "r2")
  }
  if (length(ignored) > 0) {
    .cat_yellow(paste0(
      "(Note: ", paste(ignored, collapse = ", "),
      " not applicable to ", resolved_type,
      if (resolved_type == "scatter") " without line = \"lm\"" else "",
      " \u2014 ignored)\n"
    ))
  }

  # -- Capture axis labels BEFORE factor conversion strips them ------------
  axis_labels <- stats::setNames(
    vapply(variable_names,
           function(v) .jst_short_label(data[[v]], v),
           character(1)),
    variable_names
  )
  by_label <- if (has_by) .jst_short_label(data[[by_name]], by_name) else NULL

  # -- Red title --------------------------------------------------------------
  plot_title <- .jst_plot_title(resolved_type, variable_names, by_name)
  .cat_red(paste0(plot_title, "\n"))

  # Print pipeline messages (default data frame note, filter/complete status)
  if (.jst_default_used) .jst_default_note(.jst_data_name)
  .jst_print_msgs(pipeline$msgs)

  # Convert haven-labelled categoricals to factors for plotting
  for (v in variable_names) {
    if (haven::is.labelled(data[[v]])) {
      val_labs <- labelled::val_labels(data[[v]])
      if (!is.null(val_labs) && length(val_labs) > 0) {
        data[[v]] <- haven::as_factor(data[[v]])
      } else {
        data[[v]] <- as.numeric(data[[v]])
      }
    }
  }
  if (has_by && haven::is.labelled(data[[by_name]])) {
    val_labs <- labelled::val_labels(data[[by_name]])
    if (!is.null(val_labs) && length(val_labs) > 0) {
      data[[by_name]] <- haven::as_factor(data[[by_name]])
    } else {
      data[[by_name]] <- factor(data[[by_name]])
    }
  } else if (has_by && !is.factor(data[[by_name]])) {
    data[[by_name]] <- factor(data[[by_name]])
  }

  # Print variable labels if requested
  if (.jst_resolve_toggle("var.labels", labels)) {
    .print_var_labels(data, check_names)
  }

  # Dispatch to plot builder
  p <- switch(
    resolved_type,
    histogram   = .jst_build_histogram(data, variable_names[1], by_name,
                                       axis_labels, by_label),
    bar         = .jst_build_bar(data, variable_names[1], by_name,
                                 axis_labels, by_label),
    scatter     = .jst_build_scatter(data, variable_names, by_name,
                                     line, equation, r2, band,
                                     axis_labels, by_label),
    box         = .jst_build_box(data, variable_names, var_types, by_name,
                                 axis_labels, by_label),
    grouped_bar = .jst_build_grouped_bar(data, variable_names,
                                         axis_labels)
  )

  print(p)
  invisible(p)
}


#' Internal helper: handle the formula-first form of jplot
#'
#' Called by \code{jplot.default} when the first argument is a formula.
#' Parses the formula into DV (y-axis) and IV (x-axis), resolves the data
#' frame from the second positional argument or juse default, and dispatches
#' to the scatter or box builder depending on the IV's type.
#'
#' Only single-IV formulas are supported (\code{DV ~ IV}). Multi-IV formulas
#' produce a helpful error pointing to the jlm() + jplot(m) workflow.
#'
#' @keywords internal
.jst_jplot_formula <- function(formula, jplot_call, ..., by_expr, type, line,
                               equation, r2, band, subset_expr, labels,
                               parent_env) {

  # -- Parse formula ---------------------------------------------------------
  formula_vars <- all.vars(formula)
  if (length(formula) < 3) {
    stop("jplot() requires a two-sided formula: DV ~ IV.\n",
         "  Example: jplot(Tattoos ~ Age, SampleData)", call. = FALSE)
  }

  y_name <- all.vars(formula[[2]])
  x_vars <- all.vars(formula[[3]])

  if (length(y_name) != 1) {
    stop("jplot() supports only one variable on the left side of ~.\n",
         "  Example: jplot(Tattoos ~ Age, SampleData)", call. = FALSE)
  }
  if (length(x_vars) > 1) {
    stop("jplot() supports only one independent variable in its formula.\n",
         "For multi-variable regression, fit with jlm() and plot the result:\n",
         "  m <- jlm(", deparse(formula), ", <data>)\n",
         "  jplot(m)",
         call. = FALSE)
  }
  x_name <- x_vars[1]

  # -- Resolve data frame ----------------------------------------------------
  # Second positional argument in ..., or juse default.
  dots <- list(...)
  dot_names <- names(dots)
  if (is.null(dot_names)) dot_names <- rep("", length(dots))
  positional_dots <- dots[!nzchar(dot_names)]

  .jst_default_used <- FALSE
  .jst_data_name    <- NULL
  if (length(positional_dots) >= 1) {
    data <- positional_dots[[1]]
    # Try to extract the original symbol for reporting
    mc_no_name <- jplot_call[-1L]
    mc_positional <- mc_no_name[!nzchar(names(mc_no_name)) |
                                is.null(names(mc_no_name))]
    if (length(mc_positional) >= 2) {
      .jst_data_name <- paste(deparse(mc_positional[[2]]), collapse = "")
    }
    if (length(positional_dots) > 1) {
      stop("jplot(formula, data): only one data argument is expected after ",
           "the formula. Extra positional arguments were supplied.",
           call. = FALSE)
    }
  } else {
    resolved <- .jst_resolve_data(envir = parent_env)
    data <- resolved$data
    .jst_default_used <- TRUE
    .jst_data_name    <- resolved$name
  }

  if (!is.data.frame(data)) {
    stop("jplot(): the data argument after the formula must be a data frame.",
         call. = FALSE)
  }

  # -- Handle by argument ----------------------------------------------------
  # by_expr is the result of substitute(by) from the caller — either NULL
  # (default), a symbol like `Gender`, or a complex expression.
  by_name <- NULL
  has_by  <- !is.null(by_expr) && !identical(by_expr, as.name("NULL"))
  if (has_by) {
    by_name <- paste(deparse(by_expr), collapse = "")
  }

  # -- Validate variables exist ---------------------------------------------
  check_names <- c(y_name, x_name)
  if (has_by) check_names <- c(check_names, by_name)
  .jst_check_vars(data, check_names, .jst_data_name)

  # -- Validate line / band arguments ----------------------------------------
  valid_bands <- c("ci", "pi", "see", "none")
  if (!is.character(band) || length(band) != 1 || !band %in% valid_bands) {
    stop("`band` must be one of: ", paste(sprintf("\"%s\"", valid_bands),
                                          collapse = ", "), ".",
         call. = FALSE)
  }
  if (isTRUE(line)) line <- "lm"
  if (!identical(line, FALSE) && !(is.character(line) && length(line) == 1 &&
                                   line %in% c("lm", "loess", "connect"))) {
    stop("`line` must be FALSE, TRUE, or one of: ",
         "\"lm\", \"loess\", \"connect\".", call. = FALSE)
  }

  if (!requireNamespace("ggplot2", quietly = TRUE)) {
    stop("Package 'ggplot2' is required for jplot(). ",
         "Install with: install.packages(\"ggplot2\")", call. = FALSE)
  }

  # -- Apply pipeline --------------------------------------------------------
  pipeline <- .jst_apply_pipeline(data, .jst_data_name, .jst_default_used,
                                  subset_expr = subset_expr,
                                  envir = parent_env)
  data <- pipeline$data

  # -- Decide plot type from IV's class -------------------------------------
  # Numeric IV -> scatter; categorical IV -> box (numeric DV is required).
  y_is_num <- !.jst_is_categorical(data[[y_name]], y_name, .jst_data_name)
  x_is_cat <-  .jst_is_categorical(data[[x_name]], x_name, .jst_data_name)

  if (!is.null(type)) {
    resolved_type <- type
  } else {
    if (!y_is_num) {
      stop("jplot(): the DV (left of ~) must be numeric. \"", y_name,
           "\" is categorical.", call. = FALSE)
    }
    resolved_type <- if (x_is_cat) "box" else "scatter"
  }

  # Classify both vars for downstream builders
  var_types <- c(
    if (.jst_is_categorical(data[[x_name]], x_name, .jst_data_name))
      "categorical" else "numeric",
    if (.jst_is_categorical(data[[y_name]], y_name, .jst_data_name))
      "categorical" else "numeric"
  )
  # Note: for builders, variable_names is ordered (x, y) for scatter,
  # (x, y) for box (builder detects numeric side via var_types).
  variable_names <- c(x_name, y_name)

  # -- Capture axis labels BEFORE factor conversion -------------------------
  axis_labels <- stats::setNames(
    vapply(variable_names,
           function(v) .jst_short_label(data[[v]], v),
           character(1)),
    variable_names
  )
  by_label <- if (has_by) .jst_short_label(data[[by_name]], by_name) else NULL

  # -- Red title -------------------------------------------------------------
  plot_title <- .jst_plot_title(resolved_type, c(y_name, x_name), by_name)
  # For formula form, write the title as "Scatterplot: Tattoos and Age" where
  # DV comes first for readability even though x-axis is Age.
  # .jst_plot_title already puts the two names with " and " between them.
  .cat_red(paste0(plot_title, "\n"))

  if (.jst_default_used) .jst_default_note(.jst_data_name)
  .jst_print_msgs(pipeline$msgs)

  # -- Convert haven-labelled categoricals to factors -----------------------
  for (v in variable_names) {
    if (haven::is.labelled(data[[v]])) {
      val_labs <- labelled::val_labels(data[[v]])
      if (!is.null(val_labs) && length(val_labs) > 0) {
        data[[v]] <- haven::as_factor(data[[v]])
      } else {
        data[[v]] <- as.numeric(data[[v]])
      }
    }
  }
  if (has_by && haven::is.labelled(data[[by_name]])) {
    val_labs <- labelled::val_labels(data[[by_name]])
    if (!is.null(val_labs) && length(val_labs) > 0) {
      data[[by_name]] <- haven::as_factor(data[[by_name]])
    } else {
      data[[by_name]] <- factor(data[[by_name]])
    }
  } else if (has_by && !is.factor(data[[by_name]])) {
    data[[by_name]] <- factor(data[[by_name]])
  }

  if (.jst_resolve_toggle("var.labels", labels)) {
    .print_var_labels(data, check_names)
  }

  # -- Ignored-argument note (e.g. band = ... without line = "lm") ----------
  called_args   <- names(jplot_call)
  explicit_args <- called_args[nzchar(called_args)]
  is_scatter_lm <- resolved_type == "scatter" &&
                   (identical(line, "lm") || identical(line, TRUE))
  ignored <- character(0)
  if ("line" %in% explicit_args && resolved_type != "scatter") {
    ignored <- c(ignored, "line")
  }
  if ("band" %in% explicit_args && !is_scatter_lm) {
    ignored <- c(ignored, "band")
  }
  if ("equation" %in% explicit_args && !is_scatter_lm) {
    ignored <- c(ignored, "equation")
  }
  if ("r2" %in% explicit_args && !is_scatter_lm) {
    ignored <- c(ignored, "r2")
  }
  if (length(ignored) > 0) {
    .cat_yellow(paste0(
      "(Note: ", paste(ignored, collapse = ", "),
      " not applicable to ", resolved_type,
      if (resolved_type == "scatter") " without line = \"lm\"" else "",
      " \u2014 ignored)\n"
    ))
  }

  # -- Dispatch to builder --------------------------------------------------
  p <- switch(
    resolved_type,
    scatter = .jst_build_scatter(data, variable_names, by_name,
                                 line, equation, r2, band,
                                 axis_labels, by_label),
    box     = .jst_build_box(data, variable_names, var_types, by_name,
                             axis_labels, by_label)
  )

  print(p)
  invisible(p)
}


# -- Data-first plot helpers ---------------------------------------------------

#' Internal helper: choose an axis label for a variable
#'
#' Returns the variable's label (from labelled::var_label) if one is set and
#' fits within \code{max_len} characters. Truncates with three trailing periods
#' if the label exceeds \code{max_len}. Falls back to the variable name when
#' no label is present.
#'
#' @param x A variable (vector), possibly haven-labelled.
#' @param name Character. The variable name to fall back to if no label.
#' @param max_len Integer. Maximum label length before truncation. Default 35.
#' @return A character string suitable for use as an axis label.
#' @keywords internal
.jst_short_label <- function(x, name, max_len = 35) {
  lbl <- labelled::var_label(x)
  if (is.null(lbl) || length(lbl) == 0 || is.na(lbl[1]) || !nzchar(lbl[1])) {
    return(name)
  }
  lbl <- as.character(lbl[1])
  if (nchar(lbl) > max_len) {
    return(paste0(substr(lbl, 1, max_len - 3), "..."))
  }
  lbl
}

#' Internal helper: build a red-title string for jplot.default output
#'
#' Produces titles like:
#' \itemize{
#'   \item Histogram: Age
#'   \item Bar Chart: Gender
#'   \item Scatterplot: Age and Tattoos
#'   \item Boxplot: Age by Gender
#'   \item Grouped Bar Chart: Program and Employment
#' }
#' Appends " by <by_name>" when a by-variable is supplied.
#' Uses variable names (not labels), matching the user's typed call.
#'
#' @param plot_type Character, one of the valid resolved types.
#' @param variable_names Character vector of 1 or 2 variable names.
#' @param by_name Optional character string for the by-variable.
#' @keywords internal
.jst_plot_title <- function(plot_type, variable_names, by_name = NULL) {
  prefix <- switch(
    plot_type,
    histogram   = "Histogram",
    bar         = "Bar Chart",
    scatter     = "Scatterplot",
    box         = "Boxplot",
    grouped_bar = "Grouped Bar Chart",
    "Plot"
  )
  body <- if (length(variable_names) == 1) {
    variable_names[1]
  } else {
    paste(variable_names[1], "and", variable_names[2])
  }
  if (!is.null(by_name)) {
    paste0(prefix, ": ", body, " by ", by_name)
  } else {
    paste0(prefix, ": ", body)
  }
}


#' Internal helper: auto-detect plot type from variable types
#'
#' @keywords internal
.jst_auto_plot_type <- function(var_types, n_vars) {
  if (n_vars == 1) {
    if (var_types[1] == "numeric") return("histogram")
    return("bar")
  }
  # n_vars == 2
  if (all(var_types == "numeric"))      return("scatter")
  if (all(var_types == "categorical"))  return("grouped_bar")
  return("box")
}


#' Internal helper: format the equation subtitle for a bivariate regression
#'
#' Uses variable names rather than y/x for pedagogical clarity.
#'
#' @keywords internal
.jst_format_bivar_equation <- function(model, y_name, x_name,
                                       include_r2 = TRUE) {
  coefs     <- stats::coef(model)
  intercept <- coefs[1]
  slope     <- coefs[2]
  sign_char <- if (slope >= 0) "+" else "\u2212"
  eq <- sprintf("%s = %.2f %s %.2f\u00b7%s",
                y_name, intercept, sign_char, abs(slope), x_name)
  if (include_r2) {
    r2 <- summary(model)$r.squared
    eq <- paste0(eq, "    R\u00b2 = ", sprintf("%.3f", r2))
  }
  eq
}


#' Internal helper: build histogram (1 numeric variable)
#'
#' @keywords internal
#' @importFrom rlang .data
.jst_build_histogram <- function(data, x_name, by_name = NULL,
                                 axis_labels = NULL, by_label = NULL) {
  plot_df <- data.frame(x = data[[x_name]])
  if (!is.null(by_name)) plot_df$by <- data[[by_name]]

  plot_df <- plot_df[stats::complete.cases(plot_df), , drop = FALSE]

  x_lab  <- if (!is.null(axis_labels)) axis_labels[[x_name]] else x_name
  by_lab <- if (!is.null(by_label)) by_label else by_name

  if (is.null(by_name)) {
    p <- ggplot2::ggplot(plot_df, ggplot2::aes(x = .data$x)) +
      ggplot2::geom_histogram(bins = 30, fill = "#3366FF", color = "white",
                              alpha = 0.85) +
      ggplot2::labs(x = x_lab, y = "Count") +
      ggplot2::theme_minimal()
  } else {
    p <- ggplot2::ggplot(plot_df, ggplot2::aes(x = .data$x,
                                                fill = .data$by)) +
      ggplot2::geom_histogram(bins = 30, color = "white", alpha = 0.55,
                              position = "identity") +
      ggplot2::labs(x = x_lab, y = "Count", fill = by_lab) +
      ggplot2::theme_minimal()
  }
  p
}


#' Internal helper: build bar chart (1 categorical variable)
#'
#' @keywords internal
#' @importFrom rlang .data
.jst_build_bar <- function(data, x_name, by_name = NULL,
                           axis_labels = NULL, by_label = NULL) {
  plot_df <- data.frame(x = data[[x_name]])
  if (!is.null(plot_df$x) && !is.factor(plot_df$x)) {
    plot_df$x <- factor(plot_df$x)
  }
  if (!is.null(by_name)) plot_df$by <- data[[by_name]]

  plot_df <- plot_df[stats::complete.cases(plot_df), , drop = FALSE]

  x_lab  <- if (!is.null(axis_labels)) axis_labels[[x_name]] else x_name
  by_lab <- if (!is.null(by_label)) by_label else by_name

  if (is.null(by_name)) {
    p <- ggplot2::ggplot(plot_df, ggplot2::aes(x = .data$x)) +
      ggplot2::geom_bar(fill = "#3366FF", alpha = 0.85) +
      ggplot2::labs(x = x_lab, y = "Count") +
      ggplot2::theme_minimal()
  } else {
    p <- ggplot2::ggplot(plot_df, ggplot2::aes(x = .data$x, fill = .data$by)) +
      ggplot2::geom_bar(position = ggplot2::position_dodge(width = 0.8),
                        width = 0.7) +
      ggplot2::labs(x = x_lab, y = "Count", fill = by_lab) +
      ggplot2::theme_minimal()
  }
  p
}


#' Internal helper: build scatterplot (2 numeric variables)
#'
#' @keywords internal
#' @importFrom rlang .data
.jst_build_scatter <- function(data, variable_names, by_name,
                               line, equation, r2, band,
                               axis_labels = NULL, by_label = NULL) {

  x_name <- variable_names[1]
  y_name <- variable_names[2]

  x_lab  <- if (!is.null(axis_labels)) axis_labels[[x_name]] else x_name
  y_lab  <- if (!is.null(axis_labels)) axis_labels[[y_name]] else y_name
  by_lab <- if (!is.null(by_label)) by_label else by_name

  plot_df <- data.frame(x = data[[x_name]], y = data[[y_name]])
  if (!is.null(by_name)) plot_df$by <- data[[by_name]]
  plot_df <- plot_df[stats::complete.cases(plot_df), , drop = FALSE]

  # Base scatter
  if (is.null(by_name)) {
    p <- ggplot2::ggplot(plot_df, ggplot2::aes(x = .data$x, y = .data$y)) +
      ggplot2::geom_point(alpha = 0.55, color = "#222222")
  } else {
    p <- ggplot2::ggplot(plot_df, ggplot2::aes(x = .data$x, y = .data$y,
                                                color = .data$by)) +
      ggplot2::geom_point(alpha = 0.65)
  }

  # Add line and band
  subtitle_text <- NULL
  if (!identical(line, FALSE)) {

    if (line == "connect") {
      # Simple line connecting points — no band, no equation
      if (is.null(by_name)) {
        p <- p + ggplot2::geom_line(color = "#3366FF", alpha = 0.7)
      } else {
        p <- p + ggplot2::geom_line(alpha = 0.7)
      }

    } else if (line == "loess") {
      # Loess smoother — no equation, band options apply
      show_se <- !identical(band, "none") && band == "ci"
      if (is.null(by_name)) {
        p <- p + ggplot2::geom_smooth(method = "loess", se = show_se,
                                      color = "#3366FF",
                                      fill = "#3366FF",
                                      formula = y ~ x)
      } else {
        p <- p + ggplot2::geom_smooth(method = "loess", se = show_se,
                                      formula = y ~ x)
      }

    } else if (line == "lm") {
      # Linear regression — full treatment
      p <- .jst_add_lm_line(p, plot_df, x_name, y_name, by_name, band)

      # Build equation subtitle
      if (equation || r2) {
        if (is.null(by_name)) {
          m <- stats::lm(y ~ x, data = plot_df)
          eq <- .jst_format_bivar_equation(m, y_name, x_name,
                                           include_r2 = r2)
          if (!equation) {
            # Only R² requested
            subtitle_text <- sprintf("R\u00b2 = %.3f",
                                     summary(m)$r.squared)
          } else {
            subtitle_text <- eq
          }
        } else {
          # Per-group equations
          groups <- levels(droplevels(plot_df$by))
          eq_lines <- character(0)
          for (g in groups) {
            sub <- plot_df[plot_df$by == g, , drop = FALSE]
            if (nrow(sub) >= 2 &&
                length(unique(sub$x)) >= 2) {
              m <- stats::lm(y ~ x, data = sub)
              if (equation) {
                eq <- .jst_format_bivar_equation(
                  m, y_name, x_name, include_r2 = r2
                )
                eq_lines <- c(eq_lines, paste0(g, ": ", eq))
              } else if (r2) {
                eq_lines <- c(eq_lines,
                              sprintf("%s: R\u00b2 = %.3f",
                                      g, summary(m)$r.squared))
              }
            }
          }
          if (length(eq_lines) > 0) {
            subtitle_text <- paste(eq_lines, collapse = "\n")
          }
        }
      }
    }
  }

  p <- p + ggplot2::labs(x = x_lab, y = y_lab,
                         color = by_lab, fill = by_lab,
                         subtitle = subtitle_text) +
           ggplot2::theme_minimal()
  p
}


#' Internal helper: add an lm regression line and optional band to a scatter
#'
#' Handles the four band options: ci (ggplot default), pi (prediction
#' interval, computed manually), see (constant +/- t*SEE rectangle), none.
#'
#' @keywords internal
#' @importFrom rlang .data
.jst_add_lm_line <- function(p, plot_df, x_name, y_name, by_name, band) {

  if (is.null(by_name)) {
    # Single-group line
    show_ci <- identical(band, "ci")
    p <- p + ggplot2::geom_smooth(method = "lm", se = show_ci,
                                  color = "#3366FF",
                                  fill = "#3366FF",
                                  formula = y ~ x)

    if (band %in% c("pi", "see")) {
      band_df <- .jst_compute_band(plot_df, band)
      p <- p + ggplot2::geom_ribbon(
        data = band_df,
        ggplot2::aes(x = .data$x, ymin = .data$lwr, ymax = .data$upr),
        fill = "#3366FF", alpha = 0.15,
        inherit.aes = FALSE
      )
    }

  } else {
    # Per-group lines
    show_ci <- identical(band, "ci")
    p <- p + ggplot2::geom_smooth(method = "lm", se = show_ci,
                                  formula = y ~ x)

    if (band %in% c("pi", "see")) {
      groups <- levels(droplevels(plot_df$by))
      band_dfs <- lapply(groups, function(g) {
        sub <- plot_df[plot_df$by == g, , drop = FALSE]
        if (nrow(sub) >= 3 && length(unique(sub$x)) >= 2) {
          band_df <- .jst_compute_band(sub, band)
          band_df$by <- g
          band_df
        } else NULL
      })
      band_df <- do.call(rbind, band_dfs)
      if (!is.null(band_df) && nrow(band_df) > 0) {
        band_df$by <- factor(band_df$by, levels = groups)
        p <- p + ggplot2::geom_ribbon(
          data = band_df,
          ggplot2::aes(x = .data$x, ymin = .data$lwr, ymax = .data$upr,
                       fill = .data$by),
          alpha = 0.12, inherit.aes = FALSE
        )
      }
    }
  }
  p
}


#' Internal helper: compute prediction interval or +/- t*SEE band for a bivariate
#' regression
#'
#' @param plot_df Data frame with columns x and y.
#' @param band Either "pi" or "see".
#' @return Data frame with columns x, fit, lwr, upr.
#' @keywords internal
.jst_compute_band <- function(plot_df, band) {
  m <- stats::lm(y ~ x, data = plot_df)
  x_grid <- seq(min(plot_df$x, na.rm = TRUE),
                max(plot_df$x, na.rm = TRUE), length.out = 120)
  new_df <- data.frame(x = x_grid)

  if (band == "pi") {
    pred <- stats::predict(m, newdata = new_df, interval = "prediction",
                           level = 0.95)
    return(data.frame(x = x_grid,
                      fit = pred[, "fit"],
                      lwr = pred[, "lwr"],
                      upr = pred[, "upr"]))
  }
  if (band == "see") {
    fit_vals <- stats::predict(m, newdata = new_df)
    see <- summary(m)$sigma
    t_crit <- stats::qt(0.975, df = stats::df.residual(m))
    return(data.frame(x = x_grid,
                      fit = fit_vals,
                      lwr = fit_vals - t_crit * see,
                      upr = fit_vals + t_crit * see))
  }
  NULL
}


#' Internal helper: build boxplot (1 numeric + 1 categorical)
#'
#' @keywords internal
#' @importFrom rlang .data
.jst_build_box <- function(data, variable_names, var_types, by_name = NULL,
                           axis_labels = NULL, by_label = NULL) {

  # Numeric on y, categorical on x
  if (var_types[1] == "numeric") {
    y_name <- variable_names[1]
    x_name <- variable_names[2]
  } else {
    x_name <- variable_names[1]
    y_name <- variable_names[2]
  }

  x_lab  <- if (!is.null(axis_labels)) axis_labels[[x_name]] else x_name
  y_lab  <- if (!is.null(axis_labels)) axis_labels[[y_name]] else y_name
  by_lab <- if (!is.null(by_label)) by_label else by_name

  plot_df <- data.frame(x = data[[x_name]], y = data[[y_name]])
  if (!is.factor(plot_df$x)) plot_df$x <- factor(plot_df$x)
  if (!is.null(by_name)) plot_df$by <- data[[by_name]]
  plot_df <- plot_df[stats::complete.cases(plot_df), , drop = FALSE]

  if (is.null(by_name)) {
    p <- ggplot2::ggplot(plot_df, ggplot2::aes(x = .data$x, y = .data$y)) +
      ggplot2::geom_boxplot(fill = "#E6EEF9", color = "#333333",
                            outlier.alpha = 0.6) +
      ggplot2::stat_summary(fun = mean, geom = "point",
                            shape = 18, size = 3, color = "#3366FF") +
      ggplot2::labs(x = x_lab, y = y_lab,
                    subtitle = "Diamond marks the group mean") +
      ggplot2::theme_minimal()
  } else {
    p <- ggplot2::ggplot(plot_df, ggplot2::aes(x = .data$x, y = .data$y,
                                                fill = .data$by)) +
      ggplot2::geom_boxplot(outlier.alpha = 0.6) +
      ggplot2::labs(x = x_lab, y = y_lab, fill = by_lab) +
      ggplot2::theme_minimal()
  }
  p
}


#' Internal helper: build grouped bar chart (2 categorical variables)
#'
#' @keywords internal
#' @importFrom rlang .data
.jst_build_grouped_bar <- function(data, variable_names, axis_labels = NULL) {
  x_name    <- variable_names[1]
  fill_name <- variable_names[2]

  x_lab    <- if (!is.null(axis_labels)) axis_labels[[x_name]] else x_name
  fill_lab <- if (!is.null(axis_labels)) axis_labels[[fill_name]] else fill_name

  plot_df <- data.frame(x = data[[x_name]], fill = data[[fill_name]])
  if (!is.factor(plot_df$x))    plot_df$x    <- factor(plot_df$x)
  if (!is.factor(plot_df$fill)) plot_df$fill <- factor(plot_df$fill)
  plot_df <- plot_df[stats::complete.cases(plot_df), , drop = FALSE]

  p <- ggplot2::ggplot(plot_df, ggplot2::aes(x = .data$x, fill = .data$fill)) +
    ggplot2::geom_bar(position = ggplot2::position_dodge(width = 0.8),
                      width = 0.7) +
    ggplot2::scale_fill_brewer(palette = "Blues") +
    ggplot2::labs(x = x_lab, y = "Count", fill = fill_lab) +
    ggplot2::theme_minimal()
  p
}


# -- Internal helpers for jplot ------------------------------------------------

#' Internal helper: resolve the `which` argument for jplot dispatch methods
#'
#' Translates the user's \code{which} argument into a vector of plot
#' identifiers. Accepts the special values \code{core} and
#' \code{all} (resolved against the supplied \code{core} and
#' \code{all_plots} vectors) or an explicit character vector of plot
#' names. Errors with a clear message listing the valid options if any
#' name in \code{which} isn't recognized.
#'
#' @param which The user's \code{which} argument: \code{core},
#'   \code{all}, or a character vector of plot names.
#' @param core Character vector of plot identifiers comprising the
#'   "core" set for this jplot method.
#' @param all_plots Character vector of all valid plot identifiers for
#'   this jplot method.
#' @param class_name Character. The S3 class being dispatched on, used
#'   in the error message.
#'
#' @return A character vector of plot identifiers to produce.
#'
#' @keywords internal
.jst_resolve_which <- function(which, core, all_plots, class_name) {
  if (length(which) == 1 && which %in% c("core", "all")) {
    return(if (which == "core") core else all_plots)
  }
  bad <- setdiff(which, all_plots)
  if (length(bad) > 0) {
    stop(sprintf(
      "Invalid plot name(s) for class '%s': %s.\nValid names: %s, or use \"core\" / \"all\".",
      class_name,
      paste(sprintf("'%s'", bad), collapse = ", "),
      paste(sprintf("'%s'", all_plots), collapse = ", ")
    ), call. = FALSE)
  }
  which
}

#' Internal helper: standardize the return value of jplot dispatch methods
#'
#' Strips \code{NULL} entries from a list of ggplot objects, then
#' returns the list invisibly — or, if exactly one plot remains,
#' returns that plot alone. Used so that \code{jplot()} returns a
#' sensible value for the single-plot case (suitable for further
#' piping or printing) without losing flexibility for the multi-plot
#' case.
#'
#' @param plots A list of ggplot objects, possibly containing
#'   \code{NULL} entries.
#'
#' @return Invisibly: \code{NULL} if all plots are \code{NULL}; a
#'   single ggplot if exactly one non-\code{NULL} plot remains;
#'   otherwise the trimmed list.
#'
#' @keywords internal
.jst_return_plots <- function(plots) {
  plots <- plots[!vapply(plots, is.null, logical(1))]
  if (length(plots) == 0) return(invisible(NULL))
  if (length(plots) == 1) return(invisible(plots[[1]]))
  invisible(plots)
}

#' Internal helper: resolve the `at` argument for regression-line plots
#'
#' Computes the values at which non-focal predictors should be held when
#' producing a fitted-line plot for a multiple-predictor regression. The
#' \code{at} argument accepts \code{zero}, \code{mean},
#' \code{mixed} (zero for dummies, mean for numeric), or a named
#' list giving an explicit value per non-focal predictor.
#'
#' @param at User-supplied value: \code{zero}, \code{mean},
#'   \code{mixed}, or a named list of explicit hold values.
#' @param model_frame Data frame used to fit the model
#'   (post-conversion).
#' @param dv_name Character. The dependent variable name.
#' @param focal_name Character. The focal predictor name (the one that
#'   varies along the x-axis).
#' @param dummy_coef_names Character vector of registered
#'   dummy-coefficient names, used to identify which non-focal
#'   predictors are dummies.
#'
#' @return A named list of hold values, one per non-focal predictor.
#'   Empty list if there are no non-focal predictors.
#'
#' @keywords internal
.jst_resolve_at <- function(at, model_frame, dv_name, focal_name,
                            dummy_coef_names) {

  non_focal <- setdiff(colnames(model_frame), c(dv_name, focal_name))

  if (length(non_focal) == 0) return(list())

  classify <- function(v) {
    if (v %in% dummy_coef_names) return("categorical")
    x <- model_frame[[v]]
    # Use the unified classifier. data_name is not available at this point
    # (the model_frame doesn't retain the source data frame's name), so
    # jdummy registration is checked via the dummy_coef_names list above
    # rather than by passing var_name/data_name to the classifier.
    if (.jst_is_categorical(x)) "categorical" else "interval"
  }

  hold_at <- function(v, mode) {
    x <- model_frame[[v]]
    x_num <- as.numeric(x)
    if (mode == "zero") return(0)
    if (mode == "mean") return(mean(x_num, na.rm = TRUE))
    if (mode == "mixed") {
      if (classify(v) == "categorical") return(0)
      return(mean(x_num, na.rm = TRUE))
    }
    stop("Unknown 'at' mode: ", mode, call. = FALSE)
  }

  if (is.list(at)) {
    result <- setNames(as.list(rep(0, length(non_focal))), non_focal)
    for (nm in names(at)) {
      if (nm %in% non_focal) result[[nm]] <- at[[nm]]
    }
    return(result)
  }

  if (!is.character(at) || length(at) != 1 ||
      !at %in% c("zero", "mean", "mixed")) {
    stop("`at` must be one of \"zero\", \"mean\", \"mixed\", or a named list.",
         call. = FALSE)
  }

  setNames(lapply(non_focal, hold_at, mode = at), non_focal)
}

#' Internal helper: format a regression equation for plot subtitles
#'
#' Builds a short equation string from a coefficient vector for use as a
#' plot subtitle. Truncates to \code{max_terms} predictors and joins
#' them with appropriate sign characters.
#'
#' @param coefs_vec Named numeric vector of regression coefficients
#'   (intercept first).
#' @param dv_name Character. The dependent variable name used at the
#'   left-hand side of the equation.
#' @param max_terms Integer. Maximum number of predictor terms to
#'   include. Default 3; additional terms are summarized as
#'   \code{...}.
#'
#' @return A character string of the formatted equation.
#'
#' @keywords internal
.jst_format_equation <- function(coefs_vec, dv_name, max_terms = 3) {

  intercept <- coefs_vec[1]
  slopes    <- coefs_vec[-1]
  iv_count  <- length(slopes)

  if (iv_count > max_terms) {
    return(NULL)
  }

  eq <- sprintf("%s = %.2f", dv_name, intercept)
  for (i in seq_along(slopes)) {
    b <- slopes[i]
    sign_char <- if (b >= 0) "+" else "\u2212"
    eq <- paste0(eq, " ", sign_char, " ", sprintf("%.2f", abs(b)),
                 "\u00b7", names(slopes)[i])
  }
  eq
}


# -- jplot.jst_lm --------------------------------------------------------------

#' @rdname jplot
#' @export
#' @importFrom rlang .data
jplot.jst_lm <- function(x, which = "core", focal = NULL, at = "zero",
                         equation = TRUE, r2 = TRUE, ...) {

  .jst_check_args(
    list(...),
    aliases = c(diagnostics = "which", plots = "which",
                show = "which", type = "which"),
    fn_name = "jplot.jst_lm"
  )

  if (!requireNamespace("ggplot2", quietly = TRUE)) {
    stop("Package 'ggplot2' is required for jplot(). ",
         "Install with: install.packages(\"ggplot2\")", call. = FALSE)
  }

  all_plots <- c("fit", "predicted", "effects", "coef", "vif",
                 "residuals", "qq", "scale", "cooks", "leverage")
  core      <- c("fit", "qq", "residuals", "cooks")
  plot_set  <- .jst_resolve_which(which, core, all_plots, "jst_lm")

  focal_name <- tryCatch(deparse(substitute(focal)), error = function(e) "NULL")
  if (identical(focal_name, "NULL") || !nzchar(focal_name) ||
      focal_name == "NULL") focal_name <- NULL

  model   <- x$model
  mf      <- x$model_frame
  dv_name <- all.vars(x$formula_used)[1]
  iv_names <- setdiff(colnames(mf), dv_name)

  if (is.null(focal_name)) focal_name <- iv_names[1]
  if (!focal_name %in% iv_names) {
    stop("`focal` must be one of the independent variables in the model: ",
         paste(iv_names, collapse = ", "), call. = FALSE)
  }

  plots <- list()
  coefs <- stats::coef(model)

  # ---- fit plot ------------------------------------------------------------
  if ("fit" %in% plot_set) {
    at_vals <- .jst_resolve_at(at, mf, dv_name, focal_name,
                               x$dummy_coef_names)

    focal_range <- range(mf[[focal_name]], na.rm = TRUE)
    grid_x <- seq(focal_range[1], focal_range[2], length.out = 120)
    newdata <- data.frame(grid_x)
    names(newdata) <- focal_name
    for (v in names(at_vals)) newdata[[v]] <- at_vals[[v]]

    pred <- stats::predict(model, newdata = newdata, interval = "confidence",
                           level = 0.95)
    line_df <- data.frame(
      x   = grid_x,
      fit = pred[, "fit"],
      lwr = pred[, "lwr"],
      upr = pred[, "upr"]
    )
    point_df <- data.frame(
      x = mf[[focal_name]],
      y = mf[[dv_name]]
    )

    eq_text <- if (equation) .jst_format_equation(coefs, dv_name,
                                                  max_terms = 3) else NULL
    r2_text <- if (r2) sprintf("R\u00b2 = %.3f", x$r_squared) else NULL

    subtitle_parts <- character(0)
    if (!is.null(eq_text) && !is.null(r2_text)) {
      subtitle_parts <- paste0(eq_text, "    ", r2_text)
    } else if (!is.null(eq_text)) {
      subtitle_parts <- eq_text
    } else if (!is.null(r2_text)) {
      subtitle_parts <- r2_text
    }

    if (length(at_vals) > 0) {
      at_parts <- vapply(names(at_vals), function(v) {
        val <- at_vals[[v]]
        paste0(v, " = ", if (abs(val - round(val)) < 1e-8) {
          as.character(round(val))
        } else {
          sprintf("%.2f", val)
        })
      }, character(1))
      held_note <- paste0("(line shown at ",
                          paste(at_parts, collapse = ", "), ")")
      if (length(subtitle_parts) > 0) {
        subtitle_parts <- paste0(subtitle_parts, "\n", held_note)
      } else {
        subtitle_parts <- held_note
      }
    }

    if (equation && is.null(eq_text)) {
      note <- paste0("(equation omitted: model has ",
                     length(iv_names),
                     " predictors; see jlm() output for coefficients)")
      subtitle_parts <- if (length(subtitle_parts) > 0) {
        paste0(subtitle_parts, "\n", note)
      } else {
        note
      }
    }

    p <- ggplot2::ggplot() +
      ggplot2::geom_ribbon(data = line_df,
                           ggplot2::aes(x = .data$x,
                                        ymin = .data$lwr,
                                        ymax = .data$upr),
                           fill = "#3366FF", alpha = 0.18) +
      ggplot2::geom_point(data = point_df,
                          ggplot2::aes(x = .data$x, y = .data$y),
                          alpha = 0.55, color = "#222222") +
      ggplot2::geom_line(data = line_df,
                         ggplot2::aes(x = .data$x, y = .data$fit),
                         color = "#3366FF", linewidth = 0.9) +
      ggplot2::labs(
        x        = focal_name,
        y        = dv_name,
        subtitle = if (length(subtitle_parts) > 0) subtitle_parts else NULL
      ) +
      ggplot2::theme_minimal()
    print(p)
    plots$fit <- p
  }

  # ---- predicted plot (observed vs predicted) ------------------------------
  if ("predicted" %in% plot_set) {
    pred_df <- data.frame(
      observed  = mf[[dv_name]],
      predicted = stats::fitted(model)
    )
    lim <- range(c(pred_df$observed, pred_df$predicted), na.rm = TRUE)

    p <- ggplot2::ggplot(pred_df,
                         ggplot2::aes(x = .data$predicted,
                                      y = .data$observed)) +
      ggplot2::geom_abline(slope = 1, intercept = 0, linetype = "dashed",
                           color = "grey60") +
      ggplot2::geom_point(alpha = 0.55, color = "#222222") +
      ggplot2::coord_equal(xlim = lim, ylim = lim) +
      ggplot2::labs(title = "Observed vs Predicted",
                    x = "Predicted", y = "Observed") +
      ggplot2::theme_minimal()
    print(p)
    plots$predicted <- p
  }

  # ---- effects plot (one per IV) -------------------------------------------
  if ("effects" %in% plot_set) {
    n_effects <- 0
    for (iv in iv_names) {
      at_vals <- .jst_resolve_at(at, mf, dv_name, iv, x$dummy_coef_names)
      iv_range <- range(mf[[iv]], na.rm = TRUE)
      grid_x   <- seq(iv_range[1], iv_range[2], length.out = 80)
      newdata  <- data.frame(grid_x)
      names(newdata) <- iv
      for (v in names(at_vals)) newdata[[v]] <- at_vals[[v]]

      pred <- stats::predict(model, newdata = newdata,
                             interval = "confidence", level = 0.95)
      line_df <- data.frame(x = grid_x,
                            fit = pred[, "fit"],
                            lwr = pred[, "lwr"],
                            upr = pred[, "upr"])

      p <- ggplot2::ggplot(line_df,
                           ggplot2::aes(x = .data$x, y = .data$fit)) +
        ggplot2::geom_ribbon(ggplot2::aes(ymin = .data$lwr,
                                          ymax = .data$upr),
                             fill = "#3366FF", alpha = 0.18) +
        ggplot2::geom_line(color = "#3366FF", linewidth = 0.9) +
        ggplot2::labs(title = paste0("Effect: ", iv),
                      x = iv, y = dv_name) +
        ggplot2::theme_minimal()
      print(p)
      plots[[paste0("effect_", iv)]] <- p
      n_effects <- n_effects + 1
    }
    cat("\n(", n_effects,
        " effect plots produced, one per predictor)\n", sep = "")
  }

  # ---- coef forest plot ----------------------------------------------------
  if ("coef" %in% plot_set) {
    summ <- summary(model)$coefficients
    est  <- summ[-1, "Estimate"]
    se   <- summ[-1, "Std. Error"]
    nm   <- rownames(summ)[-1]

    t_crit <- stats::qt(0.975, df = stats::df.residual(model))
    coef_df <- data.frame(
      term  = factor(nm, levels = nm[order(abs(est))]),
      est   = est,
      lower = est - t_crit * se,
      upper = est + t_crit * se,
      stringsAsFactors = FALSE
    )

    p <- ggplot2::ggplot(coef_df,
                         ggplot2::aes(x = .data$est, y = .data$term)) +
      ggplot2::geom_vline(xintercept = 0, linetype = "dashed",
                          color = "grey60") +
      ggplot2::geom_errorbarh(ggplot2::aes(xmin = .data$lower,
                                           xmax = .data$upper),
                              height = 0.2, color = "steelblue") +
      ggplot2::geom_point(size = 2.5, color = "steelblue") +
      ggplot2::labs(title = "Coefficients (95% CI)",
                    x = "Estimate", y = NULL) +
      ggplot2::theme_minimal()
    print(p)
    plots$coef <- p
  }

  # ---- vif bar plot --------------------------------------------------------
  if ("vif" %in% plot_set) {
    vifs <- x$vif
    if (is.null(vifs)) {
      message("VIF plot skipped: VIF is only computed for models with 2+ predictors.")
    } else {
      vif_df <- data.frame(
        term = factor(names(vifs), levels = names(vifs)[order(vifs)]),
        vif  = as.numeric(vifs),
        stringsAsFactors = FALSE
      )
      p <- ggplot2::ggplot(vif_df,
                           ggplot2::aes(x = .data$vif, y = .data$term)) +
        ggplot2::geom_vline(xintercept = c(5, 10), linetype = "dashed",
                            color = "red", alpha = 0.6) +
        ggplot2::geom_col(fill = "steelblue", alpha = 0.8) +
        ggplot2::labs(title = "Variance Inflation Factors",
                      subtitle = "Reference lines at VIF = 5 and 10",
                      x = "VIF", y = NULL) +
        ggplot2::theme_minimal()
      print(p)
      plots$vif <- p
    }
  }

  # ---- diagnostic plots (residuals / qq / scale / cooks / leverage) --------
  diag_plots <- intersect(plot_set, c("residuals", "qq", "scale", "cooks",
                                      "leverage"))
  if (length(diag_plots) > 0) {
    diag_result <- .jst_plot_lm_diagnostics(model, which = diag_plots)
    if (is.list(diag_result)) {
      for (nm in names(diag_result)) plots[[nm]] <- diag_result[[nm]]
    }
  }

  .jst_return_plots(plots)
}


# -- jplot.jst_logistic --------------------------------------------------------

#' @rdname jplot
#' @export
#' @importFrom rlang .data
jplot.jst_logistic <- function(x, which = "core", focal = NULL, at = "zero",
                               ...) {

  .jst_check_args(
    list(...),
    aliases = c(diagnostics = "which", plots = "which",
                show = "which", type = "which"),
    fn_name = "jplot.jst_logistic"
  )

  if (!requireNamespace("ggplot2", quietly = TRUE)) {
    stop("Package 'ggplot2' is required for jplot(). ",
         "Install with: install.packages(\"ggplot2\")", call. = FALSE)
  }

  all_plots <- c("probability", "roc", "calibration", "binned",
                 "cooks", "leverage", "coef", "vif")
  core      <- c("probability", "roc", "calibration", "cooks")
  plot_set  <- .jst_resolve_which(which, core, all_plots, "jst_logistic")

  focal_name <- tryCatch(deparse(substitute(focal)), error = function(e) "NULL")
  if (identical(focal_name, "NULL") || !nzchar(focal_name) ||
      focal_name == "NULL") focal_name <- NULL

  model   <- x$model
  mf      <- x$model_frame
  dv_name <- names(mf)[1]
  iv_names <- setdiff(colnames(mf), dv_name)

  if (is.null(focal_name)) focal_name <- iv_names[1]
  if (!focal_name %in% iv_names) {
    stop("`focal` must be one of the independent variables in the model: ",
         paste(iv_names, collapse = ", "), call. = FALSE)
  }

  plots <- list()

  # ---- probability plot (S-curve) ------------------------------------------
  if ("probability" %in% plot_set) {
    at_vals <- .jst_resolve_at(at, mf, dv_name, focal_name,
                               x$dummy_coef_names)

    focal_range <- range(mf[[focal_name]], na.rm = TRUE)
    grid_x <- seq(focal_range[1], focal_range[2], length.out = 120)
    newdata <- data.frame(grid_x)
    names(newdata) <- focal_name
    for (v in names(at_vals)) newdata[[v]] <- at_vals[[v]]

    pred_link <- stats::predict(model, newdata = newdata, type = "link",
                                se.fit = TRUE)
    t_crit <- 1.96
    line_df <- data.frame(
      x   = grid_x,
      fit = stats::plogis(pred_link$fit),
      lwr = stats::plogis(pred_link$fit - t_crit * pred_link$se.fit),
      upr = stats::plogis(pred_link$fit + t_crit * pred_link$se.fit)
    )
    point_df <- data.frame(
      x = mf[[focal_name]],
      y = as.numeric(mf[[dv_name]])
    )

    predicts_label <- if (!is.null(x$predicts)) x$predicts else "1"

    held_note <- NULL
    if (length(at_vals) > 0) {
      at_parts <- vapply(names(at_vals), function(v) {
        val <- at_vals[[v]]
        paste0(v, " = ", if (abs(val - round(val)) < 1e-8) {
          as.character(round(val))
        } else {
          sprintf("%.2f", val)
        })
      }, character(1))
      held_note <- paste0("(line shown at ",
                          paste(at_parts, collapse = ", "), ")")
    }

    p <- ggplot2::ggplot() +
      ggplot2::geom_ribbon(data = line_df,
                           ggplot2::aes(x = .data$x,
                                        ymin = .data$lwr,
                                        ymax = .data$upr),
                           fill = "#3366FF", alpha = 0.18) +
      ggplot2::geom_point(data = point_df,
                          ggplot2::aes(x = .data$x, y = .data$y),
                          alpha = 0.35, color = "#222222") +
      ggplot2::geom_line(data = line_df,
                         ggplot2::aes(x = .data$x, y = .data$fit),
                         color = "#3366FF", linewidth = 0.9) +
      ggplot2::labs(
        title    = paste0("Predicted Probability: ", dv_name,
                          " = ", predicts_label),
        x        = focal_name,
        y        = paste0("P(", dv_name, " = ", predicts_label, ")"),
        subtitle = held_note
      ) +
      ggplot2::ylim(0, 1) +
      ggplot2::theme_minimal()
    print(p)
    plots$probability <- p
  }

  # ---- coef forest plot (OR scale) -----------------------------------------
  if ("coef" %in% plot_set) {
    summ <- summary(model)$coefficients
    est  <- summ[-1, "Estimate"]
    se   <- summ[-1, "Std. Error"]
    nm   <- rownames(summ)[-1]

    t_crit <- 1.96
    coef_df <- data.frame(
      term  = factor(nm, levels = nm[order(abs(est))]),
      or    = exp(est),
      lower = exp(est - t_crit * se),
      upper = exp(est + t_crit * se),
      stringsAsFactors = FALSE
    )

    p <- ggplot2::ggplot(coef_df,
                         ggplot2::aes(x = .data$or, y = .data$term)) +
      ggplot2::geom_vline(xintercept = 1, linetype = "dashed",
                          color = "grey60") +
      ggplot2::geom_errorbarh(ggplot2::aes(xmin = .data$lower,
                                           xmax = .data$upper),
                              height = 0.2, color = "steelblue") +
      ggplot2::geom_point(size = 2.5, color = "steelblue") +
      ggplot2::scale_x_log10() +
      ggplot2::labs(title = "Odds Ratios (95% CI)",
                    subtitle = "Log scale; OR = 1 means no effect",
                    x = "Exp(B)", y = NULL) +
      ggplot2::theme_minimal()
    print(p)
    plots$coef <- p
  }

  # ---- vif bar plot --------------------------------------------------------
  if ("vif" %in% plot_set) {
    vifs <- x$vif
    if (is.null(vifs)) {
      message("VIF plot skipped: VIF is only computed for models with 2+ predictors.")
    } else {
      vif_df <- data.frame(
        term = factor(names(vifs), levels = names(vifs)[order(vifs)]),
        vif  = as.numeric(vifs),
        stringsAsFactors = FALSE
      )
      p <- ggplot2::ggplot(vif_df,
                           ggplot2::aes(x = .data$vif, y = .data$term)) +
        ggplot2::geom_vline(xintercept = c(5, 10), linetype = "dashed",
                            color = "red", alpha = 0.6) +
        ggplot2::geom_col(fill = "steelblue", alpha = 0.8) +
        ggplot2::labs(title = "Variance Inflation Factors",
                      subtitle = "Reference lines at VIF = 5 and 10",
                      x = "VIF", y = NULL) +
        ggplot2::theme_minimal()
      print(p)
      plots$vif <- p
    }
  }

  # ---- diagnostic plots (binned / roc / calibration / cooks / leverage) ----
  diag_plots <- intersect(plot_set, c("binned", "roc", "calibration",
                                      "cooks", "leverage"))
  if (length(diag_plots) > 0) {
    diag_result <- .jst_plot_logistic_diagnostics(model, which = diag_plots)
    if (is.list(diag_result)) {
      for (nm in names(diag_result)) plots[[nm]] <- diag_result[[nm]]
    }
  }

  .jst_return_plots(plots)
}


# -- jplot.jst_ttest -----------------------------------------------------------

#' @rdname jplot
#' @export
#' @importFrom rlang .data
jplot.jst_ttest <- function(x, which = "core", ...) {

  .jst_check_args(
    list(...),
    aliases = c(diagnostics = "which", plots = "which",
                show = "which", type = "which"),
    fn_name = "jplot.jst_ttest"
  )

  if (!requireNamespace("ggplot2", quietly = TRUE)) {
    stop("Package 'ggplot2' is required for jplot(). ",
         "Install with: install.packages(\"ggplot2\")", call. = FALSE)
  }

  plot_set <- .jst_resolve_which(which, core = "box", all_plots = "box",
                                 class_name = "jst_ttest")

  mf <- x$model_frame
  if (is.null(mf)) {
    stop("jplot() requires model_frame on the jst_ttest object. ",
         "Re-run jt() with the current version of the package.",
         call. = FALSE)
  }
  terms <- all.vars(x$formula)
  dv_name    <- terms[1]
  group_name <- terms[2]

  plots <- list()

  if ("box" %in% plot_set) {
    plot_df <- data.frame(
      dv    = mf[[dv_name]],
      group = mf[[group_name]]
    )
    if (!is.factor(plot_df$group)) plot_df$group <- factor(plot_df$group)

    p <- ggplot2::ggplot(plot_df,
                         ggplot2::aes(x = .data$group, y = .data$dv)) +
      ggplot2::geom_boxplot(fill = "#E6EEF9", color = "#333333",
                            outlier.alpha = 0.6) +
      ggplot2::stat_summary(fun = mean, geom = "point",
                            shape = 18, size = 3, color = "#3366FF") +
      ggplot2::labs(x = group_name, y = dv_name,
                    subtitle = "Diamond marks the group mean") +
      ggplot2::theme_minimal()
    print(p)
    plots$box <- p
  }

  .jst_return_plots(plots)
}


# -- jplot.jst_anova -----------------------------------------------------------

#' @rdname jplot
#' @export
#' @importFrom rlang .data
jplot.jst_anova <- function(x, which = "core", ...) {

  .jst_check_args(
    list(...),
    aliases = c(diagnostics = "which", plots = "which",
                show = "which", type = "which"),
    fn_name = "jplot.jst_anova"
  )

  if (!requireNamespace("ggplot2", quietly = TRUE)) {
    stop("Package 'ggplot2' is required for jplot(). ",
         "Install with: install.packages(\"ggplot2\")", call. = FALSE)
  }

  plot_set <- .jst_resolve_which(which, core = "box", all_plots = "box",
                                 class_name = "jst_anova")

  mf <- x$model_frame
  if (is.null(mf)) {
    stop("jplot() requires model_frame on the jst_anova object. ",
         "Re-run jaov() with the current version of the package.",
         call. = FALSE)
  }
  terms <- all.vars(x$formula)
  dv_name    <- terms[1]
  group_name <- terms[2]

  plots <- list()

  if ("box" %in% plot_set) {
    plot_df <- data.frame(
      dv    = mf[[dv_name]],
      group = mf[[group_name]]
    )
    if (!is.factor(plot_df$group)) plot_df$group <- factor(plot_df$group)

    p <- ggplot2::ggplot(plot_df,
                         ggplot2::aes(x = .data$group, y = .data$dv)) +
      ggplot2::geom_boxplot(fill = "#E6EEF9", color = "#333333",
                            outlier.alpha = 0.6) +
      ggplot2::stat_summary(fun = mean, geom = "point",
                            shape = 18, size = 3, color = "#3366FF") +
      ggplot2::labs(x = group_name, y = dv_name,
                    subtitle = "Diamond marks the group mean") +
      ggplot2::theme_minimal()
    print(p)
    plots$box <- p
  }

  .jst_return_plots(plots)
}


# -- jplot.jst_corr ------------------------------------------------------------

#' @rdname jplot
#' @export
#' @importFrom rlang .data
jplot.jst_corr <- function(x, which = "core", ...) {

  .jst_check_args(
    list(...),
    aliases = c(diagnostics = "which", plots = "which",
                show = "which", type = "which"),
    fn_name = "jplot.jst_corr"
  )

  if (!requireNamespace("ggplot2", quietly = TRUE)) {
    stop("Package 'ggplot2' is required for jplot(). ",
         "Install with: install.packages(\"ggplot2\")", call. = FALSE)
  }

  r_matrix <- x$r
  n_vars   <- nrow(r_matrix)

  default_core <- if (n_vars >= 3) "heatmap" else "scatter"
  all_plots <- if (n_vars >= 3) "heatmap" else c("scatter", "heatmap")

  plot_set <- .jst_resolve_which(which, core = default_core,
                                 all_plots = all_plots,
                                 class_name = "jst_corr")

  plots <- list()

  if ("heatmap" %in% plot_set) {
    var_names <- rownames(r_matrix)
    heat_df <- expand.grid(
      row = factor(var_names, levels = var_names),
      col = factor(var_names, levels = rev(var_names)),
      stringsAsFactors = FALSE
    )
    heat_df$r <- as.vector(r_matrix[cbind(match(heat_df$row, var_names),
                                           match(heat_df$col, var_names))])
    heat_df$label <- ifelse(is.na(heat_df$r), "",
                            sprintf("%.2f", heat_df$r))

    p <- ggplot2::ggplot(heat_df,
                         ggplot2::aes(x = .data$row, y = .data$col,
                                      fill = .data$r)) +
      ggplot2::geom_tile(color = "white", linewidth = 0.5) +
      ggplot2::geom_text(ggplot2::aes(label = .data$label),
                         size = 3.5, color = "#222222") +
      ggplot2::scale_fill_gradient2(low = "#CC3333", mid = "white",
                                    high = "#3366FF", midpoint = 0,
                                    limits = c(-1, 1), na.value = "grey90") +
      ggplot2::labs(title = "Correlation Matrix",
                    x = NULL, y = NULL, fill = "r") +
      ggplot2::theme_minimal() +
      ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 45,
                                                         hjust = 1))
    print(p)
    plots$heatmap <- p
  }

  if ("scatter" %in% plot_set) {
    mf <- x$model_frame
    if (is.null(mf)) {
      stop("Scatter plot requires model_frame on the jst_corr object. ",
           "Re-run jcorr() with the current version of the package.",
           call. = FALSE)
    }
    if (ncol(mf) != 2) {
      stop("Scatter plot is only available when jcorr() was called with ",
           "exactly 2 variables.", call. = FALSE)
    }
    var_names <- colnames(mf)
    r_val <- r_matrix[1, 2]
    n_val <- x$n[1, 2]

    p <- ggplot2::ggplot(mf,
                         ggplot2::aes(x = .data[[var_names[1]]],
                                      y = .data[[var_names[2]]])) +
      ggplot2::geom_point(alpha = 0.55, color = "#222222") +
      ggplot2::labs(subtitle = sprintf("r = %.3f, N = %d", r_val, n_val),
                    x = var_names[1], y = var_names[2]) +
      ggplot2::theme_minimal()
    print(p)
    plots$scatter <- p
  }

  .jst_return_plots(plots)
}


# -- jplot.jst_crosstab --------------------------------------------------------

#' @rdname jplot
#' @export
#' @importFrom rlang .data
jplot.jst_crosstab <- function(x, which = "core", ...) {

  .jst_check_args(
    list(...),
    aliases = c(diagnostics = "which", plots = "which",
                show = "which", type = "which"),
    fn_name = "jplot.jst_crosstab"
  )

  if (!requireNamespace("ggplot2", quietly = TRUE)) {
    stop("Package 'ggplot2' is required for jplot(). ",
         "Install with: install.packages(\"ggplot2\")", call. = FALSE)
  }

  plot_set <- .jst_resolve_which(which, core = "bar", all_plots = "bar",
                                 class_name = "jst_crosstab")

  plots <- list()

  if ("bar" %in% plot_set) {
    obs <- x$observed
    row_labels <- rownames(obs)
    col_labels <- colnames(obs)
    if (tail(row_labels, 1) == "Total") {
      obs <- obs[-nrow(obs), , drop = FALSE]
      row_labels <- row_labels[-length(row_labels)]
    }
    if (tail(col_labels, 1) == "Total") {
      obs <- obs[, -ncol(obs), drop = FALSE]
      col_labels <- col_labels[-length(col_labels)]
    }

    bar_df <- expand.grid(
      row = factor(row_labels, levels = row_labels),
      col = factor(col_labels, levels = col_labels),
      stringsAsFactors = FALSE
    )
    bar_df$count <- as.vector(as.matrix(obs))

    p <- ggplot2::ggplot(bar_df,
                         ggplot2::aes(x = .data$row, y = .data$count,
                                      fill = .data$col)) +
      ggplot2::geom_col(position = ggplot2::position_dodge(width = 0.8),
                        width = 0.7) +
      ggplot2::scale_fill_brewer(palette = "Blues") +
      ggplot2::labs(x = NULL, y = "Count", fill = NULL) +
      ggplot2::theme_minimal()
    print(p)
    plots$bar <- p
  }

  .jst_return_plots(plots)
}


# -- jplot.jst_desc / jplot.jst_freq (deferred to v2) --------------------------

#' @rdname jplot
#' @export
jplot.jst_desc <- function(x, which = "core", ...) {
  stop("Plotting jst_desc result objects is not supported. ",
       "Instead, call jplot() with the data frame directly, e.g.:\n",
       "  jplot(SampleData, Age)        # histogram\n",
       "  jplot(SampleData, Gender)     # bar chart\n",
       "  jplot(SampleData, Age, Gender) # boxplot",
       call. = FALSE)
}

#' @rdname jplot
#' @export
jplot.jst_freq <- function(x, which = "core", ...) {
  stop("Plotting jst_freq result objects is not supported. ",
       "Instead, call jplot() with the data frame directly, e.g.:\n",
       "  jplot(SampleData, Gender)              # bar chart\n",
       "  jplot(SampleData, Gender, Employment)  # grouped bar chart",
       call. = FALSE)
}

