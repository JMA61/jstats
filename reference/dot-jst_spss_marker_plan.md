# Internal: the SPSS-style codes a column's markers take in jconvert()

The Stata-to-SPSS mapping of `jconvert(to = "spss")`, in one place
(Session 361): a column's markers, sorted, take the convention codes in
letter order
([`.jst_tag_letters_to_codes()`](https://jma61.github.io/jstats/reference/dot-jst_tag_letters_to_codes.md));
a column with more markers than codes takes a missing-value RANGE
instead (Session 319), starting at the first code and running one
integer per marker in the direction the codes run, from the first toward
the second. A single code gives no direction, and a range that would
reach or cross zero is refused. jconvert()'s pre-flight builds its plan
here, and the SPSS-to-Stata branch asks it what the trip back would give
(the return-trip note, the S354 item), so the two cannot disagree.

## Usage

``` r
.jst_spss_marker_plan(tags, convention_codes)
```

## Arguments

- tags:

  Character vector of the column's distinct lowercase marker letters,
  sorted.

- convention_codes:

  The `missing.convention.codes` setting.

## Value

A list: `plan`, a numeric vector of codes named by letter (the mappable
subset when refused); `band`, the range's two ends or NULL; `refused`,
TRUE when the markers outnumber the codes and no range can be formed.
