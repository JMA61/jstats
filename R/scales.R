#<<<FILE: scales.R>>>


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
    # An empty positional slot (stray comma) arrives as a missing quosure;
    # touching its expression via quo_get_expr() below would throw R's raw
    # "argument is missing, with no default" error. Pass it through as ""
    # so the caller's .jst_check_vars blank-name guard reports it in the
    # one consistent voice. (Session 106; Session 23 to-do item.)
    if (rlang::quo_is_missing(q)) {
      var_names   <- c(var_names, "")
      label_parts <- c(label_parts, "")
      next
    }

    expr <- rlang::quo_get_expr(q)

    if (is.call(expr) && identical(expr[[1]], as.name(":"))) {
      # Colon notation: var1:var6
      start_name <- as.character(expr[[2]])
      end_name   <- as.character(expr[[3]])

      start_idx <- match(start_name, all_cols)
      end_idx   <- match(end_name, all_cols)

      if (is.na(start_idx)) {
        .jst_stop(
          "Variable '", start_name, "' not found in ", frame_ref, ".\n",
          "Check spelling and capitalization."
        )
      }
      if (is.na(end_idx)) {
        .jst_stop(
          "Variable '", end_name, "' not found in ", frame_ref, ".\n",
          "Check spelling and capitalization."
        )
      }

      if (start_idx > end_idx) {
        .jst_stop(
          "In ", start_name, ":", end_name, ", '", start_name,
          "' comes after '", end_name, "' in the column order of ", frame_ref, ".\n",
          "Reverse the order: ", end_name, ":", start_name
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
#' # Set the default data frame (so you can omit it in function calls)
#' juse(community)
#'
#' # Sum three variables (all must be non-missing)
#' community$EnvTotal <- jsum(Environment1, Environment3, Environment4)
#'
#' # Sum with partial data allowed (at least 2 non-missing)
#' community$EnvTotal <- jsum(Environment1, Environment3, Environment4,
#'                            min.valid = 2)
#'
#' # Sum using colon range for consecutive columns
#' community$EnvTotal <- jsum(Environment1:Environment5)
#'
#' # Mix colon ranges and explicit names (e.g. after reverse-coding an item)
#' community$Environment2R <- jrecode(community, Environment2,
#'                                    map = "1=5; 2=4; 3=3; 4=2; 5=1")
#' community$ScaleTotal <- jsum(Environment1, Environment2R,
#'                              Environment3:Environment5)
#'
#' # With a custom variable label
#' community$ScaleTotal <- jsum(Environment1:Environment5,
#'                              var.label = "Environment Scale Total")
#'
#' # With an explicit data frame (instead of using juse default)
#' community$EnvTotal <- jsum(community, Environment1, Environment3,
#'                            Environment4)
#'
#' # Not normally needed. You'd clear a default or registration only to
#' # undo a mistake, or -- as in this example -- to reset state for testing.
#' juse(NULL)
#'
#' @seealso \code{\link{javg}} for computing row-wise means.
#' @seealso \code{\link{jstats}} for the package overview,
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
  .jst_default_used <- arg1$mode %in% c("default", "symbol_with_default")

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
    .jst_stop("At least 2 variables are required.")
  }

  .jst_check_vars(data, var_names, .jst_data_name, default_used = .jst_default_used)

  # Assumption-check warning (audit): nudge only on a declared contradiction --
  # a variable the user registered as categorical via jdummy() and is now
  # summing. Structural categoricals (e.g. a labelled nominal), counts, Likert
  # items, and logicals stay silent: combining small-integer items is the point
  # of jsum(), so the warning fires only when the categorical intent is explicit.
  .dummy_regs <- .jst_get_dummy(.jst_data_name)
  if (!is.null(.dummy_regs) && length(.dummy_regs) > 0) {
    for (v in var_names) {
      if (any(vapply(.dummy_regs,
                     function(r) identical(r$var_name, v), logical(1)))) {
        warning(.jst_assumption_warning(v, "jsum"), call. = FALSE)
      }
    }
  }

  # Extract columns. Mask declared SPSS-form UDM cells to NA on this
  # analysis-only copy BEFORE stripping the haven class, so declared
  # missing codes (e.g. -98) are excluded rather than summed as literal
  # data. The user's data frame is unchanged (na_values / na_range stay
  # attached for round-trip fidelity). Stata-form tagged NAs need no
  # masking -- they satisfy is.na() natively and survive
  # .jst_as_numeric() as NA, so the non-missing count already excludes
  # them. Applies the SPSS-UDM auto-conversion helper directly rather
  # than routing through .jst_apply_pipeline, whose jsubset/jcomplete
  # filtering would drop rows and misalign this row-wise result with
  # the data frame.
  items     <- data[, var_names, drop = FALSE]
  .udm_conv <- .jst_apply_declared_udms_as_na(items)
  items     <- .udm_conv$data
  for (v in var_names) {
    items[[v]] <- .jst_as_numeric(items[[v]])
  }

  n_vars  <- length(var_names)
  n_cases <- nrow(items)

  # Determine minimum valid threshold
  if (is.null(min.valid)) {
    threshold <- n_vars   # Default: all must be non-missing
  } else {
    if (!is.numeric(min.valid) || length(min.valid) != 1L ||
        is.na(min.valid) || min.valid != as.integer(min.valid) ||
        min.valid < 1) {
      .jst_stop_arg("jsum", "min.valid", "a positive integer.")
    }
    threshold <- as.integer(min.valid)
    if (threshold > n_vars) {
      .jst_stop(
        "min.valid (", threshold, ") cannot exceed the number of variables (",
        n_vars, ")."
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

  # Headline: mean of the resulting values (joutput digits; suppressed when
  # every case came out NA, so the message never shows "Mean: NaN").
  if (n_valid > 0L) {
    digits_n <- .jst_resolve_digits(NULL)
    headline_mean <- sprintf(paste0("%.", digits_n, "f"), mean(result, na.rm = TRUE))
    msg_parts <- paste0(msg_parts,
                        "\nMean of the new variable: ", headline_mean, ".")
  }
  message(msg_parts)

  # Default-silent FYI (joutput "full" only): if declared SPSS-style
  # missing values were masked above, report where, mirroring how the
  # analysis pipeline surfaces its auto-conversions. SPSS is silent
  # here too, so this stays off at standard/minimal.
  if (length(.udm_conv$converted) > 0) {
    conv_parts <- vapply(names(.udm_conv$converted), function(v) {
      nc <- .udm_conv$converted[[v]]$n_cells
      paste0(v, " (", nc, " cell", if (nc != 1L) "s" else "", ")")
    }, character(1))
    .jst_advisory_note(paste0(
      "\nNote: declared SPSS-style missing values were treated as missing ",
      "for this calculation - ", paste(conv_parts, collapse = ", "), "."
    ))
  }

  # Assign-or-lose reminder (standard + full): jsum() returns the totals
  # invisibly, so an unassigned top-level call silently drops them. The
  # leading blank line keeps it clear of any advisory note above (Rule F).
  if (!identical(getOption(".jst_output_level", "standard"), "minimal")) {
    message(
      "\nNote: jsum() returns the totals; assign them to a column to keep them:\n",
      "  ", .jst_data_name, "$<name> <- jsum(...)\n",
      "For the full distribution (min, max, SD), run jdesc() on the new column."
    )
  }

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
#' # Set the default data frame (so you can omit it in function calls)
#' juse(community)
#'
#' # Mean of three variables (all must be non-missing)
#' community$EnvAvg <- javg(Environment1, Environment3, Environment4)
#'
#' # Mean with partial data allowed (at least 2 non-missing)
#' community$EnvAvg <- javg(Environment1, Environment3, Environment4,
#'                          min.valid = 2)
#'
#' # Mean using colon range for consecutive columns
#' community$ScaleMean <- javg(Environment1:Environment5)
#'
#' # Mix colon ranges and explicit names (e.g. after reverse-coding an item)
#' community$Environment2R <- jrecode(community, Environment2,
#'                                    map = "1=5; 2=4; 3=3; 4=2; 5=1")
#' community$ScaleMean <- javg(Environment1, Environment2R,
#'                             Environment3:Environment5)
#'
#' # Fixed denominator (always divide by total number of variables)
#' community$EnvAvg <- javg(Environment1, Environment3, Environment4,
#'                          min.valid = 2, fixed = TRUE)
#'
#' # With a custom variable label
#' community$ScaleMean <- javg(Environment1:Environment5,
#'                             var.label = "Environment Scale Mean")
#'
#' # With an explicit data frame (instead of using juse default)
#' community$EnvAvg <- javg(community, Environment1, Environment3,
#'                          Environment4)
#'
#' # Not normally needed. You'd clear a default or registration only to
#' # undo a mistake, or -- as in this example -- to reset state for testing.
#' juse(NULL)
#'
#' @seealso \code{\link{jsum}} for computing row-wise sums.
#' @seealso \code{\link{jstats}} for the package overview,
#'   workflow conventions, and complete function listing.
#'
#' @export
javg <- function(data, ..., min.valid = NULL, fixed = FALSE, var.label = NULL) {
  # Validate TRUE/FALSE flags up front.
  .jst_check_flag(fixed, "fixed")

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
  .jst_default_used <- arg1$mode %in% c("default", "symbol_with_default")

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
    .jst_stop("At least 2 variables are required.")
  }

  .jst_check_vars(data, var_names, .jst_data_name, default_used = .jst_default_used)

  # Assumption-check warning (audit): nudge only on a declared contradiction --
  # a variable the user registered as categorical via jdummy() and is now
  # averaging. Structural categoricals (e.g. a labelled nominal), counts, Likert
  # items, and logicals stay silent: combining small-integer items is the point
  # of javg(), so the warning fires only when the categorical intent is explicit.
  .dummy_regs <- .jst_get_dummy(.jst_data_name)
  if (!is.null(.dummy_regs) && length(.dummy_regs) > 0) {
    for (v in var_names) {
      if (any(vapply(.dummy_regs,
                     function(r) identical(r$var_name, v), logical(1)))) {
        warning(.jst_assumption_warning(v, "javg"), call. = FALSE)
      }
    }
  }

  # Extract columns. Mask declared SPSS-form UDM cells to NA on this
  # analysis-only copy BEFORE stripping the haven class, so declared
  # missing codes (e.g. -98) are excluded rather than summed as literal
  # data. The user's data frame is unchanged (na_values / na_range stay
  # attached for round-trip fidelity). Stata-form tagged NAs need no
  # masking -- they satisfy is.na() natively and survive
  # .jst_as_numeric() as NA, so the non-missing count already excludes
  # them. Applies the SPSS-UDM auto-conversion helper directly rather
  # than routing through .jst_apply_pipeline, whose jsubset/jcomplete
  # filtering would drop rows and misalign this row-wise result with
  # the data frame.
  items     <- data[, var_names, drop = FALSE]
  .udm_conv <- .jst_apply_declared_udms_as_na(items)
  items     <- .udm_conv$data
  for (v in var_names) {
    items[[v]] <- .jst_as_numeric(items[[v]])
  }

  n_vars  <- length(var_names)
  n_cases <- nrow(items)

  # Determine minimum valid threshold
  if (is.null(min.valid)) {
    threshold <- n_vars   # Default: all must be non-missing
  } else {
    if (!is.numeric(min.valid) || length(min.valid) != 1L ||
        is.na(min.valid) || min.valid != as.integer(min.valid) ||
        min.valid < 1) {
      .jst_stop_arg("javg", "min.valid", "a positive integer.")
    }
    threshold <- as.integer(min.valid)
    if (threshold > n_vars) {
      .jst_stop(
        "min.valid (", threshold, ") cannot exceed the number of variables (",
        n_vars, ")."
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

  # Headline: mean of the resulting values (joutput digits; suppressed when
  # every case came out NA, so the message never shows "Mean: NaN").
  if (n_valid > 0L) {
    digits_n <- .jst_resolve_digits(NULL)
    headline_mean <- sprintf(paste0("%.", digits_n, "f"), mean(result, na.rm = TRUE))
    msg_parts <- paste0(msg_parts,
                        "\nMean of the new variable: ", headline_mean, ".")
  }
  message(msg_parts)

  # Default-silent FYI (joutput "full" only): if declared SPSS-style
  # missing values were masked above, report where, mirroring how the
  # analysis pipeline surfaces its auto-conversions. SPSS is silent
  # here too, so this stays off at standard/minimal.
  if (length(.udm_conv$converted) > 0) {
    conv_parts <- vapply(names(.udm_conv$converted), function(v) {
      nc <- .udm_conv$converted[[v]]$n_cells
      paste0(v, " (", nc, " cell", if (nc != 1L) "s" else "", ")")
    }, character(1))
    .jst_advisory_note(paste0(
      "\nNote: declared SPSS-style missing values were treated as missing ",
      "for this calculation - ", paste(conv_parts, collapse = ", "), "."
    ))
  }

  # Assign-or-lose reminder (standard + full): javg() returns the scores
  # invisibly, so an unassigned top-level call silently drops them. The
  # leading blank line keeps it clear of any advisory note above (Rule F).
  if (!identical(getOption(".jst_output_level", "standard"), "minimal")) {
    message(
      "\nNote: javg() returns the scores; assign them to a column to keep them:\n",
      "  ", .jst_data_name, "$<name> <- javg(...)\n",
      "For the full distribution (min, max, SD), run jdesc() on the new column."
    )
  }

  # Attach variable label
  if (!is.null(var.label)) {
    labelled::var_label(result) <- var.label
  } else {
    auto_label <- paste0("Mean of ", paste(label_parts, collapse = ", "))
    labelled::var_label(result) <- auto_label
  }

  return(invisible(result))
}
