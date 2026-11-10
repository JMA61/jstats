# Show, list and copy table styles

A style holds a table's look and a journal's or a report's conventions:
the font, the caption's form, the rules, the decimals, and for each
table type its columns and labels. `jstyle()` lists the styles jstats
can find; `jstyle("myjournal")` checks a style file and prints every
setting the style gives, marking each one it takes from another style;
and `jstyle("apa", save.as = "myjournal")` saves a copy as a style file,
myjournal.jstyle, every setting written out with a note on what it does
and what it takes, to edit in any text editor (the step SPSS calls "Save
TableLook As"). `jstyle("myjournal", open = TRUE)` opens the file in the
editor instead of printing it.

## Usage

``` r
jstyle(style = NULL, save.as = NULL, overwrite = FALSE, open = FALSE, ...)
```

## Arguments

- style:

  The style's name in quotes – `"apa"`, `"report"` or a style file's –
  or a path to a style file; NULL (the default) lists the styles, or
  with `save.as` or `open` copies or opens `joptions(style = )`.

- save.as:

  A name for the copy, in quotes: written as `<name>.jstyle` in the
  style folder when one is set, else in your jstats folder
  (`tools::R_user_dir("jstats")`), or to a path given with a folder.
  "apa" and "report" name the built-in styles, so neither can be a
  copy's name; a file named apa.jstyle or report.jstyle is not read, and
  jstats says so.

- overwrite:

  Logical. Replace a style file that exists? With FALSE (the default) an
  interactive session asks, and one that cannot ask stops.

- open:

  Logical. TRUE opens the style's file in the editor, as base R's
  [`file.edit()`](https://rdrr.io/r/utils/file.edit.html) does (in
  RStudio, a tab beside your script), and prints no settings; the file
  is still checked, and a value it cannot use is named. With `save.as`
  it opens the file just written. Only in an interactive session: a
  script opens nothing. The built-in styles have no file; save a copy to
  open one.

- ...:

  Settings for a short copy, with `save.as`: a general setting by its
  name (`font = "Arial"`), a table type's settings in a list named for
  its section (`regression = list(fit.rows = "r2")`).
  [`jstyle_settings`](https://jma61.github.io/jstats/reference/jstyle_settings.md)
  lists them all. Any other input stops with "unused input".

## Value

Invisibly: the styles found (a data frame of name and path), the style,
or the path of the file written.

## Details

jstats has two built-in styles: `"apa"`, APA 7's conventions for a
journal, and `"report"`, the plain look the report style manuals share –
Arial 10, "Table 1:" and the title on one line, a light grey header, an
upright "Note:" – based on apa. A style for an agency or an institute is
a copy of report with its own colors and font.

Given settings, `jstyle(save.as =)` writes a short file instead: the
style it copies named on its based.on line, and only the settings given,
which is all a small change needs. A general setting is given by its
name; a table type's settings go in a list named for its section:
`jstyle("apa", save.as = "myapa", font = "Arial", regression = list(fit.rows = c("r2", "n")))`.
A short file takes everything else from its base, so it travels with it:
a file based on a style of your own works on another computer, or from
another folder, only where that style can be found too. A base given by
its path is written by its path, which is where jstats finds it; a base
given by its name is looked for in the folders below.

A style file is plain text: a setting is a name, an equals sign and a
value; a `#` starts a note; the general settings come first, then one
section per table type, `[descriptives]`, `[frequencies]`,
`[regression]`, `[logistic]`, `[correlation]`, `[ttest]`, `[anova]`,
`[crosstab]`, `[reliability]` and `[multiresponse]`. A setting the file
leaves out comes from the style its `based.on` line names.
[`jstyle_settings`](https://jma61.github.io/jstats/reference/jstyle_settings.md)
lists every setting and what it takes. jstats looks for a style named in
a call in the style folder (`joptions(style.dir = )`), the working
directory and your jstats folder, in that order.

## Making a style with an AI assistant

A style file is plain text, so an AI assistant can write one from an
example report. Give it a complete copy, which lists every setting and
what each takes – `jstyle("report", save.as = "myagency")` writes one; a
short file hides the settings it takes from its base – and the example,
with a request such as:


    Attached are myagency.jstyle, a jstats table style whose notes say what
    each setting does and what it takes, and Report.pdf. Rewrite the style
    file so that jstats tables look like the tables in the report, following
    the instructions at the top of the file, and list what the settings
    cannot reproduce.

Save its reply over the file and run `jstyle("myagency")`, which names
any value it cannot use (give that back to the assistant), then try the
style: `jtable(c1, style = "myagency", open = TRUE)`. An assistant can
reach only the looks the settings make; it is told to say what it could
not reproduce rather than invent a setting.

## See also

[`jtable`](https://jma61.github.io/jstats/reference/jtable.md) for the
tables,
[`jstyle_settings`](https://jma61.github.io/jstats/reference/jstyle_settings.md)
for every setting a style holds.

## Examples

``` r
# The styles jstats can find, and the folders it looks in
jstyle()
#> Styles
#>   apa     built into jstats (the default)
#>   report  built into jstats
#> 
#> jstats looks for a style file in these folders, in this order:
#>   /home/runner/work/jstats/jstats/docs/reference (the working directory)
#>   /home/runner/.local/share/R/jstats (your jstats folder, not created yet)
#> 

# Every setting of the built-in styles
jstyle("apa")
#> Style: apa
#>   built into jstats
#> 
#> font              = Times New Roman
#> size              = 12
#> paper             = a4
#> caption.form      = apa
#> caption.position  = row
#> caption.size      = size
#> caption.fill      = none
#> caption.text      = 000000
#> header.fill       = none
#> header.text       = 000000
#> header.bold       = no
#> band.fill         = none
#> heading.fill      = none
#> rules             = apa
#> rule.color        = 000000
#> note.label        = Note.
#> note.label.italic = yes
#> note.position     = row
#> note.size         = size
#> note.sentences    = paragraph
#> note.order        = apa
#> source.position   = note
#> source.label      = Source:
#> n.position        = title
#> decimals          = 2
#> leading.zero      = no
#> p.format          = exact
#> p.decimals        = 3
#> stars             = .05, .01, .001
#> marks             = letters
#> minus             = true
#> thousands         = comma
#> landscape         = auto
#> line.spacing      = single
#> percent.decimals  = 1
#> filter.note       = yes
#> 
#> [descriptives]
#> title          = Descriptive Statistics
#> columns        = n, mean, sd, min, max
#> stub.label     = Variable
#> n.label        = n
#> mean.label     = M
#> sd.label       = SD
#> min.label      = Min
#> max.label      = Max
#> group.headings = italic
#> 
#> [frequencies]
#> title               = Frequency Distributions
#> columns             = n, percent
#> stub.label          = Variable
#> n.label             = n
#> percent.label       = %
#> valid.percent.label = Valid %
#> cumulative.label    = Cumulative %
#> missing.rows        = combined
#> missing.label       = Missing
#> variable.headings   = plain
#> group.headings      = italic
#> 
#> [regression]
#> title             = Regression Coefficients Predicting {outcome}
#> columns           = b, se, beta, p
#> columns.last      = none
#> stub.label        = Predictor
#> b.label           = b
#> se.label          = SE
#> beta.label        = β
#> p.label           = p
#> t.label           = t
#> ci.label          = 95% CI
#> beta.gelman.label = β*
#> ci.style          = one
#> intercept         = yes
#> intercept.label   = Constant
#> fit.rows          = r2
#> reference         = row
#> reference.label   = reference
#> variable.headings = plain
#> group.headings    = italic
#> 
#> [logistic]
#> title             = Logistic Regression Coefficients Predicting {outcome}
#> columns           = b, se, or, p
#> columns.last      = none
#> stub.label        = Predictor
#> b.label           = b
#> se.label          = SE
#> or.label          = OR
#> p.label           = p
#> wald.label        = Wald
#> ci.label          = 95% CI for OR
#> beta.gelman.label = β*
#> ci.style          = one
#> intercept         = yes
#> intercept.label   = Constant
#> fit.rows          = chisq, nagelkerke
#> reference         = row
#> reference.label   = reference
#> variable.headings = plain
#> group.headings    = italic
#> 
#> [correlation]
#> title          = Descriptive Statistics and Correlations for Study Variables
#> columns        = n, mean, sd
#> stub.label     = Variable
#> n.label        = n
#> mean.label     = M
#> sd.label       = SD
#> lower.triangle = yes
#> r.stars        = yes
#> method.note    = yes
#> 
#> [ttest]
#> title         = Means, Standard Deviations, and t Tests by {group}
#> columns       = mean, sd, t, p, d
#> stub.label    = Variable
#> n.label       = n
#> mean.label    = M
#> sd.label      = SD
#> t.label       = t
#> df.label      = df
#> df.position   = head
#> p.label       = p
#> d.label       = d
#> diff.label    = Mean difference
#> ci.label      = 95% CI
#> ci.style      = one
#> group.spanner = yes
#> test.note     = yes
#> 
#> [anova]
#> title         = Means, Standard Deviations, and One-Way Analyses of Variance by {group}
#> columns       = mean, sd, f, p, eta2
#> stub.label    = Variable
#> n.label       = n
#> mean.label    = M
#> sd.label      = SD
#> f.label       = F
#> df.label      = df
#> df.position   = head
#> p.label       = p
#> eta2.label    = η²
#> group.spanner = yes
#> test.note     = yes
#> 
#> [crosstab]
#> title             = Frequencies and Percentages by {group}
#> columns           = n, percent
#> total             = yes
#> percent.base      = column
#> test.columns      = chisq, df, p, v
#> stub.label        = Variable
#> n.label           = n
#> percent.label     = %
#> total.label       = Total
#> chisq.label       = χ²
#> df.label          = df
#> p.label           = p
#> v.label           = V
#> group.spanner     = yes
#> variable.headings = plain
#> 
#> [reliability]
#> title                  = Item Statistics and Reliability
#> columns                = mean, sd, item.total, alpha.if.deleted
#> stub.label             = Item
#> mean.label             = M
#> sd.label               = SD
#> item.total.label       = Item-total *r*
#> alpha.if.deleted.label = α if item deleted
#> alpha                  = yes
#> item.total.note        = yes
#> group.headings         = italic
#> 
#> [multiresponse]
#> title         = {set}
#> columns       = n, percent
#> stub.label    = Option
#> n.label       = n
#> percent.label = %
#> none.label    = None of these
#> choice.note   = yes
#> 
jstyle("report")
#> Style: report
#>   built into jstats
#>   based on apa
#> 
#> font              = Arial
#> size              = 10
#> paper             = a4              # from apa
#> caption.form      = report
#> caption.position  = row             # from apa
#> caption.size      = size            # from apa
#> caption.fill      = none            # from apa
#> caption.text      = 000000          # from apa
#> header.fill       = D9D9D9
#> header.text       = 000000          # from apa
#> header.bold       = yes
#> band.fill         = none            # from apa
#> heading.fill      = none            # from apa
#> rules             = apa             # from apa
#> rule.color        = 000000          # from apa
#> note.label        = Note:
#> note.label.italic = no
#> note.position     = row             # from apa
#> note.size         = size - 1
#> note.sentences    = lines
#> note.order        = report
#> source.position   = line
#> source.label      = Source:         # from apa
#> n.position        = title           # from apa
#> decimals          = 2               # from apa
#> leading.zero      = yes
#> p.format          = exact           # from apa
#> p.decimals        = 3               # from apa
#> stars             = .05, .01, .001  # from apa
#> marks             = letters         # from apa
#> minus             = true            # from apa
#> thousands         = comma           # from apa
#> landscape         = auto            # from apa
#> line.spacing      = single          # from apa
#> percent.decimals  = 1               # from apa
#> filter.note       = yes             # from apa
#> 
#> [descriptives]
#> title          = Descriptive Statistics  # from apa
#> columns        = n, mean, sd, min, max   # from apa
#> stub.label     = Variable                # from apa
#> n.label        = n                       # from apa
#> mean.label     = M                       # from apa
#> sd.label       = SD                      # from apa
#> min.label      = Min                     # from apa
#> max.label      = Max                     # from apa
#> group.headings = italic                  # from apa
#> 
#> [frequencies]
#> title               = Frequency Distributions  # from apa
#> columns             = n, percent               # from apa
#> stub.label          = Variable                 # from apa
#> n.label             = n                        # from apa
#> percent.label       = %                        # from apa
#> valid.percent.label = Valid %                  # from apa
#> cumulative.label    = Cumulative %             # from apa
#> missing.rows        = combined                 # from apa
#> missing.label       = Missing                  # from apa
#> variable.headings   = bold
#> group.headings      = italic                   # from apa
#> 
#> [regression]
#> title             = Regression Coefficients Predicting {outcome}  # from apa
#> columns           = b, se, beta, p              # from apa
#> columns.last      = none                        # from apa
#> stub.label        = Predictor                   # from apa
#> b.label           = b                           # from apa
#> se.label          = SE                          # from apa
#> beta.label        = β                           # from apa
#> p.label           = p                           # from apa
#> t.label           = t                           # from apa
#> ci.label          = 95% CI                      # from apa
#> beta.gelman.label = β*                          # from apa
#> ci.style          = one                         # from apa
#> intercept         = yes                         # from apa
#> intercept.label   = Constant                    # from apa
#> fit.rows          = r2                          # from apa
#> reference         = row                         # from apa
#> reference.label   = reference                   # from apa
#> variable.headings = bold
#> group.headings    = italic                      # from apa
#> 
#> [logistic]
#> title             = Logistic Regression Coefficients Predicting {outcome}  # from apa
#> columns           = b, se, or, p                # from apa
#> columns.last      = none                        # from apa
#> stub.label        = Predictor                   # from apa
#> b.label           = b                           # from apa
#> se.label          = SE                          # from apa
#> or.label          = OR                          # from apa
#> p.label           = p                           # from apa
#> wald.label        = Wald                        # from apa
#> ci.label          = 95% CI for OR               # from apa
#> beta.gelman.label = β*                          # from apa
#> ci.style          = one                         # from apa
#> intercept         = yes                         # from apa
#> intercept.label   = Constant                    # from apa
#> fit.rows          = chisq, nagelkerke           # from apa
#> reference         = row                         # from apa
#> reference.label   = reference                   # from apa
#> variable.headings = bold
#> group.headings    = italic                      # from apa
#> 
#> [correlation]
#> title          = Descriptive Statistics and Correlations for Study Variables  # from apa
#> columns        = n, mean, sd                 # from apa
#> stub.label     = Variable                    # from apa
#> n.label        = n                           # from apa
#> mean.label     = M                           # from apa
#> sd.label       = SD                          # from apa
#> lower.triangle = yes                         # from apa
#> r.stars        = yes                         # from apa
#> method.note    = yes                         # from apa
#> 
#> [ttest]
#> title         = Means, Standard Deviations, and t Tests by {group}  # from apa
#> columns       = mean, sd, t, p, d           # from apa
#> stub.label    = Variable                    # from apa
#> n.label       = n                           # from apa
#> mean.label    = M                           # from apa
#> sd.label      = SD                          # from apa
#> t.label       = t                           # from apa
#> df.label      = df                          # from apa
#> df.position   = column
#> p.label       = p                           # from apa
#> d.label       = d                           # from apa
#> diff.label    = Mean difference             # from apa
#> ci.label      = 95% CI                      # from apa
#> ci.style      = one                         # from apa
#> group.spanner = yes                         # from apa
#> test.note     = yes                         # from apa
#> 
#> [anova]
#> title         = Means, Standard Deviations, and One-Way Analyses of Variance by {group}  # from apa
#> columns       = mean, sd, f, p, eta2        # from apa
#> stub.label    = Variable                    # from apa
#> n.label       = n                           # from apa
#> mean.label    = M                           # from apa
#> sd.label      = SD                          # from apa
#> f.label       = F                           # from apa
#> df.label      = df                          # from apa
#> df.position   = column
#> p.label       = p                           # from apa
#> eta2.label    = η²                          # from apa
#> group.spanner = yes                         # from apa
#> test.note     = yes                         # from apa
#> 
#> [crosstab]
#> title             = Frequencies and Percentages by {group}  # from apa
#> columns           = n, percent                  # from apa
#> total             = yes                         # from apa
#> percent.base      = column                      # from apa
#> test.columns      = chisq, df, p, v             # from apa
#> stub.label        = Variable                    # from apa
#> n.label           = n                           # from apa
#> percent.label     = %                           # from apa
#> total.label       = Total                       # from apa
#> chisq.label       = χ²                          # from apa
#> df.label          = df                          # from apa
#> p.label           = p                           # from apa
#> v.label           = V                           # from apa
#> group.spanner     = yes                         # from apa
#> variable.headings = bold
#> 
#> [reliability]
#> title                  = Item Statistics and Reliability  # from apa
#> columns                = mean, sd, item.total, alpha.if.deleted  # from apa
#> stub.label             = Item                        # from apa
#> mean.label             = M                           # from apa
#> sd.label               = SD                          # from apa
#> item.total.label       = Item-total *r*              # from apa
#> alpha.if.deleted.label = α if item deleted           # from apa
#> alpha                  = yes                         # from apa
#> item.total.note        = yes                         # from apa
#> group.headings         = italic                      # from apa
#> 
#> [multiresponse]
#> title         = {set}          # from apa
#> columns       = n, percent     # from apa
#> stub.label    = Option         # from apa
#> n.label       = n              # from apa
#> percent.label = %              # from apa
#> none.label    = None of these  # from apa
#> choice.note   = yes            # from apa
#> 

# A complete copy to edit, and a short one holding two changes
jstyle("apa", save.as = file.path(tempdir(), "myjournal"), overwrite = TRUE)
#> Style written to /tmp/RtmpLJH66q/myjournal.jstyle
#> 
jstyle("apa", save.as = file.path(tempdir(), "myapa"), overwrite = TRUE,
       font = "Arial", regression = list(fit.rows = c("r2", "n")))
#> Style written to /tmp/RtmpLJH66q/myapa.jstyle
#> 
```
