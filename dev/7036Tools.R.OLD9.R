# -- Internal helpers ----------------------------------------------------------

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
#' Used by jt, jaov, jcorr, jchisq, jscreen, and jalpha.
#'
#' @keywords internal
.print_var_labels <- function(data, var_names) {
  label_lines <- c()
  for (v in var_names) {
    if (v %in% names(data)) {
      vl <- labelled::var_label(data[[v]])
      if (!is.null(vl) && !is.na(vl) && nzchar(vl)) {
        label_lines <- c(label_lines, paste0("  ", v, " = ", vl))
      }
    }
  }
  if (length(label_lines) > 0) {
    cat("Variable Labels:\n")
    cat(paste(label_lines, collapse = "\n"))
    cat("\n\n")
  }
}

#' Internal helper: print a knitr::kable table without extra leading blank lines
#'
#' knitr::kable() can prepend one or more newlines to its output (especially
#' when a caption is used), which causes unwanted extra blank lines in console
#' output. This wrapper strips any such leading newlines before printing, so
#' callers can control vertical spacing precisely with explicit cat() calls.
#'
#' @keywords internal
.print_kable <- function(...) {
  tbl     <- knitr::kable(...)
  tbl_str <- paste(as.character(tbl), collapse = "\n")
  tbl_str <- sub("^\n+", "", tbl_str)
  cat(tbl_str)
  cat("\n")
}

# -----------------------------------------------------------------------------
# .jst_detect_suspicious_values()
# Checks for values that look like coded missing (e.g. -99, 999) by comparing
# them against the main cluster of values in the variable. Only flags a value
# if it sits far outside the main cluster - specifically, if the gap between
# the suspicious value and the nearest edge of the cluster is more than 10
# times the cluster's own range. This avoids false alarms when negative values
# are legitimate (e.g. -99, -98, -97 in a genuine negative scale).
# -----------------------------------------------------------------------------

.jst_detect_suspicious_values <- function(x, var_name) {

  vals <- unique(as.numeric(x[!is.na(x)]))
  if (length(vals) < 2) return(invisible(NULL))

  suspicious_candidates <- c(-99, -98, -97, -96, -9, -8, -7,
                             88, 98, 99, 999, 9999)

  found <- vals[vals %in% suspicious_candidates]
  if (length(found) == 0) return(invisible(NULL))

  main_cluster <- vals[!vals %in% suspicious_candidates]
  if (length(main_cluster) < 2) return(invisible(NULL))

  cluster_min   <- min(main_cluster)
  cluster_max   <- max(main_cluster)
  cluster_range <- max(cluster_max - cluster_min, 1)   # avoid /0

  for (sv in found) {
    gap <- min(abs(sv - cluster_min), abs(sv - cluster_max))
    if (gap > 10 * cluster_range) {
      message(
        "Note: the value ", sv, " appears in '", var_name, "' but is far outside ",
        "the range of other values (", cluster_min, " to ", cluster_max, "). ",
        "This may represent a coded missing value from SPSS or another package. ",
        "If so, convert it to NA before recoding with:\n",
        "  data$", var_name, "[data$", var_name, " == ", sv, "] <- NA\n",
        "If ", sv, " is a legitimate value, add an explicit rule for it in your ",
        "map argument to suppress this message."
      )
    }
  }
}


# -----------------------------------------------------------------------------
# .jst_parse_map()
# Parses a map string like "1=1; 2,3=2; 4,5=3; else=copy" into a structured
# list of mapping rules and an else action. Returns:
#   $mappings  - list of lists, each with $old_vals (numeric vector) and
#                $new_val (single numeric)
#   $else_action - "na" or "copy"
# Stops with a clear message if the string is malformed.
# -----------------------------------------------------------------------------

.jst_parse_map <- function(map_str) {

  rules <- trimws(strsplit(map_str, ";")[[1]])
  rules <- rules[nchar(rules) > 0]

  if (length(rules) == 0) {
    stop("The map argument is empty. Provide at least one rule, e.g. map = \"1=1; 2=0\".")
  }

  result <- list(mappings = list(), else_action = "na")

  for (rule in rules) {

    if (!grepl("=", rule)) {
      stop(paste0(
        "Invalid rule '", rule, "' in map argument: each rule must contain '=', ",
        "e.g. '1=0' or '2,3=1'."
      ))
    }

    eq_pos <- regexpr("=", rule)[1]
    lhs    <- trimws(substr(rule, 1, eq_pos - 1))
    rhs    <- trimws(substr(rule, eq_pos + 1, nchar(rule)))

    # else rule
    if (tolower(lhs) == "else") {
      if (!tolower(rhs) %in% c("na", "copy")) {
        stop(paste0(
          "Invalid else action '", rhs, "' in map argument. ",
          "Use 'else=NA' or 'else=copy'."
        ))
      }
      result$else_action <- tolower(rhs)
      next
    }

    # old values (may be comma-separated)
    old_strs <- trimws(strsplit(lhs, ",")[[1]])
    old_vals <- suppressWarnings(as.numeric(old_strs))

    if (any(is.na(old_vals))) {
      stop(paste0(
        "Invalid old value(s) '", lhs, "' in map rule '", rule, "'. ",
        "Old values must be numeric."
      ))
    }

    # new value
    new_val <- suppressWarnings(as.numeric(rhs))
    if (is.na(new_val)) {
      stop(paste0(
        "Invalid new value '", rhs, "' in map rule '", rule, "'. ",
        "New values must be numeric."
      ))
    }

    result$mappings[[length(result$mappings) + 1]] <- list(
      old_vals = old_vals,
      new_val  = new_val
    )
  }

  if (length(result$mappings) == 0) {
    stop("The map argument contains no valid recode rules (only an else clause was found).")
  }

  return(result)
}


# -----------------------------------------------------------------------------
# .jst_parse_labels()
# Parses a labels string like "1=Young; 2=Middle Aged; 3=Older" into a named
# numeric vector in haven_labelled format (names = label text, values = codes).
# Splits on the FIRST equals sign only, so label text may contain equals signs.
# -----------------------------------------------------------------------------

.jst_parse_labels <- function(labels_str) {

  rules <- trimws(strsplit(labels_str, ";")[[1]])
  rules <- rules[nchar(rules) > 0]

  if (length(rules) == 0) {
    stop("The labels argument is empty. Provide at least one label, e.g. labels = \"1=Male; 0=Female\".")
  }

  result <- c()

  for (rule in rules) {

    if (!grepl("=", rule)) {
      stop(paste0(
        "Invalid label rule '", rule, "': each rule must contain '=', ",
        "e.g. '1=Male'."
      ))
    }

    eq_pos    <- regexpr("=", rule)[1]
    val_str   <- trimws(substr(rule, 1, eq_pos - 1))
    label_str <- trimws(substr(rule, eq_pos + 1, nchar(rule)))

    val <- suppressWarnings(as.numeric(val_str))
    if (is.na(val)) {
      stop(paste0(
        "Invalid value '", val_str, "' in label rule '", rule, "'. ",
        "The left side of each label rule must be numeric."
      ))
    }

    if (nchar(label_str) == 0) {
      stop(paste0(
        "Empty label text in rule '", rule, "'. ",
        "Provide a label name after the equals sign."
      ))
    }

    entry        <- val
    names(entry) <- label_str
    result <- c(result, entry)
  }

  return(result)
}


# -- jdesc --------------------------------------------------------------------

