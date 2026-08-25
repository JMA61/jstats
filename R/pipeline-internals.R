#<<<FILE: pipeline-internals.R>>>

#' Internal helper: apply a logical mask expression to a data frame
#'
#' Shared mechanic for Step 2 (persistent jsubset) and Step 3 (per-call
#' \code{subset =} argument) of \code{.jst_apply_pipeline()}. Evaluates
#' \code{expr} in the data + caller environment, coerces \code{NA}s in
#' the resulting mask to \code{FALSE}, and returns the filtered data
#' frame. The two callers differ in upstream source (joptions state vs.
#' argument) and downstream bookkeeping (which \code{sample_info} slot
#' is populated); the masking step itself is identical.
#'
#' @param data Data frame to mask.
#' @param expr Unevaluated logical expression (a language object).
#' @param envir Environment to evaluate \code{expr} in. Data columns
#'   take precedence; \code{envir} provides fallback bindings.
#' @param on_error One of \code{"warn"} or \code{"stop"}. \code{"warn"}
#'   emits a warning and returns the data unchanged -- used for the
#'   persistent jsubset state, where the expression was validated when
#'   set and a runtime failure is unexpected. \code{"stop"} raises an
#'   error -- used for the per-call \code{subset =} argument, where a
#'   broken expression is a user error at call time.
#' @param stage_label Character. Prefix used in the error/warning
#'   message (e.g. \code{"jsubset"} or \code{"Subset"}) so failures
#'   are attributable to the right pipeline stage.
#'
#' @return The data frame filtered to rows where \code{expr} evaluates
#'   to \code{TRUE} (\code{NA} treated as \code{FALSE}).
#'
#' @keywords internal
.jst_apply_mask <- function(data, expr, envir, on_error, stage_label) {
  on_error <- match.arg(on_error, c("warn", "stop"))
  mask <- tryCatch(
    eval(expr, data, envir),
    error = function(e) {
      msg <- paste0(stage_label, " expression could not be evaluated: ",
                    conditionMessage(e))
      if (on_error == "warn") {
        .jst_warn(msg)
        rep(TRUE, nrow(data))
      } else {
        stop(msg, call. = FALSE)
      }
    }
  )
  mask[is.na(mask)] <- FALSE
  # Variable-label loss from `[.data.frame` row subsetting (plain atomic and
  # factor columns lose their label; haven_labelled keep theirs) is restored
  # once at the end of .jst_apply_pipeline, from the pre-pipeline snapshot, which
  # covers this path plus jcomplete's direct subset uniformly.
  data[mask, , drop = FALSE]
}

#' Internal helper: apply the full data pipeline and return filtered data + messages
#'
#' Order of operations:
#' \enumerate{
#'   \item jcomplete (listwise deletion for registered variables)
#'   \item jsubset (persistent case-selection expression)
#'   \item subset (one-off per-call case-selection expression)
#' }
#'
#' jcomplete and jsubset are keyed per-dataset. They apply whenever the
#' matching dataset is used, regardless of whether that dataset was supplied
#' via the juse() default or specified explicitly in the function call.
#' This matches the SPSS FILTER model: persistent state remains in effect
#' until explicitly turned off via jsubset(off) / jcomplete(off).
#'
#' When the current dataset has no jsubset / jcomplete set but at least one
#' other dataset does have an active setting, a yellow-colored note is
#' included in the pipeline messages to remind the user that case selection
#' is not active for this particular dataset.
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

  # Snapshot the pre-masking data so the CPS bottom can compute source/pool
  # per-code counts from intact UDM codes (the masking pass below converts
  # SPSS-form UDM cells to NA destructively). Survival is tracked via a
  # temporary integer id column (rownames are unreliable on tibbles, which
  # the course datasets are); the column rides through the row-subsetting
  # filters and is read off — then removed — at the end. Operates on the
  # local analysis copy only; the user's frame is untouched.
  pre_pipeline_data <- data

  # Pipeline count tracking
  n_after_complete <- NULL
  n_after_filter   <- NULL
  n_after_subset   <- NULL
  complete_active  <- FALSE
  filter_active    <- FALSE
  filter_expr_str  <- NULL
  complete_vars    <- NULL

  # -- Step 0: declared UDM masking on the analysis copy --------------------
  # Mask values declared as user-defined missing values (UDMs) to NA on a
  # copy of the data frame used for this analysis; the user's workspace
  # data frame is unchanged. SPSS-form declarations (na_values / na_range)
  # keep their attributes attached; Stata/SAS-form tagged NAs are zapped
  # (cells to plain NA, tag labels removed) so haven::as_factor() at the
  # downstream conversion sites cannot revive a labelled tag as a factor
  # level (AUDIT-039). Counts are unaffected either way: tagged cells
  # already satisfied is.na(). Full rationale at
  # .jst_apply_declared_udms_as_na(). Replaces the former auto-NA-by-label
  # mechanism (.jst_preprocess_na, retired in v0.9.5) per Cross-cutting
  # Decision 5 of JStats_Missing_Values_Reference.txt Part 4.
  #
  # The whole-DF YELLOW notice that previously announced UDM masking was
  # dropped in v0.9.6 — the information is now surfaced per-variable via
  # jfreq's Missing section and via the Case Processing Summary, scoped to
  # the variables the analysis actually touches.
  udm_result <- .jst_apply_declared_udms_as_na(data)
  data       <- udm_result$data

  # Temporary survival-tracking id (removed before this function returns).
  # Added after masking (which preserves row order) and before filtering, so
  # the surviving values are the original 1..n_original row positions.
  data$.jst_row_id <- seq_len(n_original)

  # -- Step 1: jcomplete -----------------------------------------------------
  # Applied whenever a jcomplete is set on the current dataset (by name),
  # regardless of whether that dataset was supplied via juse() default or
  # explicitly in the call. This matches the SPSS FILTER convention: state
  # persists until explicitly turned off, not bypassed by dataset mention.
  cs <- .jst_get_complete(data_name)
  if (!is.null(cs)) {
    if (cs$active) {
      complete_active <- TRUE
      valid_vars <- cs$vars[cs$vars %in% names(data)]
      complete_vars <- valid_vars
      if (length(valid_vars) > 0) {
        complete_mask    <- stats::complete.cases(data[, valid_vars, drop = FALSE])
        data             <- data[complete_mask, , drop = FALSE]
        n_after_complete <- nrow(data)
      } else {
        n_after_complete <- nrow(data)
      }
    } else {
      msgs <- c(msgs, "[YELLOW](jcomplete set but inactive)")
    }
  } else {
    # No jcomplete set for this dataset — but one is set elsewhere?
    if (.jst_any_complete_active()) {
      msgs <- c(msgs, "[YELLOW](jcomplete not active for this dataset)")
    }
  }

  # -- Step 2: jsubset -------------------------------------------------------
  fs <- .jst_get_filter(data_name)
  if (!is.null(fs)) {
    if (fs$active) {
      filter_active   <- TRUE
      filter_expr_str <- fs$expr_str
      data            <- .jst_apply_mask(data, fs$expr, envir,
                                         on_error    = "warn",
                                         stage_label = "jsubset")
      n_after_filter  <- nrow(data)
    } else {
      msgs <- c(msgs, "[YELLOW](jsubset set but inactive)")
    }
  } else {
    # No jsubset set for this dataset — but one is set elsewhere?
    if (.jst_any_filter_active()) {
      msgs <- c(msgs, "[YELLOW](jsubset not active for this dataset)")
    }
  }

  # -- Step 3: subset (always applies) -------------------------------------
  # Per-call subset arg. Counts and expression are reported in the Case
  # Processing Summary table; no pipeline message is produced.
  subset_expr_str <- NULL
  if (!is.null(subset_expr)) {
    subset_expr_str <- paste(deparse(subset_expr), collapse = " ")
    data           <- .jst_apply_mask(data, subset_expr, envir,
                                      on_error    = "stop",
                                      stage_label = "Subset")
    n_after_subset <- nrow(data)
  }

  # Recover surviving original row positions, then strip the temp id column
  # so the returned analysis data is clean.
  surviving_ids    <- data$.jst_row_id
  data$.jst_row_id <- NULL

  # Restore variable labels from the pre-pipeline snapshot. Row subsetting via
  # `[.data.frame` (jcomplete's direct subset at Step 1, the jsubset / subset
  # masks, and the temp id-column add/strip) drops the `label` attribute from
  # plain atomic and factor columns; haven_labelled columns keep theirs via their
  # own `[` method. Restoring once here, from the untouched pre_pipeline_data,
  # covers all paths at a single point (a pass that never dropped the label is a
  # no-op). Read by the functions that take the label off the filtered frame
  # (jfreq, jt, jaov, jcrosstab, jcorr); jdesc captures labels before filtering.
  for (nm in names(data)) {
    lab <- attr(pre_pipeline_data[[nm]], "label", exact = TRUE)
    if (!is.null(lab) && is.null(attr(data[[nm]], "label", exact = TRUE))) {
      attr(data[[nm]], "label") <- lab
    }
  }

  pipeline_counts <- list(
    n_original       = n_original,
    n_after_complete = n_after_complete,
    n_after_filter   = n_after_filter,
    n_after_subset   = n_after_subset,
    complete_active  = complete_active,
    filter_active    = filter_active,
    filter_expr      = filter_expr_str,
    subset_expr      = subset_expr_str,
    # SPSS-form UDM masking activity from Step 0. udm_spss_active = TRUE
    # when at least one variable had declared SPSS-form codes/ranges masked
    # on the analysis copy; udm_spss_masked_vars carries the per-variable
    # detail (entries + n_cells) consumed by jfreq's Missing section.
    # SPSS-only is deliberate: Stata/SAS tag zapping is count-neutral and
    # per-tag display counts come from the pre-pipeline frame -- one count
    # source per number (see the helper's banner).
    udm_spss_active       = length(udm_result$converted) > 0L,
    udm_spss_masked_vars  = udm_result$converted,
    # CPS rendering inputs (Steps 3-6). pre_pipeline_data holds the original
    # rows with UDM codes intact; surviving_ids are the original row numbers
    # that survived the pipeline (the analysis pool). The renderer derives
    # pool_data = pre_pipeline_data[surviving_ids, ] for source/pool counts.
    complete_vars     = complete_vars,
    pre_pipeline_data = pre_pipeline_data,
    surviving_ids     = surviving_ids
  )

  list(data = data, msgs = msgs, pipeline_counts = pipeline_counts)
}

