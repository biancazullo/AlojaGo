enum UserRole { guest, traveler, host, admin }

class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    this.phone = '',
    this.gender = '',
    this.birthday = '',
    this.profileImage = '',
    this.role = UserRole.traveler,
  });

  final String id;
  final String name;
  final String email;
  final String phone;
  final String gender;
  final String birthday;
  final String profileImage;
  final UserRole role;

  String get firstName {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) return '';
    return trimmedName.split(RegExp(r'\s+')).first;
  }

  Map<String, String> toProfileMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'gender': gender,
      'birthday': birthday,
      'profileImage': profileImage,
      'role': role.name,
    };
  }

  factory AppUser.fromProfileMap(String id, Map<String, dynamic> profile) {
    return AppUser(
      id: id,
      name: (profile['name'] ?? '').toString(),
      email: (profile['email'] ?? '').toString(),
      phone: (profile['phone'] ?? '').toString(),
      gender: (profile['gender'] ?? '').toString(),
      birthday: (profile['birthday'] ?? '').toString(),
      profileImage: (profile['profileImage'] ?? '').toString(),
      role: UserRole.values.firstWhere(
        (role) => role.name == profile['role'],
        orElse: () => UserRole.traveler,
      ),
    );
  }

  AppUser copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? gender,
    String? birthday,
    String? profileImage,
    UserRole? role,
  }) {
    return AppUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      gender: gender ?? this.gender,
      birthday: birthday ?? this.birthday,
      profileImage: profileImage ?? this.profileImage,
      role: role ?? this.role,
    );
  }
}
