# Internal helper: build an assumption-check warning string

Assembles the warning for one call site from the central clause table,
so every site shares one consistent phrasing. The result is
`paste0(var_name, " ", verb, " categorical", connector, clause)`.

## Usage

``` r
.jst_assumption_warning(var_name, site)
```

## Arguments

- var_name:

  Character. The variable's name (used verbatim in the text).

- site:

  Character. The call-site key into `.jst_assumption_clauses` (e.g.
  "jcorr", "jsum").

## Value

A single character string ready to pass to
[`warning()`](https://rdrr.io/r/base/warning.html).
