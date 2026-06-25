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
