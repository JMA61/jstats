# Internal: width-aware wrapping for runtime-message prose

Wraps ONE prose sentence (or short paragraph) at word boundaries to a
target width, replacing the former practice of hardcoded mid-sentence
line breaks sized against one content width (S230; the S229 walk showed
those breaks failing in both directions as variable content changed).
Three refinements over a bare strwrap():

- ATOMIC TOKENS: function calls (jconvert(...), joptions(...)) and
  dotted argument references (preserve.declarations = FALSE) are never
  split across lines – a break inside a runnable token is worse than a
  long line. Protection is limited to tokens it would be WRONG to break,
  which excludes code slates – the parenthesized comma lists of declared
  codes built at runtime, which can break as "(-1, -2," / "-3)".
  Considered and rejected in Session 259. A slate is ugly to break, not
  wrong: breaks fall at spaces, so an open paren is never orphaned and a
  code is never split. Making it an atom makes it unbreakable, so a long
  slate – 17 declared codes is a real administrative-data case – lands
  on its own line past the width, converting a cosmetic break into the
  over-width line this helper exists to prevent. Capping the atom to
  slates that fit the width avoids that, but then it fires only where
  the render is mildest. See the Session 259 changelog.

- ORPHAN PULL-BACK: words are pulled down from the line above while the
  last line reads as an accident – either shorter than min_tail
  outright, or shorter than min_last AND a single word. Session 257
  replaced a bare length test with this two-part condition. The bare
  test scaled badly as the resolved width narrowed: at width 50 a fixed
  20 is 40 percent of the line, and it emptied the line above down to
  the single word "codes". Measured over 392 message bodies at four
  widths, the new condition halves the count of under-filled lines at
  every width and leaves the count of one-word tails unchanged, since it
  is strictly weaker than the old test on a single word and so cannot
  create one. The alternative considered and rejected was making
  min_last a proportion of width: it bought the same fill by
  manufacturing one-word tails (3 to 12 at width 50), which is the
  defect the pull-back exists to prevent.

- PREFIX RESERVE: for strings surfaced through .jst_stop(), the emitter
  prepends a `fn(): ` prefix AFTER the builder returns; `reserve`
  narrows the first line by that many characters so the rendered first
  line still lands within width. (Since Session 256 the emitters also
  count R's own inline chrome in reserve; see .jst_stop() and
  .jst_warn() for the per-route budgets.)

## Usage

``` r
.jst_wrap_prose(
  text,
  width = .jst_resolve_width(),
  min_last = 20L,
  reserve = 0L,
  tol = 12L,
  min_tail = 10L
)
```

## Arguments

- text:

  Character scalar: one sentence/paragraph, no embedded newlines.

- width:

  Target line width. Defaults to the resolved `message.width` setting
  (see
  [`joptions`](https://jma61.github.io/jstats/reference/joptions.md));
  the shipped default is "auto", which resolves to the live console
  width less one.

- min_last:

  Length below which a SINGLE-WORD last line is pulled back. A last line
  at or above this length, or holding more than one word, is left alone
  by this test.

- reserve:

  Characters the emitter will prepend to line 1.

- tol:

  Rule 2 tolerance: when a sentence boundary sits within this many
  characters of the fill point, the break relocates to the boundary so
  the sentence stays whole. 12 is the S252-measured value (the smallest
  catching the jsubset case, the largest costing no extra lines); 0
  disables the rule and restores plain word-fill exactly.

- min_tail:

  Absolute floor: a last line shorter than this is pulled back whatever
  its word count. Stops the word test stranding a short multi-word tail
  such as "to show." (Session 257).

## Value

Character scalar with newline characters at the break points.

## Details

Scope: prose only. Runnable command lines follow Rule L (their own
indented line) and are never passed through this helper. Applied at the
S230 sites; other messages adopt it as they are touched.
