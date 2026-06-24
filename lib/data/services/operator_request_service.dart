import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/models/app_user.dart';
import '../../domain/models/operator_request.dart';

class OperatorRequestService {
  OperatorRequestService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _requests =>
      _firestore.collection('operator_requests');

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  Stream<List<OperatorRequest>> watchRequests() {
    return _requests
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => OperatorRequest.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Stream<OperatorRequest?> watchLatestForUser(String userId) {
    return _requests
        .where('userId', isEqualTo: userId)
        .limit(1)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) return null;
          final doc = snapshot.docs.first;
          return OperatorRequest.fromMap(doc.id, doc.data());
        });
  }

  Future<void> submit(AppUser user) async {
    final existing = await _requests
        .where('userId', isEqualTo: user.id)
        .where('status', isEqualTo: OperatorRequestStatus.pending.name)
        .limit(1)
        .get();
    if (existing.docs.isNotEmpty) return;

    await _requests.add({
      ...OperatorRequest(
        id: '',
        userId: user.id,
        email: user.email,
        name: user.name,
      ).toMap(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await _users.doc(user.id).set({
      'profile': {'operatorRequestStatus': OperatorRequestStatus.pending.name},
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> approve(OperatorRequest request, String pin) async {
    final cleanPin = pin.trim();
    final userRef = _users.doc(request.userId);
    final requestRef = _requests.doc(request.id);

    await _firestore.runTransaction((transaction) async {
      transaction.set(requestRef, {
        'status': OperatorRequestStatus.approved.name,
        'operatorPin': cleanPin,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      transaction.set(userRef, {
        'profile': {
          'role': UserRole.operator.name,
          'operatorPin': cleanPin,
          'hasUnreadOperatorPin': true,
          'operatorRequestStatus': OperatorRequestStatus.approved.name,
        },
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    });
  }

  Future<void> reject(OperatorRequest request) async {
    final userRef = _users.doc(request.userId);
    final requestRef = _requests.doc(request.id);

    await _firestore.runTransaction((transaction) async {
      transaction.set(requestRef, {
        'status': OperatorRequestStatus.rejected.name,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      transaction.set(userRef, {
        'profile': {
          'operatorRequestStatus': OperatorRequestStatus.rejected.name,
        },
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    });
  }

  Future<void> markOperatorPinSeen(String userId) {
    return _users.doc(userId).set({
      'profile': {'hasUnreadOperatorPin': false},
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
