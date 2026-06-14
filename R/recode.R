#<<<FILE: recode.R>>>


# =============================================================================
#  DATA MANAGEMENT — RECODING & LABELING
# =============================================================================

# -- jrelabel ----------------------------------------------------------------

#' Apply variable and value labels to a variable
#'
#' @description
#' \code{jrelabel()} attaches a variable label and/or value labels to any
#' variable in a data frame. It is designed as a simple label applicator ---
#' it does not recode values or compare variables. Use it to add labels after
#' a recode, to fix missing labels, or to label any variable that needs them.
#'
#' The function accepts haven-labelled, plain numeric, factor, and character
#' variables. The output is always a \code{haven_labelled} vector, which is
#' compatible with all jstats functions.
#'
#' Both the \code{labels} and \code{var.label} arguments are optional. If
#' neither is supplied, the function returns the variable unchanged as a
#' \code{haven_labelled} vector.
#'
#' If the variable already has labels, they are silently overwritten when
#' new labels are provided.
#'
#' @param data A data frame containing the variable.
#' @param var The variable to label (unquoted, e.g. \code{StatusR}).
#' @param labels Optional. A quoted string specifying value labels using the
#'   format \code{"code=Label Text"} with rules separated by semicolons.
#'
#'   Examples:
#'   \itemize{
#'     \item \code{"1=Yes; 0=No"}
#'     \item \code{"1=Employed; 2=Unemployed; 3=Student; 4=Retired"}
#'   }
#'
#' @param var.label Optional. A quoted string to use as the variable label
#'   (the description shown by \code{jdesc()}, \code{jfreq()}, etc.).
#'   If omitted, any existing variable label is preserved. If the variable
#'   has no existing label, no variable label is set.
#'
#' @return A \code{haven_labelled} vector with the requested labels applied.
#'   Assign this back to a column in your data frame:
#'   \code{MyData$VarName <- jrelabel(MyData, VarName, ...)}
#'
#' @examples
#' # Add value labels after a recode
#' df <- data.frame(Status = c(1, 2, 1, 2, 1, 2))
#' df$StatusR <- ifelse(df$Status == 1, 1, 0)
#' df$StatusR <- jrelabel(df, StatusR, labels = "1=Yes; 0=No",
#'                        var.label = "Status (recoded)")
#'
#' # Add just a variable label
#' df$StatusR <- jrelabel(df, StatusR, var.label = "Employment Status")
#'
#' # Add just value labels
#' df$StatusR <- jrelabel(df, StatusR, labels = "1=Yes; 0=No")
#'
#' # Using juse() default
#' juse(df)
#' df$StatusR <- jrelabel(StatusR, labels = "1=Active; 0=Inactive")
#'
#' @seealso \code{\link{jrecode}} for recoding values with optional labels
#'   in a single step.
#' @seealso \code{\link{jstats}} for the package overview,
#'   workflow conventions, and complete function listing.
#'
#' @export
jrelabel <- function(data, var, labels = NULL, var.label = NULL) {

  # --- Resolve first argument -----------------------------------------------
  arg1 <- .jst_resolve_first_arg(
    data_sub      = substitute(data),
    data_missing  = missing(data),
    fn_name       = "jrelabel",
    envir         = parent.frame(),
    accept_vector = FALSE
  )

  data <- arg1$data

  # Determine variable name. If the user typed jrelabel(VarName, labels = ...)
  # — data omitted, named labels — the helper captured VarName as first_arg_sub.
  # Otherwise var is supplied positionally.
  if (arg1$mode == "symbol_with_default") {
    if (!missing(var)) {
      displaced <- deparse(substitute(var))
      stop("jrelabel(): when the data argument is omitted, all subsequent arguments must be named. ",
           "Use jrelabel(", deparse(arg1$first_arg_sub), ", labels = ", displaced, ")",
           call. = FALSE)
    }
    var_name <- deparse(arg1$first_arg_sub)
  } else {
    var_name <- deparse(substitute(var))
  }

  # --- Input checks ---
  if (!is.data.frame(data)) {
    .jst_stop("The first argument must be a data frame.")
  }
  if (!var_name %in% names(data)) {
    frame_ref <- if (!is.null(arg1$name) && nzchar(arg1$name)) arg1$name else "the data frame"
    .jst_stop(paste0("Variable '", var_name, "' not found in ", frame_ref, "."))
  }

  x <- data[[var_name]]

  # --- Preserve any existing variable label before conversion ---
  existing_var_label <- NULL
  if (haven::is.labelled(x)) {
    existing_var_label <- labelled::var_label(x)
  }

  # --- Convert to numeric vector for haven_labelled construction ---
  if (haven::is.labelled(x)) {
    num_vals <- .jst_as_numeric(x)
  } else if (is.factor(x)) {
    num_vals <- suppressWarnings(as.numeric(as.character(x)))
    if (all(is.na(num_vals[!is.na(x)]))) {
      .jst_stop(paste0(
        "'", var_name, "' is a factor with non-numeric levels. ",
        "Convert it to numeric values before using jrelabel()."
      ))
    }
  } else if (is.character(x)) {
    num_vals <- suppressWarnings(as.numeric(x))
    if (all(is.na(num_vals[!is.na(x)]))) {
      .jst_stop(paste0(
        "'", var_name, "' contains non-numeric text values. ",
        "Convert it to numeric values before using jrelabel()."
      ))
    }
  } else {
    num_vals <- as.numeric(x)
  }

  # --- Build haven_labelled vector ---
  result <- labelled::labelled(num_vals)

  # --- Apply variable label ---
  if (!is.null(var.label)) {
    if (!is.character(var.label) || length(var.label) != 1) {
      .jst_stop("The var.label argument must be a single quoted string.")
    }
    labelled::var_label(result) <- var.label
  } else if (!is.null(existing_var_label) &&
             nchar(trimws(existing_var_label)) > 0) {
    labelled::var_label(result) <- existing_var_label
  }

  # --- Apply value labels ---
  if (!is.null(labels)) {
    if (!is.character(labels) || length(labels) != 1) {
      .jst_stop("The labels argument must be a single quoted string, e.g. \"1=Yes; 0=No\".")
    }
    parsed_labels <- tryCatch(
      .jst_parse_labels(labels),
      error = function(e) .jst_stop(paste0("Error in labels argument: ",
                                      conditionMessage(e)))
    )
    labelled::val_labels(result) <- parsed_labels
  }

  return(invisible(result))
}


# -----------------------------------------------------------------------------
# .jst_jrecode_convention_error()
#
# Builds the error message emitted by jrecode() when the user's map or
# labels argument contains Stata-style missing-value tokens but the
# resolved convention is SPSS. Constructs a dynamic echo-back of the
# user's actual map and labels with tagged-NA tokens replaced by
# equivalent numeric UDM codes drawn from
# joptions("udm.convention.codes"), plus the canonical two-call
# SPSS-style pattern (jrecode then jdeclare_udm) per Decision 10's
# worked example.
#
# joutput-level gating:
#   minimal  - three lines: what went wrong, see ?jrecode, the
#              joptions switch hint. No dynamic echo-back.
#   standard - full block with the rewritten jrecode and jdeclare_udm
#   full       lines, plus the joptions switch line at the end.
#
# Cap behavior: when tagged-NA token count exceeds the convention
# code count, the helper substitutes the mappable subset and leaves
# unmapped tokens in their original .x form. A plain-language cap
# note explaining the situation is appended between the example
# block and the switch-convention line.
# -----------------------------------------------------------------------------

#' Internal helper: build jrecode's cross-convention error message
#'
#' Produces the error message used by \code{jrecode()} when Stata-style
#' Stata-style missing-value tokens appear in the map or labels argument but the
#' resolved convention is SPSS. Verbosity is controlled by the active
#' \code{joutput()} level.
#'
#' @param parsed_map List returned by \code{.jst_parse_map()}.
#' @param parsed_labels Named numeric vector returned by
#'   \code{.jst_parse_labels()}, or \code{NULL} if no labels argument
#'   was supplied.
#' @param data_name Character. Name of the data frame in the user's
#'   call (used to reconstruct the example).
#' @param orig_name Character. Name of the variable being recoded.
#'
#' @return Character scalar suitable for passing to \code{stop()}.
#'
#' @keywords internal
.jst_jrecode_convention_error <- function(parsed_map, parsed_labels,
                                          data_name, orig_name) {

  # --- Gather every tagged-NA letter that appeared --------------------------
  map_tags <- unlist(lapply(parsed_map$mappings, function(r) r$tagged))
  if (isTRUE(parsed_map$else_action == "tagged")) {
    map_tags <- c(map_tags, parsed_map$else_tag)
  }

  label_tags_lookup <- character(0)  # letter -> label, for jdeclare_udm
  if (!is.null(parsed_labels)) {
    tags_in_labels <- haven::na_tag(parsed_labels)
    for (i in seq_along(parsed_labels)) {
      if (!is.na(tags_in_labels[i])) {
        letter <- tags_in_labels[i]
        label_tags_lookup[letter] <- names(parsed_labels)[i]
      }
    }
  }
  label_tags <- names(label_tags_lookup)

  all_tags <- sort(unique(c(map_tags, label_tags)))
  first_tag <- all_tags[1]

  # --- Verbosity gate -------------------------------------------------------
  output_level <- getOption(".jst_output_level", "standard")

  if (identical(output_level, "minimal")) {
    return(paste0(
      "the map uses '.", first_tag, "', a Stata-style missing-value ",
      "marker. The package is currently set to SPSS convention.\n",
      "See ?jrecode for examples, or run\n",
      "joptions(missing.convention = \"stata\") to switch."
    ))
  }

  # --- Standard / full block ------------------------------------------------

  letter_to_code <- .jst_tag_letters_to_codes(all_tags)
  unmapped       <- attr(letter_to_code, "unmapped")
  if (is.null(unmapped)) unmapped <- character(0)

  # Reconstruct the user's map with tagged-NA tokens replaced by their
  # equivalent SPSS-form numeric codes. Tokens that couldn't be mapped
  # (cap exceeded) are left in their original .x form.
  format_num <- function(x) {
    if (is.na(x)) return("NA")
    # Render integers without a trailing ".0".
    if (x == floor(x)) format(as.integer(x)) else format(x)
  }

  rebuilt_map_parts <- character(0)
  for (rule in parsed_map$mappings) {
    lhs <- paste(vapply(rule$old_vals, format_num, character(1)),
                 collapse = ",")
    if (!is.null(rule$tagged)) {
      code <- letter_to_code[rule$tagged]
      rhs  <- if (is.na(code)) paste0(".", rule$tagged) else format_num(code)
    } else if (is.na(rule$new_val)) {
      rhs <- "NA"
    } else {
      rhs <- format_num(rule$new_val)
    }
    rebuilt_map_parts <- c(rebuilt_map_parts, paste0(lhs, "=", rhs))
  }
  if (isTRUE(parsed_map$else_explicit)) {
    if (identical(parsed_map$else_action, "tagged")) {
      code <- letter_to_code[parsed_map$else_tag]
      else_rhs <- if (is.na(code)) {
        paste0(".", parsed_map$else_tag)
      } else format_num(code)
    } else if (identical(parsed_map$else_action, "copy")) {
      else_rhs <- "copy"
    } else {
      else_rhs <- "NA"
    }
    rebuilt_map_parts <- c(rebuilt_map_parts, paste0("else=", else_rhs))
  }
  rebuilt_map <- paste(rebuilt_map_parts, collapse = "; ")

  # Rebuild the labels argument without tagged-NA entries; those move
  # to the jdeclare_udm call per Decision 10's worked example.
  rebuilt_labels <- NULL
  if (!is.null(parsed_labels)) {
    tags_in_labels <- haven::na_tag(parsed_labels)
    non_tag_idx <- which(is.na(tags_in_labels))
    if (length(non_tag_idx) > 0L) {
      label_parts <- character(0)
      for (i in non_tag_idx) {
        label_parts <- c(label_parts,
          paste0(format_num(parsed_labels[i]), "=", names(parsed_labels)[i]))
      }
      rebuilt_labels <- paste(label_parts, collapse = "; ")
    }
  }

  # Compose the rewritten jrecode call.
  jrecode_line <- paste0("    jrecode(", data_name, ", ", orig_name,
                         ", map = \"", rebuilt_map, "\"")
  if (!is.null(rebuilt_labels)) {
    indent <- paste(rep(" ", nchar("    jrecode(")), collapse = "")
    jrecode_line <- paste0(jrecode_line, ",\n", indent,
                           "labels = \"", rebuilt_labels, "\"")
  }
  jrecode_line <- paste0(jrecode_line, ")")

  # Compose the jdeclare_udm follow-up call, covering only the mapped
  # (non-unmapped) tags so the example is syntactically valid.
  mapped_tags <- setdiff(all_tags, unmapped)
  jdeclare_line <- NULL
  if (length(mapped_tags) > 0L) {
    codes_parts <- character(0)
    for (letter in mapped_tags) {
      code  <- letter_to_code[letter]
      label <- if (letter %in% names(label_tags_lookup)) {
        label_tags_lookup[[letter]]
      } else "Missing"
      codes_parts <- c(codes_parts,
                       paste0(label, " = ", format_num(code)))
    }
    jdeclare_line <- paste0("    jdeclare_udm(", data_name, ", ",
                            orig_name, ", codes = c(",
                            paste(codes_parts, collapse = ", "), "))")
  }

  # Assemble the message.
  msg_parts <- c(
    paste0("the map uses '.", first_tag, "', a Stata-style missing-",
           "value marker. The package is currently set to SPSS"),
    "convention, which uses numeric codes. Here is the equivalent",
    "recode in SPSS style:",
    "",
    jrecode_line
  )
  if (!is.null(jdeclare_line)) {
    msg_parts <- c(msg_parts, jdeclare_line)
  }
  msg_parts <- c(msg_parts, "",
    paste0("The numeric code",
           if (length(mapped_tags) > 1L) "s" else "",
           " above came from joptions(\"udm.convention.codes\")."))

  # Cap note: appended when one or more tags exceeded the convention
  # code count. Plain-language explanation; no jargon.
  if (length(unmapped) > 0L) {
    n_tags  <- length(all_tags)
    n_codes <- length(letter_to_code)
    unmapped_render <- paste0("'.", unmapped, "'", collapse = ", ")
    were_was <- if (length(unmapped) == 1L) "was" else "were"
    msg_parts <- c(msg_parts, "",
      paste0("Note: your map uses ", n_tags, " Stata-style markers (",
             paste0(".", all_tags, collapse = ", "), ") but"),
      paste0("joptions(\"udm.convention.codes\") currently holds only ",
             n_codes, " values; ", unmapped_render, " ", were_was),
      "not substituted in the example above. To add another code, run",
      "something like joptions(udm.convention.codes = c(-99, -98, -97))."
    )
  }

  msg_parts <- c(msg_parts, "",
    "To switch to Stata convention instead, run:",
    "joptions(missing.convention = \"stata\").")

  paste(msg_parts, collapse = "\n")
}


