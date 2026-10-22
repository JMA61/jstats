# Internal helper: canonical single-line text of a formula term

Deparses a language object into one line and collapses any whitespace
run to a single space. deparse() breaks a long call across indented
continuation lines, and pasting those pieces back with collapse = ""
kept the indent as embedded padding inside the term text (AUDIT-031) –
padding that then appeared verbatim in the computed column's name and
every display of it. The transform resolver builds a term's text in two
places – once to name the computed column, once inside the formula
substitution pass to find that column again – and the two MUST produce
identical text or the substitution silently stops matching long terms;
both route through this one helper so they cannot drift.

## Usage

``` r
.jst_term_text(e)
```

## Arguments

- e:

  A language object (a call or symbol from a formula).

## Value

Single string: the deparsed term with normalized spacing.

## Details

Since Session 390 the collapse is made BETWEEN tokens only: a quoted
string or a backquoted name keeps its spaces as they are. Collapsing
inside them changed the user's text in every call the package offers
through
[`.jst_call_with()`](https://jma61.github.io/jstats/reference/dot-jst_call_with.md)
– a file named "my data.csv" was offered as "my data.csv", a line that
then stopped on a file not found, and an ideographic space inside a
Chinese or Japanese label became a plain one. Outside the quotes the
spacing is normalized as before.
