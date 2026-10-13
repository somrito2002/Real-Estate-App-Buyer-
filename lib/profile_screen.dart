import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import 'my_enquiries_screen.dart';
import 'notification_settings_screen.dart';
import 'reviews_screen.dart';
import 'manage_devices_screen.dart';
import 'select_language_screen.dart';
import 'edit_profile_screen.dart';
import 'help_and_support_screen.dart';
import 'privacy_center_screen.dart';
import 'terms_and_conditions_screen.dart';
import 'services/auth_api_service.dart';
import 'services/recently_viewed_service.dart';
import 'models/user_profile.dart';
import 'models/property_model.dart';
import 'property_details_loader.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoggedIn = false;
  bool _isLoading = true;
  bool _isFetchingProfile = false;
  String? _errorMessage;

  /// Null means profile hasn't been loaded yet or user is not logged in.
  UserProfile? _userProfile;
  List<Property> _recentProperties = [];

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final recent = await RecentlyViewedService.getRecentlyViewed();
    if (!mounted) return;
    setState(() {
      _isLoggedIn = isLoggedIn;
      _recentProperties = recent;
      _isLoading = false;
    });
    if (isLoggedIn) {
      await _fetchProfile();
    }
  }

  Future<void> _fetchProfile() async {
    if (_isFetchingProfile) return; // prevent duplicate requests
    setState(() {
      _isFetchingProfile = true;
      _errorMessage = null;
    });

    try {
      final profile = await AuthApiService.getUserProfile();
      if (!mounted) return;
      setState(() {
        _userProfile = profile;
        _isFetchingProfile = false;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      final message = e.toString().replaceAll('Exception: ', '');
      // Check if it is a 401 (session expired) — redirect to login
      if (e is Exception && message.toLowerCase().contains('unauthorized') ||
          message.toLowerCase().contains('session not found') ||
          message.toLowerCase().contains('log in again')) {
        await AuthApiService.clearSession();
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
        return;
      }
      setState(() {
        _isFetchingProfile = false;
        _isLoading = false;
        _errorMessage = message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFFAFAFA);
    final cardBgColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final borderColor = isDark ? Colors.white12 : const Color(0xFFEEEEEE);
    final titleColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final subtitleColor = isDark ? Colors.white70 : const Color(0xFF666666);
    final sectionTitleColor = isDark ? Colors.white54 : const Color(0xFF8898AA);
    final iconBgColor = isDark ? const Color(0xFF1A2A4A) : const Color(0xFFF0F5FF);
    const accentBlue = Color(0xFF4B85F0);

    // Resolve display values — prefer API data, fall back to empty
    final displayName = _userProfile?.fullName.isNotEmpty == true
        ? _userProfile!.fullName
        : (_isLoggedIn ? 'profile.guest'.tr() : 'profile.guest'.tr());
    final displayEmail = _userProfile?.email.isNotEmpty == true
        ? _userProfile!.email
        : (_isLoggedIn ? '' : 'profile.no_email'.tr());

    // Profile picture URL
    final profilePicUrl = _userProfile?.profilePictureUrl(AuthApiService.backendBaseUrl);

    // Enquiry badge count from API
    final enquiryCount = _userProfile?.enquiries.length ?? 0;
    final enquiryBadge = enquiryCount > 0 ? '$enquiryCount' : null;

    return Container(
      color: bgColor,
      child: RefreshIndicator(
        onRefresh: _fetchProfile,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Profile Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24),
                decoration: BoxDecoration(
                  color: cardBgColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  children: [
                    // Profile picture
                    _isFetchingProfile
                        ? const SizedBox(
                            width: 80,
                            height: 80,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : CircleAvatar(
                            radius: 40,
                            backgroundColor: accentBlue,
                            backgroundImage: profilePicUrl != null
                                ? NetworkImage(profilePicUrl)
                                : null,
                            onBackgroundImageError: profilePicUrl != null
                                ? (_, __) {}
                                : null,
                            child: profilePicUrl == null
                                ? Text(
                                    displayName.isNotEmpty
                                        ? displayName[0].toUpperCase()
                                        : 'U',
                                    style: GoogleFonts.inter(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  )
                                : null,
                          ),
                    const SizedBox(height: 16),
                    Text(
                      displayName.isNotEmpty ? displayName : 'profile.guest'.tr(),
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (displayEmail.isNotEmpty)
                      Text(
                        displayEmail,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: subtitleColor,
                        ),
                      ),
                    if (_userProfile?.number.isNotEmpty == true) ...[
                      const SizedBox(height: 2),
                      Text(
                        _userProfile!.number,
                        style: GoogleFonts.inter(fontSize: 13, color: subtitleColor),
                      ),
                    ],
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.redAccent,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () async {
                        final bool? updated = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                        );
                        if (updated == true && mounted) {
                          setState(() {
                            _isLoading = true;
                          });
                          await _fetchProfile();
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: borderColor),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'profile.edit_profile'.tr(),
                          style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: accentBlue),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              _buildSectionTitle('profile.account_settings'.tr(), sectionTitleColor),
              _buildCardGroup(cardBgColor, borderColor, [
                _buildMenuItem(Icons.phone_android, 'profile.manage_devices'.tr(),
                    iconBgColor, accentBlue, titleColor, onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const ManageDevicesScreen()));
                }),
                _buildDivider(borderColor),
                _buildMenuItem(Icons.language, 'profile.select_language'.tr(),
                    iconBgColor, accentBlue, titleColor, onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const SelectLanguageScreen()));
                }),
                _buildDivider(borderColor),
                _buildMenuItem(
                    Icons.notifications_none,
                    'profile.notification_settings'.tr(),
                    iconBgColor,
                    accentBlue,
                    titleColor, onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const NotificationSettingsScreen()));
                }),
                _buildDivider(borderColor),
                _buildMenuItem(Icons.privacy_tip_outlined,
                    'profile.privacy_center'.tr(), iconBgColor, accentBlue, titleColor,
                    onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const PrivacyCenterScreen()));
                }),
              ]),

              _buildSectionTitle('profile.my_activity'.tr(), sectionTitleColor),
              _buildCardGroup(cardBgColor, borderColor, [
                _buildMenuItem(Icons.star_border, 'profile.reviews'.tr(), iconBgColor,
                    accentBlue, titleColor, onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const ReviewsScreen()));
                }),
                _buildDivider(borderColor),
                _buildMenuItem(
                    Icons.chat_bubble_outline,
                    'profile.my_enquiries'.tr(),
                    iconBgColor,
                    accentBlue,
                    titleColor,
                    badge: enquiryBadge,
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const MyEnquiriesScreen()));
                    }),
              ]),

              _buildSectionTitle('profile.sell_properties'.tr(), sectionTitleColor),
              _buildCardGroup(cardBgColor, borderColor, [
                _buildMenuItem(Icons.home_outlined, 'profile.become_seller'.tr(),
                    iconBgColor, accentBlue, titleColor),
              ]),

              _buildSectionTitle('profile.support_info'.tr(), sectionTitleColor),
              _buildCardGroup(cardBgColor, borderColor, [
                _buildMenuItem(Icons.help_outline, 'profile.help_support'.tr(),
                    iconBgColor, accentBlue, titleColor, onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const HelpAndSupportScreen()));
                }),
                _buildDivider(borderColor),
                _buildMenuItem(
                    Icons.description_outlined,
                    'profile.terms_conditions'.tr(),
                    iconBgColor,
                    accentBlue,
                    titleColor, onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const TermsAndConditionsScreen()));
                }),
              ]),

              if (_recentProperties.isNotEmpty) ...[
                _buildSectionTitle('profile.recently_viewed'.tr(), sectionTitleColor),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    _recentProperties.length == 1
                        ? 'You viewed 1 property'
                        : 'You viewed ${_recentProperties.length} properties',
                    style: GoogleFonts.inter(fontSize: 13, color: subtitleColor),
                  ),
                ),
                _buildRecentlyViewedList(cardBgColor, borderColor, titleColor, subtitleColor),
              ],

              _buildSectionTitle('profile.follow_us'.tr(), sectionTitleColor),
              _buildCardGroup(cardBgColor, borderColor, [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildSocialIcon(Icons.facebook, 'Facebook', iconBgColor,
                          accentBlue, titleColor),
                      _buildSocialIcon(Icons.camera_alt_outlined, 'Instagram',
                          iconBgColor, accentBlue, titleColor),
                      _buildSocialIcon(Icons.play_circle_outline, 'YouTube',
                          iconBgColor, accentBlue, titleColor),
                      _buildSocialIcon(Icons.work_outline, 'LinkedIn', iconBgColor,
                          accentBlue, titleColor),
                    ],
                  ),
                ),
              ]),

              const SizedBox(height: 24),
              // Logout Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: TextButton(
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: cardBgColor,
                        title: Text('profile.logout_confirm_title'.tr(),
                            style: GoogleFonts.inter(
                                color: titleColor, fontWeight: FontWeight.bold)),
                        content: Text('profile.logout_confirm_desc'.tr(),
                            style: GoogleFonts.inter(color: subtitleColor)),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.of(ctx).pop(false),
                              child: Text('profile.no'.tr(),
                                  style: GoogleFonts.inter(
                                      color: accentBlue,
                                      fontWeight: FontWeight.w600))),
                          TextButton(
                              onPressed: () => Navigator.of(ctx).pop(true),
                              child: Text('profile.yes'.tr(),
                                  style: GoogleFonts.inter(
                                      color: Colors.red,
                                      fontWeight: FontWeight.w600))),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      await AuthApiService.clearSession();
                      if (!context.mounted) return;
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (Route<dynamic> route) => false,
                      );
                    }
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.red.withValues(alpha: 0.08),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    'profile.logout'.tr(),
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),
              Center(
                child: Text(
                  'Meco Real Estate v2.4.0\n© 2026 Meco Technologies Pvt. Ltd.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: subtitleColor.withValues(alpha: 0.6),
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 12),
      child: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
          color: color,
        ),
      ),
    );
  }

  Widget _buildCardGroup(
      Color bgColor, Color borderColor, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDivider(Color color) {
    return Divider(height: 1, thickness: 1, color: color, indent: 64);
  }

  Widget _buildMenuItem(IconData icon, String title, Color iconBgColor,
      Color iconColor, Color titleColor,
      {String? badge, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap ?? () {},
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 20, color: iconColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: titleColor,
                ),
              ),
            ),
            if (badge != null)
              Container(
                margin: const EdgeInsets.only(right: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: iconColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  badge,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.surface,
                  ),
                ),
              ),
            Icon(Icons.chevron_right,
                size: 20, color: titleColor.withValues(alpha: 0.3)),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentlyViewedList(Color cardBgColor, Color borderColor,
      Color titleColor, Color subtitleColor) {
    return SizedBox(
      height: 180,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _recentProperties.length,
        separatorBuilder: (c, i) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final prop = _recentProperties[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PropertyDetailsLoader(propertyId: prop.id),
                ),
              ).then((_) => _init());
            },
            child: Container(
              width: 140,
              decoration: BoxDecoration(
                color: cardBgColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius:
                            const BorderRadius.vertical(top: Radius.circular(11)),
                        child: (prop.imageUrl.isNotEmpty)
                            ? Image.network(
                                prop.imageUrl,
                                height: 110,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (c, e, s) => Container(
                                  height: 110,
                                  color: Colors.grey.shade300,
                                  child: const Icon(Icons.home, color: Colors.grey),
                                ),
                              )
                            : Container(
                                height: 110,
                                color: Colors.grey.shade300,
                                child: const Icon(Icons.home, color: Colors.grey),
                              ),
                      ),
                      if (prop.status.isNotEmpty)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF22C55E),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              prop.status,
                              style: GoogleFonts.inter(
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      Theme.of(context).colorScheme.surface),
                            ),
                          ),
                        ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          prop.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: titleColor),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          prop.location.isNotEmpty ? prop.location : prop.city,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                              fontSize: 10, color: subtitleColor),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon, String label, Color iconBgColor,
      Color iconColor, Color titleColor) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: iconBgColor, shape: BoxShape.circle),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: titleColor,
          ),
        ),
      ],
    );
  }
}
