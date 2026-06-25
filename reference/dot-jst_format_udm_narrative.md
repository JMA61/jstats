# Internal: format the UDM narrative notification text

Builds the message string emitted when UDM-bearing variables are
detected during a load. Wording differs depending on whether the UDMs
were preserved (`preserve.udm = TRUE`) or converted
(`preserve.udm = FALSE`). Variable list is truncated at `max_show`
entries with an "...and N more" tail.

## Usage

``` r
.jst_format_udm_narrative(
  udm_info,
  preserve.udm,
  max_show = 10L,
  data_name = "data"
)
```

## Details

Renders SPSS UDM codes (e.g. `-99`) and Stata tagged NAs (e.g. `.a`)
using parallel notation: `code ["label"]` or `code (no label)`. The code
form comes pre-rendered in the `code` column of
[`.jst_missing_info()`](https://jma61.github.io/jstats/reference/dot-jst_missing_info.md)'s
return.
