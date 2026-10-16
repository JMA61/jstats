# Internal: the label sentence under a rename note

Internal: the label sentence under a rename note

## Usage

``` r
.jst_rename_label_line(had, where = "")
```

## Arguments

- had:

  Character vector, one per renamed variable: "own" (it had a label and
  keeps it), "given" (its old name is now its label) or "none" (its old
  name was empty, so it has no label).

- where:

  "" for jload(), " in the file" for jsave().

## Value

Character(1), possibly empty: no sentence when no renamed variable has a
label.
