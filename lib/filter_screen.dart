import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'models/property_filters.dart';
import 'location_bottom_sheet.dart';

class FilterScreen extends StatefulWidget {
  final PropertyFilters? initialFilters;

  const FilterScreen({super.key, this.initialFilters});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  String? _purpose;
  String? _category;
  String? _type;
  RangeValues _budgetRange = const RangeValues(0, 100000000);
  String? _bedrooms;
  
  final List<String> _purposes = ['Sell', 'Rent', 'Lease'];
  final List<String> _categories = ['Residential', 'Commercial'];
  
  final List<String> _residentialTypes = ['Apartment', 'Villa', 'Independent House', 'Plot'];
  final List<String> _commercialTypes = ['Office Space', 'Shop & Retail', 'Warehouse / Godown'];

  static const Color accentBlue = Color(0xFF4B85F0);

  @override
  void initState() {
    super.initState();
    if (widget.initialFilters != null) {
      _purpose = widget.initialFilters!.purpose;
      _category = widget.initialFilters!.category;
      _type = widget.initialFilters!.type;
      _bedrooms = widget.initialFilters!.bedrooms;
      double minP = widget.initialFilters!.minPrice ?? 0;
      double maxP = widget.initialFilters!.maxPrice ?? 100000000;
      _budgetRange = RangeValues(minP, maxP);
    } else {
      _purpose = 'Sell';
      _category = 'Residential';
    }
  }

  void _clearAll() {
    setState(() {
      _purpose = 'Sell';
      _category = 'Residential';
      _type = null;
      _budgetRange = const RangeValues(0, 100000000);
      _bedrooms = null;
    });
  }

  String _formatBudget(double value) {
    if (value >= 10000000) {
      double cr = value / 10000000;
      return '?${cr == cr.truncateToDouble() ? cr.toInt() : cr.toStringAsFixed(1)} Cr';
    } else if (value >= 100000) {
      double l = value / 100000;
      return '?${l == l.truncateToDouble() ? l.toInt() : l.toStringAsFixed(1)} L';
    } else {
      return '?${value.toInt()}';
    }
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

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
    );
  }
  
  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Divider(color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5), height: 1),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<String> currentTypes = _category == 'Commercial' ? _commercialTypes : _residentialTypes;

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
                  _buildSectionHeader('Purpose'),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 12,
                    children: _purposes.map((p) => _buildPillChip(
                      p, _purpose == p, () => setState(() => _purpose = p)
                    )).toList(),
                  ),
                  _buildDivider(),
                  
                  _buildSectionHeader('Category'),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 12,
                    children: _categories.map((c) => _buildPillChip(
                      c, _category == c, () => setState(() {
                        _category = c;
                        if (!currentTypes.contains(_type)) {
                          _type = null;
                        }
                      })
                    )).toList(),
                  ),
                  _buildDivider(),

                  _buildSectionHeader('Property Type'),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 12,
                    children: currentTypes.map((t) => _buildPillChip(
                      t, _type == t, () => setState(() => _type = t)
                    )).toList(),
                  ),
                  _buildDivider(),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSectionHeader('Budget (INR)'),
                      Text(
                        '${_formatBudget(_budgetRange.start)} - ${_formatBudget(_budgetRange.end)}',
                        style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: accentBlue),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 2.0,
                      rangeThumbShape: const RoundRangeSliderThumbShape(enabledThumbRadius: 8.0),
                      overlayShape: const RoundSliderOverlayShape(overlayRadius: 16.0),
                    ),
                    child: RangeSlider(
                      values: _budgetRange,
                      min: 0,
                      max: 100000000,
                      activeColor: accentBlue,
                      inactiveColor: Theme.of(context).colorScheme.outlineVariant,
                      onChanged: (values) {
                        setState(() {
                          _budgetRange = values;
                        });
                      },
                    ),
                  ),
                  _buildDivider(),

                  _buildSectionHeader('Bedrooms'),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['1', '2', '3', '4+'].map((e) => _buildSelectionCircle(
                        e, _bedrooms == e, () => setState(() => _bedrooms = _bedrooms == e ? null : e),
                      )).toList(),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                border: Border(
                  top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5)),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    final filters = PropertyFilters(
                      purpose: _purpose,
                      category: _category,
                      type: _type,
                      bedrooms: _bedrooms,
                      minPrice: _budgetRange.start > 0 ? _budgetRange.start : null,
                      maxPrice: _budgetRange.end < 100000000 ? _budgetRange.end : null,
                    );
                    Navigator.pop(context, filters);
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
          ),
        ],
      ),
    );
  }
}
