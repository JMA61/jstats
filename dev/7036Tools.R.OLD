

#' Computes basic descriptive statistics (N, non-missing, min, max, mean, SD)
#' for one or more variables in a data frame. Prints a formatted table and
#' invisibly returns the underlying results as a data frame.
#'
#' @param data A data frame.
#' @param ... Unquoted variable names within `data`.
#'
#' @return Invisibly returns a data frame of SPSS-like descriptive statistics. Also prints a table.
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
    if (inherits(var_data, "haven_labelled") || inherits(var_data, "labelled") || !is.null(attr(var_data, "labels"))) {
      var_data <- as.numeric(vctrs::vec_data(var_data))
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

    # Pull column as a vector (teaching-friendly)
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

    # Convert numeric variables to factors (common teaching expectation)
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
  # Build complete-case model frame first (SPSS-like listwise deletion)
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

  # Print output (SPSS-ish)
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