#' Descriptive statistics for one or more variables
#'
#' Computes basic descriptive statistics (N, non-missing, min, max, mean, SD)
#' for one or more variables in a data frame. Prints a formatted table and
#' invisibly returns the underlying results as a data frame.
#'
#' Output is structured consistently with \code{jfreq()}: a red title is
#' printed first, followed by a block showing the type and variable label
#' (or "None" if no label is present) for each variable, then a single blank
#' line before the table. For multiple variables, one type/label entry is
#' printed per variable before the shared table.
#'
#' Handles haven-labelled, factor, and plain numeric variables. If a factor
#' with text categories is passed, a warning is issued directing the user
#' to \code{jfreq()} instead. Also accepts a simple numeric vector. Supports
#' grouped descriptives via the \code{by} parameter.
#'
#' Haven-labelled variables are reported as \code{haven_labelled (Categorical)}
#' in the type line; the uninformative \code{vctrs_vctr} class is suppressed.
#'
#' @param data A data frame, or a numeric vector.
#' @param ... Unquoted variable names within \code{data} (ignored if data is a vector).
#' @param by An optional unquoted grouping variable name. When provided,
#'   descriptives are computed separately for each group, with a separate
#'   titled table per dependent variable.
#' @param labels Logical. If \code{TRUE} (default), prints the variable type
#'   and label (or "None") for each variable before the table.
#'
#' @return Invisibly returns a data frame of descriptive statistics. Also
#'   prints a formatted table to the console.
#'
#' @examples
#' jdesc(mtcars, mpg)
#' jdesc(mtcars, mpg, hp, wt)
#' jdesc(c(10, 20, 30, 40, 50))
#' jdesc(mtcars, mpg, by = am)
#'
#' @export
jdesc <- function(data, ..., by = NULL, labels = TRUE) {

  # Handle vector input
  if (is.atomic(data) && !is.data.frame(data)) {
    var_name <- deparse(substitute(data))
    temp_df  <- data.frame(x = data)
    names(temp_df) <- var_name
    return(jdesc(temp_df, !!rlang::sym(var_name), labels = FALSE))
  }

  variables      <- rlang::enquos(...)
  variable_names <- purrr::map_chr(variables, rlang::quo_name)
  by_quo         <- rlang::enquo(by)

  # -- Grouped descriptives ---------------------------------------------------
  if (!rlang::quo_is_null(by_quo)) {
    by_name <- rlang::quo_name(by_quo)
    by_var  <- data[[by_name]]

    # Capture original class and label BEFORE any conversion
    original_by_class <- class(by_var)
    original_by_label <- .get_var_label_str(by_var)
    original_dv_info  <- stats::setNames(
      lapply(variable_names, function(v) {
        list(class = class(data[[v]]),
             label = .get_var_label_str(data[[v]]))
      }),
      variable_names
    )

    is_labelled_by <- haven::is.labelled(by_var)
    if (is_labelled_by) {
      original_codes  <- sort(unique(as.numeric(by_var[!is.na(by_var)])))
      data[[by_name]] <- haven::as_factor(by_var)
    } else if (!is.factor(data[[by_name]])) {
      data[[by_name]] <- factor(data[[by_name]])
    }

    group_levels <- levels(data[[by_name]])

    for (v in variable_names) {
      .cat_red(paste0("Descriptive Statistics: ", v, " by ", by_name, "\n"))

      if (labels) {
        cat(v, "\n", sep = "")
        cat("  Type: ", .format_var_type(original_dv_info[[v]]$class), "\n", sep = "")
        cat("  Variable label: ", original_dv_info[[v]]$label, "\n", sep = "")
        cat(by_name, "\n", sep = "")
        cat("  Type: ", .format_var_type(original_by_class), "\n", sep = "")
        cat("  Variable label: ", original_by_label, "\n", sep = "")
      }
      cat("\n")

      dv_data <- data[[v]]
      if (haven::is.labelled(dv_data)) {
        dv_data <- as.numeric(dv_data)
      } else if (is.factor(dv_data)) {
        dv_data <- suppressWarnings(as.numeric(as.character(dv_data)))
      } else {
        dv_data <- as.numeric(dv_data)
      }

      group_var_chr <- as.character(data[[by_name]])

      group_rows <- lapply(seq_along(group_levels), function(i) {
        lvl         <- group_levels[i]
        subset_data <- dv_data[group_var_chr == lvl]
        subset_data <- subset_data[!is.na(subset_data)]
        n <- length(subset_data)
        m <- if (n > 0) mean(subset_data) else NA
        s <- if (n > 0) sd(subset_data)   else NA

        group_label <- if (is_labelled_by) {
          paste0(original_codes[i], ": ", lvl)
        } else {
          lvl
        }

        data.frame(
          Group = group_label,
          N     = n,
          Min   = if (n > 0) round(min(subset_data), 3) else NA,
          Max   = if (n > 0) round(max(subset_data), 3) else NA,
          Mean  = if (n > 0) round(m, 3) else NA,
          SD    = if (n > 0) round(s, 3) else NA,
          stringsAsFactors = FALSE
        )
      })
      group_table <- do.call(rbind, group_rows)

      .print_kable(group_table, row.names = FALSE)
      cat("\n")
    }
    return(invisible(NULL))
  }

  # -- Standard (ungrouped) descriptives --------------------------------------

  # Capture original class and label info BEFORE any conversion
  original_var_info <- stats::setNames(
    lapply(variable_names, function(v) {
      list(class = class(data[[v]]),
           label = .get_var_label_str(data[[v]]))
    }),
    variable_names
  )

  descriptives_list <- lapply(variables, function(var) {
    var_name <- rlang::quo_name(var)
    var_data <- rlang::eval_tidy(var, data)

    if (haven::is.labelled(var_data)) {
      var_data <- as.numeric(var_data)
    }

    if (is.factor(var_data)) {
      numeric_check <- suppressWarnings(as.numeric(as.character(var_data)))
      if (all(is.na(numeric_check[!is.na(var_data)]))) {
        warning(paste0("'", var_name,
                       "' is a factor with text categories and cannot be summarised ",
                       "with descriptive statistics. Use jfreq() instead for ",
                       "categorical variables."), call. = FALSE)
        return(NULL)
      }
      var_data <- numeric_check
    }

    data.frame(
      Variable    = var_name,
      Total       = length(var_data),
      Non_missing = sum(!is.na(var_data)),
      Min         = round(min(var_data, na.rm = TRUE), 3),
      Max         = round(max(var_data, na.rm = TRUE), 3),
      Mean        = round(mean(var_data, na.rm = TRUE), 3),
      SD          = round(stats::sd(var_data, na.rm = TRUE), 3),
      stringsAsFactors = FALSE
    )
  })

  descriptives_list <- Filter(Negate(is.null), descriptives_list)
  descriptives      <- do.call(rbind, descriptives_list)

  listwise_cases <- sum(
    stats::complete.cases(dplyr::select(data, dplyr::all_of(variable_names)))
  )
  listwise_row <- data.frame(
    Variable    = "Listwise_N",
    Total       = NA,
    Non_missing = listwise_cases,
    Min         = NA,
    Max         = NA,
    Mean        = NA,
    SD          = NA,
    stringsAsFactors = FALSE
  )
  descriptives <- rbind(descriptives, listwise_row)

  # -- Print: title -> type/label block -> single blank line -> table ---------
  .cat_red("Descriptive Statistics\n")

  if (labels) {
    for (v in variable_names) {
      cat(v, "\n", sep = "")
      cat("  Type: ", .format_var_type(original_var_info[[v]]$class), "\n", sep = "")
      cat("  Variable label: ", original_var_info[[v]]$label, "\n", sep = "")
    }
  }

  cat("\n")
  .print_kable(descriptives)
  invisible(descriptives)
}


# -- jfreq --------------------------------------------------------------------

#' SPSS-like frequency tables for categorical variables
#'
#' Prints an SPSS-style frequency table (Freq, Total \%, Valid \%, Cum. \%) for
#' each variable supplied. Designed for use with unquoted variable names, and
#' also accepts a plain vector.
#'
#' Output is structured consistently with \code{jdesc()}: a red title
#' ("Frequencies for \emph{varname}") is printed first, followed by the
#' variable type and variable label (or "None" if absent), then a single blank
#' line before the table. One complete block is printed per variable.
#'
#' For haven-labelled variables, value labels and numeric codes are combined
#' in the frequency table rows (e.g. \code{1: Strongly Oppose}). The type
#' line reports \code{haven_labelled (Categorical)} and suppresses the
#' uninformative \code{vctrs_vctr} class. Variable labels are shown for all
#' variable types, not only haven-labelled ones.
#'
#' @param data A data frame, or a vector.
#' @param ... Unquoted variable name(s) within \code{data} (ignored if
#'   \code{data} is a vector).
#' @param labels Logical. If \code{TRUE} (default), prints the variable type
#'   and label (or "None") beneath the title.
#'
#' @return Invisibly returns a named list of data frames (one per variable)
#'   containing the frequency table.
#'
#' @examples
#' jfreq(mtcars, cyl, gear)
#' jfreq(c("Male", "Female", "Male", "Female", "Male"))
#'
#' @export
#' @importFrom rlang .data
jfreq <- function(data, ..., labels = TRUE) {

  # Handle vector input
  if (is.atomic(data) && !is.data.frame(data)) {
    var_name <- deparse(substitute(data))
    temp_df  <- data.frame(x = data)
    names(temp_df) <- var_name
    return(jfreq(temp_df, !!rlang::sym(var_name), labels = FALSE))
  }

  variables <- rlang::enquos(...)
  results   <- list()

  for (variable in variables) {
    variable_name <- rlang::quo_name(variable)

    # Capture class and label BEFORE any conversion
    temp_var      <- dplyr::pull(data, !!variable)
    var_class     <- class(temp_var)
    var_label_val <- .get_var_label_str(data[[variable_name]])

    # Haven-labelled: combine numeric codes with value labels
    if (haven::is.labelled(temp_var)) {
      label_text <- as.character(haven::as_factor(temp_var))
      codes      <- as.numeric(temp_var)
      temp_var   <- factor(
        ifelse(is.na(codes), NA, paste(codes, label_text, sep = ": "))
      )
    }

    # Convert plain numeric to factor for counting
    if (is.numeric(temp_var)) {
      temp_var <- factor(temp_var)
    }

    # Frequency table
    freq_table <- data.frame(temp_var = temp_var, stringsAsFactors = FALSE) |>
      dplyr::count(temp_var, name = "Freq")

    total_count <- length(temp_var)
    valid_count <- sum(!is.na(temp_var))

    freq_table <- freq_table |>
      dplyr::mutate(
        `Total %` = (.data$Freq / total_count) * 100,
        `Valid %` = ifelse(
          is.na(.data$temp_var),
          NA_real_,
          (.data$Freq / valid_count) * 100
        ),
        `Cum. %` = ifelse(
          is.na(.data$temp_var),
          NA_real_,
          cumsum(ifelse(is.na(.data$temp_var), 0,
                        (.data$Freq / valid_count) * 100))
        )
      )

    results[[variable_name]] <- freq_table

    # -- Print: title -> type -> label -> single blank line -> table ----------
    max_length      <- suppressWarnings(
      max(nchar(as.character(freq_table$temp_var)), na.rm = TRUE)
    )
    first_col_width <- max(max_length, nchar("Category"), na.rm = TRUE)

    .cat_red(paste0("Frequencies for ", variable_name, "\n"))

    if (labels) {
      cat("Type of variable: ", .format_var_type(var_class), "\n", sep = "")
      cat("Variable label: ", var_label_val, "\n", sep = "")
    }
    cat("\n")

    cat(sprintf("%-*s", first_col_width, ""),
        "Freq", "Total %", "Valid %", "Cum. %", sep = "\t")
    cat("\n",
        strrep("-", first_col_width), "\t",
        strrep("-", 4), "\t",
        strrep("-", 7), "\t",
        strrep("-", 7), "\t",
        strrep("-", 6),
        sep = "")
    cat("\n")

    for (i in seq_len(nrow(freq_table))) {
      cat(
        sprintf("%-*s", first_col_width,
                ifelse(is.na(freq_table$temp_var[i]),
                       "NA",
                       as.character(freq_table$temp_var[i]))),
        "\t", freq_table$Freq[i],
        "\t", sprintf("%.2f", freq_table$`Total %`[i]),
        "\t", ifelse(is.na(freq_table$`Valid %`[i]),  "",
                     sprintf("%.2f", freq_table$`Valid %`[i])),
        "\t", ifelse(is.na(freq_table$`Cum. %`[i]), "",
                     sprintf("%.2f", freq_table$`Cum. %`[i])),
        sep = ""
      )
      cat("\n")
    }
    cat("\n")
  }

  invisible(results)
}


