#<<<FILE: pipeline.R>>>


# =============================================================================
#  USER-FACING SETUP
# =============================================================================

# -- juse ---------------------------------------------------------------------

#' Set or display the default data frame for jstats functions
#'
#' @description
#' \code{juse()} sets a default data frame that will be used automatically
#' by all jstats functions when the \code{data} argument is omitted.
#' This reduces typing and makes interactive use more convenient.
#'
#' The function stores the \emph{name} of the data frame, not a copy of
#' the data. This means any changes you make to the data frame (adding
#' columns, recoding variables, etc.) are automatically reflected in
#' subsequent function calls.
#'
#' @param data A data frame (unquoted). If omitted, prints the current
#'   default. Use \code{juse(NULL)} to clear the default.
#'
#' @return Invisibly returns \code{NULL}. Called for its side effect of
#'   setting, displaying, or clearing the default data frame.
#'
#' @note \code{juse()} stores the \emph{name} of the data frame, not a copy
#'   of the data. This means any changes you make to the data frame (adding
#'   columns, recoding variables, etc.) are automatically reflected in
#'   subsequent function calls. This differs from base R's \code{attach()},
#'   which creates a snapshot that can become stale after modifications.
#'   \code{juse()} is the recommended approach for this package.
#'
#' @examples
#' \donttest{
#' juse(community)              # Set community as the default
#' juse()                       # Display current default
#' jdesc(Age, WellbeingScore)   # Uses community automatically
#' juse(NULL)                   # Clear the default
#' }
#'
#' @seealso \code{\link{jstats}} for the package overview,
#'   workflow conventions, and complete function listing.
#'
#' @export
juse <- function(data) {

  if (missing(data)) {
    # juse() with no arguments — print current default
    current <- getOption(".jst_default_data", default = NULL)
    if (is.null(current)) {
      message("No default data frame set. Use juse(DataFrameName) to set one.")
    } else {
      message("Current default data frame: ", current)
    }
    return(invisible(NULL))
  }

  # Capture the supplied expression WITHOUT forcing the promise. A bare
  # is.null(data) guard here would evaluate the argument first, so a
  # nonexistent symbol would trip R's raw "object not found" error before
  # the friendly exists() check below could run.
  data_sub <- substitute(data)

  # juse(NULL) — a literal NULL clears the default.
  if (is.null(data_sub)) {
    options(.jst_default_data = NULL)
    message("Default data frame cleared.")
    return(invisible(NULL))
  }

  data_name <- deparse(data_sub)

  # Check it exists and is a data frame.
  calling_env <- parent.frame()
  if (!exists(data_name, envir = calling_env)) {
    .jst_stop(paste0(data_name, " not found."))
  }
  data_val <- get(data_name, envir = calling_env)
  # A variable that holds NULL also clears the default, preserving the prior
  # behaviour where the is.null(data) guard caught this case.
  if (is.null(data_val)) {
    options(.jst_default_data = NULL)
    message("Default data frame cleared.")
    return(invisible(NULL))
  }
  if (!is.data.frame(data_val)) {
    .jst_stop(paste0(data_name, " is not a data frame."))
  }

  options(.jst_default_data = data_name)
  message("Default data frame set to: ", data_name)
  invisible(NULL)
}


# -- jsubset ------------------------------------------------------------------

#' Set, activate, deactivate, or clear a per-dataset case-selection expression
#'
#' @description
#' \code{jsubset()} sets a persistent case-selection expression that is
#' applied automatically by jstats analysis functions when the
#' default data frame (set by \code{juse()}) is in use. This is analogous
#' to the SPSS FILTER command.
#'
#' The expression is stored per dataset, so switching \code{juse()} between
#' datasets preserves each dataset's setting independently.
#'
#' The expression applies whenever the matching dataset is used, regardless
#' of whether it was supplied via \code{juse()} or specified explicitly in
#' a function call. To bypass it temporarily without losing it, use
#' \code{jsubset(off)} before the analysis and \code{jsubset(on)} afterward.
#' This matches the SPSS FILTER / USE ALL convention.
#'
#' Expressions use standard R logical operators: \code{==}, \code{!=},
#' \code{<}, \code{<=}, \code{>}, \code{>=}, \code{&} (AND), \code{|} (OR),
#' \code{!} (NOT), \code{xor()} (XOR), and `%in%`. Using \code{=} for
#' equality or the SPSS-style keywords \code{AND}/\code{OR}/\code{NOT} will
#' produce a helpful error suggesting the correct R syntax.
#'
#' @param data Optional data frame. If supplied, the expression is stored
#'   on that dataset specifically. If omitted, the dataset set by
#'   \code{juse()} is used.
#' @param expr A logical expression (e.g. \code{Age < 40 & Gender == 1}),
#'   or one of the following special values:
#'   \describe{
#'     \item{\code{off}}{Deactivate the setting but remember the expression.}
#'     \item{\code{on}}{Reactivate a previously deactivated setting.}
#'     \item{\code{NULL}}{Clear the setting entirely (forget the expression).}
#'   }
#'   If \code{expr} and \code{data} are both omitted, prints the current
#'   jsubset status.
#'
#' @return Invisibly returns \code{NULL}. Called for its side effect.
#'
#' @examples
#' \donttest{
#' juse(community)
#' jsubset(Age < 40)                        # Set using juse default
#' jsubset(community, Age < 40)             # Explicit dataset
#' jsubset(Age < 40 & WellbeingScore > 50)  # Compound condition
#' jsubset(off)                             # Deactivate
#' jsubset(on)                              # Reactivate
#' jsubset()                                # Check status
#' jsubset(NULL)                            # Clear entirely
#' }
#'
#' @seealso \code{\link{jstats}} for the package overview,
#'   workflow conventions, and complete function listing.
#'
#' @export
jsubset <- function(data, expr) {

  # -- No arguments: print session-wide status ------------------------------
  # Session-wide to match jsubset(NULL)'s scope. Collapse rule: 0 or 1 frame
  # renders on a single line; 2+ frames render a header line plus one
  # indented line per frame, with the juse() default marked.
  if (missing(data) && missing(expr)) {
    reg <- getOption(".jst_filter", default = list())
    reg <- reg[!vapply(reg, is.null, logical(1))]
    if (length(reg) == 0L) {
      message("No jsubset settings in this session.")
      return(invisible(NULL))
    }
    default_name <- getOption(".jst_default_data", default = NULL)
    dnames <- names(reg)
    if (length(reg) == 1L) {
      fs <- reg[[1L]]
      if (isTRUE(fs$active)) {
        message("jsubset active for ", dnames[1L], ": ", fs$expr_str)
      } else {
        message("jsubset set but inactive for ", dnames[1L], ": ", fs$expr_str)
      }
      return(invisible(NULL))
    }
    payloads <- vapply(reg, function(fs) fs$expr_str, character(1))
    active   <- vapply(reg, function(fs) isTRUE(fs$active), logical(1))
    .jst_render_status_overview("jsubset", dnames, payloads, active,
                                default_name)
    return(invisible(NULL))
  }

  # -- Capture both argument expressions BEFORE any evaluation --------------
  raw_data <- if (!missing(data)) substitute(data) else NULL
  raw_expr <- if (!missing(expr)) substitute(expr) else NULL

  # -- jsubset(NULL) — true global clear across all data frames -------------
  # Mirrors jdummy(NULL) semantics. Ignores the juse default; always
  # clears every per-data-frame jsubset setting. The condition
  # "data was supplied AND substituted expression is NULL" detects the
  # literal jsubset(NULL) call (cf. missing(data), which is FALSE here).
  if (!missing(data) && is.null(raw_data)) {
    all_filters <- getOption(".jst_filter", default = list())
    if (length(all_filters) == 0) {
      message("No jsubset settings to clear.")
      return(invisible(NULL))
    }
    dnames <- names(all_filters)
    hads <- vapply(seq_along(all_filters), function(i) {
      fs <- all_filters[[i]]
      if (is.null(fs)) "no jsubset set" else paste0("had: ", fs$expr_str)
    }, character(1))
    options(.jst_filter = NULL)
    .jst_render_clear("jsubset", dnames, hads)
    return(invisible(NULL))
  }

  # -- jsubset(off) / jsubset(on) — default-scoped --------------------------
  # Symbol checks happen on raw_data BEFORE the helper, since `off` and
  # `on` aren't real R objects and would fail evaluation.
  if (!is.null(raw_data) && is.symbol(raw_data) && missing(expr)) {
    sym_name <- tolower(as.character(raw_data))
    default_name <- getOption(".jst_default_data", default = NULL)
    if (sym_name == "off") {
      if (is.null(default_name)) {
        message("No default data frame set.")
        return(invisible(NULL))
      }
      fs <- .jst_get_filter(default_name)
      if (is.null(fs)) {
        message("No jsubset set for ", default_name, ". Nothing to deactivate.")
      } else {
        fs$active <- FALSE
        .jst_set_filter(default_name, fs)
        message("jsubset deactivated for ", default_name, ".")
      }
      return(invisible(NULL))
    }
    if (sym_name == "on") {
      if (is.null(default_name)) {
        message("No default data frame set.")
        return(invisible(NULL))
      }
      fs <- .jst_get_filter(default_name)
      if (is.null(fs)) {
        message("No jsubset set for ", default_name,
                ". Use jsubset(expression) to set one.")
      } else {
        fs$active <- TRUE
        .jst_set_filter(default_name, fs)
        message("jsubset reactivated for ", default_name, ": ", fs$expr_str)
      }
      return(invisible(NULL))
    }
  }

  # -- Resolve which arg is the data and which is the expression ------------
  # Uses the standard helper. For jsubset, the helper distinguishes:
  #   explicit            : raw_data is a data frame  -> raw_expr is the expr
  #   default             : missing(data)             -> raw_expr is the expr
  #   symbol_with_default : raw_data is the expr      -> juse default + raw_data
  arg1 <- .jst_resolve_first_arg(
    data_sub      = raw_data,
    data_missing  = missing(data),
    fn_name       = "jsubset",
    envir         = parent.frame(),
    accept_vector = FALSE
  )

  target_name <- arg1$name

  if (arg1$mode == "explicit") {
    # jsubset(SampleData, <expr>) — explicit data frame + expression slot
    if (missing(expr)) {
      .jst_stop("the condition must be a logical expression. ",
           "Example: jsubset(", target_name, ", Age < 40)")
    }
    filter_raw <- raw_expr
  } else if (arg1$mode == "default") {
    # jsubset(, <expr>) — leading comma + juse default
    if (is.null(raw_expr)) {
      stop("jsubset(): no logical expression supplied. ",
           "Example: jsubset(Age < 40)", call. = FALSE)
    }
    filter_raw <- raw_expr
  } else {
    # symbol_with_default — jsubset(<expr>) bare-expression form
    filter_raw <- arg1$first_arg_sub
  }

  # -- Detect common syntax mistakes before trying to evaluate --------------
  expr_str_for_check <- deparse(filter_raw, width.cutoff = 500)
  .jst_check_filter_syntax(filter_raw, expr_str_for_check)

  # -- Set and activate the expression --------------------------------------
  expr_str <- deparse(filter_raw, width.cutoff = 500)
  prior <- .jst_get_filter(target_name)
  .jst_set_filter(target_name, list(
    expr     = filter_raw,
    expr_str = expr_str,
    active   = TRUE
  ))
  if (!is.null(prior) && !identical(prior$expr_str, expr_str)) {
    message("jsubset replaced for ", target_name, ": ", expr_str,
            " (was: ", prior$expr_str, ")")
  } else {
    message("jsubset activated for ", target_name, ": ", expr_str)
  }
  invisible(NULL)
}


