#<<<FILE: plot.R>>>


# =============================================================================
#  PLOTTING
# =============================================================================

# -- jplot ---------------------------------------------------------------------

#' Visualize jst_* result objects or plot variables directly from a data frame
#'
#' Unified plotting function. Can be called in three ways:
#'
#' \strong{Result-object form:} Pass a result object returned by one of the
#' package's analysis functions. Produces appropriate plots for each class of
#' result (see valid plot names below).
#'
#' \strong{Formula form} (for plots that distinguish an outcome from a
#' predictor): Pass a
#' formula as the first argument, followed optionally by a data frame, given
#' either positionally or as \code{data = }:
#' \code{jplot(WellbeingScore ~ Income, data = community)} is the same plot
#' as \code{jplot(WellbeingScore ~ Income, community)}. Used
#' for scatterplots and boxplots, consistent with the formula syntax of
#' \code{jlm()}, \code{jaov()}, and \code{jt()}. The outcome on the left of
#' \code{~} goes on the y-axis; the predictor on the right goes on the
#' x-axis. Only one predictor is supported here; for a model of several, fit
#' with
#' \code{jlm()} and pass the result to \code{jplot()}. Each side names a
#' variable as it stands: a computed term such as \code{log(Income)} or
#' \code{I(Age > 40)} is refused, so create it as a variable of the data
#' first.
#'
#' \strong{Variable-list form} (for distributions and counts): Pass a data
#' frame followed by one or two unquoted variable names. The data frame is
#' given either positionally or as \code{data = }:
#' \code{jplot(data = community, Age)} is the same plot as
#' \code{jplot(community, Age)}. Used for histograms
#' (1 numeric), bar charts (1 categorical), and grouped bar charts (2
#' categorical). Calls that would otherwise auto-detect to a scatter or
#' boxplot produce a helpful error directing you to the formula form.
#'
#' \strong{A labelled variable with a few categories}, such as Region --
#' six values or fewer with at least one of them labelled, or whole
#' numbers from 0 to 6 -- is drawn as categories when nothing says
#' otherwise: alone, as a bar chart;
#' beside another variable in the variable-list form, as one of a grouped
#' bar chart's two variables or as a boxplot's groups (the error then gives
#' the formula line); on the right of a formula, as the groups of a
#' boxplot. This is for the plot only: the analysis functions read such a
#' variable as numbers unless it is registered or asserted (see
#' \code{\link{jdummy}}). \code{numeric =} or \code{count =}, a
#' \code{\link{jnumeric}()} or \code{\link{jcount}()} registration, a
#' \code{type}, or \code{line}, \code{band}, \code{equation} or \code{r2}
#' (which only a scatter plot draws) keeps the numbers.
#'
#' Supports pipeline integration (\code{jsubset}, \code{jcomplete}, per-call
#' \code{subset}), grouping via \code{by = }, and regression lines with
#' equation/R-squared/band annotations.
#'
#' \strong{The look.} A chart is drawn in a publication style's look -- the
#' style's \code{[plot]} section: its font and size, its colors, its gridlines and
#' axis lines, where its legend goes. Both built-in styles draw in greys,
#' Arial 10 on white, bars from zero; \code{"apa"} with both axis lines, no
#' gridlines and the legend at the right, \code{"report"} with light
#' horizontal gridlines, the x axis line alone and the legend at the top. A
#' chart's axes and legends are titled by the variables' labels, the name
#' where a variable has none; a bar chart of one series shows each bar's
#' count. The style is \code{joptions(style = )}'s, apa when none is set,
#' or the call's \code{style =}.
#'
#' \strong{A chart in a Word file.} Keep a chart with \code{<-} and give it
#' to \code{\link{jtable}()}: it goes into the Word file as a figure,
#' numbered, its title -- the variables' labels -- in the caption with N
#' after it, in the style it was drawn in (see \code{\link{jtable}}).
#'
#' Valid plot names by class (for the result-object form):
#' \itemize{
#'   \item \code{jst_lm}: \code{fit}, \code{predicted}, \code{effects},
#'     \code{coef}, \code{residuals}, \code{qq},
#'     \code{scale}, \code{cooks}, \code{leverage}
#'   \item \code{jst_logistic}: \code{probability}, \code{logit} (the
#'     same fitted line on the log-odds scale, where it is straight: the
#'     linear predictor and its 95% band against the focal variable, the
#'     cases as a rug along the axis, those with the outcome at the top
#'     and the others at the bottom; at a dummy-coded focal variable's
#'     categories, the log-odds at each), \code{roc},
#'     \code{calibration}, \code{binned}, \code{cooks}, \code{leverage},
#'     \code{coef}
#'   \item \code{jst_ttest}, \code{jst_anova}: \code{box} (the default),
#'     \code{qq} (a normal Q-Q plot of the standardized residuals: each
#'     case's distance from its group's mean, or for a paired test each
#'     pair's difference from the mean difference)
#'   \item \code{jst_corr}: \code{heatmap}, \code{scatter} (scatter requires
#'     exactly 2 variables in the correlation)
#'   \item \code{jst_crosstab}: \code{bar}
#' }
#'
#' The shortcut keyword \code{core} (default) produces a curated default
#' set for the class; \code{all} produces every plot the class supports.
#'
#' For a \code{jst_lm} result, \code{effects} draws one plot per variable
#' of the model: a term computed from a variable (\code{I(x^2)},
#' \code{log(x + 1)}, \code{I(x * z)}) is drawn in that variable's plot,
#' following it along the axis, with the other variables held as \code{at}
#' sets them. A dummy-coded categorical variable is one variable, drawn as
#' one plot: its categories along the axis, labeled as the coefficient
#' table labels them, with the predicted outcome at each and its 95%
#' confidence interval. A variable the fit dropped as an exact linear
#' combination of the others has no effect to draw. For a model with no
#' predictors
#' (\code{y ~ 1}), the plots that need a predictor, or that are drawn
#' against the fitted values or the leverage, are left out with a note.
#'
#' Valid plot types for the data-first form: \code{histogram},
#' \code{density}, \code{bar}, \code{scatter}, \code{box},
#' \code{grouped_bar}. A density plot is the histogram's alternative for a
#' numeric variable -- its kernel density estimate, one curve, or one per
#' group of \code{by =} laid over each other -- and is drawn only when
#' asked for with \code{type = "density"}.
#'
#' In the variable-list form \code{facet =} draws one panel per group of
#' the variable named, with the groups' value labels as the panel titles:
#' the alternative to \code{by =} when the groups are many, since colors
#' laid over each other stop being readable past a handful. The two can be
#' combined, \code{by =} coloring the groups of one variable within each
#' panel of another. A scatterplot or boxplot by groups takes \code{by =}
#' in the formula form; \code{facet =} is refused there.
#'
#' Valid \code{line} values: \code{FALSE} (default), \code{TRUE} (alias for
#' \code{lm}), \code{lm}, \code{loess}, \code{connect}.
#'
#' Valid \code{band} values: \code{ci} (default confidence band around the
#' regression line, flares at the ends), \code{pi} (prediction interval for
#' individual observations, wider), \code{see} (constant-width +/- t*SEE
#' band illustrating the homoskedasticity assumption), \code{none} (no band).
#'
#' @param x A result object from one of the package's analysis functions
#'   (result-object form), or a data frame (data-first form).
#' @param which Character vector. \code{core} (default), \code{all}, or
#'   one or more specific plot names valid for the object's class.
#'   (Result-object form only.)
#' @param ... Additional arguments: for the result-object form these are
#'   passed to class-specific methods; for the data-first form these are
#'   unquoted variable names (1 or 2).
#' @param focal Unquoted name of the predictor to place on the
#'   x-axis for \code{jst_lm} / \code{jst_logistic} \code{fit} and
#'   \code{probability} plots. Defaults to the first predictor
#'   in the model that is not dummy-coded, since a fitted line needs a
#'   numeric axis. A dummy-coded categorical variable is named as the
#'   formula names it (\code{focal = Region}), and is drawn with its
#'   categories along the axis: the predicted outcome (or probability) at
#'   each with its 95% confidence interval, the cases behind them.
#' @param at Character string or named list specifying where non-focal
#'   predictors are held when drawing the fitted line in
#'   \code{jst_lm} / \code{jst_logistic} methods. One of \code{zero}
#'   (default), \code{mean}, \code{mixed} (categorical at 0, interval
#'   at mean), or a named list \code{list(Var1 = value, ...)}. A term
#'   computed from the focal variable alone, or from it and variables
#'   held -- a square, \code{I(x^2)}; a log, \code{log(x + 1)} -- is not
#'   held: it is computed from the focal variable at each point of the
#'   line, so the line of a model with a squared term is a curve.
#' @param equation Logical. If TRUE (default), displays the equation in the
#'   subtitle for \code{line = "lm"} scatter plots (data-first form) or
#'   \code{jst_lm} \code{fit} plots (result-object form).
#' @param r2 Logical. If TRUE (default), displays R-squared in the subtitle
#'   alongside the equation.
#' @param by Unquoted variable name for group-coloring (data-first form).
#' @param facet Unquoted variable name for one panel per group
#'   (variable-list form: a histogram, density plot, bar chart or grouped
#'   bar chart), bare or in quotes. See Details.
#' @param type Character. Plot type override for the data-first form. One
#'   of \code{histogram}, \code{density}, \code{bar}, \code{scatter},
#'   \code{box}, \code{grouped_bar}. If NULL (default), auto-detected
#'   from variable types; \code{density} is never the automatic choice.
#' @param line Controls a line overlay on data-first scatter plots. One of
#'   \code{FALSE} (default; no line), \code{TRUE} (alias for \code{lm}),
#'   \code{lm}, \code{loess}, \code{connect}.
#' @param band Character. Uncertainty band type for \code{line = "lm"}
#'   scatter plots. One of \code{ci} (default; 95% confidence band for
#'   the mean, flares at the ends), \code{pi} (95% prediction interval
#'   for individual observations), \code{see} (constant-width band at
#'   +/- t*SEE; useful for teaching homoskedasticity), \code{none}.
#' @param subset Optional unquoted logical expression to filter cases for
#'   this call only (data-first form).
#'   Written in R syntax and checked the way \code{jsubset()} checks a
#'   filter: \code{subset = NOT(Age < 40)}, for example, is refused with
#'   the corrected \code{subset = !(Age < 40)} shown (see
#'   \code{\link{jsubset}} for a translation table).
#' @param labels Character or NULL. How the chart names its variables
#'   (data-first and formula forms). NULL (the default) and \code{"labels"}
#'   title each axis and legend with the variable's label, the name where it
#'   has none; \code{joutput()}'s \code{variable.id} does not reach a chart,
#'   as it reaches no table. \code{"names"} uses the variables' names;
#'   \code{"legend"} and \code{"legend.bottom"} keep names on the axes and
#'   print a console label legend; \code{"both"} is accepted and renders as
#'   \code{"names"}. Not a logical.
#' @param style The publication style the chart is drawn in, a name in
#'   quotes: \code{"apa"}, \code{"report"}, or the name of a style file (see
#'   \code{\link{jstyle}}). NULL (the default) uses \code{joptions(style = )},
#'   apa when it is not set. The style's \code{[plot]} section gives the chart's
#'   look, and \code{\link{jtable}()} frames the chart in the same style.
#' @param numeric Optional. Plotted variables to treat as continuous for
#'   this call (the per-call counterpart of \code{jnumeric()}), named bare
#'   or in quotes, several with \code{c()}: \code{numeric = Education}. In \code{jplot()} a variable's class chooses the
#'   geometry, so this forces numeric handling (histogram for a single
#'   variable; scatter / numeric axis in the formula and two-variable forms).
#'   Applies to the plotted variables only, not the \code{by} grouping
#'   variable.
#' @param categorical Optional. Plotted variables to treat as categorical
#'   for this call (the per-call counterpart of \code{jdummy()} for plotting
#'   purposes), named bare or in quotes, several with \code{c()}. Forces categorical geometry (bar
#'   for a single variable; box / categorical axis in the formula form). A
#'   variable cannot be listed in both \code{categorical} and
#'   \code{numeric}/\code{count}.
#' @param count Optional. Plotted variables to treat as counts for this call
#'   (the per-call counterpart of \code{jcount()}), named bare or in quotes,
#'   several with \code{c()}. A
#'   count is numeric-like for plotting, so it draws the same as \code{numeric};
#'   it is provided for symmetry with the other analysis functions.
#'
#' @return Invisibly, the chart: a \code{ggplot} object of class
#'   \code{jst_plot}, which keeps what a figure needs -- its kind, its N,
#'   its default title from labels and the data it shows -- for
#'   \code{\link{jtable}()}; it remains a ggplot, so \code{+} adds to it.
#'   For a result drawn in several plots (result-object form), a named list
#'   of them, which \code{jtable()} takes as one figure each.
#'
#' @examples
#' # Result-object form
#' m <- jlm(WellbeingScore ~ Income + Age, community)
#' jplot(m)                            # core diagnostics + fit plot
#' jplot(m, which = "coef")            # coefficient forest plot
#' jplot(m, which = "fit", focal = Age, at = "mean")
#'
#' # Formula form (scatter and box)
#' jplot(WellbeingScore ~ Income, community)               # scatter
#' jplot(WellbeingScore ~ Income, community, line = "lm")  # + regression line
#' jplot(WellbeingScore ~ Income, community, line = "lm", band = "see")
#' jplot(WellbeingScore ~ Income, community, by = Volunteer, line = "lm")
#'
#' # Boxplot: a labelled variable with a few categories, such as Region,
#' # is drawn as groups on the right of the formula (for the plot only)
#' jplot(WellbeingScore ~ Region, community)
#' # categorical = asserts it in any variable; numeric = keeps the codes
#' jplot(WellbeingScore ~ Region, community, categorical = "Region")
#'
#' # Variable-list form (distributions and counts)
#' jplot(community, Age)                      # histogram
#' jplot(data = community, Age)               # the same, data frame as data =
#' jplot(community, Region)                   # bar chart
#' jplot(community, Region, Volunteer)        # grouped bar chart
#'
#' # A chart kept, then written to a Word file as a figure
#' p1 <- jplot(community, Region)
#' jtable(p1, file = file.path(tempdir(), "Figure1.docx"), overwrite = TRUE)
#'
#' # The report style's look
#' jplot(community, Region, style = "report")
#'
#' # Using juse() default (omit the data frame in either form)
#' juse(community)
#' jplot(WellbeingScore ~ Income)               # scatter
#' jplot(WellbeingScore ~ Income, line = "lm")  # + regression line
#' jplot(Age)                                   # histogram
#' jplot(Region, Volunteer)                     # grouped bar chart
#'
#' @seealso \code{\link{jstats}} for the package overview,
#'   workflow conventions, and complete function listing.
#'
#' @export
#' @importFrom stats setNames
#' @importFrom utils tail
jplot <- function(x, which = "core", ...) {
  # S3 dispatch evaluates `x` to pick a method, which kills a bare-symbol
  # variable name -- jplot(Age) under a juse() default, or
  # jplot(data = community, Age) -- with "object 'Age' not found" before
  # jplot.default's resolver can treat Age as a variable. So the generic
  # sorts the call itself before dispatching (Session 307, v0.9.178):
  #   1. `x` evaluates to a formula, a result object, or a data frame with
  #      no data = alongside it: dispatch as normal.
  #   2. `x` evaluates to a data frame AND data = is present: stop -- the
  #      frame was given twice.
  #   3. `x` is a bare column name (does not evaluate), or data = is present
  #      and `x` evaluated to some non-frame value that shares the column's
  #      name: rebuild the call for jplot.default AS TYPED -- `x` unnamed,
  #      `which` unnamed unless the user typed it (match.call() binds the
  #      second variable of jplot(Region, Volunteer) to `which`), and a
  #      data = frame moved to the front -- and evaluate it in a child of
  #      the caller's frame that carries jplot.default itself. The method
  #      is registered, not exported, so evaluating its NAME in the
  #      caller's frame fails under library(jstats) (it worked only under
  #      load_all()).
  # `which` is a formal of this frame, so base which() must not be called
  # here: looking the function up would force the promise.
  # A data frame's column (tb$Strss) is not evaluated here either (Session
  # 338; the S324 item): jplot.default's resolver reads it from the call and
  # refuses it, and forcing it first printed a tibble's "Unknown or
  # uninitialised column" warning ahead of that stop. It takes route 3.
  mc       <- match.call(expand.dots = TRUE)
  x_sub    <- if (missing(x)) NULL else substitute(x)
  has_data <- "data" %in% names(mc)
  # A call forwarded through a wrapper's ... (Session 369, Fix Slate 16):
  # match.call() gives each forwarded argument as ..1, ..2, which point at
  # the wrapper's promises. Each argument's quosure is taken here, before
  # the test below forces x -- R drops a forced promise's environment, and
  # rlang, reaching x again through ..N, captured its VALUE (a workspace
  # object of the variable's name) and stopped on it. Everything else is
  # done in the helper. With its matching loop here, ahead of UseMethod()
  # (which carries this frame's local variables into the method's), the
  # INSTALLED generic -- byte-compiled at install, as load_all() does not --
  # stopped on "bad binding access" whenever `which` was given; R CMD
  # check's examples found it (S369; not traced further).
  q_x <- if (missing(x)) NULL else rlang::enquo(x)
  fw  <- .jst_forwarded_args(mc,
                             q_x,
                             if ("which" %in% names(mc)) rlang::enquo(which),
                             rlang::enquos(...),
                             parent.frame())
  x_col    <- !missing(x) &&
                !is.null(.jst_frame_column(substitute(x), parent.frame()))
  # The read that picks the method holds R's warnings (Session 394, the
  # (S392) item; .jst_read_held(), as every other read of the data since
  # S392): a tibble's "Unknown or uninitialised column" for
  # jplot(tb[tb$Agee > 40, ], Score) printed here, and again when the
  # rebuilt call below read the expression a second time, both above the
  # not-found sentence. They are given back only on the dispatch route,
  # once the read is known to go on; a read that failed is read again by
  # the rebuilt call, which holds its own.
  x_read   <- if (missing(x) || x_col) NULL else
                .jst_read_held(function() x)
  x_ok     <- !is.null(x_read) && !x_read$failed
  # A bare word where a quoted value goes (ruling R18, Session 356). `which`
  # is read only when the user named it: jplot(Region, Volunteer) binds a
  # second variable to it by position. And not here when x is a result (Fix
  # Slate 23, Session 377): the list below is every result's, so which =
  # heatmap on a jlm() result was offered which = "heatmap", which stops
  # next; the method reads `which` against that result's own plot names
  # (.jst_resolve_which()). Since Session 378 (Capability Slate C3) the
  # check comes after x is forced above, so a result made by the call
  # itself -- jplot(jlm(y ~ x, d), which = heatmap) -- or taken from a
  # list is a result here too, where a name was looked up without
  # evaluating and a call kept the check, and the pointer it offered
  # stopped next (the S377 item). A data frame's column is not forced
  # (S338), and is no result.
  x_result <- x_ok && inherits(x, .jst_plot_result_classes)
  .jst_word_args(sys.call(), mc, parent.frame(),
                 c(if (!x_result && !is.null(names(sys.call())) &&
                       "which" %in% names(sys.call()))
                     list(which = .jst_word_spec(
                       c("core", "all", "fit", "predicted", "effects", "coef",
                         "residuals", "qq", "scale", "cooks",
                         "leverage", "probability", "logit", "roc",
                         "calibration", "binned", "box", "heatmap", "scatter",
                         "bar"),
                       "a plot name")),
                   list(type = .jst_word_spec(c("histogram", "density", "bar",
                                                "scatter", "box",
                                                "grouped_bar"),
                                              "a plot type"),
                        line = .jst_word_spec(c("lm", "loess", "connect"),
                                              "a line type"),
                        band = .jst_word_spec(c("ci", "pi", "see", "none"),
                                              "a band type"),
                        at   = .jst_word_spec(c("zero", "mean", "mixed"),
                                              "a choice"),
                        style = .jst_word_spec(c(names(.jst_style_builtin()),
                                                 names(.jst_style_files())),
                                               "a style name"))),
                 "jplot")
  # style = (ruling R64, Session 411): the publication style the chart is
  # drawn in, a name in quotes; any other bare word gets ruling R18's
  # pointer, as jtable()'s style = does.
  .jst_free_text_arg(mc$style, parent.frame(), sys.call(), mc, "style",
                     "a style name", "jplot")
  rewrite  <- !x_ok || (has_data && is.atomic(x) && !is.null(x))
  if (!rewrite) {
    if (has_data && is.data.frame(x)) {
      .typed <- function(e) paste(deparse(e), collapse = "")
      .jst_stop("data = ", .typed(fw$typed[[match("data", fw$names)]]),
                " is a second data frame alongside ",
                .typed(fw$typed[[match("x", fw$names)]]), ".\n",
                "Specify the data frame once, before the variable names.",
                fn = "jplot")
    }
    # An expression that gave no rows by reading a column its frame lacks
    # stops here, before the read's warnings are given back (Session 394);
    # jplot.default()'s resolver makes the same check, which then passes.
    if (is.data.frame(x)) .jst_expr_empty_stop(x_sub, x, parent.frame())
    .jst_release_warnings(x_read$warnings)
    UseMethod("jplot")
  }
  sc_names    <- names(sys.call())
  which_typed <- !is.null(sc_names) && "which" %in% sc_names
  args <- fw$args
  # Arguments from more than one environment (a wrapper that passes its
  # own data frame and forwards the variables) keep their ..N; a forced x
  # among them goes in as its quosure, which jplot.default's rlang capture
  # takes as it is.
  ix <- match("x", fw$names)
  if (fw$mixed && x_ok && !is.na(ix) && !is.null(q_x)) args[ix] <- list(q_x)
  nm   <- fw$names
  nm[nm == "x"] <- ""
  if (!which_typed) nm[nm == "which"] <- ""
  names(args) <- nm
  if (has_data) {
    i    <- match("data", nm)
    args <- c(list(args[[i]]), args[-i])
  }
  env <- new.env(parent = fw$env)
  env$jplot.default <- jplot.default
  eval(as.call(c(list(quote(jplot.default)), args)), env)
}

#' Internal helper: a call forwarded through a wrapper's \code{...}, as typed
#'
#' \code{.wrap <- function(...) jplot(...)}: inside jplot()'s generic,
#' \code{match.call()} gives every argument the wrapper forwarded as
#' \code{..1}, \code{..2}, names that point at the wrapper's promises. Until
#' Session 369 (Fix Slate 16) the generic passed those names on, so
#' jplot.default read them in its own terms: \code{.wrap(data = h, Scor)}
#' said "the ..1 data frame", \code{.wrap(Score)} under a juse() default
#' stopped on a variable named "..1", and \code{.wrap(data = h, Score)} with
#' a separate \code{Score} in the workspace stopped on rlang's error, the
#' generic having forced the promise. Each \code{..N} is replaced here by
#' the expression it forwards, read from the argument's quosure, which
#' carries the environment the expression was typed in.
#'
#' The direct call has no \code{..N} and comes back unchanged, to be
#' evaluated where it was made. A forwarded call is evaluated where the
#' forwarded expressions were typed, as the direct call would be -- but only
#' when every argument that needs an environment shares that one. A
#' wrapper that passes an object of its own beside the forwarded ones
#' (\code{function(dat, ...) jplot(data = dat, ...)}) mixes two, and its
#' arguments keep their \code{..N} (\code{mixed}); the generic then passes
#' a forced \code{x} as its quosure.
#'
#' The quosures are taken in the generic's own frame, before anything
#' forces an argument, and matched here to the call's arguments: \code{x}
#' and \code{which} by name, the rest in order to the dots'. When the counts
#' disagree, none is used and the call comes back unchanged.
#'
#' @param mc The generic's \code{match.call(expand.dots = TRUE)}.
#' @param q_x,q_which The quosures of \code{x} and \code{which}, or NULL
#'   where the call does not give them.
#' @param q_dots The dots' quosures, \code{rlang::enquos(...)}.
#' @param caller_env The environment the call was made from.
#' @return A list: \code{names}, the arguments' names ("" where unnamed);
#'   \code{typed}, the arguments with each \code{..N} replaced by the
#'   expression it forwards (for messages); \code{args} and \code{env}, what
#'   to evaluate and where; \code{forwarded}, whether any argument was
#'   forwarded; \code{mixed}, whether the arguments came from more than one
#'   environment.
#' @keywords internal
.jst_forwarded_args <- function(mc, q_x, q_which, q_dots, caller_env) {
  args <- as.list(mc)[-1L]
  nms  <- names(args)
  if (is.null(nms)) nms <- rep("", length(args))
  quos <- vector("list", length(args))
  k    <- 0L
  for (i in seq_along(args)) {
    if (identical(nms[i], "x")) {
      quos[i] <- list(q_x)
    } else if (identical(nms[i], "which")) {
      quos[i] <- list(q_which)
    } else {
      k <- k + 1L
      quos[i] <- list(if (k <= length(q_dots)) q_dots[[k]] else NULL)
    }
  }
  if (k != length(q_dots)) quos <- vector("list", length(args))
  is_dd <- function(e) {
    is.symbol(e) && grepl("^\\.\\.[0-9]+$", as.character(e))
  }
  typed <- args
  envs  <- list()
  fwd   <- FALSE
  for (i in seq_along(args)) {
    e <- args[[i]]
    if (is_dd(e) && !is.null(quos[[i]])) {
      typed[i] <- list(rlang::quo_get_expr(quos[[i]]))
      envs     <- c(envs, list(rlang::quo_get_env(quos[[i]])))
      fwd      <- TRUE
    } else if (is.language(e)) {
      envs <- c(envs, list(caller_env))
    }
  }
  if (!fwd) {
    return(list(names = nms, typed = typed, args = args, env = caller_env,
                forwarded = FALSE, mixed = FALSE))
  }
  one <- all(vapply(envs, identical, logical(1), envs[[1L]]))
  if (one) {
    list(names = nms, typed = typed, args = typed, env = envs[[1L]],
         forwarded = TRUE, mixed = FALSE)
  } else {
    list(names = nms, typed = typed, args = args, env = caller_env,
         forwarded = TRUE, mixed = TRUE)
  }
}

