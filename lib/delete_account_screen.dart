import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  final TextEditingController _confirmController = TextEditingController();
  bool _isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _confirmController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _confirmController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final text = _confirmController.text.trim();
    if (text == 'DELETE') {
      if (!_isButtonEnabled) {
        setState(() {
          _isButtonEnabled = true;
        });
      }
    } else {
      if (_isButtonEnabled) {
        setState(() {
          _isButtonEnabled = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FA),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Delete Account',
          style: GoogleFonts.inter(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF1F0), // Light red background
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFFD4D1)), // Slightly darker border
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: Color(0xFFD32F2F), size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Permanent Deletion',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFD32F2F),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'This action cannot be undone. All your data will be permanently removed from MECO Real Estate.',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: const Color(0xFFD32F2F),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'What will be permanently deleted:',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1D1E),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildListItem('Profile and personal information'),
                  const SizedBox(height: 12),
                  _buildListItem('Property search history'),
                  const SizedBox(height: 12),
                  _buildListItem('Saved searches and shortlisted properties'),
                  const SizedBox(height: 12),
                  _buildListItem('All enquiry records'),
                  const SizedBox(height: 12),
                  _buildListItem('Visit history and schedules'),
                  const SizedBox(height: 12),
                  _buildListItem('Reviews and ratings'),
                  const SizedBox(height: 12),
                  _buildListItem('Payment records'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Confirm deletion:',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1D1E),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'To confirm, type DELETE in the field below:',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: TextField(
                      controller: _confirmController,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: const Color(0xFF1A1D1E),
                      ),
                      decoration: InputDecoration(
                        hintText: 'Type DELETE',
                        hintStyle: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.grey.shade400,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isButtonEnabled
                    ? () {
                        _showDeleteDialog(context);
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEA4335), // Red when active
                  disabledBackgroundColor: const Color(0xFFF3A49E), // Light red/pink when disabled
                  disabledForegroundColor: Colors.white, // Text color when disabled
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Permanently Delete Account',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Account deletion may take up to 30 days to process completely.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildListItem(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.cancel_outlined, color: Color(0xFFEA4335), size: 18),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey.shade600,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFF1F0),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    color: Color(0xFFEA4335),
                    size: 32,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Delete your account permanently?',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1D1E),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'This cannot be undone. All your data, searches, and activity will be permanently removed.',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(color: Colors.grey.shade300),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1A1D1E),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // Perform actual permanent deletion
                          Navigator.pop(context); // Close dialog
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: const Color(0xFFEA4335),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Delete Forever',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

