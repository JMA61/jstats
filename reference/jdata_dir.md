# Return the configured data folder

Read-side companion to
[`joptions`](https://jma61.github.io/jstats/reference/joptions.md)`(data.dir = ...)`:
returns the currently configured data folder as a string, for use in
scripts that need the path itself (building a file path, checking
existence, cleaning up test files) without reaching into
package-internal option names.

## Usage

``` r
jdata_dir(default = ".")
```

## Arguments

- default:

  Value returned when no data folder is configured. Defaults to `"."`
  (the working directory).

## Value

A length-one character string (the configured folder, or `default`); or
`default` unchanged when it is `NULL`.

## Details

[`joptions()`](https://jma61.github.io/jstats/reference/joptions.md)
prints the folder but returns `invisible(NULL)`; `jdata_dir()` returns
it as a value. When no folder is configured, the `default` is returned
(`"."`, the working directory, by default), so the result drops straight
into [`file.path`](https://rdrr.io/r/base/file.path.html). Pass
`default = NULL` to detect the unconfigured state explicitly.

## See also

[`joptions`](https://jma61.github.io/jstats/reference/joptions.md) to
set the folder;
[`jload`](https://jma61.github.io/jstats/reference/jload.md) and
[`jsave`](https://jma61.github.io/jstats/reference/jsave.md), which
resolve files against it.

## Examples

``` r
if (FALSE) { # \dontrun{
joptions(data.dir = "Data")
jdata_dir()                                  # "Data"
f <- file.path(jdata_dir(), "community.rds") # build a path in that folder
if (file.exists(f)) file.remove(f)

jdata_dir(default = NULL)                    # NULL if nothing configured
} # }
```
