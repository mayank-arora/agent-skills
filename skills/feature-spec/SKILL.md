---
name: feature-spec
description: "Build a non-ambiguous, complete, provenance-tagged product spec for a feature area — the behavioral oracle that prove-behavior tests against. Researches every reachable source (code, live product, sibling specs, Jira, Confluence, Slack, git history) to build a mental map, then interrogates the user exhaustively to resolve EVERY ambiguity before writing. Use when: (1) user says 'feature-spec', 'write the spec for X', 'build the product spec', 'spec out this feature', (2) before running prove-behavior on a feature that has no spec yet, (3) onboarding onto a feature and wanting the ground-truth contract. One spec per feature AREA (e.g. all of the settings screen, or checkout, or the text editor). Output: docs/features/<area>/product-spec.md."
---

# Feature Spec Writer

Produce the **oracle**: an independent, non-ambiguous statement of what a feature is *supposed* to do, against which behavior can be tested. Code is the implementation under test — it cannot be its own oracle. This spec is.

A spec that contains one silent assumption is worse than no spec, because it looks authoritative while being wrong. The entire value of this skill is that **nothing reaches the page unexamined.**

> **HARD RULE 1 — ZERO ASSUMPTION.** Every statement in the spec is exactly one of: (a) verified from a cited source, (b) confirmed by the user, (c) answered by the user. If a statement is none of these, it is NOT a spec line — it is an open question. The spec is not done while a single unconfirmed assertion or open question remains. You may not "smooth over," "infer," or "reasonably assume" anything into the document.

> **HARD RULE 2 — COMPLETENESS GATE.** The spec must cover EVERY interactive element (button, field, toggle, link, menu, dialog) and EVERY screen / route / transition in the feature area. Completeness includes **states, not just elements**: every control's full state set (default / hover / focus / loading / error / disabled / empty / active) and every async surface's loading / empty / error / success. A Save button is not specified until its loading, disabled, and error states are. A spec missing one element, one flow, or one state is incomplete and must say so explicitly. Enumerate exhaustively before you specify.

> **HARD RULE 3 — AMBIGUITY LINTER.** Every statement must be: **concrete** (no "fast", "graceful", "reasonable", "handles errors", "etc."), **testable** (you could write a pass/fail check from it as written), **bounded** (every value has a unit and a limit), and **branch-complete** (every conditional enumerates ALL branches, not just the happy one). Any statement that fails the linter becomes a question — it does not get written as-is.

> **HARD RULE 4 — READ-ONLY RESEARCH.** Never post, comment, send, draft, transition, or mutate anything on any system (Jira, Confluence, Slack, GitHub, DB, prod). Research is observation only. Asking the user questions in chat is the only "write."

> **HARD RULE 5 — DO NOT SUPPRESS QUESTIONS.** Do not skip a question because the answer seems obvious, trivial, or already implied. Obvious-but-wrong is the failure mode this skill exists to catch. Source-derived facts are surfaced as confirmations (low-friction "true?/correct?"), not silently accepted. The point of a question is partly to force the user to think — a question they had not considered is a feature, not noise.

## Output

`docs/features/<area>/product-spec.md` (kebab-case area). Create the tree if it does not exist. If `knowledge-harvester` has already produced docs in that folder, build ON them (cite, extend, reconcile) rather than restating.

## Lenses — interrogate from the perspective that reveals the real question
Every element and every finding sits on a spectrum from pure technical to pure product. Ask from the lens that exposes the REAL question, and shift consciously between them:
- **Product (PM):** what should this do for the user; is this the right behavior; is this an unmade product decision in disguise (e.g. "persist local edits on reload, or show server truth?").
- **UX / usability:** what can the user actually do; how do they experience each state; is the affordance honest.
- **Architecture:** why is it built this way; is this complexity necessary; does it solve a real problem or one we created ourselves; what is the ROOT CAUSE.
- **DX:** what does this implementation choice cost; what changes downstream (validation, error handling, maintenance) even when the user-facing behavior looks identical.

