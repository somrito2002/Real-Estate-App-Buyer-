import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/property_model.dart';

class RecentlyViewedService {
  static const String _key = 'recently_viewed_properties';
  static const int _maxItems = 20;

  /// Retrieve list of recently viewed properties, ordered newest first
  static Future<List<Property>> getRecentlyViewed() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final listJson = prefs.getStringList(_key);
      if (listJson == null || listJson.isEmpty) return [];

      final List<Property> properties = [];
      for (final item in listJson) {
        try {
          final map = json.decode(item);
          if (map is Map<String, dynamic>) {
            final prop = Property.fromJson(map);
            properties.add(prop);
          }
        } catch (_) {}
      }
      return properties;
    } catch (_) {
      return [];
    }
  }

  /// Record a viewed property (moves to top, avoids duplicates, limits to _maxItems)
  static Future<void> addRecentlyViewed(Property property) async {
    try {
      if (property.id.isEmpty) return;
      final prefs = await SharedPreferences.getInstance();
      final listJson = prefs.getStringList(_key) ?? [];

      // Remove existing occurrence with the same ID
      listJson.removeWhere((item) {
        try {
          final map = json.decode(item);
          return map['id']?.toString() == property.id || map['_id']?.toString() == property.id;
        } catch (_) {
          return false;
        }
      });

      // Insert at index 0
      final encoded = json.encode(property.toJson());
      listJson.insert(0, encoded);

      if (listJson.length > _maxItems) {
        listJson.removeRange(_maxItems, listJson.length);
      }

      await prefs.setStringList(_key, listJson);
    } catch (_) {}
  }

  /// Clear all recently viewed properties
  static Future<void> clearRecentlyViewed() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_key);
    } catch (_) {}
  }
}
