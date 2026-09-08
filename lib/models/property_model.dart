class Property {
  final String id;
  final String title;
  final String location;
  final String type;
  final String price;
  final String category;
  final String imageUrl;
  final String status; // e.g., 'READY TO MOVE', 'UNDER CONSTRUCTION'
  final String specs; // e.g., '1,450 sq.ft • 3 Bed • 2 Bath'
  bool isFavorite;

  Property({
    required this.id,
    required this.title,
    required this.location,
    required this.type,
    required this.price,
    required this.category,
    required this.imageUrl,
    required this.status,
    required this.specs,
    this.isFavorite = false,
  });
}

// Hardcoded mock data list
final List<Property> mockProperties = [
  Property(
    id: '1',
    title: '3 BHK Premium Apartment',
    location: 'Durg, Chhattisgarh',
    type: '3 BHK',
    price: '₹85 Lakh',
    category: 'Buy',
    imageUrl: 'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?w=800&auto=format&fit=crop',
    status: 'READY TO MOVE',
    specs: '1,450 sq.ft • 3 Bed • 2 Bath',
  ),
  Property(
    id: '2',
    title: 'Luxury Builder Floor',
    location: 'Bhilai, Chhattisgarh',
    type: '3 BHK',
    price: '₹1.20 Cr',
    category: 'Buy',
    imageUrl: 'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?w=800&auto=format&fit=crop',
    status: 'UNDER CONSTRUCTION',
    specs: '1,850 sq.ft • 3 Bed • 3 Bath',
  ),
  Property(
    id: '3',
    title: 'DLF The Crest Apartment',
    location: 'DLF Phase 5, Gurgaon',
    type: '3 BHK',
    price: '₹2.45 Cr',
    category: 'Buy',
    imageUrl: 'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?w=800&auto=format&fit=crop',
    status: 'READY TO MOVE',
    specs: '2,215 sq.ft • 3 BHK • 3 Baths',
  ),
  Property(
    id: '4',
    title: 'M3M Golf Estate',
    location: 'Sector 79, Gurgaon',
    type: '2 BHK',
    price: '₹1.80 Cr',
    category: 'Buy',
    imageUrl: 'https://images.unsplash.com/photo-1515263487990-61b07816b324?w=800&auto=format&fit=crop',
    status: 'NEW LAUNCH',
    specs: '1,250 sq.ft • 2 Bed • 2 Bath',
  ),
  Property(
    id: '5',
    title: 'Smart World One DXP',
    location: 'Sector 113, Gurgaon',
    type: '4 BHK',
    price: '₹3.15 Cr',
    category: 'Buy',
    imageUrl: 'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?w=800&auto=format&fit=crop',
    status: 'UNDER CONSTRUCTION',
    specs: '2,800 sq.ft • 4 Bed • 4 Bath',
  ),
  Property(
    id: '6',
    title: 'Mumbai Flats',
    location: 'Bandra, Mumbai',
    type: '1 BHK',
    price: '₹1.5 Cr',
    category: 'Rent',
    imageUrl: 'https://images.unsplash.com/photo-1493809842364-78817add7ffb?w=800&auto=format&fit=crop',
    status: 'READY TO MOVE',
    specs: '650 sq.ft • 1 Bed • 1 Bath',
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
];