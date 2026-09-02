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
  # to flag a real extreme value as suspicious. When haven metadata is
  # preserved, jload's UDM narrative (.jst_handle_udms) reports declared
  # codes regardless of magnitude; the heuristic is the safety net for
  # plain numerics where metadata has been stripped (e.g., post-csv/
  # xlsx/dta load).
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


  # Rule 2: absolute magnitude >= 5x the max of remaining values.
  # Vectorized leave-one-out formulation (S205): for each value, "the max
  # of the remaining values" needs only two numbers -- the overall absolute
  # max, and the runner-up for the sole holder of that max. Replaces the
  # previous per-value loop (others <- vals[vals != v]; max(abs(others))),
  # which rebuilt and rescanned the vector for every distinct value --
  # quadratic in distinct values, and the profiled cause of multi-second
  # jload waits on columns with thousands of distinct values (98% of load
  # time on a 144k-row file). Semantics identical: verified against the
  # loop on 20,000 randomized cases (ties, sign mixes, zeros, Rule-1
  # interaction) with zero mismatches. Values already flagged by Rule 1
  # are deduplicated by the final unique() rather than skipped up front.
  a  <- abs(vals)
  m1 <- max(a)
  n1 <- sum(a == m1)
  m2 <- if (n1 > 1) m1 else {
    rest <- a[a < m1]
    if (length(rest) > 0) max(rest) else 0
  }
  other_max <- rep(m1, length(a))
  if (n1 == 1) other_max[a == m1] <- m2
  suspicious <- c(suspicious, vals[other_max > 0 & a >= 5 * other_max])

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
# missing-suggestive labels surface for jdeclare_missing action.
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
# .jst_evidence_admits_missing_values()
#
# THE EVIDENCE CHANNEL of the package's user-defined-missing detection, and
# the sibling of .jst_detect_suspicious_values() above (THE MAGNITUDE
# CHANNEL). The two answer the same question from different evidence:
#
#   magnitude  - "this number is wildly out of line with the rest of the
#                column, so it may be a code rather than a measurement."
#                Sees numbers only. Deliberately conservative, and
#                documented as missing -99 in a column of plausible
#                magnitudes (ages, scores).
#   evidence   - "something attached to this column SAYS missing" (a value
#                label, or, in jencode's case, the words in the cells
#                themselves). Where that evidence is present, a candidate
#                does not have to clear the magnitude bar.
#
# Centralised here from birth (Session 238) so the admission rule is
# modified ONCE and every caller inherits the change, rather than each
# function growing its own bar. Any future revision -- widening what counts
# as evidence, changing which kept values qualify -- belongs in this
# function, not in a caller.
#
# THE RULE (S238, Jeff-ruled): evidence licenses reporting NEGATIVE values
# only. High positive sentinels (999 in a column of ages) already clear the
# magnitude bar via Rule 2 there, so admitting positives here would add
# false positives without covering a real gap.
#
# CURRENT CALLERS: jencode() only. jload's .jst_scan_coded_missing consults
# the wordlist too, but ONLY to reclassify a value magnitude already
# flagged ("suspected" -> "label-only") -- it cannot yet admit a value
# magnitude missed. Widening the scan to this admission channel is a
# separate item, coupled to the missing-label wordlist decision (S237),
# and until it lands the two paths are KNOWINGLY ASYMMETRIC: jencode
# reports a labelled -99 that the scan would not. Recorded rather than
# silently tolerated; see the cross-project to-do.
# -----------------------------------------------------------------------------

#' Internal helper: admit missing-value candidates on word/label evidence
#'
#' The evidence channel of UDM detection, sibling to
#' \code{.jst_detect_suspicious_values()} (the magnitude channel). Given a
#' set of values and a set of evidence strings drawn from the same column,
#' returns the values that evidence licenses reporting even though the
#' magnitude heuristic did not flag them.
#'
#' Evidence is present when at least one supplied string matches
#' \code{.jst_missing_label_wordlist} (via
#' \code{.jst_label_suggests_missing()}). When it is, negative values
#' qualify; positives never do, since positive sentinels already clear the
#' magnitude bar.
#'
#' @param values Numeric vector. Candidate values from the column, after
#'   any encoding has been applied.
#' @param evidence Character vector. Strings drawn from the same column
#'   that may signal missingness -- value labels, or the original words in
#'   a text column being encoded.
#'
#' @return A sorted numeric vector of admitted values, or
#'   \code{numeric(0)} when there is no evidence or nothing qualifies. The
#'   caller is responsible for excluding values the magnitude channel has
#'   already reported.
#'
#' @keywords internal
.jst_evidence_admits_missing_values <- function(values, evidence) {
  if (length(values) == 0L || length(evidence) == 0L) return(numeric(0))
  evidence <- evidence[!is.na(evidence)]
  if (length(evidence) == 0L) return(numeric(0))

  has_evidence <- any(vapply(evidence, .jst_label_suggests_missing,
                             logical(1)))
  if (!has_evidence) return(numeric(0))

  vals <- unique(as.numeric(values[!is.na(values)]))
  sort(vals[vals < 0])
}


