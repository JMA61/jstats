# =============================================================================
# jlm() Test Script — Variable Type Handling
# =============================================================================
# Run these tests in order using SampleData.
# Each test is labeled with what it's checking and what you should see.
# =============================================================================

# =============================================================================
# jlm() Test Script — Variable Type Handling
# =============================================================================
# Run these tests in order using SampleData.
# Each test is labeled with what it's checking and what you should see.
# =============================================================================

juse(SampleData)

# -----------------------------------------------------------------------------
# TEST 1: Baseline — all continuous IVs, no categorical issues
# EXPECT: Standard output, no reference category messages
# -----------------------------------------------------------------------------
cat("==== TEST 1: All continuous IVs ====\n")
jlm(Recidivism ~ ReadingScore + SelfControl)


# -----------------------------------------------------------------------------
# TEST 2: Auto-detection of categorical IV with value labels
# EXPECT: Employment auto-detected as categorical, reference category shown,
#         informational message suggesting jdummy() and numeric override
# -----------------------------------------------------------------------------
cat("\n==== TEST 2: Auto-detected categorical (Employment has value labels) ====\n")
jlm(Recidivism ~ ReadingScore + Employment)


# -----------------------------------------------------------------------------
# TEST 3: Multiple auto-detected categoricals
# EXPECT: Both Employment and Gender auto-detected, both references shown
# -----------------------------------------------------------------------------
cat("\n==== TEST 3: Multiple auto-detected categoricals ====\n")
jlm(Recidivism ~ ReadingScore + Employment + Gender)


# -----------------------------------------------------------------------------
# TEST 4: Using jdummy() to register Employment, then run jlm()
# EXPECT: Employment expanded via jdummy registration, reference shown
#         under "Reference categories" with NO auto-detection message
# -----------------------------------------------------------------------------
cat("\n==== TEST 4: jdummy() registered variable ====\n")
jdummy(, Employment, ref = "Full-Time")
jlm(Recidivism ~ ReadingScore + Employment)
jdummy(, Employment, remove = TRUE)  ## Clean up


# -----------------------------------------------------------------------------
# TEST 5: Mix of jdummy() registered and auto-detected
# EXPECT: Employment uses jdummy reference (Full-Time),
#         Gender auto-detected with its own reference
# -----------------------------------------------------------------------------
cat("\n==== TEST 5: Mix of jdummy registered + auto-detected ====\n")
jdummy(, Employment, ref = "Full-Time")
jlm(Recidivism ~ ReadingScore + Employment + Gender)
jdummy(, Employment, remove = TRUE)  ## Clean up


# -----------------------------------------------------------------------------
# TEST 6: numeric override — force a labelled variable to be numeric
# EXPECT: Gender treated as numeric (codes 1, 2 enter as a continuous
#         predictor). No reference category message for Gender.
#         This is statistically wrong for Gender but tests the override.
# -----------------------------------------------------------------------------
cat("\n==== TEST 6: numeric override (Gender forced to numeric) ====\n")
jlm(Recidivism ~ ReadingScore + Gender, numeric = "Gender")


# -----------------------------------------------------------------------------
# TEST 7: categorical override — force a plain numeric to categorical
# EXPECT: Program treated as categorical with first sorted value as
#         reference. Message about categorical argument shown.
#         (Program has value labels so it would auto-detect anyway —
#         this confirms the override path works)
# -----------------------------------------------------------------------------
cat("\n==== TEST 7: categorical override ====\n")
jlm(Recidivism ~ ReadingScore + Program, categorical = "Program")


# -----------------------------------------------------------------------------
# TEST 8: Multiple overrides at once
# EXPECT: Gender forced numeric, Program forced categorical
# -----------------------------------------------------------------------------
cat("\n==== TEST 8: Multiple overrides ====\n")
jlm(Recidivism ~ ReadingScore + Gender + Program,
    numeric = "Gender", categorical = "Program")


# -----------------------------------------------------------------------------
# TEST 9: numeric override on multiple variables
# EXPECT: Both Gender and Employment treated as numeric (codes entered
#         as continuous predictors). No reference categories shown for either.
# -----------------------------------------------------------------------------
cat("\n==== TEST 9: Multiple numeric overrides ====\n")
jlm(Recidivism ~ ReadingScore + Gender + Employment,
    numeric = c("Gender", "Employment"))


