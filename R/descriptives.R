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
#' Output is structured consistently with \code{jfreq()}: a single red
#' "Descriptive Statistics" title is printed first, followed by the
#' default-data note (if a juse() default was used), any pipeline
#' messages, and then either the Case Processing table (when a filter is
#' active) or a one-line statement of the N -- for several variables, the
#' size of the variable pool and how many cases are complete on all of
#' them. One shared table follows, a row per variable. Variable labels
#' are not printed in the table; \code{variable.id} puts them in the row
#' names or in a legend under the table.
#'
#' Summarizes numeric, haven-labelled, logical, numeric-coded factor, and
#' numeric-looking character variables. Variables that cannot be summarized
#' --- text factors, text character variables, and date/time variables ---
#' are skipped with a warning directing the user to \code{jfreq()} (date/time
#' variables are not supported here). When every requested variable is
#' unsummarizable, jdesc() stops with an error. Also accepts a simple numeric
#' vector. Supports grouped descriptives via the \code{by} parameter.
#'
#' Given a single variable instead of a data frame, as in
#' \code{jdesc(community$Age)}, jdesc() describes that variable. A column of
#' a data frame is described in its frame, exactly as
#' \code{jdesc(community, Age)} describes it: the frame's \code{jsubset()}
#' and \code{jcomplete()} settings and its registrations apply. Any other
#' vector is described on its own. A second variable, \code{by}, and a
#' \code{subset} condition naming another variable need the data frame, and
#' each stops with that form of the call.
#'
#' With a \code{juse()} default set, a name the default data frame has is
#' that frame's variable, as in every jstats function, even when a separate
#' object of the same name exists in the workspace: \code{jdesc(Age)}
#' describes the default frame's Age, and a line under "Using default data
#' frame" says so. A separate object is read only when the default frame
#' has no variable of that name, or when no default is set.
#'
#' With \code{by}, the case-processing summary counts the cases that have
#' a group. Where it is a single line rather than a table (at the minimal
#' output level, for example), that line counts "Grouped Cases" once the
#' grouping variable has excluded any.
#'
#' A haven-labelled variable is summarized by its codes, like any numeric
#' variable. One whose codes look like categories gets a warning that the
#' statistics may not be meaningful, with \code{jfreq()} as the
#' alternative.
#'
#' @param data A data frame, or a single variable: a column of a data frame
#'   or a numeric vector.
#' @param ... Unquoted variable names within \code{data}. None when
#'   \code{data} is a single variable. A \code{c()} of names, bare
#'   or quoted, is read as the names.
#' @param by An optional unquoted grouping variable name. When provided,
#'   descriptives are computed separately for each group, with a separate
#'   titled table per dependent variable. Each table's \code{Total} is the
#'   group's size and \code{Non_missing} the cases in it with a value on
#'   that variable, the same two columns as the ungrouped table. A case
#'   with a missing value on the grouping variable belongs to no group and
#'   so to no table; the Case Processing Summary reports those cases on a
#'   \code{by =} row (shown only when there are any), and its N counts the
#'   cases that have a group. The grouping variable cannot also be one of
#'   the variables described.
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
#'   \code{"labels"} shows each variable's label in place of its name (in the
#'   descriptives table; for grouped output, as the per-variable caption and
#'   the grouping-variable column header) -- best for short labels;
#'   \code{"legend"} and \code{"legend.bottom"} keep names and print a label
#'   legend after the table. NULL (default) defers to \code{joutput()}'s
#'   \code{variable.id} setting. Not a logical.
#' @param numeric Optional. Variables to treat as continuous for this call
#'   (the per-call counterpart of \code{jnumeric()}), named bare or in
#'   quotes, several with \code{c()}: \code{numeric = Age}.
#'   Its only effect in \code{jdesc()} is to suppress the structural "seems
#'   categorical" descriptive caution for those variables; the descriptives
#'   themselves are computed the same way regardless.
#' @param categorical Not supported by \code{jdesc()} yet. \code{jdesc()}
#'   always computes numeric descriptives; supplying \code{categorical} raises
#'   an error pointing to \code{jfreq()} for a categorical summary. (How
#'   \code{jdesc()} should handle an asserted-categorical variable is a parked
#'   design decision.)
#' @param count Optional. Variables to treat as counts for this call (the
#'   per-call counterpart of \code{jcount()}), named bare or in quotes,
#'   several with \code{c()}. A count is
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
#' # The data frame may also be given by name
#' jdesc(data = community, Age)
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
#'   which keep their own fixed conventions. The Min and Max columns are
#'   values of the variables rather than statistics: each variable shows
#'   as many decimal places as its own data carry, up to this many, so a
#'   variable measured in whole numbers prints 0 and 75 beside another's
#'   4.8 and 9.7, and the two columns are aligned on the decimal point.
#'   NULL (default) defers to \code{joutput()}'s \code{digits} setting
#'   (default 3).
#' @param case.processing.detail Per-call override of the Case
#'   Processing Summary detail tier: one of \code{"none"},
#'   \code{"totals"}, or \code{"per_code"}. \code{NULL} (default)
#'   uses the active \code{joutput()} level default. The Case
#'   Processing table itself prints only when a filter or listwise
#'   deletion excluded cases; otherwise a one-line N statement takes its
#'   place. See \code{?joutput} (\code{case.processing}).
#' @param print Logical or NULL. \code{FALSE} prints nothing -- no table,
#'   no title, no note -- and returns the result as every call does;
#'   errors and warnings still show. \code{TRUE} prints even under
#'   \code{joutput("silent")}. \code{NULL} (the default) prints unless
#'   the level is silent. For a script that keeps many results and
#'   wants no output: see \code{\link{joutput}}.
jdesc <- function(data, ..., by = NULL, subset = NULL, variable.id = NULL,
                  numeric = NULL, categorical = NULL, count = NULL,
                  value.id = NULL, case.processing.detail = NULL,
                  digits = NULL, print = NULL) {
  # print = FALSE, or joutput("silent"): the body runs inside a scope that
  # discards its output and muffles its notes; errors and warnings pass
  # (Capability Slate C3, Session 378; .jst_output_scope()).
  .jst_check_flag(print, "print", null.ok = TRUE)
  .jst_output_scope(print, {
  # A bare word where a quoted value goes (ruling R18, Session 356): the
  # front door, before anything is evaluated.
  .jst_word_args(sys.call(), match.call(expand.dots = TRUE), parent.frame(),
                 .jst_word_specs("variable.id", "value.id", "case.processing.detail"),
                 "jdesc")

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

  # Vector-input path (e.g. jdesc(community$Age)) -- wrap and recurse. Every
  # argument reaches the re-call, and what a single column cannot serve is
  # refused with the data-frame form as the fix (AUDIT-008). Named items are
  # checked here, not in the helper, so the detector reads jdesc's formals.
  if (arg1$mode == "vector_input") {
    wrapped    <- .jst_vector_frame(arg1)
    wrapped    <- .jst_vector_collision(wrapped, parent.frame(), "jdesc")
    dots       <- rlang::enquos(...)
    .jst_check_named_variables(dots, wrapped$frame, "jdesc")
    subset_sub <- substitute(subset)
    by_quo     <- rlang::enquo(by)
    return(.jst_vector_recurse(
      jdesc, "jdesc", wrapped, parent.frame(), dots = dots,
      subset_sub = subset_sub, by_quo = by_quo,
      # numeric =, categorical = and count = go to the re-call as typed,
      # where a bare name is read in the column's frame (Fix Slate 23,
      # Session 377): evaluated here, numeric = Age stopped with R's own
      # "object 'Age' not found".
      args = list(variable.id = variable.id, numeric = substitute(numeric),
                  categorical = substitute(categorical),
                  count = substitute(count),
                  value.id = value.id,
                  case.processing.detail = case.processing.detail,
                  digits = digits)))
  }

  data              <- arg1$data
  .jst_data_name    <- arg1$name
  .jst_default_used <- arg1$mode %in% c("default", "symbol_with_default")

  variables <- rlang::enquos(...)
  .jst_check_named_variables(variables, arg1$data, "jdesc")   # S290

  # Leading-comma-omitted: prepend the captured symbol to variables list
  if (arg1$mode == "symbol_with_default") {
    extra_quo <- rlang::new_quosure(arg1$first_arg_sub,
                                    env = parent.frame())
    variables <- c(list(extra_quo), variables)
    class(variables) <- "quosures"
  }
  variables <- .jst_expand_vars(variables)   # c() of names (ruling R18, S356)

  variable_names <- vapply(variables, rlang::quo_name, character(1))
  by_quo         <- rlang::enquo(by)

  # No variables (Session 338; the Session 74 item): jdesc(clinic), or a
  # bare jdesc() under a juse() default, went on to "None of the requested
  # variables can be summarized" over an empty bullet.
  if (length(variable_names) == 0L) {
    .jst_no_vars_stop("jdesc(community, Age, Income)")
  }

  # Check all variables exist before any processing
  check_names <- variable_names
  if (!rlang::quo_is_null(by_quo)) {
    check_names <- c(check_names, .jst_one_var_name(by_quo, "jdesc", "by ="))
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
  # Names bare or in quotes (ruling R18; Fix Slate 23, Session 377, as
  # jlm()'s since Session 376), read without evaluating a bare name, which
  # had stopped with R's own "object 'Environment2' not found" -- for
  # categorical = too, ahead of its refusal.
  if (.jst_arg_given(substitute(categorical), parent.frame())) {
    .jst_stop("categorical = is not supported yet: this function always ",
         "computes numeric descriptives.\nFor a categorical summary use ",
         "jfreq() instead.")
  }
  .name_args <- .jst_model_name_args(
    list(numeric = substitute(numeric), count = substitute(count)),
    parent.frame(), data, .jst_data_name, example = unname(variable_names[1L]),
    default_used = .jst_default_used)
  numeric <- .name_args$numeric
  count   <- .name_args$count
  for (.arg in c("numeric", "count")) {
    .val <- get(.arg)
    if (!is.null(.val)) {
      .bad <- setdiff(.val, variable_names)
      if (length(.bad) > 0) {
        .jst_stop(.jst_not_among_text(.arg, .bad,
                                      "the variables given to jdesc()"))
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
    if (is.null(.ov) && .jst_dummy_registered(.jst_data_name, v)) {
      .jst_warn(.jst_assumption_warning(v, "jdesc_is"))
    } else if (.jst_warns_seems_categorical(dat[[v]], v, .jst_data_name,
                                            override = .ov)) {
      .jst_warn(.jst_assumption_warning(v, "jdesc"))
    }
    if (!is.null(desc_class[[v]]$note)) {
      # Numbers-as-text coercion is pure FYI -- the variable IS summarized as
      # asked -- so it is a default-silent advisory note (full output only).
      .jst_advisory_note(desc_class[[v]]$note)
    }
  }
  # Mixed case: one consequential note per variable that was skipped.
  .emit_bad_refusals <- function() {
    for (v in bad_vars) .jst_msg(desc_class[[v]]$refusal)
  }

  # -- Grouped descriptives ---------------------------------------------------
  if (!rlang::quo_is_null(by_quo)) {
    by_name <- .jst_one_var_name(by_quo, "jdesc", "by =")

    # The grouping variable cannot also be described (Session 316): the
    # column is converted to group labels below before the per-variable
    # loop reads it, which described it as two empty groups. Refused before
    # the pipeline runs, so nothing has printed.
    if (by_name %in% variable_names) {
      .jst_stop(by_name, " is the grouping variable (by = ", by_name,
                ") and cannot also be described.")
    }

    # Apply the data pipeline (jcomplete, jsubset, subset) BEFORE converting
    # the grouping variable, mirroring jt (compare.R). The pipeline's Step 0
    # masks SPSS-style declared-missing cells to NA, so declared-missing
    # respondents cannot survive as their own group; and the pipeline receives
    # the still-labelled grouping column, so its pre-masking snapshot keeps the
    # intact codes the CPS per-code detail needs.
    subset_expr <- substitute(subset)
    pipeline <- .jst_apply_pipeline(data, .jst_data_name, .jst_default_used,
                                    subset_expr = subset_expr, envir = parent.frame(),
                                    vars = c(variable_names, by_name))
    data     <- pipeline$data

    # A text grouping variable's blank cells are one group, <blank> (S340).
    data[[by_name]] <- .jst_label_blanks(data[[by_name]])
    by_var  <- data[[by_name]]

    # Capture original class and label BEFORE any conversion. Taken from the
    # post-pipeline (masked, filtered) column so codes and levels describe the
    # same data the tables summarize.
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
      original_codes  <- .jst_group_codes(by_var)
      by_val_labels   <- labelled::val_labels(by_var)
      data[[by_name]] <- haven::as_factor(by_var)
    } else if (!is.factor(data[[by_name]])) {
      data[[by_name]] <- .jst_text_factor(data[[by_name]])
    }
    # Drop factor levels with no surviving cases -- a declared-missing level
    # masked to NA by the pipeline, or a level filtered out -- so group_levels
    # and original_codes describe the same masked column (this is what removes
    # the blank-labeled mystery group).
    data[[by_name]] <- droplevels(data[[by_name]])

    group_levels <- levels(data[[by_name]])
    # Each group's code and label (Session 399, Capability Slate T's build
    # 0), for descriptives_raw below.
    by_map <- .jst_level_codes(data[[by_name]], by_var,
                               if (is_labelled_by) by_val_labels else NULL)

    # No groups at all (Session 316): every case is missing on the grouping
    # variable, in the data or after a pipeline step. Stopped here, before
    # the title prints, instead of falling through to an empty group table
    # and a raw base R error. The active steps are named the way the Case
    # Processing rows name them.
    if (length(group_levels) == 0L) {
      pc    <- pipeline$pipeline_counts
      steps <- c(if (isTRUE(pc$complete_active)) "jcomplete()",
                 if (isTRUE(pc$filter_active))   "jsubset()",
                 if (!is.null(pc$n_after_subset)) "subset =")
      .jst_stop(by_name, " has no non-missing values",
                if (length(steps)) paste0(" after ",
                                          paste(steps, collapse = " and "))
                else "",
                ", so there are no groups to describe.")
    }

    # Build sample_info once for the entire by-group output. Only the
    # summarizable (good) analysis variables contribute; the grouping
    # variable joins them so its missingness reaches the breakdown. The
    # analysis N is the cases that have a group (Session 316, AUDIT-027): a
    # case missing on the grouping variable is in no table, and the
    # difference from the pool is what the Case Processing Summary renders
    # as the by = row. Per-variable Ns are reported in each mini-table.
    sample_info <- .jst_build_sample_info(
      pipeline_counts = pipeline$pipeline_counts,
      data            = pipeline$data,
      analysis_vars   = c(good_vars, by_name),
      n_analysis      = sum(!is.na(data[[by_name]])),
      by_var          = by_name
    )
    # Shared header for the whole by-group output: printed once (parallels
    # the no-by path), not repeated per variable. The grouping variable's
    # type/label block belongs here; each analysis variable's own block
    # stays inside the per-variable loop below. The Case Processing Summary
    # likewise renders once for the whole by-group output (per-variable
    # layouts render CPS once; locked CPS rendering design).
    .cat_red(paste0("Descriptive Statistics by ", by_name,
                    " (", .jst_fmt_n(length(group_levels)), " levels)\n"))
    if (.jst_default_used) .jst_default_note(.jst_data_name,
                                           vars = c(variable_names, by_name),
                                           envir = parent.frame())
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

    # No leading blank here either: the CPS block opens with its own blank
    # under the title. This grouped path is jdesc's SECOND CPS call site and
    # was missed by the S286 finding, which named only the ungrouped one;
    # the doubling here predates S286. (Session 287.)
    # The grouped cases (Session 348; the S316 item): the per-variable Ns,
    # the "Complete on All" count and the listwise-deletion note are read
    # off the cases the group tables describe -- those with a group -- or
    # they would disagree with the by = row. Before, this call passed no
    # data, so a grouped call never stated how many cases were complete on
    # all its variables.
    .jst_print_case_processing(
      sample_info,
      analysis_type = "per_var_desc",
      detail        = case.processing.detail,
      data          = data[!is.na(data[[by_name]]), , drop = FALSE],
      analysis_vars = good_vars)

    raw_rows <- list()
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

      # The groups' statistics unrounded, for descriptives_raw (Session
      # 399): the rows the table below prints, from the same cases.
      raw_rows[[v]] <- data.frame(
        variable    = v,
        group_code  = by_map$code,
        group_label = by_map$label,
        do.call(rbind, lapply(group_levels, function(lvl) {
          x <- dv_data[group_var_chr == lvl]
          x <- x[!is.na(x)]
          n <- length(x)
          data.frame(
            total     = sum(group_var_chr == lvl, na.rm = TRUE),
            n_valid   = n,
            n_missing = sum(group_var_chr == lvl, na.rm = TRUE) - n,
            min       = if (n > 0) min(x)       else NA_real_,
            max       = if (n > 0) max(x)       else NA_real_,
            mean      = if (n > 0) mean(x)      else NA_real_,
            sd        = if (n > 1) stats::sd(x) else NA_real_)
        })),
        stringsAsFactors = FALSE, row.names = NULL)

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

        # Total and Non_missing (Session 316): the ungrouped table's two
        # columns, per group -- the group's size, and its cases with a value
        # on this variable -- so the Totals sum to the Case Processing
        # Summary's N and each row states its own missing count. Before,
        # the one N column left a variable's missing cases unaccounted for.
        df <- data.frame(
          GROUP_PLACEHOLDER = group_label,
          Total       = sum(group_var_chr == lvl, na.rm = TRUE),
          Non_missing = n,
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

      # Block-centered numeric columns and trimmed lines (Session 316): each
      # header sits over the middle of its column, counts sit centered under
      # Total and Non_missing on their ones digit, the statistics keep their
      # decimal alignment, and no line ends in padding. The ungrouped table
      # below takes the same form, so the two read alike.
      # Mean and SD to digits places, trailing zeros kept; Min and Max are
      # values of the variable and keep the precision the data carry.
      # (Session 326)
      # THE VARIABLE'S precision, not the precision of the group minimums
      # and maximums that happen to print (Session 328): a variable measured
      # to a tenth shows 4.0 where a group's minimum is a whole number. The
      # places come from the described cases -- those with a group. One
      # variable, so one precision down each column, and "bc" already lines
      # the values up on the decimal point (the ungrouped table, where rows
      # differ in precision, needs "bd").
      mm_dp <- .jst_data_dp(dv_data[!is.na(group_var_chr)], digits_n)
      group_disp <- group_table
      group_disp$Min <- .jst_make_fmt(mm_dp)(group_table$Min)
      group_disp$Max <- .jst_make_fmt(mm_dp)(group_table$Max)
      .jst_print_table(group_disp, row.names = FALSE,
                       align = c("l", rep("bc", ncol(group_disp) - 1L)),
                       digits = c(Mean = digits_n, SD = digits_n))
      cat("\n")
    }

    # Mixed case: one note per variable that could not be summarized. The
    # notes are text after the last table's closing blank line, so what
    # follows them -- a legend, or the end of the output -- needs a blank
    # line of its own: the output ended on the note, and a legend sat
    # directly under it (Session 328). ends_blank tracks whether the last
    # thing printed was a blank line.
    .emit_bad_refusals()
    ends_blank <- length(bad_vars) == 0L

    # Variable- and value-label legends at the single consolidated position.
    # The grouping column in `data` has been factor-converted (value labels
    # stripped), so the value-label block reads from `by_var`, which retains
    # the original labelling. No lead-in blank when the last group table's
    # own closing blank line is still the last thing printed.
    leg_modes <- c("legend", "legend.bottom")
    if (vlmode %in% leg_modes) {
      if (.print_var_labels(data, c(good_vars, by_name),
                            lead = !ends_blank)) ends_blank <- TRUE
    }
    if (value_mode %in% leg_modes) {
      if (.print_value_labels(stats::setNames(list(by_var), by_name), by_name,
                              lead = !ends_blank)) ends_blank <- TRUE
    }
    if (!ends_blank) cat("\n")

    # No closing blank (Session 316): the last group table and each legend
    # already end with one, so the grouped output closes on one blank line
    # like the ungrouped output; a further cat("\n") here made it two.

    # descriptives_raw for the grouped call (Session 399, Capability Slate
    # T's build 0; NULL until then): one row per variable and group, in the
    # order printed, each group's code and label beside its statistics,
    # unrounded. The variables' labels ride as the ungrouped frame's do,
    # the grouping variable's name and label as the "by" attribute.
    descriptives_raw <- if (length(raw_rows)) do.call(rbind, unname(raw_rows))
    if (!is.null(descriptives_raw)) {
      attr(descriptives_raw, "labels") <- stats::setNames(
        vapply(good_vars, function(v) .jst_label_or_name(data, v),
               character(1)),
        good_vars)
      attr(descriptives_raw, "by") <- c(name  = by_name,
                                        label = lab_disp(by_name,
                                                         original_by_label))
    }

    ret <- list(
      descriptives = NULL,
      descriptives_raw = descriptives_raw,
      by           = by_name,
      sample_info  = sample_info
    )
    class(ret) <- "jst_desc"
    ret <- .jst_stamp_result(ret)   # Session 399: the version that made it
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
  if (.jst_default_used) .jst_default_note(.jst_data_name,
                                         vars = variable_names,
                                         envir = parent.frame())
  .jst_vector_note(data)   # the vector path's collision line (R18, S356)

  # Apply data pipeline (jcomplete, jsubset, subset)
  subset_expr <- substitute(subset)
  pipeline <- .jst_apply_pipeline(data, .jst_data_name, .jst_default_used,
                                  subset_expr = subset_expr, envir = parent.frame(),
                                  vars = variable_names)
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
    analysis_type = "per_var_desc",
    detail        = case.processing.detail,
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
    # No leading blank here: the CPS block closes with one blank line in
    # every mode (N line or table), so a cat("\n") at this point doubled it.
    # (Session 287; the S284 N line made the doubling visible everywhere.)
    # Block-centered numeric columns and trimmed lines, as the grouped
    # table (Session 316).
    # Mean and SD to digits places, trailing zeros kept (49.600, not
    # 49.6); Min and Max are values of the variables and keep the
    # precision the data carry. (Session 326)
    # EACH VARIABLE'S OWN precision (Session 328, Jeff): the two columns
    # took one precision from the values in them, so a whole-number
    # variable printed 0.0 and 75.0 beside another's 4.8 and 9.7 -- places
    # its data do not have. Each row is now formatted to the places its
    # variable's data carry (up to digits), and the two columns line up on
    # the decimal point ("bd"), so 0 sits over the 4 of 4.8.
    mm_dp <- vapply(good_vars, function(v) {
      .jst_data_dp(.jst_classify_desc_var(data[[v]], v)$num, digits_n)
    }, integer(1))
    fmt_mm <- function(x) {
      vapply(seq_along(x), function(i) .jst_make_fmt(mm_dp[[i]])(x[i]),
             character(1))
    }
    descriptives_disp$Min <- fmt_mm(descriptives$Min)
    descriptives_disp$Max <- fmt_mm(descriptives$Max)
    .jst_print_table(descriptives_disp,
                     align = c("l", ifelse(names(descriptives_disp)[-1L] %in%
                                             c("Min", "Max"), "bd", "bc")),
                     digits = c(Mean = digits_n, SD = digits_n))
    cat("\n")
  }

  # Mixed case: one note per variable that could not be summarized. As in
  # the grouped path above, the notes are text after the table's closing
  # blank line, so a legend or the end of the output needs a blank line of
  # its own after them. (Session 328)
  .emit_bad_refusals()
  ends_blank <- length(bad_vars) == 0L

  if (vlmode %in% c("legend", "legend.bottom")) {
    if (.print_var_labels(data, good_vars,
                          lead = !ends_blank)) ends_blank <- TRUE
  }
  if (!ends_blank) cat("\n")

  ret <- list(
    descriptives = descriptives,
    descriptives_raw = descriptives_raw,
    sample_info  = sample_info
  )
  class(ret) <- "jst_desc"
  ret <- .jst_stamp_result(ret)   # Session 399: the version that made it
  invisible(ret)
  })
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

#' Internal constant: the most zero rows one jfreq() table prints
#'
#' Ruling R4 (Session 345, built Session 348): a labelled value no case
#' holds, and a factor level, take a zero row; past this many in one table
#' none of them prints and one line under the table says how many there are
#' (a classification with hundreds of labels).
#' @keywords internal
.jst_freq_zero_row_cap <- 10L

#' Internal helper: the labelled VALID values no case holds
#'
#' jfreq()'s zero rows on the Valid side (Session 348, ruling R4 (b)). From a
#' variable's value labels, the values that are not among those observed in
#' the analysis pool and that the variable does not declare missing -- a
#' declared code, a value inside a declared range, or a Stata-style or
#' SAS-style marker (whose label value is NA, so it never reaches here). A
#' label on a blank text value is left out: blank cells are one category,
#' <blank>, which a zero row would duplicate.
#'
#' @param labs The variable's value labels (\code{labelled::val_labels()}).
#' @param observed The values present in the pool, as the caller holds them
#'   (numeric, or character when \code{text = TRUE}).
#' @param mi The variable's \code{.jst_missing_info()} (or NULL).
#' @param text Logical; TRUE for a character-backed labelled variable.
#' @return The values, in label order, of the same type as \code{observed}.
#' @keywords internal
.jst_freq_empty_labels <- function(labs, observed, mi, text = FALSE) {
  if (is.null(labs) || length(labs) == 0L) {
    return(if (text) character(0) else numeric(0))
  }
  v <- unname(labs)
  if (text) {
    v <- as.character(unclass(v))
    v <- v[!is.na(v) & nzchar(trimws(v))]
  } else {
    v <- suppressWarnings(as.numeric(unclass(v)))
    v <- v[!is.na(v)]
  }
  v <- unique(v)
  v <- v[!(v %in% observed)]
  if (length(v) && !is.null(mi) && identical(mi$representation, "spss")) {
    if (!is.null(mi$codes) && nrow(mi$codes) > 0L) {
      declared <- if (text) as.character(mi$codes$code)
                  else suppressWarnings(as.numeric(mi$codes$numeric))
      v <- v[!(v %in% declared)]
    }
    if (!text && !is.null(mi$na_range) && length(mi$na_range) == 2L) {
      rg <- range(as.numeric(mi$na_range))
      v  <- v[!(v >= rg[1L] & v <= rg[2L])]
    }
  }
  v
}

#' Internal helper: the code and the label behind each of jfreq()'s Valid rows
#'
#' jfreq() tabulates a factor of display strings: a labelled variable's
#' values formatted under the call's value.id mode ("1: Male", "Male" or
#' "1") and capped at 40 columns, a numeric variable's numbers as text.
#' The stored Value column is that string. This returns, for each row,
#' the value itself and its label whole (Session 399, Capability Slate
#' T's build 0), from the map the tabulating branch kept: each display
#' string beside the code it was made from, zero rows (a labelled value no
#' case holds) included. A text variable, a factor and any other type
#' have no map: the row's text is its own code, and it has no label.
#'
#' @param value Character; the Valid rows' Value column.
#' @param lvl_map NULL, or a list: \code{level} (the display strings),
#'   \code{code} (the code each was made from, the same length) and
#'   \code{labels} (the variable's value labels, or NULL).
#' @return A list: \code{code} (numeric or character) and \code{label}
#'   (character, \code{NA} where there is none), one element per row.
#' @keywords internal
.jst_freq_codes <- function(value, lvl_map) {
  if (is.null(lvl_map)) {
    return(list(code = as.character(value),
                label = rep(NA_character_, length(value))))
  }
  code <- lvl_map$code[match(value, lvl_map$level)]
  list(code = code, label = .jst_value_label_of(code, lvl_map$labels))
}

#' Internal helper: per-variable statistics, unrounded, in jdesc()'s raw shape
#'
#' One row per variable -- variable, total, n_valid, n_missing, min, max,
#' mean, sd, every number unrounded -- with the variables' labels as a
#' keyed \code{labels} attribute: the shape of jdesc()'s descriptives_raw
#' (the return-shape audit, Session 71), so a table reads M and SD the
#' same way whichever result they come from. Session 399 (Capability Slate
#' T's build 0): jcorr()'s M and SD, on the numeric values its correlations
#' read, each variable on its own cases.
#'
#' @param cols A data frame or list of numeric vectors, one per variable.
#' @param vars Character; the variables, in order.
#' @param label_src The data frame the labels are read from.
#' @return A data frame, as described.
#' @keywords internal
.jst_desc_raw_rows <- function(cols, vars, label_src) {
  out <- do.call(rbind, lapply(vars, function(v) {
    x <- cols[[v]]
    n <- sum(!is.na(x))
    data.frame(
      variable  = v,
      total     = length(x),
      n_valid   = n,
      n_missing = length(x) - n,
      min       = if (n > 0) min(x, na.rm = TRUE)        else NA_real_,
      max       = if (n > 0) max(x, na.rm = TRUE)        else NA_real_,
      mean      = if (n > 0) mean(x, na.rm = TRUE)       else NA_real_,
      sd        = if (n > 0) stats::sd(x, na.rm = TRUE)  else NA_real_,
      stringsAsFactors = FALSE, row.names = NULL)
  }))
  attr(out, "labels") <- stats::setNames(
    vapply(vars, function(v) .jst_label_or_name(label_src, v), character(1)),
    vars)
  out
}

#' SPSS-like frequency tables for categorical variables
#'
#' Prints an SPSS-style frequency table (Freq, Total %, Valid %, Cum. %) for
#' each variable supplied. Designed for use with unquoted variable names, and
#' also accepts a plain vector.
#'
#' Output is structured consistently with \code{jdesc()}: a single red
#' "Frequencies" title is printed first, followed by the default-data note
#' (if a juse() default was used), any pipeline messages, and then either
#' the Case Processing table (when a filter is active) or a one-line
#' statement of the N. Each variable then gets its own block: its caption
#' on its own line (the name, or name and label, as \code{variable.id}
#' directs), a blank line, and the frequency table. Declared missing
#' values get Missing rows of their own below the valid rows. The
#' frequency table ends with a Total row showing the post-pipeline N.
#'
#' When the table has Missing rows, a "Total valid" row closes the valid
#' rows -- the valid N, the base of every Valid % -- and, when there is
#' more than one Missing row, a "Total missing" row closes them, as in
#' SPSS FREQUENCIES.
#'
#' A value that has a value label but no case gets a row of its own at 0,
#' as an empty level of a factor does: a valid value, a declared missing
#' code, and a labelled code inside a declared missing-value range when
#' the range's values are listed one by one. A range with no case in it
#' keeps its single "range" row. When more than ten labelled values (or
#' factor levels) in one table have no case, none of them is listed, and
#' a line under the table says how many there are.
#'
#' In a text variable, cells with no text -- empty, or holding only spaces
#' or tabs -- are tabulated together in one row labeled \code{<blank>}.
#' They are counted as valid values, not as missing: a blank is absent data
#' in one file and a real answer in the next (a column coded "Y" or left
#' empty), and only you know which. A short footnote under the table says
#' how many there are; \code{\link{jencode}} gives them a code, and
#' \code{\link{jdeclare_missing}} with \code{codes = ""} declares them
#' missing. \code{<blank>} is the row's label, not a value in the
#' data: a filter selects those cells by what they hold,
#' \code{subset = trimws(Source) == ""} (or \code{Source == ""} for the
#' empty cells alone, leaving out those holding only spaces).
#'
#' A list column (a tibble's, or the geometry column of a spatial data
#' frame), a raw column, and a column that is itself a data frame cannot be
#' tabulated, and are refused before anything prints.
#'
#' For haven-labelled variables, value labels and numeric codes are combined
#' in the frequency table rows (e.g. \code{1: Strongly Oppose}) at the
#' default \code{value.id} setting. Where variable labels are shown, they
#' are shown for all variable types, not only haven-labelled ones.
#'
#' Given a single variable instead of a data frame, as in
#' \code{jfreq(community$Region)}, jfreq() tabulates that variable. A column
#' of a data frame is tabulated in its frame, exactly as
#' \code{jfreq(community, Region)} tabulates it: the frame's
#' \code{jsubset()} and \code{jcomplete()} settings and its registrations
#' apply. Any other vector is tabulated on its own. A second variable, and a
#' \code{subset} condition naming another variable, need the data frame, and
#' each stops with that form of the call.
#'
#' With a \code{juse()} default set, a name the default data frame has is
#' that frame's variable, as in every jstats function, even when a separate
#' object of the same name exists in the workspace: \code{jfreq(Region)}
#' tabulates the default frame's Region, and a line under "Using default
#' data frame" says so. A separate object is read only when the default
#' frame has no variable of that name, or when no default is set.
#'
#' @param data A data frame, or a single variable: a column of a data frame
#'   or a vector.
#' @param ... Unquoted variable name(s) within \code{data}. None when
#'   \code{data} is a single variable. A \code{c()} of names, bare
#'   or quoted, is read as the names.
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
#'   \code{frequencies} (a named list, one element per variable; each
#'   element is itself a list with seven components -- \code{valid}, the
#'   valid-row frequency table as a data frame; \code{udm}, the
#'   declared-missing rows as a data frame, empty when the variable
#'   has none; \code{na}, the system-missing row as a one-row data
#'   frame, or \code{NULL} when there are none; \code{total},
#'   \code{valid_count}, and \code{missing}, the case counts; and
#'   \code{var_label}, the variable's display label) and
#'   \code{sample_info} (pipeline and missing data counts).
#'
#' @examples
#' # With explicit data frame
#' jfreq(community, Region)
#' jfreq(community, Region, Education)
#'
#' # The data frame may also be given by name
#' jfreq(data = community, Region)
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
#' @param missing.detail Character or NULL. How much of a declared
#'   missing-value RANGE the Missing block spells out: one of
#'   \code{"totals"} (collapse the whole band into a single row),
#'   \code{"per_code"} (one row per observed in-band value, at most 10,
#'   with the remainder gathered into one line at the foot of the block),
#'   or \code{"all"} (every observed in-band value, no cap). NULL
#'   (default) defers to the \code{missing.detail} setting in
#'   \code{\link{joptions}}, whose own default is \code{"per_code"}.
#'   Declared discrete codes always print in full at every setting; the
#'   cap applies only to values reached by a range. Has no effect on a
#'   variable with no declared range.
#' @param case.processing.detail Accepted for API symmetry. jfreq's
#'   Case Processing Summary is top-table only (no missing-data
#'   breakdown), so this argument has no effect; per-variable code
#'   detail already appears in each variable's frequency table. The
#'   table itself prints only when a filter is active (even one that
#'   excluded no cases); otherwise a one-line N statement takes its
#'   place. See \code{?joutput}
#'   (\code{case.processing}).
#' @param print Logical or NULL. \code{FALSE} prints nothing -- no table,
#'   no title, no note -- and returns the result as every call does;
#'   errors and warnings still show. \code{TRUE} prints even under
#'   \code{joutput("silent")}. \code{NULL} (the default) prints unless
#'   the level is silent. For a script that keeps many results and
#'   wants no output: see \code{\link{joutput}}.
jfreq <- function(data, ..., subset = NULL, variable.id = NULL,
                  value.id = NULL, missing.detail = NULL,
                  case.processing.detail = NULL, print = NULL) {
  # print = FALSE, or joutput("silent"): the body runs inside a scope that
  # discards its output and muffles its notes; errors and warnings pass
  # (Capability Slate C3, Session 378; .jst_output_scope()).
  .jst_check_flag(print, "print", null.ok = TRUE)
  .jst_output_scope(print, {
  # A bare word where a quoted value goes (ruling R18, Session 356): the
  # front door, before anything is evaluated.
  .jst_word_args(sys.call(), match.call(expand.dots = TRUE), parent.frame(),
                 c(.jst_word_specs("variable.id", "value.id", "case.processing.detail"),
                   list(missing.detail = .jst_word_spec(c("totals", "per_code",
                                                          "all"), "a detail level"))),
                 "jfreq")

  # Resolve the first argument: explicit data frame, juse default,
  # vector input, or bare-symbol-as-variable-name (leading comma omitted).
  arg1 <- .jst_resolve_first_arg(
    data_sub      = substitute(data),
    data_missing  = missing(data),
    fn_name       = "jfreq",
    envir         = parent.frame(),
    accept_vector = TRUE
  )

  # Vector-input path (e.g. jfreq(community$Region)) -- wrap and recurse,
  # forwarding every argument (AUDIT-008; see jdesc and .jst_vector_recurse).
  if (arg1$mode == "vector_input") {
    wrapped    <- .jst_vector_frame(arg1)
    wrapped    <- .jst_vector_collision(wrapped, parent.frame(), "jfreq")
    dots       <- rlang::enquos(...)
    .jst_check_named_variables(dots, wrapped$frame, "jfreq")
    subset_sub <- substitute(subset)
    return(.jst_vector_recurse(
      jfreq, "jfreq", wrapped, parent.frame(), dots = dots,
      subset_sub = subset_sub,
      args = list(variable.id = variable.id, value.id = value.id,
                  missing.detail = missing.detail,
                  case.processing.detail = case.processing.detail)))
  }

  data              <- arg1$data
  .jst_data_name    <- arg1$name
  .jst_default_used <- arg1$mode %in% c("default", "symbol_with_default")

  # Resolved once for the whole call, so every variable in a multi-variable
  # jfreq renders its Missing block at the same granularity. Validation of a
  # bad per-call token happens here, before any table prints.
  detail_tier <- .jst_resolve_missing_detail(missing.detail)

  variables <- rlang::enquos(...)
  .jst_check_named_variables(variables, arg1$data, "jfreq")   # S290

  # Leading-comma-omitted: prepend the captured symbol to variables list
  if (arg1$mode == "symbol_with_default") {
    extra_quo <- rlang::new_quosure(arg1$first_arg_sub,
                                    env = parent.frame())
    variables <- c(list(extra_quo), variables)
    class(variables) <- "quosures"
  }
  variables <- .jst_expand_vars(variables)   # c() of names (ruling R18, S356)

  results <- list()

  # Check all variables exist before any processing
  var_names_check <- vapply(variables, rlang::quo_name, character(1))
  # No variables (Session 338; the Session 74 item): jfreq(clinic), or a
  # bare jfreq() under a juse() default, printed its title and "70 Cases in
  # the 0 Variable Pool".
  if (length(var_names_check) == 0L) {
    .jst_no_vars_stop("jfreq(community, Region)")
  }
  .jst_check_vars(data, var_names_check, .jst_data_name, default_used = .jst_default_used)

  # A list column (a data frame's or tibble's list-column, an sf geometry
  # column, a column that is itself a data frame) and a raw column cannot be
  # tabulated: after the title and the N line they stopped on R's own
  # errors -- "all arguments must have the same length", "arguments imply
  # differing number of rows: 0, 16", "unimplemented type 'raw' in
  # 'orderVector1'". They take the analysis functions' type stop, before
  # anything prints (Session 342; the S213 item, Jeff's lean 4). Every
  # other type is tabulated, as before.
  for (.fv in var_names_check) {
    .fk <- .jst_var_kind(data[[.fv]])$kind
    if (.fk %in% c("list", "raw", "other")) {
      stop(.jst_analysis_type_error_msg(.fv, .fk, "a frequency table"),
           call. = FALSE)
    }
  }

  # -- Title (printed once, before the filters run) --------------------------
  # As in jdesc() (Session 338; the S334 item). jfreq() alone printed its
  # title after the pipeline, so a stored setting that can no longer be
  # applied, a subset = that cannot be evaluated and a data frame with no
  # rows stopped with no title above the error.
  .cat_red("Frequencies\n")
  if (.jst_default_used) .jst_default_note(.jst_data_name, vars = var_names_check,
                                         envir = parent.frame())
  .jst_vector_note(data)   # the vector path's collision line (R18, S356)

  # Apply data pipeline (jcomplete, jsubset, subset) — once before per-variable loop
  subset_expr <- substitute(subset)
  pipeline <- .jst_apply_pipeline(data, .jst_data_name, .jst_default_used,
                                  subset_expr = subset_expr, envir = parent.frame(),
                                  vars = var_names_check)
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
  # The title and the default-data note are printed above, before the
  # pipeline (Session 338).
  .jst_print_msgs(pipeline$msgs)

  # Case Processing Summary (jfreq is the per-variable Frequencies layout:
  # top table only, never a bottom; per-variable code detail already lives in
  # each variable's own frequency table). case.processing.detail is accepted
  # for API uniformity but is a no-op here.
  .jst_print_case_processing(
    sample_info,
    analysis_type = "per_var_freq",
    detail        = case.processing.detail,
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

    # Blank text cells (Session 340): counted by kind off the cells as they
    # are stored, then given their one label, so "" and "   " are a single
    # <blank> row rather than two rows with no label. They stay in the
    # valid base; the footnote under the table says so.
    blank_counts <- .jst_blank_counts(temp_var)
    temp_var     <- .jst_label_blanks(temp_var)

    # Cardinality guard: count distinct non-missing values for the advisory
    # note printed with this variable's block below. (Session 47)
    n_distinct_vals <- length(unique(temp_var[!is.na(temp_var)]))

    # The pre-masking column and its declaration (S285; see TWO COLUMNS, TWO
    # JOBS below). Read here, ahead of the Valid rows, since Session 348:
    # which labeled values are VALID -- and so take a zero row when no case
    # holds them -- depends on what the variable declares missing.
    pre_col  <- pipeline$pipeline_counts$pre_pipeline_data[[variable_name]]
    pool_col <- pre_col[pipeline$pipeline_counts$surviving_ids]
    mi       <- .jst_missing_info(pre_col)
    was_factor <- is.factor(data[[variable_name]])

    # Sort key for Valid rows: build a (display_string, sort_key) mapping
    # so the table sorts numerically when the underlying values are
    # numeric, regardless of the categorical-display treatment. Without
    # this, factor() defaults to alphabetic ordering, putting "10" between
    # "1" and "2".
    sort_codes <- NULL
    sort_levels <- NULL
    # Each level's code and the variable's value labels, where the level is
    # a display string rather than the value itself (Session 399; read by
    # .jst_freq_codes() below). NULL leaves the level as its own code.
    lvl_map <- NULL

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
      # A labeled value no case holds takes a zero row (Session 348, ruling
      # R4), sorted among the values present.
      empty_chr   <- .jst_freq_empty_labels(val_labs, sort_codes, mi,
                                            text = TRUE)
      all_codes   <- c(sort_codes, empty_chr)
      all_disp    <- c(display_str[uniq],
                       .jst_format_value_labels(empty_chr, val_labs,
                                                value_mode))
      keep        <- !duplicated(all_disp)
      all_codes   <- all_codes[keep]; all_disp <- all_disp[keep]
      # The blank category first, as in a plain text variable (S340).
      sort_levels <- all_disp[order(all_codes != .jst_blank_label,
                                    all_codes)]
      temp_var    <- factor(display_str, levels = sort_levels)
      lvl_map     <- list(level = all_disp, code = all_codes,
                          labels = val_labs)

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
      # A labeled value no case holds takes a zero row (Session 348, ruling
      # R4): a valid value, not one the variable declares missing, sorted
      # among the values present -- as a factor's empty level always has.
      empty_num   <- .jst_freq_empty_labels(val_labs, sort_codes, mi)
      all_codes   <- c(sort_codes, empty_num)
      all_disp    <- c(display_str[uniq],
                       .jst_format_value_labels(empty_num, val_labs,
                                                value_mode))
      keep        <- !duplicated(all_disp)
      all_codes   <- all_codes[keep]; all_disp <- all_disp[keep]
      sort_levels <- all_disp[order(all_codes)]
      temp_var    <- factor(display_str, levels = sort_levels)
      lvl_map     <- list(level = all_disp, code = all_codes,
                          labels = val_labs)

    } else if (is.numeric(temp_var)) {
      # Plain numeric: numeric-ordered factor levels.
      uniq_vals   <- sort(unique(temp_var[!is.na(temp_var)]))
      sort_levels <- as.character(uniq_vals)
      temp_var    <- factor(as.character(temp_var), levels = sort_levels)
      lvl_map     <- list(level = sort_levels, code = uniq_vals,
                          labels = NULL)

    } else if (is.character(temp_var)) {
      # Plain text: the levels table() would build, the blank category
      # first on every machine (S340; .jst_text_factor()).
      temp_var <- .jst_text_factor(temp_var)
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
    # Decision 7).
    #
    # TWO COLUMNS, TWO JOBS (S285). Both are the PRE-MASKING column from
    # the pipeline's snapshot, so SPSS-form codes are still live values and
    # Stata/SAS tags are still tagged (Step 0's zapping, AUDIT-039, never
    # reaches them):
    #   pre_col  -- the full column. Supplies the ROW SET, via
    #               .jst_missing_info(): which codes / tags / band the
    #               variable carries. Full-column evidence on purpose: the
    #               CPS bottom and the load narrative take their row sets
    #               from the same column, and for Stata/SAS-form an
    #               UNLABELLED tag is evidenced only by its cells, so a
    #               pool-derived row set would drop a tag's row outright
    #               whenever a filter happened to exclude every cell
    #               carrying it, where the SPSS-form twin prints at 0.
    #   pool_col -- the same column restricted to the rows that survived
    #               jcomplete / jsubset / subset = (surviving_ids: the
    #               source/pool split .jst_cps_var_rows already reads).
    #               Supplies every COUNT, so the Missing rows sit on the
    #               same denominator as the Valid rows and the Total,
    #               which come from the post-pipeline temp_var.
    # Before S285 the SPSS branch read the Step-0 masking bundle
    # (udm_spss_masked_vars$entries) and the Stata branch read arg1$data
    # -- both FULL-frame counts recorded before any row filter -- so under
    # a pipeline the Missing rows, their Total %, and the System/NA row
    # were all on the wrong base and Valid + Missing != Total (S217,
    # reproduced S284). With no pipeline active surviving_ids is every
    # row, pool_col is pre_col, and nothing here changes. (pre_col,
    # pool_col and mi are read above, before the Valid rows, since
    # Session 348.)
    # Each row also carries the declared value and its label as Code and
    # Label (Session 399, Capability Slate T's build 0): Value is the row
    # as printed, '-99 ["Refused"]', which a table cannot use.
    udm_rows  <- data.frame(Value = character(0), Freq = integer(0),
                            Code = character(0), Label = character(0),
                            stringsAsFactors = FALSE)
    udm_total <- 0L

    # Zero rows (Session 348, ruling R4). The Valid block's are already in
    # valid_df (a labeled value or a factor level no case holds); a labeled
    # code inside a declared range adds its own below. Past
    # .jst_freq_zero_row_cap of them in one table none prints, and one line
    # under the table says how many there are.
    n_empty    <- sum(valid_df$Freq == 0L)
    range_zero <- NULL

    if (!is.null(mi)) {
      if (identical(mi$representation, "stata")) {
        # Stata/SAS-form: per-tag rows. haven::na_tag() distinguishes
        # lowercase (.a, .b) from uppercase (.A, .B) markers, so SAS-
        # style declarations land in their own rows correctly. Tagged NAs
        # carry no range, so missing.detail has nothing to act on here.
        tag_vec <- haven::na_tag(pool_col)
        for (i in seq_len(nrow(mi$codes))) {
          r <- mi$codes[i, ]
          row_count <- as.integer(sum(!is.na(tag_vec) & tag_vec == r$tag))
          udm_rows  <- rbind(udm_rows, data.frame(
            Value = .jst_udm_row_label(r$code, r$label),
            Freq  = row_count,
            Code  = as.character(r$code),
            Label = .jst_label_or_na(r$label),
            stringsAsFactors = FALSE))
        }
      } else {
        # SPSS-form: per-code rows, plus range rows whose granularity is
        # set by missing.detail. Each count is the number of pool cells
        # equal to the value, taken off the unclassed pool column (the
        # same comparison .jst_cps_var_rows and the Step-0 masking pass
        # use). A declared code absent from the pool counts 0 and its row
        # still prints -- the declaration, not the data, drives the row.
        x_pool     <- suppressWarnings(as.numeric(unclass(pool_col)))
        pool_count <- function(v) {
          if (is.na(v)) return(0L)
          as.integer(sum(!is.na(x_pool) & x_pool == v))
        }
        # A string variable's declared values are strings (S340): counted
        # by matching the pool's cells as stored, and listed in the order
        # .jst_missing_info() gives them.
        text_codes <- isTRUE(mi$text)
        x_pool_chr <- if (text_codes) as.character(unclass(pool_col)) else NULL

        # (1) Declared discrete codes. These are the user's own explicit
        # declaration, so they are never capped and never dropped.
        code_rows <- data.frame(Value = character(0), Freq = integer(0),
                                Code = if (text_codes) character(0)
                                       else numeric(0),
                                Label = character(0),
                                Sort = numeric(0), stringsAsFactors = FALSE)
        if (!is.null(mi$codes) && nrow(mi$codes) > 0L) {
          for (i in seq_len(nrow(mi$codes))) {
            r <- mi$codes[i, ]
            code_rows <- rbind(code_rows, data.frame(
              Value = .jst_udm_row_label(r$code, r$label),
              Freq  = if (text_codes) {
                        # A declared blank counts every blank cell (E5).
                        as.integer(sum(.jst_text_codes_mask(x_pool_chr,
                                                            r$code)))
                      } else pool_count(as.numeric(r$numeric)),
              # A declared blank is the one <blank> category, as in the
              # Valid rows and the printed row (Session 399).
              Code  = if (text_codes) {
                        if (.jst_is_blank(r$code)) .jst_blank_label
                        else as.character(r$code)
                      } else as.numeric(r$numeric),
              Label = .jst_label_or_na(r$label),
              Sort  = if (text_codes) as.numeric(i) else as.numeric(r$numeric),
              stringsAsFactors = FALSE))
          }
        }

        # (2) Range rows.
        range_rows   <- data.frame(Value = character(0), Freq = integer(0),
                                   Code = numeric(0), Label = character(0),
                                   Sort = numeric(0), stringsAsFactors = FALSE)
        overflow_row <- NULL

        if (!is.null(mi$na_range) && length(mi$na_range) == 2L) {
          rg <- mi$na_range
          # in_band: one row per DISTINCT in-band value present IN THE
          # POOL, with its pool count. The enumeration is what the
          # per_code / all tiers list, so it must come from the pool --
          # a full-column enumeration would list values the table's
          # population does not contain, at count 0, and the band would
          # never collapse. This is the one place the pool column feeds
          # .jst_missing_info(): observed = TRUE reads the cells, and the
          # band declaration it needs rides on pool_col's attributes.
          # range_values already excludes any value that is also declared
          # discretely, so summing these rows never double-counts a code
          # row.
          rv      <- .jst_missing_info(pool_col, observed = TRUE)$range_values
          in_band <- if (is.null(rv) || nrow(rv) == 0L) NULL
                     else data.frame(
                       code_display = rv$code,
                       label        = rv$label,
                       count        = vapply(as.numeric(rv$numeric),
                                             pool_count, integer(1)),
                       numeric      = as.numeric(rv$numeric),
                       stringsAsFactors = FALSE)

          # Collapse the band into one row at "totals" always, and at
          # "per_code" / "all" when no in-band value occurs. With nothing
          # to enumerate, the collapsed row keeps the DECLARATION visible
          # -- exactly as a declared discrete code prints at count 0.
          # Without this fallback a declared band would vanish from the
          # table entirely, so the enumerating tiers would tell the reader
          # LESS about the declaration than "totals" does.
          collapse_band <- identical(detail_tier, "totals") ||
                           is.null(in_band) || nrow(in_band) == 0L

          if (collapse_band) {
            # The band's cells are exactly the "range" entries (values
            # also declared discretely are filed under "code" and are
            # not double-counted here).
            range_rows <- data.frame(
              Value = sprintf("range %s to %s", rg[1], rg[2]),
              Freq  = if (is.null(in_band) || nrow(in_band) == 0L) 0L
                      else as.integer(sum(in_band$count)),
              # A band, not one value: no code and no label.
              Code  = NA_real_,
              Label = NA_character_,
              Sort  = as.numeric(min(rg)),
              stringsAsFactors = FALSE)

          } else {
            keep_n <- if (identical(detail_tier, "all")) nrow(in_band)
                      else .jst_missing_detail_cap

            if (nrow(in_band) > keep_n) {
              # SELECTION (which rows survive) is independent of DISPLAY
              # order. Labelled values rank ahead of unlabelled ones, so a
              # labelled row is never truncated while an unlabelled one
              # prints; within each group the ranking is by descending
              # count. Labelled values therefore compete among themselves
              # when they alone exceed the cap.
              has_lab  <- !is.na(in_band$label) & nzchar(in_band$label)
              rank_ord <- order(!has_lab, -in_band$count, in_band$numeric)
              keep_i   <- rank_ord[seq_len(keep_n)]
              drop_i   <- rank_ord[-seq_len(keep_n)]
              dropped  <- in_band[drop_i, , drop = FALSE]
              in_band  <- in_band[keep_i, , drop = FALSE]

              # Foot-of-block summary. It carries the dropped cells' count
              # so the Missing rows still sum to the variable's missing
              # total. Worded "values in range" rather than "unlabelled
              # values": labelled rows can be among those dropped.
              overflow_row <- data.frame(
                Value = sprintf("%s more %s in range", .jst_fmt_n(nrow(dropped)),
                                if (nrow(dropped) == 1L) "value" else "values"),
                Freq  = as.integer(sum(dropped$count)),
                Code  = NA_real_,
                Label = NA_character_,
                Sort  = Inf,
                stringsAsFactors = FALSE)
            }

            range_rows <- data.frame(
              Value = vapply(seq_len(nrow(in_band)), function(i)
                        .jst_udm_row_label(in_band$code_display[i],
                                           in_band$label[i]), character(1)),
              Freq  = as.integer(in_band$count),
              Code  = as.numeric(in_band$numeric),
              Label = .jst_label_or_na(in_band$label),
              Sort  = as.numeric(in_band$numeric),
              stringsAsFactors = FALSE)

            # A labeled code inside the range that no case in the pool
            # holds takes a zero row too (Session 348, ruling R4), as a
            # declared discrete code does. Only when the range is spelled
            # out: with nothing in it, its one "range a to b" row already
            # says 0 for every code inside it. An unlabeled number in the
            # range never gets a row, and a value also declared discretely
            # is filed under its code row above. The rows the cap dropped
            # are not "no case": they are counted in the overflow row.
            rl <- labelled::val_labels(pre_col)
            if (length(rl)) {
              rl_num <- suppressWarnings(as.numeric(unname(rl)))
              lo <- min(rg); hi <- max(rg)
              disc <- if (!is.null(mi$codes) && nrow(mi$codes) > 0L)
                        as.numeric(mi$codes$numeric) else numeric(0)
              seen <- as.numeric(rv$numeric)
              z_i  <- which(!is.na(rl_num) & rl_num >= lo & rl_num <= hi &
                            !(rl_num %in% disc) & !(rl_num %in% seen) &
                            !duplicated(rl_num))
              if (length(z_i)) {
                range_zero <- data.frame(
                  Value = vapply(z_i, function(i)
                            .jst_udm_row_label(format(rl_num[i]),
                                               names(rl)[i]), character(1)),
                  Freq  = 0L,
                  Code  = rl_num[z_i],
                  Label = .jst_label_or_na(names(rl)[z_i]),
                  Sort  = rl_num[z_i],
                  stringsAsFactors = FALSE)
                n_empty <- n_empty + nrow(range_zero)
                if (n_empty <= .jst_freq_zero_row_cap) {
                  range_rows <- rbind(range_rows, range_zero)
                }
              }
            }
          }
        }

        # (3) Assemble. The whole Missing block sorts ascending by value at
        # EVERY detail tier, as commercial statistical software does, so a
        # declared discrete code can print BELOW in-band values -- deliberate.
        #
        # ONE ORDERING PRINCIPLE ACROSS ALL THREE TIERS (S220). Before this,
        # "totals" kept the pre-S214 layout -- declared codes in DECLARATION
        # order, then the collapsed band row -- while "per_code" and "all"
        # sorted by value. A reader stepping between tiers therefore saw rows
        # move, and not only around a band: a range-free column whose codes
        # were declared out of value order reordered too, because the sort
        # covers the whole block rather than just the range rows. Declaration
        # order was a leftover, not a principle; the commercial-software
        # parity that justifies the sort does not stop applying at "totals".
        #
        # The collapsed band row sorts on its LOWER BOUND, so it lands where
        # the band actually sits among the discrete codes rather than always
        # trailing them. A code carrying no numeric value sorts last
        # (order()'s na.last default) and is still printed.
        combined <- rbind(code_rows, range_rows)
        if (nrow(combined) > 0L) {
          combined <- combined[order(combined$Sort), , drop = FALSE]
        }
        if (!is.null(overflow_row)) combined <- rbind(combined, overflow_row)

        if (nrow(combined) > 0L) {
          udm_rows <- data.frame(Value = combined$Value, Freq = combined$Freq,
                                 Code = combined$Code, Label = combined$Label,
                                 stringsAsFactors = FALSE)
        }
      }
    }

    # Past the cap, no zero row prints (Session 348, ruling R4 (c)): a
    # classification with hundreds of labels would otherwise list hundreds
    # of empty categories. The range's were never added above; the Valid
    # block's are dropped here, before any percentage is taken.
    zero_hidden <- if (n_empty > .jst_freq_zero_row_cap) n_empty else 0L
    if (zero_hidden > 0L) {
      valid_df <- valid_df[valid_df$Freq > 0L, , drop = FALSE]
    }

    # One source for the missing subtotal, so the Valid / Missing / Total
    # arithmetic holds however the block above was assembled.
    udm_total <- as.integer(sum(udm_rows$Freq, na.rm = TRUE))

    total_na <- as.integer(sum(is.na(temp_var)))

    # INVARIANT (S285). udm_total counts declared-missing cells in the pool
    # column; total_na counts NA cells in the post-masking analysis copy of
    # the same rows, and masking turned exactly those declared cells into
    # NA. So udm_total <= total_na always, and the difference is the true
    # System/NA count. A violation means a Missing-row count has come off
    # some other base than the pool -- the S217 defect, in which the
    # max(0, ...) clamp below silently absorbed the over-count and hid the
    # System/NA row with it. Internal invariant, not a user condition:
    # bare stop, not the .jst_stop emitter.
    if (udm_total > total_na) {
      stop("jfreq(): internal error -- Missing-row counts (", udm_total,
           ") exceed the missing cells in the analysis pool (", total_na,
           ") for '", variable_name, "'", call. = FALSE)
    }
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

    # The code and the label behind each Valid row (Session 399, Capability
    # Slate T's build 0). Value is the row as printed -- under the call's
    # value.id mode and the 40-column cap -- which a table cannot use: a
    # result made under value.id = "both" would put "1: Male" in a Word
    # table. The Missing rows carry theirs from where they are made. Both
    # go last, after the columns the printed table reads.
    valid_cl       <- .jst_freq_codes(valid_df$Value, lvl_map)
    valid_df$Code  <- valid_cl$code
    valid_df$Label <- valid_cl$label
    udm_rows <- udm_rows[c(setdiff(names(udm_rows), c("Code", "Label")),
                           "Code", "Label")]

    results[[variable_name]] <- list(valid = valid_df,
                                     udm   = udm_rows,
                                     na    = na_row,
                                     total = total_count,
                                     valid_count = valid_count,
                                     missing     = total_count - valid_count,
                                     blank       = blank_counts$n,
                                     var_label   = .jst_label_or_name(data, variable_name))

    # -- Print: variable anchor (name, or label under "labels") -> blank -> table
    anchor <- .jst_combine_id(variable_name, .jst_label_or_name(data, variable_name), vlmode)
    cat(anchor, "\n", sep = "")
    if (n_distinct_vals > card_warn_threshold) {
      .jst_msg_out("  Note: '", variable_name, "' has ", n_distinct_vals,
                   " distinct values; a frequency table may not be ",
                   "informative.\n  Consider jdesc() instead.")
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

    # The Valid block's subtotal (Session 348, ruling R7), whenever the
    # table has a Missing block: the valid N -- the denominator of every
    # Valid % -- stated, not left to the reader's addition. With no missing
    # data it would repeat the Total row, so it is left out.
    if (has_missing) {
      display_df <- rbind(display_df, data.frame(
        Value    = "Total valid",
        Freq     = as.character(valid_count),
        TotalPct = fmt_pct(valid_count / total_count * 100),
        ValidPct = fmt_pct(valid_count / valid_count * 100),
        CumPct   = "",
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

      # The Missing block's subtotal (Session 348, ruling R7), when the
      # block has more than one row -- SPSS FREQUENCIES' rule. One row is
      # its own total.
      if (nrow(udm_rows) + as.integer(!is.null(na_row)) > 1L) {
        display_df <- rbind(display_df, data.frame(
          Value    = "Total missing",
          Freq     = as.character(total_count - valid_count),
          TotalPct = fmt_pct((total_count - valid_count) / total_count * 100),
          ValidPct = "",
          CumPct   = "",
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

    # The four numeric columns block-centered (Session 328; they were
    # right-justified): each header over the middle of its column, the
    # counts on their ones digit and the percentages on their decimal
    # point, "--" at the right of its block. The section rows ("Valid",
    # "Missing") and the spacer rows end where their text ends.
    .jst_print_table(display_df,
                     col.names = c("", "Freq", "Total %", "Valid %", "Cum. %"),
                     row.names = FALSE,
                     align     = c("l", "bc", "bc", "bc", "bc"))
    # The zero rows left out past the cap (Session 348, ruling R4 (c)): one
    # line, against the table it explains.
    if (zero_hidden > 0L) {
      .jst_msg_out(.jst_fmt_n(zero_hidden), " ",
                   if (was_factor)
                     .jst_plural(zero_hidden, "category has", "categories have")
                   else .jst_plural(zero_hidden, "labelled value has",
                                    "labelled values have"),
                   " no cases and ",
                   .jst_plural(zero_hidden, "is", "are"), " not listed.")
    }
    # The <blank> row's footnote, against the table it explains (S340).
    if (blank_counts$n > 0L) {
      bf_col <- data[[variable_name]]
      .jst_msg_out(.jst_blank_footnote(
        blank_counts, declare = !is.factor(bf_col),
        declare_arg = if (is.factor(bf_col)) NULL
                      else .jst_text_declare_args(bf_col, "")$arg))
    }
    cat("\n")

    # value.id / variable.id legends under this variable's own table.
    .jst_print_legends_at(data, variable_name, variable_name,
                          vlmode, value_mode, "legend")
  }

  # consolidated legends after all variable tables.
  .jst_print_legends_at(data, var_names_check, var_names_check,
                        vlmode, value_mode, "legend.bottom")

  # No closing cat("\n") here (Session 328): every table above, and every
  # legend block, already ends on a blank line, so one more made jfreq the
  # one function whose output always ended on two.

  ret <- list(
    frequencies = results,
    sample_info = sample_info
  )
  class(ret) <- "jst_freq"
  ret <- .jst_stamp_result(ret)   # Session 399: the version that made it
  invisible(ret)
  })
}


#' Data screening overview
#'
#' Provides a quick overview of a data frame for screening. A red "Data
#' Screening" title is printed first (followed by a Case Processing table
#' when a filter is active), then a short header block (case and
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
#' A variable R cannot treat as a column of values -- a list column (a
#' tibble's, or the geometry column of a spatial data frame), a raw one, or
#' a column that is itself a data frame -- is listed as Unsupported and
#' screened no further; it does not stop the screening of the rest.
#'
#' Text cells with no text -- empty, or holding only spaces or tabs -- are
#' counted apart from missing values, never among them. When the screened
#' variables hold any, the header gains a "Cases with blank text" line and
#' the Missing Data & Outliers table a Blank and a % Blank column. Whether
#' a blank is absent data or a real answer depends on the file; see
#' \code{\link{jfreq}}.
#'
#' A text variable whose every value is a date written in one form -- as
#' 2015-04-01, 1-Apr-15, 28NOV2007 or 01/02/2015 -- has the sub-class
#' "date (unparsed)": a CSV file stores dates as text, and as text each
#' date is a category. A footnote under the Variable Types table gives the
#' \code{as.Date()} line that makes it a date (two lines when its values
#' could be day/month or month/day). When the dates have two-digit years,
#' a note says so: \code{as.Date()} puts 69 to 99 in the 1900s and 00 to
#' 68 in the 2000s without a warning, so a birth date written 03-Jul-68
#' becomes 2068. The note gives the \code{range()} line that shows the
#' years. Month names are read as R reads them in an English locale.
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
#' even when \code{stats} is off, surfacing the recode need. A dichotomy
#' registered with \code{jnumeric()} or \code{jcount()} is Numeric, has no
#' sub-class, and carries no marker.
#'
#' When variable names are supplied, only those variables are screened. When
#' omitted, all variables in the data frame are screened. Settings stored
#' with \code{jsubset()} and \code{jcomplete()}, and a \code{subset}
#' expression, apply to the whole data frame before the named variables are
#' taken, so they may refer to variables that are not screened.
#'
#' Given a single variable instead of a data frame, as in
#' \code{jscreen(community$Income)}, jscreen() screens that variable. A
#' column of a data frame is screened in its frame, exactly as
#' \code{jscreen(community, Income)} screens it: the frame's
#' \code{jsubset()} and \code{jcomplete()} settings and its registrations
#' apply. Any other vector is screened on its own. A second variable, and a
#' \code{subset} condition naming another variable, need the data frame, and
#' each stops with that form of the call.
#'
#' With a \code{juse()} default set, a name the default data frame has is
#' that frame's variable, as in every jstats function, even when a separate
#' object of the same name exists in the workspace, and a line under "Using
#' default data frame" says so. A separate object is read only when the
#' default frame has no variable of that name, or when no default is set.
#'
#' Those filters are accounted for as in the analysis functions: a Case
#' Processing table between the title and the header lists the original
#' count, the cases each filter excluded, and the count remaining, which the
#' header's Cases line repeats. With no filter active no table prints, and
#' the Cases line states the count. The \code{case.processing} setting of
#' \code{joutput()} applies: at the minimal tier, or with
#' \code{case.processing = FALSE}, the table is left out and the Cases line
#' carries the excluded count instead (for example
#' \code{Cases: 53 (17 Excluded)}); at the full tier, or with
#' \code{case.processing = TRUE}, the table prints even when no filter is
#' active.
#'
#' @param data A data frame, or a single variable: a column of a data frame
#'   or a vector.
#' @param ... Optional unquoted variable names to screen. If omitted,
#'   all variables in the data frame are screened. None when \code{data} is
#'   a single variable. A \code{c()} of names, bare
#'   or quoted, is read as the names.
#' @param outlier.sd Numeric. Number of standard deviations from the mean
#'   to flag as potential outliers (Numeric-class variables only). Default
#'   is 3.
#' @param subset An optional unquoted logical expression (e.g.
#'   \code{Group == 1}) to subset cases for this call only. Applied after
#'   jcomplete and jsubset. Does not affect other function calls. The
#'   cases it excludes are listed in the Case Processing table.
#'   Written in R syntax and checked the way \code{jsubset()} checks a
#'   filter: \code{subset = NOT(Age < 40)}, for example, is refused with
#'   the corrected \code{subset = !(Age < 40)} shown (see
#'   \code{\link{jsubset}} for a translation table).
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
#'   only to return a clear message rather than report \code{value.id} as
#'   a variable that was not found. Leave at NULL (default).
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
#'   "this variable carries value labels / came from SPSS, Stata, or SAS"), so it
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
#' @param print Logical or NULL. \code{FALSE} prints nothing -- no table,
#'   no title, no note -- and returns the result as every call does;
#'   errors and warnings still show. \code{TRUE} prints even under
#'   \code{joutput("silent")}. \code{NULL} (the default) prints unless
#'   the level is silent. For a script that keeps many results and
#'   wants no output: see \code{\link{joutput}}.
#'
#' @return Invisibly returns a data frame of the screening results, with one
#'   row per variable and columns including the Base R type, the jstats
#'   \code{Class} and \code{SubClass}, the classification \code{Source}
#'   ("registered" or "structural"), distinct-value count, missing count
#'   and percentage, the count and percentage of blank text cells
#'   (\code{Blank}, \code{Pct_Blank}), the outlier count (NA for
#'   non-Numeric variables), and
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
#' # The data frame may also be given by name
#' jscreen(data = community)
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
#' # A single variable
#' jscreen(community$Income)
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
                    stats = FALSE, digits = NULL, print = NULL) {
  # print = FALSE, or joutput("silent"): the body runs inside a scope that
  # discards its output and muffles its notes; errors and warnings pass
  # (Capability Slate C3, Session 378; .jst_output_scope()).
  .jst_check_flag(print, "print", null.ok = TRUE)
  .jst_output_scope(print, {
  # A bare word where a quoted value goes (ruling R18, Session 356): the
  # front door, before anything is evaluated.
  .jst_word_args(sys.call(), match.call(expand.dots = TRUE), parent.frame(),
                 c(.jst_word_specs("variable.id"),
                   list(stats = .jst_word_spec(c("none", "mean", "median",
                                                 "both"), "a statistic name"))),
                 "jscreen")
  # Validate TRUE/FALSE flags up front.
  .jst_check_flag(types, "types")
  .jst_check_flag(issues, "issues")
  .jst_check_flag(r.type, "r.type")
  if (!is.numeric(outlier.sd) || length(outlier.sd) != 1L ||
      is.na(outlier.sd) || outlier.sd <= 0) {
    .jst_stop_arg(arg = "outlier.sd",
                  requirement = "a single positive number.")
  }

  # jscreen has no per-code surface to display value labels on, so value.id
  # is accepted only to give an explicit, accurate error. A global
  # joutput(value.id=) is read by the value-displaying functions and never
  # arrives here as a per-call arg, so a non-NULL value.id can only be an
  # explicit per-call argument. Erroring here replaces the misleading
  # "variable not found: <token>" that resulted when the token fell into the
  # dots and was mistaken for a variable name. (Session 62, Option A)
  if (!is.null(value.id)) {
    .jst_stop(.jst_txt_value_id)
  }

  # Resolve stats= : hybrid logical-or-character. FALSE -> "none" (default),
  # TRUE -> "both", or one of "mean" / "median". TRUE is kept working (novices
  # try it) despite being a non-boolean toggle. digits governs the
  # decimal places of the Mean/Median columns, deferring to joutput() when NULL.
  if (isTRUE(stats))  stats <- "both"
  if (isFALSE(stats)) stats <- "none"
  stats_mode <- tryCatch(
    match.arg(stats, c("none", "mean", "median", "both")),
    error = function(e) {
      .jst_stop("`stats` must be TRUE or FALSE, or \"mean\", \"median\", ",
                "or \"both\".")
    }
  )
  digits_n   <- .jst_resolve_digits(digits)

  # Resolve the first argument: explicit data frame, juse default, vector
  # input, or bare-symbol-as-variable-name (leading comma omitted).
  arg1 <- .jst_resolve_first_arg(
    data_sub      = substitute(data),
    data_missing  = missing(data),
    fn_name       = "jscreen",
    envir         = parent.frame(),
    accept_vector = TRUE
  )

  # Vector-input path (Session 324; jscreen(community$Age)) -- the one
  # jdesc() and jfreq() take: a column of a data frame is screened in that
  # frame, any other value wrapped, every argument forwarded, and what a
  # single column cannot serve refused with the data-frame form as the fix.
  # value.id has already stopped above, and stats is passed resolved.
  if (arg1$mode == "vector_input") {
    wrapped    <- .jst_vector_frame(arg1)
    wrapped    <- .jst_vector_collision(wrapped, parent.frame(), "jscreen")
    dots       <- rlang::enquos(...)
    .jst_check_named_variables(dots, wrapped$frame, "jscreen")
    subset_sub <- substitute(subset)
    return(.jst_vector_recurse(
      jscreen, "jscreen", wrapped, parent.frame(), dots = dots,
      subset_sub = subset_sub,
      args = list(outlier.sd = outlier.sd, variable.id = variable.id,
                  types = types, issues = issues, r.type = r.type,
                  stats = stats, digits = digits)))
  }

  data              <- arg1$data
  .jst_data_name    <- arg1$name
  .jst_default_used <- arg1$mode %in% c("default", "symbol_with_default")

  # Capture subset expression before evaluation
  subset_expr <- substitute(subset)

  # Determine which variables to screen
  variables <- rlang::enquos(...)
  .jst_check_named_variables(variables, arg1$data, "jscreen")   # S290

  # Leading-comma-omitted: prepend the captured symbol to variables list
  if (arg1$mode == "symbol_with_default") {
    extra_quo <- rlang::new_quosure(arg1$first_arg_sub,
                                    env = parent.frame())
    variables <- c(list(extra_quo), variables)
    class(variables) <- "quosures"
  }
  variables <- .jst_expand_vars(variables)   # c() of names (ruling R18, S356)

  if (length(variables) > 0) {
    var_names <- vapply(variables, rlang::quo_name, character(1))
    .jst_check_vars(data, var_names, .jst_data_name, default_used = .jst_default_used)
  }

  # Red title
  .cat_red("Data Screening\n")
  if (.jst_default_used) .jst_default_note(.jst_data_name,
                      vars = if (length(variables) > 0) var_names else NULL,
                      envir = parent.frame())
  .jst_vector_note(data)   # the vector path's collision line (R18, S356)

  # Apply data pipeline (jcomplete, jsubset, subset) to the WHOLE frame, and
  # only then narrow to the named variables. Narrowing first (before S317)
  # left a stored setting on an unnamed column nothing to act on: jsubset()
  # warned that its expression could not be evaluated, jcomplete() was
  # skipped without a word, and every case was screened. A per-call subset =
  # had its variables added to the screen so it stayed evaluable; with the
  # whole frame in hand it needs no such help, so only the named variables
  # are screened, as in every other function.
  pipeline <- .jst_apply_pipeline(data, .jst_data_name, .jst_default_used,
                                  subset_expr = subset_expr, envir = parent.frame(),
                                  vars = if (length(variables) > 0) var_names else NULL)
  data     <- pipeline$data
  .jst_print_msgs(pipeline$msgs)

  if (length(variables) > 0) {
    data <- data[, var_names, drop = FALSE]
  }

  # Case Processing (Session 320): jscreen is the CPS framework's screening
  # layout. An active filter -- a stored jcomplete() or jsubset() setting, or
  # subset = -- prints the table in the block's slot, between the title and
  # the header, as in every analysis function; joutput()'s case.processing
  # setting governs it the same way. With no filter the block prints
  # nothing: the header's Cases line is the N statement (Table 4's "header"
  # family), and in never-mode (minimal, or case.processing = FALSE) the
  # printer returns the excluded count for that line to carry. No data =
  # here: the layout has no bottom and states no N line of its own, so the
  # printer needs neither the frame nor per-variable Ns.
  cps <- .jst_print_case_processing(
    .jst_build_sample_info(pipeline_counts = pipeline$pipeline_counts,
                           data            = data,
                           analysis_vars   = names(data),
                           n_analysis      = nrow(data)),
    analysis_type = "screening")
  cases_excluded <- if (is.list(cps)) cps$header_excluded else 0L

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
    # Blank text cells (Session 340): counted beside the missing cells,
    # never among them, then given their one label so the class and the
    # distinct-value count read the variable as jfreq() shows it -- the
    # empty and the whitespace cells one category.
    n_blank     <- .jst_blank_counts(col)$n
    pct_blank   <- round(n_blank / n_cases * 100, 1)
    col         <- .jst_label_blanks(col)

    jc          <- .jst_jstats_class(col, v, .jst_data_name)
    # A column that is itself a data frame (Session 342; the S213 item) has
    # rows, not cells: is.na() gives a matrix, so its missing count and its
    # distinct count are taken by row. A list column and a raw one go
    # through the general lines, which read them cell by cell.
    if (is.data.frame(col)) {
      n_missing <- 0L
      n_unique  <- nrow(unique(col))
    } else {
      n_missing <- sum(is.na(col))
      n_unique  <- length(unique(col[!is.na(col)]))
    }
    pct_missing <- round(n_missing / n_cases * 100, 1)

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
    # The star marks a dichotomy's Sub-class cell, so only a row that is
    # still Categorical takes one (Session 342; the S324 item). A 1/2
    # variable registered with jnumeric() has no sub-class: it left the
    # legend printing under a table with no starred row, or, beside another
    # variable's sub-class, a cell holding the star alone.
    star         <- is_num_dich && dich$coding %in% c("1/2", "other") &&
                    identical(jc$class, "Categorical")

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
      Blank       = n_blank,
      Pct_Blank   = pct_blank,
      Outliers    = n_outliers,
      Mean        = mean_val,
      Median      = median_val,
      Star        = star,
      Plausibility = plaus,
      stringsAsFactors = FALSE
    )
  })

  screen_table <- do.call(rbind, screen_rows)

  # Dates stored as text (Session 361; the S222 item, E3, on its lean): a
  # text variable whose every value has one date shape -- 2015-04-01,
  # 1-Apr-15, 28NOV2007 -- is Categorical with thousands of categories,
  # which is true and useless. Its Sub-class says what it is, a footnote
  # under the table gives the as.Date() line, and a two-digit year gets a
  # note: R puts 69-99 in the 1900s and 00-68 in the 2000s without a word.
  # Read on the column as given (blank cells set aside), for a structural
  # Categorical text or factor variable only.
  date_info <- list()
  for (i in seq_len(nrow(screen_table))) {
    v <- screen_table$Variable[i]
    if (!identical(screen_table$Class[i], "Categorical") ||
        !identical(screen_table$Source[i], "structural")) next
    col <- data[[v]]
    if (!(is.character(col) || is.factor(col)) || haven::is.labelled(col)) next
    di <- .jst_date_text_format(col)
    if (is.null(di)) next
    screen_table$SubClass[i] <- "date (unparsed)"
    # Session 382: the label, which the footnote's as.Date() line drops.
    di$label <- attr(col, "label", exact = TRUE)
    date_info[[v]] <- di
  }

  # -- Header block ----------------------------------------------------------
  # "Cases with missing data" = rows with >= 1 missing value (the listwise-
  # deletion magnitude). "Variables with outliers" = columns with >= 1 flagged
  # outlier (outliers are inherently per-variable, so the unit is variables).
  # Both lines always print: a 0 on either line is what explains a dropped
  # column (or the dropped Missing/Outliers table) below. (Session 51)
  # stats::complete.cases() stops on a list or raw column with R's own
  # "invalid 'type' (list) of argument", and on a column that is a data
  # frame with "not all arguments have the same length" -- the error
  # jscreen() gave for a whole frame holding one, an sf geometry column
  # being the usual case (Session 342; the S213 item). Those columns are
  # set aside for this count and screened as Unsupported rows; a list
  # column's NA cells are then counted in, as its row counts them.
  container <- vapply(data, function(col) is.list(col) || is.raw(col),
                      logical(1))
  row_missing <- if (all(container)) rep(FALSE, n_cases) else
    !stats::complete.cases(data[, !container, drop = FALSE])
  for (nm in names(data)[container]) {
    col <- data[[nm]]
    if (is.list(col) && !is.data.frame(col)) {
      row_missing <- row_missing | is.na(col)
    }
  }
  n_cases_missing <- sum(row_missing)
  n_vars_outliers <- sum(!is.na(screen_table$Outliers) & screen_table$Outliers > 0)
  # Cases with a blank cell in at least one text variable (Session 340).
  # Stated on its own line, under the missing count and never added to it:
  # a blank is absent data in one file and a real value in the next.
  blank_rows <- Reduce(`|`, lapply(data, function(col) {
    if (is.factor(col)) col <- as.character(col)
    if (is.character(col)) .jst_is_blank(col) else rep(FALSE, nrow(data))
  }), rep(FALSE, nrow(data)))
  n_cases_blank <- sum(blank_rows)

  # The never-mode rider (Session 320): the table's accounting in the form
  # every other function's N line takes, "(17 Excluded)".
  # sep = "" on every line (Session 327): cat()'s default separator put a
  # space between the value and the line end, so each of these lines ended
  # in an invisible trailing space.
  if (isTRUE(cases_excluded > 0L)) {
    cat("  Cases: ", n_cases, " (", cases_excluded, " Excluded)\n", sep = "")
  } else {
    cat("  Cases: ", n_cases, "\n", sep = "")
  }
  cat("  Variables: ", n_vars, "\n", sep = "")
  cat("  Cases with missing data: ", n_cases_missing, "\n", sep = "")
  # Printed only when there is one: a file with no blank text gains no line.
  if (n_cases_blank > 0L) {
    cat("  Cases with blank text: ", n_cases_blank, "\n", sep = "")
  }
  cat("  Variables with outliers: ", n_vars_outliers, "\n", sep = "")

  any_missing  <- any(screen_table$Missing > 0)
  any_blank    <- any(screen_table$Blank > 0)
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
    # The legend below prints only when a star was put in a cell (S342).
    show_star <- show_star && "SubClass" %in% cols
    if (show_star) {
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
    # The opt-in Mean and Median columns to digits places, trailing zeros
    # kept (Session 326). Named only when shown: the renderer refuses a name
    # that matches no column.
    # The three numeric columns -- Unique Values and, when shown, Mean and
    # Median -- block-centered; the text columns flush left, as before; no
    # line ending in padding. (Session 327)
    .jst_print_table(t1,
                     caption   = "Variable Types",
                     col.names = heads,
                     row.names = FALSE,
                     align     = ifelse(cols %in% c("Unique", "Mean", "Median"),
                                        "bc", "l"),
                     digits    = c(Mean = digits_n,
                                   Median = digits_n)[intersect(
                                     c("Mean", "Median"), cols)])

    # Conditional one-line legend, printed only when a "*" actually appeared.
    if (show_star) {
      cat("* coded other than 0/1; mean is not a proportion\n")
    }

    # Dates stored as text (Session 361, E3): the footnote under the table,
    # then the two-digit-year note.
    if (length(date_info) > 0L) {
      .jst_date_text_report(date_info, .jst_data_name)
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
  if (isTRUE(issues) && (any_missing || any_blank || any_outliers)) {
    flagged <- screen_table$Missing > 0 | screen_table$Blank > 0 |
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
      # S267: empty cells render as "--", matching the CPS convention, so
      # a blank cannot read as "not computed". Format % Missing at a fixed
      # 1 dp as a string so an all-integer-valued column still shows the
      # decimal place (e.g. "5.0", not "5"); the returned screen_table
      # keeps the numeric Pct_Missing. (Session 63)
      t2$Missing     <- ifelse(is.na(miss), "--",
                               format(miss, trim = TRUE))
      t2$Pct_Missing <- ifelse(is.na(pct), "--", sprintf("%.1f", pct))
      heads  <- c(heads, "Missing", "% Missing")
      # Block-centered (Session 313; was "r"): the values sit under the
      # middle of their headers, aligned on the ones digit / the decimal.
      aligns <- c(aligns, "bc", "bc")
    }
    if (any_blank) {
      # Blank text cells in their own pair of columns, in the Missing
      # pair's form (Session 340); shown only when a variable has one.
      blk  <- st$Blank
      bpct <- st$Pct_Blank
      bpct[blk == 0] <- NA_real_
      blk[blk == 0]  <- NA_integer_
      t2$Blank     <- ifelse(is.na(blk), "--", format(blk, trim = TRUE))
      t2$Pct_Blank <- ifelse(is.na(bpct), "--", sprintf("%.1f", bpct))
      heads  <- c(heads, "Blank", "% Blank")
      aligns <- c(aligns, "bc", "bc")
    }
    if (any_outliers) {
      out <- st$Outliers
      out[!is.na(out) & out == 0] <- NA_integer_
      t2$Outliers <- ifelse(is.na(out), "--", format(out, trim = TRUE))
      heads  <- c(heads, "Outliers")
      aligns <- c(aligns, "bc")   # block-centered like its neighbors (S313)
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

  # -- SPSS-style live-codes line (Decision 11 steering; S240 design, --------
  # S244 build). Condition-only, no remedy (S240 ruling: the steering
  # lives in the choose-first gate's menu copy and the book/guide
  # passages, and a rider here would re-import the S227 mechanics the
  # ruling kept out). Fires whenever a screened column carries
  # SPSS-form declarations -- codes and/or a range -- because base R
  # sees those values as live numbers.
  spss_live <- var_names[vapply(var_names, function(v) {
    info <- .jst_missing_info(data[[v]])
    !is.null(info) && identical(info$representation, "spss")
  }, logical(1))]
  if (length(spss_live) > 0L) {
    # Was the package's one cat()-routed wrap site, kept only because
    # stripping the builder wrap would have meant never wrapping at all.
    # With a stdout emitter in the family it strips like the rest. (S255)
    # S267: "declared missing values" covers codes AND a range (the old
    # "declared codes" misdescribed range-bearing columns); the base-R
    # sentence is pre-broken to its own line so the term cannot sever.
    .jst_msg_out(
      "\nNote: SPSS-style declared missing values on: ",
      paste(spss_live, collapse = ", "), ".\n",
      "jstats treats these as missing; base R functions do not.")
  }

  # -- Variable label legend (last; only under "legend"/"legend.bottom") -----
  # One closing blank line (Session 328): the legend block ends on its own,
  # so the closing one prints only when no legend did.
  leg <- FALSE
  if (vlmode %in% c("legend", "legend.bottom")) {
    leg <- .print_var_labels(data, var_names, lead = TRUE)
  }
  if (!leg) cat("\n")
  # Star and Plausibility are internal display flags (the "*" recode marker and
  # the "!" implausible-declaration marker); they are not part of the returned
  # screening results.
  screen_table$Star <- NULL
  screen_table$Plausibility <- NULL
  # The version that made it (Session 399), as every analysis result.
  invisible(.jst_stamp_result(screen_table))
  })
}

#' Internal: the date shapes jscreen() recognizes in text
#'
#' Session 361 (the S222 item, E3). Each entry is a pattern every value
#' must match and the as.Date() format (or two, where day/month and
#' month/day read alike) that must parse every value. Ordered so that no
#' earlier pattern matches a later one's values. The month-name forms read
#' English names, as R's month-name format does in an English locale: "1-Apr-15",
#' "28NOV2007" (SAS DATE9.), "28NOV07", "1 April 2015", "April 1, 2015".
#' @keywords internal
.jst_date_shapes <- list(
  list(re = "^[0-9]{4}-[0-9]{1,2}-[0-9]{1,2}$",       fmt = "%Y-%m-%d"),
  list(re = "^[0-9]{4}/[0-9]{1,2}/[0-9]{1,2}$",       fmt = "%Y/%m/%d"),
  list(re = "^[0-9]{1,2}/[0-9]{1,2}/[0-9]{4}$",       fmt = c("%d/%m/%Y", "%m/%d/%Y")),
  list(re = "^[0-9]{1,2}-[0-9]{1,2}-[0-9]{4}$",       fmt = c("%d-%m-%Y", "%m-%d-%Y")),
  list(re = "^[0-9]{1,2}[.][0-9]{1,2}[.][0-9]{4}$",   fmt = "%d.%m.%Y"),
  list(re = "^[0-9]{1,2}/[0-9]{1,2}/[0-9]{2}$",       fmt = c("%d/%m/%y", "%m/%d/%y")),
  list(re = "^[0-9]{1,2}-[0-9]{1,2}-[0-9]{2}$",       fmt = c("%d-%m-%y", "%m-%d-%y")),
  list(re = "^[0-9]{1,2}-[A-Za-z]{3,9}-[0-9]{4}$",    fmt = "%d-%b-%Y"),
  list(re = "^[0-9]{1,2}-[A-Za-z]{3,9}-[0-9]{2}$",    fmt = "%d-%b-%y"),
  list(re = "^[0-9]{1,2}[A-Za-z]{3}[0-9]{4}$",        fmt = "%d%b%Y"),
  list(re = "^[0-9]{1,2}[A-Za-z]{3}[0-9]{2}$",        fmt = "%d%b%y"),
  list(re = "^[0-9]{1,2} [A-Za-z]{3,9} [0-9]{4}$",    fmt = "%d %b %Y"),
  list(re = "^[A-Za-z]{3,9} [0-9]{1,2}, [0-9]{4}$",   fmt = "%b %d, %Y")
)

#' Internal: the date format a text variable's values share
#'
#' Session 361 (the S222 item, E3). Every distinct value, blank cells set
#' aside, must match one shape's pattern and parse under its format; for
#' the day/month shapes each order is tried, and both kept when the values
#' fit both (no part above 12).
#' @param x A character or factor vector.
#' @return NULL, or a list: \code{fmt}, one format or two (day/month first);
#'   \code{yy}, TRUE for a two-digit year; \code{example}, the first value.
#' @keywords internal
.jst_date_text_format <- function(x) {
  v <- as.character(x)
  v <- trimws(v[!is.na(v)])
  v <- unique(v[nzchar(v)])
  if (length(v) == 0L) return(NULL)
  for (sh in .jst_date_shapes) {
    if (!all(grepl(sh$re, v))) next
    ok <- vapply(sh$fmt, function(f) {
      d <- suppressWarnings(as.Date(v, format = f))
      all(!is.na(d))
    }, logical(1))
    if (!any(ok)) next
    fmt <- sh$fmt[ok]
    return(list(fmt = unname(fmt), yy = grepl("%y", fmt[1L], fixed = TRUE),
                example = v[1L]))
  }
  NULL
}

#' Internal: jscreen()'s footnote and note for dates stored as text
#'
#' Session 361 (the S222 item, E3, on its lean): under the Variable Types
#' table, the as.Date() line for each variable whose Sub-class is "date
#' (unparsed)" -- two lines when its values fit day/month and month/day --
#' then, for a two-digit year, a consequential note with the range() line
#' that shows the years as.Date() gives. Since Session 382 a variable with a
#' label gets, after its line or lines, the line that puts the label back
#' (\code{.jst_label_line()}), since as.Date() drops it.
#' @param date_info Named list of \code{.jst_date_text_format()} results,
#'   each with the variable's \code{label} added by jscreen().
#' @param data_name The data frame's name, for the printed lines; one that
#'   is not a name gives \code{mydata}.
#' @keywords internal
.jst_date_text_report <- function(date_info, data_name) {
  # A name or a place (lst$d) is used as typed; an expression given as
  # the data (jscreen(mk())) gets "mydata" and, opening each block of
  # lines, the line that makes it (the S343 rule; Session 374, from the
  # remedy-line audit, where the lines named a mydata nothing made).
  kind <- if (is.character(data_name) && length(data_name) == 1L &&
              !is.na(data_name) && nzchar(data_name)) {
    tryCatch(.jst_data_arg_kind(str2lang(data_name)),
             error = function(e) "expression")
  } else "expression"
  dn  <- if (kind %in% c("name", "place")) data_name else "mydata"
  pre <- if (identical(dn, "mydata") && is.character(data_name) &&
             length(data_name) == 1L && !is.na(data_name) &&
             nzchar(data_name)) {
    paste0("  mydata <- ", data_name)
  } else character(0)
  conv <- function(v, f) {
    paste0("  ", dn, "$", v, " <- as.Date(", dn, "$", v, ", format = \"", f,
           "\")")
  }
  # Session 382 (Fix Slate 25): as.Date() drops every attribute, so a
  # variable with a label gets, after its line or lines, the one that puts
  # the label back (.jst_label_line(), as jload()'s as.numeric() lines).
  lab_line <- function(v) {
    .jst_label_line(paste0(dn, "$", v), date_info[[v]]$label)
  }
  one   <- names(date_info)[lengths(lapply(date_info, `[[`, "fmt")) == 1L]
  two   <- setdiff(names(date_info), one)
  lines <- c("date (unparsed): text in a date format, which as.Date() makes a date:",
             pre)
  for (v in one) lines <- c(lines, conv(v, date_info[[v]]$fmt), lab_line(v))
  for (v in two) {
    ll <- lab_line(v)
    lines <- c(lines,
               paste0(v, "'s values fit day/month and month/day; ",
                      "run the line that fits",
                      if (length(ll)) ", then the attr() line" else "", ":"),
               conv(v, date_info[[v]]$fmt[1L]), conv(v, date_info[[v]]$fmt[2L]),
               ll)
  }
  cat("\n")
  .jst_msg_out(paste(lines, collapse = "\n"))

  yy <- names(date_info)[vapply(date_info, `[[`, logical(1), "yy")]
  if (length(yy) > 0L) {
    rng <- vapply(yy, function(v) {
      paste0("  range(as.Date(", dn, "$", v, ", format = \"",
             date_info[[v]]$fmt[1L], "\"))")
    }, character(1))
    cat("\n")
    .jst_msg(
      "Note: ", .jst_and_list(yy), " ", .jst_plural(length(yy), "has", "have"),
      " two-digit years (as in ", date_info[[yy[1L]]]$example, ").\n",
      "as.Date() puts 69-99 in the 1900s and 00-68 in the 2000s, so check ",
      "the years it gives:\n",
      paste(c(pre, rng), collapse = "\n"))
  }
  invisible(NULL)
}
