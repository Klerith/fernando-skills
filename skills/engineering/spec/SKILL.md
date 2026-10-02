---
name: spec
description: Designs specs following the spec-driven method, in three gated documents — requirements.md (user stories + EARS acceptance criteria), design.md (technical blueprint) and tasks.md (incremental, traceable tasks) — under .sdd/specs/NN-slug/. Bootstraps the project's persistent steering context (.sdd/steering/) when missing. Use it when starting a large feature, before writing code.
disable-model-invocation: true
argument-hint: 'short feature description or requirement'
allowed-tools: Read, Glob, Grep, Write, Edit, AskUserQuestion, Bash(ls:*), Bash(cat:*), Bash(date:*)
---

# /spec — Guided spec designer

## Session context

Today's date (use this for every date you write, never guess it):
!`date +%F`

Specs that already exist:
!`ls .sdd/specs/ 2>/dev/null || echo "The .sdd/specs/ folder does not exist yet"`

Steering files (persistent project context):
!`ls .sdd/steering/ 2>/dev/null || echo "No steering files yet (.sdd/steering/ does not exist)"`

Legacy single-file specs (old format, only used for numbering and conventions):
!`ls specs/ 2>/dev/null || echo "none"`

---

This skill helps you produce a useful spec following the spec-driven method. **You don't write code here.** Your job is to help the user clarify what they want to build, ask questions when something is not well-defined enough, and turn the answers into three documents that drive the implementation.

## The model

```
Plan:   Describe ⇄ Refine  →  requirements.md   (the problem: who, what, how we know it works)
Commit:                     →  design.md         (the blueprint: architecture, components, data, errors)
Build:  Divide              →  tasks.md          (concrete, testable, incremental tasks)
        Execute & validate  →  /spec-impl        (not this skill)
```

Every spec lives in its own folder:

```
.sdd/
├── config.yml            # workflow settings (seeded by this skill)
├── steering/             # persistent project context, shared by all specs
│   ├── product.md        # purpose, users, main features, domain glossary
│   ├── tech.md           # stack, libraries, commands, technical constraints
│   ├── structure.md      # folder layout, naming, code conventions
│   └── architecture.md   # the general design of the whole system
└── specs/
    └── NN-slug/
        ├── requirements.md   # header with the spec's Status + user stories + EARS criteria
        ├── design.md         # technical blueprint + Steering impact
        └── tasks.md          # checklist that /spec-impl executes
```

The shape of each document is defined by the templates next to this skill. Read the template of a document **before** writing it:

- `templates/requirements.md`
- `templates/design.md`
- `templates/tasks.md`
- `steering-templates/product.md`, `tech.md`, `structure.md`, `architecture.md` — for the steering files.

## Philosophy

A spec is not decorative documentation. It is the contract that drives later execution. If the spec is vague, the code will improvise. That is why this flow is **deliberately slow during definition** and **fast during writing**.

The steering files are the other half of the contract: they make every spec start from the same understanding of the product, the stack and the architecture, instead of re-discovering it each session.

## Command flow

- Follow the phases in order. **Never skip the questions in Phase 1** — they are the whole point. If the user wants to go faster, remind them that the cost of a bad spec gets paid later in code.
- Your replies must be in the same language as the initial prompt. E.g.: if the initial prompt is in Spanish, your replies must be in Spanish; if it is in English, your replies must be in English.
- The **documents** follow the language and wording of the existing specs and steering files in the repo (states, section headings). If none exist, write them in the language of the initial prompt.

### Phase 0 — Load the project context

1. Read the project-memory file, if one exists. Try in order and stop at the first hit: `CLAUDE.md`, `AGENTS.md`, `GEMINI.md`, `README.md`. This adapts the skill to whichever agent is running it (Claude Code, Codex, Gemini CLI, etc.).
2. Read **every** file in `.sdd/steering/` (listed in the session context above). They are short by design and they are the project's persistent context.
3. If previous specs exist in `.sdd/specs/`, read the `requirements.md` and `design.md` of at least the two most recent ones to pick up conventions — language, state wording, section headings, level of detail. If only legacy specs exist in `specs/`, read the two most recent of those instead.
4. **If any of the four steering files is missing, bootstrap it** (see **Steering bootstrap** below) before moving on.

