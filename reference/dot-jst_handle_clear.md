# Internal helper: resolve and perform a registration clear

The single decision point for clearing classification registrations,
shared by
[`jnumeric()`](https://jma61.github.io/jstats/reference/jnumeric.md),
[`jcount()`](https://jma61.github.io/jstats/reference/jcount.md), and
[`jdummy()`](https://jma61.github.io/jstats/reference/jdummy.md) so the
three verbs behave identically. Three entry shapes feed it:

- `clear.all = TRUE` – clear this kind on every data frame that carries
  it.

- `explicit_frame` set (the `verb(data, NULL)` form) – clear this kind
  on that one frame.

- neither (the `verb(NULL)` form) – clear the
  [`juse()`](https://jma61.github.io/jstats/reference/juse.md) default
  frame if one is set; otherwise clear the sole frame carrying this kind
  if exactly one does; otherwise stop and ask the user to name a frame
  or pass `clear.all = TRUE` (never a silent multi-frame wipe).

Messages are emitted here, not by the callers, so the wording stays
uniform.

## Usage

``` r
.jst_handle_clear(
  kind,
  clear.all = FALSE,
  explicit_frame = NULL,
  default_name = NULL
)
```

## Arguments

- kind:

  One of "numeric", "count", "dummy".

- clear.all:

  Logical; clear every frame carrying this kind.

- explicit_frame:

  Character data-frame name for the `verb(data, NULL)` form, or NULL.

- default_name:

  The [`juse()`](https://jma61.github.io/jstats/reference/juse.md)
  default frame name, or NULL.

## Value

`invisible(NULL)`.
