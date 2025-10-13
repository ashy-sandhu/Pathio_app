import 'package:flutter/foundation.dart';
import '../../data/models/place_model.dart';
import '../../data/repositories/places_repository.dart';

class SearchProvider extends ChangeNotifier {
  final PlacesRepository _placesRepository = PlacesRepository();

  List<Place> _searchResults = [];
  List<String> _searchHistory = [];
  bool _isSearching = false;
  String? _searchError;
  bool _hasSearched = false;

  // Getters
  List<Place> get searchResults => _searchResults;
  List<String> get searchHistory => _searchHistory;
  bool get isSearching => _isSearching;
  String? get searchError => _searchError;
  bool get hasError => _searchError != null;
  bool get hasSearched => _hasSearched;

  void initialize() {
    // Initialize any required setup
    // No need to notify listeners during initialization
    // notifyListeners(); // Removed - causes setState during build
  }

  Future<void> searchPlaces(String query) async {
    if (query.trim().isEmpty) {
      clearSearch();
      return;
    }

    _isSearching = true;
    _searchError = null;
    _hasSearched = true;
    notifyListeners();

    try {
      final results = await _placesRepository.searchPlaces(query);

      _searchResults = results;
      _addToHistory(query);

      if (kDebugMode) {
        print('🔍 Search completed: ${results.length} results for "$query"');
      }
    } catch (e) {
      _searchError = e.toString();
      _searchResults = [];

      if (kDebugMode) {
        print('🔍 Search error: $e');
      }
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  void clearSearch() {
    _searchResults = [];
    _searchError = null;
    _hasSearched = false;
    notifyListeners();
  }

  void _addToHistory(String query) {
    if (!_searchHistory.contains(query)) {
      _searchHistory.insert(0, query);
      // Keep only last 10 searches
      if (_searchHistory.length > 10) {
        _searchHistory = _searchHistory.take(10).toList();
      }
      notifyListeners();
    }
  }

  void removeFromHistory(String query) {
    _searchHistory.remove(query);
    notifyListeners();
  }

  void clearSearchHistory() {
    _searchHistory.clear();
    notifyListeners();
  }
}
