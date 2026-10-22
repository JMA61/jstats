# Internal helper: jai()'s writers and a folder R cannot write to

jai("project") and jai("machine") wrote with writeLines(), so a folder R
cannot write to – a read-only or protected one, or one an AI assistant's
sandbox mode keeps writes out of – stopped in R's own words, "cannot
open file ... Permission denied", after the user had answered the
question (Session 391; the (S206) item, jsave() and jupdate() having
said so since Session 340). The folder, or the nearest one that exists
when the skill file's folders are still to be made, is probed as jsave()
probes it (.jst_lib_writable()), before any question, and a folder R
cannot write to stops: "R cannot write to this folder:", the folder on
its own line, "Nothing was written." and the path = line. A write that
is REDIRECTED rather than refused cannot be seen from here.

## Usage

``` r
.jst_jai_check_writable(dir)
```

## Arguments

- dir:

  Character(1). The folder the file goes in.

## Value

Invisible NULL when the folder can be written to; stops otherwise.
