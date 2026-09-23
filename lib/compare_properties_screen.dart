import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';
import 'models/property_model.dart';

class ComparePropertiesScreen extends StatelessWidget {
  final Property prop1;
  final Property prop2;

  const ComparePropertiesScreen({
    super.key,
    required this.prop1,
    required this.prop2,
  });

  // Helper to extract area from specs (e.g. "2,215 sq.ft • 3 BHK • 3 Baths")
  String _extractArea(String specs) {
    if (specs.contains('sq.ft') || specs.contains('sqft')) {
      return specs.split('•').first.trim().replaceAll('sq.ft', 'sqft');
    }
    return 'N/A';
  }

  // Helper to generate a mock rate/sqft
  String _generateRate(Property prop) {
    // Generate a consistent dummy rate based on string hash
    final random = Random(prop.title.hashCode);
    final rate = 8000 + random.nextInt(7000);
    return '₹${rate.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
  }

  // Helper to generate a mock furnish status
  String _generateFurnish(Property prop) {
    final statuses = ['Semi', 'Fully', 'Unfurnished'];
    final random = Random(prop.title.hashCode);
    return statuses[random.nextInt(statuses.length)];
  }

  // Helper to generate mock boolean
  bool _generateBool(Property prop, int offset) {
    final random = Random(prop.title.hashCode + offset);
    return random.nextBool();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Theme.of(context).colorScheme.onSurface, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Compare Properties',
          style: GoogleFonts.inter(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Theme.of(context).colorScheme.outlineVariant, height: 1),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Header Row: Criteria + 2 Property Cards
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: Text(
                        'CRITERIA',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: _buildPropertyHeaderCard(context, prop1),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 3,
                    child: _buildPropertyHeaderCard(context, prop2),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Comparison Table Rows
              _buildTableRow(context, 'BHK', prop1.type, prop2.type, isStriped: false),
              _buildTableRow(context, 'Area', _extractArea(prop1.specs), _extractArea(prop2.specs), isStriped: true),
              _buildTableRow(context, 'Rate/sqft', _generateRate(prop1), _generateRate(prop2), isStriped: false),
              _buildTableRow(context, 'Furnish', _generateFurnish(prop1), _generateFurnish(prop2), isStriped: true),
              _buildBoolTableRow(context, 'Pool', _generateBool(prop1, 1), _generateBool(prop2, 1), isStriped: false),
              _buildBoolTableRow(context, 'Power', _generateBool(prop1, 2), _generateBool(prop2, 2), isStriped: true),
              
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPropertyHeaderCard(BuildContext context, Property property) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.onSurface.withAlpha(10),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
            child: property.imageUrl.startsWith('assets/')
                ? Image.asset(property.imageUrl, height: 70, width: double.infinity, fit: BoxFit.cover)
                : Image.network(property.imageUrl, height: 70, width: double.infinity, fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  property.price,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF4B85F0), // accentBlue
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  property.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
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
    );
  }

  Widget _buildTableRow(BuildContext context, String criteria, String val1, String val2, {required bool isStriped}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: isStriped ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05) : Colors.transparent,
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              criteria,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              val1,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Text(
              val2,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBoolTableRow(BuildContext context, String criteria, bool val1, bool val2, {required bool isStriped}) {
    Widget buildIcon(bool val) {
      return val
          ? const Icon(Icons.check, color: Color(0xFF10B981), size: 18) // Green check
          : const Icon(Icons.close, color: Color(0xFFEF4444), size: 18); // Red cross
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: isStriped ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05) : Colors.transparent,
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              criteria,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Center(child: buildIcon(val1)),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Center(child: buildIcon(val2)),
          ),
        ],
      ),
    );
  }
}
