# Internal helper: resolve the active missing-value convention

Implements Decision 11's four-step precedence rule for determining which
UDM convention (SPSS-form or Stata-form) applies to a fresh UDM
declaration or convention-conditional recode. Returns either `"spss"` or
`"stata"` – never `NULL`.

## Usage

``` r
.jst_resolve_convention(per_call = NULL, column_convention = NULL)
```

## Arguments

- per_call:

  The value of the calling function's `convention` argument (typically
  NULL, "spss", or "stata"). Validated; values other than NULL, "spss",
  or "stata" raise an error.

- column_convention:

  Optional. `"spss"`, `"stata"`, or `NULL`. When non-NULL, level 1 of
  the precedence rule applies and the function returns this value
  immediately. Step 5b
  ([`jdeclare_udm()`](https://jma61.github.io/jstats/reference/jdeclare_udm.md))
  will populate this argument from
  [`.jst_missing_info()`](https://jma61.github.io/jstats/reference/dot-jst_missing_info.md)
  on the operand column.

## Value

Single character: `"spss"` or `"stata"`.

## Details

The four levels of the precedence rule, in order:

1.  If the column already carries a UDM convention (na_values metadata
    for SPSS-form, tagged_na markers for Stata-form), match it. Handled
    at the call site by passing a non-NULL value to `column_convention`;
    [`jrecode()`](https://jma61.github.io/jstats/reference/jrecode.md)
    does not engage this level because it produces fresh columns.

2.  If `per_call` is `"spss"` or `"stata"`, use that.

3.  If `joptions("missing.convention")` is `"spss"` or `"stata"`, use
    that.

4.  Else default to SPSS-form.
