---
name: setup-fernando-skills
description: Configures the current repo to work with Fernando Herrera's spec-driven skills (`/spec`, `/spec-impl`). Asks where specs live, the response language, and writes a small `## Fernando skills` block into `CLAUDE.md`/`AGENTS.md`. Run once per repo before first use of `/spec`.
disable-model-invocation: true
---

# Setup Fernando Skills

Scaffold the per-repo configuration that the spec-driven skills assume:

- **specs directory** — where `/spec` saves files (default `specs/`)
- **response language** — Spanish or English (skills mirror the user's prompt language by default; this lets you force one)
- **branch prefix** — what `/spec-impl` uses when creating branches (default `spec-`)

This is a prompt-driven skill, not a deterministic script. Explore, ask, then write.

## Process

### 1. Explore

Read whatever exists; don't assume:

- `CLAUDE.md` and `AGENTS.md` at repo root — does either exist? Is there already a `## Fernando skills` block?
- `specs/` — does it exist? How many specs are inside?
- `.git/config` — is this a git repo at all? `/spec-impl` requires git.

### 2. Present findings and ask

Summarise what you found. Then walk through the three decisions **one at a time** (block of one question, get answer, move on). Don't dump them all at once.

**Section A — specs directory.**

> Explainer: `/spec` saves drafts as `specs/NN-slug.md`. If you already track specs/RFCs somewhere else (`docs/specs/`, `rfcs/`, etc.), point the skill at that path.

Default: `specs/`. Ask only if the repo already has a different convention visible from the file tree.

**Section B — response language.**

> Explainer: By default, `/spec` and `/spec-impl` answer in whatever language the user wrote the initial prompt in. If your team is fully Spanish or fully English, you can force it.

Options:

- **Auto** (mirror prompt language) — default
- **Spanish** — always reply in Spanish
- **English** — always reply in English

**Section C — branch prefix.**

> Explainer: `/spec-impl` creates a branch when it starts implementing. Default name is `spec-NN-slug`. If your repo uses a different convention (`feature/`, `feat/`, etc.), set it here.

Default: `spec-`. Ask only if the repo's `git log` shows a different convention.

### 3. Write the config block

Pick the target file in this order: `CLAUDE.md` if it exists, else `AGENTS.md` if it exists, else create `CLAUDE.md`.

Append (or replace, if a previous block exists) this section, filling in the answers:

```markdown
## Fernando skills

This repo is configured for Fernando Herrera's spec-driven skills (`/spec`, `/spec-impl`).

- **specs directory:** `specs/`
- **response language:** auto
- **branch prefix:** `spec-`

State machine for `**Estado:**` in `specs/NN-slug.md`:
`Borrador` → `En revisión` → `Aprobado` → `Implementado` (or `Obsoleto`).
Claude must never change `**Estado:**` automatically; transitions are human-driven.

`/spec-impl <NN-slug>` only runs when the spec's `**Estado:**` is exactly `Aprobado`.
```

If a `## Fernando skills` block already exists, replace its contents in place — do not duplicate.

### 4. Confirm

Tell the user:

- Which file you wrote to
- Which values are now configured
- That they can run `/spec <topic>` to start a new spec, and `/spec-impl <NN-slug>` once a spec reaches `Aprobado`
