# Internal helper: build canonical dummy variable naming for a categorical variable

Single source of truth for how categorical variables are turned into
named dummy columns across the package. Called by
[`jdummy()`](https://jma61.github.io/jstats/reference/jdummy.md) during
registration and by
[`jlm()`](https://jma61.github.io/jstats/reference/jlm.md) /
[`jlogistic()`](https://jma61.github.io/jstats/reference/jlogistic.md)
when handling `categorical =` arguments and auto-detected categorical
IVs.

## Usage

``` r
.jst_make_dummy_names(
  x,
  var_name,
  ref = "first",
  name.length.warn = 30L,
  max.categories = 20L,
  data_name = NULL
)
```

## Arguments

- x:

  A vector – haven_labelled, factor, character, or numeric.

- var_name:

  Character. The variable's name (used as the dummy column prefix).

- ref:

  Reference category specifier. May be `first` (default), `last`, a
  numeric code, or a character string matching a canonical label.

- name.length.warn:

  Integer. Warn if any final dummy name exceeds this many characters.
  Default 30.

- max.categories:

  Integer. Maximum number of input categories allowed; a variable with
  more raises an error rather than building the dummy set. Default
  `20L`.

- data_name:

  Character. Name of the source data frame, used only to build the
  suggested-fix call shown in the over-the-limit error. May be `NULL`.

## Value

A list with components: `codes`, `labels` (canonical, used for display),
`dummy_names` (canonical, for non-reference categories only),
`var_type`, `ref_idx`, `ref_code`, `ref_label`, `non_ref_idx`, `notes`
(character vector of informational messages), `warnings_msg` (character
vector of warnings).

## Details

Supports six input shapes:

1.  haven_labelled with descriptive labels not containing the variable
    name (e.g. Gender labelled "Male", "Female").

2.  haven_labelled with descriptive labels already containing the
    variable name (e.g. Program labelled "Program 1", "Program 2"...).

3.  haven_labelled with labels that equal the codes as strings (i.e.
    uninformative – labels carry no extra information).

4.  Plain numeric with no labels.

5.  Factor with character levels.

6.  Character vector.

Naming algorithm:

1.  Output form is always `VarName_Suffix`.

2.  Suffix source per category: descriptive label if available, numeric
    code otherwise. Mixed within a single variable is allowed
    (descriptive wins per-category).

3.  Canonicalise the chosen suffix: replace runs of non-alphanumeric
    characters with single underscore; trim leading and trailing
    underscores; if a suffix canonicalises to empty (label was entirely
    non-alphanumeric), fall back to that category's code.

4.  Anti-stutter: if the canonicalised suffix already begins with
    `paste0(var_name, "_")`, do not prepend the variable name again.

5.  Detect duplicates: if two categories produce the same final name,
    stop with an error pointing to
    [`jrelabel()`](https://jma61.github.io/jstats/reference/jrelabel.md).

Permissive reference matching: when `ref` is a character string, three
matching attempts are made – direct match against canonical labels,
canonicalised user input matched against canonical labels (so
`"Program 3"` or `"3"` both find `"Program_3"`), and string match
against codes (so `"3"` also matches code 3).
