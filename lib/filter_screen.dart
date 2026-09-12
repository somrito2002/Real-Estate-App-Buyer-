import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'buy_properties_screen.dart';
import 'rent_properties_screen.dart';
import 'lease_properties_screen.dart';
import 'location_bottom_sheet.dart';

class FilterScreen extends StatefulWidget {
  final String initialCategory;

  const FilterScreen({super.key, this.initialCategory = 'Buy'});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  // State variables for filters
  String _propertyCategory = 'Residential';
  final Map<String, bool> _residentialProperties = {
    'Apartment / Flat': true,
    'Villa': false,
    'Independent House': false,
    'Penthouse': true,
    'Plot / Layout Land': false,
  };
  final Map<String, bool> _commercialProperties = {
    'Office Space': false,
    'Shop & Retail': false,
    'Warehouse / Godown': false,
  };

  final Map<String, String> _residentialCounts = {
    'Apartment / Flat': '2,400',
    'Villa': '340',
    'Independent House': '120',
    'Penthouse': '15',
    'Plot / Layout Land': '100',
  };

  final Map<String, String> _commercialCounts = {
    'Office Space': '450',
    'Shop & Retail': '150',
    'Warehouse / Godown': '24',
  };

  RangeValues _budgetRange = const RangeValues(5000000, 15000000); // 50L to 1.5Cr
  String _selectedBudgetChip = '';
  
  String _bedrooms = '3';
  String _bathrooms = '2';
  
  RangeValues _areaRange = const RangeValues(1000, 3500);
  
  String _furnishing = 'Furnished';
  String _parking = '1';
  
  final Map<String, bool> _amenities = {
    'Swimming Pool': false,
    'Modern Gym': false,
    'Reserved Parking': false,
    'Kids Play Area': false,
    '24/7 Security': false,
    'Clubhouse': false,
    'Power Backup': false,
    'Elevator / Lift': false,
    'Vastu Compliant': false,
    'Rainwater Harvesting': false,
  };

  String _constructionStatus = 'Ready to Move';
  String _possessionTimeline = 'Immediate';

  // Constants
  static const Color accentBlue = Color(0xFF4B85F0);

