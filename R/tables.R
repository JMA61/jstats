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
    line.spacing     = "single"       # single | double
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
  )
)

# The column heads a style may italicize: APA sets a statistic's symbol in
# italics (n, M, SD, p, r, t, F, b, SE, R2), and a word (Min, Max,
# Variable) upright. Keyed by the column key, read by the builders.
.jst_tbl_italic_heads <- c("n", "mean", "sd", "p", "r", "t", "f", "b", "se",
                           "beta", "df", "r2", "adj.r2", "or", "wald", "d",
                           "eta2", "alpha", "item.total", "alpha.if.deleted")

#' Internal helper: the style a jtable() call uses
#'
#' Build 1 knows one style, the built-in apa list; \code{style =} names it.
#' Build 2 adds the style files, \code{jstyle()} and the lookup through
#' \code{based.on}; this is where that lookup will go, so every caller
#' already reads the style through one helper.
#'
#' @param style Character(1); the style's name.
#' @param fn The user-facing function's name, for the stop.
#' @return The style: a list with a general part and one list per table
#'   type.
#' @keywords internal
.jst_style_resolve <- function(style, fn = "jtable") {
  if (!is.character(style) || length(style) != 1L || is.na(style)) {
    .jst_stop_arg(fn, "style", choices = "apa")
  }
  if (!identical(tolower(style), "apa")) {
    .jst_stop_arg(fn, "style", choices = "apa")
  }
  .jst_style_apa
}

