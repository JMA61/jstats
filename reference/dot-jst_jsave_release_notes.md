# Internal helper: jsave's undeclared-stray release note

The RELEASE-side note of the S239 mint/observe/release framework:
[`jsave()`](https://jma61.github.io/jstats/reference/jsave.md) is the
boundary past which the package can no longer reach the data, so an
undeclared suspicious code written to a declaration-carrying format is
reported ONCE, when the frame's own metadata supplies the evidence.
Fires only when all three hold: the target format carries declarations
(gated at the call site); another column declares missing values in the
same style (SPSS-form numeric declarations – tag-form columns are
self-declaring, so no undeclared-tag state exists and tags do not
testify about numeric strays); and an undeclared suspicious code sits on
a column. Silent when the frame declares nothing anywhere (the
pure-guess case). Groups by column when codes differ; the remedy is a
runnable declare-then-resave pair.

## Usage

``` r
.jst_jsave_release_notes(
  data,
  data_name,
  file_arg,
  code_name = data_name,
  assign_line = NULL,
  clean_names = FALSE
)
```

## Arguments

- data:

  The data frame as written (post any preserve.declarations collapse, so
  a stripped frame has no evidence and stays silent), carrying the data
  frame's own variable names.

- data_name:

  Character. The frame's display name.

- file_arg:

  Character. The normalized (forward-slash) target path, echoed into the
  resave line. Never the raw file argument: a Windows backslash path
  inside the quoted recipe is a parse error on paste.

- code_name:

  Character. The data frame as the lines name it: `data_name`, or mydata
  for data given as an expression.

- assign_line:

  Character(1) or NULL: the line that makes mydata,
  `" mydata <- <the expression>"`, first in the block.

- clean_names:

  Logical: the call's `clean.names`, kept in the save line.

## Value

Character scalar note, or `NULL` when nothing fires.

## Details

Since Session 388 (Fix Slate 27; printed calls run, S343) the lines run
as printed after every save that gives the note. After clean.names =
TRUE the note names the data frame's own variable, which jsave() passes
in place of the file's name – the declare line named the file's name,
which the data frame does not hold – and the save line keeps clean.names
= TRUE, without which it stopped on the names. A name that R reads only
in backticks gets them. Given an expression as the data, the lines name
mydata after the line that makes it, the S339 form, where both had named
the expression: modify = TRUE stopped on it, and the save wrote the
unchanged data again.
