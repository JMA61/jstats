# Internal helper: a chart's text on lines of about 45 columns

A plain fill, word by word, each line kept under the width in display
columns (a Chinese, Japanese or Korean character two), a word longer
than the width on a line of its own. A chart's text is not a message, so
it does not go through the message wrapper, whose rules are for prose
(sentences kept whole, a short last line pulled back); and strwrap()
belongs to that wrapper alone, which receive_package()'s structural gate
checks.

## Usage

``` r
.jst_plot_wrap(s, width = 45L)
```

## Arguments

- s:

  Character(1).

- width:

  Integer(1), the columns.
