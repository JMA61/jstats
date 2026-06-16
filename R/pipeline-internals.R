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
        warning(msg, call. = FALSE)
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
  # copy of the data frame used for this analysis. The user's data frame in
  # the workspace is unchanged — na_values / na_range metadata stays
  # attached so round-trip fidelity through jsave is preserved. Stata-form
  # tagged_na values are not touched here; they satisfy is.na() natively at
  # the C level. Replaces the former auto-NA-by-label mechanism
  # (.jst_preprocess_na, retired in v0.9.5) per Cross-cutting Decision 5 of
  # JStats_Missing_Values_Reference.txt Part 4.
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
    # UDM masking activity from Step 0. udm_active = TRUE when at least
    # one variable had declared UDMs masked to NA on the analysis copy.
    # udm_masked_vars carries the per-variable detail (entries + n_cells)
    # for downstream display (Case Processing Summary, etc.).
    udm_active       = length(udm_result$converted) > 0L,
    udm_masked_vars  = udm_result$converted,
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
    if (startsWith(m, "[YELLOW]")) {
      .cat_yellow(sub("^\\[YELLOW\\]", "", m))
      cat("\n")
    } else {
      cat(m, "\n")
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
    udm_active         = pipeline_counts$udm_active,
    udm_masked_vars    = pipeline_counts$udm_masked_vars,
    pre_pipeline_data  = pipeline_counts$pre_pipeline_data,
    surviving_ids      = pipeline_counts$surviving_ids
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
# udm.notice supports three states:
#   FALSE - never print the UDM narrative on jload
#   TRUE  - always print the narrative (every .sav load with UDMs)
#   NULL  - "auto": print once per session, then suppress (tracked via
#           the .jst_udm_notice_shown option)
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
                  udm.notice = NULL),
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
# jconvert, jdeclare_udm, jrecode, .jst_scan_coded_missing) via
# getOption() fallback when no explicit setting is present.
#
# Slots:
#   missing.convention   - one of "none", "spss", "stata". "none" =
#                          preserve-as-loaded (no auto-conversion at
#                          load time). "spss" / "stata" opts into
#                          load-time auto-conversion and supplies the
#                          target convention for fresh UDM declarations.
#   udm.convention.codes - numeric vector, length 1-3, whole numbers,
#                          no duplicates. Recommended UDM code set used
#                          by jconvert for Stata-tag -> SPSS-code mapping
#                          and by .jst_scan_coded_missing for
#                          convention-matched detection.
#   data.dir             - single character string, or NULL. NULL =
#                          jsave writes bare-filename saves to the
#                          working directory; jload bare-filename
#                          searches the working directory. Setting a
#                          value names a folder (relative to working
#                          directory) used for both save target and
#                          load search.
.jst_options_defaults <- list(
  missing.convention   = "none",
  udm.convention.codes = c(-99, -98, -97),
  data.dir             = NULL,
  corr.layout          = "wide"
)

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

#' Internal helper: resolve the active missing-value convention
#'
#' Implements Decision 11's four-step precedence rule for determining
#' which UDM convention (SPSS-form or Stata-form) applies to a fresh
#' UDM declaration or convention-conditional recode. Returns either
#' \code{"spss"} or \code{"stata"} -- never \code{NULL}.
#'
#' The four levels of the precedence rule, in order:
#' \enumerate{
#'   \item If the column already carries a UDM convention (na_values
#'     metadata for SPSS-form, tagged_na markers for Stata-form),
#'     match it. Handled at the call site by passing a non-NULL value
#'     to \code{column_convention}; \code{jrecode()} does not engage
#'     this level because it produces fresh columns.
#'   \item If \code{per_call} is \code{"spss"} or \code{"stata"}, use
#'     that.
#'   \item If \code{joptions("missing.convention")} is \code{"spss"}
#'     or \code{"stata"}, use that.
#'   \item Else default to SPSS-form.
#' }
#'
#' @param per_call The value of the calling function's
#'   \code{convention} argument (typically NULL, "spss", or "stata").
#'   Validated; values other than NULL, "spss", or "stata" raise an
#'   error.
#' @param column_convention Optional. \code{"spss"}, \code{"stata"},
#'   or \code{NULL}. When non-NULL, level 1 of the precedence rule
#'   applies and the function returns this value immediately. Step 5b
#'   (\code{jdeclare_udm()}) will populate this argument from
#'   \code{.jst_missing_info()} on the operand column.
#'
#' @return Single character: \code{"spss"} or \code{"stata"}.
#'
#' @keywords internal
.jst_resolve_convention <- function(per_call = NULL, column_convention = NULL) {

  # Validate per_call up front so the error fires whether or not the
  # convention is actually consulted by the caller.
  if (!is.null(per_call)) {
    if (!is.character(per_call) || length(per_call) != 1L ||
        !per_call %in% c("spss", "stata")) {
      .jst_stop_arg(arg = "convention", choices = c("spss", "stata"))
    }
  }

  # Level 1: column already carries a convention.
  if (!is.null(column_convention) &&
      column_convention %in% c("spss", "stata")) {
    return(column_convention)
  }

  # Level 2: per-call argument.
  if (!is.null(per_call)) return(per_call)

  # Level 3: joptions setting.
  opt <- getOption(".jst_options_missing_convention",
                   .jst_options_defaults$missing.convention)
  if (opt %in% c("spss", "stata")) return(opt)

  # Level 4: SPSS-form default.
  return("spss")
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
