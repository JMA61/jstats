# Internal helper: the visible style folder the jstats-folder note names

Documents/jstats styles, by its full path, worked out on the computer:
R's home folder is the Documents folder on Windows
(C:/Users/jeff/Documents, or OneDrive's), so the folder is in it; on a
Mac and on Linux the home folder holds Documents. A home whose last part
is Documents is taken as the Documents folder whatever the system, so no
test of the system is needed. joptions(style.dir =) creates the folder
when the line is run.

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
