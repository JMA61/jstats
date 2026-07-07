# Internal helper: strip backticks from design-matrix term names

A resolved transformed term is a column whose name is non-syntactic
("log(x)"), which the rewritten formula references as a backticked name.
Design-matrix machinery (lm/glm coefficient rownames, model.matrix and
VIF column names, a standardized refit's coefficient names) deparses
that symbol WITH its backticks. Stripping them at each capture point
keeps every downstream key – display rownames, the japa-ready term keys,
the standardized-beta and Gelman-beta name matches, the VIF Variable
column – in the same clean form as the data frame's own column names. A
no-op for ordinary syntactic names. (A factor level containing a literal
backtick would also lose it in these display keys; accepted as
vanishingly rare.)

## Usage

``` r
.jst_unbacktick(x)
```

## Arguments

- x:

  Character vector of term names.

## Value

x with all backtick characters removed.
