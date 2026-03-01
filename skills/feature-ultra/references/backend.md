# Backend / API Domain Checks

Additional analysis for features in server-side applications, APIs, and data pipelines.

## Table of Contents
- [Data Consistency](#data-consistency)
- [Concurrency and Coordination](#concurrency-and-coordination)
- [API Contract Hazards](#api-contract-hazards)
- [Resource Management](#resource-management)
- [Observability and Recovery](#observability-and-recovery)
- [Backend Anti-Patterns](#backend-anti-patterns)

---

## Data Consistency

### Transaction Boundaries
- Is the operation atomic? If step 2 fails, does step 1 roll back?
- Are reads and writes in the same transaction, or could another request interleave between read and write (TOCTOU)?
- If using eventual consistency (replicas, caches), what happens when a read hits a stale replica immediately after a write?

### Migration Safety
- Does the feature require a schema change? Can it be deployed without downtime?
- Is the migration backward-compatible? Can old code run against the new schema during rollout?
- Is there a rollback path for the migration? What data would be lost?

### Data Integrity at Boundaries
- If data arrives from an external source (webhook, API, file upload), is it validated before storage?
- If validation is schema-based, what happens when the external source changes their schema without notice?
- Are there foreign key constraints? If not, what prevents orphaned references?

---

## Concurrency and Coordination

### Request-Level Concurrency
- If two requests modify the same entity simultaneously, is there optimistic locking (version field, ETag) or pessimistic locking?
- If using optimistic locking, does the client handle conflict responses (409) gracefully?
- If no locking, what's the worst case? Last-write-wins? Data corruption? Constraint violation?

### Background Job Hazards
- If a background job fails midway, is it retried? Is the retry idempotent?
- If the job is retried, could it produce duplicates (double-send email, double-charge)?
- If the job depends on data that might change between enqueue and execution, does it re-fetch or use stale snapshot?
- Dead letter queue: what happens to permanently-failed jobs? Is there alerting?

### Distributed Coordination
- If multiple instances run the same scheduled job, is there leader election or distributed locking?
- If using a cache as coordination mechanism, what happens on cache eviction or failure?
- Clock skew: if operations depend on timestamps across services, what's the tolerance?

---

## API Contract Hazards

### Breaking Changes
- Does the feature change an existing API response shape? Are existing clients affected?
- If adding fields, are they optional? If removing fields, is there a deprecation period?
- If changing behavior (same endpoint, different semantics), how are existing integrations affected?

### Pagination and Limits
- If the feature returns lists, is there pagination? What happens with 10,000+ results?
- If using cursor-based pagination, what happens if the underlying data changes between pages (items inserted/deleted)?
- Are there rate limits? What happens when they're hit? Is the error response clear?

### Idempotency
- Is the operation idempotent? If the same request is sent twice (network retry, client bug), does it produce the same result?
- If not naturally idempotent, is there an idempotency key mechanism?
- For operations that create entities, how are duplicates detected and handled?

---

## Resource Management

### Connection and Pool Limits
- Does the feature open new connections (DB, HTTP, gRPC)? Are they pooled? Is there a limit?
- Under load, what happens when the pool is exhausted? Does it queue, reject, or timeout?
- Are connections returned to the pool on error paths? (Check `finally` blocks, `defer` statements, connection close in error handlers)

### Memory and Compute
- Does the feature load unbounded data into memory? (e.g., "SELECT * FROM large_table" without LIMIT)
- If processing large inputs (file upload, batch operation), is it streamed or buffered entirely in memory?
- Are there compute-intensive operations (crypto, compression, serialization) that could block the event loop or exhaust thread pools?

### External Dependencies
- If the feature depends on an external service, what happens when that service is down? Is there a circuit breaker?
- What's the timeout for external calls? Is it set explicitly, or relying on defaults (which may be too long)?
- If the external service is slow (not down, just slow), does it cause cascading slowness in this service?

---

## Observability and Recovery

### Logging and Tracing
- Are errors logged with enough context to diagnose the issue? (Request ID, entity ID, user context, stack trace)
- If the operation spans multiple services, is there distributed tracing?
- Are sensitive fields (passwords, tokens, PII) redacted from logs?

### Recovery Procedures
- If the feature corrupts data, is there a fix-it script or recovery procedure?
- Is there a way to replay or re-process failed items without re-running the entire operation?
- Are there health checks that would detect this feature's failure mode?

---

## Backend Anti-Patterns

| Anti-Pattern | Description |
|-------------|-------------|
| **Naked SELECT** | Query without LIMIT on a table that could grow unboundedly. One large tenant kills the service. |
| **Fire-and-Forget Mutation** | Write operation with no confirmation of success. Caller assumes it worked. |
| **Leaky Transaction** | Transaction held open while waiting for external service response. Locks accumulate. |
| **Cache as Source of Truth** | Business logic depends on cached value. Cache eviction causes incorrect behavior. |
| **Thundering Herd** | Cache expires, all instances simultaneously hit the database to rebuild it. |
| **Implicit Ordering** | Code assumes events/messages arrive in order. Works in dev, fails in production with multiple consumers. |
| **Poison Pill** | One malformed message in a queue blocks all subsequent processing. |
| **Retry Amplification** | Service A retries → Service B retries → Service C retries. One failure produces exponential load. |
