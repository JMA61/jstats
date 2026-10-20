# Internal: the base R lines that make a text variable numbers

Session 381 (Fix Slate 24). The lines jload()'s notes offer for a
variable left as text: its cells named in `values` made missing (`==`
for one value, `%in%` for several), then
[`as.numeric()`](https://rdrr.io/r/base/numeric.html), which then gives
no warning; then, when jload() gave the variable a label (its name in
the file, after a rename), the line that puts the label back, since
[`as.numeric()`](https://rdrr.io/r/base/numeric.html) drops every
attribute. Each line indented two spaces.

## Usage

``` r
.jst_numeric_lines(obj_name, var, values = NULL, label = NA_character_)
```

## Arguments

- obj_name:

  The data frame's name.

- var:

  The variable's name, as loaded.

- values:

  The cells to make missing, or NULL.

- label:

  The variable's label, or NA.

## Value

Character: one line each.
