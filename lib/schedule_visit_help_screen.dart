import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ScheduleVisitHelpScreen extends StatefulWidget {
  const ScheduleVisitHelpScreen({super.key});

  @override
  State<ScheduleVisitHelpScreen> createState() => _ScheduleVisitHelpScreenState();
}

class _ScheduleVisitHelpScreenState extends State<ScheduleVisitHelpScreen> {
  // Store expanded state for each item (by index)
  final List<bool> _isExpanded = [true, false, false, false, false, false];

  final List<Map<String, String>> _faqs = [
    {
      'question': 'How do I schedule a property visit?',
      'answer': 'Open the property listing you\'re interested in and tap \'Schedule a Visit\'. Select your preferred date, time slot, and visit type (in-person or virtual tour).'
    },
    {
      'question': 'Can I reschedule or cancel a visit?',
      'answer': 'Yes. Go to My Visits, select the scheduled visit, and tap either Reschedule or Cancel. Please try to do this at least 24 hours in advance.'
    },
    {
      'question': 'What is a virtual tour?',
      'answer': 'A virtual tour is a live video call where the agent walks through the property, allowing you to see it and ask questions from the comfort of your home.'
    },
    {
      'question': 'Will someone accompany me during the visit?',
      'answer': 'Yes, a verified property agent or the property owner will meet you at the site to show you around and answer your questions.'
    },
    {
      'question': 'How do I get directions to the property?',
      'answer': 'In your My Visits tab, tap on the upcoming visit and select "Get Directions" to open the location in Google Maps.'
    },
    {
      'question': 'What should I check during a site visit?',
      'answer': 'It\'s a good idea to check water pressure, natural lighting, mobile network reception, parking space, and the general neighborhood environment.'
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
          'Schedule a Visit',
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
