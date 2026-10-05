import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'wishlist_api_service.dart';
import '../models/user_profile.dart';

/// Centralized authentication API service for Pro Dalal.
///
/// Base URL: https://api.prodalal.com/api
/// All auth endpoints live under /auth/*.
///
/// SECURITY: Never log password, OTP, or JWT from this class.
class AuthApiService {
  static const String _baseUrl = 'https://api.prodalal.com/api/auth';

  /// The backend base URL (without /auth), used for constructing asset URLs
  /// such as profile pictures returned as relative paths.
  static const String backendBaseUrl = 'https://api.prodalal.com';

  // ─── Headers ─────────────────────────────────────────────────────────────

  /// Headers for public (unauthenticated) endpoints.
  static Map<String, String> get _publicHeaders => {
        'Content-Type': 'application/json',
      };

  /// Headers for protected (authenticated) endpoints.
  /// Reads the stored JWT from SharedPreferences.
  static Future<Map<String, String>> authHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // ─── Signup Flow ──────────────────────────────────────────────────────────

  /// Step 1 — Initialize signup and send OTP to the user's email.
  ///
  /// POST /api/auth/signup
  /// Returns: { "message": "OTP sent to email.", "userId": "..." }
  static Future<Map<String, dynamic>> signup({
    required String fullName,
    required String number,
    required String email,
    required String occupation,
  }) async {
    final response = await _post(
      '$_baseUrl/signup',
      body: {
        'fullName': fullName,
        'number': number,
        'email': email,
        'occupation': occupation,
      },
      headers: _publicHeaders,
    );
    return response;
  }

  /// Step 2 — Verify the OTP entered by the user.
  ///
  /// POST /api/auth/verify-otp
  /// OTP must remain a String (preserves leading zeros).
  static Future<Map<String, dynamic>> verifyOtp({
    required String userId,
    required String otp,
  }) async {
    return _post(
      '$_baseUrl/verify-otp',
      body: {
        'userId': userId,
        'otp': otp, // intentionally a String — never convert to int
      },
      headers: _publicHeaders,
    );
  }

  /// Step 3 (Resend) — Resend OTP to the user's email.
  ///
  /// POST /api/auth/send-otp
  static Future<Map<String, dynamic>> sendOtp({
    required String userId,
  }) async {
    return _post(
      '$_baseUrl/send-otp',
      body: {'userId': userId},
      headers: _publicHeaders,
    );
  }

  /// Step 4 — Set the user's password and complete signup.
  ///
  /// POST /api/auth/set-password
  /// Returns: { "token": "JWT", "user": { ... } }
  static Future<Map<String, dynamic>> setPassword({
    required String userId,
    required String password,
  }) async {
    return _post(
      '$_baseUrl/set-password',
      body: {
        'userId': userId,
        'password': password, // NEVER log this
      },
      headers: _publicHeaders,
    );
  }

  // ─── Login ────────────────────────────────────────────────────────────────

  /// Login with email or phone number + password.
  ///
  /// POST /api/auth/login
  /// [identifier] can be email OR phone number.
  /// Returns: { "token": "JWT", "user": { ... } }
  static Future<Map<String, dynamic>> login({
    required String identifier,
    required String password,
  }) async {
    return _post(
      '$_baseUrl/login',
      body: {
        'identifier': identifier,
        'password': password, // NEVER log this
      },
      headers: _publicHeaders,
    );
  }

  // ─── User Profile ─────────────────────────────────────────────────────────

  /// Fetch the authenticated user's profile.
  ///
  /// GET /api/auth/user/:id
  /// Requires a valid Bearer JWT.
  ///
  /// Reads [userId] and [token] from SharedPreferences if not provided.
  ///
  /// Throws:
  ///  - [_ApiException] with statusCode 401 if token is expired/invalid.
  ///  - [_ApiException] with statusCode 403 if user cannot access this profile.
  ///  - [_ApiException] with statusCode 404 if user not found.
  static Future<UserProfile> getUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';
    final userId = prefs.getString('cached_userId') ?? '';

