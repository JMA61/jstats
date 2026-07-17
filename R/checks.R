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
#' misleading "Variable(s) not found" error pointing at the variables
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
        "Remove the quotes - e.g., ", data, " instead of \"", data, "\"."
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
  # A stray comma (e.g. jdesc(SampleData, , Age)) leaves an empty quosure,
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
      data_name
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
      paste0("\n", data_name, " is the juse() default - if you meant a ",
             "different data frame, name it in the call.")
    } else {
      ""
    }
    .jst_stop(
      "Variable(s) not found in ", df_label, ": ",
      paste(missing_vars, collapse = ", "), ".\n",
      "Check spelling and make sure the variable exists.",
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
    # Formula slot is fine. If data was supplied but is not a data frame,
    # fail fast with .jst_check_vars's existing data-frame messages instead
    # of crashing later inside the pipeline.
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
      "The formula goes first - e.g. ", fn, "(", f_text, ", SampleData).\n",
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
      "SampleData"
    }
    .jst_stop(
      "The formula goes first, then the data - e.g. ",
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
      "Remove them - e.g. ", fn, "(", formula, ", SampleData).",
      fn = fn
    )
  }

  .jst_stop(
    "The first input must be a formula - e.g. ",
    fn, "(", example, ", SampleData).",
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
    .jst_stop("unused input(s): ", paste(bad, collapse = ", "), fn = fn_name)
  }
  invisible(NULL)
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
#'     or a column reference like \code{SampleData$Gender}). The caller
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
#'   }
#'
#' @keywords internal
.jst_resolve_first_arg <- function(data_sub, data_missing, fn_name,
                                   envir         = parent.frame(),
                                   allow_null    = FALSE,
                                   accept_vector = FALSE) {

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

  # -- Try to evaluate the substituted first argument -----------------------
  eval_result <- tryCatch(
    list(value = eval(data_sub, envir = envir), failed = FALSE),
    error = function(e) list(value = NULL, failed = TRUE)
  )

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
                first_arg_sub  = data_sub,
                first_arg_value = eval_result$value))
  }

  # -- Case 5: bare symbol that didn't evaluate (or non-data-frame value
  #            when accept_vector = FALSE). Treat as a variable name. -------
  if (is.null(default_name)) {
    data_str <- paste(deparse(data_sub), collapse = "")
    .jst_stop(
      "'", data_str, "' not found. Did you mean to use it as a variable name?\n",
      "If so, provide the data frame: ", fn_name, "(MyData, ", data_str, ")\n",
      "Or set a default first with juse(MyData), then: ", fn_name, "(", data_str, ")",
    fn = fn_name)
  }
  resolved <- .jst_resolve_data(envir = envir)
  list(mode = "symbol_with_default",
       data = resolved$data, name = resolved$name,
       first_arg_sub = data_sub, first_arg_value = NULL)
}
