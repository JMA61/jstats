SampleData <- readRDS("../7036_2026/Data/7036CCJSampleData.rds")

library(haven)
library(labelled)

# Create test data
TestData <- data.frame(
  GenderR   = c(0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1),
  CrimeType = c(0, 1, 1, 0, 0, 1, -5, 1, 0, 0, 1, 1, -5, 0, -5, 1, 0, 1, 0, 1)
)

# Add value labels
TestData$GenderR <- labelled(
  TestData$GenderR,
  labels = c(Male = 0, Female = 1)
)

TestData$CrimeType <- labelled(
  TestData$CrimeType,
  labels = c("No Offense" = 0, "Offense" = 1, "missing" = -5)
)

# Variable labels (what jdesc/jfreq show as the descriptive label)
var_label(TestData$GenderR)   <- "Gender (recoded)"
var_label(TestData$CrimeType) <- "Type of crime"

# Verify structure
str(TestData)
table(TestData$CrimeType, useNA = "ifany")
attributes(TestData$CrimeType)

# Set as default data frame
juse(TestData)

# Now run the test — should trigger the coded-missing detection
jlogistic(CrimeType ~ GenderR)

TestData$CrimeTypeR <- jrecode(, CrimeType, map = "-5=NA; else=copy")

jfreq(,CrimeTypeR)


joutput("minimal")

jlogistic(CrimeTypeR ~ GenderR)
# =============================================================================
# Session 5 Testing Code
# =============================================================================

# --- Setup -------------------------------------------------------------------
library(JeffsStatTools)
# SampleData and PopulationData should auto-load via .Rprofile

juse(SampleData)

# =============================================================================
# jlogistic() — new function
# =============================================================================

# --- DV validation: 1/2 coding should produce helpful error ---
# Gender is coded 1/2 — should stop with jrecode() suggestion
jlogistic(Gender ~ SelfControl)

SampleData$GenderR <- jrecode(, Gender, map = "1=0; 2=1", labels = "0=Male; 1=Female")
jlogistic(GenderR ~ SelfControl)


juse(SampleData)
jfreq(,Gender, GenderR)


# --- DV validation: coded missing values should be detected ---
# If CrimeType has -5 values, should suggest jrecode with NA mapping
jlogistic(CrimeType ~ SelfControl)

jfreq(,CrimeType)

# --- Fix the 1/2 coding as the error message suggests ---
SampleData$GenderR <- jrecode(, Gender, map = "1=0; 2=1",
                              labels = "0=Male; 1=Female")

# --- Fix coded missings using the new value=NA syntax ---
SampleData$CrimeTypeR <- jrecode(, CrimeType, map = "-5=NA; else=copy")

# --- Basic logistic regression ---
jlogistic(GenderR ~ SelfControl)

# --- Multiple predictors ---
jlogistic(GenderR ~ SelfControl + ReadingScore + Height)

# --- With 95% CIs for Exp(B) ---
jlogistic(GenderR ~ SelfControl + ReadingScore, ci = TRUE)

# --- With classification table ---
jlogistic(GenderR ~ SelfControl + ReadingScore, classification = TRUE)

# --- Everything at once (ci, classification, diagnostics) ---
jlogistic(GenderR ~ SelfControl + ReadingScore, full = TRUE)

# --- Check return object structure ---
result <- jlogistic(GenderR ~ SelfControl + ReadingScore, full = TRUE)
class(result)              # Should be "jst_logistic"
names(result)              # Should list all components including vif, sample_info
result$nagelkerke_r2
result$predicts            # Should say "Female" (from haven labels)
result$vif                 # Named numeric vector


# =============================================================================
# jrecode() — new "value=NA" map syntax
# =============================================================================

# --- Map a single value to NA ---
SampleData$Test1 <- jrecode(, Education, map = "-5=NA; else=copy")

# --- Map multiple values to NA ---
SampleData$Test2 <- jrecode(, MathScore, map = "-5=NA; -99=NA; else=copy")

# --- Mix value=NA with regular recodes ---
SampleData$Test3 <- jrecode(, Employment, map = "1=1; 2=2; 3=2; 4=3; -5=NA")

# --- Verify NA mapping worked ---
table(SampleData$Test1, useNA = "ifany")
table(SampleData$Education, useNA = "ifany")  # Compare to original


# =============================================================================
# jlm() diagnostics
# =============================================================================

# --- Basic regression, no diagnostics (default) ---
jlm(JuvenileDelinquency ~ SelfControl + ReadingScore)

# --- Full diagnostics ---
jlm(JuvenileDelinquency ~ SelfControl + ReadingScore, diagnostics = TRUE)
# Should see: VIF table + 5 plots with console message listing them

