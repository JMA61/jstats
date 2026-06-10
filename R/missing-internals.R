#<<<FILE: missing-internals.R>>>

#' Internal helper: detect values that look like coded missing markers
#'
#' Scans a numeric vector for values likely to be coded missing markers
#' (e.g. \code{99}, \code{999}, \code{-99}) rather than legitimate
#' data. Two heuristics are applied:
#' \enumerate{
#'   \item Any negative value when all other values are positive --
#'     catches conventions like \code{-99} or \code{-9} for missing in
#'     otherwise non-negative categorical data.
#'   \item Any value whose absolute magnitude is at least 5 times the
#'     maximum of the other values -- catches \code{99} in a 1-5 scale,
#'     \code{999} in a 1-10 scale, and so on.
#' }
#' Does not print messages; the calling function decides how to surface
#' the findings.
#'
#' @param x A variable (numeric or numeric-coercible).
#' @param var_name Character. The variable's name; not used by this
#'   helper but accepted for symmetry with callers that supply it.
#'
#' @return A sorted, unique numeric vector of suspicious values, or an
#'   empty numeric if none are found.
#'
#' @keywords internal
.jst_detect_suspicious_values <- function(x, var_name) {

  # unclass() strips haven_labelled / vctrs_vctr wrappers and returns the
  # underlying double values unchanged, sidestepping a vctrs dispatch
  # ordering issue where as.numeric() on a haven_labelled subset can fail
  # in sessions where readxl was loaded before haven's vec_cast method
  # registered into vctrs's dispatch table. Class-neutral for non-haven
  # input — unclass() of a plain numeric is a no-op, and unclass() of a
  # factor returns the integer codes that as.numeric(factor) already used.
  vals <- unique(as.numeric(unclass(x)[!is.na(x)]))
  if (length(vals) < 2) return(numeric(0))

  suspicious <- numeric(0)

  # Rule 1: negative values when all others are positive AND
  # the absolute magnitude is at least 3x the max positive value.
  # NOTE: deliberately conservative — misses missing-value codes like
  # -99 in variables with naturally high positives (e.g., Age 18-80
  # would not flag -99 because 99 < 3 * 80 = 240). Trade-off: better
  # to miss a sentinel that the user can spot from jload's output than
  # to flag a real extreme value as suspicious. The SPSS-defined UDM
  # detector (.jst_scan_coded_missing's na_values branch) catches
  # these cases when haven metadata is preserved; the heuristic is
  # the safety net for plain numerics where metadata has been stripped
  # (e.g., post-csv/xlsx/dta load).
  neg_vals <- vals[vals < 0]
  pos_vals <- vals[vals >= 0]

  if (length(neg_vals) > 0 && length(pos_vals) >= 2) {
    pos_max <- max(pos_vals)
    if (pos_max > 0) {
      suspicious <- c(suspicious, neg_vals[abs(neg_vals) >= 3 * pos_max])
    } else {
      suspicious <- c(suspicious, neg_vals)
    }
  }


  # Rule 2: absolute magnitude >= 5x the max of remaining values
  for (v in vals) {
    if (v %in% suspicious) next
    others <- vals[vals != v]
    if (length(others) == 0) next
    other_max <- max(abs(others))
    if (other_max > 0 && abs(v) >= 5 * other_max) {
      suspicious <- c(suspicious, v)
    }
  }

  return(sort(unique(suspicious)))
}


# -----------------------------------------------------------------------------
# Missing-label wordlist and predicate
#
# Canonical list of value-label strings that suggest a value is intended as
# missing rather than as ordinary data. Used to classify Pattern A (label-
# only, no formal declaration) variables in jconvert, and to narrow
# .jst_scan_coded_missing's label-only branch so generic labels on
# suspicious values fall through to the "suspected" classification while
# missing-suggestive labels surface for jdeclare_udm action.
#
# All entries are lower-case and whitespace-trimmed; .jst_label_suggests_
# missing() applies tolower(trimws(...)) before matching. Apostrophe
# variants of "don't know" are enumerated explicitly rather than via regex
# normalisation — the explicit list is easier to audit and extend.
#
# Replaces the literal "missing" match formerly performed by
# .jst_detect_missing_labels (retired in v0.9.5 per Cross-cutting Decision 1
# of JStats_Missing_Values_Reference.txt Part 4).
# -----------------------------------------------------------------------------

