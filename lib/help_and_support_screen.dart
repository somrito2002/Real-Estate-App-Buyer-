import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'buying_property_help_screen.dart';
import 'chat_support_screen.dart';
import 'create_support_request_screen.dart';
import 'property_enquiries_help_screen.dart';
import 'renting_property_help_screen.dart';
import 'schedule_visit_help_screen.dart';
import 'shortlist_help_screen.dart';
import 'account_login_help_screen.dart';
import 'payments_subscriptions_help_screen.dart';
import 'notifications_help_screen.dart';
import 'ticket_details_screen.dart';

class HelpAndSupportScreen extends StatelessWidget {
  const HelpAndSupportScreen({super.key});

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
          'Help & Support',
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
              _buildSectionTitle(context, 'Popular Help Topics'),
              const SizedBox(height: 16),
              _buildHelpTopicList(context),
              const SizedBox(height: 32),
              _buildSectionTitle(context, 'Need more help?'),
              const SizedBox(height: 16),
              _buildSupportActions(context),
              const SizedBox(height: 24),
              Center(
                child: Column(
                  children: [
                    Text(
                      'Contact Support',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Support hours: Mon–Sat · 9:00 AM–6:00 PM',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              _buildSectionTitle(context, 'My Support Requests'),
              const SizedBox(height: 16),
              _buildSupportRequestCard(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }

  Widget _buildHelpTopicList(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          _buildHelpTopicItem(
            context,
            icon: Icons.business,
            iconColor: const Color(0xFF4A85F6),
            iconBgColor: const Color(0xFFEDF3FF),
            title: 'Buying a Property',
            subtitle: 'Find answers about property discovery and buying.',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BuyingPropertyHelpScreen()),
              );
            },
          ),
          _buildDivider(context),
          _buildHelpTopicItem(
            context,
            icon: Icons.home_outlined,
            iconColor: const Color(0xFF4A85F6),
            iconBgColor: const Color(0xFFEDF3FF),
            title: 'Renting a Property',
            subtitle: 'Questions about rental properties and enquiries.',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RentingPropertyHelpScreen()),
              );
            },
          ),
          _buildDivider(context),
          _buildHelpTopicItem(
            context,
            icon: Icons.chat_bubble_outline,
            iconColor: const Color(0xFF4A85F6),
            iconBgColor: const Color(0xFFEDF3FF),
            title: 'Property Enquiries',
            subtitle: 'Manage your enquiries and responses.',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PropertyEnquiriesHelpScreen()),
              );
            },
          ),
          _buildDivider(context),
          _buildHelpTopicItem(
            context,
            icon: Icons.calendar_today_outlined,
            iconColor: const Color(0xFF4A85F6),
            iconBgColor: const Color(0xFFEDF3FF),
            title: 'Schedule a Visit',
            subtitle: 'Help with in-person visits and virtual tours.',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ScheduleVisitHelpScreen()),
              );
            },
          ),
          _buildDivider(context),
          _buildHelpTopicItem(
            context,
            icon: Icons.star_border,
            iconColor: const Color(0xFF4A85F6),
            iconBgColor: const Color(0xFFEDF3FF),
            title: 'Shortlist & Saved Searches',
            subtitle: 'Manage saved properties and searches.',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ShortlistHelpScreen()),
              );
            },
          ),
          _buildDivider(context),
          _buildHelpTopicItem(
            context,
            icon: Icons.person_outline,
            iconColor: const Color(0xFF4A85F6),
            iconBgColor: const Color(0xFFEDF3FF),
            title: 'Account & Login',
            subtitle: 'Sign-in, profile and account help.',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AccountLoginHelpScreen()),
              );
            },
          ),
          _buildDivider(context),
          _buildHelpTopicItem(
            context,
            icon: Icons.notifications_none,
            iconColor: const Color(0xFF4A85F6),
            iconBgColor: const Color(0xFFEDF3FF),
            title: 'Notifications',
            subtitle: 'Manage property and activity notifications.',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationsHelpScreen()),
              );
            },
          ),
          _buildDivider(context),
          _buildHelpTopicItem(
            context,
            icon: Icons.receipt_long_outlined,
            iconColor: const Color(0xFF4A85F6),
            iconBgColor: const Color(0xFFEDF3FF),
            title: 'Payments & Subscriptions',
            subtitle: 'Help with payments and seller subscriptions.',
            isLast: true,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PaymentsSubscriptionsHelpScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHelpTopicItem(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    bool isLast = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap ?? () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.onSurfaceVariant),
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
      indent: 64,
    );
  }

  Widget _buildSupportActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildActionCard(
            context,
            icon: Icons.chat_bubble_outline,
            iconColor: const Color(0xFF0F9D58),
            iconBgColor: const Color(0xFFE6F4EA),
            title: 'Chat with Support',
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ChatSupportScreen()));
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildActionCard(
            context,
            icon: Icons.confirmation_number_outlined,
            iconColor: const Color(0xFF4A85F6),
            iconBgColor: const Color(0xFFEDF3FF),
            title: 'Raise a Support\nRequest',
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateSupportRequestScreen()));
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportRequestCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const TicketDetailsScreen()),
        );
      },
      child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ticket #MECO-1024',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Unable to schedule property visit',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'In Progress',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFF57F17),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.onSurfaceVariant),
        ],
      ),
    ));
  }
}
