#' Computes basic descriptive statistics (N, non-missing, min, max, mean, SD)
#' for one or more variables in a data frame. Prints a formatted table and
#' invisibly returns the underlying results as a data frame.
#'
#' Handles haven-labelled, factor, and plain numeric variables. If a factor
#' with text categories is passed, a warning is issued directing the user
#' to jfreq() instead.
#'
#' @param data A data frame.
#' @param ... Unquoted variable names within `data`.
#'
#' @return Invisibly returns a data frame of descriptive statistics. Also prints a table.
#'
#' @examples
#' jdesc(mtcars, mpg)
#' jdesc(mtcars, mpg, hp, wt)
#'
#' @export
#'
jdesc <- function(data, ...) {
  variables <- rlang::enquos(...)
  variable_names <- purrr::map_chr(variables, rlang::quo_name)
  descriptives_list <- lapply(variables, function(var) {
    var_name <- rlang::quo_name(var)
    var_data <- rlang::eval_tidy(var, data)

    # Handle haven-labelled variables
    if (haven::is.labelled(var_data)) {
      var_data <- as.numeric(var_data)
    }

    # Handle factor variables
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

    total_cases <- length(var_data)
    non_missing_cases <- sum(!is.na(var_data))
    min_val <- round(min(var_data, na.rm = TRUE), 3)
    max_val <- round(max(var_data, na.rm = TRUE), 3)
    mean_val <- round(mean(var_data, na.rm = TRUE), 3)
    sd_val <- round(stats::sd(var_data, na.rm = TRUE), 3)
    data.frame(
      Variable = var_name,
      Total = total_cases,
      Non_missing = non_missing_cases,
      Min = min_val,
      Max = max_val,
      Mean = mean_val,
      SD = sd_val,
      stringsAsFactors = FALSE
    )
  })
  descriptives_list <- Filter(Negate(is.null), descriptives_list)
  descriptives <- do.call(rbind, descriptives_list)
  # listwise cases (complete across selected variables)
  listwise_cases <- sum(stats::complete.cases(dplyr::select(data, dplyr::all_of(variable_names))))
  listwise_row <- data.frame(
    Variable = "Listwise_N",
    Total = NA,
    Non_missing = listwise_cases,
    Min = NA,
    Max = NA,
    Mean = NA,
    SD = NA,
    stringsAsFactors = FALSE
  )
  descriptives <- rbind(descriptives, listwise_row)
  print(knitr::kable(descriptives, caption = "Descriptive Statistics"))
  invisible(descriptives)
}


