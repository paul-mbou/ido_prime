import 'package:material_ui/material_ui.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ido_prime/src/core/routing/app_routes.dart';
import 'package:ido_prime/src/core/shared/widgets/app_frosted_app_bar.dart';
import 'package:ido_prime/src/core/theme/app_colors.dart';
import 'package:ido_prime/src/features/vendor_onboarding/models/vendor_business.dart';
import 'package:ido_prime/src/features/vendor_onboarding/providers/vendor_onboarding_providers.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class VendorOnboardingHubScreen extends ConsumerWidget {
  const VendorOnboardingHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final gutter = context.gutter;
    final biz = ref.watch(vendorBusinessProvider);
    final progress = biz.completedStepCount / 3;

    return Scaffold(
      appBar: AppFrostedAppBar(
        title: Text(
          'Vendor space',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: CustomScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        slivers: [
          SliverPadding(
            padding: EdgeInsets.fromLTRB(gutter, gutter, gutter, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
          Text(
            'Become a vendor',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const GutterTiny(),
          Text(
            'Complete the steps at your own pace. You can leave and come back — '
            'nothing is lost. Offering services goes live after IDO field verification.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          const Gutter(),
          DecoratedBox(
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: colors.outline.withValues(alpha: 0.7)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '${biz.completedStepCount}/3 steps',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _statusLabel(biz.status),
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const GutterSmall(),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress.clamp(0.0, 1.0),
                      minHeight: 8,
                      backgroundColor: colors.surfaceContainerHighest,
                      color: AppColors.primary,
                    ),
                  ),
                  const GutterSmall(),
                  Text(
                    biz.progressSubtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Gutter(),
          _StepTile(
            number: 1,
            title: 'Business identity',
            subtitle: 'Name, photo, availability, country',
            done: biz.step1Done,
            onTap: () => context.push(AppRoutes.vendorOnboardingStep1),
          ),
          const GutterSmall(),
          _StepTile(
            number: 2,
            title: 'Services & pricing',
            subtitle: 'Offers, prices, modalities',
            done: biz.step2Done,
            onTap: () => context.push(AppRoutes.vendorOnboardingStep2),
          ),
          const GutterSmall(),
          _StepTile(
            number: 3,
            title: 'KYC / KYB',
            subtitle: 'Identity & business documents',
            done: biz.step3Done,
            onTap: () => context.push(AppRoutes.vendorOnboardingStep3),
          ),
          if (biz.status == VendorBusinessStatus.pendingReview) ...[
            const GutterLarge(),
            Text(
              'Demo back-office',
              style: theme.textTheme.titleSmall?.copyWith(
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            const GutterSmall(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      await ref
                          .read(vendorBusinessProvider.notifier)
                          .stubReject();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Marked as needs info (demo)'),
                          ),
                        );
                      }
                    },
                    child: const Text('Request info'),
                  ),
                ),
                const GutterSmall(),
                Expanded(
                  child: FilledButton(
                    onPressed: () async {
                      await ref
                          .read(vendorBusinessProvider.notifier)
                          .stubApprove();
                      await ref
                          .read(activeSpaceProvider.notifier)
                          .setSpace(ActiveSpace.vendor);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Approved — vendor space unlocked'),
                          ),
                        );
                      }
                    },
                    child: const Text('Approve'),
                  ),
                ),
              ],
            ),
          ],
          if (biz.canOfferServices) ...[
            const GutterLarge(),
            FilledButton(
              onPressed: () => context.push(AppRoutes.vendorManageProfile),
              child: const Text('Manage vendor profile'),
            ),
            const GutterSmall(),
            OutlinedButton(
              onPressed: () async {
                await ref
                    .read(activeSpaceProvider.notifier)
                    .setSpace(ActiveSpace.vendor);
                if (context.mounted) context.pop();
              },
              child: const Text('Switch to Vendor space'),
            ),
          ],
              ]),
            ),
          ),
        ],
      ),
    );
  }

  String _statusLabel(VendorBusinessStatus status) => switch (status) {
    VendorBusinessStatus.draft => 'Draft',
    VendorBusinessStatus.pendingReview => 'In review',
    VendorBusinessStatus.approved => 'Approved',
    VendorBusinessStatus.rejected => 'Rejected',
    VendorBusinessStatus.needsInfo => 'Needs info',
  };
}

class _StepTile extends StatelessWidget {
  const _StepTile({
    required this.number,
    required this.title,
    required this.subtitle,
    required this.done,
    required this.onTap,
  });

  final int number;
  final String title;
  final String subtitle;
  final bool done;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: colors.outline.withValues(alpha: 0.7)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: done
                    ? AppColors.primary
                    : colors.surfaceContainerHighest,
                child: done
                    ? Icon(LucideIcons.check, color: colors.onPrimary, size: 20)
                    : Text(
                        '$number',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
              ),
              const Gutter(),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const GutterTiny(),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(LucideIcons.chevronRight, color: colors.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
