#<<<FILE: options.R>>>


# -- joutput -------------------------------------------------------------------

#' Set session-level output verbosity
#'
#' Controls what analysis functions display by default. Three preset levels
#' are available, and individual toggles can override specific settings
#' within any level. Per-call arguments on analysis functions always take
#' precedence over joutput() settings.
#'
#' @param level Character. One of \code{minimal}, \code{standard}
#'   (default), or \code{full}. If omitted, prints the current settings.
#'   If \code{NULL}, resets to defaults (standard with no toggle overrides).
#'   \describe{
#'     \item{minimal}{Stripped-down output for power users. Core results
#'       only -- no Case Processing Summary, no variable labels, no
#'       reference categories, no effect sizes, no CIs.}
#'     \item{standard}{Default. Suitable for teaching and routine use.
#'       Includes Case Processing Summary, reference categories, effect
#'       sizes, and confidence intervals for means and mean differences
#'       (\code{jt}, \code{jaov}); regression coefficient CIs (\code{jlm},
#'       \code{jlogistic}) are reserved for full. Variable labels are off by
#'       default (\code{variable.id = "names"}); request a label legend or
#'       in-table labels per call or via the \code{variable.id} toggle.}
#'     \item{full}{Everything in standard plus a variable label legend
#'       (\code{variable.id = "legend"}), regression coefficient confidence
#'       intervals, assumption checks (Levene's
#'       test), post-hoc tests, regression diagnostics, and the most
#'       detailed Case Processing Summary (per-code missing breakdown).}
#'   }
#' @param effect.size Logical or NULL. Override the level's default for
#'   effect size display.
#' @param regression.ci Logical or NULL. Override the level's default for
#'   confidence intervals on regression coefficients (\code{jlm},
#'   \code{jlogistic}). Off at minimal and standard, on at full.
#' @param means.ci Logical or NULL. Override the level's default for
#'   confidence intervals on means and mean differences (\code{jt},
#'   \code{jaov}). Off at minimal, on at standard and full.
#' @param levene Logical or NULL. Override the level's default for
#'   Levene's test display.
#' @param posthoc Logical or NULL. Override the level's default for
#'   post-hoc test display (jaov only).
#' @param diagnostics Logical or NULL. Override the level's default for
#'   regression diagnostic output (jlm only).
#' @param case.processing Three-state toggle. \code{TRUE} forces the
#'   Case Processing Summary to print on every call. \code{FALSE}
#'   suppresses it on every call. \code{NULL} (the auto-suppress default
#'   at the standard tier) prints only when the call had something to
#'   report -- pipeline state was active (\code{jsubset},
#'   \code{jcomplete}, or per-call \code{subset}), listwise deletion
#'   excluded at least one case (in listwise functions like \code{jlm},
#'   \code{jt}), or a per-variable discrepancy notification fires (in
#'   \code{jdesc}/\code{jfreq}). The minimal tier sets this to
#'   \code{FALSE}; the full tier sets it to \code{TRUE}; the standard
#'   tier sets it to \code{NULL}.
#' @param case.processing.detail Detail tier for the Case Processing
#'   Summary's missing-data breakdown: \code{"none"} (no bottom
#'   table), \code{"totals"} (one summed missing row per variable),
#'   or \code{"per_code"} (per user-defined missing value code plus system-missing). The
#'   minimal tier defaults to \code{"none"}, standard to
#'   \code{"totals"}, full to \code{"per_code"}.
#' @param variable.id Character or NULL. Variable label display mode, one
#'   of \code{"both"}, \code{"names"}, \code{"labels"}, \code{"legend"}, or
#'   \code{"legend.bottom"}. \code{"names"} shows variable names only;
#'   \code{"both"} shows \code{"name: label"}, with
#'   no labels block. \code{"labels"} replaces variable names with their
#'   labels in the analysis output itself (table rows, captions, crosstab
#'   dimnames, or \code{jplot} axis/legend titles) -- best when labels
#'   are short. \code{"legend"} keeps names in place and prints a label
#'   legend at the function's mid position (for \code{jlm}/\code{jlogistic}
#'   between the coefficients and fit blocks; for \code{jfreq} under each
#'   variable's own table; elsewhere directly after the single table).
#'   \code{"legend.bottom"} keeps names in place and prints one
#'   consolidated legend at the very end of the output. The minimal and
#'   standard tiers default to \code{"none"}; the full tier defaults to
#'   \code{"legend"}. Not a logical -- \code{TRUE}/\code{FALSE} are not
#'   accepted.
#' @param value.id Character or NULL. Value-label display mode for the
#'   categorical levels that appear in \code{jfreq} valid rows, the
#'   \code{jt}/\code{jaov} group descriptives, the \code{jcrosstab} axes, and
#'   the grouped \code{jdesc} headers. One of \code{"both"} (\code{"code: label"},
#'   degrading to a bare code where a code has no label), \code{"values"} (the
#'   bare stored code), or \code{"labels"} (the value label, degrading to the
#'   bare code per code where none exists).
#'   \code{"legend"} and \code{"legend.bottom"} keep the bare code in the
#'   table and print a value-label legend after it (\code{"legend"}
#'   per-table, \code{"legend.bottom"} consolidated where multiple tables
#'   are produced). Variables with no value labels
#'   render identically under all three modes, so this is a no-op for plain
#'   numeric data. The minimal tier defaults to \code{"values"}; the standard
#'   and full tiers default to \code{"both"}. Distinct from
#'   \code{variable.id}, which governs the one-per-variable descriptive
#'   label. Not a logical.
#' @param ref.categories Logical or NULL. Override the level's default
#'   for the reference categories block (registered dummies).
#' @param udm.notice Logical or NULL. Controls the user-defined
#'   missing-value (UDM) notification emitted by \code{jload()} for
#'   files with UDM-bearing variables. \code{TRUE} prints it on every
#'   such load; \code{FALSE} suppresses it; \code{NULL} (the default)
#'   leaves the level's setting in place. The standard and full levels
#'   print it; the minimal level suppresses it.
#' @param digits Integer or NULL. Number of decimal places shown for
#'   continuous statistics in the analysis-function output tables
#'   (range 0-7; \code{digits = 0} prints whole numbers with no
#'   trailing decimal point). Does not affect p-values, percentages,
#'   or integer quantities (counts, N, degrees of freedom), which keep
#'   their own fixed conventions. All three preset levels default to 3.
#'
#' @return Invisibly returns NULL. Called for its side effect of setting
#'   session options.
#'
#' @examples
#' joutput("standard")                       # effect sizes + means/diff CIs (jt, jaov)
#' joutput("standard", regression.ci = TRUE) # also show jlm/jlogistic coefficient CIs
#' joutput("full")                         # everything
#' joutput()                               # show current settings
#' joutput(NULL)                           # reset to defaults
#'
#' @seealso \code{\link{jstats}} for the package overview,
#'   workflow conventions, and complete function listing.
#'
#' @export
#' @param quiet Logical; default FALSE. When TRUE, joutput() applies the
#'   level/toggle change silently (the status panel is not printed). A bare
#'   joutput() status query always prints regardless of quiet.
joutput <- function(level, effect.size = NULL,
                    regression.ci = NULL, means.ci = NULL, levene = NULL,
                    posthoc = NULL, diagnostics = NULL,
                    case.processing = NULL, case.processing.detail = NULL,
                    variable.id = NULL, value.id = NULL,
                    ref.categories = NULL, udm.notice = NULL,
                    digits = NULL, quiet = FALSE) {
  # Validate TRUE/FALSE flags up front (display toggles also accept
  # NULL, meaning defer to joutput()).
  .jst_check_flag(quiet, "quiet")
  .jst_check_flag(effect.size, "effect.size", null.ok = TRUE)
  .jst_check_flag(regression.ci, "regression.ci", null.ok = TRUE)
  .jst_check_flag(means.ci, "means.ci", null.ok = TRUE)
  .jst_check_flag(levene, "levene", null.ok = TRUE)
  .jst_check_flag(posthoc, "posthoc", null.ok = TRUE)
  .jst_check_flag(diagnostics, "diagnostics", null.ok = TRUE)
  .jst_check_flag(case.processing, "case.processing", null.ok = TRUE)
  .jst_check_flag(ref.categories, "ref.categories", null.ok = TRUE)
  .jst_check_flag(udm.notice, "udm.notice", null.ok = TRUE)

  valid_levels <- c("minimal", "standard", "full")

  # joutput(NULL) -- reset to defaults
  if (!missing(level) && is.null(level)) {
    options(.jst_output_level = NULL)
    options(.jst_output_toggles = NULL)
    if (!quiet) {
      .cat_red("Output Settings\n")
      .jst_msg_out("Reset to defaults (standard, no toggle overrides).")
      cat("\n")
    }
    return(invisible(NULL))
  }

  # Collect any explicit toggle overrides
  toggle_args <- list()
  if (!is.null(effect.size))     toggle_args$effect.size     <- effect.size
  if (!is.null(regression.ci))   toggle_args$regression.ci   <- regression.ci
  if (!is.null(means.ci))        toggle_args$means.ci        <- means.ci
  if (!is.null(levene))          toggle_args$levene          <- levene
  if (!is.null(posthoc))         toggle_args$posthoc         <- posthoc
  if (!is.null(diagnostics))     toggle_args$diagnostics     <- diagnostics
  if (!is.null(case.processing)) toggle_args$case.processing <- case.processing
  if (!is.null(case.processing.detail)) {
    if (!is.character(case.processing.detail) ||
        length(case.processing.detail) != 1 ||
        !(case.processing.detail %in% c("none", "totals", "per_code"))) {
      .jst_stop_arg("joutput", "case.processing.detail", choices = c("none", "totals", "per_code"))
    }
    toggle_args$case.processing.detail <- case.processing.detail
  }
  if (!is.null(variable.id)) {
    if (!is.character(variable.id) || length(variable.id) != 1 ||
        !(variable.id %in% c("both", "names", "labels", "legend", "legend.bottom"))) {
      .jst_stop_arg("joutput", "variable.id", choices = c("both", "names", "labels", "legend", "legend.bottom"))
    }
    toggle_args$variable.id <- variable.id
  }
  if (!is.null(value.id)) {
    if (!is.character(value.id) || length(value.id) != 1 ||
        !(value.id %in% c("both", "values", "labels", "legend", "legend.bottom"))) {
      .jst_stop_arg("joutput", "value.id", choices = c("both", "values", "labels", "legend", "legend.bottom"))
    }
    toggle_args$value.id <- value.id
  }
  if (!is.null(ref.categories))  toggle_args$ref.categories  <- ref.categories
  if (!is.null(udm.notice))      toggle_args$udm.notice      <- udm.notice
  if (!is.null(digits)) {
    if (length(digits) != 1L || is.na(digits) ||
        !is.numeric(digits) || digits != as.integer(digits) ||
        digits < 0L || digits > 7L) {
      .jst_stop_arg("joutput", "digits", "a single whole number between 0 and 7.")
    }
    toggle_args$digits <- as.integer(digits)
  }

  # joutput() with no level argument -- show status or apply toggles only
  if (missing(level)) {
    if (length(toggle_args) > 0) {
      # Apply toggle overrides to current settings
      current_toggles <- getOption(".jst_output_toggles", list())
      for (nm in names(toggle_args)) current_toggles[[nm]] <- toggle_args[[nm]]
      options(.jst_output_toggles = current_toggles)
      # A toggle change respects quiet.
      if (!quiet) .jst_output_status()
    } else {
      # A bare joutput() query always prints, regardless of quiet.
      .jst_output_status()
    }
    return(invisible(NULL))
  }

  # Validate level
  if (!is.character(level) || length(level) != 1 || !(level %in% valid_levels)) {
    .jst_stop_arg("joutput", "level", choices = c("minimal", "standard", "full"))
  }

  # Set level and toggles
  options(.jst_output_level = level)
  if (length(toggle_args) > 0) {
    options(.jst_output_toggles = toggle_args)
  } else {
    options(.jst_output_toggles = NULL)
  }

  if (!quiet) .jst_output_status()
  invisible(NULL)
}

