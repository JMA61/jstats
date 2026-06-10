#<<<FILE: cps.R>>>

#' Internal helper: first-match lookup against a CPS rule frame
#'
#' @param rules A .jst_cps_*_rules data frame.
#' @param conds Named list of column -> observed value. A rule cell of
#'   \code{"any"} matches anything; otherwise an exact match is required.
#' @return The first matching row index, or \code{NA_integer_}.
#' @keywords internal
.jst_cps_match <- function(rules, conds) {
  for (i in seq_len(nrow(rules))) {
    ok <- TRUE
    for (col in names(conds)) {
      rv <- rules[[col]][i]
      if (!identical(rv, "any") && !identical(rv, conds[[col]])) {
        ok <- FALSE; break
      }
    }
    if (ok) return(i)
  }
  NA_integer_
}

#' Internal helper: resolve the CPS render spec from the rule tables
#'
#' Reads the three .jst_cps_*_rules frames and applies layer precedence
#' (Visibility first; if not rendered, returns early). Contains no rules of
#' its own. Errors loudly on a coordinate that matches no row.
#'
#' @param layout One of \code{"listwise"}, \code{"pairwise"},
#'   \code{"per_var_desc"}, \code{"per_var_freq"}.
#' @param pipeline_active Logical. Any of jcomplete/jsubset/subset fired.
#' @param has_udms Logical. At least one analysis variable has a declared UDM.
#' @param has_sysna Logical. At least one analysis variable has plain-NA
#'   missingness (in source or pool).
#' @param output_level One of \code{"minimal"}, \code{"standard"},
#'   \code{"full"}.
#' @param detail_tier One of \code{"none"}, \code{"totals"}, \code{"per_code"}.
#' @param cps_toggle Resolved case.processing toggle: \code{TRUE} (always),
#'   \code{FALSE} (never), or \code{NULL} (auto -> use output_level).
#' @return A list: render, render_top, render_bottom, endpoint_label,
#'   show_auto_listwise, resolved_tier, hide_second_col_pair.
#' @keywords internal
.jst_resolve_cps_render <- function(layout, pipeline_active,
                                    has_udms, has_sysna,
                                    output_level, detail_tier,
                                    cps_toggle = NULL) {

  eff_level <- if (isTRUE(cps_toggle)) "full"
               else if (identical(cps_toggle, FALSE)) "minimal"
               else output_level
  any_missing <- has_udms || has_sysna

  vi <- .jst_cps_match(
    .jst_cps_visibility_rules,
    list(level    = eff_level,
         pipeline = if (pipeline_active) "yes" else "no",
         missing  = if (any_missing) "yes" else "no"))
  if (is.na(vi)) {
    stop(".jst_resolve_cps_render(): no visibility rule for level='", eff_level,
         "', pipeline=", pipeline_active, ", missing=", any_missing,
         call. = FALSE)
  }
  if (!.jst_cps_visibility_rules$rendered[vi]) return(list(render = FALSE))

  li <- match(layout, .jst_cps_layout_rules$layout)
  if (is.na(li)) {
    stop(".jst_resolve_cps_render(): unknown layout '", layout, "'",
         call. = FALSE)
  }
  base <- .jst_cps_layout_rules[li, ]

  bi <- .jst_cps_match(
    .jst_cps_bottom_rules,
    list(layout    = layout,
         has_udms  = if (has_udms) "yes" else "no",
         has_sysna = if (has_sysna) "yes" else "no",
         tier      = detail_tier))
  if (is.na(bi)) {
    stop(".jst_resolve_cps_render(): no bottom rule for layout='", layout,
         "', has_udms=", has_udms, ", has_sysna=", has_sysna,
         ", tier='", detail_tier, "'", call. = FALSE)
  }
  ref <- .jst_cps_bottom_rules[bi, ]

  # Base footnote (e): the refinement layer can suppress an "on" base default
  # but cannot promote an "off" one (so per_var_freq never grows a bottom).
  render_bottom <- (base$bottom_default == "on") && isTRUE(ref$bottom)

  list(
    render               = TRUE,
    render_top           = (base$top_default == "on"),
    render_bottom        = render_bottom,
    endpoint_label       = base$endpoint_label,
    show_auto_listwise   = (base$auto_listwise == "shown"),
    resolved_tier        = if (render_bottom) ref$resolved_tier else NA_character_,
    hide_second_col_pair = !pipeline_active
  )
}

