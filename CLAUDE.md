# CLAUDE.md

Project standards for SkyPlan live in [`AGENTS.md`](AGENTS.md) — that file
is the single source of truth, kept generic so it applies to any coding
agent working in this repo (not just Claude Code). Read it before making
changes here.

Skills referenced there live in `.agents/skills/` and are also available
under `.claude/skills/` (symlinked) so Claude Code's `Skill` tool picks
them up directly — in particular `git-workflow`,
`clean-architecture-flutter`, `flutter-design-system`, and
`project-requirements`.

Quick pointers specific to this repo:
- Requirements spec: `.agents/requirements/proyecto-final.md`.
- Never work or commit directly on `main` — see `git-workflow` skill.
- Building or touching any screen/widget? Load `flutter-design-system`
  first — colors, type, radii, spacing and motion all come from
  `lib/core/design_system/`, never hard-coded.
- Before marking a module done, run through the `project-requirements`
  skill's checklist.
