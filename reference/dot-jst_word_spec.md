# Internal helper: the word arguments and what each takes

The values and the sentence noun of every argument that takes a fixed
word, for
[`.jst_word_args()`](https://jma61.github.io/jstats/reference/dot-jst_word_args.md).
The shared ones (the display modes, the Case Processing detail) are read
from here by every function that has them; a function adds its own
(`to`, `method`, `std`, `which`) at its front door with
`.jst_word_spec()`. A value list changed anywhere is changed here as
well, or the pointer prints a word the function will refuse.

## Usage

``` r
.jst_word_spec(values, noun, name_it = FALSE)

.jst_word_specs(...)
```