#' Internal helper: per-variable source/pool missing rows for the CPS bottom
#'
#' Computes, for one analysis variable, the per-code (and System/NA) counts
#' in the source (full original) and pool (surviving rows) columns. Counts
#' come from the pre-masking columns so SPSS-form UDM codes are still live
#' values; pool counts are post-filter-correct (this is also why the Session
#' 29 pre/post UDM count quirk does not affect the CPS bottom).
#'
#' @param pre_col  Pre-masking original column (full N).
#' @param pool_col Pre-masking column restricted to surviving rows.
#' @param mi       \code{.jst_missing_info()} for the column, or NULL.
#' @return data.frame(code_label, src, pool); empty if no missingness.
#' @keywords internal
.jst_cps_var_rows <- function(pre_col, pool_col, mi) {
  rows <- data.frame(code_label = character(0), src = integer(0),
                     pool = integer(0), stringsAsFactors = FALSE)

  if (!is.null(mi)) {
    if (identical(mi$representation, "stata")) {
      tag_pre  <- haven::na_tag(pre_col)
      tag_pool <- haven::na_tag(pool_col)
      for (i in seq_len(nrow(mi$codes))) {
        r   <- mi$codes[i, ]
        s   <- sum(!is.na(tag_pre)  & tag_pre  == r$tag)
        p   <- sum(!is.na(tag_pool) & tag_pool == r$tag)
        lab <- if (!is.na(r$label) && nzchar(r$label))
                 sprintf('%s ["%s"]', r$code, r$label)
               else sprintf('%s (no label)', r$code)
        rows <- rbind(rows, data.frame(code_label = lab, src = s, pool = p,
                                       stringsAsFactors = FALSE))
      }
    } else {
      # SPSS-form: per declared code, then na_range. UDM codes are live
      # values in the pre-masking columns, so numeric comparison works.
      x_pre  <- suppressWarnings(as.numeric(unclass(pre_col)))
      x_pool <- suppressWarnings(as.numeric(unclass(pool_col)))
      if (!is.null(mi$codes) && nrow(mi$codes) > 0L) {
        for (i in seq_len(nrow(mi$codes))) {
          r   <- mi$codes[i, ]
          s   <- sum(!is.na(x_pre)  & x_pre  == r$numeric)
          p   <- sum(!is.na(x_pool) & x_pool == r$numeric)
          lab <- if (!is.na(r$label) && nzchar(r$label))
                   sprintf('%s ["%s"]', r$code, r$label)
                 else sprintf('%s (no label)', r$code)
          rows <- rbind(rows, data.frame(code_label = lab, src = s, pool = p,
                                         stringsAsFactors = FALSE))
        }
      }
      if (!is.null(mi$na_range) && length(mi$na_range) == 2L) {
        lo <- mi$na_range[1]; hi <- mi$na_range[2]
        s  <- sum(!is.na(x_pre)  & x_pre  >= lo & x_pre  <= hi)
        p  <- sum(!is.na(x_pool) & x_pool >= lo & x_pool <= hi)
        rows <- rbind(rows, data.frame(
          code_label = sprintf("range %s to %s", lo, hi),
          src = s, pool = p, stringsAsFactors = FALSE))
      }
    }
  }

  # System/NA = genuine system-missing cells (NA in the raw data), counted
  # separately from the declared-UDM rows above so each missing cell is counted
  # exactly once. For Stata-form, exclude tagged NAs (those are the per-tag rows
  # above). For the SPSS/no-mi branch, count is.na() on the UNCLASSED column: a
  # live haven_labelled_spss reports its na_values cells as NA under is.na(),
  # and those cells were already counted in the code/range rows above, so
  # is.na(pre_col) would double-count them. unclass() drops the class that
  # triggers that flagging, leaving only true system-missing (and is a harmless
  # no-op for plain numeric / factor / character / non-spss labelled columns).
  if (!is.null(mi) && identical(mi$representation, "stata")) {
    sys_src  <- sum(is.na(pre_col)  & is.na(haven::na_tag(pre_col)))
    sys_pool <- sum(is.na(pool_col) & is.na(haven::na_tag(pool_col)))
  } else {
    sys_src  <- sum(is.na(unclass(pre_col)))
    sys_pool <- sum(is.na(unclass(pool_col)))
  }
  if (sys_src > 0L || sys_pool > 0L) {
    rows <- rbind(rows, data.frame(code_label = .jst_label_system_missing,
                                   src = sys_src, pool = sys_pool,
                                   stringsAsFactors = FALSE))
  }
  rows
}

