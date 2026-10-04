# Internal helper: the stop for a named setting whose name is not a data frame

Two messages (Session 334; Jeff approved both from rendered examples).
With nothing stored under the name, the name is the subject (Rule AD)
and the status call is the remedy. With a setting stored, the only call
that reaches here is `on`: the setting cannot be checked without its
data frame, so it is refused in the form the stale-setting stops use –
the cause as it was checked (Rule AH: "no longer exists" for a name that
did not evaluate, "is no longer a data frame" for one that holds
something else), "stays off" when the setting is off, and the way to
remove it. The name takes no article and no "data frame": it is not one.

## Usage

``` r
.jst_setting_name_stop(fn, st, payload = NULL, active = FALSE)
```

## Arguments

- fn:

  `"jsubset"` or `"jcomplete"`.

- st:

  The
  [`.jst_setting_name_state()`](https://jma61.github.io/jstats/reference/dot-jst_setting_name_state.md)
  result.

- payload:

  Character(1); the stored filter, or the stored variables.

- active:

  Logical; whether the stored setting is active.

## Value

Does not return; stops.
