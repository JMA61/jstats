#<<<FILE: utils.R>>>
#' jstats: Simplified Statistical Analysis Tools for Social Science
#'
#' @description
#' jstats simplifies R for users who need to do social science
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
#' quantitative research community -- criminologists, sociologists,
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
#'   \item \code{\link{jdesc}} -- univariate descriptives (mean, median, SD, range, etc.) with optional grouping
#'   \item \code{\link{jfreq}} -- frequency tables for one or more variables
#'   \item \code{\link{jcorr}} -- Pearson or Spearman correlations with significance tests
#'   \item \code{\link{jalpha}} -- Cronbach's alpha and item-total statistics for scale reliability
#'   \item \code{\link{jscreen}} -- data screening for outliers, ranges, and skew
#' }
#'
#' \strong{Group comparisons and modeling}
#' \itemize{
#'   \item \code{\link{jt}} -- independent or paired t-test
#'   \item \code{\link{jaov}} -- one-way analysis of variance with optional post-hoc tests
#'   \item \code{\link{jcrosstab}} -- cross-tabulation with chi-square and effect-size options
#'   \item \code{\link{jlm}} -- linear regression
#'   \item \code{\link{jlogistic}} -- logistic regression
#' }
#'
#' \strong{Variable construction}
#' \itemize{
#'   \item \code{\link{jrecode}} -- recode values, with optional new value labels
#'   \item \code{\link{jrelabel}} -- apply or replace value labels and variable label
#'   \item \code{\link{jsum}} -- row-wise sum across variables, with min-valid handling
#'   \item \code{\link{javg}} -- row-wise mean across variables, with min-valid handling
#' }
#'
#' \strong{Pipeline state management}
#' \itemize{
#'   \item \code{\link{juse}} -- set the default data frame used implicitly by analysis functions
#'   \item \code{\link{jsubset}} -- activate a row-level case-selection expression applied to subsequent calls
#'   \item \code{\link{jcomplete}} -- activate listwise filtering on selected variables
#'   \item \code{\link{jdummy}} -- register categorical variables for dummy coding in regression
#'   \item \code{\link{joutput}} -- set session-level output verbosity (minimal / standard / full)
#' }
#'
#' \strong{Data import and export}
#' \itemize{
#'   \item \code{\link{jload}} -- load data from \code{.rds}, \code{.sav}, \code{.dta}, \code{.sas7bdat}, \code{.xlsx}, or \code{.csv}
#'   \item \code{\link{jsave}} -- save a data frame, with format inferred from the file extension
#' }
#'
#' \strong{Visualisation}
#' \itemize{
#'   \item \code{\link{jplot}} -- base histograms and bar plots for data, plus method dispatch on result objects from \code{jt()}, \code{jlm()}, etc.
#' }
#'
#' For the full alphabetical listing of every exported function, run
#' \code{library(help = "jstats")} or browse the package index.
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
#' read automatically. State is explicit -- calls can be inspected,
#' inactivated, and cleared, and active state is reported in analysis
#' output, so a script's behavior stays visible and reproducible
#' rather than depending on hidden context.
#'
#' \strong{Output verbosity.} \code{joutput()} sets one of three
#' preset levels -- \code{minimal}, \code{standard} (default), or
#' \code{full} -- that modulate how much detail analysis functions
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
#'     \code{library(help = "jstats")}.
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

#' Internal helper: build a persistence/durability note
#'
#' Returns the standardized "where does this state live, and how do you make
#' it last" note shared by every state-setting verb. The note states which
#' durability rung the just-applied state reached and the action to climb to
#' the next rung. The mechanics deliberately differ by verb -- the registry
#' verbs (jnumeric, jcount, jlikert, jdummy) annotate the session through a
#' notebook, while jdeclare_udm writes a missing-value declaration onto the
#' data frame -- so the rung argument selects the wording rather than the
#' helper inferring it.
#'
#' Returns the note as a single string with the embedded "Note:" level prefix
#' and NO trailing newline. Callers emit it however they already do: the
#' registry verbs message() it; jdeclare_udm appends it to its larger
#' notification string. Visibility (standard and full, suppressed at minimal)
#' is the caller's gate, not this helper's.
#'
#' One deliberate divergence between the two rungs: the "session" rung names
#' "R format (.rds)" because registry registrations bake only into .rds, while
#' the "frame" rung says generic "save the data frame" because UDM codes also
#' survive .sav and .dta, so naming .rds there would be a false constraint.
#'
#' @param rung One of \code{"session"} (registry registrations -- jnumeric,
#'   jcount, jlikert, jdummy) or \code{"frame"} (a UDM declaration --
#'   jdeclare_udm).
#' @param data_name Character string name of the data frame, used to build the
#'   jsave() example and, for the "frame" rung, the reassignment line.
#' @param count Integer number of registrations just set ("session" rung
#'   only); controls singular/plural agreement. Unspecified or not equal to 1
#'   yields the plural form.
#' @param verb Character string name of the calling verb ("frame" rung only),
#'   used to build the reassignment line.
#' @param var_name Character string variable name ("frame" rung only), used to
#'   build the reassignment line.
#' @param codes_str Character string of the rendered \code{codes =} argument
#'   value ("frame" rung only). When supplied, the reassignment line shows the
#'   actual call (e.g. \code{codes = c(-99, -98)}); when NULL it shows the
#'   generic \code{...} template.
#' @keywords internal
.jst_durability_note <- function(rung, data_name, count = NULL,
                                 verb = NULL, var_name = NULL,
                                 codes_str = NULL) {
  save_call <- paste0("jsave(", data_name, ", \"", data_name, ".rds\")")
  if (identical(rung, "session")) {
    if (isTRUE(count == 1L)) {
      paste0(
        "Note: this registration is stored for this session only.\n",
        "To keep it across sessions, save the data frame in R format (.rds): ",
        save_call, "."
      )
    } else {
      paste0(
        "Note: registrations are stored for this session only.\n",
        "To keep them across sessions, save the data frame in R format (.rds): ",
        save_call, "."
      )
    }
  } else if (identical(rung, "frame")) {
    args_tail <- if (!is.null(codes_str) && nzchar(codes_str)) {
      paste0("codes = ", codes_str)
    } else {
      "..."
    }
    paste0(
      "Note: assign the result to store the declaration on the data frame: ",
      data_name, " <- ", verb, "(", data_name, ", ", var_name, ", ",
      args_tail, ").\n",
      "To keep it across sessions, save the data frame: ", save_call, "."
    )
  } else {
    stop("Internal error: .jst_durability_note() rung must be ",
         "\"session\" or \"frame\".", call. = FALSE)
  }
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
