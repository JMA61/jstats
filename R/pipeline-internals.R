#<<<FILE: pipeline-internals.R>>>

#' Internal helper: refuse a filter result of the wrong shape
#'
#' A filter must give exactly one TRUE or FALSE (NA allowed) for every row
#' of the data frame it is applied to. Anything else -- a single value,
#' numbers, text, an empty result, or the wrong number of values -- cannot
#' select rows and is refused with a guided error. ALWAYS stops: a
#' wrong-shaped result is deterministic (it fails identically on every
#' call), so there is no warn-and-continue variant (Session 288, decision
#' 1; since Session 330 an evaluation failure stops as well, in
#' \code{.jst_filter_mask()}). Refusing a single value
#' is deliberate: TRUE / FALSE / T / F would mean "keep every row", but a
#' single value is also the shape of \code{mean(Score) > 5}, \code{any(...)}
#' and \code{nrow(...)} inside a filter -- a likely error reaching for a
#' per-row comparison -- and allowing scalars would make that whole family
#' silently keep every row (decision 2). A numeric result is refused for
#' the same reason in the other direction: base R reads a numeric mask as
#' ROW POSITIONS, so \code{subset = Keep01} on a 0/1 column analyzed row 1
#' once per 1 and reported it with a case-processing table that added up
#' (the Session 289 workstation reproduction).
#'
#' Three origins share the check and differ only in wording:
#' \describe{
#'   \item{\code{"set"}}{the set-time dry run in \code{jsubset()}. The user
#'     has just typed the filter, so the fix is a corrected call. A quoted
#'     keyword (\code{"null"}, \code{"off"}, \code{"on"}) is a reset typed
#'     with quotes and gets the unquoted form back.}
#'   \item{\code{"call"}}{the per-call \code{subset =} argument. The fix
#'     names the analysis function that received it.}
#'   \item{\code{"stored"}}{a persistent \code{jsubset()} filter applied at
#'     analysis time. It was accepted when set and has since stopped
#'     matching the data (an object it depends on changed, or the frame
#'     gained or lost rows), and it re-runs on every analysis of that frame
#'     until dealt with -- so the fix is BOTH exits, each naming the frame:
#'     set aside (off, which keeps the text) first, delete (NULL) second.}
#'   \item{\code{"reactivate"}}{the same stored filter checked by
#'     \code{jsubset(d, on)} before it is turned back on (Session 331). The
#'     stored wording, ending on \code{.jst_filter_exits()}'s reactivation
#'     form: the filter is off already, so the message says it stays off and
#'     gives the delete exit alone.}
#'   \item{\code{"status"}}{the same stored filter checked for the status
#'     display (\code{jsubset()} with no arguments, Session 331). Nothing
#'     stops: the finding is handed back through
#'     \code{.jst_filter_status_signal()} as the status line "It cannot be
#'     applied: it has 12 values for 11 rows."}
#' }
#'
#' @param mask The evaluated filter result.
#' @param n_rows Integer. Row count of the data frame the result must match.
#' @param expr The unevaluated filter (a language object). A bare name that
#'   gave numbers builds its own fix (\code{Keep01} -> \code{Keep01 == 1}).
#' @param expr_str Character. The deparsed filter, echoed as the subject of
#'   the message's first line (that echo is what locates the call in a
#'   sourced script, where \code{call. = FALSE} shows no call).
#' @param origin One of \code{"set"}, \code{"call"}, \code{"stored"},
#'   \code{"reactivate"}, \code{"status"}.
#' @param data_name Character. The data frame's name. Required for
#'   \code{"stored"} and \code{"reactivate"} (the exits are built from it);
#'   used by \code{"set"} to
#'   name the frame in the unchanged-filter line and the quoted-keyword fix.
#' @param named_frame Logical. For \code{"set"}: whether the user named the
#'   frame in the call, so the quoted-keyword fix echoes that form.
#' @param prior Logical. For \code{"set"}: an earlier filter exists for the
#'   frame; the message says it is unchanged.
#'
#' @return \code{invisible(NULL)} when the result is well-shaped; otherwise
#'   stops via \code{.jst_stop()}, which supplies the "<fn>(): " prefix
#'   from the call stack (\code{jsubset} at set time, the analysis function
#'   otherwise).
#'
#' @keywords internal
.jst_check_mask_shape <- function(mask, n_rows, expr, expr_str, origin,
                                  data_name = NULL, named_frame = FALSE,
                                  prior = FALSE) {
  origin <- match.arg(origin, c("set", "call", "stored", "reactivate",
                                "status"))

  # -- What did the filter give? --------------------------------------------
  # Order matters: an empty result first (any type), then kind, then count.
  # A single number is "numbers" (kind before count); a single logical is
  # "a single value"; a logical of the wrong length is a count.
  # The parenthetical value is dropped when the expression IS that literal
  # ("null" is text, TRUE is a single value) and kept when it was
  # computed (mean(Age) > 40 is a single value (FALSE)).
  # The lead reads "<typed> is text" / "is numeric" / "is a single value" /
  # "has 3 values for 12 rows" / "has no values at all" -- a plain verb
  # describing what was typed, never "gives", which read as a non sequitur
  # to the FILTER BY user these messages are for (S290, Jeff's review).
  what <- if (length(mask) == 0L) {
    "has no values at all"
  } else if (is.character(mask)) {
    if (is.character(expr)) "is text" else paste0("is text (\"", mask[1L], "\")")
  } else if (!is.logical(mask)) {
    if (is.numeric(mask)) "is numeric" else paste0("is ", class(mask)[1L], " values")
  } else if (length(mask) == 1L) {
    if (is.logical(expr)) "is a single value"
    else paste0("is a single value (", as.character(mask), ")")
  } else if (length(mask) != n_rows) {
    paste0("has ", length(mask), " values for ", n_rows, " rows")
  } else {
    NULL
  }
  if (is.null(what)) return(invisible(NULL))

  bare_name <- if (is.symbol(expr)) as.character(expr) else NULL
  is_count  <- is.logical(mask) && length(mask) > 1L
  keyword   <- if (is.character(mask) && length(mask) == 1L &&
                   tolower(mask[1L]) %in% c("null", "off", "on")) {
    switch(tolower(mask[1L]), null = "NULL", off = "off", on = "on")
  } else {
    NULL
  }

  if (origin == "status") {
    .jst_filter_status_signal(paste0("It cannot be applied: it ", what, "."))
  }
  if (origin %in% c("stored", "reactivate")) {
    .jst_stop(
      "the jsubset filter for the ", data_name, " data frame, ", expr_str,
      ", ", what, ".\n",
      "A filter must give one TRUE or FALSE for every row.\n",
      .jst_filter_exits(data_name, origin)
    )
  }

  if (origin == "call") {
    fn  <- .jst_caller_fn()
    # A bare name (subset = Gender): the SPSS FILTER BY habit. Since S290
    # this is the only route a lone name takes (the syntax check's bare-name
    # branch is gone), and the message names the mistake rather than what
    # the variable holds -- "gives numbers" read as a non sequitur to the
    # user it is for (S290; wording mirrors the single-= syntax error).
    if (!is.null(bare_name) && is.numeric(mask)) {
      .jst_stop(
        "subset = ", bare_name, " on its own is a variable name, ",
        "which does not select rows in R.\n",
        "Use == (two equals signs) to compare it to a value:\n",
        "  subset = ", bare_name, " == 1"
      )
    }
    fix <- paste0("In your ", fn, "() call, compare a variable to a value, ",
                  "for example subset = Age < 40.")
    .jst_stop(
      "subset = ", expr_str, " ", what,
      ", not one TRUE or FALSE for every row.\n",
      fix
    )
  }

  # origin == "set"
  frame_arg <- if (isTRUE(named_frame) && !is.null(data_name)) {
    paste0(data_name, ", ")
  } else {
    ""
  }
  fix <- if (!is.null(keyword)) {
    verb <- switch(keyword, NULL = "clear the filter", off = "turn the filter off",
                   on = "turn the filter back on")
    paste0("To ", verb, ", use ", keyword, " without quotes:\n",
           "  jsubset(", frame_arg, keyword, ")")
  } else if (is_count) {
    paste0("Build the filter from the data frame's own columns, ",
           "for example:\n",
           "  jsubset(Age < 40)")
  } else {
    paste0("Compare a variable to a value, for example:\n",
           "  jsubset(Age < 40)")
  }
  unchanged <- if (isTRUE(prior) && !is.null(data_name)) {
    paste0("\nYour earlier filter for the ", data_name,
           " data frame is unchanged.")
  } else {
    ""
  }
  # A bare name (jsubset(d, Gender)): its own three-line message, mirroring
  # the single-= syntax error -- the mistake, the two equals signs, the
  # corrected call -- with nothing about what the variable holds (S290).
  if (is.null(keyword) && !is.null(bare_name) && is.numeric(mask)) {
    .jst_stop(
      bare_name, " on its own is a variable name, ",
      "which does not select rows in R.\n",
      "Use == (two equals signs) to compare it to a value:\n",
      "  jsubset(", frame_arg, bare_name, " == 1)", unchanged
    )
  }
  .jst_stop(
    expr_str, " ", what, ", not one TRUE or FALSE for every row.\n",
    fix, unchanged
  )
}