#' @keywords internal
.jst_missing_label_wordlist <- c(
  "missing", "refused", "don't know", "dont know",
  "no answer", "not asked", "not applicable", "n/a", "na",
  "skipped", "declined", "prefer not to say"
)


# -----------------------------------------------------------------------------
# .jst_label_system_missing
# Display label used in output tables for the system-missing row (R's
# plain NA, distinct from declared UDMs). "System/NA" reads in two
# audiences at once: SPSS/Stata users recognize "System" as the platform
# term for system-missing, and R users recognize "NA" as the in-language
# token for the same thing. Referenced wherever a per-row missing label
# is rendered (jfreq's Missing section in v0.9.6; CP table missing rows
# when the UDM-content work lands; future jscreen tweaks if its format
# aligns). Centralising as a constant ensures consistency if the term
# ever changes.
# -----------------------------------------------------------------------------

#' @keywords internal
.jst_label_system_missing <- "System/NA"


#' Internal helper: does a value label suggest missingness?
#'
#' Returns \code{TRUE} when the supplied label string, after case-folding
#' and whitespace trimming, matches an entry in
#' \code{.jst_missing_label_wordlist}. Returns \code{FALSE} for \code{NULL},
#' \code{NA}, non-character input, and labels that do not match the
#' wordlist.
#'
#' @keywords internal
.jst_label_suggests_missing <- function(label) {
  if (is.null(label)) return(FALSE)
  if (!is.character(label)) return(FALSE)
  if (length(label) != 1L) return(FALSE)
  if (is.na(label)) return(FALSE)
  tolower(trimws(label)) %in% .jst_missing_label_wordlist
}


# -----------------------------------------------------------------------------
# .jst_apply_declared_udms_as_na()
#
# Pipeline-step helper invoked at .jst_apply_pipeline's Step 0. For each
# column whose formal UDM information (as surfaced by .jst_missing_info)
# uses SPSS representation, masks declared na_values codes and na_range
# cells to NA on the analysis copy. The underlying data frame in the user's
# workspace is unchanged — na_values / na_range metadata stays attached to
# the column so round-trip fidelity through jsave is preserved. Stata-form
# tagged_na columns are not touched; tagged NAs satisfy is.na() natively at
# the C level and downstream code catches them without intervention.
#
# Replaces .jst_preprocess_na (retired in v0.9.5) per Cross-cutting Decision
# 5 of JStats_Missing_Values_Reference.txt Part 4.
#
# Returns a list with:
#   data      - the modified analysis copy
#   converted - a named list of per-variable entries. Each element is
#               list(entries, n_cells) where entries is a data.frame with
#               columns code_display, label, count (one row per declared
#               na_values code, count possibly 0; plus one row for the
#               na_range when declared), and n_cells is the aggregate
#               OR-mask count. Consumed by jfreq's Missing section for
#               per-code counts and by the (forthcoming) CPS per_code
#               bottom; n_cells drives udm_active.
# -----------------------------------------------------------------------------

#' Internal helper: mask declared SPSS-form UDM cells to NA on analysis copy
#'
#' @keywords internal
.jst_apply_declared_udms_as_na <- function(data) {
  converted <- list()

  for (vname in names(data)) {
    col  <- data[[vname]]
    info <- .jst_missing_info(col)
    if (is.null(info)) next
    if (info$representation != "spss") next

    # unclass() bypasses vctrs cast issues — see the matching note in
    # .jst_detect_suspicious_values() and .jst_handle_udms() for context.
    x_num <- suppressWarnings(as.numeric(unclass(col)))
    mask  <- rep(FALSE, length(x_num))

    # Per-code entries: one row per declared na_values code (count may be
    # 0 when a declared code is absent from the data), plus one row for
    # the na_range when declared. code_display / label mirror
    # .jst_missing_info()'s codes data frame so jfreq's Missing section
    # and the future CPS per_code bottom share one per-code count source.
    # The aggregate n_cells keeps its prior OR-mask semantics (used for
    # masking-activity detection / udm_active).
    entries <- data.frame(code_display = character(0), label = character(0),
                          count = integer(0), stringsAsFactors = FALSE)

    if (!is.null(info$codes) && nrow(info$codes) > 0L) {
      for (i in seq_len(nrow(info$codes))) {
        cnum <- info$codes$numeric[i]
        if (is.na(cnum)) next
        code_mask <- (!is.na(x_num) & x_num == cnum)
        mask      <- mask | code_mask
        entries   <- rbind(entries, data.frame(
          code_display = info$codes$code[i],
          label        = info$codes$label[i],
          count        = as.integer(sum(code_mask)),
          stringsAsFactors = FALSE))
      }
    }
    if (!is.null(info$na_range) && length(info$na_range) == 2L) {
      range_mask <- (!is.na(x_num) &
                       x_num >= info$na_range[1] &
                       x_num <= info$na_range[2])
      mask    <- mask | range_mask
      entries <- rbind(entries, data.frame(
        code_display = sprintf("range %s to %s",
                               as.character(info$na_range[1]),
                               as.character(info$na_range[2])),
        label        = NA_character_,
        count        = as.integer(sum(range_mask)),
        stringsAsFactors = FALSE))
    }

    n_cells <- sum(mask)
    if (n_cells > 0L) {
      # Positional indexing preserves class, na_values, na_range, and
      # value labels — only the underlying values change.
      data[[vname]][mask] <- NA
      converted[[vname]] <- list(
        entries = entries,
        n_cells = n_cells
      )
    }
  }

  list(data = data, converted = converted)
}


