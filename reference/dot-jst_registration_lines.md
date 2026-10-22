# Internal helper: the calls that make a data frame's registrations again

For jload()'s note when a reload clears the registrations set this
session (Session 391; the (Session 114) item): the numeric, count and
Likert registrations as one jnumeric(), jcount() or jlikert() line each,
naming their variables, and the dummy registrations as jdummy() lines –
those whose reference the default rule chose in one line, each named
reference in a line of its own with ref = (the data's code for a
labelled or numeric variable, the category itself, in quotes, for text
or a factor; a registration restored from an older file, which does not
record how its reference was chosen, names it too). Only variables the
loaded data holds are named, so each line runs; a name R reads only in
backticks gets them.

## Usage

``` r
.jst_registration_lines(obj_name, reg, dummy, cols)
```

## Arguments

- obj_name:

  Character(1). The data frame's name.

- reg:

  The intent registry (.jst_get_registry()), or NULL.

- dummy:

  The dummy registrations (.jst_get_dummy()), or NULL.

- cols:

  Character. The loaded data's variable names.

## Value

Character, the lines without their indent; empty when none.
