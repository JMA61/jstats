# Internal helper: map Stata-style tagged-NA letters to UDM codes

Translates a vector of lowercase letter tags (e.g. `c("a", "b")`) into
the equivalent numeric UDM codes drawn from
`joptions("udm.convention.codes")`. Mapping is positional: `.a` maps to
the first code, `.b` to the second, etc.

## Usage

``` r
.jst_tag_letters_to_codes(letters_in, convention_codes = NULL)
```

## Arguments

- letters_in:

  Character vector of lowercase letter tags. Must be single lowercase
  letters (`"a"` through `"z"`); no leading period. Caller is
  responsible for stripping any leading period before calling.

- convention_codes:

  Optional numeric vector of UDM codes. When `NULL` (the default), the
  helper sources the value of `joptions("udm.convention.codes")` via the
  standard [`getOption()`](https://rdrr.io/r/base/options.html)
  fallback.

## Value

Named numeric vector. Names are the input letters; values are the
corresponding convention codes. Carries an `unmapped` attribute
(character vector) when the input letter count exceeded the convention
code count.

## Details

When `length(letters_in) > length(convention_codes)`, the return covers
only the mappable subset (in order) and `attr(result, "unmapped")` holds
the letters that could not be mapped. Callers decide whether to error,
truncate, or annotate based on the unmapped attribute.
