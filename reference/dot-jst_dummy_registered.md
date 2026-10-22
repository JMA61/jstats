# Internal helper: is a variable registered with jdummy()?

TRUE when the dummy store holds a registration for the variable under
the data frame's name – the user's own assertion that it is categorical,
so jdesc() and jcorr() state it ("Region is categorical; ..."), as
jalpha() does, where they had hedged it (Session 391; the (Session 80)
item).

## Usage

``` r
.jst_dummy_registered(data_name, v)
```

## Arguments

- data_name:

  Character(1) or NULL. The data frame's name.

- v:

  Character(1). The variable's name.

## Value

Logical(1).
