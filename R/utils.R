#<<<FILE: utils.R>>>
#' jstats: Simplified Statistical Analysis Tools for Social Science
#'
#' @description
#' jstats simplifies R for users who need to do social science
#' analyses without being required to become experienced computer
#' programmers first. The package provides consistent syntax, sensible
#' defaults, and protection from confusing base R behaviors, while
#' staying close enough to base R conventions that users learn
#' transferable skills rather than a private dialect. Output is styled
#' after the best conventions from alternative applications such as
#' SPSS, Stata, and SAS, and code syntax is designed to ease the
#' transition from these alternative packages into R. While this
#' package was originally built as teaching infrastructure for a
#' university-level statistics course, it has now been expanded for
#' the broader social science research community.
#'
#' @section Audience:
#' The long-term primary audience is the broader social science
#' quantitative research community -- criminologists, sociologists,
#' political scientists, psychologists, public health researchers,
#' and others who routinely work with Likert scales, categorical
#' variables, dichotomies, Cronbach's alpha, dummy-coded regression,
#' and \code{haven}-imported data from SPSS, Stata, or SAS.
#'
#' During the current development phase the package is being tested
#' actively by students and colleagues at Griffith University, plus
#' a growing community of former students and collaborating
#' instructors. Feedback from this group shapes ongoing refinements.
#'
#' @section Functions by purpose:
#' \strong{Descriptive analysis}
#' \itemize{
#'   \item \code{\link{jdesc}} -- univariate descriptives (mean, median, SD, range, etc.) with optional grouping
#'   \item \code{\link{jfreq}} -- frequency tables for one or more variables
#'   \item \code{\link{jcorr}} -- Pearson or Spearman correlations with significance tests
#'   \item \code{\link{jalpha}} -- Cronbach's alpha and item-total statistics for scale reliability
#'   \item \code{\link{jscreen}} -- data screening for outliers, ranges, and skew
#' }
#'
#' \strong{Group comparisons and modeling}
#' \itemize{
#'   \item \code{\link{jt}} -- independent or paired t-test
#'   \item \code{\link{jaov}} -- one-way analysis of variance with optional post-hoc tests
#'   \item \code{\link{jcrosstab}} -- cross-tabulation with chi-square and effect-size options
#'   \item \code{\link{jlm}} -- linear regression
#'   \item \code{\link{jlogistic}} -- logistic regression
#' }
#'
#' \strong{Variable construction}
#' \itemize{
#'   \item \code{\link{jrecode}} -- recode values, with optional new value labels
#'   \item \code{\link{jrelabel}} -- apply or replace value labels and variable label
#'   \item \code{\link{jsum}} -- row-wise sum across variables, with min-valid handling
#'   \item \code{\link{javg}} -- row-wise mean across variables, with min-valid handling
#' }
#'
#' \strong{Pipeline state management}
#' \itemize{
#'   \item \code{\link{juse}} -- set the default data frame used implicitly by analysis functions
#'   \item \code{\link{jsubset}} -- activate a row-level case-selection expression applied to subsequent calls
#'   \item \code{\link{jcomplete}} -- activate listwise filtering on selected variables
#'   \item \code{\link{jdummy}} -- register categorical variables for dummy coding in regression
#'   \item \code{\link{joutput}} -- set session-level output verbosity (minimal / standard / full)
#' }
#'
#' \strong{Data import and export}
#' \itemize{
#'   \item \code{\link{jload}} -- load data from \code{.rds}, \code{.sav}, \code{.dta}, \code{.sas7bdat}, \code{.xlsx}, or \code{.csv}
#'   \item \code{\link{jsave}} -- save a data frame, with format inferred from the file extension
#' }
#'
#' \strong{Visualisation}
#' \itemize{
#'   \item \code{\link{jplot}} -- base histograms and bar plots for data, plus method dispatch on result objects from \code{jt()}, \code{jlm()}, etc.
#' }
#'
#' For the full alphabetical listing of every exported function, run
#' \code{library(help = "jstats")} or browse the package index.
#'
#' @section Workflow conventions:
#' \strong{The j-prefix.} Every user-facing function starts with
#' \code{j}, so the package's whole API can be discovered in RStudio
#' by typing \code{j} and pressing Tab. Internal helpers begin with a
#' dot or \code{.jst_} and are not intended for direct use.
#'
#' \strong{Formula vs data-first.} Group-comparison and modeling
#' functions follow the base R formula interface:
#' \code{jt(MathScore ~ Gender, data = SampleData)}. Descriptive and
#' data-management functions take the data frame first, followed by
#' unquoted variable names: \code{jfreq(SampleData, Gender, Program)}.
#' This matches the conventions of base R functions like
#' \code{aggregate()} and \code{cor()}.
#'
#' \strong{The juse-first habit.} A single \code{juse(MyData)} call
#' at the start of a session sets a default data frame. Subsequent
#' analysis calls can then omit the data argument:
#' \code{jfreq(Gender)} works the same as
#' \code{jfreq(MyData, Gender)}. The default also scopes the
#' pipeline-state functions, so \code{jsubset(Age < 30)} sets a
#' filter on the current default without further specification.
#'
#' \strong{Pipeline stages.} \code{jsubset()}, \code{jcomplete()}, and
#' \code{jdummy()} modify session state that subsequent analysis calls
#' read automatically. State is explicit -- calls can be inspected,
#' inactivated, and cleared, and active state is reported in analysis
#' output, so a script's behavior stays visible and reproducible
#' rather than depending on hidden context.
#'
#' \strong{Output verbosity.} \code{joutput()} sets one of three
#' preset levels -- \code{minimal}, \code{standard} (default), or
#' \code{full} -- that modulate how much detail analysis functions
#' print. Useful for stripping output in production scripts or
#' expanding it during exploration. Per-call arguments always
#' override session-level settings. The Case Processing Summary
#' table follows an auto-suppress rule at the standard tier: it
#' prints when something happened (pipeline state, listwise drops,
#' or a per-variable discrepancy notification) and stays silent
#' otherwise. See \code{?joutput} for the full toggle behavior.
#'
#' @section Where to go next:
#' \itemize{
#'   \item For a quick orientation to the package's conventions (also
#'     useful when working with an AI assistant): \code{jai()}.
#'   \item For the full alphabetical listing of functions:
#'     \code{library(help = "jstats")}.
#'   \item For source, issue reports, and contribution guidelines:
#'     the package's GitHub repository.
#'   \item For statistics and R fundamentals (in preparation): Book 1
#'     of the companion book series.
#'   \item For migration patterns from SPSS, Stata, or SAS, and a
#'     deeper guide to the package's design and use in real research
#'     (in preparation): Book 2, the adopter's guide.
#' }
#'
#' @keywords internal
"_PACKAGE"