# -----------------------------------------------------------------------------
# .jst_jdeclare_udm_convention_error()
#
# Builds the cross-convention error message for jdeclare_udm. Fires
# when the user passes Stata-style missing-value tokens in the codes vector
# but the resolved convention is SPSS. Mirrors the structure of
# .jst_jrecode_convention_error() (Session 31) with two simplifications:
# the rewrite is a single jdeclare_udm call (not two calls), and there
# is no separate labels argument to rebuild (labels live as names on
# the codes vector when present).
#
# joutput-level gating:
#   minimal  - three lines: what went wrong, see ?jdeclare_udm, the
#              joptions switch hint.
#   standard - full block with the rewritten jdeclare_udm call and
#   full       the joptions switch line.
#
# Cap behavior: when tagged-NA token count exceeds the convention
# code count, the helper substitutes the mappable subset and leaves
# unmapped tokens out of the example call. A plain-language cap note
# is appended.
# -----------------------------------------------------------------------------

#' Internal helper: build jdeclare_udm's cross-convention error message
#'
#' Produces the error message used by \code{jdeclare_udm()} when
#' Stata-style missing-value tokens appear in the \code{codes} argument but
#' the resolved convention is SPSS. Verbosity is controlled by the
#' active \code{joutput()} level.
#'
#' @param parsed_codes Named numeric vector. Names are labels (\code{""}
#'   where no label was given). Values are the user's codes including
#'   any tagged-NA elements.
#' @param data_name Character. Name of the data frame in the user's
#'   call (used to reconstruct the example).
#' @param var_name Character. Name of the variable being declared.
#'
#' @return Character scalar suitable for passing to \code{stop()}.
#'
#' @keywords internal
.jst_jdeclare_udm_convention_error <- function(parsed_codes,
                                               data_name, var_name) {

  # --- Identify tagged-NA elements ------------------------------------------
  tags_in_codes <- haven::na_tag(parsed_codes)
  tag_idx       <- which(!is.na(tags_in_codes))
  all_tags      <- sort(unique(tags_in_codes[tag_idx]))
  first_tag     <- all_tags[1]

  # --- Verbosity gate -------------------------------------------------------
  output_level <- getOption(".jst_output_level", "standard")

  if (identical(output_level, "minimal")) {
    return(paste0(
      "codes for ", var_name, " contains '.", first_tag,
      "', a Stata-style missing-value marker. ",
      "The package is currently set to SPSS convention.\n",
      "See ?jdeclare_udm for examples, or run\n",
      "joptions(missing.convention = \"stata\") to switch."
    ))
  }

  # --- Standard / full block ------------------------------------------------

  letter_to_code <- .jst_tag_letters_to_codes(all_tags)
  unmapped       <- attr(letter_to_code, "unmapped")
  if (is.null(unmapped)) unmapped <- character(0)
  mapped_tags    <- setdiff(all_tags, unmapped)

  # Rebuild the codes vector with tagged-NA elements substituted by
  # their SPSS-form numeric equivalents. Unmapped tags drop out of the
  # rebuilt call (no numeric equivalent available); the cap note below
  # explains.
  format_num <- function(x) {
    if (is.na(x)) return("NA")
    if (x == floor(x)) format(as.integer(x)) else format(x)
  }

  rebuilt_parts <- character(0)
  for (i in seq_along(parsed_codes)) {
    val <- parsed_codes[i]
    lbl <- names(parsed_codes)[i]
    if (i %in% tag_idx) {
      this_tag <- tags_in_codes[i]
      if (this_tag %in% unmapped) next   # drop unmapped tagged elements
      code <- letter_to_code[this_tag]
      val_render <- format_num(code)
    } else {
      val_render <- format_num(as.numeric(val))
    }
    if (is.null(lbl) || !nzchar(lbl)) {
      rebuilt_parts <- c(rebuilt_parts, val_render)
    } else {
      # Quote labels that need it; backtick labels containing spaces or
      # other syntax-sensitive characters to keep the rebuilt call
      # syntactically valid R.
      lbl_render <- if (grepl("^[A-Za-z.][A-Za-z0-9._]*$", lbl)) {
        lbl
      } else {
        paste0("`", lbl, "`")
      }
      rebuilt_parts <- c(rebuilt_parts,
                         paste0(lbl_render, " = ", val_render))
    }
  }

  # Compose the rewritten jdeclare_udm call.
  if (length(rebuilt_parts) > 1L) {
    codes_arg <- paste0("c(", paste(rebuilt_parts, collapse = ", "), ")")
  } else if (length(rebuilt_parts) == 1L) {
    # If the single remaining element has a name, keep the c() wrapper
    # so the name survives. Otherwise a bare scalar is fine.
    if (grepl(" = ", rebuilt_parts)) {
      codes_arg <- paste0("c(", rebuilt_parts, ")")
    } else {
      codes_arg <- rebuilt_parts
    }
  } else {
    codes_arg <- "c()"
  }

  jdeclare_line <- paste0("    jdeclare_udm(", data_name, ", ", var_name,
                          ", codes = ", codes_arg, ")")

  # Assemble the message.
  msg_parts <- c(
    paste0("codes for ", var_name, " contains '.", first_tag,
           "', a Stata-style missing-value marker. ",
           "The package is currently set to SPSS"),
    "convention, which uses numeric codes. Here is the equivalent",
    "declaration in SPSS style:",
    "",
    jdeclare_line,
    "",
    paste0("The numeric code",
           if (length(mapped_tags) > 1L) "s" else "",
           " above came from joptions(\"udm.convention.codes\").")
  )

  # Cap note: appended when one or more tags exceeded the convention
  # code count.
  if (length(unmapped) > 0L) {
    n_tags  <- length(all_tags)
    n_codes <- length(letter_to_code)
    unmapped_render <- paste0("'.", unmapped, "'", collapse = ", ")
    were_was <- if (length(unmapped) == 1L) "was" else "were"
    msg_parts <- c(msg_parts, "",
      paste0("Note: codes uses ", n_tags, " Stata-style markers (",
             paste0(".", all_tags, collapse = ", "), ") but"),
      paste0("joptions(\"udm.convention.codes\") currently holds only ",
             n_codes, " values; ", unmapped_render, " ", were_was),
      "not substituted in the example above. To add another code, run",
      "something like joptions(udm.convention.codes = c(-99, -98, -97))."
    )
  }

  msg_parts <- c(msg_parts, "",
    "To switch to Stata convention instead, run:",
    "joptions(missing.convention = \"stata\").")

  paste(msg_parts, collapse = "\n")
}


# -----------------------------------------------------------------------------
# .jst_jdeclare_udm_mixed_error()
#
# Builds the Sign-off 4 error for when the user mixes tagged-NA elements
# and plain numeric codes in a single codes vector under Stata
# convention. Standard / full tier includes a worked split-call example.
# -----------------------------------------------------------------------------

#' @keywords internal
.jst_jdeclare_udm_mixed_error <- function(parsed_codes, data_name, var_name) {

  tags_in_codes <- haven::na_tag(parsed_codes)
  tag_idx       <- which(!is.na(tags_in_codes))
  num_idx       <- setdiff(seq_along(parsed_codes), tag_idx)

  output_level <- getOption(".jst_output_level", "standard")

  if (identical(output_level, "minimal")) {
    return(paste0(
      "codes for ", var_name, " mixes Stata-style missing values and ",
      "SPSS-style numeric codes. Issue these as separate jdeclare_udm() calls."
    ))
  }

  # Build the two split-call examples.
  format_num <- function(x) {
    if (is.na(x)) return("NA")
    if (x == floor(x)) format(as.integer(x)) else format(x)
  }

  fmt_label <- function(lbl) {
    if (is.null(lbl) || !nzchar(lbl)) return(NA_character_)
    if (grepl("^[A-Za-z.][A-Za-z0-9._]*$", lbl)) lbl
    else paste0("`", lbl, "`")
  }

  # Tagged-only call
  tag_parts <- character(0)
  for (i in tag_idx) {
    lbl <- fmt_label(names(parsed_codes)[i])
    rhs <- paste0("tagged_na(\"", tags_in_codes[i], "\")")
    if (is.na(lbl)) tag_parts <- c(tag_parts, rhs)
    else            tag_parts <- c(tag_parts, paste0(lbl, " = ", rhs))
  }
  tag_arg <- if (length(tag_parts) > 1L || grepl(" = ", tag_parts[1])) {
    paste0("c(", paste(tag_parts, collapse = ", "), ")")
  } else tag_parts[1]
  tag_line <- paste0("    ", data_name, " <- jdeclare_udm(",
                     data_name, ", ", var_name, ", codes = ", tag_arg, ")")

  # Numeric-only call
  num_parts <- character(0)
  for (i in num_idx) {
    lbl <- fmt_label(names(parsed_codes)[i])
    rhs <- format_num(as.numeric(parsed_codes[i]))
    if (is.na(lbl)) num_parts <- c(num_parts, rhs)
    else            num_parts <- c(num_parts, paste0(lbl, " = ", rhs))
  }
  num_arg <- if (length(num_parts) > 1L || grepl(" = ", num_parts[1])) {
    paste0("c(", paste(num_parts, collapse = ", "), ")")
  } else num_parts[1]
  num_line <- paste0("    ", data_name, " <- jdeclare_udm(",
                     data_name, ", ", var_name, ", codes = ", num_arg, ")")

  msg_parts <- c(
    paste0("codes for ", var_name, " mixes Stata-style missing values ",
           "and SPSS-style numeric codes."),
    "The two operations are different -- labeling existing Stata-style",
    "missing-value cells (tagged input) and converting numeric cells to",
    "Stata-style missing values (numeric input) -- and must be issued as",
    "separate calls.",
    "For your input, that would be:",
    "",
    tag_line,
    num_line
  )

  paste(msg_parts, collapse = "\n")
}


# -----------------------------------------------------------------------------
# .jst_jdeclare_udm_drop_notice()
#
# Builds the Sign-off 5 drop-notice message emitted after a successful
# declaration when the prior UDM set contained codes not in the new set.
# Minimal tier: variable name and dropped codes only. Standard/full
# tier: labels for the dropped codes and the ?jdeclare_udm pointer.
# -----------------------------------------------------------------------------

#' @keywords internal
.jst_jdeclare_udm_drop_notice <- function(dropped_df, var_name,
                                          representation) {
  # dropped_df: subset of an .jst_missing_info()$codes data.frame containing
  # only the dropped rows. Has columns code, label, source, numeric, tag.

  output_level <- getOption(".jst_output_level", "standard")

  if (identical(output_level, "minimal")) {
    dropped_render <- paste(dropped_df$code, collapse = ", ")
    return(paste0("Note: jdeclare_udm replaced existing UDMs on ",
                  var_name, ". Dropped: ", dropped_render, "."))
  }

  # Standard / full tier: include labels where available.
  parts <- character(0)
  for (i in seq_len(nrow(dropped_df))) {
    code <- dropped_df$code[i]
    lbl  <- dropped_df$label[i]
    if (!is.na(lbl) && nzchar(lbl)) {
      parts <- c(parts, sprintf("%s [\"%s\"]", code, lbl))
    } else {
      parts <- c(parts, code)
    }
  }
  paste0("Note: jdeclare_udm replaced the existing UDM set for ", var_name,
         ". Previously declared codes dropped: ", paste(parts, collapse = ", "),
         ". Use `?jdeclare_udm` to review the replace-semantics behavior.")
}


# -- jrecode -----------------------------------------------------------------

