# Internal helper: should a "seems categorical" hedge fire for this variable?

The shared trigger predicate for the structural ("seems") warning sites
(jdesc, jcorr, the jt outcome, the jaov outcome). Centralizing the gate
keeps the four sites from drifting on the rule. Fires when the variable
is structurally categorical-looking AND the user has not asserted a
numeric role AND it is not a Likert item. Likert items are exempt
because treating them as interval is the accepted convention; the check
covers both auto-detection and a jlikert() assertion via the resolved
sub-class.

## Usage

``` r
.jst_warns_seems_categorical(
  x,
  var_name = NULL,
  data_name = NULL,
  override = NULL
)
```

## Arguments

- x:

  A variable (vector / data-frame column).

- var_name:

  Optional character. The variable's name.

- data_name:

  Optional character. The data frame's name.

- override:

  Optional per-call asserted role ("numeric", "count", "categorical", or
  NULL), passed through to the classifier for sites that accept per-call
  overrides (jdesc, jcorr).

## Value

TRUE if the hedge should fire, FALSE otherwise.
