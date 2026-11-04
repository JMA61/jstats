# Internal helper: names for the tables a message offers lines to make

t1, t2, ... unless one of them names an object in the workspace, which
an offered line would replace: then tab1, tab2, ..., then table1, ....

## Usage

``` r
.jst_table_line_names(k, env, stem = c("t", "tab", "table"))
```

## Arguments

- k:

  The number of names.

- env:

  The caller's environment.

- stem:

  The stems to try, in order.

## Value

Character, k names.
