#<<<FILE: compare.R>>>


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
#' @details
#' A transformed outcome or grouping term in \code{formula} -- \code{log(x)}
#' and the like -- is computed once on the analysis data and used by both the
#' t-test and the group descriptives, so the two describe the same values.
#' The transforms supported inline, and those that must be created as a
#' column first, are as documented for \code{\link{jlm}}.
#'
#' @param formula A formula of the form \code{DV ~ Group}. A transformed
#'   term such as \code{log(DV)} is computed automatically: the test and
#'   the descriptive output both use the transformed values.
#' @param data A data frame containing variables referenced in \code{formula}.
#' @param paired Logical. If TRUE, runs a paired samples t-test. Cases are
#'   paired by position: the i-th case in one group is matched with the
#'   i-th case in the other, so the two groups must have equal sample
#'   sizes. A pair is dropped from the analysis when either member is
#'   missing (matching how commercial statistical software handles paired
#'   comparisons), and a note reports how many pairs were dropped. Default
#'   is FALSE.
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
#' jt(WellbeingScore ~ Volunteer, data = community)
#' jt(WellbeingScore ~ Volunteer, data = community, welch = TRUE)
#' jt(WellbeingScore ~ Volunteer, data = community, full = TRUE)
#'
#' # Using juse() default
#' juse(community)
#' jt(WellbeingScore ~ Volunteer)
#' jt(WellbeingScore ~ Volunteer, full = TRUE)
#'
#' @seealso \code{\link{jstats}} for the package overview,
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

  # Front-door check: the formula goes first, then the data. A swapped or
  # misplaced formula otherwise crashes deep inside the data pipeline with
  # a raw seq_len() error. (Session 106)
  .jst_check_formula_data(
    formula    = if (missing(formula)) NULL else formula,
    data       = if (missing(data))    NULL else data,
    first_name = if (missing(formula)) NULL else
                   paste(deparse(substitute(formula)), collapse = ""),
    data_name  = if (missing(data))    NULL else
                   paste(deparse(substitute(data)), collapse = ""),
    example    = "DV ~ Group",
    fn         = "jt"
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

  # Raw-name existence check first, so the transform resolver below can
  # assume every plain variable in the formula exists.
  # Underlying variable names (pre-transform). Drives the existence check
  # and, below, the case-processing breakdown -- so a transformed term is
  # reported against its source column, which the pre-pipeline snapshot
  # contains (the computed column is not in that snapshot).
  raw_vars <- all.vars(formula)
  .jst_check_vars(data, raw_vars, .jst_data_name,
                  default_used = .jst_default_used)

  # Transformed-term front door (AUDIT-021): compute log(x), I(x^2), and
  # the like once on the analysis copy and rewrite the formula to reference
  # the computed column, so the t-test (both the independent formula path
  # and the paired by-name path) and the Group Descriptives table describe
  # the same values under the name the user typed.
  resolved <- .jst_resolve_formula_transforms(formula, data, .jst_data_name)
  formula  <- resolved$formula
  data     <- resolved$data

  terms      <- all.vars(formula)
  dv_name    <- terms[1]
  group_name <- terms[2]

  dup_var <- .jst_formula_dup_var(formula)
  if (!is.null(dup_var)) {
    .jst_stop(paste0("'", dup_var, "' appears as both the outcome variable ",
                     "and the grouping variable.\n",
                     "A t-test requires two different variables."))
  }

  .jst_check_dummy_outcome(.jst_data_name, dv_name, "jt")
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
    analysis_vars   = raw_vars,
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
      .jst_stop(paste0("'", group_name, "' has ", n_levels,
                  " category(ies) after applying ", paste(active_steps, collapse = " and "),
                  ". A t-test requires exactly 2. ",
                  "Check whether your jsubset or jcomplete settings ",
                  "are excluding one of the groups."))
    } else {
      .jst_stop(paste0("'", group_name, "' has ", n_levels,
                  " categories. A t-test requires exactly 2. ",
                  "Use jaov() for more than 2 categories."))
    }
  }

  # Assumption-check warning (audit): the outcome looks categorical where a
  # continuous outcome is expected. Likert outcomes and an asserted numeric
  # role are exempt (handled inside .jst_warns_seems_categorical).
  if (.jst_warns_seems_categorical(data[[dv_name]], dv_name, .jst_data_name)) {
    warning(.jst_assumption_warning(dv_name, "jt"), call. = FALSE)
  }

  if (haven::is.labelled(data[[dv_name]])) {
    data[[dv_name]] <- .jst_as_numeric(data[[dv_name]])
  }

  levels      <- levels(data[[group_name]])
  # which() (rather than direct logical indexing) keeps rows with a missing
  # grouping value out of the extraction entirely -- a logical index of NA
  # would insert a phantom NA element into BOTH group vectors, corrupting
  # positional pairing in the paired branch below.
  group1_data <- data[[dv_name]][which(data[[group_name]] == levels[1])]
  group2_data <- data[[dv_name]][which(data[[group_name]] == levels[2])]

  if (paired) {
    # Pair-before-filter (AUDIT-001). Pairing is positional: the i-th case
    # of each group forms pair i. Pairs must be formed on the raw group
    # vectors and THEN dropped when either member is missing; filtering
    # each group's NAs separately (the pre-fix behavior) silently re-paired
    # the survivors by position, matching values across the wrong cases.
    # This matches t.test(x, y, paired = TRUE)'s own complete-pairs
    # handling and the SPSS T-TEST PAIRS convention. Cohen's dz and the
    # Group Descriptives table use the same paired-complete vectors, so
    # both reflect the pairs actually analyzed.
    if (length(group1_data) != length(group2_data)) {
      .jst_stop("A paired t-test requires the same number of cases in each group.\n",
                "\"", levels[1], "\" has ", length(group1_data), " cases; \"",
                levels[2], "\" has ", length(group2_data), ".")
    }
    pair_complete   <- !is.na(group1_data) & !is.na(group2_data)
    n_pairs_dropped <- sum(!pair_complete)
    group1_data     <- group1_data[pair_complete]
    group2_data     <- group2_data[pair_complete]

    if (length(group1_data) < 2) {
      .jst_stop("A paired t-test requires at least 2 complete pairs; only ",
                length(group1_data),
                if (length(group1_data) == 1) " remains" else " remain",
                " after removing pairs with a missing value.")
    }

    if (n_pairs_dropped > 0) {
      message("Note: ", n_pairs_dropped,
              if (n_pairs_dropped == 1) " pair" else " pairs",
              " removed because a measurement was missing.")
    }
  } else {
    group1_data <- group1_data[!is.na(group1_data)]
    group2_data <- group2_data[!is.na(group2_data)]
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
    # Degenerate-differences guard (AUDIT-001): with zero variation in the
    # paired differences the t statistic is undefined. Base R's t.test()
    # stops with a raw "data are essentially constant" error for constant
    # nonzero differences and silently returns NaN for all-zero
    # differences; both routes land here instead, in house voice. The
    # near-constant arm mirrors base R's own threshold so its raw error
    # can never surface.
    diffs  <- group1_data - group2_data
    d_mean <- mean(diffs)
    d_se   <- stats::sd(diffs) / sqrt(length(diffs))
    if (d_se == 0 || d_se < 10 * .Machine$double.eps * abs(d_mean)) {
      .jst_stop("Every pair has the same difference, so a paired t-test cannot be computed.")
    }
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
#' @details
#' A transformed outcome or grouping term in \code{formula} -- \code{log(x)}
#' and the like -- is computed once on the analysis data and used by the F
#' test, Levene's test, the post hoc comparisons, and the descriptives, so
#' they all describe the same values. The transforms supported inline, and
#' those that must be created as a column first, are as documented for
#' \code{\link{jlm}}.
#'
#' @param formula A formula of the form \code{DV ~ Group}. A transformed
#'   term such as \code{log(DV)} is computed automatically: the tests and
#'   the descriptive output all use the transformed values.
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
#' jaov(WellbeingScore ~ Region, data = community)
#' jaov(WellbeingScore ~ Region, data = community, welch = TRUE)
#' jaov(WellbeingScore ~ Region, data = community, full = TRUE)
#'
#' # Using juse() default
#' juse(community)
#' jaov(WellbeingScore ~ Region)
#' jaov(WellbeingScore ~ Region, full = TRUE)
#'
#' @seealso \code{\link{jstats}} for the package overview,
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

  # Front-door check: the formula goes first, then the data. A swapped or
  # misplaced formula otherwise crashes deep inside the data pipeline with
  # a raw seq_len() error. (Session 106)
  .jst_check_formula_data(
    formula    = if (missing(formula)) NULL else formula,
    data       = if (missing(data))    NULL else data,
    first_name = if (missing(formula)) NULL else
                   paste(deparse(substitute(formula)), collapse = ""),
    data_name  = if (missing(data))    NULL else
                   paste(deparse(substitute(data)), collapse = ""),
    example    = "DV ~ Group",
    fn         = "jaov"
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

  # Raw-name existence check first, so the transform resolver below can
  # assume every plain variable in the formula exists.
  # Underlying variable names (pre-transform). Drives the existence check
  # and, below, the case-processing breakdown -- so a transformed term is
  # reported against its source column, which the pre-pipeline snapshot
  # contains (the computed column is not in that snapshot).
  raw_vars <- all.vars(formula)
  .jst_check_vars(data, raw_vars, .jst_data_name,
                  default_used = .jst_default_used)

  # Transformed-term front door (AUDIT-021): compute log(x), I(x^2), and
  # the like once on the analysis copy and rewrite the formula to reference
  # the computed column, so the F test, Levene's test, the post hoc
  # comparisons, and the descriptives all describe the same values under
  # the name the user typed.
  resolved <- .jst_resolve_formula_transforms(formula, data, .jst_data_name)
  formula  <- resolved$formula
  data     <- resolved$data

  terms      <- all.vars(formula)
  dv_name    <- terms[1]
  group_name <- terms[2]

  dup_var <- .jst_formula_dup_var(formula)
  if (!is.null(dup_var)) {
    .jst_stop(paste0("'", dup_var, "' appears as both the outcome variable ",
                     "and the grouping variable.\n",
                     "An ANOVA requires two different variables."))
  }

  .jst_check_dummy_outcome(.jst_data_name, dv_name, "jaov")
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
    analysis_vars   = raw_vars,
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
      .jst_stop(paste0("'", group_name, "' has ", n_levels,
                  " category(ies) after applying ", paste(active_steps, collapse = " and "),
                  ". An ANOVA requires at least 2. ",
                  "Check whether your jsubset or jcomplete settings ",
                  "are excluding one or more groups."))
    } else {
      .jst_stop(paste0("'", group_name, "' has ", n_levels,
                  " category(ies). An ANOVA requires at least 2 groups."))
    }
  }

  # Degenerate-grouping guard (Session 105): when every category contains
  # exactly one analysis case, within-group variance is undefined and the
  # computation falls through to a raw base R error ("non-numeric argument
  # to mathematical function", with qt NaN warnings). The typical cause is
  # a continuous variable supplied as the grouping variable. Counted on the
  # analysis rows (mf), so listwise deletion is respected. A mix of
  # singleton and larger cells is legitimate unbalanced data and passes.
  grp_sizes <- table(as.character(mf[[group_name]]))
  if (length(grp_sizes) > 0 && max(grp_sizes) == 1L) {
    .jst_stop(paste0("'", group_name, "' has ", length(grp_sizes),
                " categories with only 1 case in each.\n",
                "An ANOVA requires at least one category with 2 or more ",
                "cases - '", group_name, "' may be a continuous variable ",
                "rather than a grouping variable."))
  }

  # Assumption-check warning (audit): the outcome looks categorical where a
  # continuous outcome is expected. Likert outcomes and an asserted numeric
  # role are exempt (handled inside .jst_warns_seems_categorical).
  if (.jst_warns_seems_categorical(data[[dv_name]], dv_name, .jst_data_name)) {
    warning(.jst_assumption_warning(dv_name, "jaov"), call. = FALSE)
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
#' percentages, expected frequencies, adjusted standardized residuals,
#' and a chi-square test of independence are available via arguments. Handles haven-labelled,
#' numeric, factor, and character variables. For haven-labelled
#' variables, numeric codes are displayed alongside labels.
#'
#' A red "Cross-Tabulation" title is printed first, followed by
#' variable labels (if present), then the table and optional test results.
#'
#' @param formula A formula of the form \code{Row ~ Column}, naming plain
#'   variables. Transformed terms such as \code{log(x)} are not supported
#'   here -- create the variable first (e.g. with \code{cut()} for
#'   binning), then cross-tabulate it.
#' @param data A data frame containing variables referenced in \code{formula}.
#' @param chisq Logical. If TRUE, prints the chi-square test of independence
#'   below the cross-tabulation. For a 2x2 table, two rows are shown --
#'   the Pearson chi-square and the Yates continuity-corrected chi-square --
#'   matching the rows commercial statistical software reports; the Pearson
#'   row is the headline result and is what the returned object carries.
#'   Larger tables show the single Pearson result (the correction applies
#'   only to 2x2 tables). Default is FALSE.
#' @param expected Logical. If TRUE, prints expected frequencies alongside
#'   observed. Default is FALSE.
#' @param row.pct Logical. If TRUE (default), shows row percentages.
#' @param col.pct Logical. If TRUE, shows column percentages. Default is FALSE.
#' @param residuals Character. Cell residuals to display: \code{"none"}
#'   (default) or \code{"adjusted"}. \code{"adjusted"} adds an
#'   \code{(Adj.Res.)} line to each cell showing the adjusted standardized
#'   (Haberman) residual: (observed - expected) divided by its standard
#'   error. Under independence these are approximately standard normal, so a
#'   value beyond +/-1.96 flags a cell whose count departs from expected at
#'   the .05 level. This localizes a significant chi-square to individual
#'   cells, and matches the "Adjusted standardized" residual in SPSS
#'   CROSSTABS. At \code{joutput("full")} the residual cells are flagged
#'   (\code{*} past +/-1.96, \code{**} past the Bonferroni cutoff) and an
#'   interpretation note is printed below the table naming both thresholds.
#'   Not a logical.
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
#'   frequency table), \code{adjusted_residuals} (matrix of adjusted
#'   standardized residuals), \code{n} (total N), \code{model_frame} (the
#'   analysis data frame used for plotting), \code{sample_info} (pipeline and
#'   missing data counts), and if \code{chisq = TRUE}: \code{chi_square},
#'   \code{df}, and \code{p} (the Pearson chi-square), \code{chi_method}
#'   (the test's method string), and for 2x2 tables
#'   \code{chi_square_corrected} and \code{p_corrected} (the Yates
#'   continuity-corrected values).
#'
#' @examples
#' # Cross-tabulation only
#' jcrosstab(Education ~ Volunteer, data = community)
#'
#' # With chi-square test
#' jcrosstab(Education ~ Volunteer, data = community, chisq = TRUE)
#'
#' # With expected frequencies and column percentages
#' jcrosstab(Education ~ Volunteer, data = community,
#'           expected = TRUE, col.pct = TRUE)
#'
#' # With adjusted standardized residuals (interpretation note at full output)
#' jcrosstab(Education ~ Volunteer, data = community, residuals = "adjusted")
#'
#' # Using juse() default
#' juse(community)
#' jcrosstab(Education ~ Volunteer)
#' jcrosstab(Education ~ Volunteer, chisq = TRUE)
#'
#' @seealso \code{\link{jstats}} for the package overview,
#'   workflow conventions, and complete function listing.
#'
#' @importFrom stats chisq.test qnorm
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
                      row.pct = TRUE, col.pct = FALSE, residuals = "none",
                      subset = NULL,
                      variable.id = NULL, value.id = NULL,
                      case.processing.detail = NULL, digits = NULL) {

  digits_n <- .jst_resolve_digits(digits)

  # Front-door check: the formula goes first, then the data. A swapped or
  # misplaced formula otherwise crashes deep inside the data pipeline with
  # a raw seq_len() error. (Session 106)
  .jst_check_formula_data(
    formula    = if (missing(formula)) NULL else formula,
    data       = if (missing(data))    NULL else data,
    first_name = if (missing(formula)) NULL else
                   paste(deparse(substitute(formula)), collapse = ""),
    data_name  = if (missing(data))    NULL else
                   paste(deparse(substitute(data)), collapse = ""),
    example    = "RowVar ~ ColVar",
    fn         = "jcrosstab"
  )

  # Validate the residuals display mode (choice-error house form, Rule A).
  if (length(residuals) != 1L || !is.character(residuals) ||
      !residuals %in% c("none", "adjusted")) {
    .jst_stop_arg(fn = "jcrosstab", arg = "residuals",
                  choices = c("none", "adjusted"))
  }
  show_adj_res <- identical(residuals, "adjusted")

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

  dup_var <- .jst_formula_dup_var(formula)
  if (!is.null(dup_var)) {
    .jst_stop(paste0("'", dup_var, "' appears on both sides of the formula.\n",
                     "A cross-tabulation requires two different variables."))
  }

  .jst_check_vars(data, terms, .jst_data_name, default_used = .jst_default_used)
  # Transformed-term front door (AUDIT-021): a cross-tabulation needs plain
  # variables. Pre-check, a term like log(x) was silently ignored -- table()
  # pulls columns by name, so the raw column was tabulated as if the
  # transform had not been written. Refuse it clearly instead. (The analysis
  # functions with a numeric response resolve such terms via
  # .jst_resolve_formula_transforms; here a numeric transform of a
  # categorical variable has no cross-tabulation meaning.)
  .jst_check_formula_transforms(formula, .jst_data_name)
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
      .jst_stop(paste0("'", check_info$name, "' has ", length(check_info$lvls),
                  " category(ies)", context,
                  ". A cross-tabulation requires at least 2 categories ",
                  "for each variable."))
    }
  }

  row_labels <- if (row_labelled) .jst_format_value_labels(row_codes, row_vl, value_mode) else row_levels
  col_labels <- if (col_labelled) .jst_format_value_labels(col_codes, col_vl, value_mode) else col_levels

  obs_table  <- table(row_var, col_var)
  # Headline test is the uncorrected Pearson chi-square (AUDIT-006): base R's
  # chisq.test() default silently applies the Yates continuity correction to
  # 2x2 tables, which diverges from the headline number SPSS, Stata, and SAS
  # report. For a 2x2 table the Yates-corrected companion is computed too and
  # printed as a second row, SPSS-style; correct= has no effect on larger
  # tables, so it is computed only there. Expected counts and adjusted
  # residuals do not depend on the correction.
  chi_result <- suppressWarnings(stats::chisq.test(obs_table, correct = FALSE))
  is_2x2     <- all(dim(obs_table) == 2L)
  chi_corrected <- if (is_2x2) {
    suppressWarnings(stats::chisq.test(obs_table, correct = TRUE))
  } else {
    NULL
  }
  exp_table  <- chi_result$expected

  p_val <- chi_result$p.value
  p_fmt <- .jst_fmt_p(p_val)

  n_rows <- length(row_levels)
  n_cols <- length(col_levels)

  # Adjusted-residual significance markers (full output only): * past the
  # +/-1.96 reference, ** past the per-table Bonferroni cutoff. The two
  # thresholds nest, so ** implies *. bonf is reused by the note below.
  n_cells      <- n_rows * n_cols
  bonf         <- stats::qnorm(1 - 0.05 / (2 * n_cells))
  mark_adj_res <- show_adj_res &&
                  identical(getOption(".jst_output_level", "standard"), "full")

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

    if (show_adj_res) {
      adj_vals <- chi_result$stdres[i, ]
      adj_str  <- sprintf("%.*f", digits_n, adj_vals)
      if (mark_adj_res) {
        abs_d   <- abs(adj_vals)
        marks   <- ifelse(abs_d > bonf, " **",
                          ifelse(abs_d > 1.96, " *", ""))
        adj_str <- paste0(adj_str, marks)
      }
      display_rows <- c(display_rows,
                        list(c("  (Adj.Res.)", adj_str, "")))
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
    if (is_2x2) {
      # 2x2: two rows, SPSS-style -- Pearson is the headline, the Yates
      # continuity-corrected value beneath it.
      chi_table <- data.frame(
        Test       = c("Pearson", "Continuity Correction"),
        Chi_Square = sprintf("%.*f", digits_n,
                             c(chi_result$statistic, chi_corrected$statistic)),
        df         = c(chi_result$parameter, chi_corrected$parameter),
        p          = c(p_fmt, .jst_fmt_p(chi_corrected$p.value)),
        N          = c(grand_total, grand_total),
        stringsAsFactors = FALSE,
        row.names  = NULL
      )

      .jst_print_table(chi_table,
                       caption   = "Chi-Square Test of Independence",
                       col.names = c("Test", "Chi-Square", "df", "p", "N"),
                       align     = c("l", "c", "c", "c", "c"),
                       row.names = FALSE)
    } else {
      chi_table <- data.frame(
        Chi_Square = sprintf("%.*f", digits_n, chi_result$statistic),
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
    }

    min_expected <- min(exp_table)
    n_below_5    <- sum(exp_table < 5)
    if (n_below_5 > 0) {
      cat(paste0("\nNote: ", n_below_5, " cell(s) have expected frequencies less than 5 ",
                 "(minimum expected = ", round(min_expected, 1), "). ",
                 "Chi-square results may not be reliable.\n"))
    }
  }

  # Adjusted-residual interpretation note (advisory: shown at joutput("full")
  # only). States the z-reference rule, names the cell markers, and gives a
  # Bonferroni-adjusted cutoff -- the familywise correction SPSS CROSSTABS
  # omits. n_cells / bonf are computed once above.
  if (show_adj_res) {
    .jst_advisory_note(
      "Note: Adjusted residuals are approximately normal under independence.\n",
      "A value beyond +/-1.96 (marked *) departs from expected at p < .05.\n",
      "With ", n_cells, " cells, a Bonferroni-adjusted cutoff is +/-",
      sprintf("%.2f", bonf), " (marked **)."
    )
  }

  .jst_print_legends(lab_src, c(row_name, col_name), c(row_name, col_name),
                     vlmode, value_mode)

  cat("\n")

  ret <- list(
    observed           = obs_table,
    expected           = exp_table,
    adjusted_residuals = chi_result$stdres,
    n                  = grand_total,
    model_frame        = mf,
    sample_info        = sample_info
  )
  if (chisq) {
    ret$chi_square <- chi_result$statistic
    ret$df         <- chi_result$parameter
    ret$p          <- chi_result$p.value
    ret$chi_method <- chi_result$method
    if (is_2x2) {
      ret$chi_square_corrected <- chi_corrected$statistic
      ret$p_corrected          <- chi_corrected$p.value
    }
  }
  class(ret) <- "jst_crosstab"
  invisible(ret)
}
