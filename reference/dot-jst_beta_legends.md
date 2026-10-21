# Internal: the legends under a table of standardized coefficients

The notes jlm() and jlogistic() print under their tables when a model
holds interactions, powers or a product entered by hand: what the
product method treats as an ordinary predictor, and what the centered
methods change (Sessions 347 and 375). The two functions built them in
one block each, the help page aside; Session 383 gave them one home.

## Usage

``` r
.jst_beta_legends(
  std,
  beta_header,
  has_int,
  has_pow,
  pow_noun,
  hand,
  hand_sq,
  fn
)
```

## Arguments

- std:

  Character(1). The standardization method.

- beta_header:

  Character(1). The column's header.

- has_int, has_pow:

  Logical(1). Whether the formula holds an interaction, and a power.

- pow_noun:

  Character(1). "squared term" or "power term".

- hand:

  List. The products entered by hand, from
  [`.jst_hand_products()`](https://jma61.github.io/jstats/reference/dot-jst_hand_products.md).

- hand_sq:

  Logical. Which of them square one variable.

- fn:

  Character(1). The function whose help page the legends name.

## Value

Character: the legends, possibly none.
