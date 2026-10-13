import 'package:realty_app/l10n/app_localizations.dart';
import 'dart:ui';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'profile_screen.dart';
import 'saved_screen.dart';
import 'search_screen.dart' as import_search_screen;
import 'filter_screen.dart';
import 'buy_properties_screen.dart';
import 'models/property_model.dart';
import 'models/property_filters.dart';
import 'property_details_loader.dart';
import 'tilt_property_card.dart';
import 'notifications_screen.dart';
import 'location_bottom_sheet.dart';
import 'my_visits_screen.dart';
import 'widgets/ad_popup_widget.dart';
import 'services/property_api_service.dart';
import 'services/location_api_service.dart';
import 'models/location_model.dart';
import 'package:shimmer/shimmer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _bottomNavIndex = 0;
  late PageController _pageController;
  String _currentLocation = 'Locating...';
  String _currentState = '';
  String _selectedCategory = 'Residential';
  final Map<String, int> _visibleItemCounts = {};
  
  bool _isLoading = true;
  List<Property> _properties = [];
  bool _isLoadingLocations = true;
  List<LocationModel> _backendLocations = [];

  // Ad popup — shows every time the user opens the home screen
  bool _showAdPopup = false;

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
    _pageController = PageController(initialPage: _bottomNavIndex);
    _initializeData();
  }

  Future<void> _initializeData() async {
    // 1. Run location, property, and popular backend locations fetching in parallel
    await Future.wait([
      _fetchLocation().catchError((e) {
        print('Location fetch error: $e');
      }),
      _fetchProperties(),
      _fetchLocations(),
    ]);
  }

  Future<void> _fetchLocations() async {
    try {
      final locs = await LocationApiService.getLocations(popular: true);
      if (mounted) {
        setState(() {
          _backendLocations = locs;
          _isLoadingLocations = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching popular locations: $e');
      if (mounted) {
        setState(() {
          _isLoadingLocations = false;
        });
      }
    }
  }

  Future<void> _fetchProperties() async {
    try {
      final properties = await PropertyApiService.getProperties(limit: 10, status: 'ACTIVE');
      if (mounted) {
        setState(() {
          _properties = properties;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching properties: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
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
          _pageController.animateToPage(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
        } else {
          final shouldPop = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: Theme.of(context).colorScheme.surface,
              title: Text(AppLocalizations.of(context)!.homeLeaveAppTitle, style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
              content: Text(AppLocalizations.of(context)!.homeLeaveAppDesc, style: GoogleFonts.inter()),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(AppLocalizations.of(context)!.homeNo, style: GoogleFonts.inter(color: accentBlue)),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(AppLocalizations.of(context)!.homeYes, style: GoogleFonts.inter(color: Colors.red)),
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
                        _pageController.animateToPage(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
                      },
                    ),
                    title: Text(
                      _bottomNavIndex == 1 ? AppLocalizations.of(context)!.homeNavVisits : AppLocalizations.of(context)!.homeNavWishlist,
                      style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
                    ),
                    centerTitle: false,
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    elevation: 0,
                    actions: [
                      if (_bottomNavIndex == 1)
                        IconButton(
                          icon: const SizedBox.shrink(),
                          onPressed: () {},
                        ),
                    ],
                  )),
        body: _buildBodyWithAdOverlay(),
        bottomNavigationBar: _bottomNavIndex == 2 ? const SizedBox.shrink() : _buildCustomBottomNav(),
      ),
    );
  }

  Widget _buildCustomBottomNav() {
    return Padding(
      padding: EdgeInsets.only(bottom: 20 + MediaQuery.of(context).padding.bottom, left: 8, right: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(36),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.12),
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
                      border: Border.all(color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.4), width: 1.5),
                    ),
                    child: LayoutBuilder(
                builder: (context, constraints) {
                  const int itemCount = 4;
                  final double itemWidth = constraints.maxWidth / itemCount;
                  final double pillWidth = itemWidth - 12;
                  const double pillHeight = 46;
                  return AnimatedBuilder(
                    animation: _pageController,
                    builder: (context, child) {
                      double pageValue = _bottomNavIndex.toDouble();
                      if (_pageController.hasClients && _pageController.position.haveDimensions) {
                        pageValue = _pageController.page ?? pageValue;
                      }
                      final double pillLeft = pageValue * itemWidth + (itemWidth - pillWidth) / 2;
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          // Sliding pill
                          Positioned(
                            left: pillLeft,
                            top: (72 - pillHeight) / 2,
                            child: Container(
                              width: pillWidth,
                              height: pillHeight,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.outline,
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                          ),
                          // Nav items row (no individual backgrounds)
                          child!,
                        ],
                      );
                    },
                    child: Row(
                      children: [
                        Expanded(child: _buildNavItem(Icons.home, Icons.home_outlined, AppLocalizations.of(context)!.homeNavHome, 0)),
                        Expanded(child: _buildNavItem(Icons.calendar_month, Icons.calendar_month_outlined, AppLocalizations.of(context)!.homeNavVisits, 1)),
                        Expanded(child: _buildNavItem(Icons.favorite, Icons.favorite_border, AppLocalizations.of(context)!.homeNavWishlist, 2)),
                        Expanded(child: _buildNavItem(Icons.person, Icons.person_outline, AppLocalizations.of(context)!.homeNavAccount, 3)),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    ),
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            child: _bottomNavIndex == 0
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
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
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.15),
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
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData activeIcon, IconData icon, String label, int index) {
    final isSelected = _bottomNavIndex == index;
    return GestureDetector(
      onTap: () {
        if (_bottomNavIndex != index) {
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      },
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
                color: isSelected ? accentBlue : Theme.of(context).colorScheme.onSurfaceVariant,
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
                  color: isSelected ? accentBlue : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBodyWithAdOverlay() {
    return Stack(
      children: [
        _buildBody(),
        // Ad popup overlay — shown once per app open, dismissed by X tap
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 260),
          child: _showAdPopup
              ? AdPopupWidget(
                  key: const ValueKey('ad_popup'),
                  onClose: () => setState(() => _showAdPopup = false),
                  onExplore: () {
                    // Placeholder: navigate to Plots/Featured Properties
                    setState(() => _showAdPopup = false);
                  },
                )
              : const SizedBox.shrink(key: ValueKey('ad_hidden')),
        ),
      ],
    );
  }

  Widget _buildBody() {
    return PageView(
      controller: _pageController,
      onPageChanged: (index) {
        setState(() {
          _bottomNavIndex = index;
        });
      },
      children: [
        _buildHomeTab(),
        const MyVisitsScreen(isEmbedded: true),
        _bottomNavIndex == 2 
            ? SavedScreen(
                key: UniqueKey(),
                onExplore: () => _pageController.animateToPage(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut),
                onChange: () => setState(() {}),
              ) 
            : SavedScreen(
                onExplore: () => _pageController.animateToPage(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut),
                onChange: () => setState(() {}),
              ),
        const ProfileScreen(),
      ],
    );
  }

  PreferredSizeWidget _buildProfileAppBar() {
    return AppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface),
        onPressed: () {
          _pageController.animateToPage(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
        },
      ),
      title: Text(
        AppLocalizations.of(context)!.profileTitle,
        style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
      ),
      actions: [
        IconButton(
          icon: const SizedBox.shrink(),
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
    return RefreshIndicator(
      onRefresh: () => _initializeData(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
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
                              hintText: AppLocalizations.of(context)!.homeSearchHint,
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
                      GestureDetector(
                        onTap: () async {
                          final filters = await Navigator.push(context, MaterialPageRoute(builder: (_) => const FilterScreen()));
                          if (filters != null && mounted) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BuyPropertiesScreen(
                                  initialFilters: (filters is PropertyFilters && filters.isEmpty) ? null : filters,
                                ),
                              ),
                            );
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(left: 4, right: 8, top: 6, bottom: 6),
                          child: Icon(
                            Icons.tune,
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
                AppLocalizations.of(context)!.homeExploreCategory,
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
                      AppLocalizations.of(context)!.homePromoTitle,
                      style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.surface),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppLocalizations.of(context)!.homePromoDesc,
                      style: GoogleFonts.inter(fontSize: 13, color: Theme.of(context).colorScheme.surface.withAlpha(200), height: 1.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppLocalizations.of(context)!.homeStartSearching,
                      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF82B1FF)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 110),
          ],
        ),
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
          _buildSectionHeader(AppLocalizations.of(context)!.homeFeatComm, onLoadMore: () => setState(() => _visibleItemCounts['comm_feat'] = (_visibleItemCounts['comm_feat'] ?? 3) + 2)),
          _isLoading ? Padding(padding: const EdgeInsets.only(left: 16), child: _buildShimmerSkeleton()) : _buildHorizontalQueue('comm_feat', _properties.map((p) => _buildFeaturedPropertyCard(p.title, 'By ${p.partnerName}', p.location, p.price, property: p)).toList()),
          const SizedBox(height: 24),
          _buildSectionHeader(AppLocalizations.of(context)!.homeNewOffice, onLoadMore: () => setState(() => _visibleItemCounts['comm_new'] = (_visibleItemCounts['comm_new'] ?? 3) + 2)),
          _isLoading ? Padding(padding: const EdgeInsets.only(left: 16), child: _buildShimmerSkeleton()) : _buildHorizontalQueue('comm_new', _properties.map((p) => _buildNewProjectCard(p.title, p.price, property: p)).toList()),
          const SizedBox(height: 24),
          _buildSectionHeader('Popular Locations'),
          _buildPopularLocationsSection(),
          const SizedBox(height: 24),
          _buildSectionHeader(AppLocalizations.of(context)!.homeRecentView, onLoadMore: () => setState(() => _visibleItemCounts['comm_recent'] = (_visibleItemCounts['comm_recent'] ?? 3) + 2)),
          _isLoading ? Padding(padding: const EdgeInsets.only(left: 16), child: _buildShimmerSkeleton()) : _buildHorizontalQueue('comm_recent', _properties.map((p) => _buildRecentlyViewedCard(p.title, p.location, p.price, property: p)).toList()),
        ];

      case 'Plots':
        return [
          _buildSectionHeader(AppLocalizations.of(context)!.homeFeatPlots, onLoadMore: () => setState(() => _visibleItemCounts['plots_feat'] = (_visibleItemCounts['plots_feat'] ?? 3) + 2)),
          _isLoading ? Padding(padding: const EdgeInsets.only(left: 16), child: _buildShimmerSkeleton()) : _buildHorizontalQueue('plots_feat', _properties.map((p) => _buildFeaturedPropertyCard(p.title, 'By ${p.partnerName}', p.location, p.price, property: p)).toList()),
          const SizedBox(height: 24),
          _buildSectionHeader(AppLocalizations.of(context)!.homeNewPlots, onLoadMore: () => setState(() => _visibleItemCounts['plots_new'] = (_visibleItemCounts['plots_new'] ?? 3) + 2)),
          _isLoading ? Padding(padding: const EdgeInsets.only(left: 16), child: _buildShimmerSkeleton()) : _buildHorizontalQueue('plots_new', _properties.map((p) => _buildNewProjectCard(p.title, p.price, property: p)).toList()),
          const SizedBox(height: 24),
          _buildSectionHeader('Popular Locations'),
          _buildPopularLocationsSection(),
          const SizedBox(height: 24),
          _buildSectionHeader(AppLocalizations.of(context)!.homeRecentView, onLoadMore: () => setState(() => _visibleItemCounts['plots_recent'] = (_visibleItemCounts['plots_recent'] ?? 3) + 2)),
          _isLoading ? Padding(padding: const EdgeInsets.only(left: 16), child: _buildShimmerSkeleton()) : _buildHorizontalQueue('plots_recent', _properties.map((p) => _buildRecentlyViewedCard(p.title, p.location, p.price, property: p)).toList()),
        ];

      case 'PG/Co-living':
        return [
          _buildSectionHeader(AppLocalizations.of(context)!.homeFeatPg, onLoadMore: () => setState(() => _visibleItemCounts['pg_feat'] = (_visibleItemCounts['pg_feat'] ?? 3) + 2)),
          _isLoading ? Padding(padding: const EdgeInsets.only(left: 16), child: _buildShimmerSkeleton()) : _buildHorizontalQueue('pg_feat', _properties.map((p) => _buildFeaturedPropertyCard(p.title, 'By ${p.partnerName}', p.location, p.price, property: p)).toList()),
          const SizedBox(height: 24),
          _buildSectionHeader(AppLocalizations.of(context)!.homeNewPg, onLoadMore: () => setState(() => _visibleItemCounts['pg_new'] = (_visibleItemCounts['pg_new'] ?? 3) + 2)),
          _isLoading ? Padding(padding: const EdgeInsets.only(left: 16), child: _buildShimmerSkeleton()) : _buildHorizontalQueue('pg_new', _properties.map((p) => _buildNewProjectCard(p.title, p.price, property: p)).toList()),
          const SizedBox(height: 24),
          _buildSectionHeader('Popular Locations'),
          _buildPopularLocationsSection(),
          const SizedBox(height: 24),
          _buildSectionHeader(AppLocalizations.of(context)!.homeRecentView, onLoadMore: () => setState(() => _visibleItemCounts['pg_recent'] = (_visibleItemCounts['pg_recent'] ?? 3) + 2)),
          _isLoading ? Padding(padding: const EdgeInsets.only(left: 16), child: _buildShimmerSkeleton()) : _buildHorizontalQueue('pg_recent', _properties.map((p) => _buildRecentlyViewedCard(p.title, p.location, p.price, property: p)).toList()),
        ];

      // Residential (default)
      default:
        return [
          _buildSectionHeader(AppLocalizations.of(context)!.homeFeatProp, onLoadMore: () => setState(() => _visibleItemCounts['res_feat'] = (_visibleItemCounts['res_feat'] ?? 3) + 2)),
          _isLoading ? Padding(padding: const EdgeInsets.only(left: 16), child: _buildShimmerSkeleton()) : _buildHorizontalQueue('res_feat', _properties.map((p) => _buildFeaturedPropertyCard(p.title, 'By ${p.partnerName}', p.location, p.price, property: p)).toList()),
          const SizedBox(height: 24),
          _buildSectionHeader(AppLocalizations.of(context)!.homeNewProp, onLoadMore: () => setState(() => _visibleItemCounts['res_new'] = (_visibleItemCounts['res_new'] ?? 3) + 2)),
          _isLoading ? Padding(padding: const EdgeInsets.only(left: 16), child: _buildShimmerSkeleton()) : _buildHorizontalQueue('res_new', _properties.map((p) => _buildNewProjectCard(p.title, p.price, property: p)).toList()),
          const SizedBox(height: 24),
          _buildSectionHeader('Popular Locations'),
          _buildPopularLocationsSection(),
          const SizedBox(height: 24),
          _buildSectionHeader(AppLocalizations.of(context)!.homeRecentView, onLoadMore: () => setState(() => _visibleItemCounts['res_recent'] = (_visibleItemCounts['res_recent'] ?? 3) + 2)),
          _isLoading ? Padding(padding: const EdgeInsets.only(left: 16), child: _buildShimmerSkeleton()) : _buildHorizontalQueue('res_recent', _properties.map((p) => _buildRecentlyViewedCard(p.title, p.location, p.price, property: p)).toList()),
        ];
    }
  }
  Widget _buildPopularLocationsSection() {
    if (_isLoadingLocations) {
      return Padding(
        padding: const EdgeInsets.only(left: 16),
        child: _buildShimmerSkeleton(),
      );
    }

    if (_backendLocations.isNotEmpty) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: _backendLocations.map((loc) {
            final displayName = loc.cities.isNotEmpty ? loc.cities.first : loc.state;
            final subtitle = '${loc.propertiesCount} Properties';
            return _buildLocationAvatar(
              displayName,
              subtitle,
              Icons.location_city,
              imageUrl: loc.image,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BuyPropertiesScreen(
                      initialFilters: PropertyFilters(
                        city: loc.cities.isNotEmpty ? loc.cities.first : null,
                        state: loc.state,
                      ),
                    ),
                  ),
                );
              },
            );
          }).toList(),
        ),
      );
    }

    // Fallback to state / default local popular locations if backend list is empty
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: (_statePopularLocations[_currentState] ?? _defaultPopularLocations).map((loc) {
          return _buildLocationAvatar(loc['name'], '${loc['count']} Properties', loc['icon']);
        }).toList(),
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
            border: Border.all(color: isSelected ? accentBlue : Theme.of(context).colorScheme.outline),
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

  Widget _buildHorizontalQueue(String key, List<Widget> children) {
    if (children.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Center(
          child: Text(
            'No properties available.',
            style: GoogleFonts.inter(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }
    
    final count = _visibleItemCounts[key] ?? 3;
    
    List<Widget> queueItems = [];
    for (int i = 0; i < count; i++) {
      queueItems.add(children[i % children.length]);
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: queueItems,
      ),
    );
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onLoadMore}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
          ),
          if (onLoadMore != null)
            TextButton(
              onPressed: onLoadMore,
              style: TextButton.styleFrom(
                foregroundColor: accentBlue,
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text('Load More', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14)),
            ),
        ],
      ),
    );
  }

  Widget _buildFeaturedPropertyCard(String title, String builder, String location, String price, {Property? property}) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double cardWidth = screenWidth > 600 ? screenWidth * 0.4 : 260;
    const double cardHeight = 310;
    
    final String partnerLabel = (property != null && property.partnerName.isNotEmpty && property.partnerName != 'Partner')
        ? 'By ${property.partnerName}'
        : (builder.isNotEmpty ? (builder.startsWith('By ') ? builder : 'By $builder') : 'By Partner');

    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: TiltPropertyCard(
        onTap: property != null
            ? () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => PropertyDetailsLoader(propertyId: property.id)));
              }
            : null,
        child: Container(
          width: cardWidth,
          height: cardHeight,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).colorScheme.surfaceContainerHighest),
            boxShadow: [
              BoxShadow(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                child: (property != null && property.imageUrl.isNotEmpty)
                    ? CachedNetworkImage(
                        imageUrl: property.imageUrl,
                        height: 140,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) => Container(height: 140, color: Theme.of(context).colorScheme.outline, child: const Center(child: Icon(Icons.apartment, size: 50, color: Colors.white54))),
                      )
                    : Container(height: 140, color: Theme.of(context).colorScheme.outline, child: const Center(child: Icon(Icons.apartment, size: 50, color: Colors.white54))),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 38,
                        child: Text(
                          title,
                          style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14, color: Theme.of(context).colorScheme.onSurface),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        partnerLabel,
                        style: GoogleFonts.inter(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              location,
                              style: GoogleFonts.inter(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
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
                          if (property != null) AqiBadge(property: property),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNewProjectCard(String title, String price, {Property? property}) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double cardWidth = screenWidth > 600 ? screenWidth * 0.35 : 220;
    const double cardHeight = 220;

    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: TiltPropertyCard(
        onTap: property != null
            ? () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => PropertyDetailsLoader(propertyId: property.id)));
              }
            : null,
        child: Container(
          width: cardWidth,
          height: cardHeight,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).colorScheme.surfaceContainerHighest),
            boxShadow: [
              BoxShadow(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
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
                        ? CachedNetworkImage(
                            imageUrl: property.imageUrl,
                            height: 160,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) => Container(height: 160, color: Theme.of(context).colorScheme.outline, child: const Center(child: Icon(Icons.apartment, size: 50, color: Colors.white54))),
                          )
                        : Container(height: 160, color: Theme.of(context).colorScheme.outline, child: const Center(child: Icon(Icons.apartment, size: 50, color: Colors.white54))),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: CircleAvatar(
                      radius: 14,
                      backgroundColor: Theme.of(context).colorScheme.surface.withAlpha(200),
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
                        style: GoogleFonts.inter(color: Theme.of(context).colorScheme.surface, fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14, color: Theme.of(context).colorScheme.onSurface),
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
                      if (property != null) ...[
                        const SizedBox(width: 4),
                        AqiBadge(property: property),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationAvatar(String city, String subtitle, IconData icon, {String? imageUrl, VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: GestureDetector(
        onTap: onTap ?? () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BuyPropertiesScreen(
                initialFilters: PropertyFilters(city: city),
              ),
            ),
          );
        },
        child: Column(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              backgroundImage: (imageUrl != null && imageUrl.isNotEmpty)
                  ? CachedNetworkImageProvider(imageUrl)
                  : null,
              child: (imageUrl == null || imageUrl.isEmpty)
                  ? Icon(icon, size: 28, color: Theme.of(context).colorScheme.onSurfaceVariant)
                  : null,
            ),
            const SizedBox(height: 8),
            Text(city, style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 12)),
            const SizedBox(height: 2),
            Text(subtitle, style: GoogleFonts.inter(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 9)),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentlyViewedCard(String title, String location, String price, {Property? property}) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double cardWidth = screenWidth > 600 ? screenWidth * 0.3 : 180;
    const double cardHeight = 210;

    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: TiltPropertyCard(
        onTap: property != null
            ? () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => PropertyDetailsLoader(propertyId: property.id)));
              }
            : null,
        child: Container(
          width: cardWidth,
          height: cardHeight,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).colorScheme.surfaceContainerHighest),
            boxShadow: Theme.of(context).brightness == Brightness.dark
                ? [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.04),
                      blurRadius: 12,
                      spreadRadius: 1,
                      offset: const Offset(0, 4),
                    ),
                    BoxShadow(
                      color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.02),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                    BoxShadow(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.04),
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
                    ? CachedNetworkImage(
                        imageUrl: property.imageUrl,
                        height: 100,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) => Container(
                          height: 100,
                          color: Theme.of(context).colorScheme.outline,
                          child: const Center(child: Icon(Icons.home, size: 40, color: Colors.white54)),
                        ),
                      )
                    : Container(
                        height: 100,
                        color: Theme.of(context).colorScheme.outline,
                        child: const Center(child: Icon(Icons.home, size: 40, color: Colors.white54)),
                      ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(price, style: GoogleFonts.inter(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w700, fontSize: 12)),
                          if (property != null) AqiBadge(property: property),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        title,
                        style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        location,
                        style: GoogleFonts.inter(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 10),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Shimmer Skeleton Builder ──────────────────────────────────────────────
  Widget _buildShimmerSkeleton() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      child: Row(
        children: List.generate(3, (index) {
          return Container(
            width: 260,
            height: 310,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Theme.of(context).colorScheme.outlineVariant, width: 1),
            ),
            child: Shimmer.fromColors(
              baseColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              highlightColor: Theme.of(context).colorScheme.surface,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 140,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(height: 16, width: double.infinity, color: Colors.white),
                          const SizedBox(height: 8),
                          Container(height: 14, width: 150, color: Colors.white),
                          const SizedBox(height: 8),
                          Container(height: 14, width: 100, color: Colors.white),
                          const Spacer(),
                          Container(height: 24, width: 90, color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
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

class AqiBadge extends StatefulWidget {
  final Property property;
  const AqiBadge({super.key, required this.property});

  @override
  State<AqiBadge> createState() => _AqiBadgeState();
}

class _AqiBadgeState extends State<AqiBadge> {
  int? _aqi;

  @override
  void initState() {
    super.initState();
    _fetchAqi();
  }

  Future<void> _fetchAqi() async {
    try {
      double? lat = widget.property.lat;
      double? lng = widget.property.lng;

      if (lat == null || lng == null) {
        if (widget.property.city.isNotEmpty) {
          final geoRes = await http.get(Uri.parse('https://geocoding-api.open-meteo.com/v1/search?name=${Uri.encodeComponent(widget.property.city)}&count=1'));
          if (geoRes.statusCode == 200) {
            final geoData = jsonDecode(geoRes.body);
            if (geoData['results'] != null && geoData['results'].isNotEmpty) {
              lat = geoData['results'][0]['latitude'];
              lng = geoData['results'][0]['longitude'];
            }
          }
        }
      }

      if (lat != null && lng != null) {
        final aqiRes = await http.get(Uri.parse('https://air-quality-api.open-meteo.com/v1/air-quality?latitude=$lat&longitude=$lng&current=us_aqi'));
        if (aqiRes.statusCode == 200) {
          final aqiData = jsonDecode(aqiRes.body);
          if (aqiData['current'] != null && aqiData['current']['us_aqi'] != null) {
            if (mounted) {
              setState(() {
                _aqi = (aqiData['current']['us_aqi'] as num).toInt();
              });
            }
          }
        }
      }
    } catch (err) {
      debugPrint("Failed to fetch AQI: $err");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_aqi == null) return const SizedBox.shrink();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.air, size: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(
          'AQI: $_aqi',
          style: GoogleFonts.inter(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}


