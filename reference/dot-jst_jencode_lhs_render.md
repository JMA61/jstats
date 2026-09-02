# Internal helper: render a text map's left-hand side

The left-hand-side renderer
[`jencode()`](https://jma61.github.io/jstats/reference/jencode.md) hands
to
[`.jst_render_map_string()`](https://jma61.github.io/jstats/reference/dot-jst_render_map_string.md)
when the word-evidence nudge shows the user a map built from values
found in their own column. (It also fed the cross-convention echo-back
until S246, when that echo-back was retired under Rule Y.) Words render
as themselves, quoted when they contain a map separator; the empty
string renders as the taught `blank` token rather than as a pair of
quotes, since the quotes-around-nothing form is deliberately never shown
to users.

## Usage

``` r
.jst_jencode_lhs_render(old_vals)
```

## Arguments

- old_vals:

  Character vector of old values from one parsed rule.

## Value

Character scalar: the rule's left-hand side.
