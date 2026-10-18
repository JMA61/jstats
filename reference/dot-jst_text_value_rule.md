# Internal helper: a text value as the left side of a labels-string rule

For the labels = string of a line offered on a text variable (Slate E5,
ruling R26's lean 3): a blank as blank; a value that holds a semicolon
or an equals sign, opens with a quotation mark, has outer spaces or is
the word blank, in the mark it does not hold; any other value as it is.
Escaped for the R string literal it sits in
([`.jst_dq_escape()`](https://jma61.github.io/jstats/reference/dot-jst_dq_escape.md)).

## Usage

``` r
.jst_text_value_rule(v)
```

## Arguments

- v:

  Character(1).

## Value

Character(1), or `NA` where no labels string can hold the value.
