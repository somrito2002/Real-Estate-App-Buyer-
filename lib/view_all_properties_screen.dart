import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/wishlist_api_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'models/property_model.dart';
import 'property_details_screen.dart';
import 'widgets/remove_shortlist_dialog.dart';

class ViewAllPropertiesScreen extends StatefulWidget {
  final String title;
  final List<Property> properties;

  const ViewAllPropertiesScreen({
    super.key,
    required this.title,
    required this.properties,
  });

  @override
  State<ViewAllPropertiesScreen> createState() => _ViewAllPropertiesScreenState();
}

class _ViewAllPropertiesScreenState extends State<ViewAllPropertiesScreen> {
  static const Color accentBlue = Color(0xFF4B85F0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(widget.title, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurface),
      ),
      body: widget.properties.isEmpty
          ? Center(
              child: Text(
                'No properties available.',
                style: GoogleFonts.inter(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: widget.properties.length,
              itemBuilder: (context, index) {
                final property = widget.properties[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: _buildPropertyCard(property),
                );
              },
            ),
    );
  }

  Widget _buildPropertyCard(Property property) {
    Color statusBgColor = const Color(0xFFF0FDF4); // Light green
    Color statusColor = const Color(0xFF16A34A); // Green
    String statusText = property.status;

    if (property.status.toUpperCase() == 'UNDER CONSTRUCTION') {
      statusBgColor = const Color(0xFFFFFBEB); // Light yellow
      statusColor = const Color(0xFFD97706); // Orange/Amber
    } else if (property.status.toUpperCase() == 'NEW LAUNCH') {
      statusBgColor = const Color(0xFFFDF2FA); // Light pink
      statusColor = const Color(0xFFDB2777); // Pink
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => PropertyDetailsScreen(property: property)));
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withAlpha(128)),
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
            // Image and badges
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: CachedNetworkImage(
                    imageUrl: property.imageUrl,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) {
                      return Container(
                        height: 180,
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        child: Center(
                          child: Icon(Icons.image_not_supported, size: 48, color: Theme.of(context).colorScheme.onSurfaceVariant),
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusBgColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      statusText,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: InkWell(
                    onTap: () async {
                      bool currentFavorite = WishlistApiService.isWishlisted(property.id);
                      if (currentFavorite) {
                        final bool? confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => RemoveShortlistDialog(
                            propertyTitle: property.title,
                          ),
                        );
                        if (confirm != true) return;
                      }

                      if (!mounted) return;
                      await WishlistApiService.handleToggleWishlist(
                        context,
                        property.id,
                        onUpdate: (newState) {
                          if (mounted) {
                            setState(() {
                              property.isFavorite = newState;
                            });
                          }
                        },
                        onError: (error) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
                          }
                        },
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Theme.of(context).colorScheme.onSurface.withAlpha(25), blurRadius: 4),
                        ],
                      ),
                      child: Icon(
                        WishlistApiService.isWishlisted(property.id) ? Icons.favorite : Icons.favorite_border,
                        size: 20,
                        color: WishlistApiService.isWishlisted(property.id) ? Colors.red : Colors.grey,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Details
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    property.price,
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: accentBlue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    property.title,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          property.location,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Divider(color: Theme.of(context).colorScheme.outlineVariant.withAlpha(128), height: 1),
                  const SizedBox(height: 12),
                  Text(
                    property.specs,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