#' SPSS-like frequencies for categorical variables
#'
#' Prints SPSS-style frequency tables (Freq, Total %, Valid %, Cum. %) for one or
#' more variables in a data frame. Designed for use with unquoted
#' variable names. If a variable is a haven labelled vector, value labels and
#' the variable label (if present) are shown.
#'
#' @param data A data frame.
#' @param ... Unquoted variable name(s) within `data`.
#'
#' @return Invisibly returns a named list of data frames (one per variable)
#' containing the frequency table.
#'
#' @examples
#' # Basic example (categorical)
#' jfreq(mtcars, cyl, gear)
#'
#' # Labelled example (uses haven + labelled)
#' x <- haven::labelled(
#'   c(1, 2, 1, 9, NA),
#'   labels = c(Yes = 1, No = 2, "Don't know" = 9)
#' )
#' df <- data.frame(x = x)
#' labelled::var_label(df$x) <- "Example labelled variable"
#' jfreq(df, x)
#'
#' @export
#' @importFrom rlang .data
jfreq <- function(data, ...) {
  variables <- rlang::enquos(...)

  results <- list()

  for (variable in variables) {
    variable_name <- rlang::quo_name(variable)

    # Pull column as a vector
    temp_var <- dplyr::pull(data, !!variable)
    var_class <- class(temp_var)

    # If haven labelled, combine codes + labels for display and show variable label
    var_label <- NULL
    if (haven::is.labelled(temp_var)) {
      labels <- as.character(haven::as_factor(temp_var))
      codes <- as.numeric(temp_var)
      temp_var <- factor(ifelse(is.na(codes), NA, paste(codes, labels, sep = ": ")))

      # Variable label (if present)
      var_label <- labelled::var_label(data[[variable_name]])
    }

    # Convert numeric variables to factors
    if (is.numeric(temp_var)) {
      temp_var <- factor(temp_var)
    }

    # Frequency table
    freq_table <- data.frame(temp_var = temp_var, stringsAsFactors = FALSE) |>
      dplyr::count(temp_var, name = "Freq")

    # Percentages
    total_count <- length(temp_var)
    valid_count <- sum(!is.na(temp_var))

    freq_table <- freq_table |>
      dplyr::mutate(
        `Total %` = (.data$Freq / total_count) * 100,
        `Valid %` = ifelse(is.na(temp_var), NA_real_, (.data$Freq / valid_count) * 100),
        `Cum. %`  = ifelse(
          is.na(temp_var),
          NA_real_,
          cumsum(ifelse(is.na(temp_var), 0, (.data$Freq / valid_count) * 100))
        )
      )

    # Store for invisible return
    results[[variable_name]] <- freq_table

    # Formatting / printing
    max_length <- suppressWarnings(max(nchar(as.character(freq_table$temp_var)), na.rm = TRUE))
    first_col_width <- max(max_length, nchar("Category"), na.rm = TRUE)

    cat("Frequencies for", variable_name, "\n")
    cat("Type of variable:", paste(var_class, collapse = ", "), "\n")
    if (!is.null(var_label) && !is.na(var_label) && nzchar(var_label)) {
      cat("Variable label:", var_label, "\n")
    }
    cat("\n")

    cat(sprintf("%-*s", first_col_width, ""), "Freq", "Total %", "Valid %", "Cum. %", sep = "\t")
    cat("\n", strrep("-", first_col_width), "\t", strrep("-", 4), "\t", strrep("-", 7),
        "\t", strrep("-", 7), "\t", strrep("-", 6), sep = "")
    cat("\n")

    for (i in seq_len(nrow(freq_table))) {
      cat(
        sprintf("%-*s", first_col_width,
                ifelse(is.na(freq_table$temp_var[i]), "NA", as.character(freq_table$temp_var[i]))),
        "\t", freq_table$Freq[i],
        "\t", sprintf("%.2f", freq_table$`Total %`[i]),
        "\t", ifelse(is.na(freq_table$`Valid %`[i]), "", sprintf("%.2f", freq_table$`Valid %`[i])),
        "\t", ifelse(is.na(freq_table$`Cum. %`[i]), "", sprintf("%.2f", freq_table$`Cum. %`[i])),
        sep = ""
      )
      cat("\n")
    }
    cat("\n")
  }

  invisible(results)
}
#' Independent samples t-test (Student's or Welch's method)
#'
#' Runs an independent samples t-test and prints formatted group
#' descriptives and test results. By default, runs the traditional
#' Student's t-test assuming equal variances. Optional parameters
#' provide effect size (Cohen's d), Levene's test, confidence interval
#' for the mean difference, and Welch's correction. Handles
#' haven-labelled, numeric, and factor grouping variables.
#' For haven-labelled variables, numeric codes are displayed alongside
#' labels in the group descriptives table.
#'
#' @param formula A formula of the form \code{DV ~ Group}.
#' @param data A data frame containing variables referenced in \code{formula}.
#' @param welch Logical. If FALSE (default), runs Student's t-test
#'   (equal variances assumed). If TRUE, runs Welch's t-test.
#' @param effect.size Logical. If TRUE, prints Cohen's d.
#' @param levene Logical. If TRUE, prints Levene's test for homogeneity
#'   of variance.
#' @param ci Logical. If TRUE, adds 95\% confidence interval for the
#'   mean difference.
#' @param full Logical. If TRUE, turns on effect.size, levene, and ci
#'   all at once.
#'
#' @return Invisibly returns the \code{t.test} result object.
#'
#' @examples
#' mtcars$am_f <- factor(mtcars$am, labels = c("Auto", "Manual"))
#' jt(mpg ~ am_f, data = mtcars)
#' jt(mpg ~ am_f, data = mtcars, welch = TRUE)
#' jt(mpg ~ am_f, data = mtcars, full = TRUE)
#'
#' @export
#' @importFrom stats t.test sd qt
jt <- function(formula, data, welch = FALSE, effect.size = FALSE,
               levene = FALSE, ci = FALSE, full = FALSE) {

  # full = TRUE turns on all optional outputs
  if (full) {
    effect.size <- TRUE
    levene <- TRUE
    ci <- TRUE
  }

  # Extract variable names from the formula
  terms <- all.vars(formula)
  dv_name <- terms[1]
  group_name <- terms[2]

  # Get the grouping variable
  group_var <- data[[group_name]]

  # Capture numeric codes before conversion (for haven-labelled variables)
  is_labelled <- haven::is.labelled(group_var)
  if (is_labelled) {
    original_codes <- sort(unique(as.numeric(group_var[!is.na(group_var)])))
  }

  # Convert to factor if needed
  if (is_labelled) {
    data[[group_name]] <- haven::as_factor(group_var)
  } else if (!is.factor(group_var)) {
    data[[group_name]] <- factor(group_var)
  }

  # Check that grouping variable has exactly 2 levels
  n_levels <- nlevels(data[[group_name]])
  if (n_levels != 2) {
    stop(paste0("'", group_name, "' has ", n_levels,
                " categories. A t-test requires exactly 2. ",
                "Use jaov() for more than 2 categories."), call. = FALSE)
  }

  # Handle haven-labelled DV
  if (haven::is.labelled(data[[dv_name]])) {
    data[[dv_name]] <- as.numeric(data[[dv_name]])
  }

  # Levene's test (printed before descriptives if requested)
  if (levene) {
    group_factor <- data[[group_name]]
    dv_vals <- data[[dv_name]]
    group_means <- tapply(dv_vals, group_factor, mean, na.rm = TRUE)
    abs_devs <- abs(dv_vals - group_means[group_factor])
    levene_model <- stats::aov(abs_devs ~ group_factor)
    levene_result <- summary(levene_model)[[1]]
    levene_f <- round(levene_result$`F value`[1], 3)
    levene_p <- levene_result$`Pr(>F)`[1]
    levene_p_fmt <- if (!is.na(levene_p) && levene_p < 0.001) "<.001" else sprintf("%.3f", levene_p)

    levene_table <- data.frame(
      F_value = levene_f,
      df1 = levene_result$Df[1],
      df2 = levene_result$Df[2],
      p_value = levene_p_fmt,
      stringsAsFactors = FALSE,
      row.names = NULL
    )

    cat("\n")
    print(knitr::kable(levene_table,
                       caption = "Levene's Test for Homogeneity of Variance",
                       col.names = c("F", "df1", "df2", "p"),
                       row.names = FALSE))
    cat("\n")
  }

  # Get level names
  levels <- levels(data[[group_name]])

  # Group descriptives
  group1_data <- data[[dv_name]][data[[group_name]] == levels[1]]
  group2_data <- data[[dv_name]][data[[group_name]] == levels[2]]
  group1_data <- group1_data[!is.na(group1_data)]
  group2_data <- group2_data[!is.na(group2_data)]

  # Build group labels
  if (is_labelled) {
    group_labels <- paste0(original_codes, ": ", levels)
  } else {
    group_labels <- levels
  }

  desc_table <- data.frame(
    Group = group_labels,
    N = c(length(group1_data), length(group2_data)),
    Mean = round(c(mean(group1_data), mean(group2_data)), 3),
    SD = round(c(sd(group1_data), sd(group2_data)), 3),
    stringsAsFactors = FALSE
  )

  cat("\n")
  print(knitr::kable(desc_table,
                     caption = paste("Group Descriptives:", dv_name, "by", group_name),
                     row.names = FALSE))
  cat("\n")

  # Run t-test
  result <- t.test(formula, data = data, var.equal = !welch)

  # Format p value
  p_val <- result$p.value
  p_fmt <- if (!is.na(p_val) && p_val < 0.001) "<.001" else sprintf("%.3f", p_val)

  # Build test results table
  test_table <- data.frame(
    t = round(result$statistic, 3),
    df = round(result$parameter, 1),
    p = p_fmt,
    Mean_Difference = round(diff(rev(result$estimate)), 3),
    stringsAsFactors = FALSE,
    row.names = NULL
  )

  # Add CI columns if requested
  if (ci) {
    test_table$CI_Lower <- round(result$conf.int[1], 3)
    test_table$CI_Upper <- round(result$conf.int[2], 3)
  }

  # Set test label
  if (welch) {
    test_label <- "Welch's T-Test (equal variances not assumed)"
  } else {
    test_label <- "Independent Samples T-Test (equal variances assumed)"
  }

  if (ci) {
    print(knitr::kable(test_table,
                       caption = test_label,
                       col.names = c("t", "df", "p", "Mean Difference", "95% CI Lower", "95% CI Upper"),
                       row.names = FALSE))
  } else {
    print(knitr::kable(test_table,
                       caption = test_label,
                       col.names = c("t", "df", "p", "Mean Difference"),
                       row.names = FALSE))
  }

  # Effect size (Cohen's d)
  if (effect.size) {
    n1 <- length(group1_data)
    n2 <- length(group2_data)
    m1 <- mean(group1_data)
    m2 <- mean(group2_data)
    s1 <- sd(group1_data)
    s2 <- sd(group2_data)

    # Pooled standard deviation
    sp <- sqrt(((n1 - 1) * s1^2 + (n2 - 1) * s2^2) / (n1 + n2 - 2))
    d <- round((m1 - m2) / sp, 3)

    cat("\nCohen's d:", d, "\n")
  }

  invisible(result)
}

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
#' @param full Logical. If TRUE, turns on posthoc, effect.size, levene,
#'   and ci all at once.
#'
#' @return Invisibly returns the model object (aov or oneway.test).
#'
#' @examples
#' mtcars$cyl_f <- factor(mtcars$cyl)
#' jaov(mpg ~ cyl_f, data = mtcars)
#' jaov(mpg ~ cyl_f, data = mtcars, welch = TRUE)
#' jaov(mpg ~ cyl_f, data = mtcars, full = TRUE)
#' jaov(mpg ~ cyl_f, data = mtcars, posthoc = TRUE, effect.size = TRUE)
#'
#' @export
#' @importFrom stats aov oneway.test TukeyHSD qt
jaov <- function(formula, data, welch = FALSE, posthoc = FALSE,
                 effect.size = FALSE, levene = FALSE, ci = FALSE,
                 full = FALSE) {

  # full = TRUE turns on all optional outputs
  if (full) {
    posthoc <- TRUE
    effect.size <- TRUE
    levene <- TRUE
    ci <- TRUE
  }

  # Extract variable names from the formula
  terms <- all.vars(formula)
  dv_name <- terms[1]
  group_name <- terms[2]

  # Get the grouping variable
  group_var <- data[[group_name]]

  # Capture numeric codes before conversion (for haven-labelled variables)
  is_labelled <- haven::is.labelled(group_var)
  if (is_labelled) {
    original_codes <- sort(unique(as.numeric(group_var[!is.na(group_var)])))
  }

  # Convert to factor if needed
  if (is_labelled) {
    data[[group_name]] <- haven::as_factor(group_var)
  } else if (!is.factor(group_var)) {
    data[[group_name]] <- factor(group_var)
  }

  # Handle haven-labelled DV
  if (haven::is.labelled(data[[dv_name]])) {
    data[[dv_name]] <- as.numeric(data[[dv_name]])
  }

  # Levene's test (printed before ANOVA if requested)
  if (levene) {
    group_factor <- data[[group_name]]
    dv_vals <- data[[dv_name]]
    group_means <- tapply(dv_vals, group_factor, mean, na.rm = TRUE)
    abs_devs <- abs(dv_vals - group_means[group_factor])
    levene_model <- stats::aov(abs_devs ~ group_factor)
    levene_result <- summary(levene_model)[[1]]
    levene_f <- round(levene_result$`F value`[1], 3)
    levene_p <- levene_result$`Pr(>F)`[1]
    levene_p_fmt <- if (!is.na(levene_p) && levene_p < 0.001) "<.001" else sprintf("%.3f", levene_p)

    levene_table <- data.frame(
      F_value = levene_f,
      df1 = levene_result$Df[1],
      df2 = levene_result$Df[2],
      p_value = levene_p_fmt,
      stringsAsFactors = FALSE,
      row.names = NULL
    )

    cat("\n")
    print(knitr::kable(levene_table,
                       caption = "Levene's Test for Homogeneity of Variance",
                       col.names = c("F", "df1", "df2", "p"),
                       row.names = FALSE))
    cat("\n")
  }

  # Group descriptives
  levels <- levels(data[[group_name]])
  desc_rows <- lapply(seq_along(levels), function(i) {
    lvl <- levels[i]
    group_data <- data[[dv_name]][data[[group_name]] == lvl]
    group_data <- group_data[!is.na(group_data)]
    n <- length(group_data)
    m <- mean(group_data)
    s <- sd(group_data)

    # Show code: label for haven-labelled, just label otherwise
    if (is_labelled) {
      group_label <- paste0(original_codes[i], ": ", lvl)
    } else {
      group_label <- lvl
    }

    row <- data.frame(
      Group = group_label,
      N = n,
      Mean = round(m, 3),
      SD = round(s, 3),
      stringsAsFactors = FALSE
    )

    if (ci) {
      se <- s / sqrt(n)
      t_crit <- stats::qt(0.975, df = n - 1)
      row$CI_Lower <- round(m - t_crit * se, 3)
      row$CI_Upper <- round(m + t_crit * se, 3)
    }

    row
  })
  desc_table <- do.call(rbind, desc_rows)

  cat("\n")
  if (ci) {
    print(knitr::kable(desc_table,
                       caption = paste("Group Descriptives:", dv_name, "by", group_name),
                       col.names = c("Group", "N", "Mean", "SD", "95% CI Lower", "95% CI Upper"),
                       row.names = FALSE))
  } else {
    print(knitr::kable(desc_table,
                       caption = paste("Group Descriptives:", dv_name, "by", group_name),
                       row.names = FALSE))
  }
  cat("\n")

  if (welch) {
    # Welch's ANOVA (does not assume equal variances)
    model <- oneway.test(formula, data = data, var.equal = FALSE)

    p_val <- model$p.value
    p_fmt <- if (!is.na(p_val) && p_val < 0.001) "<.001" else sprintf("%.3f", p_val)

    welch_table <- data.frame(
      F_value = round(model$statistic, 3),
      df1 = round(model$parameter[1], 1),
      df2 = round(model$parameter[2], 1),
      p_value = p_fmt,
      stringsAsFactors = FALSE,
      row.names = NULL
    )

    print(knitr::kable(welch_table,
                       caption = paste("Welch's ANOVA:", dv_name, "by", group_name),
                       col.names = c("F", "df1", "df2", "p"),
                       row.names = FALSE))

    cat("\nNote: Sum of Squares and Mean Squares are not available for the Welch ANOVA.\nTo obtain these, run jaov() without the welch = TRUE option.\n")

    if (posthoc) {
      cat("\nNote: Tukey HSD post-hoc tests are not available with the Welch ANOVA.\nRun without welch = TRUE for post-hoc comparisons.\n")
    }

    if (effect.size) {
      # Eta-squared computed from traditional SS decomposition
      temp_model <- stats::aov(formula, data = data)
      temp_result <- summary(temp_model)[[1]]
      eta_sq <- round(temp_result$`Sum Sq`[1] / sum(temp_result$`Sum Sq`), 3)
      cat("\nEta-squared:", eta_sq, "\n")
      cat("(Note: Eta-squared is calculated from the traditional SS decomposition.)\n")
    }

  } else {
    # Traditional ANOVA (assumes equal variances)
    model <- aov(formula, data = data)
    result <- summary(model)[[1]]

    # Calculate totals
    total_df <- sum(result$Df)
    total_ss <- sum(result$`Sum Sq`)

    # Build clean output table
    p_val <- result$`Pr(>F)`[1]
    p_fmt <- if (!is.na(p_val) && p_val < 0.001) "<.001" else sprintf("%.3f", p_val)

    anova_table <- data.frame(
      Source = c(group_name, "Residual", "Total"),
      df = c(result$Df, total_df),
      Sum_of_Squares = round(c(result$`Sum Sq`, total_ss), 3),
      Mean_Square = c(round(result$`Mean Sq`, 3), NA),
      F_value = c(round(result$`F value`[1], 3), NA, NA),
      p_value = c(p_fmt, NA, NA),
      stringsAsFactors = FALSE
    )

    print(knitr::kable(anova_table,
                       caption = paste("ANOVA:", dv_name, "by", group_name),
                       col.names = c("Source", "df", "Sum of Squares", "Mean Square", "F", "p"),
                       row.names = FALSE))

    # Effect size
    if (effect.size) {
      eta_sq <- round(result$`Sum Sq`[1] / sum(result$`Sum Sq`), 3)
      cat("\nEta-squared:", eta_sq, "\n")
    }

    # Post-hoc tests
    if (posthoc) {
      tukey <- stats::TukeyHSD(model)
      tukey_result <- as.data.frame(tukey[[1]])

      tukey_p <- tukey_result$`p adj`
      tukey_p_fmt <- ifelse(!is.na(tukey_p) & tukey_p < 0.001, "<.001",
                            sprintf("%.3f", tukey_p))

      tukey_table <- data.frame(
        Comparison = rownames(tukey_result),
        Difference = round(tukey_result$diff, 3),
        CI_Lower = round(tukey_result$lwr, 3),
        CI_Upper = round(tukey_result$upr, 3),
        p_adj = tukey_p_fmt,
        stringsAsFactors = FALSE,
        row.names = NULL
      )

      cat("\n")
      print(knitr::kable(tukey_table,
                         caption = "Tukey HSD Post-Hoc Comparisons",
                         col.names = c("Comparison", "Mean Difference", "95% CI Lower", "95% CI Upper", "p (adjusted)"),
                         row.names = FALSE))
    }
  }

  invisible(model)
}


