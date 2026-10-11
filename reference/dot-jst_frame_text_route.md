# Internal: the text route for a whole frame, when it needs one

Five more messages offered the whole-frame jconvert(to = "stata" or
"sas") that stops on a text variable with declared missing values
(Session 352; the S351 item): joptions()'s workspace check, the
convert-first remedy of the marker error a column of SPSS-style missing
values gets, jrecode()'s ambiguous-missing stop and its marker refusal,
and jdeclare_missing()'s note on a setting the variables do not use.
Each asks this helper first: NULL when the plain call runs – a target
that is not "stata" or "sas", or no declared string in the frame – else
[`.jst_text_route()`](https://jma61.github.io/jstats/reference/dot-jst_text_route.md)'s
calls and sentence, the second call kept only when a variable of another
form remains to convert.

## Usage

``` r
.jst_frame_text_route(data, data_name, to, more_lines = FALSE)
```

## Arguments

- data:

  The data frame.

- data_name:

  Its name, for the printed calls.

- to:

  The conversion target.

- more_lines:

  Passed to
  [`.jst_text_route()`](https://jma61.github.io/jstats/reference/dot-jst_text_route.md).

## Value

NULL, or the list
[`.jst_text_route()`](https://jma61.github.io/jstats/reference/dot-jst_text_route.md)
returns.
