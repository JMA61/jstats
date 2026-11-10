# Internal helper: the data frame's name a result or a chart keeps, where an offered line can be built on it

A result keeps the data frame as its call gave it (data_name: every
analysis result since Session 416, jlm()'s since Session 403), which may
be an expression – `d[d$Age > 30, ]`. A line that changes the frame
(`jrelabel(..., modify = TRUE)`) runs only on a plain name; one that
reads it runs on a place such as `lst$d` too. Anything else, and a
result that keeps no name, gives NULL, and the line names the
placeholder MyData.

## Usage

``` r
.jst_kept_data_name(dn, place = FALSE)
```

## Arguments

- dn:

  The name as kept, or NULL.

- place:

  Logical(1); whether a place will do.

## Value

Character(1) or NULL.
