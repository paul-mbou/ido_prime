import 'package:material_ui/material_ui.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ido_prime/src/core/shared/widgets/app_frosted_app_bar.dart';
import 'package:ido_prime/src/core/shared/widgets/app_glass_dialog.dart';
import 'package:ido_prime/src/core/theme/app_colors.dart';
import 'package:ido_prime/src/features/profile/models/privacy_security_settings.dart';
import 'package:ido_prime/src/features/profile/providers/privacy_security_provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class PrivacySecurityScreen extends HookConsumerWidget {
  const PrivacySecurityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final settings = ref.watch(privacySecurityProvider);
    final notifier = ref.read(privacySecurityProvider.notifier);

    return Scaffold(
      appBar: AppFrostedAppBar(
        title: Text(
          'Privacy & Security',
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
          _SectionLabel(label: 'Security'),
          _SettingsCard(
            children: [
              _NavTile(
                icon: LucideIcons.lockKeyhole,
                label: 'Change password',
                subtitle: 'Update the password for your IDO account',
                onTap: () => _showChangePasswordSheet(context),
              ),
              _Divider(),
              _SwitchTile(
                icon: LucideIcons.shieldCheck,
                label: 'Two-factor authentication',
                subtitle: 'Extra step when signing in on a new device',
                value: settings.twoFactorEnabled,
                onChanged: notifier.setTwoFactorEnabled,
              ),
              _Divider(),
              _SwitchTile(
                icon: LucideIcons.fingerprint,
                label: 'App lock',
                subtitle: 'Require Face ID / PIN when opening IDO',
                value: settings.appLockEnabled,
                onChanged: notifier.setAppLockEnabled,
              ),
            ],
          ),
          const GutterLarge(),
          _SectionLabel(label: 'Privacy'),
          _SettingsCard(
            children: [
              _SwitchTile(
                icon: LucideIcons.eyeOff,
                label: 'Private profile',
                subtitle:
                    'Only people you approve can see your posts and celebrations',
                value: settings.privateProfile,
                onChanged: notifier.setPrivateProfile,
              ),
              _Divider(),
              _SwitchTile(
                icon: LucideIcons.activity,
                label: 'Show celebration activity',
                subtitle: 'Let others see events you join and boards you save',
                value: settings.showActivity,
                onChanged: notifier.setShowActivity,
              ),
              _Divider(),
              _SwitchTile(
                icon: LucideIcons.atSign,
                label: 'Allow tagging',
                subtitle: 'People can tag you in posts and inspiration looks',
                value: settings.allowTagging,
                onChanged: notifier.setAllowTagging,
              ),
              _Divider(),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          LucideIcons.messageCircle,
                          size: 22,
                          color: colors.onSurface,
                        ),
                        const GutterSmall(),
                        Expanded(
                          child: Text(
                            'Who can message you',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const GutterTiny(),
                    Padding(
                      padding: const EdgeInsets.only(left: 30),
                      child: Text(
                        'Vendor chats still require an event connection request. '
                        'Planner chat needs an accepted friend request.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const GutterSmall(),
                    Padding(
                      padding: const EdgeInsets.only(left: 30),
                      child: _WhoCanMessageChips(
                        selected: settings.whoCanMessage,
                        onChanged: notifier.setWhoCanMessage,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const GutterLarge(),
          _SectionLabel(label: 'Data & account'),
          _SettingsCard(
            children: [
              _NavTile(
                icon: LucideIcons.download,
                label: 'Download my data',
                subtitle: 'Request a copy of your posts, events, and profile',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'We’ll email a download link within 48 hours',
                      ),
                    ),
                  );
                },
              ),
              _Divider(),
              _NavTile(
                icon: LucideIcons.trash2,
                label: 'Delete account',
                subtitle: 'Permanently remove your IDO profile and content',
                destructive: true,
                onTap: () => _confirmDeleteAccount(context),
              ),
            ],
          ),
          const Gutter(),
          Text(
            'These controls stay on this device for now (mock). '
            'They’ll sync with your account when backend privacy ships.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
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
    this.destructive = false,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final accent = destructive ? AppColors.like : colors.onSurface;

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      leading: Icon(icon, color: accent, size: 22),
      title: Text(
        label,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w500,
          color: accent,
        ),
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

class _WhoCanMessageChips extends StatelessWidget {
  const _WhoCanMessageChips({required this.selected, required this.onChanged});

  final WhoCanMessage selected;
  final ValueChanged<WhoCanMessage> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final option in WhoCanMessage.values)
          _Chip(
            label: switch (option) {
              WhoCanMessage.everyone => 'Everyone',
              WhoCanMessage.friends => 'Friends',
              WhoCanMessage.nobody => 'Nobody',
            },
            selected: selected == option,
            onTap: () => onChanged(option),
          ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Material(
      color: selected ? AppColors.primary : colors.surfaceContainerHighest,
      shape: const StadiumBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: selected ? AppColors.onPrimary : colors.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> _showChangePasswordSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => const _ChangePasswordSheet(),
  );
}

class _ChangePasswordSheet extends HookWidget {
  const _ChangePasswordSheet();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final currentCtrl = useTextEditingController();
    final nextCtrl = useTextEditingController();
    final confirmCtrl = useTextEditingController();
    final obscure = useState(true);
    final saving = useState(false);
    final tick = useState(0);

    final canSave =
        currentCtrl.text.trim().length >= 6 &&
        nextCtrl.text.trim().length >= 6 &&
        nextCtrl.text.trim() == confirmCtrl.text.trim();

    Future<void> save() async {
      if (!canSave || saving.value) return;
      saving.value = true;
      await Future<void>.delayed(const Duration(milliseconds: 280));
      saving.value = false;
      if (!context.mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Password updated')));
    }

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Material(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              context.gutter,
              12,
              context.gutter,
              context.gutter,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colors.outline.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                const Gutter(),
                Text(
                  'Change password',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const GutterTiny(),
                Text(
                  'Use at least 6 characters. You’ll stay signed in on this device.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const Gutter(),
                TextField(
                  controller: currentCtrl,
                  obscureText: obscure.value,
                  onChanged: (_) => tick.value++,
                  decoration: InputDecoration(
                    labelText: 'Current password',
                    filled: true,
                    fillColor: colors.surfaceContainerHighest,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const GutterSmall(),
                TextField(
                  controller: nextCtrl,
                  obscureText: obscure.value,
                  onChanged: (_) => tick.value++,
                  decoration: InputDecoration(
                    labelText: 'New password',
                    filled: true,
                    fillColor: colors.surfaceContainerHighest,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const GutterSmall(),
                TextField(
                  controller: confirmCtrl,
                  obscureText: obscure.value,
                  onChanged: (_) => tick.value++,
                  decoration: InputDecoration(
                    labelText: 'Confirm new password',
                    filled: true,
                    fillColor: colors.surfaceContainerHighest,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: IconButton(
                      onPressed: () => obscure.value = !obscure.value,
                      icon: Icon(
                        obscure.value ? LucideIcons.eye : LucideIcons.eyeOff,
                      ),
                    ),
                  ),
                ),
                const Gutter(),
                FilledButton(
                  onPressed: canSave && !saving.value ? save : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    disabledBackgroundColor: colors.surfaceContainerHighest,
                    minimumSize: const Size.fromHeight(48),
                    shape: const StadiumBorder(),
                  ),
                  child: saving.value
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Update password'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> _confirmDeleteAccount(BuildContext context) async {
  final confirmed = await showAppGlassDialog<bool>(
    context: context,
    builder: (ctx) => AppGlassDialog(
      title: const Text('Delete account?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: Text(
            'Delete',
            style: TextStyle(
              color: AppColors.like,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
      child: Text(
        'This removes your profile, posts, and event plans from IDO. '
        'This can’t be undone.',
        style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
          color: Theme.of(ctx).colorScheme.onSurfaceVariant,
        ),
      ),
    ),
  );
  if (confirmed != true || !context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Account deletion isn’t available in this preview'),
    ),
  );
}
