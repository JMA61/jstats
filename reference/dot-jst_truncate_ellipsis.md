# Internal helper: truncate a string to a display-width cap with ellipsis

Single source of truth for the package's table-cell width cap. A string
wider than `max_width` display columns is cut to `max_width - 3` columns
and given a trailing three-period marker ("..."), so the result occupies
exactly `max_width` columns; shorter strings are returned unchanged. The
marker is plain ASCII (Session 293; was the Unicode ellipsis U+2026 from
Session 57), matching the ASCII closing rule adopted for the CPS block
at Session 267. Display width is measured with `nchar(type = "width")`
so double-width characters are counted correctly, and since Session 390
the cut is made by display width too
([`.jst_cut_width()`](https://jma61.github.io/jstats/reference/dot-jst_cut_width.md)):
it was made by characters, so a Chinese label of 30 characters (60
columns) was not cut at all and one of 50 was cut to 74 columns. A
two-column character that would straddle the cut is left out, and the
result is then one column narrower than the cap. The default 40-column
cap is shared across every in-table label surface – CPS pipeline detail
(via `.jst_cps_cap_label`), jfreq value labels and grouped headers,
jdesc/jcorr variable-identifier columns – so a future change to the cap
is made in this one place. Title and heading lines (which sit on their
own line with no column to share) are never routed through this helper.

## Usage

``` r
.jst_truncate_ellipsis(content, max_width = 40L)
```

## Arguments

- content:

  Character scalar (coerced; first element used).

- max_width:

  Integer display-column cap. Default 40.

## Value

Single character string, capped to `max_width` columns.
