# jstats 0.9.267

Thank you for trying jstats. Here is what is new since 0.9.265.

* **"Not at all" scales read as Likert.** A single question whose labels
  run from Not at all to Extremely, Very or A great deal, among others,
  now reads as a Likert item: `jscreen()` shows it as Likert, and
  `jdesc()` no longer warns that it seems categorical.
* **Infinite values.** When a variable holds Inf or -Inf, such as the log
  of a zero, `jt()`, `jaov()`, `jlm()`, `jlogistic()`, `jalpha()`,
  `jcorr()` for Pearson's r, and `jplot()` for a histogram, scatter or box
  plot say how many, and give the line that sets them to missing in a new
  variable. Before, R stopped with "missing value
  where TRUE/FALSE needed" or "NA/NaN/Inf in 'y'". `jdesc()` prints -Inf
  with its sign, where it printed Inf.
* **Messages easier to read.** Notes, warnings and errors put one sentence
  on a line, and they say outcome and predictor where they said DV and IV.
* **Words beyond A to Z in `jencode()`.** When the words hold letters such
  as Á or 北, its note says it coded them in character-code order, which
  may not be alphabetical: Ávila comes after Zebrinha. A map sets any
  order you like:
  `d$CityN <- jencode(d, City, map = "Ávila=1; Belém=2; Zebrinha=3")`

When something you typed before now stops, its message says what to type
instead.

Problems or suggestions: tell me, or open an issue at
https://github.com/jma61/jstats/issues.

# jstats 0.9.265

Thank you for trying jstats. Here is what is new since 0.9.254.

* **Chinese, Japanese and Korean text.** Tables, notes and labels line up,
  each character taking two columns. Text loaded from a CSV file sorts, so
  `jencode()` codes it, where it stopped with an encoding error. A
  full-width semicolon or equals sign typed in a map stops, with the call
  retyped in plain characters, ready to run.
* **Labels survive a subset.** A subset taken with base R, such as
  `community[community$Age > 40, ]`, keeps its value labels and declared
  missing values from the moment jstats is loaded. Before, a subset taken
  ahead of your first jstats call lost them without a word, and -99
  (Refused) was counted as an income.
* **A data frame's name typed wrong.** Type `dd` for `d`, as in
  `jt(Score ~ Group, dd)`, and jstats offers the call with the data frame
  that holds those variables, `jt(Score ~ Group, d)`. The same inside an
  expression, such as `dd[dd$Age > 40, ]`.
* **Blank text cells in Excel sheets.** A sheet's text variable now loads
  as a CSV file's does: an empty cell is the `<blank>` category, counted as
  valid, where it loaded as missing. To keep blanks missing:
  `jload("survey.xlsx", na = "")`
* **More single questions read as Likert.** Labels running from Never to
  Very often, Very poor to Very good, or Strongly oppose to Strongly
  support, among others, now read as a Likert item: `jscreen()` shows it as
  Likert, and `jdesc()` and `jcorr()` no longer warn that it seems
  categorical.
* **Plots of labelled variables.** A labelled variable with a few
  categories is drawn as categories, unless `numeric =` says otherwise. So
  `jplot(WellbeingScore ~ Region, community)` draws a boxplot for each
  region, where it plotted the region codes as numbers.

When something you typed before now stops, its message says what to type
instead.

Problems or suggestions: tell me, or open an issue at
https://github.com/jma61/jstats/issues.

# jstats 0.9.254

Thank you for trying jstats. Here is what is new since the last release
(0.9.252).

* **CSV files load as written.** A postcode such as 0800 keeps its zero, a
  long ID keeps every digit, a column of F stays F, and the word NA in a
  text column (Namibia's country code) stays a word. A note says when a
  column of numbers was kept as text, so a file you loaded before may now
  give such a column as text, with the reason beside it.
* **N/A, - and . in a column of numbers.** jstats does not assume they
  mean missing. When a few such cells make a column of numbers text, a
  note names them and gives the line that reads them as missing:
  `jload("incomes.csv", na = c("N/A", "-", "."))`
* **Keep a column exactly as typed.** `text =` reads codes such as 250.10
  as written, in CSV and Excel files:
  `jload("visits.csv", text = Diag)`
* **What is new, when you update.** From your next update on, `jupdate()`
  prints these notes for each release it installs.

When something you typed before now stops, its message says what to type
instead.

Problems or suggestions: tell me, or open an issue at
https://github.com/jma61/jstats/issues.

# jstats 0.9.252

To the colleagues and students trying jstats before its CRAN release: thank
you. Here is what is new since the last release (0.9.223).

* **Quiet mode for scripts.** `joutput("silent")`, or `print = FALSE` on any
  analysis, fits a model or builds a table without printing it. Keep the
  result (`m <- jlm(...)`) and use it later.
* **Label a set of survey items in one call.**
  `jrelabel(d, c(Q1, Q2, Q3), labels = "1=Never; 2=Sometimes; 3=Often", modify = TRUE)`
* **New plots.** `type = "density"` beside the histogram, `facet =` for one
  panel per group, and the log-odds plot of a logistic regression,
  `jplot(m, which = "logit")`.
* **More in the model output.** Standardized coefficients in `jlogistic()`,
  Cramer's V in `jcrosstab(chisq = TRUE)`, and one VIF row for a categorical
  predictor.
* **Missing values on text variables.** `jdeclare_missing()` now declares
  codes such as `"UNKNOWN"`, or blank cells, on a text variable.
* **Loading files.** `jload()` reads the package's example files by name,
  skips title rows in Excel and CSV files (`skip =`), reads files with no
  names row (`header = FALSE`), and fixes variable names R cannot read,
  keeping the original as the label.
* **Clearer messages throughout.** Every line of code a message suggests now
  runs as printed.

Problems or suggestions: tell me, or open an issue at
https://github.com/jma61/jstats/issues.
