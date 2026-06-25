# Internal helper: truncate a string to a display-width cap with ellipsis

Single source of truth for the package's table-cell width cap. A string
wider than `max_width` display columns is cut to `max_width - 1` columns
and given a trailing ellipsis character; shorter strings are returned
unchanged. Display width is measured with `nchar(type = "width")` so
double-width characters are counted correctly. The default 40-column cap
is shared across every in-table label surface – CPS pipeline detail (via
`.jst_cps_cap_label`), jfreq value labels and grouped headers,
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
