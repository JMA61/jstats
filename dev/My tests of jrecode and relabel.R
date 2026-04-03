

### To load the functions into the current session use
devtools::load_all()
devtools::document()

SampleData <- readRDS("../7036_2026/Data/7036CCJSampleData.rds")

?jdesc
jdesc(SampleData, Gender)
jfreq(SampleData, Gender)

SampleData$GenderR <- jrecode(SampleData, Gender, map = "2=0;1=1;else=copy")

jfreq(SampleData, Gender, GenderR)

?jrelabel



jfreq(SampleData, Gender, GenderR)


?jrecode
SampleData$GenderR <- jrecode(SampleData, Gender, map="2=0;1=1;else=copy",labels="1=Male;0=Female")


SampleData$NativeBornR <- jrecode(SampleData, NativeBorn, map = "2=0;1=1;else=copy")

jfreq(SampleData, NativeBornR, NativeBorn)


?jrelabel
jrelabel(SampleData, NativeBornR)

SampleData$NativeBornR <- jrelabel(SampleData, NativeBornR, labels = "1=Born Overseas; 0=Born in Australia")

jfreq(SampleData, NativeBorn, NativeBornR)

jfreq(SampleData, GenderR, Gender)


SampleData <- jrelabel(SampleData, Gender, GenderR)


SampleData <- jrelabel(SampleData, Gender, GenderR)


# =============================================================================
# Test Data for jrecode() and jrelabel() — v2
# =============================================================================
# Creates a single data frame (test_df) with diverse variable types to test
# both functions under normal use, edge cases, and error conditions.
#
# Requires: haven, labelled
# Run after: devtools::load_all() on the JeffsStatTools package
# =============================================================================

library(haven)
library(labelled)

set.seed(42)
n <- 20

test_df <- data.frame(row.names = 1:n)

# ---------------------------------------------------------------------------
# 1. Haven-labelled dichotomy coded 1/2 (mirrors Group 4 variables)
# ---------------------------------------------------------------------------
test_df$Veteran <- labelled::labelled(
  sample(1:2, n, replace = TRUE),
  labels = c("Yes" = 1, "No" = 2)
)
labelled::var_label(test_df$Veteran) <- "Veteran Status"

# ---------------------------------------------------------------------------
# 2. Haven-labelled multi-category variable (mirrors Group 5 variables)
# ---------------------------------------------------------------------------
test_df$Employment <- labelled::labelled(
  sample(1:4, n, replace = TRUE),
  labels = c("Full-time" = 1, "Part-time" = 2,
             "Unemployed" = 3, "Student" = 4)
)
labelled::var_label(test_df$Employment) <- "Employment Status"

# ---------------------------------------------------------------------------
# 3. Haven-labelled variable WITH missing values
# ---------------------------------------------------------------------------
crime_vals <- sample(1:2, n, replace = TRUE)
crime_vals[c(3, 7, 15)] <- NA
test_df$CrimeType <- labelled::labelled(
  crime_vals,
  labels = c("Violent" = 1, "Non-violent" = 2)
)
labelled::var_label(test_df$CrimeType) <- "Type of Crime"

# ---------------------------------------------------------------------------
# 4. Haven-labelled variable with NO value labels (only variable label)
# ---------------------------------------------------------------------------
test_df$Rating <- labelled::labelled(sample(1:5, n, replace = TRUE))
labelled::var_label(test_df$Rating) <- "Program Satisfaction Rating"

# ---------------------------------------------------------------------------
# 5. Plain numeric variable (no labels of any kind)
# ---------------------------------------------------------------------------
test_df$PlainNumeric <- sample(1:3, n, replace = TRUE)

# ---------------------------------------------------------------------------
# 6. Plain numeric dichotomy already coded 0/1
# ---------------------------------------------------------------------------
test_df$AlreadyRecoded <- sample(0:1, n, replace = TRUE)

# ---------------------------------------------------------------------------
# 7. Continuous/interval variable
# ---------------------------------------------------------------------------
test_df$Age <- round(rnorm(n, mean = 35, sd = 10), 1)

