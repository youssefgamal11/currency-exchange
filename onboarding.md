# Onboarding Screen UI + Design-Token Infrastructure

## Context

The Currency Exchange Tracker ("Axis") needs its onboarding screen built — UI only, no
navigation/business logic. Before that screen can be built properly, the shared design-token
files it depends on need to go from stubs to a real implementation:

- `AppColors` currently defines exactly one color (`blue`, an old placeholder never matching the
  approved dark-fintech design).
- `AppTextStyle` references font families (`'Inter'`, `'PlayfairDisplaySC'`) that don't exist as
  actual files anywhere in the project — no `fonts:` block in `pubspec.yaml`, no `.ttf` files.
- `ImgPath` points at an SVG (`onboarding_logo.svg`) that doesn't exist, and there is no
  `assets/` folder in the project at all.
- The onboarding page itself is a bare placeholder `Scaffold`, not wired into any real navigation
  (the `AppRouter`/`RouteName` scaffolding exists but is dead code — `main.dart` goes straight to
  a placeholder `HomePage`).

This plan builds the real onboarding screen against the design already approved with the user
(dark fintech style, floating rate-chip hero, amber/green/red palette — see token values below,
sourced from the HTML mockup built earlier in this project) and the real token infrastructure it
needs, while deliberately keeping navigation/routing/business logic out of scope.

**Decisions already confirmed with the user:**
1. **Fonts**: the user will supply the actual Inter `.ttf` files — bundled locally via
   `pubspec.yaml`'s `fonts:` block. No `google_fonts` dependency.
2. **Flags**: the user will supply 6 SVG flag files — rendered via the already-installed (but
   currently unused) `flutter_svg` package, referenced through `ImgPath`.
3. **`AppTextStyle` naming**: keep the existing terse `{weightAbbrev}{size}` convention (`eb16`,
   `b11`, `m14`, …) rather than switching to semantic names.

**Blocking dependency on the user:** this plan wires up all the code assuming the asset files
exist at specific paths/filenames (listed below). The actual `.ttf`/`.svg` files must be dropped
into place before `flutter run` will succeed — `flutter pub get` may succeed even with missing
asset files, but build/run will fail with an "unable to find asset" error until they're present.

---

## Design tokens to implement (source of truth: the approved HTML mockup)

