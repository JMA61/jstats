# Internal helper: clear one frame's registrations of one kind

Removes the requested kind's registrations for a single named data frame
and returns the variable names that were cleared (empty when there were
none). "dummy" clears the frame's `.jst_dummy` entry; "numeric"/"count"
remove only the matching-kind records from the frame's `.jst_registry`
entry, leaving any records of the other kind in place.

## Usage

``` r
.jst_clear_one_frame(kind, data_name)
```

## Arguments

- kind:

  One of "numeric", "count", "dummy".

- data_name:

  Character data-frame name.

## Value

Character vector of cleared variable names (possibly empty).
