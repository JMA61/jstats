# Internal: the built-in report style

The second built-in (ruling R58, Session 408; built Session 409): a
SHORT style based on apa, which stays the complete root of every
based.on chain. It holds only the values the report style manuals share
where apa's differ – the UK Government Analysis Function, the Australian
Government Style Manual, the UN Editorial Manual, and the US agencies'
forms, which differ from it by a setting or two (the Table Layer
Reference, 8.8): Arial 10, the caption 10 and the note 9, "Table 1:"
with the title on one line, a light grey bold header, apa's three rules,
no banding, the zero before the point (build 1's lean, Session 409: most
of the guidance writes it – NIH, the GPO manual, CDC's Emerging
Infectious Diseases, the Australian and UK manuals – and NCES's table
guidelines alone drop it on a statistic that cannot exceed 1; Jeff:
"Okay to keep your lean in this"), an upright "Note:", each variable's
label row bold. The new looks (caption.fill, heading.fill) stay off, so
a brand look is only ever turned on, in a user's own short file based on
this one.

## Usage

``` r
.jst_style_report
```

## Details

Session 414 (rulings R74, R75, R77 and R79, Session 413): the caption
follows size, as apa's does, and the note is a point smaller than size
("size - 1"), so a file based on report that sets size keeps that
relationship; the general note a sentence a line (Jeff's practice); the
notes in the report manuals' order, the source on a line of its own,
last; a t test's and an ANOVA's df in a column of their own, so a reader
who does not know APA's form does not read the number as N.
