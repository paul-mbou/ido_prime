import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ido_prime/src/features/profile/models/user_account_profile.dart';

final userAccountProvider =
    NotifierProvider<UserAccountNotifier, UserAccountProfile>(
      UserAccountNotifier.new,
    );

class UserAccountNotifier extends Notifier<UserAccountProfile> {
  @override
  UserAccountProfile build() => defaultUserAccount;

  void updateProfile({
    required String displayName,
    required String email,
    required String avatarUrl,
    required String phone,
    required String location,
    required String bio,
    required String role,
  }) {
    state = state.copyWith(
      displayName: displayName.trim(),
      email: email.trim(),
      avatarUrl: avatarUrl.trim(),
      phone: phone.trim(),
      location: location.trim(),
      bio: bio.trim(),
      role: role.trim().isEmpty ? 'Planner' : role.trim(),
    );
  }
}
