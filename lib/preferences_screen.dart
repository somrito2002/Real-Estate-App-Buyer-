import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'complete_profile_screen.dart';

/// Screen shown after completing the profile to capture user preferences.
class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  int _selectedLookingFor = 0; // 0: Buy, 1: Rent, 2: Lease
  String _selectedPropertyType = 'Apartment';

  final List<String> _propertyTypes = [
    'Apartment', 'Independent House', 'Villa', 'Plot', 'Studio', 'Other'
  ];

  final TextEditingController _locationController =
      TextEditingController(text: 'Gurugram, Haryana');
  final TextEditingController _minBudgetController =
      TextEditingController(text: '50');
  final TextEditingController _maxBudgetController =
      TextEditingController(text: '200');

  RangeValues _budgetRange = const RangeValues(50, 200);

  bool _isLoading = false;

  void _updateBudgetFromText() {
    double min = double.tryParse(_minBudgetController.text) ?? _budgetRange.start;
    double max = double.tryParse(_maxBudgetController.text) ?? _budgetRange.end;
    
    if (min > max && _maxBudgetController.text.isNotEmpty) max = min;
    if (min < 0) min = 0;
    if (max > 1000) max = 1000;
    
    setState(() {
      _budgetRange = RangeValues(min, max);
    });
  }

  @override
  void dispose() {
    _locationController.dispose();
    _minBudgetController.dispose();
    _maxBudgetController.dispose();
    super.dispose();
  }

  void _onContinue() {
    setState(() => _isLoading = true);
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() => _isLoading = false);
        // Navigate to SuccessScreen
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const CompleteProfileScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Scaffold(
      backgroundColor: theme.cardColor,
      appBar: AppBar(
        backgroundColor: theme.cardColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Preferences',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(5),
          child: LinearProgressIndicator(
            value: 0.9,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
            minHeight: 5,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'What Are You Looking For?',
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tell us your preferences so we can find matching listings.',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),

              // Buy / Rent / Lease
              Container(
                height: 48,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    _buildLookingForTab('Buy', 0),
                    _buildLookingForTab('Rent', 1),
                    _buildLookingForTab('Lease', 2),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Property Type
              _buildLabel('Property Type'),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _propertyTypes.map((type) {
                  final isSelected = _selectedPropertyType == type;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedPropertyType = type),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1) : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.outline,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Text(
                        type,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 28),

              // Preferred Location
              _buildLabel('Preferred Location'),
              const SizedBox(height: 8),
              TextField(
                controller: _locationController,
                style: GoogleFonts.inter(fontSize: 15, color: Theme.of(context).colorScheme.onSurface),
                decoration: InputDecoration(
                  prefixIcon:
                      const Icon(Icons.location_on_outlined, color: Colors.grey),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.5),
                  ),
                  filled: true,
                  fillColor: Colors.transparent,
                ),
              ),
              const SizedBox(height: 28),

              // Budget
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildLabel('Budget (INR)'),
                  Text(
                    '₹${_budgetRange.start.toInt()} L - ₹${_budgetRange.end.toInt()} L',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13, color: Theme.of(context).colorScheme.primary),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 2.0,
                  rangeThumbShape: const RoundRangeSliderThumbShape(
                    enabledThumbRadius: 8.0,
                    elevation: 2.0,
                  ),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 16.0),
                  activeTrackColor: Theme.of(context).colorScheme.primary,
                  inactiveTrackColor: Colors.grey.shade200,
                  thumbColor: Theme.of(context).colorScheme.primary,
                  overlayColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                ),
                child: RangeSlider(
                  values: _budgetRange,
                  min: 0,
                  max: 1000,
                  divisions: 100,
                  labels: RangeLabels(
                    '₹${_budgetRange.start.toInt()} L',
                    '₹${_budgetRange.end.toInt()} L',
                  ),
                  onChanged: (values) {
                    setState(() {
                      _budgetRange = values;
                      _minBudgetController.text = values.start.toInt().toString();
                      _maxBudgetController.text = values.end.toInt().toString();
                    });
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('₹0', style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
                  Text('₹10 Cr', style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _minBudgetController,
                      keyboardType: TextInputType.number,
                      onChanged: (val) => _updateBudgetFromText(),
                      style: GoogleFonts.inter(
                          fontSize: 15, color: Theme.of(context).colorScheme.onSurface),
                      decoration: InputDecoration(
                        prefixText: 'Min: ₹ ',
                        suffixText: ' L',
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.5),
                        ),
                        filled: true,
                        fillColor: Colors.transparent,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _maxBudgetController,
                      keyboardType: TextInputType.number,
                      onChanged: (val) => _updateBudgetFromText(),
                      style: GoogleFonts.inter(
                          fontSize: 15, color: Theme.of(context).colorScheme.onSurface),
                      decoration: InputDecoration(
                        prefixText: 'Max: ₹ ',
                        suffixText: ' L',
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.5),
                        ),
                        filled: true,
                        fillColor: Colors.transparent,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // Continue button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _onContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          'Continue',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLookingForTab(String title, int index) {
    final isSelected = _selectedLookingFor == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedLookingFor = index),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }
}
