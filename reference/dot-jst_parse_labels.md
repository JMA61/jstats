# Internal helper: parse a label-spec string into a named numeric vector

Parses a labels string of the form `"1=Young; 2=Middle Aged; 3=Older"`
into a named numeric vector formatted for use with `haven_labelled`
variables (names = label text, values = numeric codes). Splits on the
first equals sign in each rule, so label text may itself contain equals
signs.

## Usage

``` r
.jst_parse_labels(labels_str)
```

## Arguments

- labels_str:

  Character string of the form `"value1=label1; value2=label2; ..."`.

## Value

Invisibly, a named numeric vector. Names are label strings; values are
numeric codes, or Stata-style missing values for tagged entries.

## Details

The left-hand side of each rule may be a numeric value or a Stata- style
missing-value token (`.a` through `.z`). Tagged-NA entries are stored as
`haven::tagged_na(<letter>)` values in the returned vector; callers can
detect them via
[`haven::na_tag()`](https://haven.tidyverse.org/reference/tagged_na.html).