#' Internal helper: print info-line messages generated by the pipeline
#'
#' @keywords internal
.jst_print_msgs <- function(msgs) {
  # One leading blank separates the message block from the note/title above.
  # With .jst_default_note's default now FALSE (Session 52), this is what
  # keeps a single blank line above pipeline messages.
  if (length(msgs) > 0) cat("\n")
  for (m in msgs) {
    yellow <- startsWith(m, "[YELLOW]")
    body   <- if (yellow) sub("^\\[YELLOW\\]", "", m) else m
    # Wrap AFTER the tag is stripped and BEFORE the color is applied: the
    # tag is eight characters that never reach the console, and .cat_yellow()
    # adds nine bytes of ANSI escape that nchar() would count but the user
    # cannot see. Measuring with either attached mis-sizes every line. (S254)
    body <- tryCatch(.jst_wrap_message(body), error = function(e) body)
    if (yellow) {
      .cat_yellow(body)
      cat("\n")
    } else {
      cat(body, "\n")
    }
  }
}

#' Internal helper: build standardized sample_info block
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
#' @param transform_na Named integer vector from
#'   \code{.jst_resolve_formula_transforms()$introduced_na}: per computed
#'   term, the count of non-finite results the resolver converted to NA
#'   (AUDIT-025). NULL (the default) for callers without formula
#'   transforms; carried through for the Case Processing Summary.
#'
#' @return A list with elements: n_original, n_after_complete, n_after_filter,
#'   n_after_subset, n_analysis, n_excluded_missing, missing_by_var,
#'   complete_active, filter_active, filter_expr.
#'
#' @keywords internal
.jst_build_sample_info <- function(pipeline_counts, data, analysis_vars,
                                   n_analysis, transform_na = NULL) {

  # Count missing values per analysis variable in the post-pipeline data
  missing_by_var <- vapply(analysis_vars, function(v) {
    if (v %in% names(data)) sum(is.na(data[[v]])) else 0L
  }, integer(1))

  n_after_pipeline   <- nrow(data)
  n_excluded_missing <- n_after_pipeline - n_analysis

  list(
    n_original         = pipeline_counts$n_original,
    n_after_complete   = pipeline_counts$n_after_complete,
    n_after_filter     = pipeline_counts$n_after_filter,
    n_after_subset     = pipeline_counts$n_after_subset,
    n_after_pipeline   = n_after_pipeline,
    n_analysis         = n_analysis,
    n_excluded_missing = n_excluded_missing,
    missing_by_var     = missing_by_var,
    analysis_vars      = analysis_vars,
    complete_active    = pipeline_counts$complete_active,
    complete_vars      = pipeline_counts$complete_vars,
    filter_active      = pipeline_counts$filter_active,
    filter_expr        = pipeline_counts$filter_expr,
    subset_expr        = pipeline_counts$subset_expr,
    udm_spss_active         = pipeline_counts$udm_spss_active,
    udm_spss_masked_vars    = pipeline_counts$udm_spss_masked_vars,
    pre_pipeline_data  = pipeline_counts$pre_pipeline_data,
    surviving_ids      = pipeline_counts$surviving_ids,
    transform_na       = transform_na
  )
}

