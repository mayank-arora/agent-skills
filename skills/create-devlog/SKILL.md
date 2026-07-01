---
name: create-devlog
description: Append a verbatim entry to a personal, per-repo, gitignored devlog (DEVLOG.md), and seed talking-point nudges from recent git/PR activity and unresolved threads in the previous entry. Use when the user says "create devlog", "devlog", "add a devlog", "dev log entry", "log this", "/create-devlog", or wants to record what they are working on / rant about progress. The user usually dictates via speech-to-text, so the log is recorded WORD-FOR-WORD with only obvious typo and speech-to-text fixes, never summarized, reworded, or analyzed.
---

# Create Devlog

## Overview

The user keeps a running personal devlog where they rant, in their own words, about what they are working on. This skill appends those rants verbatim and, when they sit down to write, nudges them on what to talk about (recent git activity, and open threads from the last entry). The nudges are optional prompts, never a form to fill in.

Two hard rules that override everything else below:

1. **Verbatim.** Record exactly what the user says. Do not summarize, reword, condense, reorder, or "clean up" the rant. The only edits allowed are obvious typo and speech-to-text fixes (see [Correction policy](#correction-policy)).
2. **No analysis of the current entry.** Do not comment on, critique, summarize, or react to what was just logged. Logging an entry is not a conversation starter. (Nudges are generated from the *previous* entry and git state, never from the entry being written.)

## Locating the devlog file

The devlog is one Markdown file per repo, gitignored, newest entry on top.

Resolve the path in this order:

1. If a `DEVLOG.md` already exists in the repo, use it. Since it is gitignored it will not show in `git ls-files`, so locate it with `find`:
   ```bash
   find "$(git rev-parse --show-toplevel)" -maxdepth 4 -iname 'DEVLOG.md' -not -path '*/node_modules/*' 2>/dev/null
   ```
2. Otherwise pick a default location under the repo root:
   - If a top-level `docs/` exists → `docs/devlog/DEVLOG.md`
   - Else → `.devlog/DEVLOG.md`
3. Before writing, confirm the path is gitignored: `git check-ignore -v <path>`. If it is NOT ignored, add the file (or its directory) to the nearest `.gitignore` first, then proceed. The devlog is personal and must never be committed.

If the file does not exist, create it with this header, then add the first entry below it:

```markdown
# Devlog

Personal, gitignored running log. Newest entries on top.
```

## Workflow

### Step 1 — detect the mode

- **Text provided** (the user invoked with a rant, e.g. `/create-devlog spent all morning fighting the schema`, or pasted/dictated text): go straight to [Writing an entry](#writing-an-entry). Do NOT show nudges first — they already know what they want to say.
- **Empty invocation** (just `/create-devlog` with nothing): go to [Step 2 — nudges](#step-2--seed-the-nudges) first, then wait for the user to rant, then write the entry.

### Step 2 — seed the nudges

Only when invoked empty. Produce a short list of *optional* talking points, then stop and wait.

1. Read the most recent entry in `DEVLOG.md` (the top one) to get its date and find open threads.
2. Run the context script, scoped to everything since that last entry's date (or the last 7 days if the file is new):
   ```bash
   bash <skill-dir>/scripts/devlog-context.sh --since "<last-entry-date or 7 days ago>"
   ```
   It reports: current branch + dirty state, your commits, recently active branches, and your recent PRs. It only reads git/gh state.
3. Turn that into a handful of nudges, mixing two sources:
   - **Git activity** — new branches, commits, PRs opened/merged since the last entry. e.g. "You opened PR #1234 and merged the search-filters work — worth a line?"
   - **Open threads from the previous entry** — anything that read as unresolved, a question, a worry, a "still need to", a "not sure if", or something that was going badly. e.g. "Last time the rebase on the auth-refactor branch was a mess — did that settle?"

Present them plainly and briefly, and say outright they are just prompts — the user can ignore them and rant about whatever they want. Then wait for their next message. Do not interrogate; do not require them to address each one.

### Writing an entry

Get the current timestamp from the system, then prepend a new entry directly under the `# Devlog` header (newest on top). Format:

```markdown
## YYYY-MM-DD HH:MM (branch: <current-branch>)

<the user's words, verbatim, with only typo/STT fixes>
```

- The date/time and branch in the heading are factual context, not commentary — they are the only things added around the words.
- The body is the user's rant, verbatim. One entry per invocation.
- After writing, echo the logged entry back so the user can spot any bad correction. Keep it to that — no analysis, no follow-up questions, no "great progress!". If you made any correction you were genuinely unsure about, note just that one in a single short line.

## Correction policy

The user dictates by voice, so the raw text has speech-to-text errors. Fix those and obvious typos. Nothing else.

**Fix (only when the intended meaning is unambiguous):**
- Typos and misspellings.
- Homophone slips: their/there/they're, your/you're, to/too/two, its/it's, etc.
- Misheard technical terms when context makes the real term obvious (e.g. "react query" mis-transcribed, "use effect" → `useEffect`, a misheard library/branch/ticket name).
- Capitalization and sentence-ending punctuation where STT dropped it, to make the text readable.
- An obviously dropped or garbled small function word ("I going to" → "I'm going to") when the intended word is unmistakable.

**Never:**
- Summarize, shorten, expand, or rephrase.
- Reorder sentences or restructure the rant.
- Add, remove, or substitute content words that change meaning.
- "Improve" grammar, tone, or style. Casual speech, fragments, slang, and swearing are the user's voice — keep them.
- Fix anything you are not sure is an error. When in doubt, leave the original exactly as dictated.

Do not stop to ask about corrections mid-flow — the user does not want analysis while writing. Apply the unambiguous fixes, leave the uncertain bits verbatim, and flag at most the one or two genuinely ambiguous spots in a single line after logging.

## Style for the skill's own output

This is an informal personal tool, and the user's informal-writing preferences apply to the nudges, the echoed confirmation, and the file scaffolding (NOT to their verbatim words, which stay exactly as dictated):

- No em-dashes, arrows, tildes, fancy bullets, or section signs.
- Capitalize sentences properly. Plain hyphens for lists.
- Keep it short. The skill nudges and gets out of the way.
