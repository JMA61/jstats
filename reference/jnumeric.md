# Register variables as numeric for analysis

`jnumeric()` tells jstats to treat one or more variables as numeric
(continuous) wherever their analysis class matters, overriding the
package's automatic structural guess. It is the counterpart to
[`jdummy`](https://jma61.github.io/jstats/reference/jdummy.md)
(categorical) and
[`jcount`](https://jma61.github.io/jstats/reference/jcount.md) (count):
a variable carries exactly one registered intent at a time, so
registering it as numeric clears any prior dummy or count registration.
Registration changes no data and assigns nothing – you do not write
`df <- jnumeric(...)`. It is stored for the session, keyed by the data
frame's name; save the data frame in R format (.rds) to keep it across
sessions.

## Usage

``` r
jnumeric(data, ..., remove = FALSE, clear.all = FALSE)
```

## Arguments

- data:

  A data frame, or omitted to use the
  [`juse`](https://jma61.github.io/jstats/reference/juse.md) default.
  `jnumeric(NULL)` clears the numeric registrations on the
  [`juse`](https://jma61.github.io/jstats/reference/juse.md) default
  frame (or, with no default set, the only frame that carries them; if
  several do, it asks rather than wiping all). `jnumeric(data, NULL)`
  clears that one frame's numeric registrations. Called with no
  arguments, `jnumeric()` lists the session's numeric and count
  registrations.

- ...:

  One or more unquoted variable names to register.

- remove:

  Logical; if `TRUE`, remove the numeric registration for the named
  variables instead of adding it.

- clear.all:

  Logical; if `TRUE`, clear numeric registrations on every data frame
  that carries them.

## Value

`invisible(NULL)`. Called for its side effect on the session
registration notebook.

## Details

The typical use is a small-range whole number that the structural
classifier would treat as categorical (e.g. a 0-6 attitude item) but
that you want analyzed as a continuous score.

## See also

[`jdummy`](https://jma61.github.io/jstats/reference/jdummy.md),
[`jcount`](https://jma61.github.io/jstats/reference/jcount.md)

## Examples

``` r
# Treat a labelled Likert item as a continuous score (slope-per-unit)
jnumeric(community, Environment2)             # one labelled 1-5 item
#> Numeric registration set for 'Environment2' in community.
#> Note: this registration is stored for this session only.
#> To keep it across sessions, save the data frame in R format (.rds):
#>   jsave(community, "community.rds")
#> 
#> Next session, load that file to restore the registration:
#>   community <- jload("community.rds")
jnumeric(community, Environment2, Environment4)  # several at once
#> Numeric registration set for 'Environment2', 'Environment4' in community.
#> Note: registrations are stored for this session only.
#> To keep them across sessions, save the data frame in R format (.rds):
#>   jsave(community, "community.rds")
#> 
#> Next session, load that file to restore the registrations:
#>   community <- jload("community.rds")
jnumeric(community, Environment2, remove = TRUE) # unregister one
#> Numeric registration removed for 'Environment2' in community.
jnumeric()                          # list all registrations
#> Variable Registrations
#> Data frame: community
#> 
#>   Environment4: numeric
#> 
jnumeric(community, NULL)           # clear community's numeric registrations
#> Numeric registrations cleared for community: Environment4.
jnumeric(clear.all = TRUE)          # clear every frame's numeric registrations
#> No numeric registrations to clear.
```
