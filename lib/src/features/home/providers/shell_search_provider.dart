import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Shared search query for the main shell app bar (cleared on tab change).
final shellSearchQueryProvider =
    NotifierProvider<ShellSearchQueryNotifier, String>(
      ShellSearchQueryNotifier.new,
    );

class ShellSearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String value) => state = value;

  void clear() => state = '';
}

String shellSearchHintForTab(int tabIndex) => switch (tabIndex) {
  0 => 'Search feed…',
  1 => 'Search events…',
  2 => 'Search vendors…',
  3 => 'Search inspiration…',
  _ => 'Search…',
};
