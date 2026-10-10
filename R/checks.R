#<<<FILE: checks.R>>>

#' Internal helper: check that variable names exist in a data frame
#'
#' Produces clear error messages for several common user mistakes:
#'   - data passed as a character string (quoted dataset name)
#'   - data NULL
#'   - data is a matrix (needs as.data.frame())
#'   - data is some other non-data-frame object
#'   - data is a valid data frame, but the variable names don't appear in it
#'
#' Without these tailored messages, a string or other non-data-frame value
#' for `data` would fall through to the variable-name check and produce a
#' misleading "not found" error pointing at the variables
#' rather than at the real problem (the data argument itself).
#'
#' @param data The object passed as the data frame.
#' @param var_names Character vector of variable names to check.
#' @param data_name Optional name of the data frame, used in messages.
#' @param default_used Logical. TRUE when the data frame came from the
#'   juse() default rather than being named in the call; adds a targeted
#'   hint to the not-found message that names the default and suggests the
#'   user may have meant a different loaded data frame. Defaults to FALSE,
#'   so callers that do not pass it get the unchanged message.
#'
#' @keywords internal
.jst_check_vars <- function(data, var_names, data_name = NULL,
                            default_used = FALSE) {

  # -- First: confirm `data` is actually a data frame ----------------------
  if (!is.data.frame(data)) {
    if (is.character(data) && length(data) == 1) {
      .jst_stop(
        "'", data, "' (passed as a character string) is not a data frame. ",
        "Remove the quotes -- e.g., ", data, " instead of \"", data, "\"."
      )
    }
    if (is.null(data)) {
      .jst_stop(
        "data = NULL: no data frame supplied. Pass a data frame as the ",
        "data argument, or set a default with juse() first."
      )
    }
    if (is.matrix(data)) {
      label <- if (!is.null(data_name)) data_name else "data"
      .jst_stop(
        "'", label, "' is a matrix, not a data frame. ",
        "Convert it first with: as.data.frame(", label, ")"
      )
    }
    # Catch-all: non-data-frame R object of some other type.
    label <- if (!is.null(data_name)) data_name else "data"
    .jst_stop(
      "'", label, "' is a ", class(data)[1], " object, not a data frame. ",
      "The data argument requires a data frame."
    )
  }

  # -- Guard: blank variable name from an empty positional slot ------------
  # A stray comma (e.g. jdesc(community, , Age)) leaves an empty quosure,
  # which quo_name() renders as "". Catch it here -- one consistent error
  # across the data-first family -- before the not-found check turns it
  # into an unhelpful blank-bullet "not found" message. The .jst_stop()
  # prefix auto-detects the public function via the call stack, so the
  # error names jdesc()/jfreq()/etc., not this helper. (Session 106;
  # Session 23 to-do item, guard half of the scope split.)
  if (any(!nzchar(var_names))) {
    .jst_stop(
      "Variable names cannot be blank.\n",
      "Check for a stray comma or period in the call."
    )
  }

  # -- Then: confirm the requested variables exist in the data frame -------
  missing_vars <- var_names[!var_names %in% names(data)]
  if (length(missing_vars) > 0) {
    df_label <- if (!is.null(data_name)) {
      paste0("the ", data_name, " data frame")
    } else {
      "the data frame"
    }
    # When the data frame came from the juse() default rather than being
    # named in the call, the variable names may simply belong to a different
    # loaded data frame. Add a targeted hint naming the default, but only on
    # the default path - a call that named its data frame gets no extra line.
    # (Session 106.) The hint needs a real name to point at, so it is also
    # gated on data_name being available.
    default_hint <- if (isTRUE(default_used) && !is.null(data_name)) {
      paste0("\n", data_name, " is the juse() default -- if you meant a ",
             "different data frame, name it in the call.")
    } else {
      ""
    }
    # What was typed is the subject (voice Rule AD), the verb agrees with
    # the count (Rule O) and the frame takes its article and kind (Rule T):
    # the form the S330 filter stops use for the same condition. Until
    # Session 338 this read "Variable(s) not found in d: Agee." / "Check
    # spelling and make sure the variable exists." (the S287 plural item
    # and the Session 23 rewording).
    .jst_stop(
      .jst_format_var_list(missing_vars, and = TRUE),
      .jst_plural(length(missing_vars), " was", " were"),
      " not found in ", df_label, ".\n",
      "Check the spelling.",
      default_hint
    )
  }
}

#' Internal helper: front-door check that formula functions got a formula
#'
#' Called at the top of the formula-interface functions (jt, jaov, jcrosstab,
#' jlm, jlogistic) before any output. Verifies the first input is a formula
#' and, when the data input was supplied, that it is a data frame. Without
#' this check, a swapped call like jlm(df, Income ~ Age) or a misplaced
#' leading-comma call like jlm(, Income ~ Age) sails past the opening steps
#' and crashes deep inside the data pipeline with a raw seq_len() error.
#' (Session 106.)
#'
#' Callers pass NULL for a missing formula/data input rather than the missing
#' value itself, so this helper can inspect both safely. The non-data-frame
#' data branch delegates to .jst_check_vars with an empty name list, reusing
#' its existing data-frame validation messages (quoted-string, NULL, matrix,
#' catch-all) so no wording is duplicated. All errors route through
#' .jst_stop(fn = fn) so the public function is named in the prefix.
#'
#' @param formula The formula input's value, or NULL when it was missing.
#' @param data The data input's value, or NULL when it was missing.
#' @param first_name Deparsed name of the formula input (NULL when missing);
#'   used in the swapped-order example when the user's data frame sits there.
#' @param data_name Deparsed name of the data input (NULL when missing).
#' @param example A per-function example formula string for the generic
#'   message (e.g. "DV ~ Group").
#' @param fn The public function's name, for the error prefix and examples.
#' @return invisible(NULL) when the inputs pass; otherwise never returns.
#' @keywords internal
.jst_check_formula_data <- function(formula, data, first_name, data_name,
                                    example, fn) {

  if (inherits(formula, "formula")) {
    # Formula slot is fine. If data was supplied but is NULL, fail fast with
    # a clear message: the caller collapses a missing data argument to NULL
    # too, but only a SUPPLIED data argument carries a data_name, so
    # data_name distinguishes the two. Companion to the resolver NULL guard
    # (S208) -- the data-first functions get this via .jst_resolve_first_arg;
    # the formula family gets it here, its own shared front door.
    if (is.null(data) && !is.null(data_name)) {
      if (identical(data_name, "NULL")) {
        .jst_stop(
          "NULL is not a valid data frame. ",
          "Provide a data frame, or set a default first with juse().",
          fn = fn
        )
      }
      .jst_stop(
        "'", data_name, "' exists but contains nothing (it is NULL).\n",
        "This can happen when it was created by a call that returns nothing, ",
        "such as ", data_name, " <- jload(...).\n",
        "Rebuild or reload '", data_name, "', then rerun.",
        fn = fn
      )
    }
    # If data was supplied but is not a data frame, fail fast with
    # .jst_check_vars's existing data-frame messages instead of crashing
    # later inside the pipeline.
    if (!is.null(data) && !is.data.frame(data)) {
      .jst_check_vars(data, character(0), data_name)
    }
    return(invisible(NULL))
  }

  data_is_formula <- inherits(data, "formula")
  f_text <- if (data_is_formula) {
    paste(deparse(data), collapse = " ")
  } else {
    example
  }

  if (data_is_formula && is.null(formula)) {
    # Leading-comma habit carried over from the data-first functions:
    # an empty first slot pushes the formula into the data position.
    .jst_stop(
      "The formula goes first -- e.g. ", fn, "(", f_text, ", MyData).\n",
      "With a juse() default set, no comma is needed: ",
      fn, "(", f_text, ").",
      fn = fn
    )
  }

  if (data_is_formula) {
    # Swapped order: the data frame (or another object) sits in the formula
    # slot and the formula sits in the data slot.
    d_token <- if (is.data.frame(formula) && !is.null(first_name) &&
                   nzchar(first_name)) {
      first_name
    } else {
      "MyData"
    }
    .jst_stop(
      "The formula goes first, then the data -- e.g. ",
      fn, "(", f_text, ", ", d_token, ").",
      fn = fn
    )
  }

  if (is.character(formula) && length(formula) == 1 &&
      grepl("~", formula, fixed = TRUE)) {
    # A formula written in quotes is text, not a formula -- a likely habit
    # for users arriving from syntax-as-strings environments.
    .jst_stop(
      "The formula should not be in quotes.\n",
      "Remove them -- e.g. ", fn, "(", formula, ", MyData).",
      fn = fn
    )
  }

  .jst_stop(
    "The first input must be a formula -- e.g. ",
    fn, "(", example, ", MyData).",
    fn = fn
  )
}

