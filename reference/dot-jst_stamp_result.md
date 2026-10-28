# Internal helper: stamp an analysis result with the version that made it

Sets the `jstats_version` attribute on a result the moment it is made
(Session 399, Capability Slate T's build 0), so a result saved to disk
and read back later says which jstats made it. The table layer reads the
stamp to tell a result made before a field it needs existed from one
that lacks the field for another reason, and can say so in its own words
("made by jstats 0.9.250; run the analysis again"). A result with no
stamp predates the stamp. Called at every place an analysis function
makes its result: the ten functions jtable() reads or may read (jdesc(),
jfreq(), jscreen(), jt(), jaov(), jcrosstab(), jcorr(), jlm(),
jlogistic(), jalpha()). jsum() and javg() return a variable for the data
frame, not a result, and are not stamped.

## Usage

``` r
.jst_stamp_result(x)
```

## Arguments

- x:

  The result: a classed list, or jscreen()'s data frame.

## Value

`x` with the attribute set.