#' Recode a variable with explicit value mapping and optional labels
#'
#' @description
#' \code{jrecode()} recodes a variable using a simple map string that specifies
#' how old values should be converted to new values. It is designed for
#' situations where you need to collapse categories, change numeric codes,
#' or recode dichotomies. Variable and value labels are handled automatically.
#'
#' Map and labels rules can also produce missing values: plain system NA
#' via the \code{NA} / \code{System} / \code{SYSMIS} aliases, or
#' Stata-style tagged missing values (\code{.a} through \code{.z}) when
#' the active convention is Stata. See \emph{Missing values in the map}
#' below for the canonical patterns under each convention.
#'
#' @param data     A data frame containing the original variable.
#' @param orig.var The variable to recode (unquoted, e.g. \code{AgeGroup}).
#' @param map      A quoted string specifying the recode rules, using the
#'   format \code{"old=new"} with rules separated by semicolons. Multiple old
#'   values mapping to the same new value are separated by commas on the left
#'   side.
#'
#'   An optional \code{else} clause controls what happens to values not
#'   covered by the map:
#'   \itemize{
#'     \item No else clause: the function stops with a message if any
#'       values are left unmapped, so you can fix the map before proceeding.
#'     \item \code{else=NA} (also \code{else=System} or \code{else=SYSMIS}):
#'       unmapped values are deliberately set to system NA.
#'     \item \code{else=copy}: unmapped values are carried across unchanged.
#'     \item \code{else=.a} (or any Stata-style missing-value token, Stata
#'       convention only): unmapped values are set to that Stata-style missing value.
#'   }
#'
#'   Individual values can also be mapped to system NA using the same
#'   aliases: \code{"-5=NA"}, \code{"-5=System"}, or \code{"-5=SYSMIS"}.
#'
#'   Under Stata convention, values can be mapped to Stata-style missing-value tokens:
#'   \code{"-99=.a; -98=.b"}.
#'
#'   Examples:
#'   \itemize{
#'     \item \code{"1=1; 2=0"}
#'     \item \code{"1=1; 2,3=2; 4,5=3; else=NA"}
#'     \item \code{"1=1; 2=0; else=copy"}
#'     \item \code{"-5=System; else=copy"}
#'     \item \code{"3=1; 4=2; else=.a"} (Stata convention only)
#'   }
#'
#' @param labels   Optional. A quoted string specifying value labels for the
#'   new variable, using the format \code{"code=Label Text"} with rules
#'   separated by semicolons. If supplied, these labels are used as-is.
#'
#'   The left side of each rule may be a numeric code or, under Stata
#'   convention, a Stata-style missing-value token (\code{.a} through
#'   \code{.z}). Tagged-NA labels are stored on the tag itself, not on
#'   a numeric code.
#'
#'   If omitted, the function attempts to transfer value labels automatically
#'   from the original variable. This works when the original variable has
#'   value labels and the mapping is one-to-one (no categories are collapsed).
#'   When categories are collapsed, labels cannot be transferred automatically
#'   and a note is printed.
#'
#'   Example: \code{"1=Male; 0=Female"} or \code{".a=Refused; .b=Don't know"}.
#'
#' @param convention Optional. One of \code{"spss"}, \code{"stata"}, or
#'   \code{NULL} (default). Controls whether Stata-style missing-value tokens
#'   (\code{.a} through \code{.z}) are accepted in the map and labels
#'   arguments. Inert when no Stata-style missing-value tokens appear in either argument.
#'
#'   When \code{NULL}, the convention is resolved from
#'   \code{joptions("missing.convention")}; if that is also unset, the
#'   default is SPSS. Most users set the convention once at the top of a
#'   session via \code{joptions()} (or in their \code{.Rprofile}) rather
#'   than supplying this argument on every call. See \code{?joptions} for
#'   details.
#'
#' @return A \code{haven_labelled} vector with the recoded values, variable
#'   label, and (if supplied or auto-transferred) value labels applied. Assign
#'   this to a new column in your data frame:
#'   \code{MyData$AgeGroupR <- jrecode(MyData, AgeGroup, map = "...")}
#'
#' @details
#' The function accepts haven-labelled, plain numeric, and factor variables.
#'
#' The variable label from the original variable is carried across automatically
#' with "(recoded)" appended. If the original variable has no variable label,
#' the variable name is used instead.
#'
#' Value labels are handled in three ways, in order of priority:
#' \enumerate{
#'   \item If \code{labels} is supplied, those labels are used as-is.
#'   \item If \code{labels} is omitted and the original variable has value
#'     labels, they are automatically transferred to the new codes --- provided
#'     the mapping is one-to-one (no collapsing). For example, recoding 1/2 to
#'     1/0 will carry "Yes" and "No" across to the new codes automatically.
#'   \item If categories are collapsed (multiple old values map to one new
#'     value), automatic transfer is not possible and a note is printed
#'     directing you to supply labels manually.
#' }
#'
#' NA values in the original variable are always set to NA in the new variable,
#' regardless of the \code{else} setting.
#'
#' Values that appear to be coded missing values (e.g. -99, -9, 999) from SPSS
#' or another package are automatically detected and set to NA, even when
#' \code{else=copy} is used. A note is printed when this occurs.
#'
#' If the map does not include an \code{else} clause and there are unmapped
#' values in the variable, the function stops with a message listing the
#' unmapped values so you can fix the map before proceeding.
#'
#' If the map specifies values that do not exist in the original variable, a
#' warning is issued (but the function continues). This helps catch typos in
#' the map string.
#'
#' \strong{Missing values in the map.} The package supports two conventions
#' for representing user-defined missing values (UDMs), and the syntax for
#' producing UDMs from \code{jrecode()} depends on which one is active:
#'
#' Under \strong{SPSS convention} (the default), UDMs are real numeric
#' codes carrying metadata that flags them as missing. The two-step
#' canonical pattern is:
#'
#' \preformatted{
#' df$EducR <- jrecode(df, Education,
#'                     map    = "1,2=1; 3=2; 4,5=3; -99,-98=-99",
#'                     labels = "1=High school or less; 2=Some college; 3=Degree")
#' df <- jdeclare_udm(df, EducR, codes = c(Refused = -99))
#' }
#'
#' The \code{jrecode()} call assigns the numeric sentinel \code{-99}; the
#' subsequent \code{jdeclare_udm()} call attaches the label and flags
#' \code{-99} as missing. Labeling \code{-99} inside the \code{labels}
#' argument is unnecessary --- \code{jdeclare_udm()} owns that label.
#'
#' Under \strong{Stata convention}, UDMs are typed missing cells marked
#' with Stata-style tags (\code{.a} through \code{.z}). The single-call
#' canonical pattern is:
#'
#' \preformatted{
#' df$EducR <- jrecode(df, Education,
#'                     map    = "1,2=1; 3=2; 4,5=3; else=.a",
#'                     labels = "1=High school or less; 2=Some college; 3=Degree; .a=Refused")
#' }
#'
#' Under Stata convention, \code{jdeclare_udm()} is not needed for this
#' pattern --- \code{jrecode()} handles both the value recoding and the
#' Stata-style missing-value labeling in one call.
#'
#' Writing Stata-style missing-value tokens while the active convention is SPSS raises an
#' informative error that echoes the user's call rewritten in SPSS-style
#' syntax. Switching the convention session-wide is one line:
#' \code{joptions(missing.convention = "stata")}.
#'
#' @examples
#' # Recode with explicit labels (a 1/2 dichotomy to 0/1)
#' df <- community
#' df$OwnsHome01 <- jrecode(df, OwnsHome,
#'                          map    = "1=1; 2=0",
#'                          labels = "0=No; 1=Yes")
#'
#' # Collapse categories (must supply labels)
#' df$RegionR <- jrecode(df, Region,
#'                       map    = "1,2=1; 3,4=2",
#'                       labels = "1=North or South; 2=East or West")
#'
#' # Use else=copy to carry unspecified values across unchanged
#' df$EducR <- jrecode(df, Education,
#'                     map    = "5=4; else=copy",
#'                     labels = "4=Bachelor's degree or higher")
#'
#' # Use else=NA to deliberately drop unspecified values to system NA
#' df$EducR2 <- jrecode(df, Education,
#'                      map    = "4=1; 5=1; else=NA",
#'                      labels = "1=College degree")
#'
#' # Convert a specific coded missing value to system NA
#' df$EducR3 <- jrecode(df, Education, map = "-99=System; else=copy")
#'
#' # Stata convention: Stata-style missing-value tokens in map and labels
#' # (single call; convention = "stata" scopes the choice to this call only)
#' df$EducR4 <- jrecode(df, Education,
#'                      map    = "1,2=1; 3,4,5=2; else=.a",
#'                      labels = "1=No college; 2=College; .a=Refused",
#'                      convention = "stata")
#'
#' # Using juse() default
#' juse(df)
#' df$RegionR2 <- jrecode(Region, map = "1,2=1; 3,4=2",
#'                        labels = "1=North or South; 2=East or West")
#'
#' @seealso \code{\link{jdeclare_udm}} for declaring user-defined missing
#'   values on a column after a recode (the SPSS-style canonical pattern).
#' @seealso \code{\link{jrelabel}} for applying labels to an existing variable
#'   after a recode.
#' @seealso \code{\link{joptions}} for the session-level
#'   \code{missing.convention} setting.
#' @seealso \code{\link{jstats}} for the package overview,
#'   workflow conventions, and complete function listing.
#'
#' @export
jrecode <- function(data, orig.var, map, labels = NULL, convention = NULL) {

  # --- Resolve first argument -----------------------------------------------
  arg1 <- .jst_resolve_first_arg(
    data_sub      = substitute(data),
    data_missing  = missing(data),
    fn_name       = "jrecode",
    envir         = parent.frame(),
    accept_vector = FALSE
  )

  data           <- arg1$data
  .jst_data_name <- arg1$name

  # Determine variable name. If the user typed jrecode(VarName, map = "...")
  # — data omitted, named map — the helper captured VarName as first_arg_sub.
  # Otherwise orig.var is supplied positionally.
  if (arg1$mode == "symbol_with_default") {
    if (!missing(orig.var)) {
      displaced <- deparse(substitute(orig.var))
      stop("jrecode(): when the data argument is omitted, all subsequent arguments must be named. ",
           "Use jrecode(", deparse(arg1$first_arg_sub), ", map = ", displaced, ")",
           call. = FALSE)
    }
    orig_name <- deparse(arg1$first_arg_sub)
  } else {
    orig_name <- deparse(substitute(orig.var))
  }

  # --- Input checks ---
  if (!is.data.frame(data)) {
    .jst_stop("The first argument must be a data frame.")
  }
  if (!orig_name %in% names(data)) {
    .jst_stop(paste0("Variable '", orig_name, "' not found in '", .jst_data_name, "'."))
  }
  if (missing(map) || !is.character(map) || length(map) != 1) {
    .jst_stop("The map argument must be a single quoted string, e.g. map = \"1=1; 2=0\".")
  }

  # Validate convention argument up front so an invalid value errors
  # whether or not the recode actually uses tagged-NA tokens. The
  # resolved convention is consulted only when tokens are present.
  if (!is.null(convention)) {
    if (!is.character(convention) || length(convention) != 1L ||
        !convention %in% c("spss", "stata")) {
      .jst_stop_arg(arg = "convention", choices = c("spss", "stata"))
    }
  }

  orig <- data[[orig_name]]

  # --- Detect suspicious coded missing values ---
  suspicious_vals <- .jst_detect_suspicious_values(orig, orig_name)

  # --- Parse map string ---
  parsed_map <- tryCatch(
    .jst_parse_map(map),
    error = function(e) .jst_stop(paste0("Error in map argument: ", conditionMessage(e)))
  )

  # --- Parse labels string (if supplied) ---
  # Parsed up front so the convention check below can scan both map
  # and labels for tagged-NA tokens in a single pass. The parsed
  # structure is consumed later in the value-label application step.
  parsed_labels <- NULL
  if (!is.null(labels)) {
    if (!is.character(labels) || length(labels) != 1) {
      .jst_stop("The labels argument must be a single quoted string, e.g. labels = \"1=Male; 0=Female\".")
    }
    parsed_labels <- tryCatch(
      .jst_parse_labels(labels),
      error = function(e) .jst_stop(paste0("Error in labels argument: ",
                                      conditionMessage(e)))
    )
  }

  # --- Cross-convention validation ---
  # Gather tagged-NA tokens from map and labels. If any are present,
  # resolve the active convention; under SPSS convention, raise the
  # cross-convention error with a dynamic echo-back of the user's
  # call rewritten in SPSS-style syntax. Under Stata convention the
  # tokens are accepted and flow through to the recode loop.
  map_has_tag <- any(!vapply(parsed_map$mappings,
                             function(r) is.null(r$tagged), logical(1))) ||
                 identical(parsed_map$else_action, "tagged")
  labels_has_tag <- if (!is.null(parsed_labels)) {
    any(!is.na(haven::na_tag(parsed_labels)))
  } else FALSE

  if (map_has_tag || labels_has_tag) {
    resolved_convention <- .jst_resolve_convention(convention)
    if (identical(resolved_convention, "spss")) {
      err_msg <- .jst_jrecode_convention_error(
        parsed_map    = parsed_map,
        parsed_labels = parsed_labels,
        data_name     = .jst_data_name,
        orig_name     = orig_name
      )
      .jst_stop(err_msg)
    }
    # else: Stata convention — proceed; tagged-NA tokens are valid.
  }

  # --- Apply recode ---
  # unclass() bypasses vctrs's "Can't convert <haven_labelled> to <double>"
  # cast refusal; underlying double values are preserved unchanged. See the
  # matching note in .jst_detect_suspicious_values() for full context.
  orig_num  <- as.numeric(unclass(orig))
  new_num   <- rep(NA_real_, length(orig_num))

  all_specified_old <- c()

  for (rule in parsed_map$mappings) {
    old_vals <- rule$old_vals
    all_specified_old <- c(all_specified_old, old_vals)

    # Map value(s) absent from the data: a no-op for those values, not a
    # problem -- a default-silent advisory note (full output only).
    actual_vals       <- unique(orig_num[!is.na(orig_num)])
    missing_from_data <- setdiff(old_vals, actual_vals)
    if (length(missing_from_data) > 0) {
      .jst_advisory_note(paste0(
        "Note: '", orig_name, "' contained none of the map values ",
        paste(missing_from_data, collapse = ", "),
        " - nothing was recoded for them."
      ))
    }

    rule_mask <- !is.na(orig_num) & orig_num %in% old_vals
    if (!is.null(rule$tagged)) {
      # Stata-style tagged-NA: assign haven::tagged_na(<letter>) so the
      # tag attribute is preserved on the underlying double storage.
      new_num[rule_mask] <- haven::tagged_na(rule$tagged)
    } else {
      new_num[rule_mask] <- rule$new_val
    }
  }

  # --- Handle unspecified non-NA values ---
  # Exclude values that were explicitly mapped (including mapped to NA)
  unspecified_mask <- !is.na(orig_num) & is.na(new_num) &
                      !(orig_num %in% all_specified_old)
  unspecified_vals <- sort(unique(orig_num[unspecified_mask]))

  # Separate suspicious from legitimate unspecified values
  suspicious_unspecified <- unspecified_vals[unspecified_vals %in% suspicious_vals]
  legitimate_unspecified <- unspecified_vals[!unspecified_vals %in% suspicious_vals]

  # Force suspicious values to NA regardless of else setting
  if (length(suspicious_unspecified) > 0) {
    suspicious_mask <- !is.na(orig_num) & orig_num %in% suspicious_unspecified
    new_num[suspicious_mask] <- NA_real_
  }

  # Handle legitimate unspecified values based on else setting
  if (length(legitimate_unspecified) > 0) {
    if (parsed_map$else_explicit && parsed_map$else_action == "copy") {
      # else=copy: carry legitimate values through
      legit_mask <- !is.na(orig_num) & orig_num %in% legitimate_unspecified
      new_num[legit_mask] <- orig_num[legit_mask]
    } else if (parsed_map$else_explicit && parsed_map$else_action == "na") {
      # Explicit else=NA: set to NA silently (student is being deliberate)
      # Values are already NA, nothing to do
    } else if (parsed_map$else_explicit && parsed_map$else_action == "tagged") {
      # Stata-style tagged-NA else: assign haven::tagged_na(<letter>)
      # to all legitimate unspecified cells.
      legit_mask <- !is.na(orig_num) & orig_num %in% legitimate_unspecified
      new_num[legit_mask] <- haven::tagged_na(parsed_map$else_tag)
    } else {
      # No else clause: stop so student can fix the map
      .jst_stop(paste0(
        "Value(s) ", paste(legitimate_unspecified, collapse = ", "),
        " in '", orig_name, "' were not in the map. ",
        "Map these values and re-run. ",
        "To leave unmapped values unchanged, add 'else=copy' to the map."
      ))
    }
  }

  # Print note about suspicious values that were forced to NA.
  # Partition by source so the wording matches what we actually know:
  #   - Values present in the variable's na_values metadata are UDM-
  #     confirmed and get definitive "is a user-defined missing value"
  #     wording.
  #   - Values flagged only by the heuristic get tentative "looks like
  #     a coded missing value" wording.
  # This avoids underspeaking when the user has already seen the UDM
  # noted at jload time. See Session 22 changelog ("Problem A") for the
  # design discussion.
  if (length(suspicious_unspecified) > 0) {
    udm_codes <- attr(orig, "na_values", exact = TRUE)
    if (is.null(udm_codes)) udm_codes <- numeric(0)

    udm_unspecified  <- suspicious_unspecified[suspicious_unspecified %in% udm_codes]
    heur_unspecified <- suspicious_unspecified[!suspicious_unspecified %in% udm_codes]

    .verb_phrase <- function(n, singular, plural) if (n == 1L) singular else plural

    if (length(udm_unspecified) > 0) {
      vp <- .verb_phrase(
        length(udm_unspecified),
        "is a user-defined missing value and was set to NA",
        "are user-defined missing values and were set to NA"
      )
      message(paste0(
        "Note: ", paste(udm_unspecified, collapse = ", "),
        " in '", orig_name, "' ", vp, "."
      ))
    }
    if (length(heur_unspecified) > 0) {
      vp <- .verb_phrase(
        length(heur_unspecified),
        "looks like a coded missing value and was set to NA",
        "look like coded missing values and were set to NA"
      )
      message(paste0(
        "Note: ", paste(heur_unspecified, collapse = ", "),
        " in '", orig_name, "' ", vp, "."
      ))
    }
  }

  # NAs in original are always NA in output
  new_num[is.na(orig_num)] <- NA_real_

  # --- Variable label ---
  is_haven       <- inherits(orig, "haven_labelled")
  orig_var_label <- if (is_haven) labelled::var_label(orig) else NULL

  new_var_label <- if (!is.null(orig_var_label) &&
                       nchar(trimws(orig_var_label)) > 0) {
    paste0(orig_var_label, " (recoded)")
  } else {
    paste0(orig_name, " (recoded)")
  }

  # --- Build output as haven_labelled vector ---
  result <- labelled::labelled(new_num)
  labelled::var_label(result) <- new_var_label

  # --- Value labels ---
  if (!is.null(parsed_labels)) {
    # User-supplied labels always take precedence. The labels argument
    # was validated and parsed at the top of jrecode() so the parsed
    # vector is consumed directly here.
    labelled::val_labels(result) <- parsed_labels
  } else {
    # No labels supplied — try to auto-transfer from original variable
    orig_val_labels <- if (is_haven) labelled::val_labels(orig) else NULL

    if (!is.null(orig_val_labels) && length(orig_val_labels) > 0) {
      # Detect collapsing: multiple old values mapping to the same new
      # NON-NA value. NA-targeted rules are missing-value conversion, not
      # category collapse — combining several codes into NA is what the
      # user explicitly asked for, not a side effect to flag. Without
      # this filter, the duplicate-detection branch fires on common
      # missing-conversion maps like "-99=NA; -98=NA; else=copy".
      non_na_rules <- Filter(function(r) !is.na(r$new_val),
                              parsed_map$mappings)

      is_collapsing <- any(vapply(non_na_rules,
                                  function(r) length(r$old_vals) > 1,
                                  logical(1)))
      if (!is_collapsing) {
        non_na_new_vals <- vapply(non_na_rules,
                                   function(r) r$new_val, numeric(1))
        is_collapsing <- anyDuplicated(non_na_new_vals) > 0
      }

      if (is_collapsing) {
        message("Note: Categories were collapsed. Use labels argument or jrelabel() ",
                "to assign new value labels.")
      } else {
        # One-to-one mapping — transfer labels to new codes
        old_to_new <- list()
        for (rule in parsed_map$mappings) {
          old_to_new[[as.character(rule$old_vals)]] <- rule$new_val
        }

        new_val_labels <- c()
        for (i in seq_along(orig_val_labels)) {
          old_code   <- unname(orig_val_labels[i])
          label_name <- names(orig_val_labels)[i]

          if (as.character(old_code) %in% names(old_to_new)) {
            # Explicitly mapped — use the new code, but drop the label
            # if the target is NA (no value to anchor the label to).
            entry <- old_to_new[[as.character(old_code)]]
            if (is.na(entry)) next
            names(entry)   <- label_name
            new_val_labels <- c(new_val_labels, entry)
          } else if (parsed_map$else_action == "copy") {
            # Unmapped but carried across unchanged
            entry        <- old_code
            names(entry) <- label_name
            new_val_labels <- c(new_val_labels, entry)
          }
          # else: value became NA via else_action, label is dropped
        }

        if (length(new_val_labels) > 0) {
          labelled::val_labels(result) <- new_val_labels
        }
      }
    } else {
      # The labels hint fires only when the map mints at least one
      # non-NA category there could be a label for. Pure missing-
      # conversion / value-dropping maps (every rule targets NA, e.g.
      # "-99=NA; else=copy") create nothing new to label, so the note is
      # suppressed -- mirroring the collapse-note guard's non-NA filter
      # above. The note stays for recodes that mint genuinely new
      # unlabelled categories (e.g. an unlabelled 1/2 -> 0/1).
      mints_non_na <- any(vapply(parsed_map$mappings,
                                 function(r) !is.na(r$new_val),
                                 logical(1)))
      if (mints_non_na) {
        message("Note: No value labels assigned. To add labels, use jrelabel().")
      }
    }
  }

  return(invisible(result))
}


