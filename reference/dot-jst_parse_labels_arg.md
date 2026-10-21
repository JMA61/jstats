# Internal: a labels = string parsed, its raw marker spellings harvested

The labels parsed (.jst_parse_labels(); a parse error stops as "Error in
labels argument: ..."), then the raw-spelling record of each marker
harvested and stripped, so the labels can become a column's value labels
while a message can still quote a marker as typed (a .B stays .B; S249,
S283). jrecode(), jencode() and jdeclare_missing() each held this block
(Session 386, the twin build); each checks the string's shape first.

## Usage

``` r
.jst_parse_labels_arg(labels, convention)
```

## Arguments

- labels:

  Character(1): the labels string.

- convention:

  The convention in force for the parse.

## Value

list(parsed_labels, labels_tagged_raw).
