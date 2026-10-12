import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'auth_api_service.dart';
import '../login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/property_model.dart';

class WishlistApiService {
  static const String _baseUrl = ApiConfig.apiBaseUrl;
  
  // Local cache of wishlisted property IDs
  static final Set<String> _wishlistedIds = {};
  static bool _hasLoadedWishlist = false;

  // Guard against duplicate simultaneous toggle requests for the same property
  static final Set<String> _pendingToggles = {};

  /// Returns true if the given property ID is currently in the wishlist.
  static bool isWishlisted(String propertyId) {
    return _wishlistedIds.contains(propertyId);
  }

  /// Toggles the wishlist status of a property.
  ///
  /// POST /api/wishlist/toggle
  /// Headers: Content-Type: application/json, Authorization: Bearer <jwt>
  /// Body:    { "propertyId": "<id>" }
  /// Returns the server's actual isWishlisted value.
  static Future<bool> toggleWishlist(String propertyId) async {
    // Prevent duplicate simultaneous requests for the same property
    if (_pendingToggles.contains(propertyId)) {
      throw Exception('Toggle already in progress for this property.');
    }
    _pendingToggles.add(propertyId);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';
      String userId = prefs.getString('cached_userId') ?? '';
      
      if (userId.isEmpty && token.isNotEmpty) {
        try {
          final parts = token.split('.');
          if (parts.length == 3) {
            final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
            final data = json.decode(payload);
            userId = (data['id'] ?? data['_id'] ?? data['userId'] ?? data['sub'] ?? '').toString();
            if (userId.isNotEmpty) {
              await prefs.setString('cached_userId', userId);
            }
          }
        } catch (_) {}
      }

      if (userId.isEmpty && token.isNotEmpty) {
        try {
          final profileRes = await http.get(
            Uri.parse('$_baseUrl/auth/user'),
            headers: {'Authorization': 'Bearer $token'},
          ).timeout(const Duration(seconds: 10));
          if (profileRes.statusCode == 200) {
            final data = json.decode(profileRes.body);
            userId = (data['id'] ?? data['userId'] ?? data['_id'] ?? '').toString();
            if (userId.isNotEmpty) {
              await prefs.setString('cached_userId', userId);
            }
          }
        } catch (_) {}
      }

      if (token.isEmpty || userId.isEmpty) {
        throw Exception('Authentication required. Please login.');
      }

      if (propertyId.isEmpty) {
        throw Exception('400:Property ID is missing.');
      }

      debugPrint('[Wishlist Debug] POST /api/wishlist/toggle');
      debugPrint('[Wishlist Debug] userId = $userId');
      debugPrint('[Wishlist Debug] propertyId = $propertyId');
      
      final response = await http.post(
        Uri.parse('$_baseUrl/wishlist/toggle'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'userId': userId,
          'propertyId': propertyId,
        }),
      ).timeout(const Duration(seconds: 15));

