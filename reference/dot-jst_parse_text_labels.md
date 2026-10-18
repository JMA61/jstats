# Internal helper: parse a text variable's labels string

`"REF=Refused; UNKNOWN=Unknown"` into a named character vector (names
the labels, values the strings), for jdeclare_missing() on a text
variable (Slate E5, ruling R26's lean 3). The value is read up to the
first equals sign; quoted, it may hold `=` or `;`, and its text is kept
as typed, outer spaces included – a declared value matches as stored.
Bare, it is trimmed, and `blank` names the blank cells, as in
jencode()'s maps (`"blank"` in quotes is the word). The label is read as
ruling R17 reads one.

## Usage

``` r
.jst_parse_text_labels(labels_str)
```

## Arguments

- labels_str:

  The labels string.

## Value

Named character vector.
