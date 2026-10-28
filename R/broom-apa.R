#<<<FILE: broom-apa.R>>>



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

# The classes the two accessors have methods for, "default" last. zzz.R's
# .onLoad registers both methods for each (Session 399; the list was
# written into .onLoad until then), so a class gains its accessors here,
# beside its methods, with no edit to zzz.R. Every class an analysis
# function returns is here.
.jst_apa_classes <- c("jst_lm", "jst_logistic", "jst_freq", "jst_desc",
                      "jst_corr", "jst_ttest", "jst_anova", "jst_crosstab",
                      "jst_alpha", "default")

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
# Since Session 399 (Capability Slate T's build 0) each row carries its
# category's code and label, read from the Code and Label columns jfreq()
# stores beside the printed Value, and the Missing rows come too, block
# "missing" beside block "valid": the declared missing values one row each
# and the system-missing row last, as the printed table lists them. code
# keeps its type where every variable's codes share one (rbind() makes it
# text where they do not); a result made before Session 399 has no Code or
# Label, and its rows read NA there.

.jst_apa_terms.jst_freq <- function(x, ...) {
  res <- x$frequencies
  if (is.null(res) || length(res) == 0) return(NULL)
  rows <- lapply(names(res), function(v) {
    r  <- res[[v]]
    vl <- if (is.null(r$var_label)) v else r$var_label
    one_block <- function(df, kind) {
      if (is.null(df) || nrow(df) == 0L) return(NULL)
      valid <- identical(kind, "valid")
      data.frame(
        variable  = v,
        var_label = vl,
        block     = kind,
        code      = if (is.null(df$Code)) NA else df$Code,
        label     = if (is.null(df$Label)) NA_character_ else df$Label,
        value     = df$Value,
        count     = df$Freq,
        total_pct = if (is.null(df$TotalPct)) NA_real_ else df$TotalPct,
        valid_pct = if (valid) df$ValidPct else NA_real_,
        cum_pct   = if (valid) df$CumPct   else NA_real_,
        stringsAsFactors = FALSE, row.names = NULL)
    }
    do.call(rbind, list(one_block(r$valid, "valid"),
                        one_block(r$udm,   "missing"),
                        one_block(r$na,    "missing")))
  })
  out <- do.call(rbind, rows)
  if (!is.null(out)) rownames(out) <- NULL
  out
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
# Per-row = one row per variable, or, for jdesc(by =), per variable and
# group (Session 399: descriptives_raw was NULL for a grouped call until
# then). The identifiers come first -- variable, var_label, and for a
# grouped call group_code and group_label -- then the statistics, every
# number unrounded. A grouped call's grouping variable rides as the "by"
# attribute, c(name = , label = ).

.jst_apa_terms.jst_desc <- function(x, ...) {
  dr <- x$descriptives_raw
  if (is.null(dr)) return(NULL)
  lab <- attr(dr, "labels")
  out <- data.frame(
    variable  = dr$variable,
    var_label = if (is.null(lab)) dr$variable else unname(lab[dr$variable]),
    stringsAsFactors = FALSE, row.names = NULL)
  if (!is.null(dr$group_code)) {
    out$group_code  <- dr$group_code
    out$group_label <- dr$group_label
  }
  stat_cols <- c("total", "n_valid", "n_missing", "min", "max", "mean", "sd")
  out <- cbind(out, dr[stat_cols])
  rownames(out) <- NULL
  attr(out, "by") <- attr(dr, "by")
  out
}
.jst_apa_model.jst_desc <- function(x, ...) NULL

# -- Correlations: jst_corr ----------------------------------------------------
# Per-row = one row per unique variable pair (lower triangle). Since Session
# 399 the variables' own statistics ride beside the pairs as the
# "variables" attribute -- one row per variable, in the matrix's order:
# variable, label, n, mean, sd, unrounded, each variable on its own cases --
# which a correlation table prints beside r. NULL on a result made before
# Session 399.

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
  out <- do.call(rbind, rows)
  dr  <- x$descriptives_raw
  attr(out, "variables") <- if (is.null(dr)) NULL else data.frame(
    variable = dr$variable,
    label    = if (is.null(lab)) dr$variable else unname(lab[dr$variable]),
    n        = dr$n_valid,
    mean     = dr$mean,
    sd       = dr$sd,
    stringsAsFactors = FALSE, row.names = NULL)
  out
}
.jst_apa_model.jst_corr <- function(x, ...) {
  data.frame(method = x$method, n_vars = length(rownames(x$r)),
             stringsAsFactors = FALSE, row.names = NULL)
}

