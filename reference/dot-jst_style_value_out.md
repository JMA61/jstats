# Internal helper: a style value as a file writes it

A list of columns or thresholds joined by commas (.05, .01, .001); a
number as R prints it; a text value in double quotes when it is empty,
starts or ends with a space, starts with a quotation mark or holds a \#.

## Usage

``` r
.jst_style_value_out(v, sp)
```

## Arguments

- v:

  The value.

- sp:

  Its entry in `.jst_style_spec`.
