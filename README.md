# Agent Skills

A collection of Claude Code skills for systematic thinking and pre-implementation analysis.

## Skills

### Clarify

Adaptive thinking partner that helps clarify, challenge, and refine ideas through persistent questioning. Auto-detects domain (product, architecture, debugging, process) and user mode (exploring, deciding, refining) to adapt its question style.

**What it does:**
- Asks focused questions that build on your answers
- Actively pushes back on weak reasoning — flags contradictions, challenges assumptions, stress-tests claims
- Produces context-appropriate artifacts when done (design brief, decision record, hypothesis list, decision matrix, or key insights)

**Use when:**
- Brainstorming or exploring an idea before implementation
- Requirements are vague and need clarification
- Making architectural or product decisions
- Debugging and need to form hypotheses
- Refining an approach that's mostly decided

**Trigger phrases:** `brainstorm`, `clarify`, `think through`, `explore`, `help me figure out`, `what should I consider`, `help me decide`

---

### Feature Ultra

Systematic pre-implementation analysis that finds unknown unknowns — usability gaps, broken flows, state conflicts, concurrency hazards, error dead-ends, and edge cases BEFORE code is written. Fire-and-forget: runs all phases autonomously and delivers a severity-ordered report.

**What it does:**
1. Maps the state topology (shared state, singletons, external dependencies)
2. Enumerates all entry points (user actions, programmatic triggers, scheduled jobs, webhooks)
3. Traces flows end-to-end (trigger → validation → processing → side effects → cleanup)
4. Runs collision analysis across all flow pairs (concurrency, contamination, interruption)
5. Analyzes failure modes (network errors, partial success, timeouts, resource exhaustion)
6. Checks entity lifecycle invariants (creation, visibility, updates, deletion, duplicates)

Includes domain-specific checks for frontend, backend, CLI, and mobile.

**Use when:**
- Before implementing any feature that changes existing behavior
- Before adding async/background processing
- When a feature touches shared state
- When a feature has multiple entry points or triggers
- When reviewing a plan for hidden failure modes

**Trigger phrases:** `analyze this feature`, `what could go wrong`, `check for edge cases`, `will this break anything`, `find problems with this`, `unknown unknowns`

## Installation

### Option 1: npx skills (recommended)

Use the [skills CLI](https://github.com/vercel-labs/skills) to install across any supported agent:

```bash
npx skills add mayank-arora/agent-skills
```

Install specific skills or target specific agents:

```bash
# Install a specific skill
npx skills add mayank-arora/agent-skills --skill clarify

# Install to a specific agent
npx skills add mayank-arora/agent-skills -a claude-code
```