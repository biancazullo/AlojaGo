import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/models/app_user.dart';

abstract class UserProfileService {
  Future<AppUser?> getUser(String id);
  Future<void> createUser(AppUser user);
  Future<void> updateUser(AppUser user);
}

class FirestoreUserProfileService implements UserProfileService {
  FirestoreUserProfileService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  @override
  Future<AppUser?> getUser(String id) async {
    final snapshot = await _users.doc(id).get();
    if (!snapshot.exists) return null;
    final data = snapshot.data() ?? const {};
    final profile = Map<String, dynamic>.from(data['profile'] ?? const {});
    return AppUser.fromProfileMap(id, profile);
  }

  @override
  Future<void> createUser(AppUser user) {
    return _users.doc(user.id).set({
      'profile': user.toProfileMap(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> updateUser(AppUser user) {
    return _users.doc(user.id).update({
      'profile': user.toProfileMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
