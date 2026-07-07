# Internal helper: escape regex metacharacters in a literal string

Backslash-escapes every extended-regular-expression metacharacter so a
user-supplied name can be interpolated into a pattern and matched
literally. Used when rewriting a model formula string: a variable name
containing a dot (common from make.names()) would otherwise act as a
wildcard and could corrupt an unrelated predictor (see
.jst_expand_one_dummy).

## Usage

``` r
.jst_escape_regex(x)
```

## Arguments

- x:

  Character vector to escape.

## Value

`x` with regex metacharacters backslash-escaped.
