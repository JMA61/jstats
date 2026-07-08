#<<<FILE: models.R>>>


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
#' jcorr(community, Income, Age, WellbeingScore)
#' jcorr(community, Income, Age, WellbeingScore, method = "spearman")
#'
#' # Using juse() default
#' juse(community)
#' jcorr(Income, Age, WellbeingScore)
#'
#' @seealso \code{\link{jstats}} for the package overview,
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
    .jst_stop("value.id is not supported here; it does not display ",
         "value labels.")
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

  .jst_check_vars(data, variable_names, .jst_data_name, default_used = .jst_default_used)

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
    .jst_stop("categorical = is not supported yet: correlation requires ",
         "numeric variables.\nFor association between categorical variables use ",
         "jcrosstab() instead.")
  }
  for (.arg in c("numeric", "count")) {
    .val <- get(.arg)
    if (!is.null(.val)) {
      .bad <- setdiff(.val, variable_names)
      if (length(.bad) > 0) {
        .jst_stop(.arg, " argument: ", paste0("'", .bad, "'", collapse = ", "),
             " not found among the variables passed to jcorr(). Check for typos.")
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
    .jst_stop(paste0(
      "At least 2 variables are required. ",
      if (length(variable_names) == 0) "None were provided."
      else "Only 1 was provided."
    ))
  }

  method <- tolower(method)
  if (!method %in% c("pearson", "spearman", "kendall")) {
    .jst_stop_arg("jcorr", "method", choices = c("pearson", "spearman", "kendall"))
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
      .jst_stop(paste0("'", v, "' is a character variable and cannot be used ",
                  "in a correlation. Use a numeric variable instead."))
    }
    if (is.factor(cor_data[[v]])) {
      numeric_check <- suppressWarnings(as.numeric(as.character(cor_data[[v]])))
      if (all(is.na(numeric_check[!is.na(cor_data[[v]])]))) {
        .jst_stop(paste0("'", v,
                    "' is a factor with text categories and cannot be used ",
                    "in a correlation. Use a numeric variable instead."))
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
    if (.jst_warns_seems_categorical(data[[v]], v, .jst_data_name,
                                     override = .ov)) {
      warning(.jst_assumption_warning(v, "jcorr"), call. = FALSE)
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
#' helper rewrites factor terms to the parenthetical "Var (Level)" form
#' (e.g. "GenderR (Female)"), and gives a numeric dichotomy whose two codes
#' differ by exactly 1 the matching "Var (Level)" form, showing the HIGHER
#' code's value label (haven) or its value (Session 127) -- there the slope
#' equals the higher-vs-lower category contrast. Wider-spaced codes stay
#' bare so the label cannot misrepresent a genuine per-unit slope. Columns
#' named in skip are left entirely untouched: the jlm()/jlogistic() call
#' sites pass their machine-generated dummy column names, so generated 0/1
#' dummies keep bare names -- they are already named clearly (e.g.
#' "Education_Some_college"), a trailing "(1)" adds nothing on a column
#' that can only be 0/1, and the grouped multi-category display
#' (.jst_group_dummy_coefs) matches rows by those bare names, so decorating
#' them silently defeats the grouped layout (Session 176).
#'
#' @param coef_names Character vector of coefficient names from a fitted model.
#' @param data Data frame used to fit the model (post-conversion).
#' @param iv_names Character vector of IV names from the model formula.
#' @param sep Character. Separator to insert. Default is "-".
#' @param skip Character vector of column names to leave untouched (no
#'   factor separation, no dichotomy parenthetical). The jlm()/jlogistic()
#'   call sites pass their machine-generated dummy column names here.
#'   Default character(0).
#'
#' @return Character vector of the same length as coef_names, with factor
#'   coefficient names separated.
#'
#' @keywords internal
.jst_clean_coef_names <- function(coef_names, data, iv_names, sep = "-",
                                  skip = character(0)) {
  cleaned <- coef_names
  for (v in iv_names) {
    if (v %in% skip) next
    if (!v %in% names(data)) next
    col <- data[[v]]
    if (is.factor(col)) {
      lvls <- levels(col)
      if (length(lvls) < 2) next
      for (lvl in lvls[-1]) {
        old_name <- paste0(v, lvl)
        new_name <- paste0(v, " (", lvl, ")")
        cleaned[cleaned == old_name] <- new_name
      }
    } else if (is.numeric(col) || haven::is.labelled(col)) {
      vals <- .jst_as_numeric(col)
      u    <- sort(unique(vals[!is.na(vals)]))
      # Annotate only a two-level predictor whose codes differ by exactly 1,
      # where the numeric slope equals the higher-vs-lower category contrast.
      # Wider-spaced codes carry a genuine per-unit slope, so the bare name
      # (no category parenthetical) is the honest label in that case.
      if (length(u) == 2L && (u[2L] - u[1L]) == 1) {
        hi       <- u[2L]
        hi_label <- as.character(hi)
        if (haven::is.labelled(col)) {
          vl <- labelled::val_labels(col)
          m  <- which(vl == hi)
          if (length(m) > 0L) hi_label <- names(vl)[m[1L]]
        }
        cleaned[cleaned == v] <- paste0(v, " (", hi_label, ")")
      }
    }
  }
  cleaned
}

#' Internal helper: relabel cleaned coefficient names with variable labels
#'
#' For the \code{"labels"} variable.id display mode (jlm / jlogistic). Given
#' the cleaned names from \code{.jst_clean_coef_names()} -- numeric
#' predictors as the bare variable name, factor terms and numeric
#' dichotomies as \code{"<var> (<level>)"}, intercept as \code{"(Intercept)"}
#' -- replaces the variable-name portion of each term with the variable's
#' label, preserving the parenthetical decoration. Grouped / jdummy term
#' keys in \code{"<var><sep><level>"} form (e.g. \code{sep = "_"}) are
#' relabelled the same way, keeping the \code{"<sep><level>"} suffix. The
#' intercept, and any term not attributable to a labelled IV (e.g. a
#' clearly-named jdummy column carrying no variable label), are left
#' unchanged. Display only: the returned coefficient table keeps the cleaned
#' variable names so downstream code and the user's own indexing still work.
#'
#' @param coef_names Character vector of cleaned coefficient names.
#' @param data Data frame used to fit the model (carries variable labels).
#' @param iv_names Character vector of IV names from the model formula.
#' @param sep Character separator for grouped / jdummy term keys
#'   (\code{"<var><sep><level>"}). Default \code{"-"}; the grouped-dummy
#'   call sites pass \code{"_"}.
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
      # Parenthetical decoration "<var> (<level>)": factor terms and numeric
      # dichotomies cleaned by .jst_clean_coef_names(). Swap the leading
      # variable name for its label, keeping the " (<level>)" intact.
      if (startsWith(nm, paste0(v, " ("))) {
        out[i] <- paste0(lab, substring(nm, nchar(v) + 1L))
        break
      }
      # Separator decoration "<var><sep><level>": grouped / jdummy term keys.
      prefix <- paste0(v, sep)
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
    names(vif_values) <- .jst_unbacktick(colnames(X))
    vif_values
  }, error = function(e) {
    message("VIF could not be computed (possible perfect collinearity).")
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
#' and standardized coefficients (beta). Standardized coefficients are left
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
#' @details
#' Transformed terms in \code{formula} are computed automatically. A term
#' that applies a function to a variable -- \code{log(x)}, \code{sqrt(x)},
#' \code{exp(x)}, \code{I(x^2)}, \code{scale(x)}, an arithmetic expression,
#' or a logical condition such as \code{I(x > 10)} -- is evaluated once on
#' the analysis data and enters the model as a single derived column named
#' for the expression, so the coefficient table, the group descriptives, and
#' the standardized-beta refit all report the term as written. This follows
#' the base R formula convention; the terms supported inline are those that
#' evaluate to one numeric or logical column. Terms that produce several
#' columns (\code{poly(x, 2)}, spline bases) or a categorical result
#' (\code{cut(x, 3)}) are not supported inline: create the derived variable
#' as a column of the data first, then name that column in the formula.
#'
#' @param formula A model formula, e.g. \code{y ~ x1 + x2}. Transformed
#'   terms such as \code{log(y)} or \code{I(x1^2)} are computed
#'   automatically and used throughout the output.
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
#' @param std Character. Controls the standardized-coefficient column. One of
#'   \code{"regular"} (default) -- standardized betas with the prevalence-scaled
#'   betas of dummy and dichotomous predictors suppressed, since a fully
#'   standardized beta on a 0/1 indicator is not comparable to the continuous
#'   betas; \code{"all"} -- the same standardized betas with nothing suppressed;
#'   \code{"gelman"} -- Gelman (2008) scaling, where continuous predictors are
#'   placed on a divide-by-two-standard-deviations scale and binary predictors
#'   keep their raw 0/1 contrast (shown for all predictors, and headed
#'   "Gelman beta"); or \code{"none"} -- omit the column. The returned object
#'   always carries both the full regular betas (\code{beta}) and the full
#'   Gelman betas (\code{beta_gelman}) regardless of this display choice.
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
#' jlm(WellbeingScore ~ Income + Age, data = community)
#'
#' # With explicit data frame (positional argument)
#' jlm(WellbeingScore ~ Income + Age, community)
#'
#' # Using juse() default
#' juse(community)
#' jlm(WellbeingScore ~ Income + Age)
#'
#' # CATEGORICAL PREDICTORS
#' #
#' # Per-call: categorical = ... applies for one call only and does not
#' # persist. Useful for a quick one-off analysis.
#' jlm(WellbeingScore ~ Region + Age, categorical = "Region")
#'
#' # The recommended approach for repeated analyses: register the variable
#' # with jdummy() before running jlm(). This sets the categorical
#' # treatment persistently, so subsequent jlm() calls (and other
#' # analyses) use the same coding without re-specifying.
#' jdummy(community, Region)
#' jlm(WellbeingScore ~ Region + Age)
#'
#' # To choose a non-default reference category:
#' jdummy(community, Region, ref = "West")
#' jlm(WellbeingScore ~ Region + Age)
#'
#' # FORCING NUMERIC TREATMENT
#' #
#' # Use numeric = ... when a variable has value labels (haven_labelled)
#' # but you want it treated as a continuous score (e.g., a Likert
#' # scale you want the slope-per-unit interpretation for).
#' jlm(WellbeingScore ~ Age + Education, numeric = "Education")
#'
#' # Multiple overrides at once
#' jlm(WellbeingScore ~ Education + Environment4 + Smoker,
#'     numeric = c("Education", "Environment4"), categorical = "Smoker")
#'
#' # Not normally needed. You'd clear a default or registration only to
#' # undo a mistake, or -- as in this example -- to reset state for testing.
#' jdummy(community, NULL)
#' juse(NULL)
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
#' @param ref.categories Logical or NULL. Per-call override for showing the
#'   reference-categories block (the baseline level dropped from each set of
#'   dummy variables). \code{NULL} (default) defers to \code{joutput()}'s
#'   \code{ref.categories} setting. Applies to \code{jlm()} and
#'   \code{jlogistic()} only, since they are the functions that produce
#'   dummy-coded coefficient tables.
jlm <- function(formula, data, subset = NULL, variable.id = NULL,
                numeric = NULL, categorical = NULL, count = NULL,
                ci = NULL, std = "regular",
                diagnostics = NULL, ref.categories = NULL, full = FALSE,
                case.processing.detail = NULL, digits = NULL, ...,
                value.id = NULL) {

  .jst_check_args(
    list(...),
    aliases = c(which = "diagnostics", plots = "diagnostics",
                show = "diagnostics"),
    fn_name = "jlm"
  )

  if (!std %in% c("regular", "all", "gelman", "none")) {
    .jst_stop_arg(arg = "std", choices = c("regular", "all", "gelman", "none"))
  }

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
    .jst_stop("value.id '", value.id, "' is not supported here.")
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
    example    = "DV ~ IV",
    fn         = "jlm"
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

  # Raw-name existence check first, so the transform resolver below can
  # assume every plain variable in the formula exists.
  # Underlying variable names (pre-transform). Drives the existence check
  # and, below, the case-processing breakdown -- so a transformed term is
  # reported against its source column, which the pre-pipeline snapshot
  # contains (the computed column is not in that snapshot).
  raw_vars <- all.vars(formula)
  .jst_check_vars(data, raw_vars, .jst_data_name,
                  default_used = .jst_default_used)

  # Transformed-term front door (AUDIT-021; supersedes the AUDIT-005
  # refusal): compute log(x), I(x^2), and the like once on the analysis
  # copy and rewrite the formula to reference the computed column, so the
  # model, the descriptives, and the standardized-beta refit all see the
  # same values under the name the user typed.
  resolved <- .jst_resolve_formula_transforms(formula, data, .jst_data_name)
  formula  <- resolved$formula
  data     <- resolved$data

  model_vars            <- all.vars(formula)
  # Preserve the original (pre-expansion) variable names for use in
  # missing-by-variable reporting. After dummy expansion, model_vars
  # holds the dummy column names (e.g. ProgramApprenticeship); the
  # user wrote "Program" in the formula and the diagnostic should
  # speak the user's language. (A resolved transform keeps the user's
  # language automatically: its column is named with the term's own
  # text, e.g. "log(Age)".)
  original_formula_vars <- model_vars

  # DV-as-IV guard (Session 105): all.vars() deduplicates, so a formula like
  # MathScore ~ MathScore + Age is invisible downstream -- lm() would warn
  # cryptically, drop the response from the right-hand side, and fit a
  # different model than the user wrote. Checked on the resolved formula
  # (so log(y) ~ y, a different DV and IV, passes; log(y) ~ log(y), the
  # same computed column twice, is caught) and before dummy expansion can
  # rewrite the right-hand side.
  dup_var <- .jst_formula_dup_var(formula)
  if (!is.null(dup_var)) {
    .jst_stop(paste0("'", dup_var, "' appears as both the dependent variable ",
                     "and an independent variable.\n",
                     "Each variable can only play one role in a regression."))
  }

  # Type gate (Session 46): the response must be numeric; predictors may be
  # numeric or categorical. Date/time and complex/list/raw refused in both
  # roles. See .jst_check_analysis_var.
  .jst_check_analysis_var(data[[model_vars[1L]]], model_vars[1L], TRUE, "a linear model")
  for (.gv in model_vars[-1L]) .jst_check_analysis_var(data[[.gv]], .gv, FALSE, "a linear model")

  # -- Expand registered dummy variables ------------------------------------
  expanded         <- .jst_expand_dummies(data, formula, .jst_data_name,
                                          numeric = numeric, count = count)
  data               <- expanded$data
  formula            <- expanded$formula
  ref_cats           <- expanded$ref_cats
  dummy_coef_names   <- expanded$dummy_coef_names
  expanded_originals <- expanded$expanded_originals
  model_vars         <- all.vars(formula)

  # (Option B) A per-call numeric =/ count = naming a registered dummy is
  # consulted inside .jst_expand_dummies() above, which skips that variable's
  # expansion and emits the precedence note/warning. The variable therefore
  # arrives here as its original numeric column and is handled by the
  # numeric/count branch of the IV loop below; the registration is unchanged.

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
  .jst_check_dummy_outcome(.jst_data_name, dv_name, "jlm")

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
    # Dichotomy used as a linear-regression DV: short, definitive caution.
    warning(
      "'", dv_name, "' is the outcome variable but looks categorical (a ",
      dv_dich$coding, " dichotomy). Linear regression expects an interval outcome.",
      call. = FALSE
    )
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
        "'", dv_name, "' is registered as a count variable. Linear ",
        "regression expects an interval outcome.",
        call. = FALSE
      )
    } else if (!dv_asserted_numeric) {
      warning(
        "'", dv_name, "' is the outcome variable but looks like a count ",
        "(small-range non-negative integers). Linear regression expects an ",
        "interval outcome.",
        call. = FALSE
      )
    }
    # asserted numeric: hedge suppressed, no warning.
  } else if (.jst_is_discrete_integer(data[[dv_name]], dv_name,
                                      .jst_data_name) &&
             !dv_asserted_numeric) {
    # Non-dichotomous but categorical-like (e.g. a Likert item used as DV).
    # Suppressed when the DV's numeric role is user-asserted (jnumeric /
    # per-call numeric=).
    warning(
      "'", dv_name, "' is the outcome variable but looks categorical (few ",
      "distinct or labelled values). Linear regression expects an interval ",
      "outcome.",
      call. = FALSE
    )
  }

  # Validate override arguments against model variables
  iv_names <- setdiff(model_vars, c(dv_name, dummy_coef_names))
  # expanded_originals (the originals actually expanded into dummy columns)
  # comes from .jst_expand_dummies() above -- registered minus any skipped by a
  # numeric=/count= override (Option B) -- so a skip-overridden variable is NOT
  # removed here and remains a (numeric) IV. dummy_regs (the full registration
  # list) is still needed downstream by .jst_collect_multicat_regs().
  dummy_regs <- .jst_get_dummy(.jst_data_name)
  iv_names   <- setdiff(iv_names, expanded_originals)

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
    # Any unmatched numeric = name is a genuine typo: it is neither a model IV
    # nor a registered dummy (a registered dummy named here was skipped from
    # expansion upstream under Option B and so remains an IV).
    bad <- setdiff(numeric, iv_names)
    if (length(bad) > 0) {
      .jst_stop(
        "numeric argument: ",
        paste0("'", bad, "'", collapse = ", "),
        " not found among independent variables in ", .jst_data_name,
        ". Check for typos."
      )
    }
    numeric <- intersect(numeric, iv_names)
  }

  if (!is.null(categorical)) {
    bad <- setdiff(categorical, iv_names)
    if (length(bad) > 0) {
      bad_registered <- intersect(bad, expanded_originals)
      bad_unknown    <- setdiff(bad, expanded_originals)
      if (length(bad_registered) > 0) {
        warning(
          "categorical = was ignored for ",
          paste0(bad_registered, collapse = ", "),
          " (already registered as a dummy via jdummy; categorical ",
          "treatment is automatic).",
          call. = FALSE
        )
      }
      if (length(bad_unknown) > 0) {
        .jst_stop(
          "categorical argument: ",
          paste0("'", bad_unknown, "'", collapse = ", "),
          " not found among independent variables in ", .jst_data_name,
          ". Check for typos."
        )
      }
      categorical <- intersect(categorical, iv_names)
    }
  }

  if (!is.null(count)) {
    # Remaining count = names (DV already consumed) are IV predictors; a count
    # IV is just a numeric predictor, so validate exactly like numeric =. Any
    # unmatched name is a typo (a registered dummy named here was skipped from
    # expansion upstream under Option B and remains an IV).
    bad <- setdiff(count, iv_names)
    if (length(bad) > 0) {
      .jst_stop(
        "count argument: ",
        paste0("'", bad, "'", collapse = ", "),
        " not found among independent variables in ", .jst_data_name,
        ". Check for typos."
      )
    }
    count <- intersect(count, iv_names)
  }

  # Check for conflicts between numeric and categorical
  if (!is.null(numeric) && !is.null(categorical)) {
    conflict <- intersect(numeric, categorical)
    if (length(conflict) > 0) {
      .jst_stop(
        paste0("'", conflict, "'", collapse = ", "),
        " listed in both numeric and categorical arguments."
      )
    }
  }

  # A variable cannot be both a count and a categorical (the assertions
  # contradict). count and numeric both mean "numeric-like", so they are not
  # treated as a conflict.
  if (!is.null(count) && !is.null(categorical)) {
    conflict <- intersect(count, categorical)
    if (length(conflict) > 0) {
      .jst_stop(
        paste0("'", conflict, "'", collapse = ", "),
        " listed in both count and categorical arguments."
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
      reg <- .jst_make_dummy_names(data[[v]], v, ref = "first",
                                   data_name = .jst_data_name)
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
      reg <- .jst_make_dummy_names(data[[v]], v, ref = "first",
                                   data_name = .jst_data_name)
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
      # not need dummy-coding, and the discrete-integer hedge below would
      # be misleading for them. Coding-specific notes only (off-minimal;
      # the fitted result is identical either way -- Rule Q: the steer is
      # data-shape, not a different model):
      #   - 0/1, factor, character, logical: no note, clean run.
      #   - 1/2: registering as a dummy clarifies the intercept.
      #   - other (e.g., 5/10): non-0/1 codes; same dummy/recode steer.
      iv_dich <- .jst_is_dichotomy(data[[v]])
      if (iv_dich$is_dichotomy) {
        if (!identical(getOption(".jst_output_level", "standard"), "minimal")) {
          if (iv_dich$coding == "1/2") {
            message(
              "Note: ", v, " is a 1/2 dichotomy. The model runs correctly, but ",
              "registering ", v, " as a dummy can help interpret the intercept:\n",
              "  jdummy(", .jst_data_name, ", ", v, ")\n",
              "Or recode to a permanent 0/1 variable with jrecode()."
            )
          } else if (iv_dich$coding == "other") {
            message(
              "Note: ", v, " is a dichotomy with non-0/1 codes. The model runs ",
              "correctly, but registering ", v, " as a dummy can help interpret ",
              "the intercept:\n",
              "  jdummy(", .jst_data_name, ", ", v, ")\n",
              "Or recode to a permanent 0/1 variable with jrecode()."
            )
          }
        }
        # 0/1, factor, character, logical: no note.
      } else if (.jst_is_discrete_integer(data[[v]], v, .jst_data_name) &&
                 !.jst_role_asserted_numeric(data[[v]], v, .jst_data_name)) {
        # Non-dichotomous but categorical-like structure: emit the
        # informational warning so the user can confirm continuous
        # treatment or switch to categorical. Suppressed when the user has
        # asserted a numeric/count role (jnumeric/jcount) -- the hedge is a
        # guess they have already answered. (A per-call numeric=/count= IV
        # short-circuits earlier, so only registration reaches this gate.)
        # The formula deparses in its post-resolve form, where a computed
        # transform is a backticked column name; strip the backticks so
        # the suggested rerun reads as what the user typed (AUDIT-030).
        warning(
          v, " seems categorical. To treat it that way, register it with ",
          "jdummy() and rerun:\n\n",
          "  jdummy(", .jst_data_name, ", ", v, ")\n",
          "  jlm(", .jst_unbacktick(deparse(formula)), ")\n\n",
          "Or: jlm(", .jst_unbacktick(deparse(formula)),
          ", categorical = \"", v, "\")",
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
    analysis_vars   = raw_vars,
    n_analysis      = nrow(mf),
    transform_na    = resolved$introduced_na
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
    .jst_stop("All cases were excluded by the pipeline and/or listwise ",
         "deletion; no model can be fit. See the Case Processing ",
         "Summary above to identify which stage(s) excluded the cases.")
  }

  # Zero-variance predictor check: any IV with only one unique value in
  # the analytic sample. Skip the response (column 1 of mf) and intercept.
  iv_cols <- mf[, -1L, drop = FALSE]
  if (ncol(iv_cols) > 0L) {
    n_unique <- vapply(iv_cols, function(x) length(unique(x)), integer(1))
    constant_ivs <- names(n_unique)[n_unique < 2L]
    if (length(constant_ivs) > 0L) {
      .jst_stop("The following predictor(s) have no variation in the ",
           "analysis sample (only one unique value); cannot fit slope: ",
           paste(constant_ivs, collapse = ", "), ". This often happens ",
           "when jsubset() restricts the sample to a single category of ",
           "a variable that is then used as a predictor.")
    }
  }

  model         <- stats::lm(formula, data = mf)
  model_summary <- summary(model)

  coefs <- as.data.frame(model_summary$coefficients, stringsAsFactors = FALSE)
  colnames(coefs)[1:4] <- c("b", "StdErr", "t", "P")
  # Resolved-transform columns fit under backticked names; normalize the
  # design-matrix keys once here so every downstream match (std/Gelman
  # betas, model.matrix lookup, display cleaning, japa term keys) sees the
  # clean column-name form. No-op for ordinary names.
  rownames(coefs) <- .jst_unbacktick(rownames(coefs))

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
  names(std_coefs) <- .jst_unbacktick(names(std_coefs))
  std_b            <- rep(NA_real_, nrow(coefs))
  names(std_b)     <- rownames(coefs)
  common           <- intersect(names(std_coefs), names(std_b))
  std_b[common]    <- std_coefs[common]

  if ("(Intercept)" %in% names(std_b)) std_b["(Intercept)"] <- NA_real_

  # `std_b` now holds the FULL regular standardized beta for every coefficient
  # (intercept excepted). It is no longer blanked in place: the returned object
  # carries these full values (coefficients_raw$beta), and suppression of the
  # prevalence-scaled dummy/dichotomy betas is a display-only step applied to a
  # separate `disp_beta` copy below. (Session 128 -- replaces the v0.9.33
  # blank_dummy_beta in-place mechanism, whose comment claimed display-only but
  # in fact wrote the NA into the returned value.)

  # Gelman (2008) standardized betas, computed alongside the regular ones and
  # carried on the return regardless of which regime is displayed. Continuous
  # predictors are placed on a divide-by-2-SD scale; binary predictors (0/1
  # indicators, including each factor dummy column) keep their raw 0/1 contrast;
  # the outcome is left in its natural units (arm::standardize's standardize.y =
  # FALSE default -- built here, not depended on). Because the outcome is
  # unscaled, a Gelman beta is just the raw coefficient rescaled per predictor --
  # b * 2 * SD(x) for a continuous column, b unchanged for a binary column -- so
  # it is read off the fitted model with no refit. Centering shifts only the
  # intercept, not the slopes, so it does not affect this column.
  gelman_b        <- rep(NA_real_, nrow(coefs))
  names(gelman_b) <- rownames(coefs)
  b_named         <- stats::setNames(coefs$b, rownames(coefs))
  mm              <- stats::model.matrix(model)
  colnames(mm)    <- .jst_unbacktick(colnames(mm))
  for (nm in rownames(coefs)) {
    if (identical(nm, "(Intercept)")) next
    if (!nm %in% colnames(mm)) next
    col   <- mm[, nm]
    n_uni <- length(unique(col))
    gelman_b[nm] <- if (n_uni <= 2L) b_named[[nm]]
                    else b_named[[nm]] * 2 * stats::sd(col)
  }

  # Display-suppression set for the default "regular" regime: every 0/1
  # indicator, whose fully-standardized beta is scaled by category prevalence
  # rather than a meaningful unit and so is not comparable to the continuous
  # betas. Three sources -- (1) factor terms (each expands to one or more 0/1
  # dummy columns), (2) jdummy-registered variables, and (3) flat numeric
  # dichotomies (a single 0/1 contrast row; the Session-128 A-lock that brings
  # the standalone dichotomy into line with the grouped/factor rows). Display
  # only -- the full values stay on the return.
  factor_terms  <- names(mf)[vapply(mf, is.factor, logical(1))]
  regular_blank <- character(0)
  for (term in factor_terms) {
    regular_blank <- c(regular_blank,
                       grep(paste0("^", term), rownames(coefs), value = TRUE))
  }
  if (length(dummy_coef_names) > 0) {
    regular_blank <- c(regular_blank, intersect(dummy_coef_names, rownames(coefs)))
  }
  resp_col <- names(mf)[1L]
  for (nm in names(mf)) {
    if (identical(nm, resp_col)) next
    col <- mf[[nm]]
    if (is.numeric(col) && length(unique(stats::na.omit(col))) == 2L &&
        nm %in% rownames(coefs)) {
      regular_blank <- c(regular_blank, nm)
    }
  }
  regular_blank <- unique(regular_blank)

  # The standardized-beta vector actually printed, per the `std` regime:
  #   "regular" (default) -- regular betas, every 0/1 indicator suppressed
  #   "all"               -- regular betas, nothing suppressed
  #   "gelman"            -- Gelman betas (all shown; not prevalence-distorted)
  #   "none"              -- the column is omitted entirely (handled at render)
  disp_beta <- if (identical(std, "gelman")) gelman_b else std_b
  if (identical(std, "regular")) {
    disp_beta[names(disp_beta) %in% regular_blank] <- NA_real_
  }
  show_beta_col <- !identical(std, "none")

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
                                            all.vars(formula)[-1],
                                            skip = dummy_coef_names)

  out_coefs <- data.frame(
    b       = fmt3(coefs$b),
    StdErr  = fmt3(coefs$StdErr),
    t       = fmt3(coefs$t),
    Beta    = ifelse(is.na(disp_beta), "",
                     sprintf(paste0("%.", digits_n, "f"), as.numeric(disp_beta))),
    P       = p_fmt,
    stringsAsFactors = FALSE,
    row.names = rownames(coefs)
  )
  # std = "none": drop the standardized-beta column entirely (the header and
  # alignment vectors built below mirror this absence).
  if (!show_beta_col) out_coefs$Beta <- NULL

  # When `ci` is on, append the 95% CI bounds at the right end of the table
  # (after p -- the jlogistic append pattern). fmt3 applies the digits option and
  # the negative-zero / leading-zero normalisation, same as the b column. On
  # grouped multi-category dummy rows these columns ride through
  # .jst_group_dummy_coefs() per category untouched (the CI tracks the raw b);
  # the `std` regime governs only the Beta column, leaving the CI independent of
  # which standardization is displayed. (Session 69; std switch Session 128)
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
  # Full precision, computed once; the _raw values are stored at the top level.
  ss_total_raw      <- sum((y - mean(y))^2)
  ss_regression_raw <- sum((stats::fitted(model) - mean(y))^2)
  ss_residual_raw   <- sum(stats::residuals(model)^2)
  # Display copies feed the existing sprintf below unchanged. The round() step is
  # kept (NOT folded into sprintf on the _raw value) so R's round-half-to-even and
  # sprintf's tie-breaking cannot diverge on half-way cases -- the printout stays
  # byte-identical; only the stored top-level value moves to full precision.
  # (Session 99 precision-flatten, Option C)
  ss_total      <- round(ss_total_raw, digits_n)
  ss_regression <- round(ss_regression_raw, digits_n)
  ss_residual   <- round(ss_residual_raw, digits_n)

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
  # The standardized-beta header carries the regime: bare "\u03b2" for the
  # regular betas (default and "all"), "Gelman \u03b2" for the Gelman regime so
  # the value is not misread as a classic beta. Under std = "none" the column is
  # absent (out_coefs$Beta was dropped above), so it is left out of both the name
  # and alignment vectors. .jst_print_table sizes each column to the wider of
  # header and contents, so the longer Gelman header simply widens that one
  # column while keeping the header centered and the numbers decimal-aligned.
  if (show_beta_col) {
    beta_header    <- if (identical(std, "gelman")) "Gelman \u03b2" else "\u03b2"
    coef_col_names <- c("b", "SE", "t", beta_header, "p")
    coef_align     <- c("d", "d", "d", "d", "d")
  } else {
    coef_col_names <- c("b", "SE", "t", "p")
    coef_align     <- c("d", "d", "d", "d")
  }
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
            " - use the back arrow in the Plots pane to view all)\n",
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
  # `beta` is the FULL regular standardized coefficient (every predictor, never
  # blanked -- the console suppresses prevalence-scaled dummy/dichotomy betas at
  # print time only, so a later collector receives full values and applies its
  # own policy); `beta_gelman` is the full Gelman-scaled coefficient (Session
  # 128); the CI bounds are present regardless of the `ci` display toggle. First
  # down-payment on the cross-function return-shape audit -- the accessor
  # contract and final key form remain that item's keystones. (Session 69)
  coefficients_raw <- data.frame(
    term     = term_keys,
    b        = unname(coefs$b),
    SE       = unname(coefs$StdErr),
    t        = unname(coefs$t),
    df       = res_df,
    p        = suppressWarnings(as.numeric(coefs$P)),
    beta        = unname(std_b[term_keys]),
    beta_gelman = unname(gelman_b[term_keys]),
    ci_lower = unname(ci_lower_raw),
    ci_upper = unname(ci_upper_raw),
    stringsAsFactors = FALSE,
    row.names = NULL
  )
  # `beta` holds regular standardization; `beta_gelman` holds the Gelman regime;
  # both are always present. `std_displayed` records which regime the console
  # showed -- a display choice, not a property of the stored values.
  attr(coefficients_raw, "beta_standardization") <- "regular"
  attr(coefficients_raw, "std_displayed") <- std
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
    # Top-level scalar fit stats carry full precision; the digits feature still
    # governs the printout via the rounded locals above. r_squared / adj_r_squared /
    # residual_se / f_statistic derive from fit_raw (one computation, no drift); SS
    # sources the full-precision _raw locals because SS is not mirrored in fit_raw.
    # (Session 99 precision-flatten, Option C)
    r_squared       = fit_raw$r_squared,
    adj_r_squared   = fit_raw$adj_r_squared,
    residual_se     = fit_raw$sigma,
    f_statistic     = c(value = fit_raw$f_value, df1 = fit_raw$f_df1,
                        df2 = fit_raw$f_df2, p = fit_raw$f_p),
    sums_of_squares = c(regression = ss_regression_raw,
                        residual   = ss_residual_raw,
                        total      = ss_total_raw),
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
#' @details
#' Transformed predictor terms in \code{formula} are computed
#' automatically. A term that applies a function to a variable --
#' \code{log(x)}, \code{sqrt(x)}, \code{exp(x)}, \code{I(x^2)},
#' \code{scale(x)}, an arithmetic expression, or a logical condition such
#' as \code{I(x > 10)} -- is evaluated once on the analysis data and enters
#' the model as a single derived column named for the expression, so the
#' coefficient table and the diagnostics report the term as written. This
#' follows the base R formula convention; the terms supported inline are
#' those that evaluate to one numeric or logical column. Terms that produce
#' several columns (\code{poly(x, 2)}, spline bases) or a categorical
#' result (\code{cut(x, 3)}) are not supported inline: create the derived
#' variable as a column of the data first, then name that column in the
#' formula. (The dependent variable must be a plain 0/1 dichotomy, so a
#' transform applies to predictors, not the response.)
#'
#' @param formula A model formula, e.g. \code{DV ~ IV1 + IV2}. The DV
#'   must be a binary variable coded 0/1. Transformed predictor terms such
#'   as \code{log(IV1)} are computed automatically and used throughout the
#'   output.
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
#' # With explicit data frame -- Volunteer is already coded 0/1
#' jlogistic(Volunteer ~ Income + Age, data = community)
#'
#' # A 1/2-coded dichotomy (Yes = 1, No = 2) must be recoded to 0/1 first
#' df <- community
#' df$OwnsHome01 <- jrecode(df, OwnsHome,
#'                          map = "1=1; 2=0", labels = "0=No; 1=Yes")
#' jlogistic(OwnsHome01 ~ Income + Age, data = df)
#'
#' # Using juse() default
#' juse(community)
#' jlogistic(Volunteer ~ Income + Age)
#'
#' # CATEGORICAL PREDICTORS
#' #
#' # Per-call: categorical = ... applies for one call only and does not
#' # persist.
#' jlogistic(Volunteer ~ Region + Age, categorical = "Region")
#'
#' # The recommended approach for repeated analyses: register the variable
#' # with jdummy() before running jlogistic(). This sets categorical
#' # treatment persistently across subsequent analyses.
#' jdummy(community, Region)
#' jlogistic(Volunteer ~ Region + Age)
#'
#' # To choose a non-default reference category:
#' jdummy(community, Region, ref = "West")
#' jlogistic(Volunteer ~ Region + Age)
#'
#' # FORCING NUMERIC TREATMENT
#' #
#' # Use numeric = ... when a labelled variable should enter as a score.
#' jlogistic(Volunteer ~ Age + Education, numeric = "Education")
#'
#' # Not normally needed. You'd clear a default or registration only to
#' # undo a mistake, or -- as in this example -- to reset state for testing.
#' jdummy(community, NULL)
#' juse(NULL)
#'
#' @seealso \code{\link{jstats}} for the package overview,
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
    .jst_stop("value.id '", value.id, "' is not supported here.")
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
    example    = "DV ~ IV",
    fn         = "jlogistic"
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

  # Raw-name existence check first, so the transform resolver below can
  # assume every plain variable in the formula exists.
  # Underlying variable names (pre-transform). Drives the existence check
  # and, below, the case-processing breakdown -- so a transformed term is
  # reported against its source column, which the pre-pipeline snapshot
  # contains (the computed column is not in that snapshot).
  raw_vars <- all.vars(formula)
  .jst_check_vars(data, raw_vars, .jst_data_name,
                  default_used = .jst_default_used)

  # Transformed-term front door (AUDIT-021; supersedes the AUDIT-005
  # refusal): compute log(x), I(x^2), and the like once on the analysis
  # copy and rewrite the formula to reference the computed column. See the
  # matching block in jlm.
  resolved <- .jst_resolve_formula_transforms(formula, data, .jst_data_name)
  formula  <- resolved$formula
  data     <- resolved$data

  model_vars            <- all.vars(formula)
  dv_name               <- model_vars[1]

  # Preserve the original (pre-expansion) variable names for use in
  # missing-by-variable reporting. After dummy expansion, model_vars
  # holds the dummy column names; the user wrote the originals in
  # the formula and the diagnostic should speak the user's language. (A
  # resolved transform keeps the user's language automatically: its column
  # is named with the term's own text.)
  original_formula_vars <- model_vars

  # DV-as-IV guard (Session 105): see the matching block in jlm. Checked on
  # the resolved formula, before dummy expansion can rewrite the
  # right-hand side.
  dup_var <- .jst_formula_dup_var(formula)
  if (!is.null(dup_var)) {
    .jst_stop(paste0("'", dup_var, "' appears as both the dependent variable ",
                     "and an independent variable.\n",
                     "Each variable can only play one role in a regression."))
  }

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
  expanded         <- .jst_expand_dummies(data, formula, .jst_data_name,
                                          numeric = numeric, count = count)
  data               <- expanded$data
  formula            <- expanded$formula
  ref_cats           <- expanded$ref_cats
  dummy_coef_names   <- expanded$dummy_coef_names
  expanded_originals <- expanded$expanded_originals
  model_vars         <- all.vars(formula)

  # (Option B) A per-call numeric =/ count = naming a registered dummy IV is
  # consulted inside .jst_expand_dummies() above, which skips that variable's
  # expansion and emits the precedence note/warning. The variable then arrives
  # as its original numeric column and is handled by the numeric/count branch
  # of the IV loop below; the stored registration is unchanged.

  # -- Variable type conversion (unified classifier) ------------------------
  # Priority order:
  #   1. jdummy() registrations (already expanded above)
  #   2. numeric/count/categorical overrides from this call
  #   3. Auto-detection via .jst_is_categorical()
  # DV is always numeric; handled after this loop. (numeric=/count=/categorical=
  # naming the DV is a no-op here -- the DV is excluded from iv_names below and
  # the binary response is fixed regardless of any role assertion.)
  dv_name  <- all.vars(formula)[1]
  .jst_check_dummy_outcome(.jst_data_name, dv_name, "jlogistic")
  iv_names <- setdiff(model_vars, c(dv_name, dummy_coef_names))

  auto_detected  <- character(0)
  auto_ref_cats  <- character(0)
  auto_cat_regs  <- list()  # in-flight registrations for auto-cat / categorical = vars
  all_ref_cats   <- ref_cats

  # Originals actually expanded into dummy columns come from
  # .jst_expand_dummies() (captured above as expanded_originals): the set it
  # expanded, i.e. registered minus any skipped by a numeric=/count= override
  # (Option B). A skip-overridden variable is therefore NOT in this set and is
  # handled by the numeric/count branch of the loop below. dummy_regs (the full
  # registration list) is still needed downstream by .jst_collect_multicat_regs().
  dummy_regs <- .jst_get_dummy(.jst_data_name)

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
      reg <- .jst_make_dummy_names(data[[v]], v, ref = "first",
                                   data_name = .jst_data_name)
      auto_cat_regs[[v]] <- reg
      for (n in reg$notes) cat(n, "\n", sep = "")
      for (w in reg$warnings_msg) warning(w, call. = FALSE)
      auto_ref_cats <- c(auto_ref_cats,
                         paste0(v, " = ", reg$ref_label))
      next
    }

    # --- Auto-detection via unified classifier ---
    if (.jst_is_categorical(data[[v]], v, .jst_data_name)) {
      reg <- .jst_make_dummy_names(data[[v]], v, ref = "first",
                                   data_name = .jst_data_name)
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
      # contrast). They do not need dummy-coding, and the discrete-integer
      # hedge below would be misleading for them. Coding-specific notes
      # only (off-minimal; the fitted result is identical either way --
      # Rule Q: the steer is data-shape, not a different model):
      #   - 0/1, factor, character, logical: no note, clean run.
      #   - 1/2: registering as a dummy clarifies the intercept.
      #   - other (e.g., 5/10): non-0/1 codes; same dummy/recode steer.
      iv_dich <- .jst_is_dichotomy(data[[v]])
      if (iv_dich$is_dichotomy) {
        if (!identical(getOption(".jst_output_level", "standard"), "minimal")) {
          if (iv_dich$coding == "1/2") {
            message(
              "Note: ", v, " is a 1/2 dichotomy. The model runs correctly, but ",
              "registering ", v, " as a dummy can help interpret the intercept:\n",
              "  jdummy(", .jst_data_name, ", ", v, ")\n",
              "Or recode to a permanent 0/1 variable with jrecode()."
            )
          } else if (iv_dich$coding == "other") {
            message(
              "Note: ", v, " is a dichotomy with non-0/1 codes. The model runs ",
              "correctly, but registering ", v, " as a dummy can help interpret ",
              "the intercept:\n",
              "  jdummy(", .jst_data_name, ", ", v, ")\n",
              "Or recode to a permanent 0/1 variable with jrecode()."
            )
          }
        }
        # 0/1, factor, character, logical: no note.
      } else if (.jst_is_discrete_integer(data[[v]], v, .jst_data_name) &&
                 !.jst_role_asserted_numeric(data[[v]], v, .jst_data_name)) {
        # Non-dichotomous but categorical-like structure: emit the
        # informational warning so the user can confirm continuous
        # treatment or switch to categorical. Suppressed when the user has
        # asserted a numeric/count role (jnumeric/jcount).
        # The formula deparses in its post-resolve form, where a computed
        # transform is a backticked column name; strip the backticks so
        # the suggested rerun reads as what the user typed (AUDIT-030).
        warning(
          v, " seems categorical. To treat it that way, register it with ",
          "jdummy() and rerun:\n\n",
          "  jdummy(", .jst_data_name, ", ", v, ")\n",
          "  jlogistic(", .jst_unbacktick(deparse(formula)), ")\n\n",
          "Or: jlogistic(", .jst_unbacktick(deparse(formula)),
          ", categorical = \"", v, "\")",
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
      .jst_stop(paste0(
        "'", dv_name, "' has only one value. Logistic regression requires a ",
        "binary outcome variable."
      ))
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
      .jst_stop(paste0(
        "'", dv_name, "' has ", length(u_norm),
        if (length(u_norm) == 1L) " category" else " categories",
        " (", paste(n_show, collapse = ", "),
        if (length(unique(nonmiss)) > 5L) ", ..." else "", ").\n",
        "Logistic regression requires the outcome to have exactly two ",
        "categories.\nRecode to a 0/1 variable before running jlogistic()."
      ))
    }

    # Representative original-cased label for each normalized category.
    disp <- vapply(u_norm, function(z) nonmiss[norm == z][1], character(1))
    disp <- unname(disp)
    mb   <- .jst_match_binary_tokens(disp)

    if (!mb$recognized) {
      .jst_stop(paste0(
        "'", dv_name, "' has text categories ",
        paste(disp, collapse = "/"),
        ". Recode to a 0/1 variable so the modeled category is explicit:\n",
        "  ", .jst_data_name, "$", dv_name, "R <- jrecode(", .jst_data_name, ", ",
        dv_name, ", map = \"", disp[1], "=0; ", disp[2], "=1\")\n",
        "Then use ", dv_name, "R as your dependent variable (the category mapped ",
        "to 1 is the one jlogistic models)."
      ))
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
      .jst_stop(paste0(
        "'", dv_name, "' is coded 1/2. Logistic regression requires 0/1 coding.\n",
        "Recode before running jlogistic():\n",
        "  ", .jst_data_name, "$", dv_name, "R <- jrecode(", .jst_data_name, ", ", dv_name,
        ", map = \"1=0; 2=1\"", recode_labels, ")\n",
        "Then use ", dv_name, "R as your dependent variable.\n",
        "(jlogistic models the category coded 1; to model the other category ",
        "instead, reverse the map and labels.)"
      ))

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
        .jst_stop(paste0(
          "'", dv_name, "' has ", n_unique, " unique values (",
          paste(unique_vals, collapse = ", "),
          "). The dependent variable must have exactly 2 categories coded 0/1.\n",
          "The value(s) ", miss_str, " may be coded missing value(s).\n",
          "Convert to NA before running jlogistic():\n",
          "  ", .jst_data_name, "$", dv_name, "R <- jrecode(", .jst_data_name, ", ", dv_name,
          ", map = \"", paste0(coded_miss, "=NA", collapse = "; "),
          "; else=copy\")"
        ))
      } else {
        .jst_stop(paste0(
          "'", dv_name, "' has values: ",
          paste(unique_vals, collapse = ", "),
          ". Logistic regression requires a binary variable coded 0/1.\n",
          "Use jrecode() to create a 0/1 coded version before running jlogistic()."
        ))
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
    analysis_vars   = raw_vars,
    n_analysis      = nrow(mf),
    transform_na    = resolved$introduced_na
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
  # Resolved-transform columns fit under backticked names; normalize the
  # design-matrix keys once here (see the matching line in jlm).
  rownames(coefs) <- .jst_unbacktick(rownames(coefs))

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
                                            all.vars(formula)[-1],
                                            skip = dummy_coef_names)

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
        names(vif_vals) <- .jst_unbacktick(colnames(X))
        vif_vals
      }, error = function(e) {
        message("VIF could not be computed (possible perfect collinearity).")
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
        names(vif_vals) <- .jst_unbacktick(colnames(X))
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
#' @param ... Unquoted variable names (scale items) within \code{data}. Use
#'   colon notation (e.g. \code{Item1:Item6}) to select a range of consecutive
#'   columns.
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
#' jalpha(community, Environment1, Environment2, Environment3,
#'        Environment4, Environment5)
#'
#' # Using juse() default
#' juse(community)
#' jalpha(Environment1, Environment2, Environment3, Environment4,
#'        Environment5)
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
    .jst_stop("value.id is not supported here; it does not display ",
         "value labels.")
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

  # Resolve variable names, expanding colon ranges (e.g. Item1:Item6) the same
  # way jsum()/javg() do via .jst_resolve_varrange(); plain names pass through
  # unchanged.
  resolved       <- .jst_resolve_varrange(variables, data, "jalpha", .jst_data_name)
  variable_names <- resolved$var_names

  .jst_check_vars(data, variable_names, .jst_data_name, default_used = .jst_default_used)
  # Type gate (Session 46): scale items must be numeric; refuse text, dates,
  # and complex/list/raw. See .jst_check_analysis_var.
  for (.gv in variable_names) .jst_check_analysis_var(data[[.gv]], .gv, TRUE, "Cronbach's alpha")

  if (length(variable_names) < 2) {
    .jst_stop(paste0(
      "At least 2 items are required. ",
      if (length(variable_names) == 0) "None were provided."
      else "Only 1 was provided."
    ))
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

  # Assumption-check warning (audit): nudge only on a declared contradiction --
  # an item the user registered as categorical via jdummy() and is now putting
  # into a reliability analysis. Likert items (including yes/no items, the KR-20
  # case) and other numeric items stay silent; the warning fires only when the
  # categorical intent is explicit.
  .dummy_regs <- .jst_get_dummy(.jst_data_name)
  if (!is.null(.dummy_regs) && length(.dummy_regs) > 0) {
    for (v in variable_names) {
      if (any(vapply(.dummy_regs,
                     function(r) identical(r$var_name, v), logical(1)))) {
        warning(.jst_assumption_warning(v, "jalpha"), call. = FALSE)
      }
    }
  }

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
        ".\nThey may need reverse-coding, or may not belong in the scale ",
        "- check the item-total table and the item wording."),
        call. = FALSE)
    } else {
      warning(paste0(
        "Most items are negatively correlated with the scale total - ",
        "usually a sign the scale is keyed in the opposite direction, or ",
        "some items don't belong.\nThe item(s) that are positively ",
        "correlated while most aren't: ",
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
