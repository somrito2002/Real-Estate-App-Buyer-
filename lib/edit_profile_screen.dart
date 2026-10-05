import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'change_password_screen.dart';
import 'services/auth_api_service.dart';
import 'models/user_profile.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  
  bool _isLoading = true;
  bool _isUploading = false;
  UserProfile? _userProfile;

  bool _isResidentialSelected = true;
  bool _isVillasSelected = true;
  bool _isCommercialSelected = false;
  bool _receiveWhatsapp = true;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    try {
      final profile = await AuthApiService.getUserProfile();
      if (!mounted) return;
      setState(() {
        _userProfile = profile;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load profile: ${e.toString().replaceAll('Exception: ', '')}')),
      );
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source, imageQuality: 70);
    if (pickedFile != null) {
      setState(() {
        _isUploading = true;
      });

      try {
        final response = await AuthApiService.uploadProfilePicture(pickedFile.path);
        if (!mounted) return;
        
        setState(() {
          _imageFile = File(pickedFile.path);
          _isUploading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message']?.toString() ?? 'Profile picture updated.'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _isUploading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt, color: Theme.of(context).colorScheme.primary),
                title: Text('Camera', style: GoogleFonts.inter()),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library, color: Theme.of(context).colorScheme.primary),
                title: Text('Media/Gallery', style: GoogleFonts.inter()),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final profilePicUrl = _userProfile?.profilePictureUrl(AuthApiService.backendBaseUrl);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Edit Profile',
          style: GoogleFonts.inter(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              'Save',
              style: GoogleFonts.inter(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                          backgroundImage: _imageFile != null
                              ? FileImage(_imageFile!) as ImageProvider
                              : (profilePicUrl != null ? NetworkImage(profilePicUrl) : null),
                          onBackgroundImageError: profilePicUrl != null ? (_, __) {} : null,
                          child: _imageFile == null && profilePicUrl == null
                              ? Text(
                                  _userProfile?.fullName.isNotEmpty == true
                                      ? _userProfile!.fullName[0].toUpperCase()
                                      : 'U',
                                  style: GoogleFonts.inter(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                                )
                              : null,
                        ),
                        if (_isUploading)
                          const Positioned.fill(
                            child: CircularProgressIndicator(),
                          ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _isUploading ? null : _showImagePickerOptions,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                shape: BoxShape.circle,
                                border: Border.all(color: Theme.of(context).colorScheme.surface, width: 2),
                              ),
                              child: Icon(
                                Icons.camera_alt,
                                color: Theme.of(context).colorScheme.surface,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildLabel('Full Name'),
                  _buildTextField(initialValue: _userProfile?.fullName ?? ''),
                  const SizedBox(height: 16),
                  _buildLabel('Email Address'),
                  _buildTextField(
                    initialValue: _userProfile?.email ?? '',
                    readOnly: true,
                    suffixIcon: const Icon(Icons.verified, color: Color(0xFF0F9D58), size: 18),
                  ),
                  const SizedBox(height: 16),
                  _buildLabel('Phone Number'),
                  _buildTextField(initialValue: _userProfile?.number ?? ''),
                  const SizedBox(height: 16),
                  _buildLabel('Current City'),
                  _buildDropdownField(initialValue: 'Gurgaon, Haryana'),
                  const SizedBox(height: 16),
                  _buildLabel('Short Bio'),
                  _buildTextField(
                    initialValue: 'Looking for premium residential flats and independent builder floors in Gurgaon or South Delhi. Prefer ready to move.',
                    maxLines: 4,
                  ),
                  const SizedBox(height: 32),
            Text(
              'Search & Property Preferences',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            _buildLabel('Preferred Locations'),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).colorScheme.outline),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _buildChip('Gurgaon'),
                  const SizedBox(width: 8),
                  _buildChip('Bangalore'),
                  Text(
                    '+ Add more...',
                    style: GoogleFonts.inter(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildLabel('Budget Range (INR)'),
            _buildTextField(initialValue: '₹2.00 Cr - ₹5.00 Cr'),
            const SizedBox(height: 16),
            _buildLabel('Interested Property Types'),
            _buildCheckbox(
              title: 'Residential Apartments',
              value: _isResidentialSelected,
              onChanged: (val) => setState(() => _isResidentialSelected = val!),
            ),
            _buildCheckbox(
              title: 'Villas & Independent Houses',
              value: _isVillasSelected,
              onChanged: (val) => setState(() => _isVillasSelected = val!),
            ),
            _buildCheckbox(
              title: 'Commercial Office Spaces',
              value: _isCommercialSelected,
              onChanged: (val) => setState(() => _isCommercialSelected = val!),
            ),
            const SizedBox(height: 24),
            _buildLabel('Communication Channels'),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Receive Whatsapp updates from support',
                    style: GoogleFonts.inter(fontSize: 14, color: Theme.of(context).colorScheme.onSurface),
                  ),
                ),
                Switch(
                  value: _receiveWhatsapp,
                  activeThumbColor: Theme.of(context).colorScheme.primary,
                  onChanged: (val) => setState(() => _receiveWhatsapp = val),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Divider(color: Theme.of(context).colorScheme.surfaceContainerHighest),
            const SizedBox(height: 8),
            InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ChangePasswordScreen()));
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Change Security Password',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Icon(Icons.arrow_forward, color: Theme.of(context).colorScheme.primary, size: 16),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String initialValue,
    int maxLines = 1,
    bool readOnly = false,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      initialValue: initialValue,
      maxLines: maxLines,
      readOnly: readOnly,
      style: GoogleFonts.inter(
        fontSize: 14,
        color: readOnly ? Theme.of(context).colorScheme.onSurfaceVariant : Theme.of(context).colorScheme.onSurface,
      ),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        filled: readOnly,
        fillColor: readOnly ? Theme.of(context).colorScheme.surfaceContainerHighest : Theme.of(context).colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
        ),
        suffixIcon: suffixIcon,
      ),
    );
  }

  Widget _buildDropdownField({required String initialValue}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outline),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: initialValue,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down, color: Theme.of(context).colorScheme.onSurfaceVariant),
          style: GoogleFonts.inter(
            fontSize: 14,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          items: [initialValue].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (_) {},
        ),
      ),
    );
  }

  Widget _buildChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 12,
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildCheckbox({
    required String title,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return Row(
      children: [
        SizedBox(
          height: 32,
          width: 24,
          child: Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: Theme.of(context).colorScheme.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            side: BorderSide(color: Theme.of(context).colorScheme.outline),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
