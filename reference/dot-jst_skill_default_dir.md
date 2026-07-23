# Internal helper: the default machine-skill folder

The cross-tool user-level skills location. On Windows the profile root
is taken from USERPROFILE, not path.expand("~"): R historically expands
"~" to Documents, while skill-reading assistants treat "~" as the
profile root, and USERPROFILE is also stable under OneDrive Documents
redirection.

## Usage

``` r
.jst_skill_default_dir()
```