#' SPSS-like linear regression output with standardised coefficients
#'
#' Fits a linear model using \code{stats::lm()} and prints SPSS-style output,
#' including unstandardised coefficients, standard errors, t values, p values,
#' and standardised coefficients ("Std B"). Standardised coefficients are left
#' blank for the intercept and for dummy-coded factor terms.
#'
#' The function also prints key model summary information (R-squared, residual
#' standard error, F-test, sums of squares, and N). If any coefficients are
#' dropped due to perfect collinearity, a warning message is printed.
#'
#' Handles haven-labelled variables by converting them appropriately before
#' fitting the model.
#'
#' @param formula A model formula, e.g. \code{y ~ x1 + x2}.
#' @param data A data frame containing variables referenced in \code{formula}.
#'
#' @return Invisibly returns a list containing the fitted model, a coefficient
#' table (data frame), and model fit statistics.
#'
#' @examples
#' jlm(mpg ~ hp + wt, data = mtcars)
#'
#' # Factor example
#' mtcars$cyl_f <- factor(mtcars$cyl)
#' jlm(mpg ~ cyl_f + wt, data = mtcars)
#'
#' @export
jlm <- function(formula, data) {
  # Convert haven-labelled variables before fitting
  model_vars <- all.vars(formula)
  for (v in model_vars) {
    if (haven::is.labelled(data[[v]])) {
      if (v == all.vars(formula)[1]) {
        # DV: convert to numeric
        data[[v]] <- as.numeric(data[[v]])
      } else {
        # IV: convert to factor (preserves labels for grouping)
        data[[v]] <- haven::as_factor(data[[v]])
      }
    }
  }

  # Build complete-case model frame (SPSS-like listwise deletion)
  mf <- stats::model.frame(formula, data = data, na.action = stats::na.omit)

  model <- stats::lm(formula, data = mf)
  model_summary <- summary(model)

  # Coefficients table
  coefs <- as.data.frame(model_summary$coefficients, stringsAsFactors = FALSE)
  colnames(coefs)[1:4] <- c("b", "StdErr", "t", "P")

  # Standardised model: scale numeric columns in the model frame (including outcome)
  mf_std <- mf
  num_cols <- vapply(mf_std, is.numeric, logical(1))
  mf_std[, num_cols] <- lapply(mf_std[, num_cols, drop = FALSE], scale)

  std_model <- stats::lm(formula, data = mf_std)
  std_coefs <- stats::coef(std_model)

  # Start with standardised betas aligned to original coefficient names
  std_b <- rep(NA_real_, nrow(coefs))
  names(std_b) <- rownames(coefs)

  # Fill from std_model where available
  common <- intersect(names(std_coefs), names(std_b))
  std_b[common] <- std_coefs[common]

  # Blank out intercept
  if ("(Intercept)" %in% names(std_b)) std_b["(Intercept)"] <- NA_real_

  # Blank out factor (dummy) terms: detect factor variables in the model frame
  factor_terms <- names(mf)[vapply(mf, is.factor, logical(1))]
  if (length(factor_terms) > 0) {
    for (term in factor_terms) {
      # Dummy coefficient names usually begin with the factor variable name
      dummy_rows <- grep(paste0("^", term), rownames(coefs), value = TRUE)
      std_b[dummy_rows] <- NA_real_
    }
  }

  # Format p-values with <.001
  p_num <- suppressWarnings(as.numeric(coefs$P))
  p_fmt <- ifelse(!is.na(p_num) & p_num < 0.001, "<.001",
                  ifelse(is.na(p_num), "<.001", sprintf("%.3f", p_num)))

  # Format numeric columns
  fmt3 <- function(x) sprintf("%.3f", as.numeric(x))

  out_coefs <- data.frame(
    b      = fmt3(coefs$b),
    StdErr = fmt3(coefs$StdErr),
    t      = fmt3(coefs$t),
    `Std B` = ifelse(is.na(std_b), "", sprintf("%.3f", as.numeric(std_b))),
    P      = p_fmt,
    stringsAsFactors = FALSE,
    row.names = rownames(coefs)
  )

  # Model fit statistics
  r_squared <- round(model_summary$r.squared, 3)
  residual_se <- round(model_summary$sigma, 3)

  f_stat <- model_summary$fstatistic
  f_value <- round(unname(f_stat[1]), 3)
  df1 <- unname(f_stat[2])
  df2 <- unname(f_stat[3])
  f_p <- stats::pf(f_value, df1, df2, lower.tail = FALSE)
  f_p_fmt <- ifelse(is.na(f_p) | f_p < 0.001, "<.001", sprintf("%.3f", f_p))

  n_obs <- stats::nobs(model)

  y <- stats::model.response(mf)
  ss_total <- round(sum((y - mean(y))^2), 3)
  ss_regression <- round(sum((stats::fitted(model) - mean(y))^2), 3)
  ss_residual <- round(sum(stats::residuals(model)^2), 3)

  # Collinearity warning (dropped terms)
  if (any(is.na(stats::coef(model)))) {
    cat("\nWARNING: One or more variables have been removed from the model due to collinearity.\n")
  }

  # Print output
  cat("\nCoefficients:\n")
  print(out_coefs, quote = FALSE)

  cat("\nR-squared: ", sprintf("%.3f", r_squared), "\n", sep = "")
  cat("Residual Standard Error: ", sprintf("%.3f", residual_se), "\n", sep = "")
  cat("\nF-statistic: ", sprintf("%.3f", f_value),
      " on ", df1, " and ", df2,
      " DF, p-value: ", f_p_fmt, "\n", sep = "")

  cat("Sum of Squares:\n")
  cat(" Regression: ", sprintf("%.3f", ss_regression), "\n", sep = "")
  cat(" Residual: ", sprintf("%.3f", ss_residual), "\n", sep = "")
  cat(" Total: ", sprintf("%.3f", ss_total), "\n", sep = "")

  cat("\nNumber of observations: ", n_obs, "\n", sep = "")

  invisible(list(
    model = model,
    coefficients = out_coefs,
    r_squared = r_squared,
    residual_se = residual_se,
    f_statistic = c(value = f_value, df1 = df1, df2 = df2, p = f_p),
    sums_of_squares = c(regression = ss_regression, residual = ss_residual, total = ss_total),
    n = n_obs
  ))
}

