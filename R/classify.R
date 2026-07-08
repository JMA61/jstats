#<<<FILE: classify.R>>>


# -- Variable classifier helpers ----------------------------------------------
#
# Four helpers that answer "what kind of variable is this?" Each does one
# thing well — they are deliberately not merged because callers have
# different needs:
#
#   .jst_is_categorical()      — intent helper. TRUE only when the user has
#                                declared categorical (jdummy registration,
#                                or class factor/logical/character). Drives
#                                behavioral decisions in jlm and jlogistic.
#   .jst_is_discrete_integer() — structural helper. TRUE for variables that
#                                *look* categorical (haven-labelled with
#                                labels in data and <= 6 distinct values, or
#                                whole-number 0-6 numeric). Drives warnings.
#   .jst_is_dichotomy()        — single source of truth for "is this a two-
#                                value variable, and what coding does it
#                                use?" Used by jlm and jlogistic DV/IV
#                                checks; future jcorr point-biserial.
#   .jst_is_count()            — TRUE for plain non-negative whole-number
#                                numeric, max <= 6, not haven-labelled.
#                                Warning trigger for jlm DV.
# -----------------------------------------------------------------------------

#' Internal helper: intent-based categorical classifier
#'
#' Returns TRUE only when the user has explicitly signalled that a variable
#' should be treated as categorical. This helper answers the question
#' "should this variable be behaviorally treated as categorical?" -- for
#' decisions like factoring in regression, expanding to dummies, or
#' excluding from a correlation matrix.
#'
#' Paired with \code{.jst_is_discrete_integer()} (the structural helper).
#' Callers needing behavioral decisions use this helper; callers needing
#' a warning trigger typically check this helper first, and fall back to
#' the structural helper only if this one returns FALSE.
#'
#' Rules (first match wins):
#'
#' \enumerate{
#'   \item Per-call \code{override}: "categorical" -> TRUE; "numeric" or
#'         "count" -> FALSE (a count is numeric-like for the categorical-vs-
#'         numeric decision this helper answers). NULL falls through.
#'   \item jdummy() registration for \code{var_name} on \code{data_name}
#'         -> categorical.
#'   \item Class factor, logical, or character -> categorical.
#'   \item Otherwise -> FALSE.
#' }
#'
#' NA preprocessing is expected to have run already via
#' \code{.jst_apply_pipeline()} before this helper is called on analysis
#' data, though neither rule depends on NA state.
#'
#' @param x A variable (vector).
#' @param var_name Optional character string. The variable's column name.
#'   Required for the jdummy() registration check.
#' @param data_name Optional character string. The data frame's name.
#'   Required for the jdummy() registration check.
#' @param override Optional per-call asserted role for \code{x}: one of
#'   "categorical", "numeric", or "count" (or NULL for no override). When
#'   supplied it takes precedence over registration and structure, matching
#'   the tier-1 per-call slot in the classification resolver.
#' @return TRUE if the user has declared the variable categorical,
#'   FALSE otherwise.
#' @keywords internal
.jst_is_categorical <- function(x, var_name = NULL, data_name = NULL,
                                override = NULL) {

  # -- Rule 0: per-call override (highest priority) ------------------------
  if (!is.null(override)) {
    if (identical(override, "categorical")) return(TRUE)
    if (override %in% c("numeric", "count")) return(FALSE)
  }

  # -- Rule A: jdummy() registration ---------------------------------------
  if (!is.null(var_name) && !is.null(data_name)) {
    dummy_regs <- .jst_get_dummy(data_name)
    if (!is.null(dummy_regs) && length(dummy_regs) > 0) {
      is_registered <- any(vapply(dummy_regs,
                                  function(r) identical(r$var_name, var_name),
                                  logical(1)))
      if (is_registered) return(TRUE)
    }
  }

  # -- Rule B: factor, logical, character ----------------------------------
  if (is.factor(x) || is.logical(x) || is.character(x)) return(TRUE)

  FALSE
}


#' Internal helper: structural categorical-looking classifier
#'
#' Returns TRUE when a variable's shape suggests it *could* be categorical
#' but has not been explicitly declared as such via jdummy() or a per-call
#' override. This helper answers a different question from
#' \code{.jst_is_categorical()}: it describes the structure of the values,
#' not the user's intent.
#'
#' Used primarily as a *warning trigger*: callers that want to alert users
#' to "this looks like it should probably have been jdummy-registered or
#' passed via categorical=" check this helper. It does NOT license
#' behavioral changes -- analysis functions should only factor variables
#' based on the intent helper, not this one.
#'
#' Two structural rules, checked in order. First match wins.
#'
#' \enumerate{
#'   \item haven_labelled (including haven_labelled_spss) with value labels
#'         attached to at least one non-missing value present in the data,
#'         AND <= 6 unique non-NA values overall -> TRUE. Character-type
#'         labelled vectors return TRUE immediately. Numeric labelled
#'         vectors require BOTH that at least one labelled code actually
#'         appears in the (post-NA-preprocessing) data AND that there are
#'         no more than 6 distinct values present (variables with 7+
#'         distinct values have enough categories that linear-model
#'         assumptions hold reasonably well).
#'   \item Plain numeric (or haven_labelled numeric that fell through 1)
#'         with all whole-number values, min >= 0, max <= 6, and at least
#'         2 unique non-NA values -> TRUE.
#' }
#'
#' Bounds on both rules (0 to 6 inclusive) support the common view that
#' an interval-like variable with 6+ categories is adequately continuous
#' for linear-model use. 7-category Likert coded as 0-6 or 1-6 still
#' triggers the warning; coded as 1-7 does not. A 10-category labelled
#' Income variable falls through both rules and is treated as continuous.
#'
#' NA preprocessing (auto-conversion of values labelled "Missing" to NA)
#' is expected to have run already via \code{.jst_apply_pipeline()} before
#' this helper is called on analysis data. Rule 1's "labelled codes
#' present in data" check depends on this ordering.
#'
#' @param x A variable (vector).
#' @param var_name Optional character string. The variable's column name.
#'   Accepted for call-site symmetry with \code{.jst_is_categorical()};
#'   not currently used in this helper's logic.
#' @param data_name Optional character string. The data frame's name.
#'   Accepted for call-site symmetry with \code{.jst_is_categorical()};
#'   not currently used in this helper's logic.
#' @return TRUE if the variable has categorical-like structure,
#'   FALSE otherwise.
#' @keywords internal
.jst_is_discrete_integer <- function(x, var_name = NULL, data_name = NULL) {

  # -- Rule 1: haven_labelled with non-missing value labels ----------------
  # Require at most 6 unique non-NA values present in the data. Variables
  # with 7+ distinct values have enough categories that linear-regression
  # assumptions hold reasonably well (the 6-7 minimum convention for
  # interval-like DVs), so we do not flag them as categorical-like even
  # if they came in with value labels attached.
  if (haven::is.labelled(x)) {
    val_labs <- labelled::val_labels(x)
    if (!is.null(val_labs) && length(val_labs) > 0) {
      if (typeof(x) == "character") {
        # Character-labelled: any labels present make it categorical.
        return(TRUE)
      }
      # Numeric-labelled: require at least one labelled code to be present
      # in the (post-NA-preprocessing) data, AND require <= 6 unique
      # non-NA values overall. The first check prevents a continuous
      # variable with only a "Missing" label from misclassifying as
      # categorical once the missing values have been NA'd out. The
      # second check prevents large-N labelled variables (e.g., Income
      # with 10 broad categories) from being flagged.
      x_num       <- suppressWarnings(as.numeric(x))
      non_na_vals <- x_num[!is.na(x_num)]
      if (length(non_na_vals) > 0 &&
          any(val_labs %in% non_na_vals) &&
          length(unique(non_na_vals)) <= 6) {
        return(TRUE)
      }
      # Fall through to Rule 2 if no labelled codes remain in the data,
      # or if the variable has too many unique values to be flagged.
    }
  }

  # -- Rule 2: whole-number 0-6 range --------------------------------------
  if (is.numeric(x) || haven::is.labelled(x)) {
    x_num   <- suppressWarnings(as.numeric(x))
    x_clean <- x_num[!is.na(x_num)]
    if (length(x_clean) >= 2) {
      unique_vals <- unique(x_clean)
      if (length(unique_vals) >= 2 &&
          all(x_clean == floor(x_clean)) &&
          min(x_clean) >= 0 &&
          max(x_clean) <= 6) {
        return(TRUE)
      }
    }
  }

  FALSE
}


#' Internal helper: a labelled variable's surviving (non-missing) value labels
#'
#' Returns the value labels of a haven-labelled column with every code that is
#' declared missing removed, so the scale-detection helpers judge a variable on
#' its real response options rather than on missing-value sentinels mixed into
#' the label set. Declared-missing codes are read through the central
#' \code{.jst_missing_info()} reader, so SPSS-style \code{na_values} and
#' \code{na_range} declarations and Stata-/SAS-style tagged NAs are all handled
#' in one place. (A 1-to-5 agreement item carrying a Refused code of -99 and a
#' Don't-know code of -98 as declared missings therefore yields the five real
#' scale points, not seven codes with a gap.)
#'
#' @param col A variable / data-frame column.
#' @return A named numeric vector of surviving value labels (names are the
#'   label texts, values the codes), or \code{NULL} if the column is not
#'   labelled or has no value labels. Length 0 if every label is a declared
#'   missing.
#' @keywords internal
.jst_surviving_value_labels <- function(col) {
  if (!haven::is.labelled(col)) return(NULL)
  vl <- labelled::val_labels(col)
  if (is.null(vl) || length(vl) == 0L) return(NULL)

  codes <- suppressWarnings(as.numeric(unname(vl)))
  keep  <- !is.na(codes)                 # drops tagged-NA labels (Stata / SAS)

  mi <- .jst_missing_info(col)
  if (!is.null(mi)) {
    if (!is.null(mi$codes) && nrow(mi$codes) > 0L) {
      na_num <- mi$codes$numeric[!is.na(mi$codes$numeric)]
      if (length(na_num) > 0L) keep <- keep & !(codes %in% na_num)
    }
    if (!is.null(mi$na_range) && length(mi$na_range) == 2L) {
      lo <- min(mi$na_range); hi <- max(mi$na_range)
      keep <- keep & !(codes >= lo & codes <= hi)
    }
  }
  vl[keep]
}


#' Internal helper: a labelled variable's normalized non-missing label set
#'
#' The set of surviving (non-missing) value-label texts, trimmed and case-
#' folded, sorted and de-duplicated. This is the unit the Likert battery test
#' compares between adjacent columns: two columns belong to the same battery
#' when their normalized label sets are equal, regardless of which code each
#' label is mapped to (so a reverse-keyed sibling, which shares the same answer
#' words on a flipped code mapping, still matches).
#'
#' @param col A variable / data-frame column.
#' @return A character vector (sorted, unique, lower-cased, trimmed) of the
#'   surviving label texts, or \code{character(0)}.
#' @keywords internal
.jst_nonmissing_label_set <- function(col) {
  surv <- .jst_surviving_value_labels(col)
  if (is.null(surv) || length(surv) == 0L) return(character(0))
  txt <- names(surv)
  txt <- txt[!is.na(txt)]
  txt <- trimws(tolower(txt))
  sort(unique(txt[nzchar(txt)]))
}


# .jst_likert_anchor_families
#
# The maintained list of ordered scale families used by the anchor branch of
# .jst_is_likert. Each entry is the pair of opposite pole WORDS for one family;
# a column fires the anchor test when BOTH pole words of any family appear as
# whole tokens among its (non-missing) label texts. Matching is on whole tokens
# (labels split on non-letters and case-folded), so an intensity modifier rides
# along for free -- "Strongly Disagree" tokenizes to {strongly, disagree} and
# is caught by the "disagree" pole without listing "strongly" here, and the two
# poles are distinct tokens ("disagree" is not "agree"; "dissatisfied" is not
# "satisfied"), so a one-pole-only scale does not fire. English-centric by
# design; a non-English scale is reached through the battery test or declared
# with jlikert(). Deliberately small and easily extended. (Session 87)
.jst_likert_anchor_families <- list(
  agreement    = c("agree",     "disagree"),
  satisfaction = c("satisfied", "dissatisfied"),
  frequency    = c("never",     "always"),
  likelihood   = c("likely",    "unlikely"),
  quality      = c("poor",      "excellent")
)


