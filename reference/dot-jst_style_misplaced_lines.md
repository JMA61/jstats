# Internal helper: what to say of a setting in the wrong part

The reason, then where the setting goes: for a style file's line, or for
a setting given to jstyle() in a section's list. One home for both
doors' sentences (the S383 rule).

## Usage

``` r
.jst_style_misplaced_lines(w, k, sec, door = c("file", "call"))
```

## Arguments

- w:

  What
  [`.jst_style_misplaced()`](https://jma61.github.io/jstats/reference/dot-jst_style_misplaced.md)
  returned.

- k, sec:

  The setting and the part it was set in.

- door:

  "file" or "call".

## Value

Character: the sentences, one an element; the call door's last one
introduces the line its caller adds.
