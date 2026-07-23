# Internal helper: assemble the full orientation text

Heading, intro line, stamp line(s), blank, body. flavor = "machine"
drops the "Note for AI assistants:" framing prefix from the one body
line that carries it (a skill body is already assistant-facing; settled
S203).

## Usage

``` r
.jst_orientation_text(stamp, flavor = c("standard", "machine"))
```
