# Internal helper: md5 checksum of a character vector

Writes the lines to a temporary file with newline separators through a
binary connection (platform-stable: no CRLF translation on Windows) and
returns tools::md5sum() of it. Used for the AGENTS.md edit-detection
fingerprint.

## Usage

``` r
.jst_md5_of_lines(lines)
```
