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

  const PropertyFilters({
    this.purpose,
    this.category,
    this.type,
    this.city,
    this.state,
    this.bedrooms,
    this.minPrice,
    this.maxPrice,
  });

  bool get isEmpty =>
      purpose == null &&
      category == null &&
      type == null &&
      city == null &&
      state == null &&
      bedrooms == null &&
      minPrice == null &&
      maxPrice == null;

  PropertyFilters copyWith({
    String? purpose,
    String? category,
    String? type,
    String? city,
    String? state,
    String? bedrooms,
    double? minPrice,
    double? maxPrice,
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
    if (minPrice != null || maxPrice != null) {
      final min = minPrice != null ? _fmt(minPrice!) : '?0';
      final max = maxPrice != null ? _fmt(maxPrice!) : '?10Cr';
      labels.add('$min - $max');
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
