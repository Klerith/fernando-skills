# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Purpose

This repo is a workspace for authoring Claude Code slash-command skills, specifically for a spec-driven development workflow. Skills are written in **English**, and they instruct the agent to reply in whatever language the user's prompt used.

`reference/` is a vendored copy of `mattpocock/skills` kept as a structural/style reference — do not edit it during normal work. Its own `reference/CLAUDE.md` governs that subtree.

## Skill authoring conventions

Each skill lives under `skills/<bucket>/<name>/` (e.g. `skills/engineering/spec/`) as a directory containing at minimum a `SKILL.md`. Buckets group skills by domain (`engineering/`, future: `productivity/`, `misc/`, etc.). The YAML frontmatter of `SKILL.md` must declare:

```yaml
---
name: skill-name
description: One-line description (in Spanish)
disable-model-invocation: true
argument-hint: [hint]
---
```

Use `allowed-tools` in frontmatter to restrict what Bash commands a skill may run (see `skills/engineering/spec-impl/SKILL.md` for an example that limits to read-only git/fs).

Use `!`command``shell snippets inside`SKILL.md` to inject live repo state at skill-load time (e.g., current branch, available specs). Embed them at the top of the skill body before the instructions.

Companion files (e.g., `templates/requirements.md`) sit next to `SKILL.md` (directly or in a subfolder) and are referenced by relative path within the skill body.

## The spec workflow

This repo encodes a two-skill pair, modeled on Kiro's spec + steering approach (see `docs/mental-model.md`). Everything the skills produce lives under a single `.sdd/` root in the target project:

```
.sdd/
├── config.yml            # AutoCreateBranch flag (seeded by /spec)
├── steering/             # persistent project context, shared by all specs
│   ├── product.md        # purpose, users, features, glossary
│   ├── tech.md           # stack, libraries, commands, constraints
│   ├── structure.md      # folder layout, naming, conventions
│   └── architecture.md   # general design of the whole system
└── specs/
    └── NN-slug/
        ├── requirements.md   # header (single Status line) + user stories + EARS criteria
        ├── design.md         # technical blueprint + "Steering impact" section
        └── tasks.md          # checklist with requirement references
```

### `/spec`

Phases: 0) load context — project-memory file, all steering files, recent specs; **bootstrap any missing steering file** from the codebase (confirmed by the user once) → 1) requirements: clarify the *problem* with questions (blocks of 3–5), write `requirements.md`, gate → 2) design: technical questions only where a real choice exists, write `design.md`, gate → 3) tasks: write `tasks.md`, gate → 4) finalize. If Phase 1 already settles every technical choice, the fast path writes all three documents without gates.

Templates: `skills/engineering/spec/templates/` (the three spec documents) and `skills/engineering/spec/steering-templates/` (the four steering files).

`/spec` never modifies an **existing** steering file — it records changes in the design's **Steering impact** section, and `/spec-impl` applies them after implementation, so steering always describes code that exists.

On finalize, it seeds `.sdd/config.yml` (default `AutoCreateBranch: true`) **only if the file is missing** — an existing config is never overwritten. A legacy `specs/.spec-config.yml` value is carried over.

`requirements.md` header format:

```
> **Status:** Draft
> **Depends on:** SPEC 01
> **Date:** YYYY-MM-DD
> **Objective:** One sentence.
```

The date comes from a `!`date +%F`` snippet injected at skill-load time — never from the model's own sense of the date.

**Status** lives only in `requirements.md` and is always `Draft` after saving. State transitions are human-driven — Claude must never change `**Status:**` automatically.

Valid states: `Draft` → `In review` → `Approved` → `Implemented` · `Obsolete`. Equivalents in any language are accepted (Spanish `Borrador` / `En revisión` / `Aprobado` / `Implementado` / `Obsoleto`, etc.); `/spec-impl` matches by meaning, and `/spec` follows whatever wording the existing specs in the repo already use.

Spec numbering continues across `.sdd/specs/` folders and legacy `specs/NN-slug.md` files.

### `/spec-impl`

Accepts `<NN-slug>` as argument. Phases:

1. Locate `.sdd/specs/<NN-slug>/` (all three documents must exist), falling back to a legacy `specs/<NN-slug>.md`.
2. Read the status line in `requirements.md` — abort with a standard error message if it does not mean `Approved` in some language.
3. Check the working tree is clean, then create and switch to branch `spec-NN-slug`. If the branch already exists, treat it as a resume and propose the first unticked task in `tasks.md` (legacy: infer from `git log`).
4. Execute `tasks.md` task by task: implement, run the task's validation, tick `- [x]`, pause for diff review. **It never commits** — that stays a human action.
5. Apply the design's **Steering impact** to `.sdd/steering/`, checked against the code actually written, and pause for review.

Branch creation in step 3 is gated by the `AutoCreateBranch` flag, read at skill-load time from `.sdd/config.yml` (fallback: legacy `specs/.spec-config.yml`) via a `!`cat`` snippet. Default (file or value absent) is `true` → branch is created automatically. An explicit `false` makes the skill ask `[y/N]` before creating the branch; on decline it implements on the current branch. There is still no runtime config infra — the flag is just a value injected into the prompt and interpreted by the model.

At completion, remind the user to verify acceptance criteria and mark the spec `Implemented` manually in `requirements.md` before merging.

## Distribution

The repo is consumed by users in two ways:

1. **skills.sh** (`npx skills@latest add SantiagoRensonnet/spec-driven-development-skill`) — auto-discovers public GitHub repos with `skills/**/SKILL.md`. Just push to GitHub.
2. **Multi-agent installer** (`scripts/install-to-agent.sh <agent>`) — translates skills for Cursor (`.cursor/rules/*.mdc`), Codex (`AGENTS.md` block + `.codex/skills/`), and Antigravity (`.antigravity/skills/`). Run from the _target_ repo, not this one.

`scripts/link-skills.sh` symlinks every skill into `~/.claude/skills` for local development.

## No build or test commands

There is no package manager, build step, or test suite. All skills are plain Markdown files.
