---
name: spec-impl
description: Implements an approved spec. Validates that the state means "Approved" (in any language), creates a git branch named after the spec, switches to it, executes tasks.md task by task with pauses to review diffs, and finally applies the design's Steering impact to the project's persistent context in .sdd/steering/.
disable-model-invocation: true
argument-hint: <NN-spec-name>
allowed-tools: Read, Glob, Grep, Edit, Write, AskUserQuestion, Bash(git status:*), Bash(git branch:*), Bash(git checkout:*), Bash(git log:*), Bash(git diff:*), Bash(git stash:*), Bash(cat:*), Bash(ls:*), Bash(date:*)
---

# /spec-impl — Implementer of approved specs

## Session context

Today's date (use this for any date you write, never guess it):
!`date +%F`

Current repository state:
!`git status --short`

Current branch:
!`git branch --show-current`

Specs available:
!`ls .sdd/specs/ 2>/dev/null || echo "The .sdd/specs/ folder does not exist"`

Legacy single-file specs (old format):
!`ls specs/ 2>/dev/null || echo "none"`

Steering files:
!`ls .sdd/steering/ 2>/dev/null || echo "No steering files (.sdd/steering/ does not exist)"`

Branch-creation config:
!`cat .sdd/config.yml 2>/dev/null || cat specs/.spec-config.yml 2>/dev/null || echo "AutoCreateBranch: true (default, no config file)"`

---

## Spec formats

A spec comes in one of two formats. Detect which one in Phase 1 and use it for the rest of the run.

- **Folder format (current):** `.sdd/specs/NN-slug/` with three documents:
  - `requirements.md` — header with the spec's **single** `Status` line, user stories, EARS acceptance criteria, scope.
  - `design.md` — technical blueprint, decisions, and a **Steering impact** section.
  - `tasks.md` — the checklist you execute. Each task references the acceptance criteria it implements.
- **Legacy format:** a single file `specs/NN-slug.md` with header, scope, data model, numbered **implementation plan** and acceptance criteria. Supported so older projects keep working.

## Instructions

Follow these five phases in strict order. **Do not advance to the next phase if the previous one did not complete correctly.**

---

### Phase 1 — Identify the spec

The received argument is: `$ARGUMENTS`

If `$ARGUMENTS` is empty:

- List the available specs (you already have them above).
- Ask the user to specify the exact name of the spec.
- Stop and wait for an answer. Do not continue.

If `$ARGUMENTS` has a value:

- Look for the spec first as a folder in `.sdd/specs/`, then as a legacy file in `specs/`. The user may have written the full name (`01-mvp-arkanoid`), only the number (`01`), or only the slug (`mvp-arkanoid`). Try to find the correct one in any of those cases.
- **Folder format:** check that `requirements.md`, `design.md` and `tasks.md` all exist. If any is missing, stop: tell the user which document is missing and that they can finish it with `/spec NN-slug`.
- If you do not find the spec, show the available specs and ask the user to correct the name.
- If you do find it, continue to Phase 2.

---

### Phase 2 — Validate the spec's state

Read the file that holds the status: `requirements.md` (folder format) or the spec file itself (legacy format).

In the file's contents, look for the line that contains the spec's state. The header label is typically `**Status:**` (English) or `**Estado:**` (Spanish), but it may use any language. Match by position (status line near the top of the file) and by the surrounding state machine, not by the exact label.

**Absolute rule:** You can only continue if the state **means "Approved"** — regardless of the language used.

Treat any of the following (and their equivalents in other languages) as the **Approved** state and continue:

- English: `Approved`
- Spanish: `Aprobado`
- Portuguese: `Aprovado`
- French: `Approuvé`
- German: `Genehmigt`
- Italian: `Approvato`
- …or any other language's word that clearly means "approved"

Anything else (Draft / Borrador, In review / En revisión, Implemented / Implementado, Obsolete / Obsoleto, or any unrecognized value) means **stop** and show the error message below.

| State category                            | Examples (any language)                           | Action                                                                     |
| ----------------------------------------- | ------------------------------------------------- | -------------------------------------------------------------------------- |
| Approved                                  | `Approved`, `Aprobado`, `Aprovado`, `Approuvé`, … | Continue to Phase 3.                                                       |
| Draft                                     | `Draft`, `Borrador`, …                            | Stop. Show the error message below.                                        |
| In review                                 | `In review`, `En revisión`, …                     | Stop. Show the error message below.                                        |
| Implemented                               | `Implemented`, `Implementado`, …                  | Stop. Show the error message below.                                        |
| Obsolete                                  | `Obsolete`, `Obsoleto`, …                         | Stop. Show the error message below.                                        |
| State line not found / unrecognized value | —                                                 | Stop. The file does not follow the expected format. Tell this to the user. |

