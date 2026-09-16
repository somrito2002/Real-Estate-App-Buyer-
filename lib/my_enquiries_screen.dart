import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'follow_up_screen.dart';

class MyEnquiriesScreen extends StatefulWidget {
  const MyEnquiriesScreen({super.key});

  @override
  State<MyEnquiriesScreen> createState() => _MyEnquiriesScreenState();
}

class _MyEnquiriesScreenState extends State<MyEnquiriesScreen> {
  String _selectedFilter = 'All';

  final List<String> _filters = ['All', 'Pending', 'Responded', 'Closed'];

  // Mock data
  final List<Map<String, dynamic>> _enquiries = [
    {
      'imageUrl': 'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?auto=format&fit=crop&q=80&w=200',
      'title': '3 BHK Premium Apartment',
      'date': '24 Jan 2026',
      'status': 'Pending',
      'message': '"Is the listed price of ₹85 Lakh negotiable? I\'d like to schedule a site exploration call on upcoming Sunday."',
    },
    {
      'imageUrl': 'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?auto=format&fit=crop&q=80&w=200',
      'title': 'DLF Phase 3 Luxury Villa',
      'date': '20 Jan 2026',
      'status': 'Responded',
      'message': '"Hello Arjun, our partner builders confirmed that the project is completely RERA cleared. We uploaded the document copy..."',
    },
    {
      'imageUrl': 'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?auto=format&fit=crop&q=80&w=200',
      'title': 'Vasant Vihar Premium Suite',
      'date': '15 Jan 2026',
      'status': 'Closed',
      'message': '"This enquiry was resolved successfully after your offline discussion on lease terms."',
    },
  ];

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
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _enquiries.length,
              itemBuilder: (context, index) {
                final enquiry = _enquiries[index];
                
                // Filtering logic
                if (_selectedFilter != 'All' && enquiry['status'] != _selectedFilter) {
                  return const SizedBox.shrink();
                }

                Color statusColor;
                Color statusBgColor;
                if (enquiry['status'] == 'Pending') {
                  statusColor = Colors.orange;
                  statusBgColor = Colors.orange.withValues(alpha: 0.15);
                } else if (enquiry['status'] == 'Responded') {
                  statusColor = Colors.green;
                  statusBgColor = Colors.green.withValues(alpha: 0.15);
                } else {
                  statusColor = Theme.of(context).colorScheme.onSurfaceVariant;
                  statusBgColor = Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.15);
                }

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
                                enquiry['imageUrl'],
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
                                    enquiry['title'],
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: Theme.of(context).colorScheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Sent: ${enquiry['date']}',
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
                                enquiry['status'],
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
                          enquiry['message'],
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FollowUpScreen(enquiry: enquiry),
                            ),
                          );
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
                                'View Details',
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
        ],
      ),
    );
  }
}
