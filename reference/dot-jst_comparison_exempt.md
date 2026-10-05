# Internal helper: the variables a comparison term may read as categories

The categorical-argument guard of
[`.jst_resolve_formula_transforms()`](https://jma61.github.io/jstats/reference/dot-jst_resolve_formula_transforms.md)
refuses a computed term on a variable jstats classifies as Categorical,
because arithmetic on category codes –
[`log()`](https://rdrr.io/r/base/Log.html) of a 1/2/3/4 code – fits a
meaningless predictor without a word (AUDIT-023, Session 172). A
COMPARISON is not arithmetic on codes: `I(Sex == 1)`,
`I(Region %in% c(1, 3))` and `I(Source == "web")` each ask which cases
are in a category and give TRUE or FALSE, which is how
[`lm()`](https://rdrr.io/r/stats/lm.html) reads them. Until Session 342
the guard refused these too, and the only way through was the one it
named, a
[`jnumeric()`](https://jma61.github.io/jstats/reference/jnumeric.md)
registration – on a text variable, a factor or a logical as well, where
the registration did nothing else. When
[`jnumeric()`](https://jma61.github.io/jstats/reference/jnumeric.md)
began refusing those types (the S310 item) that way through closed, and
Jeff ruled that a comparison computes with no registration (Session 342,
the "option 2" ruling; it amends AUDIT-023's rule and follows the S322
ruling that formula names are read as
[`lm()`](https://rdrr.io/r/stats/lm.html) reads them).

## Usage

``` r
.jst_comparison_exempt(e, data)
```

## Arguments

- e:

  A formula term (a call).

- data:

  The analysis data frame.

## Value

Character vector: the variables of `data` the guard should pass over in
this term; empty when the term is not a logical expression of
comparisons.

## Details

The exemption is narrow by construction. The TERM must be a logical
expression and nothing else: comparisons (`==`, `!=`, `%in%`, `<`, `>`,
`<=`, `>=`), joined by `&`, `|` and `!`, inside parentheses or
[`I()`](https://rdrr.io/r/base/AsIs.html). Within it, a variable is
exempt only where it stands BARE as one side of a comparison –
`I(log(Grp) > 1)` still computes from Grp's codes, so Grp is not exempt
there – or bare in a logical position when it is itself a TRUE/FALSE
variable (`I(Flag & Sex == 1)`). An order comparison exempts only a
variable whose values are numbers: `I(Education >= 3)` reads an ordered
code, while `<` on a factor is not meaningful to R and on text is
alphabetical. Any other term – `I((Sex == 1) * Age)`,
`ifelse(Sex == 1, 0, Age)` – exempts nothing, and is refused as before.
