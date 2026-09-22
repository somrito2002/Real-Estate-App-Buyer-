import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'reviews_screen.dart'; // To access ReviewItem

class EditReviewScreen extends StatefulWidget {
  final ReviewItem review;

  const EditReviewScreen({super.key, required this.review});

  @override
  State<EditReviewScreen> createState() => _EditReviewScreenState();
}

class _EditReviewScreenState extends State<EditReviewScreen> {
  late double _rating;
  late TextEditingController _reviewController;

  @override
  void initState() {
    super.initState();
    _rating = widget.review.rating;
    _reviewController = TextEditingController(text: widget.review.reviewText);
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Edit Review',
          style: GoogleFonts.inter(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.review.propertyName,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1D1E),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.location_on, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  widget.review.location,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Divider(color: Colors.grey.shade200),
            const SizedBox(height: 24),
            Text(
              'Your Rating',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1D1E),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                ...List.generate(5, (index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _rating = index + 1.0;
                      });
                    },
                    child: Icon(
                      index < _rating ? Icons.star : Icons.star_border,
                      color: const Color(0xFF9E9E9E), // Grey stars based on design, or maybe they should be yellow when active? Design shows grey stars with "0". Let's stick to the grey style from the design.
                      size: 28,
                    ),
                  );
                }),
                const SizedBox(width: 8),
                Text(
                  _rating.toInt().toString(),
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1D1E),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Your Review',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1D1E),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: TextField(
                controller: _reviewController,
                maxLines: 5,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: const Color(0xFF1A1D1E),
                ),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(12),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  // Handle update review logic
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A85F6),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Update Review',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'Cancel',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF4A85F6),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () {
                  // Handle delete review logic
                  Navigator.pop(context);
                },
                child: Text(
                  'Delete Review',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFEA4335), // Red color
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
