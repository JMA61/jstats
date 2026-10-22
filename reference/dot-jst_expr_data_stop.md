# Internal helper: an expression given as the data that cannot be evaluated

The (S391) expression-typo item (Session 392): with `d` holding Score,
Group and Age and `dd` a typo for it,
`jt(Score ~ Group, dd[dd$Age > 40, ])` printed R's own "object 'dd' not
found", with no prefix – ruling R36 reads a NAME, and the data here is
an expression – and the data-first functions read the expression as a
variable: `jfreq(dd[dd$Age > 40, ], Group)` said it "needs a data frame"
and offered `jfreq(MyData, dd[dd$Age > 40, ])`, Group dropped, and under
a [`juse()`](https://jma61.github.io/jstats/reference/juse.md) default
said it "was not found in the d data frame". When the expression a call
gives as its data stops, the reason is said in the house voice, the
first that applies:

1.  a column its data frame lacks – after `$`, in a literal `[[ ]]`, or
    a name in [`subset()`](https://rdrr.io/r/base/subset.html)'s
    condition or `select` that is neither a variable of that frame nor
    an object
    ([`.jst_expr_missing_columns()`](https://jma61.github.io/jstats/reference/dot-jst_expr_missing_columns.md)):
    [`.jst_check_vars()`](https://jma61.github.io/jstats/reference/dot-jst_check_vars.md)'s
    sentence, "Agee was not found in the d data frame." / "Check the
    spelling.";

2.  a name that is no object and no variable of any data frame, R's
    message naming one of them
    ([`.jst_quoted_in()`](https://jma61.github.io/jstats/reference/dot-jst_quoted_in.md)):
    "'dd' not found.", several named together (ruling R25), with `tail`
    after it when the caller has a line of its own to give. When it is
    one name, ruling R36's offer is tried first
    ([`.jst_expr_misspelled_offer()`](https://jma61.github.io/jstats/reference/dot-jst_expr_misspelled_offer.md));

3.  any other reason, by `relay`: "always" gives " could not be
    evaluated." / "R reported:" and R's message; "unless_variable" gives
    it unless R's message names a variable of a data frame –
    `jsubset(Age > 40)` with no frame named, an expression of variables
    that needs a data frame, which the caller says – and "never" leaves
    every other reason to the caller.

## Usage

``` r
.jst_expr_data_stop(
  data_sub,
  err,
  fn,
  envir,
  cl = NULL,
  vars = NULL,
  offer = TRUE,
  relay = c("always", "unless_variable", "never"),
  tail = NULL,
  vector_ok = FALSE
)
```

## Arguments

- data_sub:

  The expression as typed.

- err:

  The condition the evaluation raised, or R's message.

- fn:

  Character(1). The user-facing function's name.

- envir:

  The caller's environment.

- cl:

  The call as typed, for the offered line; NULL for none.

- vars:

  Character. The variables the call names besides the data; NULL reads
  them from `cl`, its unnamed arguments.

- offer:

  Logical. FALSE for a function that refuses an expression as the data
  (jsubset(), jcomplete() and the registration verbs), whose offered
  line would stop there.

- relay:

  "always", "unless_variable" or "never".

- tail:

  Character or NULL. Lines after "'dd' not found." when no line is
  offered.

- vector_ok:

  Logical. TRUE for jdesc(), jfreq() and jscreen(), which take a single
  column: the offered expression may give one (`jfreq(d$Age)` for
  `jfreq(dd$Age)`).

## Value

Invisible NULL when the caller is to go on; otherwise stops.
