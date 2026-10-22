# Internal helper: jrelabel()'s note on the labels kept (ruling R37)

"Note: The declared missing values of Education kept their labels:" and,
on an indented line of its own, the values – each in the form jfreq()'s
Missing rows use
([`.jst_udm_row_label()`](https://jma61.github.io/jstats/reference/dot-jst_udm_row_label.md)),
a code as
[`.jst_fmt_code()`](https://jma61.github.io/jstats/reference/dot-jst_fmt_code.md)
gives it, a marker by its letter (.a) – as the load narrative lists a
variable's declared values. On a line of their own the values start at
the margin, where in the sentence a wrap could part -99 from its label.
Variables keeping the same labels share one note; a variable with one
such value "kept its label". At the standard and full output levels, as
jrelabel()'s other lines. Session 391.

## Usage

``` r
.jst_relabel_kept_note(kept)
```

## Arguments

- kept:

  Named list: for each variable that kept labels, the
  [`.jst_declared_labels_kept()`](https://jma61.github.io/jstats/reference/dot-jst_declared_labels_kept.md)
  result.

## Value

Character(1), the notes one blank line apart, or NULL.
