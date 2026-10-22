/// Planner vs Vendor workspace.
enum ActiveSpace { planner, vendor }

enum VendorBusinessStatus {
  draft,
  pendingReview,
  approved,
  rejected,
  needsInfo,
}

enum KycStatus { none, submitted, approved, rejected }

enum VendorAvailability { weekdays, weekends, flexible, byAppointment }

extension VendorAvailabilityLabel on VendorAvailability {
  String get label => switch (this) {
    VendorAvailability.weekdays => 'Weekdays',
    VendorAvailability.weekends => 'Weekends',
    VendorAvailability.flexible => 'Flexible',
    VendorAvailability.byAppointment => 'By appointment',
  };
}

class VendorServiceOffer {
  const VendorServiceOffer({required this.name, required this.priceLabel});

  final String name;
  final String priceLabel;

  Map<String, dynamic> toJson() => {'name': name, 'priceLabel': priceLabel};

  factory VendorServiceOffer.fromJson(Map<String, dynamic> json) {
    return VendorServiceOffer(
      name: json['name'] as String? ?? '',
      priceLabel: json['priceLabel'] as String? ?? '',
    );
  }
}

/// Past event photo used as social proof on the vendor vitrine.
class VendorGalleryItem {
  const VendorGalleryItem({
    required this.imageUrl,
    this.caption = '',
    this.eventName = '',
  });

  final String imageUrl;
  final String caption;
  final String eventName;

  Map<String, dynamic> toJson() => {
    'imageUrl': imageUrl,
    'caption': caption,
    'eventName': eventName,
  };

  factory VendorGalleryItem.fromJson(Map<String, dynamic> json) {
    return VendorGalleryItem(
      imageUrl: json['imageUrl'] as String? ?? '',
      caption: json['caption'] as String? ?? '',
      eventName: json['eventName'] as String? ?? '',
    );
  }
}

class VendorBusiness {
  const VendorBusiness({
    required this.id,
    required this.userId,
    required this.status,
    this.displayName = '',
    this.photoUrl = '',
    this.country = '',
    this.availability = VendorAvailability.flexible,
    this.services = const [],
    this.modalities = '',
    this.bio = '',
    this.category = '',
    this.phone = '',
    this.email = '',
    this.gallery = const [],
    this.kycStatus = KycStatus.none,
    this.idDocumentLabel = '',
    this.businessDocumentLabel = '',
    this.step1CompletedAt,
    this.step2CompletedAt,
    this.step3CompletedAt,
    this.boReviewedAt,
    this.boNotes = '',
  });

  final String id;
  final String userId;
  final VendorBusinessStatus status;
  final String displayName;
  final String photoUrl;
  final String country;
  final VendorAvailability availability;
  final List<VendorServiceOffer> services;
  final String modalities;
  final String bio;
  final String category;
  final String phone;
  final String email;
  final List<VendorGalleryItem> gallery;
  final KycStatus kycStatus;
  final String idDocumentLabel;
  final String businessDocumentLabel;
  final DateTime? step1CompletedAt;
  final DateTime? step2CompletedAt;
  final DateTime? step3CompletedAt;
  final DateTime? boReviewedAt;
  final String boNotes;

  factory VendorBusiness.empty({String userId = 'local'}) {
    return VendorBusiness(
      id: 'biz_$userId',
      userId: userId,
      status: VendorBusinessStatus.draft,
      photoUrl:
          'https://images.unsplash.com/photo-1555244162-803834f70033?w=400&q=80',
      category: 'Catering',
    );
  }

  bool get step1Done =>
      step1CompletedAt != null ||
      (displayName.trim().isNotEmpty &&
          country.trim().isNotEmpty &&
          photoUrl.trim().isNotEmpty);

  bool get step2Done =>
      step2CompletedAt != null ||
      (services.isNotEmpty &&
          services.every(
            (s) => s.name.trim().isNotEmpty && s.priceLabel.trim().isNotEmpty,
          ) &&
          modalities.trim().isNotEmpty);

  bool get step3Done =>
      step3CompletedAt != null ||
      (kycStatus == KycStatus.submitted ||
          kycStatus == KycStatus.approved ||
          (idDocumentLabel.isNotEmpty && businessDocumentLabel.isNotEmpty));

  int get completedStepCount =>
      (step1Done ? 1 : 0) + (step2Done ? 1 : 0) + (step3Done ? 1 : 0);

  bool get allStepsComplete => step1Done && step2Done && step3Done;

  bool get canOfferServices =>
      allStepsComplete && status == VendorBusinessStatus.approved;

  bool get hasStarted =>
      displayName.isNotEmpty ||
      country.isNotEmpty ||
      services.isNotEmpty ||
      modalities.isNotEmpty ||
      idDocumentLabel.isNotEmpty ||
      gallery.isNotEmpty ||
      bio.isNotEmpty ||
      step1CompletedAt != null ||
      step2CompletedAt != null ||
      step3CompletedAt != null;

  String get progressHeadline {
    if (status == VendorBusinessStatus.pendingReview) {
      return 'Vendor profile · Under IDO review';
    }
    if (status == VendorBusinessStatus.approved) {
      return 'Vendor profile · Live';
    }
    if (status == VendorBusinessStatus.rejected) {
      return 'Vendor profile · Needs attention';
    }
    if (status == VendorBusinessStatus.needsInfo) {
      return 'Vendor profile · Info requested';
    }
    if (!hasStarted) return 'Become a vendor · Start your profile';
    final next = !step1Done
        ? 1
        : !step2Done
        ? 2
        : !step3Done
        ? 3
        : 3;
    return 'Vendor profile · Step $next/3';
  }

