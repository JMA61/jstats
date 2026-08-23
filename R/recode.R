#<<<FILE: recode.R>>>


# =============================================================================
#  DATA MANAGEMENT — RECODING & LABELING
# =============================================================================

# -- jrelabel ----------------------------------------------------------------

#' Apply variable and value labels to a variable
#'
#' @description
#' \code{jrelabel()} attaches a variable label and/or value labels to any
#' variable in a data frame. It is designed as a simple label applicator ---
#' it does not recode values, convert types, or compare variables. Use it to
#' add labels after a recode, to fix missing labels, or to label any variable
#' that needs them.
#'
#' A variable label (\code{var.label}) can be attached to a variable of any
#' type --- the variable is returned unchanged apart from the new label, so
#' dates stay dates, factors stay factors, and text stays text. Value labels
#' (\code{labels}) can be applied to haven-labelled, plain numeric, and
#' logical variables; logical values are stored as 1 (TRUE) and 0 (FALSE).
#' Factor, character, and date/time variables cannot carry value labels, and
#' \code{jrelabel()} refuses the \code{labels} argument for these with a
#' message naming the fix.
#'
#' \code{jrelabel()} never rebuilds the variable it is given. Existing value
#' labels, SPSS-style missing values (\code{na_values} / \code{na_range}),
#' Stata-style missing values, and the variable's class all pass through
#' untouched unless an argument you supply replaces them: new value labels
#' replace the full existing set (as \code{VALUE LABELS} does in SPSS), and
#' a new variable label replaces the old one. A replacement set clears any
#' labels attached to declared missing-value codes; the declaration itself
#' is unaffected, but re-supply its label alongside the new value labels to
#' keep it.
#'
#' Both the \code{labels} and \code{var.label} arguments are optional. If
#' neither is supplied, the function returns the variable unchanged.
#'
#' @param data A data frame containing the variable.
#' @param var The variable to label (unquoted, e.g. \code{StatusR}).
#' @param labels Optional. A quoted string specifying value labels using the
#'   format \code{"code=Label Text"} with rules separated by semicolons.
#'   Accepted on haven-labelled, plain numeric, and logical variables only.
#'
#'   Examples:
#'   \itemize{
#'     \item \code{"1=Yes; 0=No"}
#'     \item \code{"1=Employed; 2=Unemployed; 3=Student; 4=Retired"}
#'   }
#'
#' @param var.label Optional. A quoted string to use as the variable label
#'   (the description shown by \code{jdesc()}, \code{jfreq()}, etc.).
#'   If omitted, any existing variable label is preserved. If the variable
#'   has no existing label, no variable label is set.
#'
#' @return The variable with the requested labels applied. The variable keeps
#'   its class: haven-labelled input stays haven-labelled with any declared
#'   SPSS-style or Stata-style missing values intact; plain numeric and
#'   logical input becomes \code{haven_labelled} when value labels are
#'   applied; any other type is returned unchanged apart from the labels.
#'   Assign the result back to a column in your data frame:
#'   \code{MyData$VarName <- jrelabel(MyData, VarName, ...)}
#'
#' @examples
#' # Add value labels after a recode
#' df <- data.frame(Status = c(1, 2, 1, 2, 1, 2))
#' df$StatusR <- ifelse(df$Status == 1, 1, 0)
#' df$StatusR <- jrelabel(df, StatusR, labels = "1=Yes; 0=No",
#'                        var.label = "Status (recoded)")
#'
#' # Add just a variable label
#' df$StatusR <- jrelabel(df, StatusR, var.label = "Employment Status")
#'
#' # Add just value labels
#' df$StatusR <- jrelabel(df, StatusR, labels = "1=Yes; 0=No")
#'
#' # Label a date variable (the variable stays a Date)
#' df$Enrolled <- as.Date(c("2024-01-15", "2024-02-01", "2024-01-20",
#'                          "2024-03-05", "2024-02-14", "2024-01-30"))
#' df$Enrolled <- jrelabel(df, Enrolled, var.label = "Enrollment date")
#'
#' # Using juse() default
#' juse(df)
#' df$StatusR <- jrelabel(StatusR, labels = "1=Active; 0=Inactive")
#'
#' @seealso \code{\link{jrecode}} for recoding values with optional labels
#'   in a single step.
#' @seealso \code{\link{jstats}} for the package overview,
#'   workflow conventions, and complete function listing.
#'
#' @export
jrelabel <- function(data, var, labels = NULL, var.label = NULL) {

  # --- Resolve first argument -----------------------------------------------
  arg1 <- .jst_resolve_first_arg(
    data_sub      = substitute(data),
    data_missing  = missing(data),
    fn_name       = "jrelabel",
    envir         = parent.frame(),
    accept_vector = FALSE
  )

  data <- arg1$data

  # Determine variable name. If the user typed jrelabel(VarName, labels = ...)
  # — data omitted, named labels — the helper captured VarName as first_arg_sub.
  # Otherwise var is supplied positionally.
  if (arg1$mode == "symbol_with_default") {
    if (!missing(var)) {
      displaced <- deparse(substitute(var))
      .jst_stop("when the data argument is omitted, all subsequent arguments must be named. ",
                "Use jrelabel(", deparse(arg1$first_arg_sub), ", labels = ", displaced, ")",
                fn = "jrelabel")
    }
    var_name <- deparse(arg1$first_arg_sub)
  } else {
    var_name <- deparse(substitute(var))
  }

  # --- Input checks ---
  if (!is.data.frame(data)) {
    .jst_stop("The first argument must be a data frame.")
  }
  if (!var_name %in% names(data)) {
    frame_ref <- if (!is.null(arg1$name) && nzchar(arg1$name)) arg1$name else "the data frame"
    .jst_stop(paste0("Variable '", var_name, "' not found in ", frame_ref, "."))
  }

  x <- data[[var_name]]

  # In-place contract: `result` IS the caller's column. Labels are attached
  # to it directly, so its class and every attribute it carries (value
  # labels, SPSS-style na_values / na_range, Stata-style tagged values,
  # variable label) survive unless an argument below replaces them. The
  # column is never rebuilt or converted. (Session 215)
  result <- x

  # --- Validate var.label ---
  if (!is.null(var.label)) {
    if (!is.character(var.label) || length(var.label) != 1) {
      .jst_stop("The var.label argument must be a single quoted string.")
    }
  }

  # --- Apply value labels ---
  # Value labels attach only where the carrier is determined by the
  # column's CLASS alone: haven-labelled (numeric-backed), plain numeric,
  # and logical (stored as 1/0 --- a total, lossless mapping). Factor,
  # character, and date/time columns are refused with a fix, because
  # whether they could be converted depends on the column's CONTENTS, and
  # jrelabel() never converts. Mirrors jdeclare_udm()'s type guard.
  if (!is.null(labels)) {
    if (!is.character(labels) || length(labels) != 1) {
      .jst_stop("The labels argument must be a single quoted string, e.g. \"1=Yes; 0=No\".")
    }
    if (inherits(x, c("Date", "POSIXct", "POSIXlt", "difftime"))) {
      .jst_stop("'", var_name, "' is a date/time variable; value labels can ",
                "only be applied to numeric variables.")
    }
    if (is.factor(x)) {
      .jst_stop("'", var_name, "' is a factor; value labels can only be ",
                "applied to numeric variables.\n",
                "If the categories are numbers, convert with as.numeric(as.character(...)) first.")
    }
    if (is.character(x) ||
        (haven::is.labelled(x) && typeof(x) == "character")) {
      .jst_stop("'", var_name, "' is a character (text) variable; value ",
                "labels can only be applied to numeric variables.\n",
                "If the values are numbers stored as text, convert with as.numeric() first.")
    }
    if (!is.numeric(x) && !is.logical(x) && !haven::is.labelled(x)) {
      .jst_stop("'", var_name, "' is of type ", typeof(x),
                " and cannot carry value labels.")
    }

    if (is.logical(result)) result <- as.numeric(result)

    parsed_labels <- tryCatch(
      .jst_parse_labels(labels),
      error = function(e) .jst_stop(paste0("Error in labels argument: ",
                                      conditionMessage(e)))
    )
    labelled::val_labels(result) <- parsed_labels
  }

  # --- Apply variable label (any column type, in place) ---
  if (!is.null(var.label)) {
    labelled::var_label(result) <- var.label
  }

  return(invisible(result))
}


# -----------------------------------------------------------------------------
# .jst_jrecode_convention_error()
#
# Builds the error message emitted by jrecode() and jencode() when the
# user's map or labels argument contains lettered missing-value markers
# but the resolved convention is SPSS. States the mismatch and names
# the two settings-level ways out. It does NOT translate the call.
#
# S246 (Rule Y, the mint test): the SPSS-style echo-back is RETIRED.
# The rewrite substituted codes minted from
# joptions("udm.convention.codes") -- a pool blind to the column -- so
# a minted code could collide with a value already present in the data
# or with one of the user's own map targets, silently merging two
# distinct values and then declaring the result missing. Detecting that
# would have meant reimplementing jrecode's survival semantics inside a
# message builder. The rule drawn from it: a message may NAME values
# that already exist in the user's data or declaration, and may not
# MINT values the user never supplied. The sibling
# .jst_jdeclare_udm_convention_error reads the column's own na_values
# rather than the pool, so it passes the test and is unchanged.
#
# Retired with the echo-back: the rebuilt map and labels, the
# jdeclare_udm follow-up line, the convention-codes provenance line,
# the cap note, and the joutput tier gate -- one form at every level,
# being what minimal already rendered plus the keep-SPSS line.
#
# Retained from S245: the head QUOTES the marker as the user typed it
# (tagged_raw, carried out of the parsers) and attaches no convention
# style word to it. The PRESCRIPTIVE positions S245 split off went with
# the echo-back. A letter seen ONLY in labels carries no raw spelling
# and still falls back to the display case.
# -----------------------------------------------------------------------------

#' Internal helper: build the cross-convention error message
#'
#' Produces the error message used by \code{jrecode()} and
#' \code{jencode()} when lettered missing-value markers appear in the
#' map or labels argument but the resolved convention is SPSS. The
#' message states the mismatch and names the settings-level remedies;
#' per Rule Y it does not rewrite the user's call. One form at every
#' \code{joutput()} level.
#'
#' @param parsed_map List returned by \code{.jst_parse_map()}, or by
#'   \code{.jst_parse_text_map()} for the \code{jencode()} caller.
#' @param parsed_labels Named numeric vector returned by
#'   \code{.jst_parse_labels()}, or \code{NULL} if no labels argument
#'   was supplied.
#' @param per_call_convention Character or \code{NULL}. The caller's raw
#'   per-call \code{convention} argument. It selects which of the two
#'   routes to an SPSS resolution the message describes -- the call or
#'   the setting -- and therefore which remedy is offered; it plays no
#'   part in whether the error fires. It also seeds the display case for
#'   a marker that carries no recorded raw spelling.
#'
#' @return Character scalar suitable for passing to \code{.jst_stop()}.
#'
#' @keywords internal
.jst_jrecode_convention_error <- function(parsed_map, parsed_labels,
                                          per_call_convention = NULL) {

  # --- Gather every tagged-NA letter that appeared --------------------------
  map_tags <- unlist(lapply(parsed_map$mappings, function(r) r$tagged))
  if (isTRUE(parsed_map$else_action == "tagged")) {
    map_tags <- c(map_tags, parsed_map$else_tag)
  }
  if (!is.null(parsed_map$na_rule) &&
      !is.null(parsed_map$na_rule$tagged)) {
    map_tags <- c(map_tags, parsed_map$na_rule$tagged)
  }

  label_tags <- character(0)
  if (!is.null(parsed_labels)) {
    tags_in_labels <- haven::na_tag(parsed_labels)
    label_tags     <- unique(tags_in_labels[!is.na(tags_in_labels)])
  }

  all_tags <- sort(unique(c(map_tags, label_tags)))

  # The head QUOTES the marker as the user typed it -- tagged_raw from the
  # parsers, which accept either case per Decision 13. Recasing a quote
  # reads as a misread of the call, in both directions: a typed '.a' shown
  # as '.A' under a sas setting, a typed '.A' shown as '.a' otherwise. No
  # convention style word attaches to a quoted token (S245): under
  # case-insensitive input, labeling a typed '.a' "SAS-style" would equate
  # two spellings that a reader sees as different things. The style
  # contrast lives in the conflict sentence instead, as surface form --
  # lettered markers against numeric codes -- which is what a migrant
  # actually sees. The labels side stores real tagged NAs and carries no
  # raw spelling, so a letter seen ONLY in labels falls back to the display
  # case. Logic below stays on the lowercase parsed letters (all_tags).
  phr       <- .jst_phrasing_convention(per_call_convention)
  disp_tags <- .jst_canonical_tag(all_tags, phr)

  raw_by_letter <- character(0)
  for (r in parsed_map$mappings) {
    if (!is.null(r$tagged) && !is.null(r$tagged_raw)) {
      raw_by_letter[r$tagged] <- r$tagged_raw
    }
  }
  if (isTRUE(parsed_map$else_action == "tagged") &&
      !is.null(parsed_map$else_tag_raw)) {
    raw_by_letter[parsed_map$else_tag] <- parsed_map$else_tag_raw
  }
  if (!is.null(parsed_map$na_rule) &&
      !is.null(parsed_map$na_rule$tagged) &&
      !is.null(parsed_map$na_rule$tagged_raw)) {
    raw_by_letter[parsed_map$na_rule$tagged] <- parsed_map$na_rule$tagged_raw
  }
  quote_tags <- disp_tags
  hit        <- all_tags %in% names(raw_by_letter)
  if (any(hit)) {
    quote_tags[hit] <- unname(raw_by_letter[all_tags[hit]])
  }
  first_tag <- quote_tags[1]

  # Where the SPSS resolution came from. This call site passes no column
  # to the resolver, so exactly two routes reach an spss resolution: the
  # per-call argument (level 2) or the setting (level 3). Saying "the
  # package is currently set to SPSS convention" on the per-call route
  # was false -- the CALL forced spss -- and it pointed the remedy at
  # joptions(), which a per-call argument outranks (S245).
  by_call  <- !is.null(per_call_convention)
  conv_txt <- if (by_call) as.character(per_call_convention)[1L] else "spss"
  conflict <- if (by_call) {
    paste0("Lettered markers can exist only under Stata or SAS convention; ",
           "they cannot be combined with convention = \"", conv_txt,
           "\", which uses numeric codes.")
  } else {
    paste0("Lettered markers can exist only under Stata or SAS convention, ",
           "and your missing.convention setting is \"spss\", which uses ",
           "numeric codes.")
  }

  # Rule Y: state the mismatch, do not translate the call. The stay-put
  # remedy names the state to reach (Rule X's requirement form) rather
  # than writing the user's codes for them. "markers" rather than "the
  # map" because the marker may have arrived through labels.
  keep_spss <- if (length(all_tags) == 1L) {
    "To keep SPSS convention, restate the marker as a numeric code."
  } else {
    "To keep SPSS convention, restate the markers as numeric codes."
  }

  # The switch remedy follows the same route fork as the conflict
  # sentence: a per-call convention outranks the setting, so joptions()
  # would be inert advice on that route.
  switch_txt <- if (by_call) {
    .jst_wrap_prose(paste0(
      "To switch conventions instead, change convention = \"", conv_txt,
      "\" on this call to \"stata\" or \"sas\"."))
  } else {
    paste0("To switch conventions instead, run one of:\n",
           "  joptions(missing.convention = \"stata\")\n",
           "  joptions(missing.convention = \"sas\")")
  }

  # One form at every joutput level (S246): the tier gate went with the
  # echo-back, since what remains is the tier-independent statement.
  paste0(
    .jst_wrap_prose(paste0("the map uses '.", first_tag,
                           "', a missing-value marker."),
                    reserve = 11L), "\n",
    .jst_wrap_prose(conflict), "\n",
    .jst_wrap_prose(keep_spss), "\n",
    switch_txt
  )
}


# -----------------------------------------------------------------------------
# .jst_jdeclare_udm_convention_error()
#
# Builds the cross-convention error message for jdeclare_udm. Fires
# when the user passes Stata-style missing-value tokens in the codes vector
# but the resolved convention is SPSS. Modeled on the structure
# .jst_jrecode_convention_error() had at Session 31, with two
# simplifications: the rewrite is a single jdeclare_udm call (not two
# calls), and there is no separate labels argument to rebuild (labels
# live as names on the codes vector when present).
#
# S246: this builder KEEPS its rewritten call, where the jrecode/jencode
# one lost its echo-back. The two are not alike where Rule Y's mint test
# bites. This one substitutes the column's OWN declared codes
# (attr(col, "na_values"), largest-magnitude-first), so whatever it names
# is already declared missing on that column -- reading, not minting.
# The worst case is a label on the wrong declared marker, which is
# visible and reversible. The jrecode echo-back minted from
# joptions("udm.convention.codes"), which knows nothing about the column.
#
# joutput-level gating:
#   minimal  - three lines: what went wrong, see ?jdeclare_udm, the
#              joptions switch hint.
#   standard - full block with the rewritten jdeclare_udm call and
#   full       the joptions switch line.
#
# Cap behavior: when tagged-NA token count exceeds the convention
# code count, the helper substitutes the mappable subset and leaves
# unmapped tokens out of the example call. A plain-language cap note
# is appended.
# -----------------------------------------------------------------------------

#' Internal helper: build jdeclare_udm's cross-convention error message
#'
#' Produces the error message used by \code{jdeclare_udm()} when
#' Stata-style missing-value tokens appear in the \code{codes} argument but
#' the resolved convention is SPSS. Verbosity is controlled by the
#' active \code{joutput()} level.
#'
#' @param parsed_codes Named numeric vector. Names are labels (\code{""}
#'   where no label was given). Values are the user's codes including
#'   any tagged-NA elements.
#' @param data_name Character. Name of the data frame in the user's
#'   call (used to reconstruct the example).
#' @param var_name Character. Name of the variable being declared.
#'
#' @return Character scalar suitable for passing to \code{stop()}.
#'
#' @keywords internal
.jst_jdeclare_udm_convention_error <- function(parsed_codes,
                                               data_name, var_name, col,
                                               per_call_convention = NULL) {

  # S218 rewrite. Sole caller is the hoisted tagged-token gate, and the
  # sole case is a column that carries SPSS-STYLE declarations while the
  # codes vector names tagged markers. The column's own form drives the
  # refusal -- the convention setting is irrelevant to WHETHER this
  # fires, so the message must not blame it or suggest switching it (the
  # pre-S218 wording did both; following that advice dead-ended on the
  # convention-conflict guard). Two genuine remedies: label the numeric
  # codes the column already declares, or jconvert() the column to
  # tagged form first.
  #
  # S240: display only, the message phrases in the user's tagged
  # convention (.jst_phrasing_convention: per-call, else a sas setting,
  # else stata) -- token case, style word, and the jconvert target all
  # follow it, so a sas-setting user reads '.A' / "SAS-style" /
  # to = "sas". Firing conditions and both remedies are unchanged.

  # --- Identify tagged-NA elements ------------------------------------------
  tags_in_codes <- haven::na_tag(parsed_codes)
  tag_idx       <- which(!is.na(tags_in_codes))
  all_tags      <- sort(unique(tolower(tags_in_codes[tag_idx])))
  phr           <- .jst_phrasing_convention(per_call_convention)
  phr_style     <- .jst_convention_label(phr)
  disp_tags     <- .jst_canonical_tag(all_tags, phr)
  first_tag     <- disp_tags[1]

  na_vals <- attr(col, "na_values")
  na_vals <- if (is.null(na_vals)) numeric(0)
             else as.numeric(na_vals)
  na_rng  <- attr(col, "na_range")
  has_rng <- !is.null(na_rng) && length(na_rng) == 2L

  decl_disp <- character(0)
  if (length(na_vals) > 0L) {
    decl_disp <- c(decl_disp,
                   paste0("na_values: ", paste(format(na_vals, trim = TRUE),
                                               collapse = ", ")))
  }
  if (has_rng) {
    decl_disp <- c(decl_disp, sprintf("na_range: [%s, %s]",
                                      format(min(na_rng)),
                                      format(max(na_rng))))
  }
  decl_disp <- paste(decl_disp, collapse = "; ")

  # --- Verbosity gate -------------------------------------------------------
  output_level <- getOption(".jst_output_level", "standard")

  if (identical(output_level, "minimal")) {
    return(paste0(
      .jst_wrap_prose(paste0(
        "codes for ", var_name, " contains '.", first_tag,
        "', a ", phr_style, " missing-value marker, but ", var_name,
        " carries SPSS-style missing values."), reserve = 16L),
      "\n",
      "Name the numeric codes directly, or convert first:\n",
      "  jconvert(", data_name, ", to = \"", phr, "\", modify = TRUE)"
    ))
  }

  # --- Standard / full block ------------------------------------------------

  msg_parts <- c(
    .jst_wrap_prose(paste0(
      "codes for ", var_name, " contains '.", first_tag,
      "', a ", phr_style, " missing-value marker, but ", var_name,
      " carries SPSS-style missing values (", decl_disp, ")."),
      reserve = 16L))

  # Equivalent-call block: substitute each tagged element with the
  # column's own declared codes, matched largest-magnitude-first (ties
  # more-negative-first) -- the same Q6 ordering jconvert() uses to
  # letter these codes, so the first displayed marker corresponds to the
  # marker that jconvert(to = <phrasing convention>) would in fact
  # produce for that code (same positions, case per convention). Range-
  # only columns have no discrete codes to name, so the block is
  # skipped and the jconvert remedy below carries the message alone
  # (jconvert enumerates the range).
  unmapped <- character(0)
  if (length(na_vals) > 0L) {
    sorted_codes  <- na_vals[order(-abs(na_vals), na_vals)]
    tag_positions <- match(all_tags, letters)
    letter_to_code <- stats::setNames(
      ifelse(!is.na(tag_positions) & tag_positions <= length(sorted_codes),
             sorted_codes[tag_positions], NA_real_),
      all_tags)
    unmapped <- all_tags[is.na(letter_to_code)]

    format_num <- function(x) {
      if (is.na(x)) return("NA")
      if (x == floor(x)) format(as.integer(x)) else format(x)
    }

    rebuilt_parts <- character(0)
    for (i in seq_along(parsed_codes)) {
      val <- parsed_codes[i]
      lbl <- names(parsed_codes)[i]
      if (i %in% tag_idx) {
        this_tag <- tolower(tags_in_codes[i])
        if (this_tag %in% unmapped) next   # no column code to substitute
        val_render <- format_num(letter_to_code[[this_tag]])
      } else {
        val_render <- format_num(as.numeric(val))
      }
      if (is.null(lbl) || !nzchar(lbl)) {
        rebuilt_parts <- c(rebuilt_parts, val_render)
      } else {
        lbl_render <- if (grepl("^[A-Za-z.][A-Za-z0-9._]*$", lbl)) {
          lbl
        } else {
          paste0("`", lbl, "`")
        }
        rebuilt_parts <- c(rebuilt_parts,
                           paste0(lbl_render, " = ", val_render))
      }
    }

    if (length(rebuilt_parts) > 0L) {
      if (length(rebuilt_parts) > 1L) {
        codes_arg <- paste0("c(", paste(rebuilt_parts, collapse = ", "), ")")
      } else if (grepl(" = ", rebuilt_parts)) {
        codes_arg <- paste0("c(", rebuilt_parts, ")")
      } else {
        codes_arg <- rebuilt_parts
      }
      msg_parts <- c(msg_parts,
        "To label the declared numeric codes, name them directly:",
        "",
        paste0("    jdeclare_udm(", data_name, ", ", var_name,
               ", codes = ", codes_arg, ")"),
        "",
        paste0("The numeric code",
               if (sum(!is.na(letter_to_code)) > 1L) "s" else "",
               " above ",
               if (sum(!is.na(letter_to_code)) > 1L) "are" else "is",
               " ", var_name, "'s declared missing value",
               if (sum(!is.na(letter_to_code)) > 1L) "s" else "",
               ", matched largest magnitude first (the ordering ",
               "jconvert() uses)."))
    }

    if (length(unmapped) > 0L) {
      unmapped_render <- paste0("'.", .jst_canonical_tag(unmapped, phr),
                                "'", collapse = ", ")
      were_was <- if (length(unmapped) == 1L) "was" else "were"
      msg_parts <- c(msg_parts, "",
        .jst_wrap_prose(paste0(
          "Note: `codes` uses ", length(all_tags),
          " ", phr_style, " markers (",
          paste0(".", disp_tags, collapse = ", "),
          ") but ", var_name, " declares only ", length(na_vals),
          " numeric code", if (length(na_vals) > 1L) "s" else "",
          "; ", unmapped_render, " ", were_was,
          " not substituted in the example above.")))
    }
  }

  msg_parts <- c(msg_parts, "",
    paste0("To use ", phr_style, " markers instead, convert the column ",
           "first:"),
    "",
    paste0("    jconvert(", data_name,
           ", to = \"", phr, "\", modify = TRUE)"))

  paste(msg_parts, collapse = "\n")
}


# -----------------------------------------------------------------------------
# .jst_jdeclare_udm_mixed_error()
#
# Builds the Sign-off 4 error for when the user mixes tagged-NA elements
# and plain numeric codes in a single codes vector under Stata
# convention. Standard / full tier includes a worked split-call example.
# -----------------------------------------------------------------------------

#' @keywords internal
.jst_jdeclare_udm_mixed_error <- function(parsed_codes, data_name, var_name,
                                          per_call_convention = NULL) {

  tags_in_codes <- haven::na_tag(parsed_codes)
  tag_idx       <- which(!is.na(tags_in_codes))
  num_idx       <- setdiff(seq_along(parsed_codes), tag_idx)

  # S240: the token style word follows the display-time phrasing
  # convention (per-call, else a sas setting, else stata); firing
  # condition and both split-call remedies are unchanged.
  phr       <- .jst_phrasing_convention(per_call_convention)
  phr_style <- .jst_convention_label(phr)

  output_level <- getOption(".jst_output_level", "standard")

  if (identical(output_level, "minimal")) {
    return(paste0(
      "codes for ", var_name, " mixes ", phr_style, " missing values and ",
      "SPSS-style numeric codes. Issue these as separate jdeclare_udm() calls."
    ))
  }

  # Build the two split-call examples.
  format_num <- function(x) {
    if (is.na(x)) return("NA")
    if (x == floor(x)) format(as.integer(x)) else format(x)
  }

  fmt_label <- function(lbl) {
    if (is.null(lbl) || !nzchar(lbl)) return(NA_character_)
    if (grepl("^[A-Za-z.][A-Za-z0-9._]*$", lbl)) lbl
    else paste0("`", lbl, "`")
  }

  # Tagged-only call. Tag case and the explicit convention follow the
  # phrasing convention (S240): the rendered example shows the case that
  # would actually be written, and carries its convention so pasting it
  # verbatim survives the unset state (gate-ready, per the Tier 3 rule).
  tag_parts <- character(0)
  for (i in tag_idx) {
    lbl <- fmt_label(names(parsed_codes)[i])
    rhs <- paste0("tagged_na(\"",
                  .jst_canonical_tag(tags_in_codes[i], phr), "\")")
    if (is.na(lbl)) tag_parts <- c(tag_parts, rhs)
    else            tag_parts <- c(tag_parts, paste0(lbl, " = ", rhs))
  }
  tag_arg <- if (length(tag_parts) > 1L || grepl(" = ", tag_parts[1])) {
    paste0("c(", paste(tag_parts, collapse = ", "), ")")
  } else tag_parts[1]
  tag_line <- paste0("    jdeclare_udm(", data_name, ", ", var_name,
                     ", codes = ", tag_arg, ", convention = \"", phr,
                     "\", modify = TRUE)")

  # Numeric-only call
  num_parts <- character(0)
  for (i in num_idx) {
    lbl <- fmt_label(names(parsed_codes)[i])
    rhs <- format_num(as.numeric(parsed_codes[i]))
    if (is.na(lbl)) num_parts <- c(num_parts, rhs)
    else            num_parts <- c(num_parts, paste0(lbl, " = ", rhs))
  }
  num_arg <- if (length(num_parts) > 1L || grepl(" = ", num_parts[1])) {
    paste0("c(", paste(num_parts, collapse = ", "), ")")
  } else num_parts[1]
  num_line <- paste0("    jdeclare_udm(", data_name, ", ", var_name,
                     ", codes = ", num_arg, ", convention = \"", phr,
                     "\", modify = TRUE)")

  msg_parts <- c(
    .jst_wrap_prose(paste0("codes for ", var_name,
                           " mixes ", phr_style, " missing values ",
                           "and SPSS-style numeric codes."),
                    reserve = 16L),
    .jst_wrap_prose(paste0(
      "The two operations are different -- labeling existing ", phr_style, " ",
      "missing-value cells (tagged input) and converting numeric cells to ",
      phr_style, " missing values (numeric input) -- and must be issued ",
      "as separate calls.")),
    "For your input, that would be:",
    "",
    tag_line,
    num_line
  )

  paste(msg_parts, collapse = "\n")
}


# -----------------------------------------------------------------------------
# .jst_jdeclare_udm_drop_notice()
#
# Builds the Sign-off 5 drop-notice message emitted after a successful
# declaration when the prior UDM set contained codes not in the new set.
# Minimal tier: variable name and dropped codes only. Standard/full
# tier: labels for the dropped codes and the ?jdeclare_udm pointer.
# -----------------------------------------------------------------------------

#' @keywords internal
.jst_jdeclare_udm_drop_notice <- function(dropped_df, var_name,
                                          representation) {
  # dropped_df: subset of an .jst_missing_info()$codes data.frame containing
  # only the dropped rows. Has columns code, label, source, numeric, tag.

  output_level <- getOption(".jst_output_level", "standard")

  if (identical(output_level, "minimal")) {
    dropped_render <- paste(dropped_df$code, collapse = ", ")
    return(paste0("Note: jdeclare_udm replaced existing user-defined missing values on ",
                  var_name, ". Dropped: ", dropped_render, "."))
  }

  # Standard / full tier: include labels where available.
  parts <- character(0)
  for (i in seq_len(nrow(dropped_df))) {
    code <- dropped_df$code[i]
    lbl  <- dropped_df$label[i]
    if (!is.na(lbl) && nzchar(lbl)) {
      parts <- c(parts, sprintf("%s [\"%s\"]", code, lbl))
    } else {
      parts <- c(parts, code)
    }
  }
  paste0("Note: jdeclare_udm replaced the existing user-defined missing values for ", var_name,
         ". Previously declared codes dropped: ", paste(parts, collapse = ", "), ".")
}


# -- jrecode -----------------------------------------------------------------

