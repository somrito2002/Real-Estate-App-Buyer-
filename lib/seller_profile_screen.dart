import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'models/property_model.dart';
import 'services/partner_api_service.dart';
import 'property_details_screen.dart';

const Color accentBlue = Color(0xFF4B85F0);

class SellerProfileScreen extends StatefulWidget {
  final String? partnerId;
  final Partner? initialPartner;

  const SellerProfileScreen({
    super.key,
    this.partnerId,
    this.initialPartner,
  });

  @override
  State<SellerProfileScreen> createState() => _SellerProfileScreenState();
}

class _SellerProfileScreenState extends State<SellerProfileScreen> {
  Partner? _partner;
  List<Property> _properties = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _partner = widget.initialPartner;
    _fetchProfile();
  }

  String? get _resolvedPartnerId {
    if (widget.partnerId != null && widget.partnerId!.trim().isNotEmpty) {
      return widget.partnerId!.trim();
    }
    if (widget.initialPartner != null && widget.initialPartner!.id.trim().isNotEmpty) {
      return widget.initialPartner!.id.trim();
    }
    return null;
  }

  Future<void> _fetchProfile() async {
    final id = _resolvedPartnerId;

    if (id == null || id.isEmpty) {
      // If no partner ID provided, provide default display
      setState(() {
        _isLoading = false;
        _partner ??= Partner(
          id: 'demo-partner',
          fullName: 'Rajesh Kumar',
          companyName: 'K-Realty Group, Delhi NCR',
          number: '+919876543210',
          email: 'rajesh.kumar@krealty.com',
          profilePicture: 'https://images.unsplash.com/photo-1560250097-0b93528c311a?w=400&auto=format&fit=crop',
          partnerType: 'Senior Property Consultant',
          profileViews: 42,
        );
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final profile = await PartnerApiService.getPublicProfile(id);
      if (mounted) {
        setState(() {
          _partner = profile.partner;
          _properties = profile.properties;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  Future<void> _makeCall(String phone) async {
    final clean = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    if (clean.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contact number not available for this seller.')),
      );
      return;
    }
    final uri = Uri.parse('tel:$clean');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open phone dialer.')),
        );
      }
    }
  }

  Future<void> _openWhatsApp(String phone) async {
    String clean = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (clean.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('WhatsApp number not available for this seller.')),
      );
      return;
    }
    if (!clean.startsWith('91') && clean.length == 10) {
      clean = '91$clean';
    }
    final uri = Uri.parse(
      'https://wa.me/$clean?text=${Uri.encodeComponent('Hello, I am interested in your property listings on Dalal Realty.')}',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch WhatsApp.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Seller Profile',
          style: GoogleFonts.inter(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          if (_partner != null)
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: accentBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: accentBlue.withValues(alpha: 0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.visibility_outlined, size: 14, color: accentBlue),
                  const SizedBox(width: 4),
                  Text(
                    '${_partner!.profileViews}',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: accentBlue,
                    ),
                  ),
                ],
              ),
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
            height: 1,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchProfile,
        color: accentBlue,
        child: _isLoading && _partner == null
            ? _buildLoadingState()
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_errorMessage != null && _partner == null)
                      _buildErrorBanner()
                    else ...[
                      const SizedBox(height: 16),
                      _buildProfileCard(context),
                      const SizedBox(height: 16),
                      _buildStatsRow(context),
                      const SizedBox(height: 24),
                      _buildActiveListingsSection(context),
                      const SizedBox(height: 24),
                      _buildReviewsSection(context),
                      const SizedBox(height: 32),
                    ],
                  ],
                ),
              ),
      ),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: accentBlue),
          const SizedBox(height: 16),
          Text(
            'Loading seller profile...',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
          const SizedBox(height: 12),
          Text(
            'Failed to load profile',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _errorMessage ?? 'An unexpected error occurred.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _fetchProfile,
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: accentBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context) {
    final partner = _partner;
    final fullName = partner?.fullName.isNotEmpty == true ? partner!.fullName : 'Verified Partner';
    final company = partner?.companyName.isNotEmpty == true ? partner!.companyName : 'Real Estate Partner';
    final partnerType = partner?.partnerType != null && partner!.partnerType!.isNotEmpty
        ? partner.partnerType!
        : 'Property Consultant';
    final pfp = partner?.profilePicture ?? '';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(36),
              child: pfp.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: pfp,
                      width: 68,
                      height: 68,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: 68,
                        height: 68,
                        color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3),
                        child: const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: accentBlue),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => _buildAvatarFallback(fullName),
                    )
                  : _buildAvatarFallback(fullName),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          fullName,
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F0FE),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.verified, size: 10, color: accentBlue),
                            const SizedBox(width: 2),
                            Text(
                              'VERIFIED',
                              style: GoogleFonts.inter(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: accentBlue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    partnerType,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    company,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: accentBlue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Eye Icon View Counter pill inside profile card
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: accentBlue.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: accentBlue.withValues(alpha: 0.15)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.remove_red_eye_rounded,
                          size: 14,
                          color: accentBlue,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${partner?.profileViews ?? 0} Profile Views',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: accentBlue,
                          ),
                        ),
                      ],
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

  Widget _buildAvatarFallback(String name) {
    final initials = name.trim().isNotEmpty
        ? name.trim().split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join()
        : 'P';
    return Container(
      width: 68,
      height: 68,
      decoration: BoxDecoration(
        color: accentBlue.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initials.toUpperCase(),
          style: GoogleFonts.inter(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: accentBlue,
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    final views = _partner?.profileViews ?? 0;
    final listingsCount = _properties.isNotEmpty ? _properties.length : (_isLoading ? '-' : 0);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Eye Icon View Counter Stat Card
          _buildStatItem(
            context,
            '$views',
            'Profile Views',
            icon: Icons.remove_red_eye_outlined,
            isHighlighted: true,
          ),
          _buildStatItem(
            context,
            '$listingsCount',
            'Active Listings',
            icon: Icons.home_work_outlined,
          ),
          _buildStatItem(
            context,
            '4.9 ★',
            'Seller Rating',
            icon: Icons.star_border_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String value,
    String label, {
    IconData? icon,
    bool isHighlighted = false,
  }) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: BoxDecoration(
          color: isHighlighted
              ? accentBlue.withValues(alpha: 0.05)
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isHighlighted
                ? accentBlue.withValues(alpha: 0.3)
                : Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    size: 15,
                    color: isHighlighted ? accentBlue : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                ],
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isHighlighted ? accentBlue : Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 10,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveListingsSection(BuildContext context) {
    final listingsCount = _properties.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          context,
          'Active Listings ($listingsCount)',
          showViewAll: listingsCount > 3,
        ),
        const SizedBox(height: 12),
        if (_isLoading && _properties.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: CircularProgressIndicator(strokeWidth: 2, color: accentBlue),
              ),
            ),
          )
        else if (_properties.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5)),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.real_estate_agent_outlined,
                    size: 40,
                    color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No active listings currently',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'This seller has not posted any active property listings yet.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ..._properties.map((prop) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildPropertyCard(context, prop),
              )),
      ],
    );
  }

  Widget _buildPropertyCard(BuildContext context, Property property) {
    final statusText = property.status.isNotEmpty ? property.status.toUpperCase() : 'ACTIVE';
    final listedByName = _partner?.fullName ?? 'Verified Seller';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PropertyDetailsScreen(property: property),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
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
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: property.imageUrl,
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        height: 160,
                        color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3),
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2, color: accentBlue),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        height: 160,
                        color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3),
                        child: const Icon(Icons.apartment, size: 48, color: Colors.grey),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE4F8E9),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        statusText,
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF00A859),
                        ),
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
                    Text(
                      property.title,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Listed by $listedByName',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            property.location,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Divider(
                      color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
                      height: 1,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                property.specs,
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                property.price,
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: accentBlue,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              'View Details',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: accentBlue,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.arrow_forward, size: 14, color: accentBlue),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReviewsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, 'Client Reviews (24)'),
        const SizedBox(height: 12),
        _buildReviewCard(
          context,
          'Ankit Sharma',
          5,
          '"Highly professional service. Helped me seal the property deal smoothly with absolute transparency."',
        ),
        const SizedBox(height: 12),
        _buildReviewCard(
          context,
          'Meera Nair',
          4,
          '"Prompt responses. Clear verified background checks provided. Highly recommended!"',
        ),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, {bool showViewAll = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          if (showViewAll)
            Text(
              'View All',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: accentBlue,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(BuildContext context, String name, int stars, String review) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  name,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < stars ? Icons.star : Icons.star_border,
                      size: 16,
                      color: const Color(0xFFFFB020),
                    );
                  }),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              review,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    final phone = _partner?.number ?? '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5)),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _makeCall(phone),
                icon: const Icon(Icons.phone_outlined, size: 18, color: accentBlue),
                label: Text(
                  'Call Us',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: accentBlue,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: accentBlue),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _openWhatsApp(phone),
                icon: Icon(Icons.chat_bubble_outline, size: 18, color: Theme.of(context).colorScheme.surface),
                label: Text(
                  'WhatsApp',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.surface,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentBlue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
