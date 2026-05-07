# Fernando Skills — Spec-Driven Development for AI Agents

[![skills.sh](https://skills.sh/b/Klerith/fernando-skills)](https://skills.sh/Klerith/fernando-skills)

> 🇪🇸 [Lee este README en español](./README-es.md)

A small, opinionated set of agent skills by [Fernando Herrera](https://github.com/Klerith) for **spec-driven development**: design the spec carefully, then let the agent implement it section by section.

The skills are written in English but reply in whatever language the user prompts in. They work in **Claude Code**, **Cursor**, **OpenAI Codex**, and **Antigravity**.

## Skills

| Skill | What it does |
| --- | --- |
| [`/spec`](./skills/engineering/spec/SKILL.md) | 4-phase guided session: read context → grill with questions → draft section by section → save to `specs/NN-slug.md`. |
| [`/spec-impl`](./skills/engineering/spec-impl/SKILL.md) | Implements an approved spec on a dedicated branch, pausing after each step for diff review. |
| [`/setup-fernando-skills`](./skills/engineering/setup-fernando-skills/SKILL.md) | One-time per-repo setup. Run first. |

## Quickstart — Claude Code (recommended)

```bash
npx skills@latest add Klerith/fernando-skills
```

Pick the skills you want, make sure `/setup-fernando-skills` is selected, then run it inside your project so it can ask where `specs/` lives and which language you want.

That's it. Run `/spec <topic>` to design a feature.

## Install in other agents

Clone the repo once, then run the installer **from inside the target repo** (the one that will use the skills):

```bash
git clone https://github.com/Klerith/fernando-skills ~/.fernando-skills
cd ~/your-project
~/.fernando-skills/scripts/install-to-agent.sh <agent>
```

`<agent>` is one of:

| Agent | What gets written |
| --- | --- |
| `claude` | Symlinks each skill into `.claude/skills/` (project-scoped) |
| `cursor` | Generates `.cursor/rules/<name>.mdc` files. Invoke with `@spec`, `@spec-impl`, etc. |
| `codex` | Adds a `## Skills` block to `AGENTS.md` and copies skill bodies into `.codex/skills/` |
| `antigravity` | Copies skill bodies into `.antigravity/skills/` |

> Cursor and Codex don't natively support Claude Code's `argument-hint` or `disable-model-invocation` frontmatter. The installer drops those fields and keeps the body — the workflow is the same, only the trigger changes.

## The spec workflow

```
/setup-fernando-skills    once per repo
        │
        ▼
/spec <topic>            design — produces specs/NN-slug.md (Status: Draft)
        │
        ▼
human review             you mark Status: Approved manually
        │
        ▼
/spec-impl <NN-slug>     implement — branch spec-NN-slug, step by step
        │
        ▼
human review             you mark Status: Implemented manually
```

The state of a spec (`Draft` → `In review` → `Approved` → `Implemented` / `Obsolete`) is **never** changed by the agent. Transitions are human-driven; that is the whole point.

> Status labels are language-agnostic. `/spec-impl` only requires the status to mean **Approved** — `Approved`, `Aprobado`, or the equivalent in any language all work. Same goes for the other states. Pick the labels your team prefers and stay consistent.

## Why these skills

I built them after watching agents improvise on under-specified tasks and waste hours rewriting things. The fix isn't a smarter agent — it's a better contract before the agent starts coding.

`/spec` is deliberately slow during definition (asks 3–5 questions at a time, drafts one section at a time, waits for confirmation) and fast during writing. `/spec-impl` is the inverse — fast read of the spec, then strict step-by-step implementation with diff-review pauses.

## Authoring your own skills

Add a folder under `skills/<bucket>/<name>/` with a `SKILL.md`:

```markdown
---
name: my-skill
description: One-line description (what it does and when to use it).
disable-model-invocation: true
argument-hint: [optional-arg]
---

# /my-skill

Body in Markdown. The body becomes the prompt the agent reads.
```

Run `./scripts/link-skills.sh` to symlink every skill into `~/.claude/skills` for local testing.

## Publishing to skills.sh

[skills.sh](https://skills.sh) auto-discovers public GitHub repos that have a `skills/` directory with `SKILL.md` files. There is no upload step — push to GitHub and the badge URL above starts working.

## License

MIT. See [LICENSE](./LICENSE).
