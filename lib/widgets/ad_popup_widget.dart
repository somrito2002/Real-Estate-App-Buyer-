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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // ── Colour tokens ────────────────────────────────────────────────────────
    // Card background
    final cardBg = isDark ? const Color(0xFF1C1C2E) : Colors.white;

    // Title colour
    final titleColor =
        isDark ? const Color(0xFFE8EDFF) : const Color(0xFF0F2057);

    // Subtitle / muted text
    final subtitleColor =
        isDark ? const Color(0xFF9AA5C4) : const Color(0xFF6B7280);

    // Close button + badge background
    const badgeBg = Color(0xFF0D1B3E);

    // Scrim behind popup (slightly lighter in dark so card pops more)
    final scrimColor =
        isDark ? Colors.black.withValues(alpha: 0.72) : Colors.black54;

    // Divider / separator between image and text panel (dark only)
    final dividerColor =
        isDark ? Colors.white.withValues(alpha: 0.06) : Colors.transparent;

    // Glow/shadow on the card
    final shadowColor = isDark
        ? const Color(0xFF4B85F0).withValues(alpha: 0.18)
        : Colors.black.withValues(alpha: 0.22);

    // CTA button gradient
    const ctaStart = Color(0xFF3B6FE8);
    const ctaEnd = Color(0xFF5B8FFF);
    // ────────────────────────────────────────────────────────────────────────

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Material(
        color: scrimColor,
        child: GestureDetector(
          onTap: _dismiss,
          child: Center(
            child: GestureDetector(
              onTap: () {},
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 28),
                  constraints: const BoxConstraints(maxWidth: 400),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(24),
                    border: isDark
                        ? Border.all(
                            color: Colors.white.withValues(alpha: 0.08),
                            width: 1,
                          )
                        : null,
                    boxShadow: [
                      BoxShadow(
                        color: shadowColor,
                        blurRadius: isDark ? 40 : 30,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ── Image Section ──────────────────────────────────
                        Stack(
                          children: [
                            // Property photo
                            AspectRatio(
                              aspectRatio: 16 / 10,
                              child: Image.asset(
                                'assets/images/ad_poster_bg.jpg',
                                fit: BoxFit.cover,
                              ),
                            ),

                            // Dark gradient overlay on image (dark mode only)
                            if (isDark)
                              Positioned.fill(
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        const Color(0xFF1C1C2E)
                                            .withValues(alpha: 0.55),
                                      ],
                                      stops: const [0.5, 1.0],
                                    ),
                                  ),
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
                                  color: badgeBg.withValues(alpha: 0.88),
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

                            // Close × button (top-right)
                            Positioned(
                              top: 10,
                              right: 10,
                              child: GestureDetector(
                                onTap: _dismiss,
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: badgeBg,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            Colors.black.withValues(alpha: 0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
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

                        // Hairline separator (dark mode)
                        if (isDark)
                          Divider(height: 1, thickness: 1, color: dividerColor),

                        // ── Text + CTA Section ────────────────────────────
                        Container(
                          color: cardBg,
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
                                  color: titleColor,
                                ),
                              ),
                              const SizedBox(height: 6),

                              // Subtitle
                              Text(
                                'Starting from \u20b925 Lakhs  \u2022  Limited Period',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: subtitleColor,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              const SizedBox(height: 12),

                              // MECO Verified badge
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

                              // Explore Now CTA button
                              SizedBox(
                                width: double.infinity,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [ctaStart, ctaEnd],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow: isDark
                                        ? [
                                            BoxShadow(
                                              color: ctaStart.withValues(
                                                  alpha: 0.4),
                                              blurRadius: 16,
                                              offset: const Offset(0, 4),
                                            ),
                                          ]
                                        : [],
                                  ),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      _dismiss();
                                      widget.onExplore();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(14),
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
