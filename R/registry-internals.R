#<<<FILE: registry-internals.R>>>


# -----------------------------------------------------------------------------
# Data pipeline helpers: jcomplete / jsubset storage and application
# These helpers manage per-dataset filter and complete-case settings,
# apply them in the correct order, and generate info-line messages.
# -----------------------------------------------------------------------------

#' Internal helper: get filter settings for a named data frame
#'
#' Looks up the \code{jsubset()} settings stored under the
#' \code{.jst_filter} option for a specific data frame name. Returns
#' \code{NULL} if no filter is set for that data frame.
#'
#' @param data_name Character string giving the data frame name to look
#'   up. If \code{NULL}, returns \code{NULL}.
#'
#' @return The stored filter settings list, or \code{NULL} if none.
#'
#' @keywords internal
.jst_get_filter <- function(data_name) {
  if (is.null(data_name) || length(data_name) != 1L ||
      is.na(data_name) || !nzchar(data_name)) return(NULL)
  all_filters <- getOption(".jst_filter", default = list())
  all_filters[[data_name]]
}

#' Internal helper: get complete-case settings for a named data frame
#'
#' Looks up the \code{jcomplete()} settings stored under the
#' \code{.jst_complete} option for a specific data frame name. Returns
#' \code{NULL} if no complete-case settings are stored for that data
#' frame.
#'
#' @param data_name Character string giving the data frame name to look
#'   up. If \code{NULL}, returns \code{NULL}.
#'
#' @return The stored complete-case settings list, or \code{NULL} if
#'   none.
#'
#' @keywords internal
.jst_get_complete <- function(data_name) {
  if (is.null(data_name) || length(data_name) != 1L ||
      is.na(data_name) || !nzchar(data_name)) return(NULL)
  all_complete <- getOption(".jst_complete", default = list())
  all_complete[[data_name]]
}

#' Internal helper: set filter settings for a named data frame
#'
#' Stores filter settings under the \code{.jst_filter} option, keyed by
#' data frame name. Used internally by \code{jsubset()}.
#'
#' @param data_name Character string giving the data frame name. If
#'   \code{NULL}, the call is a silent no-op.
#' @param settings A list of filter settings to store.
#'
#' @return \code{invisible(NULL)}. Called for its side effect on the
#'   \code{.jst_filter} option.
#'
#' @keywords internal
.jst_set_filter <- function(data_name, settings) {
  if (is.null(data_name) || length(data_name) != 1L ||
      is.na(data_name) || !nzchar(data_name)) return(invisible(NULL))
  all_filters <- getOption(".jst_filter", default = list())
  all_filters[[data_name]] <- settings
  options(.jst_filter = all_filters)
}

#' Internal helper: set complete-case settings for a named data frame
#'
#' Stores complete-case settings under the \code{.jst_complete} option,
#' keyed by data frame name. Used internally by \code{jcomplete()}.
#'
#' @param data_name Character string giving the data frame name. If
#'   \code{NULL}, the call is a silent no-op.
#' @param settings A list of complete-case settings to store.
#'
#' @return \code{invisible(NULL)}. Called for its side effect on the
#'   \code{.jst_complete} option.
#'
#' @keywords internal
.jst_set_complete <- function(data_name, settings) {
  if (is.null(data_name) || length(data_name) != 1L ||
      is.na(data_name) || !nzchar(data_name)) return(invisible(NULL))
  all_complete <- getOption(".jst_complete", default = list())
  all_complete[[data_name]] <- settings
  options(.jst_complete = all_complete)
}

#' Internal helper: report whether any data frame has an active filter
#'
#' Scans the \code{.jst_filter} option to see whether any data frame
#' has filter settings currently turned on. Used to drive informational
#' notes about filtering being active for some other dataset than the
#' one currently in use.
#'
#' @return Logical. \code{TRUE} if at least one data frame has an active
#'   filter setting; \code{FALSE} otherwise.
#'
#' @keywords internal
.jst_any_filter_active <- function() {
  all_filters <- getOption(".jst_filter", default = list())
  if (length(all_filters) == 0) return(FALSE)
  for (nm in names(all_filters)) {
    fs <- all_filters[[nm]]
    if (!is.null(fs) && isTRUE(fs$active)) return(TRUE)
  }
  FALSE
}

#' Internal helper: report whether any data frame has active complete-case settings
#'
#' Scans the \code{.jst_complete} option to see whether any data frame
#' has complete-case settings currently turned on. Used to drive
#' informational notes about complete-case handling being active for
#' some other dataset than the one currently in use.
#'
#' @return Logical. \code{TRUE} if at least one data frame has active
#'   complete-case settings; \code{FALSE} otherwise.
#'
#' @keywords internal
.jst_any_complete_active <- function() {
  all_complete <- getOption(".jst_complete", default = list())
  if (length(all_complete) == 0) return(FALSE)
  for (nm in names(all_complete)) {
    cs <- all_complete[[nm]]
    if (!is.null(cs) && isTRUE(cs$active)) return(TRUE)
  }
  FALSE
}

#' Internal helper: get registered dummy variables for a named data frame
#'
#' Looks up the \code{jdummy()} registrations stored under the
#' \code{.jst_dummy} option for a specific data frame name. Returns
#' \code{NULL} if no dummies are registered for that data frame.
#'
#' @param data_name Character string giving the data frame name to look
#'   up.
#'
#' @return The stored dummy-registration settings list, or \code{NULL}
#'   if none.
#'
#' @keywords internal
.jst_get_dummy <- function(data_name) {
  if (is.null(data_name) || length(data_name) != 1L ||
      is.na(data_name) || !nzchar(data_name)) return(NULL)
  all_dummy <- getOption(".jst_dummy", default = list())
  all_dummy[[data_name]]
}

#' Internal helper: set registered dummy variables for a named data frame
#'
#' Stores dummy registrations under the \code{.jst_dummy} option, keyed
#' by data frame name. Used internally by \code{jdummy()}.
#'
#' @param data_name Character string giving the data frame name.
#' @param settings A list of dummy registrations to store.
#'
#' @return \code{invisible(NULL)}. Called for its side effect on the
#'   \code{.jst_dummy} option.
#'
#' @keywords internal
.jst_set_dummy <- function(data_name, settings) {
  if (is.null(data_name) || length(data_name) != 1L ||
      is.na(data_name) || !nzchar(data_name)) return(invisible(NULL))
  all_dummy <- getOption(".jst_dummy", default = list())
  all_dummy[[data_name]] <- settings
  options(.jst_dummy = all_dummy)
}