#' Internal helper: the closing lines of a stored filter's stop
#'
#' One builder for the way out of every stop a stored \code{jsubset()}
#' filter raises (\code{.jst_check_mask_shape()}, \code{.jst_filter_mask()}),
#' so the forms cannot drift. At analysis time (\code{"stored"}) the filter
#' is active and re-runs on every analysis of its frame, so both exits are
#' given, set aside first. When \code{jsubset(d, on)} refuses to turn a
#' filter back on (\code{"reactivate"}, Session 331) the filter is off
#' already: "set it aside" would name the state it is in, so the message
#' says the filter stays off and gives the delete exit alone.
#'
#' @param data_name Character. The data frame's name.
#' @param origin \code{"stored"} or \code{"reactivate"}.
#' @return A character string: the message's closing lines.
#' @keywords internal
.jst_filter_exits <- function(data_name, origin = c("stored", "reactivate")) {
  origin <- match.arg(origin)
  delete <- paste0("To delete it, run:\n",
                   "  jsubset(", data_name, ", NULL)")
  if (origin == "reactivate") {
    return(paste0("The filter stays off.\n", delete))
  }
  paste0("To set it aside, run:\n",
         "  jsubset(", data_name, ", off)\n",
         delete)
}

#' Internal helper: hand a stored filter's fault back to the status display
#'
#' The status displays (\code{jsubset()} with no arguments) run each stored
#' filter through \code{.jst_filter_mask(origin = "status")} to say whether
#' it can still be applied. A status display must not stop, so where the
#' analysis-time origin would call \code{.jst_stop()} this signals a
#' condition of class \code{jst_filter_unusable} whose message is the status
#' line -- "It cannot be applied: keep12 no longer exists." -- and the
#' display catches exactly that class. Never reaches the user as an error.
#'
#' @param text Character. The status line.
#' @return Does not return.
#' @keywords internal
.jst_filter_status_signal <- function(text) {
  stop(structure(class = c("jst_filter_unusable", "error", "condition"),
                 list(message = text, call = NULL)))
}

#' Internal helper: a workspace vector holding one value per case of the frame
#'
#' Finds, in a filter condition, a workspace vector that holds one value for
#' each case of the data frame AS GIVEN when the condition is about to run
#' on fewer cases: behind an active \code{jcomplete()} (a stored
#' \code{jsubset()} filter), or behind either stored setting (a per-call
#' \code{subset =}). Such a vector lines up with the frame the user sees and
#' with nothing the condition is evaluated on, and until Session 331 only
#' the comparison of one with a labelled variable said so (the Session 330
#' add-it-to-the-frame form, reached when the evaluation fails): compared
#' with a plain variable, or with a constant (\code{keep12 == TRUE}), the
#' result is simply too long, and the shape check answered "has 12 values
#' for 11 rows" for a frame the user had removed nothing from. Asked BEFORE
#' the evaluation, so every such condition gets the one message. The
#' operand is looked up, never run (\code{.jst_recycled_operand()}'s rule);
#' a bare name as the whole condition, which that walker does not visit, is
#' looked up here.
#'
#' @param expr The unevaluated filter.
#' @param data The data the filter is about to be evaluated on.
#' @param envir The environment its other names resolve in.
#' @param n_frame Integer or NULL. The frame's row count as given.
#' @return NULL when the data has not been cut or there is no such vector;
#'   otherwise a \code{.jst_recycled_operand()}-shaped list.
#' @keywords internal
.jst_frame_vector <- function(expr, data, envir, n_frame) {
  if (is.null(n_frame) || n_frame == nrow(data)) return(NULL)
  rec <- if (is.symbol(expr)) {
    if (as.character(expr) %in% names(data)) {
      NULL
    } else {
      val <- tryCatch(eval(expr, envir), error = function(e) NULL)
      if (!is.null(val) && is.atomic(val) && length(val) > 1L) {
        list(term = expr, operand = expr, n = length(val))
      } else {
        NULL
      }
    }
  } else {
    .jst_recycled_operand(list(expr), data, envir)
  }
  if (is.null(rec) || rec$n != n_frame) return(NULL)
  rec
}

