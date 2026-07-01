---
name: pr-post
description: >
  Post-push CI verification and fix workflow. Use when: (1) user says "pr-post",
  "check ci", "check actions", "fix ci", or "are checks passing", (2) after pushing
  code to a PR branch, (3) when the user wants to verify GitHub Actions status and
  fix any failures.
---

# PR Post

Check GitHub Actions on the current PR, diagnose failures, and fix them.

## Workflow

1. Find the current PR:
   ```bash
   gh pr view --json number,url,title
   ```

2. Wait for all checks to finish, then check CI status:
   ```bash
   gh pr checks <pr-number> --watch --fail-fast
   ```
   This blocks until all checks complete and exits non-zero if any fail.

3. If all checks pass, report success and stop.

4. If any checks fail, identify the **latest** run for the HEAD commit and get failed job logs:
   ```bash
   # List runs for the HEAD commit to find the correct run ID
   gh run list --commit $(git rev-parse HEAD) --json databaseId,status,conclusion,name --limit 5
   # Then get failed logs from the correct run
   gh run view <run-id> --job <job-id> --log-failed
   ```
   **IMPORTANT:** Never reuse a run ID from a previous step or an earlier push — always derive it from the HEAD commit or the failing check's link URL. Multiple workflow runs may exist; pick the one that matches the failing check name.

5. Diagnose the failure from logs. Common causes in this repo:
   - **Lint errors** — ESLint zero-warnings policy, import/no-duplicates, React Compiler
   - **Type errors** — missing types, wrong imports
   - **Build failures** — missing dependencies, broken imports

6. Fix the issue in code, commit with `fix: <description>`, push.

7. Re-check CI status. Repeat until all checks pass or the issue needs user input.

## Rules

- Never force-push unless explicitly asked
- Never skip pre-commit hooks
- If a failure is unclear or outside the codebase (infra, flaky test, permissions), report it and ask the user instead of guessing