#' Internal helper: get the intent registry for a named data frame
#'
#' Looks up the analysis-role intent records stored under the
#' \code{.jst_registry} option for a specific data frame name. This is the
#' general intent notebook for jnumeric()/jcount() registrations; it follows
#' the same session-option, frame-keyed model as \code{.jst_dummy} but is a
#' separate store, so the existing dummy consumers are unaffected. Records are
#' a named list keyed by variable name (lookup and replace are the dominant
#' operations), each a list with at least \code{kind} (one of "numeric" or
#' "count"; the slot is general enough for later facets such as centering).
#'
#' @param data_name Character string giving the data frame name to look up.
#' @return The stored intent records (a named list), or \code{NULL} if none.
#' @keywords internal
.jst_get_registry <- function(data_name) {
  if (is.null(data_name) || length(data_name) != 1L ||
      is.na(data_name) || !nzchar(data_name)) return(NULL)
  all_reg <- getOption(".jst_registry", default = list())
  all_reg[[data_name]]
}

#' Internal helper: set the intent registry for a named data frame
#'
#' Stores analysis-role intent records under the \code{.jst_registry} option,
#' keyed by data frame name. Used internally by the registration functions
#' (jnumeric, jcount).
#'
#' @param data_name Character string giving the data frame name.
#' @param settings A named list of intent records (keyed by variable name),
#'   or \code{NULL} to clear the registry for this frame.
#' @return \code{invisible(NULL)}. Called for its side effect on the
#'   \code{.jst_registry} option.
#' @keywords internal
.jst_set_registry <- function(data_name, settings) {
  if (is.null(data_name) || length(data_name) != 1L ||
      is.na(data_name) || !nzchar(data_name)) return(invisible(NULL))
  all_reg <- getOption(".jst_registry", default = list())
  all_reg[[data_name]] <- settings
  options(.jst_registry = all_reg)
}

#' Internal helper: look up a single variable's registered intent
#'
#' Returns the intent record for one variable in a named data frame, or
#' \code{NULL} if the variable has no registered intent. Consulted by the
#' classification resolver (tier 2) and by the registration functions.
#'
#' @param data_name Character string giving the data frame name.
#' @param var_name Character string giving the variable name.
#' @return The intent record (a list with at least \code{kind}), or
#'   \code{NULL}.
#' @keywords internal
.jst_get_intent <- function(data_name, var_name) {
  reg <- .jst_get_registry(data_name)
  if (is.null(reg)) return(NULL)
  reg[[var_name]]
}

#' Internal helper: bake classification registrations onto a frame for saving
#'
#' Gathers the active classification registrations for a named data frame --
#' the jnumeric/jcount intent records (the .jst_registry notebook) and the
#' jdummy registrations (the .jst_dummy registry) -- and attaches them to the
#' data frame as a single list-valued attribute (".jst_registrations") so they
#' travel inside an R native format (.rds) save. The original frame name is
#' recorded alongside as provenance only; it is informational and is NOT used
#' as the lookup key on load (jload re-keys under the name the frame is loaded
#' as, which is the name later analysis calls will reference). The attribute is
#' attached only when at least one registration exists, so a frame with none is
#' returned unchanged and saves without the attribute. Only the .rds format
#' carries arbitrary R attributes, so this is called only on the .rds save path.
#'
#' @param data A data frame.
#' @param data_name Character string giving the data frame name to look up in
#'   the two registries.
#' @return The data frame, with a ".jst_registrations" attribute attached when
#'   registrations exist, otherwise unchanged.
#' @keywords internal
.jst_bake_registrations <- function(data, data_name) {
  reg   <- .jst_get_registry(data_name)
  dummy <- .jst_get_dummy(data_name)
  if (is.null(reg) && is.null(dummy)) {
    return(data)
  }
  attr(data, ".jst_registrations") <- list(
    registry = reg,
    dummy    = dummy,
    origin   = data_name
  )
  data
}

#' Internal helper: refresh the registration notebook from a loaded frame
#'
#' On load, makes the session notebook for a frame name match what the file
#' carries (the file is the source of truth at load time). When the loaded
#' object carries baked registrations, they are written into the .jst_registry
#' and .jst_dummy notebooks under the load-time name, replacing any differing
#' in-session registrations already sitting under that name. When the loaded
#' object carries none -- a non-.rds file, an older .rds saved before this
#' feature existed, or freshly unregistered data -- any stale registrations
#' under the reused name are cleared. Returns a one-line note describing what
#' happened (or NULL when nothing changed), for the caller to emit subject to
#' its own quiet setting.
#'
#' @param obj_name Character string giving the name the frame is loaded as
#'   (jload's name= argument, or the file stem) -- the key the analysis
#'   functions will look the frame up by.
#' @param baked The ".jst_registrations" attribute read from the loaded object
#'   (a list with registry, dummy, and origin entries), or NULL when the object
#'   carried none.
#' @return A character note, or NULL when no notebook change was made.
#' @keywords internal
.jst_refresh_registrations <- function(obj_name, baked) {
  existing_reg   <- .jst_get_registry(obj_name)
  existing_dummy <- .jst_get_dummy(obj_name)
  had_existing   <- !is.null(existing_reg) || !is.null(existing_dummy)

  if (is.null(baked)) {
    # Loaded data carries no registrations: clear any stale notebook entry
    # sitting under this reused name. Silent when there was nothing to clear.
    if (had_existing) {
      .jst_set_registry(obj_name, NULL)
      .jst_set_dummy(obj_name, NULL)
      return(paste0(
        "Cleared the classification registrations you had set this session ",
        "for '", obj_name, "' (the loaded data carries none)."))
    }
    return(NULL)
  }

  # Loaded data carries registrations: make the notebook match the file.
  replaced <- had_existing &&
    (!identical(existing_reg, baked$registry) ||
       !identical(existing_dummy, baked$dummy))
  .jst_set_registry(obj_name, baked$registry)
  .jst_set_dummy(obj_name, baked$dummy)

  origin_note <- if (!is.null(baked$origin) &&
                     !identical(baked$origin, obj_name)) {
    paste0(" (saved under '", baked$origin, "')")
  } else {
    ""
  }
  if (replaced) {
    paste0("Restored the classification registrations saved with this file",
           origin_note, ", replacing different registrations you had set ",
           "this session for '", obj_name, "'.")
  } else {
    paste0("Restored the classification registrations saved with this file",
           origin_note, ".")
  }
}

