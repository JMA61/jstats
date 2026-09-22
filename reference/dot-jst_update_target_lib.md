# Internal helper: the library folder an update of jstats should go into

Returns the library holding the copy of jstats in use, so that jupdate()
replaces that copy rather than installing beside it. find.package() with
no lib.loc lists the LOADED namespace's path first, so the answer is the
copy actually running even when .libPaths() was changed after startup.
Under devtools::load_all() that path is a source folder, not a library;
a result that is not one of .libPaths() therefore falls back to
`.libPaths()[1]` – install.packages()'s own default, and a developer
state, so it is silent. Same rule as update.packages()'s instlib
default. (S309)

## Usage

``` r
.jst_update_target_lib(pkg_path = find.package("jstats"))
```

## Arguments

- pkg_path:

  The installed (or loaded) package's folder; defaults to
  find.package("jstats"). Supplied only by tests.

## Value

A single library path, normalized.
