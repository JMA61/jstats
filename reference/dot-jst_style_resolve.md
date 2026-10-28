# Internal helper: the style a jtable() call uses

Build 1 knows one style, the built-in apa list; `style =` names it.
Build 2 adds the style files, `jstyle()` and the lookup through
`based.on`; this is where that lookup will go, so every caller already
reads the style through one helper.

## Usage

``` r
.jst_style_resolve(style, fn = "jtable")
```

## Arguments

- style:

  Character(1); the style's name.

- fn:

  The user-facing function's name, for the stop.

## Value

The style: a list with a general part and one list per table type.
