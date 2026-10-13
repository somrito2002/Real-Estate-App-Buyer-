import '../config/api_config.dart';

class Partner {
  final String id;
  final String fullName;
  final String companyName;
  final String number;
  final String email;
  final String profilePicture;
  final String? partnerType;
  final int profileViews;

  Partner({
    required this.id,
    required this.fullName,
    required this.companyName,
    required this.number,
    required this.email,
    required this.profilePicture,
    this.partnerType,
    this.profileViews = 0,
  });

  factory Partner.fromJson(Map<String, dynamic> json) {
    String pfp = json['profilePicture']?.toString() ?? '';
    if (pfp.startsWith('/')) {
      pfp = '${ApiConfig.baseUrl}$pfp';
    }

    final viewsRaw = json['profileViews'];
    int views = 0;
    if (viewsRaw is int) {
      views = viewsRaw;
    } else if (viewsRaw != null) {
      views = int.tryParse(viewsRaw.toString()) ?? 0;
    }

    return Partner(
      id: json['id']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? 'Unknown Agent',
      companyName: json['companyName']?.toString() ?? 'Agent',
      number: json['number']?.toString() ?? json['phone']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      profilePicture: pfp,
      partnerType: json['partnerType']?.toString(),
      profileViews: views,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'companyName': companyName,
      'number': number,
      'email': email,
      'profilePicture': profilePicture,
      'partnerType': partnerType,
      'profileViews': profileViews,
    };
  }
}

class Property {
  final String id;
  final String? partnerId;
  final String title;
  final String description;
  final String location;
  final String city;
  final String area;
  final String builtUpArea;
  final String address;
  final String facing;
  final String parking;
  final String floor;
  final String furnishing;
  final String age;
  final String carpetArea;
  final String totalFloors;
  final String waterSupply;
  final String type;
  final String price;
  final String category;
  final String imageUrl;
  final String status;
  final String specs;
  final int bedrooms;
  final int bathrooms;
  final int balconies;
  final List<String> amenities;
  final List<String> images;
  final double? lat;
  final double? lng;
  final String? createdAt;
  final Partner? partner;
  final String? contactName;
  final String? role;
  bool isFavorite;
  final String constructionPhase;
  final String budgetRange;
  final double rawPrice;
  final double rawArea;
  final String purpose;

  Property({
    required this.id,
    this.partnerId,
    required this.title,
    this.description = '',
    required this.location,
    this.city = '',
    this.area = '',
    this.builtUpArea = '',
    this.address = '',
    this.facing = '',
    this.parking = '',
    this.floor = '',
    this.furnishing = '',
    this.age = '',
    this.carpetArea = '',
    this.totalFloors = '',
    this.waterSupply = '',
    required this.type,
    required this.price,
    required this.category,
    required this.imageUrl,
    required this.status,
    required this.specs,
    this.constructionPhase = '',
    this.budgetRange = '',
    this.bedrooms = 0,
    this.bathrooms = 0,
    this.balconies = 0,
    this.amenities = const [],
    this.images = const [],
    this.lat,
    this.lng,
    this.createdAt,
    this.partner,
    this.contactName,
    this.role,
    this.isFavorite = false,
    this.rawPrice = 0.0,
    this.rawArea = 0.0,
    this.purpose = '',
  });

  String get partnerName {
    if (partner != null && partner!.fullName.trim().isNotEmpty && partner!.fullName.trim() != 'Partner' && partner!.fullName.trim() != 'Unknown Agent') {
      return partner!.fullName.trim();
    }
    if (partnerId == '1a3a48b0-273e-4b1f-a734-86894065cd8a') {
      return 'Somrito';
    }
    if (partnerId == 'c69bf08e-2539-47c8-8500-7a400cc66106') {
      return 'Subhadip Mandal';
    }
    if (contactName != null && contactName!.trim().isNotEmpty && contactName!.trim() != 'Partner') {
      return contactName!.trim();
    }
    if (partner != null && partner!.fullName.trim().isNotEmpty) {
      return partner!.fullName.trim();
    }
    return (contactName?.trim().isNotEmpty == true) ? contactName!.trim() : 'Partner';
  }

