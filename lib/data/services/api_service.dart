import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/place_model.dart';
import '../models/city_model.dart';
import '../models/country_model.dart';
import '../../core/constants/api_endpoints.dart';

class ApiService {
  static const Duration _timeout = Duration(seconds: 30);

  // Helper method for GET requests
  Future<dynamic> _get(String endpoint) async {
    try {
      final uri = Uri.parse('${ApiEndpoints.baseUrl}$endpoint');
      final response = await http.get(uri).timeout(_timeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw ApiException(
          'HTTP ${response.statusCode}: ${response.reasonPhrase}',
          response.statusCode,
        );
      }
    } on http.ClientException {
      throw ApiException('No internet connection', 0);
    } catch (e) {
      throw ApiException('Request failed: $e', 0);
    }
  }

  // Health check
  Future<bool> checkHealth() async {
    try {
      await _get(ApiEndpoints.health);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Places endpoints
  Future<List<Place>> getAllPlaces() async {
    final response = await _get(ApiEndpoints.places);
    final placesList = response is List
        ? response
        : (response['results'] as List<dynamic>? ?? []);
    return placesList.map((json) => Place.fromJson(json)).toList();
  }

  Future<Place> getPlaceById(int id) async {
    final response = await _get(ApiEndpoints.getPlaceById(id));
    return Place.fromJson(response);
  }

  Future<List<Place>> getPopularPlaces() async {
    final response = await _get(ApiEndpoints.popularPlaces);
    final placesList = response is List
        ? response
        : (response['results'] as List<dynamic>? ?? []);
    return placesList.map((json) => Place.fromJson(json)).toList();
  }

  Future<List<Place>> getNearbyPlaces({
    required double lat,
    required double lon,
    int radius = 50,
  }) async {
    final endpoint = ApiEndpoints.getNearbyPlaces(
      lat: lat,
      lon: lon,
      radius: radius,
    );
    print('🌐 API Call: $endpoint');

    final response = await _get(endpoint);
    print('🌐 API Response type: ${response.runtimeType}');
    print(
      '🌐 API Response length: ${response is List ? response.length : 'Not a list'}',
    );

    final placesList = response is List
        ? response
        : (response['results'] as List<dynamic>? ?? []);
    print('🌐 Places list length: ${placesList.length}');

    return placesList.map((json) => Place.fromJson(json)).toList();
  }

  Future<List<Place>> searchPlaces(String query) async {
    final response = await _get(ApiEndpoints.searchPlacesByQuery(query));
    final placesList = response is List
        ? response
        : (response['results'] as List<dynamic>? ?? []);
    return placesList.map((json) => Place.fromJson(json)).toList();
  }

  // Cities endpoints
  Future<List<City>> getAllCities() async {
    final response = await _get(ApiEndpoints.cities);
    final citiesList = response is List
        ? response
        : (response['results'] as List<dynamic>? ?? []);
    return citiesList.map((json) => City.fromJson(json)).toList();
  }

  Future<City> getCityById(int id) async {
    final response = await _get(ApiEndpoints.getCityById(id));
    return City.fromJson(response);
  }

  // Countries endpoints
  Future<List<Country>> getAllCountries() async {
    final response = await _get(ApiEndpoints.countries);
    final countriesList = response is List
        ? response
        : (response['results'] as List<dynamic>? ?? []);
    return countriesList.map((json) => Country.fromJson(json)).toList();
  }

  Future<Country> getCountryById(int id) async {
    final response = await _get(ApiEndpoints.getCountryById(id));
    return Country.fromJson(response);
  }
}

// Custom exception for API errors
class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException(this.message, this.statusCode);

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}