#' Internal helper: print current joutput() status
#'
#' @keywords internal
.jst_output_status <- function() {
  level   <- getOption(".jst_output_level", "standard")
  toggles <- getOption(".jst_output_toggles", list())

  .cat_red("Output Settings\n")
  cat("Level: ", level, "\n", sep = "")

  # Show effective value for each toggle
  toggle_names <- c("effect.size", "regression.ci", "means.ci", "levene",
                    "posthoc", "diagnostics",
                    "case.processing", "case.processing.detail",
                    "variable.id", "value.id", "ref.categories",
                    "udm.notice", "digits")
  defaults     <- .jst_output_defaults[[level]]

  for (nm in toggle_names) {
    default_val  <- defaults[[nm]]
    effective    <- if (nm %in% names(toggles)) toggles[[nm]] else default_val
    # (override) marks settings whose effective value differs from the tier
    # default -- i.e. an override with a visible effect. Setting a toggle back
    # to its tier default (even explicitly) is not flagged, since nothing is
    # actually overridden. identical() handles the NULL (AUTO) states cleanly.
    override_str <- if (!identical(effective, default_val)) " (override)" else ""

    # case.processing.detail carries a string tier (none/totals/per_code);
    # variable.id (none/labels/legend/legend.bottom) and value.id
    # (both/values/labels) likewise carry string tiers -- show the token,
    # not ON/OFF. digits is an integer (0-7) -- show the number. case.processing
    # and udm.notice support three states (TRUE/FALSE/NULL=AUTO); the remaining
    # toggles are binary.
    label <- if (nm %in% c("case.processing.detail", "variable.id",
                           "value.id")) {
      toupper(effective)
    } else if (nm == "digits") {
      as.character(effective)
    } else if (is.null(effective)) {
      "AUTO"
    } else if (isTRUE(effective)) {
      "ON"
    } else {
      "OFF"
    }

    cat("  ", nm, ": ", label, override_str, "\n", sep = "")
  }
  cat("\n")
}


