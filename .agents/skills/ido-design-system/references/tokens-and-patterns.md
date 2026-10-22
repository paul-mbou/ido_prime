# Tokens and code patterns

## Source of truth (always read)

- `lib/src/core/theme/app_colors.dart`
- `lib/src/core/theme/app_theme.dart`
- `lib/src/core/theme/app_visual_style.dart` — `light` | `dark`
- `lib/src/core/theme/theme_controllers.dart` — `appVisualStyleProvider`
- Rule: `.cursor/rules/no-sizedbox-use-gutter.mdc`

## Color roles

| Token | Use |
|-------|-----|
| `primary` / gold | FAB, filled CTAs, selected theme border, AI chip glow, Pro badge |
| `onPrimary` | Text/icons on gold |
| `scaffoldBackgroundColor` | Page canvas |
| `colorScheme.surface` | Cards, sheets, elevated panels |
| `onSurface` | Primary text & icons |
| `onSurfaceVariant` | Secondary labels, hints, section titles |
| `outline` / `outlineVariant` | Card borders, dividers, input borders |
| `surfaceContainer*` | Soft fills, chips, banners |
| `navigationBarTheme.backgroundColor` | Bottom nav / comment bar chrome |

## Themes

- Switch via `ref.read(appVisualStyleProvider.notifier).setStyle(...)`.
- `MaterialApp` uses `AppTheme.of(visualStyle)` for both `theme` and `darkTheme`.
- Status bar: `AppBarTheme.systemOverlayStyle` + `AnnotatedRegion` in `main.dart`.

## Typography

- Family: **DM Sans** (`GoogleFonts.dmSansTextTheme` in `AppTheme`).
- Prefer `theme.textTheme` with weight tweaks (`w600`–`w800` for titles).
- Section headers often `titleSmall` + `onSurfaceVariant`.

## Icons

- Package: `lucide_icons_flutter`.
- Common: `heart`, `messageCircle`, `share2`, `bookmark`, `sparkles`, `mic`, `sun` / `moon` / `leaf` for themes.

## Spacing

```dart
const GutterTiny();   // ~4
const GutterSmall();  // ~8
const Gutter();       // default
const GutterLarge();
Gutter.custom(size: 12);
```

Horizontal page padding: `context.gutter` from `flutter_gutter`.

## Shared widgets to reuse

| Widget | Path | Use |
|--------|------|-----|
| `AppRootLayout` | `core/shared/widgets/app_root_layout.dart` | Scroll pages; `extendUnderAppBar` |
| `AppFrostedAppBar` | `app_frosted_app_bar.dart` | Opaque → frosted glass when scrolled |
| `AppCachedNetworkImage` / `AppCachedAvatar` | `app_cached_network_image.dart` | Media + avatars |
| `TextInputField` | `text_input_field.dart` | FormBuilder fields; style from theme |
| Profile cards | `features/profile/screens/profile_screen.dart` | `_ProfileCard`-style surfaces |
| Vendor card / chips / AI banner | `features/vendors/widgets/` | List + AI match pattern |
| Feed cards | `features/home/widgets/feed_post_card.dart` | Social engagement (absorb taps) |

## Card recipe

```dart
DecoratedBox(
  decoration: BoxDecoration(
    color: colors.surface,
    borderRadius: BorderRadius.circular(18),
    border: Border.all(color: colors.outline.withValues(alpha: 0.7)),
  ),
  child: ...,
);
```

## CTA recipes

- Primary: `FilledButton` / gold `FloatingActionButton` circle + `LucideIcons.mic`.
- Selected chip: gold fill + soft gold glow shadow; idle = muted text.
- Danger: red text/border on translucent red fill (see Log Out).

## Contrast checklist

- Never put white/light gray body text on light canvas.
- Video overlays: keep a readable scrim; theme-aware overlay text when fading to scaffold.
- Inputs: visible `outline` border; fill = scaffold or soft container, not invisible white-on-white.
