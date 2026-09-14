import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'models/property_model.dart';
import 'my_visits_screen.dart';

class VisitScheduledSuccessScreen extends StatelessWidget {
  final Property property;
  final String visitDate;
  final String visitTime;

  const VisitScheduledSuccessScreen({
    Key? key,
    required this.property,
    required this.visitDate,
    required this.visitTime,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final bgColor = isDark ? const Color(0xFF121212) : Colors.white;
    final titleColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final subtitleColor = isDark ? Colors.white70 : const Color(0xFF666666);
    final accentBlue = const Color(0xFF4B85F0);
    
    final successCircleColor = isDark ? const Color(0xFF1A3320) : const Color(0xFFE8F8F0);
    final successIconColor = isDark ? const Color(0xFF4ADE80) : const Color(0xFF22C55E);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false, 
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: successCircleColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.check,
                    size: 50,
                    color: successIconColor,
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              Text(
                'Visit Scheduled!',
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: titleColor,
                ),
              ),
              
              const SizedBox(height: 16),
              
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    color: subtitleColor,
                    height: 1.5,
                  ),
                  children: [
                    const TextSpan(text: 'Your visit to '),
                    TextSpan(
                      text: property.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: titleColor,
                      ),
                    ),
                    const TextSpan(text: ' is\nconfirmed for '),
                    TextSpan(
                      text: visitDate,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: titleColor,
                      ),
                    ),
                    const TextSpan(text: ' at '),
                    TextSpan(
                      text: visitTime,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: titleColor,
                      ),
                    ),
                    const TextSpan(text: '.'),
                  ],
                ),
              ),
              
              const Spacer(flex: 3),
              
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: titleColor,
                    side: BorderSide(
                      color: isDark ? Colors.white24 : const Color(0xFFDDDDDD),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Add to Calendar',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Back to Property',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => const MyVisitsScreen(),
                    ),
                  );
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'View My Visits ',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: accentBlue,
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward,
                      size: 16,
                      color: accentBlue,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
