# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.0](https://github.com/Klerith/fernando-skills/compare/v0.1.2...v0.2.0) (2026-06-29)


### Features

* **spec:** introduce AutoCreateBranch configuration for branch management ([1273a5c](https://github.com/Klerith/fernando-skills/commit/1273a5c1a152711f024c0afc336c2cb2a3b019cd))

## [0.1.2](https://github.com/Klerith/fernando-skills/compare/v0.1.1...v0.1.2) (2026-06-26)


### Bug Fixes

* **spec:** improve metadata formatting in spec template ([96e4c64](https://github.com/Klerith/fernando-skills/commit/96e4c64f04c8992260fe1e24c96fc05a9981d47e))

## [0.1.1](https://github.com/Klerith/fernando-skills/compare/v0.1.0...v0.1.1) (2026-05-23)


### Bug Fixes

* remove shell command directives to pass Gen Agent Trust Hub audit ([b5d4402](https://github.com/Klerith/fernando-skills/commit/b5d4402e3ffe6305971104882487192d0e603a53))
* remove shell injection vector in spec-impl Phase 2 ([b946f46](https://github.com/Klerith/fernando-skills/commit/b946f46f752e71a74c85080a85ce20c478d8df99))
* **spec:** stop after saving spec and point to /spec-impl ([1cbde98](https://github.com/Klerith/fernando-skills/commit/1cbde987627171305411d2be20ff0caad2739c20))
* use single quotes for argument-hint in spec SKILL.md ([7f6252a](https://github.com/Klerith/fernando-skills/commit/7f6252a5f16a05cc4b4469366697aaf892809f23))

## [Unreleased]

## [0.1.0] - 2026-05-07

### Added

- `/spec` skill — guides Claude through a four-phase spec authoring workflow (context → clarification → section-by-section drafting → save). Writes specs to `specs/NN-slug.md` with status `Draft`.
- `/spec-impl` skill — validates spec status is `Approved`, creates a dedicated git branch (`spec-NN-slug`), and implements the spec step by step with diff pauses between each step.
- `scripts/link-skills.sh` — symlinks all skills into `~/.claude/skills/` for local development.
- `scripts/install-to-agent.sh` — translates skills for Cursor, Codex, and Antigravity agents.
- `scripts/list-skills.sh` — lists all available skills.

[Unreleased]: https://github.com/Klerith/fernando-skills/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/Klerith/fernando-skills/releases/tag/v0.1.0
