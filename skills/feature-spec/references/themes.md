# The 12 Themes (the axes a spec must pin down)

These are universal — every feature's intended behavior lives on these axes. Their *content* and *weight* change with the feature archetype, but the axes are constant. For each inventory item and each flow, the spec resolves every applicable theme. Each theme also generates a class of questions (Phase 5) and powers a class of checks in `prove-behavior`.

Apply the **four lenses** (Product / UX / Architecture / DX — see SKILL.md "Lenses") to every theme: the same element yields different, sharper questions through each lens, and the real question is often "why does this exist / is this the right primitive?" not "what is its correct behavior?". Atoms below the feature (shared components) carry their **own** spec — this spec composes them and leans on theirs (see SKILL.md "Spec hierarchy").

## 1. Inventory (the spine — completeness gate)
Every interactive element and every screen/route/transition, enumerated. If one toggle or route is unlisted, the spec is incomplete. Powers: coverage gate + sibling-parity checks.
Questions: "Is this the complete list of screens? Of elements on this screen? Is any element conditionally rendered (flag/role/data) and therefore easy to miss?"

## 2. Intent
What each element/flow is *for* — the user goal, not the mechanics. Powers: claim-vs-reality (does the control serve its stated purpose).
Questions: "Why does this control exist? What is the user trying to accomplish? Who is the user (role)?"

## 3. Behavior
What each element does when used — the exact effect of a click, toggle, selection. Powers: claim-vs-reality.
Questions: "What exactly happens on click? Does it have more than one effect? Does it depend on other state?"

## 4. Input and constraint
For every field/input: valid inputs, bounds, allowed sets, formats, required-ness, units, AND explicitly what is NOT allowed. This is where domain invariants are captured — the things code cannot tell you (a percentage is 0–100, a price is non-negative). **Derive a field's TYPE/FORMAT constraint from the validation source of truth (the schema), not from the editor's affordance or the field's name** — and flag any mismatch (a "URL" editor over a `z.string()` field promises what the schema does not enforce; that is a defect, not a fact to record). Where a schema validator already exists (a duration regex, a url type), the spec says "reuse it," not "hand-roll a check." Powers: the adversarial / domain-invariant lens + claim-vs-reality.
Questions: "What is the valid range? The unit? What is the hard maximum/minimum? Is empty allowed, and what does empty MEAN (unset vs zero vs default)? What characters/formats are rejected? What is the locale policy for numbers (comma decimal? thousands separators?)?"

## 5. Data lineage
Per field/area: source → transforms → sink, plus downstream consumers. Where a value is born, what mutates it, where it persists, and who else reads it. Powers: round-trip fidelity (display == stored, survives save+reload).
Questions: "Where does this value come from on load? What transforms it between input and storage? Where is it persisted? Who downstream consumes it, and are they sensitive to format?"

## 6. Presentation and variant matrix
What is rendered or produced, and across which contexts it must survive: viewport, device (mobile/web), output target (email client, print, PDF), locale/language variant, theme, feature flag. Dominant for composition/render-output features. Powers: render-fidelity checks across the matrix cross-product.
Questions: "What surfaces does this render on? Which devices/clients must it survive? Which locales, and is each locale's output correct (not just present)? Does preview match the actually-sent/published artifact? What changes per theme/flag?"

## 7. State and lifecycle
dirty/clean, loading/empty/error/success, and the semantics of save / reset / cancel / undo / discard, optimistic vs server-confirmed. **Includes per-control state sets** (the nitty-gritty that is easy to forget): a Save button's default / loading / disabled / error states, an input's invalid/disabled states, etc. — every control's states are part of the spec, and many compose down from shared atoms (see hierarchy note below). Powers: seam + recovery-completeness checks.
Questions: "What does 'dirty' mean here? What exactly does Reset restore (which state slices, including child/local buffers and derived flags)? Is a save optimistic or confirmed? What does the Save button show while the API is in flight, on error, when disabled? What are the loading/empty/error states and when do they show?"

## 8. Navigation and flow
Entry points (which screen the user came from), exit points (where each action leads), state carried across screens, back/forward, deep links, resume. Dominant for wizard/multi-step. Powers: seam checks across navigation boundaries.
Questions: "Where does the user arrive from? Where does each action take them? What state survives navigation? What happens on back/forward, refresh, deep-link into the middle of a flow?"

## 9. Seams
The internal handoffs where a value crosses an async, component, or view-to-model boundary: debounce/throttle → commit, server/prop-sync → local state, view → model, child → parent. Named explicitly so the tester attacks them. Powers: the seam lens (the highest-leverage class — bugs live here).
Questions: "Where is there a debounce/throttle, and what reads the value before it fires? Where does a server refresh write into state the user is editing? Where can the on-screen value diverge from the stored model?"

## 10. Error behavior
How an error surfaces, how to reproduce it, whether it is actionable, the user's recovery path, and what the system does (rollback / retain / log). Reproducible and actionable are requirements, not descriptions. Powers: error-containment + recovery lens (incl. blast radius).
Questions: "What errors can occur here? How does each surface to the user? Is the message actionable? What can the user DO to recover? What does the system do — roll back, retain the input, log? Can one failure take down siblings or the whole screen?"

## 11. Non-negotiables
The invariants that must NEVER break, pulled to the front as must-pass tests. A curated superset drawn from the other themes (hard value bounds, no silent data loss, blast-radius containment, reversibility, idempotency for actions). Powers: the must-pass adversarial targets.
Questions: "What must never happen here? What is the worst-case data loss or wrong action, and what prevents it? Is any irreversible action protected (confirm, idempotency)?"

## 12. History
Known past failures, one line each, each a regression target. Sourced from Jira, Slack, git, and the user. Powers: the regression suite.
Questions: "Has this broken before? What was the bug? Was it fully fixed or worked around? What class of input caused it?"

---

# Archetypes (which themes carry the load)

The same 12 themes, weighted by feature type. Declare the blend in Phase 0.

- **Form / configuration** (e.g. a settings/config screen): heavy on 4 (input/constraint), 5 (lineage), 7 (lifecycle: save/reset/dirty), 9 (seams). Light on 6.
- **Composition / render-output** (e.g. an email or template composer): 6 (presentation/variant matrix) dominates — mobile vs web vs email-client rendering, preview vs actually-sent, language variants. Plus the form themes for the editing controls.
- **Action / commit** (e.g. message send, payments, provisioning): heavy on 11 (non-negotiables: idempotency, no double-send, respect opt-outs), 10 (error behavior), and confirmation semantics. Defining question: "what does this irreversibly do, and what happens when it half-fails?"
- **Browse / list / dashboard**: heavy on 7 (state matrix: empty/error/large), 8 (navigation/drill), and behavior at scale.
- **Wizard / multi-step**: 8 (flow) dominates — step order, back/forward, partial completion, resume, cross-step state.

A feature is usually a blend (an email editor is composition + form). Name the blend so effort goes where the risk is.
