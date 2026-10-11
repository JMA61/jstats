# Internal: the text variables among those with SPSS-style declarations

The variables of `vars` whose declared missing values sit on a text
(string) variable, read through
[`.jst_missing_info()`](https://jma61.github.io/jstats/reference/dot-jst_missing_info.md)'s
`text` flag. jconvert() cannot give these Stata-style or SAS-style
missing values (Session 340), so a message offering that conversion asks
first (Session 351).

## Usage

``` r
.jst_declared_text_vars(data, vars = names(data))
```

## Arguments

- data:

  A data frame.

- vars:

  Names of its variables to consider; default every one.

## Value

Character vector, possibly empty.
