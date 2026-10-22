import 'dart:convert';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ido_prime/src/features/vendor_onboarding/models/vendor_business.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _bizKey = 'ido_vendor_business_v1';
const _spaceKey = 'ido_active_space_v1';

final activeSpaceProvider = NotifierProvider<ActiveSpaceNotifier, ActiveSpace>(
  ActiveSpaceNotifier.new,
);

class ActiveSpaceNotifier extends Notifier<ActiveSpace> {
  @override
  ActiveSpace build() {
    Future.microtask(_hydrate);
    return ActiveSpace.planner;
  }

  Future<void> _hydrate() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_spaceKey);
    if (raw == null) return;
    state = ActiveSpace.values.firstWhere(
      (e) => e.name == raw,
      orElse: () => ActiveSpace.planner,
    );
  }

  Future<void> setSpace(ActiveSpace space) async {
    state = space;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_spaceKey, space.name);
  }
}

final vendorBusinessProvider =
    NotifierProvider<VendorBusinessNotifier, VendorBusiness>(
      VendorBusinessNotifier.new,
    );

class VendorBusinessNotifier extends Notifier<VendorBusiness> {
  @override
  VendorBusiness build() {
    Future.microtask(_hydrate);
    return VendorBusiness.empty();
  }

  Future<void> _hydrate() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_bizKey);
    if (raw == null) return;
    try {
      state = VendorBusiness.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      // Keep empty draft on corrupt cache.
    }
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_bizKey, jsonEncode(state.toJson()));
  }

  Future<void> update(
    VendorBusiness Function(VendorBusiness current) fn,
  ) async {
    state = fn(state);
    await _persist();
  }

  Future<void> saveStep1({
    required String displayName,
    required String photoUrl,
    required String country,
    required VendorAvailability availability,
  }) async {
    final complete =
        displayName.trim().isNotEmpty &&
        photoUrl.trim().isNotEmpty &&
        country.trim().isNotEmpty;
    await update(
      (b) => b.copyWith(
        displayName: displayName.trim(),
        photoUrl: photoUrl.trim(),
        country: country.trim(),
        availability: availability,
        step1CompletedAt: complete ? DateTime.now() : null,
        clearStep1: !complete,
        status: b.status == VendorBusinessStatus.approved
            ? b.status
            : VendorBusinessStatus.draft,
      ),
    );
  }

  Future<void> saveStep2({
    required List<VendorServiceOffer> services,
    required String modalities,
  }) async {
    final complete =
        services.isNotEmpty &&
        services.every(
          (s) => s.name.trim().isNotEmpty && s.priceLabel.trim().isNotEmpty,
        ) &&
        modalities.trim().isNotEmpty;
    await update(
      (b) => b.copyWith(
        services: services,
        modalities: modalities.trim(),
        step2CompletedAt: complete ? DateTime.now() : null,
        clearStep2: !complete,
        status: b.status == VendorBusinessStatus.approved
            ? b.status
            : VendorBusinessStatus.draft,
      ),
    );
  }

  Future<void> saveStep3({
    required String idDocumentLabel,
    required String businessDocumentLabel,
    required bool submitForReview,
  }) async {
    final docsOk =
        idDocumentLabel.trim().isNotEmpty &&
        businessDocumentLabel.trim().isNotEmpty;
    await update((b) {
      final next = b.copyWith(
        idDocumentLabel: idDocumentLabel.trim(),
        businessDocumentLabel: businessDocumentLabel.trim(),
        kycStatus: submitForReview && docsOk
            ? KycStatus.submitted
            : (docsOk ? KycStatus.submitted : KycStatus.none),
        step3CompletedAt: docsOk ? DateTime.now() : null,
        clearStep3: !docsOk,
        status: submitForReview && docsOk && b.step1Done && b.step2Done
            ? VendorBusinessStatus.pendingReview
            : (b.status == VendorBusinessStatus.approved
                  ? b.status
                  : VendorBusinessStatus.draft),
      );
      // Recompute step1/2 from fields for gate when submitting.
      if (submitForReview && docsOk && next.step1Done && next.step2Done) {
        return next.copyWith(status: VendorBusinessStatus.pendingReview);
      }
      return next;
    });
  }

  /// Debug / stub until real back-office exists.
  Future<void> stubApprove() async {
    await update(
      (b) => b.copyWith(
        status: VendorBusinessStatus.approved,
        kycStatus: KycStatus.approved,
        boReviewedAt: DateTime.now(),
        boNotes: '',
        step1CompletedAt: b.step1CompletedAt ?? DateTime.now(),
        step2CompletedAt: b.step2CompletedAt ?? DateTime.now(),
        step3CompletedAt: b.step3CompletedAt ?? DateTime.now(),
      ),
    );
  }

  Future<void> stubReject({
    String notes = 'Please update your documents.',
  }) async {
    await update(
      (b) => b.copyWith(
        status: VendorBusinessStatus.needsInfo,
        kycStatus: KycStatus.rejected,
        boNotes: notes,
        boReviewedAt: DateTime.now(),
      ),
    );
  }

  Future<void> ensureDraftStarted() async {
    if (state.hasStarted) return;
    await _persist();
  }

  Future<void> updateProfilePicture(String photoUrl) async {
    await update((b) => b.copyWith(photoUrl: photoUrl.trim()));
  }

  Future<void> updateBioAndContact({
    required String bio,
    required String category,
    required String phone,
    required String email,
  }) async {
    await update(
      (b) => b.copyWith(
        bio: bio.trim(),
        category: category.trim(),
        phone: phone.trim(),
        email: email.trim(),
      ),
    );
  }

  Future<void> updateGallery(List<VendorGalleryItem> gallery) async {
    await update((b) => b.copyWith(gallery: gallery));
  }

  Future<void> addGalleryItem(VendorGalleryItem item) async {
    await update((b) => b.copyWith(gallery: [...b.gallery, item]));
  }

  Future<void> removeGalleryItemAt(int index) async {
    await update((b) {
      if (index < 0 || index >= b.gallery.length) return b;
      final next = List<VendorGalleryItem>.from(b.gallery)..removeAt(index);
      return b.copyWith(gallery: next);
    });
  }
}

final canOfferServicesProvider = Provider<bool>((ref) {
  return ref.watch(vendorBusinessProvider).canOfferServices;
});
