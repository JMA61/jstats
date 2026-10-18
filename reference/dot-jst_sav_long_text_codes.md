# Internal: a frame's declared text values that a .sav file would cut

SPSS format (.sav) keeps 8 bytes of a string variable's declared missing
value (observed S372, haven 2.5.4: "Refused to provide information" read
back as "Refused", the long cells valid). Bytes, not characters: a
letter outside plain ASCII takes two or more.

## Usage

``` r
.jst_sav_long_text_codes(data)
```

## Arguments

- data:

  A data frame.

## Value

A list, one entry per variable with such a value: `var` and `codes` (the
values too long, as stored).