#' Recode a variable with explicit value mapping and optional labels
#'
#' @description
#' \code{jrecode()} recodes a variable using a simple map string that specifies
#' how old values should be converted to new values. It is designed for
#' situations where you need to collapse categories, change numeric codes,
#' or recode dichotomies. Variable and value labels are handled automatically.
#'
#' Map and labels rules can also produce missing values: plain system NA
#' via the \code{NA} / \code{System} / \code{SYSMIS} aliases, or
#' Stata-style tagged missing values (\code{.a} through \code{.z}) when
#' the active convention is Stata. See \emph{Missing values in the map}
#' below for the canonical patterns under each convention.
#'
#' @param data     A data frame containing the original variable.
#' @param orig.var The variable to recode (unquoted, e.g. \code{AgeGroup}).
#' @param map      A quoted string specifying the recode rules, using the
#'   format \code{"old=new"} with rules separated by semicolons. Multiple old
#'   values mapping to the same new value are separated by commas on the left
#'   side.
#'
#'   An optional \code{else} clause controls what happens to values not
#'   covered by the map:
#'   \itemize{
#'     \item No else clause: the function stops with a message if any
#'       values are left unmapped, so you can fix the map before proceeding.
#'     \item \code{else=NA} (also \code{else=System} or \code{else=SYSMIS}):
#'       unmapped values are deliberately set to system NA.
#'     \item \code{else=copy}: unmapped values are carried across unchanged.
#'     \item \code{else=.a} (or any Stata-style missing-value token, Stata
#'       convention only): unmapped values are set to that Stata-style missing value.
#'   }
#'
#'   Individual values can also be mapped to system NA using the same
#'   aliases: \code{"-5=NA"}, \code{"-5=System"}, or \code{"-5=SYSMIS"}.
#'
#'   The same aliases may also appear as an OLD value, converting plain
#'   \code{NA} cells to a code: \code{"NA=-98; else=copy"} recodes every
#'   \code{NA} to \code{-98} (declare the code afterward with
#'   \code{jdeclare_udm()}). \code{NA} may be combined with numeric old
#'   values in one rule (\code{"NA,-99=-98"}) and may be named in at most
#'   one rule. Only plain \code{NA} cells are affected; tagged
#'   missing values are never converted by an \code{NA} rule. Under
#'   Stata or SAS convention the target may itself be a token: \code{"NA=.a"}.
#'
#'   Under Stata or SAS convention, values can be mapped to tagged missing-value tokens:
#'   \code{"-99=.a; -98=.b"}.
#'
#'   The right-hand side may also be the word \code{missing}
#'   (case-insensitive): the value is converted to your working
#'   convention's own missing form -- a tagged marker under the Stata or
#'   SAS convention, or the first code from
#'   \code{joptions("udm.convention.codes")} under the SPSS convention,
#'   declared on the result automatically. The same map string therefore
#'   works under every setting: \code{"8=missing; else=copy"}. The NA
#'   rule composes with it (\code{"NA=missing"} converts plain \code{NA}
#'   cells the same way), and \code{labels = "missing=Refused"} labels
#'   whatever the token minted. If the column already carries the other
#'   convention's markers while your \code{missing.convention} setting
#'   is set, the call stops and shows both resolutions rather than
#'   guessing.
#'
#'   Examples:
#'   \itemize{
#'     \item \code{"1=1; 2=0"}
#'     \item \code{"1=1; 2,3=2; 4,5=3; else=NA"}
#'     \item \code{"1=1; 2=0; else=copy"}
#'     \item \code{"-5=System; else=copy"}
#'     \item \code{"NA=-98; else=copy"}
#'     \item \code{"3=1; 4=2; else=.a"} (Stata or SAS convention only)
#'     \item \code{"8=missing; else=copy"} (any convention)
#'   }
#'
#' @param labels   Optional. A quoted string specifying value labels for the
#'   new variable, using the format \code{"code=Label Text"} with rules
#'   separated by semicolons. If supplied, these labels are used as-is.
#'
#'   The left side of each rule may be a numeric code or, under Stata
#'   convention, a Stata-style missing-value token (\code{.a} through
#'   \code{.z}). Tagged-NA labels are stored on the tag itself, not on
#'   a numeric code. It may also be the word \code{missing}, labelling
#'   whatever the map's \code{missing} target produced:
#'   \code{labels = "missing=Refused"}.
#'
#'   If omitted, the function attempts to transfer value labels automatically
#'   from the original variable. This works when the original variable has
#'   value labels and the mapping is one-to-one (no categories are collapsed).
#'   When categories are collapsed, labels cannot be transferred automatically
#'   and a note is printed.
#'
#'   Example: \code{"1=Male; 0=Female"} or \code{".a=Refused; .b=Don't know"}.
#'
#' @param convention Optional. One of \code{"spss"}, \code{"stata"},
#'   \code{"sas"}, or \code{NULL} (default); any capitalization is
#'   accepted. Controls whether missing-value tokens (\code{.a} through
#'   \code{.z} or \code{.A} through \code{.Z}) are accepted in the map
#'   and labels arguments. Token letters are matched case-insensitively;
#'   the stored markers take the convention's letter case (lowercase
#'   Stata-style under \code{"stata"}, uppercase SAS-style under
#'   \code{"sas"}). Inert when no such tokens appear in either argument.
#'
#'   When \code{NULL}, the convention is resolved from
#'   \code{joptions("missing.convention")}; if that is also unset, the
#'   default is SPSS. Most users set the convention once at the top of a
#'   session via \code{joptions()} (or in their \code{.Rprofile}) rather
#'   than supplying this argument on every call. See \code{?joptions} for
#'   details.
#'
#' @return A \code{haven_labelled} vector with the recoded values, variable
#'   label, and (if supplied or auto-transferred) value labels applied. Assign
#'   this to a new column in your data frame:
#'   \code{MyData$AgeGroupR <- jrecode(MyData, AgeGroup, map = "...")}
#'
#' @details
#' The function accepts haven-labelled, plain numeric, and logical variables.
#' Factor, character, and date/time variables are refused with a message
#' naming the fix --- recoding works with a variable's numeric values, so
#' convert these to numeric first.
#'
#' The variable label from the original variable is carried across automatically
#' with "(recoded)" appended. If the original variable has no variable label,
#' the variable name is used instead.
#'
#' Value labels are handled in three ways, in order of priority:
#' \enumerate{
#'   \item If \code{labels} is supplied, those labels are used as-is.
#'   \item If \code{labels} is omitted and the original variable has value
#'     labels, they are automatically transferred to the new codes --- provided
#'     the mapping is one-to-one (no collapsing). For example, recoding 1/2 to
#'     1/0 will carry "Yes" and "No" across to the new codes automatically.
#'   \item If categories are collapsed (multiple old values map to one new
#'     value), automatic transfer is not possible and a note is printed
#'     directing you to supply labels manually.
#' }
#'
#' NA values in the original variable are carried across as NA unless the
#' map names \code{NA} as an old value (for example \code{"NA=-98"}); the
#' \code{else} setting never converts NA. An \code{NA} rule affects plain
#' \code{NA} cells only --- Stata-style missing values (tagged NAs) are
#' declared missings and are preserved with their tags regardless of the
#' map.
#'
#' Values that appear to be coded missing values (e.g. -99, -9, 999) from SPSS
#' or another package are automatically detected and set to NA, even when
#' \code{else=copy} is used. A note is printed when this occurs.
#'
#' If the map does not include an \code{else} clause and there are unmapped
#' values in the variable, the function stops with a message listing the
#' unmapped values so you can fix the map before proceeding.
#'
#' If the map specifies values that do not exist in the original variable, a
#' warning is issued (but the function continues). This helps catch typos in
#' the map string.
#'
#' \strong{Missing values in the map.} The package supports three
#' conventions for representing user-defined missing values (UDMs), and
#' the syntax for producing UDMs from \code{jrecode()} depends on which
#' one is active:
#'
#' Under \strong{SPSS convention} (the default), UDMs are real numeric
#' codes carrying metadata that flags them as missing. The two-step
#' canonical pattern is:
#'
#' \preformatted{
#' df$EducR <- jrecode(df, Education,
#'                     map    = "1,2=1; 3=2; 4,5=3; -99,-98=-99",
#'                     labels = "1=High school or less; 2=Some college; 3=Degree")
#' jdeclare_udm(df, EducR, codes = c(Refused = -99), modify = TRUE)
#' }
#'
#' The \code{jrecode()} call assigns the numeric sentinel \code{-99}; the
#' subsequent \code{jdeclare_udm()} call attaches the label and flags
#' \code{-99} as missing. Labeling \code{-99} inside the \code{labels}
#' argument is unnecessary --- \code{jdeclare_udm()} owns that label.
#'
#' The same two-step pattern serves data whose missingness arrived as
#' plain \code{NA} (data born in R, or read from a CSV): \code{map =
#' "NA=-98; else=copy"} mints the sentinel from the NA cells, and
#' \code{jdeclare_udm()} declares it.
#'
#' Under \strong{Stata convention}, UDMs are typed missing cells marked
#' with Stata-style tags (\code{.a} through \code{.z}). The single-call
#' canonical pattern is:
#'
#' \preformatted{
#' df$EducR <- jrecode(df, Education,
#'                     map    = "1,2=1; 3=2; 4,5=3; else=.a",
#'                     labels = "1=High school or less; 2=Some college; 3=Degree; .a=Refused")
#' }
#'
#' Under Stata convention, \code{jdeclare_udm()} is not needed for this
#' pattern --- \code{jrecode()} handles both the value recoding and the
#' Stata-style missing-value labeling in one call.
#'
#' \strong{SAS convention} works the same way with SAS-style missing
#' values (\code{.A} through \code{.Z}). Map and labels tokens are
#' matched case-insensitively, and the stored markers take the active
#' convention's letter case: lowercase under Stata convention, uppercase
#' under SAS convention.
#'
#' Writing these missing-value tokens while the active convention is
#' SPSS raises an error naming the mismatch and the two ways out:
#' restate the markers as numeric codes to stay in SPSS convention, or
#' switch convention with \code{joptions(missing.convention = ...)} (or
#' with this call's \code{convention} argument). The error does not
#' rewrite the call for you: the SPSS-form codes would have to be minted
#' from \code{joptions("udm.convention.codes")}, which cannot be known
#' to be free of collision with values already in the column. The
#' two-call SPSS-style pattern is documented above.
#'
#' @examples
#' # Recode with explicit labels (a 1/2 dichotomy to 0/1)
#' df <- community
#' df$OwnsHome01 <- jrecode(df, OwnsHome,
#'                          map    = "1=1; 2=0",
#'                          labels = "0=No; 1=Yes")
#'
#' # Collapse categories (must supply labels)
#' df$RegionR <- jrecode(df, Region,
#'                       map    = "1,2=1; 3,4=2",
#'                       labels = "1=North or South; 2=East or West")
#'
#' # Use else=copy to carry unspecified values across unchanged
#' df$EducR <- jrecode(df, Education,
#'                     map    = "5=4; else=copy",
#'                     labels = "4=Bachelor's degree or higher")
#'
#' # Use else=NA to deliberately drop unspecified values to system NA
#' df$EducR2 <- jrecode(df, Education,
#'                      map    = "4=1; 5=1; else=NA",
#'                      labels = "1=College degree")
#'
#' # Convert a specific coded missing value to system NA
#' df$EducR3 <- jrecode(df, Education, map = "-99=System; else=copy")
#'
#' # Give plain NA cells a codable value, then declare it. Declaring on a
#' # plain column needs a chosen missing-value convention (the package
#' # never infers one), so choose it first:
#' joptions(missing.convention = "spss")
#' df$AgeR <- jrecode(df, Age, map = "NA=-98; else=copy")
#' df <- jdeclare_udm(df, AgeR, codes = c("Not recorded" = -98))
#'
#' # Stata convention: Stata-style missing-value tokens in map and labels
#' # (single call; convention = "stata" scopes the choice to this call only)
#' df$EducR4 <- jrecode(df, Education,
#'                      map    = "1,2=1; 3,4,5=2; else=.a",
#'                      labels = "1=No college; 2=College; .a=Refused",
#'                      convention = "stata")
#'
#' # SAS convention: the same single-call pattern; tokens are matched
#' # case-insensitively and the markers store in uppercase (.A)
#' df$EducR5 <- jrecode(df, Education,
#'                      map    = "1,2=1; 3,4,5=2; else=.a",
#'                      labels = "1=No college; 2=College; .a=Refused",
#'                      convention = "sas")
#'
#' # Using juse() default
#' juse(df)
#' df$RegionR2 <- jrecode(Region, map = "1,2=1; 3,4=2",
#'                        labels = "1=North or South; 2=East or West")
#'
#' @seealso \code{\link{jdeclare_udm}} for declaring user-defined missing
#'   values on a column after a recode (the SPSS-style canonical pattern).
#' @seealso \code{\link{jrelabel}} for applying labels to an existing variable
#'   after a recode.
#' @seealso \code{\link{joptions}} for the session-level
#'   \code{missing.convention} setting.
#' @seealso \code{\link{jstats}} for the package overview,
#'   workflow conventions, and complete function listing.
#'
#' @export
jrecode <- function(data, orig.var, map, labels = NULL, convention = NULL) {

  # --- Resolve first argument -----------------------------------------------
  arg1 <- .jst_resolve_first_arg(
    data_sub      = substitute(data),
    data_missing  = missing(data),
    fn_name       = "jrecode",
    envir         = parent.frame(),
    accept_vector = FALSE
  )

  data           <- arg1$data
  .jst_data_name <- arg1$name

  # Determine variable name. If the user typed jrecode(VarName, map = "...")
  # — data omitted, named map — the helper captured VarName as first_arg_sub.
  # Otherwise orig.var is supplied positionally.
  if (arg1$mode == "symbol_with_default") {
    if (!missing(orig.var)) {
      displaced <- deparse(substitute(orig.var))
      .jst_stop("when the data argument is omitted, all subsequent arguments must be named. ",
                "Use jrecode(", deparse(arg1$first_arg_sub), ", map = ", displaced, ")",
                fn = "jrecode")
    }
    orig_name <- deparse(arg1$first_arg_sub)
  } else {
    orig_name <- deparse(substitute(orig.var))
  }

  # --- Input checks ---
  if (!is.data.frame(data)) {
    .jst_stop("The first argument must be a data frame.")
  }
  if (!orig_name %in% names(data)) {
    .jst_stop(paste0("Variable '", orig_name, "' not found in '", .jst_data_name, "'."))
  }
  if (missing(map) || !is.character(map) || length(map) != 1) {
    .jst_stop("The map argument must be a single quoted string, e.g. map = \"1=1; 2=0\".")
  }

  # Validate convention argument up front so an invalid value errors
  # whether or not the recode actually uses tagged-NA tokens. The
  # resolved convention is consulted only when tokens are present.
  if (!is.null(convention)) {
    # Platform specs are case-insensitive (accept "SPSS", "Stata", ...).
    if (is.character(convention) && length(convention) == 1L &&
        !is.na(convention)) {
      convention <- tolower(convention)
    }
    if (!is.character(convention) || length(convention) != 1L ||
        !convention %in% c("spss", "stata", "sas")) {
      .jst_stop_arg(arg = "convention", choices = c("spss", "stata", "sas"))
    }
  }

  orig <- data[[orig_name]]

  # Type guard: recoding works with the column's numeric values, so text,
  # factor, and date/time columns are refused with a fix (a factor would
  # otherwise be silently recoded by its internal integer codes rather
  # than its level values). Mirrors jdeclare_udm()'s type guard.
  # (Session 215)
  if (inherits(orig, c("Date", "POSIXct", "POSIXlt", "difftime"))) {
    .jst_stop("'", orig_name, "' is a date/time variable; values can only ",
              "be recoded on numeric variables.")
  }
  if (is.factor(orig)) {
    .jst_stop("'", orig_name, "' is a factor; values can only be recoded ",
              "on numeric variables.\n",
              "If the categories are numbers, convert with as.numeric(as.character(...)) first.")
  }
  if (is.character(orig) ||
      (haven::is.labelled(orig) && typeof(orig) == "character")) {
    .jst_stop("'", orig_name, "' is a character (text) variable; values can ",
              "only be recoded on numeric variables.\n",
              "If the values are numbers stored as text, convert with as.numeric() first.")
  }
  if (!is.numeric(orig) && !is.logical(orig) && !haven::is.labelled(orig)) {
    .jst_stop("'", orig_name, "' is of type ", typeof(orig),
              " and cannot be recoded.")
  }

  # --- Detect suspicious coded missing values ---
  suspicious_vals <- .jst_detect_suspicious_values(orig, orig_name)

  # --- Parse map string ---
  parsed_map <- tryCatch(
    .jst_parse_map(map),
    error = function(e) .jst_stop(
      .jst_wrap_lines(paste0("Error in map argument: ", conditionMessage(e)),
                      reserve = 11L))
  )

  # --- Parse labels string (if supplied) ---
  # Parsed up front so the convention check below can scan both map
  # and labels for tagged-NA tokens in a single pass. The parsed
  # structure is consumed later in the value-label application step.
  parsed_labels <- NULL
  if (!is.null(labels)) {
    if (!is.character(labels) || length(labels) != 1) {
      .jst_stop("The labels argument must be a single quoted string, e.g. labels = \"1=Male; 0=Female\".")
    }
    parsed_labels <- tryCatch(
      .jst_parse_labels(labels),
      error = function(e) .jst_stop(paste0("Error in labels argument: ",
                                      conditionMessage(e)))
    )
  }

  # --- The missing token (Decision 14, Session 241) -------------------------
  # "missing" as a map target (or as the NA rule's target) mints the
  # resolved convention's own missing form. Resolution is setting-only
  # (per-call argument, then the joptions setting, then the resolver's
  # default level): the source column's form never silently decides, but
  # it IS read, to catch the one configuration where following the
  # setting would contradict the user's own data -- an explicitly chosen
  # setting against a column already carrying the other form. That
  # conflict ERRORS (the set-but-contradicted teach-gate, S239 closing
  # audit) with the per-call convention argument as the one-call escape.
  # The unset-state behavior lives inside .jst_resolve_convention(): this
  # block never branches on "no setting chosen", so the Decision 11
  # choose-first gate (shipped S244) fires at the resolver without this
  # block knowing about it.
  tok_rule_idx <- which(vapply(parsed_map$mappings,
                               function(r) isTRUE(r$missing), logical(1)))
  tok_in_na    <- !is.null(parsed_map$na_rule) &&
                  isTRUE(parsed_map$na_rule$missing)
  has_missing_token <- length(tok_rule_idx) > 0L || tok_in_na
  tok_missing_label <- attr(parsed_labels, "missing_label", exact = TRUE)

  if (!is.null(tok_missing_label) && !has_missing_token) {
    .jst_stop(
      .jst_wrap_prose(paste0(
        "labels names missing, but the map has no target for it ",
        "to label."), reserve = 11L), "\n",
      .jst_wrap_prose(paste0(
        "Add missing to the map (for example 8=missing), or label the ",
        "value directly.")))
  }

  tok_mint_code  <- NULL     # numeric; spss arm only
  tok_reused     <- FALSE    # spss arm: code already declared on the source
  tok_minted_any <- FALSE    # did the token actually assign any cell
  tok_tag        <- NULL     # canonical tag letter; stata/sas arms
  if (has_missing_token) {
    src_info <- .jst_missing_info(orig)
    src_conv <- if (is.null(src_info)) NULL else src_info$convention
    opt_conv <- getOption(".jst_options_missing_convention",
                          .jst_options_defaults$missing.convention)

    # The set-but-contradicted teach-gate (D7). A per-call convention is
    # the user answering the question, so it never conflicts; an unset
    # option has made no claim to contradict. Ambiguous mixed-case
    # columns (src_conv NA) carry markers of BOTH forms, so minting in
    # the chosen setting is consistent with part of the column and the
    # gate stays out of the way.
    if (is.null(convention) && opt_conv %in% c("spss", "stata", "sas") &&
        !is.null(src_conv) && !is.na(src_conv) &&
        !identical(src_conv, opt_conv)) {
      .jst_stop(
        .jst_wrap_prose(paste0(
          "'missing' is ambiguous for ", orig_name, ". The column uses ",
          .jst_convention_label(src_conv), " missing values, but your ",
          "missing.convention setting is ",
          .jst_convention_label(opt_conv), "."), reserve = 11L), "\n",
        "To follow the column's form for this call:\n",
        "  ", .jst_data_name, "$", orig_name, "R <- jrecode(",
        .jst_data_name, ", ", orig_name, ", map = \"",
        .jst_render_map_string(parsed_map), "\", convention = \"",
        src_conv, "\")\n",
        "Or convert the data frame to match your setting first:\n",
        "  jconvert(", .jst_data_name, ", to = \"", opt_conv,
        "\", modify = TRUE)")
    }

    tok_conv <- .jst_resolve_convention(convention, act = "token",
                                        fn = "jrecode")
    if (identical(tok_conv, "spss")) {
      cc <- getOption(".jst_options_udm_convention_codes",
                      .jst_options_defaults$udm.convention.codes)
      tok_mint_code <- as.numeric(cc[1])
      src_codes <- attr(orig, "na_values", exact = TRUE)
      src_codes <- if (is.null(src_codes)) numeric(0) else as.numeric(src_codes)
      if (tok_mint_code %in% src_codes) {
        # Benign reuse (S239): the minted code is the user's own
        # declaration, not a fourth code -- no cap arithmetic, and the
        # confirmation note fires in its already-declared variant.
        tok_reused <- TRUE
      } else {
        # Cap gate (D3): the declared codes that will survive this
        # recode (codes the map does not consume) plus the mint. Only a
        # full slate of three surviving codes can breach; the error
        # names them and offers the two remedies.
        lhs_all   <- unlist(lapply(parsed_map$mappings, `[[`, "old_vals"))
        survivors <- src_codes[!(src_codes %in% lhs_all)]
        if (length(survivors) >= 3L) {
          surv_txt <- paste(vapply(survivors, .jst_fmt_code, character(1)),
                            collapse = ", ")
          cap_txt  <- if (length(survivors) == 3L) {
            ", the maximum SPSS allows"
          } else {
            "; SPSS allows at most 3"
          }
          .jst_stop(
            .jst_wrap_prose(paste0(
              orig_name, " already declares ", length(survivors),
              " SPSS-style missing values (", surv_txt, ")", cap_txt,
              ". 'missing' would add ", .jst_fmt_code(tok_mint_code),
              " as a fourth."), reserve = 11L), "\n",
            "Use one of the declared codes instead:\n",
            "  ", .jst_data_name, "$", orig_name, "R <- jrecode(",
            .jst_data_name, ", ", orig_name, ", map = \"",
            .jst_render_map_string(parsed_map,
                                   missing_as = .jst_fmt_code(survivors[1])),
            "\")\n",
            "Or re-declare ", orig_name, " with fewer codes first:\n",
            "  jdeclare_udm(", .jst_data_name, ", ", orig_name,
            ", codes = c(",
            paste(vapply(survivors[1:2], .jst_fmt_code, character(1)),
                  collapse = ", "),
            "), modify = TRUE)")
        }
      }
      for (i in tok_rule_idx) {
        parsed_map$mappings[[i]]$new_val <- tok_mint_code
        parsed_map$mappings[[i]]$tagged  <- NULL
      }
      if (tok_in_na) {
        parsed_map$na_rule$new_val <- tok_mint_code
        parsed_map$na_rule$tagged  <- NULL
      }
    } else {
      tok_tag <- .jst_canonical_tag("a", tok_conv)
      for (i in tok_rule_idx) {
        parsed_map$mappings[[i]]$new_val <- NA_real_
        parsed_map$mappings[[i]]$tagged  <- tok_tag
      }
      if (tok_in_na) {
        parsed_map$na_rule$new_val <- NA_real_
        parsed_map$na_rule$tagged  <- tok_tag
      }
    }

    # labels = "missing=Label": the entry labels whatever the token just
    # minted -- the numeric code under spss, the tagged marker otherwise.
    if (!is.null(tok_missing_label)) {
      entry <- if (!is.null(tok_mint_code)) tok_mint_code
               else haven::tagged_na(tok_tag)
      names(entry) <- tok_missing_label
      parsed_labels <- c(parsed_labels, entry)
    }
  }

  # --- Cross-convention validation ---
  # Gather tagged-NA tokens from map and labels. If any are present,
  # resolve the active convention; under SPSS convention, raise the
  # cross-convention error, which states the mismatch and the two ways
  # out without rewriting the call (Rule Y, S246). Under Stata
  # convention the tokens are accepted and flow through to the recode
  # loop.
  map_has_tag <- any(!vapply(parsed_map$mappings,
                             function(r) is.null(r$tagged), logical(1))) ||
                 identical(parsed_map$else_action, "tagged") ||
                 (!is.null(parsed_map$na_rule) &&
                  !is.null(parsed_map$na_rule$tagged))
  labels_has_tag <- if (!is.null(parsed_labels)) {
    any(!is.na(haven::na_tag(parsed_labels)))
  } else FALSE

  if (map_has_tag || labels_has_tag) {
    # First tagged spelling in the user's call, for the choose-first
    # gate's head echo (parser-normalized lowercase; input case is
    # accepted either way per Decision 13). Token-minted tags cannot
    # reach the gate: minting them required a resolution, so a second
    # resolution here cannot fall to level 4.
    gate_marker <- NULL
    for (r in parsed_map$mappings) {
      if (!is.null(r$tagged)) { gate_marker <- paste0(".", r$tagged); break }
    }
    if (is.null(gate_marker) && identical(parsed_map$else_action, "tagged")) {
      gate_marker <- paste0(".", parsed_map$else_tag)
    }
    if (is.null(gate_marker) && !is.null(parsed_map$na_rule) &&
        !is.null(parsed_map$na_rule$tagged)) {
      gate_marker <- paste0(".", parsed_map$na_rule$tagged)
    }
    if (is.null(gate_marker) && labels_has_tag) {
      lt <- haven::na_tag(parsed_labels)
      gate_marker <- paste0(".", lt[!is.na(lt)][1L])
    }
    resolved_convention <- .jst_resolve_convention(convention,
                                                   act    = "tagged",
                                                   fn     = "jrecode",
                                                   marker = gate_marker)
    if (identical(resolved_convention, "spss")) {
      err_msg <- .jst_jrecode_convention_error(
        parsed_map          = parsed_map,
        parsed_labels       = parsed_labels,
        per_call_convention = convention
      )
      .jst_stop(err_msg)
    }
    # else: Stata or SAS convention — proceed; tagged-NA tokens are valid.

    # Canonicalize the parsed tag letters to the resolved convention's
    # mint case (Decision 13's token case rule: input is case-insensitive
    # -- the parsers lowercase-normalize -- and the case actually STORED
    # follows the governing convention: uppercase under "sas", lowercase
    # otherwise). Done once here on the parsed structures so every
    # downstream mint site and the value-label attachment inherit the
    # canonical case together; minting a lowercase cell against an
    # uppercase label (or vice versa) would silently fail to match.
    # Preserved tags from the ORIGINAL column are deliberately NOT
    # canonicalized -- display follows the stored tag, never the setting;
    # canonical case governs minting only. (Session 231)
    for (i in seq_along(parsed_map$mappings)) {
      if (!is.null(parsed_map$mappings[[i]]$tagged)) {
        parsed_map$mappings[[i]]$tagged <-
          .jst_canonical_tag(parsed_map$mappings[[i]]$tagged,
                             resolved_convention)
      }
    }
    if (!is.null(parsed_map$else_tag)) {
      parsed_map$else_tag <- .jst_canonical_tag(parsed_map$else_tag,
                                                resolved_convention)
    }
    if (!is.null(parsed_map$na_rule) &&
        !is.null(parsed_map$na_rule$tagged)) {
      parsed_map$na_rule$tagged <-
        .jst_canonical_tag(parsed_map$na_rule$tagged, resolved_convention)
    }
    if (!is.null(parsed_labels)) {
      label_tags <- haven::na_tag(parsed_labels)
      tagged_idx <- which(!is.na(label_tags))
      if (length(tagged_idx) > 0L) {
        canon <- .jst_canonical_tag(label_tags[tagged_idx],
                                    resolved_convention)
        # Subassignment keeps the vector's existing names, so only the
        # tagged values themselves are re-minted in canonical case.
        parsed_labels[tagged_idx] <- haven::tagged_na(canon)
      }
    }
  }

  # --- Apply recode ---
  # unclass() bypasses vctrs's "Can't convert <haven_labelled> to <double>"
  # cast refusal; underlying double values are preserved unchanged. See the
  # matching note in .jst_detect_suspicious_values() for full context.
  orig_num  <- as.numeric(unclass(orig))
  new_num   <- rep(NA_real_, length(orig_num))

  all_specified_old <- c()

  for (rule in parsed_map$mappings) {
    old_vals <- rule$old_vals
    all_specified_old <- c(all_specified_old, old_vals)

    # Map value(s) absent from the data: a no-op for those values, not a
    # problem -- a default-silent advisory note (full output only).
    actual_vals       <- unique(orig_num[!is.na(orig_num)])
    missing_from_data <- setdiff(old_vals, actual_vals)
    if (length(missing_from_data) > 0) {
      .jst_advisory_note(paste0(
        "Note: '", orig_name, "' contained none of the map values ",
        paste(missing_from_data, collapse = ", "),
        " - nothing was recoded for them."
      ))
    }

    rule_mask <- !is.na(orig_num) & orig_num %in% old_vals
    if (!is.null(rule$tagged)) {
      # Stata-style tagged-NA: assign haven::tagged_na(<letter>) so the
      # tag attribute is preserved on the underlying double storage.
      new_num[rule_mask] <- haven::tagged_na(rule$tagged)
    } else {
      new_num[rule_mask] <- rule$new_val
    }
  }

  # --- Handle unspecified non-NA values ---
  # Classify each unmapped, non-NA value into one of three kinds and act per
  # the locked jrecode missing-value policy: preserve declared codes, never
  # let a heuristic guess override, and obey explicit instructions.
  #   - declared SPSS-form UDM (value present in na_values): preserved
  #     unchanged -- the code value, its declaration, and its label are
  #     carried onto the recoded variable regardless of the else setting.
  #     (Stata-form tagged NAs are handled separately, below, since they are
  #     already NA and never reach this non-NA classification.)
  #   - heuristic-suspected but NOT declared: a guess, so jrecode never acts
  #     on it on its own. No else clause -> error (jointly with any
  #     legitimate unmapped value); else=copy -> carried through with a
  #     full-tier advisory note; else=NA/tagged -> handled like any unmapped
  #     value.
  #   - legitimate (not suspected): no else -> error; else=copy -> carried;
  #     else=NA -> NA; else=tagged -> tagged NA.
  unspecified_mask <- !is.na(orig_num) & is.na(new_num) &
                      !(orig_num %in% all_specified_old)
  unspecified_vals <- sort(unique(orig_num[unspecified_mask]))

  udm_codes <- attr(orig, "na_values", exact = TRUE)
  if (is.null(udm_codes)) udm_codes <- numeric(0)

  declared_unspecified <- unspecified_vals[unspecified_vals %in% udm_codes]
  heur_unspecified     <- unspecified_vals[unspecified_vals %in% suspicious_vals &
                                           !(unspecified_vals %in% udm_codes)]
  legit_unspecified    <- unspecified_vals[!(unspecified_vals %in% suspicious_vals) &
                                           !(unspecified_vals %in% udm_codes)]

  # Declared SPSS-form UDM codes: carry the code value through unchanged. The
  # na_values declaration and labels are re-attached at result construction.
  preserved_udm_codes <- numeric(0)
  if (length(declared_unspecified) > 0) {
    pres_mask <- !is.na(orig_num) & orig_num %in% declared_unspecified
    new_num[pres_mask] <- orig_num[pres_mask]
    preserved_udm_codes <- declared_unspecified
  }

  # Heuristic-suspected (undeclared) values: governed by the else setting.
  if (length(heur_unspecified) > 0 && parsed_map$else_explicit) {
    h_mask <- !is.na(orig_num) & orig_num %in% heur_unspecified
    if (parsed_map$else_action == "copy") {
      new_num[h_mask] <- orig_num[h_mask]
    } else if (parsed_map$else_action == "tagged") {
      new_num[h_mask] <- haven::tagged_na(parsed_map$else_tag)
    }
    # else=NA: already NA, nothing to do.
  }

  # Legitimate (not suspected) unmapped values: governed by the else setting.
  if (length(legit_unspecified) > 0 && parsed_map$else_explicit) {
    legit_mask <- !is.na(orig_num) & orig_num %in% legit_unspecified
    if (parsed_map$else_action == "copy") {
      new_num[legit_mask] <- orig_num[legit_mask]
    } else if (parsed_map$else_action == "tagged") {
      new_num[legit_mask] <- haven::tagged_na(parsed_map$else_tag)
    }
    # else=NA: already NA, nothing to do.
  }

  # No else clause: stop on any non-declared unmapped value (heuristic or
  # legitimate). Declared codes never reach here -- they were preserved above.
  if (!parsed_map$else_explicit) {
    error_vals <- sort(unique(c(heur_unspecified, legit_unspecified)))
    if (length(error_vals) > 0) {
      msg <- if (length(error_vals) == 1L) {
        paste0("Value ", error_vals, " in '", orig_name,
               "' was not in the map.")
      } else {
        paste0("Values ", paste(error_vals, collapse = ", "), " in '",
               orig_name, "' were not in the map.")
      }
      if (length(heur_unspecified) > 0) {
        msg <- paste0(msg, "\n", if (length(heur_unspecified) == 1L) {
          paste0(heur_unspecified,
                 " looks like a coded missing value; declare it with ",
                 "jdeclare_udm() so analyses exclude it, or map it ",
                 "(for example ", heur_unspecified[1], "=NA).")
        } else {
          paste0(paste(heur_unspecified, collapse = ", "),
                 " look like coded missing values; declare them with ",
                 "jdeclare_udm() so analyses exclude them, or map them.")
        })
      }
      if (length(legit_unspecified) > 0) {
        msg <- paste0(msg, "\nMap these values and re-run.")
      }
      msg <- paste0(msg,
        "\nTo leave unmapped values unchanged, add else=copy to the map.")
      .jst_stop(msg)
    }
  }

  # --- Notes for preserved declared codes and carried-through heuristics ---
  # Declared SPSS-form UDM codes that were preserved (M1): a standard-tier
  # note, since it states a fact about a declared thing. Heuristic-suspected
  # values carried through under else=copy (M3): a full-tier advisory note,
  # since "looks like a coded missing value" is a guess. See the message-
  # voice reference and JStats_Missing_Values_Reference.txt Part 4.
  orig_val_labels_for_note <-
    if (inherits(orig, "haven_labelled")) labelled::val_labels(orig) else NULL

  .code_with_label <- function(code) {
    if (!is.null(orig_val_labels_for_note) &&
        length(orig_val_labels_for_note) > 0) {
      lab <- names(orig_val_labels_for_note)[
        as.numeric(orig_val_labels_for_note) == code]
      lab <- lab[!is.na(lab) & nzchar(lab)]
      if (length(lab) >= 1L) return(paste0(code, " (\"", lab[1], "\")"))
    }
    as.character(code)
  }

  if (length(preserved_udm_codes) > 0) {
    rendered <- paste(vapply(preserved_udm_codes, .code_with_label,
                             character(1)), collapse = ", ")
    if (length(preserved_udm_codes) == 1L) {
      message(paste0(
        "Note: ", rendered, " is a declared missing value and was kept on ",
        "the recoded variable.\n",
        "To convert it to a plain NA instead, add ", preserved_udm_codes[1],
        "=NA to the map."))
    } else {
      message(paste0(
        "Note: ", rendered, " are declared missing values and were kept on ",
        "the recoded variable.\n",
        "To convert them to plain NA instead, map them to NA ",
        "(for example ", preserved_udm_codes[1], "=NA)."))
    }
  }

  if (length(heur_unspecified) > 0 && parsed_map$else_explicit &&
      parsed_map$else_action == "copy") {
    if (length(heur_unspecified) == 1L) {
      .jst_advisory_note(paste0(
        "Note: ", heur_unspecified, " in '", orig_name, "' looks like a ",
        "coded missing value and was carried through unchanged.\n",
        "If it represents missing data, declare it with jdeclare_udm() so ",
        "analyses exclude it."))
    } else {
      .jst_advisory_note(paste0(
        "Note: ", paste(heur_unspecified, collapse = ", "), " in '",
        orig_name, "' look like coded missing values and were carried ",
        "through unchanged.\n",
        "If they represent missing data, declare them with jdeclare_udm() ",
        "so analyses exclude them."))
    }
  }

  # NA-rule messages (E11): when the map names NA as an old value, report
  # what it did. A numeric-target mint gets a standard-tier note pointing
  # at jdeclare_udm() (the SPSS-style second step; an NA=.a target under
  # Stata convention mints an already-declared missing, so no note). When
  # the variable held no plain NA, a full-tier advisory mirrors the
  # existing absent-map-values note.
  if (!is.null(parsed_map$na_rule)) {
    n_plain_na <- sum(is.na(orig_num) & is.na(haven::na_tag(orig_num)))
    if (n_plain_na == 0) {
      .jst_advisory_note(paste0(
        "Note: '", orig_name, "' contained no NA values - nothing was ",
        "recoded for the NA rule."))
    } else if (is.null(parsed_map$na_rule$tagged) &&
               !is.na(parsed_map$na_rule$new_val) &&
               !isTRUE(parsed_map$na_rule$missing)) {
      # A token-minted NA target (NA=missing) is confirmed by the
      # missing-token note instead -- the declare remedy here would
      # prescribe a step the token already took.
      na_code <- parsed_map$na_rule$new_val
      code_txt <- if (na_code == floor(na_code)) {
        format(as.integer(na_code))
      } else {
        format(na_code)
      }
      if (n_plain_na == 1L) {
        message(paste0(
          "Note: 1 NA value in '", orig_name, "' was recoded to ",
          code_txt, ".\n",
          "Declare ", code_txt, " with jdeclare_udm() so analyses ",
          "exclude it."))
      } else {
        message(paste0(
          "Note: ", n_plain_na, " NA values in '", orig_name,
          "' were recoded to ", code_txt, ".\n",
          "Declare ", code_txt, " with jdeclare_udm() so analyses ",
          "exclude it."))
      }
    }
  }

  # NAs in original: plain-NA cells follow the map's NA rule when one is
  # present (E11) and stay NA otherwise; the else setting never converts
  # NA. Stata-form tagged NAs are declared missings and are never targeted
  # by the NA rule (or by a numeric map rule) -- their tags are re-applied
  # below, so all of them are preserved regardless of the else setting.
  orig_tags     <- haven::na_tag(orig_num)
  plain_na_mask <- is.na(orig_num) & is.na(orig_tags)
  if (!is.null(parsed_map$na_rule)) {
    if (!is.null(parsed_map$na_rule$tagged)) {
      new_num[plain_na_mask] <- haven::tagged_na(parsed_map$na_rule$tagged)
    } else {
      new_num[plain_na_mask] <- parsed_map$na_rule$new_val
    }
  } else {
    new_num[plain_na_mask] <- NA_real_
  }
  tagged_pos <- which(!is.na(orig_tags))
  if (length(tagged_pos) > 0) {
    new_num[tagged_pos] <- haven::tagged_na(orig_tags[tagged_pos])
  }

  # --- Declarations the result will carry -----------------------------------
  # Three sources compose: declared codes preserved unchanged (above),
  # declared codes the map recodes INTO (so a "8=-1" against a declared
  # -1 keeps the minted cells missing -- the cap error's first remedy
  # depends on this), and the missing token's spss-arm mint.
  declared_target_codes <- numeric(0)
  if (length(udm_codes) > 0) {
    tgt_vals <- unlist(lapply(parsed_map$mappings, function(r) {
      if (is.null(r$tagged) && !is.na(r$new_val) && !isTRUE(r$missing)) {
        r$new_val
      } else NULL
    }))
    if (!is.null(parsed_map$na_rule) &&
        is.null(parsed_map$na_rule$tagged) &&
        !is.na(parsed_map$na_rule$new_val) &&
        !isTRUE(parsed_map$na_rule$missing)) {
      tgt_vals <- c(tgt_vals, parsed_map$na_rule$new_val)
    }
    declared_target_codes <- udm_codes[udm_codes %in% tgt_vals]
  }
  if (!is.null(tok_mint_code)) {
    tok_lhs <- unlist(lapply(parsed_map$mappings[tok_rule_idx],
                             `[[`, "old_vals"))
    tok_minted_any <-
      (length(tok_lhs) > 0 &&
         any(!is.na(orig_num) & orig_num %in% tok_lhs)) ||
      (tok_in_na && any(is.na(orig_num) & is.na(orig_tags)))
  }
  result_na_values <- sort(unique(c(
    preserved_udm_codes, declared_target_codes,
    if (isTRUE(tok_minted_any)) tok_mint_code)))

  # Missing-token confirmation (D4, spss arm only; Rule R). Under a
  # stata/sas resolution the user wrote missing and got missing --
  # silent. Under spss the package chose the number AND attached the
  # declaration, so the note names both; the already-declared variant
  # covers benign reuse, where the result carries the user's own
  # declaration rather than adding a fourth code.
  if (!is.null(tok_mint_code) && isTRUE(tok_minted_any)) {
    if (isTRUE(tok_reused)) {
      message(paste0(
        .jst_wrap_prose(paste0(
          "Note: ", .jst_fmt_code(tok_mint_code), " was used for ",
          "missing, from your udm.convention.codes setting.")), "\n",
        .jst_wrap_prose(paste0(
          orig_name, " already declares ", .jst_fmt_code(tok_mint_code),
          " as a missing value, so the recoded variable carries the ",
          "existing declaration."))))
    } else {
      message(.jst_wrap_prose(paste0(
        "Note: ", .jst_fmt_code(tok_mint_code), " was used for missing, ",
        "from your udm.convention.codes setting, and declared as a ",
        "missing value on the recoded variable.")))
    }
  }

  # Map-target mint note (D1, S239 row 5): plain numeric targets the map
  # minted that look like coded missing values. The result vector is the
  # judge (the same heuristic jencode's target-side note uses); token
  # mints and declared targets are excluded -- those are already properly
  # missing on the result -- and a rule that matched nothing already drew
  # the nothing-was-recoded advisory.
  d1_rules <- Filter(function(r) {
    is.null(r$tagged) && !is.na(r$new_val) && !isTRUE(r$missing)
  }, parsed_map$mappings)
  if (length(d1_rules) > 0) {
    d1_targets <- setdiff(unique(vapply(d1_rules, `[[`, numeric(1),
                                        "new_val")),
                          result_na_values)
    if (length(d1_targets) > 0) {
      susp_res <- .jst_detect_suspicious_values(new_num, orig_name)
      flagged  <- sort(intersect(susp_res, d1_targets))
      flagged  <- as.numeric(Filter(function(v) {
        any(vapply(d1_rules, function(r) {
          r$new_val == v && any(!is.na(orig_num) & orig_num %in% r$old_vals)
        }, logical(1)))
      }, flagged))
      if (length(flagged) > 0) {
        pairs  <- character(0)
        plural <- FALSE
        for (i in seq_along(flagged)) {
          v  <- flagged[i]
          ov <- sort(unique(unlist(lapply(d1_rules, function(r) {
            if (r$new_val == v) {
              r$old_vals[r$old_vals %in% orig_num[!is.na(orig_num)]]
            } else NULL
          }))))
          shown <- .jst_and_list(vapply(ov, .jst_fmt_code, character(1)))
          if (i == 1L) plural <- length(ov) > 1L
          pairs <- c(pairs, if (i == 1L) {
            paste0(shown, if (plural) " were" else " was",
                   " recoded to ", .jst_fmt_code(v))
          } else {
            paste0(shown, " as ", .jst_fmt_code(v))
          })
        }
        one   <- length(flagged) == 1L
        codes <- vapply(flagged, .jst_fmt_code, character(1))
        message(paste0(
          .jst_wrap_prose(paste0(
            "Note: ", .jst_and_list(pairs), ", which ",
            if (one) "looks like a coded missing value."
            else "look like coded missing values.")), "\n",
          .jst_wrap_prose(paste0(
            "To make the value", if (one) "" else "s",
            " missing under your current convention, map ",
            if (one) "it" else "them", " directly:")), "\n",
          "  ", .jst_data_name, "$", orig_name, "R <- jrecode(",
          .jst_data_name, ", ", orig_name, ", map = \"",
          .jst_render_map_string(parsed_map, targets_to_missing = flagged),
          "\")\n",
          .jst_wrap_prose(paste0(
            "Or declare ", .jst_and_list(codes),
            " with jdeclare_udm() so analyses exclude ",
            if (one) "it." else "them."))))
      }
    }
  }

  # --- Variable label ---
  is_haven       <- inherits(orig, "haven_labelled")
  orig_var_label <- if (is_haven) labelled::var_label(orig) else NULL

  new_var_label <- if (!is.null(orig_var_label) &&
                       nchar(trimws(orig_var_label)) > 0) {
    paste0(orig_var_label, " (recoded)")
  } else {
    paste0(orig_name, " (recoded)")
  }

  # --- Build output as haven_labelled vector ---
  # If the result carries any SPSS-form declarations (preserved codes,
  # declared map targets, or the missing token's mint -- composed above),
  # attach them as na_values so those codes stay typed missings (excluded
  # in analyses, shown by jfreq, written back out by jsave). Otherwise a
  # plain labelled vector; any preserved Stata-form tagged NAs already sit
  # in the double payload.
  if (length(result_na_values) > 0) {
    result <- haven::labelled_spss(new_num, na_values = result_na_values)
  } else {
    result <- labelled::labelled(new_num)
  }
  labelled::var_label(result) <- new_var_label

  # --- Value labels ---
  if (!is.null(parsed_labels)) {
    # User-supplied labels always take precedence. The labels argument
    # was validated and parsed at the top of jrecode() so the parsed
    # vector is consumed directly here.
    labelled::val_labels(result) <- parsed_labels
  } else {
    # No labels supplied — try to auto-transfer from original variable
    orig_val_labels <- if (is_haven) labelled::val_labels(orig) else NULL

    if (!is.null(orig_val_labels) && length(orig_val_labels) > 0) {
      # Detect collapsing: multiple old values mapping to the same new
      # NON-NA value. NA-targeted rules are missing-value conversion, not
      # category collapse — combining several codes into NA is what the
      # user explicitly asked for, not a side effect to flag. Without
      # this filter, the duplicate-detection branch fires on common
      # missing-conversion maps like "-99=NA; -98=NA; else=copy".
      non_na_rules <- Filter(function(r) !is.na(r$new_val),
                              parsed_map$mappings)

      is_collapsing <- any(vapply(non_na_rules,
                                  function(r) length(r$old_vals) > 1,
                                  logical(1)))
      if (!is_collapsing) {
        non_na_new_vals <- vapply(non_na_rules,
                                   function(r) r$new_val, numeric(1))
        is_collapsing <- anyDuplicated(non_na_new_vals) > 0
      }

      if (is_collapsing) {
        message("Note: Categories were collapsed.\n",
                "Use labels argument or jrelabel() to assign new value labels.")
        # The collapse note covers the recoded categories only. Preserved
        # declared UDM codes are never part of a collapse, so carry their
        # labels through here; otherwise a kept code would show as
        # "(no label)" even though its declaration survived.
        if (length(preserved_udm_codes) > 0) {
          udm_labels <- c()
          for (i in seq_along(orig_val_labels)) {
            old_code <- unname(orig_val_labels[i])
            if (old_code %in% preserved_udm_codes) {
              entry        <- old_code
              names(entry) <- names(orig_val_labels)[i]
              udm_labels   <- c(udm_labels, entry)
            }
          }
          if (length(udm_labels) > 0) {
            labelled::val_labels(result) <- udm_labels
          }
        }
      } else {
        # One-to-one mapping — transfer labels to new codes
        old_to_new <- list()
        for (rule in parsed_map$mappings) {
          old_to_new[[as.character(rule$old_vals)]] <- rule$new_val
        }

        new_val_labels <- c()
        for (i in seq_along(orig_val_labels)) {
          old_code   <- unname(orig_val_labels[i])
          label_name <- names(orig_val_labels)[i]

          if (as.character(old_code) %in% names(old_to_new)) {
            # Explicitly mapped — use the new code, but drop the label
            # if the target is NA (no value to anchor the label to).
            entry <- old_to_new[[as.character(old_code)]]
            if (is.na(entry)) next
            names(entry)   <- label_name
            new_val_labels <- c(new_val_labels, entry)
          } else if (old_code %in% preserved_udm_codes) {
            # Declared SPSS-form UDM code preserved unchanged -- keep its
            # label at the same code value (so the kept code stays labelled
            # and the result reads as a proper declared missing).
            entry        <- old_code
            names(entry) <- label_name
            new_val_labels <- c(new_val_labels, entry)
          } else if (parsed_map$else_action == "copy") {
            # Unmapped but carried across unchanged
            entry        <- old_code
            names(entry) <- label_name
            new_val_labels <- c(new_val_labels, entry)
          }
          # else: value became NA via else_action, label is dropped
        }

        if (length(new_val_labels) > 0) {
          labelled::val_labels(result) <- new_val_labels
        }
      }
    } else {
      # The labels hint fires only when the map mints at least one
      # non-NA category there could be a label for. Pure missing-
      # conversion / value-dropping maps (every rule targets NA, e.g.
      # "-99=NA; else=copy") create nothing new to label, so the note is
      # suppressed -- mirroring the collapse-note guard's non-NA filter
      # above. The note stays for recodes that mint genuinely new
      # unlabelled categories (e.g. an unlabelled 1/2 -> 0/1).
      mints_non_na <- any(vapply(parsed_map$mappings,
                                 function(r) !is.na(r$new_val),
                                 logical(1)))
      if (mints_non_na) {
        message("Note: No value labels assigned. To add labels, use jrelabel().")
      }
    }
  }

  # Assign-or-lose reminder (standard + full): jrecode() returns the recoded
  # values invisibly, so an unassigned top-level call silently drops them. The
  # leading blank line keeps it clear of any label note above (Rule F).
  if (!identical(getOption(".jst_output_level", "standard"), "minimal")) {
    message(
      "\nNote: jrecode() returns the recoded values; assign them to a column to keep them:\n",
      "  ", .jst_data_name, "$<name> <- jrecode(...)\n",
      "To check the recode landed correctly, compare jfreq() on the original and the new column."
    )
  }

  return(invisible(result))
}