# -- jt -----------------------------------------------------------------------

#' Independent samples or paired samples t-test
#'
#' Runs a t-test and prints formatted group descriptives and test results.
#' By default, runs the traditional Student's independent samples t-test
#' assuming equal variances. Optional parameters provide Welch's correction,
#' paired samples, effect size (Cohen's d), Levene's test, and confidence
#' interval for the mean difference. Handles haven-labelled, numeric, and
#' factor grouping variables. For haven-labelled variables, numeric codes
#' are displayed alongside labels in the group descriptives table.
#'
#' A red title identifying the test type is printed first, followed by
#' variable labels (if present), then the results tables.
#'
#' @param formula A formula of the form \code{DV ~ Group}.
#' @param data A data frame containing variables referenced in \code{formula}.
#' @param paired Logical. If TRUE, runs a paired samples t-test. The two
#'   groups must have equal sample sizes. Default is FALSE.
#' @param welch Logical. If FALSE (default), runs Student's t-test
#'   (equal variances assumed). If TRUE, runs Welch's t-test. Ignored
#'   when paired = TRUE.
#' @param effect.size Logical. If TRUE, prints Cohen's d.
#' @param levene Logical. If TRUE, prints Levene's test for homogeneity
#'   of variance. Ignored when paired = TRUE.
#' @param ci Logical. If TRUE, adds 95\% confidence interval for the
#'   mean difference.
#' @param labels Logical. If TRUE (default), prints variable labels
#'   when available.
#' @param full Logical. If TRUE, turns on effect.size, levene, and ci
#'   all at once.
#'
#' @return Invisibly returns the \code{t.test} result object.
#'
#' @examples
#' jt(mpg ~ am, data = mtcars)
#' jt(mpg ~ am, data = mtcars, welch = TRUE)
#' jt(mpg ~ am, data = mtcars, full = TRUE)
#'
#' @export
#' @importFrom stats t.test sd qt
jt <- function(formula, data, paired = FALSE, welch = FALSE,
               effect.size = FALSE, levene = FALSE, ci = FALSE,
               labels = TRUE, full = FALSE) {

  if (full) {
    effect.size <- TRUE
    levene      <- TRUE
    ci          <- TRUE
  }

  # Red title - determined before any output
  if (paired) {
    .cat_red("Paired Samples T-Test\n")
  } else if (welch) {
    .cat_red("Welch's Independent Samples T-Test\n")
  } else {
    .cat_red("Independent Samples T-Test\n")
  }

  terms      <- all.vars(formula)
  dv_name    <- terms[1]
  group_name <- terms[2]

  group_var   <- data[[group_name]]
  is_labelled <- haven::is.labelled(group_var)
  if (is_labelled) {
    original_codes <- sort(unique(as.numeric(group_var[!is.na(group_var)])))
  }

  if (is_labelled) {
    data[[group_name]] <- haven::as_factor(group_var)
  } else if (!is.factor(group_var)) {
    data[[group_name]] <- factor(group_var)
  }

  n_levels <- nlevels(data[[group_name]])
  if (n_levels != 2) {
    stop(paste0("'", group_name, "' has ", n_levels,
                " categories. A t-test requires exactly 2. ",
                "Use jaov() for more than 2 categories."), call. = FALSE)
  }

  if (haven::is.labelled(data[[dv_name]])) {
    data[[dv_name]] <- as.numeric(data[[dv_name]])
  }

  levels      <- levels(data[[group_name]])
  group1_data <- data[[dv_name]][data[[group_name]] == levels[1]]
  group2_data <- data[[dv_name]][data[[group_name]] == levels[2]]
  group1_data <- group1_data[!is.na(group1_data)]
  group2_data <- group2_data[!is.na(group2_data)]

  if (paired && length(group1_data) != length(group2_data)) {
    stop("Paired t-test requires equal sample sizes in both groups.", call. = FALSE)
  }

  if (labels) {
    .print_var_labels(data, c(dv_name, group_name))
  }

  # Levene's test
  if (levene && !paired) {
    group_factor  <- data[[group_name]]
    dv_vals       <- data[[dv_name]]
    group_means   <- tapply(dv_vals, group_factor, mean, na.rm = TRUE)
    abs_devs      <- abs(dv_vals - group_means[group_factor])
    levene_model  <- stats::aov(abs_devs ~ group_factor)
    levene_result <- summary(levene_model)[[1]]
    levene_f      <- round(levene_result$`F value`[1], 3)
    levene_p      <- levene_result$`Pr(>F)`[1]
    levene_p_fmt  <- if (!is.na(levene_p) && levene_p < 0.001) "<.001" else sprintf("%.3f", levene_p)

    levene_table <- data.frame(
      F_value = levene_f,
      df1     = levene_result$Df[1],
      df2     = levene_result$Df[2],
      p_value = levene_p_fmt,
      stringsAsFactors = FALSE,
      row.names = NULL
    )

    .print_kable(levene_table,
                 caption = "Levene's Test for Homogeneity of Variance",
                 col.names = c("F", "df1", "df2", "p"),
                 row.names = FALSE)
    cat("\n")
  } else if (levene && paired) {
    cat("Note: Levene's test is not applicable for paired samples.\n\n")
  }

  # Group descriptives
  if (is_labelled) {
    group_labels <- paste0(original_codes, ": ", levels)
  } else {
    group_labels <- levels
  }

  desc_table <- data.frame(
    Group = group_labels,
    N     = c(length(group1_data), length(group2_data)),
    Mean  = round(c(mean(group1_data), mean(group2_data)), 3),
    SD    = round(c(sd(group1_data),   sd(group2_data)),   3),
    stringsAsFactors = FALSE
  )

  .print_kable(desc_table,
               caption = paste("Group Descriptives:", dv_name, "by", group_name),
               row.names = FALSE)
  cat("\n")

  # Run t-test
  if (paired) {
    result <- t.test(group1_data, group2_data, paired = TRUE)
  } else {
    result <- t.test(formula, data = data, var.equal = !welch)
  }

  p_val <- result$p.value
  p_fmt <- if (!is.na(p_val) && p_val < 0.001) "<.001" else sprintf("%.3f", p_val)

  test_table <- data.frame(
    t               = round(result$statistic, 3),
    df              = round(result$parameter, 1),
    p               = p_fmt,
    Mean_Difference = round(mean(group1_data) - mean(group2_data), 3),
    stringsAsFactors = FALSE,
    row.names = NULL
  )

  if (ci) {
    test_table$CI_Lower <- round(result$conf.int[1], 3)
    test_table$CI_Upper <- round(result$conf.int[2], 3)
  }

  if (paired) {
    test_label <- "Paired Samples T-Test Results"
  } else if (welch) {
    test_label <- "Welch's T-Test Results (equal variances not assumed)"
  } else {
    test_label <- "Independent Samples T-Test Results (equal variances assumed)"
  }

  if (ci) {
    .print_kable(test_table,
                 caption = test_label,
                 col.names = c("t", "df", "p", "Mean Difference",
                               "95% CI Lower", "95% CI Upper"),
                 row.names = FALSE)
  } else {
    .print_kable(test_table,
                 caption = test_label,
                 col.names = c("t", "df", "p", "Mean Difference"),
                 row.names = FALSE)
  }

  # Effect size (Cohen's d)
  if (effect.size) {
    n1 <- length(group1_data)
    n2 <- length(group2_data)
    m1 <- mean(group1_data)
    m2 <- mean(group2_data)
    s1 <- sd(group1_data)
    s2 <- sd(group2_data)

    if (paired) {
      diffs <- group1_data - group2_data
      d     <- round(mean(diffs) / sd(diffs), 3)
      cat("\nCohen's dz (paired):", d, "\n")
    } else {
      sp <- sqrt(((n1 - 1) * s1^2 + (n2 - 1) * s2^2) / (n1 + n2 - 2))
      d  <- round((m1 - m2) / sp, 3)
      cat("\nCohen's d:", d, "\n")
    }
  }

  invisible(result)
}


# -- jaov ---------------------------------------------------------------------