#' Internal helper: note that registrations are not kept in a non-rds format
#'
#' Builds the loss-of-fidelity note emitted when a frame that has active
#' classification registrations is saved to a format other than R native
#' format (.rds). Parallels the label and missing-value loss notes: the data
#' write succeeds, but the registrations are dropped because only the .rds
#' format carries them. Returns NULL when the frame has no registrations, so
#' the note fires only when there is something to lose.
#'
#' @param ext The (lower-case) target file extension.
#' @param data_name Character string giving the data frame name to look up.
#' @return A character note, or NULL when the frame has no registrations.
#' @keywords internal
.jst_jsave_registration_loss_note <- function(ext, data_name) {
  reg   <- .jst_get_registry(data_name)
  dummy <- .jst_get_dummy(data_name)
  if (is.null(reg) && is.null(dummy)) {
    return(NULL)
  }
  paste0(
    "Note: classification registrations (jnumeric/jcount/jdummy) are not ",
    "kept in ", .jst_format_label(ext), " (.", ext, "); they persist only ",
    "in R format (.rds).")
}

#' Internal helper: human-readable label for a registered intent kind
#'
#' @param kind One of "numeric", "count", "dummy".
#' @param cap Logical; if TRUE, capitalize the first letter.
#' @return A character label.
#' @keywords internal
.jst_intent_label <- function(kind, cap = FALSE) {
  lab <- switch(kind, numeric = "numeric", count = "count",
                dummy = "dummy", likert = "Likert", kind)
  if (isTRUE(cap)) lab <- paste0(toupper(substring(lab, 1, 1)), substring(lab, 2))
  lab
}

#' Internal helper: clear one variable's dummy registration
#'
#' Removes the \code{.jst_dummy} entry for a single variable in a named data
#' frame, used to enforce mutual exclusion when the variable is re-registered
#' as numeric or count. Returns TRUE when an entry was actually removed (so the
#' caller can report the reclassification).
#'
#' @param data_name Character data-frame name.
#' @param var_name Character variable name.
#' @return Logical, invisibly: TRUE if a dummy entry was cleared.
#' @keywords internal
.jst_clear_dummy_var <- function(data_name, var_name) {
  ds <- .jst_get_dummy(data_name)
  if (is.null(ds) || length(ds) == 0) return(invisible(FALSE))
  keep <- !vapply(ds, function(r) identical(r$var_name, var_name), logical(1))
  if (all(keep)) return(invisible(FALSE))
  ds <- ds[keep]
  if (length(ds) == 0) ds <- NULL
  .jst_set_dummy(data_name, ds)
  invisible(TRUE)
}

#' Internal helper: block a dummy-registered variable from being an outcome
#'
#' LHS-scoped guard for the model functions (jlm / jlogistic / jaov / jt, and
#' future jpoisson / jnegbin). A variable the user registered with jdummy()
#' has been declared categorical-with-a-reference; using it as the response
#' is a category error, so this raises a stop() at DV resolution -- before any
#' IV/group handling. Scoped to the outcome only: a registered dummy is a
#' legitimate predictor (jlm / jlogistic) or grouping variable (jaov / jt),
#' so those uses are never touched. The remedy differs by family: jlogistic
#' points to 0/1 recoding (it needs a binary outcome); the others point to
#' clearing the registration (the variable is then read in its native form).
#'
#' @param data_name Character data-frame name (may be NULL for a bare frame).
#' @param dv_name Character name of the outcome (response) variable.
#' @param fn The calling user-facing function name, e.g. "jlm".
#'
#' @return \code{invisible(NULL)} when the outcome is not a registered dummy;
#'   otherwise signals an error and does not return.
#'
#' @keywords internal
.jst_check_dummy_outcome <- function(data_name, dv_name, fn) {
  ds <- .jst_get_dummy(data_name)
  if (is.null(ds) || length(ds) == 0L) return(invisible(NULL))
  is_dummy <- any(vapply(ds, function(r) identical(r$var_name, dv_name),
                         logical(1)))
  if (!is_dummy) return(invisible(NULL))
  dn <- if (is.null(data_name) || !nzchar(data_name)) "data" else data_name
  if (identical(fn, "jlogistic")) {
    .jst_stop(
      "'", dv_name, "' is registered as a dummy, and can't be an outcome ",
      "variable.\n",
      "To use it as the outcome, ensure 0/1 coding, for example:\n",
      "  ", dn, "$", dv_name, "R <- jrecode(", dn, ", ", dv_name,
        ", map = \"<oldval1>=0; <oldval2>=1\")",
      fn = fn
    )
  } else {
    .jst_stop(
      "'", dv_name, "' is registered as a dummy, and can't be an outcome ",
      "variable.\n",
      "Clear the registration to use the variable directly:\n",
      "  jdummy(", dn, ", ", dv_name, ", remove = TRUE)",
      fn = fn
    )
  }
}

#' Internal helper: clear one variable's intent-registry record
#'
#' Removes the \code{.jst_registry} record for a single variable in a named
#' data frame. Used by \code{jdummy()} to enforce mutual exclusion (a variable
#' that becomes a dummy drops any numeric/count registration).
#'
#' @param data_name Character data-frame name.
#' @param var_name Character variable name.
#' @return The kind that was cleared (character), or NULL if none, invisibly.
#' @keywords internal
.jst_clear_intent_var <- function(data_name, var_name) {
  reg <- .jst_get_registry(data_name)
  if (is.null(reg) || is.null(reg[[var_name]])) return(invisible(NULL))
  cleared <- reg[[var_name]]$kind
  reg[[var_name]] <- NULL
  if (length(reg) == 0) reg <- NULL
  .jst_set_registry(data_name, reg)
  invisible(cleared)
}