If `$ARGUMENTS` comes in empty, ask the user for an initial **single-sentence** description of what they want to build. If the description does not fit in one sentence, that is the first signal that the feature is too big — suggest splitting it before continuing.

#### Steering bootstrap

Generate only the steering files that are missing. **Never overwrite an existing steering file in this skill** — changes to existing steering go through the **Steering impact** section of `design.md` and are applied by `/spec-impl` once the code exists.

1. Gather facts from the codebase, not from assumptions:
   - Project-memory file and `README.md`.
   - Manifests and lockfiles (`package.json`, `pyproject.toml`, `requirements.txt`, `go.mod`, `Cargo.toml`, `pom.xml`, `Gemfile`, `composer.json`, …).
   - Config files (TypeScript, linters, formatters, test runners, Docker, CI workflows).
   - The folder tree (Glob), and two or three representative source and test files to infer naming and code conventions.
   - Legacy specs in `specs/`, if any — they hold past decisions.
2. Draft each missing file following its template in `steering-templates/`. Only write what you found evidence for. Leave out sections you have nothing for rather than inventing content. Set `**Last updated:**` to today's date with `· initial generation`.
3. **Greenfield project** (no source code yet): write minimal files — `product.md` from what the user told you, and the others with a single line `Not defined yet — will be filled in by the first implemented spec.` under the title. The first spec's **Steering impact** will define them.
4. Show the user a compact summary of the key facts per file (3–6 bullets each) and ask them to confirm or correct in one reply. This is the only place in this skill where wrong inferences can leak into every future spec, so the check is worth one question.
5. Apply corrections and write the files to `.sdd/steering/`. Then continue to Phase 1.

If the steering files exist but you notice they contradict the code (e.g. `tech.md` lists a library the project no longer uses), do not fix them here. Mention it to the user and record the correction in the **Steering impact** of the spec you are writing.

### Phase 1 — Requirements (Describe ⇄ Refine)

Goal: understand **the problem, not the solution**. Technologies, files and data structures belong to Phase 2.

#### Clarify through questions

This is the most important part of the command. Your job here is to **detect ambiguities and ask**, not to assume.

Ask questions in blocks of 3 to 5 at a time (not one single question followed by another single question — that is exhausting). After each block, wait for an answer before continuing.

**Question categories you should always consider:**

- **Users and use cases:** Who uses this? What are they trying to achieve? Which use cases are the core and which are secondary?
- **Scope:** What is in and what is NOT? Which parts of the feature are deferred to another spec?
- **Behavior and states:** What does it look like when it works? What does it look like when it fails? Are there intermediate states (loading, empty, partial)?
- **Edge cases and limits:** Invalid input, size limits, concurrency, permissions, offline or degraded cases.
- **Integration:** Does this feature depend on previous specs? Does it change existing behavior or only add?
- **Closed decisions:** Is there any decision the user has already made and does not want to reopen?

Use `product.md` from the steering files to avoid asking what is already known (users, glossary, product constraints), and to detect conflicts with existing features.

**How to phrase the questions:**

- Use concrete questions, not open-ended ones. ❌ "What should happen with big files?" → ✅ "What is the max file size: 2 MB, 5 MB or 10 MB? And what does the user see when exceeded?"
- When you offer options, give 2–4, mark which one is your recommendation and why.
- If your agent exposes a native multiple-choice question tool (in Claude Code: `AskUserQuestion`), use it for these blocks instead of writing the options as prose — the user picks instead of typing. Put your recommendation first and label it. Fall back to a numbered markdown list when no such tool exists.
- If you spot an answer that would open Pandora's box (e.g. "and we also want multiplayer"), point out that it deserves its own spec and ask whether we leave it out of this one's scope.

**When to stop asking:**

Stop when, without assuming anything, you can:

1. Write every user story with **verifiable** acceptance criteria, including the unhappy paths.
2. Say exactly what is in scope and what is out.

#### Write `requirements.md`

