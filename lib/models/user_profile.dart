/// Model for a summary of a property attached to an enquiry or visit.
class PropertySummary {
  final String id;
  final String title;

  const PropertySummary({required this.id, required this.title});

  factory PropertySummary.fromJson(Map<String, dynamic> json) {
    return PropertySummary(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
    );
  }
}

/// A wishlist item returned by the backend.
class WishlistItem {
  final String id;
  final String title;
  final String price;

  const WishlistItem({required this.id, required this.title, required this.price});

  factory WishlistItem.fromJson(Map<String, dynamic> json) {
    return WishlistItem(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      price: (json['price'] ?? '').toString(),
    );
  }
}

/// An enquiry returned by the backend.
class UserEnquiry {
  final String id;
  final String message;
  final String status;
  final PropertySummary? property;
  final String? createdAt;

  const UserEnquiry({
    required this.id,
    required this.message,
    required this.status,
    this.property,
    this.createdAt,
  });

  factory UserEnquiry.fromJson(Map<String, dynamic> json) {
    return UserEnquiry(
      id: (json['id'] ?? '').toString(),
      message: (json['message'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      property: json['property'] != null
          ? PropertySummary.fromJson(json['property'] as Map<String, dynamic>)
          : null,
      createdAt: json['createdAt']?.toString(),
    );
  }
}

/// A scheduled visit returned by the backend.
class UserVisit {
  final String id;
  final String date;
  final String time;
  final String status;
  final PropertySummary? property;

  const UserVisit({
    required this.id,
    required this.date,
    required this.time,
    required this.status,
    this.property,
  });

  factory UserVisit.fromJson(Map<String, dynamic> json) {
    return UserVisit(
      id: (json['id'] ?? '').toString(),
      date: (json['date'] ?? '').toString(),
      time: (json['time'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      property: json['property'] != null
          ? PropertySummary.fromJson(json['property'] as Map<String, dynamic>)
          : null,
    );
  }
}

/// Full authenticated user profile returned by GET /api/auth/user/:id.
class UserProfile {
  final String id;
  final String fullName;
  final String email;
  final String number;

  /// May be a relative path like "/Upload/profiles/photo.jpg".
  /// Use [profilePictureUrl] to get the full URL.
  final String? profilePicture;

  final List<WishlistItem> wishlist;
  final List<UserEnquiry> enquiries;
  final List<UserVisit> visits;

  const UserProfile({
    required this.id,
    required this.fullName,
    required this.email,
    required this.number,
    this.profilePicture,
    this.wishlist = const [],
    this.enquiries = const [],
    this.visits = const [],
  });

  /// Resolves a relative profilePicture path into a full URL.
  /// Returns null when profilePicture is null so the UI can show
  /// its default avatar instead of a broken image.
  String? profilePictureUrl(String baseUrl) {
    if (profilePicture == null || profilePicture!.isEmpty) return null;
    if (profilePicture!.startsWith('http')) return profilePicture;
    // Strip trailing slash from baseUrl and leading slash from path
    final base = baseUrl.replaceAll(RegExp(r'/api/auth$'), '')
                        .replaceAll(RegExp(r'/+$'), '');
    final path = profilePicture!.startsWith('/')
        ? profilePicture!
        : '/$profilePicture';
    return '$base$path';
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    List<WishlistItem> wishlist = [];
    List<UserEnquiry> enquiries = [];
    List<UserVisit> visits = [];

    if (json['wishlist'] is List) {
      wishlist = (json['wishlist'] as List)
          .whereType<Map<String, dynamic>>()
          .map(WishlistItem.fromJson)
          .toList();
    }
    if (json['enquiries'] is List) {
      enquiries = (json['enquiries'] as List)
          .whereType<Map<String, dynamic>>()
          .map(UserEnquiry.fromJson)
          .toList();
    }
    if (json['visits'] is List) {
      visits = (json['visits'] as List)
          .whereType<Map<String, dynamic>>()
          .map(UserVisit.fromJson)
          .toList();
    }

    return UserProfile(
      id: (json['id'] ?? '').toString(),
      fullName: (json['fullName'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      number: (json['number'] ?? '').toString(),
      profilePicture: json['profilePicture']?.toString(),
      wishlist: wishlist,
      enquiries: enquiries,
      visits: visits,
    );
  }
}
