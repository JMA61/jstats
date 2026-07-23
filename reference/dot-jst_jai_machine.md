# Internal helper: jai("machine") – write SKILL.md

Writes the skill file (frontmatter plus the orientation, machine flavor)
to the default user-level skills folder, creating missing folders, or to
an explicit path for hand placement. The file is package-owned by
convention, so an existing copy is overwritten whole after confirmation;
no marker machinery.

## Usage

``` r
.jst_jai_machine(path = NULL)
```