#' Internal helper: names of data frames carrying registrations of one kind
#'
#' Scans the relevant session store and returns the names of the data frames
#' that currently hold at least one registration of the requested kind:
#' \code{.jst_registry} for "numeric"/"count" (a frame qualifies if it has any
#' record of that kind), \code{.jst_dummy} for "dummy" (a frame qualifies if it
#' has any dummy registration). Used by the clear dispatcher to decide, when no
#' frame is named and no default is set, whether a bare clear is unambiguous.
#'
#' @param kind One of "numeric", "count", "dummy".
#' @return Character vector of data-frame names (possibly empty).
#' @keywords internal
.jst_frames_with_registrations <- function(kind) {
  if (identical(kind, "dummy")) {
    all_d <- getOption(".jst_dummy", default = list())
    nm <- names(all_d)[vapply(all_d, function(x) !is.null(x) && length(x) > 0,
                              logical(1))]
    return(if (is.null(nm)) character(0) else nm)
  }
  all_r <- getOption(".jst_registry", default = list())
  keep <- vapply(all_r, function(reg) {
    !is.null(reg) && length(reg) > 0 &&
      any(vapply(reg, function(r) identical(r$kind, kind), logical(1)))
  }, logical(1))
  nm <- names(all_r)[keep]
  if (is.null(nm)) character(0) else nm
}

#' Internal helper: clear one frame's registrations of one kind
#'
#' Removes the requested kind's registrations for a single named data frame and
#' returns the variable names that were cleared (empty when there were none).
#' "dummy" clears the frame's \code{.jst_dummy} entry; "numeric"/"count" remove
#' only the matching-kind records from the frame's \code{.jst_registry} entry,
#' leaving any records of the other kind in place.
#'
#' @param kind One of "numeric", "count", "dummy".
#' @param data_name Character data-frame name.
#' @return Character vector of cleared variable names (possibly empty).
#' @keywords internal
.jst_clear_one_frame <- function(kind, data_name) {
  if (identical(kind, "dummy")) {
    existing <- .jst_get_dummy(data_name)
    if (is.null(existing) || length(existing) == 0) return(character(0))
    cleared <- vapply(existing, function(r) r$var_name, character(1))
    .jst_set_dummy(data_name, NULL)
    return(unname(cleared))
  }
  reg <- .jst_get_registry(data_name)
  if (is.null(reg) || length(reg) == 0) return(character(0))
  is_kind <- vapply(reg, function(r) identical(r$kind, kind), logical(1))
  if (!any(is_kind)) return(character(0))
  cleared <- vapply(reg[is_kind], function(r) r$var_name, character(1))
  reg <- reg[!is_kind]
  if (length(reg) == 0) reg <- NULL
  .jst_set_registry(data_name, reg)
  unname(cleared)
}

#' Internal helper: the registration verb name for a kind
#'
#' @param kind One of "numeric", "count", "dummy".
#' @return The user-facing function name ("jnumeric"/"jcount"/"jdummy").
#' @keywords internal
.jst_clear_verb <- function(kind) {
  switch(kind, numeric = "jnumeric", count = "jcount", dummy = "jdummy",
         paste0("j", kind))
}

#' Internal helper: resolve and perform a registration clear
#'
#' The single decision point for clearing classification registrations, shared
#' by \code{jnumeric()}, \code{jcount()}, and \code{jdummy()} so the three verbs
#' behave identically. Three entry shapes feed it:
#' \itemize{
#'   \item \code{clear.all = TRUE} -- clear this kind on every data frame that
#'         carries it.
#'   \item \code{explicit_frame} set (the \code{verb(data, NULL)} form) -- clear
#'         this kind on that one frame.
#'   \item neither (the \code{verb(NULL)} form) -- clear the \code{juse()}
#'         default frame if one is set; otherwise clear the sole frame carrying
#'         this kind if exactly one does; otherwise stop and ask the user to
#'         name a frame or pass \code{clear.all = TRUE} (never a silent
#'         multi-frame wipe).
#' }
#' Messages are emitted here, not by the callers, so the wording stays uniform.
#'
#' @param kind One of "numeric", "count", "dummy".
#' @param clear.all Logical; clear every frame carrying this kind.
#' @param explicit_frame Character data-frame name for the \code{verb(data,
#'   NULL)} form, or NULL.
#' @param default_name The \code{juse()} default frame name, or NULL.
#' @return \code{invisible(NULL)}.
#' @keywords internal
.jst_handle_clear <- function(kind, clear.all = FALSE, explicit_frame = NULL,
                              default_name = NULL) {
  klab <- .jst_intent_label(kind)
  Klab <- .jst_intent_label(kind, cap = TRUE)

  report_one <- function(frame, cleared, default = FALSE) {
    tag <- if (isTRUE(default)) " (the default data frame)" else ""
    if (length(cleared) == 0) {
      message("No ", klab, " registrations to clear for ", frame, tag, ".")
    } else {
      message(Klab, " registrations cleared for ", frame, tag, ": ",
              paste(cleared, collapse = ", "), ".")
    }
  }

  # clear.all: every frame carrying this kind.
  if (isTRUE(clear.all)) {
    frames <- .jst_frames_with_registrations(kind)
    if (length(frames) == 0) {
      message("No ", klab, " registrations to clear.")
      return(invisible(NULL))
    }
    for (fr in frames) .jst_clear_one_frame(kind, fr)
    message(Klab, " registrations cleared across all data frames (",
            paste(frames, collapse = ", "), ").")
    return(invisible(NULL))
  }

  # verb(data, NULL): clear the named frame only.
  if (!is.null(explicit_frame)) {
    report_one(explicit_frame, .jst_clear_one_frame(kind, explicit_frame))
    return(invisible(NULL))
  }

  # verb(NULL): default frame wins when one is set.
  if (!is.null(default_name)) {
    report_one(default_name, .jst_clear_one_frame(kind, default_name),
               default = TRUE)
    return(invisible(NULL))
  }

  # verb(NULL), no default: clear the sole registered frame, else nothing,
  # else ask rather than wipe several silently.
  frames <- .jst_frames_with_registrations(kind)
  if (length(frames) == 0) {
    message("No ", klab, " registrations to clear.")
    return(invisible(NULL))
  }
  if (length(frames) == 1) {
    report_one(frames, .jst_clear_one_frame(kind, frames))
    return(invisible(NULL))
  }
  verb <- .jst_clear_verb(kind)
  .jst_stop(Klab, " registrations exist on more than one data frame: ",
       paste(frames, collapse = ", "), ".\n",
       "Name the one to clear, e.g. ", verb, "(", frames[1], ", NULL), ",
       "or clear them all with ", verb, "(clear.all = TRUE).")
}

