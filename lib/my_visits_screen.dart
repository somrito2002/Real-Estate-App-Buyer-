import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'visit_details_screen.dart';
import 'home_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'services/visit_api_service.dart';
import 'services/property_api_service.dart';
import 'models/property_model.dart';
import 'models/visit_model.dart';
class VisitMock {
  final String imageUrl;
  final String title;
  String visitType;
  String status; // 'Upcoming', 'Completed', 'Cancelled'
  String dateTime;
  String location;
  String price;
  String timeSlot;
  final String refId;
  final String agentName;
  final String agentRole;
  final String agentImageUrl;
  final String agentPhone;
  final String otp;
  final double lat;
  final double lng;
  final DateTime? parsedDateTime;
  final Visit? rawVisit;
  final String? partnerId;

  VisitMock({
    required this.imageUrl,
    required this.title,
    required this.visitType,
    required this.status,
    required this.dateTime,
    required this.location,
    required this.price,
    required this.timeSlot,
    required this.refId,
    required this.agentName,
    required this.agentRole,
    required this.agentImageUrl,
    required this.agentPhone,
    required this.otp,
    required this.lat,
    required this.lng,
    this.parsedDateTime,
    this.rawVisit,
    this.partnerId,
  });
}

// Make _mockVisits mutable
final List<VisitMock> mockVisits = [
  VisitMock(
    imageUrl: 'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?w=400&auto=format&fit=crop',
    title: 'DLF The Crest',
    visitType: 'In-Person Visit',
    status: 'Upcoming',
    dateTime: 'Sunday, 28 Jan • 11:30 AM',
    location: 'DLF Phase 5, Gurgaon',
    price: '₹2.45 Cr',
    timeSlot: '11:30 AM - 12:30 PM',
    refId: 'MECO-893011',
    agentName: 'Arjun Malhotra',
    agentRole: 'Assigned Property Agent',
    agentImageUrl: 'https://images.unsplash.com/photo-1560250097-0b93528c311a?w=100&auto=format&fit=crop',
    agentPhone: '',
    otp: '487476',
    lat: 28.4595,
    lng: 77.0266,
    parsedDateTime: DateTime.now().add(const Duration(days: 1)),
  ),
  VisitMock(
    imageUrl: 'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?w=400&auto=format&fit=crop',
    title: 'Vasant Vihar Premium Flat',
    visitType: 'In-Person Visit',
    status: 'Completed',
    dateTime: 'Sunday, 14 Jan • 02:00 PM',
    location: 'Vasant Vihar, New Delhi',
    price: '₹5.50 Cr',
    timeSlot: '02:00 PM - 03:00 PM',
    refId: 'MECO-748392',
    agentName: 'Priya Sharma',
    agentRole: 'Senior Property Agent',
    agentImageUrl: 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=100&auto=format&fit=crop',
    agentPhone: '',
    otp: '312859',
    lat: 28.5726,
    lng: 77.1659,
    parsedDateTime: DateTime.now().subtract(const Duration(days: 1)),
  ),
  VisitMock(
    imageUrl: 'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?w=400&auto=format&fit=crop',
    title: '3 BHK Premium Apartment',
    visitType: 'Virtual Visit',
    status: 'Completed',
    dateTime: 'Wednesday, 10 Jan • 04:30 PM',
    location: 'Bandra West, Mumbai',
    price: '₹3.20 Cr',
    timeSlot: '04:30 PM - 05:30 PM',
    refId: 'MECO-229103',
    agentName: 'Rahul Desai',
    agentRole: 'Virtual Tour Expert',
    agentImageUrl: 'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=100&auto=format&fit=crop',
    agentPhone: '',
    otp: '924167',
    lat: 19.0596,
    lng: 72.8295,
    parsedDateTime: DateTime.now().subtract(const Duration(days: 2)),
  ),
];

class MyVisitsScreen extends StatefulWidget {
  final bool isEmbedded;
  
  const MyVisitsScreen({super.key, this.isEmbedded = false});

