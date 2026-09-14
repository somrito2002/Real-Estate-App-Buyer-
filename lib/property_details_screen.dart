import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'models/property_model.dart';
import 'seller_profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'login_screen.dart';
import 'create_account_screen.dart';
import 'register_screen.dart';
import 'widgets/remove_shortlist_dialog.dart';
import 'full_screen_image_gallery.dart';
import 'enquiry_success_screen.dart';
import 'confirm_visit_details_screen.dart';

class PropertyDetailsScreen extends StatefulWidget {
  final Property property;

  const PropertyDetailsScreen({super.key, required this.property});

  @override
  State<PropertyDetailsScreen> createState() => _PropertyDetailsScreenState();
}

class _PropertyDetailsScreenState extends State<PropertyDetailsScreen> {
  static const Color accentBlue = Color(0xFF4B85F0);
  static const Color backgroundLight = Color(0xFFF8FAFC);

  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      });
    }
  }

  void _onHeartTapped(Property property) async {
    if (!_isLoggedIn) {
      _showSaveToShortlistSheet();
    } else {
      if (property.isFavorite) {
        // Show confirm dialog before removing
        final bool? confirm = await showDialog<bool>(
          context: context,
          builder: (context) => RemoveShortlistDialog(
            propertyTitle: property.title,
          ),
        );
        
        if (confirm == true) {
          setState(() {
            property.isFavorite = false;
          });
        }
      } else {
        setState(() {
          property.isFavorite = true;
        });
      }
    }
  }

  void _showSaveToShortlistSheet() {
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
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.favorite, color: Colors.red.shade400, size: 36),
            ),
            const SizedBox(height: 20),
            Text(
              'Save to Shortlist',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Please sign in or create an account to save properties to your shortlist and monitor price drops.',
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
                    MaterialPageRoute(builder: (_) => const RegisterScreen()),
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
      color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5),
    );
  }

  Widget _buildFeatureChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withOpacity(0.5),
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
        ).colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: accentBlue),
          const SizedBox(width: 12),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface,
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
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final property = widget.property;

    // Parse specs for chips
    final specsParts = property.specs.split('•').map((e) => e.trim()).toList();
    final area = specsParts.isNotEmpty ? specsParts[0] : '1,450 sq.ft';
    final bedrooms = specsParts.length > 1 ? specsParts[1] : '3 Bedrooms';
    final baths = specsParts.length > 2 ? specsParts[2] : '2 Baths';

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
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => FullScreenImageGallery(
                              imageUrls: [
                                property.imageUrl,
                                'https://images.unsplash.com/photo-1600566753190-17f0baa2a6c3?w=800&auto=format&fit=crop',
                                'https://images.unsplash.com/photo-1486325212027-8081e485255e?w=800&auto=format&fit=crop',
                                'https://images.unsplash.com/photo-1574362848149-11496d93a7c7?w=800&auto=format&fit=crop',
                              ],
                            ),
                          ),
                        );
                      },
                      child: property.imageUrl.startsWith('assets/')
                          ? Image.asset(
                              property.imageUrl,
                              height: 250,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            )
                          : Image.network(
                              property.imageUrl,
                              height: 250,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                    ),
                    Positioned(
                      top: MediaQuery.of(context).padding.top + 8,
                      left: 16,
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.black,
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
                            backgroundColor: Colors.white,
                            child: IconButton(
                              icon: Icon(
                                property.isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: property.isFavorite
                                    ? Colors.red
                                    : Colors.black,
                              ),
                              onPressed: () => _onHeartTapped(property),
                            ),
                          ),
                          const SizedBox(width: 12),
                          CircleAvatar(
                            backgroundColor: Colors.white,
                            child: IconButton(
                              icon: const Icon(
                                Icons.share,
                                color: Colors.black,
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
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '1/12',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // Content Body
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Price & Status
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            property.price,
                            style: GoogleFonts.inter(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: accentBlue,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              property.status,
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

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
                          color: accentBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Residential • For Sale',
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
                          _buildFeatureChip(Icons.square_foot, area),
                          _buildFeatureChip(Icons.bed, bedrooms),
                          _buildFeatureChip(Icons.bathtub_outlined, baths),
                          _buildFeatureChip(
                            Icons.directions_car_outlined,
                            '1 Parking',
                          ),
                        ],
                      ),

                      _buildDivider(),

                      // About This Property
                      _buildSectionHeader('About This Property'),
                      const SizedBox(height: 8),
                      Text(
                        'Experience the perfect blend of luxury and comfort in this premium apartment. Features high ventilation, modern vitrified flooring, and direct access to transit hubs...',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () {},
                        child: Row(
                          children: [
                            Text(
                              'Read More',
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

                      // Features & Amenities
                      _buildSectionHeader('Features & Amenities'),
                      const SizedBox(height: 16),
                      GridView.count(
                        crossAxisCount: MediaQuery.of(context).orientation == Orientation.landscape ? 4 : 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        childAspectRatio: 3.5,
                        children: [
                          _buildAmenityItem(Icons.bed_outlined, 'Bedrooms'),
                          _buildAmenityItem(
                            Icons.bathtub_outlined,
                            'Bathrooms',
                          ),
                          _buildAmenityItem(
                            Icons.local_parking_outlined,
                            'Parking',
                          ),
                          _buildAmenityItem(Icons.elevator_outlined, 'Lift'),
                          _buildAmenityItem(
                            Icons.security_outlined,
                            'Security',
                          ),
                          _buildAmenityItem(
                            Icons.bolt_outlined,
                            'Power Backup',
                          ),
                          _buildAmenityItem(Icons.balcony_outlined, 'Balcony'),
                          _buildAmenityItem(
                            Icons.pool_outlined,
                            'Swimming Pool',
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () {},
                        child: Row(
                          children: [
                            Text(
                              'View All Features',
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

                      // Location Map
                      _buildSectionHeader('Location'),
                      const SizedBox(height: 12),
                      Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: const DecorationImage(
                            image: NetworkImage(
                              'https://images.unsplash.com/photo-1524661135-423995f22d0b?w=800&auto=format&fit=crop',
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: accentBlue,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.home,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        property.location,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () {},
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
                          const CircleAvatar(
                            radius: 24,
                            backgroundImage: NetworkImage(
                              'https://images.unsplash.com/photo-1560250097-0b93528c311a?w=100&auto=format&fit=crop',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Rajesh Sharma',
                                  style: GoogleFonts.inter(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface,
                                  ),
                                ),
                                Text(
                                  'Property Owner',
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
                      _buildDetailRow('Property ID', 'RT-20481'),
                      _buildDetailRow('Property Type', 'Apartment'),
                      _buildDetailRow('Listing Type', 'For Sale'),
                      _buildDetailRow('Area', area),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () {},
                        child: Row(
                          children: [
                            Text(
                              'View More Details',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: accentBlue,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.arrow_downward,
                              size: 14,
                              color: accentBlue,
                            ),
                          ],
                        ),
                      ),

                      _buildDivider(),

                      // Report Listing
                      Center(
                        child: TextButton.icon(
                          onPressed: () async {
                            final prefs = await SharedPreferences.getInstance();
                            final isLoggedIn =
                                prefs.getBool('isLoggedIn') ?? false;
                            if (!isLoggedIn) {
                              if (!context.mounted) return;
                              _showLoginRequiredBottomSheet(context);
                            } else {
                              if (!context.mounted) return;
                              _showReportBottomSheet(context);
                            }
                          },
                          icon: const Icon(
                            Icons.flag_outlined,
                            color: Colors.red,
                            size: 18,
                          ),
                          label: Text(
                            'Report This Listing',
                            style: GoogleFonts.inter(
                              color: Colors.red,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),

                      _buildDivider(),

                      // Similar Properties
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildSectionHeader('Similar Properties'),
                          GestureDetector(
                            onTap: () {},
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
                      SizedBox(
                        height: 180,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: mockProperties.length > 2
                              ? 2
                              : mockProperties.length,
                          itemBuilder: (context, index) {
                            final similar = mockProperties[index];
                            return Container(
                              width: 200,
                              margin: const EdgeInsets.only(right: 16),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.outlineVariant.withOpacity(0.3),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(12),
                                    ),
                                    child: Image.network(
                                      similar.imageUrl,
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
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
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
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          snap: true,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 20),
              child: ListView(
                controller: scrollController,
                children: [
                  // Drag handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.outlineVariant,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Send Enquiry',
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: Icon(Icons.close, color: Theme.of(context).colorScheme.onSurface),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 16),

                  // Property Info Card
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: widget.property.imageUrl.startsWith('assets/')
                            ? Image.asset(
                                widget.property.imageUrl,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              )
                            : Image.network(
                                widget.property.imageUrl,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 60,
                                  height: 60,
                                  color: Colors.grey.shade200,
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
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.property.price,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: accentBlue,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.property.location,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Form fields
                  _buildEnquiryTextField('Full Name', 'e.g. Robert Charles'),
                  const SizedBox(height: 16),
                  _buildEnquiryTextField('Mobile Number', '+91 98102 34567'),
                  const SizedBox(height: 16),
                  _buildEnquiryTextField('Email Address', 'robert.charles@gmail.com'),
                  const SizedBox(height: 16),
                  
                  // Dropdown
                  Text(
                    'Preferred Contact Time',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        dropdownColor: Theme.of(context).colorScheme.surface,
                        value: 'Morning (9 AM - 12 PM)',
                        icon: Icon(Icons.keyboard_arrow_down, color: Theme.of(context).colorScheme.onSurface),
                        items: ['Morning (9 AM - 12 PM)', 'Afternoon (12 PM - 4 PM)', 'Evening (4 PM - 8 PM)']
                            .map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (_) {},
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Your Message
                  Text(
                    'Your Message',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    maxLines: 3,
                    style: GoogleFonts.inter(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Interested',
                      hintStyle: GoogleFonts.inter(
                        color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: accentBlue),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Bottom Buttons
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(ctx),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'Cancel',
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
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
                              Navigator.pop(ctx);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const EnquirySuccessScreen(
                                    ownerName: 'Rajesh Sharma',
                                  ),
                                ),
                              );
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
                              'Send Enquiry',
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEnquiryTextField(String label, String hintText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          style: GoogleFonts.inter(fontSize: 14),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: GoogleFonts.inter(
              color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: accentBlue),
            ),
          ),
        ),
      ],
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
                color: accentBlue.withOpacity(0.1),
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
                  color: accentBlue.withOpacity(0.1),
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
        int selectedVisitType = 0; // 0 = In-Person, 1 = Virtual Tour
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
                                  ? Colors.white.withOpacity(0.08)
                                  : Colors.grey.shade100,
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
                            ? Colors.white.withOpacity(0.05)
                            : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withOpacity(0.08)
                              : Colors.grey.shade200,
                        ),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              property.imageUrl,
                              width: 64,
                              height: 64,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 64,
                                height: 64,
                                color: Colors.grey.shade300,
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
                        Text(
                          '${monthNames[focusedMonth.month]} ${focusedMonth.year}',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
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
                                      ? accentBlue.withOpacity(0.12)
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
                                              .withOpacity(0.35)
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
                                    accentBlue.withOpacity(0.4),
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
        String? selectedTime;
        final phoneController = TextEditingController();
        final nameController = TextEditingController();
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
                    Divider(color: colorScheme.outlineVariant.withOpacity(0.5)),
                    const SizedBox(height: 16),
                    
                    // ── Time Slots ────────────────────────────────────────
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: timeSlots.map((time) {
                        final isSelected = selectedTime == time;
                        return GestureDetector(
                          onTap: () => setSheetState(() => selectedTime = time),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected 
                                  ? accentBlue 
                                  : (isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected 
                                    ? accentBlue 
                                    : (isDark ? Colors.white12 : Colors.grey.shade300),
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
                    Divider(color: colorScheme.outlineVariant.withOpacity(0.5)),
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
                      controller: nameController,
                      onChanged: (value) => setSheetState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Arjun Malhotra',
                        hintStyle: GoogleFonts.inter(color: colorScheme.onSurfaceVariant),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: colorScheme.outlineVariant),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.5)),
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
                      controller: phoneController,
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
                          borderSide: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.5)),
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
                          borderSide: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.5)),
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
                              onPressed: (selectedTime == null || phoneController.text.trim().length != 10)
                                  ? null
                                  : () async {
                                      final shouldEdit = await Navigator.of(screenContext).push(
                                        MaterialPageRoute(
                                          builder: (_) => ConfirmVisitDetailsScreen(
                                            property: widget.property,
                                            visitDate: dateString,
                                            visitTime: selectedTime!,
                                            contactName: nameController.text.trim().isEmpty ? 'Arjun Malhotra' : nameController.text.trim(),
                                            phoneNumber: phoneController.text.trim(),
                                          ),
                                        ),
                                      );
                                      Navigator.of(sheetCtx).pop(); // close time slot sheet now that we're back
                                      if (shouldEdit == true && mounted) {
                                        _showScheduleVisitSheet(screenContext);
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: accentBlue,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: accentBlue.withOpacity(0.4),
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

  /// Pill tab for visit type selector
  Widget _visitTypeTab({
    required BuildContext context,
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(4),
          height: 36,
          decoration: BoxDecoration(
            color: selected
                ? (isDark ? Colors.white : Colors.white)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    )
                  ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 15,
                color: selected
                    ? accentBlue
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 5),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight:
                      selected ? FontWeight.w600 : FontWeight.normal,
                  color: selected
                      ? accentBlue
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
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
                    color: Colors.grey.shade300,
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
                      color: Colors.white,
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
                    side: BorderSide(color: Colors.grey.shade300),
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
                          color: Colors.grey.shade300,
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
                          unselectedWidgetColor: Colors.grey.shade300,
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
                            color: Colors.white,
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
    final shareText =
        'Check out ${widget.property.title} in ${widget.property.location} for ${widget.property.price}!\n\n$propertyUrl';

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
                    color: Colors.grey.shade300,
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
                      .withOpacity(0.4),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context)
                        .colorScheme
                        .outlineVariant
                        .withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        widget.property.imageUrl,
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 56,
                          height: 56,
                          color: Colors.grey.shade200,
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
                        .withOpacity(0.4),
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
                                  color: Colors.white),
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
                            color: Colors.white,
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
                            .withOpacity(0.5)),
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



  Widget _buildShareOption({
    required IconData icon,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
    bool hideDivider = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withAlpha(20),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey.shade400,
                  size: 20,
                ),
              ],
            ),
          ),
          if (!hideDivider) Divider(color: Colors.grey.shade200, height: 1),
        ],
      ),
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
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Preparing to share...',
                style: GoogleFonts.inter(color: Colors.white),
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
