# Internal helper: the font family R draws a style's font with

Arial and its kin draw as R's "sans" family, which is Arial on Windows
and Helvetica, of the same widths, on a Mac; Times New Roman and its kin
as "serif"; Courier New as "mono". So the built-ins draw on every
device, the PDF device R CMD check and a script use among them. Any
other face is passed by name, where a device can find it: the PDF and
PostScript devices know only their own fonts, so there it is drawn as
"sans"; Windows' devices need the face named in R's font table, which is
done here once for the session.

## Usage

``` r
.jst_plot_family(font, device = NULL)
```

## Arguments

- font:

  Character(1), the style's font.

- device:

  NULL for the device a plot will be drawn on now, or the name of the
  device it will be drawn on ("png", "pdf", "postscript").

## Value

Character(1), a font family.
