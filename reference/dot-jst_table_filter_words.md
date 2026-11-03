# Internal helper: one filter condition, in words

A comparison of a variable with a value is written with the variable's
label and the mathematical sign – "Age (years) \>= 30", the sign the
character itself – and a code compared by ==, != or %in% as its value
label ("Current smoker = No", "Region of residence = North or East"); &
and \| are "and" and "or", with parentheses where the two mix. A
condition it cannot put into words – a function of a variable, a
workspace object, a name that is not a variable of the data – is written
as typed.

## Usage

``` r
.jst_table_filter_words(cond, data = NULL, minus = "true")
```

## Arguments

- cond:

  Character(1); the condition as the result stores it.

- data:

  The data frame it was applied to, for the labels; NULL writes the
  condition as typed.

- minus:

  The style's minus setting, for a negative value.

## Value

A list: text, and or (logical: the condition's top level is an or, which
takes parentheses beside another condition).