# =============================================================================
#  joptions -- non-display session options
# =============================================================================

# -- Internal: joptions slot relatedness map ----------------------------------
#
# Which OTHER slots a setting call pulls into its echo. Strict test (S233
# design): B is related to A only if setting A changes how B behaves or how
# B's value should be read. Exactly one pair qualifies --
# missing.convention and udm.convention.codes, because the codes are the
# Stata-tag -> SPSS-code mapping set and are dormant off "spss", so the
# convention is what tells you how to read them. data.dir, corr.layout,
# missing.detail and message.width are singletons and are absent from the
# map entirely (missing.detail is a display tier, not convention-coupled;
# message.width governs prose rendering and is coupled to nothing here --
# a future table.width would be its partner, and this is where that pair
# would be declared).
#
# Only a slot actually WRITTEN pulls its partner. A named-NULL leave-alone
# call echoes the slot's own current value but changes nothing, so nothing
# has changed about how its partner should be read.

#' @keywords internal
.jst_options_related <- list(
  missing.convention   = "udm.convention.codes",
  udm.convention.codes = "missing.convention"
)


# -- Internal: print current joptions() status --------------------------------
#
# Reads slot values from options() with fallback to .jst_options_defaults
# and prints the Options Settings panel. Called at the end of every
# joptions() call (including reset).
#
# slots = NULL (the default) prints the FULL six-slot panel: the shape a
# bare joptions() status query wants, and the shape the joptions(NULL) reset
# wants because everything changed. A character vector of slot names instead
# prints a PARTIAL panel -- the same red title, only the named lines, then
# one trailing pointer at the full panel (S233: a setting call echoes what
# it touched, not the standing state). Canonical panel order and
# de-duplication are enforced here rather than at the call site, so callers
# may pass an unordered set with repeats; unrecognized names are ignored.

