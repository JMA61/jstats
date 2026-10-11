# Internal: jload()'s file argument when it is not a file name

Called by jload() with the argument as typed and its value, before the
generic "Provide a filename" stop (Session 351, Fix Slate 6). Two inputs
get a stop of their own:

- a data frame – for a shipped dataset's name (jload(community), the
  quotes left off the documented jload("community")) the quoted call;
  for any other frame named by itself, that it is already loaded and the
  jsave() call that writes it to a file (the Session 40 item);

- an empty string that an EXPRESSION gave – a variable, or a call such
  as system.file() finding no file (the S197 item, a failure mode an AI
  assistant was seen to produce). The expression is the subject of the
  sentence; for system.file() a second line says it gives an empty
  string when the file is not in the package. An empty string typed as
  such keeps the generic stop.

Anything else returns and meets jload()'s own checks.

## Usage

``` r
.jst_jload_file_value(file_sub, value)
```

## Arguments

- file_sub:

  The file argument as typed, from substitute().

- value:

  Its value, already forced by jload().

## Value

Invisibly NULL, or stops through .jst_stop().
