import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'buy_properties_screen.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'services/search_history_service.dart';

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

  // Voice search
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _voiceText = '';
  String _existingVoiceText = '';
  Timer? _silenceTimer;

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
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _silenceTimer?.cancel();
    _speech.stop();
    super.dispose();
  }

  Future<void> _onMicTapped() async {
    if (_searchController.text.trim().isNotEmpty) {
      final shouldContinue = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Text('Voice Search', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
          content: Text('What would you like to do?', style: GoogleFonts.inter()),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Search new', style: GoogleFonts.inter(color: accentBlue)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Want to continue', style: GoogleFonts.inter(color: accentBlue)),
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
          }
        }
      },
      onError: (error) {
        if (mounted) setState(() => _isListening = false);
      },
    );
    if (available) {
      setState(() {
        _isListening = true;
        _existingVoiceText = appendToExisting ? '${_searchController.text.trim()} ' : '';
        _voiceText = _existingVoiceText;
      });
      
      _silenceTimer?.cancel();
      _silenceTimer = Timer(const Duration(seconds: 2), () {
        if (mounted && _isListening) {
          _stopListening();
        }
      });
      
      _speech.listen(
        onResult: (result) {
          _silenceTimer?.cancel();
          if (mounted) {
            setState(() {
              _voiceText = _existingVoiceText + result.recognizedWords;
              _searchController.text = _voiceText;
            });
            if (result.finalResult && _voiceText.trim().isNotEmpty) {
              _speech.stop();
              setState(() => _isListening = false);
            }
          }
        },
        listenOptions: stt.SpeechListenOptions(
          listenFor: const Duration(seconds: 10),
          pauseFor: const Duration(seconds: 2),
          partialResults: true,
          localeId: 'en_IN',
        ),
      );
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Microphone permission not granted.', style: GoogleFonts.inter()),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }

  void _stopListening() {
    _silenceTimer?.cancel();
    _speech.stop();
    setState(() => _isListening = false);
  }

  Widget _buildMockupLocationItem(String title, String subtitle) {
    return InkWell(
      onTap: () {
        _searchController.text = title;
        Navigator.push(context, MaterialPageRoute(builder: (_) => BuyPropertiesScreen(initialSearchQuery: title)));
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
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: accentBlue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
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
          'Search Properties',
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
                        hintText: 'Search location, project, or pr...',
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
                  _buildMockupLocationItem('Bangalore', 'City'),
                  _buildMockupLocationItem('Bandra, Mumbai', 'Area'),
                  _buildMockupLocationItem('Bannerghatta Road, Bangalore', 'Locality'),
                  _buildMockupLocationItem('Banjara Hills, Hyderabad', 'Locality'),
                  
                  const SizedBox(height: 24),
                  
                  Text(
                    'POPULAR CITIES',
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}
