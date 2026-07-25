# Internal helper: one status line for a found orientation copy

`noun` names the artifact the line is about: AGENTS.md carries a marked
block inside a user-owned file, while SKILL.md is package-owned and
overwritten whole, so "Block" is wrong for the skill case.

## Usage

``` r
.jst_orientation_state_line(found_v, edited, regen_call, noun = "Block")
```
