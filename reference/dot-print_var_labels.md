# Internal helper: print variable label legend

Used by jt, jaov, jcorr, jcrosstab, jscreen, and jalpha. Lists only
variables that carry a meaningful label: a variable with no label, or a
label equal to its own name, is omitted (avoiding a redundant "X = X"
line). If no variable has a meaningful label, nothing is printed.

## Usage

``` r
.print_var_labels(data, var_names, lead = FALSE)
```

## Arguments

- data:

  A data frame (or label source) whose columns may carry variable
  labels.

- var_names:

  Character vector of variable names to list, in order.

- lead:

  Logical. Print a blank line before the block. Default FALSE: most
  callers' preceding output already ends on one.

## Value

Invisibly, TRUE when the block printed (the output now ends on a blank
line) and FALSE when there was nothing to print.

## Details

The block ends on a blank line of its own. So that a caller can end its
output on exactly ONE blank line (Session 328), the helper reports
whether it printed, and can put the blank line that separates it from
what precedes in front of itself – only when it prints.
