# Internal helper: tables together, as one document

What a call that writes two or more built tables returns (Session 406):
a list of jst_table of class "jst_tables". Typed, or given to print(),
it shows every table's preview numbered as in the file; given to
jtable(), alone or inside a list, it is written as its tables.

## Usage

``` r
.jst_tables_new(tables)
```

## Arguments

- tables:

  A list of jst_table.

## Value

An object of class "jst_tables".