# -----------------------------------------------------------------------------
# .jst_tag_letters_to_codes()
#
# Translates Stata-style tagged-NA letter tags (.a, .b, ...) into the
# equivalent numeric UDM codes drawn from joptions("udm.convention.codes")
# (default c(-99, -98, -97, -96)). Mapping is positional: .a -> codes[1],
# .b -> codes[2], etc. Per Decision 4 of
# JStats_Missing_Values_Reference.txt Part 4 (Session 25 walk-through
# lock), this is the convention-based direction shared between
# jconvert's Stata-to-SPSS conversion path and jrecode's cross-
# convention error echo-back. jdeclare_udm in Step 5b will consume
# the same helper.
#
# When the input letter count exceeds the convention code count, the
# return covers only the mappable subset (in order) and
# attr(result, "unmapped") holds the letters that could not be mapped.
# Callers decide whether to error, truncate, or annotate based on the
# unmapped attribute.
# -----------------------------------------------------------------------------

#' Internal helper: map Stata-style tagged-NA letters to UDM codes
#'
#' Translates a vector of lowercase letter tags (e.g.
#' \code{c("a", "b")}) into the equivalent numeric UDM codes drawn
#' from \code{joptions("udm.convention.codes")}. Mapping is positional:
#' \code{.a} maps to the first code, \code{.b} to the second, etc.
#'
#' When \code{length(letters_in) > length(convention_codes)}, the
#' return covers only the mappable subset (in order) and
#' \code{attr(result, "unmapped")} holds the letters that could not be
#' mapped. Callers decide whether to error, truncate, or annotate
#' based on the unmapped attribute.
#'
#' @param letters_in Character vector of lowercase letter tags. Must
#'   be single lowercase letters (\code{"a"} through \code{"z"}); no
#'   leading period. Caller is responsible for stripping any leading
#'   period before calling.
#' @param convention_codes Optional numeric vector of UDM codes. When
#'   \code{NULL} (the default), the helper sources the value of
#'   \code{joptions("udm.convention.codes")} via the standard
#'   \code{getOption()} fallback.
#'
#' @return Named numeric vector. Names are the input letters; values
#'   are the corresponding convention codes. Carries an
#'   \code{unmapped} attribute (character vector) when the input
#'   letter count exceeded the convention code count.
#'
#' @keywords internal
.jst_tag_letters_to_codes <- function(letters_in, convention_codes = NULL) {

  if (is.null(convention_codes)) {
    convention_codes <- getOption(".jst_options_udm_convention_codes",
                                  .jst_options_defaults$udm.convention.codes)
  }

  if (length(letters_in) == 0L) {
    return(stats::setNames(numeric(0), character(0)))
  }

  n_mappable <- min(length(letters_in), length(convention_codes))

  result <- stats::setNames(
    as.numeric(convention_codes)[seq_len(n_mappable)],
    letters_in[seq_len(n_mappable)]
  )

  if (length(letters_in) > length(convention_codes)) {
    attr(result, "unmapped") <-
      letters_in[(length(convention_codes) + 1L):length(letters_in)]
  }

  result
}
