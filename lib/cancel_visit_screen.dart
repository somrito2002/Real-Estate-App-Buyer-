import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'my_visits_screen.dart';

class CancelVisitScreen extends StatefulWidget {
  final VisitMock visit;

  const CancelVisitScreen({super.key, required this.visit});

  @override
  State<CancelVisitScreen> createState() => _CancelVisitScreenState();
}

class _CancelVisitScreenState extends State<CancelVisitScreen> {
  static const Color accentBlue = Color(0xFF4B85F0);

  int _selectedReason = -1;
  bool _isCancelling = false;

  final List<Map<String, dynamic>> _reasons = [
    {
      'icon': Icons.schedule_outlined,
      'title': 'Change of Plans',
      'subtitle': 'My schedule has changed and I need to reschedule',
    },
    {
      'icon': Icons.search_outlined,
      'title': 'Found a Better Property',
      'subtitle': 'I found another property that better suits my needs',
    },
    {
      'icon': Icons.money_off_outlined,
      'title': 'Budget Constraints',
      'subtitle': 'The property price is out of my current budget',
    },
    {
      'icon': Icons.location_off_outlined,
      'title': 'Location Not Suitable',
      'subtitle': 'The location doesn\'t work for me anymore',
    },
    {
      'icon': Icons.info_outline,
      'title': 'Property Information Changed',
      'subtitle': 'The property details have changed significantly',
    },
    {
      'icon': Icons.more_horiz,
      'title': 'Other Reason',
      'subtitle': 'I have a different reason for cancelling',
    },
  ];

  void _confirmCancellation() async {
    setState(() => _isCancelling = true);
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;
    // Pop back to My Visits
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor =
        isDark ? const Color(0xFF121212) : const Color(0xFFF5F6FA);
    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final titleColor =
        isDark ? Colors.white : const Color(0xFF1A1A1A);
    final textMuted =
        isDark ? Colors.white54 : const Color(0xFF666666);
    final borderColor =
        isDark ? Colors.white12 : const Color(0xFFEEEEEE);
    final selectedBorder = const Color(0xFFEF4444);
    final selectedBg =
        isDark ? const Color(0xFF2A1010) : const Color(0xFFFFF5F5);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1C1C1C) : Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: titleColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Cancel Visit',
            style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: titleColor)),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Property summary card ─────────────────────────────────
                  Container(
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: borderColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(14)),
                          child: Image.network(
                            widget.visit.imageUrl,
                            width: double.infinity,
                            height: 140,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(widget.visit.price,
                                  style: GoogleFonts.inter(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: accentBlue)),
                              const SizedBox(height: 4),
                              Text(widget.visit.title,
                                  style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: titleColor)),
                              const SizedBox(height: 4),
                              Row(children: [
                                Icon(Icons.location_on_outlined,
                                    size: 13, color: textMuted),
                                const SizedBox(width: 3),
                                Expanded(
                                  child: Text(widget.visit.location,
                                      style: GoogleFonts.inter(
                                          fontSize: 12, color: textMuted)),
                                ),
                              ]),
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color:
                                      isDark ? const Color(0xFF2A1010) : const Color(0xFFFFF5F5),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                      color: const Color(0xFFEF4444)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.calendar_today_outlined,
                                        size: 12,
                                        color: Color(0xFFEF4444)),
                                    const SizedBox(width: 5),
                                    Text(widget.visit.dateTime,
                                        style: GoogleFonts.inter(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFFEF4444))),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Warning banner ────────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF2A1800)
                          : const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: isDark
                              ? const Color(0xFF7A5500)
                              : const Color(0xFFFDE68A)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.warning_amber_rounded,
                            size: 18, color: Color(0xFFF59E0B)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Cancelling this visit may affect your ability to revisit this property. The slot will be released for others.',
                            style: GoogleFonts.inter(
                                fontSize: 12,
                                color: isDark
                                    ? const Color(0xFFFBBF24)
                                    : const Color(0xFF92400E),
                                height: 1.5),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Reason for cancellation ───────────────────────────────
                  Text('Reason for Cancellation',
                      style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: titleColor)),
                  const SizedBox(height: 6),
                  Text('Please let us know why you\'re cancelling',
                      style: GoogleFonts.inter(
                          fontSize: 12, color: textMuted)),
                  const SizedBox(height: 14),

                  ...List.generate(_reasons.length, (i) {
                    final isSelected = _selectedReason == i;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedReason = i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isSelected ? selectedBg : cardBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                isSelected ? selectedBorder : borderColor,
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFFEF4444).withAlpha(20)
                                    : (isDark
                                        ? const Color(0xFF2A2A2A)
                                        : const Color(0xFFF4F4F4)),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                _reasons[i]['icon'] as IconData,
                                size: 20,
                                color: isSelected
                                    ? const Color(0xFFEF4444)
                                    : textMuted,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(_reasons[i]['title'] as String,
                                      style: GoogleFonts.inter(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: isSelected
                                              ? const Color(0xFFEF4444)
                                              : titleColor)),
                                  const SizedBox(height: 3),
                                  Text(
                                      _reasons[i]['subtitle'] as String,
                                      style: GoogleFonts.inter(
                                          fontSize: 11,
                                          color: textMuted,
                                          height: 1.4)),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected
                                    ? const Color(0xFFEF4444)
                                    : Colors.transparent,
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFFEF4444)
                                      : borderColor,
                                  width: 1.5,
                                ),
                              ),
                              child: isSelected
                                  ? const Icon(Icons.check,
                                      size: 12, color: Colors.white)
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),

          // ── Bottom action bar ───────────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1C1C1C) : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(15),
                  blurRadius: 12,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 14,
              bottom: MediaQuery.of(context).padding.bottom + 14,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: (_isCancelling || _selectedReason == -1) ? null : _confirmCancellation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF4444),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: isDark
                          ? const Color(0xFF3A1A1A)
                          : const Color(0xFFFFCDD2),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isCancelling
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : Text('Confirm Cancellation',
                            style: GoogleFonts.inter(
                                fontWeight: FontWeight.w600, fontSize: 15)),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: OutlinedButton(
                    onPressed:
                        _isCancelling ? null : () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: titleColor,
                      side: BorderSide(color: borderColor),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('Go Back',
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600, fontSize: 14)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
