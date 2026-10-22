import 'package:material_ui/material_ui.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ido_prime/src/core/extensions/context_extension.dart';
import 'package:ido_prime/src/core/routing/app_routes.dart';
import 'package:ido_prime/src/core/shared/widgets/app_cached_network_image.dart';
import 'package:ido_prime/src/core/theme/app_colors.dart';
import 'package:ido_prime/src/features/home/models/feed_suggestion.dart';
import 'package:ido_prime/src/features/social/models/planner_friendship.dart';
import 'package:ido_prime/src/features/social/providers/planner_friendship_provider.dart';
import 'package:ido_prime/src/features/social/providers/vendor_follow_provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Horizontal “Suggested for you” rail — vendors (Follow) and planners (Add friend).
class FeedSuggestionsCard extends ConsumerWidget {
  const FeedSuggestionsCard({super.key, required this.suggestions});

  final List<FeedSuggestion> suggestions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final follows = ref.watch(vendorFollowProvider);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.gutter),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: colors.outline.withValues(alpha: 0.7)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    LucideIcons.users,
                    size: 16,
                    color: colors.onSurfaceVariant,
                  ),
                  const GutterTiny(),
                  Expanded(
                    child: Text(
                      'Suggested for you',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () => context.go(AppRoutes.vendors),
                    child: Text(
                      'See all',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const GutterTiny(),
              Text(
                'Follow vendors · Add planner friends',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const Gutter(),
              SizedBox(
                height: 196,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: suggestions.length,
                  separatorBuilder: (_, _) => const GutterSmall(),
                  itemBuilder: (context, index) {
                    final item = suggestions[index];
                    final isVendor = item.kind == FeedSuggestionKind.vendor;
                    final vendorId = item.routeId;
                    final isFollowing =
                        isVendor &&
                        vendorId != null &&
                        follows.contains(vendorId);
                    final friendship = !isVendor && item.routeId != null
                        ? ref.watch(plannerFriendshipProvider(item.routeId!))
                        : null;

                    return _SuggestionTile(
                      suggestion: item,
                      isFollowing: isFollowing,
                      friendship: friendship,
                      onVendorFollow: () {
                        if (vendorId == null) return;
                        ref
                            .read(vendorFollowProvider.notifier)
                            .toggle(vendorId);
                      },
                      onPlannerFriend: () {
                        final id = item.routeId;
                        if (id == null) return;
                        final status = friendship?.status;
                        if (status == FriendshipStatus.none ||
                            status == FriendshipStatus.declined) {
                          ref
                              .read(plannerFriendshipProvider(id).notifier)
                              .sendRequest();
                          context.showSnackBar('Friend request sent');
                        } else {
                          context.push(AppRoutes.plannerProfile(id));
                        }
                      },
                      onOpen: () {
                        if (item.kind == FeedSuggestionKind.vendor &&
                            item.routeId != null) {
                          context.push(AppRoutes.vendorProfile(item.routeId!));
                        } else if (item.kind == FeedSuggestionKind.user &&
                            item.routeId != null) {
                          context.push(AppRoutes.plannerProfile(item.routeId!));
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SuggestionTile extends StatelessWidget {
  const _SuggestionTile({
    required this.suggestion,
    required this.isFollowing,
    required this.friendship,
    required this.onVendorFollow,
    required this.onPlannerFriend,
    required this.onOpen,
  });

  final FeedSuggestion suggestion;
  final bool isFollowing;
  final PlannerFriendship? friendship;
  final VoidCallback onVendorFollow;
  final VoidCallback onPlannerFriend;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isVendor = suggestion.kind == FeedSuggestionKind.vendor;

    final plannerLabel = switch (friendship?.status) {
      FriendshipStatus.accepted => 'Friends',
      FriendshipStatus.pendingOutgoing => 'Pending',
      FriendshipStatus.pendingIncoming => 'Respond',
      _ => 'Add friend',
    };

    return SizedBox(
      width: 140,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: isVendor
              ? AppColors.primary.withValues(alpha: 0.08)
              : colors.surfaceContainerHighest.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isVendor
                ? AppColors.primary.withValues(alpha: 0.55)
                : colors.outline.withValues(alpha: 0.5),
            width: isVendor ? 1.4 : 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 12, 10, 10),
          child: Column(
            children: [
              InkWell(
                onTap: onOpen,
                borderRadius: BorderRadius.circular(isVendor ? 16 : 40),
                child: isVendor
                    ? _VendorAvatar(
                        imageUrl: suggestion.avatarUrl,
                        name: suggestion.name,
                      )
                    : _UserAvatar(
                        imageUrl: suggestion.avatarUrl,
                        name: suggestion.name,
                      ),
              ),
              const GutterSmall(),
              _KindBadge(isVendor: isVendor),
              const GutterTiny(),
              Text(
                suggestion.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Gutter.custom(size: 2),
              Text(
                suggestion.subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 32,
                child: isVendor
                    ? FilledButton(
                        onPressed: onVendorFollow,
                        style: FilledButton.styleFrom(
                          padding: EdgeInsets.zero,
                          backgroundColor: isFollowing
                              ? colors.surfaceContainerHighest
                              : AppColors.primary,
                          foregroundColor: isFollowing
                              ? colors.onSurface
                              : AppColors.onPrimary,
                          shape: const StadiumBorder(),
                        ),
                        child: Text(
                          isFollowing ? 'Following' : 'Follow',
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      )
                    : FilledButton(
                        onPressed: onPlannerFriend,
                        style: FilledButton.styleFrom(
                          padding: EdgeInsets.zero,
                          backgroundColor:
                              friendship?.status == FriendshipStatus.accepted
                              ? colors.surfaceContainerHighest
                              : AppColors.primary,
                          foregroundColor:
                              friendship?.status == FriendshipStatus.accepted
                              ? colors.onSurface
                              : AppColors.onPrimary,
                          shape: const StadiumBorder(),
                        ),
                        child: Text(
                          plannerLabel,
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _KindBadge extends StatelessWidget {
  const _KindBadge({required this.isVendor});

  final bool isVendor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: isVendor
            ? AppColors.primary.withValues(alpha: 0.2)
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: Text(
          isVendor ? 'Vendor' : 'Planner',
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: isVendor
                ? AppColors.primary
                : theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _VendorAvatar extends StatelessWidget {
  const _VendorAvatar({required this.imageUrl, required this.name});

  final String imageUrl;
  final String name;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: 72,
        height: 72,
        child: imageUrl.isEmpty
            ? ColoredBox(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Center(
                  child: Text(
                    name.isEmpty ? '?' : name[0].toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              )
            : AppCachedNetworkImage(imageUrl: imageUrl, fit: BoxFit.cover),
      ),
    );
  }
}

class _UserAvatar extends StatelessWidget {
  const _UserAvatar({required this.imageUrl, required this.name});

  final String imageUrl;
  final String name;

  @override
  Widget build(BuildContext context) {
    return AppCachedAvatar(imageUrl: imageUrl, radius: 36, fallbackName: name);
  }
}
