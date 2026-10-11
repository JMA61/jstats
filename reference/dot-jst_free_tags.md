# Internal helper: the first markers free of those in use

The letters, in alphabet order and in the convention's case, that none
of `used` takes in either case – the markers a printed line can send
values to without joining a kind of missing data already there.

## Usage

``` r
.jst_free_tags(used, conv, n = 1L)
```

## Arguments

- used:

  Character vector of tag letters in use (cells, labels, a map's
  targets), any case; NA ignored.

- conv:

  "stata" or "sas".

- n:

  How many letters are wanted.

## Value

Character vector of up to `n` letters.
