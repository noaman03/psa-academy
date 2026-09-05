# Stitch → Flutter hand-off

Google Stitch (stitch.withgoogle.com) has no plugin, SDK, or API for Flutter.
This folder is the hand-off point: designs come out of Stitch as HTML/screenshots,
land here, and get translated into Flutter against the existing theme.

---

## 1. Prompt Stitch with our design system

Paste this block at the top of every new Stitch conversation, then describe the
screen underneath it. Without it, Stitch invents its own palette and type scale
and every translation turns into a cleanup job.

```
Design a mobile screen for a sports academy management app (coaches, players,
admins). Material 3, light theme, 8px spacing grid, rounded corners (8px on
buttons/inputs, 12px on cards), flat cards with a soft shadow, no gradients.
Default system sans-serif (Roboto).

Palette:
- primary #00A6A6, primary light #D9F7F5, primary dark #006D6F
- secondary #FF7A45, secondary light #FFE4D8, secondary dark #B84B22
- page background #F6F8FB, surface/card #FFFFFF, muted surface #EAF0F6
- text primary #101828, text secondary #667085, hint #98A2B3
- border #D0D5DD
- success #12B76A, error #F04438, warning #F79009, info #2E90FA
- role accents: admin #FF7A45, coach #00A6A6, player #2E90FA

Type scale (px / weight):
- headline 32/600, 28/600, 24/600
- title 22/600, 18/600, 16/600
- body 16/400, 14/400, 12/400
- label 14/500, 12/500, 11/500
- button 14/600

Buttons: 48px min height, 8px radius, 24x14 padding, no elevation.

SCREEN: <describe it here>
```

## 2. Export from Stitch

Use **Copy code** (HTML + Tailwind). That carries exact spacing and colors —
far better input than an image alone. Also grab a screenshot; it catches
hierarchy and intent the markup does not spell out.

## 3. Save here

```
design/stitch/<screen_name>.html    <- the copied code
design/stitch/<screen_name>.png     <- the screenshot
```

Use snake_case matching the intended Flutter file, e.g. `coach_dashboard.html`
-> `lib/pages/coach_dashboard.dart`.

## 4. Ask Claude Code to convert

> Convert `design/stitch/coach_dashboard.html` into a Flutter screen at
> `lib/pages/coach_dashboard.dart`, following `design/stitch/README.md`
> conversion rules.

---

## Conversion rules

**Never hardcode a color or text style.** Every value maps to an existing token.
A translated Stitch export that litters `Color(0xFF00A6A6)` across screens
silently forks the design system — that is the main failure mode here.

### Colors → `AppColors` ([color_scheme.dart](../../lib/config/theme/color_scheme.dart))

| Stitch hex | Token |
|---|---|
| `#00A6A6` | `AppColors.primary` |
| `#D9F7F5` | `AppColors.primaryLight` |
| `#006D6F` | `AppColors.primaryDark` |
| `#FF7A45` | `AppColors.secondary` |
| `#FFE4D8` | `AppColors.secondaryLight` |
| `#F6F8FB` | `AppColors.background` |
| `#FFFFFF` | `AppColors.surface` / `AppColors.cardBackground` |
| `#EAF0F6` | `AppColors.surfaceMuted` |
| `#101828` | `AppColors.textPrimary` |
| `#667085` | `AppColors.textSecondary` |
| `#98A2B3` | `AppColors.textHint` / `AppColors.grey` |
| `#D0D5DD` | `AppColors.border` |
| `#E4E7EC` | `AppColors.greyLight` |
| `#12B76A` `#F04438` `#F79009` `#2E90FA` | `success` `error` `warning` `info` |

Anything off-palette: pick the nearest token rather than introducing a new
constant. If it genuinely needs a new color, add it to `AppColors` first.

### Type → `AppTextStyles` ([text_styles.dart](../../lib/config/theme/text_styles.dart))

Match on font-size + weight:

| px / weight | Style |
|---|---|
| 32/600, 28/600, 24/600 | `headlineLarge` / `headlineMedium` / `headlineSmall` |
| 22/600, 18/600, 16/600 | `titleLarge` / `titleMedium` / `titleSmall` |
| 16/400, 14/400, 12/400 | `bodyLarge` / `bodyMedium` / `bodySmall` |
| 14/500, 12/500, 11/500 | `labelLarge` / `labelMedium` / `labelSmall` |
| 14/600, 16/600, 12/600 (on buttons) | `button` / `buttonLarge` / `buttonSmall` |

Adjust only via `.copyWith(color: ...)` — never redeclare a `TextStyle`.

### Components → existing widgets

Reuse before building. Check these first:

- `lib/presentation/widgets/common/custom_button.dart`
- `lib/presentation/widgets/common/custom_card.dart`
- `lib/presentation/widgets/common/custom_text_field.dart`
- `lib/presentation/widgets/common/empty_state.dart`
- `lib/presentation/widgets/common/loading_indicator.dart`
- `lib/presentation/widgets/common/error_message.dart`
- `lib/widgets/constrained_button.dart`
- `lib/widgets/responsive_container.dart`

Buttons use `AppButtonStyles` ([button_styles.dart](../../lib/config/theme/button_styles.dart));
inputs use `AppInputDecorations` ([input_decorations.dart](../../lib/config/theme/input_decorations.dart)).

### Layout

- Tailwind spacing (`p-4`, `gap-6`) → `EdgeInsets` / `SizedBox` on the 8px grid.
- Flex row/column → `Row` / `Column`; wrap scrollable bodies in
  `SingleChildScrollView` — Stitch designs assume infinite page height and
  overflow on small devices otherwise.
- The app runs on web too (see `web/`), so keep `ResponsiveContainer` or a
  `LayoutBuilder` breakpoint on wide screens rather than stretching a phone
  layout to 1920px.
- Stitch emits fixed pixel widths freely. Convert to `Expanded` / `Flexible` /
  `double.infinity` unless the width is genuinely fixed (avatars, icons).

### Scope

Convert layout and styling only. Wire Firestore/provider state separately —
Stitch output has no data layer, and inventing one during translation produces
plumbing that does not match the repositories in `lib/data/`.
