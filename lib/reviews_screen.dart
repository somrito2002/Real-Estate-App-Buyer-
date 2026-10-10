import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'edit_review_screen.dart';
import 'services/visit_api_service.dart';

class ReviewItem {
  final String id;
  final String propertyName;
  final String location;
  final String date;
  final double rating;
  final String reviewText;

  ReviewItem({
    required this.id,
    required this.propertyName,
    required this.location,
    required this.date,
    required this.rating,
    required this.reviewText,
  });
}

class ReviewsScreen extends StatefulWidget {
  const ReviewsScreen({super.key});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  List<ReviewItem> _reviews = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchReviews();
  }

  Future<void> _fetchReviews() async {
    try {
      final rawReviews = await VisitApiService.getReviews();
      
      List<ReviewItem> mapped = rawReviews.map((r) {
        String propName = 'Unknown Property';
        String loc = 'Unknown Location';
        
        if (r['property'] != null) {
          propName = r['property']['title'] ?? propName;
          loc = r['property']['city'] ?? loc;
        }

        DateTime dateObj = DateTime.now();
        if (r['createdAt'] != null) {
          dateObj = DateTime.tryParse(r['createdAt'].toString()) ?? dateObj;
        }

        return ReviewItem(
          id: r['id']?.toString() ?? r['_id']?.toString() ?? '',
          propertyName: propName,
          location: loc,
          date: DateFormat('dd MMM yyyy').format(dateObj),
          rating: (r['rating'] is num) ? (r['rating'] as num).toDouble() : 0.0,
          reviewText: r['comment']?.toString() ?? '',
        );
      }).toList();

      if (mounted) {
        setState(() {
          _reviews = mapped;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to load reviews: $e', style: GoogleFonts.inter()),
          backgroundColor: Colors.red.shade700,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double avgRating = 0.0;
    if (_reviews.isNotEmpty) {
      double sum = 0;
      for (var r in _reviews) {
        sum += r.rating;
      }
      avgRating = sum / _reviews.length;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFFAFAFA);
    final cardBgColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final summaryBgColor = isDark ? const Color(0xFF1A2A4A) : const Color(0xFFF0F5FF);
    final summaryBorderColor = isDark ? const Color(0xFF2A3A6A) : const Color(0xFFD3E1FA);
    final borderColor = isDark ? Colors.white12 : const Color(0xFFEEEEEE);
    final titleColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final subtitleColor = isDark ? Colors.white70 : const Color(0xFF666666);
    final dateColor = isDark ? Colors.white54 : const Color(0xFF999999);
    final accentBlue = const Color(0xFF4B85F0);
    final starColor = const Color(0xFFFFB400);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: titleColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'reviews.title'.tr(),
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: titleColor,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: summaryBgColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: summaryBorderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'reviews.my_reviews_summary'.tr(),
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: accentBlue,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _reviews.isEmpty && _isLoading ? '-' : _reviews.length.toString(),
                            style: GoogleFonts.inter(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: titleColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'reviews.total_reviews_submitted'.tr(),
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: subtitleColor,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              ...List.generate(5, (index) {
                                if (index < avgRating.floor()) {
                                  return Icon(Icons.star, color: starColor, size: 14);
                                } else if (index == avgRating.floor() && avgRating - avgRating.floor() >= 0.5) {
                                  return Icon(Icons.star_half, color: starColor, size: 14);
                                } else {
                                  return Icon(Icons.star_border, color: starColor, size: 14);
                                }
                              }),
                              const SizedBox(width: 4),
                              Text(
                                _isLoading && _reviews.isEmpty ? '-' : avgRating.toStringAsFixed(1),
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: titleColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'reviews.average_rating'.tr(),
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: subtitleColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'reviews.your_reviews'.tr(),
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: titleColor,
              ),
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 50),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_reviews.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 50),
                child: Center(
                  child: Text(
                    'No reviews found.',
                    style: GoogleFonts.inter(color: subtitleColor),
                  ),
                ),
              )
            else
              ..._reviews.map((review) => _buildReviewCard(
                    review: review,
                    cardBgColor: cardBgColor,
                    borderColor: borderColor,
                    titleColor: titleColor,
                    subtitleColor: subtitleColor,
                    dateColor: dateColor,
                    starColor: starColor,
                    accentBlue: accentBlue,
                  )),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewCard({
    required ReviewItem review,
    required Color cardBgColor,
    required Color borderColor,
    required Color titleColor,
    required Color subtitleColor,
    required Color dateColor,
    required Color starColor,
    required Color accentBlue,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.propertyName,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 12, color: subtitleColor),
                        const SizedBox(width: 4),
                        Text(
                          review.location,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: subtitleColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Text(
                review.date,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: dateColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              ...List.generate(5, (index) {
                if (index < review.rating.floor()) {
                  return Icon(Icons.star, color: starColor, size: 14);
                } else if (index < review.rating) {
                  return Icon(Icons.star_half, color: starColor, size: 14);
                } else {
                  return Icon(Icons.star_border, color: starColor, size: 14);
                }
              }),
              const SizedBox(width: 6),
              Text(
                review.rating.toStringAsFixed(1),
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: titleColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            review.reviewText,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: subtitleColor,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Divider(height: 1, color: borderColor),
          const SizedBox(height: 12),
          Row(
            children: [
              GestureDetector(
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => EditReviewScreen(review: review)),
                  );
                  if (result == true) {
                    setState(() => _isLoading = true);
                    _fetchReviews();
                  }
                },
                child: Text(
                  'reviews.edit'.tr(),
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: accentBlue,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  height: 14,
                  width: 1,
                  color: borderColor,
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: Text(
                  'reviews.view_property'.tr(),
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: accentBlue,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
