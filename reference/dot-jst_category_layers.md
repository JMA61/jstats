# Internal helper: the layers that draw a prediction at each category

A point at the prediction and a bar for its 95% interval, in the fitted
line's color (Session 360).

## Usage

``` r
.jst_category_layers(pred_df)
```

## Arguments

- pred_df:

  The data frame
  [`.jst_category_predictions()`](https://jma61.github.io/jstats/reference/dot-jst_category_predictions.md)
  returns.

## Value

A list of ggplot2 layers.
