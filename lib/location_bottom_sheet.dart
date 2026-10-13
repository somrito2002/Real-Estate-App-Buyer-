import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'location_picker_screen.dart';
import 'services/google_places_service.dart';
import 'package:easy_localization/easy_localization.dart';

class LocationBottomSheet extends StatefulWidget {
  const LocationBottomSheet({super.key});

  @override
  State<LocationBottomSheet> createState() => _LocationBottomSheetState();
}

class _LocationBottomSheetState extends State<LocationBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<PlaceSuggestion> _placeSuggestions = [];
  bool _isSearchingPlaces = false;
  Timer? _debounceTimer;

  final List<Map<String, String>> recentLocations = [
    {
      'title': 'Bengaluru',
      'subtitle': 'Karnataka',
    },
    {
      'title': 'Whitefield',
      'subtitle': 'Bengaluru, Karnataka',
    },
    {
      'title': 'DLF Phase 5',
      'subtitle': 'Gurgaon, Haryana',
    },
    {
      'title': 'Mumbai',
      'subtitle': 'Maharashtra',
    },
  ];

  // Current detected location
  String _detectedCity = '';
  String _detectedRegion = '';
  bool _isFetchingLocation = false;

  @override
  void initState() {
    super.initState();
    _autoDetectLocation(); // silently pre-fill the CURRENT LOCATION card on open
  }

  /// Called at startup — silently fetches GPS and reverse-geocodes to fill
  /// the CURRENT LOCATION card without navigating anywhere.
  Future<void> _autoDetectLocation() async {
    if (!mounted) return;
    setState(() => _isFetchingLocation = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        final position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
        );
        final geocoder = Geocoding();
        final placemarks = await geocoder.placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty && mounted) {
          final p = placemarks[0];
          final sub = p.subAdministrativeArea ?? '';
          final state = p.administrativeArea ?? '';
          final region = [sub, state].where((s) => s.isNotEmpty).join(', ');
          setState(() {
            _detectedCity = p.locality ?? sub;
            _detectedRegion = region;
          });
        }
      }
    } catch (_) {}
    if (mounted) setState(() => _isFetchingLocation = false);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  /// Called when user explicitly taps "Use current location" button —
  /// opens the full-screen map picker for precise location selection.
  Future<void> _openMapPicker() async {
    if (!mounted) return;
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LocationPickerScreen()),
    );
    if (result != null && result is Map<String, dynamic> && mounted) {
      Navigator.pop(context, result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          
          // Header Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'location.select_location'.tr(),
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                InkWell(
                  onTap: () => Navigator.pop(context),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isDarkMode ? colorScheme.surfaceContainerHighest : Theme.of(context).colorScheme.surfaceContainerHighest,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.close, size: 20, color: colorScheme.onSurface),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search Bar
                  TextField(
                    controller: _searchController,
                    textInputAction: TextInputAction.search,
                    onChanged: (val) {
                      _debounceTimer?.cancel();
                      if (val.trim().isEmpty) {
                        setState(() {
                          _placeSuggestions = [];
                          _isSearchingPlaces = false;
                        });
                        return;
                      }
                      _debounceTimer = Timer(const Duration(milliseconds: 300), () async {
                        setState(() => _isSearchingPlaces = true);
                        final results = await GooglePlacesService.getAutocompleteSuggestions(val.trim());
                        if (mounted) {
                          setState(() {
                            _placeSuggestions = results;
                            _isSearchingPlaces = false;
                          });
                        }
                      });
                    },
                    onSubmitted: (val) {
                      if (val.trim().isNotEmpty) {
                        Navigator.pop(context, {
                          'city': val.trim(),
                          'region': '',
                        });
                      }
                    },
                    decoration: InputDecoration(
                      hintText: 'location.search_hint'.tr(),
                      hintStyle: GoogleFonts.inter(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 14,
                      ),
                      prefixIcon: Icon(Icons.search, color: colorScheme.onSurfaceVariant),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _placeSuggestions = [];
                                  _isSearchingPlaces = false;
                                });
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: isDarkMode ? colorScheme.surfaceContainerHighest : Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDarkMode ? colorScheme.outlineVariant : Theme.of(context).colorScheme.outline,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                  ),

                  // Autocomplete Suggestions
                  if (_isSearchingPlaces) ...[
                    const SizedBox(height: 8),
                    const LinearProgressIndicator(),
                  ] else if (_placeSuggestions.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: isDarkMode ? colorScheme.surfaceContainerHighest : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isDarkMode ? colorScheme.outlineVariant : Theme.of(context).colorScheme.outline),
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _placeSuggestions.length,
                        separatorBuilder: (context, index) => Divider(
                          height: 1,
                          color: isDarkMode ? colorScheme.outlineVariant : Theme.of(context).colorScheme.surfaceContainerHighest,
                        ),
                        itemBuilder: (context, index) {
                          final suggestion = _placeSuggestions[index];
                          return ListTile(
                            leading: Icon(Icons.location_on_outlined, color: colorScheme.primary, size: 20),
                            title: Text(
                              suggestion.mainText,
                              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: colorScheme.onSurface),
                            ),
                            subtitle: suggestion.secondaryText.isNotEmpty
                                ? Text(
                                    suggestion.secondaryText,
                                    style: GoogleFonts.inter(fontSize: 12, color: colorScheme.onSurfaceVariant),
                                  )
                                : null,
                            onTap: () {
                              Navigator.pop(context, {
                                'city': suggestion.mainText,
                                'region': suggestion.secondaryText,
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),

                  // ── Use Current Location ───────────────────────────────
                  InkWell(
                    onTap: _isFetchingLocation ? null : _openMapPicker,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.my_location, size: 18, color: colorScheme.primary),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'location.choose_location'.tr(),
                                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: colorScheme.primary),
                                ),
                                Text(
                                  'location.using_device_location'.tr(),
                                  style: GoogleFonts.inter(fontSize: 12, color: colorScheme.onSurfaceVariant),
                                ),
                              ],
                            ),
                          ),
                          if (_isFetchingLocation)
                            SizedBox(
                              width: 16, height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: colorScheme.primary),
                            )
                          else
                            Icon(Icons.chevron_right, color: colorScheme.primary),
                        ],
                      ),
                    ),
                  ),

                  // ── CURRENT LOCATION card ─────────────────────────────
                  if (_detectedCity.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Text(
                      'location.current_location'.tr(),
                      style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.8, color: colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 10),
                    InkWell(
                      onTap: () => Navigator.pop(context, {
                        'city': _detectedCity,
                        'region': _detectedRegion,
                      }),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: colorScheme.primary.withValues(alpha: 0.25)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isDarkMode ? colorScheme.surfaceContainerHighest : Theme.of(context).colorScheme.surfaceContainerHighest,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.location_on_outlined, size: 20, color: colorScheme.onSurfaceVariant),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(_detectedCity, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: colorScheme.onSurface)),
                                  if (_detectedRegion.isNotEmpty)
                                    Text(_detectedRegion, style: GoogleFonts.inter(fontSize: 12, color: colorScheme.onSurfaceVariant)),
                                ],
                              ),
                            ),
                            Icon(Icons.check_circle, color: colorScheme.primary, size: 22),
                          ],
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),
                  
                  // Recent Locations
                  Text(
                    'location.recent_locations'.tr(),
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: recentLocations.length,
                    separatorBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.only(left: 48),
                      child: Divider(
                        color: isDarkMode ? colorScheme.outlineVariant : Theme.of(context).colorScheme.surfaceContainerHighest,
                        height: 1,
                      ),
                    ),
                    itemBuilder: (context, index) {
                      final location = recentLocations[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isDarkMode ? colorScheme.surfaceContainerHighest : Theme.of(context).colorScheme.surfaceContainerHighest,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.location_on_outlined, size: 20, color: colorScheme.onSurfaceVariant),
                        ),
                        title: Text(
                          location['title']!,
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        subtitle: Text(
                          location['subtitle']!,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(context, {
                            'city': location['title']!,
                            'region': location['subtitle']!,
                          });
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
