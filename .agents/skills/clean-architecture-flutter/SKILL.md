---
name: clean-architecture-flutter
description: |-
  Clean Architecture folder structure and layering conventions for the
  SkyPlan Flutter app. Use when creating new features, screens, models, or
  deciding where a piece of code belongs.
license: Apache-2.0
---

# Clean Architecture — SkyPlan (Flutter)

Multiple developers/agents touch this codebase. A consistent layered
structure keeps modules interchangeable and testable regardless of who (or
which agent) wrote them.

## 1. When to use this skill
- Creating a new feature/module (e.g. Login, Locations, Activities).
- Adding a new screen, widget, model, service, or repository.
- Unsure where a file should live, or reviewing whether a PR respects
  layering.

## 2. Folder structure

Organize by **feature**, then by **layer**, under `lib/features/`:

```
lib/
  core/                     # cross-cutting: theming, DI, routing, errors,
                             # network client, shared widgets/utils
    di/
    theme/
    routing/
    errors/
    utils/
  features/
    auth/                   # e.g. Login + password recovery/change
      data/
        datasources/        # remote (API) / local (secure storage) sources
        models/             # DTOs, fromJson/toJson
        repositories/       # implementations of domain contracts
      domain/
        entities/           # plain Dart objects, no framework deps
        repositories/        # abstract contracts
        usecases/           # one class per business action
      presentation/
        screens/
        widgets/
        state/              # bloc/cubit/provider/notifier for this feature
    user/
    locations/
    activities/
    pending_activities/
  main.dart
```

Each module in `.agents/requirements/proyecto-final.md` maps to one
top-level folder under `features/` (`auth`, `user`, `locations`,
`activities`, `pending_activities`).

## 3. Layer rules

- **domain/** has zero dependencies on Flutter, packages, or `data/`. Only
  pure Dart. This is what makes business rules (e.g. "activities must not
  overlap", "probability of doing an outdoor activity depends on weather")
  independently testable.
- **data/** implements `domain/repositories` contracts. Talks to the
  backend API, Google Maps/Weather APIs, and local/secure storage. Never
  imports `presentation/`.
- **presentation/** only talks to `domain/` (entities + usecases), never
  directly to `data/`. UI state (loading/error/success) lives here.
- Dependency direction is always **presentation → domain ← data**. Nothing
  in `domain/` points outward.
- Shared/reusable pieces (design system components, the app's color
  palette/logo assets, HTTP client, secure-storage wrapper) go in `core/`,
  not duplicated per feature.

## 4. State management & DI

- Pick **one** state-management approach for the whole app (e.g. Bloc,
  Riverpod, or Provider) and use it consistently across features — do not
  mix approaches per feature. If this hasn't been decided yet, raise it as
  a team decision (architecture choice, not something to pick silently
  feature-by-feature).
- Wire dependencies (repositories, usecases, API clients) through a single
  DI setup in `core/di/`, not ad-hoc `new`/singletons scattered in widgets.

## 5. Cross-module rules from the requirements

- Deleting a Location must cascade-delete its Activities
  (`.agents/requirements/proyecto-final.md`, módulo 3.b) — this belongs in
  the `locations` domain/data layer (a usecase orchestrating both
  repositories), not as a database trigger hidden from the app logic.
- Activity time-overlap validation (módulo 4.a.i) and weather-based
  probability (módulo 5.e) are business rules → they live in
  `activities`/`pending_activities` `domain/usecases`, unit-testable
  without Flutter widgets or network calls.

## 6. Discovery

- A file with `import 'package:flutter/material.dart'` inside a
  `domain/` folder is a layering violation.
- A `presentation/` file importing anything from a `data/` folder directly
  (bypassing `domain/`) is a layering violation.
- Grep for direct `http.get`/API calls outside `data/datasources/` to spot
  networking code leaking into the wrong layer.

## Related Skills

- **[project-requirements](../project-requirements/SKILL.md)** — the
  spec each feature folder must satisfy.
- **[git-workflow](../git-workflow/SKILL.md)** — how this code reaches
  `main`.
- **[flutter-expert](../flutter-expert/SKILL.md)**,
  **[dart-best-practices](../dart-best-practices/SKILL.md)** — general
  Flutter/Dart craft, complementary to this structural convention.
