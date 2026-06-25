# Internal helper: recognized affirmative/negative token matcher

Given the two distinct category strings of a text dichotomy, decides
whether they form a recognized affirmative/negative pair and, if so,
which is the affirmative (the event modeled as 1) and which is the
negative (the reference, 0). Matching is case-insensitive and ignores
surrounding whitespace. The recognized vocabulary is:

- affirmative: yes, y, true, t, present, success

- negative: no, n, false, f, absent, failure

A pair is recognized only when exactly one category is affirmative and
the other is negative, so two affirmatives (e.g. "yes"/"true") or an
unrecognized pair (e.g. "high"/"low") return `recognized = FALSE`. The
caller supplies the original-cased strings; the returned `event` and
`reference` echo them unchanged for display.

## Usage

``` r
.jst_match_binary_tokens(cats)
```

## Arguments

- cats:

  Character vector of length 2: the two distinct category strings,
  original casing preserved.

## Value

A list with elements `recognized` (logical), `event` (the affirmative
category string, or NA), and `reference` (the negative category string,
or NA).

## Details

Used by jlogistic() to coerce a recognized text/factor response to 0/1
with a known, announced direction, rather than letting glm() pick the
event by alphabetical level order (which silently models the wrong
category for pairs like high/low). See the DV-resolution block in
jlogistic().