  factory Property.fromJson(Map<String, dynamic> json) {
    // Safely parse numeric fields
    int parseSafeInt(dynamic val) {
      if (val == null) return 0;
      if (val is int) return val;
      if (val is String) return int.tryParse(val) ?? 0;
      if (val is double) return val.toInt();
      return 0;
    }
    
    double? parseSafeDouble(dynamic val) {
      if (val == null) return null;
      if (val is double) return val;
      if (val is int) return val.toDouble();
      if (val is String) return double.tryParse(val);
      return null;
    }

    String cityStr = json['city']?.toString() ?? '';
    String areaStr = json['area']?.toString() ?? '';
    String loc = '';
    if (areaStr.isNotEmpty && cityStr.isNotEmpty) {
      loc = '$areaStr, $cityStr';
    } else if (cityStr.isNotEmpty) {
      loc = cityStr;
    } else if (areaStr.isNotEmpty) {
      loc = areaStr;
    } else {
      loc = 'Location not specified';
    }

    List<String> imagesList = [];
    if (json['images'] is List) {
      imagesList = (json['images'] as List).map((e) {
        String img = e.toString();
        return img.startsWith('/') ? '${ApiConfig.baseUrl}$img' : img;
      }).toList();
    }
    
    List<String> amenitiesList = [];
    if (json['amenities'] is List) {
      amenitiesList = (json['amenities'] as List).map((e) => e.toString()).toList();
    }

    // Default placeholder or prepend base url if relative path is used
    String primaryImage = 'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?w=800&auto=format&fit=crop';
    if (imagesList.isNotEmpty) {
      primaryImage = imagesList.first;
    }
    
    int bedCount = parseSafeInt(json['bedrooms']);
    int bathCount = parseSafeInt(json['bathrooms']);
    String specsStr = '';
    if (bedCount > 0) specsStr += '$bedCount Bed • ';
    if (bathCount > 0) specsStr += '$bathCount Bath';
    if (specsStr.endsWith(' • ')) specsStr = specsStr.substring(0, specsStr.length - 3);
    if (specsStr.isEmpty) specsStr = 'Custom details';

    // Parse price safely and format if it's large numbers
    String rawPrice = json['price']?.toString() ?? json['expectedPrice']?.toString() ?? '0';
    double priceVal = parseSafeDouble(rawPrice) ?? 0;
    String formattedPrice = rawPrice;
    if (priceVal > 0) {
      if (priceVal >= 10000000) {
        formattedPrice = '₹${(priceVal / 10000000).toStringAsFixed(2)} Cr';
      } else if (priceVal >= 100000) {
        formattedPrice = '₹${(priceVal / 100000).toStringAsFixed(2)} L';
      } else {
        formattedPrice = '₹$priceVal';
      }
    }

    return Property(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      partnerId: json['partnerId']?.toString(),
      title: json['title']?.toString() ?? 'Unknown Title',
      description: json['description']?.toString() ?? '',
      type: json['type']?.toString() ?? 'Property',
      price: formattedPrice,
      city: cityStr,
      area: areaStr,
      builtUpArea: json['builtUpArea']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      facing: json['facing']?.toString() ?? '',
      parking: json['parking']?.toString() ?? '',
      floor: json['propertyOnFloor']?.toString() ?? '',
      furnishing: json['furnishing']?.toString() ?? '',
      age: json['age']?.toString() ?? '',
      carpetArea: json['carpetArea']?.toString() ?? '',
      totalFloors: json['totalFloors']?.toString() ?? '',
      waterSupply: json['waterSupply']?.toString() ?? '',
      location: loc,
      constructionPhase: json['constructionPhase']?.toString() ?? '',
      budgetRange: json['budgetRange']?.toString() ?? '',
      bedrooms: bedCount,
      bathrooms: bathCount,
      balconies: parseSafeInt(json['balconies']),
      status: json['status']?.toString() ?? 'ACTIVE',
      category: json['category']?.toString() ?? 'Buy', // Default fallback for old UI compatibility
      imageUrl: primaryImage,
      specs: specsStr,
      amenities: amenitiesList,
      images: imagesList,
      lat: parseSafeDouble(json['lat']),
      lng: parseSafeDouble(json['lng']),
      createdAt: json['createdAt']?.toString(),
      partner: json['partner'] != null
          ? Partner.fromJson(json['partner'])
          : ((json['partnerId'] != null || json['contactName'] != null)
              ? Partner(
                  id: json['partnerId']?.toString() ?? '',
                  fullName: (json['partnerId'] == '1a3a48b0-273e-4b1f-a734-86894065cd8a')
                      ? 'Somrito'
                      : (json['partnerId'] == 'c69bf08e-2539-47c8-8500-7a400cc66106')
                          ? 'Subhadip Mandal'
                          : ((json['contactName'] != null && json['contactName']?.toString() != 'Partner')
                              ? json['contactName'].toString()
                              : 'Partner'),
                  companyName: json['societyName']?.toString() ?? json['role']?.toString() ?? '',
                  number: json['phone']?.toString() ?? '',
                  email: json['email']?.toString() ?? '',
                  profilePicture: '',
                  partnerType: json['role']?.toString(),
                )
              : null),
      contactName: json['contactName']?.toString(),
      role: json['role']?.toString(),
      rawPrice: priceVal,
      rawArea: parseSafeDouble(json['area']) ?? parseSafeDouble(json['builtUpArea']) ?? parseSafeDouble(json['carpetArea']) ?? 0.0,
      purpose: json['purpose']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'partnerId': partnerId,
      'title': title,
      'description': description,
      'location': location,
      'city': city,
      'area': area,
      'builtUpArea': builtUpArea,
      'address': address,
      'facing': facing,
      'parking': parking,
      'floor': floor,
      'furnishing': furnishing,
      'age': age,
      'carpetArea': carpetArea,
      'totalFloors': totalFloors,
      'waterSupply': waterSupply,
      'type': type,
      'price': price,
      'category': category,
      'imageUrl': imageUrl,
      'status': status,
      'specs': specs,
      'constructionPhase': constructionPhase,
      'budgetRange': budgetRange,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'balconies': balconies,
      'amenities': amenities,
      'images': images,
      'lat': lat,
      'lng': lng,
      'createdAt': createdAt,
      'partner': partner?.toJson(),
      'contactName': contactName,
      'role': role,
      'isFavorite': isFavorite,
      'rawPrice': rawPrice,
      'rawArea': rawArea,
      'purpose': purpose,
    };
  }
}

