# Internal helper: names of data frames carrying registrations of one kind

Scans the relevant session store and returns the names of the data
frames that currently hold at least one registration of the requested
kind: `.jst_registry` for "numeric"/"count" (a frame qualifies if it has
any record of that kind), `.jst_dummy` for "dummy" (a frame qualifies if
it has any dummy registration). Used by the clear dispatcher to decide,
when no frame is named and no default is set, whether a bare clear is
unambiguous.

## Usage

``` r
.jst_frames_with_registrations(kind)
```

## Arguments

- kind:

  One of "numeric", "count", "dummy".

## Value

Character vector of data-frame names (possibly empty).
