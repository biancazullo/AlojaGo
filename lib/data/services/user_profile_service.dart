import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/models/app_user.dart';

abstract class UserProfileService {
  Future<AppUser?> getUser(String id);
  Stream<List<AppUser>> watchUsers();
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
    final profile = _profileFromData(data);
    return AppUser.fromProfileMap(id, profile);
  }

  @override
  Stream<List<AppUser>> watchUsers() {
    return _users.orderBy('createdAt', descending: true).snapshots().map((
      snapshot,
    ) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return AppUser.fromProfileMap(doc.id, _profileFromData(data));
      }).toList();
    });
  }

  @override
  Future<void> createUser(AppUser user) {
    return _users.doc(user.id).set({
      'profile': user.toFirestoreMap(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> updateUser(AppUser user) {
    return _users.doc(user.id).set({
      'profile': user.toFirestoreMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Map<String, dynamic> _profileFromData(Map<String, dynamic> data) {
    final profile = Map<String, dynamic>.from(data['profile'] ?? const {});
    if (profile.isNotEmpty) return profile;
    return Map<String, dynamic>.from(data);
  }
}
