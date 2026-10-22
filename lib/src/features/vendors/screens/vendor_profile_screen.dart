import 'package:material_ui/material_ui.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ido_prime/src/core/routing/app_routes.dart';
import 'package:ido_prime/src/core/shared/widgets/app_cached_network_image.dart';
import 'package:ido_prime/src/core/shared/widgets/app_frosted_app_bar.dart';
import 'package:ido_prime/src/core/theme/app_colors.dart';
import 'package:ido_prime/src/features/social/providers/vendor_follow_provider.dart';
import 'package:ido_prime/src/features/vendor_onboarding/models/vendor_business.dart';
import 'package:ido_prime/src/features/vendor_onboarding/utils/active_space_gate.dart';
import 'package:ido_prime/src/features/vendors/models/vendor.dart';
import 'package:ido_prime/src/features/vendors/providers/vendor_connection_provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class VendorProfileScreen extends HookConsumerWidget {
  const VendorProfileScreen({super.key, required this.vendorId});

  final String vendorId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vendor = findVendorById(vendorId);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final gutter = context.gutter;
    final frosted = useState(false);
    final favorited = useState(vendor?.isFavorite ?? false);
    final following = ref.watch(vendorFollowProvider).contains(vendorId);

    if (vendor == null) {
      return Scaffold(
        appBar: const AppFrostedAppBar(title: Text('Vendor')),
        body: Center(
          child: Text(
            'Vendor not found',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    final appBarExtent = MediaQuery.paddingOf(context).top + kToolbarHeight - 4;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppFrostedAppBar(
        frosted: frosted.value,
        title: Text(
          'Vendor',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          AppCircleIconButton(
            icon: LucideIcons.heart,
            color: favorited.value ? AppColors.like : null,
            fill: favorited.value ? 1 : 0,
            onPressed: () => favorited.value = !favorited.value,
          ),
          const GutterSmall(),
        ],
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          final next = notification.metrics.pixels > 2;
          if (next != frosted.value) frosted.value = next;
          return false;
        },
        child: Column(
          children: [
            Expanded(
              child: CustomScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                slivers: [
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      gutter,
                      appBarExtent + gutter,
                      gutter,
                      gutter,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _HeroImage(vendor: vendor),
                        const Gutter(),
                        _IdentityBlock(vendor: vendor),
                        const Gutter(),
                        _StatsRow(vendor: vendor),
                        const Gutter(),
                        _SectionCard(
                          title: 'About',
                          child: Text(
                            vendor.bio.isEmpty
                                ? 'No description yet.'
                                : vendor.bio,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              height: 1.45,
                            ),
                          ),
                        ),
                        if (vendor.services.isNotEmpty) ...[
                          const Gutter(),
                          _SectionCard(
                            title: 'Services',
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                for (final service in vendor.services)
                                  _ServiceChip(label: service),
                              ],
                            ),
                          ),
                        ],
                        if (vendor.galleryUrls.isNotEmpty) ...[
                          const Gutter(),
                          Text(
                            'Gallery',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: colors.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const GutterSmall(),
                          SizedBox(
                            height: 120,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: vendor.galleryUrls.length,
                              separatorBuilder: (_, _) => const GutterSmall(),
                              itemBuilder: (context, index) {
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: SizedBox(
                                    width: 160,
                                    height: 120,
                                    child: AppCachedNetworkImage(
                                      imageUrl: vendor.galleryUrls[index],
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                        const Gutter(),
                        _SectionCard(
                          title: 'Details',
                          child: Column(
                            children: [
                              _DetailRow(
                                icon: LucideIcons.mapPin,
                                label: 'Location',
                                value: vendor.location,
                              ),
                              const GutterSmall(),
                              _DetailRow(
                                icon: LucideIcons.clock3,
                                label: 'Response',
                                value: vendor.responseTime,
                              ),
                              const GutterSmall(),
                              _DetailRow(
                                icon: LucideIcons.badgeCheck,
                                label: 'Experience',
                                value: vendor.yearsExperience > 0
                                    ? '${vendor.yearsExperience}+ years'
                                    : '—',
                              ),
                              const GutterSmall(),
                              _DetailRow(
                                icon: LucideIcons.wallet,
                                label: 'Price level',
                                value: '\$' * vendor.priceLevel.clamp(1, 4),
                              ),
                            ],
                          ),
                        ),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
            Material(
              color: theme.navigationBarTheme.backgroundColor ?? colors.surface,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(gutter, 10, gutter, 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => ref
                              .read(vendorFollowProvider.notifier)
                              .toggle(vendor.id),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(0, 52),
                            foregroundColor: following
                                ? colors.onSurface
                                : AppColors.primary,
                            side: BorderSide(
                              color: following
                                  ? colors.outline
                                  : AppColors.primary.withValues(alpha: 0.7),
                            ),
                            shape: const StadiumBorder(),
                          ),
                          child: Text(following ? 'Following' : 'Follow'),
                        ),
                      ),
                      const GutterSmall(),
                      Expanded(
                        flex: 2,
                        child: FilledButton(
                          onPressed: () {
                            runInActiveSpace(
                              context,
                              ref,
                              requiredSpace: ActiveSpace.planner,
                              actionLabel: 'contact a vendor',
                              message:
                                  'Vendor accounts can’t contact other vendors. '
                                  'Switch to Planner to send an event request.',
                              action: () {
                                final status = ref
                                    .read(vendorConnectionProvider(vendor.id))
                                    ?.status;
                                if (status == VendorConnectionStatus.accepted) {
                                  context.push(AppRoutes.vendorChat(vendor.id));
                                } else {
                                  context.push(
                                    AppRoutes.vendorContact(vendor.id),
                                  );
                                }
                              },
                            );
                          },
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(0, 52),
                            shape: const StadiumBorder(),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(LucideIcons.send, size: 18),
                              GutterTiny(),
                              Text('Contact for event'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroImage extends StatelessWidget {
  const _HeroImage({required this.vendor});

  final Vendor vendor;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return AspectRatio(
      aspectRatio: 16 / 11,
      child: Stack(
        fit: StackFit.expand,
        children: [
          AppCachedNetworkImage(
            imageUrl: vendor.imageUrl,
            borderRadius: BorderRadius.circular(20),
            fit: BoxFit.cover,
            errorWidget: ColoredBox(
              color: colors.surfaceContainerHighest,
              child: Icon(LucideIcons.imageOff, color: colors.onSurfaceVariant),
            ),
          ),
          if (vendor.isAiMatch)
            Positioned(
              top: 14,
              left: 14,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        LucideIcons.sparkles,
                        size: 13,
                        color: colors.onPrimary,
                      ),
                      const Gutter.custom(size: 4),
                      Text(
                        'AI Match',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: colors.onPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _IdentityBlock extends StatelessWidget {
  const _IdentityBlock({required this.vendor});

  final Vendor vendor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      vendor.name,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  if (vendor.isVerified) ...[
                    const GutterTiny(),
                    Icon(
                      LucideIcons.badgeCheck,
                      size: 22,
                      color: colors.primary,
                    ),
                  ],
                ],
              ),
            ),
            const GutterSmall(),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  LucideIcons.star,
                  size: 16,
                  color: colors.primary,
                  fill: 1,
                ),
                const Gutter.custom(size: 4),
                Text(
                  vendor.rating.toStringAsFixed(1),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  ' (${vendor.reviewCount})',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
        const GutterTiny(),
        Text(
          vendor.category,
          style: theme.textTheme.titleSmall?.copyWith(
            color: colors.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        const GutterTiny(),
        Row(
          children: [
            Icon(LucideIcons.mapPin, size: 15, color: colors.onSurfaceVariant),
            const Gutter.custom(size: 4),
            Text(
              vendor.location,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.vendor});

  final Vendor vendor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.7),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: _StatCell(
                value: '${vendor.reviewCount}',
                label: 'Reviews',
              ),
            ),
            Expanded(
              child: _StatCell(
                value: vendor.yearsExperience > 0
                    ? '${vendor.yearsExperience}y'
                    : '—',
                label: 'Experience',
              ),
            ),
            Expanded(
              child: _StatCell(
                value: '\$' * vendor.priceLevel.clamp(1, 4),
                label: 'Price',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const GutterTiny(),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.outline.withValues(alpha: 0.7)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            const GutterSmall(),
            child,
          ],
        ),
      ),
    );
  }
}

class _ServiceChip extends StatelessWidget {
  const _ServiceChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.outline.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: colors.onSurface,
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Row(
      children: [
        Icon(icon, size: 18, color: colors.onSurfaceVariant),
        const GutterSmall(),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
