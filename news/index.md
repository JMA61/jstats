# Changelog

## jstats 0.9.252

To the colleagues and students trying jstats before its CRAN release:
thank you. Here is what is new since the last release (0.9.223).

- **Quiet mode for scripts.** `joutput("silent")`, or `print = FALSE` on
  any analysis, fits a model or builds a table without printing it. Keep
  the result (`m <- jlm(...)`) and use it later.
- **Label a set of survey items in one call.**
  `jrelabel(d, c(Q1, Q2, Q3), labels = "1=Never; 2=Sometimes; 3=Often", modify = TRUE)`
- **New plots.** `type = "density"` beside the histogram, `facet =` for
  one panel per group, and the log-odds plot of a logistic regression,
  `jplot(m, which = "logit")`.
- **More in the model output.** Standardized coefficients in
  [`jlogistic()`](https://jma61.github.io/jstats/reference/jlogistic.md),
  Cramer’s V in `jcrosstab(chisq = TRUE)`, and one VIF row for a
  categorical predictor.
- **Missing values on text variables.**
  [`jdeclare_missing()`](https://jma61.github.io/jstats/reference/jdeclare_missing.md)
  now declares codes such as `"UNKNOWN"`, or blank cells, on a text
  variable.
- **Loading files.**
  [`jload()`](https://jma61.github.io/jstats/reference/jload.md) reads
  the package’s example files by name, skips title rows in Excel and CSV
  files (`skip =`), reads files with no names row (`header = FALSE`),
  and fixes variable names R cannot read, keeping the original as the
  label.
- **Clearer messages throughout.** Every line of code a message suggests
  now runs as printed.

Problems or suggestions: tell me, or open an issue at
<https://github.com/jma61/jstats/issues>.
