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

class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key});

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
    });
  }

  Future<void> _removeAll(List<Property> saved) async {
    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Remove All?',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        content: Text(
          'This will remove all ${saved.length} shortlisted properties from your shortlist.',
          style: GoogleFonts.inter(fontSize: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: GoogleFonts.inter(color: accentBlue)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Remove All', style: GoogleFonts.inter(color: accentRed, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      setState(() {
        for (final p in saved) { p.isFavorite = false; }
        _exitSelectMode();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    Widget content = !_isLoggedIn ? _buildGuestView() : _buildSavedList();

    if (Navigator.canPop(context)) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Shortlisted Properties',
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
            Text('Save to Shortlist',
                style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface)),
            const SizedBox(height: 12),
            Text(
              'Please sign in or create an account to save properties to your shortlist and monitor price drops.',
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
                child: Text('Sign In',
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
                child: Text('Create Account',
                    style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── SAVED LIST ───────────────────────────────────────────────────────────────
  Widget _buildSavedList() {
    final saved = _savedProperties;

    if (saved.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bookmark_border_rounded, size: 72,
                color: Theme.of(context).colorScheme.outlineVariant),
            const SizedBox(height: 16),
            Text('No Shortlisted Properties',
                style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface)),
            const SizedBox(height: 8),
            Text('Tap the heart icon on any property to save it here.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ],
        ),
      );
    }

    return Column(
      children: [
        // ── HEADER ──
        _buildHeader(saved),

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
            '${_selectedIndices.length} Selected',
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
              _selectedIndices.length == saved.length ? 'Deselect All' : 'Select All',
              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600,
                  color: accentBlue),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyCard(Property property, int index, bool isSelected, List<Property> saved) {
    return GestureDetector(
      onTap: () {
        if (_isSelecting) {
          _toggleSelection(index);
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => PropertyDetailsScreen(property: property)),
          ).then((_) => setState(() {}));
        }
      },
      onLongPress: () {
        if (!_isSelecting) {
          _enterSelectMode(index);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected
              ? accentBlue.withAlpha(12)
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? accentBlue : Theme.of(context).colorScheme.outlineVariant,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── IMAGE with selection indicator ──
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      width: 100,
                      height: 100,
                      child: _buildPropertyImage(context, property),
                    ),
                  ),
                  // Selection circle / check
                  Positioned(
                    top: 6, left: 6,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: _isSelecting
                          ? Container(
                              key: const ValueKey('check'),
                              width: 24, height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected ? accentBlue : Theme.of(context).colorScheme.surface.withAlpha(220),
                                border: Border.all(
                                  color: isSelected ? accentBlue : Theme.of(context).colorScheme.outline,
                                  width: 1.5,
                                ),
                              ),
                              child: isSelected
                                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                                  : null,
                            )
                          : const SizedBox.shrink(key: ValueKey('empty')),
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
                      children: [
                        Expanded(
                          child: Text(
                            property.price,
                            style: GoogleFonts.inter(
                              fontSize: 16, fontWeight: FontWeight.bold, color: accentBlue),
                          ),
                        ),
                        // Heart icon
                        GestureDetector(
                          onTap: _isSelecting
                              ? null
                              : () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (_) => RemoveShortlistDialog(
                                        propertyTitle: property.title),
                                  );
                                  if (confirm == true) {
                                    setState(() => property.isFavorite = false);
                                  }
                                },
                          child: Icon(Icons.favorite,
                              color: _isSelecting ? Theme.of(context).colorScheme.outline : accentRed,
                              size: 20),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      property.title,
                      style: GoogleFonts.inter(
                        fontSize: 14, fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onSurface),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      property.specs,
                      style: GoogleFonts.inter(fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            property.location,
                            style: GoogleFonts.inter(fontSize: 12,
                                color: Theme.of(context).colorScheme.onSurfaceVariant),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        GestureDetector(
                          onTap: _isSelecting
                              ? null
                              : () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (_) => RemoveShortlistDialog(
                                        propertyTitle: property.title),
                                  );
                                  if (confirm == true) {
                                    setState(() => property.isFavorite = false);
                                  }
                                },
                          child: Text(
                            'Remove',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _isSelecting ? Theme.of(context).colorScheme.outline : accentRed,
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
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant)),
      ),
      child: _isSelecting && _selectedIndices.isNotEmpty
          ? Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _removeSelected(saved),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: accentRed,
                      side: const BorderSide(color: accentRed),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      'Remove (${_selectedIndices.length})',
                      style: GoogleFonts.inter(
                          fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _selectedIndices.length == 2
                        ? () {
                            final p1 = saved[_selectedIndices.elementAt(0)];
                            final p2 = saved[_selectedIndices.elementAt(1)];
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => ComparePropertiesScreen(prop1: p1, prop2: p2),
                            ));
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentBlue,
                      disabledBackgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                      foregroundColor: Colors.white,
                      disabledForegroundColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('Compare Properties',
                        style: GoogleFonts.inter(
                            fontSize: 15, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            )
          : Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _removeAll(saved),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: accentRed,
                      side: const BorderSide(color: accentRed),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('Remove All',
                        style: GoogleFonts.inter(
                            fontSize: 15, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _selectedIndices.length == 2
                        ? () {
                            final p1 = saved[_selectedIndices.elementAt(0)];
                            final p2 = saved[_selectedIndices.elementAt(1)];
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => ComparePropertiesScreen(prop1: p1, prop2: p2),
                            ));
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentBlue,
                      disabledBackgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                      foregroundColor: Colors.white,
                      disabledForegroundColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('Compare Properties',
                        style: GoogleFonts.inter(
                            fontSize: 15, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
    );
  }
}
