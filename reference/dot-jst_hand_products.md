# Internal helper: find predictor columns that are hand-made products

A product entered as its own column – xz made from x \* z, then
`y ~ x + z + xz` – fits the same model as `y ~ x * z`, but jlm() cannot
see its parts, so its standardized columns standardize it as it stands
(the second convention in ?jlm's "Comparing with other software"); a
square made by hand is the same case. This finds each numeric predictor
column that equals the product of two other numeric predictor columns of
the model, or the square of one, to floating-point tolerance, so the
coefficient table can name it. A product rounded when it was saved (to
two decimals, say) is not found. Each pair is tried on the first 20
analysis rows before the whole column is compared, so the search stays
cheap on a large sample. The square of a 0/1 column is the column itself
and is left to the collinearity warning. Columns in `skip` – the
resolver-computed terms, whose parts jlm() does see, and the dummy
columns of a registered categorical, whose internal names are not what
the user typed – take part in neither role. (Session 321.)

## Usage

``` r
.jst_hand_products(mf, skip = character(0))
```

## Arguments

- mf:

  The listwise-complete model frame.

- skip:

  Column names left out of the search.

## Value

A list with one element per product found, in model order, each a list
of `col`, `a` and `b` (`a` equal to `b` for a square); empty when there
is none.
