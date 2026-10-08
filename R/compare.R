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
#' A value or vector from your workspace may be named inside a computed
#' term, as in \code{lm()}: \code{I(x > cutoff)} with \code{cutoff <- 10}.
#' A data frame may not: write \code{y ~ x} with \code{data = MyData},
#' not \code{MyData$y ~ MyData$x}.
#' A vector used value by value with the data, as in \code{I(x * w)},
#' must hold one value for each case -- each row of \code{data} left
#' after filtering -- where \code{lm()} would recycle a shorter one; a
#' set used with \code{\%in\%} may have any length.
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
#'   (equal variances assumed). If TRUE, runs Welch's t-test, which needs
#'   at least 2 cases in each group; Student's test can include a group of
#'   one case. Ignored when paired = TRUE.
#' @param effect.size Logical or NULL. If TRUE, prints Cohen's d. If NULL
#'   (default), defers to \code{joutput()} session setting.
#' @param diagnostics Logical, \code{"levene"}, or NULL. If TRUE (or
#'   \code{"levene"}), prints Levene's test for homogeneity of variance,
#'   with a note under it when the test is significant (see "Unequal
#'   variances"). Not applicable when paired = TRUE. If NULL (default),
#'   defers to \code{joutput()}'s \code{diagnostics} setting, which is off
#'   at every output level until it is set.
#' @param ci Logical or NULL. If TRUE, adds 95% confidence interval for the
#'   mean difference. If NULL (default), defers to \code{joutput()}.
#' @param subset An optional unquoted logical expression (e.g.
#'   \code{Group == 1}) to subset cases for this call only. Applied after
#'   jcomplete and jsubset. Does not affect other function calls.
#'   Written in R syntax and checked the way \code{jsubset()} checks a
#'   filter: \code{subset = NOT(Age < 40)}, for example, is refused with
#'   the corrected \code{subset = !(Age < 40)} shown (see
#'   \code{\link{jsubset}} for a translation table).
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
#' @param full Logical. If TRUE, turns on effect.size and ci together.
#'   Does not override explicit FALSE values, and does not turn on
#'   diagnostics, which \code{diagnostics} alone governs.
#' @param ... Reserved for argument-name checking. Passing \code{levene},
#'   the name of the diagnostics setting before version 0.9.219, produces
#'   an error that names \code{diagnostics}.
#'
#' @section Unequal variances:
#' Student's t-test assumes the two groups have the same variance, and
#' Levene's test (\code{diagnostics = TRUE}) asks whether they do. When it
#' is significant, a note under its table states the two things that
#' decide how much that matters -- the ratio of the larger group's size to
#' the smaller, and of the larger standard deviation to the smaller -- and
#' then takes one of three forms. Textbooks give different guidelines and
#' no single cutoff is agreed, so the note does not treat one as exact:
#' \itemize{
#'   \item Stevens (\emph{Intermediate Statistics: A Modern Approach};
#'     \emph{Applied Multivariate Statistics for the Social Sciences})
#'     holds that unequal variances distort the test appreciably only when
#'     the larger group is more than 1.5 times the smaller.
#'   \item Moore, McCabe and Craig (\emph{Introduction to the Practice of
#'     Statistics}) treat results as approximately correct while the
#'     largest standard deviation is less than twice the smallest, a rule
#'     they state for the analysis of variance; Howell (\emph{Statistical
#'     Methods for Psychology}) gives the same limit as a variance ratio of
#'     four and adds that unequal variances and unequal group sizes do not
#'     mix.
#' }
#' The note reads "usually still acceptable" when the larger group is no
#' more than 1.25 times the smaller and the larger standard deviation no
#' more than twice the smaller; it says the p-value may not be reliable
#' when the group sizes differ by more than 1.5 times and the standard
#' deviations by more than twice; and between the two it says that
#' guidelines differ. The 1.25 is not a textbook figure. It comes from
#' simulations run for jstats (a true null hypothesis, normal scores, a
#' nominal 5 percent level, the smaller group the more variable): in the
#' cases tried, Student's test rejected up to about 7 percent of the time
#' inside the first range, up to about 10 percent in the middle one, and
#' about 14 to 15 percent in the last. Two groups of the same size are the
#' most forgiving case: the rate stayed near 5 percent with one standard
#' deviation up to three times the other. The direction matters: when the
#' LARGER group is the more variable, the test rejects too rarely
#' instead. Welch's t-test (\code{welch = TRUE}) does not assume equal
#' variances. The note is not printed at \code{joutput("minimal")}, which
#' prints the table alone.
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
#' # Checking the equal-variances assumption: Levene's test
#' jt(WellbeingScore ~ Volunteer, data = community, diagnostics = TRUE)
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
#'   uses the active \code{joutput()} level default. The Case
#'   Processing table itself prints only when a filter or listwise
#'   deletion excluded cases; otherwise a one-line N statement takes its
#'   place. See \code{?joutput} (\code{case.processing}).
jt <- function(formula, data, paired = FALSE, welch = FALSE,
               effect.size = NULL, diagnostics = NULL, ci = NULL,
               subset = NULL, variable.id = NULL, value.id = NULL,
               case.processing.detail = NULL, full = FALSE, digits = NULL,
               ...) {
  # Validate TRUE/FALSE flags up front (display toggles also accept
  # NULL, meaning defer to joutput()).
  .jst_check_flag(paired, "paired")
  .jst_check_flag(welch, "welch")
  .jst_check_flag(full, "full")
  .jst_check_flag(effect.size, "effect.size", null.ok = TRUE)
  .jst_check_flag(ci, "ci", null.ok = TRUE)
  # levene = was the name of this setting until v0.9.219.
  .jst_check_args(list(...), aliases = c(levene = "diagnostics"),
                  fn_name = "jt")

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
    if (is.null(ci))          ci          <- TRUE
  }

  # Resolve display toggles: per-call > joutput() toggle > joutput() level
  effect.size <- .jst_resolve_toggle("effect.size", effect.size)
  ci          <- .jst_resolve_toggle("means.ci",    ci)
  # Diagnostics are apart from the levels and from full = TRUE (Session
  # 346): the call's own diagnostics =, else joutput()'s, else off.
  levene      <- "levene" %in% .jst_resolve_diagnostics(diagnostics, "jt")
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
  # contains (the computed column is not in that snapshot). Since Session
  # 323 the names are read as lm() reads them: a constant named inside a
  # computed term (I(x > cutoff)) resolves in the formula's environment and
  # is left out of the list; a bare name is still a variable, and a name
  # found nowhere still stops. A data frame named inside a term, and a power
  # terms() cannot read (y ~ x^k), are refused here.
  raw_vars <- .jst_check_formula_vars(
    formula, data, .jst_data_name, default_used = .jst_default_used,
    n_frame = pipeline$pipeline_counts$n_original)

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
    n_analysis      = nrow(mf),
    transform_na    = resolved$introduced_na
  )

  # Case Processing Summary
  .jst_print_case_processing(sample_info, analysis_type = "listwise", detail = case.processing.detail)

  # No case left: one stop, ahead of the group count (Session 346).
  .jst_stop_empty_sample(sample_info)

  # A text grouping variable's blank cells are one group, <blank> (S340).
  group_var   <- .jst_label_blanks(data[[group_name]])

  # A group is counted on the cases the test can use (Session 346). A group
  # whose cases are all missing on the outcome was still counted: with two
  # groups in the data the descriptives printed its row with N 0 and R
  # stopped on "grouping factor must have exactly 2 levels", and with three
  # the test was refused as an ANOVA's although two groups had cases. Not
  # for a paired test, which pairs the two groups' rows by position before
  # it drops a pair with a missing value (AUDIT-001).
  n_groups_data <- length(unique(unclass(group_var)[!is.na(group_var)]))
  if (!paired) group_var[is.na(data[[dv_name]])] <- NA

  is_labelled <- haven::is.labelled(group_var)
  if (is_labelled) {
    original_codes <- .jst_group_codes(group_var)
    group_val_labels <- labelled::val_labels(group_var)
  }

  if (is_labelled) {
    data[[group_name]] <- haven::as_factor(group_var)
  } else {
    data[[group_name]] <- if (is.factor(group_var)) group_var
                          else .jst_text_factor(group_var)
  }

  # Drop empty factor levels (pipeline filtering may leave empty levels)
  data[[group_name]] <- droplevels(data[[group_name]])

  n_levels <- nlevels(data[[group_name]])
  # Said under a group count that missing data lowered, so the count can be
  # squared with the categories the variable holds.
  uncounted <- if (n_levels < n_groups_data) {
    paste0("\nCases with a missing '", dv_name, "' are not counted.")
  }
  if (n_levels != 2) {
    # The count agrees in number (voice Rule O, .jst_plural()) and each
    # sentence takes a line (Rule E). More than 2 categories and fewer are
    # different mistakes (Session 338): only the first is jaov()'s case,
    # and only the second can come from a stored setting excluding a group
    # (.jst_settings_context()). Until then a single category with the
    # frame named in the call read "has 1 categories ... Use jaov() for
    # more than 2 categories."
    has <- paste0("'", group_name, "' has ", n_levels, " ",
                  .jst_plural(n_levels, "category", "categories"))
    if (n_levels > 2) {
      .jst_stop(has, ".\n",
                "A t-test requires exactly 2.\n",
                "Use jaov() for more than 2 categories.")
    }
    # A filter that names the grouping variable kept one category of it
    # (Session 346): the stop said "'g' has 1 category" and nothing of the
    # filter that was its whole cause.
    fn <- .jst_filters_naming(group_name, sample_info, .jst_data_name)
    if (n_groups_data == 1L && (fn$per || fn$stored)) {
      .jst_stop(.jst_filter_keeps(fn), " only 1 category of '", group_name,
                "', and a t-test requires exactly 2.\n",
                .jst_filter_way_out(fn, .jst_data_name,
                                    "To compare the categories"))
    }
    context <- .jst_settings_context(.jst_data_name)
    .jst_stop(has, context, ".\n",
              "A t-test requires exactly 2.",
              uncounted,
              if (nzchar(context)) {
                paste0("\nCheck whether your jsubset or jcomplete settings ",
                       "are excluding one of the groups.")
              })
  }

  # Groups the test cannot be computed on (Session 346; the S341 item, the
  # jt() sibling of jaov()'s one-case stops). Each of these reached R:
  # Welch's test with a group of one case stopped on "not enough 'y'
  # observations" after the descriptives had printed, two groups of one
  # case each on "not enough observations", and two groups with no
  # variation between them on "data are essentially constant". Stopped
  # here, before any table. A paired test has its own checks, on the pairs.
  if (!paired) {
    shape <- .jst_group_shape(
      if (haven::is.labelled(data[[dv_name]])) .jst_as_numeric(data[[dv_name]])
      else data[[dv_name]],
      data[[group_name]])
    solo <- names(shape$n)[shape$n == 1L]
    if (length(solo) == 2L) {
      .jst_stop("'", group_name, "' has 2 categories with only 1 case in ",
                "each.\n",
                "A t-test requires at least one category with 2 or more ",
                "cases.")
    }
    if (welch && length(solo) == 1L) {
      .jst_stop("'", group_name, "' has 1 category with only 1 case (", solo,
                ").\n",
                "Welch's t-test requires at least 2 cases in both ",
                "categories.\n",
                "Student's t-test can include it: run jt() without ",
                "welch = TRUE.")
    }
    # No variation to test against: the standard error of the difference is
    # zero. t.test()'s own threshold, so its error can never surface.
    n_g  <- as.numeric(shape$n)
    v_g  <- ifelse(n_g > 1, as.numeric(shape$var), 0)
    se_d <- if (welch) {
      sqrt(sum(v_g / n_g))
    } else {
      sqrt(sum((n_g - 1) * v_g) / (sum(n_g) - 2) * sum(1 / n_g))
    }
    if (se_d < 10 * .Machine$double.eps * max(abs(as.numeric(shape$mean)))) {
      .jst_stop("'", dv_name, "' has the same value for every case in each ",
                "category of '", group_name, "'.\n",
                "A t-test requires variation within at least one category.")
    }
  }

  # Assumption-check warning (audit): the outcome looks categorical where a
  # continuous outcome is expected. Likert outcomes and an asserted numeric
  # role are exempt (handled inside .jst_warns_seems_categorical).
  if (.jst_warns_seems_categorical(data[[dv_name]], dv_name, .jst_data_name)) {
    .jst_warn(.jst_assumption_warning(dv_name, "jt"))
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
      .jst_msg("Note: ", n_pairs_dropped,
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

    # Block-centered columns and trimmed lines (Session 327): each header
    # centered over its column, each value right-justified in a block
    # centered under it. On the default alignment F (numeric) sat flush
    # right and p (text) flush left.
    .jst_print_table(levene_table,
                     caption = "Levene's Test for Homogeneity of Variance",
                     col.names = c("F", "df1", "df2", "p"),
                     row.names = FALSE,
                     align = rep("bc", 4L),
                     digits = c(F_value = digits_n))

    # The note under a significant test, in one of three forms (Session
    # 346; .jst_levene_note()). Not when Welch's test is the one run.
    if (!welch) .jst_levene_note(levene_p, dv_vals, group_factor, "jt")
    cat("\n")
  } else if (levene && paired) {
    .jst_msg("Note: Levene's test is not applicable for paired samples.")
    cat("\n")
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

  # The group labels flush left, the numeric columns block-centered, no
  # line ending in padding (Session 327).
  .jst_print_table(desc_table,
                   caption = paste("Group Descriptives:", dv_disp, "by", group_disp),
                   row.names = FALSE,
                   align = c("l", rep("bc", 3L)),
                   digits = c(Mean = digits_n, SD = digits_n))
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

  # Decimal places by column (Session 326): the statistics at digits, with
  # trailing zeros kept; Welch's df keeps its one-place convention (57.0).
  # Student's and the paired df are whole numbers and print as such.
  test_digits <- c(t = digits_n, Mean_Difference = digits_n)
  if (welch && !paired) test_digits <- c(test_digits, df = 1L)

  if (ci) {
    test_table$CI_Lower <- round(result$conf.int[1], digits_n)
    test_table$CI_Upper <- round(result$conf.int[2], digits_n)
    test_digits <- c(test_digits, CI_Lower = digits_n, CI_Upper = digits_n)
  }

  if (paired) {
    test_label <- "Paired Samples T-Test Results"
  } else if (welch) {
    test_label <- "Welch's T-Test Results (equal variances not assumed)"
  } else {
    test_label <- "Independent Samples T-Test Results (equal variances assumed)"
  }

  # Every column block-centered, the lines trimmed (Session 327): p is
  # text, so the default alignment left-justified it beside right-justified
  # statistics.
  if (ci) {
    .jst_print_table(test_table,
                     caption = test_label,
                     col.names = c("t", "df", "p", "Mean Difference",
                                   "95% CI Lower", "95% CI Upper"),
                     row.names = FALSE,
                     align = rep("bc", 6L),
                     digits = test_digits)
  } else {
    .jst_print_table(test_table,
                     caption = test_label,
                     col.names = c("t", "df", "p", "Mean Difference"),
                     row.names = FALSE,
                     align = rep("bc", 4L),
                     digits = test_digits)
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
    # The pooled SD, as the test above pooled it. A group of one case has
    # no SD of its own and adds nothing to the sum of squares -- its term
    # is (1 - 1) * s^2 -- so d is defined by the other group's SD; taking
    # the term through R gave 0 * NA and "Cohen's d: NA" (Session 346; the
    # S341 item). effectsize::cohens_d() pools the same way.
    ss1      <- if (n1 > 1L) (n1 - 1) * s1^2 else 0
    ss2      <- if (n2 > 1L) (n2 - 1) * s2^2 else 0
    sp       <- sqrt((ss1 + ss2) / (n1 + n2 - 2))
    cohens_d <- (m1 - m2) / sp
    d_label  <- "Cohen's d"
  }

  # The value to digits places, trailing zeros kept (0.230, not 0.23).
  # (Session 326)
  if (effect.size) {
    cat(paste0("\n", d_label, ": ", .jst_fmt_stat(cohens_d, digits_n), "\n"))
  }

  leg <- .jst_print_legends(lab_src, c(dv_name, group_name), group_name,
                            vlmode, value_mode)

  n_analysis <- nrow(mf)

  # One closing blank line (Session 328): a legend block ends on its own.
  if (!leg) cat("\n")
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
#' for the Welch correction when equal variances cannot be assumed; its
#' post-hoc test is Games-Howell.
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
#' A value or vector from your workspace may be named inside a computed
#' term, as in \code{lm()}: \code{I(x > cutoff)} with \code{cutoff <- 10}.
#' A data frame may not: write \code{y ~ x} with \code{data = MyData},
#' not \code{MyData$y ~ MyData$x}.
#' A vector used value by value with the data, as in \code{I(x * w)},
#' must hold one value for each case -- each row of \code{data} left
#' after filtering -- where \code{lm()} would recycle a shorter one; a
#' set used with \code{\%in\%} may have any length.
#'
#' @param formula A formula of the form \code{DV ~ Group}. A transformed
#'   term such as \code{log(DV)} is computed automatically: the tests and
#'   the descriptive output all use the transformed values.
#' @param data A data frame containing variables referenced in \code{formula}.
#' @param welch Logical. If FALSE (default), runs traditional ANOVA.
#'   If TRUE, runs Welch's ANOVA (does not assume equal variances). Welch's
#'   F is not a ratio of two mean squares, so its table shows F, df1, df2
#'   and p: Sum of Squares and Mean Square belong to the traditional ANOVA
#'   table and are not applicable to Welch's test. Welch's ANOVA needs at
#'   least 2 cases in every group, and some variation within every group:
#'   a group whose cases all hold one value has a variance of zero, which
#'   Welch's F divides by. The traditional ANOVA can include such a group,
#'   or a group of one case.
#' @param posthoc Logical or NULL. If TRUE, prints pairwise comparisons of
#'   the group means: Tukey HSD for the traditional ANOVA, and Games-Howell
#'   when welch = TRUE. Games-Howell does not assume equal variances: each
#'   comparison uses the two groups' own variances and its own degrees of
#'   freedom, shown in a df column, and the p-values and confidence
#'   intervals are adjusted for the number of groups through the
#'   studentized range distribution, as Tukey's are. Commercial
#'   statistical software offers the same test for unequal variances
#'   (Games-Howell in SPSS's ONEWAY post-hoc tests). A Games-Howell
#'   comparison with fewer than 2 degrees of freedom -- possible when a
#'   group has two or three cases -- shows its difference and its df and
#'   leaves its interval and p-value blank, with a line under the table
#'   saying so: the studentized range distribution is not defined there.
#'   With two groups no post-hoc table is printed or returned, after
#'   either ANOVA: the test above it is the only comparison.
#'   If NULL (default), defers to \code{joutput()}.
#' @param effect.size Logical or NULL. If TRUE, prints eta-squared. If NULL
#'   (default), defers to \code{joutput()}.
#' @param diagnostics Logical, \code{"levene"}, or NULL. If TRUE (or
#'   \code{"levene"}), prints Levene's test for homogeneity of variance,
#'   with a note under it when the test is significant (see "Unequal
#'   variances"). If NULL (default), defers to \code{joutput()}'s
#'   \code{diagnostics} setting, which is off at every output level until
#'   it is set.
#' @param ci Logical or NULL. If TRUE, adds 95% confidence intervals to the
#'   group descriptives table. If NULL (default), defers to \code{joutput()}.
#' @param subset An optional unquoted logical expression (e.g.
#'   \code{Group == 1}) to subset cases for this call only. Applied after
#'   jcomplete and jsubset. Does not affect other function calls.
#'   Written in R syntax and checked the way \code{jsubset()} checks a
#'   filter: \code{subset = NOT(Age < 40)}, for example, is refused with
#'   the corrected \code{subset = !(Age < 40)} shown (see
#'   \code{\link{jsubset}} for a translation table).
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
#' @param full Logical. If TRUE, turns on posthoc, effect.size and ci
#'   together. Does not override explicit FALSE values, and does not turn
#'   on diagnostics, which \code{diagnostics} alone governs.
#' @param ... Reserved for argument-name checking. Passing \code{levene},
#'   the name of the diagnostics setting before version 0.9.219, produces
#'   an error that names \code{diagnostics}.
#'
#' @section Unequal variances:
#' The traditional ANOVA assumes the groups have the same variance, and
#' Levene's test (\code{diagnostics = TRUE}) asks whether they do. When it
#' is significant, a note under its table states the two things that
#' decide how much that matters -- the ratio of the largest group's size to
#' the smallest, and of the largest standard deviation to the smallest --
#' and then takes one of three forms. Textbooks give different guidelines
#' and no single cutoff is agreed, so the note does not treat one as
#' exact:
#' \itemize{
#'   \item Stevens (\emph{Applied Multivariate Statistics for the Social
#'     Sciences}; \emph{Intermediate Statistics: A Modern Approach}) treats
#'     the F test as robust to unequal variances while the largest group is
#'     less than 1.5 times the smallest.
#'   \item Moore, McCabe and Craig (\emph{Introduction to the Practice of
#'     Statistics}) treat the results as approximately correct while the
#'     largest standard deviation is less than twice the smallest; Howell
#'     (\emph{Statistical Methods for Psychology}) gives the same limit as
#'     a variance ratio of four and adds that unequal variances and unequal
#'     group sizes do not mix.
#' }
#' The note reads "usually still acceptable" when the largest group is no
#' more than 1.25 times the smallest and the largest standard deviation no
#' more than twice the smallest; it says the p-value may not be reliable
#' when the group sizes differ by more than 1.5 times and the standard
#' deviations by more than twice; and between the two it says that
#' guidelines differ. The 1.25 is not a textbook figure. It comes from
#' simulations run for jstats (a true null hypothesis, normal scores, a
#' nominal 5 percent level, four groups, the smallest group the most
#' variable): in the cases tried, the traditional ANOVA rejected up to
#' about 7.5 percent of the time inside the first range, about 7 to 13
#' percent in the middle one, and 13 to 16 percent in the last. The
#' direction matters: those figures are for the worst case, and when the
#' LARGEST group is the most variable the rate is lower, falling under 5
#' percent where the sizes are clearly unequal. Welch's ANOVA
#' (\code{welch = TRUE}) does not assume equal variances. The note is not
#' printed at \code{joutput("minimal")}, which prints the table alone.
#'
#' @return Invisibly returns a list of class \code{jst_anova} containing:
#'   \code{model} (the \code{aov} or \code{oneway.test} object),
#'   \code{model_frame} (the analysis data frame used for plotting),
#'   \code{test_type}, \code{formula}, \code{descriptives}, \code{f},
#'   \code{df1}, \code{df2}, \code{p}, \code{eta_squared}, \code{n},
#'   \code{sample_info} (pipeline and missing data counts), and
#'   \code{posthoc} (the pairwise comparisons as an unrounded data frame,
#'   with \code{test} naming the method; \code{NULL} when post-hoc tests
#'   were not requested).
#'
#' @examples
#' # With explicit data frame
#' jaov(WellbeingScore ~ Region, data = community)
#' jaov(WellbeingScore ~ Region, data = community, full = TRUE)
#'
#' # Checking the equal-variances assumption: Levene's test
#' jaov(WellbeingScore ~ Region, data = community, diagnostics = TRUE)
#'
#' # Pairwise comparisons after the traditional ANOVA: Tukey HSD
#' jaov(WellbeingScore ~ Region, data = community, posthoc = TRUE)
#'
#' # When equal variances cannot be assumed: Welch's ANOVA
#' jaov(WellbeingScore ~ Region, data = community, welch = TRUE)
#'
#' # Pairwise comparisons after Welch's ANOVA: Games-Howell
#' jaov(WellbeingScore ~ Region, data = community, welch = TRUE,
#'      posthoc = TRUE)
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
#' @importFrom stats aov oneway.test TukeyHSD qt ptukey qtukey
#' @param digits Integer or NULL. Number of decimal places for continuous
#'   statistics in the output tables (range 0-7; \code{digits = 0} prints
#'   whole numbers with no trailing decimal point). Does not affect p-values,
#'   percentages, or integer quantities (counts, N, degrees of freedom),
#'   which keep their own fixed conventions. NULL (default) defers to
#'   \code{joutput()}'s \code{digits} setting (default 3).
#' @param case.processing.detail Per-call override of the Case
#'   Processing Summary detail tier: one of \code{"none"},
#'   \code{"totals"}, or \code{"per_code"}. \code{NULL} (default)
#'   uses the active \code{joutput()} level default. The Case
#'   Processing table itself prints only when a filter or listwise
#'   deletion excluded cases; otherwise a one-line N statement takes its
#'   place. See \code{?joutput} (\code{case.processing}).
jaov <- function(formula, data, welch = FALSE, posthoc = NULL,
                 effect.size = NULL, diagnostics = NULL, ci = NULL,
                 subset = NULL, variable.id = NULL, value.id = NULL,
                 case.processing.detail = NULL, full = FALSE, digits = NULL,
                 ...) {
  # Validate TRUE/FALSE flags up front (display toggles also accept
  # NULL, meaning defer to joutput()).
  .jst_check_flag(welch, "welch")
  .jst_check_flag(full, "full")
  .jst_check_flag(effect.size, "effect.size", null.ok = TRUE)
  .jst_check_flag(ci, "ci", null.ok = TRUE)
  .jst_check_flag(posthoc, "posthoc", null.ok = TRUE)
  # levene = was the name of this setting until v0.9.219.
  .jst_check_args(list(...), aliases = c(levene = "diagnostics"),
                  fn_name = "jaov")

  digits_n    <- .jst_resolve_digits(digits)
  posthoc_tbl <- NULL

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
    if (is.null(ci))          ci          <- TRUE
  }

  # Resolve display toggles: per-call > joutput() toggle > joutput() level
  effect.size  <- .jst_resolve_toggle("effect.size", effect.size)
  ci           <- .jst_resolve_toggle("means.ci",   ci)
  posthoc      <- .jst_resolve_toggle("posthoc",     posthoc)
  # Diagnostics are apart from the levels and from full = TRUE (Session
  # 346): the call's own diagnostics =, else joutput()'s, else off.
  levene       <- "levene" %in% .jst_resolve_diagnostics(diagnostics, "jaov")
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
  # contains (the computed column is not in that snapshot). Since Session
  # 323 the names are read as lm() reads them: a constant named inside a
  # computed term (I(x > cutoff)) resolves in the formula's environment and
  # is left out of the list; a bare name is still a variable, and a name
  # found nowhere still stops. A data frame named inside a term, and a power
  # terms() cannot read (y ~ x^k), are refused here.
  raw_vars <- .jst_check_formula_vars(
    formula, data, .jst_data_name, default_used = .jst_default_used,
    n_frame = pipeline$pipeline_counts$n_original)

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
    n_analysis      = nrow(mf),
    transform_na    = resolved$introduced_na
  )

  # Case Processing Summary
  .jst_print_case_processing(sample_info, analysis_type = "listwise", detail = case.processing.detail)

  # No case left: one stop, ahead of the group count (Session 346).
  .jst_stop_empty_sample(sample_info)

  # A text grouping variable's blank cells are one group, <blank> (S340).
  group_var   <- .jst_label_blanks(data[[group_name]])

  # A group is counted on the cases the test can use, as in jt() (Session
  # 346): a group whose cases are all missing on the outcome printed a
  # descriptives row with N 0, and with two groups in the data R stopped on
  # "contrasts can be applied only to factors with 2 or more levels".
  n_groups_data <- length(unique(unclass(group_var)[!is.na(group_var)]))
  group_var[is.na(data[[dv_name]])] <- NA

  is_labelled <- haven::is.labelled(group_var)
  if (is_labelled) {
    original_codes <- .jst_group_codes(group_var)
    group_val_labels <- labelled::val_labels(group_var)
  }

  if (is_labelled) {
    data[[group_name]] <- haven::as_factor(group_var)
  } else {
    data[[group_name]] <- if (is.factor(group_var)) group_var
                          else .jst_text_factor(group_var)
  }

  # Drop empty factor levels (pipeline filtering may leave empty levels)
  data[[group_name]] <- droplevels(data[[group_name]])

  # Check minimum group levels
  n_levels <- nlevels(data[[group_name]])
  if (n_levels < 2) {
    # Number agreement and one sentence per line, as in jt() (Session 338).
    has <- paste0("'", group_name, "' has ", n_levels, " ",
                  .jst_plural(n_levels, "category", "categories"))
    uncounted <- if (n_levels < n_groups_data) {
      paste0("\nCases with a missing '", dv_name, "' are not counted.")
    }
    # A filter that names the grouping variable kept one category of it
    # (Session 346), as in jt().
    fn <- .jst_filters_naming(group_name, sample_info, .jst_data_name)
    if (n_levels == 1L && n_groups_data == 1L && (fn$per || fn$stored)) {
      .jst_stop(.jst_filter_keeps(fn), " only 1 category of '", group_name,
                "', and an ANOVA requires at least 2.\n",
                .jst_filter_way_out(fn, .jst_data_name,
                                    "To compare the categories"))
    }
    context <- .jst_settings_context(.jst_data_name)
    if (nzchar(context)) {
      .jst_stop(has, context, ".\n",
                "An ANOVA requires at least 2.",
                uncounted, "\n",
                "Check whether your jsubset or jcomplete settings ",
                "are excluding one or more groups.")
    }
    .jst_stop(has, ".\n",
              "An ANOVA requires at least 2 groups.",
              uncounted)
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
                "cases -- '", group_name, "' may be a continuous variable ",
                "rather than a grouping variable."))
  }

  # A one-case group under Welch (Session 341; the Session 105 item's Welch
  # half). Welch's F weights each group by n / variance, and one case has no
  # variance: oneway.test() stopped with R's own "not enough observations",
  # after the title and the descriptives had printed. The traditional ANOVA
  # pools the variance and runs with such a group, so it is the way out.
  if (welch) {
    # Counted on the converted grouping variable, so a labelled group is
    # named by its label, as the comparison tables name it.
    solo_n <- table(data[[group_name]][!is.na(data[[dv_name]])])
    solo   <- names(solo_n)[solo_n == 1L]
    if (length(solo) > 0L) {
      .jst_stop(
        "'", group_name, "' has ", length(solo), " ",
        .jst_plural(length(solo), "category", "categories"),
        " with only 1 case (", .jst_format_var_list(solo, and = TRUE), ").\n",
        "Welch's ANOVA requires at least 2 cases in every category.\n",
        "The standard ANOVA can include ",
        .jst_plural(length(solo), "it", "them"),
        ": run jaov() without welch = TRUE.")
    }
  }

  # No variation inside the groups (Session 346; the S341 constant-group
  # item). With every group constant the residual sum of squares is zero
  # and the traditional F is a rounding error over nothing: it printed as
  # 27815876027865139260134097158144.000. With one group constant Welch's F
  # weights that group by n / 0, and its table printed with blank F, df2
  # and p cells; the traditional ANOVA pools the variance and runs. A group
  # of one case is not counted here: it has no variance to be zero.
  shape <- .jst_group_shape(
    if (haven::is.labelled(data[[dv_name]])) .jst_as_numeric(data[[dv_name]])
    else data[[dv_name]],
    data[[group_name]])
  if (all(shape$flat | shape$n == 1L)) {
    .jst_stop("'", dv_name, "' has the same value for every case in each ",
              "category of '", group_name, "'.\n",
              "An ANOVA requires variation within at least one category.")
  }
  if (welch && any(shape$flat)) {
    flat <- names(shape$flat)[shape$flat]
    .jst_stop(
      "'", group_name, "' has ", length(flat), " ",
      .jst_plural(length(flat), "category", "categories"),
      " in which '", dv_name, "' does not vary (",
      .jst_format_var_list(flat, and = TRUE), ").\n",
      "Welch's ANOVA requires variation within every category.\n",
      "The standard ANOVA can include ",
      .jst_plural(length(flat), "it", "them"),
      ": run jaov() without welch = TRUE.")
  }

  # Assumption-check warning (audit): the outcome looks categorical where a
  # continuous outcome is expected. Likert outcomes and an asserted numeric
  # role are exempt (handled inside .jst_warns_seems_categorical).
  if (.jst_warns_seems_categorical(data[[dv_name]], dv_name, .jst_data_name)) {
    .jst_warn(.jst_assumption_warning(dv_name, "jaov"))
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

    # Block-centered columns and trimmed lines (Session 327): each header
    # centered over its column, each value right-justified in a block
    # centered under it. On the default alignment F (numeric) sat flush
    # right and p (text) flush left.
    .jst_print_table(levene_table,
                     caption = "Levene's Test for Homogeneity of Variance",
                     col.names = c("F", "df1", "df2", "p"),
                     row.names = FALSE,
                     align = rep("bc", 4L),
                     digits = c(F_value = digits_n))

    # The note under a significant test, in one of three forms (Session
    # 346; .jst_levene_note()). Not when Welch's test is the one run.
    if (!welch) .jst_levene_note(levene_p, dv_vals, group_factor, "jaov")
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
      # A one-case group has no SD and no interval: its cells are blank, as
      # in SPSS. qt() at 0 degrees of freedom gave NaN with R's own "NaNs
      # produced" warning above the table (Session 341; the Session 105
      # item).
      se     <- s / sqrt(n)
      t_crit <- if (n > 1L) stats::qt(0.975, df = n - 1) else NA_real_
      row$CI_Lower <- round(m - t_crit * se, digits_n)
      row$CI_Upper <- round(m + t_crit * se, digits_n)
    }

    row
  })
  desc_table <- do.call(rbind, desc_rows)

  # Every statistic to digits places, trailing zeros kept (Session 326).
  # The group labels flush left, the numeric columns block-centered, no
  # line ending in padding (Session 327).
  if (ci) {
    .jst_print_table(desc_table,
                     caption = paste("Group Descriptives:", dv_disp, "by", group_disp),
                     col.names = c("Group", "N", "Mean", "SD",
                                   "95% CI Lower", "95% CI Upper"),
                     row.names = FALSE,
                     align = c("l", rep("bc", 5L)),
                     digits = c(Mean = digits_n, SD = digits_n,
                                CI_Lower = digits_n, CI_Upper = digits_n))
  } else {
    .jst_print_table(desc_table,
                     caption = paste("Group Descriptives:", dv_disp, "by", group_disp),
                     row.names = FALSE,
                     align = c("l", rep("bc", 3L)),
                     digits = c(Mean = digits_n, SD = digits_n))
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

    # F to digits places; Welch's df2 keeps its one-place convention (50.3,
    # 57.0); df1 is a whole number. (Session 326) Every column
    # block-centered, the lines trimmed. (Session 327)
    .jst_print_table(welch_table,
                     caption = paste("Welch's ANOVA:", dv_disp, "by", group_disp),
                     col.names = c("F", "df1", "df2", "p"),
                     row.names = FALSE,
                     align = rep("bc", 4L),
                     digits = c(F_value = digits_n, df2 = 1L))

    # "Not applicable", not "not available" (Session 327; wording approved
    # by Jeff): Welch's F is a variance-weighted between-groups term over a
    # correction factor, not a ratio of two mean squares, so the test has no
    # Sum of Squares or Mean Square -- "not available" read as a gap in
    # jstats. Both notes now go through the stdout emitter, so they wrap by
    # width like the Levene notes above.
    .jst_msg_out("\nNote: Sum of Squares and Mean Square are not applicable ",
                 "to Welch's ANOVA.\n",
                 "For the standard ANOVA table, run jaov() without ",
                 "welch = TRUE.")

    # Always compute eta-squared (from traditional SS decomposition)
    temp_model  <- stats::aov(formula, data = data)
    temp_result <- summary(temp_model)[[1]]
    eta_sq      <- temp_result$`Sum Sq`[1] / sum(temp_result$`Sum Sq`)

    # The value to digits places, trailing zeros kept (0.100, not 0.1), and
    # no space before the line end. (Session 326)
    if (effect.size) {
      cat("\nEta-squared: ", .jst_fmt_stat(eta_sq, digits_n), "\n", sep = "")
      cat("(Note: Eta-squared is calculated from the traditional SS decomposition.)\n")
    }

    # Games-Howell (Session 341; the S327 item). Tukey HSD rests on the
    # pooled error term, which Welch's test sets aside, and until 0.9.215 a
    # note said so and offered nothing. The table takes the Tukey table's
    # form and place, with the df each comparison was judged on.
    if (posthoc && n_levels == 2L) {
      .jst_posthoc_two_groups()
    } else if (posthoc) {
      posthoc_tbl <- .jst_games_howell(data[[dv_name]], data[[group_name]])
      gh_table <- data.frame(
        Comparison = posthoc_tbl$comparison,
        Difference = round(posthoc_tbl$diff,  digits_n),
        CI_Lower   = round(posthoc_tbl$lower, digits_n),
        CI_Upper   = round(posthoc_tbl$upper, digits_n),
        df         = round(posthoc_tbl$df, 1),
        p_adj      = .jst_fmt_p(posthoc_tbl$p),
        stringsAsFactors = FALSE,
        row.names  = NULL
      )
      cat("\n")
      # df at Welch's one place, as df2 above; the rest as the Tukey table.
      .jst_print_table(gh_table,
                       caption = "Games-Howell Post-Hoc Comparisons",
                       col.names = c("Comparison", "Mean Difference",
                                     "95% CI Lower", "95% CI Upper",
                                     "df", "p (adjusted)"),
                       row.names = FALSE,
                       align = c("l", rep("bc", 5L)),
                       digits = c(Difference = digits_n, CI_Lower = digits_n,
                                  CI_Upper = digits_n, df = 1L))
      # Why a row's interval and p cells are blank (Session 346).
      n_low <- sum(!is.na(posthoc_tbl$df) & is.na(posthoc_tbl$p))
      if (n_low > 0L) {
        .jst_msg_out(
          "\nNote: ", n_low, " ",
          .jst_plural(n_low,
                      "comparison has fewer than 2 degrees of freedom, so its ",
                      "comparisons have fewer than 2 degrees of freedom, so their "),
          .jst_plural(n_low, "confidence interval and p-value",
                      "confidence intervals and p-values"),
          " cannot be computed.")
      }
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

    # One precision per kind of statistic (Session 326): Sum of Squares,
    # Mean Square and F all at digits places, so the between-groups SS and
    # MS of a one-df effect -- the same number -- read alike (682.770 and
    # 682.770, where per-column detection printed 682.770 beside 682.77).
    # Source flush left; df, the statistics and p block-centered, so F and
    # p sit under centered headers and a wide header (Sum of Squares) sits
    # over its values; the Residual and Total rows end at their last value,
    # with no padding after it. (Session 327)
    .jst_print_table(anova_table,
                     caption = paste("ANOVA:", dv_disp, "by", group_disp),
                     col.names = c("Source", "df", "Sum of Squares",
                                   "Mean Square", "F", "p"),
                     row.names = FALSE,
                     align = c("l", rep("bc", 5L)),
                     digits = c(Sum_of_Squares = digits_n,
                                Mean_Square = digits_n, F_value = digits_n))

    # Always compute eta-squared
    eta_sq <- result$`Sum Sq`[1] / sum(result$`Sum Sq`)

    # The value to digits places, trailing zeros kept, and no space before
    # the line end. (Session 326)
    if (effect.size) {
      cat("\nEta-squared: ", .jst_fmt_stat(eta_sq, digits_n), "\n", sep = "")
    }

    if (posthoc && n_levels == 2L) {
      .jst_posthoc_two_groups()
    } else if (posthoc) {
      tukey        <- stats::TukeyHSD(model)
      tukey_result <- as.data.frame(tukey[[1]])

      tukey_p     <- tukey_result$`p adj`
      tukey_p_fmt <- .jst_fmt_p(tukey_p)
      posthoc_tbl <- data.frame(
        comparison = rownames(tukey_result),
        diff       = tukey_result$diff,
        lower      = tukey_result$lwr,
        upper      = tukey_result$upr,
        df         = result$Df[2],
        p          = tukey_p,
        test       = "Tukey HSD",
        stringsAsFactors = FALSE
      )

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
      # Comparison flush left, the rest block-centered and the lines
      # trimmed (Session 327): the adjusted p-values are right-justified in
      # their block, so 1.000 lines up on the decimal point with .976.
      .jst_print_table(tukey_table,
                       caption = "Tukey HSD Post-Hoc Comparisons",
                       col.names = c("Comparison", "Mean Difference",
                                     "95% CI Lower", "95% CI Upper",
                                     "p (adjusted)"),
                       row.names = FALSE,
                       align = c("l", rep("bc", 4L)),
                       digits = c(Difference = digits_n, CI_Lower = digits_n,
                                  CI_Upper = digits_n))
    }

    # Store F, df, p for the return object
    f_value <- result$`F value`[1]
    df1     <- result$Df[1]
    df2     <- result$Df[2]
    p_value <- result$`Pr(>F)`[1]
  }

  leg <- .jst_print_legends(lab_src, c(dv_name, group_name), group_name,
                            vlmode, value_mode)

  n_analysis <- nrow(mf)

  # One closing blank line (Session 328): a legend block ends on its own.
  if (!leg) cat("\n")
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
    sample_info  = sample_info,
    posthoc      = posthoc_tbl
  )
  class(ret) <- "jst_anova"
  invisible(ret)
}