# ---------------------------------------------------------------------------
# 8. Factor with TEXT levels (should trigger errors)
# ---------------------------------------------------------------------------
test_df$TextFactor <- factor(
  sample(c("Red", "Blue", "Green"), n, replace = TRUE)
)

# ---------------------------------------------------------------------------
# 9. Factor with NUMERIC-LIKE levels
# ---------------------------------------------------------------------------
test_df$NumericFactor <- factor(sample(1:3, n, replace = TRUE))

# ---------------------------------------------------------------------------
# 10. Character variable with text values (should trigger errors)
# ---------------------------------------------------------------------------
test_df$CharText <- sample(c("Apple", "Banana", "Cherry"), n, replace = TRUE)

# ---------------------------------------------------------------------------
# 11. Character variable with numeric-like values
# ---------------------------------------------------------------------------
test_df$CharNumeric <- as.character(sample(1:4, n, replace = TRUE))

# ---------------------------------------------------------------------------
# 12. Logical/boolean variable
# ---------------------------------------------------------------------------
test_df$LogicalVar <- sample(c(TRUE, FALSE), n, replace = TRUE)

# ---------------------------------------------------------------------------
# 13. Variable with suspicious coded missing value: -99
# ---------------------------------------------------------------------------
suspicious_vals <- sample(1:5, n, replace = TRUE)
suspicious_vals[c(4, 12)] <- -99
test_df$WithCoded99 <- labelled::labelled(
  suspicious_vals,
  labels = c("Strongly Disagree" = 1, "Disagree" = 2, "Neutral" = 3,
             "Agree" = 4, "Strongly Agree" = 5)
)
labelled::var_label(test_df$WithCoded99) <- "Survey Item with -99"

# ---------------------------------------------------------------------------
# 14. Variable with suspicious coded missing value: -9
# ---------------------------------------------------------------------------
coded9_vals <- sample(1:3, n, replace = TRUE)
coded9_vals[c(2, 10)] <- -9
test_df$WithCoded9 <- labelled::labelled(
  coded9_vals,
  labels = c("Low" = 1, "Medium" = 2, "High" = 3)
)
labelled::var_label(test_df$WithCoded9) <- "Rating with -9"

# ---------------------------------------------------------------------------
# 15. Variable with suspicious high coded missing value: 999
# ---------------------------------------------------------------------------
coded999_vals <- sample(1:5, n, replace = TRUE)
coded999_vals[c(5, 18)] <- 999
test_df$WithCoded999 <- labelled::labelled(
  coded999_vals,
  labels = c("Strongly Disagree" = 1, "Disagree" = 2, "Neutral" = 3,
             "Agree" = 4, "Strongly Agree" = 5)
)
labelled::var_label(test_df$WithCoded999) <- "Survey Item with 999"

# ---------------------------------------------------------------------------
# 16. Haven-labelled Likert scale (5-point, clean)
# ---------------------------------------------------------------------------
test_df$LikertItem <- labelled::labelled(
  sample(1:5, n, replace = TRUE),
  labels = c("Strongly Oppose" = 1, "Oppose" = 2, "Neutral" = 3,
             "Support" = 4, "Strongly Support" = 5)
)
labelled::var_label(test_df$LikertItem) <- "Attitude Toward Policy"

# ---------------------------------------------------------------------------
# 17. Integer variable
# ---------------------------------------------------------------------------
test_df$IntegerVar <- as.integer(sample(1:3, n, replace = TRUE))


# =============================================================================
# Quick summary
# =============================================================================
cat("Test data frame created: test_df\n")
cat("Rows:", nrow(test_df), " Variables:", ncol(test_df), "\n\n")

cat("Variable types:\n")
for (v in names(test_df)) {
  cls <- paste(class(test_df[[v]]), collapse = ", ")
  vl  <- ""
  if (inherits(test_df[[v]], "haven_labelled")) {
    lab <- labelled::var_label(test_df[[v]])
    if (!is.null(lab)) vl <- paste0("  [", lab, "]")
  }
  cat(sprintf("  %-20s %s%s\n", v, cls, vl))
}