#' Internal helper: validate named arguments captured via ...
#'
#' Catches mis-named argument aliases that users sometimes type instead of
#' the correct name and errors with a "Did you mean" suggestion. Also
#' catches any other named argument in \code{...} that isn't on the
#' aliases list and errors with a plain unused-argument message. Used by
#' functions that accept \code{...} as a safety net (not for substantive
#' variable-passing).
#'
#' @param dots A list of arguments captured via \code{list(...)}.
#' @param aliases Named character vector. Names are the incorrect argument
#'   names that users might type; values are the correct argument names
#'   to suggest in the error message.
#' @param fn_name Character. The calling function's name, used in the
#'   error message.
#'
#' @return \code{invisible(NULL)}. Called for its side effect of
#'   throwing an error when an invalid argument name is found.
#'
#' @keywords internal
.jst_check_args <- function(dots, aliases, fn_name) {
  if (length(dots) == 0) return(invisible(NULL))
  dot_names <- names(dots)
  if (is.null(dot_names)) dot_names <- rep("", length(dots))

  for (nm in dot_names) {
    if (nzchar(nm) && nm %in% names(aliases)) {
      .jst_stop("'", nm, "' is not valid. Did you mean `", aliases[[nm]], "`?", fn = fn_name)
    }
  }
  bad <- dot_names[nzchar(dot_names)]
  if (length(bad) > 0) {
    .jst_stop("unused ", .jst_plural(length(bad), "input"), ": ",
              paste(bad, collapse = ", "), fn = fn_name)
  }
  invisible(NULL)
}

#' Internal helper: the "after applying ..." part of a group-count stop
#'
#' \code{jt()}, \code{jaov()} and \code{jcrosstab()} stop when a grouping
#' variable is left with too few categories. When a stored
#' \code{jcomplete()} or \code{jsubset()} setting is active for the data
#' frame the stop says so, since a setting that excludes a group is the
#' likely cause: "'Condition' has 1 category after applying the jcomplete
#' setting and the jsubset filter (Condition != 3)". The settings are named
#' as settings (voice Rule AE), the filter with its condition in
#' parentheses.
#'
#' Until Session 338 the phrase read "after applying jcomplete and jsubset
#' (Condition != 3)" -- a bare name with a spaced parenthesis, which read as
#' a malformed call (the S293 rider on the S287 item) -- and it was built
#' only when the data frame came from \code{juse()}, although a stored
#' setting applies to its data frame however the call names it: with the
#' frame named, \code{jt()} said "has 1 categories" and suggested
#' \code{jaov()}.
#'
#' @param data_name Character(1) or \code{NULL}; the data frame's name.
#' @return Character(1): the phrase with its leading space, or \code{""}
#'   when no stored setting is active for the data frame.
#' @keywords internal
.jst_settings_context <- function(data_name) {
  if (!is.character(data_name) || length(data_name) != 1L) return("")
  steps <- character(0)
  cs <- .jst_get_complete(data_name)
  if (!is.null(cs) && isTRUE(cs$active)) {
    steps <- c(steps, "the jcomplete setting")
  }
  fs <- .jst_get_filter(data_name)
  if (!is.null(fs) && isTRUE(fs$active)) {
    steps <- c(steps, paste0("the jsubset filter (", fs$expr_str, ")"))
  }
  if (length(steps) == 0L) return("")
  paste0(" after applying ", paste(steps, collapse = " and "))
}

#' Internal helper: the variables a model term is built from
#'
#' A name, or every name inside a computed term: \code{I(Stress > 20)} is
#' built from \code{Stress}. A name that does not parse as R -- a column
#' named with a space and given without backticks -- is returned as it is.
#'
#' @param term Character(1); a term as the model frame names it.
#' @return Character vector of variable names.
#' @keywords internal
.jst_term_vars <- function(term) {
  ex <- tryCatch(str2lang(term), error = function(e) NULL)
  v  <- if (is.null(ex)) character(0) else all.vars(ex)
  if (length(v) == 0L) .jst_unbacktick(term) else v
}

#' Internal helper: the filters of a call that name a variable
#'
#' When a variable an analysis needs to vary has one value, and a filter's
#' condition names that variable, the filter is the cause, and the stop
#' says so in place of guessing (Session 346; Jeff, on
#' \code{jlm(Flourishing ~ SocialSupport + PriorTherapy, subset =
#' PriorTherapy == 1)}: "the error message doesn't address the real
#' problem"). The filters are this call's \code{subset =} and the frame's
#' active \code{jsubset()} filter; \code{jcomplete()} keeps cases with
#' values and cannot leave one value of a variable it names.
#'
#' @param terms Character vector; the variables or terms that have one
#'   value.
#' @param sample_info The list \code{.jst_build_sample_info()} returns.
#' @param data_name Character(1) or \code{NULL}; the data frame's name.
#' @return A list: \code{per} and \code{stored} (logical: does that filter
#'   name one of the terms' variables), their condition texts, and
#'   \code{vars}, the variables the naming filters name.
#' @keywords internal
.jst_filters_naming <- function(terms, sample_info, data_name) {
  cond_vars <- function(s) {
    ex <- tryCatch(str2lang(s), error = function(e) NULL)
    if (is.null(ex)) character(0) else all.vars(ex)
  }
  tv  <- unique(unlist(lapply(terms, .jst_term_vars), use.names = FALSE))
  pe  <- sample_info$subset_expr
  pe  <- if (length(pe) >= 1L && !is.na(pe[1L]) && nzchar(pe[1L])) pe[1L]
         else NULL
  pv  <- if (is.null(pe)) character(0) else intersect(cond_vars(pe), tv)
  fs  <- .jst_get_filter(data_name)
  se  <- if (!is.null(fs) && isTRUE(fs$active)) fs$expr_str else NULL
  sv  <- if (is.null(se)) character(0) else intersect(cond_vars(se), tv)
  list(per = length(pv) > 0L, per_expr = pe,
       stored = length(sv) > 0L, stored_expr = se,
       vars = union(sv, pv))
}

#' Internal helper: the opening of a stop that a filter caused
#'
#' "subset = X == 1 keeps", "Your jsubset() filter (X == 1) keeps", or,
#' when both name the variable, the two joined with "keep".
#'
#' @param fn The list \code{.jst_filters_naming()} returns.
#' @return Character(1).
#' @keywords internal
.jst_filter_keeps <- function(fn) {
  s <- c(if (fn$stored) paste0("Your jsubset() filter (", fn$stored_expr, ")"),
         if (fn$per) paste0("subset = ", fn$per_expr))
  if (length(s) == 2L) paste0(s[1L], " and ", s[2L], " keep")
  else paste0(s, " keeps")
}

#' Internal helper: the way out of a stop that a filter caused
#'
#' A \code{subset =} is removed from the call; a stored filter is set
#' aside with the line \code{.jst_filter_exits()} gives for it.
#'
#' @param fn The list \code{.jst_filters_naming()} returns.
#' @param data_name Character(1); the data frame's name.
#' @param purpose Character(1); what the way out is for ("To estimate
#'   it").
#' @return Character(1), with no closing newline.
#' @keywords internal
.jst_filter_way_out <- function(fn, data_name, purpose) {
  aside <- paste0("  jsubset(", data_name, ", off)")
  if (fn$stored && fn$per) {
    paste0(purpose, ", remove subset = and set the filter aside:\n", aside)
  } else if (fn$stored) {
    paste0(purpose, ", set the filter aside:\n", aside)
  } else {
    paste0(purpose, ", remove the filter.")
  }
}

#' Internal helper: the line that points at the filters, hedged
#'
#' For a variable left with one value when no filter names it: the filters
#' may be the cause, so the line asks the user to check them. Only when a
#' filter excluded cases from this analysis (the S338 item: a stop that
#' guessed at \code{jsubset()} on a frame with no filter of any kind).
#'
#' @param sample_info The list \code{.jst_build_sample_info()} returns.
#' @param data_name Character(1) or \code{NULL}.
#' @param what Character(1); what the filters may be excluding ("the other
#'   values").
#' @return Character(1) starting with a newline, or \code{NULL}.
#' @keywords internal
.jst_filter_hedge <- function(sample_info, data_name, what) {
  stored <- nzchar(.jst_settings_context(data_name))
  per    <- !is.null(sample_info$subset_expr) &&
            !is.na(sample_info$subset_expr[1L]) &&
            nzchar(sample_info$subset_expr[1L])
  cut    <- sample_info$n_after_pipeline < sample_info$n_original
  if (!(cut && (stored || per))) return(NULL)
  paste0("\nCheck whether ",
         if (stored) "your jsubset or jcomplete settings",
         if (stored && per) ", or ",
         if (per) "subset =",
         if (stored && per) ",",
         if (stored) " are" else " is",
         " excluding ", what, ".")
}

