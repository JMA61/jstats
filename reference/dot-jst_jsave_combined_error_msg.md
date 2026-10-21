# Internal: assemble jsave's combined pre-flight error

jsave runs two independent pre-flight checks for the ReadStat formats
(.sav/.dta/.xpt): one for column types the format cannot store, one for
missing-value codes it cannot represent. When more than one fires on a
single save, this helper frames the individual messages (each already
built and tier-formatted by its own `.jst_jsave_*_error_msg()` helper)
into one numbered error, so the user fixes everything and re-runs once
rather than discovering the second problem only after fixing the first.
A single firing is returned unchanged, so single-issue saves are
byte-for- byte identical to the pre-accumulation behavior.

## Usage

``` r
.jst_jsave_combined_error_msg(
  sections,
  data_name,
  ext,
  assign_line = NULL,
  save_line = NULL,
  copy_of = "your data",
  save_name = "mydata"
)
```

## Arguments

- sections:

  List of pre-built section messages, one per fired check.

- data_name:

  Character. The data frame's name, for the header.

- ext:

  Lowercase target extension ("sav", "dta", "xpt").

- assign_line:

  Character(1) or NULL: " mydata \<- ", for data given as an expression.

- save_line:

  Character(1) or NULL: the jsave() line that closes the message – on
  mydata for data given as an expression, on the data frame's own name
  or place when a part names refused variables.

- copy_of:

  Character(1): what the copy is made from, "your d data frame" when the
  expression names one data frame, else "your data".

- save_name:

  Character(1): what the closing line says it saves, "mydata" or the
  data frame's name or place.

## Value

Character scalar suitable for `stop(call. = FALSE)`.

## Details

Given an expression as the data (ruling S386, the (S384) item), the line
that makes mydata comes once, under the header, so the parts' lines run
top to bottom on one copy – each part repeating it had undone the parts
above – and the closing line names the save that works on it, since the
expression run again stops as before.

Given a name or a place, the message closes on "run jsave() again"
unless a part names variables the format refuses: then the call as typed
would stop on them, and the closing line is the save that works, with
clean.names = TRUE (ruling R33, Session 387).
