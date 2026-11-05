# Show, list and copy table styles

A style holds a table's look and a journal's or a report's conventions:
the font, the caption's form, the rules, the decimals, and for each
table type its columns and labels. `jstyle()` lists the styles jstats
can find; `jstyle("myjournal")` checks a style file and prints every
setting the style gives, marking each one it takes from another style;
and `jstyle("apa", save.as = "myjournal")` saves a copy as a style file,
myjournal.jstyle, every setting written out with a note on what it does
and what it takes, to edit in any text editor (the step SPSS calls "Save
TableLook As").

## Usage

``` r
jstyle(style = NULL, save.as = NULL, overwrite = FALSE, ...)
```

## Arguments

- style:

  The style's name in quotes, or a path to a style file; NULL (the
  default) lists the styles, or with `save.as` copies
  `joptions(style = )`.

- save.as:

  A name for the copy, in quotes: written as `<name>.jstyle` in the
  style folder when one is set, else in your jstats folder
  (`tools::R_user_dir("jstats")`), or to a path given with a folder.
  "apa" names the built-in style, and "report" one a later version adds,
  so neither can be a copy's name; a file named apa.jstyle is not read,
  and jstats says so.

- overwrite:

  Logical. Replace a style file that exists? With FALSE (the default) an
  interactive session asks, and one that cannot ask stops.

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

Given settings, `jstyle(save.as =)` writes a short file instead: the
style it copies named on its based.on line, and only the settings given,
which is all a small change needs. A general setting is given by its
name; a table type's settings go in a list named for its section:
`jstyle("apa", save.as = "myapa", font = "Arial", regression = list(fit.rows = c("r2", "n")))`.

A style file is plain text: a setting is a name, an equals sign and a
value; a `#` starts a note; the general settings come first, then one
section per table type, `[descriptives]`, `[frequencies]`,
`[regression]`, `[logistic]`, `[correlation]`, `[ttest]`, `[anova]`,
`[crosstab]` and `[reliability]`. A setting the file leaves out comes
from the style its `based.on` line names.
[`jstyle_settings`](https://jma61.github.io/jstats/reference/jstyle_settings.md)
lists every setting and what it takes. jstats looks for a style named in
a call in the style folder (`joptions(style.dir = )`), the working
directory and your jstats folder, in that order.

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
#>   apa  built into jstats (the default)
#> 
#> jstats looks for a style file in these folders, in this order:
#>   /home/runner/work/jstats/jstats/docs/reference (the working directory)
#>   /home/runner/.local/share/R/jstats (your jstats folder, not created yet)
#> 

# Every setting of the built-in style
jstyle("apa")
#> Style: apa
#>   built into jstats
#> 
#> font             = Times New Roman
#> size             = 12
#> paper            = a4
#> caption.form     = apa
#> caption.position = row
#> caption.size     = 12
#> header.fill      = none
#> header.text      = 000000
#> header.bold      = no
#> band.fill        = none
#> rules            = apa
#> rule.color       = 000000
#> note.label       = Note.
#> note.position    = row
#> note.size        = 12
#> n.position       = note
#> decimals         = 2
#> leading.zero     = no
#> p.format         = exact
#> p.decimals       = 3
#> stars            = .05, .01, .001
#> marks            = letters
#> minus            = true
#> thousands        = comma
#> landscape        = auto
#> line.spacing     = single
#> percent.decimals = 1
#> filter.note      = yes
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

# A complete copy to edit, and a short one holding two changes
jstyle("apa", save.as = file.path(tempdir(), "myjournal"), overwrite = TRUE)
#> Style written to /tmp/RtmpeMRyjO/myjournal.jstyle
#> 
jstyle("apa", save.as = file.path(tempdir(), "myapa"), overwrite = TRUE,
       font = "Arial", regression = list(fit.rows = c("r2", "n")))
#> Style written to /tmp/RtmpeMRyjO/myapa.jstyle
#> 
```
