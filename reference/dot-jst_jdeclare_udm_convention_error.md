# Internal helper: build jdeclare_udm's cross-convention error message

Produces the error message used by
[`jdeclare_udm()`](https://jma61.github.io/jstats/reference/jdeclare_udm.md)
when Stata-style missing-value tokens appear in the `codes` argument but
the resolved convention is SPSS. Verbosity is controlled by the active
[`joutput()`](https://jma61.github.io/jstats/reference/joutput.md)
level.

## Usage

``` r
.jst_jdeclare_udm_convention_error(parsed_codes, data_name, var_name)
```

## Arguments

- parsed_codes:

  Named numeric vector. Names are labels (`""` where no label was
  given). Values are the user's codes including any tagged-NA elements.

- data_name:

  Character. Name of the data frame in the user's call (used to
  reconstruct the example).

- var_name:

  Character. Name of the variable being declared.

## Value

Character scalar suitable for passing to
[`stop()`](https://rdrr.io/r/base/stop.html).
