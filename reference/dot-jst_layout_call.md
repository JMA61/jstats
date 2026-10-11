# Internal helper: lay out a printed call that is wider than the message

Ruling R5 (Jeff, Session 345; built Session 353): every call the package
prints for pasting has ONE layout.

1.  Within the message width, one line.

2.  Wider, broken where R allows: after a comma between the call's
    arguments, each later line at a FIXED indent four spaces in from the
    call's own – not hung under the opening parenthesis, which a long
    name pushes far right. As many arguments go on a line as fit. An
    argument that will not fit on a line of its own breaks inside
    ([`.jst_break_arg()`](https://jma61.github.io/jstats/reference/dot-jst_break_arg.md)):
    a map or labels string after its semicolons, its rules set under the
    first, and a `c(...)` after its commas.

3.  Never left as one long line, never shortened with "...", never
    broken by the prose wrapper: it runs as printed.

A map broken over lines still runs: the map parsers trim each rule, so
the line break and the spaces after it are dropped with the space a
one-line map has there.

## Usage

``` r
.jst_layout_call(line, width)
```

## Arguments

- line:

  Character(1): one indented line holding one call, or an assignment
  whose right side is a call or a subscript (the
  `mydata <- d[rows, cols]` a message offers for an expression given as
  the data, broken after the commas inside its brackets).

- width:

  The message width for the line.

## Value

Character(1), with newlines where it was broken.

## Details

Called from
[`.jst_wrap_message()`](https://jma61.github.io/jstats/reference/dot-jst_wrap_message.md),
so it holds for every emitter and every function; until Session 353
[`.jst_jencode_map_call()`](https://jma61.github.io/jstats/reference/dot-jst_jencode_map_call.md)
packed its own maps, hung under the parenthesis at a fixed 76 columns,
and every other call ran on past the width. A line it cannot read as one
call – two calls, a comment, a call with text after it – is returned
unchanged.
