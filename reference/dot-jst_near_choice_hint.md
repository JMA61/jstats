# Internal helper: the did-you-mean lines for a mistyped choice

A value typed for a fixed-choice setting that is a near miss of one of
its choices – `joptions("spps")` – gets, after the Rule A choice error,
the choice it is nearest to and the call to run (the S281 item's value
half; Session 343). Near is Levenshtein distance, case-insensitive, of
at most 2 and of less than half the typed string's length: the second
test keeps a short string from matching by insertion alone ("sa" is one
edit from "sas" and is still not a near miss of it; "data" is two edits
from "stata" and is more likely a question about data.dir). Choices tied
for nearest are all offered, each with its line.

## Usage

``` r
.jst_near_choice_hint(typed, choices, line_open)
```

## Arguments

- typed:

  What the user gave; compared in lowercase.

- choices:

  Character vector of the allowed values.

- line_open:

  Character(1); the call up to and including the value's opening
  quotation mark.

## Value

Character(1) beginning with a newline, or `NULL` when `typed` is not a
single string or is near no choice.