#' Update jstats to the latest version
#'
#' \code{jupdate()} installs the most recent version of jstats. While jstats is
#' in its pre-release phase this downloads and installs the latest pre-built
#' version; once jstats reaches CRAN, the same command will update it the
#' ordinary way. Either way, you run one command instead of having to remember
#' an install line. It is safe to call from the console, a script, or a Quarto
#' document.
#'
#' The function checks for an internet connection first; if jstats is already
#' up to date it says so and stops. The install runs in a separate R process so
#' the copy of jstats loaded in your session does not lock its own files during
#' the install (the usual cause of a failed update on Windows). After a
#' successful update you restart R once to load the new version.
#'
#' @param ask Logical. When \code{TRUE} and the session is interactive,
#'   jupdate() shows the available and installed versions and asks for
#'   confirmation before installing. Defaults to \code{FALSE} (update without
#'   prompting), which is also what happens in any non-interactive session, such
#'   as a Quarto render.
#'
#' @return Invisibly \code{NULL}. Called for its side effect of installing the
#'   update, and for the messages it prints.
#'
#' @examples
#' \dontrun{
#' jupdate()            # update without prompting
#' jupdate(ask = TRUE)  # confirm before updating
#' }
#'
#' @export
#' @importFrom utils available.packages install.packages
jupdate <- function(ask = FALSE) {
  # Validate TRUE/FALSE flags up front.
  .jst_check_flag(ask, "ask")
  # One network read doubles as a connectivity probe and a migration check.
  gist <- .jst_read_gist()
  if (!isTRUE(gist$network_ok)) {
    .jst_stop(
      "no internet connection was detected. Updating jstats needs an ",
      "internet connection. Connect and run jupdate() again."
    )
  }

  # If the package has been renamed, point the user at the successor rather
  # than reinstalling a retired package. A successor whose name matches this
  # package is not a rename -- it is the gist's normal "no migration" state, so
  # it is ignored here, matching the guard in .onAttach().
  if (!is.null(gist$successor) &&
      !identical(gist$successor$package, "jstats")) {
    hint <- gist$successor$install_hint
    msg  <- paste0(
      "jstats has been renamed to '", gist$successor$package, "'. ",
      "Install that package instead of updating jstats."
    )
    if (!is.null(hint) && nzchar(hint)) {
      msg <- paste0(msg, "\nTo switch, run:\n  ", hint)
    }
    message(msg)
    return(invisible(NULL))
  }

  installed_ver <- as.character(utils::packageVersion("jstats"))
  latest_ver    <- .jst_latest_universe_version()

  if (!is.na(latest_ver) &&
      package_version(latest_ver) <= package_version(installed_ver)) {
    message("jstats v", installed_ver, " is already up to date.")
    return(invisible(NULL))
  }

  # Optional confirmation. Only prompts when the caller asked for it AND the
  # session can read a response; otherwise it just proceeds, which keeps
  # jupdate() safe in scripts and Quarto renders.
  if (isTRUE(ask) && interactive()) {
    prompt <- if (is.na(latest_ver)) {
      paste0(
        "Could not confirm the latest version, but a connection is available. ",
        "Install the latest jstats anyway?"
      )
    } else {
      paste0(
        "jstats v", latest_ver, " is available - you have v", installed_ver,
        ". Update now?"
      )
    }
    if (utils::menu(c("Yes", "No"), title = prompt) != 1L) {
      message("Update canceled.")
      return(invisible(NULL))
    }
  }

  message("Updating jstats ... (this may take a moment)")

  # Install in a clean, separate R process (via callr, an Imports dependency, so
  # always available). Because that process never loads jstats, the package
  # files are not locked, and the install completes even on Windows. A genuine
  # install failure makes the child error, which is surfaced honestly.
  err <- tryCatch({
    callr::r(
      function() {
        install.packages(
          "jstats",
          repos = c("https://jma61.r-universe.dev", "https://cloud.r-project.org")
        )
      }
    )
    NULL
  }, error = function(e) conditionMessage(e))

  if (!is.null(err)) {
    .jst_stop("the update did not complete. The error was: ", err)
  }

  message(
    "jstats has been updated.\n",
    "\n",
    "Restart R to load it in RStudio:\n",
    "  - open the Session menu > choose Restart R\n",
    "  - or press Ctrl+Shift+F10\n",
    "\n",
    "The Console will return to a blank prompt.\n",
    "Reload jstats with library(jstats) (unless loaded automatically on startup)."
  )

  invisible(NULL)
}


#' Print the jstats orientation, or install it for an AI assistant
#'
#' \code{jai()} prints a short, plain-text orientation to the package's core
#' conventions: how to load data, how jstats handles value labels and
#' user-defined missing values, how to choose an analysis function, and how
#' to keep changes made to a data frame. It is written to be useful both to
#' people new to the package and to AI coding assistants (such as the
#' assistant built into RStudio), which read console output and can act on
#' what they find there.
#'
#' Beyond the plain printout, \code{jai()} can install the same orientation
#' where an AI assistant finds it on its own. \code{setup} selects the
#' situation (values are case-insensitive):
#' \describe{
#'   \item{\code{"project"}}{Writes the orientation into \code{AGENTS.md} in
#'     the current folder (or \code{path}), inside a clearly marked block.
#'     Assistants that read \code{AGENTS.md} then see the conventions in
#'     every conversation in that project. Existing content is never
#'     overwritten: the block is appended to an existing file, and on
#'     regeneration only the marked block is replaced. Keep your own
#'     additions outside the markers; they survive regeneration, while edits
#'     inside the block are overwritten (with a warning when edits are
#'     detected).}
#'   \item{\code{"machine"}}{Writes \code{SKILL.md} to the user-level
#'     skills folder (or \code{path}), so assistants that support skills can
#'     load the conventions in any project on the machine, when relevant.}
#'   \item{\code{"chat"}}{For chat assistants outside RStudio. Currently
#'     prints a short note; a paste-ready primer is planned.}
#'   \item{\code{"status"}}{Reports which orientation files are present,
#'     their versions, and whether they are current. Nothing is written.}
#' }
#'
#' The file-writing situations confirm the exact destination before writing
#' (or write without asking when \code{path} names the folder yourself).
#' Each written file carries a version stamp; after updating jstats, rerun
#' the same \code{jai()} call to refresh it.
#'
#' @param setup Optional. \code{"project"}, \code{"machine"}, \code{"chat"},
#'   or \code{"status"}; see Details. When missing, the orientation is
#'   printed to the console.
#' @param path Optional. An existing folder to write into, overriding the
#'   default destination; used only by \code{"project"} and
#'   \code{"machine"}.
#'
#' @return Invisibly \code{NULL}. Called for its side effects.
#'
#' @examples
#' jai()
#' \dontrun{
#' jai("project")   # write AGENTS.md in the current project
#' jai("machine")   # write SKILL.md to the skills folder
#' jai("status")    # report what is installed where
#' }
#'
#' @seealso \code{help("jstats")} for the package overview and full
#'   function list.
#' @export
jai <- function(setup = NULL, path = NULL) {
  if (!is.null(path)) {
    if (!is.character(path) || length(path) != 1L || is.na(path)) {
      .jst_stop("`path` must be a single folder name in quotes.")
    }
  }
  if (is.null(setup)) {
    if (!is.null(path)) {
      message("Note: `path` is used only when writing a file and was ignored.")
    }
    .jst_jai_print()
    return(invisible(NULL))
  }
  # Situation specs are case-insensitive (accept "Project", "STATUS", ...);
  # canonicalize before validating, per the platform-spec argument rule.
  if (is.character(setup) && length(setup) == 1L && !is.na(setup)) {
    setup <- tolower(trimws(setup))
  }
  if (!is.character(setup) || length(setup) != 1L ||
      !setup %in% c("project", "machine", "chat", "status")) {
    .jst_stop_arg(arg = "setup",
                  choices = c("project", "machine", "chat", "status"))
  }
  if (setup %in% c("chat", "status") && !is.null(path)) {
    message("Note: `path` is used only when writing a file and was ignored.")
  }
  switch(setup,
    project = .jst_jai_project(path),
    machine = .jst_jai_machine(path),
    chat    = .jst_jai_chat(),
    status  = .jst_jai_status())
  invisible(NULL)
}


# =============================================================================
#  INTERNAL HELPERS
# =============================================================================

# -- jai() orientation and provisioning helpers -------------------------------

#' Internal constant: the orientation text version
#'
#' Bumped whenever the orientation content changes. Stamped into every
#' emission (console print, AGENTS.md block, SKILL.md) so a saved copy can
#' be recognized as stale after a package update.
#' @keywords internal
.jst_orientation_version <- "3.1"

#' Internal helper: the installed jstats version as a string
#'
#' Falls back to "unknown" when the package is not installed (e.g. when the
#' source is loaded directly during development).
#' @keywords internal
.jst_jstats_version <- function() {
  tryCatch(as.character(utils::packageVersion("jstats")),
           error = function(e) "unknown")
}

