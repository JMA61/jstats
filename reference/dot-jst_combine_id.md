# Internal helper: combine a variable's name and label per variable.id mode

Decouples the `variable.id` display decision from how each call site
fetches its label. The caller resolves two strings – the bare `name` and
a `label_or_name` (the variable's label if it has one, otherwise the
name, as returned by `.jst_label_or_name` or an equivalent closure) –
and this helper combines them according to `mode`:

- `"labels"`: the label (i.e. `label_or_name`).

- `"both"`: `"name: label"` when a label exists, else the bare name. "A
  label exists" is inferred from `label_or_name` differing from `name`;
  an unlabelled variable (where the two are equal) collapses to the
  name, mirroring `value.id = "both"`'s per-variable degrade.

- `"names"`, `"legend"`, `"legend.bottom"`: the bare name (legend modes
  keep the name in place and emit the label separately via
  `.print_var_labels`).

The colon-space join matches `.jst_format_value_labels`'s `"both"` form,
so a name+label identifier reads identically to a code+label category.
`cap = TRUE` routes the result through the shared 40-column cap; pass it
only for in-table-column surfaces (jdesc/jcorr/jalpha row-label
columns), never for title or heading lines.

## Usage

``` r
.jst_combine_id(name, label_or_name, mode, cap = FALSE)
```

## Arguments

- name:

  Single character: the bare variable name.

- label_or_name:

  Single character: the label if present, else the name.

- mode:

  One of `"both"`, `"names"`, `"labels"`, `"legend"`, `"legend.bottom"`.

- cap:

  Logical. Apply the in-table width cap. Default FALSE.

## Value

Single character display string.