# Output level preset defaults (used by .jst_resolve_toggle and joutput)
#
# case.processing supports three states:
#   FALSE - never print CPS
#   TRUE  - always print CPS (even when nothing was excluded)
#   NULL  - "auto": print CPS only when something happened (any pipeline
#           state active, or for listwise=TRUE callers, listwise excluded
#           at least one case)
#
# udm.notice supports three states. Standard and full both use TRUE (always
# show); minimal uses FALSE. The NULL/auto state is retained internally but
# no preset level selects it and joutput() cannot set it, so the narrative
# now shows on every UDM-bearing load unless minimal output is active:
#   FALSE - never print the UDM narrative on jload
#   TRUE  - always print the narrative (every load with UDM-bearing variables)
#   NULL  - "auto": print once per session, then suppress (tracked via the
#           .jst_udm_notice_shown option); no preset level uses this
.jst_output_defaults <- list(
  minimal  = list(effect.size = FALSE,
                  regression.ci = FALSE, means.ci = FALSE, levene = FALSE,
                  posthoc = FALSE, diagnostics = FALSE,
                  case.processing = FALSE, case.processing.detail = "none",
                  variable.id = "names", value.id = "labels",
                  ref.categories = FALSE, digits = 3,
                  udm.notice = FALSE),
  standard = list(effect.size = TRUE,
                  regression.ci = FALSE, means.ci = TRUE,  levene = FALSE,
                  posthoc = FALSE, diagnostics = FALSE,
                  case.processing = NULL,  case.processing.detail = "totals",
                  variable.id = "names", value.id = "both",
                  ref.categories = TRUE, digits = 3,
                  udm.notice = TRUE),
  full     = list(effect.size = TRUE,
                  regression.ci = TRUE,  means.ci = TRUE,  levene = TRUE,
                  posthoc = TRUE,  diagnostics = TRUE,
                  case.processing = TRUE,  case.processing.detail = "per_code",
                  variable.id = "legend", value.id = "both",
                  ref.categories = TRUE, digits = 3,
                  udm.notice = TRUE)
)

# -- joptions defaults --------------------------------------------------------
#
# Single source of truth for joptions slot defaults. Consulted both by
# joptions itself for reset semantics and by downstream readers (jload,
# jconvert, jdeclare_udm, jrecode) via getOption() fallback when no
# explicit setting is present.
#
# Slots:
#   missing.convention   - one of "none", "spss", "stata", "sas".
#                          "none" = no stated preference. A set value
#                          supplies the target convention for fresh UDM
#                          declarations and convention-conditional
#                          recodes (via .jst_resolve_convention), the
#                          default target for jconvert(to = NULL), and
#                          the reference point for the joptions
#                          environment-scan notice.
#   udm.convention.codes - numeric vector, length 1-3, whole numbers,
#                          no duplicates. Recommended UDM code set used
#                          by jconvert for Stata-tag -> SPSS-code mapping.
#   data.dir             - single character string, or NULL. NULL =
#                          jsave writes bare-filename saves to the
#                          working directory; jload bare-filename
#                          searches the working directory. Setting a
#                          value names a folder (relative to working
#                          directory) used for both save target and
#                          load search.
#   missing.detail       - one of "totals", "per_code", "all". Governs how
#                          much of a declared missing-value RANGE jfreq
#                          spells out: "totals" collapses the whole band
#                          into a single row, "per_code" (default) prints
#                          one row per observed in-band value capped at 10,
#                          "all" prints every observed in-band value.
#                          Discrete declared codes always print in full at
#                          every setting.
#   message.width        - "auto", one of the shared width tokens "narrow"
#                          (50), "medium" (76) or "wide" (90), or a whole
#                          number in 40-120. Target width for wrapped
#                          runtime MESSAGE prose; tables are unaffected.
#                          "auto" tracks the console pane live, so it is
#                          resolved per emission rather than cached.
#                          Default is "auto" (Session 256): every emitter
#                          wraps as of the Session 254-255 rollout, and the
#                          emitters reserve for R's own inline chrome, so
#                          adapting to the pane is safe on every route. The
#                          Session 253 hold (errors-only hooking) is over.
.jst_options_defaults <- list(
  missing.convention   = "none",
  udm.convention.codes = c(-99, -98, -97),
  data.dir             = NULL,
  corr.layout          = "wide",
  missing.detail       = "per_code",
  message.width        = "auto"
)

# Row cap applied to IN-BAND rows at missing.detail = "per_code". Declared
# discrete codes are never capped -- they are the user's own declaration.
.jst_missing_detail_cap <- 10L

#' Internal helper: resolve a display toggle value
#'
#' Implements three-tier precedence: (1) explicit per-call argument wins,
#' (2) individual joutput() toggle override, (3) joutput() level default.
#' Per-call arguments use NULL to mean "I didn't specify -- defer to joutput()".
#'
#' @param name Character. Toggle name (e.g. "effect.size", "means.ci", "levene").
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
  level    <- getOption(".jst_output_level", "standard")
  defaults <- .jst_output_defaults
  defaults[[level]][[name]]
}

#' Internal helper: validate and resolve the digits (decimal places) setting
#'
#' Thin wrapper over \code{.jst_resolve_toggle("digits", ...)} that first
#' validates a non-NULL per-call \code{digits} argument: it must be a single
#' whole number in the range 0-7. The resolved value is the number of decimal
#' places shown for continuous tabular statistics; it never governs p-values,
#' case-processing percentages, integer quantities (N, df, counts), or the
#' multicollinearity-warning prose numbers (all fixed by their own
#' conventions). Returns an integer.
#'
#' @param per_call The value of the calling function's \code{digits} argument,
#'   or NULL to defer to joutput().
#'
#' @return Integer in 0-7.
#'
#' @keywords internal
.jst_resolve_digits <- function(per_call) {
  if (!is.null(per_call)) {
    if (length(per_call) != 1L || is.na(per_call) ||
        !is.numeric(per_call) || per_call != as.integer(per_call) ||
        per_call < 0L || per_call > 7L) {
      .jst_stop_arg(arg = "digits", requirement = "a single whole number between 0 and 7.")
    }
  }
  as.integer(.jst_resolve_toggle("digits", per_call))
}

#' Internal helper: build a decimal-places formatter for continuous stats
#'
#' Returns a function that formats a numeric value to \code{digits} decimal
#' places via \code{sprintf("%.<digits>f")}, preserving base R's half-to-even
#' rounding (the option only changes the number of places, never the rounding
#' rule). \code{digits = 0} yields whole numbers with no trailing decimal
#' point. NA formats to the empty string so it renders as a blank cell.
#'
#' @param digits Integer number of decimal places (0-7).
#'
#' @return A function of one argument (coerced via as.numeric) returning a
#'   character string.
#'
#' @keywords internal
.jst_make_fmt <- function(digits) {
  spec <- paste0("%.", digits, "f")
  function(x) {
    x <- suppressWarnings(as.numeric(x))
    ifelse(is.na(x), "", sprintf(spec, x))
  }
}

