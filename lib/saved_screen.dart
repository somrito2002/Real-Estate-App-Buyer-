import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/property_model.dart';


import 'login_screen.dart';
import 'register_screen.dart';
import 'widgets/remove_shortlist_dialog.dart';
import 'package:easy_localization/easy_localization.dart';
import 'services/wishlist_api_service.dart';
import 'property_details_screen.dart';
import 'property_details_loader.dart';

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


  List<Property> _apiSavedProperties = [];

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final loggedIn = prefs.getBool('isLoggedIn') ?? false;
    
    if (mounted) {
      setState(() {
        _isLoggedIn = loggedIn;
      });
    }

    if (loggedIn) {
      _loadWishlist();
    } else {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadWishlist() async {
    if (!mounted) return;
    try {
      final properties = await WishlistApiService.getWishlist();
      if (mounted) {
        setState(() {
          _apiSavedProperties = properties;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        final msg = e.toString().contains('Invalid or expired token') || e.toString().contains('Authentication required')
            ? 'Session expired. Please login again.'
            : 'Failed to load wishlist. Please try again.';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      }
    }
  }

  List<Property> get _savedProperties => _apiSavedProperties;


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
      final toRemove = List<Property>.from(saved);
      // Optimistically update UI
      setState(() {
        _apiSavedProperties.clear();
      });
      
      // Execute all toggle requests concurrently
      try {
        await Future.wait(
          toRemove.map((p) => WishlistApiService.toggleWishlist(p.id))
        );
        
        // Notify parent only after backend has finished deleting
        if (mounted) {
          widget.onChange?.call();
        }
      } catch (e) {
        debugPrint('[Wishlist Debug] Remove All error: $e');
      }
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
              return GestureDetector(
                onTap: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(
                    builder: (_) => PropertyDetailsLoader(
                      propertyId: property.id,
                    ),
                  ))
                      .then((_) {
                    // Refresh the wishlist when returning from property details
                    // to pick up any changes made there.
                    if (mounted) {
                      setState(() {
                        _isLoading = true;
                      });
                      _loadWishlist();
                    }
                  });
                },
                child: _buildPropertyCard(property, index, saved),
              );
            },
          ),
        ),
        
        // Bottom Action Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _removeAll(saved),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text('Remove All', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Compare functionality coming soon')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4B85F0),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text('Compare Properties', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),

      ],
    );
  }


  Widget _buildPropertyCard(Property property, int index, List<Property> saved) {
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
              ],
            ),
            const SizedBox(width: 12),

            // ── DETAILS ──
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    property.price,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF4B85F0), // accentBlue
                    ),
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
                            // Optimistic remove locally first to make UI feel fast
                            setState(() {
                              _apiSavedProperties.remove(property);
                            });
                            
                            try {
                              // Await the backend deletion BEFORE triggering the parent refresh
                              await WishlistApiService.toggleWishlist(property.id);
                              
                              // Now it's safe to notify the parent
                              if (mounted) {
                                widget.onChange?.call();
                              }
                            } catch (e) {
                              // Rollback on failure
                              if (mounted) {
                                setState(() {
                                  _apiSavedProperties.add(property);
                                  widget.onChange?.call();
                                });
                              }
                            }
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


}
