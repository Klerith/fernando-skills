# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Purpose

This repo is a workspace for authoring Claude Code slash-command skills, specifically for a spec-driven development workflow. Skills are written in **Spanish**.

`reference/` is a vendored copy of `mattpocock/skills` kept as a structural/style reference — do not edit it during normal work. Its own `reference/CLAUDE.md` governs that subtree.

## Skill authoring conventions

Each skill lives under `skills/<name>/` as a directory containing at minimum a `SKILL.md`. The YAML frontmatter of `SKILL.md` must declare:

```yaml
---
name: skill-name
description: One-line description (in Spanish)
disable-model-invocation: true
argument-hint: [hint]
---
```

Use `allowed-tools` in frontmatter to restrict what Bash commands a skill may run (see `skills/spec-impl/SKILL.md` for an example that limits to read-only git/fs).

Use `!`command`` shell snippets inside `SKILL.md` to inject live repo state at skill-load time (e.g., current branch, available specs). Embed them at the top of the skill body before the instructions.

Companion files (e.g., `template.md`) sit next to `SKILL.md` and are referenced by relative path within the skill body.

## The spec workflow

This repo encodes a two-skill pair:

### `/spec`
Guides the user through 4 phases: read project context → clarify with questions (blocks of 3–5) → draft each spec section one at a time with user confirmation → save to `specs/NN-slug.md`.

Output file format: `specs/NN-slug.md` with a header block:
```
> **Estado:** Borrador · **Depende de:** ... · **Fecha:** YYYY-MM-DD
> **Objetivo:** One sentence.
```

**Estado** after saving is always `Borrador`. State transitions are human-driven — Claude must never change `**Estado:**` automatically.

Valid states: `Borrador` → `En revisión` → `Aprobado` → `Implementado` · `Obsoleto`

### `/spec-impl`
Accepts `<NN-slug>` as argument. Phases:
1. Locate `specs/<NN-slug>.md`.
2. Read `**Estado:**` — abort with a standard error message if it is not exactly `Aprobado`.
3. Create and switch to branch `spec-NN-slug`.
4. Implement the spec's plan step-by-step, pausing after each step for diff review.

At completion, remind the user to verify acceptance criteria and mark the spec `Implementado` manually before merging.

## No build or test commands

There is no package manager, build step, or test suite. All skills are plain Markdown files.
