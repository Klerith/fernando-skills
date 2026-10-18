[English](README.md) · [Español](README-es.md)

<p align="center">
  <h1 align="center">Development Custom Skills for Claude Code</h1>
  <p align="center">Plan the feature. Approve it. Implement it step by step.</p>
</p>

<p align="center">
  <img alt="License" src="https://img.shields.io/github/license/emmanuel-tabares-ortiz-tech/spec-driven-develpment-custom-skills">
  <img alt="Latest Release" src="https://img.shields.io/github/v/release/emmanuel-tabares-ortiz-tech/spec-driven-develpment-custom-skills">
  <img alt="GitHub Stars" src="https://img.shields.io/github/stars/emmanuel-tabares-ortiz-tech/spec-driven-develpment-custom-skills?style=social">
  <img alt="Skills" src="https://img.shields.io/badge/skills-3-blue">
</p>

## Quick start

```bash
npx skills@latest add emmanuel-tabares-ortiz-tech/spec-driven-develpment-custom-skills
```

## Skills

| Skill | Description | Argument |
| --- | --- | --- |
| `/spec` | Designs the feature document through clarifying questions, then saves it as `specs/NN-slug.md` with status `Draft`. | `[short-topic]` |
| `/spec-impl` | Validates the spec is `Approved`, creates a branch, and implements step by step with pauses for diff review. Never commits on its own. | `<NN-slug>` |
| `/manual-tecnico` | Creates or updates `docs/manual-tecnico.md` by analyzing the project and recent git changes. Works with any project type. Supports `lang:en` / `lang:es` (default: Spanish). | `[lang:en\|es] [ref-git-base]` |

---

## Installation

### Option 1 — skills.sh (recommended, Claude Code)

```bash
npx skills@latest add emmanuel-tabares-ortiz-tech/spec-driven-develpment-custom-skills
```

To uninstall:

```bash
npx skills@latest remove emmanuel-tabares-ortiz-tech/spec-driven-develpment-custom-skills
```


### Option 2 — Other agents (Cursor, Codex, Antigravity)

```bash
git clone https://github.com/emmanuel-tabares-ortiz-tech/spec-driven-develpment-custom-skills ~/.dev-custom-skills
cd ~/your-project
~/.dev-custom-skills/scripts/install-to-agent.sh <agent>
```

`<agent>` can be `claude`, `cursor`, `codex`, or `antigravity`.

| Agent         | What gets written                                                                     |
| ------------- | ------------------------------------------------------------------------------------- |
| `claude`      | Symlinks each skill into `.claude/skills/` (project-scoped)                           |
| `cursor`      | Generates `.cursor/rules/<name>.mdc` files. Invoke with `@spec`, `@spec-impl`, etc.   |
| `codex`       | Adds a `## Skills` block to `AGENTS.md` and copies skill bodies into `.codex/skills/` |
| `antigravity` | Copies skill bodies into `.antigravity/skills/`                                       |

> Cursor and Codex don't natively support Claude Code's `argument-hint` or `disable-model-invocation` frontmatter. The installer drops those fields and keeps the body — the workflow is the same, only the trigger changes.

### Option 3 — Manual

```bash
# Personal (all your projects)
mkdir -p ~/.claude/skills
cp -r skills/engineering/spec ~/.claude/skills/
cp -r skills/engineering/spec-impl ~/.claude/skills/
cp -r skills/engineering/manual-tecnico ~/.claude/skills/

# Or per-project (versioned in git)
mkdir -p .claude/skills
cp -r skills/engineering/spec .claude/skills/
cp -r skills/engineering/spec-impl .claude/skills/
cp -r skills/engineering/manual-tecnico .claude/skills/
```

For the spec workflow, also create the `specs/` folder at the project root:

```bash
mkdir specs
```

---

## Releases

This project uses [release-please](https://github.com/googleapis/release-please) for automated releases. Commit messages must follow [Conventional Commits](https://www.conventionalcommits.org/):

| Prefix | Effect |
| --- | --- |
| `feat:` | Bumps minor version |
| `fix:` | Bumps patch version |
| `feat!:` / `fix!:` | Bumps major version |
| `docs:`, `chore:`, `refactor:` | No version bump |

---

## License

MIT

---

_If you find a way to improve the method or the skills, open an issue or a PR. The most valuable part of a personal skill is that it evolves with use._
