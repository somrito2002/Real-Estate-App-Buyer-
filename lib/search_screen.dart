import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'buy_properties_screen.dart';
import 'rent_properties_screen.dart';
import 'lease_properties_screen.dart';
import 'filter_screen.dart';
import 'models/property_model.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'home_screen.dart';
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
  late String _selectedCategory;
  
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<String> _recentSearches = [];

  // Voice search
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _voiceText = '';
  String _existingVoiceText = '';
  Timer? _silenceTimer;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
    _speech = stt.SpeechToText();
    
    if (widget.startVoiceSearchAutomatically) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startListening(appendToExisting: false);
      });
    }
    SearchHistoryService.getRecentSearches().then((value) {
      if (mounted) {
        setState(() {
          _recentSearches = value;
        });
      }
    });
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
        _existingVoiceText = appendToExisting ? _searchController.text.trim() + ' ' : '';
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

  List<Property> get _suggestions {
    if (_searchQuery.isEmpty) return [];
    
    final query = _searchQuery.toLowerCase();
    return mockProperties.where((p) {
      // Filter by category first (Buy vs Rent vs Lease)
      if (p.category != _selectedCategory && _selectedCategory != 'Lease') {
        // Mock properties only have Buy and Rent currently, let's just loosely match or ignore category if lease
        if (_selectedCategory == 'Buy' && p.category != 'Buy') return false;
        if (_selectedCategory == 'Rent' && p.category != 'Rent') return false;
      }
      
      return p.title.toLowerCase().contains(query) ||
             p.location.toLowerCase().contains(query) ||
             p.type.toLowerCase().contains(query) ||
             p.specs.toLowerCase().contains(query);
    }).toList();
  }

  Widget _buildCategoryChip(String label) {
    bool isSelected = _selectedCategory == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = label;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? accentBlue.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? accentBlue : Theme.of(context).colorScheme.outline.withOpacity(0.5),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            color: isSelected ? accentBlue : Theme.of(context).colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildRecentSearchItem(String text) {
    return InkWell(
      onTap: () async {
        _searchController.text = text;
        await SearchHistoryService.addSearch(text);
        if (!mounted) return;
        if (_selectedCategory == 'Rent') {
          Navigator.push(context, MaterialPageRoute(builder: (_) => RentPropertiesScreen(initialSearchQuery: text)));
        } else if (_selectedCategory == 'Lease') {
          Navigator.push(context, MaterialPageRoute(builder: (_) => LeasePropertiesScreen(initialSearchQuery: text)));
        } else {
          Navigator.push(context, MaterialPageRoute(builder: (_) => BuyPropertiesScreen(initialSearchQuery: text)));
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          children: [
            Icon(Icons.access_time, size: 18, color: Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w400,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationChip(String location) {
    return InkWell(
      onTap: () {
        _searchController.text = location;
        if (_selectedCategory == 'Rent') {
          Navigator.push(context, MaterialPageRoute(builder: (_) => RentPropertiesScreen(initialSearchQuery: location)));
        } else if (_selectedCategory == 'Lease') {
          Navigator.push(context, MaterialPageRoute(builder: (_) => LeasePropertiesScreen(initialSearchQuery: location)));
        } else {
          Navigator.push(context, MaterialPageRoute(builder: (_) => BuyPropertiesScreen(initialSearchQuery: location)));
        }
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.5)),
        ),
        child: Text(
          location,
          style: GoogleFonts.inter(
            fontSize: 13,
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildTrendingSearchItem(String text) {
    return InkWell(
      onTap: () {
        _searchController.text = text;
        if (_selectedCategory == 'Rent') {
          Navigator.push(context, MaterialPageRoute(builder: (_) => RentPropertiesScreen(initialSearchQuery: text)));
        } else {
          Navigator.push(context, MaterialPageRoute(builder: (_) => BuyPropertiesScreen(initialSearchQuery: text)));
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          children: [
            Icon(Icons.trending_up, size: 18, color: accentBlue),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionItem(Property property) {
    return InkWell(
      onTap: () {
        // When a property is selected, navigate to properties screen
        if (property.category == 'Rent') {
          Navigator.push(context, MaterialPageRoute(builder: (_) => RentPropertiesScreen(initialSearchQuery: property.title)));
        } else if (property.category == 'Lease') {
          Navigator.push(context, MaterialPageRoute(builder: (_) => LeasePropertiesScreen(initialSearchQuery: property.title)));
        } else {
          Navigator.push(context, MaterialPageRoute(builder: (_) => BuyPropertiesScreen(initialSearchQuery: property.title)));
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                property.imageUrl,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 60,
                  height: 60,
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: const Icon(Icons.image_not_supported, size: 24, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    property.title,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    property.location,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${property.type} • ${property.price}',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: accentBlue,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
          ],
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
          onPressed: () => Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
            (route) => false,
          ),
        ),
        title: Text(
          'Search Properties',
          style: GoogleFonts.inter(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_none, color: Theme.of(context).colorScheme.onSurface),
            onPressed: () {},
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Theme.of(context).colorScheme.surfaceContainerHighest, height: 1),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Input
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.5)),
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
                            hintText: 'Search location, project, or property...',
                            hintStyle: GoogleFonts.inter(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                              fontSize: 14,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onSubmitted: (value) async {
                            if (value.isNotEmpty) {
                              await SearchHistoryService.addSearch(value);
                              if (!mounted) return;
                              if (_selectedCategory == 'Rent') {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => RentPropertiesScreen(initialSearchQuery: value)));
                              } else if (_selectedCategory == 'Lease') {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => LeasePropertiesScreen(initialSearchQuery: value)));
                              } else {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => BuyPropertiesScreen(initialSearchQuery: value)));
                              }
                            }
                          },
                        ),
                      ),
                      if (_searchQuery.isNotEmpty)
                        InkWell(
                          onTap: () {
                            _searchController.clear();
                          },
                          child: Icon(Icons.close, color: Theme.of(context).colorScheme.onSurfaceVariant, size: 20),
                        ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: _isListening ? _stopListening : _onMicTapped,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: _isListening ? accentBlue.withOpacity(0.15) : Colors.transparent,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _isListening ? Icons.mic : Icons.mic_off_outlined,
                            color: _isListening ? accentBlue : Theme.of(context).colorScheme.onSurfaceVariant,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => FilterScreen(initialCategory: _selectedCategory)));
                        },
                        child: Icon(Icons.tune, color: Theme.of(context).colorScheme.onSurface, size: 22),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // Chips row (Buy, Rent, Lease)
                Row(
                  children: [
                    _buildCategoryChip('Buy'),
                    _buildCategoryChip('Rent'),
                    _buildCategoryChip('Lease'),
                  ],
                ),
              ],
            ),
          ),
          
          Expanded(
            child: _searchQuery.isEmpty
                ? SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        // Recent Searches
                        if (_recentSearches.isNotEmpty) ...[
                          Text(
                            'Recent Searches',
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ..._recentSearches.map((s) => _buildRecentSearchItem(s)).toList(),
                          const SizedBox(height: 24),
                        ],
                        
                        // Popular Locations
                        Text(
                          'Popular Locations',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 12,
                          children: [
                            _buildLocationChip('Durg'),
                            _buildLocationChip('Raipur'),
                            _buildLocationChip('Bhilai'),
                            _buildLocationChip('Mumbai'),
                            _buildLocationChip('Gurgaon'),
                            _buildLocationChip('Bangalore'),
                          ],
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Trending Searches
                        Text(
                          'Trending Searches',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildTrendingSearchItem('DLF The Crest Gurgaon'),
                        _buildTrendingSearchItem('Gachibowli Hyderabad Flats'),
                        _buildTrendingSearchItem('Plots in Raipur'),
                        const SizedBox(height: 32),
                      ],
                    ),
                  )
                : _suggestions.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off, size: 64, color: Theme.of(context).colorScheme.outline),
                            const SizedBox(height: 16),
                            Text(
                              'No properties found',
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Try adjusting your search keyword',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: _suggestions.length,
                        separatorBuilder: (context, index) => Divider(
                          color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5),
                          height: 1,
                        ),
                        itemBuilder: (context, index) {
                          return _buildSuggestionItem(_suggestions[index]);
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
