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
# Build 1 makes the DESCRIPTIVES table (Jeff's Table 1: variables under
# role headings) from jdesc() results. The other table types are later
# builds; a result of another class stops with a sentence saying so.
#
# jtable() is UNEXPORTED until the layer's last build (ruling R48): the
# batteries call it bare.


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
    header.fill      = "none",        # a colour fills the header cells
    header.text      = "000000",      # the header text colour
    header.bold      = "no",
    band.fill        = "none",        # a colour fills alternate data rows
    rules            = "apa",         # apa: top, under the header, bottom;
                                      # grid; outer; none
    rule.color       = "000000",
    note.label       = "Note.",       # "Notes:", "Source:"
    note.position    = "row",         # row (a merged last row) | paragraph
    note.size        = 12,
    note.n           = "yes",         # the general note opens on N
    decimals         = 2,             # statistics (a mean, an SD, b, SE)
    leading.zero     = "no",          # for a statistic bounded by 1: r, p,
                                      # beta, R2, eta2, alpha, V
    p.format         = "exact",       # exact | stars | both
    p.decimals       = 3,
    stars            = c(0.05, 0.01, 0.001),
    marks            = "letters",     # letters: superscript a, b, c; symbols:
                                      # dagger, double dagger, section sign
    minus            = "true",        # true: the minus sign; hyphen
    thousands        = "comma",       # comma | none, in counts and statistics
    landscape        = "auto",        # auto | yes | no
    line.spacing     = "single",      # single | double
    percent.decimals = 1              # a percentage's decimal places (build 2)
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
  )
)

# The column heads a style may italicize: APA sets a statistic's symbol in
# italics (n, M, SD, p, r, t, F, b, SE, R2), and a word (Min, Max,
# Variable) upright. Keyed by the column key, read by the builders.
.jst_tbl_italic_heads <- c("n", "mean", "sd", "p", "r", "t", "f", "b", "se",
                           "beta", "df", "r2", "adj.r2", "or", "wald", "d",
                           "eta2", "alpha", "item.total", "alpha.if.deleted")

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
    header.fill      = list(kind = "color", none = TRUE,
                            about = "a color filling the header cells, or none"),
    header.text      = list(kind = "color", about = "the color of the header's text"),
    header.bold      = list(kind = "choice", choices = c("yes", "no"),
                            about = "bold header text: yes | no"),
    band.fill        = list(kind = "color", none = TRUE,
                            about = "a color filling every other data row, or none"),
    rules            = list(kind = "choice", choices = c("apa", "grid", "outer", "none"),
                            about = c("apa: rules above and below the header and under the table",
                                      "grid: every cell | outer: a box | none")),
    rule.color       = list(kind = "color", about = "the color of the rules"),
    note.label       = list(kind = "text", empty = TRUE,
                            about = "the word the general note opens on: Note. | Notes: | Source:"),
    note.position    = list(kind = "choice", choices = c("row", "paragraph"),
                            about = "row: the table's last row | paragraph: under the table"),
    note.size        = list(kind = "number", min = 6, max = 72,
                            about = "the notes' text size, in points"),
    note.n           = list(kind = "choice", choices = c("yes", "no"),
                            about = "the general note opens on N, the number of cases: yes | no"),
    decimals         = list(kind = "integer", min = 0, max = 6,
                            about = "the decimal places of a statistic, such as a mean"),
    leading.zero     = list(kind = "choice", choices = c("yes", "no"),
                            about = c("the zero before the point of a statistic that cannot exceed 1,",
                                      "such as p: no writes .23 | yes writes 0.23")),
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
                            about = "the decimal places of a percentage")
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
  )
)

# The table types, as messages name them, in the file's section order.
.jst_style_type_nouns <- c(descriptives = "a descriptives table",
                           frequencies  = "a frequency table")