#' @describeIn jplot the default method: a scatter or box plot from a formula (\code{Outcome ~ Predictor}), or a histogram or bar chart from a data frame and one or more variables.
#' @export
#' @importFrom rlang .data
jplot.default <- function(x, ..., by = NULL, type = NULL,
                          line = FALSE, equation = TRUE, r2 = TRUE,
                          band = "ci", subset = NULL, labels = NULL,
                          numeric = NULL, categorical = NULL, count = NULL,
                          facet = NULL, style = NULL) {
  # Validate TRUE/FALSE flags up front. (`line` is excluded: it is a hybrid
  # flag-or-string -- FALSE/TRUE or "lm"/"loess"/"connect" -- with its own
  # validation and house-voice error further down.)
  .jst_check_flag(equation, "equation")
  .jst_check_flag(r2, "r2")
  # The style the chart is drawn in (ruling R64, Session 411): the call's,
  # else the session's publication style. Resolved before anything prints,
  # so a style file that cannot be read stops the call before its title.
  .look <- .jst_plot_look(style)
  .old_look <- .jst_plot_look_set(.look)
  on.exit(.jst_plot_look_restore(.old_look), add = TRUE)

  # Capture the call for later argument-inspection (used by the ignored-arg
  # note that fires when, e.g., the user passes line = "lm" to a histogram).
  jplot_call <- match.call()

  # ---------------------------------------------------------------------------
  # Formula-first path: jplot(DV ~ IV, data) for scatter/box where a DV/IV
  # distinction is meaningful.  Detected BEFORE the data-frame branch because
  # `x` in this case is a formula, not a data frame.
  # ---------------------------------------------------------------------------
  # x is read ONCE here, and the result serves both the formula test and the
  # resolver below (AUDIT-052's jplot sibling): the resolver used to evaluate
  # the expression again, so jplot(jconvert(...), Age) ran jconvert() twice.
  # The generic has usually forced x already, which makes this read free. A
  # bare-symbol variable name routed here from the generic (jplot(Age) under
  # a juse() default) is not evaluable, so the read is guarded: it is
  # recorded as failed, exactly as the resolver's own evaluation would record
  # it, is not a formula, and the resolver treats it as a variable name.
  # A data frame's column (tb$Strss) is not read at all (Session 338): the
  # resolver refuses it from the call as typed, and evaluating it first
  # printed a tibble's own warning for a misspelled column ahead of that
  # stop.
  x_col  <- !missing(x) &&
    !is.null(.jst_frame_column(substitute(x), parent.frame()))
  # Its warnings held (Session 394, the (S392) item): on the generic's
  # rebuilt call this read evaluates the expression again, and printed a
  # tibble's warning above the resolver's stop. Given back below, once the
  # resolver has taken the data; a read the generic made already is free and
  # holds none.
  x_eval <- if (missing(x) || x_col) NULL else
    .jst_read_held(function() x)
  if (!is.null(x_eval) && !x_eval$failed && inherits(x_eval$value, "formula")) {
    .jst_release_warnings(x_eval$warnings)
    by_sub <- substitute(by)
    # facet = is the variable-list form's (Capability Slate C3, Session
    # 378): a scatterplot or boxplot by groups takes by =.
    if (!is.null(substitute(facet)) && !missing(facet)) {
      .jst_stop("facet = draws one panel per group of a histogram, a ",
                "density plot or a bar chart, in the variable-list form.\n",
                "For a scatterplot or a boxplot by groups, add by = to the ",
                "call instead, for example:\n",
                "  jplot(WellbeingScore ~ Income, community, by = Region)",
                fn = "jplot")
    }
    return(.jst_jplot_formula(x, jplot_call, ...,
                              by_expr = by_sub, type = type, line = line,
                              equation = equation, r2 = r2, band = band,
                              subset_expr = substitute(subset),
                              labels = labels,
                              name_subs = list(
                                numeric     = substitute(numeric),
                                categorical = substitute(categorical),
                                count       = substitute(count)),
                              parent_env = parent.frame()))
  }

  # Resolve the first argument: explicit data frame, juse default,
  # or bare-symbol-as-variable-name (leading comma omitted).
  arg1 <- .jst_resolve_first_arg(
    data_sub      = substitute(x),
    data_missing  = missing(x),
    fn_name       = "jplot",
    envir         = parent.frame(),
    accept_vector = FALSE,
    pre_eval      = x_eval
  )
  .jst_release_warnings(x_eval$warnings)

  # Alias to `data` internally for clarity; the generic uses `x` for S3 consistency
  data              <- arg1$data
  .jst_data_name    <- arg1$name
  .jst_default_used <- arg1$mode %in% c("default", "symbol_with_default")

  # An internal guard since Session 374 (the remedy-line audit): the
  # resolver above stops every call that would reach here without a data
  # frame -- no call tried reached it -- so it is a plain invariant, with
  # no offered line (it had offered jplot(my_result)).
  if (!is.data.frame(data)) {
    stop("Internal error: jplot() reached its plotting step without a ",
         "data frame.", call. = FALSE)
  }

  # Capture variable names
  variables <- rlang::enquos(...)
  .jst_check_named_variables(variables, arg1$data, "jplot")   # S290

  # Leading-comma-omitted: prepend the captured symbol to variables list
  if (arg1$mode == "symbol_with_default") {
    extra_quo <- rlang::new_quosure(arg1$first_arg_sub,
                                    env = parent.frame())
    variables <- c(list(extra_quo), variables)
    class(variables) <- "quosures"
  }
  variables <- .jst_expand_vars(variables)   # c() of names (ruling R18, S356)

  variable_names <- vapply(variables, rlang::quo_name, character(1))
  by_quo         <- rlang::enquo(by)
  has_by         <- !rlang::quo_is_null(by_quo)
  by_name        <- if (has_by) .jst_one_var_name(by_quo, "jplot", "by =") else NULL
  # facet = (Capability Slate C3, Session 378): one panel per group of the
  # variable named, an alternative to by = when the groups are many. Read as
  # by = is, bare or in quotes, one variable.
  facet_quo      <- rlang::enquo(facet)
  has_facet      <- !rlang::quo_is_null(facet_quo)
  facet_name     <- if (has_facet) .jst_one_var_name(facet_quo, "jplot", "facet =") else NULL

  n_vars <- length(variable_names)
  # One sentence a line, each example on a line of its own (Session 369,
  # Fix Slate 17). The over-two example had been jplot(community, Age,
  # Income, by = Region), which stops: two numeric variables want the
  # formula form.
  if (n_vars == 0) {
    .jst_no_vars_stop("jplot(community, Age)", fn = "jplot")
  }
  if (n_vars > 2) {
    .jst_stop("only 1 or 2 variables can be plotted at once.\n",
              "To show a variable by the groups of another, add by = to the ",
              "call, for example:\n",
              "  jplot(community, Age, by = Region)\n",
              "Or call jplot() once for each variable.", fn = "jplot")
  }

  # Check all variables exist
  check_names <- variable_names
  if (has_by) check_names <- c(check_names, by_name)
  if (has_facet) check_names <- c(check_names, facet_name)
  .jst_check_vars(data, check_names, .jst_data_name, default_used = .jst_default_used)
  if (has_by && has_facet && identical(by_name, facet_name)) {
    .jst_stop("by = and facet = both name ", by_name, ".\n",
              "Name it once: by = colors the groups on one plot, facet = ",
              "draws one panel per group.", fn = "jplot")
  }

  # numeric =, categorical = and count = name variables, bare or in quotes
  # (ruling R18; Fix Slate 23, Session 377, as jlm()'s since Session 376):
  # read without evaluating a bare name, which had stopped with R's own
  # "object 'Environment2' not found".
  .name_args  <- .jst_model_name_args(
    list(numeric = substitute(numeric), categorical = substitute(categorical),
         count = substitute(count)),
    parent.frame(), data, .jst_data_name, example = unname(variable_names[1L]),
    default_used = .jst_default_used)
  numeric     <- .name_args$numeric
  categorical <- .name_args$categorical
  count       <- .name_args$count

  # -- Per-call classification overrides -------------------------------------
  # In jplot a variable's class chooses the geometry (numeric -> histogram /
  # scatter point; categorical -> bar / box grouping). numeric=/categorical=/
  # count= assert that class for the named plotted variables, overriding the
  # structural guess (threaded into .jst_is_categorical below). A count is
  # numeric-like for geometry, so count= draws the same as numeric=; it is
  # exposed for symmetry and forward-compatibility. Overrides apply to the
  # plotted variables only, not to the by= grouping variable.
  for (.arg in c("numeric", "categorical", "count")) {
    .val <- get(.arg)
    if (!is.null(.val)) {
      .bad <- setdiff(.val, variable_names)
      if (length(.bad) > 0) {
        .jst_stop(.jst_not_among_text(.arg, .bad,
                                      "the variables given to jplot()"))
      }
    }
  }
  # A variable cannot be both categorical and numeric-like (the assertions
  # contradict). numeric and count are both numeric-like, so they do not clash.
  .jst_check_cat_clash(categorical, numeric, count)

  # Validate band argument
  valid_bands <- c("ci", "pi", "see", "none")
  if (!is.character(band) || length(band) != 1 || !band %in% valid_bands) {
    .jst_stop("`band` must be one of: ", paste(sprintf("\"%s\"", valid_bands),
                                          collapse = ", "), ".")
  }

  # Validate line argument
  if (isTRUE(line)) line <- "lm"
  valid_lines <- c(FALSE, "lm", "loess", "connect")
  if (!identical(line, FALSE) && !(is.character(line) && length(line) == 1 &&
                                   line %in% c("lm", "loess", "connect"))) {
    .jst_stop("`line` must be FALSE, TRUE, or one of: ",
         "\"lm\", \"loess\", \"connect\".")
  }

  # Apply data pipeline (jcomplete, jsubset, subset)
  subset_expr <- substitute(subset)
  pipeline <- .jst_apply_pipeline(data, .jst_data_name, .jst_default_used,
                                  subset_expr = subset_expr,
                                  envir = parent.frame(),
                                  vars = c(variable_names, by_name, facet_name))
  # A text variable's blank cells plot as one category, <blank> (S340).
  data <- .jst_label_blank_text(pipeline$data)
  # Pipeline messages are printed below, after the red title

  # Classify variables (per-call override > structure; see .jst_is_categorical)
  var_types <- vapply(variable_names,
                      function(v) {
                        ov <- if (v %in% categorical) "categorical"
                              else if (v %in% count)   "count"
                              else if (v %in% numeric) "numeric"
                              else NULL
                        if (.jst_is_categorical(data[[v]], v, .jst_data_name,
                                                override = ov))
                          "categorical" else "numeric"
                      },
                      character(1))

  # -- Single-variable geometry redirect (display only) ----------------------
  # The intent helper above calls an un-asserted labelled Likert (e.g.
  # community$Education, Environment1-5) "numeric", which routes it to a
  # histogram -- but a labelled/discrete vector is discrete on the x axis, so
  # geom_histogram() errors ("requires a continuous x aesthetic"). For the
  # single-variable auto case, when the variable carries NO explicit
  # numeric/count assertion (per-call override OR jnumeric/jcount registration)
  # and is structurally discrete (the existing structural detector --
  # centralizing the call so geometry and warnings can't drift apart), draw a
  # bar instead. This is a display choice only; it never changes analysis
  # classification, and an explicit numeric=/count= or registration is honoured
  # (those keep the histogram, which the builder hardens against labels below).
  # Ruling R38 (Session 391): one of two variables too, so jplot(d, Region,
  # OwnsHome) draws the grouped bar chart and jplot(d, WellbeingScore,
  # Region) gets the boxplot stop with the formula line, where both had read
  # as two numbers and stopped with a line that drew a scatter of the codes.
  # The test is .jst_plot_discrete_redirect(), the formula form's too. As
  # there, line =, band =, equation = or r2 = asks for the scatterplot.
  fit_args <- intersect(c("line", "band", "equation", "r2"),
                        names(jplot_call))
  if (is.null(type) &&
      (n_vars == 1L || (n_vars == 2L && length(fit_args) == 0L))) {
    for (i in seq_len(n_vars)) {
      vi <- variable_names[i]
      if (var_types[[i]] == "numeric" &&
          .jst_plot_discrete_redirect(data[[vi]], vi, .jst_data_name,
                                      vi %in% c(numeric, count))) {
        var_types[i] <- "categorical"
      }
    }
  }

  # Auto-detect plot type if not specified
  resolved_type <- type
  if (is.null(resolved_type)) {
    resolved_type <- .jst_auto_plot_type(var_types, n_vars)
  }

  valid_types <- c("histogram", "density", "bar", "scatter", "box",
                   "grouped_bar")
  if (!resolved_type %in% valid_types) {
    .jst_stop("Invalid `type` value: \"", resolved_type, "\".\n",
         "Valid types: ", paste(sprintf("\"%s\"", valid_types),
                                 collapse = ", "), ".")
  }
  # A histogram or a density plot (Capability Slate C3, Session 378: the
  # density plot is an alternative to the histogram, never the automatic
  # choice) draws one numeric variable: on two the scatter stop below
  # speaks; on a text variable, a factor or a date -- values no axis can
  # bin -- the stop is here, where ggplot2's own "stat_bin() requires a
  # continuous x aesthetic" had been the answer.
  if (resolved_type %in% c("histogram", "density") && n_vars == 1L) {
    v1 <- variable_names[1L]; c1 <- data[[v1]]
    kind <- if (is.character(c1) ||
                (haven::is.labelled(c1) && typeof(c1) == "character")) "a text variable"
            else if (is.factor(c1)) "a factor"
            else if (inherits(c1, c("Date", "POSIXct", "POSIXlt"))) "a date variable"
    if (!is.null(kind)) {
      .jst_stop("a ", if (resolved_type == "density") "density plot" else "histogram",
                " needs a numeric variable, and ", v1, " is ", kind, ".\n",
                "For the count of each value, draw a bar chart:\n",
                "  jplot(", if (!is.null(.jst_data_name)) .jst_data_name else "MyData",
                ", ", v1, ", type = \"bar\")", fn = "jplot")
    }
  }

  # -- Require formula syntax for scatter and box (relationship plots) ------
  # These plots distinguish DV from IV. Requiring formula syntax prevents
  # confusion about which variable goes on which axis and mirrors jlm/jaov.
  if (resolved_type == "scatter") {
    # Ruling R38 (Session 391): the formula form reads an unasserted labelled
    # variable of whole numbers on the right of ~ as groups, so where the IV
    # is one, the line keeps what made this call a scatterplot -- its
    # numeric = or count = for the IV, else its type = -- since the line
    # alone would draw a boxplot.
    iv <- variable_names[1]
    keep_iv <- if (.jst_plot_discrete_redirect(data[[iv]], iv, .jst_data_name,
                                               FALSE)) {
      if (iv %in% count) paste0(", count = ", iv)
      else if (iv %in% numeric) paste0(", numeric = ", iv)
      else if (!is.null(type)) paste0(", type = \"", type, "\"")
      else ""
    } else ""
    .jst_stop("For two-numeric scatterplots, use formula syntax to make the ",
         "outcome and the predictor explicit (consistent with jlm):\n",
         "  jplot(", variable_names[2], " ~ ", iv,
         ", ", if (!is.null(.jst_data_name)) .jst_data_name else "MyData",
         keep_iv,
         if (!identical(line, FALSE)) paste0(", line = \"",
                                             if (isTRUE(line)) "lm" else line,
                                             "\"") else "",
         ")\n",
         "(The outcome on the left of ~ goes on the y-axis; the predictor on ",
         "the right goes on the x-axis.)")
  }
  if (resolved_type == "box") {
    # The fix line is built from what the call gave (Session 338; the S316
    # item). It took both names from the variable list by class, so a
    # grouping variable given as by =, and a forced type = "box" on two
    # variables of one class, printed "~ NA". Now: one variable listed, the
    # by = variable is the grouping variable; two listed, the categorical
    # one is, or -- when both are of one class -- the one with fewer
    # distinct values (the first listed on a tie). The line carries
    # type = "box", because the formula form draws a scatterplot for a
    # grouping variable that is not registered categorical, which would
    # answer a boxplot request with a different plot.
    if (n_vars == 1L && !has_by) {
      .jst_stop("a boxplot needs a grouping variable, and only ",
                variable_names[1L], " was given.\n",
                "Use formula syntax, with the outcome on the left of ~ and ",
                "the grouping variable on the right, for example:\n",
                "  jplot(WellbeingScore ~ Region, community, type = \"box\")")
    }
    if (n_vars == 1L) {
      num_var <- variable_names[1L]
      cat_var <- by_name
      by_txt  <- ""
    } else {
      is_cat <- var_types == "categorical"
      grp <- if (sum(is_cat) == 1L) {
        which(is_cat)
      } else {
        n_distinct <- vapply(variable_names, function(v) {
          x <- data[[v]]
          length(unique(x[!is.na(x)]))
        }, integer(1))
        if (n_distinct[2L] < n_distinct[1L]) 2L else 1L
      }
      cat_var <- variable_names[grp]
      num_var <- variable_names[3L - grp]
      by_txt  <- if (has_by) paste0(", by = ", by_name) else ""
    }
    .jst_stop("For boxplots, use formula syntax to make the outcome and grouping ",
         "variable explicit (consistent with jaov):\n",
         "  jplot(", num_var, " ~ ", cat_var, ", ",
         if (!is.null(.jst_data_name)) .jst_data_name else "MyData",
         by_txt, ", type = \"box\")\n",
         "(The numeric outcome on the left of ~ goes on the y-axis; the ",
         "categorical grouping variable on the right goes on the x-axis.)")
  }

  # -- Note about arguments ignored for this plot type ----------------------
  # line/band/equation/r2 apply only to scatter plots with line = "lm"; one
  # note names any the call gave a plot that does not use them.
  .jst_plot_ignored_note(jplot_call, resolved_type, line)

  # -- Capture axis labels BEFORE factor conversion strips them ------------
  # Variable label display mode. jplot is a collapse layout where the
  # analogue of "names in rows" is the axis/legend title: under "labels" each
  # axis shows the variable's label, otherwise its name. "legend"/
  # "legend.bottom" additionally print a console label legend (below).
  # Labels by default since Session 415 (the S412 audit's F4, ruled Session
  # 413): a chart's axis and legend titles come from labels, in the Plots
  # pane as in Word, the name where a variable has none; joutput()'s
  # variable.id no longer reaches a chart, as it reaches no table. labels =
  # stays a per-call choice. A long label is put on two lines, never cut.
  vlmode <- if (is.null(labels)) "labels" else .jst_resolve_variable_id(labels)
  axis_labels <- stats::setNames(
    vapply(variable_names,
           function(v) if (identical(vlmode, "labels")) {
             .jst_plot_label(data[[v]], v)
           } else {
             v
           },
           character(1)),
    variable_names
  )
  by_label <- if (has_by) {
    if (identical(vlmode, "labels")) .jst_plot_label(data[[by_name]], by_name) else by_name
  } else NULL

  # -- Red title --------------------------------------------------------------
  plot_title <- .jst_plot_title(resolved_type, variable_names, by_name,
                                facet_name)
  .cat_red(paste0(plot_title, "\n"))

  # Print pipeline messages (default data frame note, filter/complete status)
  if (.jst_default_used) .jst_default_note(.jst_data_name)
  .jst_print_msgs(pipeline$msgs)
  # The cases the plot draws, and how many it leaves out (Session 349).
  n_plot <- .jst_plot_n_line(data, c(variable_names, by_name, facet_name),
                             pipeline$pipeline_counts$n_original)
  # A variable drawn on a numeric scale holding Inf or -Inf (Session 394):
  # ggplot2 left the case out, under its "Removed 1 rows" warning, though
  # the N line above counted it.
  .jst_plot_infinite_stop(data, c(variable_names, by_name, facet_name),
                          variable_names[var_types == "numeric"],
                          resolved_type, .jst_data_name)

  # Convert haven-labelled variables for plotting, by their resolved class.
  # A variable plotted with categorical geometry (bar, grouped bar, the x of a
  # box) becomes a factor so its value labels show; one plotted with numeric
  # geometry (histogram, scatter, the y of a box) is reduced to its underlying
  # numeric, because a labelled/factor column is discrete on a continuous axis
  # and would make geom_histogram() / scatter error. (Previously every labelled
  # variable with value labels was factored regardless of geometry, which is
  # what broke a histogram of a labelled Likert.) var_types is the per-variable
  # class the builders also read, so keying off it keeps conversion and
  # geometry consistent. Index with [[i]]: var_types here is a NAMED vector
  # (vapply over variable_names), so var_types[i] would carry the variable's
  # name and identical(named, "categorical") is always FALSE -- which silently
  # skipped the as_factor branch and bared the value labels off labelled bars.
  # What the figure frame needs from the variables before they are made
  # factors: the default title, from labels (ruling R69), and what the chart
  # names by name or by code where no label stood (ruling R72).
  cat_vars <- c(variable_names[var_types == "categorical"],
                if (has_by) by_name, facet_name)
  frame <- .jst_plot_frame_facts(
    data, resolved_type,
    shown = c(variable_names, by_name, facet_name),
    categorical = cat_vars,
    title = .jst_plot_default_title(resolved_type, data, variable_names,
                                    by_name, facet_name),
    pipeline_counts = pipeline$pipeline_counts, data_name = .jst_data_name)

  data <- .jst_plot_convert_labelled(data, variable_names, var_types,
                                     by_name, has_by)
  # The facet variable as the by variable: a factor, its value labels as the
  # panel titles.
  if (has_facet) data[[facet_name]] <- .jst_plot_group_factor(data[[facet_name]])

  # Console label legend (only under "legend"/"legend.bottom"; collapse).
  if (vlmode %in% c("legend", "legend.bottom")) {
    .print_var_labels(data, check_names)
  }

  # Dispatch to plot builder
  p <- switch(
    resolved_type,
    histogram   = .jst_build_histogram(data, variable_names[1], by_name,
                                       axis_labels, by_label, facet_name,
                                       look = .look),
    density     = .jst_build_density(data, variable_names[1], by_name,
                                     axis_labels, by_label, facet_name,
                                     look = .look),
    bar         = .jst_build_bar(data, variable_names[1], by_name,
                                 axis_labels, by_label, facet_name,
                                 look = .look),
    scatter     = .jst_build_scatter(data, variable_names, by_name,
                                     line, equation, r2, band,
                                     axis_labels, by_label, look = .look),
    box         = .jst_build_box(data, variable_names, var_types, by_name,
                                 axis_labels, by_label, look = .look),
    grouped_bar = .jst_build_grouped_bar(data, variable_names,
                                         axis_labels, facet_name,
                                         look = .look)
  )
  p <- .jst_plot_finish_built(p, resolved_type, n_plot, frame, .look)

  print(p)
  invisible(p)
}

#' Internal helper: a data-first chart's frame facts
#'
#' The default title, and the variables it shows by name or by code where
#' no label stood (ruling R72), read from the variables before they are made
#' factors.
#'
#' @param data The frame after the pipeline.
#' @param type The resolved chart type.
#' @param shown Character; every variable the chart shows.
#' @param categorical Character; those it shows by category.
#' @param title Character(1), the default title.
#' @return A list: title, names_shown, codes_shown, labelled.
#' @keywords internal
.jst_plot_frame_facts <- function(data, type, shown, categorical, title,
                                  pipeline_counts = NULL, data_name = NULL) {
  shown <- unique(shown[!is.na(shown)])
  has   <- vapply(shown, function(v) .jst_plot_has_label(data[[v]]), logical(1))
  codes <- list()
  any_vl <- FALSE
  for (v in unique(categorical)) {
    if (length(labelled::val_labels(data[[v]]))) any_vl <- TRUE
    present <- unique(unclass(data[[v]])[!is.na(data[[v]])])
    miss <- .jst_plot_unlabelled_codes(data[[v]], present)
    if (length(miss)) codes[[v]] <- miss
  }
  # The labels the shown codes' variables do carry, for the jrelabel() line
  # of ruling R72's note, which lists them with the codes it adds.
  code_labels <- lapply(names(codes), function(v) {
    vl <- labelled::val_labels(data[[v]])
    if (!length(vl)) return(NULL)
    stats::setNames(names(vl), as.character(unclass(vl)))
  })
  names(code_labels) <- names(codes)
  list(title = title, names_shown = shown[!has], codes_shown = codes,
       labelled = any(has) || any_vl, code_labels = code_labels,
       filter = .jst_plot_filter_facts(pipeline_counts),
       data_name = if (is.character(data_name) && length(data_name) == 1L &&
                       !is.na(data_name)) data_name)
}

#' Internal helper: the filters a chart was drawn under, for its figure's note
#'
#' A figure's general note names a filter as a table's does (ruling R63: "a
#' filter sentence"): the stored jsubset() filter and the call's subset =,
#' kept as the results keep them, with a slice of no rows of the data frame
#' holding the variables the conditions name, so the note can put them into
#' words with their labels without the chart carrying the data frame.
#'
#' @param si The pipeline's counts, or a result's sample_info.
#' @return NULL when no filter ran, else a list as sample_info holds it.
#' @keywords internal
.jst_plot_filter_facts <- function(si) {
  if (!is.list(si)) return(NULL)
  conds <- c(if (isTRUE(si$filter_active) && is.character(si$filter_expr))
               paste(trimws(si$filter_expr), collapse = " "),
             if (is.character(si$subset_expr) && length(si$subset_expr))
               paste(trimws(si$subset_expr), collapse = " "))
  conds <- conds[nzchar(conds)]
  if (!length(conds)) return(NULL)
  vars <- unique(unlist(lapply(conds, function(cd) {
    ex <- tryCatch(str2lang(cd), error = function(e) NULL)
    if (is.null(ex)) character(0) else all.vars(ex)
  })))
  d <- si$pre_pipeline_data
  slice <- NULL
  if (is.data.frame(d)) {
    keep <- intersect(vars, names(d))
    # A row subset drops a plain column's label (the pipeline restores them
    # the same way), so each column's label is put back on its slice.
    cols <- lapply(keep, function(v) {
      x <- d[[v]]
      y <- x[0L]
      lab <- attr(x, "label", exact = TRUE)
      if (!is.null(lab)) attr(y, "label") <- lab
      y
    })
    slice <- structure(stats::setNames(cols, keep), class = "data.frame",
                       row.names = integer(0))
  }
  list(filter_active = isTRUE(si$filter_active), filter_expr = si$filter_expr,
       subset_expr = si$subset_expr, pre_pipeline_data = slice)
}

#' Internal helper: a chart's default title (ruling R69)
#'
#' From labels, the name where a variable has none, never naming the
#' chart's kind (APA: "a brief but descriptive title"): the variable alone
#' for a bar chart, a histogram or a density plot; the variable "by" the
#' group for a chart by groups, a grouped bar chart and a box plot; the
#' outcome "by" the predictor for a scatterplot. A panel variable adds
#' itself as a group does. The title stands in the figure's caption in a
#' Word file; title = in jtable() replaces it.
#'
#' @param type The resolved chart type.
#' @param data The frame.
#' @param variable_names Character; the variables as the builder takes
#'   them (a scatterplot's and a formula box plot's predictor first).
#' @param by_name,facet_name Character(1) or NULL.
#' @param formula Logical(1); the formula form, whose outcome is second.
#' @return Character(1).
#' @keywords internal
.jst_plot_default_title <- function(type, data, variable_names, by_name = NULL,
                                    facet_name = NULL, formula = FALSE) {
  lab <- function(v) {
    l <- labelled::var_label(data[[v]])
    if (is.null(l) || !length(l) || is.na(l[1]) || !nzchar(l[1])) v else as.character(l[1])
  }
  groups <- c(by_name, facet_name)
  body <- if (type %in% c("scatter", "box") && length(variable_names) == 2L) {
    # The outcome by the predictor: the outcome is the numeric variable.
    if (identical(type, "box") && !formula) {
      num <- variable_names[vapply(variable_names, function(v) {
        !is.factor(data[[v]]) && !is.character(data[[v]])
      }, logical(1))]
      y <- if (length(num)) num[1L] else variable_names[2L]
      x <- setdiff(variable_names, y)[1L]
    } else {
      x <- variable_names[1L]; y <- variable_names[2L]
    }
    paste(lab(y), "by", lab(x))
  } else if (identical(type, "grouped_bar")) {
    paste(lab(variable_names[1L]), "by", lab(variable_names[2L]))
  } else {
    lab(variable_names[1L])
  }
  if (length(groups)) {
    body <- paste(body, if (grepl(" by ", body, fixed = TRUE)) "and" else "by",
                  .jst_and_list(vapply(groups, lab, character(1))))
  }
  body
}

#' Internal helper: a data-first chart marked as jplot()'s
#'
#' @param p The builder's chart (\code{.jst_plot_built()}).
#' @param type The resolved chart type.
#' @param n The cases drawn.
#' @param frame The facts \code{.jst_plot_frame_facts()} read.
#' @param look The look it was drawn in.
#' @return The chart.
#' @keywords internal
.jst_plot_finish_built <- function(p, type, n, frame, look) {
  if (!inherits(p, "ggplot")) return(p)
  built <- attr(p, "jst_built", exact = TRUE)
  attr(p, "jst_built") <- NULL
  .jst_plot_finish(p, kind = type, n = n, title = frame$title,
                   data = built$data, names_shown = frame$names_shown,
                   codes_shown = frame$codes_shown, scales = built$scales,
                   labelled = frame$labelled, look = look,
                   filter = frame$filter, data_name = frame$data_name,
                   code_labels = frame$code_labels)
}