#' Internal helper: rows of a frame an active jcomplete() setting keeps
#'
#' The cases Step 1 of \code{.jst_apply_pipeline()} hands to a stored
#' \code{jsubset()} filter: those an ACTIVE \code{jcomplete()} setting
#' keeps, a declared missing value counting as missing (the setting's
#' variables are masked for the test, as \code{jcomplete()}'s own count
#' masks them; the rows returned are the frame's own). Used where a stored
#' filter is checked outside an analysis -- when set, at
#' \code{jsubset(d, on)}, and for the status display (Session 331) -- so
#' the check sees as many cases as the analysis will. Returns the frame
#' untouched when there is no active setting, or when the setting names a
#' variable the frame no longer has (the analysis stops on that first).
#'
#' @param data The data frame.
#' @param data_name Character. Its name, the registry key.
#' @return A data frame.
#' @keywords internal
.jst_complete_kept <- function(data, data_name) {
  cs <- .jst_get_complete(data_name)
  if (is.null(cs) || !isTRUE(cs$active) || length(cs$vars) == 0L ||
      length(setdiff(cs$vars, names(data))) > 0L) {
    return(data)
  }
  masked <- .jst_apply_declared_udms_as_na(
    data[, cs$vars, drop = FALSE])$data
  data[stats::complete.cases(masked), , drop = FALSE]
}

#' Internal helper: the names a filter reads that are found nowhere
#'
#' When a filter's evaluation stops, this says whether the reason is a name
#' that is neither a variable of the data nor an object the caller can see:
#' a misspelled variable when the filter is set, or a variable or workspace
#' object removed since, when a stored filter is applied (Session 330). The
#' names come from \code{.jst_expr_symbols()}, so a function's name, the
#' component after a dollar sign and the body of an inline function are not
#' candidates. R's own message is consulted for one thing only: at least one
#' candidate must appear in it between quotation marks -- any character that
#' is not a space and could not be part of a name. R names the first missing
#' object that way in every language it is translated into, so the test does
#' not depend on the wording, and it keeps the claim true when the
#' evaluation stopped for another reason while a name that was never looked
#' up (inside \code{with()}, say) happens to be unbound. Requiring the marks
#' keeps a one-letter name from matching a word of the message.
#'
#' @param expr The unevaluated filter.
#' @param data The data frame it was evaluated against.
#' @param envir The environment its other names resolve in.
#' @param r_msg Character; R's message from the failed evaluation.
#' @return Character vector of the names found nowhere, in the order typed;
#'   empty when the failure is not a missing name.
#' @keywords internal
.jst_filter_unbound <- function(expr, data, envir, r_msg) {
  nms <- setdiff(.jst_expr_symbols(expr), names(data))
  nms <- nms[!vapply(nms, exists, logical(1), envir = envir,
                     USE.NAMES = FALSE)]
  if (length(nms) == 0L) return(character(0))
  mark   <- function(ch) nzchar(ch) && !grepl("[[:alnum:][:space:]._]", ch)
  quoted <- function(nm) {
    at <- gregexpr(nm, r_msg, fixed = TRUE)[[1L]]
    if (at[1L] < 0L) return(FALSE)
    any(vapply(at, function(p) {
      mark(substr(r_msg, p - 1L, p - 1L)) &&
        mark(substr(r_msg, p + nchar(nm), p + nchar(nm)))
    }, logical(1)))
  }
  if (!any(vapply(nms, quoted, logical(1), USE.NAMES = FALSE))) {
    return(character(0))
  }
  nms
}

