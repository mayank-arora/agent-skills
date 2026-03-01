---
name: feature-ultra
description: "Systematic pre-implementation analysis that finds unknown unknowns — usability gaps, broken flows, state conflicts, concurrency hazards, error dead-ends, and edge cases BEFORE code is written. Fire-and-forget: runs all phases autonomously and delivers a severity-ordered report. Works across stacks — frontend, backend, CLI, mobile, APIs. Use this skill when: (1) before implementing any feature that changes existing behavior, (2) before adding async/background processing to what was synchronous, (3) when a feature touches shared state (global stores, caches, databases, queues), (4) when a feature has multiple entry points or triggers, (5) when moving functionality between surfaces or layers, (6) when the user asks to 'think through' or 'analyze' a feature before building it, (7) when reviewing a plan for hidden failure modes. Triggers on: 'analyze this feature', 'think through the flow', 'what could go wrong', 'check for edge cases', 'will this break anything', 'find problems with this', 'unknown unknowns', flow analysis, impact analysis, pre-implementation review."
---

# Feature Ultra — Pre-Implementation Analysis

Autonomous analysis engine. Finds the things you didn't think to worry about.

Fire-and-forget: runs all phases, delivers a severity-ordered report. No interaction required during analysis.

## How It Works

1. Detect the domain (frontend, backend, CLI, mobile, API, or mixed)
2. Run all 6 phases against the proposed feature
3. Load domain-specific reference for additional checks
4. Deliver findings ordered by severity

## Phase 1: Map the State Topology

Identify every piece of shared state the feature reads, writes, or depends on.

### What to search for

Adapt to the detected domain:
- **Stores/caches**: Global state managers, in-memory caches, memoization, singletons
- **Persistent storage**: Database tables, files, localStorage, keychain, config files
- **Transient state**: URL params, query strings, environment variables, CLI flags, session data
- **Coordination state**: Locks, semaphores, queues, channels, event buses, pub/sub topics
- **External state**: Third-party APIs, webhooks, shared resources (S3 buckets, DNS, etc.)

### For each state container, document

| Field | Read by | Written by | Cleared by | Singleton? | Scope |
|-------|---------|-----------|------------|------------|-------|
| ... | ... | ... | ... | ... | request / session / global / persistent |

**Singletons are the #1 conflict source.** Any state that holds one value at a time and is written by multiple flows is a collision waiting to happen.

**Key question:** "If two different operations both write to the same state, what happens? Who wins? Is the loser's work lost silently?"

## Phase 2: Enumerate All Entry Points

Find every way the feature can be triggered. Don't just grep for function names — trace backwards from the interface layer.

### Entry point categories

1. **Direct user actions** — buttons, commands, keyboard shortcuts, menu items, CLI subcommands, form submissions
2. **Programmatic triggers** — other code calling this function, internal events, hooks, lifecycle methods
3. **Scheduled/timed triggers** — cron jobs, timers, retry loops, polling, debounced actions
4. **External triggers** — webhooks, API calls from other services, push notifications, file watchers, message queue consumers
5. **Implicit triggers** — navigation/routing changes, mounting/initialization, config changes, environment changes
6. **Chained triggers** — Operation A completing triggers Operation B (cascades, callbacks, event handlers)

### For each entry point, document

| Entry point | Trigger type | Params/context | Pre-conditions | User/caller expects |
|-------------|-------------|----------------|----------------|-------------------|
| ... | ... | ... | ... | ... |

**Key question:** "Is there an entry point I haven't considered? What if this gets called in a context the author didn't design for?"

## Phase 3: Trace Flows End-to-End

For every entry point from Phase 2, walk through the complete journey:

1. **Trigger** — what initiates the flow
2. **Validation** — what gets checked before proceeding (inputs, permissions, preconditions)
3. **Processing** — the actual work (reads, transformations, writes, external calls)
4. **Side effects** — anything beyond the primary operation (notifications, cache invalidation, event emission, logging, audit trails)
5. **Completion signal** — how the caller knows it's done (return value, callback, event, status change)
6. **Cleanup** — what state gets reset, what resources get released, what temporary artifacts get removed
7. **Destination** — where does the user/system end up? Can they return to the previous state?

At every step, verify: does the caller know what's happening? Is there feedback if this takes longer than expected? What happens if the user/caller abandons midway?

## Phase 4: Collision Analysis

Take every pair of flows that touch shared state and analyze conflicts.

### Collision types

1. **Concurrent execution** — Two flows running simultaneously, both writing shared state. Who wins? Is the loser's work lost?
2. **Sequential contamination** — Flow A completes but leaves residual state. Flow B starts with stale/dirty context.
3. **Interruption** — Flow A started, Flow B triggered before A completes. Is A's partial state cleaned up? Can it resume?
4. **Same-entity conflict** — Two operations on the same record. Does the system detect this? Is there locking or optimistic concurrency?
5. **Cascade collision** — Flow A triggers side effects that conflict with Flow B's side effects.
6. **Resource exhaustion** — Multiple flows competing for a limited resource (connections, file handles, rate limits, memory).

### Build a collision matrix

```
              | Flow A   | Flow B   | Flow C   |
Flow A        |    —     | CONFLICT |    OK    |
Flow B        | CONFLICT |    —     | CONFLICT |
Flow C        |    OK    | CONFLICT |    —     |
```

For each CONFLICT: document what state collides, what the observable symptom is, severity (data loss / incorrect behavior / cosmetic / silent corruption), and a proposed mitigation.