#' Internal helper: the orientation body text
#'
#' The single content core shared by every jai() emission: the console
#' print, the AGENTS.md block, and SKILL.md. One character element per
#' line, in Markdown (backtick code spans; the file emissions use it as
#' is, the console emissions pass it through
#' .jst_orientation_render_console()). Content matches the deployed
#' orientation text (see .jst_orientation_version); edit it here and
#' bump the version, never per emission.
#' @keywords internal
.jst_orientation_body <- function() {
  c(
    "jstats is an integrated set of j-prefixed analysis functions (`jdesc`,",
    "`jfreq`, `jlm`, ...) with shared syntax and output styled after commercial",
    "statistical software. The functions work directly with data imported from",
    "SPSS, Stata, or SAS, and with R .rds files whose columns carry haven-style",
    "metadata: value labels and user-defined missing values (UDM) are handled",
    "automatically.",
    "",
    "Note for AI assistants: jstats is newer than your training data. Do not",
    "rely on remembered or inferred jstats syntax. When unsure of a function's",
    "arguments, check them with `args()` (for example `args(jdeclare_udm)`) or",
    "the function's help page instead of guessing.",
    "",
    "- Start each session with `library(jstats)`. If the package is not",
    "  installed (`there is no package called 'jstats'`), do not guess an",
    "  install command -- jstats is not on CRAN yet, so `install.packages()`",
    "  alone will fail. Point the user to the install guide instead:",
    "  https://jma61.github.io/jstats-guides/install-jstats.html",
    "- Load data with `jload()`. It reads many file types (.rds, .sav, .dta,",
    "  .xlsx, .csv, ...) without separate packages such as haven or readxl, and",
    "  checks for undeclared missing-value codes that other loaders skip. The",
    "  shipped example datasets load the same way, by bare name:",
    "  `jload(\"clinic\")`, `jload(\"community\")` -- prefer this over `data()`,",
    "  which skips those checks. `jload()` places the dataset in the global",
    "  environment under its own name, so no assignment is needed, though",
    "  `clinic <- jload(\"clinic\")` also works.",
    "- Work with one dataset at a time, as in SPSS or Stata. Set it once with",
    "  `juse(community)`; later calls then omit the data argument --",
    "  `jdesc(Age, Income)`, `jt(CommuteTime ~ OwnsHome)`. Every result states",
    "  which data frame it used. When more than one data frame is in play, pass",
    "  the frame explicitly or switch the default with `juse()`. Prefer",
    "  `jsubset()` and `jcomplete()`, which filter cases without altering the",
    "  data, over creating modified copies of the data frame.",
    "- Explore first with `jscreen()` (variable types, missing data, and",
    "  outliers at a glance -- the first look at an unfamiliar dataset),",
    "  `jfreq()` (frequencies), and `jdesc()` (descriptives). Prefer jstats",
    "  functions over base R or tidyverse equivalents where they exist: their",
    "  output accounts for declared missing values, and one consistent toolset",
    "  keeps the analysis easy to follow.",
    "- Declare stray codes such as -99 with",
    "  `jdeclare_udm(data, var, codes = c(-99, -98))` -- the argument is",
    "  `codes`. Do not filter such values out by hand. jstats functions honor",
    "  declared UDM codes; base functions such as `mean()` ignore them and",
    "  return wrong answers with no warning.",
    "- Choose the analysis function before writing any analysis code: compare",
    "  group means with `jt()` (two groups) or `jaov()` (three or more); test",
    "  relationships with `jcorr()` (correlations), `jlm()` (regression,",
    "  numeric outcome), or `jlogistic()` (regression, yes/no outcome);",
    "  cross-tabulate with `jcrosstab()`; check scale reliability with",
    "  `jalpha()`. The group-comparison and regression functions take a formula",
    "  (`jt(CommuteTime ~ OwnsHome)`, `jlm(Income ~ Age + Education)`);",
    "  `jcorr()`, `jalpha()`, `jdesc()`, and `jfreq()` take variable names",
    "  instead. For anything not listed, check `help(\"jstats\")` for the full",
    "  function list before reaching for another package.",
    "- Analysis functions print their results directly; nothing needs to be",
    "  stored. The few functions that change data, such as `jdeclare_udm()` and",
    "  `jconvert()`, return the changed data frame: keep it by assigning back",
    "  (`df <- jdeclare_udm(df, ...)`) or with `modify = TRUE`. `jconvert()`",
    "  translates missing-value codes between software conventions -- it is for",
    "  moving data to other software or to plain base-R form, and is never a",
    "  prerequisite for analysis in jstats, which reads labelled data directly.",
    "  Save data across sessions with `jsave()`.",
    "- Detailed help and worked examples for each function are available via",
    "  `?jdesc`, `?jdeclare_udm`, and so on.",
    "",
    "Guides and reference: https://jma61.github.io/jstats-guides"
  )
}

#' Internal helper: build the version-stamp line(s)
#'
#' One line naming the orientation-text version, the jstats version it was
#' generated against, and the date. When regenerate names a jai() setup
#' value ("project" or "machine"), a second line carries the regenerate
#' instruction; the live console print passes NULL (a fresh print cannot
#' go stale, so it carries no regenerate line).
#' @keywords internal
.jst_orientation_stamp <- function(regenerate = NULL) {
  line <- paste0("Orientation text v", .jst_orientation_version,
                 " | jstats ", .jst_jstats_version(),
                 " | generated ", format(Sys.Date()))
  if (is.null(regenerate)) return(line)
  c(line, paste0("Regenerate after updating jstats: jai(\"",
                 regenerate, "\")"))
}

#' Internal helper: assemble the full orientation text
#'
#' Heading, intro line, stamp line(s), blank, body. flavor = "machine"
#' drops the "Note for AI assistants:" framing prefix from the one body
#' line that carries it (a skill body is already assistant-facing;
#' settled S203).
#' @keywords internal
.jst_orientation_text <- function(stamp, flavor = c("standard", "machine")) {
  flavor <- match.arg(flavor)
  body <- .jst_orientation_body()
  if (flavor == "machine") {
    body <- sub("^Note for AI assistants: jstats", "jstats", body)
  }
  c("# jstats conventions",
    "",
    "Orientation for users and AI assistants.",
    stamp,
    "",
    body)
}

#' Internal helper: render orientation Markdown for the console
#'
#' The body is authored in Markdown for the file emissions; a console
#' print wants plain text. Strips backtick code spans and the leading
#' heading marker; bullets read fine at a prompt and are kept.
#' @keywords internal
.jst_orientation_render_console <- function(lines) {
  lines <- gsub("`", "", lines, fixed = TRUE)
  sub("^# ", "", lines)
}

#' Internal helper: md5 checksum of a character vector
#'
#' Writes the lines to a temporary file with newline separators through a
#' binary connection (platform-stable: no CRLF translation on Windows)
#' and returns tools::md5sum() of it. Used for the AGENTS.md
#' edit-detection fingerprint.
#' @keywords internal
.jst_md5_of_lines <- function(lines) {
  tmp <- tempfile()
  on.exit(unlink(tmp), add = TRUE)
  con <- file(tmp, open = "wb")
  writeLines(lines, con, sep = "\n")
  close(con)
  unname(tools::md5sum(tmp))
}

#' Internal helper: the AGENTS.md block markers
#'
#' HTML comments: invisible in rendered Markdown, inert to an assistant
#' reading the file. The start marker carries the do-not-edit-inside
#' warning where an editing user will see it; the end marker carries the
#' checksum of the lines strictly between the two markers, as generated.
#' Detection matches on the stable prefixes only, so the warning wording
#' can change without stranding deployed blocks.
#' @keywords internal
.jst_agents_marker_start <- function() {
  paste0("<!-- jstats orientation: start - written by jai(\"project\"); ",
         "edits inside this block are overwritten at regeneration -->")
}

#' Internal helper: the AGENTS.md end marker
#'
#' Counterpart of .jst_agents_marker_start(); carries the checksum of the
#' lines strictly between the two markers, as generated, for edit
#' detection.
#' @keywords internal
.jst_agents_marker_end <- function(checksum) {
  paste0("<!-- jstats orientation: end [checksum: ", checksum, "] -->")
}

#' Internal helper: build the complete marked AGENTS.md block
#' @keywords internal
.jst_agents_block <- function() {
  content <- .jst_orientation_text(.jst_orientation_stamp("project"))
  between <- c("", content, "")
  c(.jst_agents_marker_start(),
    between,
    .jst_agents_marker_end(.jst_md5_of_lines(between)))
}

#' Internal helper: locate the jstats block markers in a file
#'
#' Returns the line indices of every start and end marker found (empty
#' integer vectors when absent). The caller decides intact vs damaged:
#' exactly one of each, start before end, is intact.
#' @keywords internal
.jst_agents_block_bounds <- function(lines) {
  list(start = grep("^<!-- jstats orientation: start", lines),
       end   = grep("^<!-- jstats orientation: end", lines))
}