# -- .jst_check_filter_syntax -------------------------------------------------

#' Internal helper: detect common SPSS-style syntax mistakes in jsubset
#' expressions and provide guidance toward standard R operators.
#'
#' Catches:
#' - \code{=} used where \code{==} was meant (for equality comparison)
#' - \code{AND} / \code{OR} / \code{NOT} / \code{XOR} used as identifiers
#'   where \code{&} / \code{|} / \code{!} / \code{xor()} were meant
#'
#' @param raw_expr The unevaluated expression (a language object).
#' @param expr_str The deparsed expression string (for display in errors).
#' @keywords internal
.jst_check_filter_syntax <- function(raw_expr, expr_str) {

  # Catch a bare symbol used as the entire subset expression, e.g.
  # jsubset(Gender). The user almost certainly meant a comparison
  # like Gender == 1. Without this check, the symbol gets stored as
  # the expression and later attempts to apply it produce cryptic
  # errors from haven_labelled internals when subset_data is
  # non-logical.
  if (is.symbol(raw_expr)) {
    sym <- as.character(raw_expr)
    if (!sym %in% c("TRUE", "FALSE", "T", "F")) {
      .jst_stop(
        "Subset expression `", sym, "` is just a variable name and ",
        "cannot be used as a subset expression on its own. A subset ",
        "expression must compare a variable to a value (or evaluate to ",
        "TRUE/FALSE for each row).\n",
        "  Examples:\n",
        "    jsubset(", sym, " == 1)         # keep rows where ", sym, " is 1\n",
        "    jsubset(!is.na(", sym, "))       # keep rows where ", sym, " is not missing\n",
        "  You wrote: jsubset(", sym, ")"
      )
    }
  }

  # Collect all symbols referenced in the expression
  all_names <- all.names(raw_expr, unique = FALSE)

  # Check for SPSS-style logical keywords used as identifiers
  spss_kw <- c("AND", "OR", "NOT", "XOR")
  hit <- intersect(toupper(all_names), spss_kw)
  if (length(hit) > 0) {
    kw <- hit[1]
    replacement <- switch(kw,
                          AND = "`&` (single ampersand)",
                          OR  = "`|` (pipe symbol)",
                          NOT = "`!` (exclamation mark)",
                          XOR = "`xor()` (a function call)")
    .jst_stop(
      "It looks like you used `", kw, "` in your subset expression, ",
      "which R treats as a variable name, not a logical operator.\n",
      "  In R, use ", replacement, " instead.\n",
      "  Examples:\n",
      "    jsubset(Age < 40 & Gender == 1)     # AND\n",
      "    jsubset(Age < 40 | Age > 60)        # OR\n",
      "    jsubset(!is.na(Age))                # NOT\n",
      "  You wrote: ", expr_str
    )
  }

  # Check for assignment (`=`) used where equality (`==`) was meant.
  # R parses `Gender = 1` inside a function call as a named argument, but
  # when deparsed it produces a `Gender = 1` string. Use the unevaluated
  # expression's deparsed form for a text check — look for ` = ` that is
  # not ` == ` and not a call argument like `method =`.
  # Most robust: check if the deparsed expression contains a lone `=` sign
  # that isn't part of `==`, `<=`, `>=`, or `!=`.
  if (grepl("(?<![=<>!])=(?!=)", expr_str, perl = TRUE)) {
    .jst_stop(
      "It looks like you used `=` in your subset expression. In R, `=` is ",
      "assignment; equality comparison uses `==` (double equals).\n",
      "  Example: jsubset(Gender == 1)\n",
      "  You wrote: ", expr_str
    )
  }

  invisible(NULL)
}


# -- jcomplete ----------------------------------------------------------------