#' Internal helper: the data frame jplot()'s formula form is given, read
#'
#' The five formula functions read their data at the front door
#' (\code{.jst_check_formula_data()}); jplot()'s formula form reads it from
#' its dots, and a name found nowhere -- \code{jplot(Score ~ Group, dd)} --
#' or an expression that could not be evaluated gave R's own "object 'dd'
#' not found". Read here, a name found nowhere gets ruling R36's stop
#' (\code{.jst_formula_data_found()}) and an expression the expression stop
#' (\code{.jst_expr_data_stop()}), or, where it gave no rows by reading a
#' column its frame lacks, the not-found sentence
#' (\code{.jst_expr_empty_stop()}), as in those functions (Session 392).
#'
#' @param q The quosure of the argument given as the data.
#' @param formula The formula.
#' @return The argument's value.
#' @keywords internal
.jst_jplot_data_value <- function(q, formula) {
  e   <- rlang::quo_get_expr(q)
  env <- rlang::quo_get_env(q)
  if (!is.environment(env)) env <- parent.frame()
  ucl <- tryCatch(.jst_caller_call(), error = function(err) NULL)
  if (is.symbol(e) && nzchar(as.character(e)) &&
      !exists(as.character(e), envir = env)) {
    .jst_formula_data_found(e, formula, env, ucl, "jplot")
  }
  val <- .jst_read_held(function() rlang::eval_tidy(q))
  if (isTRUE(val$failed)) {
    if (is.call(e)) {
      .jst_expr_data_stop(e, val$error, "jplot", env, ucl,
                          vars = all.vars(formula), relay = "always")
    }
    stop(val$error)
  }
  .jst_expr_empty_stop(e, val$value, env)
  .jst_release_warnings(val$warnings)
  val$value
}


#' Internal helper: handle the formula-first form of jplot
#'
#' Called by \code{jplot.default} when the first argument is a formula.
#' Parses the formula into DV (y-axis) and IV (x-axis), resolves the data
#' frame from the second positional argument or juse default, and dispatches
#' to the scatter or box builder depending on the IV's type.
#'
#' Only single-IV formulas are supported (\code{DV ~ IV}). Multi-IV formulas
#' produce a helpful error pointing to the jlm() + jplot(m) workflow. A data
#' frame named inside a term, and a computed term, are refused before the
#' variables are counted, once the frame is resolved (Session 323): the path
#' pulls each variable by name, so a computed term plotted the raw variable.
#'
#' @keywords internal
.jst_jplot_formula <- function(formula, jplot_call, ..., by_expr, type, line,
                               equation, r2, band, subset_expr, labels,
                               name_subs = list(), parent_env) {

  # -- Parse formula ---------------------------------------------------------
  .jst_formula_quoted_stop(formula, jplot_call, "jplot")   # R18, S356
  formula_vars <- all.vars(formula)
  if (length(formula) < 3) {
    .jst_stop("A two-sided formula is required: outcome ~ predictor.\n",
         "  Example: jplot(WellbeingScore ~ Income, community)")
  }

  # -- Resolve data frame ----------------------------------------------------
  # The first UNNAMED argument in ..., or a data = argument, or the juse
  # default -- in that order of lookup, and never both of the first two.
  # `data` is not a formal of jplot.default (the generic's first formal is
  # `x`, for S3), so data = d arrives in the NAMED dots. (Session 300: until
  # then this block read only the unnamed dots, so jplot(y ~ x, data = d)
  # fell through to the juse() branch -- a false "No data frame specified"
  # error with no default set, and the DEFAULT frame silently plotted in
  # place of d with one set.)
  # Read unevaluated first (Fix Slate 23, Session 377): an argument jplot()
  # does not take stops as "unused input", as it does in the data-first
  # form, where it had been evaluated -- foo = Smoker stopping with R's own
  # "object 'Smoker' not found" -- or, given a value, silently ignored. Only
  # the data frame is evaluated.
  dots_q    <- rlang::enquos(...)
  dot_names <- names(dots_q)
  if (is.null(dot_names)) dot_names <- rep("", length(dots_q))
  .jst_check_args(dots_q[nzchar(dot_names) & dot_names != "data"],
                  aliases = character(0), fn_name = "jplot")
  # The data frame is read through .jst_jplot_data_value() (Session 392): a
  # name found nowhere, or an expression that cannot be evaluated, gave R's
  # own "object 'dd' not found" here; ruling R36's stop and the expression
  # stop are the five formula functions'.
  pos_q <- dots_q[!nzchar(dot_names)]
  positional_dots <- lapply(seq_along(pos_q), function(i) {
    if (i == 1L) .jst_jplot_data_value(pos_q[[1L]], formula)
    else rlang::eval_tidy(pos_q[[i]])
  })
  has_data_named  <- "data" %in% dot_names
  dots <- if (has_data_named)
    list(data = .jst_jplot_data_value(dots_q[[match("data", dot_names)]],
                                      formula)) else list()

  # The frame's expression as typed, recovered from the captured call, for
  # messages and for the registry lookups keyed on it (jsubset, jcomplete,
  # jdummy). match.call() has already bound the formula to the `x` formal,
  # so a positional frame is the FIRST unnamed element of the call, not the
  # second. (Session 296: the test used to read ">= 2" and take element
  # [[2]], which no formula call can satisfy, so .jst_data_name stayed NULL
  # on every positional formula call -- stored jsubset / jcomplete settings
  # were silently skipped on this path, with a false "not active for this
  # dataset" note, and every message said "the data frame".)
  mc_args  <- as.list(jplot_call)[-1L]
  mc_names <- names(mc_args)
  if (is.null(mc_names)) mc_names <- rep("", length(mc_args))
  mc_positional <- mc_args[!nzchar(mc_names)]
  .typed <- function(e) paste(deparse(e), collapse = "")

  # A frame given both ways stops, ahead of the extra-positional stop, so
  # jplot(y ~ x, d, data = e) names the clash rather than silently plotting
  # whichever form happened to be read first.
  if (has_data_named && length(positional_dots) >= 1) {
    .jst_stop("data = ", .typed(mc_args[["data"]]),
              " is a second data frame alongside ",
              .typed(mc_positional[[1]]), ".\n",
              "Specify the data frame once, after the formula.", fn = "jplot")
  }

  .jst_default_used <- FALSE
  .jst_data_name    <- NULL
  if (length(positional_dots) >= 1) {
    data <- positional_dots[[1]]
    if (length(mc_positional) >= 1) {
      .jst_data_name <- .typed(mc_positional[[1]])
    }
    if (length(positional_dots) > 1) {
      # S355 (the S282 item; voice Rule B): the inputs named as typed, where
      # it read "Only one data argument is expected after the formula. Extra
      # positional arguments were supplied."
      .jst_stop("only one data frame goes after the formula, and this ",
                "call gives ",
                .jst_and_list(vapply(mc_positional, .typed, character(1))),
                ".\n",
                "Specify the data frame once, after the formula.",
                fn = "jplot")
    }
  } else if (has_data_named) {
    data <- dots[["data"]]
    if ("data" %in% mc_names) {
      .jst_data_name <- .typed(mc_args[["data"]])
    }
  } else {
    resolved <- .jst_resolve_data(envir = parent_env)
    data <- resolved$data
    .jst_default_used <- TRUE
    .jst_data_name    <- resolved$name
  }

  if (!is.data.frame(data)) {
    .jst_stop("the data after the formula must be a data frame.",
              fn = "jplot")
  }

  # -- Terms the plot cannot take (Session 323) ------------------------------
  # Read before the variables are counted, with the frame now known. A data
  # frame named inside a term (d$Flourishing ~ d$Income) is refused with the
  # variables-on-their-own form, as jlm() refuses it. A computed term
  # (I(ScreenTime > 4), log(Income)) is refused as jcrosstab() refuses it:
  # the path pulls the column by name, so it plotted the raw variable under
  # the term's title, and with a constant (I(ScreenTime > cutoff)) the count
  # below stopped for the wrong reason. The variable count moved below the
  # frame's resolution to make room; neither step prints anything.
  .jst_check_formula_frames(formula, data, .jst_data_name)
  # A computed term is refused first (Session 374, the remedy-line audit:
  # the add-it line kept a term refused next); a workspace object fetched
  # with $, @ or [[ (ruling R19, Session 357) is named for what it is
  # ahead of the refusal of any other term.
  .jst_check_formula_transforms(formula, .jst_data_name, skip_fetch = TRUE)
  .jst_check_formula_objects(formula, data, .jst_data_name)
  .jst_check_formula_transforms(formula, .jst_data_name)

  y_name <- all.vars(formula[[2]])
  x_vars <- all.vars(formula[[3]])

  if (length(y_name) != 1) {
    .jst_stop("Only one variable is supported on the left side of ~.\n",
         "  Example: jplot(WellbeingScore ~ Income, community)")
  }
  if (length(x_vars) > 1) {
    .jst_stop("Only one predictor is supported in the formula.\n",
         "For multi-variable regression, fit with jlm() and plot the result:\n",
         "  m <- jlm(", .jst_term_text(formula),
         if (!isTRUE(.jst_default_used)) paste0(", ", .jst_data_name),
         ")\n",
         "  jplot(m)")
  }
  x_name <- x_vars[1]


  # -- Handle by argument ----------------------------------------------------
  # by_expr is the result of substitute(by) from the caller — either NULL
  # (default), a symbol like `Gender`, or a complex expression.
  by_name <- NULL
  has_by  <- !is.null(by_expr) && !identical(by_expr, as.name("NULL"))
  if (has_by) {
    by_name <- paste(deparse(by_expr), collapse = "")
  }

  # -- Validate variables exist ---------------------------------------------
  check_names <- c(y_name, x_name)
  if (has_by) check_names <- c(check_names, by_name)
  .jst_check_vars(data, check_names, .jst_data_name, default_used = .jst_default_used)

  # -- Per-call classification overrides (formula form) ---------------------
  # Same semantics as the variable-list form: numeric=/categorical=/count=
  # assert a plotted variable's class, which here decides scatter-vs-box (and
  # guards the numeric-DV requirement). count is numeric-like for geometry.
  # Scoped to the two formula variables (DV and IV); not the by= variable.
  # Names bare or in quotes, read without evaluating a bare name (ruling
  # R18; Fix Slate 23, Session 377).
  .name_args  <- .jst_model_name_args(name_subs, parent_env, data,
                                      .jst_data_name, example = x_name,
                                      default_used = .jst_default_used)
  numeric     <- .name_args$numeric
  categorical <- .name_args$categorical
  count       <- .name_args$count
  .plot_vars <- c(y_name, x_name)
  for (.arg in c("numeric", "categorical", "count")) {
    .val <- get(.arg)
    if (!is.null(.val)) {
      .bad <- setdiff(.val, .plot_vars)
      if (length(.bad) > 0) {
        .jst_stop(.jst_not_among_text(.arg, .bad,
                                      "the variables in the formula"))
      }
    }
  }
  .jst_check_cat_clash(categorical, numeric, count)
  # Per-variable override role for .jst_is_categorical (NULL when unasserted).
  .ov_for <- function(v) {
    if (v %in% categorical) "categorical"
    else if (v %in% count)  "count"
    else if (v %in% numeric) "numeric"
    else NULL
  }

  # -- Validate line / band arguments ----------------------------------------
  valid_bands <- c("ci", "pi", "see", "none")
  if (!is.character(band) || length(band) != 1 || !band %in% valid_bands) {
    .jst_stop("`band` must be one of: ", paste(sprintf("\"%s\"", valid_bands),
                                          collapse = ", "), ".")
  }
  if (isTRUE(line)) line <- "lm"
  if (!identical(line, FALSE) && !(is.character(line) && length(line) == 1 &&
                                   line %in% c("lm", "loess", "connect"))) {
    .jst_stop("`line` must be FALSE, TRUE, or one of: ",
         "\"lm\", \"loess\", \"connect\".")
  }

  # -- Apply pipeline --------------------------------------------------------
  pipeline <- .jst_apply_pipeline(data, .jst_data_name, .jst_default_used,
                                  subset_expr = subset_expr,
                                  envir = parent_env,
                                  vars = c(all.vars(formula), by_name))
  # A text variable's blank cells plot as one category, <blank> (S340).
  data <- .jst_label_blank_text(pipeline$data)

  # -- Decide plot type from IV's class -------------------------------------
  # Numeric IV -> scatter; categorical IV -> box (numeric DV is required).
  y_is_num <- !.jst_is_categorical(data[[y_name]], y_name, .jst_data_name,
                                   override = .ov_for(y_name))
  x_is_cat <-  .jst_is_categorical(data[[x_name]], x_name, .jst_data_name,
                                   override = .ov_for(x_name))
  # Ruling R38 (Session 391): an unasserted labelled variable the
  # variable-list form draws as bars is read as groups on the right of the
  # formula, for the plot only, so jplot(WellbeingScore ~ Region, d) draws
  # the boxplot, where it drew a scatter of Region's codes. The left side
  # stays the y axis's numbers; numeric = Region, a jnumeric() or jcount()
  # registration, or a type = given keeps the plot as before, and so does
  # line =, band =, equation = or r2 =, which only a scatterplot draws.
  fit_args <- intersect(c("line", "band", "equation", "r2"),
                        names(jplot_call))
  if (is.null(type) && !x_is_cat && length(fit_args) == 0L &&
      .jst_plot_discrete_redirect(data[[x_name]], x_name, .jst_data_name,
                                  identical(.ov_for(x_name), "numeric") ||
                                    identical(.ov_for(x_name), "count"))) {
    x_is_cat <- TRUE
  }

  if (!is.null(type)) {
    resolved_type <- type
  } else {
    if (!y_is_num) {
      .jst_stop("the outcome (left of ~) must be numeric.\n\"", y_name,
                "\" is categorical.", fn = "jplot")
    }
    resolved_type <- if (x_is_cat) "box" else "scatter"
  }

  # Classify both vars for downstream builders (the x as decided above,
  # ruling R38's reading included)
  var_types <- c(
    if (x_is_cat) "categorical" else "numeric",
    if (.jst_is_categorical(data[[y_name]], y_name, .jst_data_name,
                            override = .ov_for(y_name)))
      "categorical" else "numeric"
  )
  # Note: for builders, variable_names is ordered (x, y) for scatter,
  # (x, y) for box (builder detects numeric side via var_types).
  variable_names <- c(x_name, y_name)

  # -- Capture axis labels BEFORE factor conversion -------------------------
  # Variable label display mode (see jplot.default): "labels" puts the
  # variable's label on each axis/legend title, otherwise its name. Labels
  # by default since Session 415 (the S412 audit's F4), as in jplot.default.
  vlmode <- if (is.null(labels)) "labels" else .jst_resolve_variable_id(labels)
  axis_labels <- stats::setNames(
    vapply(variable_names,
           function(v) if (identical(vlmode, "labels")) {
             .jst_plot_label(data[[v]], v)
           } else {
             v
           },
           character(1)),
    variable_names
  )
  by_label <- if (has_by) {
    if (identical(vlmode, "labels")) .jst_plot_label(data[[by_name]], by_name) else by_name
  } else NULL

  # -- Red title -------------------------------------------------------------
  plot_title <- .jst_plot_title(resolved_type, c(y_name, x_name), by_name)
  # For formula form, write the title as "Scatterplot: Tattoos and Age" where
  # DV comes first for readability even though x-axis is Age.
  # .jst_plot_title already puts the two names with " and " between them.
  .cat_red(paste0(plot_title, "\n"))

  if (.jst_default_used) .jst_default_note(.jst_data_name)
  .jst_print_msgs(pipeline$msgs)
  # The cases the plot draws, and how many it leaves out (Session 349).
  n_plot <- .jst_plot_n_line(data, c(x_name, y_name, if (has_by) by_name),
                             pipeline$pipeline_counts$n_original)
  # A variable drawn on a numeric scale holding Inf or -Inf (Session 394),
  # as in jplot.default().
  .jst_plot_infinite_stop(data, c(x_name, y_name, if (has_by) by_name),
                          variable_names[var_types == "numeric"],
                          resolved_type, .jst_data_name)

  # -- Convert haven-labelled variables by their resolved class -------------
  # Geometry-aware, mirroring jplot.default: a categorical-typed variable
  # becomes a factor (so a box's x-axis shows its value labels); a numeric-
  # typed variable is reduced to its underlying numeric (so scatter points and
  # a box's numeric y-axis get a continuous aesthetic). Keying off var_types --
  # not the presence of value labels -- keeps conversion and geometry
  # consistent; the old label-led rule factored any labelled variable that
  # carried labels, which factorised a labelled continuous DV and made the
  # scatter/box error on a discrete axis. variable_names and var_types are both
  # ordered (x, y), so positional indexing aligns. Index with [[i]] (drops any
  # name) so identical() matches even if var_types is ever built named.
  # The default title and the variables shown without a label (rulings R69
  # and R72), read before the variables are made factors.
  frame <- .jst_plot_frame_facts(
    data, resolved_type,
    shown = c(x_name, y_name, if (has_by) by_name),
    categorical = c(if (x_is_cat) x_name, if (has_by) by_name),
    title = .jst_plot_default_title(resolved_type, data, variable_names,
                                    if (has_by) by_name, formula = TRUE),
    pipeline_counts = pipeline$pipeline_counts, data_name = .jst_data_name)

  data <- .jst_plot_convert_labelled(data, variable_names, var_types,
                                     by_name, has_by)

  if (vlmode %in% c("legend", "legend.bottom")) {
    .print_var_labels(data, check_names)
  }

  # -- Ignored-argument note (e.g. band = ... without line = "lm") ----------
  .jst_plot_ignored_note(jplot_call, resolved_type, line)

  # -- Dispatch to builder --------------------------------------------------
  look <- .jst_plot_look_now()
  p <- switch(
    resolved_type,
    scatter = .jst_build_scatter(data, variable_names, by_name,
                                 line, equation, r2, band,
                                 axis_labels, by_label, look = look),
    box     = .jst_build_box(data, variable_names, var_types, by_name,
                             axis_labels, by_label, look = look)
  )
  p <- .jst_plot_finish_built(p, resolved_type, n_plot, frame, look)

  print(p)
  invisible(p)
}


# -- The chart look (Capability Slate U's charts, build 2) --------------------
#
# A chart is drawn in a STYLE's look (ruling R64, Session 411): the [plot]
# section of the session's publication style -- joptions(style = ), apa when
# none is set -- or of the call's style =. Both built-ins draw in greys, Arial
# 10 on white, bars from zero; apa with both axis lines, no gridlines and the
# legend on the right; report with light horizontal gridlines, the x axis line
# alone and the legend at the top, starting at the left. The Plots pane shows
# the look the Word file gets (ruling R47's principle). A chart jplot() draws
# carries the frame's facts -- its kind, N, title, data and labels -- and the
# class "jst_plot" before ggplot2's (the S412 audit's F6, Session 413), so
# jtable() tells it from a chart drawn in ggplot2 by hand (ruling R71).

# The look of the chart being drawn: set by jplot()'s methods for the length
# of a call, read by every builder, and by jlm()'s diagnostics, which draw
# without jplot() and take the session's style.
.jst_plot_env <- new.env(parent = emptyenv())

#' Internal helper: a style's chart look
#'
#' The \code{[plot]} settings of a style, resolved as jtable() resolves a style: the
#' call's \code{style =}, else \code{joptions(style = )}, else apa. A setting
#' the \code{[plot]} section leaves out comes from the same layer's general part
#' before the next layer (the reference, Part 3.2), so a style file that sets
#' font = for its tables sets its charts' font too, unless its \code{[plot]} section
#' sets one.
#'
#' @param style A style's name or path, a resolved style, or NULL.
#' @param fn The user-facing function, for a style's stops.
#' @return A list: the style's name, each \code{[plot]} setting, and the resolved
#'   style itself (st), which jtable() frames the chart in.
#' @keywords internal
.jst_plot_look <- function(style = NULL, fn = "jplot") {
  st  <- if (inherits(style, "jst_style")) style else .jst_style_resolve(style, fn = fn)
  key <- function(k) .jst_style_key(st, "plot", k)
  ks  <- names(.jst_style_spec$plot)
  out <- stats::setNames(lapply(ks, key), ks)
  out$size   <- as.numeric(out$size)
  out$width  <- as.numeric(out$width)
  out$height <- as.numeric(out$height)
  out$resolution <- as.numeric(out$resolution)
  c(list(style = st$name), out, list(st = st))
}

#' Internal helper: set the look of the chart being drawn
#'
#' @param look A look (\code{.jst_plot_look()}), or NULL to clear it.
#' @return The look that was set before, invisibly, for
#'   \code{.jst_plot_look_restore()}.
#' @keywords internal
.jst_plot_look_set <- function(look) {
  old <- if (exists("look", envir = .jst_plot_env, inherits = FALSE)) {
    get("look", envir = .jst_plot_env)
  }
  assign("look", look, envir = .jst_plot_env)
  invisible(old)
}

#' Internal helper: put back the look that was set before
#'
#' @param old What \code{.jst_plot_look_set()} returned.
#' @keywords internal
.jst_plot_look_restore <- function(old) {
  if (is.null(old)) {
    if (exists("look", envir = .jst_plot_env, inherits = FALSE)) {
      rm("look", envir = .jst_plot_env)
    }
  } else {
    assign("look", old, envir = .jst_plot_env)
  }
  invisible(NULL)
}

#' Internal helper: the look of the chart being drawn
#'
#' The look jplot() set for its call; a chart drawn outside one -- jlm()'s
#' diagnostics plots -- takes the session's publication style.
#' @keywords internal
.jst_plot_look_now <- function() {
  look <- if (exists("look", envir = .jst_plot_env, inherits = FALSE)) {
    get("look", envir = .jst_plot_env)
  }
  if (is.null(look)) look <- .jst_plot_look(NULL)
  look
}

#' Internal helper: the font family R draws a style's font with
#'
#' Arial and its kin draw as R's "sans" family, which is Arial on Windows
#' and Helvetica, of the same widths, on a Mac; Times New Roman and its kin
#' as "serif"; Courier New as "mono". So the built-ins draw on every device,
#' the PDF device R CMD check and a script use among them. Any other face is
#' passed by name, where a device can find it: the PDF and PostScript devices
#' know only their own fonts, so there it is drawn as "sans"; Windows'
#' devices need the face named in R's font table, which is done here once
#' for the session.
#'
#' @param font Character(1), the style's font.
#' @param device NULL for the device a plot will be drawn on now, or the
#'   name of the device it will be drawn on ("png", "pdf", "postscript").
#' @return Character(1), a font family.
#' @keywords internal
.jst_plot_family <- function(font, device = NULL) {
  f <- tolower(trimws(as.character(font)))
  if (f %in% c("arial", "helvetica", "liberation sans", "arimo", "sans")) return("sans")
  if (f %in% c("times new roman", "times", "liberation serif", "tinos", "serif")) {
    return("serif")
  }
  if (f %in% c("courier new", "courier", "liberation mono", "cousine", "mono")) {
    return("mono")
  }
  dev <- if (!is.null(device)) device else if (grDevices::dev.cur() > 1L) {
    names(grDevices::dev.cur())
  } else {
    d <- getOption("device")
    if (is.character(d)) d[1L] else if (identical(d, grDevices::pdf)) "pdf" else ""
  }
  if (tolower(dev) %in% c("pdf", "postscript")) {
    db <- if (tolower(dev) == "pdf") grDevices::pdfFonts() else grDevices::postscriptFonts()
    return(if (font %in% names(db)) font else "sans")
  }
  if (identical(.Platform$OS.type, "windows")) {
    wf <- get("windowsFonts", envir = asNamespace("grDevices"))
    if (!font %in% names(wf())) {
      one <- list(get("windowsFont", envir = asNamespace("grDevices"))(font))
      names(one) <- font
      do.call(wf, one)
    }
  }
  font
}

#' Internal helper: a chart's theme in a style's look
#'
#' White, its text black in the style's font and size, the axis lines and
#' gridlines the style names, the legend where it says with its title
#' (ruling R64). Every chart jplot() draws takes it, the diagnostics plots
#' included.
#'
#' @param look A look; the chart being drawn's when NULL.
#' @param device As \code{.jst_plot_family()}.
#' @return A complete ggplot2 theme.
#' @keywords internal
.jst_plot_theme <- function(look = NULL, device = NULL) {
  if (is.null(look)) look <- .jst_plot_look_now()
  fam  <- .jst_plot_family(look$font, device)
  ink  <- "#000000"
  grid <- ggplot2::element_line(colour = paste0("#", look$grid.color), linewidth = 0.4)
  th <- ggplot2::theme_classic(base_size = look$size, base_family = fam) +
    ggplot2::theme(
      text               = ggplot2::element_text(colour = ink),
      axis.text          = ggplot2::element_text(colour = ink),
      axis.line          = ggplot2::element_line(colour = ink, linewidth = 0.4),
      axis.ticks         = ggplot2::element_line(colour = ink, linewidth = 0.4),
      panel.grid.major.y = if (look$gridlines %in% c("horizontal", "both")) grid
                           else ggplot2::element_blank(),
      panel.grid.major.x = if (look$gridlines %in% c("vertical", "both")) grid
                           else ggplot2::element_blank(),
      panel.grid.minor   = ggplot2::element_blank(),
      panel.background   = ggplot2::element_rect(fill = "white", colour = NA),
      plot.background    = ggplot2::element_rect(fill = "white", colour = NA),
      legend.position    = look$legend.position,
      legend.justification = if (look$legend.position %in% c("top", "bottom")) "left"
                             else "center",
      legend.title       = ggplot2::element_text(colour = ink),
      plot.title         = ggplot2::element_text(face = "bold", colour = ink),
      plot.title.position = "plot",
      strip.background   = ggplot2::element_blank(),
      strip.text         = ggplot2::element_text(face = "bold", colour = ink))
  if (look$axis.lines %in% c("x", "none")) {
    th <- th + ggplot2::theme(axis.line.y = ggplot2::element_blank(),
                              axis.ticks.y = ggplot2::element_blank())
  }
  if (look$axis.lines %in% c("y", "none")) {
    th <- th + ggplot2::theme(axis.line.x = ggplot2::element_blank(),
                              axis.ticks.x = ggplot2::element_blank())
  }
  th
}

#' Internal helper: a chart's colors for n series
#'
#' Under greys (both built-ins; ruling R64): 595959 for one series, 404040
#' and A6A6A6 for two, and from 404040 in even steps for more -- to BFBFBF
#' for three or four, to D9D9D9 for five or more, so the lightest stays
#' visible on white. Under a list of colors, the first n in order; past the
#' list's length, colors between them.
#'
#' @param look A look.
#' @param n Integer(1), the series.
#' @return Character, n colors as "#RRGGBB".
#' @keywords internal
.jst_plot_colours <- function(look, n) {
  n <- max(1L, as.integer(n))
  pal <- look$palette
  if (identical(pal, "greys")) {
    if (n == 1L) return("#595959")
    if (n == 2L) return(c("#404040", "#A6A6A6"))
    top <- if (n <= 4L) 0xBF else 0xD9
    v <- round(seq(0x40, top, length.out = n))
    return(sprintf("#%02X%02X%02X", v, v, v))
  }
  cols <- paste0("#", pal)
  if (n <= length(cols)) return(cols[seq_len(n)])
  grDevices::colorRampPalette(cols)(n)
}

# The fixed greys of a model's or a test's plots (ruling R64: every jplot()
# chart in greys, the diagnostics included). A palette colors the charts of
# variables -- bars, histograms, boxes, points by group -- whose series are
# categories; these plots draw one series and their reference lines.
.jst_plot_ink <- list(line  = "#404040",  # a fitted line, a band, an estimate
                      point = "#595959",  # the cases
                      mark  = "#000000",  # a reference line, a labeled case
                      box   = "#D9D9D9")  # a box's fill

#' Internal helper: a fill or color scale in a look's colors
#'
#' Every color a chart of variables draws comes from one of these scales --
#' a single series as a constant mapped to its one color, guide off -- so
#' jtable() can draw the chart again in another style's colors by adding
#' the scale again (\code{.jst_plot_restyle()}).
#'
#' @param aes "fill" or "colour".
#' @param levels Character; the series, in order.
#' @param look A look.
#' @param guide TRUE for a legend.
#' @return A ggplot2 scale.
#' @keywords internal
.jst_plot_scale <- function(aes, levels, look, guide = TRUE) {
  cols <- stats::setNames(.jst_plot_colours(look, length(levels)), levels)
  fun <- if (identical(aes, "fill")) ggplot2::scale_fill_manual
         else ggplot2::scale_colour_manual
  fun(values = cols, breaks = levels, limits = levels,
      guide = if (isTRUE(guide)) "legend" else "none")
}

