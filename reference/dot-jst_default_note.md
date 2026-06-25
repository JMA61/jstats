# Internal helper: print the "Using default data frame: X" note in yellow

Used by every analysis function immediately after its red title line.
Groups the default-data-frame note with other session-state notes
(jsubset, jcomplete) under a consistent yellow coloring.

## Usage

``` r
.jst_default_note(data_name, extra_newline = FALSE)
```

## Arguments

- data_name:

  Character string name of the default data frame.

- extra_newline:

  Logical. If TRUE, adds a trailing blank line after the note so it's
  visually separated from whatever prints next. Defaults to FALSE, so
  the note abuts the next line directly; the jcomplete and jdummy
  summaries pass TRUE explicitly to keep their trailing blank. (Default
  flipped TRUE -\> FALSE in Session 52 to collapse the double blank line
  above the Case Processing block.)