#' Internal helper: evaluate a filter and refuse one that cannot select rows
#'
#' The one place a user's filter is run: \code{jsubset()}'s set-time dry run
#' (origin \code{"set"}), a per-call \code{subset =} (\code{"call"}) and a
#' stored \code{jsubset()} filter applied at analysis time (\code{"stored"}),
#' the last two through \code{.jst_apply_mask()}. Every failure STOPS
#' (Session 330). Until then an evaluation failure was swallowed at set time
#' -- \code{jsubset(d, Agee > 30)} reported "activated" -- and warned at
#' analysis time, after which the analysis ran on every row with a Case
#' Processing row reading "jsubset()  0": ordinary-looking output for the
#' wrong sample, identically on every call. In order:
#' \enumerate{
#'   \item The evaluation. On an error: a workspace vector the condition
#'     would recycle (\code{.jst_recycled_operand()}; a labelled variable
#'     refuses the comparison where a plain one recycles), then a name
#'     found nowhere (\code{.jst_filter_unbound()}), then any other reason,
#'     which relays R's message and claims nothing more. Warnings from the
#'     evaluation are held rather than caught -- a handler that caught them
#'     would abandon the evaluation and skip the checks below -- and are
#'     given back only when the filter passes, so R's "longer object
#'     length" warning never prints ahead of the stop that explains it. At
#'     set time they are dropped, with any message, as they always were.
#'   \item The shape of the result (\code{.jst_check_mask_shape()}). It
#'     comes before the recycling check so that a filter built from a
#'     workspace object alone (\code{keep3 == TRUE}, three values for
#'     twelve rows) keeps the shape error and its fix.
#'   \item A workspace vector recycled against the data, which leaves a
#'     result of the right shape: silently when the row count divides by
#'     its length.
#' }
#' The three origins differ in wording only. What was typed in this call is
#' the subject of its message (Rule AD): the condition at set time, with the
#' "earlier filter is unchanged" line when there is one; \code{subset = } and
#' the condition per call. A stored filter was accepted when set, so its
#' message names the frame and the filter, says it "cannot be applied", and
#' ends on both exits -- set aside (\code{off}), delete (\code{NULL}) -- as
#' the stored shape error does: it re-runs on every analysis of that frame
#' until dealt with. A name found nowhere "was not found" at set time and
#' "no longer exists" for a stored filter, which the set-time check makes
#' true. The per-call evaluation message is the one it has always been.
#'
#' A fourth origin, \code{"reactivate"} (Session 331), is the stored filter
#' checked by \code{jsubset(d, on)} before it is turned back on. Until then
#' \code{on} set the filter active unchecked: "jsubset reactivated" printed
#' for a filter that could no longer run, and the next analysis stopped. It
#' takes the stored wording with \code{.jst_filter_exits()}'s reactivation
#' close ("The filter stays off." and the delete exit), and, as at set time,
#' nothing is analyzed, so warnings and messages from the filter are dropped
#' (\code{quiet = TRUE}).
#' A fifth, \code{"status"}, is the same check made for the status display:
#' it never stops, and hands the reason back as the line "It cannot be
#' applied: ..." (\code{.jst_filter_status_signal()}).
#'
#' Ahead of the evaluation, for every origin but \code{"set"}: a workspace
#' vector holding one value per case of the frame as given, where the
#' condition is about to run on fewer cases (\code{.jst_frame_vector()},
#' Session 331) -- the add-it-to-the-frame fix. At set time the same test
#' runs last, against \code{data_kept}.
#'
#' @param expr The unevaluated filter (a language object).
#' @param expr_str Character. The filter as typed.
#' @param data Data frame to evaluate it against.
#' @param envir Environment the filter's other names resolve in.
#' @param origin One of \code{"set"}, \code{"call"}, \code{"stored"},
#'   \code{"reactivate"}, \code{"status"}.
#' @param data_name Character. The data frame's name.
#' @param named_frame Logical. For \code{"set"}: the user named the frame in
#'   the call; when FALSE the not-found message adds the juse() default
#'   hint \code{.jst_check_vars()} gives.
#' @param prior Logical. For \code{"set"}: an earlier filter exists for the
#'   frame; the message says it is unchanged.
#' @param n_frame Integer or NULL. The frame's row count before the
#'   pipeline's filters: it tells the recycling stop's two forms apart
#'   (\code{"call"}), and lets a vector holding one value per case of the
#'   frame as given be recognized when \code{data} has fewer cases
#'   (\code{.jst_frame_vector()}; every origin but \code{"set"}).
#' @param data_kept Data frame or NULL. For \code{"set"}: the frame as an
#'   active \code{jcomplete()} will hand it to the filter
#'   (\code{.jst_complete_kept()}); the same test, made once the filter has
#'   passed on the frame as given.
#' @param quiet Logical or NULL. Whether the filter's own warnings and
#'   messages are dropped; NULL drops them at set time and for the status
#'   display. \code{jsubset(d, on)} passes TRUE, for a filter that was off
#'   (\code{"reactivate"}) and for one that was never off
#'   (\code{"stored"}).
#'
#' @return The evaluated filter: one TRUE, FALSE or NA for every row.
#'
#' @keywords internal
.jst_filter_mask <- function(expr, expr_str, data, envir,
                             origin = c("set", "call", "stored",
                                        "reactivate", "status"),
                             data_name = NULL, named_frame = FALSE,
                             prior = FALSE, n_frame = NULL,
                             data_kept = NULL, quiet = NULL) {
  origin <- match.arg(origin)
  n_rows <- nrow(data)
  # A stored filter -- at analysis time, at jsubset(d, on), or for the
  # status display -- has one wording and three closes: both exits, "stays
  # off" and the delete exit (.jst_filter_exits), or none (the status line).
  # Nothing is analyzed at set time or for the status display, so there
  # the filter's own warnings and messages are dropped; jsubset(d, on)
  # asks for the same (quiet = TRUE), whichever stored form it uses.
  is_stored <- origin %in% c("stored", "reactivate", "status")
  is_quiet  <- if (is.null(quiet)) {
    origin %in% c("set", "status")
  } else {
    isTRUE(quiet)
  }
  unchanged <- if (origin == "set" && isTRUE(prior) && !is.null(data_name)) {
    paste0("\nYour earlier filter for the ", data_name,
           " data frame is unchanged.")
  } else {
    ""
  }
  stored_lead <- function() {
    paste0("the jsubset filter for the ", data_name, " data frame, ",
           expr_str, ", cannot be applied")
  }
  # The stored family's stop: the lead, the reason after a colon (or none),
  # any further lines, and the close. For the status display the same
  # reason is handed back as a line of text, with no lead and no close.
  stored_stop <- function(reason = NULL, detail = NULL,
                          close = .jst_filter_exits(data_name, origin)) {
    body <- paste0(if (!is.null(reason)) paste0(": ", reason), ".",
                   if (!is.null(detail)) paste0("\n", detail))
    if (origin == "status") {
      .jst_filter_status_signal(paste0("It cannot be applied", body))
    }
    .jst_stop(stored_lead(), body, "\n", close)
  }
  typed <- if (origin == "call") paste0("subset = ", expr_str) else expr_str
  # A workspace vector with one value per case of the frame as given, where
  # the condition runs on fewer cases (S331): the add-it-to-the-frame fix.
  frame_vector <- function(cut_data = data, n_given = n_frame) {
    rec <- .jst_frame_vector(expr, cut_data, envir, n_given)
    if (is.null(rec)) return(invisible(NULL))
    cut_by <- if (origin == "call") "filtering" else "jcomplete()"
    if (is_stored) {
      parts <- .jst_frame_vector_parts(rec, nrow(cut_data), data_name, cut_by)
      if (origin == "status") {
        .jst_filter_status_signal(paste0("It cannot be applied: ",
                                         parts$reason, "."))
      }
      .jst_stop(stored_lead(), ": ", parts$reason, ".\n",
                if (origin == "reactivate") "The filter stays off.\n",
                parts$fix)
    }
    .jst_recycled_stop(rec, typed, nrow(cut_data), data_name,
                       n_frame = n_given, tail = unchanged, cut_by = cut_by)
  }
  recycled <- function() {
    rec <- .jst_recycled_operand(list(expr), data, envir)
    if (is.null(rec)) return(invisible(NULL))
    if (is_stored) {
      # "cases" always: with one case left a longer vector gives a longer
      # result, and the shape check answers before this is reached.
      stored_stop(paste0(.jst_term_text(rec$operand), " has ", rec$n,
                         " values for ", n_rows, " cases"))
    }
    .jst_recycled_stop(rec, typed, n_rows, data_name,
                       n_frame = if (origin == "call") n_frame else NULL,
                       tail = unchanged)
  }

  frame_vector()
  held <- list()
  mask <- tryCatch(
    withCallingHandlers(
      eval(expr, data, envir),
      warning = function(w) {
        held[[length(held) + 1L]] <<- w
        invokeRestart("muffleWarning")
      },
      message = function(m) {
        if (is_quiet) invokeRestart("muffleMessage")
      }),
    error = function(e) {
      recycled()
      if (origin == "call") {
        .jst_stop("Subset expression could not be evaluated: ",
                  conditionMessage(e))
      }
      # R's message on one line, without the color codes a package may add.
      r_msg <- gsub("\033\\[[0-9;]*m", "", conditionMessage(e))
      r_msg <- gsub("[[:space:]]+", " ", trimws(r_msg))
      gone  <- .jst_filter_unbound(expr, data, envir, r_msg)
      names_gone <- .jst_format_var_list(gone, and = TRUE)
      if (is_stored) {
        if (length(gone) > 0L) {
          stored_stop(paste0(names_gone,
                             if (length(gone) == 1L) " no longer exists"
                             else " no longer exist"))
        }
        stored_stop(detail = paste0("R reported:\n  ", r_msg))
      }
      # origin == "set"
      if (length(gone) > 0L) {
        hint <- if (!isTRUE(named_frame) && !is.null(data_name)) {
          paste0("\n", data_name, " is the juse() default -- if you meant ",
                 "a different data frame, name it in the call.")
        } else {
          ""
        }
        .jst_stop(expr_str, " names ", names_gone,
                  if (length(gone) == 1L) ", which was not found in the "
                  else ", which were not found in the ",
                  data_name, " data frame.\n",
                  "Check the spelling.", hint, unchanged)
      }
      .jst_stop(expr_str, " cannot be applied to the ", data_name,
                " data frame.\n",
                "R reported:\n",
                "  ", r_msg, unchanged)
    }
  )
  .jst_check_mask_shape(mask, n_rows, expr, expr_str, origin,
                        data_name   = data_name,
                        named_frame = named_frame,
                        prior       = prior)
  recycled()
  # When set, the filter passed on the frame as given; an active
  # jcomplete() will hand it fewer cases at every analysis (S331).
  if (origin == "set" && !is.null(data_kept)) {
    frame_vector(data_kept, n_rows)
  }
  if (!is_quiet) for (w in held) warning(w)
  mask
}

