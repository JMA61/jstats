# Internal helper: the stop for results that cannot share a table

Ruling R56 (Session 406): one jtable() call makes one table, so the user
decides what goes together, and a list that cannot make one table stops.
The stop names what keeps the results apart, then gives the lines that
make each table – the results that can share one grouped, in the order
of each table's first result – and the line that writes them to one
file. Before it says so, each line's table is built (and discarded), so
a result that cannot make a table at all stops in its own words, and no
offered line stops again (ruling R23). style = goes on every line, a
table type's setting on the lines of the tables that take it, and the
file, overwrite =, open =, landscape = and print = on the line that
writes; headings =, markers =, title = and note = name one table, and a
sentence says to put them on its line.

## Usage

``` r
.jst_table_split_stop(
  results,
  groups,
  x_sub,
  env,
  st,
  over_q,
  over_vals,
  given,
  mc
)
```

## Arguments

- results:

  A list of results.

- groups:

  The tables' results
  ([`.jst_table_share_groups()`](https://jma61.github.io/jstats/reference/dot-jst_table_share_groups.md)).

- x_sub:

  The call's first argument as typed.

- env:

  The caller's environment.

- st:

  The call's style.

- over_q, over_vals:

  The call's style settings: as typed (quosures) and evaluated.

- given:

  Logical, named headings, markers, title, note: which of them the call
  gave.

- mc:

  The matched call.
