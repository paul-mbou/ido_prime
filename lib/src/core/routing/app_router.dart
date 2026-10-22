import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ido_prime/src/core/routing/app_routes.dart';
import 'package:ido_prime/src/core/routing/auth_refresh_notifier.dart';
import 'package:ido_prime/src/features/auth/presentation/screens/forgot_pass_screen.dart';
import 'package:ido_prime/src/features/auth/presentation/screens/login_screen.dart';
import 'package:ido_prime/src/features/auth/presentation/screens/new_pass_screen.dart';
import 'package:ido_prime/src/features/auth/presentation/screens/otp_screen.dart';
import 'package:ido_prime/src/features/auth/presentation/screens/register_screen.dart';
import 'package:ido_prime/src/features/events/screens/create_event_screen.dart';
import 'package:ido_prime/src/features/events/screens/event_detail_screen.dart';
import 'package:ido_prime/src/features/events/screens/events_screen.dart';
import 'package:ido_prime/src/features/home/providers/feed_posts_provider.dart';
import 'package:ido_prime/src/features/home/screens/create_post_screen.dart';
import 'package:ido_prime/src/features/home/screens/fullscreen_image_screen.dart';
import 'package:ido_prime/src/features/home/screens/home_shell.dart';
import 'package:ido_prime/src/features/home/screens/notifications_screen.dart';
import 'package:ido_prime/src/features/home/screens/post_detail_screen.dart';
import 'package:ido_prime/src/features/home/screens/posts_feed_screen.dart';
import 'package:ido_prime/src/features/home/screens/search_screen.dart';
import 'package:ido_prime/src/features/home/widgets/swipeable_shell_branch_container.dart';
import 'package:ido_prime/src/features/inspiration/screens/create_mood_board_screen.dart';
import 'package:ido_prime/src/features/inspiration/screens/inspiration_screen.dart';
import 'package:ido_prime/src/features/inspiration/screens/look_detail_screen.dart';
import 'package:ido_prime/src/features/inspiration/screens/mood_board_detail_screen.dart';
import 'package:ido_prime/src/features/onboarding/screens/onboarding_screen.dart';
import 'package:ido_prime/src/features/profile/screens/app_settings_screen.dart';
import 'package:ido_prime/src/features/profile/screens/edit_profile_screen.dart';
import 'package:ido_prime/src/features/profile/screens/help_center_screen.dart';
import 'package:ido_prime/src/features/profile/screens/planner_profile_screen.dart';
import 'package:ido_prime/src/features/profile/screens/privacy_security_screen.dart';
import 'package:ido_prime/src/features/profile/screens/profile_screen.dart';
import 'package:ido_prime/src/features/social/screens/planner_chat_screen.dart';
import 'package:ido_prime/src/features/splash/splash_screen.dart';
import 'package:ido_prime/src/features/vendor_onboarding/screens/vendor_manage_profile_screen.dart';
import 'package:ido_prime/src/features/vendor_onboarding/screens/vendor_onboarding_hub_screen.dart';
import 'package:ido_prime/src/features/vendor_onboarding/screens/vendor_onboarding_step1_screen.dart';
import 'package:ido_prime/src/features/vendor_onboarding/screens/vendor_onboarding_step2_screen.dart';
import 'package:ido_prime/src/features/vendor_onboarding/screens/vendor_onboarding_step3_screen.dart';
import 'package:ido_prime/src/features/vendors/screens/contact_vendor_screen.dart';
import 'package:ido_prime/src/features/vendors/screens/vendor_chat_screen.dart';
import 'package:ido_prime/src/features/vendors/screens/vendor_profile_screen.dart';
import 'package:ido_prime/src/features/vendors/screens/vendors_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final goRouterProvider = Provider<GoRouter>((ref) {
  final authRefresh = AuthRefreshNotifier(Supabase.instance.client);
  ref.onDispose(authRefresh.dispose);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.posts,
    debugLogDiagnostics: kDebugMode,
    refreshListenable: authRefresh,
    redirect: (context, state) {
      final isLoggedIn = authRefresh.isLoggedIn;
      final location = state.matchedLocation;
      final isSplash = location == AppRoutes.splash;
      final isOnboarding = location == AppRoutes.onboarding;

      // Splash owns its own timed navigation (animation → onboarding/auth/home).
      if (isSplash) return null;

      // First-run tour is public.
      if (isOnboarding) return null;

      // Guests can browse the main shell + discovery; only gated routes redirect.
      if (!isLoggedIn && !AppRoutes.isGuestAccessible(location)) {
        return AppRoutes.login;
      }

      // Already signed in → skip login/register entry points.
      if (isLoggedIn &&
          (location == AppRoutes.login || location == AppRoutes.register)) {
        return AppRoutes.posts;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          child: const SplashScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          child: const OnboardingScreen(),
          transitionDuration: const Duration(milliseconds: 480),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curved = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            );
            return FadeTransition(
              opacity: curved,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.04),
                  end: Offset.zero,
                ).animate(curved),
                child: child,
              ),
            );
          },
        ),
      ),
      GoRoute(
        path: AppRoutes.login,
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          child: const LoginScreen(),
          transitionDuration: const Duration(milliseconds: 420),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curved = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            );
            return FadeTransition(opacity: curved, child: child);
          },
        ),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.otp,
        builder: (context, state) => const OtpScreen(),
      ),
      GoRoute(
        path: AppRoutes.newPassword,
        builder: (context, state) => const NewPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.vendorOnboardingHub,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const VendorOnboardingHubScreen(),
      ),
      GoRoute(
        path: AppRoutes.vendorManageProfile,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const VendorManageProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.vendorOnboardingStep1,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const VendorOnboardingStep1Screen(),
      ),
      GoRoute(
        path: AppRoutes.vendorOnboardingStep2,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const VendorOnboardingStep2Screen(),
      ),
      GoRoute(
        path: AppRoutes.vendorOnboardingStep3,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const VendorOnboardingStep3Screen(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.editProfile,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.privacySecurity,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const PrivacySecurityScreen(),
      ),
      GoRoute(
        path: AppRoutes.appSettings,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AppSettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.helpCenter,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const HelpCenterScreen(),
      ),
      GoRoute(
        path: AppRoutes.plannerProfilePath,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) =>
            PlannerProfileScreen(plannerId: state.pathParameters['plannerId']!),
        routes: [
          GoRoute(
            path: 'chat',
            parentNavigatorKey: _rootNavigatorKey,
            builder: (context, state) => PlannerChatScreen(
              plannerId: state.pathParameters['plannerId']!,
            ),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.search,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => SearchScreen(
          origin: searchOriginFromParam(state.uri.queryParameters['from']),
        ),
      ),
      GoRoute(
        path: AppRoutes.notifications,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: AppRoutes.createEvent,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const CreateEventScreen(),
      ),
      GoRoute(
        path: AppRoutes.createPost,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const CreatePostScreen(),
      ),
      GoRoute(
        path: AppRoutes.createMoodBoard,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => CreateMoodBoardScreen(
          seedLookId: state.uri.queryParameters['lookId'],
        ),
      ),
      GoRoute(
        path: AppRoutes.lookDetailPath,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) =>
            LookDetailScreen(lookId: state.pathParameters['lookId']!),
      ),
      GoRoute(
        path: AppRoutes.moodBoardDetailPath,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) =>
            MoodBoardDetailScreen(boardId: state.pathParameters['boardId']!),
      ),
      // Full-screen outside the shell so pushes from Feed / Search do not
      // collide with StatefulShellRoute branch page keys.
      GoRoute(
        path: AppRoutes.eventDetailPath,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) =>
            EventDetailScreen(eventId: state.pathParameters['eventId']!),
      ),
      StatefulShellRoute(
        builder: (context, state, navigationShell) {
          return HomeShell(navigationShell: navigationShell);
        },
        navigatorContainerBuilder: (context, navigationShell, children) {
          return SwipeableShellBranchContainer(
            navigationShell: navigationShell,
            children: children,
          );
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.posts,
                builder: (context, state) => const PostsFeedScreen(),
                routes: [
                  GoRoute(
                    path: ':postId',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) => PostDetailScreen(
                      postId: state.pathParameters['postId']!,
                    ),
                    routes: [
                      GoRoute(
                        path: 'fullscreen',
                        parentNavigatorKey: _rootNavigatorKey,
                        builder: (context, state) {
                          final postId = state.pathParameters['postId']!;
                          final post = ProviderScope.containerOf(
                            context,
                          ).read(feedPostsProvider.notifier).byId(postId);
                          final index = state.extra is int
                              ? state.extra! as int
                              : 0;
                          return FullscreenImageScreen(
                            imageUrls: post?.mediaUrls ?? const <String>[],
                            initialIndex: index,
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.events,
                builder: (context, state) => const EventsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.vendors,
                builder: (context, state) => VendorsScreen(
                  eventId: state.uri.queryParameters['eventId'],
                ),
                routes: [
                  GoRoute(
                    path: ':vendorId',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) => VendorProfileScreen(
                      vendorId: state.pathParameters['vendorId']!,
                    ),
                    routes: [
                      GoRoute(
                        path: 'contact',
                        parentNavigatorKey: _rootNavigatorKey,
                        builder: (context, state) => ContactVendorScreen(
                          vendorId: state.pathParameters['vendorId']!,
                          eventId: state.uri.queryParameters['eventId'],
                        ),
                      ),
                      GoRoute(
                        path: 'chat',
                        parentNavigatorKey: _rootNavigatorKey,
                        builder: (context, state) => VendorChatScreen(
                          vendorId: state.pathParameters['vendorId']!,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.inspiration,
                builder: (context, state) => const InspirationScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
