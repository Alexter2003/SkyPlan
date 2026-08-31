---
name: git-workflow
description: |-
  Git branching, commit, and PR conventions for the SkyPlan project. Use
  whenever creating branches, committing, or opening/merging pull requests,
  regardless of which coding agent or IDE is being used.
license: Apache-2.0
---

# Git Workflow — SkyPlan

Team project with multiple developers, possibly using different coding
agents (Claude Code, Cursor, Copilot, etc.). These rules are agent-agnostic
so everyone produces the same git history.

## 1. When to use this skill
- Before creating a branch, committing, or opening a PR.
- When asked to "start work on X" or "implement feature Y".
- When reviewing whether a change is ready to merge.

## 2. Branching

- **Never commit directly to `main`.** `main` only receives merges via PR.
- One branch per feature/fix, always cut from an up-to-date `main`:
  - `feature/<short-description>` — new functionality (e.g.
    `feature/activity-weather-filter`)
  - `fix/<short-description>` — bug fixes
  - `chore/<short-description>` — tooling, deps, config
  - `refactor/<short-description>` — no behavior change
  - `docs/<short-description>` — documentation only
- Names in English, kebab-case, no ticket numbers unless the team adopts an
  issue tracker.
- Keep branches small and scoped to one module/requirement from
  `.agents/requirements/proyecto-final.md` when possible (e.g. one branch
  per sub-requirement of the Activities module, not the whole module at
  once).

## 3. Commits

- Conventional Commits, message in English:
  `<type>(<scope>): <short summary>`
  - Types: `feat`, `fix`, `chore`, `refactor`, `test`, `docs`, `style`,
    `perf`, `ci`.
  - Scope = feature/module name when useful (`feat(locations): add cascade
    delete`).
- Small, logically-scoped commits over one giant commit. Each commit should
  leave the project in a working (buildable) state.
- No `--no-verify`, no force-push to `main`, no rewriting history that has
  already been pushed and reviewed.

## 4. Pull Requests

- **Every change reaches `main` through a PR** — no exceptions, even for a
  single-line fix or a solo contributor.
- PR title mirrors the primary commit's conventional-commit format.
- PR description must state:
  - What changed and why.
  - Which requirement(s) from `.agents/requirements/proyecto-final.md` it
    addresses (module + letter, e.g. "Módulo de Actividades — 4.a").
  - How it was tested (manual steps and/or `flutter test` output).
- Run `flutter analyze` and `flutter test` locally before opening the PR;
  a PR with failing analysis/tests is not ready for review.
- At least one other teammate reviews before merge when the team size
  allows it; for a solo/pair project, self-review against this checklist
  and the `project-requirements` skill is the minimum bar.
- Prefer squash-merge so `main` history reads as one entry per feature.
- Delete the branch after merge.

## 5. Discovery

- To check if a change was made outside a PR: `git log main --oneline` and
  compare against `gh pr list --state merged`.
- To check the current branch follows convention:
  `git branch --show-current` should match
  `^(feature|fix|chore|refactor|docs)/[a-z0-9-]+$`.

## Related Skills

- **[clean-architecture-flutter](../clean-architecture-flutter/SKILL.md)** —
  where new code should live before it's committed.
- **[project-requirements](../project-requirements/SKILL.md)** — what a PR
  must satisfy before it can be considered complete.
