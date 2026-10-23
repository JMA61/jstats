# Internal helper: do a variable's labels carry a recognised scale anchor pair?

The column-local (single-item) half of the Likert sufficient
discriminator. Tokenizes the supplied label texts (split on non-letters,
case-folded) and returns TRUE when both pole words of any family in
`.jst_likert_anchor_families` are present. Because it tests for the
PRESENCE of both poles, it is reverse-coding-agnostic (the direction of
the code mapping is irrelevant). English-centric.

## Usage

``` r
.jst_labels_match_anchor(label_texts)
```

## Arguments

- label_texts:

  Character vector of label texts (typically the surviving, non-missing
  labels of a column).

## Value

TRUE if a recognised anchor pair is present, FALSE otherwise.

## Details

Since Session 394 (ruling R39) it is also TRUE when one label holds the
phrase "not at all" and another label holds one of
`.jst_likert_not_at_all_high` ("extremely", "very", ... "nearly every
day"): each label's words, in order, are matched against the phrase as
whole words, so "Not at all important" holds it and "Not applicable"
does not. The two must be different labels; one label holding both ("Not
at all or very little") is not a scale by itself.
