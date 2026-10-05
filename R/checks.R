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
