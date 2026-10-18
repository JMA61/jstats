# Internal helper: a single-column call in the data-first form

`jdesc(d$Age, subset = zw == 1)` becomes
`jdesc(d, Age, subset = zw == 1)`: the frame first, the variable after
it, every other argument kept. Only for a call whose first unnamed
argument is `<data_name>$<name>`; any other call is returned as it came
(Session 374).

## Usage

``` r
.jst_data_first_form(call, data_name)
```

## Arguments

- call:

  The user's call.

- data_name:

  Character; the data frame's name.

## Value

The call.
