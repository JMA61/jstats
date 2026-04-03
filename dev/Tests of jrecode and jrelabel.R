

# =============================================================================
# TEST CASES
# =============================================================================
# Run this section interactively to verify both functions behave correctly.
# Each test is labelled with what it checks and what you should expect to see.
# Install the labelled package first if needed: install.packages("labelled")
# =============================================================================

if (TRUE) {   # <-- Change FALSE to TRUE to run all tests

  library(labelled)

  # ---------------------------------------------------------------------------
  # Build test data frame that mimics a typical haven-imported SPSS dataset
  # ---------------------------------------------------------------------------

  set.seed(42)
  n <- 20

  test_data <- data.frame(
    Gender     = c(1, 2, 1, 1, 2, 2, 1, 2, 1, 2, 1, 1, 2, 2, 1, 2, 1, 2, 1, 2),
    ScaleItem3 = c(1, 2, 3, 4, 5, 3, 2, 1, 4, 5, 3, 2, 4, 1, 5, 3, 2, 4, 1, 5),
    AgeGroup   = c(1, 2, 3, 4, 5, 1, 3, 5, 2, 4, 1, 2, 3, 4, 5, 2, 3, 1, 4, 5),
    Status     = c(1, 2, 3, 1, 2, 3, 1, 2, 1, 3, 2, 1, 3, 2, 1, 3, 2, 1, 2, 3),
    PlainNum   = c(1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2),
    WithNA     = c(1, 2, NA, 1, 2, NA, 1, 2, 1, 2, NA, 1, 2, 1, NA, 2, 1, 2, 1, 2),
    Suspicious = c(1, 2, 3, 4, 5, 1, 2, 3, 4, 5, 1, 2, 3, 4, 5, -99, 1, 2, 3, 4),
    stringsAsFactors = FALSE
  )

  # Add haven_labelled attributes to Gender and ScaleItem3
  test_data$Gender <- labelled::labelled(
    test_data$Gender,
    labels   = c("Male" = 1, "Female" = 2),
    label    = "Respondent Gender"
  )

  test_data$ScaleItem3 <- labelled::labelled(
    test_data$ScaleItem3,
    labels = c("Strongly Disagree" = 1, "Disagree" = 2, "Neutral" = 3,
               "Agree" = 4, "Strongly Agree" = 5),
    label  = "Scale Item 3: I feel confident using R"
  )

  test_data$AgeGroup <- labelled::labelled(
    test_data$AgeGroup,
    labels = c("18-24" = 1, "25-34" = 2, "35-44" = 3, "45-54" = 4, "55+" = 5),
    label  = "Age Group"
  )

  test_data$Status <- labelled::labelled(
    test_data$Status,
    labels = c("Full-time" = 1, "Part-time" = 2, "Casual" = 3),
    label  = "Employment Status"
  )

  # ---------------------------------------------------------------------------
  # TEST 1: jrelabel() — clean 1/2 to 1/0 recode (haven_labelled)
  # EXPECT: GenderR has values 0 and 1. Variable label = "Respondent Gender (recoded)".
  #         Value labels: "Male"=1, "Female"=0. jfreq counts match Gender counts.
  # ---------------------------------------------------------------------------
  cat("\n--- TEST 1: jrelabel clean 1/2 to 1/0 ---\n")
  test_data$GenderR <- ifelse(test_data$Gender == 2, 0, 1)
  test_data <- jrelabel(test_data, Gender, GenderR)
  cat("Variable label:", labelled::var_label(test_data$GenderR), "\n")
  print(labelled::val_labels(test_data$GenderR))
  cat("Values:", table(test_data$GenderR), "\n")


  # ---------------------------------------------------------------------------
  # TEST 2: jrelabel() — reverse coding detected (should NOT transfer labels)
  # EXPECT: ScaleItem3R has values 1-5 reversed. Variable label applied.
  #         A message about reverse coding detected. No value labels assigned.
  # ---------------------------------------------------------------------------
  cat("\n--- TEST 2: jrelabel reverse coding detected ---\n")
  test_data$ScaleItem3R <- 6 - test_data$ScaleItem3
  test_data <- jrelabel(test_data, ScaleItem3, ScaleItem3R)
  cat("Variable label:", labelled::var_label(test_data$ScaleItem3R), "\n")
  cat("Value labels (should be NULL):", "\n")
  print(labelled::val_labels(test_data$ScaleItem3R))


  # ---------------------------------------------------------------------------
  # TEST 3: jrelabel() — plain numeric variable (no existing labels)
  # EXPECT: Variable label = "PlainNum (recoded)". No value labels. No error.
  # ---------------------------------------------------------------------------
  cat("\n--- TEST 3: jrelabel plain numeric, no labels ---\n")
  test_data$PlainNumR <- ifelse(test_data$PlainNum == 2, 0, 1)
  test_data <- jrelabel(test_data, PlainNum, PlainNumR)
  cat("Variable label:", labelled::var_label(test_data$PlainNumR), "\n")
  cat("Value labels (should be NULL):\n")
  print(labelled::val_labels(test_data$PlainNumR))


  # ---------------------------------------------------------------------------
  # TEST 4: jrelabel() — collapsing detected
  # We manually create a collapsing scenario to trigger the message.
  # EXPECT: A message about collapsing. No value labels assigned.
  # ---------------------------------------------------------------------------
  cat("\n--- TEST 4: jrelabel collapsing detected ---\n")
  test_data$AgeGroupCollapsed <- ifelse(test_data$AgeGroup <= 3, 1, 2)
  test_data <- jrelabel(test_data, AgeGroup, AgeGroupCollapsed)
  cat("Value labels (should be NULL):\n")
  print(labelled::val_labels(test_data$AgeGroupCollapsed))


  # ---------------------------------------------------------------------------
  # TEST 5: jrelabel() — new variable does not exist yet
  # EXPECT: A clear error message saying to run the recode line first.
  # ---------------------------------------------------------------------------
  cat("\n--- TEST 5: jrelabel new variable does not exist ---\n")
  tryCatch(
    jrelabel(test_data, Gender, NonExistentVar),
    error = function(e) cat("Correctly caught error:", conditionMessage(e), "\n")
  )


  # ---------------------------------------------------------------------------
  # TEST 6: jrelabel() — original variable does not exist
  # EXPECT: A clear error message about the original variable not being found.
  # ---------------------------------------------------------------------------
  cat("\n--- TEST 6: jrelabel original variable not found ---\n")
  tryCatch(
    jrelabel(test_data, NoSuchVar, GenderR),
    error = function(e) cat("Correctly caught error:", conditionMessage(e), "\n")
  )


  # ---------------------------------------------------------------------------
  # TEST 7: jrelabel() — NA values in original variable
  # EXPECT: NAs in WithNA are preserved as NAs in WithNAR. No errors.
  # ---------------------------------------------------------------------------
  cat("\n--- TEST 7: jrelabel with NA values ---\n")
  test_data$WithNAR <- ifelse(test_data$WithNA == 2, 0, test_data$WithNA)
  test_data <- jrelabel(test_data, WithNA, WithNAR)
  cat("Original NA count:", sum(is.na(test_data$WithNA)), "\n")
  cat("Recoded NA count:", sum(is.na(test_data$WithNAR)), "\n")


  # ---------------------------------------------------------------------------
  # TEST 8: jrecode() — collapsing recode with labels specified
  # EXPECT: AgeGroupR has values 1, 2, 3. Variable label applied.
  #         Value labels: Young=1, Middle Aged=2, Older=3. No warning messages.
  # ---------------------------------------------------------------------------
  cat("\n--- TEST 8: jrecode collapsing with labels ---\n")
  test_data$AgeGroupR <- jrecode(test_data, AgeGroup,
                                 map    = "1=1; 2,3=2; 4,5=3; else=NA",
                                 labels = "1=Young; 2=Middle Aged; 3=Older")
  cat("Variable label:", labelled::var_label(test_data$AgeGroupR), "\n")
  print(labelled::val_labels(test_data$AgeGroupR))
  cat("Value counts:\n")
  print(table(test_data$AgeGroupR))


  # ---------------------------------------------------------------------------
  # TEST 9: jrecode() — collapsing recode WITHOUT labels
  # EXPECT: AgeGroupR2 has values 1, 2, 3. A reminder message about labels.
  # ---------------------------------------------------------------------------
  cat("\n--- TEST 9: jrecode without labels (reminder message expected) ---\n")
  test_data$AgeGroupR2 <- jrecode(test_data, AgeGroup,
                                  map = "1=1; 2,3=2; 4,5=3; else=NA")
  cat("Value labels (should be NULL):\n")
  print(labelled::val_labels(test_data$AgeGroupR2))


  # ---------------------------------------------------------------------------
  # TEST 10: jrecode() — else=copy carries unspecified values across
  # EXPECT: StatusR has 1 and 0, and 3s are copied unchanged. No NA message.
  # ---------------------------------------------------------------------------
  cat("\n--- TEST 10: jrecode else=copy ---\n")
  test_data$StatusR <- jrecode(test_data, Status,
                               map    = "1=1; 2=0; else=copy",
                               labels = "1=Yes; 0=No")
  cat("Values in StatusR (3 should still appear):\n")
  print(table(test_data$StatusR))


  # ---------------------------------------------------------------------------
  # TEST 11: jrecode() — else=NA default, unspecified values message
  # EXPECT: StatusR2 has 1 and 0, and 3s become NA. Message about value 3.
  # ---------------------------------------------------------------------------
  cat("\n--- TEST 11: jrecode else=NA default, unspecified values message ---\n")
  test_data$StatusR2 <- jrecode(test_data, Status,
                                map    = "1=1; 2=0",
                                labels = "1=Yes; 0=No")
  cat("NA count in StatusR2 (should match count of 3s in Status):\n")
  cat("3s in Status:", sum(test_data$Status == 3, na.rm = TRUE), "\n")
  cat("NAs in StatusR2:", sum(is.na(test_data$StatusR2)), "\n")


  # ---------------------------------------------------------------------------
  # TEST 12: jrecode() — map value not found in data
  # EXPECT: A warning that value 9 was specified but not found in AgeGroup.
  # ---------------------------------------------------------------------------
  cat("\n--- TEST 12: jrecode map value not in data ---\n")
  test_data$AgeGroupR3 <- jrecode(test_data, AgeGroup,
                                  map    = "1=1; 2,3=2; 4,5=3; 9=9; else=NA",
                                  labels = "1=Young; 2=Middle Aged; 3=Older; 9=Unknown")


  # ---------------------------------------------------------------------------
  # TEST 13: jrecode() — malformed map string
  # EXPECT: A clear error message describing the problem.
  # ---------------------------------------------------------------------------
  cat("\n--- TEST 13: jrecode malformed map string ---\n")
  tryCatch(
    jrecode(test_data, AgeGroup, map = "1=1; 2,3; 4,5=3"),
    error = function(e) cat("Correctly caught error:", conditionMessage(e), "\n")
  )


  # ---------------------------------------------------------------------------
  # TEST 14: jrecode() — suspicious coded missing value detected
  # EXPECT: A note about -99 being far outside the main range (1 to 5).
  # ---------------------------------------------------------------------------
  cat("\n--- TEST 14: jrecode suspicious coded missing value ---\n")
  test_data$SuspiciousR <- jrecode(test_data, Suspicious,
                                   map    = "1=1; 2=2; 3=3; 4=4; 5=5; else=NA",
                                   labels = "1=Very Low; 2=Low; 3=Medium; 4=High; 5=Very High")


  # ---------------------------------------------------------------------------
  # TEST 15: jrecode() — NA values in original variable
  # EXPECT: NAs in WithNA are preserved as NAs in WithNAR2. No errors.
  # ---------------------------------------------------------------------------
  cat("\n--- TEST 15: jrecode with NA values ---\n")
  test_data$WithNAR2 <- jrecode(test_data, WithNA,
                                map    = "1=1; 2=0; else=NA",
                                labels = "1=Yes; 0=No")
  cat("Original NA count:", sum(is.na(test_data$WithNA)), "\n")
  cat("Recoded NA count:", sum(is.na(test_data$WithNAR2)), "\n")

  cat("\n--- All tests complete ---\n")

}  # end if(FALSE)
