# Internal helper: the message wrapper's step for a recode on an expression

[`.jst_expr_open_blocks()`](https://jma61.github.io/jstats/reference/dot-jst_expr_open_blocks.md)
on a message's lines when a jrecode() or jencode() call given an
expression as its data is running (`.jst_expr_context`); the lines as
they are otherwise. Called by
[`.jst_wrap_message()`](https://jma61.github.io/jstats/reference/dot-jst_wrap_message.md)
after
[`.jst_place_lines()`](https://jma61.github.io/jstats/reference/dot-jst_place_lines.md).

## Usage

``` r
.jst_expr_open_lines(lines)
```

## Arguments

- lines:

  Character; the message's lines.

## Value

Character; the lines.
