# Internal helper: render orientation Markdown for the console

The body is authored in Markdown for the file emissions; a console print
wants plain text. Strips backtick code spans and the leading heading
marker; bullets read fine at a prompt and are kept.

## Usage

``` r
.jst_orientation_render_console(lines)
```