# -- jencode ------------------------------------------------------------------
#
# NO ROXYGEN AND NO @export IN THIS BUILD (S236 ruling 1). jencode() ships
# UNEXPORTED from the core build so the pkgdown reference-index hard-fail
# ("all topics must be included in the reference index", which R CMD check
# does not catch) cannot be tripped between this session and the completion
# session that adds the roxygen, the export, and BOTH hand-curated reference
# lists (_pkgdown.yml and the guides' reference.qmd) together. Interim
# testing goes through jstats:::jencode().
#
# jencode() converts a text column ("Parole", "Bail", "Remand") to a
# labelled-numeric column, with the original words carried across as the
# value labels. Two modes: a supplied map picks the numbers (the required
# route for ordered categories), an omitted map numbers the words
# alphabetically. Numeric-looking text converts by FACE VALUE, never by
# rank -- the one deliberate departure from the equivalent commercial-
# software command. Design record: changelog S225 decisions (0)-(5) and
# (7), S235 (e)/(f), S236 (b).


#' Internal helper: render a numeric code without a trailing decimal
#'
#' Whole numbers render as integers (\code{-99}, not \code{-99.0}); other
#' values fall through to \code{format()}. Used by \code{jencode()}'s
#' message surface wherever a code value is shown to the user.
#'
#' @param x Numeric scalar.
#'
#' @return Character scalar.
#'
#' @keywords internal
.jst_fmt_code <- function(x) {
  if (is.na(x)) return("NA")
  if (x == floor(x)) format(as.integer(x)) else format(x)
}


#' Internal helper: render words as a double-quoted comma list
#'
#' The house rendering for a list of data words in a runtime message.
#' Double quotes make trailing and leading spaces visible, which is the
#' whole point when the message is about words that did or did not match.
#'
#' @param x Character vector of words.
#'
#' @return Character scalar.
#'
#' @keywords internal
.jst_quote_words <- function(x) {
  paste0("\"", x, "\"", collapse = ", ")
}


#' Internal helper: render a capped, quoted word list for a message
#'
#' Renders words as a natural quoted list, truncating at \code{max_show}
#' with Rule A's "and N more" tail so a message stays readable when a
#' column carries many distinct words. Used by \code{jencode()}'s
#' unmapped-word naming and its target-side minting note.
#'
#' @param x Character vector of words.
#' @param max_show Integer. How many words to name before truncating.
#'
#' @return Character scalar.
#'
#' @keywords internal
.jst_jencode_show_words <- function(x, max_show = 5L) {
  n <- length(x)
  if (n == 0L) return("")
  if (n <= max_show) {
    return(.jst_and_list(paste0("\"", x, "\"")))
  }
  shown <- paste0("\"", x[seq_len(max_show)], "\"")
  paste0(paste(shown, collapse = ", "), ", and ",
         .jst_fmt_n(n - max_show), " more")
}


#' Internal helper: render a vector as a natural "a, b, and c" list
#'
#' @param x Character vector.
#'
#' @return Character scalar; Oxford comma at three or more, plain "and"
#'   at exactly two.
#'
#' @keywords internal
.jst_and_list <- function(x) {
  n <- length(x)
  if (n == 0L) return("")
  if (n == 1L) return(x)
  if (n == 2L) return(paste0(x[1L], " and ", x[2L]))
  paste0(paste(x[-n], collapse = ", "), ", and ", x[n])
}


#' Internal helper: pad a character vector to a common width
#'
#' Right-pads with spaces so a two-column listing lines up. Used by
#' \code{jencode()}'s alphabetical-assignment note.
#'
#' @param x Character vector.
#'
#' @return Character vector, each element padded to the longest width.
#'
#' @keywords internal
.jst_pad_right <- function(x) {
  width <- max(nchar(x))
  paste0(x, strrep(" ", width - nchar(x)))
}


#' Internal helper: render a runnable jencode() call for a remedy line
#'
#' Builds the prefilled, non-destructive jencode() call that
#' \code{jencode()}'s notes offer as a remedy: Rule G's R-suffix target,
#' the data name from the user's own call, and the map string filled in
#' from the column's own words, so the line runs as pasted. The call is
#' emitted on one line when it fits the 76-column message width, and
#' otherwise breaks after the variable with the map string continuing
#' under its own opening quote. Every continuation still parses, because
#' \code{.jst_parse_text_map()} trims each rule.
#'
#' @param data_name Character. The data frame's name in the user's call.
#' @param var_name Character. The variable being encoded.
#' @param rules_text Character. The map string's contents, without the
#'   surrounding quotes.
#' @param indent Character. Leading indent for the first line.
#'
#' @return Character scalar; may contain newlines.
#'
#' @keywords internal
.jst_jencode_map_call <- function(data_name, var_name, rules_text,
                                  indent = "  ") {
  new_name <- paste0(var_name, "R")
  head_str <- paste0(indent, data_name, "$", new_name, " <- jencode(")
  one_line <- paste0(head_str, data_name, ", ", var_name,
                     ", map = \"", rules_text, "\")")
  if (nchar(one_line) <= 76L) return(one_line)

  cont      <- strrep(" ", nchar(head_str))
  str_cont  <- strrep(" ", nchar(cont) + 6L)
  line1     <- paste0(head_str, data_name, ", ", var_name, ",")

  # Pack the rules across continuation lines, keeping each within the
  # message width. The separator stays on the line it ends.
  pieces  <- trimws(strsplit(rules_text, ";", fixed = TRUE)[[1]])
  pieces  <- pieces[nzchar(pieces)]
  lines   <- character(0)
  current <- paste0(cont, "map = \"")
  first   <- TRUE
  for (i in seq_along(pieces)) {
    sep      <- if (i < length(pieces)) ";" else ""
    addition <- paste0(if (first) "" else " ", pieces[i], sep)
    if (!first && nchar(current) + nchar(addition) > 76L) {
      lines   <- c(lines, current)
      current <- paste0(str_cont, pieces[i], sep)
    } else {
      current <- paste0(current, addition)
    }
    first <- FALSE
  }
  lines <- c(lines, paste0(current, "\")"))
  paste(c(line1, lines), collapse = "\n")
}


