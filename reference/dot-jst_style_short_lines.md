# Internal helper: the lines of a short style file

What jstyle(save.as =) writes when it is given settings (Session 406;
Jeff, Session 402: "if only the changes are listed, then it writes only
the changes with the 'based on' providing all other specs"): a header
saying so, the two stamps, based.on naming the style copied, then the
settings given – the general ones first, then each section's under its
heading – each after the note on what it does and what it takes.

## Usage

``` r
.jst_style_short_lines(name, based, vals)
```

## Arguments

- name:

  The new file's style name.

- based:

  The style copied: its name, or its path when it was given by path.

- vals:

  The settings
  ([`.jst_style_given()`](https://jma61.github.io/jstats/reference/dot-jst_style_given.md)).
