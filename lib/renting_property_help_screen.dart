import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RentingPropertyHelpScreen extends StatelessWidget {
  const RentingPropertyHelpScreen({super.key});

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
          'Renting a Property',
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
              question: 'How do I find rental properties?',
              answer:
                  'Set the search filter to \'Rent\' on the home screen. Filter by locality, budget, furnishing status, and property type to find the perfect rental.',
              initiallyExpanded: true,
            ),
            _buildFaqItem(context, 
              question: 'What is a security deposit?',
              answer: '...', // Add placeholder text or leave empty as per design
            ),
            _buildFaqItem(context, 
              question: 'How do I contact the landlord or agent?',
              answer: '...',
            ),
            _buildFaqItem(context, 
              question: 'What should I check before signing a rental agreement?',
              answer: '...',
            ),
            _buildFaqItem(context, 
              question: 'Can I negotiate the rent?',
              answer: '...',
            ),
            _buildFaqItem(context, 
              question: 'How do I report maintenance issues?',
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
