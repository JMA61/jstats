
SampleData <- readRDS("../7036_2026/Data/7036CCJSampleData.rds")


juse(SampleData)

# Basic — no diagnostics (default minimal)
jlm(JuvenileDelinquency ~ SelfControl + ReadingScore)

# Per-call diagnostics — all 6
jlm(JuvenileDelinquency ~ SelfControl + ReadingScore, diagnostics = TRUE)

# Specific diagnostics only
jlm(JuvenileDelinquency ~ SelfControl + ReadingScore, diagnostics = c("vif", "qq"))

# Via joutput
joutput("full")
jlm(JuvenileDelinquency ~ SelfControl + ReadingScore)  # VIF + 5 plots automatically

# Suppress diagnostics even with full
jlm(JuvenileDelinquency ~ SelfControl + ReadingScore, diagnostics = FALSE)

# full shortcut on jlm
jlm(JuvenileDelinquency ~ SelfControl + ReadingScore, full = TRUE)

# Bivariate — VIF silently skipped (not meaningful with 1 predictor)
jlm(JuvenileDelinquency ~ SelfControl, diagnostics = TRUE)

# Check VIF in return object
result <- jlm(JuvenileDelinquency ~ SelfControl + ReadingScore, diagnostics = TRUE)
result$vif
