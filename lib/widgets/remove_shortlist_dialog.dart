import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RemoveShortlistDialog extends StatelessWidget {
  final String propertyTitle;

  const RemoveShortlistDialog({super.key, required this.propertyTitle});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF0F0),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.heart_broken_outlined,
                  color: Color(0xFFEF4444), // Red color
                  size: 32,
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Title
            Text(
              'Remove from Shortlist?',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            
            // Subtitle
            Text(
              'Are you sure you want to remove $propertyTitle from your saved properties?',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFF6B7280), // Gray color
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            
            // Remove Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(true); // Return true to confirm removal
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF4444), // Red
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Remove Property',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            
            // Cancel Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pop(false); // Return false to cancel
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF4B85F0), // Blue text
                  side: const BorderSide(color: Color(0xFF4B85F0), width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