#' Internal helper: parse the orientation version out of block lines
#' @keywords internal
.jst_orientation_version_in <- function(lines) {
  m <- regmatches(lines, regexpr("Orientation text v[0-9][0-9.]*", lines))
  m <- unlist(m)
  if (!length(m)) return(NULL)
  sub("^Orientation text v", "", m[[1L]])
}

#' Internal helper: parse the stored checksum out of an end-marker line
#' @keywords internal
.jst_agents_stored_checksum <- function(end_line) {
  m <- regmatches(end_line, regexpr("\\[checksum: [0-9a-f]+\\]", end_line))
  m <- unlist(m)
  if (!length(m)) return(NULL)
  sub("^\\[checksum: ([0-9a-f]+)\\]$", "\\1", m[[1L]])
}

#' Internal helper: yes/no console confirmation
#' @keywords internal
.jst_jai_confirm <- function(prompt) {
  tolower(trimws(readline(prompt))) %in% c("y", "yes")
}

#' Internal helper: the declined-write note
#' @keywords internal
.jst_jai_declined <- function() {
  message("Nothing was written.\n",
          "To write to a different folder, rerun with path = \"<folder>\".")
}

#' Internal helper: jai("project") -- write the AGENTS.md block
#'
#' Four cases: create a new file; append to an existing file with no
#' jstats markers; replace between intact markers (with checksum-based
#' edit detection); refuse and print the fresh block when the markers are
#' damaged. Interactive runs confirm before writing; an explicit path
#' skips the destination confirmation but still confirms (or, when the
#' session cannot ask, warns after the fact) before discarding detected
#' hand edits.
#' @keywords internal
.jst_jai_project <- function(path = NULL) {
  explicit <- !is.null(path)
  dir <- if (explicit) path else getwd()
  if (!dir.exists(dir)) {
    .jst_stop("`path` must name an existing folder.\n",
              "Nothing was written.")
  }
  dir_abs <- normalizePath(dir, winslash = "/")
  target  <- file.path(dir_abs, "AGENTS.md")
  block   <- .jst_agents_block()
  caution <- if (!length(list.files(dir_abs, pattern = "\\.Rproj$"))) {
    paste0("No .Rproj file is visible here, so this may not be an ",
           "RStudio project folder.\n")
  } else ""

  if (!interactive() && !explicit) {
    .jst_stop("writing needs confirmation, and this session cannot ask.\n",
              "Set path = to name the destination folder and rerun.")
  }

  keep_note <- paste0("Keep your own additions outside the marked block; ",
                      "they survive regeneration.")

  if (!file.exists(target)) {
    if (!explicit) {
      ok <- .jst_jai_confirm(paste0(
        "About to create the jstats orientation block in a new file:\n  ",
        target, "\n", caution, "Proceed? (y/n): "))
      if (!ok) {
        .jst_jai_declined()
        return(invisible(NULL))
      }
    }
    writeLines(block, target)
    message("Created the jstats orientation block in:\n  ", target, "\n",
            keep_note)
    return(invisible(NULL))
  }

  lines <- readLines(target, warn = FALSE)
  b  <- .jst_agents_block_bounds(lines)
  ns <- length(b$start)
  ne <- length(b$end)

  if (ns == 0L && ne == 0L) {
    if (!explicit) {
      ok <- .jst_jai_confirm(paste0(
        "About to append the jstats orientation block to:\n  ", target,
        "\nYour existing content is untouched.\n", caution,
        "Proceed? (y/n): "))
      if (!ok) {
        .jst_jai_declined()
        return(invisible(NULL))
      }
    }
    writeLines(c(lines, "", block), target)
    message("Appended the jstats orientation block to:\n  ", target, "\n",
            "Your existing content was not changed.\n",
            "Review any other instructions in this file alongside the ",
            "jstats block.\n", keep_note)
    return(invisible(NULL))
  }

  if (ns == 1L && ne == 1L && b$start < b$end) {
    between <- if (b$end - b$start > 1L) {
      lines[(b$start + 1L):(b$end - 1L)]
    } else {
      character(0)
    }
    stored <- .jst_agents_stored_checksum(lines[b$end])
    edited <- !is.null(stored) &&
      !identical(.jst_md5_of_lines(between), stored)
    oldv <- .jst_orientation_version_in(between)
    vers <- if (!is.null(oldv)) {
      paste0(" (v", oldv, " -> v", .jst_orientation_version, ")")
    } else ""

    if (interactive() && (!explicit || edited)) {
      prompt <- if (edited) {
        paste0("The jstats orientation block in this file has been edited ",
               "since it was generated.\n",
               "Replacing it will discard those edits:\n  ", target,
               "\nProceed? (y/n): ")
      } else {
        paste0("About to replace the jstats orientation block", vers,
               " in:\n  ", target, "\nProceed? (y/n): ")
      }
      if (!.jst_jai_confirm(prompt)) {
        .jst_jai_declined()
        return(invisible(NULL))
      }
    }
    out <- c(if (b$start > 1L) lines[1L:(b$start - 1L)],
             block,
             if (b$end < length(lines)) lines[(b$end + 1L):length(lines)])
    writeLines(out, target)
    if (edited && !interactive()) {
      warning("The previous jstats orientation block had been edited; ",
              "those edits were discarded.", call. = FALSE)
    }
    message("Replaced the jstats orientation block", vers, " in:\n  ",
            target)
    return(invisible(NULL))
  }

  which_msg <- if (ns >= 1L && ne == 0L) {
    "a start marker with no end marker"
  } else if (ns == 0L && ne >= 1L) {
    "an end marker with no start marker"
  } else if (ns == 1L && ne == 1L) {
    "the end marker before the start marker"
  } else {
    "more than one set of markers"
  }
  message("Found ", which_msg, " in:\n  ", target, "\n",
          "Repair the file by hand, or delete the damaged markers and ",
          "rerun.\n",
          "A fresh orientation block is printed below for reference.")
  cat(block, sep = "\n")
  cat("\n")
  .jst_stop("nothing was written.")
}

#' Internal helper: the default machine-skill folder
#'
#' The cross-tool user-level skills location. On Windows the profile root
#' is taken from USERPROFILE, not path.expand("~"): R historically
#' expands "~" to Documents, while skill-reading assistants treat "~" as
#' the profile root, and USERPROFILE is also stable under OneDrive
#' Documents redirection.
#' @keywords internal
.jst_skill_default_dir <- function() {
  if (.Platform$OS.type == "windows") {
    up <- Sys.getenv("USERPROFILE")
    if (nzchar(up)) {
      return(file.path(gsub("\\\\", "/", up), ".agents", "skills",
                       "jstats"))
    }
  }
  path.expand("~/.agents/skills/jstats")
}

#' Internal helper: the user-level skill folders worth checking
#'
#' The default write location first, then the Posit-specific user-level
#' location, so jai("status") reports a skill file wherever it actually
#' sits.
#' @keywords internal
.jst_skill_candidate_dirs <- function() {
  root <- dirname(dirname(dirname(.jst_skill_default_dir())))
  unique(c(.jst_skill_default_dir(),
           file.path(root, ".posit", "assistant", "skills", "jstats")))
}

#' Internal helper: the SKILL.md frontmatter description
#'
#' The when-to-use relevance trigger read by skill-supporting assistants.
#' Wording as validated S203 (the trigger fired spontaneously on the
#' jstats-named case); the trigger-edge probe may tighten it later.
#' @keywords internal
.jst_skill_description <- function() {
  paste0("Use whenever the user is working with the jstats R package or ",
         "its example datasets (community, clinic) -- loading data, ",
         "exploring it, declaring missing values, comparing groups, ",
         "running regressions or correlations, or any statistical ",
         "analysis where jstats functions (jload, jdesc, jfreq, jscreen, ",
         "jt, jaov, jcorr, jlm, jlogistic, jcrosstab, jalpha, ",
         "jdeclare_udm, juse, jsave, jconvert) are or should be in use. ",
         "jstats is newer than model training data, so its syntax must ",
         "not be guessed.")
}

