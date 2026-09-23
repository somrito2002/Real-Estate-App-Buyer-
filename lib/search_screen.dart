
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'buy_properties_screen.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'services/search_history_service.dart';
import 'services/google_places_service.dart';
import 'package:easy_localization/easy_localization.dart';

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
  List<PlaceSuggestion> _suggestions = [];

  // Voice search
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _voiceText = '';
  String _existingVoiceText = '';

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    
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

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    
    if (query.isEmpty) {
      setState(() {
        _suggestions = [];
      });
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 300), () async {
      final suggestions = await GooglePlacesService.getAutocompleteSuggestions(query);
      if (mounted) {
        setState(() {
          _suggestions = suggestions;
        });
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

  Widget _buildSuggestionItem(PlaceSuggestion suggestion) {
    return InkWell(
      onTap: () {
        _searchController.text = suggestion.description;
        Navigator.push(context, MaterialPageRoute(builder: (_) => BuyPropertiesScreen(initialSearchQuery: suggestion.description)));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Row(
          children: [
            Icon(Icons.location_on_outlined, size: 20, color: Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    suggestion.mainText.isNotEmpty ? suggestion.mainText : suggestion.description,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (suggestion.secondaryText.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      suggestion.secondaryText,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: accentBlue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
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
        Navigator.push(context, MaterialPageRoute(builder: (_) => BuyPropertiesScreen(initialSearchQuery: city)));
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
                      onSubmitted: (value) async {
                        if (value.isNotEmpty) {
                          await SearchHistoryService.addSearch(value);
                          if (!context.mounted) return;
                          Navigator.push(context, MaterialPageRoute(builder: (_) => BuyPropertiesScreen(initialSearchQuery: value)));
                        }
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
                    if (_suggestions.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24.0),
                        child: Center(
                          child: Text(
                            'search.loading'.tr(),
                            style: GoogleFonts.inter(color: Theme.of(context).colorScheme.onSurfaceVariant),
                          ),
                        ),
                      )
                    else
                      ..._suggestions.map((suggestion) => _buildSuggestionItem(suggestion)),
                  ] else ...[
                    const SizedBox(height: 24),
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


