import 'dart:ui';
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
import 'location_bottom_sheet.dart';
import 'my_visits_screen.dart';
import 'package:easy_localization/easy_localization.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _bottomNavIndex = 0;
  String _currentLocation = 'Locating...';
  String _currentState = '';
  String _selectedCategory = 'Residential';

  static const Color accentBlue = Color(0xFF4B85F0);

  final Map<String, List<Map<String, dynamic>>> _statePopularLocations = {
    'Maharashtra': [
      {'name': 'Mumbai', 'count': '4.2k+', 'icon': Icons.location_city},
      {'name': 'Pune', 'count': '3.1k+', 'icon': Icons.business},
      {'name': 'Nagpur', 'count': '1.2k+', 'icon': Icons.home},
      {'name': 'Nashik', 'count': '800+', 'icon': Icons.landscape},
    ],
    'Karnataka': [
      {'name': 'Bangalore', 'count': '5.1k+', 'icon': Icons.business},
      {'name': 'Mysore', 'count': '1.5k+', 'icon': Icons.account_balance},
      {'name': 'Hubli', 'count': '600+', 'icon': Icons.home},
      {'name': 'Mangalore', 'count': '900+', 'icon': Icons.beach_access},
    ],
    'Telangana': [
      {'name': 'Hyderabad', 'count': '2.8k+', 'icon': Icons.castle},
      {'name': 'Warangal', 'count': '500+', 'icon': Icons.account_balance},
      {'name': 'Nizamabad', 'count': '300+', 'icon': Icons.home},
      {'name': 'Karimnagar', 'count': '200+', 'icon': Icons.location_city},
    ],
    'Delhi': [
      {'name': 'New Delhi', 'count': '3.8k+', 'icon': Icons.account_balance},
      {'name': 'Dwarka', 'count': '1.2k+', 'icon': Icons.home},
      {'name': 'Rohini', 'count': '900+', 'icon': Icons.location_city},
      {'name': 'Vasant Kunj', 'count': '600+', 'icon': Icons.business},
    ],
    'Haryana': [
      {'name': 'Gurgaon', 'count': '3.5k+', 'icon': Icons.business},
      {'name': 'Faridabad', 'count': '1.1k+', 'icon': Icons.location_city},
      {'name': 'Panipat', 'count': '400+', 'icon': Icons.home},
      {'name': 'Karnal', 'count': '300+', 'icon': Icons.account_balance},
    ],
    'Chhattisgarh': [
      {'name': 'Raipur', 'count': '1.2k+', 'icon': Icons.location_city},
      {'name': 'Bhilai', 'count': '800+', 'icon': Icons.business},
      {'name': 'Bilaspur', 'count': '500+', 'icon': Icons.home},
      {'name': 'Korba', 'count': '300+', 'icon': Icons.account_balance},
    ],
  };

  final List<Map<String, dynamic>> _defaultPopularLocations = [
    {'name': 'Mumbai', 'count': '4.2k+', 'icon': Icons.location_city},
    {'name': 'Delhi', 'count': '3.8k+', 'icon': Icons.account_balance},
    {'name': 'Bangalore', 'count': '5.1k+', 'icon': Icons.business},
    {'name': 'Hyderabad', 'count': '2.8k+', 'icon': Icons.castle},
  ];

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
              _currentState = placemarks[0].administrativeArea ?? '';
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
      onPopInvokedWithResult: (didPop, result) async {
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
              title: Text('home.leave_app_title'.tr(), style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
              content: Text('home.leave_app_desc'.tr(), style: GoogleFonts.inter()),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text('home.no'.tr(), style: GoogleFonts.inter(color: accentBlue)),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text('home.yes'.tr(), style: GoogleFonts.inter(color: Colors.red)),
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
        extendBody: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: _bottomNavIndex == 3
            ? _buildProfileAppBar()
            : (_bottomNavIndex == 0
                ? _buildAppBar()
                : AppBar(
                    leading: IconButton(
                      icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface),
                      onPressed: () {
                        setState(() {
                          _bottomNavIndex = 0;
                        });
                      },
                    ),
                    title: Text(
                      _bottomNavIndex == 1 ? 'home.nav_visits'.tr() : 'home.nav_wishlist'.tr(),
                      style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
                    ),
                    centerTitle: false,
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    elevation: 0,
                    actions: [
                      if (_bottomNavIndex == 1)
                        IconButton(
                          icon: Icon(Icons.more_vert, color: Theme.of(context).colorScheme.onSurface),
                          onPressed: () {},
                        ),
                    ],
                  )),
        body: _buildBody(),
        bottomNavigationBar: _buildCustomBottomNav(),
      ),
    );
  }

  Widget _buildCustomBottomNav() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20, left: 8, right: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(36),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 25,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(36),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    height: 72,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(36),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 1.5),
                    ),
                    child: LayoutBuilder(
                builder: (context, constraints) {
                  const int itemCount = 4;
                  final double itemWidth = constraints.maxWidth / itemCount;
                  const double pillWidth = 54;
                  const double pillHeight = 46;
                  final double pillLeft = _bottomNavIndex * itemWidth + (itemWidth - pillWidth) / 2;
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      // Sliding pill
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutCubic,
                        left: pillLeft,
                        top: (72 - pillHeight) / 2,
                        child: Container(
                          width: pillWidth,
                          height: pillHeight,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                      ),
                      // Nav items row (no individual backgrounds)
                      Row(
                        children: [
                          Expanded(child: _buildNavItem(Icons.home, Icons.home_outlined, 'home.nav_home'.tr(), 0)),
                          Expanded(child: _buildNavItem(Icons.calendar_month, Icons.calendar_month_outlined, 'home.nav_visits'.tr(), 1)),
                          Expanded(child: _buildNavItem(Icons.favorite, Icons.favorite_border, 'home.nav_wishlist'.tr(), 2)),
                          Expanded(child: _buildNavItem(Icons.person, Icons.person_outline, 'home.nav_account'.tr(), 3)),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    ),
          const SizedBox(width: 12),
          // AI Button
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('AI Features Coming Soon!')));
            },
            child: Container(
              height: 56,
              width: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFFE8C1F5), Color(0xFFF7C2C9)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(Icons.auto_awesome, color: Colors.white, size: 28),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData activeIcon, IconData icon, String label, int index) {
    final isSelected = _bottomNavIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _bottomNavIndex = index),
      child: Container(
        color: Colors.transparent,
        alignment: Alignment.center,
        // No background here — the pill is drawn in the Stack behind
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isSelected ? activeIcon : icon,
                key: ValueKey('${index}_$isSelected'),
                color: isSelected ? accentBlue : Colors.grey.shade700,
                size: 24,
              ),
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? accentBlue : Colors.grey.shade700,
                ),
              ),
            ),
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
        return const MyVisitsScreen(isEmbedded: true);
      case 2:
        return const SavedScreen();
      case 3:
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
        'profile.title'.tr(),
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
              child: GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const import_search_screen.SearchScreen()));
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Theme.of(context).colorScheme.outline),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search, color: Theme.of(context).colorScheme.onSurfaceVariant, size: 22),
                      const SizedBox(width: 8),
                      Expanded(
                        child: AbsorbPointer(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'home.search_hint'.tr(),
                              hintStyle: GoogleFonts.inter(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 14),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const import_search_screen.SearchScreen(startVoiceSearchAutomatically: true)));
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
            ),
            const SizedBox(height: 16),
            
            // Categories (Residential, Commercial, Plots, etc.)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildSecondaryFilter('Residential'),
                  _buildSecondaryFilter('Commercial'),
                  _buildSecondaryFilter('Plots'),
                  _buildSecondaryFilter('PG/Co-living'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Category-specific content ──────────────────────────────────
            ..._buildCategoryContent(),

            const SizedBox(height: 24),
            
            // Explore by Category
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'home.explore_category'.tr(),
                style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.count(
                padding: EdgeInsets.zero,
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
            const SizedBox(height: 12),
            
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
                      'home.promo_title'.tr(),
                      style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'home.promo_desc'.tr(),
                      style: GoogleFonts.inter(fontSize: 13, color: Colors.white.withAlpha(200), height: 1.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'home.start_searching'.tr(),
                      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF82B1FF)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 110),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo & Title
          Row(
            children: [
              Image.asset(
                'assets/images/MECO TECHNOLOGIES PR-Photoroom.png',
                width: 32,
                height: 32,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.public, color: Colors.green, size: 32),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'MECO Real Estate',
                    style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: Theme.of(context).colorScheme.onSurface, height: 1.1),
                  ),
                  Text(
                    'EXCELLENCE IN INNOVATION',
                    style: GoogleFonts.inter(fontSize: 7, fontWeight: FontWeight.w700, letterSpacing: 0.5, color: Theme.of(context).colorScheme.primary),
                  ),
                ],
              ),
            ],
          ),
          // Location Pill
          Flexible(
            child: GestureDetector(
              onTap: () async {
                final result = await showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (ctx) => Padding(
                    padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
                    child: const LocationBottomSheet(),
                  ),
                );

                if (result != null && result is Map<String, dynamic>) {
                  setState(() {
                    if (result['city'] != null && result['city'].toString().isNotEmpty) {
                      _currentLocation = result['city'];
                    }
                    if (result['region'] != null && result['region'].toString().isNotEmpty) {
                      final parts = result['region'].toString().split(', ');
                      _currentState = parts.last;
                    }
                  });
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
                    const SizedBox(width: 2),
                    Icon(Icons.keyboard_arrow_down, color: Theme.of(context).colorScheme.primary, size: 14),
                  ],
                ),
              ),
            ),
          ),
          // Notification Bell
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
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(color: Theme.of(context).colorScheme.surfaceContainerHighest, height: 1),
      ),
    );
  }
  // ── Category content builder ──────────────────────────────────────────────
  List<Widget> _buildCategoryContent() {
    switch (_selectedCategory) {
      case 'Commercial':
        return [
          _buildSectionHeader('home.feat_comm'.tr(), onViewAll: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => ViewAllPropertiesScreen(
              title: 'home.feat_comm'.tr(),
              properties: [mockProperties[4], mockProperties[5], mockProperties[6]],
            )));
          }),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(children: [
              _buildFeaturedPropertyCard('Cyber Hub Plaza', 'By DLF Commercial', 'DLF Cyber City, Gurgaon', 'Starting ₹3.20 Cr', property: mockProperties[4]),
              _buildFeaturedPropertyCard('Unitech Signature', 'By Unitech Group', 'Sector 30, Gurgaon', 'Starting ₹5.50 Cr', property: mockProperties[5]),
              _buildFeaturedPropertyCard('World Trade Tower', 'By WTC Developers', 'Noida Sector 16', 'Starting ₹2.80 Cr', property: mockProperties[6]),
            ]),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('home.new_office'.tr(), onViewAll: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => ViewAllPropertiesScreen(
              title: 'home.new_office'.tr(),
              properties: [mockProperties[7], mockProperties[8], mockProperties[9]],
            )));
          }),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(children: [
              _buildNewProjectCard('Prestige Tech Cloud', '₹1.80 Cr', property: mockProperties[7]),
              _buildNewProjectCard('Embassy Business Hub', '₹2.40 Cr', property: mockProperties[8]),
              _buildNewProjectCard('Salarpuria Softzone', '₹1.50 Cr', property: mockProperties[9]),
            ]),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Popular Locations'),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildLocationAvatar('Gurgaon', '2.1k+ Offices', Icons.business),
                _buildLocationAvatar('BKC Mumbai', '1.8k+ Offices', Icons.location_city),
                _buildLocationAvatar('Whitefield', '1.5k+ Offices', Icons.business_center),
                _buildLocationAvatar('HITEC City', '1.2k+ Offices', Icons.computer),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('home.recent_view'.tr(), onViewAll: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => ViewAllPropertiesScreen(
              title: 'home.recent_view'.tr(),
              properties: [mockProperties[4], mockProperties[5], mockProperties[6]],
            )));
          }),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(children: [
              _buildRecentlyViewedCard('Infinity IT Park', 'Andheri East, Mumbai', '₹2.10 Cr', property: mockProperties[4]),
              _buildRecentlyViewedCard('Mantri Commercio', 'Outer Ring Road, Bangalore', '₹3.50 Cr', property: mockProperties[5]),
              _buildRecentlyViewedCard('Adani Inspire', 'BKC, Mumbai', '₹4.80 Cr', property: mockProperties[6]),
            ]),
          ),
        ];

      case 'Plots':
        return [
          _buildSectionHeader('home.feat_plots'.tr(), onViewAll: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => ViewAllPropertiesScreen(
              title: 'home.feat_plots'.tr(),
              properties: [mockProperties[0], mockProperties[1], mockProperties[2]],
            )));
          }),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(children: [
              _buildFeaturedPropertyCard('DLF Garden City', 'By DLF Ltd.', 'Shilaj, Ahmedabad', 'Starting ₹45 L', property: mockProperties[0]),
              _buildFeaturedPropertyCard('Sobha International', 'By Sobha Ltd.', 'Devanahalli, Bangalore', 'Starting ₹60 L', property: mockProperties[1]),
              _buildFeaturedPropertyCard('Godrej Reserve', 'By Godrej Properties', 'Sarjapur Road, Bangalore', 'Starting ₹55 L', property: mockProperties[2]),
            ]),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('home.new_plots'.tr(), onViewAll: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => ViewAllPropertiesScreen(
              title: 'home.new_plots'.tr(),
              properties: [mockProperties[3], mockProperties[4], mockProperties[5]],
            )));
          }),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(children: [
              _buildNewProjectCard('Prestige Elysian', '₹38 L', property: mockProperties[3]),
              _buildNewProjectCard('Brigade Meadows', '₹42 L', property: mockProperties[4]),
              _buildNewProjectCard('Mahindra Happinest', '₹29 L', property: mockProperties[5]),
            ]),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Popular Locations'),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildLocationAvatar('Pune', '3.2k+ Plots', Icons.landscape),
                _buildLocationAvatar('Hyderabad', '2.8k+ Plots', Icons.grass),
                _buildLocationAvatar('Bangalore', '2.1k+ Plots', Icons.park),
                _buildLocationAvatar('Chennai', '1.9k+ Plots', Icons.terrain),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('home.recent_view'.tr(), onViewAll: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => ViewAllPropertiesScreen(
              title: 'home.recent_view'.tr(),
              properties: [mockProperties[0], mockProperties[1], mockProperties[2]],
            )));
          }),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(children: [
              _buildRecentlyViewedCard('Adarsh Palm Retreat', 'Varthur Road, Bangalore', '₹62 L', property: mockProperties[0]),
              _buildRecentlyViewedCard('TVS Emerald', 'Thirumazhisai, Chennai', '₹35 L', property: mockProperties[1]),
              _buildRecentlyViewedCard('Casagrand Ferns', 'Kovur, Chennai', '₹28 L', property: mockProperties[2]),
            ]),
          ),
        ];

      case 'PG/Co-living':
        return [
          _buildSectionHeader('home.feat_pg'.tr(), onViewAll: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => ViewAllPropertiesScreen(
              title: 'home.feat_pg'.tr(),
              properties: [mockProperties[6], mockProperties[7], mockProperties[8]],
            )));
          }),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(children: [
              _buildFeaturedPropertyCard('Stanza Living', 'By Stanza Living', 'Koramangala, Bangalore', 'Starting ₹8,000/mo', property: mockProperties[6]),
              _buildFeaturedPropertyCard('OYO Life', 'By OYO Rooms', 'Baner, Pune', 'Starting ₹9,500/mo', property: mockProperties[7]),
              _buildFeaturedPropertyCard('Zolo Stays', 'By Zolo', 'Sector 62, Noida', 'Starting ₹7,500/mo', property: mockProperties[8]),
            ]),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('home.new_pg'.tr(), onViewAll: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => ViewAllPropertiesScreen(
              title: 'home.new_pg'.tr(),
              properties: [mockProperties[9], mockProperties[10], mockProperties[11]],
            )));
          }),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(children: [
              _buildNewProjectCard('CoHo Homes', '₹10,000/mo', property: mockProperties[9]),
              _buildNewProjectCard('NestAway Plus', '₹12,000/mo', property: mockProperties[10]),
              _buildNewProjectCard('Colive Studio', '₹14,500/mo', property: mockProperties[11]),
            ]),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Popular Locations'),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildLocationAvatar('Bangalore', '5.5k+ PGs', Icons.business),
                _buildLocationAvatar('Pune', '3.8k+ PGs', Icons.home),
                _buildLocationAvatar('Hyderabad', '2.6k+ PGs', Icons.apartment),
                _buildLocationAvatar('Delhi', '4.1k+ PGs', Icons.location_city),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('home.recent_view'.tr(), onViewAll: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => ViewAllPropertiesScreen(
              title: 'home.recent_view'.tr(),
              properties: [mockProperties[6], mockProperties[7], mockProperties[8]],
            )));
          }),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(children: [
              _buildRecentlyViewedCard('Hello World PG', 'HSR Layout, Bangalore', '₹9,000/mo', property: mockProperties[6]),
              _buildRecentlyViewedCard('Liv-in PG', 'Wakad, Pune', '₹7,800/mo', property: mockProperties[7]),
              _buildRecentlyViewedCard('Settl. Coliving', 'Whitefield, Bangalore', '₹11,000/mo', property: mockProperties[8]),
            ]),
          ),
        ];

      // Residential (default)
      default:
        return [
          _buildSectionHeader('home.feat_prop'.tr(), onViewAll: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => ViewAllPropertiesScreen(
              title: 'home.feat_prop'.tr(),
              properties: [mockProperties[2], mockProperties[3], mockProperties[8], mockProperties[9]],
            )));
          }),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(children: [
              _buildFeaturedPropertyCard('Smart World One DXP', 'By Smart World Developers', 'Sector 113, Gurgaon', 'Starting ₹1.15 Cr', property: mockProperties[4]),
              _buildFeaturedPropertyCard('Emaar Digi Homes', 'By Emaar India', 'Sector 62, Gurgaon', 'Starting ₹1.90 Cr', property: mockProperties[5]),
              _buildFeaturedPropertyCard(mockProperties[10].title, 'By Classic Builders', mockProperties[10].location, 'Starting ${mockProperties[10].price}', property: mockProperties[10]),
            ]),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('home.new_prop'.tr(), onViewAll: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => ViewAllPropertiesScreen(
              title: 'home.new_prop'.tr(),
              properties: [mockProperties[2], mockProperties[3], mockProperties[8]],
            )));
          }),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(children: [
              _buildNewProjectCard('DLF The Crest', '₹2.45 Cr', property: mockProperties[2]),
              _buildNewProjectCard('M3M Golf', '₹1.80 Cr', property: mockProperties[3]),
              _buildNewProjectCard(mockProperties[8].title, mockProperties[8].price, property: mockProperties[8]),
            ]),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Popular Locations'),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: (_statePopularLocations[_currentState] ?? _defaultPopularLocations).map((loc) {
                return _buildLocationAvatar(loc['name'], '${loc['count']} Properties', loc['icon']);
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('home.recent_view'.tr(), onViewAll: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => ViewAllPropertiesScreen(
              title: 'home.recent_view'.tr(),
              properties: [mockProperties[0], mockProperties[1], mockProperties[11]],
            )));
          }),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(children: [
              _buildRecentlyViewedCard('Godrej Habitat', 'Sector 3, Gurgaon', '₹85 L', property: mockProperties[0]),
              _buildRecentlyViewedCard('SS The Leaf', 'Bhilai, Chhattisgarh', '₹1.20 Cr', property: mockProperties[1]),
              _buildRecentlyViewedCard(mockProperties[11].title, mockProperties[11].location, mockProperties[11].price, property: mockProperties[11]),
            ]),
          ),
        ];
    }
  }

  Widget _buildPromoBanner(String title, String subtitle, List<Color> gradientColors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 8),
            Text(subtitle, style: GoogleFonts.inter(fontSize: 13, color: Colors.white.withAlpha(200), height: 1.5)),
            const SizedBox(height: 16),
            Text('Start Searching', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF82B1FF))),
          ],
        ),
      ),
    );
  }

  Widget _buildSecondaryFilter(String text) {
    final isSelected = _selectedCategory == text;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = text),
      child: Padding(
        padding: const EdgeInsets.only(right: 8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
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
                    'home.view_all'.tr(),
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
                  'home.view_all'.tr(),
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.primary),
                ),
                Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.primary, size: 16),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildFeaturedPropertyCard(String title, String builder, String location, String price, {Property? property}) {
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
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4)),
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
                        height: 140,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(height: 140, color: Colors.grey.shade300, child: const Center(child: Icon(Icons.apartment, size: 50, color: Colors.white54))),
                      )
                    : Container(height: 140, color: Colors.grey.shade300, child: const Center(child: Icon(Icons.apartment, size: 50, color: Colors.white54))),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 15, color: Theme.of(context).colorScheme.onSurface)),
                    const SizedBox(height: 4),
                    Text(builder, style: GoogleFonts.inter(color: Colors.grey.shade600, fontSize: 12)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 14, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text(location, style: GoogleFonts.inter(color: Colors.grey.shade600, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F5FF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        price,
                        style: GoogleFonts.inter(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w700, fontSize: 13),
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

  Widget _buildNewProjectCard(String title, String price, {Property? property}) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: TiltPropertyCard(
        onTap: property != null
            ? () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => PropertyDetailsScreen(property: property)));
              }
            : null,
        child: Container(
          width: 220,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).colorScheme.surfaceContainerHighest),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
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
                            height: 160,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(height: 160, color: Colors.grey.shade300, child: const Center(child: Icon(Icons.apartment, size: 50, color: Colors.white54))),
                          )
                        : Container(height: 160, color: Colors.grey.shade300, child: const Center(child: Icon(Icons.apartment, size: 50, color: Colors.white54))),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: CircleAvatar(
                      radius: 14,
                      backgroundColor: Colors.white.withAlpha(200),
                      child: Icon(Icons.visibility_off_outlined, size: 16, color: Colors.grey.shade800),
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B), // Dark pill
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        price,
                        style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 15, color: Theme.of(context).colorScheme.onSurface),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'VERIFIED',
                        style: GoogleFonts.inter(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 9),
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
}


