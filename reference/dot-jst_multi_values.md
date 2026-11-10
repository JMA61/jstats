# Internal helper: a multiple-response item's values, as compared

The values jmulti() compares with `ticked`: a number for a numeric,
labelled or logical item; text for a text or factor item, a blank cell
(empty, or spaces) missing – an unticked box, which survey software
often writes blank (ruling R61: a blank among a person's answers is not
chosen).

## Usage

``` r
.jst_multi_values(x)
```

## Arguments

- x:

  The item, after the pipeline (declared missing values NA).

## Value

A numeric or character vector.