#' Internal helper: a variable's label for an axis or a legend
#'
#' The variable's label, the name where it has none (the S412 audit's F4,
#' ruled Session 413: a chart's axis and legend titles come from labels, in
#' the Plots pane as in Word, as a table's rows do), whole: a long label is
#' put on two or more lines at about 45 columns, never cut.
#'
#' @param x The variable.
#' @param name Character(1), its name.
#' @return Character(1).
#' @keywords internal
.jst_plot_label <- function(x, name) {
  lbl <- labelled::var_label(x)
  if (is.null(lbl) || length(lbl) == 0 || is.na(lbl[1]) || !nzchar(lbl[1])) {
    return(name)
  }
  .jst_plot_wrap(as.character(lbl[1]))
}

#' Internal helper: a chart's text on lines of about 45 columns
#'
#' A plain fill, word by word, each line kept under the width in display
#' columns (a Chinese, Japanese or Korean character two), a word longer
#' than the width on a line of its own. A chart's text is not a message,
#' so it does not go through the message wrapper, whose rules are for
#' prose (sentences kept whole, a short last line pulled back); and
#' strwrap() belongs to that wrapper alone, which receive_package()'s
#' structural gate checks.
#' @param s Character(1).
#' @param width Integer(1), the columns.
#' @keywords internal
.jst_plot_wrap <- function(s, width = 45L) {
  if (.jst_dw(s) <= width) return(s)
  words <- strsplit(s, " ", fixed = TRUE)[[1L]]
  words <- words[nzchar(words)]
  lines <- character(0)
  cur   <- ""
  for (w in words) {
    cand <- if (nzchar(cur)) paste(cur, w) else w
    if (!nzchar(cur) || .jst_dw(cand) < width) {
      cur <- cand
    } else {
      lines <- c(lines, cur)
      cur   <- w
    }
  }
  paste(c(lines, cur), collapse = "\n")
}

#' Internal helper: does a variable carry a label?
#' @param x The variable.
#' @keywords internal
.jst_plot_has_label <- function(x) {
  lbl <- labelled::var_label(x)
  !(is.null(lbl) || length(lbl) == 0 || is.na(lbl[1]) || !nzchar(lbl[1]))
}

#' Internal helper: the codes a categorical variable shows without a label
#'
#' A variable with value labels on some of its codes and not others shows
#' those others by their codes (ruling R72, the S412 audit's F9): returned
#' for the note jtable() gives. A variable with no value labels at all is
#' not counted here: its values may be what they mean (a count), and a
#' grouping variable's codes are counted where it groups.
#'
#' @param x The variable, before it was made a factor.
#' @param present The codes the chart shows.
#' @return Character; the codes with no label.
#' @keywords internal
.jst_plot_unlabelled_codes <- function(x, present = NULL) {
  vl <- labelled::val_labels(x)
  if (!length(vl)) return(character(0))
  codes <- if (is.null(present)) unique(unclass(x)[!is.na(x)]) else present
  as.character(setdiff(codes, unclass(vl)))
}

#' Internal helper: mark a chart as jplot()'s, with the frame's facts
#'
#' The class "jst_plot" ahead of ggplot2's, so the chart is still a ggplot
#' (\code{p + ggplot2::theme()} works) and jtable() knows it from a chart
#' drawn by hand (the S412 audit's F6, Session 413), and an attribute with
#' what a figure frame needs: the kind of chart, its N (the cases it draws;
#' the S412 audit's F7), its default title (ruling R69), its data for the
#' Excel sheet (ruling R65), the variables it names by name or by code where
#' no label stood (ruling R72), the scales that carry its colors and the look
#' it was drawn in.
#'
#' @param p The ggplot.
#' @param kind Character(1).
#' @param n The N, or NA.
#' @param title Character(1), the default title (labels, never the chart's
#'   kind), or NA.
#' @param data A data frame of what the chart shows, or NULL.
#' @param names_shown Character; variables the chart names by name, having
#'   no label.
#' @param codes_shown A named list: by variable, the codes shown with no
#'   label.
#' @param scales A list of list(aes, levels, guide): the color scales.
#' @param labelled Logical(1); TRUE when any variable the chart shows
#'   carries a label.
#' @param look The look it was drawn in.
#' @param tweak NULL, or a theme setting of the chart's own (the heatmap's
#'   slanted axis text), added again when the chart is drawn in another look.
#' @param filter NULL, or the filters it was drawn under
#'   (\code{.jst_plot_filter_facts()}), for the figure's note.
#' @param data_name The data frame's name as typed, or NULL: the frame
#'   ruling R72's note names in its jrelabel() line.
#' @param rerun What ruling R72's note asks for once labels are added:
#'   "chart" (draw it again) or "analysis" (run the analysis and draw it).
#' @param code_labels By variable of \code{codes_shown}, the codes it does
#'   label (code = label), for the note's jrelabel() line.
#' @return The chart.
#' @keywords internal
.jst_plot_finish <- function(p, kind, n = NA_integer_, title = NA_character_,
                             data = NULL, names_shown = character(0),
                             codes_shown = list(), scales = list(),
                             labelled = FALSE, look = NULL, tweak = NULL,
                             filter = NULL, data_name = NULL, rerun = "chart",
                             code_labels = list()) {
  if (is.null(look)) look <- .jst_plot_look_now()
  attr(p, "jstats_figure") <- list(
    kind = kind, n = n, title = title, data = data,
    names_shown = unique(names_shown), codes_shown = codes_shown,
    scales = scales, labelled = isTRUE(labelled), look = look,
    tweak = tweak, filter = filter, data_name = data_name, rerun = rerun,
    code_labels = code_labels, version = .jst_jstats_version())
  if (!inherits(p, "jst_plot")) class(p) <- c("jst_plot", class(p))
  p
}

#' Internal helper: the facts of a chart jplot() drew
#' @param p A chart.
#' @return The list \code{.jst_plot_finish()} set, or NULL.
#' @keywords internal
.jst_plot_facts <- function(p) {
  f <- attr(p, "jstats_figure", exact = TRUE)
  if (is.list(f)) f else NULL
}

#' Internal helper: draw a jplot() chart again in another style's look
#'
#' At write time (the S412 audit's F6): the chart's theme replaced by the
#' writing style's, its color scales added again in that style's colors,
#' and its look recorded. Everything else the chart holds -- a title or a
#' layer added with \code{+} -- is kept. A chart drawn in that look comes
#' back as it is, so a theme setting the user added with \code{+} -- a font
#' that has Chinese characters, as the guides' Troubleshooting page gives
#' it -- stays in the Word file; in another look the chart takes that look's
#' theme in place of its own. The same look is the same font, size,
#' colors, gridlines, axis lines and legend, with the font drawn as the
#' same family on the device the picture is drawn on.
#'
#' @param p A chart jplot() drew.
#' @param look The writing style's look.
#' @param device As \code{.jst_plot_family()}.
#' @return The chart.
#' @keywords internal
.jst_plot_restyle <- function(p, look, device = NULL) {
  f <- .jst_plot_facts(p)
  if (is.null(f)) return(p)
  keys <- c("font", "size", "palette", "gridlines", "grid.color", "axis.lines",
            "legend.position")
  if (identical(look[keys], f$look[keys]) &&
      identical(.jst_plot_family(look$font, device), .jst_plot_family(look$font))) {
    return(p)
  }
  p <- p + .jst_plot_theme(look, device = device)
  if (!is.null(f$tweak)) p <- p + f$tweak
  if (!identical(look$palette, f$look$palette)) {
    for (s in f$scales) {
      p <- suppressMessages(p + .jst_plot_scale(s$aes, s$levels, look, s$guide))
    }
  }
  attr(p, "jstats_figure")$look <- look
  p
}


# -- Data-first plot helpers ---------------------------------------------------

#' Internal helper: choose an axis label for a variable
#'
#' Returns the variable's label (from labelled::var_label) if one is set and
#' fits within \code{max_len} characters. Truncates with three trailing periods
#' if the label exceeds \code{max_len}. Falls back to the variable name when
#' no label is present. Since Session 390 the length is measured and cut in
#' display columns (\code{.jst_dw()}, \code{.jst_cut_width()}): a Chinese,
#' Japanese or Korean character is about twice as wide as a Latin letter on
#' an axis too, and the count of characters let such a label run to twice
#' the length.
#'
#' @param x A variable (vector), possibly haven-labelled.
#' @param name Character. The variable name to fall back to if no label.
#' @param max_len Integer. Maximum label length before truncation. Default 35.
#' @return A character string suitable for use as an axis label.
#' @keywords internal
.jst_short_label <- function(x, name, max_len = 35) {
  lbl <- labelled::var_label(x)
  if (is.null(lbl) || length(lbl) == 0 || is.na(lbl[1]) || !nzchar(lbl[1])) {
    return(name)
  }
  lbl <- as.character(lbl[1])
  if (.jst_dw(lbl) > max_len) {
    return(paste0(.jst_cut_width(lbl, max_len - 3), "..."))
  }
  lbl
}

#' Internal helper: print a plot's one-line N statement
#'
#' A plot draws the cases that have a value on every variable it plots --
#' each builder keeps the complete cases of its columns -- after the
#' pipeline's filters. Until Session 349 jplot() said nothing of the cases
#' it left out (the S316 item): under \code{jsubset(clinic, Condition !=
#' 3)} a grouped histogram of Flourishing by Medication printed only its
#' title, where \code{jt()} on the same data states Analysis N 51. The
#' statement is the listwise layout's N line (the CPS reference, Table 4),
#' in the slot it takes there -- under the title and the notes, one blank
#' line before and one after -- with the excluded count beside it whenever
#' the plot drew fewer cases than the data frame holds: "Analysis N: 51
#' (19 Excluded)". It is the only Case Processing a plot prints, at every
#' output level (Jeff's lean, okayed S336: the N statement, not the
#' table).
#'
#' @param data The frame the plot is drawn from, after the pipeline.
#' @param vars Character; the variables the plot draws, its \code{by}
#'   variable included.
#' @param n_original Integer; the data frame's rows before the pipeline.
#' @return The cases drawn, invisibly (a figure's N since Session 415, the
#'   S412 audit's F7); prints the line.
#' @keywords internal
.jst_plot_n_line <- function(data, vars, n_original) {
  vars  <- intersect(unique(vars), names(data))
  n_plot <- if (length(vars) == 0L) nrow(data) else
    sum(stats::complete.cases(data[, vars, drop = FALSE]))
  n_exc <- n_original - n_plot
  cat("\nAnalysis N: ", n_plot,
      if (isTRUE(n_exc > 0L)) paste0(" (", n_exc, " Excluded)"),
      "\n\n", sep = "")
  invisible(n_plot)
}

#' Internal helper: jplot()'s stop on infinite values it cannot draw
#'
#' Session 394 (the (S392) infinite-value item). A histogram, a density
#' plot, a scatterplot and a box plot's numeric side cannot place Inf or
#' -Inf: ggplot2 left the case out under its "Removed 1 rows containing
#' non-finite values" warning, while the N line above counted it. The
#' analyses' stop (\code{.jst_stop_infinite()}) on the cases the N line
#' counts, for the variables drawn on a numeric scale. A bar chart draws a
#' value as a category, -Inf among them, and is not stopped.
#'
#' @param data The frame the plot is drawn from, after the pipeline.
#' @param drawn Character; every variable the plot draws (the N line's).
#' @param numeric_vars Character; those drawn on a numeric scale.
#' @param type Character(1); the resolved plot type.
#' @param data_name Character or NULL; the data frame's name.
#' @return Invisibly NULL, or never returns.
#' @keywords internal
.jst_plot_infinite_stop <- function(data, drawn, numeric_vars, type,
                                    data_name) {
  if (!type %in% c("histogram", "density", "scatter", "box") ||
      length(numeric_vars) == 0L) {
    return(invisible(NULL))
  }
  drawn <- intersect(unique(drawn), names(data))
  rows  <- if (length(drawn) == 0L) rep(TRUE, nrow(data)) else
    stats::complete.cases(data[, drawn, drop = FALSE])
  .jst_stop_infinite(data[rows, , drop = FALSE], numeric_vars, data_name,
                     what = "the plot cannot show")
}

#' Internal helper: build a red-title string for jplot.default output
#'
#' Produces titles like:
#' \itemize{
#'   \item Histogram: Age
#'   \item Bar Chart: Gender
#'   \item Scatterplot: Age and Tattoos
#'   \item Boxplot: Age by Gender
#'   \item Grouped Bar Chart: Program and Employment
#' }
#' Appends " by <by_name>" when a by-variable is supplied.
#' Uses variable names (not labels), matching the user's typed call.
#'
#' A facet variable (Session 378) adds ", one panel per <facet_name>".
#'
#' @param plot_type Character, one of the valid resolved types.
#' @param variable_names Character vector of 1 or 2 variable names.
#' @param by_name Optional character string for the by-variable.
#' @param facet_name Optional character string for the facet variable.
#' @keywords internal
.jst_plot_title <- function(plot_type, variable_names, by_name = NULL,
                            facet_name = NULL) {
  prefix <- switch(
    plot_type,
    histogram   = "Histogram",
    density     = "Density Plot",
    bar         = "Bar Chart",
    scatter     = "Scatterplot",
    box         = "Boxplot",
    grouped_bar = "Grouped Bar Chart",
    "Plot"
  )
  body <- if (length(variable_names) == 1) {
    variable_names[1]
  } else {
    paste(variable_names[1], "and", variable_names[2])
  }
  out <- if (!is.null(by_name)) {
    paste0(prefix, ": ", body, " by ", by_name)
  } else {
    paste0(prefix, ": ", body)
  }
  if (!is.null(facet_name)) out <- paste0(out, ", one panel per ", facet_name)
  out
}


#' Internal helper: a labelled variable jplot() draws as categories
#'
#' The display redirect (display only; it never changes how an analysis
#' classifies the variable, under classification Rule B). An unasserted
#' haven-labelled variable reads as a number, which drew a histogram that
#' errored on its discrete axis; when the structural detector finds it
#' discrete (.jst_is_discrete_integer()), jplot() draws it as categories.
#' Since Session 391 (ruling R38; Jeff: "Your recommendation") it applies to
#' each of two variables in the variable-list form and to the right side of
#' a formula, where only one variable had been redirected: jplot(d, Region,
#' OwnsHome) draws the grouped bar chart and jplot(WellbeingScore ~ Region,
#' d) the boxplot, where both drew scatters of the codes. A numeric = or
#' count = assertion, and a jnumeric() or jcount() registration, keep the
#' number; the callers also skip it for two variables when a type = or one
#' of the scatter plot's own arguments (line, band, equation, r2) is given,
#' and the variable-list form's scatter stop carries the call's numeric =,
#' count = or type = into its line when its IV is such a variable.
#'
#' @param col The variable, after the pipeline.
#' @param v Character(1). Its name.
#' @param data_name Character(1) or NULL. The data frame's name, for the
#'   registrations.
#' @param asserted_numeric Logical(1). TRUE when numeric = or count = names
#'   it.
#' @return Logical(1).
#' @keywords internal
.jst_plot_discrete_redirect <- function(col, v, data_name, asserted_numeric) {
  if (isTRUE(asserted_numeric)) return(FALSE)
  intent <- if (!is.null(data_name)) .jst_get_intent(data_name, v) else NULL
  if (!is.null(intent) && intent$kind %in% c("numeric", "count")) return(FALSE)
  inherits(col, "haven_labelled") &&
    .jst_is_discrete_integer(col, v, data_name)
}

#' Internal helper: auto-detect plot type from variable types
#'
#' @keywords internal
.jst_auto_plot_type <- function(var_types, n_vars) {
  if (n_vars == 1) {
    if (var_types[1] == "numeric") return("histogram")
    return("bar")
  }
  # n_vars == 2
  if (all(var_types == "numeric"))      return("scatter")
  if (all(var_types == "categorical"))  return("grouped_bar")
  return("box")
}


#' Internal helper: format the equation subtitle for a bivariate regression
#'
#' Uses variable names rather than y/x for pedagogical clarity.
#'
#' @keywords internal
.jst_format_bivar_equation <- function(model, y_name, x_name,
                                       include_r2 = TRUE) {
  coefs     <- stats::coef(model)
  intercept <- coefs[1]
  slope     <- coefs[2]
  # A plain hyphen for a negative slope (Session 360): pdf() on macOS and
  # Linux, whose character set is Latin-1, warned and dropped the minus
  # sign; ggplot2's own axis labels use the hyphen too.
  sign_char <- if (slope >= 0) "+" else "-"
  eq <- sprintf("%s = %.2f %s %.2f\u00b7%s",
                y_name, intercept, sign_char, abs(slope), x_name)
  if (include_r2) {
    r2 <- summary(model)$r.squared
    eq <- paste0(eq, "    R\u00b2 = ", sprintf("%.3f", r2))
  }
  eq
}


#' Internal helper: a chart's scales, added in a look's colors
#'
#' @param p The ggplot.
#' @param scales A list of list(aes, levels, guide).
#' @param look A look.
#' @return The ggplot.
#' @keywords internal
.jst_plot_add_scales <- function(p, scales, look) {
  for (s in scales) p <- p + .jst_plot_scale(s$aes, s$levels, look, s$guide)
  p
}

#' Internal helper: a value axis that starts at zero
#'
#' Bars and a histogram's bins stand on the axis line (ruling R64: "bars
#' from zero"), with room above the tallest for its value. An axis of
#' counts is marked in whole numbers only (Session 415): ggplot2's own
#' breaks put 2.5 and 7.5 on a histogram's Count axis.
#' @param count TRUE for an axis of counts.
#' @keywords internal
.jst_plot_zero_y <- function(count = FALSE) {
  if (count) {
    ggplot2::scale_y_continuous(expand = ggplot2::expansion(mult = c(0, 0.08)),
                                breaks = .jst_plot_whole_breaks)
  } else {
    ggplot2::scale_y_continuous(expand = ggplot2::expansion(mult = c(0, 0.08)))
  }
}

#' Internal helper: whole-number breaks for an axis of counts
#' @param lims The axis limits ggplot2 passes.
#' @keywords internal
.jst_plot_whole_breaks <- function(lims) {
  lims <- lims[is.finite(lims)]
  if (length(lims) < 2L) return(numeric(0))
  b <- pretty(lims, n = 5L)
  b[abs(b - round(b)) < 1e-8]
}

#' Internal helper: the levels a factor shows
#' @param f A factor, or a vector made one.
#' @keywords internal
.jst_plot_levels <- function(f) {
  if (!is.factor(f)) f <- factor(f)
  levels(droplevels(f))
}

#' Internal helper: a builder's chart, with the scales that carry its colors
#' @param p The ggplot.
#' @param scales The scales (\code{.jst_plot_add_scales()}).
#' @param data The numbers it shows, for the Excel sheet, or NULL.
#' @keywords internal
.jst_plot_built <- function(p, scales, data = NULL) {
  attr(p, "jst_built") <- list(scales = scales, data = data)
  p
}

#' Internal helper: the cases a chart draws, for its Excel sheet
#'
#' A histogram, a density plot, a scatterplot and a box plot draw cases,
#' so their sheet (ruling R65, the \code{[plot]} section's data.file) holds the
#' values each case is drawn at, one row per case, each column named by
#' its variable: a category as the chart labels it, a number as the
#' number.
#'
#' @param df The builder's frame (columns x, y, by, facet).
#' @param names Named character: the variable each column shows; a NULL
#'   entry drops out.
#' @return A data frame.
#' @keywords internal
.jst_plot_case_sheet <- function(df, names) {
  names <- unlist(names)
  keep <- intersect(names(names), names(df))
  out <- lapply(keep, function(k) {
    v <- df[[k]]
    if (is.factor(v)) as.character(v)
    else if (inherits(v, "haven_labelled")) as.numeric(unclass(v))
    else if (is.numeric(v) || is.character(v) || is.logical(v)) as.vector(v)
    else as.character(v)
  })
  structure(stats::setNames(out, make.unique(unname(names[keep]))),
            class = "data.frame", row.names = seq_len(nrow(df)))
}

#' Internal helper: the values on a chart's bars
#'
#' Each bar's count just beyond its end (ruling R70): on a chart of one
#' series under the style's values = yes, on a chart of several series --
#' dodged side by side -- under values.grouped = yes. Whole numbers, in the
#' chart's font at its axis labels' size.
#'
#' @param look A look.
#' @param grouped Logical(1): several series, dodged.
#' @param group_var The variable the bars are dodged by ("by" or "fill").
#' @return A ggplot2 layer, or NULL when the style shows no values.
#' @keywords internal
.jst_plot_value_layer <- function(look, grouped = FALSE, group_var = NULL) {
  on <- if (grouped) identical(look$values.grouped, "yes") else identical(look$values, "yes")
  if (!on) return(NULL)
  size <- look$size * 0.8 / ggplot2::.pt
  fam  <- .jst_plot_family(look$font)
  if (grouped) {
    ggplot2::geom_text(
      stat = "count",
      ggplot2::aes(label = ggplot2::after_stat(!!as.symbol("count")),
                   group = .data[[group_var]]),
      position = ggplot2::position_dodge(width = 0.8), vjust = -0.4,
      size = size, family = fam, colour = "#000000")
  } else {
    ggplot2::geom_text(
      stat = "count",
      ggplot2::aes(label = ggplot2::after_stat(!!as.symbol("count"))),
      vjust = -0.4, size = size, family = fam, colour = "#000000")
  }
}

#' Internal helper: the counts a bar chart shows, for its Excel sheet
#'
#' @param plot_df The builder's data: x, and by, fill or facet.
#' @param x_name,by_name,facet_name The variables' names, for the heads.
#' @param by_col The column of the series ("by" or "fill"), or NULL.
#' @return A data frame: the categories, each series and panel, n, and the
#'   percentage of the cases drawn (of each series' cases where there are
#'   several).
#' @keywords internal
.jst_plot_count_sheet <- function(plot_df, x_name, by_name = NULL,
                                  facet_name = NULL, by_col = NULL) {
  cols <- c("x", by_col, if (!is.null(facet_name)) "facet")
  tab  <- as.data.frame(table(plot_df[cols]), responseName = "n",
                        stringsAsFactors = FALSE)
  grp  <- setdiff(cols, "x")
  tot  <- if (length(grp)) stats::ave(tab$n, tab[grp], FUN = sum) else sum(tab$n)
  # One total for every row when there is no series: ifelse() gives a
  # result as long as its test, so a single total gave every row the first
  # row's percentage (found on the S415 walk).
  tot  <- rep_len(tot, nrow(tab))
  tab$Percent <- ifelse(tot > 0, 100 * tab$n / tot, NA_real_)
  names(tab)[names(tab) == "x"] <- x_name
  if (!is.null(by_col)) names(tab)[names(tab) == by_col] <- by_name
  if (!is.null(facet_name)) names(tab)[names(tab) == "facet"] <- facet_name
  tab
}

#' Internal helper: build histogram (1 numeric variable)
#'
#' One series in the look's one color; by groups laid over each other in
#' its colors for that many; bins standing on the axis (ruling R64). A
#' builder returns the chart with the scales that carry its colors
#' (\code{.jst_plot_built()}).
#'
#' @keywords internal
#' @importFrom rlang .data
.jst_build_histogram <- function(data, x_name, by_name = NULL,
                                 axis_labels = NULL, by_label = NULL,
                                 facet_name = NULL, look = .jst_plot_look_now()) {
  # A haven-labelled column is discrete on the x axis, so geom_histogram()
  # errors ("requires a continuous x aesthetic"). Strip the labels to the
  # underlying numeric for plotting -- declared missing codes have already
  # been converted to NA by the analysis pipeline before this point, so
  # as.numeric() yields the clean values. Handles both haven_labelled and
  # haven_labelled_spss. The geometry redirect in jplot() already sends most
  # labelled small-range variables to a bar; this is the safety net for any
  # that still route here (an explicit numeric=/count= or a labelled
  # continuous variable like a coded income).
  x_col <- data[[x_name]]
  if (inherits(x_col, "haven_labelled")) x_col <- as.numeric(x_col)
  plot_df <- data.frame(x = x_col)
  if (!is.null(by_name)) plot_df$by <- data[[by_name]]
  if (!is.null(facet_name)) plot_df$facet <- data[[facet_name]]

  plot_df <- plot_df[stats::complete.cases(plot_df), , drop = FALSE]

  x_lab  <- if (!is.null(axis_labels)) axis_labels[[x_name]] else x_name
  by_lab <- if (!is.null(by_label)) by_label else by_name

  if (is.null(by_name)) {
    sc <- list(list(aes = "fill", levels = "1", guide = FALSE))
    p <- ggplot2::ggplot(plot_df, ggplot2::aes(x = .data$x, fill = "1")) +
      ggplot2::geom_histogram(bins = 30, color = "white") +
      ggplot2::labs(x = x_lab, y = "Count")
  } else {
    sc <- list(list(aes = "fill", levels = .jst_plot_levels(plot_df$by), guide = TRUE))
    p <- ggplot2::ggplot(plot_df, ggplot2::aes(x = .data$x,
                                                fill = .data$by)) +
      ggplot2::geom_histogram(bins = 30, color = "white", alpha = 0.6,
                              position = "identity") +
      ggplot2::labs(x = x_lab, y = "Count", fill = by_lab)
  }
  p <- .jst_plot_add_scales(p, sc, look) + .jst_plot_zero_y(count = TRUE) +
    .jst_plot_theme(look)
  .jst_plot_built(.jst_plot_facets(p, facet_name), sc,
                  .jst_plot_case_sheet(plot_df, c(x = x_name, by = by_name,
                                                  facet = facet_name)))
}


#' Internal helper: build a density plot (1 numeric variable)
#'
#' The alternative to the histogram (Capability Slate C3, Session 378):
#' the variable's kernel density estimate, one curve, or one per group of
#' \code{by =} laid over each other, and one panel per group of
#' \code{facet =}. Never the automatic choice: \code{type = "density"}
#' asks for it. In the look's colors since Session 415.
#'
#' @keywords internal
#' @importFrom rlang .data
.jst_build_density <- function(data, x_name, by_name = NULL,
                               axis_labels = NULL, by_label = NULL,
                               facet_name = NULL, look = .jst_plot_look_now()) {
  x_col <- data[[x_name]]
  if (inherits(x_col, "haven_labelled")) x_col <- as.numeric(x_col)
  plot_df <- data.frame(x = x_col)
  if (!is.null(by_name)) plot_df$by <- data[[by_name]]
  if (!is.null(facet_name)) plot_df$facet <- data[[facet_name]]

  plot_df <- plot_df[stats::complete.cases(plot_df), , drop = FALSE]

  x_lab  <- if (!is.null(axis_labels)) axis_labels[[x_name]] else x_name
  by_lab <- if (!is.null(by_label)) by_label else by_name

  if (is.null(by_name)) {
    sc <- list(list(aes = "fill", levels = "1", guide = FALSE),
               list(aes = "colour", levels = "1", guide = FALSE))
    p <- ggplot2::ggplot(plot_df, ggplot2::aes(x = .data$x, fill = "1",
                                                colour = "1")) +
      ggplot2::geom_density(alpha = 0.35, linewidth = 0.8) +
      ggplot2::labs(x = x_lab, y = "Density")
  } else {
    lv <- .jst_plot_levels(plot_df$by)
    sc <- list(list(aes = "fill", levels = lv, guide = TRUE),
               list(aes = "colour", levels = lv, guide = TRUE))
    p <- ggplot2::ggplot(plot_df, ggplot2::aes(x = .data$x,
                                                fill = .data$by,
                                                color = .data$by)) +
      ggplot2::geom_density(alpha = 0.3, linewidth = 0.8) +
      ggplot2::labs(x = x_lab, y = "Density", fill = by_lab,
                    color = by_lab)
  }
  p <- .jst_plot_add_scales(p, sc, look) + .jst_plot_zero_y() +
    .jst_plot_theme(look)
  .jst_plot_built(.jst_plot_facets(p, facet_name), sc,
                  .jst_plot_case_sheet(plot_df, c(x = x_name, by = by_name,
                                                  facet = facet_name)))
}


