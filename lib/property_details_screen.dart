import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'models/property_model.dart';
import 'seller_profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import 'view_all_properties_screen.dart';
import 'login_screen.dart';
import 'create_account_screen.dart';
import 'widgets/remove_shortlist_dialog.dart';
import 'full_screen_image_gallery.dart';
import 'confirm_visit_details_screen.dart';
import 'financial_tools_screen.dart';
import 'widgets/enquiry_bottom_sheet.dart';
import 'services/property_api_service.dart';
import 'services/wishlist_api_service.dart';
import 'services/auth_api_service.dart';

class PropertyDetailsScreen extends StatefulWidget {
  final Property property;

  const PropertyDetailsScreen({super.key, required this.property});

  @override
  State<PropertyDetailsScreen> createState() => _PropertyDetailsScreenState();
}

class _PropertyDetailsScreenState extends State<PropertyDetailsScreen> {
  static const Color accentBlue = Color(0xFF4B85F0);


  bool _isLoggedIn = false;
  int _currentImageIndex = 0;
  bool _isAboutExpanded = false;
  bool _isFeaturesExpanded = false;
  bool _isDetailsExpanded = false;
  bool _isLoadingSimilar = true;
  List<Property> _similarProperties = [];
  int? _aqi;

  late PageController _pageController;

