# Internal helper: open a written file, when open = TRUE asks

Only in an interactive session (open = TRUE in a script, a rendered page
or a check opens nothing), with
[`utils::browseURL()`](https://rdrr.io/r/utils/browseURL.html), which
hands the file to the program the computer opens .docx files with. The
opener and the session test are arguments so a battery can stand in for
both and open nothing.

## Usage

``` r
.jst_table_open(path, open, ask = interactive(), browse = utils::browseURL)
```

## Arguments

- path:

  The file.

- open:

  Logical.

- ask:

  Logical; whether the session is interactive.

- browse:

  The function that opens the file.

## Value

TRUE when the file was handed to the opener, invisibly.

## Details

A computer with no program set for .docx files makes the opener fail (on
Windows, shell.exec()'s error; elsewhere, no browser set): the error and
any warning are caught and a note says the file was written and no
program opened it, so the call still returns its table (the (S410) item,
Session 414, on its lean's default).
