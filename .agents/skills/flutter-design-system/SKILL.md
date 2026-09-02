---
name: flutter-design-system
description: |-
  SkyPlan's visual language and UI kit: design tokens (color, typography,
  shapes, spacing, motion), the full component inventory under
  lib/core/design_system/, theming rules, and the standards that keep every
  screen visually consistent regardless of who builds it. Use before
  building or reviewing ANY screen/widget, and whenever a color, font,
  radius, or spacing value is about to be hard-coded.
license: Apache-2.0
---

# Flutter Design System — SkyPlan

SkyPlan's approved visual direction is **Dirección A (Bauhaus)**, **Paleta 2
"Cian neblina"**: geometric primaries (red/blue/yellow) as accents over a
cool cian-neutral base, thick borders, a visible 24px retícula, and small,
consistent corner radii ("redondeado, lo mínimo elegante" — never sharp,
never pill-shaped except chips/badges). The full direction was explored and
approved in a design canvas before this kit was built; this skill is the
canonical, code-level source of truth going forward.

## 1. When to use this skill

- Building any new screen, widget, or form.
- Reviewing whether a PR's UI matches the rest of the app.
- About to write a raw `Color(0x...)`, a `TextStyle`, an `EdgeInsets`
  number, or a `BorderRadius.circular(...)` by hand — stop, this skill (and
  the kit it documents) almost certainly already has a token or component
  for it.
- Deciding where a new design-system piece belongs.

## 2. The non-negotiable rule

**Never hard-code a color, font, radius, spacing value, or duration in
screen/feature code.** Everything comes from the tokens in
`lib/core/design_system/tokens/`, reached through `BuildContext` extensions:

```dart
final colors = context.skyColors;       // SkyColors
final type = context.skyTypography;     // SkyTypography
final shapes = context.skyShapes;       // SkyShapes
// SkySpacing.md, SkyMotion.base — static, no context needed
```

`SkyColors` (`lib/core/design_system/tokens/sky_colors.dart`) is the single
place brand and status colors are defined — this is the "themeColor" the
rest of the app must go through instead of introducing new colors. If a
screen needs a color that isn't one of `SkyColors`' fields, that is a design
decision (new token or reuse an existing one) — raise it, don't invent a
`Color(0xFF...)` inline.

Discovery check for reviews: grep feature code (`lib/features/`) for
`Color(0x`, `TextStyle(`, `BorderRadius.circular(` outside
`design_system/` — any hit is a violation.

## 3. Tokens

| Token file | Extension / access | Contains |
|---|---|---|
| `tokens/sky_colors.dart` | `context.skyColors` | `background`, `surface`, `ink`, `subtle`, `border`, `primaryRed/Blue/Yellow`, `onAccent`, `statusApt/Caution/Postpone` (each a `SkyStatusColor{background, foreground}`) |
| `tokens/sky_typography.dart` | `context.skyTypography` | `display`, `headline`, `title`, `body`, `bodyStrong`, `label`, `caption` — Archivo, falls back to system sans until the font asset ships |
| `tokens/sky_shapes.dart` | `context.skyShapes` | `xs`(6) `sm`(8) `md`(12) `lg`(18) `pill`(999) radii + `radiusXs/Sm/Md/Lg/Pill`; `borderThin`(2) `borderThick`(3) |
| `tokens/sky_spacing.dart` | `SkySpacing.xxs..xxxl` (static) | 4px-grid spacing: 4/8/12/16/20/24/32/40 |
| `tokens/sky_motion.dart` | `SkyMotion.*` (static) | `fast`(150ms) `base`(250ms) `slow`(350ms) durations; `standard`/`emphasized` curves |

Both `SkyColors` and `SkyTypography` are `ThemeExtension`s registered by
`SkyTheme` (`theme/sky_theme.dart`), so `SkyTheme.light` / `SkyTheme.dark`
are the only two `ThemeData` the app should ever build.

### Color usage rules

- `ink` is text **and** the thick Bauhaus borders — don't invent a separate
  border color for that use; `border` is reserved for hairline dividers.
- `primaryRed` doubles as the danger/destructive action color and the
  "posponer" status — don't add a second red.
- Status colors (apt/caution/postpone, requirement 5.e) come only from
  `colors.statusColor(SkyStatus.x)` — never branch on a raw green/amber/red.
- `onAccent` is "the text/icon color that reads on a primary fill" — use it
  any time text sits on `primaryRed`/`primaryBlue`/a status background.

## 4. Theme switching

`theme/sky_theme_context.dart` provides `SkyThemeController`
(`ChangeNotifier`, holds `ThemeMode`) and `SkyThemeScope`
(`InheritedNotifier`), wired once in `main.dart` above `MaterialApp`:

```dart
SkyThemeScope(
  controller: SkyThemeController(),
  child: Builder(
    builder: (context) => MaterialApp(
      themeMode: SkyThemeScope.of(context).mode,
      theme: SkyTheme.light,
      darkTheme: SkyTheme.dark,
      home: const HomeScreen(),
    ),
  ),
)
```

Anywhere else, read/toggle it with `SkyThemeScope.of(context)` —
`.mode`, `.isDark`, `.setMode(ThemeMode.dark)`, `.toggle()`. It's a plain
`ChangeNotifier`/`InheritedNotifier`, chosen deliberately so it doesn't
presuppose the app's eventual state-management pick for feature code (see
`clean-architecture-flutter`, "State management & DI") — it holds no
persistence; if the team wants the choice remembered across launches, that's
a separate, explicit decision (e.g. wiring `shared_preferences`), not
something to bolt on silently here.

