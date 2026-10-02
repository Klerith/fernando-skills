<p align="center">
  <h1 align="center">Spec-Driven Skills for Claude Code</h1>
  <p align="center">Plan the feature. Approve it. Implement it step by step.</p>
</p>

<p align="center">
  <img alt="License" src="https://img.shields.io/github/license/SantiagoRensonnet/spec-driven-development-skill">
  <img alt="Latest Release" src="https://img.shields.io/github/v/release/SantiagoRensonnet/spec-driven-development-skill">
  <img alt="GitHub Stars" src="https://img.shields.io/github/stars/SantiagoRensonnet/spec-driven-development-skill?style=social">
  <img alt="Skills" src="https://img.shields.io/badge/skills-2-blue">
</p>

## Quick start

```bash
npx skills@latest add SantiagoRensonnet/spec-driven-development-skill
```

> This is a standalone evolution of [Klerith/fernando-skills](https://github.com/Klerith/fernando-skills): specs are split into requirements → design → tasks, and the project keeps persistent steering context under `.sdd/`. See [Switching from fernando-skills](#switching-from-fernando-skills).

## Skills

| Skill | Description | Argument |
| --- | --- | --- |
| `/spec` | Designs the feature as requirements → design → tasks, asking clarifying questions | `[description]` |
| `/spec-impl` | Validates the spec is approved and implements step by step | `<NN-slug>` |

---

## Table of contents

- [What spec-driven design is](#what-spec-driven-design-is)
- [The problem it solves](#the-problem-it-solves)
- [The six-step procedure](#the-six-step-procedure)
- [Anatomy of a useful spec](#anatomy-of-a-useful-spec)
- [Steering: persistent project context](#steering-persistent-project-context)
- [When to use specs and when not](#when-to-use-specs-and-when-not)
- [Rules almost nobody follows](#rules-almost-nobody-follows)
- [Installation](#installation)
- [Usage](#usage)

---

## What spec-driven design is

Spec-driven design is an approach where **the spec is the main work artifact, not the code**. The code is the consequence.

It sounds obvious. The difference from the classic "document before coding" is that in spec-driven the spec **is not optional or decorative**: it's the contract that guides execution, it's versioned in git, and it's kept alive. If the code diverges from the spec, one of the two is wrong.

Each spec captures the decisions of a single feature, split into three documents — **requirements** (the problem), **design** (the solution) and **tasks** (the execution plan). Specs live in `.sdd/specs/` as numbered folders, and they form the project's design decision log. Next to them, `.sdd/steering/` keeps the project's persistent context: product, tech stack, code structure and the overall architecture.

```
.sdd/
├── config.yml
├── steering/
│   ├── product.md        # purpose, users, main features, domain glossary
│   ├── tech.md           # stack, libraries, commands, technical constraints
│   ├── structure.md      # folder layout, naming, code conventions
│   └── architecture.md   # the general design of the whole system
└── specs/
    └── 03-levels-and-highscores/
        ├── requirements.md   # user stories + EARS acceptance criteria + Status
        ├── design.md         # architecture, components, data, errors, decisions
        └── tasks.md          # incremental, testable tasks linked to requirements
```

The model is inspired by [Kiro's specs](https://kiro.dev/docs/how-kiro-works/) and [steering](https://kiro.dev/docs/steering/).

---

## The problem it solves

When you work with an LLM like Claude Code, there's a very concrete phenomenon: if you ask it _"build me an Arkanoid with power-ups and levels"_, **it's going to improvise**. It's going to make 50 implicit design decisions (classes or functions? global or local state? how are entities named?) without you seeing any of them. And each one of those decisions becomes an expensive coupling to revert later.

The problem isn't new — humans improvise too — but with an LLM it's sharper:

1. **Generation speed hides the cost of decisions.** When a human takes two hours to write a module, they have time to think. When Claude does it in 30 seconds, the decisions go invisible.
2. **Every conversation starts from scratch.** Without a spec, in the next session Claude doesn't know what you decided before and is going to improvise again, possibly in the opposite direction.
3. **Context fills up fast.** Without a stable document to refer to, you end up pasting context by hand into every prompt.

The spec solves all three: it makes decisions explicit, it persists across sessions, and it loads once as a reference.

---

## The six-step procedure

```
┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐
│   1. DESCRIBE   │→ │  2. PLAN MODE   │→ │   3. REFINE     │
│   the problem   │  │ Claude proposes │  │ You give        │
│  not the answer │  │ doesn't edit    │  │ decisions       │
└─────────────────┘  └─────────────────┘  └─────────────────┘
        ↑                                          │
        │                                          │
        └──────── 2-3 iterations until converged ──┘
                              │
                              ▼
┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐
│    4. SAVE      │→ │   5. EXECUTE    │→ │   6. REVIEW     │
│ requirements →  │  │ Task by task    │  │ Diff per task   │
│ design → tasks  │  │ with pauses     │  │ not at the end  │
└─────────────────┘  └─────────────────┘  └─────────────────┘
```

### 1. Describe

You describe the feature to Claude in terms of **the problem**, not the solution. If you dictate the solution, Claude just formats it — you lose its ability to propose structure.

### 2. Plan mode

You activate plan mode (in plan mode Claude can't write files, only read and propose). Claude responds with structured documents: requirements (user stories and acceptance criteria), design (architecture, data model, decisions) and tasks.

### 3. Refine

You read the plan with resistance and give **concrete decisions**. "Take X out of scope", "data lives in JSON, not in JS modules", "add a risks section". You iterate 2-3 times.

### 4. Save

When the spec is honed, you save it in `.sdd/specs/NN-slug/` — `requirements.md`, `design.md` and `tasks.md` — with status `Draft` (in `requirements.md`). You leave the chat, **re-read it outside the editor**, and only when you're satisfied do you change the status to `Approved` manually. That change is made by the human, not Claude.

### 5. Execute

You exit plan mode and ask Claude to implement the spec **step by step**, stopping after each task in `tasks.md`. The pause between steps is what makes the method work.

### 6. Review

After each task, you review the diff. If it's good, you continue. If not, you correct in the moment — not at the end with 600 lines mixed together.

---

## Anatomy of a useful spec

Not every document does the job. A useful spec has three documents, and each one answers a different question. If any part is missing, it's probably not enough to guide execution.

### `requirements.md` — what problem, for whom, how do we know it works

1. **Goal in one sentence.** If it doesn't fit in a sentence, the feature is too big. Split it before writing anything else.
2. **Explicit scope + what's NOT in scope.** The "out of scope" is as important as the "in scope". Without it, the boundaries are blurry and scope creep appears during implementation.
3. **User stories with EARS acceptance criteria.** Each story ("As a… I want… So that…") has numbered, verifiable criteria in [EARS](https://alistairmavin.com/ears/) notation:

   ```
   1.2. WHEN a user uploads a file larger than 5 MB
        THE SYSTEM SHALL reject it and show "File too large (max 5 MB)".
   ```

   - ❌ "Works well" — not verifiable
   - ❌ "Good UX" — subjective
   - ✅ "WHEN the user presses Esc THE SYSTEM SHALL pause the game and show the menu" — verifiable

### `design.md` — how we'll build it

4. **Architecture, components and data model.** A diagram of what changes, concrete interfaces, and real names. If you say "the levels module", say `src/levels.js`.
5. **Data flow, error handling and testing strategy.** Every unhappy path from the requirements has a home.
6. **Decisions made and discarded.** What you considered and why you chose what you chose. **This is gold three months from now** when someone asks _"why does persistence use a versioned key?"_.
7. **Steering impact.** What this spec changes in the project's persistent context once it's built.

### `tasks.md` — in what order

8. **Incremental, testable tasks.** A checklist where **each task leaves the system in a working state**, has a validation step, and references the acceptance criteria it implements (`_Requirements: 1.1, 1.2_`). If a task requires more than 30-50 lines of code, split it. The last task is not "test everything" — that's what the acceptance criteria are for.

---

## Steering: persistent project context

Every conversation with an LLM starts from scratch. Steering files fix that for the things that don't change from spec to spec:

| File              | Contains                                                          |
| ----------------- | ----------------------------------------------------------------- |
| `product.md`      | Purpose, users, main features, domain glossary, product rules.    |
| `tech.md`         | Stack, key libraries, commands, technical and testing constraints. |
| `structure.md`    | Folder layout, naming, code conventions, patterns to follow.      |
| `architecture.md` | The general design of the whole system, from the most general view. |

How they stay alive:

- **`/spec` creates them** the first time, from your codebase (manifests, configs, folder tree, sample files), and asks you to confirm the key facts once.
- **`/spec` reads them** before every new spec, so requirements and designs fit what already exists — and doesn't ask what they already answer.
- **`/spec` never edits them.** Each `design.md` lists its **Steering impact** instead.
- **`/spec-impl` applies that impact** after the last task, checked against the code actually written. Steering always describes what exists, not what was planned.

---

## When to use specs and when not

This architecture has a cost. Don't apply it to everything.

### YES — write a spec when:

- The task will touch **more than two files**.
- There are **decisions expensive to revert** (data schemas, formats, APIs).
- The feature will take **more than one session** of Claude Code.
- There's a **contract that other artifacts will reuse** (another spec, a skill, a hook).
- It's something you'll **forget about in a week**.

### NO — use a direct prompt when:

- It's a **point bug fix**.
- It's a **mechanical refactor** (renames, file moves).
- It's an **exploratory experiment** where the goal is to discover the decision, not execute it.
- The task **fits in a prompt** and is understood at first read.
- It's a **one-off task** that won't be repeated.

### Mental rule

> **If you're tempted to open plan mode, you probably need it.** > **If planning the feature bores you, you probably don't.**

Common sense beats the rule — but common sense is trained by the two columns above.

---

## Rules almost nobody follows

Four usage patterns that distinguish the method working well from the method as decorative bureaucracy:

### 1. In the description phase, describe the problem, not the solution

❌ _"Add an array of levels loaded from JSON, a `loadLevel()` function, and persistence with versioned localStorage."_

That's already a spec poorly written by you. Claude is just going to format it.

✅ _"I want the game to stop being single-screen. The next feature is: progression through levels with increasing difficulty, and persistence of high scores across sessions."_

That second version leaves room for Claude to **decide** and you to **review**. That's the nature of the flow.

### 2. In the refine phase, give concrete decisions, not suggestions

Plan mode is where **you direct**. "Take X out", "the format is JSON", "add risks". If you say "I think maybe it would be good to...", Claude is going to leave it as is.

### 3. During execution, ask for pauses between steps

The difference is:

- **Without pauses:** Claude dumps 400 lines. You review a giant commit. If something is wrong in step 2, it's mixed with changes from steps 5 and 6. Painful.
- **With pauses:** Claude dumps 50-80 lines (step 1). You read the diff. You approve or adjust. It moves to step 2. Each step is a clean commit. Reverting is trivial.

### 4. If mid-execution you want to change something, you go back to step 2 — never improvise

Mid-implementation something occurs to you. The right move is: stop, go back to plan mode, update the spec, exit, continue. **Don't improvise on the code.**

That separation is what prevents silent scope creep.

---

## Installation

### Option 1 — skills.sh (recommended, Claude Code)

```bash
# Project-level (installs into ./.claude/skills of the current project)
npx skills@latest add SantiagoRensonnet/spec-driven-development-skill

# User-level (available in all your projects)
npx skills@latest add SantiagoRensonnet/spec-driven-development-skill -g

# Preview what the repo ships without installing
npx skills@latest add SantiagoRensonnet/spec-driven-development-skill --list
```

To update or uninstall:

```bash
npx skills@latest update spec spec-impl
npx skills@latest remove spec spec-impl      # add -g if you installed globally
```

### Option 2 — Other agents (Cursor, Codex, Antigravity)

```bash
git clone https://github.com/SantiagoRensonnet/spec-driven-development-skill ~/.sdd-skills
cd ~/your-project
~/.sdd-skills/scripts/install-to-agent.sh <agent>
```

`<agent>` can be `claude`, `cursor`, `codex`, or `antigravity`.

| Agent         | What gets written                                                                     |
| ------------- | ------------------------------------------------------------------------------------- |
| `claude`      | Symlinks each skill into `.claude/skills/` (project-scoped)                           |
| `cursor`      | Generates `.cursor/rules/<name>.mdc` files. Invoke with `@spec`, `@spec-impl`, etc.   |
| `codex`       | Adds a `## Skills` block to `AGENTS.md` and copies skill bodies into `.codex/skills/` |
| `antigravity` | Copies skill bodies into `.antigravity/skills/`                                       |

> Cursor and Codex don't natively support Claude Code's `argument-hint` or `disable-model-invocation` frontmatter. The installer drops those fields and keeps the body — the workflow is the same, only the trigger changes.

To update, `git -C ~/.sdd-skills pull` and re-run the installer.

### Option 3 — Manual

```bash
git clone https://github.com/SantiagoRensonnet/spec-driven-development-skill
cd spec-driven-development-skill

# Personal (all your projects)
mkdir -p ~/.claude/skills
cp -r skills/engineering/spec ~/.claude/skills/
cp -r skills/engineering/spec-impl ~/.claude/skills/

# Or per-project (versioned in git) — run from your project root
mkdir -p .claude/skills
cp -r /path/to/spec-driven-development-skill/skills/engineering/spec .claude/skills/
cp -r /path/to/spec-driven-development-skill/skills/engineering/spec-impl .claude/skills/
```

### Switching from fernando-skills

Both repos ship skills named `spec` and `spec-impl`, so **don't install them side by side** — whichever was installed last silently wins. Remove the original first:

```bash
npx skills@latest remove spec spec-impl        # add -g if it was a global install
npx skills@latest add SantiagoRensonnet/spec-driven-development-skill
```

Existing specs keep working: `/spec-impl` still reads legacy `specs/NN-slug.md` files, and `/spec` continues the numbering from them and carries over `specs/.spec-config.yml` into `.sdd/config.yml`.

No setup is needed in your project: `/spec` creates `.sdd/` (specs, steering files and config) the first time you run it.

---

## Usage

### Full feature cycle

```bash
# 1. Design the spec with clarifying questions
/spec levels-and-highscores

# Claude reads the project-memory file, the steering files (generating them
# on first run) and previous specs. It asks about the problem in blocks,
# writes requirements.md, then design.md, then tasks.md — pausing for your
# review after each — into .sdd/specs/03-levels-and-highscores/
# with status: Draft.

# 2. Re-read the three documents outside the chat and approve the spec manually
# (open requirements.md, change Status: Draft → Approved)

# 3. Implement the approved spec
/spec-impl 03-levels-and-highscores

# Claude validates the status is Approved, creates the branch
# spec-03-levels-and-highscores, switches to it, shows the spec
# summary, and implements tasks.md task by task — ticking each one
# and pausing to review diffs. At the end it updates .sdd/steering/.
```

### What each skill does

#### `/spec [description]`

Designs the feature. Goes through these phases:

0. **Context** — reads the project-memory file (`CLAUDE.md`, `AGENTS.md`, `GEMINI.md`, or `README.md`), the steering files and previous specs. Generates any missing steering file from the codebase.
1. **Requirements** — asks about the problem in blocks of 3-5 questions, then writes `requirements.md`. You review it before moving on.
2. **Design** — asks only the technical questions the steering files and code don't already answer, then writes `design.md`. You review it.
3. **Tasks** — divides the design into `tasks.md`. You review it.
4. **Finalize** — seeds `.sdd/config.yml` if missing and stops. The spec is in `Draft`.

If your answers in phase 1 already settle every technical decision, `/spec` writes the three documents in one go without the intermediate reviews.

Run `/spec NN-slug` on an existing spec to resume an unfinished one or change it.

#### `/spec-impl <NN-name>`

Implements an approved spec. Goes through five phases:

1. **Identify** — locates `.sdd/specs/NN-slug/`.
2. **Validate** — verifies the status in `requirements.md` is `Approved`. If not, it stops.
3. **Create branch** — `git checkout -b spec-NN-slug` and switches to it. If the branch exists, resumes from the first unticked task.
4. **Implement** — task by task: implement, validate, tick `[x]` in `tasks.md`, pause for your diff review.
5. **Update steering** — applies the design's Steering impact to `.sdd/steering/`, then reminds you to verify the acceptance criteria.

> Specs in the old single-file format (`specs/NN-slug.md`) still work with `/spec-impl`.

> **Branch control:** Phase 3 reads the `AutoCreateBranch` flag from `.sdd/config.yml`. It defaults to `true` (creates the branch automatically). Set it to `false` to make `/spec-impl` ask `[y/N]` before creating any branch — useful if branch naming is part of your own Git workflow.
>
> ```yaml
> # .sdd/config.yml
> AutoCreateBranch: false
> ```

### Spec states

| State         | Meaning                                                                    |
| ------------- | -------------------------------------------------------------------------- |
| `Draft`       | The `/spec` skill generated it but the human hasn't re-read it.            |
| `In review`   | The human is reviewing or iterating with Claude.                           |
| `Approved`    | The human read and authorized it. `/spec-impl` only works with this state. |
| `Implemented` | The code exists and passes the acceptance criteria.                        |
| `Obsolete`    | Replaced by another spec. Not deleted — referenced.                        |

The status lives in `requirements.md` and covers the whole spec (all three documents).

**Changing the status to `Approved` is a deliberate human act.** It's the only signature on the contract — Claude can't approve its own work.

> Status labels are language-agnostic. `/spec-impl` only requires the status to mean **Approved** — `Approved`, `Aprobado`, or the equivalent in any language all work. Same goes for the other states. Pick the labels your team prefers and stay consistent.

---

## Why the two skills work as a pair

```
┌───────────────────────────────────────────────────────────┐
│                                                           │
│   /spec     Claude asks and designs                       │
│             ↓                                             │
│             .sdd/specs/NN-slug/  (Status: Draft)          │
│                                                           │
│   ──────── human re-reads and approves ────────           │
│             ↓                                             │
│             .sdd/specs/NN-slug/  (Status: Approved)       │
│                                                           │
│   /spec-impl  Claude validates and implements             │
│             ↓                                             │
│             branch spec-NN-slug + code                    │
│             + updated .sdd/steering/                      │
│                                                           │
└───────────────────────────────────────────────────────────┘
```

The gap between the two skills — re-reading and changing the status by hand — is deliberate. It's the only moment where **only you can do something**. Without that gap, the method degrades to "Claude writes pretty documentation and then writes whatever code occurs to it anyway".

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
