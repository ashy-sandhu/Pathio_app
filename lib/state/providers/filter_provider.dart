import 'package:flutter/foundation.dart';
import '../../data/models/city_model.dart';
import '../../data/models/country_model.dart';
import '../../data/repositories/places_repository.dart';

class FilterProvider extends ChangeNotifier {
  final PlacesRepository _repository;

  FilterProvider({PlacesRepository? repository})
    : _repository = repository ?? PlacesRepository();

  // State variables
  List<Country> _countries = [];
  List<City> _cities = [];
  Country? _selectedCountry;
  City? _selectedCity;
  String _selectedCategory = 'All';
  bool _isLoadingCountries = false;
  bool _isLoadingCities = false;
  String? _countriesError;
  String? _citiesError;

  // Getters
  List<Country> get countries => _countries;
  List<City> get cities => _cities;
  Country? get selectedCountry => _selectedCountry;
  City? get selectedCity => _selectedCity;
  String get selectedCategory => _selectedCategory;
  bool get isLoadingCountries => _isLoadingCountries;
  bool get isLoadingCities => _isLoadingCities;
  String? get countriesError => _countriesError;
  String? get citiesError => _citiesError;
  bool get hasError => _countriesError != null || _citiesError != null;
  bool get isLoading => _isLoadingCountries || _isLoadingCities;

  // Available categories - matching API exactly
  static const List<String> categories = [
    'All',
    'restaurant',
    'museum',
    'park',
    'monument',
    'hotel',
    'shopping',
    'entertainment',
    'nature',
    'religious',
    'others',
  ];

  // Load countries
  Future<void> loadCountries() async {
    if (_isLoadingCountries) return;

    _isLoadingCountries = true;
    _countriesError = null;
    notifyListeners();

    try {
      _countries = await _repository.getAllCountries();
      _countriesError = null;
    } catch (e) {
      _countriesError = e.toString();
    } finally {
      _isLoadingCountries = false;
      notifyListeners();
    }
  }

  // Load cities
  Future<void> loadCities() async {
    if (_isLoadingCities) return;

    _isLoadingCities = true;
    _citiesError = null;
    notifyListeners();

    try {
      _cities = await _repository.getAllCities();
      _citiesError = null;
    } catch (e) {
      _citiesError = e.toString();
    } finally {
      _isLoadingCities = false;
      notifyListeners();
    }
  }

  // Load cities for a specific country
  Future<void> loadCitiesForCountry(int countryId) async {
    if (_isLoadingCities) return;

    _isLoadingCities = true;
    _citiesError = null;
    notifyListeners();

    try {
      final allCities = await _repository.getAllCities();
      _cities = allCities
          .where((city) => city.countryName == _selectedCountry?.name)
          .toList();
      _citiesError = null;
    } catch (e) {
      _citiesError = e.toString();
    } finally {
      _isLoadingCities = false;
      notifyListeners();
    }
  }

  // Set selected country
  void setSelectedCountry(Country? country) {
    _selectedCountry = country;
    _selectedCity = null; // Reset city when country changes
    notifyListeners();

    // Load cities for the selected country
    if (country != null) {
      loadCitiesForCountry(country.id);
    } else {
      loadCities(); // Load all cities
    }
  }

  // Set selected city
  void setSelectedCity(City? city) {
    _selectedCity = city;
    notifyListeners();
  }

  // Set selected category
  void setSelectedCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  // Clear all filters
  void clearFilters() {
    _selectedCountry = null;
    _selectedCity = null;
    _selectedCategory = 'All';
    notifyListeners();
  }

  // Check if any filter is active
  bool get hasActiveFilters {
    return _selectedCountry != null ||
        _selectedCity != null ||
        _selectedCategory != 'All';
  }

  // Get filtered cities based on selected country
  List<City> get filteredCities {
    if (_selectedCountry == null) return _cities;
    return _cities
        .where((city) => city.countryName == _selectedCountry!.name)
        .toList();
  }

  // Initialize filters
  Future<void> initialize() async {
    await Future.wait([loadCountries(), loadCities()]);
  }

  // Clear errors
  void clearErrors() {
    _countriesError = null;
    _citiesError = null;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
