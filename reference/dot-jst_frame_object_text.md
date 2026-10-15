# Internal helper: what is said of a workspace object standing in for a variable

Ruling R19's one message, for every site that finds one
([`.jst_frame_object()`](https://jma61.github.io/jstats/reference/dot-jst_frame_object.md)):
the formula functions, jcrosstab() and jplot()'s formula path, a filter
typed in the call or with jsubset(), and a stored filter. Its lines,
each sentence on one:


    In I(Age * w), w is not in the d data frame; it is a separate object
    in your workspace.
    jstats analyzes the variables of a data frame.
    Add it to the data frame first:
      d$w <- w
      jlm(Score ~ I(Age * w), data = d)

An object reached with `$` or `[[` is added under its last name, the
term naming that column ("then name the column"); a name the frame
already has takes the next free one (G2). The lines are given when the
object holds one value per row of the frame as given and the frame's
name can be typed; the call when the user's call is in hand (none for a
stored filter, whose condition reads the new column as it stands). An
object holding one value per case left after filtering cannot be added
as it is, and gets its count and the requirement instead.

## Usage

``` r
.jst_frame_object_text(rec, typed, data, data_name, n_frame, call = NULL)
```

## Arguments

- rec:

  A
  [`.jst_frame_object()`](https://jma61.github.io/jstats/reference/dot-jst_frame_object.md)
  result.

- typed:

  Character; the term or condition as typed, or NULL when it is the
  operand itself.

- data:

  The data frame (its names; the add line's free name).

- data_name:

  Character or NULL; the data frame's name.

- n_frame:

  Integer; the frame's row count as given.

- call:

  The user's call, or NULL.

## Value

A list of `lead` (the first sentence, without "In ...") and `lines`
(every line, the first included).