#' Internal helper: which evidence strings signal missingness?
#'
#' Returns the subset of \code{evidence} that matches the missing-label
#' wordlist, so a message can cite the evidence it acted on rather than
#' asserting a conclusion the user cannot check. Order is preserved.
#'
#' @param evidence Character vector.
#'
#' @return Character vector, possibly empty.
#'
#' @keywords internal
.jst_missing_evidence_words <- function(evidence) {
  if (length(evidence) == 0L) return(character(0))
  evidence <- evidence[!is.na(evidence)]
  evidence[vapply(evidence, .jst_label_suggests_missing, logical(1))]
}


# -----------------------------------------------------------------------------
# .jst_apply_declared_udms_as_na()
#
# Pipeline-step helper invoked at .jst_apply_pipeline's Step 0 (and called
# directly by the listwise diagnostics and jsum/javg, which need the same
# masking without the pipeline's row filtering). Masks every column's
# DECLARED user-defined missing values to NA on the analysis copy; the
# user's data frame in the workspace is never touched. Treatment differs
# by representation, deliberately:
#
#   SPSS form (na_values / na_range attributes on haven_labelled_spss):
#   declared codes and in-band cells are overwritten with NA; the
#   na_values / na_range ATTRIBUTES STAY ATTACHED. The declaration is
#   metadata separate from the data, so after masking it still truthfully
#   describes what those codes mean on this variable.
#
#   Stata/SAS form (tagged NAs; lowercase .a.. and uppercase .A.. markers
#   alike): haven::zap_missing() converts tagged cells to plain NA and
#   removes the value labels attached to the tags. No keep-the-declaration
#   option exists on this side: a tag IS the declaration (it lives in the
#   cell, not in an attribute), so blanking the cell destroys it either
#   way, and labels left behind would be orphans pointing at markers no
#   longer present in the data. zap_missing() is the package's house
#   treatment for this shape (matches .jst_handle_udms()'s Stata branch).
#
# WHY tagged NAs are masked at all (AUDIT-039): tagged cells already
# satisfy is.na(), so every count, N, and complete.cases() result is
# correct without intervention -- but LABEL-DRIVEN conversion downstream
# does not go through is.na(). haven::as_factor() maps a labelled tag onto
# its label as an ordinary factor level, resurrecting declared-missing
# cases as their own category at the analysis functions' and plot helpers'
# conversion sites (jt mis-refused; jaov and jcrosstab ran silently wrong
# with the CPS contradicting the printed table). Zapping here protects
# every such site at one point. The fix is count-neutral by construction:
# tagged cells were is.na()-TRUE before and are plain NA after.
#
# Replaces .jst_preprocess_na (retired in v0.9.5) per Cross-cutting Decision
# 5 of JStats_Missing_Values_Reference.txt Part 4.
#
# Returns a list with:
#   data      - the modified analysis copy
#   converted - per-variable masking detail, SPSS FORM ONLY (deliberate --
#               see below). A named list; each element is
#               list(entries, n_cells) where entries is a data.frame with
#               columns code_display, label, count (one row per declared
#               na_values code, count possibly 0; plus one row per distinct
#               observed in-band value when a na_range is declared), and
#               n_cells is the aggregate OR-mask count. Consumed by jfreq's
#               Missing section for per-code counts; n_cells drives
#               udm_spss_active.
#
#               converted deliberately records NOTHING for Stata/SAS
#               columns. jfreq's per-tag Missing rows count tags off the
#               ORIGINAL pre-pipeline frame (haven::na_tag on raw_col) and
#               the Case Processing Summary reads the pre-pipeline
#               snapshot; recording tag entries here would create a
#               second, unsynchronized source for numbers that already
#               have one.
# -----------------------------------------------------------------------------

