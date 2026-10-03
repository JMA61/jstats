# Internal: create the configured data folder, or stop

The one place the data folder is created: `joptions(data.dir = ...)`
calls it when the setting is made (S332) and
[`jsave()`](https://jma61.github.io/jstats/reference/jsave.md) when a
bare-filename save finds the folder gone. Nested paths are created in
full. A folder that cannot be created stops in the Rule AH form – what
could not be done, the path on a line of its own (a path with spaces
must not be word-filled apart), then R's own message relayed.

## Usage

``` r
.jst_create_data_dir(dir, fn, tail = "")
```

## Arguments

- dir:

  Character(1). The folder to create.

- fn:

  Character(1). The public function named in the error prefix.

- tail:

  Character(1). A closing sentence for the error, with its leading
  newline; `""` for none.

## Value

`TRUE` if the folder was created, `FALSE` if it was already there. The
caller emits the note
([`.jst_data_dir_created_note()`](https://jma61.github.io/jstats/reference/dot-jst_data_dir_created_note.md))
where it belongs in its output.
