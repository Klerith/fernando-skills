# Steering template — `product.md`

Reference for `.sdd/steering/product.md`: **what the product is and who it is for.** It gives every spec the same understanding of the product, so requirements stay coherent across specs. **It is not text to be copied verbatim** — fill each section with facts from the project, and omit sections that do not apply.

Keep it short (under ~80 lines). It describes the product **as it exists today**, not plans.

---

```markdown
# Product

> **Last updated:** YYYY-MM-DD · by SPEC NN (or "initial generation")

## Purpose

One or two sentences: what the product does and the problem it solves.

## Users

- **Primary user:** who, and what they want to achieve.
- **Secondary users:** if any.

## Main features

- Feature — one line. (SPEC NN)
- Feature — one line. (SPEC NN)

## Domain glossary

| Term      | Meaning in this project                     |
| --------- | ------------------------------------------- |
| Job offer | A posting imported from an external board.  |

## Product constraints

- Business or product rules every spec must respect (e.g. "Free tier is limited to 3 CV analyses per month").
```

Tag features with the spec that introduced them when known, so a reader can find the decisions behind them.
