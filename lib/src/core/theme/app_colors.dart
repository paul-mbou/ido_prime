import 'dart:ui';

class AppColors {
  AppColors._();

  /// Brand accent (gold) — shared across themes.
  static const Color primary = Color(0xFFD3AF35);

  /// Text on gold buttons — deep brand purple (same hue as [darkBackground]).
  static const Color onPrimary = Color(0xFF1A0F2F);

  // ── Dark ─────────────────────────────────────────────────────────────────
  /// Scaffold / page background.
  static const Color darkBackground = Color(0xFF1A0F2F);

  /// Inputs, social buttons, elevated surfaces.
  static const Color surface = Color(0xFF241939);

  /// Slightly deeper fill for focused / filled fields.
  static const Color surfaceHigh = Color(0xFF1F1435);

  /// Borders on dark surfaces.
  static const Color outline = Color(0xFF3A3150);

  /// Secondary / hint / label text.
  static const Color muted = Color(0xFF89809C);

  /// Bottom nav bar — intentionally near-black (not scaffold purple).
  static const Color bottomNav = Color(0xFF0B081B);

  /// Soft gold wash behind primary accents.
  static const Color darkPrimaryContainer = Color(0xFF3D3420);

  /// Like / heart accent (kept separate from brand gold).
  static const Color like = Color(0xFFE25555);

  static const Color likeSoft = Color(0x33E25555);

  /// Muted purple secondary (same family as background).
  static const Color darkSecondary = Color(0xFF9B8FB8);

  static const Color darkSecondaryContainer = Color(0xFF2E2445);

  // ── Light (same purple–gold hue family, soft & readable) ─────────────────
  /// Page canvas — airy lavender mist (hue of [darkBackground], low chroma).
  static const Color lightBackground = Color(0xFFF4F1F9);

  /// Cards / elevated panels — clean white for calm contrast.
  static const Color lightSurface = Color(0xFFFFFFFF);

  /// Subtle step above background (sheets, soft panels).
  static const Color lightSurfaceLow = Color(0xFFFAF8FC);

  /// Input fills & pressed surfaces — gentle lavender.
  static const Color lightSurfaceHigh = Color(0xFFEEE9F5);

  /// Stronger container for chips / selected rows.
  static const Color lightSurfaceHighest = Color(0xFFE5DFEF);

  /// Borders — soft purple-gray, never harsh.
  static const Color lightOutline = Color(0xFFD2CBE0);

  /// Hairline dividers / quiet separators.
  static const Color lightOutlineVariant = Color(0xFFE6E1EF);

  /// Secondary text — muted lavender-gray, AA-friendly on [lightBackground].
  static const Color lightMuted = Color(0xFF6E6682);

  /// Primary body / title text — brand purple (matches dark canvas hue).
  static const Color lightOnSurface = Color(0xFF1A0F2F);

  /// Slightly softer body copy when full purple feels heavy.
  static const Color lightOnSurfaceSoft = Color(0xFF3A3250);

  /// Bottom nav — white with the same family as the canvas.
  static const Color lightBottomNav = Color(0xFFFFFFFF);

  /// Soft gold wash for primary containers / selection.
  static const Color lightPrimaryContainer = Color(0xFFF5EDD0);

  /// Text on [lightPrimaryContainer].
  static const Color lightOnPrimaryContainer = Color(0xFF3D3010);

  /// Secondary accent — gentle mid purple (light counterpart of dark purple).
  static const Color lightSecondary = Color(0xFF5C4D7A);

  static const Color lightSecondaryContainer = Color(0xFFE9E3F2);

  static const Color lightOnSecondaryContainer = Color(0xFF2A2140);
}
