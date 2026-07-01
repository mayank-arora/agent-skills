---
name: pr-comments
description: >
  Fetch PR comments, research each one against the codebase, assess validity, and present
  an action plan. Use when: (1) user says "pr-comments", "review pr comments", "check pr feedback",
  (2) user pastes a GitHub PR URL and wants to understand/triage the comments, (3) user wants to
  plan responses to code review feedback. CRITICAL: present the plan for approval before making
  any code changes.
---

# PR Comments: Fetch, Research, Plan

Fetch all comments from a GitHub PR, research each one against the codebase and project
conventions, assess validity, and present a prioritized action plan. Never start implementing
until the user approves.

## Workflow

### 1. Fetch Comments

Extract the PR number from the user's input (URL or number). Fetch all comment types in parallel:

```bash
# PR-level comments
gh api /repos/{owner}/{repo}/issues/{number}/comments

# Inline review comments (includes diff_hunk, path, line)
gh api /repos/{owner}/{repo}/pulls/{number}/comments

# Review summaries
gh api /repos/{owner}/{repo}/pulls/{number}/reviews
```

Use `jq` to extract: `author`, `body`, `path`, `line`, `diff_hunk`, `in_reply_to_id`, `created_at`.

Group replies by `in_reply_to_id` to reconstruct threads.

### 2. Display Comments

Format each comment clearly:

```
- @author file.ts#line:
  > quoted comment text
```

Include diff hunks for inline comments. Nest replies under their parent.

### 3. Research Each Comment (NON-NEGOTIABLE: thorough codebase investigation)

**You MUST perform deep, thorough codebase research before rendering any verdict.** Surface-level
searches (a single grep, reading only the referenced file) are NOT sufficient. Every verdict must
be backed by evidence from actually reading the relevant code. Use the Agent tool with Explore
subagents to parallelize research across all comments simultaneously.

For **every** comment, complete ALL applicable steps:

#### a) Read the code under review
- Read the full referenced file — not just the commented line, but enough context to understand the component/module's architecture
- Read surrounding files in the same directory to understand local patterns

#### b) Find existing patterns in the codebase
- **Search for how the same thing is done elsewhere** — if the comment suggests using an enum, find where that enum is used and where raw strings exist. If it suggests a different architecture, find what pattern other modules follow.
- **Count and compare** — don't just find one example. Find ALL examples to determine what the established pattern actually is (e.g., "5 out of 6 services do X, so X is the convention").
- **Check the specific app/module** the PR touches, not just the monorepo in general — local conventions may differ from global ones.

#### c) Verify against project conventions
- Check CLAUDE.md, MEMORY.md, and any team-conventions docs
- The comment may align with or contradict established patterns — cite which

#### d) Verify technical claims
- **For API/framework suggestions** (NestJS pipes, React patterns, etc.): read the actual framework configuration in the codebase (e.g., global pipes, query parser settings, middleware) to confirm whether the issue is real
- **For type/runtime mismatch claims**: trace the data flow from source to consumer to verify
- **For performance claims**: check if the objects in question are lightweight or heavy, and whether the pattern is used elsewhere without issue
- **For React/TypeScript comments**: verify against React version (19 = ref-as-prop, no forwardRef), project lint rules, and framework docs

#### e) Apply extra scrutiny to bot comments
- Bot reviewers (Copilot, CodeRabbit, etc.) are frequently wrong — they pattern-match without codebase context
- Before accepting a bot suggestion, verify it against how the codebase actually works
- Check React/NestJS/framework docs if the bot flags a pattern as problematic

#### f) Read surrounding code
- Understand if the suggestion fits the component's architecture and the patterns of sibling modules

### 4. Assess & Classify Each Comment

For each comment, provide:

1. **Valid / Invalid / Partially Valid** — is the suggestion correct?
2. **Why** — brief reasoning based on codebase evidence (cite files, conventions, React docs)
3. **Action** — what to do:
   - `Fix` — implement the change
   - `Fix (modified)` — the comment identifies a real issue but the suggested fix needs adjustment
   - `Skip` — the comment is incorrect or not applicable, explain why
   - `Discuss` — needs user input to decide
4. **Difficulty** — trivial / small / medium

### 5. Present the Plan

Output a structured plan organized by file, grouping related comments:

```
## Plan

### file.tsx

#### Comment 1: @author — "summary of feedback"
- **Verdict**: Valid
- **Reason**: [evidence from codebase research]
- **Action**: Fix — [specific change description]

#### Comment 2: @bot — "summary of feedback"
- **Verdict**: Invalid
- **Reason**: [why this is wrong, citing docs/conventions]
- **Action**: Skip — [explanation]

### Summary
- X comments to fix
- Y comments to skip (with reasons)
- Z comments needing discussion
```

### 6. Wait for Approval

After presenting the plan, **stop and wait**. Do not implement anything until the user
confirms which comments to address. The user may:

- Approve the full plan
- Override a verdict (e.g., "fix comment 2 anyway")
- Ask for more research on a specific comment
- Decide to skip everything

## Rules

- Never implement before the plan is approved
- Cite evidence for every verdict — file paths, line numbers, convention references
- Bot reviewers (Copilot, CodeRabbit, etc.) are frequently wrong about React patterns — always verify
- Human reviewer comments get higher default trust, but still verify against conventions
- If a comment contradicts a project convention in CLAUDE.md/MEMORY.md, flag the conflict
- When implementing approved fixes, commit them as `fixup!` commits targeting the original feature commit — not as standalone commits. This keeps the PR history clean for squash/rebase.
