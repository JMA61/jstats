# Internal: the model frame Gelman's standardization refits

Each numeric column but the outcome centered, and divided by two SDs
unless it has two values (a 0/1 column is centered only); a power or a
product computed from the rescaled inputs, never rescaled itself
(.jst_rescale_poly_terms(); S321). jlm() and jlogistic() each held this
block (Session 386, the twin build); each refits it its own way.

## Usage

``` r
.jst_gelman_frame(mf, data, computed, enclos)
```

## Arguments

- mf, data:

  The model frame and the data.

- computed:

  Character: the computed terms' columns.

- enclos:

  The formula's environment.

## Value

The rescaled model frame.