# -- jdeclare_udm ------------------------------------------------------------

#' Declare user-defined missing values on a variable
#'
#' @description
#' \code{jdeclare_udm()} declares one or more user-defined missing
#' values (UDMs) on a variable. UDMs are specific data values --
#' typically negative codes such as \code{-99} or Stata-style tagged
#' markers such as \code{.a} -- that indicate \emph{why} a value is
#' missing (refused, don't know, not applicable, etc.) rather than
#' simply that it is missing. Once declared, UDM cells are
#' automatically excluded from analyses but remain visible in the data
#' for diagnostic purposes (see \code{jfreq()}).
#'
#' The function operates in declarative mode: each call states the
#' column's complete UDM set. A second call to \code{jdeclare_udm()} on
#' the same column replaces, not augments, the prior declaration. This
#' matches SPSS's \code{MISSING VALUES} and Stata's \code{mvdecode}
#' semantics. When prior UDMs are dropped, a note lists them so the
#' destructive aspect of the replacement is not silent.
#'
#' @param data A data frame containing the variable.
#' @param var  The variable to declare UDMs on (unquoted, e.g.
#'   \code{Income}).
#' @param codes Numeric vector of code values to declare as UDMs.
#'   Accepts two forms:
#'   \describe{
#'     \item{Option A (separate codes and labels)}{Unnamed numeric
#'       vector; labels supplied via the \code{labels} argument. E.g.
#'       \code{codes = c(-99, -98), labels = "-99=Refused; -98=Don't know"}.}
#'     \item{Option C (haven-style named vector)}{Named numeric vector;
#'       names are the labels. E.g.
#'       \code{codes = c(Refused = -99, `Don't know` = -98)}.}
#'   }
#'   Under Stata convention, code values may be Stata-style missing-value markers
#'   created with \code{haven::tagged_na()}, e.g.
#'   \code{codes = c(Refused = tagged_na("a"))}.
#' @param labels Optional. A quoted string in the form
#'   \code{"value=label; value=label"} pairing labels with codes
#'   (Option A only). Must be \code{NULL} when \code{codes} is named
#'   (Option C).
#' @param convention Optional. One of \code{"spss"} or \code{"stata"};
#'   overrides the convention resolution for this call. When
#'   \code{NULL} (the default), the convention is resolved from the
#'   column's existing UDM declaration (if any), then from
#'   \code{joptions("missing.convention")}, then from the SPSS-form
#'   default.
#' @param udm.notice Logical. When \code{TRUE} (the default), the
#'   function prints a notification summarizing what was declared.
#'   Set \code{FALSE} to suppress.
#'
#' @return The data frame, with the specified variable updated to
#'   carry the declared UDMs.
#'
#' @section Missing-Values Convention:
#' Under SPSS convention, codes are declared as numeric values via the
#' column's \code{na_values} attribute (haven's representation of
#' SPSS-form UDMs). The data cells themselves are unchanged; only the
#' metadata that flags certain values as missing is added.
#'
#' Under Stata convention with Stata-style missing-value input, the function attaches
#' value labels to existing Stata-style missing-value cells on the column.
#'
#' Under Stata convention with numeric input, the function converts
#' matching cells to Stata-style missing-value markers (Session 30 design lock). The
#' mapping is ordering-based: codes sorted by absolute value
#' descending, more-negative-first as tie-breaker, then assigned
#' \code{.a}, \code{.b}, \code{.c}, \code{.d} in that order. The
#' assignment proceeds independently of \code{joptions("udm.convention.codes")}
#' (which only governs the reverse Stata-to-SPSS direction). A
#' conversion note in the standard/full \code{joutput} tier shows the
#' Stata-style equivalent for future calls.
#'
#' @section Mixed conventions and file export:
#' A single data frame may carry both SPSS-form and Stata-form UDM
#' columns. In-memory analysis and display tolerate the mix without
#' issue (each column renders in its native form). The constraint
#' shows up at file-export time: \code{.sav} cannot
#' represent Stata-style missing values; \code{.dta} cannot represent SPSS-form
#' \code{na_values} declarations; \code{.xpt} can represent neither
#' form. \code{jsave()} pre-flights the DF
#' against the destination format and errors with a pointer to
#' \code{jconvert()} when the mix is incompatible. The
#' post-declaration mismatch notice emitted at the bottom of this
#' function's output exists to alert you early if a single-column
#' declaration ends up out of step with the rest of its DF.
#'
#' @seealso \code{\link{jrecode}}, \code{\link{jconvert}},
#'   \code{\link{joptions}}, \code{\link{jstats}}
#'
#' @examples
#' # community$JobSatisfaction arrives "dirty": -99/-98 sit in the data as
#' # ordinary numbers (the state after a CSV or Excel import), so summary
#' # statistics are poisoned until the codes are declared missing.
#' df <- community
#' jdesc(df, JobSatisfaction)        # mean dragged far down by -99/-98
#'
#' # SPSS form: declare -99 and -98 as UDMs with labels
#' df <- jdeclare_udm(df, JobSatisfaction,
#'                    codes  = c(-99, -98),
#'                    labels = "-99=Refused; -98=Don't know")
#' jdesc(df, JobSatisfaction)        # codes now excluded as missing
#'
#' # Equivalent using named codes (one step instead of codes + labels)
#' df2 <- jdeclare_udm(community, JobSatisfaction,
#'                     codes = c("Refused" = -99, "Don't know" = -98))
#'
#' # Stata-style: label Stata-style missing-value cells. The jrecode() call
#' # turns the literal codes into tagged cells; jdeclare_udm() labels them.
#' df3 <- community
#' df3$JobSat2 <- jrecode(df3, JobSatisfaction,
#'                        map = "-99=.a; -98=.b; else=copy",
#'                        convention = "stata")
#' df3 <- jdeclare_udm(df3, JobSat2,
#'                     codes = c("Refused"    = haven::tagged_na("a"),
#'                               "Don't know" = haven::tagged_na("b")))
#'
#' @export
jdeclare_udm <- function(data, var, codes, labels = NULL,
                         convention = NULL, udm.notice = TRUE) {

  # --- Resolve first argument -----------------------------------------------
  arg1 <- .jst_resolve_first_arg(
    data_sub      = substitute(data),
    data_missing  = missing(data),
    fn_name       = "jdeclare_udm",
    envir         = parent.frame(),
    accept_vector = FALSE
  )

  data      <- arg1$data
  data_name <- arg1$name

  # Determine variable name (parallel to jrecode's pattern).
  if (arg1$mode == "symbol_with_default") {
    if (!missing(var)) {
      displaced <- deparse(substitute(var))
      stop("jdeclare_udm(): when the data argument is omitted, all subsequent arguments must be named. ",
           "Use jdeclare_udm(", deparse(arg1$first_arg_sub), ", var = ", displaced, ", ...)",
           call. = FALSE)
    }
    var_name <- deparse(arg1$first_arg_sub)
  } else {
    var_name <- deparse(substitute(var))
  }

  # --- Input checks ---------------------------------------------------------
  if (!is.data.frame(data)) {
    .jst_stop("The first argument must be a data frame.")
  }
  if (!var_name %in% names(data)) {
    .jst_stop(paste0("Variable '", var_name, "' not found in '",
                data_name, "'."))
  }

  # Type guard: declaring numeric codes on a text or factor column is
  # destructive (text coerces to all-NA; a factor is silently replaced
  # by its internal integer codes), so both are refused with a fix.
  guard_col <- data[[var_name]]
  if (is.character(guard_col) ||
      (haven::is.labelled(guard_col) && typeof(guard_col) == "character")) {
    .jst_stop("'", var_name, "' is a character (text) variable; missing-value ",
         "codes can only be declared on numeric variables.\n",
         "If the values are numbers stored as text, convert with as.numeric() first.")
  }
  if (is.factor(guard_col)) {
    .jst_stop("'", var_name, "' is a factor; missing-value codes can only be ",
         "declared on numeric variables.\n",
         "If the categories are numbers, convert with as.numeric(as.character(...)) first.")
  }

  if (missing(codes) || is.null(codes)) {
    .jst_stop("`codes` is required.")
  }
  if (!is.numeric(codes) || length(codes) == 0L) {
    .jst_stop("`codes` must be one or more numbers, e.g. codes = c(-99, -98).\n",
         "(Stata-style missing values are accepted under Stata convention.)")
  }
  if (!is.logical(udm.notice) || length(udm.notice) != 1L ||
      is.na(udm.notice)) {
    .jst_stop("`udm.notice` must be TRUE or FALSE.")
  }

  # Validate convention argument up front.
  if (!is.null(convention)) {
    if (!is.character(convention) || length(convention) != 1L ||
        !convention %in% c("spss", "stata")) {
      .jst_stop_arg(arg = "convention", choices = c("spss", "stata"))
    }
  }

  # --- Argument disambiguation (Option A vs Option C) ----------------------
  codes_names <- names(codes)
  has_all_names <- !is.null(codes_names) && all(nzchar(codes_names))
  has_any_names <- !is.null(codes_names) && any(nzchar(codes_names))
  partial_names <- has_any_names && !has_all_names

  if (partial_names) {
    stop("jdeclare_udm(): `codes` is partially named. Either name every ",
         "element (Option C) or none (Option A with separate labels=).",
         call. = FALSE)
  }

  if (has_all_names && !is.null(labels)) {
    stop("jdeclare_udm(): pick one labeling form. Either name every ",
         "element of `codes` (Option C) OR supply `labels = ...` ",
         "separately (Option A), not both.",
         call. = FALSE)
  }

  # --- Parse labels (Option A path) -----------------------------------------
  parsed_labels <- NULL
  if (!is.null(labels)) {
    if (!is.character(labels) || length(labels) != 1L) {
      .jst_stop("The labels argument must be a single quoted string, e.g. ",
           "labels = \"-99=Refused; -98=Don't know\".")
    }
    parsed_labels <- tryCatch(
      .jst_parse_labels(labels),
      error = function(e) .jst_stop(paste0("Error in labels argument: ",
                                       conditionMessage(e)))
    )
  }

  # --- Build the canonical parsed_codes (named numeric, names = labels) ----
  #
  # parsed_codes is the internal canonical form: a named numeric vector
  # where names are the labels (empty string where none) and values are
  # the code values (numeric or tagged-NA). All branches below consume
  # this form.
  if (has_all_names) {
    # Option C: names are labels directly.
    parsed_codes <- codes
  } else {
    # Option A: codes is unnamed numeric; pair with labels by code value.
    if (is.null(parsed_labels)) {
      parsed_codes        <- codes
      names(parsed_codes) <- rep("", length(codes))
    } else {
      # Match each entry in parsed_labels by code value to codes.
      # parsed_labels is a named numeric vector (names = labels,
      # values = numeric or tagged_na). For each code in `codes`, look
      # up the matching parsed_labels entry.
      assigned <- rep(NA_character_, length(codes))
      pl_tags  <- haven::na_tag(parsed_labels)
      c_tags   <- haven::na_tag(codes)
      for (i in seq_along(codes)) {
        if (!is.na(c_tags[i])) {
          # tagged-NA code: match by tag letter
          idx <- which(!is.na(pl_tags) & pl_tags == c_tags[i])
        } else {
          # numeric code: match by numeric value (ignore tagged entries)
          idx <- which(is.na(pl_tags) & !is.na(parsed_labels) &
                       parsed_labels == codes[i])
        }
        if (length(idx) > 0L) {
          assigned[i] <- names(parsed_labels)[idx[1]]
        }
      }
      # Warn about any labels that didn't match any code.
      pl_unused_idx <- setdiff(seq_along(parsed_labels),
                               unique(unlist(lapply(seq_along(codes),
                                 function(i) {
                                   if (!is.na(c_tags[i])) {
                                     which(!is.na(pl_tags) & pl_tags == c_tags[i])
                                   } else {
                                     which(is.na(pl_tags) & !is.na(parsed_labels) &
                                           parsed_labels == codes[i])
                                   }
                                 }))))
      if (length(pl_unused_idx) > 0L) {
        unused_render <- paste(
          vapply(pl_unused_idx,
                 function(i) {
                   v <- parsed_labels[i]
                   if (!is.na(pl_tags[i])) sprintf(".%s=%s",
                                                  pl_tags[i],
                                                  names(parsed_labels)[i])
                   else sprintf("%s=%s",
                                format(as.numeric(v)),
                                names(parsed_labels)[i])
                 }, character(1)),
          collapse = "; ")
        stop("jdeclare_udm(): labels argument contains entries that ",
             "do not match any value in `codes`: ", unused_render, ".",
             call. = FALSE)
      }

      parsed_codes <- codes
      assigned[is.na(assigned)] <- ""
      names(parsed_codes) <- assigned
    }
  }

  # --- Detect tagged-NA elements -------------------------------------------
  c_tags         <- haven::na_tag(parsed_codes)
  tag_idx        <- which(!is.na(c_tags))
  num_idx        <- setdiff(seq_along(parsed_codes), tag_idx)
  has_tagged     <- length(tag_idx) > 0L
  has_numeric    <- length(num_idx) > 0L

  # --- Sign-off 4: reject mixed tagged + numeric ---------------------------
  if (has_tagged && has_numeric) {
    .jst_stop(.jst_jdeclare_udm_mixed_error(parsed_codes, data_name, var_name))
  }

  # --- Read existing UDM info on the column --------------------------------
  col          <- data[[var_name]]
  existing_info <- .jst_missing_info(col)
  existing_conv <- if (!is.null(existing_info)) existing_info$representation
                   else NULL

  # --- Sign-off 2: per-call convention vs existing column UDM conflict -----
  if (!is.null(convention) && !is.null(existing_conv) &&
      existing_conv != convention) {
    other_form <- if (existing_conv == "spss") "SPSS-style" else "Stata-style"
    .jst_stop("Column '", var_name, "' already carries ", other_form,
         " UDMs; cannot use convention = \"", convention,
         "\" here. Use jconvert() to convert the column first, or ",
         "omit the convention argument.")
  }

  # --- Resolve convention ---------------------------------------------------
  resolved_convention <- .jst_resolve_convention(
    per_call          = convention,
    column_convention = existing_conv
  )

  # --- Sign-off 3 / Branch D2: SPSS convention + tagged-NA input -----------
  if (resolved_convention == "spss" && has_tagged) {
    err_msg <- .jst_jdeclare_udm_convention_error(
      parsed_codes = parsed_codes,
      data_name    = data_name,
      var_name     = var_name
    )
    .jst_stop(err_msg)
  }

  # ==========================================================================
  #  Branch dispatch
  # ==========================================================================

  if (resolved_convention == "spss") {
    # ---------- Branch D1: SPSS canonical (numeric codes) ------------------
    new_col <- .jst_jdeclare_udm_spss(col, parsed_codes)
    branch  <- "spss_canonical"

  } else if (has_tagged) {
    # ---------- Branch D3: Stata canonical (tagged-NA labeling) -----------
    new_col <- .jst_jdeclare_udm_stata_label(col, parsed_codes)
    branch  <- "stata_canonical"

  } else {
    # ---------- Branch D4: Stata conversion (numeric -> tagged-NA) ---------
    conv_result <- .jst_jdeclare_udm_stata_convert(col, parsed_codes,
                                                   var_name)
    new_col <- conv_result$new_col
    branch  <- "stata_conversion"
    # Conversion-specific info for the notification.
    conversion_info <- conv_result
  }

  data[[var_name]] <- new_col

  # --- Sign-off 5: drop notice ---------------------------------------------
  drop_notice_msg <- NULL
  if (!is.null(existing_info)) {
    # Determine which existing codes are not in the new set. For SPSS-form
    # this is numeric values; for Stata-form this is tag letters.
    if (existing_info$representation == "spss") {
      old_codes <- as.numeric(existing_info$codes$numeric)
      new_codes <- if (branch == "spss_canonical") {
        as.numeric(parsed_codes)
      } else {
        # branch ended up Stata; everything SPSS-side is dropped
        old_codes
      }
      dropped_mask <- !old_codes %in% new_codes
    } else {
      # existing is Stata-form
      old_tags <- existing_info$codes$tag
      new_tags <- if (branch == "stata_canonical") {
        as.character(haven::na_tag(parsed_codes))
      } else if (branch == "stata_conversion") {
        conversion_info$tag_letters
      } else {
        # branch ended up SPSS; everything Stata-side is dropped
        old_tags
      }
      dropped_mask <- !old_tags %in% new_tags
    }
    if (any(dropped_mask)) {
      drop_notice_msg <- .jst_jdeclare_udm_drop_notice(
        dropped_df     = existing_info$codes[dropped_mask, , drop = FALSE],
        var_name       = var_name,
        representation = existing_info$representation
      )
    }
  }

  # --- Build and emit notification -----------------------------------------
  if (isTRUE(udm.notice)) {
    notif <- .jst_jdeclare_udm_notification(
      data_name           = data_name,
      var_name            = var_name,
      parsed_codes        = parsed_codes,
      branch              = branch,
      conversion_info     = if (branch == "stata_conversion") conversion_info
                            else NULL
    )
    cat(notif, sep = "")
  }

  # Drop notice fires after the main notification (consistent with the
  # established pattern of placing follow-on notes after the primary
  # output block).
  if (!is.null(drop_notice_msg) && isTRUE(udm.notice)) {
    cat(drop_notice_msg, "\n", sep = "")
  }

  # --- Post-declaration mismatch notice (Decision 11 closing rule) ---------
  if (isTRUE(udm.notice)) {
    df_predominant <- .jst_predominant_convention(data)
    if (!is.na(df_predominant) && df_predominant != resolved_convention) {
      this_form  <- if (resolved_convention == "spss") "SPSS-style" else "Stata-style"
      other_form <- if (df_predominant       == "spss") "SPSS-style" else "Stata-style"
      cat(sprintf(
        "Note: variable %s is %s, but other columns in %s are predominantly %s. Use jconvert() to align if desired.\n",
        var_name, this_form, data_name, other_form))
    }
  }

  invisible(data)
}


