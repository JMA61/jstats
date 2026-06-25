# Internal helper: render a pipeline-state session-wide status overview

Shared formatter for the two-or-more-frame status overview of
[`jsubset()`](https://jma61.github.io/jstats/reference/jsubset.md) and
[`jcomplete()`](https://jma61.github.io/jstats/reference/jcomplete.md)
(the toggleable setters). Renders a header line plus one indented
`" - "` line per data frame, each tagged `[active]` / `[inactive]` and
marked `, default` for the current
[`juse()`](https://jma61.github.io/jstats/reference/juse.md) default.
The zero- and one-frame cases stay with the callers, since their
single-line wording differs (and `jcomplete` appends a live
complete-case count there). `jdummy` does not use this helper: it has no
active/inactive toggle and its overview header reads "registrations"
rather than "settings".

## Usage

``` r
.jst_render_status_overview(
  fn_label,
  dnames,
  payloads,
  active,
  default_name = NULL
)
```

## Arguments

- fn_label:

  Character function label (e.g. `"jsubset"`).

- dnames:

  Character vector of data frame names.

- payloads:

  Character vector, parallel to `dnames`, giving the per-frame payload
  shown after the colon (the expression for `jsubset`; the comma-joined
  variable list for `jcomplete`).

- active:

  Logical vector, parallel to `dnames`, TRUE when the setting is active.

- default_name:

  Character name of the current
  [`juse()`](https://jma61.github.io/jstats/reference/juse.md) default,
  or `NULL`. The matching frame is tagged `, default`.

## Value

`invisible(NULL)`. Called for its message side effect.