#' Internal helper: build and render the jcomplete deletion preview
#'
#' Constructs the row-level preview of what \code{jcomplete()}'s listwise
#' deletion will drop and renders it. Reuses the masked analysis copy
#' (SPSS-form UDMs already set to NA) so the preview reflects exactly what
#' the filter excludes (Cross-cutting 5). The display frame carries a leading
#' \code{Row} column (original position, as \code{which()} gives), the
#' registered variables (non-integer numerics rounded to 1 dp for display
#' only; integer-valued columns left untouched), and a trailing
#' \code{DeletionCheck} flag (1 for rows the filter will drop).
#'
#' The viewer (RStudio data tab) and the console listing are controlled
#' independently by the caller (\code{viewer} and \code{console}); each shows
#' only what is asked for. The viewer shows either the deleted rows only or all
#' cases (\code{show_all}); the console always shows deleted rows only, capped,
#' so it cannot flood the console. The console listing also serves as the
#' automatic fallback when the viewer was requested but no interactive viewer
#' is available.
#'
#' @param masked Analysis copy with SPSS-form UDMs masked to NA.
#' @param variable_names Character vector of the registered variables.
#' @param show_all Logical. If \code{TRUE}, the viewer shows every case;
#'   otherwise only the rows scheduled for deletion. Does not affect the
#'   console output, which is always deleted-rows-only.
#' @param console Logical or numeric. \code{FALSE} (default) prints nothing to
#'   the console; \code{TRUE} prints the first 10 deleted rows; a number prints
#'   that many. Independent of \code{viewer}.
#' @param viewer Logical. If \code{TRUE} (and the session is interactive),
#'   open the data viewer. Independent of \code{console}.
#' @param data_name Character. The data frame name, used in the viewer title
#'   and the fallback messages.
#'
#' @return Invisibly, the data frame shown in the viewer.
#'
#' @keywords internal
.jst_jcomplete_preview <- function(masked, variable_names, show_all = FALSE,
                                   console = FALSE, viewer = TRUE,
                                   data_name = NULL) {

  sub       <- masked[, variable_names, drop = FALSE]
  drop_flag <- !stats::complete.cases(sub)
  n_total   <- nrow(sub)

  # Display copy: strip haven class and round non-integer numerics to 1 dp
  # (display only). Already-integer and non-numeric columns are left as-is.
  # The filter itself is unaffected -- drop_flag came from `masked`.
  disp <- sub
  for (v in variable_names) {
    base <- unclass(disp[[v]])
    if (is.numeric(base)) {
      num    <- as.numeric(base)
      non_na <- num[!is.na(num)]
      if (length(non_na) && any(abs(non_na - round(non_na)) > 1e-8)) {
        num <- round(num, 1)
      }
      disp[[v]] <- num
    } else {
      disp[[v]] <- as.character(base)
    }
  }

  build <- function(idx) {
    data.frame(
      Row           = idx,
      disp[idx, , drop = FALSE],
      DeletionCheck = as.integer(drop_flag[idx]),
      row.names        = NULL,
      check.names      = FALSE,
      stringsAsFactors = FALSE
    )
  }

  viewer_idx <- if (isTRUE(show_all)) seq_len(n_total) else which(drop_flag)
  viewer_df  <- build(viewer_idx)
  deleted_df <- build(which(drop_flag))

  # -- Viewer (default surface) ---------------------------------------------
  title <- if (!is.null(data_name)) paste0("jcomplete preview: ", data_name)
           else "jcomplete preview"
  viewer_ok <- FALSE
  if (isTRUE(viewer) && interactive()) {
    # Prefer RStudio's docked data viewer: it opens as a Source-pane tab and
    # refreshes in place on a stable title, rather than stacking windows.
    # utils::View() is deliberately NOT called directly -- the utils:: prefix
    # bypasses RStudio's interception and opens base R's standalone viewer
    # window, which the OS places independently of the IDE. Fall back to that
    # base viewer only when not running under RStudio.
    view_fn <- if ("tools:rstudio" %in% search()) {
      tryCatch(get("View", envir = as.environment("tools:rstudio")),
               error = function(e) utils::View)
    } else {
      utils::View
    }
    viewer_ok <- tryCatch({ view_fn(viewer_df, title); TRUE },
                          error = function(e) FALSE)
  }

  # -- Console (independent of the viewer; also the no-viewer fallback) ------
  console_n <- if (isTRUE(console)) 10L
               else if (is.numeric(console) && length(console) == 1L &&
                        !is.na(console) && console >= 1) as.integer(console)
               else 0L
  want_console <- console_n > 0L
  # Fallback: the viewer was requested but could not open (no interactive
  # session) and the caller did not separately ask for console output.
  fallback     <- isTRUE(viewer) && !viewer_ok && !want_console

  if (want_console || fallback) {
    n_show <- if (want_console) console_n else 10L
    .cat_red("jcomplete Preview \u2014 rows scheduled for deletion\n")
    if (nrow(deleted_df) == 0L) {
      cat("  No cases will be dropped",
          " (no missing values on the registered variables).\n", sep = "")
    } else {
      .jst_print_table(utils::head(deleted_df, n_show), row.names = FALSE)
      if (nrow(deleted_df) > n_show) {
        more <- if (!fallback)
          " Use preview = TRUE to see them all in the viewer." else ""
        cat("\n  Showing the first ", n_show, " of ", nrow(deleted_df),
            " dropped rows.", more, "\n", sep = "")
      }
    }
    if (fallback) {
      message("(The preview viewer needs an interactive RStudio session; ",
              "showing the first ", n_show, " in the console instead.)")
    }
  }

  invisible(viewer_df)
}

