#<<<FILE: plot.R>>>


# =============================================================================
#  PLOTTING
# =============================================================================

# -- jplot ---------------------------------------------------------------------

#' Visualise jst_* result objects or plot variables directly from a data frame
#'
#' Unified plotting function. Can be called in three ways:
#'
#' \strong{Result-object form:} Pass a result object returned by one of the
#' package's analysis functions. Produces appropriate plots for each class of
#' result (see valid plot names below).
#'
#' \strong{Formula form} (for plots that distinguish DV from IV): Pass a
#' formula as the first argument, followed optionally by a data frame. Used
#' for scatterplots and boxplots, consistent with the formula syntax of
#' \code{jlm()}, \code{jaov()}, and \code{jt()}. The DV on the left of
#' \code{~} goes on the y-axis; the IV on the right goes on the x-axis. Only
#' single-IV formulas are supported here; for multi-IV models, fit with
#' \code{jlm()} and pass the result to \code{jplot()}.
#'
#' \strong{Variable-list form} (for distributions and counts): Pass a data
#' frame followed by one or two unquoted variable names. Used for histograms
#' (1 numeric), bar charts (1 categorical), and grouped bar charts (2
#' categorical). Calls that would otherwise auto-detect to a scatter or
#' boxplot produce a helpful error directing you to the formula form.
#'
#' Supports pipeline integration (\code{jsubset}, \code{jcomplete}, per-call
#' \code{subset}), grouping via \code{by = }, and regression lines with
#' equation/R-squared/band annotations.
#'
#' Valid plot names by class (for the result-object form):
#' \itemize{
#'   \item \code{jst_lm}: \code{fit}, \code{predicted}, \code{effects},
#'     \code{coef}, \code{vif}, \code{residuals}, \code{qq},
#'     \code{scale}, \code{cooks}, \code{leverage}
#'   \item \code{jst_logistic}: \code{probability}, \code{roc},
#'     \code{calibration}, \code{binned}, \code{cooks}, \code{leverage},
#'     \code{coef}, \code{vif}
#'   \item \code{jst_ttest}, \code{jst_anova}: \code{box}
#'   \item \code{jst_corr}: \code{heatmap}, \code{scatter} (scatter requires
#'     exactly 2 variables in the correlation)
#'   \item \code{jst_crosstab}: \code{bar}
#' }
#'
#' The shortcut keyword \code{core} (default) produces a curated default
#' set for the class; \code{all} produces every plot the class supports.
#'
#' Valid plot types for the data-first form: \code{histogram}, \code{bar},
#' \code{scatter}, \code{box}, \code{grouped_bar}.
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
#' @param focal Unquoted name of the independent variable to place on the
#'   x-axis for \code{jst_lm} / \code{jst_logistic} \code{fit} and
#'   \code{probability} plots. Defaults to the first IV in the model.
#' @param at Character string or named list specifying where non-focal
#'   independent variables are held when drawing the fitted line in
#'   \code{jst_lm} / \code{jst_logistic} methods. One of \code{zero}
#'   (default), \code{mean}, \code{mixed} (categorical at 0, interval
#'   at mean), or a named list \code{list(Var1 = value, ...)}.
#' @param equation Logical. If TRUE (default), displays the equation in the
#'   subtitle for \code{line = "lm"} scatter plots (data-first form) or
#'   \code{jst_lm} \code{fit} plots (result-object form).
#' @param r2 Logical. If TRUE (default), displays R-squared in the subtitle
#'   alongside the equation.
#' @param by Unquoted variable name for group-coloring (data-first form).
#' @param type Character. Plot type override for the data-first form. One
#'   of \code{histogram}, \code{bar}, \code{scatter}, \code{box},
#'   \code{grouped_bar}. If NULL (default), auto-detected from variable
#'   types.
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
#' @param labels Character or NULL. Variable label display mode (data-first
#'   and formula forms): one of \code{"both"}, \code{"names"}, \code{"labels"},
#'   \code{"legend"}, or \code{"legend.bottom"}. \code{"names"} uses variable
#'   names as axis/legend titles; \code{"labels"} uses each variable's label
#'   as its axis/legend title instead (falling back to the name when
#'   unlabelled) and prints no console legend; \code{"legend"} and
#'   \code{"legend.bottom"} keep names on the axes and print a console label
#'   legend. \code{"both"} is accepted but currently renders as \code{"names"}
#'   on plots (the \code{"name: label"} form for plot titles is deferred to a
#'   later phase). NULL (default) defers to \code{joutput()}'s
#'   \code{variable.id} setting. Not a logical.
#' @param numeric Optional character vector of plotted-variable names to treat
#'   as continuous for this call (the per-call counterpart of
#'   \code{jnumeric()}). In \code{jplot()} a variable's class chooses the
#'   geometry, so this forces numeric handling (histogram for a single
#'   variable; scatter / numeric axis in the formula and two-variable forms).
#'   Applies to the plotted variables only, not the \code{by} grouping
#'   variable.
#' @param categorical Optional character vector of plotted-variable names to
#'   treat as categorical for this call (the per-call counterpart of
#'   \code{jdummy()} for plotting purposes). Forces categorical geometry (bar
#'   for a single variable; box / categorical axis in the formula form). A
#'   variable cannot be listed in both \code{categorical} and
#'   \code{numeric}/\code{count}.
#' @param count Optional character vector of plotted-variable names to treat
#'   as counts for this call (the per-call counterpart of \code{jcount()}). A
#'   count is numeric-like for plotting, so it draws the same as \code{numeric};
#'   it is provided for symmetry with the other analysis functions.
#'
#' @return Invisibly, a single \code{ggplot} object if one plot is produced,
#'   or a named list of \code{ggplot} objects if multiple are produced
#'   (result-object form). Invisibly returns the \code{ggplot} object for
#'   the data-first form.
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
#' # Boxplot: assert the grouping variable as categorical (labelled
#' # variables otherwise enter numerically; jdummy() registration also works)
#' jplot(WellbeingScore ~ Region, community, categorical = "Region")
#'
#' # Variable-list form (distributions and counts)
#' jplot(community, Age)                      # histogram
#' jplot(community, Region)                   # bar chart
#' jplot(community, Region, Volunteer,        # grouped bar chart
#'       categorical = c("Region", "Volunteer"))
#'
#' @seealso \code{\link{jstats}} for the package overview,
#'   workflow conventions, and complete function listing.
#'
#' @export
#' @importFrom stats setNames
#' @importFrom utils tail
jplot <- function(x, which = "core", ...) {
  UseMethod("jplot")
}

