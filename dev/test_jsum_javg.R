# =============================================================================
# jsum() and javg() Test Script
# =============================================================================
# Run these tests in order using SampleData.
# =============================================================================

SampleData <- readRDS("../7036_2026/Data/7036CCJSampleData.rds")



juse(SampleData)

# -----------------------------------------------------------------------------
# TEST 1: Basic jsum with explicit variable names (all non-missing)
# EXPECT: Message "Sum of 6 variables computed for 800 cases."
#         Result is a numeric vector of length 800.
# -----------------------------------------------------------------------------
cat("==== TEST 1: Basic jsum ====\n")
SampleData$TestSum1 <- jsum(, Theft, Burglary, Assault, Drugs, Graffiti, Smoking)
jdesc(, TestSum1)


# -----------------------------------------------------------------------------
# TEST 2: jsum with colon notation for consecutive columns
# EXPECT: Same result as TEST 1 if those variables are consecutive,
#         or expands whatever range is specified.
#         Check your column order with names(SampleData) first.
# NOTE:   Adjust the variable names below if they are not consecutive
#         in your dataset. Sexism items should be consecutive.
# -----------------------------------------------------------------------------
cat("\n==== TEST 2: jsum with colon notation ====\n")
SampleData$SexismSum <- jsum(, Sexism1:Sexism6)
jdesc(, SexismSum)


# -----------------------------------------------------------------------------
# TEST 3: jsum with variables that have missing data (Group 6)
# EXPECT: Default behavior — cases with ANY missing get NA.
#         Message shows how many cases set to NA.
# -----------------------------------------------------------------------------
cat("\n==== TEST 3: jsum with missing data (default — all required) ====\n")
SampleData$TestSum3 <- jsum(, MathScore, EnglishScore, Education)
jdesc(, TestSum3)


# -----------------------------------------------------------------------------
# TEST 4: jsum with min.valid = 1 (lenient — at least 1 non-missing)
# EXPECT: Fewer NAs than TEST 3. Message shows partial data usage.
# -----------------------------------------------------------------------------
cat("\n==== TEST 4: jsum with min.valid = 1 ====\n")
SampleData$TestSum4 <- jsum(, MathScore, EnglishScore, Education, min.valid = 1)
jdesc(, TestSum4)


# -----------------------------------------------------------------------------
# TEST 5: jsum with min.valid = 2
# EXPECT: More NAs than TEST 4, fewer than TEST 3.
# -----------------------------------------------------------------------------
cat("\n==== TEST 5: jsum with min.valid = 2 ====\n")
SampleData$TestSum5 <- jsum(, MathScore, EnglishScore, Education, min.valid = 2)
jdesc(, TestSum5)


# -----------------------------------------------------------------------------
# TEST 6: jsum with custom variable label
# EXPECT: jdesc shows the custom label.
# -----------------------------------------------------------------------------
cat("\n==== TEST 6: jsum with custom var_label ====\n")
SampleData$TotalCrime <- jsum(, Theft, Burglary, Assault, Drugs, Graffiti, Smoking,
                              var_label = "Total Crime Index")
jdesc(, TotalCrime)


# -----------------------------------------------------------------------------
# TEST 7: jsum with auto-generated variable label
# EXPECT: jdesc shows "Sum of Theft, Burglary, ..." as the label.
# -----------------------------------------------------------------------------
cat("\n==== TEST 7: jsum auto-generated label ====\n")
SampleData$TestSum7 <- jsum(, Theft, Burglary, Assault)
jdesc(, TestSum7)


# -----------------------------------------------------------------------------
# TEST 8: jsum with haven-labelled items (Likert scale items)
# EXPECT: Works without warnings. Numeric codes are summed correctly.
# -----------------------------------------------------------------------------
cat("\n==== TEST 8: jsum with haven-labelled variables ====\n")
SampleData$ConservSum <- jsum(, Conservative1:Conservative6)
jdesc(, ConservSum)


# -----------------------------------------------------------------------------
# TEST 9: jsum with only 1 variable (should produce error)
# EXPECT: Error — "requires at least 2 variables"
# -----------------------------------------------------------------------------
cat("\n==== TEST 9: jsum with 1 variable (should error) ====\n")
tryCatch(
  jsum(, Theft),
  error = function(e) cat("Expected error:", conditionMessage(e), "\n")
)

## Errors here
SampleData$ConservSum <- jsum(, Sexism1:Sexism3, Sexism4R, Sexism5:Sexism6)

SampleData$ConservSum <- jsum(SampleData, Sexism1:Sexism3, Sexism4R, Sexism5:Sexism6)



# -----------------------------------------------------------------------------
# TEST 10: jsum with mix of explicit names and colon range
# EXPECT: Works — combines both specification methods.
# NOTE:   Adjust if Sexism items are not consecutive.
# -----------------------------------------------------------------------------
cat("\n==== TEST 10: Mixed explicit + colon notation ====\n")
SampleData$TestMixed <- jsum(, ReadingScore, Sexism1:Sexism6)
jdesc(, TestMixed)


# =============================================================================
# javg() TESTS
# =============================================================================

