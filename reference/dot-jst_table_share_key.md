# Internal helper: what a result shares with the others of its table

Ruling R54: results share a table when they share its columns – every
jdesc() result, every jfreq() and every jalpha() result of a call
stacks; models of one outcome sit side by side; t tests, ANOVAs and
crosstabs of one grouping (column) variable with one set of groups
stack; each jcorr() result is a table of its own. Two results share a
table when their keys are the same.

## Usage

``` r
.jst_table_share_key(r, i)
```

## Arguments

- r:

  A result.

- i:

  Its place in the list.

## Value

Character(1): the table type, then what the table's columns depend on.