#' @rdname jplot
#' @export
#' @importFrom rlang .data
jplot.default <- function(x, ..., by = NULL, type = NULL,
                          line = FALSE, equation = TRUE, r2 = TRUE,
                          band = "ci", subset = NULL, labels = NULL,
                          numeric = NULL, categorical = NULL, count = NULL) {

  # Capture the call for later argument-inspection (used by the ignored-arg
  # note that fires when, e.g., the user passes line = "lm" to a histogram).
  jplot_call <- match.call()

  # ---------------------------------------------------------------------------
  # Formula-first path: jplot(DV ~ IV, data) for scatter/box where a DV/IV
  # distinction is meaningful.  Detected BEFORE the data-frame branch because
  # `x` in this case is a formula, not a data frame.
  # ---------------------------------------------------------------------------
  if (!missing(x) && inherits(x, "formula")) {
    by_sub <- substitute(by)
    return(.jst_jplot_formula(x, jplot_call, ...,
                              by_expr = by_sub, type = type, line = line,
                              equation = equation, r2 = r2, band = band,
                              subset_expr = substitute(subset),
                              labels = labels,
                              numeric = numeric, categorical = categorical,
                              count = count,
                              parent_env = parent.frame()))
  }

  # Resolve the first argument: explicit data frame, juse default,
  # or bare-symbol-as-variable-name (leading comma omitted).
  arg1 <- .jst_resolve_first_arg(
    data_sub      = substitute(x),
    data_missing  = missing(x),
    fn_name       = "jplot",
    envir         = parent.frame(),
    accept_vector = FALSE
  )

  # Alias to `data` internally for clarity; the generic uses `x` for S3 consistency
  data              <- arg1$data
  .jst_data_name    <- arg1$name
  .jst_default_used <- arg1$mode %in% c("default", "symbol_with_default")

  if (!is.data.frame(data)) {
    stop("jplot(): the first argument must be a data frame. ",
         "To plot a result object (e.g. from jlm()), pass it as the first ",
         "argument: jplot(my_result).",
         call. = FALSE)
  }

  if (!requireNamespace("ggplot2", quietly = TRUE)) {
    .jst_stop("Package 'ggplot2' is required for jplot(). ",
         "Install with: install.packages(\"ggplot2\")")
  }

  # Capture variable names
  variables <- rlang::enquos(...)

  # Leading-comma-omitted: prepend the captured symbol to variables list
  if (arg1$mode == "symbol_with_default") {
    extra_quo <- rlang::new_quosure(arg1$first_arg_sub,
                                    env = parent.frame())
    variables <- c(list(extra_quo), variables)
    class(variables) <- "quosures"
  }

  variable_names <- vapply(variables, rlang::quo_name, character(1))
  by_quo         <- rlang::enquo(by)
  has_by         <- !rlang::quo_is_null(by_quo)
  by_name        <- if (has_by) rlang::quo_name(by_quo) else NULL

  n_vars <- length(variable_names)
  if (n_vars == 0) {
    stop("jplot(): no variables specified. Provide one or more variable ",
         "names, e.g. jplot(SampleData, Age, Tattoos).", call. = FALSE)
  }
  if (n_vars > 2) {
    stop("jplot(): only 1 or 2 variables can be plotted at once. ",
         "For more variables, use `by =` to add a grouping variable ",
         "(e.g. jplot(data, x, y, by = Gender)) or call jplot() ",
         "multiple times.", call. = FALSE)
  }

  # Check all variables exist
  check_names <- variable_names
  if (has_by) check_names <- c(check_names, by_name)
  .jst_check_vars(data, check_names, .jst_data_name, default_used = .jst_default_used)

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
        .jst_stop(.arg, " argument: ", paste0("'", .bad, "'", collapse = ", "),
             " not found among the variables passed to jplot(). Check for typos.")
      }
    }
  }
  # A variable cannot be both categorical and numeric-like (the assertions
  # contradict). numeric and count are both numeric-like, so they do not clash.
  .cat_clash <- intersect(categorical, c(numeric, count))
  if (length(.cat_clash) > 0) {
    .jst_stop(paste0("'", .cat_clash, "'", collapse = ", "),
         " listed in both categorical and numeric/count arguments.")
  }

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
                                  envir = parent.frame())
  data <- pipeline$data
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
  if (n_vars == 1L && is.null(type) && var_types[1] == "numeric") {
    v1 <- variable_names[1]
    asserted_numeric <- v1 %in% c(numeric, count)
    intent <- if (!is.null(.jst_data_name))
      .jst_get_intent(.jst_data_name, v1) else NULL
    registered_numeric <- !is.null(intent) &&
      intent$kind %in% c("numeric", "count")
    if (!asserted_numeric && !registered_numeric &&
        inherits(data[[v1]], "haven_labelled") &&
        .jst_is_discrete_integer(data[[v1]], v1, .jst_data_name)) {
      var_types[1] <- "categorical"
    }
  }

  # Auto-detect plot type if not specified
  resolved_type <- type
  if (is.null(resolved_type)) {
    resolved_type <- .jst_auto_plot_type(var_types, n_vars)
  }

  valid_types <- c("histogram", "bar", "scatter", "box", "grouped_bar")
  if (!resolved_type %in% valid_types) {
    .jst_stop("Invalid `type` value: \"", resolved_type, "\".\n",
         "Valid types: ", paste(sprintf("\"%s\"", valid_types),
                                 collapse = ", "), ".")
  }

  # -- Require formula syntax for scatter and box (relationship plots) ------
  # These plots distinguish DV from IV. Requiring formula syntax prevents
  # confusion about which variable goes on which axis and mirrors jlm/jaov.
  if (resolved_type == "scatter") {
    .jst_stop("For two-numeric scatterplots, use formula syntax to make the DV ",
         "and IV explicit (consistent with jlm):\n",
         "  jplot(", variable_names[2], " ~ ", variable_names[1],
         ", ", if (!is.null(.jst_data_name)) .jst_data_name else "MyData",
         if (!identical(line, FALSE)) paste0(", line = \"",
                                             if (isTRUE(line)) "lm" else line,
                                             "\"") else "",
         ")\n",
         "(The DV on the left of ~ goes on the y-axis; the IV on the right ",
         "goes on the x-axis.)")
  }
  if (resolved_type == "box") {
    # Numeric goes on y, categorical on x — i.e. numeric ~ categorical
    num_var <- variable_names[var_types == "numeric"][1]
    cat_var <- variable_names[var_types == "categorical"][1]
    .jst_stop("For boxplots, use formula syntax to make the outcome and grouping ",
         "variable explicit (consistent with jaov):\n",
         "  jplot(", num_var, " ~ ", cat_var, ", ",
         if (!is.null(.jst_data_name)) .jst_data_name else "MyData", ")\n",
         "(The numeric outcome on the left of ~ goes on the y-axis; the ",
         "categorical grouping variable on the right goes on the x-axis.)")
  }

  # -- Note about arguments ignored for this plot type ----------------------
  # line/band/equation/r2 apply only to scatter plots with line = "lm".
  # If the user explicitly passed any of these but the resolved plot type
  # doesn't use them, emit a single consolidated yellow note.
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
      " \u2014 ignored)\n"
    ))
  }

  # -- Capture axis labels BEFORE factor conversion strips them ------------
  # Variable label display mode. jplot is a collapse layout where the
  # analogue of "names in rows" is the axis/legend title: under "labels" each
  # axis shows the variable's label, otherwise its name. "legend"/
  # "legend.bottom" additionally print a console label legend (below).
  vlmode <- .jst_resolve_variable_id(labels)
  axis_labels <- stats::setNames(
    vapply(variable_names,
           function(v) if (identical(vlmode, "labels")) {
             .jst_short_label(data[[v]], v)
           } else {
             v
           },
           character(1)),
    variable_names
  )
  by_label <- if (has_by) {
    if (identical(vlmode, "labels")) .jst_short_label(data[[by_name]], by_name) else by_name
  } else NULL

  # -- Red title --------------------------------------------------------------
  plot_title <- .jst_plot_title(resolved_type, variable_names, by_name)
  .cat_red(paste0(plot_title, "\n"))

  # Print pipeline messages (default data frame note, filter/complete status)
  if (.jst_default_used) .jst_default_note(.jst_data_name)
  .jst_print_msgs(pipeline$msgs)

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
  for (i in seq_along(variable_names)) {
    v <- variable_names[i]
    if (!haven::is.labelled(data[[v]])) next
    if (identical(var_types[[i]], "categorical")) {
      data[[v]] <- haven::as_factor(data[[v]])
    } else {
      data[[v]] <- as.numeric(data[[v]])
    }
  }
  if (has_by && haven::is.labelled(data[[by_name]])) {
    val_labs <- labelled::val_labels(data[[by_name]])
    if (!is.null(val_labs) && length(val_labs) > 0) {
      data[[by_name]] <- haven::as_factor(data[[by_name]])
    } else {
      data[[by_name]] <- factor(data[[by_name]])
    }
  } else if (has_by && !is.factor(data[[by_name]])) {
    data[[by_name]] <- factor(data[[by_name]])
  }

  # Console label legend (only under "legend"/"legend.bottom"; collapse).
  if (vlmode %in% c("legend", "legend.bottom")) {
    .print_var_labels(data, check_names)
  }

  # Dispatch to plot builder
  p <- switch(
    resolved_type,
    histogram   = .jst_build_histogram(data, variable_names[1], by_name,
                                       axis_labels, by_label),
    bar         = .jst_build_bar(data, variable_names[1], by_name,
                                 axis_labels, by_label),
    scatter     = .jst_build_scatter(data, variable_names, by_name,
                                     line, equation, r2, band,
                                     axis_labels, by_label),
    box         = .jst_build_box(data, variable_names, var_types, by_name,
                                 axis_labels, by_label),
    grouped_bar = .jst_build_grouped_bar(data, variable_names,
                                         axis_labels)
  )

  print(p)
  invisible(p)
}


