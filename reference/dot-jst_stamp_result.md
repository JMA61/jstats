# Internal helper: stamp an analysis result with the version that made it

Sets the `jstats_version` attribute on a result the moment it is made
(Session 399, Capability Slate T's build 0), so a result saved to disk
and read back later says which jstats made it. No code reads it to treat
an older result differently (ruling R87, Session 424: until the first
CRAN release, no code for an object an earlier build saved). Called at
every place an analysis function makes its result: the ten functions
jtable() reads or may read (jdesc(), jfreq(), jscreen(), jt(), jaov(),
jcrosstab(), jcorr(), jlm(), jlogistic(), jalpha()). jsum() and javg()
return a variable for the data frame, not a result, and are not stamped.

## Usage

``` r
.jst_stamp_result(x)
```

## Arguments

- x:

  The result: a classed list, or jscreen()'s data frame.

## Value

`x` with the attribute set.
