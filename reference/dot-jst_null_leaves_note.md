# Internal helper: the note under a setting given as NULL

joptions() and joutput() read a setting named with the value NULL as
"leave it as it is" and echo its value (S233, S332), which reads easily
as a reset (Jeff, S422-S423, on joptions(style = NULL)). The note says
the setting was left as it is and gives the call that puts its default
back: the default itself, as Section 332's rule has it ("pass any slot
its default to reset it"); for joutput() the default of the level in
force, and where that level's default is no value (standard's
case.processing) the level call, which puts every setting back (Session
423).

## Usage

``` r
.jst_null_leaves_note(fn, slots, defaults, level = NULL)
```

## Arguments

- fn:

  "joptions" or "joutput".

- slots:

  Character; the settings given as NULL, in the call's order.

- defaults:

  A list of their defaults, named by setting.

- level:

  For joutput(), the output level in force; NULL otherwise.

## Value

Character(1).
