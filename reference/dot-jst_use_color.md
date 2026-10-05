# Internal helper: should this output carry color?

The one test behind
[`.cat_red()`](https://jma61.github.io/jstats/reference/dot-cat_red.md)
and
[`.cat_yellow()`](https://jma61.github.io/jstats/reference/dot-cat_yellow.md).
Color is written as ANSI escape sequences, which the RStudio Console
draws as color and almost everything else prints as raw characters
(`<ESC>[31mCross-Tabulation`): RGui, a plain terminal, output captured
with [`sink()`](https://rdrr.io/r/base/sink.html) or
[`capture.output()`](https://rdrr.io/r/utils/capture.output.html), a
knitr or Quarto render. The rule (Jeff, Session 336: "Can we simply not
do colour outside of R Studio?") is color in the RStudio Console and
plain text everywhere else, by a check of the package's own – no crayon
or cli.

## Usage

``` r
.jst_use_color(
  forced = getOption("jstats.color"),
  gui = .Platform$GUI,
  console_color = Sys.getenv("RSTUDIO_CONSOLE_COLOR"),
  sinks = sink.number(),
  knitting = isTRUE(getOption("knitr.in.progress"))
)
```

## Arguments

- forced:

  The `jstats.color` option.

- gui:

  `.Platform$GUI`.

- console_color:

  The `RSTUDIO_CONSOLE_COLOR` environment variable.

- sinks:

  The number of active output diversions.

- knitting:

  Is a knitr run in progress?

## Value

`TRUE` or `FALSE`.

## Details

"In the RStudio Console" is four things at once, because a capture and a
render both START inside RStudio:

- R is RStudio's own session process (`.Platform$GUI` is `"RStudio"`). A
  render launched from RStudio, a background job and the Terminal pane
  run R as a child process, where it is not.

- the Console says it draws color: RStudio sets the environment variable
  `RSTUDIO_CONSOLE_COLOR` when its "Show ANSI colors" preference is on.

- no [`sink()`](https://rdrr.io/r/base/sink.html) is diverting the
  output
  ([`capture.output()`](https://rdrr.io/r/utils/capture.output.html) is
  one).

- no knitr run is in progress –
  [`rmarkdown::render()`](https://pkgs.rstudio.com/rmarkdown/reference/render.html)
  typed in the Console runs in the session process.

`options(jstats.color = TRUE)` forces color on wherever the output goes
and `FALSE` forces it off; unset is the rule above. The switch is
documented for users in
[`?joutput`](https://jma61.github.io/jstats/reference/joutput.md)
("Color"): it serves a console that draws color but is not RStudio's,
and the online guides, whose Console facsimiles take their red titles
and yellow notes from these escapes during a (captured, knitr) render.

The signals are arguments so that each arm can be tested anywhere; no
caller passes one.