#' Set a listwise complete-case filter for matching N across analyses
#'
#' @description
#' \code{jcomplete()} registers a set of variables and activates a listwise
#' deletion filter that excludes any case with a missing value on any of
#' the registered variables. This ensures that all subsequent analyses use
#' the same set of complete cases, which is essential when preliminary
#' analyses need to match the N of a final regression model.
#'
#' The setting is stored per dataset, so switching \code{juse()} between
#' datasets preserves each dataset's setting independently.
#'
#' The jcomplete filter applies whenever the matching dataset is used,
#' regardless of whether it was supplied via \code{juse()} or specified
#' explicitly in a function call. To bypass temporarily without losing
#' the setting, use \code{jcomplete(off)} before the analysis and
#' \code{jcomplete(on)} afterward. This matches the SPSS USE ALL /
#' FILTER convention.
#'
#' @param data A data frame. If omitted, uses the default set by
#'   \code{juse()}. Pass \code{NULL} to clear the filter entirely.
#'   Pass the bare word \code{off} to deactivate, or \code{on} to
#'   reactivate. Call with no arguments to check the current status.
#' @param ... Unquoted variable names to include in the listwise check.
#' @param preview Logical. If \code{TRUE}, open a viewer (RStudio data tab)
#'   showing the rows the listwise filter will drop, with a leading
#'   \code{Row} column (original data position) and a trailing
#'   \code{DeletionCheck} flag (1 = the row will be dropped). May be used on
#'   its own to preview the already-set filter without re-listing the
#'   variables (\code{jcomplete(preview = TRUE)}). Default \code{FALSE}.
#' @param console Logical or numeric. Print the dropped rows to the console.
#'   \code{TRUE} prints the first 10; a number prints that many. Independent of
#'   \code{preview}: on its own it prints to the console without opening the
#'   viewer; combine with \code{preview = TRUE} to get both. The console
#'   listing is always limited to the dropped rows so it cannot flood the
#'   console. Default \code{FALSE}.
#' @param non.deletes Logical. If \code{TRUE}, the viewer shows every case
#'   (with \code{DeletionCheck} marking which will drop) rather than only the
#'   dropped rows. Affects the viewer only; the console listing stays
#'   deleted-rows-only. Default \code{FALSE}.
#'
#' @return Invisibly returns \code{NULL}. When a preview is requested,
#'   invisibly returns the previewed data frame instead, so it can be
#'   captured (e.g. \code{jcomplete_rows <- jcomplete(preview = TRUE)}).
#'
#' @examples
#' \donttest{
#' juse(community)
#' jcomplete(Income, Education, Age)
#' jdesc(Age)                     # Uses only complete cases on those 3 vars
#' jcomplete(Income, Education, Age, preview = TRUE)  # Set and preview together
#' jcomplete(preview = TRUE)      # Preview the already-set filter (viewer)
#' jcomplete(preview = TRUE, non.deletes = TRUE)  # Viewer shows all cases
#' jcomplete(console = 10)        # Console only -- first 10 dropped rows
#' jcomplete(preview = TRUE, console = 25)        # Viewer and console
#' jcomplete(off)                 # Deactivate
#' jcomplete(on)                  # Reactivate
#' jcomplete()                    # Check status
#' jcomplete(NULL)                # Clear entirely
#' }
#'
#' @seealso \code{\link{jstats}} for the package overview,
#'   workflow conventions, and complete function listing.
#'
#' @export
jcomplete <- function(data, ..., preview = FALSE, console = FALSE,
                      non.deletes = FALSE) {

  default_name <- getOption(".jst_default_data", default = NULL)

  # Any preview surface requested? console and non.deletes both imply the
  # viewer, so any of the three turns the preview on.
  .preview_on <- isTRUE(preview) || isTRUE(non.deletes) || isTRUE(console) ||
    (is.numeric(console) && length(console) == 1L && !is.na(console) &&
       console >= 1)

  # A negative console value is meaningless; flag it rather than silently
  # treating it as "off" (0 / FALSE turn the console off; TRUE or a positive
  # number show that many dropped rows).
  if (is.numeric(console) && length(console) == 1L && !is.na(console) &&
      console < 0) {
    .jst_stop("`console` must be TRUE or a positive number of rows to show ",
         "(0 or FALSE turns it off); got ", console, ".")
  }

  # -- No arguments: print session-wide status ------------------------------
  # Session-wide to match jcomplete(NULL). Collapse rule: 0 or 1 frame on a
  # single line (the single active frame appends a live complete-case count
  # when the data frame is reachable from the caller); 2+ frames render a
  # header plus one indented line per frame, with the juse() default marked.
  if (missing(data) && ...length() == 0) {
    reg <- getOption(".jst_complete", default = list())
    reg <- reg[!vapply(reg, is.null, logical(1))]

    # Preview an already-registered filter without re-listing variables.
    if (.preview_on) {
      if (length(reg) == 0L) {
        message("No jcomplete filter set. ",
                "Run jcomplete(var1, var2, ...) first.")
        return(invisible(NULL))
      }
      target <- default_name
      if (is.null(target) || is.null(reg[[target]])) {
        if (length(reg) == 1L) {
          target <- names(reg)[1L]
        } else {
          message("Multiple jcomplete filters are set and no juse() default ",
                  "is active; set a default with juse() to choose which to ",
                  "preview.")
          return(invisible(NULL))
        }
      }
      cs          <- reg[[target]]
      calling_env <- parent.frame()
      if (!exists(target, envir = calling_env)) {
        message("Data frame ", target,
                " is not reachable here to build the preview.")
        return(invisible(NULL))
      }
      df         <- get(target, envir = calling_env)
      valid_vars <- cs$vars[cs$vars %in% names(df)]
      if (length(valid_vars) == 0L) {
        message("None of the registered variables are present in ",
                target, ".")
        return(invisible(NULL))
      }
      masked <- .jst_apply_declared_udms_as_na(
        df[, valid_vars, drop = FALSE])$data
      return(.jst_jcomplete_preview(masked, valid_vars,
                                    show_all  = isTRUE(non.deletes),
                                    console   = console,
                                    viewer    = isTRUE(preview) ||
                                                isTRUE(non.deletes),
                                    data_name = target))
    }

    if (length(reg) == 0L) {
      message("No jcomplete settings in this session.")
      return(invisible(NULL))
    }
    dnames <- names(reg)
    if (length(reg) == 1L) {
      cs        <- reg[[1L]]
      vars_str  <- paste(cs$vars, collapse = ", ")
      count_str <- ""
      calling_env <- parent.frame()
      if (exists(dnames[1L], envir = calling_env)) {
        df         <- get(dnames[1L], envir = calling_env)
        valid_vars <- cs$vars[cs$vars %in% names(df)]
        if (length(valid_vars) > 0L) {
          n_total    <- nrow(df)
          # Mask SPSS-form UDMs first so the live count matches the analysis
          # pipeline (Cross-cutting 5); see the setup-summary note below.
          masked     <- .jst_apply_declared_udms_as_na(
            df[, valid_vars, drop = FALSE])$data
          n_complete <- sum(stats::complete.cases(masked[, valid_vars, drop = FALSE]))
          count_str  <- paste0(" (", n_complete, " of ", n_total,
                               " complete cases)")
        }
      }
      if (isTRUE(cs$active)) {
        message("jcomplete active for ", dnames[1L], ": ", vars_str, count_str)
      } else {
        message("jcomplete set but inactive for ", dnames[1L], ": ", vars_str)
      }
      return(invisible(NULL))
    }
    payloads <- vapply(reg, function(cs) paste(cs$vars, collapse = ", "),
                       character(1))
    active   <- vapply(reg, function(cs) isTRUE(cs$active), logical(1))
    .jst_render_status_overview("jcomplete", dnames, payloads, active,
                                default_name)
    return(invisible(NULL))
  }

  # -- Capture substitute BEFORE any evaluation ------------------------------
  # Must happen before is.null(data) or any other use of data, otherwise
  # bare symbols like off/on cause "object not found" errors.
  raw_data <- if (!missing(data)) substitute(data) else NULL

  # -- jcomplete(NULL) — true global clear across all data frames -----------
  # Mirrors jdummy(NULL) and jsubset(NULL) semantics. Ignores juse default;
  # always clears every per-data-frame jcomplete setting. The condition
  # "data was supplied AND substituted expression is NULL" detects the
  # literal jcomplete(NULL) call.
  if (!missing(data) && is.null(raw_data)) {
    all_complete <- getOption(".jst_complete", default = list())
    if (length(all_complete) == 0) {
      message("No jcomplete settings to clear.")
      return(invisible(NULL))
    }
    dnames <- names(all_complete)
    hads <- vapply(seq_along(all_complete), function(i) {
      cs <- all_complete[[i]]
      if (is.null(cs)) "no settings"
      else paste0("had: ", paste(cs$vars, collapse = ", "))
    }, character(1))
    options(.jst_complete = NULL)
    .jst_render_clear("jcomplete", dnames, hads)
    return(invisible(NULL))
  }

  # -- jcomplete(off) / jcomplete(on) — default-scoped ----------------------
  # Symbol checks happen on raw_data BEFORE the helper, since `off` and
  # `on` aren't real R objects and would fail evaluation. The
  # ...length() == 0 guard avoids interpreting a variable named "off"
  # accompanied by other variables as the off command.
  if (!is.null(raw_data) && is.symbol(raw_data) && ...length() == 0) {
    sym_name <- tolower(as.character(raw_data))
    if (sym_name == "off") {
      if (is.null(default_name)) {
        message("No default data frame set.")
        return(invisible(NULL))
      }
      cs <- .jst_get_complete(default_name)
      if (is.null(cs)) {
        message("No jcomplete filter set for ", default_name, ".")
      } else {
        cs$active <- FALSE
        .jst_set_complete(default_name, cs)
        message("jcomplete deactivated for ", default_name, ".")
      }
      return(invisible(NULL))
    }
    if (sym_name == "on") {
      if (is.null(default_name)) {
        message("No default data frame set.")
        return(invisible(NULL))
      }
      cs <- .jst_get_complete(default_name)
      if (is.null(cs)) {
        message("No jcomplete filter set for ", default_name,
                ". Use jcomplete(var1, var2, ...) to set one.")
      } else {
        cs$active <- TRUE
        .jst_set_complete(default_name, cs)
        message("jcomplete reactivated for ", default_name, ": ",
                paste(cs$vars, collapse = ", "))
      }
      return(invisible(NULL))
    }
  }

  # -- Resolve the first argument via the standard helper -------------------
  # Three modes possible at this point:
  #   explicit            : jcomplete(SampleData, v1, v2)  - data is a frame
  #   default             : jcomplete(, v1, v2)            - leading-comma form
  #   symbol_with_default : jcomplete(v1, v2, v3)          - bare-symbol form
  arg1 <- .jst_resolve_first_arg(
    data_sub      = raw_data,
    data_missing  = missing(data),
    fn_name       = "jcomplete",
    envir         = parent.frame(),
    accept_vector = FALSE
  )

  data              <- arg1$data
  .jst_data_name    <- arg1$name
  .jst_default_used <- arg1$mode %in% c("default", "symbol_with_default")

  variables <- rlang::enquos(...)

  # Bare-symbol form: prepend the captured first symbol to the variables list
  if (arg1$mode == "symbol_with_default") {
    extra_quo <- rlang::new_quosure(arg1$first_arg_sub,
                                    env = parent.frame())
    variables <- c(list(extra_quo), variables)
    class(variables) <- "quosures"
  }

  variable_names <- vapply(variables, rlang::quo_name, character(1))

  if (length(variable_names) == 0) {
    .jst_stop("Provide at least one variable name, e.g. jcomplete(DV, IV1, IV2).")
  }

  .jst_check_vars(data, variable_names, .jst_data_name, default_used = .jst_default_used)

  # Compute summary. Mask declared SPSS-form UDMs (na_values / na_range) to NA on
  # an analysis-only copy first, so this listwise diagnostic matches what the
  # analysis pipeline will actually exclude (Cross-cutting 5). complete.cases()
  # does not honour haven_labelled_spss na_values; is.na() does -- deriving both
  # the Missing column and the complete-case count from the masked copy keeps them
  # consistent. Stata/SAS tagged-NA values satisfy is.na() natively and are not
  # touched by the helper, so they already flow through complete.cases() correctly.
  n_total <- nrow(data)
  masked  <- .jst_apply_declared_udms_as_na(
    data[, variable_names, drop = FALSE])$data
  missing_info <- data.frame(
    Variable  = variable_names,
    N         = rep(n_total, length(variable_names)),
    Missing   = vapply(variable_names, function(v) sum(is.na(masked[[v]])), integer(1)),
    stringsAsFactors = FALSE
  )
  missing_info$Pct <- sprintf("%.1f%%", missing_info$Missing / n_total * 100)

  n_complete <- sum(stats::complete.cases(masked[, variable_names, drop = FALSE]))
  n_excluded <- n_total - n_complete

  # Store settings (capture any prior setting first, to flag replacement)
  prior_complete <- .jst_get_complete(.jst_data_name)
  .jst_set_complete(.jst_data_name, list(
    vars   = variable_names,
    active = TRUE
  ))

  # Print summary
  .cat_red("Listwise Case Filter\n")
  if (.jst_default_used) .jst_default_note(.jst_data_name, extra_newline = TRUE)

  .jst_print_table(missing_info,
                   col.names = c("Variable", "N", "Missing", "% Missing"),
                   row.names = FALSE)

  cat("\n  Complete cases: ", n_complete, " of ", n_total,
      " (", sprintf("%.1f", n_complete / n_total * 100), "%)\n", sep = "")
  if (n_excluded > 0) {
    cat("  Listwise filter activated \u2014 ", n_excluded,
        " cases will be excluded from subsequent analyses.\n", sep = "")
  } else {
    cat("  Listwise filter activated \u2014 no cases will be excluded (no missing values).\n")
  }
  if (!is.null(prior_complete) &&
      !identical(prior_complete$vars, variable_names)) {
    cat("  Replaced the previous jcomplete on ", .jst_data_name, " (was: ",
        paste(prior_complete$vars, collapse = ", "), ").\n", sep = "")
  }

  # Optional row-level preview of what the filter will drop. `masked` and
  # `variable_names` are already computed above for the summary, so the
  # preview reflects exactly the same complete-case logic.
  if (.preview_on) {
    pv <- .jst_jcomplete_preview(masked, variable_names,
                                 show_all  = isTRUE(non.deletes),
                                 console   = console,
                                 viewer    = isTRUE(preview) ||
                                             isTRUE(non.deletes),
                                 data_name = .jst_data_name)
    return(invisible(pv))
  }

  invisible(NULL)
}


