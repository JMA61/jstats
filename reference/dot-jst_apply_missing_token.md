# Internal: the word missing given its code or marker

Under spss each rule using the word missing takes the code minted for it
(tok_mint_code), elsewhere the marker (tok_tag); labels =
"missing=Label" then labels whichever was minted. jrecode() and
jencode() each held this block (Session 386, the twin build); jrecode()
checks its source's cells against the code first.

## Usage

``` r
.jst_apply_missing_token(
  parsed_map,
  parsed_labels,
  tok_rule_idx,
  tok_in_na,
  spss,
  tok_mint_code,
  tok_tag,
  tok_missing_label
)
```

## Arguments

- parsed_map, parsed_labels:

  The parsed map and labels.

- tok_rule_idx, tok_in_na:

  The rules using the word, and the NA rule.

- spss:

  Logical(1): whether the word takes a code.

- tok_mint_code:

  The code (spss), else NULL.

- tok_tag:

  The marker (stata, sas); read only there.

- tok_missing_label:

  The label labels = gives the word, or NULL.

## Value

list(parsed_map, parsed_labels).
