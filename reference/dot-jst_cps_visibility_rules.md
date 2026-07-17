# CPS rendering rule tables (data, not logic)

Canonical source = JStats_CPS_Rendering_Reference.txt Tables 1-3. Per
the locked lockstep commitment, any change to a rule here updates BOTH
that reference file and this data frame in the same session. "any" is a
wildcard; matching is first-match top-to-bottom, so reference rows whose
value is "-" (not evaluated) are encoded as "any" with ordering
preserved.

## Usage

``` r
.jst_cps_visibility_rules
```
