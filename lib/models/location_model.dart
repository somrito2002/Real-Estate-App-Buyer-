import '../config/api_config.dart';

class LocationModel {
  final String id;
  final String state;
  final List<String> cities;
  final String image;
  final bool isPopular;
  final String description;
  final int citiesCount;
  final int propertiesCount;

  LocationModel({
    required this.id,
    required this.state,
    required this.cities,
    required this.image,
    required this.isPopular,
    required this.description,
    required this.citiesCount,
    required this.propertiesCount,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    String img = json['image']?.toString() ?? '';
    if (img.startsWith('/')) {
      img = '${ApiConfig.baseUrl}$img';
    }

    List<String> parsedCities = [];
    if (json['cities'] is List) {
      parsedCities = (json['cities'] as List).map((c) => c.toString()).toList();
    }

    return LocationModel(
      id: json['id']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      cities: parsedCities,
      image: img,
      isPopular: json['isPopular'] == true,
      description: json['description']?.toString() ?? '',
      citiesCount: json['citiesCount'] is int ? json['citiesCount'] : int.tryParse(json['citiesCount']?.toString() ?? '') ?? parsedCities.length,
      propertiesCount: json['propertiesCount'] is int ? json['propertiesCount'] : int.tryParse(json['propertiesCount']?.toString() ?? '') ?? 0,
    );
  }
}
