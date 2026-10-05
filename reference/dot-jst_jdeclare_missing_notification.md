# Internal: notification for a single-variable jdeclare_missing call

Returns `list(block = , tail = )`. `block` is the header and the body
lines (or, on the naming branch with every marker bare, the no-change
note). `tail` is the durability reminder, with the equivalent call after
it at the full tier on the conversion branch; it is `NULL` at the
minimal tier and when nothing changed. The caller prints the two apart,
with what the call did to an earlier declaration between them (S339).

## Usage

``` r
.jst_jdeclare_missing_notification(
  data_name,
  var_name,
  parsed_codes,
  branch,
  body = NULL,
  conversion_info = NULL,
  modify = FALSE,
  resolved_convention = "stata",
  marker_notes = NULL,
  data_kind = "name"
)
```