#' Internal helper: format a p-value for display
#'
#' Formats one or more p-values to three decimal places following the package
#' convention: the leading zero is dropped (a p cannot exceed 1, so ".045" not
#' "0.045"), values below .001 collapse to the "<.001" floor, and a missing p
#' renders as the empty string (a blank cell) rather than a misleading "<.001"
#' or a stray "NA". Vectorized; used by every analysis function that prints a
#' p-value, matching jcorr's existing treatment. Statistics that can exceed 1
#' (F, t, Wald, chi-square, coefficients, standard errors, confidence-interval
#' bounds) keep their leading zero and are formatted elsewhere -- this helper is
#' for p-values only. The three-decimal precision is fixed and does not follow
#' the digits option (p-values keep their own convention).
#'
#' @param p Numeric vector of p-values (NA allowed).
#'
#' @return Character vector the same length as p.
#'
#' @keywords internal
.jst_fmt_p <- function(p) {
  p <- suppressWarnings(as.numeric(p))
  ifelse(is.na(p), "",
         ifelse(p < 0.001, "<.001",
                sub("^0\\.", ".", sprintf("%.3f", p))))
}

#' Internal helper: validate and resolve the variable.id display mode
#'
#' Thin wrapper over \code{.jst_resolve_toggle("variable.id", ...)} that
#' first validates a non-NULL per-call \code{variable.id} argument against
#' the five-token enum. Every analysis function's \code{variable.id =}
#' argument is a string-only enum (no logical aliases); a bad token errors
#' here with a consistent message rather than silently passing through to the
#' renderer. (\code{variable.id} controls the one-per-variable descriptive
#' label; the distinct \code{value.id} control governs the per-code
#' value-label mapping -- see \code{.jst_resolve_value_id}.)
#'
#' The five tokens parallel \code{value.id}'s: \code{"names"} (bare variable
#' name), \code{"labels"} (the variable label in place of the name),
#' \code{"both"} (\code{"name: label"}), \code{"legend"} (names in the table
#' plus a name->label legend block), \code{"legend.bottom"} (same, legend at
#' the very end).
#'
#' @param per_call The value of the calling function's \code{variable.id}
#'   argument: NULL (defer to joutput()), or one of \code{"both"},
#'   \code{"names"}, \code{"labels"}, \code{"legend"}, \code{"legend.bottom"}.
#'
#' @return Single character token: one of \code{"both"}, \code{"names"},
#'   \code{"labels"}, \code{"legend"}, \code{"legend.bottom"}.
#'
#' @keywords internal
.jst_resolve_variable_id <- function(per_call) {
  if (!is.null(per_call)) {
    if (!is.character(per_call) || length(per_call) != 1 ||
        !(per_call %in% c("both", "names", "labels", "legend", "legend.bottom"))) {
      .jst_stop_arg(arg = "variable.id", choices = c("both", "names", "labels", "legend", "legend.bottom"))
    }
  }
  .jst_resolve_toggle("variable.id", per_call)
}

#' Internal helper: validate and resolve the jcorr correlation-cell layout
#'
#' Resolves the \code{layout} argument of \code{jcorr()} to one of
#' \code{"wide"} or \code{"stacked"}. Unlike the joutput()-backed display
#' toggles, this layout choice is jcorr-specific (the only function that
#' renders composite r / p / N cells), so its global default lives in
#' joptions() rather than joutput(): a per-call value wins, else the
#' \code{corr.layout} joptions slot, else the built-in default of "wide".
#'
#' @param per_call The value of jcorr()'s \code{layout} argument: NULL
#'   (defer to joptions()), or one of \code{"wide"}, \code{"stacked"}.
#'
#' @return Single character token: \code{"wide"} or \code{"stacked"}.
#'
#' @keywords internal
.jst_resolve_corr_layout <- function(per_call) {
  if (!is.null(per_call)) {
    if (!is.character(per_call) || length(per_call) != 1 ||
        !(per_call %in% c("wide", "stacked"))) {
      .jst_stop_arg(arg = "layout", choices = c("wide", "stacked"))
    }
    return(per_call)
  }
  global <- getOption(".jst_options_corr_layout",
                      .jst_options_defaults$corr.layout)
  if (!is.null(global) && length(global) == 1 &&
      global %in% c("wide", "stacked")) {
    return(global)
  }
  "wide"
}

#' Internal helper: validate and resolve the missing-value detail tier
#'
#' Resolves \code{jfreq()}'s \code{missing.detail} argument to one of
#' \code{"totals"}, \code{"per_code"}, or \code{"all"}. Like
#' \code{corr.layout} and unlike the joutput()-backed display toggles,
#' this choice is specific to the one function that renders a
#' missing-value breakdown per variable, so its global default lives in
#' joptions() rather than joutput(): a per-call value wins, else the
#' \code{missing.detail} joptions slot, else the built-in default of
#' \code{"per_code"}.
#'
#' Not a platform-spec string (it names no statistical platform), so it
#' is matched exactly, as \code{corr.layout} and
#' \code{case.processing.detail} are.
#'
#' @param per_call The value of \code{jfreq()}'s \code{missing.detail}
#'   argument: NULL (defer to joptions()), or one of \code{"totals"},
#'   \code{"per_code"}, \code{"all"}.
#'
#' @return Single character token: \code{"totals"}, \code{"per_code"},
#'   or \code{"all"}.
#'
#' @keywords internal
.jst_resolve_missing_detail <- function(per_call) {
  valid <- c("totals", "per_code", "all")
  if (!is.null(per_call)) {
    if (!is.character(per_call) || length(per_call) != 1 ||
        !(per_call %in% valid)) {
      .jst_stop_arg(arg = "missing.detail", choices = valid)
    }
    return(per_call)
  }
  global <- getOption(".jst_options_missing_detail",
                      .jst_options_defaults$missing.detail)
  if (!is.null(global) && length(global) == 1 && global %in% valid) {
    return(global)
  }
  "per_code"
}

#' Internal helper: render one missing-value row label
#'
#' The established form for a missing-value row in jfreq and in
#' \code{.jst_cps_var_rows()}: \code{-99 ["Refused"]} when the value
#' carries a label, \code{-99 (no label)} when it does not. Shared so
#' declared codes, Stata tags, and observed in-band values all render
#' identically -- nothing new is invented for the in-band rows.
#'
#' @param code_display Character display form of the value.
#' @param label Character label, or \code{NA} / \code{""} for none.
#'
#' @return A single character string.
#'
#' @keywords internal
.jst_udm_row_label <- function(code_display, label) {
  if (!is.na(label) && nzchar(label)) {
    sprintf('%s ["%s"]', code_display, label)
  } else {
    sprintf('%s (no label)', code_display)
  }
}

