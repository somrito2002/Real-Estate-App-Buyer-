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
  bool _isSaving = false;
  UserProfile? _userProfile;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _occupationController = TextEditingController();
  final TextEditingController _propertyTypeController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _occupationController.dispose();
    _propertyTypeController.dispose();
    super.dispose();
  }

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
        _nameController.text = profile.fullName;
        _phoneController.text = profile.number;
        _cityController.text = profile.area ?? 'Gurgaon';
        _occupationController.text = profile.occupation ?? 'Software Engineer';
        _propertyTypeController.text = profile.propertyType ?? 'Residential';
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

  Future<void> _saveProfile() async {
    setState(() {
      _isSaving = true;
    });

    try {
      final response = await AuthApiService.updateUserProfile(
        fullName: _nameController.text.trim(),
        number: _phoneController.text.trim(),
        area: _cityController.text.trim(),
        occupation: _occupationController.text.trim(),
        propertyType: _propertyTypeController.text.trim(),
      );

      if (!mounted) return;
      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['message']?.toString() ?? 'Profile updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true); // Return true to signal success
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.redAccent,
        ),
      );
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
          _isSaving 
              ? const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
                )
              : TextButton(
                  onPressed: _saveProfile,
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
                  _buildTextField(controller: _nameController),
                  const SizedBox(height: 16),
                  _buildLabel('Phone Number'),
                  _buildTextField(controller: _phoneController),
                  const SizedBox(height: 16),
                  _buildLabel('Current City'),
                  _buildTextField(controller: _cityController),
                  const SizedBox(height: 16),
                  _buildLabel('Occupation'),
                  _buildTextField(controller: _occupationController),
                  const SizedBox(height: 16),
                  _buildLabel('Property Type'),
                  _buildTextField(controller: _propertyTypeController),
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
    TextEditingController? controller,
    int maxLines = 1,
    bool readOnly = false,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
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




}
