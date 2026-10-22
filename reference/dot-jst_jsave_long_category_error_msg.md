# Internal: jsave's .sav section for a factor category SPSS cannot hold

Session 362: haven writes a factor's categories as value labels, which
SPSS holds to 120 bytes, and refused a longer one in its own words.
jsave()'s .sav pre-flight names every factor with a category longer than
120 bytes and offers the line that keeps it as text, which SPSS keeps
whole. Measured in BYTES since Session 390 (the non-English probe): it
counted characters, so a Chinese category of 41 to 120 characters (three
bytes each) passed it and was cut in the file with no word, where the
value-label note beside it already counts bytes. Moved out of jsave() at
Session 384 (split on touch, in the Build Procedure). Since Session 384
(Fix Slate 26) a factor with a label gets, after its line, the line that
puts the label back
([`.jst_label_line()`](https://jma61.github.io/jstats/reference/dot-jst_label_line.md)),
since as.character() drops it.

## Usage

``` r
.jst_jsave_long_category_error_msg(data, code_name)
```

## Arguments

- data:

  The data frame being saved.

- code_name:

  The data frame's name as the offered lines name it.

## Value

Character scalar, the section's message, or NULL when no factor has a
category longer than 120 bytes.