#' Internal helper: handle the formula-first form of jplot
#'
#' Called by \code{jplot.default} when the first argument is a formula.
#' Parses the formula into DV (y-axis) and IV (x-axis), resolves the data
#' frame from the second positional argument or juse default, and dispatches
#' to the scatter or box builder depending on the IV's type.
#'
#' Only single-IV formulas are supported (\code{DV ~ IV}). Multi-IV formulas
#' produce a helpful error pointing to the jlm() + jplot(m) workflow.
#'
#' @keywords internal
.jst_jplot_formula <- function(formula, jplot_call, ..., by_expr, type, line,
                               equation, r2, band, subset_expr, labels,
                               numeric = NULL, categorical = NULL, count = NULL,
                               parent_env) {

  # -- Parse formula ---------------------------------------------------------
  formula_vars <- all.vars(formula)
  if (length(formula) < 3) {
    .jst_stop("A two-sided formula is required: DV ~ IV.\n",
         "  Example: jplot(Tattoos ~ Age, SampleData)")
  }

  y_name <- all.vars(formula[[2]])
  x_vars <- all.vars(formula[[3]])

  if (length(y_name) != 1) {
    .jst_stop("Only one variable is supported on the left side of ~.\n",
         "  Example: jplot(Tattoos ~ Age, SampleData)")
  }
  if (length(x_vars) > 1) {
    .jst_stop("Only one independent variable is supported in the formula.\n",
         "For multi-variable regression, fit with jlm() and plot the result:\n",
         "  m <- jlm(", deparse(formula), ", <data>)\n",
         "  jplot(m)")
  }
  x_name <- x_vars[1]

  # -- Resolve data frame ----------------------------------------------------
  # Second positional argument in ..., or juse default.
  dots <- list(...)
  dot_names <- names(dots)
  if (is.null(dot_names)) dot_names <- rep("", length(dots))
  positional_dots <- dots[!nzchar(dot_names)]

  .jst_default_used <- FALSE
  .jst_data_name    <- NULL
  if (length(positional_dots) >= 1) {
    data <- positional_dots[[1]]
    # Try to extract the original symbol for reporting
    mc_no_name <- jplot_call[-1L]
    mc_positional <- mc_no_name[!nzchar(names(mc_no_name)) |
                                is.null(names(mc_no_name))]
    if (length(mc_positional) >= 2) {
      .jst_data_name <- paste(deparse(mc_positional[[2]]), collapse = "")
    }
    if (length(positional_dots) > 1) {
      .jst_stop("Only one data argument is expected after ",
           "the formula. Extra positional arguments were supplied.")
    }
  } else {
    resolved <- .jst_resolve_data(envir = parent_env)
    data <- resolved$data
    .jst_default_used <- TRUE
    .jst_data_name    <- resolved$name
  }

  if (!is.data.frame(data)) {
    stop("jplot(): the data argument after the formula must be a data frame.",
         call. = FALSE)
  }

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
  .plot_vars <- c(y_name, x_name)
  for (.arg in c("numeric", "categorical", "count")) {
    .val <- get(.arg)
    if (!is.null(.val)) {
      .bad <- setdiff(.val, .plot_vars)
      if (length(.bad) > 0) {
        .jst_stop(.arg, " argument: ", paste0("'", .bad, "'", collapse = ", "),
             " not found among the formula variables in jplot(). Check for typos.")
      }
    }
  }
  .cat_clash <- intersect(categorical, c(numeric, count))
  if (length(.cat_clash) > 0) {
    .jst_stop(paste0("'", .cat_clash, "'", collapse = ", "),
         " listed in both categorical and numeric/count arguments.")
  }
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

  if (!requireNamespace("ggplot2", quietly = TRUE)) {
    .jst_stop("Package 'ggplot2' is required for jplot(). ",
         "Install with: install.packages(\"ggplot2\")")
  }

  # -- Apply pipeline --------------------------------------------------------
  pipeline <- .jst_apply_pipeline(data, .jst_data_name, .jst_default_used,
                                  subset_expr = subset_expr,
                                  envir = parent_env)
  data <- pipeline$data

  # -- Decide plot type from IV's class -------------------------------------
  # Numeric IV -> scatter; categorical IV -> box (numeric DV is required).
  y_is_num <- !.jst_is_categorical(data[[y_name]], y_name, .jst_data_name,
                                   override = .ov_for(y_name))
  x_is_cat <-  .jst_is_categorical(data[[x_name]], x_name, .jst_data_name,
                                   override = .ov_for(x_name))

  if (!is.null(type)) {
    resolved_type <- type
  } else {
    if (!y_is_num) {
      stop("jplot(): the DV (left of ~) must be numeric. \"", y_name,
           "\" is categorical.", call. = FALSE)
    }
    resolved_type <- if (x_is_cat) "box" else "scatter"
  }

  # Classify both vars for downstream builders
  var_types <- c(
    if (.jst_is_categorical(data[[x_name]], x_name, .jst_data_name,
                            override = .ov_for(x_name)))
      "categorical" else "numeric",
    if (.jst_is_categorical(data[[y_name]], y_name, .jst_data_name,
                            override = .ov_for(y_name)))
      "categorical" else "numeric"
  )
  # Note: for builders, variable_names is ordered (x, y) for scatter,
  # (x, y) for box (builder detects numeric side via var_types).
  variable_names <- c(x_name, y_name)

  # -- Capture axis labels BEFORE factor conversion -------------------------
  # Variable label display mode (see jplot.default): "labels" puts the
  # variable's label on each axis/legend title, otherwise its name.
  vlmode <- .jst_resolve_variable_id(labels)
  axis_labels <- stats::setNames(
    vapply(variable_names,
           function(v) if (identical(vlmode, "labels")) {
             .jst_short_label(data[[v]], v)
           } else {
             v
           },
           character(1)),
    variable_names
  )
  by_label <- if (has_by) {
    if (identical(vlmode, "labels")) .jst_short_label(data[[by_name]], by_name) else by_name
  } else NULL

  # -- Red title -------------------------------------------------------------
  plot_title <- .jst_plot_title(resolved_type, c(y_name, x_name), by_name)
  # For formula form, write the title as "Scatterplot: Tattoos and Age" where
  # DV comes first for readability even though x-axis is Age.
  # .jst_plot_title already puts the two names with " and " between them.
  .cat_red(paste0(plot_title, "\n"))

  if (.jst_default_used) .jst_default_note(.jst_data_name)
  .jst_print_msgs(pipeline$msgs)

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
  for (i in seq_along(variable_names)) {
    v <- variable_names[i]
    if (!haven::is.labelled(data[[v]])) next
    if (identical(var_types[[i]], "categorical")) {
      data[[v]] <- haven::as_factor(data[[v]])
    } else {
      data[[v]] <- as.numeric(data[[v]])
    }
  }
  if (has_by && haven::is.labelled(data[[by_name]])) {
    val_labs <- labelled::val_labels(data[[by_name]])
    if (!is.null(val_labs) && length(val_labs) > 0) {
      data[[by_name]] <- haven::as_factor(data[[by_name]])
    } else {
      data[[by_name]] <- factor(data[[by_name]])
    }
  } else if (has_by && !is.factor(data[[by_name]])) {
    data[[by_name]] <- factor(data[[by_name]])
  }

  if (vlmode %in% c("legend", "legend.bottom")) {
    .print_var_labels(data, check_names)
  }

  # -- Ignored-argument note (e.g. band = ... without line = "lm") ----------
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
      " \u2014 ignored)\n"
    ))
  }

  # -- Dispatch to builder --------------------------------------------------
  p <- switch(
    resolved_type,
    scatter = .jst_build_scatter(data, variable_names, by_name,
                                 line, equation, r2, band,
                                 axis_labels, by_label),
    box     = .jst_build_box(data, variable_names, var_types, by_name,
                             axis_labels, by_label)
  )

  print(p)
  invisible(p)
}