1. Decide the spec folder name (see **Naming the spec** below).
2. Read `templates/requirements.md` and write `.sdd/specs/NN-slug/requirements.md`: header (with `Status: Draft`), context, scope, numbered user stories with EARS acceptance criteria, and the "what is not in" reinforcement.
3. **Gate.** Tell the user the path and a 3–5 line summary (number of stories, the key criteria, what is out of scope). Ask them to review it and either request changes or confirm to move on to the design. Apply requested changes with Edit and ask again. Only continue once they confirm.

### Phase 2 — Design (Commit)

Goal: turn the approved requirements into a technical blueprint that fits the existing system.

1. Ground the design in the steering files: place new components within `architecture.md`, use the stack and commands from `tech.md`, and follow the layout and conventions from `structure.md`. Read the relevant existing source files for anything the design touches.
2. **Ask technical questions only where a real choice exists** that the steering files and the codebase do not already settle, in one block of 3–5 at most. Typical topics: where new code lives, new dependencies, data structures and persistence, interfaces between components, error handling, testing approach. Same phrasing rules as Phase 1: concrete options, recommendation first.
3. Stop asking when, without assuming anything, you can say: which files appear or change, how each acceptance criterion is satisfied, and how the feature is verified.
4. Read `templates/design.md` and write `.sdd/specs/NN-slug/design.md`, including the **Decisions** section (what was considered and discarded) and the **Steering impact** section (what `/spec-impl` must update in `.sdd/steering/` once this is implemented).
5. Check traceability: every acceptance criterion in `requirements.md` must be covered by some component, flow or error-handling row. If the design needs something the requirements do not ask for, go back and update `requirements.md` (with the user's agreement) — never let the design grow beyond the scope silently.
6. **Gate.** Give the path and a short summary (components added/changed, key decisions, steering impact). Ask for changes or confirmation to move on to the tasks. Only continue once they confirm.

### Phase 3 — Tasks (Divide)

Goal: divide the design into concrete, testable and incremental tasks that `/spec-impl` will execute one by one.

1. Read `templates/tasks.md` and write `.sdd/specs/NN-slug/tasks.md`. Each task builds on the previous one, leaves the system runnable, has a validation step, and references the acceptance criteria it implements (`_Requirements: 1.1, 2.3_`).
2. Check coverage: every acceptance criterion is referenced by at least one task. If one is not, a task is missing.
3. **Gate.** Give the path and the list of task titles. Ask for changes or confirmation. Once confirmed, go to Phase 4.

No new questions are expected here. If dividing the work reveals a gap in the design, go back and fix `design.md` first, telling the user what changed.

### Fast path

If, at the end of Phase 1's questions, the answers **also** settled every technical choice (the user dictated them, or they follow directly from the steering files and the codebase) — meaning you can answer the Phase 2 stop questions without assuming anything — then **do not gate each document**. Write `requirements.md`, `design.md` and `tasks.md` in one go and jump straight to Phase 4. The user already answered everything; re-asking is friction. The user reviews the saved files and asks for changes if needed.

Gates are the fallback for information that is still being refined, not a ritual.

### Phase 4 — Finalize

1. If the header lists dependencies (`**Depends on:** SPEC 01`), check that each referenced spec exists in `.sdd/specs/` (or in legacy `specs/`). If one does not, say so instead of leaving a dangling reference.
2. **Seed the config file if it does not exist.** Check for `.sdd/config.yml`. If it **already exists, leave it untouched** — never overwrite the user's settings. If it is **missing**, create it with the content below. If a legacy `specs/.spec-config.yml` exists, carry its `AutoCreateBranch` value over instead of the default.

   ```yaml
   # spec workflow configuration
   #
   # AutoCreateBranch — controls whether /spec-impl creates the git branch automatically.
   #   true  (default) → /spec-impl creates and switches to spec-NN-slug without asking
   #   false           → /spec-impl asks for [y/N] confirmation before creating the branch
   AutoCreateBranch: true
   ```

3. Confirm to the user:
   - The spec folder and its three files.
   - Any steering files created in this run.
   - Reminder: the spec is in `Draft` state (in `requirements.md`). Change it to `Approved` once you have re-read the three documents.
   - If you just created `.sdd/config.yml`, mention it exists and that `AutoCreateBranch` defaults to `true` (set it to `false` to control branch creation yourself).
   - Next step: once reviewed and approved, run `/spec-impl NN-slug` to implement it. `/spec-impl` will also apply the design's **Steering impact** to `.sdd/steering/` when it finishes.
   - **Stop here.** Do not propose implementing the spec, writing code, or taking any further action beyond this confirmation.

## Naming the spec

1. **Number.** Take the highest number among the folders in `.sdd/specs/` **and** the legacy files in `specs/` (both listed in the session context above), add one, and zero-pad to two digits. If the last one is `02-powerups`, this one is `03-`. If there are no specs at all, start at `01-`.
2. **Slug.** A short kebab-case slug from the objective (e.g. `levels-and-highscores`). See **Arguments** for when `$ARGUMENTS` is the slug.
3. **Date.** Use the date from the session context above for `**Date:**` and for any `**Last updated:**` line. **Never write a date you did not read from there.**
4. **Status.** `Draft` by default (or the equivalent word used by the existing specs in this repo). **Never mark it as `Approved`** — the user does that once they have re-read it. The spec has a **single** `Status` line, in `requirements.md`; `design.md` and `tasks.md` do not carry one.
5. Write the files directly. **Do not ask for permission to write them and do not ask whether the folder name works** — announce the paths at each gate. Only ask if the target folder already exists and you are not resuming it (see **Arguments**).

## Hard rules

- **Never write code during this command.** Only the spec documents, the steering files when they are missing, and `.sdd/config.yml` when it is missing.
- **Never modify an existing steering file.** Record the change in the design's **Steering impact**; `/spec-impl` applies it after implementation.
- **Never change `Status` to anything other than `Draft`.** State transitions are human-driven.
- **Never propose implementing the spec after saving it.** Your job ends when the files are written. The user runs `/spec-impl` when they are ready.
- **Never assume decisions the user did not confirm.** If you are missing information, ask — in Phase 1 for the problem, in Phase 2 for the solution.
- **Do not re-ask what was already answered** in an earlier phase or what the steering files already state.
- **If the user wants to speed up and skip the questions**, remind them: "Questions now save hours later. Are you sure you want to skip them?". If they insist, respect their decision but record it in the design's **Decisions** section ("Quick definition without detailed clarification").
- **If the feature is too big** (does not fit in one sentence, touches more than three areas of the system, requires decisions in four or more domains), propose splitting it into two or more specs before continuing.

## Tone when asking questions

Be direct and specific. Do not apologize for asking. Do not use phrases like "if you don't mind..." or "could you maybe...". The user invoked this skill precisely because they want you to ask questions. Use concrete questions, one per line when there are several, and number them so they are easy to answer.

Example of a well-formed block:

> Before writing the requirements I need to clarify three things:
>
> 1. **Accepted formats.** PDF only, or PDF and plain text? Recommendation: both — plain text is trivial and covers users without a PDF.
> 2. **Size limit.** 2 MB, 5 MB or 10 MB? And what does the user see when it is exceeded?
> 3. **Re-uploads.** When a user uploads a second CV, does it (a) replace the previous one, (b) keep a history, or (c) get rejected?

## Arguments

`$ARGUMENTS` is **the feature description**, not the folder name. Treat it as the starting point for Phase 1 and derive the slug from the objective.

Exceptions:

- If `$ARGUMENTS` is a single kebab-case token with no spaces (e.g. `/spec levels-and-highscores`), it is ambiguous between a description and a slug — use it as the slug **and** as the seed of the description, without asking for confirmation.
- If `$ARGUMENTS` names an **existing** spec folder (`03-levels-and-highscores`, `03`, or `levels-and-highscores` matching a folder in `.sdd/specs/`), **resume it**: read the documents that exist, tell the user which phase is next (the first missing document), and continue from there. If all three documents exist, ask what the user wants to change and edit the affected documents, keeping them consistent with each other. Do not touch the `Status` line; if it no longer says `Draft`, remind the user that the spec changed and should be re-reviewed.

If they invoked `/spec` without arguments, start by asking for the one-sentence description.
