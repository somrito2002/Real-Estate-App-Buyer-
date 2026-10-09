import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'models/property_model.dart';
import 'models/property_filters.dart';
import 'services/wishlist_api_service.dart';
import 'filter_screen.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'property_details_screen.dart';
import 'property_details_loader.dart';
import 'widgets/remove_shortlist_dialog.dart';
import 'services/property_api_service.dart';


class BuyPropertiesScreen extends StatefulWidget {
  final String initialSearchQuery;

  const BuyPropertiesScreen({super.key, this.initialSearchQuery = ''});

  @override
  State<BuyPropertiesScreen> createState() => _BuyPropertiesScreenState();
}

class _BuyPropertiesScreenState extends State<BuyPropertiesScreen> {
  late TextEditingController _searchController;
  final List<Property> _properties = [];
  String _selectedType = 'All Types';
  bool _isMapView = false;
  String _currentSortOption = 'Recommended';
  static const Color accentBlue = Color(0xFF4B85F0);

  bool _isConnected = true;
  bool _isLoading = true;
  bool _isFetchingMore = false;
  bool _hasMore = true;
  int _currentPage = 1;
  final ScrollController _scrollController = ScrollController();

  PropertyFilters? _filters;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialSearchQuery);
    _scrollController.addListener(_onScroll);
    _checkInternetConnection();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoading && !_isFetchingMore && _hasMore) {
        _fetchMoreProperties();
      }
    }
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
      _fetchProperties(isRefresh: true);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchProperties({bool isRefresh = false}) async {
    if (isRefresh) {
      _currentPage = 1;
      _hasMore = true;
      setState(() { _isLoading = true; });
    }

    try {
      final newProperties = await PropertyApiService.getProperties(
        status: 'ACTIVE',
        limit: 10,
        page: _currentPage,
        purpose: _filters?.purpose,
        category: _filters?.category,
        type: _filters?.type,
        city: _filters?.city,
        state: _filters?.state,
        bedrooms: _filters?.bedrooms,
        minPrice: _filters?.minPrice,
        maxPrice: _filters?.maxPrice,
      );

      if (!mounted) return;

      setState(() {
        if (isRefresh) {
          _properties.clear();
        }
        for (var p in newProperties) {
          if (!_properties.any((existing) => existing.id == p.id)) {
            _properties.add(p);
          }
        }
        if (newProperties.isEmpty || newProperties.length < 10) {
          _hasMore = false;
        }
        _isLoading = false;
        _isFetchingMore = false;
      });
      _applySort();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _isFetchingMore = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading properties: $e'), action: SnackBarAction(label: 'Retry', onPressed: () => _fetchProperties(isRefresh: isRefresh))),
      );
    }
  }


  Future<void> _fetchMoreProperties() async {
    setState(() { _isFetchingMore = true; });
    _currentPage++;
    await _fetchProperties();
  }

  void _applySort() {
    setState(() {
      if (_currentSortOption == 'Price — Low to High') {
        _properties.sort((a, b) => _parsePrice(a.price).compareTo(_parsePrice(b.price)));
      } else if (_currentSortOption == 'Price — High to Low') {
        _properties.sort((a, b) => _parsePrice(b.price).compareTo(_parsePrice(a.price)));
      }
    });
  }

  double _parsePrice(String price) {
    String p = price.replaceAll('₹', '').replaceAll(',', '').trim();
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
      onPopInvokedWithResult: (didPop, result) {
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
            'Bandra, Mumbai',
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
    if (_isMapView) {
      return _buildMapView();
    }
    if (_properties.isEmpty && !_isLoading) {
      return _buildEmptyStateScreen();
    }
    return Column(
        children: [
          // Search & Filters Header
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).scaffoldBackgroundColor,
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
                      Icon(Icons.search, color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5), size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: (val) { setState(() {}); },
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
                        onTap: () async {
                          final filters = await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => FilterScreen(initialFilters: _filters)),
                          );
                          if (filters != null && filters is PropertyFilters) {
                            setState(() {
                              _filters = filters;
                            });
                            _fetchProperties(isRefresh: true);
                          }
                        },
                        child: Icon(Icons.tune, color: Theme.of(context).colorScheme.onSurface, size: 20),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // Types & Sort List
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // Sort Chip
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: InkWell(
                          onTap: _showSortBottomSheet,
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.swap_vert, size: 16, color: Theme.of(context).colorScheme.onSurface),
                                const SizedBox(width: 4),
                                Text(
                                  'Sort',
                                  style: GoogleFonts.inter(
                                    color: Theme.of(context).colorScheme.onSurface,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Filter Chips
                      ...(_filters?.activeLabels ?? ['Residential', 'Any Budget', 'Any BHK']).map((type) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: InkWell(
                            onTap: () async {
                              final filters = await Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => FilterScreen(initialFilters: _filters)),
                              );
                              if (filters != null && filters is PropertyFilters) {
                                setState(() {
                                  _filters = filters;
                                });
                                _fetchProperties(isRefresh: true);
                              }
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: _filters != null && !_filters!.isEmpty ? accentBlue.withOpacity(0.1) : Theme.of(context).colorScheme.surface,
                                border: Border.all(color: _filters != null && !_filters!.isEmpty ? accentBlue : Theme.of(context).colorScheme.outlineVariant),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                type,
                                style: GoogleFonts.inter(
                                  color: _filters != null && !_filters!.isEmpty ? accentBlue : Theme.of(context).colorScheme.onSurface,
                                  fontWeight: _filters != null && !_filters!.isEmpty ? FontWeight.w600 : FontWeight.w500,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Divider(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5), height: 1),
                const SizedBox(height: 12),
                _isLoading 
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Finding matching homes..',
                        style: GoogleFonts.inter(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2, color: accentBlue),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_properties.length} Properties Found',
                        style: GoogleFonts.inter(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'in all locations',
                        style: GoogleFonts.inter(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          
          // Property List
          Expanded(
            child: _isLoading 
            ? ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                itemCount: 3,
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  return _buildSkeletonCard();
                },
              )
            : RefreshIndicator(
                  onRefresh: () => _fetchProperties(isRefresh: true),
                  child: ListView.separated(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: _properties.length + (_isFetchingMore ? 1 : 0),
                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      if (index == _properties.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24.0),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      return _buildPropertyCard(_properties[index]);
                    },
                  ),
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
                    onPressed: () async {
                      final filters = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => FilterScreen(initialFilters: _filters)),
                      );
                      if (filters != null && filters is PropertyFilters) {
                        setState(() {
                          _filters = filters;
                        });
                        _fetchProperties(isRefresh: true);
                      }
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
    if (_searchController.text.isNotEmpty) {
      chips.add(_buildAppliedFilterChip(_searchController.text, () {
        setState(() { _searchController.clear(); });
        _fetchProperties(isRefresh: true);
      }));
    }
    if (_filters != null && !_filters!.isEmpty) {
      for (final label in _filters!.activeLabels) {
        chips.add(_buildAppliedFilterChip(label, () {
          setState(() { _filters = null; });
          _fetchProperties(isRefresh: true);
        }));
      }
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

  Widget _buildSkeletonCard() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 180,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(width: 150, height: 12, decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(6))),
                    const SizedBox(height: 8),
                    Container(width: 200, height: 12, decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(6))),
                    const SizedBox(height: 16),
                    Container(width: 100, height: 12, decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(6))),
                  ],
                ),
                Container(width: 60, height: 12, decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(6))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyCard(Property property) {
    // Generate styling based on status
    Color statusColor = Colors.green;
    Color statusBgColor = const Color(0xFFE8F5E9);
    if (property.status.contains('CONSTRUCTION')) {
      statusColor = const Color(0xFFFBC02D);
      statusBgColor = const Color(0xFFFFF9C4);
    } else if (property.status.contains('NEW')) {
      statusColor = accentBlue;
      statusBgColor = accentBlue.withValues(alpha: 0.1);
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
                    property.status,
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
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: accentBlue,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  property.title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  property.location,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  property.specs,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                child: _buildPriceMarker('₹75L', false),
              ),
              Positioned(
                top: 180, right: 80,
                child: _buildPriceMarker('₹85L', false),
              ),
              Positioned(
                top: 250, left: 150,
                child: _buildPriceMarker('₹1.2Cr', true),
              ),
              Positioned(
                bottom: 250, left: 80,
                child: _buildPriceMarker('₹1.9Cr', false),
              ),
              
              // Bottom Card
              Positioned(
                bottom: 24,
                left: 16,
                right: 16,
                child: _properties.isNotEmpty 
                    ? _buildMapPropertyCard(_properties.first)
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
            'Swipe card above to browse ${_properties.length} properties in this area',
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
                    'Price — Low to High',
                    'Price — High to Low',
                    'Area — Smallest First',
                    'Area — Largest First'
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