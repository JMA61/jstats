# Internal helper: the results as typed, for the lines a message offers

Read from the call: a list typed in the call gives each result as typed
(`list(d1, m1)`: "d1" and "m1"), one result its expression; a name
holding a list gives each by its place in it (`res[[2]]`); any other
expression is offered with a line that keeps it first.

## Usage

``` r
.jst_table_elements(x_sub, results)
```

## Arguments

- x_sub:

  The call's first argument as typed (substitute()).

- results:

  The results it gave.

## Value

A list: text (character, one per result, or NULL), names (the list's
names, "" for none), base (the name holding the list, or NULL), expr
(the expression to keep first, or NULL), and source (the text, or NA
where there is none, for the combining hint).
