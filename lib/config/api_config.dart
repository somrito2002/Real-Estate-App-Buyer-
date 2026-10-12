/// Centralized API and environment configuration for Pro Dalal / Dalal Realty.
/// 
/// All base URLs and server endpoints are defined here to provide
/// a single source of truth across the entire app.
class ApiConfig {
  ApiConfig._();

  /// Root backend domain (without trailing slash).
  /// Used for static asset URLs (such as profile pictures, uploaded property images).
  static const String baseUrl = 'https://api.prodalal.com';

  /// Base endpoint for general API requests (`https://api.prodalal.com/api`).
  static const String apiBaseUrl = '$baseUrl/api';

  /// Base endpoint for authentication requests (`https://api.prodalal.com/api/auth`).
  static const String authBaseUrl = '$apiBaseUrl/auth';
}