# =============================================================================
# Suggested tests
# =============================================================================

cat("\n===== JRECODE: Normal use =====\n\n")

cat("## One-to-one with explicit labels\n")
cat('test_df$VeteranR <- jrecode(test_df, Veteran, map = "1=1; 2=0", labels = "1=Yes; 0=No")\n')
cat('jfreq(test_df, VeteranR)\n\n')

cat("## One-to-one WITHOUT labels — auto-transfer should work\n")
cat('test_df$CrimeR <- jrecode(test_df, CrimeType, map = "1=1; 2=0")\n')
cat('jfreq(test_df, CrimeR)   ## expect: 1: Violent, 0: Non-violent\n\n')

cat("## Multi-category one-to-one — auto-transfer\n")
cat('test_df$EmpR <- jrecode(test_df, Employment, map = "1=10; 2=20; 3=30; 4=40")\n')
cat('jfreq(test_df, EmpR)   ## expect: labels remapped to 10/20/30/40\n\n')

cat("## Collapsing categories — must supply labels\n")
cat('test_df$EmpR2 <- jrecode(test_df, Employment, map = "1,2=1; 3,4=2", labels = "1=Employed; 2=Not Employed")\n')
cat('jfreq(test_df, EmpR2)\n\n')

cat("## Collapsing WITHOUT labels — should get collapsing note\n")
cat('test_df$EmpR3 <- jrecode(test_df, Employment, map = "1,2=1; 3,4=2")\n\n')


cat("===== JRECODE: else clause behavior =====\n\n")

cat("## No else clause, all values mapped — clean, no messages\n")
cat('test_df$VetR2 <- jrecode(test_df, Veteran, map = "1=1; 2=0")\n\n')

cat("## No else clause, values NOT all mapped — should STOP\n")
cat('test_df$EmpR4 <- jrecode(test_df, Employment, map = "1=1; 2=2")\n')
cat('## expect error: Value(s) 3, 4 in \'Employment\' were not in the map.\n\n')

cat("## Explicit else=NA, values not all mapped — runs, sets extras to NA\n")
cat('test_df$EmpR5 <- jrecode(test_df, Employment, map = "1=1; 2=2; else=NA")\n')
cat('jfreq(test_df, EmpR5)   ## 3 and 4 should be NA\n\n')

cat("## else=copy, values not all mapped — carries extras through\n")
cat('test_df$EmpR6 <- jrecode(test_df, Employment, map = "1=10; 2=20; else=copy")\n')
cat('jfreq(test_df, EmpR6)   ## 1->10, 2->20, 3 stays 3, 4 stays 4\n\n')


cat("===== JRECODE: Suspicious coded missing values =====\n\n")

cat("## -99 present, all real values mapped — note about -99 set to NA\n")
cat('test_df$Coded99R <- jrecode(test_df, WithCoded99, map = "1=1; 2=2; 3=3; 4=4; 5=5")\n')
cat('jfreq(test_df, Coded99R)\n\n')

cat("## -9 present, all real values mapped — note about -9 set to NA\n")
cat('test_df$Coded9R <- jrecode(test_df, WithCoded9, map = "1=1; 2=2; 3=3")\n')
cat('jfreq(test_df, Coded9R)\n\n')

cat("## 999 present, all real values mapped — note about 999 set to NA\n")
cat('test_df$Coded999R <- jrecode(test_df, WithCoded999, map = "1=1; 2=2; 3=3; 4=4; 5=5")\n')
cat('jfreq(test_df, Coded999R)\n\n')

cat("## -99 present with else=copy — -99 still forced to NA\n")
cat('test_df$Coded99R2 <- jrecode(test_df, WithCoded99, map = "1=1; 2=2; 3=3; 4=4; 5=5; else=copy")\n')
cat('jfreq(test_df, Coded99R2)\n\n')

