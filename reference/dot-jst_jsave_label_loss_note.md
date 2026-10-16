# Internal: build the label / missing-value loss note for Excel and CSV saves

Excel and CSV cannot store variable labels, value labels, or
missing-value declarations. jsave emits a note after a successful write
to these formats describing what was (or, under
`preserve.declarations = FALSE`, would have been) lost. The wording
depends on which missing-value form the frame carried and on whether
`preserve.declarations = FALSE` blanked the codes.

## Usage

``` r
.jst_jsave_label_loss_note(
  ext,
  spss_vars,
  stata_vars,
  preserve.declarations,
  n_blanked,
  text_udm = FALSE,
  data = NULL,
  code_name = NULL,
  path = NULL
)
```

## Arguments

- ext:

  Lowercase target extension, `"xlsx"` or `"csv"`.

- spss_vars:

  Character vector of SPSS-form UDM variable names, as detected before
  any collapse.

- stata_vars:

  Character vector of Stata-form tagged-NA variable names, as detected
  before any collapse.

- preserve.declarations:

  Logical, the value passed to jsave.

- n_blanked:

  Integer count of SPSS-style code cells blanked when
  `preserve.declarations = FALSE`; zero otherwise.

- text_udm:

  Logical: is one of `spss_vars` a text variable? Its declared codes are
  words, so "ordinary numbers" becomes "ordinary values" (Session 351,
  the S340 item's rider).

- data:

  The data frame as given, before any collapse: its labels and
  declarations.

- code_name:

  Character; the data as the printed line names it (`mydata` for an
  expression, whose line the caller opens with "mydata \<- ...").

- path:

  Character; the path written, normalized.

## Value

A single message string, or `NULL` if no note applies.

## Details

Since Session 359 (the S357 item, Jeff's walk of
missing_convention_walk.R Section 30) the note says only what the frame
had to lose and names what the package knows:

- The first line names labels only when a variable carries a variable
  label or value labels (the registration note's rule: it fires only on
  registrations), and missing-value metadata only when a variable
  declares missing values. A frame with neither gets no note.

- SPSS-style codes write as literal numbers. The variables and the
  declared codes their cells hold are named – "Income's declared missing
  value -99 is written as an ordinary number and will read back as valid
  data." – where the note said "Any SPSS-style missing values (e.g.
  -99)". A declared code no cell holds writes nothing, and is not named.

- The way to write them as empty cells is the jsave() call to run, with
  the data's name and the path just written, where the note gave
  "jsave(..., preserve.declarations = FALSE)", which does not run as
  printed (the S343 rule).

- Stata-style missing values write as blank cells; the distinction
  between them is not preserved.

- `preserve.declarations = FALSE` that blanked SPSS-style codes: a
  confirmation giving the count of blanked cells.

The note is a loss-of-fidelity warning per the locked jsave design; it
is not gated to the joutput verbosity tiers.
