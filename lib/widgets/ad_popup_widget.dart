import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdPopupWidget extends StatefulWidget {
  final VoidCallback onClose;
  final VoidCallback onExplore;

  const AdPopupWidget({
    super.key,
    required this.onClose,
    required this.onExplore,
  });

  @override
  State<AdPopupWidget> createState() => _AdPopupWidgetState();
}

class _AdPopupWidgetState extends State<AdPopupWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _dismiss() {
    _controller.reverse().then((_) => widget.onClose());
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Material(
        color: Colors.black54,
        child: GestureDetector(
          onTap: _dismiss, // tap outside to dismiss
          child: Center(
            child: GestureDetector(
              onTap: () {}, // prevent dismiss when tapping inside
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 28),
                  constraints: const BoxConstraints(maxWidth: 400),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 30,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Image Section
                        Stack(
                          children: [
                            // Property Image
                            AspectRatio(
                              aspectRatio: 16 / 10,
                              child: Image.asset(
                                'assets/images/ad_poster_bg.jpg',
                                fit: BoxFit.cover,
                              ),
                            ),

                            // "EXCLUSIVE DEAL" badge (top-left)
                            Positioned(
                              top: 14,
                              left: 14,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1A2340).withValues(alpha: 0.88),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Text(
                                  'EXCLUSIVE DEAL',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ),
                            ),

                            // Close (x) button (top-right)
                            Positioned(
                              top: 10,
                              right: 10,
                              child: GestureDetector(
                                onTap: _dismiss,
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF1A2340),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Text + CTA Section
                        Container(
                          color: Colors.white,
                          padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title
                              Text(
                                'Premium Plots Available!',
                                style: GoogleFonts.inter(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF0F2057),
                                ),
                              ),
                              const SizedBox(height: 6),

                              // Subtitle
                              Text(
                                'Starting from \u20b925 Lakhs  \u2022  Limited Period',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: const Color(0xFF6B7280),
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Verified badge
                              Row(
                                children: [
                                  const Icon(
                                    Icons.verified_user_rounded,
                                    size: 16,
                                    color: Color(0xFF22C55E),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'MECO VERIFIED PLOTS',
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF22C55E),
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),

                              // Explore Now button
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {
                                    _dismiss();
                                    widget.onExplore();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF3B6FE8),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: Text(
                                    'Explore Now',
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
