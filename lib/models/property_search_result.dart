import 'property_model.dart';

class PropertyParsedQuery {
  final String raw;
  final String? detectedBhk;
  final List<String> detectedTypes;
  final List<String> textTokens;
  final String cleanedQuery;

  PropertyParsedQuery({
    this.raw = '',
    this.detectedBhk,
    this.detectedTypes = const [],
    this.textTokens = const [],
    this.cleanedQuery = '',
  });

  factory PropertyParsedQuery.fromJson(Map<String, dynamic> json) {
    List<String> types = [];
    if (json['detectedTypes'] is List) {
      types = (json['detectedTypes'] as List).map((e) => e.toString()).toList();
    }

    List<String> tokens = [];
    if (json['textTokens'] is List) {
      tokens = (json['textTokens'] as List).map((e) => e.toString()).toList();
    }

    return PropertyParsedQuery(
      raw: json['raw']?.toString() ?? '',
      detectedBhk: json['detectedBhk']?.toString(),
      detectedTypes: types,
      textTokens: tokens,
      cleanedQuery: json['cleanedQuery']?.toString() ?? '',
    );
  }
}

class PropertySearchResult {
  final bool success;
  final String query;
  final PropertyParsedQuery? parsedQuery;
  final int total;
  final int page;
  final int limit;
  final int totalPages;
  final List<Property> properties;

  PropertySearchResult({
    this.success = true,
    this.query = '',
    this.parsedQuery,
    this.total = 0,
    this.page = 1,
    this.limit = 20,
    this.totalPages = 1,
    this.properties = const [],
  });

  factory PropertySearchResult.fromJson(Map<String, dynamic> json) {
    PropertyParsedQuery? parsed;
    if (json['parsedQuery'] is Map<String, dynamic>) {
      parsed = PropertyParsedQuery.fromJson(json['parsedQuery']);
    }

    List<Property> props = [];
    if (json['properties'] is List) {
      props = (json['properties'] as List)
          .whereType<Map<String, dynamic>>()
          .map((item) => Property.fromJson(item))
          .toList();
    }

    int parseInt(dynamic val, int fallback) {
      if (val is int) return val;
      if (val is String) return int.tryParse(val) ?? fallback;
      return fallback;
    }

    return PropertySearchResult(
      success: json['success'] == true,
      query: json['query']?.toString() ?? '',
      parsedQuery: parsed,
      total: parseInt(json['total'], props.length),
      page: parseInt(json['page'], 1),
      limit: parseInt(json['limit'], 20),
      totalPages: parseInt(json['totalPages'], 1),
      properties: props,
    );
  }
}
