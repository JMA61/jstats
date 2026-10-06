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
#' The package is exercised in ongoing research projects by the author,
#' colleagues, and former students, and their feedback shapes its
#' refinement. Bug reports and suggestions are welcome through the
#' package's GitHub repository.
#'
#' @section Functions by purpose:
#' \strong{Descriptive analysis}
#' \itemize{
#'   \item \code{\link{jdesc}} -- univariate descriptives (mean, median,
#'     SD, range, etc.) with optional grouping
#'   \item \code{\link{jfreq}} -- frequency tables for one or more
#'     variables
#'   \item \code{\link{jcorr}} -- Pearson or Spearman correlations with
#'     significance tests
#'   \item \code{\link{jalpha}} -- Cronbach's alpha and item-total
#'     statistics for scale reliability
#'   \item \code{\link{jscreen}} -- data screening for outliers, ranges,
#'     and skew
#' }
#'
#' \strong{Group comparisons and modeling}
#' \itemize{
#'   \item \code{\link{jt}} -- independent or paired t-test
#'   \item \code{\link{jaov}} -- one-way analysis of variance with
#'     optional post-hoc tests
#'   \item \code{\link{jcrosstab}} -- cross-tabulation with chi-square
#'     and effect-size options
#'   \item \code{\link{jlm}} -- linear regression
#'   \item \code{\link{jlogistic}} -- logistic regression
#' }
#'
#' \strong{Variable construction}
#' \itemize{
#'   \item \code{\link{jrecode}} -- recode values, with optional new
#'     value labels
#'   \item \code{\link{jrelabel}} -- apply or replace value labels and
#'     variable label
#'   \item \code{\link{jencode}} -- encode a text or factor variable as
#'     labelled numeric codes
#'   \item \code{\link{jsum}} -- row-wise sum across variables, with
#'     min-valid handling
#'   \item \code{\link{javg}} -- row-wise mean across variables, with
#'     min-valid handling
#' }
#'
#' \strong{Missing values}
#' \itemize{
#'   \item \code{\link{jdeclare_missing}} -- declare missing-value codes
#'     or ranges on one or more variables
#'   \item \code{\link{jconvert}} -- convert missing-value declarations
#'     between SPSS-style, Stata-style, SAS-style, and base R
#'     representations
#' }
#'
#' \strong{Variable classification}
#' \itemize{
#'   \item \code{\link{jdummy}} -- register categorical variables for
#'     dummy coding in regression
#'   \item \code{\link{jnumeric}} -- register variables as numeric for
#'     analysis
#'   \item \code{\link{jcount}} -- register variables as counts for
#'     analysis
#'   \item \code{\link{jlikert}} -- register variables as Likert
#'     (ordered response) items
#'   \item \code{\link{jcopy}} -- copy a data frame, carrying its
#'     classification registrations
#' }
#'
#' \strong{Session state and options}
#' \itemize{
#'   \item \code{\link{juse}} -- set the default data frame used
#'     implicitly by analysis functions
#'   \item \code{\link{jsubset}} -- activate a row-level case-selection
#'     expression applied to subsequent calls
#'   \item \code{\link{jcomplete}} -- activate listwise filtering on
#'     selected variables
#'   \item \code{\link{joutput}} -- set session-level output verbosity
#'     (minimal / standard / full)
#'   \item \code{\link{joptions}} -- set or display session-level
#'     package options (missing-value convention, data folder, and
#'     others)
#' }
#'
#' \strong{Data import and export}
#' \itemize{
#'   \item \code{\link{jload}} -- load data from \code{.rds},
#'     \code{.sav}, \code{.dta}, \code{.sas7bdat}, \code{.xpt},
#'     \code{.xlsx}, \code{.xls}, or \code{.csv}
#'   \item \code{\link{jsave}} -- save a data frame, with format
#'     inferred from the file extension
#'   \item \code{\link{jdata_dir}} -- return the configured data folder
#' }
#'
#' \strong{Visualization}
#' \itemize{
#'   \item \code{\link{jplot}} -- histograms, bar charts, scatterplots,
#'     and boxplots from a data frame, plus plots of result objects
#'     from \code{jt()}, \code{jlm()}, etc.
#' }
#'
#' \strong{Package and assistant support}
#' \itemize{
#'   \item \code{\link{jupdate}} -- update jstats to the latest version
#'   \item \code{\link{jai}} -- print the package orientation, or
#'     install it for an AI coding assistant
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
#' \code{jt(Age ~ Volunteer, data = community)}. Descriptive and
#' data-management functions take the data frame first, followed by
#' unquoted variable names: \code{jfreq(community, Region, Education)}.
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
#' override session-level settings. The Case Processing table
#' follows an auto rule at the standard tier: it prints when a filter
#' or listwise deletion excluded cases, and a one-line N statement
#' takes its place otherwise. See \code{?joutput} for the full toggle
#' behavior.
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
#' up to date it says so and stops. Otherwise it installs the update and then
#' confirms that the update actually happened before reporting success.
#'
#' @details
#' \strong{Where the update goes.} The update is installed into the library
#' folder that holds the copy of jstats currently loaded, so the version in
#' use is the one replaced. This matters when a computer has more than one
#' library folder (a system-wide one and a personal one, say): a plain
#' \code{install.packages("jstats")} puts the new version in whichever folder
#' is first on \code{.libPaths()}, which can leave a second copy of jstats
#' beside the original rather than replacing it. jupdate() follows the rule
#' \code{update.packages()} uses instead, and installs where the loaded copy
#' lives. To see where that is, run \code{find.package("jstats")}.
#'
#' \strong{If the folder cannot be written to.} Before installing, jupdate()
#' checks that R can create files in that folder. If it cannot -- typically
#' a system-wide folder such as Program Files on Windows, or a folder locked
#' by an institution's IT policy -- jupdate() stops and names the folder,
#' rather than installing a second copy somewhere else. Run R with permission
#' to write there (on your own Windows computer, usually by starting RStudio
#' as an administrator), or ask your IT department to install the update.
#'
#' \strong{How success is confirmed.} \code{install.packages()} only warns
#' when it cannot download or install a package; it does not stop. jupdate()
#' therefore does not take a quiet install as success. After the install it
#' reads the version now on disk in the target folder, and reports success
#' only when that version is newer than the one loaded. If it is not -- a
#' dropped connection part-way through, a repository the network cannot
#' reach, or a failed build -- jupdate() stops, states that the folder still
#' holds the old version, and repeats what \code{install.packages()} reported
#' about the cause so you can see why.
#'
#' \strong{The separate process.} The install runs in a separate R process
#' so the copy of jstats loaded in your session does not lock its own files
#' during the install (the usual cause of a failed update on Windows).
#'
#' \strong{After the update.} Restart R once to load the new version; the
#' success message shows how.
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
    # One sentence per line (voice Rule E), and no cause named that was not
    # checked (Rule AH): what failed is R's own read of a web address, which
    # an absent connection and a blocked one produce alike -- a firewall, a
    # proxy, an AI assistant's sandbox mode. Until Session 340 this said "no
    # internet connection was detected ... Connect and run jupdate() again",
    # which sends a user who IS connected looking for a fault they do not
    # have.
    .jst_stop(
      "jstats was not updated: R could not reach the internet.\n",
      "If this computer is offline, connect and run jupdate() again.\n",
      "If it is online, something is blocking R's connection, such as a ",
      "firewall or an AI assistant's sandbox mode."
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
    .jst_msg(msg)
    return(invisible(NULL))
  }

  installed_ver <- as.character(utils::packageVersion("jstats"))
  latest_ver    <- .jst_latest_universe_version()

  if (!is.na(latest_ver) &&
      package_version(latest_ver) <= package_version(installed_ver)) {
    .jst_msg("jstats v", installed_ver, " is already up to date.")
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
        "jstats v", latest_ver, " is available -- you have v", installed_ver,
        ". Update now?"
      )
    }
    if (utils::menu(c("Yes", "No"), title = prompt) != 1L) {
      .jst_msg("Update canceled.")
      return(invisible(NULL))
    }
  }

  # Install into the library holding the copy of jstats in use, so the update
  # replaces that copy rather than adding a second one wherever the child's
  # .libPaths()[1] happens to point (S309; the rule update.packages() itself
  # follows). Probe the folder first: the child is non-interactive, so an
  # unwritable target would die there with R's bare "unable to install
  # packages" and nothing to act on.
  lib <- .jst_update_target_lib()
  if (!.jst_lib_writable(lib)) {
    .jst_stop(
      "R cannot write to the folder where jstats is installed:\n",
      "  ", lib, "\n",
      "Run R with permission to write to that folder (on your own Windows ",
      "computer, this usually means starting RStudio as an administrator), ",
      "then run jupdate() again.\n",
      "On a work or university computer, your IT department can do this ",
      "for you."
    )
  }

  .jst_msg("Updating jstats ... (this may take a moment)")

  # Install in a clean, separate R process (via callr, an Imports dependency, so
  # always available). Because that process never loads jstats, the package
  # files are not locked, and the install completes even on Windows. A genuine
  # install failure makes the child error, which is surfaced honestly.
  reported <- character(0)
  err <- tryCatch({
    reported <- .jst_update_install(lib)
    NULL
  }, error = function(e) conditionMessage(e))

  if (!is.null(err)) {
    .jst_stop("the update did not complete. The error was: ", err)
  }

  # install.packages() only WARNS when it cannot download or install a
  # package, so a child that returns normally proves nothing (S309). Success
  # is the version now on disk in the target library being newer than the
  # one this session loaded; anything else is a failure, reported with ONE
  # of the child's warnings: the first that names a web address (R's
  # download layer warns about byte counts before it says what it could not
  # reach, and the address survives translation where the wording does
  # not), else the first there is.
  now <- .jst_update_installed_version(lib)
  if (is.null(now) ||
      package_version(now) <= package_version(installed_ver)) {
    reason <- if (length(reported)) {
      named <- grep("://", reported, fixed = TRUE)
      pick  <- if (length(named)) named[[1L]] else 1L
      gsub("[[:space:]]+", " ", trimws(reported[[pick]]))
    } else NULL
    .jst_stop(
      "the update did not complete.\n",
      "The copy in this folder is still version ", installed_ver, ":\n",
      "  ", lib,
      if (!is.null(reason)) {
        paste0("\nR reported:\n  ", reason,
               "\nOnce that is fixed, run jupdate() again.")
      } else {
        "\nRun jupdate() again."
      }
    )
  }

  .jst_msg(
    "jstats has been updated to version ", now, ".\n",
    "\n",
    "Restart R to load it in RStudio:\n",
    "  - open the Session menu > choose Restart R\n",
    "  - or press Ctrl+Shift+F10\n",
    "\n",
    "If your startup loads packages automatically, their usual messages will ",
    "appear after the restart; otherwise the Console returns to an empty prompt.\n",
    "Reload jstats with library(jstats) (unless loaded automatically on startup)."
  )

  invisible(NULL)
}


#' Internal helper: the library folder an update of jstats should go into
#'
#' Returns the library holding the copy of jstats in use, so that jupdate()
#' replaces that copy rather than installing beside it. find.package() with no
#' lib.loc lists the LOADED namespace's path first, so the answer is the copy
#' actually running even when .libPaths() was changed after startup. Under
#' devtools::load_all() that path is a source folder, not a library; a result
#' that is not one of .libPaths() therefore falls back to
#' \code{.libPaths()[1]} -- install.packages()'s own default, and a developer
#' state, so it is silent. Same rule as update.packages()'s instlib default.
#' (S309)
#'
#' @param pkg_path The installed (or loaded) package's folder; defaults to
#'   find.package("jstats"). Supplied only by tests.
#' @return A single library path, normalized.
#' @keywords internal
.jst_update_target_lib <- function(pkg_path = find.package("jstats")) {
  lib  <- normalizePath(dirname(pkg_path), winslash = "/", mustWork = FALSE)
  libs <- normalizePath(.libPaths(), winslash = "/", mustWork = FALSE)
  if (lib %in% libs) lib else libs[1L]
}


