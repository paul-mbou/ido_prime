import 'package:material_ui/material_ui.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:ido_prime/src/core/shared/widgets/app_frosted_app_bar.dart';
import 'package:ido_prime/src/core/theme/app_colors.dart';
import 'package:ido_prime/src/features/profile/models/help_article.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpCenterScreen extends HookWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final query = useState('');
    final topic = useState(HelpTopic.all);
    final expandedId = useState<String?>(null);

    final q = query.value.trim().toLowerCase();
    final filtered = helpArticles
        .where((article) {
          final matchesTopic =
              topic.value == HelpTopic.all || article.topic == topic.value;
          if (!matchesTopic) return false;
          if (q.isEmpty) return true;
          return article.question.toLowerCase().contains(q) ||
              article.answer.toLowerCase().contains(q) ||
              article.topic.label.toLowerCase().contains(q);
        })
        .toList(growable: false);

    Future<void> contactSupport() async {
      final uri = Uri.parse(
        'mailto:hello@ido.app'
        '?subject=${Uri.encodeComponent('IDO Help')}'
        '&body=${Uri.encodeComponent('Hi IDO team,\n\n')}',
      );
      try {
        final launched = await launchUrl(uri);
        if (!launched && context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Email hello@ido.app')));
        }
      } catch (_) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Email hello@ido.app')));
      }
    }

    return Scaffold(
      appBar: AppFrostedAppBar(
        title: Text(
          'Help Center',
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
          Text(
            'How can we help?',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const GutterTiny(),
          Text(
            'Browse guides for events, vendors, inspiration, and your account.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          const Gutter(),
          TextField(
            onChanged: (value) => query.value = value,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Search help…',
              prefixIcon: const Icon(LucideIcons.search, size: 20),
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
          const Gutter(),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: HelpTopic.values.length,
              separatorBuilder: (_, _) => const GutterSmall(),
              itemBuilder: (context, index) {
                final item = HelpTopic.values[index];
                final selected = topic.value == item;
                return Material(
                  color: selected
                      ? AppColors.primary
                      : colors.surfaceContainerHighest,
                  shape: const StadiumBorder(),
                  child: InkWell(
                    onTap: () {
                      topic.value = item;
                      expandedId.value = null;
                    },
                    customBorder: const StadiumBorder(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Row(
                        children: [
                          Icon(
                            item.icon,
                            size: 16,
                            color: selected
                                ? AppColors.onPrimary
                                : colors.onSurfaceVariant,
                          ),
                          const GutterTiny(),
                          Text(
                            item.label,
                            style: theme.textTheme.labelLarge?.copyWith(
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
              },
            ),
          ),
          const GutterLarge(),
          Text(
            'FAQs',
            style: theme.textTheme.titleSmall?.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const GutterSmall(),
          if (filtered.isEmpty)
            Material(
              color: colors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: BorderSide(color: colors.outline.withValues(alpha: 0.7)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 28,
                ),
                child: Column(
                  children: [
                    Icon(
                      LucideIcons.searchX,
                      size: 28,
                      color: colors.onSurfaceVariant,
                    ),
                    const GutterSmall(),
                    Text(
                      'No articles match your search',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const GutterTiny(),
                    Text(
                      'Try another keyword, or message the IDO team below.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Material(
              color: colors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: BorderSide(color: colors.outline.withValues(alpha: 0.7)),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  for (var i = 0; i < filtered.length; i++) ...[
                    _FaqTile(
                      article: filtered[i],
                      expanded: expandedId.value == filtered[i].id,
                      onTap: () {
                        expandedId.value = expandedId.value == filtered[i].id
                            ? null
                            : filtered[i].id;
                      },
                    ),
                    if (i < filtered.length - 1)
                      Divider(
                        height: 1,
                        indent: 16,
                        endIndent: 16,
                        color: colors.outline.withValues(alpha: 0.55),
                      ),
                  ],
                ],
              ),
            ),
          const GutterLarge(),
          Text(
            'Still stuck?',
            style: theme.textTheme.titleSmall?.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const GutterSmall(),
          Material(
            color: colors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: BorderSide(color: colors.outline.withValues(alpha: 0.7)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.18),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          LucideIcons.mail,
                          color: AppColors.primary,
                          size: 22,
                        ),
                      ),
                      const GutterSmall(),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Contact support',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              'We usually reply within one business day.',
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
                  FilledButton(
                    onPressed: contactSupport,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                      minimumSize: const Size.fromHeight(48),
                      shape: const StadiumBorder(),
                    ),
                    child: const Text('Email hello@ido.app'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FaqTile extends StatelessWidget {
  const _FaqTile({
    required this.article,
    required this.expanded,
    required this.onTap,
  });

  final HelpArticle article;
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    article.question,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const GutterSmall(),
                Icon(
                  expanded ? LucideIcons.chevronUp : LucideIcons.chevronDown,
                  size: 18,
                  color: colors.onSurfaceVariant,
                ),
              ],
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article.topic.label.toUpperCase(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const GutterTiny(),
                    Text(
                      article.answer,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              crossFadeState: expanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 180),
            ),
          ],
        ),
      ),
    );
  }
}
