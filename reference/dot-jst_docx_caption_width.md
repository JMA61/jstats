# Internal helper: the width a caption row needs to keep its title on one line

Session 407 (Jeff: "Frequency Distributions should be on a single
line"): under caption.position = row the caption is the table's first
row, so it wraps at the table's width; this is the width at which it
does not – in apa's form the wider of the bold "Table 1" and the italic
title, in the journal's and the report's their one line – in the table's
font at caption.size, with the cell margins. Zero for a caption set as a
paragraph, which runs the page's width.

## Usage

``` r
.jst_docx_caption_width(tbl, style, number)
```

## Arguments

- tbl:

  A jst_table.

- style:

  The style list.

- number:

  The table's number.

## Value

Integer, dxa.