#' Internal helper: the line that stands in for a two-group post-hoc table
#'
#' With two groups there is one comparison, and the test above it has made
#' it: a post-hoc table held one row whose p repeated that test's (Tukey
#' HSD after the traditional ANOVA, Games-Howell after Welch's). No table
#' is printed and none is returned; one line says why (Session 346; the
#' S344 item's rider).
#'
#' @return Invisibly NULL; called for the line it prints.
#' @keywords internal
.jst_posthoc_two_groups <- function() {
  .jst_msg_out("\nNote: Post-hoc comparisons are not shown for 2 groups: ",
               "the test above is the only comparison.")
  invisible(NULL)
}


#' Internal helper: Games-Howell pairwise comparisons
#'
#' The post-hoc test for Welch's ANOVA (Session 341; the S327 item): every
#' pair of group means compared without a pooled variance. For groups i and
#' j the standard error is \code{sqrt(v_i / n_i + v_j / n_j)} from the two
#' groups' own variances, the degrees of freedom are Welch-Satterthwaite's
#' for that pair, and the statistic \code{|diff| / se * sqrt(2)} is referred
#' to the studentized range distribution for k groups
#' (\code{stats::ptukey()}), which is what adjusts for the number of
#' comparisons; the 95 percent interval is
#' \code{diff +/- qtukey(.95, k, df) / sqrt(2) * se}. Rows and names follow
#' \code{stats::TukeyHSD()}: pairs in level order, each named
#' \code{later-earlier} with the difference taken the same way, so the two
#' post-hoc tables read alike. Base R has no Games-Howell function; this
#' needs none beyond stats.
#'
#' A pair whose standard error is 0 (both groups constant) has no df, p or
#' interval: its cells are NA and print blank. A pair with fewer than 2
#' degrees of freedom keeps its df and has no p or interval: the
#' studentized range distribution is not defined there, and
#' \code{stats::ptukey()} and \code{stats::qtukey()} are not called
#' (Session 346). \code{jaov()} stops before this for a group of one case,
#' which has no variance, and for a group whose cases all hold one value.
#'
#' @param y Numeric vector; the outcome on the analysis rows.
#' @param g Factor; the groups, with no empty level.
#' @return A data frame, one row per pair: \code{comparison}, \code{diff},
#'   \code{lower}, \code{upper}, \code{df}, \code{p} (all unrounded) and
#'   \code{test} ("Games-Howell").
#' @keywords internal
.jst_games_howell <- function(y, g) {
  ok   <- !is.na(y) & !is.na(g)
  y    <- y[ok]
  g    <- droplevels(g[ok])
  lv   <- levels(g)
  k    <- length(lv)
  n    <- as.numeric(tapply(y, g, length))
  m    <- as.numeric(tapply(y, g, mean))
  v    <- as.numeric(tapply(y, g, stats::var))
  rows <- list()
  for (i in seq_len(k - 1L)) {
    for (j in (i + 1L):k) {
      d    <- m[j] - m[i]
      a    <- v[i] / n[i]
      b    <- v[j] / n[j]
      se   <- sqrt(a + b)
      able <- is.finite(se) && se > 0
      df   <- if (able) (a + b)^2 / (a^2 / (n[i] - 1) + b^2 / (n[j] - 1))
              else NA_real_
      # The studentized range distribution is defined from 2 degrees of
      # freedom, and a pair with a group of two or three cases can fall
      # below that: ptukey() and qtukey() then return NaN with R's "NaNs
      # produced", four times a table (Session 346; the S344 item). Such a
      # pair keeps its difference and its df; jaov() says under the table
      # why its other cells are blank.
      ranged <- able && df >= 2
      p    <- if (ranged) stats::ptukey(abs(d) / se * sqrt(2), nmeans = k,
                                        df = df, lower.tail = FALSE)
              else NA_real_
      half <- if (ranged) stats::qtukey(0.95, nmeans = k, df = df) /
                            sqrt(2) * se
              else NA_real_
      rows[[length(rows) + 1L]] <- data.frame(
        comparison = paste0(lv[j], "-", lv[i]),
        diff = d, lower = d - half, upper = d + half, df = df, p = p,
        test = "Games-Howell", stringsAsFactors = FALSE)
    }
  }
  do.call(rbind, rows)
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
#' When the cells carry more than a count -- row or column percentages,
#' expected frequencies, residuals -- a blank line separates each category's
#' rows from the next, and the Total row from the last category. The
#' columns are set four spaces apart when the table at that spacing fits
#' the message width (\code{joptions()}'s \code{message.width}), and two
#' spaces apart when it does not.
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
#'   only to 2x2 tables). When any cell's expected frequency is less than
#'   5, a note under the test gives the number of such cells and the
#'   smallest expected frequency. Default is FALSE.
#' @param expected Logical. If TRUE, prints expected frequencies alongside
#'   observed, to two decimal places. An expected frequency just under 5
#'   that would round to 5.00 prints as 4.99, so a cell the chi-square
#'   note counts as less than 5 never reads as 5. Default is FALSE.
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
#'   Written in R syntax and checked the way \code{jsubset()} checks a
#'   filter: \code{subset = NOT(Age < 40)}, for example, is refused with
#'   the corrected \code{subset = !(Age < 40)} shown (see
#'   \code{\link{jsubset}} for a translation table).
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
#'   percentages, expected frequencies (two places), or integer quantities
#'   (counts, N, degrees of freedom), which keep their own fixed
#'   conventions. NULL (default) defers to
#'   \code{joutput()}'s \code{digits} setting (default 3).
#' @param case.processing.detail Per-call override of the Case
#'   Processing Summary detail tier: one of \code{"none"},
#'   \code{"totals"}, or \code{"per_code"}. \code{NULL} (default)
#'   uses the active \code{joutput()} level default. The Case
#'   Processing table itself prints only when a filter or listwise
#'   deletion excluded cases; otherwise a one-line N statement takes its
#'   place. See \code{?joutput} (\code{case.processing}).
jcrosstab <- function(formula, data, chisq = FALSE, expected = FALSE,
                      row.pct = TRUE, col.pct = FALSE, residuals = "none",
                      subset = NULL,
                      variable.id = NULL, value.id = NULL,
                      case.processing.detail = NULL, digits = NULL) {
  # Validate TRUE/FALSE flags up front.
  .jst_check_flag(chisq, "chisq")
  .jst_check_flag(expected, "expected")
  .jst_check_flag(row.pct, "row.pct")
  .jst_check_flag(col.pct, "col.pct")

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

  # Red title. It prints once the formula and the data frame are in hand,
  # as in jt(), jaov(), jlm() and jlogistic() (Session 338; AUDIT-026). It
  # was printed after the checks below, so jcrosstab() alone gave its
  # not-found, computed-term and same-variable stops with no title above
  # them and no default-data note.
  .cat_red("Cross-Tabulation\n")
  if (.jst_default_used) .jst_default_note(.jst_data_name)

  # A data frame named inside a term (d$Region ~ d$Condition) is refused
  # first, with the variables-on-their-own form (Session 323): the
  # computed-term refusal below would call d$Region a function applied to a
  # variable, and the two-sides check would name d as the shared variable.
  .jst_check_formula_frames(formula, data, .jst_data_name)
  # Transformed-term front door (AUDIT-021): a cross-tabulation needs plain
  # variables. Pre-check, a term like log(x) was silently ignored -- table()
  # pulls columns by name, so the raw column was tabulated as if the
  # transform had not been written. Refuse it clearly instead. (The analysis
  # functions with a numeric response resolve such terms via
  # .jst_resolve_formula_transforms; here a numeric transform of a
  # categorical variable has no cross-tabulation meaning.) Since Session 323
  # it runs AHEAD of the two-sides and existence checks: a constant in a
  # computed term (I(Age > cutoff)) reaches this refusal instead of a
  # not-found stop naming cutoff, and I(x > cutoff) ~ I(z > cutoff) is
  # refused for its terms, not for "cutoff" on both sides.
  .jst_check_formula_transforms(formula, .jst_data_name)

  terms    <- all.vars(formula)
  row_name <- terms[1]
  col_name <- terms[2]

  dup_var <- .jst_formula_dup_var(formula)
  if (!is.null(dup_var)) {
    .jst_stop(paste0("'", dup_var, "' appears on both sides of the formula.\n",
                     "A cross-tabulation requires two different variables."))
  }

  .jst_check_vars(data, terms, .jst_data_name, default_used = .jst_default_used)
  # Type gate (Session 46): both variables are categorical; refuse date/time
  # and complex/list/raw. See .jst_check_analysis_var.
  for (.gv in terms) .jst_check_analysis_var(data[[.gv]], .gv, FALSE, "a cross-tabulation")

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

  # No case left: one stop, ahead of the category count (Session 346).
  .jst_stop_empty_sample(sample_info)

  # A text variable's blank cells are one category, <blank> (S340).
  row_var <- .jst_label_blanks(data[[row_name]])
  col_var <- .jst_label_blanks(data[[col_name]])

  row_labelled <- haven::is.labelled(row_var)
  col_labelled <- haven::is.labelled(col_var)

  if (row_labelled) {
    row_codes <- .jst_group_codes(row_var)
    row_vl    <- labelled::val_labels(row_var)
    row_var   <- haven::as_factor(row_var)
  } else if (!is.factor(row_var)) {
    row_var <- .jst_text_factor(row_var)
  }

  if (col_labelled) {
    col_codes <- .jst_group_codes(col_var)
    col_vl    <- labelled::val_labels(col_var)
    col_var   <- haven::as_factor(col_var)
  } else if (!is.factor(col_var)) {
    col_var <- .jst_text_factor(col_var)
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
      # Number agreement and one sentence per line, as in jt() (Session 338).
      n_lvls <- length(check_info$lvls)
      # A filter that names the variable kept one category of it (Session
      # 346). The categories are counted before listwise deletion here, so
      # one category is the filter's doing, or the data's.
      fn <- .jst_filters_naming(check_info$name, sample_info, .jst_data_name)
      if (n_lvls == 1L && (fn$per || fn$stored)) {
        .jst_stop(.jst_filter_keeps(fn), " only 1 category of '",
                  check_info$name, "', and a cross-tabulation requires at ",
                  "least 2 for each variable.\n",
                  .jst_filter_way_out(fn, .jst_data_name,
                                      "To cross-tabulate it"))
      }
      .jst_stop("'", check_info$name, "' has ", n_lvls, " ",
                .jst_plural(n_lvls, "category", "categories"),
                .jst_settings_context(.jst_data_name), ".\n",
                "A cross-tabulation requires at least 2 categories ",
                "for each variable.")
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

  # Counts print whole, never in scientific notation (Session 328):
  # as.character() turned a count or a total of exactly 100000 into "1e+05"
  # -- the margins of a 200,000-case table split evenly, for one.
  fmt_count <- function(x) format(as.numeric(x), scientific = FALSE,
                                  trim = TRUE)

  # Expected frequencies print to TWO places (Session 329, Jeff), in the
  # cells and in the note below alike, so the two cannot disagree: at one
  # place a cell read 5.0 beside a note saying "minimum = 4.96". Two places
  # leave one window open -- a value in [4.995, 5) rounds up to 5.00, the
  # threshold the note says the cell is below -- so that prints 4.99
  # (Session 327, extended here from the note to the cells). A fixed
  # convention, like a percentage's one place: the digits setting does not
  # move it.
  fmt_expected <- function(x) {
    s <- .jst_make_fmt(2L)(round(x, 2))
    s[x < 5 & round(x, 2) >= 5] <- "4.99"
    s
  }

  # A blank line sets each row group off from the next -- before every
  # category after the first, and before Total -- whenever the categories
  # carry sub-rows (Session 329, Jeff): with them the groups ran together.
  # When every category is a single line there is nothing to separate, and
  # none is printed. A spacer is a row of empty cells, which the renderer's
  # trim prints as an empty line (jfreq's spacer rows are the precedent).
  has_sub_rows <- expected || row.pct || col.pct || show_adj_res
  spacer_row   <- list(rep("", n_cols + 2L))

  display_rows <- list()

  for (i in seq_len(n_rows)) {
    obs_vals  <- as.numeric(obs_table[i, ])
    row_total <- sum(obs_vals)
    if (has_sub_rows && i > 1L) display_rows <- c(display_rows, spacer_row)
    display_rows <- c(display_rows,
                      list(c(row_labels[i], fmt_count(obs_vals),
                             fmt_count(row_total))))

    if (expected) {
      # The Total cell is the sum of the UNROUNDED expected counts (Session
      # 329): it summed the rounded cells, so three cells of 3.33 would
      # have totalled 9.99 beside an observed 10. It takes no 4.99 guard --
      # it is a row total, not a cell the note counts.
      exp_vals     <- exp_table[i, ]
      display_rows <- c(display_rows,
                        list(c("  (Expected)", fmt_expected(exp_vals),
                               .jst_make_fmt(2L)(round(sum(exp_vals), 2)))))
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
  if (has_sub_rows) display_rows <- c(display_rows, spacer_row)
  display_rows <- c(display_rows,
                    list(c("Total", fmt_count(col_totals),
                           fmt_count(grand_total))))

  if (col.pct) {
    display_rows <- c(display_rows,
                      list(c("  (Col %)", rep("100.0%", n_cols), "100.0%")))
  }

  display_df           <- as.data.frame(do.call(rbind, display_rows),
                                        stringsAsFactors = FALSE)
  colnames(display_df) <- header

  # The cells line up on the decimal point (Session 328, Jeff): every cell
  # is text -- a count, an expected count, a percentage, a residual with its
  # markers -- so the default alignment left-justified them all, and 13 sat
  # over the 1 of 12.6 only by accident of width. "bd" puts the count's
  # ones digit over the expected count's and the percentage's, and centers
  # the block under the column's header. The label column is "ln", so the
  # two-space indent the sub-row labels are built with ("  (Row %)")
  # survives: the default "l" trimmed it.
  #   The columns stand four spaces apart where the table has room for it
  # and two where it does not (Session 329, Jeff): the cell columns are
  # narrow, and at two spaces a 2 x 2 read as crowded. gap = c(4, 2) is the
  # renderer's width rule -- four if the table at four still fits the
  # message width.
  .jst_print_table(display_df,
                   caption   = paste("Crosstab:", row_disp, "by", col_disp),
                   row.names = FALSE,
                   align     = c("ln", rep("bd", ncol(display_df) - 1L)),
                   gap       = c(4L, 2L))
  # One blank line closes the crosstab. What follows -- the chi-square
  # table, the notes, the legend -- separates itself from what precedes it,
  # and the output ends on exactly ONE blank line (Session 328). ends_blank
  # tracks whether the last thing printed was a blank line.
  cat("\n")
  ends_blank <- TRUE

  # Chi-square test (only if requested)
  if (chisq) {
    ends_blank <- FALSE
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

      # Block-centered (Session 328): each cell was centered on its own
      # ("c"), so the two rows fell out of line whenever their values
      # differed in width -- "<.001" over ".001", 11.605 over 9.870.
      .jst_print_table(chi_table,
                       caption   = "Chi-Square Test of Independence",
                       col.names = c("Test", "Chi-Square", "df", "p", "N"),
                       align     = c("l", "bc", "bc", "bc", "bc"),
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
                       align     = c("bc", "bc", "bc", "bc"),
                       row.names = FALSE)
    }

    min_expected <- min(exp_table)
    n_below_5    <- sum(exp_table < 5)
    if (n_below_5 > 0) {
      # The minimum to two places, padded (Session 327; wording approved by
      # Jeff). It printed through round(x, 1), so a minimum of 4.96 read
      # "less than 5 (minimum expected = 5)" and exactly 3 read "3". Two
      # places leave one window open -- a minimum in [4.995, 5) rounds up to
      # 5.00, the threshold the note says it is below -- so that prints
      # 4.99. "(minimum = ...)" keeps the sentence on one line at the
      # default width, where "(minimum expected = ...)" wrapped.
      #   Since Session 329 the cells print through the same fmt_expected()
      # as this minimum, and the note closes with a pointer to expected =
      # TRUE when the expected frequencies it speaks of are not in the
      # table above it (Jeff: "The note speaks about expected frequencies
      # but we're not showing the expected frequencies in this output").
      .jst_msg_out("\nNote: ", n_below_5,
                   if (n_below_5 == 1L) " cell has an expected frequency"
                   else " cells have expected frequencies",
                   " less than 5 (minimum = ",
                   fmt_expected(min_expected), ").\n",
                   "Chi-square results may not be reliable.",
                   if (!expected)
                     "\nTo see the expected frequencies, add expected = TRUE.")
    }
  }

  # Adjusted-residual interpretation note (advisory: shown at joutput("full")
  # only). States the z-reference rule, names the cell markers, and gives a
  # Bonferroni-adjusted cutoff -- the familywise correction SPSS CROSSTABS
  # omits. n_cells / bonf are computed once above.
  if (show_adj_res) {
    # A blank line sets the note off from the chi-square table or the
    # expected-frequency note above it (Session 329; voice Rule F). It is
    # printed here, on stdout with the tables, and only when the note will
    # print and the output does not already end on a blank line.
    if (mark_adj_res && !ends_blank) cat("\n")
    .jst_advisory_note(
      "Note: Adjusted residuals are approximately normal under independence.\n",
      "A value beyond +/-1.96 (marked *) departs from expected at p < .05.\n",
      "With ", n_cells, " cells, a Bonferroni-adjusted cutoff is +/-",
      sprintf("%.2f", bonf), " (marked **)."
    )
    # The note prints at joutput("full") only -- exactly when the cells are
    # marked.
    if (mark_adj_res) ends_blank <- FALSE
  }

  # The legend's lead-in blank line prints only when the output does not
  # already end on one, and the closing blank line only when no legend
  # block (which ends on its own) printed. (Session 328)
  leg <- .jst_print_legends(lab_src, c(row_name, col_name), c(row_name, col_name),
                            vlmode, value_mode, lead = !ends_blank)
  if (leg) ends_blank <- TRUE
  if (!ends_blank) cat("\n")

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