#' Internal helper: do a variable's labels carry a recognised scale anchor pair?
#'
#' The column-local (single-item) half of the Likert sufficient discriminator.
#' Tokenizes the supplied label texts (split on non-letters, case-folded) and
#' returns TRUE when both pole words of any family in
#' \code{.jst_likert_anchor_families} are present. Because it tests for the
#' PRESENCE of both poles, it is reverse-coding-agnostic (the direction of the
#' code mapping is irrelevant). English-centric.
#'
#' @param label_texts Character vector of label texts (typically the surviving,
#'   non-missing labels of a column).
#' @return TRUE if a recognised anchor pair is present, FALSE otherwise.
#' @keywords internal
.jst_labels_match_anchor <- function(label_texts) {
  if (length(label_texts) == 0L) return(FALSE)
  toks <- unlist(strsplit(tolower(label_texts), "[^a-z]+"))
  toks <- unique(toks[nzchar(toks)])
  if (length(toks) == 0L) return(FALSE)
  for (fam in .jst_likert_anchor_families) {
    if (all(fam %in% toks)) return(TRUE)
  }
  FALSE
}


#' Internal helper: does a column sit in a contiguous Likert battery?
#'
#' The sibling-aware half of the Likert sufficient discriminator. A column is
#' part of a battery when at least one IMMEDIATELY ADJACENT column (the one to
#' its left or right in data-frame column order) shares its normalized non-
#' missing label set (see \code{.jst_nonmissing_label_set()}). Adjacency uses
#' the column's position in the named frame fetched by \code{data_name}; the
#' run breaks at the first neighbour with a different label set, so an adjacent
#' same-size nominal or a different-scale battery is naturally excluded. Two
#' matching columns are enough (a run of length 2 or more). Category count plays
#' no part -- the match is on the answer-word set, not the number of categories.
#'
#' The frame is fetched by name from the global environment (and the attached
#' search path); when \code{var_name} or \code{data_name} is absent, the named
#' object is not a data frame, the column is not found in it, or the column has
#' no surviving labels, the test returns FALSE and the caller falls back to the
#' anchor branch. A battery member therefore needs the resolver to have been
#' given the variable and frame identity (jscreen always supplies both); a bare
#' \code{.jst_is_likert(x)} relies on anchors alone. The name-based fetch can
#' miss when the frame is local to a calling function rather than global, a
#' tolerated gap: anchors still carry English scales and \code{jlikert()} is
#' always available.
#'
#' @param col The column under test.
#' @param var_name Character string naming the column, or NULL.
#' @param data_name Character string naming the data frame, or NULL.
#' @return TRUE if the column is part of an adjacent same-label-set run of
#'   length 2 or more, FALSE otherwise.
#' @keywords internal
.jst_in_likert_battery <- function(col, var_name = NULL, data_name = NULL) {
  if (is.null(var_name) || is.null(data_name)) return(FALSE)

  df <- get0(data_name, envir = globalenv(), inherits = TRUE, ifnotfound = NULL)
  if (is.null(df) || !is.data.frame(df)) return(FALSE)

  nms <- names(df)
  pos <- match(var_name, nms)
  if (is.na(pos)) return(FALSE)

  this_set <- .jst_nonmissing_label_set(col)
  if (length(this_set) == 0L) return(FALSE)

  neighbours <- integer(0)
  if (pos > 1L)           neighbours <- c(neighbours, pos - 1L)
  if (pos < length(nms))  neighbours <- c(neighbours, pos + 1L)

  for (j in neighbours) {
    nb_set <- .jst_nonmissing_label_set(df[[j]])
    if (length(nb_set) > 0L && setequal(this_set, nb_set)) return(TRUE)
  }
  FALSE
}


#' Internal helper: does a variable look like a Likert (ordered scale) item?
#'
#' The single detector for the "Likert" Categorical sub-class. Detection is in
#' two stages: a NECESSARY structural gate, then a SUFFICIENT discriminator that
#' separates a real ordered scale from a labelled nominal that happens to share
#' the same shape (the hard case the v1 consecutive-only detector could not tell
#' apart).
#'
#' Necessary structure (all must hold):
#' \enumerate{
#'   \item The variable is haven-labelled with at least one value label.
#'   \item Its SURVIVING value labels -- the labelled codes left after declared
#'         missing values are removed (SPSS-style \code{na_values} /
#'         \code{na_range}, Stata-/SAS-style tagged NAs), read through
#'         \code{.jst_missing_info()} -- are whole numbers forming a consecutive
#'         run (no gaps) of length 3 to 7. Removing the missing sentinels first
#'         is what lets a 1-to-5 item carrying a Refused code of -99 and a
#'         Don't-know code of -98 read as a clean 5-point scale rather than
#'         seven codes with a gap. A two-code variable is a dichotomy (handled
#'         earlier); 8 or more surviving codes is treated as continuous.
#'   \item Every value present in the data (declared missings excluded, which
#'         \code{is.na()} already flags on \code{labelled_spss} and tagged-NA
#'         columns) is one of the surviving scale points. An UNDECLARED sentinel
#'         (e.g. a literal -99 never declared missing) is therefore NOT silently
#'         absorbed: its presence fails the test, leaving the load-time coded-
#'         missing scan to nudge the user to declare it.
#' }
#'
#' Sufficient discriminator (Likert if EITHER fires):
#' \itemize{
#'   \item ANCHORS -- the surviving labels contain both pole words of a
#'         recognised ordered family (see \code{.jst_likert_anchor_families}),
#'         matched on whole tokens. Column-local, so it catches a lone item;
#'         reverse-coding-agnostic; English-centric.
#'   \item BATTERY -- the column sits in a contiguous run of adjacent columns
#'         sharing the same normalized non-missing label set (see
#'         \code{.jst_in_likert_battery()}). Language-agnostic; needs the
#'         resolver to carry the variable and frame identity.
#' }
#' Category count plays no role in either branch -- matching on count would re-
#' admit the very property a nominal shares with a battery.
#'
#' This is display/reporting scoped: a TRUE result refines the Categorical sub-
#' class to "Likert" but never changes a variable's analysis class or how
#' analyses treat it. The detector does not have to be perfect: a non-English
#' lone scale with no recognised anchor, or a scattered (non-adjacent) battery,
#' is not auto-detected and is declared with \code{jlikert()}; a labelled
#' nominal whose labels happen to carry an anchor pair could still read
#' "Likert", a tolerated cosmetic call given the sub-class carries no analysis
#' consequence.
#'
#' Because this is called only from the Categorical branch of
#' \code{.jst_class_from_role()}, it is reached structurally only for variables
#' already routed to Categorical (<= 6 categories), so the auto-detected range
#' is 3 to 6 in practice. A 7-point labelled scale resolves to Numeric
#' structurally (the Numeric/Categorical boundary is unchanged) and must be
#' declared with \code{jlikert()}.
#'
#' @param x A variable / data-frame column.
#' @param var_name Optional variable name; with \code{data_name}, lets the
#'   battery branch locate the column among its siblings.
#' @param data_name Optional data-frame name; with \code{var_name}, names the
#'   frame the battery branch fetches to read adjacent columns.
#' @return TRUE if the variable is detected as a Likert (ordered labelled
#'   scale) item, FALSE otherwise.
#' @keywords internal
.jst_is_likert <- function(x, var_name = NULL, data_name = NULL) {
  if (!haven::is.labelled(x)) return(FALSE)

  # -- Necessary structure: surviving codes form a consecutive integer run ----
  surv <- .jst_surviving_value_labels(x)
  if (is.null(surv) || length(surv) == 0L) return(FALSE)

  codes <- suppressWarnings(as.numeric(unname(surv)))
  if (any(is.na(codes)) || any(codes != floor(codes))) return(FALSE)
  codes_sorted <- sort(unique(codes))
  n_codes <- length(codes_sorted)
  if (n_codes < 3L || n_codes > 7L) return(FALSE)
  if (any(diff(codes_sorted) != 1)) return(FALSE)

  # Every present value (declared missings already dropped by is.na()) must be
  # one of the surviving scale points.
  xn      <- .jst_as_numeric(x)
  present <- xn[!is.na(x)]
  present <- present[!is.na(present)]
  if (length(present) == 0L) return(FALSE)
  if (!all(present %in% codes_sorted)) return(FALSE)

  # -- Sufficient discriminator: anchors (column-local) OR battery (siblings) -
  if (.jst_labels_match_anchor(names(surv))) return(TRUE)
  if (.jst_in_likert_battery(x, var_name, data_name)) return(TRUE)

  FALSE
}


#' Internal helper: classify a variable for descriptive summarization
#'
#' Single source of truth for \code{jdesc()}'s decision about whether a
#' variable can be summarized with descriptive statistics (Min/Max/Mean/SD)
#' and, if so, how it is coerced to numeric. Used by both the ungrouped and
#' the by-group paths so the two cannot drift apart.
#'
#' Summarized: plain numeric, haven-labelled (numeric underlying), logical
#' (as 0/1), factors whose levels are numeric, and character columns whose
#' values are numbers stored as text (a note is attached in that case).
#' Refused: factors with text categories, character columns that are true
#' text, date/time variables (\code{Date}, \code{POSIXct}, \code{POSIXlt},
#' \code{difftime}), and any other type (list, complex, raw).
#'
#' @param x A single variable (vector / data-frame column).
#' @param var_name The variable's name, used to build messages.
#'
#' @return A list with elements \code{summarisable} (logical), \code{num}
#'   (numeric vector ready to summarize, or NULL), \code{note} (an
#'   informational message to emit even though the variable is summarized,
#'   or NULL), and \code{refusal} (the message explaining why the variable
#'   cannot be summarized, or NULL).
#'
#' @keywords internal
.jst_classify_desc_var <- function(x, var_name) {
  no  <- function(msg) list(summarisable = FALSE, num = NULL, note = NULL, refusal = msg)
  yes <- function(num, note = NULL) list(summarisable = TRUE, num = num, note = note, refusal = NULL)

  # Type rules live in the shared detector so jdesc and the analysis type
  # gate cannot drift; this wrapper only maps the kind to jdesc's answer and
  # owns jdesc's refusal wording / numbers-as-text note.
  k <- .jst_var_kind(x)

  switch(k$kind,
    # Numeric-ish kinds: summarize on the coerced numeric.
    numeric        = ,
    labelled       = ,
    logical        = ,
    numeric_factor = yes(k$num),

    # Numbers stored as text: summarize, but flag it.
    numeric_text   = yes(k$num, note = paste0("'", var_name, "' is stored as text but ",
                                  "contains numeric values; summarizing it ",
                                  "numerically.")),

    # Date/time types: not supported here (a dedicated function handles these).
    datetime       = no(paste0("'", var_name, "' is a date/time variable; jdesc() ",
                               "doesn't summarize dates or times. Skipping it.")),

    # Text factor / text character: refuse and redirect to jfreq().
    text_factor    = no(paste0("'", var_name, "' is a factor with text categories and ",
                               "can't be summarized numerically - use jfreq() for ",
                               "categorical variables. Skipping it.")),
    text_character = no(paste0("'", var_name, "' is a character (text) variable and ",
                               "can't be summarized numerically - use jfreq() for ",
                               "categorical variables. Skipping it.")),

    # complex / raw / list / other: refuse with a generic message. Keyed off
    # typeof(x) (not k$kind) so e.g. a closure column still reports "closure".
    no(paste0("'", var_name, "' is a ", typeof(x), " and can't be ",
              "summarized numerically. Skipping it."))
  )
}

