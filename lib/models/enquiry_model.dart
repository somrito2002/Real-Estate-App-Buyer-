class Enquiry {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String message;
  final String status;
  final String createdAt;
  final EnquiryProperty? property;

  Enquiry({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.message,
    required this.status,
    required this.createdAt,
    this.property,
  });

  factory Enquiry.fromJson(Map<String, dynamic> json) {
    return Enquiry(
      id: (json['id'] ?? json['_id'])?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      status: json['status']?.toString() ?? 'NEW',
      createdAt: json['createdAt']?.toString() ?? '',
      property: _parseProperty(json['property']),
    );
  }

  static EnquiryProperty? _parseProperty(dynamic propJson) {
    if (propJson == null) return null;
    if (propJson is String) {
      return EnquiryProperty(id: propJson, title: '', bedrooms: '', type: '');
    }
    if (propJson is Map<String, dynamic>) {
      return EnquiryProperty.fromJson(propJson);
    }
    return null;
  }
}

class EnquiryProperty {
  final String id;
  final String title;
  final String bedrooms;
  final String type;

  EnquiryProperty({
    required this.id,
    required this.title,
    required this.bedrooms,
    required this.type,
  });

  factory EnquiryProperty.fromJson(Map<String, dynamic> json) {
    return EnquiryProperty(
      id: (json['id'] ?? json['_id'])?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      bedrooms: json['bedrooms']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
    );
  }
}
