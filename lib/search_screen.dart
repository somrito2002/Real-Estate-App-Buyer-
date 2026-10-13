
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'buy_properties_screen.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'services/search_history_service.dart';
import 'services/property_api_service.dart';
import 'models/property_model.dart';
import 'package:easy_localization/easy_localization.dart';

import '../models/property_search_result.dart';
import 'property_details_screen.dart';
import 'recent_searches_screen.dart';

class SearchScreen extends StatefulWidget {
  final String initialCategory;
  final bool startVoiceSearchAutomatically;

  const SearchScreen({
    super.key,
    this.initialCategory = 'Buy',
    this.startVoiceSearchAutomatically = false,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  static const Color accentBlue = Color(0xFF4B85F0);
  
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  
  Timer? _debounce;
  List<Property> _suggestions = [];
  PropertyParsedQuery? _parsedQuery;
  bool _isLoadingSuggestions = false;

  // Voice search
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _voiceText = '';
  String _existingVoiceText = '';

  List<String> _recentSearches = [];
  String? _detectedState;
  List<Property> _stateSuggestions = [];
  bool _isLoadingStateSuggestions = false;

  static const Map<String, String> _cityToStateMap = {
    // Maharashtra
    'mumbai': 'Maharashtra',
    'bombay': 'Maharashtra',
    'pune': 'Maharashtra',
    'nagpur': 'Maharashtra',
    'nashik': 'Maharashtra',
    'thane': 'Maharashtra',
    'aurangabad': 'Maharashtra',
    'navi mumbai': 'Maharashtra',
    'solapur': 'Maharashtra',
    'amravati': 'Maharashtra',
    'kolhapur': 'Maharashtra',

    // Karnataka
    'bengaluru': 'Karnataka',
    'bangalore': 'Karnataka',
    'mysuru': 'Karnataka',
    'mysore': 'Karnataka',
    'hubli': 'Karnataka',
    'mangalore': 'Karnataka',
    'belgaum': 'Karnataka',

    // Delhi NCR
    'delhi': 'Delhi',
    'new delhi': 'Delhi',
    'noida': 'Uttar Pradesh',
    'greater noida': 'Uttar Pradesh',
    'gurugram': 'Haryana',
    'gurgaon': 'Haryana',
    'dlf phase 5': 'Haryana',
    'faridabad': 'Haryana',
    'ghaziabad': 'Uttar Pradesh',

    // Gujarat
    'ahmedabad': 'Gujarat',
    'surat': 'Gujarat',
    'vadodara': 'Gujarat',
    'baroda': 'Gujarat',
    'rajkot': 'Gujarat',
    'gandhinagar': 'Gujarat',

    // Punjab
    'ludhiana': 'Punjab',
    'amritsar': 'Punjab',
    'jalandhar': 'Punjab',
    'patiala': 'Punjab',
    'mohali': 'Punjab',
    'chandigarh': 'Punjab',

    // Goa
    'goa': 'Goa',
    'north goa': 'Goa',
    'south goa': 'Goa',
    'panaji': 'Goa',
    'margao': 'Goa',

    // Tamil Nadu
    'chennai': 'Tamil Nadu',
    'madras': 'Tamil Nadu',
    'coimbatore': 'Tamil Nadu',
    'madurai': 'Tamil Nadu',
    'tiruchirappalli': 'Tamil Nadu',
    'salem': 'Tamil Nadu',
    'veeravanallur': 'Tamil Nadu',

    // Telangana
    'hyderabad': 'Telangana',
    'secunderabad': 'Telangana',
    'warangal': 'Telangana',

    // Andhra Pradesh
    'visakhapatnam': 'Andhra Pradesh',
    'vijayawada': 'Andhra Pradesh',
    'guntur': 'Andhra Pradesh',

    // West Bengal
    'kolkata': 'West Bengal',
    'calcutta': 'West Bengal',
    'howrah': 'West Bengal',
    'durgapur': 'West Bengal',
    'siliguri': 'West Bengal',

    // Rajasthan
    'jaipur': 'Rajasthan',
    'udaipur': 'Rajasthan',
    'jodhpur': 'Rajasthan',
    'kota': 'Rajasthan',

    // Uttar Pradesh
    'lucknow': 'Uttar Pradesh',
    'kanpur': 'Uttar Pradesh',
    'varanasi': 'Uttar Pradesh',
    'agra': 'Uttar Pradesh',
    'prayagraj': 'Uttar Pradesh',

    // Madhya Pradesh
    'indore': 'Madhya Pradesh',
    'bhopal': 'Madhya Pradesh',
    'gwalior': 'Madhya Pradesh',
    'jabalpur': 'Madhya Pradesh',

    // Kerala
    'kochi': 'Kerala',
    'cochin': 'Kerala',
    'thiruvananthapuram': 'Kerala',
    'trivandrum': 'Kerala',
    'kozhikode': 'Kerala',

    // Chhattisgarh
    'bilaspur': 'Chhattisgarh',
    'raipur': 'Chhattisgarh',
    'bhilai': 'Chhattisgarh',
    'durg': 'Chhattisgarh',
    'deori': 'Chhattisgarh',

    // Bihar
    'patna': 'Bihar',
    'gaya': 'Bihar',

    // Odisha
    'bhubaneswar': 'Odisha',
    'cuttack': 'Odisha',

    // Assam
    'guwahati': 'Assam',

    // Uttarakhand
    'dehradun': 'Uttarakhand',
    'haridwar': 'Uttarakhand',

    // Himachal Pradesh
    'shimla': 'Himachal Pradesh',
    'manali': 'Himachal Pradesh',
    'dharamshala': 'Himachal Pradesh',

    // Jammu & Kashmir
    'srinagar': 'Jammu & Kashmir',
    'jammu': 'Jammu & Kashmir',

    // Jharkhand
    'ranchi': 'Jharkhand',
    'jamshedpur': 'Jharkhand',
  };

  String? _resolveState(String locationName) {
    if (locationName.isEmpty) return null;
    final clean = locationName.trim().toLowerCase();

    const knownStates = [
      'karnataka', 'maharashtra', 'delhi', 'gujarat', 'punjab', 'goa',
      'tamil nadu', 'telangana', 'andhra pradesh', 'west bengal', 'rajasthan',
      'uttar pradesh', 'madhya pradesh', 'kerala', 'chhattisgarh', 'bihar',
      'odisha', 'assam', 'uttarakhand', 'himachal pradesh', 'haryana',
      'jharkhand', 'jammu & kashmir'
    ];
    for (final s in knownStates) {
      if (clean == s || clean.contains(s)) {
        return s.split(' ').map((w) => w[0].toUpperCase() + w.substring(1)).join(' ');
      }
    }

    if (_cityToStateMap.containsKey(clean)) {
      return _cityToStateMap[clean];
    }

    for (final entry in _cityToStateMap.entries) {
      if (clean.contains(entry.key) || entry.key.contains(clean)) {
        return entry.value;
      }
    }

    return null;
  }

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _loadRecentSearches();
    
    if (widget.startVoiceSearchAutomatically) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startListening(appendToExisting: false);
      });
    }
    
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim();
      });
      _onSearchChanged(_searchQuery);
    });
  }

  Future<void> _loadRecentSearches() async {
    final searches = await SearchHistoryService.getRecentSearches();
    if (mounted) {
      setState(() {
        _recentSearches = searches;
      });
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    
    if (query.isEmpty) {
      setState(() {
        _suggestions = [];
        _parsedQuery = null;
        _isLoadingSuggestions = false;
        _detectedState = null;
        _stateSuggestions = [];
        _isLoadingStateSuggestions = false;
      });
      return;
    }

    setState(() {
      _isLoadingSuggestions = true;
      _detectedState = null;
      _stateSuggestions = [];
      _isLoadingStateSuggestions = false;
    });

    _debounce = Timer(const Duration(milliseconds: 300), () async {
      try {
        final result = await PropertyApiService.searchProperties(
          q: query,
          limit: 10,
        );
        if (mounted && _searchController.text.trim() == query) {
          setState(() {
            _suggestions = result.properties;
            _parsedQuery = result.parsedQuery;
            _isLoadingSuggestions = false;
          });

          // If no direct properties found, detect the state and fetch state suggestions
          if (result.properties.isEmpty) {
            final state = _resolveState(query);
            if (state != null && state.isNotEmpty) {
              setState(() {
                _detectedState = state;
                _isLoadingStateSuggestions = true;
              });
              try {
                final stateResult = await PropertyApiService.searchProperties(
                  state: state,
                  status: 'ACTIVE',
                  limit: 10,
                );
                if (mounted && _searchController.text.trim() == query) {
                  setState(() {
                    _stateSuggestions = stateResult.properties;
                    _isLoadingStateSuggestions = false;
                  });
                }
              } catch (_) {
                if (mounted && _searchController.text.trim() == query) {
                  setState(() {
                    _isLoadingStateSuggestions = false;
                  });
                }
              }
            }
          }
        }
      } catch (_) {
        if (mounted && _searchController.text.trim() == query) {
          setState(() {
            _isLoadingSuggestions = false;
          });
        }
      }
    });
  }

  bool _isBottomSheetOpen = false;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _speech.stop();
    super.dispose();
  }

  void _showListeningBottomSheet() {
    if (_isBottomSheetOpen) return;
    _isBottomSheetOpen = true;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      builder: (context) => _ListeningBottomSheet(
        onStop: () {
          Navigator.pop(context); // Will trigger the .then() block to stop listening
        },
      ),
    ).then((_) {
      _isBottomSheetOpen = false;
      if (_isListening) {
        _stopListening();
      }
    });
  }

  Future<void> _onMicTapped() async {
    if (_searchController.text.trim().isNotEmpty) {
      final shouldContinue = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Text('search.voice_search_title'.tr(), style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
          content: Text('search.voice_search_desc'.tr(), style: GoogleFonts.inter()),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('search.voice_search_new'.tr(), style: GoogleFonts.inter(color: accentBlue)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('search.voice_search_continue'.tr(), style: GoogleFonts.inter(color: accentBlue)),
            ),
          ],
        ),
      );
      
      if (shouldContinue == null) return;
      await _startListening(appendToExisting: shouldContinue);
    } else {
      await _startListening(appendToExisting: false);
    }
  }

  Future<void> _startListening({required bool appendToExisting}) async {
    bool available = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          if (mounted) {
            setState(() => _isListening = false);
            if (_isBottomSheetOpen) {
              Navigator.pop(context);
            }
          }
        }
      },
      onError: (error) {
        if (mounted) {
          setState(() => _isListening = false);
          if (_isBottomSheetOpen) {
            Navigator.pop(context);
          }
        }
      },
    );
    if (available) {
      setState(() {
        _isListening = true;
        _existingVoiceText = appendToExisting ? '${_searchController.text.trim()} ' : '';
        _voiceText = _existingVoiceText;
      });
      _showListeningBottomSheet();

      _speech.listen(
        onResult: (result) {
          if (mounted) {
            setState(() {
              _voiceText = _existingVoiceText + result.recognizedWords;
              _searchController.text = _voiceText;
            });

            if (result.finalResult) {
              _stopListening();
            }
          }
        },
        listenOptions: stt.SpeechListenOptions(
          listenMode: stt.ListenMode.dictation,
          partialResults: true,
          localeId: 'en_IN',
          pauseFor: const Duration(seconds: 5),
          listenFor: const Duration(minutes: 1),
        ),
      );
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('search.mic_permission_error'.tr(), style: GoogleFonts.inter()),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }

  void _stopListening() {
    _speech.stop();
    if (mounted) {
      setState(() => _isListening = false);
    }
    if (_isBottomSheetOpen) {
      Navigator.pop(context);
    }
  }

  Widget _buildSuggestionItem(Property suggestion) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PropertyDetailsScreen(property: suggestion),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                suggestion.imageUrl,
                width: 52,
                height: 52,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 52,
                  height: 52,
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: Icon(Icons.apartment, size: 24, color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    suggestion.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${suggestion.location}${suggestion.city.isNotEmpty ? ', ${suggestion.city}' : ''}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        suggestion.price,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: accentBlue,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (suggestion.type.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Text(
                          '•  ${suggestion.type}',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.north_west, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
              tooltip: 'Fill search',
              onPressed: () {
                _searchController.text = suggestion.title;
              },
            ),
          ],
        ),
      ),
    );
  }


  Future<void> _executeSearch(String query) async {
    final clean = query.trim();
    if (clean.isEmpty) return;
    await SearchHistoryService.addSearch(clean);
    _loadRecentSearches();
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BuyPropertiesScreen(initialSearchQuery: clean),
      ),
    ).then((_) {
      _loadRecentSearches();
    });
  }

  Future<void> _removeRecentSearch(String query) async {
    await SearchHistoryService.removeSearch(query);
    _loadRecentSearches();
  }

  Widget _buildRecentSearchItem(String search) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () {
        _searchController.text = search;
        _executeSearch(search);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
              ),
              child: Icon(
                Icons.history,
                size: 22,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    search,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Recent search',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.close,
                size: 20,
                color: colorScheme.onSurfaceVariant,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              splashRadius: 20,
              tooltip: 'Remove',
              onPressed: () => _removeRecentSearch(search),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopularCityChip(String city) {
    return InkWell(
      onTap: () {
        _searchController.text = city;
        _executeSearch(city);
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3)),
        ),
        child: Text(
          city,
          style: GoogleFonts.inter(
            fontSize: 13,
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
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
          'search.search_properties'.tr(),
          style: GoogleFonts.inter(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        titleSpacing: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: Theme.of(context).colorScheme.onSurfaceVariant, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'search.search_hint'.tr(),
                        hintStyle: GoogleFonts.inter(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onSubmitted: (value) {
                        _executeSearch(value);
                      },
                    ),
                  ),
                  if (_searchQuery.isNotEmpty)
                    InkWell(
                      onTap: () {
                        _searchController.clear();
                      },
                      child: Icon(Icons.close, color: Theme.of(context).colorScheme.onSurfaceVariant, size: 18),
                    ),
                  if (_searchQuery.isEmpty)
                    Icon(Icons.close, color: Theme.of(context).colorScheme.onSurfaceVariant, size: 18),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: _isListening ? _stopListening : _onMicTapped,
                    child: Icon(
                      _isListening ? Icons.mic : Icons.mic_off_outlined,
                      color: _isListening ? accentBlue : Theme.of(context).colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  
                  if (_searchQuery.isNotEmpty) ...[
                    if (_parsedQuery != null &&
                        ((_parsedQuery!.detectedBhk != null && _parsedQuery!.detectedBhk!.isNotEmpty) ||
                            _parsedQuery!.detectedTypes.isNotEmpty)) ...[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              'Detected:',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                            if (_parsedQuery!.detectedBhk != null && _parsedQuery!.detectedBhk!.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: accentBlue.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: accentBlue.withValues(alpha: 0.3)),
                                ),
                                child: Text(
                                  '${_parsedQuery!.detectedBhk} BHK',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: accentBlue,
                                  ),
                                ),
                              ),
                            ..._parsedQuery!.detectedTypes.map(
                              (t) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                                ),
                                child: Text(
                                  t,
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(height: 1, color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.4)),
                      const SizedBox(height: 8),
                    ],
                    if (_isLoadingSuggestions)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24.0),
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: accentBlue,
                          ),
                        ),
                      )
                    else if (_suggestions.isEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24.0),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.search_off_rounded,
                                size: 48,
                                color: Theme.of(context).colorScheme.outlineVariant,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'No properties found matching "$_searchQuery"',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                              if (_detectedState != null) ...[
                                const SizedBox(height: 6),
                                Text(
                                  'Showing available properties in $_detectedState',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: accentBlue,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      if (_isLoadingStateSuggestions)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: accentBlue,
                            ),
                          ),
                        )
                      else if (_stateSuggestions.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.only(top: 8, bottom: 12),
                          child: Row(
                            children: [
                              Icon(Icons.location_on, size: 16, color: accentBlue),
                              const SizedBox(width: 6),
                              Text(
                                'Properties in $_detectedState',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ..._stateSuggestions.map((suggestion) => _buildSuggestionItem(suggestion)),
                      ],
                    ]
                    else
                      ..._suggestions.map((suggestion) => _buildSuggestionItem(suggestion)),
                  ] else ...[
                    if (_recentSearches.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Recent',
                            style: GoogleFonts.inter(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const RecentSearchesScreen(),
                                ),
                              ).then((_) {
                                _loadRecentSearches();
                              });
                            },
                            borderRadius: BorderRadius.circular(4),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                              child: Text(
                                'See All',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: accentBlue,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Column(
                        children: _recentSearches
                            .take(5)
                            .map((s) => _buildRecentSearchItem(s))
                            .toList(),
                      ),
                      const SizedBox(height: 20),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      'search.popular_cities'.tr(),
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _buildPopularCityChip('Mumbai'),
                        _buildPopularCityChip('Delhi'),
                        _buildPopularCityChip('Bangalore'),
                        _buildPopularCityChip('Hyderabad'),
                        _buildPopularCityChip('Chennai'),
                        _buildPopularCityChip('Pune'),
                      ],
                    ),
                    const SizedBox(height: 32),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ListeningBottomSheet extends StatefulWidget {
  final VoidCallback onStop;

  const _ListeningBottomSheet({required this.onStop});

  @override
  State<_ListeningBottomSheet> createState() => _ListeningBottomSheetState();
}