#' @keywords internal
.jst_options_status <- function(slots = NULL) {
  mc <- getOption(".jst_options_missing_convention",
                  .jst_options_defaults$missing.convention)
  cc <- getOption(".jst_options_udm_convention_codes",
                  .jst_options_defaults$udm.convention.codes)
  dd <- getOption(".jst_options_data_dir",
                  .jst_options_defaults$data.dir)
  cl <- getOption(".jst_options_corr_layout",
                  .jst_options_defaults$corr.layout)
  md <- getOption(".jst_options_missing_detail",
                  .jst_options_defaults$missing.detail)
  mw <- getOption(".jst_options_message_width",
                  .jst_options_defaults$message.width)

  # Map the slot value to a user-facing label. "none" reads as "None
  # selected" so users understand they're in the no-auto-conversion
  # default; "spss" / "stata" surface in their familiar capitalizations.
  mc_label <- switch(mc,
                     none  = "None selected",
                     spss  = "SPSS",
                     stata = "Stata",
                     sas   = "SAS",
                     mc)

  # data.dir: NULL displays as "Working directory" for parallelism with
  # the "None selected" reading of missing.convention. A set value
  # displays as-is; if that folder does not exist yet, annotate that it
  # will be created on first save. joptions() never creates the folder --
  # creation stays deferred to jsave's first write (Option C decision) --
  # so this note makes the pending side effect visible whenever the status
  # panel displays while the folder is still absent.
  dd_label <- if (is.null(dd)) {
    "Working directory"
  } else if (!dir.exists(dd)) {
    paste0(dd, " (will be created on first save)")
  } else {
    dd
  }

  # message.width: unlike corr.layout and missing.detail, whose tokens name
  # a SHAPE and print raw, a width token names a NUMBER the user cannot
  # otherwise see -- so the panel shows both. The panel already splits this
  # way: slots printing a raw token show it as typed ("wide", "per_code"),
  # slots rendering a PHRASE take sentence case ("None selected", "Working
  # directory"), and this is a phrase. "currently" in the auto form is doing
  # real work: the width tracks the console pane, so the number is a
  # snapshot that is true when printed and may not be a minute later.
  mw_cols <- .jst_resolve_width(slot = mw)
  mw_label <- if (identical(mw, "auto")) {
    paste0("Auto (currently ", mw_cols, ")")
  } else if (is.character(mw) && length(mw) == 1L && !is.na(mw) &&
             mw %in% names(.jst_width_tokens)) {
    paste0(toupper(substring(mw, 1L, 1L)), substring(mw, 2L),
           " (", mw_cols, ")")
  } else {
    as.character(mw_cols)
  }

  # Build every line first, named by slot, then subset. One construction
  # path serves both shapes, so a partial panel cannot word a line
  # differently from the full one; the vector's own order IS the canonical
  # panel order.
  panel_lines <- c(
    missing.convention   = paste0(
      "User-defined missing values (UDMs) convention: ", mc_label, "\n"),
    udm.convention.codes = paste0(
      "UDM convention codes: ", paste(cc, collapse = ", "), "\n"),
    data.dir             = paste0("Data folder: ", dd_label, "\n"),
    corr.layout          = paste0("Correlation layout: ", cl, "\n"),
    missing.detail       = paste0("Missing-value detail: ", md, "\n"),
    message.width        = paste0("Message width: ", mw_label, "\n")
  )

  partial <- !is.null(slots)
  if (partial) {
    # Select BY the canonical vector, not by the caller's vector: order and
    # duplicates in `slots` cannot reach the output.
    panel_lines <- panel_lines[names(panel_lines) %in% slots]
  }

  .cat_red("Options Settings\n")
  cat(panel_lines, sep = "")
  # The pointer emits from here rather than from joptions()'s tail so the
  # truncation and its explanation cannot drift apart. It CLOSES the panel
  # rather than trailing the whole emission: it explains the lines directly
  # above it, and closing here leaves the last line on screen for the
  # environment-scan notice's remedy whenever that fires.
  if (partial) .jst_msg_out("Run joptions() to see all settings.")
  cat("\n")
}


# -- Internal: globalenv() scan and mismatch nudge ----------------------------
#
# Called by joptions() when missing.convention is set to "spss",
# "stata", or "sas". Scans globalenv() for data frames; for each,
# classifies each column's UDM convention via .jst_convention_census();
# emits one notice per mismatch group (see below) listing DFs whose
# predominant convention differs from target_convention. Silent when
# no mismatches.
#
# Classification rules (per locked design, Cross-cutting 3 Notes;
# extended by Decision 13):
#   - Only columns with declared UDMs (SPSS-form na_values, or
#     tagged_na markers -- lowercase Stata-form / uppercase SAS-form)
#     count toward the predominant convention. Plain numeric columns
#     are ignored; mixed-case tagged columns classify as ambiguous
#     and are ignored (Decision 13).
#   - No strict plurality winner (a tie for the top count) causes the
#     DF to be skipped.
#   - DFs with zero countable UDM-bearing columns are skipped.
#
# Wording (S226 redraft): a DF whose countable columns are all one
# convention gets the plain verb ("uses") and the remedy "change"; a
# DF with a genuine internal majority keeps "predominantly" and the
# remedy "align". Mismatched DFs group by (convention, unanimity),
# one Note per group in fixed order (spss, stata, sas; unanimous
# before majority), a blank line between consecutive notes (Rule F),
# DF lists capped via .jst_format_var_list. No cross-DF comparison
# commentary -- each note states its group's convention and the fix.