#' Internal helper: can this session write into a library folder?
#'
#' Tries to create and remove a scratch directory inside lib, R core's own
#' test in install.packages() ("file.access is unreliable on Windows ... the
#' only known reliable way is to try it"); used on every platform because the
#' attempt is the ground truth on all of them. A folder that does not exist
#' is not writable. (S309)
#'
#' @param lib A single library path.
#' @return TRUE or FALSE.
#' @keywords internal
.jst_lib_writable <- function(lib) {
  if (!dir.exists(lib)) return(FALSE)
  probe <- file.path(lib, paste0("_test_dir_", Sys.getpid()))
  unlink(probe, recursive = TRUE)
  made <- tryCatch(dir.create(probe, showWarnings = FALSE),
                   error = function(e) FALSE)
  if (isTRUE(made)) unlink(probe, recursive = TRUE)
  isTRUE(made)
}


#' Internal helper: install the latest jstats into lib in a child R process
#'
#' The callr hand-off jupdate() makes, factored out so a test can stand in
#' for it and see the library it was handed. The child never loads jstats,
#' so the package files are not locked (the usual cause of a failed update
#' on Windows). install.packages() reports every failure it meets -- a
#' repository it cannot reach, a package it cannot find, an install that
#' exits non-zero -- as a WARNING and returns normally, so the child
#' collects those warnings and returns them for the caller to act on; the
#' caller decides success by what is on disk afterwards. Errors propagate.
#' (S309)
#'
#' @param lib The library folder to install into.
#' @return A character vector of the warnings install.packages() raised in
#'   the child, in order; empty when it raised none.
#' @keywords internal
.jst_update_install <- function(lib) {
  callr::r(
    function(lib) {
      reported <- character(0)
      withCallingHandlers(
        install.packages(
          "jstats",
          lib   = lib,
          repos = c("https://jma61.r-universe.dev", "https://cloud.r-project.org")
        ),
        warning = function(w) {
          reported <<- c(reported, conditionMessage(w))
          invokeRestart("muffleWarning")
        }
      )
      reported
    },
    args = list(lib = lib)
  )
}


#' Internal helper: the version of jstats now installed in a library folder
#'
#' Reads the installed package's metadata from lib on disk -- not the
#' loaded namespace -- so that after a child process has installed an
#' update the answer reflects what the child left there. (S309)
#'
#' @param lib A single library path.
#' @return The version string, or NULL when no jstats is installed in lib.
#' @keywords internal
.jst_update_installed_version <- function(lib) {
  d <- tryCatch(
    suppressWarnings(utils::packageDescription("jstats", lib.loc = lib)),
    error = function(e) NULL
  )
  if (!is.list(d) || is.null(d$Version)) return(NULL)
  as.character(d$Version)
}


#' Print the jstats orientation, or install it for an AI assistant
#'
#' \code{jai()} prints a short, plain-text orientation to the package's core
#' conventions: how to load data, how jstats handles value labels and
#' declared missing values, how to choose an analysis function, and how
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
      .jst_msg("Note: `path` is used only when writing a file and was ignored.")
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
    .jst_msg("Note: `path` is used only when writing a file and was ignored.")
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
#' Bumped whenever the orientation content changes -- the shared body, or
#' the SKILL.md frontmatter description (which sits outside the body but
#' inside the artifact this stamp vouches for). Stamped into every
#' emission (console print, AGENTS.md block, SKILL.md) so a saved copy can
#' be recognized as stale after a package update.
#' @keywords internal
.jst_orientation_version <- "3.7"

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
    "metadata: value labels and declared missing values are handled",
    "automatically.",
    "",
    "Note for AI assistants: jstats is newer than your training data. Do not",
    "rely on remembered or inferred jstats syntax. When unsure of a function's",
    "arguments, check them with `args()` (for example `args(jdeclare_missing)`) or",
    "the function's help page instead of guessing.",
    "",
    "- Start each session with `library(jstats)`. If the package is not",
    "  installed (`there is no package called 'jstats'`), do not guess an",
    "  install command -- jstats is not on CRAN yet, so `install.packages()`",
    "  alone will fail. Point the user to the install guide instead:",
    "  https://jma61.github.io/jstats-guides/install-jstats.html",
    "",
    "- Load data with `jload()`. It reads many file types (.rds, .sav, .dta,",
    "  .xlsx, .csv, ...) without separate packages such as haven or readxl, and",
    "  checks for undeclared missing-value codes that other loaders skip. The",
    "  shipped example datasets load the same way, by bare name:",
    "  `jload(\"clinic\")`, `jload(\"community\")` -- prefer this over `data()`,",
    "  which skips those checks. `jload()` places the dataset in the global",
    "  environment under its own name and returns nothing, so never assign",
    "  the result: `x <- jload(\"clinic\")` binds only NULL. Loading does not",
    "  make a dataset the default for later calls; that is what `juse()` does.",
    "",
    "- Work with one dataset at a time, as in SPSS or Stata. Every function",
    "  takes the data frame first: `jscreen(community)`,",
    "  `jdesc(community, Age)`. `juse(community)` sets a default and is what",
    "  licenses the shorter form -- after that call, and only after it, the",
    "  data argument may be omitted: `jdesc(Age, Income)`,",
    "  `jt(CommuteTime ~ OwnsHome)`. Omitting the frame with no `juse()` in",
    "  the session is an error. Every result states which data frame it used.",
    "  When more than one data frame is in play, pass the frame explicitly or",
    "  switch the default with `juse()`. Prefer `jsubset()` and `jcomplete()`,",
    "  which filter cases without altering the data, over creating modified",
    "  copies of the data frame.",
    "",
    "- Before analysis, explore the data with `jscreen()` (variable types,",
    "  missing data, and outliers at a glance, for an unfamiliar dataset),",
    "  `jfreq()` (frequencies), and `jdesc()` (descriptives). Prefer jstats",
    "  functions over base R or tidyverse equivalents where they exist: their",
    "  output accounts for declared missing values, and one consistent toolset",
    "  keeps the analysis easy to follow.",
    "",
    "- Before declaring missing values, choose a convention once per session:",
    "  `joptions(missing.convention = \"stata\")`. Recommended: under Stata",
    "  convention the declared markers are true NAs in base R, so base",
    "  functions and AI-generated code get right answers without knowing",
    "  jstats exists. Under SPSS convention (`\"spss\"`) the codes stay visible",
    "  numbers -- jstats treats them as missing, but base functions such as",
    "  `mean()` do not and return wrong answers with no warning. (`\"sas\"` is",
    "  Stata with uppercase markers.) With no convention chosen,",
    "  `jdeclare_missing()` stops and shows this choice rather than guessing.",
    "",
    "- Declare stray codes such as -99 with",
    "  `jdeclare_missing(data, var, codes = c(-99, -98))` -- the argument is",
    "  `codes`. The codes must already be present in the data (imported .sav",
    "  and .dta files usually carry them; data built in R usually carry plain",
    "  `NA` instead), and `NA` itself cannot be declared. Do not filter such",
    "  values out by hand: jstats functions honor declared missing values",
    "  under every convention.",
    "",
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
    "",
    "- Analysis functions print their results directly; nothing needs to be",
    "  stored. The few functions that change data, such as `jdeclare_missing()` and",
    "  `jconvert()`, take `modify = TRUE` to apply the change directly",
    "  (`jdeclare_missing(df, ..., modify = TRUE)`) -- the form jstats teaches.",
    "  They also return the changed data frame, so assigning back",
    "  (`df <- jdeclare_missing(df, ...)`) works as well. `jconvert()`",
    "  translates missing-value codes between software conventions -- it is for",
    "  moving data to other software or to plain base-R form, and is never a",
    "  prerequisite for analysis in jstats, which reads labelled data directly.",
    "  Save data across sessions with `jsave()`.",
    "",
    "- Detailed help and worked examples for each function are available via",
    "  `?jdesc`, `?jdeclare_missing`, and so on.",
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
#' HTML comments: invisible in rendered Markdown. The start marker carries
#' the do-not-edit directive, addressed to BOTH readers -- the human
#' editing the file and an assistant that may edit it agentically -- with
#' the overwrite consequence as its rationale; the end marker carries the
#' checksum of the lines strictly between the two markers, as generated,
#' plus the redirect telling the user where their own notes belong.
#' Detection matches on the stable prefixes only, so the wording of either
#' marker can change without stranding deployed blocks. Each marker must
#' stay ONE physical line: block bounds are line indices and everything
#' strictly between them is checksummed content, so a wrapped marker would
#' fold its continuation into the block. No "--" inside the comments (a
#' double hyphen is invalid in an HTML comment).
#' @keywords internal
.jst_agents_marker_start <- function() {
  paste0("<!-- jstats orientation: start - do not edit inside; edits are ",
         "overwritten when jai(\"project\") runs again -->")
}

