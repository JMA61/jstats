# Internal helper: note that registrations are not kept in a non-rds format

Builds the loss-of-fidelity note emitted when a frame that has active
classification registrations is saved to a format other than R native
format (.rds). Parallels the label and missing-value loss notes: the
data write succeeds, but the registrations are dropped because only the
.rds format carries them. Returns NULL when the frame has no
registrations, so the note fires only when there is something to lose.

## Usage

``` r
.jst_jsave_registration_loss_note(ext, data_name)
```

## Arguments

- ext:

  The (lower-case) target file extension.

- data_name:

  Character string giving the data frame name to look up.

## Value

A character note, or NULL when the frame has no registrations.
