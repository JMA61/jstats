# Internal: build jsave's .sav pre-flight error message

Produces the error message used by
[`jsave()`](https://jma61.github.io/jstats/reference/jsave.md) when
tagged-NA missing values are encountered on a `.sav` write. The .sav
format has no representation for tagged-NA markers; haven would
otherwise silently drop the marker distinctions (every `.a`, `.b`, `.c`,
... cell becomes plain `NA` indistinguishable from any other). The user
is directed to convert in advance via `jconvert(to = "spss")`, which
preserves the distinctions as numeric codes that `.sav` can carry
natively.

## Usage

``` r
.jst_jsave_sav_error_msg(vars, data, data_name)
```

## Arguments

- vars:

  Character vector of variable names containing tagged-NA missing values
  (Stata-style and/or SAS-style).

- data:

  The data frame being saved; used to inspect tag case on each flagged
  variable so the message names the right style.

- data_name:

  Character. Name of the data frame argument in the user's call to
  [`jsave()`](https://jma61.github.io/jstats/reference/jsave.md), used
  to construct the suggested
  [`jconvert()`](https://jma61.github.io/jstats/reference/jconvert.md)
  call.

## Value

Character scalar suitable for passing to
[`stop()`](https://rdrr.io/r/base/stop.html).

## Details

The opening phrase is picked by inspecting the tag case of the flagged
columns: “Stata-style missing values” when all tags are lowercase (`.a`,
`.b`, ...), “SAS-style missing values” when all tags are uppercase
(`.A`, `.B`, ...), or “Stata-style or SAS-style missing values” when
both cases appear. Verbosity is controlled by the active
[`joutput()`](https://jma61.github.io/jstats/reference/joutput.md)
level.
