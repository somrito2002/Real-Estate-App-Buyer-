/// Holds all filter parameters that can be sent to the property listing API.
class PropertyFilters {
  final String? purpose;
  final String? category;
  final String? type;
  final String? city;
  final String? state;
  final String? bedrooms;
  final double? minPrice;
  final double? maxPrice;
  final String? status;
  final String? constructionPhase;
  final double? minArea;
  final double? maxArea;
  final String? bathrooms;
  final String? parking;
  final String? furnishing;
  final List<String>? amenities;

  const PropertyFilters({
    this.purpose,
    this.category,
    this.type,
    this.city,
    this.state,
    this.bedrooms,
    this.minPrice,
    this.maxPrice,
    this.status,
    this.constructionPhase,
    this.minArea,
    this.maxArea,
    this.bathrooms,
    this.parking,
    this.furnishing,
    this.amenities,
  });

  bool get isEmpty =>
      purpose == null &&
      category == null &&
      type == null &&
      city == null &&
      state == null &&
      bedrooms == null &&
      minPrice == null &&
      maxPrice == null &&
      status == null &&
      constructionPhase == null &&
      minArea == null &&
      maxArea == null &&
      bathrooms == null &&
      parking == null &&
      furnishing == null &&
      (amenities == null || amenities!.isEmpty);

  PropertyFilters copyWith({
    String? purpose,
    String? category,
    String? type,
    String? city,
    String? state,
    String? bedrooms,
    double? minPrice,
    double? maxPrice,
    String? status,
    String? constructionPhase,
    double? minArea,
    double? maxArea,
    String? bathrooms,
    String? parking,
    String? furnishing,
    List<String>? amenities,
  }) {
    return PropertyFilters(
      purpose: purpose ?? this.purpose,
      category: category ?? this.category,
      type: type ?? this.type,
      city: city ?? this.city,
      state: state ?? this.state,
      bedrooms: bedrooms ?? this.bedrooms,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      status: status ?? this.status,
      constructionPhase: constructionPhase ?? this.constructionPhase,
      minArea: minArea ?? this.minArea,
      maxArea: maxArea ?? this.maxArea,
      bathrooms: bathrooms ?? this.bathrooms,
      parking: parking ?? this.parking,
      furnishing: furnishing ?? this.furnishing,
      amenities: amenities ?? this.amenities,
    );
  }

  List<String> get activeLabels {
    final labels = <String>[];
    if (purpose != null) labels.add(purpose!);
    if (category != null) labels.add(category!);
    if (type != null) labels.add(type!);
    if (city != null) labels.add(city!);
    if (state != null) labels.add(state!);
    if (bedrooms != null) labels.add('$bedrooms BHK');
    if (bathrooms != null) labels.add('$bathrooms Bath');
    if (status != null) labels.add(status!);
    if (constructionPhase != null) labels.add(constructionPhase!);
    if (parking != null) labels.add(parking!);
    if (furnishing != null) labels.add(furnishing!);
    
    if (minPrice != null || maxPrice != null) {
      final min = minPrice != null ? _fmt(minPrice!) : '?0';
      final max = maxPrice != null ? _fmt(maxPrice!) : '?10Cr';
      labels.add('$min - $max');
    }
    
    if (minArea != null || maxArea != null) {
      final min = minArea != null ? minArea!.toInt().toString() : '0';
      final max = maxArea != null ? maxArea!.toInt().toString() : 'Any';
      labels.add('$min - $max sqft');
    }

    if (amenities != null && amenities!.isNotEmpty) {
      labels.add('${amenities!.length} Amenities');
    }

    return labels;
  }

  static String _fmt(double value) {
    if (value >= 10000000) {
      return '?${(value / 10000000).toStringAsFixed(1)} Cr';
    } else if (value >= 100000) {
      return '?${(value / 100000).toStringAsFixed(1)} L';
    }
    return '?${value.toInt()}';
  }
}
