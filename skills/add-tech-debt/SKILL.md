---
name: add-tech-debt
description: "Append a tech debt entry to a project tech-debt log (docs/tech-debt-log.md) based on the current conversation. Use when: (1) the user says 'add tech debt', 'log tech debt', 'log this as tech debt', 'note this for the tech debt log', '/add-tech-debt', (2) the user wants to record an architectural smell, coding-practice issue, or non-blocking design flaw discovered while working on something else, (3) the user describes a self-healing or workaround-able issue that signals a deeper design mistake worth logging. Triggers on tech debt logging, architectural smell capture, code quality issue recording."
---

# Add Tech Debt

Append a numbered entry to the tech debt log based on what was discovered in the current conversation.

The log lives at `docs/tech-debt-log.md` in the repo root (adjust to your project's docs location). It captures architectural smells and "this wasn't thought through" patterns surfaced while working on something else. Entries are not blockers — they're things worth fixing when the area is revisited, or worth knowing about when onboarding.

## Workflow

### 1. Identify the issue from conversation context

Look back at the conversation. The tech debt should be something concrete that was investigated, debugged, or noticed in passing — not a hypothetical concern.

A good tech debt entry has:
- **Specific code locations** (file paths with line numbers)
- **A concrete observed symptom** (what went wrong from the user's perspective)
- **An architectural why** (the smell, not just the bug)
- **At least one plausible "right shape"** (how it should have been done)

If the conversation does not contain enough specifics to fill out all five fields below, ask the user one focused question to fill the gap. Do not invent file paths or fabricate severity.

### 2. Read the existing log

Read `docs/tech-debt-log.md` to:
- Find the highest existing entry number (look for `## N. ` headings)
- Match the existing tone, terseness, and structure
- Confirm the issue is not already logged (skim titles — if a duplicate, update the existing entry instead of adding a new one)

### 3. Draft the entry

Use this exact structure. Match the established voice: blunt, observation-first, no corporate softening. Lowercase file paths. No em-dashes in prose (use regular hyphens or rewrite). No marketing-style adjectives.

```markdown
## N. <short title, sentence case, no trailing period>

**Where**

- `relative/path/to/file.ts:LINE` (function or symbol name in parens if useful)
- additional locations, one per line

**What's wrong**

One or two short paragraphs. Describe the actual mechanism that's broken or sloppy. Be specific about what the code does versus what it should do. Skip vague language like "could be improved".

**Why it matters**

One paragraph. Name the architectural smell: cross-service coupling no one documented, missing invariant, leaky abstraction, hidden coordination, etc. If a real user lost time to this, say so. The goal is to make the future reader understand the *category* of mistake, not just this instance.

**Right shape**

Bulleted list of plausible fixes. Order from cheapest to most-correct. Each bullet is one sentence. Do not commit to a choice unless the conversation already decided one.

**Severity**

Low / Medium / High. One sentence on blast radius and self-heal behavior.

**Discovered**

YYYY-MM-DD, brief context: what was the user actually doing when this surfaced.

---
```

### 4. Append to the log

Use Edit to append the new entry to the bottom of `tech-debt-log.md`. Keep the trailing `---` separator so the next entry has a clean boundary. The numbering is global and monotonic — never reuse a number even if older entries get resolved (resolved entries should be marked, not renumbered).

### 5. Confirm to the user

Report: entry number, title, and one-line summary. Do not paste the whole entry back unless asked. If the entry was a duplicate of an existing one and you updated it instead, say so.

## Notes on style

- The log is informal but precise. Sentences end in periods. No emojis. No exclamation marks.
- Avoid "we should" / "we could" — state what the right shape is, not what someone should feel about it.
- File paths are relative to the repo root.
- If the issue spans multiple services (e.g. one service writes but another caches), list every file in **Where** — that's the whole point of the entry.
- Discovery date uses the current date (today). Convert any relative dates the user mentions ("yesterday", "last week") to absolute YYYY-MM-DD before writing.

## When NOT to use this skill

- Active bugs that need a fix now → those go in the issue tracker, not the tech debt log.
- Style nits → those belong in `team-conventions.md`, not here.
- Personal preferences without an architectural reason → not tech debt.
- Things the user has not yet investigated → ask the user to investigate first, or use a debugging skill. The tech debt log is for things you understand, not things you suspect.
