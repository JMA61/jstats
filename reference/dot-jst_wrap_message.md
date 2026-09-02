# Internal helper: width-wrap a whole multi-line runtime message

Applies
[`.jst_seg_category()`](https://jma61.github.io/jstats/reference/dot-jst_seg_category.md)
line by line and wraps each line the way its category requires.
Idempotent: wrapping twice equals wrapping once.

## Usage

``` r
.jst_wrap_message(text, width = .jst_resolve_width(), reserve = 0L)
```

## Arguments

- text:

  Character scalar, possibly containing newlines.

- width:

  Target line width. Defaults to the resolved `message.width` setting
  (see
  [`joptions`](https://jma61.github.io/jstats/reference/joptions.md)).

- reserve:

  Integer. Characters the emitter will prepend to line 1.

## Value

Character scalar.

## Details

Called by the emitters rather than at the builder site, so that a
message whose prose was never wrapped by hand still lands within the
width, and so that the first-line `reserve` can be the REAL prefix
length – the emitter knows it, a builder can only guess.
