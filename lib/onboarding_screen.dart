import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

// ─────────────────────────────────────────────
// Data model for each onboarding page
// ─────────────────────────────────────────────
class _OnboardPage {
  final String imagePath;
  final String title;
  final String description;

  const _OnboardPage({
    required this.imagePath,
    required this.title,
    required this.description,
  });
}

const _pages = [
  _OnboardPage(
    // High-quality living room / city-view image provided by user
    imagePath: 'assets/images/onboard_discover.png',
    title: 'Discover Your Next Property',
    description:
        'Explore verified properties across locations, budgets and property types—all in one place.',
  ),
  _OnboardPage(
    // High-quality tablet-comparison image provided by user
    imagePath: 'assets/images/onboard_compare.png',
    title: 'Compare Before You Decide',
    description:
        'Compare properties, prices, amenities and key details to make a confident decision.',
  ),
  _OnboardPage(
    // 3rd screen: Connect. Visit. Decide.
    imagePath: 'assets/images/onboard_connect.jpg',
    title: 'Connect. Visit. Decide.',
    description:
        'Contact sellers and agents, schedule property visits and move closer to your next property.',
  ),
];

// ─────────────────────────────────────────────
// Entry widget
// ─────────────────────────────────────────────
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToMain() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const _PlaceholderHome()),
    );
  }

  void _onNext() {
    if (_currentPage < _pages.length - 1) {
      // Go to next onboarding page
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      // Last implemented page — placeholder for Page 3 or go to main
      _goToMain();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentPageData = _pages[_currentPage];
    final isLastPage = _currentPage == _pages.length - 1;
    final bool isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    
    final bgColor = isDarkTheme ? Colors.black : Colors.white;
    final titleColor = isDarkTheme ? Colors.white : const Color(0xFF111111);
    final descColor = isDarkTheme ? const Color(0xFFCCCCCC) : const Color(0xFF888888);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenH = constraints.maxHeight;
            final screenW = constraints.maxWidth;

            // Image height ≈ 55 % of available height — matches reference
            final imageH = screenH * 0.55;
            // Horizontal margin matches reference design
            const hPad = 20.0;

            return Column(
              children: [
                // ── Paged hero images (only image swipes) ──
                SizedBox(
                  height: imageH,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _pages.length,
                    onPageChanged: (i) => setState(() => _currentPage = i),
                    itemBuilder: (_, i) => _HeroImage(
                      path: _pages[i].imagePath,
                      hPad: hPad,
                      height: imageH,
                    ),
                  ),
                ),

                // ── Text + dots + buttons ──
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: hPad),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: screenH * 0.035),

                        // Title
                        Text(
                          currentPageData.title,
                          style: GoogleFonts.inter(
                            fontSize: screenW * 0.062,
                            fontWeight: FontWeight.bold,
                            color: titleColor,
                            height: 1.2,
                          ),
                        ),

                        SizedBox(height: screenH * 0.014),

                        // Description
                        Text(
                          currentPageData.description,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: descColor,
                            height: 1.55,
                          ),
                        ),

                        const Spacer(),

                        // Dot indicators — centered
                        Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(_pages.length, (i) {
                              // 3 total dots
                              final active = i == _currentPage;
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                curve: Curves.easeInOut,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                width: active ? 22 : 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: active
                                      ? const Color(0xFF4A90E8)
                                      : const Color(0xFFD0D5DD),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              );
                            }),
                          ),
                        ),

                        SizedBox(height: screenH * 0.035),

                        // Next / Get Started button
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: _onNext,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4A90E8),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: Text(
                              isLastPage ? 'Get Started' : 'Next',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),

                        // Skip button (hidden on last page)
                        if (!isLastPage) ...[
                          Center(
                            child: TextButton(
                              onPressed: _goToMain,
                              child: Text(
                                'Skip',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: const Color(0xFF888888),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: screenH * 0.01),
                        ] else ...[
                          // Maintain spacing when skip is hidden
                          SizedBox(height: 48 + screenH * 0.01),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Hero image widget — rounded corners, full bleed
// ─────────────────────────────────────────────
class _HeroImage extends StatelessWidget {
  final String path;
  final double hPad;
  final double height;

  const _HeroImage({
    required this.path,
    required this.hPad,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(hPad, hPad, hPad, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          width: double.infinity,
          height: height - hPad,
          child: Image.asset(
            path,
            fit: BoxFit.cover,
            filterQuality: FilterQuality.high,
            // Meco logo is already embedded in the image — no overlay needed
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Placeholder home — replace with real home screen
// ─────────────────────────────────────────────
class _PlaceholderHome extends StatelessWidget {
  const _PlaceholderHome();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Text(
          'Home Screen\nComing Soon',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1A1A1A),
          ),
        ),
      ),
    );
  }
}