#' Internal helper: shared registration engine for jnumeric() / jcount()
#'
#' Validates the requested variables, then either removes their registrations
#' of the given kind (\code{remove = TRUE}) or writes them, enforcing mutual
#' exclusion: writing a record replaces any prior intent record for that
#' variable (one record per variable in \code{.jst_registry}) and clears any
#' \code{.jst_dummy} registration for it. Any reclassification (a variable that
#' previously carried a different intent or a dummy registration) is reported.
#' A standard-tier reminder notes that registrations are session-only and how
#' to persist them.
#'
#' @param kind One of "numeric", "count".
#' @param data The resolved data frame.
#' @param data_name Character data-frame name (the registry key).
#' @param default_used Logical; whether the \code{juse()} default frame was used.
#' @param var_names Character vector of variable names to register.
#' @param remove Logical; if TRUE, remove rather than write.
#' @return \code{invisible(NULL)}.
#' @keywords internal
.jst_register_intent <- function(kind, data, data_name, default_used,
                                 var_names, remove) {
  .jst_check_vars(data, var_names, data_name)

  if (isTRUE(remove)) {
    reg     <- .jst_get_registry(data_name)
    removed <- character(0)
    for (v in var_names) {
      rec <- if (!is.null(reg)) reg[[v]] else NULL
      if (!is.null(rec) && identical(rec$kind, kind)) {
        reg[[v]] <- NULL
        removed  <- c(removed, v)
      }
    }
    if (!is.null(reg) && length(reg) == 0) reg <- NULL
    .jst_set_registry(data_name, reg)
    if (length(removed) > 0) {
      message(.jst_intent_label(kind, cap = TRUE), " registration removed for ",
              paste0("'", removed, "'", collapse = ", "), " in ", data_name, ".")
    } else {
      message("No ", .jst_intent_label(kind), " registration to remove for ",
              paste0("'", var_names, "'", collapse = ", "), " in ", data_name, ".")
    }
    return(invisible(NULL))
  }

  reg <- .jst_get_registry(data_name)
  if (is.null(reg)) reg <- list()
  reclass <- character(0)
  for (v in var_names) {
    prior <- reg[[v]]
    if (!is.null(prior) && !identical(prior$kind, kind)) {
      reclass <- c(reclass, paste0("'", v, "' (", .jst_intent_label(prior$kind),
                                   " -> ", .jst_intent_label(kind), ")"))
    }
    if (isTRUE(.jst_clear_dummy_var(data_name, v))) {
      reclass <- c(reclass, paste0("'", v, "' (dummy -> ",
                                   .jst_intent_label(kind), ")"))
    }
    reg[[v]] <- list(var_name = v, kind = kind)
  }
  .jst_set_registry(data_name, reg)

  if (isTRUE(default_used)) .jst_default_note(data_name)
  message(.jst_intent_label(kind, cap = TRUE), " registration set for ",
          paste0("'", var_names, "'", collapse = ", "), " in ", data_name, ".")
  if (length(reclass) > 0) {
    message("  Reclassified: ", paste(reclass, collapse = "; "), ".")
  }
  if (!identical(getOption(".jst_output_level", "standard"), "minimal")) {
    message(.jst_durability_note("session", data_name, count = length(var_names)))
  }

  # Non-blocking declaration-plausibility heads-up for the just-registered
  # variables (count/likert; numeric is a no-op). (Session 91)
  .jst_declaration_note(data, var_names, kind)

  invisible(NULL)
}

#' Internal helper: render a pipeline-state clear message
#'
#' Shared formatter for the \code{(NULL)} clear messages of
#' \code{jsubset()}, \code{jcomplete()}, and \code{jdummy()}. Owns the
#' collapse layout so the three setters stay byte-identical: one data
#' frame renders on a single line; two or more render a header line plus
#' one indented \code{"  - "} line per data frame.
#'
#' @param fn_label Character function label used in the message prefix
#'   (e.g. \code{"jsubset"}).
#' @param dnames Character vector of data frame names being cleared.
#' @param payloads Character vector, parallel to \code{dnames}, giving the
#'   parenthesised "what was lost" text for each frame (e.g.
#'   \code{"had: Age < 40"} or \code{"had 2 registered: Religion, Region"}).
#'
#' @return \code{invisible(NULL)}. Called for its message side effect.
#'
#' @keywords internal
.jst_render_clear <- function(fn_label, dnames, payloads) {
  n <- length(dnames)
  if (n == 1L) {
    message(fn_label, " cleared for ", dnames[1L], " (", payloads[1L], ").")
  } else {
    lines <- paste0("  - ", dnames, " (", payloads, ")")
    message(fn_label, " cleared (", n, " data frames):\n",
            paste(lines, collapse = "\n"))
  }
  invisible(NULL)
}

#' Internal helper: render a pipeline-state session-wide status overview
#'
#' Shared formatter for the two-or-more-frame status overview of
#' \code{jsubset()} and \code{jcomplete()} (the toggleable setters). Renders
#' a header line plus one indented \code{"  - "} line per data frame, each
#' tagged \code{[active]} / \code{[inactive]} and marked \code{, default}
#' for the current \code{juse()} default. The zero- and one-frame cases stay
#' with the callers, since their single-line wording differs (and
#' \code{jcomplete} appends a live complete-case count there). \code{jdummy}
#' does not use this helper: it has no active/inactive toggle and its
#' overview header reads "registrations" rather than "settings".
#'
#' @param fn_label Character function label (e.g. \code{"jsubset"}).
#' @param dnames Character vector of data frame names.
#' @param payloads Character vector, parallel to \code{dnames}, giving the
#'   per-frame payload shown after the colon (the expression for
#'   \code{jsubset}; the comma-joined variable list for \code{jcomplete}).
#' @param active Logical vector, parallel to \code{dnames}, TRUE when the
#'   setting is active.
#' @param default_name Character name of the current \code{juse()} default,
#'   or \code{NULL}. The matching frame is tagged \code{, default}.
#'
#' @return \code{invisible(NULL)}. Called for its message side effect.
#'
#' @keywords internal
.jst_render_status_overview <- function(fn_label, dnames, payloads, active,
                                        default_name = NULL) {
  tags   <- ifelse(active, "active", "inactive")
  is_def <- if (is.null(default_name)) rep(FALSE, length(dnames)) else
              dnames == default_name
  tags   <- ifelse(is_def, paste0(tags, ", default"), tags)
  lines  <- paste0("  - ", dnames, ": ", payloads, "  [", tags, "]")
  message(fn_label, " settings (", length(dnames), " data frames):\n",
          paste(lines, collapse = "\n"))
  invisible(NULL)
}

