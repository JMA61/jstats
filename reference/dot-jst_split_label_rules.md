# Internal helper: the rules of a labels string, read quote-aware

Ruling R17 (Jeff, Session 356). A labels string is split after the
semicolons between its rules; a semicolon inside a quoted label – a
quotation mark of either kind right after a rule's equals sign, closed
by the same mark – does not split. Until then
[`.jst_parse_labels()`](https://jma61.github.io/jstats/reference/dot-jst_parse_labels.md)
split on every semicolon, so a label such as "Refused; not asked" could
be written in no labels string, by the user or by a line the package
offered (the S353 item). The rules come trimmed, empty ones dropped, the
quotation marks still in place for `.jst_unquote_label()`. A quote
opened and never closed stops.

## Usage

``` r
.jst_split_label_rules(labels_str)

.jst_unquote_label(label_str)
```

## Arguments

- labels_str:

  Character(1).

- label_str:

  Character(1): the text after a rule's equals sign.

## Value

Character; the rules.

For `.jst_unquote_label()`: the label, its enclosing quotation marks
removed when the trimmed text opens and closes with the same mark;
otherwise the trimmed text as it is.
