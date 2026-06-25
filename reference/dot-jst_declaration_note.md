# Internal helper: emit the registration-time declaration-plausibility note

For each just-registered variable, checks whether its data is an
implausible fit for the declared role
([`.jst_declaration_plausibility()`](https://jma61.github.io/jstats/reference/dot-jst_declaration_plausibility.md))
and, if any are, emits a single non-blocking "! Unusual declaration"
note on the message channel, alongside the other registration
advisories. Shared by jnumeric / jcount / jlikert (through
[`.jst_register_intent()`](https://jma61.github.io/jstats/reference/dot-jst_register_intent.md))
and jdummy so the wording matches the jscreen() flag exactly. "numeric"
is not a plausibility target, so a jnumeric registration emits nothing.
The declaration always stands; this is advisory only.

## Usage

``` r
.jst_declaration_note(data, var_names, kind)
```

## Arguments

- data:

  The resolved data frame.

- var_names:

  Character vector of the variables just registered.

- kind:

  The declared role: "count", "likert", or "dummy" ("numeric" is a
  no-op).

## Value

invisible(NULL). Called for its message side effect.
