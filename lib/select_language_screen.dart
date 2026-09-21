import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';

class SelectLanguageScreen extends StatefulWidget {
  const SelectLanguageScreen({super.key});

  @override
  State<SelectLanguageScreen> createState() => _SelectLanguageScreenState();
}

class _SelectLanguageScreenState extends State<SelectLanguageScreen> {
  late String _selectedLanguageCode;

  final List<Map<String, String>> _languages = [
    {
      'name': 'English',
      'code': 'en',
    },
    {
      'name': 'Hindi (हिन्दी)',
      'code': 'hi',
    },
    {
      'name': 'Bengali (বাংলা)',
      'code': 'bn',
    },
    {
      'name': 'Marathi (मराठी)',
      'code': 'mr',
    },
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _selectedLanguageCode = context.locale.languageCode;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFFAFAFA);
    final cardBgColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final borderColor = isDark ? Colors.white12 : const Color(0xFFEEEEEE);
    final titleColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final subtitleColor = isDark ? Colors.white70 : const Color(0xFF666666);
    final accentBlue = const Color(0xFF4B85F0);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: titleColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'language.title'.tr(),
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: titleColor,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'language.heading'.tr(),
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: titleColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'language.subheading'.tr(),
              style: GoogleFonts.inter(
                fontSize: 14,
                color: subtitleColor,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            
            // Language Options
            ..._languages.map((lang) {
              final isSelected = _selectedLanguageCode == lang['code'];
              final String subtitleKey = 'language.${lang['code']}_sub';
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedLanguageCode = lang['code']!;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: cardBgColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? accentBlue : borderColor,
                      width: isSelected ? 1.5 : 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'language.${lang['code']}'.tr(),
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: titleColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              subtitleKey.tr(),
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: subtitleColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? accentBlue : borderColor.withValues(alpha: 0.5),
                            width: isSelected ? 6 : 1.5,
                          ),
                          color: isSelected ? Colors.white : Colors.transparent,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 24),

            // Apply Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  context.setLocale(Locale(_selectedLanguageCode));
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentBlue,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'language.apply'.tr(),
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