// Hardcoded mock data list
final List<Property> mockProperties = [
  // [0] Godrej Habitat — Recently Viewed
  Property(
    id: '1',
    title: '3 BHK Premium Apartment',
    location: 'Durg, Chhattisgarh',
    type: '3 BHK',
    price: '₹85 Lakh',
    category: 'Buy',
    imageUrl: 'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?w=800&auto=format&fit=crop',
    status: 'READY TO MOVE',
    specs: '1,450 sq.ft • 3 Bed • 2 Bath',
  ),
  // [1] SS The Leaf — Recently Viewed
  Property(
    id: '2',
    title: 'Luxury Builder Floor',
    location: 'Bhilai, Chhattisgarh',
    type: '3 BHK',
    price: '₹1.20 Cr',
    category: 'Buy',
    imageUrl: 'https://images.unsplash.com/photo-1600566753190-17f0baa2a6c3?w=800&auto=format&fit=crop',
    status: 'UNDER CONSTRUCTION',
    specs: '1,850 sq.ft • 3 Bed • 3 Bath',
  ),
  // [2] DLF The Crest — Featured
  Property(
    id: '3',
    title: 'DLF The Crest Apartment',
    location: 'DLF Phase 5, Gurgaon',
    type: '3 BHK',
    price: '₹2.45 Cr',
    category: 'Buy',
    imageUrl: 'https://images.unsplash.com/photo-1486325212027-8081e485255e?w=800&auto=format&fit=crop',
    status: 'READY TO MOVE',
    specs: '2,215 sq.ft • 3 BHK • 3 Baths',
  ),
  // [3] M3M Golf Estate — Featured
  Property(
    id: '4',
    title: 'M3M Golf Estate',
    location: 'Sector 79, Gurgaon',
    type: '2 BHK',
    price: '₹1.80 Cr',
    category: 'Buy',
    imageUrl: 'https://images.unsplash.com/photo-1574362848149-11496d93a7c7?w=800&auto=format&fit=crop',
    status: 'NEW LAUNCH',
    specs: '1,250 sq.ft • 2 Bed • 2 Bath',
  ),
  // [4] Smart World One DXP — New Projects
  Property(
    id: '5',
    title: 'Smart World One DXP',
    location: 'Sector 113, Gurgaon',
    type: '4 BHK',
    price: '₹3.15 Cr',
    category: 'Buy',
    imageUrl: 'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?w=800&auto=format&fit=crop',
    status: 'UNDER CONSTRUCTION',
    specs: '2,800 sq.ft • 4 Bed • 4 Bath',
  ),
  // [5] Emaar Digi Homes — New Projects
  Property(
    id: '6',
    title: 'Emaar Digi Homes',
    location: 'Sector 62, Gurgaon',
    type: '2 BHK',
    price: '₹1.90 Cr',
    category: 'Buy',
    imageUrl: 'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800&auto=format&fit=crop',
    status: 'NEW LAUNCH',
    specs: '1,350 sq.ft • 2 Bed • 2 Bath',
  ),
  Property(
    id: '7',
    title: 'Bangalore Villa',
    location: 'Whitefield, Bangalore',
    type: '5 BHK',
    price: '₹5 Cr',
    category: 'Buy',
    imageUrl: 'https://images.unsplash.com/photo-1568605114967-8130f3a36994?w=800&auto=format&fit=crop',
    status: 'READY TO MOVE',
    specs: '4,500 sq.ft • 5 Bed • 5 Bath',
  ),
  Property(
    id: '8',
    title: 'Gachibowli Hyderabad Flats',
    location: 'Gachibowli, Hyderabad',
    type: '3 BHK',
    price: '₹1.2 Cr',
    category: 'Rent',
    imageUrl: 'https://images.unsplash.com/photo-1570129477492-45c003edd2be?w=800&auto=format&fit=crop',
    status: 'READY TO MOVE',
    specs: '1,550 sq.ft • 3 Bed • 3 Bath',
  ),
  // New properties matching uploaded images
  Property(
    id: '9',
    title: 'Modern White Complex',
    location: 'Sector 50, Noida',
    type: '3 BHK',
    price: '₹1.50 Cr',
    category: 'Buy',
    imageUrl: 'https://images.unsplash.com/photo-1460317442991-0ec209397118?w=800&auto=format&fit=crop', // White multi-story apartment
    status: 'READY TO MOVE',
    specs: '1,800 sq.ft • 3 Bed • 3 Bath',
  ),
  Property(
    id: '10',
    title: 'Brick House Patio',
    location: 'Whitefield, Bangalore',
    type: '4 BHK',
    price: '₹2.80 Cr',
    category: 'Buy',
    imageUrl: 'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?w=800&auto=format&fit=crop', // Brick house with lawn
    status: 'READY TO MOVE',
    specs: '2,400 sq.ft • 4 Bed • 3 Bath',
  ),
  Property(
    id: '11',
    title: 'Classic Brick Multi-story',
    location: 'Salt Lake City, Kolkata',
    type: '2 BHK',
    price: '₹95 Lakh',
    category: 'Buy',
    imageUrl: 'https://images.unsplash.com/photo-1605146769289-440113cc3d00?w=800&auto=format&fit=crop', // Multi-story brick building
    status: 'UNDER CONSTRUCTION',
    specs: '1,100 sq.ft • 2 Bed • 2 Bath',
  ),
  Property(
    id: '12',
    title: 'Urban Brick Walkway',
    location: 'Andheri West, Mumbai',
    type: '1 RK',
    price: '₹60 Lakh',
    category: 'Buy',
    imageUrl: 'https://images.unsplash.com/photo-1497366216548-37526070297c?w=800&auto=format&fit=crop', // Walkway in brick building
    status: 'READY TO MOVE',
    specs: '450 sq.ft • 1 Bed • 1 Bath',
  ),
];