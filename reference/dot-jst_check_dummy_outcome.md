# Internal helper: block a dummy-registered variable from being an outcome

LHS-scoped guard for the model functions (jlm / jlogistic / jaov / jt,
and future jpoisson / jnegbin). A variable the user registered with
jdummy() has been declared categorical-with-a-reference; using it as the
response is a category error, so this raises a stop() at DV resolution –
before any IV/group handling. Scoped to the outcome only: a registered
dummy is a legitimate predictor (jlm / jlogistic) or grouping variable
(jaov / jt), so those uses are never touched. The remedy differs by
family: jlogistic points to 0/1 recoding (it needs a binary outcome);
the others point to clearing the registration (the variable is then read
in its native form).

## Usage

``` r
.jst_check_dummy_outcome(data_name, dv_name, fn)
```

## Arguments

- data_name:

  Character data-frame name (may be NULL for a bare frame).

- dv_name:

  Character name of the outcome (response) variable.

- fn:

  The calling user-facing function name, e.g. "jlm".

## Value

`invisible(NULL)` when the outcome is not a registered dummy; otherwise
signals an error and does not return.
