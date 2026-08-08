# Internal: render a named numeric label set for an error message

Formats entries of a parsed-labels vector (names = labels, values =
numeric) as "value=label; value=label" for quoting back to the user in
refusals about unmatched labels entries.

## Usage

``` r
.jst_render_label_entries(x)
```
