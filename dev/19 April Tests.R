library(JeffsStatTools)
juse(SampleData)

# ---- Plot type coverage via variable-list form (distributions) ----
jplot(, Age)                                # histogram, 1 numeric
jplot(, Gender)                             # bar chart, 1 categorical
jplot(, Conservative1)                      # bar or histogram depending on label config
jplot(, Program, Employment)                # grouped bar, 2 categorical
jplot(, Age, by = Gender)                   # overlaid histograms by group

# ---- Plot type coverage via formula form ----
jplot(Tattoos ~ Age, SampleData)            # scatter, no line
jplot(Tattoos ~ Age, SampleData, line = "lm")                    # + lm line + ci band + equation
jplot(Tattoos ~ Age, SampleData, line = "lm", band = "pi")       # prediction interval
jplot(Tattoos ~ Age, SampleData, line = "lm", band = "see")      # SEE band
jplot(Tattoos ~ Age, SampleData, line = "lm", band = "none")     # bare line
jplot(Tattoos ~ Age, SampleData, line = "loess")                 # loess smoother
jplot(Tattoos ~ Age, SampleData, line = "connect")               # connect points
jplot(Tattoos ~ Age, SampleData, by = Gender, line = "lm")       # per-group lines + equations
jplot(Age ~ Gender, SampleData)                                  # boxplot
jplot(Age ~ Gender, SampleData, by = Veteran)                    # boxplot with by-group colouring

# ---- Pipeline integration ----
jfilter(Age < 40)
jplot(, Age)                                # histogram should use filtered data
jplot(Tattoos ~ Age, SampleData, line = "lm")    # scatter + regression on filtered data
jfilter(NULL)

jcomplete(, Age, Education, Tattoos)
jplot(Tattoos ~ Age, SampleData, line = "lm")    # regression on listwise-complete cases
jcomplete(NULL)

# subset applies to this call only
jplot(Tattoos ~ Age, SampleData, subset = Gender == 1, line = "lm")

# ---- Error behaviour ----
jplot(SampleData, Age, Tattoos)             # error → suggests formula syntax
jplot(SampleData, Age, Gender)              # error → suggests formula syntax
jplot(Tattoos ~ Age + Friends, SampleData)  # error → suggests jlm + jplot(m) workflow
jplot(Gender ~ Age, SampleData)             # error → DV must be numeric

# ---- Edge cases worth a sanity check ----
jplot(Tattoos ~ Age, SampleData, line = "lm", equation = FALSE)  # line only, no equation
jplot(Tattoos ~ Age, SampleData, line = "lm", r2 = FALSE)        # equation without R²
jplot(, Age, line = "lm")                   # ignored-arg note fires