      debugPrint('[Wishlist Debug] statusCode = ${response.statusCode}');
      debugPrint('[Wishlist Debug] responseBody = ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final bool isWishlisted = data['isWishlisted'] ?? false;

        if (isWishlisted) {
          _wishlistedIds.add(propertyId);
        } else {
          _wishlistedIds.remove(propertyId);
        }

        return isWishlisted;
      } else {
        String errorMessage = 'Failed to update wishlist. Please try again.';
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
    } finally {
      _pendingToggles.remove(propertyId);
    }
  }

  /// Fetches the user's wishlist and updates the local cache.
  /// GET /api/wishlist/:userId
  static Future<List<Property>> getWishlist() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';
    String userId = prefs.getString('cached_userId') ?? '';
    
    if (userId.isEmpty && token.isNotEmpty) {
      try {
        final parts = token.split('.');
        if (parts.length == 3) {
          final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
          final data = json.decode(payload);
          userId = (data['id'] ?? data['_id'] ?? data['userId'] ?? data['sub'] ?? '').toString();
          if (userId.isNotEmpty) {
            await prefs.setString('cached_userId', userId);
          }
        }
      } catch (_) {}
    }

    if (userId.isEmpty && token.isNotEmpty) {
      try {
        final profileRes = await http.get(
          Uri.parse('$_baseUrl/auth/user'),
          headers: {'Authorization': 'Bearer $token'},
        ).timeout(const Duration(seconds: 10));
        if (profileRes.statusCode == 200) {
          final data = json.decode(profileRes.body);
          userId = (data['id'] ?? data['userId'] ?? data['_id'] ?? '').toString();
          if (userId.isNotEmpty) {
            await prefs.setString('cached_userId', userId);
          }
        }
      } catch (_) {}
    }
    
    if (token.isEmpty || userId.isEmpty) {
      throw Exception('Authentication required. Please login.');
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/wishlist'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    ).timeout(const Duration(seconds: 30));

    debugPrint('[Wishlist Debug] GET /api/wishlist statusCode = ${response.statusCode}');
    debugPrint('[Wishlist Debug] responseBody = ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data != null && data['wishlist'] != null) {
        final List propertiesData = data['wishlist'];
        
        final properties = propertiesData.map((json) {
          try {
            return Property.fromJson(json);
          } catch (e) {
            debugPrint('[Wishlist Debug] Error parsing property: $e');
            rethrow;
          }
        }).toList();
        
        // Update local cache
        _wishlistedIds.clear();
        for (final p in properties) {
          _wishlistedIds.add(p.id);
          p.isFavorite = true;
        }
        _hasLoadedWishlist = true;
        
        return properties;
      }
      return [];
    } else if (response.statusCode == 401) {
      throw Exception('Invalid or expired token.');
    } else {
      throw Exception('Failed to load wishlist. Status: ${response.statusCode}');
    }
  }
  
  /// Preload wishlist IDs if not already loaded. Fails silently.
  static Future<void> preloadWishlist() async {
    if (_hasLoadedWishlist) return;
    try {
      await getWishlist();
    } catch (e) {
      // Fail silently on preload
    }
  }

  /// Clears the local cache (call this on logout)
  static void clearCache() {
    _wishlistedIds.clear();
    _hasLoadedWishlist = false;
    _pendingToggles.clear();
  }

  /// Helper to handle UI toggle logic consistently
  static Future<void> handleToggleWishlist(
    BuildContext context,
    String propertyId, {
    required Function(bool) onUpdate,
    required Function(String) onError,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('isLoggedIn') != true) {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Login Required'),
            content: const Text('Please login to save properties to your wishlist.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
                child: const Text('Log In'),
              ),
            ],
          ),
        );
      }
      return;
    }

    // Validate propertyId before making the request
    if (propertyId.isEmpty) {
      onError('Invalid property. Please try again.');
      return;
    }

    // Store original state for rollback
    final originalState = isWishlisted(propertyId);
    final optimisticState = !originalState;

    // Optimistically update the UI immediately
    if (optimisticState) {
      _wishlistedIds.add(propertyId);
    } else {
      _wishlistedIds.remove(propertyId);
    }
    onUpdate(optimisticState);

    try {
      final newState = await toggleWishlist(propertyId);
      // Synchronize with the exact state returned by the backend
      if (newState) {
        _wishlistedIds.add(propertyId);
      } else {
        _wishlistedIds.remove(propertyId);
      }
      onUpdate(newState);
    } on Exception catch (e) {
      final errorString = e.toString();

      debugPrint('[Wishlist] handleToggleWishlist error: $errorString');

      // Silently ignore duplicate in-progress toggle
      if (errorString.contains('Toggle already in progress')) {
        return;
      }

      // Auth failures → clear session and redirect to login
      if (errorString.contains('401:') ||
          errorString.contains('Authentication required') ||
          errorString.contains('Invalid or expired token') ||
          errorString.contains('Unauthorized')) {
        await AuthApiService.clearSession();
        if (context.mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
        }
        return;
      }

      // Revert UI and cache on error
      if (originalState) {
        _wishlistedIds.add(propertyId);
      } else {
        _wishlistedIds.remove(propertyId);
      }
      onUpdate(originalState);

      // Extract the most useful message to show the user
      String displayMsg;
      if (errorString.contains('TimeoutException') ||
          errorString.contains('timed out')) {
        displayMsg = 'Request timed out. Please check your connection.';
      } else if (errorString.contains('SocketException') ||
          errorString.contains('Connection refused') ||
          errorString.contains('No address associated')) {
        displayMsg = 'Unable to connect. Please check your internet.';
      } else {
        // Extract backend message from format "Exception: STATUS:MSG"
        displayMsg = 'Failed to update wishlist. Please try again.';
        final cleaned = errorString.replaceFirst('Exception: ', '');
        final colonIdx = cleaned.indexOf(':');
        if (colonIdx != -1 && colonIdx < 4) {
          // Starts with a status code like "400:", "500:", etc.
          final msg = cleaned.substring(colonIdx + 1).trim();
          if (msg.isNotEmpty) displayMsg = msg;
        } else if (cleaned.isNotEmpty &&
            !cleaned.startsWith('Exception') &&
            !cleaned.startsWith('Error')) {
          displayMsg = cleaned;
        }
      }

      onError(displayMsg);
    } catch (e) {
      // Catch non-Exception errors (Error subtypes, etc.)
      debugPrint('[Wishlist] Unexpected error type: ${e.runtimeType} — $e');
      onUpdate(originalState);
      onError('An unexpected error occurred. Please try again.');
    }
  }
}
