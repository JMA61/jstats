# Internal helper: yes/no console confirmation

Takes the informational lines only; the helper owns the question. The
split matters: readline()'s prompt is a SINGLE-line facility, so a
prompt carrying embedded newlines leaves the cursor parked after the
first line while the rest renders below it (confusing in RStudio).
Display goes through cat() to stdout – not message(), which writes to
stderr, renders red in RStudio, and can interleave unpredictably right
before a prompt.

## Usage

``` r
.jst_jai_confirm(info)
```
