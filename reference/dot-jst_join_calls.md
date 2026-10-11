# Internal helper: put a call a builder broke over lines back on one

The layout of a long printed call is the wrapper layer's (ruling R5,
Session 353), so a call that reaches it already broken over lines – by a
builder that laid it out itself, or by an earlier pass of the wrapper –
is first put back on one line, and then laid out like any other. A line
with the shape of a call that leaves a bracket or a string open is
joined with the lines under it, each without its indent and after one
space, until the call closes; the joined line is kept only when it
parses as one expression, so prose that merely opens with a call and an
open bracket is left as it was. A blank line ends the search. Joining
also lets
[`.jst_place_lines()`](https://jma61.github.io/jstats/reference/dot-jst_place_lines.md)
see a broken call whole.

## Usage

``` r
.jst_join_calls(lines)
```

## Arguments

- lines:

  Character vector: the physical lines of one message.

## Value

Character vector, possibly shorter.
