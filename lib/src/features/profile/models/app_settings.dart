/// Device-level preferences for feed media and interaction feel.
class AppSettings {
  const AppSettings({
    this.autoplayVideos = true,
    this.reduceDataUsage = false,
    this.hapticFeedback = true,
  });

  /// Play feed / reel videos as they come into view (muted).
  final bool autoplayVideos;

  /// Prefer smaller / deferred media loads on cellular.
  final bool reduceDataUsage;

  /// Light taps on likes, switches, and primary actions.
  final bool hapticFeedback;

  AppSettings copyWith({
    bool? autoplayVideos,
    bool? reduceDataUsage,
    bool? hapticFeedback,
  }) {
    return AppSettings(
      autoplayVideos: autoplayVideos ?? this.autoplayVideos,
      reduceDataUsage: reduceDataUsage ?? this.reduceDataUsage,
      hapticFeedback: hapticFeedback ?? this.hapticFeedback,
    );
  }
}