# -----------------------------------------------------------------------------
# TEST 10: Conflict — same variable in both numeric and categorical
# EXPECT: Error message about conflict
# -----------------------------------------------------------------------------
cat("\n==== TEST 10: Conflict (should produce an error) ====\n")
jlm(Recidivism ~ ReadingScore + Gender,
    numeric = "Gender", categorical = "Gender")

# -----------------------------------------------------------------------------
# TEST 11: Invalid variable name in numeric override
# EXPECT: Warning about 'FakeVar' not found, then runs normally
# -----------------------------------------------------------------------------
cat("\n==== TEST 11: Invalid variable in numeric override ====\n")
jlm(Recidivism ~ ReadingScore + Employment, numeric = "FakeVar")


# -----------------------------------------------------------------------------
# TEST 12: Haven-labelled continuous IV (has variable label but NO value
#          labels — e.g. ReadingScore, SelfControl)
# EXPECT: Treated as numeric automatically. No categorical message.
# -----------------------------------------------------------------------------
cat("\n==== TEST 12: Haven-labelled continuous (no value labels) ====\n")
jlm(Recidivism ~ ReadingScore + SelfControl + Friends)


# -----------------------------------------------------------------------------
# TEST 13: DV that is haven-labelled — should always become numeric
# EXPECT: Works normally even if DV has value labels
# -----------------------------------------------------------------------------
cat("\n==== TEST 13: Haven-labelled DV ====\n")
jlm(Gender ~ ReadingScore + Height + Weight, numeric = "Gender")
## Note: Gender as DV is always forced numeric regardless of the
## numeric argument — the numeric argument only affects IVs.
## Including it here just to be explicit; try without it too:
jlm(Gender ~ ReadingScore + Height + Weight)


# -----------------------------------------------------------------------------
# TEST 14: Adjusted R-squared check
# EXPECT: Both R-squared and Adjusted R-squared displayed on same line
# -----------------------------------------------------------------------------
cat("\n==== TEST 14: Adjusted R-squared display ====\n")
jlm(Recidivism ~ ReadingScore + SelfControl + Friends + Tattoos)


# -----------------------------------------------------------------------------
# TEST 15: jdummy with categorical override on different variables
# EXPECT: Employment expanded via jdummy (ref = Unemployed),
#         Residence forced categorical via argument,
#         both reference categories shown with appropriate messages
# -----------------------------------------------------------------------------
cat("\n==== TEST 15: jdummy + categorical on different variables ====\n")
jdummy(, Employment, ref = "Unemployed")
jlm(Recidivism ~ ReadingScore + Employment + Residence,
    categorical = "Residence")
jdummy(, Employment, remove = TRUE)  ## Clean up


# -----------------------------------------------------------------------------
# TEST 16: Return value inspection
# EXPECT: List with model_type = "linear", model_frame, formula_used,
#         adj_r_squared, dummy_coef_names, ref_cats all present
# -----------------------------------------------------------------------------
cat("\n==== TEST 16: Return value structure ====\n")
jdummy(, Employment, ref = "Full-Time")
result <- jlm(Recidivism ~ ReadingScore + Employment + Gender)
cat("\nReturn value components:\n")
cat("  model_type:      ", result$model_type, "\n")
cat("  adj_r_squared:   ", result$adj_r_squared, "\n")
cat("  n:               ", result$n, "\n")
cat("  formula_used:    ", deparse(result$formula_used), "\n")
cat("  dummy_coef_names:", paste(result$dummy_coef_names, collapse = ", "), "\n")
cat("  ref_cats:        ", paste(result$ref_cats, collapse = ", "), "\n")
cat("  model_frame dim: ", nrow(result$model_frame), "x",
    ncol(result$model_frame), "\n")
jdummy(, Employment, remove = TRUE)  ## Clean up
jdummy(NULL)                         ## Clear all registrations


cat("\n==== ALL TESTS COMPLETE ====\n")
