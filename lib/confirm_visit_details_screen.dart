import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'models/property_model.dart';
import 'visit_scheduled_success_screen.dart';


class ConfirmVisitDetailsScreen extends StatelessWidget {
  static const Color accentBlue = Color(0xFF4B85F0);

  final Property property;
  final String visitDate;
  final String visitTime;
  final String contactName;
  final String phoneNumber;

  const ConfirmVisitDetailsScreen({
    Key? key,
    required this.property,
    required this.visitDate,
    required this.visitTime,
    required this.contactName,
    required this.phoneNumber,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF121212) : Colors.white;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final cardBorderColor = isDark ? Colors.white12 : const Color(0xFFEEEEEE);
    final labelColor = isDark ? Colors.white54 : const Color(0xFF888888);
    final valueColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final titleColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final dividerColor = isDark ? Colors.white12 : const Color(0xFFEEEEEE);
    final disclaimerColor = isDark ? Colors.white38 : const Color(0xFF999999);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              size: 20, color: isDark ? Colors.white : const Color(0xFF1A1A1A)),
          onPressed: () => Navigator.of(context).pop(true),
        ),
        title: Text(
          'Confirm Visit Details',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: titleColor,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              'Review Booking Details',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: titleColor,
              ),
            ),
            const SizedBox(height: 20),
            // ── Details card ─────────────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: cardBorderColor),
                boxShadow: isDark
                    ? []
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: Column(
                children: [
                  // Property row
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            property.imageUrl,
                            width: 64,
                            height: 64,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: isDark ? Colors.white12 : Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(Icons.home_rounded,
                                  color: isDark ? Colors.white38 : Colors.grey.shade400),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                property.title,
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: valueColor,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                property.price,
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: accentBlue,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                property.location,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: labelColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1, color: dividerColor),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    child: Column(
                      children: [
                        _buildRow('Visit Date', visitDate, labelColor, valueColor),
                        const SizedBox(height: 14),
                        _buildRow('Visit Time', visitTime, labelColor, valueColor),
                        const SizedBox(height: 14),
                        _buildRow('Visit Type', 'In-Person Visit', labelColor, valueColor),
                        const SizedBox(height: 14),
                        _buildRow('Contact Name', contactName, labelColor, valueColor),
                        const SizedBox(height: 14),
                        _buildRow('Phone Number', '+91 $phoneNumber', labelColor, valueColor),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            // ── Disclaimer ──────────────────────────────────────────────
            Text(
              'By continuing, you agree to our Terms of Service & privacy checks for physical verification.',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: disclaimerColor,
                height: 1.6,
              ),
            ),
            
            const SizedBox(height: 28),
            // ── Confirm Visit button ─────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => VisitScheduledSuccessScreen(
                        property: property,
                        visitDate: visitDate,
                        visitTime: visitTime,
                      ),
                    ),
                  );
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
                  'Confirm Visit',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // ── Edit Details button ──────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: OutlinedButton.styleFrom(
                  foregroundColor: isDark ? Colors.white : const Color(0xFF1A1A1A),
                  side: BorderSide(
                    color: isDark ? Colors.white24 : const Color(0xFFDDDDDD),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Edit Details',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value, Color labelColor, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            color: labelColor,
          ),
        ),
        const SizedBox(width: 16),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: valueColor,
            ),
          ),
        ),
      ],
    );
  }
}