#' Internal helper: render a dummy coding-scheme table
#'
#' Single source of truth for the 0/1 dummy coding-scheme table shown by
#' \code{jdummy()} -- on registration, on display-only inspection, and in the
#' no-argument registration overview. Prints the identity-pattern table with
#' the reference category starred, the reference footnote, and, when there are
#' more than five categories and \code{show} is not "all", the truncation note.
#' The caller prints the "Dummy Coding Scheme:" header before calling this.
#'
#' @param codes The category codes (numeric or character) in display order.
#' @param labels The category labels parallel to \code{codes}.
#' @param ref_idx Integer index of the reference category within \code{codes}.
#' @param show The caller's \code{show} argument; "all" (any case) shows every
#'   category, otherwise the first five.
#'
#' @return \code{invisible(NULL)}. Called for its printed side effect.
#'
#' @keywords internal
.jst_print_dummy_scheme <- function(codes, labels, ref_idx, show) {
  n_cats   <- length(codes)
  show_all <- is.character(show) && tolower(show) == "all"
  n_show   <- if (show_all) n_cats else min(n_cats, 5)

  all_col_names <- character(n_show)
  for (i in seq_len(n_show)) {
    all_col_names[i] <- if (i == ref_idx) paste0(labels[i], "*") else labels[i]
  }

  row_labels <- character(n_show)
  for (i in seq_len(n_show)) {
    row_labels[i] <- if (i == ref_idx) {
      paste0(codes[i], ": ", labels[i], "*")
    } else {
      paste0(codes[i], ": ", labels[i])
    }
  }

  scheme <- matrix(0L, nrow = n_show, ncol = n_show)
  for (i in seq_len(n_show)) scheme[i, i] <- 1L
  scheme_df <- as.data.frame(scheme, stringsAsFactors = FALSE)
  names(scheme_df)    <- all_col_names
  rownames(scheme_df) <- row_labels

  .jst_print_table(scheme_df,
                   col.names     = all_col_names,
                   row.names     = TRUE,
                   indent        = 4,
                   header.indent = 4)

  cat("\n    * Reference category\n")
  if (n_cats > 5 && !show_all) {
    cat("    (Showing first 5 of ", n_cats,
        " categories \u2014 use show = \"all\" for complete table)\n", sep = "")
  }
  invisible(NULL)
}


# -- jdummy -------------------------------------------------------------------

