import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/property_model.dart';
import 'compare_properties_screen.dart';
import 'property_details_screen.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import 'widgets/remove_shortlist_dialog.dart';
import 'package:easy_localization/easy_localization.dart';

class SavedScreen extends StatefulWidget {
  final VoidCallback? onExplore;
  final VoidCallback? onChange;
  const SavedScreen({super.key, this.onExplore, this.onChange});

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  static const Color accentBlue = Color(0xFF4B85F0);
  static const Color accentRed = Color(0xFFEF4444);

  bool _isLoggedIn = false;
  bool _isLoading = true;

  // Multi-select state
  bool _isSelecting = false;
  final Set<int> _selectedIndices = {};

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
        _isLoading = false;
      });
    }
  }

  List<Property> get _savedProperties =>
      mockProperties.where((p) => p.isFavorite).toList();

  void _enterSelectMode(int index) {
    HapticFeedback.mediumImpact();
    setState(() {
      _isSelecting = true;
      _selectedIndices.add(index);
    });
  }

  void _exitSelectMode() {
    setState(() {
      _isSelecting = false;
      _selectedIndices.clear();
    });
  }

  void _toggleSelection(int index) {
    setState(() {
      if (_selectedIndices.contains(index)) {
        _selectedIndices.remove(index);
        if (_selectedIndices.isEmpty) _isSelecting = false;
      } else {
        _selectedIndices.add(index);
      }
    });
  }

  Future<void> _removeSelected(List<Property> saved) async {
    final toRemove = _selectedIndices.map((i) => saved[i]).toList();
    // Show dialog only if single item; bulk remove directly for multiple
    if (toRemove.length == 1) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (_) => RemoveShortlistDialog(propertyTitle: toRemove.first.title),
      );
      if (confirm != true) return;
    }
    setState(() {
      for (final p in toRemove) {
        p.isFavorite = false;
      }
      _exitSelectMode();
      widget.onChange?.call();
    });
  }

  Future<void> _removeAll(List<Property> saved) async {
    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'saved.remove_all_title'.tr(),
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        content: Text(
          'saved.remove_all_desc'.tr(namedArgs: {'count': saved.length.toString()}),
          style: GoogleFonts.inter(fontSize: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('saved.cancel'.tr(), style: GoogleFonts.inter(color: accentBlue)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('saved.remove_all'.tr(), style: GoogleFonts.inter(color: accentRed, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      setState(() {
        for (final p in saved) { p.isFavorite = false; }
        _exitSelectMode();
        widget.onChange?.call();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    Widget content = _savedProperties.isNotEmpty || _isLoggedIn 
        ? _buildSavedList() 
        : _buildGuestView();

    if (Navigator.canPop(context)) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            _savedProperties.isEmpty
                ? 'Shortlisted Properties'
                : 'Shortlisted Properties (${_savedProperties.length})',
            style: GoogleFonts.inter(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          backgroundColor: Theme.of(context).colorScheme.surface,
          elevation: 0,
          scrolledUnderElevation: 0,
          iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurface),
          actions: [
            if (_savedProperties.isNotEmpty)
              TextButton(
                onPressed: () => _removeAll(_savedProperties),
                child: Text(
                  'Clear All',
                  style: GoogleFonts.inter(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: content,
      );
    }

    return content;
  }

  // ── GUEST VIEW ──────────────────────────────────────────────────────────────
  Widget _buildGuestView() {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(color: Colors.red.shade50, shape: BoxShape.circle),
              child: Icon(Icons.favorite, color: Colors.red.shade400, size: 40),
            ),
            const SizedBox(height: 24),
            Text('saved.save_to_shortlist'.tr(),
                style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface)),
            const SizedBox(height: 12),
            Text(
              'saved.sign_in_desc'.tr(),
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurfaceVariant, height: 1.5),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity, height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => const LoginScreen()))
                    .then((_) => _checkLoginStatus()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentBlue, foregroundColor: Colors.white, elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('saved.sign_in'.tr(),
                    style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity, height: 50,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => const RegisterScreen()))
                    .then((_) => _checkLoginStatus()),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.onSurface,
                  side: BorderSide(color: Theme.of(context).colorScheme.outline),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('saved.create_account'.tr(),
                    style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 100), // Bottom padding for translucent nav bar
          ],
        ),
      ),
      ),
    );
  }

  // ── SAVED LIST ───────────────────────────────────────────────────────────────
  Widget _buildSavedList() {
    final saved = _savedProperties;

    if (saved.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  shape: BoxShape.circle,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(Icons.favorite_border, size: 48, color: Color(0xFF4B85F0)),
                    Transform.rotate(
                      angle: -0.785398, // -45 degrees in radians
                      child: Container(
                        width: 56,
                        height: 2.5,
                        color: const Color(0xFF4B85F0),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'No Properties',
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Properties you shortlist will appear here.\nStart exploring to find your perfect property.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  height: 1.5,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    if (widget.onExplore != null) {
                      widget.onExplore!();
                    } else if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4B85F0),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Explore Properties',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 100), // Bottom padding for translucent nav bar
            ],
          ),
        ),
        ),
      );
    }

    return Column(
      children: [
        // ── PROPERTY LIST ──

        // ── PROPERTY LIST ──
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            itemCount: saved.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final property = saved[index];
              final isSelected = _selectedIndices.contains(index);
              return _buildPropertyCard(property, index, isSelected, saved);
            },
          ),
        ),

        // ── BOTTOM ACTION BAR ──
        _buildBottomBar(saved),
      ],
    );
  }

  Widget _buildHeader(List<Property> saved) {
    if (!_isSelecting) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(bottom: BorderSide(color: Theme.of(context).colorScheme.outlineVariant)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _exitSelectMode,
            child: const Icon(Icons.close, size: 22),
          ),
          const SizedBox(width: 12),
          Text(
            'saved.selected_count'.tr(namedArgs: {'count': _selectedIndices.length.toString()}),
            style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              setState(() {
                if (_selectedIndices.length == saved.length) {
                  _selectedIndices.clear();
                } else {
                  _selectedIndices.addAll(
                      List.generate(saved.length, (i) => i));
                }
              });
            },
            child: Text(
              _selectedIndices.length == saved.length ? 'saved.deselect_all'.tr() : 'saved.select_all'.tr(),
              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600,
                  color: accentBlue),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyCard(Property property, int index, bool isSelected, List<Property> saved) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── IMAGE with checkbox ──
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 100,
                    height: 100,
                    child: _buildPropertyImage(context, property),
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: GestureDetector(
                    onTap: () => _toggleSelection(index),
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected ? accentBlue : Colors.white,
                        border: Border.all(
                          color: isSelected ? accentBlue : Theme.of(context).colorScheme.outline,
                          width: 1.5,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, size: 16, color: Colors.white)
                          : null,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),

            // ── DETAILS ──
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                      GestureDetector(
                        onTap: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (_) => RemoveShortlistDialog(
                                propertyTitle: property.title),
                          );
                          if (confirm == true) {
                            setState(() {
                              property.isFavorite = false;
                              if (isSelected) _selectedIndices.remove(index);
                              widget.onChange?.call();
                            });
                          }
                        },
                        child: const Icon(Icons.favorite_border,
                            color: accentRed, size: 22),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    property.title,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    property.specs,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          property.location,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (_) => RemoveShortlistDialog(
                                propertyTitle: property.title),
                          );
                          if (confirm == true) {
                            setState(() {
                              property.isFavorite = false;
                              if (isSelected) _selectedIndices.remove(index);
                              widget.onChange?.call();
                            });
                          }
                        },
                        child: Text(
                          'Remove',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: accentRed,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPropertyImage(BuildContext context, Property property) {
    if (property.imageUrl.startsWith('assets/')) {
      return Image.asset(property.imageUrl, fit: BoxFit.cover,
          errorBuilder: (context, error, stack) => _imagePlaceholder(context));
    }
    return Image.network(property.imageUrl, fit: BoxFit.cover,
        errorBuilder: (context, error, stack) => _imagePlaceholder(context));
  }

  Widget _imagePlaceholder(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Icon(Icons.home_outlined, color: Theme.of(context).colorScheme.onSurfaceVariant, size: 32),
    );
  }

  // ── BOTTOM ACTION BAR ────────────────────────────────────────────────────────
  Widget _buildBottomBar(List<Property> saved) {
    final bool canCompare = _selectedIndices.length == 2;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: () => _removeAll(saved),
              style: OutlinedButton.styleFrom(
                foregroundColor: accentRed,
                side: const BorderSide(color: accentRed),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Remove All',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: canCompare
                  ? () {
                      final List<int> sortedIndices = _selectedIndices.toList()..sort();
                      final p1 = saved[sortedIndices[0]];
                      final p2 = saved[sortedIndices[1]];
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => ComparePropertiesScreen(prop1: p1, prop2: p2),
                      ));
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: accentBlue,
                disabledBackgroundColor: accentBlue.withAlpha(128),
                foregroundColor: Colors.white,
                disabledForegroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Compare Properties',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
