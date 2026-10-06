# Internal helper: pick the singular or the plural form for a count

A runtime message that states a count agrees with it in number (voice
Rule O) where it used to hedge with a shortcut – "1 category(ies)",
"unused input(s)" (Session 338; the S287 item). Returns the word alone,
so the caller places the count:
`paste(n, .jst_plural(n, "category", "categories"))`. Zero takes the
plural, as in "0 categories". Either form may be a phrase, which is how
a verb is made to agree as well:
`.jst_plural(n, "This predictor has", "These predictors have")`.

## Usage

``` r
.jst_plural(n, singular, plural = paste0(singular, "s"))
```

## Arguments

- n:

  The count; a single number.

- singular:

  Character(1). The form for a count of exactly one.

- plural:

  Character(1). The form for every other count; by default the singular
  followed by "s".

## Value

Character(1).

## Details

The last shortcut, the map parser's "Invalid old value(s)", went in
Session 345: the stop names the invalid values alone, so it has a count
to agree with.
