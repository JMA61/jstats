# CPS rendering rule tables (data, not logic)

Canonical source = JStats_CPS_Rendering_Reference.txt Tables 1-4. Per
the locked lockstep commitment, any change to a rule here updates BOTH
that reference file and this data frame in the same session. "any" is a
wildcard; matching is first-match top-to-bottom, so reference rows whose
value is "-" (not evaluated) are encoded as "any" with ordering
preserved.

## Usage

``` r
.jst_cps_visibility_rules
```

## Details

Table 1 (S284 redesign): the upper table is gated by whether it would
carry an EXCLUSION ROW – a pipeline row (jcomplete / jsubset / subset =,
shown even at 0 excluded) or a nonzero Auto-listwise row – under the
resolved MODE (never / auto / always). Missingness no longer enters this
gate; it feeds the bottom breakdown only (Table 3). When the table does
not print, a one-line N statement takes its slot.
