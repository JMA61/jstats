# Internal helper: a table type's setting given to jstyle() bare

A setting of a table type's section goes in a list named for its section
(Session 406), since several sections can hold one name. The stop gives
the call rewritten: each such setting moved into a list for the first
section whose check takes its value; a value no section takes stops with
what the first section's setting takes.

## Usage

``` r
.jst_style_bare_stop(cl, bare)
```

## Arguments

- cl:

  The call as typed.

- bare:

  The quosures given bare, named.
