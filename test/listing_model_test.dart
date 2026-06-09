import 'package:flutter_test/flutter_test.dart';
import 'package:proyec/domain/models/listing.dart';

void main() {
  const listing = AlojaListing(
    id: 'merida-1',
    ownerId: 'host-1',
    title: 'Cabana familiar andina',
    city: 'Merida',
    region: 'Estado Merida',
    nightlyPrice: 40,
    maxGuests: 5,
    imageUrl: 'https://example.com/image.jpg',
    tag: 'Nuevo',
    rating: 4,
    reviews: [
      ListingReview(author: 'Ana', rating: 4, comment: 'Comoda y limpia.'),
    ],
  );

  test('matchesSearch filters by destination price and guests', () {
    expect(
      listing.matchesSearch(destination: 'andina', maxPrice: 45, guests: 4),
      isTrue,
    );
    expect(listing.matchesSearch(destination: 'Caracas'), isFalse);
    expect(listing.matchesSearch(maxPrice: 30), isFalse);
    expect(listing.matchesSearch(guests: 6), isFalse);
  });

  test('paused listings are excluded from public search', () {
    final paused = listing.copyWith(status: ListingStatus.paused);

    expect(paused.matchesSearch(destination: 'Merida'), isFalse);
  });

  test('addReview stores comment and recalculates average rating', () {
    final reviewed = listing.addReview(
      const ListingReview(
        author: 'Luis',
        rating: 5,
        comment: 'Excelente atencion.',
      ),
    );

    expect(reviewed.reviews, hasLength(2));
    expect(reviewed.rating, 4.5);
    expect(reviewed.reviews.last.comment, 'Excelente atencion.');
  });
}
