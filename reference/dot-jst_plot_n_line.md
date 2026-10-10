# Internal helper: print a plot's one-line N statement

A plot draws the cases that have a value on every variable it plots –
each builder keeps the complete cases of its columns – after the
pipeline's filters. Until Session 349 jplot() said nothing of the cases
it left out (the S316 item): under `jsubset(clinic, Condition != 3)` a
grouped histogram of Flourishing by Medication printed only its title,
where [`jt()`](https://jma61.github.io/jstats/reference/jt.md) on the
same data states Analysis N 51. The statement is the listwise layout's N
line (the CPS reference, Table 4), in the slot it takes there – under
the title and the notes, one blank line before and one after – with the
excluded count beside it whenever the plot drew fewer cases than the
data frame holds: "Analysis N: 51 (19 Excluded)". It is the only Case
Processing a plot prints, at every output level (Jeff's lean, okayed
S336: the N statement, not the table).

## Usage

``` r
.jst_plot_n_line(data, vars, n_original)
```

## Arguments

- data:

  The frame the plot is drawn from, after the pipeline.

- vars:

  Character; the variables the plot draws, its `by` variable included.

- n_original:

  Integer; the data frame's rows before the pipeline.

## Value

`invisible(NULL)`; prints the line.
