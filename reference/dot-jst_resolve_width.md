# Internal helper: resolve a width setting to a number of columns

Precedence follows
[`.jst_resolve_corr_layout()`](https://jma61.github.io/jstats/reference/dot-jst_resolve_corr_layout.md):
an explicit per-call value wins, else the supplied joptions slot value,
else a last-ditch fallback. Five forms are accepted – `"auto"` (the live
console width less one column), the three tokens in `.jst_width_tokens`,
or a whole number within the band.

## Usage

``` r
.jst_resolve_width(
  per_call = NULL,
  slot = getOption(".jst_options_message_width", .jst_options_defaults$message.width),
  min = 40L,
  max = 120L,
  arg = "message.width",
  fn = NULL
)
```

## Arguments

- per_call:

  A per-call width value, or NULL to defer to the slot.

- slot:

  The joptions slot value. Defaults to the `message.width` slot, the
  only consumer in this version; a future `table.width` passes its own.

- min, max:

  The consumer's band, inclusive.

- arg, fn:

  Names used in the per-call validation error.

## Value

Integer: the resolved width in columns.

## Details

TWO BEHAVIORS BY PROVENANCE, deliberately. A NUMBER the user typed is
honored or REFUSED, because a silent clamp reports success and does
something else. A WORD – a token, or `"auto"` – is FITTED to the band,
because refusing `"auto"` would punish a user for resizing a pane they
never typed a number into.

Like `corr.layout` and `missing.detail`, these tokens name no
statistical platform, so they are matched EXACTLY and are outside the
platform-spec case-insensitivity rule.

Validation is strict on `per_call` ONLY. An invalid slot falls back
silently, matching
[`.jst_resolve_corr_layout()`](https://jma61.github.io/jstats/reference/dot-jst_resolve_corr_layout.md)
– and here that is required rather than merely consistent: this resolver
is read by the message emitters, so a slot corrupted by a direct
[`options()`](https://rdrr.io/r/base/options.html) write must not raise
an error from inside the error path.