#' Internal helper: one setting of a style, for one table type
#'
#' The lookup order of the reference (Part 3.2): the type's own section,
#' then the general part. A key neither holds is an internal error, since
#' the built-in list is complete.
#'
#' @param style The style list.
#' @param type Character(1); the table type (the section's name).
#' @param key Character(1); the key.
#' @keywords internal
.jst_style_key <- function(style, type, key) {
  sec <- style[[type]]
  if (!is.null(sec) && key %in% names(sec)) return(sec[[key]])
  gen <- style$general
  if (key %in% names(gen)) return(gen[[key]])
  stop(".jst_style_key(): no key '", key, "' for table type '", type, "'",
       call. = FALSE)
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
            ".\nIt makes a table from a jdesc() result.", fn = "jtable")
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

  # headings = partitions the variables: every variable under one heading,
  # in the headings' order.
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
      tf$heading[idx] <<- h
      idx
    }))
    tf <- tf[ord, , drop = FALSE]
  }

  # markers = : each specific note's variables; the marks in the style's
  # glyphs, in the order given.
  mark_of <- stats::setNames(vector("list", nrow(tf)), tf$variable)
  specific <- list()
  if (!is.null(markers)) {
    # A variable may carry several marks, one per note; a name repeated
    # within one note is the error.
    .jst_table_check_names(unique(unlist(markers, use.names = FALSE)), vars, "markers")
    for (g in markers) .jst_table_check_names(g, vars, "markers")
    for (i in seq_along(markers)) {
      g <- .jst_tbl_mark(i, key("marks"))
      specific[[i]] <- list(mark = g, text = names(markers)[i])
      for (v in markers[[i]]) mark_of[[v]] <- c(mark_of[[v]], g)
    }
  }

  # The columns: the stub, then the style's columns with their labels.
  col_keys <- key("columns")
  columns <- data.frame(
    key    = c("stub", col_keys),
    label  = c(key("stub.label"),
               vapply(col_keys, function(k) key(paste0(k, ".label")), character(1))),
    kind   = c("text", rep("number", length(col_keys))),
    italic = c(FALSE, col_keys %in% .jst_tbl_italic_heads),
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
    style    = "apa")
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
      runs <- .jst_docx_run(r$label, bold = identical(gh, "bold"),
                            italic = identical(gh, "italic"), size = size)
      borders <- .jst_docx_borders(rules, grid, bottom, grid || outer, grid || outer, rcol)
      rows_xml <- c(rows_xml, paste0(
        "<w:tr><w:trPr><w:cantSplit/></w:trPr>",
        .jst_docx_cell(.jst_docx_par(runs, keep_next = keep, line = line),
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
#' Measured from the cell's left text edge: the cell's inner width less the
#' widest tail (the point and the digits after it, and any stars), so the
#' numbers' points line up near the right edge.
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
    tail_w <- .jst_docx_text_width(tails, size, digits = TRUE)
    # Short of the cell's right edge: a stop at or past it is no stop to
    # LibreOffice, which then tabs to its default stops and wraps.
    out[j] <- as.integer(widths[j] - 2L * margin - tail_w - 40L)
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
  all_widths <- lapply(tables, .jst_docx_widths, style = style)
  natural <- vapply(all_widths, sum, integer(1))
  landscape <- identical(land_key, "yes") ||
    (identical(land_key, "auto") && any(natural > portrait$text))
  page <- .jst_docx_page(paper, landscape)
  for (i in seq_along(tables)) {
    tbl <- tables[[i]]
    widths <- all_widths[[i]]
    # A table wider than the page is shrunk to it, every column in
    # proportion.
    if (sum(widths) > page$text) {
      widths <- as.integer(floor(widths * page$text / sum(widths)))
    }
    key <- function(k) .jst_style_key(style, tbl$type, k)
    if (!identical(key("caption.position"), "row")) {
      body <- c(body, .jst_docx_caption_pars(tbl, style, i))
    }
    body <- c(body, .jst_docx_table(tbl, style, i, widths))
    if (!identical(key("note.position"), "row")) {
      body <- c(body, .jst_docx_note_pars(tbl, style))
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
  tmp <- tempfile(pattern = "jtable_", tmpdir = dirname(file), fileext = ".docx")
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
#' and Google Docs. The table's look and conventions come from a style
#' (the built-in \code{"apa"} style in this version); the preview is a
#' facsimile of the Word table, so what prints is what the file holds.
#'
#' This version makes one table type: a descriptives table from one or
#' more \code{\link{jdesc}} results, the variables under role headings
#' when \code{headings} names them, each specific note's variables marked
#' when \code{markers} names them. Further table types follow.
#'
#' @param x A saved result -- what an analysis function returns, kept with
#'   \code{<-} -- or a list of them. A list of \code{jdesc()} results
#'   stacks into one table, each result's variables under its name in the
#'   list when the list is named. A table \code{jtable()} has already
#'   built, or a list of them, goes to the file as it is, the tables in
#'   the order given and numbered so.
#' @param headings A named list: each heading and the variables under it,
#'   bare or in quotes, e.g. \code{list("Dependent variable" = Wellbeing,
#'   "Independent variables" = c(Income, Age))}. Every variable of the
#'   result goes under one heading; the table follows the list's order.
#' @param markers A named list: each specific note's text and the
#'   variables it marks, e.g. \code{list("Mean-centered" = c(Income,
#'   Age))}. The style assigns the marks (superscript letters under APA),
#'   sets each on its rows' labels, and writes the note under the table.
#' @param title The table's title; the style's template title when NULL.
#' @param note The general note's text, after the N the style writes;
#'   \code{*text*} sets a word in italics. NULL for none.
#' @param file The Word file to write, with its .docx extension: a bare
#'   name goes in the output folder (\code{joptions(output.dir = )}) or the
#'   working directory; a path with a folder goes there. NULL writes
#'   nothing.
#' @param style The style's name; \code{"apa"} in this version.
#' @param overwrite Logical. Replace a file that exists? With FALSE (the
#'   default) an interactive session asks, and one that cannot ask stops.
#' @param print Print the preview? NULL (the default) follows the
#'   \code{\link{joutput}} level: the preview prints unless the level is
#'   \code{"silent"}. TRUE prints it under any level; FALSE prints nothing
#'   and writes the file alone.
#' @param ... Not used. An input \code{jtable()} does not take stops with
#'   "unused input".
#'
#' @return The table, invisibly: an object of class \code{jst_table},
#'   which prints its preview when typed.
#'
#' @keywords internal
jtable <- function(x, headings = NULL, markers = NULL, title = NULL,
                   note = NULL, file = NULL, style = "apa",
                   overwrite = FALSE, print = NULL, ...) {
  # An input jtable() does not take -- a misspelled argument, or a value in
  # a place it has none -- stops here, read by name and never evaluated.
  .jst_check_args(rlang::enquos(...), aliases = c(notes = "note"),
                  fn_name = "jtable", positional = "refuse")
  # A bare word where a quoted value goes (ruling R18): the front door,
  # before anything is evaluated.
  .jst_word_args(sys.call(), match.call(expand.dots = TRUE), parent.frame(),
                 list(style = .jst_word_spec("apa", "a style name")), "jtable")
  .jst_free_text_arg(substitute(file), parent.frame(), sys.call(),
                     match.call(), "file", "a file name", "jtable")
  .jst_check_flag(overwrite, "overwrite")
  .jst_check_flag(print, "print", null.ok = TRUE)
  st <- .jst_style_resolve(style, fn = "jtable")

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
  # result is refused: a result is built first.
  built <- vapply(results, inherits, logical(1), "jst_table")
  if (any(built)) {
    if (!all(built)) {
      .jst_stop("jtable() takes built tables or saved results in one call, ",
                "not both.\nBuild each result into a table first, then give ",
                "the tables together.")
    }
    if (!is.null(substitute(headings)) || !is.null(substitute(markers)) ||
        !is.null(title) || !is.null(note)) {
      .jst_stop("headings =, markers =, title = and note = belong to the ",
                "call that builds a table from a result; a built table ",
                "keeps its own.")
    }
    write <- !is.null(out_path) &&
      .jst_table_overwrite_gate(out_path, overwrite, ask = interactive())
    if (.jst_print_on(print)) {
      for (i in seq_along(results)) .jst_table_preview(results[[i]], st, number = i)
    }
    if (write) {
      .jst_docx_pack(.jst_docx_parts(results, st), out_path)
      if (.jst_print_on(print)) {
        .jst_msg_out(paste0(if (length(results) == 1L) "Table" else "Tables",
                            " written to ", .jst_norm_path(out_path)))
        cat("\n")
      }
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
  # The headings and markers, read as names: a bare name the results hold
  # is their variable whatever the workspace holds (ruling R18).
  vars <- unique(unlist(lapply(results, function(r) {
    tf <- .jst_apa_terms(r); if (is.null(tf)) character(0) else tf$variable
  })))
  hd <- .jst_table_name_groups(substitute(headings), parent.frame(), "headings", vars)
  mk <- .jst_table_name_groups(substitute(markers), parent.frame(), "markers", vars)

  tbl <- if (length(results) == 1L) {
    .jst_table_build(results[[1L]], st, headings = hd, markers = mk,
                     title = title, note = note)
  } else {
    if (!inherits(results[[1L]], "jst_desc")) {
      .jst_table_build(results[[1L]], st)   # the stop for an unbuilt type
    }
    .jst_table_build_desc(results, st, headings = hd, markers = mk,
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
  }
  invisible(tbl)
}

#' @rdname jtable
#' @exportS3Method
print.jst_table <- function(x, ...) {
  .jst_table_preview(x, .jst_style_resolve(x$style), number = 1L)
  invisible(x)
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
  if (grepl("^([A-Za-z]:|[/\\\\~])", dir)) {
    paste0("Created the output folder:\n  ", dir)
  } else {
    paste0("Created '", dir, "' folder in working directory.")
  }
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
#' @return TRUE when the write may go ahead, FALSE when the question was
#'   answered no (a note says the file was kept); stops where the session
#'   cannot ask.
#' @keywords internal
.jst_table_overwrite_gate <- function(out_path, overwrite, ask = interactive()) {
  if (!.jst_lib_writable(dirname(out_path))) {
    .jst_stop("R cannot write to this folder:\n",
              "  ", .jst_norm_path(dirname(out_path)), "\n",
              "Nothing was written.\n",
              "Choose a folder you can write to and run jtable() again.",
              fn = "jtable")
  }
  if (!file.exists(out_path) || isTRUE(overwrite)) return(TRUE)
  if (!ask) {
    .jst_stop("this file already exists:\n",
              "  ", .jst_norm_path(out_path), "\n",
              .jst_txt_keep_file, .jst_txt_add_overwrite, fn = "jtable")
  }
  ok <- .jst_confirm(
    paste0("This file already exists:\n  ", .jst_norm_path(out_path),
           "\nOverwrite? (y/n): "),
    paste0(.jst_txt_keep_file, .jst_txt_add_overwrite))
  if (!ok) {
    .jst_msg("The file was kept, and no table was written.")
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