#' Encode a text variable as labelled numbers
#'
#' Converts a character (text) variable into numeric codes, attaching the
#' original words as value labels so every later table still shows the
#' words. With no \code{map}, codes are assigned alphabetically and the
#' assignment is printed; with a \code{map}, you choose the numbers.
#' Numbers stored as text ("34") always convert to their own value, never
#' to a rank.
#'
#' @param data A data frame containing the variable to encode. Can be
#'   omitted if a default data frame has been set with \code{juse()}.
#' @param var The text variable to encode (unquoted name). Only character
#'   variables are accepted: factors, numeric, logical, and date/time
#'   variables are refused with a message naming the right tool (for
#'   numeric variables, that is \code{jrecode()}).
#' @param map Optional. A single string of semicolon-separated rules, each
#'   \code{word=number}: for example
#'   \code{"Bail=1; Parole=2; Remand=3"}. Matching against the data is
#'   case-sensitive, after outer spaces are trimmed on both sides (a note
#'   reports any cells that matched only after trimming). Words containing
#'   a semicolon must be double-quoted (\code{'"Not applicable; other"=3'});
#'   apostrophes need no quoting: \code{map = "Yes=1; Don't know=8"} works
#'   as typed.
#'
#'   Special left-hand sides: \code{blank=<number>} gives empty cells their
#'   own code (by default they are left missing, with a note showing the
#'   blank rule to use). Special targets: \code{else=NA} converts every
#'   unmapped word to system missing; \code{else=.a} (through \code{.z})
#'   converts them to a tagged missing value under the Stata or SAS
#'   convention (see \code{convention}). \code{else=copy} is refused:
#'   words cannot be kept in a numeric column. A word may also be sent to
#'   the word \code{missing} -- your working convention's own missing
#'   form, declared automatically under the SPSS convention (see
#'   \code{jrecode()}'s \code{map} for the full rule); \code{blank=missing}
#'   composes the two tokens.
#'
#'   By default an incomplete map is an error that names the unmatched
#'   words (nothing is dropped silently); add an \code{else} rule to sweep
#'   the remainder deliberately, and the note then names the words it swept.
#' @param labels Optional. A single string of semicolon-separated
#'   \code{number=Label} pairs overriding the automatic labels: for
#'   example \code{"1=Low; 2=Medium; 3=High"}. If omitted, each word
#'   becomes the label of its own code. When several words collapse to one
#'   code, no label can be chosen automatically and a note directs you
#'   here or to \code{jrelabel()}.
#' @param convention Optional. One of \code{"spss"}, \code{"stata"},
#'   \code{"sas"}, or \code{NULL} (default); any capitalization is
#'   accepted. Controls whether missing-value tokens (\code{.a} through
#'   \code{.z} or \code{.A} through \code{.Z}) are accepted as map
#'   targets. Token letters are matched case-insensitively; the stored
#'   markers take the convention's letter case (lowercase Stata-style
#'   under \code{"stata"}, uppercase SAS-style under \code{"sas"}).
#'   Inert when no such tokens appear in the map.
#'
#'   When \code{NULL}, the convention is resolved from
#'   \code{joptions("missing.convention")}; if that is also unset, the
#'   default is SPSS. Most users set the convention once at the top of a
#'   session via \code{joptions()} (or in their \code{.Rprofile}) rather
#'   than supplying this argument on every call. See \code{?joptions} for
#'   details.
#'
#' @return A \code{haven_labelled} numeric vector with the encoded values
#'   and (unless overridden) the original words as value labels. The
#'   function returns the values rather than changing \code{data}: assign
#'   the result to a column to keep it. Two assignment forms do that job:
#'
#'   \itemize{
#'     \item Preserving (recommended):
#'       \code{MyData$StatusR <- jencode(MyData, Status)} adds a new
#'       column and keeps the original text, so the two can be compared
#'       with \code{jfreq()} before the text is retired.
#'     \item Overwrite:
#'       \code{MyData$Status <- jencode(MyData, Status)} replaces the
#'       text in place. Nothing is wrong with this once the encoding is
#'       verified, but the original words in the data are gone.
#'   }
#'
#'   SPSS users will recognize the pair: \code{RECODE ... INTO new.} is
#'   the preserving form and bare \code{RECODE} the overwrite, and SPSS's
#'   own text-to-numbers command (\code{AUTORECODE}, below) offers only
#'   the preserving form.
#'
#' @details
#' \strong{The SPSS parallel.} \code{AUTORECODE} is the SPSS command for
#' this job. Given a text variable it assigns consecutive numbers to the
#' distinct values in alphabetical order, stores the original text as
#' value labels, and writes the result to a new variable. Before:
#'
#' \preformatted{Status:  "Parole"  "Bail"  "Remand"  "Bail"}
#'
#' After \code{AUTORECODE VARIABLES=Status /INTO StatusR.}:
#'
#' \preformatted{StatusR: 2  1  3  1
#' with value labels  1 "Bail"  2 "Parole"  3 "Remand"}
#'
#' \code{jencode()}'s automatic mode does exactly this, and additionally
#' prints the assignment listing plus a ready-made \code{map} call so an
#' ordered set (Low / Medium / High) can be renumbered deliberately
#' rather than accepted alphabetically.
#'
#' \strong{Numbers stored as text convert by face value.} Here the two
#' part company. \code{AUTORECODE} treats "34" as just another string and
#' renumbers it to its alphabetical rank; \code{jencode()} always
#' converts a number stored as text to its own value ("34" becomes 34,
#' never 2), because a column of ages that arrives as text should leave
#' as ages. When every cell is numeric text, no value labels are attached
#' and a note says so.
#'
#' \strong{Repair mode.} A map containing only an \code{else} rule --
#' \code{map = "else=NA"} -- is the one-line repair for a poisoned
#' column (numbers plus stray word codes plus blanks, the shape a
#' spreadsheet import often produces): the numbers are kept at face
#' value and every word and blank is swept to missing. When a kept value
#' looks like a coded missing value -- by magnitude, or because a swept
#' word such as "Refused" is evidence the column carried missing-value
#' codes -- a note suggests declaring it with \code{jdeclare_udm()}
#' rather than losing it.
#'
#' \strong{Blanks are counted separately.} An empty cell ("") is neither
#' a word nor an NA. By default blanks are left missing, with a note
#' showing the \code{blank=} rule; mapping \code{blank=0} (or any code)
#' gives them their own category, which matters in field data where a
#' blank often means "No".
#'
#' The variable label from the original variable is carried across
#' automatically with "(encoded)" appended; if there is none, the
#' variable name is used instead.
#'
#' @examples
#' MyData <- data.frame(
#'   Status = c("Parole", "Bail", "Remand", "Bail"),
#'   Answer = c("Yes", "No", "Don't know", ""),
#'   AgeTxt = c("34", "41", "-99", "Refused"),
#'   stringsAsFactors = FALSE
#' )
#'
#' # Automatic mode: alphabetical, listing printed, words become labels
#' MyData$StatusR <- jencode(MyData, Status)
#'
#' # Map mode: choose the numbers; apostrophes need no quoting
#' MyData$AnswerR <- jencode(MyData, Answer,
#'                           map = "Yes=1; No=0; Don't know=8; blank=9")
#'
#' # Repair mode: keep the numbers at face value, sweep words and blanks
#' MyData$Age <- jencode(MyData, AgeTxt, map = "else=NA")
#'
#' @seealso \code{\link{jrecode}} for changing numeric values,
#'   \code{\link{jrelabel}} for value labels,
#'   \code{\link{jdeclare_udm}} for declaring missing-value codes,
#'   \code{\link{jfreq}} for checking an encoding landed correctly.
#'
#' @export
jencode <- function(data, var, map = NULL, labels = NULL, convention = NULL) {

  # --- Resolve first argument -----------------------------------------------
  arg1 <- .jst_resolve_first_arg(
    data_sub      = substitute(data),
    data_missing  = missing(data),
    fn_name       = "jencode",
    envir         = parent.frame(),
    accept_vector = FALSE
  )

  data           <- arg1$data
  .jst_data_name <- arg1$name

  # Determine variable name. If the user typed jencode(VarName, map = "...")
  # -- data omitted, named map -- the helper captured VarName as
  # first_arg_sub. Otherwise var is supplied positionally.
  if (arg1$mode == "symbol_with_default") {
    if (!missing(var)) {
      displaced <- deparse(substitute(var))
      .jst_stop("when the data argument is omitted, all subsequent arguments must be named. ",
                "Use jencode(", deparse(arg1$first_arg_sub), ", map = ", displaced, ")",
                fn = "jencode")
    }
    var_name <- deparse(arg1$first_arg_sub)
  } else {
    var_name <- deparse(substitute(var))
  }

  # --- Input checks ---------------------------------------------------------
  if (!is.data.frame(data)) {
    .jst_stop("The first argument must be a data frame.")
  }
  if (!var_name %in% names(data)) {
    .jst_stop(paste0("Variable '", var_name, "' not found in '",
                     .jst_data_name, "'."))
  }
  if (!is.null(map) && (!is.character(map) || length(map) != 1)) {
    .jst_stop("The map argument must be a single quoted string, e.g. map = \"Bail=1; Parole=2\".")
  }
  if (!is.null(labels) && (!is.character(labels) || length(labels) != 1)) {
    .jst_stop("The labels argument must be a single quoted string, e.g. labels = \"1=Bail; 2=Parole\".")
  }

  # Validate convention up front so an invalid value errors whether or not
  # the map actually uses tagged-NA tokens (jrecode's rule, inherited).
  if (!is.null(convention)) {
    # Platform specs are case-insensitive (accept "SPSS", "Stata", ...).
    if (is.character(convention) && length(convention) == 1L &&
        !is.na(convention)) {
      convention <- tolower(convention)
    }
    if (!is.character(convention) || length(convention) != 1L ||
        !convention %in% c("spss", "stata", "sas")) {
      .jst_stop_arg(arg = "convention", choices = c("spss", "stata", "sas"))
    }
  }

  orig <- data[[var_name]]

  # --- Type guard -----------------------------------------------------------
  # jencode() is the text counterpart of jrecode(): it encodes words, so
  # everything jrecode() accepts is refused here, and the message points
  # back at jrecode() where that is the right tool.
  is_text <- is.character(orig) ||
             (haven::is.labelled(orig) && typeof(orig) == "character")
  if (!is_text) {
    if (is.factor(orig)) {
      .jst_stop("'", var_name, "' is a factor; only text variables can be ",
                "encoded.\n",
                "Convert it to text first with as.character().")
    }
    if (inherits(orig, c("Date", "POSIXct", "POSIXlt", "difftime"))) {
      .jst_stop("'", var_name, "' is a date/time variable; only text ",
                "variables can be encoded.")
    }
    if (is.numeric(orig) || haven::is.labelled(orig)) {
      .jst_stop("'", var_name, "' is a numeric variable; only text variables ",
                "can be encoded.\n",
                "To change numeric values, use jrecode().")
    }
    if (is.logical(orig)) {
      .jst_stop("'", var_name, "' is a logical variable; only text variables ",
                "can be encoded.")
    }
    .jst_stop("'", var_name, "' is of type ", typeof(orig),
              " and cannot be encoded.")
  }

  # --- Words, blanks, and NA cells ------------------------------------------
  # Three kinds of cell, kept distinct in every message: a WORD, a BLANK
  # ("" or all spaces once outer whitespace is trimmed -- real data in the
  # field, where blank often means No), and a plain NA. Outer whitespace is
  # trimmed on both the data side and the map side before matching.
  txt        <- as.character(unclass(orig))
  na_mask    <- is.na(txt)
  words      <- txt
  words[!na_mask] <- trimws(txt[!na_mask])
  blank_mask <- !na_mask & !nzchar(words)
  word_mask  <- !na_mask & !blank_mask
  n_blank    <- sum(blank_mask)

  words_u <- unique(words[word_mask])
  # "Alphabetical" = radix sort on the lowercased word, tie-broken by the
  # word itself: deterministic across locales, and reads as alphabetical.
  words_u <- words_u[order(tolower(words_u), words_u, method = "radix")]

  new_num        <- rep(NA_real_, length(txt))
  val_labels_out <- c()
  msgs           <- character(0)   # emitted in order at the end

  # Missing-token state (Decision 14; set by map mode, read at the
  # result build). jencode's column is fresh, so the token has no
  # conflict gate and no cap arithmetic here.
  tok_mint_code  <- NULL     # numeric; spss arm only
  tok_minted_any <- FALSE

  # =========================================================================
  # AUTOMATIC MODE (map omitted)
  # =========================================================================
  if (is.null(map)) {

    if (length(words_u) == 0) {
      .jst_stop("'", var_name, "' contains no words to encode - every cell ",
                "is blank or missing.")
    }

    # "Numeric-looking" = what as.numeric() accepts. "1,234" and "$5" are
    # words; documented, extendable by explicit decision (S225 decision 4).
    num_like <- !is.na(suppressWarnings(as.numeric(words_u)))

    if (all(num_like)) {
      # --- Numbers stored as text: face value, never renumbered ------------
      vals <- as.numeric(words_u)
      for (i in seq_along(words_u)) {
        new_num[word_mask & words == words_u[i]] <- vals[i]
      }
      big <- which.max(vals)
      msgs <- c(msgs, paste0(
        .jst_wrap_prose(paste0(
          "Note: every value in '", var_name, "' is a number stored as ",
          "text; each was converted to its own value (\"", words_u[big],
          "\" -> ", .jst_fmt_code(vals[big]), ", never renumbered).")), "\n",
        .jst_wrap_prose(paste0(
          "No value labels were attached. To add labels, use jrelabel()."))))
      assigned_rules <- paste0(words_u, "=", vapply(vals, .jst_fmt_code,
                                                    character(1)))

      # The minted face values run the shipped looks-like-a-coded-missing
      # heuristic, so a text "-99" comes out declared-nudged (S225 (4)).
      msgs <- c(msgs, .jst_jencode_suspicious_note(new_num, var_name))

    } else if (any(num_like)) {
      # --- Mixed column: refuse, with the two real routes ------------------
      word_only <- words_u[!num_like]
      .jst_stop(paste0(
        .jst_wrap_prose(paste0(
          "'", var_name, "' mixes numbers stored as text with words: ",
          .jst_jencode_show_words(word_only), "."), reserve = 11L), "\n",
        .jst_wrap_prose(paste0(
          "The numbers convert to their own values, so the words cannot ",
          "be numbered automatically.")), "\n",
        .jst_wrap_prose(paste0(
          "Map the words (for example ", word_only[length(word_only)],
          "=-99), or send them all to missing:")), "\n",
        "  map = \"else=NA\""))

    } else {
      # --- Alphabetical numbering ------------------------------------------
      codes <- seq_along(words_u)
      for (i in seq_along(words_u)) {
        new_num[word_mask & words == words_u[i]] <- codes[i]
      }
      val_labels_out <- stats::setNames(as.numeric(codes), words_u)
      assigned_rules <- paste0(words_u, "=", codes)

      listing <- paste0("  ", .jst_pad_right(paste0("\"", words_u, "\"")),
                        " -> ", codes)
      msgs <- c(msgs, paste0(
        "Note: '", var_name, "' was encoded alphabetically:\n",
        paste(listing, collapse = "\n"), "\n",
        .jst_wrap_prose(paste0(
          "If these categories have a natural order (like ",
          "Low/Medium/High), rerun with a map to choose the numbers:")),
        "\n",
        .jst_jencode_map_call(.jst_data_name, var_name,
                              paste(assigned_rules, collapse = "; "))))
    }

    # Outer spaces removed before encoding: the stray spaces are still in
    # the user's file, so this reports a fact about their data.
    trim_mask <- word_mask & (txt != words)
    if (any(trim_mask)) {
      n_t    <- sum(trim_mask)
      ex_raw <- txt[trim_mask][1]
      msgs <- c(msgs, .jst_wrap_prose(paste0(
        "Note: ", .jst_fmt_n(n_t), " cell", if (n_t == 1L) "" else "s",
        " in '", var_name,
        "' had outer spaces removed before encoding (e.g. \"", ex_raw,
        "\" was read as \"", trimws(ex_raw), "\").")))
    }

    # Blanks go to plain NA in automatic mode -- no convention sensitivity.
    if (n_blank > 0) {
      msgs <- c(msgs, paste0(
        .jst_wrap_prose(paste0(
          "Note: ", .jst_fmt_n(n_blank), " blank cell",
          if (n_blank == 1L) "" else "s",
          " in '", var_name, "' ", if (n_blank == 1L) "was" else "were",
          " left missing (NA).")), "\n",
        .jst_wrap_prose(paste0(
          "To give blank cells their own category, rerun with a map ",
          "naming them:")), "\n",
        .jst_jencode_map_call(.jst_data_name, var_name,
                              paste(c(assigned_rules, "blank=0"),
                                    collapse = "; "))))
    }

  } else {

    # =======================================================================
    # MAP MODE
    # =======================================================================
    parsed_map <- tryCatch(
      .jst_parse_text_map(map),
      error = function(e) .jst_stop(
        .jst_wrap_lines(paste0("Error in map argument: ",
                               conditionMessage(e)), reserve = 11L))
    )

    # else=copy is refused wholesale: words cannot live in a numeric column,
    # so there is no partial case where copying makes sense.
    if (identical(parsed_map$else_action, "copy")) {
      .jst_stop(paste0(
        .jst_wrap_prose(paste0(
          "else=copy cannot be used here - words cannot be kept in a ",
          "numeric column."), reserve = 11L), "\n",
        .jst_wrap_prose(paste0(
          "Add the remaining words to the map, or set else=NA to ",
          "convert them to missing."))))
    }

    parsed_labels <- NULL
    if (!is.null(labels)) {
      parsed_labels <- tryCatch(
        .jst_parse_labels(labels),
        error = function(e) .jst_stop(paste0("Error in labels argument: ",
                                             conditionMessage(e)))
      )
    }

    # --- The missing token (Decision 14, Session 241) ----------------------
    # jrecode's token, inherited: "missing" as a target mints the resolved
    # convention's own missing form. jencode builds its column from
    # scratch, so no existing form can disagree (no conflict gate) and no
    # declarations can crowd a cap (no cap error); the spss arm's mint is
    # declared on the fresh result below. The unset-state behavior stays
    # inside .jst_resolve_convention() -- see jrecode's token block.
    tok_rule_idx <- which(vapply(parsed_map$mappings,
                                 function(r) isTRUE(r$missing), logical(1)))
    tok_in_na    <- !is.null(parsed_map$na_rule) &&
                    isTRUE(parsed_map$na_rule$missing)
    has_missing_token <- length(tok_rule_idx) > 0L || tok_in_na
    tok_missing_label <- attr(parsed_labels, "missing_label", exact = TRUE)

    if (!is.null(tok_missing_label) && !has_missing_token) {
      .jst_stop(
        .jst_wrap_prose(paste0(
          "labels names missing, but the map has no target for ",
          "it to label."), reserve = 11L), "\n",
        .jst_wrap_prose(paste0(
          "Add missing to the map (for example Refused=missing), or ",
          "label the value directly.")))
    }

    tok_tag <- NULL
    if (has_missing_token) {
      tok_conv <- .jst_resolve_convention(convention, act = "token",
                                          fn = "jencode")
      if (identical(tok_conv, "spss")) {
        cc <- getOption(".jst_options_udm_convention_codes",
                        .jst_options_defaults$udm.convention.codes)
        tok_mint_code <- as.numeric(cc[1])
        for (i in tok_rule_idx) {
          parsed_map$mappings[[i]]$new_val <- tok_mint_code
          parsed_map$mappings[[i]]$tagged  <- NULL
        }
        if (tok_in_na) {
          parsed_map$na_rule$new_val <- tok_mint_code
          parsed_map$na_rule$tagged  <- NULL
        }
      } else {
        tok_tag <- .jst_canonical_tag("a", tok_conv)
        for (i in tok_rule_idx) {
          parsed_map$mappings[[i]]$new_val <- NA_real_
          parsed_map$mappings[[i]]$tagged  <- tok_tag
        }
        if (tok_in_na) {
          parsed_map$na_rule$new_val <- NA_real_
          parsed_map$na_rule$tagged  <- tok_tag
        }
      }
      if (!is.null(tok_missing_label)) {
        entry <- if (!is.null(tok_mint_code)) tok_mint_code
                 else haven::tagged_na(tok_tag)
        names(entry) <- tok_missing_label
        parsed_labels <- c(parsed_labels, entry)
      }
    }

    # --- Cross-convention validation (E11 gate, inherited exactly) ---------
    resolved_convention <- NULL
    map_has_tag <- any(!vapply(parsed_map$mappings,
                               function(r) is.null(r$tagged), logical(1))) ||
                   identical(parsed_map$else_action, "tagged") ||
                   (!is.null(parsed_map$na_rule) &&
                    !is.null(parsed_map$na_rule$tagged))
    labels_has_tag <- if (!is.null(parsed_labels)) {
      any(!is.na(haven::na_tag(parsed_labels)))
    } else FALSE

    if (map_has_tag || labels_has_tag) {
      # First tagged spelling in the user's call, for the choose-first
      # gate's head echo (parser-normalized lowercase; see jrecode's
      # tagged site for the token-minted-tags argument).
      gate_marker <- NULL
      for (r in parsed_map$mappings) {
        if (!is.null(r$tagged)) { gate_marker <- paste0(".", r$tagged); break }
      }
      if (is.null(gate_marker) &&
          identical(parsed_map$else_action, "tagged")) {
        gate_marker <- paste0(".", parsed_map$else_tag)
      }
      if (is.null(gate_marker) && !is.null(parsed_map$na_rule) &&
          !is.null(parsed_map$na_rule$tagged)) {
        gate_marker <- paste0(".", parsed_map$na_rule$tagged)
      }
      if (is.null(gate_marker) && labels_has_tag) {
        lt <- haven::na_tag(parsed_labels)
        gate_marker <- paste0(".", lt[!is.na(lt)][1L])
      }
      resolved_convention <- .jst_resolve_convention(convention,
                                                     act    = "tagged",
                                                     fn     = "jencode",
                                                     marker = gate_marker)
      if (identical(resolved_convention, "spss")) {
        err_msg <- .jst_jrecode_convention_error(
          parsed_map          = parsed_map,
          parsed_labels       = parsed_labels,
          per_call_convention = convention
        )
        .jst_stop(err_msg)
      }
      # else: Stata or SAS convention -- tagged-NA tokens are valid.

      # Canonicalize the parsed tag letters to the resolved convention's
      # mint case (Decision 13). Done once, on the parsed structures, so
      # every mint site and the label attachment inherit the same case;
      # minting an uppercase cell against a lowercase label would silently
      # fail to match. sas is handled from birth here (S237).
      for (i in seq_along(parsed_map$mappings)) {
        if (!is.null(parsed_map$mappings[[i]]$tagged)) {
          parsed_map$mappings[[i]]$tagged <-
            .jst_canonical_tag(parsed_map$mappings[[i]]$tagged,
                               resolved_convention)
        }
      }
      if (!is.null(parsed_map$else_tag)) {
        parsed_map$else_tag <- .jst_canonical_tag(parsed_map$else_tag,
                                                  resolved_convention)
      }
      if (!is.null(parsed_map$na_rule) &&
          !is.null(parsed_map$na_rule$tagged)) {
        parsed_map$na_rule$tagged <-
          .jst_canonical_tag(parsed_map$na_rule$tagged, resolved_convention)
      }
      if (!is.null(parsed_labels)) {
        label_tags <- haven::na_tag(parsed_labels)
        tagged_idx <- which(!is.na(label_tags))
        if (length(tagged_idx) > 0L) {
          canon <- .jst_canonical_tag(label_tags[tagged_idx],
                                      resolved_convention)
          parsed_labels[tagged_idx] <- haven::tagged_na(canon)
        }
      }
    }

    # --- Match the data against the map ------------------------------------
    map_words_all  <- unlist(lapply(parsed_map$mappings,
                                    function(r) r$old_vals))
    map_words_real <- unique(map_words_all[nzchar(map_words_all)])
    blank_in_map   <- any(!nzchar(map_words_all))

    absent <- setdiff(map_words_real, words_u)
    if (length(absent) > 0) {
      .jst_advisory_note(paste0(
        "Note: '", var_name, "' contained none of the map words ",
        .jst_quote_words(absent), " - nothing was encoded for them."))
    }

    # --- The one-line repair for a column of numbers stored as text --------
    # S225 decision (4) says two things that pull apart once a map is in
    # play: numeric-looking text converts by FACE VALUE and an else-only
    # map is the "poisoned-column repair", but also that in map mode
    # numeric-looking strings are ordinary matchable words. Read narrowly,
    # both hold: an ELSE-ONLY map (no word rules at all) names no words, so
    # it asks jencode to do the automatic thing and send whatever is left
    # to the else clause -- numeric-looking text keeps its own value, real
    # words route through else. That is exactly the case the mixed-column
    # error names, and it is what makes its "set map = "else=NA" to convert
    # them all to missing" remedy true rather than an all-NA column. As
    # soon as the map names one word, the second sentence governs and a
    # numeric-looking string is an ordinary word again.
    repair_mode <- length(map_words_real) == 0 &&
                   isTRUE(parsed_map$else_explicit)
    face_words  <- character(0)
    if (repair_mode) {
      face_words <- words_u[!is.na(suppressWarnings(as.numeric(words_u)))]
    }

    unmapped <- setdiff(words_u, c(map_words_real, face_words))
    unmapped <- unmapped[order(tolower(unmapped), unmapped, method = "radix")]
    blank_unhandled <- n_blank > 0 && !blank_in_map

    # Strict default: an unhandled word or blank is an error, not a silent
    # NA. Two remedies, equal standing.
    if (!parsed_map$else_explicit &&
        (length(unmapped) > 0 || blank_unhandled)) {

      blank_txt <- paste0(.jst_fmt_n(n_blank), " blank cell",
                          if (n_blank == 1L) "" else "s")
      word_txt  <- if (length(unmapped) == 1L) "a word" else "words"
      lines <- if (length(unmapped) > 0 && blank_unhandled) {
        paste0("'", var_name, "' contains ", word_txt, " not in the map: ",
               .jst_jencode_show_words(unmapped), ", plus ", blank_txt, ".")
      } else if (length(unmapped) > 0) {
        paste0("'", var_name, "' contains ", word_txt, " not in the map: ",
               .jst_jencode_show_words(unmapped), ".")
      } else {
        paste0("'", var_name, "' contains ", blank_txt, " that ",
               if (n_blank == 1L) "is" else "are", " not in the map.")
      }

      # Near-miss diagnosis: name the case clash rather than leaving the
      # user to spot it. Matching is case-sensitive by design.
      for (w in unmapped) {
        hit <- map_words_real[tolower(map_words_real) == tolower(w)]
        if (length(hit) > 0) {
          lines <- c(lines, paste0(
            "\"", w, "\" differs from the map's \"", hit[1],
            "\" only in capitalization - matching is case-sensitive."))
        }
      }
      if (blank_unhandled) {
        lines <- c(lines,
          "Blank cells are named in the map by the word blank, as in blank=0.")
      }
      lines <- c(lines, if (length(unmapped) > 1L) {
        paste0("Add these words to the map, or add an else rule to send ",
               "unmapped words to missing:")
      } else if (length(unmapped) == 1L) {
        paste0("Add this word to the map, or add an else rule to send ",
               "unmapped words to missing:")
      } else {
        paste0("Add a blank rule to the map, or add an else rule to send ",
               "blank cells to missing:")
      }, "  map = \"...; else=NA\"")
      # First line carries the fn(): prefix; the trailing Rule L line is
      # runnable and never wrapped.
      lines <- vapply(seq_along(lines), function(i) {
        if (grepl("^\\s\\s", lines[i])) lines[i]
        else .jst_wrap_prose(lines[i], reserve = if (i == 1L) 11L else 0L)
      }, character(1))
      .jst_stop(paste(lines, collapse = "\n"))
    }

    # Apply the rules. A blank rule is an ordinary mapping whose old value
    # is the empty string, so blank cells fall out of this loop unaided.
    for (rule in parsed_map$mappings) {
      rule_mask <- !na_mask & words %in% rule$old_vals
      if (!is.null(rule$tagged)) {
        new_num[rule_mask] <- haven::tagged_na(rule$tagged)
      } else {
        new_num[rule_mask] <- rule$new_val
      }
    }

    # Numbers stored as text, under the repair reading above: face value,
    # never renumbered.
    if (length(face_words) > 0) {
      face_vals <- as.numeric(face_words)
      for (i in seq_along(face_words)) {
        new_num[word_mask & words == face_words[i]] <- face_vals[i]
      }
      big <- which.max(face_vals)
      n_face <- sum(word_mask & words %in% face_words)
      msgs <- c(msgs, .jst_wrap_prose(paste0(
        "Note: ", .jst_fmt_n(n_face), " value",
        if (n_face == 1L) "" else "s", " in '", var_name,
        "' stored as text ", if (n_face == 1L) "was" else "were",
        " kept at ", if (n_face == 1L) "its" else "their",
        " own value (\"", face_words[big], "\" -> ",
        .jst_fmt_code(face_vals[big]), ", never renumbered).")))
      # The words routed to the else clause are the evidence: a swept
      # "Refused" says this column carried missing-value codes.
      msgs <- c(msgs, .jst_jencode_suspicious_note(new_num, var_name,
                                                   evidence = unmapped))
    }

    # Outer-space trim that decided a match.
    trim_mask <- word_mask & (txt != words) & (words %in% map_words_real)
    if (any(trim_mask)) {
      n_t    <- sum(trim_mask)
      ex_raw <- txt[trim_mask][1]
      msgs <- c(msgs, .jst_wrap_prose(paste0(
        "Note: ", .jst_fmt_n(n_t), " cell", if (n_t == 1L) "" else "s",
        " in '", var_name,
        "' matched the map only after removing outer spaces (e.g. \"",
        ex_raw, "\" matched \"", trimws(ex_raw), "\").")))
    }

    # --- else clause -------------------------------------------------------
    if (parsed_map$else_explicit) {
      else_word_mask  <- word_mask & words %in% unmapped
      else_blank_mask <- blank_mask & !blank_in_map
      target_mask     <- else_word_mask | else_blank_mask

      if (any(target_mask)) {
        if (identical(parsed_map$else_action, "tagged")) {
          new_num[target_mask] <- haven::tagged_na(parsed_map$else_tag)
        } else {
          new_num[target_mask] <- NA_real_
        }

        n_w_cells <- sum(else_word_mask)
        n_w_words <- length(unmapped)
        n_b       <- sum(else_blank_mask)
        parts <- character(0)
        if (n_w_cells > 0) {
          w_txt <- paste0(.jst_fmt_n(n_w_words), " unmapped word",
                          if (n_w_words == 1L) "" else "s")
          # Two numbers answer two questions: the word count says WHAT went
          # (and matches the list the strict-default error named), the cell
          # count says HOW MUCH. Both are shown ALWAYS, even when they are
          # equal. Suppressing the second where it merely restates the first
          # would save four characters and cost a stable message shape: a
          # user working down a run of columns should not have to work out
          # why this one reported differently, and seeing the pair agree is
          # what teaches the reader what the parenthetical means.
          w_txt <- paste0(w_txt, " (", .jst_fmt_n(n_w_cells), " cell",
                          if (n_w_cells == 1L) "" else "s", ")")
          parts <- c(parts, w_txt)
        }
        if (n_b > 0) parts <- c(parts, paste0(.jst_fmt_n(n_b), " blank cell",
                                              if (n_b == 1L) "" else "s"))
        what <- paste(parts, collapse = " and ")

        # Naming the words (S238). The counts say how much moved; at
        # field scale ("2 unmapped words (1,540 cells)") the user still
        # cannot see WHICH words moved, and those words are exactly what
        # tells them whether the sweep was right. Named on their own
        # Rule E line so the S237 count clause keeps its stable shape,
        # and capped so a many-worded column stays readable.
        name_line <- if (n_w_cells > 0) {
          paste0("The unmapped word",
                 if (n_w_words == 1L) " was " else "s were ",
                 .jst_jencode_show_words(unmapped), ".")
        } else NULL

        if (identical(parsed_map$else_action, "tagged")) {
          style <- if (identical(resolved_convention, "sas")) {
            "SAS-style"
          } else "Stata-style"
          head_txt <- paste0(
            "Note: else=.", parsed_map$else_tag, " converted ", what, " in '",
            var_name, "' to the ", style, " missing value .",
            parsed_map$else_tag, ".")
        } else {
          head_txt <- paste0(
            "Note: else=NA converted ", what, " in '", var_name,
            "' to missing (NA).")
        }
        msgs <- c(msgs, paste(c(.jst_wrap_prose(head_txt),
                                if (!is.null(name_line)) {
                                  .jst_wrap_prose(name_line)
                                }),
                              collapse = "\n"))
      }
    }

    # --- NA rule (E11 semantics, transplanted) -----------------------------
    # Plain-NA cells of the ORIGINAL column only; at most one NA rule;
    # single pass, so cells the else clause sent to missing are not
    # re-swept here.
    if (!is.null(parsed_map$na_rule)) {
      n_plain_na <- sum(na_mask)
      if (n_plain_na == 0) {
        .jst_advisory_note(paste0(
          "Note: '", var_name, "' contained no NA values - nothing was ",
          "encoded for the NA rule."))
      } else {
        if (!is.null(parsed_map$na_rule$tagged)) {
          new_num[na_mask] <- haven::tagged_na(parsed_map$na_rule$tagged)
        } else {
          new_num[na_mask] <- parsed_map$na_rule$new_val
          if (!is.na(parsed_map$na_rule$new_val) &&
              !isTRUE(parsed_map$na_rule$missing)) {
            # A token-minted NA target (NA=missing) is confirmed by the
            # missing-token note instead.
            code_txt <- .jst_fmt_code(parsed_map$na_rule$new_val)
            msgs <- c(msgs, paste0(
              "Note: ", n_plain_na, " NA value",
              if (n_plain_na == 1L) "" else "s", " in '", var_name,
              if (n_plain_na == 1L) "' was" else "' were",
              " encoded as ", code_txt, ".\n",
              "Declare ", code_txt, " with jdeclare_udm() so analyses ",
              "exclude it."))
          }
        }
      }
    }

    # --- Value labels ------------------------------------------------------
    if (!is.null(parsed_labels)) {
      # User-supplied labels always take precedence.
      val_labels_out <- parsed_labels
    } else {
      # jencode uniquely has the label in hand -- the word itself. Only the
      # COLLAPSED numbers arrive unlabelled, since for them there is nothing
      # to choose between; un-collapsed words keep their words (S235 delta
      # against S225 decision (3)'s "mirrors jrecode exactly").
      targets <- list()
      for (rule in parsed_map$mappings) {
        rw <- rule$old_vals[nzchar(rule$old_vals)]
        if (length(rw) == 0) next          # blank-only rule: no word to use
        if (is.null(rule$tagged) && is.na(rule$new_val)) next  # NA: no anchor
        key <- if (!is.null(rule$tagged)) {
          paste0(".", rule$tagged)
        } else .jst_fmt_code(rule$new_val)
        if (is.null(targets[[key]])) {
          targets[[key]] <- list(value = rule$new_val, tagged = rule$tagged,
                                 words = character(0))
        }
        targets[[key]]$words <- c(targets[[key]]$words, rw)
      }

      collapsed_keys <- character(0)
      entries        <- c()
      for (key in names(targets)) {
        tg <- targets[[key]]
        if (length(tg$words) > 1L) {
          collapsed_keys <- c(collapsed_keys, key)
        } else {
          entry <- if (!is.null(tg$tagged)) {
            haven::tagged_na(tg$tagged)
          } else tg$value
          names(entry) <- tg$words[1]
          entries      <- c(entries, entry)
        }
      }
      val_labels_out <- entries

      if (length(collapsed_keys) > 0) {
        ord_val <- vapply(collapsed_keys, function(k) {
          tg <- targets[[k]]
          if (is.null(tg$tagged)) tg$value else Inf
        }, numeric(1))
        collapsed_keys <- collapsed_keys[order(ord_val, collapsed_keys,
                                               method = "radix")]
        lines <- vapply(collapsed_keys, function(k) {
          tg   <- targets[[k]]
          disp <- if (!is.null(tg$tagged)) {
            paste0(".", tg$tagged)
          } else .jst_fmt_code(tg$value)
          paste0("  ", disp, " <- ", .jst_quote_words(tg$words))
        }, character(1))
        collapse_msg <- paste0(
          .jst_wrap_prose(paste0(
            "Note: Some numbers combine two or more words, so no label ",
            "could be chosen for them:")),
          "\n", paste(lines, collapse = "\n"))
        if (length(entries) > 0) {
          collapse_msg <- paste0(collapse_msg,
            "\nThe other numbers keep their original words as labels.")
        }
        collapse_msg <- paste0(collapse_msg, "\n",
          .jst_wrap_prose(paste0(
            "Name each combined number with the labels argument, or later ",
            "with jrelabel().")))
        msgs <- c(msgs, collapse_msg)
      }
    }

    # --- Missing-token confirmation (D4, spss arm only; Rule R) ------------
    # Under a stata/sas resolution the user wrote missing and got missing
    # -- silent. Under spss the package chose the number AND attached the
    # declaration on the fresh column, so the note names both. The
    # already-declared variant cannot arise here: a text source carries
    # no declarations.
    if (!is.null(tok_mint_code)) {
      tok_lhs <- unlist(lapply(parsed_map$mappings[tok_rule_idx],
                               `[[`, "old_vals"))
      tok_minted_any <-
        (length(tok_lhs) > 0 && any(!na_mask & words %in% tok_lhs)) ||
        (tok_in_na && any(na_mask))
      if (tok_minted_any) {
        msgs <- c(msgs, .jst_wrap_prose(paste0(
          "Note: ", .jst_fmt_code(tok_mint_code), " was used for ",
          "missing, from your udm.convention.codes setting, and declared ",
          "as a missing value on the encoded variable.")))
      }
    }

    # --- Target-side minting note ------------------------------------------
    # The heuristic runs on MAP TARGETS only. The NA rule's own mint has
    # already been reported above, so it is excluded here rather than
    # nudged twice; token mints are confirmed by the note above and the
    # spss mint is a declared missing, so both stay out of the flag set.
    plain_targets <- unlist(lapply(parsed_map$mappings, function(r) {
      if (is.null(r$tagged) && !is.na(r$new_val) && !isTRUE(r$missing)) {
        r$new_val
      } else NULL
    }))
    plain_targets <- unique(plain_targets)
    if (!is.null(tok_mint_code)) {
      plain_targets <- setdiff(plain_targets, tok_mint_code)
    }
    if (length(plain_targets) > 0) {
      susp    <- .jst_detect_suspicious_values(new_num, var_name)
      flagged <- sort(intersect(susp, plain_targets))
      if (length(flagged) > 0) {
        # S238 -- two defects fixed here. (1) Only the FIRST word reaching
        # a flagged code was named, so a collapse ("Refused" and "Don't
        # know" both to -99) silently dropped the rest. (2) A blank rule
        # rendered as the hardcoded singular "a blank cell" whatever the
        # count. Both now render from the actual contents.
        pairs  <- character(0)
        plural <- FALSE
        for (i in seq_along(flagged)) {
          v  <- flagged[i]
          wd <- character(0)
          nb <- 0L
          for (rule in parsed_map$mappings) {
            if (is.null(rule$tagged) && !is.na(rule$new_val) &&
                rule$new_val == v) {
              wd <- c(wd, rule$old_vals[nzchar(rule$old_vals)])
              if (any(!nzchar(rule$old_vals))) nb <- n_blank
            }
          }
          wd    <- unique(wd)
          parts <- character(0)
          if (length(wd) > 0) {
            parts <- c(parts, .jst_jencode_show_words(wd))
          }
          if (nb > 0) {
            parts <- c(parts, paste0(.jst_fmt_n(nb), " blank cell",
                                     if (nb == 1L) "" else "s"))
          }
          if (length(parts) == 0) parts <- "a blank cell"
          shown <- .jst_and_list(parts)
          if (i == 1L) {
            plural <- length(wd) > 1L || nb > 1L ||
                      (length(wd) > 0 && nb > 0)
          }
          pairs <- c(pairs, if (i == 1L) {
            paste0(shown, if (plural) " were" else " was", " encoded as ",
                   .jst_fmt_code(v))
          } else {
            paste0(shown, " as ", .jst_fmt_code(v))
          })
        }
        codes <- vapply(flagged, .jst_fmt_code, character(1))
        one   <- length(flagged) == 1L
        msgs <- c(msgs, paste0(
          .jst_wrap_prose(paste0(
            "Note: ", .jst_and_list(pairs), ", which ",
            if (one) "looks like a coded missing value."
            else "look like coded missing values.")), "\n",
          .jst_wrap_prose(paste0(
            "To make the value", if (one) "" else "s",
            " missing under your current convention, map ",
            if (one) "it" else "them", " directly:")), "\n",
          "  ", .jst_data_name, "$", var_name, "R <- jencode(",
          .jst_data_name, ", ", var_name, ", map = \"",
          .jst_render_map_string(parsed_map,
                                 lhs_render = .jst_jencode_lhs_render,
                                 targets_to_missing = flagged),
          "\")\n",
          .jst_wrap_prose(paste0(
            "Or declare ", .jst_and_list(codes),
            " with jdeclare_udm() so analyses exclude ",
            if (one) "it." else "them."))))
      }
    }
  }

  # =========================================================================
  # RESULT
  # =========================================================================
  # The missing token's spss-arm mint is declared on the fresh column
  # (Decision 14); otherwise a plain labelled vector, with any tagged
  # mints already in the double payload.
  if (!is.null(tok_mint_code) && isTRUE(tok_minted_any)) {
    result <- haven::labelled_spss(new_num, na_values = tok_mint_code)
  } else {
    result <- labelled::labelled(new_num)
  }

  orig_var_label <- if (inherits(orig, "haven_labelled")) {
    labelled::var_label(orig)
  } else NULL
  new_var_label <- if (!is.null(orig_var_label) &&
                       nchar(trimws(orig_var_label)) > 0) {
    paste0(orig_var_label, " (encoded)")
  } else {
    paste0(var_name, " (encoded)")
  }
  labelled::var_label(result) <- new_var_label

  if (length(val_labels_out) > 0) {
    labelled::val_labels(result) <- val_labels_out
  }

  # --- Messages, in order ---------------------------------------------------
  for (m in msgs) message(m)

  # Assign-or-lose reminder (standard + full): jencode() returns the encoded
  # values invisibly, so an unassigned top-level call silently drops them.
  # The leading blank line keeps it clear of any note above (Rule F).
  if (!identical(getOption(".jst_output_level", "standard"), "minimal")) {
    message(
      "\n",
      .jst_wrap_prose(paste0(
        "Note: jencode() returns the encoded values; assign them to a ",
        "column to keep them:")), "\n",
      "  ", .jst_data_name, "$<name> <- jencode(...)\n",
      .jst_wrap_prose(paste0(
        "To check the encoding landed correctly, compare jfreq() on the ",
        "original and the new column."))
    )
  }

  return(invisible(result))
}


#' Internal helper: jencode's face-value minting note
#'
#' Runs the shipped looks-like-a-coded-missing heuristic over values
#' \code{jencode()} minted by FACE VALUE (a text \code{"-99"} becoming
#' the number -99) and returns the nudge toward
#' \code{jdeclare_udm()}, or \code{character(0)} when nothing is
#' flagged. Shared by the all-numeric automatic path and the
#' numbers-stored-as-text repair path so the two read identically.
#'
#' @param x Numeric vector. The encoded values.
#' @param var_name Character. The variable's name.
#'
#' @return Character scalar, or \code{character(0)}.
#'
#' @keywords internal
.jst_jencode_suspicious_note <- function(x, var_name,
                                         evidence = character(0)) {
  susp <- .jst_detect_suspicious_values(x, var_name)

  # The evidence channel (S238). Words swept out of the column are
  # evidence about the column they came from: where one of them says
  # missing, a negative value kept at face value is reportable even
  # though it did not clear the magnitude bar -- the -99 in a column of
  # plausible ages that the magnitude heuristic documents itself as
  # missing. The admission rule lives in
  # .jst_evidence_admits_missing_values() so it is revised once,
  # package-wide, and never re-derived here.
  admitted <- .jst_evidence_admits_missing_values(x, evidence)
  admitted <- setdiff(admitted, susp)
  all_vals <- sort(c(susp, admitted))
  if (length(all_vals) == 0) return(character(0))

  codes <- vapply(all_vals, .jst_fmt_code, character(1))
  head_txt <- paste0(
    "Note: ", .jst_and_list(codes), " in '", var_name, "' ",
    if (length(all_vals) == 1L) "looks like a coded missing value"
    else "look like coded missing values")

  # Cite the evidence when it is doing the work, so the user can check
  # the reasoning rather than take the conclusion on trust.
  if (length(admitted) > 0) {
    words <- .jst_missing_evidence_words(evidence)
    head_txt <- paste0(
      head_txt, "; the column also contained the ",
      if (length(words) == 1L) "word " else "words ",
      .jst_jencode_show_words(words))
  }

  paste0(
    .jst_wrap_prose(paste0(head_txt, ".")), "\n",
    .jst_wrap_prose(paste0(
      "Declare ", .jst_and_list(codes), " with jdeclare_udm() so analyses ",
      "exclude ", if (length(all_vals) == 1L) "it." else "them.")))
}


#' Internal helper: render a text map's left-hand side
#'
#' The left-hand-side renderer \code{jencode()} hands to
#' \code{.jst_render_map_string()} when the word-evidence nudge shows
#' the user a map built from values found in their own column. (It also
#' fed the cross-convention echo-back until S246, when that echo-back
#' was retired under Rule Y.) Words render as themselves, quoted when
#' they contain a map separator; the empty string renders as the taught
#' \code{blank} token rather than as a pair of quotes, since the
#' quotes-around-nothing form is deliberately never shown to users.
#'
#' @param old_vals Character vector of old values from one parsed rule.
#'
#' @return Character scalar: the rule's left-hand side.
#'
#' @keywords internal
.jst_jencode_lhs_render <- function(old_vals) {
  paste(vapply(old_vals, function(w) {
    if (!nzchar(w)) return("blank")
    if (grepl("[;=,]", w)) return(paste0("\"", w, "\""))
    w
  }, character(1)), collapse = ",")
}


# -- jdeclare_udm ------------------------------------------------------------

