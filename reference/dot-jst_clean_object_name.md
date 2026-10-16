# Internal: a data frame's name made from a file's name

The same cleaner as a variable's name (lean 10 of the import audit,
Session 362), with no length budget: "My Survey (final).xlsx" loads as
My_Survey_final, where make.names() gave My.Survey..final. A name R
takes as it is stays as it is.

## Usage

``` r
.jst_clean_object_name(x)
```

## Arguments

- x:

  Character(1).

## Value

Character(1).
