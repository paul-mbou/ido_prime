import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ido_prime/src/core/app_enums.dart';
import 'package:ido_prime/src/features/auth/data/auth_repository.dart';

final authNotifierProvider =
    AsyncNotifierProvider.autoDispose<AuthNotifier, AppAuthState>(
      AuthNotifier.new,
    );

class AuthNotifier extends AsyncNotifier<AppAuthState> {
  @override
  FutureOr<AppAuthState> build() => AppAuthState.idle;

  Future<void> login({required String email, required String password}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(authRepositoryProvider)
          .signIn(email: email, password: password);
      return AppAuthState.userLoggedIn;
    }, (error) => error is AppAuthException);
  }

  Future<void> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(authRepositoryProvider)
          .signUp(
            email: email,
            password: password,
            data: {'fullName': fullName},
          );
      return AppAuthState.userSignedUp;
    }, (error) => error is AppAuthException);
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(authRepositoryProvider).signOut();
      return AppAuthState.idle;
    }, (error) => error is AppAuthException);
  }
}
