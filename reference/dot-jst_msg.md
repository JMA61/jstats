# Internal helper: emit a note in the package house voice

Concatenates its ... arguments into a message and emits it via
message(). The assembled text is width-wrapped here via
.jst_wrap_message(), so a builder need not wrap its own prose, and a
builder that already wrapped is unaffected: the wrapper is idempotent at
a given width.

## Usage

``` r
.jst_msg(...)
```

## Arguments

- ...:

  Message parts, concatenated with paste0().

## Value

Invisibly NULL; called for the message it emits.

## Details

Notes carry no function-name prefix. An error attributes a failure to a
call and needs the "fn(): " tag that .jst_stop() adds; a note is
reporting what happened, and the house form already opens with "Note: "
where that reading matters. The first-line reserve is therefore zero.

Consequential notes – an overwrite, an override taking precedence, a
skipped variable – call this directly and are always visible. Advisory
notes reach it through .jst_advisory_note(), which adds the joutput tier
gate. (Session 254, the Session B emitter pass.)
