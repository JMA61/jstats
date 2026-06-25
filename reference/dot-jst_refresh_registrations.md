# Internal helper: refresh the registration notebook from a loaded frame

On load, makes the session notebook for a frame name match what the file
carries (the file is the source of truth at load time). When the loaded
object carries baked registrations, they are written into the
.jst_registry and .jst_dummy notebooks under the load-time name,
replacing any differing in-session registrations already sitting under
that name. When the loaded object carries none – a non-.rds file, an
older .rds saved before this feature existed, or freshly unregistered
data – any stale registrations under the reused name are cleared.
Returns a one-line note describing what happened (or NULL when nothing
changed), for the caller to emit subject to its own quiet setting.

## Usage

``` r
.jst_refresh_registrations(obj_name, baked)
```

## Arguments

- obj_name:

  Character string giving the name the frame is loaded as (jload's name=
  argument, or the file stem) – the key the analysis functions will look
  the frame up by.

- baked:

  The ".jst_registrations" attribute read from the loaded object (a list
  with registry, dummy, and origin entries), or NULL when the object
  carried none.

## Value

A character note, or NULL when no notebook change was made.
