# Internal helper: how narrow a table's stub may go

Ruling R55: the labels wrap onto at most two lines, the stub never below
an inch and a half. Half the stub's width is the ruling's measure; a
label whose words cannot split into two lines that narrow sets the floor
wider, the narrowest width at which it takes two lines, so no label
wraps onto a third. A heading row spans the table and sets nothing.

## Usage

``` r
.jst_docx_stub_floor(tbl, size, w1)
```

## Arguments

- tbl:

  A jst_table.

- size:

  Points.

- w1:

  The stub's width at that size, unwrapped.

## Value

Integer, dxa; never more than w1.
