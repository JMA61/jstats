# Internal: the SAS name of the dataset inside an .xpt file

haven::write_xpt() names the dataset after the file it writes, and
jsave() writes a temporary file first, so every .xpt jsave() made until
Session 362 named its dataset jsave\_\_, and a file name over about 13
characters stopped the save ("`name` must be 32 characters or fewer").
The dataset is named after the file the user asked for, cleaned to a SAS
name: A to Z, digits and underscores, a letter or underscore first, at
most 32 characters.

## Usage

``` r
.jst_sas_member_name(stem)
```

## Arguments

- stem:

  The file name without its extension.

## Value

Character(1).
