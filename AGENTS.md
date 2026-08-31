# SkyPlan — Agent & Contributor Standards

This file is the shared, tool-agnostic entry point for **any** coding
agent (Claude Code, Cursor, Copilot, Windsurf, etc.) and for human
contributors. Multiple people use different agents on this repo — these
standards keep the output consistent regardless of which one wrote it.

## Project

Flutter mobile app ("Planificador de Actividades") for the Programación
Dispositivos Móviles final project. Full spec:
[`.agents/requirements/proyecto-final.md`](.agents/requirements/proyecto-final.md).

## Skills

Reusable, detailed conventions live as skills under
[`.agents/skills/`](.agents/skills/) (also exposed at `.claude/skills/` via
symlink for Claude Code). Load the relevant one before doing related work:

| Skill | Use for |
|---|---|
| [`git-workflow`](.agents/skills/git-workflow/SKILL.md) | Branch naming, commit format, PR requirements |
| [`clean-architecture-flutter`](.agents/skills/clean-architecture-flutter/SKILL.md) | Where new code belongs, layering rules |
| [`project-requirements`](.agents/skills/project-requirements/SKILL.md) | Checklist to verify nothing from the rubric is missing |
| [`flutter-expert`](.agents/skills/flutter-expert/SKILL.md) | General Flutter guidance |
| [`dart-best-practices`](.agents/skills/dart-best-practices/SKILL.md) | Dart style/idioms |
| [`flutter-testing`](.agents/skills/flutter-testing/SKILL.md) | Test conventions |
| [`flutter-animations`](.agents/skills/flutter-animations/SKILL.md) | Animation patterns |
| [`bash-defensive-patterns`](.agents/skills/bash-defensive-patterns/SKILL.md) | Shell scripting in tooling/CI |

## Non-negotiable rules (summary — see skills for full detail)

1. **Never commit directly to `main`.** One branch per feature/fix, always
   merged via Pull Request. See `git-workflow`.
2. **Clean Architecture, feature-first.** `lib/features/<name>/{data,domain,presentation}`.
   `domain/` has no Flutter/package imports. See `clean-architecture-flutter`.
3. **Every required item in `.agents/requirements/proyecto-final.md` must
   ship.** Extra/innovative features are welcome, but never at the cost of
   a missing requirement, and must be clearly labeled as extras in the PR.
   See `project-requirements`.
4. **Code and commits in English**; comments only where the *why* isn't
   obvious from the code.
5. Run `flutter analyze` and `flutter test` before opening a PR.

## For humans

Everyone on the team should be able to explain and defend any part of the
code (grading is individual — see the spec's instructions). Don't accept
agent-generated code you can't explain.
