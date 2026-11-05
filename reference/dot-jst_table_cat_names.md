# Internal helper: categories named by their value labels

A category's name in a table is its value label, or its code where it
has none – never the string a result printed (the reference, 4.3). Where
two codes given in one call would take one name – a label used for two
codes – each of them is named "code: label" ("1: Other", "2: Other"), as
the console shows them under value.id = "labels" (Session 407, the
(S399) colliding-labels item). A code repeated in the vector is one
code; an NA code takes no part.

## Usage

``` r
.jst_table_cat_names(code, label)
```

## Arguments

- code:

  The codes.

- label:

  The value labels (NA where there is none).

## Value

Character.
