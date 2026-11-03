# Internal helper: a number cell's whole part and its tail

The tail is the point and what follows it – the decimals, any stars, the
df after an F – or, with no point, whatever follows the digits; the
whole part is the rest. The decimal tab aligns the two.

## Usage

``` r
.jst_docx_num_parts(s)
```

## Arguments

- s:

  Character.

## Value

A list: head and tail, character vectors of s's length.
