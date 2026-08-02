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

Companion files (e.g., `template.md`) sit next to `SKILL.md` and are referenced by relative path within the skill body.

## The spec workflow

This repo encodes a two-skill pair:

### `/spec`

Guides the user through 4 phases: read project context → clarify with questions (blocks of 3–5) → draft each spec section one at a time with user confirmation → save to `specs/NN-slug.md`.

On save, it also seeds `specs/.spec-config.yml` (default `AutoCreateBranch: true`) **only if the file is missing** — an existing config is never overwritten. This is how the `AutoCreateBranch` flag that `/spec-impl` reads gets created without the user knowing the file exists.

Output file format: `specs/NN-slug.md` with a header block:

```
> **Status:** Draft
> **Depends on:** SPEC 01
> **Date:** YYYY-MM-DD
> **Objective:** One sentence.
```

The date comes from a `!`date +%F`` snippet injected at skill-load time — never from the model's own sense of the date.

**Status** after saving is always `Draft`. State transitions are human-driven — Claude must never change `**Status:**` automatically.

Valid states: `Draft` → `In review` → `Approved` → `Implemented` · `Obsolete`. Equivalents in any language are accepted (Spanish `Borrador` / `En revisión` / `Aprobado` / `Implementado` / `Obsoleto`, etc.); `/spec-impl` matches by meaning, and `/spec` follows whatever wording the existing specs in the repo already use.

### `/spec-impl`

Accepts `<NN-slug>` as argument. Phases:

1. Locate `specs/<NN-slug>.md`.
2. Read the status line — abort with a standard error message if it does not mean `Approved` in some language.
3. Check the working tree is clean, then create and switch to branch `spec-NN-slug`. If the branch already exists, treat it as a resume and propose a starting step from `git log`.
4. Implement the spec's plan step-by-step, pausing after each step for diff review. **It never commits** — that stays a human action.

Branch creation in step 3 is gated by the `AutoCreateBranch` flag, read at skill-load time from `specs/.spec-config.yml` via a `!`cat``snippet. Default (file or value absent) is`true`→ branch is created automatically. An explicit`false`makes the skill ask`[y/N]` before creating the branch; on decline it implements on the current branch. There is still no runtime config infra — the flag is just a value injected into the prompt and interpreted by the model.

At completion, remind the user to verify acceptance criteria and mark the spec `Implementado` manually before merging.

## Distribution

The repo is consumed by users in two ways:

1. **skills.sh** (`npx skills@latest add Klerith/fernando-skills`) — auto-discovers public GitHub repos with `skills/**/SKILL.md`. Just push to GitHub.
2. **Multi-agent installer** (`scripts/install-to-agent.sh <agent>`) — translates skills for Cursor (`.cursor/rules/*.mdc`), Codex (`AGENTS.md` block + `.codex/skills/`), and Antigravity (`.antigravity/skills/`). Run from the _target_ repo, not this one.

`scripts/link-skills.sh` symlinks every skill into `~/.claude/skills` for local development.

## No build or test commands

There is no package manager, build step, or test suite. All skills are plain Markdown files.
