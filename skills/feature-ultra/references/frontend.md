# Frontend / UI Domain Checks

Additional analysis for features in browser-based, desktop, or web applications.

## Table of Contents
- [UI State Hazards](#ui-state-hazards)
- [User Behavior Patterns](#user-behavior-patterns)
- [Rendering and Timing](#rendering-and-timing)
- [Feedback and Transitions](#feedback-and-transitions)
- [Frontend Anti-Patterns](#frontend-anti-patterns)

---

## UI State Hazards

### Dialog/Modal State
- If a dialog writes to global state, what happens when the user closes it without saving? Is state cleaned up?
- If two dialogs can be open simultaneously, do they share state? Can one overwrite the other's data?
- If a dialog triggers an async operation and the user closes it before completion, what happens to the result?

### Navigation State
- Browser back button: does it return to the expected state, or does it break the flow?
- Deep linking: if a user bookmarks a URL mid-flow, does reopening it produce a coherent state?
- Route changes during async operations: does the operation complete? Is the result lost? Does a callback try to update an unmounted component?

### Form State
- If a form submission fails, is user input preserved or lost?
- If the user navigates away from a form with unsaved changes, is there a warning?
- If multiple form submissions happen (double-click), are they deduplicated?

### Optimistic Updates
- If the UI updates optimistically but the server rejects the change, does the UI roll back correctly?
- If the rollback fails (component unmounted, state changed), what does the user see?
- Is the optimistic state distinguishable from confirmed state?

---

## User Behavior Patterns

Check these real-world usage patterns:

1. **Double-click / rapid re-trigger** — User clicks a button twice. Does the operation run twice? Is there debouncing?
2. **Browser back/forward** — Does navigation history produce valid states?
3. **Multiple tabs** — If the same app is open in two tabs, do they conflict? SharedWorker, BroadcastChannel, or localStorage events?
4. **Copy-paste into inputs** — Does paste trigger the same validation as typing? What about pasting rich text into plain text fields?
5. **Interrupted workflows** — User starts a flow, switches to another tab, comes back 30 minutes later. Is the session still valid? Are tokens expired?
6. **Zoom / resize** — Do layouts break at extreme viewport sizes? Do fixed-position elements overlap?
7. **Slow network** — On 3G or throttled connections, does the UI degrade gracefully? Are there loading states for everything async?
8. **Offline → online** — If the network drops mid-operation, what happens when it returns? Are failed requests queued and retried?

---

## Rendering and Timing

### Race Conditions
- Component mounts, triggers fetch, unmounts before fetch completes. Is the response discarded or does it try to set state on an unmounted component?
- Two rapid state changes trigger two re-renders. Does the second render use stale data from before the first completed?
- Debounced search: if the user types fast, do out-of-order responses produce wrong results? (Response for "ab" arrives after response for "abc")

### Layout and Paint
- Does adding/removing elements cause layout shift that moves interactive elements? Could the user accidentally click the wrong thing?
- Are animations/transitions cancelable? If state changes mid-transition, does it complete to the wrong state?
- Do large lists use virtualization? What's the performance at 1000+ items?

---

## Feedback and Transitions

### Required vs Optional Steps
- If a step is required, is the UI persistent (never in an auto-dismissing toast or tooltip)?
- If a required UI element disappears (dialog closes, page navigates), can the user still find and complete the step?
- If the user starts a new operation while a required step is pending, is there a warning?

### Surface Changes
When the active UI surface changes (dialog closes, view navigates, tab switches), verify:
- Feedback for the completed operation is visible on the NEW surface
- The user knows where to look for the result
- No information is lost in the transition

### Loading States
- Every async operation should have a loading indicator
- Loading indicators should have timeouts (don't spin forever)
- Error states should reset loading indicators (check `finally` blocks)
- Skeleton screens vs spinners: is the choice appropriate for the expected duration?

---

## Frontend Anti-Patterns

| Anti-Pattern | Description |
|-------------|-------------|
| **Ephemeral Action** | Required user action placed in an auto-dismissing toast. Toast disappears, user can't complete the workflow. |
| **Flash Dialog** | Dialog opens and immediately closes due to async state change. User sees a flash. |
| **Invisible Transition** | State changes on a different view/tab with no cross-surface indicator. |
| **Zombie Callback** | Async callback fires after component unmounts, causing errors or state corruption. |
| **Double Submit** | No debounce or disable on submit button. Operation runs twice. |
| **Scroll Hijack** | Programmatic scroll or focus change disorients the user mid-interaction. |
| **Modal Trap** | Modal opens another modal. Closing the inner one doesn't return to the outer one cleanly. |
