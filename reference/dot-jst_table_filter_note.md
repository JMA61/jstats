# Internal helper: the general note's filter sentence

"Only cases with Age (years) \>= 30 are included." (the reference, Part
1, lean 8): the filter a stored jsubset() applied and the call's subset
=, joined by "and", each put into words. Written once when every result
has the same filter; otherwise once per filter, naming the results it
covers. A jcomplete() setting adds nothing: N says it. filter.note = no
leaves the sentence out (ruling R53).

## Usage

``` r
.jst_table_filter_note(results, names, style, type, list_fn = .jst_and_list)
```

## Arguments

- results:

  The results, in the table's order.

- names:

  Character, one per result: how a sentence names it when the results'
  filters differ.

- style:

  The style.

- type:

  The table type.

- list_fn:

  The function that joins the names (the models'
  [`.jst_table_model_list()`](https://jma61.github.io/jstats/reference/dot-jst_table_model_list.md)
  writes "Models 2 and 3").

## Value

Character(0), or the sentences.
