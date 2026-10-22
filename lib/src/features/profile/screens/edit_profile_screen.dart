import 'package:material_ui/material_ui.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ido_prime/src/core/shared/widgets/app_cached_network_image.dart';
import 'package:ido_prime/src/core/shared/widgets/app_frosted_app_bar.dart';
import 'package:ido_prime/src/core/theme/app_colors.dart';
import 'package:ido_prime/src/features/profile/providers/user_account_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class EditProfileScreen extends HookConsumerWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final account = ref.watch(userAccountProvider);

    final nameCtrl = useTextEditingController(text: account.displayName);
    final emailCtrl = useTextEditingController(text: account.email);
    final phoneCtrl = useTextEditingController(text: account.phone);
    final locationCtrl = useTextEditingController(text: account.location);
    final roleCtrl = useTextEditingController(text: account.role);
    final bioCtrl = useTextEditingController(text: account.bio);
    final avatarUrl = useState(account.avatarUrl);
    final saving = useState(false);
    final picking = useState(false);

    useEffect(() {
      nameCtrl.text = account.displayName;
      emailCtrl.text = account.email;
      phoneCtrl.text = account.phone;
      locationCtrl.text = account.location;
      roleCtrl.text = account.role;
      bioCtrl.text = account.bio;
      avatarUrl.value = account.avatarUrl;
      return null;
    }, [account.id]);

    Future<void> pickAvatar() async {
      if (picking.value) return;
      picking.value = true;
      try {
        final file = await ImagePicker().pickImage(
          source: ImageSource.gallery,
          maxWidth: 1200,
          imageQuality: 85,
        );
        if (file != null) {
          avatarUrl.value = file.path;
        }
      } catch (_) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Could not pick image')));
        }
      } finally {
        picking.value = false;
      }
    }

    Future<void> save() async {
      final name = nameCtrl.text.trim();
      final email = emailCtrl.text.trim();
      if (name.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Add your display name')));
        return;
      }
      if (email.isEmpty || !email.contains('@')) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Enter a valid email')));
        return;
      }

      saving.value = true;
      await Future<void>.delayed(const Duration(milliseconds: 280));
      ref
          .read(userAccountProvider.notifier)
          .updateProfile(
            displayName: name,
            email: email,
            avatarUrl: avatarUrl.value,
            phone: phoneCtrl.text,
            location: locationCtrl.text,
            bio: bioCtrl.text,
            role: roleCtrl.text,
          );
      saving.value = false;
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profile updated')));
      context.pop();
    }

    return Scaffold(
      appBar: AppFrostedAppBar(
        title: Text(
          'Edit profile',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          TextButton(
            onPressed: saving.value ? null : save,
            child: Text(
              'Save',
              style: theme.textTheme.titleSmall?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(context.gutter, 8, context.gutter, 8),
          child: FilledButton(
            onPressed: saving.value ? null : save,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
              minimumSize: const Size.fromHeight(48),
              shape: const StadiumBorder(),
            ),
            child: saving.value
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save changes'),
          ),
        ),
      ),
      body: ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: EdgeInsets.fromLTRB(
          context.gutter,
          context.gutter,
          context.gutter,
          24,
        ),
        children: [
          Center(
            child: Column(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [AppColors.primary, Color(0xFF9B8FB8)],
                        ),
                      ),
                      child: AppCachedAvatar(
                        imageUrl: avatarUrl.value,
                        radius: 52,
                        fallbackName: nameCtrl.text,
                      ),
                    ),
                    Positioned(
                      right: -2,
                      bottom: -2,
                      child: Material(
                        color: AppColors.primary,
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: picking.value ? null : pickAvatar,
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: picking.value
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.onPrimary,
                                    ),
                                  )
                                : const Icon(
                                    LucideIcons.camera,
                                    size: 18,
                                    color: AppColors.onPrimary,
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const GutterSmall(),
                TextButton(
                  onPressed: picking.value ? null : pickAvatar,
                  child: Text(
                    'Change photo',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const GutterLarge(),
          Text(
            'PUBLIC PROFILE',
            style: theme.textTheme.labelSmall?.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.6,
            ),
          ),
          const GutterSmall(),
          _FieldCard(
            child: Column(
              children: [
                TextField(
                  controller: nameCtrl,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Display name',
                    border: InputBorder.none,
                  ),
                ),
                const GutterSmall(),
                TextField(
                  controller: roleCtrl,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Role',
                    hintText: 'Planner, Guest, Florist…',
                    border: InputBorder.none,
                  ),
                ),
                const GutterSmall(),
                TextField(
                  controller: locationCtrl,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Location',
                    hintText: 'City',
                    border: InputBorder.none,
                  ),
                ),
                const GutterSmall(),
                TextField(
                  controller: bioCtrl,
                  maxLines: 4,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Bio',
                    alignLabelWithHint: true,
                    border: InputBorder.none,
                  ),
                ),
              ],
            ),
          ),
          const GutterLarge(),
          Text(
            'CONTACT',
            style: theme.textTheme.labelSmall?.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.6,
            ),
          ),
          const GutterSmall(),
          _FieldCard(
            child: Column(
              children: [
                TextField(
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: InputBorder.none,
                  ),
                ),
                const GutterSmall(),
                TextField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    labelText: 'Phone',
                    hintText: '+237 …',
                    border: InputBorder.none,
                  ),
                ),
              ],
            ),
          ),
          const Gutter(),
          Text(
            'Your public planner profile uses this name, photo, bio, and location.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldCard extends StatelessWidget {
  const _FieldCard({required this.child});

  final Widget child;

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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: child,
      ),
    );
  }
}