## 5. Component inventory

Everything lives under `lib/core/design_system/components/`, and is
exported from the single barrel `lib/core/design_system/design_system.dart`
— import that one file from screens instead of reaching into subfolders.

| Category | Components | Notes |
|---|---|---|
| Buttons | `SkyButton` (primary/secondary/ghost/danger × sm/md/lg, loading, disabled, leading icon, `expand`), `SkyIconButton` | All heights ≥44px (hit-target floor) |
| Inputs | `SkyTextField` (base), `SkyPasswordField` (visibility toggle + confirmation mode), `SkyEmailField`, `SkySearchField`, `SkyDateField`, `SkyTimeField`, `SkyDropdown<T>`, `SkyTextArea` | Validation via `core/utils/validators.dart` (`SkyValidators`), not ad-hoc regex in screens |
| Selection | `SkyChip` (outline/filled, selectable), `SkySegmentedControl<T>`, `SkyCheckbox` (optional strike-through label), `SkyRadio<T>`, `SkyToggle` | |
| Sliders | `SkySlider`, `SkyRangeSlider` | For weather-condition ranges (temperature, rain probability) when creating an activity |
| Surfaces | `SkyScaffold` (screen shell over `SkyBackground`), `SkyCard`, `SkyBackground` (retícula texture), `SkyDivider` | Build new screens on `SkyScaffold`, not a raw `Scaffold` |
| Feedback | `SkyBadge`, `SkyProgressBar`, `SkySnackbar` (`.show(context, msg, tone: ...)`), `SkyEmptyState`, `SkySkeleton`, `SkyDialog` (`.confirm(...)`), `SkyBottomSheet` (`.show(...)`) | |
| Weather/domain | `SkyWeatherChip` (temp + condition), `SkyStatusIndicator` (apto/precaución/posponer) | The only place weather/status visuals should be assembled — don't rebuild them ad hoc in a feature screen |
| Icons | `SkyIcon(SkyIconType.x)` | Stroke-based, 24px grid, own painter — **never** `Icons.*` (Material) or emoji for app UI. Add a new `SkyIconType` case instead of falling back to Material icons |
| Logo | `SkyLogoMark`, `SkyLogo` (mark + wordmark) | Requirement 1.c — reuse this, don't redraw the mark per screen |

`gallery/kit_gallery_screen.dart` (`KitGalleryScreen`) renders every
component in every state/variant with a light/dark toggle. It's wired at
route `/kit`, registered only `if (kDebugMode)` in `main.dart` — open it to
see current component states before building a new screen, and add any new
component there when you add it to the kit.

## 6. Building a new screen

1. Wrap it in `SkyScaffold`, not `Scaffold` (unless there's a specific
   reason not to — note that reason in the PR).
2. Compose it from kit components first. If the exact piece you need isn't
   in section 5, check `/kit` to confirm, then add it to the kit
   (`components/<category>/`, export from `design_system.dart`, add to the
   gallery) rather than building a one-off styled widget inside the
   feature's `presentation/` folder — the point of the kit is that no
   feature reinvents its own button/input/card.
3. Spacing between elements: `SizedBox(height: SkySpacing.md)` etc., not
   magic numbers.
4. Motion: use `SkyMotion.fast/base/slow` + `SkyMotion.standard/emphasized`
   for any `AnimatedContainer`/`AnimatedOpacity`/custom transition — see
   `flutter-animations` for the animation techniques themselves.

## 7. Icons and logo — don't improvise

`SkyIcon` is a small, deliberately limited stroke set
(`icons/sky_icon.dart`). If a screen needs a concept that isn't in
`SkyIconType`, add a new case (same 24px/2px-stroke/rounded-cap style) —
don't import `Icons.*` or drop in an emoji. The logo (`SkyLogoMark`) is a
`CustomPainter` reproduction of the approved mark (rounded red square,
yellow circle, blue triangle) — reuse `SkyLogo`/`SkyLogoMark`, never
re-draw or restyle the mark per screen.

## 8. Known gaps to close before shipping polish

- **Archivo font**: tokens reference the `Archivo` family with a system-sans
  fallback; the actual `.ttf` assets aren't bundled yet. Add them under
  `assets/fonts/` and declare them in `pubspec.yaml`'s `flutter.fonts` when
  available — no token/component code needs to change.
- **Theme persistence**: `SkyThemeController` is in-memory only (resets to
  `ThemeMode.system` on relaunch). Persisting the user's choice is a
  separate task once the app's storage approach is decided.

## 9. Discovery

- `grep -rn "Color(0x" lib/features/` — any hit outside `design_system/` is
  a token violation.
- `grep -rn "Icons\." lib/` — any hit means a Material icon slipped in
  instead of `SkyIcon`.
- `grep -rn "extends ThemeExtension" lib/core/design_system/tokens/` — the
  full list of registered token sets; add new tokens here, not as loose
  constants in a feature file.

## Related Skills

- **[clean-architecture-flutter](../clean-architecture-flutter/SKILL.md)** —
  why the kit lives in `core/`, not `features/`.
- **[flutter-animations](../flutter-animations/SKILL.md)** — how to
  implement motion once you have `SkyMotion`'s durations/curves.
- **[flutter-testing](../flutter-testing/SKILL.md)** — widget-test
  conventions; see `test/core/design_system/` for existing examples.
- **[project-requirements](../project-requirements/SKILL.md)** — which
  requirement each weather/status piece (`SkyWeatherChip`,
  `SkyStatusIndicator`) is standing in for.
