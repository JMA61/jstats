# Internal: the lettered markers a column carries, in cells and labels

Returns the distinct tagged missing-value letters on a column: those
carried by its cells, in order of first appearance, followed by those
declared only through value labels (forward-declared markers, which no
case carries yet), in label order. This is the same union that
[`.jst_missing_info()`](https://jma61.github.io/jstats/reference/dot-jst_missing_info.md)
takes under the Session 218 evidence rule, returned unsorted; each
caller orders it as it needs (jconvert sorts by letter, since 0.9.189
the order that assigns the codes).

## Usage

``` r
.jst_marker_tags(col)
```

## Arguments

- col:

  A column (any type; only a double can carry tags).

## Value

A list with two character vectors, without the leading period: `all`,
every marker the column carries; and `label_only`, the markers found in
value labels and in no cell. Both are empty for a column that is not a
double.

## Details

Added Session 314 (AUDIT-051). `jconvert(to = "spss")` built its
declared-code set from cell tags alone, so a label-only marker kept its
label but lost its declaration. The pre-flight, the conversion, and the
jsave .sav error's style probe now read this helper.