#' One-way ANOVA (traditional or Welch method)
#'
#' Runs a one-way ANOVA and prints a formatted group descriptives table
#' followed by an ANOVA table. By default, runs the traditional ANOVA
#' assuming equal variances. Optional parameters provide post-hoc tests,
#' effect size, Levene's test, and confidence intervals. Set welch = TRUE
#' for the Welch correction when equal variances cannot be assumed.
#' Handles haven-labelled, numeric, and factor grouping variables.
#' For haven-labelled variables, numeric codes are displayed alongside
#' labels in the group descriptives table.
#'
#' A red title identifying the test type is printed first, followed by
#' variable labels (if present), then the results tables.
#'
#' @param formula A formula of the form \code{DV ~ Group}.
#' @param data A data frame containing variables referenced in \code{formula}.
#' @param welch Logical. If FALSE (default), runs traditional ANOVA.
#'   If TRUE, runs Welch's ANOVA (does not assume equal variances).
#' @param posthoc Logical. If TRUE, prints Tukey HSD pairwise comparisons.
#'   Not available when welch = TRUE.
#' @param effect.size Logical. If TRUE, prints eta-squared.
#' @param levene Logical. If TRUE, prints Levene's test for homogeneity
#'   of variance.
#' @param ci Logical. If TRUE, adds 95\% confidence intervals to the
#'   group descriptives table.
#' @param labels Logical. If TRUE (default), prints variable labels
#'   when available.
#' @param full Logical. If TRUE, turns on posthoc, effect.size, levene,
#'   and ci all at once.
#'
#' @return Invisibly returns the model object (aov or oneway.test).
#'
#' @examples
#' jaov(mpg ~ cyl, data = mtcars)
#' jaov(mpg ~ cyl, data = mtcars, welch = TRUE)
#' jaov(mpg ~ cyl, data = mtcars, full = TRUE)
#'
#' @export
#' @importFrom stats aov oneway.test TukeyHSD qt
jaov <- function(formula, data, welch = FALSE, posthoc = FALSE,
                 effect.size = FALSE, levene = FALSE, ci = FALSE,
                 labels = TRUE, full = FALSE) {

  if (full) {
    posthoc     <- TRUE
    effect.size <- TRUE
    levene      <- TRUE
    ci          <- TRUE
  }

  # Red title
  if (welch) {
    .cat_red("Welch's One-Way ANOVA\n")
  } else {
    .cat_red("One-Way ANOVA\n")
  }

  terms      <- all.vars(formula)
  dv_name    <- terms[1]
  group_name <- terms[2]

  group_var   <- data[[group_name]]
  is_labelled <- haven::is.labelled(group_var)
  if (is_labelled) {
    original_codes <- sort(unique(as.numeric(group_var[!is.na(group_var)])))
  }

  if (is_labelled) {
    data[[group_name]] <- haven::as_factor(group_var)
  } else if (!is.factor(group_var)) {
    data[[group_name]] <- factor(group_var)
  }

  if (haven::is.labelled(data[[dv_name]])) {
    data[[dv_name]] <- as.numeric(data[[dv_name]])
  }

  if (labels) {
    .print_var_labels(data, c(dv_name, group_name))
  }

  # Levene's test
  if (levene) {
    group_factor  <- data[[group_name]]
    dv_vals       <- data[[dv_name]]
    group_means   <- tapply(dv_vals, group_factor, mean, na.rm = TRUE)
    abs_devs      <- abs(dv_vals - group_means[group_factor])
    levene_model  <- stats::aov(abs_devs ~ group_factor)
    levene_result <- summary(levene_model)[[1]]
    levene_f      <- round(levene_result$`F value`[1], 3)
    levene_p      <- levene_result$`Pr(>F)`[1]
    levene_p_fmt  <- if (!is.na(levene_p) && levene_p < 0.001) "<.001" else sprintf("%.3f", levene_p)

    levene_table <- data.frame(
      F_value = levene_f,
      df1     = levene_result$Df[1],
      df2     = levene_result$Df[2],
      p_value = levene_p_fmt,
      stringsAsFactors = FALSE,
      row.names = NULL
    )

    .print_kable(levene_table,
                 caption = "Levene's Test for Homogeneity of Variance",
                 col.names = c("F", "df1", "df2", "p"),
                 row.names = FALSE)
    cat("\n")
  }

  # Group descriptives
  levels    <- levels(data[[group_name]])
  desc_rows <- lapply(seq_along(levels), function(i) {
    lvl        <- levels[i]
    group_data <- data[[dv_name]][data[[group_name]] == lvl]
    group_data <- group_data[!is.na(group_data)]
    n <- length(group_data)
    m <- mean(group_data)
    s <- sd(group_data)

    group_label <- if (is_labelled) {
      paste0(original_codes[i], ": ", lvl)
    } else {
      lvl
    }

    row <- data.frame(
      Group = group_label,
      N     = n,
      Mean  = round(m, 3),
      SD    = round(s, 3),
      stringsAsFactors = FALSE
    )

    if (ci) {
      se     <- s / sqrt(n)
      t_crit <- stats::qt(0.975, df = n - 1)
      row$CI_Lower <- round(m - t_crit * se, 3)
      row$CI_Upper <- round(m + t_crit * se, 3)
    }

    row
  })
  desc_table <- do.call(rbind, desc_rows)

  if (ci) {
    .print_kable(desc_table,
                 caption = paste("Group Descriptives:", dv_name, "by", group_name),
                 col.names = c("Group", "N", "Mean", "SD",
                               "95% CI Lower", "95% CI Upper"),
                 row.names = FALSE)
  } else {
    .print_kable(desc_table,
                 caption = paste("Group Descriptives:", dv_name, "by", group_name),
                 row.names = FALSE)
  }
  cat("\n")

  if (welch) {
    model <- oneway.test(formula, data = data, var.equal = FALSE)

    p_val <- model$p.value
    p_fmt <- if (!is.na(p_val) && p_val < 0.001) "<.001" else sprintf("%.3f", p_val)

    welch_table <- data.frame(
      F_value = round(model$statistic, 3),
      df1     = round(model$parameter[1], 1),
      df2     = round(model$parameter[2], 1),
      p_value = p_fmt,
      stringsAsFactors = FALSE,
      row.names = NULL
    )

    .print_kable(welch_table,
                 caption = paste("Welch's ANOVA:", dv_name, "by", group_name),
                 col.names = c("F", "df1", "df2", "p"),
                 row.names = FALSE)

    cat("\nNote: Sum of Squares and Mean Squares are not available for Welch's ANOVA.\n",
        "To obtain these, run jaov() without welch = TRUE.\n", sep = "")

    if (posthoc) {
      cat("\nNote: Tukey HSD post-hoc tests are not available with Welch's ANOVA.\n",
          "Run without welch = TRUE for post-hoc comparisons.\n", sep = "")
    }

    if (effect.size) {
      temp_model  <- stats::aov(formula, data = data)
      temp_result <- summary(temp_model)[[1]]
      eta_sq <- round(temp_result$`Sum Sq`[1] / sum(temp_result$`Sum Sq`), 3)
      cat("\nEta-squared:", eta_sq, "\n")
      cat("(Note: Eta-squared is calculated from the traditional SS decomposition.)\n")
    }

  } else {
    model  <- aov(formula, data = data)
    result <- summary(model)[[1]]

    total_df <- sum(result$Df)
    total_ss <- sum(result$`Sum Sq`)

    p_val <- result$`Pr(>F)`[1]
    p_fmt <- if (!is.na(p_val) && p_val < 0.001) "<.001" else sprintf("%.3f", p_val)

    anova_table <- data.frame(
      Source         = c(group_name, "Residual", "Total"),
      df             = c(result$Df, total_df),
      Sum_of_Squares = round(c(result$`Sum Sq`, total_ss), 3),
      Mean_Square    = c(round(result$`Mean Sq`, 3), NA),
      F_value        = c(round(result$`F value`[1], 3), NA, NA),
      p_value        = c(p_fmt, NA, NA),
      stringsAsFactors = FALSE
    )

    .print_kable(anova_table,
                 caption = paste("ANOVA:", dv_name, "by", group_name),
                 col.names = c("Source", "df", "Sum of Squares",
                               "Mean Square", "F", "p"),
                 row.names = FALSE)

    if (effect.size) {
      eta_sq <- round(result$`Sum Sq`[1] / sum(result$`Sum Sq`), 3)
      cat("\nEta-squared:", eta_sq, "\n")
    }

    if (posthoc) {
      tukey        <- stats::TukeyHSD(model)
      tukey_result <- as.data.frame(tukey[[1]])

      tukey_p     <- tukey_result$`p adj`
      tukey_p_fmt <- ifelse(!is.na(tukey_p) & tukey_p < 0.001, "<.001",
                            sprintf("%.3f", tukey_p))

      tukey_table <- data.frame(
        Comparison = rownames(tukey_result),
        Difference = round(tukey_result$diff, 3),
        CI_Lower   = round(tukey_result$lwr,  3),
        CI_Upper   = round(tukey_result$upr,  3),
        p_adj      = tukey_p_fmt,
        stringsAsFactors = FALSE,
        row.names  = NULL
      )

      cat("\n")
      .print_kable(tukey_table,
                   caption = "Tukey HSD Post-Hoc Comparisons",
                   col.names = c("Comparison", "Mean Difference",
                                 "95% CI Lower", "95% CI Upper",
                                 "p (adjusted)"),
                   row.names = FALSE)
    }
  }

  invisible(model)
}


# -- jcorr --------------------------------------------------------------------