#' Internal helper: jai("machine") -- write SKILL.md
#'
#' Writes the skill file (frontmatter plus the orientation, machine
#' flavor) to the default user-level skills folder, creating missing
#' folders, or to an explicit path for hand placement. The file is
#' package-owned by convention, so an existing copy is overwritten whole
#' after confirmation; no marker machinery.
#' @keywords internal
.jst_jai_machine <- function(path = NULL) {
  explicit <- !is.null(path)
  dir <- if (explicit) {
    if (!dir.exists(path)) {
      .jst_stop("`path` must name an existing folder.\n",
                "Nothing was written.")
    }
    normalizePath(path, winslash = "/")
  } else {
    .jst_skill_default_dir()
  }
  target <- file.path(dir, "SKILL.md")
  had    <- file.exists(target)

  if (!interactive() && !explicit) {
    .jst_stop("writing needs confirmation, and this session cannot ask.\n",
              "Set path = to name the destination folder and rerun.")
  }
  if (!explicit) {
    prompt <- if (had) {
      paste0("About to overwrite the jstats skill file:\n  ", target,
             "\nProceed? (y/n): ")
    } else {
      paste0("About to create the jstats skill file:\n  ", target,
             "\n(any missing folders on the way are created)\n",
             "Proceed? (y/n): ")
    }
    if (!.jst_jai_confirm(prompt)) {
      .jst_jai_declined()
      return(invisible(NULL))
    }
  }

  content <- .jst_orientation_text(.jst_orientation_stamp("machine"),
                                   flavor = "machine")
  skill <- c("---",
             "name: jstats",
             paste0("description: ", .jst_skill_description()),
             "---",
             "",
             content)
  if (!dir.exists(dir)) dir.create(dir, recursive = TRUE)
  writeLines(skill, target)
  message(if (had) "Replaced" else "Created",
          " the jstats skill file:\n  ", target, "\n",
          "Assistants that support skills find it automatically; the ",
          "first use may ask for permission.")
  if (explicit) {
    message("To be found automatically, the file must sit in a folder ",
            "named jstats inside your assistant's skills folder, e.g.:\n  ",
            .jst_skill_default_dir())
  }
  invisible(NULL)
}

#' Internal helper: jai("chat") -- the paste-primer placeholder
#'
#' The primer for standalone chat assistants is designed but not yet
#' drafted; until it lands, this routes the user to the working stopgap.
#' @keywords internal
.jst_jai_chat <- function() {
  cat("\n",
      "The paste primer for chat assistants is still in development.\n",
      "For now, run jai() and paste the printed orientation into your ",
      "chat as your first message.\n\n", sep = "")
  invisible(NULL)
}

#' Internal helper: one status line for a found orientation copy
#' @keywords internal
.jst_orientation_state_line <- function(found_v, edited, regen_call) {
  ed <- if (edited) ", hand-edited" else ""
  inst_v <- .jst_orientation_version
  if (is.null(found_v)) {
    return(paste0("Block present (version unknown", ed, ")."))
  }
  cmp <- tryCatch({
    a <- numeric_version(found_v)
    b <- numeric_version(inst_v)
    if (a < b) -1L else if (a > b) 1L else 0L
  }, error = function(e) NA_integer_)
  if (identical(cmp, 0L)) {
    paste0("Block v", found_v, ed, " -- current.")
  } else if (identical(cmp, -1L)) {
    paste0("Block v", found_v, ed, " -- older than installed v", inst_v,
           ". Regenerate with ", regen_call, ".")
  } else {
    paste0("Block v", found_v, ed, ".")
  }
}

#' Internal helper: jai("status") -- report deployed orientation copies
#'
#' Read-only. Reports the installed orientation version, then each
#' destination: AGENTS.md in the current folder (block presence, version,
#' hand-edit flag, staleness) and SKILL.md in the user-level skill
#' folders. Prints ready-to-run file.edit() lines so review is one
#' copy-paste away.
#' @keywords internal
.jst_jai_status <- function() {
  out <- c("jstats orientation status",
           "",
           paste0("Installed (jstats ", .jst_jstats_version(),
                  "): orientation text v", .jst_orientation_version),
           "")

  target <- file.path(normalizePath(getwd(), winslash = "/"), "AGENTS.md")
  out <- c(out, "Project block (AGENTS.md in the current folder):",
           paste0("  ", target))
  if (!file.exists(target)) {
    out <- c(out, "  Not present. Create it with jai(\"project\").")
  } else {
    lines <- tryCatch(readLines(target, warn = FALSE),
                      error = function(e) NULL)
    if (is.null(lines)) {
      out <- c(out, "  Present but could not be read.")
    } else {
      b <- .jst_agents_block_bounds(lines)
      if (length(b$start) == 1L && length(b$end) == 1L &&
          b$start < b$end) {
        between <- if (b$end - b$start > 1L) {
          lines[(b$start + 1L):(b$end - 1L)]
        } else {
          character(0)
        }
        stored <- .jst_agents_stored_checksum(lines[b$end])
        edited <- !is.null(stored) &&
          !identical(.jst_md5_of_lines(between), stored)
        out <- c(out, paste0("  ", .jst_orientation_state_line(
          .jst_orientation_version_in(between), edited,
          "jai(\"project\")")))
      } else if (!length(b$start) && !length(b$end)) {
        out <- c(out,
                 paste0("  File present, no jstats block. Add one with ",
                        "jai(\"project\")."))
      } else {
        out <- c(out,
                 paste0("  File present, but the jstats block markers are ",
                        "damaged. Run jai(\"project\") for repair ",
                        "guidance."))
      }
    }
  }
  out <- c(out, paste0("  To open it: file.edit(\"", target, "\")"), "")

  out <- c(out, "Machine skill (SKILL.md):")
  found_any <- FALSE
  for (d in .jst_skill_candidate_dirs()) {
    f <- file.path(d, "SKILL.md")
    if (file.exists(f)) {
      found_any <- TRUE
      lines <- tryCatch(readLines(f, warn = FALSE),
                        error = function(e) character(0))
      out <- c(out, paste0("  ", f),
               paste0("  ", .jst_orientation_state_line(
                 .jst_orientation_version_in(lines), FALSE,
                 "jai(\"machine\")")),
               paste0("  To open it: file.edit(\"", f, "\")"))
    }
  }
  if (!found_any) {
    out <- c(out,
             paste0("  Not present (looked in the usual skill folders). ",
                    "Create it with jai(\"machine\"):"),
             paste0("  ", file.path(.jst_skill_default_dir(), "SKILL.md")))
  }
  cat("\n")
  cat(out, sep = "\n")
  cat("\n")
  invisible(NULL)
}

#' Internal helper: print the orientation to the console
#'
#' The zero-argument jai() output: the full orientation, console-rendered,
#' with the informational stamp line (no regenerate line -- a live print
#' cannot go stale).
#' @keywords internal
.jst_jai_print <- function() {
  txt <- .jst_orientation_text(.jst_orientation_stamp())
  cat("\n")
  cat(.jst_orientation_render_console(txt), sep = "\n")
  cat("\n")
  invisible(NULL)
}

# -- Output formatting helpers ------------------------------------------------

#' Internal helper: format a class vector for readable display
#'
#' Drops the uninformative "vctrs_vctr" class and appends "(Categorical)"
#' to "haven_labelled" to make the type line more meaningful to the user.
#'
#' @keywords internal
.format_var_type <- function(classes) {
  is_haven  <- "haven_labelled" %in% classes
  classes   <- classes[classes != "vctrs_vctr"]
  type_str  <- paste(classes, collapse = ", ")
  if (is_haven) type_str <- paste0(type_str, " (Categorical)")
  type_str
}

#' Internal helper: print a string in red using ANSI escape codes
#'
#' Works in RStudio, most terminals, and R Markdown HTML output.
#' Falls back to plain text in environments that strip ANSI codes.
#'
#' @keywords internal
.cat_red <- function(x) {
  cat(paste0("\033[31m", x, "\033[0m"))
}

#' Internal helper: print text in yellow ANSI color
#'
#' Used for informational/status notes where the text should be visually
#' distinct from regular output but not alarming (matches the "warning/note"
#' color convention).
#'
#' @keywords internal
.cat_yellow <- function(x) {
  cat(paste0("\033[33m", x, "\033[0m"))
}