cat("## -99 present, NOT all real values mapped, no else — should STOP\n")
cat('test_df$Coded99R3 <- jrecode(test_df, WithCoded99, map = "1=1; 2=2")\n')
cat('## expect error about unmapped values 3, 4, 5\n\n')

cat("## -99 present, NOT all real values mapped, else=copy\n")
cat('test_df$Coded99R4 <- jrecode(test_df, WithCoded99, map = "1=1; 2=2; else=copy")\n')
cat('## expect: 3,4,5 copied, -99 forced to NA with note\n\n')


cat("===== JRECODE: Variables that should be interesting =====\n\n")

cat("## Plain numeric — no labels to auto-transfer\n")
cat('test_df$PlainR <- jrecode(test_df, PlainNumeric, map = "1=1; 2=2; 3=3")\n')
cat('## expect: note about no value labels\n\n')

cat("## Logical variable\n")
cat('test_df$LogR <- jrecode(test_df, LogicalVar, map = "1=1; 0=0")\n\n')


cat("===== JRELABEL: Normal use =====\n\n")

cat("## Add both value labels and variable label\n")
cat('test_df$AlreadyRecoded <- jrelabel(test_df, AlreadyRecoded, labels = "1=Yes; 0=No", var_label = "Already Recoded Variable")\n')
cat('jfreq(test_df, AlreadyRecoded)\n\n')

cat("## Add value labels only\n")
cat('test_df$PlainR <- jrelabel(test_df, PlainR, labels = "1=Low; 2=Med; 3=High")\n\n')

cat("## Add variable label only\n")
cat('test_df$Age <- jrelabel(test_df, Age, var_label = "Age at Release")\n\n')

cat("## Overwrite existing labels silently\n")
cat('test_df$LikertItem <- jrelabel(test_df, LikertItem, labels = "1=SO; 2=O; 3=N; 4=S; 5=SS")\n')
cat('jfreq(test_df, LikertItem)\n\n')


cat("===== JRELABEL: Edge cases and errors =====\n\n")

cat("## Text factor — should error\n")
cat('jrelabel(test_df, TextFactor, labels = "1=A; 2=B")\n\n')

cat("## Character text — should error\n")
cat('jrelabel(test_df, CharText, labels = "1=A; 2=B")\n\n')

cat("## Character with numeric values — should work\n")
cat('test_df$CharNumeric <- jrelabel(test_df, CharNumeric, labels = "1=A; 2=B; 3=C; 4=D")\n\n')

cat("## Logical — should work (TRUE=1, FALSE=0)\n")
cat('test_df$LogicalVar <- jrelabel(test_df, LogicalVar, labels = "1=Yes; 0=No")\n\n')

cat("## Nonexistent variable — should error\n")
cat('jrelabel(test_df, FakeVar, labels = "1=A")\n\n')

########################################################

jfreq(test_df, Veteran, VeteranR)
jfreq(test_df, Veteran, )
jfreq(test_df, Veteran)

juse(test_df)
juse(NULL)
juse()

jfreq(, Veteran)
jfreq(test_df, Veteran)

jdesc(, Veteran)

test_df$VeteranR <- jrecode(test_df, Veteran, map = "1=1; 2=0")

jfreq(test_df, Veteran, VeteranR)
jfreq(, Veteran, VeteranR)
jfreq(test_df$Veteran, test_df$VeteranR)

test_df$VeteranR <- jrecode(test_df, Veteran, map = "1=1; 2=0", labels = "1=Yes; 0=No")
jfreq(test_df, Veteran, VeteranR)

jfreq(, Veteran, VeteranRR)


test_df$EmpR     <- jrecode(test_df, Employment, map = "1=1; 2=1; 3=2; 4=2", labels = "1=Employed; 2=Not Employed")
jfreq(test_df, Employment, EmpR)

test_df$EmpR     <- jrecode(test_df, Employment, map = "1=1; 2=1; 3=2; 4=2")
jfreq(test_df, Employment, EmpR)

