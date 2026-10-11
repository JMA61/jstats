# Internal helper: read a line of R code as R reads it

Walks the characters of one line of code, keeping the bracket depth and
whether each character sits inside a string, as R's own reader does: a
quotation mark (", ' or a backtick) opens a string that the same mark
closes, a backslash inside a string escapes the character after it, and
a \# outside a string begins a comment. The layout of a printed call
(ruling R5, Session 353) reads a line through it to find where the
call's arguments begin and end, and whether a line leaves a call open.

## Usage

``` r
.jst_code_scan(s)
```

## Arguments

- s:

  Character(1): the text, with no newlines.

## Value

A list: `ch`, the characters; `depth`, the bracket depth at each
character before it is read; `instr`, TRUE for a character inside a
string (its closing mark included); `open`, TRUE when the text ends
inside a string or a bracket; and `comment`, the position of a comment's
\#, or NA.
