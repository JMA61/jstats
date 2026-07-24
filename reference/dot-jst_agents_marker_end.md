# Internal helper: the AGENTS.md end marker

Counterpart of .jst_agents_marker_start(); carries the checksum of the
lines strictly between the two markers, as generated, for edit
detection, and the redirect telling the user where their own notes
belong. The checksum parse anchors on the bracketed field, so trailing
text after it is safe.

## Usage

``` r
.jst_agents_marker_end(checksum)
```
