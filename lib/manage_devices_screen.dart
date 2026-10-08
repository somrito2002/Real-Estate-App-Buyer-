import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'services/auth_api_service.dart';

class ManageDevicesScreen extends StatefulWidget {
  const ManageDevicesScreen({super.key});

  @override
  State<ManageDevicesScreen> createState() => _ManageDevicesScreenState();
}

class _ManageDevicesScreenState extends State<ManageDevicesScreen> {
  bool _isLoading = true;
  List<dynamic> _sessions = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchSessions();
  }

  Future<void> _fetchSessions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final sessions = await AuthApiService.getSessions();
      if (!mounted) return;
      setState(() {
        _sessions = sessions;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _logoutDevice(String sessionId) async {
    try {
      // Optimistic UI update could go here, or show loading overlay
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );
      
      await AuthApiService.logoutDevice(sessionId);
      
      if (!mounted) return;
      Navigator.of(context).pop(); // remove loading
      _fetchSessions(); // refresh list
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Device logged out successfully')),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop(); // remove loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    }
  }

  Future<void> _logoutAllOtherDevices() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );
      
      await AuthApiService.logoutAllOtherDevices();
      
      if (!mounted) return;
      Navigator.of(context).pop(); // remove loading
      _fetchSessions(); // refresh list
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logged out of all other devices')),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop(); // remove loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    }
  }

  String _formatDate(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return 'Unknown';
    try {
      final date = DateTime.parse(isoDate).toLocal();
      return DateFormat('MMM dd, yyyy • hh:mm a').format(date);
    } catch (_) {
      return isoDate;
    }
  }

  String _getDeviceName(Map<String, dynamic> session) {
    final name = session['name']?.toString() ?? '';
    final deviceName = session['deviceName']?.toString() ?? '';
    final device = session['device']?.toString() ?? '';
    final model = session['model']?.toString() ?? '';
    final brand = session['brand']?.toString() ?? '';

    if (name.isNotEmpty) return name;
    if (deviceName.isNotEmpty) return deviceName;
    
    if (brand.isNotEmpty && model.isNotEmpty) return '$brand $model';
    if (device.isNotEmpty) return device;
    if (model.isNotEmpty) return model;
    
    final os = session['os']?.toString() ?? '';
    if (os.isNotEmpty) return '$os Device';

    // Temporary debug: Print out the available keys in the UI
    final keys = session.keys.join(', ');
    return 'Unknown (Keys: $keys)';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFFAFAFA);
    final cardBgColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final borderColor = isDark ? Colors.white12 : const Color(0xFFEEEEEE);
    final titleColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final subtitleColor = isDark ? Colors.white70 : const Color(0xFF666666);
    final sectionTitleColor = isDark ? Colors.white54 : const Color(0xFF7B8794);
    final iconBgColor = isDark ? const Color(0xFF1A2A4A) : const Color(0xFFF0F5FF);
    final accentBlue = const Color(0xFF4B85F0);

    Map<String, dynamic>? currentSession;
    List<Map<String, dynamic>> otherSessions = [];

    if (!_isLoading && _errorMessage == null) {
      for (var s in _sessions) {
        if (s is Map<String, dynamic>) {
          if (s['isCurrent'] == true) {
            currentSession = s;
          } else {
            otherSessions.add(s);
          }
        }
      }
    }

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
          'devices.title'.tr(),
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: titleColor,
          ),
        ),
        centerTitle: false,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : _errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_errorMessage!, style: TextStyle(color: Colors.red)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _fetchSessions,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _fetchSessions,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'devices.desc'.tr(),
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: subtitleColor,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    if (currentSession != null) ...[
                      // THIS DEVICE Section
                      Text(
                        'devices.this_device'.tr(),
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: sectionTitleColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildDeviceCard(
                        context: context,
                        sessionId: currentSession['id'] ?? '',
                        deviceName: _getDeviceName(currentSession),
                        os: currentSession['os']?.toString() ?? '',
                        browser: currentSession['browser']?.toString() ?? '',
                        clientType: currentSession['clientType']?.toString() ?? '',
                        lastUsed: _formatDate(currentSession['time']),
                        location: currentSession['location']?.toString() ?? 'Unknown',
                        registered: _formatDate(currentSession['reg']),
                        icon: currentSession['type'] == 'mobile' ? Icons.smartphone : Icons.language,
                        isCurrentDevice: true,
                        cardBgColor: cardBgColor,
                        borderColor: borderColor,
                        titleColor: titleColor,
                        subtitleColor: subtitleColor,
                        iconBgColor: iconBgColor,
                        accentBlue: accentBlue,
                      ),
                      const SizedBox(height: 24),
                    ],
                    
                    if (otherSessions.isNotEmpty) ...[
                      // OTHER DEVICES Section
                      Text(
                        'devices.other_devices'.tr(),
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: sectionTitleColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...otherSessions.map((session) => Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: _buildDeviceCard(
                          context: context,
                          sessionId: session['id'] ?? '',
                          deviceName: _getDeviceName(session),
                          os: session['os']?.toString() ?? '',
                          browser: session['browser']?.toString() ?? '',
                          clientType: session['clientType']?.toString() ?? '',
                          lastUsed: _formatDate(session['time']),
                          location: session['location']?.toString() ?? 'Unknown',
                          registered: _formatDate(session['reg']),
                          icon: session['type'] == 'mobile' ? Icons.smartphone : Icons.language,
                          isCurrentDevice: false,
                          cardBgColor: cardBgColor,
                          borderColor: borderColor,
                          titleColor: titleColor,
                          subtitleColor: subtitleColor,
                          iconBgColor: iconBgColor,
                          accentBlue: accentBlue,
                        ),
                      )),
                      
                      const SizedBox(height: 32),
                      
                      // Logout from all button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton(
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                backgroundColor: cardBgColor,
                                title: Text('Log out of all other devices?', style: GoogleFonts.inter(color: titleColor, fontWeight: FontWeight.bold)),
                                content: Text('You will be logged out of all devices except this one.', style: GoogleFonts.inter(color: subtitleColor)),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(ctx).pop(false),
                                    child: Text('Cancel', style: GoogleFonts.inter(color: subtitleColor)),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.of(ctx).pop(true),
                                    child: Text('Log out', style: GoogleFonts.inter(color: Colors.red)),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true) {
                              _logoutAllOtherDevices();
                            }
                          },
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.red.withValues(alpha: 0.05),
                            side: BorderSide(color: Colors.red.withValues(alpha: 0.5)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'devices.logout_all'.tr(),
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildDeviceCard({
    required BuildContext context,
    required String sessionId,
    required String deviceName,
    required String os,
    required String browser,
    required String clientType,
    required String lastUsed,
    required String location,
    required String registered,
    required IconData icon,
    required bool isCurrentDevice,
    required Color cardBgColor,
    required Color borderColor,
    required Color titleColor,
    required Color subtitleColor,
    required Color iconBgColor,
    required Color accentBlue,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: accentBlue, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              deviceName,
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: titleColor,
                              ),
                            ),
                          ),
                          if (!isCurrentDevice)
                            GestureDetector(
                              onTap: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    backgroundColor: cardBgColor,
                                    title: Text('Log out of this device?', style: GoogleFonts.inter(color: titleColor, fontWeight: FontWeight.bold)),
                                    content: Text('Are you sure you want to log out of $deviceName?', style: GoogleFonts.inter(color: subtitleColor)),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(ctx).pop(false),
                                        child: Text('Cancel', style: GoogleFonts.inter(color: subtitleColor)),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.of(ctx).pop(true),
                                        child: Text('Log out', style: GoogleFonts.inter(color: Colors.red)),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirm == true) {
                                  _logoutDevice(sessionId);
                                }
                              },
                              child: Text(
                                'devices.log_out'.tr(),
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: accentBlue,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      if (os.isNotEmpty || browser.isNotEmpty)
                        Text(
                          [os, browser].where((e) => e.isNotEmpty).join(' • '),
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: subtitleColor,
                          ),
                        ),
                      if (clientType.isNotEmpty)
                        Text(
                          'Client: $clientType',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: subtitleColor,
                          ),
                        ),
                      const SizedBox(height: 4),
                      Text(
                        'devices.last_used'.tr(namedArgs: {'time': lastUsed}),
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: subtitleColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        location,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: subtitleColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, thickness: 1, color: borderColor, indent: 16, endIndent: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'devices.registered_on'.tr(namedArgs: {'time': registered}),
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: subtitleColor,
                    ),
                  ),
                ),
                if (isCurrentDevice)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6F4EA),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'CURRENT DEVICE',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E8E3E),
                      ),
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
