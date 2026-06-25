# Internal helper: print legends at a specific position (per-table / bottom)

For multi-variable functions (jfreq) where `"legend"` prints under each
variable's own table and `"legend.bottom"` prints once after all tables.
Called at each position; prints only the block(s) whose mode matches
`position`. No lead-in blank: the caller's table already emits a
trailing blank line. Variable-label block first, value-label block
second when both land at the same position; each block's trailing blank
line separates co-located blocks.

## Usage

``` r
.jst_print_legends_at(data, vars_var, vars_val, vlmode, value_mode, position)
```

## Arguments

- data:

  Data frame / label source.

- vars_var:

  Variable names for the variable-label block.

- vars_val:

  Variable names for the value-label block.

- vlmode:

  Resolved variable.id mode.

- value_mode:

  Resolved value.id mode.

- position:

  Either `"legend"` or `"legend.bottom"`.