#' Internal helper: the built-in styles
#'
#' The styles jstats ships, by name. A name here always means the
#' built-in, so a style file cannot take one (\code{.jst_style_files()}
#' leaves them out).
#' @return A named list of style parts lists.
#' @keywords internal
.jst_style_builtin <- function() list(apa = .jst_style_apa)

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
    return(.jst_style_object(b, NA_character_,
                             list(c(list(source = b), builtin[[b]]))))
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
      if (grepl("^#?[0-9A-Fa-f]{6}$", s)) return(toupper(sub("^#", "", s)))
      if (tolower(s) %in% grDevices::colors()) {
        rgb <- grDevices::col2rgb(tolower(s))
        return(sprintf("%02X%02X%02X", rgb[1L], rgb[2L], rgb[3L]))
      }
      bad(if (isTRUE(sp$none)) {
        "\"none\", a color name such as \"navy\", or six hex digits such as \"1F3864\"."
      } else {
        "a color name such as \"navy\" or six hex digits such as \"1F3864\"."
      })
    },
    columns = {
      x <- tolower(items())
      if (!length(x) || any(!nzchar(x)) || any(!x %in% sp$cols) || anyDuplicated(x)) {
        bad(.jst_style_columns_req(sp$cols, type))
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
#' @return Character(1), the requirement a stop names.
#' @keywords internal
.jst_style_columns_req <- function(cols, type) {
  noun <- if (!is.null(type) && type %in% names(.jst_style_type_nouns))
            .jst_style_type_nouns[[type]] else "the table"
  paste0("columns of ", noun, ", each named once: ", .jst_choice_list(cols))
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
#' "<.01" at 2), the leading zero dropped as APA writes p; or stars alone;
#' or both, the stars after the value. NA is a blank cell.
#'
#' @param p Numeric vector.
#' @param format "exact", "stars" or "both".
#' @param decimals Integer.
#' @param stars The thresholds, largest first.
#' @keywords internal
.jst_tbl_p <- function(p, format = "exact", decimals = 3L,
                       stars = c(0.05, 0.01, 0.001)) {
  p <- suppressWarnings(as.numeric(p))
  floor_v <- 10^(-decimals)
  exact <- ifelse(is.na(p), "",
                  ifelse(p < floor_v,
                         paste0("<", sub("^0", "", sprintf(paste0("%.", decimals, "f"), floor_v))),
                         sub("^0\\.", ".", sprintf(paste0("%.", decimals, "f"), p))))
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
#' @return Character(1).
#' @keywords internal
.jst_tbl_stars_legend <- function(stars = c(0.05, 0.01, 0.001)) {
  st <- sort(as.numeric(stars), decreasing = TRUE)
  paste(vapply(seq_along(st), function(i) {
    paste0(strrep("*", i), "*p* < ", sub("^0", "", format(st[i])), ".")
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

# The classes with no builder yet stop in jtable()'s words.
.jst_table_build.default <- function(x, style, ...) {
  fn <- .jst_table_result_fn(x)
  .jst_stop("jtable() does not yet make a table from ",
            if (is.na(fn)) "this kind of result" else paste0("a ", fn, " result"),
            ".\nIt makes a table from a jdesc() or jfreq() result.", fn = "jtable")
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

  # One frame of terms, each variable with the heading its result's name
  # gives it (a list of results), carried into the heading rows below.
  frames <- lapply(seq_along(results), function(i) {
    r  <- results[[i]]
    tf <- .jst_apa_terms(r)
    if (is.null(tf)) {
      .jst_stop("this jdesc() result was made by ",
                .jst_table_result_version(r),
                ", before the fields a table needs were stored.\n",
                "Run the analysis again, then jtable() on the new result.",
                fn = "jtable")
    }
    if (!is.null(attr(tf, "by"))) {
      .jst_stop("jtable() does not yet make a table from a grouped ",
                "jdesc() result (one made with by =).", fn = "jtable")
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
      mean = .jst_tbl_num(raw$mean, dec, thou, TRUE, minus),
      sd   = .jst_tbl_num(raw$sd, dec, thou, TRUE, minus),
      min  = .jst_tbl_num(raw$min, mm_dp, thou, TRUE, minus),
      max  = .jst_tbl_num(raw$max, mm_dp, thou, TRUE, minus))
    rows[[length(rows) + 1L]] <- list(
      kind = "data", label = tf$var_label[i],
      indent = if (is.na(h)) 0L else 1L,
      marks = if (is.null(mark_of[[tf$variable[i]]])) character(0)
              else mark_of[[tf$variable[i]]],
      cells = cells[col_keys], raw = raw[col_keys])
  }

  # The notes: general (N, then the user's text), specific, probability
  # (none in a descriptives table).
  general <- character(0)
  if (identical(key("note.n"), "yes")) {
    pools <- unique(tf$n_pool)
    if (length(pools) == 1L && !is.na(pools)) {
      general <- paste0("*N* = ", .jst_tbl_count(pools, thou), ".")
    }
  }
  if (!is.null(note)) general <- c(general, note)

  .jst_table_new(
    type     = type,
    columns  = columns,
    rows     = rows,
    caption  = list(number = NA_integer_,
                    title  = if (is.null(title)) key("title") else title),
    notes    = list(general = general, specific = specific,
                    probability = character(0)),
    style    = style)
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
  pct   <- function(x) .jst_tbl_num(x, pdec, thou, TRUE, minus)

  # One block per variable: its rows (the accessor), its counts (the
  # model-level accessor), the heading its result's name gives it.
  blocks <- list()
  for (i in seq_along(results)) {
    r <- results[[i]]
    tf <- .jst_apa_terms(r); md <- .jst_apa_model(r)
    if (is.null(attr(r, "jstats_version", exact = TRUE)) || is.null(tf) ||
        is.null(md)) {
      .jst_stop("this jfreq() result was made by ",
                .jst_table_result_version(r),
                ", before the fields a table needs were stored.\n",
                "Run the analysis again, then jtable() on the new result.",
                fn = "jtable")
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

  # A category's name: its value label, else its code.
  cat_name <- function(code, label) {
    ifelse(!is.na(label) & nzchar(label), label,
           ifelse(is.na(code), key("missing.label"), as.character(code)))
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
    for (k in seq_len(nrow(valid))) {
      rows[[length(rows) + 1L]] <- data_row(
        cat_name(valid$code[k], valid$label[k]), base + 1L,
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
            cat_name(miss$code[k], miss$label[k]), base + 1L,
            list(n = miss$count[k], percent = miss$total_pct[k],
                 valid.percent = NA_real_, cumulative = NA_real_))
        }
      }
    }
  }

  # The notes: general (N when the variables share one pool, then the
  # user's text), specific; no probability note.
  general <- character(0)
  if (identical(key("note.n"), "yes")) {
    pools <- unique(vapply(blocks, function(b) as.numeric(b$n_total), numeric(1)))
    if (length(pools) == 1L && !is.na(pools)) {
      general <- paste0("*N* = ", .jst_tbl_count(pools, thou), ".")
    }
  }
  if (!is.null(note)) general <- c(general, note)

  .jst_table_new(
    type     = type,
    columns  = columns,
    rows     = rows,
    caption  = list(number = NA_integer_,
                    title  = if (is.null(title)) key("title") else title),
    notes    = list(general = general, specific = roles$specific,
                    probability = character(0)),
    style    = style)
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
  # indent.
  stub <- vapply(tbl$rows, function(r) {
    paste0(strrep(" ", 2L * r$indent), txt(r$label),
           if (length(r$marks)) paste0(.jst_table_mark_text(r$marks), collapse = "")
           else "")
  }, character(1))
  # The number columns: whole part and tail (the point and what follows),
  # so the cells align on the point as a decimal tab aligns them.
  body <- lapply(seq_len(nc)[-1L], function(j) {
    k <- cols$key[j]
    vapply(tbl$rows, function(r) {
      if (identical(r$kind, "heading")) "" else txt(r$cells[[k]])
    }, character(1))
  })
  split_num <- function(s) {
    is_num <- grepl("^[-+]?[0-9]", s)
    head <- ifelse(is_num, sub("^([-+]?[0-9,]*)(.*)$", "\\1", s), s)
    tail <- ifelse(is_num, sub("^([-+]?[0-9,]*)(.*)$", "\\2", s), "")
    list(head = head, tail = tail)
  }
  parts  <- lapply(body, split_num)
  heads  <- cols$label
  widths <- integer(nc)
  widths[1L] <- max(.jst_dw(heads[1L]), .jst_dw(stub), 0L)
  for (j in seq_len(nc)[-1L]) {
    p  <- parts[[j - 1L]]
    hw <- max(.jst_dw(p$head), 0L); tw <- max(.jst_dw(p$tail), 0L)
    widths[j] <- max(.jst_dw(heads[j]), hw + tw)
  }
  gap <- "  "
  total <- sum(widths) + 2L * (nc - 1L)
  rule  <- strrep("-", total)
  pad_l <- function(s, w) paste0(s, strrep(" ", pmax(0L, w - .jst_dw(s))))
  pad_r <- function(s, w) paste0(strrep(" ", pmax(0L, w - .jst_dw(s))), s)
  ctr   <- function(s, w) {
    extra <- pmax(0L, w - .jst_dw(s)); left <- extra - extra %/% 2L
    paste0(strrep(" ", left), s, strrep(" ", extra - left))
  }
  emit <- function(line) cat(sub("[ ]+$", "", line), "\n", sep = "")

  # The caption.
  form <- key("caption.form")
  cap  <- paste0("Table ", number)
  if (identical(form, "apa")) {
    cat(cap, "\n", tbl$caption$title, "\n", sep = "")
  } else if (identical(form, "report")) {
    cat(cap, ": ", tbl$caption$title, "\n", sep = "")
  } else {
    cat(cap, ". ", tbl$caption$title, "\n", sep = "")
  }
  emit(rule)
  # Spanners, centered over their columns.
  if (length(tbl$spanners)) {
    line <- ""
    at <- 1L
    for (sp in tbl$spanners) {
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
  # The rows.
  for (i in seq_along(tbl$rows)) {
    cells <- pad_l(stub[i], widths[1L])
    for (j in seq_len(nc)[-1L]) {
      p  <- parts[[j - 1L]]
      hw <- max(.jst_dw(p$head), 0L); tw <- max(.jst_dw(p$tail), 0L)
      cell <- paste0(pad_r(p$head[i], hw), pad_l(p$tail[i], tw))
      cells <- c(cells, pad_r(cell, widths[j]))
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
    out <- c(out, paste0("*", key("note.label"), "* ", paste(gen, collapse = " ")))
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
    out <- gsub("\\^([^^]+)\\^", "\\1", out)
    out <- gsub("\\*([^*]+)\\*", "\\1", out)
    out <- gsub("\u2212", "-", out, fixed = TRUE)
  }
  out
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

#' Internal helper: the runs of a marked-up note line
#'
#' Reads the light markup: *text* italic, ^text^ superscript.
#'
#' @param s Character(1); the line.
#' @param size Points.
#' @keywords internal
.jst_docx_markup_runs <- function(s, size = NULL) {
  out <- character(0)
  rest <- s
  while (nzchar(rest)) {
    m <- regexpr("\\*[^*]+\\*|\\^[^^]+\\^", rest)
    if (m < 0L) {
      out <- c(out, .jst_docx_run(rest, size = size)); break
    }
    if (m > 1L) out <- c(out, .jst_docx_run(substr(rest, 1L, m - 1L), size = size))
    tok <- substr(rest, m, m + attr(m, "match.length") - 1L)
    inner <- substr(tok, 2L, nchar(tok) - 1L)
    out <- c(out, if (startsWith(tok, "*"))
      .jst_docx_run(inner, italic = TRUE, size = size)
      else .jst_docx_run(inner, superscript = TRUE, size = size))
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
#' @keywords internal
.jst_docx_par <- function(runs, style = NULL, jc = NULL, ind = NULL,
                          tab = NULL, keep_next = FALSE,
                          spacing_after = NULL, line = "single") {
  ppr <- c(if (!is.null(style)) paste0("<w:pStyle w:val=\"", style, "\"/>"),
           if (keep_next) "<w:keepNext/>",
           if (!is.null(tab)) paste0("<w:tabs><w:tab w:val=\"decimal\" w:pos=\"",
                                     tab, "\"/></w:tabs>"),
           paste0("<w:spacing w:before=\"0\" w:after=\"",
                  if (is.null(spacing_after)) 0 else spacing_after * 20,
                  "\" w:line=\"", if (identical(line, "double")) 480 else 240,
                  "\" w:lineRule=\"auto\"/>"),
           if (!is.null(ind)) paste0("<w:ind w:left=\"", ind, "\"/>"),
           if (!is.null(jc)) paste0("<w:jc w:val=\"", jc, "\"/>"))
  paste0("<w:p><w:pPr>", paste(ppr, collapse = ""), "</w:pPr>", runs, "</w:p>")
}

#' Internal helper: the caption's runs -- "Table 1" on Word's SEQ field
#'
#' @param number The cached number.
#' @param bold Logical.
#' @param size Points.
#' @keywords internal
.jst_docx_seq_runs <- function(number, bold = TRUE, size = NULL) {
  rpr <- paste0("<w:rPr>", if (bold) "<w:b/>",
                if (!is.null(size)) paste0("<w:sz w:val=\"", size * 2, "\"/>"),
                "</w:rPr>")
  paste0(.jst_docx_run("Table ", bold = bold, size = size),
         "<w:r>", rpr, "<w:fldChar w:fldCharType=\"begin\"/></w:r>",
         "<w:r>", rpr, "<w:instrText xml:space=\"preserve\"> SEQ Table \\* ARABIC </w:instrText></w:r>",
         "<w:r>", rpr, "<w:fldChar w:fldCharType=\"separate\"/></w:r>",
         .jst_docx_run(as.character(number), bold = bold, size = size),
         "<w:r>", rpr, "<w:fldChar w:fldCharType=\"end\"/></w:r>")
}

#' Internal helper: the caption paragraphs of a table
#'
#' @param tbl A jst_table.
#' @param style The style list.
#' @param number The table's number.
#' @return Character; one or two paragraphs' XML.
#' @keywords internal
.jst_docx_caption_pars <- function(tbl, style, number) {
  key  <- function(k) .jst_style_key(style, tbl$type, k)
  form <- key("caption.form"); size <- key("caption.size")
  title <- tbl$caption$title
  if (identical(form, "apa")) {
    c(.jst_docx_par(.jst_docx_seq_runs(number, TRUE, size), style = "Caption",
                    keep_next = TRUE),
      .jst_docx_par(.jst_docx_run(title, italic = TRUE, size = size),
                    keep_next = TRUE, spacing_after = 6))
  } else if (identical(form, "report")) {
    .jst_docx_par(paste0(.jst_docx_seq_runs(number, TRUE, size),
                         .jst_docx_run(paste0(": ", title), bold = TRUE, size = size)),
                  style = "Caption", keep_next = TRUE, spacing_after = 6)
  } else {
    .jst_docx_par(paste0(.jst_docx_seq_runs(number, TRUE, size),
                         .jst_docx_run(".", bold = TRUE, size = size),
                         .jst_docx_run(paste0(" ", title), size = size)),
                  style = "Caption", keep_next = TRUE, spacing_after = 6)
  }
}

#' Internal helper: the note paragraphs of a table
#'
#' @param tbl A jst_table.
#' @param style The style list.
#' @param keep_next Logical; for a note inside a row.
#' @return Character; one paragraph per note line.
#' @keywords internal
.jst_docx_note_pars <- function(tbl, style, keep_next = FALSE) {
  size  <- .jst_style_key(style, tbl$type, "note.size")
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
#' @keywords internal
.jst_docx_text_width <- function(s, size, digits = FALSE) {
  em <- size * 20
  as.integer(ceiling(max(vapply(s, .jst_docx_em_width, numeric(1)), 0) * em))
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
# The minus sign, the dagger, the double dagger, the section sign and
# four Greek letters, named with names<-: a name written in a call is a
# symbol the parser makes in the session's own encoding (Session 390).
.jst_docx_char_widths <- c(
  .jst_docx_char_widths,
  stats::setNames(c(564, 500, 500, 500, 500, 500, 500, 500),
                  c("\u2212", "\u2020", "\u2021", "\u00a7",
                    "\u03b2", "\u03b7", "\u03b1", "\u03c7")))

#' Internal helper: a text's width in ems, with a small allowance
#'
#' @param x Character(1).
#' @keywords internal
.jst_docx_em_width <- function(x) {
  if (is.na(x) || !nzchar(x)) return(0)
  ch <- strsplit(x, "", fixed = TRUE)[[1L]]
  w  <- .jst_docx_char_widths[ch]
  w[is.na(w)] <- ifelse(.jst_dw(ch[is.na(w)]) > 1L, 1000, 500)
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
#' @return Character(1); the w:tbl element.
#' @keywords internal
.jst_docx_table <- function(tbl, style, number, widths) {
  type <- tbl$type
  key  <- function(k) .jst_style_key(style, type, k)
  cols <- tbl$columns; nc <- nrow(cols)
  size <- key("size"); line <- key("line.spacing")
  rules <- key("rules"); rcol <- key("rule.color")
  hfill <- key("header.fill"); bfill <- key("band.fill")
  hfill <- if (identical(hfill, "none")) NULL else hfill
  bfill <- if (identical(bfill, "none")) NULL else bfill
  htext <- key("header.text"); hbold <- identical(key("header.bold"), "yes")
  cap_row  <- identical(key("caption.position"), "row")
  note_row <- identical(key("note.position"), "row")
  margin   <- 108L
  total    <- sum(widths)
  dec_tabs <- .jst_docx_decimal_tabs(tbl, widths, size, margin)

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
  # header when the table breaks across pages.
  if (cap_row) {
    pars <- paste(.jst_docx_caption_pars(tbl, style, number), collapse = "")
    rows_xml <- c(rows_xml,
                  paste0("<w:tr><w:trPr><w:cantSplit/><w:tblHeader/></w:trPr>",
                         .jst_docx_cell(pars, total, nil, span = nc), "</w:tr>"))
  }

  # Spanners over the header (none in a descriptives table).
  if (length(tbl$spanners)) {
    cells <- character(0); at <- 1L
    for (sp in tbl$spanners) {
      if (sp$from > at) {
        for (j in at:(sp$from - 1L)) {
          cells <- c(cells, .jst_docx_cell(
            .jst_docx_par("", keep_next = TRUE, line = line), widths[j],
            .jst_docx_borders(rules, draw_h, FALSE, grid || (outer && j == 1L),
                              grid || (outer && j == nc), rcol), fill = hfill))
        }
      }
      w <- sum(widths[sp$from:sp$to])
      cells <- c(cells, .jst_docx_cell(
        .jst_docx_par(.jst_docx_run(sp$label, bold = hbold, color = htext, size = size),
                      jc = "center", keep_next = TRUE, line = line), w,
        .jst_docx_borders(rules, draw_h, TRUE, grid || (outer && sp$from == 1L),
                          grid || (outer && sp$to == nc), rcol),
        span = sp$to - sp$from + 1L, fill = hfill))
      at <- sp$to + 1L
    }
    if (at <= nc) for (j in at:nc) {
      cells <- c(cells, .jst_docx_cell(
        .jst_docx_par("", keep_next = TRUE, line = line), widths[j],
        .jst_docx_borders(rules, draw_h, FALSE, grid || (outer && j == 1L),
                          grid || (outer && j == nc), rcol), fill = hfill))
    }
    rows_xml <- c(rows_xml, paste0("<w:tr><w:trPr><w:cantSplit/><w:tblHeader/></w:trPr>",
                                   paste(cells, collapse = ""), "</w:tr>"))
  }

  # The header row.
  cells <- vapply(seq_len(nc), function(j) {
    runs <- .jst_docx_run(cols$label[j], bold = hbold, italic = cols$italic[j],
                          color = htext, size = size)
    .jst_docx_cell(
      .jst_docx_par(runs, jc = if (j == 1L) "left" else "center",
                    keep_next = TRUE, line = line),
      widths[j],
      .jst_docx_borders(rules, draw_h && !length(tbl$spanners), draw_h,
                        grid || (outer && j == 1L), grid || (outer && j == nc), rcol),
      fill = hfill)
  }, character(1))
  rows_xml <- c(rows_xml, paste0("<w:tr><w:trPr><w:cantSplit/><w:tblHeader/></w:trPr>",
                                 paste(cells, collapse = ""), "</w:tr>"))

  # The data and heading rows.
  gh  <- key("group.headings")
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
      emph <- if (identical(r$level, "variable")) key("variable.headings") else gh
      runs <- paste0(.jst_docx_run(r$label, bold = identical(emph, "bold"),
                                   italic = identical(emph, "italic"), size = size),
                     if (length(r$marks)) .jst_docx_run(paste(r$marks, collapse = ","),
                                                        superscript = TRUE, size = size))
      borders <- .jst_docx_borders(rules, grid, bottom, grid || outer, grid || outer, rcol)
      rows_xml <- c(rows_xml, paste0(
        "<w:tr><w:trPr><w:cantSplit/></w:trPr>",
        .jst_docx_cell(.jst_docx_par(runs, ind = if (isTRUE(r$indent > 0L))
                                                   180L * r$indent else NULL,
                                     keep_next = keep, line = line),
                       total, borders, span = nc),
        "</w:tr>"))
      next
    }
    band <- band + 1L
    if (!is.null(bfill) && band %% 2L == 0L) fill <- bfill
    cells <- character(nc)
    stub_runs <- paste0(.jst_docx_run(r$label, size = size),
                        if (length(r$marks)) .jst_docx_run(paste(r$marks, collapse = ","),
                                                           superscript = TRUE, size = size))
    cells[1L] <- .jst_docx_cell(
      .jst_docx_par(stub_runs, ind = if (r$indent > 0L) 180L * r$indent else NULL,
                    keep_next = keep, line = line),
      widths[1L],
      .jst_docx_borders(rules, grid, bottom, grid || outer, grid, rcol), fill = fill)
    for (j in seq_len(nc)[-1L]) {
      k <- cols$key[j]
      s <- r$cells[[k]]
      runs <- if (is.null(s) || !nzchar(s)) "" else .jst_docx_run(s, size = size)
      cells[j] <- .jst_docx_cell(
        .jst_docx_par(runs, tab = dec_tabs[j], keep_next = keep, line = line),
        widths[j],
        .jst_docx_borders(rules, grid, bottom, grid, grid || (outer && j == nc), rcol),
        fill = fill)
    }
    rows_xml <- c(rows_xml, paste0("<w:tr><w:trPr><w:cantSplit/></w:trPr>",
                                   paste(cells, collapse = ""), "</w:tr>"))
  }

  # A note row: the notes' paragraphs, no borders.
  if (note_row) {
    pars <- .jst_docx_note_pars(tbl, style, keep_next = FALSE)
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
#' From the widest text each column holds at the style's size, plus the
#' cell margins; the stub from its labels and their indents.
#'
#' @param tbl A jst_table.
#' @param style The style list.
#' @return Integer vector, one per column.
#' @keywords internal
.jst_docx_widths <- function(tbl, style) {
  size <- .jst_style_key(style, tbl$type, "size")
  cols <- tbl$columns; nc <- nrow(cols)
  margin <- 108L
  stub_text <- vapply(tbl$rows, function(r) {
    paste0(strrep("  ", r$indent), r$label, paste(r$marks, collapse = ""))
  }, character(1))
  w <- integer(nc)
  w[1L] <- max(.jst_docx_text_width(c(stub_text, cols$label[1L]), size)) + 2L * margin
  for (j in seq_len(nc)[-1L]) {
    k <- cols$key[j]
    cells <- vapply(tbl$rows, function(r) {
      s <- r$cells[[k]]; if (is.null(s)) "" else s
    }, character(1))
    w[j] <- max(.jst_docx_text_width(cells, size, digits = TRUE),
                .jst_docx_text_width(cols$label[j], size)) + 2L * margin + 120L
  }
  as.integer(w)
}

#' Internal helper: the decimal tab position of each number column
#'
#' Measured from the cell's left text edge: the block of numbers -- the
#' widest whole part and the widest tail (the point and the digits after
#' it, and any stars) -- centered in the cell's inner width, and never past
#' the inner width less the widest tail (Session 401; until then every
#' block sat at that right-hand limit).
#'
#' @param tbl A jst_table.
#' @param widths The column widths.
#' @param size Points.
#' @param margin The cell margin.
#' @return Integer vector; NA for the stub.
#' @keywords internal
.jst_docx_decimal_tabs <- function(tbl, widths, size, margin) {
  cols <- tbl$columns; nc <- nrow(cols)
  out  <- rep(NA_integer_, nc)
  for (j in seq_len(nc)[-1L]) {
    k <- cols$key[j]
    cells <- vapply(tbl$rows, function(r) {
      s <- r$cells[[k]]; if (is.null(s)) "" else s
    }, character(1))
    tails <- ifelse(grepl("[.]", cells), sub("^[^.]*", "", cells),
                    sub("^[-\u2212+0-9,]*", "", cells))
    heads <- substr(cells, 1L, nchar(cells) - nchar(tails))
    tail_w <- .jst_docx_text_width(tails, size, digits = TRUE)
    head_w <- .jst_docx_text_width(heads, size, digits = TRUE)
    # The block of numbers centered in the cell (Session 401: under a head
    # wider than its numbers, "Valid %", the block had sat at the right),
    # and short of the cell's right edge: a stop at or past it is no stop
    # to LibreOffice, which then tabs to its default stops and wraps.
    inner  <- widths[j] - 2L * margin
    out[j] <- as.integer(min(inner - tail_w - 40L,
                             floor((inner + head_w - tail_w) / 2)))
  }
  out
}

#' Internal helper: the body of a document holding tables
#'
#' Each table's caption, table and notes (paragraphs or rows by the style),
#' an empty paragraph between tables, and the section properties: the
#' page, landscape when the style says so or when auto finds the table
#' wider than the portrait text width.
#'
#' @param tables A list of jst_table.
#' @param style The style list.
#' @return A list: xml (the document part) and landscape (logical).
#' @keywords internal
.jst_docx_document <- function(tables, style) {
  body <- character(0)
  paper <- .jst_style_key(style, "general", "paper")
  land_key <- .jst_style_key(style, "general", "landscape")
  portrait <- .jst_docx_page(paper, FALSE)
  # Each table in the style it was built under (the page and the fonts are
  # the document's style).
  styles <- lapply(tables, .jst_table_style, style = style)
  all_widths <- mapply(.jst_docx_widths, tables, styles, SIMPLIFY = FALSE)
  natural <- vapply(all_widths, sum, integer(1))
  landscape <- identical(land_key, "yes") ||
    (identical(land_key, "auto") && any(natural > portrait$text))
  page <- .jst_docx_page(paper, landscape)
  for (i in seq_along(tables)) {
    tbl <- tables[[i]]
    tst <- styles[[i]]
    widths <- all_widths[[i]]
    # A table wider than the page is shrunk to it, every column in
    # proportion.
    if (sum(widths) > page$text) {
      widths <- as.integer(floor(widths * page$text / sum(widths)))
    }
    key <- function(k) .jst_style_key(tst, tbl$type, k)
    if (!identical(key("caption.position"), "row")) {
      body <- c(body, .jst_docx_caption_pars(tbl, tst, i))
    }
    body <- c(body, .jst_docx_table(tbl, tst, i, widths))
    if (!identical(key("note.position"), "row")) {
      body <- c(body, .jst_docx_note_pars(tbl, tst))
    }
    if (i < length(tables)) body <- c(body, .jst_docx_par(""))
  }
  sect <- paste0("<w:sectPr><w:pgSz w:w=\"", page$w, "\" w:h=\"", page$h, "\"",
                 if (landscape) " w:orient=\"landscape\"", "/>",
                 "<w:pgMar w:top=\"1440\" w:right=\"1440\" w:bottom=\"1440\" ",
                 "w:left=\"1440\" w:header=\"708\" w:footer=\"708\" w:gutter=\"0\"/>",
                 "</w:sectPr>")
  xml <- paste0("<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>\n",
                "<w:document xmlns:w=\"", .jst_docx_ns, "\"><w:body>",
                paste(body, collapse = ""), sect, "</w:body></w:document>")
  list(xml = xml, landscape = landscape)
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
#' @return A named list of parts: path in the package, then the text.
#' @keywords internal
.jst_docx_parts <- function(tables, style) {
  doc <- .jst_docx_document(tables, style)
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
#' \code{jtable()} turns a saved analysis result into a publication table:
#' it prints a preview in the console and, when \code{file} is given,
#' writes the table to a Word file (.docx) that opens in Word, LibreOffice
#' and Google Docs. The table's look and conventions come from a style --
#' the built-in \code{"apa"} style, or a style file of your own (see
#' \code{jstyle()}); the preview is a facsimile of the Word table, so what
#' prints is what the file holds.
#'
#' This version makes two table types: a descriptives table from one or
#' more \code{\link{jdesc}} results, and a frequency table from one or
#' more \code{\link{jfreq}} results -- each variable's label on a row of
#' its own, its categories indented under it. The variables go under role
#' headings when \code{headings} names them, and each specific note's
#' variables are marked when \code{markers} names them. Further table
#' types follow.
#'
#' @param x A saved result -- what an analysis function returns, kept with
#'   \code{<-} -- or a list of them. A list of \code{jdesc()} results, or
#'   of \code{jfreq()} results, stacks into one table, each result's
#'   variables under its name in the list when the list is named. A table
#'   \code{jtable()} has already built, or a list of them, goes to the file
#'   as it is, the tables in the order given and numbered so.
#' @param headings A named list: each heading and the variables under it,
#'   bare or in quotes, e.g. \code{list("Dependent variable" = Wellbeing,
#'   "Independent variables" = c(Income, Age))}. Every variable of the
#'   result goes under one heading; the table follows the list's order.
#' @param markers A named list: each specific note's text and the
#'   variables it marks, e.g. \code{list("Mean-centered" = c(Income,
#'   Age))}. The style assigns the marks (superscript letters under APA),
#'   sets each on its rows' labels, and writes the note under the table.
#' @param title The table's title; the style's title when NULL.
#' @param note The general note's text, after the N the style writes;
#'   \code{*text*} sets a word in italics. NULL for none.
#' @param file The Word file to write, with its .docx extension: a bare
#'   name goes in the output folder (\code{joptions(output.dir = )}) or the
#'   working directory; a path with a folder goes there. NULL writes
#'   nothing.
#' @param style The style's name in quotes: \code{"apa"}, or the name of a
#'   style file (\code{"myjournal"} for myjournal.jstyle), looked for in
#'   the style folder (\code{joptions(style.dir = )}), the working
#'   directory and your jstats folder; or a path to one. NULL (the
#'   default) uses \code{joptions(style = )}, apa when it is not set.
#' @param overwrite Logical. Replace a file that exists? With FALSE (the
#'   default) an interactive session asks, and one that cannot ask stops.
#' @param open Logical. TRUE opens the file once it is written, in the
#'   program your computer opens .docx files with; only in an interactive
#'   session, so a script or a rendered page opens nothing. Needs
#'   \code{file}.
#' @param print Print the preview? NULL (the default) follows the
#'   \code{\link{joutput}} level: the preview prints unless the level is
#'   \code{"silent"}. TRUE prints it under any level; FALSE prints nothing
#'   and writes the file alone.
#' @param ... A setting of the table type's section of the style, for this
#'   table only, e.g. \code{columns = c("mean", "sd")} for a descriptives
#'   table or \code{missing.rows = "none"} for a frequency table: the call
#'   outranks the style file. The general settings (the font, the caption's
#'   form, the decimals) are the style file's. Any other input stops with
#'   "unused input".
#'
#' @return The table, invisibly: an object of class \code{jst_table},
#'   which prints its preview when typed.
#'
#' @keywords internal
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
  gen_given <- intersect(names(over_q), gen_keys)
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
  word_specs <- list(style = .jst_word_spec(c("apa", names(.jst_style_files())),
                                            "a style name"))
  text_keys <- character(0)
  for (k in names(over_q)) {
    sps <- Filter(Negate(is.null), lapply(.jst_style_spec[types], `[[`, k))
    vals <- unique(unlist(lapply(sps, function(sp) c(sp$choices, sp$cols))))
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
      .jst_stop("jtable() writes Word files, so the file name needs the ",
                ".docx extension, for example:\n  file = \"",
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
  # discarded, and only the table prints. Errors and warnings pass.
  x <- .jst_output_scope(FALSE, x)
  results <- if (is.list(x) && !inherits(x, c(.jst_apa_classes, "jst_table"))) x
             else list(x)
  if (length(results) == 0L) {
    .jst_stop("the list given to jtable() is empty.")
  }
  # Built tables -- one, or a list of them -- go to the file as they are,
  # in the order given, each previewed with its number: the document call
  # of the reference's Part 2.2 in its first form. A built table beside a
  # result is refused: a result is built first. A built table keeps the
  # style it was built under.
  built <- vapply(results, inherits, logical(1), "jst_table")
  if (any(built)) {
    if (!all(built)) {
      .jst_stop("jtable() takes built tables or saved results in one call, ",
                "not both.\nBuild each result into a table first, then give ",
                "the tables together.")
    }
    if (!is.null(substitute(headings)) || !is.null(substitute(markers)) ||
        !is.null(title) || !is.null(note) || !is.null(style) ||
        length(over_q)) {
      .jst_stop("headings =, markers =, title =, note =, style =, and a ",
                "style's settings belong to the call that builds a table ",
                "from a result; a built table keeps its own.")
    }
    doc_st <- .jst_table_style(results[[1L]], st)
    write <- !is.null(out_path) &&
      .jst_table_overwrite_gate(out_path, overwrite, ask = interactive())
    if (.jst_print_on(print)) {
      for (i in seq_along(results)) {
        .jst_table_preview(results[[i]], .jst_table_style(results[[i]], st),
                           number = i)
      }
    }
    if (write) {
      .jst_docx_pack(.jst_docx_parts(results, doc_st), out_path)
      if (.jst_print_on(print)) {
        .jst_msg_out(paste0(if (length(results) == 1L) "Table" else "Tables",
                            " written to ", .jst_norm_path(out_path)))
        cat("\n")
      }
      .jst_table_open(out_path, open)
    }
    return(invisible(if (length(results) == 1L) results[[1L]] else results))
  }
  not_res <- !vapply(results, function(r) !is.na(.jst_table_result_fn(r)), logical(1))
  if (any(not_res)) {
    .jst_stop("jtable() takes a saved result -- what an analysis function ",
              "returns, kept with <- -- for example:\n",
              "  d1 <- jdesc(community, Age, Income)\n",
              "  jtable(d1)")
  }
  classes <- vapply(results, function(r) .jst_table_result_fn(r), character(1))
  if (length(unique(classes)) > 1L) {
    .jst_stop("jtable() does not yet put results of different kinds (",
              .jst_and_list(unique(classes)), ") in one table.\n",
              "Give it the results of one kind at a time.")
  }
  # The table's type, and the call's settings for it: the call's layer
  # goes first in the style, so it outranks the file (the reference, Part
  # 3.2).
  type <- if (inherits(results[[1L]], "jst_desc")) "descriptives"
          else if (inherits(results[[1L]], "jst_freq")) "frequencies"
          else NA_character_
  if (is.na(type)) .jst_table_build(results[[1L]], st)   # the stop for an unbuilt type
  if (length(over_vals)) {
    st <- .jst_style_object(st$name, st$path,
                            c(list(.jst_style_call_layer(over_vals, type, "jtable")),
                              st$layers),
                            st$skipped)
  }
  # The headings and markers, read as names: a bare name the results hold
  # is their variable whatever the workspace holds (ruling R18).
  vars <- unique(unlist(lapply(results, function(r) {
    tf <- .jst_apa_terms(r); if (is.null(tf)) character(0) else tf$variable
  })))
  hd <- .jst_table_name_groups(substitute(headings), env, "headings", vars)
  mk <- .jst_table_name_groups(substitute(markers), env, "markers", vars)

  # The results go to their type's builder as one list, so a named list's
  # names give the headings however many results it holds.
  tbl <- if (identical(type, "descriptives")) {
    .jst_table_build_desc(results, st, headings = hd, markers = mk,
                          title = title, note = note)
  } else {
    .jst_table_build_freq(results, st, headings = hd, markers = mk,
                          title = title, note = note)
  }

  # The overwrite question comes after every check that can stop the call
  # and before the preview, so the answer is given once, and the preview
  # and the "written" line print together after it.
  write <- !is.null(out_path) &&
    .jst_table_overwrite_gate(out_path, overwrite, ask = interactive())
  if (.jst_print_on(print)) .jst_table_preview(tbl, st, number = 1L)
  if (write) {
    .jst_docx_pack(.jst_docx_parts(list(tbl), st), out_path)
    if (.jst_print_on(print)) {
      .jst_msg_out(paste0("Table written to ", .jst_norm_path(out_path)))
      cat("\n")
    }
    .jst_table_open(out_path, open)
  }
  invisible(tbl)
}

#' @rdname jtable
#' @exportS3Method
print.jst_table <- function(x, ...) {
  .jst_table_preview(x, .jst_table_style(x, NULL), number = 1L)
  invisible(x)
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
#' @return A layer: list(source = "the call", <type> = list(...)).
#' @keywords internal
.jst_style_call_layer <- function(vals, type, fn) {
  sec <- .jst_style_spec[[type]]
  out <- list()
  for (k in names(vals)) {
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
  stats::setNames(list("the call", out), c("source", type))
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
#' jstats can find; \code{jstyle("myjournal")} prints every setting the
#' style gives, marking each one it takes from another style; and
#' \code{jstyle("apa", save.as = "myjournal")} saves a copy as a style
#' file, myjournal.jstyle, every setting written out with a note on what
#' it does, to edit in any text editor (the step SPSS calls "Save
#' TableLook As").
#'
#' A style file is plain text: a setting is a name, an equals sign and a
#' value; a \code{#} starts a note; the general settings come first, then
#' one section per table type, \code{[descriptives]} and
#' \code{[frequencies]}. A setting the file leaves out comes from the style
#' its \code{based.on} line names. jstats looks for a style named in a call
#' in the style folder (\code{joptions(style.dir = )}), the working
#' directory and your jstats folder, in that order.
#'
#' @param style The style's name in quotes, or a path to a style file;
#'   NULL (the default) lists the styles, or with \code{save.as} copies
#'   \code{joptions(style = )}.
#' @param save.as A name for the copy, in quotes: written as
#'   \code{<name>.jstyle} in the style folder when one is set, else in
#'   your jstats folder (\code{tools::R_user_dir("jstats")}), or to a path
#'   given with a folder.
#' @param overwrite Logical. Replace a style file that exists? With FALSE
#'   (the default) an interactive session asks, and one that cannot ask
#'   stops.
#' @param ... Not used. An input \code{jstyle()} does not take stops with
#'   "unused input".
#' @return Invisibly: the styles found (a data frame of name and path),
#'   the style, or the path of the file written.
#' @keywords internal
jstyle <- function(style = NULL, save.as = NULL, overwrite = FALSE, ...) {
  cl  <- sys.call()
  mc  <- match.call(expand.dots = TRUE)
  env <- parent.frame()
  .jst_check_args(rlang::enquos(...), aliases = character(0),
                  fn_name = "jstyle", positional = "refuse")
  .jst_word_args(cl, mc, env,
                 list(style = .jst_word_spec(c("apa", names(.jst_style_files())),
                                             "a style name")), "jstyle")
  .jst_free_text_arg(substitute(style), env, cl, mc, "style", "a style name", "jstyle")
  .jst_free_text_arg(substitute(save.as), env, cl, mc, "save.as", "a name", "jstyle")
  .jst_check_flag(overwrite, "overwrite")

  if (is.null(style) && is.null(save.as)) return(invisible(.jst_style_list_print()))
  st <- .jst_style_resolve(style, fn = "jstyle", cl = cl, mc = mc)
  if (is.null(save.as)) {
    .jst_style_print(st)
    return(invisible(st))
  }
  path <- .jst_style_save_path(save.as)
  write <- .jst_table_overwrite_gate(path, overwrite, ask = interactive(),
                                     fn = "jstyle", noun = "style")
  if (!write) return(invisible(NULL))
  lines <- .jst_style_file_lines(st, sub("\\.jstyle$", "", basename(path),
                                         ignore.case = TRUE))
  con <- file(path, open = "wb")
  writeBin(charToRaw(enc2utf8(paste0(paste(lines, collapse = "\n"), "\n"))), con)
  close(con)
  .jst_msg_out(paste0("Style written to ", .jst_norm_path(path)))
  cat("\n")
  invisible(path)
}

#' Internal helper: where jstyle(save.as =) writes
#'
#' A name with a folder is written where it says (the folder must exist); a
#' bare name goes in the style folder when one is set, else in the per-user
#' folder, which is created here, by the user's own call (CRAN's rule: a
#' package writes there only when asked). The .jstyle extension is added
#' when the name has none; "apa" is the built-in style's name.
#'
#' @param save.as The name given.
#' @return The path to write.
#' @keywords internal
.jst_style_save_path <- function(save.as) {
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
  if (tolower(base) %in% names(.jst_style_builtin())) {
    .jst_stop("\"", base, "\" is the name of jstats's built-in style.\n",
              "Give the copy another name, for example:\n",
              "  jstyle(\"apa\", save.as = \"myjournal\")", fn = "jstyle")
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
#' Every setting of every part, each after a line saying what it does, the
#' two stamps and based.on at the top: the file jstyle(save.as =) writes.
#'
#' @param st The style copied.
#' @param name The new file's style name.
#' @keywords internal
.jst_style_file_lines <- function(st, name) {
  heads <- c(general = "The general settings: the look of every table.",
             descriptives = "A descriptives table, from jdesc() results.",
             frequencies  = "A frequency table, from jfreq() results.")
  out <- c(paste0("# ", name, ".jstyle: a jstats table style."),
           "# Change a value after its = sign and save the file;",
           paste0("# jstyle(\"", name, "\") prints the settings jstats reads from it."),
           "# A line that starts with # is a note. A setting the file leaves out",
           "# comes from the style based.on names.")
  out <- c(out, "",
           paste0("format     = ", .jst_style_format),
           paste0("written.by = jstats ", .jst_jstats_version()),
           "based.on   = apa")
  for (part in c("general", names(.jst_style_type_nouns))) {
    out <- c(out, "", if (!identical(part, "general")) paste0("[", part, "]"),
             paste0("# ", heads[[part]]))
    spec <- .jst_style_spec[[part]]
    for (k in names(spec)) {
      out <- c(out, paste0("# ", spec[[k]]$about),  # one comment line per element
               paste0(k, " = ", .jst_style_value_out(.jst_style_key(st, part, k),
                                                     spec[[k]])))
    }
  }
  out
}