If you are unsure whether a value means "approved", **do not assume**. Stop and ask the user to clarify or to update the spec to the canonical wording.

**Standard error message when the state does not mean Approved:**

```
❌ I cannot implement this spec.

Current state: [STATE FOUND]
I only work with specs whose state means "Approved" (e.g. `Approved`, `Aprobado`,
or the equivalent in another language).

To continue you have two options:
  1. If the spec is ready to be implemented, open [FILE WITH THE STATUS LINE] and change
     the state to "Approved" (or the equivalent term your team uses) manually.
     That change is made by the human, not the agent.
  2. If the spec still needs work, use /spec [name] to resume it.
```

Do not offer alternatives, do not suggest "I can still start if you want". The block is intentional.

---

### Phase 3 — Create the git branch and switch to it

Once you have confirmed the state means `Approved`:

0. **Check the working tree first.** Look at the `git status --short` output in the session context above. If it is **not empty**, stop and show the pending changes, then ask:

   ```
   ⚠️ There are uncommitted changes in the working tree.
   Switching branches would carry them over. What do you want to do?
     1. Commit or stash them yourself, then re-run this command  (recommended)
     2. Continue anyway — the changes travel to the new branch
   ```

   Wait for the answer. **Do not stash or commit on the user's behalf** unless they explicitly ask for it. If the working tree is clean, skip straight to step 1 without mentioning it.

1. Derive the branch name from the spec's folder or file name, without the extension. Format: `spec-NN-slug`. Examples:

   - `.sdd/specs/01-mvp-arkanoid/` → branch `spec-01-mvp-arkanoid`
   - `specs/02-powerups.md` (legacy) → branch `spec-02-powerups`

2. Read the `AutoCreateBranch` flag from the **Branch-creation config** shown in the session context above (`.sdd/config.yml`, or the legacy `specs/.spec-config.yml`).

   - If no config file exists, the value is missing, or the value is unrecognized → treat it as `true` (the default).
   - Only an explicit `false` (in any capitalization) disables automatic branch creation.

   **If `AutoCreateBranch` is `true` (default):** proceed without asking.

   - If the branch **does not exist**: create it with `git checkout -b spec-NN-slug`.
   - If it **already exists**: this means previous work is being resumed. Switch to it and work out where to resume:
     - **Folder format:** the ticked tasks in `tasks.md` (`- [x]`) are the done ones; propose resuming from the first unticked task. Cross-check with `git log --oneline` and `git diff` and mention any mismatch (e.g. a task ticked with no matching changes).
     - **Legacy format:** read `git log --oneline` on the branch and say which steps of the plan already look done.
     - Tell the user which step you propose to resume from and wait for confirmation before implementing anything.
   - In both cases: switch to the branch with `git checkout spec-NN-slug` and confirm the change was successful before continuing.

   **If `AutoCreateBranch` is `false`:** ask before touching git. Show:

   ```
   AutoCreateBranch is set to false.
   Create and switch to the branch spec-NN-slug? [y/N]
   ```

   - If the user answers **yes**: create/switch to the branch exactly as in the `true` case above.
   - If the user answers **no** or leaves it empty: **do not create any branch.** Tell the user you will implement on the current branch (the one shown in the session context above) and ask for explicit confirmation to continue there. Do not improvise — wait for the answer. If `tasks.md` already has ticked tasks, propose resuming from the first unticked one.

3. Visually confirm to the user the spec is ready and which branch is active:

   ```
   ✅ Ready to implement.

   Spec:   .sdd/specs/NN-slug/   (← or specs/NN-slug.md for legacy specs)
   Branch: spec-NN-slug  (active)   (← or the current branch, if no new branch was created)
   State:  Approved   (← echo back the actual value found in the spec)
   ```

4. **Do not start implementing yet.** First load the context and show the spec summary.

   **Load the context** (read, do not show in full):
   - Every file in `.sdd/steering/`, if it exists. The code you write must follow `tech.md` (stack, commands, testing conventions) and `structure.md` (layout, naming, conventions), and fit `architecture.md`.
   - Folder format: all three spec documents.

   **Show the summary.** Match section headings by meaning, not by exact wording — the spec may be authored in any language.
   - **Folder format:**
     - The **objective** (the `**Objective:**` / `**Objetivo:**` / equivalent line in `requirements.md`).
     - The **scope** (in / out) from `requirements.md`.
     - The **requirements**: one line per user story, with the number of acceptance criteria.
     - The **design overview** from `design.md`, in 2–4 lines.
     - The **tasks** from `tasks.md`: numbered titles with their state (`[ ]` / `[x]`).
   - **Legacy format:** the objective, the scope, the implementation plan (numbered steps) and the acceptance criteria.

---

### Phase 4 — Implement task by task

After showing the summary, tell the user:

