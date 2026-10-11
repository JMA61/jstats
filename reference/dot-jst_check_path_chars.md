# Internal: stop on a path holding characters R made from single backslashes

A Windows path typed or pasted into R with single backslashes reaches
the function changed: inside quoted text R reads a backslash and the
letter after it as one special character, so a backslash before t
becomes a tab and one before n a new line, and the file is then reported
not found under a name the user never typed (Session 343, Jeff's
decision; built Session 351). An ILLEGAL escape, such as a backslash
before the digit 5, stops R while it reads the line, before any function
runs; that case is the guides' Troubleshooting entry, not this check's.

## Usage

``` r
.jst_check_path_chars(path, what = "path")
```

## Arguments

- path:

  The path argument as received.

- what:

  The noun for it in the fix line, "path" or "folder".

## Value

Invisibly NULL when the path holds no control character; otherwise stops
through .jst_stop().

## Details

A path holding a control character (below a space, or DEL) stops here,
before the file is looked for. The message quotes the path as R holds it
– deparse() writes the characters back as the escapes that made them –
and, when every such character is one of the seven a backslash and a
letter make (bell, backspace, tab, new line, vertical tab, form feed,
carriage return), gives the same path with forward slashes; otherwise
the instruction alone, since an octal or hex escape cannot be told from
the character it made. A path with none passes untouched: spaces, a UNC
path and doubled backslashes hold no control character. Callers: jload()
and jsave() on their file argument, joptions() on data.dir.