**The default failure is asking "what is the correct behavior?" when the real question is "why does this exist, and is this the right primitive?"** Question the existence and the choice, not just the behavior. Two worked examples from the first run:
- A bounded number (discount 0–100) rendered with `type="text"`: the question is not "what should happen on 999" — it is "why is a bounded number not a control that enforces its bound?" The user-facing range looks identical; validation, error handling, and min/max all change with the primitive. (Architecture + DX lens. And the answer may collide with an existing convention — surface that tension, do not just flip the primitive.)
- A 300ms debounce on three inputs: the question is not "should a fast Save flush it" — it is "why does the debounce exist at all; what real problem does it solve; or does it mask a problem the code created?" (Root-cause, architecture lens.)

Two outputs of this discipline, which the spec must record:
- **Classify each resolved decision as product or technical** — it determines who decides and how it is settled.
- **When one answer resolves many questions, record it as a PRINCIPLE, not a per-element answer.** E.g. "the server is the source of truth; the UI shows server-truth overlaid with local edits; reset and reload return to truth" resolves both the refresh-wipes-edits question AND the reset question at once, and keeps the product coherent. Principles are higher-leverage than answers — hunt for them.

## Spec hierarchy (atoms → compound → feature)
A feature's editors are **compound components built from shared atoms** (Button, Input, Select). Behavior composes up a chain: atom → compound → feature. Specs layer the same way:
- Shared components (atoms) have their OWN spec and are proven by `prove-component`. Their guarantees (a Button's loading/disabled/error states, an Input's controlled behavior) are ASSUMED by everything above.
- This feature spec composes compounds and LEANS on the atom specs: declare which shared components each editor is built from, do not re-derive atom behavior — but FLAG any depended-on atom that has no spec (an unverified link in the chain).

When a feature misbehaves, the break is somewhere in this chain: a wrong atom, a compound that misuses an atom's API, or the feature wiring. The hierarchy localizes the break. If an atom is under-specified, the right move may be to spec the atom first (a separate, smaller product spec) rather than re-proving its behavior inside every feature.

## Process

### Phase 0 — Scope and archetype
- State the feature AREA in one line (e.g. "settings: the config editor", "checkout: the payment form", "email editor: the template composer").
- Classify its archetype(s) from `references/themes.md` (Form/config, Composition/render-output, Action/commit, Browse/list, Wizard/multi-step). Most features blend. The archetype decides which of the 12 themes carry the load — an email editor lives on the render-and-variant matrix; a config form lives on input-constraint and save/reset seams.

### Phase 1 — Research fan-out (build the map BEFORE asking)
Dispatch parallel research agents (one per source-area) so the questions you bring the user are armed with context and limited to what genuinely needs them. Sources and exact tools in `references/research-sources.md`:
- **Code + git history** — every entry point, route, component, handler, input, decoder, and what was recently added/removed (removed behavior is a regression signal).
- **Live product** — drive the running app (CDP browser) to see what each screen/element actually does today.
- **Sibling specs** — other `product-spec.md` files, for shared vocabulary and cross-feature consistency.
- **Jira** — decisions, past bugs (feeds the History theme), open vs done, why things are the way they are.
- **Confluence** — PRDs, design docs, runbooks.
- **Slack** — informal decisions that never got written down; who owns this.
- **Existing KB** — `docs/features/<area>/` if `knowledge-harvester` ran.

Synthesize into a **high-level mental map**: what the feature is, who uses it, what the business needs from it, the major screens and flows.

### Phase 2 — Validate the frame (do not build depth on a wrong foundation)
Present the high-level map to the user and let them correct it BEFORE generating a single detailed question. If your frame and their mental model disagree, every detail built on it is wasted. Lock the frame, then go deep.

### Phase 3 — Exhaustive inventory (the completeness gate)
Build the spine: enumerate every element and every flow (HARD RULE 2). Use the tables in `references/spec-template.md`. This is built once and is exhaustive by construction — nothing falls through.