#' @keywords internal
.jst_options_nudge <- function(target_convention) {
  env       <- globalenv()
  obj_names <- ls(envir = env)

  groups <- list()  # key "conv|unanimity" -> character vector of DF names

  for (nm in obj_names) {
    obj <- tryCatch(get(nm, envir = env, inherits = FALSE),
                    error = function(e) NULL)
    if (!is.data.frame(obj)) next

    census <- .jst_convention_census(obj)
    if (is.na(census$predominant)) next
    if (census$predominant == target_convention) next

    key <- paste0(census$predominant, "|",
                  if (census$unanimous) "u" else "m")
    groups[[key]] <- c(groups[[key]], nm)
  }

  if (length(groups) > 0L) {
    notes <- character(0)
    for (conv in c("spss", "stata", "sas")) {
      for (mode in c("u", "m")) {
        dfs <- groups[[paste0(conv, "|", mode)]]
        if (is.null(dfs)) next
        # S227: the note opens with an article and names the object kind
        # ("the community and small data frames use ...") rather than a
        # bare frame name. A frame name cannot be capitalized -- R is
        # case-sensitive -- so the old form opened mid-sentence and read
        # as a fragment; the article also teaches "data frame" in
        # passing. Lowercase after the "Note: " prefix, matching every
        # sibling note. Names are and-joined (Oxford at 3+); a truncated
        # list keeps its own "... and N more" tail.
        df_list <- .jst_format_var_list(dfs, and = TRUE)
        label   <- .jst_convention_label(conv)
        kind    <- if (length(dfs) == 1L) "data frame" else "data frames"
        # Rule E: the remedy is a second sentence and takes its own line.
        # (Non-conformance predating S227; fixed here at Jeff's direction
        # while the message was open.)
        #
        # S242 (mv R1): the remedy carries RUNNABLE jconvert() lines in
        # Rule L form -- the sibling notes (D2, D6, D7, the jload Case
        # 6/7 riders) all hand the user a pasteable call, and this one
        # named the function without one. Rule U's repeated-remedy cap
        # applies: one frame -> "run:" + one call; exactly two -> "run
        # both:" + one call each; three or more -> "run one call per
        # data frame:" + a SINGLE exemplar built from the first named
        # frame. The cap is what keeps a max_show = 10 frame list from
        # putting ten near-identical calls in one note, and it absorbs a
        # TRUNCATED list without special handling -- "one call per data
        # frame" is equally true of the named frames and the "... and N
        # more" tail.
        recipe_line <- function(nm) {
          paste0("  jconvert(", nm, ", to = \"", target_convention,
                 "\", modify = TRUE)")
        }
        if (length(dfs) == 1L) {
          intro <- "To convert it to match this setting, run:"
          calls <- recipe_line(dfs[1L])
        } else if (length(dfs) == 2L) {
          intro <- "To convert them to match this setting, run both:"
          calls <- paste(vapply(dfs, recipe_line, character(1)),
                         collapse = "\n")
        } else {
          intro <- paste0("To convert them to match this setting, run ",
                          "one call per data frame:")
          calls <- recipe_line(dfs[1L])
        }
        if (mode == "u") {
          verb <- if (length(dfs) == 1L) "uses" else "use"
        } else {
          verb <- if (length(dfs) == 1L) "predominantly uses"
                  else "predominantly use"
        }
        # Rule U adopt-on-touch (S242): the head sentence carries a
        # variable-length frame list (up to max_show = 10 names plus a
        # "... and N more" tail) and was emitted unwrapped -- a 12-frame
        # workspace put 130 characters on one line. The runnable lines
        # below it are NOT wrapped, per Rule U.
        head_txt <- sprintf("Note: the %s %s %s %s missing values.",
                            df_list, kind, verb, label)
        notes <- c(notes, paste0(.jst_wrap_prose(head_txt), "\n",
                                 intro, "\n", calls, "\n"))
      }
    }
    cat(paste(notes, collapse = "\n"))
  }

  invisible(NULL)
}