**Colors** (dark theme only — this app doesn't need a light theme):

| Token | Hex / value |
|---|---|
| background | `#0A0C11` |
| surface | `#12151D` |
| surfaceElevated | `#1A1E28` |
| border | `rgba(255,255,255,0.07)` |
| borderStrong | `rgba(255,255,255,0.15)` |
| textPrimary | `#FFFFFF` |
| textSecondary | `#8A93A6` |
| textTertiary | `#565E70` |
| accent | `#F7B031` |
| accentStrong | `#FFC65C` |
| accentTint | `rgba(247,176,49,0.12)` |
| good | `#34D399` |
| goodTint | `rgba(52,211,153,0.12)` |
| critical | `#F2685C` |
| criticalTint | `rgba(242,104,92,0.12)` |
| info | `#6EA8E0` |
| infoTint | `rgba(110,168,224,0.12)` |

**Type scale** (all Inter, weights 400/500/700/800 — no serif; the earlier serif direction was
explicitly rejected in favor of all-bold-sans):

| Role | Size / weight |
|---|---|
| Onboarding headline | 25sp / w800 |
| Section/card title | 14–18sp / w800 |
| Body / row text | 13–14sp / w700 |
| Secondary gray line | 12sp / w500 |
| Caption / eyebrow label | 10–11sp / w700 |
| Button text | ~15sp / w700 |

## Onboarding screen structure (already approved)

1. Brand lockup — icon badge (amber gradient, "£") + "Axis" title + "EGP Exchange Tracker"
   subtitle.
2. Hero — center "EGP" badge card, 4 floating rate chips around it (USD 52.01 green spark, GBP
   70.02 red spark, JPY 0.33 green spark, SAR 13.87 green spark), each rotated a few degrees,
   non-overlapping.
3. Headline: "Track the Pound's *true value,* in real time." — "true value," in amber, rest white.
4. Subheading paragraph, gray.
5. Feature pills (wrapping): "Live Rates", "7-Day Charts", "Offline Cache", "Daily Δ".
6. Flag row: 5 flags (USD/EUR/GBP/SAR/JPY) with code labels.
7. Primary CTA: "Start Tracking Rates" + arrow icon, amber gradient, full width. `onPressed` is a
   no-op/TODO — no navigation wiring in this task.

---

## File-by-file changes

### 1. `lib/core /theme/colors.dart` — full rewrite

Replace the single `blue` stub with the full palette above, as `static const Color` fields
(const-foldable using literal `0xAARRGGBB` hex for the tint variants, e.g.
`accentTint = Color(0x1FF7B031)` for 12% opacity). Remove `blue` entirely (confirmed zero
references elsewhere in the codebase).

### 2. `lib/core /theme/text_style.dart` — full rewrite

Keep the existing inline-`TextStyle`-per-field style and terse naming convention. Drop
`playfairFamily` (confirmed unused elsewhere). Default color becomes `AppColors.textPrimary`
(white) instead of the old `AppColors.blue`; secondary/gray styles default to
`AppColors.textSecondary`. New/updated fields to cover every role above:

- `r10` (10sp/w400) — keep as-is, update color
- `m12` (12sp/w500, textSecondary) — new, secondary gray lines
- `m14` (14sp/w500) — keep as-is, update color
- `b10` (10sp/w700) — new, eyebrow/caption labels (letter-spacing applied at call-site)
- `b11` (11sp/w700) — keep as-is, update color
- `b14` (14sp/w700) — new, body/row text
- `b15` (15sp/w700) — new, button text
- `eb14` (14sp/w800) — new, section title (lower end)
- `eb16` (16sp/w800) — keep as-is, update color
- `eb18` (18sp/w800) — new, section title (upper end)
- `eb25` (25sp/w800, height 1.25) — new, onboarding headline

`fontFamily` stays `'Inter'`, now backed by real bundled font files (see pubspec changes below).
Colors requiring accent/good/critical (e.g. the two-tone headline) are applied at the widget
level via `.copyWith(color: ...)`, not baked into shared styles.

### 3. `lib/core /utils/img_paths.dart` — full rewrite

```dart
const _flagsPath = 'assets/icons/flags/';

class ImgPath {
  static const flagUsd = "${_flagsPath}us.svg";
  static const flagEur = "${_flagsPath}eu.svg";
  static const flagGbp = "${_flagsPath}gb.svg";
  static const flagSar = "${_flagsPath}sa.svg";
  static const flagJpy = "${_flagsPath}jp.svg";
  static const flagEgp = "${_flagsPath}eg.svg";
}
```

Removes the broken `onboardingLogo` entry (confirmed unused, points at a nonexistent file).

### 4. `pubspec.yaml` — assets and fonts sections

Uncomment/fill under `flutter:`:

```yaml
flutter:
  uses-material-design: true
  assets:
    - assets/icons/flags/
  fonts:
    - family: Inter
      fonts:
        - asset: assets/fonts/Inter-Regular.ttf
          weight: 400
        - asset: assets/fonts/Inter-Medium.ttf
          weight: 500
        - asset: assets/fonts/Inter-Bold.ttf
          weight: 700
        - asset: assets/fonts/Inter-ExtraBold.ttf
          weight: 800
```

No new dependencies needed — `flutter_svg` is already declared, just currently unused; this task
gives it its first real use.

### 5. Asset files the user needs to supply

**Fonts** → `assets/fonts/`:
- `Inter-Regular.ttf` (400)
- `Inter-Medium.ttf` (500)
- `Inter-Bold.ttf` (700)
- `Inter-ExtraBold.ttf` (800)

**Flags** → `assets/icons/flags/`:
- `us.svg`, `eu.svg`, `gb.svg`, `sa.svg`, `jp.svg`, `eg.svg`

I'll create the folders and wire up all referencing code; these specific files need to land in
those exact paths/filenames before the app will actually build and run.

### 6. `lib/features/onBoarding/presenation/pages/onBoarding_page.dart` — full rewrite

Single file, private (`_`-prefixed) `StatelessWidget` classes per section — not split into a
separate `widgets/` folder. Every one of these composite widgets is single-use (Module 1's rate
list will have its own distinct components), so colocating keeps the screen readable top-to-bottom
without the file-switching overhead of 6–8 near-empty single-widget files.

```dart
class OnboardingPage extends StatelessWidget { ... }  // Scaffold + SingleChildScrollView + Column
class _BrandLockup extends StatelessWidget { ... }
class _HeroSection extends StatelessWidget { ... }     // Stack + Positioned, see below
class _RateChip extends StatelessWidget { ... }        // code, rate, isPositiveTrend, corner
class _MiniSparkline extends StatelessWidget { ... }   // CustomPaint, 2px stroke polyline
class _Headline extends StatelessWidget { ... }        // Text.rich, "true value," in amber
class _FeaturePillsRow extends StatelessWidget { ... } // Wrap of pill chips
class _FlagRow extends StatelessWidget { ... }
class _PrimaryCta extends StatelessWidget { ... }      // gradient button, onPressed: () {} // TODO
class _FlagIcon extends StatelessWidget { ... }        // thin SvgPicture.asset wrapper
```

**Hero layout** — `Stack(alignment: Alignment.center, clipBehavior: Clip.none)`:
- `_EgpCenterBadge` as the one non-`Positioned` child (auto-centered by `Stack`'s alignment).
- 4 `_RateChip`s wrapped in `Positioned` (two opposing edges only, e.g. `top`+`left`) and
  `Transform.rotate` (≈3–6°, applied inside `Positioned`, not to it), anchored to the four
  corners of a `SizedBox(height: 240.h)`.
- Sizes/offsets via `flutter_screenutil`'s `.w`/`.h`/`.sp` against the existing
  `designSize: Size(390, 844)` in `main.dart`. Exact non-overlap of chips vs. the center badge
  gets a visual check-and-nudge pass when actually running the app (not solvable perfectly with
  static values alone).

**Scaffold**: `SingleChildScrollView` wraps the whole column — deliberate choice so shorter
devices or larger system text scale scroll instead of overflowing, rather than trying to force
everything into exactly one fixed screen height.

### 7. `lib/main.dart` — temporary, minimal, reversible

Change `home: const HomePage()` → `home: const OnboardingPage()` (+ import) purely to make the
screen viewable. `AppRouter`/`RouteName` wiring stays untouched/out of scope — this line reverts
once real navigation is built in a later task. `HomePage` class stays in `main.dart`, just not
the entry point during this pass.

---

## Verification

1. Confirm the user has dropped the 4 font files + 6 SVG files into `assets/fonts/` and
   `assets/icons/flags/` — build will fail on missing assets otherwise.
2. `flutter pub get`.
3. `flutter analyze` — clean run expected against `flutter_lints: ^6.0.0`; watch for deprecated
   `withOpacity` (use `withValues(alpha:)` instead) and unused-import warnings.

### Critical files
- `lib/core /theme/colors.dart`
- `lib/core /theme/text_style.dart`
- `lib/core /utils/img_paths.dart`
- `lib/features/onBoarding/presenation/pages/onBoarding_page.dart`
- `pubspec.yaml`
- `lib/main.dart`

