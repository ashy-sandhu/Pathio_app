import 'package:flutter/foundation.dart';
import '../../data/models/place_model.dart';
import '../../data/repositories/places_repository.dart';

class PlacesProvider extends ChangeNotifier {
  final PlacesRepository _repository;

  PlacesProvider({PlacesRepository? repository})
    : _repository = repository ?? PlacesRepository();

  // State variables
  List<Place> _popularPlaces = [];
  List<Place> _nearbyPlaces = [];
  List<Place> _allPlaces = [];
  List<Place> _allPopularPlaces = []; // Store all popular places
  List<Place> _allNearbyPlaces = []; // Store all nearby places
  bool _isLoadingPopular = false;
  bool _isLoadingNearby = false;
  bool _isLoadingAll = false;
  bool _isLoadingMorePopular = false;
  bool _isLoadingMoreNearby = false;
  String? _popularError;
  String? _nearbyError;
  String? _allError;

  // Pagination constants
  static const int _popularPageSize = 8;
  static const int _nearbyPageSize = 5;

  // Getters
  List<Place> get popularPlaces => _popularPlaces;
  List<Place> get nearbyPlaces => _nearbyPlaces;
  List<Place> get allPlaces => _allPlaces;
  bool get isLoadingPopular => _isLoadingPopular;
  bool get isLoadingNearby => _isLoadingNearby;
  bool get isLoadingAll => _isLoadingAll;
  bool get isLoadingMorePopular => _isLoadingMorePopular;
  bool get isLoadingMoreNearby => _isLoadingMoreNearby;
  String? get popularError => _popularError;
  String? get nearbyError => _nearbyError;
  String? get allError => _allError;
  bool get hasError =>
      _popularError != null || _nearbyError != null || _allError != null;
  bool get isLoading => _isLoadingPopular || _isLoadingNearby || _isLoadingAll;
  bool get hasMorePopular => _popularPlaces.length < _allPopularPlaces.length;
  bool get hasMoreNearby => _nearbyPlaces.length < _allNearbyPlaces.length;

  // Load popular places with pagination and filtering
  Future<void> loadPopularPlaces({String? category}) async {
    if (_isLoadingPopular) return;

    _isLoadingPopular = true;
    _popularError = null;
    // Clear previous results immediately to prevent stale data
    _popularPlaces = [];
    notifyListeners();

    try {
      // Only fetch from API if we don't have all places loaded yet
      if (_allPopularPlaces.isEmpty) {
        // Use compute for heavy operations to avoid blocking main thread
        _allPopularPlaces = await _repository.getPopularPlaces();
      }

      // Create a filtered list without modifying the original
      List<Place> filteredPlaces = List.from(_allPopularPlaces);

      // Apply category filter if provided
      if (category != null && category != 'All') {
        filteredPlaces = filteredPlaces
            .where(
              (place) => place.category.toLowerCase() == category.toLowerCase(),
            )
            .toList();
      }

      // Shuffle and take first page
      filteredPlaces.shuffle();
      _popularPlaces = filteredPlaces.take(_popularPageSize).toList();
      _popularError = null;
    } catch (e) {
      _popularError = e.toString();
      _popularPlaces = []; // Ensure empty list on error

      if (kDebugMode) {
        print('❌ Error loading popular places: $e');
      }
    } finally {
      _isLoadingPopular = false;
      notifyListeners();
    }
  }

  // Load more popular places
  Future<void> loadMorePopularPlaces() async {
    if (_isLoadingMorePopular || !hasMorePopular) return;

    _isLoadingMorePopular = true;
    notifyListeners();

    try {
      final currentLength = _popularPlaces.length;
      final nextPage = _allPopularPlaces
          .skip(currentLength)
          .take(_popularPageSize)
          .toList();
      _popularPlaces.addAll(nextPage);
    } catch (e) {
      // Handle error if needed
    } finally {
      _isLoadingMorePopular = false;
      notifyListeners();
    }
  }

  // Load nearby places with smart fallback
  Future<void> loadNearbyPlaces({
    required double lat,
    required double lon,
    int radius = 50,
  }) async {
    if (_isLoadingNearby) return;

    print('📍 Loading nearby places: lat=$lat, lon=$lon, radius=$radius');
    _isLoadingNearby = true;
    _nearbyError = null;
    notifyListeners();

    try {
      // Try with increasing radius if no places found
      final radiusValues = [radius, radius * 2, radius * 5, radius * 10];

      for (final currentRadius in radiusValues) {
        print('📍 Trying radius: ${currentRadius}km');
        _nearbyPlaces = await _repository.getNearbyPlaces(
          lat: lat,
          lon: lon,
          radius: currentRadius,
        );

        if (_nearbyPlaces.isNotEmpty) {
          print(
            '📍 Found ${_nearbyPlaces.length} places within ${currentRadius}km',
          );
          break;
        }
      }

      // If still no places found, show a helpful message
      if (_nearbyPlaces.isEmpty) {
        print('📍 No nearby places found, showing popular places instead');
        _nearbyError =
            'No places found nearby. Showing popular places instead.';
        // Load popular places as fallback
        _allNearbyPlaces = await _repository.getPopularPlaces();
        _allNearbyPlaces.shuffle();
        _nearbyPlaces = _allNearbyPlaces.take(_nearbyPageSize).toList();
      } else {
        _nearbyError = null;
        _allNearbyPlaces = _nearbyPlaces;
        _nearbyPlaces = _nearbyPlaces.take(_nearbyPageSize).toList();
      }

      print('📍 Nearby places loaded: ${_nearbyPlaces.length} places');
    } catch (e) {
      print('📍 Error loading nearby places: $e');
      _nearbyError = e.toString();
    } finally {
      _isLoadingNearby = false;
      notifyListeners();
    }
  }

  // Load more nearby places
  Future<void> loadMoreNearbyPlaces() async {
    if (_isLoadingMoreNearby || !hasMoreNearby) return;

    _isLoadingMoreNearby = true;
    notifyListeners();

    try {
      final currentLength = _nearbyPlaces.length;
      final nextPage = _allNearbyPlaces
          .skip(currentLength)
          .take(_nearbyPageSize)
          .toList();
      _nearbyPlaces.addAll(nextPage);
    } catch (e) {
      // Handle error if needed
    } finally {
      _isLoadingMoreNearby = false;
      notifyListeners();
    }
  }

  // Load all places
  Future<void> loadAllPlaces() async {
    if (_isLoadingAll) return;

    _isLoadingAll = true;
    _allError = null;
    notifyListeners();

    try {
      _allPlaces = await _repository.getAllPlaces();
      _allError = null;
    } catch (e) {
      _allError = e.toString();
    } finally {
      _isLoadingAll = false;
      notifyListeners();
    }
  }

  // Refresh all data
  Future<void> refreshAll() async {
    await Future.wait([loadPopularPlaces(), loadAllPlaces()]);
  }

  // Clear errors
  void clearErrors() {
    _popularError = null;
    _nearbyError = null;
    _allError = null;
    notifyListeners();
  }

  // Get place by ID
  Future<Place?> getPlaceById(int id) async {
    try {
      return await _repository.getPlaceById(id);
    } catch (e) {
      return null;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
