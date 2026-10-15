# Internal helper: text made safe inside a double-quoted string

A value label pasted into the `labels = "..."` of a printed call closed
the string early when it held a quotation mark –
`labels = ".b=Said "no""` does not parse (the S353 item) – so the line
the package offered did not run. Each builder that pastes a label into a
printed string escapes it with this (Session 355), as the map builders
escape a quoted word (S249): a backslash doubled, then each quotation
mark preceded by one. The label the line gives is the label as it was. A
label holding a semicolon is quoted first, by
[`.jst_label_text()`](https://jma61.github.io/jstats/reference/dot-jst_label_text.md)
(ruling R17, Session 356).

## Usage

``` r
.jst_dq_escape(x)
```

## Arguments

- x:

  Character.

## Value

Character, the same length.
