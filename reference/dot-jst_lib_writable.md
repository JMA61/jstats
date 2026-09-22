# Internal helper: can this session write into a library folder?

Tries to create and remove a scratch directory inside lib, R core's own
test in install.packages() ("file.access is unreliable on Windows ...
the only known reliable way is to try it"); used on every platform
because the attempt is the ground truth on all of them. A folder that
does not exist is not writable. (S309)

## Usage

``` r
.jst_lib_writable(lib)
```

## Arguments

- lib:

  A single library path.

## Value

TRUE or FALSE.
