import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';

class ManageDevicesScreen extends StatelessWidget {
  const ManageDevicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFFAFAFA);
    final cardBgColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final borderColor = isDark ? Colors.white12 : const Color(0xFFEEEEEE);
    final titleColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final subtitleColor = isDark ? Colors.white70 : const Color(0xFF666666);
    final sectionTitleColor = isDark ? Colors.white54 : const Color(0xFF7B8794);
    final iconBgColor = isDark ? const Color(0xFF1A2A4A) : const Color(0xFFF0F5FF);
    final accentBlue = const Color(0xFF4B85F0);
    
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
          'devices.title'.tr(),
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: titleColor,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'devices.desc'.tr(),
              style: GoogleFonts.inter(
                fontSize: 14,
                color: subtitleColor,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            
            // THIS DEVICE Section
            Text(
              'devices.this_device'.tr(),
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: sectionTitleColor,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),
            _buildDeviceCard(
              context: context,
              deviceName: 'Apple iPhone 13',
              lastUsed: 'Sep 16, 2026 • 11:54 AM',
              location: 'Bilaspur, Chhattisgarh, India',
              registered: 'Nov 24, 2024 • 12:44 AM',
              icon: Icons.smartphone,
              isCurrentDevice: true,
              cardBgColor: cardBgColor,
              borderColor: borderColor,
              titleColor: titleColor,
              subtitleColor: subtitleColor,
              iconBgColor: iconBgColor,
              accentBlue: accentBlue,
            ),
            
            const SizedBox(height: 24),
            
            // OTHER DEVICES Section
            Text(
              'devices.other_devices'.tr(),
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: sectionTitleColor,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),
            _buildDeviceCard(
              context: context,
              deviceName: 'Apple iPhone 17',
              lastUsed: 'Sep 15, 2026 • 06:40 PM',
              location: 'Gurgaon, Haryana, India',
              registered: 'Sep 10, 2026 • 01:40 AM',
              icon: Icons.smartphone,
              isCurrentDevice: false,
              cardBgColor: cardBgColor,
              borderColor: borderColor,
              titleColor: titleColor,
              subtitleColor: subtitleColor,
              iconBgColor: iconBgColor,
              accentBlue: accentBlue,
            ),
            const SizedBox(height: 12),
            _buildDeviceCard(
              context: context,
              deviceName: 'Chrome Browser',
              lastUsed: 'Sep 12, 2026 • 10:23 PM',
              location: 'Delhi, National Capital Territory of Delhi, India',
              registered: 'Apr 16, 2026 • 10:07 PM',
              icon: Icons.language,
              isCurrentDevice: false,
              cardBgColor: cardBgColor,
              borderColor: borderColor,
              titleColor: titleColor,
              subtitleColor: subtitleColor,
              iconBgColor: iconBgColor,
              accentBlue: accentBlue,
            ),
            const SizedBox(height: 12),
            _buildDeviceCard(
              context: context,
              deviceName: 'Chrome Browser',
              lastUsed: 'Sep 02, 2026 • 06:18 PM',
              location: 'Raipur, Chhattisgarh, India',
              registered: 'Sep 02, 2026 • 02:39 PM',
              icon: Icons.language,
              isCurrentDevice: false,
              cardBgColor: cardBgColor,
              borderColor: borderColor,
              titleColor: titleColor,
              subtitleColor: subtitleColor,
              iconBgColor: iconBgColor,
              accentBlue: accentBlue,
            ),
            
            const SizedBox(height: 32),
            
            // Logout from all button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.red.withValues(alpha: 0.05),
                  side: BorderSide(color: Colors.red.withValues(alpha: 0.5)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'devices.logout_all'.tr(),
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.red,
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

  Widget _buildDeviceCard({
    required BuildContext context,
    required String deviceName,
    required String lastUsed,
    required String location,
    required String registered,
    required IconData icon,
    required bool isCurrentDevice,
    required Color cardBgColor,
    required Color borderColor,
    required Color titleColor,
    required Color subtitleColor,
    required Color iconBgColor,
    required Color accentBlue,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: accentBlue, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              deviceName,
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: titleColor,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {},
                            child: Text(
                              'devices.log_out'.tr(),
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: accentBlue,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'devices.last_used'.tr(namedArgs: {'time': lastUsed}),
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: subtitleColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        location,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: subtitleColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, thickness: 1, color: borderColor, indent: 16, endIndent: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'devices.registered_on'.tr(namedArgs: {'time': registered}),
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: subtitleColor,
                    ),
                  ),
                ),
                if (isCurrentDevice)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6F4EA),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'CURRENT DEVICE',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E8E3E),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
