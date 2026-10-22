# Internal helper: the data frame a name found nowhere was probably meant to be (ruling R36)

Ruling R36 (Session 391): jrecode(dd, Age, map = ...), d holding Age,
read dd as a variable, and both routes the not-found stop offered kept
that misreading (MyData in front; under juse() Age moved into labels =);
in the five formula functions jt(Score ~ Group, dd) gave R's own "object
'dd' not found". A name the caller has already found to be no object is
read as a data frame's name typed wrong when the other two conditions of
the ruling hold as well: it is no variable of any data frame in the
workspace, exactly one data frame holds every variable typed after it,
and that data frame's name is within two letters of it (Levenshtein
distance, case counting, as R's names do) without every letter changed:
dd is one from d and dta one from data, where zz, two from d, shares no
letter with it. With no variable typed after it there is nothing to
match, and no frame is offered.

## Usage

``` r
.jst_misspelled_frame(typed_name, vars, envir)
```

## Arguments

- typed_name:

  Character(1). The name typed where the data frame goes.

- vars:

  Character. The variables typed after it.

- envir:

  The caller's environment.

## Value

Character(1), the data frame's name, or NULL.
