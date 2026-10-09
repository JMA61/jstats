# Internal helper: validate a diagnostics value

A `diagnostics` value is `TRUE`, `FALSE`, `NULL` (not given) or a
character vector of diagnostic names. Per call the names are the calling
function's own set; in
[`joutput()`](https://jma61.github.io/jstats/reference/joutput.md) they
are every function's, since each function takes from the stored setting
what applies to it.

## Usage

``` r
.jst_check_diagnostics(value, fn)
```

## Arguments

- value:

  The value given.

- fn:

  Character(1); the function it was given to.

## Value

Invisibly `value`; stops when it is not valid.

## Details

A name that is not one of them stops, where
[`jlm()`](https://jma61.github.io/jstats/reference/jlm.md) ignored it
until Session 346: `diagnostics = c("vif", "qqq")` printed the VIF table
and no plot, with nothing to say a diagnostic had been asked for and not
produced. Several names typed into ONE string – `"vif + qq"`,
`"vif, qq"` – get the stop that shows the form that works,
`c("vif", "qq")`: the form R uses for a set of values everywhere, and
the one `categorical =` takes in the same call.
