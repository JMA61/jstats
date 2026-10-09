# Internal helper: the filters of a call that name a variable

When a variable an analysis needs to vary has one value, and a filter's
condition names that variable, the filter is the cause, and the stop
says so in place of guessing (Session 346; Jeff, on
`jlm(Flourishing ~ SocialSupport + PriorTherapy, subset = PriorTherapy == 1)`:
"the error message doesn't address the real problem"). The filters are
this call's `subset =` and the frame's active
[`jsubset()`](https://jma61.github.io/jstats/reference/jsubset.md)
filter;
[`jcomplete()`](https://jma61.github.io/jstats/reference/jcomplete.md)
keeps cases with values and cannot leave one value of a variable it
names.

## Usage

``` r
.jst_filters_naming(terms, sample_info, data_name)
```

## Arguments

- terms:

  Character vector; the variables or terms that have one value.

- sample_info:

  The list
  [`.jst_build_sample_info()`](https://jma61.github.io/jstats/reference/dot-jst_build_sample_info.md)
  returns.

- data_name:

  Character(1) or `NULL`; the data frame's name.

## Value

A list: `per` and `stored` (logical: does that filter name one of the
terms' variables), their condition texts, and `vars`, the variables the
naming filters name.
