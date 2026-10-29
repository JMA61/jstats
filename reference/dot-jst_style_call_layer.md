# Internal helper: a call's own style settings, as a layer

Each setting the call gives must be one of the table type's section's (a
general setting is refused at jtable()'s front door); its value is
checked as a file's is.

## Usage

``` r
.jst_style_call_layer(vals, type, fn)
```

## Arguments

- vals:

  A named list: the settings, evaluated.

- type:

  The table type.

- fn:

  The user-facing function's name.

## Value

A layer: list(source = "the call", = list(...)).