#' Internal helper: build canonical dummy variable naming for a categorical variable
#'
#' Single source of truth for how categorical variables are turned into named
#' dummy columns across the package. Called by \code{jdummy()} during
#' registration and by \code{jlm()} / \code{jlogistic()} when handling
#' \code{categorical =} arguments and auto-detected categorical IVs.
#'
#' Supports six input shapes:
#' \enumerate{
#'   \item haven_labelled with descriptive labels not containing the
#'         variable name (e.g. Gender labelled "Male", "Female").
#'   \item haven_labelled with descriptive labels already containing the
#'         variable name (e.g. Program labelled "Program 1", "Program 2"...).
#'   \item haven_labelled with labels that equal the codes as strings
#'         (i.e. uninformative -- labels carry no extra information).
#'   \item Plain numeric with no labels.
#'   \item Factor with character levels.
#'   \item Character vector.
#' }
#'
#' Naming algorithm:
#' \enumerate{
#'   \item Output form is always \code{VarName_Suffix}.
#'   \item Suffix source per category: descriptive label if available,
#'         numeric code otherwise. Mixed within a single variable is allowed
#'         (descriptive wins per-category).
#'   \item Canonicalise the chosen suffix: replace runs of non-alphanumeric
#'         characters with single underscore; trim leading and trailing
#'         underscores; if a suffix canonicalises to empty (label was entirely
#'         non-alphanumeric), fall back to that category's code.
#'   \item Anti-stutter: if the canonicalised suffix already begins with
#'         \code{paste0(var_name, "_")}, do not prepend the variable name
#'         again.
#'   \item Detect duplicates: if two categories produce the same final name,
#'         stop with an error pointing to \code{jrelabel()}.
#' }
#'
#' Permissive reference matching: when \code{ref} is a character string,
#' three matching attempts are made -- direct match against canonical labels,
#' canonicalised user input matched against canonical labels (so
#' \code{"Program 3"} or \code{"3"} both find \code{"Program_3"}), and
#' string match against codes (so \code{"3"} also matches code 3).
#'
#' @param x A vector -- haven_labelled, factor, character, or numeric.
#' @param var_name Character. The variable's name (used as the dummy
#'   column prefix).
#' @param ref Reference category specifier. May be \code{first} (default),
#'   \code{last}, a numeric code, or a character string matching a
#'   canonical label.
#' @param name.length.warn Integer. Warn if any final dummy name exceeds
#'   this many characters. Default 30.
#' @param max.categories Integer. Maximum number of input categories allowed;
#'   a variable with more raises an error rather than building the dummy set.
#'   Default \code{20L}.
#' @param data_name Character. Name of the source data frame, used only to
#'   build the suggested-fix call shown in the over-the-limit error. May be
#'   \code{NULL}.
#'
#' @return A list with components: \code{codes}, \code{labels}
#'   (canonical, used for display), \code{dummy_names} (canonical, for
#'   non-reference categories only), \code{var_type}, \code{ref_idx},
#'   \code{ref_code}, \code{ref_label}, \code{non_ref_idx}, \code{notes}
#'   (character vector of informational messages), \code{warnings_msg}
#'   (character vector of warnings).
#'
#' @keywords internal
.jst_make_dummy_names <- function(x, var_name, ref = "first",
                                  name.length.warn = 30L,
                                  max.categories = 20L,
                                  data_name = NULL) {

  notes        <- character(0)
  warnings_msg <- character(0)

  # -- Step 1: classify input and extract codes + raw labels ----------------
  is_haven <- haven::is.labelled(x)

  if (is_haven) {
    var_type   <- "haven_labelled"
    val_labels <- labelled::val_labels(x)
    codes      <- .jst_as_numeric(sort(unique(x[!is.na(x)])))
    raw_labels <- character(length(codes))
    for (i in seq_along(codes)) {
      match_idx <- which(val_labels == codes[i])
      if (length(match_idx) > 0) {
        raw_labels[i] <- names(val_labels)[match_idx[1]]
      } else {
        raw_labels[i] <- as.character(codes[i])
      }
    }
  } else if (is.factor(x)) {
    var_type   <- "factor"
    lvls       <- levels(droplevels(x))
    codes      <- seq_along(lvls)
    raw_labels <- lvls
  } else if (is.character(x)) {
    var_type   <- "character"
    uniq       <- sort(unique(x[!is.na(x) & nzchar(x)]))
    codes      <- seq_along(uniq)
    raw_labels <- uniq
  } else if (is.numeric(x)) {
    var_type   <- "numeric"
    codes      <- sort(unique(x[!is.na(x)]))
    raw_labels <- as.character(codes)
  } else {
    .jst_stop("'", var_name, "' has an unsupported type for dummy coding ",
         "(class: ", paste(class(x), collapse = "/"), ").")
  }

  n_cats <- length(codes)
  if (n_cats < 2) {
    .jst_stop("'", var_name, "' has fewer than 2 categories. ",
         "Cannot create dummy variables.")
  }
  if (n_cats > max.categories) {
    raise_to   <- (n_cats %/% 10L + 1L) * 10L
    dn         <- if (is.null(data_name) || !nzchar(data_name)) "data" else data_name
    raise_line <- paste0("  jdummy(", dn, ", ", var_name,
                         ", max.categories = ", raise_to, ")")
    via_dummy  <- identical(tryCatch(.jst_caller_fn(), error = function(e) NULL),
                            "jdummy")
    if (via_dummy) {
      .jst_stop(
        "'", var_name, "' has ", n_cats, " categories, the default limit is ",
        max.categories, ".\n",
        "You can raise the limit with:\n",
        raise_line
      )
    } else {
      .jst_stop(
        "'", var_name, "' has ", n_cats, " categories, more than the ",
        max.categories, "-category limit for dummy coding.\n",
        "To dummy-code this many, register it with jdummy and raise the limit:\n",
        raise_line
      )
    }
  }

  # -- Step 2: choose suffix source per category ----------------------------
  # Per-category rule: use the raw label if it is descriptive (non-empty
  # and not equal to the code-as-string); otherwise use the code.
  #
  # "Descriptive" detection is per-category, so a variable with mixed
  # descriptive and uninformative labels gets the most informative suffix
  # available for each category.

  code_as_str    <- as.character(codes)
  is_descriptive <- nzchar(raw_labels) & raw_labels != code_as_str

  # For non-haven types (factor, character, numeric), is_descriptive is
  # also true when the label genuinely differs from the synthetic code.
  # For numeric (no labels) all are "non-descriptive" → use codes. For
  # factor and character all should be descriptive (raw_labels are the
  # real values, and the codes are synthetic seq_along indices).

  used_code_fallback <- !is_descriptive
  suffix_source      <- ifelse(is_descriptive, raw_labels, code_as_str)

  # -- Step 3: canonicalise each suffix -------------------------------------
  canon <- gsub("[^A-Za-z0-9]+", "_", suffix_source)
  canon <- gsub("^_+|_+$", "", canon)

  # If canonicalisation produced an empty string (label was entirely
  # non-alphanumeric), fall back to the code for that category.
  empty_canon <- !nzchar(canon)
  if (any(empty_canon)) {
    canon[empty_canon]              <- code_as_str[empty_canon]
    used_code_fallback[empty_canon] <- TRUE
  }

  # -- Step 4: anti-stutter and prepend var_name ----------------------------
  prefix          <- paste0(var_name, "_")
  already_prefixed <- startsWith(canon, prefix)
  final_labels    <- ifelse(already_prefixed, canon, paste0(prefix, canon))

  # -- Step 5: duplicate detection ------------------------------------------
  if (anyDuplicated(final_labels) > 0) {
    dup_idx   <- which(duplicated(final_labels) | duplicated(final_labels,
                                                             fromLast = TRUE))
    dup_pairs <- vapply(unique(final_labels[dup_idx]), function(d) {
      offenders <- raw_labels[final_labels == d]
      paste0("'", paste(offenders, collapse = "' and '"),
             "' both produce '", d, "'")
    }, character(1))
    .jst_stop(
      "Cannot create unique dummy names for '", var_name, "': ",
      paste(dup_pairs, collapse = "; "), ". ",
      "Use jrelabel() to give these categories distinct labels, or ",
      "jrecode() to merge or rename them."
    )
  }

  # -- Step 6: resolve reference category -----------------------------------
  if (is.character(ref) && tolower(ref) == "first") {
    ref_idx <- 1L
  } else if (is.character(ref) && tolower(ref) == "last") {
    ref_idx <- n_cats
  } else if (is.numeric(ref)) {
    ref_idx <- which(codes == ref)
    if (length(ref_idx) == 0) {
      .jst_stop("Reference code ", ref, " not found in '", var_name,
           "'. Available codes: ", paste(codes, collapse = ", "))
    }
  } else if (is.character(ref)) {
    # Try direct match against canonical labels first.
    ref_idx <- which(final_labels == ref)
    if (length(ref_idx) == 0) {
      # Try canonicalising the user's input the same way labels were
      # canonicalised, then match.
      cleaned_ref <- gsub("[^A-Za-z0-9]+", "_", ref)
      cleaned_ref <- gsub("^_+|_+$", "", cleaned_ref)
      if (nzchar(cleaned_ref) && !startsWith(cleaned_ref, prefix)) {
        cleaned_ref <- paste0(prefix, cleaned_ref)
      }
      ref_idx <- which(final_labels == cleaned_ref)
    }
    if (length(ref_idx) == 0) {
      # Last try: match against codes-as-strings (so ref = "3" works for
      # code 3 even when canonical label is "Program_3").
      ref_idx <- which(code_as_str == ref)
    }
    if (length(ref_idx) == 0) {
      .jst_stop("Reference '", ref, "' not found in '", var_name,
           "'. Available labels: ", paste(final_labels, collapse = ", "))
    }
  } else {
    ref_idx <- 1L
  }

  ref_idx     <- as.integer(ref_idx[1])
  ref_code    <- codes[ref_idx]
  ref_label   <- final_labels[ref_idx]
  non_ref_idx <- setdiff(seq_len(n_cats), ref_idx)
  dummy_names <- final_labels[non_ref_idx]

  # -- Step 7: build informational notes and warnings -----------------------
  if (any(used_code_fallback)) {
    notes <- c(notes, paste0(
      "(Note: One or more dummy names for '", var_name, "' were built ",
      "from numeric codes because descriptive value labels were not ",
      "available. If these names aren't ideal, use jrelabel() to set ",
      "value labels, or jrecode() to change the underlying values, ",
      "then re-register with jdummy().)"
    ))
  }

  long_names <- final_labels[nchar(final_labels) > name.length.warn]
  if (length(long_names) > 0) {
    warnings_msg <- c(warnings_msg, paste0(
      "Some dummy names for '", var_name, "' exceed ", name.length.warn,
      " characters: ", paste(shQuote(long_names), collapse = ", "),
      ". The model will fit, but coefficient tables may look awkward. ",
      "Use jrelabel() to shorten the labels before jdummy()."
    ))
  }

  list(
    codes        = codes,
    labels       = final_labels,
    dummy_names  = dummy_names,
    var_type     = var_type,
    ref_idx      = ref_idx,
    ref_code     = ref_code,
    ref_label    = ref_label,
    non_ref_idx  = non_ref_idx,
    notes        = notes,
    warnings_msg = warnings_msg
  )
}