  // Persisted Visit Booking State
  String? _visitSelectedTime;
  final TextEditingController _visitNameController = TextEditingController();
  final TextEditingController _visitPhoneController = TextEditingController();
  final TextEditingController _visitSpecialReqController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    _fetchSimilarProperties();
    _fetchAqi();
    _pageController = PageController();
  }

  Future<void> _fetchAqi() async {
    final property = widget.property;
    try {
      double? lat = property.lat;
      double? lng = property.lng;

      if (lat == null || lng == null) {
        if (property.city.isNotEmpty) {
          final geoRes = await http.get(Uri.parse('https://geocoding-api.open-meteo.com/v1/search?name=${Uri.encodeComponent(property.city)}&count=1'));
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

  Color _getAqiColor(int aqi) {
    if (aqi <= 50) return Colors.green;
    if (aqi <= 100) return Colors.yellow.shade700;
    if (aqi <= 150) return Colors.orange;
    if (aqi <= 200) return Colors.red;
    if (aqi <= 300) return Colors.purple;
    return Colors.brown;
  }

  Future<void> _fetchSimilarProperties() async {
    try {
      final properties = await PropertyApiService.getProperties(limit: 10, status: 'ACTIVE');
      if (mounted) {
        setState(() {
          _similarProperties = properties.where((p) => p.id != widget.property.id).toList();
          _isLoadingSimilar = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingSimilar = false);
      }
    }
  }

  @override
  void dispose() {
    _visitNameController.dispose();
    _visitPhoneController.dispose();
    _visitSpecialReqController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      });
      if (_isLoggedIn) {
        try {
          final profile = await AuthApiService.getUserProfile();
          if (mounted) {
            setState(() {
              if (_visitNameController.text.isEmpty) {
                _visitNameController.text = profile.fullName;
              }
              if (_visitPhoneController.text.isEmpty) {
                _visitPhoneController.text = profile.number;
              }
            });
          }
        } catch (_) {
          // ignore profile fetch error
        }
      }
    }
  }

  void _onHeartTapped(Property property) async {
    if (property.isFavorite) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Property is already added in the wishlist'),
          backgroundColor: accentBlue,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    WishlistApiService.handleToggleWishlist(
      context,
      property.id,
      onUpdate: (newState) {
        if (mounted) {
          setState(() {
            property.isFavorite = newState;
          });
        }
      },
      onError: (errorMsg) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMsg),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
    );
  }


  IconData _getIconForAmenity(String amenity) {
    final lower = amenity.toLowerCase();
    if (lower.contains('bed')) return Icons.bed_outlined;
    if (lower.contains('bath')) return Icons.bathtub_outlined;
    if (lower.contains('park')) return Icons.local_parking_outlined;
    if (lower.contains('lift') || lower.contains('elevator')) return Icons.elevator_outlined;
    if (lower.contains('secur')) return Icons.security_outlined;
    if (lower.contains('power')) return Icons.bolt_outlined;
    if (lower.contains('balcon')) return Icons.balcony_outlined;
    if (lower.contains('pool')) return Icons.pool_outlined;
    if (lower.contains('gym') || lower.contains('fitness')) return Icons.fitness_center_outlined;
    if (lower.contains('garden')) return Icons.park_outlined;
    if (lower.contains('wifi') || lower.contains('internet')) return Icons.wifi_outlined;
    if (lower.contains('fire')) return Icons.local_fire_department_outlined;
    return Icons.check_circle_outline;
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 32,
      thickness: 1,
      color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
    );
  }

  Widget _buildFeatureChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmenityItem(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: accentBlue),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final property = widget.property;
    
    // Sync local object state with the global wishlist cache to ensure accurate UI
    property.isFavorite = WishlistApiService.isWishlisted(property.id);

    final List<String> imageUrls = property.images.isNotEmpty 
        ? property.images 
        : [property.imageUrl];

    final area = property.builtUpArea.isNotEmpty ? '${property.builtUpArea} sq ft' : 'Area N/A';
    final bedrooms = property.bedrooms > 0 ? '${property.bedrooms} Bedrooms' : 'N/A';
    final baths = property.bathrooms > 0 ? '${property.bathrooms} Baths' : 'N/A';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Header
                Stack(
                  children: [
                    SizedBox(
                      height: 250,
                      child: PageView.builder(
                        controller: _pageController,
                        onPageChanged: (index) {
                          setState(() {
                            _currentImageIndex = index;
                          });
                        },
                        itemCount: imageUrls.length,
                        itemBuilder: (context, index) {
                          final url = imageUrls[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => FullScreenImageGallery(
                                    imageUrls: imageUrls,
                                    initialIndex: index,
                                  ),
                                ),
                              );
                            },
                            child: url.startsWith('assets/')
                                ? Image.asset(
                                    url,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  )
                                : CachedNetworkImage(
                                    imageUrl: url,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                          );
                        },
                      ),
                    ),
                    Positioned(
                      top: MediaQuery.of(context).padding.top + 8,
                      left: 16,
                      child: CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.surface,
                        child: IconButton(
                          icon: Icon(
                            Icons.arrow_back,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ),
                    Positioned(
                      top: MediaQuery.of(context).padding.top + 8,
                      right: 16,
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Theme.of(context).colorScheme.surface,
                            child: IconButton(
                              icon: Icon(
                                property.isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: property.isFavorite
                                    ? Colors.red
                                    : Theme.of(context).colorScheme.onSurface,
                              ),
                              onPressed: () => _onHeartTapped(property),
                            ),
                          ),
                          const SizedBox(width: 12),
                          CircleAvatar(
                            backgroundColor: Theme.of(context).colorScheme.surface,
                            child: IconButton(
                              icon: Icon(
                                Icons.share,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                              onPressed: () => _showShareBottomSheet(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '${_currentImageIndex + 1}/4',
                          style: GoogleFonts.inter(
                            color: Theme.of(context).colorScheme.surface,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 16,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          4,
                          (index) => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _currentImageIndex == index
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.5),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // Thumbnail Gallery
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        // Image Thumbnails
                        ...List.generate(imageUrls.length, (index) {
                          return GestureDetector(
                            onTap: () {
                              _pageController.animateToPage(
                                index,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.only(right: 8),
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: _currentImageIndex == index
                                      ? accentBlue
                                      : Colors.transparent,
                                  width: 2,
                                ),
                                image: DecorationImage(
                                  image: imageUrls[index].startsWith('assets/')
                                      ? AssetImage(imageUrls[index]) as ImageProvider
                                      : CachedNetworkImageProvider(imageUrls[index]),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          );
                        }),
                        // Video Thumbnail
                        GestureDetector(
                          onTap: () {
                            // Video action
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Theme.of(context).colorScheme.outlineVariant,
                                width: 1,
                              ),
                              color: Theme.of(context).colorScheme.surface,
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.play_circle_outline, color: Theme.of(context).colorScheme.onSurfaceVariant, size: 24),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Video',
                                    style: GoogleFonts.inter(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // 360 View Thumbnail
                        GestureDetector(
                          onTap: () {
                            // 360 view action
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Theme.of(context).colorScheme.outlineVariant,
                                width: 1,
                              ),
                              color: Theme.of(context).colorScheme.surface,
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.threesixty, color: Theme.of(context).colorScheme.onSurfaceVariant, size: 24),
                                  const SizedBox(height: 2),
                                  Text(
                                    '360°',
                                    style: GoogleFonts.inter(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Content Body
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        property.title,
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Price
                      Text(
                        property.price,
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: accentBlue,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Location
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 16,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            property.location,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Category Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: accentBlue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${property.type} • ${property.category}',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: accentBlue,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Quick Stats
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (property.builtUpArea.isNotEmpty)
                            _buildFeatureChip(Icons.square_foot, '${property.builtUpArea} sq ft'),
                          if (property.bedrooms > 0)
                            _buildFeatureChip(Icons.bed, '${property.bedrooms} Bed'),
                          if (property.bathrooms > 0)
                            _buildFeatureChip(Icons.bathtub_outlined, '${property.bathrooms} Bath'),
                          if (property.parking.isNotEmpty)
                            _buildFeatureChip(Icons.directions_car_outlined, property.parking),
                          if (property.facing.isNotEmpty)
                            _buildFeatureChip(Icons.explore_outlined, '${property.facing} Facing'),
                          if (property.floor.isNotEmpty)
                            _buildFeatureChip(Icons.layers_outlined, 'Floor ${property.floor}'),
                        ],
                      ),

                      _buildDivider(),

                      // About This Property
                      _buildSectionHeader('About This Property'),
                      const SizedBox(height: 8),
                      Text(
                        _isAboutExpanded
                            ? (property.description.isNotEmpty ? property.description : 'No description available for this property.')
                            : (property.description.isNotEmpty 
                                ? (property.description.length > 150 ? '${property.description.substring(0, 150)}...' : property.description) 
                                : 'No description available for this property.'),
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (property.description.length > 150)
                        GestureDetector(
                        onTap: () {
                          setState(() {
                            _isAboutExpanded = !_isAboutExpanded;
                          });
                        },
                        child: Row(
                          children: [
                            Text(
                              _isAboutExpanded ? 'Read Less' : 'Read More',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: accentBlue,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              _isAboutExpanded ? Icons.keyboard_arrow_up : Icons.arrow_forward,
                              size: 14,
                              color: accentBlue,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FinancialToolsScreen(property: property),
                              ),
                            );
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: accentBlue.withValues(alpha: 0.1),
                            foregroundColor: accentBlue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Calculate this Property',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      _buildDivider(),

                      // Features & Amenities
                      _buildSectionHeader('Features & Amenities'),
                      const SizedBox(height: 16),
                      property.amenities.isEmpty
                          ? const Text("No specific amenities listed.", style: TextStyle(color: Colors.grey))
                          : GridView.count(
                              padding: EdgeInsets.zero,
                              crossAxisCount: MediaQuery.of(context).orientation == Orientation.landscape ? 4 : 2,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              mainAxisSpacing: 8,
                              crossAxisSpacing: 8,
                              childAspectRatio: 3.5,
                              children: property.amenities
                                  .take(_isFeaturesExpanded ? property.amenities.length : 8)
                                  .map((amenity) => _buildAmenityItem(_getIconForAmenity(amenity), amenity))
                                  .toList(),
                            ),
                      const SizedBox(height: 12),
                      if (property.amenities.length > 8)
                        GestureDetector(
                        onTap: () {
                          setState(() {
                            _isFeaturesExpanded = !_isFeaturesExpanded;
                          });
                        },
                        child: Row(
                          children: [
                            Text(
                              _isFeaturesExpanded ? 'View Less' : 'View All Features',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: accentBlue,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              _isFeaturesExpanded ? Icons.keyboard_arrow_up : Icons.arrow_forward,
                              size: 14,
                              color: accentBlue,
                            ),
                          ],
                        ),
                      ),

                      _buildDivider(),

                      // Location Map
                      _buildSectionHeader('Location'),
                      const SizedBox(height: 12),
                      if (property.lat != null && property.lng != null)
                        Container(
                          height: 150,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: GoogleMap(
                            initialCameraPosition: CameraPosition(
                              target: LatLng(property.lat!, property.lng!),
                              zoom: 14,
                            ),
                            markers: {
                              Marker(
                                markerId: const MarkerId('property_loc'),
                                position: LatLng(property.lat!, property.lng!),
                              ),
                            },
                            zoomControlsEnabled: false,
                            scrollGesturesEnabled: false,
                            myLocationButtonEnabled: false,
                          ),
                        ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              property.address.isNotEmpty ? property.address : property.location,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          if (_aqi != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getAqiColor(_aqi!).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: _getAqiColor(_aqi!)),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    'AQI',
                                    style: GoogleFonts.inter(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: _getAqiColor(_aqi!),
                                    ),
                                  ),
                                  Text(
                                    '$_aqi',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: _getAqiColor(_aqi!),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () async {
                          final query = Uri.encodeComponent(property.address.isNotEmpty ? property.address : property.location);
                          final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri);
                          } else {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Could not open map.')),
                              );
                            }
                          }
                        },
                        child: Row(
                          children: [
                            Text(
                              'View on Map',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: accentBlue,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.arrow_forward,
                              size: 14,
                              color: accentBlue,
                            ),
                          ],
                        ),
                      ),

                      _buildDivider(),

                      // Listed By
                      _buildSectionHeader('Listed By'),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundImage: (property.partner?.profilePicture.isNotEmpty == true)
                                ? NetworkImage(property.partner!.profilePicture)
                                : null,
                            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                            child: (property.partner?.profilePicture.isEmpty ?? true)
                                ? Icon(Icons.person, color: Theme.of(context).colorScheme.onSurfaceVariant)
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  property.partner?.fullName ?? 'Property Owner',
                                  style: GoogleFonts.inter(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                                Text(
                                  property.partner?.companyName ?? 'Independent Agent',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SellerProfileScreen(),
                            ),
                          );
                        },
                        child: Row(
                          children: [
                            Text(
                              'View Profile',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: accentBlue,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.arrow_forward,
                              size: 14,
                              color: accentBlue,
                            ),
                          ],
                        ),
                      ),

                      _buildDivider(),

                      // Property Details Table
                      _buildSectionHeader('Property Details'),
                      const SizedBox(height: 12),
                      if (property.type.isNotEmpty) _buildDetailRow('Property Type', property.type),
                      if (property.category.isNotEmpty) _buildDetailRow('Listing Type', property.category),
                      if (property.address.isNotEmpty) _buildDetailRow('Address', property.address),
                      if (_isDetailsExpanded) ...[
                        if (property.furnishing.isNotEmpty) _buildDetailRow('Furnishing', property.furnishing),
                        if (property.carpetArea.isNotEmpty) _buildDetailRow('Carpet Area', '${property.carpetArea} sq ft'),
                        if (property.parking.isNotEmpty) _buildDetailRow('Parking', property.parking),
                        if (property.age.isNotEmpty) _buildDetailRow('Age of Property', property.age),
                        if (property.totalFloors.isNotEmpty) _buildDetailRow('Total Floors', property.totalFloors),
                        if (property.waterSupply.isNotEmpty) _buildDetailRow('Water Supply', property.waterSupply),
                        if (property.balconies > 0) _buildDetailRow('Balconies', property.balconies.toString()),
                        if (property.status.isNotEmpty) _buildDetailRow('Status', property.status),
                        if (property.amenities.isNotEmpty) _buildDetailRow('Amenities', '${property.amenities.length} Included'),
                        if (property.createdAt != null)
                           _buildDetailRow('Listed On', property.createdAt!.split('T').first),
                      ],
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isDetailsExpanded = !_isDetailsExpanded;
                          });
                        },
                        child: Row(
                          children: [
                            Text(
                              _isDetailsExpanded ? 'View Less Details' : 'View More Details',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: accentBlue,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              _isDetailsExpanded ? Icons.arrow_upward : Icons.arrow_downward,
                              size: 14,
                              color: accentBlue,
                            ),
                          ],
                        ),
                      ),

                      _buildDivider(),

                      // Similar Properties
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildSectionHeader('Similar Properties'),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ViewAllPropertiesScreen(
                                    title: 'Similar Properties',
                                    properties: _similarProperties,
                                  ),
                                ),
                              );
                            },
                            child: Text(
                              'View All',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: accentBlue,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _isLoadingSimilar
                          ? const Center(child: CircularProgressIndicator())
                          : _similarProperties.isEmpty
                              ? const Text("No similar properties found.")
                              : SizedBox(
                                  height: 180,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: _similarProperties.length > 5
                                        ? 5
                                        : _similarProperties.length,
                                    itemBuilder: (context, index) {
                                      final similar = _similarProperties[index];
                                      return Container(
                              width: 200,
                              margin: const EdgeInsets.only(right: 16),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.outlineVariant.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(12),
                                    ),
                                    child: CachedNetworkImage(
                                      imageUrl: similar.imageUrl,
                                      height: 100,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          similar.price,
                                          style: GoogleFonts.inter(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: accentBlue,
                                          ),
                                        ),
                                        Text(
                                          similar.title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.inter(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.onSurface,
                                          ),
                                        ),
                                        Text(
                                          similar.location,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.inter(
                                            fontSize: 10,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),

                      // Extra padding for bottom action bar
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Fixed Bottom Nav
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + MediaQuery.of(context).padding.bottom),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
                    offset: const Offset(0, -4),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton(
                        onPressed: () {
                          if (!_isLoggedIn) {
                            _showEnquiryLoginSheet(context);
                          } else {
                            _showLoggedInEnquirySheet(context);
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: accentBlue),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Enquire',
                          style: GoogleFonts.inter(
                            color: accentBlue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          if (!_isLoggedIn) {
                            _showScheduleVisitLoginSheet(context);
                          } else {
                            _showScheduleVisitSheet(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentBlue,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Schedule Visit',
                          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLoggedInEnquirySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => EnquiryBottomSheet(
        property: widget.property,
        isLoggedIn: _isLoggedIn,
      ),
    );
  }

  void _showEnquiryLoginSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => SingleChildScrollView(
        child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: accentBlue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.chat_bubble_outline, color: accentBlue, size: 36),
            ),
            const SizedBox(height: 20),
            Text(
              'Send Enquiry',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Please sign in or create an account to send instant messages and custom queries to property owners.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  ).then((_) => _checkLoginStatus());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentBlue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Sign In',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const CreateAccountScreen()),
                  ).then((_) => _checkLoginStatus());
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.onSurface,
                  side: BorderSide(color: Theme.of(context).colorScheme.outline),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Create Account',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 12),
          ],
        ),
      ),
      ),
    );
  }

  void _showScheduleVisitLoginSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: EdgeInsets.fromLTRB(
            28,
            20,
            28,
            MediaQuery.of(context).viewInsets.bottom + 32,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 28),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Calendar icon circle
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: accentBlue.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.calendar_month_outlined,
                  color: accentBlue,
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Schedule a Visit',
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Please sign in or create an account to select comfortable time slots and lock visits with agents.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 28),
              // Sign In button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    ).then((_) => _checkLoginStatus());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Sign In',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              // Create Account text button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const CreateAccountScreen()),
                    ).then((_) => _checkLoginStatus());
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.onSurface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Create Account',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showScheduleVisitSheet(BuildContext context) {
    final property = widget.property;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        // Local state managed with StatefulBuilder

        DateTime focusedMonth = DateTime.now();
        int? selectedDay;

        return StatefulBuilder(
          builder: (sheetBuilderCtx, setSheetState) {
            final colorScheme = Theme.of(sheetBuilderCtx).colorScheme;
            final isDark = Theme.of(sheetBuilderCtx).brightness == Brightness.dark;

            final daysInMonth = DateTimeRange(
              start: DateTime(focusedMonth.year, focusedMonth.month, 1),
              end: DateTime(focusedMonth.year, focusedMonth.month + 1, 0),
            ).duration.inDays;
            final firstWeekday =
                DateTime(focusedMonth.year, focusedMonth.month, 1).weekday % 7; // 0=Sun
            final today = DateTime.now();
            final monthNames = [
              '', 'January', 'February', 'March', 'April', 'May', 'June',
              'July', 'August', 'September', 'October', 'November', 'December'
            ];

            return Container(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: EdgeInsets.fromLTRB(
                  20, 16, 20, MediaQuery.of(sheetBuilderCtx).viewInsets.bottom + 24),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Drag handle + header row ──────────────────────────
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: colorScheme.outlineVariant,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Schedule a Visit',
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.of(ctx).pop(),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.08)
                                  : Theme.of(context).colorScheme.surfaceContainerHighest,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close,
                              size: 18,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ── Property card ─────────────────────────────────────
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.05)
                            : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.08)
                              : Theme.of(context).colorScheme.surfaceContainerHighest,
                        ),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: CachedNetworkImage(
                              imageUrl: property.imageUrl,
                              width: 64,
                              height: 64,
                              fit: BoxFit.cover,
                              errorWidget: (context, url, error) => Container(
                                width: 64,
                                height: 64,
                                color: Theme.of(context).colorScheme.outline,
                                child: const Icon(Icons.home, color: Colors.grey),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  property.title,
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: colorScheme.onSurface,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  property.price,
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: accentBlue,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on_outlined,
                                      size: 12,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                    const SizedBox(width: 2),
                                    Expanded(
                                      child: Text(
                                        property.location,
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),


                    // ── Calendar header ───────────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () {
                            setSheetState(() {
                              focusedMonth = DateTime(
                                  focusedMonth.year, focusedMonth.month - 1);
                              selectedDay = null;
                            });
                          },
                          icon: Icon(Icons.chevron_left,
                              color: colorScheme.onSurfaceVariant),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        Row(
                          children: [
                            DropdownButton<int>(
                              value: focusedMonth.month,
                              menuMaxHeight: 192,
                              icon: Icon(Icons.arrow_drop_down, color: colorScheme.onSurface, size: 20),
                              underline: const SizedBox(),
                              isDense: true,
                              onChanged: (int? newMonth) {
                                if (newMonth != null) {
                                  setSheetState(() {
                                    focusedMonth = DateTime(focusedMonth.year, newMonth);
                                    selectedDay = null;
                                  });
                                }
                              },
                              items: List.generate(12, (index) {
                                return DropdownMenuItem<int>(
                                  value: index + 1,
                                  child: Text(
                                    monthNames[index + 1],
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                );
                              }),
                            ),
                            const SizedBox(width: 8),
                            DropdownButton<int>(
                              value: focusedMonth.year,
                              menuMaxHeight: 192,
                              icon: Icon(Icons.arrow_drop_down, color: colorScheme.onSurface, size: 20),
                              underline: const SizedBox(),
                              isDense: true,
                              onChanged: (int? newYear) {
                                if (newYear != null) {
                                  setSheetState(() {
                                    focusedMonth = DateTime(newYear, focusedMonth.month);
                                    selectedDay = null;
                                  });
                                }
                              },
                              items: List.generate(100, (index) {
                                final year = DateTime.now().year + index;
                                return DropdownMenuItem<int>(
                                  value: year,
                                  child: Text(
                                    year.toString(),
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: () {
                            setSheetState(() {
                              focusedMonth = DateTime(
                                  focusedMonth.year, focusedMonth.month + 1);
                              selectedDay = null;
                            });
                          },
                          icon: Icon(Icons.chevron_right,
                              color: colorScheme.onSurfaceVariant),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // ── Day-of-week headers ───────────────────────────────
                    Row(
                      children: ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa']
                          .map((d) => Expanded(
                                child: Center(
                                  child: Text(
                                    d,
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 4),

                    // ── Calendar grid ─────────────────────────────────────
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 7,
                        childAspectRatio: 1,
                      ),
                      itemCount: firstWeekday + daysInMonth,
                      itemBuilder: (_, index) {
                        if (index < firstWeekday) return const SizedBox();
                        final day = index - firstWeekday + 1;
                        final thisDate = DateTime(
                            focusedMonth.year, focusedMonth.month, day);
                        final isPast = thisDate
                            .isBefore(DateTime(today.year, today.month, today.day));
                        final isToday = thisDate.year == today.year &&
                            thisDate.month == today.month &&
                            thisDate.day == today.day;
                        final isSelected = selectedDay == day;

                        return GestureDetector(
                          onTap: isPast
                              ? null
                              : () =>
                                  setSheetState(() => selectedDay = day),
                          child: Container(
                            margin: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? accentBlue
                                  : isToday
                                      ? accentBlue.withValues(alpha: 0.12)
                                      : Colors.transparent,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '$day',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: isSelected || isToday
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? Colors.white
                                      : isPast
                                          ? colorScheme.onSurfaceVariant
                                              .withValues(alpha: 0.35)
                                          : isToday
                                              ? accentBlue
                                              : colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    // ── Cancel / Next buttons ─────────────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 50,
                            child: OutlinedButton(
                              onPressed: () => Navigator.of(ctx).pop(),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: colorScheme.onSurface,
                                side: BorderSide(
                                    color: colorScheme.outline),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Cancel',
                                style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SizedBox(
                            height: 50,
                            child: ElevatedButton(
                              onPressed: selectedDay == null
                                  ? null
                                  : () {
                                      Navigator.of(ctx).pop();
                                      _showSelectTimeSlotSheet(context, DateTime(focusedMonth.year, focusedMonth.month, selectedDay!));
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: accentBlue,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor:
                                    accentBlue.withValues(alpha: 0.4),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Next',
                                style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showSelectTimeSlotSheet(BuildContext screenContext, DateTime selectedDate) {
    showModalBottomSheet(
      context: screenContext,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetCtx) {
        // Use screen-level state so data persists across back navigations
        final timeSlots = [
          '10:00 AM', '11:00 AM', '12:00 PM', '2:00 PM', '3:00 PM', '4:00 PM', '5:00 PM'
        ];
        
        final monthNames = [
          '', 'January', 'February', 'March', 'April', 'May', 'June',
          'July', 'August', 'September', 'October', 'November', 'December'
        ];
        
        final weekdayNames = [
          '', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
        ];
        
        final dateString = '${weekdayNames[selectedDate.weekday]}, ${selectedDate.day} ${monthNames[selectedDate.month]} ${selectedDate.year}';

        return StatefulBuilder(
          builder: (statefulCtx, setSheetState) {
            final colorScheme = Theme.of(statefulCtx).colorScheme;
            final isDark = Theme.of(statefulCtx).brightness == Brightness.dark;

            return Container(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: EdgeInsets.fromLTRB(
                  20, 16, 20, MediaQuery.of(statefulCtx).viewInsets.bottom + 24),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Drag handle ───────────────────────────────────────
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: colorScheme.outlineVariant,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Text(
                      'Select Time Slot',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dateString,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: accentBlue,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Divider(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
                    const SizedBox(height: 16),
                    
                    // ── Time Slots ────────────────────────────────────────
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: timeSlots.map((time) {
                        final isSelected = _visitSelectedTime == time;
                        return GestureDetector(
                          onTap: () => setSheetState(() => _visitSelectedTime = time),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected 
                                  ? accentBlue 
                                  : (isDark ? Colors.white.withValues(alpha: 0.05) : Theme.of(context).colorScheme.surfaceContainerHighest),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected 
                                    ? accentBlue 
                                    : (isDark ? Colors.white12 : Theme.of(context).colorScheme.outline),
                              ),
                            ),
                            child: Text(
                              time,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                color: isSelected 
                                    ? Colors.white 
                                    : colorScheme.onSurface,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    
                    const SizedBox(height: 24),
                    Divider(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
                    const SizedBox(height: 16),
                    
                    // ── Name Field ────────────────────────────────────────
                    Text(
                      'Name',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _visitNameController,
                      readOnly: true, // Freeze the name field
                      decoration: InputDecoration(
                        hintText: 'Enter your full name',
                        hintStyle: GoogleFonts.inter(color: colorScheme.onSurfaceVariant),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: colorScheme.outlineVariant),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: accentBlue),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // ── Phone Number Field ────────────────────────────────
                    Text(
                      'Phone Number',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _visitPhoneController,
                      onChanged: (value) => setSheetState(() {}),
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        hintText: '+91 98102 34567',
                        hintStyle: GoogleFonts.inter(color: colorScheme.onSurfaceVariant),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: colorScheme.outlineVariant),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: accentBlue),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // ── Special Requirements Field ────────────────────────
                    Text(
                      'Special Requirements (Optional)',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _visitSpecialReqController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'e.g. key location, gate pass security...',
                        hintStyle: GoogleFonts.inter(color: colorScheme.onSurfaceVariant),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: colorScheme.outlineVariant),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: accentBlue),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // ── Back and Finish Buttons ───────────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 50,
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.of(sheetCtx).pop();
                                _showScheduleVisitSheet(screenContext);
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: colorScheme.onSurface,
                                side: BorderSide(color: colorScheme.outline),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                'Back',
                                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SizedBox(
                            height: 50,
                            child: ElevatedButton(
                              onPressed: (_visitSelectedTime == null || _visitPhoneController.text.trim().length != 10)
                                  ? null
                                  : () async {
                                      await Navigator.of(screenContext).push(
                                        MaterialPageRoute(
                                          builder: (_) => ConfirmVisitDetailsScreen(
                                            property: widget.property,
                                            visitDate: dateString,
                                            visitTime: _visitSelectedTime!,
                                            contactName: _visitNameController.text.trim(),
                                            phoneNumber: _visitPhoneController.text.trim(),
                                            requirements: _visitSpecialReqController.text.trim(),
                                          ),
                                        ),
                                      );
                                      // If they tapped 'Edit Details' or 'Back', they simply return to this sheet.
                                      // If they tapped 'Confirm', popUntil is used, so we won't even reach here.
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: accentBlue,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: accentBlue.withValues(alpha: 0.4),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                'Finish',
                                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }


  void _showLoginRequiredBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.outline,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Login Required',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Please login or create an account to send an enquiry to the property owner.',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentBlue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Login',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.surface,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CreateAccountScreen(),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: Theme.of(context).colorScheme.outline),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Create Account',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showReportBottomSheet(BuildContext context) {
    String selectedReason = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.outline,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Report This Property',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Help us keep our marketplace trustworthy. Why are you reporting this listing?',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...[
                      'Incorrect Information',
                      'Spam / Fake Listing',
                      'Already Sold / Rented',
                      'Inappropriate Content',
                      'Other Reasons',
                    ].map((reason) {
                      return Theme(
                        data: ThemeData(
                          unselectedWidgetColor: Theme.of(context).colorScheme.outline,
                        ),
                        child: RadioListTile<String>(
                          title: Text(
                            reason,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Theme.of(context).colorScheme.onSurface,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          value: reason,
                          groupValue: selectedReason,
                          activeColor: accentBlue,
                          contentPadding: EdgeInsets.zero,
                          visualDensity: const VisualDensity(
                            horizontal: -4,
                            vertical: -4,
                          ),
                          onChanged: (value) {
                            setModalState(() {
                              selectedReason = value!;
                            });
                          },
                        ),
                      );
                    }),
                    const SizedBox(height: 16),
                    Text(
                      'Additional Details (Optional)',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      maxLines: 3,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Provide more information about the issue...',
                        hintStyle: GoogleFonts.inter(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurfaceVariant.withAlpha(150),
                          fontSize: 14,
                        ),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surface,
                        contentPadding: const EdgeInsets.all(12),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Theme.of(
                              context,
                            ).colorScheme.outlineVariant.withAlpha(100),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: accentBlue,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Report submitted successfully'),
                              backgroundColor: accentBlue,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentBlue,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Submit Report',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.surface,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showShareBottomSheet(BuildContext context) {
    final propertyUrl =
        'https://mecotechnologies.com/property/${widget.property.id}';


    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.outline,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Text(
                'Share Property',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),

              // Property preview card
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest
                      .withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context)
                        .colorScheme
                        .outlineVariant
                        .withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: widget.property.imageUrl,
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) => Container(
                          width: 56,
                          height: 56,
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          child: const Icon(Icons.home, color: Colors.grey),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.property.title,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color:
                                  Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.property.location,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Share via all device apps (with image)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _sharePropertyWithImage(context);
                  },
                  icon: const Icon(Icons.share_rounded, size: 20),
                  label: Text(
                    'Share via Apps',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Copy link row
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Or copy property link',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context)
                        .colorScheme
                        .outlineVariant
                        .withValues(alpha: 0.4),
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                        child: Text(
                          propertyUrl,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(
                            ClipboardData(text: propertyUrl));
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Link copied!',
                              style: GoogleFonts.inter(
                                  color: Theme.of(context).colorScheme.surface),
                            ),
                            backgroundColor: accentBlue,
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.all(4),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: accentBlue,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Copy',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.surface,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Cancel button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(
                        color: Theme.of(context)
                            .colorScheme
                            .outlineVariant
                            .withValues(alpha: 0.5)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }




  /// Downloads the property image to a temp file, then shares it
  /// together with the caption text and property link via the native
  /// OS share sheet (shows every app on the device that handles sharing).
  Future<void> _sharePropertyWithImage(BuildContext context) async {
    final propertyUrl =
        'https://mecotechnologies.com/property/${widget.property.id}';
    final shareText =
        '🏠 ${widget.property.title}\n'
        '📍 ${widget.property.location}\n'
        '💰 ${widget.property.price}\n\n'
        'View full details:\n$propertyUrl';

    // Show a brief loading snackbar
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Theme.of(context).colorScheme.surface,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Preparing to share...',
                style: GoogleFonts.inter(color: Theme.of(context).colorScheme.surface),
              ),
            ],
          ),
          backgroundColor: accentBlue,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    }

    try {
      // Download image bytes
      final response = await http
          .get(Uri.parse(widget.property.imageUrl))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        // Write to a temp file
        final tempDir = await getTemporaryDirectory();
        final filePath = '${tempDir.path}/property_share.jpg';
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        if (context.mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        }

        // Share image + text together
        await Share.shareXFiles(
          [XFile(filePath, mimeType: 'image/jpeg')],
          text: shareText,
          subject: 'Property: ${widget.property.title}',
        );
      } else {
        throw Exception('Image download failed: ${response.statusCode}');
      }
    } catch (_) {
      // Fallback: share text + link only
      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      }
      await Share.share(
        shareText,
        subject: 'Property: ${widget.property.title}',
      );
    }
  }
}
