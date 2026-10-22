import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

/// Horizontal swipe between [StatefulShellRoute] branches (Feed ↔ Events ↔ …).
///
/// Keeps [PageController] in sync when the bottom nav calls [goBranch].
class SwipeableShellBranchContainer extends StatefulWidget {
  const SwipeableShellBranchContainer({
    super.key,
    required this.navigationShell,
    required this.children,
  });

  final StatefulNavigationShell navigationShell;
  final List<Widget> children;

  @override
  State<SwipeableShellBranchContainer> createState() =>
      _SwipeableShellBranchContainerState();
}

class _SwipeableShellBranchContainerState
    extends State<SwipeableShellBranchContainer> {
  late final PageController _pageController;
  bool _animatingFromNav = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: widget.navigationShell.currentIndex,
    );
  }

  @override
  void didUpdateWidget(covariant SwipeableShellBranchContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    final index = widget.navigationShell.currentIndex;
    if (!_pageController.hasClients) return;
    final current =
        _pageController.page?.round() ?? _pageController.initialPage;
    if (current == index) return;
    _animatingFromNav = true;
    _pageController
        .animateToPage(
          index,
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
        )
        .whenComplete(() {
          if (mounted) _animatingFromNav = false;
        });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: _pageController,
      physics: const BouncingScrollPhysics(parent: PageScrollPhysics()),
      onPageChanged: (index) {
        if (_animatingFromNav) return;
        if (index == widget.navigationShell.currentIndex) return;
        widget.navigationShell.goBranch(index);
      },
      children: widget.children,
    );
  }
}
