import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: Color(0xFF4B85F0),
                    child: Text(
                      'U1',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'User1',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF111111),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'user1@gmail.com',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Edit Profile',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF111111),
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
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  _buildMenuItem(Icons.home_outlined, 'Overview'),
                  _buildDivider(),
                  _buildMenuItem(Icons.favorite_border, 'Saved Properties'),
                  _buildDivider(),
                  _buildMenuItem(Icons.search_outlined, 'Saved Searches'),
                  _buildDivider(),
                  _buildMenuItem(Icons.chat_bubble_outline, 'My Enquiries'),
                  _buildDivider(),
                  _buildMenuItem(Icons.calendar_today_outlined, 'My Visits'),
                  _buildDivider(),
                  _buildMenuItem(Icons.notifications_none_outlined, 'Notifications'),
                  _buildDivider(),
                  _buildMenuItem(Icons.settings_outlined, 'Settings'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Logout Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: TextButton(
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('isLoggedIn', false);
                  if (!context.mounted) return;
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (Route<dynamic> route) => false,
                  );
                },
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFFFFF0F0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Logout',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.red,
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

  Widget _buildMenuItem(IconData icon, String title, {String? badge}) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey.shade700, size: 22),
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF111111),
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
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          if (badge != null) const SizedBox(width: 8),
          Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20),
        ],
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      dense: true,
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(color: Colors.grey.shade200, height: 1, thickness: 1),
    );
  }
}
