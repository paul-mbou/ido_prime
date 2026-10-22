class UserAccountProfile {
  const UserAccountProfile({
    required this.id,
    required this.displayName,
    required this.email,
    required this.avatarUrl,
    this.phone = '',
    this.location = '',
    this.bio = '',
    this.role = 'Planner',
  });

  final String id;
  final String displayName;
  final String email;
  final String avatarUrl;
  final String phone;
  final String location;
  final String bio;
  final String role;

  UserAccountProfile copyWith({
    String? displayName,
    String? email,
    String? avatarUrl,
    String? phone,
    String? location,
    String? bio,
    String? role,
  }) {
    return UserAccountProfile(
      id: id,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      bio: bio ?? this.bio,
      role: role ?? this.role,
    );
  }
}

const defaultUserAccount = UserAccountProfile(
  id: 'emma',
  displayName: 'Emma Thompson',
  email: 'emma.thompson@email.com',
  avatarUrl:
      'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200&h=200&fit=crop',
  phone: '+237 6 70 00 00 00',
  location: 'Douala',
  bio:
      'Planning celebrations with calm details and warm light. '
      'Currently prepping a soft-peach September wedding.',
  role: 'Planner',
);