#' Internal helper: expand a single registration into dummy columns
#'
#' Given a registration-shaped object (from jdummy storage or built
#' in-flight via \code{.jst_make_dummy_names()}), add the dummy columns
#' to \code{data} and replace \code{var_name} with the dummy names in
#' \code{formula_str}. Used by \code{.jst_expand_dummies()} and by the
#' auto-categorical pathways in jlm and jlogistic.
#'
#' @param data The data frame.
#' @param formula_str The formula as a deparsed string.
#' @param reg A registration object (must have \code{var_name},
#'   \code{codes}, \code{non_ref_idx}, \code{dummy_names}).
#' @return A list with components \code{data}, \code{formula_str},
#'   \code{dummy_coef_names}.
#' @keywords internal
.jst_expand_one_dummy <- function(data, formula_str, reg) {

  orig_col         <- .jst_as_numeric(data[[reg$var_name]])
  dummy_coef_names <- character(0)

  for (j in seq_along(reg$non_ref_idx)) {
    idx   <- reg$non_ref_idx[j]
    dname <- reg$dummy_names[j]
    data[[dname]] <- ifelse(is.na(orig_col), NA_integer_,
                            as.integer(orig_col == reg$codes[idx]))
    dummy_coef_names <- c(dummy_coef_names, dname)
  }

  # Replace variable in formula with dummy names. Wrapping in parentheses
  # ensures correct behavior when the variable appears inside an
  # interaction term (e.g. y ~ x * Religion).
  dummy_plus  <- paste0("(", paste(reg$dummy_names, collapse = " + "), ")")
  formula_str <- gsub(paste0("\\b", reg$var_name, "\\b"),
                      dummy_plus, formula_str)

  list(data = data, formula_str = formula_str,
       dummy_coef_names = dummy_coef_names)
}


