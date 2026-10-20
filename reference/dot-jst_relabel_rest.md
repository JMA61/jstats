# Internal helper: the arguments of a jrelabel() call after its variable

Every named argument of the call as typed but `data`, `var`, `vars` and
`modify`, joined with commas, for a line that rebuilds the call (Session
378).

## Usage

``` r
.jst_relabel_rest(cl)
```

## Arguments

- cl:

  The call ([`sys.call()`](https://rdrr.io/r/base/sys.parent.html)).

## Value

Character(1), "" when there are none.
