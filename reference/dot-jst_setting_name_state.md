# Internal helper: a named off / on / NULL whose name is not a data frame

`jsubset(z, off)`, `jsubset(z, on)`, `jsubset(z, NULL)` and the
[`jcomplete()`](https://jma61.github.io/jstats/reference/jcomplete.md)
forms name the data frame a stored setting belongs to. The settings are
stored by NAME, so `off` and `NULL` need no data frame; until Session
334 the name was resolved as a data frame first, and one that had been
removed, or now held something else, met the resolver's "not found. Did
you mean to use it as a variable name?" – so the named form could not
turn off or clear the setting stored for it. This reads the name without
resolving it and says which case it is.

## Usage

``` r
.jst_setting_name_state(data_sub, stored, default_name, envir)
```

## Arguments

- data_sub:

  The substituted first argument.

- stored:

  Character; the names that carry a setting.

- default_name:

  Character(1) or `NULL`; the
  [`juse()`](https://jma61.github.io/jstats/reference/juse.md) default
  (see above).

- envir:

  The caller's environment.

## Value

`NULL`, or a list: `name`; `state`, `"gone"` (the name did not evaluate)
or `"other"` (it holds something that is not a data frame); `stored`,
whether a setting is stored under it.

## Details

Returns `NULL` – the caller carries on as before – when the input is not
a bare name, when it holds a data frame, or when nothing is stored under
it and `default_name` is set. The last is
[`jcomplete()`](https://jma61.github.io/jstats/reference/jcomplete.md)'s
case: with a
[`juse()`](https://jma61.github.io/jstats/reference/juse.md) default,
`jcomplete(v1, on)` may be two variables of the default data frame.
[`jsubset()`](https://jma61.github.io/jstats/reference/jsubset.md)
passes `default_name = NULL`, since a name followed by `off`, `on` or
`NULL` is never a condition.
