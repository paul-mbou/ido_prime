import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ido_prime/src/features/profile/models/privacy_security_settings.dart';

final privacySecurityProvider =
    NotifierProvider<PrivacySecurityNotifier, PrivacySecuritySettings>(
      PrivacySecurityNotifier.new,
    );

class PrivacySecurityNotifier extends Notifier<PrivacySecuritySettings> {
  @override
  PrivacySecuritySettings build() => const PrivacySecuritySettings();

  void setTwoFactorEnabled(bool value) {
    state = state.copyWith(twoFactorEnabled: value);
  }

  void setAppLockEnabled(bool value) {
    state = state.copyWith(appLockEnabled: value);
  }

  void setPrivateProfile(bool value) {
    state = state.copyWith(privateProfile: value);
  }

  void setShowActivity(bool value) {
    state = state.copyWith(showActivity: value);
  }

  void setAllowTagging(bool value) {
    state = state.copyWith(allowTagging: value);
  }

  void setWhoCanMessage(WhoCanMessage value) {
    state = state.copyWith(whoCanMessage: value);
  }
}
