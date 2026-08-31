---
name: project-requirements
description: |-
  Verifies work against the SkyPlan final-project requirements (graded
  rubric). Use before marking a module/feature done, before opening a PR
  that closes out a module, and when deciding whether an idea is a required
  item, an allowed extra, or scope creep that risks the deadline.
license: Apache-2.0
---

# Project Requirements Compliance — SkyPlan

Canonical spec: `.agents/requirements/proyecto-final.md` (converted from
the professor's PDF). This skill exists so no required item silently gets
dropped while extra/innovative ideas are still welcome.

## 1. When to use this skill
- Before marking any module or sub-requirement as "done".
- Before opening a PR that claims to close out part of a module.
- When a developer (or agent) wants to add something **not** in the spec —
  use this to classify it (extra vs. distraction) before building it.
- Periodically, to audit how much of the rubric is actually implemented.

## 2. The rule

1. **Nothing in the checklist below may be skipped, simplified away, or
   silently descoped.** If a requirement seems ambiguous or conflicts with
   something else, flag it to the team/user — do not just drop it.
2. **Extras are welcome, but never at the cost of a required item.** A
   developer may add innovative features (e.g. push notifications, offline
   cache, animations, extra filters) as long as:
   - All required items for that module are already implemented, or the
     extra doesn't consume time/scope that a still-missing requirement
     needs.
   - The extra is clearly separable in the code (its own
     usecase/widget/branch) so it can be reviewed or removed without
     breaking required functionality.
   - It's called out in the PR description as "extra / no está en el
     enunciado" so graders and teammates don't confuse it with a rubric
     item.
3. When implementing a module, cross-check every sub-item (a, b, c, i, ii…)
   individually — partial module implementation (e.g. login screen without
   encrypted-credential handling) counts as incomplete.

## 3. Checklist (mirrors `.agents/requirements/proyecto-final.md`)

### Login — 10%
- [ ] Login screen validates credentials via API against the app's DB.
- [ ] Credentials are handled **encrypted** (in transit and at rest —
  never store/log plaintext passwords).
- [ ] Home screen has a side/drawer menu linking to every module.
- [ ] Home screen has a logout button.
- [ ] App has a logo and a defined color palette used consistently.

### Módulo de Usuario — 10%
- [ ] Screen shows the logged-in user's info.
- [ ] User can edit personal data, **except** username and password.
- [ ] "Forgot password" flow: email-based, issues a temporary password.
- [ ] First login with a temporary password forces a password-change
  screen.
- [ ] Password-change screen requires **double confirmation** (new
  password entered twice and matched).

### Módulo de Ubicaciones Registradas — 20%
- [ ] Screen to register a location with its essential data.
- [ ] Location can be obtained via phone GPS **or** Google Maps API
  (manual pin selection).
- [ ] Coordinates are persisted in the database.
- [ ] Edit existing locations.
- [ ] Delete a location **cascades** to delete its activities too.
- [ ] Screen listing all locations available in the planner.

### Módulo de Actividades — 30%
- [ ] Screen listing activities, grouped/filterable by their location.
- [ ] Time-overlap validation: activities at a location must not overlap
  each other.
- [ ] Create-activity screen: pick location, description, date, time
  range, activity type (outdoor/indoor), desired weather conditions
  list.
- [ ] Edit-activity screen for general data.
- [ ] Delete an activity.

### Módulo de Actividades Pendientes — 30%
- [ ] Screen listing upcoming activities with assigned location and that
  day's weather at that location (via a weather API).
- [ ] Filters: by date proximity, by location, by likelihood of happening
  given the weather.
- [ ] Mark an activity as completed.
- [ ] Reschedule an activity from this screen.
- [ ] Per-activity likelihood indicator, computed from activity type +
  forecast weather.

## 4. How to run this check

1. Open `.agents/requirements/proyecto-final.md` and this checklist side
   by side.
2. For the module being worked on, go item by item — check the actual
   screen/code, don't assume from the branch name.
3. If something is unchecked and not yet planned, say so explicitly rather
   than reporting the module as "done".
4. Before a PR that claims a module complete, paste the relevant subset of
   this checklist into the PR description with boxes checked/unchecked.

## Related Skills

- **[git-workflow](../git-workflow/SKILL.md)** — PRs must reference which
  requirement(s) they close.
- **[clean-architecture-flutter](../clean-architecture-flutter/SKILL.md)**
  — where each module's implementation should live.
