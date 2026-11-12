# Internal helper: the stop for a setting given in the wrong list

paper, or a general setting in plot's list, only has to move out of the
list: the stop gives the call rewritten, the setting given by itself –
when the list was typed in the call and no setting of that name is
already given by itself; else the sentence alone. Another section's
setting gets an example in a list of its own section, since the call
cannot say which of several sections was meant.

## Usage

``` r
.jst_style_given_stop(w, s, k, cl = NULL)
```

## Arguments

- w:

  What
  [`.jst_style_misplaced()`](https://jma61.github.io/jstats/reference/dot-jst_style_misplaced.md)
  returned.

- s, k:

  The setting, and the section whose list held it.

- cl:

  The call as typed, or NULL.