# --- Specific diagnostics only ---
jlm(JuvenileDelinquency ~ SelfControl + ReadingScore,
    diagnostics = c("vif", "qq"))

# --- VIF only (no plots) ---
jlm(JuvenileDelinquency ~ SelfControl + ReadingScore, diagnostics = "vif")

# --- Bivariate model: VIF silently skipped (not meaningful with 1 predictor) ---
jlm(JuvenileDelinquency ~ SelfControl, diagnostics = TRUE)

# --- full = TRUE shortcut ---
jlm(JuvenileDelinquency ~ SelfControl + ReadingScore, full = TRUE)

# --- VIF stored in return object ---
model <- jlm(JuvenileDelinquency ~ SelfControl + ReadingScore + Muscularity,
             diagnostics = TRUE)
model$vif

# --- Test high VIF warning (if Muscularity correlates with a body measure) ---
jlm(JuvenileDelinquency ~ Muscularity + ShoeSize + EyeDistance + KneeCapHeight,
    diagnostics = TRUE)


# =============================================================================
# joutput() — session-level output control
# =============================================================================

# --- Check current settings ---
joutput()

# --- Minimal (default) ---
joutput("minimal")
jt(SelfControl ~ GenderR)              # Core results only

# --- Standard: adds effect sizes and CIs ---
joutput("standard")
jt(SelfControl ~ GenderR)              # Now shows Cohen's d + CI

# --- Full: everything ---
joutput("full")
jt(SelfControl ~ GenderR)              # Effect size, CI, Levene's, missing detail
jaov(SelfControl ~ Employment)         # Adds posthoc too
jlm(JuvenileDelinquency ~ SelfControl + ReadingScore)  # Adds diagnostics

# --- Level with toggle override ---
joutput("minimal", ci = TRUE)           # Minimal + CIs only
jt(SelfControl ~ GenderR)

# --- Per-call override wins ---
joutput("full")
jt(SelfControl ~ GenderR, effect.size = FALSE)  # Everything EXCEPT effect size

# --- Reset to defaults ---
joutput(NULL)
joutput()                               # Confirm reset


# =============================================================================
# Levene's interpretive note (NEW in Session 5)
# =============================================================================

# --- Balanced groups with significant Levene's ---
# Should produce: "Note: Levene's test is significant (p = X), but group sizes
#                  are approximately equal so the standard test remains appropriate."
jt(SelfControl ~ GenderR, levene = TRUE)

# --- Unbalanced groups with significant Levene's ---
# Example using a variable where groups differ in size substantially
# Should produce: "Note: Levene's test is significant (p = X), suggesting
#                  unequal variances. With unequal group sizes this may affect
#                  results — consider welch = TRUE."
jt(ReadingScore ~ Veteran, levene = TRUE)  # If Veteran is heavily unbalanced

# --- No note when welch already active ---
jt(ReadingScore ~ Veteran, levene = TRUE, welch = TRUE)
# Shows Levene's table but no interpretive note

# --- No note when Levene's is non-significant ---
# Table alone appears, no commentary
jt(Height ~ GenderR, levene = TRUE)  # Likely non-significant

# --- Same logic in jaov() ---
jaov(SelfControl ~ Employment, levene = TRUE)


# =============================================================================
# S3 class integration (Session 3 groundwork)
# =============================================================================

# --- Every analysis function now returns classed objects ---
t_result   <- jt(SelfControl ~ GenderR)
a_result   <- jaov(SelfControl ~ Employment)
lm_result  <- jlm(JuvenileDelinquency ~ SelfControl + ReadingScore)
log_result <- jlogistic(GenderR ~ SelfControl)
cor_result <- jcorr(SelfControl, ReadingScore, Height)
chi_result <- jcrosstab(GenderR ~ Employment)
desc_result <- jdesc(SelfControl, ReadingScore)
freq_result <- jfreq(Employment)
alpha_result <- jalpha(Conservatism1, Conservatism2, Conservatism3,
                       Conservatism4, Conservatism5, Conservatism6)

class(t_result)    # "jst_ttest"
class(a_result)    # "jst_anova"
class(lm_result)   # "jst_lm"
class(log_result)  # "jst_logistic"
class(cor_result)  # "jst_corr"
class(chi_result)  # "jst_chisq"
class(desc_result) # "jst_desc"
class(freq_result) # "jst_freq"
class(alpha_result) # "jst_alpha"

# --- All have sample_info block ---
t_result$sample_info
lm_result$sample_info


# =============================================================================
# Cleanup
# =============================================================================

joutput(NULL)  # Reset to defaults
