# Internal helper: check that variable names exist in a data frame

Produces clear error messages for several common user mistakes:

- data passed as a character string (quoted dataset name)

- data NULL

- data is a matrix (needs as.data.frame())

- data is some other non-data-frame object

- data is a valid data frame, but the variable names don't appear in it

## Usage

``` r
.jst_check_vars(data, var_names, data_name = NULL, default_used = FALSE)
```

## Arguments

- data:

  The object passed as the data frame.

- var_names:

  Character vector of variable names to check.

- data_name:

  Optional name of the data frame, used in messages.

- default_used:

  Logical. TRUE when the data frame came from the juse() default rather
  than being named in the call; adds a targeted hint to the not-found
  message that names the default and suggests the user may have meant a
  different loaded data frame. Defaults to FALSE, so callers that do not
  pass it get the unchanged message.

## Details

Without these tailored messages, a string or other non-data-frame value
for `data` would fall through to the variable-name check and produce a
misleading "Variable(s) not found" error pointing at the variables
rather than at the real problem (the data argument itself).
