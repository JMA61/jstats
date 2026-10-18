# Internal: jsave's refusal for a declared text value too long for .sav

The S372 item, refused before the write (Slate E5; lean 4, Jeff: "Yes to
all of your recommendations."): the variables and the values, then the
ways out – R format (.rds), which keeps them; the save with every
declared missing value as plain NA (Session 361's offer at every .sav
refusal); jencode(), which makes the variable numbers; or a shorter
value, stated as the requirement (voice Rule X).

## Usage

``` r
.jst_jsave_sav_long_text_error_msg(
  long_text,
  data_name,
  prose_name = data_name,
  stem = data_name,
  pd_line = NULL
)
```

## Arguments

- long_text:

  [`.jst_sav_long_text_codes()`](https://jma61.github.io/jstats/reference/dot-jst_sav_long_text_codes.md)'s
  list.

- data_name:

  The data frame's name, for the lines.

- prose_name:

  The data frame as the sentence names it.

- stem:

  The name the offered file takes.

- pd_line:

  The offered save with `preserve.declarations = FALSE`, or NULL.

## Value

Character(1), a section for
[`.jst_jsave_combined_error_msg()`](https://jma61.github.io/jstats/reference/dot-jst_jsave_combined_error_msg.md).
