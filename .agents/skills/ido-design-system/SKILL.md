---
name: ido-design-system
description: >-
  Source-of-truth design system for the IDO Prime Flutter app (events, vendors,
  inspiration, social posts, AI event co-pilot). Use when designing, prototyping,
  implementing, or reviewing any UI/UX for ido_prime — screens, components,
  chat, empty states, themes, HTML prototypes, or Figma-to-code. Wins over
  generic UI skills on brand, product purpose, colors, type, and icons.
---

# IDO Design System

**This skill is the source of truth for ido_prime UI.** When other design skills
(`ui-ux-pro-max`, `ui-design-brain`, `frontend-design`, Figma Make) conflict on
brand, palette, typography, icons, or product flows — **IDO wins**. Those skills
may advise layout craft, accessibility, and interaction states only.

## When to use

Apply automatically for any request that:

- Implements or redesigns a screen (feed, events, vendors, profile, AI chat, auth…)
- Prototypes UI (HTML/CSS/JS or Flutter)
- Adds components, empty states, sheets, composers, cards
- Mentions theme (Light / Dark), glassmorphism, or brand look

## Before writing UI

1. Read [references/product-purpose.md](references/product-purpose.md) — product north star.
2. Read [references/tokens-and-patterns.md](references/tokens-and-patterns.md) — tokens + code patterns.
3. Skim [references/screen-recipes.md](references/screen-recipes.md) for matching recipes.
4. Optionally consult `ui-ux-pro-max` / `ui-design-brain` for a11y and structure — then map output onto IDO tokens.

## Hard rules

1. **Product first** — every screen must serve planning, celebrating, discovering vendors, sharing moments, or AI co-planning for events.
2. **Theme tokens only** — use `Theme.of(context).colorScheme` / `scaffoldBackgroundColor` / `AppColors` / `AppTheme`. No hardcoded `Colors.white` for body text; no dark-only fills in light theme.
3. **Typography** — DM Sans via `AppTheme` / `textTheme`. Do not introduce Inter, Roboto, or new font families.
4. **Icons** — `lucide_icons_flutter` only (except rare brand logos like Apple/Facebook if already used).
5. **Spacing** — `flutter_gutter` for gaps (`GutterTiny`…`GutterExtraLarge`, `Gutter.custom`). Never `SizedBox` for spacing.
6. **Accent** — gold `#D3AF35` (`AppColors.primary`) for CTAs, selected states, FAB, AI sparkles. Do not invent a second accent.
7. **Surfaces** — rounded cards ~14–18px, subtle `outline` border, surface on scaffold. Match profile / vendors cards.
8. **Shell** — bottom nav (Feed · Events · Vendors · Inspiration); shared app bar (avatar → Profile, contextual search, notifications); gold **+** FAB on Posts (create post) and Events (plan event). Pad scroll content for FAB (~100 bottom) on those tabs.
9. **Themes** — Light and Dark (purple) via `AppVisualStyle` / `appVisualStyleProvider`. Default: Dark. Status bar icons must stay visible in each.
10. **Anti-slop** — no generic purple-on-white SaaS, no pill-stat hero strips, no emoji decoration, no dashboard clutter on first viewport of a focused flow.

## Workflow

### A. User wants a prototype

1. Prefer a single mobile HTML file (~390px) with CSS variables mapped 1:1 to `AppColors`.
2. One composition, brand-forward, one primary CTA.
3. After approval, port to Flutter using existing widgets.

### B. User wants implementation

1. Place under `lib/src/features/<feature>/`.
2. Wire `go_router` / shell branch if it’s a tab or route.
3. Reuse: `AppRootLayout`, `AppFrostedAppBar`, `AppCachedNetworkImage` / `AppCachedAvatar`, `TextInputField`, profile `_ProfileCard` patterns.
4. Riverpod / hooks as in neighboring features.
5. Keyboard-safe composers (column + `resizeToAvoidBottomInset`, same idea as post comment bar).

### C. After shipping a new pattern

Append a short note to `references/screen-recipes.md` so the system grows.

## Stack companions (defer to IDO on brand)

| Skill | Use for |
|-------|---------|
| `ui-ux-pro-max` | UX guidelines search, Flutter stack tips, a11y checklists |
| `ui-design-brain` | Component anatomy (chat, sheets, lists) — restyle to IDO |
| `frontend-design` | Distinctiveness / anti-template — within IDO aesthetic |
| Figma MCP | When a Figma/Make frame URL is provided |

## Quick token reminder

| Role | Dark (purple) | Light |
|------|---------------|-------|
| Canvas | `#1A0F2F` | `#F4F1F9` |
| Surface | `#241939` | `#FFFFFF` |
| Muted text | `#89809C` | `#6E6682` |
| Primary | `#D3AF35` gold (all themes) | |
| On primary | `#1A0F2F` | |

Source files: `lib/src/core/theme/app_colors.dart`, `app_theme.dart`, `app_visual_style.dart`, `theme_controllers.dart`.
