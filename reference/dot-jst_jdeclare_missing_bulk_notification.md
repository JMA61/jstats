# Internal: consolidated notification for a multi-variable jdeclare_missing call

One summary block instead of one block per column: a bulk call on 52
variables must not print 52 near-identical notices. Variables are
grouped by resulting branch (a single call CAN split branches – e.g.
numeric codes applied under an active SPSS convention across a frame
where some columns already carry Stata-form markers: the marked columns
resolve to conversion while plain columns resolve to an SPSS-style
declaration), each group gets one header plus one body block (the
declaration is identical within a group by construction), and the
durability note is returned apart from the blocks.

Returns `list(block = , tail = )`, as the single-variable builder does:
`tail` is the durability reminder, `NULL` at the minimal tier and when
no group changed anything.

## Usage

``` r
.jst_jdeclare_missing_bulk_notification(
  data_name,
  target_vars,
  results,
  modify = FALSE,
  data_kind = "name",
  scaffold_var = paste(target_vars, collapse = ", ")
)
```

## Arguments

- scaffold_var:

  The text standing for the call's variables in the reminder's two lines
  ([`.jst_scaffold_vars()`](https://jma61.github.io/jstats/reference/dot-jst_scaffold_vars.md);
  S339).