#' Internal helper: stop on an outcome with one value in the analysis sample
#'
#' A regression needs an outcome that varies, and a logistic regression an
#' outcome with both of its values. Until Session 346 \code{jlm()} fitted a
#' constant outcome, \code{summary.lm()} warned "essentially perfect fit"
#' and the output stopped on R's "0 (non-NA) cases"; \code{jlogistic()}
#' said "'y' has values: 1 ... Use jrecode() to create a 0/1 coded version"
#' of an outcome coded 0/1 whose zeros a filter had removed. When a filter
#' names the outcome it is the cause, and the way out is to remove it;
#' otherwise the hedged line points at the filters when they excluded
#' cases.
#'
#' @param dv Character(1); the outcome, as the model frame names it.
#' @param value Character(1); the one value, as it is shown.
#' @param logistic Logical(1); \code{TRUE} for \code{jlogistic()}.
#' @param sample_info The list \code{.jst_build_sample_info()} returns.
#' @param data_name Character(1) or \code{NULL}.
#' @param before_listwise Logical(1); whether the filtered data already
#'   held one value of the outcome, before listwise deletion.
#' @return Never returns.
#' @keywords internal
.jst_stop_one_value_outcome <- function(dv, value, logistic, sample_info,
                                        data_name, before_listwise) {
  dv   <- .jst_unbacktick(dv)
  need <- if (logistic) "the outcome of a logistic regression needs two"
          else "a regression needs an outcome that varies"
  fn   <- .jst_filters_naming(dv, sample_info, data_name)
  if (before_listwise && (fn$per || fn$stored)) {
    .jst_stop(.jst_filter_keeps(fn), " only one value of ", dv, ", and ",
              need, ".\n",
              .jst_filter_way_out(fn, data_name, paste0("To model ", dv)))
  }
  .jst_stop(dv, " has only one value (", value, ") in the analysis sample, ",
            "and ", need, ".",
            .jst_filter_hedge(sample_info, data_name,
                              if (logistic) "the other value"
                              else "the other values"))
}

#' Internal helper: a variable's one value, as a message shows it
#'
#' A labelled code with its label ("1: Yes"), a text value as it is (a
#' blank cell as \code{<blank>}), anything else as R prints it.
#'
#' @param x The variable; its first non-missing value is shown.
#' @return Character(1).
#' @keywords internal
.jst_one_value_text <- function(x) {
  seen <- x[!is.na(x)]
  if (haven::is.labelled(x)) {
    .jst_format_value_labels(unclass(seen[1L]), labelled::val_labels(x), "both")
  } else if (is.character(seen) || is.factor(seen)) {
    .jst_label_blanks(as.character(seen[1L]))
  } else {
    as.character(seen[1L])
  }
}

#' Internal helper: stop when a filter kept one category of a predictor to
#' be dummy-coded in the call
#'
#' \code{jlm()} and \code{jlogistic()} build a predictor's dummies in the
#' call -- \code{categorical =}, a factor, a text or logical variable --
#' from the filtered data, before the Case Processing block, and with one
#' category they stopped "'gf' has fewer than 2 categories. Cannot create
#' dummy variables." When a filter names the variable it is the cause: the
#' stop says so, with both ways out, as for a registered predictor
#' (\code{.jst_prune_absent_categories()}; Session 346). Otherwise the
#' builder's own stop stands.
#'
#' @param x The variable, filtered.
#' @param v Character(1); its name.
#' @param subset_expr This call's \code{subset =} condition text, or
#'   \code{NULL}.
#' @param data_name Character(1) or \code{NULL}.
#' @return Invisibly \code{NULL}; stops when a filter kept one category.
#' @keywords internal
.jst_stop_if_filter_kept_one <- function(x, v, subset_expr, data_name) {
  seen <- x[!is.na(x)]
  u <- unique(as.character(if (haven::is.labelled(seen)) unclass(seen)
                           else seen))
  if (length(u) != 1L) return(invisible(NULL))
  fn <- .jst_filters_naming(v, list(subset_expr = subset_expr), data_name)
  if (!(fn$per || fn$stored)) return(invisible(NULL))
  .jst_stop(.jst_filter_keeps(fn), " only one category of ", v, " (",
            .jst_one_value_text(x), "), and a dummy-coded predictor ",
            "requires at least two.\n",
            .jst_filter_way_out(fn, data_name,
                                "To estimate its coefficients"), "\n",
            "To analyze only those cases, remove ", v, " from the formula.")
}

#' Internal helper: the categories a predictor dummy-coded in the call holds
#'
#' Counted as \code{.jst_make_dummy_names()} counts them: the observed
#' values, a factor's levels in use, a text variable's blank cells as one
#' category.
#'
#' @param x The variable, filtered.
#' @return Integer(1).
#' @keywords internal
.jst_n_categories <- function(x) {
  keep <- !is.na(x)
  if (is.factor(x)) return(nlevels(droplevels(x[keep])))
  if (is.character(unclass(x))) {
    v <- as.character(unclass(.jst_label_blanks(x)))
    return(length(unique(v[keep])))
  }
  length(unique(as.vector(unclass(x))[keep]))
}

#' Internal helper: stop on a predictor dummy-coded in the call that has
#' one category
#'
#' \code{jlm()} and \code{jlogistic()} build the dummies of a predictor
#' named in \code{categorical =}, or of a factor, text or logical variable,
#' in the call, before the Case Processing block. With one category the
#' builder stopped there, "'gf' has fewer than 2 categories. Cannot create
#' dummy variables.", where a predictor registered with \code{jdummy()} got
#' the Session 306 sentence under the block, naming the category, with the
#' line pointing at the filters when a filter excluded cases. The call now
#' sets such a predictor aside and this stop is made under the block, in
#' the registered predictor's words (Session 347). A filter whose
#' condition names the variable is named as the cause before this, by
#' \code{.jst_stop_if_filter_kept_one()}.
#'
#' @param one A list with \code{v}, the variable's name, and \code{x}, the
#'   variable as filtered; or \code{NULL}.
#' @param sample_info The list \code{.jst_build_sample_info()} returns.
#' @param data_name Character(1) or \code{NULL}.
#' @return Invisibly \code{NULL} when \code{one} is \code{NULL}; otherwise
#'   never returns.
#' @keywords internal
.jst_stop_one_category_in_call <- function(one, sample_info, data_name) {
  if (is.null(one)) return(invisible(NULL))
  .jst_stop(one$v, " has only one category in the analysis sample (",
            .jst_one_value_text(one$x),
            "); a dummy-coded predictor requires at least two.",
            .jst_filter_hedge(sample_info, data_name, "the other categories"))
}

#' Internal helper: does a variable hold one value before listwise deletion?
#'
#' A filter is named as the cause of a variable's one value only when the
#' filtered data already hold one value of it; when listwise deletion on
#' another variable took the rest, the filter did not. A term that is not
#' a column (a computed term) is taken as yes.
#'
#' @param data The filtered data, before listwise deletion.
#' @param v Character(1); the variable or term.
#' @return Logical(1).
#' @keywords internal
.jst_one_value_before_listwise <- function(data, v) {
  v <- .jst_unbacktick(v)
  if (is.null(data) || !(v %in% names(data))) return(TRUE)
  x <- data[[v]]
  x <- if (haven::is.labelled(x)) unclass(x) else x
  length(unique(as.vector(x[!is.na(x)]))) <= 1L
}

#' Internal helper: stop when no case is left to analyze
#'
#' The listwise functions -- \code{jt()}, \code{jaov()}, \code{jcrosstab()},
#' \code{jlm()}, \code{jlogistic()} and \code{jalpha()} -- call this directly
#' after the Case Processing block has printed. With no case left only
#' \code{jlm()} and \code{jlogistic()} had a stop of their own; the others
#' went on to answer "'g3' has 0 categories", R's "grouping factor must have
#' exactly 2 levels" or "contrasts can be applied only to factors with 2 or
#' more levels", raw "NaNs produced", and in \code{jalpha()} a warning that
#' items "NA, NA, NA" were negatively correlated (the S338 item; Session
#' 346). One stop now, ahead of every group count.
#'
#' The second line says how the cases went, from the counts the block above
#' it shows: by a filter (\code{jcomplete()}, \code{jsubset()},
#' \code{subset =}), because of missing data on an analysis variable, or
#' both. It names no table, because at \code{joutput("minimal")} the block
#' is one line.
#'
#' One case left stops the same way (Session 346): none of the six can
#' analyze one case, and the stop each reached named a variable -- "k has
#' only one value", "'g' has 1 category" -- when every variable has one
#' value in one case and the cause is the case count.
#'
#' @param sample_info The list \code{.jst_build_sample_info()} returns.
#' @return Invisibly \code{NULL} when at least two cases are left; otherwise
#'   never returns.
#' @keywords internal
.jst_stop_empty_sample <- function(sample_info) {
  n_left <- sample_info$n_analysis
  if (length(n_left) != 1L || is.na(n_left) || n_left > 1L) {
    return(invisible(NULL))
  }
  n_all     <- sample_info$n_original
  after     <- sample_info$n_after_pipeline
  by_filter <- n_all - after
  by_miss   <- after - n_left
  how <- if (by_miss == 0L) {
    "by a filter"
  } else if (by_filter == 0L) {
    "because of missing data"
  } else {
    "by a filter or because of missing data"
  }
  if (n_left == 1L) {
    if (n_all <= 1L) .jst_stop("There is only 1 case to analyze.")
    gone <- n_all - 1L
    .jst_stop("Only 1 case is left to analyze.\n",
              .jst_plural(gone, "The other case was",
                          paste0("The other ", .jst_fmt_n(gone),
                                 " cases were")),
              " excluded ", how, ".")
  }
  .jst_stop("No cases are left to analyze.\n",
            .jst_plural(n_all, "The 1 case was",
                        paste0("All ", .jst_fmt_n(n_all), " cases were")),
            " excluded ", how, ".")
}

