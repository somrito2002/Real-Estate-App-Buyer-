import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'support_request_success_screen.dart';
class CreateSupportRequestScreen extends StatefulWidget {
  const CreateSupportRequestScreen({super.key});

  @override
  State<CreateSupportRequestScreen> createState() => _CreateSupportRequestScreenState();
}

class _CreateSupportRequestScreenState extends State<CreateSupportRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedCategory;
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  PlatformFile? _attachment;

  final List<String> _categories = [
    'Account Issue',
    'Payment Problem',
    'Property Listing',
    'Technical Support',
    'Other'
  ];

  @override
  void dispose() {
    _subjectController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickAttachment() async {
    try {
      PlatformFile? file = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: ['png', 'jpg', 'jpeg', 'pdf'],
      );

      if (file != null) {
        final fileSize = file.lengthSync() ?? 0; // in bytes
        final int maxSize = 5 * 1024 * 1024; // 5 MB

        if (fileSize > maxSize) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('File size must be less than 5 MB')),
            );
          }
          return;
        }

        setState(() {
          _attachment = file;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick file: $e')),
        );
      }
    }
  }

  void _submitRequest() {
    if (_formKey.currentState!.validate()) {
      // Process data (API call, etc.)
      
      // Navigate to success screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SupportRequestSuccessScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Create Support Request',
          style: GoogleFonts.inter(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Category', isRequired: true),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedCategory,
                        hint: Text(
                          'Select category',
                          style: GoogleFonts.inter(color: Colors.grey.shade400, fontSize: 14),
                        ),
                        items: _categories.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(
                              category,
                              style: GoogleFonts.inter(fontSize: 14, color: Colors.black87),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value;
                          });
                        },
                        validator: (value) => value == null ? 'Please select a category' : null,
                        decoration: _inputDecoration(),
                        icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      _buildLabel('Subject', isRequired: true),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _subjectController,
                        decoration: _inputDecoration(hint: 'Brief summary of the issue...'),
                        validator: (value) => value == null || value.trim().isEmpty ? 'Please enter a subject' : null,
                      ),
                      
                      const SizedBox(height: 24),
                      
                      _buildLabel('Description', isRequired: true),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 5,
                        decoration: _inputDecoration(hint: 'Please provide as much detail as possible...'),
                        validator: (value) => value == null || value.trim().isEmpty ? 'Please enter a description' : null,
                      ),
                      
                      const SizedBox(height: 24),
                      
                      _buildLabel('Attachment (optional)'),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: _pickAttachment,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.grey.shade300,
                              style: BorderStyle.solid, // Using solid as dotted border needs extra package or custom paint
                              width: 1,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _attachment != null ? Icons.insert_drive_file_outlined : Icons.description_outlined,
                                color: const Color(0xFF4A85F6),
                                size: 32,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _attachment != null ? _attachment!.name : 'Tap to attach a file',
                                style: GoogleFonts.inter(
                                  color: const Color(0xFF4A85F6),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 4),
                              if (_attachment == null)
                                Text(
                                  'PNG, JPG, PDF up to 5MB',
                                  style: GoogleFonts.inter(
                                    color: Colors.grey.shade500,
                                    fontSize: 12,
                                  ),
                                ),
                              if (_attachment != null)
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _attachment = null;
                                    });
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      'Remove',
                                      style: GoogleFonts.inter(
                                        color: Colors.red,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _submitRequest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A85F6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Submit Request',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text, {bool isRequired = false}) {
    return Row(
      children: [
        Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A1D1E),
          ),
        ),
        if (isRequired)
          Text(
            ' *',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.red,
            ),
          ),
      ],
    );
  }

  InputDecoration _inputDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(color: Colors.grey.shade400, fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF4A85F6), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
    );
  }
}
