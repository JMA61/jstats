# Internal helper: the blocks of a message's lines that name mydata, each opened on the line that makes it

The block rule of
[`.jst_expr_assign_lines()`](https://jma61.github.io/jstats/reference/dot-jst_expr_assign_lines.md)
(Session 352), one home since Session 389 for it and the message wrapper
([`.jst_expr_open_lines()`](https://jma61.github.io/jstats/reference/dot-jst_expr_open_lines.md)):
a block is a run of lines indented two spaces or more, and one that
names mydata gets "mydata \<- " as its first line, unless its first line
already makes mydata.

## Usage

``` r
.jst_expr_open_blocks(lines, typed)
```

## Arguments

- lines:

  Character; the message's lines.

- typed:

  Character(1): the expression as typed.

## Value

Character; the lines, each such block opened.