#' Internal helper: validate and resolve the value.id display mode
#'
#' Thin wrapper over \code{.jst_resolve_toggle("value.id", ...)} that
#' first validates a non-NULL per-call \code{value.id} argument against
#' the supported-token enum. \code{value.id} controls how a categorical
#' variable's per-code value labels surface (code, label, or both) wherever
#' categorical levels appear -- the frequency-table Value column, group
#' headers, crosstab axes. It is distinct from \code{variable.id}, which
#' governs the one-per-variable descriptive label.
#'
#' The five tokens: \code{"both"} (\code{"code: label"}), \code{"values"}
#' (bare code), \code{"labels"} (the value label, degrading to the bare code
#' per code where none exists), \code{"legend"} (bare codes in the table plus
#' a code->label legend block), \code{"legend.bottom"} (same, legend at the
#' very end). The legend modes keep the in-table category column compact when
#' value labels are long, mirroring \code{variable.id}'s legend modes.
#'
#' @param per_call The value of the calling function's \code{value.id}
#'   argument: NULL (defer to joutput()), or one of \code{"both"},
#'   \code{"values"}, \code{"labels"}, \code{"legend"}, \code{"legend.bottom"}.
#' @param allowed Character vector of the value.id modes the calling function
#'   accepts. Defaults to the full set; \code{jlm()} and \code{jlogistic()}
#'   pass the reduced set (\code{"both"}, \code{"values"}, \code{"labels"}) so
#'   the "must be one of" message advertises only what they support, matching
#'   their separate rejection of the legend modes.
#'
#' @return Single character token: one of \code{"both"}, \code{"values"},
#'   \code{"labels"}, \code{"legend"}, \code{"legend.bottom"}.
#'
#' @keywords internal
.jst_resolve_value_id <- function(per_call,
                                  allowed = c("both", "values", "labels",
                                              "legend", "legend.bottom")) {
  if (!is.null(per_call)) {
    if (!is.character(per_call) || length(per_call) != 1 ||
        !(per_call %in% allowed)) {
      .jst_stop_arg(arg = "value.id", choices = allowed)
    }
  }
  .jst_resolve_toggle("value.id", per_call)
}

#' Internal helper: format categorical levels under a value.id mode
#'
#' Shared formatter that maps stored codes (plus their value labels, if any)
#' to display strings under the active \code{value.id} mode. Every surface
#' where categorical levels appear -- jfreq valid rows, jt/jaov group headers,
#' jcrosstab axes, grouped jdesc group headers -- routes its code/label display
#' through this one helper so the modes behave identically across functions and
#' the per-code degrade logic lives in a single place.
#'
#' Degrades per CODE, not per variable: \code{"labels"} shows the label where
#' one exists, otherwise that bare code; \code{"both"} shows \code{"code: label"}
#' where a label exists, otherwise the bare code (so a variable with no value
#' labels at all collapses to bare codes -- the emergent whole-variable
#' behaviour). \code{"values"} always shows the bare stored code. The two
#' legend modes (\code{"legend"}, \code{"legend.bottom"}) render bare codes
#' in-table exactly like \code{"values"} -- the code->label mapping is emitted
#' separately as a legend block by the calling function (see
#' \code{.print_value_labels}). Plain numeric (unlabelled) variables therefore
#' render identically under every mode, so value.id is a no-op for them.
#'
#' In-table content is capped to a display-width ceiling via
#' \code{.jst_truncate_ellipsis} (shared 40-column cap). This bites only under
#' \code{"both"}/\code{"labels"} where a long value label would otherwise widen
#' the category column for every row; bare codes are short and unaffected. The
#' cap is applied here, in the formatting layer, so the (already-capped) string
#' is what reaches \code{.jst_print_table} -- the printer stays width-agnostic.
#'
#' Works for both numeric-backed and character-backed haven_labelled variables:
#' codes are compared as character on both sides, so string codes (e.g.
#' "US"/"UK") are never coerced to numeric.
#'
#' @param codes Vector of stored values (numeric or character), one per level
#'   or per row. NA entries (system-missing) map to NA in the output.
#' @param val_labels Named vector as returned by \code{labelled::val_labels()}
#'   (names are the labels, values are the codes), or NULL / length-0 when the
#'   variable carries no value labels.
#' @param mode One of \code{"both"}, \code{"values"}, \code{"labels"},
#'   \code{"legend"}, \code{"legend.bottom"}. The legend modes behave as
#'   \code{"values"} for the returned in-table vector.
#'
#' @return Character vector parallel to \code{codes}.
#'
#' @keywords internal
.jst_format_value_labels <- function(codes, val_labels, mode = "both") {
  codes_chr <- as.character(codes)
  lookup <- if (!is.null(val_labels) && length(val_labels) > 0L) {
    stats::setNames(names(val_labels), as.character(unname(val_labels)))
  } else {
    character(0)
  }
  lab       <- unname(lookup[codes_chr])
  has_label <- !is.na(lab) & nzchar(lab)
  out <- switch(mode,
    values         = codes_chr,
    legend         = codes_chr,
    legend.bottom  = codes_chr,
    labels = ifelse(has_label, lab, codes_chr),
    both   = ifelse(has_label, paste0(codes_chr, ": ", lab), codes_chr),
    stop("Unknown value.id mode: ", mode, call. = FALSE))
  # Cap in-table width (no-op for bare-code output; bites long labels only).
  out <- vapply(out, .jst_truncate_ellipsis, character(1), USE.NAMES = FALSE)
  out[is.na(codes)] <- NA_character_
  out
}

