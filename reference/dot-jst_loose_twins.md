# Internal helper: the variables a separate workspace object shares a name with

Ruling R12 (Session 348): of `vars`, those for which a vector or a
factor of the same name exists in `envir` or an enclosing environment up
to the global environment – the objects a user made. A function, a data
frame, a list, and anything only a package supplies (`pi`, `letters`)
are left out: none of them could have been meant as the variable.

## Usage

``` r
.jst_loose_twins(vars, envir)
```

## Arguments

- vars:

  Character; variable names.

- envir:

  The caller's environment.

## Value

Character; the names in `vars` that have such a twin.
