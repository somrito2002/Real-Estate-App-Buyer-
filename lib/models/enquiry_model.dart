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
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      status: json['status']?.toString() ?? 'NEW',
      createdAt: json['createdAt']?.toString() ?? '',
      property: json['property'] != null ? EnquiryProperty.fromJson(json['property']) : null,
    );
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
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      bedrooms: json['bedrooms']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
    );
  }
}
