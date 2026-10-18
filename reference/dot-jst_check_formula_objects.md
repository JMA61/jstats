# Internal helper: stop for a workspace object a formula reads as a variable

The formula half of ruling R19
([`.jst_frame_object()`](https://jma61.github.io/jstats/reference/dot-jst_frame_object.md)),
shared by
[`.jst_check_formula_vars()`](https://jma61.github.io/jstats/reference/dot-jst_check_formula_vars.md)
(jt, jaov, jlm, jlogistic) and the front doors of jcrosstab() and
jplot()'s formula path, where it comes before the refusal of a computed
term so a fetched object is named for what it is.

## Usage

``` r
.jst_check_formula_objects(
  formula,
  data,
  data_name,
  enclos = NULL,
  n_frame = NULL,
  term_first = FALSE
)
```

## Arguments

- formula:

  The formula as typed.

- data:

  The data frame (after the pipeline's filters, where they have run).

- data_name:

  Character; the data frame's name.

- enclos:

  The environment the formula's other names resolve in.

- n_frame:

  Integer or NULL; the frame's row count as given.

- term_first:

  Logical; a computed term that gives a categorical variable is refused
  before the object it reads is named.

## Value

Invisible NULL; stops when one is found.
