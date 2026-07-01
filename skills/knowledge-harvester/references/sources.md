# Source Playbook

Read-only everywhere. NEVER post, comment, send, schedule, or run mutating SQL. Dispatch independent source-agents in parallel. Tag every claim `verified` vs `UNVERIFIED` and cite it.

This is a template. The first time you run the skill on a project, fill in (or let the agent discover) the project-specific details: repo layout, database connection, issue-tracker keys, wiki spaces, and chat workspace.

## Table of contents
- Codebase
- Database
- Runtime / live product
- Issue tracker (Jira, Linear, GitHub Issues, ...)
- Docs / wiki (Confluence, Notion, ...)
- Chat (Slack, ...)
- Git history
- Existing docs
- Hard rules

## Codebase
- Map the repo layout first: apps, libraries, services, and the language of each. Use the project's own tooling to enumerate projects (workspace/monorepo tooling, build config) rather than guessing.
- Use **Explore agents** for breadth; require `file:line` in results.
- Capture: entry points, services/controllers, data-model entities, API endpoints + DTOs, key flows, feature flags, tests.

## Database
- Connect **read-only** to the project's database. Supply credentials via environment variables — never hardcode them. Confirm host/port/dbname/schema from the project's local dev config.
- If several databases exist (e.g. one per service), confirm which holds the tables you need via `information_schema.tables`.
- If `psql` is unavailable, use Python + psycopg2 via the `scripts/query_db.py` helper (setup and gotchas in that file's header).
- Note the data-scoping model (multi-tenancy, row-level filters, soft-deletes) and filter accordingly.
- Capture REAL shape: row counts, status mixes, date ranges, enum distributions. Numbers ground the docs and expose data-quality limits.

## Runtime / live product
- If the product has a UI, drive it **read-only** in a browser (e.g. a remote-debugging / CDP session) to see real behavior. Do not save or submit anything that mutates data.
- Use any read-only service/admin APIs the project exposes. Read-only calls only.
- Never touch production data destructively; prefer local/staging.

## Issue tracker
- Search for the topic; capture open-vs-done, recurring bugs, volume, statuses, and assignees (ownership signal). Note the project key(s) and site/workspace once, then reuse. Use the read-only search/detail tools of whatever tracker MCP is connected.

## Docs / wiki
- Search the project's wiki spaces for runbooks, PRDs, decisions, and diagrams, and note their staleness (last-updated date).

## Chat
- Read-only search/read tools only. Capture tacit knowledge, recent incidents, recurring gripes, and who answers questions about the topic (ownership). NEVER send, schedule, or draft a message.

## Git history
- `git log`, `git blame`, `git log -S"<symbol>"`, `git log --oneline -- <path>` for why-decisions and contributors. Map top contributors per area into `ownership.md`. For PRs use `gh pr list`, `gh pr view`.

## Existing docs
- Look for a docs tree already in the repo (e.g. `docs/`). Read what is there, cross-link and extend; do not duplicate.

## Hard rules
- Read-only. No POST/PUT/DELETE/comment/send/schedule/draft on any system. No INSERT/UPDATE/DELETE/TRUNCATE/ALTER/CREATE/DROP SQL.
- Tag every claim `verified` (checked against code/data) vs `UNVERIFIED` (asserted only — a stale doc, a single chat opinion). Never present an assertion as fact.
