# Internal helper: write the parts into a .docx file

The parts are written to a folder of their own under tempdir() and
packed from it by zip::zip(), the content-types part first, then the
folder is removed. The file is written to a temporary name beside the
destination and renamed into place, so a failed write leaves no part of
a file.

## Usage

``` r
.jst_docx_pack(parts, file)
```

## Arguments

- parts:

  The named list of parts.

- file:

  The destination path.

## Value

The path, invisibly.
