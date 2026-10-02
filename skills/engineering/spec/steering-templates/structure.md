# Steering template — `structure.md`

Reference for `.sdd/steering/structure.md`: **how the code is organized and written.** It keeps new files in the right place and new code consistent with existing code. **It is not text to be copied verbatim** — fill each section with what the codebase actually does (read real files, do not guess), and omit sections that do not apply.

Keep it short (under ~100 lines). It describes the codebase **as it exists today**, not plans.

---

````markdown
# Code structure and conventions

> **Last updated:** YYYY-MM-DD · by SPEC NN (or "initial generation")

## Folder layout

```
src/
├── app/          # routes and pages (Next.js App Router)
├── cv/           # CV upload and parsing (SPEC 01)
├── lib/          # shared utilities, no business logic
└── db/           # schema and queries
tests/            # mirrors src/
```

## Naming

- Files: `kebab-case.ts`. React components: `PascalCase.tsx`.
- Functions and variables: `camelCase`. Constants: `UPPER_SNAKE_CASE`.
- Tests: `<file>.test.ts` next to… / under `tests/` mirroring `src/`.

## Code conventions

- Error handling pattern (e.g. "Throw typed errors in services, map to HTTP codes in routes").
- Imports (e.g. "Absolute imports via `@/`").
- State management, async style, logging — whatever is consistent in the codebase.

## Patterns to follow

- Pattern — where to see an example (`src/cv/parser.ts`).

## Patterns to avoid

- Anti-pattern — why.
````

Point to real example files whenever possible: one concrete example beats a paragraph of rules.
