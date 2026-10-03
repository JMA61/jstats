# Internal helper: print current joutput() status

slots = NULL (the default) prints the FULL panel: the Level line and
every setting – the shape a bare joutput() status query wants, and the
shape a level change wants because a level moves most settings at once.
A character vector of setting names instead prints a PARTIAL panel: the
same red title, only the named lines (no Level line), then one trailing
pointer at the full panel (S332: a setting call echoes what it touched,
not the standing state). Panel order and de-duplication are enforced
here, so callers may pass an unordered set with repeats; unrecognized
names are ignored.

## Usage

``` r
.jst_output_status(slots = NULL)
```
