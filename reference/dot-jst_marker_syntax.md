# Internal helper: how the map, label and code parsers name a marker

The parse layer's errors about a malformed marker fire before the
convention is resolved, and until Session 355 they said "Stata-style
missing-value tokens must be '.a' through '.z' (a single lowercase
letter after the period)" under every setting – to a user of the sas
setting, who types .A, and although a typed marker's case is never
refused (the S240 item, finding F1). They are phrased as
`.jst_phrasing_convention()` phrases the refusals that fire before
resolution: the per-call convention, else a sas setting, else Stata.
"Marker", not "token" (Session 354 retired "token" from the help pages;
voice Rule B, S265).

## Usage

``` r
.jst_marker_syntax(convention = NULL)
```

## Arguments

- convention:

  The caller's per-call convention, raw, or NULL.

## Value

A list of strings: `rule` (the sentence naming the form), `one` ("a
Stata-style missing-value marker (.a through .z)"), `some` ("Stata-style
markers (.a through .z)") and `eg` ("a Stata-style missing-value marker
such as 'else=.a'").
