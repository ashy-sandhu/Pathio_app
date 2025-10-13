import '../models/place_model.dart';
import '../models/city_model.dart';
import '../models/country_model.dart';
import '../services/api_service.dart';

class PlacesRepository {
  final ApiService _apiService;

  PlacesRepository({ApiService? apiService}) 
      : _apiService = apiService ?? ApiService();

  // Places methods
  Future<List<Place>> getAllPlaces() async {
    try {
      return await _apiService.getAllPlaces();
    } catch (e) {
      throw RepositoryException('Failed to fetch places: $e');
    }
  }

  Future<Place> getPlaceById(int id) async {
    try {
      return await _apiService.getPlaceById(id);
    } catch (e) {
      throw RepositoryException('Failed to fetch place: $e');
    }
  }

  Future<List<Place>> getPopularPlaces() async {
    try {
      return await _apiService.getPopularPlaces();
    } catch (e) {
      throw RepositoryException('Failed to fetch popular places: $e');
    }
  }

  Future<List<Place>> getNearbyPlaces({
    required double lat,
    required double lon,
    int radius = 50,
  }) async {
    try {
      return await _apiService.getNearbyPlaces(
        lat: lat,
        lon: lon,
        radius: radius,
      );
    } catch (e) {
      throw RepositoryException('Failed to fetch nearby places: $e');
    }
  }

  Future<List<Place>> searchPlaces(String query) async {
    try {
      if (query.trim().isEmpty) return [];
      return await _apiService.searchPlaces(query.trim());
    } catch (e) {
      throw RepositoryException('Failed to search places: $e');
    }
  }

  // Cities methods
  Future<List<City>> getAllCities() async {
    try {
      return await _apiService.getAllCities();
    } catch (e) {
      throw RepositoryException('Failed to fetch cities: $e');
    }
  }

  Future<City> getCityById(int id) async {
    try {
      return await _apiService.getCityById(id);
    } catch (e) {
      throw RepositoryException('Failed to fetch city: $e');
    }
  }

  // Countries methods
  Future<List<Country>> getAllCountries() async {
    try {
      return await _apiService.getAllCountries();
    } catch (e) {
      throw RepositoryException('Failed to fetch countries: $e');
    }
  }

  Future<Country> getCountryById(int id) async {
    try {
      return await _apiService.getCountryById(id);
    } catch (e) {
      throw RepositoryException('Failed to fetch country: $e');
    }
  }

  // Health check
  Future<bool> isApiHealthy() async {
    try {
      return await _apiService.checkHealth();
    } catch (e) {
      return false;
    }
  }
}

// Custom exception for repository errors
class RepositoryException implements Exception {
  final String message;

  RepositoryException(this.message);

  @override
  String toString() => 'RepositoryException: $message';
}
