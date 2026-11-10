# Internal helper: a data-first chart's frame facts

The default title, and the variables it shows by name or by code where
no label stood (ruling R72), read from the variables before they are
made factors.

## Usage

``` r
.jst_plot_frame_facts(
  data,
  type,
  shown,
  categorical,
  title,
  pipeline_counts = NULL,
  data_name = NULL
)
```

## Arguments

- data:

  The frame after the pipeline.

- type:

  The resolved chart type.

- shown:

  Character; every variable the chart shows.

- categorical:

  Character; those it shows by category.

- title:

  Character(1), the default title.

## Value

A list: title, names_shown, codes_shown, labelled.