# -----------------------------------------------------------------------------
# Branch D1: SPSS canonical
# -----------------------------------------------------------------------------

#' @keywords internal
.jst_jdeclare_udm_spss <- function(col, parsed_codes) {
  # parsed_codes: named numeric vector (names = labels or "", values =
  # numeric codes). Tagged-NA elements have been ruled out upstream.

  code_vals <- as.numeric(unname(parsed_codes))

  # Validate codes: finite, whole, no duplicates.
  if (any(!is.finite(code_vals))) {
    stop("jdeclare_udm(): codes must be finite numeric values.",
         call. = FALSE)
  }
  if (any(code_vals != floor(code_vals))) {
    stop("jdeclare_udm(): codes must be whole numbers.",
         call. = FALSE)
  }
  if (anyDuplicated(code_vals) > 0L) {
    stop("jdeclare_udm(): codes contains duplicate values.",
         call. = FALSE)
  }

  # Build the new value-labels set. Merge any existing labels with the
  # newly supplied ones (new labels win for the codes being declared).
  existing_labs <- if (haven::is.labelled(col)) labelled::val_labels(col)
                   else NULL

  # Strip existing labels only for codes that are being given a NEW
  # label in this call (the new label replaces the old one below). A
  # code declared bare keeps whatever label it already carries --
  # declaring a value as missing does not touch its label (SPSS
  # parallel: MISSING VALUES never alters VALUE LABELS). Labels on
  # non-declared codes (real-data labels) are always preserved.
  label_names <- names(parsed_codes)
  if (is.null(label_names)) label_names <- rep("", length(parsed_codes))
  relabelled <- as.numeric(parsed_codes[nzchar(label_names)])
  if (!is.null(existing_labs) && length(existing_labs) > 0L &&
      length(relabelled) > 0L) {
    keep_mask <- !(unname(existing_labs) %in% relabelled)
    existing_labs <- existing_labs[keep_mask]
  }

  # Build new labels for codes that have a label.
  new_labs <- numeric(0)
  for (i in seq_along(parsed_codes)) {
    if (nzchar(label_names[i])) {
      entry <- as.numeric(parsed_codes[i])
      names(entry) <- label_names[i]
      new_labs <- c(new_labs, entry)
    }
  }

  combined_labs <- c(existing_labs, new_labs)
  if (length(combined_labs) == 0L) combined_labs <- NULL

  # Use labelled_spss to attach na_values together with labels and
  # variable label.
  haven::labelled_spss(
    x         = as.numeric(unclass(col)),
    labels    = combined_labs,
    na_values = code_vals,
    label     = attr(col, "label", exact = TRUE)
  )
}


# -----------------------------------------------------------------------------
# Branch D3: Stata canonical (label existing tagged-NA cells)
# -----------------------------------------------------------------------------

#' @keywords internal
.jst_jdeclare_udm_stata_label <- function(col, parsed_codes) {
  # parsed_codes: named numeric vector where every value is a tagged-NA
  # (NA_real_ with a tag attribute).

  tags <- haven::na_tag(parsed_codes)
  if (anyDuplicated(tags) > 0L) {
    stop("jdeclare_udm(): codes contains duplicate Stata-style missing-value letters.",
         call. = FALSE)
  }

  existing_labs <- if (haven::is.labelled(col)) labelled::val_labels(col)
                   else NULL

  # Strip existing tagged-NA labels only for tags that are being given a
  # NEW label in this call; a tag declared bare keeps its existing
  # label (parallel to the SPSS branch's bare-codes preservation).
  # Plain-numeric labels are preserved.
  label_names <- names(parsed_codes)
  if (is.null(label_names)) label_names <- rep("", length(parsed_codes))
  relabelled_tags <- tags[nzchar(label_names)]
  if (!is.null(existing_labs) && length(existing_labs) > 0L &&
      length(relabelled_tags) > 0L) {
    existing_tags <- haven::na_tag(existing_labs)
    keep_mask <- is.na(existing_tags) | !(existing_tags %in% relabelled_tags)
    existing_labs <- existing_labs[keep_mask]
  }

  # Build new tagged-NA labels.
  new_labs <- numeric(0)
  for (i in seq_along(parsed_codes)) {
    if (nzchar(label_names[i])) {
      entry <- haven::tagged_na(tags[i])
      names(entry) <- label_names[i]
      new_labs <- c(new_labs, entry)
    }
  }

  combined_labs <- c(existing_labs, new_labs)
  if (length(combined_labs) == 0L) combined_labs <- NULL

  # Plain labelled (not labelled_spss); strip na_values if it leaked in.
  out <- haven::labelled(
    x      = as.numeric(unclass(col)),
    labels = combined_labs,
    label  = attr(col, "label", exact = TRUE)
  )
  out
}


