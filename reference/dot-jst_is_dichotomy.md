# Internal helper: dichotomy classifier

Returns information about whether a variable is a two-value
(dichotomous) variable, and if so, what coding it uses. Designed to be
the single source of truth across the package for "is this a dichotomy?"
questions – used by jlm DV checks, by jlogistic DV validation, and (in
the future) by jcorr inclusion decisions for point-biserial
correlations.

## Usage

``` r
.jst_is_dichotomy(x)
```

## Arguments

- x:

  A variable (vector).

## Value

A list with elements `is_dichotomy` (logical) and `coding` (character or
NA).

## Details

Detects dichotomies in any of these forms:

- Numeric (or haven_labelled numeric) with exactly two unique non-NA
  values: classified by coding pattern as "0/1", "1/2", or "other" (e.g.
  5/10, -1/1).

- Factor with exactly two levels: classified as "factor".

- Character with exactly two unique non-NA values: classified as
  "character".

- Logical with both TRUE and FALSE present: classified as "logical".

Returns a list with two named elements so callers can both detect
dichotomies and react to specific codings without redoing the work:

- `is_dichotomy`: TRUE if the variable has exactly two non-NA distinct
  values, FALSE otherwise.

- `coding`: One of "0/1", "1/2", "other", "factor", "character",
  "logical" when `is_dichotomy` is TRUE; `NA_character_` otherwise.

Why a list rather than two helpers: most callers want both pieces of
information at the same time (e.g. jlogistic asks both "is this a
dichotomy?" and "what coding?" to decide on its error message). One
helper that returns both avoids duplicating detection work and
eliminates the risk of two helpers giving inconsistent answers if
they're modified independently later.

This helper makes no judgement about whether dichotomous treatment is
appropriate – that's up to the caller. jlogistic uses it to validate the
DV (and stops if not coded 0/1); the new jlm DV check uses it to warn
that a different model might have been intended; future jcorr could use
it to decide which correlation method to use.
