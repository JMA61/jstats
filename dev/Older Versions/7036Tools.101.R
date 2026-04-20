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
#' Used by jt, jaov, jcorr, jchisq, jscreen, and jalpha.
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
#'   }
#'
#' @keywords internal
.jst_apply_pipeline <- function(data, data_name, is_default,
                                subset_expr = NULL, envir = parent.frame()) {

  msgs <- character(0)
  n_original <- nrow(data)

  if (is_default) {

    # -- Step 1: jcomplete ---------------------------------------------------
    cs <- .jst_get_complete(data_name)
    if (!is.null(cs)) {
      if (cs$active) {
        valid_vars <- cs$vars[cs$vars %in% names(data)]
        if (length(valid_vars) > 0) {
          n_before      <- nrow(data)
          complete_mask <- stats::complete.cases(data[, valid_vars, drop = FALSE])
          data          <- data[complete_mask, , drop = FALSE]
          n_after       <- nrow(data)
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
        }
      } else {
        msgs <- c(msgs, "(jcomplete set but inactive)")
      }
    }

    # -- Step 2: jfilter -----------------------------------------------------
    fs <- .jst_get_filter(data_name)
    if (!is.null(fs)) {
      if (fs$active) {
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
    msgs <- c(msgs, paste0(
      "(Subset: ", deparse(subset_expr), " \u2014 ",
      n_after, " of ", n_before, " cases remaining)"))
  }

  list(data = data, msgs = msgs)
}

#' Internal helper: print info-line messages generated by the pipeline
#'
#' @keywords internal
.jst_print_msgs <- function(msgs) {
  for (m in msgs) cat(m, "\n")
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

  # Rule 1: negative values when all others are positive
  neg_vals <- vals[vals < 0]
  pos_vals <- vals[vals >= 0]

  if (length(neg_vals) > 0 && length(pos_vals) >= 2) {
    suspicious <- c(suspicious, neg_vals)
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
    stop(conditionMessage(original_error), call. = FALSE)
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
    new_val <- suppressWarnings(as.numeric(rhs))
    if (is.na(new_val)) {
      stop(paste0(
        "Invalid new value '", rhs, "' in map rule '", rule, "'. ",
        "New values must be numeric."
      ), call. = FALSE)
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
#' \code{jfreq(PopulationData, Computer)}), the filter is not applied
#' for that call.
#'
#' @param expr A logical expression (e.g. \code{Gender == 1}), or one
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
#' @param labels Logical. If \code{TRUE} (default), prints the variable type
#'   and label (or "None") for each variable before the table.
#'
#' @return Invisibly returns a data frame of descriptive statistics. Also
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
#' @export
jdesc <- function(data, ..., by = NULL, labels = TRUE) {

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
    .jst_data_name <- deparse(substitute(data))
  }

  # Handle vector input
  if (is.atomic(data) && !is.data.frame(data)) {
    var_name <- deparse(substitute(data))
    temp_df  <- data.frame(x = data)
    names(temp_df) <- var_name
    return(jdesc(temp_df, !!rlang::sym(var_name), labels = FALSE))
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

    # Apply data pipeline (jcomplete, jfilter) — once before per-variable loop
    pipeline <- .jst_apply_pipeline(data, .jst_data_name, .jst_default_used)
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
    return(invisible(NULL))
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

  # Apply data pipeline (jcomplete, jfilter)
  pipeline <- .jst_apply_pipeline(data, .jst_data_name, .jst_default_used)
  data     <- pipeline$data
  .jst_print_msgs(pipeline$msgs)

  if (labels) {
    for (v in variable_names) {
      cat(v, "\n", sep = "")
      cat("  Type: ", .format_var_type(original_var_info[[v]]$class), "\n", sep = "")
      cat("  Variable label: ", original_var_info[[v]]$label, "\n", sep = "")
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
  invisible(descriptives)
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
#' @param labels Logical. If \code{TRUE} (default), prints the variable type
#'   and label (or "None") beneath the title.
#'
#' @return Invisibly returns a named list of data frames (one per variable)
#'   containing the frequency table.
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
#' @export
jfreq <- function(data, ..., labels = TRUE) {

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
    .jst_data_name <- deparse(substitute(data))
  }

  # Handle vector input
  if (is.atomic(data) && !is.data.frame(data)) {
    var_name <- deparse(substitute(data))
    temp_df  <- data.frame(x = data)
    names(temp_df) <- var_name
    return(jfreq(temp_df, !!rlang::sym(var_name), labels = FALSE))
  }

  variables <- rlang::enquos(...)
  results   <- list()

  # Check all variables exist before any processing
  var_names_check <- vapply(variables, rlang::quo_name, character(1))
  .jst_check_vars(data, var_names_check, .jst_data_name)

  # Apply data pipeline (jcomplete, jfilter) — once before per-variable loop
  pipeline <- .jst_apply_pipeline(data, .jst_data_name, .jst_default_used)
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
  invisible(results)
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
#' @param effect.size Logical. If TRUE, prints Cohen's d.
#' @param levene Logical. If TRUE, prints Levene's test for homogeneity
#'   of variance. Ignored when paired = TRUE.
#' @param ci Logical. If TRUE, adds 95\% confidence interval for the
#'   mean difference.
#' @param labels Logical. If TRUE (default), prints variable labels
#'   when available.
#' @param full Logical. If TRUE, turns on effect.size, levene, and ci
#'   all at once.
#'
#' @return Invisibly returns the \code{t.test} result object.
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
               effect.size = FALSE, levene = FALSE, ci = FALSE,
               labels = TRUE, full = FALSE) {

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
    effect.size <- TRUE
    levene      <- TRUE
    ci          <- TRUE
  }

  # Red title - determined before any output
  if (paired) {
    .cat_red("Paired Samples T-Test\n")
  } else if (welch) {
    .cat_red("Welch's Independent Samples T-Test\n")
  } else {
    .cat_red("Independent Samples T-Test\n")
  }
  if (.jst_default_used) cat("(Using default data frame:", .jst_data_name, ")\n")

  # Apply data pipeline (jcomplete, jfilter)
  pipeline <- .jst_apply_pipeline(data, .jst_data_name, .jst_default_used)
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

  # Effect size (Cohen's d)
  if (effect.size) {
    n1 <- length(group1_data)
    n2 <- length(group2_data)
    m1 <- mean(group1_data)
    m2 <- mean(group2_data)
    s1 <- sd(group1_data)
    s2 <- sd(group2_data)

    if (paired) {
      diffs <- group1_data - group2_data
      d     <- round(mean(diffs) / sd(diffs), 3)
      cat("\nCohen's dz (paired):", d, "\n")
    } else {
      sp <- sqrt(((n1 - 1) * s1^2 + (n2 - 1) * s2^2) / (n1 + n2 - 2))
      d  <- round((m1 - m2) / sp, 3)
      cat("\nCohen's d:", d, "\n")
    }
  }

  cat("\n")
  invisible(result)
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
#' @param posthoc Logical. If TRUE, prints Tukey HSD pairwise comparisons.
#'   Not available when welch = TRUE.
#' @param effect.size Logical. If TRUE, prints eta-squared.
#' @param levene Logical. If TRUE, prints Levene's test for homogeneity
#'   of variance.
#' @param ci Logical. If TRUE, adds 95\% confidence intervals to the
#'   group descriptives table.
#' @param labels Logical. If TRUE (default), prints variable labels
#'   when available.
#' @param full Logical. If TRUE, turns on posthoc, effect.size, levene,
#'   and ci all at once.
#'
#' @return Invisibly returns the model object (aov or oneway.test).
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
jaov <- function(formula, data, welch = FALSE, posthoc = FALSE,
                 effect.size = FALSE, levene = FALSE, ci = FALSE,
                 labels = TRUE, full = FALSE) {

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
    posthoc     <- TRUE
    effect.size <- TRUE
    levene      <- TRUE
    ci          <- TRUE
  }

  # Red title
  if (welch) {
    .cat_red("Welch's One-Way ANOVA\n")
  } else {
    .cat_red("One-Way ANOVA\n")
  }
  if (.jst_default_used) cat("(Using default data frame:", .jst_data_name, ")\n")

  # Apply data pipeline (jcomplete, jfilter)
  pipeline <- .jst_apply_pipeline(data, .jst_data_name, .jst_default_used)
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

    if (effect.size) {
      temp_model  <- stats::aov(formula, data = data)
      temp_result <- summary(temp_model)[[1]]
      eta_sq <- round(temp_result$`Sum Sq`[1] / sum(temp_result$`Sum Sq`), 3)
      cat("\nEta-squared:", eta_sq, "\n")
      cat("(Note: Eta-squared is calculated from the traditional SS decomposition.)\n")
    }

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

    if (effect.size) {
      eta_sq <- round(result$`Sum Sq`[1] / sum(result$`Sum Sq`), 3)
      cat("\nEta-squared:", eta_sq, "\n")
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
  }

  cat("\n")
  invisible(model)
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
#' @param labels Logical. If TRUE (default), prints variable labels
#'   when available.
#'
#' @return Invisibly returns a list containing the correlation matrix,
#'   p-value matrix, and pairwise N matrix.
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
jcorr <- function(data, ..., method = "pearson", labels = TRUE) {

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

  # Apply data pipeline (jcomplete, jfilter)
  pipeline <- .jst_apply_pipeline(data, .jst_data_name, .jst_default_used)
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
  invisible(list(r = r_matrix, p = p_matrix, n = n_matrix, method = method))
}


# -- jlm ----------------------------------------------------------------------

#' SPSS-like linear regression output with standardised coefficients
#'
#' Fits a linear model using \code{stats::lm()} and prints SPSS-style output,
#' including unstandardised coefficients, standard errors, t values, p values,
#' and standardised coefficients ("Std B"). Standardised coefficients are left
#' blank for the intercept and for dummy-coded factor terms.
#'
#' Also prints key model summary information (R-squared, residual standard
#' error, F-test, sums of squares, and N). If any coefficients are dropped
#' due to perfect collinearity, a warning message is printed.
#'
#' A red "Linear Regression" title is printed first, followed by variable
#' labels (if present), then the coefficient table and model fit statistics.
#'
#' Handles haven-labelled variables by converting them appropriately before
#' fitting the model.
#'
#' @param formula A model formula, e.g. \code{y ~ x1 + x2}.
#' @param data A data frame containing variables referenced in \code{formula}.
#' @param labels Logical. If TRUE (default), prints variable labels
#'   when available.
#'
#' @return Invisibly returns a list containing the fitted model, a coefficient
#'   table (data frame), and model fit statistics.
#'
#' @examples
#' # With explicit data frame
#' jlm(mpg ~ hp + wt, data = mtcars)
#'
#' # Using juse() default
#' juse(mtcars)
#' jlm(mpg ~ hp + wt)
#'
#' @export
jlm <- function(formula, data, labels = TRUE) {

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

  # Apply data pipeline (jcomplete, jfilter)
  pipeline <- .jst_apply_pipeline(data, .jst_data_name, .jst_default_used)
  data     <- pipeline$data
  .jst_print_msgs(pipeline$msgs)

  model_vars <- all.vars(formula)

  .jst_check_vars(data, model_vars, .jst_data_name)

  for (v in model_vars) {
    if (haven::is.labelled(data[[v]])) {
      if (v == model_vars[1]) {
        data[[v]] <- as.numeric(data[[v]])
      } else {
        data[[v]] <- haven::as_factor(data[[v]])
      }
    }
  }

  if (labels) {
    .print_var_labels(data, model_vars)
  }

  mf            <- stats::model.frame(formula, data = data, na.action = stats::na.omit)
  n_excluded_na <- nrow(data) - nrow(mf)
  if (n_excluded_na > 0) {
    cat("(", n_excluded_na, " cases excluded due to missing values)\n", sep = "")
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

  p_num <- suppressWarnings(as.numeric(coefs$P))
  p_fmt <- ifelse(!is.na(p_num) & p_num < 0.001, "<.001",
                  ifelse(is.na(p_num), "<.001", sprintf("%.3f", p_num)))

  fmt3 <- function(x) sprintf("%.3f", as.numeric(x))

  out_coefs <- data.frame(
    b       = fmt3(coefs$b),
    StdErr  = fmt3(coefs$StdErr),
    t       = fmt3(coefs$t),
    `Std B` = ifelse(is.na(std_b), "", sprintf("%.3f", as.numeric(std_b))),
    P       = p_fmt,
    stringsAsFactors = FALSE,
    row.names = rownames(coefs)
  )

  r_squared   <- round(model_summary$r.squared, 3)
  residual_se <- round(model_summary$sigma, 3)

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

  cat("\nR-squared: ", sprintf("%.3f", r_squared), "\n", sep = "")
  cat("Residual Standard Error: ", sprintf("%.3f", residual_se), "\n", sep = "")
  cat("\nF-statistic: ", sprintf("%.3f", f_value),
      " on ", df1, " and ", df2,
      " DF, p-value: ", f_p_fmt, "\n", sep = "")
  cat("Sum of Squares:\n")
  cat("  Regression: ", sprintf("%.3f", ss_regression), "\n", sep = "")
  cat("  Residual:   ", sprintf("%.3f", ss_residual),   "\n", sep = "")
  cat("  Total:      ", sprintf("%.3f", ss_total),      "\n", sep = "")
  cat("\nNumber of observations: ", n_obs, "\n", sep = "")

  ret <- list(
    model           = model,
    coefficients    = out_coefs,
    r_squared       = r_squared,
    residual_se     = residual_se,
    f_statistic     = c(value = f_value, df1 = df1, df2 = df2, p = f_p),
    sums_of_squares = c(regression = ss_regression,
                        residual   = ss_residual,
                        total      = ss_total),
    n = n_obs
  )
  cat("\n")
  invisible(ret)
}


# -- jchisq -------------------------------------------------------------------

#' Chi-square test of independence with cross-tabulation
#'
#' Produces an SPSS-style cross-tabulation of two categorical variables
#' with observed frequencies, expected frequencies, row percentages,
#' column percentages, and a chi-square test of independence. Handles
#' haven-labelled, numeric, factor, and character variables.
#' For haven-labelled variables, numeric codes are displayed alongside
#' labels.
#'
#' A red "Chi-Square Analysis" title is printed first, followed by
#' variable labels (if present), then the cross-tabulation and test results.
#'
#' @param formula A formula of the form \code{Row ~ Column}.
#' @param data A data frame containing variables referenced in \code{formula}.
#' @param expected Logical. If TRUE, prints expected frequencies alongside
#'   observed. Default is FALSE.
#' @param row.pct Logical. If TRUE (default), shows row percentages.
#' @param col.pct Logical. If TRUE, shows column percentages. Default is FALSE.
#' @param labels Logical. If TRUE (default), prints variable labels
#'   when available.
#'
#' @return Invisibly returns a list containing the cross-tabulation,
#'   chi-square statistic, degrees of freedom, and p value.
#'
#' @examples
#' # With explicit data frame
#' jchisq(cyl ~ am, data = mtcars)
#' jchisq(cyl ~ am, data = mtcars, expected = TRUE, col.pct = TRUE)
#'
#' # Using juse() default
#' juse(mtcars)
#' jchisq(cyl ~ am)
#' jchisq(cyl ~ am, expected = TRUE)
#'
#' @importFrom stats chisq.test
#' @export
jchisq <- function(formula, data, expected = FALSE, row.pct = TRUE,
                   col.pct = FALSE, labels = TRUE) {

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
  .cat_red("Chi-Square Analysis\n")
  if (.jst_default_used) cat("(Using default data frame:", .jst_data_name, ")\n")

  # Apply data pipeline (jcomplete, jfilter)
  pipeline <- .jst_apply_pipeline(data, .jst_data_name, .jst_default_used)
  data     <- pipeline$data
  .jst_print_msgs(pipeline$msgs)

  # Report cases excluded due to missing values
  n_before_na <- nrow(data)
  complete_on <- data[stats::complete.cases(data[, c(row_name, col_name), drop = FALSE]), , drop = FALSE]
  n_excluded_na <- n_before_na - nrow(complete_on)
  if (n_excluded_na > 0) {
    cat("(", n_excluded_na, " cases excluded due to missing values)\n", sep = "")
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

  cat("\n")
  invisible(list(
    observed   = obs_table,
    expected   = exp_table,
    chi_square = chi_result$statistic,
    df         = chi_result$parameter,
    p          = chi_result$p.value,
    n          = grand_total
  ))
}


# -- jscreen ------------------------------------------------------------------

#' Data screening overview
#'
#' Provides a quick overview of a data frame including the number of
#' cases, variable types, missing data counts and percentages, and
#' potential outliers for numeric variables. Handles haven-labelled
#' variables by reporting their labelled status.
#'
#' A red "Data Screening" title is printed first, followed by a dataset
#' summary, variable labels (if present), and the screening table.
#'
#' @param data A data frame.
#' @param outlier.sd Numeric. Number of standard deviations from the mean
#'   to flag as potential outliers. Default is 3.
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
#'
#' @export
jscreen <- function(data, outlier.sd = 3, labels = TRUE) {

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

  # Red title
  .cat_red("Data Screening\n")
  if (.jst_default_used) cat("(Using default data frame:", .jst_data_name, ")\n")

  # Apply data pipeline (jcomplete, jfilter)
  pipeline <- .jst_apply_pipeline(data, .jst_data_name, .jst_default_used)
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
#' @param labels Logical. If TRUE (default), prints variable labels
#'   when available.
#'
#' @return Invisibly returns a list containing the overall alpha,
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
jalpha <- function(data, ..., labels = TRUE) {

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

  # Red title
  .cat_red("Reliability Analysis\n")
  if (.jst_default_used) cat("(Using default data frame:", .jst_data_name, ")\n")

  # Apply data pipeline (jcomplete, jfilter)
  pipeline <- .jst_apply_pipeline(data, .jst_data_name, .jst_default_used)
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
  invisible(list(
    alpha                 = alpha_overall,
    n_items               = k,
    n_used                = n_used,
    n_excluded            = n_excluded,
    item_statistics       = item_stats,
    item_total_statistics = item_total_table
  ))
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
#' @param var The variable to label (unquoted, e.g. \code{OneParentR}).
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
#'   \code{SampleData$VarName <- jrelabel(SampleData, VarName, ...)}
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
#'   Examples:
#'   \itemize{
#'     \item \code{"1=1; 2=0"}
#'     \item \code{"1=1; 2,3=2; 4,5=3; else=NA"}
#'     \item \code{"1=1; 2=0; else=copy"}
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
#'   \code{SampleData$AgeGroupR <- jrecode(SampleData, AgeGroup, map = "...")}
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
#' # Using juse() default
#' juse(df)
#' df$gearR5 <- jrecode(, gear, map = "3=1; 4=2; 5=3",
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
  unspecified_mask <- !is.na(orig_num) & is.na(new_num)
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


# -- .onUnload ----------------------------------------------------------------

#' Clean up session options when the package is unloaded
#'
#' @keywords internal
.onUnload <- function(libpath) {
  options(.jst_default_data = NULL)
  options(.jst_filter = NULL)
  options(.jst_complete = NULL)
}
