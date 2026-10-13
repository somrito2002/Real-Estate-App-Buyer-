import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'models/property_filters.dart';
import 'location_bottom_sheet.dart';
import 'services/property_api_service.dart';

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
  
  String? _status;
  String? _constructionPhase;
  RangeValues _areaRange = const RangeValues(0, 10000);
  String? _bathrooms;
  String? _parking;
  String? _furnishing;
  List<String> _amenities = [];

  // Default limits (these will update dynamically)
  double _minBudgetBound = 0;
  double _maxBudgetBound = 100000000; 
  double _minAreaBound = 0;
  double _maxAreaBound = 10000; 
  bool _isLoadingBounds = true;

  final List<String> _purposes = ['Buy', 'Rent', 'Lease'];
  List<String> _categories = [];
  Map<String, List<String>> _typesByCategory = {};

  final List<String> _statuses = ['ACTIVE', 'SOLD', 'PAUSED', 'DRAFT'];
  final List<String> _constructionPhases = ['READY TO MOVE', 'UNDER CONSTRUCTION', 'NEW LAUNCH'];
  final List<String> _parkingOptions = ['1 Covered', '2 Covered', 'Open'];
  final List<String> _furnishingOptions = ['Fully Furnished', 'Semi-Furnished', 'Unfurnished'];
  List<String> _amenityOptions = [];
  bool _isLoadingFilterOptions = true;

  static const Color accentBlue = Color(0xFF4B85F0);

  @override
  void initState() {
    super.initState();
    if (widget.initialFilters != null) {
      _purpose = widget.initialFilters!.purpose;
      if (_purpose != null && _purpose!.toLowerCase() == 'sell') {
        _purpose = 'Buy';
      }
      _category = widget.initialFilters!.category;
      _type = widget.initialFilters!.type;
      _bedrooms = widget.initialFilters!.bedrooms;
      double minP = widget.initialFilters!.minPrice ?? 0;
      double maxP = widget.initialFilters!.maxPrice ?? 100000000;
      _budgetRange = RangeValues(minP, maxP);
      
      _status = widget.initialFilters!.status;
      _constructionPhase = widget.initialFilters!.constructionPhase;
      double minA = widget.initialFilters!.minArea ?? 0;
      double maxA = widget.initialFilters!.maxArea ?? 10000;
      _areaRange = RangeValues(minA, maxA);
      _bathrooms = widget.initialFilters!.bathrooms;
      _parking = widget.initialFilters!.parking;
      _furnishing = widget.initialFilters!.furnishing;
      _amenities = widget.initialFilters!.amenities != null ? List.from(widget.initialFilters!.amenities!) : [];
    } else {
      _purpose = null;
      _category = null;
    }
    _fetchBounds();
    _fetchFilterOptions();
  }

  Future<void> _fetchFilterOptions() async {
    try {
      final properties = await PropertyApiService.getProperties(limit: 500);
      final Set<String> uniqueCategories = {};
      final Set<String> uniqueAmenities = {};
      final Map<String, Set<String>> typesMap = {};
      
      for (var p in properties) {
        if (p.amenities.isNotEmpty) {
          uniqueAmenities.addAll(p.amenities.map((a) => a.trim()).where((a) => a.isNotEmpty));
        }
        
        String cat = p.category.trim();
        if (cat.isEmpty || cat.toLowerCase() == 'buy') cat = 'Residential'; // Fallback
        
        uniqueCategories.add(cat);
        typesMap.putIfAbsent(cat, () => {});
        
        if (p.type.isNotEmpty) {
          typesMap[cat]!.add(p.type.trim());
        }
      }
      
      if (mounted) {
        setState(() {
          if (uniqueAmenities.isNotEmpty) _amenityOptions = uniqueAmenities.toList()..sort();
          
          _categories = uniqueCategories.toList()..sort();
          _typesByCategory = {};
          for (var c in _categories) {
            _typesByCategory[c] = (typesMap[c] ?? {}).toList()..sort();
          }
          
          if (_category != null && !_categories.contains(_category)) {
            _category = null;
          }
          
          _isLoadingFilterOptions = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingFilterOptions = false);
    }
  }

  Future<void> _fetchBounds() async {
    try {
      final ranges = await PropertyApiService.getPropertyRanges();
      
      if (mounted) {
        setState(() {
          _minBudgetBound = (ranges['minPrice'] as num?)?.toDouble() ?? 0;
          _maxBudgetBound = (ranges['maxPrice'] as num?)?.toDouble() ?? 100000000;
          _minAreaBound = (ranges['minArea'] as num?)?.toDouble() ?? 0;
          _maxAreaBound = (ranges['maxArea'] as num?)?.toDouble() ?? 10000;

          if (_minBudgetBound >= _maxBudgetBound) _maxBudgetBound = _minBudgetBound + 1000;
          if (_minAreaBound >= _maxAreaBound) _maxAreaBound = _minAreaBound + 100;

          if (widget.initialFilters?.minPrice == null && widget.initialFilters?.maxPrice == null) {
            _budgetRange = RangeValues(_minBudgetBound, _maxBudgetBound);
          } else {
            double currentMinB = _budgetRange.start.clamp(_minBudgetBound, _maxBudgetBound);
            double currentMaxB = _budgetRange.end.clamp(_minBudgetBound, _maxBudgetBound);
            if (currentMinB > currentMaxB) currentMaxB = currentMinB;
            _budgetRange = RangeValues(currentMinB, currentMaxB);
          }

          if (widget.initialFilters?.minArea == null && widget.initialFilters?.maxArea == null) {
            _areaRange = RangeValues(_minAreaBound, _maxAreaBound);
          } else {
            double currentMinA = _areaRange.start.clamp(_minAreaBound, _maxAreaBound);
            double currentMaxA = _areaRange.end.clamp(_minAreaBound, _maxAreaBound);
            if (currentMinA > currentMaxA) currentMaxA = currentMinA;
            _areaRange = RangeValues(currentMinA, currentMaxA);
          }

          _isLoadingBounds = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingBounds = false);
    }
  }

  void _clearAll() {
    setState(() {
      _purpose = null;
      _category = null;
      _type = null;
      _budgetRange = RangeValues(_minBudgetBound, _maxBudgetBound);
      _bedrooms = null;
      _status = null;
      _constructionPhase = null;
      _areaRange = RangeValues(_minAreaBound, _maxAreaBound);
      _bathrooms = null;
      _parking = null;
      _furnishing = null;
      _amenities = [];
    });
    if (mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('All filters cleared', style: GoogleFonts.inter()),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  String _formatBudget(double value) {
    if (value >= 10000000) {
      double cr = value / 10000000;
      return '₹${cr == cr.truncateToDouble() ? cr.toInt() : cr.toStringAsFixed(2)} Cr';
    } else if (value >= 100000) {
      double l = value / 100000;
      return '₹${l == l.truncateToDouble() ? l.toInt() : l.toStringAsFixed(2)} L';
    } else {
      // Add commas for smaller thousands amounts (e.g. 45,000)
      return '₹${value.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
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
    List<String> currentTypes = _category != null
        ? (_typesByCategory[_category!] ?? [])
        : (_typesByCategory.values.expand((x) => x).toSet().toList()..sort());

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
                      p, _purpose == p, () => setState(() => _purpose = _purpose == p ? null : p)
                    )).toList(),
                  ),
                  _buildDivider(),
                  
                  _buildSectionHeader('Category'),
                  const SizedBox(height: 16),
                  _isLoadingFilterOptions
                      ? const Center(child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator()))
                      : Wrap(
                          spacing: 8,
                          runSpacing: 12,
                          children: _categories.map((c) => _buildPillChip(
                            c, _category == c, () => setState(() {
                              _category = _category == c ? null : c;
                              if (_category != null && !(_typesByCategory[_category!] ?? []).contains(_type)) {
                                _type = null;
                              }
                            })
                          )).toList(),
                        ),
                  _buildDivider(),

                  _buildSectionHeader('Property Type'),
                  const SizedBox(height: 16),
                  _isLoadingFilterOptions
                      ? const Center(child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator()))
                      : currentTypes.isEmpty
                          ? Text(
                              _category == null ? 'No types available' : 'No types available for $_category',
                              style: GoogleFonts.inter(color: Theme.of(context).colorScheme.outlineVariant),
                            )
                          : Wrap(
                              spacing: 8,
                              runSpacing: 12,
                              children: currentTypes.map((t) => _buildPillChip(
                                t, _type == t, () => setState(() => _type = _type == t ? null : t)
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
                    child: _isLoadingBounds ? const Center(child: CircularProgressIndicator()) : RangeSlider(
                      values: _budgetRange,
                      min: _minBudgetBound,
                      max: _maxBudgetBound,
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
                  _buildDivider(),

                  _buildSectionHeader('Bathrooms'),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['1', '2', '3', '4+'].map((e) => _buildSelectionCircle(
                        e, _bathrooms == e, () => setState(() => _bathrooms = _bathrooms == e ? null : e),
                      )).toList(),
                    ),
                  ),
                  _buildDivider(),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSectionHeader('Area (sqft)'),
                      Text(
                        '${_areaRange.start.toInt()} - ${_areaRange.end.toInt()}',
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
                    child: _isLoadingBounds ? const Center(child: CircularProgressIndicator()) : RangeSlider(
                      values: _areaRange,
                      min: _minAreaBound,
                      max: _maxAreaBound,
                      divisions: 20,
                      activeColor: accentBlue,
                      inactiveColor: Theme.of(context).colorScheme.outlineVariant,
                      onChanged: (values) {
                        setState(() {
                          _areaRange = values;
                        });
                      },
                    ),
                  ),
                  _buildDivider(),

                  _buildSectionHeader('Property Status'),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 12,
                    children: _statuses.map((s) => _buildPillChip(
                      s, _status == s, () => setState(() => _status = _status == s ? null : s)
                    )).toList(),
                  ),
                  _buildDivider(),

                  _buildSectionHeader('Construction Phase'),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 12,
                    children: _constructionPhases.map((c) => _buildPillChip(
                      c, _constructionPhase == c, () => setState(() => _constructionPhase = _constructionPhase == c ? null : c)
                    )).toList(),
                  ),
                  _buildDivider(),

                  _buildSectionHeader('Parking'),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 12,
                    children: _parkingOptions.map((p) => _buildPillChip(
                      p, _parking == p, () => setState(() => _parking = _parking == p ? null : p)
                    )).toList(),
                  ),
                  _buildDivider(),

                  _buildSectionHeader('Furnishing State'),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 12,
                    children: _furnishingOptions.map((f) => _buildPillChip(
                      f, _furnishing == f, () => setState(() => _furnishing = _furnishing == f ? null : f)
                    )).toList(),
                  ),
                  _buildDivider(),

                  _buildSectionHeader('Amenities'),
                  const SizedBox(height: 16),
                  _isLoadingFilterOptions 
                      ? const Center(child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator()))
                      : _amenityOptions.isEmpty
                          ? Text('No amenities available', style: GoogleFonts.inter(color: Theme.of(context).colorScheme.outlineVariant))
                          : Wrap(
                              spacing: 8,
                              runSpacing: 12,
                              children: _amenityOptions.map((a) => _buildPillChip(
                                a, _amenities.contains(a), () => setState(() {
                                  if (_amenities.contains(a)) {
                                    _amenities.remove(a);
                                  } else {
                                    _amenities.add(a);
                                  }
                                })
                              )).toList(),
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
                    final isCleared = _purpose == null &&
                        _category == null &&
                        _type == null &&
                        _bedrooms == null &&
                        _status == null &&
                        _constructionPhase == null &&
                        _bathrooms == null &&
                        _parking == null &&
                        _furnishing == null &&
                        _amenities.isEmpty &&
                        _budgetRange.start <= _minBudgetBound &&
                        _budgetRange.end >= _maxBudgetBound &&
                        _areaRange.start <= _minAreaBound &&
                        _areaRange.end >= _maxAreaBound;

                    final filters = isCleared
                        ? PropertyFilters(
                            city: widget.initialFilters?.city,
                            state: widget.initialFilters?.state,
                          )
                        : PropertyFilters(
                            purpose: _purpose,
                            category: _category,
                            type: _type,
                            city: widget.initialFilters?.city,
                            state: widget.initialFilters?.state,
                            bedrooms: _bedrooms,
                            minPrice: _budgetRange.start > _minBudgetBound ? _budgetRange.start : null,
                            maxPrice: _budgetRange.end < _maxBudgetBound ? _budgetRange.end : null,
                            status: _status,
                            constructionPhase: _constructionPhase,
                            minArea: _areaRange.start > _minAreaBound ? _areaRange.start : null,
                            maxArea: _areaRange.end < _maxAreaBound ? _areaRange.end : null,
                            bathrooms: _bathrooms,
                            parking: _parking,
                            furnishing: _furnishing,
                            amenities: _amenities.isNotEmpty ? _amenities : null,
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
