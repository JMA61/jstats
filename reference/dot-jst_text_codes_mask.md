# Internal helper: which text cells does a declared string cover?

A text variable's declared missing value matches the cells that hold it
exactly as stored – case and outer spaces count, as in SPSS – with one
exception: a declared blank (`""`, ruling R27, Slate E5) covers every
blank cell, empty or holding only spaces, tabs or line ends, as SPSS's
`MISSING VALUES S ('')` covers a string of spaces. The one comparison
every reader of a declared string makes: the masking pass, jfreq()'s
Missing rows, the Case Processing rows, jconvert(to = "baseR"),
preserve.declarations = FALSE and jsave()'s notes.

## Usage

``` r
.jst_text_codes_mask(x, codes)
```

## Arguments

- x:

  A text variable (character, or character-backed labelled).

- codes:

  Character vector of declared strings.

## Value

Logical, the length of `x`; FALSE for NA cells.
