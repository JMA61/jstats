# Internal helper: the news an update brings, ready to print

After a successful update, jupdate() prints the entries of the NEWS.md
the new version installed, for the versions newer than the one the
session had, so a tester who updates sees what changed without visiting
the release page (Capability Slate C4, Session 379; Jeff, S378: "we can
have jupdate print the news file - at least until the time right when
I'm going to submit to CRAN, at which point it can be re-evaluated."). R
installs a package's NEWS.md at the top of its folder in the library,
from a source package and in a binary alike (observed on R 4.3.3, S379),
so the file is read from the library the update went into – never the
loaded copy, which is the old version – as
.jst_update_installed_version() reads the version.

## Usage

``` r
.jst_update_news(lib, from, to)
```

## Arguments

- lib:

  The library folder the update was installed into.

- from:

  The version the session had before the update.

- to:

  The version now installed.

## Value

Character(1): "", or the lead line, the entries newest first and a
closing blank line, to be spliced into jupdate()'s message.

## Details

Nothing here can cost the user the update: a file that is missing or
unreadable, or that holds no entry newer than `from`, gives "", and
jupdate()'s success message prints as it always has. A file that cannot
be opened makes readLines() WARN before it errors (as an address that
cannot be read does, Session 340), so a warning is caught as an error is
and gives "" – otherwise R's "cannot open file" would print under a
successful update (found by startup_check.R I08).
