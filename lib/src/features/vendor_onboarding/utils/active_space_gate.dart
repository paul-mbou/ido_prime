import 'package:material_ui/material_ui.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ido_prime/src/core/routing/app_routes.dart';
import 'package:ido_prime/src/core/theme/app_colors.dart';
import 'package:ido_prime/src/features/vendor_onboarding/models/vendor_business.dart';
import 'package:ido_prime/src/features/vendor_onboarding/providers/vendor_onboarding_providers.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Ensures [requiredSpace] is active before a gated action.
///
/// If the user is in another space, proposes a switch. When Vendor space is
/// required but not unlocked, routes to onboarding instead.
Future<bool> ensureActiveSpace(
  BuildContext context,
  WidgetRef ref, {
  required ActiveSpace requiredSpace,
  required String actionLabel,
  String? message,
}) async {
  final current = ref.read(activeSpaceProvider);
  if (current == requiredSpace) return true;

  final biz = ref.read(vendorBusinessProvider);

  if (requiredSpace == ActiveSpace.vendor && !biz.canOfferServices) {
    final goSetup = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => _SpaceGateSheet(
        icon: LucideIcons.briefcase,
        title: 'Vendor space required',
        body:
            message ??
            'Finish your vendor profile and get approved to $actionLabel.',
        primaryLabel: 'Continue setup',
        secondaryLabel: 'Not now',
      ),
    );
    if (goSetup == true && context.mounted) {
      await context.push(AppRoutes.vendorOnboardingHub);
    }
    return false;
  }

  final targetLabel = requiredSpace == ActiveSpace.planner
      ? 'Planner'
      : 'Vendor';
  final currentLabel = current == ActiveSpace.planner ? 'Planner' : 'Vendor';

  final confirmed = await showModalBottomSheet<bool>(
    context: context,
    showDragHandle: true,
    builder: (ctx) => _SpaceGateSheet(
      icon: requiredSpace == ActiveSpace.planner
          ? LucideIcons.calendar
          : LucideIcons.store,
      title: 'Switch to $targetLabel?',
      body:
          message ??
          'You’re in $currentLabel space. Switch to $targetLabel to $actionLabel.',
      primaryLabel: 'Switch to $targetLabel',
      secondaryLabel: 'Cancel',
    ),
  );

  if (confirmed != true) return false;
  await ref.read(activeSpaceProvider.notifier).setSpace(requiredSpace);
  return true;
}

/// Runs [action] only after [requiredSpace] is active (or user switches).
Future<void> runInActiveSpace(
  BuildContext context,
  WidgetRef ref, {
  required ActiveSpace requiredSpace,
  required String actionLabel,
  String? message,
  required VoidCallback action,
}) async {
  final ok = await ensureActiveSpace(
    context,
    ref,
    requiredSpace: requiredSpace,
    actionLabel: actionLabel,
    message: message,
  );
  if (ok && context.mounted) action();
}

class _SpaceGateSheet extends StatelessWidget {
  const _SpaceGateSheet({
    required this.icon,
    required this.title,
    required this.body,
    required this.primaryLabel,
    required this.secondaryLabel,
  });

  final IconData icon;
  final String title;
  final String body;
  final String primaryLabel;
  final String secondaryLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final gutter = context.gutter;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(gutter, 0, gutter, gutter),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                  child: Icon(icon, color: colors.primary),
                ),
                const Gutter(),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const Gutter(),
            Text(
              body,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colors.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const GutterLarge(),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(primaryLabel),
            ),
            const GutterSmall(),
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(secondaryLabel),
            ),
          ],
        ),
      ),
    );
  }
}
