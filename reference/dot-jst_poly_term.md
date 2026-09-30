# Internal helper: read a computed term as a power or product of inputs

Gelman (2008, section 3.1) rescales the input variables and recomputes
each term from them, so a squared input is the square of the rescaled
input, not the rescaled square. That applies to a term that is a power
or a product of inputs – `I(x^2)`, `I(x^3)`, `I(x * z)` – and not to a
term that makes a new input of its own: `log(x)`, `sqrt(x)`, a ratio, a
sum, a rescaling, a condition such as `I(x > 10)`, where recomputing
from a rescaled input is undefined (the logarithm of a negative z-score)
or only rescales the column again. This reads a computed term's text
and, when it is an [`I()`](https://rdrr.io/r/base/AsIs.html) call whose
argument is a product of whole-number powers of inputs with total degree
2 or more, returns the inputs. An input is a variable, or any other
sub-expression that contains a variable (`log(x)` in `I(log(x)^2)`); a
number, or a symbol that is not a column of the data, is a constant and
stays in the term as written. Parentheses, unary minus and division by a
constant are read through. (Session 321.)

## Usage

``` r
.jst_poly_term(term_txt, data_names)
```

## Arguments

- term_txt:

  The computed column's name: the term's text.

- data_names:

  Column names of the analysis frame.

## Value

NULL when the term is not a power or product of inputs; otherwise a list
of `expr` (the parsed term), `inputs` (named list of the input
expressions, keyed by their text), `kind` (`"interaction"` for two or
more distinct inputs, `"power"` for one) and `power` (the highest
exponent).
