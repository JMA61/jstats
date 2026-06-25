# Register variables as counts for analysis

`jcount()` tells jstats to treat one or more variables as count
variables (non-negative whole-number tallies). A count is numeric-like –
it passes wherever a numeric variable does and shows mean/median in
[`jscreen`](https://jma61.github.io/jstats/reference/jscreen.md) – and
additionally carries count semantics: it is the asserted signal behind
the count-regression caveat in
[`jlm`](https://jma61.github.io/jstats/reference/jlm.md) and the routing
target for future count-model functions. Unlike the structural guess,
jcount accepts counts of any range, including those outside the
automatic small-range detection (e.g. a 0-30 victimization count).

## Usage

``` r
jcount(data, ..., remove = FALSE, clear.all = FALSE)
```

## Arguments

- data:

  A data frame, or omitted to use the
  [`juse`](https://jma61.github.io/jstats/reference/juse.md) default.
  `jcount(NULL)` clears the count registrations on the
  [`juse`](https://jma61.github.io/jstats/reference/juse.md) default
  frame (or, with no default set, the only frame that carries them; if
  several do, it asks rather than wiping all). `jcount(data, NULL)`
  clears that one frame's count registrations. Called with no arguments,
  `jcount()` lists the session's numeric and count registrations.

- ...:

  One or more unquoted variable names to register.

- remove:

  Logical; if `TRUE`, remove the count registration for the named
  variables instead of adding it.

- clear.all:

  Logical; if `TRUE`, clear count registrations on every data frame that
  carries them.

## Value

`invisible(NULL)`. Called for its side effect on the session
registration notebook.

## Details

A variable carries exactly one registered intent at a time, so
registering it as a count clears any prior dummy or numeric
registration. Registration changes no data and assigns nothing. It is
stored for the session, keyed by the data frame's name; save the data
frame in R format (.rds) to keep it across sessions.

## See also

[`jnumeric`](https://jma61.github.io/jstats/reference/jnumeric.md),
[`jdummy`](https://jma61.github.io/jstats/reference/jdummy.md)

## Examples

``` r
df <- data.frame(arrests = c(0, 1, 2, 0, 3, 1, 0, 12),
                 age      = c(21, 34, 45, 29, 51, 38, 26, 60))
jcount(df, arrests)                 # treat as a count (here 0-12)
#> Count registration set for 'arrests' in df.
#> Note: this registration is stored for this session only.
#> To keep it across sessions, save the data frame in R format (.rds):
#>   jsave(df, "df.rds")
#> 
#> Next session, load that file to restore the registration:
#>   df <- jload("df.rds")
jcount(df, arrests, remove = TRUE)
#> Count registration removed for 'arrests' in df.
jcount()                            # list all registrations
#> No variable registrations in this session.
jcount(df, NULL)                    # clear df's count registrations
#> No count registrations to clear for df.
jcount(clear.all = TRUE)            # clear every frame's count registrations
#> No count registrations to clear.
```
