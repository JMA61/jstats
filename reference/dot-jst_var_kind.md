# Internal helper: classify a variable's analysis-relevant type "kind"

Single source of truth for the variable-type distinctions the analysis
functions and the type gate care about. Returns the kind plus, for the
numeric-ish kinds, the coerced numeric vector. Kinds: "numeric",
"labelled", "logical", "numeric_factor", "numeric_text" (numbers stored
as text), "text_factor", "text_character", "datetime"
(Date/POSIXct/POSIXlt/difftime), "complex", "raw", "list", "other".
([`.jst_classify_desc_var()`](https://jma61.github.io/jstats/reference/dot-jst_classify_desc_var.md)
delegates to this detector for jdesc, so the variable-type rules live
here only and the two cannot drift.)

## Usage

``` r
.jst_var_kind(x)
```

## Arguments

- x:

  A variable / data-frame column.

## Value

A list with `kind` (character) and `num` (numeric vector for numeric-ish
kinds, otherwise NULL).
