import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/visit_model.dart';

class VisitApiService {
  static const String _baseUrl = 'https://api.prodalal.com/api';

  static Future<List<Visit>> getVisits({
    String? partnerId,
    String? userId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';
    
    // Automatically fallback to token parsing if userId is not passed
    if (userId == null && partnerId == null && token.isNotEmpty) {
      String fallbackId = prefs.getString('cached_userId') ?? '';
      if (fallbackId.isEmpty) {
        try {
          final parts = token.split('.');
          if (parts.length == 3) {
            final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
            final data = json.decode(payload);
            fallbackId = (data['id'] ?? data['_id'] ?? data['userId'] ?? data['sub'] ?? '').toString();
            if (fallbackId.isNotEmpty) {
              await prefs.setString('cached_userId', fallbackId);
            }
          }
        } catch (_) {}
      }
      
      if (fallbackId.isEmpty) {
        try {
          final profileRes = await http.get(
            Uri.parse('$_baseUrl/auth/user'),
            headers: {'Authorization': 'Bearer $token'},
          ).timeout(const Duration(seconds: 10));
          if (profileRes.statusCode == 200) {
            final data = json.decode(profileRes.body);
            fallbackId = (data['id'] ?? data['userId'] ?? data['_id'] ?? '').toString();
            if (fallbackId.isNotEmpty) {
              await prefs.setString('cached_userId', fallbackId);
            }
          }
        } catch (_) {}
      }
      
      if (fallbackId.isNotEmpty) {
        userId = fallbackId;
      }
    }

    if (token.isEmpty) {
      throw Exception('401:Authentication required. Please provide a valid token.');
    }

    String url = '$_baseUrl/visits';
    if (partnerId != null) {
      url += '?partnerId=$partnerId';
    } else if (userId != null) {
      url += '?userId=$userId';
    }

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
      },
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List visitsData = data['visits'] ?? [];
      return visitsData.map((e) => Visit.fromJson(e)).toList();
    } else if (response.statusCode == 401) {
      throw Exception('401:Authentication required. Please provide a valid token.');
    } else if (response.statusCode == 403) {
      throw Exception('403:You are not authorized to view these visits.');
    } else {
      String errorMessage = 'Failed to fetch visits.';
      try {
        final data = json.decode(response.body);
        if (data['error'] != null) {
          errorMessage = data['error'].toString();
        } else if (data['message'] != null) {
          errorMessage = data['message'].toString();
        }
      } catch (_) {}
      throw Exception('${response.statusCode}:$errorMessage');
    }
  }

  static Future<Map<String, dynamic>> updateVisitStatus({
    required String visitId,
    required String status,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';

    if (token.isEmpty) {
      throw Exception('401:Authentication required. Please provide a valid token.');
    }

    final response = await http.patch(
      Uri.parse('$_baseUrl/visits/$visitId/status'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({'status': status}),
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 401) {
      throw Exception('401:Authentication required. Please provide a valid token.');
    } else {
      String errorMessage = 'Failed to update visit status.';
      try {
        final data = json.decode(response.body);
        if (data['error'] != null) {
          errorMessage = data['error'].toString();
        } else if (data['message'] != null) {
          errorMessage = data['message'].toString();
        }
      } catch (_) {}
      throw Exception('${response.statusCode}:$errorMessage');
    }
  }

  static Future<Map<String, dynamic>> scheduleVisit({
    required String propertyId,
    required String partnerId,
    String? userId,
    required String name,
    required String email,
    required String phone,
    required String date,
    required String time,
    String? requirements,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';

    if (token.isEmpty) {
      throw Exception('401:Authentication required. Please provide a valid token.');
    }

    final Map<String, dynamic> body = {
      'propertyId': propertyId,
      'partnerId': partnerId,
      if (userId != null && userId.isNotEmpty) 'userId': userId,
      'name': name,
      'email': email,
      'phone': phone,
      'date': date,
      'time': time,
      if (requirements != null && requirements.isNotEmpty) 'requirements': requirements,
    };

    final response = await http.post(
      Uri.parse('$_baseUrl/visits'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(body),
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else if (response.statusCode == 401) {
      throw Exception('401:Authentication required. Please provide a valid token.');
    } else {
      String errorMessage = 'Failed to schedule visit.';
      try {
        final data = json.decode(response.body);
        if (data['error'] != null) {
          errorMessage = data['error'].toString();
        } else if (data['message'] != null) {
          errorMessage = data['message'].toString();
        }
      } catch (_) {}
      throw Exception('${response.statusCode}:$errorMessage');
    }
  }

  static Future<String> generateOtp(String visitId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';

    if (token.isEmpty) {
      throw Exception('401:Authentication required. Please provide a valid token.');
    }

    final response = await http.post(
      Uri.parse('$_baseUrl/visits/$visitId/generate-otp'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = json.decode(response.body);
      return data['otp']?.toString() ?? '';
    } else if (response.statusCode == 401) {
      throw Exception('401:Authentication required. Please provide a valid token.');
    } else {
      String errorMessage = 'Failed to generate OTP.';
      try {
        final data = json.decode(response.body);
        if (data['error'] != null) {
          errorMessage = data['error'].toString();
        } else if (data['message'] != null) {
          errorMessage = data['message'].toString();
        }
      } catch (_) {}
      throw Exception('${response.statusCode}:$errorMessage');
    }
  }

  static Future<void> submitReview({
    required String propertyId,
    required int rating,
    required String comment,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';
    final userId = prefs.getString('cached_userId') ?? '';

    if (token.isEmpty) {
      throw Exception('401:Authentication required. Please provide a valid token.');
    }

    final body = {
      'propertyId': propertyId,
      'userId': userId,
      'rating': rating,
      'comment': comment,
    };

    final response = await http.post(
      Uri.parse('$_baseUrl/reviews'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(body),
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode != 200 && response.statusCode != 201) {
      String errorMessage = 'Failed to submit review.';
      try {
        final data = json.decode(response.body);
        if (data['error'] != null) {
          errorMessage = data['error'].toString();
        } else if (data['message'] != null) {
          errorMessage = data['message'].toString();
        }
      } catch (_) {}
      throw Exception('${response.statusCode}:$errorMessage');
    }
  }

  static Future<List<dynamic>> getReviews() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';
    final userId = prefs.getString('cached_userId') ?? '';

    if (token.isEmpty) {
      throw Exception('401:Authentication required. Please provide a valid token.');
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/reviews?userId=$userId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      if (decoded is List) {
        return decoded;
      } else if (decoded is Map) {
        if (decoded.containsKey('data') && decoded['data'] is Map && decoded['data'].containsKey('reviews')) {
          return decoded['data']['reviews'] as List<dynamic>;
        } else if (decoded.containsKey('data') && decoded['data'] is List) {
          return decoded['data'] as List<dynamic>;
        } else if (decoded.containsKey('reviews') && decoded['reviews'] is List) {
          return decoded['reviews'] as List<dynamic>;
        }
      }
      throw Exception('Unexpected API response format');
    } else if (response.statusCode == 401) {
      throw Exception('401:Authentication required.');
    } else {
      throw Exception('Failed to fetch reviews: ${response.statusCode}');
    }
  }
}