#' Internal helper: stop when a model has no more cases than coefficients
#'
#' \code{jlm()} and \code{jlogistic()} call this after the Case Processing
#' block and the checks on single variables, just before the fit. With as
#' many cases as coefficients a linear model fits every case exactly and has
#' no residual degrees of freedom: \code{lm()} returned it, and the
#' Coefficients table printed NaN standard errors and t values, an empty p
#' column, "Adjusted R-squared: NaN" and "F-statistic: NaN on 2 and 0 DF,
#' p-value: " under R's "NaNs produced". \code{glm()} on the same cases
#' warned "fitted probabilities numerically 0 or 1 occurred" dozens of
#' times and printed an Exp(B) of 62 digits. With fewer cases than
#' coefficients some coefficients cannot be estimated at all. One stop now,
#' naming both counts, and how the other cases went when some did (Session
#' 347; the S346 item).
#'
#' @param sample_info The list \code{.jst_build_sample_info()} returns.
#' @param n_coef Integer(1); the coefficients the model would estimate, the
#'   intercept included (the columns of its model matrix).
#' @param what Character(1); "A regression" or "A logistic regression".
#' @return Invisibly \code{NULL} when there are more cases than
#'   coefficients; otherwise never returns.
#' @keywords internal
.jst_stop_too_few_cases <- function(sample_info, n_coef, what) {
  n_left <- sample_info$n_analysis
  if (length(n_left) != 1L || is.na(n_left) || length(n_coef) != 1L ||
      is.na(n_coef) || n_left > n_coef) {
    return(invisible(NULL))
  }
  n_all  <- sample_info$n_original
  after  <- sample_info$n_after_pipeline
  gone   <- n_all - n_left
  coefs  <- paste0(", and the model has ", .jst_fmt_n(n_coef), " ",
                   .jst_plural(n_coef, "coefficient", "coefficients"), ".\n")
  first  <- if (gone == 0L) {
    paste0("There are only ", .jst_fmt_n(n_left), " cases to analyze", coefs)
  } else {
    paste0("Only ", .jst_fmt_n(n_left), " cases are left to analyze", coefs)
  }
  how <- if (after == n_left) {
    "by a filter"
  } else if (after == n_all) {
    "because of missing data"
  } else {
    "by a filter or because of missing data"
  }
  .jst_stop(first,
            what, " needs more cases than coefficients.",
            if (gone > 0L) {
              paste0("\n",
                     .jst_plural(gone, "The other case was",
                                 paste0("The other ", .jst_fmt_n(gone),
                                        " cases were")),
                     " excluded ", how, ".")
            })
}

#' Internal helper: the "seems categorical" warning of jlm() and jlogistic()
#'
#' A predictor that looks categorical and entered the model as a number
#' gets a warning with the two ways to treat it as categorical, each as
#' lines to run: register it with \code{jdummy()} and run the model again,
#' or name it in \code{categorical =} for this call.
#'
#' Until Session 346 the rerun lines were built from
#' \code{.jst_unbacktick(deparse(formula))} on the REWRITTEN formula.
#' \code{deparse()} returns one string for each 60 characters, so any longer
#' formula printed cut off, with a stray closing parenthesis; the backticks
#' a name such as \code{`W2-W24 (binary)`} needs were stripped with those of
#' the computed terms; a variable already registered with \code{jdummy()}
#' appeared as its dummy columns; and a call that named its data frame was
#' offered \code{jlm(y ~ x)}, which runs only with a \code{juse()} default
#' (the S345 item). The lines are now built from the formula as typed, in
#' one piece, with the data the call named. The second call sits on a line
#' of its own: after "Or: " it was wrapped as prose, and a break could land
#' inside a backticked name.
#'
#' An expression given as the data (\code{jlm(y ~ g, mk())}) cannot be
#' registered on, so the first route names it first (\code{mydata <- mk()}),
#' as \code{jrecode()}'s reminder does since v0.9.217. Arguments of the
#' call other than the formula and the data are not repeated.
#'
#' Several predictors that seem categorical get ONE warning (Session 347):
#' each had a warning of its own, with its own \code{jdummy()} line and the
#' same refit line repeated. Now the names are joined in the first line,
#' one \code{jdummy()} call takes them all, and \code{categorical =} lists
#' them.
#'
#' @param fn Character(1); \code{"jlm"} or \code{"jlogistic"}.
#' @param v Character; the predictor's name, or the names of several.
#' @param formula The formula as the call gave it.
#' @param data_name Character(1); the data frame as the call named it, or
#'   the \code{juse()} default's name.
#' @param data_kind What the call gave as its data, as
#'   \code{.jst_data_arg_kind()} reads it.
#' @param default_used Logical; the call gave no data.
#' @param categorical The call's own \code{categorical =}, kept in the
#'   second route's line.
#' @return Character(1); the warning's text.
#' @keywords internal
.jst_seems_categorical_msg <- function(fn, v, formula, data_name, data_kind,
                                       default_used, categorical = NULL) {
  f_txt <- .jst_term_text(formula)
  # The name as a line of R takes it: in backticks when it needs them,
  # which deparse() adds to a bare name only when asked.
  v_txt <- vapply(v, function(n) paste(deparse(as.name(n), backtick = TRUE),
                                        collapse = ""), character(1))
  v_txt <- paste(v_txt, collapse = ", ")
  expr  <- identical(data_kind, "expression")
  reg   <- if (expr) "mydata" else data_name
  cats  <- unique(c(categorical, v))
  c_txt <- if (length(cats) == 1L) {
    deparse(cats)
  } else {
    paste0("c(", paste(vapply(cats, deparse, character(1)),
                       collapse = ", "), ")")
  }
  one <- length(v) == 1L
  paste0(
    .jst_and_list(v), if (one) " seems" else " seem", " categorical.\n",
    "To treat ", if (one) "it" else "them", " that way, register ",
    if (one) "it" else "them", " with jdummy() and rerun:\n\n",
    if (expr) paste0("  mydata <- ", data_name, "\n"),
    "  jdummy(", reg, ", ", v_txt, ")\n",
    "  ", fn, "(", f_txt, if (!default_used) paste0(", ", reg), ")\n\n",
    "Or, for this call only:\n",
    "  ", fn, "(", f_txt, if (!default_used) paste0(", ", data_name),
    ", categorical = ", c_txt, ")")
}

#' Internal helper: stop on a predictor with one value in the analysis sample
#'
#' \code{jlm()} and \code{jlogistic()} cannot estimate a coefficient for a
#' predictor that takes a single value. The predictor is the subject of the
#' sentence (voice Rule AD), and each sentence has a line (Rule E). A second
#' line points at the filters only when a filter excluded cases from this
#' analysis: until Session 346 the stop ended "This often happens when
#' jsubset() restricts the sample to a single category of a variable that
#' is then used as a predictor" on a frame with no filter of any kind (the
#' S338 item).
#'
#' When a filter's condition names the predictor -- \code{subset =
#' PriorTherapy == 1} with PriorTherapy in the formula -- the filter is the
#' cause and the call asks for two things that cannot both be had, so the
#' stop says what the filter did and gives both ways out: remove the filter
#' to estimate the coefficient, or remove the predictor to analyze only
#' those cases (Session 346; Jeff, on the hedged form: "the error message
#' doesn't address the real problem").
#'
#' @param vars Character vector; the predictors, as the model frame names
#'   them.
#' @param sample_info The list \code{.jst_build_sample_info()} returns.
#' @param data_name Character(1) or \code{NULL}; the data frame's name, for
#'   its stored settings.
#' @param data The filtered data before listwise deletion, or \code{NULL};
#'   a filter is named as the cause only where these data already hold one
#'   value (\code{.jst_one_value_before_listwise()}).
#' @return Never returns.
#' @keywords internal
.jst_stop_constant_predictors <- function(vars, sample_info, data_name,
                                          data = NULL) {
  vars <- .jst_unbacktick(vars)
  # A filter that names a predictor kept it to one value: say so.
  fn <- .jst_filters_naming(vars, sample_info, data_name)
  named <- vars[vapply(vars, function(v) {
    any(.jst_term_vars(v) %in% fn$vars) &&
      .jst_one_value_before_listwise(data, v)
  }, logical(1))]
  if (length(named) > 0L) {
    fn   <- .jst_filters_naming(named, sample_info, data_name)
    one  <- length(named) == 1L
    who  <- .jst_format_var_list(named, and = TRUE)
    .jst_stop(.jst_filter_keeps(fn), " only one value of ",
              if (!one) "each of ", who, ", so ",
              if (one) "its coefficient" else "their coefficients",
              " cannot be estimated.\n",
              .jst_filter_way_out(fn, data_name,
                                  if (one) "To estimate it"
                                  else "To estimate them"), "\n",
              "To analyze only those cases, remove ", who,
              " from the formula.")
  }
  one   <- length(vars) == 1L
  check <- .jst_filter_hedge(sample_info, data_name, "the other values")
  .jst_stop(.jst_format_var_list(vars, and = TRUE),
            if (one) " has only one value" else " have only one value each",
            " in the analysis sample, so ",
            if (one) "its coefficient" else "their coefficients",
            " cannot be estimated.",
            check)
}