#' Internal helper: build the choose-first gate error family
#'
#' The one builder behind every render of the Decision 11 choose-first
#' gate (step (4) decided INERT at S240; texts approved S243; built
#' S244), so the variants cannot drift apart. Renders are STATELESS
#' (identical at every firing), single fixed form across joutput tiers,
#' and governed by Rule V: real choices as copy-pasteable lines, each
#' with a one-line consequence, the recommendation carried in the menu
#' copy (stata, for base-R/AI mixing), and the permanence line stating
#' the action itself.
#'
#' Variants (the S243 approved-text sheet, changelog SESSION 243 (g)):
#' \describe{
#'   \item{\code{"menu"}}{A -- the full three-option menu (stata
#'     recommended, spss contrastive, sas brief), for acts legal under
#'     all three conventions: numeric-codes declarations and the
#'     \code{missing} token family. \code{head_tail} completes the
#'     head ("no missing-value convention is selected, so <tail>").}
#'   \item{\code{"pair"}}{B -- the stata/sas pair (the spss option
#'     line omitted), for literal tagged spellings, which the
#'     paste-and-rerun test fails under spss.}
#'   \item{\code{"range_unset"}}{C -- the never-set range variant:
#'     single per-call fix line (\code{convention = "spss"}); its user
#'     has no convention to stay in, so no menu and no recipe.}
#'   \item{\code{"conflict_setting"} / \code{"conflict_call"}}{D / E --
#'     the range-vs-tagged-convention conflicts (setting-level and
#'     per-call), DATA-AWARE with two renders: when every targeted
#'     column's range covers 26 or fewer values (\code{fits}), the
#'     two-step stay-tagged recipe (declare the range under SPSS
#'     convention, then \code{jconvert()}), each recipe line preceded
#'     by what it does; over the cap, the count line, the SPSS remedy,
#'     and the Rule X requirement sentence. Only the head differs
#'     between D and E (and E's "use" versus D's "stay in": E's user
#'     may hold no setting), so one code path emits all four renders.}
#' }
#'
#' Recipes echo the caller's actual data-frame name, variables, and
#' range bounds, in the data, variable(s), named-options teaching form
#' with flat \code{modify = TRUE}; runnable lines are bare Rule L lines
#' (2-space indent, never width-wrapped). Prose is Rule U wrapped;
#' menu consequence lines wrap at their own indent via
#' \code{.jst_wrap_indent()}.
#'
#' @param variant One of \code{"menu"}, \code{"pair"},
#'   \code{"range_unset"}, \code{"conflict_setting"},
#'   \code{"conflict_call"}.
#' @param fn The exported caller's name, for the first line's wrap
#'   reserve (the \code{.jst_stop()} prefix length).
#' @param head_tail Menu/pair variants: the clause completing the head.
#' @param conv Conflict variants: the conflicting convention token
#'   (\code{"stata"} or \code{"sas"}) -- the per-call value for E, the
#'   joptions setting for D; flips the style words and the
#'   \code{to =} target mechanically.
#' @param fits Conflict variants: TRUE when every targeted column's
#'   range covers 26 or fewer values (the jconvert cap), so the
#'   two-step recipe is honest to paste.
#' @param data_name,var_names,range Conflict variants: the echo pieces
#'   for the recipe lines (\code{range} already sorted).
#' @param over_var,over_n Conflict over-cap render: the first targeted
#'   column over the cap, and its in-band value count.
#' @param prefixed TRUE (default) when the body will be passed to
#'   \code{.jst_stop()}, which prepends "<fn>(): " -- the head reserves
#'   that width and reads on from the prefix. FALSE for a
#'   \code{message()} caller, where no prefix is prepended: the head
#'   capitalizes and wraps at full width. Only the head is affected;
#'   every other line is identical, so the two paths share one copy of
#'   the menu.
#' @return Character scalar: the complete message body (no fn prefix).
#' @keywords internal
.jst_choose_convention_error <- function(variant, fn,
                                         head_tail = NULL,
                                         conv      = NULL,
                                         fits      = NULL,
                                         data_name = NULL,
                                         var_names = NULL,
                                         range     = NULL,
                                         over_var  = NULL,
                                         over_n    = NULL,
                                         prefixed  = TRUE) {

  # prefixed = FALSE is the message() caller's contract (S250): no
  # "<fn>(): " is prepended, so the head neither reserves width for it
  # nor starts mid-sentence. Body text is otherwise identical, which is
  # the point -- one menu copy, two emission paths.
  reserve <- if (isTRUE(prefixed)) nchar(fn) + 4L else 0L

  # --- D / E: the range-vs-tagged-convention conflicts ----------------------
  if (variant %in% c("conflict_setting", "conflict_call")) {
    style <- if (identical(conv, "sas")) "SAS" else "Stata"
    head  <- if (identical(variant, "conflict_setting")) {
      paste0("a missing-value range can exist only under SPSS convention, ",
             "and your missing.convention setting is \"", conv, "\".")
    } else {
      paste0("a missing-value range can exist only under SPSS convention; ",
             "it cannot be combined with convention = \"", conv, "\".")
    }
    frv       <- function(x) format(x, trim = TRUE, scientific = FALSE)
    vars_txt  <- paste(var_names, collapse = ", ")
    decl_line <- paste0("  jdeclare_udm(", data_name, ", ", vars_txt,
                        ", range = c(", frv(range[1L]), ", ", frv(range[2L]),
                        "), convention = \"spss\", modify = TRUE)")
    if (isTRUE(fits)) {
      lead <- paste0(
        if (identical(variant, "conflict_setting")) {
          paste0("To stay in ", style, " convention, ")
        } else {
          paste0("To use ", style, " convention, ")
        },
        "first declare the range using SPSS convention:")
      conv_lead <- paste0("Then convert the ",
                          if (length(var_names) > 1L) "columns" else "column",
                          " to ", style, " convention:")
      conv_line <- paste0("  jconvert(", data_name, ", ", vars_txt,
                          ", to = \"", conv, "\", modify = TRUE)")
      return(paste0(head, "\n",
                    lead, "\n",
                    decl_line, "\n",
                    conv_lead, "\n",
                    conv_line))
    }
    over_par <- paste0("In ", over_var, " the range covers ", over_n,
                       " values; ", style, "-style missing values support ",
                       "at most 26 per variable, so this range cannot ",
                       "become ", style, "-style. To declare the range ",
                       "using SPSS convention:")
    close_par <- paste0("To use ", style, " convention with jconvert(), ",
                        "you must first reduce these to 26 or fewer.")
    return(paste0(head, "\n",
                  over_par, "\n",
                  decl_line, "\n",
                  close_par))
  }

  # --- C: the never-set range variant ---------------------------------------
  if (identical(variant, "range_unset")) {
    return(paste0(
      paste0(
        if (isTRUE(prefixed)) "no" else "No",
        " missing-value convention is selected, and a missing-value ",
        "range can exist only under SPSS convention."), "\n",
      "To declare it, set convention = \"spss\" on this call."))
  }

  # --- A / B: the menu and the pair -----------------------------------------
  head  <- paste0(if (isTRUE(prefixed)) "no" else "No",
                  " missing-value convention is selected, so ", head_tail)
  parts <- c(
    "Choose one for this session:",
    "  joptions(missing.convention = \"stata\")",
    .jst_wrap_indent(paste0(
      "Markers behave as true NAs in base R; recommended if you mix ",
      "jstats with base R or AI-generated code."), indent = 6L))
  if (identical(variant, "menu")) {
    parts <- c(parts,
      # S250 (Rule H): ", as in SPSS" dropped -- the option line above
      # already names the convention, so the clause echoed a fact two
      # characters old.
      "  joptions(missing.convention = \"spss\")",
      .jst_wrap_indent(paste0(
        "Codes stay visible numbers. jstats treats them as ",
        "missing; base R does not."), indent = 6L))
  }
  parts <- c(parts,
    "  joptions(missing.convention = \"sas\")",
    .jst_wrap_indent("Like Stata, with uppercase markers (.A-.Z).",
                     indent = 6L),
    "To make the choice permanent, put the same line in your .Rprofile.")
  paste0(head, "\n",
         paste(parts, collapse = "\n"))
}


