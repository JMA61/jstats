# Internal helper: about how wide a text is drawn, in inches

A chart is laid out before a graphics device has measured its text, so
the width of a legend or of an axis's labels is reckoned from the
characters: each at about the share of its font size it takes in Arial
or Helvetica (narrow letters and punctuation about a quarter to a third,
capitals about seven tenths, m and w nearly nine tenths, the rest a
little over half; a double-width character the whole size), which reads
within about three percent of the width drawn. A monospaced face takes
six tenths for every character. The widest line counts.

## Usage

``` r
.jst_plot_text_in(s, pt, family = "sans")
```

## Arguments

- s:

  Character; one or more texts, each perhaps of several lines.

- pt:

  Numeric(1); the font size, in points.

- family:

  Character(1); the font family, as
  [`.jst_plot_family()`](https://jma61.github.io/jstats/reference/dot-jst_plot_family.md)
  returns it.

## Value

Numeric, one for each text: the widest line's width in inches.
