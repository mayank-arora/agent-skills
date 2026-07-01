---
name: knowledge-harvester
description: Build a comprehensive, source-cited knowledge base on a topic in your project - either a product feature (e.g. checkout, search, billing, notifications, importer, ...) or a company "block" (a process, deployment pipeline, team, or org area) - by fanning out across every reachable source (codebase, databases, issue tracker, wiki, chat, git history) and saving structured docs to docs/features/<topic>/. Use when the user wants to "harvest"/"document everything about"/"build a knowledge base for"/"deeply research"/"become the expert on" a feature or area, when onboarding onto an unfamiliar part of the product, or when they want to be able to answer any question about a topic confidently. Triggers: "harvest knowledge on X", "document everything about X", "/knowledge-harvester X", "what do we know about X end to end", "build the X knowledge base".
---

# Knowledge Harvester

Produce an institutional knowledge base on ONE topic, grounded in real sources, so a reader can answer almost any question about it confidently and knows exactly where to dig for the rest. The reader is a PM-minded owner: they want what it does, what it doesn't, the constraints, the quirks, the past decisions, the friction, the ownership, and the future.

## Defaults (override only if the user says otherwise in the request)
- **Depth: EXHAUSTIVE.** Maximum parallel fan-out, verify load-bearing claims, then a completeness-critic pass that loops until it finds nothing new. (Honor "quick" or "standard" if the user asks.)
- **Sources: harvest EVERYTHING automatically**, including live data and chat. Do not pause to ask permission to READ.
- **HARD RULE - read only.** NEVER post, comment, send, schedule, draft, PUT, POST, DELETE, or run mutating SQL on any system (issue tracker, wiki, chat, prod, DB, GitHub). Harvesting is observation, never mutation. This overrides "harvest everything."
- **Output:** `docs/features/<topic>/` (kebab-case topic). Create the tree if it does not exist.

## Before starting
Read all three reference files - they hold the source playbook and the project-specific details that make this skill work:
- `references/sources.md` - exact tools, credentials, ports, JQL/CQL, and gotchas for every source. READ FIRST.
- `references/output-structure.md` - the per-file purpose and which files apply to a feature vs a company-block topic.
- `references/house-style.md` - confidence tagging, citation format, tone.

## Workflow

Use parallel subagents (the Agent tool) for breadth - dispatch independent harvest agents in a single message so they run concurrently. (If the user explicitly opts into the Workflow tool, an exhaustive run can be orchestrated there instead; otherwise use parallel Agent calls.)

### Phase 0 - Scope
- Restate the topic. Classify it: **product feature** vs **company block**. This selects the output file set (`references/output-structure.md`).
- Write the list of questions a PM should be able to answer about this topic. These are the coverage targets; every one must end up answered or listed in `open-questions.md`. Always include the BUSINESS case (what problem it solves, who pays, why they care, the revenue/retention angle) as a coverage target, not just the technical surface.

### Phase 1 - Inventory existing knowledge (never duplicate)
- grep the repo's docs tree for the topic. Read any sibling feature docs. Plan to cross-link and extend, not restate.

### Phase 2 - Fan out the harvest (parallel agents, one per source-area)
Dispatch concurrently (exact tools/queries in `references/sources.md`):
1. **Code map** (Explore agents) - entry points, services/controllers, key files with file:line, data model, API endpoints + DTOs, feature flags, tests.
2. **Data model + live data** - query the local DB; capture real counts, status mixes, date ranges, enum distributions. If the DB is unreachable, fall back to the latest snapshot in `data-flow.md` and label it.
3. **Prod / runtime** - any read-only service/admin API and a CDP browser for the product's UI surfaces.
4. **Jira** - history, open vs done, bug patterns, statuses, volume, assignees.
5. **Confluence** - runbooks, PRDs, decisions, diagrams.
6. **Slack** - recent threads, incidents, gripes, who answers questions about this topic (ownership signal).
7. **Git history** - why-decisions and top contributors per area (feeds ownership).

For EXHAUSTIVE, scale each area to several agents (e.g. code split by layer; Jira split by open/closed/bugs) and keep going until a round returns nothing new.

### Phase 3 - Verify
- For every load-bearing claim, confirm against a second source or the code/data itself. Tag `verified` vs `UNVERIFIED`. Adversarially re-check anything surprising (spawn a skeptic agent whose job is to refute it).

### Phase 4 - Synthesize
- Write the output files per `references/output-structure.md`, in the house style. Every non-obvious claim carries a citation (file:line / ticket key / URL / DB query). Build `sources.md` as you go.

### Phase 5 - Completeness critic (exhaustive)
- Spawn an agent asking: "What is missing - a source not consulted, a PM question unanswered, a claim still UNVERIFIED, an entity/endpoint/ticket not covered?" Turn its findings into another harvest round. Repeat until dry. Log anything deliberately left out in `open-questions.md` - never silently truncate.

## Orchestration rules (avoid the double-write trap)
- **One writer per file.** If a subagent owns a file, the main agent must NOT also write it. Pick a lane per file.
- **Subagents own the harvested files; the main agent writes only the index** (`README.md`, `sources.md`, `open-questions.md`) and only AFTER all harvest agents have returned, so the index reflects what actually landed.
- **Subagents return short summaries, not full file contents** (they write the file themselves), so the main agent's context stays lean.
- **Warn before a big fleet.** An exhaustive run can be many agents and well over a million tokens and tens of minutes. For a large run, tell the user the rough scale first. If the main agent looks idle, it is probably waiting on long subagents, not stuck.

## Output contract
Write to `docs/features/<topic>/`. Always include `README.md` (TL;DR + status + a nav table linking every file) and `sources.md`. Include `business-use-case.md` for product features (the commercial "why"). Include the rest per topic type. Date every file and mark live-data facts as a point-in-time snapshot.

## Helper
- `scripts/query_db.py` - read-only query against a local Postgres DB. Setup and gotchas in `references/sources.md`.
