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
#' @param extra_newline Logical. If TRUE, adds a trailing blank line after
#'   the note so it's visually separated from whatever prints next.
#'   Defaults to FALSE, so the note abuts the next line directly; the
#'   jcomplete and jdummy summaries pass TRUE explicitly to keep their
#'   trailing blank. (Default flipped TRUE -> FALSE in Session 52 to
#'   collapse the double blank line above the Case Processing block.)
#' @keywords internal
.jst_default_note <- function(data_name, extra_newline = FALSE) {
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
#' Used by jt, jaov, jcorr, jcrosstab, jscreen, and jalpha. Lists only
#' variables that carry a meaningful label: a variable with no label, or a
#' label equal to its own name, is omitted (avoiding a redundant "X = X"
#' line). If no variable has a meaningful label, nothing is printed.
#'
#' @keywords internal
.print_var_labels <- function(data, var_names) {
  label_lines <- c()
  for (v in var_names) {
    if (v %in% names(data)) {
      vl <- labelled::var_label(data[[v]])
      if (!is.null(vl) && !is.na(vl) && nzchar(vl) &&
          !identical(as.character(vl), v)) {
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

#' Internal helper: print a role-grouped model variable-label legend
#'
#' The regression layout's replacement for the flat \code{.print_var_labels}
#' list: lists a model's variables grouped by role -- the outcome first, then
#' the predictors. A variable with a label that differs from its name shows as
#' "name = label"; a variable with no label (or a label equal to its name)
#' shows as the bare "name" (absence of a meaningful label is conveyed by its
#' absence, not by a "None" marker). Used by jlm and jlogistic in the
#' "legend" and "legend.bottom" variable.id modes. Predictors are listed by
#' their original formula names (e.g. "Program"), not expanded dummy columns;
#' per-dummy-level value labelling is handled separately by the value.id
#' coefficient work. Matches the flat legend's indented-lines + trailing-blank
#' structure so co-located blocks space the same way.
#'
#' @param data A data frame (or pre-conversion label source) whose columns may
#'   carry variable labels.
#' @param dv_name Character. The outcome (response) variable name.
#' @param iv_names Character vector. The predictor variable names, in order.
#'
#' @keywords internal
.print_model_var_labels <- function(data, dv_name, iv_names) {
  fmt_line <- function(v) {
    vl <- labelled::var_label(data[[v]])
    # Show "name = label" only when a label exists and differs from the name;
    # a label equal to the name (or no label at all) shows the bare name,
    # avoiding a redundant "X = X" line.
    if (!is.null(vl) && length(vl) > 0 && !is.na(vl[1]) && nzchar(vl[1]) &&
        !identical(as.character(vl[1]), v)) {
      paste0("  ", v, " = ", as.character(vl[1]))
    } else {
      paste0("  ", v)
    }
  }
  block <- character(0)
  if (length(dv_name) == 1L && dv_name %in% names(data)) {
    block <- c(block, "Outcome:", fmt_line(dv_name))
  }
  iv_present <- iv_names[iv_names %in% names(data)]
  if (length(iv_present) > 0L) {
    block <- c(block, "Predictors:",
               vapply(iv_present, fmt_line, character(1), USE.NAMES = FALSE))
  }
  if (length(block) > 0L) {
    cat(paste(block, collapse = "\n"))
    cat("\n\n")
  }
}

#' Internal helper: print a value-label legend block
#'
#' Companion to \code{.print_var_labels} for the \code{value.id} legend modes.
#' Emits one line per variable that carries value labels, in the form
#' \code{varname: code = label, code = label, ...} under a \code{Value Labels:}
#' header, matching the variable-label block's header + indented-lines + blank
#' line structure. One line per variable (locked design); legend lines are not
#' table cells, so they are not width-capped. Variables without value labels
#' contribute nothing; if no variable carries any, nothing is printed.
#'
#' @param data A data frame (or pre-conversion label source) whose columns may
#'   carry value labels (\code{labelled::val_labels}).
#' @param var_names Character vector of variable names to document, in order.
#'
#' @keywords internal
.print_value_labels <- function(data, var_names) {
  label_lines <- c()
  for (v in var_names) {
    if (v %in% names(data)) {
      vls <- labelled::val_labels(data[[v]])
      if (!is.null(vls) && length(vls) > 0L) {
        pairs <- paste0(unname(vls), " = ", names(vls))
        label_lines <- c(label_lines,
                         paste0("  ", v, ": ", paste(pairs, collapse = ", ")))
      }
    }
  }
  if (length(label_lines) > 0) {
    cat("Value Labels:\n")
    cat(paste(label_lines, collapse = "\n"))
    cat("\n\n")
  }
}

#' Internal helper: print variable- and value-label legends (single position)
#'
#' For single-table functions (jt, jaov, jcrosstab) and grouped jdesc, where
#' both \code{"legend"} and \code{"legend.bottom"} resolve to the same place --
#' after the table. Emits one lead-in blank line if either block will print,
#' then the variable-label block first and the value-label block second (the
#' Session 60 ordering lock). Each block supplies its own trailing blank line,
#' so co-located blocks are separated by exactly one blank line. The two blocks
#' can document different variable sets (e.g. jt's variable legend covers DV +
#' group, but only the group carries the value.id legend).
#'
#' @param data Data frame / label source.
#' @param vars_var Variable names for the variable-label block.
#' @param vars_val Variable names for the value-label block.
#' @param vlmode Resolved variable.id mode.
#' @param value_mode Resolved value.id mode.
#' @param lead Logical. Emit the lead-in blank line. Default TRUE. Pass FALSE
#'   when the caller's preceding output already supplies a trailing blank line
#'   (e.g. grouped jdesc, where the last group table emits one).
#'
#' @keywords internal
.jst_print_legends <- function(data, vars_var, vars_val, vlmode, value_mode,
                               lead = TRUE) {
  leg <- c("legend", "legend.bottom")
  vmode_leg   <- vlmode %in% leg
  valmode_leg <- value_mode %in% leg
  if (lead && (vmode_leg || valmode_leg)) cat("\n")
  if (vmode_leg)   .print_var_labels(data, vars_var)
  if (valmode_leg) .print_value_labels(data, vars_val)
}

#' Internal helper: print legends at a specific position (per-table / bottom)
#'
#' For multi-variable functions (jfreq) where \code{"legend"} prints under each
#' variable's own table and \code{"legend.bottom"} prints once after all
#' tables. Called at each position; prints only the block(s) whose mode matches
#' \code{position}. No lead-in blank: the caller's table already emits a
#' trailing blank line. Variable-label block first, value-label block second
#' when both land at the same position; each block's trailing blank line
#' separates co-located blocks.
#'
#' @param data Data frame / label source.
#' @param vars_var Variable names for the variable-label block.
#' @param vars_val Variable names for the value-label block.
#' @param vlmode Resolved variable.id mode.
#' @param value_mode Resolved value.id mode.
#' @param position Either \code{"legend"} or \code{"legend.bottom"}.
#'
#' @keywords internal
.jst_print_legends_at <- function(data, vars_var, vars_val, vlmode, value_mode,
                                  position) {
  if (identical(vlmode, position))     .print_var_labels(data, vars_var)
  if (identical(value_mode, position)) .print_value_labels(data, vars_val)
}

#' Internal helper: combine a variable's name and label per variable.id mode
#'
#' Decouples the \code{variable.id} display decision from how each call site
#' fetches its label. The caller resolves two strings -- the bare \code{name}
#' and a \code{label_or_name} (the variable's label if it has one, otherwise
#' the name, as returned by \code{.jst_label_or_name} or an equivalent
#' closure) -- and this helper combines them according to \code{mode}:
#' \itemize{
#'   \item \code{"labels"}: the label (i.e. \code{label_or_name}).
#'   \item \code{"both"}: \code{"name: label"} when a label exists, else the
#'     bare name. "A label exists" is inferred from \code{label_or_name}
#'     differing from \code{name}; an unlabelled variable (where the two are
#'     equal) collapses to the name, mirroring \code{value.id = "both"}'s
#'     per-variable degrade.
#'   \item \code{"names"}, \code{"legend"}, \code{"legend.bottom"}: the bare
#'     name (legend modes keep the name in place and emit the label
#'     separately via \code{.print_var_labels}).
#' }
#' The colon-space join matches \code{.jst_format_value_labels}'s
#' \code{"both"} form, so a name+label identifier reads identically to a
#' code+label category. \code{cap = TRUE} routes the result through the shared
#' 40-column cap; pass it only for in-table-column surfaces (jdesc/jcorr/jalpha
#' row-label columns), never for title or heading lines.
#'
#' @param name Single character: the bare variable name.
#' @param label_or_name Single character: the label if present, else the name.
#' @param mode One of \code{"both"}, \code{"names"}, \code{"labels"},
#'   \code{"legend"}, \code{"legend.bottom"}.
#' @param cap Logical. Apply the in-table width cap. Default FALSE.
#'
#' @return Single character display string.
#'
#' @keywords internal
.jst_combine_id <- function(name, label_or_name, mode, cap = FALSE) {
  out <- switch(mode,
    labels = label_or_name,
    both   = if (identical(label_or_name, name)) name
             else paste0(name, ": ", label_or_name),
    name)
  if (isTRUE(cap)) .jst_truncate_ellipsis(out) else out
}

#' Internal helper: variable label for display, falling back to the name
#'
#' Used by the \code{"labels"} variable.id mode, where a variable's label
#' replaces its name in table rows, table captions, crosstab dimnames, or
#' (in jplot) axis/legend/facet titles. When the variable carries no
#' non-empty variable label, its name is returned unchanged. This name
#' fallback is the only sensible rendering for an unlabelled variable and
#' is distinct from a mode fallback: \code{"labels"} is still honored
#' literally (no switch to a legend), the label slot simply equals the
#' name.
#'
#' @param data A data frame.
#' @param var Single variable name (character).
#'
#' @return Single character string: the variable's label if present and
#'   non-empty, otherwise \code{var}.
#'
#' @keywords internal
.jst_label_or_name <- function(data, var) {
  if (!is.null(data) && var %in% names(data)) {
    vl <- labelled::var_label(data[[var]])
    if (!is.null(vl) && length(vl) == 1 && !is.na(vl) && nzchar(vl)) {
      return(as.character(vl))
    }
  }
  var
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
#' @param align Optional character vector of alignment codes ("l", "r", "c",
#'   or "d"), one per displayed column. If NULL, auto-detects: numeric = right,
#'   character/other = left. Code "d" is a decimal-tab: data cells are
#'   right-justified (so a uniform decimal-places column aligns on the decimal
#'   point) while the header stays centered over the column.
#' @param caption Optional title string printed above the table.
#' @param indent Number of leading spaces for each data row. Default 0,
#'   so data rows sit flush at column 1, aligned with the caption, header,
#'   and separator (which use \code{header.indent}). Callers that want a
#'   nested/indented sub-table pass a positive value (e.g. \code{indent = 4}).
#' @param header.indent Number of leading spaces for the caption,
#'   header row, and separator row. Defaults to 0. With the default
#'   \code{indent}, header and data share the same left edge; raise one
#'   relative to the other only for special layouts.
#'
#' @keywords internal
.jst_print_table <- function(df, col.names = NULL, row.names = TRUE,
                             align = NULL, caption = NULL, indent = 0,
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
    # "ln" (left, no-trim) columns carry caller-supplied leading whitespace
    # that must count toward the width (otherwise an all-positive column of
    # sign-slot-padded cells would overflow the gap). All other columns are
    # measured trimmed, as before.
    if (identical(align[j], "ln")) {
      data_widths <- nchar(display[, j])
    } else {
      data_widths <- nchar(trimws(display[, j]))
    }
    col_widths[j] <- max(nchar(headers[j]), max(data_widths, 0L, na.rm = TRUE))
  }

  gap    <- "  "
  prefix <- paste(rep(" ", indent), collapse = "")
  header_prefix <- paste(rep(" ", header.indent), collapse = "")

  fmt_cell <- function(text, width, alignment) {
    # "ln" (left, no-trim): left-justify but preserve the caller's leading
    # whitespace (used by jcorr to reserve a sign slot so r decimals line up
    # under a leading minus). Must NOT trim, unlike every other alignment.
    if (identical(alignment, "ln")) {
      return(formatC(text, width = -width, flag = "-"))
    }
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

  # Decimal-tab columns ("d"): right-justify data so a uniform-dp column
  # aligns on the decimal point, while the header stays centered over
  # the column. Resolve "d" here; fmt_cell never sees "d".
  header_align <- ifelse(align == "d", "c", ifelse(align == "ln", "l", align))
  data_align   <- ifelse(align == "d", "r", align)

  # Header
  header_cells <- vapply(seq_len(n_cols), function(j) {
    fmt_cell(headers[j], col_widths[j], header_align[j])
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
      fmt_cell(display[i, j], col_widths[j], data_align[j])
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

#' Internal helper: get the intent registry for a named data frame
#'
#' Looks up the analysis-role intent records stored under the
#' \code{.jst_registry} option for a specific data frame name. This is the
#' general intent notebook for jnumeric()/jcount() registrations; it follows
#' the same session-option, frame-keyed model as \code{.jst_dummy} but is a
#' separate store, so the existing dummy consumers are unaffected. Records are
#' a named list keyed by variable name (lookup and replace are the dominant
#' operations), each a list with at least \code{kind} (one of "numeric" or
#' "count"; the slot is general enough for later facets such as centering).
#'
#' @param data_name Character string giving the data frame name to look up.
#' @return The stored intent records (a named list), or \code{NULL} if none.
#' @keywords internal
.jst_get_registry <- function(data_name) {
  all_reg <- getOption(".jst_registry", default = list())
  all_reg[[data_name]]
}

#' Internal helper: set the intent registry for a named data frame
#'
#' Stores analysis-role intent records under the \code{.jst_registry} option,
#' keyed by data frame name. Used internally by the registration functions
#' (jnumeric, jcount).
#'
#' @param data_name Character string giving the data frame name.
#' @param settings A named list of intent records (keyed by variable name),
#'   or \code{NULL} to clear the registry for this frame.
#' @return \code{invisible(NULL)}. Called for its side effect on the
#'   \code{.jst_registry} option.
#' @keywords internal
.jst_set_registry <- function(data_name, settings) {
  all_reg <- getOption(".jst_registry", default = list())
  all_reg[[data_name]] <- settings
  options(.jst_registry = all_reg)
}

#' Internal helper: look up a single variable's registered intent
#'
#' Returns the intent record for one variable in a named data frame, or
#' \code{NULL} if the variable has no registered intent. Consulted by the
#' classification resolver (tier 2) and by the registration functions.
#'
#' @param data_name Character string giving the data frame name.
#' @param var_name Character string giving the variable name.
#' @return The intent record (a list with at least \code{kind}), or
#'   \code{NULL}.
#' @keywords internal
.jst_get_intent <- function(data_name, var_name) {
  reg <- .jst_get_registry(data_name)
  if (is.null(reg)) return(NULL)
  reg[[var_name]]
}

#' Internal helper: bake classification registrations onto a frame for saving
#'
#' Gathers the active classification registrations for a named data frame --
#' the jnumeric/jcount intent records (the .jst_registry notebook) and the
#' jdummy registrations (the .jst_dummy registry) -- and attaches them to the
#' data frame as a single list-valued attribute (".jst_registrations") so they
#' travel inside an R native format (.rds) save. The original frame name is
#' recorded alongside as provenance only; it is informational and is NOT used
#' as the lookup key on load (jload re-keys under the name the frame is loaded
#' as, which is the name later analysis calls will reference). The attribute is
#' attached only when at least one registration exists, so a frame with none is
#' returned unchanged and saves without the attribute. Only the .rds format
#' carries arbitrary R attributes, so this is called only on the .rds save path.
#'
#' @param data A data frame.
#' @param data_name Character string giving the data frame name to look up in
#'   the two registries.
#' @return The data frame, with a ".jst_registrations" attribute attached when
#'   registrations exist, otherwise unchanged.
#' @keywords internal
.jst_bake_registrations <- function(data, data_name) {
  reg   <- .jst_get_registry(data_name)
  dummy <- .jst_get_dummy(data_name)
  if (is.null(reg) && is.null(dummy)) {
    return(data)
  }
  attr(data, ".jst_registrations") <- list(
    registry = reg,
    dummy    = dummy,
    origin   = data_name
  )
  data
}

#' Internal helper: refresh the registration notebook from a loaded frame
#'
#' On load, makes the session notebook for a frame name match what the file
#' carries (the file is the source of truth at load time). When the loaded
#' object carries baked registrations, they are written into the .jst_registry
#' and .jst_dummy notebooks under the load-time name, replacing any differing
#' in-session registrations already sitting under that name. When the loaded
#' object carries none -- a non-.rds file, an older .rds saved before this
#' feature existed, or freshly unregistered data -- any stale registrations
#' under the reused name are cleared. Returns a one-line note describing what
#' happened (or NULL when nothing changed), for the caller to emit subject to
#' its own quiet setting.
#'
#' @param obj_name Character string giving the name the frame is loaded as
#'   (jload's name= argument, or the file stem) -- the key the analysis
#'   functions will look the frame up by.
#' @param baked The ".jst_registrations" attribute read from the loaded object
#'   (a list with registry, dummy, and origin entries), or NULL when the object
#'   carried none.
#' @return A character note, or NULL when no notebook change was made.
#' @keywords internal
.jst_refresh_registrations <- function(obj_name, baked) {
  existing_reg   <- .jst_get_registry(obj_name)
  existing_dummy <- .jst_get_dummy(obj_name)
  had_existing   <- !is.null(existing_reg) || !is.null(existing_dummy)

  if (is.null(baked)) {
    # Loaded data carries no registrations: clear any stale notebook entry
    # sitting under this reused name. Silent when there was nothing to clear.
    if (had_existing) {
      .jst_set_registry(obj_name, NULL)
      .jst_set_dummy(obj_name, NULL)
      return(paste0(
        "Cleared the classification registrations you had set this session ",
        "for '", obj_name, "' (the loaded data carries none)."))
    }
    return(NULL)
  }

  # Loaded data carries registrations: make the notebook match the file.
  replaced <- had_existing &&
    (!identical(existing_reg, baked$registry) ||
       !identical(existing_dummy, baked$dummy))
  .jst_set_registry(obj_name, baked$registry)
  .jst_set_dummy(obj_name, baked$dummy)

  origin_note <- if (!is.null(baked$origin) &&
                     !identical(baked$origin, obj_name)) {
    paste0(" (saved under '", baked$origin, "')")
  } else {
    ""
  }
  if (replaced) {
    paste0("Restored the classification registrations saved with this file",
           origin_note, ", replacing different registrations you had set ",
           "this session for '", obj_name, "'.")
  } else {
    paste0("Restored the classification registrations saved with this file",
           origin_note, ".")
  }
}

#' Internal helper: note that registrations are not kept in a non-rds format
#'
#' Builds the loss-of-fidelity note emitted when a frame that has active
#' classification registrations is saved to a format other than R native
#' format (.rds). Parallels the label and missing-value loss notes: the data
#' write succeeds, but the registrations are dropped because only the .rds
#' format carries them. Returns NULL when the frame has no registrations, so
#' the note fires only when there is something to lose.
#'
#' @param ext The (lower-case) target file extension.
#' @param data_name Character string giving the data frame name to look up.
#' @return A character note, or NULL when the frame has no registrations.
#' @keywords internal
.jst_jsave_registration_loss_note <- function(ext, data_name) {
  reg   <- .jst_get_registry(data_name)
  dummy <- .jst_get_dummy(data_name)
  if (is.null(reg) && is.null(dummy)) {
    return(NULL)
  }
  paste0(
    "Note: classification registrations (jnumeric/jcount/jdummy) are not ",
    "kept in ", .jst_format_label(ext), " (.", ext, "); they persist only ",
    "in R native format (.rds).")
}

#' Internal helper: human-readable label for a registered intent kind
#'
#' @param kind One of "numeric", "count", "dummy".
#' @param cap Logical; if TRUE, capitalize the first letter.
#' @return A character label.
#' @keywords internal
.jst_intent_label <- function(kind, cap = FALSE) {
  lab <- switch(kind, numeric = "numeric", count = "count",
                dummy = "dummy", likert = "Likert", kind)
  if (isTRUE(cap)) lab <- paste0(toupper(substring(lab, 1, 1)), substring(lab, 2))
  lab
}

#' Internal helper: clear one variable's dummy registration
#'
#' Removes the \code{.jst_dummy} entry for a single variable in a named data
#' frame, used to enforce mutual exclusion when the variable is re-registered
#' as numeric or count. Returns TRUE when an entry was actually removed (so the
#' caller can report the reclassification).
#'
#' @param data_name Character data-frame name.
#' @param var_name Character variable name.
#' @return Logical, invisibly: TRUE if a dummy entry was cleared.
#' @keywords internal
.jst_clear_dummy_var <- function(data_name, var_name) {
  ds <- .jst_get_dummy(data_name)
  if (is.null(ds) || length(ds) == 0) return(invisible(FALSE))
  keep <- !vapply(ds, function(r) identical(r$var_name, var_name), logical(1))
  if (all(keep)) return(invisible(FALSE))
  ds <- ds[keep]
  if (length(ds) == 0) ds <- NULL
  .jst_set_dummy(data_name, ds)
  invisible(TRUE)
}

#' Internal helper: clear one variable's intent-registry record
#'
#' Removes the \code{.jst_registry} record for a single variable in a named
#' data frame. Used by \code{jdummy()} to enforce mutual exclusion (a variable
#' that becomes a dummy drops any numeric/count registration).
#'
#' @param data_name Character data-frame name.
#' @param var_name Character variable name.
#' @return The kind that was cleared (character), or NULL if none, invisibly.
#' @keywords internal
.jst_clear_intent_var <- function(data_name, var_name) {
  reg <- .jst_get_registry(data_name)
  if (is.null(reg) || is.null(reg[[var_name]])) return(invisible(NULL))
  cleared <- reg[[var_name]]$kind
  reg[[var_name]] <- NULL
  if (length(reg) == 0) reg <- NULL
  .jst_set_registry(data_name, reg)
  invisible(cleared)
}

#' Internal helper: names of data frames carrying registrations of one kind
#'
#' Scans the relevant session store and returns the names of the data frames
#' that currently hold at least one registration of the requested kind:
#' \code{.jst_registry} for "numeric"/"count" (a frame qualifies if it has any
#' record of that kind), \code{.jst_dummy} for "dummy" (a frame qualifies if it
#' has any dummy registration). Used by the clear dispatcher to decide, when no
#' frame is named and no default is set, whether a bare clear is unambiguous.
#'
#' @param kind One of "numeric", "count", "dummy".
#' @return Character vector of data-frame names (possibly empty).
#' @keywords internal
.jst_frames_with_registrations <- function(kind) {
  if (identical(kind, "dummy")) {
    all_d <- getOption(".jst_dummy", default = list())
    nm <- names(all_d)[vapply(all_d, function(x) !is.null(x) && length(x) > 0,
                              logical(1))]
    return(if (is.null(nm)) character(0) else nm)
  }
  all_r <- getOption(".jst_registry", default = list())
  keep <- vapply(all_r, function(reg) {
    !is.null(reg) && length(reg) > 0 &&
      any(vapply(reg, function(r) identical(r$kind, kind), logical(1)))
  }, logical(1))
  nm <- names(all_r)[keep]
  if (is.null(nm)) character(0) else nm
}

#' Internal helper: clear one frame's registrations of one kind
#'
#' Removes the requested kind's registrations for a single named data frame and
#' returns the variable names that were cleared (empty when there were none).
#' "dummy" clears the frame's \code{.jst_dummy} entry; "numeric"/"count" remove
#' only the matching-kind records from the frame's \code{.jst_registry} entry,
#' leaving any records of the other kind in place.
#'
#' @param kind One of "numeric", "count", "dummy".
#' @param data_name Character data-frame name.
#' @return Character vector of cleared variable names (possibly empty).
#' @keywords internal
.jst_clear_one_frame <- function(kind, data_name) {
  if (identical(kind, "dummy")) {
    existing <- .jst_get_dummy(data_name)
    if (is.null(existing) || length(existing) == 0) return(character(0))
    cleared <- vapply(existing, function(r) r$var_name, character(1))
    .jst_set_dummy(data_name, NULL)
    return(unname(cleared))
  }
  reg <- .jst_get_registry(data_name)
  if (is.null(reg) || length(reg) == 0) return(character(0))
  is_kind <- vapply(reg, function(r) identical(r$kind, kind), logical(1))
  if (!any(is_kind)) return(character(0))
  cleared <- vapply(reg[is_kind], function(r) r$var_name, character(1))
  reg <- reg[!is_kind]
  if (length(reg) == 0) reg <- NULL
  .jst_set_registry(data_name, reg)
  unname(cleared)
}

#' Internal helper: the registration verb name for a kind
#'
#' @param kind One of "numeric", "count", "dummy".
#' @return The user-facing function name ("jnumeric"/"jcount"/"jdummy").
#' @keywords internal
.jst_clear_verb <- function(kind) {
  switch(kind, numeric = "jnumeric", count = "jcount", dummy = "jdummy",
         paste0("j", kind))
}

#' Internal helper: resolve and perform a registration clear
#'
#' The single decision point for clearing classification registrations, shared
#' by \code{jnumeric()}, \code{jcount()}, and \code{jdummy()} so the three verbs
#' behave identically. Three entry shapes feed it:
#' \itemize{
#'   \item \code{clear.all = TRUE} -- clear this kind on every data frame that
#'         carries it.
#'   \item \code{explicit_frame} set (the \code{verb(data, NULL)} form) -- clear
#'         this kind on that one frame.
#'   \item neither (the \code{verb(NULL)} form) -- clear the \code{juse()}
#'         default frame if one is set; otherwise clear the sole frame carrying
#'         this kind if exactly one does; otherwise stop and ask the user to
#'         name a frame or pass \code{clear.all = TRUE} (never a silent
#'         multi-frame wipe).
#' }
#' Messages are emitted here, not by the callers, so the wording stays uniform.
#'
#' @param kind One of "numeric", "count", "dummy".
#' @param clear.all Logical; clear every frame carrying this kind.
#' @param explicit_frame Character data-frame name for the \code{verb(data,
#'   NULL)} form, or NULL.
#' @param default_name The \code{juse()} default frame name, or NULL.
#' @return \code{invisible(NULL)}.
#' @keywords internal
.jst_handle_clear <- function(kind, clear.all = FALSE, explicit_frame = NULL,
                              default_name = NULL) {
  klab <- .jst_intent_label(kind)
  Klab <- .jst_intent_label(kind, cap = TRUE)

  report_one <- function(frame, cleared, default = FALSE) {
    tag <- if (isTRUE(default)) " (the default data frame)" else ""
    if (length(cleared) == 0) {
      message("No ", klab, " registrations to clear for ", frame, tag, ".")
    } else {
      message(Klab, " registrations cleared for ", frame, tag, ": ",
              paste(cleared, collapse = ", "), ".")
    }
  }

  # clear.all: every frame carrying this kind.
  if (isTRUE(clear.all)) {
    frames <- .jst_frames_with_registrations(kind)
    if (length(frames) == 0) {
      message("No ", klab, " registrations to clear.")
      return(invisible(NULL))
    }
    for (fr in frames) .jst_clear_one_frame(kind, fr)
    message(Klab, " registrations cleared across all data frames (",
            paste(frames, collapse = ", "), ").")
    return(invisible(NULL))
  }

  # verb(data, NULL): clear the named frame only.
  if (!is.null(explicit_frame)) {
    report_one(explicit_frame, .jst_clear_one_frame(kind, explicit_frame))
    return(invisible(NULL))
  }

  # verb(NULL): default frame wins when one is set.
  if (!is.null(default_name)) {
    report_one(default_name, .jst_clear_one_frame(kind, default_name),
               default = TRUE)
    return(invisible(NULL))
  }

  # verb(NULL), no default: clear the sole registered frame, else nothing,
  # else ask rather than wipe several silently.
  frames <- .jst_frames_with_registrations(kind)
  if (length(frames) == 0) {
    message("No ", klab, " registrations to clear.")
    return(invisible(NULL))
  }
  if (length(frames) == 1) {
    report_one(frames, .jst_clear_one_frame(kind, frames))
    return(invisible(NULL))
  }
  verb <- .jst_clear_verb(kind)
  stop(Klab, " registrations exist on more than one data frame: ",
       paste(frames, collapse = ", "), ".\n",
       "Name the one to clear, e.g. ", verb, "(", frames[1], ", NULL), ",
       "or clear them all with ", verb, "(clear.all = TRUE).",
       call. = FALSE)
}

#' Internal helper: shared registration engine for jnumeric() / jcount()
#'
#' Validates the requested variables, then either removes their registrations
#' of the given kind (\code{remove = TRUE}) or writes them, enforcing mutual
#' exclusion: writing a record replaces any prior intent record for that
#' variable (one record per variable in \code{.jst_registry}) and clears any
#' \code{.jst_dummy} registration for it. Any reclassification (a variable that
#' previously carried a different intent or a dummy registration) is reported.
#' A standard-tier reminder notes that registrations are session-only and how
#' to persist them.
#'
#' @param kind One of "numeric", "count".
#' @param data The resolved data frame.
#' @param data_name Character data-frame name (the registry key).
#' @param default_used Logical; whether the \code{juse()} default frame was used.
#' @param var_names Character vector of variable names to register.
#' @param remove Logical; if TRUE, remove rather than write.
#' @return \code{invisible(NULL)}.
#' @keywords internal
.jst_register_intent <- function(kind, data, data_name, default_used,
                                 var_names, remove) {
  .jst_check_vars(data, var_names, data_name)

  if (isTRUE(remove)) {
    reg     <- .jst_get_registry(data_name)
    removed <- character(0)
    for (v in var_names) {
      rec <- if (!is.null(reg)) reg[[v]] else NULL
      if (!is.null(rec) && identical(rec$kind, kind)) {
        reg[[v]] <- NULL
        removed  <- c(removed, v)
      }
    }
    if (!is.null(reg) && length(reg) == 0) reg <- NULL
    .jst_set_registry(data_name, reg)
    if (length(removed) > 0) {
      message(.jst_intent_label(kind, cap = TRUE), " registration removed for ",
              paste0("'", removed, "'", collapse = ", "), " in ", data_name, ".")
    } else {
      message("No ", .jst_intent_label(kind), " registration to remove for ",
              paste0("'", var_names, "'", collapse = ", "), " in ", data_name, ".")
    }
    return(invisible(NULL))
  }

  reg <- .jst_get_registry(data_name)
  if (is.null(reg)) reg <- list()
  reclass <- character(0)
  for (v in var_names) {
    prior <- reg[[v]]
    if (!is.null(prior) && !identical(prior$kind, kind)) {
      reclass <- c(reclass, paste0("'", v, "' (", .jst_intent_label(prior$kind),
                                   " -> ", .jst_intent_label(kind), ")"))
    }
    if (isTRUE(.jst_clear_dummy_var(data_name, v))) {
      reclass <- c(reclass, paste0("'", v, "' (dummy -> ",
                                   .jst_intent_label(kind), ")"))
    }
    reg[[v]] <- list(var_name = v, kind = kind)
  }
  .jst_set_registry(data_name, reg)

  if (isTRUE(default_used)) .jst_default_note(data_name)
  message(.jst_intent_label(kind, cap = TRUE), " registration set for ",
          paste0("'", var_names, "'", collapse = ", "), " in ", data_name, ".")
  if (length(reclass) > 0) {
    message("  Reclassified: ", paste(reclass, collapse = "; "), ".")
  }
  if (!identical(getOption(".jst_output_level", "standard"), "minimal")) {
    message("Registrations are stored for this session only. To keep them ",
            "across sessions, save the data frame in R native format (.rds), ",
            "e.g. jsave(", data_name, ", \"", data_name, ".rds\").")
  }
  invisible(NULL)
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
  # One leading blank separates the message block from the note/title above.
  # With .jst_default_note's default now FALSE (Session 52), this is what
  # keeps a single blank line above pipeline messages.
  if (length(msgs) > 0) cat("\n")
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
  minimal  = list(effect.size = FALSE,
                  regression.ci = FALSE, means.ci = FALSE, levene = FALSE,
                  posthoc = FALSE, diagnostics = FALSE,
                  case.processing = FALSE, case.processing.detail = "none",
                  variable.id = "names", value.id = "labels",
                  ref.categories = FALSE, digits = 3,
                  udm.notice = FALSE),
  standard = list(effect.size = TRUE,
                  regression.ci = FALSE, means.ci = TRUE,  levene = FALSE,
                  posthoc = FALSE, diagnostics = FALSE,
                  case.processing = NULL,  case.processing.detail = "totals",
                  variable.id = "names", value.id = "both",
                  ref.categories = TRUE, digits = 3,
                  udm.notice = NULL),
  full     = list(effect.size = TRUE,
                  regression.ci = TRUE,  means.ci = TRUE,  levene = TRUE,
                  posthoc = TRUE,  diagnostics = TRUE,
                  case.processing = TRUE,  case.processing.detail = "per_code",
                  variable.id = "legend", value.id = "both",
                  ref.categories = TRUE, digits = 3,
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
  data.dir             = NULL,
  corr.layout          = "wide"
)

#' Internal helper: resolve a display toggle value
#'
#' Implements three-tier precedence: (1) explicit per-call argument wins,
#' (2) individual joutput() toggle override, (3) joutput() level default.
#' Per-call arguments use NULL to mean "I didn't specify -- defer to joutput()".
#'
#' @param name Character. Toggle name (e.g. "effect.size", "means.ci", "levene").
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

#' Internal helper: validate and resolve the digits (decimal places) setting
#'
#' Thin wrapper over \code{.jst_resolve_toggle("digits", ...)} that first
#' validates a non-NULL per-call \code{digits} argument: it must be a single
#' whole number in the range 0-7. The resolved value is the number of decimal
#' places shown for continuous tabular statistics; it never governs p-values,
#' case-processing percentages, integer quantities (N, df, counts), or the
#' multicollinearity-warning prose numbers (all fixed by their own
#' conventions). Returns an integer.
#'
#' @param per_call The value of the calling function's \code{digits} argument,
#'   or NULL to defer to joutput().
#'
#' @return Integer in 0-7.
#'
#' @keywords internal
.jst_resolve_digits <- function(per_call) {
  if (!is.null(per_call)) {
    if (length(per_call) != 1L || is.na(per_call) ||
        !is.numeric(per_call) || per_call != as.integer(per_call) ||
        per_call < 0L || per_call > 7L) {
      stop("digits must be a single whole number between 0 and 7.",
           call. = FALSE)
    }
  }
  as.integer(.jst_resolve_toggle("digits", per_call))
}

#' Internal helper: build a decimal-places formatter for continuous stats
#'
#' Returns a function that formats a numeric value to \code{digits} decimal
#' places via \code{sprintf("%.<digits>f")}, preserving base R's half-to-even
#' rounding (the option only changes the number of places, never the rounding
#' rule). \code{digits = 0} yields whole numbers with no trailing decimal
#' point. NA formats to the empty string so it renders as a blank cell.
#'
#' @param digits Integer number of decimal places (0-7).
#'
#' @return A function of one argument (coerced via as.numeric) returning a
#'   character string.
#'
#' @keywords internal
.jst_make_fmt <- function(digits) {
  spec <- paste0("%.", digits, "f")
  function(x) {
    x <- suppressWarnings(as.numeric(x))
    ifelse(is.na(x), "", sprintf(spec, x))
  }
}

#' Internal helper: format a p-value for display
#'
#' Formats one or more p-values to three decimal places following the package
#' convention: the leading zero is dropped (a p cannot exceed 1, so ".045" not
#' "0.045"), values below .001 collapse to the "<.001" floor, and a missing p
#' renders as the empty string (a blank cell) rather than a misleading "<.001"
#' or a stray "NA". Vectorized; used by every analysis function that prints a
#' p-value, matching jcorr's existing treatment. Statistics that can exceed 1
#' (F, t, Wald, chi-square, coefficients, standard errors, confidence-interval
#' bounds) keep their leading zero and are formatted elsewhere -- this helper is
#' for p-values only. The three-decimal precision is fixed and does not follow
#' the digits option (p-values keep their own convention).
#'
#' @param p Numeric vector of p-values (NA allowed).
#'
#' @return Character vector the same length as p.
#'
#' @keywords internal
.jst_fmt_p <- function(p) {
  p <- suppressWarnings(as.numeric(p))
  ifelse(is.na(p), "",
         ifelse(p < 0.001, "<.001",
                sub("^0\\.", ".", sprintf("%.3f", p))))
}

#' Internal helper: validate and resolve the variable.id display mode
#'
#' Thin wrapper over \code{.jst_resolve_toggle("variable.id", ...)} that
#' first validates a non-NULL per-call \code{variable.id} argument against
#' the five-token enum. Every analysis function's \code{variable.id =}
#' argument is a string-only enum (no logical aliases); a bad token errors
#' here with a consistent message rather than silently passing through to the
#' renderer. (\code{variable.id} controls the one-per-variable descriptive
#' label; the distinct \code{value.id} control governs the per-code
#' value-label mapping -- see \code{.jst_resolve_value_id}.)
#'
#' The five tokens parallel \code{value.id}'s: \code{"names"} (bare variable
#' name), \code{"labels"} (the variable label in place of the name),
#' \code{"both"} (\code{"name: label"}), \code{"legend"} (names in the table
#' plus a name->label legend block), \code{"legend.bottom"} (same, legend at
#' the very end).
#'
#' @param per_call The value of the calling function's \code{variable.id}
#'   argument: NULL (defer to joutput()), or one of \code{"both"},
#'   \code{"names"}, \code{"labels"}, \code{"legend"}, \code{"legend.bottom"}.
#'
#' @return Single character token: one of \code{"both"}, \code{"names"},
#'   \code{"labels"}, \code{"legend"}, \code{"legend.bottom"}.
#'
#' @keywords internal
.jst_resolve_variable_id <- function(per_call) {
  if (!is.null(per_call)) {
    if (!is.character(per_call) || length(per_call) != 1 ||
        !(per_call %in% c("both", "names", "labels", "legend", "legend.bottom"))) {
      stop("variable.id must be one of: \"both\", \"names\", \"labels\", ",
           "\"legend\", \"legend.bottom\".", call. = FALSE)
    }
  }
  .jst_resolve_toggle("variable.id", per_call)
}

#' Internal helper: validate and resolve the jcorr correlation-cell layout
#'
#' Resolves the \code{layout} argument of \code{jcorr()} to one of
#' \code{"wide"} or \code{"stacked"}. Unlike the joutput()-backed display
#' toggles, this layout choice is jcorr-specific (the only function that
#' renders composite r / p / N cells), so its global default lives in
#' joptions() rather than joutput(): a per-call value wins, else the
#' \code{corr.layout} joptions slot, else the built-in default of "wide".
#'
#' @param per_call The value of jcorr()'s \code{layout} argument: NULL
#'   (defer to joptions()), or one of \code{"wide"}, \code{"stacked"}.
#'
#' @return Single character token: \code{"wide"} or \code{"stacked"}.
#'
#' @keywords internal
.jst_resolve_corr_layout <- function(per_call) {
  if (!is.null(per_call)) {
    if (!is.character(per_call) || length(per_call) != 1 ||
        !(per_call %in% c("wide", "stacked"))) {
      stop("layout must be one of: \"wide\", \"stacked\".", call. = FALSE)
    }
    return(per_call)
  }
  global <- getOption(".jst_options_corr_layout",
                      .jst_options_defaults$corr.layout)
  if (!is.null(global) && length(global) == 1 &&
      global %in% c("wide", "stacked")) {
    return(global)
  }
  "wide"
}

#' Internal helper: validate and resolve the value.id display mode
#'
#' Thin wrapper over \code{.jst_resolve_toggle("value.id", ...)} that
#' first validates a non-NULL per-call \code{value.id} argument against
#' the supported-token enum. \code{value.id} controls how a categorical
#' variable's per-code value labels surface (code, label, or both) wherever
#' categorical levels appear -- the frequency-table Value column, group
#' headers, crosstab axes. It is distinct from \code{variable.id}, which
#' governs the one-per-variable descriptive label.
#'
#' The five tokens: \code{"both"} (\code{"code: label"}), \code{"values"}
#' (bare code), \code{"labels"} (the value label, degrading to the bare code
#' per code where none exists), \code{"legend"} (bare codes in the table plus
#' a code->label legend block), \code{"legend.bottom"} (same, legend at the
#' very end). The legend modes keep the in-table category column compact when
#' value labels are long, mirroring \code{variable.id}'s legend modes.
#'
#' @param per_call The value of the calling function's \code{value.id}
#'   argument: NULL (defer to joutput()), or one of \code{"both"},
#'   \code{"values"}, \code{"labels"}, \code{"legend"}, \code{"legend.bottom"}.
#' @param allowed Character vector of the value.id modes the calling function
#'   accepts. Defaults to the full set; \code{jlm()} and \code{jlogistic()}
#'   pass the reduced set (\code{"both"}, \code{"values"}, \code{"labels"}) so
#'   the "must be one of" message advertises only what they support, matching
#'   their separate rejection of the legend modes.
#'
#' @return Single character token: one of \code{"both"}, \code{"values"},
#'   \code{"labels"}, \code{"legend"}, \code{"legend.bottom"}.
#'
#' @keywords internal
.jst_resolve_value_id <- function(per_call,
                                  allowed = c("both", "values", "labels",
                                              "legend", "legend.bottom")) {
  if (!is.null(per_call)) {
    if (!is.character(per_call) || length(per_call) != 1 ||
        !(per_call %in% allowed)) {
      stop("value.id must be one of: ",
           paste0("\"", allowed, "\"", collapse = ", "), ".", call. = FALSE)
    }
  }
  .jst_resolve_toggle("value.id", per_call)
}

#' Internal helper: format categorical levels under a value.id mode
#'
#' Shared formatter that maps stored codes (plus their value labels, if any)
#' to display strings under the active \code{value.id} mode. Every surface
#' where categorical levels appear -- jfreq valid rows, jt/jaov group headers,
#' jcrosstab axes, grouped jdesc group headers -- routes its code/label display
#' through this one helper so the modes behave identically across functions and
#' the per-code degrade logic lives in a single place.
#'
#' Degrades per CODE, not per variable: \code{"labels"} shows the label where
#' one exists, otherwise that bare code; \code{"both"} shows \code{"code: label"}
#' where a label exists, otherwise the bare code (so a variable with no value
#' labels at all collapses to bare codes -- the emergent whole-variable
#' behaviour). \code{"values"} always shows the bare stored code. The two
#' legend modes (\code{"legend"}, \code{"legend.bottom"}) render bare codes
#' in-table exactly like \code{"values"} -- the code->label mapping is emitted
#' separately as a legend block by the calling function (see
#' \code{.print_value_labels}). Plain numeric (unlabelled) variables therefore
#' render identically under every mode, so value.id is a no-op for them.
#'
#' In-table content is capped to a display-width ceiling via
#' \code{.jst_truncate_ellipsis} (shared 40-column cap). This bites only under
#' \code{"both"}/\code{"labels"} where a long value label would otherwise widen
#' the category column for every row; bare codes are short and unaffected. The
#' cap is applied here, in the formatting layer, so the (already-capped) string
#' is what reaches \code{.jst_print_table} -- the printer stays width-agnostic.
#'
#' Works for both numeric-backed and character-backed haven_labelled variables:
#' codes are compared as character on both sides, so string codes (e.g.
#' "US"/"UK") are never coerced to numeric.
#'
#' @param codes Vector of stored values (numeric or character), one per level
#'   or per row. NA entries (system-missing) map to NA in the output.
#' @param val_labels Named vector as returned by \code{labelled::val_labels()}
#'   (names are the labels, values are the codes), or NULL / length-0 when the
#'   variable carries no value labels.
#' @param mode One of \code{"both"}, \code{"values"}, \code{"labels"},
#'   \code{"legend"}, \code{"legend.bottom"}. The legend modes behave as
#'   \code{"values"} for the returned in-table vector.
#'
#' @return Character vector parallel to \code{codes}.
#'
#' @keywords internal
.jst_format_value_labels <- function(codes, val_labels, mode = "both") {
  codes_chr <- as.character(codes)
  lookup <- if (!is.null(val_labels) && length(val_labels) > 0L) {
    stats::setNames(names(val_labels), as.character(unname(val_labels)))
  } else {
    character(0)
  }
  lab       <- unname(lookup[codes_chr])
  has_label <- !is.na(lab) & nzchar(lab)
  out <- switch(mode,
    values         = codes_chr,
    legend         = codes_chr,
    legend.bottom  = codes_chr,
    labels = ifelse(has_label, lab, codes_chr),
    both   = ifelse(has_label, paste0(codes_chr, ": ", lab), codes_chr),
    stop("Unknown value.id mode: ", mode, call. = FALSE))
  # Cap in-table width (no-op for bare-code output; bites long labels only).
  out <- vapply(out, .jst_truncate_ellipsis, character(1), USE.NAMES = FALSE)
  out[is.na(codes)] <- NA_character_
  out
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

  # System/NA = genuine system-missing cells (NA in the raw data), counted
  # separately from the declared-UDM rows above so each missing cell is counted
  # exactly once. For Stata-form, exclude tagged NAs (those are the per-tag rows
  # above). For the SPSS/no-mi branch, count is.na() on the UNCLASSED column: a
  # live haven_labelled_spss reports its na_values cells as NA under is.na(),
  # and those cells were already counted in the code/range rows above, so
  # is.na(pre_col) would double-count them. unclass() drops the class that
  # triggers that flagging, leaving only true system-missing (and is a harmless
  # no-op for plain numeric / factor / character / non-spss labelled columns).
  if (!is.null(mi) && identical(mi$representation, "stata")) {
    sys_src  <- sum(is.na(pre_col)  & is.na(haven::na_tag(pre_col)))
    sys_pool <- sum(is.na(pool_col) & is.na(haven::na_tag(pool_col)))
  } else {
    sys_src  <- sum(is.na(unclass(pre_col)))
    sys_pool <- sum(is.na(unclass(pool_col)))
  }
  if (sys_src > 0L || sys_pool > 0L) {
    rows <- rbind(rows, data.frame(code_label = .jst_label_system_missing,
                                   src = sys_src, pool = sys_pool,
                                   stringsAsFactors = FALSE))
  }
  rows
}

#' Internal helper: truncate a string to a display-width cap with ellipsis
#'
#' Single source of truth for the package's table-cell width cap. A string
#' wider than \code{max_width} display columns is cut to \code{max_width - 1}
#' columns and given a trailing ellipsis character; shorter strings are
#' returned unchanged. Display width is measured with
#' \code{nchar(type = "width")} so double-width characters are counted
#' correctly. The default 40-column cap is shared across every in-table label
#' surface -- CPS pipeline detail (via \code{.jst_cps_cap_label}), jfreq value
#' labels and grouped headers, jdesc/jcorr variable-identifier columns -- so a
#' future change to the cap is made in this one place. Title and heading lines
#' (which sit on their own line with no column to share) are never routed
#' through this helper.
#'
#' @param content Character scalar (coerced; first element used).
#' @param max_width Integer display-column cap. Default 40.
#'
#' @return Single character string, capped to \code{max_width} columns.
#'
#' @keywords internal
.jst_truncate_ellipsis <- function(content, max_width = 40L) {
  content <- as.character(content)[1L]
  if (is.na(content)) return(content)
  if (nchar(content, type = "width") <= max_width) return(content)
  paste0(substr(content, 1L, max_width - 1L), "\u2026")
}

#' Internal helper: cap a pipeline-row label's parenthetical content for CPS
#'
#' Keeps the Case-Processing top table readable when a long jcomplete()
#' variable set or a jsubset()/subset = expression would otherwise blow out
#' the dynamic column width. Two modes:
#'   "list" -- a character vector of names (jcomplete's complete_vars). With
#'             more than max_items entries, returns the first max_items
#'             followed by ", +N more". The full set stays visible via
#'             jcomplete()'s own status query.
#'   "expr" -- a single expression string (filter_expr / subset_expr).
#'             Truncated to max_width display columns with a trailing
#'             ellipsis when longer.
#' Returns the (possibly shortened) content only; the caller supplies the
#' operation prefix, e.g. sprintf("jcomplete (%s)", ...). Display width is
#' measured with nchar(type = "width"), matching the renderer's dw().
#' @keywords internal
.jst_cps_cap_label <- function(content, mode = c("list", "expr"),
                               max_items = 2L, max_width = 40L) {
  mode <- match.arg(mode)
  if (mode == "list") {
    content <- as.character(content)
    n <- length(content)
    if (n <= max_items) return(paste(content, collapse = ", "))
    sprintf("%s, +%d more",
            paste(content[seq_len(max_items)], collapse = ", "),
            n - max_items)
  } else {
    .jst_truncate_ellipsis(content, max_width = max_width)
  }
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

    # Width of the widest rendered table; sizes the closing rule (Session 52).
    rule_w <- 0L

    # ---- TOP TABLE: pipeline chain ----
    if (isTRUE(spec$render_top)) {
      labels <- "Original"; detail <- ""
      surv_v <- n_original; exc_v <- NA_integer_
      prior  <- n_original

      if (isTRUE(sample_info$complete_active) &&
          !is.null(sample_info$n_after_complete)) {
        det <- if (!is.null(sample_info$complete_vars) &&
                   length(sample_info$complete_vars))
                 .jst_cps_cap_label(sample_info$complete_vars, mode = "list")
               else ""
        labels <- c(labels, "jcomplete"); detail <- c(detail, det)
        exc_v  <- c(exc_v, prior - sample_info$n_after_complete)
        surv_v <- c(surv_v, sample_info$n_after_complete)
        prior  <- sample_info$n_after_complete
      }
      if (isTRUE(sample_info$filter_active) &&
          !is.null(sample_info$n_after_filter)) {
        det <- if (!is.null(sample_info$filter_expr) &&
                   nzchar(sample_info$filter_expr))
                 .jst_cps_cap_label(sample_info$filter_expr, mode = "expr")
               else ""
        labels <- c(labels, "jsubset"); detail <- c(detail, det)
        exc_v  <- c(exc_v, prior - sample_info$n_after_filter)
        surv_v <- c(surv_v, sample_info$n_after_filter)
        prior  <- sample_info$n_after_filter
      }
      if (!is.null(sample_info$n_after_subset)) {
        det <- if (!is.null(sample_info$subset_expr) &&
                   nzchar(sample_info$subset_expr))
                 .jst_cps_cap_label(sample_info$subset_expr, mode = "expr")
               else ""
        labels <- c(labels, "subset ="); detail <- c(detail, det)
        exc_v  <- c(exc_v, prior - sample_info$n_after_subset)
        surv_v <- c(surv_v, sample_info$n_after_subset)
        prior  <- sample_info$n_after_subset
      }
      if (isTRUE(spec$show_auto_listwise)) {
        labels <- c(labels, "Auto-listwise"); detail <- c(detail, "")
        exc_v  <- c(exc_v, sample_info$n_excluded_missing)
        surv_v <- c(surv_v, n_analysis)
        prior  <- n_analysis
      }
      labels <- c(labels, spec$endpoint_label); detail <- c(detail, "")
      exc_v  <- c(exc_v, NA_integer_)
      surv_v <- c(surv_v, prior)

      # Column widths sized to content (display width) so the multibyte
      # em-dash aligns. Pipeline detail (jcomplete variables, jsubset /
      # subset = expressions) renders as an UNHEADED trailing column after
      # Remaining, so Excluded/Remaining sit in a stable position no matter
      # how long or numerous the variable names are. Title flush-left (indent
      # 0); data rows indented 4. (Session 52: dropped "% Surviving", renamed
      # "Surviving" -> "Remaining". Session 57: pipeline detail moved to the
      # trailing column; .jst_cps_cap_label truncation retained as a line-
      # length guard only.)
      exc_strs  <- vapply(seq_along(labels), function(i)
                     if (is.na(exc_v[i])) dash else as.character(exc_v[i]),
                     character(1))
      surv_strs <- as.character(surv_v)
      h_ind <- 0L; r_ind <- 4L
      lab_end <- max(h_ind + dw("Case Processing"), r_ind + max(dw(labels)))
      exc_w  <- max(dw("Excluded"),  max(dw(exc_strs)))
      surv_w <- max(dw("Remaining"), max(dw(surv_strs)))
      g <- "  "

      cat("\n")
      cat(strrep(" ", h_ind), padr("Case Processing", lab_end - h_ind), g,
          padl("Excluded", exc_w), g, padl("Remaining", surv_w),
          "\n", sep = "")
      for (i in seq_along(labels)) {
        det_str <- if (nzchar(detail[i])) paste0(g, detail[i]) else ""
        cat(strrep(" ", r_ind), padr(labels[i], lab_end - r_ind), g,
            padl(exc_strs[i], exc_w), g, padl(surv_strs[i], surv_w),
            det_str, "\n", sep = "")
      }
      base_w  <- lab_end + exc_w + surv_w + 4L
      det_ext <- if (any(nzchar(detail)))
                   2L + max(dw(detail[nzchar(detail)])) else 0L
      rule_w  <- max(rule_w, base_w + det_ext)
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

        h_ind <- 0L; c_ind <- 6L
        lab_end <- max(h_ind + dw("Missing-data breakdown"),
                       c_ind + max(dw(all_lab)))
        # The "From N" header defines each count column's width; the count
        # value-block is sized to the widest count in that column and centred
        # within the column (counts right-justified within the block). Percent
        # columns keep their right-justified rendering. (Session 52.)
        src_count_w  <- max(dw(all_src))
        pool_count_w <- max(dw(all_pool))
        srcn_w  <- max(dw(src_hdr),  src_count_w)
        pooln_w <- max(dw(pool_hdr), pool_count_w)
        pct_w   <- max(dw("%"), max(dw(all_srcp), dw(all_plp)))
        g <- "  "

        # Centre a count under its header: right-justify within the value
        # block, then centre that block within the column width.
        ctr_count <- function(x, block_w, col_w) {
          s     <- padl(x, block_w)
          extra <- max(0L, col_w - block_w)
          left  <- extra %/% 2L
          paste0(strrep(" ", left), s, strrep(" ", extra - left))
        }

        # Build each row as one string and strip trailing whitespace before
        # printing, so header and label-only rows carry no trailing blanks
        # (Session 52). centre_counts = FALSE on the header keeps the "From N"
        # labels right-justified, since they define the column width.
        emit <- function(indent, lab, lab_w, c1, p1, c2, p2,
                         centre_counts = TRUE) {
          c1_cell <- if (centre_counts) ctr_count(c1, src_count_w, srcn_w)
                     else padl(c1, srcn_w)
          line <- paste0(strrep(" ", indent), padr(lab, lab_w), g,
                         c1_cell, g, padl(p1, pct_w))
          if (two_cols) {
            c2_cell <- if (centre_counts) ctr_count(c2, pool_count_w, pooln_w)
                       else padl(c2, pooln_w)
            line <- paste0(line, g, c2_cell, g, padl(p2, pct_w))
          }
          cat(sub("[ ]+$", "", line), "\n", sep = "")
        }

        cat("\n")
        emit(h_ind, "Missing-data breakdown", lab_end - h_ind,
             src_hdr, "%", pool_hdr, "%", centre_counts = FALSE)
        for (d in disp) {
          cat(strrep(" ", 4L), d$var, "\n", sep = "")
          for (j in seq_len(nrow(d$rows))) {
            sc <- d$rows$src[j]; pl <- d$rows$pool[j]
            emit(c_ind, d$rows$code_label[j], lab_end - c_ind,
                 as.character(sc), fmt1(sc / n_original * 100),
                 as.character(pl), fmt1(pl / n_pool * 100))
          }
        }

        bottom_w <- if (two_cols)
                      lab_end + srcn_w + pooln_w + 2L * pct_w + 8L
                    else
                      lab_end + srcn_w + pct_w + 4L
        rule_w <- max(rule_w, bottom_w)
      }
    }
    if (rule_w > 0L) {
      cat("\n", strrep("\u2500", rule_w), "\n", sep = "")
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
#'   \item Per-call \code{override}: "categorical" -> TRUE; "numeric" or
#'         "count" -> FALSE (a count is numeric-like for the categorical-vs-
#'         numeric decision this helper answers). NULL falls through.
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
#' @param override Optional per-call asserted role for \code{x}: one of
#'   "categorical", "numeric", or "count" (or NULL for no override). When
#'   supplied it takes precedence over registration and structure, matching
#'   the tier-1 per-call slot in the classification resolver.
#' @return TRUE if the user has declared the variable categorical,
#'   FALSE otherwise.
#' @keywords internal
.jst_is_categorical <- function(x, var_name = NULL, data_name = NULL,
                                override = NULL) {

  # -- Rule 0: per-call override (highest priority) ------------------------
  if (!is.null(override)) {
    if (identical(override, "categorical")) return(TRUE)
    if (override %in% c("numeric", "count")) return(FALSE)
  }

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


#' Internal helper: a labelled variable's surviving (non-missing) value labels
#'
#' Returns the value labels of a haven-labelled column with every code that is
#' declared missing removed, so the scale-detection helpers judge a variable on
#' its real response options rather than on missing-value sentinels mixed into
#' the label set. Declared-missing codes are read through the central
#' \code{.jst_missing_info()} reader, so SPSS-style \code{na_values} and
#' \code{na_range} declarations and Stata-/SAS-style tagged NAs are all handled
#' in one place. (A 1-to-5 agreement item carrying a Refused code of -99 and a
#' Don't-know code of -98 as declared missings therefore yields the five real
#' scale points, not seven codes with a gap.)
#'
#' @param col A variable / data-frame column.
#' @return A named numeric vector of surviving value labels (names are the
#'   label texts, values the codes), or \code{NULL} if the column is not
#'   labelled or has no value labels. Length 0 if every label is a declared
#'   missing.
#' @keywords internal
.jst_surviving_value_labels <- function(col) {
  if (!haven::is.labelled(col)) return(NULL)
  vl <- labelled::val_labels(col)
  if (is.null(vl) || length(vl) == 0L) return(NULL)

  codes <- suppressWarnings(as.numeric(unname(vl)))
  keep  <- !is.na(codes)                 # drops tagged-NA labels (Stata / SAS)

  mi <- .jst_missing_info(col)
  if (!is.null(mi)) {
    if (!is.null(mi$codes) && nrow(mi$codes) > 0L) {
      na_num <- mi$codes$numeric[!is.na(mi$codes$numeric)]
      if (length(na_num) > 0L) keep <- keep & !(codes %in% na_num)
    }
    if (!is.null(mi$na_range) && length(mi$na_range) == 2L) {
      lo <- min(mi$na_range); hi <- max(mi$na_range)
      keep <- keep & !(codes >= lo & codes <= hi)
    }
  }
  vl[keep]
}


#' Internal helper: a labelled variable's normalized non-missing label set
#'
#' The set of surviving (non-missing) value-label texts, trimmed and case-
#' folded, sorted and de-duplicated. This is the unit the Likert battery test
#' compares between adjacent columns: two columns belong to the same battery
#' when their normalized label sets are equal, regardless of which code each
#' label is mapped to (so a reverse-keyed sibling, which shares the same answer
#' words on a flipped code mapping, still matches).
#'
#' @param col A variable / data-frame column.
#' @return A character vector (sorted, unique, lower-cased, trimmed) of the
#'   surviving label texts, or \code{character(0)}.
#' @keywords internal
.jst_nonmissing_label_set <- function(col) {
  surv <- .jst_surviving_value_labels(col)
  if (is.null(surv) || length(surv) == 0L) return(character(0))
  txt <- names(surv)
  txt <- txt[!is.na(txt)]
  txt <- trimws(tolower(txt))
  sort(unique(txt[nzchar(txt)]))
}


# .jst_likert_anchor_families
#
# The maintained list of ordered scale families used by the anchor branch of
# .jst_is_likert. Each entry is the pair of opposite pole WORDS for one family;
# a column fires the anchor test when BOTH pole words of any family appear as
# whole tokens among its (non-missing) label texts. Matching is on whole tokens
# (labels split on non-letters and case-folded), so an intensity modifier rides
# along for free -- "Strongly Disagree" tokenizes to {strongly, disagree} and
# is caught by the "disagree" pole without listing "strongly" here, and the two
# poles are distinct tokens ("disagree" is not "agree"; "dissatisfied" is not
# "satisfied"), so a one-pole-only scale does not fire. English-centric by
# design; a non-English scale is reached through the battery test or declared
# with jlikert(). Deliberately small and easily extended. (Session 87)
.jst_likert_anchor_families <- list(
  agreement    = c("agree",     "disagree"),
  satisfaction = c("satisfied", "dissatisfied"),
  frequency    = c("never",     "always"),
  likelihood   = c("likely",    "unlikely"),
  quality      = c("poor",      "excellent")
)


#' Internal helper: do a variable's labels carry a recognised scale anchor pair?
#'
#' The column-local (single-item) half of the Likert sufficient discriminator.
#' Tokenizes the supplied label texts (split on non-letters, case-folded) and
#' returns TRUE when both pole words of any family in
#' \code{.jst_likert_anchor_families} are present. Because it tests for the
#' PRESENCE of both poles, it is reverse-coding-agnostic (the direction of the
#' code mapping is irrelevant). English-centric.
#'
#' @param label_texts Character vector of label texts (typically the surviving,
#'   non-missing labels of a column).
#' @return TRUE if a recognised anchor pair is present, FALSE otherwise.
#' @keywords internal
.jst_labels_match_anchor <- function(label_texts) {
  if (length(label_texts) == 0L) return(FALSE)
  toks <- unlist(strsplit(tolower(label_texts), "[^a-z]+"))
  toks <- unique(toks[nzchar(toks)])
  if (length(toks) == 0L) return(FALSE)
  for (fam in .jst_likert_anchor_families) {
    if (all(fam %in% toks)) return(TRUE)
  }
  FALSE
}


#' Internal helper: does a column sit in a contiguous Likert battery?
#'
#' The sibling-aware half of the Likert sufficient discriminator. A column is
#' part of a battery when at least one IMMEDIATELY ADJACENT column (the one to
#' its left or right in data-frame column order) shares its normalized non-
#' missing label set (see \code{.jst_nonmissing_label_set()}). Adjacency uses
#' the column's position in the named frame fetched by \code{data_name}; the
#' run breaks at the first neighbour with a different label set, so an adjacent
#' same-size nominal or a different-scale battery is naturally excluded. Two
#' matching columns are enough (a run of length 2 or more). Category count plays
#' no part -- the match is on the answer-word set, not the number of categories.
#'
#' The frame is fetched by name from the global environment (and the attached
#' search path); when \code{var_name} or \code{data_name} is absent, the named
#' object is not a data frame, the column is not found in it, or the column has
#' no surviving labels, the test returns FALSE and the caller falls back to the
#' anchor branch. A battery member therefore needs the resolver to have been
#' given the variable and frame identity (jscreen always supplies both); a bare
#' \code{.jst_is_likert(x)} relies on anchors alone. The name-based fetch can
#' miss when the frame is local to a calling function rather than global, a
#' tolerated gap: anchors still carry English scales and \code{jlikert()} is
#' always available.
#'
#' @param col The column under test.
#' @param var_name Character string naming the column, or NULL.
#' @param data_name Character string naming the data frame, or NULL.
#' @return TRUE if the column is part of an adjacent same-label-set run of
#'   length 2 or more, FALSE otherwise.
#' @keywords internal
.jst_in_likert_battery <- function(col, var_name = NULL, data_name = NULL) {
  if (is.null(var_name) || is.null(data_name)) return(FALSE)

  df <- get0(data_name, envir = globalenv(), inherits = TRUE, ifnotfound = NULL)
  if (is.null(df) || !is.data.frame(df)) return(FALSE)

  nms <- names(df)
  pos <- match(var_name, nms)
  if (is.na(pos)) return(FALSE)

  this_set <- .jst_nonmissing_label_set(col)
  if (length(this_set) == 0L) return(FALSE)

  neighbours <- integer(0)
  if (pos > 1L)           neighbours <- c(neighbours, pos - 1L)
  if (pos < length(nms))  neighbours <- c(neighbours, pos + 1L)

  for (j in neighbours) {
    nb_set <- .jst_nonmissing_label_set(df[[j]])
    if (length(nb_set) > 0L && setequal(this_set, nb_set)) return(TRUE)
  }
  FALSE
}


#' Internal helper: does a variable look like a Likert (ordered scale) item?
#'
#' The single detector for the "Likert" Categorical sub-class. Detection is in
#' two stages: a NECESSARY structural gate, then a SUFFICIENT discriminator that
#' separates a real ordered scale from a labelled nominal that happens to share
#' the same shape (the hard case the v1 consecutive-only detector could not tell
#' apart).
#'
#' Necessary structure (all must hold):
#' \enumerate{
#'   \item The variable is haven-labelled with at least one value label.
#'   \item Its SURVIVING value labels -- the labelled codes left after declared
#'         missing values are removed (SPSS-style \code{na_values} /
#'         \code{na_range}, Stata-/SAS-style tagged NAs), read through
#'         \code{.jst_missing_info()} -- are whole numbers forming a consecutive
#'         run (no gaps) of length 3 to 7. Removing the missing sentinels first
#'         is what lets a 1-to-5 item carrying a Refused code of -99 and a
#'         Don't-know code of -98 read as a clean 5-point scale rather than
#'         seven codes with a gap. A two-code variable is a dichotomy (handled
#'         earlier); 8 or more surviving codes is treated as continuous.
#'   \item Every value present in the data (declared missings excluded, which
#'         \code{is.na()} already flags on \code{labelled_spss} and tagged-NA
#'         columns) is one of the surviving scale points. An UNDECLARED sentinel
#'         (e.g. a literal -99 never declared missing) is therefore NOT silently
#'         absorbed: its presence fails the test, leaving the load-time coded-
#'         missing scan to nudge the user to declare it.
#' }
#'
#' Sufficient discriminator (Likert if EITHER fires):
#' \itemize{
#'   \item ANCHORS -- the surviving labels contain both pole words of a
#'         recognised ordered family (see \code{.jst_likert_anchor_families}),
#'         matched on whole tokens. Column-local, so it catches a lone item;
#'         reverse-coding-agnostic; English-centric.
#'   \item BATTERY -- the column sits in a contiguous run of adjacent columns
#'         sharing the same normalized non-missing label set (see
#'         \code{.jst_in_likert_battery()}). Language-agnostic; needs the
#'         resolver to carry the variable and frame identity.
#' }
#' Category count plays no role in either branch -- matching on count would re-
#' admit the very property a nominal shares with a battery.
#'
#' This is display/reporting scoped: a TRUE result refines the Categorical sub-
#' class to "Likert" but never changes a variable's analysis class or how
#' analyses treat it. The detector does not have to be perfect: a non-English
#' lone scale with no recognised anchor, or a scattered (non-adjacent) battery,
#' is not auto-detected and is declared with \code{jlikert()}; a labelled
#' nominal whose labels happen to carry an anchor pair could still read
#' "Likert", a tolerated cosmetic call given the sub-class carries no analysis
#' consequence.
#'
#' Because this is called only from the Categorical branch of
#' \code{.jst_class_from_role()}, it is reached structurally only for variables
#' already routed to Categorical (<= 6 categories), so the auto-detected range
#' is 3 to 6 in practice. A 7-point labelled scale resolves to Numeric
#' structurally (the Numeric/Categorical boundary is unchanged) and must be
#' declared with \code{jlikert()}.
#'
#' @param x A variable / data-frame column.
#' @param var_name Optional variable name; with \code{data_name}, lets the
#'   battery branch locate the column among its siblings.
#' @param data_name Optional data-frame name; with \code{var_name}, names the
#'   frame the battery branch fetches to read adjacent columns.
#' @return TRUE if the variable is detected as a Likert (ordered labelled
#'   scale) item, FALSE otherwise.
#' @keywords internal
.jst_is_likert <- function(x, var_name = NULL, data_name = NULL) {
  if (!haven::is.labelled(x)) return(FALSE)

  # -- Necessary structure: surviving codes form a consecutive integer run ----
  surv <- .jst_surviving_value_labels(x)
  if (is.null(surv) || length(surv) == 0L) return(FALSE)

  codes <- suppressWarnings(as.numeric(unname(surv)))
  if (any(is.na(codes)) || any(codes != floor(codes))) return(FALSE)
  codes_sorted <- sort(unique(codes))
  n_codes <- length(codes_sorted)
  if (n_codes < 3L || n_codes > 7L) return(FALSE)
  if (any(diff(codes_sorted) != 1)) return(FALSE)

  # Every present value (declared missings already dropped by is.na()) must be
  # one of the surviving scale points.
  xn      <- .jst_as_numeric(x)
  present <- xn[!is.na(x)]
  present <- present[!is.na(present)]
  if (length(present) == 0L) return(FALSE)
  if (!all(present %in% codes_sorted)) return(FALSE)

  # -- Sufficient discriminator: anchors (column-local) OR battery (siblings) -
  if (.jst_labels_match_anchor(names(surv))) return(TRUE)
  if (.jst_in_likert_battery(x, var_name, data_name)) return(TRUE)

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


#' Internal helper: recognized affirmative/negative token matcher
#'
#' Given the two distinct category strings of a text dichotomy, decides
#' whether they form a recognized affirmative/negative pair and, if so,
#' which is the affirmative (the event modeled as 1) and which is the
#' negative (the reference, 0). Matching is case-insensitive and ignores
#' surrounding whitespace. The recognized vocabulary is:
#' \itemize{
#'   \item affirmative: yes, y, true, t, present, success
#'   \item negative:    no, n, false, f, absent, failure
#' }
#' A pair is recognized only when exactly one category is affirmative and
#' the other is negative, so two affirmatives (e.g. "yes"/"true") or an
#' unrecognized pair (e.g. "high"/"low") return \code{recognized = FALSE}.
#' The caller supplies the original-cased strings; the returned
#' \code{event} and \code{reference} echo them unchanged for display.
#'
#' Used by jlogistic() to coerce a recognized text/factor response to 0/1
#' with a known, announced direction, rather than letting glm() pick the
#' event by alphabetical level order (which silently models the wrong
#' category for pairs like high/low). See the DV-resolution block in
#' jlogistic().
#'
#' @param cats Character vector of length 2: the two distinct category
#'   strings, original casing preserved.
#' @return A list with elements \code{recognized} (logical),
#'   \code{event} (the affirmative category string, or NA), and
#'   \code{reference} (the negative category string, or NA).
#' @keywords internal
.jst_match_binary_tokens <- function(cats) {

  affirmative <- c("yes", "y", "true", "t", "present", "success")
  negative    <- c("no",  "n", "false", "f", "absent",  "failure")

  norm   <- tolower(trimws(as.character(cats)))
  is_aff <- norm %in% affirmative
  is_neg <- norm %in% negative

  if (sum(is_aff) == 1L && sum(is_neg) == 1L) {
    return(list(recognized = TRUE,
                event       = cats[is_aff][1],
                reference   = cats[is_neg][1]))
  }

  list(recognized = FALSE, event = NA_character_, reference = NA_character_)
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
#' Registered intent overrides the structural rules ("Rule A"). When the
#' variable has been registered as a count via \code{jcount()}, or a per-call
#' \code{override = "count"} is supplied, this helper returns TRUE regardless
#' of the structural range checks, so a conceptual count outside the 0-6 band
#' (e.g. a 0-30 victimization tally a user has declared a count) still routes
#' to the count branch. Identity (\code{var_name} + \code{data_name}) is
#' required to consult the registration; without it the helper is purely
#' structural, as before.
#'
#' @param x A variable (vector).
#' @param var_name Optional variable name (with \code{data_name}) used to
#'   consult a \code{jcount()} registration.
#' @param data_name Optional data-frame name (with \code{var_name}) used to
#'   consult a \code{jcount()} registration.
#' @param override Optional per-call asserted role; \code{"count"} forces TRUE
#'   (the per-call counterpart of a \code{jcount()} registration).
#' @return TRUE if the variable is an asserted count, or looks like a
#'   small-range count structurally; FALSE otherwise.
#' @keywords internal
.jst_is_count <- function(x, var_name = NULL, data_name = NULL,
                          override = NULL) {

  # -- Rule A: an asserted count (per-call override or jcount registration)
  # wins over the structural range rules, catching conceptual counts that
  # sit outside the structural 0-6 band.
  if (identical(override, "count")) return(TRUE)
  if (!is.null(var_name) && !is.null(data_name)) {
    intent <- .jst_get_intent(data_name, var_name)
    if (!is.null(intent) && identical(intent$kind, "count")) return(TRUE)
  }

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


#' Internal helper: map an asserted analysis role to class + subclass
#'
#' Shared by the classification resolver's user-intent tiers (per-call
#' override and registered intent) so an asserted role produces the same
#' class/subclass pair however it was asserted. "numeric" and "count" fix the
#' subclass; "categorical" still takes its dichotomy / N-category / identifier
#' subclass from the data structure, since the role assertion fixes the class
#' but not the category count. ("identifier" is a text/factor categorical whose
#' every non-missing value is distinct -- a cosmetic sub-class only; the
#' variable is still Categorical for all analysis purposes.)
#'
#' @param role One of "numeric", "count", "categorical".
#' @param x The variable (used only to derive the categorical subclass).
#' @param var_name Optional variable name; passed through to the Likert battery
#'   detector so it can locate the variable among its siblings.
#' @param data_name Optional data-frame name; passed through to the Likert
#'   battery detector so it can read adjacent columns.
#' @return A list with \code{class} and \code{subclass}, or \code{NULL} if
#'   \code{role} is not recognized.
#' @keywords internal
.jst_class_from_role <- function(role, x, var_name = NULL, data_name = NULL) {
  if (identical(role, "numeric"))
    return(list(class = "Numeric", subclass = ""))
  if (identical(role, "count"))
    return(list(class = "Numeric", subclass = "Count"))
  if (identical(role, "likert"))
    return(list(class = "Categorical", subclass = "Likert"))
  # A user-declared dummy (jdummy). A dichotomy is a special case of a dummy and
  # keeps its own "dichotomy" sub-class (with the existing "*" recode marker and
  # User-declared Source where they apply); a variable with more than two
  # categories declared as a dummy gets the registration-only "<N>-cat dummy"
  # sub-class (e.g. "5-cat dummy"), carrying the category count in short form.
  # Registration asserts dummy intent, so the Likert/identifier auto-detectors
  # are skipped. Display-only -- still Categorical for every analysis purpose;
  # the structural classifier never emits "<N>-cat dummy". (Session 88)
  if (identical(role, "dummy")) {
    if (.jst_is_dichotomy(x)$is_dichotomy)
      return(list(class = "Categorical", subclass = "dichotomy"))
    n_unique <- length(unique(x[!is.na(x)]))
    return(list(class = "Categorical", subclass = paste0(n_unique, "-cat dummy")))
  }
  if (identical(role, "categorical")) {
    if (.jst_is_dichotomy(x)$is_dichotomy)
      return(list(class = "Categorical", subclass = "dichotomy"))
    # Likert: a value-labelled ordered response scale (consecutive run of 3-7
    # labelled codes; every data value a labelled point). A display/reporting
    # refinement only -- still Categorical for every analysis purpose; surfaces
    # in jscreen's Sub-class column. Reached structurally only for variables
    # already routed to Categorical (<= 6 categories), so 3-6 auto-detect; a
    # 7-point scale resolves Numeric structurally and needs jlikert(). The
    # registered/per-call "likert" role above asserts it directly. Detection is
    # the two-stage anchor/battery test; var_name/data_name let the battery
    # branch see sibling columns. (Session 86; redesign Session 87)
    if (.jst_is_likert(x, var_name, data_name))
      return(list(class = "Categorical", subclass = "Likert"))
    n_unique <- length(unique(x[!is.na(x)]))
    # Identifier: a text/factor categorical whose every non-missing value is
    # distinct (e.g. a respondent ID). Cosmetic sub-class only -- the variable
    # stays Categorical for every analysis and screening purpose; only the
    # displayed sub-class changes from "<n>-category" to "identifier". Gated to
    # character/factor backing (an all-distinct numeric resolves to Numeric, so
    # never reaches here) and to 7+ distinct values, so a tiny all-distinct text
    # column is not labeled an identifier. (Session 83)
    n_present <- sum(!is.na(x))
    if ((is.character(x) || is.factor(x)) &&
        n_unique > 6L && n_unique == n_present)
      return(list(class = "Categorical", subclass = "identifier"))
    return(list(class = "Categorical", subclass = paste0(n_unique, "-category")))
  }
  NULL
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
#' value variable, "Likert" for a value-labelled ordered scale (a consecutive
#' run of 3-7 surviving labelled codes plus an anchor-or-battery discriminator;
#' structural detection or a jlikert() assertion), "identifier" for a
#' text/factor variable whose every non-
#' missing value is distinct (7+ values; a respondent ID is the typical case),
#' else "N-category" (e.g. "4-category") from the count of distinct non-missing
#' values. The "Likert" and "identifier" labels are display refinements: such a variable is still
#' Categorical for every analysis and screening purpose. The boundary between Numeric and Categorical
#' is exactly the package's existing rule: a dichotomy (any coding), a
#' factor / logical / character, a haven-labelled variable with <= 6
#' categories, or a whole-number 0-6 numeric is Categorical; everything else
#' numeric-ish (continuous numeric, or labelled with 7+ categories) is
#' Numeric. The Numeric subclass "Count" is registration-only (set via jcount,
#' or the per-call override "count"); the structural classifier never emits it.
#' The Categorical subclass "<N>-cat dummy" (e.g. "5-cat dummy") is likewise
#' registration-only -- set via jdummy() on a variable with more than two
#' categories; the structural classifier never emits it, and a dichotomy
#' declared via jdummy() keeps its "dichotomy" subclass, a dichotomy being a
#' special case of a dummy.
#'
#' Resolution stack (highest wins; first tier that yields a class short-
#' circuits). Storage-determined edge kinds (date-time, numbers-as-text,
#' unsupported) resolve structurally up front and are not role-assertion
#' targets, so the user tiers operate only among Numeric, Categorical, and
#' Count: (1) per-call \code{override} -> source "per-call"; (2) registered
#' intent -- the \code{.jst_registry} notebook (jnumeric/jcount) and the
#' \code{.jst_dummy} registry (jdummy -> categorical) -> source "registered";
#' (3) SPSS measure -- designed but UNPOPULATED in v1, ignored; (4) structural
#' guess -> source "structural". Identity (\code{var_name} + \code{data_name})
#' is required to consult tiers 1-2; when omitted, the resolver returns the
#' structural answer with source "structural", so a bare
#' \code{.jst_jstats_class(x)} behaves as before but now also reports a source.
#'
#' @param x A variable / data-frame column.
#' @param var_name Optional character string naming the variable; required
#'   (with \code{data_name}) to consult registered intent.
#' @param data_name Optional character string naming the data frame; required
#'   (with \code{var_name}) to consult registered intent.
#' @param override Optional per-call asserted role ("numeric", "categorical",
#'   or "count"); highest-priority tier when supplied.
#' @return A list with \code{class} (character), \code{subclass} (character,
#'   "" when none), and \code{source} (one of "per-call", "registered",
#'   "measure", "structural").
#' @keywords internal
.jst_jstats_class <- function(x, var_name = NULL, data_name = NULL,
                              override = NULL) {
  k <- .jst_var_kind(x)

  # Storage-determined edge kinds are resolved structurally up front. They are
  # not role-assertion targets (a date column is converted, not declared), so
  # override / registration never apply to them.
  if (k$kind == "datetime")
    return(list(class = "Date-time",       subclass = "", source = "structural"))
  if (k$kind == "numeric_text")
    return(list(class = "Numbers-as-text", subclass = "", source = "structural"))
  if (k$kind %in% c("complex", "raw", "list", "other"))
    return(list(class = "Unsupported",     subclass = "", source = "structural"))

  # -- Tier 1: per-call override -------------------------------------------
  if (!is.null(override)) {
    res <- .jst_class_from_role(override, x, var_name, data_name)
    if (!is.null(res)) return(c(res, list(source = "per-call")))
  }

  # -- Tier 2: registered intent -------------------------------------------
  # Numeric/count live in the .jst_registry notebook; categorical lives in the
  # existing .jst_dummy registry. Both keyed by frame name + variable.
  if (!is.null(var_name) && !is.null(data_name)) {
    intent <- .jst_get_intent(data_name, var_name)
    if (!is.null(intent) && !is.null(intent$kind)) {
      res <- .jst_class_from_role(intent$kind, x, var_name, data_name)
      if (!is.null(res)) return(c(res, list(source = "registered")))
    }
    dummy_regs <- .jst_get_dummy(data_name)
    if (!is.null(dummy_regs) && length(dummy_regs) > 0) {
      is_registered <- any(vapply(dummy_regs,
                                  function(r) identical(r$var_name, var_name),
                                  logical(1)))
      if (is_registered)
        return(c(.jst_class_from_role("dummy", x, var_name, data_name),
                 list(source = "registered")))
    }
  }

  # -- Tier 3: SPSS measure -- designed but UNPOPULATED in v1 (skipped). ----

  # -- Tier 4: structural guess --------------------------------------------
  # Numeric-ish (numeric / labelled / logical / numeric_factor) or text
  # categorical (text_factor / text_character). Decide Numeric vs Categorical
  # with the same helpers the analysis gate and the outlier-skip use.
  dich   <- .jst_is_dichotomy(x)
  is_cat <- k$kind %in% c("text_factor", "text_character") ||
            is.factor(x) || is.logical(x) ||
            dich$is_dichotomy ||
            .jst_is_discrete_integer(x)

  if (!is_cat) return(list(class = "Numeric", subclass = "", source = "structural"))

  c(.jst_class_from_role("categorical", x, var_name, data_name), list(source = "structural"))
}


#' Internal helper: is a variable's Numeric role user-asserted?
#'
#' TRUE when the classification resolver places the variable in the Numeric
#' class (continuous or the Count subclass) via a NON-structural source -- a
#' per-call override (numeric=/count=) or a registration (jnumeric/jcount).
#' Used by the analysis functions to suppress the structural "seems
#' categorical" hedge: that hedge is only a guess, and a user who has
#' asserted a numeric role has already answered it. A structural (inferred)
#' Numeric, or any Categorical (including a jdummy-asserted one), returns
#' FALSE so the hedge fires as before -- the jdummy/jcorr/jdesc interaction
#' is deliberately left to its own (parked) design.
#'
#' @param x A variable / data-frame column.
#' @param var_name Optional variable name (with \code{data_name}) for
#'   consulting a registration.
#' @param data_name Optional data-frame name (with \code{var_name}) for
#'   consulting a registration.
#' @param override Optional per-call asserted role ("numeric", "count", or
#'   "categorical").
#' @return Logical scalar.
#' @keywords internal
.jst_role_asserted_numeric <- function(x, var_name = NULL, data_name = NULL,
                                       override = NULL) {
  res <- .jst_jstats_class(x, var_name, data_name, override = override)
  !identical(res$source, "structural") && identical(res$class, "Numeric")
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
#' \code{!} (NOT), \code{xor()} (XOR), and `%in%`. Using \code{=} for
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

#' Internal helper: build and render the jcomplete deletion preview
#'
#' Constructs the row-level preview of what \code{jcomplete()}'s listwise
#' deletion will drop and renders it. Reuses the masked analysis copy
#' (SPSS-form UDMs already set to NA) so the preview reflects exactly what
#' the filter excludes (Cross-cutting 5). The display frame carries a leading
#' \code{Row} column (original position, as \code{which()} gives), the
#' registered variables (non-integer numerics rounded to 1 dp for display
#' only; integer-valued columns left untouched), and a trailing
#' \code{DeletionCheck} flag (1 for rows the filter will drop).
#'
#' The viewer (RStudio data tab) and the console listing are controlled
#' independently by the caller (\code{viewer} and \code{console}); each shows
#' only what is asked for. The viewer shows either the deleted rows only or all
#' cases (\code{show_all}); the console always shows deleted rows only, capped,
#' so it cannot flood the console. The console listing also serves as the
#' automatic fallback when the viewer was requested but no interactive viewer
#' is available.
#'
#' @param masked Analysis copy with SPSS-form UDMs masked to NA.
#' @param variable_names Character vector of the registered variables.
#' @param show_all Logical. If \code{TRUE}, the viewer shows every case;
#'   otherwise only the rows scheduled for deletion. Does not affect the
#'   console output, which is always deleted-rows-only.
#' @param console Logical or numeric. \code{FALSE} (default) prints nothing to
#'   the console; \code{TRUE} prints the first 10 deleted rows; a number prints
#'   that many. Independent of \code{viewer}.
#' @param viewer Logical. If \code{TRUE} (and the session is interactive),
#'   open the data viewer. Independent of \code{console}.
#' @param data_name Character. The data frame name, used in the viewer title
#'   and the fallback messages.
#'
#' @return Invisibly, the data frame shown in the viewer.
#'
#' @keywords internal
.jst_jcomplete_preview <- function(masked, variable_names, show_all = FALSE,
                                   console = FALSE, viewer = TRUE,
                                   data_name = NULL) {

  sub       <- masked[, variable_names, drop = FALSE]
  drop_flag <- !stats::complete.cases(sub)
  n_total   <- nrow(sub)

  # Display copy: strip haven class and round non-integer numerics to 1 dp
  # (display only). Already-integer and non-numeric columns are left as-is.
  # The filter itself is unaffected -- drop_flag came from `masked`.
  disp <- sub
  for (v in variable_names) {
    base <- unclass(disp[[v]])
    if (is.numeric(base)) {
      num    <- as.numeric(base)
      non_na <- num[!is.na(num)]
      if (length(non_na) && any(abs(non_na - round(non_na)) > 1e-8)) {
        num <- round(num, 1)
      }
      disp[[v]] <- num
    } else {
      disp[[v]] <- as.character(base)
    }
  }

  build <- function(idx) {
    data.frame(
      Row           = idx,
      disp[idx, , drop = FALSE],
      DeletionCheck = as.integer(drop_flag[idx]),
      row.names        = NULL,
      check.names      = FALSE,
      stringsAsFactors = FALSE
    )
  }

  viewer_idx <- if (isTRUE(show_all)) seq_len(n_total) else which(drop_flag)
  viewer_df  <- build(viewer_idx)
  deleted_df <- build(which(drop_flag))

  # -- Viewer (default surface) ---------------------------------------------
  title <- if (!is.null(data_name)) paste0("jcomplete preview: ", data_name)
           else "jcomplete preview"
  viewer_ok <- FALSE
  if (isTRUE(viewer) && interactive()) {
    # Prefer RStudio's docked data viewer: it opens as a Source-pane tab and
    # refreshes in place on a stable title, rather than stacking windows.
    # utils::View() is deliberately NOT called directly -- the utils:: prefix
    # bypasses RStudio's interception and opens base R's standalone viewer
    # window, which the OS places independently of the IDE. Fall back to that
    # base viewer only when not running under RStudio.
    view_fn <- if ("tools:rstudio" %in% search()) {
      tryCatch(get("View", envir = as.environment("tools:rstudio")),
               error = function(e) utils::View)
    } else {
      utils::View
    }
    viewer_ok <- tryCatch({ view_fn(viewer_df, title); TRUE },
                          error = function(e) FALSE)
  }

  # -- Console (independent of the viewer; also the no-viewer fallback) ------
  console_n <- if (isTRUE(console)) 10L
               else if (is.numeric(console) && length(console) == 1L &&
                        !is.na(console) && console >= 1) as.integer(console)
               else 0L
  want_console <- console_n > 0L
  # Fallback: the viewer was requested but could not open (no interactive
  # session) and the caller did not separately ask for console output.
  fallback     <- isTRUE(viewer) && !viewer_ok && !want_console

  if (want_console || fallback) {
    n_show <- if (want_console) console_n else 10L
    .cat_red("jcomplete Preview \u2014 rows scheduled for deletion\n")
    if (nrow(deleted_df) == 0L) {
      cat("  No cases will be dropped",
          " (no missing values on the registered variables).\n", sep = "")
    } else {
      .jst_print_table(utils::head(deleted_df, n_show), row.names = FALSE)
      if (nrow(deleted_df) > n_show) {
        more <- if (!fallback)
          " Use preview = TRUE to see them all in the viewer." else ""
        cat("\n  Showing the first ", n_show, " of ", nrow(deleted_df),
            " dropped rows.", more, "\n", sep = "")
      }
    }
    if (fallback) {
      message("(The preview viewer needs an interactive RStudio session; ",
              "showing the first ", n_show, " in the console instead.)")
    }
  }

  invisible(viewer_df)
}

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
#' @param preview Logical. If \code{TRUE}, open a viewer (RStudio data tab)
#'   showing the rows the listwise filter will drop, with a leading
#'   \code{Row} column (original data position) and a trailing
#'   \code{DeletionCheck} flag (1 = the row will be dropped). May be used on
#'   its own to preview the already-set filter without re-listing the
#'   variables (\code{jcomplete(preview = TRUE)}). Default \code{FALSE}.
#' @param console Logical or numeric. Print the dropped rows to the console.
#'   \code{TRUE} prints the first 10; a number prints that many. Independent of
#'   \code{preview}: on its own it prints to the console without opening the
#'   viewer; combine with \code{preview = TRUE} to get both. The console
#'   listing is always limited to the dropped rows so it cannot flood the
#'   console. Default \code{FALSE}.
#' @param non.deletes Logical. If \code{TRUE}, the viewer shows every case
#'   (with \code{DeletionCheck} marking which will drop) rather than only the
#'   dropped rows. Affects the viewer only; the console listing stays
#'   deleted-rows-only. Default \code{FALSE}.
#'
#' @return Invisibly returns \code{NULL}. When a preview is requested,
#'   invisibly returns the previewed data frame instead, so it can be
#'   captured (e.g. \code{jcomplete_rows <- jcomplete(preview = TRUE)}).
#'
#' @examples
#' \donttest{
#' juse(mtcars)
#' jcomplete(mpg, hp, wt, am)
#' jdesc(mpg)                     # Uses only complete cases on those 4 vars
#' jcomplete(mpg, hp, wt, am, preview = TRUE)     # Set and preview together
#' jcomplete(preview = TRUE)      # Preview the already-set filter (viewer)
#' jcomplete(preview = TRUE, non.deletes = TRUE)  # Viewer shows all cases
#' jcomplete(console = 10)        # Console only -- first 10 dropped rows
#' jcomplete(preview = TRUE, console = 25)        # Viewer and console
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
jcomplete <- function(data, ..., preview = FALSE, console = FALSE,
                      non.deletes = FALSE) {

  default_name <- getOption(".jst_default_data", default = NULL)

  # Any preview surface requested? console and non.deletes both imply the
  # viewer, so any of the three turns the preview on.
  .preview_on <- isTRUE(preview) || isTRUE(non.deletes) || isTRUE(console) ||
    (is.numeric(console) && length(console) == 1L && !is.na(console) &&
       console >= 1)

  # A negative console value is meaningless; flag it rather than silently
  # treating it as "off" (0 / FALSE turn the console off; TRUE or a positive
  # number show that many dropped rows).
  if (is.numeric(console) && length(console) == 1L && !is.na(console) &&
      console < 0) {
    stop("`console` must be TRUE or a positive number of rows to show ",
         "(0 or FALSE turns it off); got ", console, ".", call. = FALSE)
  }

  # -- No arguments: print session-wide status ------------------------------
  # Session-wide to match jcomplete(NULL). Collapse rule: 0 or 1 frame on a
  # single line (the single active frame appends a live complete-case count
  # when the data frame is reachable from the caller); 2+ frames render a
  # header plus one indented line per frame, with the juse() default marked.
  if (missing(data) && ...length() == 0) {
    reg <- getOption(".jst_complete", default = list())
    reg <- reg[!vapply(reg, is.null, logical(1))]

    # Preview an already-registered filter without re-listing variables.
    if (.preview_on) {
      if (length(reg) == 0L) {
        message("No jcomplete filter set. ",
                "Run jcomplete(var1, var2, ...) first.")
        return(invisible(NULL))
      }
      target <- default_name
      if (is.null(target) || is.null(reg[[target]])) {
        if (length(reg) == 1L) {
          target <- names(reg)[1L]
        } else {
          message("Multiple jcomplete filters are set and no juse() default ",
                  "is active; set a default with juse() to choose which to ",
                  "preview.")
          return(invisible(NULL))
        }
      }
      cs          <- reg[[target]]
      calling_env <- parent.frame()
      if (!exists(target, envir = calling_env)) {
        message("Data frame ", target,
                " is not reachable here to build the preview.")
        return(invisible(NULL))
      }
      df         <- get(target, envir = calling_env)
      valid_vars <- cs$vars[cs$vars %in% names(df)]
      if (length(valid_vars) == 0L) {
        message("None of the registered variables are present in ",
                target, ".")
        return(invisible(NULL))
      }
      masked <- .jst_apply_declared_udms_as_na(
        df[, valid_vars, drop = FALSE])$data
      return(.jst_jcomplete_preview(masked, valid_vars,
                                    show_all  = isTRUE(non.deletes),
                                    console   = console,
                                    viewer    = isTRUE(preview) ||
                                                isTRUE(non.deletes),
                                    data_name = target))
    }

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

  # Optional row-level preview of what the filter will drop. `masked` and
  # `variable_names` are already computed above for the summary, so the
  # preview reflects exactly the same complete-case logic.
  if (.preview_on) {
    pv <- .jst_jcomplete_preview(masked, variable_names,
                                 show_all  = isTRUE(non.deletes),
                                 console   = console,
                                 viewer    = isTRUE(preview) ||
                                             isTRUE(non.deletes),
                                 data_name = .jst_data_name)
    return(invisible(pv))
  }

  invisible(NULL)
}


#' Internal helper: render a dummy coding-scheme table
#'
#' Single source of truth for the 0/1 dummy coding-scheme table shown by
#' \code{jdummy()} -- on registration, on display-only inspection, and in the
#' no-argument registration overview. Prints the identity-pattern table with
#' the reference category starred, the reference footnote, and, when there are
#' more than five categories and \code{show} is not "all", the truncation note.
#' The caller prints the "Dummy Coding Scheme:" header before calling this.
#'
#' @param codes The category codes (numeric or character) in display order.
#' @param labels The category labels parallel to \code{codes}.
#' @param ref_idx Integer index of the reference category within \code{codes}.
#' @param show The caller's \code{show} argument; "all" (any case) shows every
#'   category, otherwise the first five.
#'
#' @return \code{invisible(NULL)}. Called for its printed side effect.
#'
#' @keywords internal
.jst_print_dummy_scheme <- function(codes, labels, ref_idx, show) {
  n_cats   <- length(codes)
  show_all <- is.character(show) && tolower(show) == "all"
  n_show   <- if (show_all) n_cats else min(n_cats, 5)

  all_col_names <- character(n_show)
  for (i in seq_len(n_show)) {
    all_col_names[i] <- if (i == ref_idx) paste0(labels[i], "*") else labels[i]
  }

  row_labels <- character(n_show)
  for (i in seq_len(n_show)) {
    row_labels[i] <- if (i == ref_idx) {
      paste0(codes[i], ": ", labels[i], "*")
    } else {
      paste0(codes[i], ": ", labels[i])
    }
  }

  scheme <- matrix(0L, nrow = n_show, ncol = n_show)
  for (i in seq_len(n_show)) scheme[i, i] <- 1L
  scheme_df <- as.data.frame(scheme, stringsAsFactors = FALSE)
  names(scheme_df)    <- all_col_names
  rownames(scheme_df) <- row_labels

  .jst_print_table(scheme_df,
                   col.names     = all_col_names,
                   row.names     = TRUE,
                   indent        = 4,
                   header.indent = 4)

  cat("\n    * Reference category\n")
  if (n_cats > 5 && !show_all) {
    cat("    (Showing first 5 of ", n_cats,
        " categories \u2014 use show = \"all\" for complete table)\n", sep = "")
  }
  invisible(NULL)
}


# -- jdummy -------------------------------------------------------------------

#' Register categorical variables for dummy coding in regression
#'
#' @description
#' \code{jdummy()} registers a categorical variable so that \code{jlm()}
#' automatically expands it into dummy (indicator) variables when it appears
#' in a regression formula. The original data frame is never modified. Several
#' variables can be registered in one call; the \code{ref} setting then applies
#' to each of them.
#'
#' Registrations are stored per dataset, so switching \code{juse()} between
#' datasets preserves each dataset's registrations independently.
#'
#' @param data A data frame, or omit to use the \code{juse()} default.
#'   \code{jdummy(NULL)} clears the dummy registrations on the \code{juse()}
#'   default data frame (or, with no default set, the only frame that carries
#'   them; if several do, it asks rather than wiping all).
#' @param ... One or more unquoted variable names to register. Omit (along
#'   with data) to display all current registrations. A lone \code{NULL} in the
#'   variable slot -- \code{jdummy(data, NULL)} -- clears that frame's dummy
#'   registrations.
#' @param ref The reference category (excluded from the regression model).
#'   Can be a numeric code, a quoted label name, or \code{first}
#'   (default) or \code{last}. Applied to every variable named in the call;
#'   to use different reference categories, register the variables in
#'   separate calls.
#' @param show Logical. If \code{TRUE}, prints the dummy coding scheme
#'   table showing the pattern of 0s and 1s. Default is \code{FALSE}.
#' @param remove Logical. If \code{TRUE}, removes the registration for
#'   the specified variable(s). Default is \code{FALSE}.
#' @param clear.all Logical. If \code{TRUE}, clears dummy registrations on
#'   every data frame that carries them. Default is \code{FALSE}.
#'
#' @return Invisibly returns \code{NULL}. Called for its side effect.
#'
#' @examples
#' \donttest{
#' juse(mtcars)
#' jdummy(cyl)                          # Register, first category as reference
#' jdummy(cyl, gear)                    # Register several at once
#' jdummy(cyl, ref = "last")            # Last category as reference
#' jdummy(cyl, ref = 6)                 # Reference by numeric code
#' # For haven-labelled variables, use the label name:
#' # jdummy(Employment, ref = "Part-Time")
#' jdummy(cyl, show = TRUE)             # Show coding scheme
#' jdummy(cyl, show = "all")            # Full scheme (for many categories)
#' jdummy()                             # Show all registrations
#' jdummy(cyl, remove = TRUE)           # Remove one registration
#' jdummy(mtcars, NULL)                 # Clear mtcars' dummy registrations
#' jdummy(NULL)                         # Clear the default frame's (or ask)
#' jdummy(clear.all = TRUE)             # Clear every frame's dummy registrations
#' }
#'
#' @seealso \code{\link{JeffsStatTools}} for the package overview,
#'   workflow conventions, and complete function listing.
#'
#' @export
jdummy <- function(data, ..., ref = "first", show = FALSE,
                   remove = FALSE, clear.all = FALSE) {

  default_name <- getOption(".jst_default_data", default = NULL)

  # jdummy(clear.all = TRUE): clear dummy registrations on every frame.
  if (isTRUE(clear.all)) return(.jst_handle_clear("dummy", clear.all = TRUE))

  # -- jdummy() — no arguments: session-wide registration status ------------
  # Session-wide to match jdummy(NULL). Collapse rule: 1 frame renders the
  # full per-registration block (with optional coding scheme via show=);
  # 2+ frames render a header plus one concise line per frame (registered
  # variable names), with the juse() default marked. jdummy holds a list of
  # registrations per frame and has no active/inactive toggle, so there is
  # no off/on state to show here (unlike jsubset / jcomplete).
  if (missing(data) && ...length() == 0L) {
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
        cat("\n  Dummy Coding Scheme:\n\n")
        .jst_print_dummy_scheme(regn$codes, regn$labels, regn$ref_idx, show)
      }
      cat("\n")
    }
    return(invisible(NULL))
  }

  # -- Capture substitute BEFORE any evaluation ------------------------------
  # Needed for the literal-NULL detection idiom and for the helper call.
  raw_data <- if (!missing(data)) substitute(data) else NULL

  # -- jdummy(NULL) — clear the default frame (or sole/ask) -----------------
  # "data supplied AND substituted expression is NULL" detects the literal
  # jdummy(NULL) call. No longer an all-frames wipe: it clears the juse()
  # default frame if one is set, else the sole registered frame, else asks --
  # use jdummy(clear.all = TRUE) for every frame. Unified with jnumeric(NULL)/
  # jcount(NULL) via the shared dispatcher.
  if (!missing(data) && is.null(raw_data)) {
    return(.jst_handle_clear("dummy", default_name = default_name))
  }

  # -- Resolve the first argument via the standard helper -------------------
  # Three modes possible at this point:
  #   explicit            : jdummy(SampleData, A, B)        - data is a frame
  #   default             : jdummy(, A, B)                  - leading-comma form
  #   symbol_with_default : jdummy(A, B)                    - bare-symbol form
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

  # -- Collect variable names (multivariable) -------------------------------
  # jdummy accepts one or more variables. In symbol_with_default mode the first
  # argument is itself a variable (data came from the juse() default), so fold
  # it back in ahead of the dots -- the same pattern jnumeric()/jcount() use.
  # ref/show/remove sit after the dots and are therefore always named, which
  # removes the need for the old positional-argument guard.
  variables <- rlang::enquos(...)
  if (arg1$mode == "symbol_with_default") {
    extra_quo <- rlang::new_quosure(arg1$first_arg_sub, env = parent.frame())
    variables <- c(list(extra_quo), variables)
    class(variables) <- "quosures"
  }
  var_names <- if (length(variables) > 0L) {
    unname(vapply(variables, rlang::quo_name, character(1)))
  } else {
    character(0)
  }

  # -- jdummy(data, NULL) -- per-dataset clear ------------------------------
  # A lone NULL in the variable slot clears this dataset's registrations,
  # matching jnumeric(data, NULL) / jcount(data, NULL). The default/sole/ask
  # form jdummy(NULL) is handled earlier and never reaches this point.
  if (identical(var_names, "NULL")) {
    return(.jst_handle_clear("dummy", explicit_frame = .jst_data_name))
  }

  # No usable variable: data supplied but no variable named.
  if (length(var_names) == 0L) {
    stop("jdummy(): no variable supplied. ",
         "Use jdummy(VarName) to register, jdummy(VarName, remove = TRUE) ",
         "to remove, jdummy(VarName = NULL) to clear this frame, ",
         "or jdummy(clear.all = TRUE) to clear every frame.",
         call. = FALSE)
  }

  .jst_check_vars(data, var_names, .jst_data_name)

  # -- jdummy(var, show = ...) on an already-registered var: display only ----
  # Single-variable inspection convenience: naming one already-registered
  # variable with show = ... but no ref = ... displays the existing scheme
  # without re-registering (which would clobber a non-default reference).
  # With two or more variables the call always registers.
  if (length(var_names) == 1L && !identical(show, FALSE) &&
      missing(ref) && !remove) {
    var_name <- var_names[1L]
    ds <- .jst_get_dummy(.jst_data_name)
    if (!is.null(ds)) {
      existing_idx <- which(vapply(ds, function(r) r$var_name == var_name,
                                   logical(1)))
      if (length(existing_idx) > 0) {
        reg <- ds[[existing_idx[1]]]

        .cat_red("Dummy Variable Registration\n")
        if (.jst_default_used) .jst_default_note(.jst_data_name, extra_newline = TRUE)
        cat("  Variable: ", reg$var_name, " (", reg$var_type, ")\n", sep = "")
        cat("  Reference category: ", reg$ref_label, "\n", sep = "")
        cat("  Dummy variables: ", paste(reg$dummy_names, collapse = ", "),
            "\n", sep = "")
        cat("  Cases: ", reg$n_total, " (", reg$n_missing, " missing)\n",
            sep = "")

        cat("\n  Dummy Coding Scheme:\n\n")
        .jst_print_dummy_scheme(reg$codes, reg$labels, reg$ref_idx, show)
        cat("\n")
        return(invisible(NULL))
      }
    }
    # No existing registration -- fall through to register-and-display.
  }

  # -- jdummy(..., remove = TRUE) -- remove registrations -------------------
  if (remove) {
    ds      <- .jst_get_dummy(.jst_data_name)
    removed <- character(0)
    if (!is.null(ds)) {
      drop    <- vapply(ds, function(r) r$var_name %in% var_names, logical(1))
      removed <- vapply(ds[drop], function(r) r$var_name, character(1))
      ds      <- ds[!drop]
      if (length(ds) == 0) ds <- NULL
      .jst_set_dummy(.jst_data_name, ds)
    }
    if (length(removed) > 0) {
      message("Dummy registration removed for ",
              paste0("'", removed, "'", collapse = ", "), " in ",
              .jst_data_name, ".")
    } else {
      message("No dummy registration to remove for ",
              paste0("'", var_names, "'", collapse = ", "), " in ",
              .jst_data_name, ".")
    }
    return(invisible(NULL))
  }

  # -- Register one or more variables ---------------------------------------
  # The red header and the juse() default note print once; each variable then
  # gets its own block. The standard-tier persist reminder prints once after
  # all registrations, and any deferred naming warnings are emitted last so
  # they carry full context. (Session 82: multivariable + persist reminder.)
  .cat_red("Dummy Variable Registration\n")
  if (.jst_default_used) .jst_default_note(.jst_data_name, extra_newline = TRUE)

  deferred <- character(0)
  for (var_name in var_names) {
    col   <- data[[var_name]]
    built <- .jst_make_dummy_names(col, var_name, ref = ref)

    n_total   <- length(col)
    n_missing <- sum(is.na(col))

    # Informational notes from the helper (e.g. labels not descriptive).
    for (n in built$notes) cat(n, "\n", sep = "")

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
    existing_idx <- which(vapply(ds, function(r) r$var_name == var_name,
                                 logical(1)))
    if (length(existing_idx) > 0) {
      ds[[existing_idx[1]]] <- reg
    } else {
      ds[[length(ds) + 1]] <- reg
    }
    .jst_set_dummy(.jst_data_name, ds)

    # Mutual exclusion: becoming a dummy drops any numeric/count intent so the
    # .jst_dummy and .jst_registry stores stay disjoint per variable.
    .cleared_kind <- .jst_clear_intent_var(.jst_data_name, var_name)
    if (!is.null(.cleared_kind)) {
      message("Reclassified: '", var_name, "' (",
              .jst_intent_label(.cleared_kind), " -> dummy).")
    }

    cat("  Variable: ", var_name, " (", built$var_type, ")\n", sep = "")
    cat("  Reference category: ", built$ref_label, "\n", sep = "")
    cat("  Dummy variables: ", paste(built$dummy_names, collapse = ", "),
        "\n", sep = "")
    cat("  Cases: ", n_total, " (", n_missing, " missing)\n", sep = "")

    if (!identical(show, FALSE)) {
      cat("\n  Dummy Coding Scheme:\n\n")
      .jst_print_dummy_scheme(built$codes, built$labels, built$ref_idx, show)
    }

    cat("\n")
    deferred <- c(deferred, built$warnings_msg)
  }

  # Persist reminder (standard-tier; suppressed at minimal output).
  if (!identical(getOption(".jst_output_level", "standard"), "minimal")) {
    message("Registrations are stored for this session only. To keep them ",
            "across sessions, save the data frame in R native format (.rds), ",
            "e.g. jsave(", .jst_data_name, ", \"", .jst_data_name, ".rds\").")
  }

  for (w in deferred) warning(w, call. = FALSE)

  invisible(NULL)
}


#' Internal helper: render the session-wide numeric/count registration status
#'
#' Backs the no-argument calls \code{jnumeric()} and \code{jcount()}, which
#' both show the same unified view of the \code{.jst_registry} notebook
#' (numeric and count intents, each tagged by kind) across all data frames.
#' Dummy registrations live in a separate store and are shown by
#' \code{jdummy()}. Mirrors the jdummy no-argument overview layout: a single
#' registered frame renders a red header plus one line per variable; two or
#' more frames render a header plus one indented line per frame, with the
#' \code{juse()} default marked.
#'
#' @return \code{invisible(NULL)}. Called for its message side effect.
#'
#' @keywords internal
.jst_registry_status <- function() {
  default_name <- getOption(".jst_default_data", default = NULL)
  all_reg <- getOption(".jst_registry", default = list())
  all_reg <- all_reg[vapply(all_reg, function(x) !is.null(x) && length(x) > 0L,
                            logical(1))]
  if (length(all_reg) == 0L) {
    message("No variable registrations in this session.")
    return(invisible(NULL))
  }
  dnames <- names(all_reg)

  # Render one frame's records as "var (kind)" pieces.
  frame_items <- function(recs) {
    vapply(recs, function(r) paste0(r$var_name, " (",
                                    .jst_intent_label(r$kind), ")"),
           character(1))
  }

  if (length(all_reg) > 1L) {
    lines <- vapply(seq_along(all_reg), function(i) {
      items <- frame_items(all_reg[[i]])
      tag   <- if (identical(dnames[i], default_name)) "  [default]" else ""
      paste0("  - ", dnames[i], ": ", paste(items, collapse = ", "), tag)
    }, character(1))
    message("jstats registrations (", length(all_reg), " data frames):\n",
            paste(lines, collapse = "\n"))
    return(invisible(NULL))
  }

  # Single frame: red header plus one line per registered variable.
  frame_name <- dnames[1L]
  recs       <- all_reg[[1L]]
  .cat_red("Variable Registrations\n")
  if (identical(frame_name, default_name)) {
    .jst_default_note(frame_name, extra_newline = TRUE)
  } else {
    .cat_yellow(paste0("Data frame: ", frame_name, "\n"))
    cat("\n")
  }
  for (r in recs) {
    cat("  ", r$var_name, ": ", .jst_intent_label(r$kind), "\n", sep = "")
  }
  cat("\n")
  invisible(NULL)
}


# -- jnumeric / jcount ---------------------------------------------------------

#' Register variables as numeric for analysis
#'
#' \code{jnumeric()} tells jstats to treat one or more variables as numeric
#' (continuous) wherever their analysis class matters, overriding the package's
#' automatic structural guess. It is the counterpart to \code{\link{jdummy}}
#' (categorical) and \code{\link{jcount}} (count): a variable carries exactly
#' one registered intent at a time, so registering it as numeric clears any
#' prior dummy or count registration. Registration changes no data and assigns
#' nothing -- you do not write \code{df <- jnumeric(...)}. It is stored for the
#' session, keyed by the data frame's name; save the data frame in R native
#' format (.rds) to keep it across sessions.
#'
#' The typical use is a small-range whole number that the structural classifier
#' would treat as categorical (e.g. a 0-6 attitude item) but that you want
#' analyzed as a continuous score.
#'
#' @param data A data frame, or omitted to use the \code{\link{juse}} default.
#'   \code{jnumeric(NULL)} clears the numeric registrations on the
#'   \code{\link{juse}} default frame (or, with no default set, the only frame
#'   that carries them; if several do, it asks rather than wiping all).
#'   \code{jnumeric(data, NULL)} clears that one frame's numeric registrations.
#'   Called with no arguments, \code{jnumeric()} lists the session's numeric
#'   and count registrations.
#' @param ... One or more unquoted variable names to register.
#' @param remove Logical; if \code{TRUE}, remove the numeric registration for
#'   the named variables instead of adding it.
#' @param clear.all Logical; if \code{TRUE}, clear numeric registrations on
#'   every data frame that carries them.
#' @return \code{invisible(NULL)}. Called for its side effect on the session
#'   registration notebook.
#' @seealso \code{\link{jdummy}}, \code{\link{jcount}}
#' @examples
#' df <- data.frame(attitude = c(1, 2, 3, 4, 5, 2, 3),
#'                  score    = c(10, 22, 31, 44, 55, 28, 33))
#' jnumeric(df, attitude)              # treat the 1-5 item as continuous
#' jnumeric(df, attitude, score)       # multiple variables at once
#' jnumeric(df, attitude, remove = TRUE)
#' jnumeric()                          # list all registrations
#' jnumeric(df, NULL)                  # clear df's numeric registrations
#' jnumeric(clear.all = TRUE)          # clear every frame's numeric registrations
#' @export
jnumeric <- function(data, ..., remove = FALSE, clear.all = FALSE) {
  # jnumeric(clear.all = TRUE): clear numeric registrations on every frame.
  if (isTRUE(clear.all)) return(.jst_handle_clear("numeric", clear.all = TRUE))
  # jnumeric() with no arguments: show the session-wide registry status.
  if (missing(data) && ...length() == 0L) return(.jst_registry_status())
  raw_data <- if (!missing(data)) substitute(data) else NULL
  # jnumeric(NULL): clear the default frame (or the sole registered frame, or
  # ask) -- never a silent all-frames wipe (use clear.all = TRUE for that).
  if (!missing(data) && is.null(raw_data)) {
    return(.jst_handle_clear("numeric",
             default_name = getOption(".jst_default_data", default = NULL)))
  }

  arg1 <- .jst_resolve_first_arg(
    data_sub      = substitute(data),
    data_missing  = missing(data),
    fn_name       = "jnumeric",
    envir         = parent.frame(),
    accept_vector = FALSE
  )
  data         <- arg1$data
  data_name    <- arg1$name
  default_used <- arg1$mode %in% c("default", "symbol_with_default")

  variables <- rlang::enquos(...)
  if (arg1$mode == "symbol_with_default") {
    extra_quo <- rlang::new_quosure(arg1$first_arg_sub, env = parent.frame())
    variables <- c(list(extra_quo), variables)
    class(variables) <- "quosures"
  }
  # jnumeric(data, NULL): clear this frame's numeric registrations (mirrors
  # jdummy(data, NULL); the lone NULL sits in the variable slot).
  if (length(variables) == 1L && rlang::quo_is_null(variables[[1]])) {
    return(.jst_handle_clear("numeric", explicit_frame = data_name))
  }
  if (length(variables) == 0) {
    stop("Specify one or more variables to register, e.g. ",
         "jnumeric(", data_name, ", <var1>, <var2>).", call. = FALSE)
  }
  var_names <- vapply(variables, rlang::quo_name, character(1))

  .jst_register_intent("numeric", data, data_name, default_used,
                       var_names, remove)
}


#' Register variables as counts for analysis
#'
#' \code{jcount()} tells jstats to treat one or more variables as count
#' variables (non-negative whole-number tallies). A count is numeric-like -- it
#' passes wherever a numeric variable does and shows mean/median in
#' \code{\link{jscreen}} -- and additionally carries count semantics: it is the
#' asserted signal behind the count-regression caveat in \code{\link{jlm}} and
#' the routing target for future count-model functions. Unlike the structural
#' guess, jcount accepts counts of any range, including those outside the
#' automatic small-range detection (e.g. a 0-30 victimization count).
#'
#' A variable carries exactly one registered intent at a time, so registering
#' it as a count clears any prior dummy or numeric registration. Registration
#' changes no data and assigns nothing. It is stored for the session, keyed by
#' the data frame's name; save the data frame in R native format (.rds) to keep
#' it across sessions.
#'
#' @param data A data frame, or omitted to use the \code{\link{juse}} default.
#'   \code{jcount(NULL)} clears the count registrations on the \code{\link{juse}}
#'   default frame (or, with no default set, the only frame that carries them;
#'   if several do, it asks rather than wiping all). \code{jcount(data, NULL)}
#'   clears that one frame's count registrations. Called with no arguments,
#'   \code{jcount()} lists the session's numeric and count registrations.
#' @param ... One or more unquoted variable names to register.
#' @param remove Logical; if \code{TRUE}, remove the count registration for the
#'   named variables instead of adding it.
#' @param clear.all Logical; if \code{TRUE}, clear count registrations on every
#'   data frame that carries them.
#' @return \code{invisible(NULL)}. Called for its side effect on the session
#'   registration notebook.
#' @seealso \code{\link{jnumeric}}, \code{\link{jdummy}}
#' @examples
#' df <- data.frame(arrests = c(0, 1, 2, 0, 3, 1, 0, 12),
#'                  age      = c(21, 34, 45, 29, 51, 38, 26, 60))
#' jcount(df, arrests)                 # treat as a count (here 0-12)
#' jcount(df, arrests, remove = TRUE)
#' jcount()                            # list all registrations
#' jcount(df, NULL)                    # clear df's count registrations
#' jcount(clear.all = TRUE)            # clear every frame's count registrations
#' @export
jcount <- function(data, ..., remove = FALSE, clear.all = FALSE) {
  # jcount(clear.all = TRUE): clear count registrations on every frame.
  if (isTRUE(clear.all)) return(.jst_handle_clear("count", clear.all = TRUE))
  # jcount() with no arguments: show the session-wide registry status.
  if (missing(data) && ...length() == 0L) return(.jst_registry_status())
  raw_data <- if (!missing(data)) substitute(data) else NULL
  # jcount(NULL): clear the default frame (or the sole registered frame, or
  # ask) -- never a silent all-frames wipe (use clear.all = TRUE for that).
  if (!missing(data) && is.null(raw_data)) {
    return(.jst_handle_clear("count",
             default_name = getOption(".jst_default_data", default = NULL)))
  }

  arg1 <- .jst_resolve_first_arg(
    data_sub      = substitute(data),
    data_missing  = missing(data),
    fn_name       = "jcount",
    envir         = parent.frame(),
    accept_vector = FALSE
  )
  data         <- arg1$data
  data_name    <- arg1$name
  default_used <- arg1$mode %in% c("default", "symbol_with_default")

  variables <- rlang::enquos(...)
  if (arg1$mode == "symbol_with_default") {
    extra_quo <- rlang::new_quosure(arg1$first_arg_sub, env = parent.frame())
    variables <- c(list(extra_quo), variables)
    class(variables) <- "quosures"
  }
  # jcount(data, NULL): clear this frame's count registrations.
  if (length(variables) == 1L && rlang::quo_is_null(variables[[1]])) {
    return(.jst_handle_clear("count", explicit_frame = data_name))
  }
  if (length(variables) == 0) {
    stop("Specify one or more variables to register, e.g. ",
         "jcount(", data_name, ", <var1>, <var2>).", call. = FALSE)
  }
  var_names <- vapply(variables, rlang::quo_name, character(1))

  .jst_register_intent("count", data, data_name, default_used,
                       var_names, remove)
}


#' Register variables as Likert (ordered response) items
#'
#' \code{jlikert()} declares one or more value-labelled variables as Likert
#' items -- ordered response scales (for example 1 = Strongly disagree through
#' 5 = Strongly agree). It is the ordered-scale counterpart to
#' \code{\link{jdummy}} (categorical), \code{\link{jnumeric}} (continuous), and
#' \code{\link{jcount}} (count): a variable carries exactly one registered
#' intent at a time, so registering it as Likert clears any prior numeric,
#' count, or dummy registration on it.
#'
#' \strong{Scope -- display only.} The Likert intent refines reporting, not
#' analysis. It sets the variable's sub-class to "Likert" in
#' \code{\link{jscreen}}'s Variable Types table, marking it as an ordered scale
#' rather than a generic N-category variable. It does NOT change how any
#' analysis treats the variable (there is no order-aware modelling), and it does
#' not by itself change \code{\link{jplot}} output -- a value-labelled
#' small-range variable already plots as an ordered, labelled bar regardless of
#' this registration.
#'
#' Like the other registration verbs, registrations are session-scoped and keyed
#' by data-frame name; save the frame in R native format (.rds) with
#' \code{\link{jsave}} to keep them across sessions.
#'
#' @param data A data frame, or omitted to use the \code{\link{juse}} default.
#' @param ... One or more unquoted variable names to register, or a single
#'   \code{NULL} to clear this frame's Likert registrations (see Details).
#' @param remove Logical; if TRUE, remove the named variables' Likert
#'   registrations instead of adding them.
#' @param clear.all Logical; if TRUE, clear Likert registrations on every data
#'   frame.
#'
#' @details
#' Clearing mirrors the other registration verbs:
#' \itemize{
#'   \item \code{jlikert(data, NULL)} -- clear this frame's Likert
#'     registrations.
#'   \item \code{jlikert(NULL)} -- clear the \code{juse()} default frame (or the
#'     sole frame carrying Likert registrations; if several do, it asks rather
#'     than clearing them all).
#'   \item \code{jlikert(clear.all = TRUE)} -- clear every frame.
#' }
#' \code{jlikert()} with no arguments prints the current registration status.
#'
#' @return Invisibly NULL. Called for its side effect on the session registry.
#' @examples
#' \dontrun{
#'   jlikert(community, Environment1, Environment2)  # declare two Likert items
#'   jscreen(community)                              # Sub-class shows "Likert"
#'   jlikert(community, Environment1, remove = TRUE) # undo one
#' }
#' @seealso \code{\link{jnumeric}}, \code{\link{jcount}}, \code{\link{jdummy}},
#'   \code{\link{jscreen}}
#' @export
jlikert <- function(data, ..., remove = FALSE, clear.all = FALSE) {
  # jlikert(clear.all = TRUE): clear Likert registrations on every frame.
  if (isTRUE(clear.all)) return(.jst_handle_clear("likert", clear.all = TRUE))
  # jlikert() with no arguments: show the session-wide registry status.
  if (missing(data) && ...length() == 0L) return(.jst_registry_status())
  raw_data <- if (!missing(data)) substitute(data) else NULL
  # jlikert(NULL): clear the default frame (or the sole registered frame, or
  # ask) -- never a silent all-frames wipe (use clear.all = TRUE for that).
  if (!missing(data) && is.null(raw_data)) {
    return(.jst_handle_clear("likert",
             default_name = getOption(".jst_default_data", default = NULL)))
  }

  arg1 <- .jst_resolve_first_arg(
    data_sub      = substitute(data),
    data_missing  = missing(data),
    fn_name       = "jlikert",
    envir         = parent.frame(),
    accept_vector = FALSE
  )
  data         <- arg1$data
  data_name    <- arg1$name
  default_used <- arg1$mode %in% c("default", "symbol_with_default")

  variables <- rlang::enquos(...)
  if (arg1$mode == "symbol_with_default") {
    extra_quo <- rlang::new_quosure(arg1$first_arg_sub, env = parent.frame())
    variables <- c(list(extra_quo), variables)
    class(variables) <- "quosures"
  }
  # jlikert(data, NULL): clear this frame's Likert registrations.
  if (length(variables) == 1L && rlang::quo_is_null(variables[[1]])) {
    return(.jst_handle_clear("likert", explicit_frame = data_name))
  }
  if (length(variables) == 0) {
    stop("Specify one or more variables to register, e.g. ",
         "jlikert(", data_name, ", <var1>, <var2>).", call. = FALSE)
  }
  var_names <- vapply(variables, rlang::quo_name, character(1))

  .jst_register_intent("likert", data, data_name, default_used,
                       var_names, remove)
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
#'       Includes Case Processing Summary, reference categories, effect
#'       sizes, and confidence intervals for means and mean differences
#'       (\code{jt}, \code{jaov}); regression coefficient CIs (\code{jlm},
#'       \code{jlogistic}) are reserved for full. Variable labels are off by
#'       default (\code{variable.id = "names"}); request a label legend or
#'       in-table labels per call or via the \code{variable.id} toggle.}
#'     \item{full}{Everything in standard plus a variable label legend
#'       (\code{variable.id = "legend"}), regression coefficient confidence
#'       intervals, assumption checks (Levene's
#'       test), post-hoc tests, regression diagnostics, and the most
#'       detailed Case Processing Summary (per-code missing breakdown).}
#'   }
#' @param effect.size Logical or NULL. Override the level's default for
#'   effect size display.
#' @param regression.ci Logical or NULL. Override the level's default for
#'   confidence intervals on regression coefficients (\code{jlm},
#'   \code{jlogistic}). Off at minimal and standard, on at full.
#' @param means.ci Logical or NULL. Override the level's default for
#'   confidence intervals on means and mean differences (\code{jt},
#'   \code{jaov}). Off at minimal, on at standard and full.
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
#' @param variable.id Character or NULL. Variable label display mode, one
#'   of \code{"both"}, \code{"names"}, \code{"labels"}, \code{"legend"}, or
#'   \code{"legend.bottom"}. \code{"names"} shows variable names only;
#'   \code{"both"} shows \code{"name: label"}, with
#'   no labels block. \code{"labels"} replaces variable names with their
#'   labels in the analysis output itself (table rows, captions, crosstab
#'   dimnames, or \code{jplot} axis/legend titles) -- best when labels
#'   are short. \code{"legend"} keeps names in place and prints a label
#'   legend at the function's mid position (for \code{jlm}/\code{jlogistic}
#'   between the coefficients and fit blocks; for \code{jfreq} under each
#'   variable's own table; elsewhere directly after the single table).
#'   \code{"legend.bottom"} keeps names in place and prints one
#'   consolidated legend at the very end of the output. The minimal and
#'   standard tiers default to \code{"none"}; the full tier defaults to
#'   \code{"legend"}. Not a logical -- \code{TRUE}/\code{FALSE} are not
#'   accepted.
#' @param value.id Character or NULL. Value-label display mode for the
#'   categorical levels that appear in \code{jfreq} valid rows, the
#'   \code{jt}/\code{jaov} group descriptives, the \code{jcrosstab} axes, and
#'   the grouped \code{jdesc} headers. One of \code{"both"} (\code{"code: label"},
#'   degrading to a bare code where a code has no label), \code{"values"} (the
#'   bare stored code), or \code{"labels"} (the value label, degrading to the
#'   bare code per code where none exists).
#'   \code{"legend"} and \code{"legend.bottom"} keep the bare code in the
#'   table and print a value-label legend after it (\code{"legend"}
#'   per-table, \code{"legend.bottom"} consolidated where multiple tables
#'   are produced). Variables with no value labels
#'   render identically under all three modes, so this is a no-op for plain
#'   numeric data. The minimal tier defaults to \code{"values"}; the standard
#'   and full tiers default to \code{"both"}. Distinct from
#'   \code{variable.id}, which governs the one-per-variable descriptive
#'   label. Not a logical.
#' @param ref.categories Logical or NULL. Override the level's default
#'   for the reference categories block (registered dummies).
#' @param udm.notice Three-state toggle controlling the user-defined
#'   missing-value (UDM) notification emitted by \code{jload()} for
#'   \code{.sav} files. \code{TRUE} prints the notification on every
#'   load that involves UDM-bearing variables; \code{FALSE} suppresses
#'   it entirely; \code{NULL} ("auto") prints it only the first time
#'   in a session, then suppresses it. Standard level uses \code{NULL}
#'   (auto), minimal uses \code{FALSE}, full uses \code{TRUE}.
#' @param digits Integer or NULL. Number of decimal places shown for
#'   continuous statistics in the analysis-function output tables
#'   (range 0-7; \code{digits = 0} prints whole numbers with no
#'   trailing decimal point). Does not affect p-values, percentages,
#'   or integer quantities (counts, N, degrees of freedom), which keep
#'   their own fixed conventions. All three preset levels default to 3.
#'
#' @return Invisibly returns NULL. Called for its side effect of setting
#'   session options.
#'
#' @examples
#' joutput("standard")                       # effect sizes + means/diff CIs (jt, jaov)
#' joutput("standard", regression.ci = TRUE) # also show jlm/jlogistic coefficient CIs
#' joutput("full")                         # everything
#' joutput()                               # show current settings
#' joutput(NULL)                           # reset to defaults
#'
#' @seealso \code{\link{JeffsStatTools}} for the package overview,
#'   workflow conventions, and complete function listing.
#'
#' @export
#' @param quiet Logical; default FALSE. When TRUE, joutput() applies the
#'   level/toggle change silently (the status panel is not printed). A bare
#'   joutput() status query always prints regardless of quiet.
joutput <- function(level, effect.size = NULL,
                    regression.ci = NULL, means.ci = NULL, levene = NULL,
                    posthoc = NULL, diagnostics = NULL,
                    case.processing = NULL, case.processing.detail = NULL,
                    variable.id = NULL, value.id = NULL,
                    ref.categories = NULL, udm.notice = NULL,
                    digits = NULL, quiet = FALSE) {

  valid_levels <- c("minimal", "standard", "full")

  # joutput(NULL) -- reset to defaults
  if (!missing(level) && is.null(level)) {
    options(.jst_output_level = NULL)
    options(.jst_output_toggles = NULL)
    if (!quiet) {
      .cat_red("Output Settings\n")
      cat("Reset to defaults (standard, no toggle overrides).\n\n")
    }
    return(invisible(NULL))
  }

  # Collect any explicit toggle overrides
  toggle_args <- list()
  if (!is.null(effect.size))     toggle_args$effect.size     <- effect.size
  if (!is.null(regression.ci))   toggle_args$regression.ci   <- regression.ci
  if (!is.null(means.ci))        toggle_args$means.ci        <- means.ci
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
  if (!is.null(variable.id)) {
    if (!is.character(variable.id) || length(variable.id) != 1 ||
        !(variable.id %in% c("both", "names", "labels", "legend", "legend.bottom"))) {
      stop("variable.id must be one of: \"both\", \"names\", \"labels\", ",
           "\"legend\", \"legend.bottom\".", call. = FALSE)
    }
    toggle_args$variable.id <- variable.id
  }
  if (!is.null(value.id)) {
    if (!is.character(value.id) || length(value.id) != 1 ||
        !(value.id %in% c("both", "values", "labels", "legend", "legend.bottom"))) {
      stop("value.id must be one of: \"both\", \"values\", \"labels\", ",
           "\"legend\", \"legend.bottom\".", call. = FALSE)
    }
    toggle_args$value.id <- value.id
  }
  if (!is.null(ref.categories))  toggle_args$ref.categories  <- ref.categories
  if (!is.null(udm.notice))      toggle_args$udm.notice      <- udm.notice
  if (!is.null(digits)) {
    if (length(digits) != 1L || is.na(digits) ||
        !is.numeric(digits) || digits != as.integer(digits) ||
        digits < 0L || digits > 7L) {
      stop("digits must be a single whole number between 0 and 7.",
           call. = FALSE)
    }
    toggle_args$digits <- as.integer(digits)
  }

  # joutput() with no level argument -- show status or apply toggles only
  if (missing(level)) {
    if (length(toggle_args) > 0) {
      # Apply toggle overrides to current settings
      current_toggles <- getOption(".jst_output_toggles", list())
      for (nm in names(toggle_args)) current_toggles[[nm]] <- toggle_args[[nm]]
      options(.jst_output_toggles = current_toggles)
      # A toggle change respects quiet.
      if (!quiet) .jst_output_status()
    } else {
      # A bare joutput() query always prints, regardless of quiet.
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

  if (!quiet) .jst_output_status()
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
  toggle_names <- c("effect.size", "regression.ci", "means.ci", "levene",
                    "posthoc", "diagnostics",
                    "case.processing", "case.processing.detail",
                    "variable.id", "value.id", "ref.categories",
                    "udm.notice", "digits")
  defaults     <- .jst_output_defaults[[level]]

  for (nm in toggle_names) {
    default_val  <- defaults[[nm]]
    effective    <- if (nm %in% names(toggles)) toggles[[nm]] else default_val
    # (override) marks settings whose effective value differs from the tier
    # default -- i.e. an override with a visible effect. Setting a toggle back
    # to its tier default (even explicitly) is not flagged, since nothing is
    # actually overridden. identical() handles the NULL (AUTO) states cleanly.
    override_str <- if (!identical(effective, default_val)) " (override)" else ""

    # case.processing.detail carries a string tier (none/totals/per_code);
    # variable.id (none/labels/legend/legend.bottom) and value.id
    # (both/values/labels) likewise carry string tiers -- show the token,
    # not ON/OFF. digits is an integer (0-7) -- show the number. case.processing
    # and udm.notice support three states (TRUE/FALSE/NULL=AUTO); the remaining
    # toggles are binary.
    label <- if (nm %in% c("case.processing.detail", "variable.id",
                           "value.id")) {
      toupper(effective)
    } else if (nm == "digits") {
      as.character(effective)
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
  cl <- getOption(".jst_options_corr_layout",
                  .jst_options_defaults$corr.layout)

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
  # displays as-is; if that folder does not exist yet, annotate that it
  # will be created on first save. joptions() never creates the folder --
  # creation stays deferred to jsave's first write (Option C decision) --
  # so this note makes the pending side effect visible whenever the status
  # panel displays while the folder is still absent.
  dd_label <- if (is.null(dd)) {
    "Working directory"
  } else if (!dir.exists(dd)) {
    paste0(dd, " (will be created on first save)")
  } else {
    dd
  }

  .cat_red("Options Settings\n")
  cat("User-defined missing values (UDMs) convention: ", mc_label,
      "\n", sep = "")
  cat("UDM convention codes: ", paste(cc, collapse = ", "), "\n", sep = "")
  cat("Data folder: ", dd_label, "\n", sep = "")
  cat("Correlation layout: ", cl, "\n", sep = "")
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
#' missing-value information and related conventions. \code{joptions}
#' complements \code{\link{joutput}}: joutput governs output verbosity and
#' tiering, while joptions holds session-wide conventions plus a small number
#' of per-function display defaults (currently the \code{jcorr()} cell
#' layout). Settings are read fresh on each function call:
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
#'     it doesn't already exist (nested paths are created in full).
#'     To clear a previously-set folder back to this default, pass
#'     \code{data.dir = ""} (an empty string); passing
#'     \code{data.dir = NULL} leaves the current setting unchanged
#'     (see Call patterns). Filenames containing a directory
#'     separator (\code{/}) bypass this setting and are taken literally.}
#'   \item{corr.layout}{Character, length 1. One of \code{"wide"} or
#'     \code{"stacked"}. Default: \code{"wide"}. The default cell layout for
#'     \code{\link{jcorr}} when three or more variables are correlated:
#'     \code{"wide"} puts r and p on one line with N beneath; \code{"stacked"}
#'     stacks r, p, and N on three lines for a narrower table that fits more
#'     variables. A per-call \code{layout} argument to \code{jcorr()}
#'     overrides this. It lives here rather than in \code{\link{joutput}}
#'     because it is specific to one function's output, not a tiered
#'     analysis-content toggle.}
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
#'     \code{joptions(missing.convention = "none")}). Because
#'     \code{data.dir}'s default is \code{NULL} -- which already means
#'     "leave alone" -- it is cleared instead with \code{data.dir = ""}.}
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
#' @param corr.layout One of \code{"wide"} or \code{"stacked"}, or
#'   \code{NULL}. See Slots.
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
#' @param quiet Logical; default FALSE. When TRUE, joptions() applies the
#'   change silently, suppressing both the status panel and the convention
#'   nudge. A bare joptions() status query always prints regardless of quiet.
joptions <- function(missing.convention = NULL, udm.convention.codes = NULL,
                     data.dir = NULL, corr.layout = NULL, quiet = FALSE) {

  mc_supplied <- !missing(missing.convention)
  cc_supplied <- !missing(udm.convention.codes)
  dd_supplied <- !missing(data.dir)
  cl_supplied <- !missing(corr.layout)

  # joptions() -- no args, status only
  if (!mc_supplied && !cc_supplied && !dd_supplied && !cl_supplied) {
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
  # Ignore a named quiet = ... when detecting the reset shape, so
  # joptions(NULL, quiet = TRUE) is still recognized as a (quiet) reset
  # rather than read as two arguments.
  arg_names <- names(call_args)
  if (!is.null(arg_names)) call_args <- call_args[arg_names != "quiet"]
  positional_null_reset <- length(call_args) == 1L &&
                           (is.null(names(call_args)) ||
                            names(call_args) == "") &&
                           is.null(call_args[[1L]])

  # joptions(NULL) -- reset all
  if (positional_null_reset) {
    options(.jst_options_missing_convention   = NULL)
    options(.jst_options_udm_convention_codes = NULL)
    options(.jst_options_data_dir             = NULL)
    options(.jst_options_corr_layout          = NULL)
    if (!quiet) .jst_options_status()
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
        is.na(data.dir)) {
      stop('data.dir must be a single character string, NULL, or "". ',
           '(Use "" to clear the folder, NULL to leave it unchanged.)',
           call. = FALSE)
    }
    # Guard the literal "NULL" string -- almost always a typo for one of
    # the two real tokens. Case-sensitive, so a genuine folder named
    # "null" (lowercase) is still permitted.
    if (identical(trimws(data.dir), "NULL")) {
      stop('data.dir = "NULL" looks like a typo. To clear the data folder ',
           'back to the working directory, use data.dir = "" (empty quotes); ',
           'to leave it unchanged, use data.dir = NULL (no quotes).',
           call. = FALSE)
    }
  }
  if (cl_supplied && !is.null(corr.layout)) {
    if (!is.character(corr.layout) ||
        length(corr.layout) != 1L ||
        !(corr.layout %in% c("wide", "stacked"))) {
      stop("corr.layout must be one of: \"wide\", \"stacked\".", call. = FALSE)
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
    # "" (empty or whitespace-only) clears the slot back to its NULL
    # default (working directory); any other string sets the folder.
    # NULL never reaches here -- the !is.null gate above leaves it alone.
    if (nchar(trimws(data.dir)) == 0L) {
      options(.jst_options_data_dir = NULL)
    } else {
      options(.jst_options_data_dir = data.dir)
      .jst_data_dir_case_warning(data.dir)
    }
  }
  if (cl_supplied && !is.null(corr.layout)) {
    options(.jst_options_corr_layout = corr.layout)
  }

  # Status panel, then nudge (per Session 28 Item 1 decision). quiet = TRUE
  # silences both -- a quiet call is fully quiet.
  if (!quiet) {
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

#' Internal: warn on a case-only collision between data.dir and an existing
#' folder
#'
#' @description
#' On a case-insensitive filesystem (Windows, and macOS by default), a
#' \code{data.dir} such as \code{"Data"} silently resolves onto an existing
#' folder of a different case (e.g. \code{"data"}); saves and loads then use
#' the existing folder, and a teardown aimed at the configured name could
#' remove the wrong one. This emits a note at set time when that collision is
#' detected. Case-sensitive filesystems (Linux) create a distinct folder and
#' are not warned, so the behaviour is intentionally non-uniform across
#' operating systems.
#'
#' @param dir Character(1). The data.dir value just set.
#'
#' @return Invisibly \code{NULL}; called for the message side effect.
#'
#' @keywords internal
.jst_data_dir_case_warning <- function(dir) {
  # Only a folder that already resolves on disk can collide. On a
  # case-sensitive filesystem a differently-cased name does not exist, so
  # dir.exists() is FALSE and nothing is warned.
  if (!isTRUE(dir.exists(dir))) return(invisible(NULL))

  parent <- dirname(dir)
  if (identical(parent, "")) parent <- "."
  want    <- basename(dir)
  entries <- tryCatch(
    list.dirs(parent, full.names = FALSE, recursive = FALSE),
    error = function(e) character(0)
  )

  # An exact-case match means no collision. A match only under tolower()
  # means the filesystem folded the case onto an existing, differently-cased
  # folder.
  if (!(want %in% entries)) {
    hit <- entries[tolower(entries) == tolower(want)]
    if (length(hit) > 0) {
      message(
        "Note: data.dir was set to '", want, "', but a folder named '",
        hit[1], "' already exists and your filesystem treats the two as the ",
        "same folder. Saves and loads will use the existing '", hit[1],
        "'. To keep a separate folder, choose a name that differs by more ",
        "than letter case."
      )
    }
  }
  invisible(NULL)
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
#' @param variable.id Character or NULL. Variable label display mode: one of
#'   \code{"both"}, \code{"names"}, \code{"labels"}, \code{"legend"}, or
#'   \code{"legend.bottom"}. \code{"names"} shows variable names only;
#'   \code{"both"} shows \code{"name: label"};
#'   \code{"labels"} shows each variable's label in place of its name (in the
#'   descriptives table; for grouped output, as the per-variable caption and
#'   the grouping-variable column header) -- best for short labels;
#'   \code{"legend"} and \code{"legend.bottom"} keep names and print a label
#'   legend after the table. NULL (default) defers to \code{joutput()}'s
#'   \code{variable.id} setting. Not a logical.
#' @param numeric Optional character vector of variable names to treat as
#'   continuous for this call (the per-call counterpart of \code{jnumeric()}).
#'   Its only effect in \code{jdesc()} is to suppress the structural "seems
#'   categorical" descriptive caution for those variables; the descriptives
#'   themselves are computed the same way regardless.
#' @param categorical Not supported by \code{jdesc()} yet. \code{jdesc()}
#'   always computes numeric descriptives; supplying \code{categorical} raises
#'   an error pointing to \code{jfreq()} for a categorical summary. (How
#'   \code{jdesc()} should handle an asserted-categorical variable is a parked
#'   design decision.)
#' @param count Optional character vector of variable names to treat as counts
#'   for this call (the per-call counterpart of \code{jcount()}). A count is
#'   numeric-like here, so it behaves like \code{numeric}: it suppresses the
#'   "seems categorical" caution for those variables.
#' @param value.id Character or NULL. Value-label display mode for the
#'   grouped descriptive headers (the \code{by}-group rows): \code{"both"}
#'   (\code{"code: label"}), \code{"values"} (bare code), or \code{"labels"}
#'   (the label, degrading to the bare code where a code has none).
#'   \code{"legend"} and \code{"legend.bottom"} keep the bare code in the
#'   table and print a value-label legend after it (\code{"legend"}
#'   per-table, \code{"legend.bottom"} consolidated where multiple tables
#'   are produced). A no-op for
#'   grouping variables with no value labels, and for ungrouped calls. NULL
#'   (default) defers to \code{joutput()}'s \code{value.id} setting. Not a
#'   logical.
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
#' @param digits Integer or NULL. Number of decimal places for continuous
#'   statistics in the output tables (range 0-7; \code{digits = 0} prints
#'   whole numbers with no trailing decimal point). Does not affect p-values,
#'   percentages, or integer quantities (counts, N, degrees of freedom),
#'   which keep their own fixed conventions. NULL (default) defers to
#'   \code{joutput()}'s \code{digits} setting (default 3).
#' @param case.processing.detail Per-call override of the Case
#'   Processing Summary detail tier: one of \code{"none"},
#'   \code{"totals"}, or \code{"per_code"}. \code{NULL} (default)
#'   uses the active \code{joutput()} level default.
jdesc <- function(data, ..., by = NULL, subset = NULL, variable.id = NULL,
                  numeric = NULL, categorical = NULL, count = NULL,
                  value.id = NULL, case.processing.detail = NULL,
                  digits = NULL) {

  digits_n <- .jst_resolve_digits(digits)

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
    return(jdesc(temp_df, !!rlang::sym(var_name), variable.id = variable.id,
                 numeric = numeric, categorical = categorical, count = count,
                 value.id = value.id))
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

  # -- Per-call classification overrides -------------------------------------
  # jdesc is per-variable and numeric-coercing. numeric=/count= assert a
  # numeric-like analysis role for the named variables, which here serves a
  # single purpose: suppressing the structural "seems categorical" descriptive
  # caution (the override is consulted by .jst_role_asserted_numeric in
  # .emit_good_notes below). A count is numeric-like in this context, so
  # count= behaves like numeric= for the caution. categorical= is accepted only
  # to fail cleanly: deciding what jdesc should DO with an asserted-categorical
  # variable is a parked design (see JStats_Classification_Registry_Reference
  # Part 4), so rather than silently summarizing a variable the user asked to
  # treat categorically, jdesc stops and points to jfreq().
  if (!is.null(categorical)) {
    stop("categorical = is not supported by jdesc() yet: jdesc() always ",
         "computes numeric descriptives. For a categorical summary use ",
         "jfreq() instead.", call. = FALSE)
  }
  for (.arg in c("numeric", "count")) {
    .val <- get(.arg)
    if (!is.null(.val)) {
      .bad <- setdiff(.val, variable_names)
      if (length(.bad) > 0) {
        stop(.arg, " argument: ", paste0("'", .bad, "'", collapse = ", "),
             " not found among the variables passed to jdesc(). Check for typos.",
             call. = FALSE)
      }
    }
  }
  # numeric and count are both "numeric-like" assertions, so naming a variable
  # in both is harmless rather than a conflict (mirrors jlm).

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
    .ov <- if (v %in% count) "count" else if (v %in% numeric) "numeric" else NULL
    if (.jst_is_discrete_integer(dat[[v]], v, .jst_data_name) &&
        !.jst_role_asserted_numeric(dat[[v]], v, .jst_data_name,
                                    override = .ov)) {
      warning(paste0(v, " seems categorical. Descriptive statistics may ",
                     "not be meaningful."),
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
      by_val_labels   <- labelled::val_labels(by_var)
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
    # Variable label display mode (B1: the former inline Type/label block is
    # gone). jdesc grouped is a per-variable collapse layout: each mini-table
    # is captioned with its DV anchor -- the variable name, or its label under
    # "labels" -- which is structural (the only DV identifier on the table).
    # Under "labels" the grouping variable's column header is its label too;
    # group levels follow the value.id mode. "legend"/"legend.bottom" add one
    # consolidated legend after all mini-tables.
    vlmode   <- .jst_resolve_variable_id(variable.id)
    value_mode <- .jst_resolve_value_id(value.id)
    lab_disp <- function(nm, lab) if (!identical(lab, "None") && nzchar(lab)) lab else nm
    by_disp  <- .jst_combine_id(by_name, lab_disp(by_name, original_by_label), vlmode)
    # Per-level group-header display under the active value.id mode (indexed
    # [i] in the per-variable group loop). Empty when grouping var is unlabelled.
    group_value_disp <- if (is_labelled_by) {
      .jst_format_value_labels(original_codes, by_val_labels, value_mode)
    } else {
      NULL
    }
    cat("\n")

    .jst_print_case_processing(sample_info, analysis_type = "per_var_desc",
                               detail = case.processing.detail)

    for (v in good_vars) {
      v_disp <- .jst_combine_id(v, lab_disp(v, original_dv_info[[v]]$label), vlmode)
      cat(v_disp, "\n", sep = "")

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
          group_value_disp[i]
        } else {
          lvl
        }

        df <- data.frame(
          GROUP_PLACEHOLDER = group_label,
          N     = n,
          Min   = if (n > 0) round(min(subset_data), digits_n) else NA,
          Max   = if (n > 0) round(max(subset_data), digits_n) else NA,
          Mean  = if (n > 0) round(m, digits_n) else NA,
          SD    = if (n > 0) round(s, digits_n) else NA,
          stringsAsFactors = FALSE
        )
        names(df)[1] <- by_disp
        df
      })
      group_table <- do.call(rbind, group_rows)

      .jst_print_table(group_table, row.names = FALSE)
      cat("\n")
    }

    # Mixed case: warn for any variables that could not be summarized.
    .emit_bad_refusals()

    # Variable- and value-label legends at the single consolidated position.
    # The grouping column in `data` has been factor-converted (value labels
    # stripped), so the value-label block reads from `by_var`, which retains
    # the original labelling. No lead-in blank: the last group table emits one.
    leg_modes <- c("legend", "legend.bottom")
    if (vlmode %in% leg_modes) {
      .print_var_labels(data, c(good_vars, by_name))
    }
    if (value_mode %in% leg_modes) {
      .print_value_labels(stats::setNames(list(by_var), by_name), by_name)
    }

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
      descriptives_raw = NULL,
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

  # Variable label display mode (B1: former inline Type/label block removed).
  # jdesc ungrouped is a collapse layout with one row per variable. Under
  # "labels" the Variable column shows labels at print time only (the
  # returned descriptives keep variable names); "legend"/"legend.bottom"
  # collapse to one legend after the table.
  vlmode <- .jst_resolve_variable_id(variable.id)

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
      Min         = if (n > 0) round(min(var_data, na.rm = TRUE), digits_n) else NA,
      Max         = if (n > 0) round(max(var_data, na.rm = TRUE), digits_n) else NA,
      Mean        = if (n > 0) round(mean(var_data, na.rm = TRUE), digits_n) else NA,
      SD          = if (n > 0) round(stats::sd(var_data, na.rm = TRUE), digits_n) else NA,
      stringsAsFactors = FALSE
    )
  })

  descriptives <- do.call(rbind, descriptives_list)

  # japa-ready descriptives: full-precision per-variable statistics built
  # separately from the rounded display frame above (so the printout is
  # untouched). Variable labels travel as a keyed `labels` attribute.
  # (return-shape audit)
  descriptives_raw <- do.call(rbind, lapply(good_vars, function(v) {
    var_data <- .jst_classify_desc_var(data[[v]], v)$num
    n        <- sum(!is.na(var_data))
    data.frame(
      variable  = v,
      total     = length(var_data),
      n_valid   = n,
      n_missing = length(var_data) - n,
      min       = if (n > 0) min(var_data, na.rm = TRUE)        else NA_real_,
      max       = if (n > 0) max(var_data, na.rm = TRUE)        else NA_real_,
      mean      = if (n > 0) mean(var_data, na.rm = TRUE)       else NA_real_,
      sd        = if (n > 0) stats::sd(var_data, na.rm = TRUE)  else NA_real_,
      stringsAsFactors = FALSE,
      row.names = NULL
    )
  }))
  attr(descriptives_raw, "labels") <- stats::setNames(
    vapply(good_vars, function(v) .jst_label_or_name(data, v), character(1)),
    good_vars)

  # Defensive: with good_vars guaranteed non-empty this should always hold,
  # but guard against an empty table reaching the renderer.
  if (!is.null(descriptives) && nrow(descriptives) > 0) {
    descriptives_disp <- descriptives
    if (vlmode %in% c("labels", "both")) {
      descriptives_disp$Variable <- vapply(
        descriptives$Variable,
        function(v) .jst_combine_id(v, .jst_label_or_name(data, v), vlmode, cap = TRUE),
        character(1))
    }
    cat("\n")
    .jst_print_table(descriptives_disp)
    cat("\n")
  }

  # Mixed case: warn for any variables that could not be summarized.
  .emit_bad_refusals()

  if (vlmode %in% c("legend", "legend.bottom")) {
    .print_var_labels(data, good_vars)
  }

  ret <- list(
    descriptives = descriptives,
    descriptives_raw = descriptives_raw,
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
#' Prints an SPSS-style frequency table (Freq, Total %, Valid %, Cum. %) for
#' each variable supplied. Designed for use with unquoted variable names, and
#' also accepts a plain vector.
#'
#' Output is structured consistently with \code{jdesc()}: a single red
#' "Frequencies" title is printed first, followed by the default-data note
#' (if a juse() default was used), any pipeline messages, and the Case
#' Processing Summary (when at least one pipeline stage was active for
#' this call). Each variable then gets its own block consisting of the
#' variable name on its own line, indented Type and Variable label lines
#' (suppressed when \code{joutput()}'s \code{variable.id} toggle is off),
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
#' @param variable.id Character or NULL. Variable label display mode: one of
#'   \code{"both"}, \code{"names"}, \code{"labels"}, \code{"legend"}, or
#'   \code{"legend.bottom"}. \code{"names"} shows variable names only;
#'   \code{"both"} shows \code{"name: label"};
#'   \code{"labels"} uses each variable's label as its table caption (best
#'   for short labels); \code{"legend"} prints a label legend under each
#'   variable's own table; \code{"legend.bottom"} prints one consolidated
#'   legend after all tables. NULL (default) defers to \code{joutput()}'s
#'   \code{variable.id} setting. Not a logical. (Replaces the former inline
#'   Type/label block.)
#' @param value.id Character or NULL. Value-label display mode for the
#'   frequency-table valid rows: \code{"both"} (\code{"code: label"}),
#'   \code{"values"} (bare code), or \code{"labels"} (the label, degrading to
#'   the bare code where a code has none).
#'   \code{"legend"} and \code{"legend.bottom"} keep the bare code in the
#'   table and print a value-label legend after it (\code{"legend"}
#'   per-table, \code{"legend.bottom"} consolidated where multiple tables
#'   are produced). A no-op for variables with no value
#'   labels. NULL (default) defers to \code{joutput()}'s \code{value.id}
#'   setting. Not a logical.
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
jfreq <- function(data, ..., subset = NULL, variable.id = NULL,
                  value.id = NULL, case.processing.detail = NULL) {

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
    return(jfreq(temp_df, !!rlang::sym(var_name), variable.id = variable.id,
                 value.id = value.id))
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

  # Variable label display mode. jfreq is a distinct layout: under "labels"
  # each variable's caption anchor is its label; "legend" prints a legend
  # under each variable's own table; "legend.bottom" prints one consolidated
  # legend after all tables. (Replaces the former inline Type/label block.)
  vlmode <- .jst_resolve_variable_id(variable.id)
  # Value-label display mode (code / label / both). Routes each variable's
  # valid-row Value column through the shared formatter below. No-op for
  # variables carrying no value labels.
  value_mode <- .jst_resolve_value_id(value.id)
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
      codes_chr   <- as.character(unclass(temp_var))
      val_labs    <- labelled::val_labels(temp_var)
      display_str <- .jst_format_value_labels(codes_chr, val_labs, value_mode)
      # Dedup on the underlying code (not the display string): under "values"/
      # "labels" two distinct codes could in principle share a display string.
      uniq        <- !is.na(codes_chr) & !duplicated(codes_chr)
      sort_codes  <- codes_chr[uniq]
      sort_levels <- display_str[uniq][order(sort_codes)]
      temp_var    <- factor(display_str, levels = sort_levels)

    # Haven-labelled (numeric-backed): combine numeric codes with value labels.
    } else if (haven::is.labelled(temp_var)) {
      codes       <- .jst_as_numeric(temp_var)
      val_labs    <- labelled::val_labels(temp_var)
      # The shared formatter renders an unlabelled code as a bare code rather
      # than the "3: 3" haven::as_factor would produce (Decision 7 Notes,
      # fix (b) in the valid-row context), and applies the value.id mode.
      display_str <- .jst_format_value_labels(codes, val_labs, value_mode)
      uniq        <- !is.na(codes) & !duplicated(codes)
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
                                     total = total_count,
                                     valid_count = valid_count,
                                     missing     = total_count - valid_count,
                                     var_label   = .jst_label_or_name(data, variable_name))

    # -- Print: variable anchor (name, or label under "labels") -> blank -> table
    anchor <- .jst_combine_id(variable_name, .jst_label_or_name(data, variable_name), vlmode)
    cat(anchor, "\n", sep = "")
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

    # value.id / variable.id legends under this variable's own table.
    .jst_print_legends_at(data, variable_name, variable_name,
                          vlmode, value_mode, "legend")
  }

  # consolidated legends after all variable tables.
  .jst_print_legends_at(data, var_names_check, var_names_check,
                        vlmode, value_mode, "legend.bottom")

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
#' type, the jstats analysis-role class, an optional sub-class, an optional
#' classification source, distinct-value counts, and optional central-
#' tendency columns), a Missing Data & Outliers table, and — when variable
#' labels are shown — a Variable Labels table last. Handles haven-labelled
#' and date/time variables gracefully.
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
#' When at least one variable's class comes from a registration (jnumeric,
#' jcount, or jdummy) rather than the structural guess, a Source column
#' appears. It reads as an exception-marker: "registered" is shown against
#' the registered variables and the structurally classified rows are left
#' blank, so the registrations stand out at a glance. (The returned data
#' frame still records the literal tier for every row.) Set \code{stats = TRUE} (or "mean" / "median") to add
#' central-tendency columns for the numeric-like variables: Numeric and Count
#' variables show Mean and Median, while a numeric dichotomy shows the raw
#' mean of its stored codes and a blank median. A numeric dichotomy coded
#' other than 0/1 (e.g. the 1/2 Group-4 coding) is flagged with a "*" on its
#' sub-class cell, since its raw mean is not a proportion; the marker shows
#' even when \code{stats} is off, surfacing the recode need.
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
#' @param variable.id Character or NULL. Variable label display mode: one of
#'   \code{"both"}, \code{"names"}, \code{"labels"}, \code{"legend"}, or
#'   \code{"legend.bottom"}. \code{"names"} shows variable names only;
#'   \code{"both"} shows \code{"name: label"};
#'   \code{"labels"} shows labels in each table's Variable column (best for
#'   short labels); \code{"legend"} and \code{"legend.bottom"} keep names and
#'   print a label legend after the tables. NULL (default) defers to
#'   \code{joutput()}'s \code{variable.id} setting. Not a logical.
#' @param value.id Not supported by \code{jscreen()}. The function does not
#'   display value labels, so passing this argument is an error. It exists
#'   only to return a clear message rather than misreporting the token as a
#'   missing variable. Leave at NULL (default).
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
#' @param stats Logical or character. Adds central-tendency columns to the
#'   Variable Types table for numeric-like variables. FALSE (default) shows
#'   none; TRUE shows both Mean and Median; \code{"mean"} or \code{"median"}
#'   shows only that one. Numeric and Count variables show both; a numeric
#'   dichotomy shows its raw mean and a blank median; N-category and other
#'   non-numeric variables are blank. The returned data frame always includes
#'   Mean and Median regardless of this setting.
#' @param digits Integer or NULL. Number of decimal places for the Mean and
#'   Median columns. NULL (default) defers to \code{joutput()}'s \code{digits}
#'   setting (default 3).
#'
#' @return Invisibly returns a data frame of the screening results, with one
#'   row per variable and columns including the Base R type, the jstats
#'   \code{Class} and \code{SubClass}, the classification \code{Source}
#'   ("registered" or "structural"), distinct-value count, missing count
#'   and percentage, the outlier count (NA for non-Numeric variables), and
#'   the \code{Mean} and \code{Median} (NA where not meaningful: Median is NA
#'   for dichotomies, and both are NA for non-numeric-like variables). The
#'   returned values are the raw counts; only the printed tables blank zeros
#'   and omit clean rows.
#'
#' @examples
#' # With explicit data frame
#' jscreen(mtcars)
#' jscreen(mtcars, outlier.sd = 2.5)
#'
#' # Show the Base R storage type column
#' jscreen(mtcars, r.type = TRUE)
#'
#' # Add Mean and Median columns for numeric-like variables
#' jscreen(mtcars, stats = TRUE)
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
jscreen <- function(data, ..., outlier.sd = 3, subset = NULL, variable.id = NULL,
                    value.id = NULL, types = TRUE, issues = TRUE, r.type = FALSE,
                    stats = FALSE, digits = NULL) {

  # jscreen has no per-code surface to display value labels on, so value.id
  # is accepted only to give an explicit, accurate error. A global
  # joutput(value.id=) is read by the value-displaying functions and never
  # arrives here as a per-call arg, so a non-NULL value.id can only be an
  # explicit per-call argument. Erroring here replaces the misleading
  # "variable not found: <token>" that resulted when the token fell into the
  # dots and was mistaken for a variable name. (Session 62, Option A)
  if (!is.null(value.id)) {
    stop("value.id is not supported by jscreen(); it does not display ",
         "value labels.", call. = FALSE)
  }

  # Resolve stats= : hybrid logical-or-character. FALSE -> "none" (default),
  # TRUE -> "both", or one of "mean" / "median". TRUE is kept working (novices
  # try it) despite being the one non-boolean toggle. digits governs the
  # decimal places of the Mean/Median columns, deferring to joutput() when NULL.
  if (isTRUE(stats))  stats <- "both"
  if (isFALSE(stats)) stats <- "none"
  stats_mode <- match.arg(stats, c("none", "mean", "median", "both"))
  digits_n   <- .jst_resolve_digits(digits)

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

  # Variable label display mode. jscreen is a collapse layout screening all
  # columns: under "labels" each table's Variable column shows labels at
  # print time (the returned screen_table keeps names); "legend"/
  # "legend.bottom" collapse to one legend after the tables (the former
  # Variable Labels table); "none" prints no labels block.
  vlmode <- .jst_resolve_variable_id(variable.id)

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
    # and the Outliers column cannot disagree. (Session 51) Source is the
    # resolved provenance ("registered" / "structural" in jscreen, which takes
    # no per-call override and leaves measure unpopulated in v1). (Session 82)
    jc          <- .jst_jstats_class(col, v, .jst_data_name)
    n_missing   <- sum(is.na(col))
    pct_missing <- round(n_missing / n_cases * 100, 1)
    n_unique    <- length(unique(col[!is.na(col)]))

    # Central tendency for NUMERIC-LIKE variables: Numeric and Count (resolved
    # class "Numeric") get Mean and Median; a numeric-backed dichotomy gets the
    # raw mean of its stored codes and a BLANK median (the median of a two-value
    # variable is degenerate). N-category Categoricals, text/factor/logical
    # dichotomies, and the edge classes stay blank. A numeric dichotomy coded
    # other than 0/1 is flagged ("*") on its Sub-class cell, since its raw mean
    # is not a proportion -- the marker is display-only and shows even with
    # stats off. Mean/Median are always computed (returned regardless of the
    # stats= display gate), rounded to the resolved digits. (Session 82)
    dich         <- .jst_is_dichotomy(col)
    is_num_dich  <- isTRUE(dich$is_dichotomy) &&
                    dich$coding %in% c("0/1", "1/2", "other")
    numeric_like <- jc$class == "Numeric" || is_num_dich
    star         <- is_num_dich && dich$coding %in% c("1/2", "other")

    mean_val   <- NA_real_
    median_val <- NA_real_
    if (numeric_like) {
      num_vals <- .jst_as_numeric(col)
      if (any(!is.na(num_vals))) {
        mean_val <- round(mean(num_vals, na.rm = TRUE), digits_n)
        # Median for Numeric/Count only; a dichotomy keeps a blank median.
        if (jc$class == "Numeric") {
          median_val <- round(stats::median(num_vals, na.rm = TRUE), digits_n)
        }
      }
    }

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
      Source      = jc$source,
      Unique      = n_unique,
      Missing     = n_missing,
      Pct_Missing = pct_missing,
      Outliers    = n_outliers,
      Mean        = mean_val,
      Median      = median_val,
      Star        = star,
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
  # Base R Type column is opt-in (r.type = TRUE); the Sub-class column appears
  # only when at least one variable has a sub-class; the Source column appears
  # only when at least one variable resolves non-structurally (a registration);
  # the Mean/Median columns are opt-in via stats= and appear only when a
  # numeric-like variable carrying that statistic is present (so a dichotomy-
  # only frame requesting "median" does not print an all-blank column).
  # (Session 82)
  if (isTRUE(types)) {
    show_source <- any(screen_table$Source != "structural")
    show_mean   <- stats_mode %in% c("mean", "both") &&
                   any(!is.na(screen_table$Mean))
    show_median <- stats_mode %in% c("median", "both") &&
                   any(!is.na(screen_table$Median))
    show_star   <- any(screen_table$Star)

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
    if (show_source) {
      cols  <- c(cols, "Source")
      heads <- c(heads, "Source")
    }
    cols  <- c(cols, "Unique")
    heads <- c(heads, "Unique Values")
    if (show_mean) {
      cols  <- c(cols, "Mean")
      heads <- c(heads, "Mean")
    }
    if (show_median) {
      cols  <- c(cols, "Median")
      heads <- c(heads, "Median")
    }
    t1 <- screen_table[, cols, drop = FALSE]

    # Append the "*" recode marker to the Sub-class display cell for numeric
    # non-0/1 dichotomies. Display-only: the returned screen_table keeps the
    # clean "dichotomy". A "*" implies a sub-class, so the column is present.
    if (show_star && "SubClass" %in% cols) {
      t1$SubClass[screen_table$Star] <-
        paste0(t1$SubClass[screen_table$Star], "*")
    }

    # The Source column appears only when a registration exists, so it reads
    # cleanest as an exception-marker: the structural rows are blanked in the
    # display copy, leaving the registered variables marked. The display label
    # is "User-declared" (clearer to readers than the mechanism term
    # "registered"; avoids collision with "user-defined missing values").
    # Display-only -- the returned screen_table keeps the literal per-row
    # provenance ("registered" / "structural"). (Session 83; label Session 84)
    if ("Source" %in% cols) {
      t1$Source[screen_table$Source == "structural"] <- ""
      t1$Source[screen_table$Source == "registered"] <- "User-declared"
    }

    if (vlmode %in% c("labels", "both")) {
      t1$Variable <- vapply(t1$Variable,
                            function(v) .jst_combine_id(v, .jst_label_or_name(data, v), vlmode, cap = TRUE),
                            character(1))
    }
    cat("\n")
    .jst_print_table(t1,
                     caption   = "Variable Types",
                     col.names = heads,
                     row.names = FALSE)

    # Conditional one-line legend, printed only when a "*" actually appeared.
    if (show_star) {
      cat("* coded other than 0/1; mean is not a proportion\n")
    }
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
    heads  <- "Variable"
    aligns <- "l"
    if (any_missing) {
      miss <- st$Missing
      pct  <- st$Pct_Missing
      pct[miss == 0]  <- NA_real_
      miss[miss == 0] <- NA_integer_
      t2$Missing     <- miss
      # Format % Missing at a fixed 1 dp as a string so an all-integer-valued
      # column still shows the decimal place (e.g. "5.0", not "5"); the
      # returned screen_table keeps the numeric Pct_Missing. (Session 63)
      t2$Pct_Missing <- ifelse(is.na(pct), "", sprintf("%.1f", pct))
      heads  <- c(heads, "Missing", "% Missing")
      aligns <- c(aligns, "r", "r")
    }
    if (any_outliers) {
      out <- st$Outliers
      out[!is.na(out) & out == 0] <- NA_integer_
      t2$Outliers <- out
      heads  <- c(heads, "Outliers")
      aligns <- c(aligns, "r")
    }
    if (vlmode %in% c("labels", "both")) {
      t2$Variable <- vapply(t2$Variable,
                            function(v) .jst_combine_id(v, .jst_label_or_name(data, v), vlmode, cap = TRUE),
                            character(1))
    }
    cat("\n")
    .jst_print_table(t2,
                     caption   = paste0("Missing Data & Outliers (outliers > ",
                                        outlier.sd, " SD from mean)"),
                     col.names = heads,
                     align     = aligns,
                     row.names = FALSE)
  }

  # -- Variable label legend (last; only under "legend"/"legend.bottom") -----
  if (vlmode %in% c("legend", "legend.bottom")) {
    cat("\n")
    .print_var_labels(data, var_names)
  }

  cat("\n")
  # Star is an internal display flag (the "*" recode marker); it is not part of
  # the returned screening results.
  screen_table$Star <- NULL
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
#' @param ci Logical or NULL. If TRUE, adds 95% confidence interval for the
#'   mean difference. If NULL (default), defers to \code{joutput()}.
#' @param subset An optional unquoted logical expression (e.g.
#'   \code{Group == 1}) to subset cases for this call only. Applied after
#'   jcomplete and jsubset. Does not affect other function calls.
#' @param variable.id Character or NULL. Variable label display mode: one of
#'   \code{"both"}, \code{"names"}, \code{"labels"}, \code{"legend"}, or
#'   \code{"legend.bottom"}. \code{"names"} shows variable names only;
#'   \code{"both"} shows \code{"name: label"};
#'   \code{"labels"} shows the DV and grouping-variable labels in the table
#'   captions (group levels follow the value.id mode) -- best for short labels;
#'   \code{"legend"}/\code{"legend.bottom"} keep names and print a label
#'   legend after the output. NULL (default) defers to \code{joutput()}'s
#'   \code{variable.id} setting. Not a logical.
#' @param value.id Character or NULL. Value-label display mode for the
#'   group descriptives rows: \code{"both"} (\code{"code: label"}),
#'   \code{"values"} (bare code), or \code{"labels"} (the label, degrading to
#'   the bare code where a code has none).
#'   \code{"legend"} and \code{"legend.bottom"} keep the bare code in the
#'   table and print a value-label legend after it (\code{"legend"}
#'   per-table, \code{"legend.bottom"} consolidated where multiple tables
#'   are produced). A no-op for grouping variables with
#'   no value labels. NULL (default) defers to \code{joutput()}'s
#'   \code{value.id} setting. Not a logical.
#' @param full Logical. If TRUE, turns on effect.size, levene, and ci
#'   all at once. Does not override explicit FALSE values.
#'
#' @return Invisibly returns a list of class \code{jst_ttest} containing:
#'   \code{model} (the \code{t.test} result), \code{model_frame} (the analysis
#'   data frame used for plotting), \code{test_type}, \code{formula},
#'   \code{descriptives}, \code{t}, \code{df}, \code{p}, \code{mean_difference},
#'   \code{ci} (95% CI), \code{cohens_d}, \code{d_label}, \code{n}, and
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
#' @param digits Integer or NULL. Number of decimal places for continuous
#'   statistics in the output tables (range 0-7; \code{digits = 0} prints
#'   whole numbers with no trailing decimal point). Does not affect p-values,
#'   percentages, or integer quantities (counts, N, degrees of freedom),
#'   which keep their own fixed conventions. NULL (default) defers to
#'   \code{joutput()}'s \code{digits} setting (default 3).
#' @param case.processing.detail Per-call override of the Case
#'   Processing Summary detail tier: one of \code{"none"},
#'   \code{"totals"}, or \code{"per_code"}. \code{NULL} (default)
#'   uses the active \code{joutput()} level default.
jt <- function(formula, data, paired = FALSE, welch = FALSE,
               effect.size = NULL, levene = NULL, ci = NULL,
               subset = NULL, variable.id = NULL, value.id = NULL,
               case.processing.detail = NULL, full = FALSE, digits = NULL) {

  digits_n <- .jst_resolve_digits(digits)

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
  ci          <- .jst_resolve_toggle("means.ci",    ci)
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

  # Pre-conversion label source: variable labels survive here intact (mf's
  # row subset would drop them from plain-numeric columns; the DV's haven ->
  # numeric coercion below would drop them from labelled columns). Frozen by
  # copy-on-modify, so later data[[...]] <- conversions do not affect it.
  lab_src <- data

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
    group_val_labels <- labelled::val_labels(group_var)
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

  # Variable label display mode. jt is a collapse layout: under "labels"
  # the DV and grouping-variable names in the Group Descriptives caption are
  # swapped for their labels (group levels in the rows stay as value
  # labels); "legend"/"legend.bottom" collapse to a single legend after the
  # output. Label lookups use the pristine pre-conversion source lab_src.
  vlmode     <- .jst_resolve_variable_id(variable.id)
  value_mode <- .jst_resolve_value_id(value.id)
  dv_disp    <- .jst_combine_id(dv_name,    .jst_label_or_name(lab_src, dv_name),    vlmode)
  group_disp <- .jst_combine_id(group_name, .jst_label_or_name(lab_src, group_name), vlmode)

  # Levene's test
  if (levene && !paired) {
    group_factor  <- data[[group_name]]
    dv_vals       <- data[[dv_name]]
    group_means   <- tapply(dv_vals, group_factor, mean, na.rm = TRUE)
    abs_devs      <- abs(dv_vals - group_means[group_factor])
    levene_model  <- stats::aov(abs_devs ~ group_factor)
    levene_result <- summary(levene_model)[[1]]
    levene_f      <- round(levene_result$`F value`[1], digits_n)
    levene_p      <- levene_result$`Pr(>F)`[1]
    levene_p_fmt  <- .jst_fmt_p(levene_p)

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
      levene_p_note  <- .jst_fmt_p(levene_p)
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
    group_labels <- .jst_format_value_labels(original_codes, group_val_labels,
                                             value_mode)
  } else {
    group_labels <- levels
  }

  desc_table <- data.frame(
    Group = group_labels,
    N     = c(length(group1_data), length(group2_data)),
    Mean  = round(c(mean(group1_data), mean(group2_data)), digits_n),
    SD    = round(c(sd(group1_data),   sd(group2_data)),   digits_n),
    stringsAsFactors = FALSE
  )

  .jst_print_table(desc_table,
                   caption = paste("Group Descriptives:", dv_disp, "by", group_disp),
                   row.names = FALSE)
  cat("\n")

  # Run t-test
  if (paired) {
    result <- t.test(group1_data, group2_data, paired = TRUE)
  } else {
    result <- t.test(formula, data = data, var.equal = !welch)
  }

  p_val <- result$p.value
  p_fmt <- .jst_fmt_p(p_val)

  test_table <- data.frame(
    t               = round(result$statistic, digits_n),
    df              = round(result$parameter, 1),
    p               = p_fmt,
    Mean_Difference = round(mean(group1_data) - mean(group2_data), digits_n),
    stringsAsFactors = FALSE,
    row.names = NULL
  )

  if (ci) {
    test_table$CI_Lower <- round(result$conf.int[1], digits_n)
    test_table$CI_Upper <- round(result$conf.int[2], digits_n)
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
    cat(paste0("\n", d_label, ": ", round(cohens_d, digits_n), "\n"))
  }

  .jst_print_legends(lab_src, c(dv_name, group_name), group_name,
                     vlmode, value_mode)

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
#' @param ci Logical or NULL. If TRUE, adds 95% confidence intervals to the
#'   group descriptives table. If NULL (default), defers to \code{joutput()}.
#' @param subset An optional unquoted logical expression (e.g.
#'   \code{Group == 1}) to subset cases for this call only. Applied after
#'   jcomplete and jsubset. Does not affect other function calls.
#' @param variable.id Character or NULL. Variable label display mode: one of
#'   \code{"both"}, \code{"names"}, \code{"labels"}, \code{"legend"}, or
#'   \code{"legend.bottom"}. \code{"names"} shows variable names only;
#'   \code{"both"} shows \code{"name: label"};
#'   \code{"labels"} shows the DV and grouping-variable labels wherever the
#'   variable name appears (table captions and the ANOVA Source row; group
#'   levels follow the value.id mode) -- best for short labels;
#'   \code{"legend"}/\code{"legend.bottom"} keep names and print a label
#'   legend after the output. NULL (default) defers to \code{joutput()}'s
#'   \code{variable.id} setting. Not a logical.
#' @param value.id Character or NULL. Value-label display mode for the
#'   group descriptives rows: \code{"both"} (\code{"code: label"}),
#'   \code{"values"} (bare code), or \code{"labels"} (the label, degrading to
#'   the bare code where a code has none).
#'   \code{"legend"} and \code{"legend.bottom"} keep the bare code in the
#'   table and print a value-label legend after it (\code{"legend"}
#'   per-table, \code{"legend.bottom"} consolidated where multiple tables
#'   are produced). A no-op for grouping variables with
#'   no value labels. NULL (default) defers to \code{joutput()}'s
#'   \code{value.id} setting. Not a logical.
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
#' @param digits Integer or NULL. Number of decimal places for continuous
#'   statistics in the output tables (range 0-7; \code{digits = 0} prints
#'   whole numbers with no trailing decimal point). Does not affect p-values,
#'   percentages, or integer quantities (counts, N, degrees of freedom),
#'   which keep their own fixed conventions. NULL (default) defers to
#'   \code{joutput()}'s \code{digits} setting (default 3).
#' @param case.processing.detail Per-call override of the Case
#'   Processing Summary detail tier: one of \code{"none"},
#'   \code{"totals"}, or \code{"per_code"}. \code{NULL} (default)
#'   uses the active \code{joutput()} level default.
jaov <- function(formula, data, welch = FALSE, posthoc = NULL,
                 effect.size = NULL, levene = NULL, ci = NULL,
                 subset = NULL, variable.id = NULL, value.id = NULL,
                 case.processing.detail = NULL, full = FALSE, digits = NULL) {

  digits_n <- .jst_resolve_digits(digits)

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
  ci           <- .jst_resolve_toggle("means.ci",   ci)
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

  # Pre-conversion label source (see jt): variable labels survive here intact;
  # mf's row subset and the DV's haven -> numeric coercion below would drop
  # them. Frozen by copy-on-modify.
  lab_src <- data

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
    group_val_labels <- labelled::val_labels(group_var)
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

  # Variable label display mode. jaov is a collapse layout: under "labels"
  # the DV and grouping-variable names are swapped for their labels wherever
  # the variable name appears (descriptives/Welch captions and the ANOVA
  # Source row); group levels follow the value.id mode. "legend"/"legend.bottom"
  # collapse to one legend after the output. Lookups use the pristine lab_src.
  vlmode     <- .jst_resolve_variable_id(variable.id)
  value_mode <- .jst_resolve_value_id(value.id)
  dv_disp    <- .jst_combine_id(dv_name,    .jst_label_or_name(lab_src, dv_name),    vlmode)
  group_disp <- .jst_combine_id(group_name, .jst_label_or_name(lab_src, group_name), vlmode)
  # Per-level group display under the active value.id mode (indexed [i] in
  # the descriptives loop below). Empty when the grouping variable is unlabelled.
  group_value_disp <- if (is_labelled) {
    .jst_format_value_labels(original_codes, group_val_labels, value_mode)
  } else {
    NULL
  }

  # Levene's test
  if (levene) {
    group_factor  <- data[[group_name]]
    dv_vals       <- data[[dv_name]]
    group_means   <- tapply(dv_vals, group_factor, mean, na.rm = TRUE)
    abs_devs      <- abs(dv_vals - group_means[group_factor])
    levene_model  <- stats::aov(abs_devs ~ group_factor)
    levene_result <- summary(levene_model)[[1]]
    levene_f      <- round(levene_result$`F value`[1], digits_n)
    levene_p      <- levene_result$`Pr(>F)`[1]
    levene_p_fmt  <- .jst_fmt_p(levene_p)

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
      levene_p_note  <- .jst_fmt_p(levene_p)
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
      group_value_disp[i]
    } else {
      lvl
    }

    row <- data.frame(
      Group = group_label,
      N     = n,
      Mean  = round(m, digits_n),
      SD    = round(s, digits_n),
      stringsAsFactors = FALSE
    )

    if (ci) {
      se     <- s / sqrt(n)
      t_crit <- stats::qt(0.975, df = n - 1)
      row$CI_Lower <- round(m - t_crit * se, digits_n)
      row$CI_Upper <- round(m + t_crit * se, digits_n)
    }

    row
  })
  desc_table <- do.call(rbind, desc_rows)

  if (ci) {
    .jst_print_table(desc_table,
                     caption = paste("Group Descriptives:", dv_disp, "by", group_disp),
                     col.names = c("Group", "N", "Mean", "SD",
                                   "95% CI Lower", "95% CI Upper"),
                     row.names = FALSE)
  } else {
    .jst_print_table(desc_table,
                     caption = paste("Group Descriptives:", dv_disp, "by", group_disp),
                     row.names = FALSE)
  }
  cat("\n")

  if (welch) {
    model <- oneway.test(formula, data = data, var.equal = FALSE)

    p_val <- model$p.value
    p_fmt <- .jst_fmt_p(p_val)

    welch_table <- data.frame(
      F_value = round(model$statistic, digits_n),
      df1     = round(model$parameter[1], 1),
      df2     = round(model$parameter[2], 1),
      p_value = p_fmt,
      stringsAsFactors = FALSE,
      row.names = NULL
    )

    .jst_print_table(welch_table,
                     caption = paste("Welch's ANOVA:", dv_disp, "by", group_disp),
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
      cat("\nEta-squared:", round(eta_sq, digits_n), "\n")
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
    p_fmt <- .jst_fmt_p(p_val)

    anova_table <- data.frame(
      Source         = c(group_disp, "Residual", "Total"),
      df             = c(result$Df, total_df),
      Sum_of_Squares = round(c(result$`Sum Sq`, total_ss), digits_n),
      Mean_Square    = c(round(result$`Mean Sq`, digits_n), NA),
      F_value        = c(round(result$`F value`[1], digits_n), NA, NA),
      p_value        = c(p_fmt, NA, NA),
      stringsAsFactors = FALSE
    )

    .jst_print_table(anova_table,
                     caption = paste("ANOVA:", dv_disp, "by", group_disp),
                     col.names = c("Source", "df", "Sum of Squares",
                                   "Mean Square", "F", "p"),
                     row.names = FALSE)

    # Always compute eta-squared
    eta_sq <- result$`Sum Sq`[1] / sum(result$`Sum Sq`)

    if (effect.size) {
      cat("\nEta-squared:", round(eta_sq, digits_n), "\n")
    }

    if (posthoc) {
      tukey        <- stats::TukeyHSD(model)
      tukey_result <- as.data.frame(tukey[[1]])

      tukey_p     <- tukey_result$`p adj`
      tukey_p_fmt <- .jst_fmt_p(tukey_p)

      tukey_table <- data.frame(
        Comparison = rownames(tukey_result),
        Difference = round(tukey_result$diff, digits_n),
        CI_Lower   = round(tukey_result$lwr,  digits_n),
        CI_Upper   = round(tukey_result$upr,  digits_n),
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

  .jst_print_legends(lab_src, c(dv_name, group_name), group_name,
                     vlmode, value_mode)

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
#' @param variable.id Character or NULL. Variable label display mode: one of
#'   \code{"both"}, \code{"names"}, \code{"labels"}, \code{"legend"}, or
#'   \code{"legend.bottom"}. \code{"names"} shows variable names only;
#'   \code{"both"} shows \code{"name: label"};
#'   \code{"labels"} shows the row/column variable labels (table header and
#'   caption; cell value levels follow the value.id mode) -- best for short labels;
#'   \code{"legend"}/\code{"legend.bottom"} keep names and print a label
#'   legend after the table. NULL (default) defers to \code{joutput()}'s
#'   \code{variable.id} setting. Not a logical.
#' @param value.id Character or NULL. Value-label display mode for both
#'   table axes: \code{"both"} (\code{"code: label"}), \code{"values"} (bare
#'   code), or \code{"labels"} (the label, degrading to the bare code where a
#'   code has none).
#'   \code{"legend"} and \code{"legend.bottom"} keep the bare code in the
#'   table and print a value-label legend after it (\code{"legend"}
#'   per-table, \code{"legend.bottom"} consolidated where multiple tables
#'   are produced). A no-op for axis variables with no value labels. NULL
#'   (default) defers to \code{joutput()}'s \code{value.id} setting. Not a
#'   logical.
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
#' @param digits Integer or NULL. Number of decimal places for continuous
#'   statistics in the output tables (range 0-7; \code{digits = 0} prints
#'   whole numbers with no trailing decimal point). Does not affect p-values,
#'   percentages, or integer quantities (counts, N, degrees of freedom),
#'   which keep their own fixed conventions. NULL (default) defers to
#'   \code{joutput()}'s \code{digits} setting (default 3).
#' @param case.processing.detail Per-call override of the Case
#'   Processing Summary detail tier: one of \code{"none"},
#'   \code{"totals"}, or \code{"per_code"}. \code{NULL} (default)
#'   uses the active \code{joutput()} level default.
jcrosstab <- function(formula, data, chisq = FALSE, expected = FALSE,
                      row.pct = TRUE, col.pct = FALSE, subset = NULL,
                      variable.id = NULL, value.id = NULL,
                      case.processing.detail = NULL, digits = NULL) {

  digits_n <- .jst_resolve_digits(digits)

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
  # Pre-conversion label source (see jt): row/col labels survive here intact;
  # mf's row subset and the factor coercions below would drop plain-numeric
  # labels. Frozen by copy-on-modify.
  lab_src <- data
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
    row_vl    <- labelled::val_labels(row_var)
    row_var   <- haven::as_factor(row_var)
  } else if (!is.factor(row_var)) {
    row_var <- factor(row_var)
  }

  if (col_labelled) {
    col_codes <- sort(unique(.jst_as_numeric(col_var[!is.na(col_var)])))
    col_vl    <- labelled::val_labels(col_var)
    col_var   <- haven::as_factor(col_var)
  } else if (!is.factor(col_var)) {
    col_var <- factor(col_var)
  }

  # Variable label display mode. jcrosstab is a collapse layout: under
  # "labels" the row/column variable names (the first column header and the
  # caption) are swapped for their labels; the cell value levels follow the value.id mode.
  # "legend"/"legend.bottom" collapse to one legend after the table(s).
  vlmode   <- .jst_resolve_variable_id(variable.id)
  value_mode <- .jst_resolve_value_id(value.id)
  row_disp <- .jst_combine_id(row_name, .jst_label_or_name(lab_src, row_name), vlmode)
  col_disp <- .jst_combine_id(col_name, .jst_label_or_name(lab_src, col_name), vlmode)

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

  row_labels <- if (row_labelled) .jst_format_value_labels(row_codes, row_vl, value_mode) else row_levels
  col_labels <- if (col_labelled) .jst_format_value_labels(col_codes, col_vl, value_mode) else col_levels

  obs_table  <- table(row_var, col_var)
  chi_result <- suppressWarnings(stats::chisq.test(obs_table))
  exp_table  <- chi_result$expected

  p_val <- chi_result$p.value
  p_fmt <- .jst_fmt_p(p_val)

  n_rows <- length(row_levels)
  n_cols <- length(col_levels)
  header <- c(.jst_truncate_ellipsis(row_disp), col_labels, "Total")

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
                   caption   = paste("Crosstab:", row_disp, "by", col_disp),
                   row.names = FALSE)
  cat("\n")

  # Chi-square test (only if requested)
  if (chisq) {
    chi_table <- data.frame(
      Chi_Square = round(chi_result$statistic, digits_n),
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

  .jst_print_legends(lab_src, c(row_name, col_name), c(row_name, col_name),
                     vlmode, value_mode)

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
#' @param variable.id Character or NULL. Variable label display mode: one of
#'   \code{"both"}, \code{"names"}, \code{"labels"}, \code{"legend"}, or
#'   \code{"legend.bottom"}. \code{"names"} shows variable names only;
#'   \code{"both"} shows \code{"name: label"};
#'   \code{"labels"} shows variable labels as the matrix row/column headers
#'   (honored even if the matrix grows wide -- best for short labels; rerun
#'   with a legend mode otherwise); \code{"legend"}/\code{"legend.bottom"}
#'   keep names and print a label legend after the table. NULL (default)
#'   defers to \code{joutput()}'s \code{variable.id} setting. Not a logical.
#' @param numeric Optional character vector of variable names to treat as
#'   continuous for this call (the per-call counterpart of \code{jnumeric()}).
#'   Its only effect in \code{jcorr()} is to suppress the structural "seems
#'   categorical" caution for those variables; correlations are computed the
#'   same way regardless (labelled variables are coerced to numeric either way).
#' @param categorical Not supported by \code{jcorr()} yet. Correlation
#'   requires numeric variables; supplying \code{categorical} raises an error
#'   pointing to \code{jcrosstab()} for association between categorical
#'   variables. (How \code{jcorr()} should handle an asserted-categorical
#'   variable is a parked design decision.)
#' @param count Optional character vector of variable names to treat as counts
#'   for this call (the per-call counterpart of \code{jcount()}). A count is
#'   numeric-like here, so it behaves like \code{numeric}: it suppresses the
#'   "seems categorical" caution for those variables.
#' @param value.id Not supported by \code{jcorr()}. The function does not
#'   display value labels, so passing this argument is an error. It exists
#'   only to return a clear message rather than misreporting the token as a
#'   missing variable. Leave at NULL (default).
#' @param layout Character or NULL. How each correlation cell is laid out
#'   when three or more variables are given: \code{"wide"} (default) puts r
#'   and its p-value on one line with N on a second line beneath;
#'   \code{"stacked"} places r, p, and N on three separate lines, giving a
#'   narrower table that fits more variables before wrapping. Ignored for a
#'   single pair (two variables), which always prints a one-line summary.
#'   NULL (default) defers to the \code{corr.layout} setting in
#'   \code{joptions()} (itself defaulting to "wide").
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
#' @param digits Integer or NULL. Number of decimal places for continuous
#'   statistics in the output tables (range 0-7; \code{digits = 0} prints
#'   whole numbers with no trailing decimal point). Does not affect p-values,
#'   percentages, or integer quantities (counts, N, degrees of freedom),
#'   which keep their own fixed conventions. NULL (default) defers to
#'   \code{joutput()}'s \code{digits} setting (default 3).
#' @param case.processing.detail Per-call override of the Case
#'   Processing Summary detail tier: one of \code{"none"},
#'   \code{"totals"}, or \code{"per_code"}. \code{NULL} (default)
#'   uses the active \code{joutput()} level default.
jcorr <- function(data, ..., method = "pearson", subset = NULL, variable.id = NULL,
                  numeric = NULL, categorical = NULL, count = NULL,
                  value.id = NULL, layout = NULL, case.processing.detail = NULL,
                  digits = NULL) {

  digits_n <- .jst_resolve_digits(digits)

  # jcorr has no per-code surface to display value labels on (its per-pair Ns
  # live in the matrix, not a value legend), so value.id is accepted only to
  # give an explicit, accurate error rather than the misleading "variable not
  # found: <token>" that resulted when the token fell into the dots. A global
  # joutput(value.id=) never arrives here as a per-call arg, so a non-NULL
  # value.id can only be an explicit per-call argument. (Session 62, Option A)
  if (!is.null(value.id)) {
    stop("value.id is not supported by jcorr(); it does not display ",
         "value labels.", call. = FALSE)
  }

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

  # -- Per-call classification overrides -------------------------------------
  # jcorr is pairwise and numeric-coercing. numeric=/count= assert a numeric-
  # like analysis role for the named variables; here that serves a single
  # purpose -- suppressing the structural "seems categorical" caution (consulted
  # by .jst_role_asserted_numeric at the per-variable loop below). A count is
  # numeric-like in this context, so count= behaves like numeric=. categorical=
  # is accepted only to fail cleanly: what jcorr should DO with an asserted-
  # categorical variable is a parked design (see
  # JStats_Classification_Registry_Reference Part 4), so rather than coercing a
  # variable the user asked to treat categorically, jcorr stops and points to
  # jcrosstab().
  if (!is.null(categorical)) {
    stop("categorical = is not supported by jcorr() yet: correlation requires ",
         "numeric variables. For association between categorical variables use ",
         "jcrosstab() instead.", call. = FALSE)
  }
  for (.arg in c("numeric", "count")) {
    .val <- get(.arg)
    if (!is.null(.val)) {
      .bad <- setdiff(.val, variable_names)
      if (length(.bad) > 0) {
        stop(.arg, " argument: ", paste0("'", .bad, "'", collapse = ", "),
             " not found among the variables passed to jcorr(). Check for typos.",
             call. = FALSE)
      }
    }
  }
  # numeric and count are both numeric-like assertions, so naming a variable in
  # both is harmless rather than a conflict (mirrors jlm).

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
  .cat_red(paste0(method_label, " Bivariate Correlation",
                  if (length(variable_names) == 2) "" else "s", "\n"))
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
    .ov <- if (v %in% count) "count" else if (v %in% numeric) "numeric" else NULL
    if (.jst_is_discrete_integer(data[[v]], v, .jst_data_name) &&
        !.jst_role_asserted_numeric(data[[v]], v, .jst_data_name,
                                    override = .ov)) {
      warning(paste0(v, " seems categorical. Pearson correlations assume ",
                     "continuous/interval data."),
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

  # --- Resolve display options -----------------------------------------------
  layout <- .jst_resolve_corr_layout(layout)
  vlmode <- .jst_resolve_variable_id(variable.id)
  use_labels <- vlmode %in% c("labels", "both")
  # Display names for the row-label column and the column headers. labels/both
  # substitute the variable label (capped); names and the legend modes keep
  # bare names in the table (legend modes append a code->name legend below).
  disp_names <- if (use_labels) {
    vapply(variable_names,
           function(v) .jst_combine_id(v, .jst_label_or_name(data, v), vlmode, cap = TRUE),
           character(1))
  } else {
    variable_names
  }

  # --- Cell formatters (shared by both layouts and the 2-var block) ----------
  # r: |r| <= 1 so the integer-part zero carries no information -- drop it,
  # SPSS-style (".45" / "-.45"). The space flag reserves a sign slot so the
  # printer's "ln" no-trim alignment lines decimals up down a column even when
  # some r are negative. Exact +/-1 keeps its "1" (the sub() only bites "0.").
  fmt_r <- function(x) {
    s <- sprintf(paste0("% .", digits_n, "f"), x)
    s <- sub("^([ -])0\\.", "\\1.", s)
    # Negative zero -- a tiny negative r that rounds to zero at this precision
    # (e.g. "-.000") -- reads as an error to most users; show it unsigned.
    # Keep the sign slot as a space so the column still aligns.
    if (startsWith(s, "-") && !grepl("[1-9]", s)) s <- sub("^-", " ", s)
    s
  }
  # p: drop the leading zero; "<.001" floor. spaced = TRUE gives the roomy
  # "p = .045" / "p < .001" for the 2-var block; FALSE the tight "p=.045" /
  # "p<.001" for the in-matrix cells.
  fmt_p <- function(p, spaced = FALSE) {
    eq <- if (spaced) "p = " else "p="
    lt <- if (spaced) "p < .001" else "p<.001"
    if (!is.na(p) && p < 0.001) lt
    else paste0(eq, sub("^0\\.", ".", sprintf("%.3f", p)))
  }

  # --- Single pair: compact one-line block instead of a 2x2 matrix -----------
  # SPSS and Stata both keep the matrix form for one pair, but a single
  # correlation has exactly one number of interest; the grid is scaffolding.
  # layout is accepted-but-ignored here; legend modes degrade to plain names.
  if (n_vars == 2) {
    cat("  ", disp_names[1], " & ", disp_names[2], ":  r = ",
        trimws(fmt_r(r_matrix[2, 1])), ",  ",
        fmt_p(p_matrix[2, 1], spaced = TRUE), ",  N = ",
        n_matrix[2, 1], "\n", sep = "")

    if (has_ties) {
      cat("\nNote: Spearman p-values are approximate due to tied values in the data.\n")
    }
    cat("\n")

    mf <- data[, variable_names, drop = FALSE]
    ret <- list(r = r_matrix, p = p_matrix, n = n_matrix, method = method,
                model_frame = mf, sample_info = sample_info,
                labels = stats::setNames(
                  vapply(variable_names, function(v) .jst_label_or_name(data, v),
                         character(1)), variable_names))
    class(ret) <- "jst_corr"
    return(invisible(ret))
  }

  # --- 3+ variables: lower-triangular matrix, cells stacked per layout -------
  # Each variable contributes one or more physical rows (wide: r+p on top, N
  # below; stacked: r / p / N) followed by a blank spacer row. The row label
  # sits on the first physical row only; empty continuation rows (e.g. the
  # first variable's N row) are dropped. The label is a real first column
  # (left-aligned) rather than data-frame row names, which must be unique --
  # the continuation/spacer rows all need a blank label.
  lab_col   <- character(0)
  data_rows <- list()
  push_row  <- function(label, cells) {
    lab_col[[length(lab_col) + 1L]]   <<- label
    data_rows[[length(data_rows) + 1L]] <<- cells
  }
  blank_cells <- rep("", n_vars)

  for (i in seq_len(n_vars)) {
    r_line <- character(n_vars)   # r (with inline p in wide layout)
    p_line <- character(n_vars)   # stacked layout only
    n_line <- character(n_vars)
    for (j in seq_len(n_vars)) {
      if (j == i) {
        r_line[j] <- " 1"
      } else if (j < i) {
        rv <- fmt_r(r_matrix[i, j])
        if (layout == "wide") {
          r_line[j] <- paste0(rv, " (", fmt_p(p_matrix[i, j]), ")")
        } else {
          r_line[j] <- rv
          p_line[j] <- fmt_p(p_matrix[i, j])
        }
        n_line[j] <- paste0("N=", n_matrix[i, j])
      }
    }
    push_row(disp_names[i], r_line)
    if (layout == "stacked" && any(nzchar(p_line))) push_row("", p_line)
    if (any(nzchar(n_line))) push_row("", n_line)
    if (i < n_vars) push_row("", blank_cells)   # spacer between blocks
  }

  display_df <- data.frame(lab_col, do.call(rbind, data_rows),
                           stringsAsFactors = FALSE, check.names = FALSE)
  names(display_df) <- c("", disp_names)

  .jst_print_table(display_df,
                   col.names = c("", disp_names),
                   row.names = FALSE,
                   align     = c("l", rep("ln", n_vars)),
                   caption   = paste0("Bivariate Correlations (", method_label, ")"))

  if (vlmode %in% c("legend", "legend.bottom")) {
    cat("\n")
    .print_var_labels(data, variable_names)
  }

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
    sample_info = sample_info,
    labels      = stats::setNames(
      vapply(variable_names, function(v) .jst_label_or_name(data, v),
             character(1)), variable_names)
  )
  class(ret) <- "jst_corr"
  invisible(ret)
}


# -- Regression model helpers (jlm and jlogistic) -----------------------------

#' Internal helper: value labels in val_labels() form for any variable type
#'
#' Returns the variable's value labels in \code{labelled::val_labels()} form
#' (names are the labels, values are the codes) so the result can be fed
#' straight to \code{.jst_format_value_labels()}. Plain numeric variables have
#' no labels and return NULL (so value.id degrades to bare codes). Factor and
#' character variables get synthetic 1..k codes whose ordering mirrors
#' \code{.jst_make_dummy_names()}, so they line up with a dummy registration
#' built from the same column.
#'
#' @param x A variable (haven-labelled, factor, character, or numeric).
#'
#' @return A named integer/numeric vector in val_labels() form, or NULL.
#'
#' @keywords internal
.jst_var_value_labels <- function(x) {
  if (haven::is.labelled(x)) return(labelled::val_labels(x))
  if (is.factor(x)) {
    lv <- levels(droplevels(x))
    return(stats::setNames(seq_along(lv), lv))
  }
  if (is.character(x)) {
    u <- sort(unique(x[!is.na(x) & nzchar(x)]))
    return(stats::setNames(seq_along(u), u))
  }
  NULL
}

#' Internal helper: collect multi-category dummy registrations for grouping
#'
#' Gathers the registration-shaped objects for the MULTI-category dummy
#' variables in a fitted model, from both pathways that create dummies:
#' \code{jdummy()} registrations and the in-flight auto-categorical /
#' \code{categorical =} registrations built inside jlm()/jlogistic(). A
#' registration qualifies only when it produced two or more dummy columns and
#' at least one of those columns is actually in the model. The two-or-more
#' gate is what keeps single-contrast variables -- 0/1 and 1/2 numeric
#' dichotomies, and jdummy-registered two-level variables -- out of the
#' grouped layout, so their coefficient rows are left exactly as they are.
#'
#' @param dummy_regs List of jdummy registrations (from \code{.jst_get_dummy()}),
#'   or NULL.
#' @param auto_cat_regs Named list of in-flight registrations keyed by variable
#'   name (the stored object carries no \code{var_name} field, so it is set
#'   here from the list name).
#' @param dummy_coef_names Character vector of dummy column names present in
#'   the fitted model.
#'
#' @return A list of registration objects, each guaranteed to have
#'   \code{var_name} set and two or more \code{dummy_names}.
#'
#' @keywords internal
.jst_collect_multicat_regs <- function(dummy_regs, auto_cat_regs,
                                       dummy_coef_names) {
  out <- list()
  if (!is.null(dummy_regs)) {
    for (reg in dummy_regs) {
      if (length(reg$dummy_names) >= 2L &&
          any(reg$dummy_names %in% dummy_coef_names)) {
        out[[length(out) + 1L]] <- reg
      }
    }
  }
  if (length(auto_cat_regs) > 0) {
    for (vn in names(auto_cat_regs)) {
      reg <- auto_cat_regs[[vn]]
      reg$var_name <- vn
      if (length(reg$dummy_names) >= 2L &&
          any(reg$dummy_names %in% dummy_coef_names)) {
        out[[length(out) + 1L]] <- reg
      }
    }
  }
  out
}

#' Internal helper: group multi-category dummy rows in a coefficient table
#'
#' Restructures a coefficient display data frame so each multi-category dummy
#' variable prints as a header row -- the variable's name (or its label under
#' \code{variable.id = "labels"}), optionally carrying its reference category
#' as \code{"(ref = ...)"} -- with the variable's categories indented two
#' spaces beneath it. Category-row labels follow the resolved value.id mode
#' (both / values / labels). Rows that are not multi-category dummy members
#' (the intercept, continuous predictors, single-contrast dichotomies, factor
#' terms) pass through unchanged and in place.
#'
#' The result carries the display label for each row in a leading
#' \code{.rowlab} column rather than in the row names, so the caller prints it
#' with \code{row.names = FALSE} and an \code{"ln"} (left, no-trim) alignment
#' on that column to preserve the indent. Using a real column sidesteps the
#' data-frame unique-row-name constraint, which bare numeric codes would
#' routinely violate. Header rows carry blank cells in every data column;
#' category-row cells (including any standardized-beta column) are copied
#' verbatim from \code{disp_df}, so a future standardization mode that
#' populates beta on these rows needs no change here.
#'
#' @param disp_df The flat coefficient display data frame (character cells),
#'   with coefficient names as its row names.
#' @param regs List of multi-category registrations from
#'   \code{.jst_collect_multicat_regs()}.
#' @param value_mode Resolved value.id mode for the category rows: one of
#'   \code{"both"}, \code{"values"}, \code{"labels"} (legend modes are folded
#'   to \code{"both"} by the caller).
#' @param vlmode Resolved variable.id mode; \code{"labels"} makes the header
#'   use the variable's label.
#' @param lab_src Pre-conversion data frame used as the label source.
#' @param show_ref Logical. Whether to fold the reference category into each
#'   variable's header.
#'
#' @return A data frame whose first column \code{.rowlab} holds the display
#'   labels and whose remaining columns are \code{disp_df}'s columns verbatim.
#'
#' @keywords internal
.jst_group_dummy_coefs <- function(disp_df, regs, value_mode, vlmode,
                                    lab_src, show_ref) {
  data_cols <- names(disp_df)
  if (length(regs) == 0) {
    out <- data.frame(.rowlab = rownames(disp_df),
                      as.data.frame(as.matrix(disp_df), stringsAsFactors = FALSE,
                                    check.names = FALSE),
                      stringsAsFactors = FALSE, check.names = FALSE)
    rownames(out) <- NULL
    colnames(out) <- c(".rowlab", data_cols)
    return(out)
  }

  dummy_to_group <- list()   # dummy column name -> group key (var_name)
  cat_display    <- list()   # dummy column name -> indented category label
  header_display <- list()   # group key -> header label

  for (reg in regs) {
    gkey <- reg$var_name
    if (is.null(gkey) || !nzchar(gkey)) next
    vl <- .jst_var_value_labels(
      if (gkey %in% names(lab_src)) lab_src[[gkey]] else NULL)

    head_name <- if (identical(vlmode, "labels")) {
      .jst_label_or_name(lab_src, gkey)
    } else {
      gkey
    }
    if (isTRUE(show_ref)) {
      ref_disp  <- .jst_format_value_labels(reg$codes[reg$ref_idx], vl, value_mode)
      head_name <- paste0(head_name, " (ref = ", ref_disp, ")")
    }
    header_display[[gkey]] <- head_name

    for (j in seq_along(reg$dummy_names)) {
      dn   <- reg$dummy_names[j]
      code <- reg$codes[reg$non_ref_idx[j]]
      cat_display[[dn]]    <- paste0("  ",
        .jst_format_value_labels(code, vl, value_mode))
      dummy_to_group[[dn]] <- gkey
    }
  }

  disp_mat <- as.matrix(disp_df)
  rn       <- rownames(disp_df)
  blank    <- rep("", ncol(disp_mat))

  labels  <- character(0)
  body    <- vector("list", 0L)
  emitted <- character(0)

  for (i in seq_len(nrow(disp_mat))) {
    nm <- rn[i]
    g  <- dummy_to_group[[nm]]
    if (!is.null(g)) {
      if (!(g %in% emitted)) {
        labels <- c(labels, header_display[[g]])
        body[[length(body) + 1L]] <- blank
        emitted <- c(emitted, g)
      }
      labels <- c(labels, cat_display[[nm]])
      body[[length(body) + 1L]] <- disp_mat[i, ]
    } else {
      labels <- c(labels, nm)
      body[[length(body) + 1L]] <- disp_mat[i, ]
    }
  }

  body_mat <- do.call(rbind, body)
  out <- data.frame(.rowlab = labels,
                    as.data.frame(body_mat, stringsAsFactors = FALSE,
                                  check.names = FALSE),
                    stringsAsFactors = FALSE, check.names = FALSE)
  rownames(out) <- NULL
  colnames(out) <- c(".rowlab", data_cols)
  out
}

#' Internal helper: print the outcome name beneath a regression table
#'
#' Names the model outcome on its own line directly below the Coefficients
#' table, for the non-legend variable.id modes. The line follows variable.id:
#' the bare name under "names", the variable label under "labels", and
#' "name: label" under "both" -- each degrading to the bare name when the
#' outcome carries no variable label. Under the legend modes ("legend",
#' "legend.bottom") nothing is printed here, because the variable-label legend
#' (.print_model_var_labels) already carries the outcome in its Outcome
#' section. Emits a leading blank line so it sits one line below the table.
#'
#' @param data Pre-conversion label source (the data frame jlm()/jlogistic()
#'   captured for label lookups).
#' @param dv_name The outcome variable name (the response in the model
#'   formula).
#' @param vlmode Resolved variable.id mode.
#'
#' @return Invisibly NULL; called for its printing side effect.
#'
#' @keywords internal
.jst_print_outcome_line <- function(data, dv_name, vlmode) {
  if (vlmode %in% c("legend", "legend.bottom")) return(invisible(NULL))
  nm  <- dv_name
  lab <- .jst_label_or_name(data, dv_name)
  shown <- if (identical(vlmode, "labels")) {
    lab
  } else if (identical(vlmode, "both") && !identical(lab, nm)) {
    paste0(nm, ": ", lab)
  } else {
    nm
  }
  cat("\nOutcome: ", shown, "\n", sep = "")
  invisible(NULL)
}

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

#' Internal helper: relabel cleaned coefficient names with variable labels
#'
#' For the \code{"labels"} variable.id display mode (jlm / jlogistic). Given
#' the cleaned names from \code{.jst_clean_coef_names()} -- numeric
#' predictors as the bare variable name, factor terms as
#' \code{"<var><sep><level>"}, intercept as \code{"(Intercept)"} -- replaces
#' the variable-name portion of each term with the variable's label,
#' preserving the \code{"<sep><level>"} decoration on factor terms. The
#' intercept, and any term not attributable to a labelled IV (e.g. a
#' clearly-named jdummy column carrying no variable label), are left
#' unchanged. Display only: the returned coefficient table keeps the cleaned
#' variable names so downstream code and the user's own indexing still work.
#'
#' @param coef_names Character vector of cleaned coefficient names.
#' @param data Data frame used to fit the model (carries variable labels).
#' @param iv_names Character vector of IV names from the model formula.
#' @param sep Character separator used by \code{.jst_clean_coef_names()}.
#'   Default \code{"-"}.
#'
#' @return Character vector the same length as \code{coef_names}.
#'
#' @keywords internal
.jst_relabel_coef_names <- function(coef_names, data, iv_names, sep = "-") {
  out <- coef_names
  for (i in seq_along(out)) {
    nm <- out[i]
    if (identical(nm, "(Intercept)")) next
    for (v in iv_names) {
      lab <- .jst_label_or_name(data, v)
      if (identical(lab, v)) next               # no label to apply
      if (identical(nm, v)) {                    # bare numeric predictor
        out[i] <- lab
        break
      }
      prefix <- paste0(v, sep)                   # factor "<var><sep><level>"
      if (startsWith(nm, prefix)) {
        out[i] <- paste0(lab, sep, substring(nm, nchar(prefix) + 1L))
        break
      }
    }
  }
  out
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
#'   \item The dependent variable is always modelled as numeric. Naming it in
#'     \code{numeric} or \code{count} does not change that; it only asserts the
#'     DV's role so the count / categorical-like note is silenced
#'     (\code{numeric}) or stated definitively (\code{count}).
#' }
#'
#' @param formula A model formula, e.g. \code{y ~ x1 + x2}.
#' @param data A data frame containing variables referenced in \code{formula}.
#' @param subset An optional unquoted logical expression (e.g.
#'   \code{Group == 1}) to subset cases for this call only. Applied after
#'   jcomplete and jsubset. Does not affect other function calls.
#' @param variable.id Character or NULL. Variable label display mode: one of
#'   \code{"both"}, \code{"names"}, \code{"labels"}, \code{"legend"}, or
#'   \code{"legend.bottom"}. \code{"names"} shows variable names only;
#'   \code{"both"} shows \code{"name: label"};
#'   \code{"labels"} replaces each coefficient's variable name with its label
#'   in the Coefficients table (factor level decoration is preserved) -- best
#'   for short labels; \code{"legend"} prints a label legend between the
#'   Coefficients table and the R-squared/fit block; \code{"legend.bottom"}
#'   prints it at the very end. NULL (default) defers to \code{joutput()}'s
#'   \code{variable.id} setting. Not a logical.
#' @param value.id Character or NULL. Value-label display mode for the dummy
#'   category rows in the Coefficients table: one of \code{"both"}
#'   (\code{"code: label"}, degrading to a bare code where a code has no
#'   label), \code{"values"} (the bare code), or \code{"labels"} (the value
#'   label, degrading to the bare code where none exists). The reference
#'   category folded into each grouped variable's header follows the same
#'   mode. \code{"legend"} and \code{"legend.bottom"} are not supported here:
#'   a coefficient table already pairs each value label with its row, so a
#'   separate legend block would only duplicate it. Passing either explicitly
#'   is an error; a \code{joutput()} default of \code{"legend"} or
#'   \code{"legend.bottom"} is tolerated and rendered as \code{"both"}, so it
#'   does not break a bare call. Variables with no value labels render
#'   identically under all supported modes. NULL (default) defers to
#'   \code{joutput()}'s \code{value.id} setting. Applies only to multi-category
#'   dummy predictors; continuous and single-contrast (dichotomous) predictors
#'   are unaffected. Not a logical.
#' @param numeric Optional character vector of variable names that should be
#'   treated as continuous (numeric) even if they have value labels. For
#'   example, \code{numeric = "Age"} or \code{numeric = c("Age", "Education")}.
#' @param categorical Optional character vector of variable names that should
#'   be treated as categorical even if they lack value labels. For example,
#'   \code{categorical = "Program"} or \code{categorical = c("Program", "Region")}.
#'   The first sorted unique value becomes the reference category. Use
#'   \code{jdummy()} for control over the reference category.
#' @param count Optional character vector of variable names to treat as counts
#'   for this call (the per-call counterpart of \code{jcount()}). On the
#'   dependent variable it speaks the count-regression caveat definitively
#'   rather than as a hedge, and applies even when the variable sits outside
#'   the structural 0-6 band. On an independent variable it behaves like
#'   \code{numeric} (a count predictor enters the model as numeric). A
#'   variable cannot be listed in both \code{count} and \code{categorical}.
#' @param ci Logical or NULL. If TRUE, appends a 95% confidence interval for
#'   each unstandardized coefficient (b) at the right of the coefficient table.
#'   If NULL (default), defers to \code{joutput()}'s regression.ci setting
#'   (off at minimal and standard, on at full). Computed as the closed form
#'   b +/- t(.975, residual df) * SE.
#' @param diagnostics Logical, character vector, or NULL. If TRUE, prints VIF
#'   table and diagnostic plots. If a character vector, specifies which
#'   diagnostics to show: \code{vif}, \code{residuals}, \code{qq},
#'   \code{scale}, \code{cooks}, \code{leverage}. If NULL (default),
#'   defers to \code{joutput()} session setting.
#' @param full Logical. If TRUE, turns on the coefficient confidence interval
#'   and diagnostics. Does not override explicit FALSE values.
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
#'     \item{coefficients}{Formatted coefficient table (data frame); includes
#'       95% CI Lower / Upper columns when \code{ci} is on.}
#'     \item{coefficients_raw}{Flat data frame of raw, full-precision
#'       coefficient statistics (one row per coefficient): \code{term} (machine
#'       key), \code{b}, \code{SE}, \code{t}, \code{df}, \code{p}, \code{beta},
#'       and \code{ci_lower} / \code{ci_upper} bounds (present regardless of the
#'       \code{ci} display toggle). Carries \code{beta_standardization} and
#'       \code{outcome} attributes.}
#'     \item{fit_raw}{List of raw, full-precision fit statistics (R-squared,
#'       adjusted R-squared, residual SE, F with its dfs and p-value, residual
#'       df, and N).}
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
#' @param digits Integer or NULL. Number of decimal places for continuous
#'   statistics in the output tables (range 0-7; \code{digits = 0} prints
#'   whole numbers with no trailing decimal point). Does not affect p-values,
#'   percentages, or integer quantities (counts, N, degrees of freedom),
#'   which keep their own fixed conventions. NULL (default) defers to
#'   \code{joutput()}'s \code{digits} setting (default 3).
#' @param case.processing.detail Per-call override of the Case
#'   Processing Summary detail tier: one of \code{"none"},
#'   \code{"totals"}, or \code{"per_code"}. \code{NULL} (default)
#'   uses the active \code{joutput()} level default.
#' @param ref.categories Logical or NULL. Per-call override for showing the
#'   reference-categories block (the baseline level dropped from each set of
#'   dummy variables). \code{NULL} (default) defers to \code{joutput()}'s
#'   \code{ref.categories} setting. Applies to \code{jlm()} and
#'   \code{jlogistic()} only, since they are the functions that produce
#'   dummy-coded coefficient tables.
jlm <- function(formula, data, subset = NULL, variable.id = NULL,
                numeric = NULL, categorical = NULL, count = NULL,
                ci = NULL,
                diagnostics = NULL, ref.categories = NULL, full = FALSE,
                case.processing.detail = NULL, digits = NULL, ...,
                value.id = NULL) {

  .jst_check_args(
    list(...),
    aliases = c(which = "diagnostics", plots = "diagnostics",
                show = "diagnostics"),
    fn_name = "jlm"
  )

  # value.id is validated before any output, so an unsupported value fails
  # fast (no title or data note printed first). It governs the dummy
  # category-row labels and the reference folded into each grouped header.
  # The legend modes have no separate-block meaning beneath a regression
  # table -- the rows already pair each value label inline -- so passing one
  # explicitly is an error; a joutput() "legend"/"legend.bottom" default is
  # tolerated and folded to "both" (so a bare call does not break). Only that
  # global-default path can reach the fold, since an explicit legend value is
  # rejected here. The variable.id legend block is unrelated (handled later).
  if (!is.null(value.id) && value.id %in% c("legend", "legend.bottom")) {
    stop("value.id '", value.id, "' is not supported by jlm().", call. = FALSE)
  }
  value_mode      <- .jst_resolve_value_id(value.id,
                                           allowed = c("both", "values", "labels"))
  value_mode_coef <- if (value_mode %in% c("legend", "legend.bottom")) {
    "both"
  } else {
    value_mode
  }

  # variable.id is likewise validated before any output (same fail-fast
  # reason). It governs variable-name display in the coefficient table and
  # whether/where the variable-label legend prints: "legend" between the
  # Coefficients table and the fit block, "legend.bottom" at the very end,
  # "labels" relabels the coefficient-row terms (display only).
  vlmode          <- .jst_resolve_variable_id(variable.id)

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

  # variable.id and value.id are validated and resolved above, before any
  # output. Remaining display settings:
  show_ref_categories  <- .jst_resolve_toggle("ref.categories",  ref.categories)
  digits_n             <- .jst_resolve_digits(digits)
  # Pre-conversion label source for "labels"/legend display: captured before
  # the variable-type conversion below coerces haven-labelled IVs to numeric
  # or factor (which would drop their variable labels). Frozen by
  # copy-on-modify so later in-place conversions do not affect it.
  lab_src <- data
  # Resolve display toggles. `ci` wires the 95% coefficient CI to the joutput()
  # regression.ci default (off at minimal and standard, on at full), matching
  # jlogistic; `full` forces it on unless the caller set it FALSE. (Session 69)
  if (full) {
    if (is.null(ci))          ci          <- TRUE
    if (is.null(diagnostics)) diagnostics <- TRUE
  }
  ci <- .jst_resolve_toggle("regression.ci", ci)
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

  # Conflict guard: a per-call numeric = override cannot un-register a
  # jdummy-registered variable, because registrations are expanded above before
  # the override is applied. Warn rather than silently ignore the request.
  if (!is.null(numeric)) {
    .dummy_regs <- .jst_get_dummy(.jst_data_name)
    if (!is.null(.dummy_regs) && length(.dummy_regs) > 0) {
      .reg_names <- vapply(.dummy_regs, function(r) r$var_name, character(1))
      .clash     <- intersect(numeric, .reg_names)
      if (length(.clash) > 0) {
        warning("numeric = was ignored for ", paste(.clash, collapse = ", "),
                " (registered as a dummy via jdummy). Clear the registration ",
                "with jdummy(NULL) to treat it as numeric.",
                call. = FALSE)
      }
    }
  }

  # -- Variable type conversion -------------------------------------------------
  # Priority order:
  #   1. jdummy() registrations (already expanded above)
  #   2. numeric/categorical overrides from this call
  #   3. Auto-detection: haven-labelled with value labels -> categorical,
  #      everything else -> numeric
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
  #
  # Provenance gate (message-provenance sweep): a user-asserted numeric/count
  # role on the DV silences or de-hedges the count and categorical-like notes
  # below. dv_override captures a per-call count =/ numeric = naming the DV
  # (count wins if both name it); the resolver also reads a jcount()/jnumeric()
  # registration. The DV is modelled as numeric either way -- this affects
  # only which note prints, not the model.
  dv_override <- if (dv_name %in% count) {
    "count"
  } else if (dv_name %in% numeric) {
    "numeric"
  } else {
    NULL
  }
  dv_res <- .jst_jstats_class(data[[dv_name]], dv_name, .jst_data_name,
                              override = dv_override)
  dv_asserted_count   <- !identical(dv_res$source, "structural") &&
                         identical(dv_res$class, "Numeric") &&
                         identical(dv_res$subclass, "Count")
  dv_asserted_numeric <- !identical(dv_res$source, "structural") &&
                         identical(dv_res$class, "Numeric") &&
                         !identical(dv_res$subclass, "Count")
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
  } else if (.jst_is_count(data[[dv_name]], dv_name, .jst_data_name,
                           override = dv_override)) {
    # Count DV. Three provenance cases (resolved above):
    #   asserted count   -> de-hedged, definitive count caveat (and no "0-6
    #                       range" claim, since an asserted count may sit
    #                       outside the structural band);
    #   asserted numeric -> suppressed (user declared continuous intent);
    #   structural       -> today's hedged "looks like a count" warning.
    if (dv_asserted_count) {
      warning(
        "'", dv_name, "' is currently listed as a count variable. Linear ",
        "regression assumes a continuous DV.",
        call. = FALSE
      )
    } else if (!dv_asserted_numeric) {
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
    }
    # asserted numeric: hedge suppressed, no warning.
  } else if (.jst_is_discrete_integer(data[[dv_name]], dv_name,
                                      .jst_data_name) &&
             !dv_asserted_numeric) {
    # Non-dichotomous but categorical-like (e.g. a Likert item used as DV).
    # Suppressed when the DV's numeric role is user-asserted (jnumeric /
    # per-call numeric=); otherwise three plausible alternatives: reverse
    # formula, jlogistic (multinomial would apply but that's beyond current
    # package scope), or jaov/jt.
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
    # A numeric = naming the DV asserts a continuous DV for this call,
    # silencing the count / categorical-like DV note (consumed into
    # dv_override above). Modelling is unchanged (the DV is always numeric),
    # so drop it from the IV-override set silently -- the absence of the
    # note is the confirmation.
    numeric <- setdiff(numeric, dv_name)
    if (length(numeric) == 0) numeric <- NULL
  }

  if (!is.null(count)) {
    # A count = naming the DV asserts a count DV for this call (consumed into
    # dv_override above -> de-hedged count caveat). Drop it from the IV set;
    # any remaining count = names are IV predictors, treated as numeric and
    # validated below.
    count <- setdiff(count, dv_name)
    if (length(count) == 0) count <- NULL
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

  if (!is.null(count)) {
    # Remaining count = names (DV already consumed) are IV predictors; a count
    # IV is just a numeric predictor, so validate exactly like numeric =.
    bad <- setdiff(count, iv_names)
    if (length(bad) > 0) {
      bad_registered <- intersect(bad, expanded_originals)
      bad_unknown    <- setdiff(bad, expanded_originals)
      if (length(bad_registered) > 0) {
        warning(
          "count argument ",
          paste0("'", bad_registered, "'", collapse = ", "),
          " is ignored: already registered as a dummy variable via ",
          "jdummy(), which takes precedence. To model as numeric, first ",
          "clear the registration with: jdummy(NULL)",
          call. = FALSE
        )
      }
      if (length(bad_unknown) > 0) {
        stop(
          "count argument: ",
          paste0("'", bad_unknown, "'", collapse = ", "),
          " not found among independent variables in ", .jst_data_name,
          ". Check for typos.",
          call. = FALSE
        )
      }
      count <- intersect(count, iv_names)
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

  # A variable cannot be both a count and a categorical (the assertions
  # contradict). count and numeric both mean "numeric-like", so they are not
  # treated as a conflict.
  if (!is.null(count) && !is.null(categorical)) {
    conflict <- intersect(count, categorical)
    if (length(conflict) > 0) {
      stop(
        paste0("'", conflict, "'", collapse = ", "),
        " listed in both count and categorical arguments.",
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

    # --- Override: count = "Var" forces numeric (a count predictor enters
    # the model as a numeric predictor; the Count subclass matters only for
    # the DV count caveat, not for IV handling). ---
    if (v %in% count) {
      if (haven::is.labelled(data[[v]])) {
        data[[v]] <- .jst_as_numeric(data[[v]])
      }
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
      } else if (.jst_is_discrete_integer(data[[v]], v, .jst_data_name) &&
                 !.jst_role_asserted_numeric(data[[v]], v, .jst_data_name)) {
        # Non-dichotomous but categorical-like structure: emit the
        # informational warning so the user can confirm continuous
        # treatment or switch to categorical. Suppressed when the user has
        # asserted a numeric/count role (jnumeric/jcount) -- the hedge is a
        # guess they have already answered. (A per-call numeric=/count= IV
        # short-circuits earlier, so only registration reaches this gate.)
        warning(
          v, " seems categorical. To treat it that way, register it with ",
          "jdummy() and rerun:\n\n",
          "  jdummy(", .jst_data_name, ", ", v, ")\n",
          "  jlm(", deparse(formula), ")\n\n",
          "Or: jlm(", deparse(formula), ", categorical = \"", v, "\")",
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

  # Reference categories are printed later, under the Outcome: line (just above
  # the Coefficients table they describe). Build the vector here unconditionally
  # because downstream code (the return object) uses it regardless of display.
  all_ref_cats <- c(ref_cats, auto_ref_cats)

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

  # Machine term keys (design-matrix coefficient names: "(Intercept)",
  # "ProgramApprenticeship", "Age", ...), captured BEFORE the display rownames
  # are cleaned below. They are the stable alignment key the japa-ready return
  # carries beside each row; the final key form is a keystone of the broader
  # return-shape audit and may be refined when that item is taken. (Session 69)
  term_keys <- rownames(coefs)

  # 95% confidence interval for each unstandardized b, computed inline as
  # b +/- qt(.975, residual df) * SE -- the closed form jt uses for its
  # mean-difference CI (no stats::confint(), no new dependency; jlogistic needs
  # confint only because its interval is on the log-odds scale and is then
  # exponentiated). Held at full precision: the `ci` toggle governs DISPLAY only
  # (the rounded columns appended to the printed table below), while these raw
  # bounds always travel on the returned object so a later collector (japa())
  # can render the CI even when the console did not show it. (Session 69)
  res_df       <- stats::df.residual(model)
  ci_crit      <- stats::qt(0.975, res_df)
  ci_lower_raw <- coefs$b - ci_crit * coefs$StdErr
  ci_upper_raw <- coefs$b + ci_crit * coefs$StdErr

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

  # Whether to blank the standardized beta on dummy / factor coefficient rows.
  # A naive fully-standardized beta on a 0/1 indicator is scaled by the
  # category's prevalence rather than by a meaningful unit, so it is not
  # comparable to the continuous betas and is suppressed. This is the regular
  # (SPSS-style) standardization regime, which is the only one currently
  # offered. SEAM: when the planned none / regular / Gelman standardization
  # switch lands, it sets this flag -- e.g. under Gelman, binary indicators are
  # left on their 0/1 scale, where the standardized beta equals the raw b and
  # would be shown. Display-only; the returned object is unaffected either way.
  blank_dummy_beta <- TRUE

  factor_terms <- names(mf)[vapply(mf, is.factor, logical(1))]
  if (blank_dummy_beta && length(factor_terms) > 0) {
    for (term in factor_terms) {
      dummy_rows        <- grep(paste0("^", term), rownames(coefs), value = TRUE)
      std_b[dummy_rows] <- NA_real_
    }
  }

  # Blank β for registered dummy variables
  if (blank_dummy_beta && length(dummy_coef_names) > 0) {
    for (dname in dummy_coef_names) {
      if (dname %in% names(std_b)) std_b[dname] <- NA_real_
    }
  }

  p_num <- suppressWarnings(as.numeric(coefs$P))
  p_fmt <- .jst_fmt_p(p_num)

  # Continuous-statistic formatter honoring the joutput `digits` setting
  # (coefficients, SEs, t, standardized beta). P-values keep their own
  # fixed convention (above). A value that rounds to zero from below prints
  # as a plain "0.000", not a signed "-0.000" (which reads as an error).
  fmt3 <- function(x) {
    s <- sprintf(paste0("%.", digits_n, "f"), as.numeric(x))
    ifelse(startsWith(s, "-") & !grepl("[1-9]", s), sub("^-", "", s), s)
  }

  # Clean up factor coefficient names for readability
  rownames(coefs) <- .jst_clean_coef_names(rownames(coefs), data,
                                            all.vars(formula)[-1])

  out_coefs <- data.frame(
    b       = fmt3(coefs$b),
    StdErr  = fmt3(coefs$StdErr),
    t       = fmt3(coefs$t),
    Beta    = ifelse(is.na(std_b), "",
                     sprintf(paste0("%.", digits_n, "f"), as.numeric(std_b))),
    P       = p_fmt,
    stringsAsFactors = FALSE,
    row.names = rownames(coefs)
  )

  # When `ci` is on, append the 95% CI bounds at the right end of the table
  # (after p -- the jlogistic append pattern). fmt3 applies the digits option and
  # the negative-zero / leading-zero normalisation, same as the b column. On
  # grouped multi-category dummy rows these columns ride through
  # .jst_group_dummy_coefs() per category untouched (the CI tracks the raw b);
  # blank_dummy_beta governs only the Beta column, decoupling the CI from the
  # future none/regular/Gelman standardization switch. (Session 69)
  if (ci) {
    out_coefs$CI_Lower <- fmt3(ci_lower_raw)
    out_coefs$CI_Upper <- fmt3(ci_upper_raw)
  }

  r_squared     <- round(model_summary$r.squared, digits_n)
  adj_r_squared <- round(model_summary$adj.r.squared, digits_n)
  residual_se   <- round(model_summary$sigma, digits_n)

  f_stat  <- model_summary$fstatistic
  df1     <- unname(f_stat[2])
  df2     <- unname(f_stat[3])
  # Compute the F p-value from the full-precision F (NOT the display-rounded
  # value) so it never depends on the digits setting.
  f_p     <- stats::pf(unname(f_stat[1]), df1, df2, lower.tail = FALSE)
  f_p_fmt <- .jst_fmt_p(f_p)
  f_value <- round(unname(f_stat[1]), digits_n)

  n_obs         <- stats::nobs(model)
  y             <- stats::model.response(mf)
  ss_total      <- round(sum((y - mean(y))^2), digits_n)
  ss_regression <- round(sum((stats::fitted(model) - mean(y))^2), digits_n)
  ss_residual   <- round(sum(stats::residuals(model)^2), digits_n)

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
  out_coefs_disp <- out_coefs
  if (identical(vlmode, "labels")) {
    rownames(out_coefs_disp) <- .jst_relabel_coef_names(
      rownames(out_coefs), lab_src, all.vars(formula)[-1])
  }
  # The outcome is named beneath the Coefficients table (not above), via
  # .jst_print_outcome_line(); under the variable.id legend modes it is carried
  # by the legend's Outcome section instead, so no standalone line prints.
  # (Outcome placement moved below the table this session; previously above,
  # per Session 62/63.)
  # The reference category is no longer printed on its own line; it is folded
  # into each multi-category variable's header below (e.g.
  # "Employment (ref = 1: Employed full-time)"), governed by value.id and the
  # ref.categories toggle. all_ref_cats still feeds the returned object.
  #
  # Multi-category dummy predictors are grouped: a header row carrying the
  # variable name (its label under variable.id = "labels") with the reference
  # folded in, and the categories indented two spaces beneath with value.id
  # labels. Single-contrast (dichotomous) predictors and continuous predictors
  # are left as flat rows. The display label rides in a leading column printed
  # with "ln" (left, no-trim) alignment so the indent survives; the returned
  # object is untouched.
  multi_cat_regs <- .jst_collect_multicat_regs(dummy_regs, auto_cat_regs,
                                               dummy_coef_names)
  coef_disp <- .jst_group_dummy_coefs(out_coefs_disp, multi_cat_regs,
                                      value_mode_coef, vlmode, lab_src,
                                      show_ref_categories)
  coef_col_names <- c("b", "SE", "t", "\u03b2", "p")
  coef_align     <- c("d", "d", "d", "d", "d")
  if (ci) {
    coef_col_names <- c(coef_col_names, "95% CI Lower", "95% CI Upper")
    coef_align     <- c(coef_align, "d", "d")
  }
  .jst_print_table(coef_disp,
                   caption   = "Coefficients",
                   col.names = c("", coef_col_names),
                   align     = c("ln", coef_align),
                   row.names = FALSE)

  # Outcome named beneath the table, following variable.id; folds into the
  # legend under the legend modes (see .jst_print_outcome_line).
  .jst_print_outcome_line(lab_src, original_formula_vars[1], vlmode)

  # "legend" (mid): between the Coefficients table and the R-squared/fit block.
  # In legend mode the roster's trailing blank line doubles as the separator
  # before the fit block (matching jlogistic); otherwise one blank is emitted
  # here. The R-squared line carries no leading newline, so exactly one blank
  # precedes the fit block in every variable.id mode.
  if (identical(vlmode, "legend")) {
    cat("\n")
    .print_model_var_labels(lab_src, original_formula_vars[1], original_formula_vars[-1])
  } else {
    cat("\n")
  }

  cat("R-squared: ", sprintf(paste0("%.", digits_n, "f"), r_squared),
      "    Adjusted R-squared: ", sprintf(paste0("%.", digits_n, "f"), adj_r_squared), "\n", sep = "")
  cat("Residual Standard Error: ", sprintf(paste0("%.", digits_n, "f"), residual_se), "\n", sep = "")
  cat("\nF-statistic: ", sprintf(paste0("%.", digits_n, "f"), f_value),
      " on ", df1, " and ", df2,
      " DF, p-value: ", f_p_fmt, "\n", sep = "")
  cat("Sum of Squares:\n")
  cat("  Regression: ", sprintf(paste0("%.", digits_n, "f"), ss_regression), "\n", sep = "")
  cat("  Residual:   ", sprintf(paste0("%.", digits_n, "f"), ss_residual),   "\n", sep = "")
  cat("  Total:      ", sprintf(paste0("%.", digits_n, "f"), ss_total),      "\n", sep = "")

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

  # "legend.bottom": one consolidated legend at the very end of the output.
  if (identical(vlmode, "legend.bottom")) {
    cat("\n")
    .print_model_var_labels(lab_src, original_formula_vars[1], original_formula_vars[-1])
  }

  # japa-ready coefficient frame: one flat row per coefficient carrying RAW,
  # full-precision numbers (the printed `coefficients` frame above rounds for the
  # eye; this keeps the values intact so a later collector rounds to APA spec
  # itself). `term` is the machine alignment key; `df` is the shared residual df;
  # `beta` is the raw standardized coefficient (NA where blanked on dummy rows);
  # the CI bounds are present regardless of the `ci` display toggle. First
  # down-payment on the cross-function return-shape audit -- the accessor
  # contract and final key form remain that item's keystones. (Session 69)
  coefficients_raw <- data.frame(
    term     = term_keys,
    b        = unname(coefs$b),
    SE       = unname(coefs$StdErr),
    t        = unname(coefs$t),
    df       = res_df,
    p        = suppressWarnings(as.numeric(coefs$P)),
    beta     = unname(std_b[term_keys]),
    ci_lower = unname(ci_lower_raw),
    ci_upper = unname(ci_upper_raw),
    stringsAsFactors = FALSE,
    row.names = NULL
  )
  attr(coefficients_raw, "beta_standardization") <- "regular"
  attr(coefficients_raw, "outcome") <- c(
    name  = original_formula_vars[1],
    label = .jst_label_or_name(lab_src, original_formula_vars[1]))
  # Per-row display label keyed by term (sub-decision a: keyed attribute, not a
  # column -- keeps the numeric frame flat). Uses the package's own coef
  # relabeling; the accessor reads this alongside the dummy-group structure
  # already on the return (dummy_coef_names / ref_cats). (return-shape audit)
  attr(coefficients_raw, "labels") <- stats::setNames(
    .jst_relabel_coef_names(term_keys, lab_src, all.vars(formula)[-1], sep = "_"),
    term_keys)

  # Raw fit statistics mirroring the rounded fields below at full precision for
  # japa(); the rounded fields are retained for back-compatibility. (Session 69)
  fit_raw <- list(
    r_squared     = unname(model_summary$r.squared),
    adj_r_squared = unname(model_summary$adj.r.squared),
    sigma         = unname(model_summary$sigma),
    f_value       = unname(f_stat[1]),
    f_df1         = df1,
    f_df2         = df2,
    f_p           = unname(f_p),
    df_residual   = res_df,
    n             = n_obs
  )

  ret <- list(
    model           = model,
    model_type      = "linear",
    model_frame     = mf,
    formula_used    = formula,
    coefficients    = out_coefs,
    coefficients_raw = coefficients_raw,
    fit_raw         = fit_raw,
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
#' @param variable.id Character or NULL. Variable label display mode: one of
#'   \code{"both"}, \code{"names"}, \code{"labels"}, \code{"legend"}, or
#'   \code{"legend.bottom"}. \code{"names"} shows variable names only;
#'   \code{"both"} shows \code{"name: label"};
#'   \code{"labels"} replaces each coefficient's variable name with its label
#'   in the Coefficients table (factor level decoration is preserved) -- best
#'   for short labels; \code{"legend"} prints a label legend just below the
#'   Coefficients table (at the coefficients/fit seam);
#'   \code{"legend.bottom"} prints it at the very end. NULL (default) defers
#'   to \code{joutput()}'s \code{variable.id} setting. Not a logical.
#' @param value.id Character or NULL. Value-label display mode for the dummy
#'   category rows in the Coefficients table: one of \code{"both"}
#'   (\code{"code: label"}, degrading to a bare code where a code has no
#'   label), \code{"values"} (the bare code), or \code{"labels"} (the value
#'   label, degrading to the bare code where none exists). The reference
#'   category folded into each grouped variable's header follows the same
#'   mode. \code{"legend"} and \code{"legend.bottom"} are not supported here:
#'   a coefficient table already pairs each value label with its row, so a
#'   separate legend block would only duplicate it. Passing either explicitly
#'   is an error; a \code{joutput()} default of \code{"legend"} or
#'   \code{"legend.bottom"} is tolerated and rendered as \code{"both"}, so it
#'   does not break a bare call. Variables with no value labels render
#'   identically under all supported modes. NULL (default) defers to
#'   \code{joutput()}'s \code{value.id} setting. Applies only to multi-category
#'   dummy predictors; continuous and single-contrast (dichotomous) predictors
#'   are unaffected. Not a logical.
#' @param numeric Optional character vector of variable names to treat
#'   as continuous even if they have value labels.
#' @param categorical Optional character vector of variable names to treat
#'   as categorical even if they lack value labels.
#' @param count Optional character vector of independent-variable names to
#'   treat as counts for this call (the per-call counterpart of
#'   \code{jcount()}). A count predictor is numeric-like, so it enters the
#'   model exactly as \code{numeric} would; the argument is provided for
#'   symmetry with the other analysis functions. The binary dependent
#'   variable is fixed, so naming it here has no effect. A variable cannot be
#'   listed in both \code{count} and \code{categorical}.
#' @param ci Logical or NULL. If TRUE, adds 95% confidence intervals for
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
#'     \item{coefficients_raw}{Flat data frame of raw, full-precision
#'       coefficient statistics (one row per coefficient): \code{term} (machine
#'       key, shared with jlm), \code{b}, \code{SE}, \code{Wald}, \code{df},
#'       \code{p}, \code{exp_b}, and \code{exp_ci_lower} / \code{exp_ci_upper}
#'       odds-ratio CI bounds (present regardless of the \code{ci} display
#'       toggle). Carries an \code{outcome} attribute.}
#'     \item{fit_raw}{List of raw, full-precision model-level fit statistics:
#'       \code{ll_model}, \code{ll_null}, \code{deviance}, \code{null_deviance},
#'       the omnibus likelihood-ratio test (\code{chi_sq}, \code{omnibus_df},
#'       \code{omnibus_p}), Cox & Snell and Nagelkerke pseudo R-squared
#'       (\code{cox_snell_r2}, \code{nagelkerke_r2}), \code{aic}, and \code{n}.}
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
#' @param digits Integer or NULL. Number of decimal places for continuous
#'   statistics in the output tables (range 0-7; \code{digits = 0} prints
#'   whole numbers with no trailing decimal point). Does not affect p-values,
#'   percentages, or integer quantities (counts, N, degrees of freedom),
#'   which keep their own fixed conventions. NULL (default) defers to
#'   \code{joutput()}'s \code{digits} setting (default 3).
#' @param case.processing.detail Per-call override of the Case
#'   Processing Summary detail tier: one of \code{"none"},
#'   \code{"totals"}, or \code{"per_code"}. \code{NULL} (default)
#'   uses the active \code{joutput()} level default.
#' @param ref.categories Logical or NULL. Per-call override for showing the
#'   reference-categories block (the baseline level dropped from each set of
#'   dummy variables). \code{NULL} (default) defers to \code{joutput()}'s
#'   \code{ref.categories} setting. Applies to \code{jlm()} and
#'   \code{jlogistic()} only, since they are the functions that produce
#'   dummy-coded coefficient tables.
jlogistic <- function(formula, data, subset = NULL, variable.id = NULL,
                      numeric = NULL, categorical = NULL, count = NULL,
                      ci = NULL, classification = FALSE,
                      diagnostics = NULL, ref.categories = NULL, full = FALSE,
                      case.processing.detail = NULL, digits = NULL, ...,
                      value.id = NULL) {

  .jst_check_args(
    list(...),
    aliases = c(which = "diagnostics", plots = "diagnostics",
                show = "diagnostics"),
    fn_name = "jlogistic"
  )

  # value.id is validated before any output, so an unsupported value fails
  # fast (no title or data note printed first). It governs the dummy
  # category-row labels and the reference folded into each grouped header.
  # The legend modes have no separate-block meaning beneath a regression
  # table -- the rows already pair each value label inline -- so passing one
  # explicitly is an error; a joutput() "legend"/"legend.bottom" default is
  # tolerated and folded to "both" (so a bare call does not break). Only that
  # global-default path can reach the fold, since an explicit legend value is
  # rejected here. The variable.id legend block is unrelated (handled later).
  if (!is.null(value.id) && value.id %in% c("legend", "legend.bottom")) {
    stop("value.id '", value.id, "' is not supported by jlogistic().",
         call. = FALSE)
  }
  value_mode      <- .jst_resolve_value_id(value.id,
                                           allowed = c("both", "values", "labels"))
  value_mode_coef <- if (value_mode %in% c("legend", "legend.bottom")) {
    "both"
  } else {
    value_mode
  }

  # variable.id is likewise validated before any output (same fail-fast
  # reason). It governs variable-name display in the coefficient table and
  # whether/where the variable-label legend prints: "legend" just below the
  # Coefficients table (the coefficients/fit seam), "legend.bottom" at the
  # very end, "labels" relabels the coefficient-row terms (display only).
  vlmode          <- .jst_resolve_variable_id(variable.id)

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
  ci           <- .jst_resolve_toggle("regression.ci", ci)
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
  # Type gate (Session 46): the response is binary and may be a recognized
  # text/factor pair (e.g. "Yes"/"No") or logical, so it passes as categorical
  # here -- the DV-resolution block below classifies it via .jst_is_dichotomy(),
  # coerces a recognized response to 0/1, and records the modeled direction for
  # the Dependent Variable Encoding block. Predictors may be numeric or
  # categorical; date/time and complex/list/raw refused throughout. See
  # .jst_check_analysis_var.
  for (.gv in model_vars) .jst_check_analysis_var(data[[.gv]], .gv, FALSE, "a logistic regression")

  # Pre-conversion label source for "labels"/legend display (see jlm):
  # captured before dummy expansion and the variable-type conversion below,
  # which would drop variable labels from coerced columns. Frozen by
  # copy-on-modify.
  lab_src <- data

  # -- Expand registered dummy variables ------------------------------------
  expanded         <- .jst_expand_dummies(data, formula, .jst_data_name)
  data             <- expanded$data
  formula          <- expanded$formula
  ref_cats         <- expanded$ref_cats
  dummy_coef_names <- expanded$dummy_coef_names
  model_vars       <- all.vars(formula)

  # Conflict guard: a per-call numeric = override cannot un-register a
  # jdummy-registered variable, because registrations are expanded above before
  # the override is applied. Warn rather than silently ignore the request.
  if (!is.null(numeric)) {
    .dummy_regs <- .jst_get_dummy(.jst_data_name)
    if (!is.null(.dummy_regs) && length(.dummy_regs) > 0) {
      .reg_names <- vapply(.dummy_regs, function(r) r$var_name, character(1))
      .clash     <- intersect(numeric, .reg_names)
      if (length(.clash) > 0) {
        warning("numeric = was ignored for ", paste(.clash, collapse = ", "),
                " (registered as a dummy via jdummy). Clear the registration ",
                "with jdummy(NULL) to treat it as numeric.",
                call. = FALSE)
      }
    }
  }
  # count = is numeric-like, so it gets the same dummy-clash guard as numeric =.
  if (!is.null(count)) {
    .dummy_regs <- .jst_get_dummy(.jst_data_name)
    if (!is.null(.dummy_regs) && length(.dummy_regs) > 0) {
      .reg_names <- vapply(.dummy_regs, function(r) r$var_name, character(1))
      .clash     <- intersect(count, .reg_names)
      if (length(.clash) > 0) {
        warning("count = was ignored for ", paste(.clash, collapse = ", "),
                " (registered as a dummy via jdummy). Clear the registration ",
                "with jdummy(NULL) to treat it as numeric.",
                call. = FALSE)
      }
    }
  }

  # -- Variable type conversion (unified classifier) ------------------------
  # Priority order:
  #   1. jdummy() registrations (already expanded above)
  #   2. numeric/count/categorical overrides from this call
  #   3. Auto-detection via .jst_is_categorical()
  # DV is always numeric; handled after this loop. (numeric=/count=/categorical=
  # naming the DV is a no-op here -- the DV is excluded from iv_names below and
  # the binary response is fixed regardless of any role assertion.)
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

    # --- Override: count = "Var" forces numeric (a count predictor enters the
    # model as a numeric predictor; the Count subclass carries no special IV
    # handling, only the DV count caveat in jlm, which does not apply here). ---
    if (!is.null(count) && v %in% count) {
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
                         paste0(v, " = ", reg$ref_label))
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
                         paste0(v, " = ", reg$ref_label))
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
      } else if (.jst_is_discrete_integer(data[[v]], v, .jst_data_name) &&
                 !.jst_role_asserted_numeric(data[[v]], v, .jst_data_name)) {
        # Non-dichotomous but categorical-like structure: emit the
        # informational warning so the user can confirm continuous
        # treatment or switch to categorical. Suppressed when the user has
        # asserted a numeric/count role (jnumeric/jcount).
        warning(
          v, " seems categorical. To treat it that way, register it with ",
          "jdummy() and rerun:\n\n",
          "  jdummy(", .jst_data_name, ", ", v, ")\n",
          "  jlogistic(", deparse(formula), ")\n\n",
          "Or: jlogistic(", deparse(formula), ", categorical = \"", v, "\")",
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

  # -- Resolve and validate the binary response -----------------------------
  # .jst_is_dichotomy() is the single source of truth for numeric dichotomy
  # detection and coding; .jst_match_binary_tokens() resolves recognized
  # text/logical responses. Every valid form is coerced to 0/1 here so all
  # downstream steps (model.frame, glm, CPS, the coefficient table) see a clean
  # numeric binary. The event (modeled as 1) and reference (0) categories are
  # captured in dv_event_disp / dv_ref_disp for the Dependent Variable Encoding
  # block printed at the end. .jst_var_kind() routes numeric-coded factors and
  # character vectors (e.g. "0"/"1") through the numeric path and genuine text
  # (e.g. "Yes"/"No") through the recognized-vocabulary path.
  orig_dv       <- pipeline$data[[dv_name]]
  dv_kind       <- .jst_var_kind(orig_dv)
  dv_event_disp <- NULL
  dv_ref_disp   <- NULL

  if (identical(dv_kind$kind, "logical")) {
    # Logical: TRUE is the event. .jst_is_dichotomy() guards single-value input.
    if (!.jst_is_dichotomy(orig_dv)$is_dichotomy) {
      stop(paste0(
        "'", dv_name, "' has only one value. Logistic regression requires a ",
        "binary variable with two categories."
      ), call. = FALSE)
    }
    data[[dv_name]] <- as.numeric(orig_dv)   # FALSE -> 0, TRUE -> 1
    dv_event_disp   <- "TRUE"
    dv_ref_disp     <- "FALSE"

  } else if (dv_kind$kind %in% c("text_factor", "text_character")) {
    # Genuine text/factor: accept only the recognized affirmative/negative
    # vocabulary (C-strict). Matching is case-insensitive and whitespace-
    # trimmed, so "Yes"/"yes" collapse to one category.
    chr     <- as.character(orig_dv)
    nonmiss <- chr[!is.na(chr)]
    norm    <- tolower(trimws(nonmiss))
    u_norm  <- unique(norm)

    if (length(u_norm) != 2L) {
      # After case/whitespace folding, not a clean two-category text variable:
      # one category (no variation) or three or more.
      n_show <- unique(nonmiss)
      n_show <- n_show[seq_len(min(5L, length(n_show)))]
      stop(paste0(
        "'", dv_name, "' has ", length(u_norm),
        if (length(u_norm) == 1L) " category" else " categories",
        " (", paste(n_show, collapse = ", "),
        if (length(unique(nonmiss)) > 5L) ", ..." else "", ").\n",
        "Logistic regression requires exactly two categories. Recode to a 0/1 ",
        "variable before running jlogistic()."
      ), call. = FALSE)
    }

    # Representative original-cased label for each normalized category.
    disp <- vapply(u_norm, function(z) nonmiss[norm == z][1], character(1))
    disp <- unname(disp)
    mb   <- .jst_match_binary_tokens(disp)

    if (!mb$recognized) {
      stop(paste0(
        "'", dv_name, "' has the text categories: ",
        paste(disp, collapse = ", "),
        ". jlogistic() recognizes yes/no, y/n, true/false, t/f, present/absent, ",
        "and success/failure (case-insensitive); for any other pair, recode to ",
        "a 0/1 variable so the modeled category is explicit:\n",
        "  ", .jst_data_name, "$", dv_name, "R <- jrecode(", .jst_data_name, ", ",
        dv_name, ", map = \"", disp[1], "=0; ", disp[2], "=1\")\n",
        "Then use ", dv_name, "R as your dependent variable (the category mapped ",
        "to 1 is the one jlogistic models)."
      ), call. = FALSE)
    }

    event_norm      <- tolower(trimws(mb$event))
    y               <- rep(NA_real_, length(chr))
    keep            <- !is.na(chr)
    y[keep]         <- ifelse(tolower(trimws(chr[keep])) == event_norm, 1, 0)
    data[[dv_name]] <- y
    dv_event_disp   <- mb$event
    dv_ref_disp     <- mb$reference

  } else {
    # Numeric family (numeric, haven_labelled numeric, numeric-coded factor /
    # character). Classify the numeric coding via the single-source helper.
    x_num     <- dv_kind$num
    dv_dich   <- .jst_is_dichotomy(x_num)
    dv_vals   <- x_num[!is.na(x_num)]
    dv_labels <- if (haven::is.labelled(orig_dv)) labelled::val_labels(orig_dv) else NULL

    if (dv_dich$is_dichotomy && identical(dv_dich$coding, "0/1")) {
      # Valid. Coerce to plain numeric 0/1 (strips any labelled wrapper).
      code_label <- function(code) {
        if (!is.null(dv_labels) && length(dv_labels) > 0) {
          nm <- names(dv_labels)[as.numeric(dv_labels) == code]
          nm <- nm[!is.na(nm) & nzchar(nm)]
          if (length(nm) >= 1) return(nm[1])
        }
        as.character(code)
      }
      data[[dv_name]] <- as.numeric(x_num)
      dv_event_disp   <- code_label(1)
      dv_ref_disp     <- code_label(0)

    } else if (dv_dich$is_dichotomy && identical(dv_dich$coding, "1/2")) {
      # Common 1/2 coding -- suggest recode to 0/1 (with labels if present).
      if (!is.null(dv_labels) && length(dv_labels) >= 2) {
        label_1 <- names(dv_labels[dv_labels == 1])
        label_2 <- names(dv_labels[dv_labels == 2])
        if (length(label_1) == 0) label_1 <- "1"
        if (length(label_2) == 0) label_2 <- "2"
        recode_labels <- paste0(", labels = \"0=", label_1, "; 1=", label_2, "\"")
      } else {
        recode_labels <- ""
      }
      stop(paste0(
        "'", dv_name, "' is coded 1/2. Logistic regression requires 0/1 coding.\n",
        "Recode before running jlogistic():\n",
        "  ", .jst_data_name, "$", dv_name, "R <- jrecode(", .jst_data_name, ", ", dv_name,
        ", map = \"1=0; 2=1\"", recode_labels, ")\n",
        "Then use ", dv_name, "R as your dependent variable.\n",
        "(jlogistic models the category coded 1; to model the other category ",
        "instead, reverse the map and labels.)"
      ), call. = FALSE)

    } else {
      # Not a valid 0/1 dichotomy: distinguish suspected coded missings from a
      # generic wrong-codes / wrong-count problem (behavior preserved).
      unique_vals <- sort(unique(dv_vals))
      n_unique    <- length(unique_vals)
      if (n_unique >= 2) {
        non_binary <- setdiff(unique_vals, c(0, 1))
        suspicious <- .jst_detect_suspicious_values(dv_vals, dv_name)
        coded_miss <- intersect(non_binary, suspicious)
      } else {
        coded_miss <- numeric(0)
      }

      if (length(coded_miss) > 0) {
        miss_str <- paste(coded_miss, collapse = ", ")
        stop(paste0(
          "'", dv_name, "' has ", n_unique, " unique values (",
          paste(unique_vals, collapse = ", "),
          "). The dependent variable must have exactly 2 categories coded 0/1.\n",
          "The value(s) ", miss_str, " may be coded missing value(s).\n",
          "Convert to NA before running jlogistic():\n",
          "  ", .jst_data_name, "$", dv_name, "R <- jrecode(", .jst_data_name, ", ", dv_name,
          ", map = \"", paste0(coded_miss, "=NA", collapse = "; "),
          "; else=copy\")"
        ), call. = FALSE)
      } else {
        stop(paste0(
          "'", dv_name, "' has values: ",
          paste(unique_vals, collapse = ", "),
          ". Logistic regression requires a binary variable coded 0/1.\n",
          "Use jrecode() to create a 0/1 coded version before running jlogistic()."
        ), call. = FALSE)
      }
    }
  }

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

  # Reference categories are resolved here but printed later, under the Outcome:
  # line (just above the Coefficients table they describe), to match jlm.
  show_ref_categories <- .jst_resolve_toggle("ref.categories", ref.categories)

  # variable.id and value.id are validated and resolved above, before any
  # output.
  digits_n <- .jst_resolve_digits(digits)

  model <- stats::glm(formula, data = data, family = stats::binomial,
                       na.action = stats::na.omit)
  model_summary <- summary(model)
  n_obs         <- stats::nobs(model)

  # The modeled (event) category is reported in the Dependent Variable Encoding
  # block at the end of the output, not as an up-front line. predicts_str feeds
  # the returned object's `predicts` field; dv_event_disp was resolved with the
  # DV above and now carries the recognized text/logical category (not a bare
  # "1") when the response was coerced.
  predicts_str <- dv_event_disp

  # -- Omnibus test (model vs null) ------------------------------------------
  # Use the fitted model's own null.deviance/deviance: glm computes both on the
  # SAME listwise-complete cases as the full model. Refitting a null on `data`
  # would keep rows the full model dropped (complete on the DV but missing on a
  # predictor), mixing log-likelihoods from different N and inflating the
  # statistic. For ungrouped binary data deviance == -2 * logLik, so ll_null and
  # ll_model below remain correct for the pseudo-R-squared computations too.
  ll_null     <- -model$null.deviance / 2
  ll_model    <- -model$deviance / 2
  chi_sq      <- model$null.deviance - model$deviance
  omnibus_df  <- model$df.null - model$df.residual
  omnibus_p   <- stats::pchisq(chi_sq, df = omnibus_df, lower.tail = FALSE)
  omnibus_fmt <- .jst_fmt_p(omnibus_p)

  omnibus_table <- data.frame(
    Chi_Square = round(chi_sq, digits_n),
    df         = omnibus_df,
    p          = omnibus_fmt,
    stringsAsFactors = FALSE,
    row.names = NULL
  )
  # (Omnibus table is printed below, after the Coefficients table -- the
  # fit block follows the coefficients in the coefficient-first layout.
  # Session 63.)

  # -- Model summary --------------------------------------------------------
  neg2ll       <- -2 * ll_model
  aic          <- stats::AIC(model)
  cox_snell_r2 <- 1 - exp((2 / n_obs) * (ll_null - ll_model))
  max_r2       <- 1 - exp((2 / n_obs) * ll_null)
  nagelkerke_r2 <- cox_snell_r2 / max_r2

  summary_table <- data.frame(
    neg2LL     = round(neg2ll, digits_n),
    CoxSnellR2 = round(cox_snell_r2, digits_n),
    NagelkerkeR2 = round(nagelkerke_r2, digits_n),
    AIC        = round(aic, digits_n),
    stringsAsFactors = FALSE,
    row.names = NULL
  )
  # (Model Summary table is printed below, after the Coefficients table.
  # The variable.id "legend" roster also prints there -- at the new
  # coefficients/fit seam -- mirroring jlm. Session 63.)

  # -- Coefficients table ----------------------------------------------------
  coefs    <- as.data.frame(model_summary$coefficients, stringsAsFactors = FALSE)
  colnames(coefs) <- c("b", "SE", "z", "P")

  # Wald chi-square = z^2
  wald <- coefs$z^2

  p_num <- suppressWarnings(as.numeric(coefs$P))
  p_fmt <- .jst_fmt_p(p_num)

  exp_b <- exp(coefs$b)

  # Continuous-statistic formatter honoring the joutput `digits` setting
  # (coefficients, SEs, Wald, Exp(B), CI bounds). The Wald p-value and df
  # keep their own fixed conventions. A value that rounds to zero from below
  # prints as a plain "0.000", not a signed "-0.000" (which reads as an error).
  fmt3 <- function(x) {
    s <- sprintf(paste0("%.", digits_n, "f"), as.numeric(x))
    ifelse(startsWith(s, "-") & !grepl("[1-9]", s), sub("^-", "", s), s)
  }

  # Machine term keys (raw design-matrix coefficient names), captured BEFORE
  # the display rownames are cleaned below -- the stable alignment key the
  # japa-ready return carries beside each row, matching jlm. (return-shape audit)
  term_keys <- rownames(coefs)

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

  # Profile-likelihood CI on the odds-ratio scale, computed once regardless of
  # the `ci` display toggle so the japa-ready return always carries it.
  # stats::confint() gives log-odds bounds; exp() puts them on the Exp(B) scale.
  # A profiling failure (e.g. separation) degrades to NA rather than erroring.
  ci_raw <- tryCatch(suppressMessages(stats::confint(model)),
                     error = function(e) NULL)
  if (is.null(ci_raw)) {
    exp_ci_lower_raw <- rep(NA_real_, nrow(coefs))
    exp_ci_upper_raw <- rep(NA_real_, nrow(coefs))
  } else {
    exp_ci_lower_raw <- exp(ci_raw[, 1])
    exp_ci_upper_raw <- exp(ci_raw[, 2])
  }

  if (ci) {
    out_coefs$CI_Lower <- fmt3(exp_ci_lower_raw)
    out_coefs$CI_Upper <- fmt3(exp_ci_upper_raw)
    col_names <- c(col_names, "95% CI Lower", "95% CI Upper")
  }

  cat("\n")
  out_coefs_disp <- out_coefs
  if (identical(vlmode, "labels")) {
    rownames(out_coefs_disp) <- .jst_relabel_coef_names(
      rownames(out_coefs), lab_src, all.vars(formula)[-1])
  }
  # The outcome is named beneath the Coefficients table (not above), via
  # .jst_print_outcome_line(); under the variable.id legend modes it is carried
  # by the legend's Outcome section instead, so no standalone line prints.
  # (Outcome placement moved below the table this session; previously above,
  # per Session 62/63.)
  # The reference category is no longer printed on its own line; it is folded
  # into each multi-category variable's header below (e.g.
  # "Employment (ref = 1: Employed full-time)"), governed by value.id and the
  # ref.categories toggle. all_ref_cats still feeds the returned object.
  #
  # Multi-category dummy predictors are grouped: a header row carrying the
  # variable name (its label under variable.id = "labels") with the reference
  # folded in, and the categories indented two spaces beneath with value.id
  # labels. Single-contrast (dichotomous) predictors and continuous predictors
  # are left as flat rows. The display label rides in a leading column printed
  # with "ln" (left, no-trim) alignment so the indent survives. jlogistic has
  # no standardized-beta column, so there is nothing to blank on the grouped
  # rows; the returned object is untouched.
  multi_cat_regs <- .jst_collect_multicat_regs(dummy_regs, auto_cat_regs,
                                               dummy_coef_names)
  coef_disp <- .jst_group_dummy_coefs(out_coefs_disp, multi_cat_regs,
                                      value_mode_coef, vlmode, lab_src,
                                      show_ref_categories)
  .jst_print_table(coef_disp,
                   caption   = "Coefficients",
                   col.names = c("", col_names),
                   align     = c("ln", rep("d", length(col_names))),
                   row.names = FALSE)

  # Outcome named beneath the table, following variable.id; folds into the
  # legend under the legend modes (see .jst_print_outcome_line).
  .jst_print_outcome_line(lab_src, original_formula_vars[1], vlmode)

  # -- Fit block (coefficient-first layout: prints after the Coefficients
  # table). The variable.id "legend" roster sits at this coefficients/fit
  # seam, mirroring jlm. (Session 63)
  if (identical(vlmode, "legend")) {
    cat("\n")
    .print_model_var_labels(lab_src, original_formula_vars[1], original_formula_vars[-1])
    # the roster's trailing blank line doubles as the separator before the
    # fit block, so no extra blank is emitted here.
  } else {
    cat("\n")
  }
  .jst_print_table(omnibus_table,
                   caption = "Omnibus Test of Model Coefficients",
                   col.names = c("Chi-Square", "df", "p"),
                   row.names = FALSE)
  cat("\n")
  .jst_print_table(summary_table,
                   caption = "Model Summary",
                   col.names = c("-2 Log Likelihood", "Cox & Snell R\u00b2",
                                 "Nagelkerke R\u00b2", "AIC"),
                   row.names = FALSE)

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

  # "legend.bottom": one consolidated legend at the very end of the output.
  if (identical(vlmode, "legend.bottom")) .print_model_var_labels(lab_src, original_formula_vars[1], original_formula_vars[-1])

  # -- Dependent Variable Encoding -------------------------------------------
  # Always shown, for every valid DV type (numeric 0/1, logical, recognized
  # text). Names which category the model treats as the event (internal 1) and
  # which is the reference (0), so the modeled direction is never silent the way
  # base glm()/lm() leave it (glm picks the event by alphabetical level order).
  # The SPSS analogue is the "Dependent Variable Encoding" table. dv_event_disp
  # / dv_ref_disp were resolved with the DV above.
  cat("Dependent Variable Encoding\n")
  cat("  Modeled (1):   ", dv_event_disp, "\n", sep = "")
  cat("  Reference (0): ", dv_ref_disp,   "\n", sep = "")

  # japa-ready coefficient frame: one flat row per coefficient at full
  # precision (the printed `coefficients` frame rounds for the eye; this keeps
  # the numbers intact for a later collector). `term` is the machine alignment
  # key shared with jlm; `df` is the Wald df (always 1 here); `exp_b` and its
  # CI bounds are on the odds-ratio scale and travel regardless of the `ci`
  # display toggle. Mirrors jlm's coefficients_raw. (return-shape audit)
  coefficients_raw <- data.frame(
    term         = term_keys,
    b            = unname(coefs$b),
    SE           = unname(coefs$SE),
    Wald         = unname(wald),
    df           = rep(1L, nrow(coefs)),
    p            = unname(p_num),
    exp_b        = unname(exp_b),
    exp_ci_lower = unname(exp_ci_lower_raw),
    exp_ci_upper = unname(exp_ci_upper_raw),
    stringsAsFactors = FALSE,
    row.names = NULL
  )
  attr(coefficients_raw, "outcome") <- c(
    name  = original_formula_vars[1],
    label = .jst_label_or_name(lab_src, original_formula_vars[1]))
  # Per-row display label keyed by term (sub-decision a: keyed attribute, not a
  # column). Parity with jlm. (return-shape audit)
  attr(coefficients_raw, "labels") <- stats::setNames(
    .jst_relabel_coef_names(term_keys, lab_src, all.vars(formula)[-1], sep = "_"),
    term_keys)

  # Raw, full-precision model-level fit statistics for japa() (the printed
  # Model Summary / Omnibus tables round these). Mirrors jlm's fit_raw with
  # logistic-specific fields. (return-shape audit)
  fit_raw <- list(
    ll_model      = ll_model,
    ll_null       = ll_null,
    deviance      = neg2ll,
    null_deviance = -2 * ll_null,
    chi_sq        = unname(chi_sq),
    omnibus_df    = omnibus_df,
    omnibus_p     = unname(omnibus_p),
    cox_snell_r2  = cox_snell_r2,
    nagelkerke_r2 = nagelkerke_r2,
    aic           = aic,
    n             = n_obs
  )

  ret <- list(
    model           = model,
    model_type      = "logistic",
    model_frame     = mf,
    formula_used    = formula,
    coefficients    = out_coefs,
    coefficients_raw = coefficients_raw,
    fit_raw         = fit_raw,
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
#' @param variable.id Character or NULL. Variable label display mode: one of
#'   \code{"both"}, \code{"names"}, \code{"labels"}, \code{"legend"}, or
#'   \code{"legend.bottom"}. \code{"names"} shows variable names only;
#'   \code{"both"} shows \code{"name: label"};
#'   \code{"labels"} shows each item's label in the Item column of the Item
#'   Statistics and Item-Total Statistics tables (best for short labels; the
#'   returned tables and the reverse-coding diagnostic keep variable names);
#'   \code{"legend"}/\code{"legend.bottom"} keep names and print a label
#'   legend after the final table. NULL (default) defers to \code{joutput()}'s
#'   \code{variable.id} setting. Not a logical.
#' @param value.id Not supported by \code{jalpha()}. The function does not
#'   display value labels, so passing this argument is an error. It exists
#'   only to return a clear message rather than misreporting the token as a
#'   missing variable. Leave at NULL (default).
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
#' @param digits Integer or NULL. Number of decimal places for continuous
#'   statistics in the output tables (range 0-7; \code{digits = 0} prints
#'   whole numbers with no trailing decimal point). Does not affect p-values,
#'   percentages, or integer quantities (counts, N, degrees of freedom),
#'   which keep their own fixed conventions. NULL (default) defers to
#'   \code{joutput()}'s \code{digits} setting (default 3).
#' @param case.processing.detail Per-call override of the Case
#'   Processing Summary detail tier: one of \code{"none"},
#'   \code{"totals"}, or \code{"per_code"}. \code{NULL} (default)
#'   uses the active \code{joutput()} level default.
jalpha <- function(data, ..., subset = NULL, variable.id = NULL,
                   value.id = NULL, case.processing.detail = NULL,
                   digits = NULL) {

  digits_n <- .jst_resolve_digits(digits)

  # jalpha has no per-code surface to display value labels on, so value.id is
  # accepted only to give an explicit, accurate error rather than the
  # misleading "variable not found: <token>" that resulted when the token fell
  # into the dots. A global joutput(value.id=) never arrives here as a per-call
  # arg, so a non-NULL value.id can only be an explicit per-call argument.
  # (Session 62, Option A)
  if (!is.null(value.id)) {
    stop("value.id is not supported by jalpha(); it does not display ",
         "value labels.", call. = FALSE)
  }

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
  alpha_overall <- round((k / (k - 1)) * (1 - sum(item_vars) / total_var), digits_n)

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

  # Variable label display mode. jalpha is a collapse layout: under "labels"
  # the per-item names in the Item Statistics and Item-Total Statistics
  # tables are swapped for their labels at print time only -- the returned
  # objects and the reverse-coding diagnostic keep variable names so the
  # user knows which column to act on. "legend"/"legend.bottom" collapse to
  # one legend after the final table.
  vlmode    <- .jst_resolve_variable_id(variable.id)
  item_disp <- if (vlmode %in% c("labels", "both")) {
    vapply(variable_names,
           function(v) .jst_combine_id(v, .jst_label_or_name(data, v), vlmode, cap = TRUE),
           character(1))
  } else {
    variable_names
  }

  # Item Statistics
  item_stats <- data.frame(
    Item = variable_names,
    Mean = round(colMeans(items_complete), digits_n),
    SD   = round(sapply(items_complete, stats::sd), digits_n),
    N    = n_used,
    stringsAsFactors = FALSE,
    row.names = NULL
  )

  item_stats_disp      <- item_stats
  item_stats_disp$Item <- item_disp
  .jst_print_table(item_stats_disp,
                   caption = "Item Statistics",
                   row.names = FALSE)
  cat("\n")

  # Item-Total Statistics
  total_scores    <- rowSums(items_complete)

  item_total_rows <- lapply(seq_along(variable_names), function(i) {
    item_name   <- variable_names[i]
    item_col    <- items_complete[[i]]
    rest_total  <- total_scores - item_col
    r_corrected <- round(stats::cor(item_col, rest_total), digits_n)

    remaining <- items_complete[, -i, drop = FALSE]
    k_r <- ncol(remaining)
    alpha_deleted <- if (k_r < 2) {
      NA
    } else {
      item_vars_r <- sapply(remaining, stats::var)
      total_var_r <- stats::var(rowSums(remaining))
      round((k_r / (k_r - 1)) * (1 - sum(item_vars_r) / total_var_r), digits_n)
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

  item_total_disp      <- item_total_table
  item_total_disp$Item <- item_disp
  .jst_print_table(item_total_disp,
                   caption = "Item-Total Statistics",
                   col.names = c("Item", "Corrected Item-Total r",
                                 "Alpha if Item Deleted"),
                   row.names = FALSE)

  cat("\n")

  if (vlmode %in% c("legend", "legend.bottom")) {
    .print_var_labels(data, variable_names)
  }

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
        "Map these values and re-run. ",
        "To leave unmapped values unchanged, add 'else=copy' to the map."
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
      stop(msg, call. = FALSE)
    }
  }

  # --- Validate extension ----------------------------------------------------
  if (!from_package && !ext %in% supported_ext) {
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
  if (from_package) {
    # Package dataset: df is already materialised; there is no file path to
    # resolve (resolved_path is not used on this path).
  } else if (has_dir) {
    # Full or relative path provided — use directly
    resolved_path <- file
    if (!file.exists(resolved_path)) {
      stop("File not found: ", .jst_norm_path(resolved_path), call. = FALSE)
    }
  } else {
    # Bare filename — search Data/, data/, then working directory
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
      stop(
        "The .rds file does not contain a data frame. ",
        "jload() only loads data frames.",
        call. = FALSE
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
  if (!is.null(reg_note)) say(reg_note)

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
      "missing-value metadata. Declared missing-value codes lose their ",
      "missing status, which may result in them being written as ordinary ",
      "numbers. Alternatively, use jsave(..., preserve.udm = FALSE) to blank ",
      "them to empty cells instead."))
  }

  # SPSS-style only: literal-numbers warning + suggestion.
  if (has_spss) {
    return(paste0(
      "Note: ", fmt, " does not store variable labels, value labels, or ",
      "missing-value metadata. Any SPSS-style missing-value codes (e.g. -99) ",
      "are written as literal numbers and will read back as ordinary values. ",
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

  # --- Pre-check: unquoted filename -----------------------------------------
  # A bare filename like jsave(mtcars, mtcars.rds) parses mtcars.rds as a
  # symbol, so forcing the file argument later yields the cryptic base-R
  # message "object 'mtcars.rds' not found". Detect the forgot-the-quotes
  # case up front and give a jsave-tailored message, mirroring the
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
        stop("'", file_str, "' is not quoted. Filenames must be in quotes, ",
             "e.g. jsave(", ex_data, ", \"", file_str, "\")",
             call. = FALSE)
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

  # Format-specific notes (emitted after a confirmed successful write).
  # Excel and CSV cannot store labels or missing-value metadata; the note
  # describes the loss (and, when preserve.udm = FALSE blanked SPSS-style
  # codes, confirms it). Not joutput-gated -- this is a loss-of-fidelity
  # warning (Decision 6B), not a verbosity-tier detail.
  if (ext %in% c("xlsx", "csv")) {
    label_note <- .jst_jsave_label_loss_note(
      ext, spss_udm_vars, stata_udm_vars, preserve.udm, n_udm_blanked)
    if (!is.null(label_note)) message(label_note)
  }

  # Classification registrations ride along only in .rds (baked above). Any
  # other format silently drops them, so note the loss -- but only when the
  # frame actually has registrations to lose. Same loss-of-fidelity footing as
  # the label note above; not joutput-gated.
  if (ext != "rds") {
    reg_loss_note <- .jst_jsave_registration_loss_note(ext, data_name)
    if (!is.null(reg_loss_note)) message(reg_loss_note)
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
      stop("Provide a destination name, e.g. jcopy(mydata, newdata).",
           call. = FALSE)
    }
    dest_sub <- substitute(data)
    src <- tryCatch(
      .jst_resolve_data(envir = parent.frame()),
      error = function(e)
        stop("No source given and no juse() default set. Either name the ",
             "source -- jcopy(mydata, ", paste(deparse(dest_sub),
             collapse = ""), ") -- or set a default with juse(mydata).",
             call. = FALSE)
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
        stop("The source must be a data frame. ",
             "Provide one, e.g. jcopy(mydata, newdata).", call. = FALSE)
      }
      src_name <- paste(deparse(src_sub), collapse = "")
    }
  }

  # Validate and normalise the destination name (mirrors jload()).
  dest_name <- paste(deparse(dest_sub), collapse = "")
  if (grepl("^[0-9]", dest_name)) {
    stop("The name '", dest_name, "' starts with a number. ",
         "R does not allow variable names to start with a digit.",
         call. = FALSE)
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
      warning("'", dest_name, "' already existed and has been replaced.",
              call. = FALSE)
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
#'   scatter plots. One of \code{ci} (default; 95% confidence band for
#'   the mean, flares at the ends), \code{pi} (95% prediction interval
#'   for individual observations), \code{see} (constant-width band at
#'   +/- t*SEE; useful for teaching homoskedasticity), \code{none}.
#' @param subset Optional unquoted logical expression to filter cases for
#'   this call only (data-first form).
#' @param labels Character or NULL. Variable label display mode (data-first
#'   and formula forms): one of \code{"both"}, \code{"names"}, \code{"labels"},
#'   \code{"legend"}, or \code{"legend.bottom"}. \code{"names"} uses variable
#'   names as axis/legend titles; \code{"labels"} uses each variable's label
#'   as its axis/legend title instead (falling back to the name when
#'   unlabelled) and prints no console legend; \code{"legend"} and
#'   \code{"legend.bottom"} keep names on the axes and print a console label
#'   legend. \code{"both"} is accepted but currently renders as \code{"names"}
#'   on plots (the \code{"name: label"} form for plot titles is deferred to a
#'   later phase). NULL (default) defers to \code{joutput()}'s
#'   \code{variable.id} setting. Not a logical.
#' @param numeric Optional character vector of plotted-variable names to treat
#'   as continuous for this call (the per-call counterpart of
#'   \code{jnumeric()}). In \code{jplot()} a variable's class chooses the
#'   geometry, so this forces numeric handling (histogram for a single
#'   variable; scatter / numeric axis in the formula and two-variable forms).
#'   Applies to the plotted variables only, not the \code{by} grouping
#'   variable.
#' @param categorical Optional character vector of plotted-variable names to
#'   treat as categorical for this call (the per-call counterpart of
#'   \code{jdummy()} for plotting purposes). Forces categorical geometry (bar
#'   for a single variable; box / categorical axis in the formula form). A
#'   variable cannot be listed in both \code{categorical} and
#'   \code{numeric}/\code{count}.
#' @param count Optional character vector of plotted-variable names to treat
#'   as counts for this call (the per-call counterpart of \code{jcount()}). A
#'   count is numeric-like for plotting, so it draws the same as \code{numeric};
#'   it is provided for symmetry with the other analysis functions.
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
                          band = "ci", subset = NULL, labels = NULL,
                          numeric = NULL, categorical = NULL, count = NULL) {

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
                              numeric = numeric, categorical = categorical,
                              count = count,
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

  # -- Per-call classification overrides -------------------------------------
  # In jplot a variable's class chooses the geometry (numeric -> histogram /
  # scatter point; categorical -> bar / box grouping). numeric=/categorical=/
  # count= assert that class for the named plotted variables, overriding the
  # structural guess (threaded into .jst_is_categorical below). A count is
  # numeric-like for geometry, so count= draws the same as numeric=; it is
  # exposed for symmetry and forward-compatibility. Overrides apply to the
  # plotted variables only, not to the by= grouping variable.
  for (.arg in c("numeric", "categorical", "count")) {
    .val <- get(.arg)
    if (!is.null(.val)) {
      .bad <- setdiff(.val, variable_names)
      if (length(.bad) > 0) {
        stop(.arg, " argument: ", paste0("'", .bad, "'", collapse = ", "),
             " not found among the variables passed to jplot(). Check for typos.",
             call. = FALSE)
      }
    }
  }
  # A variable cannot be both categorical and numeric-like (the assertions
  # contradict). numeric and count are both numeric-like, so they do not clash.
  .cat_clash <- intersect(categorical, c(numeric, count))
  if (length(.cat_clash) > 0) {
    stop(paste0("'", .cat_clash, "'", collapse = ", "),
         " listed in both categorical and numeric/count arguments.",
         call. = FALSE)
  }

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

  # Classify variables (per-call override > structure; see .jst_is_categorical)
  var_types <- vapply(variable_names,
                      function(v) {
                        ov <- if (v %in% categorical) "categorical"
                              else if (v %in% count)   "count"
                              else if (v %in% numeric) "numeric"
                              else NULL
                        if (.jst_is_categorical(data[[v]], v, .jst_data_name,
                                                override = ov))
                          "categorical" else "numeric"
                      },
                      character(1))

  # -- Single-variable geometry redirect (display only) ----------------------
  # The intent helper above calls an un-asserted labelled Likert (e.g.
  # community$Education, Environment1-5) "numeric", which routes it to a
  # histogram -- but a labelled/discrete vector is discrete on the x axis, so
  # geom_histogram() errors ("requires a continuous x aesthetic"). For the
  # single-variable auto case, when the variable carries NO explicit
  # numeric/count assertion (per-call override OR jnumeric/jcount registration)
  # and is structurally discrete (the existing structural detector --
  # centralizing the call so geometry and warnings can't drift apart), draw a
  # bar instead. This is a display choice only; it never changes analysis
  # classification, and an explicit numeric=/count= or registration is honoured
  # (those keep the histogram, which the builder hardens against labels below).
  if (n_vars == 1L && is.null(type) && var_types[1] == "numeric") {
    v1 <- variable_names[1]
    asserted_numeric <- v1 %in% c(numeric, count)
    intent <- if (!is.null(.jst_data_name))
      .jst_get_intent(.jst_data_name, v1) else NULL
    registered_numeric <- !is.null(intent) &&
      intent$kind %in% c("numeric", "count")
    if (!asserted_numeric && !registered_numeric &&
        inherits(data[[v1]], "haven_labelled") &&
        .jst_is_discrete_integer(data[[v1]], v1, .jst_data_name)) {
      var_types[1] <- "categorical"
    }
  }

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
  # Variable label display mode. jplot is a collapse layout where the
  # analogue of "names in rows" is the axis/legend title: under "labels" each
  # axis shows the variable's label, otherwise its name. "legend"/
  # "legend.bottom" additionally print a console label legend (below).
  vlmode <- .jst_resolve_variable_id(labels)
  axis_labels <- stats::setNames(
    vapply(variable_names,
           function(v) if (identical(vlmode, "labels")) {
             .jst_short_label(data[[v]], v)
           } else {
             v
           },
           character(1)),
    variable_names
  )
  by_label <- if (has_by) {
    if (identical(vlmode, "labels")) .jst_short_label(data[[by_name]], by_name) else by_name
  } else NULL

  # -- Red title --------------------------------------------------------------
  plot_title <- .jst_plot_title(resolved_type, variable_names, by_name)
  .cat_red(paste0(plot_title, "\n"))

  # Print pipeline messages (default data frame note, filter/complete status)
  if (.jst_default_used) .jst_default_note(.jst_data_name)
  .jst_print_msgs(pipeline$msgs)

  # Convert haven-labelled variables for plotting, by their resolved class.
  # A variable plotted with categorical geometry (bar, grouped bar, the x of a
  # box) becomes a factor so its value labels show; one plotted with numeric
  # geometry (histogram, scatter, the y of a box) is reduced to its underlying
  # numeric, because a labelled/factor column is discrete on a continuous axis
  # and would make geom_histogram() / scatter error. (Previously every labelled
  # variable with value labels was factored regardless of geometry, which is
  # what broke a histogram of a labelled Likert.) var_types is the per-variable
  # class the builders also read, so keying off it keeps conversion and
  # geometry consistent. Index with [[i]]: var_types here is a NAMED vector
  # (vapply over variable_names), so var_types[i] would carry the variable's
  # name and identical(named, "categorical") is always FALSE -- which silently
  # skipped the as_factor branch and bared the value labels off labelled bars.
  for (i in seq_along(variable_names)) {
    v <- variable_names[i]
    if (!haven::is.labelled(data[[v]])) next
    if (identical(var_types[[i]], "categorical")) {
      data[[v]] <- haven::as_factor(data[[v]])
    } else {
      data[[v]] <- as.numeric(data[[v]])
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

  # Console label legend (only under "legend"/"legend.bottom"; collapse).
  if (vlmode %in% c("legend", "legend.bottom")) {
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
                               numeric = NULL, categorical = NULL, count = NULL,
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

  # -- Per-call classification overrides (formula form) ---------------------
  # Same semantics as the variable-list form: numeric=/categorical=/count=
  # assert a plotted variable's class, which here decides scatter-vs-box (and
  # guards the numeric-DV requirement). count is numeric-like for geometry.
  # Scoped to the two formula variables (DV and IV); not the by= variable.
  .plot_vars <- c(y_name, x_name)
  for (.arg in c("numeric", "categorical", "count")) {
    .val <- get(.arg)
    if (!is.null(.val)) {
      .bad <- setdiff(.val, .plot_vars)
      if (length(.bad) > 0) {
        stop(.arg, " argument: ", paste0("'", .bad, "'", collapse = ", "),
             " not found among the formula variables in jplot(). Check for typos.",
             call. = FALSE)
      }
    }
  }
  .cat_clash <- intersect(categorical, c(numeric, count))
  if (length(.cat_clash) > 0) {
    stop(paste0("'", .cat_clash, "'", collapse = ", "),
         " listed in both categorical and numeric/count arguments.",
         call. = FALSE)
  }
  # Per-variable override role for .jst_is_categorical (NULL when unasserted).
  .ov_for <- function(v) {
    if (v %in% categorical) "categorical"
    else if (v %in% count)  "count"
    else if (v %in% numeric) "numeric"
    else NULL
  }

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
  y_is_num <- !.jst_is_categorical(data[[y_name]], y_name, .jst_data_name,
                                   override = .ov_for(y_name))
  x_is_cat <-  .jst_is_categorical(data[[x_name]], x_name, .jst_data_name,
                                   override = .ov_for(x_name))

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
    if (.jst_is_categorical(data[[x_name]], x_name, .jst_data_name,
                            override = .ov_for(x_name)))
      "categorical" else "numeric",
    if (.jst_is_categorical(data[[y_name]], y_name, .jst_data_name,
                            override = .ov_for(y_name)))
      "categorical" else "numeric"
  )
  # Note: for builders, variable_names is ordered (x, y) for scatter,
  # (x, y) for box (builder detects numeric side via var_types).
  variable_names <- c(x_name, y_name)

  # -- Capture axis labels BEFORE factor conversion -------------------------
  # Variable label display mode (see jplot.default): "labels" puts the
  # variable's label on each axis/legend title, otherwise its name.
  vlmode <- .jst_resolve_variable_id(labels)
  axis_labels <- stats::setNames(
    vapply(variable_names,
           function(v) if (identical(vlmode, "labels")) {
             .jst_short_label(data[[v]], v)
           } else {
             v
           },
           character(1)),
    variable_names
  )
  by_label <- if (has_by) {
    if (identical(vlmode, "labels")) .jst_short_label(data[[by_name]], by_name) else by_name
  } else NULL

  # -- Red title -------------------------------------------------------------
  plot_title <- .jst_plot_title(resolved_type, c(y_name, x_name), by_name)
  # For formula form, write the title as "Scatterplot: Tattoos and Age" where
  # DV comes first for readability even though x-axis is Age.
  # .jst_plot_title already puts the two names with " and " between them.
  .cat_red(paste0(plot_title, "\n"))

  if (.jst_default_used) .jst_default_note(.jst_data_name)
  .jst_print_msgs(pipeline$msgs)

  # -- Convert haven-labelled variables by their resolved class -------------
  # Geometry-aware, mirroring jplot.default: a categorical-typed variable
  # becomes a factor (so a box's x-axis shows its value labels); a numeric-
  # typed variable is reduced to its underlying numeric (so scatter points and
  # a box's numeric y-axis get a continuous aesthetic). Keying off var_types --
  # not the presence of value labels -- keeps conversion and geometry
  # consistent; the old label-led rule factored any labelled variable that
  # carried labels, which factorised a labelled continuous DV and made the
  # scatter/box error on a discrete axis. variable_names and var_types are both
  # ordered (x, y), so positional indexing aligns. Index with [[i]] (drops any
  # name) so identical() matches even if var_types is ever built named.
  for (i in seq_along(variable_names)) {
    v <- variable_names[i]
    if (!haven::is.labelled(data[[v]])) next
    if (identical(var_types[[i]], "categorical")) {
      data[[v]] <- haven::as_factor(data[[v]])
    } else {
      data[[v]] <- as.numeric(data[[v]])
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

  if (vlmode %in% c("legend", "legend.bottom")) {
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
  # A haven-labelled column is discrete on the x axis, so geom_histogram()
  # errors ("requires a continuous x aesthetic"). Strip the labels to the
  # underlying numeric for plotting -- declared missing codes have already
  # been converted to NA by the analysis pipeline before this point, so
  # as.numeric() yields the clean values. Handles both haven_labelled and
  # haven_labelled_spss. The geometry redirect in jplot() already sends most
  # labelled small-range variables to a bar; this is the safety net for any
  # that still route here (an explicit numeric=/count= or a labelled
  # continuous variable like a coded income).
  x_col <- data[[x_name]]
  if (inherits(x_col, "haven_labelled")) x_col <- as.numeric(x_col)
  plot_df <- data.frame(x = x_col)
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



# =============================================================================
#  APA-EXPORT ACCESSORS  (return-shape audit, Session 71)
# =============================================================================
#
# Two INTERNAL S3 accessors give a future japa() a stable read surface over the
# rich invisible return objects, so the stored layout can be rearranged later
# without breaking japa:
#
#   .jst_apa_terms(x)  -> flat per-row data frame (one row per coefficient,
#                         category, variable, or variable-pair, by class).
#   .jst_apa_model(x)  -> one-row model-level data frame, or NULL for classes
#                         with no single model-level summary.
#
# These never touch broom/generics. The per-row display label (stored as a
# keyed attribute on the regression / descriptives frames) is assembled into a
# `label` column HERE rather than carried as a column on the numeric frame.

.jst_apa_terms <- function(x, ...) UseMethod(".jst_apa_terms")
.jst_apa_model <- function(x, ...) UseMethod(".jst_apa_model")

.jst_apa_terms.default <- function(x, ...) NULL
.jst_apa_model.default <- function(x, ...) NULL

# -- Regression terms: jlm / jlogistic ----------------------------------------

.jst_apa_terms_regression <- function(x) {
  cr <- x$coefficients_raw
  if (is.null(cr)) return(NULL)
  lab <- attr(cr, "labels")
  out <- cr
  out$label <- if (is.null(lab)) NA_character_ else unname(lab[out$term])
  attr(out, "outcome") <- attr(cr, "outcome")
  out
}
.jst_apa_terms.jst_lm       <- function(x, ...) .jst_apa_terms_regression(x)
.jst_apa_terms.jst_logistic <- function(x, ...) .jst_apa_terms_regression(x)

.jst_apa_model.jst_lm <- function(x, ...) {
  f <- x$fit_raw
  if (is.null(f)) return(NULL)
  data.frame(
    outcome       = unname(attr(x$coefficients_raw, "outcome")["name"]),
    r_squared     = f$r_squared,
    adj_r_squared = f$adj_r_squared,
    sigma         = f$sigma,
    f_value       = f$f_value,
    f_df1         = f$f_df1,
    f_df2         = f$f_df2,
    f_p           = f$f_p,
    df_residual   = f$df_residual,
    n             = f$n,
    stringsAsFactors = FALSE, row.names = NULL)
}

.jst_apa_model.jst_logistic <- function(x, ...) {
  f <- x$fit_raw
  if (is.null(f)) return(NULL)
  data.frame(
    outcome       = unname(attr(x$coefficients_raw, "outcome")["name"]),
    ll_model      = f$ll_model,
    ll_null       = f$ll_null,
    deviance      = f$deviance,
    null_deviance = f$null_deviance,
    chi_sq        = f$chi_sq,
    omnibus_df    = f$omnibus_df,
    omnibus_p     = f$omnibus_p,
    cox_snell_r2  = f$cox_snell_r2,
    nagelkerke_r2 = f$nagelkerke_r2,
    aic           = f$aic,
    n             = f$n,
    stringsAsFactors = FALSE, row.names = NULL)
}

# -- Frequencies: jst_freq -----------------------------------------------------
# Per-row = one row per (variable, category); model-level = per-variable N.

.jst_apa_terms.jst_freq <- function(x, ...) {
  res <- x$frequencies
  if (is.null(res) || length(res) == 0) return(NULL)
  do.call(rbind, lapply(names(res), function(v) {
    vd <- res[[v]]$valid
    if (is.null(vd) || nrow(vd) == 0) return(NULL)
    vl <- if (is.null(res[[v]]$var_label)) v else res[[v]]$var_label
    data.frame(
      variable  = v,
      var_label = vl,
      value     = vd$Value,
      count     = vd$Freq,
      total_pct = vd$TotalPct,
      valid_pct = vd$ValidPct,
      cum_pct   = vd$CumPct,
      stringsAsFactors = FALSE, row.names = NULL)
  }))
}

.jst_apa_model.jst_freq <- function(x, ...) {
  res <- x$frequencies
  if (is.null(res) || length(res) == 0) return(NULL)
  do.call(rbind, lapply(names(res), function(v) {
    vl <- if (is.null(res[[v]]$var_label)) v else res[[v]]$var_label
    data.frame(
      variable  = v,
      var_label = vl,
      n_total   = res[[v]]$total,
      n_valid   = res[[v]]$valid_count,
      n_missing = res[[v]]$missing,
      stringsAsFactors = FALSE, row.names = NULL)
  }))
}

# -- Descriptives: jst_desc ----------------------------------------------------

.jst_apa_terms.jst_desc <- function(x, ...) {
  dr <- x$descriptives_raw
  if (is.null(dr)) return(NULL)
  lab <- attr(dr, "labels")
  out <- dr
  out$var_label <- if (is.null(lab)) out$variable else unname(lab[out$variable])
  out
}
.jst_apa_model.jst_desc <- function(x, ...) NULL

# -- Correlations: jst_corr ----------------------------------------------------
# Per-row = one row per unique variable pair (lower triangle).

.jst_apa_terms.jst_corr <- function(x, ...) {
  rmx <- x$r; pmx <- x$p; nmx <- x$n
  if (is.null(rmx)) return(NULL)
  vars <- rownames(rmx); k <- length(vars); lab <- x$labels
  rows <- list()
  for (i in seq_len(k)) for (j in seq_len(k)) if (j < i) {
    rows[[length(rows) + 1L]] <- data.frame(
      var1       = vars[i],
      var2       = vars[j],
      var1_label = if (is.null(lab)) vars[i] else unname(lab[vars[i]]),
      var2_label = if (is.null(lab)) vars[j] else unname(lab[vars[j]]),
      r          = rmx[i, j],
      p          = pmx[i, j],
      n          = nmx[i, j],
      stringsAsFactors = FALSE, row.names = NULL)
  }
  if (length(rows) == 0) return(NULL)
  do.call(rbind, rows)
}
.jst_apa_model.jst_corr <- function(x, ...) {
  data.frame(method = x$method, n_vars = length(rownames(x$r)),
             stringsAsFactors = FALSE, row.names = NULL)
}


# =============================================================================
#  OPTIONAL broom / generics ADAPTER  (external-only; never on japa's path)
# =============================================================================
#
# tidy() / glance() methods that project the rich jstats return DOWN to broom's
# lossy frame, for external tools (modelsummary, gtsummary). They are NOT
# exported and carry NO S3method() NAMESPACE entry; instead they are registered
# CONDITIONALLY at load via rlang::s3_register() in zzz.R, so they force no
# dependency -- a user without broom/generics never triggers them, and japa()
# never uses them. (return-shape audit, Session 71)

tidy.jst_lm <- function(x, conf.int = FALSE, conf.level = 0.95, ...) {
  cr  <- x$coefficients_raw
  out <- data.frame(
    term      = cr$term,
    estimate  = cr$b,
    std.error = cr$SE,
    statistic = cr$t,
    p.value   = cr$p,
    stringsAsFactors = FALSE, row.names = NULL)
  if (isTRUE(conf.int)) {
    out$conf.low  <- cr$ci_lower
    out$conf.high <- cr$ci_upper
  }
  out
}

glance.jst_lm <- function(x, ...) {
  f <- x$fit_raw
  data.frame(
    r.squared     = f$r_squared,
    adj.r.squared = f$adj_r_squared,
    sigma         = f$sigma,
    statistic     = f$f_value,
    p.value       = f$f_p,
    df            = f$f_df1,
    df.residual   = f$df_residual,
    nobs          = f$n,
    stringsAsFactors = FALSE, row.names = NULL)
}

tidy.jst_logistic <- function(x, conf.int = FALSE, conf.level = 0.95,
                              exponentiate = FALSE, ...) {
  cr  <- x$coefficients_raw
  est <- if (isTRUE(exponentiate)) cr$exp_b else cr$b
  out <- data.frame(
    term      = cr$term,
    estimate  = est,
    std.error = cr$SE,
    statistic = cr$b / cr$SE,
    p.value   = cr$p,
    stringsAsFactors = FALSE, row.names = NULL)
  if (isTRUE(conf.int)) {
    if (isTRUE(exponentiate)) {
      out$conf.low  <- cr$exp_ci_lower
      out$conf.high <- cr$exp_ci_upper
    } else {
      out$conf.low  <- log(cr$exp_ci_lower)
      out$conf.high <- log(cr$exp_ci_upper)
    }
  }
  out
}

glance.jst_logistic <- function(x, ...) {
  f <- x$fit_raw
  data.frame(
    null.deviance = f$null_deviance,
    df.null       = f$n - 1L,
    logLik        = f$ll_model,
    AIC           = f$aic,
    deviance      = f$deviance,
    df.residual   = f$n - nrow(x$coefficients_raw),
    nobs          = f$n,
    stringsAsFactors = FALSE, row.names = NULL)
}


# -- t-test / ANOVA / crosstab broom doors -------------------------------------
# More of the same: project the rich jstats return DOWN to broom's frame for
# external tools. tidy() only for the htest-backed t-test and chi-square (one
# row carries everything); tidy() + glance() for one-way ANOVA. Registered
# conditionally in zzz.R alongside the regression methods above.

tidy.jst_ttest <- function(x, ...) {
  ht  <- x$model
  est <- unname(ht$estimate)
  out <- data.frame(
    estimate = if (length(est) == 2L) est[1] - est[2] else est[1],
    stringsAsFactors = FALSE, row.names = NULL)
  if (length(est) == 2L) {
    out$estimate1 <- est[1]
    out$estimate2 <- est[2]
  }
  out$statistic   <- unname(ht$statistic)
  out$parameter   <- unname(ht$parameter)
  out$p.value     <- ht$p.value
  out$conf.low    <- ht$conf.int[1]
  out$conf.high   <- ht$conf.int[2]
  out$method      <- ht$method
  out$alternative <- ht$alternative
  out$cohens_d    <- x$cohens_d
  out$d_type      <- x$d_label
  out
}

tidy.jst_anova <- function(x, ...) {
  if (identical(x$test_type, "welch")) {
    # Welch one-way (stats::oneway.test): no sums of squares are available, so
    # sumsq / meansq are NA -- the term table keeps the same columns as the
    # traditional branch for a uniform shape.
    term_lab <- attr(stats::terms(x$formula), "term.labels")[1]
    return(data.frame(
      term      = c(term_lab, "Residuals"),
      df        = c(x$df1, x$df2),
      sumsq     = c(NA_real_, NA_real_),
      meansq    = c(NA_real_, NA_real_),
      statistic = c(x$f, NA_real_),
      p.value   = c(x$p, NA_real_),
      stringsAsFactors = FALSE, row.names = NULL))
  }
  # Traditional aov: read the ANOVA table (effect row(s) + Residuals).
  tab <- summary(x$model)[[1]]
  data.frame(
    term      = trimws(rownames(tab)),
    df        = tab[["Df"]],
    sumsq     = tab[["Sum Sq"]],
    meansq    = tab[["Mean Sq"]],
    statistic = tab[["F value"]],
    p.value   = tab[["Pr(>F)"]],
    stringsAsFactors = FALSE, row.names = NULL)
}

glance.jst_anova <- function(x, ...) {
  data.frame(
    statistic   = x$f,
    df          = x$df1,
    df.residual = x$df2,
    p.value     = x$p,
    eta.squared = x$eta_squared,
    nobs        = x$n,
    stringsAsFactors = FALSE, row.names = NULL)
}

tidy.jst_crosstab <- function(x, ...) {
  if (is.null(x$chi_square)) {
    stop("This jcrosstab() result has no chi-square test to tidy. ",
         "Re-run with jcrosstab(..., chisq = TRUE).", call. = FALSE)
  }
  data.frame(
    statistic = unname(x$chi_square),
    parameter = unname(x$df),
    p.value   = unname(x$p),
    method    = "Pearson's Chi-squared test",
    n         = x$n,
    stringsAsFactors = FALSE, row.names = NULL)
}
