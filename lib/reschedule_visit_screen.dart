import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'my_visits_screen.dart';

class RescheduleVisitScreen extends StatefulWidget {
  final VisitMock visit;

  const RescheduleVisitScreen({Key? key, required this.visit}) : super(key: key);

  @override
  State<RescheduleVisitScreen> createState() => _RescheduleVisitScreenState();
}

class _RescheduleVisitScreenState extends State<RescheduleVisitScreen> {
  static const Color accentBlue = Color(0xFF4B85F0);
  int selectedDate = 15;
  String selectedTime = "11:00 AM";

  final List<String> timeSlots = [
    "10:00 AM",
    "11:00 AM",
    "12:00 PM",
    "3:00 PM"
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFFFFFFF); 
    final titleColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final cardBgColor = isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF8F9FA);
    final cardBorderColor = isDark ? Colors.white12 : const Color(0xFFEEEEEE);
    final textMuted = isDark ? Colors.white54 : const Color(0xFF666666);
    
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
          'Reschedule Visit',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: titleColor,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Current Appointment Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardBgColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: cardBorderColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'CURRENT APPOINTMENT',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: textMuted,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF1A3320) : const Color(0xFFE8F8F0),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Scheduled',
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? const Color(0xFF4ADE80) : const Color(0xFF22C55E),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  widget.visit.imageUrl,
                                  width: 48,
                                  height: 48,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.visit.title,
                                      style: GoogleFonts.inter(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: titleColor,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${widget.visit.dateTime.split(' • ').first} at ${widget.visit.timeSlot}',
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    Text(
                      'Select New Date',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: titleColor,
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Calendar View
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardBgColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: cardBorderColor),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'October 2026',
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: titleColor,
                                ),
                              ),
                              Row(
                                children: [
                                  Icon(Icons.chevron_left, color: textMuted, size: 20),
                                  const SizedBox(width: 8),
                                  Icon(Icons.chevron_right, color: titleColor, size: 20),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'].map((day) {
                              return SizedBox(
                                width: 32,
                                child: Center(
                                  child: Text(
                                    day,
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      color: textMuted,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 12),
                          _buildCalendarGrid(isDark, titleColor, textMuted),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    Text(
                      'Select New Time Slot',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: titleColor,
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: timeSlots.map((time) {
                        final isSelected = time == selectedTime;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedTime = time;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected ? accentBlue : cardBgColor,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected ? accentBlue : cardBorderColor,
                              ),
                            ),
                            child: Text(
                              time,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                color: isSelected ? Colors.white : titleColor,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    
                    const SizedBox(height: 32), // Extra padding at bottom
                  ],
                ),
              ),
            ),
            
            // Bottom Action Button
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: bgColor,
                border: Border(
                  top: BorderSide(color: cardBorderColor),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    // Show a success message or navigate
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Visit rescheduled to Oct $selectedDate at $selectedTime'),
                        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.black87,
                      ),
                    );
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => const MyVisitsScreen(),
                      ),
                      (route) => false,
                    );
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
                    'Confirm Reschedule',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarGrid(bool isDark, Color titleColor, Color textMuted) {
    // Generate dates for October 2026 (starts on Thursday)
    // Days in Sep: 30 (so 27, 28, 29, 30 are before 1st)
    // Days in Oct: 31
    List<Widget> rows = [];
    List<Widget> currentRow = [];
    
    // First row
    List<int> firstRowDates = [27, 28, 29, 30, 1, 2, 3];
    for (int i = 0; i < 7; i++) {
      int date = firstRowDates[i];
      bool isPrevMonth = i < 4;
      currentRow.add(_buildDateCell(date, isPrevMonth, false, isDark, titleColor, textMuted));
    }
    rows.add(Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: currentRow));
    
    // Second row
    currentRow = [];
    for (int i = 4; i <= 10; i++) {
      currentRow.add(_buildDateCell(i, false, false, isDark, titleColor, textMuted));
    }
    rows.add(const SizedBox(height: 12));
    rows.add(Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: currentRow));
    
    // Third row
    currentRow = [];
    for (int i = 11; i <= 17; i++) {
      currentRow.add(_buildDateCell(i, false, i == selectedDate, isDark, titleColor, textMuted));
    }
    rows.add(const SizedBox(height: 12));
    rows.add(Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: currentRow));
    
    // In a full implementation, we'd add the remaining rows. 
    // Just keeping it simple here for the visual match.
    
    return Column(children: rows);
  }
  
  Widget _buildDateCell(int date, bool isPrevMonth, bool isSelected, bool isDark, Color titleColor, Color textMuted) {
    return GestureDetector(
      onTap: () {
        if (!isPrevMonth) {
          setState(() {
            selectedDate = date;
          });
        }
      },
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4B85F0) : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            date.toString(),
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : (isPrevMonth ? FontWeight.normal : FontWeight.w500),
              color: isSelected ? Colors.white : (isPrevMonth ? textMuted.withOpacity(0.5) : titleColor),
            ),
          ),
        ),
      ),
    );
  }
}
