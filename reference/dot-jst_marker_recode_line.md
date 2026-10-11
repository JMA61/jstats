# Internal helper: the jrecode() line that sends codes to free markers

What runs, for a variable of Stata or SAS form, in place of a
jdeclare_missing() line that would put its codes on markers the variable
carries
([`.jst_marker_clash()`](https://jma61.github.io/jstats/reference/dot-jst_marker_clash.md)):
a recode of the codes to markers the variable does not use, each code's
label carried, the else rule keeping every other value – the "keep them
distinct" line of jdeclare_missing()'s own refusal. The codes take the
letters in the order jdeclare_missing() gives them (largest magnitude
first).

## Usage

``` r
.jst_marker_recode_line(data_name, var_name, codes, conv, used, labels = NULL)
```

## Arguments

- data_name:

  The data frame as the line names it.

- var_name:

  The variable.

- codes:

  Numeric codes to send to markers.

- conv:

  "stata" or "sas".

- used:

  Tag letters already in use.

- labels:

  Optional character vector parallel to `codes`: a label for each code's
  marker ("" for none).

## Value

Character(1): one indented line, or NULL when too few letters are free.
