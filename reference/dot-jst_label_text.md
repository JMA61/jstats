# Internal helper: a label as a printed labels string carries it

Ruling R17 (Jeff, Session 356). Every line the package offers with a
`labels = "..."` string writes each label through this: quoted, with the
mark the label does not hold, when it holds a semicolon or opens with a
quotation mark (the parser would read either wrongly unquoted), and
otherwise as it is; then escaped for the R string literal it sits in
([`.jst_dq_escape()`](https://jma61.github.io/jstats/reference/dot-jst_dq_escape.md)).
A label that holds a semicolon and both marks, or opens with a mark and
holds the other, can be written in no labels string: `NA`, which the
builder leaves out, saying so.

## Usage

``` r
.jst_label_text(x)
```

## Arguments

- x:

  Character.

## Value

Character, the same length; `NA` where a label cannot be written.
