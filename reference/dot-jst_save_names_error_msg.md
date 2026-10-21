# Internal: jsave()'s pre-flight section for refused names

Ruling R33 (Session 387): in a stop with other things to fix, above the
minimal level, this part offers no save line of its own – run where it
sits, before the other parts' fixes, it could only stop – and says that
the save closing the message makes the change; that save carries
clean.names = TRUE. Alone, the part keeps its line, which is the save.

## Usage

``` r
.jst_save_names_error_msg(probs, ext, data_name, line)
```

## Arguments

- probs:

  From .jst_save_name_problems().

- ext:

  The target.

- data_name:

  The data frame's name, for the prose.

- line:

  The jsave() call that saves with clean.names = TRUE, or NULL in a
  combined stop, where the closing save carries it.

## Value

Character(1).