#' Internal helper: stop for a jcomplete setting naming absent variables
#'
#' A stored \code{jcomplete()} setting can outlive its variables: one
#' dropped or renamed after the setting was made, or the frame's name
#' reassigned to a frame without it. This is the one stop for that
#' condition, raised wherever the setting is about to be used: Step 1 of
#' \code{.jst_apply_pipeline()} (every analysis of the frame, since
#' Session 330), and since Session 331 \code{jcomplete(d, on)} and the
#' preview of an already-set filter (\code{jcomplete(preview = TRUE)},
#' \code{console =}), which until then reactivated the setting unchecked
#' and previewed the rows the REMAINING variables would drop. Does nothing
#' when no variable is absent. At reactivation the setting is off, and the
#' message says it stays off.
#'
#' @param data_name Character. The data frame's name.
#' @param gone_vars Character vector: the setting's variables the frame no
#'   longer has (empty: return without stopping).
#' @param reactivate Logical. TRUE from \code{jcomplete(d, on)}: adds
#'   "The setting stays off." after the first line.
#' @return \code{invisible(NULL)} when \code{gone_vars} is empty; otherwise
#'   stops via \code{.jst_stop()}.
#' @keywords internal
.jst_complete_gone_stop <- function(data_name, gone_vars, reactivate = FALSE) {
  if (length(gone_vars) == 0L) return(invisible(NULL))
  .jst_stop(
    "the jcomplete setting for the ", data_name, " data frame names ",
    .jst_format_var_list(gone_vars, and = TRUE),
    ", which the data frame no longer has.\n",
    if (isTRUE(reactivate)) "The setting stays off.\n",
    "Run jcomplete() again with the current variable names, or clear ",
    "the setting:\n",
    "  jcomplete(", data_name, ", NULL)"
  )
}

