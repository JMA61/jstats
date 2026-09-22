# Update jstats to the latest version

`jupdate()` installs the most recent version of jstats. While jstats is
in its pre-release phase this downloads and installs the latest
pre-built version; once jstats reaches CRAN, the same command will
update it the ordinary way. Either way, you run one command instead of
having to remember an install line. It is safe to call from the console,
a script, or a Quarto document.

## Usage

``` r
jupdate(ask = FALSE)
```

## Arguments

- ask:

  Logical. When `TRUE` and the session is interactive, jupdate() shows
  the available and installed versions and asks for confirmation before
  installing. Defaults to `FALSE` (update without prompting), which is
  also what happens in any non-interactive session, such as a Quarto
  render.

## Value

Invisibly `NULL`. Called for its side effect of installing the update,
and for the messages it prints.

## Details

The function checks for an internet connection first; if jstats is
already up to date it says so and stops. Otherwise it installs the
update and then confirms that the update actually happened before
reporting success.

**Where the update goes.** The update is installed into the library
folder that holds the copy of jstats currently loaded, so the version in
use is the one replaced. This matters when a computer has more than one
library folder (a system-wide one and a personal one, say): a plain
`install.packages("jstats")` puts the new version in whichever folder is
first on [`.libPaths()`](https://rdrr.io/r/base/libPaths.html), which
can leave a second copy of jstats beside the original rather than
replacing it. jupdate() follows the rule
[`update.packages()`](https://rdrr.io/r/utils/update.packages.html) uses
instead, and installs where the loaded copy lives. To see where that is,
run `find.package("jstats")`.

**If the folder cannot be written to.** Before installing, jupdate()
checks that R can create files in that folder. If it cannot – typically
a system-wide folder such as Program Files on Windows, or a folder
locked by an institution's IT policy – jupdate() stops and names the
folder, rather than installing a second copy somewhere else. Run R with
permission to write there (on your own Windows computer, usually by
starting RStudio as an administrator), or ask your IT department to
install the update.

**How success is confirmed.**
[`install.packages()`](https://rdrr.io/r/utils/install.packages.html)
only warns when it cannot download or install a package; it does not
stop. jupdate() therefore does not take a quiet install as success.
After the install it reads the version now on disk in the target folder,
and reports success only when that version is newer than the one loaded.
If it is not – a dropped connection part-way through, a repository the
network cannot reach, or a failed build – jupdate() stops, states that
the folder still holds the old version, and repeats what
[`install.packages()`](https://rdrr.io/r/utils/install.packages.html)
reported about the cause so you can see why.

**The separate process.** The install runs in a separate R process so
the copy of jstats loaded in your session does not lock its own files
during the install (the usual cause of a failed update on Windows).

**After the update.** Restart R once to load the new version; the
success message shows how.

## Examples

``` r
if (FALSE) { # \dontrun{
jupdate()            # update without prompting
jupdate(ask = TRUE)  # confirm before updating
} # }
```
