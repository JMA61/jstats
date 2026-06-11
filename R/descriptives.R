#<<<FILE: descriptives.R>>>


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
#' jdesc(community, Age)
#' jdesc(community, Income, Age, WellbeingScore)
#' jdesc(community, WellbeingScore, by = Volunteer)
#'
#' # Using juse() default
#' juse(community)
#' jdesc(Age)
#' jdesc(Income, Age, WellbeingScore)
#' jdesc(WellbeingScore, by = Volunteer)
#'
#' # With a vector directly
#' jdesc(community$Age)
#'
#' @seealso \code{\link{jstats}} for the package overview,
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
  .jst_check_vars(data, check_names, .jst_data_name, default_used = .jst_default_used)

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
    .jst_stop("categorical = is not supported yet: this function always ",
         "computes numeric descriptives.\nFor a categorical summary use ",
         "jfreq() instead.")
  }
  for (.arg in c("numeric", "count")) {
    .val <- get(.arg)
    if (!is.null(.val)) {
      .bad <- setdiff(.val, variable_names)
      if (length(.bad) > 0) {
        .jst_stop(.arg, " argument: ", paste0("'", .bad, "'", collapse = ", "),
             " not found among the variables passed to jdesc(). Check for typos.")
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
      .jst_stop(reasons[[1L]])
    }
    .jst_stop(paste0("None of the requested variables can be summarized with ",
                "descriptive statistics:\n",
                paste0("  - ", reasons, collapse = "\n")))
  }

  # Per-variable notes for a summarized variable: the categorical-like
  # caution (small-range labelled / whole-number 0-6) and the numbers-as-text
  # note. Defined once so both paths warn identically. `dat` is passed
  # explicitly because the data frame is reassigned by the pipeline below.
  .emit_good_notes <- function(v, dat) {
    .ov <- if (v %in% count) "count" else if (v %in% numeric) "numeric" else NULL
    if (.jst_warns_seems_categorical(dat[[v]], v, .jst_data_name,
                                     override = .ov)) {
      warning(.jst_assumption_warning(v, "jdesc"), call. = FALSE)
    }
    if (!is.null(desc_class[[v]]$note)) {
      # Numbers-as-text coercion is pure FYI -- the variable IS summarized as
      # asked -- so it is a default-silent advisory note (full output only).
      .jst_advisory_note(desc_class[[v]]$note)
    }
  }
  # Mixed case: one consequential note per variable that was skipped.
  .emit_bad_refusals <- function() {
    for (v in bad_vars) message(desc_class[[v]]$refusal)
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
#' jfreq(community, Region)
#' jfreq(community, Region, Education)
#'
#' # Using juse() default
#' juse(community)
#' jfreq(Region)
#' jfreq(Region, Education)
#'
#' # With a vector directly
#' jfreq(community$Region)
#'
#' @seealso \code{\link{jstats}} for the package overview,
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
  .jst_check_vars(data, var_names_check, .jst_data_name, default_used = .jst_default_used)

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
#' tendency columns), a Missing Data & Outliers table, and -- when variable
#' labels are shown -- a Variable Labels table last. Handles haven-labelled
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
#' jscreen(community)
#' jscreen(community, outlier.sd = 2.5)
#'
#' # Show the Base R storage type column
#' jscreen(community, r.type = TRUE)
#'
#' # Add Mean and Median columns for numeric-like variables
#' jscreen(community, stats = TRUE)
#'
#' # Suppress tables (header block only)
#' jscreen(community, types = FALSE, issues = FALSE)
#'
#' # Using juse() default
#' juse(community)
#' jscreen()
#' jscreen(Income, Age, WellbeingScore)
#' jscreen(Income, Age, WellbeingScore, subset = Volunteer == 1)
#'
#' @seealso \code{\link{jstats}} for the package overview,
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
    .jst_stop("value.id is not supported here; it does not display ",
         "value labels.")
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
    .jst_check_vars(data, var_names, .jst_data_name, default_used = .jst_default_used)

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

    # Declaration-plausibility heads-up: when the resolved class came from a
    # user registration, check whether the variable's structure is an
    # implausible fit for what was declared (a count with negatives/non-whole/
    # only-two-values, a Likert outside 0-10, a dummy with many categories).
    # Non-blocking -- the declaration still stands; jscreen marks the row "!"
    # and lists the reason below the table. Structural resolutions (the package
    # guessed) are never second-guessed. The intent notebook (jnumeric/jcount/
    # jlikert) carries the kind directly; a registered variable absent from it
    # was registered via jdummy (the separate .jst_dummy registry). (Session 91)
    plaus <- ""
    if (identical(jc$source, "registered")) {
      intent    <- .jst_get_intent(.jst_data_name, v)
      decl_kind <- if (!is.null(intent) && !is.null(intent$kind)) intent$kind
                   else "dummy"
      plaus <- .jst_declaration_plausibility(col, decl_kind)
    }

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
      Plausibility = plaus,
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

    # Non-blocking "!" marker on the Source cell of any row whose registered
    # class is an implausible fit for its data; the reason is listed in the
    # "Unusual declaration" note below the table. A flagged row is always
    # registered, so the Source column is shown. Display-only -- the returned
    # screen_table is untouched. (Session 91)
    if ("Source" %in% cols) {
      flagged_rows <- nzchar(screen_table$Plausibility)
      if (any(flagged_rows))
        t1$Source[flagged_rows] <- paste0(t1$Source[flagged_rows], " !")
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

    # Conditional "Unusual declaration" note: one line per variable whose
    # registered class is an implausible fit for its data. The "!" in the
    # Source column points to the row; this spells out the reason. The
    # declaration still stands -- it is a non-blocking heads-up. (Session 91)
    if (any(nzchar(screen_table$Plausibility))) {
      cat("\n! Unusual declaration for this variable's data:\n")
      for (i in which(nzchar(screen_table$Plausibility))) {
        cat("  ", screen_table$Variable[i], " ",
            screen_table$Plausibility[i], "\n", sep = "")
      }
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
  # Star and Plausibility are internal display flags (the "*" recode marker and
  # the "!" implausible-declaration marker); they are not part of the returned
  # screening results.
  screen_table$Star <- NULL
  screen_table$Plausibility <- NULL
  invisible(screen_table)
}
