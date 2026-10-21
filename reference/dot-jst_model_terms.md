# Internal: a model's formula variables, name arguments and terms

The formula's variables checked (lm()'s reading of a computed term;
S323), numeric =, categorical = and count = read as names (ruling R18,
S376), the bare powers found on the formula as typed (S321), the
formula's environment kept for the standardized refits (S375), the
transformed terms computed (AUDIT-021) and a computed logical made 0/1
(AUDIT-028). jlm() and jlogistic() each held this block (Session 386,
the twin build).

## Usage

``` r
.jst_model_terms(
  formula,
  data,
  .jst_data_name,
  .jst_default_used,
  pipeline,
  name_subs,
  envir
)
```

## Arguments

- formula, data:

  The call's formula and the pipeline's data.

- .jst_data_name, .jst_default_used:

  The data frame's name and whether it is the juse() default.

- pipeline:

  The pipeline's result.

- name_subs:

  list(numeric, categorical, count) of the arguments' expressions
  (substitute() in the caller).

- envir:

  The caller's calling frame.

## Value

list(raw_vars, numeric, categorical, count, bare_powers, term_enclos,
resolved, formula, data).
