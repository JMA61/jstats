# Internal helper: numbers given as a text variable's codes, quoted

The line to run when numbers were given for a text variable (ruling
R26's lean 1): the same call on that variable with each number in
quotes, its labels string as typed (a labels string is already text),
and missing.notice = FALSE and modify = TRUE kept. A marker becomes its
spelling (".a"); convention = and range = are left out, since a text
variable takes neither.

## Usage

``` r
.jst_jdeclare_text_quoted_line(
  data_name,
  vn,
  codes,
  labels,
  modify,
  missing.notice
)
```

## Arguments

- data_name:

  The data frame's name as the call gave it.

- vn:

  The variable.

- codes:

  The codes as parsed (numeric), or NULL.

- labels:

  The labels string, or NULL.

- modify, missing.notice:

  The call's flags.

## Value

Character(1), indented two spaces.
