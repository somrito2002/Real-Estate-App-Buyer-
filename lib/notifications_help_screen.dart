import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationsHelpScreen extends StatelessWidget {
  const NotificationsHelpScreen({super.key});

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
          'Notifications',
          style: GoogleFonts.inter(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _FAQItem(
              title: 'What types of notifications will I receive?',
              content:
                  "You'll receive notifications for: new property matches, enquiry responses, visit confirmations and reminders, price drops on shortlisted properties, new listings in saved searches, and platform updates.",
              isInitiallyExpanded: true,
            ),
            _FAQItem(
              title: 'How do I manage my notification preferences?',
              content:
                  "Go to Profile > Settings > Notifications. Here you can toggle push notifications, emails, and SMS alerts for different categories.",
            ),
            _FAQItem(
              title: 'Why am I not receiving notifications?',
              content:
                  "Please ensure notifications are enabled for the app in your device's system settings. Also, check if you haven't muted specific alerts in the app's notification preferences.",
            ),
            _FAQItem(
              title: 'Can I mute notifications temporarily?',
              content:
                  "Yes, you can enable 'Do Not Disturb' mode in the app settings to pause all non-critical notifications for a specified duration.",
            ),
            _FAQItem(
              title: 'How do I stop receiving marketing emails?',
              content:
                  "You can unsubscribe from marketing emails by clicking the 'Unsubscribe' link at the bottom of any promotional email, or by turning off promotional emails in your notification preferences.",
            ),
            _FAQItem(
              title: 'How do I clear my notification history?',
              content:
                  "Open the notifications center by tapping the bell icon on the home screen, then tap 'Clear All' to remove your notification history.",
            ),
          ],
        ),
      ),
    );
  }
}

class _FAQItem extends StatefulWidget {
  final String title;
  final String content;
  final bool isInitiallyExpanded;

  const _FAQItem({
    required this.title,
    required this.content,
    this.isInitiallyExpanded = false,
  });

  @override
  State<_FAQItem> createState() => _FAQItemState();
}

class _FAQItemState extends State<_FAQItem> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.isInitiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Theme.of(context).colorScheme.surfaceContainerHighest),
        ),
      ),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: widget.isInitiallyExpanded,
          iconColor: const Color(0xFF4A85F6),
          collapsedIconColor: const Color(0xFF4A85F6),
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          title: Text(
            widget.title,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1D1E),
            ),
          ),
          trailing: Icon(
            _isExpanded ? Icons.remove : Icons.add,
            size: 24,
            color: const Color(0xFF4368B1),
          ),
          onExpansionChanged: (expanded) {
            setState(() {
              _isExpanded = expanded;
            });
          },
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
              child: Text(
                widget.content,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  height: 1.5,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
