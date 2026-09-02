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
.jst_jsave_release_notes(data, data_name, file_arg)
```

## Arguments

- data:

  The data frame as written (post any preserve.declarations collapse, so
  a stripped frame has no evidence and stays silent).

- data_name:

  Character. The frame's display name.

- file_arg:

  Character. The normalized (forward-slash) target path, echoed into the
  resave line. Never the raw file argument: a Windows backslash path
  inside the quoted recipe is a parse error on paste.

## Value

Character scalar note, or `NULL` when nothing fires.