# -----------------------------------------------------------------------------
# Branch D4: Stata conversion (numeric codes -> tagged-NA cells)
# -----------------------------------------------------------------------------

#' @keywords internal
.jst_jdeclare_udm_stata_convert <- function(col, parsed_codes, var_name) {
  # parsed_codes: named numeric vector (names = labels or "", values =
  # plain numeric codes). Tagged-NA elements ruled out upstream.

  code_vals <- as.numeric(unname(parsed_codes))

  # Validate codes.
  if (any(!is.finite(code_vals))) {
    stop("jdeclare_udm(): codes must be finite numeric values.",
         call. = FALSE)
  }
  if (any(code_vals != floor(code_vals))) {
    stop("jdeclare_udm(): codes must be whole numbers.",
         call. = FALSE)
  }
  if (anyDuplicated(code_vals) > 0L) {
    stop("jdeclare_udm(): codes contains duplicate values.",
         call. = FALSE)
  }
  if (length(code_vals) > 4L) {
    stop("jdeclare_udm(): under Stata convention with numeric codes, at ",
         "most 4 codes can be converted (mapped to .a, .b, .c, .d). Use ",
         "jrecode() with explicit .a-.z mappings for more.",
         call. = FALSE)
  }

  # Ordering-based mapping per Session 30 Branch D4 (Q6): codes sorted by
  # |code| descending, more-negative-first as tie-breaker. Then .a, .b,
  # .c, .d in that order.
  ordering           <- order(-abs(code_vals), code_vals)
  sorted_codes       <- code_vals[ordering]
  sorted_labels      <- names(parsed_codes)[ordering]
  tag_letters        <- letters[seq_along(sorted_codes)]

  x_num <- suppressWarnings(as.numeric(unclass(col)))
  new_col <- as.numeric(x_num)
  for (i in seq_along(sorted_codes)) {
    pos <- which(!is.na(x_num) & x_num == sorted_codes[i])
    new_col[pos] <- haven::tagged_na(tag_letters[i])
  }

  # Build val_labels with tagged_na as the value, label as the name.
  existing_labs <- if (haven::is.labelled(col)) labelled::val_labels(col)
                   else NULL

  # Carry an existing label across the conversion when the call supplies
  # no new label for that code: the numeric code's cells become
  # tagged-NA cells, and the label moves with them (parallel to the
  # SPSS branch's bare-codes preservation). A new label in the call
  # still wins.
  if (!is.null(existing_labs) && length(existing_labs) > 0L) {
    for (i in seq_along(sorted_codes)) {
      if (!nzchar(sorted_labels[i])) {
        hit <- which(unname(existing_labs) == sorted_codes[i])
        if (length(hit) > 0L) sorted_labels[i] <- names(existing_labs)[hit[1]]
      }
    }
  }

  # Strip any existing labels pointing at the codes being converted
  # (they're now tagged-NA values, not the numeric codes any more).
  if (!is.null(existing_labs) && length(existing_labs) > 0L) {
    keep_mask <- !(unname(existing_labs) %in% sorted_codes)
    existing_labs <- existing_labs[keep_mask]
  }

  new_labs <- numeric(0)
  for (i in seq_along(sorted_codes)) {
    if (nzchar(sorted_labels[i])) {
      entry <- haven::tagged_na(tag_letters[i])
      names(entry) <- sorted_labels[i]
      new_labs <- c(new_labs, entry)
    }
  }

  combined_labs <- c(existing_labs, new_labs)
  if (length(combined_labs) == 0L) combined_labs <- NULL

  out <- haven::labelled(
    x      = new_col,
    labels = combined_labs,
    label  = attr(col, "label", exact = TRUE)
  )

  list(
    new_col       = out,
    sorted_codes  = sorted_codes,
    sorted_labels = sorted_labels,
    tag_letters   = tag_letters
  )
}


# -----------------------------------------------------------------------------
# Notification builder
# -----------------------------------------------------------------------------

#' @keywords internal
.jst_jdeclare_udm_notification <- function(data_name, var_name,
                                           parsed_codes, branch,
                                           conversion_info = NULL) {

  output_level <- getOption(".jst_output_level", "standard")

  header <- switch(
    branch,
    spss_canonical    = paste0("Declared SPSS-style missing values in:"),
    stata_canonical   = paste0("Labelled Stata-style missing values in:"),
    stata_conversion  = paste0("Declared and converted to Stata-style missing values in:")
  )

  # Build body lines: code [label] format per jfreq's v0.9.5 Missing-section
  # display.
  body_lines <- character(0)
  if (branch == "stata_conversion") {
    # Lines reflect post-conversion state (tag letters, not source codes).
    for (i in seq_along(conversion_info$sorted_codes)) {
      tag <- conversion_info$tag_letters[i]
      lbl <- conversion_info$sorted_labels[i]
      if (nzchar(lbl)) {
        body_lines <- c(body_lines,
                        sprintf("  .%s [\"%s\"]  (from %s)",
                                tag, lbl,
                                format(conversion_info$sorted_codes[i])))
      } else {
        body_lines <- c(body_lines,
                        sprintf("  .%s  (from %s)",
                                tag,
                                format(conversion_info$sorted_codes[i])))
      }
    }
  } else if (branch == "stata_canonical") {
    c_tags <- haven::na_tag(parsed_codes)
    for (i in seq_along(parsed_codes)) {
      lbl <- names(parsed_codes)[i]
      if (nzchar(lbl)) {
        body_lines <- c(body_lines,
                        sprintf("  .%s [\"%s\"]", c_tags[i], lbl))
      } else {
        body_lines <- c(body_lines, sprintf("  .%s", c_tags[i]))
      }
    }
  } else {
    # SPSS canonical
    for (i in seq_along(parsed_codes)) {
      v   <- format(as.numeric(parsed_codes[i]))
      lbl <- names(parsed_codes)[i]
      if (nzchar(lbl)) {
        body_lines <- c(body_lines,
                        sprintf("  %s [\"%s\"]", v, lbl))
      } else {
        body_lines <- c(body_lines, sprintf("  %s", v))
      }
    }
  }

  msg <- paste0(
    header, "\n",
    "  ", data_name, "$", var_name, "\n",
    paste(body_lines, collapse = "\n"), "\n"
  )

  # Standard / full tier: assignment-syntax reminder.
  if (!identical(output_level, "minimal")) {
    reminder <- paste0(
      "Note: jdeclare_udm() returns the modified data frame; remember the assignment: ",
      data_name, " <- jdeclare_udm(", data_name, ", ", var_name, ", ...).\n"
    )
    msg <- paste0(msg, reminder)
  }

  # Full tier: conversion equivalent for Stata-conversion branch.
  if (identical(output_level, "full") && branch == "stata_conversion") {
    tag_parts <- character(0)
    for (i in seq_along(conversion_info$sorted_codes)) {
      tag <- conversion_info$tag_letters[i]
      lbl <- conversion_info$sorted_labels[i]
      rhs <- paste0("tagged_na(\"", tag, "\")")
      if (nzchar(lbl)) {
        lbl_render <- if (grepl("^[A-Za-z.][A-Za-z0-9._]*$", lbl)) lbl
                      else paste0("`", lbl, "`")
        tag_parts <- c(tag_parts, paste0(lbl_render, " = ", rhs))
      } else {
        tag_parts <- c(tag_parts, rhs)
      }
    }
    eq_call <- paste0(
      "Equivalent Stata-style call for future use:\n",
      "    ", data_name, " <- jdeclare_udm(", data_name, ", ", var_name,
      ", codes = c(", paste(tag_parts, collapse = ", "), "))\n"
    )
    msg <- paste0(msg, eq_call)
  }

  msg
}

# =============================================================================
#  DATA I/O
# =============================================================================

# -- jconvert -----------------------------------------------------------------

