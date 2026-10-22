import 'package:material_ui/material_ui.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ido_prime/src/core/routing/app_routes.dart';
import 'package:ido_prime/src/core/shared/widgets/scroll_chrome.dart';
import 'package:ido_prime/src/core/theme/app_colors.dart';
import 'package:ido_prime/src/features/home/providers/shell_search_provider.dart';
import 'package:ido_prime/src/features/home/widgets/app_bottom_nav.dart';
import 'package:ido_prime/src/features/home/widgets/main_shell_app_bar.dart';
import 'package:ido_prime/src/features/vendor_onboarding/models/vendor_business.dart';
import 'package:ido_prime/src/features/vendor_onboarding/utils/active_space_gate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// App scaffold with bottom navigation, driven by [StatefulShellRoute].
class HomeShell extends HookConsumerWidget {
  const HomeShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  /// Space reserved for floating nav + FAB lift (includes safe area).
  // Uses [AppBottomNav.clearance] at runtime.

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabIndex = navigationShell.currentIndex;
    final isPostsTab = tabIndex == 0;
    final isEventsTab = tabIndex == 1;
    final showFab = isPostsTab || isEventsTab;
    final frosted = useState(false);
    final chromeVisible = useState(true);
    final navClearance = AppBottomNav.clearance(context);

    useEffect(() {
      chromeVisible.value = true;
      frosted.value = false;
      // Defer provider write — useEffect can run during build on first mount.
      Future.microtask(() {
        ref.read(shellSearchQueryProvider.notifier).clear();
      });
      return null;
    }, [tabIndex]);

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      // No [bottomNavigationBar] slot — nav is overlaid so hidden chrome
      // does not reserve empty space at the bottom.
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 1),
        child: ScrollChromeSlide(
          visible: chromeVisible.value,
          edge: ScrollChromeEdge.top,
          child: MainShellAppBar(
            frosted: frosted.value,
            searchHint: shellSearchHintForTab(tabIndex),
          ),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification.metrics.axis == Axis.vertical) {
                final next = notification.metrics.pixels > 2;
                if (next != frosted.value) frosted.value = next;
              }
              updateScrollChromeVisibility(
                notification,
                visible: chromeVisible.value,
                onVisibilityChanged: (value) => chromeVisible.value = value,
              );
              return false;
            },
            child: navigationShell,
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: ScrollChromeSlide(
              visible: chromeVisible.value,
              edge: ScrollChromeEdge.bottom,
              child: AppBottomNav(
                currentIndex: tabIndex,
                onTap: (index) {
                  chromeVisible.value = true;
                  navigationShell.goBranch(
                    index,
                    initialLocation: index == tabIndex,
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: showFab
          ? AnimatedPadding(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              padding: EdgeInsets.only(
                bottom: chromeVisible.value ? navClearance : 0,
              ),
              child: ScrollChromeSlide(
                visible: chromeVisible.value,
                edge: ScrollChromeEdge.bottom,
                child: FloatingActionButton(
                  onPressed: () {
                    if (isPostsTab) {
                      runInActiveSpace(
                        context,
                        ref,
                        requiredSpace: ActiveSpace.planner,
                        actionLabel: 'create a post',
                        message:
                            'Posts are shared from your Planner space. '
                            'Switch to Planner to create a post.',
                        action: () => context.push(AppRoutes.createPost),
                      );
                      return;
                    }
                    runInActiveSpace(
                      context,
                      ref,
                      requiredSpace: ActiveSpace.planner,
                      actionLabel: 'plan an event',
                      message:
                          'Events are planned from your Planner space. '
                          'Switch to Planner to create an event.',
                      action: () => context.push(AppRoutes.createEvent),
                    );
                  },
                  tooltip: isPostsTab ? 'Create post' : 'Plan an event',
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  elevation: 8,
                  shape: const CircleBorder(),
                  child: Icon(
                    isPostsTab ? LucideIcons.plus : LucideIcons.calendarPlus,
                    size: 28,
                  ),
                ),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