#' Declare user-defined missing values on one or more variables
#'
#' @description
#' \code{jdeclare_udm()} declares one or more user-defined missing
#' values (UDMs) on one or more variables. UDMs are specific data values --
#' typically negative codes such as \code{-99} or Stata-style tagged
#' markers such as \code{.a} -- that indicate \emph{why} a value is
#' missing (refused, don't know, not applicable, etc.) rather than
#' simply that it is missing. Once declared, UDM cells are
#' automatically excluded from analyses but remain visible in the data
#' for diagnostic purposes (see \code{jfreq()}).
#'
#' The function operates in declarative mode: what a call mentions, it
#' replaces; what it omits survives. Supplying \code{codes} replaces the
#' column's discrete-code set; supplying \code{range} replaces the
#' column's missing-value range; an existing range survives a codes-only
#' call, and existing discrete codes survive a range-only call. A second
#' call therefore replaces, not augments, whichever parts it names --
#' matching SPSS's \code{MISSING VALUES} and Stata's \code{mvdecode}
#' semantics, neither of which has an additive form. When prior UDMs are
#' dropped, a note lists them so the destructive aspect of the
#' replacement is not silent.
#'
#' Variables are given either as unquoted names (\code{jdeclare_udm(df,
#' MathScore, EnglishScore, codes = c(-99))}) or as a character vector
#' via \code{vars =} (the programmatic form, e.g.
#' \code{vars = offence_cols}). A multi-variable call applies the same
#' declaration to every named column, all-or-nothing: if any column
#' fails a check, no column is changed. There is deliberately no
#' whole-data-frame default -- declaring a code frame-wide would flag it
#' missing even on columns where that value is legitimate data. To
#' declare on every column, pass \code{vars = names(data)} explicitly.
#'
#' @param data A data frame containing the variable(s).
#' @param ... The variable(s) to declare UDMs on, as unquoted names
#'   (e.g. \code{Income}, or \code{MathScore, EnglishScore}). Use
#'   either \code{...} or \code{vars}, not both. All arguments after
#'   the variables must be named.
#' @param codes Numeric vector of code values to declare as UDMs.
#'   Accepts two forms:
#'   \describe{
#'     \item{Option A (separate codes and labels)}{Unnamed numeric
#'       vector; labels supplied via the \code{labels} argument. E.g.
#'       \code{codes = c(-99, -98), labels = "-99=Refused; -98=Don't know"}.}
#'     \item{Option C (haven-style named vector)}{Named numeric vector;
#'       names are the labels. E.g.
#'       \code{codes = c(Refused = -99, `Don't know` = -98)}.}
#'   }
#'   On a column that already carries Stata-style or SAS-style missing
#'   values, codes may name the markers directly as quoted tokens, e.g.
#'   \code{codes = c(Refused = ".a")} -- a token \code{".a"} means the
#'   \code{.a} marker (or \code{.A} on a SAS-style column: token case is
#'   accepted either way and canonicalized to the column's convention).
#'   Tokens are refused on columns with no tagged missing values to
#'   label (see the Missing-Values Convention section).
#'
#'   A token may name a marker that no case currently carries -- useful
#'   for FORWARD-DECLARING a label before recoding values into it. The
#'   label attaches, nothing in the data changes, and the notification
#'   says the marker is not present in the data. Such a label survives
#'   both a Stata and an SPSS round trip.
#'
#'   A token given with no label is a no-op on an already-tagged
#'   column: the cells are already missing, so the only act available
#'   is naming a marker, and the call reports that it changed nothing.
#'   This differs from the numeric form, where a bare code IS the
#'   declaration.
#' @param labels Optional. A quoted string in the form
#'   \code{"value=label; value=label"} pairing labels with codes
#'   (Option A only). Must be \code{NULL} when \code{codes} is named
#'   (Option C). When a \code{range} is in effect (supplied in this
#'   call, or already on the column), entries may also name values
#'   inside the range: those attach as value labels on the in-range
#'   values without becoming discrete declared codes (see the
#'   Missing-value ranges section).
#' @param range Optional. A length-2 numeric vector declaring a
#'   missing-value RANGE (band), e.g. \code{range = c(-99, -51)} --
#'   every value from the first bound through the second is treated as
#'   missing. The SPSS parallel is \code{MISSING VALUES X (-99 THRU
#'   -51)}. Bounds may be non-integer, and one bound may be infinite
#'   (\code{c(-Inf, -51)} is SPSS's \code{LO THRU -51}). A
#'   missing-value range can exist only under SPSS convention:
#'   combining \code{range} with the Stata or SAS convention -- as a
#'   per-call argument or as the \code{joptions()} setting -- or with
#'   tagged tokens is refused, and the refusal teaches the two-step
#'   route (declare the range under SPSS convention, then
#'   \code{jconvert()} the column) when the range covers few enough
#'   values to convert. When no convention is selected anywhere, a
#'   range declaration stops and asks for \code{convention = "spss"}
#'   on the call. SPSS allows at
#'   most ONE discrete code alongside a range, and the check applies to
#'   the column's composed result (what this call supplies plus what
#'   already survives on the column), so a declaration that a
#'   \code{.sav} file could not hold is refused here rather than at
#'   save time.
#' @param vars Optional. A character vector of variable names, the
#'   programmatic alternative to unquoted names in \code{...}
#'   (e.g. \code{vars = c("Age", "Income")}, or \code{vars =
#'   offence_cols} where \code{offence_cols} holds the names). Use
#'   either \code{vars} or \code{...}, not both.
#' @param convention Optional. One of \code{"spss"}, \code{"stata"}, or
#'   \code{"sas"} (any capitalization is accepted); overrides the
#'   convention resolution for this call. When
#'   \code{NULL} (the default), the convention is resolved from the
#'   column's existing UDM declaration (if any), then from
#'   \code{joptions("missing.convention")}; when neither supplies one,
#'   the call stops with a guided error asking you to choose -- the
#'   package never infers a convention for a fresh declaration. A
#'   \code{range} requires SPSS convention (see \code{range}).
#'   The SAS convention behaves as the Stata convention with uppercase
#'   markers: markers mint and label as \code{.A}-\code{.Z}. Token
#'   input is case-insensitive under both tagged conventions; the case
#'   written to the column follows the resolved convention.
#' @param udm.notice Logical. When \code{TRUE} (the default), the
#'   function prints a notification summarizing what was declared,
#'   plus a reminder of how to keep the result.
#'   Set \code{FALSE} to suppress.
#' @param modify Logical. When \code{TRUE}, the declaration is written
#'   back onto the data frame named in the call (or onto the
#'   \code{juse()} default when the data argument is omitted), so no
#'   assignment is needed -- the recommended workflow, since a
#'   declaration lost to a forgotten assignment silently poisons later
#'   statistics. Requires the data frame to be given as a plain name.
#'   When \code{FALSE} (the default), the caller's data frame is
#'   untouched; assign the returned data frame to keep the
#'   declaration.
#'
#' @return The data frame, with the specified variable(s) updated to
#'   carry the declared UDMs, returned invisibly. With the default
#'   \code{modify = FALSE}, the caller's data frame is unchanged until
#'   the result is assigned back. With \code{modify = TRUE}, the
#'   change is also written back onto the caller's data frame, and the
#'   returned copy can be ignored.
#'
#' @section Missing-Values Convention:
#' Under SPSS convention, codes are declared as numeric values via the
#' column's \code{na_values} attribute (haven's representation of
#' SPSS-form UDMs). The data cells themselves are unchanged; only the
#' metadata that flags certain values as missing is added.
#'
#' Under Stata or SAS convention with tagged missing-value input (quoted
#' tokens such as \code{".a"}), the function attaches value labels to
#' the column's existing tagged missing-value markers. This
#' requires the column to already carry tagged missing values --
#' either tagged cells, or markers previously declared through value
#' labels (a marker may be labeled before any cases carry it, so a
#' declaration made early in data collection is complete for later
#' data). Token case is accepted either way and canonicalized to the
#' resolved convention: lowercase markers under Stata convention,
#' uppercase under SAS. Tokens against a column with no tagged missing
#' values are refused identically under every convention source: on a
#' plain column the error points at \code{jrecode()} (which creates
#' tagged cells from numeric codes); on a column carrying SPSS-style
#' declarations it points at \code{jconvert()}.
#'
#' Note that on a plain numeric column with plain numeric codes and no
#' \code{convention} argument, the resolved convention decides the
#' outcome: under SPSS convention the numbers stay in the cells and are
#' flagged missing; under Stata or SAS convention the matching cells
#' are converted to markers and the numbers leave the data. This is the
#' one place \code{joptions(missing.convention = ...)} changes what
#' happens to data (see the examples).
#'
#' Under Stata or SAS convention with numeric input, the function
#' converts matching cells to tagged missing-value markers (Session 30
#' design lock; SAS convention mints the same letters uppercase). The
#' mapping is ordering-based: codes sorted by absolute value
#' descending, more-negative-first as tie-breaker, then assigned
#' \code{.a}, \code{.b}, \code{.c}, \code{.d} in that order (\code{.A},
#' \code{.B}, ... under SAS convention). The
#' assignment proceeds independently of \code{joptions("udm.convention.codes")}
#' (which only governs the reverse Stata-to-SPSS direction). A
#' conversion note in the standard/full \code{joutput} tier shows the
#' Stata-style equivalent for future calls.
#'
#' @section Missing-value ranges:
#' A range declares a whole band of values missing at once -- the form
#' commercial statistical software uses when a study's sentinel codes
#' share a band (e.g. every code from -99 through -51). SPSS accepts at
#' most three discrete missing values, OR a range, OR a range plus one
#' discrete value; \code{jdeclare_udm()} enforces the same rule on the
#' composed result of each call, so a declaration is refused at the
#' moment it becomes illegal rather than when \code{jsave()} later
#' refuses the file. A range-only call is complete in itself
#' (\code{jdeclare_udm(df, X, range = c(-99, -51))}).
#'
#' Values inside the band may carry value labels: with a range in
#' effect, \code{labels} entries that match no discrete code but fall
#' inside the band attach as ordinary value labels on those values.
#' They do not become discrete declared codes -- the band already
#' covers them -- but analysis output that breaks out in-range values
#' can then show their meanings. Because a range replaces the column's
#' existing range and existing discrete codes survive a range-only
#' call, a column already carrying two or more discrete codes cannot
#' take a range in the same declaration; the call is refused with the
#' surviving codes named.
#'
#' @section Mixed conventions and file export:
#' A single data frame may carry both SPSS-form and Stata-form UDM
#' columns. In-memory analysis and display tolerate the mix without
#' issue (each column renders in its native form). The constraint
#' shows up at file-export time: \code{.sav} cannot
#' represent Stata-style missing values; \code{.dta} cannot represent SPSS-form
#' \code{na_values} declarations; \code{.xpt} can represent neither
#' form. \code{jsave()} pre-flights the DF
#' against the destination format and errors with a pointer to
#' \code{jconvert()} when the mix is incompatible. The
#' post-declaration mismatch notice emitted at the bottom of this
#' function's output exists to alert you early if a declaration
#' ends up out of step with the rest of its DF.
#'
#' @seealso \code{\link{jrecode}}, \code{\link{jconvert}},
#'   \code{\link{joptions}}, \code{\link{jstats}}
#'
#' @examples
#' # A fresh declaration needs a chosen missing-value convention; the
#' # package never infers one. Choose SPSS convention for these examples:
#' joptions(missing.convention = "spss")
#'
#' # clinic$MoodRating arrives "dirty": -99/-98 sit in the data as
#' # ordinary numbers (the state after a CSV or Excel import), so summary
#' # statistics are poisoned until the codes are declared missing.
#' df <- clinic
#' jdesc(df, MoodRating)        # mean dragged far down by -99/-98
#'
#' # SPSS form: declare -99 and -98 as UDMs with labels. modify = TRUE
#' # writes the declaration back onto df in one step -- the recommended
#' # workflow.
#' jdeclare_udm(df, MoodRating,
#'              codes  = c(-99, -98),
#'              labels = "-99=Refused; -98=Don't know",
#'              modify = TRUE)
#' jdesc(df, MoodRating)        # codes now excluded as missing
#'
#' # Equivalent without modify: assign the returned data frame back
#' df2 <- clinic
#' df2 <- jdeclare_udm(df2, MoodRating,
#'                     codes  = c(-99, -98),
#'                     labels = "-99=Refused; -98=Don't know")
#'
#' # Equivalent using named codes (one step instead of codes + labels)
#' df3 <- jdeclare_udm(clinic, MoodRating,
#'                     codes = c("Refused" = -99, "Don't know" = -98))
#'
#' # A missing-value RANGE: every value from -99 through -51 is missing.
#' # SPSS parallel: MISSING VALUES MoodRating (-99 THRU -51).
#' df4 <- jdeclare_udm(clinic, MoodRating, range = c(-99, -51))
#'
#' # Range plus labeled values inside the band, on several variables at
#' # once. The same declaration lands on every named column,
#' # all-or-nothing.
#' \dontrun{
#' jdeclare_udm(mydata, vars = c("Theft", "Assault", "Burglary"),
#'              range  = c(-99, -51),
#'              labels = "-99=Refused; -61=Not applicable",
#'              modify = TRUE)
#' }
#'
#' # Stata-style: label Stata-style missing-value cells. The jrecode() call
#' # turns the literal codes into tagged cells; jdeclare_udm() labels them
#' # by naming the markers as quoted tokens.
#' df5 <- clinic
#' df5$Mood2 <- jrecode(df5, MoodRating,
#'                      map = "-99=.a; -98=.b; else=copy",
#'                      convention = "stata")
#' jdeclare_udm(df5, Mood2,
#'              codes = c("Refused" = ".a", "Don't know" = ".b"),
#'              modify = TRUE)
#'
#' \dontrun{
#' # The same neutral call -- plain numeric codes, no convention argument,
#' # plain column -- forks on joptions(missing.convention = ...):
#' joptions(missing.convention = "spss")
#' df6 <- jdeclare_udm(clinic, MoodRating, codes = c(-99))
#' # -99 stays in the cells, flagged as missing (SPSS-form declaration)
#'
#' joptions(missing.convention = "stata")
#' df7 <- jdeclare_udm(clinic, MoodRating, codes = c(-99))
#' # -99 cells become the .a marker; the number -99 leaves the data
#' }
#'
#' @export
jdeclare_udm <- function(data, ..., codes = NULL, labels = NULL,
                         range = NULL, vars = NULL, convention = NULL,
                         udm.notice = TRUE, modify = FALSE) {

  # Captured before `data` is reassigned below: substitute() on the
  # rebound variable would return the value, not the caller's expression.
  data_sub_expr <- substitute(data)

  # --- Resolve first argument -----------------------------------------------
  arg1 <- .jst_resolve_first_arg(
    data_sub      = data_sub_expr,
    data_missing  = missing(data),
    fn_name       = "jdeclare_udm",
    envir         = parent.frame(),
    accept_vector = FALSE
  )

  data      <- arg1$data
  data_name <- arg1$name

  if (!is.data.frame(data)) {
    .jst_stop("The first argument must be a data frame.")
  }

  # --- Resolve variable list (... vs vars; mutually exclusive) --------------
  # Same dual interface as jconvert(): unquoted names through the dots, or
  # a character vector through vars =. Unlike jconvert(), an empty
  # selection is an ERROR, not a whole-frame default: conversion is
  # representational and round-trips, but a declaration changes analysis
  # semantics -- a code declared frame-wide is flagged missing even on
  # columns where that value is legitimate data. The explicit whole-frame
  # route (vars = names(data)) is named in the error instead. Do not
  # "fix" this asymmetry into consistency with jconvert; it is the point.
  variables <- rlang::enquos(...)

  # Leading-comma-omitted form: if first arg was captured as a bare symbol
  # alongside an active juse() default, prepend it to the variables list.
  if (arg1$mode == "symbol_with_default") {
    extra_quo <- rlang::new_quosure(arg1$first_arg_sub, env = parent.frame())
    variables <- c(list(extra_quo), variables)
    class(variables) <- "quosures"
  }

  dot_names <- if (length(variables) > 0) {
    vapply(variables, rlang::quo_name, character(1))
  } else {
    character(0)
  }

  if (length(dot_names) > 0 && !is.null(vars)) {
    .jst_stop("Use either unquoted variable names (...) or quoted names ",
         "via vars = c(...), but not both.")
  }
  if (!is.null(vars) && (!is.character(vars) || length(vars) == 0L)) {
    .jst_stop("`vars` must be one or more variable names in quotes, ",
         "e.g. vars = c(\"Age\", \"Income\").")
  }

  if (length(dot_names) > 0) {
    target_vars <- dot_names
  } else if (!is.null(vars)) {
    target_vars <- vars
  } else {
    .jst_stop("specify at least one variable to declare on: unquoted names ",
         "(for example jdeclare_udm(", data_name, ", Age, Income, ",
         "codes = c(-99))) or quoted names via vars = c(...).\n",
         "To apply one declaration to every column, pass ",
         "vars = names(", data_name, ") explicitly.",
         fn = "jdeclare_udm")
  }

  if (anyDuplicated(target_vars) > 0L) {
    dups <- unique(target_vars[duplicated(target_vars)])
    .jst_stop("variable name(s) given more than once: ",
              paste0("'", dups, "'", collapse = ", "), ".",
              fn = "jdeclare_udm")
  }

  .jst_check_vars(data, target_vars, data_name)
  n_targets <- length(target_vars)

  # --- Input checks (call-level) --------------------------------------------

  # Labels-only form: `codes` omitted; `labels` carries both the code values
  # and their names (for example labels = "-99=Refused; -98=Don't know", or
  # labels = ".a=Refused; .b=Don't know"). Only available when no range is
  # supplied: with a range in the call, label entries name values inside
  # the band rather than defining discrete codes, so they are routed to
  # the in-range path below instead. Detect before `codes` is touched so
  # missing() reads correctly.
  labels_only <- (missing(codes) || is.null(codes)) && !is.null(labels) &&
                 is.null(range)

  if ((missing(codes) || is.null(codes)) && is.null(labels) &&
      is.null(range)) {
    .jst_stop("Provide `codes` (for example codes = c(-99, -98)), a ",
         "`range` (for example range = c(-99, -51)), or use the ",
         "labels-only form, for example labels = \"-99=Refused; -98=Don't know\" ",
         "or labels = \".a=Refused; .b=Don't know\".")
  }

  has_codes_arg <- !(missing(codes) || is.null(codes))

  if (has_codes_arg && !labels_only) {
    # Accept Stata-style tokens and numeric strings in `codes` so callers
    # need not write haven::tagged_na(): ".a" -> tagged_na("a"); "-99" -> -99.
    if (is.character(codes)) {
      codes <- tryCatch(
        .jst_parse_code_tokens(codes),
        error = function(e) .jst_stop(conditionMessage(e)))
    }
    if (!is.numeric(codes) || length(codes) == 0L) {
      phr0 <- .jst_phrasing_convention(convention)
      tok_ab <- .jst_canonical_tag(c("a", "b"), phr0)
      .jst_stop("`codes` must be one or more numbers (for example ",
           "codes = c(-99, -98)) or ", .jst_convention_label(phr0),
           " tokens (for example ",
           "codes = c(\".", tok_ab[1], "\", \".", tok_ab[2], "\")).")
    }
    # haven::na_tag() (used on parsed_codes below) accepts only double
    # vectors; an integer input -- e.g. codes = -(51:99), the natural way
    # to type a run of codes -- crashed it with a raw haven error before
    # this coercion (S219 sweep finding). Integer input cannot carry
    # tagged NAs, so the coercion is lossless for values; names must be
    # carried across by hand because as.double() drops attributes.
    if (is.integer(codes)) {
      code_nm <- names(codes)
      codes <- as.double(codes)
      names(codes) <- code_nm
    }
  }
  .jst_check_flag(udm.notice, "udm.notice")
  .jst_check_flag(modify, "modify")
  # modify = TRUE writes the result back onto the caller's variable, so the
  # data must arrive as a bare name -- an expression has no name to write to.
  # The juse()-default paths (modes "default" / "symbol_with_default") are
  # fine: the default name is the write-back target there.
  if (isTRUE(modify) && arg1$mode == "explicit" &&
      !is.symbol(data_sub_expr)) {
    .jst_stop("modify = TRUE can only change a data frame that has a name.\n",
         "Name the data first, then rerun with modify = TRUE:\n",
         "  mydata <- ", paste(deparse(data_sub_expr), collapse = " "), "\n",
         "  jdeclare_udm(mydata, ..., modify = TRUE)")
  }

  # Validate convention argument up front.
  if (!is.null(convention)) {
    # Platform specs are case-insensitive (accept "SPSS", "Stata", ...).
    if (is.character(convention) && length(convention) == 1L &&
        !is.na(convention)) {
      convention <- tolower(convention)
    }
    if (!is.character(convention) || length(convention) != 1L ||
        !convention %in% c("spss", "stata", "sas")) {
      .jst_stop_arg(arg = "convention", choices = c("spss", "stata", "sas"))
    }
  }

  # --- Validate range (call-level) ------------------------------------------
  if (!is.null(range)) {
    if (!is.numeric(range) || length(range) != 2L || anyNA(range)) {
      .jst_stop("`range` must be two numbers giving the bounds of the ",
           "missing-value range, for example range = c(-99, -51).")
    }
    if (all(is.infinite(range))) {
      .jst_stop("`range` cannot be infinite at both ends; that would ",
           "declare every value missing.\n",
           "Use one finite bound, for example range = c(-Inf, -51).")
    }
    range <- sort(as.numeric(range))

    # --- Guards E and D: a range against a non-SPSS convention (S244) ------
    # A missing-value range can exist only in the SPSS representation
    # (haven's na_range). Guard E refuses the per-call pair (range +
    # convention = "stata"/"sas"; the reworded and relocated successor
    # of the S219 call-level guard -- same refusal set, new render).
    # Guard D refuses the setting-level conflict the removed forcing
    # line used to override silently: a live S243 run showed a stata
    # setting + range declaring SPSS-form. Both guards sit after
    # variable resolution so the in-band count is computable, and both
    # are DATA-AWARE (one builder, head parameter x fits/over-cap
    # fork): the two-step stay-tagged recipe renders only when EVERY
    # targeted column's range covers 26 or fewer values (jconvert's
    # cap); over the cap, the count line, the SPSS remedy, and the
    # Rule X requirement sentence. Guard D leaves columns that carry
    # their own convention alone: an SPSS-form column resolves itself
    # at Level 1 (Decision 11 precedence, unchanged), and a
    # tagged-form column falls to the per-column range guard below,
    # whose convert-first remedy is the right one there. Both written
    # as != "spss" so any future non-SPSS convention token is covered
    # without edits here.
    if (!is.null(convention) && convention != "spss") {
      nb <- .jst_gate_inband_counts(data, target_vars, range)
      ov <- which(nb > 26L)
      .jst_stop(.jst_choose_convention_error(
                  variant   = "conflict_call",
                  fn        = "jdeclare_udm",
                  conv      = convention,
                  fits      = length(ov) == 0L,
                  data_name = data_name,
                  var_names = target_vars,
                  range     = range,
                  over_var  = if (length(ov) > 0L) target_vars[ov[1L]],
                  over_n    = if (length(ov) > 0L) nb[ov[1L]]),
                fn = "jdeclare_udm")
    }
    if (is.null(convention)) {
      opt_conv <- getOption(".jst_options_missing_convention",
                            .jst_options_defaults$missing.convention)
      if (opt_conv %in% c("stata", "sas")) {
        settable <- vapply(target_vars, function(v)
          is.null(.jst_missing_info(data[[v]])), logical(1))
        if (any(settable)) {
          nb <- .jst_gate_inband_counts(data, target_vars, range)
          ov <- which(nb > 26L)
          .jst_stop(.jst_choose_convention_error(
                      variant   = "conflict_setting",
                      fn        = "jdeclare_udm",
                      conv      = opt_conv,
                      fits      = length(ov) == 0L,
                      data_name = data_name,
                      var_names = target_vars,
                      range     = range,
                      over_var  = if (length(ov) > 0L) target_vars[ov[1L]],
                      over_n    = if (length(ov) > 0L) nb[ov[1L]]),
                    fn = "jdeclare_udm")
        }
      }
    }
  }

  # --- Parse labels (Option A path and the labels-only form) ---------------
  parsed_labels <- NULL
  if (!is.null(labels)) {
    if (!is.character(labels) || length(labels) != 1L) {
      .jst_stop("The labels argument must be a single quoted string, e.g. ",
           "labels = \"-99=Refused; -98=Don't know\".")
    }
    parsed_labels <- tryCatch(
      .jst_parse_labels(labels),
      error = function(e) .jst_stop(paste0("Error in labels argument: ",
                                       conditionMessage(e)))
    )
  }

  # --- Argument disambiguation (Option A vs Option C) ----------------------
  # Skipped for the labels-only form, where the parsed labels are themselves
  # the codes (resolved at parsed_codes construction, below).
  if (!labels_only && has_codes_arg) {
    codes_names <- names(codes)
    has_all_names <- !is.null(codes_names) && all(nzchar(codes_names))
    has_any_names <- !is.null(codes_names) && any(nzchar(codes_names))
    partial_names <- has_any_names && !has_all_names

    if (partial_names) {
      .jst_stop("`codes` is partially named. Either name every ",
                "element (Option C) or none (Option A with separate labels=).",
                fn = "jdeclare_udm")
    }

    if (has_all_names && !is.null(labels)) {
      .jst_stop("pick one labeling form. Either name every ",
                "element of `codes` (Option C) OR supply `labels = ...` ",
                "separately (Option A), not both.",
                fn = "jdeclare_udm")
    }
  } else {
    has_all_names <- FALSE
  }

  # --- Build the canonical parsed_codes (named numeric, names = labels) ----
  #
  # parsed_codes is the internal canonical form: a named numeric vector
  # where names are the labels (empty string where none) and values are
  # the code values (numeric or tagged-NA). All branches below consume
  # this form. label_residue collects labels entries that match no code;
  # with a range in effect they may label values INSIDE the band, and
  # are validated per column below (a residue entry outside every target
  # column's band is an error there).
  label_residue <- NULL
  if (labels_only) {
    # Labels-only form: the parsed labels ARE the codes -- a named vector
    # whose names are the labels and whose values are numeric or tagged-NA.
    parsed_codes <- parsed_labels
  } else if (!has_codes_arg) {
    # Range-only call (with or without labels): no discrete codes; every
    # labels entry is a candidate in-range label.
    parsed_codes <- stats::setNames(numeric(0), character(0))
    label_residue <- parsed_labels
  } else if (has_all_names) {
    # Option C: names are labels directly.
    parsed_codes <- codes
  } else {
    # Option A: codes is unnamed numeric; pair with labels by code value.
    if (is.null(parsed_labels)) {
      parsed_codes        <- codes
      names(parsed_codes) <- rep("", length(codes))
    } else {
      # Match each entry in parsed_labels by code value to codes.
      # parsed_labels is a named numeric vector (names = labels,
      # values = numeric or tagged_na). For each code in `codes`, look
      # up the matching parsed_labels entry.
      assigned <- rep(NA_character_, length(codes))
      pl_tags  <- haven::na_tag(parsed_labels)
      c_tags   <- haven::na_tag(codes)
      for (i in seq_along(codes)) {
        if (!is.na(c_tags[i])) {
          # tagged-NA code: match by tag letter
          idx <- which(!is.na(pl_tags) & pl_tags == c_tags[i])
        } else {
          # numeric code: match by numeric value (ignore tagged entries)
          idx <- which(is.na(pl_tags) & !is.na(parsed_labels) &
                       parsed_labels == codes[i])
        }
        if (length(idx) > 0L) {
          assigned[i] <- names(parsed_labels)[idx[1]]
        }
      }
      # Labels that matched no code become residue: legal only where a
      # missing-value range is in effect and the value falls inside it
      # (validated per column below).
      pl_unused_idx <- setdiff(seq_along(parsed_labels),
                               unique(unlist(lapply(seq_along(codes),
                                 function(i) {
                                   if (!is.na(c_tags[i])) {
                                     which(!is.na(pl_tags) & pl_tags == c_tags[i])
                                   } else {
                                     which(is.na(pl_tags) & !is.na(parsed_labels) &
                                           parsed_labels == codes[i])
                                   }
                                 }))))
      if (length(pl_unused_idx) > 0L) {
        label_residue <- parsed_labels[pl_unused_idx]
      }

      parsed_codes <- codes
      assigned[is.na(assigned)] <- ""
      names(parsed_codes) <- assigned
    }
  }

  # Residue entries written as Stata-style tokens can never be in-range
  # labels (a band is an SPSS-form structure; tokens are Stata-form), so
  # they are refused here rather than per column.
  if (!is.null(label_residue) && length(label_residue) > 0L) {
    res_tags <- haven::na_tag(label_residue)
    if (any(!is.na(res_tags))) {
      bad <- which(!is.na(res_tags))
      bad_render <- paste(
        vapply(bad, function(i) sprintf(".%s=%s", res_tags[i],
                                        names(label_residue)[i]),
               character(1)), collapse = "; ")
      .jst_stop("labels argument contains ",
                .jst_convention_label(.jst_phrasing_convention(convention)),
                " token entries that ",
                "do not match any token in `codes`: ", bad_render, ".\n",
                "Token entries label markers named in `codes`; they cannot ",
                "name values inside a missing-value range.",
                fn = "jdeclare_udm")
    }
  }
  has_residue <- !is.null(label_residue) && length(label_residue) > 0L

  # --- Detect tagged-NA elements -------------------------------------------
  c_tags         <- haven::na_tag(parsed_codes)
  tag_idx        <- which(!is.na(c_tags))
  num_idx        <- setdiff(seq_along(parsed_codes), tag_idx)
  has_tagged     <- length(tag_idx) > 0L
  has_numeric    <- length(num_idx) > 0L

  # First tagged token in the call, for the choose-first gate's head
  # echo (S244; parser-normalized lowercase). Reachable at level 4 only
  # from an ambiguous mixed-case column: a clean tagged column resolves
  # itself at level 1, and tokens on a plain or SPSS-form column are
  # refused at sign-off 3 before resolution.
  gate_marker <- if (has_tagged) paste0(".", c_tags[tag_idx[1L]]) else NULL

  # A range is SPSS-only; tagged tokens are Stata-form. The two cannot
  # appear in one declaration.
  if (!is.null(range) && has_tagged) {
    .jst_stop("a missing-value `range` exists only under SPSS convention ",
         "and cannot be combined with ",
         .jst_convention_label(.jst_phrasing_convention(convention)),
         " tokens in `codes`.\n",
         "Declare the range with numeric codes only, or drop `range` ",
         "and label the markers with tokens alone.",
         fn = "jdeclare_udm")
  }

  # --- Sign-off 4: reject mixed tagged + numeric ---------------------------
  if (has_tagged && has_numeric) {
    .jst_stop(.jst_jdeclare_udm_mixed_error(parsed_codes, data_name,
                                            target_vars[1],
                                            per_call_convention = convention))
  }

  # ==========================================================================
  #  Per-column build pass (all-or-nothing: nothing is assigned until
  #  every target column has built cleanly)
  # ==========================================================================

  results   <- vector("list", n_targets)
  build_err <- character(0)

  for (ti in seq_len(n_targets)) {
    vn <- target_vars[ti]
    res <- tryCatch({
      col <- data[[vn]]

      # Type guard: declaring numeric codes on a text or factor column is
      # destructive (text coerces to all-NA; a factor is silently replaced
      # by its internal integer codes), so both are refused with a fix.
      if (is.character(col) ||
          (haven::is.labelled(col) && typeof(col) == "character")) {
        .jst_stop("'", vn, "' is a character (text) variable; missing-value ",
             "codes can only be declared on numeric variables.\n",
             "If the values are numbers stored as text, convert with as.numeric() first.")
      }
      if (is.factor(col)) {
        .jst_stop("'", vn, "' is a factor; missing-value codes can only be ",
             "declared on numeric variables.\n",
             "If the categories are numbers, convert with as.numeric(as.character(...)) first.")
      }

      # --- Read existing UDM info on the column ----------------------------
      # Feed switched from $representation to $convention (S240, Decision
      # 13 parity): an uppercase-tag column now reads "sas" (so its mints
      # and gate messages go uppercase), a lowercase-tag column "stata",
      # an SPSS-form column "spss". A MIXED-case column reads NA
      # (ambiguous) -- it casts no vote, falls through the resolver, and
      # skips the sign-off 2 conflict gate below; every comparison on
      # this value must therefore be NA-safe.
      existing_info <- .jst_missing_info(col)
      existing_conv <- if (!is.null(existing_info)) existing_info$convention
                       else NULL

      # Stata-form evidence check (S218). .jst_missing_info detects tagged
      # CELLS; a forward-declared column (tagged value labels, no tagged
      # cells yet -- e.g. a marker declared before any cases carry it) is
      # Stata-form too, and must resolve as such: otherwise an SPSS-resolved
      # convention would route its tagged tokens into the numeric branch.
      col_has_stata_form <- FALSE
      if (is.double(col)) {
        if (any(!is.na(haven::na_tag(col)))) {
          col_has_stata_form <- TRUE
        } else if (haven::is.labelled(col)) {
          vl_probe <- labelled::val_labels(col)
          if (!is.null(vl_probe) && length(vl_probe) > 0L &&
              any(!is.na(haven::na_tag(vl_probe)))) {
            col_has_stata_form <- TRUE
          }
        }
      }
      if (is.null(existing_conv) && col_has_stata_form) existing_conv <- "stata"

      # --- Sign-off 3 (hoisted S218): tagged tokens need a Stata-form column
      # Runs BEFORE convention resolution, so the outcome is identical under
      # every convention source (per-call argument, joptions setting, or the
      # default). jdeclare_udm labels existing Stata-style missings; it does
      # not create them, so tagged tokens against a column with no Stata-form
      # representation are refused whatever the convention says.
      if (has_tagged && !col_has_stata_form) {
        if (identical(existing_conv, "spss")) {
          # Column carries SPSS-style declarations: point at the column's own
          # codes and at jconvert (S218 builder rewrite; phrasing convention
          # threaded S240 so a sas-setting user reads uppercase tokens and a
          # to = "sas" remedy).
          err_msg <- .jst_jdeclare_udm_convention_error(
            parsed_codes        = parsed_codes,
            data_name           = data_name,
            var_name            = vn,
            col                 = col,
            per_call_convention = convention
          )
          .jst_stop(err_msg)
        }
        # Plain column: tagged tokens have no tagged cells to label. Point
        # at the tools that create them. Phrased in the display-time
        # convention (S240) with gate-ready remedies: both suggested calls
        # carry an explicit convention =, so pasting them verbatim survives
        # the unset state under the Decision 11 choose-first gate
        # (shipped S244).
        phr       <- .jst_phrasing_convention(convention)
        tok_style <- .jst_convention_label(phr)
        tok_range <- if (identical(phr, "sas")) ".A-.Z" else ".a-.z"
        tok_ex    <- .jst_canonical_tag("a", phr)
        .jst_stop(
          .jst_wrap_prose(paste0(
            "'", vn, "' has no tagged missing values to label, so ",
            tok_style, " tokens (", tok_range, ") cannot be applied ",
            "here."), reserve = 16L),
          "\n",
          .jst_wrap_prose(paste0(
            "To turn numeric codes into tagged missings, use jrecode() ",
            "(for example map = \"-99=.", tok_ex, "\", convention = \"",
            phr, "\"); or declare the numbers directly with ",
            "codes = c(-99), convention = \"", phr, "\".")))
      }

      # A range cannot land on a tagged-form column: the band is an
      # SPSS-form structure with no Stata/SAS representation. Written as
      # not-"spss" (S240) so it covers "stata", "sas", AND the NA of a
      # mixed-case column -- all three are structurally tagged form.
      if (!is.null(range) && !is.null(existing_conv) &&
          !identical(existing_conv, "spss")) {
        carried <- if (is.na(existing_conv)) {
          "tagged (Stata/SAS-style)"
        } else {
          .jst_convention_label(existing_conv)
        }
        .jst_stop(
          .jst_wrap_prose(paste0(
            "'", vn, "' carries ", carried, " missing values; a ",
            "missing-value range exists only under SPSS convention."),
            reserve = 16L),
          "\n",
          "Use jconvert() to convert the column to SPSS form first.",
          fn = "jdeclare_udm")
      }

      # --- Sign-off 2: per-call convention vs existing column UDM conflict -
      # NA-ambiguous (mixed-case) columns SKIP this gate by design (S240
      # ruling): with no column vote there is no contradiction to catch,
      # matching the resolver's fall-through semantics -- the per-call
      # argument genuinely governs there. The gate still refuses every
      # clean-column conflict, so jdeclare_udm can never CREATE a mixed
      # column out of a clean one; the post-apply mixed-marker note below
      # covers columns that arrived mixed.
      if (!is.null(convention) && !is.null(existing_conv) &&
          !is.na(existing_conv) && existing_conv != convention) {
        other_form <- .jst_convention_label(existing_conv)
        .jst_stop(
          .jst_wrap_prose(paste0(
            "Column '", vn, "' already carries ", other_form,
            " missing values; cannot use convention = \"", convention,
            "\" here."), reserve = 16L),
          "\n",
          .jst_wrap_prose(paste0(
            "Use jconvert() to convert the column first, or omit the ",
            "convention argument.")))
      }

      # --- Resolve convention ----------------------------------------------
      # The range-forcing line is GONE (Decision 11 step (4), S244): a
      # range no longer silently overrides the resolution. Legal range
      # calls reach SPSS through the column's own form (level 1), a
      # per-call convention = "spss" (level 2), or an spss setting
      # (level 3); a stata/sas per-call or setting was refused by
      # guards E and D above, a tagged-form column + range was refused
      # just above, and the never-set state gates at level 4 with the
      # single per-call fix line (act = "range").
      resolved_convention <- .jst_resolve_convention(
        per_call          = convention,
        column_convention = existing_conv,
        act               = if (!is.null(range)) "range"
                            else if (has_tagged) "tagged"
                            else "codes",
        fn                = "jdeclare_udm",
        marker            = gate_marker
      )

      # --- Canonicalize parsed tag case for THIS column (S240) -------------
      # Mint case follows the resolved convention (Decision 13): parsers
      # normalize tokens to lowercase, so under a sas resolution the tags
      # must be uppercased before dispatch -- the D3 strip-and-relabel
      # match and every mint site inherit the case from this one point.
      # Done on a per-column COPY because resolution is per column: two
      # columns in one call can legitimately canonicalize differently.
      # (Mirrors the jrecode/jencode canonicalize-once pattern at the
      # per-column scope this function resolves at.)
      pc <- parsed_codes
      if (resolved_convention %in% c("stata", "sas") && has_tagged) {
        tg  <- haven::na_tag(pc)
        idx <- which(!is.na(tg))
        if (length(idx) > 0L) {
          canon <- .jst_canonical_tag(tg[idx], resolved_convention)
          for (k in seq_along(idx)) {
            pc[idx[k]] <- haven::tagged_na(canon[k])
          }
        }
      }

      # Mixed-column edge (S240): fires only on an AMBIGUOUS (mixed-case)
      # column whose resolution fell through to spss -- a clean tagged
      # column resolves its own convention at Level 1, tokens on an
      # SPSS-form or plain column were refused at sign-off 3, and a
      # pathological both-representations input keeps its historical D1
      # path (existing_conv "spss" there, not NA). Without this guard,
      # token calls would die on a misleading "codes must be finite"
      # error, and numeric-code calls would mint na_values BESIDE the
      # tagged cells -- creating the both-representations state
      # .jst_missing_info treats as pathological.
      if (resolved_convention == "spss" && !is.null(existing_conv) &&
          is.na(existing_conv)) {
        .jst_stop(
          .jst_wrap_prose(paste0(
            "'", vn, "' carries tagged missing values in both letter ",
            "cases, which the resolved convention (SPSS) cannot act on."),
            reserve = 16L),
          "\n",
          "Set convention = \"stata\" or convention = \"sas\" on this ",
          "call.")
      }

      # --- Validate in-range label residue against this column -------------
      # Residue entries must fall inside the effective band: the range
      # supplied in this call, or failing that the band already on the
      # column. No band, or a value outside it, is an error here.
      inband_labels <- NULL
      if (has_residue) {
        if (resolved_convention != "spss") {
          .jst_stop("labels argument contains entries that do not match ",
               "any value in `codes`: ",
               .jst_render_label_entries(label_residue), ".\n",
               "Only SPSS-form columns can carry in-range value labels.",
               fn = "jdeclare_udm")
        }
        band <- if (!is.null(range)) range else {
          er <- attr(col, "na_range")
          if (!is.null(er) && length(er) == 2L) as.numeric(sort(er)) else NULL
        }
        if (is.null(band)) {
          .jst_stop("labels argument contains entries that do not match ",
               "any value in `codes`, and '", vn, "' has no ",
               "missing-value range they could fall inside: ",
               .jst_render_label_entries(label_residue), ".",
               fn = "jdeclare_udm")
        }
        res_vals <- as.numeric(label_residue)
        outside  <- res_vals < band[1] | res_vals > band[2]
        if (any(outside)) {
          .jst_stop("labels argument contains entries that match no value ",
               "in `codes` and fall outside the missing-value range (",
               format(band[1]), " to ", format(band[2]), ") on '", vn,
               "': ",
               .jst_render_label_entries(label_residue[outside]), ".",
               fn = "jdeclare_udm")
        }
        inband_labels <- label_residue
      }

      # --- Branch dispatch --------------------------------------------------
      # Tagged branches consume the canonicalized per-column copy (pc);
      # the SPSS branch takes the original (no tags can reach it).
      conversion_info <- NULL
      # S247: per-marker truthfulness annotations, filled by the tagged
      # canonical branch only -- the other two report what they declared,
      # which is what they did.
      marker_notes <- NULL
      if (resolved_convention == "spss") {
        # ---------- Branch D1: SPSS canonical (numeric codes / range) ------
        new_col <- .jst_jdeclare_udm_spss(col, parsed_codes, vn,
                                          range         = range,
                                          inband_labels = inband_labels)
        branch  <- "spss_canonical"

      } else if (has_tagged) {
        # ---------- Branch D3: Stata/SAS canonical (tagged-NA labeling) ----
        new_col <- .jst_jdeclare_udm_stata_label(col, pc)
        branch  <- "stata_canonical"
        marker_notes <- .jst_jdeclare_udm_marker_notes(col, new_col, pc)

      } else {
        # ---------- Branch D4: Stata/SAS conversion (numeric -> tagged) ----
        conv_result <- .jst_jdeclare_udm_stata_convert(col, pc, vn,
                         convention = resolved_convention)
        new_col <- conv_result$new_col
        branch  <- "stata_conversion"
        # Conversion-specific info for the notification.
        conversion_info <- conv_result
      }

      list(new_col = new_col, branch = branch,
           conversion_info = conversion_info,
           existing_info = existing_info,
           resolved_convention = resolved_convention,
           parsed_codes_used = pc,
           marker_notes = marker_notes)
    }, error = function(e) {
      structure(list(msg = conditionMessage(e)), class = "jst_build_err")
    })

    if (inherits(res, "jst_build_err")) {
      build_err <- c(build_err,
                     stats::setNames(res$msg, vn))
    } else {
      results[[ti]] <- res
    }
  }

  # All-or-nothing: any failure means no column is changed.
  if (length(build_err) > 0L) {
    if (n_targets == 1L) {
      # Single-variable call: re-raise the original message untouched
      # (it already carries the variable name where relevant).
      stop(build_err[[1L]], call. = FALSE)
    }
    lines <- vapply(seq_along(build_err), function(i) {
      m <- sub("^jdeclare_udm\\(\\): ", "", build_err[[i]])
      paste0("  ", names(build_err)[i], ": ",
             gsub("\n", "\n    ", m, fixed = TRUE))
    }, character(1))
    .jst_stop("cannot declare on ", length(build_err), " of ", n_targets,
              " variables; no variable was changed:\n",
              paste(lines, collapse = "\n"),
              fn = "jdeclare_udm")
  }

  # ==========================================================================
  #  Apply pass (all builds clean; assign and collect notices)
  # ==========================================================================

  drop_notices <- character(0)
  mixed_notes  <- character(0)

  for (ti in seq_len(n_targets)) {
    vn  <- target_vars[ti]
    res <- results[[ti]]
    new_col       <- res$new_col
    branch        <- res$branch
    existing_info <- res$existing_info

    data[[vn]] <- new_col

    # --- Mixed-marker note (S240, consequential) ---------------------------
    # A declared-on column that carries tags in BOTH letter cases after
    # the call gets a note naming the mix and the collapse remedy. Only a
    # column that ARRIVED mixed can be in this state (sign-off 2 plus the
    # resolver's column-wins level prevent creating a mix from a clean
    # column), so the note fires rarely and persists only until remedied.
    # Remedy target follows THIS call's resolved convention -- the user's
    # demonstrated preference. No joptions rider (S227 rule check): this
    # is a column-scoped collapse, not a mixed-frame align line -- a
    # cleaned column resolves by its own form at Level 1 thereafter, so
    # the re-mix bite the rider prevents cannot occur.
    if (branch != "spss_canonical") {
      post_tags <- haven::na_tag(new_col)
      post_tags <- post_tags[!is.na(post_tags)]
      if (haven::is.labelled(new_col)) {
        vl_post <- labelled::val_labels(new_col)
        if (!is.null(vl_post) && length(vl_post) > 0L) {
          lt <- haven::na_tag(vl_post)
          post_tags <- c(post_tags, lt[!is.na(lt)])
        }
      }
      post_tags <- unique(post_tags)
      lo_tags <- sort(post_tags[post_tags %in% letters])
      up_tags <- sort(post_tags[post_tags %in% LETTERS])
      if (length(lo_tags) > 0L && length(up_tags) > 0L) {
        mixed_notes <- c(mixed_notes, paste0(
          .jst_wrap_prose(paste0(
            "Note: ", vn, " carries both Stata-style (",
            paste0(".", lo_tags, collapse = ", "),
            ") and SAS-style (",
            paste0(".", up_tags, collapse = ", "),
            ") missing-value markers.")),
          "\n",
          "To collapse them to one form:\n",
          "  jconvert(", data_name,
          ", to = \"", res$resolved_convention, "\", vars = \"", vn,
          "\", modify = TRUE)"))
      }
    }

    # --- Sign-off 5: drop notice -------------------------------------------
    if (!is.null(existing_info)) {
      # Determine which existing codes are not in the new set. Both arms
      # compare against the column's actual RESULTING state, not against
      # the call's argument list (S218 principle, extended to the SPSS arm
      # when range-only calls made "codes absent from the call" no longer
      # mean "codes dropped": a range-only declaration preserves existing
      # discrete codes, and the old parsed_codes comparison would have
      # falsely reported them dropped).
      if (existing_info$representation == "spss") {
        old_codes <- if (is.null(existing_info$codes)) numeric(0)
                     else as.numeric(existing_info$codes$numeric)
        new_codes <- if (branch == "spss_canonical") {
          nv <- attr(new_col, "na_values")
          if (is.null(nv)) numeric(0) else as.numeric(nv)
        } else {
          # branch ended up Stata; everything SPSS-side is dropped
          numeric(0)
        }
        dropped_mask <- !old_codes %in% new_codes
      } else {
        # existing is Stata-form
        old_tags <- existing_info$codes$tag
        new_tags <- if (branch %in% c("stata_canonical", "stata_conversion")) {
          # Tags present in cells or declared through value labels -- the
          # Stata-side branches have keep-semantics (a marker absent from
          # the call is untouched, not dropped), so a call-list comparison
          # falsely reported preserved markers as dropped (S218 fix;
          # surfaced by the forward-declaration pattern, where each call
          # names only the new marker).
          nt <- haven::na_tag(new_col)
          nt <- nt[!is.na(nt)]
          if (haven::is.labelled(new_col)) {
            vl_new <- labelled::val_labels(new_col)
            if (!is.null(vl_new) && length(vl_new) > 0L) {
              lt <- haven::na_tag(vl_new)
              nt <- c(nt, lt[!is.na(lt)])
            }
          }
          unique(nt)
        } else {
          # branch ended up SPSS; everything Stata-side is dropped
          character(0)
        }
        dropped_mask <- !old_tags %in% new_tags
      }
      if (any(dropped_mask)) {
        drop_notices <- c(drop_notices, .jst_jdeclare_udm_drop_notice(
          dropped_df     = existing_info$codes[dropped_mask, , drop = FALSE],
          var_name       = vn,
          representation = existing_info$representation
        ))
      }
    }
  }

  # --- modify = TRUE write-back --------------------------------------------
  # Writes the modified frame back onto the caller's variable (bare-symbol
  # calls; guarded above) or onto the juse() default name. Same caller-
  # environment assign as jcopy(). The frame is still returned invisibly
  # below, so every call shape composes.
  if (isTRUE(modify)) {
    modify_target <- if (arg1$mode == "explicit") as.character(data_sub_expr)
                     else arg1$name
    assign(modify_target, data, envir = parent.frame())
  }

  # --- Column-vs-option override notes (D2, S239; consequential) -----------
  # Fires when the column's own form (resolver level 1) overrode an
  # EXPLICITLY SET missing.convention (level 3). A per-call convention or
  # range is the user answering the question -- level 2 -- so those calls
  # are out; the "none" default already distinguishes chose from
  # never-chose. Fires each call: a jdeclare_udm call is a deliberate
  # convention choice, so the once-per-session gate was declined.
  override_notes <- list()
  d2_opt <- getOption(".jst_options_missing_convention",
                      .jst_options_defaults$missing.convention)
  if (is.null(convention) && is.null(range) &&
      d2_opt %in% c("spss", "stata", "sas")) {
    for (ti in seq_len(n_targets)) {
      ex <- results[[ti]]$existing_info
      ex_conv <- if (is.null(ex)) NULL else ex$convention
      if (!is.null(ex_conv) && !is.na(ex_conv) &&
          !identical(ex_conv, d2_opt)) {
        override_notes[[length(override_notes) + 1L]] <-
          list(var = target_vars[ti], col_conv = ex_conv)
      }
    }
  }

  # --- Build and emit notification -----------------------------------------
  if (isTRUE(udm.notice)) {
    if (n_targets == 1L) {
      notif <- .jst_jdeclare_udm_notification(
        data_name           = data_name,
        var_name            = target_vars[1L],
        parsed_codes        = results[[1L]]$parsed_codes_used,
        branch              = results[[1L]]$branch,
        conversion_info     = if (results[[1L]]$branch == "stata_conversion")
                                results[[1L]]$conversion_info else NULL,
        modify              = modify,
        range               = range,
        inband_labels       = if (has_residue) label_residue else NULL,
        resolved_convention = results[[1L]]$resolved_convention,
        marker_notes        = results[[1L]]$marker_notes
      )
    } else {
      notif <- .jst_jdeclare_udm_bulk_notification(
        data_name     = data_name,
        target_vars   = target_vars,
        results       = results,
        parsed_codes  = parsed_codes,
        range         = range,
        inband_labels = if (has_residue) label_residue else NULL,
        modify        = modify
      )
    }
    cat(notif, sep = "")
  }

  # D2 override notes, grouped by the column form. The primary
  # notification above already names the resolved form, so the note goes
  # straight to the mismatch and the two remedies (Rule R's
  # otherwise-evident carve-out).
  if (length(override_notes) > 0L && isTRUE(udm.notice)) {
    cat("\n")   # Rule F: a blank line off the notification block above
    convs   <- unique(vapply(override_notes, `[[`, character(1),
                             "col_conv"))
    d2_msgs <- character(0)
    for (cv in convs) {
      vars_cv <- vapply(Filter(function(o) identical(o$col_conv, cv),
                               override_notes),
                        `[[`, character(1), "var")
      verb <- if (length(vars_cv) == 1L) "uses" else "use"
      d2_msgs <- c(d2_msgs, paste0(
        .jst_wrap_prose(paste0(
          "Note: ", .jst_format_var_list(vars_cv, and = TRUE), " ", verb,
          " ", .jst_convention_label(cv), " missing values, but your ",
          "missing.convention setting is ",
          .jst_convention_label(d2_opt), ".")), "\n",
        "To convert the data frame, run:\n",
        "  jconvert(", data_name, ", to = \"", d2_opt,
        "\", modify = TRUE)\n",
        "To keep ", .jst_convention_label(cv),
        " instead, change the setting:\n",
        "  joptions(missing.convention = \"", cv, "\")"))
    }
    cat(paste(d2_msgs, collapse = "\n\n"), "\n", sep = "")
  }

  # Drop notices fire after the main notification (consistent with the
  # established pattern of placing follow-on notes after the primary
  # output block).
  if (length(drop_notices) > 0L && isTRUE(udm.notice)) {
    cat(paste(drop_notices, collapse = "\n"), "\n", sep = "")
  }

  # Mixed-marker notes (S240): consequential level, so always shown when
  # notices are on; column-level before the frame-level mismatch notice.
  if (length(mixed_notes) > 0L && isTRUE(udm.notice)) {
    cat(paste(mixed_notes, collapse = "\n"), "\n", sep = "")
  }

  # --- Post-declaration mismatch notice (Decision 11 closing rule) ---------
  # Detection is unchanged: predominance over the WHOLE frame decides
  # whether the notice fires. The verb, though, describes the "other
  # columns" -- so unanimity is judged over the frame MINUS the
  # mismatched variables, matching what the sentence claims (S226;
  # excluding a minority can only strengthen or unanimize the same
  # verdict, never flip it).
  if (isTRUE(udm.notice)) {
    df_predominant <- .jst_predominant_convention(data)
    if (!is.na(df_predominant)) {
      mismatched <- target_vars[vapply(results, function(r)
        r$resolved_convention != df_predominant, logical(1))]
      if (length(mismatched) > 0L) {
        this_conv  <- results[[match(mismatched[1L], target_vars)]]$resolved_convention
        this_form  <- .jst_convention_label(this_conv)
        other_form <- .jst_convention_label(df_predominant)
        others_census <- .jst_convention_census(
          data[, setdiff(names(data), mismatched), drop = FALSE])
        other_verb <- if (isTRUE(others_census$unanimous)) "are"
                      else "are predominantly"
        # S227: variable names stand alone -- the leading "variable" /
        # "variables" is dropped. A variable name carries its own case
        # and the context makes the kind obvious, unlike a frame name at
        # the head of the joptions nudge (which takes an article). Plural
        # lists are and-joined, matching that note.
        # S242 (mv R2): the opening spends the full locked term
        # ("uses Stata-style missing values") on first mention and drops
        # to the bare style word for the second clause, matching shipped
        # D2 read side by side. "Mixing forms is allowed." replaces the
        # two-word "if desired" hedge, which was carrying the whole
        # reassurance load. The remedy becomes a runnable Rule L line
        # (jconvert carries a vars formal); singular takes a bare
        # vars = "Income", plural takes c(...). One remedy only, not
        # D2's two -- here the frame is simply the frame, so Rule D's
        # one-fix applies.
        vars_arg <- if (length(mismatched) == 1L) {
          paste0("\"", mismatched[1L], "\"")
        } else {
          paste0("c(", paste0("\"", mismatched, "\"", collapse = ", "), ")")
        }
        head_line <- if (length(mismatched) == 1L) {
          sprintf("Note: %s uses %s missing values, but other columns in %s %s %s.",
                  mismatched[1L], this_form, data_name, other_verb, other_form)
        } else {
          sprintf("Note: %s use %s missing values, but other columns in %s %s %s.",
                  .jst_format_var_list(mismatched, and = TRUE), this_form,
                  data_name, other_verb, other_form)
        }
        align_obj <- if (length(mismatched) == 1L) mismatched[1L] else "them"
        cat(paste0(
          .jst_wrap_prose(head_line), "\n",
          "Mixing forms is allowed. To align ", align_obj,
          " with the rest, run:\n",
          "  jconvert(", data_name, ", to = \"", df_predominant,
          "\", vars = ", vars_arg, ", modify = TRUE)\n"))
      }
    }
  }

  invisible(data)
}


