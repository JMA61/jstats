# Internal helper: the stop for a data frame named with no variable

jrecode(d), jencode(d) and jrelabel(d) – or the same under a juse()
default with no variable – reached the blank-name guard of
[`.jst_check_vars()`](https://jma61.github.io/jstats/reference/dot-jst_check_vars.md)
and were told "Variable names cannot be blank. / Check for a stray comma
or period in the call." (the S369 item). They now say what is missing
and give the function's own example, as jdesc() and jfreq() have since
Session 338: "no variable specified." / "Provide the variable to recode,
for example:" and the line on community. jdeclare_missing(d) gives the
same form, its line on community, then `extra` (its vars = names()
line). Session 370, Fix Slate 18.

## Usage

``` r
.jst_no_var_stop(fn, extra = NULL)
```

## Arguments

- fn:

  Character. The function's name.

- extra:

  Character or NULL. Text that follows the example, starting with its
  own newline.

## Value

Does not return; stops.