#' Internal helper: in-band value counts for the range-conflict guards
#'
#' The data-aware half of the Decision 11 gate's D/E guards (S243
#' design; S244 build): for each targeted column, how many values would
#' a candidate missing-value range cover -- the count \code{jconvert()}
#' would enumerate when converting the declared range to tagged form.
#' Delegates to the shared counter (\code{.jst_missing_info(observed =
#' TRUE)}) by attaching the candidate range to a throwaway copy of the
#' column, so the guard and the converter cannot disagree about what
#' "inside the range" means (distinct observed in-band values,
#' excluding any discretely declared codes).
#'
#' @param data The data frame.
#' @param vars Character vector of target column names.
#' @param range Length-2 numeric, sorted: the candidate range.
#' @return Integer vector, one count per element of \code{vars}.
#' @keywords internal
.jst_gate_inband_counts <- function(data, vars, range) {
  vapply(vars, function(v) {
    tmp <- data[[v]]
    attr(tmp, "na_range") <- range
    info <- .jst_missing_info(tmp, observed = TRUE)
    if (is.null(info) || is.null(info$range_values)) 0L
    else nrow(info$range_values)
  }, integer(1), USE.NAMES = FALSE)
}


#' Internal helper: resolve the active missing-value convention
#'
#' Implements Decision 11's four-step precedence rule for determining
#' which UDM convention (SPSS-form, Stata-form, or SAS-form; Decision
#' 13 added "sas") applies to a fresh UDM declaration or
#' convention-conditional recode. RESOLVES OR STOPS: returns
#' \code{"spss"}, \code{"stata"}, or \code{"sas"} when any of levels
#' 1-3 supplies a convention, and otherwise -- level 4, no convention
#' anywhere -- signals the Decision 11 choose-first gate (step (4)
#' decided INERT at S240; built S244) instead of defaulting. The
#' package never infers a convention for a minting act; an unset
#' option and an explicit \code{"none"} are identical.
#'
#' The four levels of the precedence rule, in order:
#' \enumerate{
#'   \item If the column already carries a UDM convention (na_values
#'     metadata for SPSS-form; tagged_na markers for Stata-form when
#'     lowercase, SAS-form when uppercase), match it. Handled at the
#'     call site by passing a non-NULL value to
#'     \code{column_convention}; \code{jrecode()} does not engage
#'     this level because it produces fresh columns. A mixed-case
#'     tagged column classifies as no convention (Decision 13's
#'     ambiguous rule) and does not engage this level.
#'   \item If \code{per_call} is \code{"spss"}, \code{"stata"}, or
#'     \code{"sas"}, use that.
#'   \item If \code{joptions("missing.convention")} is \code{"spss"},
#'     \code{"stata"}, or \code{"sas"}, use that.
#'   \item Else STOP with the act-shaped choose-first guided error,
#'     rendered by \code{.jst_choose_convention_error()}: the full
#'     three-option menu for numeric codes and the \code{missing}
#'     token family, the stata/sas pair for literal tagged spellings,
#'     and the single \code{convention = "spss"} fix line for a
#'     range. Variants are assigned per SPELLING by the
#'     paste-and-rerun test (Rule V, S243 amendment).
#' }
#'
#' All call sites are demand-driven -- the resolver runs only when the
#' call actually mints a missing form -- so a never-set user doing
#' ordinary non-minting work never reaches level 4.
#'
#' @param per_call The value of the calling function's
#'   \code{convention} argument (typically NULL, "spss", "stata", or
#'   "sas"). Validated; other values raise an error.
#' @param column_convention Optional. \code{"spss"}, \code{"stata"},
#'   \code{"sas"}, or \code{NULL} (an \code{NA} from an ambiguous
#'   mixed-case column is treated as \code{NULL}). When non-NULL and
#'   non-NA, level 1 of the precedence rule applies and the function
#'   returns this value immediately. \code{jdeclare_udm()} populates
#'   this argument from \code{.jst_missing_info()} on the operand
#'   column.
#' @param act REQUIRED. The minting act, so the level-4 gate renders
#'   the honest variant: \code{"codes"} (numeric-codes declaration,
#'   full menu), \code{"token"} (the \code{missing} target family,
#'   full menu), \code{"tagged"} (literal tagged spellings, the
#'   stata/sas pair), or \code{"range"} (the per-call fix line).
#' @param fn REQUIRED. The exported caller's name, passed through to
#'   \code{.jst_stop()} so the gate's prefix names the function the
#'   user actually called (auto-detection is bypassed deliberately:
#'   the stop fires inside a shared internal helper).
#' @param marker Optional. For \code{act = "tagged"}: the first tagged
#'   spelling in the user's call (e.g. \code{".a"},
#'   parser-normalized lowercase), echoed in the gate's head.
#'
#' @return Single character: \code{"spss"}, \code{"stata"}, or
#'   \code{"sas"} -- or no return (the level-4 stop).
#'
#' @keywords internal
.jst_resolve_convention <- function(per_call = NULL, column_convention = NULL,
                                    act, fn, marker = NULL) {

  # Internal invariants (bare stops: these catch package bugs, not user
  # input -- every call site is package code).
  if (missing(act) || !is.character(act) || length(act) != 1L ||
      !act %in% c("codes", "token", "tagged", "range")) {
    stop(".jst_resolve_convention() requires act = \"codes\", \"token\", ",
         "\"tagged\", or \"range\".", call. = FALSE)
  }
  if (missing(fn) || !is.character(fn) || length(fn) != 1L || !nzchar(fn)) {
    stop(".jst_resolve_convention() requires the exported caller's name ",
         "in `fn`.", call. = FALSE)
  }

  # Platform specs are case-insensitive (accept "SPSS", "Stata", ...);
  # canonicalize before validating so every caller inherits the rule.
  if (is.character(per_call) && length(per_call) == 1L && !is.na(per_call)) {
    per_call <- tolower(per_call)
  }
  # Validate per_call up front so the error fires whether or not the
  # convention is actually consulted by the caller.
  if (!is.null(per_call)) {
    if (!is.character(per_call) || length(per_call) != 1L ||
        !per_call %in% c("spss", "stata", "sas")) {
      .jst_stop_arg(arg = "convention", choices = c("spss", "stata", "sas"))
    }
  }

  # Level 1: column already carries a convention. An NA (ambiguous
  # mixed-case column) fails the %in% and falls through -- Decision 13.
  if (!is.null(column_convention) &&
      column_convention %in% c("spss", "stata", "sas")) {
    return(column_convention)
  }

  # Level 2: per-call argument.
  if (!is.null(per_call)) return(per_call)

  # Level 3: joptions setting.
  opt <- getOption(".jst_options_missing_convention",
                   .jst_options_defaults$missing.convention)
  if (opt %in% c("spss", "stata", "sas")) return(opt)

  # Level 4: the choose-first gate (Decision 11 step (4); decided INERT
  # S240, texts approved S243, built S244). No convention anywhere --
  # the package refuses to infer one for a minting act. Stateless
  # single render; the act picks the Rule V variant.
  head_tail <- switch(act,
    codes  = "these codes cannot be declared.",
    token  = "the 'missing' target cannot be applied.",
    tagged = paste0("the '",
                    if (is.null(marker)) ".a" else marker,
                    "' marker cannot be ",
                    if (identical(fn, "jdeclare_udm")) "declared."
                    else "applied."),
    range  = NULL)
  gate_variant <- switch(act, codes = "menu", token = "menu",
                         tagged = "pair", range = "range_unset")
  .jst_stop(.jst_choose_convention_error(variant   = gate_variant,
                                         fn        = fn,
                                         head_tail = head_tail),
            fn = fn)
}

