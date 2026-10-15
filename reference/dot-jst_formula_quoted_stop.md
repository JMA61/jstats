# Internal helper: a variable named in quotes inside a formula

`jt(Score ~ "Gender", d)` printed its title and stopped on R's "missing
value where TRUE/FALSE needed"; `jlm(Score ~ Age + "Region", d)` on
"invalid model formula in ExtractVars"; the plot form said NA was not
found (ruling R18, Session 355; built Session 356). A string standing as
a term – an operand of the formula's own operators, `~ + - * : / | ^`
and parentheses – is the sibling of "The formula should not be in
quotes": the stop names the first such term and gives the call as typed
with every quoted term's quotes removed. A string inside a computed term
(`I(Source == "web")`) is R code and is left alone.

## Usage

``` r
.jst_formula_quoted_stop(formula, cl, fn)
```

## Arguments

- formula:

  The formula.

- cl:

  The call as typed, for the line.

- fn:

  Character(1); the user-facing function's name.

## Value

Invisible NULL; stops when a quoted term is found.
