# Internal helper: the category values behind a dummy registration

Returns the raw category value each registration code stands for, in
code order. Registrations built since Session 305 carry them as the
`values` field, which is returned as stored. A registration saved by an
earlier version (a jdummy() card in an older .rds file) has no such
field, so the values are reconstructed. For a factor or character
variable the codes are POSITION indices 1..k, and the reconstruction
cannot simply re-sort the column: a category absent from the frame in
hand – filtered out, or not in this file – would shift every later
position onto the wrong code. Instead each candidate value in the column
is canonicalized exactly as
[`.jst_make_dummy_names()`](https://jma61.github.io/jstats/reference/dot-jst_make_dummy_names.md)
builds a dummy name and matched against the registration's stored
labels, which pins each value to the code it was registered under. A
registered category with no matching value in the column is left NA, so
its dummy comes out all zero, as an absent numeric code does. For
numeric, haven-labelled and logical variables the codes are the values
themselves.

## Usage

``` r
.jst_dummy_category_values(reg, col)
```

## Arguments

- reg:

  A registration object (`var_name`, `var_type`, `codes`, `labels`,
  optionally `values`).

- col:

  The variable's column, used only for the reconstruction.

## Value

A vector the length of `reg$codes`: character for factor and character
registrations, numeric otherwise.
