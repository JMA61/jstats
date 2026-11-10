# Internal helper: a style's chart look

The `[plot]` settings of a style, resolved as jtable() resolves a style:
the call's `style =`, else `joptions(style = )`, else apa. A setting the
`[plot]` section leaves out comes from the same layer's general part
before the next layer (the reference, Part 3.2), so a style file that
sets font = for its tables sets its charts' font too, unless its
`[plot]` section sets one.

## Usage

``` r
.jst_plot_look(style = NULL, fn = "jplot")
```

## Arguments

- style:

  A style's name or path, a resolved style, or NULL.

- fn:

  The user-facing function, for a style's stops.

## Value

A list: the style's name, each `[plot]` setting, and the resolved style
itself (st), which jtable() frames the chart in.
