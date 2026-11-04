# Internal helper: a style file's "takes" note, set to the file's width

"# takes: ..." and, where the text runs past 76 columns, continuation
lines under it ("# ..."), broken between words. Set by hand: the wrap
helpers belong to the message layer and follow the console's width,
which a file must not (as the orientation text, Session 357).

## Usage

``` r
.jst_style_note_lines(text, width = 76L)
```

## Arguments

- text:

  Character(1), what the setting takes.

- width:

  The widest line.

## Value

Character, the comment lines.
