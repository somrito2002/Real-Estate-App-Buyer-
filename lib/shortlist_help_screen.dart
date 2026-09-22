import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ShortlistHelpScreen extends StatefulWidget {
  const ShortlistHelpScreen({super.key});

  @override
  State<ShortlistHelpScreen> createState() => _ShortlistHelpScreenState();
}

class _ShortlistHelpScreenState extends State<ShortlistHelpScreen> {
  // Store expanded state for each item (by index)
  final List<bool> _isExpanded = [true, false, false, false, false, false];

  final List<Map<String, String>> _faqs = [
    {
      'question': 'How do I shortlist a property?',
      'answer': 'Tap the heart icon on any property card or listing page to add it to your shortlist. Access all shortlisted properties from the Wishlist tab in the bottom navigation.'
    },
    {
      'question': 'Can I organise my shortlisted properties?',
      'answer': 'Currently, all shortlisted properties are displayed in a single list within your Wishlist tab. Custom folders will be introduced in a future update.'
    },
    {
      'question': 'How do I save a search?',
      'answer': 'Once you have applied your desired filters on the search page, tap the "Save Search" button at the bottom of the filters menu to save it for quick access.'
    },
    {
      'question': 'How do I get alerts for saved searches?',
      'answer': 'You can enable email and push notifications for your saved searches in the Settings section under Notifications.'
    },
    {
      'question': 'Can I share my shortlist with someone?',
      'answer': 'While you cannot share the entire list at once, you can share individual properties by tapping the share icon on the property details page.'
    },
    {
      'question': 'How do I remove a property from my shortlist?',
      'answer': 'Simply tap the filled heart icon on the property card again, either from the search results or directly in your Wishlist tab, to remove it.'
    },
  ];

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
          'Shortlist & Saved Searches',
          style: GoogleFonts.inter(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: ListView.builder(
        itemCount: _faqs.length,
        itemBuilder: (context, index) {
          final faq = _faqs[index];
          final isExpanded = _isExpanded[index];

          return Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey.shade200,
                  width: 1,
                ),
              ),
            ),
            child: Theme(
              data: Theme.of(context).copyWith(
                dividerColor: Colors.transparent, // Remove internal divider
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
              ),
              child: ExpansionTile(
                initiallyExpanded: isExpanded,
                onExpansionChanged: (expanded) {
                  setState(() {
                    _isExpanded[index] = expanded;
                  });
                },
                tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                title: Text(
                  faq['question']!,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1D1E),
                  ),
                ),
                trailing: Icon(
                  isExpanded ? Icons.remove : Icons.add,
                  color: const Color(0xFF5A75A6), // The blueish color in the image
                  size: 20,
                ),
                childrenPadding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                children: [
                  Text(
                    faq['answer']!,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: const Color(0xFF757A82),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
