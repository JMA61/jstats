# Internal: build jsave's .dta pre-flight error message

Produces the error message used by
[`jsave()`](https://jma61.github.io/jstats/reference/jsave.md) when
SPSS-form UDM declarations (`na_values` and/or `na_range`) are
encountered on a `.dta` write. The .dta format has no representation for
SPSS-style missing-value codes; haven would otherwise drop them
silently. The user is directed to convert via `jconvert(to = "stata")`
for enumerated codes, or to drop via `jconvert(to = "baseR")` for
range-based missingness (which cannot be converted to Stata form).
Verbosity is controlled by the active
[`joutput()`](https://jma61.github.io/jstats/reference/joutput.md)
level.

## Usage

``` r
.jst_jsave_dta_error_msg(enum_vars, range_vars, data_name)
```

## Arguments

- enum_vars:

  Character vector of variable names with enumerated missing-value codes
  (`na_values`).

- range_vars:

  Character vector of variable names with range-based missingness
  (`na_range`). A column that carries both `na_values` and `na_range` is
  placed in this bucket by the caller, since the range portion is the
  more restrictive constraint.

- data_name:

  Character. Name of the data frame argument in the user's call to
  [`jsave()`](https://jma61.github.io/jstats/reference/jsave.md), used
  to construct the suggested
  [`jconvert()`](https://jma61.github.io/jstats/reference/jconvert.md)
  call.

## Value

Character scalar suitable for passing to
[`stop()`](https://rdrr.io/r/base/stop.html).