test_df$CrimeR   <- jrecode(test_df, CrimeType, map = "1=1; 2=0")
jfreq(test_df, CrimeType, CrimeR)

test_df$EmpR4 <- jrecode(test_df, Employment, map = "1=1; 2=2")  # Throws Error - as expected.


test_df$EmpR5 <- jrecode(test_df, Employment, map = "1=1; 2=2; else=NA")
jfreq(test_df, Employment, EmpR5)

test_df$EmpR6 <- jrecode(test_df, Employment, map = "1=10; 2=20; else=copy")
jfreq(test_df, Employment, EmpR6)


test_df$Coded99R <- jrecode(test_df, WithCoded99, map = "1=1; 2=2; 3=3; 4=4; 5=5")
jfreq(test_df,WithCoded99, Coded99R)

test_df$Coded99R <- jrecode(test_df, WithCoded99, map = "1=1; 2=2; 3=3; 4=4; 5=5; -99=-99")
jfreq(test_df,WithCoded99, Coded99R)


juse(test_df)
jfreq(, Veteran, VeteranR)  ### Dataset name not printing. ### check that error that comes with devtools::check()

?juse



?jrecode

jrelabel(test_df, TextFactor, labels = "1=A; 2=B") ## should throw an error

jfreq(test_df$TextFactor)


test_df$PlainR   <- jrecode(test_df, PlainNumeric, map = "1=1; 2=2; 3=3", labels = "1=Low; 2=Med; 3=High")
jfreq(test_df, PlainNumeric, PlainR)

jfreq(test_df, WithCoded99)

test_df$SusR     <- jrecode(test_df, WithCoded99, map = "1=1; 2=2; 3=3; 4=4; 5=5")
jfreq(test_df, WithCoded99, SusR)




test_df$SusR     <- jrecode(test_df, WithCoded99, map = "1=1; 2=2; 3=3; 4=4; 5=5; else=copy")
jfreq(test_df, WithCoded99, SusR)

jlm(JuvenileDelinquency ~ Gender, data = SampleData)

juse(SampleData)
?jalpha

jalpha(SampleData, Conservative1,Conservative2, Conservative3, Conservative4, Conservative5, Conservative6)
jfreq(, Conservative3)

SampleData$Conservative3R <- jrecode(SampleData, Conservative3, map = "1=5; 2=4; 3=3; 4=2; 5=1; else=copy")
jrecode(SampleData, Conservative3, map = "1=5; 2=4; 3=3; 4=2; 5=1; else=copy")

jfreq(, Conservative3, Conservative3R)

Conservative3R <- jrecode(SampleData, Conservative3, map = "1=5; 2=4; 3=3; 4=2; 5=1; else=copy")

jt(JuvenileDelinquency ~ Gender,)

jaov(JuvenileDelinquency ~ Gender,)

jdesc(,JuvenileDelinquency)

?jcorr

jcorr(,JuvenileDelinquency, MathScore, ReadingScore)

jcorr(,JuvenileDelinquency, MathScore, ReadingScore, method = "spearman")

jcorr(mtcars, mpg, hp, wt, method = "spearman")

jcorr(,JuvenileDelinquency, MathScore, ReadingScore, method = "kendall")


jcorr(,JuvenileDelinquency, MathScore, ReadingScore, labels=FALSE)

?jchisq
jchisq(Gender ~ Firearm)
jchisq(Gender ~ Firearm, col.pct = TRUE)

jscreen()
?jscreen

jfreq(SampleData,Gender)
jfreq(,Gender)

?jrecode

SampleData$GenderR <- jrecode(SampleData, Gender,
                              map    = "2=0; else=copy")

jfreq(,GenderR  )


SampleData$GenderR <- jrecode(SampleData, Gender,
                     map    = "2=0; else=copy",
                     labels = "1=Three gears")

SampleData$GenderR <- jrelabel(, GenderR, labels = "0=A;1=Test;2=B")
jfreq(,GenderR  )






