import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_screen.dart';

class NotificationItem {
  final String title;
  final String description;
  final String time;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final bool isUnread;

  NotificationItem({
    required this.title,
    required this.description,
    required this.time,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    this.isUnread = false,
  });
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String selectedFilter = 'All';
  bool _allRead = false;
  final List<String> filters = ['All', 'Enquiries', 'Visits', 'Properties'];

  final List<NotificationItem> notifications = [
    NotificationItem(
      title: 'Enquiry Response',
      description: 'Rajesh Sharma responded to your enquiry about 3 BHK in Durg: \'Available for visit.\'',
      time: 'Just now',
      icon: Icons.chat_bubble_outline_rounded,
      iconColor: const Color(0xFF4B85F0),
      iconBgColor: const Color(0xFF4B85F0).withOpacity(0.1),
      isUnread: true,
    ),
    NotificationItem(
      title: 'Visit Confirmed',
      description: 'Your visit to DLF The Crest is confirmed for Wed, 14 Oct at 10:30 AM.',
      time: '2 hours ago',
      icon: Icons.calendar_today_outlined,
      iconColor: const Color(0xFF10B981),
      iconBgColor: const Color(0xFF10B981).withOpacity(0.1),
      isUnread: true,
    ),
    NotificationItem(
      title: 'Price Drop Alert',
      description: 'A 3 BHK Apartment in your saved search dropped its price by ₹5 Lakh.',
      time: '1 day ago',
      icon: Icons.trending_down,
      iconColor: const Color(0xFFEF4444),
      iconBgColor: const Color(0xFFEF4444).withOpacity(0.1),
    ),
    NotificationItem(
      title: 'New Match Found',
      description: '3 new properties match your saved search for 2 BHK in Raipur.',
      time: '2 days ago',
      icon: Icons.home_outlined,
      iconColor: const Color(0xFFF59E0B),
      iconBgColor: const Color(0xFFF59E0B).withOpacity(0.1),
    ),
    NotificationItem(
      title: 'System Maintenance',
      description: 'Our dashboard will undergo routine system updates on Sunday from 2 AM IST.',
      time: '1 week ago',
      icon: Icons.settings_outlined,
      iconColor: const Color(0xFF6B7280),
      iconBgColor: const Color(0xFF6B7280).withOpacity(0.1),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFFFFFFF);
    final titleColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final textMuted = isDark ? Colors.white54 : const Color(0xFF666666);
    final dividerColor = isDark ? Colors.white12 : const Color(0xFFF0F0F0);
    
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
          'Notifications',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: titleColor,
          ),
        ),
        centerTitle: false,
        actions: [
          if (!_allRead)
            TextButton(
              onPressed: () {
                setState(() {
                  _allRead = true;
                });
              },
              child: Text(
                'Mark all read',
                style: GoogleFonts.inter(
                  color: const Color(0xFF4B85F0),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
      body: _allRead ? _buildEmptyState(isDark, titleColor) : Column(
        children: [
          Divider(height: 1, color: dividerColor),
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: filters.map((filter) {
                final isSelected = filter == selectedFilter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedFilter = filter;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF4B85F0) : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF4B85F0) : (isDark ? Colors.white24 : const Color(0xFFE5E7EB)),
                        ),
                      ),
                      child: Text(
                        filter,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected ? Colors.white : textMuted,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          
          Expanded(
            child: ListView.separated(
              itemCount: notifications.length,
              separatorBuilder: (context, index) => Divider(height: 1, color: dividerColor),
              itemBuilder: (context, index) {
                final notification = notifications[index];
                
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  color: isDark ? const Color(0xFF1E1E1E) : (notification.isUnread ? const Color(0xFFF8FAFC) : Colors.transparent),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Unread Dot Indicator
                      SizedBox(
                        width: 12,
                        child: notification.isUnread
                            ? Container(
                                margin: const EdgeInsets.only(top: 14),
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF4B85F0),
                                  shape: BoxShape.circle,
                                ),
                              )
                            : null,
                      ),
                      
                      // Icon
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isDark ? notification.iconColor.withOpacity(0.2) : notification.iconBgColor,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            notification.icon,
                            color: notification.iconColor,
                            size: 20,
                          ),
                        ),
                      ),
                      
                      const SizedBox(width: 12),
                      
                      // Content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              notification.title,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: titleColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              notification.description,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: textMuted,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              notification.time,
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: isDark ? Colors.white38 : const Color(0xFF9CA3AF),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark, Color titleColor) {
    final textMuted = isDark ? Colors.white54 : const Color(0xFF666666);
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFFFFFFF);

    return Container(
      color: bgColor,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Crossed bell icon in a circle
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF0F3FB),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.notifications_off_outlined,
                    size: 40,
                    color: isDark ? Colors.white38 : const Color(0xFF9CA3AF),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'No Notifications',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: titleColor,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "You'll see updates about your enquiries, visits, and saved searches here.",
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: textMuted,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                height: 46,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const HomeScreen()),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4B85F0),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Explore Properties',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

