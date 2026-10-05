# Internal helper: refuse off, on or NULL given along with a condition

`jsubset(d, Age < 40, on)`: the word acts on the stored filter and takes
no condition. Its third input landed in `clear.all`, where evaluating it
gave R's own "object 'on' not found" (the S334 item; Session 338). What
the user meant cannot be told from the call – to set the filter, or to
act on the one already stored – so the stop gives both calls (voice Rule
D, equal-standing remedies), the one that sets the filter first. Two
words and no condition (`jsubset(d, off, on)`) get one sentence.

## Usage

``` r
.jst_word_with_condition_stop(items, is_word, frame = NULL)
```

## Arguments

- items:

  The call's unnamed inputs after the data frame, unevaluated.

- is_word:

  Logical, one per item: TRUE for `off`, `on` or `NULL`.

- frame:

  Character(1) or `NULL`; the data frame as typed, when the call named
  one.

## Value

Does not return; stops.
