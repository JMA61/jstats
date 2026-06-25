# Internal helper: detect common SPSS-style syntax mistakes in jsubset expressions and provide guidance toward standard R operators.

Catches:

- `=` used where `==` was meant (for equality comparison)

- `AND` / `OR` / `NOT` / `XOR` used as identifiers where `&` / `|` / `!`
  / [`xor()`](https://rdrr.io/r/base/Logic.html) were meant

## Usage

``` r
.jst_check_filter_syntax(raw_expr, expr_str)
```

## Arguments

- raw_expr:

  The unevaluated expression (a language object).

- expr_str:

  The deparsed expression string (for display in errors).
