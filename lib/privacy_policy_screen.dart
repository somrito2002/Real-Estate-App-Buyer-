import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

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
          'Privacy Policy',
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Privacy Policy',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1A1D1E),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Last updated: September 16, 2026',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF4A85F6),
              ),
            ),
            const SizedBox(height: 24),
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
                  _buildSection(
                    title: '1. Information We Collect',
                    content: 'When you use the MECO Real Estate platform, we collect information you provide directly — such as your name, email, phone number, and property preferences. We also collect usage data including search history, viewed properties, saved searches, and enquiry activity to improve your experience.',
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    title: '2. How We Use Your Information',
                    content: '• Personalise property recommendations and search results\n• Process property enquiries and visit scheduling\n• Send notifications about price changes and new listings\n• Improve platform features and user experience\n• Ensure account security and prevent fraud',
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    title: '3. Information Sharing',
                    content: 'We share your contact details with property sellers, developers, or agents only when you initiate an enquiry or schedule a visit. We do not sell your personal information to third parties.',
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    title: '4. Data Storage & Security',
                    content: 'Your data is stored securely on encrypted servers. We implement industry-standard security measures to protect your personal information.',
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    title: '5. Your Rights',
                    content: 'You have the right to access, correct, or delete your personal data at any time through the Privacy Center in your account settings.',
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    title: '6. Contact Us',
                    content: 'For privacy-related queries, reach out through Help & Support in the app.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required String content}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF4A85F6),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: Colors.grey.shade600,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
