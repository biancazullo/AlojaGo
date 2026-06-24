import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/models/listing.dart';

class ListingService {
  ListingService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _listings =>
      _firestore.collection('listings');

  Stream<List<AlojaListing>> watchListings() {
    return _listings
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => AlojaListing.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Future<void> saveListing(AlojaListing listing) {
    return _listings.doc(listing.id).set({
      ...listing.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> deleteListing(String id) {
    return _listings.doc(id).delete();
  }

  Future<void> seedIfEmpty(List<AlojaListing> seedListings) async {
    final snapshot = await _listings.limit(1).get();
    if (snapshot.docs.isNotEmpty) return;
    final batch = _firestore.batch();
    for (final listing in seedListings) {
      batch.set(_listings.doc(listing.id), {
        ...listing.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }
}
