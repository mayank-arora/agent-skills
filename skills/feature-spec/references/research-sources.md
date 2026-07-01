# Research Sources (Phase 1)

Goal: resolve everything resolvable from sources so the user only gets what genuinely needs them, and so every question is armed with context. Dispatch these as parallel research agents.

> The exact tools, credentials, ports, JQL/CQL queries, and gotchas for Jira/Confluence/Slack/DB/prod already live in `knowledge-harvester/references/sources.md`. Read that first and reuse it. Below is only what is specific to spec-writing.

## Per source — what to extract for a spec

1. **Code + git history** (Explore agents)
   - Routes/entry points, every screen, every component, every input/handler/decoder.
   - For each input: its type, the parse/format path, any guard/validator, any min/max/maxLength/pattern.
   - The data lineage: where each value is read on load and where the change handler sends it.
   - The seams: every `useDebounce*`/`useThrottle*`, every effect that syncs a prop/server value into local state, every controlled-vs-local-state pair.
   - `git log` / `git diff` for recently added AND removed behavior (a deleted or replaced editor is a regression signal).

2. **Live product** (CDP browser — drive the running app; use a known local test account/tenant for data)
   - What each screen and element actually does today. Confirm the inventory against reality, not just the code.
   - Capture the variant matrix in practice (locales, viewports) where relevant.
   - READ-ONLY: do not save/submit anything that mutates real data.

3. **Sibling specs** — other `docs/features/*/product-spec.md`
   - Shared vocabulary, cross-feature invariants, and consistency. Reuse terms; flag contradictions as questions.

4. **Jira** — decisions, the reason behind current behavior, and past bugs (History theme). Note open vs done and bug clusters.

5. **Confluence** — PRDs, design docs, runbooks for the area.

6. **Slack** — informal decisions never written down; ownership (who answers questions about this area).

7. **Existing knowledge base** — `docs/features/<area>/` from `knowledge-harvester`. If present, build on it; do not restate. The harvester gives the "what it is"; this skill adds the "what is correct, testably."

## Synthesis
Collapse all of the above into one high-level mental map (Phase 2 input): what the feature is, who uses it, what the business needs, the major screens and flows. The map is what you validate with the user before going deep.
