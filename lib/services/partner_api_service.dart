import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/property_model.dart';

class PartnerPublicProfile {
  final Partner partner;
  final List<Property> properties;

  PartnerPublicProfile({
    required this.partner,
    required this.properties,
  });

  factory PartnerPublicProfile.fromJson(Map<String, dynamic> json) {
    final partnerMap = json['partner'] as Map<String, dynamic>? ?? {};
    Partner partnerObj = Partner.fromJson(partnerMap);

    String partnerPhone = partnerObj.number;
    String partnerEmail = partnerObj.email;

    final rawProps = json['properties'];
    final List<Property> propList = [];
    if (rawProps is List) {
      for (final p in rawProps) {
        if (p is Map<String, dynamic>) {
          if (partnerPhone.isEmpty && p['phone'] != null) {
            partnerPhone = p['phone'].toString();
          }
          if (partnerEmail.isEmpty && p['email'] != null) {
            partnerEmail = p['email'].toString();
          }
          try {
            propList.add(Property.fromJson(p));
          } catch (_) {
            // Ignore corrupted single property item
          }
        }
      }
    }

    if (partnerPhone != partnerObj.number || partnerEmail != partnerObj.email) {
      partnerObj = Partner(
        id: partnerObj.id,
        fullName: partnerObj.fullName,
        companyName: partnerObj.companyName,
        number: partnerPhone,
        email: partnerEmail,
        profilePicture: partnerObj.profilePicture,
        partnerType: partnerObj.partnerType,
        profileViews: partnerObj.profileViews,
      );
    }

    return PartnerPublicProfile(
      partner: partnerObj,
      properties: propList,
    );
  }
}

class PartnerApiService {
  static const String _baseUrl = ApiConfig.apiBaseUrl;

  /// Fetches public partner details and their active property listings.
  /// Automatically increments the partner's profileViews on the server side.
  static Future<PartnerPublicProfile> getPublicProfile(String partnerId) async {
    final cleanId = partnerId.trim();
    if (cleanId.isEmpty) {
      throw Exception('Partner ID is required');
    }

    try {
      final uri = Uri.parse('$_baseUrl/partner/public/${Uri.encodeComponent(cleanId)}');
      final response = await http.get(uri).timeout(const Duration(seconds: 25));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = json.decode(response.body);
        if (data is Map<String, dynamic>) {
          return PartnerPublicProfile.fromJson(data);
        }
        throw Exception('Unexpected server response format');
      } else if (response.statusCode == 404) {
        throw Exception('Seller profile not found.');
      } else {
        throw Exception('Server responded with status code ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load seller profile: $e');
    }
  }

  /// Fetches reviews for a seller's properties or by partner ID.
  static Future<List<SellerReview>> getReviewsForSeller({
    required String partnerId,
    List<String> propertyIds = const [],
  }) async {
    final cleanPartnerId = partnerId.trim();
    final cleanPropIds = propertyIds.map((e) => e.trim()).where((e) => e.isNotEmpty).toSet();
    final Map<String, SellerReview> reviewsMap = {};

    // 1. Try querying /api/reviews which returns reviews with nested property details
    try {
      final uri = Uri.parse('$_baseUrl/reviews');
      final response = await http.get(uri).timeout(const Duration(seconds: 15));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = json.decode(response.body);
        List<dynamic>? rawReviews;
        if (decoded is Map<String, dynamic> && decoded['reviews'] is List) {
          rawReviews = decoded['reviews'] as List<dynamic>;
        } else if (decoded is List) {
          rawReviews = decoded;
        }

        if (rawReviews != null) {
          for (final item in rawReviews) {
            if (item is Map<String, dynamic>) {
              final rev = SellerReview.fromJson(item);
              final prop = item['property'];
              final propPartnerId = prop is Map<String, dynamic>
                  ? (prop['partnerId']?.toString() ?? '')
                  : '';

              final bool matchesPartner =
                  cleanPartnerId.isNotEmpty && propPartnerId == cleanPartnerId;
              final bool matchesProperty =
                  cleanPropIds.isNotEmpty && cleanPropIds.contains(rev.propertyId);

              if (matchesPartner || matchesProperty) {
                reviewsMap[rev.id] = rev;
              }
            }
          }
        }
      }
    } catch (_) {}

    // 2. Also query /api/reviews?propertyId=<id> for each property to ensure completeness
    for (final pId in cleanPropIds) {
      try {
        final uri = Uri.parse('$_baseUrl/reviews?propertyId=${Uri.encodeComponent(pId)}');
        final response = await http.get(uri).timeout(const Duration(seconds: 10));
        if (response.statusCode >= 200 && response.statusCode < 300) {
          final decoded = json.decode(response.body);
          List<dynamic>? rawReviews;
          if (decoded is Map<String, dynamic> && decoded['reviews'] is List) {
            rawReviews = decoded['reviews'] as List<dynamic>;
          } else if (decoded is List) {
            rawReviews = decoded;
          }

          if (rawReviews != null) {
            for (final item in rawReviews) {
              if (item is Map<String, dynamic>) {
                final rev = SellerReview.fromJson(item);
                reviewsMap[rev.id] = rev;
              }
            }
          }
        }
      } catch (_) {}
    }

    final result = reviewsMap.values.toList();
    result.sort((a, b) {
      if (a.createdAt != null && b.createdAt != null) {
        return b.createdAt!.compareTo(a.createdAt!);
      }
      return 0;
    });
    return result;
  }
}

class SellerReview {
  final String id;
  final double rating;
  final String comment;
  final String propertyId;
  final String propertyTitle;
  final String userId;
  final DateTime? createdAt;

  SellerReview({
    required this.id,
    required this.rating,
    required this.comment,
    required this.propertyId,
    required this.propertyTitle,
    required this.userId,
    this.createdAt,
  });

  factory SellerReview.fromJson(Map<String, dynamic> json) {
    double parsedRating = 0.0;
    if (json['rating'] is num) {
      parsedRating = (json['rating'] as num).toDouble();
    } else if (json['rating'] != null) {
      parsedRating = double.tryParse(json['rating'].toString()) ?? 0.0;
    }

    String propTitle = '';
    if (json['property'] is Map<String, dynamic>) {
      propTitle = (json['property']['title'] ?? '').toString();
    }

    DateTime? created;
    if (json['createdAt'] != null) {
      created = DateTime.tryParse(json['createdAt'].toString());
    }

    return SellerReview(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      rating: parsedRating,
      comment: json['comment']?.toString() ?? '',
      propertyId: json['propertyId']?.toString() ?? '',
      propertyTitle: propTitle,
      userId: json['userId']?.toString() ?? '',
      createdAt: created,
    );
  }
}
