# Internal helper: the rules of a text variable's labels string

Splits on the semicolons outside quotation marks. A mark opens a quoted
value at the start of a rule – `"A;B"=Odd` – or a quoted label right
after its equals sign (ruling R17's form); anywhere else it is an
ordinary character, so a rule DK=Don't know reads as written, as in
jencode()'s maps.

## Usage

``` r
.jst_split_text_label_rules(s)
```

## Arguments

- s:

  The labels string.

## Value

Character vector of rules, trimmed, empty ones dropped.
