# Internal helper: signal a warning in the package house voice

Concatenates its ... arguments into a message and signals a warning().
Always signals with call. = FALSE, matching .jst_stop(): the package
suppresses R's automatic call context throughout, and the emitter owns
that choice so the call sites do not each repeat it.

## Usage

``` r
.jst_warn(...)
```

## Arguments

- ...:

  Message parts, concatenated with paste0().

## Value

Invisibly NULL; called for the warning it signals.

## Details

The assembled text is width-wrapped here via .jst_wrap_message() with a
flat first-line reserve of 9: the widest inline chrome R can attach to
the warning route, "Warning: " under options(warn = 1). The default
deferred single-warning display puts "Warning message:" on its own line
(cost 0) and numbered deferred warnings cost 3-4 ("1: "), so both land
inside the 9-column budget. A conditional reserve reading
getOption("warn") was considered and rejected: it would make the same
message wrap differently across sessions, forking the walks (which set
warn = 1) from a user's default session. warn = 2 converts warnings to
errors with R's own "converted from warning" chrome; that is a developer
setting and is out of scope – recorded here, not budgeted. (Session 256;
supersedes the Session 254 reserve-0 rationale.)
