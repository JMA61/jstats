# Internal helper: the first lettered marker a call typed, as typed

The marker the choose-first gate echoes in its head: the first tagged
spelling in the call, read in map order (a rule's target, then the else
target, then the NA rule's target) and then from the labels, and quoted
AS TYPED from the parsers' `tagged_raw` records, falling back to the
normalized lowercase letter where no record exists. One walk for
[`jrecode()`](https://jma61.github.io/jstats/reference/jrecode.md) and
[`jencode()`](https://jma61.github.io/jstats/reference/jencode.md),
which each carried a copy of it from Session 283 to Session 345 (the
S283 item). The two other homes of the pattern read different structures
and keep their own code:
[`jdeclare_missing()`](https://jma61.github.io/jstats/reference/jdeclare_missing.md)'s
one line over its parsed codes, and the refusal builder, which walks
every letter rather than the first.

## Usage

``` r
.jst_first_typed_marker(
  parsed_map,
  parsed_labels = NULL,
  labels_tagged_raw = NULL
)
```

## Arguments

- parsed_map:

  The parsed map.

- parsed_labels:

  The parsed labels vector, or `NULL`.

- labels_tagged_raw:

  The labels parser's typed-spelling record (letters named by their
  lowercase form), or `NULL`.

## Value

Character(1) such as `".a"` or `".B"`, or `NULL` when the call names no
marker.
