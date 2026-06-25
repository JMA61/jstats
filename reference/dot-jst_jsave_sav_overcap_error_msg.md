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
.jst_jsave_sav_overcap_error_msg(overcap_info, data_name)
```

## Arguments

- overcap_info:

  List of per-variable entries, each a list with `var` (name), `n`
  (count of discrete na_values codes), and `range` (logical: does the
  column also carry an na_range?).

- data_name:

  The data frame's name, used in the suggested fix code.

## Value

Character scalar suitable as a `.jst_jsave_combined_error_msg` section
(no `jsave():` prefix; that is added on emission).
