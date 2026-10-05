# Internal helper: refuse a registration the variable's type cannot carry

[`jnumeric()`](https://jma61.github.io/jstats/reference/jnumeric.md),
[`jcount()`](https://jma61.github.io/jstats/reference/jcount.md) and
[`jlikert()`](https://jma61.github.io/jstats/reference/jlikert.md)
assert an analysis role for a variable that holds numbers. Until Session
342 they accepted any variable and confirmed the registration as if it
had changed something: `jnumeric(d, Sev)` on a factor printed "Numeric
registration set" while
[`jdesc()`](https://jma61.github.io/jstats/reference/jdesc.md) went on
refusing Sev, and
[`jscreen()`](https://jma61.github.io/jstats/reference/jscreen.md)
showed a text variable as "Numeric / User-declared" over R's "NAs
introduced by coercion" (the S310 item). The Classification reference's
registration scope boundary (Session 79) had always said the
storage-determined kinds are refused with guidance to convert first;
Jeff's Session 342 lean 2 extended the refusal to every kind but numeric
and haven-labelled numeric, a logical included. The wording follows
`jrelabel(labels = )` and
[`jdeclare_missing()`](https://jma61.github.io/jstats/reference/jdeclare_missing.md),
which refuse the same kinds: a factor or text variable is pointed to
[`jencode()`](https://jma61.github.io/jstats/reference/jencode.md); the
other kinds have no conversion jstats performs, and get the fact alone.
[`jdummy()`](https://jma61.github.io/jstats/reference/jdummy.md) is not
gated here – it registers a categorical role, which every one of these
kinds but the dates and the unsupported types can take.

## Usage

``` r
.jst_check_registration_type(kind, x, var_name)
```

## Arguments

- kind:

  `"numeric"`, `"count"` or `"likert"`.

- x:

  The variable.

- var_name:

  Its name.

## Value

Invisibly `NULL`; stops when the variable is refused.
