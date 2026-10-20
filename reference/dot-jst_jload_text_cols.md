# Internal: the variables jload()'s text = names

Ruling R31 (Session 380): `text =` names variables, so under ruling R18
it takes names bare or in quotes, or a
[`c()`](https://rdrr.io/r/base/c.html) of either, each read without
evaluating it. A name is the file's own or the one jload() gives the
variable (`"Post code"` or `Post_code`). A bare name the file does not
have, but which holds names in the workspace, is read for them; any
other expression is evaluated and must give names. A name the file has
under neither form stops, every such name in one stop (voice Rule AJ),
with the file's names listed, as `sheet =` lists the sheets.

## Usage

``` r
.jst_jload_text_cols(sub, env, raw_nm, shown)
```

## Arguments

- sub:

  `text =` as typed (`substitute(text)`).

- env:

  The caller's environment.

- raw_nm:

  The names as the file has them.

- shown:

  The file's name, for the stop.

## Value

Integer vector: the variables' positions.
