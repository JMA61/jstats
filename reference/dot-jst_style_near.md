# Internal helper: the near miss of a section or setting name

The test
[`.jst_near_choice_hint()`](https://jma61.github.io/jstats/reference/dot-jst_near_choice_hint.md)
uses: at most two edits, and fewer than half the typed name's letters.

## Usage

``` r
.jst_style_near(typed, known)
```

## Arguments

- typed:

  Character(1).

- known:

  Character; the names there are.

## Value

The nearest name, or character(0).