#' Internal helper: one panel per group (facet =)
#'
#' Adds \code{ggplot2::facet_wrap()} on the builder's \code{facet} column
#' when a facet variable was given (Capability Slate C3, Session 378), and
#' returns the plot as it is otherwise. The column is the facet variable
#' made a factor, its value labels the panel titles.
#'
#' @param p The ggplot.
#' @param facet_name Character(1) or NULL.
#' @return The ggplot.
#' @keywords internal
.jst_plot_facets <- function(p, facet_name) {
  if (is.null(facet_name)) return(p)
  p + ggplot2::facet_wrap(ggplot2::vars(.data$facet))
}

#' Internal helper: build bar chart (1 categorical variable)
#'
#' One series in the look's one color, each bar's count beyond its end
#' (ruling R70); by groups side by side, in the look's colors for that
#' many, their counts shown only under values.grouped = yes. The bars stand
#' on the axis (ruling R64).
#'
#' @keywords internal
#' @importFrom rlang .data
.jst_build_bar <- function(data, x_name, by_name = NULL,
                           axis_labels = NULL, by_label = NULL,
                           facet_name = NULL, look = .jst_plot_look_now()) {
  plot_df <- data.frame(x = data[[x_name]])
  if (!is.null(plot_df$x) && !is.factor(plot_df$x)) {
    plot_df$x <- factor(plot_df$x)
  }
  if (!is.null(by_name)) plot_df$by <- data[[by_name]]
  if (!is.null(facet_name)) plot_df$facet <- data[[facet_name]]

  plot_df <- plot_df[stats::complete.cases(plot_df), , drop = FALSE]

  x_lab  <- if (!is.null(axis_labels)) axis_labels[[x_name]] else x_name
  by_lab <- if (!is.null(by_label)) by_label else by_name

  if (is.null(by_name)) {
    sc <- list(list(aes = "fill", levels = "1", guide = FALSE))
    p <- ggplot2::ggplot(plot_df, ggplot2::aes(x = .data$x, fill = "1")) +
      ggplot2::geom_bar(width = 0.7) +
      .jst_plot_value_layer(look) +
      ggplot2::labs(x = x_lab, y = "Count")
  } else {
    sc <- list(list(aes = "fill", levels = .jst_plot_levels(plot_df$by), guide = TRUE))
    p <- ggplot2::ggplot(plot_df, ggplot2::aes(x = .data$x, fill = .data$by)) +
      ggplot2::geom_bar(position = ggplot2::position_dodge(width = 0.8),
                        width = 0.7) +
      .jst_plot_value_layer(look, grouped = TRUE, group_var = "by") +
      ggplot2::labs(x = x_lab, y = "Count", fill = by_lab)
  }
  p <- .jst_plot_add_scales(p, sc, look) + .jst_plot_zero_y(count = TRUE) +
    .jst_plot_theme(look)
  .jst_plot_built(.jst_plot_facets(p, facet_name), sc,
                  .jst_plot_count_sheet(plot_df, x_name, by_name, facet_name,
                                        if (!is.null(by_name)) "by"))
}


#' Internal helper: build scatterplot (2 numeric variables)
#'
#' The cases, and the line asked for, in the look's one color; by groups,
#' in its colors for that many (Session 415).
#'
#' @keywords internal
#' @importFrom rlang .data
.jst_build_scatter <- function(data, variable_names, by_name,
                               line, equation, r2, band,
                               axis_labels = NULL, by_label = NULL,
                               look = .jst_plot_look_now()) {

  x_name <- variable_names[1]
  y_name <- variable_names[2]

  x_lab  <- if (!is.null(axis_labels)) axis_labels[[x_name]] else x_name
  y_lab  <- if (!is.null(axis_labels)) axis_labels[[y_name]] else y_name
  by_lab <- if (!is.null(by_label)) by_label else by_name

  plot_df <- data.frame(x = data[[x_name]], y = data[[y_name]])
  if (!is.null(by_name)) plot_df$by <- data[[by_name]]
  plot_df <- plot_df[stats::complete.cases(plot_df), , drop = FALSE]

  # Base scatter
  if (is.null(by_name)) {
    sc <- list(list(aes = "colour", levels = "1", guide = FALSE),
               list(aes = "fill", levels = "1", guide = FALSE))
    p <- ggplot2::ggplot(plot_df, ggplot2::aes(x = .data$x, y = .data$y)) +
      ggplot2::geom_point(ggplot2::aes(colour = "1"), alpha = 0.55)
  } else {
    lv <- .jst_plot_levels(plot_df$by)
    sc <- list(list(aes = "colour", levels = lv, guide = TRUE),
               list(aes = "fill", levels = lv, guide = TRUE))
    p <- ggplot2::ggplot(plot_df, ggplot2::aes(x = .data$x, y = .data$y,
                                                color = .data$by)) +
      ggplot2::geom_point(alpha = 0.65)
  }

  # Add line and band
  subtitle_text <- NULL
  if (!identical(line, FALSE)) {

    if (line == "connect") {
      # Simple line connecting points — no band, no equation
      if (is.null(by_name)) {
        p <- p + ggplot2::geom_line(ggplot2::aes(colour = "1"), alpha = 0.7)
      } else {
        p <- p + ggplot2::geom_line(alpha = 0.7)
      }

    } else if (line == "loess") {
      # Loess smoother — no equation, band options apply
      show_se <- !identical(band, "none") && band == "ci"
      if (is.null(by_name)) {
        p <- p + ggplot2::geom_smooth(ggplot2::aes(colour = "1", fill = "1"),
                                      method = "loess", se = show_se,
                                      formula = y ~ x)
      } else {
        p <- p + ggplot2::geom_smooth(ggplot2::aes(fill = .data$by),
                                      method = "loess", se = show_se,
                                      formula = y ~ x)
      }

    } else if (line == "lm") {
      # Linear regression — full treatment
      p <- .jst_add_lm_line(p, plot_df, x_name, y_name, by_name, band)

      # Build equation subtitle
      if (equation || r2) {
        if (is.null(by_name)) {
          m <- stats::lm(y ~ x, data = plot_df)
          eq <- .jst_format_bivar_equation(m, y_name, x_name,
                                           include_r2 = r2)
          if (!equation) {
            # Only R² requested
            subtitle_text <- sprintf("R\u00b2 = %.3f",
                                     summary(m)$r.squared)
          } else {
            subtitle_text <- eq
          }
        } else {
          # Per-group equations
          groups <- levels(droplevels(plot_df$by))
          eq_lines <- character(0)
          for (g in groups) {
            sub <- plot_df[plot_df$by == g, , drop = FALSE]
            if (nrow(sub) >= 2 &&
                length(unique(sub$x)) >= 2) {
              m <- stats::lm(y ~ x, data = sub)
              if (equation) {
                eq <- .jst_format_bivar_equation(
                  m, y_name, x_name, include_r2 = r2
                )
                eq_lines <- c(eq_lines, paste0(g, ": ", eq))
              } else if (r2) {
                eq_lines <- c(eq_lines,
                              sprintf("%s: R\u00b2 = %.3f",
                                      g, summary(m)$r.squared))
              }
            }
          }
          if (length(eq_lines) > 0) {
            subtitle_text <- paste(eq_lines, collapse = "\n")
          }
        }
      }
    }
  }

  p <- p + ggplot2::labs(x = x_lab, y = y_lab,
                         color = by_lab, fill = by_lab,
                         subtitle = subtitle_text)
  p <- .jst_plot_add_scales(p, sc, look) + .jst_plot_theme(look)
  .jst_plot_built(p, sc, .jst_plot_case_sheet(plot_df, c(x = x_name, y = y_name,
                                                         by = by_name)))
}


#' Internal helper: add an lm regression line and optional band to a scatter
#'
#' Handles the four band options: ci (ggplot default), pi (prediction
#' interval, computed manually), see (constant +/- t*SEE rectangle), none.
#' The line and its band take the series' color through the chart's color
#' scales (Session 415).
#'
#' @keywords internal
#' @importFrom rlang .data
.jst_add_lm_line <- function(p, plot_df, x_name, y_name, by_name, band) {

  if (is.null(by_name)) {
    # Single-group line
    show_ci <- identical(band, "ci")
    p <- p + ggplot2::geom_smooth(ggplot2::aes(colour = "1", fill = "1"),
                                  method = "lm", se = show_ci,
                                  formula = y ~ x)

    if (band %in% c("pi", "see")) {
      band_df <- .jst_compute_band(plot_df, band)
      p <- p + ggplot2::geom_ribbon(
        data = band_df,
        ggplot2::aes(x = .data$x, ymin = .data$lwr, ymax = .data$upr,
                     fill = "1"),
        alpha = 0.15,
        inherit.aes = FALSE
      )
    }

  } else {
    # Per-group lines
    show_ci <- identical(band, "ci")
    p <- p + ggplot2::geom_smooth(ggplot2::aes(fill = .data$by),
                                  method = "lm", se = show_ci,
                                  formula = y ~ x)

    if (band %in% c("pi", "see")) {
      groups <- levels(droplevels(plot_df$by))
      band_dfs <- lapply(groups, function(g) {
        sub <- plot_df[plot_df$by == g, , drop = FALSE]
        if (nrow(sub) >= 3 && length(unique(sub$x)) >= 2) {
          band_df <- .jst_compute_band(sub, band)
          band_df$by <- g
          band_df
        } else NULL
      })
      band_df <- do.call(rbind, band_dfs)
      if (!is.null(band_df) && nrow(band_df) > 0) {
        band_df$by <- factor(band_df$by, levels = groups)
        p <- p + ggplot2::geom_ribbon(
          data = band_df,
          ggplot2::aes(x = .data$x, ymin = .data$lwr, ymax = .data$upr,
                       fill = .data$by),
          alpha = 0.12, inherit.aes = FALSE
        )
      }
    }
  }
  p
}


#' Internal helper: compute prediction interval or +/- t*SEE band for a bivariate
#' regression
#'
#' @param plot_df Data frame with columns x and y.
#' @param band Either "pi" or "see".
#' @return Data frame with columns x, fit, lwr, upr.
#' @keywords internal
.jst_compute_band <- function(plot_df, band) {
  m <- stats::lm(y ~ x, data = plot_df)
  x_grid <- seq(min(plot_df$x, na.rm = TRUE),
                max(plot_df$x, na.rm = TRUE), length.out = 120)
  new_df <- data.frame(x = x_grid)

  if (band == "pi") {
    pred <- stats::predict(m, newdata = new_df, interval = "prediction",
                           level = 0.95)
    return(data.frame(x = x_grid,
                      fit = pred[, "fit"],
                      lwr = pred[, "lwr"],
                      upr = pred[, "upr"]))
  }
  if (band == "see") {
    fit_vals <- stats::predict(m, newdata = new_df)
    see <- summary(m)$sigma
    t_crit <- stats::qt(0.975, df = stats::df.residual(m))
    return(data.frame(x = x_grid,
                      fit = fit_vals,
                      lwr = fit_vals - t_crit * see,
                      upr = fit_vals + t_crit * see))
  }
  NULL
}


#' Internal helper: build boxplot (1 numeric + 1 categorical)
#'
#' One series light grey with black lines, the mean a black diamond (the
#' fixed greys of ruling R64); by groups, the boxes in the look's colors
#' for that many.
#'
#' @keywords internal
#' @importFrom rlang .data
.jst_build_box <- function(data, variable_names, var_types, by_name = NULL,
                           axis_labels = NULL, by_label = NULL,
                           look = .jst_plot_look_now()) {

  # Numeric on y, categorical on x
  if (var_types[1] == "numeric") {
    y_name <- variable_names[1]
    x_name <- variable_names[2]
  } else {
    x_name <- variable_names[1]
    y_name <- variable_names[2]
  }

  x_lab  <- if (!is.null(axis_labels)) axis_labels[[x_name]] else x_name
  y_lab  <- if (!is.null(axis_labels)) axis_labels[[y_name]] else y_name
  by_lab <- if (!is.null(by_label)) by_label else by_name

  plot_df <- data.frame(x = data[[x_name]], y = data[[y_name]])
  if (!is.factor(plot_df$x)) plot_df$x <- factor(plot_df$x)
  if (!is.null(by_name)) plot_df$by <- data[[by_name]]
  plot_df <- plot_df[stats::complete.cases(plot_df), , drop = FALSE]

  if (is.null(by_name)) {
    sc <- list()
    p <- ggplot2::ggplot(plot_df, ggplot2::aes(x = .data$x, y = .data$y)) +
      ggplot2::geom_boxplot(fill = .jst_plot_ink$box, color = "#000000",
                            outlier.alpha = 0.6) +
      ggplot2::stat_summary(fun = mean, geom = "point",
                            shape = 18, size = 3, color = .jst_plot_ink$mark) +
      ggplot2::labs(x = x_lab, y = y_lab,
                    subtitle = "Diamond marks the group mean")
  } else {
    sc <- list(list(aes = "fill", levels = .jst_plot_levels(plot_df$by), guide = TRUE))
    p <- ggplot2::ggplot(plot_df, ggplot2::aes(x = .data$x, y = .data$y,
                                                fill = .data$by)) +
      ggplot2::geom_boxplot(outlier.alpha = 0.6) +
      ggplot2::labs(x = x_lab, y = y_lab, fill = by_lab)
  }
  p <- .jst_plot_add_scales(p, sc, look) + .jst_plot_theme(look)
  .jst_plot_built(p, sc, .jst_plot_case_sheet(plot_df, c(x = x_name, y = y_name,
                                                         by = by_name)))
}


#' Internal helper: build grouped bar chart (2 categorical variables)
#'
#' The second variable's categories side by side in the look's colors for
#' that many, their counts shown only under values.grouped = yes (ruling
#' R70: no values on a chart of several series by default); the bars stand
#' on the axis.
#'
#' @keywords internal
#' @importFrom rlang .data
.jst_build_grouped_bar <- function(data, variable_names, axis_labels = NULL,
                                   facet_name = NULL, look = .jst_plot_look_now()) {
  x_name    <- variable_names[1]
  fill_name <- variable_names[2]

  x_lab    <- if (!is.null(axis_labels)) axis_labels[[x_name]] else x_name
  fill_lab <- if (!is.null(axis_labels)) axis_labels[[fill_name]] else fill_name

  plot_df <- data.frame(x = data[[x_name]], fill = data[[fill_name]])
  if (!is.factor(plot_df$x))    plot_df$x    <- factor(plot_df$x)
  if (!is.factor(plot_df$fill)) plot_df$fill <- factor(plot_df$fill)
  if (!is.null(facet_name)) plot_df$facet <- data[[facet_name]]
  plot_df <- plot_df[stats::complete.cases(plot_df), , drop = FALSE]

  sc <- list(list(aes = "fill", levels = .jst_plot_levels(plot_df$fill), guide = TRUE))
  p <- ggplot2::ggplot(plot_df, ggplot2::aes(x = .data$x, fill = .data$fill)) +
    ggplot2::geom_bar(position = ggplot2::position_dodge(width = 0.8),
                      width = 0.7) +
    .jst_plot_value_layer(look, grouped = TRUE, group_var = "fill") +
    ggplot2::labs(x = x_lab, y = "Count", fill = fill_lab)
  p <- .jst_plot_add_scales(p, sc, look) + .jst_plot_zero_y(count = TRUE) +
    .jst_plot_theme(look)
  .jst_plot_built(.jst_plot_facets(p, facet_name), sc,
                  .jst_plot_count_sheet(plot_df, x_name, fill_name, facet_name,
                                        "fill"))
}


# -- Internal helpers for jplot ------------------------------------------------

#' Internal constant: the results jplot() draws through .jst_resolve_which()
#'
#' The classes whose methods read \code{which} against the result's own
#' plot names. jplot()'s generic leaves a bare \code{which} to them
#' (Session 377).
#' @keywords internal
.jst_plot_result_classes <- c("jst_lm", "jst_logistic", "jst_ttest",
                              "jst_anova", "jst_corr", "jst_crosstab")

#' Internal helper: resolve the `which` argument for jplot dispatch methods
#'
#' Translates the user's \code{which} argument into a vector of plot
#' identifiers. Accepts the special values \code{core} and
#' \code{all} (resolved against the supplied \code{core} and
#' \code{all_plots} vectors) or an explicit character vector of plot
#' names. A name it does not take stops in voice Rule A's form, the
#' result named by the function that made it, and the sentence of what
#' \code{which} takes from \code{.jst_takes_names()} (Session 376).
#'
#' A plot name typed without quotes (Fix Slate 23, Session 377) is read
#' here, from the method's call, rather than evaluated: \code{which = vif}
#' had stopped with R's own "object 'vif' not found". A name this result
#' has gets ruling R18's pointer, the call with the name in quotes; a name
#' it does not have gets the plot-name stop, since the pointer's line
#' would stop on it next (ruling R23). The generic's own bare-word check
#' leaves \code{which} to this helper whenever \code{x} is a result, so
#' the set read is this result's, not every result's.
#'
#' @param which The user's \code{which} argument: \code{core},
#'   \code{all}, or a character vector of plot names.
#' @param core Character vector of plot identifiers comprising the
#'   "core" set for this jplot method.
#' @param all_plots Character vector of all valid plot identifiers for
#'   this jplot method.
#' @param class_name Character. The S3 class being dispatched on; the
#'   stop names the function whose result it is.
#' @param explain Optional named character vector: a plot name the method
#'   draws only for some results of its kind, and the stop that says why,
#'   used in place of the plot-name stop when that name is the only one
#'   refused (jcorr()'s scatter plot, which needs two variables).
#'
#' @return A character vector of plot identifiers to produce.
#'
#' @keywords internal
.jst_resolve_which <- function(which, core, all_plots, class_name,
                               explain = NULL) {
  # The expression the method was given for `which`, and what it evaluates
  # to (an error for a name found nowhere; a function for effects or qq
  # where a package defines one).
  ex  <- eval(call("substitute", as.name("which")), parent.frame())
  val <- tryCatch(which, error = function(e) e)
  words <- .jst_bare_words(ex)
  if (!is.null(words) && !is.character(val)) {
    takes_all <- c("core", "all", all_plots)
    hit <- match(tolower(words$words), tolower(takes_all))
    if (anyNA(hit)) {
      which <- words$words
    } else {
      canon <- words$words
      canon[!is.na(hit)] <- takes_all[hit[!is.na(hit)]]
      new <- if (length(canon) == 1L) canon else
        as.call(c(list(as.name("c")), as.list(canon)))
      cl <- sys.call(-1L)
      cl[[1L]] <- as.name("jplot")
      mc <- match.call(jplot, cl)
      named <- !is.null(names(cl)) && "which" %in% names(cl)
      typed <- words$words[words$bare]
      .jst_stop(.jst_and_list(typed),
                if (length(typed) == 1L) " is" else " are",
                " not in quotes.\n",
                if (named) "which = takes a plot name in quotes:"
                else "A plot name goes in quotes:", "\n",
                "  ", .jst_call_with(cl, mc, "which", new), fn = "jplot")
    }
  } else if (inherits(val, "error")) {
    stop(val)
  } else {
    which <- val
  }
  if (is.character(which) && length(which) == 1L && !is.na(which) &&
      which %in% c("core", "all")) {
    return(if (which == "core") core else all_plots)
  }
  # The stop in voice Rule A's form, as the diagnostics stop gives it
  # (Session 376; it read "Invalid plot name for class 'jst_lm': ...",
  # R's class name and single quotes). The result named by the function
  # that made it.
  maker <- c(jst_lm = "jlm", jst_logistic = "jlogistic", jst_ttest = "jt",
             jst_anova = "jaov", jst_corr = "jcorr",
             jst_crosstab = "jcrosstab")[class_name]
  owner <- if (is.na(maker)) "this result" else paste0("a ", maker, "() result")
  takes <- .jst_takes_names("which", all_plots,
                            lead = c("\"core\"", "\"all\""))
  if (!is.character(which) || length(which) == 0L || anyNA(which)) {
    .jst_stop(takes, fn = "jplot")
  }
  bad <- unique(setdiff(which, all_plots))
  if (length(bad) > 0L && length(explain) > 0L &&
      all(bad %in% names(explain))) {
    .jst_stop(paste(explain[bad], collapse = "\n"), fn = "jplot")
  }
  if (length(bad) > 0L) {
    # A name the method explains (jcorr()'s scatter on three or more
    # variables) is not "not a plot" of the result: beside a name that is,
    # the stop names only the latter (Session 378; the S377 item), and the
    # explanation comes on the next call, once that name is gone.
    plain <- setdiff(bad, names(explain))
    .jst_stop(.jst_and_list(paste0("\"", plain, "\"")),
              if (length(plain) == 1L) " is not a plot of "
              else " are not plots of ",
              owner, ".\n", takes, fn = "jplot")
  }
  which
}

#' Internal helper: standardize the return value of jplot dispatch methods
#'
#' Strips \code{NULL} entries from a list of ggplot objects, then
#' returns the list invisibly -- or, if exactly one plot remains,
#' returns that plot alone. Used so that \code{jplot()} returns a
#' sensible value for the single-plot case (suitable for further
#' piping or printing) without losing flexibility for the multi-plot
#' case.
#'
#' @param plots A list of ggplot objects, possibly containing
#'   \code{NULL} entries.
#'
#' @return Invisibly: \code{NULL} if all plots are \code{NULL}; a
#'   single ggplot if exactly one non-\code{NULL} plot remains;
#'   otherwise the trimmed list.
#'
#' @keywords internal
.jst_return_plots <- function(plots) {
  plots <- plots[!vapply(plots, is.null, logical(1))]
  if (length(plots) == 0) return(invisible(NULL))
  if (length(plots) == 1) return(invisible(plots[[1]]))
  invisible(plots)
}

#' Internal helper: predict from a model, without the rank-deficient warning
#'
#' A model whose fit dropped a term as an exact linear combination of the
#' others (an NA coefficient) predicts from the terms it kept, and
#' \code{predict.lm()} -- which \code{predict.glm()} calls -- warns
#' "prediction from rank-deficient fit; attr(*, "non-estim") has doubtful
#' cases" whenever the grid holds the dropped term at a value the kept
#' terms do not imply: once for the fit plot and once per effect plot
#' (Session 359; the S347 item). jlm() and jlogistic() have already said
#' which term the fit dropped (\code{.jst_warn_aliased()}), and the line
#' drawn is the kept terms' prediction, so that one warning is muffled
#' here. Any other warning passes.
#'
#' @param ... Passed to \code{stats::predict()}.
#' @return What \code{stats::predict()} returns.
#' @keywords internal
.jst_predict_kept <- function(...) {
  rank_msg <- gettext(paste0("prediction from rank-deficient fit; ",
                             "attr(*, \"non-estim\") has doubtful cases"),
                      domain = "R-stats")
  withCallingHandlers(
    stats::predict(...),
    warning = function(w) {
      msg <- conditionMessage(w)
      if (identical(msg, rank_msg) ||
          grepl("rank-deficient", msg, fixed = TRUE)) {
        invokeRestart("muffleWarning")
      }
    })
}

#' Internal helper: the plots a model with no predictors cannot draw
#'
#' The intercept-only model (\code{y ~ 1}, supported since Session 359)
#' gives every case the same fitted value and the same leverage, and has
#' no predictor to put on an axis: a fit line, an effect plot, a
#' coefficient plot, and the plots drawn against the fitted values
#' or the leverage have nothing to show. Those named in \code{skip} are
#' left out of \code{plot_set}, and one note names them.
#'
#' @param plot_set Character; the plots asked for.
#' @param model The fitted model.
#' @param skip Character; the plots of \code{plot_set} such a model cannot
#'   draw.
#' @param labels Named character; each plot's name as the note gives it.
#' @param note Logical; emit the note here (FALSE returns the names and
#'   leaves the note to the caller, \code{.jst_no_predictor_note()}).
#' @return \code{plot_set} without the plots left out, with the left-out
#'   names as the attribute \code{"dropped"}.
#' @keywords internal
.jst_no_predictor_plots <- function(plot_set, model, skip, labels,
                                    note = TRUE) {
  if (!identical(names(stats::coef(model)), "(Intercept)")) {
    return(plot_set)
  }
  drop <- intersect(plot_set, skip)
  if (length(drop) > 0L && note) .jst_no_predictor_note(labels[drop])
  structure(setdiff(plot_set, drop), dropped = drop)
}

#' Internal helper: the note for the plots a model with no predictors
#' cannot draw
#'
#' The note \code{.jst_no_predictor_plots()} emits, and jlm()'s
#' diagnostics emit under their plot list (Session 359).
#'
#' @param dropped_labels Character; the left-out plots, named as the note
#'   gives them.
#' @return Invisible NULL; emits the note.
#' @keywords internal
.jst_no_predictor_note <- function(dropped_labels) {
  one <- length(dropped_labels) == 1L
  .jst_msg("Note: The model has no predictors, so ",
           .jst_and_list(unname(dropped_labels)),
           if (one) " is" else " are", " not drawn.")
}

#' Internal helper: compute the terms built from the focal variable on a
#' plot's grid
#'
#' A fitted-line plot moves one predictor along its axis and holds the
#' others at the values \code{.jst_resolve_at()} gives. A term computed
#' from the moving predictor -- \code{I(x^2)}, \code{log(x + 5)},
#' \code{I(x * z)} with \code{z} held -- is a column of its own in the
#' model, and until Session 347 it was held too: at 0 by default, so the
#' line for \code{y ~ x + I(x^2)} was the straight line \code{b0 + b1 x},
#' subtitled "(line shown at I(x^2) = 0)". Such a term is now computed from
#' the grid. Only terms built from arithmetic, comparisons and elementwise
#' functions are computed; a term whose value depends on the whole sample
#' (\code{scale(x)}, \code{poly(x, 2)}) or that names a variable that is
#' neither held nor a single number in the formula's environment is held
#' as before.
#'
#' @param newdata The grid: the focal variable's values, the held values.
#' @param focal Character(1); the focal variable.
#' @param at_vals The held values, by model column.
#' @param enclos The formula's environment, for a constant a term names.
#' @return A list: \code{newdata}, with the terms computed, and
#'   \code{computed}, their names (to leave out of the held-at note).
#' @keywords internal
.jst_terms_on_grid <- function(newdata, focal, at_vals, enclos = NULL) {
  if (!is.environment(enclos)) enclos <- baseenv()
  pointwise <- c("I", "(", "+", "-", "*", "/", "^", "%%", "%/%",
                 "log", "log2", "log10", "log1p", "exp", "expm1", "sqrt",
                 "abs", "sin", "cos", "tan", "round", "floor", "ceiling",
                 "trunc", "pmin", "pmax", ">", "<", ">=", "<=", "==", "!=",
                 "&", "|", "!")
  done <- character(0)
  for (v in names(at_vals)) {
    ex <- tryCatch(str2lang(v), error = function(e) NULL)
    if (is.null(ex) || !is.call(ex)) next
    vars <- all.vars(ex)
    fns  <- setdiff(all.names(ex), vars)
    if (!(focal %in% vars) || !all(fns %in% pointwise)) next
    vals <- list()
    vals[[focal]] <- newdata[[focal]]
    ok <- TRUE
    for (w in setdiff(vars, focal)) {
      if (w %in% names(at_vals)) {
        vals[[w]] <- at_vals[[w]]
        next
      }
      hit <- tryCatch(get(w, envir = enclos), error = function(e) NULL)
      if (is.numeric(hit) && length(hit) == 1L) {
        vals[[w]] <- hit
        next
      }
      ok <- FALSE
      break
    }
    if (!ok) next
    val <- tryCatch(suppressWarnings(eval(ex, vals, baseenv())),
                    error = function(e) NULL)
    if (!(is.numeric(val) || is.logical(val)) ||
        length(val) != nrow(newdata)) next
    newdata[[v]] <- as.numeric(val)
    done <- c(done, v)
  }
  list(newdata = newdata, computed = done)
}

