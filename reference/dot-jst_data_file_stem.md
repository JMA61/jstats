# Internal helper: the file name a data argument is saved under

The stem of the file in a save or load line built from a call's data
argument. A name gives itself. A place gives its last component when
that is a name – `lst$d`, `lst[["d"]]` and `obj@d` all give `d` – and
the placeholder `mydata` otherwise (a place reached by position,
`lst[[2]]`, or by a computed name). Until Session 342 the registration
note pasted the argument as typed, which gave `jload("lst[["d"]].rds")`.

## Usage

``` r
.jst_data_file_stem(data_sub, data_name)
```

## Arguments

- data_sub:

  The substituted data argument, or `NULL` when the
  [`juse()`](https://jma61.github.io/jstats/reference/juse.md) default
  was used.

- data_name:

  Character(1); the data frame's name as the message prints it.

## Value

Character(1).