#' Internal helper: group sizes and within-group variation of an outcome
#'
#' What \code{jt()} and \code{jaov()} need to know before they compute
#' anything: how many analysis cases each group holds, and whether the
#' outcome varies inside it. A group of one case has no variance, and a
#' group whose cases all hold one value has a variance of zero; R answers
#' both in its own words ("not enough 'y' observations", "data are
#' essentially constant"), or with an F of 27815876027865139260134097158144
#' (Session 346).
#'
#' @param y Numeric vector; the outcome.
#' @param g Factor; the groups, with no empty level.
#' @return A list: \code{n} (cases per group, named by level), \code{flat}
#'   (logical per group: two or more cases, all holding one value),
#'   \code{mean} and \code{var} (per group; \code{var} is \code{NA} for a
#'   group of one case).
#' @keywords internal
.jst_group_shape <- function(y, g) {
  ok  <- !is.na(y) & !is.na(g)
  y   <- as.numeric(y[ok])
  g   <- droplevels(g[ok])
  n   <- tapply(y, g, length)
  n[is.na(n)] <- 0L
  rng <- tapply(y, g, function(v) max(v) - min(v))
  list(n    = n,
       flat = !is.na(rng) & n >= 2L & rng == 0,
       mean = tapply(y, g, mean),
       var  = tapply(y, g, stats::var))
}

#' Internal helper: catch a named item in a variable list
#'
#' A variable list (the \code{...} of \code{jdesc()}, \code{jsum()},
#' \code{jsubset()} and the rest) takes unquoted names only; nothing reads
#' the names of that list, so a NAMED item is always a mistake. Two
#' mistakes arrive this way, and the name tells them apart (Session 290):
#' - the name is a column of the frame: a condition typed with a single
#'   \code{=}, \code{jdesc(community, Age, Gender = 1)}, where R's parser
#'   has already turned \code{Gender = 1} into an argument named Gender.
#'   Before Session 290 the value was looked up as a variable
#'   ("Variable(s) not found in community: 1."; the not-found message's
#'   wording until Session 338), and \code{jsubset()},
#'   which had no \code{...}, died inside R ("unused argument
#'   (Gender = 1)"). The error now shows the fix in the form the caller
#'   can take: \code{jsubset(Gender == 1)} for \code{jsubset()};
#'   \code{subset = Gender == 1} where the caller has a \code{subset}
#'   input (read from the caller's own formals, so the functions that do
#'   are never listed by hand); "list the variable on its own" otherwise.
#' - the name is not a column: a misspelled input that R could not
#'   partial-match (formals after \code{...} match exactly),
#'   \code{jdesc(community, Age, digit = 2)}. Routed to
#'   \code{.jst_check_args()} for its "unused input" message.
#' Unnamed items pass through untouched. Called at every
#' \code{rlang::enquos(...)} site directly after the capture, and from
#' \code{jsubset()} before its argument grammar runs.
#'
#' @param quos The captured variable list (\code{rlang::enquos(...)}).
#' @param data The resolved data frame, or \code{NULL} when no frame is in
#'   hand (\code{jsubset()} calls before resolving one); then every named
#'   item is treated as a condition.
#' @param fn_name Character. The calling function's name, for the message
#'   prefix and for the \code{jsubset()} fix form.
#' @param frame Character(1) or \code{NULL}. For \code{jsubset()}: the data
#'   frame as typed, when the call named one; the fix line keeps it
#'   (\code{jsubset(d, Gender == 1)}; Session 338, the S290 item).
#' @keywords internal
.jst_check_named_variables <- function(quos, data, fn_name, frame = NULL) {
  nms <- names(quos)
  if (is.null(nms) || !any(nzchar(nms))) return(invisible(NULL))
  named <- nms[nzchar(nms)]
  cols  <- if (is.data.frame(data)) names(data) else named
  cond  <- named[named %in% cols]
  if (length(cond) > 0L) {
    nm  <- cond[1L]
    q   <- quos[[which(nms == nm)[1L]]]
    val <- if (rlang::is_quosure(q)) rlang::quo_get_expr(q) else q
    val <- paste(deparse(val, width.cutoff = 500), collapse = " ")
    typed <- paste0(nm, " = ", val)
    fixed <- paste0(nm, " == ", val)
    if (identical(fn_name, "jsubset")) {
      .jst_stop(typed, " uses a single =, which does not test equality in R.\n",
                "Use == (two equals signs):\n",
                "  jsubset(", if (!is.null(frame)) paste0(frame, ", "),
                fixed, ")", fn = fn_name)
    }
    has_subset <- "subset" %in% names(formals(sys.function(sys.parent())))
    if (has_subset) {
      .jst_stop(typed, " uses a single =, and the variable list takes ",
                "names, not conditions.\n",
                "To select rows, use == (two equals signs) in subset =:\n",
                "  subset = ", fixed, fn = fn_name)
    }
    .jst_stop(typed, " uses a single =, and the variable list takes ",
              "names, not conditions.\n",
              "List the variable on its own:\n",
              "  ", nm, fn = fn_name)
  }
  .jst_check_args(quos[nms %in% named], aliases = character(0), fn_name)
}

#' Internal helper: resolve which data frame to use when none is explicitly given
#'
#' Looks up the data frame name set by \code{juse()} via the
#' \code{.jst_default_data} option, fetches the object from the specified
#' environment, and returns both the data frame itself and its name. The
#' name is needed by callers for output messages such as "(Using default
#' data frame: X)".
#'
#' Errors with a clear message if no default has been set, if the named
#' object cannot be found in the supplied environment, or if it is not a
#' data frame.
#'
#' @param envir Environment in which to look up the default data frame.
#'   Defaults to the parent frame so the caller's environment is searched.
#'
#' @return A list with two components:
#'   \describe{
#'     \item{data}{The resolved data frame.}
#'     \item{name}{Character string giving the name of the data frame.}
#'   }
#'
#' @keywords internal
.jst_resolve_data <- function(envir = parent.frame()) {
  data_name <- getOption(".jst_default_data", default = NULL)
  if (is.null(data_name)) {
    .jst_stop("No data frame specified and no default set. Use juse() to set a default.")
  }
  if (!exists(data_name, envir = envir)) {
    .jst_stop(paste0("Default data frame ", data_name,
                " not found. It may have been removed or renamed."))
  }
  data <- get(data_name, envir = envir)
  if (!is.data.frame(data)) {
    .jst_stop(paste0(data_name, " is not a data frame."))
  }
  list(data = data, name = data_name)
}

