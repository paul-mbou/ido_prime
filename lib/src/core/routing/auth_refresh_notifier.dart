import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Notifies [GoRouter] when the Supabase auth session changes.
class AuthRefreshNotifier extends ChangeNotifier {
  AuthRefreshNotifier(this._client) {
    _subscription = _client.auth.onAuthStateChange.listen((_) {
      notifyListeners();
    });
  }

  final SupabaseClient _client;
  late final StreamSubscription<AuthState> _subscription;

  bool get isLoggedIn => _client.auth.currentSession != null;

  @override
  void dispose() {
    unawaited(_subscription.cancel());
    super.dispose();
  }
}