# -- Group comparisons: jst_ttest, jst_anova (Session 399) --------------------
# Per-row = one row per group, from descriptives_raw: group_code,
# group_label, n, mean, sd, unrounded (the printed descriptives are
# rounded), and for jaov() the 95 percent interval of each mean. The
# outcome and the grouping variable ride as the "outcome" and "group"
# attributes, c(name = , label = ), as the regression terms carry the
# outcome. jaov()'s post-hoc table rides as the "posthoc" attribute, each
# pair's groups by code and label (NULL when none was run). Model-level =
# one row: the test, its statistic, df and p, the effect size, N and
# Levene's test where it was run (NA where it was not). NULL on a result
# made before Session 399.

.jst_apa_group_terms <- function(x) {
  dr <- x$descriptives_raw
  if (is.null(dr)) return(NULL)
  out <- dr
  rownames(out) <- NULL
  out
}

.jst_apa_levene <- function(lv) {
  if (is.null(lv)) {
    return(list(levene_f = NA_real_, levene_df1 = NA_real_,
                levene_df2 = NA_real_, levene_p = NA_real_))
  }
  list(levene_f = unname(lv$F), levene_df1 = unname(lv$df1),
       levene_df2 = unname(lv$df2), levene_p = unname(lv$p))
}

.jst_apa_name <- function(x, which) {
  a <- attr(x$descriptives_raw, which)
  if (is.null(a)) NA_character_ else unname(a["name"])
}

.jst_apa_terms.jst_ttest <- function(x, ...) .jst_apa_group_terms(x)

.jst_apa_model.jst_ttest <- function(x, ...) {
  if (is.null(x$descriptives_raw)) return(NULL)
  ci <- x$ci
  data.frame(
    outcome         = .jst_apa_name(x, "outcome"),
    group           = .jst_apa_name(x, "group"),
    test_type       = x$test_type,
    t               = x$t,
    df              = x$df,
    p               = x$p,
    mean_difference = x$mean_difference,
    ci_lower        = unname(ci["lower"]),
    ci_upper        = unname(ci["upper"]),
    cohens_d        = x$cohens_d,
    d_type          = x$d_label,
    n               = x$n,
    .jst_apa_levene(x$levene),
    stringsAsFactors = FALSE, row.names = NULL)
}

.jst_apa_terms.jst_anova <- function(x, ...) {
  out <- .jst_apa_group_terms(x)
  if (!is.null(out)) attr(out, "posthoc") <- x$posthoc
  out
}

.jst_apa_model.jst_anova <- function(x, ...) {
  if (is.null(x$descriptives_raw)) return(NULL)
  data.frame(
    outcome     = .jst_apa_name(x, "outcome"),
    group       = .jst_apa_name(x, "group"),
    test_type   = x$test_type,
    f           = x$f,
    df1         = x$df1,
    df2         = x$df2,
    p           = x$p,
    eta_squared = x$eta_squared,
    n           = x$n,
    .jst_apa_levene(x$levene),
    stringsAsFactors = FALSE, row.names = NULL)
}

# -- Crosstab: jst_crosstab (Session 399) --------------------------------------
# Per-row = one row per cell, row by row in the stored table's order: each
# category's level as the table names it, its code and label (from the
# row_categories and col_categories jcrosstab() stores; NA on a result made
# before Session 399), the count, the expected count, the adjusted
# residual, and the cell's row, column and total percentages. The two
# variables ride as the "row" and "col" attributes, c(name = , label = ).
# Model-level = one row: the variables, N and the table's size, and the
# chi-square test where it was run (NA where it was not).

