# Internal: the names jload() gives the variables of a file from outside R

Ruling R20: a name R can read bare, and not a repeat of an earlier one,
is never touched; every other name is cleaned (.jst_clean_name()) and
made unique among all the names. Used for every outside format, never
for .rds.

## Usage

``` r
.jst_clean_import_names(nm)
```

## Arguments

- nm:

  Character vector: the names as the file has them.

## Value

list(names, changed): the new names and which of them changed.
