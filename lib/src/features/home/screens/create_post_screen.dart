import 'package:material_ui/material_ui.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ido_prime/src/core/shared/widgets/app_cached_network_image.dart';
import 'package:ido_prime/src/core/shared/widgets/app_frosted_app_bar.dart';
import 'package:ido_prime/src/core/theme/app_colors.dart';
import 'package:ido_prime/src/features/home/providers/feed_posts_provider.dart';
import 'package:ido_prime/src/features/profile/providers/user_account_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class CreatePostScreen extends HookConsumerWidget {
  const CreatePostScreen({super.key});

  static const _maxMedia = 8;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final account = ref.watch(userAccountProvider);
    final captionCtrl = useTextEditingController();
    final mediaPaths = useState<List<String>>(const []);
    final publishing = useState(false);
    final captionTick = useState(0);

    final canPublish =
        captionCtrl.text.trim().isNotEmpty || mediaPaths.value.isNotEmpty;

    Future<void> pickImages(ImageSource source) async {
      try {
        final remaining = _maxMedia - mediaPaths.value.length;
        if (remaining <= 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('You can add up to 8 photos')),
          );
          return;
        }

        if (source == ImageSource.gallery) {
          final files = await ImagePicker().pickMultiImage(
            maxWidth: 1920,
            maxHeight: 1920,
            imageQuality: 85,
            limit: remaining,
          );
          if (files.isEmpty) return;
          mediaPaths.value = [
            ...mediaPaths.value,
            for (final file in files) file.path,
          ].take(_maxMedia).toList(growable: false);
          return;
        }

        final file = await ImagePicker().pickImage(
          source: ImageSource.camera,
          maxWidth: 1920,
          maxHeight: 1920,
          imageQuality: 85,
        );
        if (file == null) return;
        mediaPaths.value = [...mediaPaths.value, file.path];
      } catch (_) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not add photos')),
        );
      }
    }

    Future<void> publish() async {
      if (!canPublish || publishing.value) return;
      publishing.value = true;
      await Future<void>.delayed(const Duration(milliseconds: 220));
      final post = ref.read(feedPostsProvider.notifier).createPost(
            author: account,
            caption: captionCtrl.text,
            mediaUrls: mediaPaths.value,
          );
      publishing.value = false;
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post shared')),
      );
      context.pop(post.id);
    }

    return Scaffold(
      appBar: AppFrostedAppBar(
        leading: IconButton(
          onPressed: publishing.value ? null : () => context.pop(),
          icon: const Icon(LucideIcons.x),
        ),
        title: Text(
          'New post',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton(
              onPressed: canPublish && !publishing.value ? publish : null,
              child: Text(
                'Share',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: canPublish
                      ? AppColors.primary
                      : colors.onSurfaceVariant.withValues(alpha: 0.45),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(context.gutter, 8, context.gutter, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: publishing.value
                          ? null
                          : () => pickImages(ImageSource.gallery),
                      icon: const Icon(LucideIcons.images, size: 18),
                      label: const Text('Photos'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        shape: const StadiumBorder(),
                      ),
                    ),
                  ),
                  const GutterSmall(),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: publishing.value
                          ? null
                          : () => pickImages(ImageSource.camera),
                      icon: const Icon(LucideIcons.camera, size: 18),
                      label: const Text('Camera'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        shape: const StadiumBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const GutterSmall(),
              FilledButton(
                onPressed: canPublish && !publishing.value ? publish : null,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  disabledBackgroundColor: colors.surfaceContainerHighest,
                  minimumSize: const Size.fromHeight(48),
                  shape: const StadiumBorder(),
                ),
                child: publishing.value
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Share post'),
              ),
            ],
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppCachedAvatar(
                imageUrl: account.avatarUrl,
                radius: 22,
                fallbackName: account.displayName,
              ),
              const GutterSmall(),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      account.displayName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      account.role,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Gutter(),
          TextField(
            controller: captionCtrl,
            onChanged: (_) => captionTick.value++,
            maxLines: null,
            minLines: 5,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: 'Share a celebration moment…',
              hintStyle: theme.textTheme.bodyLarge?.copyWith(
                color: colors.onSurfaceVariant,
              ),
              filled: true,
              fillColor: colors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: colors.outline.withValues(alpha: 0.7),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: colors.outline.withValues(alpha: 0.7),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
            ),
          ),
          if (mediaPaths.value.isNotEmpty) ...[
            const Gutter(),
            Text(
              'PHOTOS · ${mediaPaths.value.length}/$_maxMedia',
              style: theme.textTheme.labelSmall?.copyWith(
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            const GutterSmall(),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: mediaPaths.value.length +
                  (mediaPaths.value.length < _maxMedia ? 1 : 0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemBuilder: (context, index) {
                if (index >= mediaPaths.value.length) {
                  return Material(
                    color: colors.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(
                        color: colors.outline.withValues(alpha: 0.7),
                      ),
                    ),
                    child: InkWell(
                      onTap: () => pickImages(ImageSource.gallery),
                      borderRadius: BorderRadius.circular(14),
                      child: const Center(
                        child: Icon(LucideIcons.plus, color: AppColors.primary),
                      ),
                    ),
                  );
                }
                final path = mediaPaths.value[index];
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: AppCachedNetworkImage(
                        imageUrl: path,
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Material(
                        color: Colors.black.withValues(alpha: 0.55),
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () {
                            mediaPaths.value = [
                              for (var i = 0; i < mediaPaths.value.length; i++)
                                if (i != index) mediaPaths.value[i],
                            ];
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(6),
                            child: Icon(
                              LucideIcons.x,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ] else ...[
            const Gutter(),
            Material(
              color: colors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: colors.outline.withValues(alpha: 0.7),
                ),
              ),
              child: InkWell(
                onTap: () => pickImages(ImageSource.gallery),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 28,
                  ),
                  child: Column(
                    children: [
                      Icon(
                        LucideIcons.imagePlus,
                        size: 32,
                        color: colors.onSurfaceVariant,
                      ),
                      const GutterSmall(),
                      Text(
                        'Add photos from your celebration',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const GutterTiny(),
                      Text(
                        'Or share a text update for the community',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
