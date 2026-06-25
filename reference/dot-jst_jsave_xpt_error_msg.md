# Internal: build jsave's .xpt pre-flight error message

Produces the error message used by
[`jsave()`](https://jma61.github.io/jstats/reference/jsave.md) when
missing-value forms the .xpt format cannot represent are encountered on
a `.xpt` write: tagged-NA values (haven would otherwise emit a low-level
error, “Failed to insert value...”, and leave a partial file on disk)
and/or SPSS-form UDM declarations (haven would otherwise strip the
metadata silently, mirroring the .dta-with-SPSS-UDMs failure mode). The
user is directed to drop via `jconvert(to = "baseR")`, or to preserve
the codes by saving as `.dta` (tagged NAs; SAS PROC IMPORT can read it)
or `.sav` (SPSS-form declarations). Verbosity is controlled by the
active
[`joutput()`](https://jma61.github.io/jstats/reference/joutput.md)
level.

## Usage

``` r
.jst_jsave_xpt_error_msg(vars, data_name, spss_vars = character(0))
```

## Arguments

- vars:

  Character vector of variable names containing tagged NAs. May be empty
  when only SPSS-form columns fired.

- data_name:

  Character. Name of the data frame argument in the user's call to
  [`jsave()`](https://jma61.github.io/jstats/reference/jsave.md), used
  to construct the suggested
  [`jconvert()`](https://jma61.github.io/jstats/reference/jconvert.md)
  call.

- spss_vars:

  Character vector of variable names carrying SPSS-form UDM declarations
  (`na_values` and/or `na_range`). The .xpt interchange format cannot
  represent these either;
  [`haven::write_xpt`](https://haven.tidyverse.org/reference/read_xpt.html)
  would strip them silently. Default `character(0)` keeps the
  pre-extension call signature working unchanged.

## Value

Character scalar suitable for passing to
[`stop()`](https://rdrr.io/r/base/stop.html).