#' Set or display session-level package options
#'
#' Controls session-wide settings that affect how the package handles
#' missing-value information and related conventions. \code{joptions}
#' complements \code{\link{joutput}}: joutput governs output verbosity and
#' tiering, while joptions holds session-wide conventions plus a small number
#' of per-function display defaults (the \code{jcorr()} cell layout via
#' \code{corr.layout}, and the \code{jfreq()} missing-value range detail
#' via \code{missing.detail}), and the width at which runtime message prose
#' wraps (\code{message.width}). Settings are read fresh on each function call:
#' changing a setting after data has been loaded does not retroactively
#' transform data already in memory. \code{\link{jconvert}} is the
#' explicit transform path for data already in the workspace.
#'
#' @section Slots:
#' \describe{
#'   \item{missing.convention}{Character, length 1. One of \code{"none"},
#'     \code{"spss"}, \code{"stata"}, or \code{"sas"}. Default:
#'     \code{"none"}, meaning no stated preference: loaded data is
#'     preserved as-is and fresh user-defined missing value (UDM)
#'     declarations fall back to SPSS-style. A set value states your
#'     working convention: it supplies the target for fresh UDM
#'     declarations on columns with no existing convention, becomes the
#'     default target for \code{\link{jconvert}} when \code{to} is not
#'     given, and is the reference point for the environment-scan
#'     notice (see below). Data already loaded is never changed by
#'     setting this; \code{\link{jconvert}} is the explicit transform
#'     path.}
#'   \item{udm.convention.codes}{Numeric vector, length 1 to 3, whole
#'     numbers, no duplicates. Sign unconstrained. Default:
#'     \code{c(-99, -98, -97)}. The recommended UDM code set used
#'     by \code{\link{jconvert}} when translating Stata-style missing values
#'     (\code{.a}, \code{.b}, \code{.c}, \code{.d}) into SPSS-style
#'     numeric codes, and by the load-time diagnostic for
#'     convention-matched detection.}
#'   \item{data.dir}{Character string (length 1), or \code{NULL}. Default:
#'     \code{NULL}. When \code{NULL}, \code{\link{jsave}} writes
#'     bare-filename saves to the working directory and \code{\link{jload}}
#'     searches the working directory. When set, names a folder (relative
#'     to the working directory) used as both the save target for
#'     bare-filename saves and as the first directory searched on
#'     bare-filename loads. The folder is auto-created on first save if
#'     it doesn't already exist (nested paths are created in full).
#'     To clear a previously-set folder back to this default, pass
#'     \code{data.dir = ""} (an empty string); passing
#'     \code{data.dir = NULL} leaves the current setting unchanged
#'     (see Call patterns). Filenames containing a directory
#'     separator (\code{/}) bypass this setting and are taken literally.}
#'   \item{corr.layout}{Character, length 1. One of \code{"wide"} or
#'     \code{"stacked"}. Default: \code{"wide"}. The default cell layout for
#'     \code{\link{jcorr}} when three or more variables are correlated:
#'     \code{"wide"} puts r and p on one line with N beneath; \code{"stacked"}
#'     stacks r, p, and N on three lines for a narrower table that fits more
#'     variables. A per-call \code{layout} argument to \code{jcorr()}
#'     overrides this. It lives here rather than in \code{\link{joutput}}
#'     because it is specific to one function's output, not a tiered
#'     analysis-content toggle.}
#'   \item{missing.detail}{Character, length 1. One of \code{"totals"},
#'     \code{"per_code"}, or \code{"all"}. Default: \code{"per_code"}.
#'     Governs how much of a declared missing-value RANGE
#'     \code{\link{jfreq}} spells out in its Missing block.
#'     \code{"totals"} collapses the whole band into one row;
#'     \code{"per_code"} prints one row per observed in-band value, at
#'     most 10, with the remainder gathered into a single line at the
#'     foot of the block; \code{"all"} prints every observed in-band
#'     value with no cap. Declared discrete codes always print in full
#'     at every setting -- the cap applies only to values reached by a
#'     range. A per-call \code{missing.detail} argument to
#'     \code{jfreq()} overrides this. Like \code{corr.layout} it lives
#'     here rather than in \code{\link{joutput}} because it is specific
#'     to one function's output.}
#'   \item{message.width}{Character or numeric, length 1. One of
#'     \code{"auto"}, \code{"narrow"} (50 columns), \code{"medium"} (76),
#'     \code{"wide"} (90), or a whole number between 40 and 120. Default:
#'     \code{"medium"}. The target width at which the package wraps runtime
#'     MESSAGE prose -- errors, warnings and notes. \code{"auto"} follows the
#'     console pane, which R keeps current as the pane is resized, so it is
#'     resolved afresh for each message rather than fixed when it is set. A
#'     width outside 40 to 120 is refused rather than quietly adjusted.
#'     Analysis TABLES are not affected and do not reflow: prose can be
#'     re-wrapped without losing information, whereas breaking a correlation
#'     matrix mid-row would destroy the alignment that makes it readable.}
#' }
#'
#' @section Call patterns:
#' \describe{
#'   \item{\code{joptions()}}{Print the full settings panel.}
#'   \item{\code{joptions(NULL)}}{Reset all slots to defaults, then print
#'     the full panel -- everything changed.}
#'   \item{\code{joptions(slot = value, ...)}}{Set one or more slots, then
#'     echo only what the call touched: the slots named, plus
#'     \code{udm.convention.codes} whenever \code{missing.convention} is
#'     set and vice versa (the codes are read in light of the convention),
#'     closed by a pointer to \code{joptions()} for the full panel. The
#'     other three slots are independent and are not pulled in.
#'     Passing \code{slot = NULL} as a named
#'     argument leaves that slot at its current value -- useful for
#'     setting one slot without touching another -- and echoes that
#'     unchanged value back. To reset a single
#'     slot to its default, pass the default value explicitly (e.g.
#'     \code{joptions(missing.convention = "none")}). Because
#'     \code{data.dir}'s default is \code{NULL} -- which already means
#'     "leave alone" -- it is cleared instead with \code{data.dir = ""}.}
#' }
#'
#' @section Environment-scan notice:
#' Setting \code{missing.convention} to \code{"spss"}, \code{"stata"},
#' or \code{"sas"} triggers a one-time scan of \code{globalenv()} for
#' data frames whose UDM convention differs from the newly-set value.
#' When mismatches exist, a notice lists the affected data frames and
#' suggests \code{\link{jconvert}}: frames whose declared columns all
#' carry one convention read "use X-style missing values", while
#' frames with a genuine internal majority read "predominantly use".
#' The notice is informational; nothing is changed. Plain data frames
#' with no UDM-bearing columns -- including the course datasets in
#' their standard form -- do not trigger the notice.
#'
#' @param missing.convention One of \code{"none"}, \code{"spss"},
#'   \code{"stata"}, or \code{"sas"} (any capitalization is accepted).
#'   See Slots.
#' @param udm.convention.codes Numeric vector, length 1 to 3. See Slots.
#' @param data.dir Character string (length 1), or \code{NULL}. See Slots.
#' @param corr.layout One of \code{"wide"} or \code{"stacked"}, or
#'   \code{NULL}. See Slots.
#' @param missing.detail One of \code{"totals"}, \code{"per_code"}, or
#'   \code{"all"}, or \code{NULL}. See Slots.
#' @param message.width One of \code{"auto"}, \code{"narrow"},
#'   \code{"medium"}, \code{"wide"}, a whole number between 40 and 120,
#'   or \code{NULL}. See Slots.
#'
#' @return Invisibly returns \code{NULL}. Called for the side effect of
#'   updating session options and printing the settings panel -- in full
#'   for a status query or a reset, or as an echo of the slots a setting
#'   call touched.
#'
#' @examples
#' joptions()                                        # show current settings
#'
#' # Setting a convention echoes the convention and its codes, then scans
#' # the workspace and notes any data frames whose UDM convention differs
#' # (see the Environment-scan notice section):
#' joptions(missing.convention = "spss")             # set, echo, scan notice
#' joptions(missing.convention = "sas")              # SAS-style: .A, .B, ...
#' joptions(udm.convention.codes = c(-99, -98))      # set, echo, no scan
#' joptions(data.dir = "Data")                       # set save/load folder
#' joptions(missing.convention = "stata",
#'          udm.convention.codes = c(-99, -98, -97)) # set both
#' joptions(missing.convention = "spss",
#'          udm.convention.codes = NULL)             # set mc, leave codes
#' joptions(NULL)                                    # reset all to defaults
#'
#' @seealso \code{\link{joutput}} for output-verbosity settings;
#'   \code{\link{jstats}} for the package overview.
#'
#' @export
#' @param quiet Logical; default FALSE. When TRUE, joptions() applies the
#'   change silently, suppressing the settings echo, its pointer, and the
#'   convention nudge alike. A bare joptions() status query always prints
#'   regardless of quiet.
joptions <- function(missing.convention = NULL, udm.convention.codes = NULL,
                     data.dir = NULL, corr.layout = NULL,
                     missing.detail = NULL, message.width = NULL,
                     quiet = FALSE) {
  # Validate TRUE/FALSE flags up front.
  .jst_check_flag(quiet, "quiet")

  mc_supplied <- !missing(missing.convention)
  cc_supplied <- !missing(udm.convention.codes)
  dd_supplied <- !missing(data.dir)
  cl_supplied <- !missing(corr.layout)
  md_supplied <- !missing(missing.detail)
  mw_supplied <- !missing(message.width)

  # joptions() -- no args, status only
  if (!mc_supplied && !cc_supplied && !dd_supplied && !cl_supplied &&
      !md_supplied && !mw_supplied) {
    .jst_options_status()
    return(invisible(NULL))
  }

  # Distinguish joptions(NULL) (reset all) from joptions(slot = NULL)
  # (leave that slot alone). The reset call has a single positional NULL
  # argument; match.call() would have rewritten that to
  # joptions(missing.convention = NULL) and erased the distinction, so
  # we inspect sys.call() directly. Detected shape: exactly one supplied
  # argument, unnamed in the source call, and NULL in value.
  call_args <- as.list(sys.call())[-1L]
  # Ignore a named quiet = ... when detecting the reset shape, so
  # joptions(NULL, quiet = TRUE) is still recognized as a (quiet) reset
  # rather than read as two arguments.
  arg_names <- names(call_args)
  if (!is.null(arg_names)) call_args <- call_args[arg_names != "quiet"]
  positional_null_reset <- length(call_args) == 1L &&
                           (is.null(names(call_args)) ||
                            names(call_args) == "") &&
                           is.null(call_args[[1L]])

  # joptions(NULL) -- reset all
  if (positional_null_reset) {
    options(.jst_options_missing_convention   = NULL)
    options(.jst_options_udm_convention_codes = NULL)
    options(.jst_options_data_dir             = NULL)
    options(.jst_options_corr_layout          = NULL)
    options(.jst_options_missing_detail       = NULL)
    options(.jst_options_message_width        = NULL)
    if (!quiet) .jst_options_status()
    return(invisible(NULL))
  }

  # Validate (atomic) -- all checks pass before any options() write
  if (mc_supplied && !is.null(missing.convention)) {
    # Platform specs are case-insensitive (accept "SPSS", "Stata", ...).
    if (is.character(missing.convention) &&
        length(missing.convention) == 1L && !is.na(missing.convention)) {
      missing.convention <- tolower(missing.convention)
    }
    if (!is.character(missing.convention) ||
        length(missing.convention) != 1L ||
        !(missing.convention %in% c("none", "spss", "stata", "sas"))) {
      .jst_stop_arg("joptions", "missing.convention",
                    choices = c("none", "spss", "stata", "sas"))
    }
  }
  if (cc_supplied && !is.null(udm.convention.codes)) {
    x <- udm.convention.codes
    if (!is.numeric(x))
      .jst_stop_arg("joptions", "udm.convention.codes", "numeric.")
    if (length(x) < 1L || length(x) > 3L)
      .jst_stop("udm.convention.codes must have length 1 to 3.", fn = "joptions")
    if (anyNA(x) || !all(x == round(x)))
      .jst_stop("udm.convention.codes must contain only whole numbers.")
    if (anyDuplicated(x) > 0L)
      .jst_stop("udm.convention.codes must contain no duplicates.")
  }
  if (dd_supplied && !is.null(data.dir)) {
    if (!is.character(data.dir) ||
        length(data.dir) != 1L ||
        is.na(data.dir)) {
      .jst_stop('data.dir must be a single character string, NULL, or "". ',
           '(Use "" to clear the folder, NULL to leave it unchanged.)')
    }
    # Guard the literal "NULL" string -- almost always a typo for one of
    # the two real tokens. Case-sensitive, so a genuine folder named
    # "null" (lowercase) is still permitted.
    if (identical(trimws(data.dir), "NULL")) {
      .jst_stop('data.dir = "NULL" looks like a typo. To clear the data folder ',
           'back to the working directory, use data.dir = "" (empty quotes); ',
           'to leave it unchanged, use data.dir = NULL (no quotes).')
    }
  }
  if (cl_supplied && !is.null(corr.layout)) {
    if (!is.character(corr.layout) ||
        length(corr.layout) != 1L ||
        !(corr.layout %in% c("wide", "stacked"))) {
      .jst_stop_arg("joptions", "corr.layout", choices = c("wide", "stacked"))
    }
  }
  if (md_supplied && !is.null(missing.detail)) {
    if (!is.character(missing.detail) ||
        length(missing.detail) != 1L ||
        !(missing.detail %in% c("totals", "per_code", "all"))) {
      .jst_stop_arg("joptions", "missing.detail",
                    choices = c("totals", "per_code", "all"))
    }
  }
  if (mw_supplied && !is.null(message.width)) {
    # Validate by RESOLVING: one implementation of the five accepted forms
    # and the band, shared with the read path, so the two cannot drift.
    # The resolved number is discarded -- the slot stores the TOKEN, so
    # "auto" stays live and re-reads the pane on every message.
    invisible(.jst_resolve_width(per_call = message.width,
                                 arg = "message.width", fn = "joptions"))
  }

  # Write -- only supplied non-NULL args; NULL means "leave alone"
  trigger_nudge <- FALSE
  # Slots actually SET, accumulated as they are written rather than
  # re-derived afterwards: the echo's map pull keys off this, and a
  # re-derivation would have to restate every condition below.
  written       <- character(0)
  if (mc_supplied && !is.null(missing.convention)) {
    options(.jst_options_missing_convention = missing.convention)
    written <- c(written, "missing.convention")
    if (missing.convention %in% c("spss", "stata", "sas")) trigger_nudge <- TRUE
  }
  if (cc_supplied && !is.null(udm.convention.codes)) {
    options(.jst_options_udm_convention_codes = udm.convention.codes)
    written <- c(written, "udm.convention.codes")
  }
  if (dd_supplied && !is.null(data.dir)) {
    # "" (empty or whitespace-only) clears the slot back to its NULL
    # default (working directory); any other string sets the folder.
    # NULL never reaches here -- the !is.null gate above leaves it alone.
    if (nchar(trimws(data.dir)) == 0L) {
      options(.jst_options_data_dir = NULL)
    } else {
      options(.jst_options_data_dir = data.dir)
      .jst_data_dir_case_warning(data.dir)
    }
    written <- c(written, "data.dir")
  }
  if (cl_supplied && !is.null(corr.layout)) {
    options(.jst_options_corr_layout = corr.layout)
    written <- c(written, "corr.layout")
  }
  if (md_supplied && !is.null(missing.detail)) {
    options(.jst_options_missing_detail = missing.detail)
    written <- c(written, "missing.detail")
  }
  if (mw_supplied && !is.null(message.width)) {
    options(.jst_options_message_width = message.width)
    written <- c(written, "message.width")
  }

  # Partial panel, then nudge. S233 revisit of the Session 28 Item 1
  # full-panel-on-every-call decision: a setting call now echoes only what
  # it touched, so the change is visible against the standing state instead
  # of buried in it. The echo names every slot the call SUPPLIED --
  # including a named-NULL leave-alone, which echoes its current value back
  # under the no-change-detection principle -- plus the map partner of
  # every slot actually WRITTEN. .jst_options_status() imposes canonical
  # order and drops duplicates, so this set may be unordered.
  #
  # Ordering consequence, and the point of the change: with the echo down
  # to one or two lines, the nudge lands directly beneath the setting that
  # triggered it rather than five lines below it.
  #
  # quiet = TRUE silences panel, pointer and nudge alike -- a quiet call is
  # fully quiet.
  if (!quiet) {
    supplied <- c(if (mc_supplied) "missing.convention",
                  if (cc_supplied) "udm.convention.codes",
                  if (dd_supplied) "data.dir",
                  if (cl_supplied) "corr.layout",
                  if (md_supplied) "missing.detail",
                  if (mw_supplied) "message.width")
    .jst_options_status(c(supplied,
                          unlist(.jst_options_related[written],
                                 use.names = FALSE)))
    if (trigger_nudge) .jst_options_nudge(missing.convention)
  }

  invisible(NULL)
}