class _ListeningBottomSheetState extends State<_ListeningBottomSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // Each dot gets its own curved animation with a staggered interval offset
  late Animation<double> _dot0;
  late Animation<double> _dot1;
  late Animation<double> _dot2;
  late Animation<double> _dot3;
  // Glow animation for the mic button
  late Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();

    // Staggered intervals: each dot starts 0.15 later than the previous
    _dot0 = _staggeredBounce(0.00, 0.60);
    _dot1 = _staggeredBounce(0.15, 0.75);
    _dot2 = _staggeredBounce(0.30, 0.90);
    _dot3 = _staggeredBounce(0.45, 1.00);

    // Glow uses the full cycle but slower feel via sine curve
    _glow = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  Animation<double> _staggeredBounce(double begin, double end) {
    return TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: -8.0).chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(begin: -8.0, end: 0.0).chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(begin, end, curve: Curves.linear),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 320,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(32), topRight: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Glowing Mic Button
          AnimatedBuilder(
            animation: _glow,
            builder: (context, child) {
              return GestureDetector(
                onTap: widget.onStop,
                child: Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).scaffoldBackgroundColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withValues(alpha: 0.15 + 0.25 * _glow.value),
                        blurRadius: 30 + 30 * _glow.value,
                        spreadRadius: 5 + 15 * _glow.value,
                      ),
                      BoxShadow(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(Icons.mic, color: Colors.blue.shade600, size: 55),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 40),
          Text(
            'search.listening'.tr(),
            style: GoogleFonts.inter(
                fontSize: 20,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 20),
          // Floating dots — each one translated vertically by its own animation
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildFloatingDot(_dot0.value),
                  const SizedBox(width: 8),
                  _buildFloatingDot(_dot1.value),
                  const SizedBox(width: 8),
                  _buildFloatingDot(_dot2.value),
                  const SizedBox(width: 8),
                  _buildFloatingDot(_dot3.value),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingDot(double yOffset) {
    return Transform.translate(
      offset: Offset(0, yOffset),
      child: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onSurface,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}