#' Internal helper: class-safe numeric coercion for haven-input columns
#'
#' Equivalent to \code{as.numeric(x)} for every input type (numeric, factor,
#' Date/POSIXct/difftime, character, and haven_labelled all give the same
#' result, since \code{unclass()} strips only the class attribute), but
#' bypasses vctrs method dispatch. A bare \code{as.numeric()} on a
#' \code{haven_labelled} vector can abort with "Can't convert
#' <haven_labelled> to <double>" in a fresh session where \code{readxl} was
#' attached before haven registered its \code{vec_cast} method (and always
#' aborts on a character-backed haven_labelled). Stripping the class first
#' sidesteps the dispatch entirely. Standardised package-wide at the
#' haven-input coercion sites in jdesc, jfreq, jscreen, jt, jaov, jcrosstab,
#' jcorr, jlm, jlogistic, jalpha, jdummy, and jrecode. (Session 50)
#'
#' @param x A variable / data-frame column.
#' @return A numeric vector.
#' @keywords internal
.jst_as_numeric <- function(x) as.numeric(unclass(x))

#' Internal helper: classify a variable's analysis-relevant type "kind"
#'
#' Single source of truth for the variable-type distinctions the analysis
#' functions and the type gate care about. Returns the kind plus, for the
#' numeric-ish kinds, the coerced numeric vector. Kinds: "numeric",
#' "labelled", "logical", "numeric_factor", "numeric_text" (numbers stored
#' as text), "text_factor", "text_character", "datetime"
#' (Date/POSIXct/POSIXlt/difftime), "complex", "raw", "list", "other".
#' (\code{.jst_classify_desc_var()} delegates to this detector for jdesc, so
#' the variable-type rules live here only and the two cannot drift.)
#'
#' @param x A variable / data-frame column.
#' @return A list with \code{kind} (character) and \code{num} (numeric
#'   vector for numeric-ish kinds, otherwise NULL).
#' @keywords internal
.jst_var_kind <- function(x) {
  if (inherits(x, c("Date", "POSIXct", "POSIXlt", "difftime")))
    return(list(kind = "datetime", num = NULL))
  if (is.complex(x)) return(list(kind = "complex", num = NULL))
  if (is.raw(x))     return(list(kind = "raw",     num = NULL))
  if (haven::is.labelled(x)) {
    # Character-backed haven_labelled (e.g. country codes "US"/"UK" carrying
    # value labels) has no numeric codes to summarize. Route it to the text-
    # categorical branch so jdesc refuses cleanly ("use jfreq()") instead of
    # coercing the character backing to all-NA and emitting "NAs introduced
    # by coercion". Numeric-backed labelled falls through to the numeric-ish
    # "labelled" kind unchanged. (Session 51)
    if (typeof(x) == "character") return(list(kind = "text_character", num = NULL))
    return(list(kind = "labelled", num = .jst_as_numeric(x)))
  }
  if (is.logical(x)) return(list(kind = "logical", num = as.numeric(x)))
  if (is.factor(x)) {
    num <- suppressWarnings(as.numeric(as.character(x)))
    if (all(is.na(num[!is.na(x)]))) return(list(kind = "text_factor", num = NULL))
    return(list(kind = "numeric_factor", num = num))
  }
  if (is.character(x)) {
    num <- suppressWarnings(as.numeric(x))
    if (all(is.na(num[!is.na(x)]))) return(list(kind = "text_character", num = NULL))
    return(list(kind = "numeric_text", num = num))
  }
  if (is.list(x))    return(list(kind = "list",    num = NULL))  # POSIXlt handled above
  if (is.numeric(x)) return(list(kind = "numeric", num = as.numeric(x)))
  list(kind = "other", num = NULL)
}

#' Internal helper: build the analysis type-gate error message
#'
#' @param var_name The offending variable's name.
#' @param kind The kind returned by \code{.jst_var_kind()}.
#' @param fn_label A short noun phrase for the function (e.g. "a t-test").
#' @return Character scalar suitable for \code{stop(call. = FALSE)}.
#' @keywords internal
.jst_analysis_type_error_msg <- function(var_name, kind, fn_label) {
  if (kind == "datetime") {
    return(paste0("'", var_name, "' is a date/time variable and cannot be used in ",
      fn_label, ". Convert it to an elapsed duration first, e.g. ",
      "as.numeric(difftime(end, start, units = \"days\"))."))
  }
  if (kind %in% c("complex", "raw", "list", "other")) {
    return(paste0("'", var_name, "' is of type ", kind,
      " and cannot be used in ", fn_label, "."))
  }
  if (kind == "numeric_text") {
    return(paste0("'", var_name, "' is numbers stored as text. Convert it with ",
      "as.numeric() before using it in ", fn_label, "."))
  }
  paste0("'", var_name, "' is a categorical (text) variable and cannot be used in ",
    fn_label, ", which needs a numeric variable.")
}

#' Internal helper: detect the user-facing function on the call stack
#'
#' Walks the call stack from the outermost frame inward and returns the name
#' of the first exported jstats function (j-prefixed) found, reducing an S3
#' method name to its generic (e.g. jplot.jst_lm -> jplot). Used so that
#' shared validation helpers can name the function the user actually called,
#' even though errors are signaled with call. = FALSE. Returns NULL when no
#' jstats frame is on the stack.
#' @return A function name string, or NULL.
#' @keywords internal
.jst_caller_fn <- function() {
  calls <- sys.calls()
  if (is.null(calls)) return(NULL)
  for (cl in calls) {
    if (!is.call(cl)) next
    head <- cl[[1L]]
    nm <- NULL
    if (is.symbol(head)) {
      nm <- as.character(head)
    } else if (is.call(head) && length(head) == 3L &&
               as.character(head[[1L]]) %in% c("::", ":::")) {
      nm <- as.character(head[[3L]])
    }
    if (!is.null(nm) && grepl("^j[a-z]", nm)) {
      return(sub("^(j[a-z]+)\\..*$", "\\1", nm))
    }
  }
  NULL
}

#' Internal helper: signal an error in the package house voice
#'
#' Concatenates its ... arguments into a message and raises a stop() prefixed
#' with the user-facing function name as "<fn>(): ". The function name is taken
#' from fn when supplied, otherwise auto-detected from the call stack via
#' .jst_caller_fn(); if detection fails the message is emitted without a prefix
#' rather than erroring. Always signals with call. = FALSE.
#' @param ... Message parts, concatenated with paste0().
#' @param fn Optional function name (without parentheses); auto-detected when NULL.
#' @return Never returns; always signals an error.
#' @keywords internal
.jst_stop <- function(..., fn = NULL) {
  if (is.null(fn)) fn <- tryCatch(.jst_caller_fn(), error = function(e) NULL)
  prefix <- if (is.null(fn) || !nzchar(fn)) "" else paste0(fn, "(): ")
  stop(paste0(prefix, ...), call. = FALSE)
}


#' Internal helper: raise a standardized argument-validation error
#'
#' Builds and signals a stop() in the package house voice:
#'   <fn>(): <arg> must be <requirement>
#' The fn prefix names the user-facing function so the message identifies its
#' origin even though the package signals errors with call. = FALSE (which
#' suppresses R's automatic call context). Supply either a freeform
#' requirement string, or a character vector of allowed values via choices to
#' get a standardized "one of:" enumeration with consistent double-quoting.
#'
#' @param fn The user-facing function name, without parentheses (e.g. "jcorr").
#' @param arg The offending argument's name (e.g. "method").
#' @param requirement A string completing "<arg> must be ..."; include the
#'   trailing period. Ignored when choices is supplied.
#' @param choices Optional character vector of allowed values; renders as a
#'   double-quoted comma-separated list introduced by "one of:".
#' @return Never returns; always signals an error.
#' @keywords internal
.jst_stop_arg <- function(fn = NULL, arg, requirement = NULL, choices = NULL) {
  if (!is.null(choices)) {
    # Choice-error house form (Rule A): backtick the name, drop "one of:",
    # natural list with Oxford comma on 3+ choices and none on exactly 2.
    quoted <- paste0("\"", choices, "\"")
    n <- length(quoted)
    if (n >= 3L) {
      lst <- paste0(paste(quoted[-n], collapse = ", "), ", or ", quoted[n])
    } else if (n == 2L) {
      lst <- paste0(quoted[1L], " or ", quoted[2L])
    } else {
      lst <- quoted
    }
    requirement <- paste0(lst, ".")
    arg <- paste0("`", arg, "`")
  }
  .jst_stop(arg, " must be ", requirement, fn = fn)
}


#' Internal helper: emit a default-silent advisory note
#'
#' Advisory notes are pure FYI: the function did exactly what was asked, and
#' the note just reports a benign detail (a no-op recode, a silent text-to-
#' numeric coercion). They are shown only at \code{joutput("full")} and stay
#' hidden at "standard" and "minimal". Consequential notes -- an overwrite, an
#' override taking precedence, a skipped variable, a diagnostic that could not
#' be computed -- use a plain \code{message()} instead and are always visible.
#'
#' This is the tier-gating primitive for the note layer; a broader joutput
#' note-gating framework would build on it.
#'
#' @param ... Parts of the message, passed through to \code{message()}.
#' @return Invisibly NULL.
#' @keywords internal
.jst_advisory_note <- function(...) {
  if (identical(getOption(".jst_output_level", "standard"), "full")) {
    message(...)
  }
  invisible(NULL)
}


#' Internal: detect a variable appearing on both sides of an analysis formula
#'
#' Checks a two-sided analysis formula for a variable named on both the
#' left- and right-hand sides (e.g. \code{MathScore ~ MathScore} or
#' \code{MathScore ~ MathScore + Age}). Such formulas cannot be caught
#' downstream via \code{all.vars(formula)}, which deduplicates names: the
#' formula functions then either index a second variable that is not there
#' (jt / jaov / jcrosstab fall through to raw base R errors) or hand the
#' formula to \code{lm()} / \code{glm()}, which silently drops the response
#' from the right-hand side and fits a different model than the user wrote
#' (jlm / jlogistic). Callers stop with a clear, named message when this
#' helper returns a name.
#'
#' @param formula The user's analysis formula.
#' @return The first duplicated variable name (character scalar), or
#'   \code{NULL} when the formula is one-sided, not a formula, or has no
#'   variable in both roles.
#' @keywords internal
.jst_formula_dup_var <- function(formula) {
  if (!inherits(formula, "formula") || length(formula) != 3L) return(NULL)
  dup <- intersect(all.vars(formula[[2]]), all.vars(formula[[3]]))
  if (length(dup) == 0) return(NULL)
  dup[1]
}

