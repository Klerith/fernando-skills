# Template — `tasks.md`

This file is the reference the `/spec` skill consults when writing `tasks.md`, the third of the three spec documents. It divides the design into **concrete, testable and incremental tasks** that `/spec-impl` executes one by one. **It is not text to be copied verbatim** — it is the shape the skill must respect.

---

## Header

No status here — the spec's single `Status` line lives in `requirements.md`.

```markdown
# SPEC NN — Short, descriptive title · Tasks

> **Spec:** [requirements](./requirements.md) · [design](./design.md) · tasks
```

---

## Task list

A markdown checklist. Top-level tasks are numbered; optional sub-tasks are numbered `<task>.<sub>`. Each task has:

- A **title** that says what is built, in the imperative.
- **Details**: the files and changes involved, using the names from `design.md`.
- **Validate**: how to check the task is done — an automated test to add/run, or a concrete manual check.
- **Requirements**: the acceptance criteria from `requirements.md` that this task implements or advances.

```markdown
## Tasks

- [ ] 1. Create the CV parser
  - Create `src/cv/parser.ts` with `parseCv()` and `CvUnreadableError`.
  - Validate: unit tests for text PDF, image-only PDF and `.txt` pass.
  - _Requirements: 1.1, 1.3_

- [ ] 2. Expose the upload endpoint
  - [ ] 2.1 Add `POST /api/cv` that calls `parseCv()` and stores a `Cv`.
  - [ ] 2.2 Reject files larger than 5 MB with `413` before parsing.
  - Validate: integration tests for 201, 413 and 422 pass.
  - _Requirements: 1.1, 1.2, 1.3_

- [ ] 3. Wire the upload form
  - Add `UploadForm` posting to `/api/cv`; disable the button while uploading.
  - Validate: manual — upload a PDF in the browser and see the success message.
  - _Requirements: 1.2, 1.4_
```

`/spec-impl` ticks each box (`- [x]`) once the task is implemented and the user has reviewed the diff. That is how progress is tracked and how an interrupted implementation is resumed.

---

## Rules

- **Incremental.** Each task builds on the previous one and leaves the system in a **functional and runnable** state. No "implement half and continue tomorrow".
- **Commitable.** Each top-level task must be commitable on its own.
- **Small.** If a task requires more than 30–50 lines of code, split it into sub-tasks or separate tasks.
- **Traceable.** Every task references at least one requirement. Every acceptance criterion in `requirements.md` is referenced by at least one task. If a criterion has no task, a task is missing.
- **Coding only.** Tasks are things an agent can do in the codebase: write code, write tests, change config. Not "deploy to production", "gather user feedback" or "hold a meeting".
- **Test early.** Prefer adding the test for a behavior in the same task that builds it, not in a final "write tests" task.
- **The last task is not "test everything"** — that is what the acceptance criteria in `requirements.md` are for.
- **No steering task.** Updating `.sdd/steering/` is done by `/spec-impl` after the last task, from the **Steering impact** section of `design.md`.
