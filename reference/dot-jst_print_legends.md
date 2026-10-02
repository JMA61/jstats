# Internal helper: print variable- and value-label legends (single position)

For single-table functions (jt, jaov, jcrosstab) and grouped jdesc,
where both `"legend"` and `"legend.bottom"` resolve to the same place –
after the table. Emits one lead-in blank line when a block prints, then
the variable-label block first and the value-label block second (the
Session 60 ordering lock). Each block supplies its own trailing blank
line, so co-located blocks are separated by exactly one blank line. The
two blocks can document different variable sets (e.g. jt's variable
legend covers DV + group, but only the group carries the value.id
legend).

## Usage

``` r
.jst_print_legends(data, vars_var, vars_val, vlmode, value_mode, lead = TRUE)
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

- lead:

  Logical. Emit the lead-in blank line. Default TRUE. Pass FALSE when
  the caller's preceding output already supplies a trailing blank line
  (e.g. grouped jdesc, where the last group table emits one).

## Value

Invisibly, TRUE when at least one block printed (the output now ends on
a blank line) and FALSE when nothing printed.

## Details

Since Session 328 the lead-in blank line prints only when a block does
(a legend mode with no labelled variable printed a lone blank line), and
the helper reports whether anything printed, so the caller can end its
output on exactly one blank line: a printed block already ends on one.
