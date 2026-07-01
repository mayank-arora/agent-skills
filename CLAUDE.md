# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A distributable collection of Claude Code agent skills. No build, test, or lint — every file is Markdown. The "code" is the skill definitions and the convention they follow.

Distributed via the [skills CLI](https://github.com/vercel-labs/skills): `npx skills add mayank-arora/agent-skills`. Because skills install by name, the `name:` in frontmatter is the public identifier — renaming a skill breaks existing installs.

## Skill structure

Each skill lives in `skills/<name>/` with a `SKILL.md` entry point:

```
---
name: <kebab-case, must match directory name>
description: "<what it does + explicit 'Use when' cases + 'Triggers on' phrases>"
---
<the skill body>
```

The `description` is load-bearing: it's the only thing the agent sees when deciding whether to invoke the skill, so it must enumerate concrete trigger phrases and use-cases, not just summarize. Keep it in the imperative/third-person style of the existing two skills.

**Progressive disclosure.** Large skills split domain detail into `skills/<name>/references/*.md`, loaded on demand from SKILL.md via a relative link (see `feature-ultra`, which loads `references/{frontend,backend,cli,mobile}.md` only after detecting the domain). Keep SKILL.md as the always-loaded core; push anything conditional into references.

## When editing skills

`README.md` is the published catalog — its per-skill "What it does / Use when / Trigger phrases" sections mirror each SKILL.md's `description`. Changing a skill's purpose or triggers means updating both, or they drift.
