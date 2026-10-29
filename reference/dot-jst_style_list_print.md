# Internal helper: print the styles jstats can find

The built-in style, then every style file in the folders searched, the
first folder winning a name; the default marked; then the folders, in
the order they are searched.

## Usage

``` r
.jst_style_list_print()
```

## Value

A data frame: name, path (NA for a built-in).
