import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'auth_api_service.dart';
import '../login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/property_model.dart';

class WishlistApiService {
  static const String _baseUrl = 'https://api.prodalal.com/api';
  
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

      if (token.isEmpty) {
        throw Exception('Authentication required. Please provide a valid token.');
      }

      if (propertyId.isEmpty) {
        throw Exception('400:Property ID is missing.');
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/wishlist/toggle'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'propertyId': propertyId,
        }),
      ).timeout(const Duration(seconds: 15));

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
  /// GET /api/wishlist/
  static Future<List<Property>> getWishlist() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';
    
    if (token.isEmpty) {
      throw Exception('Authentication required. Please provide a valid token.');
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/wishlist/'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    ).timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data != null && data['wishlist'] != null) {
        final List propertiesData = data['wishlist'];
        
        final properties = propertiesData.map((json) => Property.fromJson(json)).toList();
        
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
      onError('Please login to save properties to your wishlist.');
      return;
    }

    // Validate propertyId before making the request
    if (propertyId.isEmpty) {
      onError('Invalid property. Please try again.');
      return;
    }

    // Store original state for rollback
    final originalState = isWishlisted(propertyId);

    try {
      final newState = await toggleWishlist(propertyId);
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

      // Revert UI on error
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
