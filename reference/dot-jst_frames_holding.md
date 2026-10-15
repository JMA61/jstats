# Internal helper: the data frames in the workspace that hold a variable

Walks from `envir` to the global environment, as
[`.jst_loose_twins()`](https://jma61.github.io/jstats/reference/dot-jst_loose_twins.md)
does, and names every data frame (a tibble and an sf frame are data
frames) that has every one of `vars` as a column. Objects a package
supplies are not seen: the walk stops at the global environment. Ruling
R18 (Session 356): the vector-path line and the fix lines that named
MyData read this.

## Usage

``` r
.jst_frames_holding(vars, envir)

.jst_frame_holding(vars, envir)
```

## Arguments

- vars:

  Character; variable names.

- envir:

  The caller's environment.

## Value

Character; the frames' names, sorted; empty when none. A hidden object
(a name starting with a dot) is not seen.

For `.jst_frame_holding()`: the one frame's name, or NULL when none or
several hold the variables.
