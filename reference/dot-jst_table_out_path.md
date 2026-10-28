# Internal helper: where jtable() writes a file

A path with a folder is used as given, and its folder must exist; a bare
name goes in the output folder, `joptions(output.dir = )`, created again
here if it has been removed since it was set (as jsave() re-creates
data.dir), or in the working directory when none is set.

## Usage

``` r
.jst_table_out_path(file)
```

## Arguments

- file:

  The file argument.

## Value

The path to write.
