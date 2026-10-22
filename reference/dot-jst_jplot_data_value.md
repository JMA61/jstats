# Internal helper: the data frame jplot()'s formula form is given, read

The five formula functions read their data at the front door
([`.jst_check_formula_data()`](https://jma61.github.io/jstats/reference/dot-jst_check_formula_data.md));
jplot()'s formula form reads it from its dots, and a name found nowhere
– `jplot(Score ~ Group, dd)` – or an expression that could not be
evaluated gave R's own "object 'dd' not found". Read here, a name found
nowhere gets ruling R36's stop
([`.jst_formula_data_found()`](https://jma61.github.io/jstats/reference/dot-jst_formula_data_found.md))
and an expression the expression stop
([`.jst_expr_data_stop()`](https://jma61.github.io/jstats/reference/dot-jst_expr_data_stop.md)),
or, where it gave no rows by reading a column its frame lacks, the
not-found sentence
([`.jst_expr_empty_stop()`](https://jma61.github.io/jstats/reference/dot-jst_expr_empty_stop.md)),
as in those functions (Session 392).

## Usage

``` r
.jst_jplot_data_value(q, formula)
```

## Arguments

- q:

  The quosure of the argument given as the data.

- formula:

  The formula.

## Value

The argument's value.
