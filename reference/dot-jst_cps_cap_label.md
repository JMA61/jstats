# Internal helper: cap a pipeline-row label's parenthetical content for CPS

Keeps the Case-Processing top table readable when a long jcomplete()
variable set or a jsubset()/subset = expression would otherwise blow out
the dynamic column width. Two modes: "list" – a character vector of
names (jcomplete's complete_vars). With more than max_items entries,
returns the first max_items followed by ", +N more". The full set stays
visible via jcomplete()'s own status query. "expr" – a single expression
string (filter_expr / subset_expr). Truncated to max_width display
columns with a trailing ellipsis when longer. Returns the (possibly
shortened) content only; the caller supplies the operation prefix, e.g.
sprintf("jcomplete (%s)", ...). Display width is measured with
nchar(type = "width"), matching the renderer's dw().

## Usage

``` r
.jst_cps_cap_label(
  content,
  mode = c("list", "expr"),
  max_items = 2L,
  max_width = 40L
)
```
