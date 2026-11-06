#<<<FILE: tables.R>>>



# =============================================================================
#  THE TABLE LAYER  (Capability Slate T; Session 400, build 1)
# =============================================================================
#
# jtable() turns a saved analysis result into a publication table: a console
# PREVIEW, and a Word (.docx) file when file = is given. The design is
# JStats_Table_Layer_Reference.txt; the decisions it builds are rulings R45
# (jstats writes the .docx itself, the zip package in Imports) and R47 (the
# preview is a facsimile of the Word table: its formats come from the STYLE,
# not from the console rules the analysis functions follow).
#
# The flow (the reference, Part 2):
#
#   saved result -> accessor -> builder -> table STRUCTURE -> preview writer
#                                                           -> Word writer
#
#   - A BUILDER (one method per result class) reads the result ONLY through
#     the accessors in broom-apa.R, and reads the code and label fields,
#     never a display string. It returns the STRUCTURE: rows (data, group
#     heading), columns (text or number, their labels), the caption, the
#     notes, each cell as an already-formatted string beside its raw
#     number. A builder never writes Word XML or console text.
#   - A STYLE supplies the look and the conventions. In this build the one
#     style is the built-in apa list below; the style FILES, jstyle() and
#     the joptions() keys are build 2. Every key the writers read is here,
#     so a style file can set any of them.
#   - The two WRITERS render the same structure: the preview with cat() and
#     the Word writer as XML parts packed by zip::zip(). Two writers from
#     the first build is what proves the structure carries no Word XML.
#
# Build 1 made the DESCRIPTIVES table (Jeff's Table 1: variables under
# role headings) from jdesc() results; build 2 the frequency table, build 3
# the regression and logistic tables, and build 4 (Session 405) the
# correlation, t-test, ANOVA, crosstab and reliability tables. Every result
# class an analysis function returns has its table type.
#
# Build 5 (Session 406) finished the layer and EXPORTED jtable() and jstyle()
# (ruling R48 ends): one call makes one table (ruling R56), a call reports
# what it made and print() shows a table (ruling R57), several built tables
# go to one file as a document object, each table on the page it needs,
# jstyle(save.as =) writes a short file from settings, and the settings
# help page (jstyle_settings) is generated from .jst_style_spec.


# -----------------------------------------------------------------------------
# 1. The built-in apa style
# -----------------------------------------------------------------------------
#
# The vocabulary a style file will carry (the reference, Part 3): a general
# part, the look, and one section per table type, the conventions. Every
# key has a value here, so a file that sets only what differs from APA
# inherits the rest. A section added here is a table type the package has
# gained; a key added here is one the writers read.

#' Internal: the built-in apa style
#'
#' The general part (the look) and the descriptives section (that table's
#' conventions), each key with APA's value. The complete reference for a
#' style file: a key here is one the writers read, and a key a file leaves
#' out takes its value from here. The caption and the notes are ROWS of the
#' table by default (Jeff, Session 400: the title, the table and its notes
#' travel as one object into a manuscript, and no page break parts them);
#' paragraph puts them outside the table, in Word's Caption style, where
#' only the header row repeats on a continuation page.
#'
#' @keywords internal
.jst_style_apa <- list(
  general = list(
    font             = "Times New Roman",
    size             = 12,            # points
    paper            = "a4",          # a4 | letter: the page the file opens on
    caption.form     = "apa",         # apa: bold "Table 1", italic title next
                                      # line; journal: bold "Table 1." and the
                                      # title on one line; report: "Table 1:"
    caption.position = "row",         # row (a merged first row, no borders,
                                      # repeated with the header) | paragraph
    caption.size     = 12,
    caption.fill     = "none",        # a colour fills the caption row; header:
                                      # the header's fill and text colour
                                      # (Session 409, ruling R58)
    header.fill      = "none",        # a colour fills the header cells
    header.text      = "000000",      # the header text colour
    header.bold      = "no",
    band.fill        = "none",        # a colour fills alternate data rows
    heading.fill     = "none",        # a colour fills each variable's label
                                      # row (Session 409, ruling R58)
    rules            = "apa",         # apa: top, under the header, bottom;
                                      # grid; outer; none
    rule.color       = "000000",
    note.label       = "Note.",       # "Notes:", "Source:"
    note.label.italic = "yes",        # the note's label in italics, as APA
                                      # sets it (Session 409, ruling R58)
    note.position    = "row",         # row (a merged last row) | paragraph
    note.size        = 12,
    n.position       = "note",        # note: the general note opens on N;
                                      # title: "(N = 103)" after the title;
                                      # none (ruling R51, build 3)
    decimals         = 2,             # statistics (a mean, an SD, b, SE)
    leading.zero     = "no",          # no: dropped for a statistic bounded
                                      # by 1 (r, p, beta, R2, eta2, alpha,
                                      # V); yes: kept; never: dropped on
                                      # every number below 1 (build 3)
    p.format         = "exact",       # exact | stars | both
    p.decimals       = 3,
    stars            = c(0.05, 0.01, 0.001),
    marks            = "letters",     # letters: superscript a, b, c; symbols:
                                      # dagger, double dagger, section sign
    minus            = "true",        # true: the minus sign; hyphen
    thousands        = "comma",       # comma | none, in counts and statistics
    landscape        = "auto",        # auto | yes | no
    line.spacing     = "single",      # single | double
    percent.decimals = 1,             # a percentage's decimal places (build 2)
    filter.note      = "yes"          # yes: the general note says which cases
                                      # a filter kept (build 4) | no
  ),
  descriptives = list(
    title          = "Descriptive Statistics",
    columns        = c("n", "mean", "sd", "min", "max"),
    stub.label     = "Variable",
    n.label        = "n",
    mean.label     = "M",
    sd.label       = "SD",
    min.label      = "Min",
    max.label      = "Max",
    group.headings = "italic"         # italic | bold | plain
  ),
  frequencies = list(
    title               = "Frequency Distributions",
    columns             = c("n", "percent"),  # n, percent, valid.percent,
                                              # cumulative
    stub.label          = "Variable",
    n.label             = "n",
    percent.label       = "%",
    valid.percent.label = "Valid %",
    cumulative.label    = "Cumulative %",
    missing.rows        = "combined",    # combined | each | none
    missing.label       = "Missing",
    variable.headings   = "plain",       # plain | italic | bold
    group.headings      = "italic"       # italic | bold | plain
  ),
  regression = list(                   # jlm() results (build 3, S403)
    title             = "Regression Coefficients Predicting {outcome}",
    columns           = c("b", "se", "beta", "p"),  # t, ci, beta.gelman
    columns.last      = "none",        # columns added to the last model only
    stub.label        = "Predictor",   # ruling R49
    b.label           = "b",
    se.label          = "SE",
    beta.label        = "\u03b2",
    p.label           = "p",
    t.label           = "t",
    ci.label          = "95% CI",
    beta.gelman.label = "\u03b2*",
    ci.style          = "one",         # one: "[LL, UL]" | two: LL and UL
    intercept         = "yes",         # the constant's row: yes | no
    intercept.label   = "Constant",
    fit.rows          = "r2",          # r2, adj.r2, f, delta.r2, f.change,
                                       # n, or none
    reference         = "row",         # row | note | none
    reference.label   = "reference",
    variable.headings = "plain",       # a dummy-coded variable's label row
    group.headings    = "italic"       # (headings = is not read; kept for
                                       # the shared writer)
  ),
  logistic = list(                     # jlogistic() results (build 3, S403)
    title             = "Logistic Regression Coefficients Predicting {outcome}",
    columns           = c("b", "se", "or", "p"),  # wald, ci, beta.gelman
    columns.last      = "none",
    stub.label        = "Predictor",
    b.label           = "b",
    se.label          = "SE",
    or.label          = "OR",
    p.label           = "p",
    wald.label        = "Wald",
    ci.label          = "95% CI for OR",
    beta.gelman.label = "\u03b2*",
    ci.style          = "one",
    intercept         = "yes",
    intercept.label   = "Constant",
    fit.rows          = c("chisq", "nagelkerke"),  # neg2ll, cox.snell,
                                                   # aic, n, none
    reference         = "row",
    reference.label   = "reference",
    variable.headings = "plain",
    group.headings    = "italic"
  ),
  correlation = list(                  # a jcorr() result (build 4, S405)
    title          = "Descriptive Statistics and Correlations for Study Variables",
    columns        = c("n", "mean", "sd"),  # before the matrix, or none
    stub.label     = "Variable",
    n.label        = "n",
    mean.label     = "M",
    sd.label       = "SD",
    lower.triangle = "yes",            # yes: r below the diagonal | no: both
    r.stars        = "yes",            # yes: asterisks on r for its p-value
    method.note    = "yes"             # the sentence naming a Spearman or
                                       # Kendall table's correlations
  ),
  ttest = list(                        # jt() results (build 4)
    title          = "Means, Standard Deviations, and t Tests by {group}",
    columns        = c("mean", "sd", "t", "p", "d"),  # n, diff, ci
    stub.label     = "Variable",
    n.label        = "n",
    mean.label     = "M",
    sd.label       = "SD",
    t.label        = "t",
    df.label       = "df",
    p.label        = "p",
    d.label        = "d",
    diff.label     = "Mean difference",
    ci.label       = "95% CI",
    ci.style       = "one",            # one: "[LL, UL]" | two: LL and UL
    group.spanner  = "yes",            # the grouping variable's label over
                                       # the groups
    test.note      = "yes"             # the sentence on a Welch or a paired
                                       # test
  ),
  anova = list(                        # jaov() results (build 4)
    title          = "Means, Standard Deviations, and One-Way Analyses of Variance by {group}",
    columns        = c("mean", "sd", "f", "p", "eta2"),  # n
    stub.label     = "Variable",
    n.label        = "n",
    mean.label     = "M",
    sd.label       = "SD",
    f.label        = "F",
    df.label       = "df",
    p.label        = "p",
    eta2.label     = "\u03b7\u00b2",
    group.spanner  = "yes",
    test.note      = "yes"
  ),
  crosstab = list(                     # jcrosstab() results (build 4)
    title             = "Frequencies and Percentages by {group}",
    columns           = c("n", "percent"),  # each group's, and the total's
    total             = "yes",         # the Total column: yes | no
    percent.base      = "column",      # column (within each group) | row |
                                       # total
    test.columns      = c("chisq", "df", "p", "v"),  # on each variable's
                                                     # row, or none
    stub.label        = "Variable",
    n.label           = "n",
    percent.label     = "%",
    total.label       = "Total",
    chisq.label       = "\u03c7\u00b2",
    df.label          = "df",
    p.label           = "p",
    v.label           = "V",
    group.spanner     = "yes",
    variable.headings = "plain"        # a variable's label row
  ),
  reliability = list(                  # jalpha() results (build 4)
    title                  = "Item Statistics and Reliability",
    columns                = c("mean", "sd", "item.total", "alpha.if.deleted"),
    stub.label             = "Item",
    mean.label             = "M",
    sd.label               = "SD",
    item.total.label       = "Item-total *r*",
    alpha.if.deleted.label = "\u03b1 if item deleted",
    alpha                  = "yes",    # Cronbach's alpha in the note, or after
                                       # each scale's name
    item.total.note        = "yes",    # the sentence defining item-total r
    group.headings         = "italic"  # a scale's name row
  )
)

# The column heads a style may italicize: APA sets a statistic's symbol in
# italics (n, M, SD, p, r, t, F, b, SE, R2, OR, V), and a word (Min, Max,
# Variable, Wald) and a Greek letter (beta, eta2, alpha, chi2) upright
# (APA's list of statistical abbreviations; Session 402). Keyed by the
# column key, read by the builders. A head whose label carries the light
# markup -- "Item-total *r*", "*t*(101)" -- is set by its markup instead
# (Session 405).
.jst_tbl_italic_heads <- c("n", "mean", "sd", "p", "r", "t", "f", "b", "se",
                           "df", "r2", "adj.r2", "or", "d", "v")

#' Internal helper: which of a table's column heads are set in italics
#'
#' APA sets a statistic's SYMBOL in italics (n, M, SD) and a word upright.
#' A head is italic when its column is a statistic's
#' (\code{.jst_tbl_italic_heads}) and its label is still the symbol the
#' built-in apa style gives it: a word a style puts in its place -- "Mean",
#' "Std Dev." -- is set upright (Session 401, on the journal file's walk).
#'
#' @param type The table type.
#' @param keys The columns' keys, the stub's first.
#' @param labels Their labels.
#' @return Logical, one per column.
#' @keywords internal
.jst_tbl_head_italic <- function(type, keys, labels) {
  sym <- vapply(keys, function(k) {
    v <- .jst_style_apa[[type]][[paste0(k, ".label")]]
    if (is.null(v)) NA_character_ else v
  }, character(1), USE.NAMES = FALSE)
  keys %in% .jst_tbl_italic_heads & !is.na(sym) & labels == sym
}

# -----------------------------------------------------------------------------
# 1b. Style files (build 2; ruling R46)
# -----------------------------------------------------------------------------
#
# A style FILE carries a journal's or a report's look and conventions in
# plain text that Notepad edits: key = value lines, UTF-8, the extension
# .jstyle; a comment after #; the general part first, then one [section]
# per table type. Three lines at the top are the file's own: format and
# written.by (stamped by jstyle(save.as =)), and based.on, the style a
# setting the file leaves out comes from (apa when it names none).
#
# A STYLE, resolved, is a list of LAYERS read first to last for each
# setting (the reference, Part 3.2): a call's own settings, the file's
# section for the table's type, the file's general part, the same in the
# style based.on names, and so on to the built-in apa list, which is
# complete. Every value is checked against .jst_style_spec when it is
# read, so a writer never meets a value it cannot use.

#' Internal: what each style setting takes
#'
#' One entry per setting of the built-in apa list, by part: its kind (text,
#' choice, number, integer, color, columns, stars), what the kind needs
#' (the choices; the range; the columns a table type has; whether "none"
#' or an empty text is allowed), and what the setting does, which
#' jstyle(save.as =) writes as the setting's comment. The reader checks a
#' file's values against it, jtable() a call's, and tables_check.R that
#' it and .jst_style_apa name the same settings.
#'
#' @keywords internal
.jst_style_spec <- list(
  general = list(
    font             = list(kind = "text", about = "the typeface of every cell, caption and note"),
    size             = list(kind = "number", min = 6, max = 72,
                            about = "the text size, in points"),
    paper            = list(kind = "choice", choices = c("a4", "letter"),
                            about = "the page the file opens on: a4 | letter"),
    caption.form     = list(kind = "choice", choices = c("apa", "journal", "report"),
                            about = c("apa: bold \"Table 1\", the italic title on the next line",
                                      "journal: bold \"Table 1.\" and the title on one line",
                                      "report: \"Table 1:\" and the title")),
    caption.position = list(kind = "choice", choices = c("row", "paragraph"),
                            about = c("row: the table's first row, repeated with the header on a new page",
                                      "paragraph: above the table")),
    caption.size     = list(kind = "number", min = 6, max = 72,
                            about = "the caption's text size, in points"),
    caption.fill     = list(kind = "color", none = TRUE, header = TRUE,
                            about = c("a color filling the caption row (caption.position = row), header for",
                                      "the header's fill and text color, or none")),
    header.fill      = list(kind = "color", none = TRUE,
                            about = "a color filling the header cells, or none"),
    header.text      = list(kind = "color", about = "the color of the header's text"),
    header.bold      = list(kind = "choice", choices = c("yes", "no"),
                            about = "bold header text: yes | no"),
    band.fill        = list(kind = "color", none = TRUE,
                            about = "a color filling every other data row, or none"),
    heading.fill     = list(kind = "color", none = TRUE,
                            about = c("a color filling each variable's label row (the rows variable.headings",
                                      "sets), or none")),
    rules            = list(kind = "choice", choices = c("apa", "grid", "outer", "none"),
                            about = c("apa: rules above and below the header and under the table",
                                      "grid: every cell | outer: a box | none")),
    rule.color       = list(kind = "color", about = "the color of the rules"),
    note.label       = list(kind = "text", empty = TRUE,
                            about = "the word the general note opens on: Note. | Notes: | Source:"),
    note.label.italic = list(kind = "choice", choices = c("yes", "no"),
                             about = "the note's label in italics, as APA sets it: yes | no"),
    note.position    = list(kind = "choice", choices = c("row", "paragraph"),
                            about = "row: the table's last row | paragraph: under the table"),
    note.size        = list(kind = "number", min = 6, max = 72,
                            about = "the notes' text size, in points"),
    n.position       = list(kind = "choice", choices = c("note", "title", "none"),
                            about = c("where N, the number of cases, goes: note (the general note opens",
                                      "on it) | title (\"(N = 103)\" after the title) | none")),
    decimals         = list(kind = "integer", min = 0, max = 6,
                            about = "the decimal places of a statistic, such as a mean"),
    leading.zero     = list(kind = "choice", choices = c("yes", "no", "never"),
                            about = c("the zero before the point: no drops it on a statistic that cannot",
                                      "exceed 1, such as p (.23) | yes keeps it (0.23) | never drops it on",
                                      "every number below 1 (.197 for an SE)")),
    p.format         = list(kind = "choice", choices = c("exact", "stars", "both"),
                            about = "exact: the p-value | stars: asterisks | both"),
    p.decimals       = list(kind = "integer", min = 1, max = 6,
                            about = "the decimal places of a p-value"),
    stars            = list(kind = "stars",
                            about = "the p-values the asterisks mark, largest first"),
    marks            = list(kind = "choice", choices = c("letters", "symbols"),
                            about = "the marks of the notes on rows: letters (a, b, c) | symbols (daggers)"),
    minus            = list(kind = "choice", choices = c("true", "hyphen"),
                            about = "true: a true minus sign | hyphen: the keyboard's hyphen"),
    thousands        = list(kind = "choice", choices = c("comma", "none"),
                            about = "comma: 1,037 | none: 1037"),
    landscape        = list(kind = "choice", choices = c("auto", "yes", "no"),
                            about = c("auto: a landscape page when the table is wider than a portrait one",
                                      "| yes | no")),
    line.spacing     = list(kind = "choice", choices = c("single", "double"),
                            about = "single | double"),
    percent.decimals = list(kind = "integer", min = 0, max = 4,
                            about = "the decimal places of a percentage"),
    filter.note      = list(kind = "choice", choices = c("yes", "no"),
                            about = c("yes: the general note says which cases a filter kept (jsubset(),",
                                      "subset =) | no"))
  ),
  descriptives = list(
    title          = list(kind = "text", about = "the title when the call gives none"),
    columns        = list(kind = "columns", cols = c("n", "mean", "sd", "min", "max"),
                          about = "the columns, in order: n, mean, sd, min, max"),
    stub.label     = list(kind = "text", empty = TRUE, about = "the first column's head"),
    n.label        = list(kind = "text", empty = TRUE, about = "the head of the n column"),
    mean.label     = list(kind = "text", empty = TRUE, about = "the head of the mean column"),
    sd.label       = list(kind = "text", empty = TRUE, about = "the head of the sd column"),
    min.label      = list(kind = "text", empty = TRUE, about = "the head of the min column"),
    max.label      = list(kind = "text", empty = TRUE, about = "the head of the max column"),
    group.headings = list(kind = "choice", choices = c("italic", "bold", "plain"),
                          about = "how a heading from headings = is set: italic | bold | plain")
  ),
  frequencies = list(
    title               = list(kind = "text", about = "the title when the call gives none"),
    columns             = list(kind = "columns",
                               cols = c("n", "percent", "valid.percent", "cumulative"),
                               about = c("the columns, in order: n, percent (of all cases), valid.percent,",
                                         "cumulative")),
    stub.label          = list(kind = "text", empty = TRUE, about = "the first column's head"),
    n.label             = list(kind = "text", empty = TRUE, about = "the head of the n column"),
    percent.label       = list(kind = "text", empty = TRUE,
                               about = "the head of the percent column"),
    valid.percent.label = list(kind = "text", empty = TRUE,
                               about = "the head of the valid.percent column"),
    cumulative.label    = list(kind = "text", empty = TRUE,
                               about = "the head of the cumulative column"),
    missing.rows        = list(kind = "choice", choices = c("combined", "each", "none"),
                               about = c("a variable's missing cases: combined (one row) | each (a row per",
                                         "missing value) | none")),
    missing.label       = list(kind = "text", about = "the label of the combined missing row"),
    variable.headings   = list(kind = "choice", choices = c("plain", "italic", "bold"),
                               about = "how each variable's label row is set: plain | italic | bold"),
    group.headings      = list(kind = "choice", choices = c("italic", "bold", "plain"),
                               about = "how a heading from headings = is set: italic | bold | plain")
  ),
  regression = list(
    title             = list(kind = "text",
                             about = c("the title when the call gives none; {outcome} is the outcome's",
                                       "label")),
    columns           = list(kind = "columns",
                             cols = c("b", "se", "beta", "p", "t", "ci", "beta.gelman"),
                             about = c("the columns of each model, in order: b, se, beta, p, t, ci,",
                                       "beta.gelman (Gelman's standardized coefficient)")),
    columns.last      = list(kind = "columns", none = TRUE,
                             cols = c("b", "se", "beta", "p", "t", "ci", "beta.gelman"),
                             about = "columns added to the last model only, or none"),
    stub.label        = list(kind = "text", empty = TRUE, about = "the first column's head"),
    b.label           = list(kind = "text", empty = TRUE, about = "the head of the b column"),
    se.label          = list(kind = "text", empty = TRUE, about = "the head of the se column"),
    beta.label        = list(kind = "text", empty = TRUE, about = "the head of the beta column"),
    p.label           = list(kind = "text", empty = TRUE, about = "the head of the p column"),
    t.label           = list(kind = "text", empty = TRUE, about = "the head of the t column"),
    ci.label          = list(kind = "text", empty = TRUE, about = "the head of the ci column"),
    beta.gelman.label = list(kind = "text", empty = TRUE,
                             about = "the head of the beta.gelman column"),
    ci.style          = list(kind = "choice", choices = c("one", "two"),
                             about = "one: the interval in one column, [LL, UL] | two: LL and UL"),
    intercept         = list(kind = "choice", choices = c("yes", "no"),
                             about = "the constant's row, first in the table: yes | no"),
    intercept.label   = list(kind = "text", about = "the constant's row label"),
    fit.rows          = list(kind = "columns", none = TRUE,
                             cols = c("r2", "adj.r2", "f", "delta.r2", "f.change", "n"),
                             about = c("the fit rows under the predictors, in order: r2, adj.r2, f,",
                                       "delta.r2 (nested models), f.change (its F test), n, or none")),
    reference         = list(kind = "choice", choices = c("row", "note", "none"),
                             about = c("where a dummy-coded variable's reference category is named: row",
                                       "(after its label) | note (the general note) | none")),
    reference.label   = list(kind = "text",
                             about = "the word before the reference category: reference | ref."),
    variable.headings = list(kind = "choice", choices = c("plain", "italic", "bold"),
                             about = "how a dummy-coded variable's label row is set: plain | italic | bold"),
    group.headings    = list(kind = "choice", choices = c("italic", "bold", "plain"),
                             about = "how a heading row is set: italic | bold | plain")
  ),
  logistic = list(
    title             = list(kind = "text",
                             about = c("the title when the call gives none; {outcome} is the outcome's",
                                       "label")),
    columns           = list(kind = "columns",
                             cols = c("b", "se", "or", "p", "wald", "ci", "beta.gelman"),
                             about = c("the columns of each model, in order: b, se, or (the odds ratio),",
                                       "p, wald, ci (for the odds ratio), beta.gelman")),
    columns.last      = list(kind = "columns", none = TRUE,
                             cols = c("b", "se", "or", "p", "wald", "ci", "beta.gelman"),
                             about = "columns added to the last model only, or none"),
    stub.label        = list(kind = "text", empty = TRUE, about = "the first column's head"),
    b.label           = list(kind = "text", empty = TRUE, about = "the head of the b column"),
    se.label          = list(kind = "text", empty = TRUE, about = "the head of the se column"),
    or.label          = list(kind = "text", empty = TRUE, about = "the head of the or column"),
    p.label           = list(kind = "text", empty = TRUE, about = "the head of the p column"),
    wald.label        = list(kind = "text", empty = TRUE, about = "the head of the wald column"),
    ci.label          = list(kind = "text", empty = TRUE, about = "the head of the ci column"),
    beta.gelman.label = list(kind = "text", empty = TRUE,
                             about = "the head of the beta.gelman column"),
    ci.style          = list(kind = "choice", choices = c("one", "two"),
                             about = "one: the interval in one column, [LL, UL] | two: LL and UL"),
    intercept         = list(kind = "choice", choices = c("yes", "no"),
                             about = "the constant's row, first in the table: yes | no"),
    intercept.label   = list(kind = "text", about = "the constant's row label"),
    fit.rows          = list(kind = "columns", none = TRUE,
                             cols = c("chisq", "nagelkerke", "cox.snell", "neg2ll", "aic", "n"),
                             about = c("the fit rows under the predictors, in order: chisq (the model",
                                       "chi-square), nagelkerke, cox.snell, neg2ll, aic, n, or none")),
    reference         = list(kind = "choice", choices = c("row", "note", "none"),
                             about = c("where a dummy-coded variable's reference category is named: row",
                                       "(after its label) | note (the general note) | none")),
    reference.label   = list(kind = "text",
                             about = "the word before the reference category: reference | ref."),
    variable.headings = list(kind = "choice", choices = c("plain", "italic", "bold"),
                             about = "how a dummy-coded variable's label row is set: plain | italic | bold"),
    group.headings    = list(kind = "choice", choices = c("italic", "bold", "plain"),
                             about = "how a heading row is set: italic | bold | plain")
  ),
  correlation = list(
    title          = list(kind = "text", about = "the title when the call gives none"),
    columns        = list(kind = "columns", none = TRUE, cols = c("n", "mean", "sd"),
                          about = "the columns before the correlations, in order: n, mean, sd, or none"),
    stub.label     = list(kind = "text", empty = TRUE, about = "the first column's head"),
    n.label        = list(kind = "text", empty = TRUE, about = "the head of the n column"),
    mean.label     = list(kind = "text", empty = TRUE, about = "the head of the mean column"),
    sd.label       = list(kind = "text", empty = TRUE, about = "the head of the sd column"),
    lower.triangle = list(kind = "choice", choices = c("yes", "no"),
                          about = "yes: each correlation once, below the diagonal | no: both triangles"),
    r.stars        = list(kind = "choice", choices = c("yes", "no"),
                          about = c("yes: asterisks on each correlation for its p-value, explained under",
                                    "the table | no")),
    method.note    = list(kind = "choice", choices = c("yes", "no"),
                          about = "yes: the note names a Spearman or Kendall table's correlations | no")
  ),
  ttest = list(
    title          = list(kind = "text",
                          about = c("the title when the call gives none; {group} is the grouping",
                                    "variable's label")),
    columns        = list(kind = "columns",
                          cols = c("n", "mean", "sd", "t", "p", "d", "diff", "ci"),
                          about = c("the columns, in order: each group's n, mean and sd, then t (with",
                                    "its df), p, d (Cohen's d), diff (the mean difference) and ci (its",
                                    "confidence interval)")),
    stub.label     = list(kind = "text", empty = TRUE, about = "the first column's head"),
    n.label        = list(kind = "text", empty = TRUE, about = "the head of the n column"),
    mean.label     = list(kind = "text", empty = TRUE, about = "the head of the mean column"),
    sd.label       = list(kind = "text", empty = TRUE, about = "the head of the sd column"),
    t.label        = list(kind = "text", empty = TRUE, about = "the head of the t column"),
    df.label       = list(kind = "text", empty = TRUE,
                          about = "the head of the df column, when the tests' df differ"),
    p.label        = list(kind = "text", empty = TRUE, about = "the head of the p column"),
    d.label        = list(kind = "text", empty = TRUE, about = "the head of the d column"),
    diff.label     = list(kind = "text", empty = TRUE, about = "the head of the diff column"),
    ci.label       = list(kind = "text", empty = TRUE, about = "the head of the ci column"),
    ci.style       = list(kind = "choice", choices = c("one", "two"),
                          about = "one: the interval in one column, [LL, UL] | two: LL and UL"),
    group.spanner  = list(kind = "choice", choices = c("yes", "no"),
                          about = "yes: the grouping variable's label over the groups' columns | no"),
    test.note      = list(kind = "choice", choices = c("yes", "no"),
                          about = "yes: the note says when a test is Welch's or a paired test | no")
  ),
  anova = list(
    title          = list(kind = "text",
                          about = c("the title when the call gives none; {group} is the grouping",
                                    "variable's label")),
    columns        = list(kind = "columns", cols = c("n", "mean", "sd", "f", "p", "eta2"),
                          about = c("the columns, in order: each group's n, mean and sd, then f (with",
                                    "its df), p, eta2")),
    stub.label     = list(kind = "text", empty = TRUE, about = "the first column's head"),
    n.label        = list(kind = "text", empty = TRUE, about = "the head of the n column"),
    mean.label     = list(kind = "text", empty = TRUE, about = "the head of the mean column"),
    sd.label       = list(kind = "text", empty = TRUE, about = "the head of the sd column"),
    f.label        = list(kind = "text", empty = TRUE, about = "the head of the f column"),
    df.label       = list(kind = "text", empty = TRUE,
                          about = "the head of the df column, when the tests' df differ"),
    p.label        = list(kind = "text", empty = TRUE, about = "the head of the p column"),
    eta2.label     = list(kind = "text", empty = TRUE, about = "the head of the eta2 column"),
    group.spanner  = list(kind = "choice", choices = c("yes", "no"),
                          about = "yes: the grouping variable's label over the groups' columns | no"),
    test.note      = list(kind = "choice", choices = c("yes", "no"),
                          about = "yes: the note says when a test is Welch's | no")
  ),
  crosstab = list(
    title             = list(kind = "text",
                             about = c("the title when the call gives none; {group} is the column",
                                       "variable's label")),
    columns           = list(kind = "columns", cols = c("n", "percent"),
                             about = "each group's columns, in order: n, percent"),
    total             = list(kind = "choice", choices = c("yes", "no"),
                             about = "yes: a Total column after the groups | no"),
    percent.base      = list(kind = "choice", choices = c("column", "row", "total"),
                             about = c("what a percentage is of: column (each group's cases) | row (each",
                                       "category's) | total (all cases)")),
    test.columns      = list(kind = "columns", none = TRUE, cols = c("chisq", "df", "p", "v"),
                             about = c("the chi-square test's columns on each variable's row, in order:",
                                       "chisq, df, p, v (Cramer's V), or none")),
    stub.label        = list(kind = "text", empty = TRUE, about = "the first column's head"),
    n.label           = list(kind = "text", empty = TRUE, about = "the head of the n column"),
    percent.label     = list(kind = "text", empty = TRUE,
                             about = "the head of the percent column"),
    total.label       = list(kind = "text", about = "the head over the Total column"),
    chisq.label       = list(kind = "text", empty = TRUE, about = "the head of the chisq column"),
    df.label          = list(kind = "text", empty = TRUE, about = "the head of the df column"),
    p.label           = list(kind = "text", empty = TRUE, about = "the head of the p column"),
    v.label           = list(kind = "text", empty = TRUE, about = "the head of the v column"),
    group.spanner     = list(kind = "choice", choices = c("yes", "no"),
                             about = "yes: the column variable's label over the groups' columns | no"),
    variable.headings = list(kind = "choice", choices = c("plain", "italic", "bold"),
                             about = "how each variable's label row is set: plain | italic | bold")
  ),
  reliability = list(
    title                  = list(kind = "text", about = "the title when the call gives none"),
    columns                = list(kind = "columns",
                                  cols = c("mean", "sd", "item.total", "alpha.if.deleted"),
                                  about = c("the columns, in order: mean, sd, item.total (the corrected",
                                            "item-total correlation), alpha.if.deleted")),
    stub.label             = list(kind = "text", empty = TRUE, about = "the first column's head"),
    mean.label             = list(kind = "text", empty = TRUE,
                                  about = "the head of the mean column"),
    sd.label               = list(kind = "text", empty = TRUE, about = "the head of the sd column"),
    item.total.label       = list(kind = "text", empty = TRUE,
                                  about = "the head of the item.total column; *r* sets r in italics"),
    alpha.if.deleted.label = list(kind = "text", empty = TRUE,
                                  about = "the head of the alpha.if.deleted column"),
    alpha                  = list(kind = "choice", choices = c("yes", "no"),
                                  about = c("yes: Cronbach's alpha in the note, or after each scale's name",
                                            "when the table holds several | no")),
    item.total.note        = list(kind = "choice", choices = c("yes", "no"),
                                  about = "yes: the note says what the item.total column is | no"),
    group.headings         = list(kind = "choice", choices = c("italic", "bold", "plain"),
                                  about = "how a scale's name row is set: italic | bold | plain")
  )
)

# The table types, as messages name them, in the file's section order.
.jst_style_type_nouns <- c(descriptives = "a descriptives table",
                           frequencies  = "a frequency table",
                           regression   = "a regression table",
                           logistic     = "a logistic regression table",
                           correlation  = "a correlation table",
                           ttest        = "a t-test table",
                           anova        = "an ANOVA table",
                           crosstab     = "a crosstab",
                           reliability  = "a reliability table")

# The table type of each result class (Session 405: every class has one).
.jst_table_types <- c(jst_desc = "descriptives", jst_freq = "frequencies",
                      jst_lm = "regression", jst_logistic = "logistic",
                      jst_corr = "correlation", jst_ttest = "ttest",
                      jst_anova = "anova", jst_crosstab = "crosstab",
                      jst_alpha = "reliability")

#' Internal: the built-in report style
#'
#' The second built-in (ruling R58, Session 408; built Session 409): a
#' SHORT style based on apa, which stays the complete root of every
#' based.on chain. It holds only the values the report style manuals share
#' where apa's differ -- the UK Government Analysis Function, the
#' Australian Government Style Manual, the UN Editorial Manual, and the US
#' agencies' forms, which differ from it by a setting or two (the Table
#' Layer Reference, 8.8): Arial 10, the caption 10 and the note 9, "Table
#' 1:" with the title on one line, a light grey bold header, apa's three
#' rules, no banding, the zero before the point (build 1's lean, Session
#' 409: most of the guidance writes it -- NIH, the GPO manual, CDC's
#' Emerging Infectious Diseases, the Australian and UK manuals -- and
#' NCES's table guidelines alone drop it on a statistic that cannot exceed
#' 1; Jeff: "Okay to keep your lean in this"), an upright "Note:", each
#' variable's label row bold. The new looks (caption.fill, heading.fill)
#' stay off, so a brand look is only ever turned on, in a user's own short
#' file based on this one.
#'
#' @keywords internal
.jst_style_report <- list(
  general = list(
    font              = "Arial",
    size              = 10,
    caption.form      = "report",
    caption.size      = 10,
    header.fill       = "D9D9D9",
    header.bold       = "yes",
    note.label        = "Note:",
    note.label.italic = "no",
    note.size         = 9,
    leading.zero      = "yes"
  ),
  frequencies = list(variable.headings = "bold"),
  regression  = list(variable.headings = "bold"),
  logistic    = list(variable.headings = "bold"),
  crosstab    = list(variable.headings = "bold")
)

#' Internal helper: the built-in styles
#'
#' The styles jstats ships, by name: apa, the complete root, and report, a
#' short style based on it (Session 409, ruling R58). A name here always
#' means the built-in, so a style file cannot take one
#' (\code{.jst_style_files()} leaves them out).
#' @return A named list of style parts lists.
#' @keywords internal
.jst_style_builtin <- function() list(apa = .jst_style_apa, report = .jst_style_report)

# The built-in each built-in is based on; apa, the root, has none.
.jst_style_builtin_base <- c(report = "apa")

#' Internal helper: a built-in style's layers
#'
#' The built-in's own list, then the lists of the built-ins it is based
#' on, apa last: report reads its own values, then apa's.
#'
#' @param b Character(1); a built-in style's name.
#' @return A list of layers, each a parts list with its source.
#' @keywords internal
.jst_style_builtin_layers <- function(b) {
  out  <- list(c(list(source = b), .jst_style_builtin()[[b]]))
  base <- unname(.jst_style_builtin_base[b])
  if (!is.na(base)) out <- c(out, .jst_style_builtin_layers(base))
  out
}

#' Internal helper: the names kept for built-in styles still to come
#'
#' A built-in's name wins over any file, so a file saved under the name of
#' a built-in a later version adds would stop being read the day that
#' version is installed, and a file based on it would change its base.
#' \code{jstyle(save.as = )} refuses these names, as it refuses a
#' built-in's (Session 407). A name moves from here to
#' \code{.jst_style_builtin()} when its style ships: \code{report} did at
#' Session 409, and none is kept now.
#' @keywords internal
.jst_style_reserved <- character(0)

#' Internal helper: style files named like a built-in style
#'
#' The \code{.jstyle} files in the folders searched whose name, the
#' letters' case aside, is a built-in style's: never read, since the
#' built-in's name always means the built-in (Session 407).
#'
#' @param name Character(1); a built-in style's name.
#' @return Character; the files' paths, in the folders' order.
#' @keywords internal
.jst_style_shadowed <- function(name) {
  out <- character(0)
  for (d in .jst_style_dirs()) {
    if (!dir.exists(d)) next
    f  <- list.files(d, pattern = "\\.jstyle$", ignore.case = TRUE,
                     full.names = TRUE)
    nm <- sub("\\.jstyle$", "", basename(f), ignore.case = TRUE)
    out <- c(out, f[tolower(nm) == tolower(name)])
  }
  out
}

#' Internal helper: the note for style files named like a built-in style
#'
#' Said where such a file is passed over: when a call names the built-in
#' (or takes it as the session's style), and under \code{jstyle()}'s list
#' of styles (Session 407, the (S406) item's lean, Jeff's default).
#'
#' @param name Character(1); the built-in style's name.
#' @param paths Character; the files, from \code{.jst_style_shadowed()}.
#' @return Character(1), the note, or NULL when there are no files.
#' @keywords internal
.jst_style_shadowed_note <- function(name, paths) {
  if (!length(paths)) return(NULL)
  one <- length(paths) == 1L
  paste0(if (one) "This file is" else "These files are",
         " not read, since \"", name, "\" always names a style built into ",
         "jstats:\n",
         paste0("  ", .jst_norm_path(paths), collapse = "\n"), "\n",
         "To use ", if (one) "it" else "one", ", rename it, for example to my",
         name, ".jstyle, and use style = \"my", name, "\".")
}

#' Internal helper: the style a jtable() call uses
#'
#' Resolves \code{style =} into a STYLE (class "jst_style"): its layers,
#' read first to last for each setting -- the file named, the style its
#' based.on names, and so on, the built-in apa list last. A resolved style
#' passes through unchanged, and a bare list of parts (the built-in apa
#' list) is made one. NULL takes the session's default,
#' \code{joptions(style = )}, apa when none is set.
#'
#' A NAME is looked for as \code{<name>.jstyle} in the style folder
#' (\code{joptions(style.dir = )}) when one is set, then the working
#' directory, then the per-user folder \code{tools::R_user_dir("jstats")}
#' gives (the reference, Part 1, R46), the letters' case aside; "apa" is
#' the built-in style's name and always means it. A name given with its
#' .jstyle is the name. A PATH -- a name holding a slash -- is read as
#' given, .jstyle added when it has no extension.
#'
#' @param style A style's name or path, a resolved style, or NULL.
#' @param fn The user-facing function's name, for the stops.
#' @param cl,mc The call as typed and the matched call, for the line a
#'   near miss offers; NULL gives the sentence alone.
#' @return An object of class "jst_style": name, path (NA for a built-in),
#'   layers (each a list: source, general and one list per table type) and
#'   skipped (settings a newer jstats wrote, passed over with a note).
#' @keywords internal
.jst_style_resolve <- function(style = NULL, fn = "jtable", cl = NULL,
                               mc = NULL) {
  if (inherits(style, "jst_style")) return(style)
  if (is.list(style) && !is.null(style$general)) {
    return(.jst_style_object("apa", NA_character_,
                             list(c(list(source = "apa"), style))))
  }
  if (is.null(style)) {
    style <- getOption(".jst_options_style", .jst_options_defaults$style)
  }
  if (!is.character(style) || length(style) != 1L || is.na(style) ||
      !nzchar(trimws(style))) {
    .jst_stop("`style` must be a style name in quotes, for example:\n",
              "  style = \"apa\"", fn = fn)
  }
  .jst_style_load(trimws(style), fn = fn, cl = cl, mc = mc)
}

#' Internal helper: make a style object
#'
#' @param name Character(1); the style's name.
#' @param path Character(1); its file, NA for a built-in.
#' @param layers The layers, read first to last.
#' @param skipped Character; settings a newer jstats wrote, passed over.
#' @keywords internal
.jst_style_object <- function(name, path, layers, skipped = character(0)) {
  structure(list(name = name, path = path, layers = layers,
                 skipped = skipped), class = "jst_style")
}

#' Internal helper: one setting of a style, for one table type
#'
#' The lookup of the reference (Part 3.2), layer by layer: in each, the
#' type's own section, then the general part; the first value found wins.
#' A plain list of parts (the built-in apa list) is read as one layer. A
#' key no layer holds is an internal error: the built-in list is complete.
#'
#' @param style A style object, or a list of parts.
#' @param type Character(1); the table type (the section's name), or
#'   "general".
#' @param key Character(1); the key.
#' @keywords internal
.jst_style_key <- function(style, type, key) {
  layers <- if (inherits(style, "jst_style")) style$layers else list(style)
  for (L in layers) {
    v <- L[[type]][[key]]
    if (!is.null(v)) return(v)
    v <- L$general[[key]]
    if (!is.null(v)) return(v)
  }
  stop(".jst_style_key(): no key '", key, "' for table type '", type, "'",
       call. = FALSE)
}

#' Internal helper: which layer a setting comes from
#'
#' @inheritParams .jst_style_key
#' @return Character(1): the source of the layer that holds it ("apa", a
#'   file's name, "the call").
#' @keywords internal
.jst_style_key_source <- function(style, type, key) {
  for (L in style$layers) {
    if (!is.null(L[[type]][[key]]) || !is.null(L$general[[key]])) return(L$source)
  }
  NA_character_
}

#' Internal helper: the folders a style name is looked for in, in order
#'
#' @return A named character vector: the folder, named by its role
#'   ("style folder", "working directory", "your jstats folder").
#' @keywords internal
.jst_style_dirs <- function() {
  sd <- getOption(".jst_options_style_dir", .jst_options_defaults$style.dir)
  dirs <- c(if (!is.null(sd)) c("the style folder" = sd),
            "the working directory" = getwd(),
            "your jstats folder"    = tools::R_user_dir("jstats", "data"))
  norm <- normalizePath(dirs, winslash = "/", mustWork = FALSE)
  dirs[!duplicated(tolower(norm))]
}

#' Internal helper: the style files the folders hold, by name
#'
#' The first folder that holds a name wins, the letters' case aside, as
#' the lookup reads them.
#'
#' @return A named character vector of paths, named by style.
#' @keywords internal
.jst_style_files <- function() {
  out <- character(0)
  for (d in .jst_style_dirs()) {
    if (!dir.exists(d)) next
    f  <- list.files(d, pattern = "\\.jstyle$", ignore.case = TRUE,
                     full.names = TRUE)
    nm <- sub("\\.jstyle$", "", basename(f), ignore.case = TRUE)
    keep <- !tolower(nm) %in% tolower(c(names(out), names(.jst_style_builtin())))
    keep <- keep & !duplicated(tolower(nm))
    out  <- c(out, stats::setNames(f[keep], nm[keep]))
  }
  out
}

#' Internal helper: load a style by name or path, with its based.on chain
#'
#' @param style Character(1).
#' @param fn,cl,mc As \code{.jst_style_resolve()}.
#' @param seen The files already in the chain, for the loop check.
#' @param from NULL, or where based.on named it: list(file, line, chain).
#' @keywords internal
.jst_style_load <- function(style, fn, cl = NULL, mc = NULL,
                            seen = character(0), from = NULL) {
  builtin <- .jst_style_builtin()
  nm <- sub("\\.jstyle$", "", style, ignore.case = TRUE)
  if (!grepl("[/\\\\]", style) && tolower(nm) %in% names(builtin)) {
    b <- tolower(nm)
    # A file of the built-in's name is passed over; said when the call
    # itself names the built-in, not for each based.on that reaches it.
    if (is.null(from)) {
      note <- .jst_style_shadowed_note(b, .jst_style_shadowed(b))
      if (!is.null(note)) {
        .jst_msg(note)
        cat("\n")
      }
    }
    return(.jst_style_object(b, NA_character_, .jst_style_builtin_layers(b)))
  }
  path <- .jst_style_find(style, fn, cl, mc, from)
  norm <- normalizePath(path, winslash = "/", mustWork = FALSE)
  file <- basename(path)
  if (tolower(norm) %in% tolower(seen)) {
    chain <- c(from$chain, file)
    .jst_stop(chain[1L], " is based on ",
              paste(chain[-1L], collapse = ", which is based on "),
              ".\nA style cannot be based on itself.", fn = fn)
  }
  rd   <- .jst_style_read(path, fn)
  base <- .jst_style_load(rd$based.on, fn, seen = c(seen, norm),
                          from = list(file = file, line = rd$based.on_line,
                                      chain = c(from$chain, file)))
  .jst_style_object(sub("\\.jstyle$", "", file, ignore.case = TRUE), norm,
                    c(list(rd$layer), base$layers),
                    c(rd$skipped, base$skipped))
}

#' Internal helper: the file a style name or path names
#'
#' @inheritParams .jst_style_load
#' @return The path; stops when there is none.
#' @keywords internal
.jst_style_find <- function(style, fn, cl = NULL, mc = NULL, from = NULL) {
  if (grepl("[/\\\\]", style)) {
    path <- style
    if (!grepl("\\.jstyle$", path, ignore.case = TRUE)) {
      if (nzchar(tools::file_ext(basename(path)))) {
        .jst_stop("style = names a file ending in .",
                  tools::file_ext(basename(path)), ", not .jstyle:\n  ", path,
                  fn = fn)
      }
      path <- paste0(path, ".jstyle")
    }
    .jst_check_path_chars(path, what = "path")
    if (!file.exists(path)) .jst_stop("File not found: ", .jst_norm_path(path), fn = fn)
    return(path)
  }
  nm    <- sub("\\.jstyle$", "", style, ignore.case = TRUE)
  files <- .jst_style_files()
  hit   <- match(tolower(nm), tolower(names(files)))
  if (!is.na(hit)) return(unname(files[hit]))

  # Not found: a near name is offered with the call that uses it; else the
  # styles found are named.
  avail <- c(names(.jst_style_builtin()), names(files))
  lead  <- if (is.null(from)) paste0("no style named \"", nm, "\" was found.")
           else paste0("line ", from$line, " of ", from$file, " sets based.on = ",
                       nm, ", and no style of that name was found.")
  dist  <- as.integer(utils::adist(tolower(nm), tolower(avail)))
  near  <- avail[dist <= 2L & dist * 2L < nchar(nm)]
  if (length(near)) {
    near <- near[which.min(dist[match(near, avail)])]
    line <- if (!is.null(cl) && !is.null(mc)) .jst_call_with(cl, mc, "style", near)
    .jst_stop(lead, "\nDid you mean \"", near, "\"?",
              if (!is.null(line)) paste0("\n  ", line), fn = fn)
  }
  .jst_stop(lead, "\nThe styles found are ",
            .jst_and_list(paste0("\"", avail, "\"")), ".\n",
            "jstyle() lists them and the folders searched.", fn = fn)
}

#' Internal helper: read and check one style file
#'
#' Reads every line first, then judges: the stamps and based.on (the
#' general part only); a section or a setting this version does not have
#' -- a near miss of one it has stops with the did-you-mean, one the
#' written.by stamp shows a newer jstats wrote is passed over with a note
#' naming it, any other stops naming both causes and the settings there
#' are; a setting given twice, or a section opened twice, stops; every
#' value is checked against \code{.jst_style_spec} and converted.
#'
#' @param path The file.
#' @param fn The user-facing function's name.
#' @return A list: layer (source, general and the sections), based.on and
#'   its line, skipped (character).
#' @keywords internal
.jst_style_read <- function(path, fn) {
  file <- basename(path)
  txt  <- tryCatch(readLines(path, encoding = "UTF-8", warn = FALSE),
                   error = function(e) {
                     .jst_stop("the style file could not be read:\n  ",
                               .jst_norm_path(path), "\nR reported:\n  ",
                               conditionMessage(e), fn = fn)
                   })
  if (length(txt)) txt[1L] <- sub("^\ufeff", "", txt[1L])
  at <- function(i) paste0("line ", i, " of ", file)

  parts <- list(general = list()); opened <- c(general = 0L)
  section <- "general"
  for (i in seq_along(txt)) {
    s <- trimws(sub("\r$", "", txt[i]))
    if (!nzchar(s) || startsWith(s, "#")) next
    m <- regmatches(s, regexec("^\\[\\s*([^]]*?)\\s*\\]\\s*(#.*)?$", s, perl = TRUE))[[1L]]
    if (length(m)) {
      sec <- tolower(m[2L])
      if (sec %in% names(opened)) {
        .jst_stop(at(i), " opens [", sec, "] again (line ", opened[[sec]],
                  " opened it first).\nPut a section's settings under one heading.",
                  fn = fn)
      }
      section <- sec; opened[[sec]] <- i; parts[[sec]] <- list()
      next
    }
    eq <- regexpr("=", s, fixed = TRUE)
    k  <- if (eq > 1L) tolower(trimws(substr(s, 1L, eq - 1L))) else ""
    if (!grepl("^[a-z][a-z0-9._]*$", k)) {
      .jst_stop(at(i), " is not a setting:\n  ", s, "\n",
                "A setting is a name, an equals sign and a value, for example:\n",
                "  font = Times New Roman", fn = fn)
    }
    if (!is.null(parts[[section]][[k]])) {
      .jst_stop(at(i), " sets ", k, " again (line ", parts[[section]][[k]]$line,
                " set it first).\nSet each setting once in a section.", fn = fn)
    }
    parts[[section]][[k]] <- c(.jst_style_value_text(substr(s, eq + 1L, nchar(s))),
                               list(line = i))
  }

  # The file's own lines: the general part only.
  own <- c("format", "written.by", "based.on")
  for (sec in setdiff(names(parts), "general")) {
    for (k in intersect(own, names(parts[[sec]]))) {
      .jst_stop(at(parts[[sec]][[k]]$line), " sets ", k, " in [", sec, "].\n",
                k, " goes at the top of the file, before the first section.",
                fn = fn)
    }
  }
  g <- parts$general
  if (!is.null(g$format)) {
    f <- suppressWarnings(as.numeric(g$format$text))
    if (is.na(f) || f != round(f) || f < 1) {
      .jst_stop(at(g$format$line), " sets format = ", g$format$raw, ".\n",
                "`format` must be a whole number.", fn = fn)
    }
    if (f > .jst_style_format) {
      .jst_stop(file, " is in style-file format ", f, ", which this version ",
                "of jstats (", .jst_jstats_version(), ") cannot read.\n",
                "Update jstats with jupdate().", fn = fn)
    }
  }
  wb_ver <- if (is.null(g$written.by)) NA_character_ else
    regmatches(g$written.by$text, regexpr("[0-9]+(\\.[0-9]+)+", g$written.by$text))
  if (!length(wb_ver)) wb_ver <- NA_character_
  newer <- !is.na(wb_ver) && .jst_version_newer(wb_ver, .jst_jstats_version())

  skipped <- character(0)
  # Sections this version does not have.
  types <- names(.jst_style_type_nouns)
  for (sec in setdiff(names(parts), c("general", types))) {
    ln   <- opened[[sec]]
    near <- .jst_style_near(sec, types)
    if (length(near)) {
      .jst_stop(at(ln), " opens [", sec, "], which is not a section of a ",
                "style.\nDid you mean [", near, "]?",
                .jst_style_newer_line(newer, file, wb_ver), fn = fn)
    }
    if (newer) { skipped <- c(skipped, stats::setNames(paste0("[", sec, "]"), ln)); next }
    .jst_stop(at(ln), " opens [", sec, "], which is not a section jstats has.\n",
              "It may be misspelled, or it may be from a newer version of ",
              "jstats (update with jupdate()).\n",
              "The sections are ", .jst_and_list(paste0("[", types, "]")), ".",
              fn = fn)
  }
  # Settings this version does not have, then every value.
  layer <- list(source = file)
  for (sec in intersect(names(parts), c("general", types))) {
    allowed <- if (identical(sec, "general")) c(names(.jst_style_spec$general), own)
               else c(names(.jst_style_spec[[sec]]), names(.jst_style_spec$general))
    vals <- list()
    for (k in names(parts[[sec]])) {
      it <- parts[[sec]][[k]]
      if (!k %in% allowed) {
        near <- .jst_style_near(k, allowed)
        if (length(near)) {
          .jst_stop(at(it$line), " sets ", k, ", which is not a setting ",
                    if (identical(sec, "general")) "of a style"
                    else paste0("of [", sec, "]"), ".\nDid you mean ", near, "?",
                    .jst_style_newer_line(newer, file, wb_ver), fn = fn)
        }
        if (newer) {
          skipped <- c(skipped, stats::setNames(if (identical(sec, "general")) k
                                                else paste0("[", sec, "] ", k),
                                                it$line))
          next
        }
        .jst_stop(at(it$line), " sets ", k, ", which is not a setting jstats has.\n",
                  "It may be misspelled, or it may be from a newer version of ",
                  "jstats (update with jupdate()).\n",
                  .jst_style_settings_line(sec), fn = fn)
      }
      if (k %in% own) next
      sp <- if (k %in% names(.jst_style_spec$general) &&
                !k %in% names(.jst_style_spec[[sec]])) .jst_style_spec$general[[k]]
            else .jst_style_spec[[sec]][[k]]
      vals[[k]] <- .jst_style_check_value(k, sp, it, sec, fn,
                                          where = paste0(at(it$line), " sets ",
                                                         k, " = ", it$raw,
                                                         if (!grepl("[.]$", it$raw)) "."))
    }
    layer[[sec]] <- vals
  }
  if (length(skipped)) {
    skipped <- unname(skipped[order(as.integer(names(skipped)))])
    .jst_msg(file, " was written by jstats ", wb_ver, ", and this is jstats ",
             .jst_jstats_version(), ".\n",
             "These settings are from the newer version and were skipped: ",
             paste(skipped, collapse = ", "), ".\n",
             "Update jstats with jupdate() to use them.")
  }
  list(layer = layer,
       based.on = if (is.null(g$based.on) || !nzchar(g$based.on$text)) "apa"
                  else g$based.on$text,
       based.on_line = if (is.null(g$based.on)) NA_integer_ else g$based.on$line,
       skipped = skipped)
}

# The style-file format this version reads and writes.
.jst_style_format <- 1L

#' Internal helper: is one version newer than another?
#' @param a,b Character versions; "unknown" is never newer or older.
#' @keywords internal
.jst_version_newer <- function(a, b) {
  pa <- tryCatch(package_version(a), error = function(e) NULL)
  pb <- tryCatch(package_version(b), error = function(e) NULL)
  !is.null(pa) && !is.null(pb) && pa > pb
}

#' Internal helper: the near miss of a section or setting name
#'
#' The test \code{.jst_near_choice_hint()} uses: at most two edits, and
#' fewer than half the typed name's letters.
#'
#' @param typed Character(1).
#' @param known Character; the names there are.
#' @return The nearest name, or character(0).
#' @keywords internal
.jst_style_near <- function(typed, known) {
  d <- as.integer(utils::adist(tolower(typed), known))
  ok <- d <= 2L & d * 2L < nchar(typed)
  if (!any(ok)) return(character(0))
  known[ok][which.min(d[ok])]
}

#' Internal helper: the line a near miss adds for a newer file
#'
#' When a style file was written by a newer jstats, a name that is
#' close to a known one may still be a newer setting; the stop says so.
#' @param newer Logical(1); the file comes from a newer jstats.
#' @param file Character(1); the file's name, as messages give it.
#' @param ver Character(1); the version that wrote the file.
#' @return Character(1) starting with a newline, or NULL.
#' @keywords internal
.jst_style_newer_line <- function(newer, file, ver) {
  if (!newer) return(NULL)
  paste0("\n", file, " was written by jstats ", ver, ", newer than this ",
         "version; if it is a newer setting, update jstats with jupdate().")
}

#' Internal helper: the settings one part of a style file takes
#'
#' For the stop on a setting the part does not have.
#' @param sec Character(1); "general" or a table type.
#' @return Character(1).
#' @keywords internal
.jst_style_settings_line <- function(sec) {
  if (identical(sec, "general")) {
    paste0("The general settings are ",
           .jst_and_list(names(.jst_style_spec$general)), ".")
  } else {
    paste0("The settings of [", sec, "] are ",
           .jst_and_list(names(.jst_style_spec[[sec]])), ".\n",
           "A general setting may be set there too.")
  }
}

#' Internal helper: a value's text in a style file
#'
#' The text after the equals sign: a value in double or single quotes is
#' read as quoted (a # inside it is text); a color written with its # --
#' #1F3864 -- keeps it; otherwise a # at the start or after a space opens
#' a comment.
#'
#' @param v Character(1).
#' @return A list: text (the value), raw (the value as written, the
#'   comment removed) and quoted (logical).
#' @keywords internal
.jst_style_value_text <- function(v) {
  v <- trimws(v)
  q <- substr(v, 1L, 1L)
  if (q %in% c("\"", "'") && nchar(v) >= 2L) {
    close <- regexpr(q, substr(v, 2L, nchar(v)), fixed = TRUE)
    if (close > 0L) {
      rest <- trimws(substr(v, close + 2L, nchar(v)))
      if (!nzchar(rest) || startsWith(rest, "#")) {
        return(list(text = substr(v, 2L, close), raw = substr(v, 1L, close + 1L),
                    quoted = TRUE))
      }
    }
  }
  hex <- regmatches(v, regexec("^(#[0-9A-Fa-f]{6})(\\s+#.*|\\s*)$", v))[[1L]]
  if (length(hex)) return(list(text = hex[2L], raw = hex[2L], quoted = FALSE))
  cm <- regexpr("(^|\\s)#", v)
  if (cm > 0L) v <- substr(v, 1L, cm - 1L)
  v <- trimws(v)
  list(text = v, raw = v, quoted = FALSE)
}

#' Internal helper: check and convert one style value
#'
#' The same checks for a file's value (its text) and a call's (an R
#' value). A wrong value stops with what the setting takes, after the
#' line that set it when it came from a file.
#'
#' @param key The setting's name.
#' @param sp Its entry in \code{.jst_style_spec}.
#' @param val A file's value (a list from \code{.jst_style_value_text()}),
#'   or a call's R value.
#' @param type The part it is in, for the columns a table type has.
#' @param fn The user-facing function's name.
#' @param where For a file's value, the sentence naming the line; NULL for
#'   a call's.
#' @return The value converted: text, a lowercase choice, a number, a hex
#'   color (or "none"), a vector of column keys, the stars' thresholds.
#' @keywords internal
.jst_style_check_value <- function(key, sp, val, type, fn, where = NULL) {
  from_file <- !is.null(where)
  bad <- function(req) {
    .jst_stop(if (from_file) paste0(where, "\n"), "`", key, "` must be ",
              req, fn = fn)
  }
  one <- function() {
    if (from_file) return(val$text)
    if (is.numeric(val) && length(val) == 1L && !is.na(val) &&
        sp$kind %in% c("number", "integer")) return(as.character(val))
    if (!is.character(val) || length(val) != 1L || is.na(val)) {
      bad(switch(sp$kind,
                 number  = paste0("a number from ", sp$min, " to ", sp$max, "."),
                 integer = paste0("a whole number from ", sp$min, " to ", sp$max, "."),
                 choice  = .jst_choice_list(sp$choices),
                 "text in quotes."))
    }
    val
  }
  items <- function() {
    if (from_file) {
      x <- strsplit(val$raw, ",", fixed = TRUE)[[1L]]
      return(gsub("^[\"']|[\"']$", "", trimws(x)))
    }
    if (is.numeric(val) && sp$kind == "stars") return(as.character(val))
    if (!is.character(val) || anyNA(val)) {
      bad(if (sp$kind == "stars") "one to three p-values between 0 and 1."
          else .jst_style_columns_req(sp$cols, type))
    }
    trimws(val)
  }
  switch(sp$kind,
    text = {
      s <- one()
      if (!isTRUE(sp$empty) && !nzchar(trimws(s))) bad("text, not empty.")
      s
    },
    choice = {
      s <- tolower(trimws(one()))
      if (!s %in% sp$choices) bad(.jst_choice_list(sp$choices))
      s
    },
    number = , integer = {
      x <- suppressWarnings(as.numeric(trimws(one())))
      whole <- identical(sp$kind, "integer")
      if (is.na(x) || x < sp$min || x > sp$max || (whole && x != round(x))) {
        bad(paste0(if (whole) "a whole number" else "a number", " from ",
                   sp$min, " to ", sp$max, "."))
      }
      x
    },
    color = {
      s <- trimws(one())
      if (isTRUE(sp$none) && identical(tolower(s), "none")) return("none")
      # "header" (caption.fill, Session 409): the header's fill and text color,
      # so a file names its color once.
      if (isTRUE(sp$header) && identical(tolower(s), "header")) return("header")
      if (grepl("^#?[0-9A-Fa-f]{6}$", s)) return(toupper(sub("^#", "", s)))
      if (tolower(s) %in% grDevices::colors()) {
        rgb <- grDevices::col2rgb(tolower(s))
        return(sprintf("%02X%02X%02X", rgb[1L], rgb[2L], rgb[3L]))
      }
      bad(if (isTRUE(sp$header)) {
        paste0("\"none\", \"header\", a color name such as \"navy\", or six hex ",
               "digits such as \"1F3864\".")
      } else if (isTRUE(sp$none)) {
        "\"none\", a color name such as \"navy\", or six hex digits such as \"1F3864\"."
      } else {
        "a color name such as \"navy\" or six hex digits such as \"1F3864\"."
      })
    },
    columns = {
      x <- tolower(items())
      # "none" where the setting allows it (columns.last, fit.rows): no
      # columns, kept as the word so a file writes it back as given.
      if (isTRUE(sp$none) && length(x) == 1L && identical(x, "none")) return("none")
      if (!length(x) || any(!nzchar(x)) || any(!x %in% sp$cols) || anyDuplicated(x)) {
        bad(.jst_style_columns_req(sp$cols, type, none = isTRUE(sp$none)))
      }
      x
    },
    stars = {
      x <- suppressWarnings(as.numeric(items()))
      if (!length(x) || length(x) > 3L || anyNA(x) || any(x <= 0 | x >= 1) ||
          anyDuplicated(x)) {
        bad("one to three p-values between 0 and 1, for example .05, .01, .001.")
      }
      sort(x, decreasing = TRUE)
    }
  )
}

#' Internal helper: what columns = takes for one table type
#'
#' @param cols Character; the column keys the type knows.
#' @param type Character(1) or NULL; the table type.
#' @param none Logical; TRUE when "none" is a value too (columns.last,
#'   fit.rows).
#' @return Character(1), the requirement a stop names.
#' @keywords internal
.jst_style_columns_req <- function(cols, type, none = FALSE) {
  noun <- if (!is.null(type) && type %in% names(.jst_style_type_nouns))
            .jst_style_type_nouns[[type]] else "the table"
  lst <- .jst_choice_list(cols)
  if (none) lst <- paste0(sub("\\.$", "", lst), "; or \"none\".")
  paste0("columns of ", noun, ", each named once: ", lst)
}


# -----------------------------------------------------------------------------
# 2. Number formats in tables
# -----------------------------------------------------------------------------
#
# The console's rules (the Package Rules Reference, "Number format") do not
# reach a table: these formats take the STYLE's decimals, leading zero,
# thousands separator and minus sign (ruling R47), so the preview and the
# Word file print the same cell. What they keep from the console: a value
# that rounds to zero from below prints unsigned, NA is a blank cell, and
# -Inf keeps its sign (.jst_make_fmt()).

#' Internal helper: format a number for a table cell
#'
#' @param x Numeric vector.
#' @param decimals Integer; the decimal places.
#' @param thousands "comma" or "none".
#' @param leading.zero Logical; FALSE drops the zero before the point of a
#'   value between -1 and 1 (".23", "-.12").
#' @param minus "true" for the minus sign (U+2212), "hyphen" for the
#'   hyphen-minus.
#' @return Character vector; NA is "".
#' @keywords internal
.jst_tbl_num <- function(x, decimals = 2L, thousands = "comma",
                         leading.zero = TRUE, minus = "true") {
  x <- suppressWarnings(as.numeric(x))
  s <- .jst_make_fmt(decimals)(x)
  if (identical(thousands, "comma")) {
    # The whole-number part gets its separators; the fraction is untouched.
    whole <- sub("^(-?)([0-9]+).*$", "\\2", s)
    rest  <- sub("^-?[0-9]+", "", s)
    sign  <- ifelse(startsWith(s, "-"), "-", "")
    has   <- grepl("^-?[0-9]+", s)
    whole_sep <- vapply(whole, function(w) {
      if (!grepl("^[0-9]+$", w)) return(w)
      formatC(as.numeric(w), format = "f", digits = 0, big.mark = ",")
    }, character(1), USE.NAMES = FALSE)
    s <- ifelse(has, paste0(sign, whole_sep, rest), s)
  }
  if (!isTRUE(leading.zero)) s <- sub("^(-?)0\\.", "\\1.", s)
  if (identical(minus, "true")) s <- sub("^-", "\u2212", s)
  s
}

#' Internal helper: whether a number keeps the zero before its point
#'
#' The style's leading.zero setting, read for one kind of number: yes
#' keeps the zero on every number; no drops it on a statistic that cannot
#' exceed 1 (p, beta, r, R2 -- APA's rule) and keeps it on any other (b,
#' SE, a mean); never drops it on every number below 1 (".197" for an SE;
#' Session 402, item 5).
#'
#' @param setting The leading.zero value.
#' @param bounded Logical; TRUE for a statistic bounded by 1.
#' @return Logical(1).
#' @keywords internal
.jst_tbl_lz <- function(setting, bounded = FALSE) {
  switch(as.character(setting), yes = TRUE, never = FALSE, no = !bounded, TRUE)
}

#' Internal helper: format a coefficient, with a near-zero value kept visible
#'
#' As \code{.jst_tbl_num()}, except that a value that rounds to zero at
#' the decimals but is not zero prints with enough places to show its
#' first digit, as APA's Table 7.17 prints .0002 (Session 402, item 6): a
#' b of -0.00129 at two decimals prints -0.001, where "0.00" would
#' misreport the coefficient's sign and size. For b, SE and a confidence
#' limit, which depend on the predictor's units; a standardized
#' coefficient keeps the decimals.
#'
#' @inheritParams .jst_tbl_num
#' @keywords internal
.jst_tbl_coef <- function(x, decimals = 2L, thousands = "comma",
                          leading.zero = TRUE, minus = "true") {
  x  <- suppressWarnings(as.numeric(x))
  dp <- vapply(x, function(v) {
    if (is.na(v) || !is.finite(v) || v == 0 || round(v, decimals) != 0) {
      return(as.integer(decimals))
    }
    as.integer(min(6L, max(decimals, -floor(log10(abs(v))))))
  }, integer(1))
  vapply(seq_along(x), function(i) {
    .jst_tbl_num(x[i], dp[i], thousands, leading.zero, minus)
  }, character(1))
}

#' Internal helper: format a count for a table cell or a note
#'
#' @param n Numeric vector of counts.
#' @param thousands "comma" or "none".
#' @keywords internal
.jst_tbl_count <- function(n, thousands = "comma") {
  n <- suppressWarnings(as.numeric(n))
  ifelse(is.na(n), "",
         if (identical(thousands, "comma")) .jst_fmt_n(n)
         else formatC(n, format = "d"))
}

#' Internal helper: format a p-value for a table cell
#'
#' Exact to \code{decimals} places with the floor "<.001" (at 3 places;
#' "<.01" at 2), the leading zero dropped as APA writes p (kept under
#' leading.zero = yes, Session 403); or stars alone; or both, the stars
#' after the value. NA is a blank cell.
#'
#' @param p Numeric vector.
#' @param format "exact", "stars" or "both".
#' @param decimals Integer.
#' @param stars The thresholds, largest first.
#' @param leading.zero Logical; TRUE keeps the zero before the point.
#' @keywords internal
.jst_tbl_p <- function(p, format = "exact", decimals = 3L,
                       stars = c(0.05, 0.01, 0.001), leading.zero = FALSE) {
  p <- suppressWarnings(as.numeric(p))
  floor_v <- 10^(-decimals)
  lz <- function(s) if (isTRUE(leading.zero)) s else sub("^0\\.", ".", s)
  exact <- ifelse(is.na(p), "",
                  ifelse(p < floor_v,
                         paste0("<", lz(sprintf(paste0("%.", decimals, "f"), floor_v))),
                         lz(sprintf(paste0("%.", decimals, "f"), p))))
  st <- .jst_tbl_stars(p, stars)
  switch(format,
         exact = exact,
         stars = ifelse(is.na(p), "", st),
         both  = ifelse(is.na(p), "", paste0(exact, st)),
         exact)
}

#' Internal helper: the stars a p-value earns
#'
#' @param p Numeric vector.
#' @param stars The thresholds, largest first; one star per threshold
#'   passed.
#' @return Character vector; "" for none or NA.
#' @keywords internal
.jst_tbl_stars <- function(p, stars = c(0.05, 0.01, 0.001)) {
  p  <- suppressWarnings(as.numeric(p))
  st <- sort(as.numeric(stars), decreasing = TRUE)
  vapply(p, function(v) {
    if (is.na(v)) return("")
    strrep("*", sum(v < st))
  }, character(1))
}

#' Internal helper: the probability note the stars key makes
#'
#' Generated from the thresholds, so it can never disagree with the cells:
#' "*p < .05. **p < .01. ***p < .001." The p is set in italics by the Word
#' writer, which reads the marker.
#'
#' @param stars The thresholds.
#' @param leading.zero The style's leading.zero setting: p is a statistic
#'   bounded by 1, so its zero is kept only under "yes", as in the cells
#'   (Session 409: until then the legend dropped it under every setting,
#'   "*p < .05" beneath cells reading 0.003).
#' @return Character(1).
#' @keywords internal
.jst_tbl_stars_legend <- function(stars = c(0.05, 0.01, 0.001), leading.zero = "no") {
  st <- sort(as.numeric(stars), decreasing = TRUE)
  keep <- .jst_tbl_lz(leading.zero, bounded = TRUE)
  paste(vapply(seq_along(st), function(i) {
    v <- format(st[i])
    paste0(strrep("*", i), "*p* < ", if (keep) v else sub("^0", "", v), ".")
  }, character(1)), collapse = " ")
}

#' Internal helper: the glyph of the i-th specific-note mark
#'
#' @param i Integer; the mark's position.
#' @param marks "letters" (a, b, c, ...) or "symbols" (dagger, double
#'   dagger, section sign, then doubled).
#' @keywords internal
.jst_tbl_mark <- function(i, marks = "letters") {
  if (identical(marks, "symbols")) {
    base <- c("\u2020", "\u2021", "\u00a7")
    return(strrep(base[(i - 1L) %% 3L + 1L], (i - 1L) %/% 3L + 1L))
  }
  letters[(i - 1L) %% 26L + 1L]
}


# -----------------------------------------------------------------------------
# 3. The table structure
# -----------------------------------------------------------------------------

#' Internal helper: a table structure
#'
#' The neutral form every writer renders (the reference, Part 2.1).
#'
#' @param type Character(1); the table type, the style section's name.
#' @param columns A data frame, one row per column: key, label, kind
#'   ("text" or "number"), italic (logical). The first column is the stub.
#' @param rows A list; each row a list with kind ("data" or "heading"),
#'   label, indent (0 or 1), marks (character; the specific-note marks the
#'   label carries), cells (a named list of formatted strings, by column
#'   key; a heading has none) and raw (the numbers the cells were made
#'   from).
#' @param caption A list: number (NA until a document assigns one) and
#'   title.
#' @param notes A list: general (character; one string per sentence),
#'   specific (a list of mark/text pairs) and probability (character).
#' @param spanners A list of heading spanners (label, from, to: column
#'   positions), or NULL.
#' @param style The style name the table was built under.
#' @return An object of class "jst_table".
#' @keywords internal
.jst_table_new <- function(type, columns, rows, caption, notes,
                           spanners = NULL, style = "apa") {
  structure(list(type = type, columns = columns, rows = rows,
                 caption = caption, notes = notes, spanners = spanners,
                 style = style),
            class = "jst_table")
}


# -----------------------------------------------------------------------------
# 4. The descriptives builder (jdesc() results)
# -----------------------------------------------------------------------------

#' Internal generic: build a table structure from a saved result
#'
#' One method per result class. A class with no method stops in jtable()'s
#' words: the table types come one build at a time.
#'
#' @param x The saved result.
#' @param style The style list.
#' @param headings A named list: each heading's variables (or NULL).
#' @param markers A named list: each specific note's variables (or NULL).
#' @param title The user's title, or NULL for the type's template.
#' @param note The user's general note, or NULL.
#' @param ... Unused.
#' @keywords internal
.jst_table_build <- function(x, style, headings = NULL, markers = NULL,
                             title = NULL, note = NULL, ...) {
  UseMethod(".jst_table_build")
}

# A class with no builder stops in jtable()'s words (Session 405: every
# class an analysis function returns has one, so only an object of some
# other class reaches this).
.jst_table_build.default <- function(x, style, ...) {
  fn <- .jst_table_result_fn(x)
  .jst_stop("no table is made from ",
            if (is.na(fn)) "this kind of result" else paste0("a ", fn, " result"),
            " yet.\nTables are made from jdesc(), jfreq(), jcorr(), jt(), ",
            "jaov(), jcrosstab(), jalpha(), jlm(), and jlogistic() results.",
            fn = "jtable")
}

#' Internal helper: the analysis function that made a result
#'
#' @param x A result, or anything.
#' @return Character(1): "jfreq()", "jlm()", ...; NA for an object of no
#'   result class.
#' @keywords internal
.jst_table_result_fn <- function(x) {
  map <- c(jst_lm = "jlm()", jst_logistic = "jlogistic()", jst_freq = "jfreq()",
           jst_desc = "jdesc()", jst_corr = "jcorr()", jst_ttest = "jt()",
           jst_anova = "jaov()", jst_crosstab = "jcrosstab()",
           jst_alpha = "jalpha()")
  hit <- intersect(class(x), names(map))
  if (length(hit)) unname(map[hit[1L]]) else NA_character_
}

# A jdesc() result: one result, built as a list of one.
.jst_table_build.jst_desc <- function(x, style, headings = NULL,
                                      markers = NULL, title = NULL,
                                      note = NULL, ...) {
  .jst_table_build_desc(list(x), style, headings, markers, title, note)
}

#' Internal helper: the descriptives table from one or more jdesc() results
#'
#' Rows from \code{.jst_apa_terms()} on each result in turn, so several
#' results stack into one table. Role headings come from \code{headings}
#' (a named list of variables) or from the names of a list of results;
#' under a heading its variables are indented. The columns are the style's
#' descriptives columns; a mean and an SD take the style's decimals, a
#' minimum and a maximum the places the data carry (they are values of the
#' variable, not statistics), n is a count. The general note opens on N
#' (the cases in the pool) when note.n is yes, then carries the user's
#' text; each specific note's mark is assigned by the style (letters or
#' symbols) and set on its rows' labels.
#'
#' @param results A list of jst_desc results; names are headings.
#' @inheritParams .jst_table_build
#' @return A jst_table.
#' @keywords internal
.jst_table_build_desc <- function(results, style, headings = NULL,
                                  markers = NULL, title = NULL,
                                  note = NULL) {
  type <- "descriptives"
  key  <- function(k) .jst_style_key(style, type, k)
  dec  <- key("decimals"); thou <- key("thousands"); minus <- key("minus")
  lz   <- .jst_tbl_lz(key("leading.zero"))

  # One frame of terms, each variable with the heading its result's name
  # gives it (a list of results), carried into the heading rows below.
  frames <- lapply(seq_along(results), function(i) {
    r  <- results[[i]]
    tf <- .jst_apa_terms(r)
    if (is.null(tf)) .jst_table_old_stop(r, "jdesc()")
    if (!is.null(attr(tf, "by"))) {
      .jst_stop("no table is made from a grouped jdesc() result (one made ",
                "with by =) yet.", fn = "jtable")
    }
    tf$heading <- if (!is.null(names(results)) && nzchar(names(results)[i]))
                    names(results)[i] else NA_character_
    tf$n_pool  <- r$sample_info$n_analysis
    tf
  })
  tf <- do.call(rbind, frames)
  rownames(tf) <- NULL
  vars <- tf$variable
  .jst_table_once(vars)

  # headings = and markers = (one home for both table types).
  roles <- .jst_table_roles(vars, tf$heading, headings, markers, key("marks"))
  tf <- tf[roles$order, , drop = FALSE]
  tf$heading <- roles$heading
  mark_of  <- roles$marks
  specific <- roles$specific

  # The columns: the stub, then the style's columns with their labels.
  col_keys <- key("columns")
  col_labs <- vapply(col_keys, function(k) key(paste0(k, ".label")), character(1),
                     USE.NAMES = FALSE)
  columns <- data.frame(
    key    = c("stub", col_keys),
    label  = c(key("stub.label"), col_labs),
    kind   = c("text", rep("number", length(col_keys))),
    italic = c(FALSE, .jst_tbl_head_italic(type, col_keys, col_labs)),
    stringsAsFactors = FALSE, row.names = NULL)

  # The rows: a heading row where the heading changes, each variable's
  # data row under it (indented when it has a heading).
  rows <- list(); last_h <- NA_character_
  for (i in seq_len(nrow(tf))) {
    h <- tf$heading[i]
    if (!is.na(h) && !identical(h, last_h)) {
      rows[[length(rows) + 1L]] <- list(kind = "heading", label = h,
                                        indent = 0L, marks = character(0),
                                        cells = list(), raw = list())
      last_h <- h
    }
    raw <- list(n = tf$n_valid[i], mean = tf$mean[i], sd = tf$sd[i],
                min = tf$min[i], max = tf$max[i])
    mm_dp <- min(.jst_data_dp(c(tf$min[i], tf$max[i])), dec)
    cells <- list(
      n    = .jst_tbl_count(raw$n, thou),
      mean = .jst_tbl_num(raw$mean, dec, thou, lz, minus),
      sd   = .jst_tbl_num(raw$sd, dec, thou, lz, minus),
      min  = .jst_tbl_num(raw$min, mm_dp, thou, lz, minus),
      max  = .jst_tbl_num(raw$max, mm_dp, thou, lz, minus))
    rows[[length(rows) + 1L]] <- list(
      kind = "data", label = tf$var_label[i],
      indent = if (is.na(h)) 0L else 1L,
      marks = if (is.null(mark_of[[tf$variable[i]]])) character(0)
              else mark_of[[tf$variable[i]]],
      cells = cells[col_keys], raw = raw[col_keys])
  }

  # The notes: general (N where the style puts it, the filter, then the
  # user's text), specific, probability (none in a descriptives table). N
  # is written only when every variable comes from one pool of cases.
  pools <- unique(tf$n_pool)
  np <- .jst_table_n_parts(key("n.position"),
                           if (length(pools) == 1L && !is.na(pools))
                             paste0("*N* = ", .jst_tbl_count(pools, thou)))
  general <- c(np$note, .jst_table_filter_note(
    results, vapply(frames, function(f) .jst_and_list(f$var_label), character(1)),
    style, type))
  if (!is.null(note)) general <- c(general, note)

  .jst_table_new(
    type     = type,
    columns  = columns,
    rows     = rows,
    caption  = list(number = NA_integer_,
                    title  = paste0(if (is.null(title)) key("title") else title,
                                    np$title)),
    notes    = list(general = general, specific = specific,
                    probability = character(0)),
    style    = style)
}

#' Internal helper: where a table's N goes (ruling R51)
#'
#' n.position = note opens the general note on N; title adds "(N = 103)"
#' after the title, the call's own included; none writes no N. A table
#' with no one N to write (variables from different pools of cases) gets
#' nothing under any setting. The text is marked up for the writers (*N*
#' italic).
#'
#' @param setting The n.position value.
#' @param n_text NULL, or the sentence's body: "*N* = 103", or the
#'   models' form when their Ns differ.
#' @param title_text The text for the title's parenthesis; the same by
#'   default (shorter for models whose Ns differ).
#' @return A list: note (character(0) or the sentence) and title ("" or
#'   the parenthesis to append).
#' @keywords internal
.jst_table_n_parts <- function(setting, n_text, title_text = n_text) {
  if (is.null(n_text) || identical(setting, "none")) {
    return(list(note = character(0), title = ""))
  }
  if (identical(setting, "title")) {
    return(list(note = character(0), title = paste0(" (", title_text, ")")))
  }
  list(note = paste0(n_text, "."), title = "")
}

#' Internal helper: a table lists each variable once
#'
#' Two results that hold the same variable would put it in the table
#' twice, and headings = and markers = could not say which row they mean.
#'
#' @param vars Character; the variables, in the order of the results.
#' @keywords internal
.jst_table_once <- function(vars) {
  dup <- unique(vars[duplicated(vars)])
  if (length(dup)) {
    .jst_stop(.jst_and_list(dup), if (length(dup) == 1L) " is" else " are",
              " in more than one of the results.\n",
              "A table lists each variable once.", fn = "jtable")
  }
  invisible(NULL)
}

#' Internal helper: the headings and the specific-note marks of a table
#'
#' One home for headings = and markers = in every table type. headings =
#' partitions the variables -- every variable under one heading, in the
#' headings' order, a name given twice or not in the results refused, a
#' variable left out refused -- and replaces the headings a named list of
#' results gives. markers = assigns each specific note a mark in the
#' style's glyphs, in the order given; a variable may carry several marks,
#' one per note.
#'
#' @param vars Character; the variables, in the results' order.
#' @param heading Character, one per variable; the heading a named list of
#'   results gives it, or NA.
#' @param headings,markers The named lists jtable() read, or NULL.
#' @param marks The style's marks key ("letters" or "symbols").
#' @return A list: order (integer; the variables' new order), heading
#'   (character; each variable's heading in that order), marks (a named
#'   list, by variable: the marks its label carries) and specific (a list
#'   of mark/text pairs).
#' @keywords internal
.jst_table_roles <- function(vars, heading, headings, markers, marks) {
  ord <- seq_along(vars)
  if (!is.null(headings)) {
    named <- unlist(headings, use.names = FALSE)
    .jst_table_check_names(named, vars, "headings")
    left_out <- setdiff(vars, named)
    if (length(left_out)) {
      .jst_stop("headings = leaves out ", .jst_and_list(left_out), ".\n",
                "Name every variable of the result under a heading, or ",
                "leave headings = out.", fn = "jtable")
    }
    ord <- unlist(lapply(names(headings), function(h) {
      idx <- match(headings[[h]], vars)
      heading[idx] <<- h
      idx
    }))
  }
  mark_of  <- stats::setNames(vector("list", length(vars)), vars)
  specific <- list()
  if (!is.null(markers)) {
    # A variable may carry several marks, one per note; a name repeated
    # within one note is the error.
    .jst_table_check_names(unique(unlist(markers, use.names = FALSE)), vars, "markers")
    for (g in markers) .jst_table_check_names(g, vars, "markers")
    for (i in seq_along(markers)) {
      g <- .jst_tbl_mark(i, marks)
      specific[[i]] <- list(mark = g, text = names(markers)[i])
      for (v in markers[[i]]) mark_of[[v]] <- c(mark_of[[v]], g)
    }
  }
  list(order = ord, heading = heading[ord], marks = mark_of,
       specific = specific)
}


# -----------------------------------------------------------------------------
# 4b. The frequencies builder (jfreq() results; build 2)
# -----------------------------------------------------------------------------

# A jfreq() result: one result, built as a list of one.
.jst_table_build.jst_freq <- function(x, style, headings = NULL,
                                      markers = NULL, title = NULL,
                                      note = NULL, ...) {
  .jst_table_build_freq(list(x), style, headings, markers, title, note)
}

#' Internal helper: the frequency table from one or more jfreq() results
#'
#' Jeff's Table 2: each variable's label on a row of its own, its
#' categories indented under it, then the style's frequencies columns --
#' n and the percentage of all cases under apa. A variable with missing
#' data closes on rows the missing.rows key chooses: combined, one Missing
#' row, so each variable's rows add up to N and to 100 percent; each, a row
#' per missing value by its label (its code where it has none; the label
#' key's word for the cells left empty); none, no row. A category is named
#' by its value label, or by its code where it has none, never by the
#' printed string. Several results stack into one table; headings = and a
#' named list of results put the variables under role headings, and
#' markers = marks a variable's label row, as in the descriptives table.
#' The general note opens on N when every variable comes from one pool of
#' cases.
#'
#' @param results A list of jst_freq results; names are headings.
#' @inheritParams .jst_table_build
#' @return A jst_table.
#' @keywords internal
.jst_table_build_freq <- function(results, style, headings = NULL,
                                  markers = NULL, title = NULL,
                                  note = NULL) {
  type  <- "frequencies"
  key   <- function(k) .jst_style_key(style, type, k)
  thou  <- key("thousands"); minus <- key("minus")
  pdec  <- key("percent.decimals"); mrows <- key("missing.rows")
  lz    <- .jst_tbl_lz(key("leading.zero"))
  pct   <- function(x) .jst_tbl_num(x, pdec, thou, lz, minus)

  # One block per variable: its rows (the accessor), its counts (the
  # model-level accessor), the heading its result's name gives it.
  blocks <- list()
  for (i in seq_along(results)) {
    r <- results[[i]]
    tf <- .jst_apa_terms(r); md <- .jst_apa_model(r)
    if (is.null(attr(r, "jstats_version", exact = TRUE)) || is.null(tf) ||
        is.null(md)) {
      .jst_table_old_stop(r, "jfreq()")
    }
    h <- if (!is.null(names(results)) && nzchar(names(results)[i]))
           names(results)[i] else NA_character_
    for (j in seq_len(nrow(md))) {
      v <- md$variable[j]
      blocks[[length(blocks) + 1L]] <- list(
        variable  = v,
        var_label = md$var_label[j],
        n_total   = md$n_total[j],
        rows      = tf[tf$variable == v, , drop = FALSE],
        heading   = h)
    }
  }
  vars <- vapply(blocks, function(b) b$variable, character(1))
  .jst_table_once(vars)
  roles  <- .jst_table_roles(vars,
                             vapply(blocks, function(b) b$heading, character(1)),
                             headings, markers, key("marks"))
  blocks <- blocks[roles$order]
  for (b in seq_along(blocks)) blocks[[b]]$heading <- roles$heading[b]

  # The columns: the stub, then the style's columns with their labels.
  col_keys <- key("columns")
  col_labs <- vapply(col_keys, function(k) key(paste0(k, ".label")), character(1),
                     USE.NAMES = FALSE)
  columns <- data.frame(
    key    = c("stub", col_keys),
    label  = c(key("stub.label"), col_labs),
    kind   = c("text", rep("number", length(col_keys))),
    italic = c(FALSE, .jst_tbl_head_italic(type, col_keys, col_labs)),
    stringsAsFactors = FALSE, row.names = NULL)

  # A category's name: its value label, else its code; a declared range,
  # which has neither, the missing label. Named a block at a time, so a
  # label two codes share shows each code (Session 407).
  cat_names <- function(code, label) {
    out <- .jst_table_cat_names(code, label)
    out[is.na(out)] <- key("missing.label")
    out
  }
  data_row <- function(label, indent, raw) {
    cells <- list(n             = .jst_tbl_count(raw$n, thou),
                  percent       = pct(raw$percent),
                  valid.percent = pct(raw$valid.percent),
                  cumulative    = pct(raw$cumulative))
    list(kind = "data", label = label, indent = indent, marks = character(0),
         cells = cells[col_keys], raw = raw[col_keys])
  }

  rows <- list(); last_h <- NA_character_
  for (b in blocks) {
    h <- b$heading
    if (!is.na(h) && !identical(h, last_h)) {
      rows[[length(rows) + 1L]] <- list(kind = "heading", level = "group",
                                        label = h, indent = 0L,
                                        marks = character(0),
                                        cells = list(), raw = list())
      last_h <- h
    }
    base <- if (is.na(h)) 0L else 1L
    # The variable's label, a row of its own; its marks on it.
    rows[[length(rows) + 1L]] <- list(
      kind = "heading", level = "variable", label = b$var_label,
      indent = base,
      marks = if (is.null(roles$marks[[b$variable]])) character(0)
              else roles$marks[[b$variable]],
      cells = list(), raw = list())
    valid <- b$rows[b$rows$block == "valid", , drop = FALSE]
    miss  <- b$rows[b$rows$block == "missing", , drop = FALSE]
    valid_names <- cat_names(valid$code, valid$label)
    miss_names  <- cat_names(miss$code, miss$label)
    for (k in seq_len(nrow(valid))) {
      rows[[length(rows) + 1L]] <- data_row(
        valid_names[k], base + 1L,
        list(n = valid$count[k], percent = valid$total_pct[k],
             valid.percent = valid$valid_pct[k],
             cumulative = valid$cum_pct[k]))
    }
    if (nrow(miss) > 0L && !identical(mrows, "none")) {
      if (identical(mrows, "combined")) {
        n_miss <- sum(miss$count)
        rows[[length(rows) + 1L]] <- data_row(
          key("missing.label"), base + 1L,
          list(n = n_miss, percent = 100 * n_miss / b$n_total,
               valid.percent = NA_real_, cumulative = NA_real_))
      } else {
        for (k in seq_len(nrow(miss))) {
          rows[[length(rows) + 1L]] <- data_row(
            miss_names[k], base + 1L,
            list(n = miss$count[k], percent = miss$total_pct[k],
                 valid.percent = NA_real_, cumulative = NA_real_))
        }
      }
    }
  }

  # The notes: general (N when the variables share one pool, where the
  # style puts it, the filter, then the user's text), specific; no
  # probability note.
  pools <- unique(vapply(blocks, function(b) as.numeric(b$n_total), numeric(1)))
  np <- .jst_table_n_parts(key("n.position"),
                           if (length(pools) == 1L && !is.na(pools))
                             paste0("*N* = ", .jst_tbl_count(pools, thou)))
  general <- c(np$note, .jst_table_filter_note(
    results, vapply(results, function(r) {
      .jst_and_list(.jst_apa_model(r)$var_label)
    }, character(1)), style, type))
  if (!is.null(note)) general <- c(general, note)

  .jst_table_new(
    type     = type,
    columns  = columns,
    rows     = rows,
    caption  = list(number = NA_integer_,
                    title  = paste0(if (is.null(title)) key("title") else title,
                                    np$title)),
    notes    = list(general = general, specific = roles$specific,
                    probability = character(0)),
    style    = style)
}

# -----------------------------------------------------------------------------
# 4c. The regression and logistic builders (jlm() and jlogistic() results;
#     build 3, Session 403)
# -----------------------------------------------------------------------------
#
# Jeff's Table 3 (the reference, Part 4.1, and Part 1's build-3 decisions):
# the models of one outcome SIDE BY SIDE, a spanner over each model's
# columns, the Constant first, the predictors in the models' order, a
# dummy-coded variable as its label row with its categories indented under
# it, each named by its value label, the reference category named after
# the label (reference = row), the fit rows under the predictors, and the
# notes. One builder serves both classes: a logistic result differs in
# its columns (the odds ratio in place of beta) and its fit rows. A
# builder reads the code and the label, never a display string (4.3).

# A jlm() or jlogistic() result: one result, built as a list of one.
.jst_table_build.jst_lm <- function(x, style, headings = NULL, markers = NULL,
                                    title = NULL, note = NULL, ...) {
  .jst_table_build_models(list(x), style, headings, markers, title, note)
}
.jst_table_build.jst_logistic <- function(x, style, headings = NULL,
                                          markers = NULL, title = NULL,
                                          note = NULL, ...) {
  .jst_table_build_models(list(x), style, headings, markers, title, note)
}

#' Internal helper: the regression or logistic table from one or more models
#'
#' The models of one outcome side by side, in the order given (the
#' reference, Part 2.4). The columns are the style's, repeated per model
#' under a spanner reading "Model 1", "Model 2", ... or the list's names,
#' with columns.last added to the last model only; the Constant first
#' (intercept = yes); then the predictors in first-appearance order over
#' the models, a term's row labelled by its variable label; a dummy-coded
#' variable of three or more categories as its label row with the
#' categories indented under it, each named by its value label (its code
#' where it has none), and a two-category one as one row, "label:
#' category"; the reference category after the label (reference = row),
#' in the general note (note) or nowhere (none); then the fit rows the
#' style asks for, each under its model's first column, with the N row
#' added when the models' Ns differ (Session 401). Numbers follow the
#' style: b, SE and a confidence limit with a near-zero value kept visible
#' (\code{.jst_tbl_coef()}), a standardized coefficient, R2 and p at the
#' decimals with APA's leading-zero rule, counts whole. The general note:
#' N where n.position puts it, the reference categories under reference =
#' note, the beta* definition when the column is shown, then the user's
#' text; stars' legend when p.format uses them. Models with different Ns
#' are built, never stopped: the table says so and the console gets the
#' jcomplete() line (the structure's \code{messages}, which jtable()
#' prints).
#'
#' @param results A list of jst_lm, or of jst_logistic, results; names
#'   are the model heads.
#' @inheritParams .jst_table_build
#' @return A jst_table, with a \code{messages} element (character; the
#'   notes jtable() prints before the preview).
#' @keywords internal
.jst_table_build_models <- function(results, style, headings = NULL,
                                    markers = NULL, title = NULL,
                                    note = NULL) {
  logistic <- inherits(results[[1L]], "jst_logistic")
  type <- if (logistic) "logistic" else "regression"
  fn   <- if (logistic) "jlogistic()" else "jlm()"
  key  <- function(k) .jst_style_key(style, type, k)
  dec  <- key("decimals"); thou <- key("thousands"); minus <- key("minus")
  lzs  <- key("leading.zero"); pfmt <- key("p.format"); pdec <- key("p.decimals")
  stars <- key("stars")
  lz_u <- .jst_tbl_lz(lzs, FALSE); lz_b <- .jst_tbl_lz(lzs, TRUE)
  num   <- function(x, bounded = FALSE) {
    .jst_tbl_num(x, dec, thou, if (bounded) lz_b else lz_u, minus)
  }
  coef  <- function(x) .jst_tbl_coef(x, dec, thou, lz_u, minus)
  pval  <- function(p) .jst_tbl_p(p, pfmt, pdec, stars, lz_b)
  count <- function(n) .jst_tbl_count(n, thou)
  use_stars <- !identical(pfmt, "exact")
  star  <- function(p) if (use_stars) .jst_tbl_stars(p, stars) else ""
  whole <- function(x) formatC(round(x), format = "d")

  .jst_table_no_headings(headings, type, "the predictors in the models' order")

  # Each result's fields, as this build stores them: a result made before
  # them stops with its version (as the other builders stop).
  nm <- length(results)
  terms <- vector("list", nm); mods <- vector("list", nm)
  groups <- vector("list", nm)
  for (i in seq_len(nm)) {
    r  <- results[[i]]
    tf <- .jst_apa_terms(r); md <- .jst_apa_model(r); gr <- r$dummy_groups
    ok <- !is.null(attr(r, "jstats_version", exact = TRUE)) &&
      !is.null(tf) && !is.null(md) && !is.null(r$formula_used) &&
      all(vapply(gr, function(g) !is.null(g$codes), logical(1)))
    if (!ok) .jst_table_old_stop(r, fn)
    terms[[i]] <- tf; mods[[i]] <- md; groups[[i]] <- gr
  }

  # One outcome: models of different outcomes are tables of their own, and
  # jtable() sorts its results before a builder sees them (ruling R56,
  # Session 406).
  outs <- vapply(results, function(r) {
    unname(attr(r$coefficients_raw, "outcome")["name"])
  }, character(1))
  if (length(unique(outs)) > 1L) {
    stop(".jst_table_build_models(): models of different outcomes", call. = FALSE)
  }
  out_label <- unname(attr(results[[1L]]$coefficients_raw, "outcome")["label"])
  if (is.na(out_label) || !nzchar(out_label)) out_label <- outs[1L]

  # The model heads: the list's names, else "Model 1", "Model 2", ...
  nms   <- names(results)
  named <- !is.null(nms) && any(nzchar(nms))
  heads <- paste("Model", seq_len(nm))
  if (named) heads[nzchar(nms)] <- nms[nzchar(nms)]

  # The columns, per model: the style's, and columns.last for the last.
  col_keys  <- key("columns")
  last_cols <- key("columns.last")
  last_cols <- if (identical(last_cols, "none")) character(0)
               else setdiff(last_cols, col_keys)
  ci_two    <- identical(key("ci.style"), "two")
  keys_of   <- lapply(seq_len(nm), function(i) {
    c(col_keys, if (i == nm) last_cols)
  })
  columns <- data.frame(key = "stub", label = key("stub.label"), kind = "text",
                        italic = FALSE, stringsAsFactors = FALSE)
  row1 <- list(); row2 <- list()
  first_col <- character(nm)      # each model's first column key
  pos <- 1L
  for (i in seq_len(nm)) {
    from <- pos + 1L
    for (k in keys_of[[i]]) {
      lab  <- key(paste0(k, ".label"))
      ital <- .jst_tbl_head_italic(type, k, lab)
      if (identical(k, "ci") && ci_two) {
        columns <- rbind(columns, data.frame(
          key = paste0("m", i, ".", c("ci.lower", "ci.upper")),
          label = c("LL", "UL"), kind = "number", italic = FALSE,
          stringsAsFactors = FALSE))
        row2[[length(row2) + 1L]] <- list(label = lab, from = pos + 1L,
                                          to = pos + 2L)
        pos <- pos + 2L
      } else {
        columns <- rbind(columns, data.frame(
          key = paste0("m", i, ".", k), label = lab, kind = "number",
          italic = ital, stringsAsFactors = FALSE))
        pos <- pos + 1L
      }
      if (!nzchar(first_col[i])) first_col[i] <- paste0("m", i, ".", k)
    }
    row1[[length(row1) + 1L]] <- list(label = heads[i], from = from, to = pos)
  }
  rownames(columns) <- NULL
  spanners <- list()
  if (nm > 1L || named) spanners <- c(spanners, list(row1))
  if (length(row2)) spanners <- c(spanners, list(row2))
  if (!length(spanners)) spanners <- NULL
  num_keys <- columns$key[-1L]

  # The row plan: the terms of every model in first-appearance order, a
  # dummy-coded variable's terms gathered under its variable.
  group_of <- function(i, term) {
    for (v in names(groups[[i]])) {
      if (term %in% groups[[i]][[v]]$dummy) return(v)
    }
    NA_character_
  }
  plan <- list(); seen <- character(0)
  for (i in seq_len(nm)) {
    tf <- terms[[i]]
    for (j in seq_len(nrow(tf))) {
      tk <- tf$term[j]
      if (identical(tk, "(Intercept)")) next
      v  <- group_of(i, tk)
      id <- if (is.na(v)) paste0("term:", tk) else paste0("group:", v)
      if (id %in% seen) next
      seen <- c(seen, id)
      plan[[length(plan) + 1L]] <- if (is.na(v)) {
        list(kind = "term", var = tk, term = tk,
             label = if (is.na(tf$label[j]) || !nzchar(tf$label[j])) tk
                     else tf$label[j])
      } else {
        list(kind = "group", var = v)
      }
    }
  }
  # A dummy-coded variable's categories: the first model's, in code order,
  # and any a later model adds; the reference is the one with no dummy.
  group_cats <- function(v) {
    codes <- character(0); labs <- character(0); dums <- character(0)
    var_label <- v
    for (i in seq_len(nm)) {
      g <- groups[[i]][[v]]
      if (is.null(g)) next
      if (identical(var_label, v) && !is.null(g$var_label)) var_label <- g$var_label
      for (k in seq_along(g$codes)) {
        cd <- as.character(g$codes[k])
        if (cd %in% codes) next
        codes <- c(codes, cd); labs <- c(labs, g$value_labels[k])
        dums  <- c(dums, g$dummy[k])
      }
    }
    list(var_label = var_label, codes = codes, dummy = dums,
         names = .jst_table_cat_names(codes, labs))
  }

  # markers = marks a predictor's row: a term's, or a dummy-coded
  # variable's label row.
  vars  <- vapply(plan, function(p) p$var, character(1))
  roles <- .jst_table_roles(vars, rep(NA_character_, length(vars)), NULL,
                            markers, key("marks"))
  mark_of <- roles$marks

  # The cells of one term in one model, by column key; "" where the model
  # lacks the term. Stars go on b when the table has no p column.
  cell_of <- function(i, term, k) {
    tf <- terms[[i]]
    r  <- tf[tf$term == term, , drop = FALSE]
    if (!nrow(r)) return("")
    is_int <- identical(term, "(Intercept)")
    switch(k,
           b           = paste0(coef(r$b), if (!"p" %in% keys_of[[i]]) star(r$p)),
           se          = coef(r$SE),
           beta        = if (is_int) "" else num(r$beta, TRUE),
           beta.gelman = if (is_int) "" else num(r$beta_gelman),
           p           = pval(r$p),
           t           = num(r$t),
           wald        = num(r$Wald),
           or          = num(r$exp_b),
           ci          = if (logistic) {
             paste0("[", coef(r$exp_ci_lower), ", ", coef(r$exp_ci_upper), "]")
           } else {
             paste0("[", coef(r$ci_lower), ", ", coef(r$ci_upper), "]")
           },
           ci.lower    = coef(if (logistic) r$exp_ci_lower else r$ci_lower),
           ci.upper    = coef(if (logistic) r$exp_ci_upper else r$ci_upper),
           "")
  }
  term_cells <- function(term) {
    cells <- stats::setNames(vector("list", length(num_keys)), num_keys)
    for (ck in num_keys) {
      i <- as.integer(sub("^m([0-9]+)\\..*$", "\\1", ck))
      k <- sub("^m[0-9]+\\.", "", ck)
      cells[[ck]] <- cell_of(i, term, k)
    }
    cells
  }
  data_row <- function(label, indent, cells, marks = character(0),
                       markup = FALSE, tail = "", span = NULL) {
    list(kind = "data", label = label, indent = indent, marks = marks,
         cells = cells, raw = list(), markup = markup, tail = tail,
         span = span)
  }
  ref_set <- key("reference"); ref_word <- key("reference.label")
  ref_of  <- function(ref_name) {
    if (identical(ref_set, "row")) paste0(" (", ref_word, " = ", ref_name, ")")
    else ""
  }

  rows <- list(); ref_notes <- character(0)
  # The Constant, first.
  if (identical(key("intercept"), "yes") &&
      any(vapply(terms, function(tf) "(Intercept)" %in% tf$term, logical(1)))) {
    rows[[length(rows) + 1L]] <- data_row(key("intercept.label"), 0L,
                                          term_cells("(Intercept)"))
  }
  for (p in plan) {
    marks <- if (is.null(mark_of[[p$var]])) character(0) else mark_of[[p$var]]
    if (identical(p$kind, "term")) {
      rows[[length(rows) + 1L]] <- data_row(p$label, 0L, term_cells(p$term), marks)
      next
    }
    g   <- group_cats(p$var)
    ref <- which(is.na(g$dummy))
    ref_name <- if (length(ref)) g$names[ref[1L]] else NA_character_
    cats <- which(!is.na(g$dummy))
    if (identical(ref_set, "note") && !is.na(ref_name)) {
      ref_notes <- c(ref_notes, paste0("Reference category for ", g$var_label,
                                       ": ", ref_name, "."))
    }
    # The reference parenthetical is the row's tail: after the label and
    # any mark on it.
    suffix <- if (!is.na(ref_name)) ref_of(ref_name) else ""
    if (length(cats) == 1L) {
      # A two-category variable: one row, "label: category" (Session 402,
      # item 7).
      rows[[length(rows) + 1L]] <- data_row(
        paste0(g$var_label, ": ", g$names[cats]), 0L,
        term_cells(g$dummy[cats]), marks, tail = suffix)
      next
    }
    rows[[length(rows) + 1L]] <- list(kind = "heading", level = "variable",
                                      label = g$var_label, indent = 0L,
                                      marks = marks, cells = list(),
                                      raw = list(), tail = suffix)
    for (k in cats) {
      rows[[length(rows) + 1L]] <- data_row(g$names[k], 1L,
                                            term_cells(g$dummy[k]))
    }
  }

  # The fit rows, each under its model's first column.
  ns <- vapply(mods, function(m) as.numeric(m$n), numeric(1))
  ns_differ <- length(unique(ns)) > 1L
  fit_keys  <- key("fit.rows")
  fit_none  <- identical(fit_keys, "none")
  if (fit_none) fit_keys <- character(0)
  if (ns_differ && !fit_none && !"n" %in% fit_keys) fit_keys <- c(fit_keys, "n")
  messages <- character(0)
  # Delta R2 and its F test need nested models on one set of cases.
  nested <- !ns_differ && nm > 1L && all(vapply(seq_len(nm)[-1L], function(i) {
    all(terms[[i - 1L]]$term %in% terms[[i]]$term)
  }, logical(1)))
  if (!logistic && any(c("delta.r2", "f.change") %in% fit_keys) && !nested) {
    gone <- intersect(c("delta.r2", "f.change"), fit_keys)
    messages <- c(messages, paste0(
      "Note: the ", .jst_and_list(c(delta.r2 = "delta R2", f.change = "F change")[gone]),
      if (length(gone) == 1L) " row is" else " rows are",
      " left out: ", if (length(gone) == 1L) "it needs" else "they need",
      " nested models -- each holding every predictor of the one before ",
      "it -- fit on the same cases."))
    fit_keys <- setdiff(fit_keys, gone)
  }
  n_pred <- vapply(terms, function(tf) sum(tf$term != "(Intercept)"), integer(1))
  fit_cell <- function(k, i) {
    m <- mods[[i]]
    if (logistic) {
      switch(k,
             chisq      = paste0(num(m$chi_sq), star(m$omnibus_p), " (",
                                 whole(m$omnibus_df), ")"),
             nagelkerke = num(m$nagelkerke_r2, TRUE),
             cox.snell  = num(m$cox_snell_r2, TRUE),
             neg2ll     = num(-2 * m$ll_model),
             aic        = num(m$aic),
             n          = count(m$n),
             "")
    } else {
      switch(k,
             r2       = num(m$r_squared, TRUE),
             adj.r2   = num(m$adj_r_squared, TRUE),
             f        = paste0(num(m$f_value), star(m$f_p), " (", whole(m$f_df1),
                               ", ", whole(m$f_df2), ")"),
             delta.r2 = if (i == 1L) "" else
               num(m$r_squared - mods[[i - 1L]]$r_squared, TRUE),
             f.change = if (i == 1L) "" else {
               d1 <- n_pred[i] - n_pred[i - 1L]; d2 <- m$df_residual
               fc <- ((m$r_squared - mods[[i - 1L]]$r_squared) / d1) /
                 ((1 - m$r_squared) / d2)
               pc <- stats::pf(fc, d1, d2, lower.tail = FALSE)
               paste0(num(fc), star(pc), " (", whole(d1), ", ", whole(d2), ")")
             },
             n        = count(m$n),
             "")
    }
  }
  fit_labels <- if (logistic) {
    c(chisq = "Model \u03c7\u00b2", nagelkerke = "Nagelkerke *R*\u00b2",
      cox.snell = "Cox and Snell *R*\u00b2", neg2ll = "\u22122 log likelihood",
      aic = "AIC", n = "*N*")
  } else {
    c(r2 = "*R*\u00b2", adj.r2 = "Adjusted *R*\u00b2", f = "*F*",
      delta.r2 = "\u0394*R*\u00b2", f.change = "\u0394*F*", n = "*N*")
  }
  # A fit cell spans its model's columns: its value sits on the b
  # column's point, and the df that follow an F or a chi-square run on
  # into the model's other columns, empty in a fit row, instead of
  # widening b (Session 403).
  spans <- lapply(row1, function(sp) c(sp$from, sp$to))
  for (k in fit_keys) {
    cells <- stats::setNames(as.list(rep("", length(num_keys))), num_keys)
    for (i in seq_len(nm)) cells[[first_col[i]]] <- fit_cell(k, i)
    rows[[length(rows) + 1L]] <- data_row(fit_labels[[k]], 0L, cells,
                                          markup = TRUE, span = spans)
  }

  # The notes: N where n.position puts it (the models' Ns when they
  # differ), the reference categories, the beta* definition with its
  # column, the user's text; the stars' legend when stars are shown.
  n_text <- if (!ns_differ) {
    paste0("*N* = ", count(ns[1L]))
  } else {
    parts <- vapply(unique(ns), function(u) {
      paste0(count(u), " (", .jst_table_model_list(heads[ns == u]), ")")
    }, character(1))
    paste0("*N* differs by model: ", paste(parts, collapse = ", "))
  }
  np <- .jst_table_n_parts(key("n.position"), n_text,
                           if (ns_differ) "*N* differs by model" else n_text)
  general <- c(np$note, .jst_table_filter_note(results, heads, style, type,
                                               .jst_table_model_list),
               ref_notes)
  if ("beta.gelman" %in% unlist(keys_of)) {
    general <- c(general, paste0(
      "\u03b2* = Gelman's (2008) standardized coefficient: each continuous ",
      "predictor divided by two standard deviations, each binary predictor ",
      "kept at 0 and 1."))
  }
  if (!is.null(note)) general <- c(general, note)
  probability <- if (use_stars) .jst_tbl_stars_legend(stars, key("leading.zero")) else character(0)

  # The console note when the Ns differ: each model's N, and the
  # jcomplete() line that puts them on one set of cases (Session 401).
  if (ns_differ) {
    vars_all <- character(0)
    for (i in seq_len(nm)) {
      av <- all.vars(results[[i]]$formula_used)
      for (v in names(groups[[i]])) av[av %in% groups[[i]][[v]]$dummy] <- v
      vars_all <- union(vars_all, av)
    }
    dn <- results[[which.max(ns)]]$data_name
    dk <- if (is.character(dn) && length(dn) == 1L && !is.na(dn) && nzchar(dn)) {
      tryCatch(.jst_data_arg_kind(str2lang(dn)), error = function(e) "expression")
    } else "expression"
    data_txt <- if (dk %in% c("name", "place")) dn else "mydata"
    pre <- if (identical(data_txt, "mydata") && is.character(dn) &&
               length(dn) == 1L && !is.na(dn) && nzchar(dn)) {
      paste0("  mydata <- ", dn, "\n")
    }
    parts <- vapply(unique(ns), function(u) {
      paste0(.jst_table_model_list(heads[ns == u]), ": ", count(u))
    }, character(1))
    messages <- c(messages, paste0(
      "Note: the models were fit on different numbers of cases (",
      paste(parts, collapse = "; "), "); the table's note says so.\n",
      "To fit every model on the same cases, run jcomplete() on the ",
      "largest model's variables, then the models again:\n",
      pre, "  jcomplete(", data_txt, ", ", paste(vars_all, collapse = ", "), ")"))
  }

  tbl <- .jst_table_new(
    type     = type,
    columns  = columns,
    rows     = rows,
    caption  = list(number = NA_integer_,
                    title  = paste0(
                      if (is.null(title)) gsub("{outcome}", out_label, key("title"),
                                               fixed = TRUE)
                      else title,
                      np$title)),
    notes    = list(general = general, specific = roles$specific,
                    probability = probability),
    spanners = spanners,
    style    = style)
  tbl$messages <- messages
  tbl
}

#' Internal helper: a list of model heads, for a note
#'
#' "Model 2", "Model 3" and "Model 4" become "Models 2, 3, and 4"; named
#' heads are listed as given.
#'
#' @param heads Character; the heads.
#' @keywords internal
.jst_table_model_list <- function(heads) {
  if (length(heads) > 1L && all(grepl("^Model [0-9]+$", heads))) {
    return(paste0("Models ", .jst_and_list(sub("^Model ", "", heads))))
  }
  .jst_and_list(heads)
}

#' Internal helper: the variables of a result that headings = and markers =
#' may name
#'
#' A descriptives or frequency result's variables; a model's predictors --
#' each term as the coefficient table keys it, a dummy-coded variable by
#' its own name (the intercept aside); a correlation's variables; a t test's
#' or an ANOVA's outcome; a crosstab's row variable; a scale's items.
#'
#' @param r A result.
#' @return Character, possibly empty.
#' @keywords internal
.jst_table_result_vars <- function(r) {
  if (inherits(r, "jst_corr")) {
    return(if (is.null(r$r)) character(0) else rownames(r$r))
  }
  if (inherits(r, c("jst_ttest", "jst_anova"))) {
    v <- .jst_apa_name(r, "outcome")
    return(if (is.na(v)) character(0) else v)
  }
  if (inherits(r, "jst_crosstab")) {
    a <- attr(r$row_categories, "variable")
    return(if (is.null(a)) character(0) else unname(a["name"]))
  }
  tf <- .jst_apa_terms(r)
  if (is.null(tf)) return(character(0))
  if (inherits(r, "jst_alpha")) return(as.character(tf$item))
  if (!inherits(r, c("jst_lm", "jst_logistic"))) return(tf$variable)
  dummies <- unlist(lapply(r$dummy_groups, function(g) g$dummy))
  c(setdiff(tf$term, c("(Intercept)", dummies)), names(r$dummy_groups))
}

#' Internal helper: the version a result was made by, for a stop
#'
#' @param x A result.
#' @return Character(1): "jstats 0.9.200" from the stamp, or "an earlier
#'   version of jstats" when there is none (a result made before the
#'   stamp).
#' @keywords internal
.jst_table_result_version <- function(x) {
  v <- attr(x, "jstats_version", exact = TRUE)
  if (is.null(v)) "an earlier version of jstats" else paste("jstats", as.character(v))
}

#' Internal helper: names given in headings = or markers = are the result's
#'
#' @param given Character; the names given.
#' @param vars Character; the result's variables.
#' @param arg "headings" or "markers".
#' @keywords internal
.jst_table_check_names <- function(given, vars, arg) {
  bad <- setdiff(given, vars)
  if (length(bad)) {
    .jst_stop(arg, " = names ", .jst_and_list(bad), ", ",
              if (length(bad) == 1L) "which is" else "which are",
              " not among the variables of the result.\n",
              "The result holds ", .jst_and_list(vars), ".",
              fn = "jtable")
  }
  dup <- unique(given[duplicated(given)])
  if (length(dup)) {
    .jst_stop(arg, " = names ", .jst_and_list(dup), " more than once.",
              fn = "jtable")
  }
  invisible(NULL)
}

# -----------------------------------------------------------------------------
# 4d. What every builder shares: the stops, the names, the filter sentence
#     (build 4, Session 405)
# -----------------------------------------------------------------------------

#' Internal helper: the stop for a result made before its table's fields
#'
#' One home for the stop every builder gives a result whose fields predate
#' its table: the version that made it, from the stamp, and the way out.
#'
#' @param r The result.
#' @param fn The analysis function that made it, as messages name it
#'   ("jdesc()").
#' @keywords internal
.jst_table_old_stop <- function(r, fn) {
  .jst_stop("this ", fn, " result was made by ", .jst_table_result_version(r),
            ", before the fields a table needs were stored.\n",
            "Run the analysis again, then jtable() on the new result.",
            fn = "jtable")
}

#' Internal helper: the stop for headings = on a table that takes none
#'
#' headings = puts a descriptives or frequency table's variables under role
#' headings; every other table type lists its rows in an order of its own.
#'
#' @param headings The headings jtable() read, or NULL.
#' @param type The table type.
#' @param lists What the table lists, and in what order.
#' @keywords internal
.jst_table_no_headings <- function(headings, type, lists) {
  if (is.null(headings)) return(invisible(NULL))
  .jst_stop("headings = puts the variables of a descriptives or frequency ",
            "table under role headings; ", .jst_style_type_nouns[[type]],
            " lists ", lists, ".", fn = "jtable")
}

#' Internal helper: categories named by their value labels
#'
#' A category's name in a table is its value label, or its code where it
#' has none -- never the string a result printed (the reference, 4.3).
#' Where two codes given in one call would take one name -- a label used
#' for two codes -- each of them is named "code: label" ("1: Other",
#' "2: Other"), as the console shows them under value.id = "labels"
#' (Session 407, the (S399) colliding-labels item). A code repeated in
#' the vector is one code; an NA code takes no part.
#'
#' @param code The codes.
#' @param label The value labels (NA where there is none).
#' @return Character.
#' @keywords internal
.jst_table_cat_names <- function(code, label) {
  label <- as.character(label)
  has   <- !is.na(label) & nzchar(label)
  key   <- as.character(code)
  out   <- ifelse(has, label, key)
  seen  <- !is.na(code) & !duplicated(key)
  twice <- out[seen][duplicated(out[seen])]
  i     <- has & !is.na(code) & out %in% twice
  out[i] <- paste0(key[i], ": ", label[i])
  out
}

#' Internal helper: a variable's label, from a c(name = , label = ) pair
#'
#' @param a The pair (a result's "outcome", "group" or "variable"
#'   attribute), or NULL.
#' @param fallback The name to use when there is no label.
#' @return Character(1).
#' @keywords internal
.jst_table_var_label <- function(a, fallback) {
  lab <- if (is.null(a)) NA_character_ else unname(a["label"])
  if (is.na(lab) || !nzchar(lab)) fallback else lab
}

#' Internal helper: the general note's filter sentence
#'
#' "Only cases with Age (years) >= 30 are included." (the reference, Part
#' 1, lean 8): the filter a stored jsubset() applied and the call's
#' subset =, joined by "and", each put into words. Written once when every
#' result has the same filter; otherwise once per filter, naming the
#' results it covers. A jcomplete() setting adds nothing: N says it.
#' filter.note = no leaves the sentence out (ruling R53).
#'
#' @param results The results, in the table's order.
#' @param names Character, one per result: how a sentence names it when the
#'   results' filters differ.
#' @param style The style.
#' @param type The table type.
#' @param list_fn The function that joins the names (the models'
#'   \code{.jst_table_model_list()} writes "Models 2 and 3").
#' @return Character(0), or the sentences.
#' @keywords internal
.jst_table_filter_note <- function(results, names, style, type,
                                   list_fn = .jst_and_list) {
  key <- function(k) .jst_style_key(style, type, k)
  if (!identical(key("filter.note"), "yes")) return(character(0))
  minus <- key("minus")
  txt <- vapply(results, .jst_table_filter_text, character(1), minus = minus)
  if (all(is.na(txt))) return(character(0))
  u <- unique(txt)
  if (length(u) == 1L) return(paste0("Only cases with ", u, " are included."))
  vapply(u[!is.na(u)], function(t) {
    paste0("Only cases with ", t, " are included for ",
           list_fn(names[!is.na(txt) & txt == t]), ".")
  }, character(1), USE.NAMES = FALSE)
}

#' Internal helper: a result's filters, in words
#'
#' @param r A result.
#' @param minus The style's minus setting.
#' @return Character(1): the stored jsubset() filter, then the call's
#'   subset =, joined by "and" (an or-condition in parentheses beside the
#'   other); NA when the result had none.
#' @keywords internal
.jst_table_filter_text <- function(r, minus = "true") {
  si <- r$sample_info
  if (!is.list(si)) return(NA_character_)
  conds <- character(0)
  if (isTRUE(si$filter_active) && is.character(si$filter_expr) &&
      length(si$filter_expr)) {
    conds <- c(conds, paste(trimws(si$filter_expr), collapse = " "))
  }
  if (is.character(si$subset_expr) && length(si$subset_expr)) {
    conds <- c(conds, paste(trimws(si$subset_expr), collapse = " "))
  }
  if (!length(conds)) return(NA_character_)
  data  <- if (is.data.frame(si$pre_pipeline_data)) si$pre_pipeline_data
  parts <- lapply(conds, .jst_table_filter_words, data = data, minus = minus)
  txt <- vapply(parts, function(p) {
    if (length(parts) > 1L && isTRUE(p$or)) paste0("(", p$text, ")") else p$text
  }, character(1))
  paste(txt, collapse = " and ")
}

#' Internal helper: one filter condition, in words
#'
#' A comparison of a variable with a value is written with the variable's
#' label and the mathematical sign -- "Age (years) >= 30", the sign the
#' character itself -- and a code compared by ==, != or %in% as its value
#' label ("Current smoker = No", "Region of residence = North or East");
#' & and | are "and" and "or", with parentheses where the two mix. A
#' condition it cannot put into words -- a function of a variable, a
#' workspace object, a name that is not a variable of the data -- is
#' written as typed.
#'
#' @param cond Character(1); the condition as the result stores it.
#' @param data The data frame it was applied to, for the labels; NULL
#'   writes the condition as typed.
#' @param minus The style's minus setting, for a negative value.
#' @return A list: text, and or (logical: the condition's top level is an
#'   or, which takes parentheses beside another condition).
#' @keywords internal
.jst_table_filter_words <- function(cond, data = NULL, minus = "true") {
  ex <- tryCatch(str2lang(cond), error = function(e) NULL)
  if (is.null(ex)) return(list(text = cond, or = FALSE))
  is_or <- is.call(ex) && as.character(ex[[1L]])[1L] %in% c("|", "||")
  w <- if (is.data.frame(data)) .jst_table_cond_words(ex, data, minus) else NULL
  list(text = if (is.null(w)) cond else w, or = is_or)
}

#' Internal helper: a parsed condition in words, or NULL
#'
#' The walk \code{.jst_table_filter_words()} runs: NULL as soon as any part
#' cannot be put into words, so a condition is written wholly in words or
#' wholly as typed. A value is read only from what was typed -- a number,
#' a string, TRUE or FALSE, c() and : of them -- never evaluated.
#'
#' @param ex The parsed condition.
#' @param data The data frame.
#' @param minus The style's minus setting.
#' @return Character(1), or NULL.
#' @keywords internal
.jst_table_cond_words <- function(ex, data, minus = "true") {
  signs <- c("==" = "=", "!=" = "\u2260", ">=" = "\u2265", "<=" = "\u2264",
             ">" = ">", "<" = "<")
  flip  <- c("==" = "==", "!=" = "!=", ">=" = "<=", "<=" = ">=", ">" = "<",
             "<" = ">")
  is_var <- function(e) is.symbol(e) && as.character(e) %in% names(data)
  one <- function(e) {
    if ((is.numeric(e) || is.character(e) || is.logical(e)) && length(e) == 1L &&
        !is.na(e)) return(e)
    if (is.call(e) && identical(e[[1L]], as.name("-")) && length(e) == 2L &&
        is.numeric(e[[2L]]) && length(e[[2L]]) == 1L) return(-e[[2L]])
    NULL
  }
  many <- function(e) {
    x <- one(e)
    if (!is.null(x)) return(x)
    if (is.call(e) && identical(e[[1L]], as.name("c")) && length(e) > 1L) {
      parts <- lapply(as.list(e)[-1L], one)
      if (any(vapply(parts, is.null, logical(1)))) return(NULL)
      return(unlist(parts))
    }
    if (is.call(e) && identical(e[[1L]], as.name(":")) && length(e) == 3L) {
      a <- one(e[[2L]]); b <- one(e[[3L]])
      if (is.numeric(a) && is.numeric(b) && abs(b - a) < 100) return(seq(a, b))
    }
    NULL
  }
  vlab <- function(v) {
    l <- attr(data[[v]], "label", exact = TRUE)
    if (is.character(l) && length(l) == 1L && !is.na(l) && nzchar(l)) l else v
  }
  value <- function(v, x, by_label) {
    if (by_label) {
      labs <- attr(data[[v]], "labels", exact = TRUE)
      if (!is.null(labs)) {
        i <- match(x, unname(labs))
        if (!is.na(i) && nzchar(names(labs)[i])) return(names(labs)[i])
      }
    }
    if (is.character(x)) return(x)
    if (is.logical(x)) return(as.character(x))
    s <- format(x, scientific = FALSE, trim = TRUE)
    if (identical(minus, "true")) s <- sub("^-", "\u2212", s)
    s
  }
  walk <- function(e) {
    if (!is.call(e)) return(NULL)
    f <- as.character(e[[1L]])[1L]
    if (identical(f, "(") && length(e) == 2L) {
      a <- walk(e[[2L]])
      return(if (is.null(a)) NULL else paste0("(", a, ")"))
    }
    if (f %in% c("&", "&&", "|", "||") && length(e) == 3L) {
      a <- walk(e[[2L]]); b <- walk(e[[3L]])
      if (is.null(a) || is.null(b)) return(NULL)
      and   <- f %in% c("&", "&&")
      other <- if (and) c("|", "||") else c("&", "&&")
      wrap  <- function(sub, txt) {
        if (is.call(sub) && as.character(sub[[1L]])[1L] %in% other) {
          paste0("(", txt, ")")
        } else txt
      }
      return(paste(wrap(e[[2L]], a), if (and) "and" else "or", wrap(e[[3L]], b)))
    }
    if (f %in% names(signs) && length(e) == 3L) {
      l <- e[[2L]]; r <- e[[3L]]; op <- f
      if (!is_var(l) && is_var(r)) { t <- l; l <- r; r <- t; op <- flip[[op]] }
      if (!is_var(l)) return(NULL)
      x <- one(r)
      if (is.null(x)) return(NULL)
      v <- as.character(l)
      return(paste(vlab(v), signs[[op]], value(v, x, op %in% c("==", "!="))))
    }
    if (identical(f, "%in%") && length(e) == 3L && is_var(e[[2L]])) {
      x <- many(e[[3L]])
      if (is.null(x) || !length(x)) return(NULL)
      v <- as.character(e[[2L]])
      return(paste(vlab(v), "=",
                   .jst_or_list(vapply(x, function(z) value(v, z, TRUE), character(1)))))
    }
    NULL
  }
  walk(ex)
}

#' Internal helper: N in a table that stacks results, when the Ns differ
#'
#' "*N* differs by variable: 98 (Current smoker), 103 (Owns home and
#' Region of residence)" -- equal Ns grouped, as the models' sentence
#' groups them (Session 403).
#'
#' @param ns Numeric, one per result.
#' @param names Character, one per result.
#' @param by The word after "by": "variable", "scale".
#' @param thou The style's thousands setting.
#' @return A list: note (the sentence's body, or the one N's) and title (the
#'   title's parenthesis body).
#' @keywords internal
.jst_table_n_by <- function(ns, names, by, thou) {
  if (length(unique(ns)) == 1L) {
    t <- paste0("*N* = ", .jst_tbl_count(ns[1L], thou))
    return(list(note = t, title = t))
  }
  parts <- vapply(unique(ns), function(u) {
    paste0(.jst_tbl_count(u, thou), " (", .jst_and_list(names[ns == u]), ")")
  }, character(1))
  list(note  = paste0("*N* differs by ", by, ": ", paste(parts, collapse = ", ")),
       title = paste0("*N* differs by ", by))
}


# -----------------------------------------------------------------------------
# 4e. The correlation table (a jcorr() result; build 4, Session 405)
# -----------------------------------------------------------------------------
#
# APA's sample form (the reference, Part 1, lean 1): the variables
# numbered, each variable's n, M and SD on its own cases, then one column
# per variable headed 1 to k, each correlation once below the diagonal and
# an em dash on the diagonal; r without its zero (bounded by 1), with stars
# for its p-value -- an exact p cannot share a matrix cell -- and their
# legend under the table. Each jcorr() result is a table of its own
# (ruling R54): more variables go in the one call.

# A jcorr() result: one result, built as a list of one.
.jst_table_build.jst_corr <- function(x, style, headings = NULL,
                                      markers = NULL, title = NULL,
                                      note = NULL, ...) {
  .jst_table_build_corr(list(x), style, headings, markers, title, note)
}

#' Internal helper: the correlation table from a jcorr() result
#'
#' @param results A list holding one jst_corr result.
#' @inheritParams .jst_table_build
#' @return A jst_table.
#' @keywords internal
.jst_table_build_corr <- function(results, style, headings = NULL,
                                  markers = NULL, title = NULL, note = NULL) {
  type <- "correlation"
  key  <- function(k) .jst_style_key(style, type, k)
  dec  <- key("decimals"); thou <- key("thousands"); minus <- key("minus")
  lzs  <- key("leading.zero")
  num  <- function(x, bounded = FALSE) {
    .jst_tbl_num(x, dec, thou, .jst_tbl_lz(lzs, bounded), minus)
  }
  count <- function(n) .jst_tbl_count(n, thou)
  .jst_table_no_headings(headings, type, "its variables in the result's order")
  # Each jcorr() result is a table of its own (ruling R54): jtable() gives
  # this builder one at a time, and its stop for a list of them is
  # .jst_table_split_stop()'s (ruling R56, Session 406).
  if (length(results) > 1L) {
    stop(".jst_table_build_corr(): one jcorr() result per table", call. = FALSE)
  }
  r  <- results[[1L]]
  tf <- .jst_apa_terms(r)
  vt <- if (is.null(tf)) NULL else attr(tf, "variables")
  if (is.null(attr(r, "jstats_version", exact = TRUE)) || is.null(vt) ||
      is.null(r$r)) {
    .jst_table_old_stop(r, "jcorr()")
  }
  vars <- rownames(r$r); k <- length(vars)
  vt   <- vt[match(vars, vt$variable), , drop = FALSE]
  labs <- ifelse(is.na(vt$label) | !nzchar(vt$label), vars, vt$label)

  # The columns: the stub, the descriptive columns, then 1 to k.
  dcols <- key("columns")
  if (identical(dcols, "none")) dcols <- character(0)
  dlabs <- vapply(dcols, function(cc) key(paste0(cc, ".label")), character(1),
                  USE.NAMES = FALSE)
  rkeys <- paste0("r", seq_len(k))
  columns <- data.frame(
    key    = c("stub", dcols, rkeys),
    label  = c(key("stub.label"), dlabs, as.character(seq_len(k))),
    kind   = c("text", rep("number", length(dcols) + k)),
    italic = c(FALSE, .jst_tbl_head_italic(type, dcols, dlabs), rep(FALSE, k)),
    stringsAsFactors = FALSE, row.names = NULL)

  # The rows: each variable numbered; the matrix below the diagonal (both
  # triangles under lower.triangle = no), an em dash on it.
  lower <- identical(key("lower.triangle"), "yes")
  st_on <- identical(key("r.stars"), "yes"); thr <- key("stars")
  roles <- .jst_table_roles(vars, rep(NA_character_, k), NULL, markers,
                            key("marks"))
  rows <- lapply(seq_len(k), function(i) {
    raw   <- list(n = vt$n[i], mean = vt$mean[i], sd = vt$sd[i])
    cells <- list(n = count(vt$n[i]), mean = num(vt$mean[i]), sd = num(vt$sd[i]))
    for (j in seq_len(k)) {
      cells[[rkeys[j]]] <- if (i == j) {
        "\u2014"
      } else if (j < i || !lower) {
        paste0(num(r$r[i, j], TRUE), if (st_on) .jst_tbl_stars(r$p[i, j], thr))
      } else ""
      raw[[rkeys[j]]] <- if (i == j) NA_real_ else r$r[i, j]
    }
    list(kind = "data", label = paste0(i, ". ", labs[i]), indent = 0L,
         marks = if (is.null(roles$marks[[vars[i]]])) character(0)
                 else roles$marks[[vars[i]]],
         cells = cells[c(dcols, rkeys)], raw = raw[c(dcols, rkeys)])
  })

  # The notes: N, or the range of the pairwise ns, where n.position puts
  # it; the filter; the method of a Spearman or Kendall table; the user's
  # text; the stars' legend.
  pn <- r$n[lower.tri(r$n)]
  one_n <- length(unique(pn)) == 1L
  n_text <- if (one_n) paste0("*N* = ", count(pn[1L])) else {
    paste0("Pairwise *n*s range from ", count(min(pn)), " to ", count(max(pn)))
  }
  np <- .jst_table_n_parts(key("n.position"), n_text,
                           if (one_n) n_text else
                             paste0("pairwise *n*s ", count(min(pn)), " to ",
                                    count(max(pn))))
  general <- c(np$note, .jst_table_filter_note(results, "the correlations",
                                               style, type))
  meth <- if (is.character(r$method) && length(r$method) == 1L) r$method else "pearson"
  if (meth %in% c("spearman", "kendall") && identical(key("method.note"), "yes")) {
    general <- c(general, paste0("Correlations are ",
                                 c(spearman = "Spearman", kendall = "Kendall")[[meth]],
                                 " rank correlations."))
  }
  if (!is.null(note)) general <- c(general, note)

  .jst_table_new(
    type     = type,
    columns  = columns,
    rows     = rows,
    caption  = list(number = NA_integer_,
                    title  = paste0(if (is.null(title)) key("title") else title,
                                    np$title)),
    notes    = list(general = general, specific = roles$specific,
                    probability = if (st_on) .jst_tbl_stars_legend(thr, key("leading.zero"))
                                  else character(0)),
    style    = style)
}


# -----------------------------------------------------------------------------
# 4f. The t-test and ANOVA tables (jt() and jaov() results; build 4)
# -----------------------------------------------------------------------------
#
# APA's samples (the reference, Part 1, leans 2 and 3): one row per outcome
# -- the tests of one grouping variable stacked (ruling R54) -- each
# group's M and SD under its value label, the grouping variable's label
# over the groups, then t, p and Cohen's d, or F, p and eta2. The df go in
# the statistic's head when every row shares them ("t(101)", "F(3, 99)"),
# else in a df column. The groups' ns go in the general note. One builder
# serves both classes.

# A jt() or jaov() result: one result, built as a list of one.
.jst_table_build.jst_ttest <- function(x, style, headings = NULL,
                                       markers = NULL, title = NULL,
                                       note = NULL, ...) {
  .jst_table_build_groups(list(x), style, headings, markers, title, note)
}
.jst_table_build.jst_anova <- function(x, style, headings = NULL,
                                       markers = NULL, title = NULL,
                                       note = NULL, ...) {
  .jst_table_build_groups(list(x), style, headings, markers, title, note)
}

#' Internal helper: the t-test or ANOVA table from one or more results
#'
#' The results of one grouping variable, one row per outcome in the order
#' given; the columns are the style's: each group's columns (n, mean, sd)
#' under the group's value label (its code where it has none), the
#' grouping variable's label over them all (group.spanner), then the test's
#' (t, p, d, diff, ci; or f, p, eta2). Signs as jt() computes them, the
#' first group's mean minus the second's. The general note: the groups'
#' ns where n.position puts N (a range per group where they vary), the
#' filter, a sentence for a Welch or a paired test (test.note), the user's
#' text; the stars' legend when p.format uses them.
#'
#' @param results A list of jst_ttest, or of jst_anova, results.
#' @inheritParams .jst_table_build
#' @return A jst_table.
#' @keywords internal
.jst_table_build_groups <- function(results, style, headings = NULL,
                                    markers = NULL, title = NULL, note = NULL) {
  anova <- inherits(results[[1L]], "jst_anova")
  type  <- if (anova) "anova" else "ttest"
  fn    <- if (anova) "jaov()" else "jt()"
  key   <- function(k) .jst_style_key(style, type, k)
  dec   <- key("decimals"); thou <- key("thousands"); minus <- key("minus")
  lzs   <- key("leading.zero"); pfmt <- key("p.format"); pdec <- key("p.decimals")
  stars <- key("stars")
  num   <- function(x, bounded = FALSE) {
    .jst_tbl_num(x, dec, thou, .jst_tbl_lz(lzs, bounded), minus)
  }
  pval  <- function(p) .jst_tbl_p(p, pfmt, pdec, stars, .jst_tbl_lz(lzs, TRUE))
  count <- function(n) .jst_tbl_count(n, thou)
  use_stars <- !identical(pfmt, "exact")
  star  <- function(p) if (use_stars) .jst_tbl_stars(p, stars) else ""
  # df: whole, without a thousands separator (APA); Welch's at the decimals.
  dfmt  <- function(x) {
    if (is.null(x) || is.na(x)) return("")
    if (abs(x - round(x)) < 1e-8) formatC(round(x), format = "d")
    else .jst_tbl_num(x, dec, "none", TRUE, minus)
  }
  .jst_table_no_headings(headings, type, "its outcomes in the order given")

  nr <- length(results)
  terms <- vector("list", nr); mods <- vector("list", nr)
  for (i in seq_len(nr)) {
    r  <- results[[i]]
    tf <- .jst_apa_terms(r); md <- .jst_apa_model(r)
    if (is.null(attr(r, "jstats_version", exact = TRUE)) || is.null(tf) ||
        is.null(md)) {
      .jst_table_old_stop(r, fn)
    }
    terms[[i]] <- tf; mods[[i]] <- md
  }
  # One grouping variable (ruling R54), the same groups in every result,
  # each outcome once. jtable() sorts its results by what they share
  # before a builder sees them, so results of different grouping variables
  # or groups stop there, with the lines that make each table (ruling R56,
  # Session 406); here they are an internal fault.
  grps <- vapply(mods, function(m) as.character(m$group), character(1))
  codes <- lapply(terms, function(tf) as.character(tf$group_code))
  if (length(unique(grps)) > 1L ||
      !all(vapply(codes, identical, logical(1), codes[[1L]]))) {
    stop(".jst_table_build_groups(): results of different groups", call. = FALSE)
  }
  outs <- vapply(mods, function(m) as.character(m$outcome), character(1))
  .jst_table_once(outs)
  olabs <- vapply(seq_len(nr), function(i) {
    .jst_table_var_label(attr(results[[i]]$descriptives_raw, "outcome"), outs[i])
  }, character(1))
  glab  <- .jst_table_var_label(attr(results[[1L]]$descriptives_raw, "group"),
                                grps[1L])
  gnames <- .jst_table_cat_names(terms[[1L]]$group_code, terms[[1L]]$group_label)
  ng <- length(gnames)

  # The columns: each group's, then the test's. The df in the statistic's
  # head when every row shares them, else a column after it.
  req    <- key("columns")
  g_keys <- intersect(req, c("n", "mean", "sd"))
  s_keys <- intersect(req, if (anova) c("f", "p", "eta2")
                           else c("t", "p", "d", "diff", "ci"))
  stat   <- if (anova) "f" else "t"
  df_txt <- vapply(mods, function(m) {
    if (anova) paste0(dfmt(m$df1), ", ", dfmt(m$df2)) else dfmt(m$df)
  }, character(1))
  df_shared <- length(unique(df_txt)) == 1L
  ci_two <- !anova && identical(key("ci.style"), "two")
  columns <- data.frame(key = "stub", label = key("stub.label"), kind = "text",
                        italic = FALSE, stringsAsFactors = FALSE)
  add_col <- function(k, lab, ital) {
    columns <<- rbind(columns, data.frame(key = k, label = lab, kind = "number",
                                          italic = ital, stringsAsFactors = FALSE))
  }
  rowB <- list(); pos <- 1L
  for (g in seq_len(ng)) {
    from <- pos + 1L
    for (k in g_keys) {
      lab <- key(paste0(k, ".label"))
      add_col(paste0("g", g, ".", k), lab, .jst_tbl_head_italic(type, k, lab))
      pos <- pos + 1L
    }
    if (length(g_keys)) rowB[[length(rowB) + 1L]] <- list(label = gnames[g],
                                                          from = from, to = pos)
  }
  g_end <- pos
  for (k in s_keys) {
    lab <- key(paste0(k, ".label"))
    if (identical(k, stat) && df_shared) {
      # The head carries its df: "*t*(101)", the symbol in italics (a
      # head with markup, Session 405).
      ital <- .jst_tbl_head_italic(type, k, lab)
      add_col(k, if (ital) paste0("*", lab, "*(", df_txt[1L], ")")
                 else paste0(lab, " (", df_txt[1L], ")"), FALSE)
      pos <- pos + 1L
    } else if (identical(k, "ci") && ci_two) {
      add_col("ci.lower", "LL", FALSE); add_col("ci.upper", "UL", FALSE)
      rowB[[length(rowB) + 1L]] <- list(label = lab, from = pos + 1L, to = pos + 2L)
      pos <- pos + 2L
    } else {
      add_col(k, lab, .jst_tbl_head_italic(type, k, lab))
      pos <- pos + 1L
    }
    if (identical(k, stat) && !df_shared) {
      dl <- key("df.label")
      add_col("df", dl, .jst_tbl_head_italic(type, "df", dl))
      # An ANOVA's df are two numbers, "3, 99": text, centered, never on a
      # decimal tab.
      if (anova) columns$kind[nrow(columns)] <- "text"
      pos <- pos + 1L
    }
  }
  rownames(columns) <- NULL
  spanners <- list()
  if (length(g_keys) && identical(key("group.spanner"), "yes")) {
    spanners <- c(spanners, list(list(list(label = glab, from = 2L, to = g_end))))
  }
  if (length(rowB)) spanners <- c(spanners, list(rowB))
  if (!length(spanners)) spanners <- NULL

  # The rows: one per outcome; stars on the statistic when the table has
  # no p column (as on b, Session 403).
  roles <- .jst_table_roles(outs, rep(NA_character_, nr), NULL, markers,
                            key("marks"))
  p_shown <- "p" %in% s_keys
  rows <- lapply(seq_len(nr), function(i) {
    tf <- terms[[i]]; m <- mods[[i]]
    cells <- list(); raw <- list()
    for (g in seq_len(ng)) {
      cells[[paste0("g", g, ".n")]]    <- count(tf$n[g])
      cells[[paste0("g", g, ".mean")]] <- num(tf$mean[g])
      cells[[paste0("g", g, ".sd")]]   <- num(tf$sd[g])
      raw[[paste0("g", g, ".n")]]      <- tf$n[g]
      raw[[paste0("g", g, ".mean")]]   <- tf$mean[g]
      raw[[paste0("g", g, ".sd")]]     <- tf$sd[g]
    }
    if (anova) {
      cells$f    <- paste0(num(m$f), if (!p_shown) star(m$p))
      cells$eta2 <- num(m$eta_squared, TRUE)
      raw$f <- m$f; raw$eta2 <- m$eta_squared
    } else {
      cells$t    <- paste0(num(m$t), if (!p_shown) star(m$p))
      cells$d    <- num(m$cohens_d)
      cells$diff <- num(m$mean_difference)
      cells$ci   <- if (is.na(m$ci_lower) || is.na(m$ci_upper)) "" else
        paste0("[", num(m$ci_lower), ", ", num(m$ci_upper), "]")
      cells$ci.lower <- num(m$ci_lower); cells$ci.upper <- num(m$ci_upper)
      raw$t <- m$t; raw$d <- m$cohens_d; raw$diff <- m$mean_difference
      raw$ci.lower <- m$ci_lower; raw$ci.upper <- m$ci_upper
    }
    cells$df <- df_txt[i]
    cells$p  <- pval(m$p)
    raw$p <- m$p
    list(kind = "data", label = olabs[i], indent = 0L,
         marks = if (is.null(roles$marks[[outs[i]]])) character(0)
                 else roles$marks[[outs[i]]],
         cells = cells[columns$key[-1L]], raw = raw)
  })

  # The notes: the groups' ns where n.position puts N (none when each
  # group's n is a column); the filter; a Welch or paired test; the user's
  # text; the stars' legend.
  npos <- key("n.position")
  gn <- do.call(rbind, lapply(terms, function(tf) as.numeric(tf$n)))
  Ns <- vapply(mods, function(m) as.numeric(m$n), numeric(1))
  general <- character(0); n_title <- ""
  if (identical(npos, "note") && !"n" %in% g_keys) {
    if (all(apply(gn, 2L, function(x) length(unique(x)) == 1L))) {
      general <- paste0("*n* = ", .jst_and_list(paste0(count(gn[1L, ]), " (",
                                                       gnames, ")")), ".")
    } else {
      # Missing data are the cause only where every row had the same
      # filter; rows filtered differently vary for that reason too.
      lo <- apply(gn, 2L, min); hi <- apply(gn, 2L, max)
      rng <- ifelse(lo == hi, count(lo), paste0(count(lo), " to ", count(hi)))
      ftxt <- vapply(results, .jst_table_filter_text, character(1))
      general <- paste0("Group *n*s vary",
                        if (length(unique(ftxt)) == 1L) " with missing data",
                        ": ", paste0(gnames, ", ", rng, collapse = "; "), ".")
    }
  } else if (identical(npos, "title")) {
    n_title <- if (length(unique(Ns)) == 1L) paste0(" (*N* = ", count(Ns[1L]), ")")
               else " (*N* differs by variable)"
  }
  general <- c(general, .jst_table_filter_note(results, olabs, style, type))
  if (identical(key("test.note"), "yes")) {
    tt <- vapply(mods, function(m) as.character(m$test_type), character(1))
    one_w <- if (anova) "analysis of variance" else "*t* test"
    many_w <- if (anova) "analyses of variance" else "*t* tests"
    subject <- function(hit) {
      if (all(hit)) {
        paste("The", if (nr == 1L) one_w else many_w)
      } else {
        paste0("The ", if (sum(hit) == 1L) one_w else many_w, " for ",
               .jst_and_list(olabs[hit]))
      }
    }
    welch <- tt == "welch"
    if (any(welch)) {
      general <- c(general, paste0(subject(welch),
                                   " did not assume equal variances (Welch's ",
                                   if (anova) "*F*" else "*t*", " test)."))
    }
    paired <- tt == "paired"
    if (any(paired)) {
      single <- if (all(paired)) nr == 1L else sum(paired) == 1L
      general <- c(general, paste0(
        subject(paired), if (single) " is a paired-samples test"
                         else " are paired-samples tests",
        if ("d" %in% s_keys) "; *d* is Cohen's *d*z, computed from the differences",
        "."))
    }
  }
  if (!is.null(note)) general <- c(general, note)

  .jst_table_new(
    type     = type,
    columns  = columns,
    rows     = rows,
    caption  = list(number = NA_integer_,
                    title  = paste0(
                      if (is.null(title)) gsub("{group}", glab, key("title"),
                                               fixed = TRUE)
                      else title,
                      n_title)),
    notes    = list(general = general, specific = roles$specific,
                    probability = if (use_stars) .jst_tbl_stars_legend(stars, key("leading.zero"))
                                  else character(0)),
    spanners = spanners,
    style    = style)
}


# -----------------------------------------------------------------------------
# 4g. The crosstab (jcrosstab() results; build 4)
# -----------------------------------------------------------------------------
#
# The reference, Part 1, lean 4: each row variable's label a row of its
# own, its categories indented under it (the frequency table's form), the
# column variable's categories across the top under its label, each with n
# and the percentage within the group, and a Total; the chi-square test on
# each variable's label row -- chi2, df, p and Cramer's V -- computed from
# the stored counts (the Pearson test jcrosstab() reports, so a result made
# without chisq = TRUE has it too). Crosstabs of one column variable stack
# (ruling R54).

# A jcrosstab() result: one result, built as a list of one.
.jst_table_build.jst_crosstab <- function(x, style, headings = NULL,
                                          markers = NULL, title = NULL,
                                          note = NULL, ...) {
  .jst_table_build_crosstab(list(x), style, headings, markers, title, note)
}

#' Internal helper: the crosstab from one or more jcrosstab() results
#'
#' @param results A list of jst_crosstab results, one column variable.
#' @inheritParams .jst_table_build
#' @return A jst_table.
#' @keywords internal
.jst_table_build_crosstab <- function(results, style, headings = NULL,
                                      markers = NULL, title = NULL,
                                      note = NULL) {
  type  <- "crosstab"
  key   <- function(k) .jst_style_key(style, type, k)
  dec   <- key("decimals"); thou <- key("thousands"); minus <- key("minus")
  lzs   <- key("leading.zero"); pfmt <- key("p.format"); pdec <- key("p.decimals")
  stars <- key("stars")
  num   <- function(x, bounded = FALSE) {
    .jst_tbl_num(x, dec, thou, .jst_tbl_lz(lzs, bounded), minus)
  }
  pct   <- function(x) .jst_tbl_num(x, key("percent.decimals"), thou,
                                    .jst_tbl_lz(lzs, FALSE), minus)
  pval  <- function(p) .jst_tbl_p(p, pfmt, pdec, stars, .jst_tbl_lz(lzs, TRUE))
  count <- function(n) .jst_tbl_count(n, thou)
  use_stars <- !identical(pfmt, "exact")
  .jst_table_no_headings(headings, type, "its variables in the order given")

  for (r in results) {
    if (is.null(attr(r, "jstats_version", exact = TRUE)) || is.null(r$observed) ||
        is.null(r$row_categories) || is.null(r$col_categories)) {
      .jst_table_old_stop(r, "jcrosstab()")
    }
  }
  vname <- function(cats) unname(attr(cats, "variable")["name"])
  # One column variable with one set of categories (ruling R54); jtable()
  # sorts its results before a builder sees them (ruling R56, Session 406).
  cvars <- vapply(results, function(r) vname(r$col_categories), character(1))
  cc <- results[[1L]]$col_categories
  ccodes <- lapply(results, function(r) as.character(r$col_categories$code))
  if (length(unique(cvars)) > 1L ||
      !all(vapply(ccodes, identical, logical(1), ccodes[[1L]]))) {
    stop(".jst_table_build_crosstab(): results of different column variables",
         call. = FALSE)
  }
  rvars <- vapply(results, function(r) vname(r$row_categories), character(1))
  .jst_table_once(rvars)
  rlabs <- vapply(seq_along(results), function(i) {
    .jst_table_var_label(attr(results[[i]]$row_categories, "variable"), rvars[i])
  }, character(1))
  glab   <- .jst_table_var_label(attr(cc, "variable"), cvars[1L])
  gnames <- .jst_table_cat_names(cc$code, cc$label)
  ng <- length(gnames)

  # The columns: each group's (n, percent), the Total's, then the test's.
  g_keys <- key("columns")
  tot    <- identical(key("total"), "yes")
  tests  <- key("test.columns")
  if (identical(tests, "none")) tests <- character(0)
  columns <- data.frame(key = "stub", label = key("stub.label"), kind = "text",
                        italic = FALSE, stringsAsFactors = FALSE)
  add_col <- function(k, lab, ital) {
    columns <<- rbind(columns, data.frame(key = k, label = lab, kind = "number",
                                          italic = ital, stringsAsFactors = FALSE))
  }
  rowB <- list(); pos <- 1L
  for (g in c(seq_len(ng), if (tot) 0L)) {
    from <- pos + 1L
    for (k in g_keys) {
      lab <- key(paste0(k, ".label"))
      add_col(paste0(if (g) paste0("g", g) else "tot", ".", k), lab,
              .jst_tbl_head_italic(type, k, lab))
      pos <- pos + 1L
    }
    rowB[[length(rowB) + 1L]] <- list(label = if (g) gnames[g] else key("total.label"),
                                      from = from, to = pos)
    if (g == ng) g_end <- pos
  }
  for (k in tests) {
    lab <- key(paste0(k, ".label"))
    add_col(k, lab, .jst_tbl_head_italic(type, k, lab))
    pos <- pos + 1L
  }
  rownames(columns) <- NULL
  spanners <- list()
  if (identical(key("group.spanner"), "yes")) {
    spanners <- c(spanners, list(list(list(label = glab, from = 2L, to = g_end))))
  }
  spanners <- c(spanners, list(rowB))
  num_keys <- columns$key[-1L]

  # The rows: each variable's label row, carrying its test; its categories
  # indented under it. The percentages within each group (percent.base =
  # column), each category (row) or all cases (total).
  base  <- key("percent.base")
  roles <- .jst_table_roles(rvars, rep(NA_character_, length(rvars)), NULL,
                            markers, key("marks"))
  rows <- list(); Ns <- numeric(0)
  blank <- stats::setNames(as.list(rep("", length(num_keys))), num_keys)
  for (i in seq_along(results)) {
    r   <- results[[i]]
    obs <- unclass(r$observed)
    obs <- obs[, match(as.character(cc$level), colnames(obs)), drop = FALSE]
    rc  <- r$row_categories[match(rownames(obs), r$row_categories$level), ,
                            drop = FALSE]
    N  <- sum(obs); Ns <- c(Ns, N)
    cs <- colSums(obs); rs <- rowSums(obs)
    # The Pearson chi-square test from the counts, without Yates's
    # correction (the test jcrosstab(chisq = TRUE) reports).
    tcell <- blank[intersect(tests, num_keys)]
    if (length(tests) && nrow(obs) >= 2L && ncol(obs) >= 2L) {
      ct <- suppressWarnings(stats::chisq.test(obs, correct = FALSE))
      x2 <- unname(ct$statistic); df <- unname(ct$parameter); p <- ct$p.value
      if (is.finite(x2)) {
        v <- sqrt(x2 / (N * (min(dim(obs)) - 1L)))
        tcell <- list(chisq = paste0(num(x2), if (use_stars && !"p" %in% tests)
                                                .jst_tbl_stars(p, stars)),
                      df = formatC(round(df), format = "d"), p = pval(p),
                      v = num(v, TRUE))[tests]
      }
    }
    lab_cells <- blank; lab_cells[names(tcell)] <- tcell
    rows[[length(rows) + 1L]] <- list(
      kind = "data", level = "variable", label = rlabs[i], indent = 0L,
      marks = if (is.null(roles$marks[[rvars[i]]])) character(0)
              else roles$marks[[rvars[i]]],
      cells = lab_cells, raw = list())
    cat_names <- .jst_table_cat_names(rc$code, rc$label)
    for (a in seq_len(nrow(obs))) {
      cells <- blank
      for (g in seq_len(ng)) {
        den <- switch(base, column = cs[g], row = rs[a], total = N)
        cells[[paste0("g", g, ".n")]]       <- count(obs[a, g])
        cells[[paste0("g", g, ".percent")]] <- if (den > 0) pct(100 * obs[a, g] / den)
                                               else ""
      }
      if (tot) {
        den <- if (identical(base, "row")) rs[a] else N
        cells[["tot.n"]]       <- count(rs[a])
        cells[["tot.percent"]] <- if (den > 0) pct(100 * rs[a] / den) else ""
      }
      rows[[length(rows) + 1L]] <- list(
        kind = "data", label = cat_names[a], indent = 1L, marks = character(0),
        cells = cells[num_keys], raw = list(n = as.numeric(obs[a, ])))
    }
  }

  # The notes: N where n.position puts it (each variable's when they
  # differ); the filter; the user's text; the stars' legend when the test's
  # p-values carry them.
  nb <- .jst_table_n_by(Ns, rlabs, "variable", thou)
  np <- .jst_table_n_parts(key("n.position"), nb$note, nb$title)
  general <- c(np$note, .jst_table_filter_note(results, rlabs, style, type))
  if (!is.null(note)) general <- c(general, note)

  .jst_table_new(
    type     = type,
    columns  = columns,
    rows     = rows,
    caption  = list(number = NA_integer_,
                    title  = paste0(
                      if (is.null(title)) gsub("{group}", glab, key("title"),
                                               fixed = TRUE)
                      else title,
                      np$title)),
    notes    = list(general = general, specific = roles$specific,
                    probability = if (use_stars && any(c("chisq", "p") %in% tests))
                                    .jst_tbl_stars_legend(stars, key("leading.zero"))
                                  else character(0)),
    spanners = spanners,
    style    = style)
}


# -----------------------------------------------------------------------------
# 4h. The reliability table (jalpha() results; build 4)
# -----------------------------------------------------------------------------
#
# The reference, Part 1, lean 5: one row per item, named by its label (the
# item's wording), with M, SD, the corrected item-total correlation and
# alpha if the item is deleted; N and Cronbach's alpha in the general
# note. Several scales stack, each under its name -- a named list's names,
# else "Scale 1", "Scale 2" -- with its alpha after the name.

# A jalpha() result: one result, built as a list of one.
.jst_table_build.jst_alpha <- function(x, style, headings = NULL,
                                       markers = NULL, title = NULL,
                                       note = NULL, ...) {
  .jst_table_build_alpha(list(x), style, headings, markers, title, note)
}

#' Internal helper: the reliability table from one or more jalpha() results
#'
#' @param results A list of jst_alpha results; names are the scales'.
#' @inheritParams .jst_table_build
#' @return A jst_table.
#' @keywords internal
.jst_table_build_alpha <- function(results, style, headings = NULL,
                                   markers = NULL, title = NULL, note = NULL) {
  type <- "reliability"
  key  <- function(k) .jst_style_key(style, type, k)
  dec  <- key("decimals"); thou <- key("thousands"); minus <- key("minus")
  lzs  <- key("leading.zero")
  num  <- function(x, bounded = FALSE) {
    .jst_tbl_num(x, dec, thou, .jst_tbl_lz(lzs, bounded), minus)
  }
  .jst_table_no_headings(headings, type, "each scale's items in their order")

  ns <- length(results)
  terms <- vector("list", ns); mods <- vector("list", ns)
  for (i in seq_len(ns)) {
    r  <- results[[i]]
    tf <- .jst_apa_terms(r); md <- .jst_apa_model(r)
    if (is.null(attr(r, "jstats_version", exact = TRUE)) || is.null(tf) ||
        is.null(md)) {
      .jst_table_old_stop(r, "jalpha()")
    }
    terms[[i]] <- tf; mods[[i]] <- md
  }
  items <- unlist(lapply(terms, function(tf) as.character(tf$item)))
  .jst_table_once(items)
  # The scales' names: a named list's, else "Scale 1", "Scale 2", ... when
  # there are several; one scale given alone has none.
  nms   <- names(results)
  named <- !is.null(nms) && any(nzchar(nms))
  heads <- NULL
  if (ns > 1L || named) {
    heads <- paste("Scale", seq_len(ns))
    if (named) heads[nzchar(nms)] <- nms[nzchar(nms)]
  }
  alpha_on <- identical(key("alpha"), "yes")

  col_keys <- key("columns")
  col_labs <- vapply(col_keys, function(k) key(paste0(k, ".label")), character(1),
                     USE.NAMES = FALSE)
  columns <- data.frame(
    key    = c("stub", col_keys),
    label  = c(key("stub.label"), col_labs),
    kind   = c("text", rep("number", length(col_keys))),
    italic = c(FALSE, .jst_tbl_head_italic(type, col_keys, col_labs)),
    stringsAsFactors = FALSE, row.names = NULL)

  roles <- .jst_table_roles(items, rep(NA_character_, length(items)), NULL,
                            markers, key("marks"))
  rows <- list()
  for (s in seq_len(ns)) {
    tf <- terms[[s]]; md <- mods[[s]]
    if (!is.null(heads)) {
      rows[[length(rows) + 1L]] <- list(
        kind = "heading", level = "group",
        label = paste0(heads[s], if (alpha_on) paste0(" (\u03b1 = ",
                                                      num(md$alpha, TRUE), ")")),
        indent = 0L, marks = character(0), cells = list(), raw = list())
    }
    for (j in seq_len(nrow(tf))) {
      it  <- as.character(tf$item[j])
      lab <- if (is.na(tf$label[j]) || !nzchar(tf$label[j])) it else tf$label[j]
      raw <- list(mean = tf$mean[j], sd = tf$sd[j], item.total = tf$item_total_r[j],
                  alpha.if.deleted = tf$alpha_if_deleted[j])
      cells <- list(mean = num(raw$mean), sd = num(raw$sd),
                    item.total = num(raw$item.total, TRUE),
                    alpha.if.deleted = num(raw$alpha.if.deleted, TRUE))
      rows[[length(rows) + 1L]] <- list(
        kind = "data", label = lab, indent = if (is.null(heads)) 0L else 1L,
        marks = if (is.null(roles$marks[[it]])) character(0) else roles$marks[[it]],
        cells = cells[col_keys], raw = raw[col_keys])
    }
  }

  # The notes: N where n.position puts it (each scale's when they differ);
  # the filter; the one scale's alpha; what item-total r is; the user's
  # text.
  Ns <- vapply(mods, function(m) as.numeric(m$n_used), numeric(1))
  snames <- if (is.null(heads)) "the scale" else heads
  nb <- .jst_table_n_by(Ns, snames, "scale", thou)
  np <- .jst_table_n_parts(key("n.position"), nb$note, nb$title)
  general <- c(np$note, .jst_table_filter_note(results, snames, style, type))
  if (alpha_on && is.null(heads)) {
    general <- c(general, paste0("Cronbach's \u03b1 = ", num(mods[[1L]]$alpha, TRUE),
                                 "."))
  }
  if (identical(key("item.total.note"), "yes") && "item.total" %in% col_keys) {
    general <- c(general, paste0(key("item.total.label"), " is each item's ",
                                 "correlation with the sum of the other items."))
  }
  if (!is.null(note)) general <- c(general, note)

  .jst_table_new(
    type     = type,
    columns  = columns,
    rows     = rows,
    caption  = list(number = NA_integer_,
                    title  = paste0(if (is.null(title)) key("title") else title,
                                    np$title)),
    notes    = list(general = general, specific = roles$specific,
                    probability = character(0)),
    style    = style)
}


# -----------------------------------------------------------------------------
# 5. The preview writer
# -----------------------------------------------------------------------------
#
# A facsimile of the Word table for the console (ruling R47): the caption,
# the rules (top, under the header, bottom), the header centered over each
# column, the labels flush left and indented under a heading, the numbers
# aligned on the decimal point, the notes under the bottom rule. What the
# console cannot show it leaves out: italics, bold and colour; a specific
# note's mark is written ^a after the label and before its note. The minus
# sign is the hyphen here and the minus sign in the file.

#' Internal helper: print a table structure to the console
#'
#' @param tbl A jst_table.
#' @param style The style list.
#' @param number The table's number for the caption; 1 for a table on its
#'   own.
#' @keywords internal
.jst_table_preview <- function(tbl, style, number = 1L) {
  type <- tbl$type
  key  <- function(k) .jst_style_key(style, type, k)
  cols <- tbl$columns
  nc   <- nrow(cols)
  # The console takes ASCII: the minus sign becomes a hyphen.
  txt <- function(s) gsub("\u2212", "-", s, fixed = TRUE)

  # The stub column's text: a heading, or a label with its marks and its
  # indent; a fit row's label carries markup, stripped here.
  stub <- vapply(tbl$rows, function(r) {
    paste0(strrep(" ", 2L * r$indent),
           txt(if (isTRUE(r$markup)) .jst_table_strip_markup(r$label) else r$label),
           if (length(r$marks)) paste0(.jst_table_mark_text(r$marks), collapse = "")
           else "",
           if (is.null(r$tail)) "" else txt(r$tail))
  }, character(1))
  # The number columns: whole part and tail (the point and what follows),
  # so the cells align on the point as a decimal tab aligns them.
  body <- lapply(seq_len(nc)[-1L], function(j) {
    k <- cols$key[j]
    vapply(tbl$rows, function(r) {
      if (identical(r$kind, "heading")) "" else txt(r$cells[[k]])
    }, character(1))
  })
  # A number may open on a sign, a "<" (p's floor) or a "[" (a confidence
  # interval), and may have no digit before the point (".38"): the head
  # is everything before the point, so the points line up as the decimal
  # tab lines them up in the file, and the "<" hangs to the left. A cell
  # with no point -- a count, an ANOVA's "3, 99", an em dash -- ends where
  # the point would be, as Word sets text with no decimal point on a
  # decimal tab (Session 405).
  split_num <- function(s) {
    is_num <- grepl("^[<>\\[]?[-+]?([0-9]|\\.[0-9])", s) & grepl(".", s, fixed = TRUE)
    head <- ifelse(is_num, sub("^([<>\\[]?[-+]?[0-9,]*)(.*)$", "\\1", s), s)
    tail <- ifelse(is_num, sub("^([<>\\[]?[-+]?[0-9,]*)(.*)$", "\\2", s), "")
    list(head = head, tail = tail)
  }
  parts  <- lapply(body, split_num)
  # A head's markup ("*t*(101)") is the file's; the console shows the text.
  heads  <- .jst_table_strip_markup(cols$label)
  # A spanning cell (a fit row's, across its model's columns): its whole
  # part sets the column's width with the other cells', its tail runs on
  # past the column, so the tail is left out here.
  span_from <- function(r, j) {
    if (is.null(r$span)) return(FALSE)
    any(vapply(r$span, function(sp) sp[1L] == j, logical(1)))
  }
  spanning <- vapply(seq_len(nc), function(j) {
    vapply(tbl$rows, span_from, logical(1), j = j)
  }, logical(length(tbl$rows)))
  spanning <- matrix(spanning, nrow = length(tbl$rows))
  # A plain cell -- an em dash, an ANOVA's df -- is centered in its column
  # and does not set where the point falls (Session 405).
  plain <- lapply(seq_len(nc)[-1L], function(j) {
    .jst_tbl_plain_cell(body[[j - 1L]], cols$kind[j])
  })
  widths <- integer(nc)
  widths[1L] <- max(.jst_dw(heads[1L]), .jst_dw(stub), 0L)
  hws <- integer(nc); tws <- integer(nc)
  for (j in seq_len(nc)[-1L]) {
    p  <- parts[[j - 1L]]
    pl <- plain[[j - 1L]]
    hw <- max(.jst_dw(p$head[!pl]), 0L)
    tw <- max(.jst_dw(p$tail[!spanning[, j] & !pl]), 0L)
    hws[j] <- hw; tws[j] <- tw
    widths[j] <- max(.jst_dw(heads[j]), hw + tw, .jst_dw(body[[j - 1L]][pl]), 0L)
  }
  gap <- "  "
  # A spanner's label wider than its columns spreads the difference over
  # them, as the Word writer does (Session 405: the column variable's label
  # over a crosstab's groups ran past the rule).
  for (srow in tbl$spanners) for (sp in srow) {
    need <- .jst_dw(sp$label)
    have <- sum(widths[sp$from:sp$to]) + 2L * (sp$to - sp$from)
    if (need > have) {
      k <- sp$to - sp$from + 1L
      add <- rep((need - have) %/% k, k)
      add[seq_len((need - have) %% k)] <- add[seq_len((need - have) %% k)] + 1L
      widths[sp$from:sp$to] <- widths[sp$from:sp$to] + add
    }
  }
  for (i in seq_along(tbl$rows)) {
    for (sp in tbl$rows[[i]]$span) {
      from <- sp[1L]; to <- sp[2L]
      p <- parts[[from - 1L]]
      need <- widths[from] - tws[from] + .jst_dw(p$tail[i])
      have <- sum(widths[from:to]) + 2L * (to - from)
      if (need > have) widths[to] <- widths[to] + (need - have)
    }
  }
  total <- sum(widths) + 2L * (nc - 1L)
  rule  <- strrep("-", total)
  pad_l <- function(s, w) paste0(s, strrep(" ", pmax(0L, w - .jst_dw(s))))
  pad_r <- function(s, w) paste0(strrep(" ", pmax(0L, w - .jst_dw(s))), s)
  ctr   <- function(s, w) {
    extra <- pmax(0L, w - .jst_dw(s)); left <- extra - extra %/% 2L
    paste0(strrep(" ", left), s, strrep(" ", extra - left))
  }
  emit <- function(line) cat(sub("[ ]+$", "", line), "\n", sep = "")

  # The caption (its title's markup -- the N a style puts there -- stripped).
  form  <- key("caption.form")
  cap   <- paste0("Table ", number)
  ttl   <- txt(.jst_table_strip_markup(tbl$caption$title))
  if (identical(form, "apa")) {
    cat(cap, "\n", ttl, "\n", sep = "")
  } else if (identical(form, "report")) {
    cat(cap, ": ", ttl, "\n", sep = "")
  } else {
    cat(cap, ". ", ttl, "\n", sep = "")
  }
  emit(rule)
  # Spanners, each row centered over its columns: a list of rows, the top
  # row first (the models, then a confidence interval's LL and UL).
  for (srow in tbl$spanners) {
    line <- ""
    at <- 1L
    for (sp in srow) {
      from <- sp$from; to <- sp$to
      w <- sum(widths[from:to]) + 2L * (to - from)
      lead <- if (from > at) sum(widths[at:(from - 1L)]) + 2L * (from - at) else 0L
      line <- paste0(line, strrep(" ", lead), ctr(sp$label, w), gap)
      at <- to + 1L
    }
    emit(line)
  }
  # The header: the stub head flush left, the rest centered.
  emit(paste(c(pad_l(heads[1L], widths[1L]),
               vapply(seq_len(nc)[-1L], function(j) ctr(heads[j], widths[j]),
                      character(1))), collapse = gap))
  emit(rule)
  # The rows; a spanning cell laid across its columns, on the first's
  # point.
  for (i in seq_along(tbl$rows)) {
    cells <- pad_l(stub[i], widths[1L])
    j <- 2L
    while (j <= nc) {
      p  <- parts[[j - 1L]]
      hw <- hws[j]; tw <- tws[j]
      to <- j
      for (sp in tbl$rows[[i]]$span) if (sp[1L] == j) to <- sp[2L]
      if (to > j) {
        cell <- paste0(strrep(" ", widths[j] - hw - tw), pad_r(p$head[i], hw),
                       p$tail[i])
        cells <- c(cells, pad_l(cell, sum(widths[j:to]) + 2L * (to - j)))
      } else if (plain[[j - 1L]][i]) {
        cells <- c(cells, ctr(body[[j - 1L]][i], widths[j]))
      } else {
        cell <- paste0(pad_r(p$head[i], hw), pad_l(p$tail[i], tw))
        cells <- c(cells, pad_r(cell, widths[j]))
      }
      j <- to + 1L
    }
    emit(paste(cells, collapse = gap))
  }
  emit(rule)
  # The notes, each kind on its own line, wrapped at the message width.
  notes <- .jst_table_note_lines(tbl, style, plain = TRUE)
  for (ln in notes) .jst_msg_out(ln)
  cat("\n")
  invisible(NULL)
}

#' Internal helper: a mark as the console shows it
#'
#' A letter is written ^a, since a plain letter after a label would read
#' as part of it; a symbol (a dagger) is unmistakable and is written bare.
#'
#' @param marks Character; the marks.
#' @keywords internal
.jst_table_mark_text <- function(marks) {
  ifelse(grepl("^[a-z]+$", marks), paste0("^", marks), marks)
}

#' Internal helper: the note lines of a table, as marked-up text
#'
#' One string per line: the general note (the style's label, then the
#' sentences), the specific notes (each mark and its text), the
#' probability note. The light markup the Word writer reads -- *italic*
#' and ^superscript^ -- is kept, or stripped for the console.
#'
#' @param tbl A jst_table.
#' @param style The style list.
#' @param plain Logical; TRUE strips the markup for the console, where a
#'   mark is written ^a.
#' @return Character vector, possibly empty.
#' @keywords internal
.jst_table_note_lines <- function(tbl, style, plain = FALSE) {
  key  <- function(k) .jst_style_key(style, tbl$type, k)
  out  <- character(0)
  gen  <- tbl$notes$general
  if (length(gen)) {
    # The label in italics unless note.label.italic = no (Session 409,
    # ruling R58: report's upright "Note:"); an empty label is no label --
    # until Session 409 it left a pair of asterisks, "** N = 103.", that
    # the Word file and the console printed as marks.
    lab <- key("note.label")
    lead <- if (!nzchar(trimws(lab))) ""
            else if (identical(key("note.label.italic"), "no")) paste0(lab, " ")
            else paste0("*", lab, "* ")
    out <- c(out, paste0(lead, paste(gen, collapse = " ")))
  }
  if (length(tbl$notes$specific)) {
    out <- c(out, paste(vapply(tbl$notes$specific, function(s) {
      paste0("^", s$mark, "^ ", s$text,
             if (!grepl("[.!?]$", s$text)) ".")
    }, character(1)), collapse = " "))
  }
  if (length(tbl$notes$probability)) {
    out <- c(out, paste(tbl$notes$probability, collapse = " "))
  }
  if (plain) {
    out <- gsub("\\^([a-z]+)\\^", "^\\1", out)
    out <- .jst_table_strip_markup(out)
    out <- gsub("\u2212", "-", out, fixed = TRUE)
  }
  out
}

#' Internal helper: is a cell set centered rather than on its decimal tab?
#'
#' A cell of a text column (an ANOVA's df, "3, 99") or a cell with no digit
#' (a correlation's em dash): both Word and LibreOffice need a number on a
#' decimal tab, and LibreOffice sets other text from the tab rightward
#' (Session 405).
#'
#' @param s Character; the cells.
#' @param kind The column's kind ("number" or "text").
#' @return Logical, one per cell.
#' @keywords internal
.jst_tbl_plain_cell <- function(s, kind = "number") {
  identical(kind, "text") | (nzchar(s) & !grepl("[0-9]", s))
}

#' Internal helper: does a text carry the light markup?
#'
#' @param x Character.
#' @return Logical.
#' @keywords internal
.jst_tbl_markup <- function(x) grepl("\\*[^*]+\\*|\\^[^^]+\\^", x)

#' Internal helper: strip the light markup for the console
#'
#' \code{*italic*} and \code{^superscript^} lose their marks; the text
#' stays.
#'
#' @param x Character vector.
#' @keywords internal
.jst_table_strip_markup <- function(x) {
  x <- gsub("\\^([^^]+)\\^", "\\1", x)
  gsub("\\*([^*]+)\\*", "\\1", x)
}


# -----------------------------------------------------------------------------
# 6. The Word writer
# -----------------------------------------------------------------------------
#
# The small part of Word's format a table needs (the reference, Part 5),
# packed by zip::zip() into the five parts Word, LibreOffice and Google
# Docs all open: [Content_Types].xml, _rels/.rels, word/_rels/
# document.xml.rels, word/document.xml and word/styles.xml. The package
# layer takes a LIST of parts, so a later part (a figure, a second
# document) adds to the list.
#
# Measures are in twentieths of a point (dxa): 1440 to the inch, 20 to the
# point. A column's width is estimated from its widest text at the style's
# font size (a digit half an em, a letter a little less), plus the cell
# margins. Numbers sit on a DECIMAL TAB STOP in the cell's paragraph with
# NO tab character: Word aligns a cell's text on its decimal tab by
# itself, and so does LibreOffice; a tab character written before the
# number made LibreOffice tab past the stop and wrap the number onto a
# second line (Session 400).

.jst_docx_ns <- "http://schemas.openxmlformats.org/wordprocessingml/2006/main"

#' Internal helper: escape text for XML
#' @keywords internal
.jst_xml_esc <- function(x) {
  x <- gsub("&", "&amp;", x, fixed = TRUE)
  x <- gsub("<", "&lt;", x, fixed = TRUE)
  x <- gsub(">", "&gt;", x, fixed = TRUE)
  x <- gsub("\"", "&quot;", x, fixed = TRUE)
  x
}

#' Internal helper: one run of text
#'
#' @param text The text; "" gives an empty run.
#' @param bold,italic,superscript Logical.
#' @param color A six-digit hex colour, or NULL.
#' @param size Points, or NULL for the document default.
#' @param tab Logical; TRUE writes a tab character before the text.
#' @keywords internal
.jst_docx_run <- function(text, bold = FALSE, italic = FALSE,
                          superscript = FALSE, color = NULL, size = NULL,
                          tab = FALSE) {
  rpr <- c(if (bold) "<w:b/>", if (italic) "<w:i/>",
           if (!is.null(color) && !identical(color, "000000"))
             paste0("<w:color w:val=\"", color, "\"/>"),
           if (!is.null(size)) paste0("<w:sz w:val=\"", size * 2, "\"/>",
                                      "<w:szCs w:val=\"", size * 2, "\"/>"),
           if (superscript) "<w:vertAlign w:val=\"superscript\"/>")
  paste0("<w:r>",
         if (length(rpr)) paste0("<w:rPr>", paste(rpr, collapse = ""), "</w:rPr>"),
         if (tab) "<w:tab/>",
         if (nzchar(text)) paste0("<w:t xml:space=\"preserve\">",
                                  .jst_xml_esc(text), "</w:t>"),
         "</w:r>")
}

#' Internal helper: the runs of a marked-up line
#'
#' Reads the light markup: *text* italic, ^text^ superscript. Under an
#' italic base (an apa caption's title) *text* is set upright, as a word
#' that would be italic is set inside italic text.
#'
#' @param s Character(1); the line.
#' @param size Points.
#' @param bold,italic Logical; the base style of the line (Session 403: a
#'   caption's title, a fit row's label).
#' @param color A six-digit hex colour, or NULL (Session 405: a column head
#'   with markup takes the header's colour).
#' @keywords internal
.jst_docx_markup_runs <- function(s, size = NULL, bold = FALSE, italic = FALSE,
                                  color = NULL) {
  out <- character(0)
  rest <- s
  while (nzchar(rest)) {
    m <- regexpr("\\*[^*]+\\*|\\^[^^]+\\^", rest)
    if (m < 0L) {
      out <- c(out, .jst_docx_run(rest, bold = bold, italic = italic,
                                  color = color, size = size))
      break
    }
    if (m > 1L) {
      out <- c(out, .jst_docx_run(substr(rest, 1L, m - 1L), bold = bold,
                                  italic = italic, color = color, size = size))
    }
    tok <- substr(rest, m, m + attr(m, "match.length") - 1L)
    inner <- substr(tok, 2L, nchar(tok) - 1L)
    out <- c(out, if (startsWith(tok, "*"))
      .jst_docx_run(inner, bold = bold, italic = !italic, color = color, size = size)
      else .jst_docx_run(inner, bold = bold, italic = italic, superscript = TRUE,
                         color = color, size = size))
    rest <- substr(rest, m + attr(m, "match.length"), nchar(rest))
  }
  paste(out, collapse = "")
}

#' Internal helper: one paragraph
#'
#' @param runs The runs' XML, pasted.
#' @param style A paragraph style id, or NULL.
#' @param jc "left", "center" or "right", or NULL.
#' @param ind Left indent in dxa, or NULL.
#' @param tab A decimal tab position in dxa, or NULL.
#' @param keep_next Logical.
#' @param spacing_after Points after the paragraph, or NULL.
#' @param line "single" or "double".
#' @param size Points, or NULL: the paragraph mark's size, which sets the
#'   height of an EMPTY cell -- given when a table is fitted to the page
#'   at a size below the document's, so an empty cell does not hold its
#'   row at the larger height (Session 403).
#' @keywords internal
.jst_docx_par <- function(runs, style = NULL, jc = NULL, ind = NULL,
                          tab = NULL, keep_next = FALSE,
                          spacing_after = NULL, line = "single", size = NULL) {
  ppr <- c(if (!is.null(style)) paste0("<w:pStyle w:val=\"", style, "\"/>"),
           if (keep_next) "<w:keepNext/>",
           if (!is.null(tab)) paste0("<w:tabs><w:tab w:val=\"decimal\" w:pos=\"",
                                     tab, "\"/></w:tabs>"),
           paste0("<w:spacing w:before=\"0\" w:after=\"",
                  if (is.null(spacing_after)) 0 else spacing_after * 20,
                  "\" w:line=\"", if (identical(line, "double")) 480 else 240,
                  "\" w:lineRule=\"auto\"/>"),
           if (!is.null(ind)) paste0("<w:ind w:left=\"", ind, "\"/>"),
           if (!is.null(jc)) paste0("<w:jc w:val=\"", jc, "\"/>"),
           if (!is.null(size)) paste0("<w:rPr><w:sz w:val=\"", size * 2,
                                      "\"/><w:szCs w:val=\"", size * 2, "\"/></w:rPr>"))
  paste0("<w:p><w:pPr>", paste(ppr, collapse = ""), "</w:pPr>", runs, "</w:p>")
}

#' Internal helper: the caption's runs -- "Table 1" on Word's SEQ field
#'
#' @param number The cached number.
#' @param bold Logical.
#' @param size Points.
#' @param color A six-digit hex colour, or NULL (Session 409: a caption bar
#'   that follows the header takes the header's text colour).
#' @keywords internal
.jst_docx_seq_runs <- function(number, bold = TRUE, size = NULL, color = NULL) {
  col <- if (!is.null(color) && !identical(color, "000000"))
    paste0("<w:color w:val=\"", color, "\"/>")
  rpr <- paste0("<w:rPr>", if (bold) "<w:b/>", col,
                if (!is.null(size)) paste0("<w:sz w:val=\"", size * 2, "\"/>"),
                "</w:rPr>")
  paste0(.jst_docx_run("Table ", bold = bold, size = size, color = color),
         "<w:r>", rpr, "<w:fldChar w:fldCharType=\"begin\"/></w:r>",
         "<w:r>", rpr, "<w:instrText xml:space=\"preserve\"> SEQ Table \\* ARABIC </w:instrText></w:r>",
         "<w:r>", rpr, "<w:fldChar w:fldCharType=\"separate\"/></w:r>",
         .jst_docx_run(as.character(number), bold = bold, size = size, color = color),
         "<w:r>", rpr, "<w:fldChar w:fldCharType=\"end\"/></w:r>")
}

#' Internal helper: the width a caption row needs to keep its title on one line
#'
#' Session 407 (Jeff: "Frequency Distributions should be on a single
#' line"): under caption.position = row the caption is the table's first
#' row, so it wraps at the table's width; this is the width at which it
#' does not -- in apa's form the wider of the bold "Table 1" and the
#' italic title, in the journal's and the report's their one line -- in
#' the table's font at caption.size, with the cell margins. Zero for a
#' caption set as a paragraph, which runs the page's width.
#'
#' @param tbl A jst_table.
#' @param style The style list.
#' @param number The table's number.
#' @return Integer, dxa.
#' @keywords internal
.jst_docx_caption_width <- function(tbl, style, number) {
  key <- function(k) .jst_style_key(style, tbl$type, k)
  if (!identical(key("caption.position"), "row")) return(0L)
  form <- key("caption.form"); size <- key("caption.size"); font <- key("font")
  title <- tbl$caption$title
  title <- if (is.null(title)) "" else .jst_table_strip_markup(title)
  lab   <- paste0("Table ", number)
  tw <- function(s, bold = FALSE) .jst_docx_text_width(s, size, font = font, bold = bold)
  need <- if (identical(form, "apa")) max(tw(lab, TRUE), tw(title))
          else if (identical(form, "report")) tw(paste0(lab, ": ", title), TRUE)
          else tw(paste0(lab, "."), TRUE) + tw(paste0(" ", title))
  as.integer(need + 2L * 108L)
}

#' Internal helper: a table's columns widened to a width, in proportion
#'
#' Each column's share of the extra width follows its own width; what the
#' rounding leaves goes to the stub.
#'
#' @param w Integer, the column widths.
#' @param to The width wanted, dxa; never narrower than \code{sum(w)}.
#' @return Integer.
#' @keywords internal
.jst_docx_widen <- function(w, to) {
  if (to <= sum(w)) return(as.integer(w))
  out <- as.integer(floor(w * to / sum(w)))
  out[1L] <- out[1L] + as.integer(to - sum(out))
  out
}

#' Internal helper: the caption paragraphs of a table
#'
#' @param tbl A jst_table.
#' @param style The style list.
#' @param number The table's number.
#' @param color A six-digit hex colour for the caption's text, or NULL
#'   (Session 409: the header's text colour, on a caption bar that follows
#'   the header).
#' @return Character; one or two paragraphs' XML.
#' @keywords internal
.jst_docx_caption_pars <- function(tbl, style, number, color = NULL) {
  key  <- function(k) .jst_style_key(style, tbl$type, k)
  form <- key("caption.form"); size <- key("caption.size")
  # The title's markup: the N a style puts after it (n.position = title)
  # is "*N* = 103", N upright inside apa's italic title and italic in the
  # other forms.
  title <- tbl$caption$title
  if (identical(form, "apa")) {
    c(.jst_docx_par(.jst_docx_seq_runs(number, TRUE, size, color), style = "Caption",
                    keep_next = TRUE),
      .jst_docx_par(.jst_docx_markup_runs(title, size = size, italic = TRUE,
                                          color = color),
                    keep_next = TRUE, spacing_after = 6))
  } else if (identical(form, "report")) {
    .jst_docx_par(paste0(.jst_docx_seq_runs(number, TRUE, size, color),
                         .jst_docx_markup_runs(paste0(": ", title), size = size,
                                               bold = TRUE, color = color)),
                  style = "Caption", keep_next = TRUE, spacing_after = 6)
  } else {
    .jst_docx_par(paste0(.jst_docx_seq_runs(number, TRUE, size, color),
                         .jst_docx_run(".", bold = TRUE, size = size, color = color),
                         .jst_docx_markup_runs(paste0(" ", title), size = size,
                                               color = color)),
                  style = "Caption", keep_next = TRUE, spacing_after = 6)
  }
}

#' Internal helper: the note paragraphs of a table
#'
#' @param tbl A jst_table.
#' @param style The style list.
#' @param keep_next Logical; for a note inside a row.
#' @param size Points, or NULL for the style's note.size (a table fitted
#'   to the page steps it down with the table's size, Session 403).
#' @return Character; one paragraph per note line.
#' @keywords internal
.jst_docx_note_pars <- function(tbl, style, keep_next = FALSE, size = NULL) {
  if (is.null(size)) size <- .jst_style_key(style, tbl$type, "note.size")
  lines <- .jst_table_note_lines(tbl, style, plain = FALSE)
  vapply(lines, function(ln) {
    .jst_docx_par(.jst_docx_markup_runs(ln, size = size), keep_next = keep_next)
  }, character(1), USE.NAMES = FALSE)
}

#' Internal helper: the width a text needs in a cell, in dxa
#'
#' @param s Character; the texts.
#' @param size Points.
#' @param digits Logical; TRUE for a number column (a digit is about half
#'   an em), FALSE for text (a letter a little less).
#' @param font Character(1), or NULL: the face measured in (Session 407).
#' @param bold Logical; TRUE for bold text, which is up to about 8 percent
#'   wider than the same text upright (Arial's bold; Times's about 6).
#' @keywords internal
.jst_docx_text_width <- function(s, size, digits = FALSE, font = NULL,
                                 bold = FALSE) {
  em <- size * 20
  as.integer(ceiling(max(vapply(s, .jst_docx_em_width, numeric(1), font = font),
                         0) * em * (if (isTRUE(bold)) 1.08 else 1)))
}

# The advance widths of a serif text face, in thousandths of an em (the
# standard Times Roman metrics), for the width estimate. A character not
# listed is half an em; one the console shows two columns wide (Chinese,
# Japanese, Korean) a full em.
.jst_docx_char_widths <- c(
  a = 444, b = 500, c = 444, d = 500, e = 444, f = 333, g = 500, h = 500,
  i = 278, j = 278, k = 500, l = 278, m = 778, n = 500, o = 500, p = 500,
  q = 500, r = 333, s = 389, t = 278, u = 500, v = 500, w = 722, x = 500,
  y = 500, z = 444,
  A = 722, B = 667, C = 667, D = 722, E = 611, F = 556, G = 722, H = 722,
  I = 333, J = 389, K = 722, L = 611, M = 889, N = 722, O = 722, P = 556,
  Q = 722, R = 667, S = 556, T = 611, U = 722, V = 722, W = 944, X = 722,
  Y = 722, Z = 611,
  "0" = 500, "1" = 500, "2" = 500, "3" = 500, "4" = 500, "5" = 500,
  "6" = 500, "7" = 500, "8" = 500, "9" = 500,
  " " = 250, "." = 250, "," = 250, ":" = 278, ";" = 278, "-" = 333,
  "(" = 333, ")" = 333, "[" = 333, "]" = 333, "/" = 278, "%" = 833,
  "*" = 500, "=" = 564, "+" = 564, "<" = 564, ">" = 564, "'" = 333,
  "\"" = 408, "&" = 778, "!" = 333, "?" = 444, "_" = 500, "#" = 500)
# The minus sign, the dagger, the double dagger, the section sign, four
# Greek letters and the em dash (a correlation's diagonal, Session 405),
# named with names<-: a name written in a call is a symbol the parser
# makes in the session's own encoding (Session 390).
.jst_docx_char_widths <- c(
  .jst_docx_char_widths,
  stats::setNames(c(564, 500, 500, 500, 500, 500, 500, 500, 1000),
                  c("\u2212", "\u2020", "\u2021", "\u00a7",
                    "\u03b2", "\u03b7", "\u03b1", "\u03c7", "\u2014")))

# The same characters' advance widths in a sans serif face -- Arial's,
# which Helvetica and Liberation Sans share -- and in Calibri (Carlito's,
# which it shares), read from the fonts' own metrics at Session 407. Until
# then every table was measured in Times whatever its font, and a table in
# Arial, about a tenth wider, wrapped its labels in narrow columns (the
# Session 407 walk: "How we contacted you" over two lines at 11 pt).
.jst_docx_char_widths_sans <- c(a = 556, b = 556, c = 500, d = 556, e = 556,
  f = 278, g = 556, h = 556, i = 222, j = 222, k = 500, l = 222, m = 833,
  n = 556, o = 556, p = 556, q = 556, r = 333, s = 500, t = 278, u = 556,
  v = 500, w = 722, x = 500, y = 500, z = 500, A = 667, B = 667, C = 722,
  D = 722, E = 667, F = 611, G = 778, H = 722, I = 278, J = 500, K = 667,
  L = 556, M = 833, N = 722, O = 778, P = 667, Q = 778, R = 722, S = 667,
  T = 611, U = 722, V = 667, W = 944, X = 667, Y = 667, Z = 611, "0" = 556,
  "1" = 556, "2" = 556, "3" = 556, "4" = 556, "5" = 556, "6" = 556, "7" = 556,
  "8" = 556, "9" = 556, " " = 278, "." = 278, "," = 278, ":" = 278, ";" = 278,
  "-" = 333, "(" = 333, ")" = 333, "[" = 278, "]" = 278, "/" = 278, "%" = 889,
  "*" = 389, "=" = 584, "+" = 584, "<" = 584, ">" = 584, "'" = 191, "\"" = 355,
  "&" = 667, "!" = 278, "?" = 556, "_" = 556, "#" = 556)
.jst_docx_char_widths_sans <- c(
  .jst_docx_char_widths_sans,
  stats::setNames(c(584, 556, 556, 556, 575, 556, 578, 525, 1000),
                  c("\u2212", "\u2020", "\u2021", "\u00a7",
                    "\u03b2", "\u03b7", "\u03b1", "\u03c7", "\u2014")))
.jst_docx_char_widths_calibri <- c(a = 479, b = 525, c = 423, d = 525, e = 498,
  f = 305, g = 471, h = 525, i = 229, j = 239, k = 455, l = 229, m = 799,
  n = 525, o = 527, p = 525, q = 525, r = 349, s = 391, t = 335, u = 525,
  v = 452, w = 715, x = 433, y = 453, z = 395, A = 579, B = 544, C = 533,
  D = 615, E = 488, F = 459, G = 631, H = 623, I = 252, J = 319, K = 520,
  L = 420, M = 855, N = 646, O = 662, P = 517, Q = 673, R = 543, S = 459,
  T = 487, U = 642, V = 567, W = 890, X = 519, Y = 487, Z = 468, "0" = 507,
  "1" = 507, "2" = 507, "3" = 507, "4" = 507, "5" = 507, "6" = 507, "7" = 507,
  "8" = 507, "9" = 507, " " = 226, "." = 252, "," = 250, ":" = 268, ";" = 268,
  "-" = 306, "(" = 303, ")" = 303, "[" = 307, "]" = 307, "/" = 386, "%" = 715,
  "*" = 498, "=" = 498, "+" = 498, "<" = 498, ">" = 498, "'" = 221, "\"" = 401,
  "&" = 682, "!" = 326, "?" = 463, "_" = 498, "#" = 498)
.jst_docx_char_widths_calibri <- c(
  .jst_docx_char_widths_calibri,
  stats::setNames(c(498, 498, 498, 498, 531, 537, 567, 426, 905),
                  c("\u2212", "\u2020", "\u2021", "\u00a7",
                    "\u03b2", "\u03b7", "\u03b1", "\u03c7", "\u2014")))
# Any other font is measured generously: each character at the widest of
# the three faces, plus a tenth, so a label does not wrap in a face jstats
# has no metrics for (Verdana is wider still; Georgia and Cambria fit).
.jst_docx_char_widths_other <- ceiling(
  pmax(.jst_docx_char_widths,
       .jst_docx_char_widths_sans[names(.jst_docx_char_widths)],
       .jst_docx_char_widths_calibri[names(.jst_docx_char_widths)]) * 1.1)

#' Internal helper: the advance widths a table's font is measured in
#'
#' Times New Roman's for that face and the faces that share its metrics
#' (Times, Liberation Serif, Tinos), and for no font named (NULL: the
#' measure until Session 407); Arial's for Arial, Helvetica, Liberation
#' Sans and Arimo; Calibri's for Calibri and Carlito; for any other font the
#' generous table. The name is compared without regard to case or outer
#' spaces. The unknown-character width rides as the attribute "other": half
#' an em in Times, as before, and each face's digit width elsewhere.
#'
#' @param font Character(1), or NULL.
#' @return A named numeric vector, in thousandths of an em.
#' @keywords internal
.jst_docx_font_widths <- function(font = NULL) {
  f <- if (is.null(font) || is.na(font)) "" else tolower(trimws(font))
  w <- if (!nzchar(f) || f %in% c("times new roman", "times",
                                   "liberation serif", "tinos")) {
    structure(.jst_docx_char_widths, other = 500)
  } else if (f %in% c("arial", "helvetica", "liberation sans", "arimo")) {
    structure(.jst_docx_char_widths_sans, other = 556)
  } else if (f %in% c("calibri", "carlito")) {
    structure(.jst_docx_char_widths_calibri, other = 507)
  } else {
    structure(.jst_docx_char_widths_other, other = 612)
  }
  w
}

#' Internal helper: a text's width in ems, with a small allowance
#'
#' Measured in the face \code{font} names (\code{.jst_docx_font_widths()};
#' Session 407), Times New Roman when it names none.
#'
#' @param x Character(1).
#' @param font Character(1), or NULL.
#' @keywords internal
.jst_docx_em_width <- function(x, font = NULL) {
  if (is.na(x) || !nzchar(x)) return(0)
  tab <- .jst_docx_font_widths(font)
  ch <- strsplit(x, "", fixed = TRUE)[[1L]]
  w  <- tab[ch]
  w[is.na(w)] <- ifelse(.jst_dw(ch[is.na(w)]) > 1L, 1000, attr(tab, "other"))
  sum(w) / 1000 * 1.06
}

#' Internal helper: the page, in dxa
#'
#' @param paper "a4" or "letter".
#' @param landscape Logical.
#' @return A list: w, h (the page) and text (the text width between
#'   one-inch margins).
#' @keywords internal
.jst_docx_page <- function(paper, landscape) {
  size <- if (identical(paper, "letter")) c(12240L, 15840L) else c(11906L, 16838L)
  if (landscape) size <- rev(size)
  list(w = size[1L], h = size[2L], text = size[1L] - 2L * 1440L)
}

#' Internal helper: the cell borders for one cell under the style's rules
#'
#' @param rules "apa", "grid", "outer" or "none".
#' @param top,bottom,left,right Logical; the cell's edges that the rule set
#'   draws when it draws that kind of edge.
#' @param color Hex colour.
#' @keywords internal
.jst_docx_borders <- function(rules, top, bottom, left, right, color) {
  line <- function(on) if (on)
    paste0("<w:%s w:val=\"single\" w:sz=\"8\" w:space=\"0\" w:color=\"", color, "\"/>")
    else "<w:%s w:val=\"nil\"/>"
  paste0("<w:tcBorders>",
         sprintf(line(top), "top"), sprintf(line(left), "left"),
         sprintf(line(bottom), "bottom"), sprintf(line(right), "right"),
         "</w:tcBorders>")
}

#' Internal helper: one table cell
#'
#' @param pars The paragraphs' XML, pasted.
#' @param width dxa.
#' @param borders The tcBorders XML.
#' @param span Grid span, or NULL.
#' @param fill Hex colour, or NULL.
#' @keywords internal
.jst_docx_cell <- function(pars, width, borders, span = NULL, fill = NULL) {
  paste0("<w:tc><w:tcPr><w:tcW w:w=\"", width, "\" w:type=\"dxa\"/>",
         if (!is.null(span) && span > 1L) paste0("<w:gridSpan w:val=\"", span, "\"/>"),
         borders,
         if (!is.null(fill)) paste0("<w:shd w:val=\"clear\" w:color=\"auto\" w:fill=\"",
                                    fill, "\"/>"),
         "<w:vAlign w:val=\"bottom\"/></w:tcPr>", pars, "</w:tc>")
}

#' Internal helper: the table of a jst_table, as XML
#'
#' @param tbl A jst_table.
#' @param style The style list.
#' @param number The table's number (for a caption row).
#' @param widths Column widths in dxa.
#' @param size,note_size Points, or NULL for the style's size and
#'   note.size: a table fitted to the page passes the stepped-down sizes
#'   (Session 403).
#' @return Character(1); the w:tbl element.
#' @keywords internal
.jst_docx_table <- function(tbl, style, number, widths, size = NULL,
                            note_size = NULL) {
  type <- tbl$type
  key  <- function(k) .jst_style_key(style, type, k)
  cols <- tbl$columns; nc <- nrow(cols)
  if (is.null(size)) size <- key("size")
  # The paragraph mark's size, set only when the table is fitted below the
  # document's size, so the XML of an unfitted table is unchanged.
  msz  <- if (!identical(as.numeric(size), as.numeric(key("size")))) size else NULL
  line <- key("line.spacing")
  rules <- key("rules"); rcol <- key("rule.color")
  hfill <- key("header.fill"); bfill <- key("band.fill")
  hfill <- if (identical(hfill, "none")) NULL else hfill
  bfill <- if (identical(bfill, "none")) NULL else bfill
  htext <- key("header.text"); hbold <- identical(key("header.bold"), "yes")
  # The two fills of Session 409 (ruling R58): a caption bar -- a colour,
  # or "header": the header's fill with the header's text colour -- and a
  # fill for each variable's label row. Both "none" in apa and report, so
  # neither table's XML changes.
  cfill <- key("caption.fill"); cfill_text <- NULL
  if (identical(cfill, "header")) {
    cfill <- hfill
    if (!is.null(cfill)) cfill_text <- htext
  } else if (identical(cfill, "none")) {
    cfill <- NULL
  }
  vfill <- key("heading.fill")
  vfill <- if (identical(vfill, "none")) NULL else vfill
  cap_row  <- identical(key("caption.position"), "row")
  note_row <- identical(key("note.position"), "row")
  margin   <- 108L
  total    <- sum(widths)
  dec_tabs <- .jst_docx_decimal_tabs(tbl, widths, size, margin, font = key("font"))

  # Which rows draw which rules.
  draw_h <- !identical(rules, "none")              # the header's rules
  grid   <- identical(rules, "grid")
  outer  <- identical(rules, "outer")
  n_rows <- length(tbl$rows)

  rows_xml <- character(0)
  span_all <- function(pars, borders) {
    paste0("<w:tr><w:trPr><w:cantSplit/></w:trPr>",
           .jst_docx_cell(pars, total, borders, span = nc), "</w:tr>")
  }
  nil <- .jst_docx_borders("none", FALSE, FALSE, FALSE, FALSE, rcol)

  # A caption row: the caption's paragraphs, no borders, repeated with the
  # header when the table breaks across pages; filled when the style puts a
  # bar there (caption.fill, Session 409).
  if (cap_row) {
    pars <- paste(.jst_docx_caption_pars(tbl, style, number, color = cfill_text),
                  collapse = "")
    rows_xml <- c(rows_xml,
                  paste0("<w:tr><w:trPr><w:cantSplit/><w:tblHeader/></w:trPr>",
                         .jst_docx_cell(pars, total, nil, span = nc, fill = cfill),
                         "</w:tr>"))
  }

  # Spanner rows over the header (a regression table's models, then a
  # confidence interval's LL and UL): the top row carries the table's top
  # rule, each spanner a rule under its label; an empty cell where a row
  # spans nothing.
  for (si in seq_along(tbl$spanners)) {
    srow  <- tbl$spanners[[si]]
    top   <- draw_h && si == 1L
    cells <- character(0); at <- 1L
    for (sp in srow) {
      if (sp$from > at) {
        for (j in at:(sp$from - 1L)) {
          cells <- c(cells, .jst_docx_cell(
            .jst_docx_par("", keep_next = TRUE, line = line, size = msz), widths[j],
            .jst_docx_borders(rules, top, FALSE, grid || (outer && j == 1L),
                              grid || (outer && j == nc), rcol), fill = hfill))
        }
      }
      w <- sum(widths[sp$from:sp$to])
      cells <- c(cells, .jst_docx_cell(
        .jst_docx_par(.jst_docx_run(sp$label, bold = hbold, color = htext, size = size),
                      jc = "center", keep_next = TRUE, line = line, size = msz), w,
        .jst_docx_borders(rules, top, draw_h, grid || (outer && sp$from == 1L),
                          grid || (outer && sp$to == nc), rcol),
        span = sp$to - sp$from + 1L, fill = hfill))
      at <- sp$to + 1L
    }
    if (at <= nc) for (j in at:nc) {
      cells <- c(cells, .jst_docx_cell(
        .jst_docx_par("", keep_next = TRUE, line = line, size = msz), widths[j],
        .jst_docx_borders(rules, top, FALSE, grid || (outer && j == 1L),
                          grid || (outer && j == nc), rcol), fill = hfill))
    }
    rows_xml <- c(rows_xml, paste0("<w:tr><w:trPr><w:cantSplit/><w:tblHeader/></w:trPr>",
                                   paste(cells, collapse = ""), "</w:tr>"))
  }

  # The header row. A head may carry the light markup -- "*t*(101)",
  # "Item-total *r*" -- read over the column's italic setting (Session 405:
  # until then a head was wholly italic or wholly upright).
  cells <- vapply(seq_len(nc), function(j) {
    runs <- if (.jst_tbl_markup(cols$label[j])) {
      .jst_docx_markup_runs(cols$label[j], size = size, bold = hbold,
                            italic = cols$italic[j], color = htext)
    } else {
      .jst_docx_run(cols$label[j], bold = hbold, italic = cols$italic[j],
                    color = htext, size = size)
    }
    .jst_docx_cell(
      .jst_docx_par(runs, jc = if (j == 1L) "left" else "center",
                    keep_next = TRUE, line = line, size = msz),
      widths[j],
      .jst_docx_borders(rules, draw_h && !length(tbl$spanners), draw_h,
                        grid || (outer && j == 1L), grid || (outer && j == nc), rcol),
      fill = hfill)
  }, character(1))
  rows_xml <- c(rows_xml, paste0("<w:tr><w:trPr><w:cantSplit/><w:tblHeader/></w:trPr>",
                                 paste(cells, collapse = ""), "</w:tr>"))

  # The data and heading rows.
  band <- 0L
  has_note <- length(.jst_table_note_lines(tbl, style)) > 0L
  for (i in seq_len(n_rows)) {
    r    <- tbl$rows[[i]]
    last <- i == n_rows
    # Keep-with-next on every row holds the table together across a page
    # break; the last row keeps with the note that follows it, as a row or
    # a paragraph, and with nothing when there is none.
    keep <- !last || has_note
    bottom <- (last && draw_h) || grid
    fill <- NULL
    if (identical(r$kind, "heading")) {
      # A role heading takes group.headings; a variable's label row (a
      # frequency table's) takes variable.headings, its indent and its
      # marks.
      emph <- if (identical(r$level, "variable")) key("variable.headings")
              else key("group.headings")
      runs <- paste0(if (isTRUE(r$markup)) {
                       .jst_docx_markup_runs(r$label, size = size,
                                             bold = identical(emph, "bold"),
                                             italic = identical(emph, "italic"))
                     } else {
                       .jst_docx_run(r$label, bold = identical(emph, "bold"),
                                     italic = identical(emph, "italic"), size = size)
                     },
                     if (length(r$marks)) .jst_docx_run(paste(r$marks, collapse = ","),
                                                        superscript = TRUE, size = size),
                     if (!is.null(r$tail) && nzchar(r$tail))
                       .jst_docx_run(r$tail, bold = identical(emph, "bold"),
                                     italic = identical(emph, "italic"), size = size))
      borders <- .jst_docx_borders(rules, grid, bottom, grid || outer, grid || outer, rcol)
      # A variable's label row takes heading.fill (Session 409); a role
      # heading does not.
      rows_xml <- c(rows_xml, paste0(
        "<w:tr><w:trPr><w:cantSplit/></w:trPr>",
        .jst_docx_cell(.jst_docx_par(runs, ind = if (isTRUE(r$indent > 0L))
                                                   180L * r$indent else NULL,
                                     keep_next = keep, line = line, size = msz),
                       total, borders, span = nc,
                       fill = if (identical(r$level, "variable")) vfill),
        "</w:tr>"))
      next
    }
    band <- band + 1L
    if (!is.null(bfill) && band %% 2L == 0L) fill <- bfill
    # A variable's label row that carries cells (a crosstab's, with its
    # test) takes heading.fill across the row, in place of a band's fill.
    if (identical(r$level, "variable") && !is.null(vfill)) fill <- vfill
    cells <- character(nc)
    # A fit row's label carries markup (*R*2 -- an italic R); any other
    # label is text as written. A variable's label row that carries cells
    # (a crosstab's, with its test: Session 405) takes variable.headings,
    # as a heading row's does.
    emph <- if (identical(r$level, "variable")) key("variable.headings") else "plain"
    eb <- identical(emph, "bold"); ei <- identical(emph, "italic")
    stub_runs <- paste0(if (isTRUE(r$markup)) {
                          .jst_docx_markup_runs(r$label, size = size, bold = eb,
                                                italic = ei)
                        } else .jst_docx_run(r$label, bold = eb, italic = ei, size = size),
                        if (length(r$marks)) .jst_docx_run(paste(r$marks, collapse = ","),
                                                           superscript = TRUE, size = size),
                        if (!is.null(r$tail) && nzchar(r$tail))
                          .jst_docx_run(r$tail, bold = eb, italic = ei, size = size))
    cells[1L] <- .jst_docx_cell(
      .jst_docx_par(stub_runs, ind = if (r$indent > 0L) 180L * r$indent else NULL,
                    keep_next = keep, line = line, size = msz),
      widths[1L],
      .jst_docx_borders(rules, grid, bottom, grid || outer, grid, rcol), fill = fill)
    j <- 2L
    while (j <= nc) {
      k <- cols$key[j]
      s <- r$cells[[k]]
      runs <- if (is.null(s) || !nzchar(s)) "" else .jst_docx_run(s, size = size)
      # A spanning cell (a fit row's) takes its model's columns, its value
      # on the first column's tab (Session 403). A plain cell -- an em
      # dash, an ANOVA's df -- is centered, with no tab (Session 405).
      to <- j
      for (sp in r$span) if (sp[1L] == j) to <- sp[2L]
      plain_j <- .jst_tbl_plain_cell(if (is.null(s)) "" else s, cols$kind[j])
      cells[j] <- .jst_docx_cell(
        .jst_docx_par(runs, tab = if (plain_j) NULL else dec_tabs[j],
                      jc = if (plain_j) "center", keep_next = keep, line = line,
                      size = msz),
        sum(widths[j:to]),
        .jst_docx_borders(rules, grid, bottom, grid, grid || (outer && to == nc), rcol),
        span = if (to > j) to - j + 1L else NULL, fill = fill)
      j <- to + 1L
    }
    cells <- cells[nzchar(cells)]
    rows_xml <- c(rows_xml, paste0("<w:tr><w:trPr><w:cantSplit/></w:trPr>",
                                   paste(cells, collapse = ""), "</w:tr>"))
  }

  # A note row: the notes' paragraphs, no borders.
  if (note_row) {
    pars <- .jst_docx_note_pars(tbl, style, keep_next = FALSE, size = note_size)
    if (length(pars)) {
      rows_xml <- c(rows_xml, span_all(paste(pars, collapse = ""), nil))
    }
  }

  grid_xml <- paste0("<w:gridCol w:w=\"", widths, "\"/>", collapse = "")
  # The children of tblPr in the schema's order (Word refuses a part whose
  # elements are out of order): tblW, tblBorders, tblLayout, tblCellMar.
  paste0("<w:tbl><w:tblPr>",
         "<w:tblW w:w=\"", total, "\" w:type=\"dxa\"/>",
         "<w:tblBorders><w:top w:val=\"nil\"/><w:left w:val=\"nil\"/>",
         "<w:bottom w:val=\"nil\"/><w:right w:val=\"nil\"/>",
         "<w:insideH w:val=\"nil\"/><w:insideV w:val=\"nil\"/></w:tblBorders>",
         "<w:tblLayout w:type=\"fixed\"/>",
         "<w:tblCellMar><w:left w:w=\"", margin, "\" w:type=\"dxa\"/>",
         "<w:right w:w=\"", margin, "\" w:type=\"dxa\"/></w:tblCellMar>",
         "</w:tblPr><w:tblGrid>", grid_xml, "</w:tblGrid>",
         paste(rows_xml, collapse = ""),
         "</w:tbl>")
}

#' Internal helper: the column widths of a table, in dxa
#'
#' From the widest text each column holds at the style's size, in the
#' table's font and bold where the style sets it bold (Session 407), plus
#' the cell margins; a column of numbers at least as wide as its block, the
#' widest whole part beside the widest tail (Session 405); the stub from
#' every row's label, a heading row's too, each beside its indent (Session
#' 407); a spanner's label spread over its columns when it is wider than
#' they are.
#'
#' @param tbl A jst_table.
#' @param style The style list.
#' @param size Points, or NULL for the style's size.
#' @param pad The twips added to each number column beside its margins
#'   (120; a table fitted to the page gives up half of it first, Session
#'   403).
#' @param headings FALSE for the stub from the data rows alone: the width
#'   at which no data label wraps, which the page fit and its report read
#'   (a heading row spans the table, so in a table fitted to its page the
#'   stub may narrow past it, and the heading runs on over the numbers).
#' @return Integer vector, one per column.
#' @keywords internal
.jst_docx_widths <- function(tbl, style, size = NULL, pad = 120L,
                             headings = TRUE) {
  if (is.null(size)) size <- .jst_style_key(style, tbl$type, "size")
  key  <- function(k) .jst_style_key(style, tbl$type, k)
  font <- key("font")
  cols <- tbl$columns; nc <- nrow(cols)
  margin <- 108L
  label_of <- function(r) {
    paste0(if (isTRUE(r$markup)) .jst_table_strip_markup(r$label) else r$label,
           paste(r$marks, collapse = ""), if (is.null(r$tail)) "" else r$tail)
  }
  indent_of <- function(r) if (isTRUE(r$indent > 0L)) as.integer(r$indent) else 0L
  # The stub's width is every row's label, each beside its indent: 180
  # dxa a level, as the writer indents it (Session 407; measured until
  # then as two spaces, about 125 dxa at 12 pt, and a short indented label
  # in Arial wrapped). A heading row -- a variable's label over its
  # categories, a role or a scale -- counts as the console's preview
  # counts it (Session 407, Jeff: "the label 'How we contacted you' should
  # define the width of that first column"; from Session 403 until then
  # the data rows alone set it, the heading spanning the table). The page
  # fit reads the data rows' width (headings = FALSE): a heading spans the
  # table, so a fitted stub may narrow past it and the heading run on.
  # A variable's label row takes variable.headings and a heading row
  # group.headings, as the writer reads them: only the table types that
  # have such rows have the settings.
  bold_of <- function(r) {
    emph <- if (identical(r$level, "variable")) key("variable.headings")
            else if (identical(r$kind, "heading")) key("group.headings")
            else "plain"
    identical(emph, "bold")
  }
  stub_w <- vapply(tbl$rows, function(r) {
    if (!headings && identical(r$kind, "heading")) return(0L)
    .jst_docx_text_width(label_of(r), size, font = font, bold = bold_of(r)) +
      180L * indent_of(r)
  }, integer(1))
  w <- integer(nc)
  heads <- .jst_table_strip_markup(cols$label)
  hbold <- identical(key("header.bold"), "yes")
  w[1L] <- max(stub_w, .jst_docx_text_width(heads[1L], size, font = font,
                                            bold = hbold)) + 2L * margin
  # A spanning cell (a fit row's, across its model's columns, Session
  # 403): its whole part sets the first column's width with the other
  # cells', and its tail -- the df after an F -- the span's, below.
  for (j in seq_len(nc)[-1L]) {
    k <- cols$key[j]
    cells <- vapply(tbl$rows, function(r) {
      s <- r$cells[[k]]; if (is.null(s)) s <- ""
      if (.jst_docx_spans_from(r, j)) .jst_docx_num_parts(s)$head else s
    }, character(1))
    # A column of numbers holds its block -- the widest whole part beside
    # the widest tail, each from whichever cell has it -- since the cells
    # share one decimal stop: a correlation column's ".62***" and "-.07"
    # need the minus left of the point and the stars right of it (Session
    # 405; the widest cell alone had left Word no room for the minus,
    # and it pushed "-.07" off the point).
    # The two are joined and measured as one text, so a column whose
    # widest cell holds both is as wide as before.
    pl    <- .jst_tbl_plain_cell(cells, cols$kind[j])
    parts <- .jst_docx_num_parts(cells[!pl])
    widest <- function(x) {
      x[which.max(vapply(x, .jst_docx_em_width, numeric(1), font = font))]
    }
    block <- .jst_docx_text_width(paste0(widest(parts$head), widest(parts$tail)),
                                  size, digits = TRUE, font = font)
    w[j] <- max(.jst_docx_text_width(cells, size, digits = TRUE, font = font), block,
                .jst_docx_text_width(heads[j], size, font = font, bold = hbold)) +
      2L * margin + pad
  }
  for (srow in tbl$spanners) for (sp in srow) {
    need <- .jst_docx_text_width(sp$label, size, font = font, bold = hbold) +
      2L * margin
    have <- sum(w[sp$from:sp$to])
    if (need > have) {
      extra <- need - have
      w[sp$from:sp$to] <- w[sp$from:sp$to] + ceiling(extra / (sp$to - sp$from + 1L))
    }
  }
  for (r in tbl$rows) for (sp in r$span) {
    from <- sp[1L]; to <- sp[2L]
    s <- r$cells[[cols$key[from]]]
    if (is.null(s) || !nzchar(s)) next
    need <- w[from] + .jst_docx_text_width(.jst_docx_num_parts(s)$tail, size,
                                           digits = TRUE, font = font)
    have <- sum(w[from:to])
    if (need > have) w[to] <- w[to] + (need - have)
  }
  as.integer(w)
}

#' Internal helper: does a row's cell at a column span columns?
#'
#' A fit row's cell spans its model's columns (Session 403); the row's
#' span field holds each span as c(from, to).
#'
#' @param r A row of a jst_table.
#' @param j A column index.
#' @return Logical.
#' @keywords internal
.jst_docx_spans_from <- function(r, j) {
  if (is.null(r$span)) return(FALSE)
  any(vapply(r$span, function(sp) sp[1L] == j, logical(1)))
}

#' Internal helper: a number cell's whole part and its tail
#'
#' The tail is the point and what follows it -- the decimals, any stars,
#' the df after an F; the whole part is the rest. The decimal tab aligns
#' the two. A cell with no point is all whole part: Word sets text with no
#' decimal point to end at a decimal tab (Session 405: an ANOVA's df
#' column, "3, 99", and a correlation's em dash; until then the text after
#' the digits counted as tail).
#'
#' @param s Character.
#' @return A list: head and tail, character vectors of s's length.
#' @keywords internal
.jst_docx_num_parts <- function(s) {
  tails <- ifelse(grepl("[.]", s), sub("^[^.]*", "", s), "")
  list(head = substr(s, 1L, nchar(s) - nchar(tails)), tail = tails)
}

#' Internal helper: a table's widths and sizes, fitted to the page
#'
#' Ruling R55 (Session 404): a table wider than its page loses half its
#' number columns' padding; then its labels wrap onto at most two lines,
#' the stub narrowing as far as \code{.jst_docx_stub_floor()} allows; then
#' its font steps down a point at a time to 8 pt, the stub at each size
#' allowed its floor again; then the stub narrows to an inch and a half and
#' every column in proportion. A number never wraps until that last step.
#' The notes step down with the table; the caption keeps its size. (Until
#' Session 405 the font stepped down before any label wrapped -- Session
#' 402, item 11, settled on a 17-column regression table whose numbers set
#' its width.)
#'
#' @param tbl A jst_table.
#' @param style The style list.
#' @param page_text The text width available, in dxa.
#' @return A list: widths (integer), size and note_size (points).
#' @keywords internal
.jst_docx_fit <- function(tbl, style, page_text) {
  size0 <- .jst_style_key(style, tbl$type, "size")
  note0 <- .jst_style_key(style, tbl$type, "note.size")
  mk <- function(w, s) list(widths = as.integer(w), size = s,
                            note_size = max(6, note0 - (size0 - s)))
  w <- .jst_docx_widths(tbl, style, size = size0, pad = 120L)
  if (sum(w) <= page_text) return(mk(w, size0))
  s <- size0
  for (s in .jst_docx_fit_sizes(size0)) {
    w <- .jst_docx_widths(tbl, style, size = s, pad = 60L)
    room <- page_text - sum(w[-1L])
    # The floor from the data rows' stub: a heading spans the table.
    w1 <- .jst_docx_widths(tbl, style, size = s, pad = 60L, headings = FALSE)[1L]
    if (room >= .jst_docx_stub_floor(tbl, s, w1,
                                     font = .jst_style_key(style, tbl$type, "font"))) {
      w[1L] <- min(w[1L], room)
      return(mk(w, s))
    }
  }
  # Still too wide at the smallest size: the stub to an inch and a half,
  # then every column in proportion.
  w[1L] <- min(w[1L], max(2160L, page_text - sum(w[-1L])))
  if (sum(w) > page_text) w <- floor(w * page_text / sum(w))
  mk(w, s)
}

#' Internal helper: the sizes a fitted table steps through
#'
#' The style's size, then each whole point below it down to 8 (APA's floor
#' for a table): 12, 11, 10, 9, 8.
#'
#' @param size0 The style's size.
#' @return Numeric.
#' @keywords internal
.jst_docx_fit_sizes <- function(size0) {
  low <- ceiling(size0) - 1
  c(size0, if (low >= 8) seq(low, 8, by = -1))
}

#' Internal helper: how narrow a table's stub may go
#'
#' Ruling R55: the labels wrap onto at most two lines, the stub never below
#' an inch and a half. Half the stub's width is the ruling's measure; a
#' label whose words cannot split into two lines that narrow sets the floor
#' wider, the narrowest width at which it takes two lines, so no label
#' wraps onto a third. A heading row spans the table and sets nothing: the
#' stub may narrow past it, and it runs on over the numbers.
#'
#' @param tbl A jst_table.
#' @param size Points.
#' @param w1 The stub's width at that size, unwrapped.
#' @param font Character(1), or NULL: the face measured in (Session 407).
#' @return Integer, dxa; never more than w1.
#' @keywords internal
.jst_docx_stub_floor <- function(tbl, size, w1, font = NULL) {
  em <- size * 20
  labs <- character(0); ind <- integer(0)
  for (r in tbl$rows) {
    if (identical(r$kind, "heading")) next
    labs <- c(labs, paste0(if (isTRUE(r$markup)) .jst_table_strip_markup(r$label)
                           else r$label,
                           paste(r$marks, collapse = ""),
                           if (is.null(r$tail)) "" else r$tail))
    ind  <- c(ind, if (isTRUE(r$indent > 0L)) as.integer(r$indent) else 0L)
  }
  labs <- c(labs, .jst_table_strip_markup(tbl$columns$label[1L])); ind <- c(ind, 0L)
  need <- 0
  for (i in seq_along(labs)) {
    wd <- strsplit(labs[i], " ", fixed = TRUE)[[1L]]
    wd <- wd[nzchar(wd)]
    if (!length(wd)) next
    m <- length(wd)
    two <- if (m == 1L) .jst_docx_em_width(wd, font) else {
      min(vapply(seq_len(m - 1L), function(k) {
        max(.jst_docx_em_width(paste(wd[seq_len(k)], collapse = " "), font),
            .jst_docx_em_width(paste(wd[(k + 1L):m], collapse = " "), font))
      }, numeric(1)))
    }
    need <- max(need, two * em + 180 * ind[i])
  }
  need <- as.integer(ceiling(need)) + 2L * 108L
  as.integer(min(w1, max(2160L, as.integer(ceiling(w1 / 2)), need)))
}

#' Internal helper: the decimal tab position of each number column
#'
#' Measured from the cell's left text edge: the block of numbers -- the
#' widest whole part and the widest tail (the point and the digits after
#' it, and any stars) -- centered in the cell's inner width, never past
#' the inner width less the widest tail (Session 401; until then every
#' block sat at that right-hand limit), and never left of the widest whole
#' part (Session 405).
#'
#' @param tbl A jst_table.
#' @param widths The column widths.
#' @param size Points.
#' @param margin The cell margin.
#' @param font Character(1), or NULL: the face measured in (Session 407).
#' @return Integer vector; NA for the stub.
#' @keywords internal
.jst_docx_decimal_tabs <- function(tbl, widths, size, margin, font = NULL) {
  cols <- tbl$columns; nc <- nrow(cols)
  out  <- rep(NA_integer_, nc)
  for (j in seq_len(nc)[-1L]) {
    k <- cols$key[j]
    cells <- vapply(tbl$rows, function(r) {
      s <- r$cells[[k]]; if (is.null(s)) "" else s
    }, character(1))
    parts <- .jst_docx_num_parts(cells)
    # A spanning cell's tail runs on past the column: it does not set
    # the tab (Session 403); nor does a plain cell, centered with no tab
    # (Session 405).
    spans <- vapply(tbl$rows, .jst_docx_spans_from, logical(1), j = j)
    pl <- .jst_tbl_plain_cell(cells, cols$kind[j])
    tail_w <- .jst_docx_text_width(parts$tail[!spans & !pl], size, digits = TRUE,
                                   font = font)
    head_w <- .jst_docx_text_width(parts$head[!pl], size, digits = TRUE, font = font)
    # The block of numbers centered in the cell (Session 401: under a head
    # wider than its numbers, "Valid %", the block had sat at the right),
    # and short of the cell's right edge: a stop at or past it is no stop
    # to LibreOffice, which then tabs to its default stops and wraps.
    # And never left of the widest whole part: Word pushes a number whose
    # whole part does not fit left of the stop off the point (Session 405).
    inner  <- widths[j] - 2L * margin
    out[j] <- as.integer(max(head_w, min(inner - tail_w - 40L,
                                         floor((inner + head_w - tail_w) / 2))))
  }
  out
}

#' Internal helper: a table's own font and size, on its runs
#'
#' Word takes a run's font from the document's defaults unless the run
#' names one. A table whose style's font differs from the document's gets
#' it on every run -- w:rFonts first in the run's properties, as Word's
#' schema orders them, with East Asian text set in it as the defaults set
#' it -- and on every paragraph mark; a table whose size differs gets it on
#' the paragraph marks that carry none (its runs carry their size always),
#' so an empty cell is as tall as the table's text. Session 407.
#'
#' @param xml Character; the table's paragraphs and table, as XML.
#' @param font Character(1), or NULL to leave the font alone.
#' @param size Points, or NULL to leave the paragraph marks' size alone.
#' @return Character, as \code{xml}.
#' @keywords internal
.jst_docx_retype <- function(xml, font = NULL, size = NULL) {
  if (is.null(font) && is.null(size)) return(xml)
  rf <- if (!is.null(font)) {
    f <- .jst_xml_esc(font)
    paste0("<w:rFonts w:ascii=\"", f, "\" w:hAnsi=\"", f, "\" w:cs=\"", f,
           "\" w:eastAsia=\"", f, "\"/>")
  } else ""
  sz <- if (!is.null(size)) {
    paste0("<w:sz w:val=\"", size * 2, "\"/><w:szCs w:val=\"", size * 2, "\"/>")
  } else ""
  # The paragraph marks first: a mark's properties hold a size only where
  # the table was fitted below its style's size, and keep it.
  mark <- function(p) {
    if (grepl("<w:rPr>", p, fixed = TRUE)) {
      sub("<w:rPr>", paste0("<w:rPr>", rf), p, fixed = TRUE)
    } else if (nzchar(rf) || nzchar(sz)) {
      sub("</w:pPr>", paste0("<w:rPr>", rf, sz, "</w:rPr></w:pPr>"), p,
          fixed = TRUE)
    } else p
  }
  vapply(xml, function(x) {
    m <- gregexpr("<w:pPr>.*?</w:pPr>", x, perl = TRUE)
    regmatches(x, m) <- list(vapply(regmatches(x, m)[[1L]], mark, character(1),
                                    USE.NAMES = FALSE))
    if (nzchar(rf)) {
      x <- gsub("<w:r><w:rPr>", paste0("<w:r><w:rPr>", rf), x, fixed = TRUE)
      x <- gsub("<w:r>(?!<w:rPr>)", paste0("<w:r><w:rPr>", rf, "</w:rPr>"), x,
                perl = TRUE)
    }
    x
  }, character(1), USE.NAMES = FALSE)
}

#' Internal helper: the body of a document holding tables
#'
#' Each table's caption, table and notes (paragraphs or rows by the style),
#' two empty paragraphs between tables (Jeff, Session 401), and the
#' section properties. Since Session 406 each table has the page it needs
#' (\code{.jst_docx_layout()}): where the orientation changes between two
#' tables, the second empty paragraph ends a section, and Word starts the
#' next table on a new page turned its own way; tables in a row with the
#' same orientation share pages. Until then one orientation served the
#' whole document: landscape when the style -- or the call, since Session
#' 403 -- said so, or when auto found any table that could not fit the
#' portrait text width at the style's size with half its padding and its
#' labels on two lines (ruling R55, Session 404).
#'
#' Each table keeps its own style's font (Session 407, the (S406) item):
#' the document's defaults are its style's -- the first table's, for
#' built tables written together -- and a table whose style sets another
#' font, or another size, has it written on its own runs and paragraph
#' marks (\code{.jst_docx_retype()}). Until then the defaults alone carried
#' the font, so the second table of a document written under two styles
#' took the first one's font while its fills, rules and captions followed
#' its own style. A table in the document's font and size is written as
#' before.
#'
#' @param tables A list of jst_table.
#' @param style The style list.
#' @param landscape NULL, or "auto", "yes" or "no" for every page (the
#'   writing call's setting).
#' @return A list: xml (the document part) and landscape (logical, one per
#'   table).
#' @keywords internal
.jst_docx_document <- function(tables, style, landscape = NULL) {
  body <- character(0)
  lay  <- .jst_docx_layout(tables, style, landscape)
  doc_font <- .jst_style_key(style, "general", "font")
  doc_size <- as.numeric(.jst_style_key(style, "general", "size"))
  for (i in seq_along(tables)) {
    tbl <- tables[[i]]
    L   <- lay[[i]]
    tst <- L$style
    key <- function(k) .jst_style_key(tst, tbl$type, k)
    one <- character(0)
    if (!identical(key("caption.position"), "row")) {
      one <- c(one, .jst_docx_caption_pars(tbl, tst, i))
    }
    one <- c(one, .jst_docx_table(tbl, tst, i, L$fit$widths, size = L$fit$size,
                                  note_size = L$fit$note_size))
    if (!identical(key("note.position"), "row")) {
      one <- c(one, .jst_docx_note_pars(tbl, tst, size = L$fit$note_size))
    }
    t_font <- key("font")
    t_size <- as.numeric(key("size"))
    body <- c(body, .jst_docx_retype(
      one, font = if (!identical(t_font, doc_font)) t_font,
      size = if (!identical(t_size, doc_size)) t_size))
    if (i < length(tables)) {
      # Two empty paragraphs between tables (Session 401); where the next
      # table needs the other page orientation, the second paragraph ends
      # this section, so the next table starts a new page turned its own
      # way (Session 406).
      body <- c(body, .jst_docx_par(""),
                if (identical(L$landscape, lay[[i + 1L]]$landscape)) .jst_docx_par("")
                else paste0("<w:p><w:pPr>", .jst_docx_sect(L$page, L$landscape),
                            "</w:pPr></w:p>"))
    }
  }
  last <- lay[[length(lay)]]
  xml <- paste0("<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>\n",
                "<w:document xmlns:w=\"", .jst_docx_ns, "\"><w:body>",
                paste(body, collapse = ""), .jst_docx_sect(last$page, last$landscape),
                "</w:body></w:document>")
  list(xml = xml, landscape = vapply(lay, function(L) L$landscape, logical(1)))
}

#' Internal helper: a section's properties
#'
#' The page size, turned for landscape, and the margins.
#'
#' @param page A page from \code{.jst_docx_page()}.
#' @param landscape Logical(1).
#' @return Character(1), the w:sectPr element.
#' @keywords internal
.jst_docx_sect <- function(page, landscape) {
  paste0("<w:sectPr><w:pgSz w:w=\"", page$w, "\" w:h=\"", page$h, "\"",
         if (landscape) " w:orient=\"landscape\"", "/>",
         "<w:pgMar w:top=\"1440\" w:right=\"1440\" w:bottom=\"1440\" ",
         "w:left=\"1440\" w:header=\"708\" w:footer=\"708\" w:gutter=\"0\"/>",
         "</w:sectPr>")
}

#' Internal helper: each table's page and fit in a document
#'
#' Each table gets the page it needs (Session 406): the setting is its own
#' style's landscape (the style it was built under, a call's own setting
#' included), read for its table type, so a table built with landscape =
#' "yes" keeps its page in any document; under auto it turns only when the
#' table cannot fit the portrait text width at the style's size with half
#' its padding and its labels on two lines (ruling R55). \code{landscape}
#' given -- the setting in the call that writes the document -- sets every
#' page. Until Session 406 a document had one orientation, so one wide
#' table turned every page. A table wider than its page is fitted to it
#' (\code{.jst_docx_fit()}). The paper is the document style's. A table
#' narrower than its caption row's title widens to it, every column in
#' proportion, as far as its page allows (Session 407), so the title keeps
#' one line.
#'
#' @param tables A list of jst_table.
#' @param style The document's style.
#' @param landscape NULL, or "auto", "yes" or "no" for every page.
#' @return A list, one element per table: style (the table's), landscape
#'   (logical), page, fit (widths, size and note_size; size NULL when the
#'   table fits as it is), natural (the widths before any fit) and size0
#'   (the style's size).
#' @keywords internal
.jst_docx_layout <- function(tables, style, landscape = NULL) {
  paper    <- .jst_style_key(style, "general", "paper")
  portrait <- .jst_docx_page(paper, FALSE)
  lapply(seq_along(tables), function(i) {
    tbl   <- tables[[i]]
    tst   <- .jst_table_style(tbl, style)
    size0 <- .jst_style_key(tst, tbl$type, "size")
    land_key <- if (is.null(landscape)) .jst_style_key(tst, tbl$type, "landscape")
                else landscape
    nat <- .jst_docx_widths(tbl, tst)
    # The narrowest the table goes at the style's size: half its padding,
    # its labels on two lines.
    w60 <- .jst_docx_widths(tbl, tst, size = size0, pad = 60L, headings = FALSE)
    narrowest <- as.numeric(sum(w60[-1L]) +
      .jst_docx_stub_floor(tbl, size0, w60[1L],
                           font = .jst_style_key(tst, tbl$type, "font")))
    land <- identical(land_key, "yes") ||
      (identical(land_key, "auto") && narrowest > portrait$text)
    page <- .jst_docx_page(paper, land)
    fit  <- if (sum(nat) > page$text) .jst_docx_fit(tbl, tst, page$text)
            else list(widths = nat, size = NULL, note_size = NULL)
    # A caption row keeps its title on one line: the table widens to it,
    # every column in proportion, as far as the page allows (Session 407).
    cap <- .jst_docx_caption_width(tbl, tst, i)
    if (cap > sum(fit$widths)) {
      fit$widths <- .jst_docx_widen(fit$widths, min(cap, page$text))
    }
    list(style = tst, landscape = land, page = page, fit = fit, natural = nat,
         size0 = size0)
  })
}

#' Internal helper: the styles part
#'
#' The document defaults (the font for every script, the size, the
#' language) and the Normal and Caption paragraph styles.
#'
#' @param style The style list.
#' @keywords internal
.jst_docx_styles <- function(style) {
  font <- .jst_style_key(style, "general", "font")
  size <- .jst_style_key(style, "general", "size") * 2
  f <- .jst_xml_esc(font)
  paste0("<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>\n",
         "<w:styles xmlns:w=\"", .jst_docx_ns, "\">",
         "<w:docDefaults><w:rPrDefault><w:rPr>",
         "<w:rFonts w:ascii=\"", f, "\" w:hAnsi=\"", f, "\" w:cs=\"", f,
         "\" w:eastAsia=\"", f, "\"/>",
         "<w:sz w:val=\"", size, "\"/><w:szCs w:val=\"", size, "\"/>",
         "<w:lang w:val=\"en-US\" w:eastAsia=\"en-US\" w:bidi=\"ar-SA\"/>",
         "</w:rPr></w:rPrDefault><w:pPrDefault><w:pPr>",
         "<w:spacing w:after=\"0\" w:line=\"240\" w:lineRule=\"auto\"/>",
         "</w:pPr></w:pPrDefault></w:docDefaults>",
         "<w:style w:type=\"paragraph\" w:default=\"1\" w:styleId=\"Normal\">",
         "<w:name w:val=\"Normal\"/><w:qFormat/></w:style>",
         "<w:style w:type=\"paragraph\" w:styleId=\"Caption\">",
         "<w:name w:val=\"caption\"/><w:basedOn w:val=\"Normal\"/>",
         "<w:next w:val=\"Normal\"/><w:qFormat/></w:style>",
         "<w:style w:type=\"table\" w:default=\"1\" w:styleId=\"TableNormal\">",
         "<w:name w:val=\"Normal Table\"/>",
         "<w:tblPr><w:tblInd w:w=\"0\" w:type=\"dxa\"/>",
         "<w:tblCellMar><w:top w:w=\"0\" w:type=\"dxa\"/>",
         "<w:left w:w=\"108\" w:type=\"dxa\"/><w:bottom w:w=\"0\" w:type=\"dxa\"/>",
         "<w:right w:w=\"108\" w:type=\"dxa\"/></w:tblCellMar></w:tblPr></w:style>",
         "</w:styles>")
}

#' Internal helper: the parts of a document file
#'
#' @param tables A list of jst_table.
#' @param style The style list.
#' @param landscape NULL, or the page setting for every page (the writing
#'   call's).
#' @return A named list of parts: path in the package, then the text.
#' @keywords internal
.jst_docx_parts <- function(tables, style, landscape = NULL) {
  doc <- .jst_docx_document(tables, style, landscape)
  ct <- paste0(
    "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>\n",
    "<Types xmlns=\"http://schemas.openxmlformats.org/package/2006/content-types\">",
    "<Default Extension=\"rels\" ContentType=\"application/vnd.openxmlformats-package.relationships+xml\"/>",
    "<Default Extension=\"xml\" ContentType=\"application/xml\"/>",
    "<Override PartName=\"/word/document.xml\" ContentType=\"application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml\"/>",
    "<Override PartName=\"/word/styles.xml\" ContentType=\"application/vnd.openxmlformats-officedocument.wordprocessingml.styles+xml\"/>",
    "</Types>")
  rels <- paste0(
    "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>\n",
    "<Relationships xmlns=\"http://schemas.openxmlformats.org/package/2006/relationships\">",
    "<Relationship Id=\"rId1\" Type=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument\" Target=\"word/document.xml\"/>",
    "</Relationships>")
  doc_rels <- paste0(
    "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>\n",
    "<Relationships xmlns=\"http://schemas.openxmlformats.org/package/2006/relationships\">",
    "<Relationship Id=\"rId1\" Type=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles\" Target=\"styles.xml\"/>",
    "</Relationships>")
  list("[Content_Types].xml" = ct,
       "_rels/.rels" = rels,
       "word/_rels/document.xml.rels" = doc_rels,
       "word/document.xml" = doc$xml,
       "word/styles.xml" = .jst_docx_styles(style))
}

#' Internal helper: write the parts into a .docx file
#'
#' The parts are written to a folder of their own under tempdir() and
#' packed from it by zip::zip(), the content-types part first, then the
#' folder is removed. The file is written to a temporary name beside the
#' destination and renamed into place, so a failed write leaves no part
#' of a file.
#'
#' @param parts The named list of parts.
#' @param file The destination path.
#' @return The path, invisibly.
#' @keywords internal
.jst_docx_pack <- function(parts, file) {
  root <- tempfile("jtable_")
  dir.create(root)
  on.exit(unlink(root, recursive = TRUE), add = TRUE)
  for (p in names(parts)) {
    full <- file.path(root, p)
    dir.create(dirname(full), recursive = TRUE, showWarnings = FALSE)
    con <- file(full, open = "wb")
    writeBin(charToRaw(enc2utf8(parts[[p]])), con)
    close(con)
  }
  # The temporary name is ABSOLUTE: zip::zip() changes into root to pack the
  # parts, and a relative name -- the file's folder is "." for a bare file
  # name, or a relative output folder -- was made inside root, so the file
  # was never written (Session 401; the taught form, file = "Table1.docx").
  tmp <- tempfile(pattern = "jtable_",
                  tmpdir = normalizePath(dirname(file), winslash = "/",
                                         mustWork = TRUE),
                  fileext = ".docx")
  zip::zip(zipfile = tmp, files = names(parts), root = root,
           mode = "mirror", include_directories = FALSE)
  if (!file.rename(tmp, file)) {
    ok <- file.copy(tmp, file, overwrite = TRUE)
    unlink(tmp)
    if (!isTRUE(ok)) {
      # A file open in Word is locked against replacement.
      .jst_stop("the file could not be written:\n  ", .jst_norm_path(file),
                "\nIf it is open in Word, close it and run jtable() again.",
                fn = "jtable")
    }
  }
  invisible(file)
}


# -----------------------------------------------------------------------------
# 7. jtable()
# -----------------------------------------------------------------------------

#' Make a publication table from a saved result
#'
#' \code{jtable()} turns a saved analysis result into a publication table
#' and, when \code{file} is given, writes it to a Word file (.docx) that
#' opens in Word, LibreOffice and Google Docs. The table's look and
#' conventions come from a style -- the built-in \code{"apa"} style for a
#' journal, the built-in \code{"report"} style for a report, or a style
#' file of your own (see \code{\link{jstyle}}).
#'
#' A table is made from each kind of result: a descriptives table from one
#' or more \code{\link{jdesc}} results; a frequency table from one or more
#' \code{\link{jfreq}} results -- each variable's label on a row of its
#' own, its categories indented under it; a regression table from one or
#' more \code{\link{jlm}} results, or a logistic regression table from
#' \code{\link{jlogistic}} results -- the models of one outcome side by
#' side, each under its own head, the constant first, a dummy-coded
#' variable's categories indented under its label with the reference
#' category named, and the fit rows under the predictors; a correlation
#' table from a \code{\link{jcorr}} result -- the variables numbered, their
#' n, mean and standard deviation, and the correlations below the
#' diagonal; a t-test table from \code{\link{jt}} results, or an ANOVA table
#' from \code{\link{jaov}} results, of one grouping variable -- one row per
#' outcome, each group's mean and standard deviation, then the test; a
#' crosstab from \code{\link{jcrosstab}} results of one column variable --
#' each row variable's categories with their counts and percentages in
#' each group, and the chi-square test; and a reliability table from
#' \code{\link{jalpha}} results -- each item's mean, standard deviation,
#' corrected item-total correlation and alpha if the item is deleted. The
#' variables of a descriptives or frequency table go under role headings
#' when \code{headings} names them, and each specific note's variables are
#' marked when \code{markers} names them. A filter the analysis applied
#' (\code{\link{jsubset}}, \code{subset =}) is named in the general note.
#'
#' @details
#' \strong{One call, one table.} The results given to one call make one
#' table: results share a table when they share its columns (see
#' \code{x}). Results that cannot share one -- results of different
#' kinds, models of different outcomes, tests of different grouping
#' variables -- stop, and the message gives the lines that make each
#' table in a call of its own. To put several tables in one file, build
#' each table, then give the tables together:
#' \code{jtable(list(t1, t2, t3), file = "Tables.docx")}. The tables keep
#' the order given and are numbered so.
#'
#' \strong{What prints.} \code{jtable()} reports what it made: each table's
#' number and title, what it holds, the page it is on (a landscape page,
#' the text stepped down to fit), and where the file was written. To see a
#' table in the console, keep it with \code{<-} and print it:
#' \code{print(t1)}, or type \code{t1}. The console shows a facsimile of
#' the Word table, its numbers formatted by the style.
#'
#' \strong{The page.} Under the style's \code{landscape = "auto"} each
#' table gets the page it needs: a table too wide for a portrait page sits
#' on landscape pages of its own, and the tables around it stay portrait.
#' \code{landscape = "yes"} or \code{"no"} in the call that writes a file
#' sets every page.
#'
#' \strong{The analysis inside the call.} \code{jtable(jlm(Fear ~ Age,
#' d))} runs the analysis without printing it and makes its table; errors
#' and warnings still show.
#'
#' \strong{Keeping a result for a later session.} A saved result is an R
#' object, which base R keeps in a file of its own:
#' \code{saveRDS(m1, "m1.rds")}, then in a later session
#' \code{m1 <- readRDS("m1.rds")}. A result made by an earlier version of
#' jstats than the table needs stops, and says which version made it.
#'
#' @param x A saved result -- what an analysis function returns, kept with
#'   \code{<-} -- or a list of them that share one table: a list of
#'   \code{jdesc()} results, or of \code{jfreq()} results, stacks into one
#'   table, each result's variables under its name in the list when the
#'   list is named; a list of \code{jlm()} results, or of
#'   \code{jlogistic()} results, with one outcome puts the models side by
#'   side, headed "Model 1", "Model 2", ... or by the list's names; a list
#'   of \code{jt()}, \code{jaov()} or \code{jcrosstab()} results with one
#'   grouping variable stacks a row or a block per outcome; a list of
#'   \code{jalpha()} results stacks the scales, each under its name. A
#'   \code{jcorr()} result is a table of its own. Or a table \code{jtable()}
#'   has already built, or a list of them: they go to the file as they
#'   are, in the order given.
#' @param headings A named list: each heading and the variables under it,
#'   bare or in quotes, e.g. \code{list("Dependent variable" = Wellbeing,
#'   "Independent variables" = c(Income, Age))}. Every variable of the
#'   result goes under one heading; the table follows the list's order.
#'   For a descriptives or frequency table.
#' @param markers A named list: each specific note's text and the
#'   variables it marks, e.g. \code{list("Mean-centered" = c(Income,
#'   Age))}. The style assigns the marks (superscript letters under APA),
#'   sets each on its rows' labels, and writes the note under the table.
#'   In a regression table a predictor's row is marked; in a t-test or
#'   ANOVA table an outcome's; in a crosstab a variable's label row; in a
#'   reliability table an item's.
#' @param title The table's title; the style's title when NULL (a
#'   regression table's names the outcome, a t-test, ANOVA or crosstab's
#'   the grouping variable). \code{*text*} sets a word in
#'   italics.
#' @param note The general note's text, after what the style writes
#'   there (N, a reference category); \code{*text*} sets a word in
#'   italics. NULL for none.
#' @param file The Word file to write, with its .docx extension: a bare
#'   name goes in the output folder (\code{joptions(output.dir = )}) or the
#'   working directory; a path with a folder goes there. NULL writes
#'   nothing.
#' @param style The style's name in quotes: \code{"apa"}, \code{"report"},
#'   or the name of a style file (\code{"myjournal"} for
#'   myjournal.jstyle), looked for in the style folder
#'   (\code{joptions(style.dir = )}), the working directory and your
#'   jstats folder; or a path to one. NULL (the default) uses
#'   \code{joptions(style = )}, apa when it is not set.
#' @param overwrite Logical. Replace a file that exists? With FALSE (the
#'   default) an interactive session asks, and one that cannot ask stops.
#' @param open Logical. TRUE opens the file once it is written, in the
#'   program your computer opens .docx files with; only in an interactive
#'   session, so a script or a rendered page opens nothing. Needs
#'   \code{file}.
#' @param print Print the report of what was made? NULL (the default)
#'   follows the \code{\link{joutput}} level: the report prints unless the
#'   level is \code{"silent"}. TRUE prints it under any level; FALSE prints
#'   nothing.
#' @param ... A setting of the table type's section of the style, for this
#'   table only, e.g. \code{columns = c("mean", "sd")} for a descriptives
#'   table, \code{missing.rows = "none"} for a frequency table or
#'   \code{fit.rows = c("r2", "delta.r2")} for a regression table: the
#'   call outranks the style file. \code{\link{jstyle_settings}} lists
#'   every setting. The general settings (the font, the caption's form,
#'   the decimals) are the style file's, except \code{landscape = "yes"} or
#'   \code{"no"}, a page choice the call may make. Any other input stops
#'   with "unused input".
#'
#' @return The table, invisibly: an object of class \code{jst_table}, which
#'   shows a facsimile of the Word table when printed. A call given two or
#'   more built tables returns them together (class \code{jst_tables}),
#'   which prints each one, numbered as in the file.
#'
#' @seealso \code{\link{jstyle}} for styles, \code{\link{jstyle_settings}}
#'   for every setting a style holds.
#'
#' @examples
#' # Keep a result, make its table, and look at it in the console
#' d1 <- jdesc(community, Age, Income, print = FALSE)
#' t1 <- jtable(d1, title = "Descriptive Statistics for Study Variables")
#' print(t1)
#'
#' # Two models of one outcome side by side, written to a Word file
#' m1 <- jlm(WellbeingScore ~ Age, community, print = FALSE)
#' m2 <- jlm(WellbeingScore ~ Age + Volunteer, community, print = FALSE)
#' t2 <- jtable(list(m1, m2), file = file.path(tempdir(), "Table2.docx"),
#'              overwrite = TRUE)
#'
#' # Several tables in one file: build each, then give them together
#' doc <- jtable(list(t1, t2), file = file.path(tempdir(), "Tables.docx"),
#'               overwrite = TRUE)
#' print(doc)
#'
#' # Keep a result for a later session with base R
#' path <- file.path(tempdir(), "m1.rds")
#' saveRDS(m1, path)
#' m1 <- readRDS(path)
#'
#' @export
jtable <- function(x, headings = NULL, markers = NULL, title = NULL,
                   note = NULL, file = NULL, style = NULL,
                   overwrite = FALSE, open = FALSE, print = NULL, ...) {
  cl  <- sys.call()
  mc  <- match.call(expand.dots = TRUE)
  env <- parent.frame()
  # A setting of the style given in the call (Jeff, Session 401: "Yes to
  # the ability to change a style in the call"): taken out of the dots
  # before the unused-input check. A name near a setting's gets that
  # check's did-you-mean.
  dots   <- rlang::enquos(...)
  dnames <- names(dots); if (is.null(dnames)) dnames <- rep("", length(dots))
  types    <- names(.jst_style_type_nouns)
  sec_keys <- setdiff(unique(unlist(lapply(.jst_style_spec[types], names))), "title")
  gen_keys <- names(.jst_style_spec$general)
  is_key   <- nzchar(dnames) & dnames %in% c(sec_keys, gen_keys)
  near     <- character(0)
  for (nm in dnames[nzchar(dnames) & !is_key]) {
    nr <- .jst_style_near(nm, sec_keys)
    if (length(nr)) near[nm] <- nr
  }
  # An input jtable() does not take -- a misspelled argument, or a value in
  # a place it has none -- stops here, read by name and never evaluated.
  .jst_check_args(dots[!is_key], aliases = c(notes = "note", near),
                  fn_name = "jtable", positional = "refuse")
  over_q <- dots[is_key]
  # A general setting stays the style file's -- except landscape, a page
  # choice the call may make (Jeff, Session 402: "can we have a landscape
  # option?").
  gen_given <- setdiff(intersect(names(over_q), gen_keys), "landscape")
  if (length(gen_given)) {
    .jst_stop(.jst_and_list(paste0(gen_given, " =")),
              if (length(gen_given) == 1L) " is one of a style's general settings, which a call "
              else " are general settings of a style, which a call ",
              "cannot change.\nSet ", if (length(gen_given) == 1L) "it" else "them",
              " in a style file, for example a copy of apa:\n",
              "  jstyle(\"apa\", save.as = \"mystyle\")", fn = "jtable")
  }
  # A bare word where a quoted value goes (ruling R18): the front door,
  # before anything is evaluated -- the style's name, and a setting's value
  # in the call.
  word_specs <- list(style = .jst_word_spec(c(names(.jst_style_builtin()),
                                              names(.jst_style_files())),
                                            "a style name"))
  text_keys <- character(0)
  for (k in names(over_q)) {
    sps <- Filter(Negate(is.null), lapply(.jst_style_spec[types], `[[`, k))
    if (identical(k, "landscape")) sps <- list(.jst_style_spec$general$landscape)
    vals <- unique(unlist(lapply(sps, function(sp) {
      c(sp$choices, sp$cols, if (isTRUE(sp$none)) "none")
    })))
    if (length(vals)) word_specs[[k]] <- .jst_word_spec(vals, "its value")
    if (any(vapply(sps, function(sp) identical(sp$kind, "text"), logical(1)))) {
      text_keys <- c(text_keys, k)
    }
  }
  .jst_word_args(cl, mc, env, word_specs, "jtable")
  .jst_free_text_arg(substitute(style), env, cl, mc, "style", "a style name", "jtable")
  for (k in text_keys) {
    .jst_free_text_arg(rlang::quo_get_expr(over_q[[k]]), env, cl, mc, k,
                       "text", "jtable")
  }
  .jst_free_text_arg(substitute(file), env, cl, mc, "file", "a file name", "jtable")
  .jst_check_flag(overwrite, "overwrite")
  .jst_check_flag(open, "open")
  .jst_check_flag(print, "print", null.ok = TRUE)
  if (isTRUE(open) && is.null(substitute(file))) {
    .jst_stop("open = TRUE opens the file jtable() writes, so it needs file = ",
              "as well, for example:\n  ",
              .jst_call_with(cl, mc, "file", "Table1.docx"), fn = "jtable")
  }
  st <- .jst_style_resolve(style, fn = "jtable", cl = cl, mc = mc)
  over_vals <- lapply(over_q, rlang::eval_tidy)

  # file =, checked before the result is forced (the S338 rule: a refused
  # call changes nothing, and a bad path never costs running an analysis).
  out_path <- NULL
  if (!is.null(file)) {
    if (!is.character(file) || length(file) != 1L || is.na(file) ||
        !nzchar(trimws(file))) {
      .jst_stop("`file` must be a file name in quotes, with its extension, ",
                "for example:\n  file = \"Table1.docx\"")
    }
    .jst_check_path_chars(file, what = "path")
    if (!identical(tolower(tools::file_ext(file)), "docx")) {
      .jst_stop("the file name needs the .docx extension (a Word file), ",
                "for example:\n  file = \"",
                tools::file_path_sans_ext(basename(file)), ".docx\"")
    }
    out_path <- .jst_table_out_path(file)
  }
  if (!is.null(title) && (!is.character(title) || length(title) != 1L ||
                          is.na(title))) {
    .jst_stop("`title` must be a single quoted string.")
  }
  if (!is.null(note) && (!is.character(note) || anyNA(note))) {
    .jst_stop("`note` must be text in quotes.")
  }

  # The result, forced here: a nested analysis call runs with its output
  # discarded, and only what jtable() reports prints. Errors and warnings
  # pass.
  x_sub <- substitute(x)
  x <- .jst_output_scope(FALSE, x)
  results <- if (is.list(x) && !inherits(x, c(.jst_apa_classes, "jst_table"))) {
    if (inherits(x, "jst_tables")) unclass(x) else x
  } else list(x)
  # A document given inside a list -- jtable(list(doc, t4)) -- puts its
  # tables in place (Session 406).
  results <- .jst_tables_splice(results)
  if (length(results) == 0L) {
    .jst_stop("the list given to jtable() is empty.")
  }
  # Built tables -- one, or a list of them -- go to the file as they are,
  # in the order given, each numbered: the document call of the reference's
  # Part 2.2. A built table beside a result is refused: a result is built
  # first. A built table keeps the style it was built under; landscape =,
  # a page choice, is the one setting the writing call may give (Session
  # 406: it sets every page).
  built <- vapply(results, inherits, logical(1), "jst_table")
  if (any(built)) {
    if (!all(built)) {
      .jst_stop("built tables and saved results cannot be given in one ",
                "call.\nBuild each result into a table first, then give the ",
                "tables together.")
    }
    if (!is.null(substitute(headings)) || !is.null(substitute(markers)) ||
        !is.null(title) || !is.null(note) || !is.null(style) ||
        length(setdiff(names(over_q), "landscape"))) {
      .jst_stop("headings =, markers =, title =, note =, style =, and a ",
                "style's settings belong to the call that builds a table ",
                "from a result; a built table keeps its own.")
    }
    land <- if (is.null(over_vals$landscape)) NULL else
      .jst_style_check_value("landscape", .jst_style_spec$general$landscape,
                             over_vals$landscape, "general", "jtable")
    doc_st <- .jst_table_style(results[[1L]], st)
    .jst_table_finish(results, doc_st, out_path, overwrite, open, print,
                      landscape = land, hint = TRUE)
    return(invisible(if (length(results) == 1L) results[[1L]]
                     else .jst_tables_new(results)))
  }
  not_res <- !vapply(results, function(r) !is.na(.jst_table_result_fn(r)), logical(1))
  if (any(not_res)) {
    .jst_stop("a table is made from a saved result -- what an analysis ",
              "function returns, kept with <- -- for example:\n",
              "  d1 <- jdesc(community, Age, Income)\n",
              "  jtable(d1)")
  }
  # One call makes one table (ruling R56, Session 406: "Wouldn't the user be
  # determining what results go together into the same table and the code
  # simply providing a stop error if that's not possible?"). Results that
  # cannot share a table -- results of different kinds, models of different
  # outcomes, tests of different grouping variables or groups, crosstabs of
  # different column variables, two jcorr() results -- stop, with the lines
  # that make each table and write them to one file.
  groups <- .jst_table_share_groups(results)
  if (length(groups) > 1L) {
    .jst_table_split_stop(results, groups, x_sub, env, st, over_q, over_vals,
                          given = c(headings = !is.null(substitute(headings)),
                                    markers  = !is.null(substitute(markers)),
                                    title    = !is.null(title),
                                    note     = !is.null(note)),
                          mc = mc)
  }
  # The table's type, and the call's settings for it: the call's layer
  # goes first in the style, so it outranks the file (the reference, Part
  # 3.2).
  type <- .jst_table_type_of(results[[1L]])
  if (is.na(type)) .jst_table_build(results[[1L]], st)   # the stop for an unbuilt type
  if (length(over_vals)) {
    st <- .jst_style_object(st$name, st$path,
                            c(list(.jst_style_call_layer(over_vals, type, "jtable")),
                              st$layers),
                            st$skipped)
  }
  # The headings and markers, read as names: a bare name the results hold
  # is their variable whatever the workspace holds (ruling R18). A model's
  # variables are its predictors.
  vars <- unique(unlist(lapply(results, .jst_table_result_vars)))
  hd <- .jst_table_name_groups(substitute(headings), env, "headings", vars)
  mk <- .jst_table_name_groups(substitute(markers), env, "markers", vars)

  # The results go to their type's builder as one list, so a named list's
  # names give the headings -- or the model heads -- however many results
  # it holds.
  tbl <- .jst_table_builder(type)(results, st, headings = hd, markers = mk,
                                  title = title, note = note)
  # What the report says of the table, and what the combining hint reads
  # when the table is later written beside others (Session 406).
  tbl$summary <- .jst_table_summary(results, type, hd)
  tbl$share   <- .jst_table_share_key(results[[1L]], 1L)
  tbl$vars    <- vars
  tbl$source  <- .jst_table_elements(x_sub, results)$source
  # What the builder has to say beside the table (the models' Ns differ):
  # printed before the report, at every output level.
  for (m in tbl$messages) .jst_msg(m)
  .jst_table_finish(list(tbl), st, out_path, overwrite, open, print,
                    how = c(.jst_call_with(cl, mc, "file", "Table1.docx"),
                            .jst_term_text(cl)))
  invisible(tbl)
}

#' @rdname jtable
#' @exportS3Method
print.jst_table <- function(x, ...) {
  .jst_table_preview(x, .jst_table_style(x, NULL), number = 1L)
  invisible(x)
}

#' @rdname jtable
#' @exportS3Method
print.jst_tables <- function(x, ...) {
  for (i in seq_along(x)) {
    .jst_table_preview(x[[i]], .jst_table_style(x[[i]], NULL), number = i)
  }
  invisible(x)
}

#' Internal helper: tables together, as one document
#'
#' What a call that writes two or more built tables returns (Session 406):
#' a list of jst_table of class "jst_tables". Typed, or given to print(), it
#' shows every table's preview numbered as in the file; given to jtable(),
#' alone or inside a list, it is written as its tables.
#'
#' @param tables A list of jst_table.
#' @return An object of class "jst_tables".
#' @keywords internal
.jst_tables_new <- function(tables) {
  structure(tables, class = "jst_tables")
}

#' Internal helper: put a document's tables in its place in a list
#'
#' @param results The list jtable() was given.
#' @return The list, each jst_tables element replaced by its tables, names
#'   kept for the other elements.
#' @keywords internal
.jst_tables_splice <- function(results) {
  docs <- vapply(results, inherits, logical(1), "jst_tables")
  if (!any(docs)) return(results)
  rn  <- names(results); if (is.null(rn)) rn <- rep("", length(results))
  out <- list(); nms <- character(0)
  for (i in seq_along(results)) {
    if (docs[i]) {
      el  <- unclass(results[[i]])
      out <- c(out, unname(el)); nms <- c(nms, rep("", length(el)))
    } else {
      out <- c(out, list(results[[i]])); nms <- c(nms, rn[i])
    }
  }
  names(out) <- if (any(nzchar(nms))) nms else NULL
  out
}

#' Internal helper: a result's table type
#'
#' @param r A result.
#' @return Character(1): "descriptives", "regression", ...; NA for an object
#'   of no result class.
#' @keywords internal
.jst_table_type_of <- function(r) {
  unname(.jst_table_types[intersect(class(r), names(.jst_table_types))[1L]])
}

#' Internal helper: the builder of a table type
#'
#' @param type Character(1), a table type.
#' @return The builder function.
#' @keywords internal
.jst_table_builder <- function(type) {
  switch(type,
    descriptives = .jst_table_build_desc,
    frequencies  = .jst_table_build_freq,
    regression   = , logistic = .jst_table_build_models,
    correlation  = .jst_table_build_corr,
    ttest        = , anova = .jst_table_build_groups,
    crosstab     = .jst_table_build_crosstab,
    reliability  = .jst_table_build_alpha)
}

#' Internal helper: what a result shares with the others of its table
#'
#' Ruling R54: results share a table when they share its columns -- every
#' jdesc() result, every jfreq() and every jalpha() result of a call stacks;
#' models of one outcome sit side by side; t tests, ANOVAs and crosstabs of
#' one grouping (column) variable with one set of groups stack; each
#' jcorr() result is a table of its own. Two results share a table when
#' their keys are the same. A field a result made before it existed cannot
#' give is read as a key of its own, so the result's table is built alone
#' and its stop says which version made it.
#'
#' @param r A result.
#' @param i Its place in the list.
#' @return Character(1): the table type, then what the table's columns
#'   depend on.
#' @keywords internal
.jst_table_share_key <- function(r, i) {
  type <- .jst_table_type_of(r)
  one  <- function(expr) {
    k <- tryCatch(expr, error = function(e) NA_character_)
    if (length(k) != 1L) NA_character_ else as.character(k)
  }
  key <- switch(type,
    regression = , logistic = one(unname(attr(r$coefficients_raw, "outcome")["name"])),
    ttest = , anova = one({
      md <- .jst_apa_model(r); tf <- .jst_apa_terms(r)
      paste(c(as.character(md$group), as.character(tf$group_code)), collapse = "\r")
    }),
    crosstab = one({
      cc <- r$col_categories
      paste(c(unname(attr(cc, "variable")["name"]), as.character(cc$code)),
            collapse = "\r")
    }),
    correlation = NA_character_,
    "")
  if (is.na(key)) key <- paste0("\r#", i)
  paste(type, key, sep = "\n")
}

#' Internal helper: the results that would share each table
#'
#' @param results A list of results.
#' @return A list of index vectors, one per table, in the order of each
#'   table's first result in the list.
#' @keywords internal
.jst_table_share_groups <- function(results) {
  keys <- vapply(seq_along(results), function(i) {
    .jst_table_share_key(results[[i]], i)
  }, character(1))
  lapply(unique(keys), function(k) which(keys == k))
}

#' Internal helper: the results as typed, for the lines a message offers
#'
#' Read from the call: a list typed in the call gives each result as typed
#' (\code{list(d1, m1)}: "d1" and "m1"), one result its expression; a name
#' holding a list gives each by its place in it (\code{res[[2]]}); any other
#' expression is offered with a line that keeps it first.
#'
#' @param x_sub The call's first argument as typed (substitute()).
#' @param results The results it gave.
#' @return A list: text (character, one per result, or NULL), names (the
#'   list's names, "" for none), base (the name holding the list, or
#'   NULL), expr (the expression to keep first, or NULL), and source (the
#'   text, or NA where there is none, for the combining hint).
#' @keywords internal
.jst_table_elements <- function(x_sub, results) {
  n   <- length(results)
  nms <- names(results); if (is.null(nms)) nms <- rep("", n)
  dp  <- function(e) paste(deparse(e, width.cutoff = 500L), collapse = " ")
  is_list_call <- is.call(x_sub) &&
    (identical(x_sub[[1L]], as.name("list")) || identical(x_sub[[1L]], quote(base::list)))
  if (is_list_call && length(x_sub) - 1L == n) {
    txt <- vapply(as.list(x_sub)[-1L], dp, character(1), USE.NAMES = FALSE)
    return(list(text = txt, names = nms, base = NULL, expr = NULL,
                source = stats::setNames(txt, nms)))
  }
  if (n == 1L && !is_list_call) {
    txt <- dp(x_sub)
    return(list(text = txt, names = nms, base = NULL, expr = NULL,
                source = stats::setNames(txt, nms)))
  }
  if (is.symbol(x_sub)) {
    nm <- as.character(x_sub)
    return(list(text = NULL, names = nms, base = nm, expr = NULL,
                source = stats::setNames(paste0(nm, "[[", seq_len(n), "]]"), nms)))
  }
  list(text = NULL, names = nms, base = NULL, expr = dp(x_sub),
       source = stats::setNames(rep(NA_character_, n), nms))
}

#' Internal helper: names for the tables a message offers lines to make
#'
#' t1, t2, ... unless one of them names an object in the workspace, which
#' an offered line would replace: then tab1, tab2, ..., then table1, ....
#'
#' @param k The number of names.
#' @param env The caller's environment.
#' @param stem The stems to try, in order.
#' @return Character, k names.
#' @keywords internal
.jst_table_line_names <- function(k, env, stem = c("t", "tab", "table")) {
  # The caller's frame and the workspace: the lines are pasted at the
  # console, where a name in either would be replaced.
  taken <- function(nm) {
    exists(nm, envir = env, inherits = FALSE) ||
      exists(nm, envir = globalenv(), inherits = FALSE)
  }
  for (p in stem) {
    cand <- if (k == 0L) p else paste0(p, seq_len(k))
    if (!any(vapply(cand, taken, logical(1)))) return(cand)
  }
  paste0(stem[length(stem)], "_", seq_len(max(k, 1L)))
}

#' Internal helper: the stop for results that cannot share a table
#'
#' Ruling R56 (Session 406): one jtable() call makes one table, so the user
#' decides what goes together, and a list that cannot make one table stops.
#' The stop names what keeps the results apart, then gives the lines that
#' make each table -- the results that can share one grouped, in the order
#' of each table's first result -- and the line that writes them to one
#' file. Before it says so, each line's table is built (and discarded), so
#' a result that cannot make a table at all stops in its own words, and no
#' offered line stops again (ruling R23). style = goes on every line, a
#' table type's setting on the lines of the tables that take it, and the
#' file, overwrite =, open =, landscape = and print = on the line that
#' writes; headings =, markers =, title = and note = name one table, and a
#' sentence says to put them on its line.
#'
#' @param results A list of results.
#' @param groups The tables' results (\code{.jst_table_share_groups()}).
#' @param x_sub The call's first argument as typed.
#' @param env The caller's environment.
#' @param st The call's style.
#' @param over_q,over_vals The call's style settings: as typed (quosures)
#'   and evaluated.
#' @param given Logical, named headings, markers, title, note: which of
#'   them the call gave.
#' @param mc The matched call.
#' @keywords internal
.jst_table_split_stop <- function(results, groups, x_sub, env, st, over_q,
                                  over_vals, given, mc) {
  types  <- vapply(results, .jst_table_type_of, character(1))
  gtypes <- vapply(groups, function(g) types[g[1L]], character(1))
  takes  <- function(t, k) k %in% names(.jst_style_spec[[t]])
  sec_keys <- setdiff(names(over_q), "landscape")
  for (k in sec_keys) {
    if (!any(vapply(gtypes, takes, logical(1), k = k))) {
      owners <- names(Filter(function(s) k %in% names(s),
                             .jst_style_spec[names(.jst_style_type_nouns)]))
      .jst_stop(k, " = is a setting of ",
                .jst_and_list(unname(.jst_style_type_nouns[owners])),
                ", and none of these results makes one.", fn = "jtable")
    }
  }
  # Each table is built first: a result that cannot make one stops here,
  # in its own words.
  keeps <- lapply(gtypes, function(t) sec_keys[vapply(sec_keys, takes, logical(1), t = t)])
  for (j in seq_along(groups)) {
    stj <- st
    if (length(keeps[[j]])) {
      stj <- .jst_style_object(st$name, st$path,
                               c(list(.jst_style_call_layer(over_vals[keeps[[j]]],
                                                            gtypes[j], "jtable")),
                                 st$layers), st$skipped)
    }
    .jst_table_builder(gtypes[j])(results[groups[[j]]], stj)
  }

  # What keeps the results apart.
  fns <- vapply(results, .jst_table_result_fn, character(1))
  lead <- if (length(unique(types)) > 1L) {
    paste0("results of different kinds (", .jst_and_list(unique(fns)),
           ") cannot share a table.")
  } else {
    t <- types[1L]
    if (t %in% c("regression", "logistic")) {
      outs <- vapply(results, function(r) {
        unname(attr(r$coefficients_raw, "outcome")["name"])
      }, character(1))
      paste0("models of different outcomes (", .jst_and_list(unique(outs)),
             ") cannot share a table.")
    } else if (t %in% c("ttest", "anova")) {
      fn   <- fns[1L]
      grps <- vapply(results, function(r) as.character(.jst_apa_model(r)$group),
                     character(1))
      if (length(unique(grps)) > 1L) {
        paste0(fn, " results of different grouping variables (",
               .jst_and_list(unique(grps)), ") cannot share a table.")
      } else {
        sets <- vapply(results, function(r) {
          tf <- .jst_apa_terms(r)
          .jst_and_list(.jst_table_cat_names(tf$group_code, tf$group_label))
        }, character(1))
        paste0("the ", fn, " results compare different groups of ", grps[1L],
               " (", paste(unique(sets), collapse = "; "),
               "), so they cannot share a table.")
      }
    } else if (identical(t, "crosstab")) {
      vname <- function(r) unname(attr(r$col_categories, "variable")["name"])
      cvars <- vapply(results, vname, character(1))
      if (length(unique(cvars)) > 1L) {
        paste0("jcrosstab() results with different column variables (",
               .jst_and_list(unique(cvars)), ") cannot share a table.")
      } else {
        sets <- vapply(results, function(r) {
          .jst_and_list(.jst_table_cat_names(r$col_categories$code,
                                             r$col_categories$label))
        }, character(1))
        paste0("the jcrosstab() results hold different categories of ",
               cvars[1L], " (", paste(unique(sets), collapse = "; "),
               "), so they cannot share a table.")
      }
    } else {
      paste0("each jcorr() result is a table of its own.\n",
             "To correlate more variables in one table, name them in one ",
             "jcorr() call.")
    }
  }

  # The lines: each table's, then the one that writes them.
  el  <- .jst_table_elements(x_sub, results)
  nm  <- .jst_table_line_names(length(groups), env)
  dp  <- function(e) paste(deparse(e, width.cutoff = 500L), collapse = " ")
  pre <- NULL; base <- el$base
  if (!is.null(el$expr)) {
    base <- .jst_table_line_names(0L, env, stem = c("res", "results", "res_list"))
    pre  <- paste0("  ", base, " <- ", el$expr, "\n")
  }
  piece <- function(g) {
    if (!is.null(el$text)) {
      if (length(g) == 1L && !nzchar(el$names[g])) return(el$text[g])
      return(paste0("list(", paste(ifelse(nzchar(el$names[g]),
                                          paste0("\"", el$names[g], "\" = ", el$text[g]),
                                          el$text[g]), collapse = ", "), ")"))
    }
    if (length(g) == 1L && !nzchar(el$names[g])) return(paste0(base, "[[", g, "]]"))
    paste0(base, "[c(", paste(g, collapse = ", "), ")]")
  }
  style_arg <- if (!is.null(mc$style)) paste0(", style = ", dp(mc$style))
  lines <- vapply(seq_along(groups), function(j) {
    sets <- vapply(keeps[[j]], function(k) {
      paste0(", ", k, " = ", dp(rlang::quo_get_expr(over_q[[k]])))
    }, character(1))
    paste0("  ", nm[j], " <- jtable(", piece(groups[[j]]), style_arg,
           paste(sets, collapse = ""), ")")
  }, character(1))
  wr <- c(paste0("file = ", if (is.null(mc$file)) "\"Tables.docx\"" else dp(mc$file)),
          if (!is.null(mc$overwrite)) paste0("overwrite = ", dp(mc$overwrite)),
          if (!is.null(mc$open)) paste0("open = ", dp(mc$open)),
          if (!is.null(over_q$landscape)) {
            paste0("landscape = ", dp(rlang::quo_get_expr(over_q$landscape)))
          },
          if (!is.null(mc$print)) paste0("print = ", dp(mc$print)))
  last <- paste0("  jtable(list(", paste(nm, collapse = ", "), "), ",
                 paste(wr, collapse = ", "), ")")
  gv <- names(given)[given]
  tail <- if (length(gv)) {
    paste0("\n", .jst_and_list(paste0(gv, " =")), " ",
           .jst_plural(length(gv), "names", "name"), " one table: add ",
           .jst_plural(length(gv), "it", "them"), " to that table's line.")
  }
  .jst_stop(lead, "\n",
            "Make each table in a call of its own, then give the tables ",
            "together to write them to one file:\n",
            pre, paste(lines, collapse = "\n"), "\n", last, tail, fn = "jtable")
}

#' Internal helper: what a table holds, for jtable()'s report
#'
#' @param results The results the table was built from.
#' @param type Its table type.
#' @param headings The headings given, or NULL.
#' @return Character(1), e.g. "4 models side by side".
#' @keywords internal
.jst_table_summary <- function(results, type, headings = NULL) {
  cnt  <- function(k, noun) paste(k, .jst_plural(k, noun))
  vars <- unique(unlist(lapply(results, .jst_table_result_vars)))
  nh   <- if (length(headings)) length(headings) else {
    rn <- names(results); if (is.null(rn)) 0L else sum(nzchar(rn))
  }
  switch(type,
    descriptives = , frequencies = paste0(
      cnt(length(vars), "variable"),
      if (nh > 0L) paste0(" under ", cnt(nh, "heading"))),
    regression = , logistic = if (length(results) == 1L) "1 model" else
      paste(length(results), "models side by side"),
    correlation = cnt(length(vars), "variable"),
    ttest = , anova = paste0(cnt(length(results), "outcome"), " by ",
                             .jst_apa_name(results[[1L]], "group")),
    crosstab = paste0(cnt(length(results), "variable"), " by ",
                      unname(attr(results[[1L]]$col_categories, "variable")["name"])),
    reliability = if (length(results) == 1L) paste0("1 scale of ", cnt(length(vars), "item"))
      else paste0(length(results), " scales, ", cnt(length(vars), "item")))
}

#' Internal helper: the overwrite question, the file, and the report
#'
#' What every jtable() call does once its tables are built (Session 406,
#' ruling R57): the overwrite question (after every check that can stop
#' the call), the file written, then the report -- each table's number,
#' title, contents and page, and where the file went -- printed unless
#' print = FALSE or the level is silent; the replica of a table prints
#' only with print(). Then the file opened, under open = TRUE.
#'
#' @param tables A list of jst_table.
#' @param style The document's style.
#' @param out_path The file to write, or NULL.
#' @param overwrite,open,print The call's.
#' @param landscape The writing call's page setting, or NULL.
#' @param hint Logical; TRUE for a call that writes built tables, whose
#'   report carries the combining hint at joutput("full").
#' @param how NULL, or two lines for a call that writes no file: the call
#'   with file = added, and the call as typed (offered at joutput("full")).
#' @return TRUE when the file was written, invisibly.
#' @keywords internal
.jst_table_finish <- function(tables, style, out_path, overwrite, open, print,
                              landscape = NULL, hint = FALSE, how = NULL) {
  existed <- !is.null(out_path) && file.exists(out_path)
  write <- !is.null(out_path) &&
    .jst_table_overwrite_gate(out_path, overwrite, ask = interactive())
  if (write) .jst_docx_pack(.jst_docx_parts(tables, style, landscape), out_path)
  if (.jst_print_on(print)) {
    .jst_table_report(tables, .jst_docx_layout(tables, style, landscape),
                      path = if (write) out_path, replaced = existed && write,
                      asked = !is.null(out_path), hint = hint, how = how)
  }
  if (write) .jst_table_open(out_path, open)
  invisible(write)
}

#' Internal helper: jtable()'s report
#'
#' Ruling R57 (Session 406): what a jtable() call prints in place of the
#' table -- for each table, "Table n." and its title, then an indented
#' line saying what it holds and the page it is on (the page turned, the
#' text stepped down, long labels wrapped, as the Word file has them); then
#' where the file went ("Table written to <path>", "3 tables written to
#' <path>", replacing a file that was there), or, when no file was asked
#' for, that none was written -- at joutput("full") with the lines that
#' write the table and show it. A call that writes built tables adds, at
#' joutput("full"), the tables that could have been one.
#'
#' @param tables A list of jst_table.
#' @param lay Their layout (\code{.jst_docx_layout()}).
#' @param path The file written, or NULL.
#' @param replaced Logical; the file replaced one that was there.
#' @param asked Logical; the call gave file = (the overwrite gate speaks
#'   for a declined write).
#' @param hint,how As \code{.jst_table_finish()}.
#' @keywords internal
.jst_table_report <- function(tables, lay, path = NULL, replaced = FALSE,
                              asked = FALSE, hint = FALSE, how = NULL) {
  for (i in seq_along(tables)) {
    tbl <- tables[[i]]
    .jst_msg_out(paste0("Table ", i, ". ",
                        .jst_table_strip_markup(tbl$caption$title)))
    .jst_msg_out(paste0("  ", .jst_table_shape(tbl), ", ",
                        .jst_table_page_text(tbl, lay[[i]]), "."))
  }
  if (!is.null(path)) {
    .jst_msg_out(paste0(if (length(tables) == 1L) "Table" else
                          paste(length(tables), "tables"),
                        " written to ", .jst_norm_path(path)))
    if (replaced) .jst_msg_out("It replaced the file that was there.")
  } else if (!asked) {
    .jst_msg_out("No file was written.")
    if (length(how) == 2L) {
      .jst_advisory_note(
        "Note: to write the table to a Word file, add file = to the call:\n",
        "  ", how[1L], "\n",
        "To see the table here, keep it with <- and print it:\n",
        "  t1 <- ", how[2L], "\n",
        "  print(t1)")
    }
  }
  if (hint) .jst_table_combine_hint(tables)
  cat("\n")
}

#' Internal helper: what a table holds, in a few words
#'
#' The summary jtable() stored when it built the table; for a table built
#' before Session 406, its rows counted.
#'
#' @param tbl A jst_table.
#' @return Character(1).
#' @keywords internal
.jst_table_shape <- function(tbl) {
  if (!is.null(tbl$summary)) return(tbl$summary)
  n <- sum(vapply(tbl$rows, function(r) !identical(r$kind, "heading"), logical(1)))
  paste(n, .jst_plural(n, "row"))
}

#' Internal helper: a table's page, in a few words
#'
#' The orientation, then what the fit did: the text stepped down to fit
#' the page, long labels wrapped onto two lines.
#'
#' @param tbl A jst_table.
#' @param L Its layout (one element of \code{.jst_docx_layout()}).
#' @return Character(1), e.g. "on a landscape page, its text at 10 pt".
#' @keywords internal
.jst_table_page_text <- function(tbl, L) {
  out <- paste0("on a ", if (L$landscape) "landscape" else "portrait", " page")
  if (!is.null(L$fit$size)) {
    if (L$fit$size < L$size0) {
      out <- paste0(out, ", its text at ", format(L$fit$size), " pt")
    }
    w <- .jst_docx_widths(tbl, L$style, size = L$fit$size, pad = 60L,
                          headings = FALSE)
    if (L$fit$widths[1L] < w[1L]) out <- paste0(out, ", long labels on two lines")
  }
  out
}

#' Internal helper: the tables in a file that could have been one
#'
#' At joutput("full"), for a call that writes built tables (Session 406;
#' Jeff: "the possibility of combining more than one result in the same
#' table if the user doesn't specify a combined table when it's possible"):
#' tables whose results share their columns (ruling R54) and hold no
#' variable twice are named, with the line that makes them one table when
#' every result's name is known. Tables kept apart on purpose are common,
#' so the note is advisory.
#'
#' @param tables A list of jst_table.
#' @keywords internal
.jst_table_combine_hint <- function(tables) {
  keys <- vapply(tables, function(t) if (is.null(t$share)) NA_character_ else t$share,
                 character(1))
  for (k in unique(keys[!is.na(keys)])) {
    at <- which(keys == k)
    if (length(at) < 2L || startsWith(k, "correlation\n")) next
    type <- tables[[at[1L]]]$type
    # Models of one outcome sit side by side whatever predictors they share;
    # every other table holds each variable once.
    vars <- unlist(lapply(tables[at], function(t) t$vars))
    if (!type %in% c("regression", "logistic") && anyDuplicated(vars)) next
    what <- switch(type,
      descriptives = "are descriptives tables",
      frequencies  = "are frequency tables",
      regression   = , logistic = "hold models of one outcome",
      ttest        = "hold t tests of one grouping variable",
      anova        = "hold ANOVAs of one grouping variable",
      crosstab     = "hold crosstabs of one column variable",
      reliability  = "are reliability tables")
    src <- unlist(lapply(tables[at], function(t) t$source))
    line <- if (length(src) && !anyNA(src)) {
      nms <- names(src); if (is.null(nms)) nms <- rep("", length(src))
      paste0("\n  jtable(list(", paste(ifelse(nzchar(nms),
                                              paste0("\"", nms, "\" = ", src), src),
                                       collapse = ", "), "))")
    }
    .jst_advisory_note("Note: Tables ", .jst_and_list(as.character(at)), " ",
                       what, " and could be one table",
                       if (is.null(line)) "." else ":", line)
  }
  invisible(NULL)
}

#' Internal helper: the style a built table is drawn in
#'
#' A table keeps the style it was built under, the call's own settings
#' included, so it prints and writes as it was built; a table made before
#' Session 401 carries the style's name instead, read again here.
#'
#' @param tbl A jst_table.
#' @param style The style to use when the table carries none.
#' @keywords internal
.jst_table_style <- function(tbl, style) {
  if (inherits(tbl$style, "jst_style")) return(tbl$style)
  if (is.character(tbl$style)) return(.jst_style_resolve(tbl$style))
  .jst_style_resolve(style)
}

#' Internal helper: open a written file, when open = TRUE asks
#'
#' Only in an interactive session (open = TRUE in a script, a rendered
#' page or a check opens nothing), with \code{utils::browseURL()}, which
#' hands the file to the program the computer opens .docx files with. The
#' opener and the session test are arguments so a battery can stand in for
#' both and open nothing.
#'
#' @param path The file.
#' @param open Logical.
#' @param ask Logical; whether the session is interactive.
#' @param browse The function that opens the file.
#' @return TRUE when the file was handed to the opener, invisibly.
#' @keywords internal
.jst_table_open <- function(path, open, ask = interactive(),
                            browse = utils::browseURL) {
  if (!isTRUE(open) || !isTRUE(ask)) return(invisible(FALSE))
  browse(normalizePath(path, winslash = "/", mustWork = FALSE))
  invisible(TRUE)
}

#' Internal helper: a call's own style settings, as a layer
#'
#' Each setting the call gives must be one of the table type's section's
#' (a general setting is refused at jtable()'s front door); its value is
#' checked as a file's is.
#'
#' @param vals A named list: the settings, evaluated.
#' @param type The table type.
#' @param fn The user-facing function's name.
#' @return A layer: list(source = "the call", <type> = list(...)), with a
#'   general part when the call sets landscape (Session 403).
#' @keywords internal
.jst_style_call_layer <- function(vals, type, fn) {
  sec <- .jst_style_spec[[type]]
  out <- list(); gen <- list()
  for (k in names(vals)) {
    if (identical(k, "landscape")) {
      gen[[k]] <- .jst_style_check_value(k, .jst_style_spec$general[[k]], vals[[k]],
                                         "general", fn)
      next
    }
    if (!k %in% names(sec)) {
      owners <- names(Filter(function(s) k %in% names(s),
                             .jst_style_spec[names(.jst_style_type_nouns)]))
      .jst_stop(k, " = is a setting of ",
                .jst_and_list(unname(.jst_style_type_nouns[owners])),
                ", and this table is ", .jst_style_type_nouns[[type]], ".",
                fn = fn)
    }
    out[[k]] <- .jst_style_check_value(k, sec[[k]], vals[[k]], type, fn)
  }
  layer <- stats::setNames(list("the call", out), c("source", type))
  if (length(gen)) layer$general <- gen
  layer
}

#' Internal helper: where jtable() writes a file
#'
#' A path with a folder is used as given, and its folder must exist; a
#' bare name goes in the output folder, \code{joptions(output.dir = )},
#' created again here if it has been removed since it was set (as jsave()
#' re-creates data.dir), or in the working directory when none is set.
#'
#' @param file The file argument.
#' @return The path to write.
#' @keywords internal
.jst_table_out_path <- function(file) {
  if (grepl("[/\\\\]", file)) {
    out_dir <- dirname(file)
    if (!dir.exists(out_dir)) {
      .jst_stop("the folder does not exist:\n  ", .jst_norm_path(out_dir),
                fn = "jtable")
    }
    return(file)
  }
  out_dir <- getOption(".jst_options_output_dir", .jst_options_defaults$output.dir)
  if (is.null(out_dir)) return(file)
  if (.jst_create_data_dir(out_dir, fn = "jtable")) {
    .jst_msg(.jst_output_dir_created_note(out_dir))
  }
  file.path(out_dir, file)
}

#' Internal: the note for an output folder just created
#'
#' @param dir Character(1).
#' @keywords internal
.jst_output_dir_created_note <- function(dir) {
  .jst_data_dir_created_note(dir, what = "output")
}

#' Internal helper: the overwrite question before jtable() writes
#'
#' After every check that can stop the call (ruling R42's form, as
#' jsave()'s): a file that exists and overwrite = FALSE is a question where
#' the session can ask, and a stop with both ways out where it cannot. A
#' folder R cannot write to stops first.
#'
#' @param out_path The path.
#' @param overwrite Logical.
#' @param ask Logical; whether the session can ask (interactive()).
#' @param fn The user-facing function's name (jtable, jstyle).
#' @param noun What the call writes, for the kept-file note.
#' @return TRUE when the write may go ahead, FALSE when the question was
#'   answered no (a note says the file was kept); stops where the session
#'   cannot ask.
#' @keywords internal
.jst_table_overwrite_gate <- function(out_path, overwrite, ask = interactive(),
                                      fn = "jtable", noun = "table") {
  if (!.jst_lib_writable(dirname(out_path))) {
    .jst_stop("R cannot write to this folder:\n",
              "  ", .jst_norm_path(dirname(out_path)), "\n",
              "Nothing was written.\n",
              "Choose a folder you can write to and run ", fn, "() again.",
              fn = fn)
  }
  if (!file.exists(out_path) || isTRUE(overwrite)) return(TRUE)
  if (!ask) {
    .jst_stop("this file already exists:\n",
              "  ", .jst_norm_path(out_path), "\n",
              .jst_txt_keep_file, .jst_txt_add_overwrite, fn = fn)
  }
  ok <- .jst_confirm(
    paste0("This file already exists:\n  ", .jst_norm_path(out_path),
           "\nOverwrite? (y/n): "),
    paste0(.jst_txt_keep_file, .jst_txt_add_overwrite))
  if (!ok) {
    .jst_msg("The file was kept, and no ", noun, " was written.")
    return(FALSE)
  }
  TRUE
}

#' Internal helper: read headings = or markers = as groups of names
#'
#' A named list of variable names, bare or in quotes, a c() of either, or
#' a name holding names (ruling R18: a bare name that is one of the
#' results' variables is that variable, whatever the workspace holds; a
#' bare name that is not is read for the names it holds). Each element
#' needs a name: the heading's text, or the specific note's. NULL for an
#' argument not given.
#'
#' @param sub The argument as typed (\code{substitute()}).
#' @param env The caller's environment.
#' @param arg "headings" or "markers".
#' @param vars Character; the results' variables.
#' @return A named list of character vectors, or NULL.
#' @keywords internal
.jst_table_name_groups <- function(sub, env, arg, vars = character(0)) {
  if (is.null(sub)) return(NULL)
  if (is.symbol(sub)) {
    val <- tryCatch(eval(sub, env), error = function(e) NULL)
    if (is.null(val)) return(NULL)
    if (!is.list(val)) .jst_table_groups_stop(arg)
    sub <- as.call(c(as.name("list"), val))
  }
  if (!is.call(sub) || !identical(sub[[1L]], as.name("list"))) {
    .jst_table_groups_stop(arg)
  }
  items <- as.list(sub)[-1L]
  if (length(items) == 0L) return(NULL)
  nms <- names(items)
  if (is.null(nms) || any(!nzchar(nms))) {
    .jst_stop("each item of ", arg, " = needs a name, ",
              if (identical(arg, "headings")) "the heading's text"
              else "the note's text", ", for example:\n  ",
              .jst_table_groups_example(arg), fn = "jtable")
  }
  one <- function(e) {
    if (is.character(e) && !anyNA(e)) return(e)
    if (is.symbol(e)) {
      nm <- as.character(e)
      if (nm %in% vars) return(nm)
      val <- tryCatch(eval(e, env), error = function(err) NULL)
      if (is.character(val) && !anyNA(val) && length(val) >= 1L) return(val)
      return(nm)
    }
    if (is.call(e) && identical(e[[1L]], as.name("c")) && length(e) > 1L) {
      return(unlist(lapply(as.list(e)[-1L], one)))
    }
    .jst_table_groups_stop(arg)
  }
  out <- lapply(items, one)
  names(out) <- nms
  out
}

# The example line of the headings = and markers = stops.
.jst_table_groups_example <- function(arg) {
  if (identical(arg, "headings")) {
    "headings = list(\"Outcome\" = Wellbeing, \"Predictors\" = c(Age, Income))"
  } else {
    "markers = list(\"Mean-centered\" = c(Age, Income))"
  }
}

# The stop for a value that is not a named list.
.jst_table_groups_stop <- function(arg) {
  .jst_stop(arg, " = takes a named list of variable names, for example:\n  ",
            .jst_table_groups_example(arg), fn = "jtable")
}


# -----------------------------------------------------------------------------
# 8. jstyle() (build 2; ruling R46)
# -----------------------------------------------------------------------------

#' Show, list and copy table styles
#'
#' A style holds a table's look and a journal's or a report's conventions:
#' the font, the caption's form, the rules, the decimals, and for each
#' table type its columns and labels. \code{jstyle()} lists the styles
#' jstats can find; \code{jstyle("myjournal")} checks a style file and
#' prints every setting the style gives, marking each one it takes from
#' another style; and \code{jstyle("apa", save.as = "myjournal")} saves a
#' copy as a style file, myjournal.jstyle, every setting written out with
#' a note on what it does and what it takes, to edit in any text editor
#' (the step SPSS calls "Save TableLook As"). \code{jstyle("myjournal",
#' open = TRUE)} opens the file in the editor instead of printing it.
#'
#' jstats has two built-in styles: \code{"apa"}, APA 7's conventions for a
#' journal, and \code{"report"}, the plain look the report style manuals
#' share -- Arial 10, "Table 1:" and the title on one line, a light grey
#' header, an upright "Note:" -- based on apa. A style for an agency or an
#' institute is a copy of report with its own colors and font.
#'
#' Given settings, \code{jstyle(save.as =)} writes a short file instead: the
#' style it copies named on its based.on line, and only the settings given,
#' which is all a small change needs. A general setting is given by its
#' name; a table type's settings go in a list named for its section:
#' \code{jstyle("apa", save.as = "myapa", font = "Arial", regression =
#' list(fit.rows = c("r2", "n")))}.
#'
#' A style file is plain text: a setting is a name, an equals sign and a
#' value; a \code{#} starts a note; the general settings come first, then
#' one section per table type, \code{[descriptives]}, \code{[frequencies]},
#' \code{[regression]}, \code{[logistic]}, \code{[correlation]},
#' \code{[ttest]}, \code{[anova]}, \code{[crosstab]} and
#' \code{[reliability]}. A setting the file leaves out comes from the style
#' its \code{based.on} line names. \code{\link{jstyle_settings}} lists every
#' setting and what it takes. jstats looks for a style named in a call in
#' the style folder (\code{joptions(style.dir = )}), the working directory
#' and your jstats folder, in that order.
#'
#' @param style The style's name in quotes -- \code{"apa"}, \code{"report"}
#'   or a style file's -- or a path to a style file; NULL (the default)
#'   lists the styles, or with \code{save.as} or \code{open} copies or
#'   opens \code{joptions(style = )}.
#' @param save.as A name for the copy, in quotes: written as
#'   \code{<name>.jstyle} in the style folder when one is set, else in
#'   your jstats folder (\code{tools::R_user_dir("jstats")}), or to a path
#'   given with a folder. "apa" and "report" name the built-in styles, so
#'   neither can be a copy's name; a file named apa.jstyle or report.jstyle
#'   is not read, and jstats says so.
#' @param overwrite Logical. Replace a style file that exists? With FALSE
#'   (the default) an interactive session asks, and one that cannot ask
#'   stops.
#' @param open Logical. TRUE opens the style's file in the editor, as base
#'   R's \code{file.edit()} does (in RStudio, a tab beside your script),
#'   and prints no settings; the file is still checked, and a value it
#'   cannot use is named. With \code{save.as} it opens the file just
#'   written. Only in an interactive session: a script opens nothing. The
#'   built-in styles have no file; save a copy to open one.
#' @param ... Settings for a short copy, with \code{save.as}: a general
#'   setting by its name (\code{font = "Arial"}), a table type's settings
#'   in a list named for its section (\code{regression = list(fit.rows =
#'   "r2")}). \code{\link{jstyle_settings}} lists them all. Any other input
#'   stops with "unused input".
#' @return Invisibly: the styles found (a data frame of name and path),
#'   the style, or the path of the file written.
#'
#' @section Making a style with an AI assistant:
#' A style file is plain text, so an AI assistant can write one from an
#' example report. Give it a complete copy, which lists every setting and
#' what each takes -- \code{jstyle("report", save.as = "myagency")} writes
#' one; a short file hides the settings it takes from its base -- and the
#' example, with a request such as:
#' \preformatted{
#' Attached are myagency.jstyle, a jstats table style whose notes say what
#' each setting does and what it takes, and Report.pdf. Rewrite the style
#' file so that jstats tables look like the tables in the report, following
#' the instructions at the top of the file, and list what the settings
#' cannot reproduce.
#' }
#' Save its reply over the file and run \code{jstyle("myagency")}, which
#' names any value it cannot use (give that back to the assistant), then
#' try the style: \code{jtable(c1, style = "myagency", open = TRUE)}. An
#' assistant can reach only the looks the settings make; it is told to say
#' what it could not reproduce rather than invent a setting.
#'
#' @seealso \code{\link{jtable}} for the tables, \code{\link{jstyle_settings}}
#'   for every setting a style holds.
#'
#' @examples
#' # The styles jstats can find, and the folders it looks in
#' jstyle()
#'
#' # Every setting of the built-in styles
#' jstyle("apa")
#' jstyle("report")
#'
#' # A complete copy to edit, and a short one holding two changes
#' jstyle("apa", save.as = file.path(tempdir(), "myjournal"), overwrite = TRUE)
#' jstyle("apa", save.as = file.path(tempdir(), "myapa"), overwrite = TRUE,
#'        font = "Arial", regression = list(fit.rows = c("r2", "n")))
#'
#' @export
jstyle <- function(style = NULL, save.as = NULL, overwrite = FALSE,
                   open = FALSE, ...) {
  cl  <- sys.call()
  mc  <- match.call(expand.dots = TRUE)
  env <- parent.frame()
  # Settings for a short copy (Session 406): a general setting by its name,
  # a table type's in a list named for its section. Taken out of the dots
  # before the unused-input check; a name near a setting's gets that
  # check's did-you-mean.
  dots  <- rlang::enquos(...)
  dn    <- names(dots); if (is.null(dn)) dn <- rep("", length(dots))
  parts <- names(.jst_style_type_nouns)
  gen_keys <- names(.jst_style_spec$general)
  sec_only <- setdiff(unique(unlist(lapply(.jst_style_spec[parts], names))), gen_keys)
  is_set  <- nzchar(dn) & dn %in% c(gen_keys, parts)
  is_bare <- nzchar(dn) & dn %in% sec_only
  near <- character(0)
  for (nm in dn[nzchar(dn) & !is_set & !is_bare]) {
    nr <- .jst_style_near(nm, c(gen_keys, parts, sec_only))
    if (length(nr)) near[nm] <- nr
  }
  .jst_check_args(dots[!(is_set | is_bare)], aliases = near,
                  fn_name = "jstyle", positional = "refuse")
  .jst_word_args(cl, mc, env,
                 list(style = .jst_word_spec(c(names(.jst_style_builtin()),
                                               names(.jst_style_files())),
                                             "a style name")), "jstyle")
  .jst_free_text_arg(substitute(style), env, cl, mc, "style", "a style name", "jstyle")
  .jst_free_text_arg(substitute(save.as), env, cl, mc, "save.as", "a name", "jstyle")
  .jst_check_flag(overwrite, "overwrite")
  .jst_check_flag(open, "open")
  if (any(is_bare)) .jst_style_bare_stop(cl, dots[is_bare])
  if (anyDuplicated(dn[is_set])) {
    twice <- unique(dn[is_set][duplicated(dn[is_set])])
    .jst_stop(.jst_and_list(paste0(twice, " =")), " ",
              .jst_plural(length(twice), "is", "are"), " given twice.\n",
              "Give each setting once.", fn = "jstyle")
  }
  given <- dots[is_set]
  if (length(given) && is.null(save.as)) {
    .jst_stop("a style's settings are written to a new style file, so they ",
              "need save.as =, for example:\n",
              "  ", .jst_call_with(cl, mc, "save.as", "mystyle"), fn = "jstyle")
  }

  # open = TRUE (ruled Session 406, built Session 409): the style's file in
  # the editor, the printout skipped; with no style named, the session's
  # (as save.as copies it).
  if (is.null(save.as) && isTRUE(open)) {
    return(invisible(.jst_style_open_file(style, cl = cl, mc = mc)))
  }
  if (is.null(style) && is.null(save.as)) return(invisible(.jst_style_list_print()))
  st <- .jst_style_resolve(style, fn = "jstyle", cl = cl, mc = mc)
  if (is.null(save.as)) {
    .jst_style_print(st)
    return(invisible(st))
  }
  vals <- .jst_style_given(given)
  path <- .jst_style_save_path(save.as, from = st$name)
  write <- .jst_table_overwrite_gate(path, overwrite, ask = interactive(),
                                     fn = "jstyle", noun = "style")
  if (!write) return(invisible(NULL))
  name <- sub("\\.jstyle$", "", basename(path), ignore.case = TRUE)
  lines <- if (length(vals)) {
    src <- if (is.null(style)) getOption(".jst_options_style", .jst_options_defaults$style)
           else style
    based <- if (grepl("[/\\\\]", src)) .jst_norm_path(st$path) else st$name
    .jst_style_short_lines(name, based, vals)
  } else .jst_style_file_lines(st, name)
  con <- file(path, open = "wb")
  writeBin(charToRaw(enc2utf8(paste0(paste(lines, collapse = "\n"), "\n"))), con)
  close(con)
  .jst_msg_out(paste0("Style written to ", .jst_norm_path(path)))
  cat("\n")
  .jst_style_open(path, open)
  invisible(path)
}

#' Internal helper: open a style's file, for jstyle(open = TRUE)
#'
#' The style named -- or the session's, \code{joptions(style = )}, when
#' none is -- found as jstyle() finds it and handed to the editor, then
#' checked: a file holding a value jstats cannot use stops on that line
#' with the file already open, so it can be put right (Session 409). A
#' built-in style has no file, and the stop gives the line that saves a
#' copy and opens it. The session test and the opener are arguments, so a
#' battery can stand in for both and open nothing, as for jtable()'s
#' \code{open =}.
#'
#' @param style The style argument as given.
#' @param cl,mc The call, for the line a near miss offers.
#' @param ask Logical; whether the session is interactive.
#' @param edit The function that opens the file.
#' @return The style, resolved.
#' @keywords internal
.jst_style_open_file <- function(style, cl = NULL, mc = NULL,
                                 ask = interactive(), edit = utils::file.edit) {
  nm <- if (is.null(style)) {
    getOption(".jst_options_style", .jst_options_defaults$style)
  } else style
  if (is.character(nm) && length(nm) == 1L && !is.na(nm) && nzchar(trimws(nm))) {
    nm <- trimws(nm)
    b  <- tolower(sub("\\.jstyle$", "", nm, ignore.case = TRUE))
    if (!grepl("[/\\\\]", nm) && b %in% names(.jst_style_builtin())) {
      copy <- if (identical(b, "apa")) "myjournal" else paste0("my", b)
      .jst_stop("\"", b, "\" is built into jstats, so it has no file to open.\n",
                "Save a copy to open, for example:\n",
                "  jstyle(\"", b, "\", save.as = \"", copy, "\", open = TRUE)",
                fn = "jstyle")
    }
    .jst_style_open(.jst_style_find(nm, "jstyle", cl, mc), TRUE, ask = ask,
                    edit = edit)
  }
  .jst_style_resolve(style, fn = "jstyle", cl = cl, mc = mc)
}

#' Internal helper: hand a style file to the editor, when open = TRUE asks
#'
#' Only in an interactive session, with \code{utils::file.edit()}, which in
#' RStudio opens a tab in the editor pane (a script, a rendered page or a
#' check opens nothing). The session test and the opener are arguments so
#' a battery can stand in for both.
#'
#' @param path The file.
#' @param open Logical.
#' @param ask Logical; whether the session is interactive.
#' @param edit The function that opens the file.
#' @return TRUE when the file was handed to the editor, invisibly.
#' @keywords internal
.jst_style_open <- function(path, open, ask = interactive(),
                            edit = utils::file.edit) {
  if (!isTRUE(open) || !isTRUE(ask)) return(invisible(FALSE))
  edit(normalizePath(path, winslash = "/", mustWork = FALSE))
  invisible(TRUE)
}

#' Internal helper: a table type's setting given to jstyle() bare
#'
#' A setting of a table type's section goes in a list named for its
#' section (Session 406), since several sections can hold one name. The
#' stop gives the call rewritten: each such setting moved into a list for
#' the first section whose check takes its value; a value no section takes
#' stops with what the first section's setting takes.
#'
#' @param cl The call as typed.
#' @param bare The quosures given bare, named.
#' @keywords internal
.jst_style_bare_stop <- function(cl, bare) {
  parts <- names(.jst_style_type_nouns)
  moved <- list()
  owners_of <- list()
  for (k in names(bare)) {
    owners <- parts[vapply(parts, function(p) k %in% names(.jst_style_spec[[p]]),
                           logical(1))]
    owners_of[[k]] <- owners
    val <- rlang::eval_tidy(bare[[k]])
    fits <- owners[vapply(owners, function(p) {
      !inherits(tryCatch(.jst_style_check_value(k, .jst_style_spec[[p]][[k]], val,
                                                p, "jstyle"),
                         error = function(e) e), "error")
    }, logical(1))]
    if (!length(fits)) {
      .jst_style_check_value(k, .jst_style_spec[[owners[1L]]][[k]], val,
                             owners[1L], "jstyle")
    }
    sec <- fits[1L]
    moved[[sec]] <- c(moved[[sec]], stats::setNames(list(rlang::quo_get_expr(bare[[k]])), k))
  }
  items <- as.list(cl)
  keep  <- !(names(items) %in% names(bare)) | seq_along(items) == 1L
  items <- items[keep]
  for (sec in names(moved)) {
    old <- items[[sec]]
    add <- as.call(c(as.name("list"), moved[[sec]]))
    if (is.call(old) && identical(old[[1L]], as.name("list"))) {
      add <- as.call(c(as.list(old), moved[[sec]]))
    }
    items[[sec]] <- add
  }
  ks <- names(bare)
  many <- vapply(owners_of, length, integer(1)) > 1L
  lead <- if (length(ks) == 1L) {
    paste0(ks, " = is a setting of ",
           .jst_and_list(unname(.jst_style_type_nouns[owners_of[[1L]]])),
           ", so it goes in a list named for its section")
  } else {
    paste0(.jst_and_list(paste0(ks, " =")), " are settings of a table type, so ",
           "each goes in a list named for its section")
  }
  .jst_stop(lead, if (any(many)) ", for example:\n" else ":\n",
            "  ", .jst_term_text(as.call(items)), fn = "jstyle")
}

#' Internal helper: the settings given to jstyle(save.as =), checked
#'
#' Each general setting, and each setting in a section's list, checked as
#' a file's value is; a general setting may be given in a section's list,
#' as a file may set one in a section. A color is kept as it was typed (a
#' name reads as itself in the file), every other value as the file writes
#' it.
#'
#' @param given Named quosures: general settings and section lists.
#' @return A named list of parts (general first, then the sections in the
#'   file's order), each a named list of the values' text.
#' @keywords internal
.jst_style_given <- function(given) {
  parts <- names(.jst_style_type_nouns)
  out <- list()
  txt <- function(k, sp, val, part) {
    v <- .jst_style_check_value(k, sp, val, part, "jstyle")
    if (identical(sp$kind, "color") && is.character(val)) trimws(val)
    else .jst_style_value_out(v, sp)
  }
  for (k in names(given)) {
    val <- rlang::eval_tidy(given[[k]])
    if (k %in% parts) {
      if (!is.list(val) || !length(val) || is.null(names(val)) ||
          any(!nzchar(names(val)))) {
        .jst_stop(k, " = takes a list of the section's settings, each named, ",
                  "for example:\n",
                  "  ", k, " = list(", .jst_style_example_setting(k), ")",
                  fn = "jstyle")
      }
      if (anyDuplicated(names(val))) {
        .jst_stop(k, " = names ", names(val)[duplicated(names(val))][1L],
                  " twice.\nGive each setting once.", fn = "jstyle")
      }
      allowed <- c(names(.jst_style_spec[[k]]), names(.jst_style_spec$general))
      for (s in names(val)) {
        if (!s %in% allowed) {
          nr <- .jst_style_near(s, allowed)
          .jst_stop(s, " is not a setting of [", k, "].",
                    if (length(nr)) paste0("\nDid you mean ", nr, "?")
                    else paste0("\n", .jst_style_settings_line(k)), fn = "jstyle")
        }
        sp <- if (s %in% names(.jst_style_spec[[k]])) .jst_style_spec[[k]][[s]]
              else .jst_style_spec$general[[s]]
        out[[k]][[s]] <- txt(s, sp, val[[s]], k)
      }
    } else {
      out$general[[k]] <- txt(k, .jst_style_spec$general[[k]], val, "general")
    }
  }
  out[intersect(c("general", parts), names(out))]
}

#' Internal helper: one setting of a section, for an example line
#'
#' @param sec A table type.
#' @return Character(1): a setting and its apa value as R code.
#' @keywords internal
.jst_style_example_setting <- function(sec) {
  k  <- if ("columns" %in% names(.jst_style_spec[[sec]])) "columns"
        else names(.jst_style_spec[[sec]])[1L]
  v  <- .jst_style_apa[[sec]][[k]]
  paste0(k, " = ", paste(deparse(v), collapse = ""))
}

#' Internal helper: the lines of a short style file
#'
#' What jstyle(save.as =) writes when it is given settings (Session 406;
#' Jeff, Session 402: "if only the changes are listed, then it writes only
#' the changes with the 'based on' providing all other specs"): a header
#' saying so, the two stamps, based.on naming the style copied, then the
#' settings given -- the general ones first, then each section's under its
#' heading -- each after the note on what it does and what it takes. The
#' header is the file's name on a line of its own, then one sentence a
#' line, none wrapped (Session 407; Jeff: "each sentence should be on its
#' own line ... Notepad and other text editors should easily be able to
#' handle sentences that are relatively long without wrapping").
#'
#' @param name The new file's style name.
#' @param based The style copied: its name, or its path when it was given
#'   by path.
#' @param vals The settings (\code{.jst_style_given()}).
#' @keywords internal
.jst_style_short_lines <- function(name, based, vals) {
  # The style copied, by name: apa named as the built-in, since no file
  # holds it (Session 407; Jeff: "there really isn't an apa.jstyle file
  # since it's built in").
  base <- sub("\\.jstyle$", "", basename(based), ignore.case = TRUE)
  builtin <- !grepl("[/\\\\]", based) && tolower(base) %in% names(.jst_style_builtin())
  # Two built-ins since Session 409, so a built-in base is "a style built
  # into jstats"; the editing rule is the complete copy's and the
  # orientation's, with adding a setting from the list allowed here (the
  # presentation review's entry 7: one wording for the three texts).
  out <- c(paste0("# ", name, ".jstyle:"),
           paste0("# A jstats table style, based on ", base,
                  if (builtin) ", a style built into jstats", "."),
           paste0("# It lists only the settings that differ from ", base,
                  "; any setting not listed here takes ", base, "'s value."),
           "# ?jstyle_settings lists every setting and what it takes.",
           paste0("# Change only the values after the = signs, or add a setting ",
                  "from that list; do not invent a setting, and do not rename a ",
                  "setting or a section."),
           paste0("# jstyle(\"", name, "\") checks the file and names any value ",
                  "it cannot use."),
           "",
           paste0("format     = ", .jst_style_format),
           paste0("written.by = jstats ", .jst_jstats_version()),
           paste0("based.on   = ", if (grepl("#", based)) paste0("\"", based, "\"") else based))
  for (part in names(vals)) {
    out <- c(out, "", if (!identical(part, "general")) paste0("[", part, "]"))
    for (k in names(vals[[part]])) {
      sp <- if (!identical(part, "general") && k %in% names(.jst_style_spec[[part]]))
              .jst_style_spec[[part]][[k]] else .jst_style_spec$general[[k]]
      out <- c(out, paste0("# ", .jst_style_about_lines(sp$about)),
               .jst_style_note_lines(.jst_style_takes(sp, part)),
               paste0(k, " = ", vals[[part]][[k]]))
    }
  }
  out
}

#' Internal helper: a style file's "takes" note
#'
#' "# takes: ..." on one line, however long (Session 407: until then
#' broken at 76 columns onto lines opening "#   ", which Jeff found hard to
#' read; a text editor shows a long line whole).
#'
#' @param text Character(1), what the setting takes.
#' @return Character(1), the comment line.
#' @keywords internal
.jst_style_note_lines <- function(text) {
  paste0("# takes: ", text)
}

#' Internal helper: a setting's note, one line per choice
#'
#' A setting's \code{about} is held in lines; a line that opens on a
#' choice's name ("journal: ...") is a choice of its own, and any other
#' continues the line before it. The style file shows each choice on its
#' own line and the rest unwrapped (Session 407); the settings help page
#' joins the choices with "|".
#'
#' @param a Character, the setting's about.
#' @return Character, one element per line.
#' @keywords internal
.jst_style_about_lines <- function(a) {
  if (length(a) < 2L) return(a)
  starts <- c(TRUE, grepl("^[a-z]+: ", a[-1L]))
  vapply(split(a, cumsum(starts)), paste, character(1), collapse = " ",
         USE.NAMES = FALSE)
}

#' Internal helper: what a style setting takes, in words
#'
#' For the note on each setting in a style file and for the settings help
#' page (Session 406: a person, or an AI assistant, editing a file reads
#' there what a value may be).
#'
#' @param sp The setting's entry in \code{.jst_style_spec}.
#' @param part Its part: "general" or a table type.
#' @return Character(1).
#' @keywords internal
.jst_style_takes <- function(sp, part = "general") {
  switch(sp$kind,
    text    = if (isTRUE(sp$empty)) "any text, or nothing" else "any text",
    choice  = paste0("one of ", paste(sp$choices, collapse = " | ")),
    number  = paste0("a number from ", sp$min, " to ", sp$max),
    integer = paste0("a whole number from ", sp$min, " to ", sp$max),
    color   = paste0("a color name such as lightblue, or six hex digits such as ",
                     "ADD8E6", if (isTRUE(sp$header)) "; or header, or none"
                     else if (isTRUE(sp$none)) "; or none"),
    columns = paste0("one or more of ", paste(sp$cols, collapse = ", "),
                     ", in order, separated by commas",
                     if (isTRUE(sp$none)) "; or none"),
    stars   = "one to three p-values between 0 and 1, largest first",
    "")
}

#' Internal helper: where jstyle(save.as =) writes
#'
#' A name with a folder is written where it says (the folder must exist); a
#' bare name goes in the style folder when one is set, else in the per-user
#' folder, which is created here, by the user's own call (CRAN's rule: a
#' package writes there only when asked). The .jstyle extension is added
#' when the name has none; "apa" and "report" are the built-in styles'
#' names (Session 409), and a name in \code{.jst_style_reserved} would be
#' a built-in's still to come (Session 407).
#'
#' @param save.as The name given.
#' @param from Character(1); the name of the style the call copies, for the
#'   line a refused name offers (Session 409: the call's own style, where
#'   it was always apa).
#' @return The path to write.
#' @keywords internal
.jst_style_save_path <- function(save.as, from = "apa") {
  if (!is.character(save.as) || length(save.as) != 1L || is.na(save.as) ||
      !nzchar(trimws(save.as))) {
    .jst_stop("`save.as` must be a name in quotes, for example:\n",
              "  save.as = \"myjournal\"", fn = "jstyle")
  }
  nm <- trimws(save.as)
  .jst_check_path_chars(nm, what = "path")
  if (!grepl("\\.jstyle$", nm, ignore.case = TRUE)) {
    if (nzchar(tools::file_ext(basename(nm)))) {
      .jst_stop("save.as = names a file ending in .",
                tools::file_ext(basename(nm)), ", not .jstyle, which jstyle() ",
                "adds:\n  save.as = \"", tools::file_path_sans_ext(nm), "\"",
                fn = "jstyle")
    }
    nm <- paste0(nm, ".jstyle")
  }
  base <- sub("\\.jstyle$", "", basename(nm), ignore.case = TRUE)
  if (grepl("[<>:\"|?*]", base) || !nzchar(base)) {
    .jst_stop("\"", base, "\" cannot be a file's name.\n",
              "Use letters, digits, spaces, dashes, or underscores.",
              fn = "jstyle")
  }
  # A built-in's name, or one kept for a built-in to come: the line offered
  # copies the call's own style under "my" and the name (Session 409).
  example <- paste0("  jstyle(\"", from, "\", save.as = \"my", tolower(base), "\")")
  if (tolower(base) %in% names(.jst_style_builtin())) {
    .jst_stop("\"", base, "\" is the name of a style built into jstats.\n",
              "Give the copy another name, for example:\n", example,
              fn = "jstyle")
  }
  if (tolower(base) %in% .jst_style_reserved) {
    .jst_stop("\"", base, "\" is the name of a built-in style a later ",
              "version of jstats adds.\n",
              "Give the copy another name, for example:\n", example,
              fn = "jstyle")
  }
  if (grepl("[/\\\\]", nm)) {
    if (!dir.exists(dirname(nm))) {
      .jst_stop("the folder does not exist:\n  ", .jst_norm_path(dirname(nm)),
                fn = "jstyle")
    }
    return(nm)
  }
  sd  <- getOption(".jst_options_style_dir", .jst_options_defaults$style.dir)
  dir <- if (is.null(sd)) tools::R_user_dir("jstats", "data") else sd
  .jst_create_data_dir(dir, fn = "jstyle", what = "style")
  file.path(dir, nm)
}

#' Internal helper: print the styles jstats can find
#'
#' The built-in style, then every style file in the folders searched, the
#' first folder winning a name; the default marked; then the folders, in
#' the order they are searched.
#'
#' @return A data frame: name, path (NA for a built-in).
#' @keywords internal
.jst_style_list_print <- function() {
  files <- .jst_style_files()
  df <- data.frame(name = c(names(.jst_style_builtin()), names(files)),
                   path = c(rep(NA_character_, length(.jst_style_builtin())),
                            unname(files)),
                   stringsAsFactors = FALSE)
  def <- getOption(".jst_options_style", .jst_options_defaults$style)
  where <- ifelse(is.na(df$path), "built into jstats", .jst_norm_path(df$path))
  is_def <- tolower(df$name) == tolower(sub("\\.jstyle$", "", basename(def),
                                            ignore.case = TRUE))
  where[is_def] <- paste0(where[is_def], " (the default)")
  w <- max(nchar(df$name))
  .cat_red("Styles\n")
  cat(paste0("  ", formatC(df$name, width = -w), "  ", where, "\n"), sep = "")
  cat("\n")
  dirs <- .jst_style_dirs()
  .jst_msg_out("jstats looks for a style file in these folders, in this order:")
  for (i in seq_along(dirs)) {
    .jst_msg_out(paste0("  ", .jst_norm_path(dirs[[i]]), " (", names(dirs)[i],
                        if (!dir.exists(dirs[[i]])) ", not created yet", ")"))
  }
  cat("\n")
  # A file of a built-in's name is left out of the list above (Session 407).
  for (b in names(.jst_style_builtin())) {
    note <- .jst_style_shadowed_note(b, .jst_style_shadowed(b))
    if (!is.null(note)) {
      .jst_msg(note)
      cat("\n")
    }
  }
  invisible(df)
}

#' Internal helper: print every setting a style gives
#'
#' In the style file's own form -- the general settings, then each table
#' type's section -- so a line can be copied into a file. A setting the
#' style takes from another (based.on, or apa) says where it comes from.
#'
#' @param st A style.
#' @keywords internal
.jst_style_print <- function(st) {
  .cat_red(paste0("Style: ", st$name, "\n"))
  own <- st$layers[[1L]]$source
  if (!is.na(st$path)) {
    chain <- vapply(st$layers[-1L], function(L) L$source, character(1))
    .jst_msg_out(paste0("  ", .jst_norm_path(st$path)))
    .jst_msg_out(paste0("  based on ", paste(sub("\\.jstyle$", "", chain,
                                                 ignore.case = TRUE),
                                             collapse = ", then ")))
  } else {
    .jst_msg_out("  built into jstats")
    # A built-in based on another (report, on apa; Session 409).
    if (length(st$layers) > 1L) {
      .jst_msg_out(paste0("  based on ",
                          paste(vapply(st$layers[-1L], function(L) L$source,
                                       character(1)), collapse = ", then ")))
    }
  }
  cat("\n")
  for (part in c("general", names(.jst_style_type_nouns))) {
    if (!identical(part, "general")) cat("[", part, "]\n", sep = "")
    spec <- .jst_style_spec[[part]]
    keys <- names(spec)
    vals <- vapply(keys, function(k) {
      .jst_style_value_out(.jst_style_key(st, part, k), spec[[k]])
    }, character(1))
    from <- vapply(keys, function(k) .jst_style_key_source(st, part, k), character(1),
                   USE.NAMES = FALSE)
    w  <- max(nchar(keys)); vw <- min(max(nchar(vals)), 26L)
    for (i in seq_along(keys)) {
      line <- paste0(formatC(keys[i], width = -w), " = ", vals[i])
      if (!identical(from[i], own)) {
        line <- paste0(formatC(line, width = -(w + 3L + vw)), "  # from ",
                       sub("\\.jstyle$", "", from[i], ignore.case = TRUE))
      }
      cat(line, "\n", sep = "")
    }
    cat("\n")
  }
  invisible(NULL)
}

#' Internal helper: a style value as a file writes it
#'
#' A list of columns or thresholds joined by commas (.05, .01, .001); a
#' number as R prints it; a text value in double quotes when it is empty,
#' starts or ends with a space, starts with a quotation mark or holds a #.
#'
#' @param v The value.
#' @param sp Its entry in \code{.jst_style_spec}.
#' @keywords internal
.jst_style_value_out <- function(v, sp) {
  if (identical(sp$kind, "stars")) {
    return(paste(sub("^0", "", vapply(v, format, character(1), scientific = FALSE)),
                 collapse = ", "))
  }
  if (identical(sp$kind, "columns")) return(paste(v, collapse = ", "))
  if (is.numeric(v)) return(format(v, scientific = FALSE))
  v <- as.character(v)
  if (!nzchar(v) || grepl("^\\s|\\s$|^[\"']|#", v)) {
    return(paste0("\"", v, "\""))
  }
  v
}

#' Internal helper: the lines of a full style file
#'
#' Every setting of every part, each after a line saying what it does and
#' one saying what it takes (Session 406), the two stamps and based.on at
#' the top: the file jstyle(save.as =) writes when it is given no settings.
#' The header says to change values only, so the file can be handed to a
#' person or an AI assistant with a request: the file's name on a line of
#' its own, then one sentence a line, none wrapped (Session 407), and since
#' Session 409 a block for an assistant asked to match an example. based.on
#' names the built-in the copied style reaches first: report for a copy of
#' report or of a file based on it, else apa.
#'
#' @param st The style copied.
#' @param name The new file's style name.
#' @keywords internal
.jst_style_file_lines <- function(st, name) {
  heads <- c(general = "The general settings: the look of every table.",
             descriptives = "A descriptives table, from jdesc() results.",
             frequencies  = "A frequency table, from jfreq() results.",
             regression   = "A regression table, from jlm() results.",
             logistic     = "A logistic regression table, from jlogistic() results.",
             correlation  = "A correlation table, from a jcorr() result.",
             ttest        = "A t-test table, from jt() results.",
             anova        = "An ANOVA table, from jaov() results.",
             crosstab     = "A crosstab, from jcrosstab() results.",
             reliability  = "A reliability table, from jalpha() results.")
  # The header tells whoever edits the file -- a person, or an AI
  # assistant given the file's text -- what may change (Session 406). The
  # editing rule is worded as the short file's and the orientation's are
  # (Session 409, the presentation review's entry 7), and a block below it
  # addresses an assistant asked to match an example (Session 409; the AI
  # Integration record, Part 24).
  out <- c(paste0("# ", name, ".jstyle:"),
           "# A jstats table style.",
           paste0("# Every setting jstats has is below, each after a note saying ",
                  "what it does and what it takes."),
           paste0("# Change only the values after the = signs; do not invent a ",
                  "setting, and do not rename a setting or a section."),
           "# A line that starts with # is a note.",
           paste0("# jstyle(\"", name, "\") checks the file and names any value ",
                  "it cannot use."),
           "#",
           "# To an AI assistant asked to edit this file so tables look like an example:",
           paste0("# Change only the values after the = signs, using only the values ",
                  "each setting's \"# takes:\" line allows."),
           "# Keep every other line as it is, and return the whole file.",
           paste0("# Then say what the example has that these settings cannot make, ",
                  "rather than inventing a setting for it."))
  # A copy names as its base the built-in its style reaches first: report
  # for a copy of report, or of a file based on it, so a setting a later
  # jstats adds comes from report as the copy's others did; apa otherwise
  # (Session 409, build 1's lean, on Claude's default).
  srcs  <- vapply(st$layers, function(L) as.character(L$source), character(1))
  built <- srcs[tolower(srcs) %in% names(.jst_style_builtin())]
  out <- c(out, "",
           paste0("format     = ", .jst_style_format),
           paste0("written.by = jstats ", .jst_jstats_version()),
           paste0("based.on   = ", if (length(built)) tolower(built[1L]) else "apa"))
  for (part in c("general", names(.jst_style_type_nouns))) {
    out <- c(out, "", if (!identical(part, "general")) paste0("[", part, "]"),
             paste0("# ", heads[[part]]))
    spec <- .jst_style_spec[[part]]
    for (k in names(spec)) {
      out <- c(out, paste0("# ", .jst_style_about_lines(spec[[k]]$about)),
               .jst_style_note_lines(.jst_style_takes(spec[[k]], part)),
               paste0(k, " = ", .jst_style_value_out(.jst_style_key(st, part, k),
                                                     spec[[k]])))
    }
  }
  out
}


# -----------------------------------------------------------------------------
# 9. The settings help page (Session 406)
# -----------------------------------------------------------------------------

#' The settings of a table style
#'
#' @description
#' Every setting a jstats table style holds: the general settings, which
#' set the look of every table, then one section per table type, which set
#' that table's columns, labels and notes. A style file (see
#' \code{\link{jstyle}}) sets any of them; a setting it leaves out comes
#' from the style its based.on line names, and in the end from the
#' built-in apa style, whose value each entry gives -- with the built-in
#' report style's where it differs. A table type's setting can also be
#' given in a \code{\link{jtable}} call, for that table only.
#'
#' This page is made from the list jstats checks every style against, so
#' it names exactly what jstats accepts. A Greek letter in a label is
#' written in a style file as the letter itself; this page names it.
#'
#' @eval .jst_style_settings_rd()
#' @seealso \code{\link{jstyle}} to list, print and copy styles;
#'   \code{\link{jtable}} for the tables.
#' @name jstyle_settings
NULL

#' Internal helper: the settings help page's sections
#'
#' Generated from \code{.jst_style_spec} and \code{.jst_style_apa} when the
#' help is built (Session 402: "?jstyle_keys GENERATED from .jst_style_spec
#' when the help is built"; named jstyle_settings at Session 406), so the
#' page cannot drift from what jstats accepts: an example of the file's
#' form, then one section per part, each setting with what it does, what
#' it takes and apa's value. The text is plain ASCII: a Greek letter in a
#' value is written with \code{\\eqn}, its name the text form.
#'
#' @return Character: roxygen \code{@rawRd} tags.
#' @keywords internal
.jst_style_settings_rd <- function() {
  esc <- function(x) {
    x <- gsub("\\", "\\\\", x, fixed = TRUE)
    x <- gsub("%", "\\%", x, fixed = TRUE)
    x <- gsub("{", "\\{", x, fixed = TRUE)
    gsub("}", "\\}", x, fixed = TRUE)
  }
  greek <- function(x) {
    # Named with names<-, never inside c(): a name written in a call is
    # made in the session's own encoding, and a non-UTF-8 install warned
    # "unable to translate" for each (the S390 rule; Session 407).
    map <- c("\\eqn{\\eta^2}{eta^2}", "\\eqn{\\chi^2}{chi^2}",
             "\\eqn{\\beta}{beta}", "\\eqn{\\alpha}{alpha}")
    names(map) <- c("\u03b7\u00b2", "\u03c7\u00b2", "\u03b2", "\u03b1")
    for (g in names(map)) x <- gsub(g, map[[g]], x, fixed = TRUE)
    x
  }
  ascii <- function(x) !grepl("[^\001-\177]", x, perl = TRUE)
  value <- function(v, sp) {
    t <- .jst_style_value_out(v, sp)
    if (identical(t, "\"\"")) return("nothing")
    if (ascii(t)) paste0("\\code{", esc(t), "}") else greek(esc(t))
  }
  # A note's lines read as one sentence; a line that opens on a choice's
  # name ("journal: ...") is a choice of its own, set off with "|".
  about <- function(a) {
    sub("[.]$", "", paste(.jst_style_about_lines(a), collapse = " | "))
  }
  # The built-in report style, read as a call reads it, for the values it
  # sets (Session 409); built here, not resolved, so no folder is searched.
  rep_st <- .jst_style_object("report", NA_character_,
                              .jst_style_builtin_layers("report"))
  sec <- function(title, part) {
    spec  <- .jst_style_spec[[part]]
    items <- vapply(names(spec), function(k) {
      sp <- spec[[k]]
      a  <- .jst_style_key(.jst_style_apa, part, k)
      r  <- .jst_style_key(rep_st, part, k)
      paste0("\\item{\\code{", k, "}}{", esc(about(sp$about)),
             ". Takes ", esc(.jst_style_takes(sp, part)), ". In apa: ",
             value(.jst_style_apa[[part]][[k]], sp),
             if (!identical(a, r)) paste0("; in report: ", value(r, sp)), ".}")
    }, character(1))
    paste0("@rawRd \\section{", title, "}{\n\\describe{\n",
           paste(items, collapse = "\n"), "\n}\n}")
  }
  form <- paste0(
    "@rawRd \\section{In a style file}{\n",
    "A setting is its name, an equals sign and a value; a list of values is ",
    "separated by commas; a \\code{#} starts a note. The general settings come ",
    "first, then each table type's under its heading:\n",
    "\\preformatted{\n",
    "based.on = apa\n",
    "font     = Arial\n\n",
    "[regression]\n",
    "fit.rows = r2, n\n",
    "}\n",
    "A general setting may also be set in a table type's section, for that ",
    "table type only.\n}")
  out <- c(form, sec("General settings", "general"),
           vapply(names(.jst_style_type_nouns), function(p) {
             sec(paste0("[", p, "]: ", .jst_style_type_nouns[[p]]), p)
           }, character(1)))
  out <- unname(out)
  if (!all(ascii(out))) {
    stop(".jst_style_settings_rd(): text beyond ASCII", call. = FALSE)
  }
  out
}
