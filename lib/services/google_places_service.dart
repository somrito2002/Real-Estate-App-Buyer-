import 'dart:convert';
import 'package:http/http.dart' as http;

class GooglePlacesService {
  static const String _apiKey = 'AIzaSyCywGyNk-3DalVKhTnX8A-ZGmSJBuMNxTA';
  static const String _baseUrl = 'https://maps.googleapis.com/maps/api/place/autocomplete/json';

  /// Fetches autocomplete suggestions from Google Places API.
  static Future<List<PlaceSuggestion>> getAutocompleteSuggestions(String query) async {
    if (query.trim().isEmpty) return [];

    final url = Uri.parse('$_baseUrl?input=$query&key=$_apiKey&components=country:in');
    
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final predictions = data['predictions'] as List;
          return predictions.map((p) {
            return PlaceSuggestion(
              placeId: p['place_id'],
              description: p['description'],
              mainText: p['structured_formatting']?['main_text'] ?? '',
              secondaryText: p['structured_formatting']?['secondary_text'] ?? '',
            );
          }).toList();
        }
      }
    } catch (e) {
      print('Error fetching places: $e');
    }
    return [];
  }
}

class PlaceSuggestion {
  final String placeId;
  final String description;
  final String mainText;
  final String secondaryText;

  PlaceSuggestion({
    required this.placeId,
    required this.description,
    required this.mainText,
    required this.secondaryText,
  });
}