#' Internal helper: truncate a string to a display-width cap with ellipsis
#'
#' Single source of truth for the package's table-cell width cap. A string
#' wider than \code{max_width} display columns is cut to \code{max_width - 1}
#' columns and given a trailing ellipsis character; shorter strings are
#' returned unchanged. Display width is measured with
#' \code{nchar(type = "width")} so double-width characters are counted
#' correctly. The default 40-column cap is shared across every in-table label
#' surface -- CPS pipeline detail (via \code{.jst_cps_cap_label}), jfreq value
#' labels and grouped headers, jdesc/jcorr variable-identifier columns -- so a
#' future change to the cap is made in this one place. Title and heading lines
#' (which sit on their own line with no column to share) are never routed
#' through this helper.
#'
#' @param content Character scalar (coerced; first element used).
#' @param max_width Integer display-column cap. Default 40.
#'
#' @return Single character string, capped to \code{max_width} columns.
#'
#' @keywords internal
.jst_truncate_ellipsis <- function(content, max_width = 40L) {
  content <- as.character(content)[1L]
  if (is.na(content)) return(content)
  if (nchar(content, type = "width") <= max_width) return(content)
  paste0(substr(content, 1L, max_width - 1L), "\u2026")
}

#' Internal helper: cap a pipeline-row label's parenthetical content for CPS
#'
#' Keeps the Case-Processing top table readable when a long jcomplete()
#' variable set or a jsubset()/subset = expression would otherwise blow out
#' the dynamic column width. Two modes:
#'   "list" -- a character vector of names (jcomplete's complete_vars). With
#'             more than max_items entries, returns the first max_items
#'             followed by ", +N more". The full set stays visible via
#'             jcomplete()'s own status query.
#'   "expr" -- a single expression string (filter_expr / subset_expr).
#'             Truncated to max_width display columns with a trailing
#'             ellipsis when longer.
#' Returns the (possibly shortened) content only; the caller supplies the
#' operation prefix, e.g. sprintf("jcomplete (%s)", ...). Display width is
#' measured with nchar(type = "width"), matching the renderer's dw().
#' @keywords internal
.jst_cps_cap_label <- function(content, mode = c("list", "expr"),
                               max_items = 2L, max_width = 40L) {
  mode <- match.arg(mode)
  if (mode == "list") {
    content <- as.character(content)
    n <- length(content)
    if (n <= max_items) return(paste(content, collapse = ", "))
    sprintf("%s, +%d more",
            paste(content[seq_len(max_items)], collapse = ", "),
            n - max_items)
  } else {
    .jst_truncate_ellipsis(content, max_width = max_width)
  }
}