#' Internal: refuse a transformed term in a model formula, in house voice
#'
#' Detects a function call among the formula's variables -- log(x), I(x^2),
#' sqrt(x), and the like, on either side -- and stops with a clear message
#' (AUDIT-005). Used where transformed terms stay unsupported: jcrosstab,
#' whose row and column variables must be plain names (a numeric transform
#' of a categorical variable has no cross-tabulation meaning, and the
#' pre-check era silently tabulated the raw column instead). The analysis
#' functions that DO support transformed terms (jt, jaov, jlm, jlogistic)
#' route through .jst_resolve_formula_transforms instead, which computes
#' the term and rewrites the formula rather than refusing (AUDIT-021).
#' Interaction terms (x * z, x:z) are unaffected:
#' terms() lists their component variables as plain names, not calls.
#' When the offending call is a single function applied to one bare
#' variable, the message includes a runnable make-the-variable example
#' built from the user's own term and data-frame name.
#'
#' @param formula The user's analysis formula.
#' @param data_name Character; the data frame's name (for the example line).
#' @return Invisibly NULL; stops when a transformed term is found. A
#'   formula that terms() cannot process (e.g. a bare dot) passes through
#'   untouched for downstream handling.
#' @keywords internal
.jst_check_formula_transforms <- function(formula, data_name) {
  vars <- tryCatch(attr(stats::terms(formula), "variables"),
                   error = function(e) NULL)
  if (is.null(vars)) return(invisible(NULL))
  for (i in seq_along(vars)[-1L]) {
    v <- vars[[i]]
    if (!is.call(v)) next
    term_txt <- paste(deparse(v), collapse = "")
    # Runnable example only for the simple shape: one function, one bare
    # variable (log(x), sqrt(x)). Anything else (I(x^2), poly(x, 2),
    # log(x + 1)) keeps the two-sentence form without an example.
    if (length(v) == 2L && is.symbol(v[[2L]]) && is.symbol(v[[1L]])) {
      fn_txt   <- as.character(v[[1L]])
      var_txt  <- as.character(v[[2L]])
      new_col  <- paste0(var_txt, "_", fn_txt)
      .jst_stop("The formula applies a function to a variable: ", term_txt,
                ".\nCreate the transformed variable as a new column first, ",
                "then use that column in the formula:\n  ",
                data_name, "$", new_col, " <- ", fn_txt, "(",
                data_name, "$", var_txt, ")")
    }
    .jst_stop("The formula applies a function to a variable: ", term_txt,
              ".\nCreate the transformed variable as a new column first, ",
              "then use that column in the formula.")
  }
  invisible(NULL)
}

#' Internal helper: strip backticks from design-matrix term names
#'
#' A resolved transformed term is a column whose name is non-syntactic
#' ("log(x)"), which the rewritten formula references as a backticked name.
#' Design-matrix machinery (lm/glm coefficient rownames, model.matrix and
#' VIF column names, a standardized refit's coefficient names) deparses
#' that symbol WITH its backticks. Stripping them at each capture point
#' keeps every downstream key -- display rownames, the japa-ready term
#' keys, the standardized-beta and Gelman-beta name matches, the VIF
#' Variable column -- in the same clean form as the data frame's own
#' column names. A no-op for ordinary syntactic names. (A factor level
#' containing a literal backtick would also lose it in these display
#' keys; accepted as vanishingly rare.)
#'
#' @param x Character vector of term names.
#' @return x with all backtick characters removed.
#' @keywords internal
.jst_unbacktick <- function(x) gsub("`", "", x, fixed = TRUE)

#' Internal helper: canonical single-line text of a formula term
#'
#' Deparses a language object into one line and collapses any whitespace
#' run to a single space. deparse() breaks a long call across indented
#' continuation lines, and pasting those pieces back with collapse = ""
#' kept the indent as embedded padding inside the term text (AUDIT-031) --
#' padding that then appeared verbatim in the computed column's name and
#' every display of it. The transform resolver builds a term's text in two
#' places -- once to name the computed column, once inside the formula
#' substitution pass to find that column again -- and the two MUST produce
#' identical text or the substitution silently stops matching long terms;
#' both route through this one helper so they cannot drift.
#'
#' @param e A language object (a call or symbol from a formula).
#' @return Single string: the deparsed term with normalized spacing.
#' @keywords internal
.jst_term_text <- function(e) {
  gsub("[[:space:]]+", " ",
       paste(deparse(e, width.cutoff = 500L), collapse = " "))
}

#' Internal helper: resolve transformed formula terms into computed columns
#'
#' Walks the formula's variables for function-call terms -- log(x), I(x^2),
#' sqrt(x), and the like, on either side -- and, for each supported term,
#' computes the transformed values once on the analysis copy and stores them
#' as a column whose name is the term's own text (a column literally named
#' "log(x)"), rewriting the formula to reference that column as a plain
#' name. Everything downstream -- the descriptives, the Case Processing
#' Summary, the model fit, the standardized-beta refit -- then sees an
#' ordinary variable whose printed name is the expression the user typed,
#' so the test statistic and the descriptive output describe the same
#' values (AUDIT-021) and the model-frame refit that motivated the former
#' front-door refusal (AUDIT-005) finds the column by name instead of
#' re-evaluating the term. Interaction terms (x * z, x:z) are untouched:
#' terms() lists their component variables as plain names, not calls. A
#' transformed term nested inside an interaction (log(x):z) is listed as
#' its own variable by terms(), so it is computed and substituted inside
#' the interaction. Supersedes the AUDIT-005 refusal in jlm and jlogistic;
#' .jst_check_formula_transforms remains in use where transformed terms
#' stay unsupported (jcrosstab).
#'
#' A term is supported when it evaluates against the analysis copy to a
#' single numeric or logical column with one value per case. Terms that
#' produce several columns (poly(x, 2), spline bases), a categorical
#' result (cut(x, 3)), a single summary value (mean(x)), or an evaluation
#' error are refused in house voice with a make-the-variable message.
#' A term is also refused, before evaluation, when its argument is a
#' variable the package classifies as Categorical -- most importantly a
#' value-labelled categorical, whose numeric codes would otherwise be
#' transformed silently into a meaningless predictor (log() of a 1/2/3/4
#' category code fits with no error). The check uses the same classification
#' stack the analysis path uses, so a jnumeric/jcount registration moves the
#' variable to Numeric and lifts the refusal -- the identical escape hatch,
#' and the exact path the message names -- while factor/character arguments
#' are caught here too (a typed message in place of base R's raw non-numeric
#' error). A term that evaluates but yields non-finite values for some
#' cases -- log() of a zero (-Inf) or of a negative (NaN) -- is NOT
#' refused: those cells are set to NA, counted per term, and reported in a
#' consequential note, with base R's raw "NaNs produced" warning muffled in
#' favor of that note; the counts travel out as introduced_na so the Case
#' Processing Summary can attribute the exclusions (AUDIT-024, AUDIT-025).
#' Evaluation happens on the pipeline-masked analysis copy, so declared
#' SPSS-style missing values are already NA before any arithmetic touches
#' them; haven-labelled inputs are unclassed to plain numeric for the
#' computation, the same coercion the analysis functions apply themselves.
#' Objects that are not columns (a threshold constant in I(x > cutoff))
#' resolve in the formula's own environment, matching model.frame().
#'
#' @param formula The user's analysis formula.
#' @param data The analysis data frame (the post-pipeline copy).
#' @param data_name Character; the data frame's name (for messages).
#' @return A list: formula (rewritten when any term was computed, otherwise
#'   the input), data (with any computed columns appended), computed
#'   (character vector of the computed columns' names, possibly empty), and
#'   introduced_na (named integer vector keyed by term text: per computed
#'   term, the count of non-finite results converted to NA; empty when no
#'   term introduced any). A formula that terms() cannot process (e.g. a
#'   bare dot) passes through untouched for downstream handling.
#' @keywords internal
.jst_resolve_formula_transforms <- function(formula, data, data_name) {
  out  <- list(formula = formula, data = data, computed = character(0),
               introduced_na = integer(0))
  vars <- tryCatch(attr(stats::terms(formula), "variables"),
                   error = function(e) NULL)
  if (is.null(vars)) return(out)

  term_list <- as.list(vars)[-1L]
  call_terms <- term_list[vapply(term_list, is.call, logical(1))]
  if (length(call_terms) == 0L) return(out)

  # Evaluation environment: the analysis copy, with haven-labelled columns
  # unclassed to plain numeric (the coercion the analysis functions apply
  # themselves). Declared SPSS-style missing values are already NA here --
  # the pipeline's masking pass runs before this helper. Functions and any
  # non-column objects resolve in the formula's own environment, matching
  # base R's model.frame() lookup.
  eval_data <- data
  for (v in names(eval_data)) {
    if (haven::is.labelled(eval_data[[v]])) {
      eval_data[[v]] <- .jst_as_numeric(eval_data[[v]])
    }
  }
  enclos <- environment(formula)
  if (is.null(enclos)) enclos <- parent.frame()

  # Muffle base R's raw "NaNs produced" warning during term evaluation:
  # the non-finite guard below converts those NaNs to NA and reports them
  # in an attributed note, so the bare base warning would only duplicate
  # it without naming the term (AUDIT-024). Matched against the current
  # locale's translation as well as the English string; any other warning
  # passes through untouched.
  nan_msgs <- unique(c("NaNs produced",
                       gettext("NaNs produced", domain = "R")))
  muffle_nan <- function(w) {
    if (conditionMessage(w) %in% nan_msgs) invokeRestart("muffleWarning")
  }

  computed      <- character(0)
  introduced_na <- integer(0)
  for (v in call_terms) {
    term_txt <- .jst_term_text(v)
    if (term_txt %in% computed) next

    if (term_txt %in% names(data)) {
      .jst_stop("The formula term ", term_txt, " matches the name of an ",
                "existing column in ", data_name, ".\n",
                "Rename that column, or create the transformed variable ",
                "under a new name and use that name in the formula.")
    }

    # Categorical-argument guard: a numeric transform applied to a variable
    # the package classifies as Categorical is refused before evaluation.
    # This closes the silent path where a haven-labelled categorical unclasses
    # to its integer codes and log()/I(x^2) computes a meaningless number from
    # them (a value-labelled var whose codes are 1,2,3,4 would otherwise fit
    # with no error). The check runs on the raw column via the same
    # classification stack the analysis path uses, so a jnumeric/jcount
    # registration moves the variable to the Numeric class and lifts the
    # refusal -- identical to the escape hatch for the bare variable, and the
    # exact path the message points to. (A per-call numeric= cannot serve here:
    # the analysis functions require numeric= to name a bare independent
    # variable, which a transformed term is not.) Non-column symbols inside a
    # term (a threshold constant in I(x > cutoff)) are skipped and resolve in
    # the formula's environment, matching model.frame(). Factor / character
    # categoricals are caught here too, upgrading base R's raw "non-numeric
    # argument" to a typed message; date-time / numbers-as-text fall through to
    # the evaluation-error branch below.
    for (vn in all.vars(v)) {
      if (!vn %in% names(data)) next
      if (identical(.jst_jstats_class(data[[vn]], vn, data_name)$class,
                    "Categorical")) {
        .jst_stop(vn, " is a categorical variable, so the formula term ",
                  term_txt, " cannot be computed.\n",
                  "If ", vn, " should be treated as numeric, register it ",
                  "first:\n",
                  "  jnumeric(", data_name, ", ", vn, ")")
      }
    }

    res <- tryCatch(withCallingHandlers(eval(v, eval_data, enclos),
                                        warning = muffle_nan),
                    error = function(e) e)
    if (inherits(res, "error")) {
      .jst_stop("The formula term ", term_txt, " could not be computed (",
                conditionMessage(res), ").\n",
                "Create the transformed variable as a new column first, ",
                "then use that column in the formula.")
    }

    n_col <- NCOL(res)
    if ((is.matrix(res) || is.data.frame(res)) && n_col > 1L) {
      .jst_stop("The formula term ", term_txt, " produces ", n_col,
                " columns, not a single variable.\n",
                "Create each column as its own variable first, then use ",
                "those variables in the formula.")
    }
    if (is.matrix(res) || is.data.frame(res)) res <- res[, 1L]

    if (is.factor(res) || is.character(res)) {
      .jst_stop("The formula term ", term_txt, " produces a categorical ",
                "variable, not a numeric one.\n",
                "Create it as a new column first, then use that column ",
                "in the formula.")
    }
    if (!is.numeric(res) && !is.logical(res)) {
      .jst_stop("The formula term ", term_txt, " does not produce a ",
                "numeric variable.\n",
                "Create the transformed variable as a new column first, ",
                "then use that column in the formula.")
    }

    res <- as.vector(res)
    if (length(res) == 1L && nrow(data) != 1L) {
      .jst_stop("The formula term ", term_txt, " produces a single value, ",
                "not a variable with one value per case.\n",
                "Create the transformed variable as a new column first, ",
                "then use that column in the formula.")
    }
    if (length(res) != nrow(data)) {
      .jst_stop("The formula term ", term_txt, " produces ", length(res),
                " values for ", nrow(data), " cases.\n",
                "Create the transformed variable as a new column first, ",
                "then use that column in the formula.")
    }

    # Non-finite guard (AUDIT-024): log(0) evaluates to -Inf, which base R
    # does NOT treat as missing -- it sails into the model and crashes with
    # a raw "NA/NaN/Inf in 'x'" error, or prints -Inf group statistics.
    # log() of a negative evaluates to NaN, which listwise-drops silently
    # behind base R's unattributed "NaNs produced" warning. Convert both
    # to NA -- the commercial-software behavior (SPSS's COMPUTE sets the
    # case to system-missing and logs "argument out of range") -- count
    # the conversions, and report them in one consequential note per term
    # (Rule R: the note names the data condition; the muffled base warning
    # above is replaced by it). An input already NA evaluates to NA, which
    # is neither infinite nor NaN, so the count is exactly the cases that
    # were present going in and non-finite coming out; pre-existing
    # missingness stays a listwise matter. The per-term counts travel out
    # as introduced_na so the Case Processing Summary can attribute the
    # exclusions (AUDIT-025).
    non_finite <- is.infinite(res) | is.nan(res)
    n_nf <- sum(non_finite)
    if (n_nf > 0L) {
      res[non_finite] <- NA
      introduced_na[[term_txt]] <- n_nf
      message("Note: ", term_txt, ": ", n_nf,
              if (n_nf == 1L) " value became infinite or undefined and was"
              else            " values became infinite or undefined and were",
              " set to missing.")
    }

    data[[term_txt]] <- res
    computed <- c(computed, term_txt)
  }

  # Substitute each computed call in the formula with the plain (backticked)
  # name of its computed column, descending into interactions and other
  # containing calls. Editing the formula object in place preserves its
  # class and environment. The empty-symbol guard skips a missing argument
  # (as in x[, 1]) that indexing would otherwise choke on.
  sub_term <- function(e) {
    if (is.call(e)) {
      # MUST match the column-naming pass exactly; both route through
      # .jst_term_text so the two constructions cannot drift (AUDIT-031).
      txt <- .jst_term_text(e)
      if (txt %in% computed) return(as.name(txt))
      for (k in seq_along(e)) {
        if (k == 1L) next
        if (identical(as.list(e)[[k]], substitute())) next
        e[[k]] <- sub_term(e[[k]])
      }
    }
    e
  }
  new_formula <- formula
  for (k in 2:length(new_formula)) {
    new_formula[[k]] <- sub_term(new_formula[[k]])
  }

  out$formula       <- new_formula
  out$data          <- data
  out$computed      <- computed
  out$introduced_na <- introduced_na
  out
}

