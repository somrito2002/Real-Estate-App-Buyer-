import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/property_model.dart';

class PropertyApiService {
  static const String _baseUrl = ApiConfig.apiBaseUrl;

  static Future<List<Property>> getProperties({
    String status = 'ACTIVE',
    int limit = 10,
    int page = 1,
    String? search,
    String? purpose,
    String? category,
    String? type,
    String? city,
    String? state,
    String? bedrooms,
    double? minPrice,
    double? maxPrice,
    String? constructionPhase,
    double? minArea,
    double? maxArea,
    String? bathrooms,
    String? parking,
    String? furnishing,
    List<String>? amenities,
  }) async {
    try {
      final params = <String, String>{
        'status': status,
        'limit': limit.toString(),
        'page': page.toString(),
      };
      if (search != null && search.isNotEmpty) params['search'] = search;
      if (purpose != null && purpose.isNotEmpty) {
        // Backend stores for-sale properties with purpose 'Sell', while UI uses 'Buy'
        params['purpose'] = purpose.toLowerCase() == 'buy' ? 'Sell' : purpose;
      }
      if (category != null && category.isNotEmpty) params['category'] = category;
      if (type != null && type.isNotEmpty) params['type'] = type;
      if (city != null && city.isNotEmpty) params['city'] = city;
      if (state != null && state.isNotEmpty) params['state'] = state;
      if (bedrooms != null && bedrooms.isNotEmpty) params['bedrooms'] = bedrooms;
      if (minPrice != null) params['minPrice'] = minPrice.toInt().toString();
      if (maxPrice != null) params['maxPrice'] = maxPrice.toInt().toString();
      if (constructionPhase != null && constructionPhase.isNotEmpty) params['constructionPhase'] = constructionPhase;
      if (minArea != null) params['minArea'] = minArea.toInt().toString();
      if (maxArea != null) params['maxArea'] = maxArea.toInt().toString();
      if (bathrooms != null && bathrooms.isNotEmpty) params['bathrooms'] = bathrooms;
      if (parking != null && parking.isNotEmpty) params['parking'] = parking;
      if (furnishing != null && furnishing.isNotEmpty) params['furnishing'] = furnishing;
      if (amenities != null && amenities.isNotEmpty) params['amenities'] = amenities.join(',');

      final uri = Uri.parse('$_baseUrl/properties').replace(queryParameters: params);
      final response = await http.get(uri).timeout(const Duration(seconds: 30));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = json.decode(response.body);
        if (data != null && data['properties'] != null) {
          final List propertiesData = data['properties'];
          return propertiesData.map((json) => Property.fromJson(json)).toList();
        }
        return [];
      } else {
        throw Exception('Failed to load properties. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Unable to load properties: $e');
    }
  }

  static Future<Property> getPropertyById(String propertyId) async {
    try {
      final uri = Uri.parse('$_baseUrl/properties/${Uri.encodeComponent(propertyId)}');
      final response = await http.get(uri).timeout(const Duration(seconds: 30));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = json.decode(response.body);
        if (data != null) {
          if (data['property'] != null) {
            return Property.fromJson(data['property']);
          } else if (data['properties'] != null && (data['properties'] as List).isNotEmpty) {
            return Property.fromJson(data['properties'][0]);
          } else if (data['id'] != null || data['_id'] != null) {
            return Property.fromJson(data);
          }
        }
        throw Exception('Property data not found in response. Received: $data');
      } else if (response.statusCode == 404) {
        throw Exception('Property not found.');
      } else {
        throw Exception('Failed to load property. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Unable to load property: $e');
    }
  }

  static Future<Map<String, dynamic>> getPropertyRanges() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/properties/ranges'),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded is Map<String, dynamic>) {
          if (decoded.containsKey('data') && decoded['data'] is Map<String, dynamic>) {
            return decoded['data'] as Map<String, dynamic>;
          }
          return decoded;
        }
        return {};
      } else {
        throw Exception('Failed to fetch property ranges: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error while fetching ranges: $e');
    }
  }
}
