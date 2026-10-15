# Internal helper: the labels = argument of an offered line

Builds `, labels = "..."` from parallel left sides and labels, each
label through
[`.jst_label_text()`](https://jma61.github.io/jstats/reference/dot-jst_label_text.md)
(ruling R17, Session 356), and the sentence that names any label the
string cannot carry, which the caller prints after the line. An empty or
missing label gets no rule; with no rule left the argument is empty.

## Usage

``` r
.jst_labels_arg(lhs, labels)
```

## Arguments

- lhs:

  Character; the left sides (".b", "0").

- labels:

  Character; the labels, parallel to `lhs`.

## Value

A list: `arg`, the argument text or ""; `note`, the sentence or "".
