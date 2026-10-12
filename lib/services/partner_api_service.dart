import 'dart:convert';
import 'package:http/http.dart' as http;
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
  static const String _baseUrl = 'https://api.prodalal.com/api';

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
}
