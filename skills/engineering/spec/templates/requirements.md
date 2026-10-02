# Template — `requirements.md`

This file is the reference the `/spec` skill consults when writing `requirements.md`, the first of the three spec documents. It captures **the problem, not the solution**: who the users are, what they need, and how we will know it works. Each section includes its purpose and a minimal example. **It is not text to be copied verbatim** — it is the shape the skill must respect.

`requirements.md` is the spec's **entry point**: it holds the header block with the spec's single `Status` line. `design.md` and `tasks.md` do not repeat it.

---

## Header

Every spec starts with metadata in a blockquote (no tables, no blocks, simple as shown below):

```markdown
# SPEC NN — Short, descriptive title

> **Status:** Draft
> **Depends on:** SPEC 01, SPEC 02
> **Date:** YYYY-MM-DD
> **Objective:** A single sentence. If you need two sentences, the feature is too big.
```

**Valid states:** `Draft`, `In review`, `Approved`, `Implemented`, `Obsolete`.

> The labels above are the English defaults. The skills also accept equivalents in any language (e.g. Spanish `Borrador` / `En revisión` / `Aprobado` / `Implementado` / `Obsoleto`). Pick one set per repo and stay consistent.

**Objective rule:** one sentence that a human reads in 5 seconds and understands what is going to be built. If it doesn't fit in one sentence, split the feature.

If the spec depends on nothing, write `> **Depends on:** —`.

---

## Section 1 — Context

Who the feature is for and what it achieves. Two lines, not an essay. Add a short **why** paragraph only if the spec takes non-obvious decisions or breaks project patterns.

```markdown
## Context

**Primary user:** Active job seekers.
**Goal:** Improve CV quality to strengthen the professional profile.
```

---

## Section 2 — Scope

Two explicit sub-blocks. **Both are mandatory.**

```markdown
## Scope

**In:**

- Concrete thing one.
- Concrete thing two.

**Out of scope (for future specs):**

- Something that could be done but not now.
- Something that came up in the conversation but is not in.
```

**Why "out" matters:** it captures the things the user mentioned during the question phase but were decided to be deferred. Without that record, during implementation there will be a temptation to slip them in "while we're at it".

---

## Section 3 — Requirements

Numbered user stories. Each story has its own **acceptance criteria** written in **EARS** notation (Easy Approach to Requirements Syntax). Criteria are numbered `<story>.<criterion>` so that `tasks.md` can reference them (`_Requirements: 1.2_`).

```markdown
## Requirements

### Requirement 1 — Upload CV for analysis

**As a** job seeker
**I want to** upload my CV in PDF or plain-text format
**So that** the system can analyze it and compare it with job offers

**Acceptance criteria:**

1.1. WHEN a user uploads a PDF file THE SYSTEM SHALL extract its text content.
1.2. WHEN a user uploads a file larger than 5 MB THE SYSTEM SHALL reject it and show "File too large (max 5 MB)".
1.3. IF the PDF contains no extractable text THEN THE SYSTEM SHALL show "We could not read this file" and keep the previous CV.
1.4. WHILE an upload is in progress THE SYSTEM SHALL disable the upload button.
```

**EARS patterns:**

| Pattern      | Shape                                                    | Use it for                          |
| ------------ | -------------------------------------------------------- | ----------------------------------- |
| Event-driven | `WHEN <trigger> THE SYSTEM SHALL <response>`             | Reactions to user or system events. |
| State-driven | `WHILE <state> THE SYSTEM SHALL <response>`              | Behavior during a state.            |
| Unwanted     | `IF <condition> THEN THE SYSTEM SHALL <response>`        | Errors and degraded cases.          |
| Optional     | `WHERE <feature is enabled> THE SYSTEM SHALL <response>` | Behavior behind a flag or setting.  |
| Ubiquitous   | `THE SYSTEM SHALL <response>`                            | Always-true constraints.            |

Keep the EARS keywords (`WHEN`, `THE SYSTEM SHALL`, …) in uppercase English even when the rest of the spec is in another language — they are the notation, not prose.

**Rules:**

- Every criterion is **boolean**: it can be verified with yes or no.
- Every criterion has a concrete trigger and a concrete response. Quote exact messages, limits and names.
- Cover the unhappy paths: invalid input, failures, empty states, limits.
- Requirements describe **observable behavior**, not implementation. ❌ "Use pdf.js to parse the file." → that is a design decision.

**Anti-patterns to avoid:**

- ❌ "THE SYSTEM SHALL work well." → not verifiable.
- ❌ "THE SYSTEM SHALL have good UX." → subjective.
- ❌ "THE SYSTEM SHALL have no bugs." → not operational.
- ✅ "WHEN the user presses Esc THE SYSTEM SHALL pause the game and show the menu." → verifiable, boolean.

---

## Final section — What is NOT in (reinforcement)

Repeat explicitly at the end what **will not** be done in this spec. This repetition is deliberate — the Scope section already says it, but at the end of the document it serves as a reminder when someone reads only the last lines.

```markdown
## What is **not** in this spec

- Visual editor (another spec if it ever lands).
- Multiplayer.

Each one of those, if it lands, goes in its own spec.
```

---

## Global rules

- **One sentence per idea.** If a sentence has two commas and a semicolon, split it.
- **No TODOs.** A TODO means the decision was not made. Make it or note it as an open question with a reason.
- **No solutions.** Technologies, files and data structures belong in `design.md`.
- **Standard markdown.** It must render on GitHub without surprises.
