# Internal helper: the convention argument a printed marker line needs

A jrecode() call that maps a value to a lettered marker resolves its
convention from the call, then the setting: under no setting it stops at
the choose-first gate, under "spss" at the cross-convention error. A
line the package prints for a variable whose own form is Stata-style or
SAS-style – read from the variable, as jdeclare_missing() reads it –
therefore carries that convention unless the setting is already it
(Session 352; ruling R8's offered lines, and the two lines of
jdeclare_missing()'s marker refusal, which stopped under an unset or
spss setting since v0.9.218).

## Usage

``` r
.jst_marker_conv_arg(conv)
```

## Arguments

- conv:

  "stata" or "sas": the variable's form.

## Value

Character(1): "" or `, convention = "<conv>"`.