#' Internal helper: print the "Using default data frame: X" note in yellow
#'
#' Used by every analysis function immediately after its red title line.
#' Groups the default-data-frame note with other session-state notes (jsubset,
#' jcomplete) under a consistent yellow coloring.
#'
#' @param data_name Character string name of the default data frame.
#' @param extra_newline Logical. If TRUE, adds a trailing blank line after
#'   the note so it's visually separated from whatever prints next.
#'   Defaults to FALSE, so the note abuts the next line directly; the
#'   jcomplete and jdummy summaries pass TRUE explicitly to keep their
#'   trailing blank. (Default flipped TRUE -> FALSE in Session 52 to
#'   collapse the double blank line above the Case Processing block.)
#' @keywords internal
.jst_default_note <- function(data_name, extra_newline = FALSE) {
  .cat_yellow(paste0("Using default data frame: ", data_name, "\n"))
  if (extra_newline) cat("\n")
}

#' Internal helper: build a persistence/durability note
#'
#' Returns the standardized "where does this state live, and how do you make
#' it last" note shared by every state-setting verb. The note states which
#' durability rung the just-applied state reached and the action to climb to
#' the next rung. The mechanics deliberately differ by verb -- the registry
#' verbs (jnumeric, jcount, jlikert, jdummy) annotate the session through a
#' notebook, while jdeclare_udm writes a missing-value declaration onto the
#' data frame -- so the rung argument selects the wording rather than the
#' helper inferring it.
#'
#' Returns the note as a single string with NO trailing newline. The "session"
#' rung carries a "Note:" prefix; the "frame" rung follows jdeclare_udm's
#' declaration block, so it has none. Callers emit it however they already do: the
#' registry verbs message() it; jdeclare_udm appends it to its larger
#' notification string. Visibility (standard and full, suppressed at minimal)
#' is the caller's gate, not this helper's.
#'
#' One deliberate divergence between the two rungs: the "session" rung names
#' "R format (.rds)" because registry registrations bake only into .rds, while
#' the "frame" rung says generic "save the data frame" because UDM codes also
#' survive .sav and .dta, so naming .rds there would be a false constraint.
#'
#' @param rung One of \code{"session"} (registry registrations -- jnumeric,
#'   jcount, jlikert, jdummy), \code{"frame"} (a UDM declaration --
#'   jdeclare_udm), or \code{"convert"} (a missing-value conversion --
#'   jconvert).
#' @param data_name Character string name of the data frame, used to build the
#'   jsave() example and, for the "frame" rung, the reassignment line.
#' @param count Integer number of registrations just set ("session" rung
#'   only); controls singular/plural agreement. Unspecified or not equal to 1
#'   yields the plural form.
#' @param verb Character string name of the calling verb ("frame" rung only),
#'   used to build the reassignment line.
#' @param var_name Character string variable name ("frame" rung only), used to
#'   build the reassignment line.
#' @keywords internal
.jst_durability_note <- function(rung, data_name, count = NULL,
                                 verb = NULL, var_name = NULL,
                                 modify = FALSE) {
  save_call <- paste0("jsave(", data_name, ", \"", data_name, ".rds\")")
  load_call <- paste0(data_name, " <- jload(\"", data_name, ".rds\")")
  if (identical(rung, "session")) {
    if (isTRUE(count == 1L)) {
      paste0(
        "Note: this registration is stored for this session only.\n",
        "To keep it across sessions, save the data frame in R format (.rds):\n",
        "  ", save_call, "\n",
        "\n",
        "Next session, load that file to restore the registration:\n",
        "  ", load_call
      )
    } else {
      paste0(
        "Note: registrations are stored for this session only.\n",
        "To keep them across sessions, save the data frame in R format (.rds):\n",
        "  ", save_call, "\n",
        "\n",
        "Next session, load that file to restore the registrations:\n",
        "  ", load_call
      )
    }
  } else if (identical(rung, "frame")) {
    if (isTRUE(modify)) {
      paste0(
        "To keep it across sessions, save the data frame:\n",
        "  ", save_call
      )
    } else {
      paste0(
        "This call changes ", data_name, " only if you assign the result:\n",
        "  ", data_name, " <- ", verb, "(", data_name, ", ", var_name, ", ...)\n",
        "\n",
        "To change ", data_name, " directly, rerun with modify = TRUE:\n",
        "  ", verb, "(", data_name, ", ", var_name, ", ..., modify = TRUE)"
      )
    }
  } else if (identical(rung, "convert")) {
    if (isTRUE(modify)) {
      paste0(
        "To keep it across sessions, save the data frame:\n",
        "  ", save_call
      )
    } else {
      paste0(
        "This call changes ", data_name, " only if you assign the result:\n",
        "  ", data_name, " <- jconvert(", data_name, ", ...)\n",
        "\n",
        "To change ", data_name, " directly, rerun with modify = TRUE:\n",
        "  jconvert(", data_name, ", ..., modify = TRUE)"
      )
    }
  } else {
    stop("Internal error: .jst_durability_note() rung must be ",
         "\"session\", \"frame\", or \"convert\".", call. = FALSE)
  }
}

#' Internal helper: retrieve a variable label as a string
#'
#' Returns the label if present, otherwise the string "None".
#'
#' @keywords internal
.get_var_label_str <- function(x) {
  vl <- labelled::var_label(x)
  if (!is.null(vl) && length(vl) > 0 && !is.na(vl[1]) && nzchar(vl[1])) {
    as.character(vl[1])
  } else {
    "None"
  }
}

#' Internal helper: print variable label legend
#'
#' Used by jt, jaov, jcorr, jcrosstab, jscreen, and jalpha. Lists only
#' variables that carry a meaningful label: a variable with no label, or a
#' label equal to its own name, is omitted (avoiding a redundant "X = X"
#' line). If no variable has a meaningful label, nothing is printed.
#'
#' @keywords internal
.print_var_labels <- function(data, var_names) {
  shown_names  <- character(0)
  shown_labels <- character(0)
  for (v in var_names) {
    if (v %in% names(data)) {
      vl <- labelled::var_label(data[[v]])
      if (!is.null(vl) && !is.na(vl) && nzchar(vl) &&
          !identical(as.character(vl), v)) {
        shown_names  <- c(shown_names, v)
        shown_labels <- c(shown_labels, as.character(vl))
      }
    }
  }
  if (length(shown_names) > 0) {
    # Pad names to the widest so the "=" signs line up; with similar-length
    # names (e.g. a Likert battery) the column is tight, and it degrades
    # gracefully when names differ a lot.
    w <- max(nchar(shown_names))
    label_lines <- paste0("  ", formatC(shown_names, width = w, flag = "-"),
                          " = ", shown_labels)
    cat("Variable Labels:\n")
    cat(paste(label_lines, collapse = "\n"))
    cat("\n\n")
  }
}

#' Internal helper: print a role-grouped model variable-label legend
#'
#' The regression layout's replacement for the flat \code{.print_var_labels}
#' list: lists a model's variables grouped by role -- the outcome first, then
#' the predictors. A variable with a label that differs from its name shows as
#' "name = label"; a variable with no label (or a label equal to its name)
#' shows as the bare "name" (absence of a meaningful label is conveyed by its
#' absence, not by a "None" marker). Used by jlm and jlogistic in the
#' "legend" and "legend.bottom" variable.id modes. Predictors are listed by
#' their original formula names (e.g. "Program"), not expanded dummy columns;
#' per-dummy-level value labelling is handled separately by the value.id
#' coefficient work. Matches the flat legend's indented-lines + trailing-blank
#' structure so co-located blocks space the same way.
#'
#' @param data A data frame (or pre-conversion label source) whose columns may
#'   carry variable labels.
#' @param dv_name Character. The outcome (response) variable name.
#' @param iv_names Character vector. The predictor variable names, in order.
#'
#' @keywords internal
.print_model_var_labels <- function(data, dv_name, iv_names) {
  has_label <- function(v) {
    vl <- labelled::var_label(data[[v]])
    !is.null(vl) && length(vl) > 0 && !is.na(vl[1]) && nzchar(vl[1]) &&
      !identical(as.character(vl[1]), v)
  }
  # Width for the "=" column: the widest name that actually shows a label,
  # taken across BOTH roles so the outcome and predictors align as one column.
  shown   <- c(if (length(dv_name) == 1L && dv_name %in% names(data)) dv_name,
               iv_names[iv_names %in% names(data)])
  labeled <- shown[vapply(shown, has_label, logical(1))]
  w <- if (length(labeled) > 0L) max(nchar(labeled)) else 0L
  fmt_line <- function(v) {
    # Show "name = label" only when a label exists and differs from the name;
    # a label equal to the name (or no label at all) shows the bare name,
    # avoiding a redundant "X = X" line.
    if (has_label(v)) {
      paste0("  ", formatC(v, width = w, flag = "-"), " = ",
             as.character(labelled::var_label(data[[v]])[1]))
    } else {
      paste0("  ", v)
    }
  }
  block <- character(0)
  if (length(dv_name) == 1L && dv_name %in% names(data)) {
    block <- c(block, "Outcome:", fmt_line(dv_name))
  }
  iv_present <- iv_names[iv_names %in% names(data)]
  if (length(iv_present) > 0L) {
    block <- c(block, "Predictors:",
               vapply(iv_present, fmt_line, character(1), USE.NAMES = FALSE))
  }
  if (length(block) > 0L) {
    cat(paste(block, collapse = "\n"))
    cat("\n\n")
  }
}