#' Internal helper: gate a variable for use in an analysis function
#'
#' Stops with a clean, variable-naming error when the variable's type cannot
#' be used in the calling analysis. Date/time, complex, list, and raw are
#' refused for every role; text (factor or character) and numbers-stored-as-
#' text are additionally refused when a numeric variable is required.
#' Accepted variables pass through; the returned kind carries the coerced
#' numeric for callers that want it.
#'
#' @param x The variable / column.
#' @param var_name The variable's name (for the message).
#' @param requires_numeric TRUE for roles that need a numeric variable
#'   (continuous DV, correlation variable, scale item); FALSE for roles where
#'   a categorical variable is valid (grouping variable, regression predictor,
#'   logistic DV).
#' @param fn_label A short noun phrase for the function (e.g. "a t-test").
#' @return Invisibly, the \code{.jst_var_kind()} result.
#' @keywords internal
.jst_check_analysis_var <- function(x, var_name, requires_numeric = TRUE,
                                    fn_label = "this analysis") {
  k <- .jst_var_kind(x)
  always_refuse <- c("datetime", "complex", "raw", "list", "other")
  num_refuse    <- c("text_factor", "text_character", "numeric_text")
  if (k$kind %in% always_refuse ||
      (requires_numeric && k$kind %in% num_refuse)) {
    stop(.jst_analysis_type_error_msg(var_name, k$kind, fn_label), call. = FALSE)
  }
  invisible(k)
}


#' Internal helper: dichotomy classifier
#'
#' Returns information about whether a variable is a two-value (dichotomous)
#' variable, and if so, what coding it uses. Designed to be the single
#' source of truth across the package for "is this a dichotomy?" questions
#' -- used by jlm DV checks, by jlogistic DV validation, and (in the
#' future) by jcorr inclusion decisions for point-biserial correlations.
#'
#' Detects dichotomies in any of these forms:
#' \itemize{
#'   \item Numeric (or haven_labelled numeric) with exactly two unique
#'         non-NA values: classified by coding pattern as "0/1", "1/2",
#'         or "other" (e.g. 5/10, -1/1).
#'   \item Factor with exactly two levels: classified as "factor".
#'   \item Character with exactly two unique non-NA values: classified
#'         as "character".
#'   \item Logical with both TRUE and FALSE present: classified as
#'         "logical".
#' }
#'
#' Returns a list with two named elements so callers can both detect
#' dichotomies and react to specific codings without redoing the work:
#' \itemize{
#'   \item \code{is_dichotomy}: TRUE if the variable has exactly two
#'         non-NA distinct values, FALSE otherwise.
#'   \item \code{coding}: One of "0/1", "1/2", "other", "factor",
#'         "character", "logical" when \code{is_dichotomy} is TRUE;
#'         \code{NA_character_} otherwise.
#' }
#'
#' Why a list rather than two helpers: most callers want both pieces of
#' information at the same time (e.g. jlogistic asks both "is this a
#' dichotomy?" and "what coding?" to decide on its error message). One
#' helper that returns both avoids duplicating detection work and
#' eliminates the risk of two helpers giving inconsistent answers if
#' they're modified independently later.
#'
#' This helper makes no judgement about whether dichotomous treatment
#' is appropriate -- that's up to the caller. jlogistic uses it to
#' validate the DV (and stops if not coded 0/1); the new jlm DV check
#' uses it to warn that a different model might have been intended;
#' future jcorr could use it to decide which correlation method to use.
#'
#' @param x A variable (vector).
#' @return A list with elements \code{is_dichotomy} (logical) and
#'   \code{coding} (character or NA).
#' @keywords internal
.jst_is_dichotomy <- function(x) {

  na_result <- list(is_dichotomy = FALSE, coding = NA_character_)

  # -- Logical: TRUE/FALSE -------------------------------------------------
  if (is.logical(x)) {
    vals <- unique(x[!is.na(x)])
    if (length(vals) == 2) return(list(is_dichotomy = TRUE, coding = "logical"))
    return(na_result)
  }

  # -- Factor: two levels --------------------------------------------------
  if (is.factor(x)) {
    if (nlevels(x) == 2) return(list(is_dichotomy = TRUE, coding = "factor"))
    return(na_result)
  }

  # -- Character: two unique non-NA values ---------------------------------
  if (is.character(x)) {
    vals <- unique(x[!is.na(x)])
    if (length(vals) == 2) return(list(is_dichotomy = TRUE, coding = "character"))
    return(na_result)
  }

  # -- Numeric or haven_labelled numeric: classify by coding pattern -------
  if (is.numeric(x) || haven::is.labelled(x)) {
    vals <- suppressWarnings(as.numeric(x))
    vals <- vals[!is.na(vals)]
    unique_vals <- sort(unique(vals))
    if (length(unique_vals) != 2) return(na_result)
    coding <- if (identical(unique_vals, c(0, 1))) {
                "0/1"
              } else if (identical(unique_vals, c(1, 2))) {
                "1/2"
              } else {
                "other"
              }
    return(list(is_dichotomy = TRUE, coding = coding))
  }

  na_result
}


#' Internal helper: recognized affirmative/negative token matcher
#'
#' Given the two distinct category strings of a text dichotomy, decides
#' whether they form a recognized affirmative/negative pair and, if so,
#' which is the affirmative (the event modeled as 1) and which is the
#' negative (the reference, 0). Matching is case-insensitive and ignores
#' surrounding whitespace. The recognized vocabulary is:
#' \itemize{
#'   \item affirmative: yes, y, true, t, present, success
#'   \item negative:    no, n, false, f, absent, failure
#' }
#' A pair is recognized only when exactly one category is affirmative and
#' the other is negative, so two affirmatives (e.g. "yes"/"true") or an
#' unrecognized pair (e.g. "high"/"low") return \code{recognized = FALSE}.
#' The caller supplies the original-cased strings; the returned
#' \code{event} and \code{reference} echo them unchanged for display.
#'
#' Used by jlogistic() to coerce a recognized text/factor response to 0/1
#' with a known, announced direction, rather than letting glm() pick the
#' event by alphabetical level order (which silently models the wrong
#' category for pairs like high/low). See the DV-resolution block in
#' jlogistic().
#'
#' @param cats Character vector of length 2: the two distinct category
#'   strings, original casing preserved.
#' @return A list with elements \code{recognized} (logical),
#'   \code{event} (the affirmative category string, or NA), and
#'   \code{reference} (the negative category string, or NA).
#' @keywords internal
.jst_match_binary_tokens <- function(cats) {

  affirmative <- c("yes", "y", "true", "t", "present", "success")
  negative    <- c("no",  "n", "false", "f", "absent",  "failure")

  norm   <- tolower(trimws(as.character(cats)))
  is_aff <- norm %in% affirmative
  is_neg <- norm %in% negative

  if (sum(is_aff) == 1L && sum(is_neg) == 1L) {
    return(list(recognized = TRUE,
                event       = cats[is_aff][1],
                reference   = cats[is_neg][1]))
  }

  list(recognized = FALSE, event = NA_character_, reference = NA_character_)
}


#' Internal helper: count-variable classifier
#'
#' Returns TRUE when a variable's values fit the structural pattern of a
#' small-range count: non-negative whole numbers in the 0-6 range, with
#' no value labels attached, and not a dichotomy (which has its own
#' helper).
#'
#' Used as a *warning trigger* for analyses that assume a continuous DV
#' with at least 6-7 distinct values for reliable inference. The jlm DV
#' check uses it to warn that linear regression's assumptions (normally
#' distributed residuals, constant variance) are usually violated by
#' small-range counts. A future jpoisson()/jnegbin() workflow would be
#' the appropriate response when count regression is implemented; for
#' now the warning explains the limitation.
#'
#' This helper deliberately uses the same range rules as
#' .jst_is_discrete_integer() (min >= 0, max <= 6, all whole numbers).
#' The only structural difference is the "not haven-labelled" rule:
#' counts in this package are typically plain integers, while labelled
#' small-range integers are usually Likert items or category codes
#' rather than counts. Both helpers can return TRUE for the same
#' variable (e.g., an unlabelled small-range count fires both); the
#' calling function decides how to handle that overlap. For example,
#' the jlm DV check examines counts before discrete-integers so that
#' an unlabelled count gets the count-specific warning rather than the
#' more general categorical-like one.
#'
#' Detection criteria, all required:
#' \itemize{
#'   \item is.numeric and not haven_labelled
#'   \item not a dichotomy (.jst_is_dichotomy() handles the binary case)
#'   \item all values are whole numbers (integer-valued)
#'   \item minimum value >= 0
#'   \item maximum value <= 6
#'   \item at least 2 non-NA values
#' }
#'
#' Registered intent overrides the structural rules ("Rule A"). When the
#' variable has been registered as a count via \code{jcount()}, or a per-call
#' \code{override = "count"} is supplied, this helper returns TRUE regardless
#' of the structural range checks, so a conceptual count outside the 0-6 band
#' (e.g. a 0-30 victimization tally a user has declared a count) still routes
#' to the count branch. Identity (\code{var_name} + \code{data_name}) is
#' required to consult the registration; without it the helper is purely
#' structural, as before.
#'
#' @param x A variable (vector).
#' @param var_name Optional variable name (with \code{data_name}) used to
#'   consult a \code{jcount()} registration.
#' @param data_name Optional data-frame name (with \code{var_name}) used to
#'   consult a \code{jcount()} registration.
#' @param override Optional per-call asserted role; \code{"count"} forces TRUE
#'   (the per-call counterpart of a \code{jcount()} registration).
#' @return TRUE if the variable is an asserted count, or looks like a
#'   small-range count structurally; FALSE otherwise.
#' @keywords internal
.jst_is_count <- function(x, var_name = NULL, data_name = NULL,
                          override = NULL) {

  # -- Rule A: an asserted count (per-call override or jcount registration)
  # wins over the structural range rules, catching conceptual counts that
  # sit outside the structural 0-6 band.
  if (identical(override, "count")) return(TRUE)
  if (!is.null(var_name) && !is.null(data_name)) {
    intent <- .jst_get_intent(data_name, var_name)
    if (!is.null(intent) && identical(intent$kind, "count")) return(TRUE)
  }

  if (haven::is.labelled(x))   return(FALSE)
  if (!is.numeric(x))          return(FALSE)
  if (.jst_is_dichotomy(x)$is_dichotomy) return(FALSE)

  vals <- x[!is.na(x)]
  if (length(vals) < 2)        return(FALSE)
  if (!all(vals == floor(vals))) return(FALSE)
  if (min(vals) < 0)           return(FALSE)
  if (max(vals) > 6)           return(FALSE)

  TRUE
}