#' Return the configured data folder
#'
#' Read-side companion to \code{\link{joptions}(data.dir = ...)}: returns the
#' currently configured data folder as a string, for use in scripts that need
#' the path itself (building a file path, checking existence, cleaning up test
#' files) without reaching into package-internal option names.
#'
#' \code{joptions()} prints the folder but returns \code{invisible(NULL)};
#' \code{jdata_dir()} returns it as a value. When no folder is configured, the
#' \code{default} is returned (\code{"."}, the working directory, by default),
#' so the result drops straight into \code{\link{file.path}}. Pass
#' \code{default = NULL} to detect the unconfigured state explicitly.
#'
#' @param default Value returned when no data folder is configured. Defaults
#'   to \code{"."} (the working directory).
#' @return A length-one character string (the configured folder, or
#'   \code{default}); or \code{default} unchanged when it is \code{NULL}.
#' @seealso \code{\link{joptions}} to set the folder; \code{\link{jload}} and
#'   \code{\link{jsave}}, which resolve files against it.
#' @examples
#' \dontrun{
#' joptions(data.dir = "Data")
#' jdata_dir()                                  # "Data"
#' f <- file.path(jdata_dir(), "community.rds") # build a path in that folder
#' if (file.exists(f)) file.remove(f)
#'
#' jdata_dir(default = NULL)                    # NULL if nothing configured
#' }
#' @export
jdata_dir <- function(default = ".") {
  dir <- getOption(".jst_options_data_dir", .jst_options_defaults$data.dir)
  if (is.null(dir)) default else dir
}

