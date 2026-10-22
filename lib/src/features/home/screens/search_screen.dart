import 'dart:ui';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ido_prime/src/core/routing/app_routes.dart';
import 'package:ido_prime/src/core/shared/widgets/app_cached_network_image.dart';
import 'package:ido_prime/src/core/theme/app_colors.dart';
import 'package:ido_prime/src/features/events/providers/events_provider.dart';
import 'package:ido_prime/src/features/home/providers/feed_posts_provider.dart';
import 'package:ido_prime/src/features/vendors/models/vendor.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

enum SearchOrigin { feed, inspiration, events, vendors }

SearchOrigin searchOriginFromParam(String? raw) => switch (raw) {
  'inspiration' => SearchOrigin.inspiration,
  'events' => SearchOrigin.events,
  'vendors' => SearchOrigin.vendors,
  _ => SearchOrigin.feed,
};

class SearchScreen extends HookConsumerWidget {
  const SearchScreen({super.key, this.origin = SearchOrigin.feed});

  final SearchOrigin origin;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final gutter = context.gutter;
    final controller = useTextEditingController();
    final query = useState('');
    final focusNode = useFocusNode();
    final allPosts = ref.watch(feedPostsProvider);

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (focusNode.canRequestFocus) focusNode.requestFocus();
      });
      return null;
    }, const []);

    final q = query.value.trim().toLowerCase();
    final posts = allPosts
        .where(
          (p) =>
              q.isEmpty ||
              p.authorName.toLowerCase().contains(q) ||
              p.caption.toLowerCase().contains(q),
        )
        .take(6)
        .toList();
    final vendors = mockVendors
        .where(
          (v) =>
              q.isEmpty ||
              v.name.toLowerCase().contains(q) ||
              v.category.toLowerCase().contains(q) ||
              v.location.toLowerCase().contains(q),
        )
        .take(6)
        .toList();
    final events = mockEvents
        .where(
          (e) =>
              q.isEmpty ||
              e.title.toLowerCase().contains(q) ||
              e.place.toLowerCase().contains(q),
        )
        .take(6)
        .toList();

    final sections = <_SearchSection>[
      _SearchSection(
        key: SearchOrigin.feed,
        title: 'Posts',
        hasResults: posts.isNotEmpty,
        builder: (context) => [
          for (final post in posts) ...[
            _SuggestTile(
              leading: AppCachedAvatar(
                imageUrl: post.authorAvatarUrl,
                radius: 20,
                fallbackName: post.authorName,
              ),
              title: post.authorName,
              subtitle: post.caption,
              onTap: () => context.push(AppRoutes.postDetail(post.id)),
              onLeadingTap: () =>
                  context.push(AppRoutes.plannerProfile(post.authorId)),
            ),
            const GutterSmall(),
          ],
        ],
      ),
      _SearchSection(
        key: SearchOrigin.vendors,
        title: 'Vendors',
        hasResults: vendors.isNotEmpty,
        builder: (context) => [
          for (final vendor in vendors) ...[
            _SuggestTile(
              leading: AppCachedAvatar(
                imageUrl: vendor.imageUrl,
                radius: 20,
                fallbackName: vendor.name,
              ),
              title: vendor.name,
              subtitle: '${vendor.category} · ${vendor.location}',
              onTap: () => context.push(AppRoutes.vendorProfile(vendor.id)),
            ),
            const GutterSmall(),
          ],
        ],
      ),
      _SearchSection(
        key: SearchOrigin.events,
        title: 'Events',
        hasResults: events.isNotEmpty,
        builder: (context) => [
          for (final event in events) ...[
            _SuggestTile(
              leading: CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                child: Icon(
                  LucideIcons.calendarDays,
                  size: 18,
                  color: colors.primary,
                ),
              ),
              title: event.title,
              subtitle: '${event.dateLabel} · ${event.place}',
              onTap: () => context.push(AppRoutes.eventDetail(event.id)),
            ),
            const GutterSmall(),
          ],
        ],
      ),
      _SearchSection(
        key: SearchOrigin.inspiration,
        title: 'Inspiration',
        hasResults: q.isEmpty,
        builder: (context) => [
          if (q.isEmpty)
            _SuggestTile(
              leading: CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                child: Icon(
                  LucideIcons.sparkles,
                  size: 18,
                  color: colors.primary,
                ),
              ),
              title: 'Mood boards & looks',
              subtitle: 'Browse inspiration ideas',
              onTap: () {
                context.pop();
                context.go(AppRoutes.inspiration);
              },
            ),
        ],
      ),
    ];

    // Origin tab's category stays first.
    sections.sort((a, b) {
      final aPrimary = a.key == origin;
      final bPrimary = b.key == origin;
      if (aPrimary != bPrimary) return aPrimary ? -1 : 1;
      return 0;
    });

    // Hide categories with no matches for the current query.
    final visibleSections = q.isEmpty
        ? sections
        : sections.where((s) => s.hasResults).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: ColoredBox(
              color: theme.scaffoldBackgroundColor.withValues(alpha: 0.72),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(gutter, 8, gutter, 0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => context.pop(),
                        icon: const Icon(LucideIcons.arrowLeft),
                      ),
                      const GutterTiny(),
                      Expanded(
                        child: TextField(
                          controller: controller,
                          focusNode: focusNode,
                          onChanged: (v) => query.value = v,
                          textInputAction: TextInputAction.search,
                          decoration: InputDecoration(
                            hintText: 'Search ${_hintFor(origin)}…',
                            prefixIcon: Icon(
                              LucideIcons.search,
                              size: 18,
                              color: colors.onSurfaceVariant,
                            ),
                            filled: true,
                            fillColor: colors.surface.withValues(alpha: 0.85),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(22),
                              borderSide: BorderSide(
                                color: colors.outline.withValues(alpha: 0.5),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(22),
                              borderSide: BorderSide(
                                color: colors.outline.withValues(alpha: 0.5),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(22),
                              borderSide: const BorderSide(
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Gutter(),
                Expanded(
                  child: visibleSections.isEmpty
                      ? Center(
                          child: Text(
                            'No results for “${query.value.trim()}”',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        )
                      : CustomScrollView(
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,
                          slivers: [
                            SliverPadding(
                              padding: EdgeInsets.fromLTRB(
                                gutter,
                                0,
                                gutter,
                                32,
                              ),
                              sliver: SliverList(
                                delegate: SliverChildListDelegate([
                                  for (final section in visibleSections) ...[
                                    _SectionTitle(title: section.title),
                                    const GutterSmall(),
                                    ...section.builder(context),
                                    const Gutter(),
                                  ],
                                ]),
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _hintFor(SearchOrigin o) => switch (o) {
    SearchOrigin.feed => 'feed',
    SearchOrigin.inspiration => 'inspiration',
    SearchOrigin.events => 'events',
    SearchOrigin.vendors => 'vendors',
  };
}

class _SearchSection {
  const _SearchSection({
    required this.key,
    required this.title,
    required this.hasResults,
    required this.builder,
  });

  final SearchOrigin key;
  final String title;
  final bool hasResults;
  final List<Widget> Function(BuildContext context) builder;
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _SuggestTile extends StatelessWidget {
  const _SuggestTile({
    required this.leading,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.onLeadingTap,
  });

  final Widget leading;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final VoidCallback? onLeadingTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Material(
      color: colors.surface.withValues(alpha: 0.7),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              GestureDetector(
                onTap: onLeadingTap,
                behavior: HitTestBehavior.opaque,
                child: leading,
              ),
              const GutterSmall(),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                LucideIcons.chevronRight,
                size: 18,
                color: colors.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
