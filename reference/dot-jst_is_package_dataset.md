# Internal: is a bare name a package-shipped dataset?

TRUE when `name` matches a dataset shipped in the package (see
`.jst_package_datasets`). Backs jload's shadowed-dataset note (a disk
file sharing a name with a shipped dataset) and the package = TRUE
guard, both of which need a name-only test without materialising the
data.

## Usage

``` r
.jst_is_package_dataset(name)
```

## Arguments

- name:

  Character(1). The bare name to test.

## Value

A length-one logical.
