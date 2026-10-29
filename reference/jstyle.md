# Show, list and copy table styles

A style holds a table's look and a journal's or a report's conventions:
the font, the caption's form, the rules, the decimals, and for each
table type its columns and labels. `jstyle()` lists the styles jstats
can find; `jstyle("myjournal")` prints every setting the style gives,
marking each one it takes from another style; and
`jstyle("apa", save.as = "myjournal")` saves a copy as a style file,
myjournal.jstyle, every setting written out with a note on what it does,
to edit in any text editor (the step SPSS calls "Save TableLook As").

## Usage

``` r
jstyle(style = NULL, save.as = NULL, overwrite = FALSE, ...)
```

## Arguments

- style:

  The style's name in quotes, or a path to a style file; NULL (the
  default) lists the styles, or with `save.as` copies
  `joptions(style = )`.

- save.as:

  A name for the copy, in quotes: written as `<name>.jstyle` in the
  style folder when one is set, else in your jstats folder
  (`tools::R_user_dir("jstats")`), or to a path given with a folder.

- overwrite:

  Logical. Replace a style file that exists? With FALSE (the default) an
  interactive session asks, and one that cannot ask stops.

- ...:

  Not used. An input `jstyle()` does not take stops with "unused input".

## Value

Invisibly: the styles found (a data frame of name and path), the style,
or the path of the file written.

## Details

A style file is plain text: a setting is a name, an equals sign and a
value; a `#` starts a note; the general settings come first, then one
section per table type, `[descriptives]` and `[frequencies]`. A setting
the file leaves out comes from the style its `based.on` line names.
jstats looks for a style named in a call in the style folder
(`joptions(style.dir = )`), the working directory and your jstats
folder, in that order.