# -----------------------------------------------------------------------------
# TEST 11: Basic javg
# EXPECT: Message "Mean of 6 variables computed for 800 cases."
# -----------------------------------------------------------------------------
cat("\n==== TEST 11: Basic javg ====\n")
SampleData$TestAvg <- javg(, Theft, Burglary, Assault, Drugs, Graffiti, Smoking)
jdesc(, TestAvg)


# -----------------------------------------------------------------------------
# TEST 12: javg with colon notation
# EXPECT: Scale mean of the Sexism items.
# -----------------------------------------------------------------------------
cat("\n==== TEST 12: javg with colon notation ====\n")
SampleData$SexismMean <- javg(, Sexism1:Sexism6)
jdesc(, SexismMean)


# -----------------------------------------------------------------------------
# TEST 13: javg with missing data (default — all required)
# EXPECT: Cases with any missing get NA.
# -----------------------------------------------------------------------------
cat("\n==== TEST 13: javg with missing data (default) ====\n")
SampleData$TestAvg13 <- javg(, MathScore, EnglishScore, Education)
jdesc(, TestAvg13)


# -----------------------------------------------------------------------------
# TEST 14: javg with min.valid = 1 (flexible denominator — default)
# EXPECT: Mean adjusts denominator for each case based on non-missing count.
#         E.g. if 2 of 3 are non-missing, divides sum by 2.
# -----------------------------------------------------------------------------
cat("\n==== TEST 14: javg min.valid = 1, flexible denominator ====\n")
SampleData$TestAvg14 <- javg(, MathScore, EnglishScore, Education, min.valid = 1)
jdesc(, TestAvg14)


# -----------------------------------------------------------------------------
# TEST 15: javg with min.valid = 1 and fixed = TRUE
# EXPECT: Mean always divides by 3 (total variables), even when some are
#         missing. Means will be lower than TEST 14 for cases with missing data.
# -----------------------------------------------------------------------------
cat("\n==== TEST 15: javg min.valid = 1, fixed denominator ====\n")
SampleData$TestAvg15 <- javg(, MathScore, EnglishScore, Education,
                              min.valid = 1, fixed = TRUE)
jdesc(, TestAvg15)


# -----------------------------------------------------------------------------
# TEST 16: Compare TEST 14 vs TEST 15 for a case with missing data
# EXPECT: Where all 3 values are present, results are identical.
#         Where 1 or 2 are missing, TEST 15 values are lower.
# -----------------------------------------------------------------------------
cat("\n==== TEST 16: Compare flexible vs fixed denominator ====\n")
comparison <- data.frame(
  MathScore    = SampleData$MathScore[1:10],
  EnglishScore = SampleData$EnglishScore[1:10],
  Education    = SampleData$Education[1:10],
  FlexAvg      = round(SampleData$TestAvg14[1:10], 3),
  FixedAvg     = round(SampleData$TestAvg15[1:10], 3)
)
print(comparison)


# -----------------------------------------------------------------------------
# TEST 17: javg with custom variable label
# EXPECT: jdesc shows the custom label.
# -----------------------------------------------------------------------------
cat("\n==== TEST 17: javg with custom var_label ====\n")
SampleData$SexismMean <- javg(, Sexism1:Sexism6,
                               var_label = "Sexism Scale Mean")
jdesc(, SexismMean)


# -----------------------------------------------------------------------------
# TEST 18: min.valid exceeds number of variables (should error)
# EXPECT: Error — "min.valid (5) cannot exceed the number of variables (3)"
# -----------------------------------------------------------------------------
cat("\n==== TEST 18: min.valid too large (should error) ====\n")
tryCatch(
  jsum(, Theft, Burglary, Assault, min.valid = 5),
  error = function(e) cat("Expected error:", conditionMessage(e), "\n")
)


# -----------------------------------------------------------------------------
# TEST 19: Colon range with reversed order (should error)
# EXPECT: Error about column order.
# NOTE:   This only triggers if Sexism6 comes before Sexism1 in the data,
#         which it shouldn't. Adjust variable names as needed.
# -----------------------------------------------------------------------------
cat("\n==== TEST 19: Reversed colon range (should error) ====\n")
tryCatch(
  jsum(, Sexism6:Sexism1),
  error = function(e) cat("Expected error:", conditionMessage(e), "\n")
)


# -----------------------------------------------------------------------------
# TEST 20: jsum with explicit data frame argument (not juse default)
# EXPECT: Works the same way but uses specified data frame.
# -----------------------------------------------------------------------------
cat("\n==== TEST 20: Explicit data frame ====\n")
SampleData$TestExplicit <- jsum(SampleData, Theft, Burglary, Assault)
jdesc(, TestExplicit)


# -----------------------------------------------------------------------------
# Clean up test variables
# -----------------------------------------------------------------------------
cat("\n==== CLEANING UP ====\n")
test_cols <- c("TestSum1", "SexismSum", "TestSum3", "TestSum4", "TestSum5",
               "TotalCrime", "TestSum7", "ConservSum", "TestMixed",
               "TestAvg", "SexismMean", "TestAvg13", "TestAvg14",
               "TestAvg15", "TestExplicit")
SampleData[test_cols] <- NULL
cat("Test columns removed.\n")

cat("\n==== ALL TESTS COMPLETE ====\n")
