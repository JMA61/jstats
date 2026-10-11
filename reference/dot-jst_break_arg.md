# Internal helper: break one argument of a printed call that will not fit

The second level of ruling R5's layout: an argument too long for a line
of its own. A `map =` or `labels =` string breaks after the semicolons
between its rules, the rules that follow set under its first rule; a
call such as `c(...)` breaks after the commas between its elements, set
under its first element. Anything else – a long name, a formula, a
string of another kind – is kept whole on its line, past the width: a
call is never shortened.

## Usage

``` r
.jst_break_arg(arg, tail, ind, width, hang = NULL)
```

## Arguments

- arg:

  Character(1): the argument as written.

- tail:

  Character(1): what follows it, "," or ")".

- ind:

  Character(1): what its first line holds before it – the indent of a
  continuation line, or the call's opening for the first argument.

- width:

  The message width.

- hang:

  Character(1) or NULL: the indent of its later lines. NULL sets them
  under its first rule or element, which is a few columns in from a
  continuation line's fixed indent. The first argument passes the call's
  fixed indent instead, since it starts beside the call's name and a
  line set under it would hang far right.

## Value

Character vector: its lines.