#' Bivariate correlation matrix with p values and pairwise N
#'
#' Computes pairwise correlations and prints a formatted lower-triangle
#' correlation matrix showing r, p values, and pairwise N for each pair.
#' Supports Pearson (default), Spearman, and Kendall methods.
#' Handles haven-labelled and factor variables with numeric levels.
#' Warns when variables may be categorical rather than continuous.
#'
#' A red title identifying the correlation method is printed first,
#' followed by variable labels (if present), then the matrix.
#'
#' @param data A data frame.
#' @param ... Unquoted variable names within \code{data}.
#' @param method Character. Correlation method: "pearson" (default),
#'   "spearman", or "kendall".
#' @param labels Logical. If TRUE (default), prints variable labels
#'   when available.
#'
#' @return Invisibly returns a list containing the correlation matrix,
#'   p-value matrix, and pairwise N matrix.
#'
#' @examples
#' jcorr(mtcars, mpg, hp, wt)
#' jcorr(mtcars, mpg, hp, wt, method = "spearman")
#'
#' @importFrom stats cor.test complete.cases
#' @export
jcorr <- function(data, ..., method = "pearson", labels = TRUE) {
  variables      <- rlang::enquos(...)
  variable_names <- purrr::map_chr(variables, rlang::quo_name)

  if (length(variable_names) < 2) {
    stop("jcorr() requires at least 2 variables. Only 1 was provided.", call. = FALSE)
  }

  method <- tolower(method)
  if (!method %in% c("pearson", "spearman", "kendall")) {
    stop("method must be 'pearson', 'spearman', or 'kendall'.", call. = FALSE)
  }

  method_label <- switch(method,
                         pearson  = "Pearson",
                         spearman = "Spearman",
                         kendall  = "Kendall")

  # Red title
  .cat_red(paste0(method_label, " Bivariate Correlations\n"))

  cor_data <- data[, variable_names, drop = FALSE]

  for (v in variable_names) {
    if (haven::is.labelled(cor_data[[v]])) {
      warning(paste0("'", v, "' is a haven-labelled variable and may be categorical. ",
                     "Pearson correlations assume continuous/interval data. ",
                     "Verify this variable is appropriate for correlation."), call. = FALSE)
      cor_data[[v]] <- as.numeric(cor_data[[v]])
    } else if (is.factor(cor_data[[v]])) {
      numeric_check <- suppressWarnings(as.numeric(as.character(cor_data[[v]])))
      if (all(is.na(numeric_check[!is.na(cor_data[[v]])]))) {
        stop(paste0("'", v,
                    "' is a factor with text categories and cannot be used ",
                    "in a correlation. Use a numeric variable instead."), call. = FALSE)
      }
      warning(paste0("'", v, "' is a factor with numeric levels and may be categorical. ",
                     "Pearson correlations assume continuous/interval data. ",
                     "Verify this variable is appropriate for correlation."), call. = FALSE)
      cor_data[[v]] <- numeric_check
    } else if (is.character(cor_data[[v]])) {
      stop(paste0("'", v, "' is a character variable and cannot be used ",
                  "in a correlation. Use a numeric variable instead."), call. = FALSE)
    } else if (is.numeric(cor_data[[v]])) {
      n_unique <- length(unique(cor_data[[v]][!is.na(cor_data[[v]])]))
      if (n_unique <= 5) {
        warning(paste0("'", v, "' has only ", n_unique, " unique values and may be categorical. ",
                       "Pearson correlations assume continuous/interval data. ",
                       "Verify this variable is appropriate for correlation."), call. = FALSE)
      }
    }
  }

  n_vars   <- length(variable_names)
  r_matrix <- matrix(NA, n_vars, n_vars, dimnames = list(variable_names, variable_names))
  p_matrix <- matrix(NA, n_vars, n_vars, dimnames = list(variable_names, variable_names))
  n_matrix <- matrix(NA, n_vars, n_vars, dimnames = list(variable_names, variable_names))

  for (i in seq_len(n_vars)) {
    for (j in seq_len(n_vars)) {
      complete       <- stats::complete.cases(cor_data[[i]], cor_data[[j]])
      n_matrix[i, j] <- sum(complete)
      if (i == j) {
        r_matrix[i, j] <- 1
      } else if (n_matrix[i, j] > 2) {
        test            <- stats::cor.test(cor_data[[i]], cor_data[[j]], method = method)
        r_matrix[i, j] <- test$estimate
        p_matrix[i, j] <- test$p.value
      }
    }
  }

  display <- matrix("", n_vars, n_vars, dimnames = list(variable_names, variable_names))

  for (i in seq_len(n_vars)) {
    for (j in seq_len(n_vars)) {
      if (i == j) {
        display[i, j] <- "1"
      } else if (j < i) {
        r_fmt <- sprintf("%.3f", r_matrix[i, j])
        p_fmt <- if (!is.na(p_matrix[i, j]) && p_matrix[i, j] < 0.001) {
          "<.001"
        } else {
          sprintf("%.3f", p_matrix[i, j])
        }
        display[i, j] <- paste0(r_fmt, " (p=", p_fmt, ") N=", n_matrix[i, j])
      }
    }
  }

  display_df <- as.data.frame(display, stringsAsFactors = FALSE)

  if (labels) {
    .print_var_labels(data, variable_names)
  }

  .print_kable(display_df,
               caption = paste0("Bivariate Correlations (", method_label, ")"))

  invisible(list(r = r_matrix, p = p_matrix, n = n_matrix, method = method))
}


# -- jlm ----------------------------------------------------------------------

#' SPSS-like linear regression output with standardised coefficients
#'
#' Fits a linear model using \code{stats::lm()} and prints SPSS-style output,
#' including unstandardised coefficients, standard errors, t values, p values,
#' and standardised coefficients ("Std B"). Standardised coefficients are left
#' blank for the intercept and for dummy-coded factor terms.
#'
#' Also prints key model summary information (R-squared, residual standard
#' error, F-test, sums of squares, and N). If any coefficients are dropped
#' due to perfect collinearity, a warning message is printed.
#'
#' A red "Linear Regression" title is printed first, followed by variable
#' labels (if present), then the coefficient table and model fit statistics.
#'
#' Handles haven-labelled variables by converting them appropriately before
#' fitting the model.
#'
#' @param formula A model formula, e.g. \code{y ~ x1 + x2}.
#' @param data A data frame containing variables referenced in \code{formula}.
#' @param labels Logical. If TRUE (default), prints variable labels
#'   when available.
#'
#' @return Invisibly returns a list containing the fitted model, a coefficient
#'   table (data frame), and model fit statistics.
#'
#' @examples
#' jlm(mpg ~ hp + wt, data = mtcars)
#'
#' @export
jlm <- function(formula, data, labels = TRUE) {

  # Red title
  .cat_red("Linear Regression\n")

  model_vars <- all.vars(formula)

  for (v in model_vars) {
    if (haven::is.labelled(data[[v]])) {
      if (v == model_vars[1]) {
        data[[v]] <- as.numeric(data[[v]])
      } else {
        data[[v]] <- haven::as_factor(data[[v]])
      }
    }
  }

  if (labels) {
    .print_var_labels(data, model_vars)
  }

  mf            <- stats::model.frame(formula, data = data, na.action = stats::na.omit)
  model         <- stats::lm(formula, data = mf)
  model_summary <- summary(model)

  coefs <- as.data.frame(model_summary$coefficients, stringsAsFactors = FALSE)
  colnames(coefs)[1:4] <- c("b", "StdErr", "t", "P")

  mf_std   <- mf
  num_cols <- vapply(mf_std, is.numeric, logical(1))
  mf_std[, num_cols] <- lapply(mf_std[, num_cols, drop = FALSE], scale)

  std_model        <- stats::lm(formula, data = mf_std)
  std_coefs        <- stats::coef(std_model)
  std_b            <- rep(NA_real_, nrow(coefs))
  names(std_b)     <- rownames(coefs)
  common           <- intersect(names(std_coefs), names(std_b))
  std_b[common]    <- std_coefs[common]

  if ("(Intercept)" %in% names(std_b)) std_b["(Intercept)"] <- NA_real_

  factor_terms <- names(mf)[vapply(mf, is.factor, logical(1))]
  if (length(factor_terms) > 0) {
    for (term in factor_terms) {
      dummy_rows        <- grep(paste0("^", term), rownames(coefs), value = TRUE)
      std_b[dummy_rows] <- NA_real_
    }
  }

  p_num <- suppressWarnings(as.numeric(coefs$P))
  p_fmt <- ifelse(!is.na(p_num) & p_num < 0.001, "<.001",
                  ifelse(is.na(p_num), "<.001", sprintf("%.3f", p_num)))

  fmt3 <- function(x) sprintf("%.3f", as.numeric(x))

  out_coefs <- data.frame(
    b       = fmt3(coefs$b),
    StdErr  = fmt3(coefs$StdErr),
    t       = fmt3(coefs$t),
    `Std B` = ifelse(is.na(std_b), "", sprintf("%.3f", as.numeric(std_b))),
    P       = p_fmt,
    stringsAsFactors = FALSE,
    row.names = rownames(coefs)
  )

  r_squared   <- round(model_summary$r.squared, 3)
  residual_se <- round(model_summary$sigma, 3)

  f_stat  <- model_summary$fstatistic
  f_value <- round(unname(f_stat[1]), 3)
  df1     <- unname(f_stat[2])
  df2     <- unname(f_stat[3])
  f_p     <- stats::pf(f_value, df1, df2, lower.tail = FALSE)
  f_p_fmt <- ifelse(is.na(f_p) | f_p < 0.001, "<.001", sprintf("%.3f", f_p))

  n_obs         <- stats::nobs(model)
  y             <- stats::model.response(mf)
  ss_total      <- round(sum((y - mean(y))^2), 3)
  ss_regression <- round(sum((stats::fitted(model) - mean(y))^2), 3)
  ss_residual   <- round(sum(stats::residuals(model)^2), 3)

  if (any(is.na(stats::coef(model)))) {
    cat("\nWARNING: One or more variables have been removed from the model due to collinearity.\n")
  }

  cat("\nCoefficients:\n")
  print(out_coefs, quote = FALSE)

  cat("\nR-squared: ", sprintf("%.3f", r_squared), "\n", sep = "")
  cat("Residual Standard Error: ", sprintf("%.3f", residual_se), "\n", sep = "")
  cat("\nF-statistic: ", sprintf("%.3f", f_value),
      " on ", df1, " and ", df2,
      " DF, p-value: ", f_p_fmt, "\n", sep = "")
  cat("Sum of Squares:\n")
  cat("  Regression: ", sprintf("%.3f", ss_regression), "\n", sep = "")
  cat("  Residual:   ", sprintf("%.3f", ss_residual),   "\n", sep = "")
  cat("  Total:      ", sprintf("%.3f", ss_total),      "\n", sep = "")
  cat("\nNumber of observations: ", n_obs, "\n", sep = "")

  invisible(list(
    model           = model,
    coefficients    = out_coefs,
    r_squared       = r_squared,
    residual_se     = residual_se,
    f_statistic     = c(value = f_value, df1 = df1, df2 = df2, p = f_p),
    sums_of_squares = c(regression = ss_regression,
                        residual   = ss_residual,
                        total      = ss_total),
    n = n_obs
  ))
}


# -- jchisq -------------------------------------------------------------------