#' Internal helper: resolve the first positional argument of a data-first function
#'
#' Inspects the unevaluated first argument of a data-first function and
#' decides whether the user passed a real data frame, omitted the data
#' argument (so the \code{juse()} default should be used), or passed a
#' bare variable name without a leading comma (so the default should be
#' used and the captured symbol treated as the user's first content
#' argument).
#'
#' Distinguishes five outcomes via the \code{mode} field:
#' \describe{
#'   \item{\code{default}}{Data argument was missing; juse default used.}
#'   \item{\code{null}}{User passed literal \code{NULL}; only returned
#'     when \code{allow_null = TRUE}. Caller handles (e.g., for global
#'     clear semantics in jdummy/jsubset/jcomplete).}
#'   \item{\code{explicit}}{User passed an expression that evaluated
#'     to a data frame. That data frame is used.}
#'   \item{\code{vector_input}}{Only returned when
#'     \code{accept_vector = TRUE}. User passed an expression that
#'     evaluated to a non-data-frame value (typically an atomic vector
#'     or a column reference like \code{MyData$Gender}). The caller
#'     handles this --- usually by wrapping the value in a temporary
#'     data frame.}
#'   \item{\code{symbol_with_default}}{User passed a bare symbol that
#'     did not evaluate (or evaluated to a non-data-frame value when
#'     \code{accept_vector = FALSE}). Treated as a variable-name attempt
#'     missing the leading comma. The juse default is used as the data
#'     frame, and the caller is expected to inject \code{first_arg_sub}
#'     as an additional content argument.}
#' }
#'
#' Errors with a tailored message when the user passed something that
#' cannot be resolved (e.g., bare symbol with no juse default set, or
#' literal \code{NULL} when \code{allow_null = FALSE}).
#'
#' A first argument typed as a data frame's column -- \code{d$Stress} or
#' \code{d[["Stress"]]}, with \code{d} a data frame (\code{.jst_frame_column()})
#' -- is read before it is evaluated (Session 324). A name the frame does not
#' have stops with the not-found check, as \code{jdesc(d, Strss)} would,
#' instead of evaluating to NULL and meeting the empty-object guard. When
#' \code{accept_vector = FALSE} the column stops there too, with
#' \code{.jst_frame_column_stop()}: it was found, but it is not a data frame,
#' where Case 5 used to call it not found. When \code{accept_vector = TRUE}
#' it is evaluated and returned in mode \code{vector_input} with the frame
#' recorded, so the caller's re-call can run in that frame.
#'
#' @param data_sub The substituted first argument, captured by the
#'   caller via \code{substitute(data)}.
#' @param data_missing Logical. The result of \code{missing(data)} in
#'   the calling function. Must be captured by the caller because
#'   \code{missing()} cannot be used reliably across function call
#'   boundaries.
#' @param fn_name Character. The calling function's name, used in
#'   tailored error messages.
#' @param envir Environment. The calling function's parent frame; used
#'   for evaluating the first argument and looking up the juse default
#'   data frame.
#' @param allow_null Logical. If \code{TRUE}, literal \code{NULL} is
#'   returned with mode \code{null} for the caller to handle.
#'   Defaults to \code{FALSE}, in which case literal \code{NULL} errors.
#' @param accept_vector Logical. If \code{TRUE}, an expression that
#'   evaluates to a non-data-frame value is returned with mode
#'   \code{vector_input} for the caller to handle. Defaults to
#'   \code{FALSE}, in which case such inputs are treated as bare-symbol
#'   variable-name attempts (mode \code{symbol_with_default}).
#' @param pre_eval Optional. The caller's own evaluation of the first
#'   argument, as \code{list(value = , failed = )} in the shape this
#'   function builds for itself. When supplied it is used instead of
#'   evaluating \code{data_sub} again, so an argument that prints a message,
#'   or is slow to compute, runs once (AUDIT-052: jsave's pre-check and
#'   jplot's formula test both evaluate the argument first). Defaults to
#'   \code{NULL}, which evaluates as before.
#'
#' @return A list with components:
#'   \describe{
#'     \item{\code{mode}}{Character. One of \code{default},
#'       \code{null}, \code{explicit}, \code{vector_input},
#'       \code{symbol_with_default}.}
#'     \item{\code{data}}{The resolved data frame (or \code{NULL} for
#'       modes \code{null} and \code{vector_input}).}
#'     \item{\code{name}}{Character name string for messages (or
#'       \code{NULL} for modes \code{null} and \code{vector_input}).}
#'     \item{\code{first_arg_sub}}{The user's substituted first argument
#'       (or \code{NULL} when not applicable). Set for modes
#'       \code{vector_input} and \code{symbol_with_default}.}
#'     \item{\code{first_arg_value}}{The evaluated value of the first
#'       argument, set only for mode \code{vector_input}; \code{NULL}
#'       otherwise.}
#'     \item{\code{first_arg_frame}}{For mode \code{vector_input}, the
#'       \code{.jst_frame_column()} result when the argument was typed as a
#'       data frame's column, otherwise \code{NULL}; absent in the other
#'       modes.}
#'   }
#'
#' @keywords internal
.jst_resolve_first_arg <- function(data_sub, data_missing, fn_name,
                                   envir         = parent.frame(),
                                   allow_null    = FALSE,
                                   accept_vector = FALSE,
                                   pre_eval      = NULL) {

  # -- Case 1: data argument truly missing ----------------------------------
  if (data_missing) {
    resolved <- .jst_resolve_data(envir = envir)
    return(list(mode = "default",
                data = resolved$data, name = resolved$name,
                first_arg_sub = NULL, first_arg_value = NULL))
  }

  # -- Case 2: literal NULL passed in ---------------------------------------
  if (is.null(data_sub)) {
    if (allow_null) {
      return(list(mode = "null",
                  data = NULL, name = NULL,
                  first_arg_sub = NULL, first_arg_value = NULL))
    }
    .jst_stop("NULL is not a valid data argument. ",
              "Provide a data frame, or set a default first with juse().",
              fn = fn_name)
  }

  # -- A data frame's column, read before evaluation (Session 324) ----------
  # d$Stress or d[["Stress"]] with d a data frame. A name the frame does not
  # have stops with the not-found check, as jdesc(d, Strss) does: evaluated,
  # it gives NULL (a tibble warns as well), which the guard below would call
  # an object that exists but holds nothing, and data.frame's $ would
  # partial-match d$Str to Stress where the data-frame form finds no Str. A
  # function that does not take a single column refuses the column
  # truthfully -- it was found, but it is not a data frame -- where Case 5
  # called it not found and suggested a call that would not run (the S322
  # jscreen/jcorr item, part B). The call and function are the caller's, read
  # here for the fix line. The single-column functions evaluate it as before,
  # and Case 4 passes the frame on, so their re-call runs in it (part A).
  frame_col <- .jst_frame_column(data_sub, envir)
  if (!is.null(frame_col)) {
    if (!frame_col$present) {
      .jst_check_vars(get(frame_col$frame, envir = envir), frame_col$var,
                      frame_col$frame)
    }
    if (!accept_vector) {
      caller_call <- sys.call(sys.parent())
      caller_fun  <- sys.function(sys.parent())
      .jst_frame_column_stop(data_sub, frame_col, fn_name,
                             cl = caller_call, fun = caller_fun,
                             envir = envir)
    }
  }

  # -- Try to evaluate the substituted first argument -----------------------
  # A caller that has already evaluated the argument passes the result in
  # (pre_eval), so the user's expression runs exactly once (AUDIT-052).
  eval_result <- if (!is.null(pre_eval)) pre_eval else tryCatch(
    list(value = eval(data_sub, envir = envir), failed = FALSE),
    error = function(e) list(value = NULL, failed = TRUE)
  )

  # -- Guard: existing object that evaluated to NULL ------------------------
  # A literal NULL was handled at Case 2. Reaching here with a NULL VALUE
  # means an existing object that contains nothing -- e.g. the result of
  # capturing jload()'s return, which is NULL. Without this check the value
  # slips past Case 3 and, on accept_vector functions, reaches the Case-4
  # vector wrap, where data.frame(x = NULL) yields a zero-column frame and a
  # cryptic names<- length error (S205 finding). Stop cleanly instead.
  if (!eval_result$failed && is.null(eval_result$value)) {
    data_str <- paste(deparse(data_sub), collapse = "")
    .jst_stop(
      "'", data_str, "' exists but contains nothing (it is NULL).\n",
      "This can happen when it was created by a call that returns nothing, ",
      "such as ", data_str, " <- jload(...).\n",
      "Rebuild or reload '", data_str, "', then rerun.",
      fn = fn_name
    )
  }

  # -- Case 3: evaluated to a data frame ------------------------------------
  if (!eval_result$failed && is.data.frame(eval_result$value)) {
    return(list(mode = "explicit",
                data = eval_result$value,
                name = paste(deparse(data_sub), collapse = ""),
                first_arg_sub = NULL, first_arg_value = NULL))
  }

  # -- Cases 4 and 5 both need the juse default to fall back on -------------
  default_name <- getOption(".jst_default_data", default = NULL)

  # -- Case 4: evaluated to a non-data-frame value (vector input) -----------
  # Under a juse() default, a bare name the default frame has is the frame's
  # variable (Session 348, ruling R12), as it is in every function that does
  # not take a single column: jdesc(Age) with a separate vector Age in the
  # workspace described the vector and said nothing. The object is read only
  # when the default frame has no variable of that name, or with no default.
  # The caller's default note says which was read (.jst_default_note()).
  if (accept_vector && !eval_result$failed && is.symbol(data_sub) &&
      !is.null(default_name) && is.null(frame_col)) {
    dflt <- if (exists(default_name, envir = envir))
              get(default_name, envir = envir) else NULL
    if (is.data.frame(dflt) && as.character(data_sub) %in% names(dflt)) {
      return(list(mode = "symbol_with_default",
                  data = dflt, name = default_name,
                  first_arg_sub = data_sub, first_arg_value = NULL))
    }
  }
  if (accept_vector && !eval_result$failed) {
    return(list(mode = "vector_input",
                data = NULL, name = NULL,
                first_arg_sub   = data_sub,
                first_arg_value = eval_result$value,
                first_arg_frame = frame_col))
  }

  # -- Case 5: bare symbol that didn't evaluate (or non-data-frame value
  #            when accept_vector = FALSE). Treat as a variable name. -------
  if (is.null(default_name)) {
    # A condition or computed value naming a data frame, typed where the
    # frame goes (Session 330, the S324 item): jsubset(d$Age > 40) with no
    # juse() default. It is not a name that was "not found", and the call
    # this branch suggests, jsubset(MyData, d$Age > 40), would be refused
    # for naming d. With a default set the same input reaches jsubset()'s
    # own S323 refusal; this is that refusal with the frame first. A plain
    # frame$column was dealt with above (.jst_frame_column()).
    frames <- .jst_frame_refs(data_sub, character(0), envir)
    if (length(frames) > 0L) {
      .jst_frame_first_stop(data_sub, frames, fn_name,
                            cl = sys.call(sys.parent()), envir = envir)
    }
    # The first sentence says what was checked (S334): an input that did
    # not evaluate was "not found"; one that evaluated to something other
    # than a data frame was found, and until 0.9.211 was called "not
    # found" too (z <- 1:3; jcorr(z)).
    data_str <- paste(deparse(data_sub), collapse = "")
    .jst_stop(
      "'", data_str,
      if (eval_result$failed) "' not found." else "' is not a data frame.",
      " Did you mean to use it as a variable name?\n",
      "If so, provide the data frame: ", fn_name, "(MyData, ", data_str, ")\n",
      "Or set a default first with juse(MyData), then: ", fn_name, "(", data_str, ")",
    fn = fn_name)
  }
  resolved <- .jst_resolve_data(envir = envir)
  list(mode = "symbol_with_default",
       data = resolved$data, name = resolved$name,
       first_arg_sub = data_sub, first_arg_value = NULL)
}

