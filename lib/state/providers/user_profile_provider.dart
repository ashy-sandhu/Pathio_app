import 'package:flutter/foundation.dart';
import '../../services/user_data_service.dart';
import '../../data/models/saved_place_model.dart';
import '../../data/models/trip_model.dart';
import '../../data/models/review_model.dart';
import '../../data/models/place_model.dart';

class UserProfileProvider extends ChangeNotifier {
  final UserDataService _userDataService = UserDataService();

  List<SavedPlace> _savedPlaces = [];
  List<Trip> _trips = [];
  List<Review> _userReviews = [];
  bool _isLoading = false;
  String? _error;

  List<SavedPlace> get savedPlaces => _savedPlaces;
  List<Trip> get trips => _trips;
  List<Review> get userReviews => _userReviews;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // ==================== Saved Places ====================

  Future<void> loadSavedPlaces({required String userId}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _savedPlaces = await _userDataService.getSavedPlaces(userId: userId);
      _error = null;
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        print('Error loading saved places: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> savePlace({
    required String userId,
    required String placeId,
    Place? placeData,
  }) async {
    try {
      _error = null;
      notifyListeners();

      await _userDataService.savePlace(
        userId: userId,
        placeId: placeId,
        placeData: placeData,
      );

      // Reload saved places
      await loadSavedPlaces(userId: userId);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> removePlace({
    required String userId,
    required String placeId,
  }) async {
    try {
      _error = null;
      notifyListeners();

      await _userDataService.removePlace(
        userId: userId,
        placeId: placeId,
      );

      // Reload saved places
      await loadSavedPlaces(userId: userId);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> isPlaceSaved({
    required String userId,
    required String placeId,
  }) async {
    try {
      return await _userDataService.isPlaceSaved(
        userId: userId,
        placeId: placeId,
      );
    } catch (e) {
      return false;
    }
  }

  // ==================== Trips ====================

  Future<void> loadTrips({required String userId}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _trips = await _userDataService.getUserTrips(userId: userId);
      _error = null;
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        print('Error loading trips: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> createTrip({
    required String userId,
    required String name,
    String? description,
    required DateTime startDate,
    required DateTime endDate,
    required List<Place> places,
  }) async {
    try {
      _error = null;
      notifyListeners();

      final tripId = await _userDataService.createTrip(
        userId: userId,
        name: name,
        description: description,
        startDate: startDate,
        endDate: endDate,
        places: places,
      );

      // Reload trips
      await loadTrips(userId: userId);
      return tripId;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<bool> updateTrip({
    required String userId,
    required String tripId,
    String? name,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    List<Place>? places,
  }) async {
    try {
      _error = null;
      notifyListeners();

      await _userDataService.updateTrip(
        userId: userId,
        tripId: tripId,
        name: name,
        description: description,
        startDate: startDate,
        endDate: endDate,
        places: places,
      );

      // Reload trips
      await loadTrips(userId: userId);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteTrip({
    required String userId,
    required String tripId,
  }) async {
    try {
      _error = null;
      notifyListeners();

      await _userDataService.deleteTrip(
        userId: userId,
        tripId: tripId,
      );

      // Reload trips
      await loadTrips(userId: userId);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ==================== Reviews ====================

  Future<void> loadUserReviews({required String userId}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _userReviews = await _userDataService.getUserReviews(userId: userId);
      _error = null;
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        print('Error loading user reviews: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> saveReview({
    required String userId,
    required String userDisplayName,
    String? userPhotoUrl,
    required String placeId,
    required int rating,
    required String comment,
  }) async {
    try {
      _error = null;
      notifyListeners();

      final reviewId = await _userDataService.saveReview(
        userId: userId,
        userDisplayName: userDisplayName,
        userPhotoUrl: userPhotoUrl,
        placeId: placeId,
        rating: rating,
        comment: comment,
      );

      // Reload user reviews
      await loadUserReviews(userId: userId);
      return reviewId;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<bool> updateReview({
    required String reviewId,
    int? rating,
    String? comment,
  }) async {
    try {
      _error = null;
      notifyListeners();

      await _userDataService.updateReview(
        reviewId: reviewId,
        rating: rating,
        comment: comment,
      );

      // Reload user reviews
      final userId = _userReviews
          .firstWhere((r) => r.id == reviewId, orElse: () => _userReviews.first)
          .userId;
      await loadUserReviews(userId: userId);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteReview({required String reviewId}) async {
    try {
      _error = null;
      notifyListeners();

      final userId = _userReviews
          .firstWhere((r) => r.id == reviewId, orElse: () => _userReviews.first)
          .userId;

      await _userDataService.deleteReview(reviewId: reviewId);

      // Reload user reviews
      await loadUserReviews(userId: userId);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Clear all data (e.g., on logout)
  void clearData() {
    _savedPlaces = [];
    _trips = [];
    _userReviews = [];
    _error = null;
    notifyListeners();
  }
}

