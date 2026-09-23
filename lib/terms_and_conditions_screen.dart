import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TermsAndConditionsScreen extends StatefulWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  State<TermsAndConditionsScreen> createState() => _TermsAndConditionsScreenState();
}

class _TermsAndConditionsScreenState extends State<TermsAndConditionsScreen> {
  int _expandedIndex = 0; // 0 for the first item '1. Acceptance of Terms'

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
          'Terms & Conditions',
          style: GoogleFonts.inter(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Terms & Conditions',
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Last updated: September 16, 2026',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'These terms explain the rules and conditions for using the MECO Real Estate platform. Please read them carefully before using our services.',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                ),
                child: Column(
                  children: [
                    _buildExpandableItem(
                      index: 0,
                      title: '1. Acceptance of Terms',
                      content: 'By accessing or using the MECO Real Estate mobile application and website, you agree to be bound by these Terms and Conditions:\n\n• Users must be at least 18 years of age to register an account or enquire about listings.\n\n• You agree to provide accurate and complete registration and profile information.\n\n• We reserve the right to suspend accounts violating our platform codes of conduct.',
                    ),
                    _buildExpandableItem(index: 1, title: '2. Using the MECO Real Estate Platform', content: '...'),
                    _buildExpandableItem(index: 2, title: '3. Property Listings & Information', content: '...'),
                    _buildExpandableItem(index: 3, title: '4. User Accounts', content: '...'),
                    _buildExpandableItem(index: 4, title: '5. Property Enquiries', content: '...'),
                    _buildExpandableItem(index: 5, title: '6. Property Visits & Virtual Tours', content: '...'),
                    _buildExpandableItem(index: 6, title: '7. Reviews & User Content', content: '...'),
                    _buildExpandableItem(index: 7, title: '8. Communications & Notifications', content: '...'),
                    _buildExpandableItem(index: 8, title: '9. Payments & Subscriptions', content: '...'),
                    _buildExpandableItem(index: 9, title: '10. Privacy & Data Protection', content: '...'),
                    _buildExpandableItem(index: 10, title: '11. Third-Party Services', content: '...'),
                    _buildExpandableItem(index: 11, title: '12. Limitation of Liability', content: '...'),
                    _buildExpandableItem(index: 12, title: '13. Prohibited Activities', content: '...'),
                    _buildExpandableItem(index: 13, title: '14. Changes to These Terms', content: '...'),
                    _buildExpandableItem(index: 14, title: '15. Contact & Support', content: '...', isLast: true),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      'Questions about these terms?',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Contact our support team if you need clarification.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Get Started',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpandableItem({
    required int index,
    required String title,
    required String content,
    bool isLast = false,
  }) {
    bool isExpanded = _expandedIndex == index;
    Color textColor = isExpanded ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface;
    Color iconColor = isExpanded ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurfaceVariant;

    return Container(
      decoration: BoxDecoration(
        border: isLast ? null : Border(bottom: BorderSide(color: Theme.of(context).colorScheme.outlineVariant)),
      ),
      child: Theme(
        data: ThemeData(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          initiallyExpanded: isExpanded,
          onExpansionChanged: (expanded) {
            setState(() {
              if (expanded) {
                _expandedIndex = index;
              } else if (_expandedIndex == index) {
                _expandedIndex = -1;
              }
            });
          },
          iconColor: iconColor,
          collapsedIconColor: iconColor,
          title: Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  content,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