    if (userId.isEmpty) {
      throw _ApiException('User session not found. Please log in again.', statusCode: 401);
    }

    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/user/$userId'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token', // NEVER log this header
            },
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        try {
          final data = json.decode(response.body) as Map<String, dynamic>;
          return UserProfile.fromJson(data);
        } catch (_) {
          throw _ApiException('Failed to parse profile data.', statusCode: 500);
        }
      }

      // Error — parse backend message
      String errorMessage;
      try {
        final data = json.decode(response.body) as Map<String, dynamic>;
        errorMessage = (data['error'] ?? data['message'] ?? '').toString();
        if (errorMessage.isEmpty) errorMessage = _defaultError(response.statusCode);
      } catch (_) {
        errorMessage = _defaultError(response.statusCode);
      }

      throw _ApiException(errorMessage, statusCode: response.statusCode);
    } on SocketException {
      throw Exception(
          'Unable to connect to the server. Please check your internet connection and try again.');
    } on HttpException {
      throw Exception(
          'Unable to connect to the server. Please check your internet connection and try again.');
    } catch (e) {
      if (e is _ApiException) rethrow;
      if (e is Exception) rethrow;
      throw Exception('Request failed. Please try again.');
    }
  }

  /// Upload the authenticated user's profile picture.
  ///
  /// PUT /api/auth/user/:id/profile-picture
  /// Requires a valid Bearer JWT.
  ///
  /// [imagePath] is the local file path to the selected image.
  static Future<Map<String, dynamic>> uploadProfilePicture(String imagePath) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';
    final userId = prefs.getString('cached_userId') ?? '';

    if (userId.isEmpty) {
      throw _ApiException('User session not found. Please log in again.', statusCode: 401);
    }

    try {
      final request = http.MultipartRequest(
        'PUT',
        Uri.parse('$_baseUrl/user/$userId/profile-picture'),
      );
      request.headers['Authorization'] = 'Bearer $token';
      
      request.files.add(
        await http.MultipartFile.fromPath('profilePicture', imagePath),
      );

      final streamedResponse = await request.send().timeout(const Duration(seconds: 45));
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        try {
          return json.decode(response.body) as Map<String, dynamic>;
        } catch (_) {
          throw _ApiException('Failed to parse response data.', statusCode: 500);
        }
      }

      String errorMessage;
      try {
        final data = json.decode(response.body) as Map<String, dynamic>;
        errorMessage = (data['error'] ?? data['message'] ?? '').toString();
        if (errorMessage.isEmpty) errorMessage = _defaultError(response.statusCode);
      } catch (_) {
        errorMessage = _defaultError(response.statusCode);
      }
      throw _ApiException(errorMessage, statusCode: response.statusCode);
    } on SocketException {
      throw Exception('Unable to connect to the server. Please check your internet connection and try again.');
    } on HttpException {
      throw Exception('Unable to connect to the server. Please check your internet connection and try again.');
    } catch (e) {
      if (e is _ApiException) rethrow;
      if (e is Exception) rethrow;
      throw Exception('Request failed. Please try again.');
    }
  }

  // ─── Token / Session ──────────────────────────────────────────────────────

  /// Save JWT and mark user as logged in.
  /// Call this after a successful login or set-password response.
  /// Optionally persists [userId] as 'cached_userId' so wishlist and profile
  /// APIs can use it without re-decoding the JWT.
  static Future<void> saveSession(String token, {String? userId}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    await prefs.setBool('isLoggedIn', true);
    if (userId != null && userId.isNotEmpty) {
      await prefs.setString('cached_userId', userId);
    }
  }

  /// Clear JWT and authentication state.
  /// Call this on logout or when a 401 Unauthorized is received.
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('cached_userId');
    await prefs.setBool('isLoggedIn', false);
    
    // Clear wishlist cache to prevent leaking state between users
    WishlistApiService.clearCache();
  }

  // ─── Internal HTTP helper ─────────────────────────────────────────────────

  static Future<Map<String, dynamic>> _post(
    String url, {
    required Map<String, dynamic> body,
    required Map<String, String> headers,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(url),
            headers: headers,
            body: json.encode(body),
          )
          .timeout(const Duration(seconds: 30));

      return _processResponse(response);
    } on SocketException {
      throw Exception(
          'Unable to connect to the server. Please check your internet connection and try again.');
    } on HttpException {
      throw Exception(
          'Unable to connect to the server. Please check your internet connection and try again.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Request failed. Please try again.');
    }
  }

  static Map<String, dynamic> _processResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        return json.decode(response.body) as Map<String, dynamic>;
      } catch (_) {
        return {'message': 'Success'};
      }
    }

    // Error response — parse backend message
    String errorMessage;
    try {
      final data = json.decode(response.body) as Map<String, dynamic>;
      errorMessage = (data['error'] ?? data['message'] ?? '').toString();
      if (errorMessage.isEmpty) errorMessage = _defaultError(response.statusCode);
    } catch (_) {
      errorMessage = _defaultError(response.statusCode);
    }

    throw _ApiException(errorMessage, statusCode: response.statusCode);
  }

  static String _defaultError(int statusCode) {
    switch (statusCode) {
      case 400:
        return 'Invalid request. Please check your details and try again.';
      case 401:
        return 'Invalid credentials.';
      case 409:
        return 'An account with this email or phone number already exists.';
      case 500:
        return 'Something went wrong on the server. Please try again later.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}

/// Internal exception that carries the HTTP status code.
/// Use this to detect 401 Unauthorized and clear the session.
class _ApiException implements Exception {
  final String message;
  final int statusCode;

  const _ApiException(this.message, {required this.statusCode});

  @override
  String toString() => message;
}

/// Public-facing exception type for callers that need to inspect status.
class ApiException implements Exception {
  final String message;
  final int statusCode;

  const ApiException(this.message, {required this.statusCode});

  @override
  String toString() => message;
}

