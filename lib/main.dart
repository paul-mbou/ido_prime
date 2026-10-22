import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ido_prime/src/core/routing/app_router.dart';
import 'package:ido_prime/src/core/shared/widgets/app_keyboard_dismiss.dart';
import 'package:ido_prime/src/core/theme/app_theme.dart';
import 'package:ido_prime/src/core/theme/theme_controllers.dart';
import 'package:material_ui/material_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Prefetch in parallel with Supabase; font failures must not block startup
  // (offline / DNS to fonts.gstatic.com → system fallback until cached).
  await Future.wait([
    _prefetchBrandFonts(),
    Supabase.initialize(
      url: 'https://iuqbxvokhqpsbonzxcbn.supabase.co',
      publishableKey: 'sb_publishable_P5hs1RIAoKQg7UVrSp1_Qg__sNkybUv',
    ),
  ]);

  runApp(const ProviderScope(child: MainApp()));
}

/// Best-effort DM Sans + Fraunces warm-up. Never throws.
Future<void> _prefetchBrandFonts() async {
  try {
    await GoogleFonts.pendingFonts([
      GoogleFonts.dmSans(),
      GoogleFonts.dmSans(fontWeight: FontWeight.w500),
      GoogleFonts.dmSans(fontWeight: FontWeight.w600),
      GoogleFonts.dmSans(fontWeight: FontWeight.w700),
      GoogleFonts.dmSans(fontWeight: FontWeight.w800),
      GoogleFonts.fraunces(fontWeight: FontWeight.w400),
      GoogleFonts.fraunces(
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.italic,
      ),
    ]);
  } catch (error, stack) {
    debugPrint('Brand font prefetch skipped: $error');
    debugPrint('$stack');
  }
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    final visualStyle = ref.watch(appVisualStyleProvider);
    final theme = AppTheme.of(visualStyle);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: theme,
      darkTheme: theme,
      themeMode: ThemeMode.light,
      routerConfig: router,
      builder: (context, child) {
        Widget content = child ?? const SizedBox.shrink();
        final overlay = Theme.of(context).appBarTheme.systemOverlayStyle;
        if (overlay != null) {
          content = AnnotatedRegion<SystemUiOverlayStyle>(
            value: overlay,
            child: content,
          );
        }
        // App-wide: tap empty space to hide the keyboard.
        return AppKeyboardDismiss(child: content);
      },
    );
  }
}
