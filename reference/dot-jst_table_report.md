# Internal helper: jtable()'s report

Ruling R57 (Session 406): what a jtable() call prints in place of the
table – for each table, "Table n." and its title, then an indented line
saying what it holds and the page it is on (the page turned, the text
stepped down, long labels wrapped, as the Word file has them); then
where the file went ("Table written to ", "3 tables written to ",
replacing a file that was there), or, when no file was asked for, that
none was written – at joutput("full") with the lines that write the
table and show it. A call that writes built tables adds, at
joutput("full"), the tables that could have been one.

## Usage

``` r
.jst_table_report(
  tables,
  lay,
  path = NULL,
  replaced = FALSE,
  asked = FALSE,
  hint = FALSE,
  how = NULL
)
```

## Arguments

- tables:

  A list of jst_table.

- lay:

  Their layout
  ([`.jst_docx_layout()`](https://jma61.github.io/jstats/reference/dot-jst_docx_layout.md)).

- path:

  The file written, or NULL.

- replaced:

  Logical; the file replaced one that was there.

- asked:

  Logical; the call gave file = (the overwrite gate speaks for a
  declined write).

- hint, how:

  As
  [`.jst_table_finish()`](https://jma61.github.io/jstats/reference/dot-jst_table_finish.md).
