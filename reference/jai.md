# Print the jstats orientation, or install it for an AI assistant

`jai()` prints a short, plain-text orientation to the package's core
conventions: how to load data, how jstats handles value labels and
user-defined missing values, how to choose an analysis function, and how
to keep changes made to a data frame. It is written to be useful both to
people new to the package and to AI coding assistants (such as the
assistant built into RStudio), which read console output and can act on
what they find there.

## Usage

``` r
jai(setup = NULL, path = NULL)
```

## Arguments

- setup:

  Optional. `"project"`, `"machine"`, `"chat"`, or `"status"`; see
  Details. When missing, the orientation is printed to the console.

- path:

  Optional. An existing folder to write into, overriding the default
  destination; used only by `"project"` and `"machine"`.

## Value

Invisibly `NULL`. Called for its side effects.

## Details

Beyond the plain printout, `jai()` can install the same orientation
where an AI assistant finds it on its own. `setup` selects the situation
(values are case-insensitive):

- `"project"`:

  Writes the orientation into `AGENTS.md` in the current folder (or
  `path`), inside a clearly marked block. Assistants that read
  `AGENTS.md` then see the conventions in every conversation in that
  project. Existing content is never overwritten: the block is appended
  to an existing file, and on regeneration only the marked block is
  replaced. Keep your own additions outside the markers; they survive
  regeneration, while edits inside the block are overwritten (with a
  warning when edits are detected).

- `"machine"`:

  Writes `SKILL.md` to the user-level skills folder (or `path`), so
  assistants that support skills can load the conventions in any project
  on the machine, when relevant.

- `"chat"`:

  For chat assistants outside RStudio. Currently prints a short note; a
  paste-ready primer is planned.

- `"status"`:

  Reports which orientation files are present, their versions, and
  whether they are current. Nothing is written.

The file-writing situations confirm the exact destination before writing
(or write without asking when `path` names the folder yourself). Each
written file carries a version stamp; after updating jstats, rerun the
same `jai()` call to refresh it.

## See also

[`help("jstats")`](https://jma61.github.io/jstats/reference/jstats-package.md)
for the package overview and full function list.

## Examples

``` r
jai()
#> 
#> jstats conventions
#> 
#> Orientation for users and AI assistants.
#> Orientation text v3.1 | jstats 0.9.108 | generated 2026-07-23
#> 
#> jstats is an integrated set of j-prefixed analysis functions (jdesc,
#> jfreq, jlm, ...) with shared syntax and output styled after commercial
#> statistical software. The functions work directly with data imported from
#> SPSS, Stata, or SAS, and with R .rds files whose columns carry haven-style
#> metadata: value labels and user-defined missing values (UDM) are handled
#> automatically.
#> 
#> Note for AI assistants: jstats is newer than your training data. Do not
#> rely on remembered or inferred jstats syntax. When unsure of a function's
#> arguments, check them with args() (for example args(jdeclare_udm)) or
#> the function's help page instead of guessing.
#> 
#> - Start each session with library(jstats). If the package is not
#>   installed (there is no package called 'jstats'), do not guess an
#>   install command -- jstats is not on CRAN yet, so install.packages()
#>   alone will fail. Point the user to the install guide instead:
#>   https://jma61.github.io/jstats-guides/install-jstats.html
#> - Load data with jload(). It reads many file types (.rds, .sav, .dta,
#>   .xlsx, .csv, ...) without separate packages such as haven or readxl, and
#>   checks for undeclared missing-value codes that other loaders skip. The
#>   shipped example datasets load the same way, by bare name:
#>   jload("clinic"), jload("community") -- prefer this over data(),
#>   which skips those checks. jload() places the dataset in the global
#>   environment under its own name, so no assignment is needed, though
#>   clinic <- jload("clinic") also works.
#> - Work with one dataset at a time, as in SPSS or Stata. Set it once with
#>   juse(community); later calls then omit the data argument --
#>   jdesc(Age, Income), jt(CommuteTime ~ OwnsHome). Every result states
#>   which data frame it used. When more than one data frame is in play, pass
#>   the frame explicitly or switch the default with juse(). Prefer
#>   jsubset() and jcomplete(), which filter cases without altering the
#>   data, over creating modified copies of the data frame.
#> - Explore first with jscreen() (variable types, missing data, and
#>   outliers at a glance -- the first look at an unfamiliar dataset),
#>   jfreq() (frequencies), and jdesc() (descriptives). Prefer jstats
#>   functions over base R or tidyverse equivalents where they exist: their
#>   output accounts for declared missing values, and one consistent toolset
#>   keeps the analysis easy to follow.
#> - Declare stray codes such as -99 with
#>   jdeclare_udm(data, var, codes = c(-99, -98)) -- the argument is
#>   codes. Do not filter such values out by hand. jstats functions honor
#>   declared UDM codes; base functions such as mean() ignore them and
#>   return wrong answers with no warning.
#> - Choose the analysis function before writing any analysis code: compare
#>   group means with jt() (two groups) or jaov() (three or more); test
#>   relationships with jcorr() (correlations), jlm() (regression,
#>   numeric outcome), or jlogistic() (regression, yes/no outcome);
#>   cross-tabulate with jcrosstab(); check scale reliability with
#>   jalpha(). The group-comparison and regression functions take a formula
#>   (jt(CommuteTime ~ OwnsHome), jlm(Income ~ Age + Education));
#>   jcorr(), jalpha(), jdesc(), and jfreq() take variable names
#>   instead. For anything not listed, check help("jstats") for the full
#>   function list before reaching for another package.
#> - Analysis functions print their results directly; nothing needs to be
#>   stored. The few functions that change data, such as jdeclare_udm() and
#>   jconvert(), return the changed data frame: keep it by assigning back
#>   (df <- jdeclare_udm(df, ...)) or with modify = TRUE. jconvert()
#>   translates missing-value codes between software conventions -- it is for
#>   moving data to other software or to plain base-R form, and is never a
#>   prerequisite for analysis in jstats, which reads labelled data directly.
#>   Save data across sessions with jsave().
#> - Detailed help and worked examples for each function are available via
#>   ?jdesc, ?jdeclare_udm, and so on.
#> 
#> Guides and reference: https://jma61.github.io/jstats-guides
#> 
if (FALSE) { # \dontrun{
jai("project")   # write AGENTS.md in the current project
jai("machine")   # write SKILL.md to the skills folder
jai("status")    # report what is installed where
} # }
```
