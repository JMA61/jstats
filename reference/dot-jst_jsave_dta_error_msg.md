# Internal: build jsave's .dta pre-flight error message

Produces the error message used by
[`jsave()`](https://jma61.github.io/jstats/reference/jsave.md) when
SPSS-form UDM declarations (`na_values` and/or `na_range`) are
encountered on a `.dta` write. The .dta format has no representation for
SPSS-style missing-value codes; haven would otherwise drop them
silently. The user is directed to convert via `jconvert(to = "stata")` –
since S218 the one remedy covers both forms, as jconvert enumerates
`na_range` declarations too. Verbosity is controlled by the active
[`joutput()`](https://jma61.github.io/jstats/reference/joutput.md)
level.

## Usage

``` r
.jst_jsave_dta_error_msg(spss_vars, data_name)
```

## Arguments

- spss_vars:

  Character vector of variable names carrying SPSS-form UDM declarations
  (`na_values` and/or `na_range`).

- data_name:

  Character. Name of the data frame argument in the user's call to
  [`jsave()`](https://jma61.github.io/jstats/reference/jsave.md), used
  to construct the suggested
  [`jconvert()`](https://jma61.github.io/jstats/reference/jconvert.md)
  call.

## Value

Character scalar suitable for passing to
[`stop()`](https://rdrr.io/r/base/stop.html).
