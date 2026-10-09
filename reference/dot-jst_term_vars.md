# Internal helper: the variables a model term is built from

A name, or every name inside a computed term: `I(Stress > 20)` is built
from `Stress`. A name that does not parse as R – a column named with a
space and given without backticks – is returned as it is.

## Usage

``` r
.jst_term_vars(term)
```

## Arguments

- term:

  Character(1); a term as the model frame names it.

## Value

Character vector of variable names.
