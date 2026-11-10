# Internal helper: draw a picture on a file device, then close it

The device the session had open before – RStudio's Plots pane – is made
current again afterwards, so writing a figure leaves the user's plots
where they were.

## Usage

``` r
.jst_figure_on_device(open, p)
```

## Arguments

- open:

  A function that opens the file device.

- p:

  The picture.