# -----------------------------------------------------------------------------
# Branch D1: SPSS canonical
# -----------------------------------------------------------------------------

#' @keywords internal
.jst_jdeclare_udm_spss <- function(col, parsed_codes, var_name,
                                   range = NULL, inband_labels = NULL) {
  # parsed_codes: named numeric vector (names = labels or "", values =
  # numeric codes), possibly EMPTY (a range-only call). Tagged-NA elements
  # have been ruled out upstream. range: the call's supplied band (already
  # validated and sorted), or NULL. inband_labels: named numeric vector of
  # labels for values inside the effective band (validated upstream), or
  # NULL.

  code_vals <- as.numeric(unname(parsed_codes))

  # Validate codes: finite, whole, no duplicates. (All vacuously true for
  # a range-only call's empty vector.)
  if (any(!is.finite(code_vals))) {
    .jst_stop("codes must be finite numeric values.", fn = "jdeclare_udm")
  }
  if (any(code_vals != floor(code_vals))) {
    .jst_stop("codes must be whole numbers.", fn = "jdeclare_udm")
  }
  if (anyDuplicated(code_vals) > 0L) {
    .jst_stop("codes contains duplicate values.", fn = "jdeclare_udm")
  }

  # --- Compose the resulting declaration ------------------------------------
  # Declarative-replace with omission-survival: what the call mentions, it
  # replaces; what it omits survives. A supplied range replaces the
  # column's band; supplied codes replace the column's discrete set; an
  # existing band survives a codes-only call, and existing discrete codes
  # survive a range-only call.
  existing_range  <- attr(col, "na_range")
  has_exist_range <- !is.null(existing_range) && length(existing_range) == 2L
  existing_codes  <- attr(col, "na_values")
  has_exist_codes <- !is.null(existing_codes) && length(existing_codes) > 0L

  range_supplied <- !is.null(range)
  codes_supplied <- length(code_vals) > 0L

  eff_range <- if (range_supplied) as.numeric(range)
               else if (has_exist_range) as.numeric(sort(existing_range))
               else NULL
  eff_codes <- if (codes_supplied) code_vals
               else if (has_exist_codes) as.numeric(existing_codes)
               else numeric(0)

  # --- Composed-result legality (SPSS's own acceptance rule) ----------------
  # SPSS accepts at most three discrete missing values, OR a range, OR a
  # range plus ONE discrete value. The check runs on the COMPOSED result
  # (supplied-or-surviving range + supplied-or-surviving codes), so it can
  # never disagree with jsave's .sav pre-flight -- an illegal combination
  # is refused at the moment the user can fix it, with the column named,
  # rather than at the writer (haven refuses late and does not name the
  # column).
  if (!is.null(eff_range) && length(eff_codes) > 1L) {
    if (range_supplied && codes_supplied) {
      # Remedy scope note. This message deliberately names no Stata pointer
      # (S218 decision, extended here from the existing-range case to the
      # supplied-range case): users declaring SPSS-style UDMs almost
      # certainly need SPSS-compatible files, so the Stata route is not a
      # meaningful fix for this audience; Book 2 carries the fuller story.
      .jst_stop("a missing-value range allows at most 1 separate code ",
                "alongside it; you supplied ", length(code_vals),
                " codes with the range.\n",
                "Declare a single code alongside the range.",
                fn = "jdeclare_udm")
    } else if (range_supplied) {
      # Range-only call; the >1 surviving discrete codes make the
      # composition illegal. There is currently no way to clear an
      # existing code set in the same call (codes = NULL means "not
      # supplied", and survives by design), so the remedy is to
      # redeclare the full set explicitly.
      .jst_stop("'", var_name, "' already carries ", length(eff_codes),
                " declared codes (",
                paste(format(eff_codes, trim = TRUE), collapse = ", "),
                "), and a missing-value range allows at most 1 code ",
                "alongside it.\n",
                "Redeclare with the range and a single code, for example ",
                "range = c(", format(eff_range[1]), ", ",
                format(eff_range[2]), "), codes = ",
                format(eff_codes[1], trim = TRUE), ".",
                fn = "jdeclare_udm")
    } else {
      # Codes-only call against a surviving band (the pre-existing case).
      .jst_stop("'", var_name, "' already has a missing-value range (",
                format(eff_range[1]), " to ", format(eff_range[2]),
                "), which allows at most 1 separate code alongside it; ",
                "you supplied ", length(code_vals), ".\n",
                "Declare a single code alongside the range.",
                fn = "jdeclare_udm")
    }
  }
  if (is.null(eff_range) && length(eff_codes) > 3L) {
    # E18 rewrite: for a .sav deliverable the range is the answer, so it
    # is named first; the Stata convention second.
    .jst_stop("SPSS-style missing values are limited to 3 codes ",
              "per variable, or a range, or a range plus 1 code; ",
              "you supplied ", length(code_vals), " codes.\n",
              "To declare a band of consecutive codes, use ",
              "range = c(low, high); to declare more than 3 unrelated ",
              "codes, use Stata convention (convention = \"stata\").",
              fn = "jdeclare_udm")
  }

  # Build the new value-labels set. Merge any existing labels with the
  # newly supplied ones (new labels win for the codes being declared).
  existing_labs <- if (haven::is.labelled(col)) labelled::val_labels(col)
                   else NULL

  # Strip existing labels only for codes that are being given a NEW
  # label in this call (the new label replaces the old one below). A
  # code declared bare keeps whatever label it already carries --
  # declaring a value as missing does not touch its label (SPSS
  # parallel: MISSING VALUES never alters VALUE LABELS). Labels on
  # non-declared codes (real-data labels) are always preserved.
  # In-range labels follow the same replace-by-value rule.
  label_names <- names(parsed_codes)
  if (is.null(label_names)) label_names <- rep("", length(parsed_codes))
  relabelled <- as.numeric(parsed_codes[nzchar(label_names)])
  if (!is.null(inband_labels) && length(inband_labels) > 0L) {
    relabelled <- c(relabelled, as.numeric(inband_labels))
  }
  if (!is.null(existing_labs) && length(existing_labs) > 0L &&
      length(relabelled) > 0L) {
    keep_mask <- !(unname(existing_labs) %in% relabelled)
    existing_labs <- existing_labs[keep_mask]
  }

  # Build new labels for codes that have a label.
  new_labs <- numeric(0)
  for (i in seq_along(parsed_codes)) {
    if (nzchar(label_names[i])) {
      entry <- as.numeric(parsed_codes[i])
      names(entry) <- label_names[i]
      new_labs <- c(new_labs, entry)
    }
  }
  # In-range labels attach as ordinary value labels on the in-band
  # values; they do NOT join na_values (the band already covers them).
  if (!is.null(inband_labels) && length(inband_labels) > 0L) {
    ib <- as.numeric(inband_labels)
    names(ib) <- names(inband_labels)
    new_labs <- c(new_labs, ib)
  }

  combined_labs <- c(existing_labs, new_labs)
  if (length(combined_labs) == 0L) combined_labs <- NULL

  # Use labelled_spss to attach na_values together with labels and
  # variable label. The effective band and effective code set were
  # composed above: a band survives a codes-only call (omitting it here
  # silently promoted every in-band cell back to ordinary data,
  # AUDIT-038), and discrete codes survive a range-only call.
  haven::labelled_spss(
    x         = as.numeric(unclass(col)),
    labels    = combined_labs,
    na_values = if (length(eff_codes) > 0L) eff_codes else NULL,
    na_range  = eff_range,
    label     = attr(col, "label", exact = TRUE)
  )
}


# -----------------------------------------------------------------------------
# Branch D3: Stata canonical (label existing tagged-NA cells)
# -----------------------------------------------------------------------------

#' @keywords internal
.jst_jdeclare_udm_stata_label <- function(col, parsed_codes) {
  # parsed_codes: named numeric vector where every value is a tagged-NA
  # (NA_real_ with a tag attribute).

  tags <- haven::na_tag(parsed_codes)
  if (anyDuplicated(tags) > 0L) {
    # Style word follows the tags' (already canonicalized) case (S240).
    dup_style <- if (all(tags[!is.na(tags)] %in% LETTERS)) "SAS-style"
                 else "Stata-style"
    .jst_stop("codes contains duplicate ", dup_style,
              " missing-value letters.",
              fn = "jdeclare_udm")
  }

  existing_labs <- if (haven::is.labelled(col)) labelled::val_labels(col)
                   else NULL

  # Strip existing tagged-NA labels only for tags that are being given a
  # NEW label in this call; a tag declared bare keeps its existing
  # label (parallel to the SPSS branch's bare-codes preservation).
  # Plain-numeric labels are preserved.
  label_names <- names(parsed_codes)
  if (is.null(label_names)) label_names <- rep("", length(parsed_codes))
  relabelled_tags <- tags[nzchar(label_names)]
  if (!is.null(existing_labs) && length(existing_labs) > 0L &&
      length(relabelled_tags) > 0L) {
    existing_tags <- haven::na_tag(existing_labs)
    keep_mask <- is.na(existing_tags) | !(existing_tags %in% relabelled_tags)
    existing_labs <- existing_labs[keep_mask]
  }

  # Build new tagged-NA labels.
  new_labs <- numeric(0)
  for (i in seq_along(parsed_codes)) {
    if (nzchar(label_names[i])) {
      entry <- haven::tagged_na(tags[i])
      names(entry) <- label_names[i]
      new_labs <- c(new_labs, entry)
    }
  }

  combined_labs <- c(existing_labs, new_labs)
  if (length(combined_labs) == 0L) combined_labs <- NULL

  # Plain labelled (not labelled_spss); strip na_values if it leaked in.
  out <- haven::labelled(
    x      = as.numeric(unclass(col)),
    labels = combined_labs,
    label  = attr(col, "label", exact = TRUE)
  )
  out
}


# -----------------------------------------------------------------------------
# Branch D4: Stata conversion (numeric codes -> tagged-NA cells)
# -----------------------------------------------------------------------------

