# Internal helper: the AGENTS.md block markers

HTML comments: invisible in rendered Markdown, inert to an assistant
reading the file. The start marker carries the do-not-edit-inside
warning where an editing user will see it; the end marker carries the
checksum of the lines strictly between the two markers, as generated.
Detection matches on the stable prefixes only, so the warning wording
can change without stranding deployed blocks.

## Usage

``` r
.jst_agents_marker_start()
```