#' Register categorical variables for dummy coding in regression
#'
#' @description
#' \code{jdummy()} registers a categorical variable so that \code{jlm()}
#' automatically expands it into dummy (indicator) variables when it appears
#' in a regression formula. The original data frame is never modified. Several
#' variables can be registered in one call; the \code{ref} setting then applies
#' to each of them.
#'
#' Registrations are stored per dataset, so switching \code{juse()} between
#' datasets preserves each dataset's registrations independently.
#'
#' @param data A data frame, or omit to use the \code{juse()} default.
#'   \code{jdummy(NULL)} clears the dummy registrations on the \code{juse()}
#'   default data frame (or, with no default set, the only frame that carries
#'   them; if several do, it asks rather than wiping all).
#' @param ... One or more unquoted variable names to register. Omit (along
#'   with data) to display all current registrations. A lone \code{NULL} in the
#'   variable slot -- \code{jdummy(data, NULL)} -- clears that frame's dummy
#'   registrations.
#' @param ref The reference category (excluded from the regression model).
#'   Can be a numeric code, a quoted label name, or \code{first}
#'   (default) or \code{last}. Applied to every variable named in the call;
#'   to use different reference categories, register the variables in
#'   separate calls.
#' @param show Logical. If \code{TRUE}, prints the dummy coding scheme
#'   table showing the pattern of 0s and 1s. Default is \code{FALSE}.
#' @param remove Logical. If \code{TRUE}, removes the registration for
#'   the specified variable(s). Default is \code{FALSE}.
#' @param clear.all Logical. If \code{TRUE}, clears dummy registrations on
#'   every data frame that carries them. Default is \code{FALSE}.
#' @param max.categories Integer. Maximum number of categories a variable may
#'   have to be dummy-coded; a variable with more raises an error. Raise it to
#'   dummy-code a higher-cardinality variable. Default \code{20L}.
#'
#' @return Invisibly returns \code{NULL}. Called for its side effect.
#'
#' @examples
#' \donttest{
#' juse(community)
#' jdummy(Region)                       # Register, first category as reference
#' jdummy(Region, Education)            # Register several at once
#' jdummy(Region, ref = "last")         # Last category as reference
#' jdummy(Region, ref = 4)              # Reference by numeric code
#' jdummy(Region, ref = "East")         # Reference by value label
#' jdummy(Region, show = TRUE)          # Show coding scheme
#' jdummy(Region, show = "all")         # Full scheme (for many categories)
#' jdummy()                             # Show all registrations
#' jdummy(Region, remove = TRUE)        # Remove one registration
#' jdummy(community, NULL)              # Clear community's dummy registrations
#' jdummy(NULL)                         # Clear the default frame's (or ask)
#' jdummy(clear.all = TRUE)             # Clear every frame's dummy registrations
#' }
#'
#' @seealso \code{\link{jstats}} for the package overview,
#'   workflow conventions, and complete function listing.
#'
#' @export
jdummy <- function(data, ..., ref = "first", show = FALSE,
                   remove = FALSE, clear.all = FALSE,
                   max.categories = 20L) {

  default_name <- getOption(".jst_default_data", default = NULL)

  # jdummy(clear.all = TRUE): clear dummy registrations on every frame.
  if (isTRUE(clear.all)) return(.jst_handle_clear("dummy", clear.all = TRUE))

  # -- jdummy() — no arguments: session-wide registration status ------------
  # Session-wide to match jdummy(NULL). Collapse rule: 1 frame renders the
  # full per-registration block (with optional coding scheme via show=);
  # 2+ frames render a header plus one concise line per frame (registered
  # variable names), with the juse() default marked. jdummy holds a list of
  # registrations per frame and has no active/inactive toggle, so there is
  # no off/on state to show here (unlike jsubset / jcomplete).
  if (missing(data) && ...length() == 0L) {
    reg <- getOption(".jst_dummy", default = list())
    reg <- reg[vapply(reg, function(x) !is.null(x) && length(x) > 0L,
                      logical(1))]
    if (length(reg) == 0L) {
      message("No dummy registrations in this session.")
      return(invisible(NULL))
    }
    dnames <- names(reg)
    if (length(reg) > 1L) {
      lines <- vapply(seq_along(reg), function(i) {
        vn  <- vapply(reg[[i]], function(r) r$var_name, character(1))
        tag <- if (identical(dnames[i], default_name)) "  [default]" else ""
        paste0("  - ", dnames[i], ": ", paste(vn, collapse = ", "), tag)
      }, character(1))
      message("jdummy registrations (", length(reg), " data frames):\n",
              paste(lines, collapse = "\n"))
      return(invisible(NULL))
    }
    # Single frame: full per-registration rendering.
    frame_name <- dnames[1L]
    ds <- reg[[1L]]
    .cat_red("Dummy Variable Registrations\n")
    if (identical(frame_name, default_name)) {
      .jst_default_note(frame_name, extra_newline = TRUE)
    } else {
      .cat_yellow(paste0("Data frame: ", frame_name, "\n"))
      cat("\n")
    }
    for (regn in ds) {
      cat("  Variable: ", regn$var_name,
          " (", regn$var_type, ")\n", sep = "")
      cat("  Reference category: ", regn$ref_code, ": ", regn$ref_label, "\n", sep = "")
      cat("  Dummy variables: ", paste(regn$dummy_names, collapse = ", "), "\n", sep = "")
      cat("  Cases: ", regn$n_total,
          " (", regn$n_missing, " missing)\n", sep = "")

      # Show coding scheme if requested
      if (!identical(show, FALSE)) {
        cat("\n  Dummy Coding Scheme:\n\n")
        .jst_print_dummy_scheme(regn$codes, regn$labels, regn$ref_idx, show)
      }
      cat("\n")
    }
    return(invisible(NULL))
  }

  # -- Capture substitute BEFORE any evaluation ------------------------------
  # Needed for the literal-NULL detection idiom and for the helper call.
  raw_data <- if (!missing(data)) substitute(data) else NULL

  # -- jdummy(NULL) — clear the default frame (or sole/ask) -----------------
  # "data supplied AND substituted expression is NULL" detects the literal
  # jdummy(NULL) call. No longer an all-frames wipe: it clears the juse()
  # default frame if one is set, else the sole registered frame, else asks --
  # use jdummy(clear.all = TRUE) for every frame. Unified with jnumeric(NULL)/
  # jcount(NULL) via the shared dispatcher.
  if (!missing(data) && is.null(raw_data)) {
    return(.jst_handle_clear("dummy", default_name = default_name))
  }

  # -- Resolve the first argument via the standard helper -------------------
  # Three modes possible at this point:
  #   explicit            : jdummy(SampleData, A, B)        - data is a frame
  #   default             : jdummy(, A, B)                  - leading-comma form
  #   symbol_with_default : jdummy(A, B)                    - bare-symbol form
  arg1 <- .jst_resolve_first_arg(
    data_sub      = raw_data,
    data_missing  = missing(data),
    fn_name       = "jdummy",
    envir         = parent.frame(),
    accept_vector = FALSE
  )

  data              <- arg1$data
  .jst_data_name    <- arg1$name
  .jst_default_used <- arg1$mode %in% c("default", "symbol_with_default")

  # -- Collect variable names (multivariable) -------------------------------
  # jdummy accepts one or more variables. In symbol_with_default mode the first
  # argument is itself a variable (data came from the juse() default), so fold
  # it back in ahead of the dots -- the same pattern jnumeric()/jcount() use.
  # ref/show/remove sit after the dots and are therefore always named, which
  # removes the need for the old positional-argument guard.
  variables <- rlang::enquos(...)
  if (arg1$mode == "symbol_with_default") {
    extra_quo <- rlang::new_quosure(arg1$first_arg_sub, env = parent.frame())
    variables <- c(list(extra_quo), variables)
    class(variables) <- "quosures"
  }
  var_names <- if (length(variables) > 0L) {
    unname(vapply(variables, rlang::quo_name, character(1)))
  } else {
    character(0)
  }

  # -- jdummy(data, NULL) -- per-dataset clear ------------------------------
  # A lone NULL in the variable slot clears this dataset's registrations,
  # matching jnumeric(data, NULL) / jcount(data, NULL). The default/sole/ask
  # form jdummy(NULL) is handled earlier and never reaches this point.
  if (identical(var_names, "NULL")) {
    return(.jst_handle_clear("dummy", explicit_frame = .jst_data_name))
  }

  # No usable variable: data supplied but no variable named.
  if (length(var_names) == 0L) {
    stop("jdummy(): no variable supplied. ",
         "Use jdummy(VarName) to register, jdummy(VarName, remove = TRUE) ",
         "to remove, jdummy(VarName = NULL) to clear this frame, ",
         "or jdummy(clear.all = TRUE) to clear every frame.",
         call. = FALSE)
  }

  .jst_check_vars(data, var_names, .jst_data_name, default_used = .jst_default_used)

  # -- jdummy(var, show = ...) on an already-registered var: display only ----
  # Single-variable inspection convenience: naming one already-registered
  # variable with show = ... but no ref = ... displays the existing scheme
  # without re-registering (which would clobber a non-default reference).
  # With two or more variables the call always registers.
  if (length(var_names) == 1L && !identical(show, FALSE) &&
      missing(ref) && !remove) {
    var_name <- var_names[1L]
    ds <- .jst_get_dummy(.jst_data_name)
    if (!is.null(ds)) {
      existing_idx <- which(vapply(ds, function(r) r$var_name == var_name,
                                   logical(1)))
      if (length(existing_idx) > 0) {
        reg <- ds[[existing_idx[1]]]

        .cat_red("Dummy Variable Registration\n")
        if (.jst_default_used) .jst_default_note(.jst_data_name, extra_newline = TRUE)
        cat("  Variable: ", reg$var_name, " (", reg$var_type, ")\n", sep = "")
        cat("  Reference category: ", reg$ref_label, "\n", sep = "")
        cat("  Dummy variables: ", paste(reg$dummy_names, collapse = ", "),
            "\n", sep = "")
        cat("  Cases: ", reg$n_total, " (", reg$n_missing, " missing)\n",
            sep = "")

        cat("\n  Dummy Coding Scheme:\n\n")
        .jst_print_dummy_scheme(reg$codes, reg$labels, reg$ref_idx, show)
        cat("\n")
        return(invisible(NULL))
      }
    }
    # No existing registration -- fall through to register-and-display.
  }

  # -- jdummy(..., remove = TRUE) -- remove registrations -------------------
  if (remove) {
    ds      <- .jst_get_dummy(.jst_data_name)
    removed <- character(0)
    if (!is.null(ds)) {
      drop    <- vapply(ds, function(r) r$var_name %in% var_names, logical(1))
      removed <- vapply(ds[drop], function(r) r$var_name, character(1))
      ds      <- ds[!drop]
      if (length(ds) == 0) ds <- NULL
      .jst_set_dummy(.jst_data_name, ds)
    }
    if (length(removed) > 0) {
      message("Dummy registration removed for ",
              paste0("'", removed, "'", collapse = ", "), " in ",
              .jst_data_name, ".")
    } else {
      message("No dummy registration to remove for ",
              paste0("'", var_names, "'", collapse = ", "), " in ",
              .jst_data_name, ".")
    }
    return(invisible(NULL))
  }

  # -- Register one or more variables ---------------------------------------
  # The red header and the juse() default note print once; each variable then
  # gets its own block. The standard-tier persist reminder prints once after
  # all registrations, and any deferred naming warnings are emitted last so
  # they carry full context. (Session 82: multivariable + persist reminder.)
  .cat_red("Dummy Variable Registration\n")
  if (.jst_default_used) .jst_default_note(.jst_data_name, extra_newline = TRUE)

  deferred <- character(0)
  for (var_name in var_names) {
    col   <- data[[var_name]]
    built <- .jst_make_dummy_names(col, var_name, ref = ref,
                                   max.categories = max.categories,
                                   data_name = .jst_data_name)

    n_total   <- length(col)
    n_missing <- sum(is.na(col))

    # Informational notes from the helper (e.g. labels not descriptive).
    for (n in built$notes) cat(n, "\n", sep = "")

    reg <- list(
      var_name    = var_name,
      var_type    = built$var_type,
      codes       = built$codes,
      labels      = built$labels,
      ref_idx     = built$ref_idx,
      ref_code    = built$ref_code,
      ref_label   = built$ref_label,
      dummy_names = built$dummy_names,
      non_ref_idx = built$non_ref_idx,
      n_total     = n_total,
      n_missing   = n_missing
    )

    ds <- .jst_get_dummy(.jst_data_name)
    if (is.null(ds)) ds <- list()
    existing_idx <- which(vapply(ds, function(r) r$var_name == var_name,
                                 logical(1)))
    if (length(existing_idx) > 0) {
      ds[[existing_idx[1]]] <- reg
    } else {
      ds[[length(ds) + 1]] <- reg
    }
    .jst_set_dummy(.jst_data_name, ds)

    # Mutual exclusion: becoming a dummy drops any numeric/count intent so the
    # .jst_dummy and .jst_registry stores stay disjoint per variable.
    .cleared_kind <- .jst_clear_intent_var(.jst_data_name, var_name)
    if (!is.null(.cleared_kind)) {
      message("Reclassified: '", var_name, "' (",
              .jst_intent_label(.cleared_kind), " -> dummy).")
    }

    cat("  Variable: ", var_name, " (", built$var_type, ")\n", sep = "")
    cat("  Reference category: ", built$ref_label, "\n", sep = "")
    cat("  Dummy variables: ", paste(built$dummy_names, collapse = ", "),
        "\n", sep = "")
    cat("  Cases: ", n_total, " (", n_missing, " missing)\n", sep = "")

    if (!identical(show, FALSE)) {
      cat("\n  Dummy Coding Scheme:\n\n")
      .jst_print_dummy_scheme(built$codes, built$labels, built$ref_idx, show)
    }

    cat("\n")
    deferred <- c(deferred, built$warnings_msg)
  }

  # Persist reminder (standard-tier; suppressed at minimal output).
  if (!identical(getOption(".jst_output_level", "standard"), "minimal")) {
    message(.jst_durability_note("session", .jst_data_name,
                                 count = length(var_names)))
  }

  # Non-blocking declaration-plausibility heads-up for the just-registered
  # dummy variables (flags a many-category declaration). (Session 91)
  .jst_declaration_note(data, var_names, "dummy")

  for (w in deferred) warning(w, call. = FALSE)

  invisible(NULL)
}


