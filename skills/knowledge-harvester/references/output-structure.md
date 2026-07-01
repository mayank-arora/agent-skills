# Output Structure

Write to `docs/features/<topic>/` (kebab-case topic, e.g. `checkout`, `search`, `release-pipeline`). Keep each file scannable: lead with a 1-3 line TL;DR, use tables for enumerations, put citations inline. If a file grows past ~300 lines, split it.

## Always (both topic types)
- **README.md** - one-paragraph TL;DR, current status, and a nav table linking every other file with a one-line hook. This is the fresh-session entry point; a reader should orient from this file alone.
- **sources.md** - every source consulted: ticket keys (with status), wiki URLs, chat permalinks, file:line anchors, DB queries run, endpoints hit. Note coverage gaps and anything deliberately skipped.
- **open-questions.md** - each unknown plus exactly where or who to get the answer (a file to read, a person to ask, a ticket to file).

## Product feature (e.g. checkout, search, billing, notifications, importer, ...)
- **overview.md** - what it is, what it's for, who uses it (end user / support / ops / admin), where it lives in the product.
- **capabilities.md** - what it does, what it explicitly does NOT do, limits, constraints, quirks, edge cases, failure modes. This is the most valuable file - be specific and cite.
- **architecture.md** - code map (services, key files with file:line), data flow, dependencies, feature flags, deployment shape.
- **data-model.md** - entities/tables, relationships, enums, and REAL data shape (counts, distributions, date ranges from the live DB, dated).
- **apis.md** - endpoints, request/response contracts, auth/permissions, who calls them.
- **history-and-decisions.md** - notable epics/bugs/migrations, why past decisions were made (git + wiki + tickets), what changed and when. Convert relative dates to absolute.
- **ownership.md** - who built it, who owns it now, who to ask. Derive from git authors, ticket assignees, and chat.
- **frustrations-and-friction.md** - user pain, recurring support tickets, chat gripes, known tech debt, manual workarounds.
- **business-use-case.md** - the commercial "why": the business problem it solves, the jobs-to-be-done, who benefits and how (customer revenue/retention, user experience, company ARR/stickiness), pricing/packaging if known, and why a customer chooses it. Keep distinct from future-and-market.md (this is the present commercial case; that is the forward roadmap).
- **future-and-market.md** - roadmap, ideal future state, market/competitive angle, strategic intent.
- **glossary.md** - domain terms a newcomer needs.

## Company block (process, pipeline, team, org area)
Use README.md, sources.md, open-questions.md, plus:
- **overview.md** - what the block is and why it exists.
- **how-it-works.md** - the steps/flow, systems involved, triggers and owner at each step.
- **ownership.md** - who's who, who does what, who is responsible (the org-chart slice for this block).
- **friction.md** - where it breaks, manual steps, recurring pain, volume.
- **future.md** - how it should work, automation opportunities, blockers.
- **business-case.md** - why this block matters to the business: cost, risk, and revenue/retention impact, and what breaks commercially if it fails.

## Notes
- Pick only the files that have real content. An empty file is worse than a noted gap in `open-questions.md`.
- Reuse and link existing docs rather than copying.
