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
already up to date it says so and stops. The install runs in a separate
R process so the copy of jstats loaded in your session does not lock its
own files during the install (the usual cause of a failed update on
Windows). After a successful update you restart R once to load the new
version.

## Examples

``` r
if (FALSE) { # \dontrun{
jupdate()            # update without prompting
jupdate(ask = TRUE)  # confirm before updating
} # }
```
