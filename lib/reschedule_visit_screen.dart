import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'my_visits_screen.dart';
import 'visit_rescheduled_success_screen.dart';
class RescheduleVisitScreen extends StatefulWidget {
  final VisitMock visit;

  const RescheduleVisitScreen({super.key, required this.visit});

  @override
  State<RescheduleVisitScreen> createState() => _RescheduleVisitScreenState();
}

class _RescheduleVisitScreenState extends State<RescheduleVisitScreen> {
  static const Color accentBlue = Color(0xFF4B85F0);
  
  late DateTime _currentMonth;
  late DateTime _selectedDate;
  late DateTime _today;

  final List<String> _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];
  
  final List<String> _weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

  String selectedTime = "11:00 AM";

  final List<String> timeSlots = [
    "10:00 AM",
    "11:00 AM",
    "12:00 PM",
    "3:00 PM"
  ];

  @override
  void initState() {
    super.initState();
    _today = DateTime.now();
    _currentMonth = DateTime(_today.year, _today.month);
    _selectedDate = _today;
  }

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
                              Row(
                                children: [
                                  DropdownButton<int>(
                                    value: _currentMonth.month,
                                    menuMaxHeight: 192,
                                    icon: Icon(Icons.arrow_drop_down, color: titleColor, size: 20),
                                    underline: const SizedBox(),
                                    isDense: true,
                                    onChanged: (int? newMonth) {
                                      if (newMonth != null) {
                                        setState(() {
                                          _currentMonth = DateTime(_currentMonth.year, newMonth);
                                        });
                                      }
                                    },
                                    items: List.generate(12, (index) {
                                      return DropdownMenuItem<int>(
                                        value: index + 1,
                                        child: Text(
                                          _months[index],
                                          style: GoogleFonts.inter(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: titleColor,
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                  const SizedBox(width: 8),
                                  DropdownButton<int>(
                                    value: _currentMonth.year,
                                    menuMaxHeight: 192,
                                    icon: Icon(Icons.arrow_drop_down, color: titleColor, size: 20),
                                    underline: const SizedBox(),
                                    isDense: true,
                                    onChanged: (int? newYear) {
                                      if (newYear != null) {
                                        setState(() {
                                          _currentMonth = DateTime(newYear, _currentMonth.month);
                                        });
                                      }
                                    },
                                    items: List.generate(100, (index) {
                                      final year = DateTime.now().year + index;
                                      return DropdownMenuItem<int>(
                                        value: year,
                                        child: Text(
                                          year.toString(),
                                          style: GoogleFonts.inter(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: titleColor,
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.chevron_left, color: _isSameMonth(_currentMonth, _today) ? textMuted.withValues(alpha: 0.5) : titleColor, size: 20),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    onPressed: () {
                                      if (!_isSameMonth(_currentMonth, _today)) {
                                        setState(() {
                                          _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
                                        });
                                      }
                                    },
                                  ),
                                  const SizedBox(width: 16),
                                  IconButton(
                                    icon: Icon(Icons.chevron_right, color: titleColor, size: 20),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    onPressed: () {
                                      setState(() {
                                        _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
                                      });
                                    },
                                  ),
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
                    // Calculate end time (assuming 30 min duration for demo)
                    String endTime = selectedTime.contains("AM") 
                        ? selectedTime.replaceAll("11:00", "11:30").replaceAll("10:00", "10:30")
                        : selectedTime.replaceAll("12:00", "12:30").replaceAll("3:00", "3:30");
                    
                    String weekdayName = _weekdays[_selectedDate.weekday - 1];
                    String monthName = _months[_selectedDate.month - 1].substring(0, 3);
                    String fullMonthName = _months[_selectedDate.month - 1];
                    
                    // Update the visit model so it reflects in the My Visits screen
                    widget.visit.dateTime = '$weekdayName, ${_selectedDate.day} $monthName • $selectedTime';
                    widget.visit.timeSlot = '$selectedTime - $endTime';
                    
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => VisitRescheduledSuccessScreen(
                          visit: widget.visit,
                          newDate: '${_selectedDate.day} $fullMonthName ${_selectedDate.year}',
                          newTime: '$selectedTime - $endTime',
                        ),
                      ),
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

  bool _isSameMonth(DateTime a, DateTime b) => a.year == b.year && a.month == b.month;
  bool _isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  Widget _buildCalendarGrid(bool isDark, Color titleColor, Color textMuted) {
    int daysInMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
    int firstWeekday = DateTime(_currentMonth.year, _currentMonth.month, 1).weekday; // 1 = Monday, 7 = Sunday
    int offset = firstWeekday == 7 ? 0 : firstWeekday; // If Sunday is first day of week

    List<Widget> rows = [];
    List<Widget> currentRow = [];

    // Previous month's trailing days
    int daysInPrevMonth = DateTime(_currentMonth.year, _currentMonth.month, 0).day;
    for (int i = 0; i < offset; i++) {
      int prevDate = daysInPrevMonth - offset + 1 + i;
      currentRow.add(_buildDateCell(
        DateTime(_currentMonth.year, _currentMonth.month - 1, prevDate),
        isOtherMonth: true,
        isDark: isDark,
        titleColor: titleColor,
        textMuted: textMuted,
      ));
    }

    // Current month's days
    for (int i = 1; i <= daysInMonth; i++) {
      if (currentRow.length == 7) {
        rows.add(Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: currentRow));
        rows.add(const SizedBox(height: 12));
        currentRow = [];
      }
      currentRow.add(_buildDateCell(
        DateTime(_currentMonth.year, _currentMonth.month, i),
        isOtherMonth: false,
        isDark: isDark,
        titleColor: titleColor,
        textMuted: textMuted,
      ));
    }

    // Next month's leading days
    int nextDate = 1;
    while (currentRow.length < 7) {
      currentRow.add(_buildDateCell(
        DateTime(_currentMonth.year, _currentMonth.month + 1, nextDate),
        isOtherMonth: true,
        isDark: isDark,
        titleColor: titleColor,
        textMuted: textMuted,
      ));
      nextDate++;
    }
    if (currentRow.isNotEmpty) {
      rows.add(Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: currentRow));
    }

    return Column(children: rows);
  }
  
  Widget _buildDateCell(DateTime date, {required bool isOtherMonth, required bool isDark, required Color titleColor, required Color textMuted}) {
    bool isSelected = _isSameDay(date, _selectedDate);
    // Ignore time for comparison
    DateTime dateOnly = DateTime(date.year, date.month, date.day);
    DateTime todayOnly = DateTime(_today.year, _today.month, _today.day);
    bool isPast = dateOnly.isBefore(todayOnly);
    
    return GestureDetector(
      onTap: () {
        if (!isPast) {
          setState(() {
            _selectedDate = date;
            if (isOtherMonth) {
              _currentMonth = DateTime(date.year, date.month);
            }
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
            date.day.toString(),
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : (isOtherMonth ? FontWeight.normal : FontWeight.w500),
              color: isSelected 
                  ? Colors.white 
                  : (isPast || isOtherMonth ? textMuted.withValues(alpha: 0.5) : titleColor),
            ),
          ),
        ),
      ),
    );
  }
}
