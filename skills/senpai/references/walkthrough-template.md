# Walkthrough template

Fill in. Cut every section that's empty after honest effort — empty headings are noise.

---

# {Feature name} — Build-from-scratch walkthrough

> Branch: `{branch}` · Base: `{base}`
> Plan: [{plan filename}](./{plan filename}) · Spec: [{spec filename}](./{spec filename})
> Last updated: `{date}`

One short paragraph. What this feature is in product terms, the two-or-three user-visible paths it adds, and the single most important fact a maintainer needs to know up front (e.g. "renderer is unchanged — this just produces data the renderer already handled" or "schema is unchanged — uses existing fields").

---

## Steps at a glance

Numbered overview of the discovery sequence the rest of the doc follows. One line per step, phrased as the question the dev would have hit, with what they'd build to answer it. Mirrors the section headings below — readers should be able to use it as a table of contents.

1. **{User-visible question}** → {what gets built}
2. **{Next question forced by step 1}** → {what gets built}
3. **{Next question}** → {what gets built}
…

---

## The starting point

Two short paragraphs. What the dev knows walking in:
- The user-facing pain point this kills.
- Any existing code that the feature has to interoperate with (renderer, save pipeline, etc.) — and crucially, what it does NOT require them to change.

Pointing at the single line in the existing code that tells the dev "you don't have to touch this" is worth a lot here.

---

## Step 1 — {The first question, e.g. "Where does this UI mount?"}

Open with the question. Then walk through the discovery: which existing files give the dev the answer, what pattern they'd notice, what decision they'd make.

Show the existing pattern they're modeling on (1–3 lines of code), then show what they'd add.

End with whatever about this step is non-obvious — a constraint, a gotcha, the alternative they considered.

## Step 2 — {The question forced by step 1's answer}

Same shape. The header is the question, not the file name.

If a step branches the feature into two paths (e.g. "happy path vs error path"), say so. Then handle one path through its end and come back to the other.

… continue until every meaningful change is covered …

---

## Decision log

Choices in the **current code** where the rationale isn't obvious from reading the file.

Format per bullet: **{the choice in 5–8 words}.** {Why: the constraint or failure mode that drove it.} {Rejected: only mention an alternative if it's *live* — something a maintainer might reach for next time they touch the code.}

Aim for 5–12 bullets. If you have fewer, you didn't read deeply. If you have more, you're enumerating dead alternatives — cut.

---

## Pointer table — if I want to change X, touch Y

| Change | Touch |
|---|---|
| {realistic future change} | `path/file.ts` (`functionName`) |
| … | … |

Aim for 8–15 rows.

---

## Open threads

- **{Thread name}** — what's pending, what blocks it, who owns it. One sentence each.
- Manual QA scenarios that still need to happen.
- Env / infra prerequisites (API keys, CORS, fixture updates).
- Known-but-accepted issues (with the reason for accepting them).
- Tests not written.

---

## Glossary (only if needed)

- **{Term}** — definition relevant to this feature only. Skip the section if no domain jargon was introduced.