```
I am going to implement the spec following tasks.md exactly   (← "the implementation plan" for legacy specs)
I will pause after each task so you can review the diff.

Shall we start with Task 1?   (← or the resume point agreed in Phase 3)
```

Wait for explicit confirmation ("yes", "go ahead", "go", or equivalent). Do not start without it.

Once confirmed, follow these rules during the entire implementation:

**Never commit automatically.** Not per task, not at the end. You write the code and show the diff; committing is the user's decision and the user's command. Only commit if they explicitly ask you to.

**One rule above all:** implement what the spec says. If something in the spec looks suboptimal to you, mention it as an observation but implement what was agreed. Changes to the spec go into the spec, not into the code by surprise.

**Work rhythm (one top-level task at a time):**

- Re-read the task in `tasks.md`, the acceptance criteria it references (`_Requirements: …_`) in `requirements.md`, and the components it touches in `design.md`.
- Implement the task, including its sub-tasks.
- Run its **Validate** step: run the tests it names using the commands in `tech.md`, or, for a manual check, tell the user exactly what to check. Report the result honestly — if a test fails, say so and fix it before asking to continue.
- **Tick the task in `tasks.md`** (`- [ ]` → `- [x]`, and its finished sub-tasks too). Ticking is how progress is recorded and how the next run resumes — it is not a status change of the spec.
- Show a summary of which files you touched, what you did, and the validation result.
- Say: `Task N completed. Could you review the diff and let me know if I continue with Task N+1?`
- Wait for confirmation before continuing.

For legacy specs, the same rhythm applies to the steps of the implementation plan, without ticking (the legacy plan has no checkboxes).

**If during the implementation you find an ambiguity** the spec does not resolve:

- Stop.
- Describe the ambiguity exactly.
- Present two or three concrete options.
- Wait for the user's decision.
- Do not improvise.

**If the user asks for something that is out of the spec's scope:**

- Remind them that it is out of this spec's scope.
- Suggest noting it down for the next spec.
- Do not implement it on this branch.

---

### Phase 5 — Update the steering files

When the last task is done, bring the project's persistent context up to date so the next spec starts from reality.

1. **Folder format:** read the **Steering impact** section of `design.md`. **Legacy format:** there is no such section; derive the impact from the spec's decisions and the code you wrote.
2. If `.sdd/steering/` does not exist, do not create it here. Tell the user that running `/spec` next time will generate it from the codebase, and skip to the closing message.
3. Apply the impact to the steering files with Edit, **checked against the code that was actually written** — if the implementation diverged from the design (e.g. an ambiguity was resolved differently), the steering files describe what exists, not what was planned. Mention any divergence to the user.
   - Keep each file's structure and its short size. Edit the affected lines; do not rewrite the file.
   - Tag new components, features, flows and decisions with the spec (`(SPEC NN)`).
   - Update the `**Last updated:**` line to today's date from the session context, `· by SPEC NN`.
   - If the impact says "No steering changes", leave the files untouched and say so.
4. Show the user which steering files changed and a one-line summary per file, and ask them to review that diff like any other step. Apply corrections if requested.

**When finished:**

```
✅ All tasks are implemented and the steering files are up to date.

Next step: verify the acceptance criteria in requirements.md one by one.
If they all pass, update the spec's state to "Implemented" (or the equivalent
in your repo's language) in requirements.md and make the final commit before
merging this branch.
```

(For legacy specs: "the spec's acceptance criteria" and "the spec's state", in `specs/NN-slug.md`.)

**Never change the `Status` line yourself.** Marking the spec as implemented is a human action.

---

## Summary of expected behavior

```
/spec-impl 01-mvp-arkanoid

  Phase 1  →  Finds .sdd/specs/01-mvp-arkanoid/ (requirements, design, tasks)
  Phase 2  →  Reads Status in requirements.md → "Approved" (or "Aprobado", etc.) → ✅ continues
  Phase 3  →  git checkout -b spec-01-mvp-arkanoid
              Loads steering, shows objective, scope, requirements, design overview, tasks
  Phase 4  →  Implements task by task: validate → tick [x] in tasks.md → pause for diff review
  Phase 5  →  Applies the design's Steering impact to .sdd/steering/ → pause for review
              Ends by reminding to verify the acceptance criteria

/spec-impl 02-powerups  (Status: Draft / Borrador)

  Phase 1  →  Finds .sdd/specs/02-powerups/
  Phase 2  →  Reads Status → "Draft" → ❌ stops
              Shows the standard error message
              Does not create branch, does not touch code
```

**Branch creation is controlled by the `AutoCreateBranch` flag** in `.sdd/config.yml` (legacy: `specs/.spec-config.yml`). It defaults to `true` (create the branch automatically, as shown above). Set it to `false` to make Phase 3 ask `[y/N]` before creating the branch.