**Key question:** "What's the worst thing that happens if these two flows run at the same time?"

## Phase 5: Failure Mode Analysis

**The most important phase.** Every operation can fail. Trace what happens to state, callers, and the system when things break.

### Error categories

1. **Network/IO failures** — timeout, connection refused, disk full, permission denied. The operation never completes.
2. **Rejection errors** — invalid input, auth failure, rate limit, quota exceeded. The system says no.
3. **Malformed responses** — unexpected data shape, missing fields, wrong types. Common with LLM APIs, third-party services, and loosely-typed boundaries.
4. **Partial success** — Step 1 succeeds, step 2 fails. System is in an intermediate state.
5. **Timeout/hang** — Operation takes too long or never completes. No error thrown, just silence.
6. **Resource errors** — out of memory, connection pool exhausted, file handle limit, disk space.
7. **Concurrency errors** — deadlock, livelock, race condition, lost update, stale read.

### For each error, trace

1. **State after error** — What does the state look like? Is it consistent? Is a flag stuck? Is there orphaned data?
2. **Observable symptom** — What does the user/caller see? An error message? Nothing? Incorrect data? A loading state that never resolves?
3. **Recovery path** — Can the operation be retried? Does the caller need to clear state first? Is manual intervention required?
4. **Blast radius** — Does this error affect only this operation, or does it break other features? Does it leave the system in a state where other operations also fail?
5. **Data integrity** — Did the error create orphaned records, dangling references, or inconsistent state across stores?

### Error x Flow interaction

Errors create new collision surface. Example:
- Upload fails → `status: 'error'`, `result: null`, `retryable: true`
- User triggers a different operation → Does it clear the error state? Or does the new flow see the old error?
- System auto-retries the upload → Does it conflict with the operation the user just started?

**Key question:** "After this error, what can the caller do next? If the answer is 'nothing without manual intervention', that's a critical finding."

## Phase 6: Entity Lifecycle and Invariant Analysis

Check that data entities maintain consistency throughout their lifecycle.

### Entity checks

1. **Creation invariants** — What must be true for an entity to be valid? Can it be created in a state that violates those invariants?
2. **Partial creation** — Multi-step entity creation where intermediate steps can fail. What's left in storage?
3. **Visibility timing** — When does the entity become visible to other parts of the system? Before it's fully formed?
4. **Update consistency** — If entity is updated from multiple sources, are updates atomic? Can two updates interleave and produce invalid state?
5. **Deletion cascades** — When an entity is removed, what references to it remain? Are foreign keys/references cleaned up? Are dependent entities orphaned?
6. **Duplicate risk** — If the creation operation retries (timeout, network error, idempotency failure), could duplicates be created?
7. **Temporal consistency** — If entity has timestamps, versions, or ordering, can concurrent operations produce impossible sequences?

**Key question:** "If I look at this entity after a crash halfway through its lifecycle, is it in a state that makes sense? Can the system recover from that state?"

## Output Format

Present findings as a single report, ordered by severity.

### 1. Critical Findings (data loss, corruption, security, unrecoverable states)

Each finding:
- **What**: One-sentence description
- **How it happens**: The specific sequence of events
- **Impact**: What breaks, who's affected
- **Suggested fix**: Concrete mitigation

### 2. Significant Findings (incorrect behavior, poor error recovery, race conditions)

Same format as critical.

### 3. Minor Findings (cosmetic issues, missing feedback, suboptimal experience)

Brief list with one-line descriptions.

### 4. State Map

Table of all shared state identified in Phase 1.

### 5. Collision Matrix

From Phase 4, showing all flow interactions.

### 6. Recommendations

Ordered list of changes needed, grouped by:
- **Must fix before shipping** (critical + significant with high likelihood)
- **Should fix** (significant with lower likelihood, all race conditions)
- **Nice to have** (minor findings)

## Domain-Specific Checks

After running the core phases, load the appropriate reference for additional domain-specific analysis:

- Frontend/UI applications: See [references/frontend.md](references/frontend.md)
- Backend services and APIs: See [references/backend.md](references/backend.md)
- CLI tools: See [references/cli.md](references/cli.md)
- Mobile applications: See [references/mobile.md](references/mobile.md)

For mixed systems (e.g., frontend + API backend), load both relevant references and analyze the boundary between them as an additional collision surface.

## Common Anti-Patterns

These appear across all domains. Flag them whenever found:

| Anti-Pattern | Description | Severity |
|-------------|-------------|----------|
| **Silent Failure** | Error caught and swallowed. No log, no notification, no recovery path. | Critical |
| **Singleton Collision** | Two concurrent operations writing the same shared state. Loser's work disappears. | Critical |
| **Unrecoverable Error** | Error leaves system in a state where the only recovery is restart/redeployment. | Critical |
| **Orphan Entity** | Entity created in step 1, enriched in step 2. Step 2 fails. Half-formed entity persists. | Significant |
| **Stuck State** | Operation fails but status flag never resets. System thinks operation is still in progress. | Significant |
| **Stale Context** | New operation starts with leftover state from a previous operation. | Significant |
| **Cascade Failure** | One component's failure causes dependent components to also fail, amplifying blast radius. | Significant |
| **Retry Storm** | Automatic retries without backoff overwhelm an already-struggling system. | Significant |
| **Temporal Coupling** | Operations must happen in a specific order but nothing enforces that order. | Significant |
| **Phantom Dependency** | Feature works only because of an implicit side effect that could be removed at any time. | Minor |