#' Internal helper: apply a logical mask expression to a data frame
#'
#' Shared mechanic for Step 2 (persistent jsubset) and Step 3 (per-call
#' \code{subset =} argument) of \code{.jst_apply_pipeline()}. Runs
#' \code{expr} through \code{.jst_filter_mask()} -- which evaluates it in
#' the data + caller environment and stops on anything that cannot select
#' rows -- coerces \code{NA}s in the mask to \code{FALSE}, and returns the
#' filtered data frame. The two callers differ in upstream source (joptions
#' state vs. argument) and downstream bookkeeping (which \code{sample_info}
#' slot is populated); the masking step itself is identical. This is the
#' package's single row-selection site for user filters (Session 288 scan).
#' Until Session 330 it took \code{on_error} and \code{stage_label}: a
#' stored filter whose evaluation failed warned and kept every row. Both
#' origins stop now, so both arguments are gone.
#'
#' @param data Data frame to mask.
#' @param expr Unevaluated logical expression (a language object).
#' @param envir Environment to evaluate \code{expr} in. Data columns
#'   take precedence; \code{envir} provides fallback bindings.
#' @param origin One of \code{"stored"} or \code{"call"}; selects the
#'   wording of every refusal.
#' @param expr_str Character. The deparsed expression, echoed in the
#'   refusals.
#' @param data_name Character. The data frame's name; the stored-filter
#'   errors build their exits from it.
#' @param n_frame Integer or NULL. The frame's row count before the
#'   pipeline's filters: for the per-call recycling stop, and (both
#'   origins, Session 331) for a vector holding one value per case of the
#'   frame as given.
#'
#' @return The data frame filtered to rows where \code{expr} evaluates
#'   to \code{TRUE} (\code{NA} treated as \code{FALSE}).
#'
#' @keywords internal
.jst_apply_mask <- function(data, expr, envir, origin, expr_str,
                            data_name = NULL, n_frame = NULL) {
  origin <- match.arg(origin, c("stored", "call"))
  mask <- .jst_filter_mask(expr, expr_str, data, envir, origin,
                           data_name = data_name, n_frame = n_frame)
  # A case whose condition evaluates to NA is dropped, as R's subset() does.
  # The count is taken here, before the NA-to-FALSE line erases it, and
  # handed back on the result as the "jst_mask_na" attribute for the Case
  # Processing Summary's "(k missing)" annotation on the filter row (S312);
  # the pipeline reads it off and strips it. Because the pipeline evaluates
  # the condition on the analysis copy, a declared missing-value code counts
  # here too, and an expression that keeps missing cases on purpose
  # (x > 5 | is.na(x)) counts nothing.
  n_na <- sum(is.na(mask))
  mask[is.na(mask)] <- FALSE
  # Variable-label loss from `[.data.frame` row subsetting (plain atomic and
  # factor columns lose their label; haven_labelled keep theirs) is restored
  # once at the end of .jst_apply_pipeline, from the pre-pipeline snapshot, which
  # covers this path plus jcomplete's direct subset uniformly.
  out <- data[mask, , drop = FALSE]
  attr(out, "jst_mask_na") <- as.integer(n_na)
  out
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
#' until explicitly turned off via jsubset(off) / jcomplete(off) on the
#' default dataset, or jsubset(d, off) on a named one.
#'
#' When the current dataset has no jsubset / jcomplete set but at least one
#' other dataset does have an active setting, a yellow-colored note is
#' included in the pipeline messages to remind the user that case selection
#' is not active for this particular dataset.
#'
#' Ahead of all three steps, a zero-row input frame stops the call. The count
#' is read before step 1, so the guard fires only when the frame ARRIVED
#' empty; a filter that empties a non-empty frame is a different condition and
#' is left alone, because there the Case Processing Summary prints with a
#' Remaining N of 0 and the counts below it are informative. The guard lives
#' here rather than in each caller so that all thirteen call sites (nine
#' analysis functions, with jdesc entering twice, plus jscreen and the two
#' jplot paths) raise one consistent error; the emitter names the user-facing
#' function from the call stack, so no caller passes one in. Decided
#' Session 287, added Session 295.
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

  # -- Zero-row input frame (Session 295) ------------------------------------
  # Read before step 1, so this fires only when the frame ARRIVED empty. A
  # filter that empties a non-empty frame passes through here and is handled
  # by the steps below: there the Case Processing Summary prints with a
  # Remaining N of 0, and the zeros beneath it are informative.
  #
  # Without the guard the callers split three ways on one condition: jt,
  # jaov, jcrosstab, jlm and jlogistic stop late with a pipeline-flavored
  # message; jfreq, jdesc, jcorr and jalpha render something useless (a table
  # of zeros ending "Total 0 100.00", a descriptives header with no rows, a
  # NaN alpha); and jplot hands ggplot an empty frame. Decided S287 for
  # consistency across the ten, extended at S295 to the two jplot paths,
  # which enter through this same helper.
  #
  # Rule T (S227): a frame takes an article and its kind noun rather than a
  # bare lowercase name at the head of a sentence, and the same sentence then
  # serves the unnamed-frame case unchanged. No fn = is passed -- .jst_stop()
  # walks sys.calls() outermost-first for the first ^j[a-z] name, which is
  # the user-facing function (jt, jplot, ...), not this helper.
  if (n_original == 0L) {
    frame_ref <- if (!is.null(data_name) && nzchar(data_name)) {
      paste0("the ", data_name, " data frame")
    } else {
      "the data frame"
    }
    .jst_stop(frame_ref, " has no rows, so there is nothing to analyze.")
  }

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
  filter_na_n      <- NULL
  subset_na_n      <- NULL
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
      # A stored setting can outlive its variables: one dropped or renamed
      # after jcomplete() was set, or the name reassigned to a frame without
      # it. Until S318 Step 1 kept the names still present and skipped the
      # rest without a word; from S318 it warned, and applied the rest. It
      # STOPS since S330 (Jeff's ruling, with the stored jsubset() below):
      # the warning repeated identically on every call and was scrolled
      # past, while the analysis ran on cases the setting was meant to
      # remove.
      .jst_complete_gone_stop(data_name, setdiff(cs$vars, names(data)))
      complete_vars <- cs$vars
      if (length(complete_vars) > 0) {
        complete_mask    <- stats::complete.cases(data[, complete_vars, drop = FALSE])
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
                                         origin    = "stored",
                                         expr_str  = fs$expr_str,
                                         data_name = data_name,
                                         n_frame   = n_original)
      filter_na_n     <- attr(data, "jst_mask_na", exact = TRUE)
      attr(data, "jst_mask_na") <- NULL
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
    # The same syntax check jsubset() runs at set time, in its per-call
    # form (S290). Before it, subset = NOT(...) died as R's "could not
    # find function", and subset = (Gender = 1) & (Age < 40) RAN, as
    # 1 & (Age < 40), with the Gender test silently dropped. The shape of
    # what the expression produces is the mask helper's job, below.
    .jst_check_filter_syntax(subset_expr, subset_expr_str, origin = "call")
    # A data frame named in the condition (subset = d$Income < 45) would be
    # read from the user's raw frame, where declared missing values are
    # numbers: refused, with the variables on their own (Session 323).
    .jst_check_condition_frames(subset_expr, subset_expr_str, data, envir,
                                origin = "call", data_name = data_name)
    data           <- .jst_apply_mask(data, subset_expr, envir,
                                      origin    = "call",
                                      expr_str  = subset_expr_str,
                                      data_name = data_name,
                                      n_frame   = n_original)
    subset_na_n    <- attr(data, "jst_mask_na", exact = TRUE)
    attr(data, "jst_mask_na") <- NULL
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
    # Cases each filter step dropped because its condition evaluated to NA
    # (S312): the "(k missing)" annotation on the jsubset() and subset = rows
    # of the Case Processing Summary. NULL when the step did not run.
    filter_na        = filter_na_n,
    subset_na        = subset_na_n,
    # SPSS-form UDM masking activity from Step 0. udm_spss_active = TRUE
    # when at least one variable had declared SPSS-form codes/ranges masked
    # on the analysis copy; udm_spss_masked_vars carries the per-variable
    # detail (entries + n_cells) as a record of what Step 0 masked. These
    # are FULL-frame counts taken before any row filter ran, so they are
    # NOT a display count source: jfreq's Missing section read `entries`
    # until S285 and reported pre-filter counts against a post-filter
    # Total (S217); it now counts off pre_pipeline_data[surviving_ids]
    # below, as the CPS bottom always has. SPSS-only is deliberate:
    # Stata/SAS tag zapping is count-neutral and records nothing (see the
    # helper's banner).
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
#' @param by_var Character scalar, or NULL (the default): the grouping
#'   variable of a jdesc(by =) call (Session 316, AUDIT-027). When set,
#'   \code{n_analysis} is the count of cases that have a group, so
#'   \code{n_excluded_missing} is the count missing on the grouping
#'   variable; the Case Processing Summary renders it as the by = row and
#'   leaves the variable out of the N line's variable count.
#'
#' @return A list with elements: n_original, n_after_complete, n_after_filter,
#'   n_after_subset, n_analysis, n_excluded_missing, missing_by_var,
#'   complete_active, filter_active, filter_expr, by_var (and the rest of
#'   the pipeline counts).
#'
#' @keywords internal
.jst_build_sample_info <- function(pipeline_counts, data, analysis_vars,
                                   n_analysis, transform_na = NULL,
                                   by_var = NULL) {

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
    filter_na          = pipeline_counts$filter_na,
    subset_na          = pipeline_counts$subset_na,
    udm_spss_active         = pipeline_counts$udm_spss_active,
    udm_spss_masked_vars    = pipeline_counts$udm_spss_masked_vars,
    pre_pipeline_data  = pipeline_counts$pre_pipeline_data,
    surviving_ids      = pipeline_counts$surviving_ids,
    transform_na       = transform_na,
    by_var             = by_var
  )
}

