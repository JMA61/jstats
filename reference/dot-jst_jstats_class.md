# Internal helper: jstats analysis-role class for display

Single display-layer resolver that reports how jstats treats a variable,
for the jscreen() "Variable Types" table. It does NOT define any new
classification rules: it composes the existing single-source helpers
([`.jst_var_kind()`](https://jma61.github.io/jstats/reference/dot-jst_var_kind.md),
[`.jst_is_dichotomy()`](https://jma61.github.io/jstats/reference/dot-jst_is_dichotomy.md),
[`.jst_is_discrete_integer()`](https://jma61.github.io/jstats/reference/dot-jst_is_discrete_integer.md))
so the screening report cannot drift from how analyses and the
outlier-skip actually treat a variable. The same resolver decides
jscreen's outlier-screening (screened iff `class == "Numeric"`), so the
Class column and the Outliers column can never disagree.

## Usage

``` r
.jst_jstats_class(x, var_name = NULL, data_name = NULL, override = NULL)
```

## Arguments

- x:

  A variable / data-frame column.

- var_name:

  Optional character string naming the variable; required (with
  `data_name`) to consult registered intent.

- data_name:

  Optional character string naming the data frame; required (with
  `var_name`) to consult registered intent.

- override:

  Optional per-call asserted role ("numeric", "categorical", or
  "count"); highest-priority tier when supplied.

## Value

A list with `class` (character), `subclass` (character, "" when none),
and `source` (one of "per-call", "registered", "measure", "structural").

## Details

Class (the analysis role): one of "Numeric", "Categorical",
"Numbers-as-text", "Date-time", "Unsupported". Storage facts (labelled
vs plain, character backing) live in jscreen's separate "Base R Type"
column, never here – a base-R numeric can resolve to Numeric, or to
Categorical (dichotomy), or to Categorical (N-category), depending only
on the analysis-relevant structure.

Sub-class (for Categorical only; "" otherwise): "dichotomy" for a two-
value variable, "Likert" for a value-labelled ordered scale (a
consecutive run of 3-7 surviving labelled codes plus an
anchor-or-battery discriminator; structural detection or a jlikert()
assertion), "identifier" for a text/factor variable whose every non-
missing value is distinct (7+ values; a respondent ID is the typical
case), else "N-category" (e.g. "4-category") from the count of distinct
non-missing values. The "Likert" and "identifier" labels are display
refinements: such a variable is still Categorical for every analysis and
screening purpose. The boundary between Numeric and Categorical is
exactly the package's existing rule: a dichotomy (any coding), a factor
/ logical / character, a haven-labelled variable with \<= 6 categories,
or a whole-number 0-6 numeric is Categorical; everything else
numeric-ish (continuous numeric, or labelled with 7+ categories) is
Numeric. The Numeric subclass "Count" is registration-only (set via
jcount, or the per-call override "count"); the structural classifier
never emits it. The Categorical subclass "-cat dummy" (e.g. "5-cat
dummy") is likewise registration-only – set via jdummy() on a variable
with more than two categories; the structural classifier never emits it,
and a dichotomy declared via jdummy() keeps its "dichotomy" subclass, a
dichotomy being a special case of a dummy.

Resolution stack (highest wins; first tier that yields a class short-
circuits). Storage-determined edge kinds (date-time, numbers-as-text,
unsupported) resolve structurally up front and are not role-assertion
targets, so the user tiers operate only among Numeric, Categorical, and
Count: (1) per-call `override` -\> source "per-call"; (2) registered
intent – the `.jst_registry` notebook (jnumeric/jcount) and the
`.jst_dummy` registry (jdummy -\> categorical) -\> source "registered";
(3) SPSS measure – designed but UNPOPULATED in v1, ignored; (4)
structural guess -\> source "structural". Identity (`var_name` +
`data_name`) is required to consult tiers 1-2; when omitted, the
resolver returns the structural answer with source "structural", so a
bare `.jst_jstats_class(x)` behaves as before but now also reports a
source.
