import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PropertyEnquiriesHelpScreen extends StatefulWidget {
  const PropertyEnquiriesHelpScreen({super.key});

  @override
  State<PropertyEnquiriesHelpScreen> createState() => _PropertyEnquiriesHelpScreenState();
}

class _PropertyEnquiriesHelpScreenState extends State<PropertyEnquiriesHelpScreen> {
  // Store expanded state for each item (by index)
  final List<bool> _isExpanded = [true, false, false, false, false];

  final List<Map<String, String>> _faqs = [
    {
      'question': 'Where can I see my enquiries?',
      'answer': 'Go to Account → My Enquiries to view all your property enquiries, their status, and responses from builders and agents.'
    },
    {
      'question': 'How long does it take to get a response?',
      'answer': 'Most agents and builders typically respond within 24 to 48 hours. If you don\'t receive a response after this period, you can try sending a follow-up message.'
    },
    {
      'question': 'Can I withdraw an enquiry?',
      'answer': 'Yes, you can withdraw an enquiry by navigating to your My Enquiries section, selecting the specific enquiry, and choosing the "Withdraw" option.'
    },
    {
      'question': 'Why am I not getting responses to my enquiries?',
      'answer': 'Responses depend on the agent\'s availability. It may help to verify your contact information in your Profile or ensure the property is still actively listed.'
    },
    {
      'question': 'Can I enquire about multiple properties at once?',
      'answer': 'Currently, enquiries must be sent individually for each property to ensure the specific agent receives your request directly.'
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
          'Property Enquiries',
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
