# Internal helper: classify a variable for descriptive summarization

Single source of truth for
[`jdesc()`](https://jma61.github.io/jstats/reference/jdesc.md)'s
decision about whether a variable can be summarized with descriptive
statistics (Min/Max/Mean/SD) and, if so, how it is coerced to numeric.
Used by both the ungrouped and the by-group paths so the two cannot
drift apart.

## Usage

``` r
.jst_classify_desc_var(x, var_name)
```

## Arguments

- x:

  A single variable (vector / data-frame column).

- var_name:

  The variable's name, used to build messages.

## Value

A list with elements `summarisable` (logical), `num` (numeric vector
ready to summarize, or NULL), `note` (an informational message to emit
even though the variable is summarized, or NULL), and `refusal` (the
message explaining why the variable cannot be summarized, or NULL).

## Details

Summarized: plain numeric, haven-labelled (numeric underlying), logical
(as 0/1), factors whose levels are numeric, and character columns whose
values are numbers stored as text (a note is attached in that case).
Refused: factors with text categories, character columns that are true
text, date/time variables (`Date`, `POSIXct`, `POSIXlt`, `difftime`),
and any other type (list, complex, raw).