#' Convert user-defined missing value (UDM) declarations between formats
#'
#' \code{jconvert()} provides a single entry point for changing how user-
#' defined missing values (UDMs) are represented on the columns of a data
#' frame already in memory. Three target formats are supported: SPSS-style
#' (\code{na_values} on \code{haven_labelled_spss}), Stata-style
#' (\code{tagged_na} on \code{haven_labelled}), and base R (declarations
#' stripped, declared cells converted to plain \code{NA}). Replaces
#' \code{jstrip_udm()} (retired in v0.9.5); the base R target is the strip
#' behavior.
#'
#' @param data A data frame, or omitted to use the \code{juse()} default.
#' @param to One of \code{"baseR"}, \code{"spss"}, or \code{"stata"}
#'   (case-sensitive). When \code{NULL} (the default), \code{jconvert()}
#'   reads \code{joptions("missing.convention")}: if the slot is set to
#'   \code{"spss"} or \code{"stata"}, \code{to} resolves to that value; if
#'   the slot is at its \code{"none"} default, \code{jconvert()} errors
#'   with guidance naming the three concrete options. The destructive
#'   \code{"baseR"} target is never auto-resolved -- it must always be
#'   passed explicitly.
#' @param ... Optional unquoted variable names. When supplied, only the
#'   listed variables are scanned. Mutually exclusive with \code{vars}.
#' @param vars Alternative scope-by-vector path: a character vector of
#'   variable names. Mutually exclusive with \code{...}. When both
#'   \code{...} and \code{vars} are empty, \code{jconvert()} operates on
#'   the whole data frame.
#' @param udm.notice Logical; \code{TRUE} (default) prints a notification
#'   summarizing what was converted (and what was skipped) along with an
#'   assignment-syntax reminder. \code{FALSE} suppresses the message.
#'   Always-on by default; does not consult \code{joutput()} because the
#'   function reports an action it just performed rather than explaining
#'   system behavior.
#'
#' @return The data frame with the requested conversions applied, returned
#'   invisibly. As with \code{jrelabel()} and \code{jrecode()}, the user
#'   must assign the return value back to retain the changes.
#'
#' @details
#' The three target formats:
#' \describe{
#'   \item{\code{to = "baseR"}}{Strip all UDM declarations and convert
#'     declared cells to plain \code{NA}. For SPSS-form columns
#'     (\code{na_values} / \code{na_range} on
#'     \code{haven_labelled_spss}), masks declared codes to \code{NA} and
#'     removes the attributes; value labels are preserved so the column
#'     can still round-trip through \code{jsave()} with original
#'     labeling. For columns carrying Stata-style missing values
#'     (\code{tagged_na} markers), uses \code{haven::zap_missing()} to
#'     convert them to plain \code{NA}s.}
#'   \item{\code{to = "spss"}}{Convert Stata-style or SAS-style missing
#'     values to SPSS-form numeric codes. Letter tags map to numeric
#'     codes via \code{joptions("udm.convention.codes")} (default
#'     \code{-99}, \code{-98}, \code{-97}, \code{-96}):
#'     \code{.a -> codes[1]}, \code{.b -> codes[2]}, and so on. SAS-style
#'     (uppercase) tags are case-corrected to Stata-style (lowercase)
#'     before the numeric mapping -- for round-trip purposes the package
#'     treats \code{.A} and \code{.a} as the same conceptual marker, and
#'     mixed-case columns collapse to a single lowercase marker (SPSS has
#'     no parallel uppercase convention). The notification's per-column
#'     display shows the original (pre-correction) tag for SAS-corrected
#'     columns -- e.g. \code{.A "Refused" -> -99} -- so the user-visible
#'     mapping reflects what was actually in the data on input. Letter
#'     tags beyond \code{.d} (after case correction) are refused with
#'     guidance to use \code{jrecode()} for manual mapping.}
#'   \item{\code{to = "stata"}}{Convert SPSS-form numeric codes to
#'     Stata-style missing values. Letter tags are assigned by ordering
#'     rather than by convention: each column's own declared
#'     \code{na_values} codes are sorted by absolute value descending
#'     (ties broken with more-negative-first), then mapped
#'     \code{.a, .b, .c, .d} in that order. Convention codes are NOT
#'     consulted for this direction;
#'     they only govern the reverse (Stata to SPSS) mapping. Round-trip
#'     conversions are not guaranteed to preserve the original numeric
#'     codes (e.g. SPSS \code{c(-1, 9)} -> Stata \code{.a, .b} -> SPSS
#'     \code{c(-99, -98)} loses the original numbers), but the value
#'     labels survive intact and the missingness semantics are preserved.
#'     Range-based SPSS missings (\code{na_range}) are out of cross-format
#'     scope; columns with \code{na_range} are refused with guidance to
#'     enumerate the range in SPSS first. Columns with more than 4
#'     distinct \code{na_values} codes are also refused (matches the
#'     4-code cap on Stata letter-tag mapping).}
#' }
#'
#' Pre-flight checks for \code{to = "spss"} include a collision check:
#' if a column's target numeric code (e.g. \code{-99} for \code{.a}) is
#' present as genuine data in the column, the call errors before any
#' data is touched. The error message lists every colliding column and
#' presents three resolution paths: change the convention codes via
#' \code{joptions(udm.convention.codes = ...)}, scope the call via
#' \code{vars = c(...)} to exclude affected columns, or recode the real-
#' data values via \code{jrecode()} first. Atomicity applies to every
#' error mode -- the entire \code{jconvert()} call either succeeds or
#' errors before mutating the data frame.
#'
#' \strong{Pattern A -- value labels suggest missingness but no formal
#' declaration.} When a column has no formal UDM declaration but carries
#' value labels matching the package's missing-label wordlist (e.g.
#' \code{"Refused"}, \code{"Don't know"}, \code{"Not applicable"}),
#' \code{jconvert()} skips the column and surfaces it in the
#' notification with the affected value/label pairs. To formalise these
#' as UDMs use \code{jdeclare_udm()}; to leave them as ordinary data, no
#' action is needed.
#'
#' @examples
#' # community ships with SPSS-form UDMs (Income, Education, Smoker,
#' # Environment1, Environment3), so the conversions run on it directly.
#'
#' # Strip UDMs from every applicable variable:
#' df <- jconvert(community, to = "baseR")
#'
#' # Convert SPSS-form UDMs to Stata-style missing values:
#' df <- jconvert(community, to = "stata")
#'
#' # Scope by unquoted names:
#' df <- jconvert(community, to = "baseR", Income, Education)
#'
#' # Scope by character vector (alternative form):
#' df <- jconvert(community, to = "baseR", vars = c("Income", "Education"))
#'
#' # Suppress the notification (e.g. inside a script):
#' df <- jconvert(community, to = "baseR", udm.notice = FALSE)
#'
#' \dontrun{
#' # Convert with target inferred from joptions:
#' joptions(missing.convention = "spss")
#' df <- jconvert(df)   # converts any Stata-form columns to SPSS
#' }
#'
#' @seealso \code{\link{jload}} for the load-time strip alternative
#'   (\code{preserve.udm = FALSE}); \code{\link{joptions}} for setting
#'   the default convention and convention codes session-wide.
#'
#' @export
jconvert <- function(data, to = NULL, ..., vars = NULL, udm.notice = TRUE) {

  # --- Resolve first argument -------------------------------------------------
  arg1 <- .jst_resolve_first_arg(
    data_sub      = substitute(data),
    data_missing  = missing(data),
    fn_name       = "jconvert",
    envir         = parent.frame(),
    accept_vector = FALSE
  )

  data      <- arg1$data
  data_name <- arg1$name

  # --- Resolve `to` -----------------------------------------------------------
  # Auto-resolve from joptions when to= is NULL. spss/stata flow through;
  # "none" errors with guidance (Q5 of the Session 28 jconvert design lock).
  # baseR never auto-resolves — destructive transformations require
  # explicit intent.
  if (is.null(to)) {
    convention <- getOption(".jst_options_missing_convention",
                            .jst_options_defaults$missing.convention)
    if (convention %in% c("spss", "stata")) {
      to <- convention
    } else {
      .jst_stop(
        "A target format is required. Set to = \"baseR\", \"spss\", or \"stata\"."
      )
    }
  }
  if (!is.character(to) || length(to) != 1L ||
      !to %in% c("baseR", "spss", "stata")) {
    .jst_stop("`to` must be \"baseR\", \"spss\", or \"stata\" (case-sensitive).")
  }

  # --- Resolve variable list (... vs vars; mutually exclusive) ---------------
  variables <- rlang::enquos(...)

  # Leading-comma-omitted form: if first arg was captured as a bare symbol
  # alongside an active juse() default, prepend it to the variables list.
  if (arg1$mode == "symbol_with_default") {
    extra_quo <- rlang::new_quosure(arg1$first_arg_sub, env = parent.frame())
    variables <- c(list(extra_quo), variables)
    class(variables) <- "quosures"
  }

  dot_names <- if (length(variables) > 0) {
    vapply(variables, rlang::quo_name, character(1))
  } else {
    character(0)
  }

  if (length(dot_names) > 0 && !is.null(vars)) {
    .jst_stop("Use either unquoted variable names (...) or quoted names ",
         "via vars = c(...), but not both.")
  }
  if (!is.null(vars) && (!is.character(vars) || length(vars) == 0L)) {
    .jst_stop("`vars` must be one or more variable names in quotes, ",
         "e.g. vars = c(\"Age\", \"Income\").")
  }

  if (length(dot_names) > 0) {
    .jst_check_vars(data, dot_names, data_name)
    target_vars    <- dot_names
    user_specified <- TRUE
    var_scope      <- "dots"
  } else if (!is.null(vars)) {
    .jst_check_vars(data, vars, data_name)
    target_vars    <- vars
    user_specified <- TRUE
    var_scope      <- "vars"
  } else {
    target_vars    <- names(data)
    user_specified <- FALSE
    var_scope      <- "all"
  }

  # --- Classify each target column -------------------------------------------
  info_list       <- list()
  pattern_a       <- list()
  skipped_no_udms <- character(0)

  for (vname in target_vars) {
    col  <- data[[vname]]
    info <- .jst_missing_info(col)

    if (!is.null(info)) {
      info_list[[vname]] <- info
      next
    }

    # Pattern A scan: no formal declaration. Look for value labels matching
    # the missing-label wordlist (.jst_label_suggests_missing).
    pa_entries <- list()
    if (haven::is.labelled(col)) {
      val_labs <- labelled::val_labels(col)
      if (!is.null(val_labs) && length(val_labs) > 0L) {
        for (i in seq_along(val_labs)) {
          lbl <- names(val_labs)[i]
          if (.jst_label_suggests_missing(lbl)) {
            pa_entries[[length(pa_entries) + 1L]] <- list(
              value = unname(val_labs[i]),
              label = lbl
            )
          }
        }
      }
    }
    if (length(pa_entries) > 0L) {
      pattern_a[[vname]] <- pa_entries
    } else if (user_specified) {
      skipped_no_udms <- c(skipped_no_udms, vname)
    }
  }

  # --- Pre-flight checks: Q3 strict atomicity --------------------------------
  convention_codes <- getOption(".jst_options_udm_convention_codes",
                                .jst_options_defaults$udm.convention.codes)
  letter_codes <- letters[seq_along(convention_codes)]
  code_for_tag <- .jst_tag_letters_to_codes(letter_codes, convention_codes)
  tag_for_code <- stats::setNames(letter_codes, as.character(convention_codes))

  # Tracking for SAS-style (uppercase) tagged-NA case correction performed
  # inside the to = "spss" branch. Declared at function scope so the
  # notification builder (below) can read it regardless of which branch
  # the call took.
  sas_corrected_vars <- character(0)

  if (to == "spss") {
    # Case-correct SAS-style tags before validating. The convention codes
    # map lowercase letters positionally (.a -> codes[1], .b -> codes[2],
    # ...); uppercase tags have no native SPSS-form representation. Like
    # jsave's .dta path, jconvert treats .A and .a as the same conceptual
    # marker for round-trip purposes, converting the former to the latter
    # before the numeric mapping. Mixed-case columns (a column containing
    # both .a and .A) collapse to a single .a marker — the case
    # distinction is not preserved through SPSS-form, since SPSS has no
    # parallel uppercase convention.
    for (vname in names(info_list)) {
      info <- info_list[[vname]]
      if (info$representation != "stata") next
      col <- data[[vname]]
      if (!is.double(col)) next

      cell_changed  <- FALSE
      label_changed <- FALSE

      tags        <- haven::na_tag(col)
      upper_cells <- which(!is.na(tags) & tags %in% LETTERS)
      if (length(upper_cells) > 0L) {
        for (i in upper_cells) col[i] <- haven::tagged_na(tolower(tags[i]))
        cell_changed <- TRUE
      }

      if (haven::is.labelled(col)) {
        vl <- labelled::val_labels(col)
        if (!is.null(vl) && length(vl) > 0L) {
          lab_tags   <- haven::na_tag(vl)
          upper_labs <- which(!is.na(lab_tags) & lab_tags %in% LETTERS)
          if (length(upper_labs) > 0L) {
            for (i in upper_labs) vl[i] <- haven::tagged_na(tolower(lab_tags[i]))
            labelled::val_labels(col) <- vl
            label_changed <- TRUE
          }
        }
      }

      if (cell_changed || label_changed) {
        data[[vname]]      <- col
        sas_corrected_vars <- c(sas_corrected_vars, vname)
        # Refresh info_list so the downstream validation and conversion
        # loops see post-correction tags rather than the original .A/.B.
        info_list[[vname]] <- .jst_missing_info(col)
      }
    }

    # Stata-to-SPSS: check for letter-tag-beyond-.d and collisions.
    beyond_d_vars  <- list()
    collision_vars <- list()

    for (vname in names(info_list)) {
      info <- info_list[[vname]]
      if (info$representation != "stata") next

      col  <- data[[vname]]
      tags <- haven::na_tag(col)
      unique_tags <- unique(tags[!is.na(tags)])

      bad_tags <- unique_tags[!unique_tags %in% letter_codes]
      if (length(bad_tags) > 0L) {
        beyond_d_vars[[length(beyond_d_vars) + 1L]] <- list(
          var = vname, tags = paste0(".", bad_tags))
      }
      good_tags <- intersect(unique_tags, letter_codes)
      if (length(good_tags) > 0L) {
        x_num         <- suppressWarnings(as.numeric(unclass(col)))
        target_codes  <- unname(code_for_tag[good_tags])
        real_values   <- x_num[!is.na(x_num)]
        hits <- target_codes[
          vapply(target_codes,
                 function(tc) any(real_values == tc),
                 logical(1))
        ]
        if (length(hits) > 0L) {
          collision_vars[[length(collision_vars) + 1L]] <- list(
            var = vname, codes = hits)
        }
      }
    }

    if (length(beyond_d_vars) > 0L || length(collision_vars) > 0L) {
      msg_lines <- "jconvert() cannot proceed with to = \"spss\":"
      if (length(beyond_d_vars) > 0L) {
        msg_lines <- c(msg_lines, "",
                       "  Letter tags beyond .d (jconvert supports .a-.d):")
        for (e in beyond_d_vars) {
          msg_lines <- c(msg_lines,
                         sprintf("    %s: %s", e$var,
                                 paste(e$tags, collapse = ", ")))
        }
      }
      if (length(collision_vars) > 0L) {
        msg_lines <- c(msg_lines, "",
                       "  Target numeric codes collide with real data values:")
        for (e in collision_vars) {
          msg_lines <- c(msg_lines,
                         sprintf("    %s: %s", e$var,
                                 paste(e$codes, collapse = ", ")))
        }
      }
      msg_lines <- c(msg_lines, "",
                     "Resolution options:",
                     "  1. Change the convention codes:",
                     "       joptions(udm.convention.codes = c(...))",
                     "  2. Scope the call to exclude affected columns:",
                     sprintf("       jconvert(%s, to = \"spss\", vars = c(...))",
                             data_name),
                     "  3. Recode the real-data values first via jrecode().")
      .jst_stop(paste(msg_lines, collapse = "\n"))
    }
  }

  if (to == "stata") {
    # SPSS-to-Stata: check for na_range (out of scope) and >4 codes. The
    # codes themselves are mapped to letter tags by descending |code|
    # within each column (per Q6 of the Session 29 design lock); the
    # convention codes are NOT consulted for this direction.
    range_vars     <- character(0)
    over_cap_vars  <- list()

    for (vname in names(info_list)) {
      info <- info_list[[vname]]
      if (info$representation != "spss") next

      if (!is.null(info$na_range) && length(info$na_range) == 2L) {
        range_vars <- c(range_vars, vname)
      }
      if (!is.null(info$codes) && nrow(info$codes) > 4L) {
        over_cap_vars[[length(over_cap_vars) + 1L]] <- list(
          var = vname, n_codes = nrow(info$codes))
      }
    }

    if (length(range_vars) > 0L || length(over_cap_vars) > 0L) {
      msg_lines <- "jconvert() cannot proceed with to = \"stata\":"
      if (length(range_vars) > 0L) {
        msg_lines <- c(msg_lines, "",
                       "  Range-based SPSS missings (na_range) are out of",
                       "  cross-format scope:")
        for (v in range_vars) {
          msg_lines <- c(msg_lines, sprintf("    %s", v))
        }
        msg_lines <- c(msg_lines,
                       "  Enumerate the range as individual na_values codes",
                       "  in SPSS before converting, or scope the call to",
                       "  exclude these columns.")
      }
      if (length(over_cap_vars) > 0L) {
        msg_lines <- c(msg_lines, "",
                       "  More than 4 distinct na_values codes (jconvert",
                       "  supports up to 4 distinct tags .a-.d):")
        for (e in over_cap_vars) {
          msg_lines <- c(msg_lines,
                         sprintf("    %s: %d codes", e$var, e$n_codes))
        }
      }
      msg_lines <- c(msg_lines, "",
                     "Resolution options:",
                     "  1. Scope the call to exclude affected columns:",
                     sprintf("       jconvert(%s, to = \"stata\", vars = c(...))",
                             data_name),
                     "  2. Recode the codes manually via jrecode().")
      .jst_stop(paste(msg_lines, collapse = "\n"))
    }
  }

  # --- Perform conversions ---------------------------------------------------
  converted_vars   <- character(0)
  converted_info   <- list()
  skipped_already  <- character(0)   # in target format already (user_specified only)

  for (vname in names(info_list)) {
    info <- info_list[[vname]]
    col  <- data[[vname]]

    if (to == "baseR") {

      if (info$representation == "spss") {
        x_num <- suppressWarnings(as.numeric(unclass(col)))
        mask  <- rep(FALSE, length(x_num))
        if (!is.null(info$codes) && nrow(info$codes) > 0L) {
          declared_codes <- info$codes$numeric
          declared_codes <- declared_codes[!is.na(declared_codes)]
          if (length(declared_codes) > 0L) {
            mask <- mask | (!is.na(x_num) & x_num %in% declared_codes)
          }
        }
        if (!is.null(info$na_range) && length(info$na_range) == 2L) {
          mask <- mask | (!is.na(x_num) &
                            x_num >= info$na_range[1] &
                            x_num <= info$na_range[2])
        }
        data[[vname]][mask]              <- NA
        attr(data[[vname]], "na_values") <- NULL
        attr(data[[vname]], "na_range")  <- NULL
      } else {
        # Stata-form: haven::zap_missing handles tagged NAs uniformly.
        data[[vname]] <- haven::zap_missing(col)
      }

      # Build the display entries from the original info (pre-strip codes).
      display_entries <- character(0)
      if (!is.null(info$codes) && nrow(info$codes) > 0L) {
        for (i in seq_len(nrow(info$codes))) {
          code <- info$codes$code[i]
          lbl  <- info$codes$label[i]
          display_entries <- c(display_entries,
                               if (!is.na(lbl)) {
                                 sprintf('%s "%s"', code, lbl)
                               } else code)
        }
      }
      if (!is.null(info$na_range) && length(info$na_range) == 2L) {
        display_entries <- c(display_entries,
                             sprintf("range [%s, %s]",
                                     as.character(info$na_range[1]),
                                     as.character(info$na_range[2])))
      }
      converted_vars         <- c(converted_vars, vname)
      converted_info[[vname]] <- list(display = display_entries)

    } else if (to == "spss") {

      if (info$representation == "spss") {
        # Already in target — silent for whole-DF, reported as skipped for
        # explicit-named. Tracked unconditionally so the notification
        # builder can detect the "everything already in target" whole-DF
        # case and report it distinctly from the genuinely-empty case.
        skipped_already <- c(skipped_already, vname)
        next
      }

      tags  <- haven::na_tag(col)
      x_num <- suppressWarnings(as.numeric(unclass(col)))
      unique_tags <- unique(tags[!is.na(tags)])
      for (tg in unique_tags) {
        pos <- which(!is.na(tags) & tags == tg)
        x_num[pos] <- code_for_tag[[tg]]
      }

      val_labs     <- labelled::val_labels(col)
      new_val_labs <- val_labs
      if (!is.null(new_val_labs) && length(new_val_labs) > 0L) {
        vl_tags <- haven::na_tag(new_val_labs)
        for (i in seq_along(new_val_labs)) {
          if (!is.na(vl_tags[i]) && vl_tags[i] %in% letter_codes) {
            new_val_labs[i] <- code_for_tag[[vl_tags[i]]]
          }
        }
      }

      used_codes <- unname(code_for_tag[unique_tags])
      data[[vname]] <- haven::labelled_spss(
        x         = x_num,
        labels    = new_val_labs,
        na_values = used_codes,
        label     = attr(col, "label", exact = TRUE)
      )

      # Build display entries — source tag -> destination code, with the
      # label on the source side. Sort by tag (a, b, c, d) for stable
      # display order regardless of order-of-appearance in the data.
      # SAS-corrected columns display the original uppercase tag, since
      # post-correction `.a`/`.b` would obscure what the user actually
      # had in their data on input.
      was_sas <- vname %in% sas_corrected_vars
      display_entries <- character(0)
      for (tg in sort(unique_tags)) {
        code <- code_for_tag[[tg]]
        display_tag <- if (was_sas) toupper(tg) else tg
        source_disp <- paste0(".", display_tag)
        lbl  <- NA_character_
        if (!is.null(val_labs) && length(val_labs) > 0L) {
          vl_tags <- haven::na_tag(val_labs)
          mm <- which(!is.na(vl_tags) & vl_tags == tg)
          if (length(mm) > 0L) lbl <- names(val_labs)[mm[1]]
        }
        source_disp_with_lbl <- if (!is.na(lbl) && nzchar(lbl)) {
          sprintf('%s "%s"', source_disp, lbl)
        } else source_disp
        display_entries <- c(display_entries,
                             sprintf("%s -> %s",
                                     source_disp_with_lbl,
                                     as.character(code)))
      }
      converted_vars         <- c(converted_vars, vname)
      converted_info[[vname]] <- list(display = display_entries)

    } else if (to == "stata") {

      if (info$representation == "stata") {
        skipped_already <- c(skipped_already, vname)
        next
      }

      x_num <- suppressWarnings(as.numeric(unclass(col)))
      declared_codes <- info$codes$numeric
      declared_codes <- declared_codes[!is.na(declared_codes)]

      # Q6 (Session 29 design lock): SPSS->Stata mapping is ordering-based,
      # not convention-based. Sort the column's own declared codes by
      # absolute value descending, with more-negative-first as the tie-
      # breaker. Then map sorted_codes[1] -> .a, sorted_codes[2] -> .b,
      # etc. The convention codes are NOT consulted for this direction;
      # they only govern the reverse (Stata->SPSS) direction.
      ordering           <- order(-abs(declared_codes), declared_codes)
      sorted_codes       <- declared_codes[ordering]
      column_tag_letters <- letters[seq_along(sorted_codes)]
      column_tag_for_code <- stats::setNames(column_tag_letters,
                                             as.character(sorted_codes))

      new_col   <- as.numeric(x_num)
      used_tags <- character(0)
      for (code in sorted_codes) {
        tag_letter <- column_tag_for_code[[as.character(code)]]
        pos        <- which(!is.na(x_num) & x_num == code)
        new_col[pos] <- haven::tagged_na(tag_letter)
        used_tags <- c(used_tags, tag_letter)
      }

      val_labs     <- labelled::val_labels(col)
      new_val_labs <- val_labs
      if (!is.null(new_val_labs) && length(new_val_labs) > 0L) {
        for (i in seq_along(new_val_labs)) {
          v <- unname(new_val_labs[i])
          # Gate on declared_codes — val_labs entries pointing at codes
          # that aren't formally declared are real-data labels and must
          # stay as numeric entries. Otherwise a val_lab like "Don't know"
          # = -98 on a column with na_values = c(-99) would be incorrectly
          # converted to a tagged-NA marker, breaking the labeling for
          # real -98 cells in the data.
          if (!is.na(v) && v %in% declared_codes) {
            new_val_labs[i] <- haven::tagged_na(
              column_tag_for_code[[as.character(v)]])
          }
        }
      }

      data[[vname]] <- haven::labelled(
        x      = new_col,
        labels = new_val_labs,
        label  = attr(col, "label", exact = TRUE)
      )

      # Build display entries — source code -> destination tag, with the
      # label shown on the source side (the label survives unchanged on
      # the destination, so showing it once on the source is enough). The
      # entries are emitted in sorted_codes order (largest |code| first
      # per Q6), so the user reads ".a came from the largest |code|" left
      # to right.
      display_entries <- character(0)
      for (i in seq_along(sorted_codes)) {
        code <- sorted_codes[i]
        tg   <- column_tag_letters[i]
        lbl  <- NA_character_
        if (!is.null(val_labs) && length(val_labs) > 0L) {
          mm <- which(unname(val_labs) == code & !is.na(unname(val_labs)))
          if (length(mm) > 0L) lbl <- names(val_labs)[mm[1]]
        }
        source_disp <- if (!is.na(lbl) && nzchar(lbl)) {
          sprintf('%s "%s"', as.character(code), lbl)
        } else as.character(code)
        display_entries <- c(display_entries,
                             sprintf("%s -> .%s", source_disp, tg))
      }
      converted_vars         <- c(converted_vars, vname)
      converted_info[[vname]] <- list(display = display_entries)
    }
  }

  # --- Build notification (Q4 five-section format) --------------------------
  if (isTRUE(udm.notice)) {

    n_converted     <- length(converted_vars)
    n_already       <- length(skipped_already)
    n_pattern_a     <- length(pattern_a)
    n_skipped_nodes <- length(skipped_no_udms)

    # Empty-case detection. Two sub-cases need distinct messages:
    #   genuinely_empty       — no UDMs anywhere, no Pattern A. The truly
    #                           "nothing to look at" case.
    #   all_already_in_target — UDM-bearing columns exist but all already
    #                           match the requested target format. Whole-
    #                           DF flavour gets a single-line summary
    #                           since enumerating every already-in-target
    #                           column would be noisy.
    genuinely_empty       <- (length(info_list) == 0L && n_pattern_a == 0L)
    all_already_in_target <- (n_converted == 0L && n_pattern_a == 0L &&
                               n_skipped_nodes == 0L && n_already > 0L)

    if (genuinely_empty) {
      if (user_specified) {
        message("No user-defined missing values found in: ",
                paste(target_vars, collapse = ", "), ".")
      } else {
        message("No user-defined missing values found in '", data_name, "'.")
      }
      return(invisible(data))
    }

    if (all_already_in_target && !user_specified) {
      message(sprintf(
        "All UDM-bearing variables in '%s' are already in %s-form representation.",
        data_name, to))
      return(invisible(data))
    }

    msg_lines <- character(0)

    # Header + Converted: section
    if (n_converted > 0L) {
      header_verb <- switch(
        to,
        baseR = "Stripped declarations of user-defined missing values (UDMs) from",
        spss  = "Converted to SPSS-style missing values in",
        stata = "Converted to Stata-style missing values in"
      )
      msg_lines <- c(msg_lines, paste0(
        header_verb, " ", n_converted, " variable",
        if (n_converted == 1L) "" else "s", ":"))

      max_name_len <- max(nchar(converted_vars))
      for (vname in converted_vars) {
        ci <- converted_info[[vname]]
        msg_lines <- c(msg_lines, paste0(
          "  ", format(vname, width = max_name_len),
          "  (", paste(ci$display, collapse = ", "), ")"))
      }
    }

    # Skipped — already in target format (user_specified only — for whole-DF
    # the all_already_in_target short-circuit above already covered the case
    # where everything was already in target; for whole-DF with some
    # converted and some already in target, the already-in-target columns
    # are intentionally not enumerated to avoid noise).
    if (n_already > 0L && user_specified) {
      if (length(msg_lines) > 0L) msg_lines <- c(msg_lines, "")
      msg_lines <- c(msg_lines,
                     sprintf("Skipped (already in %s-form representation):", to),
                     paste0("  ", paste(skipped_already, collapse = ", ")))
    }

    # Skipped — no UDMs found (user_specified only by construction —
    # skipped_no_udms is only populated when user_specified is TRUE)
    if (n_skipped_nodes > 0L) {
      if (length(msg_lines) > 0L) msg_lines <- c(msg_lines, "")
      msg_lines <- c(msg_lines,
                     "Skipped (no UDMs found):",
                     paste0("  ", paste(skipped_no_udms, collapse = ", ")))
    }

    # Skipped — value labels suggest missingness (Pattern A)
    if (n_pattern_a > 0L) {
      if (length(msg_lines) > 0L) msg_lines <- c(msg_lines, "")
      msg_lines <- c(msg_lines,
                     "Skipped (value labels suggest missingness but not formally declared):")
      for (vname in names(pattern_a)) {
        entries <- pattern_a[[vname]]
        for (e in entries) {
          msg_lines <- c(msg_lines, sprintf(
            "  %s: %s = \"%s\"",
            vname, as.character(e$value), e$label))
        }
      }
      msg_lines <- c(msg_lines,
                     "",
                     "  To formalise these as UDMs, see jdeclare_udm().",
                     "  To leave them as ordinary data, no action is needed.")
    }

    # Assignment-syntax reminder (only when a conversion actually
    # happened AND the output level isn't "minimal" — the reminder is an
    # instructional aid for SPSS migrants new to R's assignment
    # semantics, displayed on the "standard" and "full" levels but
    # suppressed on "minimal" where users have already opted into
    # less-verbose output).
    if (n_converted > 0L) {
      out_level <- getOption(".jst_output_level", "standard")
      if (out_level != "minimal") {
        if (length(msg_lines) > 0L) msg_lines <- c(msg_lines, "")
        example_call <- .jst_build_jconvert_example(
          data_name = data_name, to = to,
          var_scope = var_scope,
          dot_names = dot_names, vars = vars)
        msg_lines <- c(msg_lines,
                       "Reminder: Changes are retained only when assigning the result back to your data frame,",
                       paste0("e.g., ", example_call))
      }
    }

    message(paste(msg_lines, collapse = "\n"))
  }

  invisible(data)
}


