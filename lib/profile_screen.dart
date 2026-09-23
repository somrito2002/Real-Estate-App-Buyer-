import 'dart:io';
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

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoggedIn = false;
  bool _isLoading = true;
  bool _isHardcodedUser = false;
  String _cachedFullName = '';
  String _cachedEmail = '';
  String? _cachedProfilePhotoPath;

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
        _isHardcodedUser = prefs.getBool('isHardcodedUser') ?? false;
        _cachedFullName = prefs.getString('cached_fullName') ?? 'Arjun Malhotra';
        _cachedEmail = prefs.getString('cached_email') ?? 'arjun.malhotra@gmail.com';
        _cachedProfilePhotoPath = prefs.getString('cached_profilePhotoPath');
        _isLoading = false;
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
    final accentBlue = const Color(0xFF4B85F0);

    // Profile photo handling
    final bool showRealData = _isLoggedIn && !_isHardcodedUser;
    String displayName = _isLoggedIn ? (showRealData ? _cachedFullName : 'Arjun Malhotra') : 'profile.guest'.tr();
    String displayEmail = _isLoggedIn ? (showRealData ? _cachedEmail : 'arjun.malhotra@gmail.com') : 'profile.no_email'.tr();
    String initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U';
    final bool showPhoto = showRealData && _cachedProfilePhotoPath != null && File(_cachedProfilePhotoPath!).existsSync();

    return Container(
      color: bgColor,
      child: SingleChildScrollView(
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
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: accentBlue,
                      backgroundImage: showPhoto
                          ? FileImage(File(_cachedProfilePhotoPath!))
                          : const NetworkImage('https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&auto=format&fit=crop') as ImageProvider, // Default mock avatar
                      child: null,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      displayName,
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      displayEmail,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: subtitleColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen())),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: borderColor),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'profile.edit_profile'.tr(),
                          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: accentBlue),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              _buildSectionTitle('profile.account_settings'.tr(), sectionTitleColor),
              _buildCardGroup(cardBgColor, borderColor, [
                _buildMenuItem(Icons.phone_android, 'profile.manage_devices'.tr(), iconBgColor, accentBlue, titleColor, onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const ManageDevicesScreen()));
                }),
                _buildDivider(borderColor),
                _buildMenuItem(Icons.language, 'profile.select_language'.tr(), iconBgColor, accentBlue, titleColor, onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const SelectLanguageScreen()));
                }),
                _buildDivider(borderColor),
                _buildMenuItem(Icons.notifications_none, 'profile.notification_settings'.tr(), iconBgColor, accentBlue, titleColor, onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationSettingsScreen()));
                }),
                _buildDivider(borderColor),
                _buildMenuItem(Icons.privacy_tip_outlined, 'profile.privacy_center'.tr(), iconBgColor, accentBlue, titleColor, onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyCenterScreen()));
                }),
              ]),

              _buildSectionTitle('profile.my_activity'.tr(), sectionTitleColor),
              _buildCardGroup(cardBgColor, borderColor, [
                _buildMenuItem(Icons.star_border, 'profile.reviews'.tr(), iconBgColor, accentBlue, titleColor, onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const ReviewsScreen()));
                }),
                _buildDivider(borderColor),
                _buildMenuItem(Icons.chat_bubble_outline, 'profile.my_enquiries'.tr(), iconBgColor, accentBlue, titleColor, badge: '2', onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const MyEnquiriesScreen()));
                }),
              ]),

              _buildSectionTitle('profile.sell_properties'.tr(), sectionTitleColor),
              _buildCardGroup(cardBgColor, borderColor, [
                _buildMenuItem(Icons.home_outlined, 'profile.become_seller'.tr(), iconBgColor, accentBlue, titleColor),
              ]),

              _buildSectionTitle('profile.support_info'.tr(), sectionTitleColor),
              _buildCardGroup(cardBgColor, borderColor, [
                _buildMenuItem(Icons.help_outline, 'profile.help_support'.tr(), iconBgColor, accentBlue, titleColor, onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpAndSupportScreen()));
                }),
                _buildDivider(borderColor),
                _buildMenuItem(Icons.description_outlined, 'profile.terms_conditions'.tr(), iconBgColor, accentBlue, titleColor, onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const TermsAndConditionsScreen()));
                }),
              ]),

              _buildSectionTitle('profile.recently_viewed'.tr(), sectionTitleColor),
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  'profile.viewed_today'.tr(),
                  style: GoogleFonts.inter(fontSize: 13, color: subtitleColor),
                ),
              ),
              _buildRecentlyViewedList(cardBgColor, borderColor, titleColor, subtitleColor),

              _buildSectionTitle('profile.follow_us'.tr(), sectionTitleColor),
              _buildCardGroup(cardBgColor, borderColor, [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildSocialIcon(Icons.facebook, 'Facebook', iconBgColor, accentBlue, titleColor),
                      _buildSocialIcon(Icons.camera_alt_outlined, 'Instagram', iconBgColor, accentBlue, titleColor),
                      _buildSocialIcon(Icons.play_circle_outline, 'YouTube', iconBgColor, accentBlue, titleColor),
                      _buildSocialIcon(Icons.work_outline, 'LinkedIn', iconBgColor, accentBlue, titleColor),
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
                      builder: (context) => AlertDialog(
                        backgroundColor: cardBgColor,
                        title: Text('profile.logout_confirm_title'.tr(), style: GoogleFonts.inter(color: titleColor, fontWeight: FontWeight.bold)),
                        content: Text('profile.logout_confirm_desc'.tr(), style: GoogleFonts.inter(color: subtitleColor)),
                        actions: [
                          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text('profile.no'.tr(), style: GoogleFonts.inter(color: accentBlue, fontWeight: FontWeight.w600))),
                          TextButton(onPressed: () => Navigator.of(context).pop(true), child: Text('profile.yes'.tr(), style: GoogleFonts.inter(color: Colors.red, fontWeight: FontWeight.w600))),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('isLoggedIn', false);
                      if (!context.mounted) return;
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                        (Route<dynamic> route) => false,
                      );
                    }
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.red.withValues(alpha: 0.08),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
              // Footer Text
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

  Widget _buildCardGroup(Color bgColor, Color borderColor, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildDivider(Color color) {
    return Divider(height: 1, thickness: 1, color: color, indent: 64);
  }

  Widget _buildMenuItem(IconData icon, String title, Color iconBgColor, Color iconColor, Color titleColor, {String? badge, VoidCallback? onTap}) {
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
            Icon(Icons.chevron_right, size: 20, color: titleColor.withValues(alpha: 0.3)),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentlyViewedList(Color cardBgColor, Color borderColor, Color titleColor, Color subtitleColor) {
    final properties = [
      {
        'title': 'Green Valley Re...',
        'location': 'Raipur, Chhattisgarh',
        'image': 'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?w=300&auto=format&fit=crop',
        'tag': null,
      },
      {
        'title': 'Skyline Heights',
        'location': 'Bilaspur, Chhattisga...',
        'image': 'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?w=300&auto=format&fit=crop',
        'tag': null,
      },
      {
        'title': 'DLF The Crest',
        'location': 'Sector 54, Gurgaon',
        'image': 'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?w=300&auto=format&fit=crop',
        'tag': 'Ready to Move',
      },
    ];

    return SizedBox(
      height: 180,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: properties.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final prop = properties[index];
          return Container(
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
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
                      child: Image.network(
                        prop['image'] as String,
                        height: 110,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    if (prop['tag'] != null)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF22C55E),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            prop['tag'] as String,
                            style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.surface),
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
                        prop['title'] as String,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: titleColor),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        prop['location'] as String,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(fontSize: 10, color: subtitleColor),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon, String label, Color iconBgColor, Color iconColor, Color titleColor) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: iconBgColor,
            shape: BoxShape.circle,
          ),
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
