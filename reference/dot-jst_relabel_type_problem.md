# Internal helper: what keeps a variable from carrying value labels

NULL for a haven-labelled numeric, a plain numeric or a logical
variable; otherwise a list: `kind` ("a factor", "a character (text)
variable", "a date/time variable", "of type list") and `convert` (TRUE
where jencode() is the way to numbers). The list form's refusal (Session
378); the one-variable form keeps its own sentences.

## Usage

``` r
.jst_relabel_type_problem(x)
```

## Arguments

- x:

  The variable.

## Value

NULL or a list.
