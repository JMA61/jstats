# Internal helper: the text a multiple-response set's labels share

The labels' common start, cut back to the last separator in it – a
colon, a question mark, an opening bracket or parenthesis, a dash, a
bar, a slash or a full stop – so "Services used: Counselling" and
"Services used: Housing" share "Services used", LimeSurvey's
`"Which services have you used? [Counselling]"` shares
`"Which services have you used?"`, and Qualtrics's "Q1 - ... - Selected
Choice - Counselling" shares all but the option. Labels that share no
such start, an item with no label, or an option left empty by the cut
share nothing.

## Usage

``` r
.jst_multi_shared(labs)
```

## Arguments

- labs:

  Character: the items' labels, NA for an item with none.

## Value

A list: title (the shared text, NA for none) and cut (the start each
label's option follows, "" for none).
