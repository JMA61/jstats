# Internal: the word missing in a map, found

The rules whose new value is the word missing, whether the NA rule is
one, and the label labels = "missing=..." gives it; a label for the word
with no rule using it stops (S355: the token quoted, so it cannot read
as an adjective). jrecode() and jencode() each held this block (Session
386, the twin build).

## Usage

``` r
.jst_missing_token_rules(parsed_map, parsed_labels, example)
```

## Arguments

- parsed_map, parsed_labels:

  The parsed map and labels.

- example:

  Character(1): the stop's example rule.

## Value

list(tok_rule_idx, tok_in_na, has_missing_token, tok_missing_label).
