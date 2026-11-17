# Internal helper: the visible style folder the jstats-folder note names

Documents/Styles, by its full path, worked out on the computer: R's home
folder is the Documents folder on Windows (C:/Users/jeff/Documents, or
OneDrive's), so the folder is in it; on a Mac and on Linux the home
folder holds Documents. A home whose last part is Documents is taken as
the Documents folder whatever the system, so no test of the system is
needed. joptions(style.dir =) creates the folder when the line is run.

## Usage

``` r
.jst_style_visible_dir(home = path.expand("~"))
```

## Arguments

- home:

  The home folder (`path.expand("~")`); an argument so a battery can
  stand in for either shape. Its backslashes become forward slashes and
  a trailing one is dropped; it is not otherwise normalized, since R's
  home folder is already a full path, and normalizePath() on Windows
  would put a drive before a stand-in's "/Users/...".

## Value

Character(1), with forward slashes.

## Details

The folder is Styles, with a capital S, since Session 435 (the (S434)
item; Jeff: "we should lock in the Styles with a capital S to be used
everywhere for consistency"), beside the folders the guides use (Data,
Tables, Scripts); until then it was "jstats styles". No code reads a
folder named the old way (no backward compatibility before CRAN): a
session whose joptions(style.dir =) line names it keeps that folder.
