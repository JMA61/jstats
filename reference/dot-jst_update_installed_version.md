# Internal helper: the version of jstats now installed in a library folder

Reads the installed package's metadata from lib on disk – not the loaded
namespace – so that after a child process has installed an update the
answer reflects what the child left there. (S309)

## Usage

``` r
.jst_update_installed_version(lib)
```

## Arguments

- lib:

  A single library path.

## Value

The version string, or NULL when no jstats is installed in lib.
