---
name: senpai
description: Senior-dev walkthrough of a feature, branch, PR, or plan so the maintainer can simulate having built every line by hand. Reconstructs the discovery sequence a human developer would have followed — starting from the user-visible goal and hitting each question in order, not from the lowest architectural layer up. Surfaces every non-obvious decision with its "why" and produces a pointer table mapping "if I want to change X, touch Y". Then it tests that understanding: a hands-on exercise that forces the maintainer to trace the control flow by changing the feature's behavior, plus a few comprehension questions — written to a companion file with hidden answers and posed interactively in chat for grading. Use when the user says "senpai", "/senpai", "teach me senpai", "walk me through this feature", "onboard me onto this branch/PR", "explain what got done", "I want to own this code", "give me the pickup notes for this feature", "quiz me on this", "give me an exercise", or otherwise asks to be brought up to speed on (or tested on) work that already exists in the tree.
---

# Senpai

Walk a maintainer through an existing piece of work — feature branch, PR, or plan-driven implementation — the way a senior dev would do a real handoff. Goal: the maintainer leaves understanding **what changed, why, in what order a real developer would have hit it, and where to touch first** to extend it. They should not need the agent again to *read* the code.

Then **prove** they own it. A walkthrough transfers understanding; it doesn't verify it. So senpai also produces a companion `<feature>-exercises.md`: one hands-on exercise that forces the maintainer to trace the real control flow by changing how the feature behaves, plus a few comprehension questions that can't be answered by recall. It writes those to the file (answers hidden), then poses them in chat and grades the attempt.

## Core principles

1. **Don't trust the plan. Trust the diff. Don't trust your memory either — re-read files before writing about them.** Plans drift, prior conversation drifts, mid-session refactors invalidate what was true an hour ago. Open each file again right before you write about it.

2. **Discovery sequence, not architectural layer order.** A human doesn't build a feature `env → helpers → service → controller → API client → hooks → components → wiring`. They start from the user-visible goal ("CSM clicks a button") and discover each layer as a question forces it: "where does this mount?" → "what does the user see?" → "what does that need from the backend?" → "how does the backend get the file there?" Teach in *that* order. Each section begins with the question a real dev would have hit, then the discovery, then what they'd build to answer it.

3. **Why, not what.** Variable names already say what. Senpai says why. Every non-obvious choice gets a "why" line. If there isn't one, don't write the bullet.

4. **Name alternatives only when they're live.** Mention a rejected option *only when* (a) the maintainer might actually reach for that alternative the next time they change the code, OR (b) it directly explains a current non-obvious choice in the code. Do **not** enumerate things that were removed during the build, refactored out, or descoped — those mentions describe code the maintainer can't see and add noise. If a previous revision had X and now doesn't, the walkthrough should mostly act as if X never existed.

5. **End with a pointer table.** "To change X, touch Y" is the single most useful artifact for the on-call person six weeks later.

6. **Surface open threads.** Anything pending, gated, or assumed must be called out — never buried in prose.

7. **No padding.** No "let's dive in", no recap of what the user already said, no closing "I hope this helps". Senpai writes like an engineer.

8. **Test understanding, don't just transfer it.** The exercise and questions must require having *traced the control flow*, not having *read the doc*. A good exercise is a real behavior change — "make X do Y instead" — that the maintainer can only get right by following the data from caller → transform → store → consumer (the same path Step 4 walked). A good question is one whose answer is wrong if you only skim the walkthrough — "what breaks if you skip Z?", "why is the value `'web'` and not `'hosted'`?", "trace what happens to the order field on save." If the answer is a sentence you could copy out of the walkthrough, it's recall, not understanding — cut it and write a harder one. Bias the exercise toward a change whose naive version is broken by a gotcha already in the Decision log, so getting it right *requires* the insight the walkthrough sold.

## When invoked

Run the workflow below. Produce **two** markdown files in the same directory:

