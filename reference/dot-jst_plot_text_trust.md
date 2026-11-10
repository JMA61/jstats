# Internal helper: how far a text's reckoned width is trusted

For the faces every device draws as "sans", "serif" or "mono" the
reckoning is close: a text is taken as up to 4 percent wider where it
must fit, and 5 percent narrower where something is moved by its width.
Any other face may be wider or narrower than those: 12 percent wider, 15
percent narrower.

## Usage

``` r
.jst_plot_text_trust(family)
```

## Arguments

- family:

  Character(1); the font family.

## Value

Numeric(2), named over and under: the factors.