#' Internal helper: render the session-wide numeric/count registration status
#'
#' Backs the no-argument calls \code{jnumeric()} and \code{jcount()}, which
#' both show the same unified view of the \code{.jst_registry} notebook
#' (numeric and count intents, each tagged by kind) across all data frames.
#' Dummy registrations live in a separate store and are shown by
#' \code{jdummy()}. Mirrors the jdummy no-argument overview layout: a single
#' registered frame renders a red header plus one line per variable; two or
#' more frames render a header plus one indented line per frame, with the
#' \code{juse()} default marked.
#'
#' @return \code{invisible(NULL)}. Called for its message side effect.
#'
#' @keywords internal
.jst_registry_status <- function() {
  default_name <- getOption(".jst_default_data", default = NULL)
  all_reg <- getOption(".jst_registry", default = list())
  all_reg <- all_reg[vapply(all_reg, function(x) !is.null(x) && length(x) > 0L,
                            logical(1))]
  if (length(all_reg) == 0L) {
    message("No variable registrations in this session.")
    return(invisible(NULL))
  }
  dnames <- names(all_reg)

  # Render one frame's records as "var (kind)" pieces.
  frame_items <- function(recs) {
    vapply(recs, function(r) paste0(r$var_name, " (",
                                    .jst_intent_label(r$kind), ")"),
           character(1))
  }

  if (length(all_reg) > 1L) {
    lines <- vapply(seq_along(all_reg), function(i) {
      items <- frame_items(all_reg[[i]])
      tag   <- if (identical(dnames[i], default_name)) "  [default]" else ""
      paste0("  - ", dnames[i], ": ", paste(items, collapse = ", "), tag)
    }, character(1))
    message("jstats registrations (", length(all_reg), " data frames):\n",
            paste(lines, collapse = "\n"))
    return(invisible(NULL))
  }

  # Single frame: red header plus one line per registered variable.
  frame_name <- dnames[1L]
  recs       <- all_reg[[1L]]
  .cat_red("Variable Registrations\n")
  if (identical(frame_name, default_name)) {
    .jst_default_note(frame_name, extra_newline = TRUE)
  } else {
    .cat_yellow(paste0("Data frame: ", frame_name, "\n"))
    cat("\n")
  }
  for (r in recs) {
    cat("  ", r$var_name, ": ", .jst_intent_label(r$kind), "\n", sep = "")
  }
  cat("\n")
  invisible(NULL)
}


# -- jnumeric / jcount ---------------------------------------------------------

#' Register variables as numeric for analysis
#'
#' \code{jnumeric()} tells jstats to treat one or more variables as numeric
#' (continuous) wherever their analysis class matters, overriding the package's
#' automatic structural guess. It is the counterpart to \code{\link{jdummy}}
#' (categorical) and \code{\link{jcount}} (count): a variable carries exactly
#' one registered intent at a time, so registering it as numeric clears any
#' prior dummy or count registration. Registration changes no data and assigns
#' nothing -- you do not write \code{df <- jnumeric(...)}. It is stored for the
#' session, keyed by the data frame's name; save the data frame in R format
#' (.rds) to keep it across sessions.
#'
#' The typical use is a small-range whole number that the structural classifier
#' would treat as categorical (e.g. a 0-6 attitude item) but that you want
#' analyzed as a continuous score.
#'
#' @param data A data frame, or omitted to use the \code{\link{juse}} default.
#'   \code{jnumeric(NULL)} clears the numeric registrations on the
#'   \code{\link{juse}} default frame (or, with no default set, the only frame
#'   that carries them; if several do, it asks rather than wiping all).
#'   \code{jnumeric(data, NULL)} clears that one frame's numeric registrations.
#'   Called with no arguments, \code{jnumeric()} lists the session's numeric
#'   and count registrations.
#' @param ... One or more unquoted variable names to register.
#' @param remove Logical; if \code{TRUE}, remove the numeric registration for
#'   the named variables instead of adding it.
#' @param clear.all Logical; if \code{TRUE}, clear numeric registrations on
#'   every data frame that carries them.
#' @return \code{invisible(NULL)}. Called for its side effect on the session
#'   registration notebook.
#' @seealso \code{\link{jdummy}}, \code{\link{jcount}}
#' @examples
#' # Treat a labelled Likert item as a continuous score (slope-per-unit)
#' jnumeric(community, Environment2)             # one labelled 1-5 item
#' jnumeric(community, Environment2, Environment4)  # several at once
#' jnumeric(community, Environment2, remove = TRUE) # unregister one
#' jnumeric()                          # list all registrations
#' jnumeric(community, NULL)           # clear community's numeric registrations
#' jnumeric(clear.all = TRUE)          # clear every frame's numeric registrations
#' @export
jnumeric <- function(data, ..., remove = FALSE, clear.all = FALSE) {
  # jnumeric(clear.all = TRUE): clear numeric registrations on every frame.
  if (isTRUE(clear.all)) return(.jst_handle_clear("numeric", clear.all = TRUE))
  # jnumeric() with no arguments: show the session-wide registry status.
  if (missing(data) && ...length() == 0L) return(.jst_registry_status())
  raw_data <- if (!missing(data)) substitute(data) else NULL
  # jnumeric(NULL): clear the default frame (or the sole registered frame, or
  # ask) -- never a silent all-frames wipe (use clear.all = TRUE for that).
  if (!missing(data) && is.null(raw_data)) {
    return(.jst_handle_clear("numeric",
             default_name = getOption(".jst_default_data", default = NULL)))
  }

  arg1 <- .jst_resolve_first_arg(
    data_sub      = substitute(data),
    data_missing  = missing(data),
    fn_name       = "jnumeric",
    envir         = parent.frame(),
    accept_vector = FALSE
  )
  data         <- arg1$data
  data_name    <- arg1$name
  default_used <- arg1$mode %in% c("default", "symbol_with_default")

  variables <- rlang::enquos(...)
  if (arg1$mode == "symbol_with_default") {
    extra_quo <- rlang::new_quosure(arg1$first_arg_sub, env = parent.frame())
    variables <- c(list(extra_quo), variables)
    class(variables) <- "quosures"
  }
  # jnumeric(data, NULL): clear this frame's numeric registrations (mirrors
  # jdummy(data, NULL); the lone NULL sits in the variable slot).
  if (length(variables) == 1L && rlang::quo_is_null(variables[[1]])) {
    return(.jst_handle_clear("numeric", explicit_frame = data_name))
  }
  if (length(variables) == 0) {
    .jst_stop("Specify one or more variables to register, e.g. ",
         "jnumeric(", data_name, ", <var1>, <var2>).")
  }
  var_names <- vapply(variables, rlang::quo_name, character(1))

  .jst_register_intent("numeric", data, data_name, default_used,
                       var_names, remove)
}


