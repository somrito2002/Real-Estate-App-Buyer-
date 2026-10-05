import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'otp_screen.dart';
import 'services/auth_api_service.dart';

/// Register screen for Meco Technologies app.
/// Matches the "Create Your Account" design uploaded by the user.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _occupationController = TextEditingController();

  bool _isLoading = false;
  bool _isConnected = true;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  String? _profileImagePath;

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
    _fullNameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _occupationController.dispose();
    super.dispose();
  }

  void _handleVerifyByEmail() async {
    if (_formKey.currentState!.validate()) {
      if (_isLoading) return;
      setState(() => _isLoading = true);
      try {
        if (_profileImagePath != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('cached_profilePhotoPath', _profileImagePath!);
        }

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('cached_fullName', _fullNameController.text.trim());
        await prefs.setString('cached_email', _emailController.text.trim());
        await prefs.setString('cached_mobile', _mobileController.text.trim());
        await prefs.setString('cached_occupation', _occupationController.text.trim());

        final response = await AuthApiService.signup(
          fullName: _fullNameController.text.trim(),
          number: _mobileController.text.trim(),
          email: _emailController.text.trim(),
          occupation: _occupationController.text.trim(),
        );

        final userId = (response['userId'] ?? '').toString();
        if (userId.isNotEmpty) {
          await prefs.setString('cached_userId', userId);
        }

        // Capture text values before async gap
        final email = _emailController.text.trim();

        if (!mounted) return;
        setState(() => _isLoading = false);

        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => OtpScreen(
              phoneNumber: email,
              userId: userId,
            ),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              const begin = Offset(1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.fastOutSlowIn;
              var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              return SlideTransition(position: animation.drive(tween), child: child);
            },
            transitionDuration: const Duration(milliseconds: 220),
          ),
        );
      } catch (e) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
      }
    }
  }

  void _handleVerifyByNumber() async {
    if (_formKey.currentState!.validate()) {
      if (_isLoading) return;
      setState(() => _isLoading = true);
      try {
        if (_profileImagePath != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('cached_profilePhotoPath', _profileImagePath!);
        }

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('cached_fullName', _fullNameController.text.trim());
        await prefs.setString('cached_email', _emailController.text.trim());
        await prefs.setString('cached_mobile', _mobileController.text.trim());
        await prefs.setString('cached_occupation', _occupationController.text.trim());

        final response = await AuthApiService.signup(
          fullName: _fullNameController.text.trim(),
          number: _mobileController.text.trim(),
          email: _emailController.text.trim(),
          occupation: _occupationController.text.trim(),
        );

        final userId = (response['userId'] ?? '').toString();
        if (userId.isNotEmpty) {
          await prefs.setString('cached_userId', userId);
        }

        // Capture text values before async gap
        final mobile = _mobileController.text.trim();

        if (!mounted) return;
        setState(() => _isLoading = false);

        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => OtpScreen(
              phoneNumber: mobile,
              userId: userId,
            ),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              const begin = Offset(1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.fastOutSlowIn;
              var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              return SlideTransition(position: animation.drive(tween), child: child);
            },
            transitionDuration: const Duration(milliseconds: 220),
          ),
        );
      } catch (e) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
      }
    }
  }

  void _navigateToLogin() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                  child: _buildHeader(context),
                ),
                const SizedBox(height: 14),
                Divider(color: Theme.of(context).colorScheme.outline, thickness: 1, height: 1),

                // ── PROGRESS BAR ──
                _buildProgressBar(),

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
                              color: Theme.of(context).colorScheme.onSurface,
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
                      const SizedBox(height: 28),

                      // ── TITLE & SUBTITLE ──
                      Text(
                        'Create Your Account',
                        style: GoogleFonts.inter(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Join the marketplace and find properties that match your needs.',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          height: 1.55,
                        ),
                      ),
                      const SizedBox(height: 28),

                      // ── FULL NAME ──
                      _buildLabel('Full Name', Theme.of(context).colorScheme.onSurface),
                      const SizedBox(height: 8),
                      _buildFullNameField(),
                      const SizedBox(height: 20),

                      // ── MOBILE NUMBER ──
                      _buildLabel('Mobile Number', Theme.of(context).colorScheme.onSurface),
                      const SizedBox(height: 8),
                      _buildMobileField(),
                      const SizedBox(height: 20),

                      // ── EMAIL ADDRESS ──
                      _buildLabel('Email Address', Theme.of(context).colorScheme.onSurface),
                      const SizedBox(height: 8),
                      _buildEmailField(),
                      const SizedBox(height: 20),

                      // ── OCCUPATION ──
                      _buildLabel('Occupation', Theme.of(context).colorScheme.onSurface),
                      const SizedBox(height: 8),
                      _buildOccupationField(),
                      const SizedBox(height: 32),

                      // ── VERIFY BUTTONS ──
                      _buildVerifyButtons(),
                      const SizedBox(height: 28),

                      // ── LOGIN LINK ──
                      _buildLoginRow(),
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

  // ── Header: back arrow + globe image + Meco brand ──
  Widget _buildHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Back arrow
        GestureDetector(
          onTap: _navigateToLogin,
          child: Icon(Icons.arrow_back, size: 22, color: Theme.of(context).colorScheme.onSurface),
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
                color: Theme.of(context).colorScheme.onSurface,
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
    );
  }

  // ── Progress Bar ──
  Widget _buildProgressBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Container(
        height: 5,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(3),
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: 0.18,
            child: Container(
              decoration: BoxDecoration(
                color: accentBlue,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ),
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
    String? hintText,
    TextStyle? hintStyle,
  }) {
    return InputDecoration(
      filled: true,
      fillColor: fill,
      hintText: hintText,
      hintStyle: hintStyle,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
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

  Widget _buildFullNameField() {
    return TextFormField(
      controller: _fullNameController,
      keyboardType: TextInputType.name,
      textCapitalization: TextCapitalization.words,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      style: GoogleFonts.inter(fontSize: 15, color: Theme.of(context).colorScheme.onSurface),
      decoration: _fieldDecoration(
        fill: Theme.of(context).colorScheme.surface,
        border: Theme.of(context).colorScheme.outline,
        hintText: 'Arjun Malhotra',
        hintStyle: GoogleFonts.inter(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 15),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter your full name.';
        }
        if (value.trim().length < 2) {
          return 'Name is too short.';
        }
        return null;
      },
    );
  }

  Widget _buildMobileField() {
    return TextFormField(
      controller: _mobileController,
      keyboardType: TextInputType.phone,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      style: GoogleFonts.inter(fontSize: 15, color: Theme.of(context).colorScheme.onSurface),
      decoration: _fieldDecoration(
        fill: Theme.of(context).colorScheme.surface,
        border: Theme.of(context).colorScheme.outline,
        hintText: '+91 98765 43210',
        hintStyle: GoogleFonts.inter(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 15),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter your mobile number.';
        }
        final digits = value.replaceAll(RegExp(r'\D'), '');
        if (digits.length < 10) {
          return 'Please enter a valid mobile number.';
        }
        return null;
      },
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      style: GoogleFonts.inter(fontSize: 15, color: Theme.of(context).colorScheme.onSurface),
      decoration: _fieldDecoration(
        fill: Theme.of(context).colorScheme.surface,
        border: Theme.of(context).colorScheme.outline,
        hintText: 'arjun.malhotra@gmail.com',
        hintStyle: GoogleFonts.inter(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 15),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter your email address.';
        }
        final emailRegex = RegExp(r'^[\w.+-]+@[\w-]+\.[a-zA-Z]{2,}$');
        if (!emailRegex.hasMatch(value.trim())) {
          return 'Please enter a valid email address.';
        }
        return null;
      },
    );
  }

  Widget _buildOccupationField() {
    return TextFormField(
      controller: _occupationController,
      keyboardType: TextInputType.text,
      textCapitalization: TextCapitalization.words,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      style: GoogleFonts.inter(fontSize: 15, color: Theme.of(context).colorScheme.onSurface),
      decoration: _fieldDecoration(
        fill: Theme.of(context).colorScheme.surface,
        border: Theme.of(context).colorScheme.outline,
        hintText: 'Real Estate Agent, Buyer, etc.',
        hintStyle: GoogleFonts.inter(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 15),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter your occupation.';
        }
        return null;
      },
    );
  }

  Widget _buildVerifyButtons() {
    return Column(
      children: [
        // Verify through Email
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : _handleVerifyByEmail,
            icon: const Icon(Icons.email_outlined, size: 20),
            label: Text(
              'Verify through Email',
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: accentBlue,
              disabledBackgroundColor: accentBlue.withAlpha(153),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        // Verify through Number
        SizedBox(
          width: double.infinity,
          height: 54,
          child: OutlinedButton.icon(
            onPressed: _isLoading ? null : _handleVerifyByNumber,
            icon: Icon(Icons.phone_outlined, size: 20, color: accentBlue),
            label: Text(
              'Verify through Number',
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: accentBlue,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: accentBlue, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ),
        if (_isLoading) ...[
          const SizedBox(height: 16),
          const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              color: accentBlue,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLoginRow() {
    return Center(
      child: RichText(
        text: TextSpan(
          style: GoogleFonts.inter(fontSize: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
          children: [
            const TextSpan(text: 'Already have an account? '),
            TextSpan(
              text: 'Login',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                color: accentBlue,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = _navigateToLogin,
            ),
          ],
        ),
      ),
    );
  }
}