  @override
  State<MyVisitsScreen> createState() => _MyVisitsScreenState();
}

class _MyVisitsScreenState extends State<MyVisitsScreen> {
  static const Color accentBlue = Color(0xFF4B85F0);
  String _selectedFilter = 'Upcoming';
  List<VisitMock> _visits = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchVisits();
  }

  Future<void> _fetchVisits() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final apiVisits = await VisitApiService.getVisits();
      
      // Fetch full property details concurrently to get the correct real property images
      final propertyFutures = apiVisits.map((v) => 
        PropertyApiService.getPropertyById(v.property.id).catchError((_) => null as dynamic)
      );
      final properties = await Future.wait(propertyFutures);

      final mappedVisits = apiVisits.asMap().entries.map((entry) {
        final index = entry.key;
        final v = entry.value;
        final Property? prop = properties[index] as Property?;
        
        String finalImageUrl = v.property.imageUrl;
        if (prop != null && prop.imageUrl.isNotEmpty) {
          finalImageUrl = prop.imageUrl;
        }

        DateTime? parsedDT;
        try {
          // Parse ISO date (YYYY-MM-DD)
          parsedDT = DateTime.parse(v.date);
        } catch (e) {
          try {
            // Fallback for "Saturday, 10 October 2026" format
            parsedDT = DateFormat('EEEE, d MMMM yyyy').parse(v.date);
          } catch (e2) {
            try {
              // Fallback for "10 October 2026" format
              parsedDT = DateFormat('d MMMM yyyy').parse(v.date);
            } catch (e3) {
              // Ignore
            }
          }
        }

        return VisitMock(
          imageUrl: finalImageUrl,
          title: v.property.title,
          visitType: 'In-Person Visit',
          status: v.status, // Strictly fetch status from backend API
          dateTime: '${v.date} • ${v.time}',
          location: (prop != null && prop.address.isNotEmpty) ? prop.address : v.property.city,
          price: (prop != null) ? prop.price : 'Price on Request',
          timeSlot: v.time,
          refId: v.id,
          agentName: prop?.partner?.fullName ?? 'Assigned Agent',
          agentRole: prop?.partner?.companyName ?? 'Property Agent',
          agentImageUrl: (prop?.partner?.profilePicture != null && prop!.partner!.profilePicture.isNotEmpty) ? prop.partner!.profilePicture : 'https://images.unsplash.com/photo-1560250097-0b93528c311a?w=100&auto=format&fit=crop',
          agentPhone: prop?.partner?.number ?? '',
          otp: '123456',
          lat: (prop != null && prop.lat != null) ? prop.lat! : 28.4595,
          lng: (prop != null && prop.lng != null) ? prop.lng! : 77.0266,
          parsedDateTime: parsedDT,
          rawVisit: v,
          partnerId: prop?.partner?.id ?? '',
        );
      }).toList();

      setState(() {
        _visits = mappedVisits;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _visits = [];
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load visits: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final bgColor = isDark ? Color(0xFF121212) : Theme.of(context).colorScheme.surface; // Slightly off-white for background
    final titleColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final cardBgColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final cardBorderColor = isDark ? Colors.white12 : const Color(0xFFEEEEEE);
    final chipBgUnselected = isDark ? const Color(0xFF2A2A2A) : Colors.white;
    final chipBorderUnselected = isDark ? Colors.white12 : const Color(0xFFE0E0E0);
    final textMuted = isDark ? Colors.white54 : const Color(0xFF666666);
    final dividerColor = isDark ? Colors.white12 : const Color(0xFFEEEEEE);

    List<VisitMock> filteredVisits = _visits.where((v) {
      if (_selectedFilter == 'Upcoming') {
        return v.status.toUpperCase() == 'PENDING' || 
               v.status.toUpperCase() == 'RESCHEDULED' || 
               v.status.toUpperCase() == 'CONFIRMED' || 
               v.status.toUpperCase() == 'ACCEPTED';
      }
      if (_selectedFilter == 'Completed') {
        return v.status.toUpperCase() == 'COMPLETED';
      }
      if (_selectedFilter == 'Cancelled') {
        return v.status.toUpperCase() == 'CANCELLED' || v.status.toUpperCase() == 'REJECTED';
      }
      return true;
    }).toList();

    Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                _buildFilterChip('Upcoming', isDark, chipBgUnselected, chipBorderUnselected),
                const SizedBox(width: 8),
                _buildFilterChip('Completed', isDark, chipBgUnselected, chipBorderUnselected),
                const SizedBox(width: 8),
                _buildFilterChip('Cancelled', isDark, chipBgUnselected, chipBorderUnselected),
              ],
            ),
          ),
          
          // Visit List
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator()) 
              : (_visits.isEmpty 
                  ? const Center(child: Text("No visits found.")) 
                  : ListView.separated(
                      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 100),
                      itemCount: filteredVisits.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final visit = filteredVisits[index];
                        return _buildVisitCard(visit, cardBgColor, cardBorderColor, titleColor, textMuted, dividerColor, isDark);
                      },
                    )),
          ),
        ],
      );
    if (!widget.isEmbedded) {
      return Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: bgColor,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: titleColor),
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const HomeScreen()),
                (route) => false,
              );
            },
          ),
          title: Text(
            'visits.my_visits'.tr(),
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: titleColor,
            ),
          ),
          centerTitle: false,
          actions: [
            IconButton(
              icon: Icon(Icons.more_vert, color: titleColor),
              onPressed: () {},
            ),
          ],
        ),
        body: content,
      );
    }

    return content;
  }

  Widget _buildFilterChip(String label, bool isDark, Color bgUnselected, Color borderUnselected) {
    // We compare with the translated label but store the original or compare with tr
    final isSelected = _selectedFilter.tr() == label || _selectedFilter == label || 'visits.${_selectedFilter.toLowerCase()}'.tr() == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? accentBlue : bgUnselected,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? accentBlue : borderUnselected,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? Colors.white : (isDark ? Colors.white70 : const Color(0xFF666666)),
          ),
        ),
      ),
    );
  }

  Widget _buildVisitCard(
    VisitMock visit,
    Color cardBg,
    Color borderColor,
    Color titleColor,
    Color textMuted,
    Color dividerColor,
    bool isDark,
  ) {
    Color badgeBg;
    Color badgeText;
    
    final upperStatus = visit.status.toUpperCase();
    if (upperStatus == 'PENDING' || upperStatus == 'SCHEDULED' || upperStatus == 'CONFIRMED') {
      badgeBg = isDark ? const Color(0xFF1A2A4A) : const Color(0xFFE8F0FE);
      badgeText = const Color(0xFF4B85F0);
    } else if (upperStatus == 'COMPLETED') {
      badgeBg = isDark ? const Color(0xFF1A3320) : const Color(0xFFE8F8F0);
      badgeText = isDark ? const Color(0xFF4ADE80) : const Color(0xFF22C55E);
    } else {
      badgeBg = isDark ? const Color(0xFF3A1A1A) : const Color(0xFFFEE8E8);
      badgeText = isDark ? const Color(0xFFF87171) : const Color(0xFFEF4444);
    }

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    visit.imageUrl,
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
                        visit.title,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: titleColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        visit.visitType == 'In-Person Visit' ? 'visits.in_person_visit'.tr() : 'visits.virtual_visit'.tr(),
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: accentBlue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    visit.status,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: badgeText,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          Divider(height: 1, color: dividerColor),
          
          // Bottom section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today_outlined, size: 14, color: textMuted),
                    const SizedBox(width: 8),
                    Text(
                      visit.dateTime,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: isDark ? Colors.white70 : const Color(0xFF444444),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => VisitDetailsScreen(visit: visit),
                      ),
                    ).then((_) {
                      if (mounted) {
                        _fetchVisits();
                      }
                    });
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'visits.view_details'.tr(),
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: accentBlue,
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward,
                        size: 14,
                        color: accentBlue,
                      ),
                    ],
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
