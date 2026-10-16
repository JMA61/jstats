# Internal: find a bare filename in the data.dir folder or the working directory

Internal: find a bare filename in the data.dir folder or the working
directory

## Usage

``` r
.jst_find_file(filename, quiet = FALSE, fallback = NULL)
```

## Arguments

- quiet:

  Logical; default FALSE. When TRUE, suppresses the "Reading from

  " note (propagated from jload()'s quiet argument). The not-found error
  is unaffected.

- fallback:

  A path returned, in place of the not-found stop, when no file of that
  name is on disk: the shipped example file of that name (Session 361),
  or NULL.
