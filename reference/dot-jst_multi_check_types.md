# Internal helper: a multiple-response set's items checked against ticked =

A number counted as chosen needs numeric items (labelled, logical or
plain); text needs text items (a factor's levels included). An item of
the other kind stops, named (R62's lean, Session 414: LimeSurvey's
"Other" text column, Q1_other, inside a range of ticked items). Where
the text items each hold one value at most beside their blanks – a box
written "Y" or blank, as LimeSurvey's CSV files write it – the stop
gives the call with that value as ticked =.

## Usage

``` r
.jst_multi_check_types(data, items, ticked, cl, mc)
```

## Arguments

- data:

  The data frame.

- items:

  The items.

- ticked:

  The value counted as chosen.

- cl, mc:

  The call, for the line the stop offers.
