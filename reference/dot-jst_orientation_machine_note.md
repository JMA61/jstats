# Internal constant: the machine flavor's AI-assistant paragraph

The paragraph of
[`.jst_orientation_body()`](https://jma61.github.io/jstats/reference/dot-jst_orientation_body.md)
that opens "Note for AI assistants:", without that prefix and set to the
body's width, for SKILL.md (see
[`.jst_orientation_text()`](https://jma61.github.io/jstats/reference/dot-jst_orientation_text.md)).
Its words must match the body's paragraph after the prefix; the jai
checks hold the two together. Edit both, and bump
`.jst_orientation_version`.

## Usage

``` r
.jst_orientation_machine_note
```