# Output level preset defaults (used by .jst_resolve_toggle and joutput)
#
# case.processing supports three states (the three CPS MODES, S284):
#   FALSE - never print the CPS table: the one-line N statement only
#   TRUE  - always print the table, even when its only rows are Original
#           and the endpoint
#   NULL  - "auto": the table prints only when it has an exclusion row (a
#           pipeline step active, or listwise deletion excluded at least
#           one case); otherwise the N line takes its slot. Rules in
#           JStats_CPS_Rendering_Reference.txt.
#
# case.processing.filter (S312) governs the breakdown's jcomplete()-ONLY
# rows -- variables in jcomplete()'s list that the analysis never uses:
#   "list"     - one row per jcomplete()-only variable with missingness
#   "collapse" - one "jcomplete()-only variables (k)" row for two or more
#   "auto"     - named up to .jst_cps_filter_named_max, collapsed beyond
# A lone jcomplete()-only variable is always named. A jsubset() / subset =
# variable is accounted for on its own row's "(k missing)" annotation.
#
# missing.notice supports three states. Standard and full both use TRUE (always
# show); minimal uses FALSE. The NULL/auto state is retained internally but
# no preset level selects it and joutput() cannot set it, so the narrative
# now shows on every UDM-bearing load unless minimal output is active:
#   FALSE - never print the UDM narrative on jload
#   TRUE  - always print the narrative (every load with UDM-bearing variables)
#   NULL  - "auto": print once per session, then suppress (tracked via the
#           .jst_missing_notice_shown option); no preset level uses this
.jst_output_defaults <- list(
  minimal  = list(effect.size = FALSE,
                  regression.ci = FALSE, means.ci = FALSE, levene = FALSE,
                  posthoc = FALSE, diagnostics = FALSE,
                  case.processing = FALSE, case.processing.detail = "none",
                  case.processing.filter = "collapse",
                  variable.id = "names", value.id = "labels",
                  ref.categories = FALSE, digits = 3,
                  missing.notice = FALSE),
  standard = list(effect.size = TRUE,
                  regression.ci = FALSE, means.ci = TRUE,  levene = FALSE,
                  posthoc = FALSE, diagnostics = FALSE,
                  case.processing = NULL,  case.processing.detail = "totals",
                  case.processing.filter = "auto",
                  variable.id = "names", value.id = "both",
                  ref.categories = TRUE, digits = 3,
                  missing.notice = TRUE),
  full     = list(effect.size = TRUE,
                  regression.ci = TRUE,  means.ci = TRUE,  levene = TRUE,
                  posthoc = TRUE,  diagnostics = TRUE,
                  case.processing = TRUE,  case.processing.detail = "per_code",
                  case.processing.filter = "list",
                  variable.id = "legend", value.id = "both",
                  ref.categories = TRUE, digits = 3,
                  missing.notice = TRUE)
)

# -- joptions defaults --------------------------------------------------------
#
# Single source of truth for joptions slot defaults. Consulted both by
# joptions itself for reset semantics and by downstream readers (jload,
# jconvert, jdeclare_missing, jrecode) via getOption() fallback when no
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
#   missing.convention.codes - numeric vector, length 1-3, whole numbers,
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
  missing.convention.codes = c(-99, -98, -97),
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
#' point. NA formats to the empty string so it renders as a blank cell. A
#' value that rounds to zero from below prints unsigned ("0.000", not
#' "-0.000"), the rule the jlm and jlogistic coefficient formatters and
#' jcorr's r cells already follow.
#'
#' Since Session 326 this is the formatter behind the \code{digits} argument
#' of \code{.jst_print_table()} (every column a caller fixes) and behind
#' \code{.jst_fmt_stat()} (the effect-size result lines).
#'
#' @param digits Integer number of decimal places (0-7).
#'
#' @return A function of one argument (coerced via as.numeric) returning a
#'   character vector the same length as its input.
#'
#' @keywords internal
.jst_make_fmt <- function(digits) {
  spec <- paste0("%.", digits, "f")
  function(x) {
    x <- suppressWarnings(as.numeric(x))
    if (length(x) == 0L) return(character(0))
    s <- sprintf(spec, x)
    # A value that rounds to zero from below prints unsigned: "-0.000" reads
    # as an error. (Session 326)
    s <- ifelse(startsWith(s, "-") & !grepl("[1-9]", s), sub("^-", "", s), s)
    ifelse(is.na(x), "", s)
  }
}