#' Internal helper: canonical letter case for a tagged-NA marker
#'
#' Embodies Decision 13's token case rule: marker-letter INPUT is
#' case-insensitive everywhere, but the case actually STORED follows
#' the governing convention -- uppercase under "sas", lowercase
#' otherwise. Display always follows the stored tag, never the
#' setting; this helper governs minting only.
#'
#' Foundation-session machinery (S226): the mint sites (jrecode,
#' jdeclare_udm) adopt it at their parity-worklist touches; until
#' then they mint lowercase regardless of convention (the documented
#' piecewise lag).
#'
#' @param tag Character vector of single tag letters, any case.
#' @param convention Single character: \code{"spss"}, \code{"stata"},
#'   or \code{"sas"} (a resolved convention, as returned by
#'   \code{.jst_resolve_convention()}).
#'
#' @return Character vector of tag letters in the convention's
#'   canonical case.
#'
#' @keywords internal
.jst_canonical_tag <- function(tag, convention) {
  if (identical(convention, "sas")) toupper(tag) else tolower(tag)
}

# -----------------------------------------------------------------------------
# .jst_phrasing_convention()
#
# Display-time tagged convention for MESSAGE PHRASING ONLY (S240). Used by
# refusal messages that fire before (or independently of) convention
# resolution -- the jdeclare_udm plain-column token refusal and the
# cross-convention builder -- so their token case, style word, and remedy
# targets read congruently for a sas-setting user. Rule: a per-call
# "stata"/"sas" wins; else a "sas" joptions setting; else "stata" (today's
# phrasing, which is also correct for the lowercase-normalized tokens the
# parsers produce). Deliberately NEVER consults the resolver's default
# level, so it stays non-gating when the unset state becomes a choose-first
# gate (Decision 11 step (4) revisit, Session 240 design). Returns "stata"
# or "sas" only -- never "spss", never an error.
# -----------------------------------------------------------------------------

#' @keywords internal
.jst_phrasing_convention <- function(per_call = NULL) {
  # Robust to a RAW per-call value (some callers fire before the argument
  # is validated/canonicalized): anything that is not a single "stata"/
  # "sas" string, in any capitalization, simply falls through.
  if (is.character(per_call) && length(per_call) == 1L && !is.na(per_call)) {
    pc <- tolower(per_call)
    if (pc %in% c("stata", "sas")) return(pc)
  }
  opt <- getOption(".jst_options_missing_convention",
                   .jst_options_defaults$missing.convention)
  if (identical(opt, "sas")) return("sas")
  "stata"
}

#' Internal helper: user-facing style label for a UDM convention
#'
#' Maps a convention token to the locked user-facing vocabulary
#' (the MISSING-VALUE-TERMS rule, S36): "SPSS-style" / "Stata-style" /
#' "SAS-style". Shared by the joptions environment-scan notice and
#' jdeclare_udm's post-declaration mismatch notice so the two render
#' identically.
#'
#' @param convention Character vector of convention tokens ("spss",
#'   "stata", "sas").
#'
#' @return Character vector of display labels; \code{NA} for
#'   unrecognized or \code{NA} input.
#'
#' @keywords internal
.jst_convention_label <- function(convention) {
  unname(c(spss  = "SPSS-style",
           stata = "Stata-style",
           sas   = "SAS-style")[convention])
}

#' CPS rendering rule tables (data, not logic)
#'
#' Canonical source = JStats_CPS_Rendering_Reference.txt Tables 1-3. Per the
#' locked lockstep commitment, any change to a rule here updates BOTH that
#' reference file and this data frame in the same session. "any" is a
#' wildcard; matching is first-match top-to-bottom, so reference rows whose
#' value is "-" (not evaluated) are encoded as "any" with ordering preserved.
#'
#' @keywords internal
.jst_cps_visibility_rules <- data.frame(
  level    = c("minimal", "standard", "standard", "standard", "full"),
  pipeline = c("any",     "no",       "yes",      "any",      "any"),
  missing  = c("any",     "no",       "any",      "yes",      "any"),
  rendered = c(FALSE,     FALSE,      TRUE,       TRUE,       TRUE),
  stringsAsFactors = FALSE
)

#' @keywords internal
.jst_cps_layout_rules <- data.frame(
  layout         = c("listwise", "pairwise", "per_var_desc", "per_var_freq"),
  top_default    = c("on",       "on",       "on",           "on"),
  bottom_default = c("on",       "on",       "on",           "off"),
  endpoint_label = c("Analysis N", "Remaining N", "Remaining N", "Remaining N"),
  auto_listwise  = c("shown",    "hidden",   "hidden",       "hidden"),
  stringsAsFactors = FALSE
)

#' @keywords internal
.jst_cps_bottom_rules <- data.frame(
  layout    = c(rep("listwise", 7), rep("pairwise", 7),
                rep("per_var_desc", 5), "per_var_freq"),
  has_udms  = c("no","no","no","no","yes","yes","yes",
                "no","no","no","no","yes","yes","yes",
                "no","no","yes","yes","yes",
                "any"),
  has_sysna = c("no","yes","yes","yes","any","any","any",
                "no","yes","yes","yes","any","any","any",
                "no","yes","any","any","any",
                "any"),
  tier      = c("any","none","totals","per_code","none","totals","per_code",
                "any","none","totals","per_code","none","totals","per_code",
                "any","any","none","totals","per_code",
                "any"),
  bottom        = c(FALSE,FALSE,TRUE,TRUE,FALSE,TRUE,TRUE,
                    FALSE,FALSE,TRUE,TRUE,FALSE,TRUE,TRUE,
                    FALSE,FALSE,FALSE,FALSE,TRUE,
                    FALSE),
  resolved_tier = c(NA,NA,"totals","totals",NA,"totals","per_code",
                    NA,NA,"totals","totals",NA,"totals","per_code",
                    NA,NA,NA,NA,"per_code",
                    NA),
  stringsAsFactors = FALSE
)
