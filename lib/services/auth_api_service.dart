import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';
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

  // ─── Device & Headers ───────────────────────────────────────────────────

  /// Fetches structured device data and a synthesized User-Agent
  static Future<Map<String, String>> _getDeviceData() async {
    final data = <String, String>{
      'type': 'mobile',
      'clientType': 'mobile', // Updated to 'mobile'
      'browser': 'Flutter App',
      'userAgent': 'MecoApp/1.0',
    };

    try {
      final deviceInfo = DeviceInfoPlugin();
      String deviceName = 'Unknown Device';
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        deviceName = androidInfo.model; // e.g. RMX3844
        data['deviceName'] = deviceName;
        data['os'] = 'Android ${androidInfo.version.release}';
        data['userAgent'] = 'Mozilla/5.0 (Linux; Android ${androidInfo.version.release}; ${androidInfo.model}) AppleWebKit/537.36 (KHTML, like Gecko) Mobile MecoApp/1.0';
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        deviceName = iosInfo.name;
        data['deviceName'] = deviceName;
        data['os'] = 'iOS ${iosInfo.systemVersion}';
        data['userAgent'] = 'Mozilla/5.0 (iPhone; CPU iPhone OS ${iosInfo.systemVersion.replaceAll('.', '_')} like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile MecoApp/1.0';
      }
      
      data['name'] = '$deviceName (Flutter App)';
      
    } catch (_) {
      // Fallback if platform detection fails
      data['name'] = 'Unknown Mobile (Flutter App)';
    }
    
    // DEBUG LOG: device information collected by Flutter
    print('DEBUG: Flutter Device Info Collected: $data');
    return data;
  }

  /// Headers for public (unauthenticated) endpoints.
  static Future<Map<String, String>> get _publicHeaders async {
    final headers = {
      'Content-Type': 'application/json',
    };
    final deviceData = await _getDeviceData();
    if (deviceData.containsKey('userAgent')) {
      headers['User-Agent'] = deviceData['userAgent']!;
    }
    return headers;
  }

  /// Headers for protected (authenticated) endpoints.
  /// Reads the stored JWT from SharedPreferences.
  static Future<Map<String, String>> authHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';
    
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    final deviceData = await _getDeviceData();
    if (deviceData.containsKey('userAgent')) {
      headers['User-Agent'] = deviceData['userAgent']!;
    }
    return headers;
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
    final deviceData = await _getDeviceData();
    
    final response = await _post(
      '$_baseUrl/signup',
      body: {
        'fullName': fullName,
        'number': number,
        'email': email,
        'occupation': occupation,
        ...deviceData,
      },
      headers: await _publicHeaders,
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
      headers: await _publicHeaders,
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
      headers: await _publicHeaders,
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
    final deviceData = await _getDeviceData();
    
    return _post(
      '$_baseUrl/set-password',
      body: {
        'userId': userId,
        'password': password, // NEVER log this
        ...deviceData,
      },
      headers: await _publicHeaders,
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
    final deviceData = await _getDeviceData();
    
    final payload = {
      'identifier': identifier,
      'password': password, // NEVER log this
      ...deviceData,
    };
    
    // DEBUG LOG: login request metadata (masking password)
    final debugPayload = Map<String, dynamic>.from(payload);
    debugPayload['password'] = '********';
    print('DEBUG: Login Request Payload: $debugPayload');
    
    final response = await _post(
      '$_baseUrl/login',
      body: payload,
      headers: await _publicHeaders,
    );
    
    // DEBUG LOG: session creation response (keys only to avoid logging JWT)
    print('DEBUG: Login Response Keys: ${response.keys.toList()}');
    if (response.containsKey('user')) {
      print('DEBUG: Login Response User Info: ${response['user']}');
    }
    
    return response;
  }

  // ─── User Profile ─────────────────────────────────────────────────────────

  /// Update the authenticated user's profile.
  ///
  /// PUT /api/auth/user/:id
  static Future<Map<String, dynamic>> updateUserProfile({
    String? fullName,
    String? number,
    String? occupation,
    String? area,
    String? propertyType,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';
    final userId = prefs.getString('cached_userId') ?? '';

    if (userId.isEmpty) {
      throw _ApiException('User session not found. Please log in again.', statusCode: 401);
    }

    final body = <String, dynamic>{};
    if (fullName != null) body['fullName'] = fullName;
    if (number != null) body['number'] = number;
    if (occupation != null) body['occupation'] = occupation;
    if (area != null) body['area'] = area;
    if (propertyType != null) body['propertyType'] = propertyType;

    try {
      final response = await http
          .put(
            Uri.parse('$_baseUrl/user/$userId'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: json.encode(body),
          )
          .timeout(const Duration(seconds: 30));

      return _processResponse(response);
    } on SocketException {
      throw Exception('Unable to connect to the server. Please check your internet connection.');
    } on HttpException {
      throw Exception('Unable to connect to the server. Please check your internet connection.');
    } catch (e) {
      if (e is _ApiException) rethrow;
      throw Exception('Request failed. Please try again.');
    }
  }

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

  // ─── Sessions ─────────────────────────────────────────────────────────────

  /// Get all active sessions/devices for the authenticated user
  /// GET /api/auth/sessions
  static Future<List<dynamic>> getSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';

    if (token.isEmpty) {
      throw _ApiException('User session not found.', statusCode: 401);
    }

    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/sessions'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        
        // DEBUG LOG: GET /api/auth/sessions response
        print('DEBUG: GET /api/auth/sessions Response: $data');
        
        return data['sessions'] as List<dynamic>? ?? [];
      }

      throw _ApiException(_defaultError(response.statusCode), statusCode: response.statusCode);
    } on SocketException {
      throw Exception('Unable to connect to the server.');
    } catch (e) {
      if (e is _ApiException) rethrow;
      throw Exception('Request failed.');
    }
  }

  /// Logout of a specific device
  /// DELETE /api/auth/sessions/:sessionId
  static Future<void> logoutDevice(String sessionId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';

    if (token.isEmpty) {
      throw _ApiException('User session not found.', statusCode: 401);
    }

    try {
      final response = await http
          .delete(
            Uri.parse('$_baseUrl/sessions/$sessionId'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return;
      }
      throw _ApiException(_defaultError(response.statusCode), statusCode: response.statusCode);
    } on SocketException {
      throw Exception('Unable to connect to the server.');
    } catch (e) {
      if (e is _ApiException) rethrow;
      throw Exception('Request failed.');
    }
  }

  /// Logout of all other devices
  /// DELETE /api/auth/sessions
  static Future<void> logoutAllOtherDevices() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';

    if (token.isEmpty) {
      throw _ApiException('User session not found.', statusCode: 401);
    }

    try {
      final response = await http
          .delete(
            Uri.parse('$_baseUrl/sessions'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return;
      }
      throw _ApiException(_defaultError(response.statusCode), statusCode: response.statusCode);
    } on SocketException {
      throw Exception('Unable to connect to the server.');
    } catch (e) {
      if (e is _ApiException) rethrow;
      throw Exception('Request failed.');
    }
  }

  // ─── Internal HTTP helper ─────────────────────────────────────────────────

  static Future<Map<String, dynamic>> _post(
    String url, {
    required Map<String, dynamic> body,
    required Map<String, String> headers,
  }) async {
    // DEBUG LOG: Request Endpoint and Headers
    print('DEBUG: Request Endpoint: $url');
    final debugHeaders = Map<String, String>.from(headers);
    debugHeaders.remove('Authorization');
    print('DEBUG: Request Headers: $debugHeaders');
    if (debugHeaders.containsKey('User-Agent')) {
      print('REQUEST USER-AGENT:\n${debugHeaders['User-Agent']}');
    } else {
      print('REQUEST USER-AGENT: (Not set explicitly, using Dart default)');
    }

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

