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