#' Internal helper: refuse an expression naming a data frame where the frame goes
#'
#' The resolver's stop for a first argument that is neither a data frame nor
#' a plain \code{frame$column} but names a data frame, with no
#' \code{juse()} default to fall back on: \code{jsubset(d$Age > 40)}
#' (Session 330; the S324 item). Case 5 called it "not found" and suggested
#' a call that names the frame twice. When the function is \code{jsubset()},
#' the expression is the call's only argument, one frame is named and every
#' reference to it rewrites to a variable the frame has, the fix line is the
#' call with the frame first and the variables on their own; otherwise the
#' sentence is given without a call.
#'
#' @param data_sub The substituted first argument.
#' @param frames Character; the data frames it names
#'   (\code{.jst_frame_refs()}).
#' @param fn_name Character; the user-facing function's name.
#' @param cl The caller's call, as typed.
#' @param envir The caller's environment.
#' @return Does not return; stops.
#' @keywords internal
.jst_frame_first_stop <- function(data_sub, frames, fn_name, cl, envir) {
  typed <- .jst_term_text(data_sub)
  fr    <- frames[1L]
  head  <- paste0(typed, " names the ", fr, " data frame.\n")
  s     <- .jst_strip_frame_refs(data_sub, frames)
  what  <- if (length(s$cols) == 1L) "the variable" else "each variable"
  frame <- tryCatch(get(fr, envir = envir), error = function(e) NULL)
  if (identical(fn_name, "jsubset") && is.call(cl) && length(cl) == 2L &&
      length(frames) == 1L && s$clean && !s$summary &&
      is.data.frame(frame) && all(s$cols %in% names(frame))) {
    .jst_stop(head, "Name the data frame first, and ", what,
              " on its own:\n",
              "  jsubset(", fr, ", ", .jst_term_text(s$expr), ")",
              fn = fn_name)
  }
  .jst_stop(head, "Name the data frame first, and each variable on its own.",
            fn = fn_name)
}

#' Internal helper: a first argument typed as a data frame's column
#'
#' Recognizes \code{d$Stress}, and \code{d[["Stress"]]} with a single quoted
#' name, where \code{d} is a name for a data frame in \code{envir} (Session
#' 324). The resolver reads it before evaluating the argument: a misspelled
#' column evaluates to NULL, which its empty-object guard would describe as
#' an object holding nothing, and data.frame's dollar sign partial-matches
#' \code{d$Str} to \code{Stress} where \code{jdesc(d, Str)} finds no such
#' variable. Anything else -- a frame reached through a list, \code{d[, 2]},
#' a computed vector -- gives NULL and is evaluated as before.
#'
#' @param e The substituted first argument.
#' @param envir The environment the argument would be evaluated in.
#' @return NULL, or a list of \code{frame} (the data frame's name),
#'   \code{var} (the column named) and \code{present} (TRUE when the frame
#'   has a column of exactly that name).
#' @keywords internal
.jst_frame_column <- function(e, envir) {
  if (!is.call(e) || length(e) != 3L || !is.symbol(e[[1L]]) ||
      !is.symbol(e[[2L]])) {
    return(NULL)
  }
  h   <- as.character(e[[1L]])
  col <- NULL
  if (h == "$" && (is.symbol(e[[3L]]) || is.character(e[[3L]]))) {
    col <- as.character(e[[3L]])
  } else if (h == "[[" && is.character(e[[3L]]) && length(e[[3L]]) == 1L) {
    col <- e[[3L]]
  }
  if (length(col) != 1L || is.na(col) || !nzchar(col)) return(NULL)
  fr <- as.character(e[[2L]])
  if (!nzchar(fr) || !exists(fr, envir = envir)) return(NULL)
  obj <- get(fr, envir = envir)
  if (!is.data.frame(obj)) return(NULL)
  list(frame = fr, var = col, present = col %in% names(obj))
}

#' Internal helper: refuse a data frame's column where the frame goes
#'
#' The resolver's stop for a function that does not take a single column,
#' given one as its first argument: \code{jcorr(d$Income, d$Age)} (Session
#' 324, the S322 jscreen/jcorr item, part B). Case 5 said "'d$Income' not
#' found" and suggested \code{jcorr(MyData, d$Income)}; the column was found,
#' it is not a data frame, and that call would not run either. The fix line
#' is the user's own call with the frame first and its columns on their own
#' (\code{.jst_frame_column_fix()}); when that rebuild cannot be complete the
#' sentence is given without a call.
#'
#' @param data_sub The substituted first argument.
#' @param fcol Its \code{.jst_frame_column()} result.
#' @param fn_name Character; the user-facing function's name.
#' @param cl The caller's call, as typed.
#' @param fun The caller's function, for its formals.
#' @param envir The caller's environment.
#' @return Does not return; stops.
#' @keywords internal
.jst_frame_column_stop <- function(data_sub, fcol, fn_name, cl, fun, envir) {
  typed <- paste(deparse(data_sub), collapse = "")
  head  <- paste0(typed, " is a single variable, not a data frame.\n")
  fix   <- tryCatch(.jst_frame_column_fix(data_sub, fcol, fn_name, cl, fun,
                                          envir),
                    error = function(e) NULL)
  if (!is.null(fix)) {
    .jst_stop(head, "Name the data frame first:\n  ", fix, fn = fn_name)
  }
  .jst_stop(head, "Name the data frame first, and each variable on its own.",
            fn = fn_name)
}

#' Internal helper: the call a data frame's column should have been
#'
#' Rebuilds the caller's call with the frame first and the column after it
#' -- \code{jcorr(d$Income, d$Age, method = "spearman")} becomes
#' \code{jcorr(d, Income, Age, method = "spearman")} -- for
#' \code{.jst_frame_column_stop()}. The frame's other columns become bare
#' names through \code{.jst_strip_frame_refs()}, a named argument keeps its
#' name, and the column goes where the function takes variables: straight
#' after the frame when its second formal is \code{...}, \code{var},
#' \code{orig.var} or \code{expr}, or when nothing positional follows
#' (\code{jconvert(d$Stress, to = "stata")}). Gives NULL -- the sentence
#' without a call -- when the rebuild cannot be complete: the argument is not
#' found in the call, a positional argument would land in the wrong slot,
#' a summary of the frame is used (\code{mean(d$Age)}), or a data frame is
#' still named after the rewrite (another frame's column, \code{d[, 2]}).
#'
#' @inheritParams .jst_frame_column_stop
#' @return Character; the rebuilt call on one line, or NULL.
#' @keywords internal
.jst_frame_column_fix <- function(data_sub, fcol, fn_name, cl, fun, envir) {
  if (!is.call(cl) || !is.function(fun)) return(NULL)
  args <- as.list(cl)[-1L]
  hit  <- which(vapply(args, function(a) identical(a, data_sub), logical(1)))
  if (length(hit) != 1L) return(NULL)
  nms  <- names(args)
  if (is.null(nms)) nms <- rep("", length(args))
  rest <- args[-hit]
  fmls <- names(formals(fun))
  if (length(fmls) < 2L) return(NULL)
  if (!(fmls[2L] %in% c("...", "var", "orig.var", "expr")) &&
      any(!nzchar(nms[-hit]))) {
    return(NULL)
  }
  s <- .jst_strip_frame_refs(as.call(c(list(as.name(fn_name)), rest)),
                             fcol$frame)
  if (isTRUE(s$summary)) return(NULL)
  if (length(.jst_frame_refs(s$expr, character(0), envir)) > 0L) return(NULL)
  out <- as.call(c(list(as.name(fn_name), as.name(fcol$frame),
                        as.name(fcol$var)), as.list(s$expr)[-1L]))
  .jst_term_text(out)
}

#' Internal helper: wrap a bare column for the vector-input path
#'
#' Builds the one-column data frame that jdesc(), jfreq() and jscreen()
#' analyze when given a bare column, as in \code{jdesc(community$Age)}, plus
#' the names their messages use: the column as typed, the variable name, and
#' the frame it came from. A column of a data frame (the resolver's
#' \code{first_arg_frame}, Session 324) takes both names from that frame, so
#' \code{d[["Age"]]} reads as Age from d, and is marked \code{in_frame} for
#' \code{.jst_vector_recurse()}.
#'
#' Anything else is read by its SHAPE (Session 342; the S338 item). A place
#' ending in a name -- \code{lst$d$Sex}, a data frame held in a list -- is
#' named for that last part, with the rest as its frame. A plain name
#' (\code{x}) is named for itself, with the placeholder frame MyData. A
#' COMPUTED vector -- \code{d$Sex[d$Age > 40]}, \code{log(d$Age)},
#' \code{c(1, 2, 3)} -- is named with the expression as typed and marked
#' \code{computed}: until then the name was whatever followed the last
#' dollar sign of the text, so those two tables were titled "Age > 40]" and
#' "Age)", and the fix line built from the same split read
#' \code{jfreq(d$Sex[d, Age > 40], Grp)}. A computed vector has no data
#' frame to name in a fix line, so \code{.jst_vector_recurse()} gives it the
#' sentence without one.
#'
#' @param arg1 The \code{.jst_resolve_first_arg()} result, mode
#'   \code{vector_input}.
#' @return A list with \code{frame}, \code{typed}, \code{var},
#'   \code{frame_nm}, \code{in_frame} and \code{computed}.
#' @keywords internal
.jst_vector_frame <- function(arg1) {
  e     <- arg1$first_arg_sub
  typed <- paste(deparse(e), collapse = "")
  fc    <- arg1$first_arg_frame
  # The last part of a place, when it is a name: lst$d$Sex, lst$d[["Sex"]].
  last  <- NULL
  if (is.null(fc) && is.call(e) && length(e) == 3L && is.symbol(e[[1L]]) &&
      identical(.jst_data_arg_kind(e), "place")) {
    h <- as.character(e[[1L]])
    if (h == "$" && (is.symbol(e[[3L]]) || is.character(e[[3L]]))) {
      last <- as.character(e[[3L]])
    } else if (h == "[[" && is.character(e[[3L]]) && length(e[[3L]]) == 1L) {
      last <- e[[3L]]
    }
    if (length(last) != 1L || is.na(last) || !nzchar(last)) last <- NULL
  }
  computed <- is.null(fc) && is.null(last) && !is.symbol(e)
  var      <- if (!is.null(fc)) fc$var else if (!is.null(last)) last else typed
  # A list (a data frame's list column, d$geom) cannot be spread into a
  # column by data.frame(), which stopped here with R's "arguments imply
  # differing number of rows" before the function could refuse the type;
  # it is put in whole (Session 342).
  val      <- arg1$first_arg_value
  frame    <- tryCatch(data.frame(x = val), error = function(e) NULL)
  if (is.null(frame) || ncol(frame) != 1L) {
    frame   <- data.frame(x = seq_len(NROW(val)))
    frame$x <- val
  }
  names(frame) <- var
  list(frame = frame, typed = typed, var = var,
       frame_nm = if (!is.null(fc)) fc$frame
                  else if (!is.null(last))
                    paste(deparse(e[[2L]]), collapse = "")
                  else "MyData",
       in_frame = !is.null(fc),
       computed = computed)
}

