import 'package:shared_preferences/shared_preferences.dart';

class SearchHistoryService {
  static const String _key = 'recent_searches';
  static const int _maxSearches = 5;

  static Future<List<String>> getRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? [];
  }

  static Future<void> addSearch(String query) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> searches = prefs.getStringList(_key) ?? [];
    
    // Remove if already exists to move it to the top
    searches.remove(query);
    
    // Insert at the beginning
    searches.insert(0, query);
    
    // Keep only the max number of searches
    if (searches.length > _maxSearches) {
      searches = searches.sublist(0, _maxSearches);
    }
    
    await prefs.setStringList(_key, searches);
  }

  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
