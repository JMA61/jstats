# Internal: the confirmation's lines for a text variable

The `.jst_jdeclare_missing_body()` structure for a text variable's
resulting declaration (Slate E5), read from the column the call
produced: each declared string as jfreq()'s Missing rows show it
(`REF ["Refused"]`, `<blank>`), marked "no label" when it has none and
"not present in the data" when no cell holds it.

## Usage

``` r
.jst_jdeclare_missing_text_body(new_col)
```

## Arguments

- new_col:

  The declared variable.

## Value

A list of `text`, `notes` and `absent`.