#' Internal helper: re-call jdesc(), jfreq() or jscreen() on a bare column
#'
#' The vector-input path's re-call. Every argument the caller received is
#' forwarded (AUDIT-008: the re-call once passed only some of them, so
#' digits, subset and case.processing.detail were silently ignored), and the
#' call is evaluated in a child of the caller's environment, so a subset
#' condition finds the same objects it would in the data-frame form. What a
#' single column cannot serve is refused, each time with the data-frame form
#' as the fix: further variables, a by grouping, and a subset condition
#' naming another variable. A condition may name the wrapped variable or an
#' object in the caller's environment. A column reached through a data frame
#' with the dollar sign (\code{subset = d$Keep01 == 1}) was served until
#' Session 323; it is refused now, with the data-frame form as the fix,
#' because the re-call would read it from the user's raw frame, past its
#' declared missing values -- the S322 ruling the data-frame form's
#' \code{subset =} follows.
#'
#' A column of a data frame (\code{wrapped$in_frame}, Session 324) is
#' re-called in that frame -- \code{jdesc(d$Age)} as \code{jdesc(d, Age)} --
#' so the frame's stored \code{jsubset()} and \code{jcomplete()} settings and
#' its registrations, all kept by the frame's name, apply as they do in the
#' data-frame form. Until then the re-call ran on a one-column copy under an
#' internal name: a stored filter was skipped, and the yellow line said it
#' was "not active for this dataset". Any other value (\code{c(...)}, a
#' computed vector) is still wrapped. The refusals above apply to both.
#'
#' An empty vector that is not a data frame's column
#' (\code{jdesc(numeric(0))}) is refused first, as typed (Session 338): the
#' re-call's zero-row guard named the internal frame.
#'
#' @param fn The calling function, called again.
#' @param fn_name Character: its name, for messages and the re-call.
#' @param wrapped The \code{.jst_vector_frame()} result.
#' @param user_env The caller's parent frame.
#' @param dots The caller's \code{rlang::enquos(...)}; named items have
#'   already been refused by \code{.jst_check_named_variables()}.
#' @param subset_sub The caller's \code{substitute(subset)}, or \code{NULL}.
#' @param by_quo The caller's \code{rlang::enquo(by)}, or \code{NULL} for a
#'   function without a by argument.
#' @param args Named list of the remaining arguments' values.
#' @return The re-call's value.
#' @keywords internal
.jst_vector_recurse <- function(fn, fn_name, wrapped, user_env, dots = list(),
                                subset_sub = NULL, by_quo = NULL,
                                args = list()) {
  typed    <- wrapped$typed
  var      <- wrapped$var
  # An empty vector (Session 338; the S324 item) is refused here, as typed:
  # jdesc(numeric(0)) reached the re-call's zero-row guard, which named the
  # internal one-column frame ("the temp_df data frame has no rows"). A
  # column of a data frame is left to the re-call, which names that frame.
  if (!isTRUE(wrapped$in_frame) && nrow(wrapped$frame) == 0L) {
    .jst_stop(typed, " has no values, so there is nothing to analyze.",
              fn = fn_name)
  }
  lead     <- paste0(" the data frame, not the single column ", typed, ".\n")
  no_frame <- function(x) sub("^.*\\$", "", x)
  # A computed vector (Session 342) has no data frame to put in a fix line:
  # the three refusals below end on the sentence alone, where the line
  # built from the text read jfreq(d$Sex[d, Age > 40], Grp).
  computed <- isTRUE(wrapped$computed)
  first    <- if (computed)
    "Name the data frame first, and each variable on its own." else
    "Name the data frame first:\n"
  fix      <- function(tail) {
    if (computed) return("")
    paste0("  ", fn_name, "(", wrapped$frame_nm, ", ", var, ", ", tail, ")")
  }

  if (length(dots) > 0L) {
    extra <- vapply(dots, rlang::quo_name, character(1), USE.NAMES = FALSE)
    .jst_stop(.jst_format_var_list(extra, and = TRUE),
              if (length(extra) == 1L) " needs" else " need", lead, first,
              fix(paste(no_frame(extra), collapse = ", ")), fn = fn_name)
  }
  if (!is.null(by_quo) && !rlang::quo_is_null(by_quo)) {
    by_typed <- paste(deparse(rlang::quo_get_expr(by_quo)), collapse = "")
    .jst_stop("by = ", by_typed, " needs", lead, first,
              fix(paste0("by = ", no_frame(by_typed))), fn = fn_name)
  }
  if (!is.null(subset_sub)) {
    # A data frame named in the condition (Session 323): the re-call would
    # read d$Keep01 from the raw frame, as subset = does in the data-frame
    # form, which refuses it. Refused here first, with that form as the fix;
    # the scan below reads d$Keep01 as the object d and would pass it.
    frames <- .jst_frame_refs(subset_sub, var, user_env)
    if (length(frames) > 0L) {
      sub_typed <- paste(deparse(subset_sub), collapse = " ")
      fr <- if (wrapped$frame_nm %in% frames) wrapped$frame_nm else frames[1L]
      s  <- .jst_strip_frame_refs(subset_sub, frames)
      head <- paste0("subset = ", sub_typed, " names the ", fr,
                     " data frame.\n")
      if (identical(fr, wrapped$frame_nm) && s$clean && !s$summary) {
        .jst_stop(head, first, fix(paste0("subset = ", .jst_term_text(s$expr))),
                  fn = fn_name)
      }
      if (identical(fr, wrapped$frame_nm) && !s$summary) {
        .jst_stop(head, "Name the data frame first, and each variable on ",
                  "its own.", fn = fn_name)
      }
      .jst_stop(head, "Save what you need from the ", fr, " data frame ",
                "under a new name, and use that name in the condition.",
                fn = fn_name)
    }
    # Names the condition uses as values: the right side of frame$column is
    # not a free name, and a call's function position is not walked.
    syms <- function(e) {
      if (is.symbol(e)) return(setdiff(as.character(e), ""))
      if (!is.call(e)) return(character(0))
      h <- e[[1L]]
      if (is.symbol(h) && as.character(h) %in% c("$", "@")) return(syms(e[[2L]]))
      unlist(lapply(as.list(e)[-1L], syms), use.names = FALSE)
    }
    other <- setdiff(unique(syms(subset_sub)), var)
    known <- vapply(other, function(nm) exists(nm, envir = user_env) &&
                      !is.function(get(nm, envir = user_env)), logical(1))
    other <- other[!known]
    if (length(other) > 0L) {
      sub_typed <- paste(deparse(subset_sub), collapse = " ")
      .jst_stop("subset = ", sub_typed, " refers to ", other[1L],
                ", which the single column ", typed, " does not contain.\n",
                first, fix(paste0("subset = ", sub_typed)), fn = fn_name)
    }
  }

  env <- new.env(parent = user_env)
  assign(fn_name, fn, envir = env)
  # A column of a data frame is analyzed in that frame (Session 324), so its
  # stored settings and registrations apply. The frame is reached by name
  # from the caller's environment, as in the data-frame form; a frame named
  # like the function itself would be hidden by the binding above, so it is
  # wrapped instead.
  if (isTRUE(wrapped$in_frame) && !identical(wrapped$frame_nm, fn_name)) {
    cl <- as.call(c(list(as.symbol(fn_name), as.symbol(wrapped$frame_nm),
                         as.symbol(var)),
                    args, list(subset = subset_sub)))
    return(eval(cl, env))
  }
  assign("temp_df", wrapped$frame, envir = env)
  cl <- as.call(c(list(as.symbol(fn_name), as.symbol("temp_df"), as.symbol(var)),
                  args, list(subset = subset_sub)))
  eval(cl, env)
}
