# Internal: the convention = argument, lowercased and checked

Platform specs are case-insensitive ("SPSS", "Stata" ...); anything but
one of "spss", "stata" or "sas" stops in the choice-error form. Called
when convention is not NULL. jrecode(), jencode(), jdeclare_missing()
and its text path each held this block (Session 386, the twin build);
joptions() keeps its own, which offers the nearest value.

## Usage

``` r
.jst_convention_arg(convention)
```

## Arguments

- convention:

  The call's convention argument (not NULL).

## Value

The convention, lowercased.
