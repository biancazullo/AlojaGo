// lib/domain/models/listing.dart
// Agrega maxReservations y currentReservations al modelo

class ListingReview {
  const ListingReview({
    required this.author,
    required this.rating,
    required this.comment,
    this.operatorReply,
  });

  final String author;
  final int rating;
  final String comment;
  final String? operatorReply; // Respuesta del operador a la reseña

  ListingReview copyWith({String? operatorReply}) {
    return ListingReview(
      author: author,
      rating: rating,
      comment: comment,
      operatorReply: operatorReply ?? this.operatorReply,
    );
  }
}

enum ListingStatus { active, paused, pendingApproval, rejected }

class AlojaListing {
  const AlojaListing({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.city,
    required this.region,
    required this.nightlyPrice,
    required this.maxGuests,
    required this.imageUrl,
    required this.tag,
    required this.rating,
    required this.reviews,
    this.status = ListingStatus.pendingApproval,
    this.maxReservations = 0,      // ← NUEVO: cantidad máx de reservas (0=sin límite)
    this.currentReservations = 0,  // ← NUEVO: reservas actuales
    this.accommodationType = '',   // tipo de hospedaje
    this.category = '',            // categoría
  });

  final String id;
  final String ownerId;
  final String title;
  final String city;
  final String region;
  final int nightlyPrice;
  final int maxGuests;
  final String imageUrl;
  final String tag;
  final double rating;
  final List<ListingReview> reviews;
  final ListingStatus status;
  final int maxReservations;
  final int currentReservations;
  final String accommodationType;
  final String category;

  String get priceLabel => '\$$nightlyPrice/noche';

  bool get hasAvailability =>
      maxReservations == 0 || currentReservations < maxReservations;

  int get availableSlots =>
      maxReservations == 0 ? 999 : maxReservations - currentReservations;

  bool matchesSearch({String destination = '', int? maxPrice, int? guests}) {
    final normalizedDestination = destination.trim().toLowerCase();
    final matchesDestination =
        normalizedDestination.isEmpty ||
        city.toLowerCase().contains(normalizedDestination) ||
        region.toLowerCase().contains(normalizedDestination) ||
        title.toLowerCase().contains(normalizedDestination);
    final matchesPrice = maxPrice == null || nightlyPrice <= maxPrice;
    final matchesGuests = guests == null || maxGuests >= guests;
    return status == ListingStatus.active &&
        matchesDestination &&
        matchesPrice &&
        matchesGuests;
  }

  AlojaListing addReview(ListingReview review) {
    final updatedReviews = List<ListingReview>.from(reviews)..add(review);
    final totalRating =
        updatedReviews.fold(0.0, (sum, r) => sum + r.rating) /
        updatedReviews.length;
    return copyWith(reviews: updatedReviews, rating: totalRating);
  }

  AlojaListing copyWith({
    String? id,
    String? ownerId,
    String? title,
    String? city,
    String? region,
    int? nightlyPrice,
    int? maxGuests,
    String? imageUrl,
    String? tag,
    double? rating,
    List<ListingReview>? reviews,
    ListingStatus? status,
    int? maxReservations,
    int? currentReservations,
    String? accommodationType,
    String? category,
  }) {
    return AlojaListing(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      title: title ?? this.title,
      city: city ?? this.city,
      region: region ?? this.region,
      nightlyPrice: nightlyPrice ?? this.nightlyPrice,
      maxGuests: maxGuests ?? this.maxGuests,
      imageUrl: imageUrl ?? this.imageUrl,
      tag: tag ?? this.tag,
      rating: rating ?? this.rating,
      reviews: reviews ?? this.reviews,
      status: status ?? this.status,
      maxReservations: maxReservations ?? this.maxReservations,
      currentReservations: currentReservations ?? this.currentReservations,
      accommodationType: accommodationType ?? this.accommodationType,
      category: category ?? this.category,
    );
  }
}
