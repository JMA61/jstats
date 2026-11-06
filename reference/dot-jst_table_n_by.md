# Internal helper: N in a table that stacks results, when the Ns differ

"*N* differs by variable: 98 (Current smoker), 103 (Owns home and Region
of residence)" – equal Ns grouped, as the models' sentence groups them
(Session 403).

## Usage

``` r
.jst_table_n_by(ns, names, by, thou)
```

## Arguments

- ns:

  Numeric, one per result.

- names:

  Character, one per result.

- by:

  The word after "by": "variable", "scale".

- thou:

  The style's thousands setting.

## Value

A list: note (the sentence's body, or the one N's) and varies (TRUE when
the Ns differ, so the sentence goes in the note under n.position = title
too: ruling R59, Session 409).