#' @keywords internal
.jst_jdeclare_udm_stata_convert <- function(col, parsed_codes, var_name,
                                            convention = "stata") {
  # parsed_codes: named numeric vector (names = labels or "", values =
  # plain numeric codes). Tagged-NA elements ruled out upstream.
  # convention: the resolved convention ("stata" or "sas"); drives the
  # mint alphabet and the cap message case (S240, Decision 13 parity).

  code_vals <- as.numeric(unname(parsed_codes))
  mint_alphabet <- if (identical(convention, "sas")) LETTERS else letters
  conv_word     <- if (identical(convention, "sas")) "SAS" else "Stata"
  conv_span     <- if (identical(convention, "sas")) ".A-.Z" else ".a-.z"

  # Validate codes.
  if (any(!is.finite(code_vals))) {
    .jst_stop("codes must be finite numeric values.", fn = "jdeclare_udm")
  }
  if (any(code_vals != floor(code_vals))) {
    .jst_stop("codes must be whole numbers.", fn = "jdeclare_udm")
  }
  if (anyDuplicated(code_vals) > 0L) {
    .jst_stop("codes contains duplicate values.", fn = "jdeclare_udm")
  }
  if (length(code_vals) > length(mint_alphabet)) {
    .jst_stop("under ", conv_word, " convention with numeric codes, at ",
              "most 26 can be converted (mapped to ", conv_span, ").",
              fn = "jdeclare_udm")
  }

  # Ordering-based mapping per Session 30 Branch D4 (Q6): codes sorted by
  # |code| descending, more-negative-first as tie-breaker. Then the first
  # alphabet letters in that order (.a, .b, ... or .A, .B, ... under sas).
  ordering           <- order(-abs(code_vals), code_vals)
  sorted_codes       <- code_vals[ordering]
  sorted_labels      <- names(parsed_codes)[ordering]
  tag_letters        <- mint_alphabet[seq_along(sorted_codes)]

  x_num <- suppressWarnings(as.numeric(unclass(col)))
  new_col <- as.numeric(x_num)
  for (i in seq_along(sorted_codes)) {
    pos <- which(!is.na(x_num) & x_num == sorted_codes[i])
    new_col[pos] <- haven::tagged_na(tag_letters[i])
  }

  # Build val_labels with tagged_na as the value, label as the name.
  existing_labs <- if (haven::is.labelled(col)) labelled::val_labels(col)
                   else NULL

  # Carry an existing label across the conversion when the call supplies
  # no new label for that code: the numeric code's cells become
  # tagged-NA cells, and the label moves with them (parallel to the
  # SPSS branch's bare-codes preservation). A new label in the call
  # still wins.
  if (!is.null(existing_labs) && length(existing_labs) > 0L) {
    for (i in seq_along(sorted_codes)) {
      if (!nzchar(sorted_labels[i])) {
        hit <- which(unname(existing_labs) == sorted_codes[i])
        if (length(hit) > 0L) sorted_labels[i] <- names(existing_labs)[hit[1]]
      }
    }
  }

  # Strip any existing labels pointing at the codes being converted
  # (they're now tagged-NA values, not the numeric codes any more).
  if (!is.null(existing_labs) && length(existing_labs) > 0L) {
    keep_mask <- !(unname(existing_labs) %in% sorted_codes)
    existing_labs <- existing_labs[keep_mask]
  }

  new_labs <- numeric(0)
  for (i in seq_along(sorted_codes)) {
    if (nzchar(sorted_labels[i])) {
      entry <- haven::tagged_na(tag_letters[i])
      names(entry) <- sorted_labels[i]
      new_labs <- c(new_labs, entry)
    }
  }

  combined_labs <- c(existing_labs, new_labs)
  if (length(combined_labs) == 0L) combined_labs <- NULL

  out <- haven::labelled(
    x      = new_col,
    labels = combined_labs,
    label  = attr(col, "label", exact = TRUE)
  )

  list(
    new_col       = out,
    sorted_codes  = sorted_codes,
    sorted_labels = sorted_labels,
    tag_letters   = tag_letters
  )
}


# -----------------------------------------------------------------------------
# .jst_jdeclare_udm_marker_notes()
#
# Per-marker truthfulness annotations for the stata_canonical body lines
# (S247). That branch renders from the CODES ARGUMENT rather than from what
# changed on the column, so it reported acts that did not happen: a label
# attached to a marker in no cell, a bare marker that changes nothing, and
# a rename that silently dropped the old label. Each body line now carries
# what actually happened to that marker on the resulting column.
#
# Three facts, combinable, rendered in this order:
#   "no change"               - the marker's label is what it already was
#                               (a bare entry, or the same name re-asserted)
#   was "<old>"               - the entry replaced an existing label
#   "not present in the data" - no cell carries the marker
#
# Absence is judged on CELLS ONLY, deliberately: a marker living just in the
# value labels is precisely the case being reported. Forward-declaring one is
# permitted (Option A, S247) -- haven accepts it, it survives both a Stata and
# an SPSS round trip, and sign-off 5 already counts a label-only marker as a
# real declaration when deciding what was dropped. Case is significant, since
# .a and .A are different markers, so a canonicalized code whose cells carry
# the other case reads as absent -- which is true, and is the mixed-marker
# state the census reports separately.
# -----------------------------------------------------------------------------

#' @keywords internal
.jst_jdeclare_udm_marker_notes <- function(col, new_col, parsed_codes) {
  tags <- haven::na_tag(parsed_codes)
  lbls <- names(parsed_codes)
  if (is.null(lbls)) lbls <- rep("", length(parsed_codes))

  cell_tags <- haven::na_tag(new_col)
  cell_tags <- cell_tags[!is.na(cell_tags)]

  old_labs <- if (haven::is.labelled(col)) labelled::val_labels(col) else NULL
  if (is.null(old_labs) || length(old_labs) == 0L) {
    old_labs <- NULL
    old_tags <- character(0)
  } else {
    old_tags <- haven::na_tag(old_labs)
  }

  vapply(seq_along(parsed_codes), function(i) {
    prior <- NA_character_
    if (length(old_tags) > 0L) {
      hit <- which(!is.na(old_tags) & old_tags == tags[i])
      if (length(hit) > 0L) prior <- names(old_labs)[hit[1L]]
    }

    parts <- character(0)
    if (!nzchar(lbls[i]) || identical(prior, lbls[i])) {
      parts <- c(parts, "no change")
    } else if (!is.na(prior) && nzchar(prior)) {
      parts <- c(parts, paste0("was \"", prior, "\""))
    }
    if (!(tags[i] %in% cell_tags)) {
      parts <- c(parts, "not present in the data")
    }

    if (length(parts) == 0L) "" else
      paste0(" (", paste(parts, collapse = "; "), ")")
  }, character(1))
}


# -----------------------------------------------------------------------------
# .jst_jdeclare_udm_no_naming_note()
#
# Replaces the stata_canonical block when EVERY entry in codes is bare
# (S247). On this branch the cells are already tagged NAs -- already missing,
# which is what put the column on the branch -- so the only act available is
# naming a marker, and a call that names none does nothing at all. The old
# rendering printed a "Named ..." header over a list of markers, asserting an
# act that never occurred.
#
# The likely cause is worth teaching to, not just reporting: a migrant who
# learned codes = -99 on the SPSS side, where a bare code IS the declaration,
# reasonably writes codes = ".a" here and expects the same. So the note names
# why bare does nothing on this branch and shows the naming form.
#
# Consequential (the user asked for something and got nothing), so it prints
# at every tier above minimal. No durability note follows: nothing changed,
# and there is nothing to make durable.
# -----------------------------------------------------------------------------

#' @keywords internal
.jst_jdeclare_udm_no_naming_note <- function(data_name, var_phrase,
                                             parsed_codes, scaffold_var,
                                             modify = FALSE,
                                             plural = FALSE) {
  tag1 <- haven::na_tag(parsed_codes)[1L]
  code_arg <- paste0("codes = c(Refused = \".", tag1, "\")")
  scaffold <- if (isTRUE(modify)) {
    paste0("    jdeclare_udm(", data_name, ", ", scaffold_var, ", ",
           code_arg, ", modify = TRUE)")
  } else {
    paste0("    ", data_name, " <- jdeclare_udm(", data_name, ", ",
           scaffold_var, ", ", code_arg, ")")
  }
  paste0(
    .jst_wrap_prose(paste0(
      "Note: jdeclare_udm made no change to ", var_phrase, ". ",
      if (isTRUE(plural)) "Their" else "Its",
      " markers are already missing values, so a bare marker has ",
      "nothing to name."), reserve = 0L), "\n",
    "  To name one:\n",
    scaffold, "\n"
  )
}


# -----------------------------------------------------------------------------
# Notification builder
# -----------------------------------------------------------------------------

#' @keywords internal
.jst_jdeclare_udm_notification <- function(data_name, var_name,
                                           parsed_codes, branch,
                                           conversion_info = NULL,
                                           modify = FALSE,
                                           range = NULL,
                                           inband_labels = NULL,
                                           resolved_convention = "stata",
                                           marker_notes = NULL) {

  output_level <- getOption(".jst_output_level", "standard")

  # S247: an all-bare codes argument names nothing on the tagged branch, so
  # the naming header is replaced outright rather than annotated. Checked
  # before the header is built -- there is no header to build.
  if (identical(branch, "stata_canonical") &&
      !any(nzchar(names(parsed_codes)))) {
    return(.jst_jdeclare_udm_no_naming_note(
      data_name    = data_name,
      var_phrase   = var_name,
      parsed_codes = parsed_codes,
      scaffold_var = var_name,
      modify       = modify))
  }

  # Two-branch header (assignment-accuracy rule): the frame name appears
  # only in the modify branch, where the claim that the frame changed is
  # true. The default branch names just the variable -- the declaration is
  # true of the returned column regardless of assignment. Style word
  # follows the resolved convention (S240): a sas resolution says
  # "SAS-style" and its body lines carry the uppercase markers actually
  # minted. parsed_codes here is the caller's CANONICALIZED per-column
  # copy, so the stata_canonical body renders the case that was written.
  #
  # S246: the stata_canonical branch reads "Named ... " where it once read
  # "Labeled ... ", and its body line reads '<marker> is now "<label>"'
  # rather than the shared 'code ["label"]' form. On an already-tagged
  # column there is nothing to declare -- the cells are already missing --
  # so the only act available is naming a marker, and the old wording did
  # not say that: a reader took "Labeled SAS-style missing values on Score"
  # to mean something had happened to the values. The state form
  # '.A ["Changed"]' reinforced it. The pairing form states the change.
  # This branch alone diverges from the shared body format, deliberately:
  # the other two report a list of what was declared, this one reports a
  # renaming.
  style_word <- .jst_convention_label(
    if (identical(branch, "spss_canonical")) "spss" else resolved_convention)
  header <- switch(
    branch,
    spss_canonical    = paste0("Declared ", style_word,
                               " missing values on "),
    stata_canonical   = paste0("Named ", style_word,
                               " missing values on "),
    stata_conversion  = paste0("Declared and converted to ", style_word,
                               " missing values on ")
  )
  header <- if (isTRUE(modify)) {
    paste0(header, var_name, " in ", data_name, ":")
  } else {
    paste0(header, var_name, ":")
  }

  # Build body lines: code [label] format per jfreq's v0.9.5 Missing-section
  # display.
  body_lines <- character(0)
  if (branch == "stata_conversion") {
    # Lines reflect post-conversion state (tag letters, not source codes).
    for (i in seq_along(conversion_info$sorted_codes)) {
      tag <- conversion_info$tag_letters[i]
      lbl <- conversion_info$sorted_labels[i]
      if (nzchar(lbl)) {
        body_lines <- c(body_lines,
                        sprintf("  .%s [\"%s\"]  (from %s)",
                                tag, lbl,
                                format(conversion_info$sorted_codes[i])))
      } else {
        body_lines <- c(body_lines,
                        sprintf("  .%s  (from %s)",
                                tag,
                                format(conversion_info$sorted_codes[i])))
      }
    }
  } else if (branch == "stata_canonical") {
    # S246: the pairing form. A bare marker (no label given) keeps its
    # existing label, so there is no renaming to report -- it renders as
    # the marker alone. S247: each line carries its truthfulness annotation
    # (what actually happened to that marker), built by
    # .jst_jdeclare_udm_marker_notes(). An all-bare call never reaches here.
    c_tags <- haven::na_tag(parsed_codes)
    notes  <- if (is.null(marker_notes)) rep("", length(parsed_codes))
              else marker_notes
    for (i in seq_along(parsed_codes)) {
      lbl <- names(parsed_codes)[i]
      if (nzchar(lbl)) {
        body_lines <- c(body_lines,
                        sprintf("  .%s is now \"%s\"%s",
                                c_tags[i], lbl, notes[i]))
      } else {
        body_lines <- c(body_lines,
                        sprintf("  .%s%s", c_tags[i], notes[i]))
      }
    }
  } else {
    # SPSS canonical. A declared range leads (mirroring jfreq's Missing-
    # section "range lo to hi" row), then discrete codes, then labeled
    # in-range values marked "(in range)" -- they carry value labels but
    # are covered by the band rather than declared discretely.
    if (!is.null(range)) {
      body_lines <- c(body_lines,
                      sprintf("  range %s to %s",
                              format(range[1]), format(range[2])))
    }
    for (i in seq_along(parsed_codes)) {
      v   <- format(as.numeric(parsed_codes[i]))
      lbl <- names(parsed_codes)[i]
      if (nzchar(lbl)) {
        body_lines <- c(body_lines,
                        sprintf("  %s [\"%s\"]", v, lbl))
      } else {
        body_lines <- c(body_lines, sprintf("  %s", v))
      }
    }
    if (!is.null(inband_labels) && length(inband_labels) > 0L) {
      for (i in seq_along(inband_labels)) {
        body_lines <- c(body_lines,
                        sprintf("  %s [\"%s\"]  (in range)",
                                format(as.numeric(inband_labels[i]),
                                       trim = TRUE),
                                names(inband_labels)[i]))
      }
    }
  }

  msg <- paste0(
    header, "\n",
    paste(body_lines, collapse = "\n"), "\n"
  )

  # Standard / full tier: durability note. Default branch: the conditional
  # assignment scaffold plus the modify = TRUE pointer (each the next step
  # on the in-session rung). Modify branch: the cross-session jsave tip --
  # the change has already landed on the frame, so saving is the next step.
  # Scaffolds use the generic ... template (Session 116, reverting the
  # Session-115 Option-B real-codes echo): the codes are already listed in
  # the block just above and the user has already run the call, so the
  # reminder only needs to show the corrective scaffold.
  if (!identical(output_level, "minimal")) {
    msg <- paste0(msg, "\n",
                  .jst_durability_note("frame", data_name,
                                       verb = "jdeclare_udm",
                                       var_name = var_name,
                                       modify = modify),
                  "\n")
  }

  # Full tier: conversion equivalent for the tagged-conversion branch.
  # Style word follows the resolved convention (S240).
  if (identical(output_level, "full") && branch == "stata_conversion") {
    eq_style <- .jst_convention_label(resolved_convention)
    tag_parts <- character(0)
    for (i in seq_along(conversion_info$sorted_codes)) {
      tag <- conversion_info$tag_letters[i]
      lbl <- conversion_info$sorted_labels[i]
      rhs <- paste0("tagged_na(\"", tag, "\")")
      if (nzchar(lbl)) {
        lbl_render <- if (grepl("^[A-Za-z.][A-Za-z0-9._]*$", lbl)) lbl
                      else paste0("`", lbl, "`")
        tag_parts <- c(tag_parts, paste0(lbl_render, " = ", rhs))
      } else {
        tag_parts <- c(tag_parts, rhs)
      }
    }
    eq_call <- if (isTRUE(modify)) {
      paste0(
        "Equivalent ", eq_style, " call for future use:\n",
        "    jdeclare_udm(", data_name, ", ", var_name,
        ", codes = c(", paste(tag_parts, collapse = ", "),
        "), modify = TRUE)\n"
      )
    } else {
      paste0(
        "Equivalent ", eq_style, " call for future use:\n",
        "    ", data_name, " <- jdeclare_udm(", data_name, ", ", var_name,
        ", codes = c(", paste(tag_parts, collapse = ", "), "))\n"
      )
    }
    msg <- paste0(msg, eq_call)
  }

  msg
}


#' Internal: consolidated notification for a multi-variable jdeclare_udm call
#'
#' @description
#' One summary block instead of one block per column: a bulk call on 52
#' variables must not print 52 near-identical notices. Variables are
#' grouped by resulting branch (a single call CAN split branches -- e.g.
#' numeric codes applied across a frame where some columns already carry
#' Stata-form markers resolve to conversion while plain columns resolve
#' to the SPSS default), each group gets one header plus one body block
#' (the declaration is identical within a group by construction), and
#' the durability note prints once at the end.
#'
#' @keywords internal
.jst_jdeclare_udm_bulk_notification <- function(data_name, target_vars,
                                                results, parsed_codes,
                                                range = NULL,
                                                inband_labels = NULL,
                                                modify = FALSE) {
  output_level <- getOption(".jst_output_level", "standard")

  branches <- vapply(results, function(r) r$branch, character(1))
  # Group key includes the resolved convention (S240): resolution is per
  # column, so one bulk call can hold stata- and sas-resolved columns in
  # the SAME branch, minting different letter cases -- a branch-only
  # group would render one case for columns that got the other. Within a
  # (branch, convention) subgroup the canonicalized copies are identical,
  # so the subgroup's first result renders for all of it.
  convs    <- vapply(results, function(r) r$resolved_convention, character(1))
  # S247: the key gains a marker-note signature, extending the same widening
  # S240 made when it added the convention. Presence and prior labels are
  # properties of the COLUMN, not of the codes argument, so two columns can
  # sit in one (branch, convention) subgroup and still need different body
  # lines -- one carrying a marker the other lacks. Rendering the subgroup's
  # first result for both would state a falsehood about one of them. The
  # split is bounded: the signature ranges over the markers named in the
  # call, so a 52-column call naming one marker yields at most two blocks.
  sigs <- vapply(results, function(r) {
    if (is.null(r$marker_notes)) "" else paste(r$marker_notes, collapse = "\r")
  }, character(1))
  grp_keys <- paste(branches, convs, sigs, sep = "|")
  msg <- character(0)
  # S247: a group that named nothing changed nothing. If EVERY group is such
  # a group the call left the frame untouched, so the durability note must
  # not follow -- there is nothing to make durable, and saying otherwise
  # repeats the defect this session removes. A mixed call still gets it.
  no_change_only <- logical(0)

  for (gk in unique(grp_keys)) {
    idx    <- which(grp_keys == gk)
    br     <- branches[idx[1]]
    vn_set <- target_vars[idx]
    style_word <- .jst_convention_label(
      if (identical(br, "spss_canonical")) "spss" else convs[idx[1]])
    header <- switch(
      br,
      spss_canonical    = paste0("Declared ", style_word,
                                 " missing values on "),
      stata_canonical   = paste0("Named ", style_word,
                                 " missing values on "),
      stata_conversion  = paste0("Declared and converted to ", style_word,
                                 " missing values on ")
    )
    header <- if (isTRUE(modify)) {
      paste0(header, length(vn_set),
             if (length(vn_set) == 1L) " variable in " else " variables in ",
             data_name, ":")
    } else {
      paste0(header, length(vn_set),
             if (length(vn_set) == 1L) " variable:" else " variables:")
    }
    # Echo the variable list (wrapped): the user supplied it via vars= or
    # the dots, and the echo confirms exactly which columns changed.
    var_line <- paste(strwrap(paste(vn_set, collapse = ", "),
                              width = 70, initial = "  ", prefix = "  "),
                      collapse = "\n")

    body_lines <- character(0)
    if (br == "stata_conversion") {
      ci <- results[[idx[1]]]$conversion_info
      for (i in seq_along(ci$sorted_codes)) {
        tag <- ci$tag_letters[i]
        lbl <- ci$sorted_labels[i]
        if (nzchar(lbl)) {
          body_lines <- c(body_lines,
                          sprintf("  .%s [\"%s\"]  (from %s)", tag, lbl,
                                  format(ci$sorted_codes[i])))
        } else {
          body_lines <- c(body_lines,
                          sprintf("  .%s  (from %s)", tag,
                                  format(ci$sorted_codes[i])))
        }
      }
    } else if (br == "stata_canonical") {
      # Subgroup-local canonicalized copy: carries the letter case this
      # subgroup's columns actually got (S240). Pairing form per S246, with
      # the S247 annotations -- the group key above guarantees every column
      # in this subgroup shares one signature, so the first result's notes
      # are true of all of them.
      pc_grp <- results[[idx[1]]]$parsed_codes_used
      # All-bare names nothing: the whole block becomes the no-change note
      # (S247). Bare-ness comes from the codes argument, so it is call-level
      # -- but the BRANCH is per column, so other groups keep their blocks.
      if (!any(nzchar(names(pc_grp)))) {
        nn <- .jst_jdeclare_udm_no_naming_note(
          data_name    = data_name,
          var_phrase   = paste0(length(vn_set),
                                if (length(vn_set) == 1L) " variable"
                                else " variables"),
          parsed_codes = pc_grp,
          scaffold_var = vn_set[1L],
          modify       = modify,
          plural       = length(vn_set) > 1L)
        no_change_only <- c(no_change_only, TRUE)
        # Splice the variable echo under the first sentence: "no change to 3
        # variables" is not actionable without naming them.
        nn_parts <- strsplit(nn, "\n  To name one:\n", fixed = TRUE)[[1]]
        msg <- c(msg, paste0(nn_parts[1], "\n", var_line,
                             "\n  To name one:\n", nn_parts[2]))
        next
      }
      c_tags <- haven::na_tag(pc_grp)
      notes  <- results[[idx[1]]]$marker_notes
      if (is.null(notes)) notes <- rep("", length(pc_grp))
      for (i in seq_along(pc_grp)) {
        lbl <- names(pc_grp)[i]
        if (nzchar(lbl)) {
          body_lines <- c(body_lines,
                          sprintf("  .%s is now \"%s\"%s",
                                  c_tags[i], lbl, notes[i]))
        } else {
          body_lines <- c(body_lines,
                          sprintf("  .%s%s", c_tags[i], notes[i]))
        }
      }
    } else {
      if (!is.null(range)) {
        body_lines <- c(body_lines,
                        sprintf("  range %s to %s",
                                format(range[1]), format(range[2])))
      }
      for (i in seq_along(parsed_codes)) {
        v   <- format(as.numeric(parsed_codes[i]))
        lbl <- names(parsed_codes)[i]
        if (nzchar(lbl)) {
          body_lines <- c(body_lines, sprintf("  %s [\"%s\"]", v, lbl))
        } else {
          body_lines <- c(body_lines, sprintf("  %s", v))
        }
      }
      if (!is.null(inband_labels) && length(inband_labels) > 0L) {
        for (i in seq_along(inband_labels)) {
          body_lines <- c(body_lines,
                          sprintf("  %s [\"%s\"]  (in range)",
                                  format(as.numeric(inband_labels[i]),
                                         trim = TRUE),
                                  names(inband_labels)[i]))
        }
      }
    }

    msg <- c(msg, paste0(header, "\n", var_line, "\n",
                         paste(body_lines, collapse = "\n"), "\n"))
    no_change_only <- c(no_change_only, FALSE)
  }

  out <- paste(msg, collapse = "\n")

  if (!identical(output_level, "minimal") && !all(no_change_only)) {
    out <- paste0(out, "\n",
                  .jst_durability_note("frame", data_name,
                                       verb = "jdeclare_udm",
                                       var_name = "vars = c(...)",
                                       modify = modify),
                  "\n")
  }
  out
}


#' Internal: render a named numeric label set for an error message
#'
#' @description
#' Formats entries of a parsed-labels vector (names = labels, values =
#' numeric) as "value=label; value=label" for quoting back to the user
#' in refusals about unmatched labels entries.
#'
#' @keywords internal
.jst_render_label_entries <- function(x) {
  paste(
    vapply(seq_along(x), function(i) {
      sprintf("%s=%s", format(as.numeric(x[i]), trim = TRUE), names(x)[i])
    }, character(1)),
    collapse = "; ")
}

# =============================================================================
#  DATA I/O
# =============================================================================

# -- jconvert -----------------------------------------------------------------

