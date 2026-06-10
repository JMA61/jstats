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
