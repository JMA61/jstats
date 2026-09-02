# Internal helper: emit a note to stdout in the package house voice

The stdout sibling of
[`.jst_msg()`](https://jma61.github.io/jstats/reference/dot-jst_msg.md):
same assembly, same width wrapping, different sink. Some notes belong on
stdout rather than the message connection – the status panels, and the
note builders that have always printed rather than signalled. Those call
this instead of [`cat()`](https://rdrr.io/r/base/cat.html) so that they
participate in the message.width setting like every other emitter,
rather than depending on each builder remembering to wrap its own prose.

## Usage

``` r
.jst_msg_out(...)
```

## Arguments

- ...:

  Message parts, concatenated with paste0().

## Value

Invisibly NULL; called for the text it prints.

## Details

NOT a general [`cat()`](https://rdrr.io/r/base/cat.html) replacement,
and deliberately not named as one. The analysis functions render
column-aligned tables through
[`cat()`](https://rdrr.io/r/base/cat.html); wrapping those would destroy
the alignment. This emitter is for prose.

Trailing newlines are normalized away and exactly one is emitted.
[`message()`](https://rdrr.io/r/base/message.html) supplies its own line
ending and [`cat()`](https://rdrr.io/r/base/cat.html) does not, so the
call sites converted to this emitter all wrote their own; normalizing
means a converted site cannot emit a stray blank line and a new site
cannot forget. Leading blank lines are PRESERVED: a builder that opens
with one is spacing itself off the output above, which is a layout
choice the emitter has no business overriding.