#' Convert user-defined missing value (UDM) declarations between formats
#'
#' \code{jconvert()} provides a single entry point for changing how user-
#' defined missing values (UDMs) are represented on the columns of a data
#' frame already in memory. Four target formats are supported: SPSS-style
#' (\code{na_values} on \code{haven_labelled_spss}), Stata-style
#' (lowercase \code{tagged_na} on \code{haven_labelled}), SAS-style
#' (uppercase \code{tagged_na} on \code{haven_labelled}), and base R
#' (declarations stripped, declared cells converted to plain \code{NA}).
#'
#' @param data A data frame, or omitted to use the \code{juse()} default.
#' @param to One of \code{"baseR"}, \code{"spss"}, \code{"stata"}, or
#'   \code{"sas"} (any capitalization is accepted). When \code{NULL} (the
#'   default), \code{jconvert()}
#'   reads \code{joptions("missing.convention")}: if the slot is set to
#'   \code{"spss"}, \code{"stata"}, or \code{"sas"}, \code{to} resolves to
#'   that value; if
#'   the slot is at its \code{"none"} default, \code{jconvert()} errors
#'   with guidance naming the concrete options. The destructive
#'   \code{"baseR"} target is never auto-resolved -- it must always be
#'   passed explicitly.
#' @param ... Optional unquoted variable names. When supplied, only the
#'   listed variables are scanned. Mutually exclusive with \code{vars}.
#' @param vars Alternative scope-by-vector path: a character vector of
#'   variable names. Mutually exclusive with \code{...}. When both
#'   \code{...} and \code{vars} are empty, \code{jconvert()} operates on
#'   the whole data frame.
#' @param udm.notice Logical; \code{TRUE} (default) prints a notification
#'   summarizing what was converted (and what was skipped) along with a
#'   reminder of how to keep the result. \code{FALSE} suppresses the
#'   message. Always-on by default; does not consult \code{joutput()}
#'   because the function reports an action it just performed rather than
#'   explaining system behavior.
#' @param modify Logical. When \code{TRUE}, the converted data frame is
#'   written back onto the data frame named in the call (or onto the
#'   \code{juse()} default when the data argument is omitted), so no
#'   assignment is needed -- the recommended workflow, since conversions
#'   lost to a forgotten assignment silently change how later analyses
#'   treat the affected values. Requires the data frame to be given as a
#'   plain name. When \code{FALSE} (the default), the caller's data frame
#'   is untouched; assign the returned data frame to keep the
#'   conversions.
#'
#' @return The data frame with the requested conversions applied, returned
#'   invisibly. With the default \code{modify = FALSE}, the caller's data
#'   frame is unchanged until the result is assigned back. With
#'   \code{modify = TRUE}, the conversions are also written back onto the
#'   caller's data frame, and the returned copy can be ignored.
#'
#' @details
#' The three target formats:
#' \describe{
#'   \item{\code{to = "baseR"}}{Strip all UDM declarations and convert
#'     declared cells to plain \code{NA}. For SPSS-form columns
#'     (\code{na_values} / \code{na_range} on
#'     \code{haven_labelled_spss}), masks declared codes to \code{NA} and
#'     removes the attributes; value labels are preserved so the column
#'     can still round-trip through \code{jsave()} with original
#'     labeling. For columns carrying Stata-style missing values
#'     (\code{tagged_na} markers), uses \code{haven::zap_missing()} to
#'     convert them to plain \code{NA}s.}
#'   \item{\code{to = "spss"}}{Convert Stata-style or SAS-style missing
#'     values to SPSS-form numeric codes. Letter tags map to numeric
#'     codes via \code{joptions("udm.convention.codes")} (default
#'     \code{-99}, \code{-98}, \code{-97}):
#'     \code{.a -> codes[1]}, \code{.b -> codes[2]}, and so on. SAS-style
#'     (uppercase) tags are case-corrected to Stata-style (lowercase)
#'     before the numeric mapping -- for round-trip purposes the package
#'     treats \code{.A} and \code{.a} as the same conceptual marker, and
#'     mixed-case columns collapse to a single lowercase marker (SPSS has
#'     no parallel uppercase convention). The notification's per-column
#'     display shows the original (pre-correction) tag for SAS-corrected
#'     columns -- e.g. \code{.A "Refused" -> -99} -- so the user-visible
#'     mapping reflects what was actually in the data on input. Letter
#'     tags beyond those covered by the convention codes (default
#'     \code{.a}--\code{.c}, one letter per code, after case correction)
#'     are refused with guidance to use \code{jrecode()} for manual
#'     mapping.}
#'   \item{\code{to = "stata"}}{Convert SPSS-form numeric codes to
#'     Stata-style missing values. Letter tags are assigned by ordering
#'     rather than by convention: each column's own declared
#'     \code{na_values} codes are sorted by absolute value descending
#'     (ties broken with more-negative-first), then mapped
#'     \code{.a, .b, .c} in that order. Convention codes are NOT
#'     consulted for this direction;
#'     they only govern the reverse (Stata to SPSS) mapping. Round-trip
#'     conversions are not guaranteed to preserve the original numeric
#'     codes (e.g. SPSS \code{c(-1, 9)} -> Stata \code{.a, .b} -> SPSS
#'     \code{c(-99, -98)} loses the original numbers), but the value
#'     labels survive intact and the missingness semantics are preserved.
#'     Range-based SPSS missings (\code{na_range}) are enumerated:
#'     Stata-style missing values have no range concept, so the distinct
#'     range values present in the column's data, plus any range values
#'     carrying a value label, are translated individually. They join the
#'     column's discrete \code{na_values} codes in a single set, sorted
#'     and lettered by the same ordering rule. The range rule itself is
#'     not preserved -- a range value with neither a data occurrence nor
#'     a label at conversion time is not translated, so if it first
#'     appears in later data it arrives as an ordinary data value. A
#'     column whose combined set exceeds 26 values (the \code{.a}--\code{.z}
#'     alphabet) is refused before any data is touched. A range
#'     declaration with no values to translate does not block the
#'     conversion: the column still converts, with the empty range
#'     declaration dropped and reported. SAS-style (uppercase) tagged
#'     columns are
#'     case-corrected to Stata-style (lowercase) and counted as
#'     converted; columns already fully lowercase are skipped as already
#'     in the target form.}
#'   \item{\code{to = "sas"}}{Identical to \code{to = "stata"} except
#'     that the letters are uppercase (\code{.A}--\code{.Z}, SAS's
#'     native extended-missing convention): SPSS-form columns are
#'     enumerated and mapped to uppercase tags, Stata-style (lowercase)
#'     tagged columns are case-corrected to uppercase and counted as
#'     converted, and columns already fully uppercase are skipped.
#'     Inside R the two tagged forms are the same structure differing
#'     only in letter case; note that saving to Stata format (.dta)
#'     lowercases uppercase tags again, since the .dta format only
#'     supports lowercase letters.}
#' }
#'
#' Pre-flight checks for \code{to = "spss"} include a collision check:
#' if a column's target numeric code (e.g. \code{-99} for \code{.a}) is
#' present as genuine data in the column, the call errors before any
#' data is touched. The error message lists every colliding column and
#' presents three resolution paths: change the convention codes via
#' \code{joptions(udm.convention.codes = ...)}, scope the call via
#' \code{vars = c(...)} to exclude affected columns, or recode the real-
#' data values via \code{jrecode()} first. Atomicity applies to every
#' error mode -- the entire \code{jconvert()} call either succeeds or
#' errors before mutating the data frame.
#'
#' \strong{Pattern A -- value labels suggest missingness but no formal
#' declaration.} When a column has no formal UDM declaration but carries
#' value labels matching the package's missing-label wordlist (e.g.
#' \code{"Refused"}, \code{"Don't know"}, \code{"Not applicable"}),
#' \code{jconvert()} skips the column and surfaces it in the
#' notification with the affected value/label pairs. To formalize these
#' as UDMs use \code{jdeclare_udm()}; to leave them as ordinary data, no
#' action is needed.
#'
#' @examples
#' # community ships with SPSS-form UDMs (Income, Education, Smoker,
#' # Environment1, Environment3), so the conversions run on it directly.
#'
#' # Convert SPSS-form UDMs to Stata-style missing values. modify = TRUE
#' # writes the result back onto df in one step -- the recommended
#' # workflow.
#' df <- community
#' jconvert(df, to = "stata", modify = TRUE)
#'
#' # Equivalent without modify: assign the returned data frame back
#' df2 <- jconvert(community, to = "stata")
#'
#' # Convert to SAS-style missing values (uppercase .A, .B, ...):
#' df_sas <- jconvert(community, to = "sas")
#'
#' # Strip UDMs from every applicable variable:
#' df3 <- jconvert(community, to = "baseR")
#'
#' # Scope by unquoted names:
#' df4 <- jconvert(community, to = "baseR", Income, Education)
#'
#' # Scope by character vector (alternative form):
#' df5 <- jconvert(community, to = "baseR", vars = c("Income", "Education"))
#'
#' # Suppress the notification (e.g. inside a script):
#' df6 <- jconvert(community, to = "baseR", udm.notice = FALSE)
#'
#' \dontrun{
#' # Convert with target inferred from joptions:
#' joptions(missing.convention = "spss")
#' df <- jconvert(df)   # converts any Stata-form columns to SPSS
#' }
#'
#' @seealso \code{\link{jload}} for the load-time strip alternative
#'   (\code{preserve.udm = FALSE}); \code{\link{joptions}} for setting
#'   the default convention and convention codes session-wide.
#'
#' @export
jconvert <- function(data, to = NULL, ..., vars = NULL, udm.notice = TRUE,
                     modify = FALSE) {

  # Captured before `data` is reassigned below: substitute() on the
  # rebound variable would return the value, not the caller's expression.
  data_sub_expr <- substitute(data)

  # --- Resolve first argument -------------------------------------------------
  arg1 <- .jst_resolve_first_arg(
    data_sub      = data_sub_expr,
    data_missing  = missing(data),
    fn_name       = "jconvert",
    envir         = parent.frame(),
    accept_vector = FALSE
  )

  data      <- arg1$data
  data_name <- arg1$name

  # --- Resolve `to` -----------------------------------------------------------
  # Auto-resolve from joptions when to= is NULL. spss/stata/sas flow
  # through; "none" gates (Q5 of the Session 28 jconvert design lock,
  # harmonized to the Rule V choose-first form at S244 -- the four-target
  # menu decided S243). baseR never auto-resolves -- destructive
  # transformations require explicit intent, which is also why the menu
  # must OFFER it (no setting can ever supply it) and lists it last. No
  # recommendation line: a conversion destination is externally
  # constrained (the format a collaborator or supervisor needs). The
  # joptions tail is the gate's permanence-line analogue, teaching the
  # standing default that makes the bare call work.
  if (is.null(to)) {
    convention <- getOption(".jst_options_missing_convention",
                            .jst_options_defaults$missing.convention)
    if (convention %in% c("spss", "stata", "sas")) {
      to <- convention
    } else {
      .jst_stop(
        .jst_wrap_prose(
          "no target format is selected, so nothing can be converted.",
          reserve = 12L), "\n",
        "Choose a target for this call:\n",
        "  to = \"stata\"\n",
        .jst_wrap_indent(paste0(
          "Numeric missing codes become Stata-style missing values ",
          "(.a-.z); markers behave as true NAs in base R."),
          indent = 6L), "\n",
        "  to = \"spss\"\n",
        .jst_wrap_indent(paste0(
          "Stata- or SAS-style missing values (.a-.z, .A-.Z) become ",
          "numeric codes; codes stay visible numbers, as in SPSS."),
          indent = 6L), "\n",
        "  to = \"sas\"\n",
        .jst_wrap_indent(
          "Like to = \"stata\", with uppercase markers (.A-.Z).",
          indent = 6L), "\n",
        "  to = \"baseR\"\n",
        .jst_wrap_indent(paste0(
          "All missing-value declarations are removed; declared values ",
          "become plain NA."),
          indent = 6L), "\n",
        "To set a session default so to = is not needed, choose a ",
        "convention:\n",
        "  joptions(missing.convention = \"stata\")    (or \"spss\", \"sas\")",
        fn = "jconvert")
    }
  }
  # Platform specs are case-insensitive: accept "SPSS", "BaseR", "Stata",
  # etc., canonicalized here so downstream code sees the exact tokens.
  if (is.character(to) && length(to) == 1L && !is.na(to)) {
    hit <- match(tolower(to), c("baser", "spss", "stata", "sas"))
    if (!is.na(hit)) to <- c("baseR", "spss", "stata", "sas")[hit]
  }
  if (!is.character(to) || length(to) != 1L ||
      !to %in% c("baseR", "spss", "stata", "sas")) {
    .jst_stop_arg(arg = "to", choices = c("baseR", "spss", "stata", "sas"))
  }
  .jst_check_flag(modify, "modify")
  .jst_check_flag(udm.notice, "udm.notice")
  # modify = TRUE writes the result back onto the caller's variable, so the
  # data must arrive as a bare name -- an expression has no name to write to.
  # The juse()-default paths (modes "default" / "symbol_with_default") are
  # fine: the default name is the write-back target there.
  if (isTRUE(modify) && arg1$mode == "explicit" &&
      !is.symbol(data_sub_expr)) {
    .jst_stop("modify = TRUE can only change a data frame that has a name.\n",
         "Name the data first, then rerun with modify = TRUE:\n",
         "  mydata <- ", paste(deparse(data_sub_expr), collapse = " "), "\n",
         "  jconvert(mydata, ..., modify = TRUE)")
  }

  # --- Resolve variable list (... vs vars; mutually exclusive) ---------------
  variables <- rlang::enquos(...)

  # Leading-comma-omitted form: if first arg was captured as a bare symbol
  # alongside an active juse() default, prepend it to the variables list.
  if (arg1$mode == "symbol_with_default") {
    extra_quo <- rlang::new_quosure(arg1$first_arg_sub, env = parent.frame())
    variables <- c(list(extra_quo), variables)
    class(variables) <- "quosures"
  }

  dot_names <- if (length(variables) > 0) {
    vapply(variables, rlang::quo_name, character(1))
  } else {
    character(0)
  }

  if (length(dot_names) > 0 && !is.null(vars)) {
    .jst_stop("Use either unquoted variable names (...) or quoted names ",
         "via vars = c(...), but not both.")
  }
  if (!is.null(vars) && (!is.character(vars) || length(vars) == 0L)) {
    .jst_stop("`vars` must be one or more variable names in quotes, ",
         "e.g. vars = c(\"Age\", \"Income\").")
  }

  if (length(dot_names) > 0) {
    .jst_check_vars(data, dot_names, data_name)
    target_vars    <- dot_names
    user_specified <- TRUE
    var_scope      <- "dots"
  } else if (!is.null(vars)) {
    .jst_check_vars(data, vars, data_name)
    target_vars    <- vars
    user_specified <- TRUE
    var_scope      <- "vars"
  } else {
    target_vars    <- names(data)
    user_specified <- FALSE
    var_scope      <- "all"
  }

  # --- Classify each target column -------------------------------------------
  info_list       <- list()
  pattern_a       <- list()
  skipped_no_udms <- character(0)

  for (vname in target_vars) {
    col  <- data[[vname]]
    # The tagged targets (stata/sas) enumerate na_range declarations, so
    # they need the observed in-band values; observed = TRUE reads the
    # column's data only on columns that actually declare a band, so the
    # extra cost is confined to exactly the columns that need it.
    info <- .jst_missing_info(col, observed = to %in% c("stata", "sas"))

    if (!is.null(info)) {
      info_list[[vname]] <- info
      next
    }

    # Pattern A scan: no formal declaration. Look for value labels matching
    # the missing-label wordlist (.jst_label_suggests_missing).
    pa_entries <- list()
    if (haven::is.labelled(col)) {
      val_labs <- labelled::val_labels(col)
      if (!is.null(val_labs) && length(val_labs) > 0L) {
        for (i in seq_along(val_labs)) {
          lbl <- names(val_labs)[i]
          if (.jst_label_suggests_missing(lbl)) {
            pa_entries[[length(pa_entries) + 1L]] <- list(
              value = unname(val_labs[i]),
              label = lbl
            )
          }
        }
      }
    }
    if (length(pa_entries) > 0L) {
      pattern_a[[vname]] <- pa_entries
    } else if (user_specified) {
      skipped_no_udms <- c(skipped_no_udms, vname)
    }
  }

  # --- Pre-flight checks: Q3 strict atomicity --------------------------------
  convention_codes <- getOption(".jst_options_udm_convention_codes",
                                .jst_options_defaults$udm.convention.codes)
  letter_codes <- letters[seq_along(convention_codes)]
  code_for_tag <- .jst_tag_letters_to_codes(letter_codes, convention_codes)
  tag_for_code <- stats::setNames(letter_codes, as.character(convention_codes))

  # Tracking for SAS-style (uppercase) tagged-NA case correction performed
  # inside the to = "spss" branch. Declared at function scope so the
  # notification builder (below) can read it regardless of which branch
  # the call took.
  sas_corrected_vars <- character(0)

  if (to == "spss") {
    # Case-correct SAS-style tags before validating. The convention codes
    # map lowercase letters positionally (.a -> codes[1], .b -> codes[2],
    # ...); uppercase tags have no native SPSS-form representation. Like
    # jsave's .dta path, jconvert treats .A and .a as the same conceptual
    # marker for round-trip purposes, converting the former to the latter
    # before the numeric mapping. Mixed-case columns (a column containing
    # both .a and .A) collapse to a single .a marker — the case
    # distinction is not preserved through SPSS-form, since SPSS has no
    # parallel uppercase convention.
    for (vname in names(info_list)) {
      info <- info_list[[vname]]
      if (info$representation != "stata") next
      col <- data[[vname]]
      if (!is.double(col)) next

      cell_changed  <- FALSE
      label_changed <- FALSE

      tags        <- haven::na_tag(col)
      upper_cells <- which(!is.na(tags) & tags %in% LETTERS)
      if (length(upper_cells) > 0L) {
        for (i in upper_cells) col[i] <- haven::tagged_na(tolower(tags[i]))
        cell_changed <- TRUE
      }

      if (haven::is.labelled(col)) {
        vl <- labelled::val_labels(col)
        if (!is.null(vl) && length(vl) > 0L) {
          lab_tags   <- haven::na_tag(vl)
          upper_labs <- which(!is.na(lab_tags) & lab_tags %in% LETTERS)
          if (length(upper_labs) > 0L) {
            for (i in upper_labs) vl[i] <- haven::tagged_na(tolower(lab_tags[i]))
            labelled::val_labels(col) <- vl
            label_changed <- TRUE
          }
        }
      }

      if (cell_changed || label_changed) {
        data[[vname]]      <- col
        sas_corrected_vars <- c(sas_corrected_vars, vname)
        # Refresh info_list so the downstream validation and conversion
        # loops see post-correction tags rather than the original .A/.B.
        info_list[[vname]] <- .jst_missing_info(col)
      }
    }

    # Stata-to-SPSS: check for letter-tag-beyond-.d and collisions.
    beyond_d_vars  <- list()
    collision_vars <- list()

    for (vname in names(info_list)) {
      info <- info_list[[vname]]
      if (info$representation != "stata") next

      col  <- data[[vname]]
      tags <- haven::na_tag(col)
      unique_tags <- unique(tags[!is.na(tags)])

      bad_tags <- unique_tags[!unique_tags %in% letter_codes]
      if (length(bad_tags) > 0L) {
        beyond_d_vars[[length(beyond_d_vars) + 1L]] <- list(
          var = vname, n = length(unique_tags))
      }
      good_tags <- intersect(unique_tags, letter_codes)
      if (length(good_tags) > 0L) {
        x_num         <- suppressWarnings(as.numeric(unclass(col)))
        target_codes  <- unname(code_for_tag[good_tags])
        real_values   <- x_num[!is.na(x_num)]
        hits <- target_codes[
          vapply(target_codes,
                 function(tc) any(real_values == tc),
                 logical(1))
        ]
        if (length(hits) > 0L) {
          collision_vars[[length(collision_vars) + 1L]] <- list(
            var = vname, codes = hits)
        }
      }
    }

    if (length(beyond_d_vars) > 0L || length(collision_vars) > 0L) {
      has_over <- length(beyond_d_vars) > 0L
      has_coll <- length(collision_vars) > 0L

      over_lines <- .jst_cap_var_lines(vapply(beyond_d_vars,
        function(e) sprintf("    %s: %d codes", e$var, e$n), character(1)))
      coll_lines <- .jst_cap_var_lines(vapply(collision_vars,
        function(e) sprintf("    %s: %s", e$var,
                            paste(e$codes, collapse = ", ")), character(1)))

      n_over <- length(beyond_d_vars)
      n_coll <- length(collision_vars)
      over_lead <- if (n_over == 1L) "This variable" else "These variables"
      over_verb <- if (n_over == 1L) "has" else "have"
      coll_lead <- if (n_coll == 1L) "This variable" else "These variables"
      coll_verb <- if (n_coll == 1L) "is" else "are"

      if (has_over && !has_coll) {
        msg_lines <- c(
          "SPSS does not support more than 3 user-defined missing values (UDMs) per variable.",
          "",
          sprintf("%s in %s %s more:", over_lead, data_name, over_verb),
          over_lines,
          "",
          "Resolution options:",
          "  1. Convert a narrower set of variables, leaving out those above:",
          sprintf("       jconvert(%s, to = \"spss\", vars = c(...), modify = TRUE)",
                  data_name),
          "  2. Reduce each variable to 3 or fewer UDMs first with jrecode().")
      } else if (has_coll && !has_over) {
        msg_lines <- c(
          "the user-defined missing value (UDM) convention codes overlap with real data values.",
          "",
          sprintf("%s in %s %s affected:", coll_lead, data_name, coll_verb),
          coll_lines,
          "",
          "Suggested resolution:",
          "  Change the UDM convention codes:",
          "       joptions(udm.convention.codes = c(...))")
      } else {
        msg_lines <- c(
          sprintf("cannot convert %s to SPSS -- two problems:", data_name),
          "",
          "SPSS does not support more than 3 user-defined missing values (UDMs) per variable.",
          sprintf("%s %s more:", over_lead, over_verb),
          over_lines,
          "To fix, reduce each to 3 or fewer UDMs with jrecode().",
          "",
          "The UDM convention codes overlap with real data values.",
          sprintf("%s %s affected:", coll_lead, coll_verb),
          coll_lines,
          "To fix, change the UDM convention codes:",
          "    joptions(udm.convention.codes = c(...))",
          "",
          "Or convert a narrower set, leaving out all the variables above:",
          sprintf("    jconvert(%s, to = \"spss\", vars = c(...), modify = TRUE)",
                  data_name))
      }
      .jst_stop(paste(msg_lines, collapse = "\n"))
    }
  }

  # Per-column conversion plans for the tagged targets. Filled by the
  # pre-flight below; the conversion loop consumes them.
  tagged_plan <- list()

  if (to %in% c("stata", "sas")) {
    # SPSS-to-tagged (Decision 4 Q6 + the S218 range extension): discrete
    # na_values codes and enumerated na_range values merge into ONE set per
    # column, sorted by descending |value| (more-negative-first tie-break)
    # and lettered in that order -- lowercase for to = "stata", uppercase
    # for to = "sas". Range enumeration takes the distinct in-band values
    # OBSERVED in the data plus any in-band values carrying a value LABEL
    # (declaration-by-label parallels how a discrete declared code converts
    # whether or not it occurs); a value in the band with neither is not
    # translated. The 26-letter alphabet caps the merged set; more is
    # refused here, before any mutation (strict atomicity). The convention
    # codes are NOT consulted for this direction.
    tag_alphabet <- if (to == "sas") LETTERS else letters
    tag_display  <- if (to == "sas") ".A-.Z" else ".a-.z"
    style_word   <- if (to == "sas") "SAS-style" else "Stata-style"
    over_cap_vars <- list()

    for (vname in names(info_list)) {
      info <- info_list[[vname]]
      if (info$representation != "spss") next

      declared_codes <- if (!is.null(info$codes)) info$codes$numeric else numeric(0)
      declared_codes <- declared_codes[!is.na(declared_codes)]

      band        <- info$na_range
      band_values <- numeric(0)
      if (!is.null(band) && length(band) == 2L) {
        # Observed in-band values (already excludes discrete codes; see
        # .jst_missing_info's range_values component).
        if (!is.null(info$range_values) && nrow(info$range_values) > 0L) {
          band_values <- info$range_values$numeric
        }
        # Labelled in-band values: value labels pointing at numbers inside
        # the band that are neither observed nor discretely declared.
        col      <- data[[vname]]
        val_labs <- if (haven::is.labelled(col)) labelled::val_labels(col)
                    else NULL
        if (!is.null(val_labs) && length(val_labs) > 0L) {
          lab_nums <- suppressWarnings(as.numeric(val_labs))
          lo <- min(band); hi <- max(band)
          in_band <- !is.na(lab_nums) & lab_nums >= lo & lab_nums <= hi
          lab_vals <- unique(lab_nums[in_band])
          lab_vals <- lab_vals[!(lab_vals %in% declared_codes) &
                               !(lab_vals %in% band_values)]
          band_values <- c(band_values, lab_vals)
        }
      }

      merged <- c(declared_codes, band_values)
      if (length(merged) > length(tag_alphabet)) {
        over_cap_vars[[length(over_cap_vars) + 1L]] <- list(
          var = vname, n_total = length(merged),
          n_codes = length(declared_codes), n_band = length(band_values))
        next
      }

      ordering      <- order(-abs(merged), merged)
      sorted_values <- merged[ordering]
      tagged_plan[[vname]] <- list(
        sorted_values = sorted_values,
        letters       = tag_alphabet[seq_along(sorted_values)],
        band          = if (!is.null(band) && length(band) == 2L) band
                        else NULL,
        band_n        = length(band_values)
      )
    }

    if (length(over_cap_vars) > 0L) {
      over_lines <- .jst_cap_var_lines(vapply(over_cap_vars,
        function(e) {
          if (e$n_band > 0L) {
            sprintf("    %s: %d values (%d declared code%s + %d range value%s)",
                    e$var, e$n_total,
                    e$n_codes, if (e$n_codes == 1L) "" else "s",
                    e$n_band,  if (e$n_band  == 1L) "" else "s")
          } else {
            sprintf("    %s: %d codes", e$var, e$n_total)
          }
        }, character(1)))

      n_over    <- length(over_cap_vars)
      over_lead <- if (n_over == 1L) "This variable" else "These variables"
      over_verb <- if (n_over == 1L) "has" else "have"

      msg_lines <- c(
        sprintf("%s missing values support at most 26 per variable (mapped to %s).",
                style_word, tag_display),
        "",
        sprintf("%s in %s %s more to convert:", over_lead, data_name, over_verb),
        over_lines,
        "",
        "Resolution options:",
        "  1. Convert a narrower set of variables, leaving out those above:",
        sprintf("       jconvert(%s, to = \"%s\", vars = c(...), modify = TRUE)",
                data_name, to),
        "  2. Reduce each variable to 26 or fewer values first with jrecode().")
      .jst_stop(paste(msg_lines, collapse = "\n"))
    }
  }

  # --- Perform conversions ---------------------------------------------------
  converted_vars   <- character(0)
  converted_info   <- list()
  skipped_already  <- character(0)   # in target format already (user_specified only)
  banded_converted <- character(0)   # converted vars that carried an na_range

  for (vname in names(info_list)) {
    info <- info_list[[vname]]
    col  <- data[[vname]]

    if (to == "baseR") {

      if (info$representation == "spss") {
        x_num <- suppressWarnings(as.numeric(unclass(col)))
        mask  <- rep(FALSE, length(x_num))
        if (!is.null(info$codes) && nrow(info$codes) > 0L) {
          declared_codes <- info$codes$numeric
          declared_codes <- declared_codes[!is.na(declared_codes)]
          if (length(declared_codes) > 0L) {
            mask <- mask | (!is.na(x_num) & x_num %in% declared_codes)
          }
        }
        if (!is.null(info$na_range) && length(info$na_range) == 2L) {
          mask <- mask | (!is.na(x_num) &
                            x_num >= info$na_range[1] &
                            x_num <= info$na_range[2])
        }
        data[[vname]][mask]              <- NA
        attr(data[[vname]], "na_values") <- NULL
        attr(data[[vname]], "na_range")  <- NULL
      } else {
        # Stata-form: haven::zap_missing handles tagged NAs uniformly.
        data[[vname]] <- haven::zap_missing(col)
      }

      # Build the display entries from the original info (pre-strip codes).
      display_entries <- character(0)
      if (!is.null(info$codes) && nrow(info$codes) > 0L) {
        for (i in seq_len(nrow(info$codes))) {
          code <- info$codes$code[i]
          lbl  <- info$codes$label[i]
          display_entries <- c(display_entries,
                               if (!is.na(lbl)) {
                                 sprintf('%s "%s"', code, lbl)
                               } else code)
        }
      }
      if (!is.null(info$na_range) && length(info$na_range) == 2L) {
        display_entries <- c(display_entries,
                             sprintf("range [%s, %s]",
                                     as.character(info$na_range[1]),
                                     as.character(info$na_range[2])))
      }
      converted_vars         <- c(converted_vars, vname)
      converted_info[[vname]] <- list(display = display_entries)

    } else if (to == "spss") {

      if (info$representation == "spss") {
        # Already in target — silent for whole-DF, reported as skipped for
        # explicit-named. Tracked unconditionally so the notification
        # builder can detect the "everything already in target" whole-DF
        # case and report it distinctly from the genuinely-empty case.
        skipped_already <- c(skipped_already, vname)
        next
      }

      tags  <- haven::na_tag(col)
      x_num <- suppressWarnings(as.numeric(unclass(col)))
      unique_tags <- unique(tags[!is.na(tags)])
      for (tg in unique_tags) {
        pos <- which(!is.na(tags) & tags == tg)
        x_num[pos] <- code_for_tag[[tg]]
      }

      val_labs     <- labelled::val_labels(col)
      new_val_labs <- val_labs
      if (!is.null(new_val_labs) && length(new_val_labs) > 0L) {
        vl_tags <- haven::na_tag(new_val_labs)
        for (i in seq_along(new_val_labs)) {
          if (!is.na(vl_tags[i]) && vl_tags[i] %in% letter_codes) {
            new_val_labs[i] <- code_for_tag[[vl_tags[i]]]
          }
        }
      }

      used_codes <- unname(code_for_tag[unique_tags])
      data[[vname]] <- haven::labelled_spss(
        x         = x_num,
        labels    = new_val_labs,
        na_values = used_codes,
        label     = attr(col, "label", exact = TRUE)
      )

      # Build display entries — source tag -> destination code, with the
      # label on the source side. Sort by tag (a, b, c, d) for stable
      # display order regardless of order-of-appearance in the data.
      # SAS-corrected columns display the original uppercase tag, since
      # post-correction `.a`/`.b` would obscure what the user actually
      # had in their data on input.
      was_sas <- vname %in% sas_corrected_vars
      display_entries <- character(0)
      for (tg in sort(unique_tags)) {
        code <- code_for_tag[[tg]]
        display_tag <- if (was_sas) toupper(tg) else tg
        source_disp <- paste0(".", display_tag)
        lbl  <- NA_character_
        if (!is.null(val_labs) && length(val_labs) > 0L) {
          vl_tags <- haven::na_tag(val_labs)
          mm <- which(!is.na(vl_tags) & vl_tags == tg)
          if (length(mm) > 0L) lbl <- names(val_labs)[mm[1]]
        }
        source_disp_with_lbl <- if (!is.na(lbl) && nzchar(lbl)) {
          sprintf('%s "%s"', source_disp, lbl)
        } else source_disp
        display_entries <- c(display_entries,
                             sprintf("%s -> %s",
                                     source_disp_with_lbl,
                                     as.character(code)))
      }
      converted_vars         <- c(converted_vars, vname)
      converted_info[[vname]] <- list(display = display_entries)

    } else if (to %in% c("stata", "sas")) {

      target_upper <- identical(to, "sas")

      if (info$representation == "stata") {
        # Tagged column already. If every tag (cells and value labels) is
        # in the target case, it is genuinely in target form -- skip. Any
        # off-case tag is case-corrected -- a real conversion, counted and
        # displayed as such. Mixed-case columns collapse to the target
        # case: an off-case tag flipping onto an existing same-letter tag
        # merges with it, mirroring the to = "spss" branch's collapse
        # (the case distinction is not a distinction the tagged formats
        # can jointly preserve).
        cell_tags <- haven::na_tag(col)
        val_labs  <- labelled::val_labels(col)
        lab_tags  <- if (!is.null(val_labs)) haven::na_tag(val_labs)
                     else character(0)
        all_tags  <- c(cell_tags[!is.na(cell_tags)],
                       lab_tags[!is.na(lab_tags)])
        off_case  <- unique(all_tags[if (target_upper) all_tags %in% letters
                                     else all_tags %in% LETTERS])

        if (length(off_case) == 0L) {
          skipped_already <- c(skipped_already, vname)
          next
        }

        flip <- if (target_upper) toupper else tolower

        off_cells <- which(!is.na(cell_tags) & cell_tags %in% off_case)
        if (length(off_cells) > 0L) {
          for (i in off_cells) col[i] <- haven::tagged_na(flip(cell_tags[i]))
        }
        if (!is.null(val_labs) && length(val_labs) > 0L) {
          off_labs <- which(!is.na(lab_tags) & lab_tags %in% off_case)
          if (length(off_labs) > 0L) {
            new_vl <- val_labs
            for (i in off_labs) {
              new_vl[i] <- haven::tagged_na(flip(lab_tags[i]))
            }
            labelled::val_labels(col) <- new_vl
          }
        }
        data[[vname]] <- col

        # Display: original tag (with its label, if any) -> flipped tag.
        display_entries <- character(0)
        for (tg in sort(off_case)) {
          lbl <- NA_character_
          if (!is.null(val_labs) && length(val_labs) > 0L) {
            mm <- which(!is.na(lab_tags) & lab_tags == tg)
            if (length(mm) > 0L) lbl <- names(val_labs)[mm[1]]
          }
          source_disp <- if (!is.na(lbl) && nzchar(lbl)) {
            sprintf('.%s "%s"', tg, lbl)
          } else paste0(".", tg)
          display_entries <- c(display_entries,
                               sprintf("%s -> .%s", source_disp, flip(tg)))
        }
        converted_vars          <- c(converted_vars, vname)
        converted_info[[vname]] <- list(display = display_entries)
        next
      }

      # SPSS-form column: consume the pre-flight's conversion plan (the
      # merged discrete + enumerated-range set, Q6-ordered and lettered
      # in the target case; see the pre-flight above for the rules).
      plan          <- tagged_plan[[vname]]
      sorted_values <- plan$sorted_values
      plan_letters  <- plan$letters
      tag_for_value <- stats::setNames(plan_letters,
                                       as.character(sorted_values))

      x_num   <- suppressWarnings(as.numeric(unclass(col)))
      new_col <- as.numeric(x_num)
      for (v in sorted_values) {
        tag_letter <- tag_for_value[[as.character(v)]]
        pos        <- which(!is.na(x_num) & x_num == v)
        if (length(pos) > 0L) new_col[pos] <- haven::tagged_na(tag_letter)
      }

      val_labs     <- labelled::val_labels(col)
      new_val_labs <- val_labs
      if (!is.null(new_val_labs) && length(new_val_labs) > 0L) {
        for (i in seq_along(new_val_labs)) {
          v <- unname(new_val_labs[i])
          # Gate on the merged set — val_labs entries pointing at values
          # that are neither declared codes nor enumerated range values
          # are real-data labels and must stay as numeric entries.
          if (!is.na(v) && v %in% sorted_values) {
            new_val_labs[i] <- haven::tagged_na(
              tag_for_value[[as.character(v)]])
          }
        }
      }

      data[[vname]] <- haven::labelled(
        x      = new_col,
        labels = new_val_labs,
        label  = attr(col, "label", exact = TRUE)
      )

      # Build display entries — source value -> destination tag, with the
      # label shown on the source side, emitted in sorted order (largest
      # |value| first per Q6). A band contributes a trailing entry: either
      # the enumeration fact, or -- when it supplied no values at all --
      # the dropped-declaration report (Q1: the empty declaration is
      # reported even at zero, since the loss is largest exactly when
      # nothing was translated).
      display_entries <- character(0)
      for (i in seq_along(sorted_values)) {
        v   <- sorted_values[i]
        tg  <- plan_letters[i]
        lbl <- NA_character_
        if (!is.null(val_labs) && length(val_labs) > 0L) {
          mm <- which(unname(val_labs) == v & !is.na(unname(val_labs)))
          if (length(mm) > 0L) lbl <- names(val_labs)[mm[1]]
        }
        source_disp <- if (!is.na(lbl) && nzchar(lbl)) {
          sprintf('%s "%s"', as.character(v), lbl)
        } else as.character(v)
        display_entries <- c(display_entries,
                             sprintf("%s -> .%s", source_disp, tg))
      }
      if (!is.null(plan$band)) {
        band_disp <- sprintf("range [%s, %s]",
                             as.character(plan$band[1]),
                             as.character(plan$band[2]))
        if (plan$band_n > 0L) {
          display_entries <- c(display_entries,
                               paste0(band_disp, " enumerated"))
        } else {
          display_entries <- c(display_entries,
                               paste0(band_disp,
                                      ": no values found; declaration dropped"))
        }
        banded_converted <- c(banded_converted, vname)
      }
      converted_vars          <- c(converted_vars, vname)
      converted_info[[vname]] <- list(display = display_entries)
    }
  }

  # --- modify = TRUE write-back ---------------------------------------------
  # Only when at least one column converted -- the no-op paths return the
  # frame unchanged, so there is nothing to write back. Writes onto the
  # caller's bare-symbol variable (guarded above) or the juse() default
  # name; same caller-environment assign as jcopy(). The frame is still
  # returned invisibly below, so every call shape composes.
  if (isTRUE(modify) && length(converted_vars) > 0L) {
    modify_target <- if (arg1$mode == "explicit") as.character(data_sub_expr)
                     else arg1$name
    assign(modify_target, data, envir = parent.frame())
  }

  # --- Build notification (Q4 five-section format) --------------------------
  if (isTRUE(udm.notice)) {

    n_converted     <- length(converted_vars)
    n_already       <- length(skipped_already)
    n_pattern_a     <- length(pattern_a)
    n_skipped_nodes <- length(skipped_no_udms)

    # Empty-case detection. Two sub-cases need distinct messages:
    #   genuinely_empty       — no UDMs anywhere, no Pattern A. The truly
    #                           "nothing to look at" case.
    #   all_already_in_target — UDM-bearing columns exist but all already
    #                           match the requested target format. Whole-
    #                           DF flavour gets a single-line summary
    #                           since enumerating every already-in-target
    #                           column would be noisy.
    genuinely_empty       <- (length(info_list) == 0L && n_pattern_a == 0L)
    all_already_in_target <- (n_converted == 0L && n_pattern_a == 0L &&
                               n_skipped_nodes == 0L && n_already > 0L)

    if (genuinely_empty) {
      if (user_specified) {
        message("No user-defined missing values found in: ",
                paste(target_vars, collapse = ", "), ".")
      } else {
        message("No user-defined missing values found in '", data_name, "'.")
      }
      return(invisible(data))
    }

    if (all_already_in_target && !user_specified) {
      message(sprintf(
        "All variables with user-defined missing values in '%s' are already in %s-form representation.",
        data_name, to))
      return(invisible(data))
    }

    msg_lines <- character(0)

    # Header + Converted: section
    if (n_converted > 0L) {
      header_verb <- switch(
        to,
        baseR = "Stripped declarations of user-defined missing values (UDMs) from",
        spss  = "Converted to SPSS-style missing values in",
        stata = "Converted to Stata-style missing values in",
        sas   = "Converted to SAS-style missing values in"
      )
      msg_lines <- c(msg_lines, paste0(
        header_verb, " ", n_converted, " variable",
        if (n_converted == 1L) "" else "s", ":"))

      max_name_len <- max(nchar(converted_vars))
      for (vname in converted_vars) {
        ci <- converted_info[[vname]]
        msg_lines <- c(msg_lines, paste0(
          "  ", format(vname, width = max_name_len),
          "  (", paste(ci$display, collapse = ", "), ")"))
      }

      # Range-loss note (S218). Whenever a converted column carried an
      # na_range, state plainly what did not survive: the tagged formats
      # have no range concept, so the rule itself is gone and only the
      # values enumerated above were translated. Most important precisely
      # when the band was empty -- the declaration vanished with nothing
      # translated. Rides inside the udm.notice gate (Q2: an explicit
      # udm.notice = FALSE suppresses this along with the rest of the
      # report).
      if (length(banded_converted) > 0L) {
        style_word <- if (identical(to, "sas")) "SAS-style" else "Stata-style"
        msg_lines <- c(msg_lines, "", paste0(
          "Note: ", style_word, " missing values have no range concept. For the"))
        msg_lines <- c(msg_lines,
          "  range declarations above, only values present in the data or",
          "  carrying value labels were translated; the range rule itself was",
          "  not preserved. A range value first appearing in later data will",
          "  arrive as an ordinary data value.")
      }
    }

    # Skipped — already in target format (user_specified only — for whole-DF
    # the all_already_in_target short-circuit above already covered the case
    # where everything was already in target; for whole-DF with some
    # converted and some already in target, the already-in-target columns
    # are intentionally not enumerated to avoid noise).
    if (n_already > 0L && user_specified) {
      if (length(msg_lines) > 0L) msg_lines <- c(msg_lines, "")
      msg_lines <- c(msg_lines,
                     sprintf("Skipped (already in %s-form representation):", to),
                     paste0("  ", paste(skipped_already, collapse = ", ")))
    }

    # Skipped — no UDMs found (user_specified only by construction —
    # skipped_no_udms is only populated when user_specified is TRUE)
    if (n_skipped_nodes > 0L) {
      if (length(msg_lines) > 0L) msg_lines <- c(msg_lines, "")
      msg_lines <- c(msg_lines,
                     "Skipped (no user-defined missing values found):",
                     paste0("  ", paste(skipped_no_udms, collapse = ", ")))
    }

    # Skipped — value labels suggest missingness (Pattern A)
    if (n_pattern_a > 0L) {
      if (length(msg_lines) > 0L) msg_lines <- c(msg_lines, "")
      msg_lines <- c(msg_lines,
                     "Skipped (value labels suggest missingness but not formally declared):")
      for (vname in names(pattern_a)) {
        entries <- pattern_a[[vname]]
        for (e in entries) {
          msg_lines <- c(msg_lines, sprintf(
            "  %s: %s = \"%s\"",
            vname, as.character(e$value), e$label))
        }
      }
      msg_lines <- c(msg_lines,
                     "",
                     "  To formalize these as user-defined missing values, see jdeclare_udm().",
                     "  To leave them as ordinary data, no action is needed.")
    }

    # Assignment-syntax reminder (only when a conversion actually
    # happened AND the output level isn't "minimal" — the reminder is an
    # instructional aid for SPSS migrants new to R's assignment
    # semantics, displayed on the "standard" and "full" levels but
    # suppressed on "minimal" where users have already opted into
    # less-verbose output).
    if (n_converted > 0L) {
      out_level <- getOption(".jst_output_level", "standard")
      if (out_level != "minimal") {
        if (length(msg_lines) > 0L) msg_lines <- c(msg_lines, "")
        msg_lines <- c(msg_lines,
                       .jst_durability_note("convert", data_name,
                                            modify = modify))
      }
    }

    message(paste(msg_lines, collapse = "\n"))
  }

  invisible(data)
}
