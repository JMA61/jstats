# Internal: refuse a transformed term in a model formula, in house voice

Detects a function call among the formula's variables – log(x), I(x^2),
sqrt(x), and the like, on either side – and stops with a clear message
(AUDIT-005). Without this front-door check, jlm/jlogistic build the
model frame from the data (which yields a column literally named
"log(x)") and then refit against that frame, where the term goes looking
for a plain x that no longer exists; the user gets base R's raw,
unattributed "object 'x' not found". Interaction terms (x \* z, x:z) are
unaffected: terms() lists their component variables as plain names, not
calls. When the offending call is a single function applied to one bare
variable, the message includes a runnable make-the-variable example
built from the user's own term and data-frame name.

## Usage

``` r
.jst_check_formula_transforms(formula, data_name)
```

## Arguments

- formula:

  The user's analysis formula.

- data_name:

  Character; the data frame's name (for the example line).

## Value

Invisibly NULL; stops when a transformed term is found. A formula that
terms() cannot process (e.g. a bare dot) passes through untouched for
downstream handling.
