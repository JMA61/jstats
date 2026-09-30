# Internal helper: name the kinds of term a coefficient-table note is about

The standardized-column notes under jlm()'s coefficient table name only
what the model contains (Session 321, Jeff): an interaction, a squared
term ("power term" when a power above 2 is present), or both – with
articles ("an interaction and a squared term"), or after "each" for the
std = "product" note ("each interaction and squared term").

## Usage

``` r
.jst_term_kinds_phrase(has_int, has_pow, pow_noun, each = FALSE)
```

## Arguments

- has_int, has_pow:

  Logical: the model has an interaction; a power.

- pow_noun:

  "squared term" or "power term".

- each:

  Logical: the "each" form, without articles.

## Value

Character scalar.