#' Chi-square test of independence with cross-tabulation
#'
#' Produces an SPSS-style cross-tabulation of two categorical variables
#' with observed frequencies, expected frequencies, row percentages,
#' column percentages, and a chi-square test of independence. Handles
#' haven-labelled, numeric, factor, and character variables.
#' For haven-labelled variables, numeric codes are displayed alongside
#' labels.
#'
#' A red "Chi-Square Analysis" title is printed first, followed by
#' variable labels (if present), then the cross-tabulation and test results.
#'
#' @param formula A formula of the form \code{Row ~ Column}.
#' @param data A data frame containing variables referenced in \code{formula}.
#' @param expected Logical. If TRUE, prints expected frequencies alongside
#'   observed. Default is FALSE.
#' @param row.pct Logical. If TRUE (default), shows row percentages.
#' @param col.pct Logical. If TRUE, shows column percentages. Default is FALSE.
#' @param labels Logical. If TRUE (default), prints variable labels
#'   when available.
#'
#' @return Invisibly returns a list containing the cross-tabulation,
#'   chi-square statistic, degrees of freedom, and p value.
#'
#' @examples
#' jchisq(cyl ~ am, data = mtcars)
#' jchisq(cyl ~ am, data = mtcars, expected = TRUE, col.pct = TRUE)
#'
#' @importFrom stats chisq.test
#' @export
jchisq <- function(formula, data, expected = FALSE, row.pct = TRUE,
                   col.pct = FALSE, labels = TRUE) {

  terms    <- all.vars(formula)
  row_name <- terms[1]
  col_name <- terms[2]

  # Red title
  .cat_red("Chi-Square Analysis\n")

  row_var <- data[[row_name]]
  col_var <- data[[col_name]]

  row_labelled <- haven::is.labelled(row_var)
  col_labelled <- haven::is.labelled(col_var)

  if (row_labelled) {
    row_codes <- sort(unique(as.numeric(row_var[!is.na(row_var)])))
    row_var   <- haven::as_factor(row_var)
  } else if (!is.factor(row_var)) {
    row_var <- factor(row_var)
  }

  if (col_labelled) {
    col_codes <- sort(unique(as.numeric(col_var[!is.na(col_var)])))
    col_var   <- haven::as_factor(col_var)
  } else if (!is.factor(col_var)) {
    col_var <- factor(col_var)
  }

  if (labels) {
    .print_var_labels(data, c(row_name, col_name))
  }

  row_levels <- levels(row_var)
  col_levels <- levels(col_var)
  row_labels <- if (row_labelled) paste0(row_codes, ": ", row_levels) else row_levels
  col_labels <- if (col_labelled) paste0(col_codes, ": ", col_levels) else col_levels

  obs_table  <- table(row_var, col_var)
  chi_result <- suppressWarnings(stats::chisq.test(obs_table))
  exp_table  <- chi_result$expected

  p_val <- chi_result$p.value
  p_fmt <- if (!is.na(p_val) && p_val < 0.001) "<.001" else sprintf("%.3f", p_val)

  n_rows <- length(row_levels)
  n_cols <- length(col_levels)
  header <- c(row_name, col_labels, "Total")

  display_rows <- list()

  for (i in seq_len(n_rows)) {
    obs_vals  <- as.numeric(obs_table[i, ])
    row_total <- sum(obs_vals)
    display_rows <- c(display_rows,
                      list(c(row_labels[i], as.character(obs_vals),
                             as.character(row_total))))

    if (expected) {
      exp_vals     <- round(exp_table[i, ], 1)
      display_rows <- c(display_rows,
                        list(c("  (Expected)", sprintf("%.1f", exp_vals),
                               sprintf("%.1f", sum(exp_vals)))))
    }

    if (row.pct) {
      row_pcts     <- round(obs_vals / row_total * 100, 1)
      display_rows <- c(display_rows,
                        list(c("  (Row %)", sprintf("%.1f%%", row_pcts), "100.0%")))
    }

    if (col.pct) {
      col_totals    <- colSums(obs_table)
      col_pcts      <- round(obs_vals / col_totals * 100, 1)
      grand_total   <- sum(obs_table)
      col_pct_total <- round(row_total / grand_total * 100, 1)
      display_rows  <- c(display_rows,
                         list(c("  (Col %)", sprintf("%.1f%%", col_pcts),
                                sprintf("%.1f%%", col_pct_total))))
    }
  }

  col_totals  <- colSums(obs_table)
  grand_total <- sum(obs_table)
  display_rows <- c(display_rows,
                    list(c("Total", as.character(col_totals),
                           as.character(grand_total))))

  if (col.pct) {
    display_rows <- c(display_rows,
                      list(c("  (Col %)", rep("100.0%", n_cols), "100.0%")))
  }

  display_df           <- as.data.frame(do.call(rbind, display_rows),
                                        stringsAsFactors = FALSE)
  colnames(display_df) <- header

  .print_kable(display_df,
               caption = paste("Cross-tabulation:", row_name, "by", col_name),
               row.names = FALSE)
  cat("\n")

  chi_table <- data.frame(
    Chi_Square = round(chi_result$statistic, 3),
    df         = chi_result$parameter,
    p          = p_fmt,
    N          = grand_total,
    stringsAsFactors = FALSE,
    row.names  = NULL
  )

  .print_kable(chi_table,
               caption = "Chi-Square Test of Independence",
               col.names = c("Chi-Square", "df", "p", "N"),
               row.names = FALSE)

  min_expected <- min(exp_table)
  n_below_5    <- sum(exp_table < 5)
  if (n_below_5 > 0) {
    cat(paste0("\nNote: ", n_below_5, " cell(s) have expected frequencies less than 5 ",
               "(minimum expected = ", round(min_expected, 1), "). ",
               "Chi-square results may not be reliable.\n"))
  }

  invisible(list(
    observed   = obs_table,
    expected   = exp_table,
    chi_square = chi_result$statistic,
    df         = chi_result$parameter,
    p          = chi_result$p.value,
    n          = grand_total
  ))
}


# -- jscreen ------------------------------------------------------------------

#' Data screening overview
#'
#' Provides a quick overview of a data frame including the number of
#' cases, variable types, missing data counts and percentages, and
#' potential outliers for numeric variables. Handles haven-labelled
#' variables by reporting their labelled status.
#'
#' A red "Data Screening" title is printed first, followed by a dataset
#' summary, variable labels (if present), and the screening table.
#'
#' @param data A data frame.
#' @param outlier.sd Numeric. Number of standard deviations from the mean
#'   to flag as potential outliers. Default is 3.
#' @param labels Logical. If TRUE (default), prints variable labels
#'   when available.
#'
#' @return Invisibly returns a data frame containing the screening results.
#'
#' @examples
#' jscreen(mtcars)
#' jscreen(mtcars, outlier.sd = 2.5)
#'
#' @export
jscreen <- function(data, outlier.sd = 3, labels = TRUE) {

  n_cases   <- nrow(data)
  n_vars    <- ncol(data)
  var_names <- names(data)

  # Red title
  .cat_red("Data Screening\n")
  cat("  Cases:", n_cases, "\n")
  cat("  Variables:", n_vars, "\n")
  cat("  Complete cases (no missing on any variable):",
      sum(stats::complete.cases(data)), "\n")

  screen_rows <- lapply(var_names, function(v) {
    col <- data[[v]]

    var_type <- if (haven::is.labelled(col)) {
      "haven_labelled"
    } else if (is.factor(col)) {
      "factor"
    } else if (is.numeric(col)) {
      "numeric"
    } else if (is.character(col)) {
      "character"
    } else {
      paste(class(col), collapse = ", ")
    }

    n_missing   <- sum(is.na(col))
    pct_missing <- round(n_missing / n_cases * 100, 1)
    n_unique    <- length(unique(col[!is.na(col)]))

    n_outliers <- NA
    if (is.numeric(col) || haven::is.labelled(col)) {
      num_col <- as.numeric(col)
      m <- mean(num_col, na.rm = TRUE)
      s <- stats::sd(num_col, na.rm = TRUE)
      n_outliers <- if (!is.na(s) && s > 0) {
        sum(abs(num_col - m) > outlier.sd * s, na.rm = TRUE)
      } else {
        0
      }
    }

    data.frame(
      Variable    = v,
      Type        = var_type,
      Unique      = n_unique,
      Missing     = n_missing,
      Pct_Missing = pct_missing,
      Outliers    = n_outliers,
      stringsAsFactors = FALSE
    )
  })

  screen_table <- do.call(rbind, screen_rows)

  if (labels) {
    cat("\n")
    .print_var_labels(data, var_names)
  } else {
    cat("\n")
  }

  .print_kable(screen_table,
               caption = paste0("Data Screening (outliers defined as > ",
                                outlier.sd, " SD from mean)"),
               col.names = c("Variable", "Type", "Unique Values",
                             "Missing", "% Missing", "Outliers"),
               row.names = FALSE)

  missing_vars <- screen_table[screen_table$Missing > 0, ]
  outlier_vars <- screen_table[!is.na(screen_table$Outliers) &
                                 screen_table$Outliers > 0, ]

  if (nrow(missing_vars) > 0) {
    cat("\nVariables with missing data:\n")
    for (i in seq_len(nrow(missing_vars))) {
      cat("  ", missing_vars$Variable[i], ": ",
          missing_vars$Missing[i], " missing (",
          missing_vars$Pct_Missing[i], "%)\n", sep = "")
    }
  } else {
    cat("\nNo missing data detected.\n")
  }

  if (nrow(outlier_vars) > 0) {
    cat("\nVariables with potential outliers (> ", outlier.sd, " SD):\n", sep = "")
    for (i in seq_len(nrow(outlier_vars))) {
      cat("  ", outlier_vars$Variable[i], ": ",
          outlier_vars$Outliers[i], " cases\n", sep = "")
    }
  } else {
    cat("\nNo potential outliers detected.\n")
  }

  cat("\n")
  invisible(screen_table)
}


# -- jalpha -------------------------------------------------------------------

