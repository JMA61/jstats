# Internal helper: flag a registered classification that fights the data

Given a variable and the analysis role the user declared for it
("count", "likert", or "dummy"), returns a short plain-language reason
when the variable's structure is an implausible fit for that
declaration, or "" when the declaration is a reasonable fit (or cannot
be assessed). This drives the non-blocking "Unusual declaration"
heads-up in jscreen() and the registration-time note in jcount(): the
declaration always stands (a user assertion overrides structure by
design), but a clear contradiction is surfaced in case it was a slip.

## Usage

``` r
.jst_declaration_plausibility(x, kind)
```

## Arguments

- x:

  A variable / data-frame column.

- kind:

  The declared role: one of "count", "likert", "dummy". Any other value
  (including "numeric") returns "".

## Value

A character scalar: the reason tail (e.g. "declared as a count, but
negative values are present"), or "" when the declaration is plausible
or cannot be assessed.

## Details

The plausibility envelope per role:

- "count" – non-negative whole numbers with more than two distinct
  values. Flagged on a negative value, a non-whole value, or exactly two
  distinct values (which reads as a dichotomy).

- "likert" – non-negative whole numbers within 0 to 10 and at most 11
  distinct points. Flagged when a value falls outside that range, a
  value is non-whole, or there are more than 11 distinct values.

- "dummy" – at most 11 categories, flagged only on the high end (more
  than 11 categories). There is no lower floor: a two-category
  (dichotomy) dummy is never flagged.

"numeric" is not a plausibility target – declaring a variable Numeric is
the maximally permissive assertion – so it returns "".

Declared-missing codes are removed before the structure is judged
(through the central
[`.jst_missing_info()`](https://jma61.github.io/jstats/reference/dot-jst_missing_info.md)
reader, so SPSS-style na_values / na_range and Stata-/SAS-style tagged
NAs are all handled). A Likert item carrying an out-of-range missing
sentinel (e.g. 99 = "Refused") is therefore judged on its real scale
points, not flagged for the sentinel. The count and Likert checks read
the numeric codes; the dummy category count is taken on the surviving
values with their type preserved, so a character/factor identifier is
counted by its distinct labels.
