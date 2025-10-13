import 'package:shared_preferences/shared_preferences.dart';

class PermissionManager {
  static const String _locationPermissionAskedKey = 'location_permission_asked';
  static const String _locationPermissionGrantedKey =
      'location_permission_granted';

  // Check if we've already asked for location permission
  static Future<bool> hasAskedForLocationPermission() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_locationPermissionAskedKey) ?? false;
  }

  // Mark that we've asked for location permission
  static Future<void> markLocationPermissionAsked() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_locationPermissionAskedKey, true);
  }

  // Check if location permission was granted
  static Future<bool> wasLocationPermissionGranted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_locationPermissionGrantedKey) ?? false;
  }

  // Mark that location permission was granted
  static Future<void> markLocationPermissionGranted(bool granted) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_locationPermissionGrantedKey, granted);
  }

  // Reset permission state (for testing or if user wants to be asked again)
  static Future<void> resetPermissionState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_locationPermissionAskedKey);
    await prefs.remove(_locationPermissionGrantedKey);
  }
}
