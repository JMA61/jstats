
# -- Internal helpers ----------------------------------------------------------

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
#'
#' @keywords internal
.jst_print_table <- function(df, col.names = NULL, row.names = TRUE,
                             align = NULL, caption = NULL, indent = 2) {

  headers <- if (!is.null(col.names)) col.names else names(df)

  # Build display matrix
  display_cols <- lapply(seq_len(ncol(df)), function(j) {
    col <- df[[j]]
    if (is.numeric(col)) {
      ifelse(is.na(col), "", format(col, trim = TRUE))
    } else {
      as.character(ifelse(is.na(col), "", col))
    }
  })
  display <- do.call(cbind, display_cols)

  if (row.names && !is.null(rownames(df)) &&
      !identical(rownames(df), as.character(seq_len(nrow(df))))) {
    display <- cbind(rownames(df), display)
    headers <- c("", headers)
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

  fmt_cell <- function(text, width, alignment) {
    text <- trimws(text)
    switch(alignment,
           "r" = formatC(text, width = width, flag = " "),
           "c" = formatC(text, width = width, format = "s"),
           formatC(text, width = -width, flag = "-")
    )
  }

  if (!is.null(caption)) {
    cat(prefix, caption, "\n", sep = "")
  }

  # Header
  header_cells <- vapply(seq_len(n_cols), function(j) {
    fmt_cell(headers[j], col_widths[j], align[j])
  }, character(1))
  cat(prefix, paste(header_cells, collapse = gap), "\n", sep = "")

  # Separator
  sep_cells <- vapply(col_widths, function(w) {
    paste(rep("-", w), collapse = "")
  }, character(1))
  cat(prefix, paste(sep_cells, collapse = gap), "\n", sep = "")

  # Data rows
  for (i in seq_len(n_rows)) {
    row_cells <- vapply(seq_len(n_cols), function(j) {
      fmt_cell(display[i, j], col_widths[j], align[j])
    }, character(1))
    cat(prefix, paste(row_cells, collapse = gap), "\n", sep = "")
  }
}




# -----------------------------------------------------------------------------
# Data pipeline helpers: jcomplete / jfilter storage and application
# These helpers manage per-dataset filter and complete-case settings,
# apply them in the correct order, and generate info-line messages.
# -----------------------------------------------------------------------------

#' @keywords internal
.jst_get_filter <- function(data_name) {
  all_filters <- getOption(".jst_filter", default = list())
  all_filters[[data_name]]
}

#' @keywords internal
.jst_get_complete <- function(data_name) {
  all_complete <- getOption(".jst_complete", default = list())
  all_complete[[data_name]]
}

#' @keywords internal
.jst_set_filter <- function(data_name, settings) {
  all_filters <- getOption(".jst_filter", default = list())
  all_filters[[data_name]] <- settings
  options(.jst_filter = all_filters)
}

#' @keywords internal
.jst_set_complete <- function(data_name, settings) {
  all_complete <- getOption(".jst_complete", default = list())
  all_complete[[data_name]] <- settings
  options(.jst_complete = all_complete)
}

#' @keywords internal
.jst_get_dummy <- function(data_name) {
  all_dummy <- getOption(".jst_dummy", default = list())
  all_dummy[[data_name]]
}

#' @keywords internal
.jst_set_dummy <- function(data_name, settings) {
  all_dummy <- getOption(".jst_dummy", default = list())
  all_dummy[[data_name]] <- settings
  options(.jst_dummy = all_dummy)
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
#'     \item{dummy_coef_names}{Character vector of dummy column names (for blanking Std B).}
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
        # Create dummy columns in data
        orig_col <- as.numeric(data[[reg$var_name]])
        for (j in seq_along(reg$non_ref_idx)) {
          idx   <- reg$non_ref_idx[j]
          dname <- reg$dummy_names[j]
          data[[dname]] <- ifelse(is.na(orig_col), NA_integer_,
                                  as.integer(orig_col == reg$codes[idx]))
          dummy_coef_names <- c(dummy_coef_names, dname)
        }

        # Replace variable in formula string with dummy names.
        # Wrapping in parentheses ensures correct behaviour when the variable
        # appears inside an interaction term (e.g. y ~ x * Religion).
        dummy_plus <- paste0("(", paste(reg$dummy_names, collapse = " + "), ")")
        formula_str <- gsub(paste0("\\b", reg$var_name, "\\b"),
                            dummy_plus, formula_str)

        ref_cats <- c(ref_cats, paste0(reg$var_name, " = ", reg$ref_label))
      }
    }

    formula    <- stats::as.formula(formula_str)
  }

  list(data = data, formula = formula, ref_cats = ref_cats,
       dummy_coef_names = dummy_coef_names)
}

#' Internal helper: apply the full data pipeline and return filtered data + messages
#'
#' Order of operations:
#' \enumerate{
#'   \item jcomplete (listwise deletion for registered variables)
#'   \item jfilter (substantive filtering expression)
#'   \item subset (one-off per-call filter)
#' }
#'
#' When the dataset was specified explicitly (not via juse default), jcomplete
#' and jfilter are skipped and a note is printed if settings exist.
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

  # Pipeline count tracking
  n_after_complete <- NULL
  n_after_filter   <- NULL
  n_after_subset   <- NULL
  complete_active  <- FALSE
  filter_active    <- FALSE
  filter_expr_str  <- NULL

  if (is_default) {

    # -- Step 1: jcomplete ---------------------------------------------------
    cs <- .jst_get_complete(data_name)
    if (!is.null(cs)) {
      if (cs$active) {
        complete_active <- TRUE
        valid_vars <- cs$vars[cs$vars %in% names(data)]
        if (length(valid_vars) > 0) {
          n_before      <- nrow(data)
          complete_mask <- stats::complete.cases(data[, valid_vars, drop = FALSE])
          data          <- data[complete_mask, , drop = FALSE]
          n_after       <- nrow(data)
          n_after_complete <- n_after
          n_excluded    <- n_before - n_after
          if (n_excluded > 0) {
            msgs <- c(msgs, paste0(
              "(jcomplete active: ", n_after, " of ", n_before,
              " cases \u2014 ", n_excluded, " excluded due to missing values)"))
          } else {
            msgs <- c(msgs, paste0(
              "(jcomplete active: ", n_after, " of ", n_before,
              " cases \u2014 no missing values)"))
          }
        } else {
          n_after_complete <- nrow(data)
        }
      } else {
        msgs <- c(msgs, "(jcomplete set but inactive)")
      }
    }

    # -- Step 2: jfilter -----------------------------------------------------
    fs <- .jst_get_filter(data_name)
    if (!is.null(fs)) {
      if (fs$active) {
        filter_active   <- TRUE
        filter_expr_str <- fs$expr_str
        n_before <- nrow(data)
        mask <- tryCatch(
          eval(fs$expr, data, envir),
          error = function(e) {
            warning("Filter expression could not be evaluated: ",
                    conditionMessage(e), call. = FALSE)
            rep(TRUE, nrow(data))
          }
        )
        mask[is.na(mask)] <- FALSE
        data    <- data[mask, , drop = FALSE]
        n_after <- nrow(data)
        n_after_filter <- n_after
        msgs <- c(msgs, paste0(
          "(Filter active: ", fs$expr_str, " \u2014 ",
          n_after, " of ", n_before, " cases selected)"))
      } else {
        msgs <- c(msgs, "(Filter set but inactive)")
      }
    }

  } else {
    # Explicit dataset — note if any defaults exist for the juse dataset
    default_name <- getOption(".jst_default_data", default = NULL)
    if (!is.null(default_name)) {
      has_complete <- !is.null(.jst_get_complete(default_name))
      has_filter   <- !is.null(.jst_get_filter(default_name))
      if (has_complete && has_filter) {
        msgs <- c(msgs, paste0(
          "(Note: jcomplete and jfilter not applied",
          " \u2014 data frame specified explicitly)"))
      } else if (has_complete) {
        msgs <- c(msgs, paste0(
          "(Note: jcomplete not applied",
          " \u2014 data frame specified explicitly)"))
      } else if (has_filter) {
        msgs <- c(msgs, paste0(
          "(Note: jfilter not applied",
          " \u2014 data frame specified explicitly)"))
      }
    }
  }

  # -- Step 3: subset (always applies) -------------------------------------
  if (!is.null(subset_expr)) {
    n_before <- nrow(data)
    mask <- tryCatch(
      eval(subset_expr, data, envir),
      error = function(e) {
        stop("Subset expression could not be evaluated: ",
             conditionMessage(e), call. = FALSE)
      }
    )
    mask[is.na(mask)] <- FALSE
    data    <- data[mask, , drop = FALSE]
    n_after <- nrow(data)
    n_after_subset <- n_after
    msgs <- c(msgs, paste0(
      "(Subset: ", deparse(subset_expr), " \u2014 ",
      n_after, " of ", n_before, " cases remaining)"))
  }

  pipeline_counts <- list(
    n_original       = n_original,
    n_after_complete = n_after_complete,
    n_after_filter   = n_after_filter,
    n_after_subset   = n_after_subset,
    complete_active  = complete_active,
    filter_active    = filter_active,
    filter_expr      = filter_expr_str
  )

  list(data = data, msgs = msgs, pipeline_counts = pipeline_counts)
}

#' Internal helper: print info-line messages generated by the pipeline
#'
#' @keywords internal
.jst_print_msgs <- function(msgs) {
  for (m in msgs) cat(m, "\n")
}

#' Internal helper: build standardised sample_info block
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
    n_original       = pipeline_counts$n_original,
    n_after_complete = pipeline_counts$n_after_complete,
    n_after_filter   = pipeline_counts$n_after_filter,
    n_after_subset   = pipeline_counts$n_after_subset,
    n_analysis       = n_analysis,
    n_excluded_missing = n_excluded_missing,
    missing_by_var   = missing_by_var,
    complete_active  = pipeline_counts$complete_active,
    filter_active    = pipeline_counts$filter_active,
    filter_expr      = pipeline_counts$filter_expr
  )
}

# Output level preset defaults (used by .jst_resolve_toggle and joutput)
.jst_output_defaults <- list(
  minimal  = list(effect.size = FALSE, ci = FALSE, levene = FALSE,
                  posthoc = FALSE, missing = FALSE, diagnostics = FALSE),
  standard = list(effect.size = TRUE,  ci = TRUE,  levene = FALSE,
                  posthoc = FALSE, missing = FALSE, diagnostics = FALSE),
  full     = list(effect.size = TRUE,  ci = TRUE,  levene = TRUE,
                  posthoc = TRUE,  missing = TRUE,  diagnostics = TRUE)
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
  level    <- getOption(".jst_output_level", "minimal")
  defaults <- .jst_output_defaults
  defaults[[level]][[name]]
}

#' Internal helper: print per-variable missing data breakdown
#'
#' Prints a detail line showing how many missing values each analysis variable
#' contributed. Only called when the missing toggle is active and there are
#' missing values.
#'
#' @param missing_by_var Named integer vector from sample_info$missing_by_var.
#'
#' @keywords internal
.jst_print_missing_detail <- function(missing_by_var) {
  has_missing <- missing_by_var[missing_by_var > 0]
  if (length(has_missing) > 0) {
    detail <- paste0(names(has_missing), " (", has_missing, ")",
                     collapse = ", ")
    cat("  Missing by variable: ", detail, "\n", sep = "")
  }
}

#' Internal helper: check that variable names exist in a data frame
#'
#' Produces a clear error message listing any variables not found,
#' so students see helpful feedback instead of cryptic internal error traces.
#'
#' @keywords internal
.jst_check_vars <- function(data, var_names, data_name = NULL) {
  missing_vars <- var_names[!var_names %in% names(data)]
  if (length(missing_vars) > 0) {
    df_label <- if (!is.null(data_name)) {
      paste0("'", data_name, "'")
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

# -----------------------------------------------------------------------------
# .jst_check_args()
# Catches mis-named argument aliases passed via ... and errors with a helpful
# "did you mean" suggestion. Also catches any other named argument in ... and
# errors with a plain unused-argument message. Used by functions that accept
# ... purely as a safety net (not for substantive variable-passing).
#
# aliases: named character vector where names are the wrong names users might
#   type and values are the correct argument name to suggest.
# -----------------------------------------------------------------------------

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

# -----------------------------------------------------------------------------
# .jst_resolve_data()
# Looks up the default data frame set by juse(). Called by all student-facing
# functions when the data argument is not specified. Returns a list with
# $data (the data frame) and $name (the stored name as a string).
# Stops with a clear message if no default is set or the data frame is missing.
# Uses the calling environment (passed in via envir) to look up the data frame.
# -----------------------------------------------------------------------------

.jst_resolve_data <- function(envir = parent.frame()) {
  data_name <- getOption(".jst_default_data", default = NULL)
  if (is.null(data_name)) {
    stop("No data frame specified and no default set. Use juse() to set a default.",
         call. = FALSE)
  }
  if (!exists(data_name, envir = envir)) {
    stop(paste0("Default data frame '", data_name,
                "' not found. It may have been removed or renamed."),
         call. = FALSE)
  }
  data <- get(data_name, envir = envir)
  if (!is.data.frame(data)) {
    stop(paste0("'", data_name, "' is not a data frame."), call. = FALSE)
  }
  list(data = data, name = data_name)
}

# -----------------------------------------------------------------------------
# .jst_detect_suspicious_values()
# Detects values that look like coded missing values (e.g. -99, -9, 999).
# Two detection rules:
#   1. Any negative value when all other values are positive (catches -9,
#      -99, etc. in categorical variables coded with positive integers)
#   2. Any value whose absolute magnitude is 5+ times the maximum of the
#      other values (catches 99 in a 1-5 variable, 999 in a 1-10 variable)
#
# Returns a numeric vector of suspicious values found (empty if none).
# Does NOT print messages — the calling function handles messaging.
# -----------------------------------------------------------------------------

.jst_detect_suspicious_values <- function(x, var_name) {

  vals <- unique(as.numeric(x[!is.na(x)]))
  if (length(vals) < 2) return(numeric(0))

  suspicious <- numeric(0)

  # Rule 1: negative values when all others are positive AND
  # the absolute magnitude is at least 3x the max positive value
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
# .jst_missing_comma_error()
# Called when a data-first function's data argument fails to evaluate. This
# typically means the student wrote jfreq(VarName) instead of jfreq(, VarName).
# Produces a helpful error message pointing them to the leading comma.
# -----------------------------------------------------------------------------

.jst_missing_comma_error <- function(data_expr_str, fn_name, original_error) {
  default_df <- getOption(".jst_default_data", default = NULL)
  if (!is.null(default_df)) {
    stop(paste0(
      "If '", data_expr_str, "' is a variable name in '", default_df,
      "', add a leading comma: ", fn_name, "(, ", data_expr_str, ").\n",
      "Otherwise, check spelling and capitalisation, or verify the data frame is loaded."
    ), call. = FALSE)
  } else {
    stop(paste0(
      "'", data_expr_str, "' not found. Did you mean to use it as a variable name?\n",
      "If so, provide the data frame: ", fn_name, "(MyData, ", data_expr_str, ")\n",
      "Or set a default first with juse(MyData), then: ", fn_name, "(, ", data_expr_str, ")"
    ), call. = FALSE)
  }
}


# -----------------------------------------------------------------------------
# .jst_parse_map()
# Parses a map string like "1=1; 2,3=2; 4,5=3; else=copy" into a structured
# list of mapping rules and an else action. Returns:
#   $mappings      - list of lists, each with $old_vals (numeric vector) and
#                    $new_val (single numeric)
#   $else_action   - "na" or "copy"
#   $else_explicit - TRUE if the user wrote an else clause, FALSE if defaulted
# Stops with a clear message if the string is malformed.
# -----------------------------------------------------------------------------

.jst_parse_map <- function(map_str) {

  rules <- trimws(strsplit(map_str, ";")[[1]])
  rules <- rules[nchar(rules) > 0]

  if (length(rules) == 0) {
    stop("The map argument is empty. Provide at least one rule, e.g. map = \"1=1; 2=0\".", call. = FALSE)
  }

  result <- list(mappings = list(), else_action = "na", else_explicit = FALSE)

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
      if (!tolower(rhs) %in% c("na", "copy")) {
        stop(paste0(
          "Invalid else action '", rhs, "' in map argument. ",
          "Use 'else=NA' or 'else=copy'."
        ), call. = FALSE)
      }
      result$else_action   <- tolower(rhs)
      result$else_explicit <- TRUE
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
    if (toupper(trimws(rhs)) == "NA") {
      new_val <- NA_real_
    } else {
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
          "New values must be numeric (or NA)."
        ), call. = FALSE)
      }
    }

    result$mappings[[length(result$mappings) + 1]] <- list(
      old_vals = old_vals,
      new_val  = new_val
    )
  }

  if (length(result$mappings) == 0) {
    stop("The map argument contains no valid recode rules (only an else clause was found).", call. = FALSE)
  }

  return(invisible(result))
}


