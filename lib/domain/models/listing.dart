class ListingReview {
  const ListingReview({
    required this.author,
    required this.rating,
    required this.comment,
  });

  final String author;
  final int rating;
  final String comment;
}

enum ListingStatus { active, paused }

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
    this.status = ListingStatus.active,
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

  String get priceLabel => '\$$nightlyPrice/noche';

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
    );
  }

  AlojaListing addReview(ListingReview review) {
    final nextReviews = [...reviews, review];
    final total = nextReviews.fold<double>(0, (sum, item) => sum + item.rating);
    return copyWith(
      reviews: nextReviews,
      rating: double.parse((total / nextReviews.length).toStringAsFixed(1)),
    );
  }
}
