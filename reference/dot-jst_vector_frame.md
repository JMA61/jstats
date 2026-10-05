# Internal helper: wrap a bare column for the vector-input path

Builds the one-column data frame that jdesc(), jfreq() and jscreen()
analyze when given a bare column, as in `jdesc(community$Age)`, plus the
names their messages use: the column as typed, the variable name, and
the frame it came from. A column of a data frame (the resolver's
`first_arg_frame`, Session 324) takes both names from that frame, so
`d[["Age"]]` reads as Age from d, and is marked `in_frame` for
[`.jst_vector_recurse()`](https://jma61.github.io/jstats/reference/dot-jst_vector_recurse.md).

## Usage

``` r
.jst_vector_frame(arg1)
```

## Arguments

- arg1:

  The
  [`.jst_resolve_first_arg()`](https://jma61.github.io/jstats/reference/dot-jst_resolve_first_arg.md)
  result, mode `vector_input`.

## Value

A list with `frame`, `typed`, `var`, `frame_nm`, `in_frame` and
`computed`.

## Details

Anything else is read by its SHAPE (Session 342; the S338 item). A place
ending in a name – `lst$d$Sex`, a data frame held in a list – is named
for that last part, with the rest as its frame. A plain name (`x`) is
named for itself, with the placeholder frame MyData. A COMPUTED vector –
`d$Sex[d$Age > 40]`, `log(d$Age)`, `c(1, 2, 3)` – is named with the
expression as typed and marked `computed`: until then the name was
whatever followed the last dollar sign of the text, so those two tables
were titled "Age \> 40\]" and "Age)", and the fix line built from the
same split read `jfreq(d$Sex[d, Age > 40], Grp)`. A computed vector has
no data frame to name in a fix line, so
[`.jst_vector_recurse()`](https://jma61.github.io/jstats/reference/dot-jst_vector_recurse.md)
gives it the sentence without one.