#' Internal helper: expand registered dummy variables in a formula and data frame
#'
#' Checks for jdummy registrations matching variables in the formula,
#' creates temporary dummy columns in the data frame, rewrites the formula,
#' and returns updated data, formula, reference category labels, and dummy
#' coefficient names. Used by jlm and jlogistic.
#'
#' A per-call numeric = or count = naming a registered dummy IV overrides the
#' registration for that one call (Option B): the variable is skipped before
#' expansion -- left intact as its original numeric column rather than expanded
#' then reverted -- and a message (registered dichotomy) or warning (registered
#' multi-category dummy) is emitted. The stored registration is never mutated.
#'
#' @param data The data frame.
#' @param formula The model formula.
#' @param data_name Character string name of the data frame (for looking up registrations).
#' @param numeric Optional character vector of variable names given a per-call
#'   numeric = override by the calling analysis function. A registered dummy
#'   named here is skipped from expansion (Option B) and left as its original
#'   numeric column; the stored registration is not changed.
#' @param count Optional character vector of variable names given a per-call
#'   count = override. Treated identically to \code{numeric} for expansion
#'   purposes (a count predictor enters a model as a numeric column).
#'
#' @return A list with components:
#'   \describe{
#'     \item{data}{The data frame with dummy columns added.}
#'     \item{formula}{The updated formula with dummy names.}
#'     \item{ref_cats}{Character vector of "VarName = RefLabel" strings.}
#'     \item{expanded_originals}{Character vector of the original variable
#'       names actually expanded into dummy columns (registered, minus any
#'       skipped by a per-call numeric=/count= override, minus any not in the
#'       formula). Callers use this to identify which originals were replaced.}
#'     \item{dummy_coef_names}{Character vector of dummy column names (for blanking beta).}
#'   }
#'
#' @keywords internal
.jst_expand_dummies <- function(data, formula, data_name,
                                numeric = NULL, count = NULL) {

  model_vars         <- all.vars(formula)
  dummy_regs         <- .jst_get_dummy(data_name)
  ref_cats           <- character(0)
  dummy_coef_names   <- character(0)
  expanded_originals <- character(0)

  if (!is.null(dummy_regs) && length(dummy_regs) > 0) {
    formula_str <- deparse(formula, width.cutoff = 500)
    dv_name     <- model_vars[1]

    for (reg in dummy_regs) {
      if (reg$var_name %in% model_vars && reg$var_name != dv_name) {

        # Option B (skip-before-expand): a per-call numeric =/ count = naming
        # a registered dummy IV wins over the registration for this one call.
        # Consult the override BEFORE expanding -- leave the original column
        # intact (no expand-then-revert) and skip it, so the variable flows on
        # to the analysis function's numeric/count branch as a plain numeric
        # predictor. The stored registration is never mutated (per-call only).
        if (reg$var_name %in% c(numeric, count)) {
          arg_label <- if (reg$var_name %in% numeric) "numeric" else "count"
          # Subclass split uses the SAME dichotomy test .jst_class_from_role()
          # uses for the registry Sub-class label, so the override message and
          # jscreen always agree on a given variable.
          if (.jst_is_dichotomy(data[[reg$var_name]])$is_dichotomy) {
            # Registered dichotomy -> mild consequential note (always shown).
            message(
              arg_label, " = takes precedence for ", reg$var_name,
              " (registered as a dummy via jdummy); entering it as numeric ",
              "for this model. The registration is unchanged."
            )
          } else {
            # Registered multi-category dummy -> real warning: collapsing its
            # category codes into one slope is an interval-scale assumption.
            warning(
              arg_label, " = takes precedence for ", reg$var_name,
              " (registered as a dummy via jdummy); entering it as numeric ",
              "for this model, so its category codes enter as a single ",
              "numeric predictor -- treating them as an interval scale. ",
              "The registration is unchanged.",
              call. = FALSE
            )
          }
          next
        }

        expanded <- .jst_expand_one_dummy(data, formula_str, reg)
        data               <- expanded$data
        formula_str        <- expanded$formula_str
        dummy_coef_names   <- c(dummy_coef_names, expanded$dummy_coef_names)
        expanded_originals <- c(expanded_originals, reg$var_name)

        ref_cats <- c(ref_cats, paste0(reg$var_name, " = ", reg$ref_label))
      }
    }

    formula <- stats::as.formula(formula_str)
  }

  list(data = data, formula = formula, ref_cats = ref_cats,
       dummy_coef_names = dummy_coef_names,
       expanded_originals = expanded_originals)
}
