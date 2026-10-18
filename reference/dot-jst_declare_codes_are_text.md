# Internal helper: are a jdeclare_missing() call's codes words?

TRUE when the codes (or, with no codes, the labels string) cannot be
read as numbers or markers – words, which only a text variable holds.
Decides the route of a call that names text and numeric variables
together.

## Usage

``` r
.jst_declare_codes_are_text(codes, labels)
```

## Arguments

- codes:

  The codes as given, or NULL.

- labels:

  The labels string as given, or NULL.

## Value

Logical(1).
