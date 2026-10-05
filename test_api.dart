import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:realty_app/models/property_model.dart';
void main() async {
  final uri = Uri.parse('https://api.prodalal.com/api/properties?status=ACTIVE&limit=10&page=1');
  final response = await http.get(uri);
  final data = json.decode(response.body);
  final List propertiesData = data['properties'];
  try {
    for (var j in propertiesData) {
      Property.fromJson(j);
    }
    print('SUCCESS');
  } catch (e, stack) {
    print('ERROR: ' + e.toString());
  }
}
