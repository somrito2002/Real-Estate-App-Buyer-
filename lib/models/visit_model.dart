class Visit {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String date;
  final String time;
  final String status;
  final VisitProperty property;
  final String createdAt;

  Visit({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.date,
    required this.time,
    required this.status,
    required this.property,
    required this.createdAt,
  });

  factory Visit.fromJson(Map<String, dynamic> json) {
    return Visit(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      time: json['time']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      property: VisitProperty.fromJson(json['property'] ?? {}),
      createdAt: json['createdAt']?.toString() ?? '',
    );
  }
}

class VisitProperty {
  final String id;
  final String title;
  final String city;
  final String imageUrl;

  VisitProperty({
    required this.id,
    required this.title,
    required this.city,
    required this.imageUrl,
  });

  factory VisitProperty.fromJson(Map<String, dynamic> json) {
    String parsedImage = 'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?w=400&auto=format&fit=crop';
    if (json['imageUrl'] != null && json['imageUrl'].toString().isNotEmpty) {
      parsedImage = json['imageUrl'].toString();
    } else if (json['photos'] != null && json['photos'] is List && (json['photos'] as List).isNotEmpty) {
      parsedImage = (json['photos'] as List).first.toString();
    }

    if (parsedImage.startsWith('/')) {
      parsedImage = 'https://api.prodalal.com$parsedImage';
    }

    return VisitProperty(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      imageUrl: parsedImage,
    );
  }
}
