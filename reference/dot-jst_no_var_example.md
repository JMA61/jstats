# Internal helper: the example a recode-family stop gives when no variable is named

One example per function, given by two stops (Session 370, Fix Slate
18): the function's own stop for a data frame named with no variable
([`.jst_no_var_stop()`](https://jma61.github.io/jstats/reference/dot-jst_no_var_stop.md)),
and ruling R22's single stop for a call naming neither
([`.jst_no_frame_stop()`](https://jma61.github.io/jstats/reference/dot-jst_no_frame_stop.md)),
so the two agree. Each is a line on community that runs as printed in
every convention state (voice Rule AC; Jeff, S369: a remedy must not
lead to another stop). The functions that return a variable are assigned
to a column of community, as jsum()'s and javg()'s examples are;
jdeclare_missing() names its convention, since a declaration on a plain
variable needs one and community's are SPSS-style. community's one text
variable is its ID, so jencode()'s example encodes RespondentID.

## Usage

``` r
.jst_no_var_example(fn)
```

## Arguments

- fn:

  Character. The function's name.

## Value

NULL for a function with no entry, else a list: call (the call, quoted),
lhs (the column it is assigned to, or NULL), n ("one" or "one or more"),
noun (for R22's line, when not "variables"), provide (the no-variable
stop's second line, before ", for example:"), named (the arguments that
name variables) and keep (the arguments R22's stop keeps from the call).
