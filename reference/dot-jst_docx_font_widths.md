# Internal helper: the advance widths a table's font is measured in

Times New Roman's for that face and the faces that share its metrics
(Times, Liberation Serif, Tinos), and for no font named (NULL: the
measure until Session 407); Arial's for Arial, Helvetica, Liberation
Sans and Arimo; Calibri's for Calibri and Carlito; for any other font
the generous table. The name is compared without regard to case or outer
spaces. The unknown-character width rides as the attribute "other": half
an em in Times, as before, and each face's digit width elsewhere.

## Usage

``` r
.jst_docx_font_widths(font = NULL)
```

## Arguments

- font:

  Character(1), or NULL.

## Value

A named numeric vector, in thousandths of an em.
