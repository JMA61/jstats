# Internal helper: print variable label legend

Used by jt, jaov, jcorr, jcrosstab, jscreen, and jalpha. Lists only
variables that carry a meaningful label: a variable with no label, or a
label equal to its own name, is omitted (avoiding a redundant "X = X"
line). If no variable has a meaningful label, nothing is printed.

## Usage

``` r
.print_var_labels(data, var_names)
```
