import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';

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
        _cachedFullName = prefs.getString('cached_fullName') ?? 'User1';
        _cachedEmail = prefs.getString('cached_email') ?? 'user1@gmail.com';
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

    // For hardcoded demo login, always show static data
    // For registered users, show their real data
    final bool showRealData = _isLoggedIn && !_isHardcodedUser;

    String displayName = _isLoggedIn
        ? (showRealData ? _cachedFullName.toUpperCase() : 'USER1')
        : 'Guest';
    String displayEmail = _isLoggedIn
        ? (showRealData ? _cachedEmail : 'user1@gmail.com')
        : 'No email';

    // Parse initials from real name, or use 'U1' for hardcoded, 'G' for guest
    String initial;
    if (!_isLoggedIn) {
      initial = 'G';
    } else if (_isHardcodedUser) {
      initial = 'U1';
    } else {
      final names = _cachedFullName.trim().split(' ');
      final firstLetter = names.first.isNotEmpty ? names.first[0].toUpperCase() : '';
      final lastLetter = names.length > 1 && names.last.isNotEmpty ? names.last[0].toUpperCase() : '';
      initial = '$firstLetter$lastLetter';
      if (initial.isEmpty) initial = 'U';
    }

    // Profile photo: only show for registered users who set one
    final bool showPhoto = showRealData &&
        _cachedProfilePhotoPath != null &&
        File(_cachedProfilePhotoPath!).existsSync();

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 16),
          // Profile Card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Theme.of(context).colorScheme.outline),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: const Color(0xFF4B85F0),
                    backgroundImage: showPhoto
                        ? FileImage(File(_cachedProfilePhotoPath!))
                        : null,
                    child: showPhoto
                        ? null
                        : Text(
                            initial,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.surface,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    displayName,
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    displayEmail,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_isLoggedIn)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Theme.of(context).colorScheme.outline),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Edit Profile',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Menu List
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Theme.of(context).colorScheme.outline),
              ),
              child: Column(
                children: [
                  _buildMenuItem(context, Icons.home_outlined, 'Overview'),
                  _buildDivider(context),
                  _buildMenuItem(context, Icons.favorite_border, 'Saved Properties'),
                  _buildDivider(context),
                  _buildMenuItem(context, Icons.search_outlined, 'Saved Searches'),
                  _buildDivider(context),
                  _buildMenuItem(context, Icons.chat_bubble_outline, 'My Enquiries'),
                  _buildDivider(context),
                  _buildMenuItem(context, Icons.calendar_today_outlined, 'My Visits'),
                  _buildDivider(context),
                  _buildMenuItem(context, Icons.notifications_none_outlined, 'Notifications'),
                  _buildDivider(context),
                  _buildMenuItem(context, Icons.settings_outlined, 'Settings'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Logout / Login Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: TextButton(
                onPressed: () async {
                  if (_isLoggedIn) {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: Theme.of(context).colorScheme.surface,
                        title: Text(
                          'Log Out',
                          style: GoogleFonts.inter(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        content: Text(
                          'Do you want to log out?',
                          style: GoogleFonts.inter(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: Text(
                              'No',
                              style: GoogleFonts.inter(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: Text(
                              'Yes',
                              style: GoogleFonts.inter(
                                color: Colors.red,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
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
                  } else {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                      (Route<dynamic> route) => false,
                    );
                  }
                },
                style: TextButton.styleFrom(
                  backgroundColor: _isLoggedIn ? Colors.red.withOpacity(0.1) : const Color(0xFF4B85F0).withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _isLoggedIn ? 'Logout' : 'Login',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: _isLoggedIn ? Colors.red : const Color(0xFF4B85F0),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, String title, {String? badge}) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.onSurfaceVariant, size: 22),
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (badge != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF4B85F0),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                badge,
                style: GoogleFonts.inter(
                  color: Theme.of(context).colorScheme.surface,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          if (badge != null) const SizedBox(width: 8),
          Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.onSurfaceVariant, size: 20),
        ],
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      dense: true,
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(color: Theme.of(context).colorScheme.outline, height: 1, thickness: 1),
    );
  }
}
