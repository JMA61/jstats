# Internal helper: a call on a place, assigned back to it

The line that runs for a call given `modify = TRUE` on a place such as
`lst$d`, which modify cannot change: the call as typed, without its
modify argument, assigned to the place –
`lst$d <- jdeclare_missing(lst$d, W, codes = -99)` (Session 352; the
S345 item). The form
[`.jst_place_lines()`](https://jma61.github.io/jstats/reference/dot-jst_place_lines.md)
gives an offered line since Session 345, here for the call the user
typed.

## Usage

``` r
.jst_place_assign_line(call, place)
```

## Arguments

- call:

  The call as made, from
  [`sys.call()`](https://rdrr.io/r/base/sys.parent.html) in the exported
  function.

- place:

  The data argument as typed, a place.

## Value

Character(1): one indented line.
