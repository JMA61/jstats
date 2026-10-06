# Internal helper: the choose-first menu, for a remedy that says "declare it"

Several notes and one error close by telling the reader to declare a
value with
[`jdeclare_missing()`](https://jma61.github.io/jstats/reference/jdeclare_missing.md).
With no missing-value convention selected that call stops at the
choose-first gate, so the advice led to a second message – the round
trip Session 250 rejected for the D1 note, which has carried the gate's
own menu since. This helper gives the other sites the same menu (Session
345; the S251 item): the text to place before the remedy, or `NULL` when
a convention is selected or `plain` is FALSE.

## Usage

``` r
.jst_declare_gate_lead(fn, n = 1L, plain = TRUE)
```

## Arguments

- fn:

  The exported caller's name (the menu builder's signature).

- n:

  How many values the remedy names; picks "value" or "values".

- plain:

  FALSE when the variable to declare on already carries declared missing
  values of either form:
  [`jdeclare_missing()`](https://jma61.github.io/jstats/reference/jdeclare_missing.md)
  follows the variable's own form there and meets no gate.

## Value

Character scalar ending without a newline, or `NULL`.

## Details

Reads the SETTING only. A per-call `convention =` on the call that
printed the note does not travel to the
[`jdeclare_missing()`](https://jma61.github.io/jstats/reference/jdeclare_missing.md)
call the reader types next.