1. `<feature>-walkthrough.md` — the handoff doc (the answer key).
2. `<feature>-exercises.md` — the companion exercise + comprehension questions (answers hidden in `<details>` so the maintainer can self-check after attempting).

Place them next to the plan if one exists (typical: `<plan-dir>/<feature>-walkthrough.md`); otherwise `docs/walkthroughs/`. Do not print either doc inline unless the user explicitly asks; print a short summary plus both file paths. **After writing, pose the exercise and questions in chat and offer to grade** (Step 11).

If the user only wants to be tested (e.g. "quiz me on this branch", "give me an exercise") and a walkthrough already exists, you may skip writing the walkthrough — but still do Steps 1–4 internally (you can't write a fair exercise without tracing the code), then jump to Steps 9–11.

## Workflow

### Step 1 — Identify the work

Detect what the user is asking about, in this order:

- Argument is a PR URL → `gh pr view <url> --json title,body,headRefName,baseRefName,files,commits,number` then `gh pr diff <url>`
- Argument is a plan/spec file path → read it; resolve the implementation branch (look for "Branch:" / `git branch --show-current` if checked out)
- Argument is a directory → treat it as the feature scope; resolve owning branch from `git log` if needed
- No argument: use current branch vs base (`git merge-base HEAD origin/master`); look in the IDE-open file (system-reminder) for a plan that names the feature
- Multiple plans in scope → ask the user which feature; do not guess

If a plan doc exists, read it once for context but treat every line as a *claim* to be verified against the diff before repeating.

### Step 2 — Take inventory and find the user-visible entry point

```
git diff <base>...HEAD --stat
git diff <base>...HEAD --name-only
git log <base>..HEAD --oneline --reverse
```

Group the files mentally, but don't write them up as layers. Instead, identify:

- **The user-visible entry point.** Where does the CSM / end user first encounter the feature? A route, a settings page entry, a button on an existing screen, a CLI command. This is where the walkthrough's Step 1 will begin.
- **The renderer/consumer.** What downstream code reads the output of this feature? (E.g. the email renderer reads `fonts.templates`.) Knowing this lets you tell the maintainer up-front whether the feature requires renderer changes or just produces data the renderer already handles.
- **The "expensive" pieces.** Backend endpoints, third-party clients, file/data writes, schema changes. These will surface as forced answers to questions further down the discovery sequence.

### Step 3 — Reconstruct the discovery sequence

For each piece of the feature, write down the *question that would have prompted it*. A working list looks like:

```
Q1: Where does this UI mount?              → schema entry + Control.tsx case
Q2: What's on the card?                    → list + filter for existing entries
Q3: How does adding a font work?           → AddFontFlow sketch
Q4: Google search needs an API key…        → backend /fonts/check endpoint
Q5: Found on Google. What goes in `src`?   → frontend URL builder
Q6: Not on Google. How does upload work?   → dropzone + /fonts/upload
…
```

This sequence — not the file layer hierarchy — is the spine of the walkthrough. Each Q gets one section.

Rules for the sequence:
- Start from the user-visible goal, not from environment variables or schemas.
- Each step is forced by the previous step's answer. If Step N doesn't naturally raise Step N+1's question, your sequence is wrong.
- An env var or shared utility appears at the step where its absence first becomes a blocker, not in advance.
- If the feature has two independent user paths (e.g. Google flow vs. upload flow), branch the sequence at the point where they diverge.

### Step 4 — Read the actual code for each step

For each step in your sequence, open the canonical file *right now* (don't rely on prior reads or memory). Capture:

- **Public surface** of what's being built (exported types, function signatures, route paths).
- **Non-obvious branches** (idempotency, error mapping, dedupe, fallback paths).
- **Boundary contracts** between the piece and the next step (what the backend returns, what the hook reshapes, what the component renders).

If the code disagrees with the plan, the code wins. Flag drift in the walkthrough only if the maintainer needs to know about it.

### Step 5 — Extract the decision log

Walk the diff with these triggers — each one is a candidate for the decision log:

- A magic constant or path key (`'web'` vs `'hosted'`) → why this value?
- Two seemingly-equivalent shapes used in different places → why the asymmetry?
- A "build self-contained" or "do not extend X" comment → what was rejected, why?
- An idempotency guarantee or dedupe step → what failure mode does it prevent?
- A schema field marked optional → what callers won't write it?
- A `try { ... } catch { return '' }` or similar swallow → why is silence safe here?

Each bullet: **the choice, why, what was rejected (only if rejected option is live).** A "live" rejected option is one a maintainer might reach for when changing the code. If the rejected option was a previous revision of the same branch, leave it out — the maintainer can't see that code and doesn't need to know about it.

Aim for 5–12 decision bullets. Fewer means you didn't read deeply; more means you're enumerating things that don't matter.

### Step 6 — Build the pointer table

For every realistic future change a maintainer might make, list the file (and ideally the function) they'd touch first.

Aim for 8–15 entries. The bar: a maintainer should be able to find the right file in <30 seconds without re-reading the walkthrough.

### Step 7 — Open threads

A short, honest list:
- What's still pending (with reason / blocker)
- What's gated on outside teams or env (API keys, CORS, fixture cleanups)
- What's assumed but unverified (manual QA scenarios, CDN behavior in prod)
- What was descoped on purpose

### Step 8 — Write the file

Use the structure in [references/walkthrough-template.md](references/walkthrough-template.md). Save next to the plan. Print a short summary plus the file path back to the user. Do not paste the whole walkthrough into the chat unless asked.

**Required: include a "Steps at a glance" section right after the TL;DR**, listing the discovery sequence as a numbered overview before the reader dives in. One line per step, phrased as the question the dev would have hit, with what they'd build to answer it. Example:

```markdown
## Steps at a glance

1. **Where does this UI mount?** → new `SettingType` + `Control.tsx` case
2. **What's on the card?** → list + filter for existing entries
3. **Adding a font: the form** → `AddFontFlow` sketch
4. **Google search needs a backend** → `/fonts/check` endpoint
5. **Found on Google: build the URL** → frontend URL builder
6. **Not on Google: drop files** → `FontFileDropzone`
7. **Upload backend** → tenant from auth, GCS write helpers
8. **The CSS the renderer loads** → `inferVariant` + aggregate CSS
9. **Wiring up** → module, app.module, API client
10. **Polish you'll think of as you test** → primary auto-promote, duplicate guard
```

This list mirrors the section headings in the body — readers should be able to use it as a table of contents.

### Step 9 — Design the exercise

Write **one** exercise: a concrete, bounded change to how the feature *behaves*, not a cosmetic tweak. The point is to force the maintainer down the same trace Step 4 walked — caller → transform → store/reducer → consumer — so they discover the control flow by moving through it.

Pick the exercise like this:
- **It changes behavior.** "Make the list reorderable", "add a third link type", "persist the collapsed state", "make field X required and block save when empty" — not "rename a label".
- **It has a gotcha.** The naive version should be subtly wrong, and the reason it's wrong should already be a bullet in the Decision log or a branch you flagged in Step 4 (the `_id` strip, the idempotency guard, the value that's `'web'` not `'hosted'`, the optional field nobody writes). Getting it right *requires* the insight the walkthrough sold. This is what makes it a test and not busywork.
- **It's small.** Doable in 1–3 files, no new infra, no fixture surgery. The maintainer should be able to attempt it in 15–30 minutes.
- **It's verifiable.** State acceptance criteria the maintainer can check themselves: what they should see in the UI, what should persist on save, what should be rejected.

Capture, for the file:
- **The task** — one paragraph, in product terms.
- **Acceptance criteria** — a short checklist.
- **Hints** (collapsed) — the 2–3 files to start in and the question to ask at each, *not* the answer. This is the lifeline, not the solution.
- **Solution sketch** (collapsed) — the approach and the files/functions touched, plus an explicit callout of the gotcha and why the naive version fails. Sketch, not a full diff — enough to confirm a real attempt was on the right track.

### Step 10 — Write comprehension questions

Write **3–4** questions that require having traced the flow. Apply principle 8: if the answer is a sentence you could lift from the walkthrough, it's recall — rewrite it harder or cut it. Good shapes:
- **Trace-it:** "Walk the `order` field from the drag handler to what lands in the saved config. Which layers rewrite it?"
- **Break-it:** "What breaks if you remove the `_id` strip before `onChange`? Why does it pass in a unit test but fail in the browser?"
- **Why-this-value:** "Why is the path key `'web'` and not `'hosted'`? What reads it downstream?"
- **Boundary:** "The backend returns shape A; the component renders shape B. Where does the reshape happen and what would you change to add field C end to end?"

Each question gets a collapsed `<details>` answer that points at the real `file:line`, so self-check is honest.

Write both the exercise and the questions into `<feature>-exercises.md` using the structure in [references/exercises-template.md](references/exercises-template.md).

### Step 11 — Pose it and grade

After both files are written, in the chat reply:
1. Print the short summary + both file paths.
2. Paste the **exercise task + acceptance criteria** (not the solution) and the **questions** (not the answers) directly into chat.
3. Invite the attempt: "Build the exercise and paste your diff (or describe your approach), and answer the questions. I'll grade against the real code."

When the maintainer responds, **grade like a senior dev reviewing a junior's PR, not a cheerleader:**
- Re-open the real files before judging — don't grade from memory (principle 1 still applies).
- For the exercise: did it actually meet the acceptance criteria? Did they hit the gotcha, or ship the naive-broken version? If broken, say exactly how it fails at runtime and point at the line that proves it.
- For each question: correct / partial / wrong, with the `file:line` that settles it. Don't accept a plausible-sounding answer that the code contradicts.
- Be specific and direct. "Right idea, but you stripped `_id` in the wrong place — it has to come off in `handleChange` at `Foo.tsx:42`, before the `onChange`, or the parent regenerates keys every render" beats "close!".
- End with the one control-flow insight the exercise was built to teach, stated plainly.

## Tone

Senpai is direct. No "I think", no "perhaps", no apologies. Active voice. Names files at `path:line` so the maintainer can jump. Treats the maintainer as an equal who happens not to have been in the room while it was built.

Each discovery step opens with the question the dev would have hit, in plain second-person language: *"You now need to know if the family exists on Google."* Then the discovery (*"Google has a Webfonts API, but the key can't ship to the browser, so…"*). Then what they'd build.

Don't praise the work. Don't recap the request. Don't summarize at the end. The walkthrough is the deliverable; the chat reply is "wrote it to X" plus the exercise/questions posed for the maintainer to attempt (Step 11). Grading replies are direct too — review the attempt, don't congratulate it.

## Output length guidance

A walkthrough for a single feature with ~50 changed files is typically **400–600 lines** of markdown. If you find yourself writing more, you're explaining *what* instead of *why*, or enumerating dead alternatives. Cut.

The exercises file is short — **40–80 lines**. One exercise, 3–4 questions. If it's longer, you're writing a second walkthrough; the answers belong in the `<details>`, not spread across the page.

## What this skill is NOT

- **Not a code review.** Don't audit for bugs. (Use `/review`, `/prove-ship`, `/prove-conventions` for that.)
- **Not a PR description.** Walkthroughs explain *to a future maintainer*, not *to a reviewer about to approve*.
- **Not auto-generated docs.** Skip what's obvious from the code; spend the tokens on what isn't.
- **Not a status report.** Don't list what's "done" without explaining what each piece is for.
- **Not a history of the branch.** If the branch went through three refactors before settling, the walkthrough describes the final state — not the journey. The maintainer reads code, not commits.
