# Internal helper: validate named arguments captured via ...

Catches mis-named argument aliases that users sometimes type instead of
the correct name and errors with a "Did you mean" suggestion. Also
catches any other named argument in `...` that isn't on the aliases list
and errors with a plain unused-argument message. Used by functions that
accept `...` as a safety net (not for substantive variable-passing).

## Usage

``` r
.jst_check_args(dots, aliases, fn_name)
```

## Arguments

- dots:

  A list of arguments captured via `list(...)`.

- aliases:

  Named character vector. Names are the incorrect argument names that
  users might type; values are the correct argument names to suggest in
  the error message.

- fn_name:

  Character. The calling function's name, used in the error message.

## Value

`invisible(NULL)`. Called for its side effect of throwing an error when
an invalid argument name is found.