#' Internal helper: print the Case Processing Summary (CPS)
#'
#' Resolves a render spec from the .jst_cps_*_rules tables (via
#' \code{.jst_resolve_cps_render}) and draws the top table (pipeline chain)
#' and, where the spec calls for it, the bottom table (per-variable
#' missing-data breakdown, totals or per_code tier). Contains no render-rule
#' logic of its own; all show/hide decisions arrive pre-resolved.
#'
#' Display design = JStats_CPS_Rendering_Reference.txt (four layouts, Form B
#' bottom). Missing-value semantics = JStats_Missing_Values_Reference.txt.
#'
#' @param sample_info List from \code{.jst_build_sample_info} (carries the
#'   pipeline counts plus pre_pipeline_data / surviving_ids / analysis_vars).
#' @param analysis_type Layout key: \code{"listwise"}, \code{"pairwise"},
#'   \code{"per_var_desc"}, or \code{"per_var_freq"}.
#' @param detail Per-call case.processing.detail override (NULL, "none",
#'   "totals", "per_code"). NULL defers to the joutput tier default.
#' @param notification_template,data,analysis_vars Listwise-discrepancy
#'   notification inputs (per-variable layouts only); see the closure below.
#' @return \code{invisible(NULL)}.
#' @keywords internal
.jst_print_case_processing <- function(sample_info,
                                       analysis_type        = "listwise",
                                       detail                = NULL,
                                       notification_template = NULL,
                                       data                  = NULL,
                                       analysis_vars         = NULL) {

  valid_layouts <- c("listwise", "pairwise", "per_var_desc", "per_var_freq")
  if (!analysis_type %in% valid_layouts) {
    stop(".jst_print_case_processing(): analysis_type must be one of ",
         paste(sprintf("'%s'", valid_layouts), collapse = ", "), ".",
         call. = FALSE)
  }

  # Validate the per-call case.processing.detail value at this shared chokepoint
  # (every analysis function routes its case.processing.detail through here as
  # detail=). NULL means "defer to the joutput tier default"; any non-NULL value
  # must be a real detail tier. Caught here -- rather than left to slip through
  # to .jst_resolve_cps_render's internal "no bottom rule" stop() -- so an
  # invalid value (e.g. the output-level name "full" passed by mistake) yields
  # the same house-voice error every analysis function would give, attributed to
  # the public caller via .jst_stop_arg's auto-detection. Mirrors the joutput()
  # guard on the same argument; user-facing value, so it routes through
  # .jst_stop_arg rather than the bare internal-invariant stop() above.
  if (!is.null(detail) &&
      (!is.character(detail) || length(detail) != 1L ||
       !(detail %in% c("none", "totals", "per_code")))) {
    .jst_stop_arg(arg = "case.processing.detail",
                  choices = c("none", "totals", "per_code"))
  }

  n_original <- sample_info$n_original
  n_analysis <- sample_info$n_analysis
  if (is.null(n_original) || n_original == 0) return(invisible(NULL))

  is_per_var <- analysis_type %in% c("per_var_desc", "per_var_freq")

  # ---- Listwise-discrepancy notification (per-variable layouts only) -------
  # Fires when 2+ analysis variables AND listwise across them would drop
  # cases beyond the smallest per-variable N. Independent of the CPS table.
  notification_eligible <- function() {
    if (!is_per_var || is.null(notification_template) ||
        is.null(data) || is.null(analysis_vars) ||
        length(analysis_vars) < 2 ||
        getOption(".jst_output_level", "standard") == "minimal" ||
        isTRUE(sample_info$complete_active)) {
      return(FALSE)
    }
    listwise_n <- sum(stats::complete.cases(data[, analysis_vars, drop = FALSE]))
    per_var_ns <- vapply(analysis_vars,
                         function(v) sum(!is.na(data[[v]])), integer(1))
    listwise_n < min(per_var_ns)
  }
  fire_notification <- function() {
    listwise_n <- sum(stats::complete.cases(data[, analysis_vars, drop = FALSE]))
    msg <- if (grepl("%d", notification_template, fixed = TRUE)) {
      sprintf(notification_template, listwise_n)
    } else notification_template
    cat(msg, "\n\n", sep = "")
  }

  # ---- Resolve the render spec from the rule tables ------------------------
  pre <- sample_info$pre_pipeline_data
  if (!is.null(pre) && !is.null(sample_info$surviving_ids)) {
    pool <- pre[sample_info$surviving_ids, , drop = FALSE]
  } else {
    pool <- NULL
  }
  cps_vars <- intersect(sample_info$analysis_vars,
                        if (is.null(pre)) character(0) else names(pre))

  mi_list  <- if (length(cps_vars))
                lapply(cps_vars, function(v) .jst_missing_info(pre[[v]]))
              else list()
  names(mi_list) <- cps_vars
  has_udms  <- any(vapply(mi_list, function(mi)
                 !is.null(mi) && !is.null(mi$codes) && nrow(mi$codes) > 0L,
                 logical(1)))
  has_sysna <- any(vapply(cps_vars, function(v) sum(is.na(pre[[v]])) > 0L,
                          logical(1)))

  pipeline_active <- isTRUE(sample_info$complete_active) ||
                     isTRUE(sample_info$filter_active) ||
                     !is.null(sample_info$n_after_subset)

  cps_toggle  <- .jst_resolve_toggle("case.processing", NULL)
  detail_tier <- .jst_resolve_toggle("case.processing.detail", detail)
  out_level   <- getOption(".jst_output_level", "standard")

  spec <- .jst_resolve_cps_render(
    layout          = analysis_type,
    pipeline_active = pipeline_active,
    has_udms        = isTRUE(has_udms),
    has_sysna       = isTRUE(has_sysna),
    output_level    = out_level,
    detail_tier     = detail_tier,
    cps_toggle      = cps_toggle)

  fmt1 <- function(x) sprintf("%.1f", x)
  dash <- "\u2014"
  # Pad on DISPLAY width, not sprintf's byte-based field width: the em-dash
  # is one column but three UTF-8 bytes, so sprintf("%Ns", ...) would under-
  # pad dash cells and shift the row. padl/padr right/left-justify by glyph
  # width so numeric and dash rows align.
  padl <- function(x, w) { x <- as.character(x)
    paste0(strrep(" ", max(0L, w - nchar(x, type = "width"))), x) }
  padr <- function(x, w) { x <- as.character(x)
    paste0(x, strrep(" ", max(0L, w - nchar(x, type = "width")))) }
  dw   <- function(x) nchar(as.character(x), type = "width")

  if (isTRUE(spec$render)) {

    # Width of the widest rendered table; sizes the closing rule (Session 52).
    rule_w <- 0L

    # ---- TOP TABLE: pipeline chain ----
    if (isTRUE(spec$render_top)) {
      labels <- "Original"; detail <- ""
      surv_v <- n_original; exc_v <- NA_integer_
      prior  <- n_original

      if (isTRUE(sample_info$complete_active) &&
          !is.null(sample_info$n_after_complete)) {
        det <- if (!is.null(sample_info$complete_vars) &&
                   length(sample_info$complete_vars))
                 .jst_cps_cap_label(sample_info$complete_vars, mode = "list")
               else ""
        labels <- c(labels, "jcomplete"); detail <- c(detail, det)
        exc_v  <- c(exc_v, prior - sample_info$n_after_complete)
        surv_v <- c(surv_v, sample_info$n_after_complete)
        prior  <- sample_info$n_after_complete
      }
      if (isTRUE(sample_info$filter_active) &&
          !is.null(sample_info$n_after_filter)) {
        det <- if (!is.null(sample_info$filter_expr) &&
                   nzchar(sample_info$filter_expr))
                 .jst_cps_cap_label(sample_info$filter_expr, mode = "expr")
               else ""
        labels <- c(labels, "jsubset"); detail <- c(detail, det)
        exc_v  <- c(exc_v, prior - sample_info$n_after_filter)
        surv_v <- c(surv_v, sample_info$n_after_filter)
        prior  <- sample_info$n_after_filter
      }
      if (!is.null(sample_info$n_after_subset)) {
        det <- if (!is.null(sample_info$subset_expr) &&
                   nzchar(sample_info$subset_expr))
                 .jst_cps_cap_label(sample_info$subset_expr, mode = "expr")
               else ""
        labels <- c(labels, "subset ="); detail <- c(detail, det)
        exc_v  <- c(exc_v, prior - sample_info$n_after_subset)
        surv_v <- c(surv_v, sample_info$n_after_subset)
        prior  <- sample_info$n_after_subset
      }
      if (isTRUE(spec$show_auto_listwise)) {
        labels <- c(labels, "Auto-listwise"); detail <- c(detail, "")
        exc_v  <- c(exc_v, sample_info$n_excluded_missing)
        surv_v <- c(surv_v, n_analysis)
        prior  <- n_analysis
      }
      labels <- c(labels, spec$endpoint_label); detail <- c(detail, "")
      exc_v  <- c(exc_v, NA_integer_)
      surv_v <- c(surv_v, prior)

      # Column widths sized to content (display width) so the multibyte
      # em-dash aligns. Pipeline detail (jcomplete variables, jsubset /
      # subset = expressions) renders as an UNHEADED trailing column after
      # Remaining, so Excluded/Remaining sit in a stable position no matter
      # how long or numerous the variable names are. Title flush-left (indent
      # 0); data rows indented 4. (Session 52: dropped "% Surviving", renamed
      # "Surviving" -> "Remaining". Session 57: pipeline detail moved to the
      # trailing column; .jst_cps_cap_label truncation retained as a line-
      # length guard only.)
      exc_strs  <- vapply(seq_along(labels), function(i)
                     if (is.na(exc_v[i])) dash else as.character(exc_v[i]),
                     character(1))
      surv_strs <- as.character(surv_v)
      h_ind <- 0L; r_ind <- 4L
      lab_end <- max(h_ind + dw("Case Processing"), r_ind + max(dw(labels)))
      exc_w  <- max(dw("Excluded"),  max(dw(exc_strs)))
      surv_w <- max(dw("Remaining"), max(dw(surv_strs)))
      g <- "  "

      cat("\n")
      cat(strrep(" ", h_ind), padr("Case Processing", lab_end - h_ind), g,
          padl("Excluded", exc_w), g, padl("Remaining", surv_w),
          "\n", sep = "")
      for (i in seq_along(labels)) {
        det_str <- if (nzchar(detail[i])) paste0(g, detail[i]) else ""
        cat(strrep(" ", r_ind), padr(labels[i], lab_end - r_ind), g,
            padl(exc_strs[i], exc_w), g, padl(surv_strs[i], surv_w),
            det_str, "\n", sep = "")
      }
      base_w  <- lab_end + exc_w + surv_w + 4L
      det_ext <- if (any(nzchar(detail)))
                   2L + max(dw(detail[nzchar(detail)])) else 0L
      rule_w  <- max(rule_w, base_w + det_ext)
    }

    # ---- BOTTOM TABLE: missing-data breakdown (Form B) ----
    if (isTRUE(spec$render_bottom) && !is.null(pool)) {
      per_code <- identical(spec$resolved_tier, "per_code")
      two_cols <- !isTRUE(spec$hide_second_col_pair)
      n_pool   <- nrow(pool)

      # First pass: gather the rows to display per variable (skip variables
      # with no missingness in either column), so widths can be sized to
      # actual content.
      disp <- list()
      for (v in cps_vars) {
        vr <- .jst_cps_var_rows(pre[[v]], pool[[v]], mi_list[[v]])
        if (nrow(vr) == 0L || (sum(vr$src) == 0L && sum(vr$pool) == 0L)) next
        rows <- if (per_code) vr
                else data.frame(code_label = "Missing", src = sum(vr$src),
                                pool = sum(vr$pool), stringsAsFactors = FALSE)
        disp[[length(disp) + 1L]] <- list(var = v, rows = rows)
      }

      if (length(disp) > 0L) {
        src_hdr  <- paste0("From ", n_original)
        pool_hdr <- paste0("From ", n_pool)
        all_lab  <- unlist(lapply(disp, function(d) d$rows$code_label))
        all_src  <- unlist(lapply(disp, function(d) d$rows$src))
        all_pool <- unlist(lapply(disp, function(d) d$rows$pool))
        all_srcp <- fmt1(all_src  / n_original * 100)
        all_plp  <- fmt1(all_pool / n_pool     * 100)

        h_ind <- 0L; c_ind <- 6L
        lab_end <- max(h_ind + dw("Missing-data breakdown"),
                       c_ind + max(dw(all_lab)))
        # The "From N" header defines each count column's width; the count
        # value-block is sized to the widest count in that column and centred
        # within the column (counts right-justified within the block). Percent
        # columns keep their right-justified rendering. (Session 52.)
        src_count_w  <- max(dw(all_src))
        pool_count_w <- max(dw(all_pool))
        srcn_w  <- max(dw(src_hdr),  src_count_w)
        pooln_w <- max(dw(pool_hdr), pool_count_w)
        pct_w   <- max(dw("%"), max(dw(all_srcp), dw(all_plp)))
        g <- "  "

        # Centre a count under its header: right-justify within the value
        # block, then centre that block within the column width.
        ctr_count <- function(x, block_w, col_w) {
          s     <- padl(x, block_w)
          extra <- max(0L, col_w - block_w)
          left  <- extra %/% 2L
          paste0(strrep(" ", left), s, strrep(" ", extra - left))
        }

        # Build each row as one string and strip trailing whitespace before
        # printing, so header and label-only rows carry no trailing blanks
        # (Session 52). centre_counts = FALSE on the header keeps the "From N"
        # labels right-justified, since they define the column width.
        emit <- function(indent, lab, lab_w, c1, p1, c2, p2,
                         centre_counts = TRUE) {
          c1_cell <- if (centre_counts) ctr_count(c1, src_count_w, srcn_w)
                     else padl(c1, srcn_w)
          line <- paste0(strrep(" ", indent), padr(lab, lab_w), g,
                         c1_cell, g, padl(p1, pct_w))
          if (two_cols) {
            c2_cell <- if (centre_counts) ctr_count(c2, pool_count_w, pooln_w)
                       else padl(c2, pooln_w)
            line <- paste0(line, g, c2_cell, g, padl(p2, pct_w))
          }
          cat(sub("[ ]+$", "", line), "\n", sep = "")
        }

        cat("\n")
        emit(h_ind, "Missing-data breakdown", lab_end - h_ind,
             src_hdr, "%", pool_hdr, "%", centre_counts = FALSE)
        for (d in disp) {
          cat(strrep(" ", 4L), d$var, "\n", sep = "")
          for (j in seq_len(nrow(d$rows))) {
            sc <- d$rows$src[j]; pl <- d$rows$pool[j]
            emit(c_ind, d$rows$code_label[j], lab_end - c_ind,
                 as.character(sc), fmt1(sc / n_original * 100),
                 as.character(pl), fmt1(pl / n_pool * 100))
          }
        }

        bottom_w <- if (two_cols)
                      lab_end + srcn_w + pooln_w + 2L * pct_w + 8L
                    else
                      lab_end + srcn_w + pct_w + 4L
        rule_w <- max(rule_w, bottom_w)
      }
    }
    if (rule_w > 0L) {
      cat("\n", strrep("\u2500", rule_w), "\n", sep = "")
    }
    cat("\n")
  }

  # Notification fires on its own conditions, table or no table.
  if (notification_eligible()) fire_notification()

  invisible(NULL)
}
