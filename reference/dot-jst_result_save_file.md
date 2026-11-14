# Internal helper: the file a saved result or a built table is saved in

Session 429 (reversing Session 406's stop, which gave base R's saveRDS()
and readRDS() lines; Jeff: "Let's reverse the decision and incorporate
the rest of your ideas"). jsave() keeps a saved result – what an
analysis function returns – or a table jtable() built in R format
(.rds), the one format that holds any R object. The file name is
optional: jsave(m1) names the file for the object, m1.rds (a place,
lst\$m1, for its last part); a name with no extension gets .rds, as a
data frame's does, and so does one whose ending is no file format's
(model.1, so that jload("model.1") finds model.1.rds). The checks run
before anything is written, in this order, each a stop whose line runs:

- a file name typed without its quotes: ruling R18's pointer
  (.jst_free_text_arg(), .jst_bare_path_stop());

- a file name that is not text;

- an object with no name of its own – a result made in the call, a place
  reached by position – and no file name: the call with one;

- another file format: only R format holds one, with the save in R
  format – a table, or a .docx file named, first offered the jtable()
  line that writes Word;

- an input only a data frame takes (preserve.declarations =, clean.names
  =): the call without it.

## Usage

``` r
.jst_result_save_file(
  data_sub,
  val,
  file_sub,
  file_fn,
  env,
  cl,
  mc,
  overwrite,
  data_only
)
```

## Arguments

- data_sub:

  The data argument as typed.

- val:

  Its value, a saved result or a built table.

- file_sub:

  The file argument as typed, or NULL.

- file_fn:

  A function forcing the file argument, or NULL; called only after the
  unquoted-name checks, so a bare word never reaches R.

- env:

  The caller's environment.

- cl, mc:

  The call as typed and the matched call.

- overwrite:

  The call's overwrite =.

- data_only:

  The data-frame inputs the call gave, as "name =".

## Value

A list: `file` (the name to save under, ending .rds), `name` (what the
Saved line calls it), `noun` (what it is, in words) and `load` (the line
that loads it back).