#' Internal helper: map an asserted analysis role to class + subclass
#'
#' Shared by the classification resolver's user-intent tiers (per-call
#' override and registered intent) so an asserted role produces the same
#' class/subclass pair however it was asserted. "numeric" and "count" fix the
#' subclass; "categorical" still takes its dichotomy / N-category / identifier
#' subclass from the data structure, since the role assertion fixes the class
#' but not the category count. ("identifier" is a text/factor categorical whose
#' every non-missing value is distinct -- a cosmetic sub-class only; the
#' variable is still Categorical for all analysis purposes.)
#'
#' @param role One of "numeric", "count", "categorical".
#' @param x The variable (used only to derive the categorical subclass).
#' @param var_name Optional variable name; passed through to the Likert battery
#'   detector so it can locate the variable among its siblings.
#' @param data_name Optional data-frame name; passed through to the Likert
#'   battery detector so it can read adjacent columns.
#' @return A list with \code{class} and \code{subclass}, or \code{NULL} if
#'   \code{role} is not recognized.
#' @keywords internal
.jst_class_from_role <- function(role, x, var_name = NULL, data_name = NULL) {
  if (identical(role, "numeric"))
    return(list(class = "Numeric", subclass = ""))
  if (identical(role, "count"))
    return(list(class = "Numeric", subclass = "Count"))
  if (identical(role, "likert"))
    return(list(class = "Categorical", subclass = "Likert"))
  # A user-declared dummy (jdummy). A dichotomy is a special case of a dummy and
  # keeps its own "dichotomy" sub-class (with the existing "*" recode marker and
  # User-declared Source where they apply); a variable with more than two
  # categories declared as a dummy gets the registration-only "<N>-cat dummy"
  # sub-class (e.g. "5-cat dummy"), carrying the category count in short form.
  # Registration asserts dummy intent, so the Likert/identifier auto-detectors
  # are skipped. Display-only -- still Categorical for every analysis purpose;
  # the structural classifier never emits "<N>-cat dummy". (Session 88)
  if (identical(role, "dummy")) {
    if (.jst_is_dichotomy(x)$is_dichotomy)
      return(list(class = "Categorical", subclass = "dichotomy"))
    n_unique <- length(unique(x[!is.na(x)]))
    return(list(class = "Categorical", subclass = paste0(n_unique, "-cat dummy")))
  }
  if (identical(role, "categorical")) {
    if (.jst_is_dichotomy(x)$is_dichotomy)
      return(list(class = "Categorical", subclass = "dichotomy"))
    # Likert: a value-labelled ordered response scale (consecutive run of 3-7
    # labelled codes; every data value a labelled point). A display/reporting
    # refinement only -- still Categorical for every analysis purpose; surfaces
    # in jscreen's Sub-class column. Reached structurally only for variables
    # already routed to Categorical (<= 6 categories), so 3-6 auto-detect; a
    # 7-point scale resolves Numeric structurally and needs jlikert(). The
    # registered/per-call "likert" role above asserts it directly. Detection is
    # the two-stage anchor/battery test; var_name/data_name let the battery
    # branch see sibling columns. (Session 86; redesign Session 87)
    if (.jst_is_likert(x, var_name, data_name))
      return(list(class = "Categorical", subclass = "Likert"))
    n_unique <- length(unique(x[!is.na(x)]))
    # Identifier: a text/factor categorical whose every non-missing value is
    # distinct (e.g. a respondent ID). Cosmetic sub-class only -- the variable
    # stays Categorical for every analysis and screening purpose; only the
    # displayed sub-class changes from "<n>-category" to "identifier". Gated to
    # character/factor backing (an all-distinct numeric resolves to Numeric, so
    # never reaches here) and to 7+ distinct values, so a tiny all-distinct text
    # column is not labeled an identifier. (Session 83)
    n_present <- sum(!is.na(x))
    if ((is.character(x) || is.factor(x)) &&
        n_unique > 6L && n_unique == n_present)
      return(list(class = "Categorical", subclass = "identifier"))
    return(list(class = "Categorical", subclass = paste0(n_unique, "-category")))
  }
  NULL
}


#' Internal helper: flag a registered classification that fights the data
#'
#' Given a variable and the analysis role the user declared for it
#' ("count", "likert", or "dummy"), returns a short plain-language reason when
#' the variable's structure is an implausible fit for that declaration, or ""
#' when the declaration is a reasonable fit (or cannot be assessed). This drives
#' the non-blocking "Unusual declaration" heads-up in jscreen() and the
#' registration-time note in jcount(): the declaration always stands (a user
#' assertion overrides structure by design), but a clear contradiction is
#' surfaced in case it was a slip.
#'
#' The plausibility envelope per role:
#' \itemize{
#'   \item "count" -- non-negative whole numbers with more than two distinct
#'     values. Flagged on a negative value, a non-whole value, or exactly two
#'     distinct values (which reads as a dichotomy).
#'   \item "likert" -- non-negative whole numbers within 0 to 10 and at most 11
#'     distinct points. Flagged when a value falls outside that range, a value
#'     is non-whole, or there are more than 11 distinct values.
#'   \item "dummy" -- at most 11 categories, flagged only on the high end (more
#'     than 11 categories). There is no lower floor: a two-category (dichotomy)
#'     dummy is never flagged.
#' }
#' "numeric" is not a plausibility target -- declaring a variable Numeric is the
#' maximally permissive assertion -- so it returns "".
#'
#' Declared-missing codes are removed before the structure is judged (through
#' the central \code{.jst_missing_info()} reader, so SPSS-style na_values /
#' na_range and Stata-/SAS-style tagged NAs are all handled). A Likert item
#' carrying an out-of-range missing sentinel (e.g. 99 = "Refused") is therefore
#' judged on its real scale points, not flagged for the sentinel. The count and
#' Likert checks read the numeric codes; the dummy category count is taken on
#' the surviving values with their type preserved, so a character/factor
#' identifier is counted by its distinct labels.
#'
#' @param x A variable / data-frame column.
#' @param kind The declared role: one of "count", "likert", "dummy". Any other
#'   value (including "numeric") returns "".
#' @return A character scalar: the reason tail (e.g.
#'   "declared as a count, but negative values are present"), or "" when the
#'   declaration is plausible or cannot be assessed.
#' @keywords internal
.jst_declaration_plausibility <- function(x, kind) {
  if (!kind %in% c("count", "likert", "dummy")) return("")

  # Surviving values: non-NA, with declared-missing codes removed. Type is
  # preserved so the dummy category count sees character/factor levels.
  present <- x[!is.na(x)]
  if (length(present) == 0L) return("")
  mi <- .jst_missing_info(x)
  if (!is.null(mi)) {
    codes_num <- suppressWarnings(as.numeric(present))
    drop <- rep(FALSE, length(present))
    if (!is.null(mi$codes) && nrow(mi$codes) > 0L) {
      na_num <- mi$codes$numeric[!is.na(mi$codes$numeric)]
      if (length(na_num) > 0L)
        drop <- drop | (!is.na(codes_num) & codes_num %in% na_num)
    }
    if (!is.null(mi$na_range) && length(mi$na_range) == 2L) {
      lo <- min(mi$na_range); hi <- max(mi$na_range)
      drop <- drop | (!is.na(codes_num) & codes_num >= lo & codes_num <= hi)
    }
    present <- present[!drop]
  }
  if (length(present) == 0L) return("")

  # Dummy: judge the category count on the surviving values as stored.
  if (identical(kind, "dummy")) {
    n_cat <- length(unique(present))
    if (n_cat > 11L)
      return(paste0("declared as a dummy, but it has ", n_cat, " categories"))
    return("")
  }

  # Count / Likert judge the numeric codes.
  num <- suppressWarnings(as.numeric(present))
  num <- num[!is.na(num)]
  if (length(num) == 0L) return("")

  if (identical(kind, "count")) {
    if (any(num < 0))
      return("declared as a count, but negative values are present")
    if (!all(num == floor(num)))
      return("declared as a count, but it has non-whole values")
    if (length(unique(num)) == 2L)
      return("declared as a count, but it has only two distinct values")
    return("")
  }

  # Likert
  if (any(num < 0 | num > 10))
    return("declared as Likert, but its values fall outside the usual 0 to 10 range")
  if (!all(num == floor(num)))
    return("declared as Likert, but it has non-whole values")
  if (length(unique(num)) > 11L)
    return("declared as Likert, but it has more than 11 distinct values")
  ""
}


#' Internal helper: emit the registration-time declaration-plausibility note
#'
#' For each just-registered variable, checks whether its data is an implausible
#' fit for the declared role (\code{.jst_declaration_plausibility()}) and, if any
#' are, emits a single non-blocking "! Unusual declaration" note on the message
#' channel, alongside the other registration advisories. Shared by jnumeric /
#' jcount / jlikert (through \code{.jst_register_intent()}) and jdummy so the
#' wording matches the jscreen() flag exactly. "numeric" is not a plausibility
#' target, so a jnumeric registration emits nothing. The declaration always
#' stands; this is advisory only.
#'
#' @param data The resolved data frame.
#' @param var_names Character vector of the variables just registered.
#' @param kind The declared role: "count", "likert", or "dummy" ("numeric" is a
#'   no-op).
#' @return invisible(NULL). Called for its message side effect.
#' @keywords internal
.jst_declaration_note <- function(data, var_names, kind) {
  flagged <- character(0)
  for (v in var_names) {
    if (!v %in% names(data)) next
    r <- .jst_declaration_plausibility(data[[v]], kind)
    if (nzchar(r)) flagged <- c(flagged, paste0("  ", v, " ", r))
  }
  if (length(flagged) > 0L) {
    message("! Unusual declaration for this variable's data:\n",
            paste(flagged, collapse = "\n"))
  }
  invisible(NULL)
}