### Phase 4 — Draft assertions per theme
Walk the 12 themes (`references/themes.md`) against every inventory item. For each, write a draft assertion tagged with provenance and confidence:
`[verified-from-code]`, `[product-decision]`, `[from-jira/confluence/slack +link]`, `[needs-confirmation]`, `[OPEN — unknown]`. Anything not `verified` or `product-decision` is a question, not yet a spec line.

### Phase 5 — Interrogate until zero open
Resolve every `[needs-confirmation]` and `[OPEN]`. Two question kinds, neither suppressed (HARD RULE 5):
- **Confirmations** — "code does X, docs imply Y. Correct?" Covers the obvious-looking things.
- **Open / conflict / edge** — genuine gaps, contradictions between two sources, and the edge/seam/variant combinations the themes generate automatically ("when A and B are both true, then what?", "refresh lands mid-edit — keep or discard?", "renders in 3 locales — what is correct for each?"). Always say WHY you are asking; the reason is what triggers the user's rethink.

Question delivery: ask in focused batches grouped by screen or theme (a handful at a time, not a 100-item dump, not a trickle). Maintain a question ledger in the draft (answered / open). **Reflect downstream implications back** when an answer has consequences: "so edits survive a refresh, which means the dirty badge stays lit and Save stays enabled — correct?" — that is where a small answer exposes a business-logic problem the user had not considered.

### Phase 6 — Ambiguity lint
Run HARD RULE 3 over the whole draft. Every vague, untestable, unbounded, or branch-incomplete statement becomes a new question (back to Phase 5). Loop until the draft passes clean.

### Phase 7 — Write the spec
Write `product-spec.md` from `references/spec-template.md`, every line provenance-tagged. Separately list any **residual product-level open questions** the user surfaced but could not yet answer (the latent design problems this process exposed) — these are an output, not a failure. Do not invent answers for them.

### Phase 8 — Re-runnable / incremental
This skill is meant to be re-run. On a later pass, load the existing spec and reconcile against new code and new user corrections rather than starting over — specs get truer each run. Record a dated revision line at the top.

## Self-improvement (meta-learning loop) — NON-NEGOTIABLE
This skill improves itself from the conversation. During and after a run, watch for a **generalizable** insight: a new lens, a new theme or check, a sharper question-pattern, a class of defect the method structurally missed, or a better framing — as distinct from a feature-specific fact. When one surfaces:

1. **Classify it.**
   - **Method-generic** (helps every future feature) → edit THIS skill (SKILL.md / references), add a dated one-line Changelog entry below. If the insight is a behavioral *check* (something a tester should run) and you also use a paired behavioral-testing skill, update that skill's checks too — a new lens here usually implies a new check there. Keep them in sync.
   - **Feature-specific** (a truth about the feature under study) → update that feature's `product-spec.md` (ledger/principles), NOT the skill.
2. **Capture in the same turn** the insight appears — the live context is the source; a later pass loses it.
3. **Guardrail (mirror the memory discipline):** only durable, generalizable learnings. A one-off preference, a transient answer, or something already covered is NOT a skill edit. If unsure whether it generalizes, leave it in the product-spec, not the skill. Don't bloat — prefer sharpening an existing rule over adding a near-duplicate.
4. **Tell the user** what you captured and where (skill vs spec), so it is visible and reversible.

## Changelog
- 2026-06-30 (config-form run): added the four lenses (Product / UX / Architecture / DX) and the "question the existence/primitive, not just the behavior" discipline; completeness gate now includes per-control STATES (loading/disabled/error); added the spec hierarchy (atoms → compound → feature); added this self-improvement loop.
- 2026-06-30 (config-form run): theme 4 now derives type/format constraints from the validation source of truth (schema), not the editor affordance or field name, and flags affordance-vs-schema mismatches (paired with a behavioral-testing check).

## What this skill is NOT
It is not feature documentation (that is `knowledge-harvester`). It is a tight, testable contract. If a reader cannot derive a pass/fail test from a line, that line does not belong here.