#' Internal helper: print a value-label legend block
#'
#' Companion to \code{.print_var_labels} for the \code{value.id} legend modes.
#' Emits one line per variable that carries value labels, in the form
#' \code{varname: code = label, code = label, ...} under a \code{Value Labels:}
#' header, matching the variable-label block's header + indented-lines + blank
#' line structure. One line per variable (locked design); legend lines are not
#' table cells, so they are not width-capped. Variables without value labels
#' contribute nothing; if no variable carries any, nothing is printed.
#'
#' @param data A data frame (or pre-conversion label source) whose columns may
#'   carry value labels (\code{labelled::val_labels}).
#' @param var_names Character vector of variable names to document, in order.
#'
#' @keywords internal
.print_value_labels <- function(data, var_names) {
  label_lines <- c()
  for (v in var_names) {
    if (v %in% names(data)) {
      vls <- labelled::val_labels(data[[v]])
      if (!is.null(vls) && length(vls) > 0L) {
        pairs <- paste0(unname(vls), " = ", names(vls))
        label_lines <- c(label_lines,
                         paste0("  ", v, ": ", paste(pairs, collapse = ", ")))
      }
    }
  }
  if (length(label_lines) > 0) {
    cat("Value Labels:\n")
    cat(paste(label_lines, collapse = "\n"))
    cat("\n\n")
  }
}

#' Internal helper: print variable- and value-label legends (single position)
#'
#' For single-table functions (jt, jaov, jcrosstab) and grouped jdesc, where
#' both \code{"legend"} and \code{"legend.bottom"} resolve to the same place --
#' after the table. Emits one lead-in blank line if either block will print,
#' then the variable-label block first and the value-label block second (the
#' Session 60 ordering lock). Each block supplies its own trailing blank line,
#' so co-located blocks are separated by exactly one blank line. The two blocks
#' can document different variable sets (e.g. jt's variable legend covers DV +
#' group, but only the group carries the value.id legend).
#'
#' @param data Data frame / label source.
#' @param vars_var Variable names for the variable-label block.
#' @param vars_val Variable names for the value-label block.
#' @param vlmode Resolved variable.id mode.
#' @param value_mode Resolved value.id mode.
#' @param lead Logical. Emit the lead-in blank line. Default TRUE. Pass FALSE
#'   when the caller's preceding output already supplies a trailing blank line
#'   (e.g. grouped jdesc, where the last group table emits one).
#'
#' @keywords internal
.jst_print_legends <- function(data, vars_var, vars_val, vlmode, value_mode,
                               lead = TRUE) {
  leg <- c("legend", "legend.bottom")
  vmode_leg   <- vlmode %in% leg
  valmode_leg <- value_mode %in% leg
  if (lead && (vmode_leg || valmode_leg)) cat("\n")
  if (vmode_leg)   .print_var_labels(data, vars_var)
  if (valmode_leg) .print_value_labels(data, vars_val)
}

#' Internal helper: print legends at a specific position (per-table / bottom)
#'
#' For multi-variable functions (jfreq) where \code{"legend"} prints under each
#' variable's own table and \code{"legend.bottom"} prints once after all
#' tables. Called at each position; prints only the block(s) whose mode matches
#' \code{position}. No lead-in blank: the caller's table already emits a
#' trailing blank line. Variable-label block first, value-label block second
#' when both land at the same position; each block's trailing blank line
#' separates co-located blocks.
#'
#' @param data Data frame / label source.
#' @param vars_var Variable names for the variable-label block.
#' @param vars_val Variable names for the value-label block.
#' @param vlmode Resolved variable.id mode.
#' @param value_mode Resolved value.id mode.
#' @param position Either \code{"legend"} or \code{"legend.bottom"}.
#'
#' @keywords internal
.jst_print_legends_at <- function(data, vars_var, vars_val, vlmode, value_mode,
                                  position) {
  if (identical(vlmode, position))     .print_var_labels(data, vars_var)
  if (identical(value_mode, position)) .print_value_labels(data, vars_val)
}

#' Internal helper: combine a variable's name and label per variable.id mode
#'
#' Decouples the \code{variable.id} display decision from how each call site
#' fetches its label. The caller resolves two strings -- the bare \code{name}
#' and a \code{label_or_name} (the variable's label if it has one, otherwise
#' the name, as returned by \code{.jst_label_or_name} or an equivalent
#' closure) -- and this helper combines them according to \code{mode}:
#' \itemize{
#'   \item \code{"labels"}: the label (i.e. \code{label_or_name}).
#'   \item \code{"both"}: \code{"name: label"} when a label exists, else the
#'     bare name. "A label exists" is inferred from \code{label_or_name}
#'     differing from \code{name}; an unlabelled variable (where the two are
#'     equal) collapses to the name, mirroring \code{value.id = "both"}'s
#'     per-variable degrade.
#'   \item \code{"names"}, \code{"legend"}, \code{"legend.bottom"}: the bare
#'     name (legend modes keep the name in place and emit the label
#'     separately via \code{.print_var_labels}).
#' }
#' The colon-space join matches \code{.jst_format_value_labels}'s
#' \code{"both"} form, so a name+label identifier reads identically to a
#' code+label category. \code{cap = TRUE} routes the result through the shared
#' 40-column cap; pass it only for in-table-column surfaces (jdesc/jcorr/jalpha
#' row-label columns), never for title or heading lines.
#'
#' @param name Single character: the bare variable name.
#' @param label_or_name Single character: the label if present, else the name.
#' @param mode One of \code{"both"}, \code{"names"}, \code{"labels"},
#'   \code{"legend"}, \code{"legend.bottom"}.
#' @param cap Logical. Apply the in-table width cap. Default FALSE.
#'
#' @return Single character display string.
#'
#' @keywords internal
.jst_combine_id <- function(name, label_or_name, mode, cap = FALSE) {
  out <- switch(mode,
    labels = label_or_name,
    both   = if (identical(label_or_name, name)) name
             else paste0(name, ": ", label_or_name),
    name)
  if (isTRUE(cap)) .jst_truncate_ellipsis(out) else out
}

#' Internal helper: variable label for display, falling back to the name
#'
#' Used by the \code{"labels"} variable.id mode, where a variable's label
#' replaces its name in table rows, table captions, crosstab dimnames, or
#' (in jplot) axis/legend/facet titles. When the variable carries no
#' non-empty variable label, its name is returned unchanged. This name
#' fallback is the only sensible rendering for an unlabelled variable and
#' is distinct from a mode fallback: \code{"labels"} is still honored
#' literally (no switch to a legend), the label slot simply equals the
#' name.
#'
#' @param data A data frame.
#' @param var Single variable name (character).
#'
#' @return Single character string: the variable's label if present and
#'   non-empty, otherwise \code{var}.
#'
#' @keywords internal
.jst_label_or_name <- function(data, var) {
  if (!is.null(data) && var %in% names(data)) {
    vl <- labelled::var_label(data[[var]])
    if (!is.null(vl) && length(vl) == 1 && !is.na(vl) && nzchar(vl)) {
      return(as.character(vl))
    }
  }
  var
}

