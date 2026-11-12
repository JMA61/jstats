# Internal helper: a style file saved with .txt after its name

A style that comes back from an AI assistant, or out of a text editor,
is often saved as name.jstyle.txt or name.txt, which no lookup reads:
.jstyle is the one extension (ruling R81, Session 419). The folders a
style name is looked for in are read for such a file, so the stop for a
name not found can name it and give the line that renames it.
name.jstyle.txt counts whatever it holds; name.txt only when its text
reads as a style file
([`.jst_style_text_like()`](https://jma61.github.io/jstats/reference/dot-jst_style_text_like.md)),
since a folder may hold a notes file of any name. A built-in's name
never comes here: the built-in is loaded before any file is looked for,
and a built-in's name typed with .txt gets the did-you-mean first.

## Usage

``` r
.jst_style_txt_twin(stem)
```

## Arguments

- stem:

  Character(1); the style's name, without .jstyle or .txt.

## Value

NULL, or a list: from (the file found), to (the name it needs) and where
(the folder's role, opening a sentence).
