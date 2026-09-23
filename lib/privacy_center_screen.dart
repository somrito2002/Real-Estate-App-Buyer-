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
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Privacy Center',
          style: GoogleFonts.inter(
            color: Theme.of(context).colorScheme.onSurface,
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
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Privacy is Priority',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Control your data, manage consents, and configure how Meco protects your real estate search journey.',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
              ),
              child: Column(
                children: [
                  _buildListItem(
                    context,
                    title: 'Privacy Policy',
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen()));
                    },
                  ),
                  _buildDivider(context),
                  _buildListItem(
                    context,
                    title: 'Request My Data',
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const RequestDataScreen()));
                    },
                  ),
                  _buildDivider(context),
                  _buildListItem(
                    context,
                    title: 'De-activate my Account',
                    titleColor: Theme.of(context).colorScheme.primary,
                    iconColor: Theme.of(context).colorScheme.primary,
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const DeactivateAccountScreen()));
                    },
                  ),
                  _buildDivider(context),
                  _buildListItem(
                    context,
                    title: 'Delete my Account',
                    titleColor: Theme.of(context).colorScheme.primary,
                    iconColor: Theme.of(context).colorScheme.primary,
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

  Widget _buildListItem(
    BuildContext context, {
    required String title,
    Color? titleColor,
    Color? iconColor,
    bool isLast = false,
    required VoidCallback onTap,
  }) {
    final tColor = titleColor ?? Theme.of(context).colorScheme.onSurface;
    final iColor = iconColor ?? Theme.of(context).colorScheme.onSurfaceVariant;
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
                color: tColor,
              ),
            ),
            Icon(Icons.chevron_right, color: iColor),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: Theme.of(context).colorScheme.outlineVariant,
    );
  }
}