#' Cronbach's Alpha Reliability Analysis
#'
#' Computes Cronbach's alpha and prints SPSS-style reliability output
#' including a case processing summary, overall alpha, item statistics,
#' and item-total statistics with alpha-if-item-deleted. Built from
#' scratch with no external package dependencies beyond base R.
#' Handles haven-labelled variables automatically. Detects potentially
#' reverse-coded or misfit items.
#'
#' A red "Reliability Analysis" title is printed first, followed by the
#' case processing summary, overall alpha, item statistics, and
#' item-total statistics.
#'
#' @param data A data frame.
#' @param ... Unquoted variable names (scale items) within \code{data}.
#' @param labels Logical. If TRUE (default), prints variable labels
#'   when available.
#'
#' @return Invisibly returns a list containing the overall alpha,
#'   item statistics data frame, and item-total statistics data frame.
#'
#' @examples
#' jalpha(attitude, rating, complaints, privileges, learning, raises)
#'
#' @export
jalpha <- function(data, ..., labels = TRUE) {
  variables      <- rlang::enquos(...)
  variable_names <- purrr::map_chr(variables, rlang::quo_name)

  # Red title
  .cat_red("Reliability Analysis\n")

  items <- data[, variable_names, drop = FALSE]

  for (v in variable_names) {
    if (haven::is.labelled(items[[v]])) {
      items[[v]] <- as.numeric(items[[v]])
    }
  }

  complete_mask  <- stats::complete.cases(items)
  n_total        <- nrow(items)
  n_used         <- sum(complete_mask)
  n_excluded     <- n_total - n_used
  items_complete <- items[complete_mask, ]

  # Case Processing Summary
  case_table <- data.frame(
    Cases   = c("Valid", "Excluded", "Total"),
    N       = c(n_used, n_excluded, n_total),
    Percent = sprintf("%.1f", c(n_used / n_total * 100,
                                n_excluded / n_total * 100,
                                100)),
    stringsAsFactors = FALSE
  )

  cat("\n")
  .print_kable(case_table,
               caption = "Case Processing Summary",
               col.names = c("", "N", "%"),
               row.names = FALSE)
  cat("\n")

  # Overall Cronbach's Alpha
  k             <- ncol(items_complete)
  item_vars     <- sapply(items_complete, stats::var)
  total_var     <- stats::var(rowSums(items_complete))
  alpha_overall <- round((k / (k - 1)) * (1 - sum(item_vars) / total_var), 3)

  alpha_table <- data.frame(
    Alpha   = alpha_overall,
    N_Items = k,
    stringsAsFactors = FALSE
  )

  .print_kable(alpha_table,
               caption = "Reliability Statistics",
               col.names = c("Cronbach's Alpha", "N of Items"),
               row.names = FALSE)
  cat("\n")

  # Variable Labels
  if (labels) {
    .print_var_labels(data, variable_names)
  }

  # Item Statistics
  item_stats <- data.frame(
    Item = variable_names,
    Mean = round(colMeans(items_complete), 3),
    SD   = round(sapply(items_complete, stats::sd), 3),
    N    = n_used,
    stringsAsFactors = FALSE,
    row.names = NULL
  )

  .print_kable(item_stats,
               caption = "Item Statistics",
               row.names = FALSE)
  cat("\n")

  # Item-Total Statistics
  total_scores    <- rowSums(items_complete)

  item_total_rows <- lapply(seq_along(variable_names), function(i) {
    item_name   <- variable_names[i]
    item_col    <- items_complete[[i]]
    rest_total  <- total_scores - item_col
    r_corrected <- round(stats::cor(item_col, rest_total), 3)

    remaining <- items_complete[, -i, drop = FALSE]
    k_r <- ncol(remaining)
    alpha_deleted <- if (k_r < 2) {
      NA
    } else {
      item_vars_r <- sapply(remaining, stats::var)
      total_var_r <- stats::var(rowSums(remaining))
      round((k_r / (k_r - 1)) * (1 - sum(item_vars_r) / total_var_r), 3)
    }

    data.frame(
      Item                   = item_name,
      Corrected_Item_Total_r = r_corrected,
      Alpha_If_Deleted       = alpha_deleted,
      stringsAsFactors       = FALSE
    )
  })

  item_total_table <- do.call(rbind, item_total_rows)

  # Diagnostic Warning
  neg_items <- item_total_table$Item[item_total_table$Corrected_Item_Total_r < 0]
  pos_items <- item_total_table$Item[item_total_table$Corrected_Item_Total_r >= 0]

  if (length(neg_items) > 0) {
    n_neg <- length(neg_items)
    n_pos <- length(pos_items)

    if (n_neg <= n_pos) {
      warning(paste0(
        "The following item(s) are negatively correlated with the rest ",
        "of the scale: ", paste(neg_items, collapse = ", "),
        ". This may indicate that these items need to be reverse-coded, ",
        "or that they do not belong in the scale. Examine the item-total ",
        "statistics table and the item content to determine the appropriate action."),
        call. = FALSE)
    } else {
      warning(paste0(
        "The majority of items are negatively correlated with the scale total. ",
        "This usually means that one or more items are coded in the opposite ",
        "direction or do not belong in the scale. Check the following item(s) ",
        "which are positively correlated while most others are not: ",
        paste(pos_items, collapse = ", ")),
        call. = FALSE)
    }
    cat("\n")
  }

  .print_kable(item_total_table,
               caption = "Item-Total Statistics",
               col.names = c("Item", "Corrected Item-Total r",
                             "Alpha if Item Deleted"),
               row.names = FALSE)

  invisible(list(
    alpha                 = alpha_overall,
    n_items               = k,
    n_used                = n_used,
    n_excluded            = n_excluded,
    item_statistics       = item_stats,
    item_total_statistics = item_total_table
  ))
}


# =============================================================================
# jrelabel()
# =============================================================================

#' Transfer variable and value labels after a simple recode
#'
#' @description
#' After recoding a variable in base R (using \code{ifelse} or arithmetic),
#' \code{jrelabel()} compares the original and recoded variable row by row,
#' automatically detects the value mapping, and transfers both the variable
#' label and value labels to the new variable.
#'
#' This function is intended for clean one-to-one recodes where each original
#' value maps to exactly one new value - for example, recoding 1/2 to 1/0, or
#' simple value shifts. It will not transfer value labels automatically if it
#' detects a reverse coding pattern or category collapsing, and will instead
#' issue an informative message explaining what to do next.
#'
#' @param data A data frame containing both variables.
#' @param orig_var The original variable (unquoted, e.g. \code{Gender}).
#' @param new_var  The recoded variable (unquoted, e.g. \code{GenderR}).
#'   This variable must already exist in the data frame - run your recode line
#'   before calling \code{jrelabel()}.
#'
#' @return The data frame with labels applied to the recoded variable.
#'
#' @details
#' The function handles \code{haven_labelled}, factor, and plain numeric
#' variables. For plain numeric variables with no labels, only the variable
#' label (derived from the original variable name) is applied.
#'
#' \strong{Reverse coding:} If the function detects that values have been
#' reversed (e.g. 1->5, 2->4, 3->3, 4->2, 5->1), it will \emph{not} transfer
#' value labels, as the original labels would be misleading in reverse order.
#' A message will guide you to assign labels manually.
#'
#' \strong{Collapsing:} If multiple original values map to the same new value,
#' labels cannot be transferred automatically. Use \code{\link{jrecode}} with
#' the \code{labels} argument instead.
#'
#' \strong{Existing labels:} If the new variable already has labels assigned,
#' the function will ask whether you want to overwrite them before proceeding.
#'
#' NA values are always copied across without modification.
#'
#' @examples
#' df <- data.frame(Status = c(1, 2, 1, 2, 1, 2))
#' df$StatusR <- ifelse(df$Status == 2, 0, 1)
#' df <- jrelabel(df, Status, StatusR)
#'
#' # Reverse coding - labels will not transfer (by design)
#' df$ScaleItem <- c(1, 2, 3, 4, 5, 3)
#' df$ScaleItemR <- 6 - df$ScaleItem
#' df <- jrelabel(df, ScaleItem, ScaleItemR)
#'
#' @seealso \code{\link{jrecode}} for recoding with collapsing or explicit
#'   value mapping; \code{labelled::val_labels} and \code{labelled::var_label}
#'   for manual label assignment.
#'
#' @export
jrelabel <- function(data, orig_var, new_var) {

  orig_name <- deparse(substitute(orig_var))
  new_name  <- deparse(substitute(new_var))

  # --- Input checks ---
  if (!is.data.frame(data)) {
    stop("The first argument must be a data frame.")
  }
  if (!orig_name %in% names(data)) {
    stop(paste0("Variable '", orig_name, "' not found in the data frame."))
  }
  if (!new_name %in% names(data)) {
    stop(paste0(
      "Variable '", new_name, "' not found in the data frame. ",
      "Run your recode line first, then call jrelabel()."
    ))
  }

  orig <- data[[orig_name]]
  new  <- data[[new_name]]

  # --- Determine type and extract existing labels ---
  is_haven  <- inherits(orig, "haven_labelled")
  is_factor <- is.factor(orig)

  if (is_haven) {
    orig_var_label  <- labelled::var_label(orig)
    orig_val_labels <- labelled::val_labels(orig)
  } else if (is_factor) {
    orig_var_label  <- NULL
    codes           <- seq_along(levels(orig))
    orig_val_labels        <- as.numeric(codes)
    names(orig_val_labels) <- levels(orig)
  } else {
    orig_var_label  <- NULL
    orig_val_labels <- NULL
  }

  # --- Build value mapping table (non-NA rows only) ---
  non_na      <- !is.na(orig) & !is.na(new)
  orig_num    <- as.numeric(orig)[non_na]
  new_num     <- as.numeric(new)[non_na]
  mapping     <- unique(data.frame(orig_val = orig_num, new_val = new_num,
                                   stringsAsFactors = FALSE))
  mapping     <- mapping[order(mapping$orig_val), ]

  # --- Detect mapping type ---
  is_collapsing <- any(table(mapping$new_val) > 1)

  is_reversed <- FALSE
  if (nrow(mapping) > 1 && !is_collapsing) {
    sorted_new  <- mapping[order(mapping$orig_val), "new_val"]
    is_reversed <- all(diff(sorted_new) < 0)
  }

  # --- Check for existing labels on new variable ---
  has_existing <- FALSE
  if (inherits(new, "haven_labelled")) {
    ev  <- labelled::var_label(new)
    el  <- labelled::val_labels(new)
    has_existing <- (!is.null(ev) && nchar(trimws(ev)) > 0) ||
      (!is.null(el) && length(el) > 0)
  }

  if (has_existing) {
    response <- readline(prompt = paste0(
      "Variable '", new_name, "' already has labels assigned. ",
      "Overwrite them? (yes/no): "
    ))
    if (!tolower(trimws(response)) %in% c("yes", "y")) {
      message("Labels for '", new_name, "' were not changed.")
      return(data)
    }
  }

  # --- Set variable label ---
  new_var_label <- if (!is.null(orig_var_label) && nchar(trimws(orig_var_label)) > 0) {
    paste0(orig_var_label, " (recoded)")
  } else {
    paste0(orig_name, " (recoded)")
  }

  # Ensure new variable is haven_labelled so we can attach labels
  if (!inherits(data[[new_name]], "haven_labelled")) {
    data[[new_name]] <- labelled::labelled(as.numeric(data[[new_name]]))
  }

  labelled::var_label(data[[new_name]]) <- new_var_label

  # --- Handle value labels based on detected mapping type ---

  if (is_collapsing) {
    message(
      "Category collapsing detected in '", new_name, "': multiple original values ",
      "map to the same new value. Value labels have not been transferred automatically.\n",
      "To assign value labels, use jrecode() with the labels argument, or assign ",
      "them manually with val_labels()."
    )
    return(data)
  }

  if (is_reversed) {
    message(
      "A reverse coding pattern was detected in '", new_name, "'. Value labels have ",
      "not been automatically transferred, as the original labels would be misleading ",
      "in reverse order (e.g., 'Strongly Disagree' would end up at the high end).\n",
      "Please assign new value labels manually using val_labels(), or use jrecode() ",
      "with the labels argument."
    )
    return(data)
  }

  # --- Transfer value labels for clean one-to-one mapping ---
  if (!is.null(orig_val_labels) && length(orig_val_labels) > 0) {
    new_val_labels <- orig_val_labels
    for (i in seq_along(orig_val_labels)) {
      old_code  <- unname(orig_val_labels[i])
      match_row <- mapping[mapping$orig_val == old_code, , drop = FALSE]
      if (nrow(match_row) == 1) {
        new_val_labels[i] <- match_row$new_val
      }
    }
    labelled::val_labels(data[[new_name]]) <- new_val_labels
  }

  return(data)
}


