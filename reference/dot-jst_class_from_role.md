# Internal helper: map an asserted analysis role to class + subclass

Shared by the classification resolver's user-intent tiers (per-call
override and registered intent) so an asserted role produces the same
class/subclass pair however it was asserted. "numeric" and "count" fix
the subclass; "categorical" still takes its dichotomy / N-category /
identifier subclass from the data structure, since the role assertion
fixes the class but not the category count. ("identifier" is a
text/factor categorical whose every non-missing value is distinct – a
cosmetic sub-class only; the variable is still Categorical for all
analysis purposes.)

## Usage

``` r
.jst_class_from_role(role, x, var_name = NULL, data_name = NULL)
```

## Arguments

- role:

  One of "numeric", "count", "categorical".

- x:

  The variable (used only to derive the categorical subclass).

- var_name:

  Optional variable name; passed through to the Likert battery detector
  so it can locate the variable among its siblings.

- data_name:

  Optional data-frame name; passed through to the Likert battery
  detector so it can read adjacent columns.

## Value

A list with `class` and `subclass`, or `NULL` if `role` is not
recognized.
