# Internal helper: resolve transformed formula terms into computed columns

Walks the formula's variables for function-call terms – log(x), I(x^2),
sqrt(x), and the like, on either side – and, for each supported term,
computes the transformed values once on the analysis copy and stores
them as a column whose name is the term's own text (a column literally
named "log(x)"), rewriting the formula to reference that column as a
plain name. Everything downstream – the descriptives, the Case
Processing Summary, the model fit, the standardized-beta refit – then
sees an ordinary variable whose printed name is the expression the user
typed, so the test statistic and the descriptive output describe the
same values (AUDIT-021) and the model-frame refit that motivated the
former front-door refusal (AUDIT-005) finds the column by name instead
of re-evaluating the term. Interaction terms (x \* z, x:z) are
untouched: terms() lists their component variables as plain names, not
calls. A transformed term nested inside an interaction (log(x):z) is
listed as its own variable by terms(), so it is computed and substituted
inside the interaction. Supersedes the AUDIT-005 refusal in jlm and
jlogistic; .jst_check_formula_transforms remains in use where
transformed terms stay unsupported (jcrosstab).

## Usage

``` r
.jst_resolve_formula_transforms(formula, data, data_name)
```

## Arguments

- formula:

  The user's analysis formula.

- data:

  The analysis data frame (the post-pipeline copy).

- data_name:

  Character; the data frame's name (for messages).

## Value

A list: formula (rewritten when any term was computed, otherwise the
input), data (with any computed columns appended), computed (character
vector of the computed columns' names, possibly empty), and
introduced_na (named integer vector keyed by term text: per computed
term, the count of non-finite results converted to NA; empty when no
term introduced any). A formula that terms() cannot process (e.g. a bare
dot) passes through untouched for downstream handling.

## Details

A term is supported when it evaluates against the analysis copy to a
single numeric or logical column with one value per case. Terms that
produce several columns (poly(x, 2), spline bases), a categorical result
(cut(x, 3)), a single summary value (mean(x)), or an evaluation error
are refused in house voice with a make-the-variable message. A term is
also refused, before evaluation, when its argument is a variable the
package classifies as Categorical – most importantly a value-labelled
categorical, whose numeric codes would otherwise be transformed silently
into a meaningless predictor (log() of a 1/2/3/4 category code fits with
no error). The check uses the same classification stack the analysis
path uses, so a jnumeric/jcount registration moves the variable to
Numeric and lifts the refusal – the identical escape hatch, and the
exact path the message names – while factor/character arguments are
caught here too (a typed message in place of base R's raw non-numeric
error). A term that evaluates but yields non-finite values for some
cases – log() of a zero (-Inf) or of a negative (NaN) – is NOT refused:
those cells are set to NA, counted per term, and reported in a
consequential note, with base R's raw "NaNs produced" warning muffled in
favor of that note; the counts travel out as introduced_na so the Case
Processing Summary can attribute the exclusions (AUDIT-024, AUDIT-025).
Evaluation happens on the pipeline-masked analysis copy, so declared
SPSS-style missing values are already NA before any arithmetic touches
them; haven-labelled inputs are unclassed to plain numeric for the
computation, the same coercion the analysis functions apply themselves.
Objects that are not columns (a threshold constant in I(x \> cutoff))
resolve in the formula's own environment, matching model.frame().
