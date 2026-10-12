import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'property_details_loader.dart';

import 'services/enquiry_api_service.dart';
import 'models/enquiry_model.dart';
import 'models/property_model.dart';
import 'services/property_api_service.dart';

import 'login_screen.dart';

class MyEnquiriesScreen extends StatefulWidget {
  const MyEnquiriesScreen({super.key});

  @override
  State<MyEnquiriesScreen> createState() => _MyEnquiriesScreenState();
}

class _MyEnquiriesScreenState extends State<MyEnquiriesScreen> {
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Pending', 'Responded', 'Closed'];

  List<Enquiry> _enquiries = [];
  Map<String, String> _propertyImages = {};
bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchEnquiries();
  }

  Future<void> _fetchEnquiries() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final fetched = await EnquiryApiService.getEnquiries(
        userId: null, // Let backend rely purely on the Auth token
        partnerId: null, // Strictly fetch as user, not as partner
      );

      final propertyFutures = fetched.map((e) {
        if (e.property?.id != null && e.property!.id.isNotEmpty) {
          return PropertyApiService.getPropertyById(e.property!.id).catchError((_) => null as dynamic);
        }
        return Future.value(null);
      });
      final propertiesList = await Future.wait(propertyFutures);
      
      final Map<String, String> loadedImages = {};
      for (int i = 0; i < fetched.length; i++) {
        final propId = fetched[i].property?.id;
        final Property? propDetails = propertiesList[i];
        if (propId != null && propDetails != null && propDetails.imageUrl.isNotEmpty) {
          loadedImages[propId] = propDetails.imageUrl;
        }
      }

      if (mounted) {
        setState(() {
          _enquiries = fetched;
          _propertyImages = loadedImages;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        String msg = e.toString();
        if (msg.contains('401')) {
          _handleLogout();
          return;
        } else if (msg.contains('403')) {
          msg = 'You are not authorized to view these enquiries.';
        } else if (msg.contains('SocketException') || msg.contains('HttpException')) {
          msg = 'Unable to connect to the server. Please check your internet connection and try again.';
        } else if (msg.contains(':')) {
          msg = msg.split(':').last;
        }

        setState(() {
          _errorMessage = msg;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('cached_userId');
    await prefs.remove('cached_partnerId');

    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color accentBlue = Color(0xFF4B85F0);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'My Enquiries',
          style: GoogleFonts.inter(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: Theme.of(context).colorScheme.onSurface),
            onPressed: () {},
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Theme.of(context).colorScheme.outlineVariant, height: 1),
        ),
      ),
      body: Column(
        children: [
          // Filters
          Container(
            color: Theme.of(context).colorScheme.surface,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _filters.map((filter) {
                  final isSelected = _selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(
                        filter,
                        style: GoogleFonts.inter(
                          color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 14,
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedFilter = filter;
                          });
                        }
                      },
                      selectedColor: accentBlue,
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      side: BorderSide(
                        color: isSelected ? accentBlue : Theme.of(context).colorScheme.outlineVariant,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      showCheckmark: false,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          
          // List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _errorMessage!,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(
                                  color: Theme.of(context).colorScheme.error,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _fetchEnquiries,
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : _enquiries.isEmpty
                        ? Center(
                            child: Text(
                              'No enquiries found.',
                              style: GoogleFonts.inter(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                                fontSize: 16,
                              ),
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _fetchEnquiries,
                            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _enquiries.length,
              itemBuilder: (context, index) {
                final enquiry = _enquiries[index];
                
                // Filtering logic
                final statusFilter = _selectedFilter.toUpperCase();
                if (statusFilter != 'ALL' && enquiry.status.toUpperCase() != statusFilter) {
                  return const SizedBox.shrink();
                }

                Color statusColor;
                Color statusBgColor;
                if (enquiry.status.toUpperCase() == 'PENDING' || enquiry.status.toUpperCase() == 'NEW') {
                  statusColor = Colors.orange;
                  statusBgColor = Colors.orange.withValues(alpha: 0.15);
                } else if (enquiry.status.toUpperCase() == 'RESPONDED') {
                  statusColor = Colors.green;
                  statusBgColor = Colors.green.withValues(alpha: 0.15);
                } else {
                  statusColor = Theme.of(context).colorScheme.onSurfaceVariant;
                  statusBgColor = Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.15);
                }
                
                final String propId = enquiry.property?.id ?? '';
                final imageUrl = _propertyImages.containsKey(propId) 
                    ? _propertyImages[propId]! 
                    : 'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?auto=format&fit=crop&q=80&w=200';
                final title = enquiry.property?.title ?? 'Unknown Property';
                final dateStr = enquiry.createdAt.isNotEmpty ? enquiry.createdAt : 'Unknown Date';
                final displayStatus = enquiry.status.isNotEmpty ? enquiry.status : 'NEW';

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Image
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                imageUrl,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => Container(
                                  width: 50,
                                  height: 50,
                                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                  child: Icon(Icons.home, color: Theme.of(context).colorScheme.onSurfaceVariant),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: Theme.of(context).colorScheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Sent: $dateStr',
                                    style: GoogleFonts.inter(
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: statusBgColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                displayStatus,
                                style: GoogleFonts.inter(
                                  color: statusColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          enquiry.message,
                          style: GoogleFonts.inter(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            height: 1.5,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Divider(height: 1),
                      InkWell(
                        onTap: () {
                          if (enquiry.property != null && enquiry.property!.id.isNotEmpty) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PropertyDetailsLoader(
                                  propertyId: enquiry.property!.id,
                                ),
                              ),
                            ).then((_) {
                              _fetchEnquiries();
                            });
                          }
                        },
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Text(
                                'View Property',
                                style: GoogleFonts.inter(
                                  color: accentBlue,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.arrow_forward, size: 16, color: accentBlue),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
                          ),
          ),
        ],
      ),
    );
  }
}
