import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'my_visits_screen.dart';
import 'reschedule_visit_screen.dart';
import 'cancel_visit_screen.dart';
import 'services/visit_api_service.dart';

class VisitDetailsScreen extends StatefulWidget {
  final VisitMock visit;
  const VisitDetailsScreen({super.key, required this.visit});

  @override
  State<VisitDetailsScreen> createState() => _VisitDetailsScreenState();
}

class _VisitDetailsScreenState extends State<VisitDetailsScreen> {
  static const Color accentBlue = Color(0xFF4B85F0);
  GoogleMapController? _mapController;

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _openDirections() async {
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${widget.visit.lat},${widget.visit.lng}',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Could not open maps.', style: GoogleFonts.inter()),
          backgroundColor: Colors.red.shade700,
        ));
      }
    }
  }

  bool _isUpdating = false;
  Future<void> _updateVisitStatus(String newStatus) async {
    setState(() => _isUpdating = true);
    try {
      await VisitApiService.updateVisitStatus(
        visitId: widget.visit.refId,
        status: newStatus,
      );
      if (mounted) {
        setState(() {
          widget.visit.status = newStatus;
          _isUpdating = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Status updated to $newStatus')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUpdating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update status: $e')),
        );
      }
    }
  }

  List<Map<String, String>> _buildTimeline() {
    final upperStatus = widget.visit.status.toUpperCase();
    if (upperStatus == 'CANCELLED') {
      return [
        {'title': 'Visit Scheduled', 'status': 'Completed'},
        {'title': 'Visit Confirmed', 'status': 'Completed'},
        {'title': 'Visit Cancelled', 'status': 'Cancelled'},
        {'title': 'Visit Day', 'status': 'Pending'},
        {'title': 'OTP Verification', 'status': 'Pending'},
      ];
    }
    return [
      {'title': 'Visit Scheduled', 'status': 'Completed'},
      {'title': 'Visit Confirmed', 'status': 'Completed'},
      {
        'title': 'Visit Day',
        'status': (upperStatus == 'PENDING' || upperStatus == 'SCHEDULED' || upperStatus == 'CONFIRMED') ? 'Upcoming' : 'Completed',
      },
      {
        'title': 'OTP Verification',
        'status': upperStatus == 'COMPLETED' ? 'Completed' : 'Pending',
      },
      {
        'title': 'Visit Completed',
        'status': widget.visit.status == 'Completed' ? 'Completed' : 'Pending',
      },
    ];
  }

  void _showCancelDialog(
      bool isDark, Color cardBg, Color titleColor, Color textMuted, Color borderColor) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF3A1A1A) : const Color(0xFFFFF0F0),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(Icons.calendar_today_outlined,
                      color: isDark ? const Color(0xFFF87171) : const Color(0xFFEF4444),
                      size: 26),
                ),
              ),
              const SizedBox(height: 20),
              Text('Cancel Visit?',
                  style: GoogleFonts.inter(
                      fontSize: 18, fontWeight: FontWeight.bold, color: titleColor)),
              const SizedBox(height: 10),
              Text(
                'Are you sure you want to cancel your scheduled visit to ${widget.visit.title}?',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: 13, color: textMuted, height: 1.5),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(ctx).pop(); // close dialog
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => CancelVisitScreen(visit: widget.visit),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF4444),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text('Cancel Visit',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14)),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: titleColor,
                    side: BorderSide(color: borderColor),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text('Keep Visit',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F0F0F) : const Color(0xFFF0F2F6);
    final cardBg = isDark ? const Color(0xFF1C1C1C) : Colors.white;
    final borderColor = isDark ? Colors.white10 : const Color(0xFFE8E8E8);
    final titleColor = isDark ? Colors.white : const Color(0xFF1A1A2E);
    final textMuted = isDark ? Colors.white54 : const Color(0xFF888899);
    final timeline = _buildTimeline();

    final upperStatus = widget.visit.status.toUpperCase();
    String statusLabel = upperStatus;
    Color statusBg, statusText;

    if (upperStatus == 'PENDING' || upperStatus == 'SCHEDULED' || upperStatus == 'CONFIRMED') {
      statusBg = isDark ? const Color(0xFF0D2E18) : const Color(0xFFE6F9EE);
      statusText = const Color(0xFF16A34A);
    } else if (upperStatus == 'COMPLETED') {
      statusBg = isDark ? const Color(0xFF1A2A4A) : const Color(0xFFE8F0FE);
      statusText = accentBlue;
    } else {
      statusBg = isDark ? const Color(0xFF3A1A1A) : const Color(0xFFFEE8E8);
      statusText = const Color(0xFFEF4444);
    }

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
        title: Text('My Visit',
            style: GoogleFonts.inter(
                fontSize: 18, fontWeight: FontWeight.bold, color: titleColor)),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ──────────────────────────────────────────────────────────────
            // 1. PROPERTY HERO CARD
            // ──────────────────────────────────────────────────────────────
            Container(
              color: cardBg,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.network(
                    widget.visit.imageUrl,
                    width: double.infinity,
                    height: 210,
                    fit: BoxFit.cover,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.visit.price,
                            style: GoogleFonts.inter(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: accentBlue)),
                        const SizedBox(height: 5),
                        Text(widget.visit.title,
                            style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: titleColor)),
                        const SizedBox(height: 5),
                        Row(children: [
                          Icon(Icons.location_on_outlined, size: 14, color: textMuted),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(widget.visit.location,
                                style: GoogleFonts.inter(fontSize: 12, color: textMuted)),
                          ),
                        ]),
                        const SizedBox(height: 12),
                        Row(children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF1A2A4A)
                                  : const Color(0xFFEEF3FF),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(widget.visit.visitType,
                                style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: accentBlue)),
                          ),
                          const Spacer(),
                          OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              foregroundColor: accentBlue,
                              side: const BorderSide(color: accentBlue),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 7),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text('View Property',
                                style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: accentBlue)),
                          ),
                        ]),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 6),

            // ──────────────────────────────────────────────────────────────
            // 2. VISIT STATUS
            // ──────────────────────────────────────────────────────────────
            if (widget.visit.status == 'Cancelled')
              Container(
                color: isDark ? const Color(0xFF2A1010) : const Color(0xFFFFF5F5),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Visit Status',
                            style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: titleColor)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            border: Border.all(color: const Color(0xFFEF4444)),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text('CANCELLED',
                              style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFFEF4444))),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text('This visit has been cancelled!',
                        style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFEF4444))),
                    const SizedBox(height: 4),
                    Text(
                        'The appointment has been cancelled. You can book another visit whenever you are ready.',
                        style: GoogleFonts.inter(fontSize: 12, color: textMuted, height: 1.4)),
                  ],
                ),
              )
            else if (widget.visit.status == 'Completed')
              Container(
                color: isDark ? const Color(0xFF0D2517) : const Color(0xFFF0FDF4),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Visit Status',
                            style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: titleColor)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            border: Border.all(color: const Color(0xFF16A34A)),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text('COMPLETED',
                              style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF16A34A))),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text('Your visit was completed successfully',
                        style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF16A34A))),
                    const SizedBox(height: 4),
                    Text(
                        'Thanks for visiting. Your visit and OTP verification are completed.',
                        style: GoogleFonts.inter(fontSize: 12, color: textMuted, height: 1.4)),
                  ],
                ),
              )
            else
              Container(
                color: cardBg,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Visit Status',
                            style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: titleColor)),
                        const SizedBox(height: 3),
                        Text('Visit visit is ${widget.visit.status.toLowerCase()}',
                            style: GoogleFonts.inter(fontSize: 12, color: textMuted)),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(statusLabel,
                          style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: statusText)),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 6),

            // ──────────────────────────────────────────────────────────────
            // 3. VISIT INFORMATION
            // ──────────────────────────────────────────────────────────────
            Container(
              color: cardBg,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Visit Information',
                      style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: titleColor)),
                  const SizedBox(height: 14),
                  _infoRow(Icons.calendar_today_outlined,
                      widget.visit.dateTime.split(' • ').first,
                      textMuted, titleColor, isDark),
                  const SizedBox(height: 12),
                  _infoRow(Icons.access_time_outlined, widget.visit.timeSlot,
                      textMuted, titleColor, isDark),
                  const SizedBox(height: 12),
                  _infoRow(Icons.person_outline_rounded, widget.visit.visitType,
                      textMuted, titleColor, isDark),
                  const SizedBox(height: 12),
                  _infoRow(Icons.location_on_outlined, widget.visit.location,
                      textMuted, titleColor, isDark),
                  const SizedBox(height: 12),
                  _infoRow(Icons.confirmation_number_outlined, widget.visit.refId,
                      textMuted, accentBlue, isDark),
                ],
              ),
            ),

            const SizedBox(height: 6),

            // ──────────────────────────────────────────────────────────────
            // 4. IN-PERSON VISIT BLOCK
            // ──────────────────────────────────────────────────────────────
            Container(
              color: cardBg,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.visit.visitType,
                      style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: titleColor)),
                  const SizedBox(height: 14),
                  Row(children: [
                    _iconBox(Icons.calendar_month_outlined, isDark),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.visit.dateTime.split(' • ').first,
                            style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: titleColor)),
                        const SizedBox(height: 2),
                        Text(widget.visit.timeSlot,
                            style: GoogleFonts.inter(fontSize: 12, color: textMuted)),
                      ],
                    ),
                  ]),
                  const SizedBox(height: 12),
                  Row(children: [
                    _iconBox(Icons.location_on_outlined, isDark),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(widget.visit.location,
                          style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: titleColor)),
                    ),
                  ]),
                ],
              ),
            ),

            const SizedBox(height: 6),

            // ──────────────────────────────────────────────────────────────
            // 5. PROPERTY REPRESENTATIVE
            // ──────────────────────────────────────────────────────────────
            Container(
              color: cardBg,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Property Representative',
                      style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: titleColor)),
                  const SizedBox(height: 14),
                  Row(children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor:
                          isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE0E4EE),
                      backgroundImage: const NetworkImage(
                          'https://images.unsplash.com/photo-1560250097-0b93528c311a?w=100&auto=format&fit=crop'),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.visit.agentName,
                              style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: titleColor)),
                          const SizedBox(height: 3),
                          Text(widget.visit.agentRole,
                              style: GoogleFonts.inter(fontSize: 12, color: textMuted)),
                        ],
                      ),
                    ),
                  ]),
                  const SizedBox(height: 14),
                  Row(children: [
                    Expanded(
                      child: SizedBox(
                        height: 42,
                        child: OutlinedButton.icon(
                          onPressed: (widget.visit.status == 'Cancelled' || widget.visit.status == 'Completed') ? null : () {},
                          icon: Icon(Icons.call_outlined, size: 16, color: (widget.visit.status == 'Cancelled' || widget.visit.status == 'Completed') ? textMuted : accentBlue),
                          label: Text('Call',
                              style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: (widget.visit.status == 'Cancelled' || widget.visit.status == 'Completed') ? textMuted : accentBlue)),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: (widget.visit.status == 'Cancelled' || widget.visit.status == 'Completed') ? borderColor : accentBlue),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 42,
                        child: ElevatedButton.icon(
                          onPressed: (widget.visit.status == 'Cancelled' || widget.visit.status == 'Completed') ? null : () {},
                          icon: Icon(Icons.chat_bubble_outline_rounded, size: 15, color: (widget.visit.status == 'Cancelled' || widget.visit.status == 'Completed') ? textMuted : Colors.white),
                          label: Text('Message',
                              style: GoogleFonts.inter(
                                  fontSize: 13, fontWeight: FontWeight.w600, color: (widget.visit.status == 'Cancelled' || widget.visit.status == 'Completed') ? textMuted : Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: (widget.visit.status == 'Cancelled' || widget.visit.status == 'Completed') ? (isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE5E5E5)) : accentBlue,
                            foregroundColor: (widget.visit.status == 'Cancelled' || widget.visit.status == 'Completed') ? textMuted : Colors.white,
                            disabledBackgroundColor: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE5E5E5),
                            disabledForegroundColor: textMuted,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                    ),
                  ]),
                ],
              ),
            ),

            const SizedBox(height: 6),

            // ──────────────────────────────────────────────────────────────
            // 6. VISIT VERIFICATION (OTP)
            // ──────────────────────────────────────────────────────────────
            if (widget.visit.status == 'Cancelled')
              Container(
                color: isDark ? const Color(0xFF2A1010) : const Color(0xFFFFF5F5),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Visit Verification',
                            style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: titleColor)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            border: Border.all(color: const Color(0xFFEF4444)),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text('OTP INACTIVE',
                              style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFFEF4444))),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'No OTP is Available, because this visit was cancelled.',
                      style: GoogleFonts.inter(fontSize: 12, color: textMuted, height: 1.5),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'OTP NOT AVAILABLE',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFEF4444),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text('Cancel Visit OTP',
                              style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: textMuted)),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            else if (widget.visit.status == 'Completed')
              Container(
                color: const Color(0xFF132920),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Visit Verification',
                            style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.surface)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text('Verified',
                              style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF16A34A))),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Visit verified successfully by ${widget.visit.agentName} on ${widget.visit.dateTime.split(' • ').first} at ${widget.visit.timeSlot}.',
                      style: GoogleFonts.inter(fontSize: 12, color: Colors.white70, height: 1.5),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E352B),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.check, color: Colors.white, size: 18),
                              const SizedBox(width: 6),
                              Text(
                                'VERIFIED',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.surface,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text('OTP VERIFIED - SUCCESS',
                              style: GoogleFonts.inter(
                                  fontSize: 10,
                                  color: Colors.white54)),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                color: cardBg,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Visit Verification',
                            style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: titleColor)),
                        Container(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1A2A4A)
                                : const Color(0xFFEEF3FF),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text('OTP ACTION',
                              style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: accentBlue)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Share the OTP to the property representative when they ask for it.',
                      style: GoogleFonts.inter(
                          fontSize: 12, color: textMuted, height: 1.5),
                    ),
                    const SizedBox(height: 18),
                    // Big OTP number
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: widget.visit.otp));
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('OTP copied!', style: GoogleFonts.inter()),
                            backgroundColor: accentBlue,
                            duration: const Duration(seconds: 2),
                          ));
                        },
                        child: Column(
                          children: [
                            Text(
                              widget.visit.otp,
                              style: GoogleFonts.inter(
                                fontSize: 52,
                                fontWeight: FontWeight.bold,
                                color: accentBlue,
                                letterSpacing: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text('Visit OTP',
                                style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: textMuted)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF2A1800)
                            : const Color(0xFFFFFBEB),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: isDark
                                ? const Color(0xFF7A5500)
                                : const Color(0xFFFDE68A)),
                      ),
                      child: Row(children: [
                        const Icon(Icons.warning_amber_rounded,
                            size: 15, color: Color(0xFFF59E0B)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Don't share this OTP with anyone before your visit.",
                            style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFFB45309)),
                          ),
                        ),
                      ]),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 6),

            // ──────────────────────────────────────────────────────────────
            // 7. VISIT LOCATION (MAP)
            // ──────────────────────────────────────────────────────────────
            Container(
              color: cardBg,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                    child: Text('Visit Location',
                        style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: titleColor)),
                  ),
                  SizedBox(
                    height: 175,
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(
                          target: LatLng(widget.visit.lat, widget.visit.lng),
                          zoom: 15),
                      markers: {
                        Marker(
                          markerId: const MarkerId('prop'),
                          position: LatLng(widget.visit.lat, widget.visit.lng),
                        ),
                      },
                      myLocationButtonEnabled: false,
                      zoomControlsEnabled: false,
                      scrollGesturesEnabled: false,
                      zoomGesturesEnabled: false,
                      onMapCreated: (c) => _mapController = c,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.location_on, size: 15, color: accentBlue),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(widget.visit.location,
                                  style: GoogleFonts.inter(
                                      fontSize: 13, color: titleColor, height: 1.4)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          height: 44,
                          child: ElevatedButton(
                            onPressed: _openDirections,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accentBlue,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            child: Text('Get Directions',
                                style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w600, fontSize: 14)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 6),

            // ──────────────────────────────────────────────────────────────
            // 8. VISIT TIMELINE
            // ──────────────────────────────────────────────────────────────
            Container(
              color: cardBg,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Visit Timeline',
                      style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: titleColor)),
                  const SizedBox(height: 16),
                  ...List.generate(timeline.length, (i) {
                    return _timelineRow(
                      timeline[i]['title']!,
                      timeline[i]['status']!,
                      i == timeline.length - 1,
                      isDark,
                      titleColor,
                      textMuted,
                    );
                  }),
                ],
              ),
            ),

            const SizedBox(height: 16),

            if (widget.visit.status == 'Cancelled')
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentBlue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('Book Another Visit',
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600, fontSize: 15)),
                  ),
                ),
              )
            else if (widget.visit.status == 'Completed')
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentBlue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('Share Visit Feedback',
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600, fontSize: 15)),
                  ),
                ),
              )
            else ...[
              // ──────────────────────────────────────────────────────────────
              // 9. RESCHEDULE VISIT
              // ──────────────────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => RescheduleVisitScreen(visit: widget.visit))),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFF59E0B),
                      backgroundColor:
                          isDark ? const Color(0xFF2A1800) : const Color(0xFFFFFBEB),
                      side: const BorderSide(color: Color(0xFFF59E0B)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('Reschedule Visit',
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: const Color(0xFFF59E0B))),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ──────────────────────────────────────────────────────────────
              // 10. UPDATE STATUS (CONFIRM/COMPLETE)
              // ──────────────────────────────────────────────────────────────
              if (upperStatus != 'CANCELLED' && upperStatus != 'COMPLETED')
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      if (upperStatus == 'PENDING' || upperStatus == 'SCHEDULED')
                        Expanded(
                          child: SizedBox(
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _isUpdating ? null : () => _updateVisitStatus('CONFIRMED'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF16A34A),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              child: _isUpdating 
                                ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : Text('Confirm Visit',
                                  style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15)),
                            ),
                          ),
                        ),
                      if (upperStatus == 'PENDING' || upperStatus == 'SCHEDULED')
                        const SizedBox(width: 12),
                      
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isUpdating ? null : () => _updateVisitStatus('COMPLETED'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accentBlue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            child: _isUpdating 
                                ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : Text('Complete Visit',
                                style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              if (upperStatus != 'CANCELLED' && upperStatus != 'COMPLETED')
                const SizedBox(height: 12),

              // ──────────────────────────────────────────────────────────────
              // 11. CANCEL VISIT
              // ──────────────────────────────────────────────────────────────
              if (upperStatus != 'CANCELLED' && upperStatus != 'COMPLETED')
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: () => _showCancelDialog(
                        isDark, cardBg, titleColor, textMuted, borderColor),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFEF4444),
                      backgroundColor:
                          isDark ? const Color(0xFF2A1010) : const Color(0xFFFFF5F5),
                      side: const BorderSide(color: Color(0xFFEF4444)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('Cancel Visit',
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: const Color(0xFFEF4444))),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ── HELPER: icon box for in-person visit section ────────────────────────
  Widget _iconBox(IconData icon, bool isDark) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2A4A) : const Color(0xFFEEF3FF),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, size: 18, color: accentBlue),
    );
  }

  // ── HELPER: info row with square icon badge ─────────────────────────────
  Widget _infoRow(IconData icon, String text, Color muted, Color valueColor, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF252530) : const Color(0xFFF5F6FA),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: muted),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(text,
                style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: valueColor)),
          ),
        ),
      ],
    );
  }

  // ── HELPER: timeline row ────────────────────────────────────────────────
  Widget _timelineRow(String title, String status, bool isLast, bool isDark,
      Color titleColor, Color textMuted) {
    final isCompleted = status == 'Completed';
    final isUpcoming = status == 'Upcoming';
    final isCancelled = status == 'Cancelled';

    Color dotColor, lineColor, labelColor, labelBg;
    Widget dot;

    if (isCompleted) {
      dotColor = accentBlue;
      lineColor = accentBlue;
      labelColor = accentBlue;
      labelBg = isDark ? const Color(0xFF1A2A4A) : const Color(0xFFEEF3FF);
      dot = Container(
        width: 20,
        height: 20,
        decoration: const BoxDecoration(color: accentBlue, shape: BoxShape.circle),
        child: const Icon(Icons.check, color: Colors.white, size: 12),
      );
    } else if (isCancelled) {
      dotColor = const Color(0xFFEF4444);
      lineColor = const Color(0xFFEF4444);
      labelColor = const Color(0xFFEF4444);
      labelBg = Colors.white;
      dot = Container(
        width: 20,
        height: 20,
        decoration: const BoxDecoration(
          color: Color(0xFFEF4444),
          shape: BoxShape.circle,
        ),
      );
    } else if (isUpcoming) {
      dotColor = const Color(0xFFF59E0B);
      lineColor = isDark ? Colors.white12 : const Color(0xFFDDDDDD);
      labelColor = const Color(0xFFF59E0B);
      labelBg = isDark ? const Color(0xFF2A1800) : const Color(0xFFFFFBEB);
      dot = Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDark ? const Color(0xFF2A1800) : const Color(0xFFFFFBEB),
          border: Border.all(color: const Color(0xFFF59E0B), width: 2),
        ),
      );
    } else {
      dotColor = isDark ? Colors.white24 : const Color(0xFFCCCCCC);
      lineColor = isDark ? Colors.white12 : const Color(0xFFDDDDDD);
      labelColor = textMuted;
      labelBg = isDark ? const Color(0xFF252530) : const Color(0xFFF4F4F4);
      dot = Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: dotColor, width: 2),
        ),
      );
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 20,
            child: Column(
              children: [
                dot,
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 3),
                      decoration: BoxDecoration(
                          color: lineColor, borderRadius: BorderRadius.circular(1)),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title,
                      style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isCompleted ? titleColor : textMuted)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration:
                        BoxDecoration(color: labelBg, borderRadius: BorderRadius.circular(20)),
                    child: Text(status,
                        style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: labelColor)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
