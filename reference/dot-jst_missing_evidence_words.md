# Internal helper: which evidence strings signal missingness?

Returns the subset of `evidence` that matches the missing-label
wordlist, so a message can cite the evidence it acted on rather than
asserting a conclusion the user cannot check. Order is preserved.

## Usage

``` r
.jst_missing_evidence_words(evidence)
```

## Arguments

- evidence:

  Character vector.

## Value

Character vector, possibly empty.