#' Bivariate correlation matrix with p values and pairwise N
#'
#' Computes pairwise Pearson correlations and prints a formatted lower-triangle
#' correlation matrix showing r, p values, and pairwise N for each pair.
#' Handles haven-labelled and factor variables with numeric levels.
#'
#' @param data A data frame.
#' @param ... Unquoted variable names within `data`.
#'
#' @return Invisibly returns a list containing the correlation matrix,
#' p-value matrix, and pairwise N matrix.
#'
#' @examples
#' jcorr(mtcars, mpg, hp, wt)
#'
#' @importFrom stats cor.test complete.cases
#' @export
jcorr <- function(data, ...) {
  variables <- rlang::enquos(...)
  variable_names <- purrr::map_chr(variables, rlang::quo_name)

  # Extract and prepare data
  cor_data <- data[, variable_names, drop = FALSE]

  # Handle haven-labelled and factor variables
  for (v in variable_names) {
    if (haven::is.labelled(cor_data[[v]])) {
      cor_data[[v]] <- as.numeric(cor_data[[v]])
    } else if (is.factor(cor_data[[v]])) {
      numeric_check <- suppressWarnings(as.numeric(as.character(cor_data[[v]])))
      if (all(is.na(numeric_check[!is.na(cor_data[[v]])]))) {
        stop(paste0("'", v,
                    "' is a factor with text categories and cannot be used ",
                    "in a correlation. Use a numeric variable instead."), call. = FALSE)
      }
      cor_data[[v]] <- numeric_check
    }
  }

  n_vars <- length(variable_names)

  # Initialize matrices
  r_matrix <- matrix(NA, n_vars, n_vars,
                     dimnames = list(variable_names, variable_names))
  p_matrix <- matrix(NA, n_vars, n_vars,
                     dimnames = list(variable_names, variable_names))
  n_matrix <- matrix(NA, n_vars, n_vars,
                     dimnames = list(variable_names, variable_names))

  # Compute pairwise correlations
  for (i in seq_len(n_vars)) {
    for (j in seq_len(n_vars)) {
      complete <- stats::complete.cases(cor_data[[i]], cor_data[[j]])
      n_matrix[i, j] <- sum(complete)
      if (i == j) {
        r_matrix[i, j] <- 1
      } else if (n_matrix[i, j] > 2) {
        test <- stats::cor.test(cor_data[[i]], cor_data[[j]])
        r_matrix[i, j] <- test$estimate
        p_matrix[i, j] <- test$p.value
      }
    }
  }

  # Build display table (lower triangle only)
  display <- matrix("", n_vars, n_vars,
                    dimnames = list(variable_names, variable_names))

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

  print(knitr::kable(display_df, caption = "Bivariate Correlations"))

  invisible(list(
    r = r_matrix,
    p = p_matrix,
    n = n_matrix
  ))
}



