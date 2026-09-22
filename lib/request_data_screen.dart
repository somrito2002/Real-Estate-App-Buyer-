import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RequestDataScreen extends StatelessWidget {
  const RequestDataScreen({super.key});

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
          'Request My Data',
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
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F5FF), // Light blue background
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFD3E1FA)), // Slightly darker border
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Data, Your Control',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1D1E),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Request a copy of the personal data MECO Real Estate holds about you. We\'ll prepare your data and notify you when it\'s ready for download.',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                      height: 1.5,
                    ),
                  ),
                ],
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
                  Text(
                    'What\'s included in your data export:',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1D1E),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildListItem('Profile information'),
                  const SizedBox(height: 12),
                  _buildListItem('Property search history'),
                  const SizedBox(height: 12),
                  _buildListItem('Saved searches & shortlisted properties'),
                  const SizedBox(height: 12),
                  _buildListItem('Enquiry history'),
                  const SizedBox(height: 12),
                  _buildListItem('Visit scheduling records'),
                  const SizedBox(height: 12),
                  _buildListItem('Reviews & ratings'),
                  const SizedBox(height: 12),
                  _buildListItem('Notification preferences'),
                  const SizedBox(height: 12),
                  _buildListItem('Login & device history'),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'PREVIOUS REQUESTS',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Data Export — Sep 10, 2026',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1A1D1E),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFF0F9D58),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Completed',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'Download',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF4A85F6),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  // Handle data request logic
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Data export requested successfully!')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A85F6), // Blue
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Request My Data',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Data preparation may take up to 48 hours. You\'ll receive a notification when ready.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildListItem(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.check, color: Color(0xFF0F9D58), size: 18),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey.shade600,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}