#' Internal helper: a model's variables as its plots name them
#'
#' A dummy-coded predictor is fit as one column per category but is ONE
#' variable (Session 360; the S359 item). The model frame of
#' \code{y ~ x + g}, g with four categories, has the columns \code{x},
#' \code{g_b}, \code{g_c} and \code{g_d}; until v0.9.232 \code{jplot()}
#' drew an effect plot for each column, took \code{g_b} as the fit plot's
#' default focal variable when g came first, and refused \code{focal = g}
#' with the four columns listed. Here each group of dummy columns is
#' replaced by its variable, at the place of its first column.
#'
#' @param x A \code{jst_lm} or \code{jst_logistic} result.
#' @param iv_names Character; the model frame's predictor columns.
#' @return A list: \code{vars}, the variables in model order;
#'   \code{groups}, the result's \code{dummy_groups} whose dummy columns
#'   are all in the model frame (a result made before Session 360 has
#'   none, and its columns are drawn as before); and \code{owner}, the
#'   variable of each dummy column, named by column.
#' @keywords internal
.jst_plot_variables <- function(x, iv_names) {
  groups <- x$dummy_groups
  if (!is.list(groups)) groups <- list()
  groups <- groups[vapply(groups, function(g) {
    d <- g$dummy[!is.na(g$dummy)]
    length(d) > 0L && all(d %in% iv_names)
  }, logical(1))]
  owner <- character(0)
  for (v in names(groups)) {
    d <- groups[[v]]$dummy
    d <- d[!is.na(d)]
    owner[d] <- v
  }
  vars <- vapply(iv_names, function(col) {
    if (col %in% names(owner)) owner[[col]] else col
  }, character(1), USE.NAMES = FALSE)
  list(vars = unique(vars), groups = groups, owner = owner)
}

#' Internal helper: a model's variable, as its plots title an axis
#'
#' The variable's label, the name where it has none (the S412 audit's F4,
#' ruled Session 413), read from the result, which keeps the labels the
#' analysis ran with: the outcome's from the coefficients' "outcome", a
#' dummy-coded variable's from its group, any other predictor's from the
#' coefficients' labels, keyed by term. A result stores a variable's name
#' where it had no label.
#'
#' @param x A \code{jst_lm} or \code{jst_logistic} result.
#' @param var Character(1), the variable's name.
#' @param wrap Logical(1): put a long label on two lines, for an axis.
#' @return Character(1).
#' @keywords internal
.jst_plot_model_label <- function(x, var, wrap = TRUE) {
  if (is.null(var) || length(var) != 1L || is.na(var)) return(var)
  out <- function(l) {
    if (is.null(l) || length(l) != 1L || is.na(l) || !nzchar(l)) return(var)
    l <- as.character(l)
    if (wrap) .jst_plot_wrap(l) else l
  }
  oc <- attr(x$coefficients_raw, "outcome")
  if (!is.null(oc) && identical(unname(oc["name"]), var)) return(out(unname(oc["label"])))
  g <- x$dummy_groups[[var]]
  if (is.list(g) && !is.null(g$var_label)) return(out(g$var_label))
  labs <- attr(x$coefficients_raw, "labels")
  if (!is.null(labs) && var %in% names(labs)) return(out(unname(labs[[var]])))
  var
}

#' Internal helper: a comparison's variable, as its plots title an axis
#'
#' @param x A \code{jst_ttest} or \code{jst_anova} result.
#' @param which "outcome" or "group".
#' @param name The variable's name.
#' @param wrap Logical(1).
#' @return Character(1): its label, the name where it has none.
#' @keywords internal
.jst_plot_group_label <- function(x, which, name, wrap = TRUE) {
  a <- attr(x$descriptives_raw, which)
  l <- if (is.null(a)) NA_character_ else unname(a["label"])
  if (is.na(l) || !nzchar(l)) return(name)
  if (wrap) .jst_plot_wrap(l) else l
}

#' Internal helper: the heatmap's own theme setting, its axis text slanted
#' @keywords internal
.jst_plot_heat_tweak <- function() {
  ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 45, hjust = 1))
}

#' Internal helper: which variables a result names by name, or by code
#'
#' Ruling R72 (Session 412; the S412 audit's F9, taken Session 413): a
#' jstats result keeps the labels it had when the analysis ran, and a table
#' or a figure made from it shows a variable's NAME where the result holds
#' no label for it, and a category's CODE where it holds no value label.
#' Read from the result's own label fields -- a stored label that is the
#' name counts as absent, as the results store the name in its place --
#' never from the text a table shows. A variable shown by its categories
#' is counted where its codes stand for categories: a grouping variable, a
#' crosstab's variables and a dummy-coded predictor whatever their labels;
#' a frequency table's variable only when some of its codes carry a label,
#' since the values of a variable with none may be what they mean (a
#' count).
#'
#' @param x A result.
#' @param shown Character, or NULL for every variable the result holds:
#'   the variables a plot shows.
#' @return A list: names_shown (the variables with no label), codes_shown
#'   (by variable, the codes with no value label), labelled (TRUE when the
#'   result holds any label at all), and data_name (the data frame's name
#'   as the result recorded it, or NULL).
#' @keywords internal
.jst_result_label_gaps <- function(x, shown = NULL) {
  vars  <- character(0)        # by variable: its label, NA for none
  codes <- list()
  any_vl <- FALSE
  absent <- function(l, v) {
    is.null(l) || length(l) != 1L || is.na(l) || !nzchar(l) ||
      identical(as.character(l), v)
  }
  addv <- function(v, l) {
    if (is.null(v) || length(v) != 1L || is.na(v) || !nzchar(v)) return(invisible())
    if (!v %in% names(vars)) vars[v] <<- if (absent(l, v)) NA_character_ else as.character(l)
  }
  addc <- function(v, code, label, partial = FALSE) {
    if (is.null(v) || is.na(v) || is.null(code) || !length(code)) return(invisible())
    if (is.null(label)) label <- rep(NA_character_, length(code))
    has <- !is.na(label) & nzchar(as.character(label))
    if (any(has)) any_vl <<- TRUE
    if (partial && !any(has)) return(invisible())
    num  <- suppressWarnings(!is.na(as.numeric(as.character(code))))
    miss <- as.character(code[!is.na(code) & num & !has])
    if (length(miss)) codes[[v]] <<- unique(c(codes[[v]], miss))
  }
  if (inherits(x, c("jst_lm", "jst_logistic"))) {
    oc <- attr(x$coefficients_raw, "outcome")
    if (!is.null(oc)) addv(unname(oc["name"]), unname(oc["label"]))
    dummies <- character(0)
    for (v in names(x$dummy_groups)) {
      g <- x$dummy_groups[[v]]
      addv(v, g$var_label)
      addc(v, g$codes, g$value_labels)
      dummies <- c(dummies, g$dummy)
    }
    labs <- attr(x$coefficients_raw, "labels")
    for (tm in setdiff(names(labs), dummies)) {
      # A variable's own term; a computed one (I(Age^2), log(Income)) and
      # the constant are not variables.
      if (identical(make.names(tm), tm)) addv(tm, unname(labs[[tm]]))
    }
  } else if (inherits(x, c("jst_ttest", "jst_anova"))) {
    dr <- x$descriptives_raw
    for (w in c("outcome", "group")) {
      a <- attr(dr, w)
      if (!is.null(a)) addv(unname(a["name"]), unname(a["label"]))
    }
    gv <- .jst_apa_name(x, "group")
    if (!is.null(dr$group_code) && !is.na(gv)) addc(gv, dr$group_code, dr$group_label)
  } else if (inherits(x, "jst_corr")) {
    for (v in rownames(x$r)) {
      addv(v, if (is.null(x$labels)) NULL else unname(x$labels[v]))
    }
  } else if (inherits(x, "jst_crosstab")) {
    for (cats in list(x$row_categories, x$col_categories)) {
      a <- attr(cats, "variable")
      if (is.null(a)) next
      addv(unname(a["name"]), unname(a["label"]))
      if (!is.null(cats$code)) addc(unname(a["name"]), cats$code, cats$label)
    }
  } else if (inherits(x, "jst_freq")) {
    for (v in names(x$frequencies)) {
      f <- x$frequencies[[v]]
      addv(v, f$var_label)
      if (is.data.frame(f$valid) && !is.null(f$valid$Code)) {
        addc(v, f$valid$Code, f$valid$Label, partial = TRUE)
      }
    }
  } else if (inherits(x, "jst_desc")) {
    dr <- x$descriptives_raw
    labs <- attr(dr, "labels")
    for (v in unique(dr$variable)) addv(v, if (is.null(labs)) NULL else unname(labs[v]))
    by <- attr(dr, "by")
    if (!is.null(by)) {
      addv(unname(by["name"]), unname(by["label"]))
      if (!is.null(dr$group_code)) addc(unname(by["name"]), dr$group_code, dr$group_label)
    }
  } else if (inherits(x, "jst_alpha")) {
    ir <- x$items_raw
    if (is.data.frame(ir)) for (i in seq_len(nrow(ir))) addv(ir$item[i], ir$label[i])
  } else if (inherits(x, "jst_multi")) {
    rr <- x$rows_raw
    if (is.data.frame(rr)) {
      it <- rr[!is.na(rr$item), , drop = FALSE]
      for (i in seq_len(nrow(it))) addv(it$item[i], it$label[i])
    }
  }
  if (!is.null(shown)) {
    shown <- unique(shown[!is.na(shown) & nzchar(shown)])
    vars  <- vars[names(vars) %in% shown]
    codes <- codes[names(codes) %in% shown]
  }
  list(names_shown = names(vars)[is.na(vars)], codes_shown = codes,
       labelled = any(!is.na(vars)) || any_vl,
       data_name = if (is.character(x$data_name) && length(x$data_name) == 1L &&
                       !is.na(x$data_name) && nzchar(x$data_name)) x$data_name)
}

#' Internal helper: the points a model's or a test's plot draws, for its
#' Excel sheet
#'
#' The plot's own data frame, the columns jstats built it with (ruling R65:
#' a figure's data to Excel), each a number or text.
#'
#' @param p A ggplot.
#' @return A data frame, or NULL.
#' @keywords internal
.jst_plot_points_sheet <- function(p) {
  d <- tryCatch(p$data, error = function(e) NULL)
  if (!is.data.frame(d) || !nrow(d)) return(NULL)
  ok <- vapply(d, function(v) is.atomic(v) && is.null(dim(v)), logical(1))
  if (!any(ok)) return(NULL)
  out <- lapply(d[ok], function(v) {
    if (is.factor(v)) as.character(v)
    else if (inherits(v, "haven_labelled")) as.numeric(unclass(v))
    else as.vector(v)
  })
  structure(out, class = "data.frame", row.names = seq_len(nrow(d)))
}

#' Internal helper: a result's plots marked as jplot()'s
#'
#' Each plot gets the class and the frame's facts (\code{.jst_plot_finish()}):
#' its kind (the plot's name: "fit", "qq", "effect_Age"), the result's N,
#' its default title (ruling R69: a model's or a test's plot keeps its own
#' title -- "Residuals vs Fitted" -- which stands in the caption in a Word
#' file; a fit plot, a box plot and a scatterplot, which have none, the
#' outcome "by" the predictor or the group), and what it shows without a
#' label (ruling R72).
#'
#' @param plots A named list of ggplots.
#' @param x The result.
#' @param n Its N.
#' @param titles Named character; default titles by plot name.
#' @param shown Character; the variables the plots show.
#' @return The list, each plot marked.
#' @keywords internal
.jst_plot_mark_results <- function(plots, x, n = NA, titles = character(0),
                                   shown = character(0)) {
  gaps <- .jst_result_label_gaps(x, shown)
  code_labels <- stats::setNames(lapply(names(gaps$codes_shown), function(v) {
    .jst_result_value_labels(list(x), v)
  }), names(gaps$codes_shown))
  look <- .jst_plot_look_now()
  for (nm in names(plots)) {
    p <- plots[[nm]]
    if (!inherits(p, "ggplot")) next
    t <- if (nm %in% names(titles)) titles[[nm]]
         else if (!is.null(attr(p, "jst_title"))) attr(p, "jst_title")
         else if (!is.null(p$labels$title)) p$labels$title
         else NA_character_
    pn <- if (!is.null(attr(p, "jst_n"))) attr(p, "jst_n") else n
    sc <- attr(p, "jst_scales"); if (is.null(sc)) sc <- list()
    dt <- attr(p, "jst_data")
    if (is.null(dt)) dt <- .jst_plot_points_sheet(p)
    tw <- attr(p, "jst_tweak")
    for (a in c("jst_title", "jst_n", "jst_scales", "jst_data", "jst_tweak")) {
      attr(p, a) <- NULL
    }
    plots[[nm]] <- .jst_plot_finish(p, kind = nm, n = pn, title = t, data = dt,
                                    names_shown = gaps$names_shown,
                                    codes_shown = gaps$codes_shown,
                                    scales = sc, labelled = gaps$labelled,
                                    look = look, tweak = tw,
                                    filter = .jst_plot_filter_facts(x$sample_info),
                                    data_name = gaps$data_name,
                                    rerun = "analysis",
                                    code_labels = code_labels)
  }
  plots
}

#' Internal helper: the focal variable of a fit or probability plot
#'
#' \code{focal} names a VARIABLE of the model (Session 360): a
#' dummy-coded one by its own name, and a dummy column by the variable it
#' belongs to, so \code{focal = g_b}, which the old refusal listed,
#' draws g. With no \code{focal}, the first predictor that is not
#' dummy-coded, since a fitted line needs a numeric axis; a model whose
#' predictors are all dummy-coded takes its first. A name that is not a
#' variable of the model stops, the model's variables listed.
#'
#' @param focal_name Character(1) or NULL, as deparsed from the call.
#' @param pv The list \code{.jst_plot_variables()} returns.
#' @return Character(1): the focal variable (\code{NA} for a model with no
#'   predictors).
#' @keywords internal
.jst_plot_focal <- function(focal_name, pv) {
  vars <- pv$vars
  if (is.null(focal_name)) {
    num <- setdiff(vars, names(pv$groups))
    return(if (length(num) > 0L) num[1L] else vars[1L])
  }
  if (focal_name %in% names(pv$owner)) return(pv$owner[[focal_name]])
  if (length(vars) > 0L && !focal_name %in% vars) {
    .jst_stop("`focal` must be one of the predictors in the model: ",
              paste(vars, collapse = ", "))
  }
  focal_name
}

#' Internal helper: the cases' categories of a dummy-coded variable
#'
#' Read back from the model frame's dummy columns: a case marked by none
#' is in the reference category.
#'
#' @param mf The result's model frame.
#' @param group One element of \code{.jst_plot_variables()$groups}.
#' @return A factor, its levels the categories in code order.
#' @keywords internal
.jst_case_category <- function(mf, group) {
  d   <- group$dummy
  idx <- rep(which(is.na(d))[1L], nrow(mf))
  for (j in which(!is.na(d))) idx[mf[[d[j]]] == 1] <- j
  factor(group$labels[idx], levels = group$labels)
}

#' Internal helper: the prediction at each category of a dummy-coded
#' variable
#'
#' One row per category (Session 360): its dummy columns set as the
#' category's cases have them, every other predictor held where
#' \code{at_vals} puts it, and the prediction with its 95% interval --
#' the confidence interval of the mean for a linear model, the interval on
#' the logit scale carried to the probability scale for a logistic one,
#' as the fitted line and the S-curve compute theirs.
#'
#' @param model The fitted \code{lm} or \code{glm}.
#' @param group One element of \code{.jst_plot_variables()$groups}.
#' @param at_vals The held values, by model column.
#' @param logistic Logical; TRUE for a \code{glm} on the logit link.
#' @param link Logical; with \code{logistic}, TRUE keeps the prediction
#'   and its interval on the logit scale (the logit plot, Session 378).
#' @return A data frame: \code{x} (a factor of the categories),
#'   \code{fit}, \code{lwr}, \code{upr}.
#' @keywords internal
.jst_category_predictions <- function(model, group, at_vals,
                                      logistic = FALSE, link = FALSE) {
  k  <- length(group$labels)
  d  <- group$dummy
  nd <- data.frame(row.names = seq_len(k))
  for (dn in d[!is.na(d)]) nd[[dn]] <- as.integer(!is.na(d) & d == dn)
  for (v in names(at_vals)) nd[[v]] <- at_vals[[v]]
  if (logistic) {
    p   <- .jst_predict_kept(model, newdata = nd, type = "link",
                             se.fit = TRUE)
    tr  <- if (link) identity else stats::plogis
    fit <- tr(p$fit)
    lwr <- tr(p$fit - 1.96 * p$se.fit)
    upr <- tr(p$fit + 1.96 * p$se.fit)
  } else {
    p   <- .jst_predict_kept(model, newdata = nd, interval = "confidence",
                             level = 0.95)
    fit <- p[, "fit"]
    lwr <- p[, "lwr"]
    upr <- p[, "upr"]
  }
  data.frame(x = factor(group$labels, levels = group$labels),
             fit = unname(fit), lwr = unname(lwr), upr = unname(upr))
}

#' Internal helper: the layers that draw a prediction at each category
#'
#' A point at the prediction and a bar for its 95% interval, in the
#' fitted line's color (Session 360).
#'
#' @param pred_df The data frame \code{.jst_category_predictions()}
#'   returns.
#' @return A list of ggplot2 layers.
#' @keywords internal
.jst_category_layers <- function(pred_df) {
  list(
    ggplot2::geom_errorbar(data = pred_df,
                           ggplot2::aes(x = .data$x, ymin = .data$lwr,
                                        ymax = .data$upr),
                           width = 0.15, color = .jst_plot_ink$line,
                           linewidth = 0.8),
    ggplot2::geom_point(data = pred_df,
                        ggplot2::aes(x = .data$x, y = .data$fit),
                        color = .jst_plot_ink$line, size = 2.8)
  )
}

#' Internal helper: the note naming where the other predictors are held
#'
#' "(line shown at x = 0, g_b = 0)" under a fitted line; under the
#' predictions at a dummy-coded variable's categories, what is shown is
#' named instead of the line ("(means shown at x = 0)", Session 360). A
#' dummy column keeps its name, as in the equation (Session 347).
#'
#' @param at_vals The held values, by model column.
#' @param what Character(1): "line", "means" or "probabilities".
#' @return Character(1), or NULL when nothing is held.
#' @keywords internal
.jst_held_note <- function(at_vals, what = "line") {
  if (length(at_vals) == 0L) return(NULL)
  at_parts <- vapply(names(at_vals), function(v) {
    val <- at_vals[[v]]
    paste0(v, " = ", if (abs(val - round(val)) < 1e-8) {
      as.character(round(val))
    } else {
      sprintf("%.2f", val)
    })
  }, character(1))
  paste0("(", what, " shown at ", paste(at_parts, collapse = ", "), ")")
}

#' Internal helper: resolve the `at` argument for regression-line plots
#'
#' Computes the values at which non-focal predictors should be held when
#' producing a fitted-line plot for a multiple-predictor regression. The
#' \code{at} argument accepts \code{zero}, \code{mean},
#' \code{mixed} (zero for dummies, mean for numeric), or a named
#' list giving an explicit value per non-focal predictor.
#'
#' @param at User-supplied value: \code{zero}, \code{mean},
#'   \code{mixed}, or a named list of explicit hold values.
#' @param model_frame Data frame used to fit the model
#'   (post-conversion).
#' @param dv_name Character. The dependent variable name.
#' @param focal_name Character. The focal predictor name (the one that
#'   varies along the x-axis).
#' @param dummy_coef_names Character vector of registered
#'   dummy-coefficient names, used to identify which non-focal
#'   predictors are dummies.
#'
#' @return A named list of hold values, one per non-focal predictor.
#'   Empty list if there are no non-focal predictors.
#'
#' @keywords internal
.jst_resolve_at <- function(at, model_frame, dv_name, focal_name,
                            dummy_coef_names) {

  non_focal <- setdiff(colnames(model_frame), c(dv_name, focal_name))

  if (length(non_focal) == 0) return(list())

  classify <- function(v) {
    if (v %in% dummy_coef_names) return("categorical")
    x <- model_frame[[v]]
    # Use the unified classifier. data_name is not available at this point
    # (the model_frame doesn't retain the source data frame's name), so
    # jdummy registration is checked via the dummy_coef_names list above
    # rather than by passing var_name/data_name to the classifier.
    if (.jst_is_categorical(x)) "categorical" else "interval"
  }

  hold_at <- function(v, mode) {
    x <- model_frame[[v]]
    x_num <- as.numeric(x)
    if (mode == "zero") return(0)
    if (mode == "mean") return(mean(x_num, na.rm = TRUE))
    if (mode == "mixed") {
      if (classify(v) == "categorical") return(0)
      return(mean(x_num, na.rm = TRUE))
    }
    .jst_stop("Unknown 'at' mode: ", mode)
  }

  if (is.list(at)) {
    result <- setNames(as.list(rep(0, length(non_focal))), non_focal)
    for (nm in names(at)) {
      if (nm %in% non_focal) result[[nm]] <- at[[nm]]
    }
    return(result)
  }

  if (!is.character(at) || length(at) != 1 ||
      !at %in% c("zero", "mean", "mixed")) {
    .jst_stop("`at` must be one of \"zero\", \"mean\", \"mixed\", or a named list.")
  }

  setNames(lapply(non_focal, hold_at, mode = at), non_focal)
}

#' Internal helper: format a regression equation for plot subtitles
#'
#' Builds a short equation string from a coefficient vector for use as a
#' plot subtitle. Truncates to \code{max_terms} predictors and joins
#' them with appropriate sign characters.
#'
#' The terms are named as the coefficient table names them (Session 347):
#' without the backticks R puts around a computed term or a name with a
#' space (\code{`I(x^2)`}, \code{`my var`}), and an interaction with
#' \code{" * "} for R's \code{":"}. A dummy column keeps its name
#' (\code{g_Mid}), which the line's "(line shown at g_Mid = 0, ...)" uses
#' too.
#'
#' @param coefs_vec Named numeric vector of regression coefficients
#'   (intercept first).
#' @param dv_name Character. The dependent variable name used at the
#'   left-hand side of the equation.
#' @param max_terms Integer. Maximum number of predictor terms to
#'   include. Default 3; additional terms are summarized as
#'   \code{...}.
#'
#' @return A character string of the formatted equation.
#'
#' @keywords internal
.jst_format_equation <- function(coefs_vec, dv_name, max_terms = 3) {

  intercept <- coefs_vec[1]
  slopes    <- coefs_vec[-1]
  # A term the fit dropped as aliased has no coefficient and is left out
  # (Session 347): its NA stopped jplot() on "missing value where
  # TRUE/FALSE needed".
  slopes    <- slopes[!is.na(slopes)]
  iv_count  <- length(slopes)

  if (iv_count > max_terms) {
    return(NULL)
  }

  eq <- sprintf("%s = %.2f", dv_name, intercept)
  for (i in seq_along(slopes)) {
    b <- slopes[i]
    # A plain hyphen (Session 360), as in .jst_format_bivar_equation().
    sign_char <- if (b >= 0) "+" else "-"
    eq <- paste0(eq, " ", sign_char, " ", sprintf("%.2f", abs(b)),
                 "\u00b7",
                 .jst_interaction_label(.jst_unbacktick(names(slopes)[i])))
  }
  eq
}


# -- jplot.jst_lm --------------------------------------------------------------

