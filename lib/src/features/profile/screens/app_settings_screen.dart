import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ido_prime/src/core/shared/widgets/app_cached_network_image.dart';
import 'package:ido_prime/src/core/shared/widgets/app_frosted_app_bar.dart';
import 'package:ido_prime/src/core/shared/widgets/app_glass_dialog.dart';
import 'package:ido_prime/src/core/theme/app_colors.dart';
import 'package:ido_prime/src/features/onboarding/providers/onboarding_provider.dart';
import 'package:ido_prime/src/features/profile/providers/app_settings_provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class AppSettingsScreen extends ConsumerWidget {
  const AppSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final settings = ref.watch(appSettingsProvider);
    final notifier = ref.read(appSettingsProvider.notifier);

    return Scaffold(
      appBar: AppFrostedAppBar(
        title: Text(
          'App Settings',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: EdgeInsets.fromLTRB(
          context.gutter,
          context.gutter,
          context.gutter,
          context.gutter * 2,
        ),
        children: [
          _SectionLabel(label: 'Media & feed'),
          _SettingsCard(
            children: [
              _SwitchTile(
                icon: LucideIcons.play,
                label: 'Autoplay videos',
                subtitle:
                    'Start muted video posts and reels as you scroll the feed',
                value: settings.autoplayVideos,
                onChanged: (value) async {
                  await notifier.setAutoplayVideos(value);
                  if (settings.hapticFeedback) {
                    HapticFeedback.selectionClick();
                  }
                },
              ),
              _Divider(),
              _SwitchTile(
                icon: LucideIcons.wifiOff,
                label: 'Reduce data usage',
                subtitle:
                    'Load lighter images and defer video until you tap play',
                value: settings.reduceDataUsage,
                onChanged: (value) async {
                  await notifier.setReduceDataUsage(value);
                  if (settings.hapticFeedback) {
                    HapticFeedback.selectionClick();
                  }
                },
              ),
            ],
          ),
          const GutterLarge(),
          _SectionLabel(label: 'Experience'),
          _SettingsCard(
            children: [
              _SwitchTile(
                icon: LucideIcons.vibrate,
                label: 'Haptic feedback',
                subtitle:
                    'Subtle vibration on likes, toggles, and primary taps',
                value: settings.hapticFeedback,
                onChanged: (value) async {
                  await notifier.setHapticFeedback(value);
                  if (value) HapticFeedback.selectionClick();
                },
              ),
            ],
          ),
          const GutterLarge(),
          _SectionLabel(label: 'Storage & help'),
          _SettingsCard(
            children: [
              _NavTile(
                icon: LucideIcons.trash2,
                label: 'Clear image cache',
                subtitle:
                    'Free space used by cached feed, avatar, and inspiration photos',
                onTap: () => _clearImageCache(context),
              ),
              _Divider(),
              _NavTile(
                icon: LucideIcons.sparkles,
                label: 'Replay product tour',
                subtitle:
                    'Show the Plan · Discover · Inspire · Share intro on next launch',
                onTap: () => _replayOnboarding(context, ref),
              ),
            ],
          ),
          const GutterLarge(),
          _SectionLabel(label: 'About'),
          _SettingsCard(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 4,
                ),
                leading: Icon(
                  LucideIcons.info,
                  color: colors.onSurface,
                  size: 22,
                ),
                title: Text(
                  'Version',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                trailing: Text(
                  'IDO v1.0.0',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const Gutter(),
          Text(
            'These controls stay on this device. Feed media behavior will '
            'respect them as playback and caching land.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _clearImageCache(BuildContext context) async {
    final confirmed = await showAppGlassDialog<bool>(
      context: context,
      builder: (ctx) => AppGlassDialog(
        title: const Text('Clear image cache?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Clear'),
          ),
        ],
        child: Text(
          'Cached photos will download again the next time you open the feed '
          'or inspiration.',
          style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
            color: Theme.of(ctx).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
    if (confirmed != true || !context.mounted) return;

    await AppImageCacheManager.instance.emptyCache();
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Image cache cleared')));
  }

  Future<void> _replayOnboarding(BuildContext context, WidgetRef ref) async {
    final confirmed = await showAppGlassDialog<bool>(
      context: context,
      builder: (ctx) => AppGlassDialog(
        title: const Text('Replay product tour?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Enable'),
          ),
        ],
        child: Text(
          'The next time you open IDO, you’ll see the first-run celebration '
          'tour again. You’ll stay signed in.',
          style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
            color: Theme.of(ctx).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
    if (confirmed != true || !context.mounted) return;

    await ref.read(onboardingControllerProvider).reset();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Product tour will show on next launch')),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        label,
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: colors.outline.withValues(alpha: 0.7)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      indent: 52,
      color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.55),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      leading: Icon(icon, color: colors.onSurface, size: 22),
      title: Text(
        label,
        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(
          color: colors.onSurfaceVariant,
        ),
      ),
      trailing: Icon(
        LucideIcons.chevronRight,
        size: 18,
        color: colors.onSurfaceVariant,
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  const _SwitchTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      leading: Icon(icon, color: colors.onSurface, size: 22),
      title: Text(
        label,
        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(
          color: colors.onSurfaceVariant,
        ),
      ),
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeThumbColor: AppColors.onPrimary,
        activeTrackColor: AppColors.primary,
      ),
    );
  }
}
