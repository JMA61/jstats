# Internal helper: the note for a p column a call lists under stars

Under p.format = stars a table has no p column, the asterisks on the
statistic (ruling R83, Session 419). When the CALL itself lists p –
columns = c("b", "se", "p") – the table leaves out a column the call
asked for, so jtable() says so and where the p-values come from; a style
file's own list of columns gets no note, its p.format beside it.

## Usage

``` r
.jst_table_stars_note(style, type, args, stat)
```

## Arguments

- style:

  The table's style.

- type:

  The table type.

- args:

  Character; the settings that list columns, as a call names them.

- stat:

  Character(1); the statistic the asterisks are on, as the note names
  it.

## Value

Character: the note, or none.
