import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  // State for toggles
  bool _newPropertyMatches = true;
  bool _priceDropAlerts = true;
  bool _propertyAvailability = true;

  bool _enquiryUpdates = false;
  bool _visitReminders = true;
  bool _scheduleChanges = false;

  bool _messages = true;
  bool _securityAlerts = false;

  bool _offersRecommendations = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA);
    final cardBgColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final borderColor = isDark ? Colors.white12 : const Color(0xFFEEEEEE);
    final titleColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final subtitleColor = isDark ? Colors.white70 : const Color(0xFF666666);
    final sectionTitleColor = const Color(0xFF4B85F0); // Blue section title

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
          'notification_settings.title'.tr(),
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
              'notification_settings.stay_updated'.tr(),
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: titleColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'notification_settings.choose_desc'.tr(),
              style: GoogleFonts.inter(
                fontSize: 14,
                color: subtitleColor,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),

            // PROPERTY UPDATES
            _buildSection(
              title: 'notification_settings.property_updates'.tr(),
              sectionTitleColor: sectionTitleColor,
              cardBgColor: cardBgColor,
              borderColor: borderColor,
              children: [
                _buildToggleItem(
                  title: 'notification_settings.new_property_matches'.tr(),
                  subtitle: 'notification_settings.new_property_matches_desc'.tr(),
                  value: _newPropertyMatches,
                  onChanged: (val) => setState(() => _newPropertyMatches = val),
                  titleColor: titleColor,
                  subtitleColor: subtitleColor,
                  showDivider: true,
                  borderColor: borderColor,
                ),
                _buildToggleItem(
                  title: 'notification_settings.price_drop_alerts'.tr(),
                  subtitle: 'notification_settings.price_drop_alerts_desc'.tr(),
                  value: _priceDropAlerts,
                  onChanged: (val) => setState(() => _priceDropAlerts = val),
                  titleColor: titleColor,
                  subtitleColor: subtitleColor,
                  showDivider: true,
                  borderColor: borderColor,
                ),
                _buildToggleItem(
                  title: 'notification_settings.property_availability'.tr(),
                  subtitle: 'notification_settings.property_availability_desc'.tr(),
                  value: _propertyAvailability,
                  onChanged: (val) => setState(() => _propertyAvailability = val),
                  titleColor: titleColor,
                  subtitleColor: subtitleColor,
                  showDivider: false,
                  borderColor: borderColor,
                ),
              ],
            ),

            const SizedBox(height: 20),

            // MY ACTIVITY
            _buildSection(
              title: 'notification_settings.my_activity'.tr(),
              sectionTitleColor: sectionTitleColor,
              cardBgColor: cardBgColor,
              borderColor: borderColor,
              children: [
                _buildToggleItem(
                  title: 'notification_settings.enquiry_updates'.tr(),
                  subtitle: 'notification_settings.enquiry_updates_desc'.tr(),
                  value: _enquiryUpdates,
                  onChanged: (val) => setState(() => _enquiryUpdates = val),
                  titleColor: titleColor,
                  subtitleColor: subtitleColor,
                  showDivider: true,
                  borderColor: borderColor,
                ),
                _buildToggleItem(
                  title: 'notification_settings.visit_reminders'.tr(),
                  subtitle: 'notification_settings.visit_reminders_desc'.tr(),
                  value: _visitReminders,
                  onChanged: (val) => setState(() => _visitReminders = val),
                  titleColor: titleColor,
                  subtitleColor: subtitleColor,
                  showDivider: true,
                  borderColor: borderColor,
                ),
                _buildToggleItem(
                  title: 'notification_settings.schedule_changes'.tr(),
                  subtitle: 'notification_settings.schedule_changes_desc'.tr(),
                  value: _scheduleChanges,
                  onChanged: (val) => setState(() => _scheduleChanges = val),
                  titleColor: titleColor,
                  subtitleColor: subtitleColor,
                  showDivider: false,
                  borderColor: borderColor,
                ),
              ],
            ),

            const SizedBox(height: 20),

            // MESSAGES & ACCOUNT
            _buildSection(
              title: 'notification_settings.messages_account'.tr(),
              sectionTitleColor: sectionTitleColor,
              cardBgColor: cardBgColor,
              borderColor: borderColor,
              children: [
                _buildToggleItem(
                  title: 'notification_settings.messages'.tr(),
                  subtitle: 'notification_settings.messages_desc'.tr(),
                  value: _messages,
                  onChanged: (val) => setState(() => _messages = val),
                  titleColor: titleColor,
                  subtitleColor: subtitleColor,
                  showDivider: true,
                  borderColor: borderColor,
                ),
                _buildToggleItem(
                  title: 'notification_settings.security_alerts'.tr(),
                  subtitle: 'notification_settings.security_alerts_desc'.tr(),
                  value: _securityAlerts,
                  onChanged: (val) => setState(() => _securityAlerts = val),
                  titleColor: titleColor,
                  subtitleColor: subtitleColor,
                  showDivider: false,
                  borderColor: borderColor,
                ),
              ],
            ),

            const SizedBox(height: 20),

            // PROMOTIONAL
            _buildSection(
              title: 'notification_settings.promotional'.tr(),
              sectionTitleColor: sectionTitleColor,
              cardBgColor: cardBgColor,
              borderColor: borderColor,
              children: [
                _buildToggleItem(
                  title: 'notification_settings.offers_recommendations'.tr(),
                  subtitle: 'notification_settings.offers_recommendations_desc'.tr(),
                  value: _offersRecommendations,
                  onChanged: (val) => setState(() => _offersRecommendations = val),
                  titleColor: titleColor,
                  subtitleColor: subtitleColor,
                  showDivider: false,
                  borderColor: borderColor,
                ),
              ],
            ),

            const SizedBox(height: 32),

            Center(
              child: Text(
                'notification_settings.saved_automatically'.tr(),
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: subtitleColor,
                ),
              ),
            ),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required Color sectionTitleColor,
    required Color cardBgColor,
    required Color borderColor,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 16.0, right: 16.0, bottom: 8.0),
            child: Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: sectionTitleColor,
                letterSpacing: 0.5,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildToggleItem({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required Color titleColor,
    required Color subtitleColor,
    required bool showDivider,
    required Color borderColor,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: subtitleColor,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Switch(
                value: value,
                onChanged: onChanged,
                activeColor: Colors.white,
                activeTrackColor: const Color(0xFF4B85F0),
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: Colors.grey.withOpacity(0.5),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(height: 1, color: borderColor, indent: 16, endIndent: 16),
      ],
    );
  }
}
