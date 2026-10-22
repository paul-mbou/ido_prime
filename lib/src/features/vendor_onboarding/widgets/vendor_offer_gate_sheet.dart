import 'package:material_ui/material_ui.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:go_router/go_router.dart';
import 'package:ido_prime/src/core/routing/app_routes.dart';
import 'package:ido_prime/src/core/theme/app_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Shown when a vendor-only action is blocked until onboarding + BO approval.
Future<void> showVendorOfferGateSheet(
  BuildContext context, {
  required String message,
}) {
  final theme = Theme.of(context);
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: theme.colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      return Padding(
        padding: EdgeInsets.fromLTRB(
          ctx.gutter,
          20,
          ctx.gutter,
          20 + MediaQuery.paddingOf(ctx).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(LucideIcons.lock, color: theme.colorScheme.primary),
            const Gutter(),
            Text(
              'Vendor profile incomplete',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const GutterSmall(),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const Gutter(),
            FilledButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                context.push(AppRoutes.vendorOnboardingHub);
              },
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
              ),
              child: const Text('Continue setup'),
            ),
          ],
        ),
      );
    },
  );
}