#' Internal: build the assignment-syntax example for jconvert notifications
#'
#' When the rendered call fits within the current terminal width (allowing
#' for the \code{prefix_width}-character "e.g., " prefix the caller will
#' prepend), the function returns a single-line string. When it doesn't,
#' the call is broken across multiple lines, packing args greedily into
#' each line, with continuation lines indented to align with the opening
#' paren of the \code{jconvert(} call.
#'
#' @keywords internal
.jst_build_jconvert_example <- function(data_name, to,
                                        var_scope, dot_names, vars,
                                        prefix_width = 6L) {
  to_arg <- paste0("to = \"", to, "\"")

  if (var_scope == "dots") {
    args <- c(data_name, to_arg, dot_names)
  } else if (var_scope == "vars") {
    vars_str <- paste0("vars = c(\"",
                       paste(vars, collapse = "\", \""),
                       "\")")
    args <- c(data_name, to_arg, vars_str)
  } else {
    args <- c(data_name, to_arg)
  }

  header <- paste0(data_name, " <- jconvert(")
  width  <- getOption("width", 80L)

  # Single-line case: the call (with the caller's "e.g., " prefix
  # accounted for) fits within terminal width.
  single <- paste0(header, paste(args, collapse = ", "), ")")
  if (prefix_width + nchar(single) <= width) {
    return(single)
  }

  # Multi-line wrap. Continuation lines align with the opening paren of
  # the jconvert() call on the first line.
  cont_indent <- strrep(" ", prefix_width + nchar(header))

  # Each token = one arg with its trailing punctuation ("arg," or "arg)").
  tokens <- vapply(seq_along(args), function(i) {
    paste0(args[i], if (i < length(args)) "," else ")")
  }, character(1))

  out_lines <- character(0)
  current   <- header
  on_first  <- TRUE   # first line gets the "e.g., " prefix width
  fresh     <- TRUE   # current line has no args yet (just header/indent)

  for (tok in tokens) {
    sep  <- if (fresh) "" else " "
    test <- paste0(current, sep, tok)
    eff  <- if (on_first) prefix_width + nchar(test) else nchar(test)

    if (eff <= width || fresh) {
      # Fits, or the line has no args yet — accept either way (a token too
      # wide for an otherwise-empty line still has to go somewhere).
      current <- test
      fresh   <- FALSE
    } else {
      # Doesn't fit; flush current line and start a new continuation line.
      out_lines <- c(out_lines, current)
      current   <- paste0(cont_indent, tok)
      on_first  <- FALSE
      fresh     <- FALSE
    }
  }

  out_lines <- c(out_lines, current)
  paste(out_lines, collapse = "\n")
}
