# Internal: message text shared by more than one function

Constants holding the fixed text of messages that several functions
print, each used where its message is built, so the wording is changed
in one place (Session 383, the hygiene slate; the S381 item). Each value
is the text its sites printed before the merge, byte for byte.

## Details

- `.jst_txt_jencode_first`:

  the type refusals' remedy for a factor or text variable: jrecode(),
  jrelabel(), jdeclare_missing(), the registration verbs, a computed
  formula term.

- `.jst_txt_modify_unnamed`, `.jst_txt_name_first`:

  the first two sentences of the stop for modify = TRUE on a data frame
  given as an expression or a place: jrelabel(), jdeclare_missing(),
  jconvert().

- `.jst_txt_pd_instead`, `.jst_txt_pd_sav`:

  the lead of the preserve.declarations = FALSE route in jsave()'s .dta
  and .sav refusals.

- `.jst_txt_plot_nav`:

  the line under a list of plots.

- `.jst_txt_new_column`, `.jst_txt_new_column_it`:

  the remedy for a formula term jstats cannot use as written.

- `.jst_txt_first_arg_frame`:

  the recode family's stop for a first argument that is not a data
  frame.

- `.jst_txt_vars_quoted`:

  the stop for vars = that does not hold names in quotes.

- `.jst_txt_add_overwrite`:

  what the overwrite question says when the session cannot ask it:
  jload(), jsave(), jcopy().

- `.jst_txt_map_commas`, `.jst_txt_na_longhand`, `.jst_txt_na_one_rule`,
  `.jst_txt_map_empty`:

  the map parsers' messages, numeric and text.

- `.jst_txt_frame_each_var`:

  the close of the stops for a variable given with its data frame
  attached.

- `.jst_txt_default_route`:

  the lead of the second route when no data frame is named.

- `.jst_txt_provide_two_vars`:

  jcorr(), jsum() and javg() given fewer than two variables.

- `.jst_txt_jai_cannot_ask`, `.jst_txt_jai_set_path`:

  jai()'s writing setups.

- `.jst_txt_value_id`:

  value.id given to a function that shows no value labels.

- `.jst_txt_qq_produced`:

  jt() and jaov()'s Q-Q plot line.

- `.jst_txt_full_distribution`:

  the close of jsum() and javg()'s keep-it note.

- `.jst_txt_levene_caption`:

  the title of Levene's test in jt() and jaov().

- `.jst_txt_stata_markers_na`:

  the stata option's line in the convention menus.

- `.jst_txt_assign_expr`:

  the assign-or-lose reminder's lead for data given as an expression.

- `.jst_txt_null_remedy`:

  the stop for NULL given as the data.

- `.jst_txt_both_missing`:

  jrecode() and jencode()'s stop for a code the map also assigns as an
  ordinary value.
