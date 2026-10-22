import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ido_prime/src/core/app_exception_handler.dart';
import 'package:ido_prime/src/core/app_logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabaseClientProvider = Provider.autoDispose<SupabaseClient>(
  (ref) => Supabase.instance.client,
);
final authRepositoryProvider = Provider.autoDispose<AuthRepository>(
  (ref) => AuthRepository(supabase: ref.watch(supabaseClientProvider)),
);

class AuthRepository {
  AuthRepository({required this._supabase});
  final SupabaseClient _supabase;

  Future<void> signIn({required String email, required String password}) async {
    try {
      final authResponse = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      logInfo('Sign in response [session]: ${authResponse.session}');
      logInfo('Sign in response [user]: ${authResponse.user}');
      // if (authResponse.session == null || authResponse.user == null) {
      //   throw AppAuthException.unknownError;
      // }
      // if (authResponse.session?.isExpired ?? true) {
      //   throw AppAuthException.sessionExpired;
      // }
    } on Exception catch (exception) {
      throw AppExceptionHandler.handleAuthException(exception);
    }
  }

  Future<void> signUp({
    required Map<String, dynamic> data,
    required String email,
    required String password,
  }) async {
    try {
      final authResponse = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: data,
      );
      logInfo('Sign up new user response: $authResponse');
    } on Exception catch (exception) {
      throw AppExceptionHandler.handleAuthException(exception);
    }
  }

  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
      logInfo('User signed out');
    } on Exception catch (exception) {
      throw AppExceptionHandler.handleAuthException(exception);
    }
  }
}
