# Internal helper: is a style file in the hidden per-user folder?

Internal helper: is a style file in the hidden per-user folder?

## Usage

``` r
.jst_style_in_hidden_folder(path)
```

## Arguments

- path:

  The file's path.

## Value

Logical(1): TRUE when the file is in
`tools::R_user_dir("jstats", "data")`, the folder jstyle(save.as =)
writes to when no style folder is set.
