# Internal helper: a workspace vector holding one value per case of the frame

Finds, in a filter condition, a workspace vector that holds one value
for each case of the data frame AS GIVEN when the condition is about to
run on fewer cases: behind an active
[`jcomplete()`](https://jma61.github.io/jstats/reference/jcomplete.md)
(a stored
[`jsubset()`](https://jma61.github.io/jstats/reference/jsubset.md)
filter), or behind either stored setting (a per-call `subset =`). Such a
vector lines up with the frame the user sees and with nothing the
condition is evaluated on, and until Session 331 only the comparison of
one with a labelled variable said so (the Session 330
add-it-to-the-frame form, reached when the evaluation fails): compared
with a plain variable, or with a constant (`keep12 == TRUE`), the result
is simply too long, and the shape check answered "has 12 values for 11
rows" for a frame the user had removed nothing from. Asked BEFORE the
evaluation, so every such condition gets the one message. The operand is
looked up, never run
([`.jst_recycled_operand()`](https://jma61.github.io/jstats/reference/dot-jst_recycled_operand.md)'s
rule); a bare name as the whole condition, which that walker does not
visit, is looked up here.

## Usage

``` r
.jst_frame_vector(expr, data, envir, n_frame)
```

## Arguments

- expr:

  The unevaluated filter.

- data:

  The data the filter is about to be evaluated on.

- envir:

  The environment its other names resolve in.

- n_frame:

  Integer or NULL. The frame's row count as given.

## Value

NULL when the data has not been cut or there is no such vector;
otherwise a
[`.jst_recycled_operand()`](https://jma61.github.io/jstats/reference/dot-jst_recycled_operand.md)-shaped
list.
