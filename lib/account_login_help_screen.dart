import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AccountLoginHelpScreen extends StatelessWidget {
  const AccountLoginHelpScreen({super.key});

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
          'Account & Login',
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
              title: 'How do I create an account?',
              content:
                  "Tap 'Sign Up' on the login screen. You can register using your mobile number, email address, or sign in with Google. OTP verification is required for mobile number registration.",
              isInitiallyExpanded: true,
            ),
            _FAQItem(
              title: 'I forgot my password. How do I reset it?',
              content:
                  "On the login screen, tap on 'Forgot Password'. Enter your registered email or mobile number, and we will send you instructions to reset your password.",
            ),
            _FAQItem(
              title: 'How do I update my profile information?',
              content:
                  "Go to your profile section and tap on 'Edit Profile'. You can update your personal details, preferences, and communication settings there.",
            ),
            _FAQItem(
              title: 'How do I change my registered mobile number?',
              content:
                  "Please contact support to change your registered mobile number for security reasons.",
            ),
            _FAQItem(
              title: 'Can I have multiple accounts?',
              content:
                  "We recommend having only one account per user to maintain the integrity of our platform and avoid confusion.",
            ),
            _FAQItem(
              title: 'How do I delete my account?',
              content:
                  "To delete your account, please contact our support team. Please note that this action is irreversible.",
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
            color: const Color(0xFF4368B1), // dark blue tone for icons as per UI
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
