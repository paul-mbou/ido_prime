/// Centralized route paths and names for [GoRouter].
abstract final class AppRoutes {
  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';
  static const otp = '/otp';
  static const newPassword = '/new-password';

  static const posts = '/posts';
  static const inspiration = '/inspiration';
  static const createMoodBoard = '/inspiration/create';

  static String lookDetail(String lookId) => '/inspiration/looks/$lookId';

  static String moodBoardDetail(String boardId) =>
      '/inspiration/boards/$boardId';

  static const lookDetailPath = '/inspiration/looks/:lookId';
  static const moodBoardDetailPath = '/inspiration/boards/:boardId';

  static const events = '/events';
  static const vendors = '/vendors';
  static const profile = '/profile';
  static const editProfile = '/profile/edit';
  static const privacySecurity = '/profile/privacy';
  static const appSettings = '/profile/settings';
  static const helpCenter = '/profile/help';
  static const search = '/search';
  static const notifications = '/notifications';

  static String plannerProfile(String plannerId) => '/planners/$plannerId';

  static const plannerProfilePath = '/planners/:plannerId';

  /// Planner ↔ planner chat — only after friendship is accepted.
  static String plannerChat(String plannerId) => '/planners/$plannerId/chat';

  static const vendorOnboardingHub = '/vendor-onboarding';
  static const vendorManageProfile = '/vendor-onboarding/manage';
  static const vendorOnboardingStep1 = '/vendor-onboarding/identity';
  static const vendorOnboardingStep2 = '/vendor-onboarding/services';
  static const vendorOnboardingStep3 = '/vendor-onboarding/kyc';

  static String postDetail(String postId) => '/posts/$postId';

  static String postFullscreenImage(String postId) =>
      '/posts/$postId/fullscreen';

  static String eventDetail(String eventId) => '/events/$eventId';

  /// Path pattern for event detail (top-level, outside shell).
  static const eventDetailPath = '/events/:eventId';

  /// Create flow — distinct from `/events/:eventId`.
  static const createEvent = '/event/create';

  /// Create post — distinct from `/posts/:postId`.
  static const createPost = '/post/create';

  static String vendorProfile(String vendorId) => '/vendors/$vendorId';

  static String vendorContact(String vendorId, {String? eventId}) {
    final base = '/vendors/$vendorId/contact';
    if (eventId == null || eventId.isEmpty) return base;
    return '$base?eventId=${Uri.encodeQueryComponent(eventId)}';
  }

  /// Vendors tab, optionally scoped to an event for contact flow.
  static String vendorsForEvent(String eventId) =>
      '/vendors?eventId=${Uri.encodeQueryComponent(eventId)}';

  /// In-app chat — only after a connection request is accepted.
  static String vendorChat(String vendorId) => '/vendors/$vendorId/chat';

  /// Public auth + first-run flows (accessible without a session).
  static const authPaths = <String>{
    login,
    register,
    forgotPassword,
    otp,
    newPassword,
  };

  static const publicPaths = <String>{splash, onboarding, ...authPaths};

  /// Bottom-nav shell destinations.
  static const shellPaths = <String>{posts, inspiration, events, vendors};

  /// Routes that require a signed-in session (create, account, messaging…).
  static const authRequiredExact = <String>{
    profile,
    editProfile,
    privacySecurity,
    appSettings,
    helpCenter,
    notifications,
    createEvent,
    createPost,
    createMoodBoard,
    vendorOnboardingHub,
    vendorManageProfile,
    vendorOnboardingStep1,
    vendorOnboardingStep2,
    vendorOnboardingStep3,
  };

  /// True when a guest may open [location] without signing in.
  ///
  /// Shell tabs + browse (posts, events, vendors, inspiration, search, public
  /// planner profiles) are open. Account, create flows, and vendor chat/contact
  /// still require auth.
  static bool isGuestAccessible(String location) {
    if (publicPaths.contains(location) || shellPaths.contains(location)) {
      return true;
    }
    if (authRequiredExact.contains(location)) return false;
    if (location.startsWith('/vendor-onboarding')) return false;
    if (location.startsWith('/profile')) return false;
    if (location == createEvent ||
        location == createPost ||
        location == createMoodBoard) {
      return false;
    }
    if (location.endsWith('/contact') || location.endsWith('/chat')) {
      return false;
    }

    const browsePrefixes = <String>[
      posts,
      events,
      vendors,
      inspiration,
      search,
      '/planners',
    ];
    for (final prefix in browsePrefixes) {
      if (location == prefix || location.startsWith('$prefix/')) {
        // Inspiration create is exact-gated above; keep browsing looks/boards.
        if (location == createMoodBoard) return false;
        return true;
      }
    }
    return false;
  }
}
