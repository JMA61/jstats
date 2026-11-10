# Internal helper: a label's text, breaking only between its words

Ruling R55's measure
([`.jst_docx_stub_floor()`](https://jma61.github.io/jstats/reference/dot-jst_docx_stub_floor.md))
wraps a label onto two lines between its words, a parenthetical one
word; Word also breaks after a hyphen and an en dash and between a
parenthetical's words, and fills the first line as far as it goes, so
"Wellbeing score (0-100)" in a narrowed stub broke after "(0-" (found on
the S414 walk). Here a hyphen is Word's non-breaking hyphen
(w:noBreakHyphen), as the true minus sign keeps a negative whole; the
spaces inside parentheses are non-breaking; and an en dash is joined to
what follows it (Session 415; Jeff: "Is there some way to have the
entire parenthetical on the second line when wrapping is necessary?").
The text reads as before.

## Usage

``` r
.jst_docx_keep_text(text)
```

## Arguments

- text:

  Character(1).

## Value

The run's text elements, XML.