#' Internal: warn on a case-only collision between data.dir and an existing
#' folder
#'
#' @description
#' On a case-insensitive filesystem (Windows, and macOS by default), a
#' \code{data.dir} such as \code{"Data"} silently resolves onto an existing
#' folder of a different case (e.g. \code{"data"}); saves and loads then use
#' the existing folder, and a teardown aimed at the configured name could
#' remove the wrong one. This emits a note at set time when that collision is
#' detected. Case-sensitive filesystems (Linux) create a distinct folder and
#' are not warned, so the behaviour is intentionally non-uniform across
#' operating systems.
#'
#' @param dir Character(1). The data.dir value just set.
#'
#' @return Invisibly \code{NULL}; called for the message side effect.
#'
#' @keywords internal
.jst_data_dir_case_warning <- function(dir) {
  # Only a folder that already resolves on disk can collide. On a
  # case-sensitive filesystem a differently-cased name does not exist, so
  # dir.exists() is FALSE and nothing is warned.
  if (!isTRUE(dir.exists(dir))) return(invisible(NULL))

  parent <- dirname(dir)
  if (identical(parent, "")) parent <- "."
  want    <- basename(dir)
  entries <- tryCatch(
    list.dirs(parent, full.names = FALSE, recursive = FALSE),
    error = function(e) character(0)
  )

  # An exact-case match means no collision. A match only under tolower()
  # means the filesystem folded the case onto an existing, differently-cased
  # folder.
  if (!(want %in% entries)) {
    hit <- entries[tolower(entries) == tolower(want)]
    if (length(hit) > 0) {
      .jst_msg(
        "Note: data.dir was set to '", want, "', but a folder named '",
        hit[1], "' already exists and your filesystem treats the two as the ",
        "same folder. Saves and loads will use the existing '", hit[1],
        "'. To keep a separate folder, choose a name that differs by more ",
        "than letter case."
      )
    }
  }
  invisible(NULL)
}
