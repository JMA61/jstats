# Internal helper: the orientation body text

The single content core shared by every jai() emission: the console
print, the AGENTS.md block, and SKILL.md. One character element per
line, in Markdown (backtick code spans; the file emissions use it as is,
the console emissions pass it through
.jst_orientation_render_console()). Content matches the deployed
orientation text (see .jst_orientation_version); edit it here and bump
the version, never per emission.

## Usage

``` r
.jst_orientation_body()
```
