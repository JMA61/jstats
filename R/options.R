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
      cat("Reset to defaults (standard, no toggle overrides).\n\n")
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

# -- Internal: print current joptions() status --------------------------------
#
# Reads slot values from options() with fallback to .jst_options_defaults
# and prints the Options Settings panel. Called at the end of every
# joptions() call (including reset).

#' @keywords internal
.jst_options_status <- function() {
  mc <- getOption(".jst_options_missing_convention",
                  .jst_options_defaults$missing.convention)
  cc <- getOption(".jst_options_udm_convention_codes",
                  .jst_options_defaults$udm.convention.codes)
  dd <- getOption(".jst_options_data_dir",
                  .jst_options_defaults$data.dir)
  cl <- getOption(".jst_options_corr_layout",
                  .jst_options_defaults$corr.layout)

  # Map the slot value to a user-facing label. "none" reads as "None
  # selected" so users understand they're in the no-auto-conversion
  # default; "spss" / "stata" surface in their familiar capitalizations.
  mc_label <- switch(mc,
                     none  = "None selected",
                     spss  = "SPSS",
                     stata = "Stata",
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

  .cat_red("Options Settings\n")
  cat("User-defined missing values (UDMs) convention: ", mc_label,
      "\n", sep = "")
  cat("UDM convention codes: ", paste(cc, collapse = ", "), "\n", sep = "")
  cat("Data folder: ", dd_label, "\n", sep = "")
  cat("Correlation layout: ", cl, "\n", sep = "")
  cat("\n")
}


# -- Internal: globalenv() scan and one-line mismatch nudge -------------------
#
# Called by joptions() when missing.convention is set to "spss" or
# "stata". Scans globalenv() for data frames; for each, classifies each
# column's UDM convention via .jst_missing_info(); computes the DF's
# predominant convention; emits a one-line notice listing DFs whose
# predominant convention differs from target_convention. Silent when
# no mismatches.
#
# Classification rules (per locked design, Cross-cutting 3 Notes):
#   - Only columns with declared UDMs (SPSS-form na_values or Stata-form
#     tagged_na) count toward the predominant convention. Plain numeric
#     columns are ignored.
#   - Ties (equal SPSS- and Stata-form counts) cause the DF to be skipped.
#   - DFs with zero UDM-bearing columns are skipped (no predominant
#     convention to mismatch against).
#
# All mismatched DFs share the same predominant convention (the one
# opposite the newly-set target), so the message can group them.

#' @keywords internal
.jst_options_nudge <- function(target_convention) {
  env       <- globalenv()
  obj_names <- ls(envir = env)
  mismatched <- character(0)

  for (nm in obj_names) {
    obj <- tryCatch(get(nm, envir = env, inherits = FALSE),
                    error = function(e) NULL)
    if (!is.data.frame(obj)) next

    predominant <- .jst_predominant_convention(obj)
    if (is.na(predominant)) next

    if (predominant != target_convention) {
      mismatched <- c(mismatched, nm)
    }
  }

  if (length(mismatched) > 0L) {
    other_conv <- if (target_convention == "spss") "Stata" else "SPSS"
    verb       <- if (length(mismatched) == 1L) "uses" else "use"
    cat(sprintf("Note: %s predominantly %s %s-form user-defined missing values. Use jconvert() to align.\n",
                paste(mismatched, collapse = ", "),
                verb,
                other_conv))
  }

  invisible(NULL)
}


#' Set or display session-level package options
#'
#' Controls session-wide settings that affect how the package handles
#' missing-value information and related conventions. \code{joptions}
#' complements \code{\link{joutput}}: joutput governs output verbosity and
#' tiering, while joptions holds session-wide conventions plus a small number
#' of per-function display defaults (currently the \code{jcorr()} cell
#' layout). Settings are read fresh on each function call:
#' changing a setting after data has been loaded does not retroactively
#' transform data already in memory. \code{\link{jconvert}} is the
#' explicit transform path for data already in the workspace.
#'
#' @section Slots:
#' \describe{
#'   \item{missing.convention}{Character, length 1. One of \code{"none"},
#'     \code{"spss"}, or \code{"stata"}. Default: \code{"none"}.
#'     \code{"none"} preserves loaded data as-is (no automatic conversion
#'     between user-defined missing value (UDM) representations at load time). \code{"spss"} or
#'     \code{"stata"} opts into load-time auto-conversion via
#'     \code{\link{jload}}, and also supplies the target convention for
#'     fresh UDM declarations on columns with no existing convention.}
#'   \item{udm.convention.codes}{Numeric vector, length 1 to 3, whole
#'     numbers, no duplicates. Sign unconstrained. Default:
#'     \code{c(-99, -98, -97)}. The recommended UDM code set used
#'     by \code{\link{jconvert}} when translating Stata-style missing values
#'     (\code{.a}, \code{.b}, \code{.c}, \code{.d}) into SPSS-form
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
#' }
#'
#' @section Call patterns:
#' \describe{
#'   \item{\code{joptions()}}{Print the current settings panel.}
#'   \item{\code{joptions(NULL)}}{Reset all slots to defaults, then print
#'     the panel.}
#'   \item{\code{joptions(slot = value, ...)}}{Set one or more slots,
#'     then print the panel. Passing \code{slot = NULL} as a named
#'     argument leaves that slot at its current value -- useful for
#'     setting one slot without touching another. To reset a single
#'     slot to its default, pass the default value explicitly (e.g.
#'     \code{joptions(missing.convention = "none")}). Because
#'     \code{data.dir}'s default is \code{NULL} -- which already means
#'     "leave alone" -- it is cleared instead with \code{data.dir = ""}.}
#' }
#'
#' @section Environment-scan notice:
#' Setting \code{missing.convention} to \code{"spss"} or \code{"stata"}
#' triggers a one-time scan of \code{globalenv()} for data frames whose
#' predominant UDM convention differs from the newly-set value. When
#' mismatches exist, a one-line notice lists the affected data frames
#' and suggests \code{\link{jconvert}} for alignment. The notice is
#' informational; nothing is changed. Plain data frames with no
#' UDM-bearing columns -- including the course datasets in their
#' standard form -- do not trigger the notice.
#'
#' @param missing.convention One of \code{"none"}, \code{"spss"}, or
#'   \code{"stata"} (any capitalization is accepted). See Slots.
#' @param udm.convention.codes Numeric vector, length 1 to 3. See Slots.
#' @param data.dir Character string (length 1), or \code{NULL}. See Slots.
#' @param corr.layout One of \code{"wide"} or \code{"stacked"}, or
#'   \code{NULL}. See Slots.
#'
#' @return Invisibly returns \code{NULL}. Called for the side effect of
#'   updating session options and printing the status panel.
#'
#' @examples
#' joptions()                                        # show current settings
#' joptions(missing.convention = "spss")             # set, panel, nudge
#' joptions(udm.convention.codes = c(-99, -98))      # set, panel, no nudge
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
#'   change silently, suppressing both the status panel and the convention
#'   nudge. A bare joptions() status query always prints regardless of quiet.
joptions <- function(missing.convention = NULL, udm.convention.codes = NULL,
                     data.dir = NULL, corr.layout = NULL, quiet = FALSE) {
  # Validate TRUE/FALSE flags up front.
  .jst_check_flag(quiet, "quiet")

  mc_supplied <- !missing(missing.convention)
  cc_supplied <- !missing(udm.convention.codes)
  dd_supplied <- !missing(data.dir)
  cl_supplied <- !missing(corr.layout)

  # joptions() -- no args, status only
  if (!mc_supplied && !cc_supplied && !dd_supplied && !cl_supplied) {
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
        !(missing.convention %in% c("none", "spss", "stata"))) {
      .jst_stop_arg("joptions", "missing.convention", choices = c("none", "spss", "stata"))
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

  # Write -- only supplied non-NULL args; NULL means "leave alone"
  trigger_nudge <- FALSE
  if (mc_supplied && !is.null(missing.convention)) {
    options(.jst_options_missing_convention = missing.convention)
    if (missing.convention %in% c("spss", "stata")) trigger_nudge <- TRUE
  }
  if (cc_supplied && !is.null(udm.convention.codes)) {
    options(.jst_options_udm_convention_codes = udm.convention.codes)
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
  }
  if (cl_supplied && !is.null(corr.layout)) {
    options(.jst_options_corr_layout = corr.layout)
  }

  # Status panel, then nudge (per Session 28 Item 1 decision). quiet = TRUE
  # silences both -- a quiet call is fully quiet.
  if (!quiet) {
    .jst_options_status()
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
      message(
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
