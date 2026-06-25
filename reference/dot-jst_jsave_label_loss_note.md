# Internal: build the label / missing-value loss note for Excel and CSV saves

Excel and CSV cannot store variable labels, value labels, or
missing-value declarations. jsave emits a note after a successful write
to these formats describing what was (or, under `preserve.udm = FALSE`,
would have been) lost. The wording depends on which missing-value form
the frame carried and on whether `preserve.udm = FALSE` blanked the
codes.

## Usage

``` r
.jst_jsave_label_loss_note(ext, spss_vars, stata_vars, preserve.udm, n_blanked)
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

- preserve.udm:

  Logical, the value passed to jsave.

- n_blanked:

  Integer count of SPSS-style code cells blanked when
  `preserve.udm = FALSE`; zero otherwise.

## Value

A single message string, or `NULL` if no note applies.

## Details

Branching (SPSS-style codes write as literal numbers, while Stata-style
tagged NAs write as blank cells):

- `preserve.udm = FALSE` and SPSS-style codes were blanked: a
  confirmation giving the count of blanked cells.

- both forms present (`preserve.udm = TRUE`): a generic note that names
  neither platform, plus the `preserve.udm = FALSE` suggestion.

- SPSS-style only: the literal-numbers warning plus the suggestion.

- Stata-style only: a brief note that the tags write as blank cells and
  the distinction between them is not preserved.

- neither: a plain labels-only note.

The note is a loss-of-fidelity warning per the locked jsave design; it
is not gated to the joutput verbosity tiers.