# -----------------------------------------------------------------------------
# .jst_parse_labels()
# Parses a labels string like "1=Young; 2=Middle Aged; 3=Older" into a named
# numeric vector in haven_labelled format (names = label text, values = codes).
# Splits on the FIRST equals sign only, so label text may contain equals signs.
# -----------------------------------------------------------------------------

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

    val <- suppressWarnings(as.numeric(val_str))
    if (is.na(val)) {
      stop(paste0(
        "Invalid value '", val_str, "' in label rule '", rule, "'. ",
        "The left side of each label rule must be numeric."
      ), call. = FALSE)
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
#' jdesc(, mpg, hp)       # Uses mtcars automatically
#' juse(NULL)             # Clear the default
#' }
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
    stop(paste0("'", data_name, "' not found."), call. = FALSE)
  }
  if (!is.data.frame(get(data_name, envir = calling_env))) {
    stop(paste0("'", data_name, "' is not a data frame."), call. = FALSE)
  }

  options(.jst_default_data = data_name)
  message("Default data frame set to: ", data_name)
  invisible(NULL)
}


# -- jfilter ------------------------------------------------------------------

#' Set, activate, deactivate, or clear a global data filter
#'
#' @description
#' \code{jfilter()} sets a persistent filter expression that is applied
#' automatically by all JeffsStatTools analysis functions when the default
#' data frame (set by \code{juse()}) is in use. This is analogous to
#' the SPSS FILTER command.
#'
#' The filter is stored per dataset, so switching \code{juse()} between
#' datasets preserves each dataset's filter independently.
#'
#' When a data frame is specified explicitly in a function call (e.g.
#' \code{jfreq(MyData, Computer)}), the filter is not applied
#' for that call.
#'
#' @param expr A logical expression (e.g. \code{Group == 1}), or one
#'   of the following special values:
#'   \describe{
#'     \item{\code{off}}{Deactivate the filter but remember the expression.}
#'     \item{\code{on}}{Reactivate a previously deactivated filter.}
#'     \item{\code{NULL}}{Clear the filter entirely (forget the expression).}
#'   }
#'   If omitted, prints the current filter status.
#'
#' @return Invisibly returns \code{NULL}. Called for its side effect.
#'
#' @examples
#' \donttest{
#' juse(mtcars)
#' jfilter(cyl == 4)       # Set and activate
#' jdesc(, mpg)            # Uses only 4-cylinder cars
#' jfilter(off)            # Deactivate
#' jdesc(, mpg)            # Uses all cars
#' jfilter(on)             # Reactivate
#' jfilter()               # Check status
#' jfilter(NULL)           # Clear entirely
#' }
#'
#' @export
jfilter <- function(expr) {

  # Get the current default dataset name
  default_name <- getOption(".jst_default_data", default = NULL)

  if (missing(expr)) {
    # jfilter() — print status
    if (is.null(default_name)) {
      message("No default data frame set. Use juse() first.")
      return(invisible(NULL))
    }
    fs <- .jst_get_filter(default_name)
    if (is.null(fs)) {
      message("No filter set for ", default_name, ".")
    } else if (fs$active) {
      message("Filter active for ", default_name, ": ", fs$expr_str)
    } else {
      message("Filter set but inactive for ", default_name, ".")
    }
    return(invisible(NULL))
  }

  # Capture unevaluated expression BEFORE any evaluation
  raw_expr <- substitute(expr)
  expr_str <- deparse(raw_expr, width.cutoff = 500)

  # jfilter(NULL) — clear (substitute(NULL) returns NULL)
  if (is.null(raw_expr)) {
    if (!is.null(default_name)) {
      .jst_set_filter(default_name, NULL)
      message("Filter cleared for ", default_name, ".")
    } else {
      message("No default data frame set. Nothing to clear.")
    }
    return(invisible(NULL))
  }

  # jfilter(off) / jfilter(on)
  if (is.symbol(raw_expr)) {
    sym_name <- as.character(raw_expr)
    if (tolower(sym_name) == "off") {
      if (is.null(default_name)) {
        message("No default data frame set.")
        return(invisible(NULL))
      }
      fs <- .jst_get_filter(default_name)
      if (is.null(fs)) {
        message("No filter set for ", default_name, ". Nothing to deactivate.")
      } else {
        fs$active <- FALSE
        .jst_set_filter(default_name, fs)
        message("Filter deactivated for ", default_name, ".")
      }
      return(invisible(NULL))
    }
    if (tolower(sym_name) == "on") {
      if (is.null(default_name)) {
        message("No default data frame set.")
        return(invisible(NULL))
      }
      fs <- .jst_get_filter(default_name)
      if (is.null(fs)) {
        message("No filter set for ", default_name, ". Use jfilter(expression) to set one.")
      } else {
        fs$active <- TRUE
        .jst_set_filter(default_name, fs)
        message("Filter reactivated for ", default_name, ": ", fs$expr_str)
      }
      return(invisible(NULL))
    }
  }

  # jfilter(expression) — set and activate
  if (is.null(default_name)) {
    stop("No default data frame set. Use juse() first.", call. = FALSE)
  }

  .jst_set_filter(default_name, list(
    expr     = raw_expr,
    expr_str = expr_str,
    active   = TRUE
  ))
  message("Filter set and activated for ", default_name, ": ", expr_str)
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
#' When a data frame is specified explicitly in a function call, the
#' jcomplete filter is not applied for that call.
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
#' jcomplete(, mpg, hp, wt, am)
#' jdesc(, mpg)                   # Uses only complete cases on those 4 vars
#' jcomplete(off)                 # Deactivate
#' jcomplete(on)                  # Reactivate
#' jcomplete()                    # Check status
#' jcomplete(NULL)                # Clear entirely
#' }
#'
#' @export
jcomplete <- function(data, ...) {

  default_name <- getOption(".jst_default_data", default = NULL)

  # -- No arguments: print status -------------------------------------------
  if (missing(data) && ...length() == 0) {
    if (is.null(default_name)) {
      message("No default data frame set. Use juse() first.")
      return(invisible(NULL))
    }
    cs <- .jst_get_complete(default_name)
    if (is.null(cs)) {
      message("No jcomplete filter set for ", default_name, ".")
    } else if (cs$active) {
      calling_env <- parent.frame()
      if (exists(default_name, envir = calling_env)) {
        df <- get(default_name, envir = calling_env)
        valid_vars <- cs$vars[cs$vars %in% names(df)]
        if (length(valid_vars) > 0) {
          n_total    <- nrow(df)
          n_complete <- sum(stats::complete.cases(df[, valid_vars, drop = FALSE]))
          message("jcomplete active for ", default_name, ": ",
                  n_complete, " of ", n_total, " complete cases")
          message("Variables: ", paste(cs$vars, collapse = ", "))
        }
      } else {
        message("jcomplete active for ", default_name)
        message("Variables: ", paste(cs$vars, collapse = ", "))
      }
    } else {
      message("jcomplete set but inactive for ", default_name, ".")
      message("Variables: ", paste(cs$vars, collapse = ", "))
    }
    return(invisible(NULL))
  }

  # -- Capture substitute BEFORE any evaluation ------------------------------
  # This must happen before is.null(data) or any other use of data,
  # otherwise bare symbols like off/on cause "object not found" errors.
  raw_data <- if (!missing(data)) substitute(data) else NULL

  # -- jcomplete(off) / jcomplete(on) — check BEFORE evaluating data --------
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
                ". Use jcomplete(, var1, var2, ...) to set one.")
      } else {
        cs$active <- TRUE
        .jst_set_complete(default_name, cs)
        message("jcomplete reactivated for ", default_name, ".")
      }
      return(invisible(NULL))
    }
  }

  # -- Now safe to evaluate data ---------------------------------------------
  if (!missing(data)) {
    data <- force(data)
  }

  # -- jcomplete(NULL) — clear -----------------------------------------------
  if (!missing(data) && is.null(data)) {
    if (!is.null(default_name)) {
      .jst_set_complete(default_name, NULL)
      message("jcomplete filter cleared for ", default_name, ".")
    } else {
      message("No default data frame set. Nothing to clear.")
    }
    return(invisible(NULL))
  }

  # -- jcomplete(, var1, var2, ...) — set and activate -----------------------

  # Resolve data frame
  .jst_data_name <- NULL
  if (missing(data)) {
    resolved <- .jst_resolve_data(envir = parent.frame())
    data <- resolved$data
    .jst_data_name <- resolved$name
  } else {
    .jst_data_name <- deparse(substitute(data))
  }

  variables      <- rlang::enquos(...)
  variable_names <- vapply(variables, rlang::quo_name, character(1))

  if (length(variable_names) == 0) {
    stop("Provide at least one variable name, e.g. jcomplete(, DV, IV1, IV2).",
         call. = FALSE)
  }

  .jst_check_vars(data, variable_names, .jst_data_name)

  # Compute summary
  n_total <- nrow(data)
  missing_info <- data.frame(
    Variable  = variable_names,
    N         = rep(n_total, length(variable_names)),
    Missing   = vapply(variable_names, function(v) sum(is.na(data[[v]])), integer(1)),
    stringsAsFactors = FALSE
  )
  missing_info$Pct <- sprintf("%.1f%%", missing_info$Missing / n_total * 100)

  n_complete <- sum(stats::complete.cases(data[, variable_names, drop = FALSE]))
  n_excluded <- n_total - n_complete

  # Store settings
  .jst_set_complete(.jst_data_name, list(
    vars   = variable_names,
    active = TRUE
  ))

  # Print summary
  .cat_red("Listwise Case Filter\n")
  cat("(Using default data frame:", .jst_data_name, ")\n\n")

  .jst_print_table(missing_info,
                   col.names = c("Variable", "N", "Missing", "% Missing"),
                   row.names = FALSE)

  cat("\n  Complete cases: ", n_complete, " of ", n_total,
      " (", sprintf("%.1f", n_complete / n_total * 100), "%)\n", sep = "")
  if (n_excluded > 0) {
    cat("  Listwise filter activated \u2014 ", n_excluded, " cases excluded.\n", sep = "")
  } else {
    cat("  Listwise filter activated \u2014 no cases excluded (no missing values).\n")
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
#'   Can be a numeric code, a quoted label name, or \code{"first"}
#'   (default) or \code{"last"}.
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
#' jdummy(, cyl)                         # Register, first category as reference
#' jdummy(, cyl, ref = "last")          # Last category as reference
#' jdummy(, cyl, ref = 6)              # Reference by numeric code
#' # For haven-labelled variables, use the label name:
#' # jdummy(, Employment, ref = "Part-Time")
#' jdummy(, cyl, show = TRUE)          # Show coding scheme
#' jdummy(, cyl, show = "all")         # Full scheme (for many categories)
#' jdummy()                             # Show all registrations
#' jdummy(, cyl, remove = TRUE)        # Remove registration
#' jdummy(NULL)                         # Clear all
#' }
#'
#' @export
jdummy <- function(data, var, ref = "first", show = FALSE, remove = FALSE) {

  default_name <- getOption(".jst_default_data", default = NULL)

  # -- jdummy() — no arguments: show all registrations ----------------------
  if (missing(data) && missing(var)) {
    if (is.null(default_name)) {
      message("No default data frame set. Use juse() first.")
      return(invisible(NULL))
    }
    ds <- .jst_get_dummy(default_name)
    if (is.null(ds) || length(ds) == 0) {
      message("No dummy variables registered for ", default_name, ".")
    } else {
      .cat_red("Dummy Variable Registrations\n")
      cat("(Using default data frame:", default_name, ")\n\n")
      for (reg in ds) {
        cat("  Variable: ", reg$var_name,
            " (", reg$var_type, ")\n", sep = "")
        cat("  Reference category: ", reg$ref_code, ": ", reg$ref_label, "\n", sep = "")
        cat("  Dummy variables: ", paste(reg$dummy_names, collapse = ", "), "\n", sep = "")
        cat("  Cases: ", reg$n_total,
            " (", reg$n_missing, " missing)\n", sep = "")

        # Show coding scheme if requested
        if (!identical(show, FALSE)) {
          n_cats <- length(reg$codes)
          show_all <- is.character(show) && tolower(show) == "all"
          n_show <- if (show_all) n_cats else min(n_cats, 5)

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
    }
    return(invisible(NULL))
  }

  # -- jdummy(NULL) — clear all registrations --------------------------------
  if (!missing(data) && is.null(data)) {
    if (!is.null(default_name)) {
      .jst_set_dummy(default_name, NULL)
      message("All dummy registrations cleared for ", default_name, ".")
    } else {
      message("No default data frame set. Nothing to clear.")
    }
    return(invisible(NULL))
  }

  # -- Resolve data frame ----------------------------------------------------
  .jst_data_name <- NULL
  if (missing(data)) {
    resolved <- .jst_resolve_data(envir = parent.frame())
    data <- resolved$data
    .jst_data_name <- resolved$name
  } else {
    .jst_data_name <- deparse(substitute(data))
  }

  var_name <- deparse(substitute(var))
  .jst_check_vars(data, var_name, .jst_data_name)

  # -- jdummy(, var, remove = TRUE) — remove one registration ----------------
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

  # -- Build registration ---------------------------------------------------
  col <- data[[var_name]]
  is_haven <- haven::is.labelled(col)

  var_type <- if (is_haven) "haven_labelled" else if (is.factor(col)) "factor" else "numeric"

  # Extract categories: codes and labels
  if (is_haven) {
    val_labels <- labelled::val_labels(col)
    codes  <- as.numeric(sort(unique(col[!is.na(col)])))
    labels_vec <- character(length(codes))
    for (i in seq_along(codes)) {
      match_idx <- which(val_labels == codes[i])
      if (length(match_idx) > 0) {
        labels_vec[i] <- names(val_labels)[match_idx[1]]
      } else {
        labels_vec[i] <- as.character(codes[i])
      }
    }
  } else if (is.factor(col)) {
    lvls <- levels(droplevels(col))
    codes <- seq_along(lvls)
    labels_vec <- lvls
  } else {
    codes <- sort(unique(col[!is.na(col)]))
    labels_vec <- as.character(codes)
  }

  n_cats    <- length(codes)
  n_total   <- length(col)
  n_missing <- sum(is.na(col))

  if (n_cats < 2) {
    stop(paste0("'", var_name, "' has fewer than 2 categories. ",
                "Cannot create dummy variables."), call. = FALSE)
  }

  # Determine reference category
  if (is.character(ref) && tolower(ref) == "first") {
    ref_idx <- 1
  } else if (is.character(ref) && tolower(ref) == "last") {
    ref_idx <- n_cats
  } else if (is.numeric(ref)) {
    ref_idx <- which(codes == ref)
    if (length(ref_idx) == 0) {
      stop(paste0("Reference code ", ref, " not found in '", var_name,
                  "'. Available codes: ", paste(codes, collapse = ", ")),
           call. = FALSE)
    }
  } else if (is.character(ref)) {
    ref_idx <- which(labels_vec == ref)
    if (length(ref_idx) == 0) {
      stop(paste0("Reference label '", ref, "' not found in '", var_name,
                  "'. Available labels: ", paste(labels_vec, collapse = ", ")),
           call. = FALSE)
    }
  } else {
    ref_idx <- 1
  }

  ref_code  <- codes[ref_idx]
  ref_label <- labels_vec[ref_idx]

  # Build dummy variable names
  non_ref_idx <- setdiff(seq_len(n_cats), ref_idx)
  if (is_haven && all(nchar(labels_vec) > 0) &&
      !all(labels_vec == as.character(codes))) {
    # Use haven labels for names
    dummy_names <- paste0(var_name, "_", gsub("[^A-Za-z0-9]+", "_", labels_vec[non_ref_idx]))
  } else {
    # Use numeric codes
    dummy_names <- paste0(var_name, "_", codes[non_ref_idx])
    if (!is_haven) {
      cat("(Note: ", var_name, " has no value labels \u2014 dummy variables will be named\n",
          " by numeric code. Use jrelabel() to add descriptive labels.)\n", sep = "")
    }
  }

  # Store registration
  reg <- list(
    var_name    = var_name,
    var_type    = var_type,
    codes       = codes,
    labels      = labels_vec,
    ref_idx     = ref_idx,
    ref_code    = ref_code,
    ref_label   = ref_label,
    dummy_names = dummy_names,
    non_ref_idx = non_ref_idx,
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

  # Print registration summary
  .cat_red("Dummy Variable Registration\n")
  cat("(Using default data frame:", .jst_data_name, ")\n\n")
  cat("  Variable: ", var_name, " (", var_type, ")\n", sep = "")
  cat("  Reference category: ", ref_code, ": ", ref_label, "\n", sep = "")
  cat("  Dummy variables: ", paste(dummy_names, collapse = ", "), "\n", sep = "")
  cat("  Cases: ", n_total, " (", n_missing, " missing)\n", sep = "")

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
#' @param level Character. One of \code{"minimal"} (default), \code{"standard"},
#'   or \code{"full"}. If omitted, prints the current settings.
#'   If \code{NULL}, resets to defaults (minimal with no toggle overrides).
#'   \describe{
#'     \item{minimal}{Current default behaviour. Core results only.}
#'     \item{standard}{Adds effect sizes and confidence intervals.}
#'     \item{full}{Adds assumption checks (Levene's test), post-hoc tests,
#'       diagnostics, and per-variable missing data detail.}
#'   }
#' @param effect.size Logical or NULL. Override the level's default for
#'   effect size display.
#' @param ci Logical or NULL. Override the level's default for confidence
#'   interval display.
#' @param levene Logical or NULL. Override the level's default for
#'   Levene's test display.
#' @param posthoc Logical or NULL. Override the level's default for
#'   post-hoc test display (jaov only).
#' @param missing Logical or NULL. Override the level's default for
#'   per-variable missing data detail.
#' @param diagnostics Logical or NULL. Override the level's default for
#'   regression diagnostic output (jlm only).
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
#' @export
joutput <- function(level, effect.size = NULL, ci = NULL, levene = NULL,
                    posthoc = NULL, missing = NULL, diagnostics = NULL) {

  valid_levels <- c("minimal", "standard", "full")

  # joutput(NULL) -- reset to defaults
  if (!missing(level) && is.null(level)) {
    options(.jst_output_level = NULL)
    options(.jst_output_toggles = NULL)
    .cat_red("Output Settings\n")
    cat("Reset to defaults (minimal, no toggle overrides).\n\n")
    return(invisible(NULL))
  }

  # Collect any explicit toggle overrides
  toggle_args <- list()
  if (!is.null(effect.size))  toggle_args$effect.size  <- effect.size
  if (!is.null(ci))           toggle_args$ci           <- ci
  if (!is.null(levene))       toggle_args$levene       <- levene
  if (!is.null(posthoc))      toggle_args$posthoc      <- posthoc
  if (!is.null(missing))      toggle_args$missing      <- missing
  if (!is.null(diagnostics))  toggle_args$diagnostics  <- diagnostics

  # joutput() with no level argument -- show status or apply toggles only
  if (missing(level)) {
    if (length(toggle_args) > 0) {
      # Apply toggle overrides to current settings
      current_toggles <- getOption(".jst_output_toggles", list())
      for (nm in names(toggle_args)) current_toggles[[nm]] <- toggle_args[[nm]]
      options(.jst_output_toggles = current_toggles)
    }
    # Show current status
    .jst_output_status()
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

  .jst_output_status()
  invisible(NULL)
}

#' Internal helper: print current joutput() status
#'
#' @keywords internal
.jst_output_status <- function() {
  level   <- getOption(".jst_output_level", "minimal")
  toggles <- getOption(".jst_output_toggles", list())

  .cat_red("Output Settings\n")
  cat("Level: ", level, "\n", sep = "")

  # Show effective value for each toggle
  toggle_names <- c("effect.size", "ci", "levene", "posthoc", "missing", "diagnostics")
  defaults     <- .jst_output_defaults[[level]]

  for (nm in toggle_names) {
    default_val  <- defaults[[nm]]
    effective    <- if (nm %in% names(toggles)) toggles[[nm]] else default_val
    override_str <- if (nm %in% names(toggles)) " (override)" else ""
    cat("  ", nm, ": ", if (effective) "ON" else "OFF",
        override_str, "\n", sep = "")
  }
  cat("\n")
}


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
#' Handles haven-labelled, factor, and plain numeric variables. If a factor
#' with text categories is passed, a warning is issued directing the user
#' to \code{jfreq()} instead. Also accepts a simple numeric vector. Supports
#' grouped descriptives via the \code{by} parameter.
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
#'   \code{Group == 1}) to filter cases for this call only. Applied after
#'   jcomplete and jfilter. Does not affect other function calls.
#' @param labels Logical. If \code{TRUE} (default), prints the variable type
#'   and label (or "None") for each variable before the table.
#'
#' @return Invisibly returns a list of class \code{"jst_desc"} containing:
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
#' jdesc(, mpg)
#' jdesc(, mpg, hp, wt)
#' jdesc(, mpg, by = am)
#'
#' # With a vector directly
#' jdesc(mtcars$mpg)
#'
#' @export
jdesc <- function(data, ..., by = NULL, subset = NULL, labels = TRUE) {

  # Capture original expression before any evaluation (needed for vector input)
  .data_expr <- if (!missing(data)) {
    paste(deparse(substitute(data)), collapse = "")
  } else NULL

  # Catch missing-comma error: jdesc(VarName) instead of jdesc(, VarName)
  if (!missing(data)) {
    mc <- match.call()
    data <- tryCatch(force(data), error = function(e) {
      .jst_missing_comma_error(deparse(mc$data), "jdesc", e)
    })
  }

  # Resolve default data frame if not specified
  .jst_default_used <- FALSE
  .jst_data_name    <- NULL
  if (missing(data)) {
    resolved <- .jst_resolve_data(envir = parent.frame())
    data <- resolved$data
    .jst_default_used <- TRUE
    .jst_data_name    <- resolved$name
  } else {
    .jst_data_name <- .data_expr
  }

  # Handle vector input
  if (is.atomic(data) && !is.data.frame(data)) {
    var_name <- .data_expr
    if (grepl("\\$", var_name)) {
      var_name <- sub("^.*\\$", "", var_name)
    }
    temp_df  <- data.frame(x = data)
    names(temp_df) <- var_name
    return(jdesc(temp_df, !!rlang::sym(var_name), labels = labels))
  }

  variables      <- rlang::enquos(...)
  variable_names <- vapply(variables, rlang::quo_name, character(1))
  by_quo         <- rlang::enquo(by)

  # Check all variables exist before any processing
  check_names <- variable_names
  if (!rlang::quo_is_null(by_quo)) {
    check_names <- c(check_names, rlang::quo_name(by_quo))
  }
  .jst_check_vars(data, check_names, .jst_data_name)

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
      original_codes  <- sort(unique(as.numeric(by_var[!is.na(by_var)])))
      data[[by_name]] <- haven::as_factor(by_var)
    } else if (!is.factor(data[[by_name]])) {
      data[[by_name]] <- factor(data[[by_name]])
    }

    group_levels <- levels(data[[by_name]])

    # Apply data pipeline (jcomplete, jfilter, subset) — once before per-variable loop
    subset_expr <- substitute(subset)
    pipeline <- .jst_apply_pipeline(data, .jst_data_name, .jst_default_used,
                                    subset_expr = subset_expr, envir = parent.frame())
    data     <- pipeline$data

    for (v in variable_names) {
      .cat_red(paste0("Descriptive Statistics: ", v, " by ", by_name, "\n"))
      if (.jst_default_used) cat("(Using default data frame:", .jst_data_name, ")\n")
      .jst_print_msgs(pipeline$msgs)

      if (labels) {
        cat(v, "\n", sep = "")
        cat("  Type: ", .format_var_type(original_dv_info[[v]]$class), "\n", sep = "")
        cat("  Variable label: ", original_dv_info[[v]]$label, "\n", sep = "")
        cat(by_name, "\n", sep = "")
        cat("  Type: ", .format_var_type(original_by_class), "\n", sep = "")
        cat("  Variable label: ", original_by_label, "\n", sep = "")
      }

      # Warn if DV is haven-labelled (categorical)
      if ("haven_labelled" %in% original_dv_info[[v]]$class) {
        warning(paste0("'", v, "' is a categorical variable. Descriptive statistics ",
                       "may not be meaningful. Use jfreq() for frequency tables."),
                call. = FALSE)
      }
      cat("\n")

      dv_data <- data[[v]]
      if (haven::is.labelled(dv_data)) {
        dv_data <- as.numeric(dv_data)
      } else if (is.factor(dv_data)) {
        dv_data <- suppressWarnings(as.numeric(as.character(dv_data)))
      } else {
        dv_data <- as.numeric(dv_data)
      }

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

        data.frame(
          Group = group_label,
          N     = n,
          Min   = if (n > 0) round(min(subset_data), 3) else NA,
          Max   = if (n > 0) round(max(subset_data), 3) else NA,
          Mean  = if (n > 0) round(m, 3) else NA,
          SD    = if (n > 0) round(s, 3) else NA,
          stringsAsFactors = FALSE
        )
      })
      group_table <- do.call(rbind, group_rows)

      .jst_print_table(group_table, row.names = FALSE)
      cat("\n")
    }
    cat("\n")

    # Build sample_info for grouped descriptives
    sample_info <- .jst_build_sample_info(
      pipeline_counts = pipeline$pipeline_counts,
      data            = pipeline$data,
      analysis_vars   = c(variable_names, by_name),
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
  if (.jst_default_used) cat("(Using default data frame:", .jst_data_name, ")\n")

  # Apply data pipeline (jcomplete, jfilter, subset)
  subset_expr <- substitute(subset)
  pipeline <- .jst_apply_pipeline(data, .jst_data_name, .jst_default_used,
                                  subset_expr = subset_expr, envir = parent.frame())
  data     <- pipeline$data
  .jst_print_msgs(pipeline$msgs)

  if (labels) {
    for (v in variable_names) {
      cat(v, "\n", sep = "")
      cat("  Type: ", .format_var_type(original_var_info[[v]]$class), "\n", sep = "")
      cat("  Variable label: ", original_var_info[[v]]$label, "\n", sep = "")
    }
  }

  # Warn if haven-labelled (categorical) variables are being described
  for (v in variable_names) {
    if ("haven_labelled" %in% original_var_info[[v]]$class) {
      warning(paste0("'", v, "' is a categorical variable. Descriptive statistics ",
                     "may not be meaningful. Use jfreq() for frequency tables."),
              call. = FALSE)
    }
  }

  # -- Compute descriptives on filtered data ---------------------------------
  descriptives_list <- lapply(variables, function(var) {
    var_name <- rlang::quo_name(var)
    var_data <- rlang::eval_tidy(var, data)

    if (haven::is.labelled(var_data)) {
      var_data <- as.numeric(var_data)
    }

    if (is.factor(var_data)) {
      numeric_check <- suppressWarnings(as.numeric(as.character(var_data)))
      if (all(is.na(numeric_check[!is.na(var_data)]))) {
        warning(paste0("'", var_name,
                       "' is a factor with text categories and cannot be summarised ",
                       "with descriptive statistics. Use jfreq() instead for ",
                       "categorical variables."), call. = FALSE)
        return(NULL)
      }
      var_data <- numeric_check
    }

    data.frame(
      Variable    = var_name,
      Total       = length(var_data),
      Non_missing = sum(!is.na(var_data)),
      Min         = round(min(var_data, na.rm = TRUE), 3),
      Max         = round(max(var_data, na.rm = TRUE), 3),
      Mean        = round(mean(var_data, na.rm = TRUE), 3),
      SD          = round(stats::sd(var_data, na.rm = TRUE), 3),
      stringsAsFactors = FALSE
    )
  })

  descriptives_list <- Filter(Negate(is.null), descriptives_list)
  descriptives      <- do.call(rbind, descriptives_list)

  listwise_cases <- sum(
    stats::complete.cases(data[, variable_names, drop = FALSE])
  )
  listwise_row <- data.frame(
    Variable    = "Listwise_N",
    Total       = NA,
    Non_missing = listwise_cases,
    Min         = NA,
    Max         = NA,
    Mean        = NA,
    SD          = NA,
    stringsAsFactors = FALSE
  )
  descriptives <- rbind(descriptives, listwise_row)

  cat("\n")
  .jst_print_table(descriptives)
  cat("\n")

  # Build sample_info
  sample_info <- .jst_build_sample_info(
    pipeline_counts = pipeline$pipeline_counts,
    data            = pipeline$data,
    analysis_vars   = variable_names,
    n_analysis      = listwise_cases
  )

  ret <- list(
    descriptives = descriptives,
    sample_info  = sample_info
  )
  class(ret) <- "jst_desc"
  invisible(ret)
}


# -- jfreq --------------------------------------------------------------------

#' SPSS-like frequency tables for categorical variables
#'
#' Prints an SPSS-style frequency table (Freq, Total \%, Valid \%, Cum. \%) for
#' each variable supplied. Designed for use with unquoted variable names, and
#' also accepts a plain vector.
#'
#' Output is structured consistently with \code{jdesc()}: a red title
#' ("Frequencies for \emph{varname}") is printed first, followed by the
#' variable type and variable label (or "None" if absent), then a single blank
#' line before the table. One complete block is printed per variable.
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
#'   \code{Group == 1}) to filter cases for this call only. Applied after
#'   jcomplete and jfilter. Does not affect other function calls.
#' @param labels Logical. If \code{TRUE} (default), prints the variable type
#'   and label (or "None") beneath the title.
#'
#' @return Invisibly returns a list of class \code{"jst_freq"} containing:
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
#' jfreq(, cyl)
#' jfreq(, cyl, gear)
#'
#' # With a vector directly
#' jfreq(mtcars$gear)
#'
#' @export
jfreq <- function(data, ..., subset = NULL, labels = TRUE) {

  # Capture original expression before any evaluation (needed for vector input)
  .data_expr <- if (!missing(data)) {
    paste(deparse(substitute(data)), collapse = "")
  } else NULL

  # Catch missing-comma error: jfreq(VarName) instead of jfreq(, VarName)
  if (!missing(data)) {
    mc <- match.call()
    data <- tryCatch(force(data), error = function(e) {
      .jst_missing_comma_error(deparse(mc$data), "jfreq", e)
    })
  }

  # Resolve default data frame if not specified
  .jst_default_used <- FALSE
  .jst_data_name    <- NULL
  if (missing(data)) {
    resolved <- .jst_resolve_data(envir = parent.frame())
    data <- resolved$data
    .jst_default_used <- TRUE
    .jst_data_name    <- resolved$name
  } else if (is.data.frame(data)) {
    .jst_data_name <- .data_expr
  }

  # Handle vector input
  if (is.atomic(data) && !is.data.frame(data)) {
    var_name <- .data_expr
    if (grepl("\\$", var_name)) {
      var_name <- sub("^.*\\$", "", var_name)
    }
    temp_df  <- data.frame(x = data)
    names(temp_df) <- var_name
    return(jfreq(temp_df, !!rlang::sym(var_name), labels = labels))
  }

  variables <- rlang::enquos(...)
  results   <- list()

  # Check all variables exist before any processing
  var_names_check <- vapply(variables, rlang::quo_name, character(1))
  .jst_check_vars(data, var_names_check, .jst_data_name)

  # Apply data pipeline (jcomplete, jfilter, subset) — once before per-variable loop
  subset_expr <- substitute(subset)
  pipeline <- .jst_apply_pipeline(data, .jst_data_name, .jst_default_used,
                                  subset_expr = subset_expr, envir = parent.frame())
  data     <- pipeline$data

  for (variable in variables) {
    variable_name <- rlang::quo_name(variable)

    # Capture class and label BEFORE any conversion
    temp_var      <- data[[variable_name]]
    var_class     <- class(temp_var)
    var_label_val <- .get_var_label_str(data[[variable_name]])

    # Haven-labelled: combine numeric codes with value labels
    if (haven::is.labelled(temp_var)) {
      label_text <- as.character(haven::as_factor(temp_var))
      codes      <- as.numeric(temp_var)
      temp_var   <- factor(
        ifelse(is.na(codes), NA, paste(codes, label_text, sep = ": "))
      )
    }

    # Convert plain numeric to factor for counting
    if (is.numeric(temp_var)) {
      temp_var <- factor(temp_var)
    }

    # Frequency table (base R)
    tbl         <- table(temp_var, useNA = "ifany")
    total_count <- length(temp_var)
    valid_count <- sum(!is.na(temp_var))

    freq_table <- data.frame(
      temp_var = factor(names(tbl), levels = names(tbl)),
      Freq     = as.integer(tbl),
      stringsAsFactors = FALSE
    )

    # Handle NA row — table() with useNA="ifany" uses NA as a name
    na_count <- sum(is.na(temp_var))
    if (na_count > 0) {
      na_row <- data.frame(temp_var = NA, Freq = na_count,
                           stringsAsFactors = FALSE)
      # Remove the NA row table() may have created with a literal "NA" name
      freq_table <- freq_table[!is.na(freq_table$temp_var) &
                                 freq_table$temp_var != "NA", , drop = FALSE]
      freq_table <- rbind(freq_table, na_row)
    }

    freq_table$`Total %` <- (freq_table$Freq / total_count) * 100
    freq_table$`Valid %` <- ifelse(
      is.na(freq_table$temp_var),
      NA_real_,
      (freq_table$Freq / valid_count) * 100
    )
    valid_pcts <- ifelse(is.na(freq_table$temp_var), 0,
                         (freq_table$Freq / valid_count) * 100)
    freq_table$`Cum. %` <- ifelse(
      is.na(freq_table$temp_var),
      NA_real_,
      cumsum(valid_pcts)
    )

    results[[variable_name]] <- freq_table

    # -- Print: title -> type -> label -> single blank line -> table ----------
    .cat_red(paste0("Frequencies for ", variable_name, "\n"))
    if (.jst_default_used) cat("(Using default data frame:", .jst_data_name, ")\n")
    .jst_print_msgs(pipeline$msgs)

    if (labels) {
      cat("Type of variable: ", .format_var_type(var_class), "\n", sep = "")
      cat("Variable label: ", var_label_val, "\n", sep = "")
    }
    cat("\n")

    # Build display data frame for the table printer
    display_df <- data.frame(
      Value   = ifelse(is.na(freq_table$temp_var), "NA",
                       as.character(freq_table$temp_var)),
      Freq    = freq_table$Freq,
      TotalPct = sprintf("%.2f", freq_table$`Total %`),
      ValidPct = ifelse(is.na(freq_table$`Valid %`), "",
                        sprintf("%.2f", freq_table$`Valid %`)),
      CumPct   = ifelse(is.na(freq_table$`Cum. %`), "",
                        sprintf("%.2f", freq_table$`Cum. %`)),
      stringsAsFactors = FALSE
    )

    .jst_print_table(display_df,
                     col.names = c("", "Freq", "Total %", "Valid %", "Cum. %"),
                     row.names = FALSE)
    cat("\n")
  }

  cat("\n")

  # Build sample_info
  sample_info <- .jst_build_sample_info(
    pipeline_counts = pipeline$pipeline_counts,
    data            = pipeline$data,
    analysis_vars   = var_names_check,
    n_analysis      = nrow(data)
  )

  ret <- list(
    frequencies = results,
    sample_info = sample_info
  )
  class(ret) <- "jst_freq"
  invisible(ret)
}


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
#'   \code{Group == 1}) to filter cases for this call only. Applied after
#'   jcomplete and jfilter. Does not affect other function calls.
#' @param labels Logical. If TRUE (default), prints variable labels
#'   when available.
#' @param full Logical. If TRUE, turns on effect.size, levene, and ci
#'   all at once. Does not override explicit FALSE values.
#'
#' @return Invisibly returns a list of class \code{"jst_ttest"} containing:
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
#' @export
#' @importFrom stats t.test sd qt
jt <- function(formula, data, paired = FALSE, welch = FALSE,
               effect.size = NULL, levene = NULL, ci = NULL,
               subset = NULL, labels = TRUE, full = FALSE) {

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
  show_missing <- .jst_resolve_toggle("missing",    NULL)

  # Red title - determined before any output
  if (paired) {
    .cat_red("Paired Samples T-Test\n")
  } else if (welch) {
    .cat_red("Welch's Independent Samples T-Test\n")
  } else {
    .cat_red("Independent Samples T-Test\n")
  }
  if (.jst_default_used) cat("(Using default data frame:", .jst_data_name, ")\n")

  # Apply data pipeline (jcomplete, jfilter, subset)
  subset_expr <- substitute(subset)
  pipeline <- .jst_apply_pipeline(data, .jst_data_name, .jst_default_used,
                                  subset_expr = subset_expr, envir = parent.frame())
  data     <- pipeline$data
  .jst_print_msgs(pipeline$msgs)

  terms      <- all.vars(formula)
  dv_name    <- terms[1]
  group_name <- terms[2]

  .jst_check_vars(data, terms, .jst_data_name)

  # Report cases excluded due to missing values
  n_before_na <- nrow(data)
  complete_on <- data[stats::complete.cases(data[, terms, drop = FALSE]), , drop = FALSE]
  n_excluded_na <- n_before_na - nrow(complete_on)
  if (n_excluded_na > 0) {
    cat("(", n_excluded_na, " cases excluded due to missing values)\n", sep = "")
    if (show_missing) {
      mbv <- vapply(terms, function(v) sum(is.na(data[[v]])), integer(1))
      .jst_print_missing_detail(mbv)
    }
  }

  group_var   <- data[[group_name]]
  is_labelled <- haven::is.labelled(group_var)
  if (is_labelled) {
    original_codes <- sort(unique(as.numeric(group_var[!is.na(group_var)])))
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
                                                       paste0("jfilter (", fs$expr_str, ")"))
    }
    if (length(active_steps) > 0) {
      stop(paste0("'", group_name, "' has ", n_levels,
                  " category(ies) after applying ", paste(active_steps, collapse = " and "),
                  ". A t-test requires exactly 2. ",
                  "Check whether your filter or complete-case settings ",
                  "are excluding one of the groups."), call. = FALSE)
    } else {
      stop(paste0("'", group_name, "' has ", n_levels,
                  " categories. A t-test requires exactly 2. ",
                  "Use jaov() for more than 2 categories."), call. = FALSE)
    }
  }

  if (haven::is.labelled(data[[dv_name]])) {
    data[[dv_name]] <- as.numeric(data[[dv_name]])
  }

  levels      <- levels(data[[group_name]])
  group1_data <- data[[dv_name]][data[[group_name]] == levels[1]]
  group2_data <- data[[dv_name]][data[[group_name]] == levels[2]]
  group1_data <- group1_data[!is.na(group1_data)]
  group2_data <- group2_data[!is.na(group2_data)]

  if (paired && length(group1_data) != length(group2_data)) {
    stop("Paired t-test requires equal sample sizes in both groups.", call. = FALSE)
  }

  if (labels) {
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

  # Build sample_info
  n_analysis <- n1 + n2
  sample_info <- .jst_build_sample_info(
    pipeline_counts = pipeline$pipeline_counts,
    data            = pipeline$data,
    analysis_vars   = terms,
    n_analysis      = n_analysis
  )

  # Build analysis-level data frame for jplot()
  mf <- data[stats::complete.cases(data[, terms, drop = FALSE]),
             terms, drop = FALSE]

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
#'   \code{Group == 1}) to filter cases for this call only. Applied after
#'   jcomplete and jfilter. Does not affect other function calls.
#' @param labels Logical. If TRUE (default), prints variable labels
#'   when available.
#' @param full Logical. If TRUE, turns on posthoc, effect.size, levene,
#'   and ci all at once. Does not override explicit FALSE values.
#'
#' @return Invisibly returns a list of class \code{"jst_anova"} containing:
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
#' @export
#' @importFrom stats aov oneway.test TukeyHSD qt
jaov <- function(formula, data, welch = FALSE, posthoc = NULL,
                 effect.size = NULL, levene = NULL, ci = NULL,
                 subset = NULL, labels = TRUE, full = FALSE) {

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
  show_missing <- .jst_resolve_toggle("missing",     NULL)

  # Red title
  if (welch) {
    .cat_red("Welch's One-Way ANOVA\n")
  } else {
    .cat_red("One-Way ANOVA\n")
  }
  if (.jst_default_used) cat("(Using default data frame:", .jst_data_name, ")\n")

  # Apply data pipeline (jcomplete, jfilter, subset)
  subset_expr <- substitute(subset)
  pipeline <- .jst_apply_pipeline(data, .jst_data_name, .jst_default_used,
                                  subset_expr = subset_expr, envir = parent.frame())
  data     <- pipeline$data
  .jst_print_msgs(pipeline$msgs)

  terms      <- all.vars(formula)
  dv_name    <- terms[1]
  group_name <- terms[2]

  .jst_check_vars(data, terms, .jst_data_name)

  # Report cases excluded due to missing values
  n_before_na <- nrow(data)
  complete_on <- data[stats::complete.cases(data[, terms, drop = FALSE]), , drop = FALSE]
  n_excluded_na <- n_before_na - nrow(complete_on)
  if (n_excluded_na > 0) {
    cat("(", n_excluded_na, " cases excluded due to missing values)\n", sep = "")
    if (show_missing) {
      mbv <- vapply(terms, function(v) sum(is.na(data[[v]])), integer(1))
      .jst_print_missing_detail(mbv)
    }
  }

  group_var   <- data[[group_name]]
  is_labelled <- haven::is.labelled(group_var)
  if (is_labelled) {
    original_codes <- sort(unique(as.numeric(group_var[!is.na(group_var)])))
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
                                                       paste0("jfilter (", fs$expr_str, ")"))
    }
    if (length(active_steps) > 0) {
      stop(paste0("'", group_name, "' has ", n_levels,
                  " category(ies) after applying ", paste(active_steps, collapse = " and "),
                  ". An ANOVA requires at least 2. ",
                  "Check whether your filter or complete-case settings ",
                  "are excluding one or more groups."), call. = FALSE)
    } else {
      stop(paste0("'", group_name, "' has ", n_levels,
                  " category(ies). An ANOVA requires at least 2 groups."),
           call. = FALSE)
    }
  }

  if (haven::is.labelled(data[[dv_name]])) {
    data[[dv_name]] <- as.numeric(data[[dv_name]])
  }

  if (labels) {
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

  # Build sample_info
  n_analysis <- nrow(complete_on)
  sample_info <- .jst_build_sample_info(
    pipeline_counts = pipeline$pipeline_counts,
    data            = pipeline$data,
    analysis_vars   = terms,
    n_analysis      = n_analysis
  )

  # Build analysis-level data frame for jplot()
  mf <- data[stats::complete.cases(data[, terms, drop = FALSE]),
             terms, drop = FALSE]

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


# -- jcorr --------------------------------------------------------------------

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
#'   \code{Group == 1}) to filter cases for this call only. Applied after
#'   jcomplete and jfilter. Does not affect other function calls.
#' @param labels Logical. If TRUE (default), prints variable labels
#'   when available.
#'
#' @return Invisibly returns a list of class \code{"jst_corr"} containing:
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
#' jcorr(, mpg, hp, wt)
#'
#' @importFrom stats cor.test complete.cases
#' @export
jcorr <- function(data, ..., method = "pearson", subset = NULL, labels = TRUE) {

  # Catch missing-comma error: jcorr(VarName, ...) instead of jcorr(, VarName, ...)
  if (!missing(data)) {
    mc <- match.call()
    data <- tryCatch(force(data), error = function(e) {
      .jst_missing_comma_error(deparse(mc$data), "jcorr", e)
    })
  }

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

  variables      <- rlang::enquos(...)
  variable_names <- vapply(variables, rlang::quo_name, character(1))

  .jst_check_vars(data, variable_names, .jst_data_name)

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
  if (.jst_default_used) cat("(Using default data frame:", .jst_data_name, ")\n")

  # Apply data pipeline (jcomplete, jfilter, subset)
  subset_expr <- substitute(subset)
  pipeline <- .jst_apply_pipeline(data, .jst_data_name, .jst_default_used,
                                  subset_expr = subset_expr, envir = parent.frame())
  data     <- pipeline$data
  .jst_print_msgs(pipeline$msgs)

  cor_data <- data[, variable_names, drop = FALSE]

  for (v in variable_names) {
    if (haven::is.labelled(cor_data[[v]])) {
      warning(paste0("'", v, "' is a haven-labelled variable and may be categorical. ",
                     "Pearson correlations assume continuous/interval data. ",
                     "Verify this variable is appropriate for correlation."), call. = FALSE)
      cor_data[[v]] <- as.numeric(cor_data[[v]])
    } else if (is.factor(cor_data[[v]])) {
      numeric_check <- suppressWarnings(as.numeric(as.character(cor_data[[v]])))
      if (all(is.na(numeric_check[!is.na(cor_data[[v]])]))) {
        stop(paste0("'", v,
                    "' is a factor with text categories and cannot be used ",
                    "in a correlation. Use a numeric variable instead."), call. = FALSE)
      }
      warning(paste0("'", v, "' is a factor with numeric levels and may be categorical. ",
                     "Pearson correlations assume continuous/interval data. ",
                     "Verify this variable is appropriate for correlation."), call. = FALSE)
      cor_data[[v]] <- numeric_check
    } else if (is.character(cor_data[[v]])) {
      stop(paste0("'", v, "' is a character variable and cannot be used ",
                  "in a correlation. Use a numeric variable instead."), call. = FALSE)
    } else if (is.numeric(cor_data[[v]])) {
      n_unique <- length(unique(cor_data[[v]][!is.na(cor_data[[v]])]))
      if (n_unique <= 5) {
        warning(paste0("'", v, "' has only ", n_unique, " unique values and may be categorical. ",
                       "Pearson correlations assume continuous/interval data. ",
                       "Verify this variable is appropriate for correlation."), call. = FALSE)
      }
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

  if (labels) {
    .print_var_labels(data, variable_names)
  }

  .jst_print_table(display_df,
                   caption = paste0("Bivariate Correlations (", method_label, ")"))

  if (has_ties) {
    cat("\nNote: Spearman p-values are approximate due to tied values in the data.\n")
  }

  cat("\n")

  # Build sample_info (jcorr uses pairwise deletion, not listwise)
  sample_info <- .jst_build_sample_info(
    pipeline_counts = pipeline$pipeline_counts,
    data            = pipeline$data,
    analysis_vars   = variable_names,
    n_analysis      = nrow(data)
  )

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


# -- jlm diagnostic helpers ----------------------------------------------------

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


# -- jlm ----------------------------------------------------------------------

#' SPSS-like linear regression output with standardised coefficients
#'
#' Fits a linear model using \code{stats::lm()} and prints SPSS-style output,
#' including unstandardised coefficients, standard errors, t values, p values,
#' and standardised coefficients ("Std B"). Standardised coefficients are left
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
#'   \code{Group == 1}) to filter cases for this call only. Applied after
#'   jcomplete and jfilter. Does not affect other function calls.
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
#'   diagnostics to show: \code{"vif"}, \code{"residuals"}, \code{"qq"},
#'   \code{"scale"}, \code{"cooks"}, \code{"leverage"}. If NULL (default),
#'   defers to \code{joutput()} session setting.
#' @param full Logical. If TRUE, turns on diagnostics. Does not override
#'   explicit FALSE values.
#' @param ... Reserved for argument-name checking. Passing \code{which},
#'   \code{plots}, or \code{show} will produce a helpful error suggesting
#'   \code{diagnostics} instead.
#'
#' @return Invisibly returns a list of class \code{"jst_lm"} containing:
#'   \describe{
#'     \item{model}{The fitted \code{lm} object.}
#'     \item{model_type}{Character string \code{"linear"}.}
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
#' # With explicit data frame
#' jlm(mpg ~ hp + wt, data = mtcars)
#'
#' # Using juse() default
#' juse(mtcars)
#' jlm(mpg ~ hp + wt)
#'
#' \dontrun{
#' # Force a variable with value labels to be treated as numeric
#' jlm(Outcome ~ Age + Employment, numeric = "Age")
#'
#' # Force a plain numeric variable to be treated as categorical
#' jlm(Outcome ~ Program + ReadingScore, categorical = "Program")
#'
#' # Multiple overrides
#' jlm(Outcome ~ Age + Education + Program,
#'     numeric = c("Age", "Education"), categorical = "Program")
#' }
#'
#' @export
jlm <- function(formula, data, subset = NULL, labels = TRUE,
                numeric = NULL, categorical = NULL,
                diagnostics = NULL, full = FALSE, ...) {

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
  if (.jst_default_used) cat("(Using default data frame:", .jst_data_name, ")\n")

  # Apply data pipeline (jcomplete, jfilter, subset)
  subset_expr <- substitute(subset)
  pipeline <- .jst_apply_pipeline(data, .jst_data_name, .jst_default_used,
                                  subset_expr = subset_expr, envir = parent.frame())
  data     <- pipeline$data
  .jst_print_msgs(pipeline$msgs)

  # Resolve missing detail toggle
  show_missing <- .jst_resolve_toggle("missing", NULL)

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

  model_vars <- all.vars(formula)

  .jst_check_vars(data, model_vars, .jst_data_name)

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
  dv_name <- all.vars(formula)[1]

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

  if (!is.null(numeric)) {
    bad <- setdiff(numeric, iv_names)
    if (length(bad) > 0) {
      warning(
        "numeric argument: ",
        paste0("'", bad, "'", collapse = ", "),
        " not found among independent variables (ignoring).",
        call. = FALSE
      )
      numeric <- intersect(numeric, iv_names)
    }
  }

  if (!is.null(categorical)) {
    bad <- setdiff(categorical, iv_names)
    if (length(bad) > 0) {
      warning(
        "categorical argument: ",
        paste0("'", bad, "'", collapse = ", "),
        " not found among independent variables (ignoring).",
        call. = FALSE
      )
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
      if (haven::is.labelled(data[[v]])) data[[v]] <- as.numeric(data[[v]])
      next
    }

    # --- Override: numeric = "Var" forces numeric ---
    if (v %in% numeric) {
      if (haven::is.labelled(data[[v]])) {
        data[[v]] <- as.numeric(data[[v]])
      }
      # Plain numeric stays as-is
      next
    }

    # --- Override: categorical = "Var" forces categorical ---
    if (v %in% categorical) {
      if (haven::is.labelled(data[[v]])) {
        data[[v]] <- haven::as_factor(data[[v]])
      } else {
        # Plain numeric or character — convert to factor using sorted unique values
        unique_vals <- sort(unique(data[[v]][!is.na(data[[v]])]))
        data[[v]] <- factor(data[[v]], levels = unique_vals)
      }
      ref_level <- levels(data[[v]])[1]
      auto_ref_cats <- c(auto_ref_cats, paste0(v, " = ", ref_level))
      next
    }

    # --- Auto-detection ---
    if (haven::is.labelled(data[[v]])) {
      val_labs <- labelled::val_labels(data[[v]])
      if (length(val_labs) > 0) {
        # Has value labels — treat as categorical
        data[[v]] <- haven::as_factor(data[[v]])
        ref_level <- levels(data[[v]])[1]
        auto_ref_cats <- c(auto_ref_cats, paste0(v, " = ", ref_level))
      } else {
        # No value labels — treat as continuous
        data[[v]] <- as.numeric(data[[v]])
      }
    }
    # Plain numeric without override or labels — stays numeric (untouched)
  }

  if (labels) {
    .print_var_labels(data, all.vars(formula))
  }

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

  mf            <- stats::model.frame(formula, data = data, na.action = stats::na.omit)
  n_excluded_na <- nrow(data) - nrow(mf)
  if (n_excluded_na > 0) {
    cat("(", n_excluded_na, " cases excluded due to missing values)\n", sep = "")
    if (show_missing) {
      mbv <- vapply(model_vars, function(v) {
        if (v %in% names(data)) sum(is.na(data[[v]])) else 0L
      }, integer(1))
      .jst_print_missing_detail(mbv)
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

  # Blank Std B for registered dummy variables
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
    `Std B` = ifelse(is.na(std_b), "", sprintf("%.3f", as.numeric(std_b))),
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

  cat("\nCoefficients:\n")
  .jst_print_table(out_coefs,
                   col.names = c("B", "SE", "t", "Std B", "p"),
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
  cat("\nNumber of observations: ", n_obs, "\n", sep = "")

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

  # Build sample_info
  sample_info <- .jst_build_sample_info(
    pipeline_counts = pipeline$pipeline_counts,
    data            = pipeline$data,
    analysis_vars   = all.vars(formula),
    n_analysis      = n_obs
  )

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
#'   \code{Group == 1}) to filter cases for this call only.
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
#'   VIF table. If a character vector, \code{"vif"} is currently the only
#'   supported option. If NULL (default), defers to \code{joutput()}.
#' @param full Logical. If TRUE, turns on ci, classification, and
#'   diagnostics. Does not override explicit FALSE values.
#' @param ... Reserved for argument-name checking. Passing \code{which},
#'   \code{plots}, or \code{show} will produce a helpful error suggesting
#'   \code{diagnostics} instead.
#'
#' @return Invisibly returns a list of class \code{"jst_logistic"} containing:
#'   \describe{
#'     \item{model}{The fitted \code{glm} object.}
#'     \item{model_type}{Character string \code{"logistic"}.}
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
#' @export
#' @importFrom stats glm binomial pchisq logLik as.formula
jlogistic <- function(formula, data, subset = NULL, labels = TRUE,
                      numeric = NULL, categorical = NULL,
                      ci = NULL, classification = FALSE,
                      diagnostics = NULL, full = FALSE, ...) {

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
  show_missing <- .jst_resolve_toggle("missing", NULL)

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
  if (.jst_default_used) cat("(Using default data frame:", .jst_data_name, ")\n")

  # Apply data pipeline (jcomplete, jfilter, subset)
  subset_expr <- substitute(subset)
  pipeline <- .jst_apply_pipeline(data, .jst_data_name, .jst_default_used,
                                  subset_expr = subset_expr, envir = parent.frame())
  data     <- pipeline$data
  .jst_print_msgs(pipeline$msgs)

  model_vars <- all.vars(formula)
  dv_name    <- model_vars[1]

  .jst_check_vars(data, model_vars, .jst_data_name)

  # -- Expand registered dummy variables ------------------------------------
  expanded         <- .jst_expand_dummies(data, formula, .jst_data_name)
  data             <- expanded$data
  formula          <- expanded$formula
  ref_cats         <- expanded$ref_cats
  dummy_coef_names <- expanded$dummy_coef_names
  model_vars       <- all.vars(formula)

  # -- Variable type conversion (same logic as jlm) --------------------------
  dv_name  <- all.vars(formula)[1]
  iv_names <- setdiff(model_vars, c(dv_name, dummy_coef_names))

  auto_detected  <- character(0)
  auto_ref_cats  <- character(0)
  all_ref_cats   <- ref_cats

  for (v in iv_names) {
    if (v %in% names(data) && haven::is.labelled(data[[v]])) {
      val_labels <- labelled::val_labels(data[[v]])

      if (!is.null(numeric) && v %in% numeric) {
        data[[v]] <- as.numeric(data[[v]])
      } else if (!is.null(categorical) && v %in% categorical) {
        data[[v]] <- haven::as_factor(data[[v]])
        ref_val   <- levels(data[[v]])[1]
        auto_ref_cats <- c(auto_ref_cats,
                           paste0(v, " = ", ref_val, " (first category)"))
      } else if (length(val_labels) > 0) {
        data[[v]] <- haven::as_factor(data[[v]])
        auto_detected <- c(auto_detected, v)
        ref_val       <- levels(data[[v]])[1]
        auto_ref_cats <- c(auto_ref_cats,
                           paste0(v, " = ", ref_val, " (first category)"))
      } else {
        data[[v]] <- as.numeric(data[[v]])
      }
    } else if (!is.null(categorical) && v %in% categorical) {
      if (!is.factor(data[[v]])) {
        data[[v]] <- factor(data[[v]])
        ref_val   <- levels(data[[v]])[1]
        auto_ref_cats <- c(auto_ref_cats,
                           paste0(v, " = ", ref_val, " (first category)"))
      }
    }
  }

  all_ref_cats <- c(ref_cats, auto_ref_cats)

  if (haven::is.labelled(data[[dv_name]])) {
    data[[dv_name]] <- as.numeric(data[[dv_name]])
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

  if (labels) {
    .print_var_labels(data, all.vars(formula))
  }

  # -- Fit model -------------------------------------------------------------
  mf            <- stats::model.frame(formula, data = data,
                                      na.action = stats::na.omit)
  n_excluded_na <- nrow(data) - nrow(mf)
  if (n_excluded_na > 0) {
    cat("(", n_excluded_na, " cases excluded due to missing values)\n", sep = "")
    if (show_missing) {
      mbv <- vapply(model_vars, function(v) {
        if (v %in% names(data)) sum(is.na(data[[v]])) else 0L
      }, integer(1))
      .jst_print_missing_detail(mbv)
    }
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
  colnames(coefs) <- c("B", "SE", "z", "P")

  # Wald chi-square = z^2
  wald <- coefs$z^2

  p_num <- suppressWarnings(as.numeric(coefs$P))
  p_fmt <- ifelse(!is.na(p_num) & p_num < 0.001, "<.001",
                  ifelse(is.na(p_num), "<.001", sprintf("%.3f", p_num)))

  exp_b <- exp(coefs$B)

  fmt3 <- function(x) sprintf("%.3f", as.numeric(x))

  # Clean up factor coefficient names for readability
  rownames(coefs) <- .jst_clean_coef_names(rownames(coefs), data,
                                            all.vars(formula)[-1])

  out_coefs <- data.frame(
    B      = fmt3(coefs$B),
    SE     = fmt3(coefs$SE),
    Wald   = fmt3(wald),
    df     = rep("1", nrow(coefs)),
    p      = p_fmt,
    Exp_B  = fmt3(exp_b),
    stringsAsFactors = FALSE,
    row.names = rownames(coefs)
  )

  col_names <- c("B", "SE", "Wald", "df", "p", "Exp(B)")

  if (ci) {
    ci_vals <- suppressMessages(stats::confint(model))
    exp_ci_lower <- exp(ci_vals[, 1])
    exp_ci_upper <- exp(ci_vals[, 2])
    out_coefs$CI_Lower <- fmt3(exp_ci_lower)
    out_coefs$CI_Upper <- fmt3(exp_ci_upper)
    col_names <- c(col_names, "95% CI Lower", "95% CI Upper")
  }

  cat("Coefficients:\n")
  .jst_print_table(out_coefs, col.names = col_names, row.names = TRUE)

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

  # Build sample_info
  sample_info <- .jst_build_sample_info(
    pipeline_counts = pipeline$pipeline_counts,
    data            = pipeline$data,
    analysis_vars   = all.vars(formula),
    n_analysis      = n_obs
  )

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

#' Cross-tabulation with optional chi-square test of independence
#'
#' Produces an SPSS-style cross-tabulation of two categorical variables
#' with observed frequencies, expected frequencies, row percentages,
#' and column percentages. Optionally includes a chi-square test of
#' independence. Handles haven-labelled, numeric, factor, and character
#' variables. For haven-labelled variables, numeric codes are displayed
#' alongside labels.
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
#'   \code{Group == 1}) to filter cases for this call only. Applied after
#'   jcomplete and jfilter. Does not affect other function calls.
#' @param labels Logical. If TRUE (default), prints variable labels
#'   when available.
#'
#' @return Invisibly returns a list of class \code{"jst_chisq"} containing:
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
#' @importFrom stats chisq.test
#' @export
jcrosstab <- function(formula, data, chisq = FALSE, expected = FALSE,
                      row.pct = TRUE, col.pct = FALSE, subset = NULL,
                      labels = TRUE) {

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

  # Red title
  .cat_red("Cross-Tabulation\n")
  if (.jst_default_used) cat("(Using default data frame:", .jst_data_name, ")\n")

  # Apply data pipeline (jcomplete, jfilter, subset)
  subset_expr <- substitute(subset)
  pipeline <- .jst_apply_pipeline(data, .jst_data_name, .jst_default_used,
                                  subset_expr = subset_expr, envir = parent.frame())
  data     <- pipeline$data
  .jst_print_msgs(pipeline$msgs)

  # Resolve missing detail toggle
  show_missing <- .jst_resolve_toggle("missing", NULL)

  # Report cases excluded due to missing values
  n_before_na <- nrow(data)
  complete_on <- data[stats::complete.cases(data[, c(row_name, col_name), drop = FALSE]), , drop = FALSE]
  n_excluded_na <- n_before_na - nrow(complete_on)
  if (n_excluded_na > 0) {
    cat("(", n_excluded_na, " cases excluded due to missing values)\n", sep = "")
    if (show_missing) {
      mbv <- vapply(c(row_name, col_name), function(v) sum(is.na(data[[v]])), integer(1))
      .jst_print_missing_detail(mbv)
    }
  }

  row_var <- data[[row_name]]
  col_var <- data[[col_name]]

  row_labelled <- haven::is.labelled(row_var)
  col_labelled <- haven::is.labelled(col_var)

  if (row_labelled) {
    row_codes <- sort(unique(as.numeric(row_var[!is.na(row_var)])))
    row_var   <- haven::as_factor(row_var)
  } else if (!is.factor(row_var)) {
    row_var <- factor(row_var)
  }

  if (col_labelled) {
    col_codes <- sort(unique(as.numeric(col_var[!is.na(col_var)])))
    col_var   <- haven::as_factor(col_var)
  } else if (!is.factor(col_var)) {
    col_var <- factor(col_var)
  }

  if (labels) {
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
                                                         paste0("jfilter (", fs$expr_str, ")"))
      }
      context <- if (length(active_steps) > 0) {
        paste0(" after applying ", paste(active_steps, collapse = " and "))
      } else ""
      stop(paste0("'", check_info$name, "' has ", length(check_info$lvls),
                  " category(ies)", context,
                  ". A chi-square test requires at least 2 categories ",
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
                   caption = paste("Cross-tabulation:", row_name, "by", col_name),
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
                     caption = "Chi-Square Test of Independence",
                     col.names = c("Chi-Square", "df", "p", "N"),
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

  # Build sample_info
  sample_info <- .jst_build_sample_info(
    pipeline_counts = pipeline$pipeline_counts,
    data            = pipeline$data,
    analysis_vars   = c(row_name, col_name),
    n_analysis      = grand_total
  )

  # Build analysis-level data frame for jplot()
  mf <- data[stats::complete.cases(data[, c(row_name, col_name), drop = FALSE]),
             c(row_name, col_name), drop = FALSE]

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
  class(ret) <- "jst_chisq"
  invisible(ret)
}


# -- jscreen ------------------------------------------------------------------

#' Data screening overview
#'
#' Provides a quick overview of a data frame including the number of
#' cases, variable types, missing data counts and percentages, and
#' potential outliers for numeric variables. Handles haven-labelled
#' variables by reporting their labelled status.
#'
#' When variable names are supplied, only those variables are screened.
#' When omitted, all variables in the data frame are screened. If a
#' \code{subset} expression references variables not already in the
#' screening list, they are included automatically.
#'
#' A red "Data Screening" title is printed first, followed by a dataset
#' summary, variable labels (if present), and the screening table.
#'
#' @param data A data frame.
#' @param ... Optional unquoted variable names to screen. If omitted,
#'   all variables in the data frame are screened.
#' @param outlier.sd Numeric. Number of standard deviations from the mean
#'   to flag as potential outliers. Default is 3.
#' @param subset An optional unquoted logical expression (e.g.
#'   \code{Group == 1}) to filter cases for this call only. Applied after
#'   jcomplete and jfilter. Does not affect other function calls.
#' @param labels Logical. If TRUE (default), prints variable labels
#'   when available.
#'
#' @return Invisibly returns a data frame containing the screening results.
#'
#' @examples
#' # With explicit data frame
#' jscreen(mtcars)
#' jscreen(mtcars, outlier.sd = 2.5)
#'
#' # Using juse() default
#' juse(mtcars)
#' jscreen()
#' jscreen(, mpg, hp, wt)
#' jscreen(, mpg, hp, wt, subset = am == 1)
#'
#' @export
jscreen <- function(data, ..., outlier.sd = 3, subset = NULL, labels = TRUE) {

  # Catch missing-comma error
  if (!missing(data)) {
    mc <- match.call()
    data <- tryCatch(force(data), error = function(e) {
      .jst_missing_comma_error(deparse(mc$data), "jscreen", e)
    })
  }

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

  # Capture subset expression before evaluation
  subset_expr <- substitute(subset)

  # Determine which variables to screen
  variables <- rlang::enquos(...)
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
  if (.jst_default_used) cat("(Using default data frame:", .jst_data_name, ")\n")

  # Apply data pipeline (jcomplete, jfilter, subset)
  pipeline <- .jst_apply_pipeline(data, .jst_data_name, .jst_default_used,
                                  subset_expr = subset_expr, envir = parent.frame())
  data     <- pipeline$data
  .jst_print_msgs(pipeline$msgs)

  n_cases   <- nrow(data)
  n_vars    <- ncol(data)
  var_names <- names(data)

  cat("  Cases:", n_cases, "\n")
  cat("  Variables:", n_vars, "\n")
  cat("  Complete cases (no missing on any variable):",
      sum(stats::complete.cases(data)), "\n")

  screen_rows <- lapply(var_names, function(v) {
    col <- data[[v]]

    var_type <- if (haven::is.labelled(col)) {
      "haven_labelled"
    } else if (is.factor(col)) {
      "factor"
    } else if (is.numeric(col)) {
      "numeric"
    } else if (is.character(col)) {
      "character"
    } else {
      paste(class(col), collapse = ", ")
    }

    n_missing   <- sum(is.na(col))
    pct_missing <- round(n_missing / n_cases * 100, 1)
    n_unique    <- length(unique(col[!is.na(col)]))

    n_outliers <- NA
    if (is.numeric(col) || haven::is.labelled(col)) {
      num_col <- as.numeric(col)
      m <- mean(num_col, na.rm = TRUE)
      s <- stats::sd(num_col, na.rm = TRUE)
      n_outliers <- if (!is.na(s) && s > 0) {
        sum(abs(num_col - m) > outlier.sd * s, na.rm = TRUE)
      } else {
        0
      }
    }

    data.frame(
      Variable    = v,
      Type        = var_type,
      Unique      = n_unique,
      Missing     = n_missing,
      Pct_Missing = pct_missing,
      Outliers    = n_outliers,
      stringsAsFactors = FALSE
    )
  })

  screen_table <- do.call(rbind, screen_rows)

  if (labels) {
    cat("\n")
    .print_var_labels(data, var_names)
  } else {
    cat("\n")
  }

  .jst_print_table(screen_table,
                   caption = paste0("Data Screening (outliers defined as > ",
                                    outlier.sd, " SD from mean)"),
                   col.names = c("Variable", "Type", "Unique Values",
                                 "Missing", "% Missing", "Outliers"),
                   row.names = FALSE)

  missing_vars <- screen_table[screen_table$Missing > 0, ]
  outlier_vars <- screen_table[!is.na(screen_table$Outliers) &
                                 screen_table$Outliers > 0, ]

  if (nrow(missing_vars) > 0) {
    cat("\nVariables with missing data:\n")
    for (i in seq_len(nrow(missing_vars))) {
      cat("  ", missing_vars$Variable[i], ": ",
          missing_vars$Missing[i], " missing (",
          missing_vars$Pct_Missing[i], "%)\n", sep = "")
    }
  } else {
    cat("\nNo missing data detected.\n")
  }

  if (nrow(outlier_vars) > 0) {
    cat("\nVariables with potential outliers (> ", outlier.sd, " SD):\n", sep = "")
    for (i in seq_len(nrow(outlier_vars))) {
      cat("  ", outlier_vars$Variable[i], ": ",
          outlier_vars$Outliers[i], " cases\n", sep = "")
    }
  } else {
    cat("\nNo potential outliers detected.\n")
  }

  cat("\n")
  cat("\n")
  invisible(screen_table)
}


# -- jalpha -------------------------------------------------------------------

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
#'   \code{Group == 1}) to filter cases for this call only. Applied after
#'   jcomplete and jfilter. Does not affect other function calls.
#' @param labels Logical. If TRUE (default), prints variable labels
#'   when available.
#'
#' @return Invisibly returns a list of class \code{"jst_alpha"} containing:
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
#' jalpha(, rating, complaints, privileges, learning, raises)
#'
#' @export
jalpha <- function(data, ..., subset = NULL, labels = TRUE) {

  # Catch missing-comma error: jalpha(VarName, ...) instead of jalpha(, VarName, ...)
  if (!missing(data)) {
    mc <- match.call()
    data <- tryCatch(force(data), error = function(e) {
      .jst_missing_comma_error(deparse(mc$data), "jalpha", e)
    })
  }

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

  variables      <- rlang::enquos(...)
  variable_names <- vapply(variables, rlang::quo_name, character(1))

  .jst_check_vars(data, variable_names, .jst_data_name)

  if (length(variable_names) < 2) {
    stop("jalpha() requires at least 2 items. Only 1 was provided.", call. = FALSE)
  }

  # Red title
  .cat_red("Reliability Analysis\n")
  if (.jst_default_used) cat("(Using default data frame:", .jst_data_name, ")\n")

  # Apply data pipeline (jcomplete, jfilter, subset)
  subset_expr <- substitute(subset)
  pipeline <- .jst_apply_pipeline(data, .jst_data_name, .jst_default_used,
                                  subset_expr = subset_expr, envir = parent.frame())
  data     <- pipeline$data
  .jst_print_msgs(pipeline$msgs)

  items <- data[, variable_names, drop = FALSE]

  for (v in variable_names) {
    if (haven::is.labelled(items[[v]])) {
      items[[v]] <- as.numeric(items[[v]])
    }
  }

  complete_mask  <- stats::complete.cases(items)
  n_total        <- nrow(items)
  n_used         <- sum(complete_mask)
  n_excluded     <- n_total - n_used
  items_complete <- items[complete_mask, ]

  # Case Processing Summary
  case_table <- data.frame(
    Cases   = c("Valid", "Excluded", "Total"),
    N       = c(n_used, n_excluded, n_total),
    Percent = sprintf("%.1f", c(n_used / n_total * 100,
                                n_excluded / n_total * 100,
                                100)),
    stringsAsFactors = FALSE
  )

  cat("\n")
  .jst_print_table(case_table,
                   caption = "Case Processing Summary",
                   col.names = c("", "N", "%"),
                   row.names = FALSE)
  cat("\n")

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
  if (labels) {
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

  # Build sample_info
  sample_info <- .jst_build_sample_info(
    pipeline_counts = pipeline$pipeline_counts,
    data            = pipeline$data,
    analysis_vars   = variable_names,
    n_analysis      = n_used
  )

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
#' column order. Named arguments (e.g. min.valid, var_label) are excluded.
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
.jst_resolve_varrange <- function(quos_list, data, fn_name) {

  all_cols    <- names(data)
  var_names   <- character(0)
  label_parts <- character(0)

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
          "Variable '", start_name, "' not found in the data frame.\n",
          "Check spelling and capitalisation.",
          call. = FALSE
        )
      }
      if (is.na(end_idx)) {
        stop(
          "Variable '", end_name, "' not found in the data frame.\n",
          "Check spelling and capitalisation.",
          call. = FALSE
        )
      }

      if (start_idx > end_idx) {
        stop(
          "In ", start_name, ":", end_name, ", '", start_name,
          "' comes after '", end_name, "' in the data frame column order.\n",
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
#' @param var_label Character string (optional). A variable label to attach
#'   to the result. If omitted, an auto-generated label is used.
#'
#' @return A numeric vector the same length as \code{nrow(data)}, suitable for
#'   assigning to a new column:
#'   \code{MyData$Total <- jsum(, Var1, Var2, Var3)}.
#'
#' @examples
#' \dontrun{
#' # Set the default data frame (so you can omit it in function calls)
#' juse(MyData)
#'
#' # Sum three variables (all must be non-missing)
#' MyData$Total <- jsum(, Score1, Score2, Score3)
#'
#' # Sum with partial data allowed (at least 1 non-missing)
#' MyData$Total <- jsum(, Score1, Score2, Score3, min.valid = 1)
#'
#' # Sum using colon range for consecutive columns
#' MyData$ScaleTotal <- jsum(, Attitude1:Attitude6)
#'
#' # Mix colon ranges and explicit names (e.g. after reverse-coding an item)
#' MyData$ScaleTotal <- jsum(, Attitude1:Attitude3, Attitude4R, Attitude5:Attitude6)
#'
#' # With a custom variable label
#' MyData$Total <- jsum(, Score1, Score2, Score3,
#'                      var_label = "Total Score")
#'
#' # With an explicit data frame (instead of using juse default)
#' MyData$Total <- jsum(MyData, Score1, Score2, Score3)
#' }
#'
#' @seealso \code{\link{javg}} for computing row-wise means.
#'
#' @export
jsum <- function(data, ..., min.valid = NULL, var_label = NULL) {

  # Capture the data name before any evaluation
  .jst_data_name <- if (!missing(data)) {
    paste(deparse(substitute(data)), collapse = "")
  } else NULL

  # Catch missing-comma error: jsum(VarName, ...) instead of jsum(, VarName, ...)
  if (!missing(data)) {
    mc <- match.call()
    data <- tryCatch(force(data), error = function(e) {
      .jst_missing_comma_error(deparse(mc$data), "jsum", e)
    })
  }

  # Resolve default data frame if not specified
  if (missing(data)) {
    resolved <- .jst_resolve_data(envir = parent.frame())
    data <- resolved$data
    .jst_data_name <- resolved$name
  }

  # Resolve variable names (handles colon ranges)
  quos_list <- rlang::enquos(...)
  resolved  <- .jst_resolve_varrange(quos_list, data, "jsum")
  var_names   <- resolved$var_names
  label_parts <- resolved$label_parts

  if (length(var_names) < 2) {
    stop("jsum() requires at least 2 variables.", call. = FALSE)
  }

  .jst_check_vars(data, var_names, .jst_data_name)

  # Extract columns and convert haven-labelled to numeric
  items <- data[, var_names, drop = FALSE]
  for (v in var_names) {
    if (haven::is.labelled(items[[v]])) {
      items[[v]] <- as.numeric(items[[v]])
    } else {
      items[[v]] <- as.numeric(items[[v]])
    }
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
  if (!is.null(var_label)) {
    labelled::var_label(result) <- var_label
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
#' @param var_label Character string (optional). A variable label to attach
#'   to the result. If omitted, an auto-generated label is used.
#'
#' @return A numeric vector the same length as \code{nrow(data)}, suitable for
#'   assigning to a new column:
#'   \code{MyData$ScaleMean <- javg(, Var1, Var2, Var3)}.
#'
#' @examples
#' \dontrun{
#' # Set the default data frame (so you can omit it in function calls)
#' juse(MyData)
#'
#' # Mean of three variables (all must be non-missing)
#' MyData$Avg <- javg(, Score1, Score2, Score3)
#'
#' # Mean with partial data allowed (at least 1 non-missing)
#' MyData$Avg <- javg(, Score1, Score2, Score3, min.valid = 1)
#'
#' # Mean using colon range for consecutive columns
#' MyData$ScaleMean <- javg(, Attitude1:Attitude6)
#'
#' # Mix colon ranges and explicit names (e.g. after reverse-coding an item)
#' MyData$ScaleMean <- javg(, Attitude1:Attitude3, Attitude4R, Attitude5:Attitude6)
#'
#' # Fixed denominator (always divide by total number of variables)
#' MyData$Avg <- javg(, Score1, Score2, Score3, min.valid = 1, fixed = TRUE)
#'
#' # With a custom variable label
#' MyData$ScaleMean <- javg(, Attitude1:Attitude6,
#'                          var_label = "Scale Mean Score")
#'
#' # With an explicit data frame (instead of using juse default)
#' MyData$Avg <- javg(MyData, Score1, Score2, Score3)
#' }
#'
#' @seealso \code{\link{jsum}} for computing row-wise sums.
#'
#' @export
javg <- function(data, ..., min.valid = NULL, fixed = FALSE, var_label = NULL) {

  # Capture the data name before any evaluation
  .jst_data_name <- if (!missing(data)) {
    paste(deparse(substitute(data)), collapse = "")
  } else NULL

  # Catch missing-comma error: javg(VarName, ...) instead of javg(, VarName, ...)
  if (!missing(data)) {
    mc <- match.call()
    data <- tryCatch(force(data), error = function(e) {
      .jst_missing_comma_error(deparse(mc$data), "javg", e)
    })
  }

  # Resolve default data frame if not specified
  if (missing(data)) {
    resolved <- .jst_resolve_data(envir = parent.frame())
    data <- resolved$data
    .jst_data_name <- resolved$name
  }

  # Resolve variable names (handles colon ranges)
  quos_list <- rlang::enquos(...)
  resolved  <- .jst_resolve_varrange(quos_list, data, "javg")
  var_names   <- resolved$var_names
  label_parts <- resolved$label_parts

  if (length(var_names) < 2) {
    stop("javg() requires at least 2 variables.", call. = FALSE)
  }

  .jst_check_vars(data, var_names, .jst_data_name)

  # Extract columns and convert haven-labelled to numeric
  items <- data[, var_names, drop = FALSE]
  for (v in var_names) {
    if (haven::is.labelled(items[[v]])) {
      items[[v]] <- as.numeric(items[[v]])
    } else {
      items[[v]] <- as.numeric(items[[v]])
    }
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
  if (!is.null(var_label)) {
    labelled::var_label(result) <- var_label
  } else {
    auto_label <- paste0("Mean of ", paste(label_parts, collapse = ", "))
    labelled::var_label(result) <- auto_label
  }

  return(invisible(result))
}


# =============================================================================
# jrelabel()
# =============================================================================

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
#' Both the \code{labels} and \code{var_label} arguments are optional. If
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
#' @param var_label Optional. A quoted string to use as the variable label
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
#'                        var_label = "Status (recoded)")
#'
#' # Add just a variable label
#' df$StatusR <- jrelabel(df, StatusR, var_label = "Employment Status")
#'
#' # Add just value labels
#' df$StatusR <- jrelabel(df, StatusR, labels = "1=Yes; 0=No")
#'
#' # Using juse() default
#' juse(df)
#' df$StatusR <- jrelabel(, StatusR, labels = "1=Active; 0=Inactive")
#'
#' @seealso \code{\link{jrecode}} for recoding values with optional labels
#'   in a single step.
#'
#' @export
jrelabel <- function(data, var, labels = NULL, var_label = NULL) {

  # Catch missing-comma error: jrelabel(VarName, ...) instead of jrelabel(, VarName, ...)
  if (!missing(data)) {
    mc <- match.call()
    data <- tryCatch(force(data), error = function(e) {
      .jst_missing_comma_error(deparse(mc$data), "jrelabel", e)
    })
  }

  # Resolve default data frame if not specified
  if (missing(data)) {
    resolved <- .jst_resolve_data(envir = parent.frame())
    data <- resolved$data
  }

  var_name <- deparse(substitute(var))

  # --- Input checks ---
  if (!is.data.frame(data)) {
    stop("The first argument must be a data frame.", call. = FALSE)
  }
  if (!var_name %in% names(data)) {
    stop(paste0("Variable '", var_name, "' not found in the data frame."), call. = FALSE)
  }

  x <- data[[var_name]]

  # --- Preserve any existing variable label before conversion ---
  existing_var_label <- NULL
  if (haven::is.labelled(x)) {
    existing_var_label <- labelled::var_label(x)
  }

  # --- Convert to numeric vector for haven_labelled construction ---
  if (haven::is.labelled(x)) {
    num_vals <- as.numeric(x)
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
  if (!is.null(var_label)) {
    if (!is.character(var_label) || length(var_label) != 1) {
      stop("The var_label argument must be a single quoted string.", call. = FALSE)
    }
    labelled::var_label(result) <- var_label
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


# =============================================================================
# jrecode()
# =============================================================================

#' Recode a variable with explicit value mapping and optional labels
#'
#' @description
#' \code{jrecode()} recodes a variable using a simple map string that specifies
#' how old values should be converted to new values. It is designed for
#' situations where you need to collapse categories, change numeric codes,
#' or recode dichotomies. Variable and value labels are handled automatically.
#'
#' @param data     A data frame containing the original variable.
#' @param orig_var The variable to recode (unquoted, e.g. \code{AgeGroup}).
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
#'     \item \code{else=NA}: unmapped values are deliberately set to missing.
#'     \item \code{else=copy}: unmapped values are carried across unchanged.
#'   }
#'
#'   Individual values can also be mapped to NA to convert coded missing
#'   values: \code{"-5=NA"} or \code{"-99=NA; -5=NA"}.
#'
#'   Examples:
#'   \itemize{
#'     \item \code{"1=1; 2=0"}
#'     \item \code{"1=1; 2,3=2; 4,5=3; else=NA"}
#'     \item \code{"1=1; 2=0; else=copy"}
#'     \item \code{"-5=NA; else=copy"}
#'   }
#'
#' @param labels   Optional. A quoted string specifying value labels for the
#'   new variable, using the format \code{"code=Label Text"} with rules
#'   separated by semicolons. If supplied, these labels are used as-is.
#'
#'   If omitted, the function attempts to transfer value labels automatically
#'   from the original variable. This works when the original variable has
#'   value labels and the mapping is one-to-one (no categories are collapsed).
#'   When categories are collapsed, labels cannot be transferred automatically
#'   and a note is printed.
#'
#'   Example: \code{"1=Male; 0=Female"}
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
#' # Use else=NA to deliberately drop unspecified values
#' df$gearR4 <- jrecode(df, gear,
#'                      map    = "3=1; 4=2; else=NA",
#'                      labels = "1=Three gears; 2=Four gears")
#'
#' # Convert a specific coded missing value to NA
#' df$gearR5 <- jrecode(df, gear, map = "99=NA; else=copy")
#'
#' # Using juse() default
#' juse(df)
#' df$gearR6 <- jrecode(, gear, map = "3=1; 4=2; 5=3",
#'                       labels = "1=Three; 2=Four; 3=Five")
#'
#' @seealso \code{\link{jrelabel}} for applying labels to an existing variable
#'   after a recode.
#'
#' @export
jrecode <- function(data, orig_var, map, labels = NULL) {

  # Catch missing-comma error: jrecode(VarName, ...) instead of jrecode(, VarName, ...)
  if (!missing(data)) {
    mc <- match.call()
    data <- tryCatch(force(data), error = function(e) {
      .jst_missing_comma_error(deparse(mc$data), "jrecode", e)
    })
  }

  # Resolve default data frame if not specified
  .jst_data_name <- NULL
  if (missing(data)) {
    resolved <- .jst_resolve_data(envir = parent.frame())
    data <- resolved$data
    .jst_data_name <- resolved$name
  } else {
    .jst_data_name <- deparse(substitute(data))
  }

  orig_name <- deparse(substitute(orig_var))

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

  orig <- data[[orig_name]]

  # --- Detect suspicious coded missing values ---
  suspicious_vals <- .jst_detect_suspicious_values(orig, orig_name)

  # --- Parse map string ---
  parsed_map <- tryCatch(
    .jst_parse_map(map),
    error = function(e) stop(paste0("Error in map argument: ", conditionMessage(e)), call. = FALSE)
  )

  # --- Apply recode ---
  orig_num  <- as.numeric(orig)
  new_num   <- rep(NA_real_, length(orig_num))

  all_specified_old <- c()

  for (rule in parsed_map$mappings) {
    old_vals <- rule$old_vals
    new_val  <- rule$new_val
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

    new_num[!is.na(orig_num) & orig_num %in% old_vals] <- new_val
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
    } else {
      # No else clause: stop so student can fix the map
      stop(paste0(
        "Value(s) ", paste(legitimate_unspecified, collapse = ", "),
        " in '", orig_name, "' were not in the map. ",
        "Map these values and re-run."
      ), call. = FALSE)
    }
  }

  # Print note about suspicious values that were forced to NA
  if (length(suspicious_unspecified) > 0) {
    message(paste0(
      "Note: ", paste(suspicious_unspecified, collapse = ", "),
      " in '", orig_name,
      "' looks like a coded missing value and was set to NA."
    ))
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
  if (!is.null(labels)) {
    # User-supplied labels always take precedence
    if (!is.character(labels) || length(labels) != 1) {
      stop("The labels argument must be a single quoted string, e.g. labels = \"1=Male; 0=Female\".", call. = FALSE)
    }
    parsed_labels <- tryCatch(
      .jst_parse_labels(labels),
      error = function(e) stop(paste0("Error in labels argument: ",
                                      conditionMessage(e)), call. = FALSE)
    )
    labelled::val_labels(result) <- parsed_labels
  } else {
    # No labels supplied — try to auto-transfer from original variable
    orig_val_labels <- if (is_haven) labelled::val_labels(orig) else NULL

    if (!is.null(orig_val_labels) && length(orig_val_labels) > 0) {
      # Detect collapsing: multiple old values mapping to the same new value
      is_collapsing <- any(vapply(parsed_map$mappings,
                                  function(r) length(r$old_vals) > 1,
                                  logical(1)))
      if (!is_collapsing) {
        new_vals <- vapply(parsed_map$mappings,
                           function(r) r$new_val, numeric(1))
        is_collapsing <- anyDuplicated(new_vals) > 0
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
            # Explicitly mapped — use the new code
            entry        <- old_to_new[[as.character(old_code)]]
            names(entry) <- label_name
            new_val_labels <- c(new_val_labels, entry)
          } else if (parsed_map$else_action == "copy") {
            # Unmapped but carried across unchanged
            entry        <- old_code
            names(entry) <- label_name
            new_val_labels <- c(new_val_labels, entry)
          }
          # else: value became NA, label is dropped
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
#'     (a) \code{Data/} subfolder, (b) \code{data/} subfolder,
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
#'#' # Extension omitted — jload searches for a matching file automatically
#' jload("mydata")
#'
#' # Full file path
#' jload("C:/Projects/Data/mydata.dta")
#' }
#'
#' @export
jload <- function(file, name = NULL, use = FALSE, overwrite = FALSE,
                  check.missing = TRUE, sheet = NULL) {

  # --- Validate file argument ------------------------------------------------
  if (missing(file) || !is.character(file) || length(file) != 1 ||
      nchar(trimws(file)) == 0) {
    stop("Please provide a filename, e.g. jload(\"mydata.sav\")", call. = FALSE)
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
                       collapse = " and "))
        else
          paste0("Searched in: ", dirname(file)),
        call. = FALSE
      )
    }
    if (length(found) == 1) {
      message("Found ", basename(found), " in ", dirname(found), "/")
      file    <- found
      ext     <- tolower(tools::file_ext(file))
      has_dir <- TRUE
    } else {
      msg <- paste0(
        "Multiple files found matching '", file, "':\n",
        paste0("  ", found, collapse = "\n"), "\n",
        "Please include the file extension to specify which one."
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
      "  .rds       R data (single object)",
      call. = FALSE
    )
  }

  # --- Resolve file path -----------------------------------------------------
  if (has_dir) {
    # Full or relative path provided — use directly
    resolved_path <- file
    if (!file.exists(resolved_path)) {
      stop("File not found: ", resolved_path, call. = FALSE)
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
      "Please provide a name, e.g.:\n",
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
  df <- switch(ext,
               sav      = haven::read_sav(resolved_path),
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

  # --- Assign to environment -------------------------------------------------
  assign(obj_name, df, envir = target_env)

  # --- Summary message -------------------------------------------------------
  message(
    "Loaded ", obj_name, ": ",
    format(nrow(df), big.mark = ","), " cases, ",
    ncol(df), " variables"
  )

  # --- Set as default with juse() if requested -------------------------------
  if (use) {
    options(.jst_default_data = obj_name)
    message("Default data frame set to: ", obj_name)
  }

  # --- Coded missing value scan ----------------------------------------------
  if (check.missing) {
    .jst_scan_coded_missing(df, obj_name, ext)
  }

  invisible(df)
}


# -- jload internal helpers ---------------------------------------------------

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
#' @keywords internal
.jst_get_search_dirs <- function() {
  dirs <- c(".")
  if (dir.exists("Data")) dirs <- c("Data", dirs)
  if (dir.exists("data") && !dir.exists("Data")) dirs <- c("data", dirs)
  # If both Data/ and data/ exist (unusual), check both — Data/ first
  if (dir.exists("Data") && dir.exists("data") &&
      !identical(normalizePath("Data"), normalizePath("data"))) {
    dirs <- c("Data", "data", ".")
  }
  return(dirs)
}

#' Internal: find a bare filename in Data/, data/, or working directory
#' @keywords internal
.jst_find_file <- function(filename) {
  search_dirs <- .jst_get_search_dirs()
  for (d in search_dirs) {
    candidate <- file.path(d, filename)
    if (file.exists(candidate)) {
      if (d != ".") {
        message("Reading from ", d, "/")
      }
      return(candidate)
    }
  }
  stop(
    "File '", filename, "' not found.\n",
    "Searched in: ",
    paste(ifelse(search_dirs == ".", "working directory",
                 paste0(search_dirs, " folder")),
          collapse = " and "), "\n",
    "Check that the filename and extension are correct.",
    call. = FALSE
  )
}

#' Internal: scan for coded missing values and report findings
#' @keywords internal
.jst_scan_coded_missing <- function(df, obj_name, ext) {

  max_report <- 20L  # Maximum number of rows to display

  # Collect findings: list of lists with var, value, count, source
  findings <- list()

  for (vname in names(df)) {
    col <- df[[vname]]
    if (!is.numeric(col) && !inherits(col, "haven_labelled")) next
    # Only scan numeric-like variables
    num_vals <- suppressWarnings(as.numeric(col))
    if (all(is.na(num_vals))) next

    # --- Check SPSS user-defined missing values (haven attribute) ---
    # SPSS-defined missings are checked on ALL values (including decimals)
    # because SPSS allows any value to be defined as missing.
    spss_na_vals <- attr(col, "na_values")
    spss_na_range <- attr(col, "na_range")

    if (!is.null(spss_na_vals)) {
      for (sv in spss_na_vals) {
        n_cases <- sum(num_vals == sv, na.rm = TRUE)
        if (n_cases > 0) {
          findings[[length(findings) + 1]] <- list(
            var = vname, value = sv, count = n_cases,
            source = "defined as missing in original SPSS file"
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
              source = "defined as missing in original SPSS file"
            )
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
        # Skip if already reported from SPSS metadata
        already <- any(vapply(findings, function(f) {
          f$var == vname && f$value == sv
        }, logical(1)))
        if (!already) {
          n_cases <- sum(num_vals == sv, na.rm = TRUE)
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
    cat("\nPossible coded missing values detected:\n")
    n_show <- min(length(findings), max_report)
    for (i in seq_len(n_show)) {
      f <- findings[[i]]
      cat(sprintf("  %-15s %6g  (%d case%s)  [%s]\n",
                  paste0(f$var, ":"), f$value, f$count,
                  if (f$count == 1) "" else "s", f$source))
    }
    if (length(findings) > max_report) {
      cat(sprintf("  ... and %d more.\n", length(findings) - max_report))
    }
    # Build example from first finding
    ex <- findings[[1]]
    cat("\nUse jrecode() to convert to NA if needed, e.g.:\n")
    cat(sprintf("  %s$%s <- jrecode(%s, %s, map = \"%g=NA; else=copy\")\n",
                obj_name, ex$var, obj_name, ex$var, ex$value))
    cat("If these are real values, no action is needed.\n")
  }
}


# -- jsave --------------------------------------------------------------------

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
#' By default, \code{jsave()} writes to a \code{Data/} subfolder. If a
#' \code{Data/} (or \code{data/}) folder already exists, it is used. If
#' neither exists, a \code{Data/} folder is created automatically.
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
#'   \item If the path is a bare filename, \code{jsave()} writes to the
#'     \code{Data/} subfolder (using an existing one, or creating one
#'     if neither \code{Data/} nor \code{data/} exists).
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
#' @export
jsave <- function(data, file, overwrite = FALSE) {

  # --- Resolve data frame ----------------------------------------------------
  if (missing(data)) {
    resolved <- .jst_resolve_data(envir = parent.frame())
    data <- resolved$data
    data_name <- resolved$name
  } else {
    # Capture name before evaluation
    data_name <- deparse(substitute(data))
    # Check for missing-comma error
    mc <- match.call()
    data <- tryCatch(force(data), error = function(e) {
      .jst_missing_comma_error(deparse(mc$data), "jsave", e)
    })
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
      "Please provide a filename with extension, e.g. jsave(MyData, \"mydata.sav\")\n",
      "Supported formats:\n",
      "  .sav       SPSS\n",
      "  .dta       Stata\n",
      "  .xpt       SAS transport\n",
      "  .xlsx      Excel\n",
      "  .csv       Comma-separated values\n",
      "  .rds       R data (single object)",
      call. = FALSE
    )
  }

  # --- Check extension -------------------------------------------------------
  ext <- tolower(tools::file_ext(file))

  if (ext == "") {
    stop(
      "No file extension provided. Please include an extension to specify ",
      "the format:\n",
      "  .sav       SPSS\n",
      "  .dta       Stata\n",
      "  .xpt       SAS transport\n",
      "  .xlsx      Excel\n",
      "  .csv       Comma-separated values\n",
      "  .rds       R data (single object)",
      call. = FALSE
    )
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
      "  .rds       R data (single object)",
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
      stop("Directory does not exist: ", out_dir, call. = FALSE)
    }
  } else {
    # Bare filename — write to Data/ (create if needed)
    if (!dir.exists("Data") && !dir.exists("data")) {
      dir.create("Data")
      message("Created 'Data' folder in working directory.")
      out_path <- file.path("Data", file)
    } else if (dir.exists("Data")) {
      out_path <- file.path("Data", file)
    } else {
      out_path <- file.path("data", file)
    }
  }

  # --- Overwrite check -------------------------------------------------------
  if (file.exists(out_path) && !overwrite) {
    if (interactive()) {
      response <- readline(
        paste0("File '", out_path, "' already exists. Overwrite? (y/n): ")
      )
      if (!tolower(trimws(response)) %in% c("y", "yes")) {
        message("Save cancelled.")
        return(invisible(NULL))
      }
    } else {
      stop(
        "File '", out_path, "' already exists. ",
        "Use overwrite = TRUE to replace it.",
        call. = FALSE
      )
    }
  }

  # --- Write the file --------------------------------------------------------
  switch(ext,
         sav = haven::write_sav(data, out_path),
         dta = haven::write_dta(data, out_path, version = 14),
         xpt = haven::write_xpt(data, out_path),
         xlsx = {
           writexl::write_xlsx(data, out_path)
           message("Note: Excel format does not preserve variable or value labels.")
         },
         csv = {
           utils::write.csv(data, out_path, row.names = FALSE)
           message("Note: CSV format does not preserve variable or value labels.")
         },
         rds = saveRDS(data, out_path)
  )

  # --- Confirmation message --------------------------------------------------
  message(
    "Saved ", data_name, " to ", out_path,
    " (", format(nrow(data), big.mark = ","), " cases, ",
    ncol(data), " variables)"
  )

  invisible(NULL)
}


# -- .jst_plot_logistic_diagnostics --------------------------------------------

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
#'   \code{"binned"}, \code{"roc"}, \code{"calibration"}, \code{"cooks"},
#'   \code{"leverage"}.
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


# -- jplot ---------------------------------------------------------------------

#' Visualise jst_* result objects or plot variables directly from a data frame
#'
#' Unified plotting function. Can be called in two ways:
#'
#' \strong{Result-object form:} Pass a result object returned by one of the
#' package's analysis functions. Produces appropriate plots for each class of
#' result (see valid plot names below).
#'
#' \strong{Data-first form:} Pass a data frame followed by one or two unquoted
#' variable names. Produces a plot with sensible auto-detection based on
#' variable types (histogram for one numeric variable, bar chart for one
#' categorical, scatter for two numeric, boxplot for one numeric and one
#' categorical, grouped bar for two categorical). Override the auto-detection
#' with \code{type = "..."}. Supports pipeline integration (\code{jfilter},
#' \code{jcomplete}, per-call \code{subset}), grouping via \code{by = }, and
#' regression lines with equation/R-squared/band annotations.
#'
#' Valid plot names by class (for the result-object form):
#' \itemize{
#'   \item \code{jst_lm}: \code{"fit"}, \code{"predicted"}, \code{"effects"},
#'     \code{"coef"}, \code{"vif"}, \code{"residuals"}, \code{"qq"},
#'     \code{"scale"}, \code{"cooks"}, \code{"leverage"}
#'   \item \code{jst_logistic}: \code{"probability"}, \code{"roc"},
#'     \code{"calibration"}, \code{"binned"}, \code{"cooks"}, \code{"leverage"},
#'     \code{"coef"}, \code{"vif"}
#'   \item \code{jst_ttest}, \code{jst_anova}: \code{"box"}
#'   \item \code{jst_corr}: \code{"heatmap"}, \code{"scatter"} (scatter requires
#'     exactly 2 variables in the correlation)
#'   \item \code{jst_chisq}: \code{"bar"}
#' }
#'
#' The shortcut keyword \code{"core"} (default) produces a curated default
#' set for the class; \code{"all"} produces every plot the class supports.
#'
#' Valid plot types for the data-first form: \code{"histogram"}, \code{"bar"},
#' \code{"scatter"}, \code{"box"}, \code{"grouped_bar"}.
#'
#' Valid \code{line} values: \code{FALSE} (default), \code{TRUE} (alias for
#' \code{"lm"}), \code{"lm"}, \code{"loess"}, \code{"connect"}.
#'
#' Valid \code{band} values: \code{"ci"} (default confidence band around the
#' regression line, flares at the ends), \code{"pi"} (prediction interval for
#' individual observations, wider), \code{"see"} (constant-width +/- t*SEE
#' band illustrating the homoskedasticity assumption), \code{"none"} (no band).
#'
#' @param x A result object from one of the package's analysis functions
#'   (result-object form), or a data frame (data-first form).
#' @param which Character vector. \code{"core"} (default), \code{"all"}, or
#'   one or more specific plot names valid for the object's class.
#'   (Result-object form only.)
#' @param ... Additional arguments: for the result-object form these are
#'   passed to class-specific methods; for the data-first form these are
#'   unquoted variable names (1 or 2).
#' @param focal Unquoted name of the independent variable to place on the
#'   x-axis for \code{jst_lm} / \code{jst_logistic} \code{"fit"} and
#'   \code{"probability"} plots. Defaults to the first IV in the model.
#' @param at Character string or named list specifying where non-focal
#'   independent variables are held when drawing the fitted line in
#'   \code{jst_lm} / \code{jst_logistic} methods. One of \code{"zero"}
#'   (default), \code{"mean"}, \code{"mixed"} (categorical at 0, interval
#'   at mean), or a named list \code{list(Var1 = value, ...)}.
#' @param equation Logical. If TRUE (default), displays the equation in the
#'   subtitle for \code{line = "lm"} scatter plots (data-first form) or
#'   \code{jst_lm} \code{"fit"} plots (result-object form).
#' @param r2 Logical. If TRUE (default), displays R-squared in the subtitle
#'   alongside the equation.
#' @param by Unquoted variable name for group-colouring (data-first form).
#' @param type Character. Plot type override for the data-first form. One
#'   of \code{"histogram"}, \code{"bar"}, \code{"scatter"}, \code{"box"},
#'   \code{"grouped_bar"}. If NULL (default), auto-detected from variable
#'   types.
#' @param line Controls a line overlay on data-first scatter plots. One of
#'   \code{FALSE} (default; no line), \code{TRUE} (alias for \code{"lm"}),
#'   \code{"lm"}, \code{"loess"}, \code{"connect"}.
#' @param band Character. Uncertainty band type for \code{line = "lm"}
#'   scatter plots. One of \code{"ci"} (default; 95\% confidence band for
#'   the mean, flares at the ends), \code{"pi"} (95\% prediction interval
#'   for individual observations), \code{"see"} (constant-width band at
#'   +/- t*SEE; useful for teaching homoskedasticity), \code{"none"}.
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
#'   # Data-first form
#'   jplot(SampleData, Age)                           # histogram
#'   jplot(SampleData, Age, Tattoos)                  # scatter
#'   jplot(SampleData, Age, Tattoos, line = "lm")     # scatter + regression
#'   jplot(SampleData, Age, Tattoos, line = "lm", band = "see")
#'   jplot(SampleData, Age, Tattoos, by = Gender, line = "lm")
#'   jplot(SampleData, Age, Gender)                   # boxplot (auto)
#' }
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
                          band = "ci", subset = NULL, labels = TRUE) {

  # Rename to `data` internally for clarity; the generic uses `x` for S3 consistency
  data <- x

  # Capture original expression before any evaluation
  .data_expr <- if (!missing(data)) {
    paste(deparse(substitute(x)), collapse = "")
  } else NULL

  # Catch missing-comma error: jplot(VarName) instead of jplot(, VarName)
  if (!missing(data)) {
    mc <- match.call()
    data <- tryCatch(force(data), error = function(e) {
      .jst_missing_comma_error(deparse(mc$x), "jplot", e)
    })
  }

  # Resolve default data frame if not specified
  .jst_default_used <- FALSE
  .jst_data_name    <- NULL
  if (missing(data)) {
    resolved <- .jst_resolve_data(envir = parent.frame())
    data <- resolved$data
    .jst_default_used <- TRUE
    .jst_data_name    <- resolved$name
  } else {
    .jst_data_name <- .data_expr
  }

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
  variables      <- rlang::enquos(...)
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

  # Apply data pipeline (jcomplete, jfilter, subset)
  subset_expr <- substitute(subset)
  pipeline <- .jst_apply_pipeline(data, .jst_data_name, .jst_default_used,
                                  subset_expr = subset_expr,
                                  envir = parent.frame())
  data <- pipeline$data
  .jst_print_msgs(pipeline$msgs)

  # Classify variables
  var_types <- vapply(variable_names,
                      function(v) if (.jst_is_categorical(data[[v]]))
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
  if (labels) {
    .print_var_labels(data, check_names)
  }

  # Dispatch to plot builder
  p <- switch(
    resolved_type,
    histogram   = .jst_build_histogram(data, variable_names[1], by_name),
    bar         = .jst_build_bar(data, variable_names[1], by_name),
    scatter     = .jst_build_scatter(data, variable_names, by_name,
                                     line, equation, r2, band),
    box         = .jst_build_box(data, variable_names, var_types, by_name),
    grouped_bar = .jst_build_grouped_bar(data, variable_names)
  )

  print(p)
  invisible(p)
}


# -- Data-first plot helpers ---------------------------------------------------

#' Internal helper: classify a variable as categorical or numeric
#'
#' Uses the same rule as jlm() auto-detection: factor/logical/character, or
#' haven-labelled with value labels attached, or 0/1-coded numeric, counts as
#' categorical. Everything else is numeric.
#'
#' @param x A variable (vector).
#' @return TRUE if categorical, FALSE if numeric.
#' @keywords internal
.jst_is_categorical <- function(x) {
  if (is.factor(x) || is.logical(x) || is.character(x)) return(TRUE)
  if (haven::is.labelled(x)) {
    val_labs <- labelled::val_labels(x)
    return(!is.null(val_labs) && length(val_labs) > 0)
  }
  ux <- unique(x[!is.na(x)])
  if (length(ux) == 2 && all(ux %in% c(0, 1))) return(TRUE)
  FALSE
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
.jst_build_histogram <- function(data, x_name, by_name = NULL) {
  plot_df <- data.frame(x = data[[x_name]])
  if (!is.null(by_name)) plot_df$by <- data[[by_name]]

  plot_df <- plot_df[stats::complete.cases(plot_df), , drop = FALSE]

  if (is.null(by_name)) {
    p <- ggplot2::ggplot(plot_df, ggplot2::aes(x = .data$x)) +
      ggplot2::geom_histogram(bins = 30, fill = "#3366FF", color = "white",
                              alpha = 0.85) +
      ggplot2::labs(x = x_name, y = "Count") +
      ggplot2::theme_minimal()
  } else {
    p <- ggplot2::ggplot(plot_df, ggplot2::aes(x = .data$x,
                                                fill = .data$by)) +
      ggplot2::geom_histogram(bins = 30, color = "white", alpha = 0.55,
                              position = "identity") +
      ggplot2::labs(x = x_name, y = "Count", fill = by_name) +
      ggplot2::theme_minimal()
  }
  p
}


#' Internal helper: build bar chart (1 categorical variable)
#'
#' @keywords internal
#' @importFrom rlang .data
.jst_build_bar <- function(data, x_name, by_name = NULL) {
  plot_df <- data.frame(x = data[[x_name]])
  if (!is.null(plot_df$x) && !is.factor(plot_df$x)) {
    plot_df$x <- factor(plot_df$x)
  }
  if (!is.null(by_name)) plot_df$by <- data[[by_name]]

  plot_df <- plot_df[stats::complete.cases(plot_df), , drop = FALSE]

  if (is.null(by_name)) {
    p <- ggplot2::ggplot(plot_df, ggplot2::aes(x = .data$x)) +
      ggplot2::geom_bar(fill = "#3366FF", alpha = 0.85) +
      ggplot2::labs(x = x_name, y = "Count") +
      ggplot2::theme_minimal()
  } else {
    p <- ggplot2::ggplot(plot_df, ggplot2::aes(x = .data$x, fill = .data$by)) +
      ggplot2::geom_bar(position = ggplot2::position_dodge(width = 0.8),
                        width = 0.7) +
      ggplot2::labs(x = x_name, y = "Count", fill = by_name) +
      ggplot2::theme_minimal()
  }
  p
}


#' Internal helper: build scatterplot (2 numeric variables)
#'
#' @keywords internal
#' @importFrom rlang .data
.jst_build_scatter <- function(data, variable_names, by_name,
                               line, equation, r2, band) {

  x_name <- variable_names[1]
  y_name <- variable_names[2]

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

  p <- p + ggplot2::labs(x = x_name, y = y_name,
                         color = by_name, fill = by_name,
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
.jst_build_box <- function(data, variable_names, var_types, by_name = NULL) {

  # Numeric on y, categorical on x
  if (var_types[1] == "numeric") {
    y_name <- variable_names[1]
    x_name <- variable_names[2]
  } else {
    x_name <- variable_names[1]
    y_name <- variable_names[2]
  }

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
      ggplot2::labs(x = x_name, y = y_name,
                    subtitle = "Diamond marks the group mean") +
      ggplot2::theme_minimal()
  } else {
    p <- ggplot2::ggplot(plot_df, ggplot2::aes(x = .data$x, y = .data$y,
                                                fill = .data$by)) +
      ggplot2::geom_boxplot(outlier.alpha = 0.6) +
      ggplot2::labs(x = x_name, y = y_name, fill = by_name) +
      ggplot2::theme_minimal()
  }
  p
}


#' Internal helper: build grouped bar chart (2 categorical variables)
#'
#' @keywords internal
#' @importFrom rlang .data
.jst_build_grouped_bar <- function(data, variable_names) {
  x_name    <- variable_names[1]
  fill_name <- variable_names[2]

  plot_df <- data.frame(x = data[[x_name]], fill = data[[fill_name]])
  if (!is.factor(plot_df$x))    plot_df$x    <- factor(plot_df$x)
  if (!is.factor(plot_df$fill)) plot_df$fill <- factor(plot_df$fill)
  plot_df <- plot_df[stats::complete.cases(plot_df), , drop = FALSE]

  p <- ggplot2::ggplot(plot_df, ggplot2::aes(x = .data$x, fill = .data$fill)) +
    ggplot2::geom_bar(position = ggplot2::position_dodge(width = 0.8),
                      width = 0.7) +
    ggplot2::scale_fill_brewer(palette = "Blues") +
    ggplot2::labs(x = x_name, y = "Count", fill = fill_name) +
    ggplot2::theme_minimal()
  p
}


# -- Internal helpers for jplot ------------------------------------------------

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

.jst_return_plots <- function(plots) {
  plots <- plots[!vapply(plots, is.null, logical(1))]
  if (length(plots) == 0) return(invisible(NULL))
  if (length(plots) == 1) return(invisible(plots[[1]]))
  invisible(plots)
}

.jst_resolve_at <- function(at, model_frame, dv_name, focal_name,
                            dummy_coef_names) {

  non_focal <- setdiff(colnames(model_frame), c(dv_name, focal_name))

  if (length(non_focal) == 0) return(list())

  classify <- function(v) {
    if (v %in% dummy_coef_names) return("categorical")
    x <- model_frame[[v]]
    if (is.factor(x) || is.logical(x) || is.character(x)) return("categorical")
    ux <- unique(stats::na.omit(x))
    if (length(ux) <= 2 && all(ux %in% c(0, 1))) return("categorical")
    "interval"
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


# -- jplot.jst_chisq -----------------------------------------------------------

#' @rdname jplot
#' @export
#' @importFrom rlang .data
jplot.jst_chisq <- function(x, which = "core", ...) {

  .jst_check_args(
    list(...),
    aliases = c(diagnostics = "which", plots = "which",
                show = "which", type = "which"),
    fn_name = "jplot.jst_chisq"
  )

  if (!requireNamespace("ggplot2", quietly = TRUE)) {
    stop("Package 'ggplot2' is required for jplot(). ",
         "Install with: install.packages(\"ggplot2\")", call. = FALSE)
  }

  plot_set <- .jst_resolve_which(which, core = "bar", all_plots = "bar",
                                 class_name = "jst_chisq")

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


# -- .onUnload ----------------------------------------------------------------

#' Clean up session options when the package is unloaded
#'
#' @keywords internal
.onUnload <- function(libpath) {
  options(.jst_default_data = NULL)
  options(.jst_filter = NULL)
  options(.jst_complete = NULL)
  options(.jst_dummy = NULL)
  options(.jst_output_level = NULL)
  options(.jst_output_toggles = NULL)
}
