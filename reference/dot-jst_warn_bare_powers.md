# Internal helper: warn about each single term raised to a power outside I()

Emits one warning per term
[`.jst_formula_bare_powers()`](https://jma61.github.io/jstats/reference/dot-jst_formula_bare_powers.md)
found, called once the model has been fitted: the model ran, but the
term entered as the single term alone. The first line names the term as
typed and what it entered the model as (Rule AD); the second gives the
rewrite, built from the term. (Session 321; wording approved by Jeff.)

## Usage

``` r
.jst_warn_bare_powers(powers)
```

## Arguments

- powers:

  The list
  [`.jst_formula_bare_powers()`](https://jma61.github.io/jstats/reference/dot-jst_formula_bare_powers.md)
  returned.

## Value

Invisibly NULL.
