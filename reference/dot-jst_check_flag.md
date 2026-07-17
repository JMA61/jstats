# Internal helper: validate a TRUE/FALSE flag argument

Guard for logical flag arguments on the public surface: the value must
be a single non-NA TRUE or FALSE. Anything else raises the house-voice
error "`<arg>` must be TRUE or FALSE." via .jst_stop, whose caller
auto-detection names the user-facing function (a .jst\_-prefixed helper
is transparent to it, so guards must sit at the public function's entry
point). Set null.ok = TRUE for the tri-state display toggles, where NULL
means "not specified – defer to joutput()" and is accepted without
comment.

## Usage

``` r
.jst_check_flag(x, arg, null.ok = FALSE)
```

## Arguments

- x:

  The flag value to validate.

- arg:

  The argument's name as a string (e.g. "paired").

- null.ok:

  Logical. Accept NULL as valid (tri-state toggles)?

## Value

Invisibly NULL; called for its side effect (the stop).
