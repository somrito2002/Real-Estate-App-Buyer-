import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:realty_app/models/property_model.dart';

void main() async {
  final uri = Uri.parse('https://api.prodalal.com/api/properties?status=ACTIVE&limit=10&page=1');
  final response = await http.get(uri);
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    final List propertiesData = data['properties'];
    print('Raw length: \');
    try {
      final properties = propertiesData.map((j) => Property.fromJson(j)).toList();
      print('Parsed length: \');
    } catch (e, stack) {
      print('Parse error: \');
      print(stack);
    }
  }
}
