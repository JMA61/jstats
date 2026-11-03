# Internal helper: where a table's N goes (ruling R51)

n.position = note opens the general note on N; title adds "(N = 103)"
after the title, the call's own included; none writes no N. A table with
no one N to write (variables from different pools of cases) gets nothing
under any setting. The text is marked up for the writers (*N* italic).

## Usage

``` r
.jst_table_n_parts(setting, n_text, title_text = n_text)
```

## Arguments

- setting:

  The n.position value.

- n_text:

  NULL, or the sentence's body: "*N* = 103", or the models' form when
  their Ns differ.

- title_text:

  The text for the title's parenthesis; the same by default (shorter for
  models whose Ns differ).

## Value

A list: note (character(0) or the sentence) and title ("" or the
parenthesis to append).
