# Internal helper: bake classification registrations onto a frame for saving

Gathers the active classification registrations for a named data frame –
the jnumeric/jcount intent records (the .jst_registry notebook) and the
jdummy registrations (the .jst_dummy registry) – and attaches them to
the data frame as a single list-valued attribute (".jst_registrations")
so they travel inside an R native format (.rds) save. The original frame
name is recorded alongside as provenance only; it is informational and
is NOT used as the lookup key on load (jload re-keys under the name the
frame is loaded as, which is the name later analysis calls will
reference). The attribute is attached only when at least one
registration exists, so a frame with none is returned unchanged and
saves without the attribute. Only the .rds format carries arbitrary R
attributes, so this is called only on the .rds save path.

## Usage

``` r
.jst_bake_registrations(data, data_name)
```

## Arguments

- data:

  A data frame.

- data_name:

  Character string giving the data frame name to look up in the two
  registries.

## Value

The data frame, with a ".jst_registrations" attribute attached when
registrations exist, otherwise unchanged.
