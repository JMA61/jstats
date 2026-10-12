# Internal helper: a target format given where jconvert() takes variables

Until v0.9.227 `to` was
[`jconvert()`](https://jma61.github.io/jstats/reference/jconvert.md)'s
second formal, so `jconvert(d, Education)` bound Education to `to`: R's
"object 'Education' not found", or, with a workspace object of that
name, its value taken as the target and the whole frame converted
(Session 354, ruling A of the S243 item). The dots are second now, as in
every data-first function, and the target is always named – as every
printed line names it. This check gives the old positional form the line
to run: a format name typed in quotes or bare (`jconvert(d, "stata")`,
`jconvert(d, stata)`), or a name holding one
(`fmt <- "stata"; jconvert(d, fmt)`), stops with the call rebuilt as
`jconvert(d, <the other variables>, to = "stata")`, keeping
`modify = TRUE` when the call had it. A name the data frame has is a
variable, whatever it is called.

## Usage

``` r
.jst_convert_target_pointer(variables, data, data_name, modify)
```

## Arguments

- variables:

  The quosures of `...`, after the juse() prepend.

- data:

  The resolved data frame.

- data_name:

  Its name, for the line.

- modify:

  The call's `modify` flag.

## Value

Invisible NULL; stops when a target format is found.
