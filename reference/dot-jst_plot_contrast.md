# Internal helper: black or white, whichever reads better on a color

For a value written inside a segment (ruling R70: "white on the dark
greys and black on the light"): the text color with the higher contrast
against the fill, by the WCAG relative luminance.

## Usage

``` r
.jst_plot_contrast(cols)
```

## Arguments

- cols:

  Character; colors as "#RRGGBB".

## Value

Character; "#FFFFFF" or "#000000" for each.
