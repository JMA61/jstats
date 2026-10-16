# Internal: the names a save format refuses

jsave()'s check before writing .sav, .dta or .xpt (the import audit's
third finding; Session 362). haven checks some rules and ReadStat
others, one name at a time, in haven's own words: a Stata save named
only a long name, then, fixed, "2024 score", then "Age (years)". This
one check holds each format's rules and reports every name at once, with
the name it would be given and why:

- sav:

  haven's own test: a letter or @ first; letters, digits and . \_ \$ \#
  @ after, not ending in a period; at most 64 bytes; not ALL AND BY EQ
  GE GT LE LT NE NOT OR TO WITH in any case; unique ignoring case.

- dta:

  a letter or underscore first, letters, digits and underscores after;
  at most 32 characters; not a word Stata reserves (ReadStat's list,
  probed S362, and str followed by digits).

- xpt:

  A to Z, digits and underscores, not a digit first; at most 32
  characters; not *N*, *ERROR*, *ALL*, *NUMERIC* or *CHARACTER*; unique
  ignoring case (SAS folds case; haven writes both names).

## Usage

``` r
.jst_save_name_problems(nm, ext)
```

## Arguments

- nm:

  Character vector of names.

- ext:

  "sav", "dta" or "xpt".

## Value

data.frame(pos, old, new, why), one row per refused name; zero rows when
every name can be written.