  void _clearAll() {
    setState(() {
      _propertyCategory = 'Residential';
      _residentialProperties.updateAll((key, value) => false);
      _commercialProperties.updateAll((key, value) => false);
      _budgetRange = const RangeValues(5000000, 15000000);
      _selectedBudgetChip = '';
      _bedrooms = 'Any';
      _bathrooms = 'Any';
      _areaRange = const RangeValues(1000, 3500);
      _furnishing = 'Any';
      _parking = 'Any';
      _amenities.updateAll((key, value) => false);
      _constructionStatus = 'Any';
      _possessionTimeline = 'Any';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Filters',
          style: GoogleFonts.inter(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.bold,
              fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.location_on_outlined, color: Theme.of(context).colorScheme.onSurface),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (ctx) => Padding(
                  padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
                  child: const LocationBottomSheet(),
                ),
              );
            },
          ),
          TextButton(
            onPressed: _clearAll,
            child: Text(
              'Clear All',
              style: GoogleFonts.inter(
                color: accentBlue,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5),
            height: 1,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('Property Type'),
                  const SizedBox(height: 16),
                  
                  // Property Category
                  Text('Property Category', style: _subHeaderStyle()),
                  const SizedBox(height: 8),
                  _buildRadioListTile('Residential', '2,400'),
                  _buildRadioListTile('Plots & Land', '124'),
                  _buildRadioListTile('Commercial', '345'),
                  _buildRadioListTile('Special Purpose', '42'),
                  _buildRadioListTile('Industrial', '27'),
                  _buildRadioListTile('Agricultural', '15'),
                  
                  const SizedBox(height: 16),
                  
                  // Residential Properties
                  Text('Residential Properties', style: _subHeaderStyle()),
                  const SizedBox(height: 8),
                  ..._residentialProperties.keys.map((key) => _buildCheckboxListTile(
                        key, 
                        _residentialCounts[key] ?? '',
                        _residentialProperties[key]!, 
                        (val) => setState(() => _residentialProperties[key] = val ?? false),
                      )),
                  
                  const SizedBox(height: 16),
                  
                  // Commercial Properties
                  Text('Commercial Properties', style: _subHeaderStyle(color: Theme.of(context).colorScheme.onSurface)),
                  const SizedBox(height: 8),
                  ..._commercialProperties.keys.map((key) => _buildCheckboxListTile(
                        key, 
                        _commercialCounts[key] ?? '',
                        _commercialProperties[key]!, 
                        (val) => setState(() => _commercialProperties[key] = val ?? false),
                      )),
                  
                  _buildDivider(),
                  
                  // Budget
                  _buildSectionHeader('SELECT BUDGET'),
                  const SizedBox(height: 8),
                  Text(
                    '₹50 Lakhs - ₹1.5 Crores',
                    style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: accentBlue),
                  ),
                  const SizedBox(height: 16),
                  RangeSlider(
                    values: _budgetRange,
                    min: 0,
                    max: 100000000, // 10 Cr
                    activeColor: accentBlue,
                    inactiveColor: Theme.of(context).colorScheme.outlineVariant,
                    onChanged: (values) {
                      setState(() {
                        _budgetRange = values;
                        _selectedBudgetChip = '';
                      });
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('0 L', style: _hintStyle()),
                      Text('10 Cr', style: _hintStyle()),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text('QUICK BUDGET RANGES', style: _subHeaderStyle(fontSize: 11)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 12,
                    children: [
                      _buildBudgetChip('Under ₹50L'),
                      _buildBudgetChip('₹50L - 1Cr'),
                      _buildBudgetChip('₹1 - 2Cr'),
                      _buildBudgetChip('₹2 - 5Cr'),
                      _buildBudgetChip('₹5Cr+'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: accentBlue.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Approx EMI: ₹40,000/month', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13, color: accentBlue)),
                        const SizedBox(height: 4),
                        Text('Calculated based on 8.5% p.a. for 20 years with 20% down payment.', style: GoogleFonts.inter(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  
                  _buildDivider(),
                  
                  // Bedrooms
                  _buildSectionHeader('Bedrooms'),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['Any', '1', '2', '3', '4', '5+'].map((e) => _buildSelectionCircle(
                        e, _bedrooms == e, () => setState(() => _bedrooms = e),
                      )).toList(),
                    ),
                  ),
                  
                  _buildDivider(),
                  
                  // Bathrooms
                  _buildSectionHeader('Bathrooms'),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['Any', '1', '2', '3', '4+'].map((e) => _buildSelectionCircle(
                        e, _bathrooms == e, () => setState(() => _bathrooms = e),
                      )).toList(),
                    ),
                  ),
                  
                  _buildDivider(),
                  
                  // Area
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSectionHeader('Area (sq.ft)'),
                      Text('1,000 - 3,500 sq.ft', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13, color: accentBlue)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  RangeSlider(
                    values: _areaRange,
                    min: 0,
                    max: 5000,
                    activeColor: accentBlue,
                    inactiveColor: Theme.of(context).colorScheme.outlineVariant,
                    onChanged: (values) {
                      setState(() {
                        _areaRange = values;
                      });
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('0 sq.ft', style: _hintStyle()),
                      Text('5,000 sq.ft', style: _hintStyle()),
                    ],
                  ),
                  
                  _buildDivider(),
                  
                  // Furnishing
                  _buildSectionHeader('Furnishing'),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 12,
                    children: ['Any', 'Furnished', 'Semi Furnished', 'Unfurnished'].map((e) => _buildPillChip(
                      e, _furnishing == e, () => setState(() => _furnishing = e),
                    )).toList(),
                  ),
                  
                  _buildDivider(),
                  
                  // Parking
                  _buildSectionHeader('Parking'),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['Any', '1', '2', '3+'].map((e) => _buildSelectionCircle(
                        e, _parking == e, () => setState(() => _parking = e),
                      )).toList(),
                    ),
                  ),
                  
                  _buildDivider(),
                  
                  // Amenities
                  _buildSectionHeader('Amenities'),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.5)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search, color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5), size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Search amenities...',
                              hintStyle: GoogleFonts.inter(color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5), fontSize: 13),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 12,
                    children: _amenities.keys.map((key) => _buildIconPillChip(
                      key, _amenities[key]!, () => setState(() => _amenities[key] = !_amenities[key]!),
                      _getAmenityIcon(key),
                    )).toList(),
                  ),
                  
                  _buildDivider(),
                  
                  // Construction Status
                  _buildSectionHeader('Construction Status'),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 12,
                    children: ['Under Construction', 'Ready to Move', 'Pre-Launch'].map((e) => _buildPillChip(
                      e, _constructionStatus == e, () => setState(() => _constructionStatus = e),
                    )).toList(),
                  ),
                  
                  _buildDivider(),
                  
                  // Possession Timeline
                  _buildSectionHeader('Possession Timeline'),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 12,
                    children: ['Immediate', '2024', '2025', '2026+'].map((e) => _buildPillChip(
                      e, _possessionTimeline == e, () => setState(() => _possessionTimeline = e),
                    )).toList(),
                  ),
                  
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          // Bottom sticky bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              border: Border(
                top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5)),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: OutlinedButton(
                      onPressed: _clearAll,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Theme.of(context).colorScheme.outline),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text('Reset', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface)),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        if (widget.initialCategory == 'Rent') {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const RentPropertiesScreen()),
                          );
                        } else if (widget.initialCategory == 'Lease') {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const LeasePropertiesScreen()),
                          );
                        } else {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const BuyPropertiesScreen()),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentBlue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text('Apply Filters', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
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

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
    );
  }

  TextStyle _subHeaderStyle({Color? color, double fontSize = 12}) {
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
      color: color ?? accentBlue,
      letterSpacing: 0.5,
    );
  }

  TextStyle _hintStyle() {
    return GoogleFonts.inter(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant);
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Divider(color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5), height: 1),
    );
  }

  Widget _buildRadioListTile(String title, String count) {
    final isSelected = _propertyCategory == title;
    return InkWell(
      onTap: () => setState(() => _propertyCategory = title),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isSelected ? accentBlue : Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(title, style: GoogleFonts.inter(fontSize: 14, color: Theme.of(context).colorScheme.onSurface))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                count,
                style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckboxListTile(String title, String count, bool value, ValueChanged<bool?> onChanged) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(
              value ? Icons.check_box : Icons.check_box_outline_blank,
              color: value ? accentBlue : Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(title, style: GoogleFonts.inter(fontSize: 14, color: Theme.of(context).colorScheme.onSurface))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                count,
                style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetChip(String label) {
    final isSelected = _selectedBudgetChip == label;
    return InkWell(
      onTap: () => setState(() => _selectedBudgetChip = label),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? accentBlue.withOpacity(0.1) : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? accentBlue : Theme.of(context).colorScheme.outlineVariant),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? accentBlue : Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionCircle(String label, bool isSelected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isSelected ? accentBlue.withOpacity(0.1) : Theme.of(context).colorScheme.surface,
            border: Border.all(color: isSelected ? accentBlue : Theme.of(context).colorScheme.outlineVariant),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? accentBlue : Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPillChip(String label, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? accentBlue.withOpacity(0.1) : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? accentBlue : Theme.of(context).colorScheme.outlineVariant),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? accentBlue : Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  Widget _buildIconPillChip(String label, bool isSelected, VoidCallback onTap, IconData icon) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? accentBlue.withOpacity(0.1) : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? accentBlue : Theme.of(context).colorScheme.outlineVariant),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isSelected ? accentBlue : Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? accentBlue : Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getAmenityIcon(String name) {
    switch (name) {
      case 'Swimming Pool': return Icons.pool;
      case 'Modern Gym': return Icons.fitness_center;
      case 'Reserved Parking': return Icons.directions_car;
      case 'Kids Play Area': return Icons.child_friendly;
      case '24/7 Security': return Icons.security;
      case 'Clubhouse': return Icons.home_repair_service; // placeholder
      case 'Power Backup': return Icons.bolt;
      case 'Elevator / Lift': return Icons.elevator;
      case 'Vastu Compliant': return Icons.explore; // placeholder
      case 'Rainwater Harvesting': return Icons.water_drop;
      default: return Icons.check_circle_outline;
    }
  }
}