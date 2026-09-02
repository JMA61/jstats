# Internal helper: classify one physical line of a runtime message

The three-category classifier behind
[`.jst_wrap_message()`](https://jma61.github.io/jstats/reference/dot-jst_wrap_message.md).
Replaces the former two-category `.jst_wrap_lines()`, whose "any
indented line passes" rule let indented PROSE through unwrapped – the
jai status panel rendered such lines at 97 and 81 characters.

## Usage

``` r
.jst_seg_category(line, width = 76L)
```

## Arguments

- line:

  Character scalar: one physical line, no newlines.

- width:

  The width in force for this line (the caller subtracts any first-line
  reserve before calling).

## Value

One of "pass", "prose", or "indent".

## Details

- pass:

  Byte-identical. Blank lines, anything already fitting, Rule L runnable
  command lines, Rule V menu options, and column-aligned layout.

- prose:

  Wrapped by
  [`.jst_wrap_prose()`](https://jma61.github.io/jstats/reference/dot-jst_wrap_prose.md)
  at the full width.

- indent:

  Wrapped by
  [`.jst_wrap_indent()`](https://jma61.github.io/jstats/reference/dot-jst_wrap_indent.md)
  at its own indent, so every continuation line keeps the indent it
  started with.

The fits test is protective rather than cosmetic:
[`.jst_wrap_prose()`](https://jma61.github.io/jstats/reference/dot-jst_wrap_prose.md)
rejoins on single spaces, so a column-aligned line that already fits
must never reach it.

Derived from, and verified against, the Session 252 dry-run corpus: of
the over-width lines in the 282 messages that change under this wrapper
alone, all 305 unindented ones wrap and none pass, which is why an
unindented line is prose without further tests.
