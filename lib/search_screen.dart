import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'filter_screen.dart';
import 'buy_properties_screen.dart';
import 'models/property_model.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  static const Color accentBlue = Color(0xFF4B85F0);
  String _selectedCategory = 'Buy';
  
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
      onTap: () {
        _searchController.text = text;
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
        // In a fully wired app, we might pass the selected property or filter to BuyPropertiesScreen
        Navigator.push(context, MaterialPageRoute(builder: (_) => const BuyPropertiesScreen()));
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
                  color: Theme.of(context).colorScheme.surfaceVariant,
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
          onPressed: () => Navigator.pop(context),
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
          child: Container(color: Theme.of(context).colorScheme.surfaceVariant, height: 1),
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
                          onSubmitted: (value) {
                            if (value.isNotEmpty) {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const BuyPropertiesScreen()));
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
                      InkWell(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const FilterScreen()));
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
                        Text(
                          'Recent Searches',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildRecentSearchItem('3 BHK in Durg'),
                        _buildRecentSearchItem('2 BHK Apartments near Railway Station'),
                        _buildRecentSearchItem('Commercial space in Bhilai'),
                        
                        const SizedBox(height: 24),
                        
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
