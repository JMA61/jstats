# Internal helper: the tables in a file that could have been one

At joutput("full"), for a call that writes built tables (Session 406;
Jeff: "the possibility of combining more than one result in the same
table if the user doesn't specify a combined table when it's possible"):
tables whose results share their columns (ruling R54) and hold no
variable twice are named, with the line that makes them one table when
every result's name is known. Tables kept apart on purpose are common,
so the note is advisory.

## Usage

``` r
.jst_table_combine_hint(tables)
```

## Arguments

- tables:

  A list of jst_table.
