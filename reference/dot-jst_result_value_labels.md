# Internal helper: the codes and labels a result holds for a variable

For the code line of ruling R72's note: a variable's labelled codes as
the result holds them, so the jrelabel() line keeps them.

## Usage

``` r
.jst_result_value_labels(results, v)
```

## Arguments

- results:

  The results.

- v:

  The variable's name.

## Value

A named character vector (code = label), or NULL.
