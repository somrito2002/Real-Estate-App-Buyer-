import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'privacy_policy_screen.dart';
import 'deactivate_account_screen.dart';
import 'delete_account_screen.dart';
import 'request_data_screen.dart';

class PrivacyCenterScreen extends StatelessWidget {
  const PrivacyCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FA),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Privacy Center',
          style: GoogleFonts.inter(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Privacy is Priority',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1D1E),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Control your data, manage consents, and configure how Meco protects your real estate search journey.',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  _buildListItem(
                    title: 'Privacy Policy',
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen()));
                    },
                  ),
                  _buildDivider(),
                  _buildListItem(
                    title: 'Request My Data',
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const RequestDataScreen()));
                    },
                  ),
                  _buildDivider(),
                  _buildListItem(
                    title: 'De-activate my Account',
                    titleColor: const Color(0xFF4A85F6),
                    iconColor: const Color(0xFF4A85F6),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const DeactivateAccountScreen()));
                    },
                  ),
                  _buildDivider(),
                  _buildListItem(
                    title: 'Delete my Account',
                    titleColor: const Color(0xFF4A85F6),
                    iconColor: const Color(0xFF4A85F6),
                    isLast: true,
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const DeleteAccountScreen()));
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListItem({
    required String title,
    Color titleColor = const Color(0xFF1A1D1E),
    Color iconColor = const Color(0xFF5F6368),
    bool isLast = false,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: titleColor,
              ),
            ),
            Icon(Icons.chevron_right, color: iconColor),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.grey.shade100,
    );
  }
}
