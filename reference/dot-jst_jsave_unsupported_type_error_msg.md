# Internal: build jsave's error message for unsupported column types

The statistical interchange formats (.sav, .dta, .xpt) cannot store
complex, list, raw, or POSIXlt columns; the underlying writers abort
mid-write with a low-level message that does not name the offending
column (e.g. "Columns of type complex not supported yet", or "...type
list..." for a POSIXlt column, which is list-backed). This helper
produces one clean package-level error that names the column(s) and
their type(s) and gives the right remedy for each: complex/list/raw have
no sensible conversion and are dropped, while POSIXlt converts
faithfully to POSIXct (the same instant, which the formats can store).

## Usage

``` r
.jst_jsave_unsupported_type_error_msg(vars, types, ext, data_name)
```

## Arguments

- vars:

  Character vector of offending column names.

- types:

  Character vector of the columns' types, parallel to `vars` ("complex",
  "list", "raw", or "POSIXlt").

- ext:

  The target extension ("sav", "dta", or "xpt").

- data_name:

  The data frame's name, used in the suggested fix code.

## Value

Character scalar suitable for `stop(call. = FALSE)`.
