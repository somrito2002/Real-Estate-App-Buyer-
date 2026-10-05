import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/enquiry_model.dart';
class EnquiryApiService {
  static const String _baseUrl = 'https://api.prodalal.com/api';

  static Future<Map<String, dynamic>> submitEnquiry({
    required String propertyId,
    required String partnerId,
    required String name,
    required String email,
    required String phone,
    required String message,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';

    if (token.isEmpty) {
      throw Exception('Authentication required. Please provide a valid token.');
    }

    final body = {
      'propertyId': propertyId,
      'partnerId': partnerId,
      'name': name,
      'email': email,
      'phone': phone,
      'message': message,
    };

    final response = await http.post(
      Uri.parse('$_baseUrl/enquiries'),
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
      String errorMessage = 'Failed to submit enquiry.';
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
  static Future<List<Enquiry>> getEnquiries({
    String? partnerId,
    String? userId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';

    if (token.isEmpty) {
      throw Exception('401:Authentication required. Please provide a valid token.');
    }

    String url = '$_baseUrl/enquiries';
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
      final List enquiriesData = data['enquiries'] ?? [];
      return enquiriesData.map((e) => Enquiry.fromJson(e)).toList();
    } else if (response.statusCode == 401) {
      throw Exception('401:Authentication required. Please provide a valid token.');
    } else if (response.statusCode == 403) {
      throw Exception('403:You are not authorized to view these enquiries.');
    } else {
      String errorMessage = 'Failed to fetch enquiries.';
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
}
