import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BuyingPropertyHelpScreen extends StatelessWidget {
  const BuyingPropertyHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Buying a Property',
          style: GoogleFonts.inter(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildFaqItem(
              question: 'How do I search for properties?',
              answer:
                  'Use the search bar on the home screen. You can filter by location, price range, property type, BHK configuration, and amenities. Save your searches for quick access later.',
              initiallyExpanded: true,
            ),
            _buildFaqItem(
              question: 'What does \'Under Construction\' vs \'Ready to Move\' mean?',
              answer: '...', // Add placeholder text or leave empty as per design
            ),
            _buildFaqItem(
              question: 'How do I schedule a site visit?',
              answer: '...',
            ),
            _buildFaqItem(
              question: 'What documents do I need to buy a property?',
              answer: '...',
            ),
            _buildFaqItem(
              question: 'How do I make an enquiry about a property?',
              answer: '...',
            ),
            _buildFaqItem(
              question: 'What is RERA registration?',
              answer: '...',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqItem({
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
            bottom: BorderSide(color: Colors.grey.shade200),
          ),
        ),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          iconColor: const Color(0xFF4A85F6),
          collapsedIconColor: const Color(0xFF5F6368),
          title: Text(
            question,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1D1E),
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 20.0),
              child: Text(
                answer,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: const Color(0xFF5F6368),
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