#' Internal helper: mask declared UDM cells to NA on the analysis copy
#'
#' @keywords internal
.jst_apply_declared_udms_as_na <- function(data) {
  converted <- list()

  for (vname in names(data)) {
    col  <- data[[vname]]
    # observed = TRUE: this pass already scans every column's data to build
    # the mask, so enumerating in-band values here costs nothing extra and
    # keeps ONE source for both the values and their counts.
    info <- .jst_missing_info(col, observed = TRUE)
    if (is.null(info)) next

    if (info$representation == "stata") {
      # Stata/SAS-form (lower- and uppercase tags alike): zap tagged cells
      # to plain NA and drop their labels, so downstream as_factor() cannot
      # revive a labelled tag as a factor level (AUDIT-039). Count-neutral;
      # deliberately records nothing in `converted` (see banner above).
      data[[vname]] <- haven::zap_missing(col)
      next
    }
    # Only SPSS representation remains (.jst_missing_info returns no other).

    # unclass() bypasses vctrs cast issues — see the matching note in
    # .jst_detect_suspicious_values() and .jst_handle_udms() for context.
    x_num <- suppressWarnings(as.numeric(unclass(col)))
    mask  <- rep(FALSE, length(x_num))

    # Per-value entries: one row per declared na_values code (count may be
    # 0 when a declared code is absent from the data), plus one row per
    # DISTINCT OBSERVED value falling inside a declared na_range.
    # code_display / label mirror .jst_missing_info()'s codes data frame
    # so jfreq's Missing section and the future CPS per_code bottom share
    # one per-value count source.
    #
    # `source` marks which declaration produced the row -- "code" for a
    # discrete na_values code, "range" for an in-band value. Consumers
    # that want the band collapsed sum the "range" rows; consumers that
    # want it enumerated read them individually. This replaces the
    # earlier rule that identified the range row as "whatever row is not
    # a declared code", which was fragile the moment more than one range
    # row could exist.
    #
    # The aggregate n_cells keeps its prior OR-mask semantics (used for
    # masking-activity detection / udm_spss_active), so the callers that read
    # only n_cells (jcomplete, jsum, javg, the pipeline) are unaffected.
    entries <- data.frame(code_display = character(0), label = character(0),
                          count = integer(0), source = character(0),
                          numeric = numeric(0), stringsAsFactors = FALSE)

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
          source       = "code",
          numeric      = as.numeric(cnum),
          stringsAsFactors = FALSE))
      }
    }
    if (!is.null(info$na_range) && length(info$na_range) == 2L) {
      # The mask still covers the WHOLE declared band, not just the
      # values that happen to occur -- masking semantics are unchanged.
      range_mask <- (!is.na(x_num) &
                       x_num >= min(info$na_range) &
                       x_num <= max(info$na_range))
      mask <- mask | range_mask

      # range_values excludes any value that is also declared discretely,
      # so summing the "range" rows never double-counts a "code" row.
      rv <- info$range_values
      if (!is.null(rv) && nrow(rv) > 0L) {
        for (i in seq_len(nrow(rv))) {
          rnum <- rv$numeric[i]
          entries <- rbind(entries, data.frame(
            code_display = rv$code[i],
            label        = rv$label[i],
            count        = as.integer(sum(!is.na(x_num) & x_num == rnum)),
            source       = "range",
            numeric      = as.numeric(rnum),
            stringsAsFactors = FALSE))
        }
      }
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
# equivalent numeric UDM codes drawn from joptions("missing.convention.codes")
# (default c(-99, -98, -97)). Mapping is positional: .a -> codes[1],
# .b -> codes[2], etc. Per Decision 4 of
# JStats_Missing_Values_Reference.txt Part 4 (Session 25 walk-through
# lock), this is the convention-based direction used by jconvert's
# Stata-to-SPSS conversion path -- which guards it with a collision
# check against the column's real values before converting. The
# jrecode/jencode cross-convention error was a second consumer until
# S246, when the echo-back it fed was retired: minting codes from the
# pool inside a message could not be made safe (Rule Y, the mint test).
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
#' from \code{joptions("missing.convention.codes")}. Mapping is positional:
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
#'   \code{joptions("missing.convention.codes")} via the standard
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
                                  .jst_options_defaults$missing.convention.codes)
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
