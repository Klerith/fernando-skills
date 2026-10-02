# Steering template — `tech.md`

Reference for `.sdd/steering/tech.md`: **the technology stack and how to work with it.** It keeps every design using the same tools, versions and commands instead of improvising new ones. **It is not text to be copied verbatim** — fill each section with facts from the project (manifests, lockfiles, config files, CI), and omit sections that do not apply.

Keep it short (under ~100 lines). It describes the stack **as it exists today**, not plans.

---

```markdown
# Tech stack

> **Last updated:** YYYY-MM-DD · by SPEC NN (or "initial generation")

## Stack

| Layer     | Technology              | Version | Notes                       |
| --------- | ----------------------- | ------- | --------------------------- |
| Language  | TypeScript              | 5.6     | `strict: true`              |
| Framework | Next.js (App Router)    | 15      |                             |
| Database  | PostgreSQL via Drizzle  | 16      | Migrations in `drizzle/`    |
| Testing   | Vitest, Playwright      |         | Unit and e2e                |

## Key libraries

- `zod` — input validation at every API boundary.
- `pdf-parse` — PDF text extraction. (SPEC 01)

## Commands

| Task          | Command          |
| ------------- | ---------------- |
| Install       | `pnpm install`   |
| Dev server    | `pnpm dev`       |
| Unit tests    | `pnpm test`      |
| Lint / format | `pnpm lint`      |
| Build         | `pnpm build`     |

## Technical constraints

- Constraints every design must respect (e.g. "Must run on Node 20", "No native dependencies", "Deployed to Vercel serverless — no long-running processes").

## Testing conventions

- Where tests live, how they are named, what is expected per change (e.g. "Every API route has an integration test").
```

Only list commands that actually exist in the project. Never invent a command.
