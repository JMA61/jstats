# Internal helper: a number cell's whole part and its tail

The tail is the point and what follows it – the decimals, any stars, the
df after an F; the whole part is the rest. The decimal tab aligns the
two. A cell with no point is all whole part: Word sets text with no
decimal point to end at a decimal tab (Session 405: an ANOVA's df
column, "3, 99", and a correlation's em dash; until then the text after
the digits counted as tail).

## Usage

``` r
.jst_docx_num_parts(s)
```

## Arguments

- s:

  Character.

## Value

A list: head and tail, character vectors of s's length.
