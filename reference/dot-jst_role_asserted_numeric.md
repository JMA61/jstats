# Internal helper: is a variable's Numeric role user-asserted?

TRUE when the classification resolver places the variable in the Numeric
class (continuous or the Count subclass) via a NON-structural source – a
per-call override (numeric=/count=) or a registration (jnumeric/jcount).
Used by the analysis functions to suppress the structural "seems
categorical" hedge: that hedge is only a guess, and a user who has
asserted a numeric role has already answered it. A structural (inferred)
Numeric, or any Categorical (including a jdummy-asserted one), returns
FALSE so the hedge fires as before – the jdummy/jcorr/jdesc interaction
is deliberately left to its own (parked) design.

## Usage

``` r
.jst_role_asserted_numeric(
  x,
  var_name = NULL,
  data_name = NULL,
  override = NULL
)
```

## Arguments

- x:

  A variable / data-frame column.

- var_name:

  Optional variable name (with `data_name`) for consulting a
  registration.

- data_name:

  Optional data-frame name (with `var_name`) for consulting a
  registration.

- override:

  Optional per-call asserted role ("numeric", "count", or
  "categorical").

## Value

Logical scalar.
