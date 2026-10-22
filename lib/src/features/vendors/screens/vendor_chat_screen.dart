import 'package:material_ui/material_ui.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ido_prime/src/core/routing/app_routes.dart';
import 'package:ido_prime/src/core/shared/widgets/app_cached_network_image.dart';
import 'package:ido_prime/src/core/shared/widgets/app_frosted_app_bar.dart';
import 'package:ido_prime/src/core/theme/app_colors.dart';
import 'package:ido_prime/src/features/vendors/models/vendor.dart';
import 'package:ido_prime/src/features/vendors/providers/vendor_chat_provider.dart';
import 'package:ido_prime/src/features/vendors/providers/vendor_connection_provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// In-app planner ↔ vendor conversation — available only after accept.
class VendorChatScreen extends HookConsumerWidget {
  const VendorChatScreen({super.key, required this.vendorId});

  final String vendorId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vendor = findVendorById(vendorId);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final gutter = context.gutter;
    final connection = ref.watch(vendorConnectionProvider(vendorId));
    final messages = ref.watch(vendorChatProvider(vendorId));
    final controller = useTextEditingController();
    final scrollController = useScrollController();
    final frosted = useState(false);

    useEffect(() {
      if (connection?.status != VendorConnectionStatus.accepted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!context.mounted) return;
          context.replace(AppRoutes.vendorContact(vendorId));
        });
      }
      return null;
    }, [connection?.status]);

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!scrollController.hasClients) return;
        scrollController.jumpTo(scrollController.position.maxScrollExtent);
      });
      return null;
    }, [messages.length]);

    if (vendor == null) {
      return Scaffold(
        appBar: const AppFrostedAppBar(title: Text('Chat')),
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

    if (connection?.status != VendorConnectionStatus.accepted) {
      return const Scaffold(
        appBar: AppFrostedAppBar(title: Text('Chat')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    Future<void> send() async {
      final text = controller.text;
      controller.clear();
      await ref.read(vendorChatProvider(vendorId).notifier).send(text);
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      extendBodyBehindAppBar: true,
      appBar: AppFrostedAppBar(
        frosted: frosted.value,
        title: Row(
          children: [
            AppCachedAvatar(
              imageUrl: vendor.imageUrl,
              radius: 16,
              fallbackName: vendor.name,
            ),
            const GutterSmall(),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    vendor.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Event chat · ${vendor.category}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          AppCircleIconButton(icon: LucideIcons.phone, onPressed: () {}),
          const GutterSmall(),
        ],
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (n) {
          final next = n.metrics.pixels > 2;
          if (next != frosted.value) frosted.value = next;
          return false;
        },
        child: Column(
          children: [
            Expanded(
              child: CustomScrollView(
                controller: scrollController,
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                slivers: [
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      gutter,
                      MediaQuery.paddingOf(context).top + kToolbarHeight + 16,
                      gutter,
                      12,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final msg = messages[index];
                        return _Bubble(message: msg);
                      }, childCount: messages.length),
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
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      IconButton(
                        onPressed: () {},
                        tooltip: 'Voice note',
                        icon: Icon(
                          LucideIcons.mic,
                          size: 22,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      const GutterTiny(),
                      Expanded(
                        child: TextField(
                          controller: controller,
                          minLines: 1,
                          maxLines: 4,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => send(),
                          decoration: InputDecoration(
                            hintText: 'Message…',
                            isDense: true,
                            filled: true,
                            fillColor: colors.surfaceContainerHighest
                                .withValues(alpha: 0.45),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 12,
                            ),
                            border: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(999),
                              ),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: const BorderRadius.all(
                                Radius.circular(999),
                              ),
                              borderSide: BorderSide(
                                color: colors.outline.withValues(alpha: 0.55),
                              ),
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(999),
                              ),
                              borderSide: BorderSide(
                                color: AppColors.primary,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const GutterSmall(),
                      IconButton.filled(
                        onPressed: send,
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.onPrimary,
                        ),
                        icon: const Icon(LucideIcons.send, size: 18),
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

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message});

  final VendorChatMessage message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final mine = message.fromPlanner;

    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.78,
        ),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: mine
                  ? AppColors.primary.withValues(alpha: 0.22)
                  : colors.surface,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(mine ? 16 : 4),
                bottomRight: Radius.circular(mine ? 4 : 16),
              ),
              border: Border.all(
                color: mine
                    ? AppColors.primary.withValues(alpha: 0.35)
                    : colors.outline.withValues(alpha: 0.55),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Text(
                message.body,
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.35),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
