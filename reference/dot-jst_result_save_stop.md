# Internal helper: jsave() given a saved result or a built table

Session 406 (the (Session 128) item, decided at Capability Slate T's
build 5: no jstats verb, since base R keeps any R object): jsave() saves
data frames, so it stops, and gives the base R lines that keep the
object and read it back – named as typed, the file the call gave with
.rds in place of its extension, else the object's name with .rds; a
built table first gets the line that writes it to Word.

## Usage

``` r
.jst_result_save_stop(data_sub, val, file = NULL)
```

## Arguments

- data_sub:

  The data argument as typed.

- val:

  Its value.

- file:

  The call's file, or NULL.
