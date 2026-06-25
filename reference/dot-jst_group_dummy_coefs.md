# Internal helper: group multi-category dummy rows in a coefficient table

Restructures a coefficient display data frame so each multi-category
dummy variable prints as a header row – the variable's name (or its
label under `variable.id = "labels"`), optionally carrying its reference
category as `"(ref = ...)"` – with the variable's categories indented
two spaces beneath it. Category-row labels follow the resolved value.id
mode (both / values / labels). Rows that are not multi-category dummy
members (the intercept, continuous predictors, single-contrast
dichotomies, factor terms) pass through unchanged and in place.

## Usage

``` r
.jst_group_dummy_coefs(disp_df, regs, value_mode, vlmode, lab_src, show_ref)
```

## Arguments

- disp_df:

  The flat coefficient display data frame (character cells), with
  coefficient names as its row names.

- regs:

  List of multi-category registrations from
  [`.jst_collect_multicat_regs()`](https://jma61.github.io/jstats/reference/dot-jst_collect_multicat_regs.md).

- value_mode:

  Resolved value.id mode for the category rows: one of `"both"`,
  `"values"`, `"labels"` (legend modes are folded to `"both"` by the
  caller).

- vlmode:

  Resolved variable.id mode; `"labels"` makes the header use the
  variable's label.

- lab_src:

  Pre-conversion data frame used as the label source.

- show_ref:

  Logical. Whether to fold the reference category into each variable's
  header.

## Value

A data frame whose first column `.rowlab` holds the display labels and
whose remaining columns are `disp_df`'s columns verbatim.

## Details

The result carries the display label for each row in a leading `.rowlab`
column rather than in the row names, so the caller prints it with
`row.names = FALSE` and an `"ln"` (left, no-trim) alignment on that
column to preserve the indent. Using a real column sidesteps the
data-frame unique-row-name constraint, which bare numeric codes would
routinely violate. Header rows carry blank cells in every data column;
category-row cells (including any standardized-beta column) are copied
verbatim from `disp_df`, so a future standardization mode that populates
beta on these rows needs no change here.