  String get progressSubtitle {
    if (status == VendorBusinessStatus.pendingReview) {
      return 'Field verification by the IDO team — you will be notified.';
    }
    if (status == VendorBusinessStatus.approved) {
      return 'You can offer services and appear in discovery.';
    }
    if (status == VendorBusinessStatus.rejected ||
        status == VendorBusinessStatus.needsInfo) {
      return boNotes.isEmpty ? 'Open your checklist to continue.' : boNotes;
    }
    if (!step1Done) return 'Add business name, photo, availability & country';
    if (!step2Done) return 'Add services, prices & modalities';
    if (!step3Done) return 'Submit KYC / KYB documents';
    return 'Waiting for IDO back-office approval';
  }

  VendorBusiness copyWith({
    VendorBusinessStatus? status,
    String? displayName,
    String? photoUrl,
    String? country,
    VendorAvailability? availability,
    List<VendorServiceOffer>? services,
    String? modalities,
    String? bio,
    String? category,
    String? phone,
    String? email,
    List<VendorGalleryItem>? gallery,
    KycStatus? kycStatus,
    String? idDocumentLabel,
    String? businessDocumentLabel,
    DateTime? step1CompletedAt,
    DateTime? step2CompletedAt,
    DateTime? step3CompletedAt,
    DateTime? boReviewedAt,
    String? boNotes,
    bool clearStep1 = false,
    bool clearStep2 = false,
    bool clearStep3 = false,
  }) {
    return VendorBusiness(
      id: id,
      userId: userId,
      status: status ?? this.status,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      country: country ?? this.country,
      availability: availability ?? this.availability,
      services: services ?? this.services,
      modalities: modalities ?? this.modalities,
      bio: bio ?? this.bio,
      category: category ?? this.category,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      gallery: gallery ?? this.gallery,
      kycStatus: kycStatus ?? this.kycStatus,
      idDocumentLabel: idDocumentLabel ?? this.idDocumentLabel,
      businessDocumentLabel:
          businessDocumentLabel ?? this.businessDocumentLabel,
      step1CompletedAt: clearStep1
          ? null
          : (step1CompletedAt ?? this.step1CompletedAt),
      step2CompletedAt: clearStep2
          ? null
          : (step2CompletedAt ?? this.step2CompletedAt),
      step3CompletedAt: clearStep3
          ? null
          : (step3CompletedAt ?? this.step3CompletedAt),
      boReviewedAt: boReviewedAt ?? this.boReviewedAt,
      boNotes: boNotes ?? this.boNotes,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'status': status.name,
    'displayName': displayName,
    'photoUrl': photoUrl,
    'country': country,
    'availability': availability.name,
    'services': services.map((s) => s.toJson()).toList(),
    'modalities': modalities,
    'bio': bio,
    'category': category,
    'phone': phone,
    'email': email,
    'gallery': gallery.map((g) => g.toJson()).toList(),
    'kycStatus': kycStatus.name,
    'idDocumentLabel': idDocumentLabel,
    'businessDocumentLabel': businessDocumentLabel,
    'step1CompletedAt': step1CompletedAt?.toIso8601String(),
    'step2CompletedAt': step2CompletedAt?.toIso8601String(),
    'step3CompletedAt': step3CompletedAt?.toIso8601String(),
    'boReviewedAt': boReviewedAt?.toIso8601String(),
    'boNotes': boNotes,
  };

  factory VendorBusiness.fromJson(Map<String, dynamic> json) {
    return VendorBusiness(
      id: json['id'] as String? ?? 'biz_local',
      userId: json['userId'] as String? ?? 'local',
      status: VendorBusinessStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => VendorBusinessStatus.draft,
      ),
      displayName: json['displayName'] as String? ?? '',
      photoUrl: json['photoUrl'] as String? ?? '',
      country: json['country'] as String? ?? '',
      availability: VendorAvailability.values.firstWhere(
        (e) => e.name == json['availability'],
        orElse: () => VendorAvailability.flexible,
      ),
      services: (json['services'] as List<dynamic>? ?? [])
          .map(
            (e) => VendorServiceOffer.fromJson(
              Map<String, dynamic>.from(e as Map),
            ),
          )
          .toList(),
      modalities: json['modalities'] as String? ?? '',
      bio: json['bio'] as String? ?? '',
      category: json['category'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String? ?? '',
      gallery: (json['gallery'] as List<dynamic>? ?? [])
          .map(
            (e) =>
                VendorGalleryItem.fromJson(Map<String, dynamic>.from(e as Map)),
          )
          .toList(),
      kycStatus: KycStatus.values.firstWhere(
        (e) => e.name == json['kycStatus'],
        orElse: () => KycStatus.none,
      ),
      idDocumentLabel: json['idDocumentLabel'] as String? ?? '',
      businessDocumentLabel: json['businessDocumentLabel'] as String? ?? '',
      step1CompletedAt: _parseDate(json['step1CompletedAt']),
      step2CompletedAt: _parseDate(json['step2CompletedAt']),
      step3CompletedAt: _parseDate(json['step3CompletedAt']),
      boReviewedAt: _parseDate(json['boReviewedAt']),
      boNotes: json['boNotes'] as String? ?? '',
    );
  }

  static DateTime? _parseDate(Object? value) {
    if (value is! String || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }
}
