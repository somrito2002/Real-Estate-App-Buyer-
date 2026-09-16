import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/services.dart';
import 'profile_screen.dart';
import 'saved_screen.dart';
import 'search_screen.dart' as import_search_screen;
import 'models/property_model.dart';
import 'property_details_screen.dart';
import 'view_all_properties_screen.dart';
import 'tilt_property_card.dart';
import 'notifications_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _bottomNavIndex = 0;
  String _currentLocation = 'Locating...';
  String _selectedPrimaryCategory = 'Buy';

  static const Color accentBlue = Color(0xFF4B85F0);

  // Voice search
  @override
  void initState() {
    super.initState();
    _fetchLocation();
  }

  @override
  void dispose() {
    super.dispose();
  }



  Future<void> _fetchLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
        Position position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
        );
        final geocoder = Geocoding();
        List<Placemark> placemarks = await geocoder.placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty) {
          if (mounted) {
            setState(() {
              _currentLocation = placemarks[0].locality ?? placemarks[0].subAdministrativeArea ?? 'Unknown';
            });
          }
        }
      } else {
        if (mounted) {
          setState(() {
            _currentLocation = 'Unknown';
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching location: $e');
      if (mounted) {
        setState(() {
          _currentLocation = 'Unknown';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        if (_bottomNavIndex != 0) {
          setState(() {
            _bottomNavIndex = 0;
          });
        } else {
          final shouldPop = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: Theme.of(context).colorScheme.surface,
              title: Text('Leave App?', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
              content: Text('Do you want to leave the app?', style: GoogleFonts.inter()),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text('No', style: GoogleFonts.inter(color: accentBlue)),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text('Yes', style: GoogleFonts.inter(color: Colors.red)),
                ),
              ],
            ),
          );
          if (shouldPop == true) {
            // Using SystemNavigator.pop to exit app on Android
            // ignore: unawaited_futures
            SystemNavigator.pop();
          }
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: _bottomNavIndex == 4
            ? _buildProfileAppBar()
            : (_bottomNavIndex == 1
                ? null
                : (_bottomNavIndex == 2
                    ? AppBar(
                        title: Text('Shortlisted Properties',
                            style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface)),
                        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                        elevation: 0,
                        scrolledUnderElevation: 0,
                      )
                    : (_bottomNavIndex == 0
                        ? _buildAppBar()
                        : AppBar(
                            title: const Text('Coming Soon'),
                            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                            elevation: 0)))),
        body: _buildBody(),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _bottomNavIndex,
          onTap: (i) => setState(() => _bottomNavIndex = i),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: accentBlue,
          unselectedItemColor: Colors.grey.shade500,
          selectedLabelStyle: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600),
          unselectedLabelStyle: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.search_outlined), activeIcon: Icon(Icons.search), label: 'Search'),
            BottomNavigationBarItem(icon: Icon(Icons.favorite_border), activeIcon: Icon(Icons.favorite), label: 'Shortlisted'),
            BottomNavigationBarItem(
              icon: Badge(
                backgroundColor: Colors.red,
                child: Icon(Icons.notifications_none),
              ),
              activeIcon: Badge(
                backgroundColor: Colors.red,
                child: Icon(Icons.notifications),
              ),
              label: 'Inbox',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (_bottomNavIndex) {
      case 0:
        return _buildHomeTab();
      case 1:
        return const import_search_screen.SearchScreen();
      case 2:
        return const SavedScreen();
      case 4:
        return const ProfileScreen();
      default:
        return const Center(child: Text('Coming Soon'));
    }
  }

  PreferredSizeWidget _buildProfileAppBar() {
    return AppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface),
        onPressed: () {
          setState(() {
            _bottomNavIndex = 0;
          });
        },
      ),
      title: Text(
        'My Profile',
        style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.more_vert, color: Theme.of(context).colorScheme.onSurface),
          onPressed: () {},
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(color: Theme.of(context).colorScheme.surfaceContainerHighest, height: 1),
      ),
    );
  }

  Widget _buildHomeTab() {
    return SingleChildScrollView(
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Theme.of(context).colorScheme.outline),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                         Navigator.push(context, MaterialPageRoute(builder: (_) => import_search_screen.SearchScreen(initialCategory: _selectedPrimaryCategory)));
                      },
                      child: Icon(Icons.search, color: Theme.of(context).colorScheme.onSurfaceVariant, size: 22),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => import_search_screen.SearchScreen(initialCategory: _selectedPrimaryCategory)));
                        },
                        child: AbsorbPointer(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Search properties, projects, localities...',
                              hintStyle: GoogleFonts.inter(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 14),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => import_search_screen.SearchScreen(initialCategory: _selectedPrimaryCategory, startVoiceSearchAutomatically: true)));
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Icon(
                          Icons.mic_off_outlined,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Primary Filters (Buy, Rent, Lease)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(child: GestureDetector(onTap: () => setState(() => _selectedPrimaryCategory = 'Buy'), child: _buildPrimaryFilter('Buy', _selectedPrimaryCategory == 'Buy'))),
                  const SizedBox(width: 8),
                  Expanded(child: GestureDetector(onTap: () => setState(() => _selectedPrimaryCategory = 'Rent'), child: _buildPrimaryFilter('Rent', _selectedPrimaryCategory == 'Rent'))),
                  const SizedBox(width: 8),
                  Expanded(child: GestureDetector(onTap: () => setState(() => _selectedPrimaryCategory = 'Lease'), child: _buildPrimaryFilter('Lease', _selectedPrimaryCategory == 'Lease'))),
                ],
              ),
            ),
            const SizedBox(height: 12),
            
            // Secondary Filters (Residential, Commercial, Plots, etc.)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildSecondaryFilter('Residential', true),
                  _buildSecondaryFilter('Commercial', false),
                  _buildSecondaryFilter('Plots', false),
                  _buildSecondaryFilter('PG/Co-living', false),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Featured Properties
            _buildSectionHeader('Featured Properties', onViewAll: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => ViewAllPropertiesScreen(
                title: 'Featured Properties',
                properties: [mockProperties[2], mockProperties[3], mockProperties[8], mockProperties[9]],
              )));
            }),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildFeaturedPropertyCard(
                    'DLF The Crest',
                    'DLF Phase 5, Gurgaon',
                    '₹2.45 Cr',
                    '3 Beds',
                    '3 Baths',
                    '2,215 sqft',
                    property: mockProperties[2],
                  ),
                  _buildFeaturedPropertyCard(
                    'M3M Golf',
                    'Sector 79, Gurgaon',
                    '₹1.80 Cr',
                    '2 Beds',
                    '2 Baths',
                    '1,500 sqft',
                    property: mockProperties[3],
                  ),
                  _buildFeaturedPropertyCard(
                    mockProperties[8].title,
                    mockProperties[8].location,
                    mockProperties[8].price,
                    '3 Beds',
                    '3 Baths',
                    '1,800 sqft',
                    property: mockProperties[8],
                  ),
                  _buildFeaturedPropertyCard(
                    mockProperties[9].title,
                    mockProperties[9].location,
                    mockProperties[9].price,
                    '4 Beds',
                    '3 Baths',
                    '2,400 sqft',
                    property: mockProperties[9],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // New Projects
            _buildSectionHeader('New Projects', onViewAll: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => ViewAllPropertiesScreen(
                title: 'New Projects',
                properties: [mockProperties[4], mockProperties[5], mockProperties[10]],
              )));
            }),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildNewProjectCard(
                    'Smart World One DXP',
                    'Smart World Developers',
                    'Sector 113, Gurgaon',
                    'Starting ₹3.15 Cr',
                    property: mockProperties[4],
                  ),
                  _buildNewProjectCard(
                    'Emaar Digi H...',
                    'Emaar India',
                    'Sector 62, Gur...',
                    'Starting ₹1.90 Cr',
                    property: mockProperties[5],
                  ),
                  _buildNewProjectCard(
                    mockProperties[10].title,
                    'Classic Builders',
                    mockProperties[10].location,
                    'Starting ${mockProperties[10].price}',
                    property: mockProperties[10],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Popular Locations
            _buildSectionHeader('Popular Locations'),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildLocationAvatar('Mumbai', '4.2k+ Properties', Icons.location_city),
                  _buildLocationAvatar('Delhi', '3.8k+ Properties', Icons.account_balance),
                  _buildLocationAvatar('Bangalore', '5.1k+ Properties', Icons.business),
                  _buildLocationAvatar('Hyderabad', '2.8k+ Properties', Icons.castle),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Recently Viewed
            _buildSectionHeader('Recently Viewed', onViewAll: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => ViewAllPropertiesScreen(
                title: 'Recently Viewed',
                properties: [mockProperties[0], mockProperties[1], mockProperties[11]],
              )));
            }),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildRecentlyViewedCard('Godrej Habitat', 'Sector 3, Gurgaon', '₹85 L', property: mockProperties[0]),
                  _buildRecentlyViewedCard('SS The Leaf', 'Bhilai, Chhattisgarh', '₹1.20 Cr', property: mockProperties[1]),
                  _buildRecentlyViewedCard(mockProperties[11].title, mockProperties[11].location, mockProperties[11].price, property: mockProperties[11]),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Explore by Category
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Explore by Category',
                style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.count(
                crossAxisCount: MediaQuery.of(context).orientation == Orientation.landscape ? 4 : 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 2.5,
                children: [
                  _buildCategoryCard(Icons.apartment, const Color(0xFFFDF2FA)),
                  _buildCategoryCard(Icons.house_outlined, const Color(0xFFF0FDF4)),
                  _buildCategoryCard(Icons.chair_outlined, const Color(0xFFF0F5FF)),
                  _buildCategoryCard(Icons.golf_course_outlined, const Color(0xFFFFFBEB)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Promo Banner
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4B85F0), Color(0xFF1E293B)],
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Find your dream property today',
                      style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Over 15,000+ verified listings across top cities with expert consultancy.',
                      style: GoogleFonts.inter(fontSize: 13, color: Colors.white.withAlpha(200), height: 1.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Start Searching',
                      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF82B1FF)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      titleSpacing: 16,
      title: Row(
        children: [
          Image.asset(
            'assets/images/MECO TECHNOLOGIES PR-Photoroom.png',
            width: 32,
            height: 32,
            errorBuilder: (context, error, stackTrace) => const Icon(Icons.public, color: Colors.green, size: 32),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MECO Real Estate',
                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: Theme.of(context).colorScheme.onSurface, height: 1.1),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'EXCELLENCE IN INNOVATION',
                  style: GoogleFonts.inter(fontSize: 7, fontWeight: FontWeight.w700, letterSpacing: 0.5, color: Theme.of(context).colorScheme.primary),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 160),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F5FF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.location_on_outlined, color: Theme.of(context).colorScheme.primary, size: 14),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      _currentLocation,
                      style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.primary),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()));
            },
            child: Badge(
              backgroundColor: Colors.red,
              smallSize: 8,
              child: Icon(Icons.notifications_outlined, color: Theme.of(context).colorScheme.onSurface, size: 26),
            ),
          ),
        ],
      ),
      actions: const [],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(color: Theme.of(context).colorScheme.surfaceContainerHighest, height: 1),
      ),
    );
  }

  Widget _buildPrimaryFilter(String text, bool isSelected) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? accentBlue : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isSelected ? accentBlue : Colors.grey.shade300),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildSecondaryFilter(String text, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1) : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? accentBlue : Colors.grey.shade300),
        ),
        child: Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onViewAll}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
          ),
          if (onViewAll != null)
            GestureDetector(
              onTap: onViewAll,
              child: Row(
                children: [
                  Text(
                    'View All',
                    style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.primary),
                  ),
                  Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.primary, size: 16),
                ],
              ),
            )
          else
            Row(
              children: [
                Text(
                  'View All',
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.primary),
                ),
                Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.primary, size: 16),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildFeaturedPropertyCard(String title, String location, String price, String beds, String baths, String sqft, {Property? property}) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: TiltPropertyCard(
        onTap: property != null
            ? () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => PropertyDetailsScreen(property: property)));
              }
            : null,
        child: Container(
        width: 260,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.surfaceContainerHighest),
        boxShadow: Theme.of(context).brightness == Brightness.dark
            ? [
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.04),
                  blurRadius: 12,
                  spreadRadius: 1,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.02),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                child: (property != null && property.imageUrl.isNotEmpty)
                    ? Image.network(
                        property.imageUrl,
                        height: 140,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 140,
                          color: Colors.grey.shade300,
                          child: const Center(child: Icon(Icons.apartment, size: 50, color: Colors.white54)),
                        ),
                      )
                    : Container(
                        height: 140,
                        color: Colors.grey.shade300,
                        child: const Center(child: Icon(Icons.apartment, size: 50, color: Colors.white54)),
                      ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: CircleAvatar(
                  radius: 14,
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  child: Icon(Icons.visibility_off_outlined, size: 16, color: Colors.grey.shade800),
                ),
              ),
              Positioned(
                bottom: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onSurface,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    price,
                    style: GoogleFonts.inter(color: Theme.of(context).colorScheme.surface, fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 15)),
                    Text('VERIFIED', style: GoogleFonts.inter(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 9)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on_outlined, size: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(location, style: GoogleFonts.inter(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 11)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(beds, style: GoogleFonts.inter(fontSize: 11, color: Theme.of(context).colorScheme.onSurface)),
                    _dot(),
                    Text(baths, style: GoogleFonts.inter(fontSize: 11, color: Theme.of(context).colorScheme.onSurface)),
                    _dot(),
                    Text(sqft, style: GoogleFonts.inter(fontSize: 11, color: Theme.of(context).colorScheme.onSurface)),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    ),
    ),
    );
  }

  Widget _buildNewProjectCard(String title, String builder, String location, String startingPrice, {Property? property}) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: TiltPropertyCard(
        onTap: property != null
            ? () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => PropertyDetailsScreen(property: property)));
              }
            : null,
        child: Container(
        width: 260,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.surfaceContainerHighest),
        boxShadow: Theme.of(context).brightness == Brightness.dark
            ? [
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.04),
                  blurRadius: 12,
                  spreadRadius: 1,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.02),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
            child: (property != null && property.imageUrl.isNotEmpty)
                ? Image.network(
                    property.imageUrl,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 120,
                      color: Colors.grey.shade300,
                      child: const Center(child: Icon(Icons.landscape, size: 50, color: Colors.white54)),
                    ),
                  )
                : Container(
                    height: 120,
                    color: Colors.grey.shade300,
                    child: const Center(child: Icon(Icons.landscape, size: 50, color: Colors.white54)),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 2),
                Text('By $builder', style: GoogleFonts.inter(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 11)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on_outlined, size: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(location, style: GoogleFonts.inter(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 11)),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F5FF),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    startingPrice,
                    style: GoogleFonts.inter(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w600, fontSize: 11),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    ),
    ),
    );
  }

  Widget _buildLocationAvatar(String city, String subtitle, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: Colors.grey.shade200,
            child: Icon(icon, size: 30, color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          Text(city, style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 12)),
          const SizedBox(height: 2),
          Text(subtitle, style: GoogleFonts.inter(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 9)),
        ],
      ),
    );
  }

  Widget _buildRecentlyViewedCard(String title, String location, String price, {Property? property}) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: TiltPropertyCard(
        onTap: property != null
            ? () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => PropertyDetailsScreen(property: property)));
              }
            : null,
        child: Container(
        width: 180,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.surfaceContainerHighest),
        boxShadow: Theme.of(context).brightness == Brightness.dark
            ? [
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.04),
                  blurRadius: 12,
                  spreadRadius: 1,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.02),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
            child: (property != null && property.imageUrl.isNotEmpty)
                ? Image.network(
                    property.imageUrl,
                    height: 100,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 100,
                      color: Colors.grey.shade300,
                      child: const Center(child: Icon(Icons.home, size: 40, color: Colors.white54)),
                    ),
                  )
                : Container(
                    height: 100,
                    color: Colors.grey.shade300,
                    child: const Center(child: Icon(Icons.home, size: 40, color: Colors.white54)),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(price, style: GoogleFonts.inter(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w700, fontSize: 12)),
                const SizedBox(height: 4),
                Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13)),
                const SizedBox(height: 2),
                Text(location, style: GoogleFonts.inter(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 10)),
              ],
            ),
          )
        ],
      ),
    ),
    ),
    );
  }

  Widget _buildCategoryCard(IconData icon, Color bgColor) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 28),
      ),
    );
  }

  Widget _dot() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Icon(Icons.circle, size: 3, color: Colors.grey.shade400),
    );
  }


}