#' Internal helper: format one statistic for a result line
#'
#' Formats a single statistic printed on a line of its own rather than in a
#' table -- jaov's "Eta-squared:" line and jt's "Cohen's d:" line, and since
#' Session 327 the numbers three notes print (the smallest expected
#' frequency in jcrosstab's note; the VIF and the inflation factor in the
#' collinearity notes of jlm and jlogistic) -- to exactly \code{digits}
#' decimal places, trailing zeros kept (0.100, not 0.1). The value is
#' rounded with \code{round()} first, so a result line shows the number it
#' showed before Session 326, now padded. A value that rounds to zero from
#' below prints unsigned. A non-finite value (NaN from a zero total sum of
#' squares, say) prints as R prints it, never as a blank.
#'
#' @param x A single numeric value.
#' @param digits Integer number of decimal places (0-7).
#'
#' @return A character string.
#'
#' @keywords internal
.jst_fmt_stat <- function(x, digits) {
  if (length(x) != 1L || !is.finite(x)) return(as.character(x))
  .jst_make_fmt(digits)(round(x, digits))
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
    decl_line <- paste0("  jdeclare_missing(", data_name, ", ", vars_txt,
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
  # S267: descriptors are two pre-broken .jst_wrap_indent lines each, with
  # "base R" anchored at a line edge. Rationale: the wrapper can sever the
  # locked term "base R" mid-phrase (short_tail rescues only sub-10-col or
  # single-word tails), and these lines are the migrant's first contact.
  # The pair below is sever-swept clean across widths 40-120.
  parts <- c(
    "Choose one for this session:",
    "  joptions(missing.convention = \"stata\")",
    paste0(
      .jst_wrap_indent("Lowercase markers behave as true NAs in base R.",
                       indent = 6L), "\n",
      .jst_wrap_indent(paste0("Recommended if you also run base R or ",
                              "AI-generated code."), indent = 6L)))
  if (identical(variant, "menu")) {
    parts <- c(parts,
      # S250 (Rule H): ", as in SPSS" dropped -- the option line above
      # already names the convention, so the clause echoed a fact two
      # characters old.
      "  joptions(missing.convention = \"spss\")",
      paste0(
        .jst_wrap_indent(paste0("Codes stay visible numbers; jstats ",
                                "treats them as missing."), indent = 6L),
        "\n",
        .jst_wrap_indent("Base R does not.", indent = 6L)))
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
#'   \item If the \code{missing.convention} setting in \code{\link{joptions}}
#'     is \code{"spss"}, \code{"stata"}, or \code{"sas"}, use that.
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
#'   returns this value immediately. \code{jdeclare_missing()} populates
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
#'   spelling in the user's call (e.g. \code{".a"}), echoed in the
#'   gate's head AS THE USER TYPED IT -- callers build it from the
#'   parsers' tagged_raw record, not the normalized lowercase letter
#'   (S283; a typed \code{.A} was echoed as \code{'.a'} before).
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
                    if (identical(fn, "jdeclare_missing")) "declared."
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
#' jdeclare_missing) adopt it at their parity-worklist touches; until
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
# resolution -- the jdeclare_missing plain-column token refusal and the
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
#' jdeclare_missing's post-declaration mismatch notice so the two render
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
#' Canonical source = JStats_CPS_Rendering_Reference.txt Tables 1-4. Per the
#' locked lockstep commitment, any change to a rule here updates BOTH that
#' reference file and this data frame in the same session. "any" is a
#' wildcard; matching is first-match top-to-bottom, so reference rows whose
#' value is "-" (not evaluated) are encoded as "any" with ordering preserved.
#'
#' Table 1 (S284 redesign): the upper table is gated by whether it would
#' carry an EXCLUSION ROW -- a pipeline row (jcomplete / jsubset / subset =,
#' shown even at 0 excluded), a nonzero Auto-listwise row, or (Session 316)
#' a nonzero by = row -- under the resolved MODE (never / auto / always).
#' Missingness no longer enters this gate; it feeds the bottom breakdown
#' only (Table 3). When the table does not print, a one-line N statement
#' takes its slot.
#'
#' Table 2's by_row column (Session 316, AUDIT-027): the per-variable
#' descriptives layout is the only one whose analysis can exclude cases
#' AFTER the pipeline without listwise deletion -- jdesc(by =) describes
#' the cases that have a group, so a case missing on the grouping variable
#' is in no table. That exclusion is the layout's counterpart of the
#' listwise layout's Auto-listwise row: eligible on per_var_desc only,
#' shown when nonzero (rule 2), and an exclusion row for Table 1.
#'
#' Table 2's fifth layout, "screening" (Session 320), is jscreen(). It has
#' no bottom (jscreen's own Missing Data table is its breakdown), the
#' Remaining N endpoint, and neither an Auto-listwise nor a by = row, so
#' only a pipeline row can give it an exclusion row. Its N-line family,
#' "header", has the one form "none" (Table 4): in the N-line state the
#' block prints nothing -- not even its closing blank -- because jscreen's
#' header already opens with a Cases line, and the printer hands the
#' excluded count back to the caller for that line instead.
#'
#' @keywords internal
.jst_cps_visibility_rules <- data.frame(
  mode          = c("never", "auto", "auto", "always"),
  exclusion_row = c("any",   "no",   "yes",  "any"),
  table         = c(FALSE,   FALSE,  TRUE,   TRUE),
  n_line        = c(TRUE,    TRUE,   FALSE,  FALSE),
  stringsAsFactors = FALSE
)

#' @keywords internal
.jst_cps_layout_rules <- data.frame(
  layout         = c("listwise", "pairwise", "per_var_desc", "per_var_freq",
                     "screening"),
  bottom_default = c("on",       "on",       "on",           "off",
                     "off"),
  endpoint_label = c("Analysis N", "Remaining N", "Remaining N", "Remaining N",
                     "Remaining N"),
  auto_listwise  = c("eligible", "never",    "never",        "never",
                     "never"),
  by_row         = c("never",    "never",    "eligible",     "never",
                     "never"),
  n_line_family  = c("analysis", "pool",     "pool",         "pool",
                     "header"),
  stringsAsFactors = FALSE
)

#' @keywords internal
.jst_cps_bottom_rules <- data.frame(
  layout    = c(rep("listwise", 7), rep("pairwise", 7),
                rep("per_var_desc", 5), "per_var_freq", "screening"),
  has_udms  = c("no","no","no","no","yes","yes","yes",
                "no","no","no","no","yes","yes","yes",
                "no","no","yes","yes","yes",
                "any",
                "any"),
  has_sysna = c("no","yes","yes","yes","any","any","any",
                "no","yes","yes","yes","any","any","any",
                "no","yes","any","any","any",
                "any",
                "any"),
  tier      = c("any","none","totals","per_code","none","totals","per_code",
                "any","none","totals","per_code","none","totals","per_code",
                "any","any","none","totals","per_code",
                "any",
                "any"),
  bottom        = c(FALSE,FALSE,TRUE,TRUE,FALSE,TRUE,TRUE,
                    FALSE,FALSE,TRUE,TRUE,FALSE,TRUE,TRUE,
                    FALSE,FALSE,FALSE,FALSE,TRUE,
                    FALSE,
                    FALSE),
  resolved_tier = c(NA,NA,"totals","totals",NA,"totals","per_code",
                    NA,NA,"totals","totals",NA,"totals","per_code",
                    NA,NA,NA,NA,"per_code",
                    NA,
                    NA),
  stringsAsFactors = FALSE
)

#' Table 4 (S284): which FORM the one-line N statement takes. Chosen by the
#' layout's n_line_family and, for the pool family, whether the analysis
#' variables' per-variable Ns differ. The excluded-count rider (appended
#' whenever cases were excluded before the analysis) is orthogonal to the
#' form and is applied by the renderer, not encoded here. The header family
#' (Session 320, the screening layout) has the one form "none": the
#' caller's own header states the N, so the renderer prints no line and
#' returns the rider's count to the caller instead.
#' @keywords internal
.jst_cps_n_line_rules <- data.frame(
  family     = c("analysis", "pool", "pool",          "header"),
  unequal_ns = c("any",      "no",   "yes",           "any"),
  form       = c("analysis", "pool", "pool_complete", "none"),
  stringsAsFactors = FALSE
)

# jcomplete()-only rows in the bottom breakdown (Session 312): under the
# case.processing.filter slot's "auto" setting, jcomplete()-only variables
# with missingness are named one per row up to this many; from the next one
# on they collapse into a single "jcomplete()-only variables (k)" row. A
# render refinement noted under Table 3 in the reference, not a rule-frame
# row. The jcomplete() detail column's cap (2 names, then "+N more") is the
# nearest precedent.
.jst_cps_filter_named_max <- 3L