#' @describeIn jplot diagnostic, coefficient (forest), and fitted-effect plots for a \code{jlm()} linear-regression result.
#' @export
#' @importFrom rlang .data
jplot.jst_lm <- function(x, which = "core", focal = NULL, at = "zero",
                         equation = TRUE, r2 = TRUE, ..., style = NULL) {
  # Validate TRUE/FALSE flags up front.
  .jst_check_flag(equation, "equation")
  .jst_check_flag(r2, "r2")

  .jst_check_args(
    rlang::enquos(...),
    aliases = c(diagnostics = "which", plots = "which",
                show = "which", type = "which"),
    fn_name = "jplot"   # the function the user typed (Session 377)
  )
  # The style the plots are drawn in (ruling R64), as jplot.default().
  .old_look <- .jst_plot_look_set(.jst_plot_look(style))
  on.exit(.jst_plot_look_restore(.old_look), add = TRUE)

  # No "vif" since Session 376 (Jeff: the bar chart added nothing the VIF
  # table does not give, and the commercial packages draw none).
  all_plots <- c("fit", "predicted", "effects", "coef",
                 "residuals", "qq", "scale", "cooks", "leverage")
  core      <- c("fit", "qq", "residuals", "cooks")
  plot_set  <- .jst_resolve_which(which, core, all_plots, "jst_lm")

  focal_name <- tryCatch(deparse(substitute(focal)), error = function(e) "NULL")
  if (identical(focal_name, "NULL") || !nzchar(focal_name) ||
      focal_name == "NULL") focal_name <- NULL

  model   <- x$model
  mf      <- x$model_frame
  dv_name <- all.vars(x$formula_used)[1]
  iv_names <- setdiff(colnames(mf), dv_name)

  # The intercept-only model (Session 359): the plots that need a
  # predictor, or that are drawn against the fitted values or the
  # leverage, are left out with one note.
  plot_set <- .jst_no_predictor_plots(
    plot_set, model,
    skip   = c("fit", "predicted", "effects", "coef", "residuals",
               "scale", "leverage"),
    labels = c(fit = "the fit plot", predicted = "Observed vs Predicted",
               effects = "the effect plots",
               coef = "Coefficients (95% CI)",
               residuals = "Residuals vs Fitted", scale = "Scale-Location",
               leverage = "Residuals vs Leverage"))

  # The model's variables (Session 360): a dummy-coded variable is one
  # variable, its dummy columns drawn together. focal names a variable;
  # with none given, the first predictor that is not dummy-coded.
  pv          <- .jst_plot_variables(x, iv_names)
  focal_name  <- .jst_plot_focal(focal_name, pv)
  focal_group <- if (isTRUE(focal_name %in% names(pv$groups))) {
    pv$groups[[focal_name]]
  }
  focal_cols  <- if (is.null(focal_group)) {
    focal_name
  } else {
    focal_group$dummy[!is.na(focal_group$dummy)]
  }

  plots <- list()
  coefs <- stats::coef(model)

  # ---- fit plot ------------------------------------------------------------
  if ("fit" %in% plot_set) {
    at_vals <- .jst_resolve_at(at, mf, dv_name, focal_cols,
                               x$dummy_coef_names)

    if (!is.null(focal_group)) {
      # A dummy-coded focal variable (Session 360): its categories along
      # the axis, the predicted mean at each with its 95% interval, the
      # cases behind them.
      pred_df  <- .jst_category_predictions(model, focal_group, at_vals)
      point_df <- data.frame(x = .jst_case_category(mf, focal_group),
                             y = mf[[dv_name]])
    } else {
      focal_range <- range(mf[[focal_name]], na.rm = TRUE)
      grid_x <- seq(focal_range[1], focal_range[2], length.out = 120)
      newdata <- data.frame(grid_x)
      names(newdata) <- focal_name
      for (v in names(at_vals)) newdata[[v]] <- at_vals[[v]]
      # A term computed from the focal variable follows it along the axis
      # (Session 347): I(x^2) was held at 0 while x varied, so the line was
      # straight and the subtitle said "(line shown at I(x^2) = 0)".
      on_grid <- .jst_terms_on_grid(newdata, focal_name, at_vals,
                                    environment(x$formula_used))
      newdata <- on_grid$newdata
      at_vals <- at_vals[setdiff(names(at_vals), on_grid$computed)]

      pred <- .jst_predict_kept(model, newdata = newdata,
                                interval = "confidence", level = 0.95)
      line_df <- data.frame(
        x   = grid_x,
        fit = pred[, "fit"],
        lwr = pred[, "lwr"],
        upr = pred[, "upr"]
      )
      point_df <- data.frame(
        x = mf[[focal_name]],
        y = mf[[dv_name]]
      )
    }

    eq_text <- if (equation) .jst_format_equation(coefs, dv_name,
                                                  max_terms = 3) else NULL
    r2_text <- if (r2) sprintf("R\u00b2 = %.3f", x$r_squared) else NULL

    subtitle_parts <- character(0)
    if (!is.null(eq_text) && !is.null(r2_text)) {
      subtitle_parts <- paste0(eq_text, "    ", r2_text)
    } else if (!is.null(eq_text)) {
      subtitle_parts <- eq_text
    } else if (!is.null(r2_text)) {
      subtitle_parts <- r2_text
    }

    held_note <- .jst_held_note(at_vals,
                                if (is.null(focal_group)) "line" else "means")
    if (!is.null(held_note)) {
      if (length(subtitle_parts) > 0) {
        subtitle_parts <- paste0(subtitle_parts, "\n", held_note)
      } else {
        subtitle_parts <- held_note
      }
    }

    if (equation && is.null(eq_text)) {
      # The count was of model-frame columns (Session 360): y ~ x + g, g
      # with four categories, read "model has 4 predictors". Where the
      # predictors and the terms differ in number -- a dummy-coded
      # variable, an interaction -- the note names the terms, which are
      # what leaves the equation out (more than 3).
      n_vars <- length(pv$vars)
      n_coef <- sum(!is.na(coefs[-1]))
      note   <- if (n_vars == n_coef) {
        paste0("(equation omitted: model has ", n_vars,
               " predictors; see jlm() output for coefficients)")
      } else {
        "(equation omitted: more than 3 terms; see jlm() output for coefficients)"
      }
      subtitle_parts <- if (length(subtitle_parts) > 0) {
        paste0(subtitle_parts, "\n", note)
      } else {
        note
      }
    }

    p <- if (!is.null(focal_group)) {
      ggplot2::ggplot() +
        ggplot2::geom_point(data = point_df,
                            ggplot2::aes(x = .data$x, y = .data$y),
                            alpha = 0.55, color = .jst_plot_ink$point,
                            position = ggplot2::position_jitter(
                              width = 0.12, height = 0, seed = 1)) +
        .jst_category_layers(pred_df)
    } else {
      ggplot2::ggplot() +
        ggplot2::geom_ribbon(data = line_df,
                             ggplot2::aes(x = .data$x,
                                          ymin = .data$lwr,
                                          ymax = .data$upr),
                             fill = .jst_plot_ink$line, alpha = 0.18) +
        ggplot2::geom_point(data = point_df,
                            ggplot2::aes(x = .data$x, y = .data$y),
                            alpha = 0.55, color = .jst_plot_ink$point) +
        ggplot2::geom_line(data = line_df,
                           ggplot2::aes(x = .data$x, y = .data$fit),
                           color = .jst_plot_ink$line, linewidth = 0.9)
    }
    p <- p +
      ggplot2::labs(
        x        = .jst_plot_model_label(x, focal_name),
        y        = .jst_plot_model_label(x, dv_name),
        subtitle = if (length(subtitle_parts) > 0) subtitle_parts else NULL
      ) +
      .jst_plot_theme()
    print(p)
    plots$fit <- p
  }

  # ---- predicted plot (observed vs predicted) ------------------------------
  if ("predicted" %in% plot_set) {
    pred_df <- data.frame(
      observed  = mf[[dv_name]],
      predicted = stats::fitted(model)
    )
    lim <- range(c(pred_df$observed, pred_df$predicted), na.rm = TRUE)

    p <- ggplot2::ggplot(pred_df,
                         ggplot2::aes(x = .data$predicted,
                                      y = .data$observed)) +
      ggplot2::geom_abline(slope = 1, intercept = 0, linetype = "dashed",
                           color = "grey60") +
      ggplot2::geom_point(alpha = 0.55, color = .jst_plot_ink$point) +
      ggplot2::coord_equal(xlim = lim, ylim = lim) +
      ggplot2::labs(title = "Observed vs Predicted",
                    x = "Predicted", y = "Observed") +
      .jst_plot_theme()
    print(p)
    plots$predicted <- p
  }

  # ---- effects plot (one per variable) -------------------------------------
  # One plot per VARIABLE (Session 359; the S347 item, Jeff's lean at
  # S358): a term computed from a variable of the model -- I(x^2),
  # log(x + 1), I(x * z) -- is drawn in that variable's plot, computed
  # along its axis by .jst_terms_on_grid() (a product in each of its
  # variables' plots, the other held), and has no plot of its own; until
  # v0.9.232 "Effect: I(x^2)" moved the square with x held at 0. A
  # computed term none of whose variables is in the model by itself
  # (y ~ log(x)) keeps its own plot, as the only way to show it. A
  # variable whose coefficient the fit dropped (an exact linear
  # combination of the others) has no effect to draw, and the count line
  # says so.
  # A dummy-coded variable is one variable here too (Session 360; the S359
  # item, Jeff's okay of the lean): ONE plot, its categories along the
  # axis, the predicted outcome at each with its 95% interval, the other
  # variables held as `at` sets them -- where v0.9.232 drew a line across
  # 0 to 1 for each dummy column (Effect: g_b, g_c, g_d) under a count of
  # "one per variable". It is dropped when the fit dropped every one of
  # its dummy columns.
  if ("effects" %in% plot_set) {
    cols    <- setdiff(iv_names, names(pv$owner))
    is_term <- vapply(cols, function(v) {
      ex <- tryCatch(str2lang(v), error = function(e) NULL)
      is.call(ex)
    }, logical(1))
    plain    <- cols[!is_term]
    term_var <- lapply(cols[is_term], function(v) all.vars(str2lang(v)))
    names(term_var) <- cols[is_term]
    own      <- names(term_var)[vapply(term_var, function(vs) {
      length(intersect(vs, plain)) == 0L
    }, logical(1))]
    fit_b <- stats::coef(model)
    names(fit_b) <- .jst_unbacktick(names(fit_b))
    dropped <- plain[vapply(plain, function(v) {
      v %in% names(fit_b) && is.na(fit_b[[v]]) &&
        !any(vapply(names(term_var), function(t) {
          v %in% term_var[[t]] && t %in% names(fit_b) && !is.na(fit_b[[t]])
        }, logical(1)))
    }, logical(1))]
    grp_dropped <- names(pv$groups)[vapply(pv$groups, function(g) {
      d <- g$dummy[!is.na(g$dummy)]
      all(d %in% names(fit_b)) && all(is.na(fit_b[d]))
    }, logical(1))]
    effect_vars <- pv$vars[pv$vars %in% c(setdiff(plain, dropped), own,
                                          setdiff(names(pv$groups),
                                                  grp_dropped))]
    dropped <- pv$vars[pv$vars %in% c(dropped, grp_dropped)]
    n_effects <- 0
    for (iv in effect_vars) {
      grp <- pv$groups[[iv]]
      if (!is.null(grp)) {
        at_vals <- .jst_resolve_at(at, mf, dv_name,
                                   grp$dummy[!is.na(grp$dummy)],
                                   x$dummy_coef_names)
        pred_df <- .jst_category_predictions(model, grp, at_vals)
        p <- ggplot2::ggplot() +
          .jst_category_layers(pred_df) +
          ggplot2::labs(title = paste0("Effect: ", iv),
                        x = .jst_plot_model_label(x, iv),
                        y = .jst_plot_model_label(x, dv_name)) +
          .jst_plot_theme()
        print(p)
        plots[[paste0("effect_", iv)]] <- p
        n_effects <- n_effects + 1
        next
      }
      at_vals <- .jst_resolve_at(at, mf, dv_name, iv, x$dummy_coef_names)
      iv_range <- range(mf[[iv]], na.rm = TRUE)
      grid_x   <- seq(iv_range[1], iv_range[2], length.out = 80)
      newdata  <- data.frame(grid_x)
      names(newdata) <- iv
      for (v in names(at_vals)) newdata[[v]] <- at_vals[[v]]
      newdata <- .jst_terms_on_grid(newdata, iv, at_vals,
                                    environment(x$formula_used))$newdata

      pred <- .jst_predict_kept(model, newdata = newdata,
                                interval = "confidence", level = 0.95)
      line_df <- data.frame(x = grid_x,
                            fit = pred[, "fit"],
                            lwr = pred[, "lwr"],
                            upr = pred[, "upr"])

      p <- ggplot2::ggplot(line_df,
                           ggplot2::aes(x = .data$x, y = .data$fit)) +
        ggplot2::geom_ribbon(ggplot2::aes(ymin = .data$lwr,
                                          ymax = .data$upr),
                             fill = .jst_plot_ink$line, alpha = 0.18) +
        ggplot2::geom_line(color = .jst_plot_ink$line, linewidth = 0.9) +
        ggplot2::labs(title = paste0("Effect: ", iv),
                      x = .jst_plot_model_label(x, iv),
                      y = .jst_plot_model_label(x, dv_name)) +
        .jst_plot_theme()
      print(p)
      plots[[paste0("effect_", iv)]] <- p
      n_effects <- n_effects + 1
    }
    # In number (Session 347): it read "(1 effect plots produced, one per
    # predictor)". Counted in variables since Session 359, and laid out as
    # an output's last line: none above it, one blank line after it (the
    # S347 item; it opened on a blank line and ended without one, so two
    # stood together under jlm()'s output and the next output began
    # directly beneath it).
    gone <- if (length(dropped) > 0L) {
      paste0("; none for ", .jst_and_list(dropped), ", which ",
             if (length(dropped) == 1L) "was" else "were",
             " removed from the model")
    } else {
      ""
    }
    .jst_msg_out("(", .jst_plural(n_effects, "1 effect plot produced",
                                  paste0(.jst_fmt_n(n_effects), " effect plots produced, ",
                                         "one per variable")), gone, ")")
    cat("\n")
  }

  # ---- coef forest plot ----------------------------------------------------
  if ("coef" %in% plot_set) {
    summ <- summary(model)$coefficients
    est  <- summ[-1, "Estimate"]
    se   <- summ[-1, "Std. Error"]
    nm   <- rownames(summ)[-1]

    t_crit <- stats::qt(0.975, df = stats::df.residual(model))
    coef_df <- data.frame(
      term  = factor(nm, levels = nm[order(abs(est))]),
      est   = est,
      lower = est - t_crit * se,
      upper = est + t_crit * se,
      stringsAsFactors = FALSE
    )

    p <- ggplot2::ggplot(coef_df,
                         ggplot2::aes(x = .data$est, y = .data$term)) +
      ggplot2::geom_vline(xintercept = 0, linetype = "dashed",
                          color = "grey60") +
      ggplot2::geom_errorbarh(ggplot2::aes(xmin = .data$lower,
                                           xmax = .data$upper),
                              height = 0.2, color = .jst_plot_ink$line) +
      ggplot2::geom_point(size = 2.5, color = .jst_plot_ink$line) +
      ggplot2::labs(title = "Coefficients (95% CI)",
                    x = "Estimate", y = NULL) +
      .jst_plot_theme()
    print(p)
    plots$coef <- p
  }

  # ---- diagnostic plots (residuals / qq / scale / cooks / leverage) --------
  diag_plots <- intersect(plot_set, c("residuals", "qq", "scale", "cooks",
                                      "leverage"))
  if (length(diag_plots) > 0) {
    # No blank line ahead of a note here (Session 359): in jlm() the note
    # follows the plot list, which ends without one; jplot() prints none.
    diag_result <- .jst_plot_lm_diagnostics(model, which = diag_plots,
                                            lead = FALSE)
    if (is.list(diag_result)) {
      for (nm in names(diag_result)) plots[[nm]] <- diag_result[[nm]]
    }
  }

  .jst_return_plots(.jst_plot_mark_results(
    plots, x, n = x$n,
    titles = c(fit = paste(.jst_plot_model_label(x, dv_name, wrap = FALSE), "by",
                           .jst_plot_model_label(x, focal_name, wrap = FALSE))),
    shown = c(dv_name, focal_name)))
}


# -- jplot.jst_logistic --------------------------------------------------------

#' @describeIn jplot predicted-probability (S-curve) and coefficient plots for a \code{jlogistic()} result.
#' @export
#' @importFrom rlang .data
jplot.jst_logistic <- function(x, which = "core", focal = NULL, at = "zero",
                               ..., style = NULL) {

  .jst_check_args(
    rlang::enquos(...),
    aliases = c(diagnostics = "which", plots = "which",
                show = "which", type = "which"),
    fn_name = "jplot"   # the function the user typed (Session 377)
  )
  .old_look <- .jst_plot_look_set(.jst_plot_look(style))
  on.exit(.jst_plot_look_restore(.old_look), add = TRUE)

  # No "vif" since Session 376, as in jplot.jst_lm(). "logit" since
  # Session 378: the probability plot's companion, not in the core set.
  all_plots <- c("probability", "logit", "roc", "calibration", "binned",
                 "cooks", "leverage", "coef")
  core      <- c("probability", "roc", "calibration", "cooks")
  plot_set  <- .jst_resolve_which(which, core, all_plots, "jst_logistic")

  focal_name <- tryCatch(deparse(substitute(focal)), error = function(e) "NULL")
  if (identical(focal_name, "NULL") || !nzchar(focal_name) ||
      focal_name == "NULL") focal_name <- NULL

  model   <- x$model
  mf      <- x$model_frame
  dv_name <- names(mf)[1]
  iv_names <- setdiff(colnames(mf), dv_name)

  # The intercept-only model (Session 359), as in jplot.jst_lm(): every
  # case has the same predicted probability and leverage.
  plot_set <- .jst_no_predictor_plots(
    plot_set, model,
    skip   = c("probability", "logit", "roc", "calibration", "binned",
               "leverage", "coef"),
    labels = c(probability = "the probability plot",
               logit = "the logit-scale plot", roc = "ROC Curve",
               calibration = "Calibration Plot",
               binned = "Binned Residuals",
               leverage = "Residuals vs Leverage",
               coef = "Odds Ratios (95% CI)"))

  # The model's variables and the focal one, as in jplot.jst_lm()
  # (Session 360).
  pv          <- .jst_plot_variables(x, iv_names)
  focal_name  <- .jst_plot_focal(focal_name, pv)
  focal_group <- if (isTRUE(focal_name %in% names(pv$groups))) {
    pv$groups[[focal_name]]
  }
  focal_cols  <- if (is.null(focal_group)) {
    focal_name
  } else {
    focal_group$dummy[!is.na(focal_group$dummy)]
  }

  plots <- list()

  # ---- probability plot (S-curve) and its logit-scale companion ----------
  # The two share one computation (Capability Slate C3, Session 378): the
  # linear predictor and its 95% band along the focal variable, every other
  # predictor held where at = puts it. The probability plot draws them
  # through plogis(); the logit plot draws them as they are, where the
  # fitted line is straight, with the cases as a rug along the axis (those
  # with the outcome at the top, the others at the bottom), since a 0/1
  # outcome has no log-odds of its own to plot. At a dummy-coded focal
  # variable's categories, the prediction at each, on either scale.
  if (any(c("probability", "logit") %in% plot_set)) {
    at_vals <- .jst_resolve_at(at, mf, dv_name, focal_cols,
                               x$dummy_coef_names)

    if (!is.null(focal_group)) {
      # A dummy-coded focal variable (Session 360): the predicted
      # probability at each category with its 95% interval, the cases
      # behind them at 0 and 1.
      pred_df  <- .jst_category_predictions(model, focal_group, at_vals,
                                            logistic = TRUE)
      pred_lg  <- .jst_category_predictions(model, focal_group, at_vals,
                                            logistic = TRUE, link = TRUE)
      point_df <- data.frame(x = .jst_case_category(mf, focal_group),
                             y = as.numeric(mf[[dv_name]]))
    } else {
      focal_range <- range(mf[[focal_name]], na.rm = TRUE)
      grid_x <- seq(focal_range[1], focal_range[2], length.out = 120)
      newdata <- data.frame(grid_x)
      names(newdata) <- focal_name
      for (v in names(at_vals)) newdata[[v]] <- at_vals[[v]]
      # A term computed from the focal variable follows it along the axis
      # (Session 347): I(x^2) was held at 0 while x varied, so the line was
      # straight and the subtitle said "(line shown at I(x^2) = 0)".
      on_grid <- .jst_terms_on_grid(newdata, focal_name, at_vals,
                                    environment(x$formula_used))
      newdata <- on_grid$newdata
      at_vals <- at_vals[setdiff(names(at_vals), on_grid$computed)]

      pred_link <- .jst_predict_kept(model, newdata = newdata, type = "link",
                                     se.fit = TRUE)
      t_crit <- 1.96
      link_df <- data.frame(
        x   = grid_x,
        fit = pred_link$fit,
        lwr = pred_link$fit - t_crit * pred_link$se.fit,
        upr = pred_link$fit + t_crit * pred_link$se.fit
      )
      line_df <- data.frame(
        x   = grid_x,
        fit = stats::plogis(link_df$fit),
        lwr = stats::plogis(link_df$lwr),
        upr = stats::plogis(link_df$upr)
      )
      point_df <- data.frame(
        x = mf[[focal_name]],
        y = as.numeric(mf[[dv_name]])
      )
    }

    predicts_label <- if (!is.null(x$predicts)) x$predicts else "1"

    held_note <- .jst_held_note(at_vals, if (is.null(focal_group)) {
      "line"
    } else {
      "probabilities"
    })
  }

  if ("probability" %in% plot_set) {
    p <- if (!is.null(focal_group)) {
      ggplot2::ggplot() +
        ggplot2::geom_point(data = point_df,
                            ggplot2::aes(x = .data$x, y = .data$y),
                            alpha = 0.35, color = .jst_plot_ink$point,
                            position = ggplot2::position_jitter(
                              width = 0.12, height = 0, seed = 1)) +
        .jst_category_layers(pred_df)
    } else {
      ggplot2::ggplot() +
        ggplot2::geom_ribbon(data = line_df,
                             ggplot2::aes(x = .data$x,
                                          ymin = .data$lwr,
                                          ymax = .data$upr),
                             fill = .jst_plot_ink$line, alpha = 0.18) +
        ggplot2::geom_point(data = point_df,
                            ggplot2::aes(x = .data$x, y = .data$y),
                            alpha = 0.35, color = .jst_plot_ink$point) +
        ggplot2::geom_line(data = line_df,
                           ggplot2::aes(x = .data$x, y = .data$fit),
                           color = .jst_plot_ink$line, linewidth = 0.9)
    }
    p <- p +
      ggplot2::labs(
        title    = paste0("Predicted Probability: ", dv_name,
                          " = ", predicts_label),
        x        = .jst_plot_model_label(x, focal_name),
        y        = paste0("P(", dv_name, " = ", predicts_label, ")"),
        subtitle = held_note
      ) +
      ggplot2::ylim(0, 1) +
      .jst_plot_theme()
    print(p)
    plots$probability <- p
  }

  # ---- logit-scale plot (the linear underlayer) ----------------------------
  if ("logit" %in% plot_set) {
    held_lg <- .jst_held_note(at_vals, if (is.null(focal_group)) {
      "line"
    } else {
      "log-odds"
    })
    p <- if (!is.null(focal_group)) {
      ggplot2::ggplot() +
        ggplot2::geom_hline(yintercept = 0, linetype = "dashed",
                            color = "grey60") +
        .jst_category_layers(pred_lg)
    } else {
      rug_df <- point_df
      rug_df$side <- ifelse(rug_df$y == 1, "t", "b")
      ggplot2::ggplot() +
        ggplot2::geom_hline(yintercept = 0, linetype = "dashed",
                            color = "grey60") +
        ggplot2::geom_ribbon(data = link_df,
                             ggplot2::aes(x = .data$x,
                                          ymin = .data$lwr,
                                          ymax = .data$upr),
                             fill = .jst_plot_ink$line, alpha = 0.18) +
        ggplot2::geom_line(data = link_df,
                           ggplot2::aes(x = .data$x, y = .data$fit),
                           color = .jst_plot_ink$line, linewidth = 0.9) +
        ggplot2::geom_rug(data = rug_df[rug_df$side == "t", , drop = FALSE],
                          ggplot2::aes(x = .data$x), sides = "t",
                          alpha = 0.35, color = .jst_plot_ink$point,
                          length = ggplot2::unit(0.03, "npc")) +
        ggplot2::geom_rug(data = rug_df[rug_df$side == "b", , drop = FALSE],
                          ggplot2::aes(x = .data$x), sides = "b",
                          alpha = 0.35, color = .jst_plot_ink$point,
                          length = ggplot2::unit(0.03, "npc"))
    }
    p <- p +
      ggplot2::labs(
        title    = paste0("Log-odds (Logit Scale): ", dv_name,
                          " = ", predicts_label),
        x        = .jst_plot_model_label(x, focal_name),
        y        = paste0("Log-odds of ", dv_name, " = ", predicts_label),
        subtitle = held_lg,
        caption  = if (is.null(focal_group))
          paste0("Rug: cases with ", dv_name, " = ", predicts_label,
                 " at the top, the others at the bottom")
      ) +
      .jst_plot_theme()
    print(p)
    plots$logit <- p
  }

  # ---- coef forest plot (OR scale) -----------------------------------------
  if ("coef" %in% plot_set) {
    summ <- summary(model)$coefficients
    est  <- summ[-1, "Estimate"]
    se   <- summ[-1, "Std. Error"]
    nm   <- rownames(summ)[-1]

    t_crit <- 1.96
    coef_df <- data.frame(
      term  = factor(nm, levels = nm[order(abs(est))]),
      or    = exp(est),
      lower = exp(est - t_crit * se),
      upper = exp(est + t_crit * se),
      stringsAsFactors = FALSE
    )

    p <- ggplot2::ggplot(coef_df,
                         ggplot2::aes(x = .data$or, y = .data$term)) +
      ggplot2::geom_vline(xintercept = 1, linetype = "dashed",
                          color = "grey60") +
      ggplot2::geom_errorbarh(ggplot2::aes(xmin = .data$lower,
                                           xmax = .data$upper),
                              height = 0.2, color = .jst_plot_ink$line) +
      ggplot2::geom_point(size = 2.5, color = .jst_plot_ink$line) +
      ggplot2::scale_x_log10() +
      ggplot2::labs(title = "Odds Ratios (95% CI)",
                    subtitle = "Log scale; OR = 1 means no effect",
                    x = "Exp(b)", y = NULL) +
      .jst_plot_theme()
    print(p)
    plots$coef <- p
  }

  # ---- diagnostic plots (binned / roc / calibration / cooks / leverage) ----
  diag_plots <- intersect(plot_set, c("binned", "roc", "calibration",
                                      "cooks", "leverage"))
  if (length(diag_plots) > 0) {
    diag_result <- .jst_plot_logistic_diagnostics(model, which = diag_plots)
    if (is.list(diag_result)) {
      for (nm in names(diag_result)) plots[[nm]] <- diag_result[[nm]]
    }
  }

  .jst_return_plots(.jst_plot_mark_results(plots, x, n = x$n,
                                           shown = c(dv_name, focal_name)))
}


#' Internal helper: a box plot's groups, labeled as the descriptives label
#' them
#'
#' \code{jplot()} on a \code{jt()} or \code{jaov()} result drew its boxes
#' over the codes -- 1, 2, 3, 4 -- where the Group Descriptives table of the
#' same result reads "1: Control", "2: CBT" (Session 347; the S344 item).
#' The axis now takes the table's labels, which follow \code{value.id} as
#' the call that made the result resolved it. The groups are in the table's
#' order: a labelled variable's codes sorted, a factor's levels in use, a
#' text variable's values with the blank cells last, under \code{<blank>}.
#' A result whose table does not match the groups in its model frame (one
#' made by an older version) keeps the old axis. Called with no
#' \code{groups}, it makes the \code{facet =} variable's panels the same
#' way. (A first definition of this name, earlier in this file, was never
#' called -- R keeps the later -- and was removed at Session 409, Fix Slate
#' V.)
#'
#' @param x The grouping variable from the result's model frame.
#' @param groups Character; the Group column of the result's descriptives,
#'   or \code{NULL}.
#' @return A factor.
#' @keywords internal
.jst_plot_group_factor <- function(x, groups = NULL) {
  if (haven::is.labelled(x)) {
    codes <- .jst_group_codes(x)
    v     <- unclass(x)
    v     <- if (is.character(v)) as.character(v) else .jst_as_numeric(x)
    if (length(groups) == length(codes)) {
      return(factor(v, levels = codes, labels = groups))
    }
    return(droplevels(.jst_code_factor(x)))
  }
  f <- if (is.factor(x)) droplevels(x) else droplevels(.jst_text_factor(x))
  if (length(groups) == nlevels(f)) levels(f) <- groups
  f
}

#' Internal helper: standardized residuals of a comparison of groups
#'
#' Each case's distance from its group's mean, divided by its standard
#' error: \code{e / (s * sqrt(1 - 1/n))}, with \code{n} the group's size and
#' \code{s} the pooled standard deviation (\code{pooled = TRUE}, Student's
#' t-test and the traditional ANOVA, where this is \code{rstandard()} of
#' the one-way model) or the group's own (\code{pooled = FALSE}, Welch's
#' tests, whose groups need not share a variance). A paired test passes the
#' differences as one group. A case of a one-case group, or of a group with
#' no spread, gets \code{NA}. What \code{jt()} and \code{jaov()} return as
#' \code{residuals} and the normal Q-Q plot draws (Session 375; ruling R14,
#' part 2).
#'
#' @param y Numeric vector; the outcome (or the paired differences).
#' @param g The groups, any type; a case missing on either is left out.
#' @param pooled Logical; pool the standard deviation across the groups.
#' @return Numeric vector, the cases complete on both, names kept.
#' @keywords internal
.jst_group_std_resid <- function(y, g, pooled = TRUE) {
  nm <- names(y)
  y  <- as.numeric(y)
  ok <- !is.na(y) & !is.na(g)
  y  <- y[ok]
  gf <- factor(unclass(g)[ok])
  idx <- split(seq_along(y), gf)
  idx <- idx[lengths(idx) > 0L]
  e   <- y - stats::ave(y, gf)
  s   <- if (pooled) {
    df_res <- length(y) - length(idx)
    rep(if (df_res > 0L) sqrt(sum(e^2) / df_res) else NA_real_, length(idx))
  } else {
    vapply(idx, function(ii) if (length(ii) > 1L) stats::sd(y[ii])
                             else NA_real_, numeric(1))
  }
  r <- rep(NA_real_, length(y))
  for (k in seq_along(idx)) {
    ii <- idx[[k]]
    n  <- length(ii)
    if (n > 1L && is.finite(s[k]) && s[k] > 0) {
      r[ii] <- e[ii] / (s[k] * sqrt(1 - 1 / n))
    }
  }
  if (!is.null(nm)) names(r) <- nm[ok]
  r
}

#' Internal helper: the residuals of a jt() or jaov() result
#'
#' The \code{residuals} element, which results made before Session 375 do
#' not carry; for one of those, the stop that asks for the call again.
#'
#' @param x A \code{jst_ttest} or \code{jst_anova} result.
#' @param fn Character(1); \code{"jt"} or \code{"jaov"}.
#' @return Numeric vector.
#' @keywords internal
.jst_result_residuals <- function(x, fn) {
  if (is.null(x$residuals)) {
    .jst_stop("This ", fn, "() result was made by an earlier version of ",
              "jstats and holds no residuals.\n",
              "Run ", fn, "() again to draw the Q-Q plot.")
  }
  x$residuals
}