# =============================================================================
# jrecode()
# =============================================================================

#' Recode a variable with explicit value mapping and optional labels
#'
#' @description
#' \code{jrecode()} recodes a variable using a simple map string that specifies
#' how old values should be converted to new values. It is designed for
#' situations where you need to collapse categories, or where you want full
#' explicit control over the mapping. Variable and value labels are handled
#' automatically.
#'
#' For simple one-to-one recodes (e.g. \code{ifelse} or arithmetic), consider
#' using base R for the recode followed by \code{\link{jrelabel}} to restore
#' labels.
#'
#' @param data     A data frame containing the original variable.
#' @param orig_var The variable to recode (unquoted, e.g. \code{AgeGroup}).
#' @param map      A quoted string specifying the recode rules, using the
#'   format \code{"old=new"} with rules separated by semicolons. Multiple old
#'   values mapping to the same new value are separated by commas on the left
#'   side. Use \code{else=NA} (default) to set unspecified values to missing,
#'   or \code{else=copy} to carry them across unchanged.
#'
#'   Examples:
#'   \itemize{
#'     \item \code{"1=1; 2=0"}
#'     \item \code{"1=1; 2,3=2; 4,5=3; else=NA"}
#'     \item \code{"1=1; 2=0; else=copy"}
#'   }
#'
#' @param labels   Optional. A quoted string specifying value labels for the
#'   new variable, using the format \code{"code=Label Text"} with rules
#'   separated by semicolons. If omitted, no value labels are assigned and
#'   a reminder message is printed.
#'
#'   Example: \code{"1=Male; 0=Female"}
#'
#' @return A \code{haven_labelled} vector with the recoded values, variable
#'   label, and (if supplied) value labels applied. Assign this to a new
#'   column in your data frame:
#'   \code{SampleData$AgeGroupR <- jrecode(SampleData, AgeGroup, map = "...")}
#'
#' @details
#' The variable label from the original variable is carried across automatically
#' with "(recoded)" appended. If the original variable has no variable label,
#' the variable name is used instead.
#'
#' NA values in the original variable are always set to NA in the new variable,
#' regardless of the \code{else} setting.
#'
#' If the map specifies values that do not exist in the original variable, a
#' warning is issued (but the function continues). This helps catch typos in
#' the map string.
#'
#' If suspicious coded-missing values are detected (e.g. -99 sitting far
#' outside the main range of values), an informative note is printed suggesting
#' you convert them to NA before recoding.
#'
#' @examples
#' df <- data.frame(gear = mtcars$gear)
#' df$gearR <- jrecode(df, gear,
#'                     map    = "3=1; 4,5=2; else=NA",
#'                     labels = "1=Three gears; 2=Four or five gears")
#'
#' # Recode without labels (reminder message will be printed)
#' df$gearR2 <- jrecode(df, gear, map = "3=1; 4,5=2")
#'
#' # Use else=copy to carry unspecified values across unchanged
#' df$gearR3 <- jrecode(df, gear,
#'                      map    = "3=1; else=copy",
#'                      labels = "1=Three gears")
#'
#' @seealso \code{\link{jrelabel}} for automatically relabelling after a simple
#'   one-to-one recode.
#'
#' @export
jrecode <- function(data, orig_var, map, labels = NULL) {

  orig_name <- deparse(substitute(orig_var))

  # --- Input checks ---
  if (!is.data.frame(data)) {
    stop("The first argument must be a data frame.")
  }
  if (!orig_name %in% names(data)) {
    stop(paste0("Variable '", orig_name, "' not found in the data frame."))
  }
  if (missing(map) || !is.character(map) || length(map) != 1) {
    stop("The map argument must be a single quoted string, e.g. map = \"1=1; 2=0\".")
  }

  orig <- data[[orig_name]]

  # --- Check for suspicious coded missing values ---
  .jst_detect_suspicious_values(orig, orig_name)

  # --- Parse map string ---
  parsed_map <- tryCatch(
    .jst_parse_map(map),
    error = function(e) stop(paste0("Error in map argument: ", conditionMessage(e)))
  )

  # --- Apply recode ---
  orig_num  <- as.numeric(orig)
  new_num   <- rep(NA_real_, length(orig_num))

  all_specified_old <- c()

  for (rule in parsed_map$mappings) {
    old_vals <- rule$old_vals
    new_val  <- rule$new_val
    all_specified_old <- c(all_specified_old, old_vals)

    # Warn if a specified old value is not present in the data
    actual_vals       <- unique(orig_num[!is.na(orig_num)])
    missing_from_data <- setdiff(old_vals, actual_vals)
    if (length(missing_from_data) > 0) {
      warning(paste0(
        "Value(s) ", paste(missing_from_data, collapse = ", "),
        " specified in the map argument were not found in '", orig_name, "'. ",
        "Check for typos in your map string."
      ))
    }

    new_num[!is.na(orig_num) & orig_num %in% old_vals] <- new_val
  }

  # Handle unspecified non-NA values
  unspecified_mask <- !is.na(orig_num) & is.na(new_num)

  if (parsed_map$else_action == "copy") {
    new_num[unspecified_mask] <- orig_num[unspecified_mask]
  } else {
    # else = NA (default): leave as NA but inform the user
    unspecified_vals <- sort(unique(orig_num[unspecified_mask]))
    if (length(unspecified_vals) > 0) {
      message(
        "The following value(s) in '", orig_name, "' were not specified in the ",
        "map argument and have been set to NA in the new variable: ",
        paste(unspecified_vals, collapse = ", "), ".\n",
        "If this is not what you intended, add rules for these values in your ",
        "map argument, or use else=copy to carry unspecified values across unchanged."
      )
    }
  }

  # NAs in original are always NA in output
  new_num[is.na(orig_num)] <- NA_real_

  # --- Variable label ---
  is_haven       <- inherits(orig, "haven_labelled")
  orig_var_label <- if (is_haven) labelled::var_label(orig) else NULL

  new_var_label <- if (!is.null(orig_var_label) && nchar(trimws(orig_var_label)) > 0) {
    paste0(orig_var_label, " (recoded)")
  } else {
    paste0(orig_name, " (recoded)")
  }

  # --- Build output as haven_labelled vector ---
  result <- labelled::labelled(new_num)
  labelled::var_label(result) <- new_var_label

  # --- Value labels ---
  if (!is.null(labels)) {
    if (!is.character(labels) || length(labels) != 1) {
      stop("The labels argument must be a single quoted string, e.g. labels = \"1=Male; 0=Female\".")
    }
    parsed_labels <- tryCatch(
      .jst_parse_labels(labels),
      error = function(e) stop(paste0("Error in labels argument: ", conditionMessage(e)))
    )
    labelled::val_labels(result) <- parsed_labels
  } else {
    message(
      "No value labels have been assigned to the new variable. ",
      "To add value labels, use the labels argument - ",
      "e.g., labels = \"1=Category One; 2=Category Two\". ",
      "Run jfreq() to check your result."
    )
  }

  return(result)
}
