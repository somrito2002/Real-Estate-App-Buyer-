import 'package:flutter_test/flutter_test.dart';
import 'package:realty_app/services/partner_api_service.dart';

void main() {
  group('SellerReview Model and Rating Tests', () {
    test('SellerReview parses correctly from JSON', () {
      final json = {
        'id': '4e8ed905-39fe-4327-ad66-b1e0890e9d24',
        'rating': 2,
        'comment': 'good',
        'propertyId': 'd4b61362-5bdd-4dca-be3f-7b8f78c6e36f',
        'userId': '5b4a3796-8d2a-404d-99b9-6ae1535b93a6',
        'createdAt': '2026-10-10T10:42:55.343Z',
        'property': {
          'id': 'd4b61362-5bdd-4dca-be3f-7b8f78c6e36f',
          'partnerId': '1a3a48b0-273e-4b1f-a734-86894065cd8a',
          'title': 'Et in ullamco quod v',
        },
      };

      final review = SellerReview.fromJson(json);

      expect(review.id, '4e8ed905-39fe-4327-ad66-b1e0890e9d24');
      expect(review.rating, 2.0);
      expect(review.comment, 'good');
      expect(review.propertyId, 'd4b61362-5bdd-4dca-be3f-7b8f78c6e36f');
      expect(review.propertyTitle, 'Et in ullamco quod v');
      expect(review.userId, '5b4a3796-8d2a-404d-99b9-6ae1535b93a6');
      expect(review.createdAt, isNotNull);
    });

    test('Average rating calculation works with multiple reviews', () {
      final reviews = [
        SellerReview(
          id: '1',
          rating: 4.0,
          comment: 'Great property',
          propertyId: 'p1',
          propertyTitle: 'Villa',
          userId: 'u1',
        ),
        SellerReview(
          id: '2',
          rating: 5.0,
          comment: 'Excellent seller',
          propertyId: 'p1',
          propertyTitle: 'Villa',
          userId: 'u2',
        ),
      ];

      final total = reviews.fold<double>(0.0, (acc, r) => acc + r.rating);
      final avg = total / reviews.length;

      expect(avg, 4.5);
      expect('${avg.toStringAsFixed(1)} ★', '4.5 ★');
    });

    test('Single review rating matches exact score', () {
      final reviews = [
        SellerReview(
          id: '1',
          rating: 2.0,
          comment: 'good',
          propertyId: 'p1',
          propertyTitle: 'Et in ullamco quod v',
          userId: 'u1',
        ),
      ];

      final total = reviews.fold<double>(0.0, (acc, r) => acc + r.rating);
      final avg = total / reviews.length;

      expect(avg, 2.0);
      expect('${avg.toStringAsFixed(1)} ★', '2.0 ★');
    });
  });
}
