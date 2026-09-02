# Internal helper: in-band value counts for the range-conflict guards

The data-aware half of the Decision 11 gate's D/E guards (S243 design;
S244 build): for each targeted column, how many values would a candidate
missing-value range cover – the count
[`jconvert()`](https://jma61.github.io/jstats/reference/jconvert.md)
would enumerate when converting the declared range to tagged form.
Delegates to the shared counter (`.jst_missing_info(observed = TRUE)`)
by attaching the candidate range to a throwaway copy of the column, so
the guard and the converter cannot disagree about what "inside the
range" means (distinct observed in-band values, excluding any discretely
declared codes).

## Usage

``` r
.jst_gate_inband_counts(data, vars, range)
```

## Arguments

- data:

  The data frame.

- vars:

  Character vector of target column names.

- range:

  Length-2 numeric, sorted: the candidate range.

## Value

Integer vector, one count per element of `vars`.
