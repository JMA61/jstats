# Copy a data frame, carrying its classification registrations

Copies a data frame to a new name AND clones any classification
registrations (jnumeric / jcount / jdummy) attached to it, so the copy
behaves the same as the original under later analysis calls. A plain
assignment (newdata \<- mydata) copies the data but not the
registrations, because registrations live in a name-keyed session
notebook rather than on the data object; jcopy() is the verb that keeps
the two together across a rename or copy.

## Usage

``` r
jcopy(data, name, overwrite = FALSE, quiet = FALSE)
```

## Arguments

- data:

  The source data frame (unquoted). May be omitted when a juse() default
  is set, in which case the default frame is the source.

- name:

  The destination name (unquoted) the copy is assigned to. When a single
  name is given it is read as the destination, not the source.

- overwrite:

  Logical; if FALSE (the default) and the destination name already
  exists in your environment, an interactive session asks before
  overwriting.

- quiet:

  Logical; if TRUE, suppress the confirmation message.

## Value

Invisibly NULL. Called for its side effect: the copy is assigned into
the calling environment under `name`, and its registrations are cloned
onto that name.

## Details

Like jload(), jcopy() cannot see the name on the left of an assignment,
so the new name is supplied as an argument. The destination name is
unquoted, and a single name is always taken as the destination, with the
source coming from the juse() default:

- `jcopy(mydata, newdata)` – copy `mydata` to `newdata`.

- `jcopy(newdata)` – copy the juse() default frame to `newdata`.

Registrations travel only when the source frame carries them; copying an
unregistered frame just copies the data. The copy is independent of the
original.

## See also

[`jload`](https://jma61.github.io/jstats/reference/jload.md),
[`jsave`](https://jma61.github.io/jstats/reference/jsave.md),
[`juse`](https://jma61.github.io/jstats/reference/juse.md)

## Examples

``` r
if (FALSE) { # \dontrun{
  jdummy(community, Region)        # register a classification on community
  jcopy(community, survey)         # survey carries Region's registration

  juse(community)
  jcopy(survey2)                   # copy the default (community) to survey2
} # }
```
