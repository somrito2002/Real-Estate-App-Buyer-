import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/property_model.dart';

class PropertyApiService {
  static const String _baseUrl = 'https://api.prodalal.com/api';

  static Future<List<Property>> getProperties({
    String status = 'ACTIVE',
    int limit = 10,
    int page = 1, // Optional: if backend uses it
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/properties?status=$status&limit=$limit&page=$page');
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
}
