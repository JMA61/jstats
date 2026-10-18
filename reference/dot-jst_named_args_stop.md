# Internal helper: the stop for an unnamed argument after the variable, with no data frame

jrecode(), jencode() and jrelabel() under a juse() default, given the
variable first and another argument unnamed – jrecode(Age, "1=2"). The
stop had rewritten the call by position, "Use jrecode(Age, map = ...)",
inline (Session 371, the remedy-line audit): a first argument that was
not a variable of the default frame – a data frame's name typed wrong,
jencode(dta, Name, map = "a=1") – was offered jencode(dta, map = Name),
the map dropped. Now the first argument is checked first, and one the
default frame lacks gets the not-found sentence, with the default hint;
the call is given back with its one unnamed argument named, on a line of
its own, and with several unnamed, or the slot already named, the
sentence alone.

## Usage

``` r
.jst_named_args_stop(fn, arg1, data, data_name, cl, slot)
```

## Arguments

- fn:

  Character. The function's name.

- arg1:

  The resolver's result.

- data:

  The default data frame.

- data_name:

  Its name.

- cl:

  The call as typed.

- slot:

  The argument an unnamed second argument fills ("map", "labels").

## Value

Does not return; stops.
