# Internal helper: a registration verb's named clear or removal, by name

`jdummy(z, NULL)` and `jdummy(z, Grp, remove = TRUE)` – and the
[`jnumeric()`](https://jma61.github.io/jstats/reference/jnumeric.md),
[`jcount()`](https://jma61.github.io/jstats/reference/jcount.md) and
[`jlikert()`](https://jma61.github.io/jstats/reference/jlikert.md) forms
– name the data frame whose registrations are to go. The stores are
keyed by NAME, so neither needs the data frame; until Session 342 the
name was resolved as a data frame first, and one that had been removed,
or now held something else, stopped at the resolver ("'z' is not a data
frame. Did you mean to use it as a variable name?"), leaving the
registrations out of the named form's reach (the S334 item;
[`jsubset()`](https://jma61.github.io/jstats/reference/jsubset.md) and
[`jcomplete()`](https://jma61.github.io/jstats/reference/jcomplete.md)
got the by-name forms at v0.9.211, and this follows them through
[`.jst_setting_name_state()`](https://jma61.github.io/jstats/reference/dot-jst_setting_name_state.md)).

## Usage

``` r
.jst_registration_by_name(kind, data_sub, dots, remove, envir)
```

## Arguments

- kind:

  One of "numeric", "count", "likert", "dummy".

- data_sub:

  The substituted first argument.

- dots:

  The unevaluated `...` of the call, as a list.

- remove:

  The call's `remove` flag.

- envir:

  The caller's environment.

## Value

`TRUE` when the call was served here, otherwise `FALSE`; stops for a
name that carries nothing.

## Details

Called before the resolver. Acts, and returns `TRUE`, when the first
argument is a bare name that does not hold a data frame and
registrations of this kind are stored under it. A lone `NULL` with
nothing stored under the name is refused as a name
([`.jst_registration_name_stop()`](https://jma61.github.io/jstats/reference/dot-jst_registration_name_stop.md))
when no [`juse()`](https://jma61.github.io/jstats/reference/juse.md)
default is set; with a default, and for the removal form whenever
nothing is stored, the call is left to the resolver, since the name may
be a variable of the default data frame. REGISTERING under such a name
is never served here: it stays the resolver's refusal (Jeff's Session
342 lean 3).
