import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'my_visits_screen.dart';

class VisitRescheduledSuccessScreen extends StatelessWidget {
  final VisitMock visit;
  final String newDate;
  final String newTime;

  const VisitRescheduledSuccessScreen({
    super.key,
    required this.visit,
    required this.newDate,
    required this.newTime,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final bgColor = isDark ? const Color(0xFF121212) : Colors.white;
    final titleColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final subtitleColor = isDark ? Colors.white70 : const Color(0xFF666666);
    final accentBlue = const Color(0xFF4B85F0);
    
    final bannerBgColor = isDark ? const Color(0xFF332715) : const Color(0xFFFFF7E6);
    final bannerTitleColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final bannerSubtitleColor = isDark ? const Color(0xFFEAB308) : const Color(0xFFB45309);
    final tagTextColor = isDark ? const Color(0xFFEAB308) : const Color(0xFF92400E);
    
    final cardBgColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final cardBorderColor = isDark ? Colors.white12 : const Color(0xFFEEEEEE);
    
    final iconBgColor = isDark ? const Color(0xFF1A2A4A) : const Color(0xFFF0F5FF);
    final iconColor = accentBlue;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: titleColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Visit Details',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: titleColor,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: bannerBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Visit Rescheduled',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: bannerTitleColor,
                          ),
                        ),
                        Text(
                          'RESCHEDULED',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                            color: tagTextColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your new visit time is confirmed.',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: bannerSubtitleColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              Text(
                'Updated Visit Information',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: titleColor,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Details Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardBgColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: cardBorderColor),
                  boxShadow: isDark
                      ? []
                      : [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                ),
                child: Column(
                  children: [
                    _buildInfoRow(Icons.calendar_today_outlined, 'Date', newDate, iconBgColor, iconColor, titleColor, subtitleColor),
                    const SizedBox(height: 16),
                    _buildInfoRow(Icons.access_time_outlined, 'Time', newTime, iconBgColor, iconColor, titleColor, subtitleColor),
                    const SizedBox(height: 16),
                    _buildInfoRow(Icons.person_outline, 'Visit Type', visit.visitType, iconBgColor, iconColor, titleColor, subtitleColor),
                    const SizedBox(height: 16),
                    _buildInfoRow(Icons.location_on_outlined, 'Location', visit.location, iconBgColor, iconColor, titleColor, subtitleColor),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Property Card
              Container(
                padding: const EdgeInsets.all(16),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: cardBgColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: cardBorderColor),
                  boxShadow: isDark
                      ? []
                      : [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      visit.title,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${visit.location} - ${visit.refId}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: subtitleColor,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Buttons
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: titleColor,
                    side: BorderSide(
                      color: isDark ? Colors.white24 : const Color(0xFFDDDDDD),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Add to Calendar',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
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
                    'Back to Property',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (_) => const MyVisitsScreen(),
                      ),
                      (route) => false,
                    );
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'View My Visits ',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: accentBlue,
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward,
                        size: 16,
                        color: accentBlue,
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color iconBgColor, Color iconColor, Color titleColor, Color subtitleColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconBgColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: iconColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: subtitleColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: titleColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
