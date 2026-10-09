# Internal helper: are interpretive notes printed at this output level?

A diagnostic's brief interpretation – the note under Levene's test, the
lines under a VIF above 10 – is part of the diagnostic output and prints
with it, except at `joutput("minimal")`, the level for a user who wants
the numbers alone (Jeff, Session 346). The 1/2-dichotomy note of
[`jlm()`](https://jma61.github.io/jstats/reference/jlm.md) has been
silent at that level on the same reasoning.

## Usage

``` r
.jst_notes_on()
```

## Value

Logical(1).