#' Internal helper: jstats analysis-role class for display
#'
#' Single display-layer resolver that reports how jstats treats a variable,
#' for the jscreen() "Variable Types" table. It does NOT define any new
#' classification rules: it composes the existing single-source helpers
#' (\code{.jst_var_kind()}, \code{.jst_is_dichotomy()},
#' \code{.jst_is_discrete_integer()}) so the screening report cannot drift
#' from how analyses and the outlier-skip actually treat a variable. The
#' same resolver decides jscreen's outlier-screening (screened iff
#' \code{class == "Numeric"}), so the Class column and the Outliers column
#' can never disagree.
#'
#' Class (the analysis role): one of "Numeric", "Categorical",
#' "Numbers-as-text", "Date-time", "Unsupported". Storage facts (labelled
#' vs plain, character backing) live in jscreen's separate "Base R Type"
#' column, never here -- a base-R numeric can resolve to Numeric, or to
#' Categorical (dichotomy), or to Categorical (N-category), depending only
#' on the analysis-relevant structure.
#'
#' Sub-class (for Categorical only; "" otherwise): "dichotomy" for a two-
#' value variable, "Likert" for a value-labelled ordered scale (a consecutive
#' run of 3-7 surviving labelled codes plus an anchor-or-battery discriminator;
#' structural detection or a jlikert() assertion), "identifier" for a
#' text/factor variable whose every non-
#' missing value is distinct (7+ values; a respondent ID is the typical case),
#' else "N-category" (e.g. "4-category") from the count of distinct non-missing
#' values. The "Likert" and "identifier" labels are display refinements: such a variable is still
#' Categorical for every analysis and screening purpose. The boundary between Numeric and Categorical
#' is exactly the package's existing rule: a dichotomy (any coding), a
#' factor / logical / character, a haven-labelled variable with <= 6
#' categories, or a whole-number 0-6 numeric is Categorical; everything else
#' numeric-ish (continuous numeric, or labelled with 7+ categories) is
#' Numeric. The Numeric subclass "Count" is registration-only (set via jcount,
#' or the per-call override "count"); the structural classifier never emits it.
#' The Categorical subclass "<N>-cat dummy" (e.g. "5-cat dummy") is likewise
#' registration-only -- set via jdummy() on a variable with more than two
#' categories; the structural classifier never emits it, and a dichotomy
#' declared via jdummy() keeps its "dichotomy" subclass, a dichotomy being a
#' special case of a dummy.
#'
#' Resolution stack (highest wins; first tier that yields a class short-
#' circuits). Storage-determined edge kinds (date-time, numbers-as-text,
#' unsupported) resolve structurally up front and are not role-assertion
#' targets, so the user tiers operate only among Numeric, Categorical, and
#' Count: (1) per-call \code{override} -> source "per-call"; (2) registered
#' intent -- the \code{.jst_registry} notebook (jnumeric/jcount) and the
#' \code{.jst_dummy} registry (jdummy -> categorical) -> source "registered";
#' (3) SPSS measure -- designed but UNPOPULATED in v1, ignored; (4) structural
#' guess -> source "structural". Identity (\code{var_name} + \code{data_name})
#' is required to consult tiers 1-2; when omitted, the resolver returns the
#' structural answer with source "structural", so a bare
#' \code{.jst_jstats_class(x)} behaves as before but now also reports a source.
#'
#' @param x A variable / data-frame column.
#' @param var_name Optional character string naming the variable; required
#'   (with \code{data_name}) to consult registered intent.
#' @param data_name Optional character string naming the data frame; required
#'   (with \code{var_name}) to consult registered intent.
#' @param override Optional per-call asserted role ("numeric", "categorical",
#'   or "count"); highest-priority tier when supplied.
#' @return A list with \code{class} (character), \code{subclass} (character,
#'   "" when none), and \code{source} (one of "per-call", "registered",
#'   "measure", "structural").
#' @keywords internal
.jst_jstats_class <- function(x, var_name = NULL, data_name = NULL,
                              override = NULL) {
  k <- .jst_var_kind(x)

  # Storage-determined edge kinds are resolved structurally up front. They are
  # not role-assertion targets (a date column is converted, not declared), so
  # override / registration never apply to them.
  if (k$kind == "datetime")
    return(list(class = "Date-time",       subclass = "", source = "structural"))
  if (k$kind == "numeric_text")
    return(list(class = "Numbers-as-text", subclass = "", source = "structural"))
  if (k$kind %in% c("complex", "raw", "list", "other"))
    return(list(class = "Unsupported",     subclass = "", source = "structural"))

  # -- Tier 1: per-call override -------------------------------------------
  if (!is.null(override)) {
    res <- .jst_class_from_role(override, x, var_name, data_name)
    if (!is.null(res)) return(c(res, list(source = "per-call")))
  }

  # -- Tier 2: registered intent -------------------------------------------
  # Numeric/count live in the .jst_registry notebook; categorical lives in the
  # existing .jst_dummy registry. Both keyed by frame name + variable.
  if (!is.null(var_name) && !is.null(data_name)) {
    intent <- .jst_get_intent(data_name, var_name)
    if (!is.null(intent) && !is.null(intent$kind)) {
      res <- .jst_class_from_role(intent$kind, x, var_name, data_name)
      if (!is.null(res)) return(c(res, list(source = "registered")))
    }
    dummy_regs <- .jst_get_dummy(data_name)
    if (!is.null(dummy_regs) && length(dummy_regs) > 0) {
      is_registered <- any(vapply(dummy_regs,
                                  function(r) identical(r$var_name, var_name),
                                  logical(1)))
      if (is_registered)
        return(c(.jst_class_from_role("dummy", x, var_name, data_name),
                 list(source = "registered")))
    }
  }

  # -- Tier 3: SPSS measure -- designed but UNPOPULATED in v1 (skipped). ----

  # -- Tier 4: structural guess --------------------------------------------
  # Numeric-ish (numeric / labelled / logical / numeric_factor) or text
  # categorical (text_factor / text_character). Decide Numeric vs Categorical
  # with the same helpers the analysis gate and the outlier-skip use.
  dich   <- .jst_is_dichotomy(x)
  is_cat <- k$kind %in% c("text_factor", "text_character") ||
            is.factor(x) || is.logical(x) ||
            dich$is_dichotomy ||
            .jst_is_discrete_integer(x)

  if (!is_cat) return(list(class = "Numeric", subclass = "", source = "structural"))

  c(.jst_class_from_role("categorical", x, var_name, data_name), list(source = "structural"))
}


#' Internal helper: is a variable's Numeric role user-asserted?
#'
#' TRUE when the classification resolver places the variable in the Numeric
#' class (continuous or the Count subclass) via a NON-structural source -- a
#' per-call override (numeric=/count=) or a registration (jnumeric/jcount).
#' Used by the analysis functions to suppress the structural "seems
#' categorical" hedge: that hedge is only a guess, and a user who has
#' asserted a numeric role has already answered it. A structural (inferred)
#' Numeric, or any Categorical (including a jdummy-asserted one), returns
#' FALSE so the hedge fires as before -- the jdummy/jcorr/jdesc interaction
#' is deliberately left to its own (parked) design.
#'
#' @param x A variable / data-frame column.
#' @param var_name Optional variable name (with \code{data_name}) for
#'   consulting a registration.
#' @param data_name Optional data-frame name (with \code{var_name}) for
#'   consulting a registration.
#' @param override Optional per-call asserted role ("numeric", "count", or
#'   "categorical").
#' @return Logical scalar.
#' @keywords internal
.jst_role_asserted_numeric <- function(x, var_name = NULL, data_name = NULL,
                                       override = NULL) {
  res <- .jst_jstats_class(x, var_name, data_name, override = override)
  !identical(res$source, "structural") && identical(res$class, "Numeric")
}


# -----------------------------------------------------------------------------
# Assumption-check warning generator (the analysis-function audit)
#
# One source of wording for the "this variable looks like the wrong kind for
# this analysis" warnings, so phrasing cannot drift across functions (the same
# idea as the centralized .jst_cps_*_rules tables for CPS rendering).
# .jst_assumption_clauses is the single place the wording lives; call sites pass
# a site key and the variable name. Two warning families share the generator:
#
#   "seems" sites -- triggered by STRUCTURE (the variable only looks
#                    categorical), so the message hedges: "X seems categorical.
#                    <consequence>". Gated by .jst_warns_seems_categorical().
#   "is" sites    -- triggered by an explicit user DECLARATION (a jdummy
#                    registration), so the message speaks definitively: "X is
#                    categorical; <consequence>". Matches the v0.9.41 provenance
#                    rule (drop the hedge when the class was asserted).
# -----------------------------------------------------------------------------

#' Internal data: assumption-check warning clauses, keyed by call site
#'
#' One entry per warning site. \code{verb} is "seems" (a structural hedge) or
#' "is" (asserted, definitive); \code{connector} joins the opener to the
#' consequence (". " starts a new sentence for the hedge sites, "; " keeps one
#' sentence for the definitive sites); \code{clause} is the analysis-specific
#' consequence text. Editing wording here changes it everywhere that site fires.
#'
#' @keywords internal
.jst_assumption_clauses <- list(
  jdesc  = list(verb = "seems", connector = ". ",
                clause = "Descriptive statistics may not be meaningful."),
  jcorr  = list(verb = "seems", connector = ". ",
                clause = "Pearson correlations assume continuous/interval data."),
  jt     = list(verb = "seems", connector = ". ",
                clause = "A t-test expects an interval outcome."),
  jaov   = list(verb = "seems", connector = ". ",
                clause = "ANOVA expects an interval outcome."),
  jsum   = list(verb = "is",    connector = "; ",
                clause = "summing may not be meaningful."),
  javg   = list(verb = "is",    connector = "; ",
                clause = "averaging may not be meaningful."),
  jalpha = list(verb = "is",    connector = "; ",
                clause = "reliability analysis expects numeric items.")
)

#' Internal helper: build an assumption-check warning string
#'
#' Assembles the warning for one call site from the central clause table, so
#' every site shares one consistent phrasing. The result is
#' \code{paste0(var_name, " ", verb, " categorical", connector, clause)}.
#'
#' @param var_name Character. The variable's name (used verbatim in the text).
#' @param site Character. The call-site key into \code{.jst_assumption_clauses}
#'   (e.g. "jcorr", "jsum").
#' @return A single character string ready to pass to \code{warning()}.
#' @keywords internal
.jst_assumption_warning <- function(var_name, site) {
  spec <- .jst_assumption_clauses[[site]]
  if (is.null(spec)) {
    stop("Internal error: unknown assumption-warning site '", site, "'.",
         call. = FALSE)
  }
  paste0(var_name, " ", spec$verb, " categorical", spec$connector, spec$clause)
}

#' Internal helper: should a "seems categorical" hedge fire for this variable?
#'
#' The shared trigger predicate for the structural ("seems") warning sites
#' (jdesc, jcorr, the jt outcome, the jaov outcome). Centralizing the gate
#' keeps the four sites from drifting on the rule. Fires when the variable is
#' structurally categorical-looking AND the user has not asserted a numeric
#' role AND it is not a Likert item. Likert items are exempt because treating
#' them as interval is the accepted convention; the check covers both
#' auto-detection and a jlikert() assertion via the resolved sub-class.
#'
#' @param x A variable (vector / data-frame column).
#' @param var_name Optional character. The variable's name.
#' @param data_name Optional character. The data frame's name.
#' @param override Optional per-call asserted role ("numeric", "count",
#'   "categorical", or NULL), passed through to the classifier for sites that
#'   accept per-call overrides (jdesc, jcorr).
#' @return TRUE if the hedge should fire, FALSE otherwise.
#' @keywords internal
.jst_warns_seems_categorical <- function(x, var_name = NULL, data_name = NULL,
                                         override = NULL) {
  if (!.jst_is_discrete_integer(x, var_name, data_name)) return(FALSE)
  if (.jst_role_asserted_numeric(x, var_name, data_name, override = override)) {
    return(FALSE)
  }
  cls <- .jst_jstats_class(x, var_name, data_name, override = override)
  if (identical(cls$subclass, "Likert")) return(FALSE)
  TRUE
}


