import 'package:material_ui/material_ui.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ido_prime/src/core/routing/app_routes.dart';
import 'package:ido_prime/src/core/shared/widgets/app_cached_network_image.dart';
import 'package:ido_prime/src/core/shared/widgets/app_frosted_app_bar.dart';
import 'package:ido_prime/src/core/theme/app_colors.dart';
import 'package:ido_prime/src/core/theme/app_visual_style.dart';
import 'package:ido_prime/src/core/theme/theme_controllers.dart';
import 'package:ido_prime/src/features/auth/presentation/provider/auth_notifier.dart';
import 'package:ido_prime/src/features/profile/providers/user_account_provider.dart';
import 'package:ido_prime/src/features/vendor_onboarding/models/vendor_business.dart';
import 'package:ido_prime/src/features/vendor_onboarding/providers/vendor_onboarding_providers.dart';
import 'package:ido_prime/src/features/vendor_onboarding/utils/active_space_gate.dart';
import 'package:ido_prime/src/features/vendor_onboarding/widgets/vendor_onboarding_progress_banner.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final gutter = context.gutter;
    final style = ref.watch(appVisualStyleProvider);
    final space = ref.watch(activeSpaceProvider);
    final biz = ref.watch(vendorBusinessProvider);
    final account = ref.watch(userAccountProvider);

    return Scaffold(
      appBar: AppFrostedAppBar(
        title: Text(
          'Profile',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: CustomScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        slivers: [
          SliverPadding(
            padding: EdgeInsets.fromLTRB(gutter, gutter, gutter, gutter * 2),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _ProfileHeaderCard(
                  name: account.displayName,
                  email: account.email,
                  avatarUrl: account.avatarUrl,
                  events: 12,
                  vendors: 34,
                  saves: 89,
                ),
                const Gutter(),
                const VendorOnboardingProgressBanner(),
                const Gutter(),
                _SectionCard(
                  title: 'Active space',
                  footer:
                      'Actions are attributed to this space — Planner or Vendor.',
                  child: _SpaceSelector(
                    space: space,
                    vendorReady: biz.canOfferServices,
                    vendorName: biz.displayName.isEmpty
                        ? 'Vendor'
                        : biz.displayName,
                    onChanged: (value) async {
                      if (value == ActiveSpace.vendor &&
                          !biz.canOfferServices) {
                        context.push(AppRoutes.vendorOnboardingHub);
                        return;
                      }
                      await ref
                          .read(activeSpaceProvider.notifier)
                          .setSpace(value);
                    },
                  ),
                ),
                const Gutter(),
                _VendorEntryCard(
                  business: biz,
                  onTap: () {
                    if (!biz.canOfferServices) {
                      context.push(AppRoutes.vendorOnboardingHub);
                      return;
                    }
                    runInActiveSpace(
                      context,
                      ref,
                      requiredSpace: ActiveSpace.vendor,
                      actionLabel: 'manage your vendor profile',
                      message:
                          'Vendor tools live in Vendor space. '
                          'Switch to Vendor to edit your business profile.',
                      action: () => context.push(AppRoutes.vendorManageProfile),
                    );
                  },
                ),
                const Gutter(),
                _SettingsGroup(
                  title: 'Account',
                  items: [
                    _SettingsItemData(
                      icon: LucideIcons.user,
                      label: 'Edit Profile',
                      onTap: () => context.push(AppRoutes.editProfile),
                    ),
                    _SettingsItemData(
                      icon: LucideIcons.bell,
                      label: 'Notifications',
                      onTap: () => context.push(AppRoutes.notifications),
                    ),
                    _SettingsItemData(
                      icon: LucideIcons.shield,
                      label: 'Privacy & Security',
                      onTap: () => context.push(AppRoutes.privacySecurity),
                    ),
                  ],
                ),
                const Gutter(),
                _PreferencesGroup(
                  style: style,
                  onStyleChanged: (value) =>
                      ref.read(appVisualStyleProvider.notifier).setStyle(value),
                  onAppSettingsTap: () => context.push(AppRoutes.appSettings),
                ),
                const Gutter(),
                _SettingsGroup(
                  title: 'Support',
                  items: [
                    _SettingsItemData(
                      icon: LucideIcons.circleHelp,
                      label: 'Help Center',
                      onTap: () => context.push(AppRoutes.helpCenter),
                    ),
                  ],
                ),
                const GutterLarge(),
                _LogoutButton(
                  onPressed: () =>
                      ref.read(authNotifierProvider.notifier).logout(),
                ),
                const Gutter(),
                Text(
                  'IDO v1.0.0',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colors.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _SpaceSelector extends StatelessWidget {
  const _SpaceSelector({
    required this.space,
    required this.vendorReady,
    required this.vendorName,
    required this.onChanged,
  });

  final ActiveSpace space;
  final bool vendorReady;
  final String vendorName;
  final ValueChanged<ActiveSpace> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ModeChip(
          label: 'Planner',
          icon: LucideIcons.calendar,
          selected: space == ActiveSpace.planner,
          onTap: () => onChanged(ActiveSpace.planner),
        ),
        const Gutter(),
        _ModeChip(
          label: vendorReady ? vendorName : 'Vendor',
          icon: LucideIcons.store,
          selected: space == ActiveSpace.vendor,
          onTap: () => onChanged(ActiveSpace.vendor),
        ),
      ],
    );
  }
}

class _VendorEntryCard extends StatelessWidget {
  const _VendorEntryCard({required this.business, required this.onTap});

  final VendorBusiness business;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final title = !business.hasStarted
        ? 'Become a vendor'
        : business.canOfferServices
        ? 'Manage vendor profile'
        : 'Continue vendor setup';

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
                backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                child: Icon(LucideIcons.briefcase, color: colors.primary),
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
                      business.hasStarted
                          ? business.progressSubtitle
                          : 'Offer services after identity, pricing & KYC/KYB.',
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

class _ProfileHeaderCard extends StatelessWidget {
  const _ProfileHeaderCard({
    required this.name,
    required this.email,
    required this.avatarUrl,
    required this.events,
    required this.vendors,
    required this.saves,
  });

  final String name;
  final String email;
  final String avatarUrl;
  final int events;
  final int vendors;
  final int saves;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return _ProfileCard(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
        child: Column(
          children: [
            Row(
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 2),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(2),
                    child: AppCachedAvatar(imageUrl: avatarUrl, radius: 32),
                  ),
                ),
                const Gutter(),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const GutterTiny(),
                      Text(
                        email,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      const GutterSmall(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Pro Member',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Gutter(),
            Divider(color: colors.outline.withValues(alpha: 0.7), height: 1),
            const Gutter(),
            Row(
              children: [
                Expanded(
                  child: _StatCell(value: '$events', label: 'Events'),
                ),
                Expanded(
                  child: _StatCell(value: '$vendors', label: 'Vendors'),
                ),
                Expanded(
                  child: _StatCell(value: '$saves', label: 'Saves'),
                ),
              ],
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
          style: theme.textTheme.titleLarge?.copyWith(
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
  const _SectionCard({
    required this.title,
    required this.child,
    required this.footer,
  });

  final String title;
  final Widget child;
  final String footer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _ProfileCard(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Gutter(),
            child,
            const Gutter(),
            Text(
              footer,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  const _ModeChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedStyle = theme.textTheme.labelLarge?.copyWith(
      color: AppColors.onPrimary,
      fontWeight: FontWeight.w700,
    );
    final idleStyle = theme.textTheme.labelLarge?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
      fontWeight: FontWeight.w600,
    );

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    blurRadius: 16,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: selected
                    ? AppColors.onPrimary
                    : theme.colorScheme.onSurfaceVariant,
              ),
              const GutterTiny(),
            ],
            Text(label, style: selected ? selectedStyle : idleStyle),
          ],
        ),
      ),
    );
  }
}

class _PreferencesGroup extends StatelessWidget {
  const _PreferencesGroup({
    required this.style,
    required this.onStyleChanged,
    required this.onAppSettingsTap,
  });

  final AppVisualStyle style;
  final ValueChanged<AppVisualStyle> onStyleChanged;
  final VoidCallback onAppSettingsTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'Preferences',
            style: theme.textTheme.titleSmall?.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        _ProfileCard(
          child: Column(
            children: [
              const _SettingsTile(
                item: _SettingsItemData(
                  icon: LucideIcons.globe,
                  label: 'Language',
                  trailingLabel: 'English',
                ),
              ),
              Divider(
                height: 1,
                indent: 52,
                color: colors.outline.withValues(alpha: 0.55),
              ),
              _SettingsTile(
                item: _SettingsItemData(
                  icon: LucideIcons.settings,
                  label: 'App Settings',
                  onTap: onAppSettingsTap,
                ),
              ),
              Divider(
                height: 1,
                indent: 52,
                color: colors.outline.withValues(alpha: 0.55),
              ),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 14),
                leading: Icon(
                  LucideIcons.palette,
                  color: colors.onSurface,
                  size: 22,
                ),
                title: Text(
                  'Theme',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                trailing: _ThemeSegmented(
                  selected: style,
                  onChanged: onStyleChanged,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ThemeSegmented extends StatelessWidget {
  const _ThemeSegmented({required this.selected, required this.onChanged});

  final AppVisualStyle selected;
  final ValueChanged<AppVisualStyle> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ThemeSegChip(
              label: 'Light',
              icon: LucideIcons.sun,
              selected: selected == AppVisualStyle.light,
              onTap: () => onChanged(AppVisualStyle.light),
            ),
            _ThemeSegChip(
              label: 'Dark',
              icon: LucideIcons.moon,
              selected: selected == AppVisualStyle.dark,
              onTap: () => onChanged(AppVisualStyle.dark),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeSegChip extends StatelessWidget {
  const _ThemeSegChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Material(
      color: selected ? AppColors.primary : Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 14,
                color: selected ? AppColors.onPrimary : colors.onSurfaceVariant,
              ),
              const Gutter.custom(size: 4),
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: selected
                      ? AppColors.onPrimary
                      : colors.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.title, required this.items});

  final String title;
  final List<_SettingsItemData> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        _ProfileCard(
          child: Column(
            children: [
              for (var i = 0; i < items.length; i++) ...[
                _SettingsTile(item: items[i]),
                if (i < items.length - 1)
                  Divider(
                    height: 1,
                    indent: 52,
                    color: theme.colorScheme.outline.withValues(alpha: 0.55),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _SettingsItemData {
  const _SettingsItemData({
    required this.icon,
    required this.label,
    this.trailingLabel,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String? trailingLabel;
  final VoidCallback? onTap;
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({required this.item});

  final _SettingsItemData item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return ListTile(
      onTap: item.onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14),
      leading: Icon(item.icon, color: colors.onSurface, size: 22),
      title: Text(
        item.label,
        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (item.trailingLabel != null) ...[
            Text(
              item.trailingLabel!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const GutterSmall(),
          ],
          Icon(
            LucideIcons.chevronRight,
            size: 18,
            color: colors.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    const danger = Color(0xFFE25555);
    return Material(
      color: danger.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: danger.withValues(alpha: 0.45)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(LucideIcons.logOut, color: danger, size: 20),
              const GutterSmall(),
              Text(
                'Log Out',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: danger,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(18);
    // Material (not DecoratedBox) so ListTile ink / tileColor paint correctly.
    return Material(
      color: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(color: colors.outline.withValues(alpha: 0.7)),
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}
