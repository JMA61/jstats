# Internal helper: admit missing-value candidates on word/label evidence

The evidence channel of UDM detection, sibling to
[`.jst_detect_suspicious_values()`](https://jma61.github.io/jstats/reference/dot-jst_detect_suspicious_values.md)
(the magnitude channel). Given a set of values and a set of evidence
strings drawn from the same column, returns the values that evidence
licenses reporting even though the magnitude heuristic did not flag
them.

## Usage

``` r
.jst_evidence_admits_missing_values(values, evidence)
```

## Arguments

- values:

  Numeric vector. Candidate values from the column, after any encoding
  has been applied.

- evidence:

  Character vector. Strings drawn from the same column that may signal
  missingness – value labels, or the original words in a text column
  being encoded.

## Value

A sorted numeric vector of admitted values, or `numeric(0)` when there
is no evidence or nothing qualifies. The caller is responsible for
excluding values the magnitude channel has already reported.

## Details

Evidence is present when at least one supplied string matches
`.jst_missing_label_wordlist` (via
[`.jst_label_suggests_missing()`](https://jma61.github.io/jstats/reference/dot-jst_label_suggests_missing.md)).
When it is, negative values qualify; positives never do, since positive
sentinels already clear the magnitude bar.