#' Internal helper: decimal places needed to display a numeric column
#'
#' Values reaching the table renderer are already rounded at their source
#' (round(x, digits_n)). This returns the number of decimal places needed to
#' show such a column faithfully: each finite value is written to \code{cap}
#' decimal places with \code{formatC(format = "f")} and its trailing zeros are
#' removed; the count of decimals that remain is that value's requirement, and
#' the column-wise maximum is returned so the whole column shares one decimal
#' width (the decimal-point alignment the renderer relies on). The fixed-format
#' write avoids the magnitude-scaled tolerance of a round()/all.equal test,
#' which under-resolves trailing decimals for larger-magnitude values (e.g.
#' 40.0599999 collapsing to 40.06). The cap (default 7, the joutput digits
#' maximum) bounds an unrounded full-precision value reaching the renderer. An
#' all-NA / non-finite column returns 0.
#'
#' @param x A numeric vector (one already-rounded table column).
#' @param cap Integer. Maximum number of decimal places to consider
#'   (default 7, the joutput digits ceiling).
#'
#' @return Integer scalar: the number of decimal places needed to display
#'   \code{x} faithfully, capped at \code{cap}. Returns 0 for an all-NA or
#'   non-finite column.
#'
#' @keywords internal
.jst_col_dp <- function(x, cap = 7L) {
  x <- x[is.finite(x)]
  if (length(x) == 0L) return(0L)
  s   <- formatC(x, format = "f", digits = cap)
  s   <- sub("\\.?0+$", "", s)
  dec <- ifelse(grepl(".", s, fixed = TRUE),
                nchar(sub("^[^.]*\\.", "", s)),
                0L)
  max(dec)
}

#' Internal helper: print a formatted table with precise column alignment
#'
#' Purpose-built table printer that replaces knitr::kable() for console output.
#' Provides right-justified numbers, left-justified text, clean separator lines,
#' and consistent indentation. No external dependencies --- pure base R.
#'
#' @param df A data frame to print.
#' @param col.names Optional character vector of column headers. If NULL,
#'   uses \code{names(df)}.
#' @param row.names Logical. If TRUE, includes row names as the first column.
#' @param align Optional character vector of alignment codes ("l", "r", "c",
#'   or "d"), one per displayed column. If NULL, auto-detects: numeric = right,
#'   character/other = left. Code "d" is a decimal-tab: data cells are
#'   right-justified (so a uniform decimal-places column aligns on the decimal
#'   point) while the header stays centered over the column.
#' @param caption Optional title string printed above the table.
#' @param indent Number of leading spaces for each data row. Default 0,
#'   so data rows sit flush at column 1, aligned with the caption, header,
#'   and separator (which use \code{header.indent}). Callers that want a
#'   nested/indented sub-table pass a positive value (e.g. \code{indent = 4}).
#' @param header.indent Number of leading spaces for the caption,
#'   header row, and separator row. Defaults to 0. With the default
#'   \code{indent}, header and data share the same left edge; raise one
#'   relative to the other only for special layouts.
#'
#' @keywords internal
.jst_print_table <- function(df, col.names = NULL, row.names = TRUE,
                             align = NULL, caption = NULL, indent = 0,
                             header.indent = 0) {

  headers <- if (!is.null(col.names)) col.names else names(df)

  # Build display matrix
  display_cols <- lapply(seq_len(ncol(df)), function(j) {
    col <- df[[j]]
    if (is.numeric(col)) {
      # Values reaching the renderer are already rounded at their source
      # (round(x, digits_n)). format()'s default is getOption("digits") = 7
      # SIGNIFICANT figures, which silently drops decimals once a value's
      # integer part is large -- a chi-square / F / large mean/SD whose
      # integer part has k digits keeps only (7 - k) decimals, fewer than
      # digits requested. Instead detect the column's intended decimal places
      # from the already-rounded values and format to that fixed count with
      # formatC(format = "f"): large-magnitude statistics keep their
      # decimals, counts / percentages keep the precision set at their
      # source, scientific notation stays off (e.g. 200000, not "2e+05"),
      # and the whole column shares one decimal width so right-justified
      # columns still align on the decimal point. (Sessions 50, 119)
      dp <- .jst_col_dp(col)
      ifelse(is.na(col), "", formatC(col, format = "f", digits = dp))
    } else {
      as.character(ifelse(is.na(col), "", col))
    }
  })
  display <- do.call(cbind, display_cols)

  if (row.names && !is.null(rownames(df)) &&
      !identical(rownames(df), as.character(seq_len(nrow(df))))) {
    display <- cbind(rownames(df), display)
    headers <- c("", headers)
    # If the caller passed an explicit align vector sized for the data
    # columns only, prepend "l" so the row-names column gets left-
    # justification and the rest shift into the right slots. Without
    # this, align[1] would silently absorb the row-names column (causing
    # variable names to be centered when the caller intended "c" for the
    # first data column) and align[n_displayed_cols] would be NA
    # (causing the last column to fall through to the default left
    # alignment). Skip the prepend if the caller already supplied a
    # vector matching the displayed-column count, on the assumption they
    # did so deliberately.
    if (!is.null(align) && length(align) == ncol(df)) {
      align <- c("l", align)
    }
  }

  n_cols <- ncol(display)
  n_rows <- nrow(display)

  # Auto-detect alignment
  if (is.null(align)) {
    align <- character(n_cols)
    for (j in seq_len(n_cols)) {
      if (row.names && j == 1 && !identical(rownames(df), as.character(seq_len(nrow(df))))) {
        align[j] <- "l"
      } else {
        orig_col <- if (row.names && !identical(rownames(df), as.character(seq_len(nrow(df))))) j - 1 else j
        if (orig_col >= 1 && orig_col <= ncol(df) && is.numeric(df[[orig_col]])) {
          align[j] <- "r"
        } else {
          align[j] <- "l"
        }
      }
    }
  }

  # Column widths
  col_widths <- integer(n_cols)
  for (j in seq_len(n_cols)) {
    # "ln" (left, no-trim) columns carry caller-supplied leading whitespace
    # that must count toward the width (otherwise an all-positive column of
    # sign-slot-padded cells would overflow the gap). All other columns are
    # measured trimmed, as before.
    if (identical(align[j], "ln")) {
      data_widths <- nchar(display[, j])
    } else {
      data_widths <- nchar(trimws(display[, j]))
    }
    col_widths[j] <- max(nchar(headers[j]), max(data_widths, 0L, na.rm = TRUE))
  }

  gap    <- "  "
  prefix <- paste(rep(" ", indent), collapse = "")
  header_prefix <- paste(rep(" ", header.indent), collapse = "")

  fmt_cell <- function(text, width, alignment) {
    # "ln" (left, no-trim): left-justify but preserve the caller's leading
    # whitespace (used by jcorr to reserve a sign slot so r decimals line up
    # under a leading minus). Must NOT trim, unlike every other alignment.
    if (identical(alignment, "ln")) {
      return(formatC(text, width = -width, flag = "-"))
    }
    text <- trimws(text)
    switch(alignment,
           "r" = formatC(text, width = width, flag = " "),
           "c" = {
             pad   <- max(0L, width - nchar(text))
             left  <- pad %/% 2
             right <- pad - left
             paste0(strrep(" ", left), text, strrep(" ", right))
           },
           formatC(text, width = -width, flag = "-")
    )
  }

  if (!is.null(caption)) {
    cat(header_prefix, caption, "\n", sep = "")
  }

  # Decimal-tab columns ("d"): right-justify data so a uniform-dp column
  # aligns on the decimal point, while the header stays centered over
  # the column. Resolve "d" here; fmt_cell never sees "d".
  header_align <- ifelse(align == "d", "c", ifelse(align == "ln", "l", align))
  data_align   <- ifelse(align == "d", "r", align)

  # Header
  header_cells <- vapply(seq_len(n_cols), function(j) {
    fmt_cell(headers[j], col_widths[j], header_align[j])
  }, character(1))
  cat(header_prefix, paste(header_cells, collapse = gap), "\n", sep = "")

  # Separator
  sep_cells <- vapply(col_widths, function(w) {
    paste(rep("-", w), collapse = "")
  }, character(1))
  cat(header_prefix, paste(sep_cells, collapse = gap), "\n", sep = "")

  # Data rows
  for (i in seq_len(n_rows)) {
    row_cells <- vapply(seq_len(n_cols), function(j) {
      fmt_cell(display[i, j], col_widths[j], data_align[j])
    }, character(1))
    cat(prefix, paste(row_cells, collapse = gap), "\n", sep = "")
  }
}
