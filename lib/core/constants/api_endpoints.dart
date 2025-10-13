class ApiEndpoints {
  // Base URL
  static const String baseUrl = 'https://web-production-40bd5.up.railway.app';

  // Health Check
  static const String health = '/health/';

  // Places
  static const String places = '/api/places/';
  static const String popularPlaces = '/api/popular/';
  static const String nearbyPlaces = '/api/nearby/';
  static const String searchPlaces = '/api/search/';

  // Cities
  static const String cities = '/api/cities/';

  // Countries
  static const String countries = '/api/countries/';

  // Helper methods
  static String getPlaceById(int id) => '$places$id/';
  static String getCityById(int id) => '$cities$id/';
  static String getCountryById(int id) => '$countries$id/';
  static String getNearbyPlaces({
    required double lat,
    required double lon,
    int radius = 50,
  }) => '$nearbyPlaces?lat=$lat&lon=$lon&radius=$radius';
  static String searchPlacesByQuery(String query) =>
      '$searchPlaces?query=$query';
}
