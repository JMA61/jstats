# Internal helper: the overwrite question, the file, and the report

What every jtable() call does once its tables are built (Session 406,
ruling R57): the overwrite question (after every check that can stop the
call), the file written, then the report – each table's number, title,
contents and page, and where the file went – printed unless print =
FALSE or the level is silent; the replica of a table prints only with
print(). Then the file opened, under open = TRUE.

## Usage

``` r
.jst_table_finish(
  tables,
  style,
  out_path,
  overwrite,
  open,
  print,
  landscape = NULL,
  hint = FALSE,
  how = NULL
)
```

## Arguments

- tables:

  A list of jst_table.

- style:

  The document's style.

- out_path:

  The file to write, or NULL.

- overwrite, open, print:

  The call's.

- landscape:

  The writing call's page setting, or NULL.

- hint:

  Logical; TRUE for a call that writes built tables, whose report
  carries the combining hint at joutput("full").

- how:

  NULL, or two lines for a call that writes no file: the call with file
  = added, and the call as typed (offered at joutput("full")).

## Value

TRUE when the file was written, invisibly.
