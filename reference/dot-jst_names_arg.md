# Internal: a variable list as the vars = argument of a printed call

One name as a quoted string, several as c() of quoted strings –
`vars = "S"`, `vars = c("S", "T")` – through deparse(), so a name
holding a quotation mark or a backslash is written as R reads it.

## Usage

``` r
.jst_names_arg(v)
```

## Arguments

- v:

  Character vector of variable names.

## Value

Character scalar.
