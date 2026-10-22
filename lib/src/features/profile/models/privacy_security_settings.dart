enum WhoCanMessage { everyone, friends, nobody }

class PrivacySecuritySettings {
  const PrivacySecuritySettings({
    this.twoFactorEnabled = false,
    this.appLockEnabled = false,
    this.privateProfile = false,
    this.showActivity = true,
    this.allowTagging = true,
    this.whoCanMessage = WhoCanMessage.friends,
  });

  final bool twoFactorEnabled;
  final bool appLockEnabled;
  final bool privateProfile;
  final bool showActivity;
  final bool allowTagging;
  final WhoCanMessage whoCanMessage;

  PrivacySecuritySettings copyWith({
    bool? twoFactorEnabled,
    bool? appLockEnabled,
    bool? privateProfile,
    bool? showActivity,
    bool? allowTagging,
    WhoCanMessage? whoCanMessage,
  }) {
    return PrivacySecuritySettings(
      twoFactorEnabled: twoFactorEnabled ?? this.twoFactorEnabled,
      appLockEnabled: appLockEnabled ?? this.appLockEnabled,
      privateProfile: privateProfile ?? this.privateProfile,
      showActivity: showActivity ?? this.showActivity,
      allowTagging: allowTagging ?? this.allowTagging,
      whoCanMessage: whoCanMessage ?? this.whoCanMessage,
    );
  }
}
