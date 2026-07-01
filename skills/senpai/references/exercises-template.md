# Exercises template

Companion to `<feature>-walkthrough.md`. The walkthrough is the answer key; this file tests whether the maintainer can actually navigate the code. Answers live in collapsed `<details>` so they can self-check *after* attempting.

Fill in. One exercise, 3–4 questions. Cut anything you'd have to pad.

---

# {Feature name} — Exercises

> Companion to [{feature}-walkthrough.md](./{feature}-walkthrough.md)
> Branch: `{branch}` · Base: `{base}`

Do the exercise first, then the questions. Don't open a `<details>` until you've committed to an answer — the point is to find out what you can't yet do, not to read more.

---

## Exercise — {one-line behavior change, e.g. "make the link list reorderable"}

{One paragraph in product terms: what the feature does today, and what you want it to do instead. Frame it as a real ticket, not "study function X".}

**Acceptance criteria**
- [ ] {What you should see in the UI}
- [ ] {What should persist on save / round-trip correctly}
- [ ] {What should be rejected / what edge case must hold}

<details>
<summary>Hints (open only if stuck)</summary>

Not the answer — the trail. Start here and ask the question at each stop:

1. `{path/file.tsx}` — {the question to ask here, e.g. "where does the edited value leave this component?"}
2. `{path/file.ts}` — {next question}
3. `{path/file.ts}` — {next question}

</details>

<details>
<summary>Solution sketch (open after you've attempted)</summary>

Approach: {2–4 sentences — the shape of the change, not a full diff}.

Touch:
- `{path/file.tsx}` (`{fn}`) — {what changes}
- `{path/file.ts}` (`{fn}`) — {what changes}

**The gotcha:** {the thing the naive version gets wrong, and exactly how it fails at runtime — the data-flow insight this exercise exists to teach. Tie it to the Decision-log bullet it came from.}

</details>

---

## Comprehension check

Answer before opening any `<details>`. If your answer matches the collapsed one but you weren't sure *why*, treat that as a miss and re-read the cited lines.

**1. {Trace-it / break-it / why-this-value / boundary question}**

<details><summary>Answer</summary>

{Answer, anchored at `path/file.ts:line`. Says why, not just what.}

</details>

**2. {question}**

<details><summary>Answer</summary>

{Answer with `file:line`.}

</details>

**3. {question}**

<details><summary>Answer</summary>

{Answer with `file:line`.}

</details>

{**4. {optional fourth question}** — drop if three already cover the feature.}
