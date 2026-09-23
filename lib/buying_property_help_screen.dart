import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BuyingPropertyHelpScreen extends StatelessWidget {
  const BuyingPropertyHelpScreen({super.key});

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
          'Buying a Property',
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
            _buildFaqItem(context, 
              question: 'How do I search for properties?',
              answer:
                  'Use the search bar on the home screen. You can filter by location, price range, property type, BHK configuration, and amenities. Save your searches for quick access later.',
              initiallyExpanded: true,
            ),
            _buildFaqItem(context, 
              question: 'What does \'Under Construction\' vs \'Ready to Move\' mean?',
              answer: '...', // Add placeholder text or leave empty as per design
            ),
            _buildFaqItem(context, 
              question: 'How do I schedule a site visit?',
              answer: '...',
            ),
            _buildFaqItem(context, 
              question: 'What documents do I need to buy a property?',
              answer: '...',
            ),
            _buildFaqItem(context, 
              question: 'How do I make an enquiry about a property?',
              answer: '...',
            ),
            _buildFaqItem(context, 
              question: 'What is RERA registration?',
              answer: '...',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqItem(BuildContext context, {
    required String question,
    required String answer,
    bool initiallyExpanded = false,
  }) {
    return Theme(
      data: ThemeData(
        dividerColor: Colors.transparent, // Remove default ExpansionTile divider
      ),
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Theme.of(context).colorScheme.surfaceContainerHighest),
          ),
        ),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          iconColor: Theme.of(context).colorScheme.primary,
          collapsedIconColor: Theme.of(context).colorScheme.onSurfaceVariant,
          title: Text(
            question,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 20.0),
              child: Text(
                answer,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
