# Internal helper: the AGENTS.md block markers

HTML comments: invisible in rendered Markdown. The start marker carries
the do-not-edit directive, addressed to BOTH readers – the human editing
the file and an assistant that may edit it agentically – with the
overwrite consequence as its rationale; the end marker carries the
checksum of the lines strictly between the two markers, as generated,
plus the redirect telling the user where their own notes belong.
Detection matches on the stable prefixes only, so the wording of either
marker can change without stranding deployed blocks. Each marker must
stay ONE physical line: block bounds are line indices and everything
strictly between them is checksummed content, so a wrapped marker would
fold its continuation into the block. No "–" inside the comments (a
double hyphen is invalid in an HTML comment).

## Usage

``` r
.jst_agents_marker_start()
```
