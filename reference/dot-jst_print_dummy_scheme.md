# Internal helper: render a dummy coding-scheme table

Single source of truth for the 0/1 dummy coding-scheme table shown by
[`jdummy()`](https://jma61.github.io/jstats/reference/jdummy.md) – on
registration, on display-only inspection, and in the no-argument
registration overview. Prints the identity-pattern table with the
reference category starred, the reference footnote, and, when there are
more than five categories and `show` is not "all", the truncation note.
The caller prints the "Dummy Coding Scheme:" header before calling this.

## Usage

``` r
.jst_print_dummy_scheme(codes, labels, ref_idx, show)
```

## Arguments

- codes:

  The category codes (numeric or character) in display order.

- labels:

  The category labels parallel to `codes`.

- ref_idx:

  Integer index of the reference category within `codes`.

- show:

  The caller's `show` argument; "all" (any case) shows every category,
  otherwise the first five.

## Value

`invisible(NULL)`. Called for its printed side effect.
