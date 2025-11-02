import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../../services/location_service.dart';
import '../../services/permission_manager.dart';

class LocationProvider extends ChangeNotifier {
  final LocationService _locationService;

  LocationProvider({LocationService? locationService})
    : _locationService = locationService ?? LocationService();

  // State variables
  LocationData? _currentLocation;
  bool _isLoading = false;
  String? _error;
  bool _hasPermission = false;
  bool _isLocationServiceEnabled = false;
  bool _shouldShowPermissionDialog = false;

  // Getters
  LocationData? get currentLocation => _currentLocation;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasPermission => _hasPermission;
  bool get isLocationServiceEnabled => _isLocationServiceEnabled;
  bool get hasLocation => _currentLocation != null;
  bool get shouldShowPermissionDialog => _shouldShowPermissionDialog;

  // Initialize location services
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Check if location services are enabled
      _isLocationServiceEnabled = await _locationService
          .isLocationServiceEnabled();

      // Check if we have permission
      _hasPermission = await _locationService.hasLocationPermission();

      // Check if we've asked for permission before
      final hasAskedBefore =
          await PermissionManager.hasAskedForLocationPermission();

      if (_hasPermission && _isLocationServiceEnabled) {
        // User has granted permission - get location immediately
        await getCurrentLocation();
      } else if (!hasAskedBefore) {
        // First time user - show permission dialog
        _shouldShowPermissionDialog = true;
        _error = null;
      } else {
        // User denied permission before
        _error =
            'Location permission was denied. You can enable it in settings.';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get current location
  Future<void> getCurrentLocation() async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final position = await _locationService.getCurrentLocation();
      if (position != null) {
        _currentLocation = LocationData.fromPosition(position);
        _hasPermission = true;
        _error = null;
      } else {
        _error = 'Unable to get current location';
      }
    } catch (e) {
      _error = e.toString();
      _hasPermission = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Request location permission
  Future<void> requestPermission() async {
    _isLoading = true;
    notifyListeners();

    try {
      final permission = await _locationService.requestLocationPermission();
      _hasPermission =
          permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;

      if (_hasPermission) {
        await getCurrentLocation();
      } else {
        _error = 'Location permission denied';
      }
    } catch (e) {
      _error = e.toString();
      _hasPermission = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Open location settings
  Future<void> openLocationSettings() async {
    try {
      await _locationService.openLocationSettings();
    } catch (e) {
      _error = 'Failed to open location settings: $e';
      notifyListeners();
    }
  }

  // Open app settings
  Future<void> openAppSettings() async {
    try {
      await _locationService.openAppSettings();
    } catch (e) {
      _error = 'Failed to open app settings: $e';
      notifyListeners();
    }
  }

  // Get last known location
  Future<void> getLastKnownLocation() async {
    try {
      final position = await _locationService.getLastKnownLocation();
      if (position != null) {
        _currentLocation = LocationData.fromPosition(position);
        _error = null;
      }
    } catch (e) {
      _error = e.toString();
    }
    notifyListeners();
  }

  // Calculate distance to a place
  double? calculateDistanceToPlace(double lat, double lon) {
    if (_currentLocation == null) return null;

    return _locationService.calculateDistance(
      _currentLocation!.latitude,
      _currentLocation!.longitude,
      lat,
      lon,
    );
  }

  // Clear error
  // Handle permission dialog response
  Future<void> onPermissionDialogResponse(bool granted) async {
    _shouldShowPermissionDialog = false;

    // Mark that we've asked for permission
    await PermissionManager.markLocationPermissionAsked();
    await PermissionManager.markLocationPermissionGranted(granted);

    if (granted) {
      // User granted permission - try to get location
      await getCurrentLocation();
    } else {
      // User denied permission
      _error = 'Location permission denied. You can enable it in settings.';
    }

    notifyListeners();
  }

  // Dismiss permission dialog without action
  void dismissPermissionDialog() {
    _shouldShowPermissionDialog = false;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

}