# -- Data-first plot helpers ---------------------------------------------------

#' Internal helper: choose an axis label for a variable
#'
#' Returns the variable's label (from labelled::var_label) if one is set and
#' fits within \code{max_len} characters. Truncates with three trailing periods
#' if the label exceeds \code{max_len}. Falls back to the variable name when
#' no label is present.
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
  if (nchar(lbl) > max_len) {
    return(paste0(substr(lbl, 1, max_len - 3), "..."))
  }
  lbl
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
#' @param plot_type Character, one of the valid resolved types.
#' @param variable_names Character vector of 1 or 2 variable names.
#' @param by_name Optional character string for the by-variable.
#' @keywords internal
.jst_plot_title <- function(plot_type, variable_names, by_name = NULL) {
  prefix <- switch(
    plot_type,
    histogram   = "Histogram",
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
  if (!is.null(by_name)) {
    paste0(prefix, ": ", body, " by ", by_name)
  } else {
    paste0(prefix, ": ", body)
  }
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
  sign_char <- if (slope >= 0) "+" else "\u2212"
  eq <- sprintf("%s = %.2f %s %.2f\u00b7%s",
                y_name, intercept, sign_char, abs(slope), x_name)
  if (include_r2) {
    r2 <- summary(model)$r.squared
    eq <- paste0(eq, "    R\u00b2 = ", sprintf("%.3f", r2))
  }
  eq
}


#' Internal helper: build histogram (1 numeric variable)
#'
#' @keywords internal
#' @importFrom rlang .data
.jst_build_histogram <- function(data, x_name, by_name = NULL,
                                 axis_labels = NULL, by_label = NULL) {
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

  plot_df <- plot_df[stats::complete.cases(plot_df), , drop = FALSE]

  x_lab  <- if (!is.null(axis_labels)) axis_labels[[x_name]] else x_name
  by_lab <- if (!is.null(by_label)) by_label else by_name

  if (is.null(by_name)) {
    p <- ggplot2::ggplot(plot_df, ggplot2::aes(x = .data$x)) +
      ggplot2::geom_histogram(bins = 30, fill = "#3366FF", color = "white",
                              alpha = 0.85) +
      ggplot2::labs(x = x_lab, y = "Count") +
      ggplot2::theme_minimal()
  } else {
    p <- ggplot2::ggplot(plot_df, ggplot2::aes(x = .data$x,
                                                fill = .data$by)) +
      ggplot2::geom_histogram(bins = 30, color = "white", alpha = 0.55,
                              position = "identity") +
      ggplot2::labs(x = x_lab, y = "Count", fill = by_lab) +
      ggplot2::theme_minimal()
  }
  p
}


#' Internal helper: build bar chart (1 categorical variable)
#'
#' @keywords internal
#' @importFrom rlang .data
.jst_build_bar <- function(data, x_name, by_name = NULL,
                           axis_labels = NULL, by_label = NULL) {
  plot_df <- data.frame(x = data[[x_name]])
  if (!is.null(plot_df$x) && !is.factor(plot_df$x)) {
    plot_df$x <- factor(plot_df$x)
  }
  if (!is.null(by_name)) plot_df$by <- data[[by_name]]

  plot_df <- plot_df[stats::complete.cases(plot_df), , drop = FALSE]

  x_lab  <- if (!is.null(axis_labels)) axis_labels[[x_name]] else x_name
  by_lab <- if (!is.null(by_label)) by_label else by_name

  if (is.null(by_name)) {
    p <- ggplot2::ggplot(plot_df, ggplot2::aes(x = .data$x)) +
      ggplot2::geom_bar(fill = "#3366FF", alpha = 0.85) +
      ggplot2::labs(x = x_lab, y = "Count") +
      ggplot2::theme_minimal()
  } else {
    p <- ggplot2::ggplot(plot_df, ggplot2::aes(x = .data$x, fill = .data$by)) +
      ggplot2::geom_bar(position = ggplot2::position_dodge(width = 0.8),
                        width = 0.7) +
      ggplot2::labs(x = x_lab, y = "Count", fill = by_lab) +
      ggplot2::theme_minimal()
  }
  p
}


#' Internal helper: build scatterplot (2 numeric variables)
#'
#' @keywords internal
#' @importFrom rlang .data
.jst_build_scatter <- function(data, variable_names, by_name,
                               line, equation, r2, band,
                               axis_labels = NULL, by_label = NULL) {

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
    p <- ggplot2::ggplot(plot_df, ggplot2::aes(x = .data$x, y = .data$y)) +
      ggplot2::geom_point(alpha = 0.55, color = "#222222")
  } else {
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
        p <- p + ggplot2::geom_line(color = "#3366FF", alpha = 0.7)
      } else {
        p <- p + ggplot2::geom_line(alpha = 0.7)
      }

    } else if (line == "loess") {
      # Loess smoother — no equation, band options apply
      show_se <- !identical(band, "none") && band == "ci"
      if (is.null(by_name)) {
        p <- p + ggplot2::geom_smooth(method = "loess", se = show_se,
                                      color = "#3366FF",
                                      fill = "#3366FF",
                                      formula = y ~ x)
      } else {
        p <- p + ggplot2::geom_smooth(method = "loess", se = show_se,
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
                         subtitle = subtitle_text) +
           ggplot2::theme_minimal()
  p
}


#' Internal helper: add an lm regression line and optional band to a scatter
#'
#' Handles the four band options: ci (ggplot default), pi (prediction
#' interval, computed manually), see (constant +/- t*SEE rectangle), none.
#'
#' @keywords internal
#' @importFrom rlang .data
.jst_add_lm_line <- function(p, plot_df, x_name, y_name, by_name, band) {

  if (is.null(by_name)) {
    # Single-group line
    show_ci <- identical(band, "ci")
    p <- p + ggplot2::geom_smooth(method = "lm", se = show_ci,
                                  color = "#3366FF",
                                  fill = "#3366FF",
                                  formula = y ~ x)

    if (band %in% c("pi", "see")) {
      band_df <- .jst_compute_band(plot_df, band)
      p <- p + ggplot2::geom_ribbon(
        data = band_df,
        ggplot2::aes(x = .data$x, ymin = .data$lwr, ymax = .data$upr),
        fill = "#3366FF", alpha = 0.15,
        inherit.aes = FALSE
      )
    }

  } else {
    # Per-group lines
    show_ci <- identical(band, "ci")
    p <- p + ggplot2::geom_smooth(method = "lm", se = show_ci,
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
#' @keywords internal
#' @importFrom rlang .data
.jst_build_box <- function(data, variable_names, var_types, by_name = NULL,
                           axis_labels = NULL, by_label = NULL) {

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
    p <- ggplot2::ggplot(plot_df, ggplot2::aes(x = .data$x, y = .data$y)) +
      ggplot2::geom_boxplot(fill = "#E6EEF9", color = "#333333",
                            outlier.alpha = 0.6) +
      ggplot2::stat_summary(fun = mean, geom = "point",
                            shape = 18, size = 3, color = "#3366FF") +
      ggplot2::labs(x = x_lab, y = y_lab,
                    subtitle = "Diamond marks the group mean") +
      ggplot2::theme_minimal()
  } else {
    p <- ggplot2::ggplot(plot_df, ggplot2::aes(x = .data$x, y = .data$y,
                                                fill = .data$by)) +
      ggplot2::geom_boxplot(outlier.alpha = 0.6) +
      ggplot2::labs(x = x_lab, y = y_lab, fill = by_lab) +
      ggplot2::theme_minimal()
  }
  p
}


#' Internal helper: build grouped bar chart (2 categorical variables)
#'
#' @keywords internal
#' @importFrom rlang .data
.jst_build_grouped_bar <- function(data, variable_names, axis_labels = NULL) {
  x_name    <- variable_names[1]
  fill_name <- variable_names[2]

  x_lab    <- if (!is.null(axis_labels)) axis_labels[[x_name]] else x_name
  fill_lab <- if (!is.null(axis_labels)) axis_labels[[fill_name]] else fill_name

  plot_df <- data.frame(x = data[[x_name]], fill = data[[fill_name]])
  if (!is.factor(plot_df$x))    plot_df$x    <- factor(plot_df$x)
  if (!is.factor(plot_df$fill)) plot_df$fill <- factor(plot_df$fill)
  plot_df <- plot_df[stats::complete.cases(plot_df), , drop = FALSE]

  p <- ggplot2::ggplot(plot_df, ggplot2::aes(x = .data$x, fill = .data$fill)) +
    ggplot2::geom_bar(position = ggplot2::position_dodge(width = 0.8),
                      width = 0.7) +
    ggplot2::scale_fill_brewer(palette = "Blues") +
    ggplot2::labs(x = x_lab, y = "Count", fill = fill_lab) +
    ggplot2::theme_minimal()
  p
}


# -- Internal helpers for jplot ------------------------------------------------

#' Internal helper: resolve the `which` argument for jplot dispatch methods
#'
#' Translates the user's \code{which} argument into a vector of plot
#' identifiers. Accepts the special values \code{core} and
#' \code{all} (resolved against the supplied \code{core} and
#' \code{all_plots} vectors) or an explicit character vector of plot
#' names. Errors with a clear message listing the valid options if any
#' name in \code{which} isn't recognized.
#'
#' @param which The user's \code{which} argument: \code{core},
#'   \code{all}, or a character vector of plot names.
#' @param core Character vector of plot identifiers comprising the
#'   "core" set for this jplot method.
#' @param all_plots Character vector of all valid plot identifiers for
#'   this jplot method.
#' @param class_name Character. The S3 class being dispatched on, used
#'   in the error message.
#'
#' @return A character vector of plot identifiers to produce.
#'
#' @keywords internal
.jst_resolve_which <- function(which, core, all_plots, class_name) {
  if (length(which) == 1 && which %in% c("core", "all")) {
    return(if (which == "core") core else all_plots)
  }
  bad <- setdiff(which, all_plots)
  if (length(bad) > 0) {
    .jst_stop(sprintf(
      "Invalid plot name(s) for class '%s': %s.\nValid names: %s, or use \"core\" / \"all\".",
      class_name,
      paste(sprintf("'%s'", bad), collapse = ", "),
      paste(sprintf("'%s'", all_plots), collapse = ", ")
    ))
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
  iv_count  <- length(slopes)

  if (iv_count > max_terms) {
    return(NULL)
  }

  eq <- sprintf("%s = %.2f", dv_name, intercept)
  for (i in seq_along(slopes)) {
    b <- slopes[i]
    sign_char <- if (b >= 0) "+" else "\u2212"
    eq <- paste0(eq, " ", sign_char, " ", sprintf("%.2f", abs(b)),
                 "\u00b7", names(slopes)[i])
  }
  eq
}


# -- jplot.jst_lm --------------------------------------------------------------

#' @rdname jplot
#' @export
#' @importFrom rlang .data
jplot.jst_lm <- function(x, which = "core", focal = NULL, at = "zero",
                         equation = TRUE, r2 = TRUE, ...) {

  .jst_check_args(
    list(...),
    aliases = c(diagnostics = "which", plots = "which",
                show = "which", type = "which"),
    fn_name = "jplot.jst_lm"
  )

  if (!requireNamespace("ggplot2", quietly = TRUE)) {
    .jst_stop("Package 'ggplot2' is required for jplot(). ",
         "Install with: install.packages(\"ggplot2\")")
  }

  all_plots <- c("fit", "predicted", "effects", "coef", "vif",
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

  if (is.null(focal_name)) focal_name <- iv_names[1]
  if (!focal_name %in% iv_names) {
    .jst_stop("`focal` must be one of the independent variables in the model: ",
         paste(iv_names, collapse = ", "))
  }

  plots <- list()
  coefs <- stats::coef(model)

  # ---- fit plot ------------------------------------------------------------
  if ("fit" %in% plot_set) {
    at_vals <- .jst_resolve_at(at, mf, dv_name, focal_name,
                               x$dummy_coef_names)

    focal_range <- range(mf[[focal_name]], na.rm = TRUE)
    grid_x <- seq(focal_range[1], focal_range[2], length.out = 120)
    newdata <- data.frame(grid_x)
    names(newdata) <- focal_name
    for (v in names(at_vals)) newdata[[v]] <- at_vals[[v]]

    pred <- stats::predict(model, newdata = newdata, interval = "confidence",
                           level = 0.95)
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

    if (length(at_vals) > 0) {
      at_parts <- vapply(names(at_vals), function(v) {
        val <- at_vals[[v]]
        paste0(v, " = ", if (abs(val - round(val)) < 1e-8) {
          as.character(round(val))
        } else {
          sprintf("%.2f", val)
        })
      }, character(1))
      held_note <- paste0("(line shown at ",
                          paste(at_parts, collapse = ", "), ")")
      if (length(subtitle_parts) > 0) {
        subtitle_parts <- paste0(subtitle_parts, "\n", held_note)
      } else {
        subtitle_parts <- held_note
      }
    }

    if (equation && is.null(eq_text)) {
      note <- paste0("(equation omitted: model has ",
                     length(iv_names),
                     " predictors; see jlm() output for coefficients)")
      subtitle_parts <- if (length(subtitle_parts) > 0) {
        paste0(subtitle_parts, "\n", note)
      } else {
        note
      }
    }

    p <- ggplot2::ggplot() +
      ggplot2::geom_ribbon(data = line_df,
                           ggplot2::aes(x = .data$x,
                                        ymin = .data$lwr,
                                        ymax = .data$upr),
                           fill = "#3366FF", alpha = 0.18) +
      ggplot2::geom_point(data = point_df,
                          ggplot2::aes(x = .data$x, y = .data$y),
                          alpha = 0.55, color = "#222222") +
      ggplot2::geom_line(data = line_df,
                         ggplot2::aes(x = .data$x, y = .data$fit),
                         color = "#3366FF", linewidth = 0.9) +
      ggplot2::labs(
        x        = focal_name,
        y        = dv_name,
        subtitle = if (length(subtitle_parts) > 0) subtitle_parts else NULL
      ) +
      ggplot2::theme_minimal()
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
      ggplot2::geom_point(alpha = 0.55, color = "#222222") +
      ggplot2::coord_equal(xlim = lim, ylim = lim) +
      ggplot2::labs(title = "Observed vs Predicted",
                    x = "Predicted", y = "Observed") +
      ggplot2::theme_minimal()
    print(p)
    plots$predicted <- p
  }

  # ---- effects plot (one per IV) -------------------------------------------
  if ("effects" %in% plot_set) {
    n_effects <- 0
    for (iv in iv_names) {
      at_vals <- .jst_resolve_at(at, mf, dv_name, iv, x$dummy_coef_names)
      iv_range <- range(mf[[iv]], na.rm = TRUE)
      grid_x   <- seq(iv_range[1], iv_range[2], length.out = 80)
      newdata  <- data.frame(grid_x)
      names(newdata) <- iv
      for (v in names(at_vals)) newdata[[v]] <- at_vals[[v]]

      pred <- stats::predict(model, newdata = newdata,
                             interval = "confidence", level = 0.95)
      line_df <- data.frame(x = grid_x,
                            fit = pred[, "fit"],
                            lwr = pred[, "lwr"],
                            upr = pred[, "upr"])

      p <- ggplot2::ggplot(line_df,
                           ggplot2::aes(x = .data$x, y = .data$fit)) +
        ggplot2::geom_ribbon(ggplot2::aes(ymin = .data$lwr,
                                          ymax = .data$upr),
                             fill = "#3366FF", alpha = 0.18) +
        ggplot2::geom_line(color = "#3366FF", linewidth = 0.9) +
        ggplot2::labs(title = paste0("Effect: ", iv),
                      x = iv, y = dv_name) +
        ggplot2::theme_minimal()
      print(p)
      plots[[paste0("effect_", iv)]] <- p
      n_effects <- n_effects + 1
    }
    cat("\n(", n_effects,
        " effect plots produced, one per predictor)\n", sep = "")
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
                              height = 0.2, color = "steelblue") +
      ggplot2::geom_point(size = 2.5, color = "steelblue") +
      ggplot2::labs(title = "Coefficients (95% CI)",
                    x = "Estimate", y = NULL) +
      ggplot2::theme_minimal()
    print(p)
    plots$coef <- p
  }

  # ---- vif bar plot --------------------------------------------------------
  if ("vif" %in% plot_set) {
    vifs <- x$vif
    if (is.null(vifs)) {
      message("VIF plot skipped: VIF is only computed for models with 2+ predictors.")
    } else {
      vif_df <- data.frame(
        term = factor(names(vifs), levels = names(vifs)[order(vifs)]),
        vif  = as.numeric(vifs),
        stringsAsFactors = FALSE
      )
      p <- ggplot2::ggplot(vif_df,
                           ggplot2::aes(x = .data$vif, y = .data$term)) +
        ggplot2::geom_vline(xintercept = c(5, 10), linetype = "dashed",
                            color = "red", alpha = 0.6) +
        ggplot2::geom_col(fill = "steelblue", alpha = 0.8) +
        ggplot2::labs(title = "Variance Inflation Factors",
                      subtitle = "Reference lines at VIF = 5 and 10",
                      x = "VIF", y = NULL) +
        ggplot2::theme_minimal()
      print(p)
      plots$vif <- p
    }
  }

  # ---- diagnostic plots (residuals / qq / scale / cooks / leverage) --------
  diag_plots <- intersect(plot_set, c("residuals", "qq", "scale", "cooks",
                                      "leverage"))
  if (length(diag_plots) > 0) {
    diag_result <- .jst_plot_lm_diagnostics(model, which = diag_plots)
    if (is.list(diag_result)) {
      for (nm in names(diag_result)) plots[[nm]] <- diag_result[[nm]]
    }
  }

  .jst_return_plots(plots)
}


# -- jplot.jst_logistic --------------------------------------------------------

#' @rdname jplot
#' @export
#' @importFrom rlang .data
jplot.jst_logistic <- function(x, which = "core", focal = NULL, at = "zero",
                               ...) {

  .jst_check_args(
    list(...),
    aliases = c(diagnostics = "which", plots = "which",
                show = "which", type = "which"),
    fn_name = "jplot.jst_logistic"
  )

  if (!requireNamespace("ggplot2", quietly = TRUE)) {
    .jst_stop("Package 'ggplot2' is required for jplot(). ",
         "Install with: install.packages(\"ggplot2\")")
  }

  all_plots <- c("probability", "roc", "calibration", "binned",
                 "cooks", "leverage", "coef", "vif")
  core      <- c("probability", "roc", "calibration", "cooks")
  plot_set  <- .jst_resolve_which(which, core, all_plots, "jst_logistic")

  focal_name <- tryCatch(deparse(substitute(focal)), error = function(e) "NULL")
  if (identical(focal_name, "NULL") || !nzchar(focal_name) ||
      focal_name == "NULL") focal_name <- NULL

  model   <- x$model
  mf      <- x$model_frame
  dv_name <- names(mf)[1]
  iv_names <- setdiff(colnames(mf), dv_name)

  if (is.null(focal_name)) focal_name <- iv_names[1]
  if (!focal_name %in% iv_names) {
    .jst_stop("`focal` must be one of the independent variables in the model: ",
         paste(iv_names, collapse = ", "))
  }

  plots <- list()

  # ---- probability plot (S-curve) ------------------------------------------
  if ("probability" %in% plot_set) {
    at_vals <- .jst_resolve_at(at, mf, dv_name, focal_name,
                               x$dummy_coef_names)

    focal_range <- range(mf[[focal_name]], na.rm = TRUE)
    grid_x <- seq(focal_range[1], focal_range[2], length.out = 120)
    newdata <- data.frame(grid_x)
    names(newdata) <- focal_name
    for (v in names(at_vals)) newdata[[v]] <- at_vals[[v]]

    pred_link <- stats::predict(model, newdata = newdata, type = "link",
                                se.fit = TRUE)
    t_crit <- 1.96
    line_df <- data.frame(
      x   = grid_x,
      fit = stats::plogis(pred_link$fit),
      lwr = stats::plogis(pred_link$fit - t_crit * pred_link$se.fit),
      upr = stats::plogis(pred_link$fit + t_crit * pred_link$se.fit)
    )
    point_df <- data.frame(
      x = mf[[focal_name]],
      y = as.numeric(mf[[dv_name]])
    )

    predicts_label <- if (!is.null(x$predicts)) x$predicts else "1"

    held_note <- NULL
    if (length(at_vals) > 0) {
      at_parts <- vapply(names(at_vals), function(v) {
        val <- at_vals[[v]]
        paste0(v, " = ", if (abs(val - round(val)) < 1e-8) {
          as.character(round(val))
        } else {
          sprintf("%.2f", val)
        })
      }, character(1))
      held_note <- paste0("(line shown at ",
                          paste(at_parts, collapse = ", "), ")")
    }

    p <- ggplot2::ggplot() +
      ggplot2::geom_ribbon(data = line_df,
                           ggplot2::aes(x = .data$x,
                                        ymin = .data$lwr,
                                        ymax = .data$upr),
                           fill = "#3366FF", alpha = 0.18) +
      ggplot2::geom_point(data = point_df,
                          ggplot2::aes(x = .data$x, y = .data$y),
                          alpha = 0.35, color = "#222222") +
      ggplot2::geom_line(data = line_df,
                         ggplot2::aes(x = .data$x, y = .data$fit),
                         color = "#3366FF", linewidth = 0.9) +
      ggplot2::labs(
        title    = paste0("Predicted Probability: ", dv_name,
                          " = ", predicts_label),
        x        = focal_name,
        y        = paste0("P(", dv_name, " = ", predicts_label, ")"),
        subtitle = held_note
      ) +
      ggplot2::ylim(0, 1) +
      ggplot2::theme_minimal()
    print(p)
    plots$probability <- p
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
                              height = 0.2, color = "steelblue") +
      ggplot2::geom_point(size = 2.5, color = "steelblue") +
      ggplot2::scale_x_log10() +
      ggplot2::labs(title = "Odds Ratios (95% CI)",
                    subtitle = "Log scale; OR = 1 means no effect",
                    x = "Exp(B)", y = NULL) +
      ggplot2::theme_minimal()
    print(p)
    plots$coef <- p
  }

  # ---- vif bar plot --------------------------------------------------------
  if ("vif" %in% plot_set) {
    vifs <- x$vif
    if (is.null(vifs)) {
      message("VIF plot skipped: VIF is only computed for models with 2+ predictors.")
    } else {
      vif_df <- data.frame(
        term = factor(names(vifs), levels = names(vifs)[order(vifs)]),
        vif  = as.numeric(vifs),
        stringsAsFactors = FALSE
      )
      p <- ggplot2::ggplot(vif_df,
                           ggplot2::aes(x = .data$vif, y = .data$term)) +
        ggplot2::geom_vline(xintercept = c(5, 10), linetype = "dashed",
                            color = "red", alpha = 0.6) +
        ggplot2::geom_col(fill = "steelblue", alpha = 0.8) +
        ggplot2::labs(title = "Variance Inflation Factors",
                      subtitle = "Reference lines at VIF = 5 and 10",
                      x = "VIF", y = NULL) +
        ggplot2::theme_minimal()
      print(p)
      plots$vif <- p
    }
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

  .jst_return_plots(plots)
}


# -- jplot.jst_ttest -----------------------------------------------------------

#' @rdname jplot
#' @export
#' @importFrom rlang .data
jplot.jst_ttest <- function(x, which = "core", ...) {

  .jst_check_args(
    list(...),
    aliases = c(diagnostics = "which", plots = "which",
                show = "which", type = "which"),
    fn_name = "jplot.jst_ttest"
  )

  if (!requireNamespace("ggplot2", quietly = TRUE)) {
    .jst_stop("Package 'ggplot2' is required for jplot(). ",
         "Install with: install.packages(\"ggplot2\")")
  }

  plot_set <- .jst_resolve_which(which, core = "box", all_plots = "box",
                                 class_name = "jst_ttest")

  mf <- x$model_frame
  if (is.null(mf)) {
    .jst_stop("The jst_ttest object is missing model_frame. ",
         "Re-run jt() with the current version of the package.")
  }
  terms <- all.vars(x$formula)
  dv_name    <- terms[1]
  group_name <- terms[2]

  plots <- list()

  if ("box" %in% plot_set) {
    plot_df <- data.frame(
      dv    = mf[[dv_name]],
      group = mf[[group_name]]
    )
    if (!is.factor(plot_df$group)) plot_df$group <- factor(plot_df$group)

    p <- ggplot2::ggplot(plot_df,
                         ggplot2::aes(x = .data$group, y = .data$dv)) +
      ggplot2::geom_boxplot(fill = "#E6EEF9", color = "#333333",
                            outlier.alpha = 0.6) +
      ggplot2::stat_summary(fun = mean, geom = "point",
                            shape = 18, size = 3, color = "#3366FF") +
      ggplot2::labs(x = group_name, y = dv_name,
                    subtitle = "Diamond marks the group mean") +
      ggplot2::theme_minimal()
    print(p)
    plots$box <- p
  }

  .jst_return_plots(plots)
}


# -- jplot.jst_anova -----------------------------------------------------------

#' @rdname jplot
#' @export
#' @importFrom rlang .data
jplot.jst_anova <- function(x, which = "core", ...) {

  .jst_check_args(
    list(...),
    aliases = c(diagnostics = "which", plots = "which",
                show = "which", type = "which"),
    fn_name = "jplot.jst_anova"
  )

  if (!requireNamespace("ggplot2", quietly = TRUE)) {
    .jst_stop("Package 'ggplot2' is required for jplot(). ",
         "Install with: install.packages(\"ggplot2\")")
  }

  plot_set <- .jst_resolve_which(which, core = "box", all_plots = "box",
                                 class_name = "jst_anova")

  mf <- x$model_frame
  if (is.null(mf)) {
    .jst_stop("The jst_anova object is missing model_frame. ",
         "Re-run jaov() with the current version of the package.")
  }
  terms <- all.vars(x$formula)
  dv_name    <- terms[1]
  group_name <- terms[2]

  plots <- list()

  if ("box" %in% plot_set) {
    plot_df <- data.frame(
      dv    = mf[[dv_name]],
      group = mf[[group_name]]
    )
    if (!is.factor(plot_df$group)) plot_df$group <- factor(plot_df$group)

    p <- ggplot2::ggplot(plot_df,
                         ggplot2::aes(x = .data$group, y = .data$dv)) +
      ggplot2::geom_boxplot(fill = "#E6EEF9", color = "#333333",
                            outlier.alpha = 0.6) +
      ggplot2::stat_summary(fun = mean, geom = "point",
                            shape = 18, size = 3, color = "#3366FF") +
      ggplot2::labs(x = group_name, y = dv_name,
                    subtitle = "Diamond marks the group mean") +
      ggplot2::theme_minimal()
    print(p)
    plots$box <- p
  }

  .jst_return_plots(plots)
}


# -- jplot.jst_corr ------------------------------------------------------------

#' @rdname jplot
#' @export
#' @importFrom rlang .data
jplot.jst_corr <- function(x, which = "core", ...) {

  .jst_check_args(
    list(...),
    aliases = c(diagnostics = "which", plots = "which",
                show = "which", type = "which"),
    fn_name = "jplot.jst_corr"
  )

  if (!requireNamespace("ggplot2", quietly = TRUE)) {
    .jst_stop("Package 'ggplot2' is required for jplot(). ",
         "Install with: install.packages(\"ggplot2\")")
  }

  r_matrix <- x$r
  n_vars   <- nrow(r_matrix)

  default_core <- if (n_vars >= 3) "heatmap" else "scatter"
  all_plots <- if (n_vars >= 3) "heatmap" else c("scatter", "heatmap")

  plot_set <- .jst_resolve_which(which, core = default_core,
                                 all_plots = all_plots,
                                 class_name = "jst_corr")

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

    p <- ggplot2::ggplot(heat_df,
                         ggplot2::aes(x = .data$row, y = .data$col,
                                      fill = .data$r)) +
      ggplot2::geom_tile(color = "white", linewidth = 0.5) +
      ggplot2::geom_text(ggplot2::aes(label = .data$label),
                         size = 3.5, color = "#222222") +
      ggplot2::scale_fill_gradient2(low = "#CC3333", mid = "white",
                                    high = "#3366FF", midpoint = 0,
                                    limits = c(-1, 1), na.value = "grey90") +
      ggplot2::labs(title = "Correlation Matrix",
                    x = NULL, y = NULL, fill = "r") +
      ggplot2::theme_minimal() +
      ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 45,
                                                         hjust = 1))
    print(p)
    plots$heatmap <- p
  }

  if ("scatter" %in% plot_set) {
    mf <- x$model_frame
    if (is.null(mf)) {
      .jst_stop("Scatter plot requires model_frame on the jst_corr object. ",
           "Re-run jcorr() with the current version of the package.")
    }
    if (ncol(mf) != 2) {
      .jst_stop("Scatter plot is only available when jcorr() was called with ",
           "exactly 2 variables.")
    }
    var_names <- colnames(mf)
    r_val <- r_matrix[1, 2]
    n_val <- x$n[1, 2]

    p <- ggplot2::ggplot(mf,
                         ggplot2::aes(x = .data[[var_names[1]]],
                                      y = .data[[var_names[2]]])) +
      ggplot2::geom_point(alpha = 0.55, color = "#222222") +
      ggplot2::labs(subtitle = sprintf("r = %.3f, N = %d", r_val, n_val),
                    x = var_names[1], y = var_names[2]) +
      ggplot2::theme_minimal()
    print(p)
    plots$scatter <- p
  }

  .jst_return_plots(plots)
}


# -- jplot.jst_crosstab --------------------------------------------------------

#' @rdname jplot
#' @export
#' @importFrom rlang .data
jplot.jst_crosstab <- function(x, which = "core", ...) {

  .jst_check_args(
    list(...),
    aliases = c(diagnostics = "which", plots = "which",
                show = "which", type = "which"),
    fn_name = "jplot.jst_crosstab"
  )

  if (!requireNamespace("ggplot2", quietly = TRUE)) {
    .jst_stop("Package 'ggplot2' is required for jplot(). ",
         "Install with: install.packages(\"ggplot2\")")
  }

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

    p <- ggplot2::ggplot(bar_df,
                         ggplot2::aes(x = .data$row, y = .data$count,
                                      fill = .data$col)) +
      ggplot2::geom_col(position = ggplot2::position_dodge(width = 0.8),
                        width = 0.7) +
      ggplot2::scale_fill_brewer(palette = "Blues") +
      ggplot2::labs(x = NULL, y = "Count", fill = NULL) +
      ggplot2::theme_minimal()
    print(p)
    plots$bar <- p
  }

  .jst_return_plots(plots)
}


# -- jplot.jst_desc / jplot.jst_freq (deferred to v2) --------------------------

#' @rdname jplot
#' @export
jplot.jst_desc <- function(x, which = "core", ...) {
  .jst_stop("Plotting jst_desc result objects is not supported. ",
       "Instead, call jplot() with the data frame directly, e.g.:\n",
       "  jplot(community, Age)       # histogram\n",
       "  jplot(community, Region)    # bar chart\n",
       "  jplot(WellbeingScore ~ Region, community, categorical = \"Region\")  # boxplot")
}

#' @rdname jplot
#' @export
jplot.jst_freq <- function(x, which = "core", ...) {
  .jst_stop("Plotting jst_freq result objects is not supported. ",
       "Instead, call jplot() with the data frame directly, e.g.:\n",
       "  jplot(community, Region)    # bar chart\n",
       "  jplot(community, Region, Volunteer, ",
       "categorical = c(\"Region\", \"Volunteer\"))  # grouped bar chart")
}
