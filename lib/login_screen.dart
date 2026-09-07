import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'register_screen.dart';
import 'home_screen.dart';
import 'phone_number_screen.dart';

/// Login screen for Meco Technologies app.
/// Matches the "Welcome Back" design (something.png reference).
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _isLoading = false;
  bool _isConnected = true;
  bool _showVerificationError = false;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  static const Color accentBlue = Color(0xFF4B85F0);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(const AssetImage('assets/images/MECO TECHNOLOGIES PR-Photoroom.png'), context);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _checkConnectivity();
      _connectivitySubscription = Connectivity().onConnectivityChanged.listen((results) {
        _updateConnectionStatus(results);
      });
    });
  }

  Future<void> _checkConnectivity() async {
    final results = await Connectivity().checkConnectivity();
    _updateConnectionStatus(results);
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    bool connected = results.any((r) => r != ConnectivityResult.none);
    setState(() {
      _isConnected = connected;
    });
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _showVerificationError = false;
      });
      // TODO: replace with your real authentication call.
      Future.delayed(const Duration(seconds: 1), () async {
        if (!mounted) return;
        setState(() => _isLoading = false);
        
        bool isEmailCorrect = _emailController.text.trim() == 'user1@gmail.com';
        bool isPasswordCorrect = _passwordController.text == 'nopass';
        
        if (isEmailCorrect && isPasswordCorrect) {
          // Save login state
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isLoggedIn', true);
          if (!mounted) return;
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        } else if (!isEmailCorrect && !isPasswordCorrect) {
          setState(() => _showVerificationError = true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('invalid login credentials'),
              backgroundColor: Colors.red,
            ),
          );
        }
      });
    }
  }

  void _handleGoogleLogin() {
    // TODO: hook up Google sign-in.
  }

  void _handleAppleLogin() {
    // TODO: hook up Apple sign-in.
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor    = isDark ? Colors.black        : Colors.white;
    final titleColor = isDark ? Colors.white        : const Color(0xFF111111);
    final descColor  = isDark ? const Color(0xFFCCCCCC) : const Color(0xFF888888);
    final labelColor = isDark ? Colors.white        : Colors.black;
    final borderColor= isDark ? const Color(0xFF3A3A3C) : const Color(0xFFE0E0E0);
    final hintColor  = isDark ? const Color(0xFF7A7A7E) : const Color(0xFFB3B3B3);
    final fieldFill  = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final dividerClr = isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE5E7EB);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),

                // ── HEADER: back arrow + globe logo + brand name ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildHeader(context, titleColor, dividerClr),
                ),

                if (_showVerificationError) ...[
                  Container(
                    width: double.infinity,
                    color: isDark ? const Color(0xFF1A233A) : const Color(0xFFF4F8FF),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: accentBlue, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Your account hasn't been verified yet.",
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: titleColor,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) => const PhoneNumberScreen()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accentBlue,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                            minimumSize: const Size(80, 32),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Text(
                            'Verify Now',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                if (!_isConnected) ...[
                  Container(
                    width: double.infinity,
                    color: const Color(0xFFFDE8E8),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Row(
                      children: [
                        const Icon(Icons.wifi_off, color: Color(0xFFEF4444), size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Connection lost. Please try again.',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: _checkConnectivity,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFEF4444),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                            minimumSize: const Size(80, 32),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Text(
                            'Try Again',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 36),

                      // ── WELCOME TEXT ──
                      Text(
                        'Welcome Back',
                        style: GoogleFonts.inter(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: titleColor,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Login to access premium listings and personalised property updates.',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: descColor,
                          height: 1.55,
                        ),
                      ),
                      const SizedBox(height: 28),

                      // ── EMAIL ──
                      _buildLabel('Email / Phone Number', labelColor),
                      const SizedBox(height: 8),
                      _buildEmailField(fieldFill, borderColor, hintColor, labelColor),
                      const SizedBox(height: 20),

                      // ── PASSWORD ──
                      _buildLabel('Password', labelColor),
                      const SizedBox(height: 8),
                      _buildPasswordField(fieldFill, borderColor, labelColor, descColor),
                      const SizedBox(height: 16),

                      // ── REMEMBER ME + FORGOT PASSWORD ──
                      _buildRememberForgotRow(descColor, borderColor),
                      const SizedBox(height: 24),

                      // ── LOGIN BUTTON ──
                      _buildLoginButton(),
                      const SizedBox(height: 24),

                      // ── OR CONTINUE WITH ──
                      _buildDivider(borderColor, descColor),
                      const SizedBox(height: 20),

                      // ── SOCIAL BUTTONS ──
                      _buildSocialButtons(borderColor, labelColor),
                      const SizedBox(height: 28),

                      // ── REGISTER LINK ──
                      _buildRegisterRow(descColor),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Header: back arrow + globe image + Meco brand + divider ──
  Widget _buildHeader(BuildContext context, Color titleColor, Color dividerColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Back arrow
            GestureDetector(
              onTap: () => Navigator.of(context).maybePop(),
              child: Icon(Icons.arrow_back, size: 22, color: titleColor),
            ),
            const SizedBox(width: 14),

            // Meco globe logo (from assets)
            Image.asset(
              'assets/images/MECO TECHNOLOGIES PR-Photoroom.png',
              width: 38,
              height: 38,
              fit: BoxFit.contain,
              gaplessPlayback: true,
            ),
            const SizedBox(width: 10),

            // Brand name + tagline
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Meco Technologies',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: titleColor,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  'EXCELLENCE IN INNOVATION',
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.6,
                    color: accentBlue,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 14),
        Divider(color: dividerColor, thickness: 1, height: 1),
      ],
    );
  }

  Widget _buildLabel(String text, Color color) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: color,
      ),
    );
  }

  InputDecoration _fieldDecoration({
    required Color fill,
    required Color border,
    Widget? suffixIcon,
    String? hintText,
    TextStyle? hintStyle,
  }) {
    return InputDecoration(
      filled: true,
      fillColor: fill,
      hintText: hintText,
      hintStyle: hintStyle,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      suffixIcon: suffixIcon,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: accentBlue, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
    );
  }

  Widget _buildEmailField(Color fill, Color border, Color hint, Color text) {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      style: GoogleFonts.inter(fontSize: 15, color: text),
      decoration: _fieldDecoration(
        fill: fill,
        border: border,
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter your email or phone number.';
        }
        final trimmed = value.trim();

        // If user starts entering any number
        if (RegExp(r'^[0-9]').hasMatch(trimmed)) {
          final digits = trimmed.replaceAll(' ', '').replaceAll('-', '');
          if (digits.length != 10 || !RegExp(r'^[0-9]+$').hasMatch(digits)) {
            return 'Please enter a valid mobile number.';
          }
          return null;
        }

        // If user starts entering or typing letters or alphabets
        if (RegExp(r'^[a-zA-Z]').hasMatch(trimmed)) {
          final emailRegex = RegExp(r'^[\w.+-]+@[\w-]+\.[a-zA-Z]{2,}$');
          if (!emailRegex.hasMatch(trimmed)) {
            return 'Please enter a valid email address.';
          }
          return null;
        }

        // If any special characters are typed at the start
        return 'Please enter your email or phone number.';
      },
    );
  }

  Widget _buildPasswordField(Color fill, Color border, Color text, Color iconColor) {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      style: GoogleFonts.inter(fontSize: 15, color: text),
      decoration: _fieldDecoration(
        fill: fill,
        border: border,
        suffixIcon: GestureDetector(
          onTap: () => setState(() => _obscurePassword = !_obscurePassword),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: iconColor,
                  size: 18,
                ),
                const SizedBox(width: 4),
                Text(
                  _obscurePassword ? 'Show' : 'Hide',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: iconColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty || value.length < 6) {
          return 'Incorrect password. Please try again.';
        }
        return null;
      },
    );
  }

  Widget _buildRememberForgotRow(Color textColor, Color borderColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: Checkbox(
                value: _rememberMe,
                onChanged: (value) => setState(() => _rememberMe = value ?? false),
                activeColor: accentBlue,
                side: BorderSide(color: borderColor, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Remember me',
              style: GoogleFonts.inter(fontSize: 14, color: textColor),
            ),
          ],
        ),
        GestureDetector(
          onTap: () {
            // TODO: navigate to forgot password screen.
          },
          child: Text(
            'Forgot Password?',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: accentBlue,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: accentBlue,
          disabledBackgroundColor: accentBlue.withAlpha(153),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.4,
                ),
              )
            : Text(
                'Login',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Widget _buildDivider(Color border, Color textColor) {
    return Row(
      children: [
        Expanded(child: Divider(color: border, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'or continue with',
            style: GoogleFonts.inter(color: textColor, fontSize: 13),
          ),
        ),
        Expanded(child: Divider(color: border, thickness: 1)),
      ],
    );
  }

  Widget _buildSocialButtons(Color border, Color textColor) {
    return Row(
      children: [
        Expanded(
          child: _SocialButton(
            label: 'Google',
            icon: Image.asset(
              'assets/images/google_logo.png',
              width: 22,
              height: 22,
              fit: BoxFit.contain,
            ),
            border: border,
            textColor: textColor,
            onTap: _handleGoogleLogin,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _SocialButton(
            label: 'Apple ID',
            icon: Icon(Icons.apple, size: 24, color: textColor),
            border: border,
            textColor: textColor,
            onTap: _handleAppleLogin,
          ),
        ),
      ],
    );
  }

  void _navigateToRegister() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const RegisterScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.fastOutSlowIn;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 220),
        reverseTransitionDuration: const Duration(milliseconds: 200),
      ),
    );
  }

  Widget _buildRegisterRow(Color textColor) {
    return Center(
      child: RichText(
        text: TextSpan(
          style: GoogleFonts.inter(fontSize: 14, color: textColor),
          children: [
            const TextSpan(text: "Don't have an account? "),
            TextSpan(
              text: 'Register Now',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                color: accentBlue,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = _navigateToRegister,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Social button ────────────────────────────────────────────
class _SocialButton extends StatelessWidget {
  final String label;
  final Widget icon;
  final Color border;
  final Color textColor;
  final VoidCallback onTap;

  const _SocialButton({
    required this.label,
    required this.icon,
    required this.border,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.zero,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
