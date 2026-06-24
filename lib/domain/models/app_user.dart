// lib/domain/models/app_user.dart
// Roles: traveler (viajero), operator (operador turístico), admin (administrador)

enum UserRole { guest, traveler, operator, admin }

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
    this.operatorPin = '',
    this.hasUnreadOperatorPin = false,
    this.operatorRequestStatus = '',
  });

  final String id;
  final String name;
  final String email;
  final String phone;
  final String gender;
  final String birthday;
  final String profileImage;
  final UserRole role;
  final String operatorPin;
  final bool hasUnreadOperatorPin;
  final String operatorRequestStatus;

  bool get isTraveler => role == UserRole.traveler;
  bool get isOperator => role == UserRole.operator;
  bool get isAdmin => role == UserRole.admin;

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
      'operatorPin': operatorPin,
      'hasUnreadOperatorPin': hasUnreadOperatorPin.toString(),
      'operatorRequestStatus': operatorRequestStatus,
    };
  }

  Map<String, dynamic> toFirestoreMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'gender': gender,
      'birthday': birthday,
      'profileImage': profileImage,
      'role': role.name,
      'operatorPin': operatorPin,
      'hasUnreadOperatorPin': hasUnreadOperatorPin,
      'operatorRequestStatus': operatorRequestStatus,
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
        (r) => r.name == profile['role'],
        orElse: () => UserRole.traveler,
      ),
      operatorPin: (profile['operatorPin'] ?? '').toString(),
      hasUnreadOperatorPin:
          profile['hasUnreadOperatorPin'] == true ||
          profile['hasUnreadOperatorPin'].toString() == 'true',
      operatorRequestStatus: (profile['operatorRequestStatus'] ?? '')
          .toString(),
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
    String? operatorPin,
    bool? hasUnreadOperatorPin,
    String? operatorRequestStatus,
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
      operatorPin: operatorPin ?? this.operatorPin,
      hasUnreadOperatorPin: hasUnreadOperatorPin ?? this.hasUnreadOperatorPin,
      operatorRequestStatus:
          operatorRequestStatus ?? this.operatorRequestStatus,
    );
  }
}
