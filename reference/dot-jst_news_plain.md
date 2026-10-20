# Internal helper: Markdown markup taken out of a line of NEWS.md

The backticks around code and the asterisks of bold, which the Console
would show as typed; a link becomes its text with the address in
parentheses, and an address in angle brackets the address. Typographic
dashes, quotation marks, the ellipsis and the no-break space become
their ASCII forms, as in every runtime string. Single asterisks and
underscores are left alone: in this file they are more often code
(`x * z`) than emphasis.

## Usage

``` r
.jst_news_plain(x)
```

## Arguments

- x:

  Character vector.

## Value

Character vector.
