# Product Spec Template

The output of `feature-spec`. Every line carries a provenance tag. The spec passes only when there are zero `[needs-confirmation]` and zero `[OPEN]` tags left inside the body (residual unknowns move to the dedicated section at the end).

## Provenance tags (put one on every assertion)
- `[code]` — verified from source, with `file:line`
- `[product]` — a product/business decision the user confirmed
- `[doc:link]` — from Jira/Confluence/Slack/PRD, with the link
- `[user]` — answered directly by the user
- `[history]` — a past failure
- `[needs-confirmation]` / `[OPEN]` — NOT allowed in the final body; these are questions in progress

---

```markdown
# Product Spec — <Feature Area>

> Revision: <date> · Archetype: <blend> · Status: <complete | incomplete (N open)>
> This is a behavioral oracle, not documentation. Every line must yield a pass/fail test.

## 1. Purpose
- What the feature does, in one or two lines. `[product]`
- What the business needs from it / why it must not break. `[product]`
- Primary user(s) and their role. `[product]`

## 2. Inventory (completeness gate)
### Screens / routes
| Screen | Route | Entry from | Exits to |
|--------|-------|-----------|----------|

### Elements (every screen, every interactive element)
| Screen | Element | Type | Conditionally rendered? (flag/role/data) |
|--------|---------|------|------------------------------------------|

> If any screen or element is unlisted, mark the spec INCOMPLETE here.

## 3. Elements in detail
For each element (themes 2,3,4):
### <Element name> — <screen>
- **Intent:** what it is for. `[..]`
- **Behavior:** exact effect when used; ALL branches. `[..]`
- **Input & constraint** (fields only): valid range + unit + hard bounds; what empty means; rejected formats; locale policy. `[..]`

## 4. Data lineage (theme 5)
| Value | Source (on load) | Transforms | Sink (persisted) | Downstream consumers |
|-------|------------------|-----------|------------------|----------------------|

## 5. Presentation & variant matrix (theme 6 — depth scales with archetype)
- Surfaces rendered on; devices/clients that must be survived. `[..]`
- Locale/language variants and what is correct for each. `[..]`
- Preview vs actual-output fidelity expectation. `[..]`
- Per-theme / per-flag differences. `[..]`
- The matrix to test (cross-product of the above).

## 6. State & lifecycle (theme 7)
- Meaning of dirty/clean. `[..]`
- Loading / empty / error / success states and triggers. `[..]`
- Reset / Cancel / Undo / Discard: EXACTLY which state slices each restores (incl. child/local buffers and derived flags). `[..]`
- Save: optimistic or server-confirmed. `[..]`

## 7. Navigation & flow (theme 8)
- Entry/exit per screen; state carried across. `[..]`
- Back/forward, refresh, deep-link behavior. `[..]`
- (Wizard) step order, partial completion, resume. `[..]`

## 8. Seams (theme 9 — name every one)
| Seam | Boundary type | Risk | Expected behavior |
|------|---------------|------|-------------------|
(e.g. debounce→save: "edits made <wait> before Save must still be saved")

## 9. Error behavior (theme 10)
| Error | How it surfaces | Reproduce | Actionable? | User recovery | System response | Blast radius |
|-------|-----------------|-----------|-------------|---------------|-----------------|--------------|

## 10. Non-negotiables (theme 11)
- Numbered list of invariants that must NEVER break. Each must be a concrete, testable statement. `[..]`

## 11. Known past failures (theme 12)
| Bug | Class of input/trigger | Fixed or worked-around | Regression test |
|-----|------------------------|------------------------|-----------------|

---

## Residual open product questions
Latent questions this spec surfaced that the user could not yet answer. NOT failures — outputs. Do not invent answers.
- ...

## Question ledger (working — remove on finalize or keep collapsed)
- answered: ...
- open: ...
```

---

## Linter reminder (HARD RULE 3)
Before finalizing, reject any statement that is:
- vague ("fast", "graceful", "reasonable", "handles errors", "etc.")
- untestable (no observable pass/fail)
- unbounded (a value with no unit or limit)
- branch-incomplete (a conditional missing a branch)
Convert each into a question instead of shipping it.