#' Internal helper: the AGENTS.md end marker
#'
#' Counterpart of .jst_agents_marker_start(); carries the checksum of the
#' lines strictly between the two markers, as generated, for edit
#' detection, and the redirect telling the user where their own notes
#' belong. The checksum parse anchors on the bracketed field, so trailing
#' text after it is safe.
#' @keywords internal
.jst_agents_marker_end <- function(checksum) {
  paste0("<!-- jstats orientation: end [checksum: ", checksum,
         "] - keep your own notes outside this block -->")
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

#' Internal helper: validated yes/no console confirmation
#'
#' The shared confirmation reader behind every user-facing prompt (jsave,
#' jload, jcopy, and jai via .jst_jai_confirm). Reads one answer with
#' readline() and validates it: y/yes proceeds, n/no declines, and
#' anything else -- including an empty answer -- stops with an error. The
#' validation exists because advancing a script while a prompt is waiting
#' -- select-all + Run, pasting, or stepping line by line with Ctrl+Enter
#' -- sends the next script line as the answer: the operation cancels, the
#' consumed line never executes, and nothing announces either. An
#' unrecognizable answer is treated as that case, since no human's reply
#' at a y/n prompt is a function call or a comment. Deliberately does NOT
#' re-prompt on invalid input -- a retry would consume a further script
#' line and compound the misalignment.
#'
#' Enter is NOT a decline (S221, widening the original E8 scope on
#' evidence). RStudio sends a script's blank lines to the console, so a
#' blank line following a prompting call is consumed and arrives here as
#' "" -- and a blank line after a save is ordinary formatting, making it
#' the COMMONEST route into the silent non-write this helper exists to
#' prevent. Since every call site is interactive()-guarded (jai stops
#' before its prompt when non-interactive), an empty answer has exactly
#' two possible origins: a human pressed Enter, or a blank script line
#' was consumed. Treating it as an error costs the first case an error
#' instead of a quiet cancel -- the operation does not happen either way,
#' so nothing is at risk -- and closes the second. The prompt reads
#' "(y/n):" with no capitalized default, so it never promised Enter would
#' answer it.
#'
#' Message shape (Rules D and I): the question, the received text on its
#' own line, and ONE corrective action. The received text carries the
#' diagnosis, so no sentence explains the mechanism -- it would be
#' accurate for the script case and wrong for a user who simply typed
#' "yep", and both readers act on the same fix. The text is shown
#' unquoted because a consumed line is often itself quoted. The two
#' truncation bounds differ ON PURPOSE: clipping starts only past 70
#' characters but cuts to 60, so a line just over the display width is
#' shown whole rather than losing a character or two to an ellipsis that
#' saves nothing. The empty case takes a two-line form of its own, since
#' "It received:" followed by nothing reads as a rendering fault.
#'
#' The error routes through .jst_stop(), whose stack walk skips this
#' helper (no j-prefix) and prefixes the user-facing caller's name.
#' @param prompt The single-line prompt string, ending "(y/n): ".
#' @param remedy One sentence naming the caller-specific fix; becomes the
#'   error's final line.
#' @param subject The question's name as it reads in the error's first
#'   line; "overwrite" for the three overwrite prompts, "confirmation"
#'   for jai, which asks about writing rather than overwriting.
#' @return TRUE to proceed, FALSE to decline; or signals an error.
#' @keywords internal
.jst_confirm <- function(prompt, remedy, subject = "overwrite") {
  response <- trimws(readline(prompt))
  answer <- tolower(response)
  if (answer %in% c("y", "yes")) return(TRUE)
  if (answer %in% c("n", "no")) return(FALSE)
  if (!nzchar(answer)) {
    .jst_stop(
      "The ", subject, " question needs y or n. It received an empty line.\n",
      remedy
    )
  }
  shown <- if (nchar(response) > 70L) {
    paste0(substr(response, 1L, 60L), "...")
  } else {
    response
  }
  .jst_stop(
    "The ", subject, " question needs y or n. It received:\n",
    shown, "\n",
    remedy
  )
}

#' Internal helper: yes/no console confirmation for jai()
#'
#' Takes the informational lines only; the helper owns the question. The
#' split matters: readline()'s prompt is a SINGLE-line facility, so a
#' prompt carrying embedded newlines leaves the cursor parked after the
#' first line while the rest renders below it (confusing in RStudio).
#' Display goes through cat() to stdout -- not message(), which writes to
#' stderr, renders red in RStudio, and can interleave unpredictably right
#' before a prompt. The answer itself is read and validated by
#' .jst_confirm(); jai's fix is path = (naming the destination is the
#' consent, so no prompt fires), not overwrite =, and its question is
#' about writing a file rather than overwriting one.
#' @keywords internal
.jst_jai_confirm <- function(info) {
  cat("\n", sub("\n+$", "", info), "\n\n", sep = "")
  .jst_confirm(
    "Proceed? (y/n): ",
    "Set path = to name the destination folder and rerun.",
    subject = "confirmation"
  )
}

#' Internal helper: the declined-write note
#' @keywords internal
.jst_jai_declined <- function() {
  .jst_msg("Nothing was written.\n",
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
        target, "\n", caution))
      if (!ok) {
        .jst_jai_declined()
        return(invisible(NULL))
      }
    }
    writeLines(block, target)
    .jst_msg("Created the jstats orientation block in:\n  ", target, "\n",
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
        "\nYour existing content is untouched.\n", caution))
      if (!ok) {
        .jst_jai_declined()
        return(invisible(NULL))
      }
    }
    writeLines(c(lines, "", block), target)
    .jst_msg("Appended the jstats orientation block to:\n  ", target, "\n",
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
      info <- if (edited) {
        paste0("The jstats orientation block in this file has been edited ",
               "since it was generated.\n",
               "Replacing it will discard those edits:\n  ", target)
      } else {
        paste0("About to replace the jstats orientation block", vers,
               " in:\n  ", target)
      }
      if (!.jst_jai_confirm(info)) {
        .jst_jai_declined()
        return(invisible(NULL))
      }
    }
    out <- c(if (b$start > 1L) lines[1L:(b$start - 1L)],
             block,
             if (b$end < length(lines)) lines[(b$end + 1L):length(lines)])
    writeLines(out, target)
    if (edited && !interactive()) {
      .jst_warn("The previous jstats orientation block had been edited; ",
                "those edits were discarded.")
    }
    .jst_msg("Replaced the jstats orientation block", vers, " in:\n  ",
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
  .jst_msg("Found ", which_msg, " in:\n  ", target, "\n",
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
#' The when-to-use relevance trigger read by skill-supporting assistants,
#' and the only jstats text an assistant carries in EVERY conversation:
#' S209 established that the skill directory (name plus description) sits
#' in context from the start, while loading only fetches the body.
#'
#' EMITTED AS ONE PLAIN SCALAR ON THE description: LINE. NEVER WRAP IT.
#' S209 verified against the live runtime that a folded block scalar
#' (description: >-) yields an EMPTY description in the assistant's skill
#' directory -- fatal even with a single indented continuation line, and
#' silent: the skill still lists by name, so nothing looks wrong while the
#' match surface is gone. The runtime reads the value line-wise, whatever
#' the loader does with the rest of the file. Two probe runs were lost to
#' this. Consequences: the source keeps the sentences as separate elements
#' for editing only, joined here with single spaces (so no element may end
#' in a space, and none may contain ": ", which a plain scalar forbids).
#'
#' Wording per the S207 trigger-edge probe -- a token list, not prose, with
#' the dataset names load-bearing -- and the S209 closing sentence, which
#' pairs the anti-guessing warning with the remedy: warned but not told
#' what to do, the S209 run avoided jstats entirely and reached for haven.
#' @keywords internal
.jst_skill_description <- function() {
  paste(
    c("Use with the jstats R package or its example datasets community",
      "and clinic. jstats functions include jload, jdesc, jfreq, jscreen,",
      "jt, jaov, jcorr, jlm, jlogistic, jcrosstab, jalpha, jdeclare_missing,",
      "juse, jsave, jconvert. Load this skill before writing jstats code;",
      "its syntax is newer than model training data and must not be",
      "guessed."),
    collapse = " ")
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
    info <- if (had) {
      paste0("About to overwrite the jstats skill file:\n  ", target)
    } else {
      paste0("About to create the jstats skill file:\n  ", target,
             "\n(any missing folders on the way are created)")
    }
    if (!.jst_jai_confirm(info)) {
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
  .jst_msg(if (had) "Replaced" else "Created",
           " the jstats skill file:\n  ", target, "\n",
           "Assistants that support skills find it automatically; the ",
           "first use may ask for permission.")
  if (explicit) {
    .jst_msg("To be found automatically, the file must sit in a folder ",
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
  .jst_msg_out("\nThe paste primer for chat assistants is still in ",
               "development.\n",
               "For now, run jai() and paste the printed orientation into ",
               "your chat as your first message.")
  cat("\n")
  invisible(NULL)
}

#' Internal helper: one status line for a found orientation copy
#'
#' \code{noun} names the artifact the line is about: AGENTS.md carries a
#' marked block inside a user-owned file, while SKILL.md is package-owned
#' and overwritten whole, so "Block" is wrong for the skill case.
#' @keywords internal
.jst_orientation_state_line <- function(found_v, edited, regen_call,
                                        noun = "Block") {
  ed <- if (edited) ", hand-edited" else ""
  inst_v <- .jst_orientation_version
  if (is.null(found_v)) {
    return(paste0(noun, " present (version unknown", ed, ")."))
  }
  cmp <- tryCatch({
    a <- numeric_version(found_v)
    b <- numeric_version(inst_v)
    if (a < b) -1L else if (a > b) 1L else 0L
  }, error = function(e) NA_integer_)
  if (identical(cmp, 0L)) {
    paste0(noun, " v", found_v, ed, " -- current.")
  } else if (identical(cmp, -1L)) {
    paste0(noun, " v", found_v, ed, " -- older than installed v", inst_v,
           ". Regenerate with ", regen_call, ".")
  } else {
    paste0(noun, " v", found_v, ed, ".")
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
                 "jai(\"machine\")", noun = "File")),
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

#' Internal helper: should this output carry color?
#'
#' The one test behind \code{.cat_red()} and \code{.cat_yellow()}. Color is
#' written as ANSI escape sequences, which the RStudio Console draws as
#' color and almost everything else prints as raw characters
#' (\code{<ESC>[31mCross-Tabulation}): RGui, a plain terminal, output
#' captured with \code{sink()} or \code{capture.output()}, a knitr or
#' Quarto render. The rule (Jeff, Session 336: "Can we simply not do colour
#' outside of R Studio?") is color in the RStudio Console and plain text
#' everywhere else, by a check of the package's own -- no crayon or cli.
#'
#' "In the RStudio Console" is four things at once, because a capture and
#' a render both START inside RStudio:
#' \itemize{
#'   \item R is RStudio's own session process (\code{.Platform$GUI} is
#'     \code{"RStudio"}). A render launched from RStudio, a background job
#'     and the Terminal pane run R as a child process, where it is not.
#'   \item the Console says it draws color: RStudio sets the environment
#'     variable \code{RSTUDIO_CONSOLE_COLOR} when its "Show ANSI colors"
#'     preference is on.
#'   \item no \code{sink()} is diverting the output
#'     (\code{capture.output()} is one).
#'   \item no knitr run is in progress -- \code{rmarkdown::render()} typed
#'     in the Console runs in the session process.
#' }
#'
#' \code{options(jstats.color = TRUE)} forces color on wherever the output
#' goes and \code{FALSE} forces it off; unset is the rule above. The
#' switch is documented for users in \code{?joutput} ("Color"): it serves
#' a console that draws color but is not RStudio's, and the online guides,
#' whose Console facsimiles take their red titles and yellow notes from
#' these escapes during a (captured, knitr) render.
#'
#' The signals are arguments so that each arm can be tested anywhere; no
#' caller passes one.
#'
#' @param forced The \code{jstats.color} option.
#' @param gui \code{.Platform$GUI}.
#' @param console_color The \code{RSTUDIO_CONSOLE_COLOR} environment
#'   variable.
#' @param sinks The number of active output diversions.
#' @param knitting Is a knitr run in progress?
#' @return \code{TRUE} or \code{FALSE}.
#' @keywords internal
.jst_use_color <- function(forced        = getOption("jstats.color"),
                           gui           = .Platform$GUI,
                           console_color = Sys.getenv("RSTUDIO_CONSOLE_COLOR"),
                           sinks         = sink.number(),
                           knitting      = isTRUE(getOption("knitr.in.progress"))) {
  if (isTRUE(forced))  return(TRUE)
  if (isFALSE(forced)) return(FALSE)
  identical(gui, "RStudio") &&
    length(console_color) == 1L && !is.na(console_color) &&
    nzchar(console_color) && !identical(console_color, "0") &&
    sinks == 0L && !isTRUE(knitting)
}

#' Internal helper: print a string in red, where the output draws color
#'
#' Red in the RStudio Console (ANSI escape codes); plain text everywhere
#' else. See \code{.jst_use_color()}.
#'
#' @keywords internal
.cat_red <- function(x) {
  cat(if (.jst_use_color()) paste0("\033[31m", x, "\033[0m") else x)
}

#' Internal helper: print text in yellow, where the output draws color
#'
#' Used for informational/status notes where the text should be visually
#' distinct from regular output but not alarming (matches the "warning/note"
#' color convention). Yellow in the RStudio Console; plain text everywhere
#' else. See \code{.jst_use_color()}.
#'
#' @keywords internal
.cat_yellow <- function(x) {
  cat(if (.jst_use_color()) paste0("\033[33m", x, "\033[0m") else x)
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
#' notebook, while jdeclare_missing writes a missing-value declaration onto the
#' data frame -- so the rung argument selects the wording rather than the
#' helper inferring it.
#'
#' Returns the note as a single string with NO trailing newline. The "session"
#' rung carries a "Note:" prefix; the "frame" rung follows jdeclare_missing's
#' declaration block, so it has none. Callers emit it however they already do: the
#' registry verbs message() it; jdeclare_missing appends it to its larger
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
#'   jdeclare_missing), or \code{"convert"} (a missing-value conversion --
#'   jconvert).
#' @param data_name Character string name of the data frame, used to build the
#'   jsave() example and, for the "frame" rung, the reassignment line.
#' @param count Integer number of registrations just set ("session" rung
#'   only); controls singular/plural agreement. Unspecified or not equal to 1
#'   yields the plural form.
#' @param verb Character string name of the calling verb ("frame" rung only),
#'   used to build the reassignment line.
#' @param var_name Character string ("frame" rung only) placed where the
#'   call's variables go in the reassignment line: one variable name, or
#'   what \code{.jst_scaffold_vars()} returns for a call on several, which
#'   is \code{""} when the line's own \code{...} is to stand for them.
#' @param modify Logical. \code{TRUE} when the call wrote its result back
#'   (\code{modify = TRUE}); the "frame" and "convert" rungs then give the
#'   save tip in place of the reassignment lines.
#' @param data_kind What the call's data argument was, as
#'   \code{.jst_data_arg_kind()} reads it ("frame" and "convert" rungs).
#'   \code{"name"}, the default: a data frame's name or the \code{juse()}
#'   default, which gets both the reassignment line and the
#'   \code{modify = TRUE} line. \code{"place"}: somewhere a result can be
#'   assigned that is not a plain name (\code{lst$d}), which gets the
#'   reassignment line alone, because \code{modify = TRUE} needs a name.
#'   \code{"expression"}: anything else (\code{mk()}), which gets a line
#'   assigning the result to a new name. Until Session 339 the scaffold
#'   read \code{mk() <- jconvert(mk(), ...)}, which does not run (the
#'   S219 item, finding 2).
#' @param file_stem Character(1); the file name, without its extension, in
#'   the two example lines. The data frame's name by default. A caller whose
#'   data argument is a place passes \code{.jst_data_file_stem()}'s answer,
#'   so that \code{lst$d} is saved as \code{"d.rds"}: \code{"lst$d.rds"} is
#'   a poor file name and the double-bracket form's line does not parse
#'   (Session 342).
#' @keywords internal
.jst_durability_note <- function(rung, data_name, count = NULL,
                                 verb = NULL, var_name = NULL,
                                 modify = FALSE, data_kind = "name",
                                 file_stem = data_name) {
  save_call <- paste0("jsave(", data_name, ", \"", file_stem, ".rds\")")
  load_call <- paste0("jload(\"", file_stem, ".rds\")")
  # The reassignment block of the "frame" and "convert" rungs. call_open is
  # the call up to, and not including, its closing parenthesis.
  assign_or_modify <- function(call_open) {
    if (identical(data_kind, "expression")) {
      return(paste0(
        "The result is kept only if you assign it to a name:\n",
        "  mydata <- ", call_open, ")"))
    }
    out <- paste0(
      "This call changes ", data_name, " only if you assign the result:\n",
      "  ", data_name, " <- ", call_open, ")")
    if (identical(data_kind, "name")) {
      out <- paste0(
        out, "\n",
        "\n",
        "To change ", data_name, " directly, rerun with modify = TRUE:\n",
        "  ", call_open, ", modify = TRUE)")
    }
    out
  }
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
      # An empty var_name (.jst_scaffold_vars()) leaves the variables to
      # the template's "...".
      assign_or_modify(paste0(
        verb, "(", data_name,
        if (!is.null(var_name) && nzchar(var_name)) paste0(", ", var_name),
        ", ..."))
    }
  } else if (identical(rung, "convert")) {
    if (isTRUE(modify)) {
      paste0(
        "To keep it across sessions, save the data frame:\n",
        "  ", save_call
      )
    } else {
      assign_or_modify(paste0("jconvert(", data_name, ", ..."))
    }
  } else {
    stop("Internal error: .jst_durability_note() rung must be ",
         "\"session\", \"frame\", or \"convert\".", call. = FALSE)
  }
}

#' Internal helper: what kind of thing a call gave as its data argument
#'
#' Reads the data argument as typed and says whether a result can be
#' assigned back to it. A reassignment line built by pasting the argument on
#' both sides of an arrow is only R when the argument is a name or a place:
#' \code{mk() <- jconvert(mk(), ...)} is neither (the S219 item, findings 2
#' and 5; Session 339).
#'
#' @param data_sub The substituted data argument, or \code{NULL} when the
#'   call gave none and the \code{juse()} default was used.
#' @return \code{"name"} for a plain name (or \code{NULL});
#'   \code{"place"} for a \code{$}, double-bracket or slot access whose
#'   left side is itself a name or a place (\code{lst$d}); otherwise
#'   \code{"expression"}.
#' @keywords internal
.jst_data_arg_kind <- function(data_sub) {
  if (is.null(data_sub) || is.symbol(data_sub)) return("name")
  is_place <- function(e) {
    if (is.symbol(e)) return(TRUE)
    is.call(e) && length(e) >= 2L && is.symbol(e[[1L]]) &&
      as.character(e[[1L]]) %in% c("$", "[[", "@") && is_place(e[[2L]])
  }
  if (is_place(data_sub)) "place" else "expression"
}

#' Internal helper: the assign-or-lose reminder of jrecode() and jencode()
#'
#' Both functions return the new values and change nothing, so an
#' unassigned call drops them; the reminder closes each call's notes at the
#' standard and full output levels. The line it shows assigns to a variable
#' of the data frame the call named. An expression in the data's place --
#' \code{jencode(mt(), w)} -- has no such variable to assign to, and until
#' Session 343 the line read \code{mt()$<name> <- jencode(...)}, which is
#' not R (the S339 item's second half). It now gets the two lines the
#' registration verbs give: the expression assigned to a name, and the
#' assignment on that name. A place (\code{lst$d}) keeps the one line,
#' which runs.
#'
#' @param fn_name Character(1); \code{"jrecode"} or \code{"jencode"}.
#' @param data_name Character(1); the data frame as the lines name it.
#' @param data_kind What the call gave as its data, as
#'   \code{.jst_data_arg_kind()} reads it.
#' @param typed Character(1); the data argument as typed, for the
#'   \code{"expression"} kind's first line.
#' @param landed Character(1); the noun of the closing check line
#'   (\code{"recode"}, \code{"encoding"}).
#' @return Character(1) with a leading newline (voice Rule F) and no
#'   trailing one.
#' @keywords internal
.jst_assign_reminder <- function(fn_name, data_name, data_kind, typed,
                                 landed) {
  paste0(
    if (identical(data_kind, "expression")) {
      paste0(
        "\nNote: The result is kept only if you assign it.\n",
        "Name the data frame first, then assign the result to a variable ",
        "in it:\n")
    } else {
      paste0("\nNote: This call changes ", data_name,
             " only if you assign the result:\n")
    },
    .jst_assign_lines(fn_name, data_name, data_kind, typed),
    "To check the ", landed, " landed correctly, compare jfreq() on the ",
    "original and the new column.")
}

#' Internal helper: the assignment lines of an assign-or-lose reminder
#'
#' The code lines under the reminders of \code{jrecode()},
#' \code{jencode()}, \code{jsum()} and \code{javg()}, each of which
#' returns a new variable's values and changes nothing. A name or a place
#' gets the one pattern line it always had. An expression gets two: it is
#' assigned to \code{mydata}, and the pattern line is written on
#' \code{mydata}, because \code{mk()$<name> <- jsum(...)} is not R
#' (Session 343).
#'
#' @param fn_name Character(1); the function the lines call.
#' @param data_name Character(1); the data frame as the line names it.
#' @param data_kind What the call gave as its data, as
#'   \code{.jst_data_arg_kind()} reads it.
#' @param typed Character(1); the data argument as typed.
#' @return Character(1): one line or two, each ending in a newline.
#' @keywords internal
.jst_assign_lines <- function(fn_name, data_name, data_kind, typed) {
  if (identical(data_kind, "expression")) {
    return(paste0("  mydata <- ", typed, "\n",
                  "  mydata$<name> <- ", fn_name, "(mydata, ...)\n"))
  }
  paste0("  ", data_name, "$<name> <- ", fn_name, "(...)\n")
}

#' Internal helper: the file name a data argument is saved under
#'
#' The stem of the file in a save or load line built from a call's data
#' argument. A name gives itself. A place gives its last component when
#' that is a name -- \code{lst$d}, \code{lst[["d"]]} and \code{obj@d} all
#' give \code{d} -- and the placeholder \code{mydata} otherwise (a place
#' reached by position, \code{lst[[2]]}, or by a computed name). Until
#' Session 342 the registration note pasted the argument as typed, which
#' gave \code{jload("lst[["d"]].rds")}.
#'
#' @param data_sub The substituted data argument, or \code{NULL} when the
#'   \code{juse()} default was used.
#' @param data_name Character(1); the data frame's name as the message
#'   prints it.
#' @return Character(1).
#' @keywords internal
.jst_data_file_stem <- function(data_sub, data_name) {
  if (is.null(data_sub) || is.symbol(data_sub)) return(data_name)
  last <- NULL
  if (is.call(data_sub) && length(data_sub) == 3L &&
      is.symbol(data_sub[[1L]])) {
    h   <- as.character(data_sub[[1L]])
    rhs <- data_sub[[3L]]
    if (h %in% c("$", "@") && (is.symbol(rhs) || is.character(rhs))) {
      last <- as.character(rhs)
    } else if (h == "[[" && is.character(rhs) && length(rhs) == 1L) {
      last <- rhs
    }
  }
  if (length(last) == 1L && !is.na(last) && nzchar(last) &&
      identical(make.names(last), last)) last else "mydata"
}

#' Internal helper: refuse an expression given as the data to a registration
#'
#' A registration is stored under its data frame's NAME, so a registration
#' verb needs one. Given a call or a subset in the data's place --
#' \code{jnumeric(mk(), Age)}, \code{jdummy(d[d$Age > 30, ], Grp)} -- the
#' four verbs stored the registration under the text of the expression,
#' where no later call could reach it, and printed
#' \code{jsave(mk(), "mk().rds")} (the S339 item; Session 342, Jeff's lean
#' 1). The stop gives two lines that run: the expression assigned to a
#' name, and the user's own call on that name. A place (\code{lst$d}) is
#' not refused: it works end to end, since \code{jscreen(lst$d)} and
#' \code{jsave(lst$d, ...)} read the same text.
#'
#' A call that clears or removes (\code{jdummy(mk(), NULL)},
#' \code{remove = TRUE}) is refused too, with the status call as its
#' remedy: nothing is stored under an expression, and the registrations
#' the user means are under whatever name the data frame has.
#'
#' @param data_sub The substituted data argument, an expression.
#' @param fn_name Character; the calling verb.
#' @param cl The verb's call, as typed.
#' @param registering Logical; \code{FALSE} for a call that clears or
#'   removes.
#' @return Does not return; stops.
#' @keywords internal
.jst_registration_expression_stop <- function(data_sub, fn_name, cl,
                                              registering = TRUE) {
  typed <- .jst_term_text(data_sub)
  if (!isTRUE(registering)) {
    .jst_stop(
      typed, " is not a name, and registrations are stored under a data ",
      "frame's name.\n",
      "To see the registrations that are stored, run:\n",
      "  ", fn_name, "()",
      fn = fn_name)
  }
  args  <- as.list(cl)[-1L]
  hit   <- which(vapply(args, function(a) identical(a, data_sub), logical(1)))
  recall <- if (length(hit) == 1L) {
    args[[hit]] <- as.name("mydata")
    .jst_term_text(as.call(c(list(as.name(fn_name)), args)))
  } else {
    paste0(fn_name, "(mydata, ...)")
  }
  .jst_stop(
    typed, " is not a name, and a registration is stored under its data ",
    "frame's name.\n",
    "Give the data frame a name first, then register:\n",
    "  mydata <- ", typed, "\n",
    "  ", recall,
    fn = fn_name)
}

#' Internal helper: the variables shown in a reassignment line
#'
#' The text that stands for a call's variables in the durability note's two
#' lines, each of which ends in the template's own \code{...} and is never
#' wrapped (voice Rule L). A call on many variables once put every name on
#' both lines: 52 names made two lines of some 1,300 characters (the S298
#' item, with S292 site 1; Session 339). Three forms, the first that
#' applies: \code{vars =} as the call typed it, when the call gave it and
#' it fits the line; every name, when there are three or fewer and they fit;
#' otherwise nothing, so the line reads \code{d <- jdeclare_missing(d, ...)}
#' and the template's \code{...} stands for all of the call's arguments
#' (voice Rule K). A list is never shown in part: a line naming the first
#' few of fourteen variables, completed and run, would declare on those few
#' (the concern modify_form_walk.R Section 10 has recorded since S282).
#'
#' @param var_names Character; the call's resolved variable names.
#' @param vars_typed Character(1) or \code{NULL}; the \code{vars =}
#'   argument as typed, when the call used it.
#' @param fixed_chars Integer; the characters of the longer line apart from
#'   the variables.
#' @param width The message width in force.
#' @return Character(1); \code{""} when the variables are left to the
#'   template's \code{...}.
#' @keywords internal
.jst_scaffold_vars <- function(var_names, vars_typed = NULL, fixed_chars = 0L,
                               width = .jst_resolve_width()) {
  budget <- width - fixed_chars
  if (!is.null(vars_typed) && length(vars_typed) == 1L) {
    cand <- paste0("vars = ", vars_typed)
    if (nchar(cand) <= budget) return(cand)
  }
  listed <- paste(var_names, collapse = ", ")
  if (length(var_names) <= 3L && nchar(listed) <= budget) listed else ""
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
#' The block ends on a blank line of its own. So that a caller can end its
#' output on exactly ONE blank line (Session 328), the helper reports
#' whether it printed, and can put the blank line that separates it from
#' what precedes in front of itself -- only when it prints.
#'
#' @param data A data frame (or label source) whose columns may carry
#'   variable labels.
#' @param var_names Character vector of variable names to list, in order.
#' @param lead Logical. Print a blank line before the block. Default FALSE:
#'   most callers' preceding output already ends on one.
#'
#' @return Invisibly, TRUE when the block printed (the output now ends on a
#'   blank line) and FALSE when there was nothing to print.
#'
#' @keywords internal
.print_var_labels <- function(data, var_names, lead = FALSE) {
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
    if (isTRUE(lead)) cat("\n")
    cat("Variable Labels:\n")
    cat(paste(label_lines, collapse = "\n"))
    cat("\n\n")
    return(invisible(TRUE))
  }
  invisible(FALSE)
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
#' coefficient work. Every predictor is listed (Session 320, AUDIT-036): a
#' computed term such as \code{I(ScreenTime > 4)} is not a column of the
#' label source, so it shows as its bare text; until v0.9.198 it was left out
#' and the block disagreed with the VIF table beneath it. Matches the flat
#' legend's indented-lines + trailing-blank structure so co-located blocks
#' space the same way.
#'
#' @param data A data frame (or pre-conversion label source) whose columns may
#'   carry variable labels.
#' @param dv_name Character. The outcome (response) variable name.
#' @param iv_names Character vector. The predictor variable names, in order.
#' @param lead Logical. Print a blank line before the block, only when the
#'   block prints. Default FALSE. (Session 328)
#'
#' @return Invisibly, TRUE when the block printed (the output now ends on a
#'   blank line) and FALSE when there was nothing to print.
#'
#' @keywords internal
.print_model_var_labels <- function(data, dv_name, iv_names, lead = FALSE) {
  has_label <- function(v) {
    if (!v %in% names(data)) return(FALSE)
    vl <- labelled::var_label(data[[v]])
    !is.null(vl) && length(vl) > 0 && !is.na(vl[1]) && nzchar(vl[1]) &&
      !identical(as.character(vl[1]), v)
  }
  # Width for the "=" column: the widest name that actually shows a label,
  # taken across BOTH roles so the outcome and predictors align as one column.
  shown   <- c(if (length(dv_name) == 1L && dv_name %in% names(data)) dv_name,
               iv_names)
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
  if (length(iv_names) > 0L) {
    block <- c(block, "Predictors:",
               vapply(iv_names, fmt_line, character(1), USE.NAMES = FALSE))
  }
  if (length(block) > 0L) {
    if (isTRUE(lead)) cat("\n")
    cat(paste(block, collapse = "\n"))
    cat("\n\n")
    return(invisible(TRUE))
  }
  invisible(FALSE)
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
#' @param lead Logical. Print a blank line before the block, only when the
#'   block prints. Default FALSE. (Session 328)
#'
#' @return Invisibly, TRUE when the block printed (the output now ends on a
#'   blank line) and FALSE when there was nothing to print.
#'
#' @keywords internal
.print_value_labels <- function(data, var_names, lead = FALSE) {
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
    if (isTRUE(lead)) cat("\n")
    cat("Value Labels:\n")
    cat(paste(label_lines, collapse = "\n"))
    cat("\n\n")
    return(invisible(TRUE))
  }
  invisible(FALSE)
}

#' Internal helper: print variable- and value-label legends (single position)
#'
#' For single-table functions (jt, jaov, jcrosstab) and grouped jdesc, where
#' both \code{"legend"} and \code{"legend.bottom"} resolve to the same place --
#' after the table. Emits one lead-in blank line when a block prints, then
#' the variable-label block first and the value-label block second (the
#' Session 60 ordering lock). Each block supplies its own trailing blank line,
#' so co-located blocks are separated by exactly one blank line. The two blocks
#' can document different variable sets (e.g. jt's variable legend covers DV +
#' group, but only the group carries the value.id legend).
#'
#' Since Session 328 the lead-in blank line prints only when a block does (a
#' legend mode with no labelled variable printed a lone blank line), and the
#' helper reports whether anything printed, so the caller can end its output
#' on exactly one blank line: a printed block already ends on one.
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
#' @return Invisibly, TRUE when at least one block printed (the output now
#'   ends on a blank line) and FALSE when nothing printed.
#'
#' @keywords internal
.jst_print_legends <- function(data, vars_var, vars_val, vlmode, value_mode,
                               lead = TRUE) {
  leg <- c("legend", "legend.bottom")
  printed <- FALSE
  if (vlmode %in% leg) {
    printed <- .print_var_labels(data, vars_var, lead = lead)
  }
  if (value_mode %in% leg) {
    # The second block needs no lead-in when the first printed: the first
    # block's own trailing blank line separates the two.
    printed <- .print_value_labels(data, vars_val,
                                   lead = lead && !printed) || printed
  }
  invisible(printed)
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
#' @return Invisibly, TRUE when at least one block printed and FALSE when
#'   nothing printed. (Session 328)
#'
#' @keywords internal
.jst_print_legends_at <- function(data, vars_var, vars_val, vlmode, value_mode,
                                  position) {
  printed <- FALSE
  if (identical(vlmode, position)) {
    printed <- .print_var_labels(data, vars_var)
  }
  if (identical(value_mode, position)) {
    printed <- .print_value_labels(data, vars_val) || printed
  }
  invisible(printed)
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

#' Internal helper: the decimal places a variable's data carry
#'
#' Returns the number of decimal places needed to show every value of a
#' variable faithfully, capped at \code{cap} -- the precision the DATA
#' carry, as opposed to the precision of the few values a table happens to
#' print. jdesc() uses it for Min and Max (Session 328): a variable measured
#' in whole numbers shows 0 and 75, one measured to a tenth shows 4.8 and
#' 10.0, and each variable keeps its own places when several share a table.
#' Before, both columns took one precision from the minimums and maximums
#' in them, so a whole-number variable printed 0.0 and 75.0 beside another
#' variable's 4.8 and 9.7.
#'
#' The work is \code{.jst_col_dp()}'s, on the distinct values: a vector of
#' whole numbers returns 0 without formatting anything, and the scan stops
#' as soon as the cap is reached, so a full-precision variable with a
#' million distinct values costs one small batch.
#'
#' @param x A numeric vector (a variable's values; missing values ignored).
#' @param cap Integer. Maximum number of decimal places to report (the
#'   digits setting in force).
#'
#' @return Integer scalar between 0 and \code{cap}. Returns 0 for an
#'   all-missing vector.
#'
#' @keywords internal
.jst_data_dp <- function(x, cap = 7L) {
  x <- x[is.finite(x)]
  if (length(x) == 0L || cap <= 0L) return(0L)
  if (all(x == round(x))) return(0L)
  ux <- unique(x)
  dp <- 0L
  for (first in seq(1L, length(ux), by = 5000L)) {
    last <- min(first + 4999L, length(ux))
    dp   <- max(dp, .jst_col_dp(ux[first:last], cap = cap))
    if (dp >= cap) break
  }
  as.integer(dp)
}

#' Internal helper: carry passenger attributes through a column rebuild
#'
#' A haven-imported column carries attributes beyond its labels and its
#' missing-value declaration: the platform display format
#' (\code{format.spss} such as "F2.0" or "A20", \code{format.stata} such as
#' "%9.0g"), the SPSS Data Editor column width (\code{display_width}), and
#' whatever a future haven attaches. R never reads them; haven's writers
#' do, and a writer that finds none invents a default (F8.2 for a .sav
#' numeric), so a rebuild that drops them changes how the column displays
#' when the file goes back to its platform (S298 field finding 2: 52
#' declared columns read back F8.2 in place of their delivered format).
#'
#' Rebuilding through \code{haven::labelled()},
#' \code{haven::labelled_spss()}, or \code{labelled::val_labels<-}
#' (which rebuilds internally) keeps only what the constructor is told.
#' This helper copies onto \code{to} every attribute of \code{from} that
#' the rebuild does not own -- everything except the structural set
#' (\code{class}, \code{levels}, \code{names}, \code{dim},
#' \code{dimnames}) and the owned set (\code{label}, \code{labels},
#' \code{na_values}, \code{na_range}) -- and fills only attributes
#' \code{to} lacks, so it restores what was dropped and never overrides
#' what the rebuild set. A plain vector with no attributes passes
#' through unchanged.
#'
#' Called at the exit of every column rebuild that keeps the column's
#' storage kind: jrelabel(), jrecode(), the three jdeclare_missing()
#' branch builders, jconvert()'s write-backs, and jsave's .dta
#' pre-write. jencode() does NOT call it by design: its source is text and
#' its result numeric, so the source's "A<n>" format would be wrong on
#' the result (S299).
#'
#' @param from The column before the rebuild.
#' @param to The rebuilt column.
#'
#' @return \code{to}, with the passenger attributes of \code{from} added.
#'
#' @keywords internal
.jst_carry_col_attrs <- function(from, to) {
  keep_out <- c("class", "levels", "names", "dim", "dimnames",
                "label", "labels", "na_values", "na_range")
  a <- attributes(from)
  if (is.null(a)) return(to)
  a <- a[setdiff(names(a), keep_out)]
  for (nm in names(a)) {
    if (is.null(attr(to, nm, exact = TRUE))) attr(to, nm) <- a[[nm]]
  }
  to
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
#'   "d", "ln", "bc", or "bd"), one per displayed column. If NULL,
#'   auto-detects: numeric = right, character/other = left -- the form a
#'   listing of data rows wants, and jcomplete()'s preview is the one caller
#'   that passes none. Every statistics table names its columns, because
#'   only the caller knows that a text column holds p-values or labels (a
#'   default keyed to the column's type would leave every p header flush
#'   left; Session 328). Code "d" is a decimal-tab: data
#'   cells are right-justified (so a uniform decimal-places column aligns on
#'   the decimal point) while the header stays centered over the column.
#'   Code "ln" is left, no-trim (a caller-supplied leading space survives).
#'   Code "bc" is block-centered: each value is right-justified in a block
#'   the width of the column's widest value, and that block is centered
#'   under the header, so counts align on their ones digit down the column
#'   while the column reads centered rather than right-heavy (the Case
#'   Processing bottom table's Session 52 rule, available to any table since
#'   Session 313). The header is centered over the column, as for "d".
#'   Code "bd" is block-centered on the decimal point (Session 328): each
#'   cell is split where its whole-number part ends, the whole-number parts
#'   are right-justified and what follows them (a decimal fraction, a
#'   percent sign, a significance marker) is left-justified, so the cells of
#'   a column line up on the decimal point whatever each one carries -- a
#'   count over an expected count over a percentage in jcrosstab's cells, a
#'   whole number over a one-decimal value in jdesc's Min and Max. The two
#'   widths together are the block, centered under the header as a "bc"
#'   block is. A cell that does not start with a number sits with the
#'   whole-number parts.
#'   Where a header or a block cannot be centered exactly, the odd space
#'   goes on the LEFT, so the text sits one place right of center: a
#'   one-digit df under "df" reads as right-justified, where a number
#'   conventionally sits. One rule for every table, the Case Processing
#'   block included (Session 328); the odd space went on the right through
#'   Session 327.
#' @param caption Optional title string printed above the table.
#' @param indent Number of leading spaces for each data row. Default 0,
#'   so data rows sit flush at column 1, aligned with the caption, header,
#'   and separator (which use \code{header.indent}). Callers that want a
#'   nested/indented sub-table pass a positive value (e.g. \code{indent = 4}).
#' @param header.indent Number of leading spaces for the caption,
#'   header row, and separator row. Defaults to 0. With the default
#'   \code{indent}, header and data share the same left edge; raise one
#'   relative to the other only for special layouts.
#' @param trim Logical. When TRUE (the default since Session 328),
#'   trailing spaces are removed from the header row and every data row
#'   before printing. A centered header or a left-aligned or block-centered
#'   cell in the LAST column is padded to the column's width, so without
#'   the trim those lines end in spaces -- invisible on screen but carried
#'   into anything copied or captured. It was opt-in from Session 316
#'   (jdesc's two tables) through Session 327 (the statistics tables); no
#'   table wants the padding, so no caller passes FALSE.
#' @param digits Optional named vector that fixes the decimal places of
#'   numeric columns, keyed by the data frame's own column names (not the
#'   display headers), e.g. \code{c(Mean = 3, SD = 3)}. A named column
#'   prints every value to exactly that many places, trailing zeros kept
#'   (0.100, 16.000), through \code{.jst_make_fmt()}, so a value that rounds
#'   to zero from below prints unsigned and NA stays a blank cell. A numeric
#'   column the vector does not name keeps the detected decimals described
#'   in the body, so a caller that passes nothing prints exactly as before;
#'   an NA entry also keeps the detection, and an entry naming a non-numeric
#'   column is ignored. A name that matches no column is an error, so a
#'   misspelled name cannot fall back to the detection unnoticed. NULL (the
#'   default) fixes no column. Added Session 326: a column's decimal places
#'   come from what it holds -- a statistic at the digits setting, a fixed
#'   convention at its own -- never from the values that happen to be in it.
#' @param gap The number of spaces between columns: one whole number, used
#'   as given (the default, 2, is the gap every table has had), or several
#'   in order of preference. Given several, the table takes the first gap
#'   at which its full width -- the indent, the columns and the gaps
#'   between them -- still fits the message width (\code{joptions()}'s
#'   \code{message.width}, 76 by default), and the last one when none
#'   fits. jcrosstab's crosstab passes \code{c(4, 2)}: its cell columns
#'   are narrow and crowd at two spaces, so a table with room takes four
#'   and a wide one keeps two (Session 329, Jeff). The width is the
#'   table's own; a caption longer than the table does not count. The
#'   message width is the ceiling because it is the one width the package
#'   already keeps, and it gives the same table on every screen where the
#'   console's width changes with the pane.
#'
#' @keywords internal
.jst_print_table <- function(df, col.names = NULL, row.names = TRUE,
                             align = NULL, caption = NULL, indent = 0,
                             header.indent = 0, trim = TRUE, digits = NULL,
                             gap = 2L) {

  headers <- if (!is.null(col.names)) col.names else names(df)

  # Fixed decimal places by column name (Session 326). Validated first: a
  # name that matches no column is a caller's slip, and quietly falling back
  # to the detection below would hide exactly the trailing-zero defect the
  # argument exists to fix.
  if (!is.null(digits)) {
    dn <- names(digits)
    if (is.null(dn) || anyNA(dn) || any(!nzchar(dn)) ||
        any(!dn %in% names(df))) {
      stop(".jst_print_table(): every digits entry must name a column of ",
           "df; not found: ", paste(setdiff(dn, names(df)), collapse = ", "),
           call. = FALSE)
    }
  }

  # Build display matrix
  display_cols <- lapply(seq_len(ncol(df)), function(j) {
    col <- df[[j]]
    if (is.numeric(col)) {
      # A column the caller fixed (Session 326): exactly that many places,
      # trailing zeros kept -- 0.100, not 0.1; 682.770 beside 682.770, not
      # 682.77 -- a negative zero unsigned, NA blank.
      fixed <- if (!is.null(digits) && names(df)[j] %in% names(digits)) {
        digits[[names(df)[j]]]
      } else {
        NA
      }
      if (!is.na(fixed)) return(.jst_make_fmt(fixed)(col))
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

  # Block widths for "bc" (block-centered) columns: the widest trimmed value
  # in the column, header excluded. Zero for an empty column. (Session 313)
  block_widths <- vapply(seq_len(n_cols), function(j) {
    max(nchar(trimws(display[, j])), 0L, na.rm = TRUE)
  }, integer(1))

  # Decimal-aligned blocks ("bd", Session 328). Each cell is split where its
  # whole-number part ends: the whole-number parts are right-justified and
  # the tails (a decimal fraction, a percent sign, a marker) left-justified,
  # so every cell of the column lines up on the decimal point -- 13 over
  # 12.6 over 26.5% in a crosstab cell, 0 over 4.8 in jdesc's Min. The two
  # widths together are the block. A cell that does not start with a number
  # ("--") is all head, so it sits with the whole-number parts; a blank
  # cell stays blank. The cells are built here, whole, and reach fmt_cell()
  # already at block width.
  bd_cells <- vector("list", n_cols)
  for (j in which(align == "bd")) {
    tx     <- trimws(display[, j])
    is_num <- grepl("^[-+]?[0-9]*[.]?[0-9]", tx)
    head   <- ifelse(is_num, sub("^([-+]?[0-9]*)(.*)$", "\\1", tx), tx)
    tail   <- ifelse(is_num, sub("^([-+]?[0-9]*)(.*)$", "\\2", tx), "")
    head_w <- max(nchar(head), 0L)
    tail_w <- max(nchar(tail), 0L)
    bd_cells[[j]]   <- paste0(strrep(" ", head_w - nchar(head)), head,
                              tail, strrep(" ", tail_w - nchar(tail)))
    block_widths[j] <- head_w + tail_w
    col_widths[j]   <- max(nchar(headers[j]), block_widths[j])
  }

  # The column gap (Session 329). One number is used as given. Several are
  # tried in order: the first at which the whole table fits the message
  # width, else the last. Measured after the column widths are settled, so
  # a "bd" column counts at the width of its block.
  gap_n <- suppressWarnings(as.integer(gap))
  if (length(gap_n) < 1L || anyNA(gap_n) || any(gap_n < 1L)) {
    stop(".jst_print_table(): gap must be one or more whole numbers of ",
         "spaces, each at least 1", call. = FALSE)
  }
  if (length(gap_n) > 1L) {
    room  <- .jst_resolve_width() - max(indent, header.indent) -
             sum(col_widths)
    fits  <- gap_n * (n_cols - 1L) <= room
    gap_n <- if (any(fits)) gap_n[which(fits)[1L]] else gap_n[length(gap_n)]
  }
  gap    <- strrep(" ", gap_n)
  prefix <- paste(rep(" ", indent), collapse = "")
  header_prefix <- paste(rep(" ", header.indent), collapse = "")

  fmt_cell <- function(text, width, alignment, block = width) {
    # "ln" (left, no-trim): left-justify but preserve the caller's leading
    # whitespace (used by jcorr to reserve a sign slot so r decimals line up
    # under a leading minus). Must NOT trim, unlike every other alignment.
    if (identical(alignment, "ln")) {
      return(formatC(text, width = -width, flag = "-"))
    }
    # "bd" (block-centered on the decimal point): the cell arrives built to
    # the block's width (bd_cells above) and must NOT be trimmed -- its
    # leading spaces are the alignment. Center the block as "bc" does.
    if (identical(alignment, "bd")) {
      extra <- max(0L, width - nchar(text))
      left  <- extra - extra %/% 2
      return(paste0(strrep(" ", left), text, strrep(" ", extra - left)))
    }
    text <- trimws(text)
    # THE LEAN (Session 328, Jeff): where the spare space is odd, the larger
    # half goes on the LEFT, so a header or a block sits one place right of
    # center -- a one-digit df under "df" reads as right-justified. The same
    # rule in "c", "bc", "bd" and the Case Processing block's ctr_count();
    # through Session 327 the larger half went on the right.
    switch(alignment,
           "r" = formatC(text, width = width, flag = " "),
           "c" = {
             pad   <- max(0L, width - nchar(text))
             left  <- pad - pad %/% 2
             right <- pad - left
             paste0(strrep(" ", left), text, strrep(" ", right))
           },
           # "bc" (block-centered): right-justify within the value block,
           # then center that block within the column -- the same two steps
           # as ctr_count() in .jst_print_case_processing (Session 52), so
           # a one-digit and a two-digit count align on their ones digit
           # while the block sits under the middle of the header. Applies
           # to DATA cells only; the header resolves to "c" below.
           "bc" = {
             s     <- formatC(text, width = block, flag = " ")
             extra <- max(0L, width - block)
             left  <- extra - extra %/% 2
             paste0(strrep(" ", left), s, strrep(" ", extra - left))
           },
           formatC(text, width = -width, flag = "-")
    )
  }

  if (!is.null(caption)) {
    cat(header_prefix, caption, "\n", sep = "")
  }

  # Decimal-tab columns ("d"): right-justify data so a uniform-dp column
  # aligns on the decimal point, while the header stays centered over
  # the column. Resolve "d" here; fmt_cell never sees "d". Block-centered
  # columns ("bc") center their header the same way (Session 313; a header
  # narrower than its values, "N" over 103, sits over the middle digit);
  # their data cells reach fmt_cell as "bc" with the column's block width.
  # Decimal-aligned columns ("bd", Session 328) center their header too.
  header_align <- ifelse(align == "d", "c",
                  ifelse(align == "ln", "l",
                  ifelse(align %in% c("bc", "bd"), "c", align)))
  data_align   <- ifelse(align == "d", "r", align)

  # emit(): one table line, its trailing spaces removed when trim = TRUE
  # (Session 316; the default since Session 328). The separator row never
  # ends in a space, so it is printed as before.
  emit <- function(line) {
    if (isTRUE(trim)) line <- sub("[ ]+$", "", line)
    cat(line, "\n", sep = "")
  }

  # Header
  header_cells <- vapply(seq_len(n_cols), function(j) {
    fmt_cell(headers[j], col_widths[j], header_align[j])
  }, character(1))
  emit(paste0(header_prefix, paste(header_cells, collapse = gap)))

  # Separator
  sep_cells <- vapply(col_widths, function(w) {
    paste(rep("-", w), collapse = "")
  }, character(1))
  cat(header_prefix, paste(sep_cells, collapse = gap), "\n", sep = "")

  # Data rows
  for (i in seq_len(n_rows)) {
    row_cells <- vapply(seq_len(n_cols), function(j) {
      cell <- if (identical(data_align[j], "bd")) bd_cells[[j]][i]
              else display[i, j]
      fmt_cell(cell, col_widths[j], data_align[j], block_widths[j])
    }, character(1))
    emit(paste0(prefix, paste(row_cells, collapse = gap)))
  }
}


# -----------------------------------------------------------------------------
# Console width: the message.width foundation
#
# Three helpers rather than one, so that a future table.width slot is an
# ADDITION here and not a rewrite:
#
#   .jst_console_width()  the raw console width, UNCLAMPED. Tables will want
#                         the true value even below the message floor -- a
#                         35-column console is exactly when jcorr should
#                         consider its stacked layout -- so clamping belongs
#                         to the consumer, not to the reading.
#   .jst_width_tokens     the token -> number map, ONE shared constant. NOT
#                         per-consumer: a token names a width, and a future
#                         joptions(width = "narrow") setting two slots at
#                         once is incoherent if "narrow" means two different
#                         numbers in two places.
#   .jst_resolve_width()  the precedence resolver, with the BAND as an
#                         argument so each consumer passes its own bounds.
#
# SCOPE IS PROSE. Nothing in the package reads getOption("width") for table
# rendering, and the slot is named message.width for exactly that reason: a
# broader name would promise a reflow that does not happen. Prose can reflow
# without losing information; a table cannot. (Session 253.)
# -----------------------------------------------------------------------------

#' Internal helper: the current console width, unclamped
#'
#' Returns \code{getOption("width")} as an integer, with no clamping to any
#' consumer band. R keeps this value current with the console pane, so it is
#' read at the point of use rather than cached: a message renders to the pane
#' it prints into. Falls back to R's own documented default of 80 when the
#' option is missing or malformed -- a validity fallback, not a clamp.
#'
#' @return Integer: the console width in columns.
#' @keywords internal
.jst_console_width <- function() {
  w <- getOption("width")
  if (is.null(w) || length(w) != 1L || !is.numeric(w) || is.na(w)) return(80L)
  as.integer(w)
}


# -- Internal: the shared width tokens ----------------------------------------
#
# The token to column-count map, shared by every width consumer. "narrow" is
# the floor of the online-teaching range, "medium" is Rule U's established
# value (safe under an 80-column terminal and a Quarto render), "wide" is a
# comfortable modern pane.
#
# Plain comments rather than roxygen, matching .jst_options_related: roxygen
# on a non-function object generates a \docType{data} Rd, which this package
# does not carry for internal constants.

#' @keywords internal
.jst_width_tokens <- c(narrow = 50L, medium = 76L, wide = 90L)


#' Internal helper: resolve a width setting to a number of columns
#'
#' Precedence follows \code{.jst_resolve_corr_layout()}: an explicit per-call
#' value wins, else the supplied joptions slot value, else a last-ditch
#' fallback. Five forms are accepted -- \code{"auto"} (the live console width
#' less one column), the three tokens in \code{.jst_width_tokens}, or a whole
#' number within the band.
#'
#' TWO BEHAVIORS BY PROVENANCE, deliberately. A NUMBER the user typed is
#' honored or REFUSED, because a silent clamp reports success and does
#' something else. A WORD -- a token, or \code{"auto"} -- is FITTED to the
#' band, because refusing \code{"auto"} would punish a user for resizing a
#' pane they never typed a number into.
#'
#' Like \code{corr.layout} and \code{missing.detail}, these tokens name no
#' statistical platform, so they are matched EXACTLY and are outside the
#' platform-spec case-insensitivity rule.
#'
#' Validation is strict on \code{per_call} ONLY. An invalid slot falls back
#' silently, matching \code{.jst_resolve_corr_layout()} -- and here that is
#' required rather than merely consistent: this resolver is read by the
#' message emitters, so a slot corrupted by a direct \code{options()} write
#' must not raise an error from inside the error path.
#'
#' @param per_call A per-call width value, or NULL to defer to the slot.
#' @param slot The joptions slot value. Defaults to the \code{message.width}
#'   slot, the only consumer in this version; a future \code{table.width}
#'   passes its own.
#' @param min,max The consumer's band, inclusive.
#' @param arg,fn Names used in the per-call validation error.
#'
#' @return Integer: the resolved width in columns.
#' @keywords internal
.jst_resolve_width <- function(per_call = NULL,
                               slot = getOption(
                                 ".jst_options_message_width",
                                 .jst_options_defaults$message.width),
                               min = 40L, max = 120L,
                               arg = "message.width", fn = NULL) {
  # Clamp written with comparisons rather than base min()/max(): the band
  # parameters are NAMED min and max to match the agreed signature, and
  # calling the base functions in their shadow, while legal, reads as a bug.
  fit <- function(w) {
    w <- as.integer(w)
    if (w < min) w <- as.integer(min)
    if (w > max) w <- as.integer(max)
    w
  }

  # Interpret one accepted form: the resolved integer, or NA carrying a
  # "why" the strict path turns into an error.
  interpret <- function(x) {
    if (is.character(x) && length(x) == 1L && !is.na(x)) {
      if (identical(x, "auto")) return(fit(.jst_console_width() - 1L))
      if (x %in% names(.jst_width_tokens)) return(fit(.jst_width_tokens[[x]]))
      return(structure(NA_integer_, why = "form"))
    }
    if (is.numeric(x) && length(x) == 1L && !is.na(x) &&
        x == as.integer(x)) {
      x <- as.integer(x)
      if (x < min || x > max) return(structure(NA_integer_, why = "band"))
      return(x)
    }
    structure(NA_integer_, why = "form")
  }

  if (!is.null(per_call)) {
    got <- interpret(per_call)
    if (!is.na(got)) return(got)
    if (identical(attr(got, "why"), "band")) {
      .jst_stop_arg(fn, arg,
                    paste0("between ", min, " and ", max,
                           ". Out-of-range widths are refused rather than ",
                           "quietly adjusted."))
    }
    .jst_stop_arg(fn, arg,
                  paste0("\"auto\", ",
                         paste0("\"", names(.jst_width_tokens), "\"",
                                collapse = ", "),
                         ", or a whole number between ", min, " and ",
                         max, "."))
  }

  got <- interpret(slot)
  if (!is.na(got)) return(got)
  # Last-ditch only: the slot has been corrupted by a direct options() write.
  # Not any consumer's default -- a consumer's default reaches this function
  # as `slot`, via getOption(name, .jst_options_defaults$name).
  fit(.jst_width_tokens[["medium"]])
}


#' Internal: width-aware wrapping for runtime-message prose
#'
#' Wraps ONE prose sentence (or short paragraph) at word boundaries to a
#' target width, replacing the former practice of hardcoded mid-sentence
#' line breaks sized against one content width (S230; the S229 walk showed
#' those breaks failing in both directions as variable content changed).
#' Three refinements over a bare strwrap():
#'   - ATOMIC TOKENS: function calls (jconvert(...), joptions(...)) and
#'     dotted argument references (preserve.declarations = FALSE) are never split
#'     across lines -- a break inside a runnable token is worse than a
#'     long line. Protection is limited to tokens it would be WRONG to
#'     break, which excludes code slates -- the parenthesized comma
#'     lists of declared codes built at runtime, which can break as
#'     "(-1, -2," / "-3)". Considered and rejected in Session 259. A
#'     slate is ugly to break, not wrong: breaks fall at spaces, so an
#'     open paren is never orphaned and a code is never split. Making
#'     it an atom makes it unbreakable, so a long slate -- 17 declared
#'     codes is a real administrative-data case -- lands on its own
#'     line past the width, converting a cosmetic break into the
#'     over-width line this helper exists to prevent. Capping the atom
#'     to slates that fit the width avoids that, but then it fires only
#'     where the render is mildest. See the Session 259 changelog.
#'   - ORPHAN PULL-BACK: words are pulled down from the line above while
#'     the last line reads as an accident -- either shorter than min_tail
#'     outright, or shorter than min_last AND a single word. Session 257
#'     replaced a bare length test with this two-part condition. The bare
#'     test scaled badly as the resolved width narrowed: at width 50 a
#'     fixed 20 is 40 percent of the line, and it emptied the line above
#'     down to the single word "codes". Measured over 392 message bodies
#'     at four widths, the new condition halves the count of under-filled
#'     lines at every width and leaves the count of one-word tails
#'     unchanged, since it is strictly weaker than the old test on a
#'     single word and so cannot create one. The alternative considered
#'     and rejected was making min_last a proportion of width: it bought
#'     the same fill by manufacturing one-word tails (3 to 12 at width
#'     50), which is the defect the pull-back exists to prevent.
#'   - PREFIX RESERVE: for strings surfaced through .jst_stop(), the
#'     emitter prepends a `fn(): ` prefix AFTER the builder returns;
#'     `reserve` narrows the first line by that many characters so the
#'     rendered first line still lands within width. (Since Session 256
#'     the emitters also count R's own inline chrome in reserve; see
#'     .jst_stop() and .jst_warn() for the per-route budgets.)
#'
#' Scope: prose only. Runnable command lines follow Rule L (their own
#' indented line) and are never passed through this helper. Called ONLY
#' from the wrapper layer -- .jst_wrap_message() and .jst_wrap_indent()
#' -- never from a message builder: the emitters wrap every message at
#' the real prefix reserve and treat existing breaks as hard, so a
#' builder-side wrap at a guessed reserve produces two sets of break
#' points (the S287 jencode double wrap). receive_package()'s structural
#' gate enforces this as a call-site whitelist (S292). A builder that
#' needs an indent for its own layout may still call .jst_wrap_indent().
#'
#' @param text Character scalar: one sentence/paragraph, no embedded newlines.
#' @param width Target line width. Defaults to the resolved
#'   \code{message.width} setting (see \code{\link{joptions}}); the shipped
#'   default is "auto", which resolves to the live console width less one.
#' @param min_last Length below which a SINGLE-WORD last line is pulled
#'   back. A last line at or above this length, or holding more than one
#'   word, is left alone by this test.
#' @param min_tail Absolute floor: a last line shorter than this is pulled
#'   back whatever its word count. Stops the word test stranding a short
#'   multi-word tail such as "to show." (Session 257).
#' @param reserve Characters the emitter will prepend to line 1.
#' @param tol Rule 2 tolerance: when a sentence boundary sits within this
#'   many characters of the fill point, the break relocates to the boundary
#'   so the sentence stays whole. 12 is the S252-measured value (the
#'   smallest catching the jsubset case, the largest costing no extra
#'   lines); 0 disables the rule and restores plain word-fill exactly.
#' @return Character scalar with newline characters at the break points.
#' @keywords internal
.jst_wrap_prose <- function(text, width = .jst_resolve_width(),
                            min_last = 20L, reserve = 0L, tol = 12L,
                            min_tail = 10L) {
  if (!nzchar(text)) return(text)
  # Protect atomic tokens: swap internal spaces for \x01 so they travel
  # as single words, restored after line assembly.
  protected <- text
  atom_re <- paste0(
    "[A-Za-z_.][A-Za-z0-9_.]*\\([^()]*\\)",              # calls
    "|[A-Za-z][A-Za-z0-9._]* = [^ ]+",                   # arg = value (S254)
    "|\"[^\"\n]{1,60}\""                                # quoted phrases (S238)
  )
  m <- gregexpr(atom_re, protected)[[1]]
  if (m[1] != -1L) {
    starts <- as.integer(m)
    lens   <- attr(m, "match.length")
    for (i in rev(seq_along(starts))) {
      seg <- substr(protected, starts[i], starts[i] + lens[i] - 1L)
      seg <- gsub(" ", "\x01", seg, fixed = TRUE)
      protected <- paste0(substr(protected, 1L, starts[i] - 1L), seg,
                          substring(protected, starts[i] + lens[i]))
    }
  }
  words <- strsplit(protected, " ", fixed = TRUE)[[1]]
  words <- words[nzchar(words)]
  lines <- character(0)
  cur   <- ""
  avail <- width - reserve
  # Rule 2 (S252 design, built S254): a word ends a sentence if it closes
  # with terminal punctuation, is not a letter-dot abbreviation (e.g., i.e.),
  # and the next word opens a sentence. Conservative by construction: the
  # dotted tokens preserve.declarations, .a, .sav, 0.9.141 end in letters or digits
  # without terminal punctuation, so none can fire.
  ends_sentence <- function(a, b) {
    grepl("[.!?]$", a) && !grepl("^([A-Za-z]\\.)+$", a) && grepl("^[A-Z0-9\"]", b)
  }
  for (w in words) {
    cand <- if (nzchar(cur)) paste(cur, w) else w
    if (nchar(cand) <= avail) {
      cur <- cand
    } else {
      # Rule 2: sentence-aware break. If a sentence boundary sits within
      # `tol` characters of the fill point, break there so the sentence
      # stays whole; the words after the boundary open the next line. Only
      # taken when the relocated tail still fits the width, so the rule can
      # relocate a break but never widen a line. At tol = 0 this block is
      # inert and the loop is byte-identical to plain word-fill.
      moved <- FALSE
      if (tol > 0L) {
        cw <- strsplit(cur, " ", fixed = TRUE)[[1]]
        k  <- length(cw)
        if (k > 1L) {
          tail_len <- 0L
          i <- k - 1L
          while (i >= 1L) {
            tail_len <- tail_len + nchar(cw[i + 1L]) + 1L
            if (tail_len > tol) break
            if (ends_sentence(cw[i], cw[i + 1L]) &&
                tail_len + nchar(w) <= width) {
              lines <- c(lines, paste(cw[seq_len(i)], collapse = " "))
              cur   <- paste(c(cw[seq(i + 1L, k)], w), collapse = " ")
              avail <- width
              moved <- TRUE
              break
            }
            i <- i - 1L
          }
        }
      }
      if (!moved) {
        # Do not push an empty first line when the very first word is itself
        # wider than the available space. An over-long token -- a path, a long
        # variable name, a long c(...) atom -- belongs on its own line, not
        # under a blank one. Latent at width 76 (nothing in the source is that
        # long); visible as soon as the resolved width narrows. (S254)
        if (nzchar(cur)) lines <- c(lines, cur)
        cur   <- w
        avail <- width   # reserve applies to the first line only
      }
    }
  }
  lines <- c(lines, cur)
  # Orphan pull-back: iterate until the last line stops reading as an
  # accident, or a move would overflow the width. Rule 2's second half
  # (S254, demonstrated in the S252 Appendix A trials): the pull-back never
  # drags words across a sentence boundary -- a last line that is itself a
  # complete sentence stays short rather than stealing the tail of the
  # sentence above it. Inert at tol = 0, like the break relocation.
  #
  # The tail test is two-part (S257). Word counting is safe here because
  # atoms still carry \x01 in place of their internal spaces at this point
  # -- a protected call such as jcomplete(var1, var2, ...) correctly counts
  # as the single token it renders as. The restore happens after the loop.
  short_tail <- function(s) {
    if (nchar(s) < min_tail) return(TRUE)
    nchar(s) < min_last &&
      length(strsplit(s, " ", fixed = TRUE)[[1]]) < 2L
  }
  while (length(lines) > 1L && short_tail(lines[length(lines)])) {
    prev <- strsplit(lines[length(lines) - 1L], " ", fixed = TRUE)[[1]]
    if (length(prev) < 2L) break
    first_last <- strsplit(lines[length(lines)], " ", fixed = TRUE)[[1]][1L]
    if (tol > 0L && ends_sentence(prev[length(prev)], first_last)) break
    moved <- prev[length(prev)]
    cand  <- paste(moved, lines[length(lines)])
    if (nchar(cand) > width) break
    lines[length(lines) - 1L] <- paste(prev[-length(prev)], collapse = " ")
    lines[length(lines)]      <- cand
  }
  gsub("\x01", " ", paste(lines, collapse = "\n"), fixed = TRUE)
}


#' Internal helper: wrap message prose at a fixed left indent
#'
#' Companion to \code{.jst_wrap_prose()} for indented explanatory text
#' inside a multi-line message layout -- the consequence lines under a
#' choose-first gate's menu options (Rule V), where every line of the
#' wrapped text sits at the same indent. Delegates the wrapping (atom
#' protection, orphan pull-back) to \code{.jst_wrap_prose()} at a width
#' reduced by the indent, then prefixes every resulting line with the
#' indent spaces. (Session 244, the Decision 11 gate build.)
#'
#' @param text Character scalar: one sentence/paragraph, no embedded
#'   newlines.
#' @param indent Number of spaces every line is indented by.
#' @param width Target total line width including the indent. Defaults to
#'   the resolved \code{message.width} setting (see \code{\link{joptions}}).
#' @return Character scalar; every line starts with \code{indent} spaces.
#' @keywords internal
.jst_wrap_indent <- function(text, indent, width = .jst_resolve_width()) {
  pad  <- strrep(" ", indent)
  body <- .jst_wrap_prose(text, width = width - indent)
  paste0(pad, gsub("\n", paste0("\n", pad), body, fixed = TRUE))
}


# -----------------------------------------------------------------------------
# .jst_fmt_n()
#
# House rendering for a COUNT in runtime-message prose: comma-grouped at a
# thousand and above ("1,540 cells"). The package-wide convention, locked
# S238 after the field corpus made four-figure counts routine.
#
# SCOPE -- counts in prose only. A number that is a DATA VALUE or part of a
# RUNNABLE line is never grouped: "Refused=-99", codes = c(-99999), and any
# prefilled call keep their bare digits, because a comma inside a runnable
# token would break the line the user is invited to paste. Table cells are
# also out of scope; their own column logic governs alignment.
#
# Adoption follows Rule U's pattern -- applied here at jencode's whole
# surface, and elsewhere ON TOUCH rather than by sweep. The three sites
# that already grouped by hand (jload / jsave / jcopy case counts) are
# conformant as written and are converted when next touched.
# -----------------------------------------------------------------------------

#' Internal helper: render a count for runtime-message prose
#'
#' Returns the count comma-grouped at a thousand and above. Used for
#' counts in message prose (cells, cases, words, variables), never for
#' data values or for numbers inside a runnable command line.
#'
#' @param n Numeric scalar (or vector). The count.
#'
#' @return Character vector of the same length.
#'
#' @keywords internal
.jst_fmt_n <- function(n) {
  formatC(n, format = "d", big.mark = ",")
}


#' Internal helper: pick the singular or the plural form for a count
#'
#' A runtime message that states a count agrees with it in number (voice
#' Rule O) where it used to hedge with a shortcut -- "1 category(ies)",
#' "unused input(s)" (Session 338; the S287 item). Returns the word alone,
#' so the caller places the count:
#' \code{paste(n, .jst_plural(n, "category", "categories"))}. Zero takes
#' the plural, as in "0 categories". Either form may be a phrase, which is
#' how a verb is made to agree as well:
#' \code{.jst_plural(n, "This predictor has", "These predictors have")}.
#'
#' One site keeps its shortcut on purpose: the map parser's
#' "Invalid old value(s)", which quotes the whole left-hand side of a rule
#' and so has no count to agree with.
#'
#' @param n The count; a single number.
#' @param singular Character(1). The form for a count of exactly one.
#' @param plural Character(1). The form for every other count; by default
#'   the singular followed by "s".
#' @return Character(1).
#' @keywords internal
.jst_plural <- function(n, singular, plural = paste0(singular, "s")) {
  if (length(n) == 1L && !is.na(n) && n == 1) singular else plural
}


#' Internal helper: classify one physical line of a runtime message
#'
#' The three-category classifier behind \code{.jst_wrap_message()}. Replaces
#' the former two-category \code{.jst_wrap_lines()}, whose "any indented line
#' passes" rule let indented PROSE through unwrapped -- the jai status panel
#' rendered such lines at 97 and 81 characters.
#'
#' \describe{
#'   \item{pass}{Byte-identical. Blank lines, anything already fitting, Rule L
#'     runnable command lines, Rule V menu options, and column-aligned layout.}
#'   \item{prose}{Wrapped by \code{.jst_wrap_prose()} at the full width.}
#'   \item{indent}{Wrapped by \code{.jst_wrap_indent()} at its own indent, so
#'     every continuation line keeps the indent it started with.}
#' }
#'
#' The fits test is protective rather than cosmetic: \code{.jst_wrap_prose()}
#' rejoins on single spaces, so a column-aligned line that already fits must
#' never reach it.
#'
#' Derived from, and verified against, the Session 252 dry-run corpus: of the
#' over-width lines in the 282 messages that change under this wrapper alone,
#' all 305 unindented ones wrap and none pass, which is why an unindented line
#' is prose without further tests.
#'
#' @param line Character scalar: one physical line, no newlines.
#' @param width The width in force for this line (the caller subtracts any
#'   first-line reserve before calling).
#'
#' @return One of "pass", "prose", or "indent".
#' @keywords internal
.jst_seg_category <- function(line, width = 76L) {
  if (!nzchar(trimws(line))) return("pass")
  if (nchar(line) <= width) return("pass")

  indent <- nchar(line) - nchar(sub("^ +", "", line))
  if (indent == 0L) return("prose")

  body <- substring(line, indent + 1L)

  # Runnable: the line STARTS with a call or an assignment. "Starts with" is
  # load-bearing -- both indented prose lines in the corpus CONTAIN a call
  # (jai("project")), so a contains-a-call test would misclassify them.
  #
  # The character classes below carry no backslashes on purpose. Inside a
  # POSIX bracket expression a backslash is literal and "]" closes the class
  # early; that is exactly the defect that split runnable lines mid-command
  # in the S252 prototype, and it fails silently.
  if (grepl("^[A-Za-z._][A-Za-z0-9._:]*\\(", body)) return("pass")
  if (grepl("^[^ ]+ *<- ", body)) return("pass")

  # A filesystem path displayed on its own line -- jai() emits one after
  # "in:", and jsave/jload echo targets the same way. Word-filling a path
  # makes it un-copyable, and a Windows path containing spaces (C:/Users/Jane
  # Smith/My Project/data.sav) is exactly what a word-fill would break.
  # Tested with substr() rather than a bracket expression, for the backslash
  # reason noted above. (S254)
  c1 <- substr(body, 1L, 1L)
  if (c1 == "/" || c1 == "~") return("pass")
  if (substr(body, 1L, 2L) == "./" || substr(body, 1L, 3L) == "../")
    return("pass")
  if (substr(body, 1L, 2L) == "\\\\") return("pass")
  if (grepl("^[A-Za-z]:", body) &&
      substr(body, 3L, 3L) %in% c("/", "\\")) return("pass")

  # An interior column gap means table layout or a trailing comment column,
  # where respacing would destroy the alignment.
  if (grepl("  ", body)) return("pass")

  "indent"
}


#' Internal helper: width-wrap a whole multi-line runtime message
#'
#' Applies \code{.jst_seg_category()} line by line and wraps each line the way
#' its category requires. Idempotent: wrapping twice equals wrapping once.
#'
#' Called by the emitters rather than at the builder site, so that a message
#' whose prose was never wrapped by hand still lands within the width, and so
#' that the first-line \code{reserve} can be the REAL prefix length -- the
#' emitter knows it, a builder can only guess.
#'
#' @param text Character scalar, possibly containing newlines.
#' @param width Target line width. Defaults to the resolved
#'   \code{message.width} setting (see \code{\link{joptions}}).
#' @param reserve Integer. Characters the emitter will prepend to line 1.
#'
#' @return Character scalar.
#' @keywords internal
.jst_wrap_message <- function(text, width = .jst_resolve_width(),
                              reserve = 0L) {
  lines <- strsplit(text, "\n", fixed = TRUE)[[1]]
  if (length(lines) == 0L) return(text)
  out <- character(length(lines))
  for (i in seq_along(lines)) {
    ln  <- lines[i]
    res <- if (i == 1L) reserve else 0L
    switch(.jst_seg_category(ln, width = width - res),
      pass   = { out[i] <- ln },
      prose  = { out[i] <- .jst_wrap_prose(ln, width = width, reserve = res) },
      indent = {
        ind    <- nchar(ln) - nchar(sub("^ +", "", ln))
        out[i] <- .jst_wrap_indent(sub("^ +", "", ln), indent = ind,
                                   width = width)
      })
  }
  paste(out, collapse = "\n")
}
