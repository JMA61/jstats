# Encode a text variable as labelled numbers

Converts a character (text) variable into numeric codes, attaching the
original words as value labels so every later table still shows the
words. With no `map`, codes are assigned alphabetically and the
assignment is printed; with a `map`, you choose the numbers. Numbers
stored as text ("34") always convert to their own value, never to a
rank.

## Usage

``` r
jencode(data, var, map = NULL, labels = NULL, convention = NULL)
```

## Arguments

- data:

  A data frame containing the variable to encode. Can be omitted if a
  default data frame has been set with
  [`juse()`](https://jma61.github.io/jstats/reference/juse.md).

- var:

  The text variable to encode (unquoted name). Only character variables
  are accepted: factors, numeric, logical, and date/time variables are
  refused with a message naming the right tool (for numeric variables,
  that is
  [`jrecode()`](https://jma61.github.io/jstats/reference/jrecode.md)).

- map:

  Optional. A single string of semicolon-separated rules, each
  `word=number`: for example `"Bail=1; Parole=2; Remand=3"`. Matching
  against the data is case-sensitive, after outer spaces are trimmed on
  both sides (a note reports any cells that matched only after
  trimming). Words containing a semicolon must be double-quoted
  (`'"Not applicable; other"=3'`); apostrophes need no quoting:
  `map = "Yes=1; Don't know=8"` works as typed.

  Special left-hand sides: `blank=<number>` gives empty cells their own
  code (by default they are left missing, with a note showing the blank
  rule to use). Special targets: `else=NA` converts every unmapped word
  to system missing; `else=.a` (through `.z`) converts them to a tagged
  missing value under the Stata or SAS convention (see `convention`).
  `else=copy` is refused: words cannot be kept in a numeric column. A
  word may also be sent to the word `missing` – your working
  convention's own missing form, declared automatically under the SPSS
  convention (see
  [`jrecode()`](https://jma61.github.io/jstats/reference/jrecode.md)'s
  `map` for the full rule); `blank=missing` composes the two tokens.

  By default an incomplete map is an error that names the unmatched
  words (nothing is dropped silently); add an `else` rule to sweep the
  remainder deliberately, and the note then names the words it swept.

- labels:

  Optional. A single string of semicolon-separated `number=Label` pairs
  overriding the automatic labels: for example
  `"1=Low; 2=Medium; 3=High"`. If omitted, each word becomes the label
  of its own code. When several words collapse to one code, no label can
  be chosen automatically and a note directs you here or to
  [`jrelabel()`](https://jma61.github.io/jstats/reference/jrelabel.md).

- convention:

  Optional. One of `"spss"`, `"stata"`, `"sas"`, or `NULL` (default);
  any capitalization is accepted. Controls whether missing-value tokens
  (`.a` through `.z` or `.A` through `.Z`) are accepted as map targets.
  Token letters are matched case-insensitively; the stored markers take
  the convention's letter case (lowercase Stata-style under `"stata"`,
  uppercase SAS-style under `"sas"`). Inert when no such tokens appear
  in the map.

  When `NULL`, the convention is resolved from
  `joptions("missing.convention")`; if that is also unset, the call
  stops with a guided error asking you to choose – the package never
  infers a convention. Most users set the convention once at the top of
  a session via
  [`joptions()`](https://jma61.github.io/jstats/reference/joptions.md)
  (or in their `.Rprofile`) rather than supplying this argument on every
  call. See
  [`?joptions`](https://jma61.github.io/jstats/reference/joptions.md)
  for details.

## Value

A `haven_labelled` numeric vector with the encoded values and (unless
overridden) the original words as value labels. The function returns the
values rather than changing `data`: assign the result to a column to
keep it. Two assignment forms do that job:

- Preserving (recommended): `MyData$StatusR <- jencode(MyData, Status)`
  adds a new column and keeps the original text, so the two can be
  compared with
  [`jfreq()`](https://jma61.github.io/jstats/reference/jfreq.md) before
  the text is retired.

- Overwrite: `MyData$Status <- jencode(MyData, Status)` replaces the
  text in place. Nothing is wrong with this once the encoding is
  verified, but the original words in the data are gone.

SPSS users will recognize the pair: `RECODE ... INTO new.` is the
preserving form and bare `RECODE` the overwrite, and SPSS's own
text-to-numbers command (`AUTORECODE`, below) offers only the preserving
form.

## Details

**The SPSS parallel.** `AUTORECODE` is the SPSS command for this job.
Given a text variable it assigns consecutive numbers to the distinct
values in alphabetical order, stores the original text as value labels,
and writes the result to a new variable. Before:

    Status:  "Parole"  "Bail"  "Remand"  "Bail"

After `AUTORECODE VARIABLES=Status /INTO StatusR.`:

    StatusR: 2  1  3  1
    with value labels  1 "Bail"  2 "Parole"  3 "Remand"

`jencode()`'s automatic mode does exactly this, and additionally prints
the assignment listing plus a ready-made `map` call so an ordered set
(Low / Medium / High) can be renumbered deliberately rather than
accepted alphabetically.

**Numbers stored as text convert by face value.** Here the two part
company. `AUTORECODE` treats "34" as just another string and renumbers
it to its alphabetical rank; `jencode()` always converts a number stored
as text to its own value ("34" becomes 34, never 2), because a column of
ages that arrives as text should leave as ages. When every cell is
numeric text, no value labels are attached and a note says so.

**Repair mode.** A map containing only an `else` rule –
`map = "else=NA"` – is the one-line repair for a poisoned column
(numbers plus stray word codes plus blanks, the shape a spreadsheet
import often produces): the numbers are kept at face value and every
word and blank is swept to missing. When a kept value looks like a coded
missing value – by magnitude, or because a swept word such as "Refused"
is evidence the column carried missing-value codes – a note suggests
declaring it with
[`jdeclare_missing()`](https://jma61.github.io/jstats/reference/jdeclare_missing.md)
rather than losing it.

**Blanks are counted separately.** An empty cell ("") is neither a word
nor an NA. By default blanks are left missing, with a note showing the
`blank=` rule; mapping `blank=0` (or any code) gives them their own
category, which matters in field data where a blank often means "No".

The variable label from the original variable is carried across
automatically with "(encoded)" appended; if there is none, the variable
name is used instead.

## See also

[`jrecode`](https://jma61.github.io/jstats/reference/jrecode.md) for
changing numeric values,
[`jrelabel`](https://jma61.github.io/jstats/reference/jrelabel.md) for
value labels,
[`jdeclare_missing`](https://jma61.github.io/jstats/reference/jdeclare_missing.md)
for declaring missing-value codes,
[`jfreq`](https://jma61.github.io/jstats/reference/jfreq.md) for
checking an encoding landed correctly.

## Examples

``` r
MyData <- data.frame(
  Status = c("Parole", "Bail", "Remand", "Bail"),
  Answer = c("Yes", "No", "Don't know", ""),
  AgeTxt = c("34", "41", "-99", "Refused"),
  stringsAsFactors = FALSE
)

# Automatic mode: alphabetical, listing printed, words become labels
MyData$StatusR <- jencode(MyData, Status)
#> Note: 'Status' was encoded alphabetically:
#>   "Bail"   -> 1
#>   "Parole" -> 2
#>   "Remand" -> 3
#> If these categories have a natural order (like Low/Medium/High), rerun with a
#> map to choose the numbers:
#>   MyData$StatusR <- jencode(MyData, Status,
#>                             map = "Bail=1; Parole=2; Remand=3")
#> 
#> Note: This call changes MyData only if you assign the result:
#>   MyData$<name> <- jencode(...)
#> To check the encoding landed correctly, compare jfreq() on the original and the
#> new column.

# Map mode: choose the numbers; apostrophes need no quoting
MyData$AnswerR <- jencode(MyData, Answer,
                          map = "Yes=1; No=0; Don't know=8; blank=9")
#> 
#> Note: This call changes MyData only if you assign the result:
#>   MyData$<name> <- jencode(...)
#> To check the encoding landed correctly, compare jfreq() on the original and the
#> new column.

# Repair mode: keep the numbers at face value, sweep words and blanks
MyData$Age <- jencode(MyData, AgeTxt, map = "else=NA")
#> Note: 3 values in 'AgeTxt' stored as text were kept at their own value ("41" ->
#> 41, never renumbered).
#> 
#> Note: -99 in 'AgeTxt' looks like a coded missing value; the column also
#> contained the word "Refused".
#> Declare -99 with jdeclare_missing() so analyses exclude it.
#> 
#> Note: else=NA converted 1 unmapped word (1 cell) in 'AgeTxt' to missing (NA).
#> The unmapped word was "Refused".
#> 
#> Note: This call changes MyData only if you assign the result:
#>   MyData$<name> <- jencode(...)
#> To check the encoding landed correctly, compare jfreq() on the original and the
#> new column.
```