#' Register variables as counts for analysis
#'
#' \code{jcount()} tells jstats to treat one or more variables as count
#' variables (non-negative whole-number tallies). A count is numeric-like -- it
#' passes wherever a numeric variable does and shows mean/median in
#' \code{\link{jscreen}} -- and additionally carries count semantics: it is the
#' asserted signal behind the count-regression caveat in \code{\link{jlm}} and
#' the routing target for future count-model functions. Unlike the structural
#' guess, jcount accepts counts of any range, including those outside the
#' automatic small-range detection (e.g. a 0-30 victimization count).
#'
#' A variable carries exactly one registered intent at a time, so registering
#' it as a count clears any prior dummy or numeric registration. Registration
#' changes no data and assigns nothing. It is stored for the session, keyed by
#' the data frame's name; save the data frame in R format (.rds) to keep
#' it across sessions.
#'
#' @param data A data frame, or omitted to use the \code{\link{juse}} default.
#'   \code{jcount(NULL)} clears the count registrations on the \code{\link{juse}}
#'   default frame (or, with no default set, the only frame that carries them;
#'   if several do, it asks rather than wiping all). \code{jcount(data, NULL)}
#'   clears that one frame's count registrations. Called with no arguments,
#'   \code{jcount()} lists the session's numeric and count registrations.
#' @param ... One or more unquoted variable names to register.
#' @param remove Logical; if \code{TRUE}, remove the count registration for the
#'   named variables instead of adding it.
#' @param clear.all Logical; if \code{TRUE}, clear count registrations on every
#'   data frame that carries them.
#' @return \code{invisible(NULL)}. Called for its side effect on the session
#'   registration notebook.
#' @seealso \code{\link{jnumeric}}, \code{\link{jdummy}}
#' @examples
#' df <- data.frame(arrests = c(0, 1, 2, 0, 3, 1, 0, 12),
#'                  age      = c(21, 34, 45, 29, 51, 38, 26, 60))
#' jcount(df, arrests)                 # treat as a count (here 0-12)
#' jcount(df, arrests, remove = TRUE)
#' jcount()                            # list all registrations
#' jcount(df, NULL)                    # clear df's count registrations
#' jcount(clear.all = TRUE)            # clear every frame's count registrations
#' @export
jcount <- function(data, ..., remove = FALSE, clear.all = FALSE) {
  # jcount(clear.all = TRUE): clear count registrations on every frame.
  if (isTRUE(clear.all)) return(.jst_handle_clear("count", clear.all = TRUE))
  # jcount() with no arguments: show the session-wide registry status.
  if (missing(data) && ...length() == 0L) return(.jst_registry_status())
  raw_data <- if (!missing(data)) substitute(data) else NULL
  # jcount(NULL): clear the default frame (or the sole registered frame, or
  # ask) -- never a silent all-frames wipe (use clear.all = TRUE for that).
  if (!missing(data) && is.null(raw_data)) {
    return(.jst_handle_clear("count",
             default_name = getOption(".jst_default_data", default = NULL)))
  }

  arg1 <- .jst_resolve_first_arg(
    data_sub      = substitute(data),
    data_missing  = missing(data),
    fn_name       = "jcount",
    envir         = parent.frame(),
    accept_vector = FALSE
  )
  data         <- arg1$data
  data_name    <- arg1$name
  default_used <- arg1$mode %in% c("default", "symbol_with_default")

  variables <- rlang::enquos(...)
  if (arg1$mode == "symbol_with_default") {
    extra_quo <- rlang::new_quosure(arg1$first_arg_sub, env = parent.frame())
    variables <- c(list(extra_quo), variables)
    class(variables) <- "quosures"
  }
  # jcount(data, NULL): clear this frame's count registrations.
  if (length(variables) == 1L && rlang::quo_is_null(variables[[1]])) {
    return(.jst_handle_clear("count", explicit_frame = data_name))
  }
  if (length(variables) == 0) {
    .jst_stop("Specify one or more variables to register, e.g. ",
         "jcount(", data_name, ", <var1>, <var2>).")
  }
  var_names <- vapply(variables, rlang::quo_name, character(1))

  .jst_register_intent("count", data, data_name, default_used,
                       var_names, remove)
}


#' Register variables as Likert (ordered response) items
#'
#' \code{jlikert()} declares one or more value-labelled variables as Likert
#' items -- ordered response scales (for example 1 = Strongly disagree through
#' 5 = Strongly agree). It is the ordered-scale counterpart to
#' \code{\link{jdummy}} (categorical), \code{\link{jnumeric}} (continuous), and
#' \code{\link{jcount}} (count): a variable carries exactly one registered
#' intent at a time, so registering it as Likert clears any prior numeric,
#' count, or dummy registration on it.
#'
#' \strong{Scope -- display only.} The Likert intent refines reporting, not
#' analysis. It sets the variable's sub-class to "Likert" in
#' \code{\link{jscreen}}'s Variable Types table, marking it as an ordered scale
#' rather than a generic N-category variable. It does NOT change how any
#' analysis treats the variable (there is no order-aware modelling), and it does
#' not by itself change \code{\link{jplot}} output -- a value-labelled
#' small-range variable already plots as an ordered, labelled bar regardless of
#' this registration.
#'
#' Like the other registration verbs, registrations are session-scoped and keyed
#' by data-frame name; save the frame in R format (.rds) with
#' \code{\link{jsave}} to keep them across sessions.
#'
#' @param data A data frame, or omitted to use the \code{\link{juse}} default.
#' @param ... One or more unquoted variable names to register, or a single
#'   \code{NULL} to clear this frame's Likert registrations (see Details).
#' @param remove Logical; if TRUE, remove the named variables' Likert
#'   registrations instead of adding them.
#' @param clear.all Logical; if TRUE, clear Likert registrations on every data
#'   frame.
#'
#' @details
#' Clearing mirrors the other registration verbs:
#' \itemize{
#'   \item \code{jlikert(data, NULL)} -- clear this frame's Likert
#'     registrations.
#'   \item \code{jlikert(NULL)} -- clear the \code{juse()} default frame (or the
#'     sole frame carrying Likert registrations; if several do, it asks rather
#'     than clearing them all).
#'   \item \code{jlikert(clear.all = TRUE)} -- clear every frame.
#' }
#' \code{jlikert()} with no arguments prints the current registration status.
#'
#' @return Invisibly NULL. Called for its side effect on the session registry.
#' @examples
#' \donttest{
#'   jlikert(community, Environment1, Environment2)  # declare two Likert items
#'   jscreen(community)                              # Sub-class shows "Likert"
#'   jlikert(community, Environment1, remove = TRUE) # undo one
#'   jlikert(community, NULL)                        # clear the registrations
#' }
#' @seealso \code{\link{jnumeric}}, \code{\link{jcount}}, \code{\link{jdummy}},
#'   \code{\link{jscreen}}
#' @export
jlikert <- function(data, ..., remove = FALSE, clear.all = FALSE) {
  # jlikert(clear.all = TRUE): clear Likert registrations on every frame.
  if (isTRUE(clear.all)) return(.jst_handle_clear("likert", clear.all = TRUE))
  # jlikert() with no arguments: show the session-wide registry status.
  if (missing(data) && ...length() == 0L) return(.jst_registry_status())
  raw_data <- if (!missing(data)) substitute(data) else NULL
  # jlikert(NULL): clear the default frame (or the sole registered frame, or
  # ask) -- never a silent all-frames wipe (use clear.all = TRUE for that).
  if (!missing(data) && is.null(raw_data)) {
    return(.jst_handle_clear("likert",
             default_name = getOption(".jst_default_data", default = NULL)))
  }

  arg1 <- .jst_resolve_first_arg(
    data_sub      = substitute(data),
    data_missing  = missing(data),
    fn_name       = "jlikert",
    envir         = parent.frame(),
    accept_vector = FALSE
  )
  data         <- arg1$data
  data_name    <- arg1$name
  default_used <- arg1$mode %in% c("default", "symbol_with_default")

  variables <- rlang::enquos(...)
  if (arg1$mode == "symbol_with_default") {
    extra_quo <- rlang::new_quosure(arg1$first_arg_sub, env = parent.frame())
    variables <- c(list(extra_quo), variables)
    class(variables) <- "quosures"
  }
  # jlikert(data, NULL): clear this frame's Likert registrations.
  if (length(variables) == 1L && rlang::quo_is_null(variables[[1]])) {
    return(.jst_handle_clear("likert", explicit_frame = data_name))
  }
  if (length(variables) == 0) {
    .jst_stop("Specify one or more variables to register, e.g. ",
         "jlikert(", data_name, ", <var1>, <var2>).")
  }
  var_names <- vapply(variables, rlang::quo_name, character(1))

  .jst_register_intent("likert", data, data_name, default_used,
                       var_names, remove)
}
