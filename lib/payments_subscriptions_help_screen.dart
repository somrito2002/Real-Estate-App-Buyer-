import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PaymentsSubscriptionsHelpScreen extends StatelessWidget {
  const PaymentsSubscriptionsHelpScreen({super.key});

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
          'Payments & Subscriptions',
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
              title: 'What payment methods are accepted?',
              content:
                  "MECO accepts UPI, credit/debit cards (Visa, Mastercard, RuPay), net banking, and select wallet options like Paytm and PhonePe for premium services.",
              isInitiallyExpanded: true,
            ),
            _FAQItem(
              title: 'What is MECO Premium?',
              content:
                  "MECO Premium offers exclusive benefits like zero brokerage properties, prioritized support, and early access to new listings.",
            ),
            _FAQItem(
              title: 'How do I manage my subscription?',
              content:
                  "You can manage your subscription by going to your Profile, selecting 'Payments & Subscriptions', and viewing your active plans.",
            ),
            _FAQItem(
              title: 'How do I cancel my subscription?',
              content:
                  "To cancel, go to your active plans under 'Payments & Subscriptions' and tap on 'Cancel Subscription'. Your benefits will remain active until the end of the billing cycle.",
            ),
            _FAQItem(
              title: 'I was charged incorrectly. What should I do?',
              content:
                  "If you notice an incorrect charge, please raise a support ticket with your transaction ID and our team will investigate and process a refund if applicable.",
            ),
            _FAQItem(
              title: 'Are there any hidden charges?',
              content:
                  "No, MECO believes in complete transparency. All charges are shown upfront before you make a payment.",
            ),
            _FAQItem(
              title: 'How do I get a payment receipt or invoice?',
              content:
                  "You can download invoices for all successful transactions from the 'Transaction History' section in your profile.",
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
