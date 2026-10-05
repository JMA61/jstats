# Internal: the notification's body lines for one block

Renders a `.jst_jdeclare_missing_body()` result: each value, two spaces
in, with its annotations after one space in a single pair of
parentheses, joined by "; " – the form the naming branch's lines have
had since S247
(`.a is now "Refused" (was "Old"; not present in the data)`). "not
present in the data" comes last, as it does there.

## Usage

``` r
.jst_jdeclare_missing_body_lines(body, absent = body$absent)
```

## Arguments

- body:

  A `.jst_jdeclare_missing_body()` result.

- absent:

  Logical, one per line: whether to mark the line "not present in the
  data". Defaults to the body's own; the bulk notification passes the
  block's – TRUE only where no variable in the block holds the value.

## Value

Character vector of lines.
