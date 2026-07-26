# Internal helper: the SKILL.md frontmatter description

The when-to-use relevance trigger read by skill-supporting assistants,
and the only jstats text an assistant carries in EVERY conversation:
S209 established that the skill directory (name plus description) sits
in context from the start, while loading only fetches the body.

## Usage

``` r
.jst_skill_description()
```

## Details

EMITTED AS ONE PLAIN SCALAR ON THE description: LINE. NEVER WRAP IT.
S209 verified against the live runtime that a folded block scalar
(description: \>-) yields an EMPTY description in the assistant's skill
directory – fatal even with a single indented continuation line, and
silent: the skill still lists by name, so nothing looks wrong while the
match surface is gone. The runtime reads the value line-wise, whatever
the loader does with the rest of the file. Two probe runs were lost to
this. Consequences: the source keeps the sentences as separate elements
for editing only, joined here with single spaces (so no element may end
in a space, and none may contain ": ", which a plain scalar forbids).

Wording per the S207 trigger-edge probe – a token list, not prose, with
the dataset names load-bearing – and the S209 closing sentence, which
pairs the anti-guessing warning with the remedy: warned but not told
what to do, the S209 run avoided jstats entirely and reached for haven.
