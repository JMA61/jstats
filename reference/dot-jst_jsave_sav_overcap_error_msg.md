# Internal: build jsave's error message for SPSS-form UDM columns that exceed the .sav missing-value limit

SPSS .sav files allow at most three discrete user-defined-missing codes
per variable, or a range plus one discrete code. haven::write_sav()
enforces SPSS's own rule and errors mid-write (leaving a partial file)
on a column carrying more, so jsave()'s .sav pre-flight catches these
first. Because the Stata-side cap is 26 (Decision 4, Session 121),
converting to Stata and saving as .dta is a keep-all route alongside
.rds, so both non-lossy options are offered before the lossy jrecode()
reduction.

## Usage

``` r
.jst_jsave_sav_overcap_error_msg(
  overcap_info,
  data_name,
  text_vars = character(0),
  prose_name = data_name,
  stem = data_name,
  pd_line = NULL
)
```

## Arguments

- overcap_info:

  List of per-variable entries, each a list with `var` (name), `n`
  (count of discrete na_values codes), and `range` (logical: does the
  column also carry an na_range?).

- data_name:

  The data frame's name, used in the suggested fix code.

- text_vars:

  The frame's text variables with declared missing values (Session 351).
  When there are any, the Stata route is not offered: a .dta file cannot
  keep a text variable's declared missing values, so its "also keeping
  all the codes" would be false, and its jconvert() line stops on them
  (the S340 item; Jeff's lean, S351).

- prose_name:

  The data frame as the sentence names it; by default `data_name`.
  jsave() gives the typed expression here when the lines name mydata
  (Session 352).

- stem:

  The name the offered files take; by default `data_name`. Until Session
  352 the data argument as typed, which for an expression gave a file
  name that does not parse.

- pd_line:

  The offered jsave() call with `preserve.declarations = FALSE`,
  indented, or NULL (Session 361, the S218 item): the save that makes
  every declared missing value plain NA in the file, offered beside the
  conversion.

## Value

Character scalar suitable as a `.jst_jsave_combined_error_msg` section
(no `jsave():` prefix; that is added on emission).
