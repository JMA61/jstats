# Internal helper: put a written file in place, R's warnings kept back

The last step of a write (Session 430): the temporary file renamed over
the destination, or, where the rename is refused, copied over it. A
destination another program holds refuses both, and R said so in two
warnings of its own, file.rename()'s "Access is denied" and
file.create()'s "Permission denied", after jtable()'s stop had already
said it in the house voice ("The warning is cryptic." – Jeff, S429). The
warnings are kept back here and the caller stops; the temporary file is
removed whatever happens.

## Usage

``` r
.jst_move_into_place(tmp, dest)
```

## Arguments

- tmp:

  The temporary file.

- dest:

  The destination.

## Value

TRUE when the file is in place, FALSE otherwise.
