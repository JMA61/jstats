# Internal helper: one NEWS.md entry as Console text

The Console shows Markdown as typed, so the entry is printed as plain
text: its heading as a line, each paragraph as one line for the emitter
to wrap, each list item at two spaces with a dash and its text hung at
four, nested items two further in, a line that is only code – a call in
backticks, or the lines of a fenced block – on a line of its own, four
spaces in (two past an item's text), and the backticks and bold markers
taken out
([`.jst_news_plain()`](https://jma61.github.io/jstats/reference/dot-jst_news_plain.md)).
A blank line in the file is one blank line here. Prose is reflowed to
the message width, not broken one sentence to a line: the entry is the
release's own text, not a message in the package's voice. An item is
wrapped here, at its hanging indent, through
[`.jst_wrap_indent()`](https://jma61.github.io/jstats/reference/dot-jst_wrap_indent.md),
so each of its lines fits the width and the emitter passes it as it is.

## Usage

``` r
.jst_news_render(entry, width = .jst_resolve_width())
```

## Arguments

- entry:

  One element of
  [`.jst_news_entries()`](https://jma61.github.io/jstats/reference/dot-jst_news_entries.md)'s
  list.

- width:

  The message width.

## Value

Character(1), lines joined by newlines.
