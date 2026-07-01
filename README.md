# Agent Skills

A collection of Claude Code skills for systematic thinking and pre-implementation analysis.

## Skills

### Clarify

Adaptive thinking partner that helps clarify, challenge, and refine ideas through persistent questioning. Auto-detects domain (product, architecture, debugging, process) and user mode (exploring, deciding, refining) to adapt its question style.

**What it does:**
- Asks focused questions that build on your answers
- Actively pushes back on weak reasoning — flags contradictions, challenges assumptions, stress-tests claims
- Produces context-appropriate artifacts when done (design brief, decision record, hypothesis list, decision matrix, or key insights)

**Use when:**
- Brainstorming or exploring an idea before implementation
- Requirements are vague and need clarification
- Making architectural or product decisions
- Debugging and need to form hypotheses
- Refining an approach that's mostly decided

**Trigger phrases:** `brainstorm`, `clarify`, `think through`, `explore`, `help me figure out`, `what should I consider`, `help me decide`

---

### Feature Ultra

Systematic pre-implementation analysis that finds unknown unknowns — usability gaps, broken flows, state conflicts, concurrency hazards, error dead-ends, and edge cases BEFORE code is written. Fire-and-forget: runs all phases autonomously and delivers a severity-ordered report.

**What it does:**
1. Maps the state topology (shared state, singletons, external dependencies)
2. Enumerates all entry points (user actions, programmatic triggers, scheduled jobs, webhooks)
3. Traces flows end-to-end (trigger → validation → processing → side effects → cleanup)
4. Runs collision analysis across all flow pairs (concurrency, contamination, interruption)
5. Analyzes failure modes (network errors, partial success, timeouts, resource exhaustion)
6. Checks entity lifecycle invariants (creation, visibility, updates, deletion, duplicates)

Includes domain-specific checks for frontend, backend, CLI, and mobile.

**Use when:**
- Before implementing any feature that changes existing behavior
- Before adding async/background processing
- When a feature touches shared state
- When a feature has multiple entry points or triggers
- When reviewing a plan for hidden failure modes

**Trigger phrases:** `analyze this feature`, `what could go wrong`, `check for edge cases`, `will this break anything`, `find problems with this`, `unknown unknowns`

---

### Senpai

Senior-dev walkthrough of a feature, branch, or PR so you can own code you didn't write line-by-line. Reconstructs the decision sequence, produces an "if I want to change X, touch Y" pointer table, then tests understanding with a hands-on exercise and comprehension questions.

**Trigger phrases:** `senpai`, `walk me through this feature`, `onboard me onto this branch`, `explain what got done`, `quiz me on this`

---

### Handoff

Compacts the current conversation into a handoff document (saved to a temp dir) so a fresh agent can continue the work. Includes a "suggested skills" section and references existing artifacts by path instead of duplicating them.

**Trigger phrases:** `handoff`

---

### Create Devlog

Appends a verbatim, per-repo, gitignored devlog entry (`DEVLOG.md`) and seeds talking points from recent git/PR activity. Records dictated notes word-for-word — never summarized or reworded.

**Trigger phrases:** `devlog`, `create devlog`, `log this`, `dev log entry`

---

### PR Comments

Fetches PR review comments, researches each against the codebase, assesses validity, and presents an action plan — for approval **before** any code changes.

**Trigger phrases:** `pr-comments`, `review pr comments`, `check pr feedback`

---

### PR Post

Post-push CI verification and fix workflow — checks GitHub Actions status after a push and fixes failures.

**Trigger phrases:** `pr-post`, `check ci`, `fix ci`, `are checks passing`

---

### Add Tech Debt

Appends a tech-debt entry (architectural smells, non-blocking design flaws discovered mid-task) to a project tech-debt log.

**Trigger phrases:** `add tech debt`, `log tech debt`

> Writes to `docs/tech-debt-log.md` by default — adjust the path in `SKILL.md` for your repo.

---

### Knowledge Harvester

Builds a comprehensive, source-cited knowledge base on a feature or process by fanning out across code, databases, your issue tracker, wiki, chat, and git history, saving structured docs to a `docs/features/<topic>/` tree.

**Trigger phrases:** `harvest knowledge on X`, `document everything about X`, `build the X knowledge base`

> `references/sources.md` is a template — fill in your project's sources (repo layout, DB connection, tracker/wiki/chat) on first use.

---

### Feature Spec

Builds a non-ambiguous, provenance-tagged product spec for a feature area — a behavioral oracle to test the feature against. Researches every reachable source, then interrogates you to resolve every ambiguity before writing.

**Trigger phrases:** `feature-spec`, `write the spec for X`, `spec out this feature`

> Writes to `docs/features/<area>/product-spec.md` — adjust for your repo's docs layout.

## Installation

### Option 1: npx skills (recommended)

Use the [skills CLI](https://github.com/vercel-labs/skills) to install across any supported agent:

```bash
npx skills add mayank-arora/agent-skills
```

Install specific skills or target specific agents:

```bash
# Install a specific skill
npx skills add mayank-arora/agent-skills --skill clarify

# Install to a specific agent
npx skills add mayank-arora/agent-skills -a claude-code
```

## Skill Pruning

Every skill you download is personalized to whoever wrote it — not just their directories and commands, but their taste and judgment calls. Generalizing only goes so far. So prune any skill you install to fit you and your repo:

1. **Run it** and let it read the output it produced. Have it check that output against the original intent and judge whether it will actually succeed for you.
2. **If not, edit the skill** — reword instructions, fix paths, change whatever's off.
3. **Run it again.**

Two or three passes usually gets it right. It works best when you actively steer — tell it what's good and what isn't as it goes.