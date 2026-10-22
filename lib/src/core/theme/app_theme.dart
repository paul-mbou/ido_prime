import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ido_prime/src/core/theme/app_colors.dart';
import 'package:ido_prime/src/core/theme/app_visual_style.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';

class AppTheme {
  AppTheme._();

  static ThemeData of(AppVisualStyle style) => switch (style) {
    AppVisualStyle.light => light,
    AppVisualStyle.dark => dark,
  };

  /// Purple brand canvas + gold accent.
  static ThemeData get dark => _build(
    brightness: Brightness.dark,
    colorScheme: _darkColorScheme,
    background: AppColors.darkBackground,
    surfaceHigh: AppColors.surfaceHigh,
    muted: AppColors.muted,
    bottomNav: AppColors.bottomNav,
  );

  static ThemeData get light => _build(
    brightness: Brightness.light,
    colorScheme: _lightColorScheme,
    background: AppColors.lightBackground,
    surfaceHigh: AppColors.lightSurfaceHigh,
    muted: AppColors.lightMuted,
    bottomNav: AppColors.lightBottomNav,
  );

  /// Deep purple canvas + gold accent — explicit tokens (no seed drift).
  static const ColorScheme _darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.primary,
    onPrimary: AppColors.onPrimary,
    primaryContainer: AppColors.darkPrimaryContainer,
    onPrimaryContainer: AppColors.primary,
    secondary: AppColors.darkSecondary,
    onSecondary: AppColors.darkBackground,
    secondaryContainer: AppColors.darkSecondaryContainer,
    onSecondaryContainer: Color(0xFFE4DDF2),
    tertiary: AppColors.primary,
    onTertiary: AppColors.onPrimary,
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF690005),
    surface: AppColors.surface,
    onSurface: Colors.white,
    onSurfaceVariant: AppColors.muted,
    outline: AppColors.outline,
    outlineVariant: Color(0xFF4A4260),
    shadow: Colors.black,
    scrim: Colors.black,
    inverseSurface: AppColors.lightSurface,
    onInverseSurface: AppColors.lightOnSurface,
    inversePrimary: Color(0xFF6B5B20),
    surfaceContainerLowest: AppColors.bottomNav,
    surfaceContainerLow: AppColors.darkBackground,
    surfaceContainer: AppColors.surfaceHigh,
    surfaceContainerHigh: AppColors.surface,
    surfaceContainerHighest: Color(0xFF2E2445),
  );

  /// Soft lavender light theme — same hue family as dark, gentle to read.
  static const ColorScheme _lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primary,
    onPrimary: AppColors.onPrimary,
    primaryContainer: AppColors.lightPrimaryContainer,
    onPrimaryContainer: AppColors.lightOnPrimaryContainer,
    secondary: AppColors.lightSecondary,
    onSecondary: Colors.white,
    secondaryContainer: AppColors.lightSecondaryContainer,
    onSecondaryContainer: AppColors.lightOnSecondaryContainer,
    tertiary: Color(0xFF8A7340),
    onTertiary: Colors.white,
    error: Color(0xFFB3261E),
    onError: Colors.white,
    surface: AppColors.lightSurface,
    onSurface: AppColors.lightOnSurface,
    onSurfaceVariant: AppColors.lightMuted,
    outline: AppColors.lightOutline,
    outlineVariant: AppColors.lightOutlineVariant,
    shadow: AppColors.lightOnSurface,
    scrim: AppColors.lightOnSurface,
    inverseSurface: AppColors.darkBackground,
    onInverseSurface: Colors.white,
    inversePrimary: AppColors.primary,
    surfaceContainerLowest: AppColors.lightBackground,
    surfaceContainerLow: AppColors.lightSurfaceLow,
    surfaceContainer: AppColors.lightSurfaceHigh,
    surfaceContainerHigh: AppColors.lightSurfaceHighest,
    surfaceContainerHighest: Color(0xFFDED7EB),
  );

  static ThemeData _build({
    required Brightness brightness,
    required ColorScheme colorScheme,
    required Color background,
    required Color surfaceHigh,
    required Color muted,
    required Color bottomNav,
  }) {
    final onSurface = colorScheme.onSurface;
    final surface = colorScheme.surface;
    final outline = colorScheme.outline;

    final textTheme = GoogleFonts.dmSansTextTheme(
      ThemeData(brightness: brightness).textTheme,
    ).apply(bodyColor: onSurface, displayColor: onSurface);

    final overlayStyle = brightness == Brightness.light
        ? SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
            systemNavigationBarColor: bottomNav,
            systemNavigationBarIconBrightness: Brightness.dark,
          )
        : SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.dark,
            systemNavigationBarColor: bottomNav,
            systemNavigationBarIconBrightness: Brightness.light,
          );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: overlayStyle,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: onSurface,
          fontWeight: FontWeight.bold,
        ),
      ),
      actionIconTheme: ActionIconThemeData(
        backButtonIconBuilder: (BuildContext context) => CircleAvatar(
          backgroundColor: surface,
          child: Icon(LucideIcons.arrowLeft, color: onSurface),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceHigh,
        visualDensity: VisualDensity.compact,
        hintStyle: textTheme.bodyMedium?.copyWith(color: muted),
        prefixIconColor: muted,
        suffixIconColor: muted,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: outline),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.primary),
          borderRadius: BorderRadius.circular(12),
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: outline),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          textStyle: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
          minimumSize: const Size(double.infinity, 48),
          shape: const StadiumBorder(),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: onSurface,
          backgroundColor: surface,
          textStyle: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
          minimumSize: const Size(double.infinity, 48),
          side: BorderSide(color: outline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: brightness == Brightness.light
              ? AppColors.lightSecondary
              : AppColors.primary,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: surface,
          foregroundColor: onSurface,
          elevation: 0,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: outline),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: outline.withValues(alpha: 0.6)),
        ),
      ),
      chipTheme: ChipThemeData(
        showCheckmark: false,
        selectedColor: AppColors.primary.withValues(alpha: 0.22),
        checkmarkColor: Colors.transparent,
        labelStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        secondaryLabelStyle: textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        side: BorderSide(color: outline.withValues(alpha: 0.7)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: bottomNav,
        indicatorColor: AppColors.primary.withValues(
          alpha: brightness == Brightness.light ? 0.18 : 0.15,
        ),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return textTheme.labelSmall?.copyWith(
            color: selected ? AppColors.primary : muted,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? AppColors.primary : muted,
            size: 28,
            weight: selected ? 700 : 400,
            fill: selected ? 1 : 0,
          );
        }),
      ),
    );
  }
}