#' Internal helper: parse a recoding-map string into a structured rule list
#'
#' Parses a map string of the form \code{"1=1; 2,3=2; 4,5=3; else=copy"}
#' (used by \code{jrecode()}) into a list of mapping rules plus an
#' else-action. Each rule's left-hand side may be a single value or a
#' comma-separated list of values; an explicit \code{else=...} clause
#' sets the fallback action.
#'
#' The right-hand side of each rule may be a numeric value, one of the
#' system-NA aliases (\code{System}, \code{NA}, or \code{SYSMIS}, case-
#' insensitive), or a Stata-style missing-value token (\code{.a} through
#' \code{.z}). Tagged-NA tokens are recorded in the parsed structure
#' but not validated against the active convention here; the caller
#' (\code{jrecode()}) performs the convention check after parsing.
#'
#' Errors with a clear message if the string is malformed.
#'
#' @param map_str Character string giving the recoding map, e.g.
#'   \code{"1=1; 2=0; else=NA"} or \code{"1=1; 2=0; else=.a"}.
#'
#' @return Invisibly, a list with components:
#'   \describe{
#'     \item{mappings}{List of lists; each inner list has \code{old_vals}
#'       (numeric vector), \code{new_val} (single numeric; \code{NA_real_}
#'       for system-NA and tagged-NA rules), and \code{tagged} (NULL for
#'       numeric or system-NA rules; a single lowercase letter character
#'       for tagged-NA rules).}
#'     \item{else_action}{Character: \code{"na"}, \code{"copy"}, or
#'       \code{"tagged"}.}
#'     \item{else_tag}{NULL when \code{else_action} is \code{"na"} or
#'       \code{"copy"}; a single lowercase letter character when
#'       \code{else_action} is \code{"tagged"}.}
#'     \item{else_explicit}{Logical: \code{TRUE} if the user wrote an
#'       explicit \code{else=...} clause, \code{FALSE} if defaulted.}
#'   }
#'
#' @keywords internal
.jst_parse_map <- function(map_str) {

  rules <- trimws(strsplit(map_str, ";")[[1]])
  rules <- rules[nchar(rules) > 0]

  if (length(rules) == 0) {
    stop("The map argument is empty. Provide at least one rule, e.g. map = \"1=1; 2=0\".", call. = FALSE)
  }

  result <- list(mappings = list(), else_action = "na",
                 else_tag = NULL, else_explicit = FALSE)

  # Helper: parse an RHS token. Returns list(new_val = numeric,
  # tagged = NULL | letter) or NULL if the token is not recognized
  # (caller then falls through to the existing numeric-error path).
  parse_rhs_token <- function(rhs_str, rule_str) {
    rhs_lower <- tolower(trimws(rhs_str))

    # System-NA aliases.
    if (rhs_lower %in% c("na", "sysmis", "system")) {
      return(list(new_val = NA_real_, tagged = NULL))
    }

    # Stata-style missing-value token: .a through .z.
    if (grepl("^\\.[a-z]$", rhs_lower)) {
      return(list(new_val = NA_real_,
                  tagged = substr(rhs_lower, 2L, 2L)))
    }

    # Malformed tagged-NA shapes: helpful error.
    if (grepl("^\\.", rhs_lower) || grepl("^na\\(", rhs_lower)) {
      stop(paste0(
        "Invalid new value '", rhs_str, "' in map rule '", rule_str, "'. ",
        "Stata-style missing-value tokens must be '.a' through '.z' ",
        "(a single lowercase letter after the period). The NA(a) ",
        "longhand is not supported in the map argument."
      ), call. = FALSE)
    }

    NULL
  }

  for (rule in rules) {

    if (!grepl("=", rule)) {
      stop(paste0(
        "Invalid rule '", rule, "' in map argument: each rule must contain '=', ",
        "e.g. '1=0' or '2,3=1'."
      ), call. = FALSE)
    }

    eq_pos <- regexpr("=", rule)[1]
    lhs    <- trimws(substr(rule, 1, eq_pos - 1))
    rhs    <- trimws(substr(rule, eq_pos + 1, nchar(rule)))

    # else rule
    if (tolower(lhs) == "else") {
      rhs_lower <- tolower(rhs)
      if (rhs_lower %in% c("na", "sysmis", "system")) {
        result$else_action   <- "na"
        result$else_tag      <- NULL
        result$else_explicit <- TRUE
      } else if (rhs_lower == "copy") {
        result$else_action   <- "copy"
        result$else_tag      <- NULL
        result$else_explicit <- TRUE
      } else if (grepl("^\\.[a-z]$", rhs_lower)) {
        result$else_action   <- "tagged"
        result$else_tag      <- substr(rhs_lower, 2L, 2L)
        result$else_explicit <- TRUE
      } else if (grepl("^\\.", rhs_lower) || grepl("^na\\(", rhs_lower)) {
        stop(paste0(
          "Invalid else action '", rhs, "' in map argument. ",
          "Stata-style missing-value tokens must be '.a' through '.z' ",
          "(a single lowercase letter after the period). The NA(a) ",
          "longhand is not supported in the map argument."
        ), call. = FALSE)
      } else {
        stop(paste0(
          "Invalid else action '", rhs, "' in map argument. Use ",
          "'else=NA', 'else=copy', or a Stata-style missing-value token ",
          "such as 'else=.a' (Stata convention only)."
        ), call. = FALSE)
      }
      next
    }

    # old values (may be comma-separated)
    old_strs <- trimws(strsplit(lhs, ",")[[1]])
    old_vals <- suppressWarnings(as.numeric(old_strs))

    if (any(is.na(old_vals))) {
      stop(paste0(
        "Invalid old value(s) '", lhs, "' in map rule '", rule, "'. ",
        "Old values must be numeric."
      ), call. = FALSE)
    }

    # new value
    rhs_parsed <- parse_rhs_token(rhs, rule)

    if (!is.null(rhs_parsed)) {
      new_val <- rhs_parsed$new_val
      tagged  <- rhs_parsed$tagged
    } else {
      tagged  <- NULL
      new_val <- suppressWarnings(as.numeric(rhs))
      if (is.na(new_val)) {
        # Detect commas used instead of semicolons between rules
        if (grepl(",", rhs) && grepl("=", rhs)) {
          stop(paste0(
            "It looks like commas were used to separate rules in the map string. ",
            "Use semicolons instead, e.g. map = \"1=5; 2=4; 3=3\"."
          ), call. = FALSE)
        }
        stop(paste0(
          "Invalid new value '", rhs, "' in map rule '", rule, "'. ",
          "New values must be numeric, a system-NA alias (NA, System, ",
          "or SYSMIS), or a Stata-style missing-value token (.a through .z)."
        ), call. = FALSE)
      }
    }

    result$mappings[[length(result$mappings) + 1]] <- list(
      old_vals = old_vals,
      new_val  = new_val,
      tagged   = tagged
    )
  }

  if (length(result$mappings) == 0) {
    stop("The map argument contains no valid recode rules (only an else clause was found).", call. = FALSE)
  }

  return(invisible(result))
}


#' Internal helper: convert a character \code{codes} vector to canonical form
#'
#' Converts a character \code{codes} vector (as accepted by
#' \code{jdeclare_udm}) into the canonical numeric / tagged-NA form, so a
#' caller can write \code{codes = c("Refused" = ".a")} or
#' \code{c(".a", ".b")} without \code{haven::tagged_na()}. A token \code{".a"}
#' becomes \code{haven::tagged_na("a")}; a numeric string such as \code{"-99"}
#' becomes \code{-99}. Names (label text, when present) are preserved.
#'
#' @param codes Character vector of codes; each element is a Stata-style
#'   missing-value token (\code{.a} through \code{.z}) or a numeric string.
#'
#' @return A numeric vector (with tagged-NA values for token entries),
#'   carrying the names of \code{codes}.
#'
#' @keywords internal
.jst_parse_code_tokens <- function(codes) {
  # Convert a character `codes` vector into the canonical numeric / tagged-NA
  # form, so callers can write codes = c("Refused" = ".a") or c(".a", ".b")
  # without haven::tagged_na(). ".a" -> tagged_na("a"); "-99" -> -99. Names
  # (labels, when present) are preserved.
  nm  <- names(codes)
  out <- rep(NA_real_, length(codes))
  for (i in seq_along(codes)) {
    tok <- trimws(as.character(codes[[i]]))
    low <- tolower(tok)
    if (grepl("^\\.[a-z]$", low)) {
      out[i] <- haven::tagged_na(substr(low, 2L, 2L))
    } else if (grepl("^\\.", low) || grepl("^na\\(", low)) {
      stop(paste0("Invalid code '", tok, "'. Stata-style missing-value ",
                  "tokens must be '.a' through '.z' (a single lowercase ",
                  "letter after the period)."), call. = FALSE)
    } else {
      v <- suppressWarnings(as.numeric(tok))
      if (is.na(v)) {
        stop(paste0("Invalid code '", tok, "'. Codes must be numbers (for ",
                    "example -99) or Stata-style tokens (.a through .z)."),
             call. = FALSE)
      }
      out[i] <- v
    }
  }
  names(out) <- nm
  out
}

#' Internal helper: parse a label-spec string into a named numeric vector
#'
#' Parses a labels string of the form
#' \code{"1=Young; 2=Middle Aged; 3=Older"} into a named numeric
#' vector formatted for use with \code{haven_labelled} variables (names
#' = label text, values = numeric codes). Splits on the first equals
#' sign in each rule, so label text may itself contain equals signs.
#'
#' The left-hand side of each rule may be a numeric value or a Stata-
#' style missing-value token (\code{.a} through \code{.z}). Tagged-NA
#' entries are stored as \code{haven::tagged_na(<letter>)} values in
#' the returned vector; callers can detect them via
#' \code{haven::na_tag()}.
#'
#' @param labels_str Character string of the form
#'   \code{"value1=label1; value2=label2; ..."}.
#'
#' @return Invisibly, a named numeric vector. Names are label strings;
#'   values are numeric codes, or Stata-style missing values for tagged entries.
#'
#' @keywords internal
.jst_parse_labels <- function(labels_str) {

  rules <- trimws(strsplit(labels_str, ";")[[1]])
  rules <- rules[nchar(rules) > 0]

  if (length(rules) == 0) {
    stop("The labels argument is empty. Provide at least one label, e.g. labels = \"1=Male; 0=Female\".", call. = FALSE)
  }

  result <- c()

  for (rule in rules) {

    if (!grepl("=", rule)) {
      stop(paste0(
        "Invalid label rule '", rule, "': each rule must contain '=', ",
        "e.g. '1=Male'."
      ), call. = FALSE)
    }

    eq_pos    <- regexpr("=", rule)[1]
    val_str   <- trimws(substr(rule, 1, eq_pos - 1))
    label_str <- trimws(substr(rule, eq_pos + 1, nchar(rule)))

    val_lower <- tolower(val_str)

    if (grepl("^\\.[a-z]$", val_lower)) {
      # Stata-style missing-value token: .a through .z.
      val <- haven::tagged_na(substr(val_lower, 2L, 2L))
    } else if (grepl("^\\.", val_lower) || grepl("^na\\(", val_lower)) {
      stop(paste0(
        "Invalid value '", val_str, "' in label rule '", rule, "'. ",
        "Stata-style missing-value tokens must be '.a' through '.z' ",
        "(a single lowercase letter after the period). The NA(a) ",
        "longhand is not supported in the labels argument."
      ), call. = FALSE)
    } else {
      val <- suppressWarnings(as.numeric(val_str))
      if (is.na(val)) {
        stop(paste0(
          "Invalid value '", val_str, "' in label rule '", rule, "'. ",
          "The left side of each label rule must be numeric or a ",
          "Stata-style missing-value token (.a through .z)."
        ), call. = FALSE)
      }
    }

    if (nchar(label_str) == 0) {
      stop(paste0(
        "Empty label text in rule '", rule, "'. ",
        "Provide a label name after the equals sign."
      ), call. = FALSE)
    }

    entry        <- val
    names(entry) <- label_str
    result <- c(result, entry)
  }

  return(invisible(result))
}
