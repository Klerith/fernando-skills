# Spec-Driven Design for Claude Code

Spanish version: [README-es.md](README-es.md)

> Skills for Claude Code that implement the spec-driven method: you plan the feature in a document, approve it, and then it gets implemented step by step. Prevents Claude from improvising design decisions you never made.

This package contains two complementary skills:

- **`/spec`** — Designs the feature document by asking clarifying questions.
- **`/spec-impl`** — Validates that the spec is approved, creates a git branch, and implements step by step.

---

## Table of contents

- [What is spec-driven design](#what-is-spec-driven-design)
- [The problem it solves](#the-problem-it-solves)
- [The six-step procedure](#the-six-step-procedure)
- [Anatomy of a useful spec](#anatomy-of-a-useful-spec)
- [When to use specs and when not to](#when-to-use-specs-and-when-not-to)
- [Rules almost no one follows](#rules-almost-no-one-follows)
- [Installation](#installation)
- [Usage](#usage)

---

## What is spec-driven design

Spec-driven design is an approach where **the spec is the primary artifact of the work, not the code**. The code is the consequence.

It sounds obvious. The difference with the classic "document before you code" is that in spec-driven the spec **is not optional or decorative**: it's the contract that guides execution, it's versioned in git, and it stays alive. If the code diverges from the spec, one of the two is wrong.

Each spec captures the decisions of a single feature. Specs live in `specs/` as `.md` files numbered sequentially, and they form the project's design decision log.

---

## The problem it solves

When you work with an LLM like Claude Code, there's a very concrete phenomenon: if you ask for _"build me an Arkanoid with power-ups and levels"_, **it's going to improvise**. It will make 50 implicit design decisions (classes or functions? global or local state? how are entities named?) without you seeing any of them. And each of those decisions becomes coupling that is expensive to revert later.

The problem isn't new — humans improvise too — but with an LLM it's sharper:

1. **Generation speed hides the cost of decisions.** When a human takes two hours to write a module, they have time to think. When Claude does it in 30 seconds, decisions slip by invisibly.
2. **Every conversation starts from scratch.** Without a spec, in the next session Claude doesn't know what you decided before and will improvise again, possibly in the opposite direction.
3. **Context fills up fast.** Without a stable document to refer to, you end up pasting context by hand into every prompt.

The spec solves all three: it makes decisions explicit, it persists between sessions, and it loads once as a reference.

---

## The six-step procedure

```
┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐
│  1. DESCRIBE    │→ │  2. PLAN MODE   │→ │   3. REFINE     │
│  the problem    │  │ Claude proposes │  │ You make        │
│  not the answer │  │ doesn't edit    │  │ decisions       │
└─────────────────┘  └─────────────────┘  └─────────────────┘
        ↑                                          │
        │                                          │
        └─────── 2-3 iterations until convergence ─┘
                              │
                              ▼
┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐
│   4. SAVE       │→ │   5. EXECUTE    │→ │   6. REVIEW     │
│ specs/NN-       │  │ Step by step    │  │ Diff per step   │
│ feature.md      │  │ with pauses     │  │ not at the end  │
└─────────────────┘  └─────────────────┘  └─────────────────┘
```

### 1. Describe

You describe the feature to Claude in terms of **the problem**, not the solution. If you dictate the solution, Claude only formats it — you lose its ability to propose structure.

### 2. Plan mode

You enable plan mode (in plan mode Claude cannot write files, only read and propose). Claude responds with a structured document: scope, data model, implementation plan, and acceptance criteria.

### 3. Refine

You read the plan with resistance and give **concrete decisions**. "Take X out of scope", "data lives in JSON, not in JS modules", "add a risks section". Iterate 2-3 times.

### 4. Save

When the spec is dialed in, you save it to `specs/NN-slug.md` with state `Borrador` (Draft). You leave the chat, **reread it outside the editor**, and only when you're satisfied do you change the state to `Aprobado` (Approved) manually. That change is made by the human, not Claude.

### 5. Execute

You exit plan mode and ask Claude to implement the spec **step by step**, pausing after each step in the implementation plan. The pause between steps is what makes the method work.

### 6. Review

After each step, you review the diff. If it's good, you continue. If it's not, you fix it on the spot — not at the end with 600 mixed lines.

---

## Anatomy of a useful spec

Not every document is useful. A useful spec has six parts — if any are missing, it's probably not enough to guide execution.

### 1. Goal in one sentence

If it doesn't fit in a sentence, the feature is too big. Split it before writing anything else.

### 2. Explicit scope + what's NOT in scope

The "not in scope" is as important as the "in scope". Without it, the boundaries are blurry and scope creep shows up during implementation. Capture the things that were mentioned but deliberately deferred.

### 3. Data model

Concrete structures and names. If you say "the levels module", say `src/levels.js`. If you say "a key", give the exact string. This section is the one most often cited later in other specs and skills.

### 4. Ordered implementation plan

Numbered sequential steps. **Each step must leave the system in a working state.** If a step requires more than 30-50 lines of code, split it. The last step is not "test everything" — that's what acceptance criteria are for.

### 5. Acceptance criteria

A verifiable boolean checklist. Each item can be answered with yes or no.

- ❌ "Works well" — not verifiable
- ❌ "Good UX" — subjective
- ❌ "No bugs" — not operational
- ✅ "Pressing Esc pauses the game and shows the menu" — verifiable

### 6. Decisions made and discarded

What you considered and why you chose what you chose. **This is gold three months from now** when someone asks _"why does persistence use a versioned key?"_. The answer lives there.

Each decision ideally has a brief reason. Decisions without a reason are the first ones questioned later.

---

## When to use specs and when not to

This architecture has a cost. Don't apply it to everything.

### YES — write a spec when:

- The task will touch **more than two files**.
- There are **decisions expensive to revert** (data schemas, formats, APIs).
- The feature will span **more than one Claude Code session**.
- There is a **contract that other artifacts will reuse** (another spec, a skill, a hook).
- It's something **you'll forget within a week**.

### NO — use a direct prompt when:

- It's a **one-off bug fix**.
- It's a **mechanical refactor** (rename, move files).
- It's an **exploratory experiment** where the goal is to discover the decision, not to execute it.
- The task **fits in a prompt** and is understood the first time.
- It's a **one-shot task** that won't be repeated.

### Rule of thumb

> **If you're tempted to open plan mode, you probably need it.** > **If planning the feature bores you, you probably don't.**

Common sense beats the rule — but common sense is trained on the two columns above.

---

## Rules almost no one follows

Four usage patterns that distinguish the method working well from the method as decorative bureaucracy:

### 1. In the description phase, describe the problem, not the solution

❌ _"Add an array of levels loaded from JSON, a `loadLevel()` function, and persistence via versioned localStorage."_

That's already a poorly written spec, written by you. Claude will only format it.

✅ _"I want the game to stop being a single screen. The next feature is: progression through levels with increasing difficulty, and persistence of best scores between sessions."_

That second version leaves room for Claude to **decide** and you to **review**. That's the nature of the flow.

### 2. In the refine phase, give concrete decisions, not suggestions

Plan mode is where **you direct**. "Cut X", "the format is JSON", "add risks". If you say "I think maybe it would be good...", Claude will leave it as is.

### 3. During execution, ask for pauses between steps

The difference is:

- **Without pauses:** Claude dumps 400 lines. You review one giant commit. If something is wrong in step 2, it's mixed with changes from steps 5 and 6. Painful.
- **With pauses:** Claude dumps 50-80 lines (step 1). You read the diff. You approve or adjust. Move on to step 2. Each step is a clean commit. Reverting is trivial.

### 4. If you want to change something mid-execution, go back to step 2 — never improvise

Mid-implementation you come up with something. The right move is: stop, go back to plan mode, update the spec, exit, continue. **Don't improvise on the code.**

That separation is what prevents silent scope creep.

---

## Installation

### Option 1 — Personal (all your projects)

```bash
mkdir -p ~/.claude/skills
cp -r skills/spec ~/.claude/skills/
cp -r skills/spec-impl ~/.claude/skills/
```

### Option 2 — Per-project (versioned in git)

```bash
mkdir -p .claude/skills
cp -r skills/spec .claude/skills/
cp -r skills/spec-impl .claude/skills/
```

For the method to work, you also need to create the `specs/` folder in the project root:

```bash
mkdir specs
```

Optionally, add a `specs/README.md` documenting the convention (see the example in this repo).

---

## Usage

### Full feature cycle

```bash
# 1. Design the spec with clarifying questions
/spec levels-and-highscores

# Claude reads CLAUDE.md and existing specs/, asks questions
# in blocks, develops the spec section by section,
# and at the end saves it as specs/03-levels-and-highscores.md
# with state: Borrador (Draft).

# 2. Reread the spec outside the chat and approve it manually
# (open the file in the editor, change Estado: Borrador → Aprobado)

# 3. Implement the approved spec
/spec-impl 03-levels-and-highscores

# Claude validates that the state is Aprobado, creates the
# spec-03-levels-and-highscores branch, switches to it, shows
# the spec summary, and starts implementation
# step by step with pauses to review diffs.
```

### What each skill does

#### `/spec [short-topic]`

Designs the feature document. Goes through four phases:

1. **Context** — reads `CLAUDE.md` and previous specs.
2. **Clarification** — asks questions in blocks of 3-5 until the feature is clearly defined.
3. **Section-by-section drafting** — generates and confirms each section of the spec before moving on.
4. **Save** — writes the file to `specs/NN-slug.md` with state `Borrador`.

#### `/spec-impl <NN-name>`

Implements an approved spec. Goes through four phases:

1. **Identify** — finds the spec file.
2. **Validate** — checks that the state is `Aprobado`. If not, it stops.
3. **Create branch** — `git checkout -b spec-NN-slug` and switches to it.
4. **Implement** — step by step with pauses, showing the spec summary first.

### Spec states

| State          | Meaning                                                                       |
| -------------- | ----------------------------------------------------------------------------- |
| `Borrador`     | The `/spec` skill generated it but the human hasn't reread it yet.            |
| `En revisión`  | The human is reviewing it or iterating with Claude.                           |
| `Aprobado`     | The human read it and authorized it. `/spec-impl` only works with this state. |
| `Implementado` | The code exists and passes the acceptance criteria.                           |
| `Obsoleto`     | Replaced by another spec. Not deleted — referenced.                           |

**Changing the state to `Aprobado` is a deliberate human act.** It's the only signature on the contract — Claude cannot approve its own work.

---

## Why the two skills work as a pair

```
┌───────────────────────────────────────────────────────────┐
│                                                           │
│   /spec     Claude asks and designs                       │
│             ↓                                             │
│             specs/NN-slug.md  (State: Borrador)           │
│                                                           │
│   ──────── human rereads and approves ────────            │
│             ↓                                             │
│             specs/NN-slug.md  (State: Aprobado)           │
│                                                           │
│   /spec-impl  Claude validates and implements             │
│             ↓                                             │
│             branch spec-NN-slug + code                    │
│                                                           │
└───────────────────────────────────────────────────────────┘
```

The gap between the two skills — rereading and changing the state by hand — is deliberate. It's the only moment where **only you can do something**. Without that gap, the method degrades into "Claude writes pretty documentation and then writes whatever code it feels like anyway".

---

## License

MIT

---

_If you find a way to improve the method or the skills, open an issue or a PR. The most valuable part of a personal skill is that it evolves with use._
