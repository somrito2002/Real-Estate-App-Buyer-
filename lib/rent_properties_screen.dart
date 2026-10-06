import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'models/property_model.dart';
import 'services/wishlist_api_service.dart';
import 'filter_screen.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'property_details_screen.dart';
import 'property_details_loader.dart';
import 'widgets/remove_shortlist_dialog.dart';
import 'services/property_api_service.dart';

class RentPropertiesScreen extends StatefulWidget {
  final String initialSearchQuery;

  const RentPropertiesScreen({super.key, this.initialSearchQuery = ''});

  @override
  State<RentPropertiesScreen> createState() => _RentPropertiesScreenState();
}

class _RentPropertiesScreenState extends State<RentPropertiesScreen> {
  late TextEditingController _searchController;
  List<Property> _allProperties = [];
  List<Property> _filteredProperties = [];
  bool _isLoading = true;
  String _selectedType = 'All Types';
  bool _isMapView = false;
  String _currentSortOption = 'Recommended';
  static const Color accentBlue = Color(0xFF4B85F0);

  bool _isConnected = true;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialSearchQuery);
    _checkInternetConnection();
  }

  Future<void> _checkInternetConnection() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      setState(() {
        _isConnected = !connectivityResult.contains(ConnectivityResult.none);
      });
    } catch (e) {
      setState(() {
        _isConnected = true;
      });
    }
    if (_isConnected) {
      _fetchProperties();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchProperties() async {
    setState(() { _isLoading = true; });
    try {
      final properties = await PropertyApiService.getProperties(status: 'ACTIVE', limit: 30);
      if (mounted) {
        setState(() {
          // Temporarily filtering by 'Rent' until a category param is added to the backend
          _allProperties = properties.where((p) => p.category == 'Rent').toList();
          _isLoading = false;
        });
        _filterProperties();
      }
    } catch (e) {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }

  void _filterProperties() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredProperties = _allProperties.where((p) {
        final matchesQuery = p.title.toLowerCase().contains(query) ||
                             p.location.toLowerCase().contains(query) ||
                             p.type.toLowerCase().contains(query) ||
                             p.specs.toLowerCase().contains(query);
        final matchesType = _selectedType == 'All Types' || p.category.toLowerCase() == _selectedType.toLowerCase() ||
                           (_selectedType == 'Residential' && p.category == 'Rent'); // simplistic matching for mock
        return matchesQuery && matchesType;
      }).toList();
    });
    _applySort();
  }

  void _applySort() {
    setState(() {
      if (_currentSortOption == 'Price â€” Low to High') {
        _filteredProperties.sort((a, b) => _parsePrice(a.price).compareTo(_parsePrice(b.price)));
      } else if (_currentSortOption == 'Price â€” High to Low') {
        _filteredProperties.sort((a, b) => _parsePrice(b.price).compareTo(_parsePrice(a.price)));
      }
      // other logic can be added here
    });
  }

  double _parsePrice(String price) {
    String p = price.replaceAll('â‚¹', '').replaceAll(',', '').trim();
    if (p.contains('Cr')) {
      return (double.tryParse(p.replaceAll('Cr', '').trim()) ?? 0) * 10000000;
    } else if (p.contains('Lakh') || p.contains('L')) {
      return (double.tryParse(p.replaceAll('Lakh', '').replaceAll('L', '').trim()) ?? 0) * 100000;
    }
    return double.tryParse(p) ?? 0;
  }
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isMapView,
      onPopInvoked: (didPop) {
        if (didPop) return;
        
        if (_isMapView) {
          setState(() {
            _isMapView = false;
          });
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface),
            onPressed: () {
              if (_isMapView) {
                setState(() => _isMapView = false);
              } else {
                Navigator.pop(context);
              }
            },
          ),
          title: Text(
            'Rent Properties',
            style: GoogleFonts.inter(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Center(
                child: Container(
                  height: 32,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () => setState(() => _isMapView = false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          decoration: BoxDecoration(
                            color: !_isMapView ? accentBlue : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'List',
                            style: GoogleFonts.inter(
                              color: !_isMapView ? Colors.white : Theme.of(context).colorScheme.onSurfaceVariant,
                              fontWeight: !_isMapView ? FontWeight.w600 : FontWeight.w500,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => setState(() => _isMapView = true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          decoration: BoxDecoration(
                            color: _isMapView ? accentBlue : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Map',
                            style: GoogleFonts.inter(
                              color: _isMapView ? Colors.white : Theme.of(context).colorScheme.onSurfaceVariant,
                              fontWeight: _isMapView ? FontWeight.w600 : FontWeight.w500,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(
              color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
              height: 1,
            ),
          ),
        ),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (!_isConnected) {
      return _buildNoInternetScreen();
    }
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_isMapView) {
      return _buildMapView();
    }
    if (_filteredProperties.isEmpty) {
      return _buildEmptyStateScreen();
    }
    return Column(
        children: [
          // Search & Filters Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              border: Border(
                bottom: BorderSide(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5)),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Field
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.radio_button_unchecked, color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5), size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: (val) => _filterProperties(),
                          decoration: InputDecoration(
                            hintText: 'Search location, project...',
                            hintStyle: GoogleFonts.inter(color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5), fontSize: 14),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const FilterScreen()));
                        },
                        child: Icon(Icons.tune, color: Theme.of(context).colorScheme.onSurface, size: 20),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // Types List
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['All Types', 'Residential', 'Commercial', 'Budget'].map((type) {
                      final isSelected = _selectedType == type;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _selectedType = type;
                              _filterProperties();
                            });
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? accentBlue.withValues(alpha: 0.1) : Theme.of(context).colorScheme.surface,
                              border: Border.all(color: isSelected ? accentBlue : Theme.of(context).colorScheme.outlineVariant),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              type,
                              style: GoogleFonts.inter(
                                color: isSelected ? accentBlue : Theme.of(context).colorScheme.onSurface,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Sort Button
                GestureDetector(
                  onTap: _showSortBottomSheet,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.swap_vert, size: 18, color: Theme.of(context).colorScheme.onSurface),
                        const SizedBox(width: 8),
                        Text(
                          'Sort',
                          style: GoogleFonts.inter(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_filteredProperties.length} Properties for Rent',
                      style: GoogleFonts.inter(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(Icons.tune, size: 14, color: accentBlue),
                        const SizedBox(width: 4),
                        Text(
                          'Filters',
                          style: GoogleFonts.inter(
                            color: accentBlue,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Property List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              itemCount: _filteredProperties.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                return _buildPropertyCard(_filteredProperties[index]);
              },
            ),
          ),
        ],
      );
  }

  Widget _buildNoInternetScreen() {
    return Column(
      children: [
        // The chips header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            border: Border(bottom: BorderSide(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5))),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _buildAppliedFilterChips(),
            ),
          ),
        ),
        // Empty body
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(Icons.cloud_off, size: 50, color: Colors.red.shade400),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Unable to Load Results',
                  style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
                ),
                const SizedBox(height: 12),
                Text(
                  'Please check your internet connection or network\nsignal and try again.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(fontSize: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      _checkInternetConnection();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentBlue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text('Retry Connection', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('Go Back', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyStateScreen() {
    return Column(
      children: [
        // The chips header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            border: Border(bottom: BorderSide(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5))),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _buildAppliedFilterChips(),
            ),
          ),
        ),
        // Empty body
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: accentBlue.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(Icons.search, size: 40, color: accentBlue),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'No Properties Found',
                  style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
                ),
                const SizedBox(height: 12),
                Text(
                  'Try adjusting your filters or search in a different location.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(fontSize: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _searchController.clear();
                        _selectedType = 'All Types';
                        _filterProperties();
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: accentBlue),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text('Clear Filters', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: accentBlue)),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const FilterScreen()));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentBlue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text('Modify Search', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildAppliedFilterChips() {
    final chips = <Widget>[];
    if (_selectedType != 'All Types') {
      chips.add(_buildAppliedFilterChip(_selectedType, () {
        setState(() { _selectedType = 'All Types'; _filterProperties(); });
      }));
    }
    if (_searchController.text.isNotEmpty) {
      chips.add(_buildAppliedFilterChip(_searchController.text, () {
        setState(() { _searchController.clear(); _filterProperties(); });
      }));
    }
    if (_searchController.text.isEmpty && _selectedType == 'All Types') {
      chips.add(_buildAppliedFilterChip('Residential', () {}));
      chips.add(_buildAppliedFilterChip('3 BHK', () {}));
      chips.add(_buildAppliedFilterChip('Durg', () {}));
      chips.add(_buildAppliedFilterChip('â‚¹50L-â‚¹90L', () {}));
    }
    return chips;
  }

  Widget _buildAppliedFilterChip(String label, VoidCallback onRemove) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: accentBlue.withValues(alpha: 0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: GoogleFonts.inter(fontSize: 13, color: accentBlue, fontWeight: FontWeight.w500)),
            const SizedBox(width: 4),
            InkWell(
              onTap: onRemove,
              child: const Icon(Icons.close, size: 16, color: accentBlue),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPropertyCard(Property property) {
    // Generate styling based on status
    Color statusColor = Colors.white;
    Color statusBgColor = accentBlue;
    String statusText = property.status.contains('FURNISHED') ? property.status : 'FURNISHED';

    if (property.status.contains('SEMI')) {
      statusText = 'SEMI-FURNISHED';
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => PropertyDetailsLoader(propertyId: property.id)));
      },
      child: Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image and badges
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  property.imageUrl,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 180,
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      child: Center(
                        child: Icon(Icons.image_not_supported, size: 48, color: Theme.of(context).colorScheme.onSurfaceVariant),
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusBgColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    statusText,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: InkWell(
                  onTap: () async {
                    bool currentFavorite = WishlistApiService.isWishlisted(property.id);
                    if (currentFavorite) {
                      final bool? confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => RemoveShortlistDialog(
                          propertyTitle: property.title,
                        ),
                      );
                      if (confirm != true) return;
                    }

                    if (!mounted) return;
                    await WishlistApiService.handleToggleWishlist(
                      context,
                      property.id,
                      onUpdate: (newState) {
                        if (mounted) {
                          setState(() {
                            property.isFavorite = newState;
                          });
                        }
                      },
                      onError: (error) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
                        }
                      },
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1), blurRadius: 4),
                      ],
                    ),
                    child: Icon(
                      property.isFavorite ? Icons.favorite : Icons.favorite_border,
                      size: 20,
                      color: property.isFavorite ? Colors.red : Colors.grey,
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Details
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  property.price,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: accentBlue,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  property.title,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on_outlined, size: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        property.location,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Divider(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5), height: 1),
                const SizedBox(height: 12),
                Text(
                  property.specs,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
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
  Widget _buildMapView() {
    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              // Background Map Placeholder
              Container(
                width: double.infinity,
                height: double.infinity,
                color: const Color(0xFFEFE9E1), // Map background color
                child: CustomPaint(
                  painter: _MapGridPainter(),
                ),
              ),
              // Price markers
              Positioned(
                top: 100, left: 50,
                child: _buildPriceMarker('â‚¹75L', false),
              ),
              Positioned(
                top: 180, right: 80,
                child: _buildPriceMarker('â‚¹85L', false),
              ),
              Positioned(
                top: 250, left: 150,
                child: _buildPriceMarker('â‚¹1.2Cr', true),
              ),
              Positioned(
                bottom: 250, left: 80,
                child: _buildPriceMarker('â‚¹1.9Cr', false),
              ),
              
              // Bottom Card
              Positioned(
                bottom: 24,
                left: 16,
                right: 16,
                child: _filteredProperties.isNotEmpty 
                    ? _buildMapPropertyCard(_filteredProperties.first)
                    : const SizedBox(),
              ),
            ],
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          child: Text(
            'Swipe card above to browse ${_filteredProperties.length} properties in this area',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceMarker(String price, bool isActive) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isActive ? 16 : 12, vertical: isActive ? 8 : 6),
      decoration: BoxDecoration(
        color: isActive ? Theme.of(context).colorScheme.onSurface : accentBlue,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.15), blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Text(
        price,
        style: GoogleFonts.inter(
          color: Theme.of(context).colorScheme.surface,
          fontWeight: FontWeight.bold,
          fontSize: isActive ? 14 : 12,
        ),
      ),
    );
  }

  Widget _buildMapPropertyCard(Property property) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1), blurRadius: 10, offset: Offset(0, 5)),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              property.imageUrl,
              height: 100,
              width: 100,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 100, width: 100, color: Colors.grey[300],
                child: const Icon(Icons.image, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      property.price,
                      style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: accentBlue),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'READY',
                        style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.green),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  property.title,
                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  property.specs,
                  style: GoogleFonts.inter(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on_outlined, size: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        property.location,
                        style: GoogleFonts.inter(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSortBottomSheet() {
    String tempSort = _currentSortOption;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.outline,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Sort By',
                    style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
                  ),
                  const SizedBox(height: 16),
                  ...[
                    'Recommended',
                    'Newest First',
                    'Price â€” Low to High',
                    'Price â€” High to Low',
                    'Area â€” Smallest First',
                    'Area â€” Largest First'
                  ].map((option) {
                    return InkWell(
                      onTap: () {
                        setSheetState(() => tempSort = option);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              option,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            Icon(
                              tempSort == option ? Icons.radio_button_checked : Icons.radio_button_off,
                              color: tempSort == option ? accentBlue : Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _currentSortOption = tempSort;
                        });
                        _applySort();
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: Text('Apply', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round;

    // Draw some fake intersecting roads
    canvas.drawLine(Offset(size.width * 0.2, 0), Offset(size.width * 0.8, size.height), paint);
    canvas.drawLine(Offset(size.width * 0.8, 0), Offset(size.width * 0.2, size.height), paint);
    canvas.drawLine(Offset(0, size.height * 0.5), Offset(size.width, size.height * 0.5), paint);

    paint.color = Colors.white.withValues(alpha: 0.5);
    paint.strokeWidth = 2.0;
    canvas.drawLine(Offset(size.width * 0.4, 0), Offset(size.width * 0.4, size.height), paint);
    canvas.drawLine(Offset(size.width * 0.6, 0), Offset(size.width * 0.6, size.height), paint);
    canvas.drawLine(Offset(0, size.height * 0.3), Offset(size.width, size.height * 0.3), paint);
    canvas.drawLine(Offset(0, size.height * 0.7), Offset(size.width, size.height * 0.7), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
