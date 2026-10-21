# Internal: stop when a variable is named both categorical and numeric

jplot()'s data-first and formula forms (Session 383). numeric and count
are both numeric-like, so they do not clash with each other.

## Usage

``` r
.jst_check_cat_clash(categorical, numeric, count)
```

## Arguments

- categorical, numeric, count:

  Character. The names in each argument.

## Value

NULL, invisibly; stops on a clash.