.jst_apa_terms.jst_crosstab <- function(x, ...) {
  obs <- x$observed
  if (is.null(obs)) return(NULL)
  obs <- unclass(obs)
  nr  <- nrow(obs); nc <- ncol(obs)
  rl  <- rownames(obs); cl <- colnames(obs)
  cat_of <- function(cats, lv, field) {
    if (is.null(cats)) return(rep(NA, length(lv)))
    cats[[field]][match(lv, cats$level)]
  }
  i <- rep(seq_len(nr), each = nc)
  j <- rep(seq_len(nc), times = nr)
  cnt <- obs[cbind(i, j)]
  rs  <- rowSums(obs); cs <- colSums(obs); n <- sum(obs)
  out <- data.frame(
    row_level         = rl[i],
    row_code          = cat_of(x$row_categories, rl, "code")[i],
    row_label         = cat_of(x$row_categories, rl, "label")[i],
    col_level         = cl[j],
    col_code          = cat_of(x$col_categories, cl, "code")[j],
    col_label         = cat_of(x$col_categories, cl, "label")[j],
    count             = as.numeric(cnt),
    expected          = if (is.null(x$expected)) NA_real_
                        else as.numeric(x$expected[cbind(i, j)]),
    adjusted_residual = if (is.null(x$adjusted_residuals)) NA_real_
                        else as.numeric(x$adjusted_residuals[cbind(i, j)]),
    row_pct           = ifelse(rs[i] > 0, cnt / rs[i] * 100, NA_real_),
    col_pct           = ifelse(cs[j] > 0, cnt / cs[j] * 100, NA_real_),
    total_pct         = if (n > 0) cnt / n * 100 else NA_real_,
    stringsAsFactors  = FALSE, row.names = NULL)
  attr(out, "row") <- attr(x$row_categories, "variable")
  attr(out, "col") <- attr(x$col_categories, "variable")
  out
}

.jst_apa_model.jst_crosstab <- function(x, ...) {
  if (is.null(x$observed)) return(NULL)
  num <- function(v) if (is.null(v)) NA_real_ else unname(as.numeric(v))
  nm  <- function(cats) {
    a <- attr(cats, "variable")
    if (is.null(a)) NA_character_ else unname(a["name"])
  }
  data.frame(
    row                  = nm(x$row_categories),
    col                  = nm(x$col_categories),
    n                    = num(x$n),
    n_rows               = nrow(x$observed),
    n_cols               = ncol(x$observed),
    chi_square           = num(x$chi_square),
    df                   = num(x$df),
    p                    = num(x$p),
    method               = if (is.null(x$chi_method)) NA_character_
                           else x$chi_method,
    cramers_v            = num(x$cramers_v),
    chi_square_corrected = num(x$chi_square_corrected),
    p_corrected          = num(x$p_corrected),
    stringsAsFactors = FALSE, row.names = NULL)
}

# -- Reliability: jst_alpha (Session 399) --------------------------------------
# Per-row = one row per item, from items_raw: item, label, n, mean, sd, the
# corrected item-total correlation and alpha if the item is deleted, every
# number unrounded (the printed tables and the alpha, item_statistics and
# item_total_statistics stored beside them are rounded). Model-level = one
# row: alpha unrounded, the items, and the cases used and excluded. NULL on
# a result made before Session 399.

.jst_apa_terms.jst_alpha <- function(x, ...) {
  ir <- x$items_raw
  if (is.null(ir)) return(NULL)
  rownames(ir) <- NULL
  ir
}

.jst_apa_model.jst_alpha <- function(x, ...) {
  if (is.null(x$alpha_raw)) return(NULL)
  data.frame(alpha = x$alpha_raw, n_items = x$n_items, n_used = x$n_used,
             n_excluded = x$n_excluded,
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
    .jst_stop("This jcrosstab() result has no chi-square test to tidy.\n",
              "Re-run with jcrosstab(..., chisq = TRUE).", fn = "tidy")
  }
  # Cramer's V (Session 375); a result made before then carries none, and
  # it is computed from what the result does carry.
  v <- if (!is.null(x$cramers_v)) x$cramers_v
       else .jst_cramers_v(x$chi_square, x$n, dim(x$observed))
  data.frame(
    statistic = unname(x$chi_square),
    parameter = unname(x$df),
    p.value   = unname(x$p),
    method    = if (!is.null(x$chi_method)) x$chi_method
                else "Pearson's Chi-squared test",
    n         = x$n,
    cramers_v = unname(v),
    stringsAsFactors = FALSE, row.names = NULL)
}
