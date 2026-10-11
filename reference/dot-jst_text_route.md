# Internal: the route to Stata-style or SAS-style missing values for a frame holding text variables with declared missing values

A marker is a kind of NA in a NUMERIC variable, so jconvert() refuses a
text variable with declared missing values under to = "stata" or "sas"
(Session 340), and every message that offered the whole-frame conversion
printed a call that stopped (the S340 item, built Session 351). What
runs: the text variables' declared values made plain NA, then the frame
converted – the order matters, since the conversion refuses while a
declared string remains – with one sentence naming what the first line
does. The load narrative's Case 1 line takes to = "baseR" for the same
reason (v0.9.214).

## Usage

``` r
.jst_text_route(
  data_name,
  to,
  text_vars,
  convert_rest = TRUE,
  more_lines = FALSE,
  rest_vars = NULL
)
```

## Arguments

- data_name:

  The data frame's name, for the printed calls.

- to:

  "stata" or "sas".

- text_vars:

  The text variables with declared missing values.

- convert_rest:

  Logical: does a variable remain for the second call to convert? FALSE
  leaves the first call alone, its sentence saying "this" for "the first
  line".

- more_lines:

  Logical: will the caller print a line after these calls (the
  joptions() rider)? Then the sentence says "the first line" even when
  there is one call.

- rest_vars:

  Optional: the variables the second call converts, as its vars =
  (Session 352, jdeclare_missing()'s align line); NULL converts the
  frame.

## Value

A list: `calls`, the indented call lines; `note`, the sentence.
