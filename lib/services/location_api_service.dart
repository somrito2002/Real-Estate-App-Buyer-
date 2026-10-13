import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/location_model.dart';

class LocationApiService {
  static const String _baseUrl = ApiConfig.apiBaseUrl;

  /// Fetches locations from GET /api/locations.
  /// If [popular] is specified, appends ?popular=true or ?popular=false.
  static Future<List<LocationModel>> getLocations({bool? popular}) async {
    try {
      String url = '$_baseUrl/locations';
      if (popular != null) {
        url += '?popular=$popular';
      }

      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 15));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = json.decode(response.body);
        final List locationsList = data['locations'] ?? [];
        return locationsList.map((e) => LocationModel.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load locations: ${response.statusCode}');
      }
    } catch (e) {
      // Re-throw or let caller handle fallback
      rethrow;
    }
  }

  /// Fetches popular states from GET /api/locations?popular=true.
  static Future<List<LocationModel>> getPopularStates() async {
    try {
      final list = await getLocations(popular: true);
      if (list.isNotEmpty) {
        return list;
      }
      final all = await getLocations();
      final popular = all.where((l) => l.isPopular).toList();
      return popular.isNotEmpty ? popular : all;
    } catch (e) {
      rethrow;
    }
  }
}