#' Internal helper: the normal Q-Q plot of a comparison's residuals
#'
#' The standardized residuals against the normal quantiles, the line of
#' equality dashed, the three cases farthest from 0 labeled by their row
#' names (by their pair's number for a paired test) -- the plot
#' \code{jlm()}'s \code{"qq"} draws, for a \code{jt()} or \code{jaov()}
#' result (Session 375; ruling R14, part 2: a plot, not a test). Printed,
#' and returned invisibly.
#'
#' @param r Numeric vector; the standardized residuals.
#' @param paired Logical; the residuals are a paired test's differences.
#' @param n_label Integer; the cases labeled.
#' @return Invisibly, the ggplot.
#' @keywords internal
#' @importFrom rlang .data
.jst_plot_group_qq <- function(r, paired = FALSE, n_label = 3L) {
  lab <- names(r)
  if (is.null(lab) || paired) lab <- as.character(seq_along(r))
  keep <- !is.na(r)
  r    <- unname(r[keep])
  lab  <- lab[keep]
  qq   <- stats::qqnorm(r, plot.it = FALSE)
  df_qq <- data.frame(theoretical = qq$x, sample = qq$y, obs = lab,
                      stringsAsFactors = FALSE)
  idx <- if (length(r) <= n_label) seq_along(r)
         else order(abs(r), decreasing = TRUE)[seq_len(n_label)]
  p <- ggplot2::ggplot(df_qq, ggplot2::aes(x = .data$theoretical,
                                            y = .data$sample)) +
    ggplot2::geom_point(alpha = 0.5) +
    ggplot2::geom_abline(slope = 1, intercept = 0, linetype = "dashed",
                         color = .jst_plot_ink$mark) +
    ggplot2::geom_text(data = df_qq[idx, ],
                       ggplot2::aes(label = .data$obs),
                       hjust = -0.2, size = 3, color = .jst_plot_ink$mark) +
    ggplot2::labs(title = "Normal Q-Q",
                  subtitle = if (paired) "Differences between the pairs",
                  x = "Theoretical Quantiles",
                  y = "Standardized Residuals") +
    .jst_plot_theme()
  print(p)
  invisible(p)
}

#' Internal helper: the line jplot() prints under a comparison's plots
#'
#' jplot() on a model result says what it drew; on a \code{jt()} or
#' \code{jaov()} result it drew the box plot alone, and said nothing. With
#' the Q-Q plot (Session 375; ruling R14, part 2: "as jlm()'s which =
#' "qq"") it says so in jplot()'s words for a model: one diagnostic plot
#' on one line, two plots as a numbered list with the arrow buttons named,
#' since the box plot is then behind the Q-Q plot in the Plots pane. The
#' box plot alone stays silent, as it has been since jplot() drew it. None
#' above, one blank line after (Session 359).
#'
#' @param drawn Character; the names of the plots drawn, in order.
#' @return Invisible NULL.
#' @keywords internal
.jst_group_plot_list <- function(drawn) {
  drawn <- unname(drawn)
  if (!length(drawn) || identical(drawn, "Box Plot")) return(invisible(NULL))
  if (length(drawn) == 1L) {
    cat("(Diagnostic plot produced: ", drawn, ")\n", sep = "")
  } else {
    .jst_msg_out(.jst_fmt_n(length(drawn)), " plots produced\n",
                 .jst_txt_plot_nav)
    for (i in seq_along(drawn)) cat("  ", i, ". ", drawn[i], "\n", sep = "")
  }
  cat("\n")
  invisible(NULL)
}

# -- jplot.jst_ttest -----------------------------------------------------------

#' @describeIn jplot a group-comparison box plot for a \code{jt()} result, with the group means marked; \code{which = "qq"} draws the normal Q-Q plot of its residuals.
#' @export
#' @importFrom rlang .data
jplot.jst_ttest <- function(x, which = "core", ..., style = NULL) {

  .jst_check_args(
    rlang::enquos(...),
    aliases = c(diagnostics = "which", plots = "which",
                show = "which", type = "which"),
    fn_name = "jplot"   # the function the user typed (Session 377)
  )
  .old_look <- .jst_plot_look_set(.jst_plot_look(style))
  on.exit(.jst_plot_look_restore(.old_look), add = TRUE)

  plot_set <- .jst_resolve_which(which, core = "box",
                                 all_plots = c("box", "qq"),
                                 class_name = "jst_ttest")

  mf <- x$model_frame
  if (is.null(mf)) {
    .jst_stop("The jst_ttest object is missing model_frame.\n",
         "Re-run jt() with the current version of the package.")
  }
  terms <- all.vars(x$formula)
  dv_name    <- terms[1]
  group_name <- terms[2]

  plots <- list()

  if ("box" %in% plot_set) {
    plot_df <- data.frame(
      dv    = as.vector(unclass(mf[[dv_name]])),
      group = .jst_plot_group_factor(mf[[group_name]], x$descriptives$Group)
    )

    p <- ggplot2::ggplot(plot_df,
                         ggplot2::aes(x = .data$group, y = .data$dv)) +
      ggplot2::geom_boxplot(fill = .jst_plot_ink$box, color = "#000000",
                            outlier.alpha = 0.6) +
      ggplot2::stat_summary(fun = mean, geom = "point",
                            shape = 18, size = 3, color = .jst_plot_ink$mark) +
      ggplot2::labs(x = .jst_plot_group_label(x, "group", group_name),
                    y = .jst_plot_group_label(x, "outcome", dv_name),
                    subtitle = "Diamond marks the group mean") +
      .jst_plot_theme()
    print(p)
    plots$box <- p
  }

  # The normal Q-Q plot of the residuals (Session 375; ruling R14, part 2).
  if ("qq" %in% plot_set) {
    plots$qq <- .jst_plot_group_qq(.jst_result_residuals(x, "jt"),
                                   paired = identical(x$test_type, "paired"))
  }

  .jst_group_plot_list(c(box = "Box Plot", qq = "Normal Q-Q")[names(plots)])
  .jst_return_plots(.jst_plot_mark_results(
    plots, x, n = x$n,
    titles = c(box = paste(.jst_plot_group_label(x, "outcome", dv_name, wrap = FALSE),
                           "by", .jst_plot_group_label(x, "group", group_name,
                                                       wrap = FALSE))),
    shown = c(dv_name, group_name)))
}


# -- jplot.jst_anova -----------------------------------------------------------

#' @describeIn jplot a group-comparison box plot for a \code{jaov()} result, with the group means marked; \code{which = "qq"} draws the normal Q-Q plot of its residuals.
#' @export
#' @importFrom rlang .data
jplot.jst_anova <- function(x, which = "core", ..., style = NULL) {

  .jst_check_args(
    rlang::enquos(...),
    aliases = c(diagnostics = "which", plots = "which",
                show = "which", type = "which"),
    fn_name = "jplot"   # the function the user typed (Session 377)
  )
  .old_look <- .jst_plot_look_set(.jst_plot_look(style))
  on.exit(.jst_plot_look_restore(.old_look), add = TRUE)

  plot_set <- .jst_resolve_which(which, core = "box",
                                 all_plots = c("box", "qq"),
                                 class_name = "jst_anova")

  mf <- x$model_frame
  if (is.null(mf)) {
    .jst_stop("The jst_anova object is missing model_frame.\n",
         "Re-run jaov() with the current version of the package.")
  }
  terms <- all.vars(x$formula)
  dv_name    <- terms[1]
  group_name <- terms[2]

  plots <- list()

  if ("box" %in% plot_set) {
    plot_df <- data.frame(
      dv    = as.vector(unclass(mf[[dv_name]])),
      group = .jst_plot_group_factor(mf[[group_name]], x$descriptives$Group)
    )

    p <- ggplot2::ggplot(plot_df,
                         ggplot2::aes(x = .data$group, y = .data$dv)) +
      ggplot2::geom_boxplot(fill = .jst_plot_ink$box, color = "#000000",
                            outlier.alpha = 0.6) +
      ggplot2::stat_summary(fun = mean, geom = "point",
                            shape = 18, size = 3, color = .jst_plot_ink$mark) +
      ggplot2::labs(x = .jst_plot_group_label(x, "group", group_name),
                    y = .jst_plot_group_label(x, "outcome", dv_name),
                    subtitle = "Diamond marks the group mean") +
      .jst_plot_theme()
    print(p)
    plots$box <- p
  }

  # The normal Q-Q plot of the residuals (Session 375; ruling R14, part 2).
  if ("qq" %in% plot_set) {
    plots$qq <- .jst_plot_group_qq(.jst_result_residuals(x, "jaov"))
  }

  .jst_group_plot_list(c(box = "Box Plot", qq = "Normal Q-Q")[names(plots)])
  .jst_return_plots(.jst_plot_mark_results(
    plots, x, n = x$n,
    titles = c(box = paste(.jst_plot_group_label(x, "outcome", dv_name, wrap = FALSE),
                           "by", .jst_plot_group_label(x, "group", group_name,
                                                       wrap = FALSE))),
    shown = c(dv_name, group_name)))
}


# -- jplot.jst_corr ------------------------------------------------------------

#' @describeIn jplot a heat-map of the correlation matrix for a \code{jcorr()} result, or a scatter plot for a single pair.
#' @export
#' @importFrom rlang .data
jplot.jst_corr <- function(x, which = "core", ..., style = NULL) {

  .jst_check_args(
    rlang::enquos(...),
    aliases = c(diagnostics = "which", plots = "which",
                show = "which", type = "which"),
    fn_name = "jplot"   # the function the user typed (Session 377)
  )
  .old_look <- .jst_plot_look_set(.jst_plot_look(style))
  on.exit(.jst_plot_look_restore(.old_look), add = TRUE)

  r_matrix <- x$r
  n_vars   <- nrow(r_matrix)

  default_core <- if (n_vars >= 3) "heatmap" else "scatter"
  all_plots <- if (n_vars >= 3) "heatmap" else c("scatter", "heatmap")

  # A scatter plot is drawn only for two variables. Asked of a result of
  # three or more, the stop says so and gives the two-variable call (Fix
  # Slate 23, Session 377; Jeff: "Default okay."), where it said scatter
  # "is not a plot of a jcorr() result". The data frame is the one the
  # result was made from (data_name, since v0.9.250; MyData for an older
  # result) and the method stays as it was.
  explain <- NULL
  if (n_vars >= 3) {
    vn <- rownames(r_matrix)[1:2]
    dn <- x$data_name
    dx <- if (is.character(dn) && length(dn) == 1L)
      tryCatch(str2lang(dn), error = function(e) NULL)
    if (!(is.symbol(dx) ||
          (is.call(dx) && identical(dx[[1L]], as.name("$"))))) {
      dn <- "MyData"   # an older result, or an expression given as the data
    }
    meth <- if (!is.null(x$method) && !identical(x$method, "pearson"))
      paste0(", method = \"", x$method, "\"") else ""
    explain <- c(scatter = paste0(
      "a scatter plot needs a jcorr() result with exactly two variables, ",
      "and this one has ", n_vars, ".\n",
      "Correlate two of them and plot that result, for example:\n",
      "  r2 <- jcorr(", dn, ", ", vn[1], ", ", vn[2], meth, ")\n",
      "  jplot(r2, which = \"scatter\")"))
  }

  plot_set <- .jst_resolve_which(which, core = default_core,
                                 all_plots = all_plots,
                                 class_name = "jst_corr",
                                 explain = explain)

  plots <- list()

  if ("heatmap" %in% plot_set) {
    var_names <- rownames(r_matrix)
    heat_df <- expand.grid(
      row = factor(var_names, levels = var_names),
      col = factor(var_names, levels = rev(var_names)),
      stringsAsFactors = FALSE
    )
    heat_df$r <- as.vector(r_matrix[cbind(match(heat_df$row, var_names),
                                           match(heat_df$col, var_names))])
    heat_df$label <- ifelse(is.na(heat_df$r), "",
                            sprintf("%.2f", heat_df$r))
    # In greys (ruling R64, Session 411; the lean taken Session 415): a
    # grey scale cannot show a correlation's sign, so each tile is shaded by
    # its strength, the absolute value of r, from white to dark grey, and
    # the sign is in the value printed on it, white on the darker tiles.
    heat_df$strength <- abs(heat_df$r)
    text_col <- ifelse(!is.na(heat_df$strength) & heat_df$strength > 0.6,
                       "#FFFFFF", "#000000")

    # The variables by their labels, the names where none (the S412 audit's
    # F4, Session 413: a chart's words come from labels), on two lines past
    # about 20 columns.
    hl <- vapply(var_names, function(v) {
      l <- if (is.null(x$labels)) NA_character_ else unname(x$labels[v])
      if (is.na(l) || !nzchar(l)) v else .jst_plot_wrap(l, 20L)
    }, character(1))
    look_h <- .jst_plot_look_now()
    p <- ggplot2::ggplot(heat_df,
                         ggplot2::aes(x = .data$row, y = .data$col,
                                      fill = .data$strength)) +
      ggplot2::geom_tile(color = "white", linewidth = 0.5) +
      ggplot2::geom_text(ggplot2::aes(label = .data$label),
                         size = look_h$size * 0.8 / ggplot2::.pt,
                         family = .jst_plot_family(look_h$font),
                         color = text_col) +
      ggplot2::scale_fill_gradient(low = "#FFFFFF", high = "#404040",
                                   limits = c(0, 1), na.value = "#F2F2F2") +
      ggplot2::scale_x_discrete(labels = hl) +
      ggplot2::scale_y_discrete(labels = hl) +
      ggplot2::labs(title = "Correlation Matrix",
                    x = NULL, y = NULL, fill = "|r|") +
      .jst_plot_theme() +
      .jst_plot_heat_tweak()
    attr(p, "jst_tweak") <- .jst_plot_heat_tweak()
    # The Excel sheet: the matrix as the tiles show it.
    attr(p, "jst_data") <- {
      sh <- as.data.frame(unclass(r_matrix), stringsAsFactors = FALSE)
      rownames(sh) <- NULL
      cbind(data.frame(Variable = var_names, stringsAsFactors = FALSE), sh)
    }
    print(p)
    plots$heatmap <- p
  }

  if ("scatter" %in% plot_set) {
    mf <- x$model_frame
    if (is.null(mf)) {
      .jst_stop("Scatter plot requires model_frame on the jst_corr object.\n",
           "Re-run jcorr() with the current version of the package.")
    }
    if (ncol(mf) != 2) {
      .jst_stop("Scatter plot is only available when jcorr() was called with ",
           "exactly 2 variables.")
    }
    var_names <- colnames(mf)
    r_val <- r_matrix[1, 2]
    n_val <- x$n[1, 2]
    # The pairs the correlation used (Session 377): a case missing either
    # value is left out here, as it was from r and N, where ggplot2 dropped
    # it with its own "Removed 4 rows containing missing values" warning.
    mf <- mf[!is.na(mf[[1L]]) & !is.na(mf[[2L]]), , drop = FALSE]

    lab_of <- function(v, wrap = TRUE) {
      l <- if (is.null(x$labels)) NA_character_ else unname(x$labels[v])
      if (is.na(l) || !nzchar(l)) v else if (wrap) .jst_plot_wrap(l) else l
    }
    p <- ggplot2::ggplot(mf,
                         ggplot2::aes(x = .data[[var_names[1]]],
                                      y = .data[[var_names[2]]])) +
      ggplot2::geom_point(alpha = 0.55, color = .jst_plot_ink$point) +
      ggplot2::labs(subtitle = sprintf("r = %.3f, N = %d", r_val, n_val),
                    x = lab_of(var_names[1]), y = lab_of(var_names[2])) +
      .jst_plot_theme()
    attr(p, "jst_title") <- paste(lab_of(var_names[2], FALSE), "by",
                                  lab_of(var_names[1], FALSE))
    attr(p, "jst_n") <- n_val
    print(p)
    plots$scatter <- p
  }

  .jst_return_plots(.jst_plot_mark_results(
    plots, x, n = if (!is.null(x$n)) min(x$n[lower.tri(x$n)], na.rm = TRUE) else NA,
    shown = rownames(r_matrix)))
}


# -- jplot.jst_crosstab --------------------------------------------------------

#' @describeIn jplot a grouped bar chart of cell counts for a \code{jcrosstab()} result.
#' @export
#' @importFrom rlang .data
jplot.jst_crosstab <- function(x, which = "core", ..., style = NULL) {

  .jst_check_args(
    rlang::enquos(...),
    aliases = c(diagnostics = "which", plots = "which",
                show = "which", type = "which"),
    fn_name = "jplot"   # the function the user typed (Session 377)
  )
  look <- .jst_plot_look(style)
  .old_look <- .jst_plot_look_set(look)
  on.exit(.jst_plot_look_restore(.old_look), add = TRUE)

  plot_set <- .jst_resolve_which(which, core = "bar", all_plots = "bar",
                                 class_name = "jst_crosstab")

  plots <- list()

  if ("bar" %in% plot_set) {
    obs <- x$observed
    row_labels <- rownames(obs)
    col_labels <- colnames(obs)
    if (tail(row_labels, 1) == "Total") {
      obs <- obs[-nrow(obs), , drop = FALSE]
      row_labels <- row_labels[-length(row_labels)]
    }
    if (tail(col_labels, 1) == "Total") {
      obs <- obs[, -ncol(obs), drop = FALSE]
      col_labels <- col_labels[-length(col_labels)]
    }

    bar_df <- expand.grid(
      row = factor(row_labels, levels = row_labels),
      col = factor(col_labels, levels = col_labels),
      stringsAsFactors = FALSE
    )
    bar_df$count <- as.vector(as.matrix(obs))

    # The column variable's categories side by side in the look's colors,
    # the row variable along the axis, each titled by its label (Session
    # 415: the S412 audit's F4; ruling R64's legend with its title).
    rv <- attr(x$row_categories, "variable")
    cv <- attr(x$col_categories, "variable")
    vlab <- function(a, wrap = TRUE) {
      if (is.null(a)) return(NULL)
      l <- unname(a["label"]); nm <- unname(a["name"])
      if (is.na(l) || !nzchar(l)) nm else if (wrap) .jst_plot_wrap(l) else l
    }
    sc <- list(list(aes = "fill", levels = col_labels, guide = TRUE))
    p <- ggplot2::ggplot(bar_df,
                         ggplot2::aes(x = .data$row, y = .data$count,
                                      fill = .data$col)) +
      ggplot2::geom_col(position = ggplot2::position_dodge(width = 0.8),
                        width = 0.7) +
      (if (identical(look$values.grouped, "yes"))
        ggplot2::geom_text(ggplot2::aes(label = .data$count, group = .data$col),
                           position = ggplot2::position_dodge(width = 0.8),
                           vjust = -0.4, size = look$size * 0.8 / ggplot2::.pt,
                           family = .jst_plot_family(look$font),
                           colour = "#000000")) +
      ggplot2::labs(x = vlab(rv), y = "Count", fill = vlab(cv)) +
      .jst_plot_zero_y(count = TRUE) +
      .jst_plot_theme()
    p <- .jst_plot_add_scales(p, sc, look)
    attr(p, "jst_title") <- if (!is.null(rv) && !is.null(cv)) {
      paste(vlab(rv, FALSE), "by", vlab(cv, FALSE))
    }
    attr(p, "jst_scales") <- sc
    attr(p, "jst_data") <- {
      sh <- data.frame(as.character(bar_df$row), as.character(bar_df$col),
                       bar_df$count, stringsAsFactors = FALSE)
      names(sh) <- c(if (is.null(rv)) "Row" else unname(rv["name"]),
                     if (is.null(cv)) "Column" else unname(cv["name"]), "n")
      sh
    }
    print(p)
    plots$bar <- p
  }

  .jst_return_plots(.jst_plot_mark_results(
    plots, x, n = if (!is.null(x$n)) as.numeric(x$n) else NA,
    shown = c(if (!is.null(attr(x$row_categories, "variable")))
                unname(attr(x$row_categories, "variable")["name"]),
              if (!is.null(attr(x$col_categories, "variable")))
                unname(attr(x$col_categories, "variable")["name"]))))
}


# -- jplot.jst_desc / jplot.jst_freq (deferred to v2) --------------------------

#' @describeIn jplot (planned) direct plotting of a \code{jdesc()} result is not yet available; this method points you to the data-first form, for example \code{jplot(data, Variable)}.
#' @export
jplot.jst_desc <- function(x, which = "core", ...) {
  .jst_plot_result_stop(x, substitute(x),
       "Call jplot() with the data frame instead, for example:\n",
       "  jplot(community, Age)       # histogram\n",
       "  jplot(community, Region)    # bar chart\n",
       "  jplot(WellbeingScore ~ Region, community, categorical = \"Region\")  # boxplot")
}

#' @describeIn jplot (planned) direct plotting of a \code{jfreq()} result is not yet available; this method points you to the data-first form, for example \code{jplot(data, Variable)}.
#' @export
jplot.jst_freq <- function(x, which = "core", ...) {
  .jst_plot_result_stop(x, substitute(x),
       "Call jplot() with the data frame instead, for example:\n",
       "  jplot(community, Region)    # bar chart\n",
       "  jplot(community, Region, Volunteer, ",
       "categorical = c(\"Region\", \"Volunteer\"))  # grouped bar chart")
}

#' @describeIn jplot a \code{jalpha()} result is not drawn; this method says
#'   so and points you to the data-first form for its items, for example
#'   \code{jplot(data, Item1)}.
#' @export
jplot.jst_alpha <- function(x, which = "core", ...) {
  .jst_plot_result_stop(x, substitute(x), .jst_plot_items_line(x))
}

#' @describeIn jplot a \code{jmulti()} result is not drawn; this method says
#'   so and points you to the data-first form for its items.
#' @export
jplot.jst_multi <- function(x, which = "core", ...) {
  .jst_plot_result_stop(x, substitute(x), .jst_plot_items_line(x))
}

#' Internal: jplot()'s note on arguments the plot drawn does not use
#'
#' line, band, equation and r2 apply only to a scatter plot with line =
#' "lm". When the call names any of them for a plot that does not use
#' them, one yellow note lists them. jplot.default() and
#' .jst_jplot_formula() each held this block (Session 386, the twin
#' build).
#'
#' @param jplot_call The call as typed (match.call()).
#' @param resolved_type Character(1): the plot type drawn.
#' @param line The call's line argument.
#' @return NULL, invisibly; prints the note when one applies.
#' @keywords internal
.jst_plot_ignored_note <- function(jplot_call, resolved_type, line) {
  called_args   <- names(jplot_call)
  explicit_args <- called_args[nzchar(called_args)]
  is_scatter_lm <- resolved_type == "scatter" &&
                   (identical(line, "lm") || identical(line, TRUE))
  ignored <- character(0)
  if ("line" %in% explicit_args && resolved_type != "scatter") {
    ignored <- c(ignored, "line")
  }
  if ("band" %in% explicit_args && !is_scatter_lm) {
    ignored <- c(ignored, "band")
  }
  if ("equation" %in% explicit_args && !is_scatter_lm) {
    ignored <- c(ignored, "equation")
  }
  if ("r2" %in% explicit_args && !is_scatter_lm) {
    ignored <- c(ignored, "r2")
  }
  if (length(ignored) > 0) {
    .cat_yellow(paste0(
      "(Note: ", paste(ignored, collapse = ", "),
      " not applicable to ", resolved_type,
      if (resolved_type == "scatter") " without line = \"lm\"" else "",
      " -- ignored)\n"
    ))
  }
  invisible(NULL)
}

#' Internal: jplot()'s labelled variables made ready to draw
#'
#' Conversion follows each variable's resolved class (var_types), never
#' the presence of value labels: a categorical-typed labelled variable
#' becomes a factor of its labels (haven::as_factor()), any other
#' labelled variable its underlying numbers, so the geometry and the
#' conversion agree (a labelled Likert as a histogram, a labelled outcome
#' on a scatter or a box's y-axis). var_types is indexed with \code{[[i]]}, which
#' drops a name, so identical() matches whether or not it was built named.
#' The by variable becomes a factor, of its value labels when it has
#' them. jplot.default() and .jst_jplot_formula() each held this block
#' (Session 386, the twin build).
#'
#' @param data The data frame being plotted.
#' @param variable_names Character: the plotted variables, in the order of
#'   var_types.
#' @param var_types Character: each variable's resolved class.
#' @param by_name Character(1) or NULL: the by variable.
#' @param has_by Logical(1): whether a by variable is in use.
#' @return The data frame, converted.
#' @keywords internal
.jst_plot_convert_labelled <- function(data, variable_names, var_types,
                                       by_name, has_by) {
  for (i in seq_along(variable_names)) {
    v <- variable_names[i]
    if (!haven::is.labelled(data[[v]])) next
    if (identical(var_types[[i]], "categorical")) {
      data[[v]] <- .jst_code_factor(data[[v]])
    } else {
      data[[v]] <- as.numeric(data[[v]])
    }
  }
  if (has_by && haven::is.labelled(data[[by_name]])) {
    val_labs <- labelled::val_labels(data[[by_name]])
    if (!is.null(val_labs) && length(val_labs) > 0) {
      data[[by_name]] <- .jst_code_factor(data[[by_name]])
    } else {
      data[[by_name]] <- factor(data[[by_name]])
    }
  } else if (has_by && !is.factor(data[[by_name]])) {
    data[[by_name]] <- factor(data[[by_name]])
  }
  data
}

#' Internal: stop when a variable is named both categorical and numeric
#'
#' jplot()'s data-first and formula forms (Session 383). numeric and count
#' are both numeric-like, so they do not clash with each other.
#'
#' @param categorical,numeric,count Character. The names in each argument.
#' @return NULL, invisibly; stops on a clash.
#' @keywords internal
.jst_check_cat_clash <- function(categorical, numeric, count) {
  clash <- intersect(categorical, c(numeric, count))
  if (length(clash) > 0) {
    .jst_stop(.jst_and_list(paste0("'", clash, "'")),
              .jst_plural(length(clash), " is", " are"),
              " listed in both categorical = and numeric = or count =.")
  }
  invisible(NULL)
}

#' Internal: the stop for a result jplot() does not draw
#'
#' A jdesc(), jfreq(), jalpha() or jmulti() result. Named as the house
#' voice names a result -- "a jdesc() result", as jsave() says it, never
#' the class (Session 415; until then "Plotting jst_desc result objects is
#' not supported.") -- and, given by its name, by that name (Rule AD). A
#' jalpha() or jmulti() result went on to jplot.default(), which read it
#' as a variable name and said it was not a data frame (Session 415; found
#' in build 1).
#'
#' @param x The result.
#' @param x_sub The result as typed.
#' @param ... The lines after the first: what jplot() takes, and an example.
#' @return Does not return; stops.
#' @keywords internal
.jst_plot_result_stop <- function(x, x_sub, ...) {
  fn <- .jst_table_result_fn(x)
  # The prefix names jplot(), so the first line does not (the presentation
  # review's entry 5, Session 414, for jtable()'s stops).
  .jst_stop(if (is.symbol(x_sub)) paste0(as.character(x_sub), " is a ", fn,
                                         " result, which has no chart of its own.\n")
            else paste0("a ", fn, " result has no chart of its own.\n"),
            ..., fn = "jplot")
}

#' Internal: the line a result jplot() does not draw offers
#'
#' Its items, drawn from the data frame it was made from: the frame's name
#' as the result keeps it, else MyData, and its first item.
#'
#' @param x A jalpha() or jmulti() result.
#' @return Character(1), the example's lines after the first.
#' @keywords internal
.jst_plot_items_line <- function(x) {
  items <- if (inherits(x, "jst_alpha") && is.data.frame(x$items_raw)) x$items_raw$item
           else if (inherits(x, "jst_multi")) x$items
  items <- items[!is.na(items)]
  dn <- if (is.character(x$data_name) && length(x$data_name) == 1L &&
            !is.na(x$data_name) && nzchar(x$data_name)) x$data_name else "MyData"
  v <- if (length(items)) items[[1L]] else "Variable"
  paste0("A chart is drawn from the variables of a data frame, or from a jlm(), ",
         "jlogistic(), jt(), jaov(), jcorr() or jcrosstab() result.\n",
         "To draw an item, give jplot() the data frame and the item, for example:\n",
         "  jplot(", dn, ", ", v, ")")
}
