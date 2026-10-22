# Internal helper: a convention gate's line when dropping convention = would meet a marker the variable carries

Session 389 (Fix Slate 28; the remedy-line audit's finding B).
jdeclare_missing()'s two convention gates – a column of one form given
another convention for the call ("To follow the column's form, drop
convention = ..."), and a column carrying both forms given convention =
"spss" under a stata or sas setting ("To use the setting, drop
convention = ...") – offered the call without convention =, which turns
the codes into markers from the start of the alphabet. On a variable
already carrying those markers that line stopped at the marker-collision
refusal (S345): a remedy leading to another stop. Ruling R8's rule for
an offered declaration (Session 352) applies: what runs is the codes
sent to markers the variable does not use, in a new variable
([`.jst_marker_recode_line()`](https://jma61.github.io/jstats/reference/dot-jst_marker_recode_line.md)).
The test is the refusal's own – the first letters of the convention's
alphabet, in its case, against the markers the cells and the value
labels carry – read under the convention the call without convention =
resolves, which a variable of both forms takes from the setting
([`.jst_marker_clash()`](https://jma61.github.io/jstats/reference/dot-jst_marker_clash.md)
reads the variable's own form only). Given an expression as the data,
the line that makes mydata comes first (the S343 rule). A call the gates
cannot echo – named codes, a labels string – gets the same line, each
code's label carried to its marker: its fallback, "drop convention = ...
from the call.", led to the same refusal.

## Usage

``` r
.jst_gate_marker_route(
  col,
  codes,
  conv,
  data_name,
  data_kind,
  vn,
  lead,
  labels = NULL
)
```

## Arguments

- col:

  The variable.

- codes:

  The call's numeric codes.

- conv:

  "stata" or "sas": the convention the call would resolve without its
  convention = argument.

- data_name, data_kind:

  The data argument as the call gave it, and what kind it is
  ([`.jst_data_arg_kind()`](https://jma61.github.io/jstats/reference/dot-jst_data_arg_kind.md)).

- vn:

  The variable's name.

- lead:

  Character(1); the sentence's opening, "To follow the column's form" or
  "To use the setting".

- labels:

  Optional character vector parallel to `codes`: the label the call gave
  each code ("" for none).

## Value

Character(1), the sentence and its lines, ending in a newline; NULL when
the call without convention = runs as offered, or when too few letters
are free.
