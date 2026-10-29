# Internal helper: the overwrite question before jtable() writes

After every check that can stop the call (ruling R42's form, as
jsave()'s): a file that exists and overwrite = FALSE is a question where
the session can ask, and a stop with both ways out where it cannot. A
folder R cannot write to stops first.

## Usage

``` r
.jst_table_overwrite_gate(
  out_path,
  overwrite,
  ask = interactive(),
  fn = "jtable",
  noun = "table"
)
```

## Arguments

- out_path:

  The path.

- overwrite:

  Logical.

- ask:

  Logical; whether the session can ask (interactive()).

- fn:

  The user-facing function's name (jtable, jstyle).

- noun:

  What the call writes, for the kept-file note.

## Value

TRUE when the write may go ahead, FALSE when the question was answered
no (a note says the file was kept); stops where the session cannot ask.
