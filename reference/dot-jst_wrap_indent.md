# Internal helper: wrap message prose at a fixed left indent

Companion to
[`.jst_wrap_prose()`](https://jma61.github.io/jstats/reference/dot-jst_wrap_prose.md)
for indented explanatory text inside a multi-line message layout – the
consequence lines under a choose-first gate's menu options (Rule V),
where every line of the wrapped text sits at the same indent. Delegates
the wrapping (atom protection, orphan pull-back) to
[`.jst_wrap_prose()`](https://jma61.github.io/jstats/reference/dot-jst_wrap_prose.md)
at a width reduced by the indent, then prefixes every resulting line
with the indent spaces. (Session 244, the Decision 11 gate build.)

## Usage

``` r
.jst_wrap_indent(text, indent, width = .jst_resolve_width())
```

## Arguments

- text:

  Character scalar: one sentence/paragraph, no embedded newlines.

- indent:

  Number of spaces every line is indented by.

- width:

  Target total line width including the indent. Defaults to the resolved
  `message.width` setting (see
  [`joptions`](https://jma61.github.io/jstats/reference/joptions.md)).

## Value

Character scalar; every line starts with `indent` spaces.
